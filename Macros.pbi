; File: Macros.pbi

EnableExplicit

Macro scsRaiseError()
  ; Macro added 23Jun2021 11.8.5am
  ; Replaces previous incorrect use of RaiseError(ErrorNumber), because ErrorNumber must be a #PB_OnError_... constant, whereas we want to supply an SCS error number.
  ; NB gsError must first be set using a call to setGlobalError(nErrorCode, ...)
  scsMessageRequester("SCS Error detected in " + sProcName,
                      gsError +
                      #CRLF$ + "gnLabel=" + gnLabel + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnLabelSAM=" + gnLabelSAM + ", gnLabelSpecial=" + gnLabelSpecial + ", gnLabelPre=" + gnLabelPre +
                      #CRLF$ + #CRLF$ + "Please email the log file " + #DQUOTE$ + gsDebugFile + #DQUOTE$ + " to " + #SCS_EMAIL_SUPPORT +
                      #CRLF$ + #CRLF$ + "Force-closing SCS", #PB_MessageRequester_Error)
  End
EndMacro

Macro GGT(GadgetNo)
  ; see also macro GLT()
  GetGadgetText(GadgetNo)
EndMacro

Macro SGT(GadgetNo, pText)
  SetGadgetText(GadgetNo, pText)
EndMacro

Macro SGTIR(GadgetNo, pText)  ; SetGadgetText if required
  If GetGadgetText(GadgetNo) <> pText
    SetGadgetText(GadgetNo, pText)
  EndIf
EndMacro

Macro GLT(GadgetNo)
  ; 'get label text' - GetGadgetText() and replace any line feeds by spaces
  ; see also procedure removeLF()
  Trim(ReplaceString(GetGadgetText(GadgetNo), Chr(10), " "))
EndMacro

Macro getGadgetPropsIndex(GadgetNo)
  (GadgetNo - #SCS_GADGET_BASE_NO)
EndMacro

Macro getModGadgetType(GadgetNo)
  gaGadgetProps(GadgetNo - #SCS_GADGET_BASE_NO)\nModGadgetType
EndMacro

Macro GGS(GadgetNo)
  GetGadgetState(GadgetNo)
EndMacro

Macro SGS(GadgetNo, pState)
  SetGadgetState(GadgetNo, pState)
EndMacro

Macro SGSIR(GadgetNo, pState) ; SetGadgetState if required
  If GetGadgetState(GadgetNo) <> pState
    SetGadgetState(GadgetNo, pState)
  EndIf
EndMacro

Macro GGA(GadgetNo, pAttribute)
  GetGadgetAttribute(GadgetNo, pAttribute)
EndMacro

Macro SGA(GadgetNo, pAttribute, pValue)
  SetGadgetAttribute(GadgetNo, pAttribute, pValue)
EndMacro

Macro SGAIR(GadgetNo, pAttribute, pValue) ; SetGadgetAttribute if required
  If GetGadgetAttribute(GadgetNo, pAttribute) <> pValue
    SetGadgetAttribute(GadgetNo, pAttribute, pValue)
  EndIf
EndMacro

Macro SAG(GadgetNo)
  ; debugMsg(sProcName, "calling SetActiveGadget(" + getGadgetName(GadgetNo) + ")")
  SetActiveGadget(GadgetNo)
EndMacro

Macro SAW(WindowNo)
  ; debugMsg(sProcName, "calling SetActiveWindow(" + decodeWindow(WindowNo) + ")")
  SetActiveWindow(WindowNo)
EndMacro

Macro GWT(WindowNo)
  GetWindowTitle(WindowNo)
EndMacro

Macro SetGadgetColors(GadgetNo, pFrontColor, pBackColor)
  SetGadgetColor(GadgetNo, #PB_Gadget_FrontColor, pFrontColor)
  SetGadgetColor(GadgetNo, #PB_Gadget_BackColor, pBackColor)
EndMacro

Macro SetGadgetVisible(Gadget, Hide)  ; 0 = display, 1 = hide
  HideGadget(Gadget, Hide)
EndMacro

Macro setThreadNo(nThreadNo)
  gnThreadNo = nThreadNo
  gsThreadNo = " #" + nThreadNo + " "
EndMacro

Macro CBOCHG(pChgProc)
  CompilerIf #c_new_gui And Defined(ModuleEx, #PB_Module)
    If gnEventType = #PB_EventType_Change Or gnEventType = ModuleEx::#EventType_Change
      logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " = " + GGT(gnEventGadgetNo))
      pChgProc
    EndIf
  CompilerElse
    If gnEventType = #PB_EventType_Change
      logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " = " + GGT(gnEventGadgetNo))
      pChgProc
    EndIf
  CompilerEndIf
EndMacro

Macro CHKCHG(pChgProc)
  logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " = " + GGS(gnEventGadgetNo))
  pChgProc
EndMacro

Macro CHKOWNCHG(pChgProc)
  logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " = " + getOwnState(gnEventGadgetNo))
  pChgProc
EndMacro

Macro BTNCLICK(pClickProc)
  logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName)
  pClickProc
EndMacro

Macro LOGEVENT()
  logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName)
EndMacro

Macro ETVAL(pValProc)   ; assumes gadget no. is gnEventGadgetNo (eg for use in gadget event procedures)
  If gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd
    If pValProc = #False
      gbLastVALResult = #False
      If gnFocusGadgetNo = 0
        gnFocusGadgetNo = gnEventGadgetNo
      EndIf
    Else
      gbLastVALResult = #True
      gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd = #False
      ; debugMsg0(sProcName, "gaGadgetProps(" + gnEventGadgetPropsIndex + ")\bValidationReqd=" + strB(gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd))
      gnValidateGadgetNo = 0
      logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " = " + GGT(gnEventGadgetNo))
    EndIf
  EndIf
EndMacro

Macro ETVAL2(pValProc)   ; assumes gadget no. is nGadgetNo (eg for use in form validation procedures)
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  ;   debugMsg(sProcName, "ETVAL2: nGadgetNo=" + getGadgetName(nGadgetNo) + ", nGadgetPropsIndex=" + nGadgetPropsIndex +
  ;                       ", gaGadgetProps(nGadgetPropsIndex)\bValidationReqd=" + strB(gaGadgetProps(nGadgetPropsIndex)\bValidationReqd) +
  ;                       ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
  
  ; Note: Originally added "And (GetActiveGadget() <> nGadgetNo)" (below) in 11.4.0, but can't remember why. Removed it 28/4/2015 following a test
  ; where I modified a sub-cue description of a control send cue and then clicked the 'Save' button without tabbing out of the field. Since this
  ; sub-cue description field was still the active gadget, the macro did nothing and the \bValidationReqd flag remained set to #True, which caused
  ; WQM_valGadget() and commonValidation() to both return #False, so the 'Save' was never executed.
  If (gaGadgetProps(nGadgetPropsIndex)\bValidationReqd) ; And (GetActiveGadget() <> nGadgetNo)  ; see above note
    If pValProc = #False
      gbLastVALResult = #False
      If gnFocusGadgetNo = 0
        gnFocusGadgetNo = nGadgetNo
      EndIf
    Else
      gbLastVALResult = #True
      gaGadgetProps(nGadgetPropsIndex)\bValidationReqd = #False
      ; debugMsg0(sProcName, "gaGadgetProps(" + nGadgetPropsIndex + ")\bValidationReqd=" + strB(gaGadgetProps(nGadgetPropsIndex)\bValidationReqd))
      gnValidateGadgetNo = 0
      logKeyEvent(gaGadgetProps(nGadgetPropsIndex)\sLogName + " = " + GGT(nGadgetNo))
    EndIf
  EndIf
EndMacro

Macro PROCNAME(pProcName)
  Protected sProcName.s = pProcName
EndMacro

Macro PROCNAMEC()
  Protected sProcName.s = #PB_Compiler_Procedure
EndMacro

Macro PROCNAMECQ(pCuePtr)
  Protected sProcName.s = buildCueProcName(#PB_Compiler_Procedure, pCuePtr)
EndMacro

Macro PROCNAMECQ2(pCuePtr)
  Protected sProcName.s = buildCueProcName2(#PB_Compiler_Procedure, pCuePtr)
EndMacro

Macro PROCNAMECS(pSubPtr, bPrimaryFile=#True)
  Protected sProcName.s = buildSubProcName(#PB_Compiler_Procedure, pSubPtr, bPrimaryFile)
EndMacro

Macro PROCNAMECA(pAudPtr)
  Protected sProcName.s = buildAudProcName(#PB_Compiler_Procedure, pAudPtr)
EndMacro

Macro PROCNAMECP(h)
  Protected sProcName.s = buildCuePanelProcName(#PB_Compiler_Procedure, h)
EndMacro

Macro PROCNAMECG(pGadgetNo)
  Protected sProcName.s = buildGadgetProcName(#PB_Compiler_Procedure, pGadgetNo)
EndMacro

Macro PROCNAMECW(pWindowNo)
  Protected sProcName.s = buildWindowProcName(#PB_Compiler_Procedure, pWindowNo)
EndMacro

Macro PROCNAMECT(pThreadIndex)
  Protected sProcName.s = THR_buildThreadProcName(#PB_Compiler_Procedure, pThreadIndex)
EndMacro

Macro LABEL(pLabel)
  gnLabelOther = pLabel
  gnLabelThread = gnThreadNo
EndMacro

Macro debugMsg0(pProcName, pMessage)
  ; debug messages that ALSO issue call the PB Debug statement so that message also appears in the debugger
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line, #False, #True)
EndMacro

Macro debugMsg(pProcName, pMessage)
  ; regular debug messages
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgQ(pProcName, pMessage)
  ; regular debug messages, but replace single quotes with double-quotes in pMessage
  debugMsgProcAll(pProcName, ReplaceString(pMessage, "'", #DQUOTE$), gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsg2(pProcName, pMessage, pResult)
  ; regular debug messages that also displays the value returned by a function, usually the return value from a BASS function call
  ; the 'log group' ~2 enables these lines to be easily extracted from the log file by doing a search for ~2, so typically can be used to find the BASS calls.
  ; however, more recently I've been extract BASS function calls by searching for ': BASS'
  debugMsgProcAll2(pProcName, pMessage, pResult, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsg3(pProcName, pMessage)
  ; as debugMsg() but with ~2 as the log group - see debugMsg2() for more info on this log group
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro logMsg(pProcName, pMessage)
  logKeyEventProc(pProcName, pMessage, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgC(pProcName, pMessage)
  ; conditional debug message
  If bTrace
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro debugMsgC0(pProcName, pMessage)
  ; debug messages that ALSO issue call the PB Debug statement so that message also appears in the debugger
  If bTrace
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line, #False, #True)
  EndIf
EndMacro

Macro debugMsgC2(pProcName, pMessage, pResult)
  ; conditional debug message for log group ~2, that also displays the value returned by a function, usually the return value from a BASS function call
  ; see debugMsg2() for more info
  If bTrace
    debugMsgProcAll2(pProcName, pMessage, pResult, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro debugMsgC3(pProcName, pMessage)
  ; conditional debug message for log group ~2
  If bTrace
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro debugMsg_S(pProcName, pMessage)
  ; debug message for tracing sync proc's, eg when a loop sync point is reached
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsg2_S(pProcName, pMessage, pResult)
  ; debug message for log group ~2 for tracing sync proc's, eg when a loop sync point is reached, that also displays the value returned by a function, usually the return value from a BASS function call
  debugMsgProcAll2(pProcName, pMessage, pResult, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsg3_S(pProcName, pMessage)
  ; debug message for log group ~2 for tracing sync proc's, eg when a loop sync point is reached
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~2", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgAS(pProcName, pMessage)
  CompilerIf #cTraceAuthString
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~A", #PB_Compiler_Filename, #PB_Compiler_Line)
    Debug pProcName + ": " + pMessage
  CompilerEndIf
EndMacro

Macro debugMsg_AWF(pProcName, pMessage)
  ; debug messages for 'analyze wav file'
  CompilerIf #cTraceAnalyzeWavFile
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
  CompilerEndIf
EndMacro

Macro debugMsgC_AWF(pProcName, pMessage)
  ; conditional debug messages for 'analyze wav file'
  CompilerIf #cTraceAnalyzeWavFile
    If bTrace
      debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~1", #PB_Compiler_Filename, #PB_Compiler_Line)
    EndIf
  CompilerEndIf
EndMacro

Macro debugMsgSMS(pProcName, pMessage)
  ; debug messages for SoundMan-Server processing
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~S", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgV(pProcName, pMessage)
  ; debug messages for video/image display
  CompilerIf #cTraceVidPicDisplay
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~V", #PB_Compiler_Filename, #PB_Compiler_Line)
  CompilerEndIf
EndMacro

Macro debugMsgD(pProcName, pMessage)
  ; debug messages for image drawing excluding detailed alpha-drawing drawing
  CompilerIf #cTraceVidPicDrawing
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~D", #PB_Compiler_Filename, #PB_Compiler_Line)
  CompilerEndIf
EndMacro

Macro debugMsgDA(pProcName, pMessage)
  ; debug messages for image drawing including the alpha-blend drawing
  CompilerIf #cTraceVidPicDrawingAlphaBlend
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~D", #PB_Compiler_Filename, #PB_Compiler_Line)
  CompilerEndIf
EndMacro

Macro debugMsgT(pProcName, pMessage)
  ; debug messages for TVG (TVideoGrabber) processing
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~T", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgT2(pProcName, pMessage, pResult)
  ; debug messages for TVG (TVideoGrabber) function calls, that also displays the value returned by a function
  debugMsgProcAll2(pProcName, pMessage, pResult, gsThreadNo, " ~T", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro debugMsgN(pProcName, pMessage)
  ; conditional debug messages for network processing
  If bHideTracing = #False
    debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~N", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro debugMsgN2(pProcName, pMessage, pResult)
  ; conditional debug messages for network function calls, that also displays the value returned by a function
  If bHideTracing = #False
    debugMsgProcAll2(pProcName, pMessage, pResult, gsThreadNo, " ~N", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro debugMsgR(pProcName, pMessage)
  ; debug messages for messages sent to or received from the remote app (RAI - Remote App Interface)
  debugMsgProcAll(pProcName, pMessage, gsThreadNo, " ~R", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro logListEvent(pProcName, pMessage, bHoldLineIfNotOpen=#False)
  logListEventProc(pProcName, pMessage, gsThreadNo, bHoldLineIfNotOpen)
EndMacro

Macro logKeyEvent(pMessage)
  ; writes a 'Key Event' entry to the log file, using ~K as the log group. Key events can thus be easily extracted from the log file.
  logKeyEventProc(sProcName, pMessage, " ~K", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro logKeyEvent2(pMessage, pResult)
  ; as logKeyEvent (above) but also displays the value returned by a function
  logKeyEventProc(sProcName, pMessage + " returned " + pResult, " ~K", #PB_Compiler_Filename, #PB_Compiler_Line)
EndMacro

Macro logProcessorEvent(pMessage)
  ; writes a 'Key Event' entry to the log file, using ~P as the log group. Key events can thus be easily extracted from the log file.
  If gbLogProcessorEvents
    logKeyEventProc(sProcName, pMessage, " ~U", #PB_Compiler_Filename, #PB_Compiler_Line)
  EndIf
EndMacro

Macro newHandle(nHandleType, nHandle, bTrace=#False, sExtraInfo="")
  ; Creates a descriptive handle from a BASS, TVG or other handle.
  ; For example, BASS_StreamCreateFile() may return a number like 3028747 but newHandleProc() can generate a descriptive handle like source#5, which is much more helpful when analyzing log files.
  ; See also procedure decodeHandle().
  newHandleProc(nHandleType, nHandle, sProcName, bTrace, sExtraInfo)
EndMacro

Macro freeHandle(nHandle)
  ; use this when a BASS, TVG or other handle (eg stream) is freed, so that the descriptive name, such as source#5 is also freed and removed from the array
  freeHandleProc(nHandle, sProcName)
EndMacro

Macro lockAllMixerStreams(bLock, bForce=#False, bTrace=#False)
  lockAllMixerStreamsProc(sProcName, bLock, bForce, bTrace)
EndMacro

Macro ASSERT_THREAD(pReqdThreadNo)
  ; Use to ensure a function is being called from an appropriate thread.
  ; Usually used for any activity that creates, resizes or move screen objects as these must happen in the main thread (#SCS_THREAD_MAIN).
  ; Throws a run-time error if the thread assertion fails, so hopefully this will always be caught and fixed during testing.
  THR_assertThreadProc(pReqdThreadNo, #PB_Compiler_Procedure + "@" + #PB_Compiler_Line)
EndMacro

Macro COND_OPEN_PREFS(pPrefGroup)
  bPrefsOpenAtStart = gbPreferencesOpen
  sPrefGroupAtStart = gsPrefenceGroup
  If gbPreferencesOpen = #False
    If OpenPreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator) = 0
      CreatePreferences(gsAppDataPath + #SCS_PREFS_FILE, #PB_Preference_GroupSeparator)
    EndIf
    gbPreferencesOpen = #True
    ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  EndIf
  PreferenceGroup(pPrefGroup)
  gsPrefenceGroup = pPrefGroup
EndMacro

Macro COND_CLOSE_PREFS()
  If bPrefsOpenAtStart = #False
    ClosePreferences()
    gbPreferencesOpen = #False
    ; debugMsg(sProcName, "gbPreferencesOpen=" + strB(gbPreferencesOpen))
  ElseIf Len(sPrefGroupAtStart) > 0
    PreferenceGroup(sPrefGroupAtStart)
    gsPrefenceGroup = sPrefGroupAtStart
  EndIf
EndMacro

Macro OPEN_PREF_GROUP(pPrefGroup)
  PreferenceGroup(pPrefGroup)
  gsPrefenceGroup = pPrefGroup
EndMacro

Macro VBStrFromAnsiPtr(lpStr)
  PeekS(lpStr, -1, #PB_Ascii)
EndMacro

Macro REDIM_ARRAY(pArray, pNewSize, pDefault, sArrayName)
  gnRedimIndex = ArraySize(pArray())
  ReDim pArray(pNewSize)
  If ArraySize(pArray()) < 0
    debugMsg(sProcName, "Out of bounds in function: " + #PB_Compiler_Procedure + " at line " + Str(#PB_Compiler_Line) + " in file " + #PB_Compiler_File) 
    setGlobalError(#SCS_ERROR_ARRAY_SIZE_INVALID, pNewSize, ArraySize(pArray()), sArrayName, sProcName)
    scsRaiseError()
  Else
    While gnRedimIndex < pNewSize
      gnRedimIndex + 1
      pArray(gnRedimIndex) = pDefault
    Wend
  EndIf
EndMacro

Macro REDIM_ARRAY2(pArray, pNewSize, pDefault)
  gnRedimIndex = ArraySize(pArray())
  If pNewSize > gnRedimIndex
    ReDim pArray(pNewSize)
    While gnRedimIndex < pNewSize
      gnRedimIndex + 1
      pArray(gnRedimIndex) = pDefault
    Wend
  EndIf
EndMacro

Macro INIT_ARRAY(pArray, pDefault)
  For n = 0 To ArraySize(pArray())
    pArray(n) = pDefault
  Next n
EndMacro

Macro CanvasMX(Canvas)
  GetGadgetAttribute(Canvas, #PB_Canvas_MouseX)  
EndMacro

Macro CanvasMY(Canvas)
  GetGadgetAttribute(Canvas, #PB_Canvas_MouseY)  
EndMacro

Macro CanvasKey(Canvas)
  GetGadgetAttribute(Canvas, #PB_Canvas_Key)  
EndMacro

Macro MustBeEntered(lblGadget)
  LangPars("Errors", "MustBeEntered", GetGadgetText(lblGadget))
EndMacro

Macro MustBeSelected(lblGadget)
  LangPars("Errors", "MustBeSelected", GetGadgetText(lblGadget))
EndMacro

Macro scsLockMutex(hMutexHandle, nMutexNo, nLockNo)
  CompilerIf #c_lockmutex_monitoring
    gaTryLockInfo(nMutexNo)\qTryLockStartTime = ElapsedMilliseconds() ; nb gqTryLockStartTime, gqTryLockLogInfoTime, gqTryLockTimeNow and gbTryLockDetailLogged are Threaded variables so are unique for each thread
    gaTryLockInfo(nMutexNo)\qTryLockLogInfoTime = gaTryLockInfo(nMutexNo)\qTryLockStartTime
    gaTryLockInfo(nMutexNo)\bTryLockDetailLogged = #False
    While #True
      If TryLockMutex(hMutexHandle)
        gaTryLockInfo(nMutexNo)\qTryLockSuccessfulTime = ElapsedMilliseconds()
        gaTryLockInfo(nMutexNo)\nTryLockSuccessfulLockNo = nLockNo
        If gaTryLockInfo(nMutexNo)\bTryLockDetailLogged
          debugMsg(sProcName, "scsLockMutex(" + hMutexHandle + ", " + decodeMutex(nMutexNo) + ", " + nLockNo + ") lock successful after " +
                              Str(gaTryLockInfo(nMutexNo)\qTryLockSuccessfulTime - gaTryLockInfo(nMutexNo)\qTryLockStartTime) + "ms")
        EndIf
        ; Added 2Aug2020 11.8.3.2ap
        ; Note: Array gaTryLockInfo() is threaded, but array gaSuccessfulLockInfo() is NOT threaded, so is common to all threads.
        ; This can therefore be used to easily determine which thread last successfully locked this mutex.
        gaSuccessfulLockInfo(nMutexNo)\qMutexLockTime = ElapsedMilliseconds()
        gaSuccessfulLockInfo(nMutexNo)\nMutexLockNo = nLockNo
        gaSuccessfulLockInfo(nMutexNo)\nMutexLockThread = gnThreadNo
        ; End added 2Aug2020 11.8.3.2ap
        Break
      Else
        gaTryLockInfo(nMutexNo)\qTryLockTimeNow = ElapsedMilliseconds()
        If (gaTryLockInfo(nMutexNo)\qTryLockTimeNow - gaTryLockInfo(nMutexNo)\qTryLockLogInfoTime) > 1000
          ; log info once a second until lock successful
          debugMsg(sProcName, "scsLockMutex(" + hMutexHandle + ", " + decodeMutex(nMutexNo) + ", " + nLockNo + ") waiting " +
                              Str(gaTryLockInfo(nMutexNo)\qTryLockTimeNow - gaTryLockInfo(nMutexNo)\qTryLockStartTime) + "ms" +
                              ", \qTryLockStartTime=" + traceTime(gaTryLockInfo(nMutexNo)\qTryLockStartTime) +
                              ", \qTryLockLogInfoTime=" + traceTime(gaTryLockInfo(nMutexNo)\qTryLockLogInfoTime) +
                              ", (prev) gaSuccessfulLockInfo(" + decodeMutex(nMutexNo) + ")\qMutexLockTime=" + traceTime(gaSuccessfulLockInfo(nMutexNo)\qMutexLockTime) +
                              ", (prev) \nMutexLockNo=" + gaSuccessfulLockInfo(nMutexNo)\nMutexLockNo +
                              ", (prev) \nMutexLockThread=" + THR_decodeThread(gaSuccessfulLockInfo(nMutexNo)\nMutexLockThread))
          ;                                 ", (prev)\qTryLockSuccessfulTime=" + traceTime(gaTryLockInfo(nMutexNo)\qTryLockSuccessfulTime) +
          ;                                 ", (prev)\nTryLockSuccessfulLockNo=" + gaTryLockInfo(nMutexNo)\nTryLockSuccessfulLockNo)
          gaTryLockInfo(nMutexNo)\sTryLockExtraInfo1 = "... gnLabelOther=" + gnLabelOther + ", gnLabelThread=#" + gnLabelThread + ", gnLabel=" + gnLabel + ", gnLabelSAM=" + gnLabelSAM +
                                                       ", gnLabelUpdDispPanels=" + gnLabelUpdDispPanels + ", gnLabelUpdDispPanel=" + gnLabelUpdDispPanel + ", gnLabelReposAuds=" + gnLabelReposAuds +
                                                       ", gnLabelSlider=" + gnLabelSlider + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnMainThreadLabel=" + gnMainThreadLabel
          If gaTryLockInfo(nMutexNo)\bTryLockDetailLogged = #False Or gaTryLockInfo(nMutexNo)\sTryLockExtraInfo1 <> gaTryLockInfo(nMutexNo)\sTryLockExtraInfo2
            ; extra info logged (if necessary) only once per call to scsLockMutex()
            debugMsg(sProcName, gaTryLockInfo(nMutexNo)\sTryLockExtraInfo1)
            gaTryLockInfo(nMutexNo)\sTryLockExtraInfo2 = gaTryLockInfo(nMutexNo)\sTryLockExtraInfo1
            If gaTryLockInfo(nMutexNo)\bTryLockDetailLogged = #False
              Select nMutexNo
                Case #SCS_MUTEX_CUE_LIST
                  If gnCueListMutexLockThread > 0
                    debugMsg(sProcName, "... gnCueListMutexLockThread=#" + gnCueListMutexLockThread +", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime))
                    debugMsg(sProcName, "... gqSamProcessLastStarted=" + traceTime(gqSamProcessLastStarted) + ", gqSamProcessLastEnded=" + traceTime(gqSamProcessLastEnded) +
                                        ", gnSamLastRequestProcessed=" + gnSamLastRequestProcessed + ", gqSamTimeLastRequestStarted=" + traceTime(gqSamTimeLastRequestStarted) + ", gqSamTimeLastRequestEnded=" + traceTime(gqSamTimeLastRequestEnded) +
                                        ", gnSamRequestsProcessed=" + gnSamRequestsProcessed)
                  EndIf
              EndSelect
              gaTryLockInfo(nMutexNo)\bTryLockDetailLogged = #True
            EndIf
          EndIf
          gaTryLockInfo(nMutexNo)\qTryLockLogInfoTime = gaTryLockInfo(nMutexNo)\qTryLockTimeNow ; moved 30Jan2020 11.8.2.2ae (was previously incorrectly after the following EndIf which meant that the If test for a time difference of more than one second was never successful)
        EndIf
        Delay(10)
      EndIf
    Wend
  CompilerElse
    LockMutex(hMutexHandle)
  CompilerEndIf
  bLockedMutex = #True
EndMacro

Macro scsTryLockMutex(hMutexHandle, nMutexNo, nLockNo)
  If TryLockMutex(hMutexHandle)
    bLockedMutex = #True
  Else
    bLockedMutex = #False
  EndIf
EndMacro

Macro scsUnlockMutex(hMutexHandle, nMutexNo)
  UnlockMutex(hMutexHandle)
  bLockedMutex = #False
EndMacro

Macro LockCueListMutex(nLockNo)
  If gnCueListMutexLockThread <> gnThreadNo
    If gnTraceMutexLocking > 0
      If gnCueListMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), nLockNo=" + nLockNo + ", gnCueListMutexLockThread=" + gnCueListMutexLockThread +
                             ", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) +
                             ", gnLabel=" + gnLabel + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnLabelSAM=" + gnLabelSAM +
                             ", gnMainThreadLabel=" + gnMainThreadLabel)
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
EndMacro

Macro TryLockCueListMutex(nLockNo)
  If gnCueListMutexLockThread <> gnThreadNo
    bLockReqd = #True
    If gnTraceMutexLocking > 0
      If gnCueListMutexLockThread > 0 Or 1=1
        debugMsg3(sProcName, "calling TryLockMutex(gnCueListMutex), nLockNo=" + nLockNo + ", gnCueListMutexLockThread=" + gnCueListMutexLockThread +
                             ", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) +
                             ", gnLabel=" + gnLabel + ", gnLabelStatusCheck=" + gnLabelStatusCheck + ", gnLabelSAM=" + gnLabelSAM +
                             ", gnMainThreadLabel=" + gnMainThreadLabel)
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnCueListMutex), nLockNo=" + nLockNo + ", gnCueListMutexLockThread=" + gnCueListMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnCueListMutex, #SCS_MUTEX_CUE_LIST, nLockNo)
    If bLockedMutex
      If gnTraceMutexLocking > 0
        debugMsg3(sProcName, "gnCueListMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnCueListMutexLockThread = gnThreadNo
      gnCueListMutexLockNo = nLockNo
      gqCueListMutexLockTime = ElapsedMilliseconds()
    Else
      If gnTraceMutexLocking > 0
        debugMsg3(sProcName, "TryLockMutex(gnCueListMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockCueListMutex()
  If bLockedMutex
    gqCueListLockDuration = ElapsedMilliseconds() - gqCueListMutexLockTime
    If gqCueListLockDuration > 500 Or gnTraceMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnCueListMutex), duration of lock " + gnCueListMutexLockNo + ": " + gqCueListLockDuration + "ms")
    EndIf
    gnCueListMutexLockThread = 0
    scsUnlockMutex(gnCueListMutex, #SCS_MUTEX_CUE_LIST)
  EndIf
EndMacro

Macro LockSMSNetworkMutex(nLockNo)
  If gnSMSNetworkMutexLockThread <> gnThreadNo
    If gnTraceSMSMutexLocking > 0
      If gnSMSNetworkMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnSMSNetworkMutex), nLockNo=" + nLockNo + ", gnSMSNetworkMutexLockThread=" + gnSMSNetworkMutexLockThread +
                             ", gnSMSNetworkMutexLockNo=" + gnSMSNetworkMutexLockNo + ", gqSMSNetworkMutexLockTime=" + traceTime(gqSMSNetworkMutexLockTime))
      Else
        debugMsg3(sProcName, "calling LockMutex(gnSMSNetworkMutex), nLockNo=" + nLockNo + ", gnSMSNetworkMutexLockThread=" + gnSMSNetworkMutexLockThread)
      EndIf
    EndIf
    scsLockMutex(gnSMSNetworkMutex, #SCS_MUTEX_SMS_NETWORK, nLockNo)
    If gnTraceSMSMutexLocking > 0
      debugMsg3(sProcName, "gnSMSNetworkMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnSMSNetworkMutexLockThread = gnThreadNo
    gnSMSNetworkMutexLockNo = nLockNo
    gqSMSNetworkMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockSMSNetworkMutex(nLockNo)
  If gnSMSNetworkMutexLockThread <> gnThreadNo
    bLockReqd = #True
    If gnTraceSMSMutexLocking > 0
      If gnSMSNetworkMutexLockThread > 0
        debugMsg3(sProcName, "calling TryLockMutex(gnSMSNetworkMutex), nLockNo=" + nLockNo + ", gnSMSNetworkMutexLockThread=" + gnSMSNetworkMutexLockThread +
                             ", gnSMSNetworkMutexLockNo=" + gnSMSNetworkMutexLockNo + ", gqSMSNetworkMutexLockTime=" + traceTime(gqSMSNetworkMutexLockTime))
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnSMSNetworkMutex), nLockNo=" + nLockNo + ", gnSMSNetworkMutexLockThread=" + gnSMSNetworkMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnSMSNetworkMutex, #SCS_MUTEX_SMS_NETWORK, nLockNo)
    If bLockedMutex
      If gnTraceSMSMutexLocking > 0
        debugMsg3(sProcName, "gnSMSNetworkMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnSMSNetworkMutexLockThread = gnThreadNo
      gnSMSNetworkMutexLockNo = nLockNo
      gqSMSNetworkMutexLockTime = ElapsedMilliseconds()
    Else
      If gnTraceSMSMutexLocking > 0
        debugMsg3(sProcName, "TryLockMutex(gnSMSNetworkMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockSMSNetworkMutex()
  If bLockedMutex
    If gnTraceSMSMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnSMSNetworkMutex), duration of lock: " + Str(ElapsedMilliseconds() - gqSMSNetworkMutexLockTime) + "ms")
    EndIf
    gnSMSNetworkMutexLockThread = 0
    scsUnlockMutex(gnSMSNetworkMutex, #SCS_MUTEX_SMS_NETWORK)
  EndIf
EndMacro

Macro LockMTCSendMutex(nLockNo, bTrace)
  If gnMTCSendMutexLockThread <> gnThreadNo And gnMTCSendMutex <> 0
    If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
      If gnMTCSendMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnMTCSendMutex), nLockNo=" + nLockNo + ", gnMTCSendMutexLockThread=" + gnMTCSendMutexLockThread +
                             ", gnMTCSendMutexLockNo=" + gnMTCSendMutexLockNo + ", gqMTCSendMutexLockTime=" + traceTime(gqMTCSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling LockMutex(gnMTCSendMutex), nLockNo=" + nLockNo + ", gnMTCSendMutexLockThread=" + gnMTCSendMutexLockThread)
      EndIf
    EndIf
    scsLockMutex(gnMTCSendMutex, #SCS_MUTEX_MTC_SEND, nLockNo)
    If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
      debugMsg3(sProcName, "gnMTCSendMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnMTCSendMutexLockThread = gnThreadNo
    gnMTCSendMutexLockNo = nLockNo
    gqMTCSendMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockMTCSendMutex(nLockNo, bTrace)
  If gnMTCSendMutexLockThread <> gnThreadNo And gnMTCSendMutex <> 0
    bLockReqd = #True
    If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
      If gnMTCSendMutexLockThread > 0
        debugMsg3(sProcName, "calling TryLockMutex(gnMTCSendMutex), nLockNo=" + nLockNo + ", gnMTCSendMutexLockThread=" + gnMTCSendMutexLockThread +
                             ", gnMTCSendMutexLockNo=" + gnMTCSendMutexLockNo + ", gqMTCSendMutexLockTime=" + traceTime(gqMTCSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnMTCSendMutex), nLockNo=" + nLockNo + ", gnMTCSendMutexLockThread=" + gnMTCSendMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnMTCSendMutex, #SCS_MUTEX_MTC_SEND, nLockNo)
    If bLockedMutex
      If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
        debugMsg3(sProcName, "gnMTCSendMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnMTCSendMutexLockThread = gnThreadNo
      gnMTCSendMutexLockNo = nLockNo
      gqMTCSendMutexLockTime = ElapsedMilliseconds()
    Else
      If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
        debugMsg3(sProcName, "TryLockMutex(gnMTCSendMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockMTCSendMutex(bTrace)
  If bLockedMutex And gnMTCSendMutex <> 0
    If (gnTraceMTCSendMutexLocking > 0) And (bTrace)
      debugMsg3(sProcName, "calling UnlockMutex(gnMTCSendMutex), duration of lock: " + Str(ElapsedMilliseconds() - gqMTCSendMutexLockTime) + "ms")
    EndIf
    gnMTCSendMutexLockThread = 0
    scsUnlockMutex(gnMTCSendMutex, #SCS_MUTEX_MTC_SEND)
  EndIf
EndMacro

Macro LockDMXSendMutex(nLockNo)
  If gnDMXSendMutexLockThread <> gnThreadNo
    If gnTraceDMXSendMutexLocking > 0
      If gnDMXSendMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnDMXSendMutex), nLockNo=" + nLockNo + ", gnDMXSendMutexLockThread=" + gnDMXSendMutexLockThread +
                             ", gnDMXSendMutexLockNo=" + gnDMXSendMutexLockNo + ", gqDMXSendMutexLockTime=" + traceTime(gqDMXSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling LockMutex(gnDMXSendMutex), nLockNo=" + nLockNo + ", gnDMXSendMutexLockThread=" + gnDMXSendMutexLockThread)
      EndIf
    EndIf
    scsLockMutex(gnDMXSendMutex, #SCS_MUTEX_DMX_SEND, nLockNo)
    If gnTraceDMXSendMutexLocking > 0
      debugMsg3(sProcName, "gnDMXSendMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnDMXSendMutexLockThread = gnThreadNo
    gnDMXSendMutexLockNo = nLockNo
    gqDMXSendMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockDMXSendMutex(nLockNo)
  If gnDMXSendMutexLockThread <> gnThreadNo
    bLockReqd = #True
    If gnTraceDMXSendMutexLocking > 0
      If gnDMXSendMutexLockThread > 0
        debugMsg3(sProcName, "calling TryLockMutex(gnDMXSendMutex), nLockNo=" + nLockNo + ", gnDMXSendMutexLockThread=" + gnDMXSendMutexLockThread +
                             ", gnDMXSendMutexLockNo=" + gnDMXSendMutexLockNo + ", gqDMXSendMutexLockTime=" + traceTime(gqDMXSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnDMXSendMutex), nLockNo=" + nLockNo + ", gnDMXSendMutexLockThread=" + gnDMXSendMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnDMXSendMutex, #SCS_MUTEX_DMX_SEND, nLockNo)
    If bLockedMutex
      If gnTraceDMXSendMutexLocking > 0
        debugMsg3(sProcName, "gnDMXSendMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnDMXSendMutexLockThread = gnThreadNo
      gnDMXSendMutexLockNo = nLockNo
      gqDMXSendMutexLockTime = ElapsedMilliseconds()
    Else
      If gnTraceDMXSendMutexLocking > 0
        debugMsg3(sProcName, "TryLockMutex(gnDMXSendMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockDMXSendMutex()
  If bLockedMutex
    If gnTraceDMXSendMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnDMXSendMutex), duration of lock: " + Str(ElapsedMilliseconds() - gqDMXSendMutexLockTime) + "ms")
    EndIf
    gnDMXSendMutexLockThread = 0
    scsUnlockMutex(gnDMXSendMutex, #SCS_MUTEX_DMX_SEND)
  EndIf
EndMacro

Macro LockDMXReceiveMutex(nLockNo)
  If gnDMXReceiveMutexLockThread <> gnThreadNo
    If gnTraceDMXReceiveMutexLocking > 0
      If gnDMXReceiveMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnDMXReceiveMutex), nLockNo=" + nLockNo + ", gnDMXReceiveMutexLockThread=" + gnDMXReceiveMutexLockThread +
                             ", gnDMXReceiveMutexLockNo=" + gnDMXReceiveMutexLockNo + ", gqDMXReceiveMutexLockTime=" + traceTime(gqDMXReceiveMutexLockTime))
      Else
        debugMsg3(sProcName, "calling LockMutex(gnDMXReceiveMutex), nLockNo=" + nLockNo + ", gnDMXReceiveMutexLockThread=" + gnDMXReceiveMutexLockThread)
      EndIf
    EndIf
    scsLockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE, nLockNo)
    If gnTraceDMXReceiveMutexLocking > 0
      debugMsg3(sProcName, "gnDMXReceiveMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnDMXReceiveMutexLockThread = gnThreadNo
    gnDMXReceiveMutexLockNo = nLockNo
    gqDMXReceiveMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockDMXReceiveMutex(nLockNo)
  If gnDMXReceiveMutexLockThread <> gnThreadNo
    bLockReqd = #True
    If gnTraceDMXReceiveMutexLocking > 0
      If gnDMXReceiveMutexLockThread > 0
        debugMsg3(sProcName, "calling TryLockMutex(gnDMXReceiveMutex), nLockNo=" + nLockNo + ", gnDMXReceiveMutexLockThread=" + gnDMXReceiveMutexLockThread +
                             ", gnDMXReceiveMutexLockNo=" + gnDMXReceiveMutexLockNo + ", gqDMXReceiveMutexLockTime=" + traceTime(gqDMXReceiveMutexLockTime))
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnDMXReceiveMutex), nLockNo=" + nLockNo + ", gnDMXReceiveMutexLockThread=" + gnDMXReceiveMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE, nLockNo)
    If bLockedMutex
      If gnTraceDMXReceiveMutexLocking > 0
        debugMsg3(sProcName, "gnDMXReceiveMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnDMXReceiveMutexLockThread = gnThreadNo
      gnDMXReceiveMutexLockNo = nLockNo
      gqDMXReceiveMutexLockTime = ElapsedMilliseconds()
    Else
      If gnTraceDMXReceiveMutexLocking > 0
        debugMsg3(sProcName, "TryLockMutex(gnDMXReceiveMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockDMXReceiveMutex()
  If bLockedMutex
    If gnTraceDMXReceiveMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnDMXReceiveMutex), duration of lock: " + Str(ElapsedMilliseconds() - gqDMXReceiveMutexLockTime) + "ms")
    EndIf
    gnDMXReceiveMutexLockThread = 0
    scsUnlockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE)
  EndIf
EndMacro

Macro LockHTTPSendMutex(nLockNo)
  If gnHTTPSendMutexLockThread <> gnThreadNo
    If gnTraceHTTPSendMutexLocking > 0
      If gnHTTPSendMutexLockThread > 0
        debugMsg3(sProcName, "calling LockMutex(gnHTTPSendMutex), nLockNo=" + nLockNo + ", gnHTTPSendMutexLockThread=" + gnHTTPSendMutexLockThread +
                             ", gnHTTPSendMutexLockNo=" + gnHTTPSendMutexLockNo + ", gqHTTPSendMutexLockTime=" + traceTime(gqHTTPSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling LockMutex(gnHTTPSendMutex), nLockNo=" + nLockNo + ", gnHTTPSendMutexLockThread=" + gnHTTPSendMutexLockThread)
      EndIf
    EndIf
    scsLockMutex(gnHTTPSendMutex, #SCS_MUTEX_HTTP_SEND, nLockNo)
    If gnTraceHTTPSendMutexLocking > 0
      debugMsg3(sProcName, "gnHTTPSendMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnHTTPSendMutexLockThread = gnThreadNo
    gnHTTPSendMutexLockNo = nLockNo
    gqHTTPSendMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockHTTPSendMutex(nLockNo)
  If gnHTTPSendMutexLockThread <> gnThreadNo
    bLockReqd = #True
    If gnTraceHTTPSendMutexLocking > 0
      If gnHTTPSendMutexLockThread > 0
        debugMsg3(sProcName, "calling TryLockMutex(gnHTTPSendMutex), nLockNo=" + nLockNo + ", gnHTTPSendMutexLockThread=" + gnHTTPSendMutexLockThread +
                             ", gnHTTPSendMutexLockNo=" + gnHTTPSendMutexLockNo + ", gqHTTPSendMutexLockTime=" + traceTime(gqHTTPSendMutexLockTime))
      Else
        debugMsg3(sProcName, "calling TryLockMutex(gnHTTPSendMutex), nLockNo=" + nLockNo + ", gnHTTPSendMutexLockThread=" + gnHTTPSendMutexLockThread)
      EndIf
    EndIf
    scsTryLockMutex(gnHTTPSendMutex, #SCS_MUTEX_HTTP_SEND, nLockNo)
    If bLockedMutex
      If gnTraceHTTPSendMutexLocking > 0
        debugMsg3(sProcName, "gnHTTPSendMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnHTTPSendMutexLockThread = gnThreadNo
      gnHTTPSendMutexLockNo = nLockNo
      gqHTTPSendMutexLockTime = ElapsedMilliseconds()
    Else
      If gnTraceHTTPSendMutexLocking > 0
        debugMsg3(sProcName, "TryLockMutex(gnHTTPSendMutex) failed")
      EndIf
    EndIf
  EndIf
EndMacro

Macro UnlockHTTPSendMutex()
  If bLockedMutex
    If gnTraceHTTPSendMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnHTTPSendMutex), duration of lock: " + Str(ElapsedMilliseconds() - gqHTTPSendMutexLockTime) + "ms")
    EndIf
    gnHTTPSendMutexLockThread = 0
    scsUnlockMutex(gnHTTPSendMutex, #SCS_MUTEX_HTTP_SEND)
  EndIf
EndMacro

Macro LockImageMutex(nLockNo)
  If gnImageMutexLockThread <> gnThreadNo
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "calling LockMutex(gnImageMutex), nLockNo=" + nLockNo)
    EndIf
    scsLockMutex(gnImageMutex, #SCS_MUTEX_IMAGE, nLockNo)
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "gnImageMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnImageMutexLockThread = gnThreadNo
    gnImageMutexLockNo = nLockNo
    gqImageMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockImageMutex(nLockNo)
  If gnImageMutexLockThread <> gnThreadNo
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "calling TryLockMutex(gnImageMutex), nLockNo=" + nLockNo)
    EndIf
    scsTryLockMutex(gnImageMutex, #SCS_MUTEX_IMAGE, nLockNo)
    If bLockedMutex
      If gnTraceMutexLocking > 0
        debugMsg3(sProcName, "gnImageMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnImageMutexLockThread = gnThreadNo
      gnImageMutexLockNo = nLockNo
      gqImageMutexLockTime = ElapsedMilliseconds()
    EndIf
  EndIf
EndMacro

Macro UnlockImageMutex()
  If bLockedMutex
    gnImageMutexLockThread = 0
    scsUnlockMutex(gnImageMutex, #SCS_MUTEX_IMAGE)
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "called UnlockMutex(gnImageMutex)")
    EndIf
  EndIf
EndMacro

Macro LockTempDatabaseMutex(nLockNo)
  If gnTempDatabaseMutexLockThread <> gnThreadNo
    If gnTraceTempDatabaseMutexLocking > 0
      debugMsg3(sProcName, "calling LockMutex(gnTempDatabaseMutex), nLockNo=" + nLockNo)
    EndIf
    scsLockMutex(gnTempDatabaseMutex, #SCS_MUTEX_TEMP_DATABASE, nLockNo)
    If gnTraceTempDatabaseMutexLocking > 0
      debugMsg3(sProcName, "gnTempDatabaseMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnTempDatabaseMutexLockThread = gnThreadNo
    gnTempDatabaseMutexLockNo = nLockNo
    gqTempDatabaseMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockTempDatabaseMutex(nLockNo)
  If gnTempDatabaseMutexLockThread <> gnThreadNo
    If gnTraceTempDatabaseMutexLocking > 0
      debugMsg3(sProcName, "calling TryLockMutex(gnTempDatabaseMutex), nLockNo=" + nLockNo)
    EndIf
    scsTryLockMutex(gnTempDatabaseMutex, #SCS_MUTEX_TEMP_DATABASE, nLockNo)
    If bLockedMutex
      If gnTraceTempDatabaseMutexLocking > 0
        debugMsg3(sProcName, "gnTempDatabaseMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnTempDatabaseMutexLockThread = gnThreadNo
      gnTempDatabaseMutexLockNo = nLockNo
      gqTempDatabaseMutexLockTime = ElapsedMilliseconds()
    EndIf
  EndIf
EndMacro

Macro UnlockTempDatabaseMutex()
  If bLockedMutex
    gnTempDatabaseMutexLockThread = 0
    If gnTraceTempDatabaseMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnTempDatabaseMutex), gnTempDatabaseMutexLockNo=" + gnTempDatabaseMutexLockNo)
    EndIf
    scsUnlockMutex(gnTempDatabaseMutex, #SCS_MUTEX_TEMP_DATABASE)
  EndIf
EndMacro

Macro LockLoadSamplesMutex(nLockNo)
  If gnLoadSamplesMutexLockThread <> gnThreadNo
    If gnTraceLoadSamplesMutexLocking > 0
      debugMsg3(sProcName, "calling LockMutex(gnLoadSamplesMutex), nLockNo=" + nLockNo)
    EndIf
    scsLockMutex(gnLoadSamplesMutex, #SCS_MUTEX_TEMP_DATABASE, nLockNo)
    If gnTraceLoadSamplesMutexLocking > 0
      debugMsg3(sProcName, "gnLoadSamplesMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnLoadSamplesMutexLockThread = gnThreadNo
    gnLoadSamplesMutexLockNo = nLockNo
    gqLoadSamplesMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockLoadSamplesMutex(nLockNo)
  If gnLoadSamplesMutexLockThread <> gnThreadNo
    If gnTraceLoadSamplesMutexLocking > 0
      debugMsg3(sProcName, "calling TryLockMutex(gnLoadSamplesMutex), nLockNo=" + nLockNo)
    EndIf
    scsTryLockMutex(gnLoadSamplesMutex, #SCS_MUTEX_TEMP_DATABASE, nLockNo)
    If bLockedMutex
      If gnTraceLoadSamplesMutexLocking > 0
        debugMsg3(sProcName, "gnLoadSamplesMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnLoadSamplesMutexLockThread = gnThreadNo
      gnLoadSamplesMutexLockNo = nLockNo
      gqLoadSamplesMutexLockTime = ElapsedMilliseconds()
    EndIf
  EndIf
EndMacro

Macro UnlockLoadSamplesMutex()
  If bLockedMutex
    gnLoadSamplesMutexLockThread = 0
    If gnTraceLoadSamplesMutexLocking > 0
      debugMsg3(sProcName, "calling UnlockMutex(gnLoadSamplesMutex), gnLoadSamplesMutexLockNo=" + gnLoadSamplesMutexLockNo)
    EndIf
    scsUnlockMutex(gnLoadSamplesMutex, #SCS_MUTEX_TEMP_DATABASE)
  EndIf
EndMacro

Macro LockTimeLineMutex(nLockNo)
  If gnTimeLineMutexLockThread <> gnThreadNo
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "calling LockMutex(gnTimeLineMutex), nLockNo=" + nLockNo)
    EndIf
    scsLockMutex(gnTimeLineMutex, #SCS_MUTEX_TIMELINE, nLockNo)
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "gnTimeLineMutex locked, nLockNo=" + nLockNo)
    EndIf
    gnTimeLineMutexLockThread = gnThreadNo
    gnTimeLineMutexLockNo = nLockNo
    gqTimeLineMutexLockTime = ElapsedMilliseconds()
  EndIf
EndMacro

Macro TryLockTimeLineMutex(nLockNo)
  If gnTimeLineMutexLockThread <> gnThreadNo
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "calling TryLockMutex(gnTimeLineMutex), nLockNo=" + nLockNo)
    EndIf
    scsTryLockMutex(gnTimeLineMutex, #SCS_MUTEX_TIMELINE, nLockNo)
    If bLockedMutex
      If gnTraceMutexLocking > 0
        debugMsg3(sProcName, "gnTimeLineMutex locked, nLockNo=" + nLockNo)
      EndIf
      gnTimeLineMutexLockThread = gnThreadNo
      gnTimeLineMutexLockNo = nLockNo
      gqTimeLineMutexLockTime = ElapsedMilliseconds()
    EndIf
  EndIf
EndMacro

Macro UnlockTimeLineMutex()
  If bLockedMutex
    gnTimeLineMutexLockThread = 0
    scsUnlockMutex(gnTimeLineMutex, #SCS_MUTEX_TIMELINE)
    If gnTraceMutexLocking > 0
      debugMsg3(sProcName, "called UnlockMutex(gnTimeLineMutex)")
    EndIf
  EndIf
EndMacro

Macro CheckSubInRange(nValue, nMaxValue, sArrayName)
  If (nValue < 0) Or (nValue > nMaxValue)
    debugMsg(sProcName, "Out of bounds in function: " + #PB_Compiler_Procedure + " at line " + Str(#PB_Compiler_Line) + " in file " + #PB_Compiler_File) 
    setGlobalError(#SCS_ERROR_SUBSCRIPT_OUT_OF_RANGE, nValue, nMaxValue, sArrayName, sProcName)
    scsRaiseError()
  EndIf
EndMacro

Macro doRedim(aArray, nArraySize, sArrayName)
  If ArraySize(aArray()) < nArraySize
    ReDim aArray(nArraySize)
    If ArraySize(aArray()) < 0
      debugMsg(sProcName, "Out of bounds in function: " + #PB_Compiler_Procedure + " at line " + Str(#PB_Compiler_Line) + " in file " + #PB_Compiler_File) 
      setGlobalError(#SCS_ERROR_ARRAY_SIZE_INVALID, nArraySize, ArraySize(aArray()), sArrayName, sProcName)
      scsRaiseError()
    EndIf
  EndIf
EndMacro

Macro RaiseMiscError(sErrorMsg)
  gsError = sErrorMsg
  debugMsg(sProcName, gsError)
  scsRaiseError()
;   RaiseError(#SCS_ERROR_MISC)
EndMacro

Macro SetFlag(nFlagName, nFlagValue)
  nFlagName | nFlagValue
EndMacro

Macro ClearFlag(nFlagName, nFlagValue)
  If nFlagName & nFlagValue
    nFlagName ! nFlagValue
  EndIf
EndMacro

Macro samAddRequest(nRequest, p1Long=0, p2Single=0, p3Long=0, p4String="", qNotBefore=0, p5Long=0, pCuePtrForRequestTime=-1, pReplaceNotBefore=#True, bFullDuplicateTest=#False, p6Quad=0, p7Long=0, p8String="")
  samAddRequestProc(sProcName + "@" + #PB_Compiler_Line, nRequest, p1Long, p2Single, p3Long, p4String, qNotBefore, p5Long, pCuePtrForRequestTime, pReplaceNotBefore, bFullDuplicateTest, p6Quad, p7Long, p8String)
EndMacro

Macro sendSMSCommand(sCommandString, bLogCommand=#True)
  sendSMSCommandProc(sCommandString, bLogCommand, GetFilePart(#PB_Compiler_Filename, #PB_FileSystem_NoExtension) + "@" + #PB_Compiler_Line + "." + sProcName)
EndMacro

Macro sendSMSCommandNP(sCommandString, bLogCommand=#True)
  ; no sProcName (eg because source info already included at end of sCommandString)
  sendSMSCommandProc(sCommandString, bLogCommand)
EndMacro

Macro sendSMSCommandSC(sCommandString, bLogCommand=#True)
  ; used in statusCheck()
  sendSMSCommandProc(sCommandString, bLogCommand, GetFilePart(#PB_Compiler_Filename, #PB_FileSystem_NoExtension) + "@" + #PB_Compiler_Line + "." + sProcName, nLabel)
EndMacro

Macro getGadgetName(nGadgetNo, bIncludeWindow=#True)
  getGadgetNameProc(sProcName, nGadgetNo, bIncludeWindow)
EndMacro

Macro ShiftKeyDown()
  (GetAsyncKeyState_(#VK_SHIFT) & (1 << 15))
EndMacro

Macro setProcSFRFlags(pSFRCueType)
  Select pSFRCueType
    Case #SCS_SFR_CUE_PLAY_FIRST To #SCS_SFR_CUE_PLAY_LAST, #SCS_SFR_CUE_PLAYEXCEPT
      bPlayingCuesOnly = #True
  EndSelect
  Select pSFRCueType
    Case #SCS_SFR_CUE_ALL_ANY, #SCS_SFR_CUE_PLAY_ANY
      bAnyCues = #True
    Case #SCS_SFR_CUE_ALL_AUDIO, #SCS_SFR_CUE_PLAY_AUDIO
      bAudioOnly = #True
    Case #SCS_SFR_CUE_ALL_VIDEO_IMAGE, #SCS_SFR_CUE_PLAY_VIDEO_IMAGE
      bVideoOnly = #True
    Case #SCS_SFR_CUE_ALL_LIVE, #SCS_SFR_CUE_PLAY_LIVE
      bLiveOnly = #True
  EndSelect
EndMacro

Macro setProcSFRFlags2(pSFRCueType)
  Select pSFRCueType
    Case #SCS_SFR_CUE_ALL_ANY, #SCS_SFR_CUE_PLAY_ANY
      bAnyCues = #True
    Case #SCS_SFR_CUE_ALL_AUDIO, #SCS_SFR_CUE_PLAY_AUDIO
      bAudioOnly = #True
    Case #SCS_SFR_CUE_ALL_VIDEO_IMAGE, #SCS_SFR_CUE_PLAY_VIDEO_IMAGE
      bVideoOnly = #True
    Case #SCS_SFR_CUE_ALL_LIVE, #SCS_SFR_CUE_PLAY_LIVE
      bLiveOnly = #True
  EndSelect
EndMacro

Macro setWantThisSub(pSubPtr)
  bWantThisSub = #True
  ; 22Oct2018 11.7.1.4as: moved 'stopping everything' test around the remainder of the macro to match change made in Macros setWantThisCue()
  If gbStoppingEverything = #False And gbFadingEverything = #False ; Added gbFadingEverything test 13May2021 11.8.4.2bd when checking this macro for other changes
    If aSub(pSubPtr)\bSubEnabled = #False
      bWantThisSub = #False
    ElseIf bAnyCues
      ; If ((aSub(pSubPtr)\nSubState <= #SCS_CUE_READY) Or (aSub(pSubPtr)\nSubState > #SCS_CUE_FADING_OUT))
      If (aSub(pSubPtr)\nSubState > #SCS_CUE_FADING_OUT) ; Changed 8Nov2022 11.9.7ab following email from Dave Pursley where a sub-cue of a playing cue had not yet been started, and that caused the whole cue to be reset to 'Ready'
        bWantThisSub = #False
      EndIf
    ElseIf (bPlayingCuesOnly) And ((aSub(pSubPtr)\nSubState <= #SCS_CUE_READY) Or (aSub(pSubPtr)\nSubState > #SCS_CUE_FADING_OUT))
      bWantThisSub = #False
    ElseIf (bAudioOnly) And (aSub(pSubPtr)\bSubTypeForP = #False)
      bWantThisSub = #False
    ElseIf (bVideoOnly) And (aSub(pSubPtr)\bSubTypeA = #False)
      bWantThisSub = #False
    ElseIf (bLiveOnly) And (aSub(pSubPtr)\bSubTypeI = #False)
      bWantThisSub = #False
    ElseIf FindString("FPAIMER", aSub(pSubPtr)\sSubType) = 0 ; added 17Oct2016 11.5.2.3 following email from Alex Irwin about Level Change cues being stopped by an SFR cue
                                                             ; added "M" 20Mar2017 11.6.0 following report from Martin Norris that fade out all didn't stop a MIDI file
                                                             ; added "E" 23Mar2020 11.8.2.3af following report from Tim Hornett where he used an SFR cue to 'fade out and stop' a Memo cue, and the Memo cue didn't close
                                                             ; added "R" 02Jun2020 11.8.3rc7 following reported from Joris Verbeeren that 'run external program' sub-cues weren't stopped by 'stop all'
      If (aSub(pSubPtr)\nSubState >= #SCS_CUE_FADING_IN)     ; added nSubState test 22Mar2017 11.6.0 following email from Stas Ushomirsky about SFR counting down subs not being stopped
        bWantThisSub = #False
      EndIf
    EndIf
  Else
    ; Added 13May2021 11.8.4.2bd following emails from Rainer Schon
    If aSub(pSubPtr)\bSubEnabled = #False
      bWantThisSub = #False
    EndIf
    ; End added 13May2021 11.8.4.2bd following emails from Rainer Schon
  EndIf
EndMacro

Macro setWantThisSub2(pSubPtr)
  bWantThisSub = #True
  ; 22Oct2018 11.7.1.4as: moved 'stopping everything' test around the remainder of the macro to match change made in Macros setWantThisCue()
  If gbStoppingEverything = #False And gbFadingEverything = #False ; Added gbFadingEverything test 13May2021 11.8.4.2bd when checking this macro for other changes
    If aSub(pSubPtr)\bSubEnabled = #False
      bWantThisSub = #False
    ElseIf (bAudioOnly) And (aSub(pSubPtr)\bSubTypeForP = #False)
      bWantThisSub = #False
    ElseIf (bVideoOnly) And (aSub(pSubPtr)\bSubTypeA = #False)
      bWantThisSub = #False
    ElseIf (bLiveOnly) And (aSub(pSubPtr)\bSubTypeI = #False)
      bWantThisSub = #False
    ElseIf FindString("FPAIMER", aSub(pSubPtr)\sSubType) = 0 ; added 17Oct2016 11.5.2.3 following email from Alex Irwin about Level Change cues being stopped by an SFR cue
                                                             ; added "M" 20Mar2017 11.6.0 following report from Martin Norris that fade out all didn't stop a MIDI file
                                                             ; added "E" 23Mar2020 11.8.2.3af following report from Tim Hornett where he used an SFR cue to 'fade out and stop' a Memo cue, and the Memo cue didn't close
                                                             ; added "R" 02Jun2020 11.8.3rc7 following reported from Joris Verbeeren that 'run external program' sub-cues weren't stopped by 'stop all'
      If (aSub(pSubPtr)\nSubState >= #SCS_CUE_FADING_IN)     ; added nSubState test 22Mar2017 11.6.0 following email from Stas Ushomirsky about SFR counting down subs not being stopped
        bWantThisSub = #False
      EndIf
    EndIf
  Else
    ; Added 13May2021 11.8.4.2bd following emails from Rainer Schon
    If aSub(pSubPtr)\bSubEnabled = #False
      bWantThisSub = #False
    EndIf
    ; End added 13May2021 11.8.4.2bd following emails from Rainer Schon
  EndIf
EndMacro

Macro setWantThisCue(pCuePtr)
  bWantThisCue = #True
  ; 22Oct2018 11.7.1.4as: moved 'stopping everything' test around the remainder of the macro following report from Richard Borsey about some cues not stopping after 'stop all'
  ; under certain conditions (see email and logs supplied by Richard)
  If gbStoppingEverything = #False And gbFadingEverything = #False ; Added gbFadingEverything test 13May2021 11.8.4.2bd when checking this macro for other changes
    If aCue(pCuePtr)\bCueCurrentlyEnabled = #False
      bWantThisCue = #False
    ElseIf bAnyCues
      If ((aCue(pCuePtr)\nCueState <= #SCS_CUE_READY) Or (aCue(pCuePtr)\nCueState > #SCS_CUE_FADING_OUT))
        bWantThisCue = #False
      EndIf
    ElseIf (bPlayingCuesOnly) And ((aCue(pCuePtr)\nCueState <= #SCS_CUE_READY) Or (aCue(pCuePtr)\nCueState > #SCS_CUE_FADING_OUT))
      bWantThisCue = #False
    ElseIf (bAudioOnly) And (aCue(pCuePtr)\bSubTypeForP = #False)
      bWantThisCue = #False
    ElseIf (bVideoOnly) And (aCue(pCuePtr)\bSubTypeA = #False)
      bWantThisCue = #False
    ElseIf (bLiveOnly) And (aCue(pCuePtr)\bSubTypeI = #False)
      bWantThisCue = #False
    ElseIf (aCue(pCuePtr)\bSubTypeForP = #False) And (aCue(pCuePtr)\bSubTypeA = #False) And (aCue(pCuePtr)\bSubTypeI = #False) ; added 17Oct2016 11.5.2.3 following email from Alex Irwin about Level Change cues being stopped by an SFR cue
      bWantThisCue = #False
    EndIf
  Else
    ; Added 13May2021 11.8.4.2bd to match changes made in macro setWantThisSub()
    If aCue(pCuePtr)\bCueCurrentlyEnabled = #False
      bWantThisCue = #False
    EndIf
    ; End added 13May2021 11.8.4.2bd to match changes made in macro setWantThisSub()
  EndIf
  
  ; debugMsg(sProcName, "bVideoOnly=" + strB(bVideoOnly) + ", (aCue(" + getCueLabel(pCuePtr) + ")\bSubTypeA=" + strB(aCue(pCuePtr)\bSubTypeA) + ", bWantThisCue=" + strB(bWantThisCue))
EndMacro

Macro decodeFlag(pHoldFlags, pFlagLong, pFlagString, pDecodedString)
  nTmpFlag = pFlagLong
  nTmp = pHoldFlags & nTmpFlag
  If nTmp = nTmpFlag
    pDecodedString + pFlagString
    pHoldFlags ! nTmp
    ; debugMsg(sProcName, "pHoldFlags=$" + Hex(pHoldFlags) + ", pDecodedString=" + pDecodedString)
  EndIf
EndMacro

Macro macSetRelStartTime(pTxtField)
  Select aSub(pSubPtr)\nRelStartMode
    Case #SCS_RELSTART_DEFAULT
      SetGadgetText(pTxtField, timeToStringBWZ(aSub(pSubPtr)\nRelStartTime))
    Default
      SetGadgetText(pTxtField, timeToString(aSub(pSubPtr)\nRelStartTime))
  EndSelect
EndMacro

Macro StrN(nValue, nSize)
  ; return right-justified string of a number, with leading zeros
  ; eg StrN(12,5) will return the string "00012"
  RSet(Str(nValue), nSize, "0")
EndMacro

Macro getTemplateName(sTemplateFile)
  ignoreExtension(GetFilePart(sTemplateFile))
EndMacro

Macro drawPosCursor(X, nGraphTop, nGraphBottom, nCursorColor, nShadowColor, bCuePanel)
  If (grColorScheme\rColorAudioGraph\nCuePanelCursorStyle = 0) And (bCuePanel)
    ; display a pointer at the top of the cursor
    ; DrawingMode(#PB_2DDrawing_AlphaBlend)
    DrawingMode(#PB_2DDrawing_Default)
    Box(X-4, nGraphTop, 9, 5, nCursorColor)
    LineXY(X-3, nGraphTop+5, X+3, nGraphTop+5, nCursorColor)
    LineXY(X-2, nGraphTop+6, X+2, nGraphTop+6, nCursorColor)
    LineXY(X-1, nGraphTop+7, X+1, nGraphTop+7, nCursorColor)
    ; vertical cursor line
    LineXY(X, nGraphTop+8, X, nGraphBottom, nCursorColor)
    ; vertical 'shadow' lines (left)
    LineXY(X-1, nGraphTop+8, X-1, nGraphBottom, nShadowColor)
    LineXY(X-5, nGraphTop, X-5, nGraphTop+4, nShadowColor)
    LineXY(X-4, nGraphTop+5, X-2, nGraphTop+7, nShadowColor)
    ; vertical 'shadow' lines (right) ; added 15Jun2017 11.7.0
    LineXY(X+1, nGraphTop+8, X+1, nGraphBottom, nShadowColor)
    LineXY(X+5, nGraphTop, X+5, nGraphTop+4, nShadowColor)
    LineXY(X+4, nGraphTop+5, X+2, nGraphTop+7, nShadowColor)
    DrawingMode(#PB_2DDrawing_Default)
  Else
    ; display a pointer at the bottom of the cursor
    ; vertical cursor line
    ; debugMsg(sProcName, "LineXY(" + X + ", ...)")
    LineXY(X, nGraphTop, X, nGraphBottom, nCursorColor)
    ; vertical 'shadow' line (left)
    LineXY(X-1, nGraphTop, X-1, nGraphBottom, nShadowColor)
    ; vertical 'shadow' line (right) ; added 15Jun2017 11.7.0
    LineXY(X+1, nGraphTop, X+1, nGraphBottom, nShadowColor)
  EndIf
EndMacro

Macro traceDMXChannelIfReqd(sPrefix, nDMXDevPtr, nDMXPort, nDMXChannel, nItemIndex)
  CompilerIf #cTraceDMXSendChannels1to12
    If nDMXChannel < 13
      debugMsg(sProcName, sPreFix + "nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel +
                          ", grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet) +
                          ", \nDMXChannelValue=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelValue +
                          ", \bDMXChannelDimmable=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelDimmable) +
                          ", \nDMXChannelFadeTime=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelFadeTime)
    EndIf
  CompilerElseIf #cTraceDMXSendChannels1to34
    If nDMXChannel < 35
      debugMsg(sProcName, sPreFix + "nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel +
                          ", grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet) +
                          ", \nDMXChannelValue=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelValue +
                          ", \bDMXChannelDimmable=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelDimmable) +
                          ", \nDMXChannelFadeTime=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelFadeTime)
    EndIf
  CompilerElseIf #cTraceDMXSendChannelsNonZero
    If grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelValue > 0
      debugMsg(sProcName, sPreFix + "nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel +
                          ", grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet) +
                          ", \nDMXChannelValue=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelValue +
                          ", \bDMXChannelDimmable=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelDimmable) +
                          ", \nDMXChannelFadeTime=" + grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelFadeTime)
    EndIf
  CompilerEndIf
EndMacro

Macro audSetState(pAudPtr, pAudState, pCallId=0)
  If pAudState <> aAud(pAudPtr)\nAudState
    If pCallId = 0
      debugMsg(sProcName, "changing aAud(" + getAudLabel(pAudPtr) + ")\nAudState from " + decodeCueState(aAud(pAudPtr)\nAudState) + " to " + decodeCueState(pAudState))
    Else
      debugMsg(sProcName, "pCallId=" + pCallId + ", changing aAud(" + getAudLabel(pAudPtr) + ")\nAudState from " + decodeCueState(aAud(pAudPtr)\nAudState) + " to " + decodeCueState(pAudState))
    EndIf
  EndIf
  aAud(pAudPtr)\nAudState = pAudState
EndMacro

Macro doThreadLoopStart(nThreadIndex, nSuspensionDelayTime=10)
  
  nLoopAction = #SCS_LOOP_ACTION_PROCEED
  
  If (gaThread(nThreadIndex)\nThreadState = #SCS_THREAD_STATE_STOPPED) Or (gaThread(nThreadIndex)\bStopRequested) Or (gaThread(nThreadIndex)\bStopASAP)
    ; gbClosingDown is not included in the above test because the network thread must NOT be aborted during closedown or we will lose SMS responses to commands like 'set matrix off' etc
    debugMsg(sProcName, "\nThreadState=" + THR_decodeThreadState(gaThread(nThreadIndex)\nThreadState) + ", \bStopRequested=" + strB(gaThread(nThreadIndex)\bStopRequested) + ", \bStopASAP=" + strB(gaThread(nThreadIndex)\bStopASAP))
    gaThread(nThreadIndex)\nThreadState = #SCS_THREAD_STATE_STOPPED
    gaThread(nThreadIndex)\bStopASAP = #False
    gaThread(nThreadIndex)\bStopRequested = #False
    gaThread(nThreadIndex)\bSuspendRequested = #False
    ; debugMsg(sProcName, "(a) \bStopRequested=" + strB(gaThread(nThreadIndex)\bStopRequested) + ", \bSuspendRequested=" + StrB(gaThread(nThreadIndex)\bSuspendRequested))
  EndIf
  nThreadState = gaThread(nThreadIndex)\nThreadState
  bSuspendRequested = gaThread(nThreadIndex)\bSuspendRequested
  
  If nThreadState = #SCS_THREAD_STATE_STOPPED
    ; thread stopped, ie quit thread
    debugMsg(sProcName, "Thread " + THR_decodeThreadIndex(nThreadIndex) + " stopped")
    nLoopAction = #SCS_LOOP_ACTION_BREAK
  EndIf
  
  If bSuspendRequested
    ; thread to be suspended (ie keep thread alive but do nothing)
    gaThread(nThreadIndex)\nThreadState = #SCS_THREAD_STATE_SUSPENDED
    gaThread(nThreadIndex)\bSuspendRequested = #False
    ; debugMsg(sProcName, "(b) \bSuspendRequested=" + StrB(gaThread(nThreadIndex)\bSuspendRequested))
    nThreadState = gaThread(nThreadIndex)\nThreadState
    Select nThreadIndex
      Case #SCS_THREAD_BLENDER
        If gbPictureBlending
          gbPictureBlending = #False
          ; debugMsg(sProcName, "gbPictureBlending=" + strB(gbPictureBlending))
        EndIf
    EndSelect
    debugMsg(sProcName, "Thread " + THR_decodeThreadIndex(nThreadIndex) + " suspended")
    Delay(nSuspensionDelayTime)
    nLoopAction = #SCS_LOOP_ACTION_CONTINUE
  EndIf
  
  If nThreadState = #SCS_THREAD_STATE_SUSPENDED
    ; thread suspended (ie do nothing)
    Delay(nSuspensionDelayTime)
    nLoopAction = #SCS_LOOP_ACTION_CONTINUE
  EndIf
  
EndMacro

Macro traceContainer(nGadgetNo)
  debugMsg(sProcName, "gnContainerLevel=" + gnContainerLevel + ", " + Space(gnContainerLevel*2) + gaGadgetProps(nGadgetNo - #SCS_GADGET_BASE_NO)\sLogName + ", " + X + ", " + Y + ", " + Width + ", " + Height)
EndMacro

Macro traceContainerNoPosOrSize(nGadgetNo)
  debugMsg(sProcName, "gnContainerLevel=" + gnContainerLevel + ", " + Space(gnContainerLevel*2) + gaGadgetProps(nGadgetNo - #SCS_GADGET_BASE_NO)\sLogName)
EndMacro

Macro setGlobalTimeNow()
  ; This macro was created 11Jan2021 to ensure that gqTimeNow does NOT get updated whilst processing 'Apply Move to Time'.
  ; gqTimeNow does get set near the start of M2T_btnMoveToTimeApply_Click() but this setting of gqTimeNow must then be unchanged for the duration of processing M2T_btnMoveToTimeApply_Click(),
  ; otherwise some sub-cue positions may be slightly inaccurate. Tested using cue file "Startbahn 2 - Q30.scs11" from Christian Peters.
  ; The macro does NOT need to be used in procedures that will never be called directly or indirectly from M2T_btnMoveToTimeApply_Click(), eg editor procedures.
  If grM2T\bProcessingApplyMoveToTime = #False
    gqTimeNow = ElapsedMilliseconds()
  EndIf
EndMacro

Macro traceDMXChannelItems(pCompilerIf)
  CompilerIf pCompilerIf
    For n = 0 To ArraySize(grDMXChannelItems\aDMXChannelItem())
      If grDMXChannelItems\aDMXChannelItem(n)\bDMXChannelSet Or grDMXChannelItems\aDMXChannelItem(n)\nDMXChannelValue > 0
        debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + n + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(n)\bDMXChannelSet) +
                            ", \nDMXChannelValue=" + grDMXChannelItems\aDMXChannelItem(n)\nDMXChannelValue + ", \nDMXChannelFadeTime=" + grDMXChannelItems\aDMXChannelItem(n)\nDMXChannelFadeTime)
      EndIf
    Next n
  CompilerEndIf
EndMacro

; ----------------------------
Macro macHeaderEvents(pRecord)
  
Case pRecord\cboRelStartMode
  CBOCHG(SUB_cboRelStartMode_Click(pRecord\cboRelStartMode))
  
Case pRecord\cboSubCueMarker
  CBOCHG(SUB_cboSubCueMarker_Click(pRecord\cboSubCueMarker))
  
Case pRecord\cboSubStart
  CBOCHG(SUB_cboSubStart_Click(pRecord\cboSubStart))
  
Case pRecord\chkSubEnabled
  CHKOWNCHG(SUB_chkSubEnabled_Click(pRecord\chkSubEnabled, pRecord\lblSubDisabled, pRecord\txtSubDescr))
  
Case pRecord\cntSubHeader
  ; ignore events
  
Case pRecord\txtRelStartTime
  If gnEventType = #PB_EventType_LostFocus
    ETVAL(SUB_txtRelStartTime_Validate(pRecord\txtRelStartTime, pRecord\cboSubStart))
  EndIf
  
Case pRecord\txtSubDescr
  If gnEventType = #PB_EventType_Change
    SUB_txtSubDescr_Change(pRecord\txtSubDescr, pRecord\lblSubDescr)
  ElseIf gnEventType = #PB_EventType_LostFocus
    ETVAL(SUB_txtSubDescr_Validate(pRecord\txtSubDescr))
  EndIf
  
Case pRecord\txtSubRelMTCStartPart(0)
  If gnEventType = #PB_EventType_Change
    Select gnEventGadgetNo
      Case pRecord\txtSubRelMTCStartPart(0)
        macTimecodeEntry(pRecord\txtSubRelMTCStartPart(0), pRecord\txtSubRelMTCStartPart(1))
      Case pRecord\txtSubRelMTCStartPart(1)
        macTimecodeEntry(pRecord\txtSubRelMTCStartPart(1), pRecord\txtSubRelMTCStartPart(2))
      Case pRecord\txtSubRelMTCStartPart(2)
        macTimecodeEntry(pRecord\txtSubRelMTCStartPart(2), pRecord\txtSubRelMTCStartPart(3))
      Case pRecord\txtSubRelMTCStartPart(3)
        ; do NOT call macTimecodeEntry() as this is the last part of the timecode
    EndSelect
  ElseIf gnEventType = #PB_EventType_LostFocus
    debugMsg(sProcName, "calling ETVAL(SUB_txtRelMTCStartPart_Validate())")
    ETVAL(SUB_txtRelMTCStartPart_Validate())
    debugMsg(sProcName, "returned from ETVAL(SUB_txtRelMTCStartPart_Validate())")
  EndIf
EndMacro

; ----------------------------
Macro macHeaderValGadget(pRecord)
  
Case pRecord\txtRelStartTime
  ETVAL2(SUB_txtRelStartTime_Validate(\txtRelStartTime, \cboSubStart))
  
Case pRecord\txtSubDescr
  ETVAL2(SUB_txtSubDescr_Validate(pRecord\txtSubDescr))
  
EndMacro

; ----------------------------
Macro macHeaderDisplaySub(pRecord, pSubType, pFormGlobal)
  setOwnState(pFormGlobal\chkSubEnabled, pRecord\bSubEnabled)
  SUB_fcSubEnabled(pFormGlobal\lblSubDisabled, pFormGlobal\txtSubDescr)
  SGT(pFormGlobal\txtSubDescr, pRecord\sSubDescr)
  setSubDescrToolTip(pFormGlobal\txtSubDescr)
  SUB_setCboSubStart(pFormGlobal\cboSubStart, pRecord\nSubStart)
  SUB_fcSubStart(pSubType)
  SUB_setCboRelStartMode(pFormGlobal\cboRelStartMode, pRecord\nRelStartMode)
  macSetRelStartTime(pFormGlobal\txtRelStartTime)
EndMacro

; ----------------------------
Macro macReadNumericOrStringParam(pData, pString, pNumeric, pNumDefault, pTimeField)
  ; Modified 30Jan2024 11.10.2ad following tests that revealed the macro did not handle time fields containing minutes, eg "2:30"
  ; NOTE: Populates pString and pNumeric from value in pData.
  ; NOTE: pString will be set to "" unless pData is a callable cue parameter, in which case pString will set to pData
  ; pTimeField should only be set #True if pData contains a formatted time field, eg 3.5 or 2:30.123.  
  ; Saved time fields are stored in milliseconds so these are just like any other numeric field and so pTimeField should be set #False.
  If pData And UCase(Left(pData,1)) >= "A" And UCase(Left(pData,1)) <= "Z"
    ; This is a callable cue parameter (paramid's must start with a letter)
    pString = pData
    pNumeric - pNumDefault
  Else
    pString = ""
    If pData
      If pTimeField
        pNumeric = stringToTime(pData) ; converts time field to milliseconds, eg "3.5" to 3500, "2:30" to 150000
      Else
        pNumeric = Val(pData)
      EndIf
    Else
      ; pData is blank
      pNumeric = pNumDefault
    EndIf
  EndIf
EndMacro

; ----------------------------
Macro macWriteTagForNumericOrStringParam(pTag, pString, pNumeric, pNumDefault)
  If pString And UCase(Left(pString,1)) >= "A" And UCase(Left(pString,1)) <= "Z"
    ; this is a callable cue parameter (paramid's must start with a letter)
    writeTagWithContent(nFileNo, pTag, pString)
  Else
    ; this is a normal numeric value
    writeTagIfReqd(nFileNo, pTag, Str(pNumeric), Str(pNumDefault))
  EndIf
EndMacro

; ----------------------------
Macro macTimecodeEntry(nGadgetPartNo, nNextGadgetPartNo)
  ; Enhancement requested by Ian Harding:
  ;   Is it possible to [also] use the ‘.’ (decimal point) to shift between hour/minutes/seconds/frames in all timecode enter fields?
  ;   This allows the numeric keypad to be leveraged to key in times much easier/faster.
  ; NOTE: This macro should only be used as the LAST or ONLY code in #PB_EventType_Change processing of a MTC time code part, eg txtMTCStartPart(n)
  ; An MTC timecode comprises 4 parts 
  gsTmpString = Trim(GetGadgetText(nGadgetPartNo))
  If Len(gsTmpString) > 0
    If Right(gsTmpString,1) = "."
      SetGadgetText(nGadgetPartNo, Trim(gsTmpString, "."))
      SetActiveGadget(nNextGadgetPartNo)
    ElseIf Right(gsTmpString,1) = ":"
      SetGadgetText(nGadgetPartNo, Trim(gsTmpString, ":"))
      SetActiveGadget(nNextGadgetPartNo)
    EndIf
  EndIf
EndMacro

Macro macSMSLevelPlus6dB(fLevel)
  fReqdDBLevel = convertBVLevelToDBLevel(fLevel)
  fReqdDBLevel + 6
  fLevel = convertDBLevelToBVLevel(fReqdDBLevel)
EndMacro

Macro macSMSLevelMinus6dB(fLevel)
  fReqdDBLevel = convertBVLevelToDBLevel(fLevel)
  fReqdDBLevel - 6
  fLevel = convertDBLevelToBVLevel(fReqdDBLevel)
EndMacro

Macro macCommonTimeFieldValidationD(bInValidateFlag)
  ; common validation for time values in hundredths of a second, also allowing for the time field containing a callable cue parameter
  sValue = Trim(GGT(nTimeGadget))
  If sValue
    nTimeFieldIsParamId = isNumericValueACallCueParamId(sValue, nEditSubPtr)
    ; nTimeFieldIsParamId values:
    ;   0 - sValue is not a call cue parameter, ie it doesn't start with A-Z or a-z
    ;   1 - sValue is a call cue parameter that was found in the parent cue's parameter list
    ;  -1 - sValue looks like a call cue parameter but it does not exist in the parent cue's parameter list
    If nTimeFieldIsParamId = 0
      If validateTimeFieldD(sValue, sPrompt, #False, #False, 0, #True) = #False
        bInValidateFlag = #False
        ProcedureReturn #False
      ElseIf GGT(nTimeGadget) <> gsTmpString
        SGT(nTimeGadget, gsTmpString)
      EndIf
    EndIf
  EndIf
EndMacro

Macro macCommonTimeFieldValidationT(bInValidateFlag)
  ; common validation for time values in thousandths of a second (milliseconds), also allowing for the time field containing a callable cue parameter
  sValue = Trim(GGT(nTimeGadget))
  If sValue
    nTimeFieldIsParamId = isNumericValueACallCueParamId(sValue, nEditSubPtr)
    ; nTimeFieldIsParamId values:
    ;   0 - sValue is not a call cue parameter, ie it doesn't start with A-Z or a-z
    ;   1 - sValue is a call cue parameter that was found in the parent cue's parameter list
    ;  -1 - sValue looks like a call cue parameter but it does not exist in the parent cue's parameter list
    If nTimeFieldIsParamId = 0
      If validateTimeFieldT(sValue, sPrompt, #False, #False, 0, #True) = #False
        bInValidateFlag = #False
        ProcedureReturn #False
      ElseIf GGT(nTimeGadget) <> gsTmpString
        SGT(nTimeGadget, gsTmpString)
      EndIf
    EndIf
  EndIf
EndMacro

Macro lockBassAsioIfReqd()
  If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO
    gnCurrAsioLockCount + 1
    If gnCurrAsioLockCount = 1
      debugMsg(sProcName, "Calling BASS_ASIO_Lock(#BASSTRUE)")
      nBassResult = BASS_ASIO_Lock(#BASSTRUE)
      debugMsg2(sProcName, "BASS_ASIO_Lock(#BASSTRUE)", nBassResult)
      If nBassResult = #BASSFALSE
        nErrorCode = BASS_ASIO_ErrorGetCode()
        debugMsg3(sProcName, "BASS_ASIO_ErrorGetCode=" + nErrorCode + " (" + getBassErrorDesc(nErrorCode) + ")")
      EndIf
    Else
      debugMsg(sProcName, "BASS_ASIO_Lock(#BASSTRUE) not called because gnCurrAsioLockCount=" + gnCurrAsioLockCount)
    EndIf
  EndIf
EndMacro

Macro unlockBassAsioIfReqd()
  If gnCurrAudioDriver = #SCS_DRV_BASS_ASIO
    If gnCurrAsioLockCount = 1
      debugMsg(sProcName, "Calling BASS_ASIO_Lock(#BASSFALSE)")
      nBassResult = BASS_ASIO_Lock(#BASSFALSE)
      debugMsg2(sProcName, "BASS_ASIO_Lock(#BASSFALSE)", nBassResult)
      If nBassResult = #BASSFALSE
        nErrorCode = BASS_ASIO_ErrorGetCode()
        debugMsg3(sProcName, "BASS_ASIO_ErrorGetCode=" + nErrorCode + " (" + getBassErrorDesc(nErrorCode) + ")")
      EndIf
    Else
      debugMsg(sProcName, "BASS_ASIO_Lock(#BASSFALSE) not called because gnCurrAsioLockCount=" + gnCurrAsioLockCount)
    EndIf
    gnCurrAsioLockCount - 1
  EndIf
EndMacro

; EOF