; File: fmRegister.pbi

EnableExplicit

Procedure WRG_setButtons()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  CompilerIf #cDemo = #False And #cWorkshop = #False
    If Len(Trim(GetGadgetText(WRG\txtLicUser))) = 0 Or Len(Trim(GetGadgetText(WRG\txtAuthString))) = 0
      setEnabled(WRG\btnRegister, #False)
    Else
      setEnabled(WRG\btnRegister, #True)
    EndIf
  CompilerEndIf
EndProcedure

Procedure WRG_displayRegistrationDetails()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\sLicType <> "D"
    SGT(WRG\txtLicUser, gsLicUser)
    CompilerIf 1=2
      ; blocked out 31Mar2019 11.8.0.2cm - don't populate the existing registration details as this could be viewed by anyone using the system (using the new 'eye' feature)
      If Len(grLicInfo\sExpString) = 0
        SGT(WRG\txtAuthString, gsRegAuthString)
      Else
        SGT(WRG\txtAuthString, gsRegAuthString + "-" + grLicInfo\sExpString)
      EndIf
    CompilerEndIf
  Else
    SGT(WRG\txtLicUser, "")
    SGT(WRG\txtAuthString, "")
  EndIf
  debugMsg(sProcName, "txtAuthString=" + GetGadgetText(WRG\txtAuthString) + ", gsRegAuthString=" + gsRegAuthString + ", grLicInfo\sExpString=" + grLicInfo\sExpString + ", grLicInfo\bAllUsers=" + strB(grLicInfo\bAllUsers))
  
  WRG_setButtons()
  SAG(WRG\txtLicUser)
EndProcedure

Procedure WRG_Form_Load(nParentWindow)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WRG) = #False
    debugMsg(sProcName, "calling createfmRegister()")
    createfmRegister(nParentWindow)
    drawPasswordEye(WRG\cvsAuthStringEye)
  EndIf
  
  WRG_setButtons()
  setWindowVisible(#WRG, #True)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WRG_Form_Show(bModal, nParentWindow)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  WRG\nParentWindow = nParentWindow
  
  If IsWindow(#WRG) = #False
    WRG_Form_Load(nParentWindow)
  EndIf
  CompilerIf #cDemo = #False And #cWorkshop = #False
    WRG_displayRegistrationDetails()
  CompilerEndIf
  setWindowModal(#WRG, bModal)
  setWindowVisible(#WRG, #True)
  SetActiveWindow(#WRG)
EndProcedure

Procedure WRG_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling unsetWindowModal(#WRG)")
  unsetWindowModal(#WRG)
  debugMsg(sProcName, "calling scsCloseWindow(#WRG)")
  scsCloseWindow(#WRG)
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WRG_btnCancel_Click()
  PROCNAMEC()
  
  WRG_Form_Unload()
  
  If gbInitialising
    If WRG\nParentWindow <> #WLP
      closeDown(#True)
    EndIf
  EndIf
  
EndProcedure

Procedure WRG_checkRegistrationDetails()
  PROCNAMEC()
  Protected sRegisteredLicType.s, sLicUser.s, sAuthString.s, sExpString.s, bAllUsers, bSetRegDate
  Protected ReqdAuthString.s, ActualAuthString.s
  Protected sAuthStringPacked.s, sLicDesc.s
  Protected nExpireDate, nStartsLeft
  Protected bResult
  Protected bStudent, dLicExpDate, bLicExpired
  Protected nExpFactor.l  ; must be long for decodeExpString
  Protected sMsg.s
  
  bResult = #False
  ; debugMsg(sProcName, "txtAuthString=" + GetGadgetText(WRG\txtAuthString))
  sAuthString = UCase(Trim(GetGadgetText(WRG\txtAuthString)))
  If Len(sAuthString) > 15
    bStudent = #True
    sExpString = Mid(sAuthString, 16)
    sAuthString = Left(sAuthString, 14)
    dLicExpDate = decodeExpString(sExpString, @nExpFactor)
    If dLicExpDate < Date()
      bLicExpired = #True
    EndIf
    debugMsgAS(sProcName, "dLicExpDate=" + FormatDate("%yyyy/%mm/%dd", dLicExpDate) + ", bLicExpired=" + strB(bLicExpired))
  EndIf
  
  sLicUser = Trim(GetGadgetText(WRG\txtLicUser))
  bAllUsers = #True
  bSetRegDate = #True
  
  debugMsg(sProcName, "sLicUser=" + sLicUser + ", sAuthString=" + sAuthString + ", sExpString=" + sExpString)
  
  sRegisteredLicType = "?"
  sLicDesc = ""
  nExpireDate = 0
  
  If (sLicUser) And (sAuthString)
    If icu(Trim(sLicUser), Trim(sAuthString))
      Select sAuthString
          
        Case comp92AuthString(sLicUser, "Z") ; Platinum
          sRegisteredLicType = "Z"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "HC") ; Platinum Corporate
          sRegisteredLicType = "HC"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "H4") ; Platinum 4-user
          sRegisteredLicType = "H4"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "H3") ; Platinum 3-user
          sRegisteredLicType = "H3"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "H2") ; Platinum 2-user
          sRegisteredLicType = "H2"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "Q") ; Professional Plus
          sRegisteredLicType = "Q"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "Y") ; Professional Corporate (also "MC"?)
          sRegisteredLicType = "Y"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "P") ; Professional
          sRegisteredLicType = "P"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "S") ; Standard
          sRegisteredLicType = "S"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "L") ; Lite   ; must check "L" before "ES" because of overlap in factors
          sRegisteredLicType = "L"
          gnMaxCueIndex = 40
          
        Case comp92AuthString(sLicUser, "MC") ; Professional Corporate (also "Y"?)
          sRegisteredLicType = "MC"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "M4") ; Professional 4-user
          sRegisteredLicType = "M4"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "M3") ; Professional 3-user
          sRegisteredLicType = "M3"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "M2") ; Professional 2-user
          sRegisteredLicType = "M2"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "ES", nExpFactor) ; Professional (Student)   ; must check "L" before "ES" because of overlap in factors
          sRegisteredLicType = "ES"
          sLicDesc = "SCS Professional (Student)"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "GC") ; Professional Plus Corporate
          sRegisteredLicType = "GC"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "G4") ; Professional Plus 4-user
          sRegisteredLicType = "G4"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "G3") ; Professional Plus 3-user
          sRegisteredLicType = "G3"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "G2") ; Professional Plus 2-user
          sRegisteredLicType = "G2"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "GS", nExpFactor) ; Professional (Student)
          sRegisteredLicType = "GS"
          sLicDesc = "SCS Professional Plus (Student)"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "FC") ; Standard Corporate
          sRegisteredLicType = "FC"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "F4") ; Standard 4-user
          sRegisteredLicType = "F4"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "F3") ; Standard 3-user
          sRegisteredLicType = "F3"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "F2") ; Standard 2-user
          sRegisteredLicType = "F2"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "FS", nExpFactor) ; Standard (Student)
          sRegisteredLicType = "FS"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "NZ", nExpFactor) ; Platinum time-limited
          sRegisteredLicType = "NZ"
          sLicDesc = "SCS Professional Platinum (Time-Limited)"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "NQ", nExpFactor) ; Professional Plus time-limited
          sRegisteredLicType = "NQ"
          sLicDesc = "SCS Professional Plus (Time-Limited)"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "NP", nExpFactor) ; Professional time-limited
          sRegisteredLicType = "NP"
          sLicDesc = "SCS Professional (Time-Limited)"
          gnMaxCueIndex = -1
          
        Case comp92AuthString(sLicUser, "NS", nExpFactor) ; Standard time-limited
          sRegisteredLicType = "NS"
          sLicDesc = "SCS Standard (Time-Limited)"
          gnMaxCueIndex = 80
          
        Case comp92AuthString(sLicUser, "T") ; Temporary
          If grLicInfo\sRegisteredLicType <> "T"
            ; prevents re-registering "T" and extending nExpireDate!
            sRegisteredLicType = "T"
            nExpireDate = dateToNumber(Date()) + 30
            nStartsLeft = 99
            sLicDesc = "Temporary"
            gnMaxCueIndex = 80
          EndIf
          
      EndSelect
      
    EndIf
    
    If (Len(sLicDesc) = 0) And (sRegisteredLicType <> "?")
      sLicDesc = decodeLicType(sRegisteredLicType, dLicExpDate)
    EndIf
    
    debugMsgAS(sProcName, "sRegisteredLicType=" + sRegisteredLicType + ", bLicExpired=" + strB(bLicExpired))
    If (sRegisteredLicType <> "?") And (bLicExpired = #False)
      grLicInfo\nLicLevel = getLicLevel(sRegisteredLicType)
      grLicInfo\sRegisteredLicType = sRegisteredLicType
      grLicInfo\sLicType = sRegisteredLicType
      If packRegKey(sRegisteredLicType, sLicUser, sAuthString, nExpireDate, nStartsLeft, sExpString, dLicExpDate, bAllUsers, bSetRegDate) = #False
        If grLicInfo\sRegErrorMsg
          sMsg = grLicInfo\sRegErrorMsg + Chr(10) + Chr(10) + "Please email this information to " + #SCS_EMAIL_SUPPORT
          ensureSplashNotOnTop()
          scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
          ProcedureReturn #False
        EndIf
      EndIf
      gbDemoMode = #False
      gbWorkshopMode = #False
      bResult = #True
      gsLicUser = sLicUser
      sMsg = LangPars("WRG", "Thankyou", gsLicUser) + Chr(10) + Chr(10) + Lang("WRG", "RegAccepted") + Chr(10) + Chr(10) + LangPars("WRG", "LicenseType", sLicDesc)
      Select sRegisteredLicType
        Case "ES", "FS", "NP", "NS", "NQ", "NZ"
          ; Time-limited license
          sMsg + Chr(10) + Chr(10) + LangPars("WRG", "LicenseExpires", formatDateAsDDMMMYYYY(dLicExpDate))
      EndSelect
      ensureSplashNotOnTop()
      scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONINFORMATION)
      gnRegisterRetries = 0
    Else
      setMouseCursorBusy()
      gnRegisterRetries + 1
      Delay(500)
      setMouseCursorNormal()
      ensureSplashNotOnTop()
      If (sRegisteredLicType <> "?") And (bLicExpired)
        sMsg = LangPars("WRG", "LicenseExpired", formatDateAsDDMMMYYYY(dLicExpDate))
      Else
        sMsg = Lang("WRG", "AuthNotValid")
      EndIf
      If gnRegisterRetries < 3
        scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
        WRG_setButtons()
      Else
        scsMessageRequester(#SCS_TITLE, sMsg + Chr(10) + Chr(10) + Lang("WRG", "MaxAttempts"), #MB_ICONEXCLAMATION)
        closeDown(#True)
        End
      EndIf
    EndIf
  Else
    WRG_setButtons()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure WRG_btnRegister_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If WRG_checkRegistrationDetails()
    ensureSplashNotOnTop()
    If gbInitialising
      scsMessageRequester(#SCS_TITLE, Lang("WRG", "PlsRestart"), #MB_ICONINFORMATION)
      closeDown(#True)
    Else
      scsMessageRequester(#SCS_TITLE, Lang("WRG", "PlsCloseAndRestart"), #MB_ICONINFORMATION)
    EndIf
    WRG_Form_Unload()
  Else
    WRG_setButtons()
    SAG(WRG\txtLicUser)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WRG_EventHandler()
  PROCNAMEC()
  
  With WRG
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WRG_btnCancel_Click()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn
            CompilerIf #cDemo Or #cWorkshop
              WRG_Form_Unload()
            CompilerElse
              If getEnabled(\btnRegister)
                WRG_btnRegister_Click()
              EndIf
            CompilerEndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WRG_btnCancel_Click()
            
        EndSelect
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
            
            ; NOTE gadgets displayed in demo mode
          Case \btnOK
            WRG_Form_Unload()
            
          Case \hypRegLink
            ; #SCS_REGISTER_URL_LINK = "http://www.showcuesystems.com/cms/purchase" for regular demo version (set in Constants.pbi),
            ; or "https://www.lambertstudios.net/scs" for agent David Lambert demo version (set in scs_PB_demo_x64_Lambert.pb or scs_PB_demo_x86_Lambert.pb)
            OpenURL(#SCS_REGISTER_URL_LINK)
            
            ; NOTE gadgets displayed in non-demo mode
          Case \btnCancel
            WRG_btnCancel_Click()
            
          Case \btnRegister
            WRG_btnRegister_Click()
            
          Case \cvsAuthStringEye
            processPasswordEyeEvent(\txtAuthString)
            
          Case \txtAuthString
            Select gnEventType
              Case #PB_EventType_Change
                WRG_setButtons()
            EndSelect
            
          Case \txtLicUser
            Select gnEventType
              Case #PB_EventType_Change
                WRG_setButtons()
            EndSelect
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " " + getGadgetName(gnEventGadgetNo))
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
