; File WindowEventHandler.pbi

EnableExplicit

Procedure clearOtherOptionGadget2s(nEventGadgetNo, nEventGadgetPropsIndex)
  PROCNAMEC()
  Protected nContainerGadgetNo
  Protected nGadgetNo, nGadgetPropsIndex
  
  debugMsg(sProcName, #SCS_START + ", nEventGadgetNo=" + getGadgetName(nEventGadgetNo))
  If gaGadgetProps(nEventGadgetPropsIndex)\nContainerLevel > 0
    nContainerGadgetNo = gaGadgetProps(gnEventGadgetPropsIndex)\nContainerGadgetNo
    For nGadgetNo = #SCS_GADGET_BASE_NO To gnMaxGadgetNo
      nGadgetPropsIndex = nGadgetNo - #SCS_GADGET_BASE_NO
      With gaGadgetProps(nGadgetPropsIndex)
        If \nGType = #SCS_GTYPE_OPTION2
          If \nContainerGadgetNo = nContainerGadgetNo
            If nGadgetNo <> nEventGadgetNo
              debugMsg(sProcName, "calling setOwnState(" + getGadgetName(nGadgetNo) + ", 0)")
              setOwnState(nGadgetNo, 0)
            EndIf
          EndIf
        EndIf
      EndWith
    Next nGadgetNo
  EndIf
  
EndProcedure

Procedure handleWindowEvents()
  PROCNAMEC()
  Protected nActiveGadgetNo
  Protected sMidiCue.s, nCuePtr, nSubPtr, nAudPtr
  Protected bIgnoreEvent
  Protected qTimeOfLastMonitorCheck.q, qTimeNow.q, qTimeDiff.q, nMinTimeDiff
  Protected qTimeOfLastButtonClick.q, bSetTimeOfLastButtonClick
  Protected nBassASIODevice.l
  Protected nBassResult.l, nErrorCode.l
  Protected nThreadNo, nMutexNo
  Protected qTimeOfLastHalfSecondCheck.q
  Protected nEventData
  Protected bCalledFromDrawVUDisplay, bCalledFromSendMTCQuarterFrames
  Protected bMonitorCheckBoxKeyboardKey, bCheckBoxClickOrEquivalent
  Protected bButtonClickOrEquivalent
  Protected bLockedMutex
  Protected nDispPanel, bValidationResult
  ; Protected sMidiInName.s
  
  ; need to wait until splash window is created because WaitWindowEvent() will fail if no window exists
  While IsWindow(#WSP) = 0
    Delay(200)
  Wend
  debugMsg(sProcName, "starting")
  
  qTimeOfLastMonitorCheck = ElapsedMilliseconds()
  qTimeOfLastButtonClick = qTimeOfLastMonitorCheck
  qTimeOfLastHalfSecondCheck = qTimeOfLastMonitorCheck
  
  Repeat
    gnMainThreadLabel = #PB_Compiler_Line
    gqThreadMainLoopStarted = ElapsedMilliseconds()
    gnWindowEvent = WaitWindowEvent(gnWaitWindowEventTimeout) ; nb gnWaitWindowEventTimeout initially preset, and can also be changed externally
    ; debugMsg(sProcName, "gnWindowEvent=" + gnWindowEvent)
    gqTimeNow = ElapsedMilliseconds()
    gqThreadMainEventStarted = gqTimeNow
    
    ; timeout allows us to process SAM requests, update progress counters, VU meters etc, even if no 'event' has occurred
    ; gnWaitWindowEventTimeout = 50
    ; gnWaitWindowEventTimeout = 10
    gnWaitWindowEventTimeout = 20
    bIgnoreEvent = #False
    bSetTimeOfLastButtonClick = #False
    
    With grStopEverythingInfo
      If gbStopEverything
        ; we get here only if stopEverythingPart1() was called from a thread other than the main thread,
        ; so stopEverythingPart1() is now called from this main thread
        debugMsg(sProcName, "calling stopEverythingPart1(" + getCueLabel(\nCuePtr) + ", " + strB(\bResetAfterStop) + ", " + strB(\bResumeThreadsAfterStop) + ")")
        stopEverythingPart1(\nCuePtr, \bResetAfterStop, \bResumeThreadsAfterStop)
      EndIf
      If \bCallStopEverythingPart2
        If (\nDelayTimeBeforePart2 = 0) Or (ElapsedMilliseconds() >= (gqStopEverythingTime + \nDelayTimeBeforePart2))
          debugMsg(sProcName, "calling stopEverythingPart2(" + getCueLabel(\nCuePtr) + ", " + strB(\bResetAfterStop) + ", " + strB(\bResumeThreadsAfterStop) + ")")
          stopEverythingPart2(\nCuePtr, \bResetAfterStop, \bResumeThreadsAfterStop)
        EndIf
      EndIf
    EndWith
    
    qTimeNow = ElapsedMilliseconds()
    If gnWindowEvent <> 0
      
      gnMainThreadLabel = #PB_Compiler_Line
      gnSliderEvent = #SCS_SLD_EVENT_NONE
      gnEventWindowNo = EventWindow()
      gnEventGadgetNo = EventGadget()
      gnEventType = EventType()
      
      ; debugMsg(sProcName,"gnWindowEvent=" + decodeEvent(gnWindowEvent) + ", gnEventWindowNo=" + decodeWindow(gnEventWindowNo) + ", gnEventGadgetNo=G" + gnEventGadgetNo)
      
      If gqPriorityPostEventWaiting > 0
        Select gnWindowEvent
          Case #SCS_Event_DummyFirst To #SCS_Event_DummyLast
            ; about to process this priority post event so we can clear the flag
            gqPriorityPostEventWaiting = 0
        EndSelect
      EndIf
      
      gnMainThreadLabel = #PB_Compiler_Line
      Select gnWindowEvent
        Case #PB_Event_Gadget ; gadget event
          gnMainThreadLabel = #PB_Compiler_Line
          If (gnEventGadgetNo >= #SCS_GADGET_BASE_NO) And (gnEventGadgetNo <= gnMaxGadgetNo)
            gnEventGadgetPropsIndex = gnEventGadgetNo - #SCS_GADGET_BASE_NO
            With gaGadgetProps(gnEventGadgetPropsIndex)
              gnEventGadgetNoForEvHdlr = \nGadgetNoForEvHdlr
              gnEventGadgetType = \nGType
              gnEventGadgetArrayIndex = \nArrayIndex
              gnEventCuePanelNo = \nCuePanelNo
              gnEventSliderNo = \nSliderNo
              Select gnEventType
                Case #PB_EventType_MouseEnter, #PB_EventType_MouseLeave, #PB_EventType_MouseMove, #PB_EventType_MouseWheel
                  ; Added 28Jun2022 11.9.3ad following errors reported by Ian Harding (27Jun2022) and Beverley Grover (also 27Jun2022)
                  ; Example: if user changes the cue number in the editor to an existing cue number, then an 'already exists' error is correctly reported using a standard message box.
                  ; However, if the message box (and particularly the OK button) is positioned over a canvas gadget (such as WQA\cvsPreview) then when OK is clicked and the message box is closed,
                  ; the cursor is then over the canvas gadget and a 'mouse enter' event is raised. This can cause 'SetActiveGadget' to be applied to the canvas gadget, which immediately re-raises
                  ; the 'lost focus' event on the error field (eg the cue number). The result is that the error message is repeatedly re-raised.
                  ; The problem only occurs if gbLastVALResult is #False, so in that case we now ignore all mouse events.
                  If gbLastVALResult = #False
                    If gnEventType = #PB_EventType_MouseEnter Or gnEventType = #PB_EventType_MouseLeave
                      debugMsg(sProcName, "ignoring gnEventType=" + decodeEventType(gnEventGadgetNo) + " on " + getGadgetName(gnEventGadgetNo) + ", gaGadgetProps(gnEventGadgetPropsIndex)=" + getGadgetName(gaGadgetProps(gnEventGadgetPropsIndex)))
                    EndIf
                    bIgnoreEvent = #True
                  EndIf
                  ; End added 28Jun2022 11.9.3ad
                  ; ignore logging
                Case #WM_KEYDOWN, #WM_KEYUP, #WM_MOUSEMOVE
                  ; ignore logging
                Case #PB_EventType_KeyDown, #PB_EventType_KeyUp
                  ; ignore logging
                Case #PB_EventType_LeftButtonDown, #PB_EventType_LeftButtonUp, #PB_EventType_LeftClick
                  ; debugMsg0(sProcName, \sGWindow + "\" + \sName + ": " + decodeEventType(gnEventGadgetNo) + ", gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", gnEventGadgetNo=" + gnEventGadgetNo + ", gnEventSliderNo=" + gnEventSliderNo)
                  ; ignore logging
                Case #PB_EventType_Focus, #PB_EventType_LostFocus, #PB_EventType_Change
                  ; include '#PB_EventType_Change' to avoid key events for every key press in text fields
                  ; ignore logging
                Case #PB_EventType_Resize
                  ; ignore logging
                Case #PB_EventType_Input ; Added 17Feb2022 11.9.1aa following log from Michel Winogradoff
                  ; ignore logging
                Case 1024
                  ; hex(400) - not sure why this event type is raised - it seems to occur with #PB_EventType_Change on string fields
                  ; ignore logging
                Default
                  logKeyEvent(\sGWindow + "\" + \sName + ": " + decodeEventType(gnEventGadgetNo))
              EndSelect
            EndWith
            If bIgnoreEvent = #False ; Test added 28Jun2022 11.9.3ad
              gnMainThreadLabel = #PB_Compiler_Line
              If gnEventSliderNo > 0
                If gnFocusSliderNo <> gnEventSliderNo
                  If gnEventType = #PB_EventType_Focus
                    If SLD_getEnabled(gnEventSliderNo)
                      gnFocusSliderNo = gnEventSliderNo
                      ; debugMsg(sProcName, "gnEventType=" + decodeEventType() + ", calling SLD_gotFocus(" + Str(gnFocusSliderNo) + ")")
                      SLD_gotFocus(gnFocusSliderNo)
                    EndIf
                  EndIf
                EndIf
                ; debugMsg0(sProcName, "calling SLD_Event() gnEventSliderNo=" + gnEventSliderNo + ", gnEventType=" + gnEventType + ", gnEventWindowNo=" + decodeWindow(gnEventWindowNo))
                gnSliderEvent = SLD_Event(gnEventSliderNo, gnWindowEvent, gnEventWindowNo, gnEventGadgetNo, gnEventType, #True)
                ; debugMsg0(sProcName, "gnEventSliderNo=" + gnEventSliderNo + ", gnSliderEvent=" + gnSliderEvent)
              Else
                If gnEventType <> #PB_EventType_LostFocus
                  If gnFocusSliderNo <> 0
                    Select gnEventType
                      Case #PB_EventType_MouseEnter, #PB_EventType_MouseLeave, #PB_EventType_MouseMove, #PB_EventType_MouseWheel
                        ; ignore mouse movements when testing for lost-focus so we don't treat moving the mouse over a canvas gadget as a trigger for simulating lost-focus
                      Default
                        SLD_LostFocus(gnFocusSliderNo)
                        gnFocusSliderNo = 0
                    EndSelect
                  EndIf
                EndIf
              EndIf
              
              gnMainThreadLabel = #PB_Compiler_Line
              gnEventButtonId = gaGadgetProps(gnEventGadgetNo-#SCS_GADGET_BASE_NO)\nToolBarBtnId
              If gnEventButtonId <> 0
                Select gnEventType
                  Case #PB_EventType_LeftClick
                    debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventType=#PB_EventType_LeftClick")
                    If (ElapsedMilliseconds() - qTimeOfLastButtonClick) <= grGeneralOptions\nDoubleClickTime
                      debugMsg(sProcName, "double-click assumed - ignoring second click")
                      bIgnoreEvent = #True
                    Else
                      bSetTimeOfLastButtonClick = #True
                    EndIf
                EndSelect
              EndIf
              
;               gnMainThreadLabel = #PB_Compiler_Line
;               Select gnWindowEvent
;                 Case #WM_SYSTIMER, #WM_PAINT
;                   bIgnoreEvent = #True
;                   debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent) + ", bIgnoreEvent=" + strB(bIgnoreEvent))
;               EndSelect
            EndIf
            
            If bIgnoreEvent = #False
              Select gnEventType
                Case #PB_EventType_MouseEnter
                  CompilerIf #c_new_button
                    If gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_BUTTON2
                      debugMsg0(sProcName, "MouseEnter " + getGadgetName(gnEventGadgetNo) + " button")
                    EndIf
                  CompilerEndIf
                  
                Case #PB_EventType_MouseLeave
                  CompilerIf #c_new_button
                    If gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_BUTTON2
                      debugMsg0(sProcName, "MouseLeave " + getGadgetName(gnEventGadgetNo) + " button")
                    EndIf
                  CompilerEndIf
                  
                Case #PB_EventType_Focus
                  gnMainThreadLabel = #PB_Compiler_Line
                  ; debugMsg(sProcName, "G" + gnEventGadgetNo + " Focus")
                  If (gnValidateGadgetNo > 0) And (gnValidateGadgetNo <> gnEventGadgetNo)
                    If IsGadget(gnEventGadgetNo)
                      If GadgetType(gnEventGadgetNo) = #PB_GadgetType_String
                        ; ignore Focus event on a String gadget if processing a validation error
                        debugMsg(sProcName, "ignoring Focus event on String Gadget G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) +
                                            "), gnValidateGadgetNo=G" + gnValidateGadgetNo + "(" + getGadgetName(gnValidateGadgetNo) + ")")
                        gnMainThreadContinueLine = #PB_Compiler_Line
                        Continue
                      ElseIf GadgetType(gnEventGadgetNo) = #PB_GadgetType_ComboBox
                        ; ignore Focus event on a ComboBox gadget if processing a validation error
                        debugMsg(sProcName, "ignoring Focus event on ComboBox Gadget G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) +
                                            "), gnValidateGadgetNo=G" + gnValidateGadgetNo + "(" + getGadgetName(gnValidateGadgetNo) + ")")
                        gnMainThreadContinueLine = #PB_Compiler_Line
                        Continue
                      EndIf
                    EndIf
                  EndIf
                  If gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_STRING_ENTERABLE
                    ; debugMsg(sProcName, "calling selectWholeField(G" + gnEventGadgetNo + ")")
                    selectWholeField(gnEventGadgetNo)
                  EndIf
                  
                Case #PB_EventType_LostFocus
                  gnMainThreadLabel = #PB_Compiler_Line
                  If GetActiveGadget() = gnEventGadgetNo
                    If GadgetType(gnEventGadgetNo) = #PB_GadgetType_String
                      ; ignore LostFocus event on a String gadget if focus hasn't moved - avoids possible loop on throwing error if trying to navigate to a different node
                      ; debugMsg(sProcName, "ignoring LostFocus event on String Gadget G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + ")")
                      ; Debug sProcName + ": ignoring LostFocus event on String Gadget G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + ")"
                      gnMainThreadContinueLine = #PB_Compiler_Line
                      Continue
                    ElseIf GadgetType(gnEventGadgetNo) = #PB_GadgetType_ComboBox
                      ; ignore LostFocus event on a ComboBox gadget if focus hasn't moved - avoids possible loop on throwing error if trying to navigate to a different node
                      debugMsg(sProcName, "ignoring LostFocus event on ComboBox Gadget G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + ")")
                      gnMainThreadContinueLine = #PB_Compiler_Line
                      Continue
                    EndIf
                  EndIf
                  
                Case #PB_EventType_Change
                  gnMainThreadLabel = #PB_Compiler_Line
                  ; GENERAL INFO: #PB_EventType_Change is only raised if the USER changes the gadget, eg types into a string, NOT if the gadget is 'changed' by program
                  Select gaGadgetProps(gnEventGadgetPropsIndex)\nGType
                    Case #SCS_GTYPE_STRING_ENTERABLE, #SCS_GTYPE_STRING_NO_SELECT_WHOLE_FIELD
                      ; must call applyUpperCase() if necessary BEFORE calling applyValidChars() as the ValidChars may not allow for lower case characters in an 'uppercase' field
                      If gaGadgetProps(gnEventGadgetPropsIndex)\bUpperCase
                        applyUpperCase(gnEventGadgetNo)
                      EndIf
                      If gaGadgetProps(gnEventGadgetPropsIndex)\bValidCharsPresent
                        applyValidChars(gnEventGadgetNo, gaGadgetProps(gnEventGadgetPropsIndex)\sValidChars)
                      EndIf
                      gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd = #True
                      ; debugMsg0(sProcName, "gaGadgetProps(" + gnEventGadgetPropsIndex + ")\bValidationReqd=" + strB(gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd))
                      gnValidateGadgetNo = gnEventGadgetNo
                      gnValidateSubPtr = nEditSubPtr
                      If IsGadget(WED\tvwProdTree)
                        gnValidateProdTreeGadgetState = GGS(WED\tvwProdTree)
                      EndIf
                  EndSelect
                  
              EndSelect
              
              gnMainThreadLabel = #PB_Compiler_Line
              If gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_CHECKBOX2 ; INFO \nGType = #SCS_GTYPE_CHECKBOX2
                bCheckBoxClickOrEquivalent = #False
                Select gnEventType
                  Case #PB_EventType_LeftClick
                    gnMainThreadLabel = #PB_Compiler_Line
                    ; user has clicked on an owner-drawn checkbox, so change the visual state of the checkbox before passing an event thru
                    bCheckBoxClickOrEquivalent = #True
;                   Case #PB_EventType_Focus
;                     bMonitorCheckBoxKeyboardKey = #True
;                     Debug "Focus"
;                   Case #PB_EventType_KeyDown
;                     bMonitorCheckBoxKeyboardKey = #True
;                     Debug "KeyDown"
;                   Case #PB_EventType_KeyUp
;                     bMonitorCheckBoxKeyboardKey = #False
;                     Debug "KeyUp"
                  Case #PB_EventType_Input  ; this test and associated code added 23Nov2018 11.8.0ay
                    gnMainThreadLabel = #PB_Compiler_Line
                    If Chr(GetGadgetAttribute(gnEventGadgetNo, #PB_Canvas_Input)) = " "
                      ; space pressed
;                       If bMonitorCheckBoxKeyboardKey
                        bCheckBoxClickOrEquivalent = #True
;                         Debug " Space pressed"
;                         bMonitorCheckBoxKeyboardKey = #False
;                       EndIf
                    EndIf
                  Default
                    gnMainThreadLabel = #PB_Compiler_Line
                    ; ignore all other canvas event types
                    gnMainThreadContinueLine = #PB_Compiler_Line
                    Continue
                EndSelect
                gnMainThreadLabel = #PB_Compiler_Line
                If bCheckBoxClickOrEquivalent
                  With gaGadgetProps(gnEventGadgetPropsIndex)
                    If \bEnabled
                      Select \nState
                        Case #PB_Checkbox_Unchecked
                          \nState = #PB_Checkbox_Checked
                        Case #PB_Checkbox_Checked
                          \nState = #PB_Checkbox_Unchecked
                        Case #PB_Checkbox_Inbetween
                          \nState = #PB_Checkbox_Checked
                      EndSelect
                      drawCheckBoxGadget2(gnEventGadgetNo)
                    Else
                      ; ignore event if checkbox is not enabled
                      gnMainThreadContinueLine = #PB_Compiler_Line
                      Continue
                    EndIf
                  EndWith
                EndIf
                
              ElseIf gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_OPTION2 ; INFO \nGType = #SCS_GTYPE_OPTION2
                gnMainThreadLabel = #PB_Compiler_Line
                Select gnEventType
                  Case #PB_EventType_LeftClick
                    ; user has clicked on an owner-drawn checkbox, so change the visual state of the checkbox before passing an event thru
                    With gaGadgetProps(gnEventGadgetPropsIndex)
                      If \bEnabled
                        \nState = 1
                        drawOptionGadget2(gnEventGadgetNo)
                        clearOtherOptionGadget2s(gnEventGadgetNo, gnEventGadgetPropsIndex)
                      Else
                        ; ignore event if checkbox is not enabled
                        gnMainThreadContinueLine = #PB_Compiler_Line
                        Continue
                      EndIf
                    EndWith
                  Default
                    ; ignore all other canvas event types as they have no equivalent for checkboxes
                    gnMainThreadContinueLine = #PB_Compiler_Line
                    Continue
                EndSelect
                
              ElseIf gaGadgetProps(gnEventGadgetPropsIndex)\nGType = #SCS_GTYPE_BUTTON2 ; INFO \nGType = #SCS_GTYPE_BUTTON2
                bButtonClickOrEquivalent = #False
                ; debugMsg(sProcName, "gnEventType=" + decodeEventType())
                Select gnEventType
                  Case #PB_EventType_LeftClick
                    gnMainThreadLabel = #PB_Compiler_Line
                    ; user has clicked on an owner-drawn button, so change the visual state of the button before passing an event thru
                    bButtonClickOrEquivalent = #True
                  Case #PB_EventType_MouseEnter
                  Case #PB_EventType_MouseLeave
                    
;                   Case #PB_EventType_Focus
;                     bMonitorButtonKeyboardKey = #True
;                     Debug "Focus"
;                   Case #PB_EventType_KeyDown
;                     bMonitorButtonKeyboardKey = #True
;                     Debug "KeyDown"
;                   Case #PB_EventType_KeyUp
;                     bMonitorButtonKeyboardKey = #False
;                     Debug "KeyUp"
;                   Case #PB_EventType_Input  ; this test and associated code added 23Nov2018 11.8.0ay
;                     gnMainThreadLabel = #PB_Compiler_Line
;                     If Chr(GetGadgetAttribute(gnEventGadgetNo, #PB_Canvas_Input)) = " "
;                       ; space pressed
; ;                       If bMonitorButtonKeyboardKey
;                         bButtonClickOrEquivalent = #True
; ;                         Debug " Space pressed"
; ;                         bMonitorButtonKeyboardKey = #False
; ;                       EndIf
;                     EndIf
                  Default
                    gnMainThreadLabel = #PB_Compiler_Line
                    ; ignore all other canvas event types
                    gnMainThreadContinueLine = #PB_Compiler_Line
                    Continue
                EndSelect
                gnMainThreadLabel = #PB_Compiler_Line
                If bButtonClickOrEquivalent
                  With gaGadgetProps(gnEventGadgetPropsIndex)
                    If \bEnabled
;                       Select \nState
;                         Case #PB_Checkbox_Unchecked
;                           \nState = #PB_Checkbox_Checked
;                         Case #PB_Checkbox_Checked
;                           \nState = #PB_Checkbox_Unchecked
;                         Case #PB_Checkbox_Inbetween
;                           \nState = #PB_Checkbox_Checked
;                       EndSelect
                      drawButtonGadget2(gnEventGadgetNo)
                    Else
                      ; ignore event if button is not enabled
                      gnMainThreadContinueLine = #PB_Compiler_Line
                      Continue
                    EndIf
                  EndWith
                Else
                  ; ignore further processing for this event if not 'button clicked'
                  gnMainThreadContinueLine = #PB_Compiler_Line
                  Continue
                EndIf
                
              EndIf
              gnMainThreadLabel = #PB_Compiler_Line
              
            EndIf
            
          Else  ; gnEventGadgetNo < #SCS_GADGET_BASE_NO (eg gnEventGadgetNo = -1)
            bIgnoreEvent = #True
            
          EndIf
          If gnDisableEventCheckingForGadgetNo <> 0
            If gnDisableEventCheckingForGadgetNo = gnEventGadgetNo
              debugMsg(sProcName, "ignoring event type " + decodeEventType(gnEventGadgetNo) + " for gadget " + getGadgetName(gnEventGadgetNo))
              bIgnoreEvent = #True
            Else
              bIgnoreEvent = #False
              debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", so clearing gnDisableEventCheckingForGadgetNo(was " + getGadgetName(gnDisableEventCheckingForGadgetNo) + ")")
              gnDisableEventCheckingForGadgetNo = 0
            EndIf
          EndIf
          gnMainThreadLabel = #PB_Compiler_Line
          
        Case #PB_Event_GadgetDrop
          gnMainThreadLabel = #PB_Compiler_Line
          ; gadget drop event
          ; debugMsg(sProcName, "Gadget Drop event")
          ; debugMsg(sProcName,"gnWindowEvent=" + decodeEvent(gnWindowEvent) + ", gnEventWindowNo=" + gnEventWindowNo + ", gnEventGadgetNo=G" + gnEventGadgetNo)
          If gnEventGadgetNo >= #SCS_GADGET_BASE_NO
            gnEventGadgetPropsIndex = gnEventGadgetNo - #SCS_GADGET_BASE_NO
            With gaGadgetProps(gnEventGadgetPropsIndex)
              gnEventGadgetNoForEvHdlr = \nGadgetNoForEvHdlr
              gnEventGadgetType = \nGType
              gnEventGadgetArrayIndex = \nArrayIndex
              gnEventCuePanelNo = \nCuePanelNo
              gnEventSliderNo = \nSliderNo
              gnEventButtonId = \nToolBarBtnId
              logKeyEvent(decodeEvent(gnWindowEvent) + " " + \sGWindow + "\" + \sName + ": " + decodeEventType(gnEventGadgetNo))
            EndWith
            
          Else  ; gnEventGadgetNo < #SCS_GADGET_BASE_NO (eg gnEventGadgetNo = -1)
            bIgnoreEvent = #True
            
          EndIf
          
        Case #PB_Event_CloseWindow
          gnMainThreadLabel = #PB_Compiler_Line
          ; added gbLastVALResult test 7Apr2017 11.6.1ad following tests that found that closing #WMN when there's an error in a field in the editor
          ; would correctly report the error but on acknowledging the error message #WMN and SCS would be closed anyway.
          ; this new global variable is set or cleared in the macros ETVAL() and ETVAL2()
          If gbLastVALResult = #False
            debugMsg(sProcName, "ignoring #PB_Event_CloseWindow because gbLastVALResult=#False")
            bIgnoreEvent = #True
            SAG(-1) ; helps force a re-validation if the user just re-clicks the close window button
          Else
            logKeyEvent("#PB_Event_CloseWindow: " + decodeWindow(EventWindow()))
            ; Added 30Aug2021 11.8.6af after finding that closing #WEM when the slider has focus wouldn't close the window because gnEventGadgetNo was still set
            gnEventGadgetNo = 0
            gnEventSliderNo = 0
            gnEventButtonId = 0
            ; End added 30Aug2021 11.8.6af
          EndIf
          
        Case #PB_Event_MinimizeWindow, #PB_Event_MaximizeWindow, #PB_Event_RestoreWindow, #PB_Event_SizeWindow, #PB_Event_MoveWindow  ; selected window events
;           gnMainThreadLabel = #PB_Compiler_Line
;           logKeyEvent(decodeEvent(gnWindowEvent) + ": " + decodeWindow(EventWindow()))
          
        Case #PB_Event_Menu ; #PB_Event_Menu
          gnMainThreadLabel = #PB_Compiler_Line
          logKeyEvent(decodeEvent(gnWindowEvent) + ": " + decodeMenuItem(EventMenu()))
          
        Case #PB_Event_Timer  ; #PB_Event_Timer
          gnEventGadgetNo = 0
          gnEventSliderNo = 0
          gnEventButtonId = 0
          If EventTimer() = #SCS_TIMER_VU_METERS
            If gbRefreshVUDisplay And gbClosingDown = #False
              If gbUseBASS  ; BASS
                updateSpectrumBASS()
              Else  ; SM-S
                updateSpectrumSMS()
              EndIf
              If grTVGControl\bDisplayVUMeters
                updateSpectrumTVG()
              EndIf  
              drawVUDisplay()
            EndIf
          EndIf

          ; added 26Oct2016 11.5.2.4
        Case #WM_RBUTTONDOWN, #WM_NCRBUTTONDOWN, #WM_KEYDOWN, #WM_SYSKEYDOWN, #WM_KEYUP, #WM_SYSKEYUP
          ; debugMsg0(sProcName, "WM_.........................")
          gnMainThreadLabel = #PB_Compiler_Line
          If EventWindow() <> GetActiveWindow()
            ; nb the above test may be true for #WM... events if a window timer is running (EventWindow may be the window that had the timer added)
            ; debugMsg(sProcName, "re-posting " + decodeEvent(gnWindowEvent) + " with correct window (EventWindow=" + decodeWindow(EventWindow()) + ")")
            ; debugMsg0(sProcName, "PostEvent(" + decodeEvent(gnWindowEvent) + ", " + decodeWindow(GetActiveWindow()) + ", " + GetActiveGadget() + ")")
            PostEvent(gnWindowEvent, GetActiveWindow(), GetActiveGadget())
            bIgnoreEvent = #True
          EndIf
          ; end added 26Oct2016 11.5.2.4
          
        Case #WM_SYSTIMER, #WM_PAINT ; Added 23Sep2023 11.10.0
          bIgnoreEvent = #True
          
          ; SCS Events
        Case #SCS_Event_CollectThreadEnd
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_CollectThreadEnd, gnEventWindowNo=" + decodeWindow(gnEventWindowNo))
          debugMsg(sProcName, "calling updateAllGridFileInfo()")
          updateAllGridFileInfo()
          
        Case #SCS_Event_DrawLTC
          gnMainThreadLabel = #PB_Compiler_Line
          bCalledFromDrawVUDisplay = #False
          ; debugMsg(sProcName, "calling drawLTCSend(" + strB(bCalledFromDrawVUDisplay) + ")")
          ; nEventData = EventData()
          ; drawLTCSend(nEventData, bCalledFromDrawVUDisplay)
          ; debugMsg(sProcName, "calling drawLTCSend(" + strB(bCalledFromDrawVUDisplay) + ")")
          drawLTCSend(bCalledFromDrawVUDisplay)
          
        Case #SCS_Event_DrawMTC
          gnMainThreadLabel = #PB_Compiler_Line
          nEventData = EventData()
          bCalledFromDrawVUDisplay = #False
          bCalledFromSendMTCQuarterFrames = #False
          If nEventData & 1
            bCalledFromDrawVUDisplay = #True
          EndIf
          If nEventData & 2
            bCalledFromSendMTCQuarterFrames = #True
          EndIf
          ; debugMsg(sProcName, "calling drawMTCSend(" + strB(bCalledFromDrawVUDisplay) + ", " + strB(bCalledFromSendMTCQuarterFrames) + ")")
          drawMTCSend(bCalledFromDrawVUDisplay, bCalledFromSendMTCQuarterFrames)
          
        Case #SCS_Event_GoButton
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_GoButton calling goIfOK()")
          goIfOK()
          
        Case #SCS_Event_GoConfirm
          gnMainThreadLabel = #PB_Compiler_Line
          nEventData = EventData()
          debugMsg(sProcName, "#SCS_Event_GoConfirm calling confirmGo(" + nEventData + ")")
          confirmGo(nEventData)
          
        Case #SCS_Event_GoTo_End_Cue
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_GoTo_End_Cue calling WMN_EndCue()")
          WMN_EndCue()
          
        Case #SCS_Event_GoTo_Next_Cue
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_GoTo_Next_Cue calling WMN_NextCue()")
          WMN_NextCue()
          
        Case #SCS_Event_GoTo_Prev_Cue
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_GoTo_Prev_Cue calling WMN_PrevCue()")
          WMN_PrevCue()
          
        Case #SCS_Event_GoTo_Top_Cue
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_GoTo_Top_Cue calling WMN_TopCue()")
          WMN_TopCue()
          
        Case #SCS_Event_M2T_Apply
          gnMainThreadLabel = #PB_Compiler_Line
          nDispPanel = EventData()
          ; debugMsg0(sProcName, "GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
          If GetActiveGadget() = gaPnlVars(nDispPanel)\txtMoveToTime
            bValidationResult = M2T_txtMoveToTime_Validate(nDispPanel)
          Else
            bValidationResult = #True
          EndIf
          If bValidationResult
            debugMsg(sProcName, "#SCS_Event_M2T_Apply calling M2T_btnMoveToTimeApply_Click(" + nDispPanel + ")")
            M2T_btnMoveToTimeApply_Click(nDispPanel)
          EndIf
          
        Case #SCS_Event_M2T_Cancel
          gnMainThreadLabel = #PB_Compiler_Line
          nDispPanel = EventData()
          debugMsg(sProcName, "#SCS_Event_M2T_Cancel calling M2T_btnMoveToTimeCancel_Click(" + nDispPanel + ")")
          M2T_btnMoveToTimeCancel_Click(nDispPanel)
          
        Case #SCS_Event_PlayCue
          gnMainThreadLabel = #PB_Compiler_Line
          gqPriorityPostEventWaiting = 0
          nCuePtr = EventData()
          debugMsg(sProcName, "#SCS_Event_PlayCue calling playCue(" + getCueLabel(nCuePtr) + ")")
          playCue(nCuePtr)
          ; aCue(nCuePtr)\bPlayCueEventPosted = #False ; Deleted 19Oct2022 11.9.6 - moved to setCueState() because all the sub-cues of the cue have not necessarily completed yet, so we now wait for the cue state to indicate completed
          
        Case #SCS_Event_PlayMidiCue
          gnMainThreadLabel = #PB_Compiler_Line
          sMidiCue = Str(EventData())
          debugMsg(sProcName, "#SCS_Event_PlayMidiCue calling playMidiCue('" + sMidiCue + "')")
          playMidiCue(sMidiCue)
          
        Case #SCS_Event_PlaySub
          gnMainThreadLabel = #PB_Compiler_Line
          gqPriorityPostEventWaiting = 0
          nSubPtr = EventData()
          debugMsg(sProcName, "#SCS_Event_PlaySub calling playSub(" + getSubLabel(nSubPtr) + ")")
          playSub(nSubPtr)
          
        Case #SCS_Event_Send_xremote_to_X32
          gnMainThreadLabel = #PB_Compiler_Line
          If grX32CueControl\nX32ClientConnection
            SendNetworkStringAscii(grX32CueControl\nX32ClientConnection, "/xremote")
            ; debugMsg(sProcName, "sent /xremote to network connection " + grX32CueControl\nX32ClientConnection)
          EndIf
          
        Case #SCS_Event_SetFaderAssignments
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_SetFaderAssignments calling setFaderAssignments()")
          setFaderAssignments()
          
        Case #SCS_Event_SetStandbyToolbarBtn
          gnMainThreadLabel = #PB_Compiler_Line
          nEventData = EventData()
          debugMsg(sProcName, "#SCS_Event_SetStandbyToolbarBtn calling WMN_setToolbarStandbyBtn(" + strB(nEventData) + ")")
          WMN_setToolbarStandbyBtn(nEventData)
          
        Case #SCS_Event_StartOrRestartTimeCodeForSub
          gnMainThreadLabel = #PB_Compiler_Line
          gqPriorityPostEventWaiting = 0
          nSubPtr = EventData()
          debugMsg(sProcName, "#SCS_Event_StartOrRestartTimeCodeForSub calling MTC_StartOrRestartTimeCodeForSub(" + getSubLabel(nSubPtr) + ")")
          MTC_StartOrRestartTimeCodeForSub(nSubPtr)
          
        Case #SCS_Event_StopAndEndSub ; added 1Sep2019 11.8.2ai
          gnMainThreadLabel = #PB_Compiler_Line
          gqPriorityPostEventWaiting = 0
          nSubPtr = EventData()
          debugMsg(sProcName, "#SCS_Event_StopAndEndSub calling stopSub(" + getSubLabel(nSubPtr) + ", 'ALL', #True, #False)")
          stopSub(nSubPtr, "ALL", #True, #False)
          debugMsg(sProcName, "#SCS_Event_StopAndEndSub calling endOfSub(" + getSubLabel(nSubPtr) + ", -1)")
          endOfSub(nSubPtr, -1)
          aSub(nSubPtr)\bStopSubEventPosted = #False
          
        Case #SCS_Event_StopEverything
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_StopEverything")
          ; Changed the following 22Apr2025 11.10.8ba
          ; stopEverythingPart1()
          processStopAll()
          
        Case #SCS_Event_TVG_RunPlayer
          gnMainThreadLabel = #PB_Compiler_Line
          ; debugMsg(sProcName, "#SCS_Event_TVG_RunPlayer")
          nEventData = EventData()
          TVG_RunPlayer(*gmVideoGrabber(nEventData))
          debugMsgT(sProcName, "TVG_RunPlayer(" + decodeHandle(*gmVideoGrabber(nEventData)) + ")")
          
        Case #SCS_Event_VSTGetData
          gnMainThreadLabel = #PB_Compiler_Line
          ; event posted by WPL_VSTEditorCallBack()
          WPL_getVSTData(EventData())
         
        Case #SCS_Event_WakeUp
          gnMainThreadLabel = #PB_Compiler_Line
          ; debugMsg(sProcName, "#SCS_Event_WakeUp")
          ; no further processing required
          
        Case #SCS_Event_Deadlock
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_Deadlock")
          nThreadNo = EventData()
          nMutexNo = nThreadNo & $FFFF
          nThreadNo >> 16
          Debug "#SCS_Event_Deadlock, nThreadNo=" + nThreadNo + ", nMutexNo=" + nMutexNo
          THR_displayDeadlockInfo(nThreadNo, nMutexNo, "Deadlock Detected")
          
        Case #SCS_Event_LockTimeOut
          gnMainThreadLabel = #PB_Compiler_Line
          debugMsg(sProcName, "#SCS_Event_LockTimeOut")
          nThreadNo = EventData()
          nMutexNo = nThreadNo & $FFFF
          nThreadNo >> 16
          Debug "#SCS_Event_LockTimeOut, nThreadNo=" + nThreadNo + ", nMutexNo=" + nMutexNo
          THR_displayDeadlockInfo(nThreadNo, nMutexNo, "Thread Lock TimeOut")
          
      EndSelect
      gnMainThreadLabel = #PB_Compiler_Line
      
      If bIgnoreEvent = #False
        Select gnEventWindowNo
          Case #WAB  ; fmAbout
            gnMainThreadLabel = #PB_Compiler_Line
            WAB_EventHandler()
          Case #WAC  ; fmAGColors
            gnMainThreadLabel = #PB_Compiler_Line
            WAC_EventHandler()
          Case #WBE  ; fmBulkEdit
            gnMainThreadLabel = #PB_Compiler_Line
            WBE_EventHandler()
          Case #WCD  ; fmCountdownClock
            gnMainThreadLabel = #PB_Compiler_Line
            WCD_EventHandler()
          Case #WCI  ; fmCurrInfo
            gnMainThreadLabel = #PB_Compiler_Line
            WCI_EventHandler()
          Case #WCL  ; fmClock
            gnMainThreadLabel = #PB_Compiler_Line
            WCL_EventHandler()
          Case #WCM  ; fmCtrlSetup
            gnMainThreadLabel = #PB_Compiler_Line
            WCM_EventHandler()
          Case #WCN  ; fmControllers
            gnMainThreadLabel = #PB_Compiler_Line
            WCN_EventHandler()
          Case #WCP  ; fmCopyProps
            gnMainThreadLabel = #PB_Compiler_Line
            WCP_EventHandler()
          Case #WCS  ; fmColorScheme
            gnMainThreadLabel = #PB_Compiler_Line
            WCS_EventHandler()
          Case #WDD  ; fmDMXDisplay
            gnMainThreadLabel = #PB_Compiler_Line
            WDD_EventHandler()
          Case #WDT  ; fmDMXTest
            gnMainThreadLabel = #PB_Compiler_Line
            WDT_EventHandler()
          Case #WE1 To #WE2  ; fmMemo
            gnMainThreadLabel = #PB_Compiler_Line
            WEN_EventHandler()
          Case #WED  ; fmEditor
            gnMainThreadLabel = #PB_Compiler_Line
            WED_EventHandler()
          Case #WEM  ; fmEditModal
            gnMainThreadLabel = #PB_Compiler_Line
            WEM_EventHandler()
          Case #WES  ; fmScribbleStrip
            gnMainThreadLabel = #PB_Compiler_Line
            WES_EventHandler()
          Case #WEV  ; fmEditVal
            gnMainThreadLabel = #PB_Compiler_Line
          Case #WEX  ; fmExport
            gnMainThreadLabel = #PB_Compiler_Line
            WEX_EventHandler()
          Case #WFF  ; fmFavFiles
            gnMainThreadLabel = #PB_Compiler_Line
            WFF_EventHandler()
          Case #WFI  ; fmFind
            gnMainThreadLabel = #PB_Compiler_Line
            WFI_EventHandler()
          Case #WFL  ; fmFileLocator
            gnMainThreadLabel = #PB_Compiler_Line
            WFL_EventHandler()
          Case #WFO  ; fmFileOpener
            gnMainThreadLabel = #PB_Compiler_Line
            WFO_EventHandler()
          Case #WFR  ; fmFileRename
            gnMainThreadLabel = #PB_Compiler_Line
            WFR_EventHandler()
          Case #WFS  ; fmFavFileSelector
            gnMainThreadLabel = #PB_Compiler_Line
            WFS_EventHandler()
          Case #WIC  ; fmImportCSV
            gnMainThreadLabel = #PB_Compiler_Line
            WIC_EventHandler()
          Case #WID  ; fmImportDevs
            gnMainThreadLabel = #PB_Compiler_Line
            WID_EventHandler()
          Case #WIM  ; fmImport
            gnMainThreadLabel = #PB_Compiler_Line
            WIM_EventHandler()
          Case #WIR  ; fmInputRequester
            gnMainThreadLabel = #PB_Compiler_Line
            WIR_EventHandler()
          Case #WLC  ; fmLabelChange
            gnMainThreadLabel = #PB_Compiler_Line
            WLC_EventHandler()
          Case #WLD  ; fmLinkDevices
            gnMainThreadLabel = #PB_Compiler_Line
            CompilerIf #c_cuepanel_multi_dev_select
              WLD_EventHandler()
            CompilerEndIf
          Case #WLE  ; fmLockEditor
            gnMainThreadLabel = #PB_Compiler_Line
            WLE_EventHandler()
          Case #WLP ; fmLoadProd
            gnMainThreadLabel = #PB_Compiler_Line
            WLP_EventHandler()
          Case #WM2 To #WM_LAST  ; fmMonitor
            gnMainThreadLabel = #PB_Compiler_Line
            WMO_EventHandler()
          Case #WMC  ; fmMultiCueCopyEtc
            gnMainThreadLabel = #PB_Compiler_Line
            WMC_EventHandler()
          Case #WMN  ; fmMain
            gnMainThreadLabel = #PB_Compiler_Line
            WMN_EventHandler()
          Case #WMT  ; fmMidiTest
            gnMainThreadLabel = #PB_Compiler_Line
            WMT_EventHandler()
          Case #WNE  ; fmNearEndWarning
            gnMainThreadLabel = #PB_Compiler_Line
            WNE_EventHandler()
          Case #WOC  ; fmOSCCapture
            gnMainThreadLabel = #PB_Compiler_Line
            WOC_EventHandler()
          Case #WOP  ; fmOptions
            gnMainThreadLabel = #PB_Compiler_Line
            WOP_EventHandler()
          Case #WPF  ; fmCollectFiles
            gnMainThreadLabel = #PB_Compiler_Line
            WPF_EventHandler()
          Case #WPL  ; VST Plugin Window
            gnMainThreadLabel = #PB_Compiler_Line
            WPL_EventHandler()
          Case #WPR  ; fmPrintCueList
            gnMainThreadLabel = #PB_Compiler_Line
            WPR_EventHandler()
          Case #WPT  ; fmProdTimer
            gnMainThreadLabel = #PB_Compiler_Line
            WPT_EventHandler()
          Case #WRG  ; fmRegister
            gnMainThreadLabel = #PB_Compiler_Line
            WRG_EventHandler()
          Case #WSP  ; fmSplash
            gnMainThreadLabel = #PB_Compiler_Line
            WSP_EventHandler()
          Case #WTC  ; fmMTCDisplay
            gnMainThreadLabel = #PB_Compiler_Line
            WTC_EventHandler()
          Case #WTI  ; fmTimerDisplay
            gnMainThreadLabel = #PB_Compiler_Line
            WTI_EventHandler()
          Case #WTM  ; fmTemplates
            gnMainThreadLabel = #PB_Compiler_Line
            WTM_EventHandler()
          Case #WTP  ; fmTimeProfile
            gnMainThreadLabel = #PB_Compiler_Line
            WTP_EventHandler()
          Case #WUP
            gnMainThreadLabel = #PB_Compiler_Line
            WUP_EventHandler()
          Case #WV2 To #WV_LAST  ; fmVideo
            gnMainThreadLabel = #PB_Compiler_Line
            WVN_EventHandler()
          Case #WVP  ; fmVSTPlugins
            gnMainThreadLabel = #PB_Compiler_Line
            WVP__EventHandler()
        EndSelect
        
      EndIf
      
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gqPriorityPostEventWaiting > 0
      ; Important note regarding gqPriorityPostEventWaiting (added 8Mar2020 11.8.2.2bg):
      ;  Where gqPriorityPostEventWaiting is to be set for a PostEvent, eg "PostEvent(#SCS_Event_PlayCue, ...)", gqPriorityPostEventWaiting must be set BEFORE calling PostEvent.
      ;  When this 'PriorityPostEventWaiting' code was first added, the setting of this indicator (which originally was a boolean) was applied AFTER the call to PostEvent.
      ;  Although that was the logical place for it to occur, some users reported freezes, particularly Dave Korman who supplied many logs. What I eventually realised was that
      ;  sometimes the requested event (eg #SCS_Event_PlayCue) was actually actioned immediately, PRIOR to the setting of the PriorityPostEventWaiting flag. The actual event
      ;  processing (eg for #SCS_Event_PlayCue) then cleared the flag (even though it was still clear). A fraction of a millisecond later, the calling process then SET the flag,
      ;  even though that event processing had already started or even finished.
      ;  The result of this was that the PriorityPostEventWaiting flag remained set even though there was no longer a priority event waiting. This caused the original code below to
      ;  'Continue' the main loop, effectively preventing any later code in this Procedure from being processed, the most notable omission being the call to samProcess.
      ;  There were two possible solutions to this that I considered. The one I have implemented is to ensure the setting of the PriorityPostEventWaiting flag is set BEFORE the
      ;  PostEvent call, so the event processing will never occur before the original setting of the flag. The other solution would have been to use a Mutex to lock together the
      ;  PostEvent call and the setting of the flag, and to use that same Mutex in the code below when accessing that flag.
      If (ElapsedMilliseconds() - gqPriorityPostEventWaiting) > 500
        ; 'priority' post has been waiting for more than 0.5 second, so this may be the freeze problem reported by Dave Korman, so cancel the wait;
        ; NB the 0.5 second fail-safe processing was added prior to my realisation that the problem was caused as explained above. However, I decided to retain this fail-safe test,
        ; eben though I don't expect this to ever occur.
        debugMsg(sProcName, "Cancelling gqPriorityPostEventWaiting. Was " + traceTime(gqPriorityPostEventWaiting))
        gqPriorityPostEventWaiting = 0
      Else
        ; A priority event is waiting to be processed, so suspend other operations in this loop until that event has been processed.
        gnMainThreadContinueLine = #PB_Compiler_Line
        Continue
      EndIf
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If (grMTCControl\nMaxCueOrSubForMTC >= 0) And (gbMidiTestWindow = #False)
      If checkArrayCueOrSubForMTC()
        debugMsg(sProcName, "grMTCControl\sTxt=" + grMTCControl\sTxt + ", gaMidiControl(" + grMTCControl\nMidiPhysicalDevPtr + ")\nStatusType=" + gaMidiControl(grMTCControl\nMidiPhysicalDevPtr)\nStatusType)
        If grMTCControl\sTxt
          With gaMidiControl(grMTCControl\nMidiPhysicalDevPtr)
            \sStatusField = " MIDI IN  " + grMTCControl\sMidiInName + ": " + grMTCControl\sTxt
            \nStatusType = #SCS_STATUS_INFO
            WMN_setStatusField(\sStatusField, \nStatusType)
          EndWith
        EndIf
      EndIf
    EndIf
    gnMainThreadLabel = #PB_Compiler_Line
    
    CompilerIf #c_vMix_in_video_cues
      If grvMixControl\nConnection
        scsTryLockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND, 2702)
        If bLockedMutex
          If NetworkClientEvent(grvMixControl\nConnection) = #PB_NetworkEvent_Data
            vMix_GetData(sProcName) ;, #True) ; do not trace as this will include tracing data like "ACTS OK InputVolume..." of which there could be many
          EndIf
          If grvMixInfo\nMaxIncomingMsg >= 0
            vMix_ProcessIncomingMessages(#True)
          EndIf
          If grvMixInfo\nMaxInputKeyToRemoveWhenvMixIdle >= 0
            If vMix_CheckActive() = #False
              debugMsg(sProcName, "calling vMix_RemoveRequestedInputs(" + strB(#True) + ")")
              vMix_RemoveRequestedInputs(#True)
            EndIf
          EndIf
          scsUnlockMutex(gnvMixSendMutex, #SCS_MUTEX_VMIX_SEND)
        EndIf
      EndIf
    CompilerEndIf
    
    If gnMidiInCount > 0
      gnMainThreadLabel = #PB_Compiler_Line
      doMidiIn_Proc()
    EndIf
    
    If gnRS232InCount > 0
      gnMainThreadLabel = #PB_Compiler_Line
      doRS232In_Proc()
    EndIf
    
    If grDMX\bReceiveDMX Or grDMX\bCaptureDMX
      scsTryLockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE, 929)
      If bLockedMutex
        If grDMX\nDMXInCount > 0
          DMX_doDMXIn_Proc()
        EndIf
        scsUnlockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE)
      EndIf
    EndIf
    gnMainThreadLabel = #PB_Compiler_Line
    
    ; Added 24Jun2021 11.8.5an to replace calls to DMX_displayDMXSendData() that were occurring in the DMX Send Thread (causing locking issues)
    If grDMX\bCallDisplayDMXSendData
      gnMainThreadLabel = #PB_Compiler_Line
      DMX_displayDMXSendData()
    EndIf
    ; End added 24Jun2021 11.8.5an
    
    ; Added 13Jul2022 11.9.4
    If WCN\bRefreshDimmerChannelFaders
      gnMainThreadLabel = #PB_Compiler_Line
      WCN_refreshDimmerChannelFaders()
    EndIf
    ; End added 13Jul2022 11.9.4
    
    ; Added 21Sep2023 11.10.0
    If WCN\bRefreshAudioChannelFaders
      gnMainThreadLabel = #PB_Compiler_Line
      WCN_refreshAudioChannelFaders()
    EndIf
    ; End added 21Sep2023 11.10.0
    
    If gqMainThreadRequest <> 0
      gnMainThreadLabel = #PB_Compiler_Line
      doMainThreadRequests()
      gnMainThreadLabel = #PB_Compiler_Line
    EndIf
    
    If gbCheckForPrimeVideoReqd
      ; debugMsg(sProcName, "calling checkForPrimeVideoReqd()")
      gnMainThreadLabel = #PB_Compiler_Line
      checkForPrimeVideoReqd()
      gnMainThreadLabel = #PB_Compiler_Line
    EndIf
    
    If grMain\nCasRequestsWaiting > 0
      ; debugMsg(sProcName, "grMain\nCasRequestsWaiting=" + grMain\nCasRequestsWaiting)
      gnMainThreadLabel = #PB_Compiler_Line
      casProcess()
      gnMainThreadLabel = #PB_Compiler_Line
      ; debugMsg(sProcName, "returned from casProcess")
    EndIf
    
    If gbLogInfoForSam
      debugMsg(sProcName, "grMain\nSamRequestsWaiting=" + grMain\nSamRequestsWaiting + ", grMain\bControlThreadWaiting=" + strB(grMain\bControlThreadWaiting))
    EndIf
    If (grMain\nSamRequestsWaiting > 0) And (grMain\bControlThreadWaiting = #False)
      ; debugMsg(sProcName, "grMain\nSamRequestsWaiting=" + grMain\nSamRequestsWaiting)
      ; If grDMX\bDMXReadyToSend = #False ; (temp test added 8Apr2017 11.6.1ae for Peter Hawkins, to block SAM processing while DMX fades etc are occurring)
      gnMainThreadLabel = #PB_Compiler_Line
      samProcess()
      gnMainThreadLabel = #PB_Compiler_Line
      ; EndIf
      ; debugMsg(sProcName, "returned from samProcess")
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbResetTOD
      gbResetTOD = #False
      resetTOD()
    EndIf
    
    ; Added 21Jan2022 11.9.0rc3
    If gbGoIfOk
      gbGoIfOk = #False
      goIfOK()
    EndIf
    ; End added 21Jan2022 11.9.0rc3
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbCallPrimeSplash
      gbCallPrimeSplash = #False
      WSP_Form_Load()
      WSP_primeSplash()
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbCallEditor
      gbCallEditor = #False
      ; call editor from this (main) thread, so that the events are processed in this same WaitWindowEvent() loop
      debugMsg(sProcName, "calling callEditor(" + getCueLabel(gnCallEditorCuePtr) + ")")
      callEditor(gnCallEditorCuePtr)
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If grMTCSendControl\bMTCSendRefreshDisplay
      If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
        ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay) + ", calling drawMTCSend(#False)")
        gnMainThreadLabel = #PB_Compiler_Line
        If grMTCSendControl\nMTCType = #SCS_MTC_TYPE_MTC
          ; debugMsg(sProcName, "calling drawMTCSend(#False)")
          drawMTCSend(#False)
        ElseIf grMTCSendControl\nMTCType = #SCS_MTC_TYPE_LTC
          ; debugMsg(sProcName, "calling drawLTCSend(#False)")
          drawLTCSend(#False)
        EndIf
      EndIf
    ElseIf grMTCControl\bMTCControlActive
      gnMainThreadLabel = #PB_Compiler_Line
      drawMTCReceive(#False)
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gnFocusGadgetNo
      nActiveGadgetNo = GetActiveGadget()
      debugMsg(sProcName, "gnFocusGadgetNo=" + getGadgetName(gnFocusGadgetNo) + ", nActiveGadgetNo=" + getGadgetName(nActiveGadgetNo))
      If nActiveGadgetNo <> gnFocusGadgetNo
        SetActiveGadget(gnFocusGadgetNo)
      EndIf
      gnFocusGadgetNo = 0
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbMoviePlaying
      checkMoviesToBeCleared()
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gnSplitterMoving > 0
      ; Debug "gnSplitterMoving=" + gnSplitterMoving + ", isLeftMouseButtonDown()=" + isLeftMouseButtonDown()
      If isLeftMouseButtonDown() = #False
        processSplitterRepositioned(gnSplitterMoving, #True)
        gnSplitterMoving = 0
      EndIf
    EndIf
    
    ; added 6Jun2019 11.8.1.1an to update grid layout memory after dragging a column to a new position, or resizing a column - see also WMN_callback_cues()
    gnMainThreadLabel = #PB_Compiler_Line
    If grMain\bDoSaveGridLayout
      If isLeftMouseButtonDown() = #False
        debugMsg(sProcName, "calling updateGridInfoFromPhysicalLayout(@grOperModeOptions(" + gnOperMode + ")\rGrdCuesInfo)")
        updateGridInfoFromPhysicalLayout(@grOperModeOptions(gnOperMode)\rGrdCuesInfo)
        grMain\bDoSaveGridLayout = #False
      EndIf
    EndIf
    ; end added 6Jun2019 11.8.1.1an
    
    ; added 19Oct2019 11.8.2bb following a test run that crashed during closedown because a procedure was trying to save data to the temp database, which had been closed
    gnMainThreadLabel = #PB_Compiler_Line
    If gbClosingDown
      Break
    EndIf
    ; end added 19Oct2019 11.8.2bb
    
    gnMainThreadLabel = #PB_Compiler_Line
    WMN_displayProdTimer()
    
    gnMainThreadLabel = #PB_Compiler_Line
    If grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase
      debugMsg(sProcName, "calling saveMG34SlicePeakAndMinArraysToTempDatabase(@grMG4)")
      saveMG34SlicePeakAndMinArraysToTempDatabase(@grMG4)
      grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase = #False
      debugMsg(sProcName, "grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase=" + strB(grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase))
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If grMG2\bInGetData Or grMG2\bInLoadSlicePeakAndMin
      drawProgressBar(@grMG2)
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If (gbProcessSliderLoadFileRequests) And (gbProcessSliderLoadFileRequestIssued = #False)
      ; debugMsg(sProcName, "calling SLD_processOneLoadFileRequest()")
      debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_LOAD_SLIDER_AUDIO_FILE, -1, 0, 0, '', " + traceTime(ElapsedMilliseconds()+200) + ")")
      samAddRequest(#SCS_SAM_LOAD_SLIDER_AUDIO_FILE, -1, 0, 0, "", ElapsedMilliseconds()+200)
      gbProcessSliderLoadFileRequestIssued = #True
    EndIf
    gnMainThreadLabel = #PB_Compiler_Line
    If gnReloadSldCount > 0
      If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\nThreadState <> #SCS_THREAD_STATE_ACTIVE ; added this test 8Feb2020 11.8.2.2ai to prevent the main thread being suspended by resetGraphView() when preparing audio graphs
        SLD_reloadSlidersWhereRequested()
      EndIf
    EndIf
    gnMainThreadLabel = #PB_Compiler_Line
    If gnRedrawSldCount > 0
      SLD_redrawSlidersWhereRequested()
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    CompilerIf 1=1  ; see comment in checkForNoteHotkeysReleased() about the procedure being obsolete as at 11.6.1bd
      If gnNoteHotkeyCuesPlaying
        checkForNoteHotkeysReleased()
      EndIf
    CompilerEndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    qTimeDiff = qTimeNow - qTimeOfLastMonitorCheck
    If qTimeDiff >= 2000
      qTimeOfLastMonitorCheck = qTimeNow
      ; checkMonitorInfo() ; Commented out 26Jul2024 11.10.3au as this functionality is now controlled via the Windows message #WM_DISPLAYCHANGE in WMN_windowCallback()
      ; run the following check also every 2 seconds
      If gnFocusSliderNo > 0
        SLD_clearFocusSlider()
      EndIf
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    qTimeDiff = qTimeNow - qTimeOfLastHalfSecondCheck
    If qTimeDiff >= 500
      qTimeOfLastHalfSecondCheck = qTimeNow
      ; debugMsg(sProcName, "grWMN\nLastPlayingCuePtr=" + getCueLabel(grWMN\nLastPlayingCuePtr))
      If grWMN\nLastPlayingCuePtr >= 0
        checkLastPlayingCue()
      EndIf
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If grTVGControl\bCloseTVGsWaiting
      If (qTimeNow - grTVGControl\qTimeOfLastIsPlayingCheck) > 5000
        If isTVGPlaying() = #False
          ; debugMsg(sProcName, "isTVGPlaying() returned #False, calling freeWaitingTVGControls()")
          freeWaitingTVGControls()
        Else
          ; debugMsg(sProcName, "isTVGPlaying() returned #True")
          grTVGControl\qTimeOfLastIsPlayingCheck = qTimeNow
        EndIf
      EndIf
    EndIf
    
    ; moved here from statusCheck() 21May2019 11.8.1rc4f following bug reported by Stas Ushomirsky, which was caused by the control thread trying to update the screen
    gnMainThreadLabel = #PB_Compiler_Line
    If gbEditMidiInfoDisplayedSet
      If (qTimeNow - gqEditMidiInfoDisplayed) > 4000
        SetGadgetText(WQM\lblEditMidiInfo[0], "")
        SetGadgetText(WQM\lblEditMidiInfo[1], "")
        SetGadgetText(WQM\lblMidiCaptureDone, "")
        gbEditMidiInfoDisplayedSet = #False
      EndIf
    EndIf
    ; end moved here from statusCheck() 21May2019 11.8.1rc4f
    
    gnMainThreadLabel = #PB_Compiler_Line
    If bSetTimeOfLastButtonClick
      ; set nTimeOfLastButtonClick to the time at the END of processing the button click so that checking for a double-click using grGeneralOptions\nDoubleClickTime
      ; is not affected by the time it takes to process the original click (eg the time taken to open the editor)
      qTimeOfLastButtonClick = ElapsedMilliseconds()
      debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", qTimeOfLastButtonClick=" + traceTime(qTimeOfLastButtonClick))
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbReloadAndDisplayDevsForProd
      gbReloadAndDisplayDevsForProd = #False
      If IsGadget(WEP\cboAudioPhysicalDev(0))
        WEP_loadAndDisplayDevsForProd()
      EndIf
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If gbPreviewPlaying
      If gbPreviewEnded
        WFO_previewEnded()
      Else
        WFO_updatePreviewProgressTrackbar()
      EndIf
    EndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    If grRAI\nSendSetPosCount > 0
      checkForAndSendSetPosMsgs()
    EndIf
    
    CompilerIf #c_dmx_receive_in_main_thread
      If grDMX\bReceiveDMX
        gnMainThreadLabel = #PB_Compiler_Line
        DMX_processDMXReceiveThread()
      EndIf
    CompilerEndIf
    
    gnMainThreadLabel = #PB_Compiler_Line
    gqThreadMainLoopEnded = ElapsedMilliseconds()
    gnMainThreadContinueLine = -1
    
  Until gbClosingDown
  
  gnMainThreadLabel = #PB_Compiler_Line
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Macro DO_REQUEST(nRequestNo, sProcedure)
  If gqMainThreadRequest & nRequestNo
    gqMainThreadRequest ! nRequestNo
    sProcedure
    If gqMainThreadRequest & nRequestNo
      gqMainThreadRequest ! nRequestNo
    EndIf
  EndIf
EndMacro

Macro DO_REQUEST_LOGGED(nRequestNo, sProcedure, sRequestCode)
  If gqMainThreadRequest & nRequestNo
    gqMainThreadRequest ! nRequestNo
    debugMsg(sProcName, "processing request " + sRequestCode)
    sProcedure
    If gqMainThreadRequest & nRequestNo
      gqMainThreadRequest ! nRequestNo
    EndIf
  EndIf
EndMacro

Procedure doMainThreadRequests()
  PROCNAMEC()
  ; Processes actions that must be called from the main thread as they affect gadgets on windows, eg resizing gadgets.
  ; Note that if some other thread (eg the control thread) were to create, resize or otherwise adjust a gadget on a window, this
  ; could lock up the program. This is possibly due to a thread locking conflict between SCS and Windows, but I can't be sure.
  ; The safest solution is to ensure that all such operations are processed in the main thread, and SCS handles this in several different
  ; ways, depending on the nature of the operation. These possible ways are:
  ;  1. Via this Procedure, which uses binary flags set in gqMainThreadRequest, such as the flag #SCS_MTH_UPDATE_DISP_PANELS.
  ;     Note that 'MTH' in these constants stands for 'Main Thread'.
  ;  2. Via SAM (Special Action Manager). SAM is run in the main thread - see the call to samProcess() in handleWindowEvents(). Requests are added using samAddRequest().
  ;  3. Via PureBasic PostEvent calls. I discovered this feature later and this is now the preferred solution unless multiple parameters need to be passed.
  
  Protected bLockedMutex
  
  If gbClosingDown = #False
    
    Select gqMainThreadRequest
      Case #SCS_MTH_UPDATE_DISP_PANELS
        ; do not lock mutex if this is the only request
      Default
        ; debugMsg(sProcName, "gqMainThreadRequest=%" + Bin(gqMainThreadRequest))
        LockCueListMutex(123)
    EndSelect
    
    DO_REQUEST(#SCS_MTH_PAUSE_ALL, pauseAll())    ; see also #SCS_MTH_PAUSE_RESUME_ALL later in this procedure
    DO_REQUEST(#SCS_MTH_RESUME_ALL, resumeAll())
    
    DO_REQUEST(#SCS_MTH_DISPLAY_OR_HIDE_HOTKEYS, WMN_displayOrHideHotkeys())
    DO_REQUEST(#SCS_MTH_SET_GRID_WINDOW, WMN_setGridWindow())
    DO_REQUEST(#SCS_MTH_REFRESH_GRDCUES, WMN_refreshGrdCues())
    DO_REQUEST_LOGGED(#SCS_MTH_LOAD_DISP_PANELS, PNL_loadDispPanels(), "#SCS_MTH_LOAD_DISP_PANELS")
    DO_REQUEST_LOGGED(#SCS_MTH_REFRESH_DISP_PANEL, PNL_refreshDispPanel(gnRefreshCuePtr, gnRefreshSubPtr, gnRefreshAudPtr, #False), "#SCS_MTH_REFRESH_DISP_PANEL")
    DO_REQUEST_LOGGED(#SCS_MTH_RELOAD_DISP_PANEL, PNL_refreshDispPanel(gnRefreshCuePtr, gnRefreshSubPtr, gnRefreshAudPtr, #True), "#SCS_MTH_RELOAD_DISP_PANEL")
    DO_REQUEST(#SCS_MTH_SET_NAVIGATE_BUTTONS, setNavigateButtons())
    DO_REQUEST(#SCS_MTH_HIGHLIGHT_LINE, highlightLine(gnCueToHighlight, #PB_Compiler_Line))
    DO_REQUEST(#SCS_MTH_SET_CUE_TO_GO, setCueToGo())
    
    DO_REQUEST(#SCS_MTH_VU_INIT, initVU())
    DO_REQUEST(#SCS_MTH_VU_CLEAR, clearVUDisplay())
    
    DO_REQUEST(#SCS_MTH_DISP_VIS_WARN_IF_REQD, displayVisualWarningIfReqd())
    DO_REQUEST(#SCS_MTH_UPDATE_DISP_PANELS, PNL_updateDispPanels())
    
    DO_REQUEST(#SCS_MTH_EDIT_UPDATE_DISPLAY, editUpdateDisplay())
    DO_REQUEST(#SCS_MTH_DRAW_WQF_GRAPH, drawGraph(@grMG2))
    
    DO_REQUEST_LOGGED(#SCS_MTH_CLEAR_STATUS_FIELD, WMN_setStatusField("", #SCS_STATUS_CLEAR), "#SCS_MTH_CLEAR_STATUS_FIELD")
    DO_REQUEST_LOGGED(#SCS_MTH_SET_STATUS_FIELD, WMN_setStatusField(grMain\sStatusField, grMain\nStatusType, grMain\nExtraDisplayTime, grMain\bMayOverrideStatus), "#SCS_MTH_SET_STATUS_FIELD")
    DO_REQUEST(#SCS_MTH_HIDE_WARNING_MSG, WMN_hideWarningMsg())
    
    DO_REQUEST(#SCS_MTH_GET_MIDI_MODE, getMidiMode(grMMedia\nAudPtrForGetMidiMode))
    
    DO_REQUEST(#SCS_MTH_SET_WED_NODE, WED_setNode())
    
    DO_REQUEST(#SCS_MTH_PLAY_SUB, playSubsInMainThread())
    
    DO_REQUEST(#SCS_MTH_CLOSE_DOWN, closeDown(#True))
    
    DO_REQUEST(#SCS_MTH_STOP_ALL, processStopAll())
    DO_REQUEST(#SCS_MTH_FADE_ALL, processFadeAll())
    DO_REQUEST(#SCS_MTH_PAUSE_RESUME_ALL, processPauseResumeAll())  ; see also #SCS_MTH_PAUSE_ALL and #SCS_MTH_RESUME_ALL earlier in this procedure
    DO_REQUEST(#SCS_MTH_STOP_MTC, processStopMTC())
    
    DO_REQUEST(#SCS_MTH_CALL_SETFILESAVE, setFileSave())
    
    DO_REQUEST(#SCS_MTH_PROCESS_ACTION, processAction())
    
    DO_REQUEST(#SCS_MTH_UPDATE_ALL_GRID, updateAllGrid())
    
    If bLockedMutex
      UnlockCueListMutex()
    EndIf
    
  EndIf
  
EndProcedure

; EOF