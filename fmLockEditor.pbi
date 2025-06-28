; File: fmLockEditor.pbi
; called from fmOptions - see WOP_btnLockEditing_Click()

EnableExplicit

Procedure WLE_addShortcuts()
  AddKeyboardShortcut(#WLE, #PB_Shortcut_Return, #WLE_mnuLock)
  AddKeyboardShortcut(#WLE, #PB_Shortcut_Escape, #WLE_mnuCancel)
EndProcedure

Procedure WLE_btnLock_Click()
  PROCNAMEC()
  Protected sMMFlags.s, sFlag.s, bEnabled, sMsg.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  Protected sEnteredPassword.s, bPasswordOK

  ; check for correct password
  
  sEnteredPassword = Trim(GGT(WLE\txtLockPassword))
  If sEnteredPassword
    If UCase(sEnteredPassword) = UCase(gsRegAuthString)
      bPasswordOK = #True
    Else
      ; MMFlags contains encrypted editor password (see also AudioFlags)
      COND_OPEN_PREFS("GeneralOptions")  ; COND_OPEN_PREFS("GeneralOptions")
      sMMFlags = ReadPreferenceString("MMFlags", "")
      debugMsgAS(sProcName, "sMMFlags=" + sMMFlags + ", WLE_Fe(" + sEnteredPassword + ")=" + WLE_Fe(sEnteredPassword))
      If WLE_Fe(sEnteredPassword) = sMMFlags
        bPasswordOK = #True
      EndIf
    EndIf
  EndIf
  
  If bPasswordOK
    
    If grWOP\bEditorAndOptionsLocked = #False
      
      ; about to lock editor, so save preferences that must not be saved while editing and options are locked.
      ; the main issue is that even with editing and options locked, the user can still resize columns in the cue list (a ListIconGadget).
      ; normally we save the new column sizes, but if editing and options are locked then we do not save changes like this, so the next
      ; time SCS is opened, the 'authorised' column sizes, etc, are reinstated.
      debugMsg(sProcName, "saving registry settings")
      savePreferences()
      
      grWOP\bEditorAndOptionsLocked = #True
      sFlag = "Y"
      bEnabled = #False
    Else
      grWOP\bEditorAndOptionsLocked = #False
      sFlag = "N"
      bEnabled = #True
    EndIf
    ; AudioFlags contains Y if editor is locked (see also MMFlags)
    WritePreferenceString("AudioFlags", sFlag)
    
    WOP_processEditorAndOptionsLocked()
    WOP_setOptionsChanged()
    
    WMN_setToolbarButtons()
    
    If grWOP\bEditorAndOptionsLocked
      sMsg = Lang("WLE", "NowLocked")     ; "Editing and General Options now locked"
    Else
      sMsg = Lang("WLE", "NowUnlocked")   ; "Editing and General Options now unlocked"
    EndIf
    debugMsg(sProcName, sMsg)
    scsMessageRequester(GWT(#WLE), sMsg, #PB_MessageRequester_Ok|#MB_ICONINFORMATION)
    
    WLE_Form_Unload()
    
  Else
    ; Incorrect Password
    scsMessageRequester(GWT(#WLE), Lang("WLE", "PassWrong"), #PB_MessageRequester_Error)
    SAG(WLE\txtLockPassword)
  EndIf
  
  COND_CLOSE_PREFS()
  
EndProcedure

Procedure.s WLE_Fe(pIn.s)
  Protected i, j, sChars.s
  Protected nTemp.d, nTemp2.d, nChar
  Protected nCounter, nRem.d, nFactor
  Protected sTemp.s, sChar.s

  nFactor = 327146
  nTemp = 0
  For i = 1 To Len(pIn)
    nChar = Asc(UCase(Mid(pIn, i, 1))) ; NOTE: The use of UCASE() means that the password is not case-sensitive
    j = i % 8
    nTemp2 = nChar + j
    nTemp = nTemp + (nTemp2 * nFactor)
  Next

  sTemp = ""
  sChars = "PQRSEFGHABCDJKLMNTUVWXYZ"
  nCounter = 0
  While nTemp > 0 And nCounter < 12
    nCounter = nCounter + 1
    
    ; nRem = nTemp % 24   ; PB throws error because % cannot be used with floats, so replaced with the following line:
    nRem = nTemp - (Round(nTemp / 24, #PB_Round_Down) * 24)
    
    nTemp = Round(nTemp / 5, #PB_Round_Down)
    sTemp = sTemp + Mid(sChars, nRem+1, 1)
  Wend

  ProcedureReturn sTemp

EndProcedure

Procedure WLE_btnSetPassword_Click()
  PROCNAMEC()
  Protected sFlag.s, sMsg.s, sTmp.s
  Protected bPrefsOpenAtStart, sPrefGroupAtStart.s
  
  debugMsg(sProcName, #SCS_START)

  If Trim(UCase(GGT(WLE\txtAuthString))) <> UCase(gsRegAuthString)
    grWLE\nLockAttempts + 1
    If grWLE\nLockAttempts < 3
      sMsg = Lang("WLE", "AuthMsg1")
    ElseIf grWLE\nLockAttempts < #SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS
      sTmp = Lang("WLE", "AuthMsg2")
      sTmp = ReplaceString(sTmp, "$1", Str(#SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS))
      sTmp = ReplaceString(sTmp, "$2", Str(#SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS - grWLE\nLockAttempts))
      sMsg = Lang("WLE", "AuthMsg1") + #CRLF$ + #CRLF$ + sTmp
    Else
      sTmp = Lang("WLE", "AuthMsg3")
      sTmp = ReplaceString(sTmp, "$1", Str(#SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS))
      sMsg = Lang("WLE", "AuthMsg1") + #CRLF$ + #CRLF$ + sTmp
    EndIf
    setMouseCursorBusy()
    Delay(500)
    setMouseCursorNormal()
    scsMessageRequester(GGT(WLE\frSetPassword), sMsg, #PB_MessageRequester_Error)
    If grWLE\nLockAttempts < #SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS
      SAG(WLE\txtAuthString)
    Else
      ; if max attempts reached then disable this button
      setEnabled(WLE\btnSetPassword, #False)
      setEnabled(WLE\txtAuthString, #False)
    EndIf
    ProcedureReturn
  EndIf

  If Trim(GGT(WLE\txtNew1)) <> Trim(GGT(WLE\txtNew2))
    ; 'Confirm New Password' is different to 'New Password'
    scsMessageRequester(GGT(WLE\frSetPassword), Lang("WLE", "PassDiff"), #PB_MessageRequester_Error)
    SAG(WLE\txtNew1)
    ProcedureReturn
  EndIf

  If Len(Trim(GGT(WLE\txtNew1))) > 0 And Len(Trim(GGT(WLE\txtNew1))) < 6
    ; New Password must be at least 6 characters long
    scsMessageRequester(GGT(WLE\frSetPassword), Lang("WLE", "PassLength"), #PB_MessageRequester_Error)
    SAG(WLE\txtNew1)
    ProcedureReturn
  EndIf

  COND_OPEN_PREFS("GeneralOptions")  ; COND_OPEN_PREFS("GeneralOptions")
  
  ; MMFlags contains encrypted editor password (see also AudioFlags)
  WritePreferenceString("MMFlags", WLE_Fe(Trim(GGT(WLE\txtNew1))))

  If grWOP\bEditorAndOptionsLocked = #False
    grWOP\bEditorAndOptionsLocked = #True
    sFlag = "Y"
  Else
    grWOP\bEditorAndOptionsLocked = #False
    sFlag = "N"
  EndIf
  ; AudioFlags contains Y if editor is locked (see also MMFlags)
  WritePreferenceString("AudioFlags", sFlag)
  
  COND_CLOSE_PREFS()
  
  WOP_processEditorAndOptionsLocked()
  WOP_setOptionsChanged()
  
  WMN_setToolbarButtons()

  sMsg = Lang("WLE", "PassOK")          ; "New password accepted."
  sMsg + Chr(10) + Chr(10)
  If grWOP\bEditorAndOptionsLocked
    sMsg + Lang("WLE", "NowLocked")     ; "Editing and General Options now locked"
  Else
    sMsg + Lang("WLE", "NowUnlocked")   ; "Editing and General Options now unlocked"
  EndIf
  scsMessageRequester(GWT(#WLE), sMsg, #PB_MessageRequester_Ok|#MB_ICONINFORMATION)

  WLE_Form_Unload()

EndProcedure

Procedure WLE_Form_Unload()
  getFormPosition(#WLE, @grLockWindow)
  unsetWindowModal(#WLE)
  scsCloseWindow(#WLE)
EndProcedure

Procedure WLE_Form_Show(bModal=#False)
  PROCNAMEC()
  
  If grWLE\nLockAttempts >= #SCS_LOCK_EDITOR_MAX_INVALID_AUTH_STRING_ATTEMPTS
    ProcedureReturn
  EndIf
  
  If IsWindow(#WLE) = #False
    createfmLockEditor()
    With WLE
      drawPasswordEye(\cvsLockPasswordEye)
      drawPasswordEye(\cvsAuthStringEye)
      drawPasswordEye(\cvsNew1Eye)
      drawPasswordEye(\cvsNew2Eye)
    EndWith
  EndIf
  setWindowModal(#WLE, bModal)
  setFormPosition(#WLE, @grLockWindow)
  
  WLE_addShortcuts()
  WLE_selectLockOrUnlock()
  
  setWindowVisible(#WLE, #True)
  SAW(#WLE)
  
EndProcedure

Procedure WLE_selectLockOrUnlock()
  PROCNAMEC()

  setVisible(WLE\cntSetPassword,#False)
  setEnabled(WLE\cntSetPassword,#False)

  If grWOP\bEditorAndOptionsLocked = #False
    SetWindowTitle(#WLE, Lang("WLE", "WindowLock"))   ; "Lock Editing and Options"
    SGT(WLE\frLock, Lang("WLE", "WindowLock"))        ; this frame title is same as window title
    SGT(WLE\btnLock, Lang("WLE", "Lock"))
    SGT(WLE\lblLockIntro, Lang("WLE","IntroLock"))
  Else
    SetWindowTitle(#WLE, Lang("WLE", "WindowUnlock")) ; "Unlock Editing and General Options"
    SGT(WLE\frLock, Lang("WLE", "WindowUnlock"))      ; this frame title is same as window title
    SGT(WLE\btnLock, Lang("WLE", "Unlock"))
    SGT(WLE\lblLockIntro, Lang("WLE","IntroUnlock"))
  EndIf

  grWLE\sCurrentFrame = "frLock"
  setEnabled(WLE\frLock, #True)
  ; btnLock\Default = #True
  WLE_setButtonEnabled()

  SAG(WLE\txtLockPassword)

EndProcedure

Procedure WLE_selectSetPassword()
  PROCNAMEC()

  setVisible(WLE\cntLock, #False)
  setEnabled(WLE\cntLock, #False)

  grWLE\sCurrentFrame = "frSetPassword"
  setVisible(WLE\cntSetPassword, #True)
  setEnabled(WLE\cntSetPassword, #True)
  WLE_setButtonEnabled()

  SAG(WLE\txtAuthString)

EndProcedure

Procedure WLE_setButtonEnabled()
  Protected bEnabled

  bEnabled = #False
  If grWLE\sCurrentFrame = "frLock"
    If Len(Trim(GGT(WLE\txtLockPassword))) <> 0
      bEnabled = #True
    EndIf
    setEnabled(WLE\btnLock, bEnabled)

  ElseIf grWLE\sCurrentFrame = "frSetPassword"
    If Len(Trim(GGT(WLE\txtAuthString))) > 0 And Len(Trim(GGT(WLE\txtNew1))) > 0 And Len(Trim(GGT(WLE\txtNew2))) > 0
      bEnabled = #True
    EndIf
    setEnabled(WLE\btnSetPassword, bEnabled)
  EndIf
EndProcedure

Procedure WLE_EventHandler()
  PROCNAMEC()
  
  With WLE
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WLE_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
          Case #WLE_mnuLock
            If getEnabled(\btnLock)
              WLE_btnLock_Click()
            EndIf
          Case #WLE_mnuCancel
            WLE_Form_Unload()
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WLE_Form_Unload()
            
          Case \btnForgot
            WLE_selectSetPassword()
            
          Case \btnLock
            WLE_btnLock_Click()
            
          Case \btnSetPassword
            WLE_btnSetPassword_Click()
            
          Case \cvsAuthStringEye
            processPasswordEyeEvent(\txtAuthString)
            
          Case \cvsLockPasswordEye
            processPasswordEyeEvent(\txtLockPassword)
            
          Case \cvsNew1Eye
            processPasswordEyeEvent(\txtNew1)
            
          Case \cvsNew2Eye
            processPasswordEyeEvent(\txtNew2)
            
          Case \txtAuthString
            If gnEventType = #PB_EventType_Change
              WLE_setButtonEnabled()
            EndIf
            
          Case \txtLockPassword
            If gnEventType = #PB_EventType_Change
              WLE_setButtonEnabled()
            EndIf
            
          Case \txtNew1
            If gnEventType = #PB_EventType_Change
              WLE_setButtonEnabled()
            EndIf
            
          Case \txtNew2
            If gnEventType = #PB_EventType_Change
              WLE_setButtonEnabled()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
