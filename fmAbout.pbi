; File: fmAbout.pbi

EnableExplicit

Procedure WAB_Form_Load()
  PROCNAMEC()
  Protected nExpiryDate
  
  If IsWindow(#WAB) = #False
    createfmAbout()
  EndIf
  
  SGT(WAB\lblCopyright, grProgVersion\sCopyRight)
  SGT(WAB\lblVersion, "SCS " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ")")
  ; setGadgetWidth(WAB\lblVersion)
  SGT(WAB\lblBuild, LangSpace("WAB", "lblBuild") + grProgVersion\sBuildDateTime)
  
  If grLicInfo\sLicType = "D"
    SGT(WAB\lblLicUser, "DEMO VERSION")
    SGT(WAB\lblLicType, "")
    
  ElseIf grLicInfo\sLicType = "W"
    SGT(WAB\lblLicUser, "WORKSHOP VERSION")
    SGT(WAB\lblLicType, "")
    
  ElseIf grLicInfo\sLicType = "T"
    SGT(WAB\lblLicUser, "")
    nExpiryDate = dateToNumber(grLicInfo\nExpireDate)
    SGT(WAB\lblLicType, "Temporary License expiring " + formatDateAsDDMMMYYYY(nExpiryDate))
    
  ElseIf grLicInfo\nLicLevel <> #SCS_LIC_DEMO
    SGT(WAB\lblLicUser, Lang("Common", "LicensedTo") + ": " + grLicInfo\sLicUser)
    SGT(WAB\lblLicType, Lang("WAB", "lblLicType") + ": " + decodeLicType(grLicInfo\sLicType, grLicInfo\dLicExpDate))
    
  Else
    SGT(WAB\lblLicUser, Lang("WAB", "NotRegistered"))
    SGT(WAB\lblLicType, "")
    
  EndIf
  
  CompilerIf #cAgent
    SGT(WAB\lblInfo, LangPars("WAB","lblInfoAgent",#SCS_AGENT_NAME))
  CompilerElse
    SGT(WAB\lblInfo, Lang("WAB","lblInfo"))
  CompilerEndIf
  
  setWindowVisible(#WAB, #True)
  
EndProcedure

Procedure WAB_Form_Show(bModal=#False)
  PROCNAMEC()
  
  If IsWindow(#WAB) = #False
    WAB_Form_Load()
  EndIf
  ensureSplashNotOnTop()
  setWindowModal(#WAB, bModal)
  setWindowVisible(#WAB, #True)
  SAW(#WAB)
EndProcedure

Procedure WAB_Form_Unload()
  unsetWindowModal(#WAB)
  scsCloseWindow(#WAB)
EndProcedure

Procedure WAB_EventHandler()
  PROCNAMEC()
  
  With WAB
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WAB_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            WAB_Form_Unload()
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WAB_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnOK   ; btnOK
            WAB_Form_Unload()
            
          Case \lblSCSHomePageURL   ; lblSCSHomePageURL
            OpenURL(#SCS_HOME_PAGE_URL_DISPLAY)
            
          Case \lblURL  ; lblURL
            OpenURL(#SCS_URL_LINK)
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
