; File: fmSpecialStart.pbi

EnableExplicit

; debugMsg() cannot be used in this module as trace files have not yet been opened

Procedure WSS_Process_btnOK()
  Protected bResult
  Protected nResponse
  Protected nResult
  Protected sPrefFileName.s
  Protected sPrefGroupName.s, sPrefKeyName.s
  
  bResult = #True
  
  With WSS
    sPrefFileName = gsAppDataPath + #SCS_PREFS_FILE
    Debug "sPrefFileName=" + sPrefFileName
    If grSpecialStartInfo\bFactoryReset ; factory reset
      nResponse = MessageRequester(GWT(#WSS), Lang("WSS", "AreYouSure"), #PB_MessageRequester_YesNo)
      If nResponse = #PB_MessageRequester_Yes
        If FileSize(sPrefFileName) >= 0
          nResult = DeleteFile(sPrefFileName)
          Debug "DeleteFile(sPrefFileName) returned " + nResult
        EndIf
        If Len(gsCommonAppDataPath) = 0
          gsCommonAppDataPath = GetUserDirectory(#PB_Directory_AllUserData) ; "C:\ProgramData"
          gsCommonAppDataPath  + "ShowCueSystem\"
        EndIf
        sPrefFileName = gsCommonAppDataPath + #SCS_PREFS_FILE
        If FileSize(sPrefFileName) >= 0
          nResult = DeleteFile(sPrefFileName)
          Debug "DeleteFile(sPrefFileName) returned " + nResult
        EndIf
        ; re-call initialisePart0() to load US English
        initialisePart0()
      Else
        grSpecialStartInfo\bFactoryReset = #False
        SGS(\chkFactoryReset, 0)
        ; do not 'Break' if user replies 'No' but stay in window
        bResult = #False
      EndIf
      
    Else
      
      If OpenPreferences(sPrefFileName, #PB_Preference_GroupSeparator)
        
        If grSpecialStartInfo\bIgnoreWindows
          ; remove all "Windows..." groups
          ExaminePreferenceGroups()
          While NextPreferenceGroup() ; While group exists
            sPrefGroupName = PreferenceGroupName()
            If Left(sPrefGroupName, 7) = "Windows"
              RemovePreferenceGroup(sPrefGroupName)
            EndIf
          Wend
          ; now remove any "SplitScreenCount..." preferences in the "VideoDriver" group
          If PreferenceGroup("VideoDriver")
            ExaminePreferenceKeys()
            While NextPreferenceKey()
              sPrefKeyName = PreferenceKeyName()
              If LCase(Left(sPrefKeyName, 16)) = LCase("SplitScreenCount")
                Debug "removing 'VideoDriver' key '" + sPrefKeyName + "'"
                RemovePreferenceKey(sPrefKeyName)
              EndIf
            Wend
          Else
            ; if PreferenceGroup("VideoDriver") returned 0 then the VideoDriver group did not previously exist, but PreferenceGroup() will now have created it, so remove it to reinstate the status quo
            RemovePreferenceGroup("VideoDriver")
          EndIf
        EndIf
        
        ; always save the 'Do NOT use WASAPI' setting (if not doing a 'factory reset') as it was originally populated from the preference file setting
        If PreferenceGroup("AudioDriverBASS")
          If grSpecialStartInfo\bNoWASAPI
            WritePreferenceInteger("NoWASAPI", grSpecialStartInfo\bNoWASAPI)
          Else
            RemovePreferenceKey("NoWASAPI")
          EndIf
        EndIf
        
        ClosePreferences()
      EndIf
      
    EndIf
    
  EndWith
  
  ProcedureReturn bResult
  
EndProcedure

Procedure WSS_Main()
  Protected bCloseSCS
  Protected sPrefFileName.s
  Protected rSpecialStartInfoDef.tySpecialStartInfo
  
  If IsWindow(#WSS) = #False
    createfmSpecialStart()
  EndIf
  
  Debug "grLicInfo\sLicType=" + grLicInfo\sLicType + ", \nLicLevel=" + grLicInfo\nLicLevel
  
  sPrefFileName = gsAppDataPath + #SCS_PREFS_FILE
  Debug "sPrefFileName=" + sPrefFileName
  If OpenPreferences(sPrefFileName, #PB_Preference_GroupSeparator)
    If PreferenceGroup("AudioDriverBASS")
      grSpecialStartInfo\bNoWASAPI = ReadPreferenceInteger("NoWASAPI", 0)
      If grSpecialStartInfo\bNoWASAPI
        SetGadgetState(WSS\chkNoWASAPI, #PB_Checkbox_Checked)
      EndIf
    EndIf
  EndIf
  
  rSpecialStartInfoDef = grSpecialStartInfo
  
  With WSS
    Repeat
      gnWindowEvent = WaitWindowEvent()
      
      Select gnWindowEvent
        Case #PB_Event_Menu
          gnEventMenu = EventMenu()
          Select gnEventMenu
            Case #SCS_mnuKeyboardReturn   ; Return
              If WSS_Process_btnOK()
                Break
              Else
                ; user clicked 'No' for 'Are you sure'
              EndIf
              
            Case #SCS_mnuKeyboardEscape   ; Escape
              grSpecialStartInfo = rSpecialStartInfoDef
              Break
              
          EndSelect
          
        Case #PB_Event_Gadget
          gnEventGadgetNo = EventGadget()
          gnEventType = EventType()
          Select gnEventGadgetNo
            Case \btnCancel
              grSpecialStartInfo = rSpecialStartInfoDef
              Break
              
            Case \btnCloseSCS
              bCloseSCS = #True
              Break
              
            Case \btnOK ; btnOK
              If WSS_Process_btnOK()
                Break
              Else
                ; user clicked 'No' for 'Are you sure'
              EndIf
              
            Case \chkDoNotOpenMRF
              grSpecialStartInfo\bDoNotOpenMRF = GGS(\chkDoNotOpenMRF)
              
            Case \chkFactoryReset
              grSpecialStartInfo\bFactoryReset = GGS(\chkFactoryReset)
              
            Case \chkIgnoreWindows
              grSpecialStartInfo\bIgnoreWindows = GGS(\chkIgnoreWindows)
              
            Case \chkNoWASAPI
              grSpecialStartInfo\bNoWASAPI = GGS(\chkNoWASAPI)
              
          EndSelect
      EndSelect
      
    Until gnWindowEvent = #PB_Event_CloseWindow
  EndWith
  CloseWindow(#WSS)
  
  If bCloseSCS
    ProcedureReturn #False
  Else
    ProcedureReturn #True
  EndIf
  
EndProcedure

; EOF
