; File: Windows.pbi

EnableExplicit

; 'standard' gap between a right-justified prompt and a field: 7 pixels
;
; the following 'standards' are partly based on gadget sizes observed in Microsoft products, eg Explorer and IE
;    button gadget height:   23 pixels (shows 20 pixels from displayed top to bottom of gadget)
;    combobox gadget height: 21 pixels (shows 20 pixels from displayed top to bottom of gadget)
;    checkbox gadget height: 17 pixels
;    string gadget height:   21 pixels (string gadget is a text box)
;    label gadget height:    15 pixels (for normal font)
;    label gadget top:        3 pixels greater than associated string/combobox gadget top
;                             5 pixels greater than associated button gadget

Macro SUBCUE_HEADER_FIELDS()
  ; common sub fields
  cboRelStartMode.i
  cboSubCueMarker.i
  cboSubStart.i
  chkSubEnabled.i
  cntSubRelMTCStartTime.i
  cntSubHeader.i
  lblSubCueType.i
  lblSubDescr.i
  lblSubDisabled.i
  Array lblSubRelMTCStartSep.i(3)
  lblRelStart.i
  txtRelStartTime.i
  txtSubDescr.i
  Array txtSubRelMTCStartPart.i(3)
EndMacro

Macro SUBCUE_HEADER_CODE(pRecord)
  Protected nHdrPartWidth, nHdrSepWidth, nHdrFlag, nHdrPartIndex, nHdrMTCWidth

  pRecord\cntSubHeader=scsContainerGadget(0,0,gnEditorScaPropertiesInnerWidth,41,0,"cntSubHeader")
    
    pRecord\lblSubCueType=scsTextGadget(0,0,gnEditorScaPropertiesInnerWidth,18,"",0,"lblSubCueType")
    scsSetGadgetFont(pRecord\lblSubCueType, #SCS_FONT_GEN_BOLD9)
    setReverseEditorColors(pRecord\lblSubCueType, #True)
    
    pRecord\chkSubEnabled=scsCheckBoxGadget2(GadgetX(WEC\chkCueEnabled),0,-1,16,Lang("CED","chkSubEnabled"),0,"chkSubEnabled")
    scsToolTip(pRecord\chkSubEnabled,Lang("CED","chkSubEnabledTT"))
    setReverseEditorColors(pRecord\chkSubEnabled, #True)
    pRecord\lblSubDisabled=scsTextGadget(gnNextX+gnGap2,1,85,16,"  "+Lang("CED","lblSubDisabled")+"  ",#PB_Text_Center,"lblSubDisabled")
    scsSetGadgetFont(pRecord\lblSubDisabled, #SCS_FONT_GEN_BOLD)
    setGadgetWidth(pRecord\lblSubDisabled) ; sets width to 'required size'
    SetGadgetColor(pRecord\lblSubDisabled, #PB_Gadget_FrontColor, #SCS_Red)
    SetGadgetColor(pRecord\lblSubDisabled, #PB_Gadget_BackColor, #SCS_White)
    setAllowEditorColors(pRecord\lblSubDisabled, #False)
    setVisible(pRecord\lblSubDisabled, #False)
    
    pRecord\lblSubDescr=scsTextGadget(0,23,102,15," "+grText\sTextDescription,#PB_Text_Right,"lblSubDescr")
    setGadgetWidth(pRecord\lblSubDescr,-1,#True,100)
    pRecord\txtSubDescr=scsStringGadget(gnNextX+gnGap,20,250,21,"",0,"txtSubDescr")
    scsToolTip(pRecord\txtSubDescr,Lang("CED","SubDescrTT"))
    
    pRecord\cboSubStart=scsComboBoxGadget(gnNextX,20,160,21,0,"cboSubStart")
    scsToolTip(pRecord\cboSubStart,Lang("CED","cboSubStartTT"))
    ; the following code for creating an 'MTC Gadget' is based on code from the PB Forum topic "Customized IPAddressGadget() is need"
    ; at http://www.purebasic.fr/english/viewtopic.php?f=13&t=37929
    nHdrPartWidth = GetTextWidth(" 88 ")
    nHdrSepWidth = GetTextWidth(":") + 1
    nHdrMTCWidth = (4 * nHdrPartWidth) + (3 * nHdrSepWidth) + gl3DBorderAllowanceX + gl3DBorderAllowanceX
    pRecord\cntSubRelMTCStartTime=scsContainerGadget(gnNextX,20,nHdrMTCWidth,21,#PB_Container_Flat,"cntSubRelMTCStartTime")
      SetGadgetColor(pRecord\cntSubRelMTCStartTime, #PB_Gadget_BackColor, #SCS_White)
      setAllowEditorColors(pRecord\cntSubRelMTCStartTime, #False)
      ; nHdrFlag = #PB_String_Numeric | #PB_String_BorderLess | #ES_CENTER
      nHdrFlag = #PB_String_BorderLess | #ES_CENTER
      pRecord\txtSubRelMTCStartPart(0)=scsStringGadget(1,1,nHdrPartWidth,20,"",nHdrFlag,"txtSubRelMTCStartPart(0)")
      pRecord\txtSubRelMTCStartPart(1)=scsStringGadget(gnNextX+nHdrSepWidth,1,nHdrPartWidth,20,"",nHdrFlag,"txtSubRelMTCStartPart(1)")
      pRecord\txtSubRelMTCStartPart(2)=scsStringGadget(gnNextX+nHdrSepWidth,1,nHdrPartWidth,20,"",nHdrFlag,"txtSubRelMTCStartPart(2)")
      pRecord\txtSubRelMTCStartPart(3)=scsStringGadget(gnNextX+nHdrSepWidth,1,nHdrPartWidth,20,"",nHdrFlag,"txtSubRelMTCStartPart(3)")
      ; Create separators 
      For nHdrPartIndex = 0 To 2
        pRecord\lblSubRelMTCStartSep(nHdrPartIndex)=scsTextGadget(GadgetX(pRecord\txtSubRelMTCStartPart(nHdrPartIndex)) + GadgetWidth(pRecord\txtSubRelMTCStartPart(nHdrPartIndex)) + 1, 1, nHdrSepWidth, 20, ":", #PB_Text_Center, "lblSubRelMTCStartSep("+nHdrPartIndex+")")
        SetGadgetColor(pRecord\lblSubRelMTCStartSep(nHdrPartIndex), #PB_Gadget_BackColor, #SCS_White)
        setAllowEditorColors(pRecord\lblSubRelMTCStartSep(nHdrPartIndex), #False)
      Next nHdrPartIndex
    scsCloseGadgetList() 
    ; set length of per field, and tooltip
    For nHdrPartIndex = 0 To 3
      SendMessage_(pRecord\txtSubRelMTCStartPart(nHdrPartIndex), #EM_LIMITTEXT, 2, 0) 
      scsToolTip(pRecord\txtSubRelMTCStartPart(nHdrPartIndex),Lang("CED","txtSubRelMTCStartTimeTT"))
    Next nHdrPartIndex
    pRecord\cboSubCueMarker=scsComboBoxGadget(GadgetX(pRecord\cntSubRelMTCStartTime),20,120,21,0,"cboSubCueMarker")
    pRecord\txtRelStartTime=scsStringGadget(gnNextX+gnGap,20,62,21,"",0,"txtRelStartTime")
    scsToolTip(pRecord\txtRelStartTime,Lang("CED","txtRelStartTimeTT"))
    setValidChars(pRecord\txtRelStartTime, "0123456789.:")
    pRecord\cboRelStartMode=scsComboBoxGadget(gnNextX,20,160,21,0,"cboRelStartMode")
    scsToolTip(pRecord\cboRelStartMode,Lang("CED","cboRelStartModeTT"))
  scsCloseGadgetList()
EndMacro

Procedure adjustWindowPosIfReqd(*nWindowLeft.Integer, *nWindowTop.Integer, *nWindowWidth.Integer, *nWindowHeight.Integer, *nWindowFlags.Integer)
  Protected nMonitor2Left, nMonitor2Top, nMonitor2Width, nMonitor2Height
  Protected nWidth, nHeight, nFlags
  Protected nCalcLeft, nCalcTop
  Protected bAdjusted
  
  ; Procedure modified 5Feb2022 11.9.0rc7a to use gnSwapMonitor instead of the fixed swap value 2
  If (gbSwapMonitors1and2) And (gnMonitors >= gnSwapMonitor)
    nWidth = PeekI(*nWindowWidth)
    nHeight = PeekI(*nWindowHeight)
    nFlags = PeekI(*nWindowFlags)
    
    nMonitor2Left = gaMonitors(gnSwapMonitor)\nMonitorBoundsLeft
    nMonitor2Top = gaMonitors(gnSwapMonitor)\nMonitorBoundsTop
    nMonitor2Width = gaMonitors(gnSwapMonitor)\nMonitorBoundsWidth
    nMonitor2Height = gaMonitors(gnSwapMonitor)\nMonitorBoundsHeight
    If nWidth < nMonitor2Width
      nCalcLeft = nMonitor2Left + ((nMonitor2Width - nWidth) >> 1)
      PokeI(*nWindowLeft, nCalcLeft)
    EndIf
    If nHeight < nMonitor2Height
      nCalcTop = nMonitor2Top + ((nMonitor2Height - nHeight) >> 1)
      PokeI(*nWindowTop, nCalcTop)
    EndIf
    ; remove 'centered' flag if present
    If nFlags & #PB_Window_ScreenCentered
      nFlags ! #PB_Window_ScreenCentered
      PokeI(*nWindowFlags, nFlags)
    EndIf
    bAdjusted = #True
  EndIf
  ProcedureReturn bAdjusted
EndProcedure

Structure strWAB ; fmAbout
  btnOK.i
  cntLicence.i
  frLicence.i
  imgAboutLogo.i
  lblBuild.i
  lblCopyright.i
  lblDllVersion.i
  lblInfo.i
  lblLicType.i
  lblLicUser.i
  lblSCSHomePageURL.i
  lblURL.i
  lblVersion.i
  lnLine1.i
  lnLine2.i
  lnLine3.i
EndStructure
Global WAB.strWAB ; fmAbout

Procedure createfmAbout()
  PROCNAMEC()
  Protected nLeft, nWidth
  Protected nBackColor = RGB($E6,$FF,$F2)
  
  If IsWindow(#WAB)
    ; already created
    ProcedureReturn
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  With WAB
    If scsOpenWindow(#WAB, 0, 0, 382, 451, Lang("WAB","Window"), #PB_Window_SystemMenu|#PB_Window_WindowCentered | #PB_Window_Invisible, #WMN)
      registerWindow(#WAB, "WAB(fmAbout)")
      SetWindowColor(#WAB, nBackColor)
      
      ; image
      IMG_catchAboutScreenImages()
      \imgAboutLogo=scsImageGadget(26,20,330,144,ImageID(hAboutScreenLogo),0,"imgAboutLogo")
      DisableGadget(\imgAboutLogo, #True)
      
      ; copyright and version info
      \lblCopyright=scsTextGadget(6,193,247,15,"",0,"lblCopyright")
      SetGadgetColor(\lblCopyright, #PB_Gadget_BackColor, nBackColor)
      \lblVersion=scsTextGadget(253,193,123,15,"", #PB_Text_Right, "lblVersion")
      SetGadgetColor(\lblVersion, #PB_Gadget_BackColor, nBackColor)
      CompilerIf #cAgent
        \lblSCSHomePageURL=scsHyperLinkGadget(6,208,190,20,#SCS_HOME_PAGE_URL_DISPLAY, #SCS_Blue, #PB_HyperLink_Underline, "lblSCSHomePageURL")
        SetGadgetColor(\lblSCSHomePageURL, #PB_Gadget_BackColor, nBackColor)
      CompilerEndIf
      \lblBuild=scsTextGadget(196,208,180,15,"", #PB_Text_Right, "lblBuild")
      SetGadgetColor(\lblBuild, #PB_Gadget_BackColor, nBackColor)
      
      \lnLine1=scsLineGadget(0,184,382,1,gnSCSColor,0,"lnLine1")
      
      ; license info
      \cntLicence=scsContainerGadget(61,235,256,107,0,"cntLicence")
        \frLicence=scsFrameGadget(0,0,256,107,Lang("WAB", "frLicence"),0,"frLicence")
        \lblLicUser=scsTextGadget(6,20,245,32,"", #PB_Text_Center,"lblLicUser")
        scsSetGadgetFont(\lblLicUser, #SCS_FONT_GEN_BOLD)
        \lblLicType=scsTextGadget(6,58,245,42,"", #PB_Text_Center,"lblLicType")
        scsSetGadgetFont(\lblLicType, #SCS_FONT_GEN_BOLD)
      scsCloseGadgetList() ; frLicence
      
      ; general info
      \lnLine2=scsLineGadget(0,347,382,1,gnSCSColor,0,"lnLine2")
      \lblInfo=scsTextGadget(20,356,343,31,"", #PB_Text_Center, "lblInfo")
      SetGadgetColor(\lblInfo, #PB_Gadget_BackColor, nBackColor)
      nWidth = GetTextWidth(#SCS_URL_DISPLAY)
      nLeft = (WindowWidth(#WAB) - nWidth) >> 1
      \lblURL=scsHyperLinkGadget(nLeft,386,nWidth,20,#SCS_URL_DISPLAY, #SCS_Blue, #PB_HyperLink_Underline, "lblURL")
      SetGadgetColor(\lblURL, #PB_Gadget_BackColor, nBackColor)
      CompilerIf #cAgent
        scsSetGadgetFont(\lblInfo, #SCS_FONT_GEN_BOLD)
        scsSetGadgetFont(\lblURL, #SCS_FONT_GEN_BOLD)
      CompilerEndIf
      \lnLine3=scsLineGadget(0,410,382,1,gnSCSColor,0,"lnLine3")
      
      ; OK button
      \btnOK=scsButtonGadget(148,419,84,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      
      AddKeyboardShortcut(#WAB, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WAB, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
      ; setWindowVisible(#WAB,#True)
      setWindowEnabled(#WAB,#True)
    EndIf
  EndWith
EndProcedure

Structure strWBE ; fmBulkEdit
  btnApply.i
  btnCancel.i
  btnClearAll.i
  btnHelp.i
  btnOK.i
  btnSelectAll.i
  btnViewChanges.i
  cboChangeType.i
  cboDevice.i
  cboField.i
  cboLUFS.i
  cboNewValue.i
  cboNormToApply.i
  chkContinuous.i
  chkNewValue.i
  cntAudioLevelInfo.i
  cntColorKey.i
  cntNewValues.i
  frColorKey.i
  grdBulkEdit.i
  lblCappedLevelWarning.i
  lblChangeType.i
  lblContinuous.i
  lblDevice.i
  lblField.i
  lblLUFS.i
  lblLUFSComment.i
  lblMaxLevel.i
  lblNewLevelDerived.i
  lblNewValue.i
  lblNormToApply.i
  lblTotalPlayLength.i
  txtColorKey.i[4]
  txtMaxLevel.i
  txtNewValue.i
  txtTotalPlayLength.i
EndStructure
Global WBE.strWBE ; fmBulkEdit

Procedure createfmBulkEdit()
  PROCNAMEC()
  Protected nLeft, nTop, nLeftCaption
  Protected nBtnWidth, nGap
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WBE, 0, 0, 900, 453, Lang("WBE","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WBE, "WBE(fmBulkEdit)")
    With WBE
      
      \btnSelectAll=scsButtonGadget(302,5,81,gnBtnHeight,Lang("Btns","SelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(gnNextX+6,5,81,gnBtnHeight,Lang("Btns","ClearAll"),0,"btnClearAll")
      
      nLeft = 10
      nLeftCaption = nLeft + 2 + gl3DBorderWidth ; align captions approximately to the same left of text displayed in the control below the caption
      
      \lblField=scsTextGadget(nLeftCaption,38,280,15,Lang("WBE","lblField"),0,"lblField") ; Field to be changed
      \cboField=scsComboBoxGadget(nLeft,54,280,21,0,"cboField")
      
      \cntAudioLevelInfo=scsContainerGadget(0,81,300,86,#PB_Container_BorderLess,"cntAudioLevelInfo") ; will be displayed only if cboField = Audio Levels
        \lblChangeType=scsTextGadget(nLeftCaption,0,280,15,Lang("WBE","lblChangeType"),0,"lblChangeType")
        \cboChangeType=scsComboBoxGadget(nLeft,16,280,21,0,"cboChangeType")
        \lblDevice=scsTextGadget(nLeftCaption,43,280,15,grText\sTextDevice,0,"lblDevice")
        \cboDevice=scsComboBoxGadget(nLeft,59,280,21,0,"cboDevice")
      scsCloseGadgetList()

      \cntNewValues=scsContainerGadget(0,81,300,80,#PB_Container_BorderLess,"cntNewValues") ; will be positioned dynamically depending on selected cboField value
        nTop = 0
        \lblNewValue=scsTextGadget(nLeftCaption,nTop,170,15,Lang("WBE","lblNewValue"),0,"lblNewValue")
        \lblNormToApply=scsTextGadget(nLeftCaption,nTop,100,15,Lang("WBE","NormToApply"),0,"lblNormToApply")
        setGadgetWidth(\lblNormToApply,-1,#True)
        setVisible(\lblNormToApply,#False)
        ; fields \cboNewValue, \txtNewValue and \chkNewValue are mutually exclusive and so occupy same positions on screen
        nTop + 16
        \cboNewValue=scsComboBoxGadget(nLeft,nTop,280,21,0,"cboNewValue")
        \txtNewValue=scsStringGadget(nLeft,nTop,70,21,"",0,"txtNewValue")
        setVisible(\txtNewValue,#False)
        \lblContinuous=scsTextGadget(gnNextX+gnGap2,nTop+gnLblVOffsetS,20,15,Lang("Common","or"),#PB_Text_Center,"lblContinuous")
        setGadgetWidth(\lblContinuous,-1,#True)
        setVisible(\lblContinuous,#False)
        \chkContinuous=scsCheckBoxGadget(gnNextX+gnGap2,nTop+1,100,17,Lang("Common","Continuous"),0,"chkContinuous")
        setVisible(\chkContinuous,#False)
        \chkNewValue=scsCheckBoxGadget(nLeft,nTop,280,17,"",0,"chkNewValue")
        setVisible(\chkNewValue,#False)
        \cboNormToApply=scsComboBoxGadget(nLeft,nTop,120,21,0,"cboNormToApply")
        setVisible(\cboNormToApply,#False)
        nTop + 27
        \lblLUFS=scsTextGadget(nLeftCaption,nTop,170,15,"LUFS",0,"lblLUFS")
        setVisible(\lblLUFS,#False)
        \lblMaxLevel=scsTextGadget(nLeftCaption,nTop,170,15,Lang("WBE", "MaxLevel"),0,"lblMaxLevel")
        setVisible(\lblMaxLevel,#False)
        nTop + 16
        \cboLUFS=scsComboBoxGadget(nLeft,nTop,30,21,0,"cboLUFS")
        setVisible(\cboLUFS,#False)
        \lblLUFSComment=scsTextGadget(gnNextX+gnGap2,nTop+gnLblVOffsetC,170,15,Lang("WBE","lblLUFSComment"),0,"lblLUFSComment")
        setGadgetWidth(\lblLUFSComment)
        setVisible(\lblLUFSComment,#False)
        \txtMaxLevel=scsStringGadget(nLeft,nTop,70,21,"",0,"txtMaxLevel")
        setVisible(\txtMaxLevel,#False)
        nTop + 37
        \btnViewChanges=scsButtonGadget(nLeft,nTop,87,gnBtnHeight,Lang("WBE","btnViewChanges"),0,"btnViewChanges")
      scsCloseGadgetList()
      
      \lblTotalPlayLength=scsTextGadget(nLeftCaption,217,280,15,Lang("WBE","lblTotalPlayLength"),0,"lblTotalPlayLength")
      setVisible(\lblTotalPlayLength,#False)
      \txtTotalPlayLength=scsStringGadget(40,233,80,21,"",#PB_String_ReadOnly|#PB_String_BorderLess,"txtTotalPlayLength")
      setVisible(\txtTotalPlayLength,#False)
      
      ; bulk edit grid
      \grdBulkEdit=scsListIconGadget(300,30,590,380,grText\sTextSelect,45,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdBulkEdit")
      grWBE\nDefaultGridWidth = GadgetWidth(\grdBulkEdit)
      grWBE\nMaxColNo = 0
      \lblNewLevelDerived=scsTextGadget(300,GadgetY(\grdBulkEdit)-17,100,17,Lang("WBE","NewLevelDerived"),#PB_Text_Center,"lblNewLevelDerived")
      setVisible(\lblNewLevelDerived,#False)
      
      ; color key
      \cntColorKey=scsContainerGadget(70,282,103,97,0,"cntColorKey")
        \frColorKey=scsFrameGadget(0,0,103,97,Lang("WBE","frColorKey"),0,"frColorKey")
        \txtColorKey[0]=scsTextGadget(5,18,87,18," "+Lang("WBE","txtColorKey[0]"),0,"txtColorKey[0]")
        \txtColorKey[1]=scsTextGadget(5,36,87,18," "+Lang("WBE","txtColorKey[1]"),0,"txtColorKey[1]")
        \txtColorKey[2]=scsTextGadget(5,54,87,18," "+Lang("WBE","txtColorKey[2]"),0,"txtColorKey[2]")
        \txtColorKey[3]=scsTextGadget(5,72,87,18," "+Lang("WBE","txtColorKey[3]"),0,"txtColorKey[3]")
      scsCloseGadgetList()
      
      ; dialog buttons
      nGap = 12
      nBtnWidth = 81
      nLeft = (WindowWidth(#WBE) - (nBtnWidth * 4) - (nGap * 3)) >> 1
      nTop = GadgetY(\grdBulkEdit) + GadgetHeight(\grdBulkEdit) + 9
      \btnOK=scsButtonGadget(nLeft,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnApply=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnApply,0,"btnApply")
      \btnHelp=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      ; Capped level warning
      \lblCappedLevelWarning=scsTextGadget(gnNextX+20,nTop+2,200,18," "+Lang("WBE","lblCappedLevelWarning"),0,"lblCappedLevelWarning")
      setGadgetWidth(\lblCappedLevelWarning)
      setVisible(\lblCappedLevelWarning,#False)
      
    EndWith
    SetWindowCallback(@WBE_WinCallbackProc())
    ; setWindowVisible(#WBE,#True)
    setWindowEnabled(#WBE,#True)
    grWBE\nDefaultWindowWidth = WindowWidth(#WBE)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWCMCtrlSetup
  ; gadgets
  btnCtrlNo.i
  cntCtrl.i
  cvsMIDI.i
  ; runtime variables
  nCtrlType.i
EndStructure

Structure strWCM ; fmCtrlSetup
  ; gadgets
  Array aBankSetup.strWCMCtrlSetup(2)
  Array aCtrlSetup.strWCMCtrlSetup(16)
  btnCancel.i
  btnHelp.i
  btnOK.i
  cboController.i
  cboCtrlConfig.i
  cboMidiInPort.i
  cboMidiOutPort.i
  chkIncludeGoEtc.i
  ; chkShowMidi.i
  cntCueCtrl.i
  cntStdCtrl.i
  cvsCueCtrlDetail.i
  cvsStdCtrlDetail.i
  lblController.i
  lblCtrlConfig.i
  lblInfoLine1.i
  lblInfoLine2.i
  lblMidiInPort.i
  lblMidiOutPort.i
EndStructure
Global WCM.strWCM ; fmCtrlSetup

Procedure createfmCtrlSetup()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight, nGap
  Protected nCntTop, nCntWidth, nCntHeight, nItemHeight, nInnerWidth, nInnerHeight
  Protected sNr.s
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  If OpenWindow(#WCM, 0, 0, 690, 490, Lang("WCM","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WCN))
    registerWindow(#WCM, "WCM(fmCtrlSetup)")
    
    With WCM
      nTop = 8
      \lblController=scsTextGadget(12,nTop+gnLblVOffsetC,100,15,Lang("WCM","lblController"),#PB_Text_Right,"lblController")
      \cboController=scsComboBoxGadget(gnNextX+gnGap,nTop,170,21,0,"cboController")
      nCntTop = nTop + GadgetHeight(\cboController)
      nCntWidth = WindowWidth(#WCM)
      nCntHeight = WindowHeight(#WCM) - nCntTop - (gnBtnHeight + 16)
      \cntStdCtrl=scsContainerGadget(0,nCntTop,nCntWidth,nCntHeight,0,"cntStdCtrl")
        nTop = 0
        \lblMidiInPort=scsTextGadget(12,nTop+gnLblVOffsetC,100,15,Lang("WCM","lblMidiInPort"),#PB_Text_Right,"lblMidiInPort")
        \cboMidiInPort=scsComboBoxGadget(gnNextX+gnGap,nTop,170,21,0,"cboMidiInPort")
        \lblMidiOutPort=scsTextGadget(gnNextX+12,nTop+gnLblVOffsetC,100,15,Lang("WCM","lblMidiOutPort"),#PB_Text_Right,"lblMidiOutPort")
        \cboMidiOutPort=scsComboBoxGadget(gnNextX+gnGap,nTop,170,21,0,"cboMidiOutPort")
        nTop + 21
        \lblCtrlConfig=scsTextGadget(12,nTop+gnLblVOffsetC,100,15,Lang("WCM","lblCtrlConfig"),#PB_Text_Right,"lblCtrlConfig")
        \cboCtrlConfig=scsComboBoxGadget(gnNextX+gnGap,nTop,240,21,0,"cboCtrlConfig")
        nLeft = GadgetX(\cboMidiOutPort)
        \chkIncludeGoEtc=scsCheckBoxGadget(nLeft,nTop+4,200,17,Lang("WCM","chkIncludeGoEtc"),0,"chkIncludeGoEtc")
        nWidth = GadgetWidth(\chkIncludeGoEtc, #PB_Gadget_RequiredSize)
        ResizeGadget(\chkIncludeGoEtc,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        nLeft = gnNextX + 8
        nTop + 29
        nLeft = 4
        nWidth = nCntWidth - (nLeft * 2)
        nHeight = 330
        \cvsStdCtrlDetail=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsStdCtrlDetail")
        nTop + GadgetHeight(\cvsStdCtrlDetail) + 8
        nLeft = 20
        nWidth = nCntWidth - 40
        \lblInfoLine1=scsTextGadget(nLeft,nTop,nWidth,15,"",#PB_Text_Center,"lblInfoLine1")
        nTop + 17
        \lblInfoLine2=scsTextGadget(nLeft,nTop,nWidth,15,"",#PB_Text_Center,"lblInfoLine2")
      scsCloseGadgetList()
      \cntCueCtrl=scsContainerGadget(0,nCntTop,nCntWidth,nCntHeight,0,"cntCueCtrl")
        nTop = 12
        nLeft = 4
        nWidth = nCntWidth - (nLeft * 2)
        nHeight = nCntHeight - nTop - 4
        \cvsCueCtrlDetail=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsCueCtrlDetail")
      scsCloseGadgetList()
      nTop = GadgetY(\cntStdCtrl) + GadgetHeight(\cntStdCtrl) + 8
      nWidth = 60
      nHeight = 23
      nGap = 4
      nLeft = (WindowWidth(#WCM) - ((nWidth * 3) + (nGap * 2))) >> 1
      \btnOK=scsButtonGadget(nLeft, nTop, nWidth, nHeight, grText\sTextBtnOK,0,"btnOK")
      nLeft + nWidth + nGap
      \btnCancel=scsButtonGadget(nLeft, nTop, nWidth, nHeight, grText\sTextBtnCancel,0,"btnCancel")
      nLeft + nWidth + nGap
      \btnHelp=scsButtonGadget(nLeft, nTop, nWidth, nHeight, grText\sTextBtnHelp,0,"btnHelp")
      
    EndWith
    
    setWindowEnabled(#WCM,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWCNController
  ; gadgets
  cntCtrl.i
  cvsEQInd.i
  cvsLabel.i
  cvsLive.i
  cvsMute.i
  cvsSelect.i
  cvsSolo.i
  sldLevelOrValue.i
  ; runtime variables
  nWCNCtrlType.i
  nWCNCtrlNo.i         ; controller number within control type, base 1 (eg first live input is 1, and first output is 1)
  nWCNSliderType.i
  sWCNLabel.s
  sWCNLogicalDev.s
  nWCNDevMapDevPtr.i
  nWCNDevNo.i
  nLeft.i
  bLiveOn.i
  bMuteOn.i
  bSaveEnabled.i
  bSoloOn.i
  fBVLevel.f
  sDBLevel.s
  sInitialDBLevel.s
  nValue.i
  nInitialValue.i
  bDMXSliderUsed.i
  rOrigDev.tyDevMapDev  ; device settings as at 'prime' or last save, used for checking EQ changes
  nWCNDimmerChan.i        ; Added 11Jul2022 11.9.4 for DMX fixtures included in the controllers
  nWCNDMXSendItemIndex.i  ; Added 13Jul2022 11.9.4
  dWCNPrevValue.d
  bSliderValueMatched.i   ; Added 16Oct2023 11.10.0ck for controllers like the NK2 that do not have motorized faders, where action on fader moveent has to wait until the fader value matches (or closely matches) the SCS level
EndStructure

Structure strWCN ; fmControllers
  ; gadgets
  Array aController.strWCNController(8)
  btnClearSolos.i
  btnClose.i
  btnLoCut.i
  btnSave.i
  btnSetup.i
  cntEQPanel.i
  cntKnob.i[7]
  cntMain.i
  cvsDimmerChanTitle.i
  cvsDMXMasterTitle.i
  cvsEQBand.i[2]
  cvsFaderAssignments.i[3]
  cvsInputTitle.i
  cvsLoCut.i
  cvsOutputTitle.i
  cvsMasterTitle.i
  cvsPlayingTitle.i
  lblCtrlConfig.i
  lblLoCutFreq.i
  lblEQQ.i[2]
  lblEQFreq.i[2]
  lblEQGain.i[2]
  lblSelection.i
  ; runtime variables (sorted)
  bDisplayClearSolos.i
  bDisplayEQPanel.i
  bDisplaySaveFaderLevels.i
  bDisplaySoloAndMute.i
  bEQChanged.i
  bRefreshAudioChannelFaders.i
  bRefreshDimmerChannelFaders.i
  bUseFaders.i
  nCtrlGap.i
  nCtrlWidth.i
  nDimmerChanCtrls.i
  nDMXMasterCtrls.i
  nDMXMasterIndex.i
  nFirstVidAudIndex.i ; used for NK2 Preset C (faders for earliest playing cue) to identify indexd of the first video audio fader (-1 if not required)
  nLiveInputCtrls.i
  nLiveInputSolos.i
  nMasterCtrls.i
  nMasterIndex.i
  nMaxEQControl.i
  nNrOfControllers.i
  nNrOfEQControls.i
  nOutputCtrls.i
  nOutputSolos.i
  nPlayingCtrls.i
  nPlayingSubTypeF.i ; used for NK2 Preset C (faders for earliest playing cue)
  nSelectedController.i
  sldDMXMasterFader.i ; nb derived
EndStructure
Global WCN.strWCN ; fmControllers

Procedure createfmControllers()
  PROCNAMEC()
  Protected nTitleLeft, nTitleTop, nTitleWidth, nTitleHeight
  Protected nCtrlLeft, nCtrlTop, nCtrlWidth, nCtrlHeight, nCtrlGap
  Protected nFaderLeft, nFaderWidth, nFaderHeight
  Protected nWindowWidth, nWindowHeight
  Protected nBtnWidth, nBtnHeight, nBtnGap
  Protected nBtnClearSolosWidth, nBtnSaveWidth, nBtnSetUpWidth, nBtnCloseWidth
  Protected nSelectWidth
  Protected nReqdMinWindowWidth
  Protected nLeft, nTop, nWidth, nHeight, nGap
  Protected n, n2, n2Max, nSliderType
  Protected sNr.s
  Protected nInputTitleWidth, nOutputTitleWidth, nPlayingTitleWidth, nMasterTitleWidth, nDMXMasterTitleWidth, nDimmerChanTitleWidth
  Protected sText.s, nTextLeft, nTextTop, nTextWidth
  Protected bFirst
  Protected nEQPanelLeft, nEQPanelTop, nEQPanelWidth, nEQPanelHeight
  Protected nEQKnobLeft, nEQKnobTop, nEQKnobDiameter
  Protected nKnobType, nEQBand
  Protected nBtnTextPadding = gl3DBorderAllowanceX + 10
  
  ; debugMsg0(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  nBtnClearSolosWidth = GetTextWidth(Lang("WCN","btnClearSolos")) + nBtnTextPadding
  nBtnSaveWidth = GetTextWidth(Lang("WCN","btnSave")) + nBtnTextPadding
  nBtnCloseWidth = GetTextWidth(Lang("Btns","Close")) + nBtnTextPadding
  nBtnSetUpWidth = GetTextWidth(Lang("WCN","btnSetup")) + nBtnTextPadding
  nSelectWidth = GetTextWidth(grText\sTextSelect)
  If nSelectWidth < 40
    nSelectWidth = 40
  ElseIf nSelectWidth > 50
    nSelectWidth = 50
  EndIf
  debugMsg(sProcName, "nBtnClearSolosWidth=" + nBtnClearSolosWidth + ", nBtnSaveWidth=" + nBtnSaveWidth + ", nBtnCloseWidth=" + nBtnCloseWidth + ", nBtnSetUpWidth=" + nBtnSetUpWidth)

  nGap = 4
  nReqdMinWindowWidth = nBtnSaveWidth + nBtnCloseWidth + nBtnSetUpWidth + (nGap * 2) + 16  ; 8 left and right of buttons
  If WCN\bDisplayClearSolos
    nReqdMinWindowWidth + nBtnClearSolosWidth + nGap
  EndIf
  
  nCtrlLeft = 4
  nCtrlWidth = 64
  nCtrlGap = 1
  WCN\nCtrlWidth = nCtrlWidth
  WCN\nCtrlGap = nCtrlGap
  
  If WCN\bDisplayEQPanel
    WCN\nNrOfEQControls = 7
    WCN\nMaxEQControl = WCN\nNrOfEQControls - 1
    nEQPanelLeft = nCtrlLeft
    nEQPanelTop = 4
    nEQKnobDiameter = 50
    nEQPanelHeight = 120
    nEQPanelWidth = (nCtrlWidth+nCtrlGap) * WCN\nNrOfEQControls
  EndIf
  
  nTitleLeft = nCtrlLeft
  nTitleTop = nEQPanelTop + nEQPanelHeight + 4
  nTitleHeight = 17
  nCtrlTop = nTitleTop + nTitleHeight
  If WCN\bDisplayEQPanel
    nCtrlHeight = 275
  Else
    nCtrlHeight = 254  ; 'Select' button not displayed if the EQ panel is not displayed
  EndIf
  nWindowWidth = (nCtrlLeft << 1) + ((nCtrlWidth+nCtrlGap) * WCN\nNrOfControllers) - 1
  If nWindowWidth < nEQPanelWidth
    nWindowWidth = nEQPanelWidth
  EndIf
  If nWindowWidth < nReqdMinWindowWidth
    nWindowWidth = nReqdMinWindowWidth
  EndIf
  nWindowHeight = nCtrlTop + nCtrlHeight + 70 ; 50
  nTitleWidth = nWindowWidth - (nTitleLeft << 1)
  nFaderWidth = nCtrlWidth - 2
  nFaderLeft = (nCtrlWidth - nFaderWidth) >> 1
  nFaderHeight = 205
  nBtnWidth = 16  ; see also WCN_setButtons()
  nBtnHeight = 16 ; see also WCN_setButtons()
  nBtnGap = 2
  nTextTop = 1 ; see also WCN_setPlayingControlsIfReqd()
  
  nEQKnobLeft = (nCtrlWidth - nEQKnobDiameter) >> 1
  nEQKnobTop = 17
  
  If OpenWindow(#WCN, 0, 0, nWindowWidth, nWindowHeight, Lang("WCN","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WCN, "WCN(fmControllers)")
    SetWindowCallback(@WCN_windowCallback(), #WCN)  ; window callback
    
    With WCN
      If \bDisplayEQPanel
        \cntEQPanel=scsContainerGadget(nEQPanelLeft,nEQPanelTop,nEQPanelWidth,nEQPanelHeight,#PB_Container_Flat,"cntEQPanel")
          nLeft = 0
          nTop = 0
          nHeight = 15
          nWidth = nCtrlWidth
          \cvsLoCut=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsLoCut")
          nLeft + nWidth + 1
          For n = 0 To 1
            sNr = "[" + n + "]"
            nWidth = ((nCtrlWidth + 1) * 3) - 1
            \cvsEQBand[n]=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsEQBand" + sNr)
            nLeft + nWidth + 1
          Next n
          nLeft = 0
          nTop + nHeight + 1
          nWidth = nCtrlWidth
          
          \lblLoCutFreq=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WCN","lblEQFreq"),#PB_Text_Center,"lblLoCutFreq" + sNr)
          SetGadgetColor(\lblLoCutFreq, #PB_Gadget_BackColor, _BkRGB)
          SetGadgetColor(\lblLoCutFreq, #PB_Gadget_FrontColor, #SCS_White)
          nLeft + nCtrlWidth + 1
          For n = 0 To 1
            sNr = "[" + n + "]"
            \lblEQGain[n]=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WCN","lblEQGain"),#PB_Text_Center,"lblEQGain" + sNr)
            SetGadgetColor(\lblEQGain[n], #PB_Gadget_BackColor, _BkRGB)
            SetGadgetColor(\lblEQGain[n], #PB_Gadget_FrontColor, #SCS_White)
            nLeft + nWidth + nCtrlGap
            \lblEQFreq[n]=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WCN","lblEQFreq"),#PB_Text_Center,"lblEQFreq" + sNr)
            SetGadgetColor(\lblEQFreq[n], #PB_Gadget_BackColor, _BkRGB)
            SetGadgetColor(\lblEQFreq[n], #PB_Gadget_FrontColor, #SCS_White)
            nLeft + nWidth + nCtrlGap
            \lblEQQ[n]=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WCN","lblEQQ"),#PB_Text_Center,"lblEQQ" + sNr)
            SetGadgetColor(\lblEQQ[n], #PB_Gadget_BackColor, _BkRGB)
            SetGadgetColor(\lblEQQ[n], #PB_Gadget_FrontColor, #SCS_White)
            nLeft + nWidth + nCtrlGap
          Next n
          
          nLeft = 0
          nTop + nHeight + 1
          nWidth = nCtrlWidth
          nHeight = nEQKnobDiameter + nEQKnobTop + 4
          For n = 0 To 6
            sNr = "[" + n + "]"
            \cntKnob[n]=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntKnob" + sNr)
              SetGadgetColor(\cntKnob[n], #PB_Gadget_BackColor, _BkRGB)
              Select n
                Case 0
                  nKnobType = #SCS_EQTYPE_LOWCUT_FREQ
                Case 1, 4
                  nKnobType = #SCS_EQTYPE_GAIN
                Case 2, 5
                  nKnobType = #SCS_EQTYPE_FREQ
                Case 3, 6
                  nKnobType = #SCS_EQTYPE_Q
              EndSelect
              Select n
                Case 1 To 3
                  nEQBand = 1
                Case 2 To 6
                  nEQBand = 2
                Default
                  nEQBand = -1
              EndSelect
              KNOBSetting(n+1, nEQKnobLeft, nEQKnobTop, nEQKnobDiameter, nKnobType, nEQBand)
            scsCloseGadgetList()
            nLeft + nCtrlWidth + nCtrlGap
          Next n
          
          nLeft = 0
          nTop + nHeight + 1
          nWidth = nEQPanelWidth
          nHeight = 15
          \lblSelection=scsTextGadget(nLeft, nTop, nWidth, nHeight, "",#PB_Text_Center,"lblSelection")
          SetGadgetColor(\lblSelection, #PB_Gadget_BackColor, _BkRGB)
          SetGadgetColor(\lblSelection, #PB_Gadget_FrontColor, #SCS_White)
          
        scsCloseGadgetList()
      EndIf
    EndWith
    
    nInputTitleWidth = WCN\nLiveInputCtrls * (nCtrlWidth+nCtrlGap)
    nOutputTitleWidth = WCN\nOutputCtrls * (nCtrlWidth+nCtrlGap)
    nPlayingTitleWidth = WCN\nPlayingCtrls * (nCtrlWidth+nCtrlGap)
    Select grCtrlSetup\nCtrlConfig
      Case #SCS_CTRLCONF_NK2_PRESET_B
        nMasterTitleWidth = WCN\nMasterCtrls * (nCtrlWidth+nCtrlGap)
      Default
        nMasterTitleWidth = WCN\nMasterCtrls * (nCtrlWidth+nCtrlGap) - 1 ; deduct 1 for the right-most control
    EndSelect
    nDMXMasterTitleWidth = WCN\nDMXMasterCtrls * (nCtrlWidth+nCtrlGap)
    nDimmerChanTitleWidth = WCN\nDimmerChanCtrls * (nCtrlWidth+nCtrlGap) - 1 ; deduct 1 for the right-most control
    bFirst = #True
    nLeft = nCtrlLeft
    If nInputTitleWidth > 0
      ; Live Inputs
      WCN\cvsInputTitle=scsCanvasGadget(nLeft,nTitleTop,nInputTitleWidth,nTitleHeight,0,"cvsInputTitle")
      If StartDrawing(CanvasOutput(WCN\cvsInputTitle))
        If bFirst
          LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        sText = Lang("WCN","InputGainL")
        nTextWidth = TextWidth(sText)
        If nTextWidth > (nInputTitleWidth-1)
          sText = Lang("WCN","InputGainS")
          nTextWidth = TextWidth(sText)
        EndIf
        If nTextWidth < (nInputTitleWidth-1)
          nTextLeft = (nInputTitleWidth-1 - nTextWidth) >> 1
        Else
          nTextLeft = 1
        EndIf
        LineXY(0,0,nInputTitleWidth,0,#SCS_Dark_Grey)
        DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
        LineXY(nInputTitleWidth-1,0,nInputTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
        StopDrawing()
      EndIf
      bFirst = #False
      nLeft + nInputTitleWidth
    EndIf
    
    If nOutputTitleWidth > 0
      ; Output Gain
      WCN\cvsOutputTitle=scsCanvasGadget(nLeft,nTitleTop,nOutputTitleWidth,nTitleHeight,0,"cvsOutputTitle")
      If StartDrawing(CanvasOutput(WCN\cvsOutputTitle))
        If bFirst
          LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        sText = Lang("WCN","OutputGainL")
        nTextWidth = TextWidth(sText)
        If nTextWidth > (nOutputTitleWidth-1)
          sText = Lang("WCN","OutputGainS")
          nTextWidth = TextWidth(sText)
        EndIf
        If nTextWidth < (nOutputTitleWidth-1)
          nTextLeft = (nOutputTitleWidth-1 - nTextWidth) >> 1
        Else
          nTextLeft = 1
        EndIf
        LineXY(0,0,nOutputTitleWidth,0,#SCS_Dark_Grey)
        DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
        LineXY(nOutputTitleWidth-1,0,nOutputTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
        StopDrawing()
      EndIf
      bFirst = #False
      nLeft + nOutputTitleWidth
    EndIf
    
    If nPlayingTitleWidth > 0
      ; Playing Level (Level of playing cue)
      WCN\cvsPlayingTitle=scsCanvasGadget(nLeft,nTitleTop,nPlayingTitleWidth,nTitleHeight,0,"cvsPlayingTitle")
      If StartDrawing(CanvasOutput(WCN\cvsPlayingTitle))
        If bFirst
          LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        sText = grText\sTextLevel ; "Level"
        nTextWidth = TextWidth(sText)
        If nTextWidth < (nPlayingTitleWidth-1)
          nTextLeft = (nPlayingTitleWidth-1 - nTextWidth) >> 1
        Else
          nTextLeft = 1
        EndIf
        LineXY(0,0,nPlayingTitleWidth,0,#SCS_Dark_Grey)
        DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
        LineXY(nPlayingTitleWidth-1,0,nPlayingTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
        StopDrawing()
      EndIf
      bFirst = #False
      nLeft + nPlayingTitleWidth
    EndIf
    
    If nMasterTitleWidth > 0
      ; Master (audio)
      WCN\cvsMasterTitle=scsCanvasGadget(nLeft,nTitleTop,nMasterTitleWidth,nTitleHeight,0,"cvsMasterTitle")
      If StartDrawing(CanvasOutput(WCN\cvsMasterTitle))
        If bFirst
          LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        sText = Lang("Common","Master")
        nTextWidth = TextWidth(sText)
        If nTextWidth < (nMasterTitleWidth-1)
          nTextLeft = (nMasterTitleWidth-1 - nTextWidth) >> 1
        Else
          nTextLeft = 1
        EndIf
        LineXY(0,0,nMasterTitleWidth,0,#SCS_Dark_Grey)
        DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
        LineXY(nMasterTitleWidth-1,0,nMasterTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
        StopDrawing()
      EndIf
      bFirst = #False
      nLeft + nMasterTitleWidth
    EndIf
    
    If gbDMXAvailable
      If nDMXMasterTitleWidth > 0
        ; DMX (master)
        WCN\cvsDMXMasterTitle=scsCanvasGadget(nLeft,nTitleTop,nDMXMasterTitleWidth,nTitleHeight,0,"cvsDMXMasterTitle")
        If StartDrawing(CanvasOutput(WCN\cvsDMXMasterTitle))
          If bFirst
            LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
          EndIf
          DrawingMode(#PB_2DDrawing_Transparent)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          sText = "DMX"
          nTextWidth = TextWidth(sText)
          If nTextWidth < (nDMXMasterTitleWidth-1)
            nTextLeft = (nDMXMasterTitleWidth-1 - nTextWidth) >> 1
          Else
            nTextLeft = 1
          EndIf
          LineXY(0,0,nDMXMasterTitleWidth,0,#SCS_Dark_Grey)
          DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
          LineXY(nDMXMasterTitleWidth-1,0,nDMXMasterTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
          StopDrawing()
        EndIf
        bFirst = #False
        nLeft + nDMXMasterTitleWidth
        
        If nDimmerChanTitleWidth > 0
          ; Dimmer Channels
          WCN\cvsDimmerChanTitle=scsCanvasGadget(nLeft,nTitleTop,nDimmerChanTitleWidth,nTitleHeight,0,"cvsDimmerChanTitle")
          If StartDrawing(CanvasOutput(WCN\cvsDimmerChanTitle))
            If bFirst
              LineXY(0,0,0,nTitleHeight,#SCS_Dark_Grey)
            EndIf
            DrawingMode(#PB_2DDrawing_Transparent)
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            sText = Lang("WCN","DimmerChanL") ; L = 'Large' for wider available text space
            nTextWidth = TextWidth(sText)
            If nTextWidth > (nDimmerChanTitleWidth-1)
              sText = Lang("WCN","DimmerChanS") ; S = 'Small' for smaller available text space
              nTextWidth = TextWidth(sText)
            EndIf
            If nTextWidth < (nDimmerChanTitleWidth-1)
              nTextLeft = (nDimmerChanTitleWidth-1 - nTextWidth) >> 1
            Else
              nTextLeft = 1
            EndIf
            LineXY(0,0,nDimmerChanTitleWidth,0,#SCS_Dark_Grey)
            DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
            LineXY(nDimmerChanTitleWidth-1,0,nDimmerChanTitleWidth-1,nTitleHeight,#SCS_Dark_Grey)
            StopDrawing()
          EndIf
          bFirst = #False
          nLeft + nDimmerChanTitleWidth
        EndIf
      
      EndIf
    EndIf
    
    ReDim WCN\aController(WCN\nNrOfControllers)
    n = 0
    For nSliderType = #SCS_ST_VFADER_LIVE_INPUT To #SCS_ST_VFADER_DIMMER_CHAN ; #SCS_ST_VFADER_DMX_MASTER
      ; debugMsg(sProcName, "nSliderType=" + nSliderType)
      Select nSliderType
        Case #SCS_ST_VFADER_LIVE_INPUT
          n2Max = WCN\nLiveInputCtrls
        Case #SCS_ST_VFADER_OUTPUT
          n2Max = WCN\nOutputCtrls
        Case #SCS_ST_VFADER_PLAYING
          n2Max = WCN\nPlayingCtrls
        Case #SCS_ST_VFADER_MASTER
          n2Max = WCN\nMasterCtrls
        Case #SCS_ST_VFADER_DMX_MASTER
          n2Max = WCN\nDMXMasterCtrls
        Case #SCS_ST_VFADER_DIMMER_CHAN
          n2Max = WCN\nDimmerChanCtrls
      EndSelect
      For n2 = 1 To n2Max
        n + 1
        With WCN\aController(n)
          sNr = "[" + n + "]"
          \nWCNSliderType = nSliderType
          nLeft = nCtrlLeft + ((nCtrlWidth+nCtrlGap) * (n-1))
          ; debugMsg(sProcName, "n=" + n + ", nLeft=" + nLeft + ", \nWCNSliderType=" + \nWCNSliderType)
          \cntCtrl=scsContainerGadget(nLeft,nCtrlTop,nCtrlWidth,nCtrlHeight,0,"cntCtrl"+sNr)
            SetGadgetColor(\cntCtrl, #PB_Gadget_BackColor, $606060)
            nTop = 4
            Select nSliderType
              Case #SCS_ST_VFADER_DIMMER_CHAN, #SCS_ST_VFADER_DMX_MASTER
                \sldLevelOrValue=SLD_New("CN_DMX_"+Str(n+1),\cntCtrl,0,nFaderLeft,nTop,nFaderWidth,nFaderHeight,nSliderType,0,255) ; nb max for DMX faders = 255, which is the maximum DMX value
                If nSliderType = #SCS_ST_VFADER_DMX_MASTER
                  WCN\sldDMXMasterFader = \sldLevelOrValue
                EndIf
              Default
                \sldLevelOrValue=SLD_New("CN_Level_"+Str(n+1),\cntCtrl,0,nFaderLeft,nTop,nFaderWidth,nFaderHeight,nSliderType,0,10000) ; nb max for audio faders = 10000 as for all other audio faders in SCS
                SLD_setControlKeyAction(\sldLevelOrValue, #SCS_SLD_CCK_0DB)
            EndSelect
            nTop + SLD_gadgetHeight(\sldLevelOrValue) + 2
            Select nSliderType
              Case #SCS_ST_VFADER_LIVE_INPUT
                nLeft = (nCtrlWidth - ((nBtnWidth * 3) + (nBtnGap * 2))) >> 1
              Case #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_PLAYING
                nLeft = (nCtrlWidth - ((nBtnWidth * 2) + (nBtnGap * 1))) >> 1
            EndSelect
            If nSliderType = #SCS_ST_VFADER_LIVE_INPUT
              \cvsLive=scsCanvasGadget(nLeft,nTop,nBtnWidth,nBtnHeight,0,"cvsLive"+sNr,WCN\aController(1)\cvsLive)
              nLeft + nBtnWidth + nBtnGap
            EndIf
            If (nSliderType = #SCS_ST_VFADER_LIVE_INPUT) Or (nSliderType = #SCS_ST_VFADER_OUTPUT)
              If WCN\bDisplaySoloAndMute
                \cvsMute=scsCanvasGadget(nLeft,nTop,nBtnWidth,nBtnHeight,0,"cvsMute"+sNr,WCN\aController(1)\cvsMute)
                scsToolTip(\cvsMute, grText\sTextMute)
                nLeft + nBtnWidth + nBtnGap
                \cvsSolo=scsCanvasGadget(nLeft,nTop,nBtnWidth,nBtnHeight,0,"cvsSolo"+sNr,WCN\aController(1)\cvsSolo)
                scsToolTip(\cvsSolo, grText\sTextSolo)
                nLeft + nBtnWidth + nBtnGap
              EndIf
            EndIf
            nTop + nBtnHeight + 5
            nWidth = nSelectWidth
            nLeft = (nCtrlWidth - nWidth) >> 1
            If WCN\bDisplayEQPanel
              If (nSliderType = #SCS_ST_VFADER_LIVE_INPUT) ; Or (nSliderType = #SCS_ST_VFADER_OUTPUT)
                \cvsSelect=scsCanvasGadget(nLeft,nTop,nWidth,18,0,"cvsSelect"+sNr,WCN\aController(1)\cvsSelect)
                nLeft + nWidth + 1
                nWidth = nCtrlWidth - nLeft
                \cvsEQInd=scsCanvasGadget(nLeft,nTop,nWidth,18,0,"cvsEQInd"+sNr,WCN\aController(1)\cvsEQInd)
              EndIf
              nTop + 23
            EndIf
            nLeft = 0
            nWidth = nCtrlWidth - nLeft - nLeft
            \cvsLabel=scsCanvasGadget(nLeft,nTop,nWidth,20,0,"cvsLabel"+sNr,WCN\aController(1)\cvsLabel)
          scsCloseGadgetList()
        EndWith
      Next n2
    Next nSliderType
    
    With WCN
      nLeft = 8
      nTop = nCtrlTop + nCtrlHeight + 3
      nWidth = 8
      nHeight = 16
      ; note: \cvsFaderAssignments[] will be resized and displayed if required, so initial left and width are not significant
      For n = 0 To 2
        sNr = "[" + n + "]"
        \cvsFaderAssignments[n]=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsFaderAssignments" + sNr)
        setVisible(\cvsFaderAssignments[n],#False)
        nLeft + nWidth + 1
      Next n
      nLeft = 8
      nTop + GadgetHeight(\cvsFaderAssignments) + 3
      \lblCtrlConfig=scsTextGadget(nLeft,nTop,100,15,"",0,"lblCtrlConfig")
      nTop + 17
      nHeight = 23
      nGap = 4
      If \bDisplayClearSolos
        \btnClearSolos=scsButtonGadget(nLeft,nTop,nBtnClearSolosWidth,nHeight,Lang("WCN","btnClearSolos"),0,"btnClearSolos")
        nLeft + nBtnClearSolosWidth + nGap
      EndIf
      If \bDisplaySaveFaderLevels
        \btnSave=scsButtonGadget(nLeft,nTop,nBtnSaveWidth,nHeight,Lang("WCN","btnSave"),0,"btnSave")
      EndIf
      nLeft = WindowWidth(#WCN) - (nBtnCloseWidth + nGap + nBtnSetUpWidth) - 8
      \btnClose=scsButtonGadget(nLeft,nTop,nBtnCloseWidth,nHeight,Lang("Btns","Close"),0,"btnClose")
      nLeft + nBtnCloseWidth + nGap
      \btnSetup=scsButtonGadget(nLeft,nTop,nBtnSetUpWidth,nHeight,Lang("WCN","btnSetup"),0,"btnSetup")
    EndWith
    
    ; setWindowVisible(#WCN,#True)
    setWindowEnabled(#WCN,#True)
    ; debugMsg0(sProcName, #SCS_END)
    ProcedureReturn #True
  Else
    ; debugMsg0(sProcName, #SCS_END)
    ProcedureReturn #False
  EndIf
  
EndProcedure

Structure strWCP  ; fmCopyProps
  btnCancel.i
  btnClearAll.i
  btnCopy.i
  btnHelp.i
  btnSelectAll.i
  cboCFCue.i
  chkProperty.i[#SCS_MAX_ITEM_IN_COPY_PROPERTIES+1]
  lblCFCue.i
  lblCueType.i
  lblInfo.i
  lblThisCue.i
  txtCueType.i
  txtThisCue.i
EndStructure
Global WCP.strWCP ; fmCopyProps

Procedure createfmCopyProps()
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, nHeight
  Protected nWindowWidth, nReqdWindowHeight
  Protected sNr.s
  Protected sInfo.s, nInfoTextWidth
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WCP, 0, 0, 620, 410, Lang("WCP","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WCP, "WCP(fmCopyProps)")
    nWindowWidth = WindowWidth(#WCP)
    With WCP
      nLeft = 20
      nTop = 12
      \lblCFCue=scsTextGadget(nLeft,nTop+gnLblVOffsetS,100,15,Lang("WCP","lblCFCue"),#PB_Text_Right,"lblCFCue")
      setGadgetWidth(\lblCFCue,100)
      \lblThisCue=scsTextGadget(nLeft,nTop+28,100,15,Lang("WCP","lblThisCue"),#PB_Text_Right,"lblThisCue")
      setGadgetWidth(\lblThisCue,100)
      \lblCueType=scsTextGadget(nLeft,nTop+53,100,15,Lang("Common","CueType"),#PB_Text_Right,"lblCueType")
      nWidth = GadgetWidth(\lblThisCue)
      If GadgetWidth(\lblCFCue) > nWidth
        nWidth = GadgetWidth(\lblCFCue)
      EndIf
      ResizeGadget(\lblThisCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      ResizeGadget(\lblCueType,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      ResizeGadget(\lblCFCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
      nLeft + nWidth + gnGap
      \cboCFCue=scsComboBoxGadget(nLeft,nTop,300,21,0,"cboCFCue")
      \txtThisCue=scsStringGadget(nLeft,nTop+25,300,21,"",#PB_String_ReadOnly,"txtThisCue")
      \txtCueType=scsStringGadget(nLeft,nTop+50,150,21,"",#PB_String_ReadOnly,"txtCueType")
      
      nTop + 90
      \lblInfo=scsTextGadget(0,nTop,nWindowWidth,20,Lang("WCP", "lblInfo"),#PB_Text_Center,"lblInfo")
      scsSetGadgetFont(\lblInfo, #SCS_FONT_GEN_BOLD)
      
      nTop + 22
      nLeft = GadgetX(\cboCFCue)
      
      \btnSelectAll=scsButtonGadget(nLeft,nTop,81,gnBtnHeight,Lang("Btns","SelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(gnNextX+6,nTop,81,gnBtnHeight,Lang("Btns","ClearAll"),0,"btnClearAll")
      nTop + 27
      nHeight = 17
      nWidth = 240
      For n = 0 To #SCS_MAX_ITEM_IN_COPY_PROPERTIES
        sNr = "[" + n + "]"
        \chkProperty[n]=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, "",0,"chkProperty"+sNr)
        nTop + 20
        setVisible(\chkProperty[n],#False)
      Next n
      
      nTop + 20
      nLeft = (nWindowWidth - 202) / 2
      \btnCopy=scsButtonGadget(nLeft,nTop,64,gnBtnHeight,Lang("Btns","Copy"),#PB_Button_Default,"btnCopy")
      \btnCancel=scsButtonGadget(gnNextX+gnGap,nTop,64,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(gnNextX+gnGap,nTop,64,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      AddKeyboardShortcut(#WCP, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      AddKeyboardShortcut(#WCP, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      
      nReqdWindowHeight = nTop + GadgetHeight(\btnCopy) + 16
      ResizeWindow(#WCP,#PB_Ignore,#PB_Ignore,#PB_Ignore,nReqdWindowHeight)
      
    EndWith
    
    ; setWindowVisible(#WCP,#True)
    setWindowEnabled(#WCP,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure

Structure strWAC ; fmAGColors (audio graph colors)
  btnCancel.i
  btnOK.i
  btnReset.i
  btnUseClassic.i
  btnUseDflts.i
  chkRightSameAsLeft.i
  cboScheme.i
  cvsCursorColor.i
  cvsLeftColor.i
  cvsLeftColorPlay.i
  cvsRightColor.i
  cvsRightColorPlay.i
  cvsCPSample.i
  cvsCPSamplePlay.i
  cvsEDSample.i
  lblCursorColor.i
  lblDarkenFactor.i
  lblLeftColor.i
  lblLeftColorPlay.i
  lblRightColor.i
  lblRightColorPlay.i
  lblCPSample.i
  lblCPSamplePlay.i
  lblEDSample.i
  lblScheme.i
  lnHdgSep.i
  lnSampleSep.i
  trbDarkenFactor.i
EndStructure
Global WAC.strWAC ; fmAGColors

Procedure createfmAGColors()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth
  Protected nLblLeft, nLblWidth, nCtrlLeft, nCtrlWidth
  Protected nLblPlayLeft, nLblPlayWidth, nCtrlPlayLeft, nCtrlPlayWidth
  Protected nWindowWidth, nWindowHeight, nBtnWidth, nBtnGap
  Protected nEDSampleRight, nBtnPadRight
  
  If IsWindow(#WAC)
    ; already created
    ProcedureReturn
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  With WAC
    nWindowWidth = 420
    nWindowHeight = 540
    If OpenWindow(#WAC, 0, 0, nWindowWidth, nWindowHeight, Lang("WAC","Window"), #PB_Window_SystemMenu|#PB_Window_Invisible, WindowID(#WCS))
      registerWindow(#WAC, "WAC(fmAGColors)")
      
      nLblLeft = 4
      nLblWidth = GetTextWidth(Lang("WAC","lblLeftColor")) + 12
      nCtrlLeft = nLblLeft + nLblWidth + gnGap
      nCtrlWidth = 54
      nLblPlayLeft = nCtrlLeft + nCtrlWidth + gnGap2
      nLblPlayWidth = GetTextWidth(Lang("WAC","lblColorPlay")) + 12
      nCtrlPlayLeft = nLblPlayLeft + nLblPlayWidth + gnGap
      nCtrlPlayWidth = nCtrlWidth
      
      ; color scheme (display-only in this window)
      nTop = 8
      \lblScheme=scsTextGadget(nLblLeft,nTop+4,nLblWidth,17,Lang("WCS","lblScheme"), #PB_Text_Right, "lblScheme")
      \cboScheme=scsComboBoxGadget(nCtrlLeft,nTop,205,21,0,"cboScheme")
      setEnabled(\cboScheme, #False)
      
      nTop + 29
      \lnHdgSep=scsLineGadget(0,nTop,nWindowWidth,1,#SCS_Dark_Grey,0,"lnHdgSep")
      
      nTop + 18
      \lblLeftColor=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WAC","lblLeftColor"),#PB_Text_Right,"lblLeftColor")
      \cvsLeftColor=scsCanvasGadget(nCtrlLeft,nTop,nCtrlWidth,18,0,"cvsLeftColor")  ; nb width and height the same as color items in fmColorScheme
      \lblLeftColorPlay=scsTextGadget(nLblPlayLeft,nTop+gnLblVOffsetS,nLblPlayWidth,15,Lang("WAC","lblColorPlay"),#PB_Text_Right,"lblLeftColorPlay")
      \cvsLeftColorPlay=scsCanvasGadget(nCtrlPlayLeft,nTop,nCtrlPlayWidth,18,0,"cvsLeftColorPlay")
      nTop + 25
      \chkRightSameAsLeft=scsCheckBoxGadget(nCtrlLeft,nTop,120,17,Lang("WAC","chkRightSameAsLeft"),0,"chkRightSameAsLeft")
      setGadgetWidth(\chkRightSameAsLeft)
      nTop + 23
      \lblRightColor=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WAC","lblRightColor"),#PB_Text_Right,"lblRightColor")
      \cvsRightColor=scsCanvasGadget(nCtrlLeft,nTop,nCtrlWidth,18,0,"cvsRightColor")
      \lblRightColorPlay=scsTextGadget(nLblPlayLeft,nTop+gnLblVOffsetS,nLblPlayWidth,15,Lang("WAC","lblColorPlay"),#PB_Text_Right,"lblRightColorPlay")
      \cvsRightColorPlay=scsCanvasGadget(nCtrlPlayLeft,nTop,nCtrlPlayWidth,18,0,"cvsRightColorPlay")
      nTop + 27
      \lblDarkenFactor=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WAC","lblDarkenFactor"),#PB_Text_Right,"lblDarkenFactor")
      \trbDarkenFactor=scsTrackBarGadget(nCtrlLeft,nTop,120,23,0,100,0,"trbDarkenFactor")
      scsToolTip(\trbDarkenFactor,Lang("WAC","trbDarkenFactorTT"))
      nTop + 36
      \lblCursorColor=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WAC","lblCursorColor"),#PB_Text_Right,"lblCursorColor")
      \cvsCursorColor=scsCanvasGadget(nCtrlLeft,nTop,54,18,0,"cvsCursorColor")
      
      nTop + 32
      \lnSampleSep=scsLineGadget(0,nTop,nWindowWidth,1,#SCS_Dark_Grey,0,"lnSampleSep")
      
      nTop + 12
      \lblCPSample=scsTextGadget(0,nTop,nWindowWidth,15,Lang("WAC","lblCPSample"),#PB_Text_Center,"lblCPSample")
      nTop + 19
      nWidth = 360
      nLeft = (nWindowWidth - nWidth) >> 1
      \cvsCPSample=scsCanvasGadget(nLeft,nTop,nWidth,27,0,"cvsCPSample")  ; nb will be resized in WAC_Form_Show()
      nTop + GadgetHeight(\cvsCPSample) + 4
      \lblCPSamplePlay=scsTextGadget(0,nTop,nWindowWidth,15,Lang("WAC","lblCPSamplePlay"),#PB_Text_Center,"lblCPSamplePlay")
      nTop + 19
      nWidth = 360
      nLeft = (nWindowWidth - nWidth) >> 1
      \cvsCPSamplePlay=scsCanvasGadget(nLeft,nTop,nWidth,27,0,"cvsCPSamplePlay")  ; nb will be resized in WAC_Form_Show()
      
      nTop + GadgetHeight(\cvsCPSample) + 12
      \lblEDSample=scsTextGadget(0,nTop,nWindowWidth,15,Lang("WAC","lblEDSample"),#PB_Text_Center,"lblEDSample")
      nTop + 19
      nWidth = 360
      nLeft = (nWindowWidth - nWidth) >> 1
      \cvsEDSample=scsCanvasGadget(nLeft,nTop,nWidth,129,0,"cvsEDSample")
      
      nEDSampleRight = GadgetX(\cvsEDSample) + GadgetWidth(\cvsEDSample)
      nBtnPadRight = nWindowWidth - nEDSampleRight - 1
      nTop + GadgetHeight(\cvsEDSample) + 12
      nBtnGap = 7
      nLeft = 7
      \btnUseDflts=scsButtonGadget(nLeft,nTop,80,gnBtnHeight,Lang("WAC","btnUseDflts"),0,"btnUseDflts")
      setGadgetWidth(\btnUseDflts, -1, #True)
      \btnUseClassic=scsButtonGadget(gnNextX+nBtnGap,nTop,80,gnBtnHeight,Lang("WAC","btnUseClassic"),0,"btnUseClassic")
      setGadgetWidth(\btnUseClassic)
      nBtnWidth = GadgetWidth(\btnUseDflts)
      If GadgetWidth(\btnUseClassic) > nBtnWidth
        nBtnWidth = GadgetWidth(\btnUseClassic)
      EndIf
      nLeft = nWindowWidth - (nBtnWidth * 2) - nBtnGap - nBtnPadRight
      ResizeGadget(\btnUseDflts,nLeft,#PB_Ignore,nBtnWidth,#PB_Ignore)
      nLeft + nBtnWidth + nBtnGap
      ResizeGadget(\btnUseClassic,nLeft,#PB_Ignore,nBtnWidth,#PB_Ignore)
      
      nTop + gnBtnHeight + 8
      nBtnWidth = 64
      nLeft = nWindowWidth - (nBtnWidth * 3) - (nBtnGap * 2) - nBtnPadRight
      \btnReset=scsButtonGadget(nLeft,nTop,nBtnWidth,gnBtnHeight,Lang("Btns","Reset"),0,"btnReset")
      \btnOK=scsButtonGadget(gnNextX+nBtnGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nBtnGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      
      AddKeyboardShortcut(#WAC, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WAC, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
      ; setWindowVisible(#WAC,#True)
      setWindowEnabled(#WAC,#True)
    EndIf
  EndWith
EndProcedure

Structure strWCS ; fmColorScheme
  btnAGColors.i
  btnCancel.i
  btnCopy.i
  btnDelete.i
  btnExport.i
  btnHelp.i
  btnImport.i
  btnOK.i
  btnPaste.i
  btnResetItem.i
  btnSave.i
  btnSaveAs.i
  btnSwap.i
  cboColNXAction.i
  cboScheme.i
  chkUseDflt.i[#SCS_COL_ITEM_LAST + 1]
  cntBackColor.i[#SCS_COL_ITEM_LAST + 1]
  cntColNXAction.i
  cntColorItem.i[#SCS_COL_ITEM_LAST + 1]
  cntColorItemList.i
  cntCtrlPanel.i
  cntSampleGrid.i
  cntSampleNX.i
  cntTextColor.i[#SCS_COL_ITEM_LAST + 1]
  cvsCopy.i
  cvsPaste.i
  imgBackColor.i[#SCS_COL_ITEM_LAST + 1]
  imgSamplePanel.i
  imgTextColor.i[#SCS_COL_ITEM_LAST + 1]
  lblBackColor.i
  lblColNXAction.i
  lblColNXSample.i
  lblInfo.i
  lblItemDtl.i[#SCS_COL_ITEM_LAST + 1]
  lblItemHdg.i
  lblSample.i
  lblSampleGrid.i
  lblSampleNX.i
  lblScheme.i
  lblTextColor.i
  lblUseDflt.i
  lnAGColorsSep.i
  lnHdgSep.i
  lnCtrlSep.i
  picBackColor.i[#SCS_COL_ITEM_LAST + 1]
  picSamplePanel.i
  picTextColor.i[#SCS_COL_ITEM_LAST + 1]
  scaColorItemList.i
EndStructure
Global WCS.strWCS ; fmColorScheme

Procedure createfmColorScheme(nParentWindow)
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, nHeight, nItemHeight
  Protected nInnerWidth, nInnerHeight
  Protected nWindowWidth
  Protected m
  Protected sNr.s
  Protected nColNXActionHeight
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WCS, 0, 0, 622, 541, Lang("WCS","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WCS, "WCS(fmColorScheme)")
    nWindowWidth = WindowWidth(#WCS)
    
    nColNXActionHeight = 38
    
    With WCS
      ; color scheme
      nTop = 8
      \lblScheme=scsTextGadget(8,nTop+4,120,17,Lang("WCS","lblScheme"),#PB_Text_Right,"lblScheme")
      scsSetGadgetFont(\lblScheme,#SCS_FONT_GEN_BOLD)
      \cboScheme=scsComboBoxGadget(gnNextX+7,nTop,205,21,0,"cboScheme")
      
      nTop + 25
      \lblInfo=scsTextGadget(0,nTop,nWindowWidth,31,"",#PB_Text_Center,"lblInfo")
      scsSetGadgetFont(\lblInfo, #SCS_FONT_GEN_BOLD)
      setVisible(\lblInfo, #False)    
      ; lblInfo and lnHdgSep are mutually exclusive
      \lnHdgSep=scsLineGadget(0,nTop+17,nWindowWidth,1,#SCS_Black,0,"lnHdgSep")
      
      nTop + 32
      ; table headings
      \lblUseDflt=scsTextGadget(157,nTop,70,31,Lang("WCS","lblUseDflt"),#PB_Text_Center,"lblUseDflt")
      \lblBackColor=scsTextGadget(gnNextX+gnGap,nTop,70,31,Lang("WCS","lblBackColor"),#PB_Text_Center,"lblBackColor")
      \lblTextColor=scsTextGadget(gnNextX+gnGap,nTop,70,31,Lang("WCS","lblTextColor"),#PB_Text_Center,"lblTextColor")
      
      nLeft = 16
      nTop + 31
      nItemHeight = 20
      nWidth = 384
      nHeight = nItemHeight + 1 ; add 1 pixel so bottom border of 'default colors' container is overlaid by top border of scrollarea gadget
      
      ; setup 'default colors' item
      n = 0
      sNr = "[00]"
      \cntColorItem[n]=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_Flat,"cntColorItem"+sNr)
        \lblItemDtl[n]=scsStringGadget(7,3,138,17,"",#PB_String_BorderLess|#PB_String_ReadOnly,"lblItemDtl"+sNr)
        
        ; note: \chkUseDflt[0] must be created as this will be used as the 'gadget number for event handler' for other \chkUseDflt[n] items,
        ; but the checkbox is not relevant for the 'default colours' item so will be hidden
        \chkUseDflt[n]=scsCheckBoxGadget(167,2,15,15,"",0,"chkUseDflt"+sNr)
        setVisible(\chkUseDflt[n], #False)
        
        \cntBackColor[n]=scsContainerGadget(219,0,58,nItemHeight,0,"cntBackColor"+sNr)
          \imgBackColor[n]=CreateImage(#PB_Any,54,18)
          \picBackColor[n]=scsImageGadget(2,1,54,18,ImageID(\imgBackColor[n]),0,"picBackColor"+sNr)
        scsCloseGadgetList()
        
        \cntTextColor[n]=scsContainerGadget(292,0,58,nItemHeight,0,"cntTextColor"+sNr)
          \imgTextColor[n]=CreateImage(#PB_Any,54,18)
          \picTextColor[n]=scsImageGadget(2,1,54,18,ImageID(\imgTextColor[n]),0,"picTextColor"+sNr)
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; cntColorItem[n]
      
      nTop + nItemHeight
      nHeight = WindowHeight(#WCS) - nTop - nColNXActionHeight - 17
      nInnerWidth = nWidth - gl3DBorderAllowanceX - glScrollBarWidth
      nInnerHeight = (#SCS_COL_ITEM_LAST * nItemHeight) + gl3DBorderAllowanceY + 1
      \scaColorItemList=scsScrollAreaGadget(nLeft, nTop, nWidth, nHeight, nInnerWidth,nInnerHeight,nItemHeight,#PB_ScrollArea_Flat,"scaColorItemList")
        
        ; table rows (items)
        For n = 1 To #SCS_COL_ITEM_LAST
          nTop = (n-1) * nItemHeight
          If n < 10
            sNr = "[0"+n+"]"
          Else
            sNr = "["+n+"]"
          EndIf
          
          ; setup item
          \cntColorItem[n]=scsContainerGadget(0,nTop,nInnerWidth,nItemHeight,0,"cntColorItem"+sNr)
            \lblItemDtl[n]=scsStringGadget(7,3,138,17,"",#PB_String_BorderLess|#PB_String_ReadOnly,"lblItemDtl"+sNr)
            
            \chkUseDflt[n]=scsCheckBoxGadget(167,2,15,15,"",0,"chkUseDflt"+sNr)
            
            \cntBackColor[n]=scsContainerGadget(219,0,58,nItemHeight,0,"cntBackColor"+sNr)
              \imgBackColor[n]=CreateImage(#PB_Any,54,18)
              \picBackColor[n]=scsImageGadget(2,1,54,18,ImageID(\imgBackColor[n]),0,"picBackColor"+sNr)
            scsCloseGadgetList()
            
            \cntTextColor[n]=scsContainerGadget(292,0,58,nItemHeight,0,"cntTextColor"+sNr)
              \imgTextColor[n]=CreateImage(#PB_Any,54,18)
              \picTextColor[n]=scsImageGadget(2,1,54,18,ImageID(\imgTextColor[n]),0,"picTextColor"+sNr)
            scsCloseGadgetList()
            
          scsCloseGadgetList() ; cntColorItem[n]
          
        Next n
        
      scsCloseGadgetList()
      
      nTop = GadgetY(\scaColorItemList) + GadgetHeight(\scaColorItemList) + 8
      \cntColNXAction=scsContainerGadget(nLeft,nTop,nWidth,nColNXActionHeight,0,"cntColNXAction")
        \lblColNXAction=scsTextGadget(4,0,196,15,Lang("WCS","lblColNXAction"),0,"lblColNXAction")
        scsSetGadgetFont(\lblColNXAction,#SCS_FONT_GEN_BOLD)
        ; \lblColNXSample=scsTextGadget(gnNextX+gnGap,0,157,15,Lang("WCS","lblSample"),#PB_Text_Center,"lblColNXSample")
        \cboColNXAction=scsComboBoxGadget(0,15,200,23,0,"cboColNXAction")
        \cntSampleNX=scsContainerGadget(gnNextX+gnGap,15,165,23,#PB_Container_Flat,"cntSampleNX")
          \lblSampleNX=scsTextGadget(2,4,161,15,"",#PB_Text_Center,"lblSampleNX")
        scsCloseGadgetList()
      scsCloseGadgetList()
      
      nLeft = GadgetX(\scaColorItemList) + GadgetWidth(\scaColorItemList) + 16
      nTop = GadgetY(\scaColorItemList)
      nWidth = 192
      ; nHeight = GadgetHeight(\scaColorItemList) - 31
      nHeight = GadgetY(\cntColNXAction) + GadgetHeight(\cntColNXAction) - GadgetY(\scaColorItemList) - 31
      \cntCtrlPanel=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_Flat,"cntCtrlPanel")
        
        \lblSample=scsTextGadget(17,8,157,15,Lang("WCS", "lblSample"),#PB_Text_Center,"lblSample")
        \cntSampleGrid=scsContainerGadget(17,25,157,30,#PB_Container_Flat,"cntSampleGrid")
          \lblSampleGrid=scsTextGadget(4,7,149,14,"", #PB_Text_Center,"lblSampleGrid")
        scsCloseGadgetList() ; cntSampleGrid
        
        nLeft = 13
        nTop = 65
        nWidth = 165
        nHeight = 30
        \btnSwap=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WCS","btnSwap"),0,"btnSwap")
        setToolTipFromTextIfReqd(\btnSwap)
        nTop + 35
        nHeight = 23
        \btnResetItem=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WCS","btnResetItem"),0,"btnResetItem")
        setToolTipFromTextIfReqd(\btnResetItem)
        nTop + 28
        \btnCopy=scsButtonGadget(22,nTop,70,nHeight,grText\sTextCopy,0,"btnCopy")
        \btnPaste=scsButtonGadget(99,nTop,70,nHeight,grText\sTextPaste,0,"btnPaste")
        nTop + 23
        \cvsCopy=scsCanvasGadget(26,nTop,62,10,0,"cvsCopy")
        \cvsPaste=scsCanvasGadget(103,nTop,62,10,0,"cvsPaste")
        
        nTop + 25
        \lnAGColorsSep=scsLineGadget(0,nTop,GadgetWidth(\cntCtrlPanel),1,#SCS_Black,0,"lnAGColorsSep")
        nTop + 12
        \btnAGColors=scsButtonGadget(nLeft, nTop, nWidth, nHeight, LangEllipsis("WCS","btnAGColors"),0,"btnAGColors")
        setToolTipFromTextIfReqd(\btnAGColors)
        
        nTop + nHeight + 12
        \lnCtrlSep=scsLineGadget(0,nTop,GadgetWidth(\cntCtrlPanel),1,#SCS_Black,0,"lnCtrlSep")
        nTop + 12
        \btnExport=scsButtonGadget(nLeft, nTop, nWidth, nHeight, LangEllipsis("WCS","btnExport"),0,"btnExport")
        setToolTipFromTextIfReqd(\btnExport)
        nTop + 28
        \btnImport=scsButtonGadget(nLeft, nTop, nWidth, nHeight, LangEllipsis("WCS","btnImport"),0,"btnImport")
        setToolTipFromTextIfReqd(\btnImport)
        
        nTop + 38
        \btnSave=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WCS","btnSave"),0,"btnSave")
        setToolTipFromTextIfReqd(\btnSave)
        nTop + 28
        \btnSaveAs=scsButtonGadget(nLeft, nTop, nWidth, nHeight, LangEllipsis("WCS","btnSaveAs"),0,"btnSaveAs")
        setToolTipFromTextIfReqd(\btnSaveAs)
        nTop + 28
        \btnDelete=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WCS","btnDelete"),0,"btnDelete")
        setToolTipFromTextIfReqd(\btnDelete)
        
      scsCloseGadgetList()
      
      nTop = GadgetY(\cntCtrlPanel) + GadgetHeight(\cntCtrlPanel) + 8
      nLeft = GadgetX(\cntCtrlPanel) - 7
      \btnOK=scsButtonGadget(nLeft,nTop,66,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+5,nTop,66,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(gnNextX+5,nTop,66,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      AddKeyboardShortcut(#WCS, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      AddKeyboardShortcut(#WCS, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      
    EndWith
    ; setWindowVisible(#WCS,#True)
    setWindowEnabled(#WCS,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWED ; fmEditor
  cntLeft.i
  cntRight.i
  cntSideBar.i
  cntSpecialQA.i
  cntSpecialQF.i
  cntTemplate.i
  cntTopPanel.i
  imgButtonTBS.i[12]
  lblClipboardInfo.i
  lblTemplateInfo.i
  lblUndoRedoList.i
  lnSbSep.i[4]
  splEditV.i
  tbEditor.i
  tvwProdTree.i
  txtDummy.i ; Added 20Jun2022 11.9.3aa
  ;
  rScrollInfo.SCROLLINFO  ; used in window callback
EndStructure
Global WED.strWED ; fmEditor

Procedure createfmEditor()
  PROCNAMEC()
  Protected bCreateResult
  Protected nFormLeft, nFormTop, nFormWidth, nFormHeight
  Protected nToolHeight ;  = 80 ; 91 ; 93  ; was 116
  Protected nLeft, nTop, nWidth, nHeight
  Protected nFlags
  Protected nCntTop, nCntHeight
  
  debugMsg(sProcName, #SCS_START)
  
  ; added 8Oct2019 11.8.2at following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
  ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
  If IsWindow(#WED)
    If GetWindowState(#WED) = #PB_Window_Minimize
      debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
      SetWindowState(#WED, #PB_Window_Normal)
      debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
    EndIf
  EndIf
  ; end added 8Oct2019 11.8.2at
  
  gnWEDDefaultWindowWidth = 950 ; 900   ; changed 20Sep2023
  gnWEDDefaultWindowHeight = 740 ; 694  ; changed 20Sep2023
  nToolHeight = 80
  
  grWED\nSpecialAreaHeight = 176  ; currently based on the required height of \cntSpecialQF, which is greater than the required height of \cntSpecialQA
  
  nFlags = #PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible | #PB_Window_SizeGadget
  
  If grEditWindow\nLeft = -1
    nFlags | #PB_Window_ScreenCentered
    nFormLeft = 0                 ; ignored due to Window_ScreenCentered flag
    nFormTop = 0                  ; ignored due to Window_ScreenCentered flag
  Else
    nFormLeft = grEditWindow\nLeft
    nFormTop = grEditWindow\nTop
  EndIf
  
  If grEditWindow\nWidth = -1
    nFormWidth = gnWEDDefaultWindowWidth
  Else
    nFormWidth = grEditWindow\nWidth
  EndIf
  
  nFormHeight = gnWEDDefaultWindowHeight
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  ; WED\rScrollInfo used in window callback
  With WED\rScrollInfo
    \cbSize = SizeOf(WED\rScrollInfo)
    \fMask = #SIF_POS 
  EndWith
  
  If IsWindow(#WED) = #False
    debugMsg(sProcName, "nFormLeft=" + nFormLeft + ", nFormTop=" + nFormTop + ", nFormWidth=" + nFormWidth + ", nFormHeight=" + nFormHeight)
    If OpenWindow(#WED, nFormLeft, nFormTop, nFormWidth, nFormHeight, Lang("WED","Window"), nFlags)
      registerWindow(#WED, "WED(fmEditor)")
      
      setToolTipControls()
      
      ; set reasonable minimum width and height (nb minimum width MUST prevent cntRight being cut on the right)
      WindowBounds(#WED, 800, 300, #PB_Ignore, #PB_Ignore)
      
      WED_buildEditorMenus()    ; builds popup menus (used by the toolbar)
      
      With WED
        ; editor tool bar
        \cntTopPanel=scsContainerGadget(0,0,nFormWidth,nToolHeight,0,"cntTopPanel")
          SetGadgetColor(\cntTopPanel, #PB_Gadget_BackColor, RGB($D9,$EE,$FF))  ; same color as toolbar background
          createEditorToolBar(0,0,nFormWidth,nToolHeight,WindowID(#WED))
        scsCloseGadgetList()
        
        nCntTop = nToolHeight
        nCntHeight = nFormHeight - nCntTop
        
        ; container left of splitter
        \cntLeft=scsContainerGadget(0, nCntTop, 228, nCntHeight, 0, "cntLeft")
          nHeight = nCntHeight - 35 ; see also WED_Form_Resized()
          \cntSideBar=scsContainerGadget(0,0,30,nHeight,0,"cntSideBar")
            \imgButtonTBS[0]=scsStandardButton(3,8,24,24,#SCS_STANDARD_BTN_EXPAND_ALL,"imgButtonTBS[0]")
            \imgButtonTBS[1]=scsStandardButton(3,34,24,24,#SCS_STANDARD_BTN_COLLAPSE_ALL,"imgButtonTBS[1]")
            \lnSbSep[0]=scsLineGadget(3,63,24,1,#SCS_Grey,0,"lnSbSep[0]")
            \lnSbSep[1]=scsLineGadget(3,64,24,1,#SCS_White,0,"lnSbSep[1]")
            \imgButtonTBS[2]=scsStandardButton(3,69,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgButtonTBS[2]")
            \imgButtonTBS[3]=scsStandardButton(3,95,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgButtonTBS[3]")
            \imgButtonTBS[4]=scsStandardButton(3,121,24,24,#SCS_STANDARD_BTN_MOVE_RIGHT_UP,"imgButtonTBS[4]")
            \imgButtonTBS[5]=scsStandardButton(3,147,24,24,#SCS_STANDARD_BTN_MOVE_LEFT,"imgButtonTBS[5]")
            \lnSbSep[2]=scsLineGadget(3,176,24,1,#SCS_Grey,0,"lnSbSep[2]")
            \lnSbSep[3]=scsLineGadget(3,177,24,1,#SCS_White,0,"lnSbSep[3]")
            \imgButtonTBS[6]=scsStandardButton(3,182,24,24,#SCS_STANDARD_BTN_CUT,"imgButtonTBS[6]")
            \imgButtonTBS[7]=scsStandardButton(3,208,24,24,#SCS_STANDARD_BTN_COPY,"imgButtonTBS[7]")
            \imgButtonTBS[8]=scsStandardButton(3,234,24,24,#SCS_STANDARD_BTN_PASTE,"imgButtonTBS[8]")
            \imgButtonTBS[9]=scsStandardButton(3,260,24,24,#SCS_STANDARD_BTN_DELETE,"imgButtonTBS[9]")
            \imgButtonTBS[10]=scsStandardButton(3,286,24,24,#SCS_STANDARD_BTN_FIND,"imgButtonTBS[10]")
            \imgButtonTBS[11]=scsStandardButton(3,312,24,24,#SCS_STANDARD_BTN_COPY_PROPS,"imgButtonTBS[11]")
          scsCloseGadgetList() ; cntSideBar
          nLeft = GadgetWidth(\cntSideBar)
          nWidth = GadgetWidth(\cntLeft) - nLeft
          \tvwProdTree=scsTreeGadget(nLeft,0,nWidth,nHeight,#PB_Tree_AlwaysShowSelection,"tvwProdTree")
          scsSetGadgetFont(\tvwProdTree, #SCS_FONT_GEN_BOLD9)
          SetGadgetColor(\tvwProdTree, #PB_Gadget_BackColor, RGB(255, 255, 223))
          EnableGadgetDrop(\tvwProdTree, #PB_Drop_Files, #PB_Drag_Copy)
          EnableGadgetDrop(\tvwProdTree, #PB_Drop_Private, #PB_Drag_Move, #SCS_PRIVTYPE_DRAG_CUE)
          nTop = GadgetY(\tvwProdTree) + GadgetHeight(\tvwProdTree)
          scsToolTip(\tvwProdTree, Lang("WED", "tvwProdTreeTT"))
          ; template info (displayed if editing a template)
          \cntTemplate=scsContainerGadget(nLeft,nTop,nWidth,25,#PB_Container_Flat,"cntTemplate")
            SetGadgetColor(\cntTemplate, #PB_Gadget_BackColor, RGB(0,102,204))
            \lblTemplateInfo=scsTextGadget(0,3,nWidth,17,"",#PB_Text_Center,"lblTemplateInfo")
            SetGadgetColors(\lblTemplateInfo, #SCS_White, RGB(0,102,204))
            scsSetGadgetFont(\lblTemplateInfo, #SCS_FONT_WMN_ITALIC)
            SetGadgetColor(\lblTemplateInfo, #PB_Gadget_BackColor, GetGadgetColor(\cntTemplate, #PB_Gadget_BackColor))
          scsCloseGadgetList() ; cntTemplate
          setVisible(\cntTemplate,#False)
          \lblClipboardInfo=scsTextGadget(nLeft, nTop, nWidth, 31, "", #PB_Text_Center | #PB_Text_Border, "lblClipboardInfo")
        scsCloseGadgetList()   ; cntLeft
        
        ; container right of splitter
        \cntRight=scsContainerGadget(0, 0, 0, 0, 0, "cntRight")
        scsCloseGadgetList() ; cntRight
        
        ; vertical splitter
        \splEditV=scsSplitterGadget(0, nCntTop, nFormWidth, nCntHeight, \cntLeft, \cntRight, #PB_Splitter_Separator|#PB_Splitter_Vertical|#PB_Splitter_SecondFixed, "splEditV")
        SetGadgetAttribute(\splEditV, #PB_Splitter_FirstMinimumSize, 50)
        
        ; nHeight = 176
        nHeight = grWED\nSpecialAreaHeight
        nTop = WindowHeight(#WED) - nHeight
        nWidth = WindowWidth(#WED)
        \cntSpecialQA=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntSpecialQA")
        ; resized and populated by createfmEditQA
        scsCloseGadgetList()
        setVisible(\cntSpecialQA,#False)
        
        \cntSpecialQF=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntSpecialQF")
          ; resized and populated by createfmEditQF
        scsCloseGadgetList()
        setVisible(\cntSpecialQF,#False)
        debugMsg(sProcName,"WindowWidth(#WED)=" + WindowWidth(#WED) + ", GadgetWidth(WED\cntSpecialQF)=" + GadgetWidth(WED\cntSpecialQF))
        
        ; Added 20Jun2022 11.9.3aa
        \txtDummy=scsTextGadget(-10,-10,10,10,"",0,"txtDummy")
        setVisible(\txtDummy,#False)
        ; End added 20Jun2022 11.9.3aa
        
      EndWith
      
      gnEditorScaPropertiesInnerWidth = 641 ; was 637
      gnEditorCntRightFixedWidth = gnEditorScaPropertiesInnerWidth + glScrollBarWidth + gl3DBorderAllowanceX
      gnEditorScaSubCueInnerHeight = 490  ; 'fixed', based on maximum inner height required, which is for fmEditQF
      
      If (grEditorPrefs\nSplitterPosEditH = -1) Or (gnPrefsReadVersion < 110201)  ; nb default changed at 11.2.1
        grEditorPrefs\nSplitterPosEditH = 107 ; 115
      EndIf
      
      CompilerIf 1=2
        ; windowcallback to handle WED\tvwProdTree processing was based on code supplied by srod in PB 'Coding Questions' forum topic: 'TreeGadget - left click problem'
        ; but was blocked out 3Dec2015 11.4.1.2q as the callback can require the user to click a second time on the sub-node of an expanded node, and on
        ; testing this there doesn't appear to be any reason for this callback - maybe the 'problem' reported in the forum topic has been fixed
        SetWindowCallback(@WED_windowCallback(), #WED)  ; window callback
      CompilerEndIf
      
      ; added 5 Jul 2016 11.5.1
      AddKeyboardShortcut(#WED, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      ; nb see also code in WED_EventHandler() where this keyboard shortcut is removed while an editor gadget has focus
      ; this is to enable 'return' to be used correctly when setting up or maintaining a memo

      ; setWindowVisible(#WED,#True)
      setWindowEnabled(#WED,#True)
      ; setEnabled(WED\tbEditor, #True)
      bCreateResult = #True
    Else
      debugMsg(sProcName, "WED window open failed")
    EndIf
  Else
    bCreateResult = #True
  EndIf
  debugMsg(sProcName, "WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED) + ", WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
  
  setWindowEnabled(#WMN,#True)
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn bCreateResult
EndProcedure

Structure strWEC ; fmEditCue
  btnEditExternally.i
  cboActivationMethod.i
  cboAutoActivateCue.i
  cboAutoActivateMarker.i
  cboAutoActivatePosn.i
  cboExtFaderCC.i
  cboHideCueOpt.i
  cboHotkeyBank.i
  cboHotkey.i
  cboStandby.i
  chkCueEnabled.i
  chkCueGapless.i
  chkExclusive.i
  chkSubEnabled.i ; dummy hidden field - used for establishing required position of chkCueEnabled, to match position of chkSubEnabled in sub-cues
  chkWarningBeforeEnd.i
  cntLTCInputDev.i
  cntMTCStartTime.i
  cntStandby.i
  cntSubPlaceHolder.i
  cntTBC.i
  cvsParamsQMark.i
  lblActivationHdg.i
  lblAutoStartPosition.i
  lblCallableCueParams.i
  lblCue.i
  lblCueDisabled.i
  lblCueProperties.i
  lblDescr.i
  lblExtFaderCC.i
  lblHidden.i
  lblHideCueOpt.i
  lblHotkey.i
  lblHotkeyBank.i
  lblHotkeyLabel.i
  lblLatestTimeOfDay.i  ; Latest Time of Day
  lblLTCInputDev.i
  lblMidiCue.i
  lblMTCStartSep.i[4]
  lblPageNo.i
  lblStandby.i
  lblSubDisabled.i ; dummy hidden field - used for establishing required position of chkCueEnabled, (not lblCueDisabled) to match position of chkSubEnabled in sub-cues
  lblTimeOfDay.i
  lblTimeProfile.i
  lblWhenReqd.i
  lnActMethod.i[2]
  lnCueProperties.i
  lnStandby.i[3]
  scaCueProperties.i
  scaTBC.i
  splEditH.i
  txtAutoActivateTime.i
  txtCallableCueParams.i
  txtCueFR.i
  txtCueNormal.i
  txtCueUC.i
  txtCueUCFR.i
  txtDescr.i
  txtHotkeyLabel.i
  txtLTCInputDev.i
  txtMidiCue.i
  txtMTCStartPart.i[4] ; Also used for LTC
  txtPageNo.i
  txtTimeOfDay.i[#SCS_MAX_TIME_PROFILE+1]
  txtTimeProfile.i[#SCS_MAX_TIME_PROFILE+1]
  txtLatestTimeOfDay.i[#SCS_MAX_TIME_PROFILE+1]
  txtWhenReqd.i
EndStructure
Global WEC.strWEC ; fmEditCue

Procedure createfmEditCue()
  PROCNAMEC()
  Protected nFlags, n, sNr.s, sTempString.s
  Protected nLeft, nTop, nWidth, nHeight, nInnerHeight, nLeft2, nleft3
  Protected nTextWidth, nPromptWidth, nFieldWidth
  Protected nCueDisabledWidth, nSubDisabledWidth, nCueEnabledWidth, nSubEnabledWidth
  Protected sText.s, s2.s = "  "
  Protected nSepWidth, nPartWidth, nFlag
  Protected hEditAudioFileExternal.i
  Protected bPrefsOpenAtStart.i, sPrefGroupAtStart.s
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WEC
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WEC
      ; scaCueProperties (upper gadget in splitter)
      \scaCueProperties=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, 167, 30, #PB_ScrollArea_Flat, "scaCueProperties")
        ; header
        \lblCueProperties=scsTextGadget(0,0,gnEditorScaPropertiesInnerWidth,18," "+Lang("WEC","lblCueProperties"),0,"lblCueProperties")
        scsSetGadgetFont(\lblCueProperties, #SCS_FONT_GEN_NORMAL10)
        setReverseEditorColors(\lblCueProperties, #True)
        
        \chkCueEnabled=scsCheckBoxGadget2(400,0,-1,16,Lang("WEC","chkCueEnabled"),0,"chkCueEnabled")
        scsToolTip(\chkCueEnabled,Lang("WEC","chkCueEnabledTT"))
        setReverseEditorColors(\chkCueEnabled, #True)
        \lblCueDisabled=scsTextGadget(gnNextX+gnGap2,1,85,16,s2+Lang("WEC","lblCueDisabled")+s2,#PB_Text_Center,"lblCueDisabled")
        scsSetGadgetFont(\lblCueDisabled, #SCS_FONT_GEN_BOLD)
        setGadgetWidth(\lblCueDisabled) ; sets width to 'required size'
        SetGadgetColor(\lblCueDisabled, #PB_Gadget_FrontColor, #SCS_Red)
        SetGadgetColor(\lblCueDisabled, #PB_Gadget_BackColor, #SCS_White)
        setAllowEditorColors(\lblCueDisabled, #False)
        setVisible(\lblCueDisabled, #False)
        
        ; dummy hidden fields:
        \chkSubEnabled=scsCheckBoxGadget2(-120,-100,-1,16,Lang("CED","chkSubEnabled"),0,"chkSubEnabled")
        setVisible(\chkSubEnabled, #False)
        setEnabled(\chkSubEnabled, #False)
        \lblSubDisabled=scsTextGadget(-100,-100,85,16,s2+Lang("CED","lblSubDisabled")+s2,#PB_Text_Center,"lblSubDisabled")
        scsSetGadgetFont(\lblSubDisabled, #SCS_FONT_GEN_BOLD)
        setGadgetWidth(\lblSubDisabled) ; sets width to 'required size'
        ; calculate required position of \chkCueEnabled so that it can match the position of \chkSubEnabled in sub-cues
        nCueDisabledWidth = GadgetWidth(\lblCueDisabled)
        nSubDisabledWidth = GadgetWidth(\lblSubDisabled)
        If nSubDisabledWidth > nCueDisabledWidth
          nCueDisabledWidth = nSubDisabledWidth
        EndIf
        nCueEnabledWidth = GadgetWidth(\chkCueEnabled)
        nSubEnabledWidth = GadgetWidth(\chkSubEnabled)
        If nSubEnabledWidth > nCueEnabledWidth
          nCueEnabledWidth = nSubEnabledWidth
        EndIf
        nLeft = gnEditorScaPropertiesInnerWidth - nCueDisabledWidth - gnGap2 - nCueEnabledWidth - 1
        ResizeGadget(\chkCueEnabled, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft + GadgetWidth(\chkCueEnabled) + gnGap2
        ResizeGadget(\lblCueDisabled, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft = GadgetX(\chkCueEnabled) - 130
        \lblHidden=scsTextGadget(nLeft,1,125,16,Lang("WEC","lblHidden"),#PB_Text_Center,"lblHidden")
        SetGadgetColor(\lblHidden, #PB_Gadget_BackColor, #SCS_Yellow)
        setAllowEditorColors(\lblHidden, #False)
        setVisible(\lblHidden, #False)
        
        ; cue label
        nTop = GadgetY(\lblCueProperties) + GadgetHeight(\lblCueProperties) + 0
        \lblCue=scsTextGadget(8,nTop+gnLblVOffsetS,49,17,Lang("Common","Cue"), #PB_Text_Right,"lblCue")
        scsSetGadgetFont(\lblCue, #SCS_FONT_GEN_BOLD11)
        nWidth = GetTextWidth(Lang("Common","Cue"), #SCS_FONT_GEN_BOLD11)   ; get the font resized width
        nHeight = GetTextHeight(Lang("Common","Cue"), #SCS_FONT_GEN_BOLD11)   ; get the font resized height
        ResizeGadget(\lblCue, #PB_Ignore, #PB_Ignore, nWidth, nHeight)
        
        ; Note: There are four fields used for the cue label (or 'cue number') because the PB StringGadget requires different flags for different
        ; 'production property' settings, and these flags can only be set when the gadget is created. The relevant production property settings and string gadget flags are:
        ; - 'new or change cue labels forced to upper case', which requires the flag #PB_String_UpperCase
        ; - 'cue labels cannot be changed', which requires the flag #PB_String_ReadOnly
        ; Procedure WEC_displayCueDetail() determines which of these cue label fields is to be used, storing the required gadget number in grCED\nCurrentCueLabelGadgetNo.
        
        ; The code below was altered by Dee 30/03/2025 to allow for user defined "Page" and "WhenReqd" column headers, Both headers are limited to 24 chars (#SCS_USER_COLUMN_LENGTH)
        ; Right aligned text for lblPageNo and lblWhenReq is achived by use of GetTextGadgetSize to obtain the accurate length of text.
        
        nLeft = nWidth + gnGap + 8
        nHeight = 22
        nwidth = 70
        
        ; normal (no flags)
        ntop + 2
        \txtCueNormal=scsStringGadget(nLeft, nTop, nWidth, nHeight, "",0,"txtCueNormal")
        scsToolTip(\txtCueNormal,Lang("WEC","txtCueTT"))
        scsSetGadgetFont(\txtCueNormal, #SCS_FONT_GEN_BOLD11)
        ; uppercase (#PB_String_UpperCase)
        \txtCueUC=scsStringGadget(nLeft, nTop, nWidth, nHeight, "",#PB_String_UpperCase,"txtCueUC")
        scsToolTip(\txtCueUC,Lang("WEC","txtCueTT"))
        scsSetGadgetFont(\txtCueUC, #SCS_FONT_GEN_BOLD11)
        setVisible(\txtCueUC, #False)
        ; frozen, ie cannot be changed (#PB_String_ReadOnly)
        \txtCueFR=scsStringGadget(nLeft, nTop, nWidth, nHeight, "",#PB_String_ReadOnly,"txtCueFR")
        scsToolTip(\txtCueFR,Lang("WEC","txtCueFRTT")) ; nb different tooltip for frozen
        scsSetGadgetFont(\txtCueFR, #SCS_FONT_GEN_NORMAL11)
        SetGadgetColor(\txtCueFR, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
        setVisible(\txtCueFR, #False)
        ; uppercase and frozen (#PB_String_UpperCase|#PB_String_ReadOnly)|#PB_String_Read
        \txtCueUCFR=scsStringGadget(nLeft, nTop, nWidth, nHeight, "",#PB_String_UpperCase,"txtCueUCFR")
        scsToolTip(\txtCueUCFR,Lang("WEC","txtCueFRTT"))
        scsSetGadgetFont(\txtCueUCFR, #SCS_FONT_GEN_NORMAL11)
        SetGadgetColor(\txtCueUCFR, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
        setVisible(\txtCueUCFR, #False)
        
        grCED\nCurrentCueLabelGadgetNo = \txtCueNormal ; currently-visible 'cue' gadget - may be changed in WEC_displayCueDetail()
        
        nPromptWidth = getMaxTextWidth(0, Lang("Common","Description"), Lang("WEC","lblPageNo"), Lang("WEC","lblWhenReqd"))
        
        ; other info about the cue
        nTop = GadgetY(\lblCueProperties) + GadgetHeight(\lblCueProperties) + 2
        \lblDescr=scsTextGadget(128,nTop+gnLblVOffsetS,nPromptWidth,15,Lang("Common","Description"), #PB_Text_Right,"lblDescr")
        nTextWidth = GetTextWidth(Lang("Common","Description"))
        ResizeGadget(\lblDescr, #PB_Ignore, #PB_Ignore, nTextWidth, #PB_Ignore)

        nFieldWidth = 200
        \txtDescr=scsStringGadget(128+gnGap+nTextWidth,nTop,nFieldWidth,21,"",0,"txtDescr")
        scsToolTip(\txtDescr,Lang("WEC","txtDescrTT"))
        
        ; Correct to here, switch to right align, use initial values then read the rendered ones and resize.
        nfieldwidth = 45
        nTextWidth = GetTextWidth( Lang("WEC","lblMidiCue"))
        nleft = gnEditorScaPropertiesInnerWidth - 8 - nfieldwidth - nTextWidth - gnGap
        nLeft2 = nleft + nTextWidth + gnGap
        
        \lblMidiCue=scsTextGadget(nLeft,nTop+gnLblVOffsetS+1,nTextWidth,31,Lang("WEC","lblMidiCue"),0,"lblMidiCue")
        \txtMidiCue=scsStringGadget(nLeft2,nTop,nfieldwidth,21,"",0,"txtMidiCue")
        scsToolTip(\txtMidiCue,Lang("WEC","txtMidiCueTT"))
        setValidChars(\txtMidiCue, "0123456789.,") ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
       
        ; do page and whenreqd, calculate for a large feild but this will be reduced when using the default "Page"
        sTempString = Left(Lang("common","page"), #SCS_USER_COLUMN_LENGTH)
        nTop = GadgetY(\txtCueNormal) + GadgetHeight(\txtCueNormal) 
        nfieldwidth = 200
        nTextWidth = GetTextWidth(sTempString)
        nleft = gnEditorScaPropertiesInnerWidth - 8 - nfieldwidth
        nLeft2 = nleft - nTextWidth - gnGap
        \lblPageNo=scsTextGadget(nleft2,nTop+gnLblVOffsetS,nTextWidth,15,sTempString,#PB_Text_Right,"page")
       
        If gnuserColumnChanged1             ; use a longer string field.
          \txtPageNo=scsStringGadget(nleft,nTop-1,nfieldwidth,21,"",0,"txtpageno")
        Else
          \txtPageNo=scsStringGadget(nleft,nTop-1,45,21,"",0,"txtpageno")
        EndIf
        
        scsToolTip(\txtPageNo,Lang("WEC","txtPageNoTT"))
        
        ; Note: \lblPageNo and \lblWhenReqd need to be right aligned to the start of \txtPageNo and \txtWhenReqd. 
        nTop = GadgetY(\lblPageNo) + GadgetHeight(\lblPageNo) + 2
        sTempString = Left(Lang("common","whenreqd"), #SCS_USER_COLUMN_LENGTH)
        nTextWidth = GetTextWidth(sTempString)
        nLeft2 = nleft - nTextWidth - gnGap
        \lblWhenReqd=scsTextGadget(nleft2,nTop,nTextWidth,15,sTempString,#PB_Text_Right,"WhenReqd")
        \txtWhenReqd=scsStringGadget(nleft,nTop,nfieldwidth,21,"",0,"txtwhenreqd")
        scsToolTip(\txtWhenReqd,Lang("WEC","txtWhenReqdTT"))
        
        nTop = GadgetY(\lblCue) + GadgetHeight(\lblCue) + 7
        nWidth = 178
        nLeft = GadgetX(\lblCue) + 8
        \cboHideCueOpt=scsComboBoxGadget(nLeft,nTop,nWidth,21,0,"cboHideCueOpt")
        scsToolTip(\cboHideCueOpt,Lang("WEC","cboHideCueOptTT"))
        sText = Lang("WEC","lblHideCueOpt")
        nWidth = GetTextWidth(sText)
        nLeft - nWidth - 5
        \lblHideCueOpt=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,sText,#PB_Text_Right,"lblHideCueOpt")
        
        nTop = GadgetY(\lblCue) + GadgetHeight(\lblCue) + 5
        nleft = GadgetX(\lblCue) + 200
        \chkExclusive=scsCheckBoxGadget2(nleft,nTop,100,16,Lang("WEC","chkExclusive"),0,"chkExclusive")
        scsToolTip(\chkExclusive,Lang("WEC","chkExclusiveTT"))
        nTop + 18
        \chkWarningBeforeEnd=scsCheckBoxGadget2(nleft,nTop,100,16,Lang("WEC","chkWarningBeforeEnd"),0,"chkWarningBeforeEnd")
        scsToolTip(\chkWarningBeforeEnd,Lang("WEC","chkWarningBeforeEndTT"))
        SetGadgetState(\chkWarningBeforeEnd, #True)
        setVisible(\chkWarningBeforeEnd, #False)
        
        ; activation and other info about cue
        nTop = GadgetY(\lblCue) + GadgetHeight(\lblCue) + 35
        sText = Lang("WEC","lblActivationHdg")
        nWidth = GetTextWidth(sText)
        \lblActivationHdg=scsTextGadget(11,nTop,nWidth,15,sText,0,"lblActivationHdg") ; X = 4 greater than X for associated combobox so that text left-aligns
        \cboActivationMethod=scsComboBoxGadget(7,nTop+15,120,21,0,"cboActivationMethod") ; changed 23Mar2023 11.10.0an, width was 117
        scsToolTip(\cboActivationMethod,Lang("WEC","cboActivationMethodTT"))
        
        ; auto-start fields
        nTop = GadgetY(\lblCue) + GadgetHeight(\lblCue) + 50
        \txtAutoActivateTime=scsStringGadget(136,nTop,64,21,"",0,"txtAutoActivateTime")
        scsToolTip(\txtAutoActivateTime,Lang("WEC","txtAutoActivateTimeTT"))
        \lblAutoStartPosition=scsTextGadget(204,nTop+gnLblVOffsetS + 4,40,15,Lang("WEC","lblAutoStartPosition"), #PB_Text_Center,"lblAutoStartPosition")  ; "seconds"
        \cboAutoActivatePosn=scsComboBoxGadget(251,nTop,176,21,0,"cboAutoActivatePosn") ; "after start", etc
        scsToolTip(\cboAutoActivatePosn,Lang("WEC","cboAutoActivatePosnTT"))
        \cboAutoActivateCue=scsComboBoxGadget(435,nTop,178,21,0,"cboAutoActivateCue")
        scsToolTip(\cboAutoActivateCue,Lang("WEC","cboAutoActivateCueTT"))
        
        ; hotkey fields
        \lblHotkeyBank=scsTextGadget(136,nTop+gnLblVOffsetS,42,15,Lang("WEC","lblHotkeyBank"), #PB_Text_Right,"lblHotkeyBank")
        setGadgetWidth(\lblHotkeyBank,-1,#True)
        \cboHotkeyBank=scsComboBoxGadget(gnNextX+gnGap,nTop,40,21,0,"cboHotkeyBank")
        If grLicInfo\nMaxHotkeyBank = 0
          setEnabled(\cboHotkeyBank, #False)
        Else
          scsToolTip(\cboHotkeyBank,Lang("WEC", "cboHotkeyBankTT"))
        EndIf
        \lblHotkey=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,42,15,Lang("WEC","lblHotkey"), #PB_Text_Right,"lblHotkey")
        setGadgetWidth(\lblHotkey,-1,#True)
        \cboHotkey=scsComboBoxGadget(gnNextX+gnGap,nTop,135,21,0,"cboHotkey")
        scsToolTip(\cboHotkey,Lang("WEC","cboHotkeyTT"))
        \lblHotkeyLabel=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,71,15,Lang("WEC","lblHotkeyLabel"), #PB_Text_Right,"lblHotkeyLabel")
        setGadgetWidth(\lblHotkeyLabel,-1,#True)
        \txtHotkeyLabel=scsStringGadget(gnNextX+gnGap,nTop,135,21,"",0,"txtHotkeyLabel")
        scsToolTip(\txtHotkeyLabel,Lang("WEC","txtHotkeyLabelTT"))
        
        ; callable cue parameters
        nLeft = GadgetX(\cboActivationMethod) + GadgetWidth(\cboActivationMethod) + 8
        \lblCallableCueParams=scsTextGadget(nLeft,nTop+gnLblVOffsetS,42,15,Lang("WEC","lblCallableCueParams"),0,"lblCallableCueParams")
        setGadgetWidth(\lblCallableCueParams,-1,#True)
        \txtCallableCueParams=scsStringGadget(gnNextX+gnGap,nTop,300,21,"",0,"txtCallableCueParams")
        scsToolTip(\txtCallableCueParams,Lang("WEC","txtCallableCueParamsTT"))
        \cvsParamsQMark=scsCanvasGadget(gnNextX+2,nTop,21,21,0,"cvsParamsQMark")
        
        ; time based fields
        nLeft = GadgetX(\cboActivationMethod) + GadgetWidth(\cboActivationMethod) + 8
        nTop = GadgetY(\cboActivationMethod) + 1
        \cntTBC=scsContainerGadget(nLeft,nTop,307,82,#PB_Container_Flat,"cntTBC")
          \lblTimeProfile=scsTextGadget(5,0,120,15,Lang("Common","TimeProfile"),0,"lblTimeProfile")
          \lblTimeOfDay=scsTextGadget(gnNextX+gnGap,0,77,15,Lang("WEC","TimeOfDay"),0,"lblTimeOfDay")
          ; TBC Project Changes
          \lblLatestTimeOfDay=scsTextGadget(gnNextX+gnGap,0,77,15,Lang("WEC", "LblLatestTimeOfDay"),0,"lblLatestTimeOfDay")
          nInnerHeight = (#SCS_MAX_TIME_PROFILE + 1) * 21
          \scaTBC=scsScrollAreaGadget(3,15,298,63,276,nInnerHeight,21,#PB_ScrollArea_BorderLess,"scaTBC")
            nTop = 0
            For n = 0 To #SCS_MAX_TIME_PROFILE
              sNr = "["+n+"]"
              \txtTimeProfile[n]=scsStringGadget(0,nTop,120,21,"",0,"txtTimeProfile"+sNr)
              setEnabled(\txtTimeProfile[n], #False)
              \txtTimeOfDay[n]=scsStringGadget(gnNextX+gnGap,nTop,77,21,"",0,"txtTimeOfDay"+sNr)
              ; TBC Project changes
              \txtLatestTimeOfDay[n]=scsStringGadget(gnNextX+gnGap,nTop,77,21,"",0,"txtLatestTimeOfDay"+sNr)
              nTop + 21
            Next n
          scsCloseGadgetList()
        scsCloseGadgetList()
        setVisible(\cntTBC, #False)
        
        ; MTC/LTC cue start fields
        ; NOTE: Used for both MTC and LTC Start Times
        nLeft = GadgetX(\cntTBC)
        nTop = GadgetY(\cntTBC) - 1
        ; the following code for creating an 'MTC Gadget' is based on code from the PB Forum topic "Customized IPAddressGadget() is need"
        ; at http://www.purebasic.fr/english/viewtopic.php?f=13&t=37929
        nPartWidth = GetTextWidth(" 88 ")
        nSepWidth = GetTextWidth(":") + 1
        nWidth = (4 * nPartWidth) + (3 * nSepWidth) + gl3DBorderAllowanceX + gl3DBorderAllowanceX
        \cntMTCStartTime=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_Flat,"cntMTCStartTime")
          SetGadgetColor(\cntMTCStartTime, #PB_Gadget_BackColor, #SCS_White)
          setAllowEditorColors(\cntMTCStartTime, #False)
          ; nFlag = #PB_String_Numeric | #PB_String_BorderLess | #ES_CENTER
          nFlag = #PB_String_BorderLess | #ES_CENTER
          nTop = 3
          \txtMTCStartPart[0]=scsStringGadget(1,nTop,nPartWidth,20,"",nFlag,"txtMTCStartPart[0]")
          \txtMTCStartPart[1]=scsStringGadget(gnNextX+nSepWidth,nTop,nPartWidth,20,"",nFlag,"txtMTCStartPart[1]")
          \txtMTCStartPart[2]=scsStringGadget(gnNextX+nSepWidth,nTop,nPartWidth,20,"",nFlag,"txtMTCStartPart[2]")
          \txtMTCStartPart[3]=scsStringGadget(gnNextX+nSepWidth,nTop,nPartWidth,20,"",nFlag,"txtMTCStartPart[3]")
          ; Create separators 
          For n = 0 To 2
            \lblMTCStartSep[n]=scsTextGadget(GadgetX(\txtMTCStartPart[n])+GadgetWidth(\txtMTCStartPart[n])+1,nTop,nSepWidth,20,":",#PB_Text_Center,"lblMTCStartSep["+n+"]")
            SetGadgetColor(\lblMTCStartSep[n], #PB_Gadget_BackColor, #SCS_White)
            setAllowEditorColors(\lblMTCStartSep[n], #False)
          Next n
        scsCloseGadgetList() 
        ; set length of per field, and tooltip
        For n = 0 To 3
          SendMessage_(\txtMTCStartPart[n], #EM_LIMITTEXT, 2, 0) 
          scsToolTip(\txtMTCStartPart[n],Lang("WQU","txtMTCStartTimeTT"))
        Next n
        setVisible(\cntMTCStartTime, #False)
        
        CompilerIf #c_lock_audio_to_ltc
          If grLicInfo\bLockAudioToLTCAvailable
            nLeft = GadgetX(\cntMTCStartTime) + GadgetWidth(\cntMTCStartTime) + gnGap2
            nTop = GadgetY(\cntMTCStartTime)
            nWidth = 100 ; temp setting - will be adjusted after container populated
            \cntLTCInputDev=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntLTCInputDev")
              \lblLTCInputDev=scsTextGadget(0, gnLblVOffsetS, 40, -1, Lang("WEC", "lblLTCInputDev"),0,"lblLTCInputDev")
              setGadgetWidth(\lblLTCInputDev, -1, #True)
              \txtLTCInputDev=scsStringGadget(gnNextX+gnGap, 0, 100, -1, "", 0, "txtLTCInputDev")
              setEnabled(\txtLTCInputDev, #False)
              setTextBoxBackColor(\txtLTCInputDev)
              nWidth = gnNextX
            scsCloseGadgetList()
            ResizeGadget(\cntLTCInputDev, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
          EndIf
        CompilerEndIf
        
        ; OCM 'On Cue Marker' (cue marker/point) field
        nLeft = GadgetX(\cboActivationMethod) + GadgetWidth(\cboActivationMethod) + 8
        nTop = GadgetY(\cboActivationMethod)
        \cboAutoActivateMarker=scsComboBoxGadget(nLeft,nTop,300,21,0,"cboAutoActivateMarker")
        
        If grLicInfo\bExtFaderCueControlAvailable
          nLeft = GadgetX(\cboActivationMethod) + GadgetWidth(\cboActivationMethod) + 8
          nTop = GadgetY(\cboActivationMethod)
          \lblExtFaderCC=scsTextGadget(nLeft,nTop+gnLblVOffsetS,42,15,Lang("WEC","lblExtFaderCC"), #PB_Text_Right,"lblExtFaderCC")
          setGadgetWidth(\lblExtFaderCC,-1,#True)
          \cboExtFaderCC=scsComboBoxGadget(gnNextX+gnShortGap,nTop,42,21,0,"cboExtFaderCC")
        EndIf
        
        ; standby control
        nTop = GadgetY(\cboActivationMethod) + GadgetHeight(\cboActivationMethod) + 3
        nHeight = 48
        nWidth = 244
        nLeft = GadgetX(\cboAutoActivateCue) + GadgetWidth(\cboAutoActivateCue) - nWidth
        \cntStandby=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_Flat,"cntStandby")
          nLeft = 8
          nTop = 4
          \lblStandby=scsTextGadget(nLeft,nTop,81,15,Lang("WEC","lblStandby"),0,"lblStandby")  ; "Standby Control"
          \cboStandby=scsComboBoxGadget(nLeft,nTop+15,225,21,0,"cboStandby")
          scsToolTip(\cboStandby,Lang("WEC","cboStandbyTT"))
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaCueProperties
      
      colorEditorComponent(#WEC)
      SetGadgetColor(WEC\scaCueProperties, #PB_Gadget_BackColor, grColorScheme\aItem[#SCS_COL_ITEM_CP]\nBackColor)
      
      ; cntSubPlaceHolder (lower gadget in splitter)
      \cntSubPlaceHolder=scsContainerGadget(0, 0, 0, 0, 0, "cntSubPlaceHolder")
      scsCloseGadgetList()
      setVisible(\cntSubPlaceHolder, #False)
      
      ; splitter
      \splEditH=scsSplitterGadget(0, 0, gnEditorCntRightFixedWidth, GadgetHeight(WED\cntRight), \scaCueProperties, \cntSubPlaceHolder, #PB_Splitter_Separator, "splEditH")
      
    EndWith
    
  scsCloseGadgetList()
  
  WEC_setSplitterHMinSizes()
  
  debugMsg(sProcName, "grEditorPrefs\nSplitterPosEditH=" + Str(grEditorPrefs\nSplitterPosEditH))
  SetGadgetState(WEC\splEditH, grEditorPrefs\nSplitterPosEditH)
  debugMsg(sProcName, "GGS(WEC\splEditH)=" + Str(GGS(WEC\splEditH)))
  
  gnCurrentEditorComponent = 0
  grCED\bCueCreated = #True
  debugMsg(sProcName, "grCED\bCueCreated=" + strB(grCED\bCueCreated))
  
EndProcedure

; fmEditProd
Structure strWEP
  ; sorted within groups
  ; NOTE: Production Properties controls separate from controls within the panel gadget pnlProd
  lblProdProperties.i
  pnlProd.i
  scaProdProperties.i
  ; NOTE: General tab controls
  ;{
  cboCueLabelIncrement.i
  cboDefOutputScreen.i
  cboMemoDispOptForPrim.i
  chkDefPauseAtEndA.i
  chkDefRepeatA.i
  chkEnableMidiCue.i
  chkLabelsFrozen.i
  chkLabelsUCase.i
  cntGenProps.i
  cntTabGeneral.i
  cntTemplate.i
  edgTmDesc.i
  lblCueLabelIncrement.i
  lblDefDisplayTimeA.i
  lblDefFadeInTime.i
  lblDefFadeInTimeA.i
  lblDefFadeInTimeI.i
  lblDefFadeOutTime.i
  lblDefFadeOutTimeA.i
  lblDefFadeOutTimeI.i
  lblDefLoopXFadeTime.i
  lblDefOutputScreen.i
  lblDefSFRTimeOverride.i
  lblMemoDispOptForPrim.i
  lblTemplateInfo.i
  lblTitle.i
  lblTmDesc.i
  lblTmName.i
  lnDefCueTypeSeperator.i[5]
  txtDefDisplayTimeA.i
  txtDefFadeInTime.i
  txtDefFadeInTimeA.i
  txtDefFadeInTimeI.i
  txtDefFadeOutTime.i
  txtDefFadeOutTimeA.i
  txtDefFadeOutTimeI.i
  txtDefLoopXFadeTime.i
  txtDefSFRTimeOverride.i
  txtTitle.i
  txtTmName.i
  ;}
  ; NOTE: Devices tab
  ;{
  btnApplyDevChgs.i
  btnDeleteDevMap.i
  btnRenameDevMap.i
  btnRetryActivate.i
  btnSaveAsDevMap.i
  btnUndoDevChgs.i
  cntDevices.i
  pnlDevs.i
  ; NOTE: DevMap Info
  cboDevMap.i
  cntDevMap.i[#SCS_PROD_TAB_INDEX_LAST+1]
  lblDevMap.i[#SCS_PROD_TAB_INDEX_LAST+1]
  lblMapping.i[#SCS_PROD_TAB_INDEX_LAST+1]
  txtDevMap.i[#SCS_PROD_TAB_INDEX_LAST+1]
  ; NOTE: Audio Driver Info
  btnDriverSettings.i[2]
  cboAudioDriver.i
  cntAudioDriver.i[#SCS_PROD_TAB_INDEX_LAST+1]
  lblAudioDriver.i[#SCS_PROD_TAB_INDEX_LAST+1]
  txtAudioDriver.i[#SCS_PROD_TAB_INDEX_LAST+1]
  ; NOTE: Audio Device Info
  Array cboAudioPhysicalDev.i(0)
  Array cboNumChans.i(0)
  Array cboOutputRange.i(0)
  Array chkAudActive.i(0)
  Array cntAudPhysDev.i(0)
  Array lblAudDevNo.i(0)
  Array sldAudOutputGain.i(0)
  Array txtAudLogicalDev.i(0)
  Array txtAudOutputGainDB.i(0)
  Array txtOutputDelayTime.i(0)
  ; NOTE: Video Audio Device Info
  Array cboVidAudPhysicalDev.i(0)
  Array cntVidAudPhysDev.i(0)
  Array lblVidAudDevNo.i(0)
  Array sldVidAudOutputGain.i(0)
  Array txtVidAudLogicalDev.i(0)
  Array txtVidAudOutputGainDB.i(0)
  ; NOTE: Video Capture Device Info
  Array cboVidCapPhysicalDev.i(0)
  Array cntVidCapPhysDev.i(0)
  Array lblVidCapDevNo.i(0)
  Array txtVidCapDummy.i(0)
  Array txtVidCapLogicalDev.i(0)
  ; NOTE: Fixture Type Info
  Array lblFixTypeNo.i(0)
  Array txtFixTypeInfo.i(0)
  Array txtFixTypeName.i(0)
  ; NOTE: Lighting Device Info
  Array cboLightingDevType.i(0)
  Array chkLightingActive.i(0)
  Array cntLightingPhysDev.i(0)
  Array lblLightingDevNo.i(0)
  Array txtLightingLogicalDev.i(0)
  Array txtLightingPhysDevInfo.i(0)
  ; NOTE: Control Send Device Info
  Array chkCtrlActive.i(0)
  Array cntCtrlPhysDev.i(0)
  Array cvsCtrlDevType.i(0)
  Array cvsCtrlDevTypeText.s(0) ; text content of cvsCtrlDevType
  Array lblCtrlDevNo.i(0)
  Array txtCtrlLogicalDev.i(0)
  Array txtCtrlPhysDevInfo.i(0)
  ; NOTE: Cue Control Device Info
  Array cboCueDevType.i(0)
  Array chkCueActive.i(0)
  Array cntCuePhysDev.i(0)
  Array lblCueDevNo.i(0)
  Array txtCuePhysDevInfo.i(0)
  ; NOTE: Live Input Device Info
  Array cboInputRange.i(0)
  Array cboLivePhysicalDev.i(0)
  Array cboNumInputChans.i(0)
  Array chkLiveActive.i(0)
  Array cntLivePhysDev.i(0)
  Array lblLiveDevNo.i(0)
  Array sldInputGain.i(0)
  Array txtInputGainDB.i(0)
  Array txtLiveLogicalDev.i(0)
  ; NOTE: Input Group Info
  Array lblInGrpNo.i(0)
  Array txtInGrpInfo.i(0)
  Array txtInGrpName.i(0)
  ; NOTE: Input Group Item Info
  Array cboInGrpLiveInput.i(0)
  ; NOTE: Devices / Audio Output controls
  ;{
  btnDfltDevCenter.i
  btnTestToneCancel.i
  btnTestToneCenter.i
  btnTestToneContinuous.i
  btnTestToneShort.i
  cboDfltDevTrim.i
  cboTestSound.i
  chkAutoInclude.i
  chkForLTC.i
  cntAudDevSideBar.i
  cntAudDfltSettings.i
  cntAudPhysDevLabels.i
  cntTabAudDevs.i
  cntTestTone.i
  imgAudButtonTBS.i[4]
  lblAudActive.i
  lblAudDefaults.i
  lblAudDevName.i
  lblAudDevsReqd.i
  lblAudPhysical.i
  lblDelayTime.i
  lblDfltDevDB.i
  lblDfltDevLevel.i
  lblDfltDevPan.i
  lblDfltDevTrim.i
  lblGain.i
  lblGainDB.i
  lblNumChans.i
  lblOutputRange.i
  lblTestSound.i
  lblTestToneConfirm.i
  lblTestToneLevel.i
  lblTestTonePan.i
  lnAudVertRight1.i
  lnAudVertRightInSCA.i
  lnAudVertSep.i
  lnAudVertSepInSCA.i
  pnlAudDevDetail.i
  scaAudioDevs.i
  sldDfltDevLevel.i
  sldDfltDevPan.i
  sldTestToneLevel.i
  sldTestTonePan.i
  txtDfltDevDBLevel.i
  txtDfltDevPan.i
  ;}
  ; NOTE: Devices / Video Audio controls
  ;{
  btnDfltVidAudCenter.i
  cboDfltVidAudTrim.i
  CompilerIf #c_allow_video_audio_routed_to_audio_device
    cboVidAudRouteToAudLogicalDev.i
  CompilerEndIf
  chkVidAudAutoInclude.i
  cntTabVidAudDevs.i
  cntVidAudDevSideBar.i
  cntVidAudDfltSettings.i
  cntVidAudPhysDevLabels.i
  imgVidAudButtonTBS.i[4]
  lblDfltVidAudDB.i
  lblDfltVidAudLevel.i
  lblDfltVidAudPan.i
  lblDfltVidAudTrim.i
  lblVidAudDefaults.i
  lblVidAudDevName.i
  lblVidAudDevsReqd.i
  lblVidAudGain.i
  lblVidAudGainDB.i
  lblVidAudPhysical.i
  CompilerIf #c_allow_video_audio_routed_to_audio_device
    lblVidAudRouteToAudLogicalDev.i
  CompilerEndIf
  lnVidAudVertRight1.i
  lnVidAudVertRightInSCA.i
  lnVidAudVertSep.i
  lnVidAudVertSepInSCA.i
  pnlVidAudDevDetail.i
  scaVidAudDevs.i
  sldDfltVidAudLevel.i
  sldDfltVidAudPan.i
  txtDfltVidAudDBLevel.i
  txtDfltVidAudPan.i
  ;}
  ; NOTE: Devices / Video Capture controls
  ;{
  btnTestVidCapStop.i
  btnTestVidCapStart.i
  cboVidCapDevFormat.i
  chkVidCapAutoInclude.i
  cntTabVidCapDevs.i
  cntTestVidCap.i
  cntVidCapDevDetail.i
  cntVidCapDevFormatEtc.i
  cntVidCapDevSideBar.i
  cntVidCapDfltSettings.i
  cntVidCapPhysDevLabels.i
  cvsTestVidCap.i
  imgVidCapButtonTBS.i[4]
  lblVidCapDevFormat.i
  lblVidCapDevFrameRate.i
  lblVidCapDevName.i
  lblVidCapDevsReqd.i
  lblVidCapPhysical.i
  lnVidCapVertRight1.i
  lnVidCapVertRightInSCA.i
  lnVidCapVertSep.i
  lnVidCapVertSepInSCA.i
  pnlVidCapDevDetail.i
  scaVidCapDevs.i
  txtVidCapDevFrameRate.i
  ;}
  ; NOTE: Devices / Fixture Type controls
  ;{
  chkFTCDimmerChan.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  cntFixTypeChannels.i
  cntFixTypeGeneral.i
  cntFixTypeSideBar.i
  cntFTCDetail.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  cntTabFixTypes.i
  cntTabFixTypesPre118.i
  cvsFTCGridSample.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  cvsFTCTextColor.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  imgFixTypeButtonTBS.i[4]
  lblFixtureTypes.i
  lblFixtureTypesPre118.i
  lblFixTypeDesc.i
  lblFixTypeInfo.i
  lblFixTypeName.i
  lblFTCChannel.i
  lblFTCChannelDesc.i
  lblFTCChanNo.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  lblFTCDefault.i
  lblFTCDimmerChan.i
  lblFTCGridSample.i
  lblFTCTextColor.i
  lblFTTotalChans.i
  lnFixTypeChannels.i
  pnlFixTypeDetail.i
  scaFixTypeChans.i
  scaFixTypes.i
  txtFixTypeDesc.i
  txtFTCChannelDesc.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  txtFTCDefault.i[#SCS_MAX_FIX_TYPE_CHANNEL]    ; the default value for this fixture channel
  txtFTTotalChans.i
  ;}
  ; NOTE: Devices / Lighting controls
  ;{
  btnCopyDMXStartsFrom.i
  btnDMXIPRefresh.i
  cboDMXPhysDev.i[2]
  cboDMXPort.i[2]
  cboDMXRefreshRate.i
  cboDMXIpAddress.i
  cntDMXSettings.i[2]
  cntDMXStartChannels.i
  cntFixtureLabels.i
  cntLightingDevDetail.i
  cntLightingDevSideBar.i
  cntLightingFixtureSideBar.i
  cntLightingPhysDevLabels.i
  cntPhysDMX.i[2]
  cntTabLightingDevs.i
  imgFixtureButtonTBS.i[4]
  imgLightingButtonTBS.i[4]
  lblDimmableChannels.i
  lblDMXPhysDev.i[2]
  lblDMXPort.i[2]
  lblDMXRefreshRate.i
  lblDMXIpAddress.i
  lblDMXStartChannel.i
  lblFixtureCode.i
  lblFixtureDesc.i
  lblFixtureDescPre118.i
  lblFixtures.i
  lblFixtureType.i
  lblLightingActive.i
  lblLightingDevDetail.i
  lblLightingDevName.i
  lblLightingDevsReqd.i
  lblLightingDevType.i
  lblLightingPhysical.i
  lnLightingVertRight1.i
  lnLightingVertRightInSCA.i
  lnLightingVertSep.i
  lnLightingVertSepInSCA.i
  scaFixtures.i
  scaLightingDevs.i
  ;}
  ; NOTE: Devices / Control Send controls (NB controls with [2] may also be used for Cue Control controls)
  ;{
  btnCompIPAddresses.i[2]
  btnRS232Default.i[2]
  cboCtrlMidiChannel.i
  cboCtrlMidiRemoteDev.i
  cboCtrlNetworkRemoteDev.i
  cboDelayBeforeReloadNames.i
  cboMidiOutPort.i
  cboMidiThruInPort.i
  cboMidiThruOutPort.i
  cboNetworkMsgAction.i[#SCS_MAX_NETWORK_MSG_RESPONSE+1]
  cboNetworkProtocol.i[2]
  cboNetworkRole.i[2]
  cboOSCVersion.i[2]
  cboRS232BaudRate.i[2]
  cboRS232DataBits.i[2]
  cboRS232DTREnable.i[2]
  cboRS232Handshaking.i[2]
  cboRS232Parity.i[2]
  cboRS232Port.i[2]
  cboRS232RTSEnable.i[2]
  cboRS232StopBits.i[2]
  chkForMTC.i
  chkM2TSkipEarlierCSMsgs_MidiOut.i
  chkConnectWhenReqd.i ; Added 19Sep2022 11.9.6
  chkGetRemDevScribbleStripNames.i
  chkNetworkDummy.i[2]
  chkNetworkReplyMsgAddCR.i
  chkNetworkReplyMsgAddLF.i
  cntCtrlDevDetail.i
  cntCtrlDevSideBar.i
  cntCtrlNetworkRemoteDevPW.i
  cntCtrlPhysDevLabels.i
  cntHTTPSettings.i
  cntMIDISettings.i[2]
  cntMidiThruSettings.i
  cntNetworkAddCRLF.i
  cntNetworkMsgResponses.i
  cntNetworkSettings.i[2]
  cntPhysMidi.i[2]
  cntPhysMidiThru.i
  cntPhysNetwork.i[2]
  cntPhysRS232.i[2]
  cntTabCtrlDevs.i
  imgCtrlButtonTBS.i[4]
  lblBaudRate.i[2]
  lblConnectTo.i
  lblCtrlActive.i
  lblCtrlDevDetail.i
  lblCtrlDevName.i
  lblCtrlDevsReqd.i
  lblCtrlDevType.i
  lblCtrlInfo.i
  lblCtrlMidiChannel.i
  lblCtrlMidiRemoteDev.i
  lblCtrlNetworkRemoteDev.i
  lblCtrlNetworkRemoteDevPW.i
  lblCtrlPhysical.i
  lblCtrlSendDelay.i
  lblDataBits.i[2]
  lblDelayBeforeReloadNames.i
  lblHTTPStart.i
  lblLocalPort.i[2]
  lblMidiOutPort.i
  lblMidiThruInPort.i
  lblMidiThruOutPort.i
  lblNetworkMsgAction.i
  lblNetworkMsgResponses.i
  lblNetworkProtocol.i[2]
  lblNetworkReceiveMsg.i
  lblNetworkReplyMsg.i
  lblNetworkRole.i[2]
  lblOSCVersion.i[2]
  lblParity.i[2]
  lblRemoteHost.i[2]
  lblRemotePort.i[2]
  lblRS232DTREnable.i[2]
  lblRS232Handshaking.i[2]
  lblRS232Port.i[2]
  lblRS232RTSEnable.i[2]
  lblStopBits.i[2]
  lnCtrlVertRight1.i
  lnCtrlVertRightInSCA.i
  lnCtrlVertSep.i
  lnCtrlVertSepInSCA.i
  optDMXOutPref.i[2]
  scaCtrlDevs.i
  scaNetworkMsgResponses.i
  txtCtrlNetworkRemoteDevPW.i
  txtCtrlSendDelay.i
  txtHTTPStart.i
  txtLocalPort.i[2]
  txtNetworkReceiveMsg.i[#SCS_MAX_NETWORK_MSG_RESPONSE+1]
  txtNetworkReplyMsg.i[#SCS_MAX_NETWORK_MSG_RESPONSE+1]
  txtRemoteHost.i[2]
  txtRemotePort.i[2]
  ;}
  ; NOTE: Devices / Cue Control controls (NB some controls may be listed under Control Send controls with [2])
  ;{
  btnTestDMX.i
  btnTestMidi.i
  btnTestNetwork.i
  btnTestRS232.i
  cboCtrlMethod.i
  cboCueNetworkRemoteDev.i
  cboDMXTrgValue.i
  cboGoMacro.i
  cboMidiCC.i[#SCS_MAX_MIDI_COMMAND+1]
  cboMidiChannel.i
  cboMidiCommand.i[#SCS_MAX_MIDI_COMMAND+1]
  cboMidiDevId.i
  cboMidiInPort.i
  cboMidiVV.i[#SCS_MAX_MIDI_COMMAND+1]
  cboMSCCommandFormat.i
  cboNetworkMsgFormat.i
  cboThresholdVV.i
  cboX32Command.i[#SCS_MAX_X32_COMMAND+1]
  chkMMCApplyFadeForStop.i
  cntCueDevDetail.i
  cntCuePhysDevLabels.i
  cntDMXCommands.i
  cntDMXPref.i[2]
  cntDMXTrgCtrl.i
  cntMidiAssigns.i
  cntMidiCueCtrl.i
  cntMidiSpecial.i
  cntMSC.i
  cntNetworkAssigns.i
  cntNonMSC.i
  cntRS232Assigns.i
  cntRS232Settings.i[2]
  cntSettingsReqd.i
  cntTabCueDevs.i
  cntX32Special.i
  edgMidiAssigns.i
  edgNetworkAssigns.i
  edgRS232Assigns.i
  frDMXCommands.i
  frMidiAssigns.i
  frMidiSpecial.i
  frNetworkAssigns.i
  frRS232Assigns.i
  frX32Special.i
  lblCC.i[#SCS_MAX_MIDI_COMMAND+1]
  lblCommand.i[#SCS_MAX_MIDI_COMMAND+1]
  lblCtrlMethod.i
  lblCueActive.i
  lblCueDevDetail.i
  lblCueDevType.i
  lblCueHdg.i
  lblCueInfo.i
  lblCueNetworkRemoteDev.i
  lblCuePhysical.i
  lblDMXChannel.i
  lblDMXCommand.i[#SCS_MAX_DMX_COMMAND+1]
  lblDMXPref.i[2]
  lblDMXTrgCtrl.i
  lblDMXTrgValue.i
  lblGoMacro.i
  lblMidiChannel.i
  lblMidiDevId.i
  lblMidiInPort.i
  lblMSCCommandFormat.i
  lblThresholdVV.i
  lblX32Command.i[#SCS_MAX_X32_COMMAND+1]
  lnCueVertRight1.i
  lnCueVertRightInSCA.i
  lnCueVertSep.i
  lnCueVertSepInSCA.i
  lnMidi.i
  lnNetwork.i
  lnRS232.i
  optDMXInPref.i[2]
  optDMXTrgCtrl.i[3]
  scaCueDevs.i
  scaMidiSpecial.i
  scaX32Special.i
  txtDMXChannel.i[#SCS_MAX_DMX_COMMAND+1]
  ;}
  ; NOTE: Devices / Live Input controls
  ;{
  btnTestLiveInputCancel.i
  btnTestLiveInputStart.i
  cboOutputDevForTestLiveInput.i
  chkInputForLTC.i
  cntInputSettings.i
  cntLiveDevSideBar.i
  cntLivePhysDevLabels.i
  cntTabLiveDevs.i
  cntTestLiveInput.i
  cvsTestLiveInputVU.i
  imgLiveButtonTBS.i[4]
  lblDfltInputDevDB.i
  lblDfltInputDevLevel.i
  lblInputDefaults.i
  lblInputGain.i
  lblInputGainDB.i
  lblInputRange.i
  lblInputsReqd.i
  lblLiveActive.i
  lblLiveDevName.i
  lblLivePhysical.i
  lblNumInputChans.i
  lblOutputDevForTestLiveInput.i
  lnLiveVertRight1.i
  lnLiveVertRightInSCA.i
  lnLiveVertSep.i
  lnLiveVertSepInSCA.i
  pnlLiveInputDevDetail.i
  scaLiveDevs.i
  sldDfltInputDevLevel.i
  txtDfltInputDevDBLevel.i
  ;}
  ; NOTE: Devices / Input Group controls
  ;{
  cntInGrpDetail.i
  cntInGrpSideBar.i
  cntTabInGrps.i
  imgInGrpButtonTBS.i[4]
  lblInGrpInfo.i
  lblInGrpInputs.i
  lblInGrpName.i
  lblInGrpsReqd.i
  pnlInGrpDetail.i
  scaInGrpLiveInputs.i
  scaInGrps.i
  ;}
  ; NOTE: Time Profiles tab
  ;{
  cboDfltTimeProfile.i
  cboDfltTimeProfileForDay.i[7]
  cboResetTOD.i
  cntTabTimeProfiles.i
  lblDfltTimeProfile.i
  lblDfltTimeProfileByDay.i
  lblDfltTimeProfileDay.i[7]
  lblProfileName.i
  lblProfileNo.i[#SCS_MAX_TIME_PROFILE+1]
  lblResetTOD.i
  lblTimeProfiles.i
  txtTimeProfile.i[#SCS_MAX_TIME_PROFILE+1]
  ;}
  ; NOTE: Run Time Settings tab
  ;{
  cboFocusPoint.i
  cboGridClickAction.i
  cboLostFocusAction.i
  cboMaxDBLevel.i
  cboMinDBLevel.i
  cboRunMode.i
  cboVisualWarningFormat.i
  cboVisualWarningTime.i
  chkAllowHKeyClick.i
  chkDoNotCalcCueStartValues.i
  chkNoPreLoadVideoHotkeys.i
  chkPreLoadNextManualOnly.i
  chkStopAllInclHib.i
  cntDMXMasterFader.i
  cntMasterFader.i
  cntTabRunTime.i
  lblDBLevelChangeIncrement.i
  lblDBLevelChangeIncrementDB.i
  lblDefChaseSpeed.i
  lblDefDMXFadeTime.i
  lblDMXMasterFader.i
  lblFocusPoint.i
  lblGridClickAction.i
  lblLostFocusAction.i
  lblMasterFader.i
  lblMasterFaderDB.i
  lblMaxDBLevel.i
  lblMinDBLevel.i
  lblRunMode.i
  lblRunTimeSettings.i
  lblVisualWarningFormat.i
  lblVisualWarningTime.i
  lnRunTimeAudio.i
  lnRunTimeDMX.i
  sldDMXMasterFader2.i
  sldMasterFader2.i
  txtDBLevelChangeIncrement.i
  txtDefChaseSpeed.i
  txtDefDMXFadeTime.i
  txtMasterFaderDB.i
  ;}
  ; common fields
  nDevInnerWidth.i : nDevInnerHeight.i
  nScaDevsLeft.i : nScaDevsTop.i : nScaDevsWidth.i : nScaDevsHeight.i
  nDevDetailLeft.i : nDevDetailTop.i : nDevDetailWidth.i : nDevDetailHeight.i
  nDevPanelItemWidth.i : nDevPanelItemHeight.i
  nSideBarLeft.i : nSideBarWidth.i
  nLevelLeft.i : nVertSepLeft.i : nVertBorderRight.i
  nPhysBackColor.l
EndStructure

Structure strWEPFixture ; For fixtures used by Devices / Lighting
  cboFixtureType.i
  cntFixture.i
  cntFixturePhysicalInfo.i
  lblFixtureNo.i
  txtDimmableChannels.i
  txtDMXStartChannel.i
  txtFixtureCode.i
  txtFixtureDesc.i
  bFixtureUpdated.i
  nFixtureId.i
EndStructure

Global WEP.strWEP ; fmEditProd
Global Dim WEPFixture.strWEPFixture(0)
Global gnWEPFixtureCurrItem
Global gnWEPFixtureLastItem

Procedure setWEPMaxLoadProgress()
  With grWEP
    \nMaxLoadProgress = 0
    \nMaxLoadProgress + 2 ; General Tab (one for createfmEditProd(), and one for WEP_Form_Load())
    \nMaxLoadProgress + 2 ; Audio Output Devices (ditto)
    If grLicInfo\nMaxVidAudDevPerProd >= 0
      \nMaxLoadProgress + 2 ; Video Audio Devices
    EndIf
    If grLicInfo\nMaxVidCapDevPerProd >= 0
      \nMaxLoadProgress + 2 ; Video Capture Devices
    EndIf
    If grLicInfo\nMaxFixTypePerProd >= 0
      \nMaxLoadProgress + 2 ; Fixture Types
    EndIf
    If grLicInfo\nMaxLightingDevPerProd >= 0
      \nMaxLoadProgress + 2 ; Lighting Devices
    EndIf
    If grLicInfo\nMaxCtrlSendDevPerProd >= 0
      \nMaxLoadProgress + 2 ; Control Send Devices
    EndIf
    If grLicInfo\nMaxCueCtrlDev >= 0
      \nMaxLoadProgress + 2 ; Cue Control Devices
    EndIf
    If grLicInfo\nMaxLiveDevPerProd >= 0
      \nMaxLoadProgress + 2 ; Live Inputs
    EndIf
    If grLicInfo\nMaxInGrpPerProd >= 0
      \nMaxLoadProgress + 2 ; Input Groups
    EndIf
    If grLicInfo\bTimeProfilesAvailable
      \nMaxLoadProgress + 2 ; Time Profiles
    EndIf
    \nMaxLoadProgress + 2 ; Run Time Settings
    \nMaxLoadProgress + 1 ; for end of WEP_Form_Load(), ie after WEP_drawForm(), etc
  EndWith
EndProcedure

Procedure createWEPDevMapInfo(Index, nCntLeft)
  PROCNAMEC()
  Protected sNr.s
  Protected nCntWidth, nCntHeight, nTop
  Static sMapping.s, sTextDevMap.s, sToolTip.s, nPhysBackColor
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nCntLeft=" + nCntLeft)
  
  If bStaticLoaded = #False
    sMapping = Lang("WEP", "lblMapping")
    sTextDevMap = Lang("WEP", "lblDevMap")
    sToolTip = LangPars("WEP", "OnThisComputerTT", sTextDevMap)
    nPhysBackColor = #SCS_Phys_BackColor
    bStaticLoaded = #True
  EndIf
  
  With WEP
    sNr = "[" + Index + "]"
    nCntWidth = GetGadgetAttribute(\pnlDevs, #PB_Panel_ItemWidth) - nCntLeft - 2
    Select Index
      Case #SCS_PROD_TAB_INDEX_AUD_DEVS
        nCntHeight = 52
        nTop = 24
      Case #SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS, #SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS
        nCntHeight = 62
        nTop = 29
      Default
        nCntHeight = 52
        nTop = 24
    EndSelect
    \cntDevMap[Index]=scsContainerGadget(nCntLeft, 0, nCntWidth, nCntHeight, #PB_Container_Flat, "cntDevMap"+sNr)
      \lblMapping[Index]=scsTextGadget(8,4,418,18,sMapping,0,"lblMapping"+sNr)
      scsSetGadgetFont(\lblMapping[Index], #SCS_FONT_GEN_BOLDUL)
      If Index = #SCS_PROD_TAB_INDEX_AUD_DEVS
        ; The user may change the Audio Driver in the first devices tab (Audio Output)
        \lblDevMap[Index]=scsTextGadget(8,nTop+gnLblVOffsetC,70,17,sTextDevMap,#PB_Text_Right,"lblDevMap"+sNr)
        setGadgetWidth(\lblDevMap[Index], -1, #True)
        \cboDevMap=scsComboBoxGadget(gnNextX+gnGap,nTop,200,21,0,"cboDevMap")
        scsToolTip(\cboDevMap, sToolTip)
      Else
        ; The Audio Driver field is display-only on other devices tabs
        \lblDevMap[Index]=scsTextGadget(8,nTop+gnLblVOffsetS,70,17,sTextDevMap,#PB_Text_Right,"lblDevMap"+sNr)
        setGadgetWidth(\lblDevMap[Index], -1, #True)
        \txtDevMap[Index]=scsStringGadget(gnNextX+gnGap,nTop,200,20,"",0,"txtDevMap"+sNr)
        setEnabled(\txtDevMap[Index], #False)
        setTextBoxBackColor(\txtDevMap[Index])
      EndIf
      setAllowEditorColors(\cntDevMap[Index],#False)
      setAllowEditorColors(\lblMapping[Index],#False)
      setAllowEditorColors(\lblDevMap[Index],#False)
      SetGadgetColor(\cntDevMap[Index],#PB_Gadget_BackColor,nPhysBackColor)
      SetGadgetColor(\lblMapping[Index],#PB_Gadget_BackColor,nPhysBackColor)
      SetGadgetColor(\lblDevMap[Index],#PB_Gadget_BackColor,nPhysBackColor)
    scsCloseGadgetList()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createWEPAudioDriverInfo(Index)
  PROCNAMEC()
  Protected sNr.s
  Protected nCntLeft, nCntTop, nCntWidth, nCntHeight
  Protected nTop
  Static sTextDriver.s, sToolTip.s
  Static nPhysBackColor
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WEP
    If bStaticLoaded = #False
      sTextDriver = Lang("WEP", "lblAudioDriver")
      sToolTip = LangPars("WEP", "OnThisComputerTT", sTextDriver)
      nPhysBackColor = #SCS_Phys_BackColor
      bStaticLoaded = #True
    EndIf
    
    sNr = "[" + Index + "]"
    nCntLeft = GadgetX(\cntDevMap[#SCS_PROD_TAB_INDEX_AUD_DEVS])
    nCntTop = GadgetY(\cntDevMap[#SCS_PROD_TAB_INDEX_AUD_DEVS]) + GadgetHeight(\cntDevMap[#SCS_PROD_TAB_INDEX_AUD_DEVS]) - 1 ; minus 1 to overlap borders of the flat containers
    nCntWidth = GadgetWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_AUD_DEVS])
    nCntHeight = 34
    \cntAudioDriver[Index]=scsContainerGadget(nCntLeft,nCntTop,nCntWidth,nCntHeight,#PB_Container_Flat,"cntAudioDriver"+sNr)
      nTop = 5
      \lblAudioDriver[Index]=scsTextGadget(8,nTop+gnLblVOffsetC,70,17,sTextDriver,#PB_Text_Right,"lblAudioDriver"+sNr)
      setGadgetWidth(\lblAudioDriver[Index], -1, #True)
      If Index = #SCS_PROD_TAB_INDEX_AUD_DEVS
        \cboAudioDriver=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboAudioDriver")
        \btnDriverSettings=scsButtonGadget(gnNextX+12,nTop-1,120,gnBtnHeight,LangEllipsis("WEP","btnDriverSettings"),0,"btnDriverSettings")
        scsToolTip(\cboAudioDriver, sToolTip)
      Else
        \txtAudioDriver[Index]=scsStringGadget(gnNextX+gnGap,nTop,160,21,"",0,"txtAudioDriver"+sNr)
        setEnabled(\txtAudioDriver[Index], #False)
      EndIf
      setAllowEditorColors(\cntAudioDriver[Index],#False)
      setAllowEditorColors(\lblAudioDriver[Index],#False)
      SetGadgetColor(\cntAudioDriver[Index],#PB_Gadget_BackColor,nPhysBackColor)
      SetGadgetColor(\lblAudioDriver[Index],#PB_Gadget_BackColor,nPhysBackColor)
    scsCloseGadgetList()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createWEPAudDevs()
  PROCNAMEC()
  ; creates new audio output devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize, n
  
  ; debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxAudioLogicalDev=" + grProdForDevChgs\nMaxAudioLogicalDev + ", \nMaxAudioLogicalDevDisplay=" + grProdForDevChgs\nMaxAudioLogicalDevDisplay)
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaAudioDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxAudioLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblAudDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblAudDevNo(nReqdArraySize)
        ReDim \txtAudLogicalDev(nReqdArraySize)
        ReDim \cboNumChans(nReqdArraySize)
        ReDim \cntAudPhysDev(nReqdArraySize)
        ReDim \cboAudioPhysicalDev(nReqdArraySize)
        ReDim \cboOutputRange(nReqdArraySize)
        ReDim \sldAudOutputGain(nReqdArraySize)
        ReDim \txtAudOutputGainDB(nReqdArraySize)
        ReDim \chkAudActive(nReqdArraySize)
        ReDim \txtOutputDelayTime(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        ; debugMsg(sProcName, "IsGadget(\lblAudDevNo(" + nIndex + "))=" + IsGadget(\lblAudDevNo(nIndex)))
        If IsGadget(\lblAudDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblAudDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblAudDevNo(nIndex)=scsStringGadget(2,nTop+1,34,19,"A"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblAudDevNo"+sNr)
          SetGadgetColor(\lblAudDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblAudDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \txtAudLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtAudLogicalDev"+sNr)
          \cboNumChans(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,73,21,0,"cboNumChans"+sNr)
          ; physical dev info
          nLeft = gnNextX+4
          If GadgetX(\lnAudVertSepInSCA) <> nLeft
            ResizeGadget(\lnAudVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntAudPhysDevLabels)
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntAudPhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntAudPhysDev"+sNr)
            nTop = 0
            If gbDelayTimeAvailable
              \cboAudioPhysicalDev(nIndex)=scsComboBoxGadget(7,nTop,120,21,0,"cboAudioPhysicalDev"+sNr)
              \cboOutputRange(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,60,21,0,"cboOutputRange"+sNr)
              \txtOutputDelayTime(nIndex)=scsStringGadget(gnNextX+2,nTop,38,21,"",0,"txtOutputDelayTime"+sNr)
              setValidChars(\txtOutputDelayTime(nIndex), "0123456789.:")
              \sldAudOutputGain(nIndex)=SLD_New("PR_OutputGain"+Str(n+1),\cntAudPhysDev(nIndex),0,gnNextX+2,nTop,94,21,#SCS_ST_HLEVELNODB,0,1000)
              \txtAudOutputGainDB(nIndex)=scsStringGadget(gnNextX+2,nTop,34,21,"",0,"txtAudOutputGainDB"+sNr)
              nLeft = gnNextX + 4
            Else
              \cboAudioPhysicalDev(nIndex)=scsComboBoxGadget(7,nTop,160,21,0,"cboAudioPhysicalDev"+sNr)
              \cboOutputRange(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,60,21,0,"cboOutputRange"+sNr)
              \sldAudOutputGain(nIndex)=SLD_New("PR_OutputGain"+Str(n+1),\cntAudPhysDev(nIndex),0,gnNextX+2,nTop,94,21,#SCS_ST_HLEVELNODB,0,1000)
              \txtAudOutputGainDB(nIndex)=scsStringGadget(gnNextX+2,nTop,34,21,"",0,"txtAudOutputGainDB"+sNr)
              nLeft = gnNextX + 4
            EndIf
            \chkAudActive(nIndex)=scsCheckBoxGadget2(nLeft,nTop+2,17,17,"",0,"chkAudActive"+sNr)
            setOwnEnabled(\chkAudActive(nIndex), #False)
            setAllowEditorColors(\cntAudPhysDev(nIndex),#False)
            setAllowEditorColors(\chkAudActive(nIndex),#False)
            SetGadgetColor(\cntAudPhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
            setOwnColor(\chkAudActive(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
          ED_fcAudLogicalDev(nIndex)
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_AUDIO_OUTPUT)
  EndWith
  
  gnCurrentEditorComponent = 0
  
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure createWEPVidAudDevs()
  PROCNAMEC()
  ; create WEP gadgets for any new video audio devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  ; debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxVidAudLogicalDev=" + grProdForDevChgs\nMaxVidAudLogicalDev + ", \nMaxVidAudLogicalDevDisplay=" + grProdForDevChgs\nMaxVidAudLogicalDevDisplay)
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaVidAudDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxVidAudLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblVidAudDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblVidAudDevNo(nReqdArraySize)
        ReDim \txtVidAudLogicalDev(nReqdArraySize)
        ReDim \cntVidAudPhysDev(nReqdArraySize)
        ReDim \cboVidAudPhysicalDev(nReqdArraySize)
        ReDim \sldVidAudOutputGain(nReqdArraySize)
        ReDim \txtVidAudOutputGainDB(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblVidAudDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblVidAudDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblVidAudDevNo(nIndex)=scsStringGadget(2,nTop+1,34,19,"VA"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblVidAudDevNo"+sNr)
          SetGadgetColor(\lblVidAudDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblVidAudDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \txtVidAudLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtVidAudLogicalDev"+sNr)
          ; physical dev info
          nLeft = gnNextX+4
          If GadgetX(\lnVidAudVertSepInSCA) <> nLeft
            ResizeGadget(\lnVidAudVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntVidAudPhysDevLabels)
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntVidAudPhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntVidAudPhysDev"+sNr)
            nTop = 0
            \cboVidAudPhysicalDev(nIndex)=scsComboBoxGadget(6,nTop,180,21,0,"cboVidAudPhysicalDev"+sNr)
            \sldVidAudOutputGain(nIndex)=SLD_New("PR_OutputGain"+Str(nIndex+1),\cntVidAudPhysDev(nIndex),0,gnNextX+2,nTop,94,21,#SCS_ST_HLEVELNODB,0,1000)
            \txtVidAudOutputGainDB(nIndex)=scsStringGadget(gnNextX+2,nTop,34,21,"",0,"txtVidAudOutputGainDB"+sNr)
            setAllowEditorColors(\cntVidAudPhysDev(nIndex),#False)
            SetGadgetColor(\cntVidAudPhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
          ED_fcVidAudLogicalDev(nIndex)
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_VIDEO_AUDIO)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPVidCapDevs()
  PROCNAMEC()
  ; create WEP gadgets for any new video audio devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  ; debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxVidCapLogicalDev=" + grProdForDevChgs\nMaxVidCapLogicalDev + ", \nMaxVidCapLogicalDevDisplay=" + grProdForDevChgs\nMaxVidCapLogicalDevDisplay)
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaVidCapDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxVidCapLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblVidCapDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblVidCapDevNo(nReqdArraySize)
        ReDim \txtVidCapLogicalDev(nReqdArraySize)
        ReDim \cntVidCapPhysDev(nReqdArraySize)
        ReDim \cboVidCapPhysicalDev(nReqdArraySize)
        ReDim \txtVidCapDummy(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblVidCapDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblVidCapDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblVidCapDevNo(nIndex)=scsStringGadget(2,nTop+1,34,19,"VC"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblVidCapDevNo"+sNr)
          SetGadgetColor(\lblVidCapDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblVidCapDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \txtVidCapLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtVidCapLogicalDev"+sNr)
          ; physical dev info
          nLeft = gnNextX+4
          If GadgetX(\lnVidCapVertSepInSCA) <> nLeft
            ResizeGadget(\lnVidCapVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntVidCapPhysDevLabels)
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntVidCapPhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntVidCapPhysDev"+sNr)
            nTop = 0
            \cboVidCapPhysicalDev(nIndex)=scsComboBoxGadget(6,nTop,180,21,0,"cboVidCapPhysicalDev"+sNr)
            setAllowEditorColors(\cntVidCapPhysDev(nIndex),#False)
            SetGadgetColor(\cntVidCapPhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
            ; ResizeGadget(\cntVidCapPhysDev(nIndex),#PB_Ignore,#PB_Ignore,gnNextX+gnGap,#PB_Ignore)
          scsCloseGadgetList()
          ; now create a dummy text field out of sight so that when the user presses tab after entering a new logical dev the cursor doesn't go down to the next line
          nLeft = GadgetWidth(\scaVidCapDevs) + 100
          \txtVidCapDummy(nIndex)=scsStringGadget(nLeft,nTop,40,17,"",0,"txtVidCapDummy"+sNr)
          ED_fcVidCapLogicalDev(nIndex)
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_VIDEO_CAPTURE)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPFixTypes()
  PROCNAMEC()
  ; create WEP gadgets for any new fixture types
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  ; debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxFixType=" + grProdForDevChgs\nMaxFixType + ", \nMaxFixTypeDisplay=" + grProdForDevChgs\nMaxFixTypeDisplay)
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaFixTypes)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxFixTypeDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblFixTypeNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblFixTypeNo(nReqdArraySize)
        ReDim \txtFixTypeName(nReqdArraySize)
        ReDim \txtFixTypeInfo(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblFixTypeNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblFixTypeNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblFixTypeNo(nIndex)=scsStringGadget(2,nTop+1,34,19,"FT"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblFixTypeNo"+sNr)
          SetGadgetColor(\lblFixTypeNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblFixTypeNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; fixture type info
          \txtFixTypeName(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtFixTypeName"+sNr)
          \txtFixTypeInfo(nIndex)=scsStringGadget(gnNextX+8,nTop,400,21,"",#PB_String_ReadOnly,"txtFixTypeInfo"+sNr)
          ; nb commented out the following so that tabbing out of \txtFixTypeName(nIndex) doesn't go down to the next line but stays on the current item
          ; by setting focus to the readonly field \txtFixTypeInfo(nIndex)
          ; setEnabled(\txtFixTypeInfo(nIndex), #False)
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_FIX_TYPE)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPLightingDevs()
  PROCNAMEC()
  ; create WEP gadgets for any new lighting devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxLightingLogicalDev=" + grProdForDevChgs\nMaxLightingLogicalDev + ", \nMaxLightingLogicalDevDisplay=" + grProdForDevChgs\nMaxLightingLogicalDevDisplay)
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaLightingDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxLightingLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblLightingDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblLightingDevNo(nReqdArraySize)
        ReDim \cboLightingDevType(nReqdArraySize)
        ReDim \txtLightingLogicalDev(nReqdArraySize)
        ReDim \cntLightingPhysDev(nReqdArraySize)
        ReDim \txtLightingPhysDevInfo(nReqdArraySize)
        ReDim \chkLightingActive(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblLightingDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblLightDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblLightingDevNo(nIndex)=scsStringGadget(2,nTop+1,32,19,"LT"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblLightingDevNo"+sNr)
          SetGadgetColor(\lblLightingDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblLightingDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \cboLightingDevType(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,100,21,0,"cboLightingDevType"+sNr)
          \txtLightingLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtLightingLogicalDev"+sNr)
          ; physical dev info
          nLeft = gnNextX+6
          If GadgetX(\lnLightingVertSepInSCA) <> nLeft
            ResizeGadget(\lnLightingVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntLightingPhysDevLabels) ; use this if scrollbar is NOT visible
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntLightingPhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntLightingPhysDev"+sNr)
            nTop = 0
            \txtLightingPhysDevInfo(nIndex)=scsStringGadget(7,nTop,300,21,"",0,"txtLightingPhysDevInfo"+sNr)
            setEnabled(\txtLightingPhysDevInfo(nIndex), #False)
            setTextBoxBackColor(\txtLightingPhysDevInfo(nIndex))
            nLeft = gnNextX + 12
            \chkLightingActive(nIndex)=scsCheckBoxGadget2(nLeft,nTop+2,17,17,"",0,"chkLightingActive"+sNr)
            setOwnEnabled(\chkLightingActive(nIndex), #False)
            setAllowEditorColors(\cntLightingPhysDev(nIndex),#False)
            setAllowEditorColors(\chkLightingActive(nIndex),#False)
            SetGadgetColor(\cntLightingPhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
            setOwnColor(\chkLightingActive(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_LIGHTING)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure setWEPFixturePositions()
  PROCNAMEC()
  Protected n, nTop, nInnerHeight
  Protected nReqdDescWidth, bFixtureTypeVisible, bDimmableChannelsVisible
  
  If grProd\bLightingPre118
    nReqdDescWidth = 200
    bDimmableChannelsVisible = #True
  Else
    nReqdDescWidth = 100
    bFixtureTypeVisible = #True
  EndIf

  For n = 0 To gnWEPFixtureLastItem
    With WEPFixture(n)
      nTop = n * 21
      If GadgetY(WEPFixture(n)\cntFixture) <> nTop
        ResizeGadget(WEPFixture(n)\cntFixture, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      EndIf
      setVisible(\txtDimmableChannels, bDimmableChannelsVisible)
      setVisible(\cboFixtureType, bFixtureTypeVisible)
      If GadgetWidth(\txtFixtureDesc) <> nReqdDescWidth
        ResizeGadget(\txtFixtureDesc, #PB_Ignore, #PB_Ignore, nReqdDescWidth, #PB_Ignore)
      EndIf
    EndWith
  Next n
  nInnerHeight = 21 * (gnWEPFixtureLastItem + 1)
  SetGadgetAttribute(WEP\scaFixtures, #PB_ScrollArea_InnerHeight, nInnerHeight)
  
EndProcedure

Procedure createWEPFixture()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth
  Protected sFixtureId.s
  Protected n, nFirstGadgetNo, nLastGadgetNo
  Static sDimmableChannelsTooltip.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sDimmableChannelsTooltip = Lang("WEP", "txtDimmableChannelsTT")
    bStaticLoaded = #True
  EndIf
  
  gnWEPFixtureCurrItem + 1
  gnWEPFixtureLastItem + 1
  ; debugMsg(sProcName, "gnWEPFixtureCurrItem=" + gnWEPFixtureCurrItem + ", gnWEPFixtureLastItem=" + gnWEPFixtureLastItem)
  If gnWEPFixtureLastItem > ArraySize(WEPFixture())
    ReDim WEPFixture(gnWEPFixtureLastItem + 20)
  EndIf
  For n = (gnWEPFixtureLastItem-1) To gnWEPFixtureCurrItem Step -1
    WEPFixture(n+1) = WEPFixture(n)
    WEPFixture(n+1)\bFixtureUpdated = #True
  Next n
  
  gnCurrentEditorComponent = #WEP
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  scsOpenGadgetList(WEP\scaFixtures)
    With WEPFixture(gnWEPFixtureCurrItem)
      If IsGadget(\cntFixture)
        ; container already exists, so clear the displayed content
        SGT(\txtFixtureCode, "")
        SGT(\txtFixtureDesc, "")
        SGS(\cboFixtureType, 0)
        SGT(\txtDimmableChannels, "")
        SGT(\txtDMXStartChannel, "")
      Else
        \nFixtureId = grWEP\nFixtureId  ; unique id for this fixture
        sFixtureId = "[" + \nFixtureId + "]"
        nTop = gnWEPFixtureCurrItem * 21
        \cntFixture=scsContainerGadget(0,nTop,GadgetWidth(WEP\scaFixtures),21,#PB_Container_BorderLess,"cntFixture"+sFixtureId)
          nFirstGadgetNo = \cntFixture
          ; nb using a StringGadget rather than a TextGadget for \lblDevNo[n] so we receive an event when the user clicks on the gadget
          \lblFixtureNo=scsStringGadget(0,1,32,19,"F"+Str(gnWEPFixtureCurrItem+1),#PB_String_ReadOnly|#ES_CENTER,"lblFixtureNo"+sFixtureId,#SCS_G4EH_PR_LBLFIXTURENO)
          ; WARNING! WEP__EventHandler() relies on the 'sName' for this gadget starting with "lblFixtureNo"
          SetGadgetColor(\lblFixtureNo, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblFixtureNo, #PB_Gadget_FrontColor, #SCS_Black)
          ; fixture info
          \txtFixtureCode=scsStringGadget(gnNextX+2,0,70,21,"",#PB_String_UpperCase,"txtFixtureCode"+sFixtureId,#SCS_G4EH_PR_TXTFIXTURECODE)
          \txtFixtureDesc=scsStringGadget(gnNextX+2,0,100,21,"",0,"txtFixtureDesc"+sFixtureId,#SCS_G4EH_PR_TXTFIXTUREDESC)
          ; Fixture Type (added 11.7.2)
          \cboFixtureType=scsComboBoxGadget(gnNextX+2,0,222,21,0,"cboFixtureType"+sFixtureId,#SCS_G4EH_PR_CBOFIXTURETYPE)
          WEP_populateCboFixtureType(gnWEPFixtureCurrItem)
          ; Dimmable Channels (for pre-11.8 definitions)
          \txtDimmableChannels=scsStringGadget(GadgetX(\txtFixtureDesc)+200,0,120,21,"",0,"txtDimmableChannels"+sFixtureId,#SCS_G4EH_PR_TXTDIMMABLECHANNELS)
          scsToolTip(\txtDimmableChannels, sDimmableChannelsTooltip)
          setVisible(\txtDimmableChannels, #False)
          ; Physical Info
          nLeft = GadgetX(\cboFixtureType) + GadgetWidth(\cboFixtureType) + gnGap2
          \cntFixturePhysicalInfo=scsContainerGadget(nLeft,0,110,21,0,"cntFixturePhysicalInfo"+sFixtureId) ; nb same X position as \txtDimmableChannels
            setAllowEditorColors(\cntFixturePhysicalInfo,#False)
            SetGadgetColor(\cntFixturePhysicalInfo, #PB_Gadget_BackColor, #SCS_Phys_BackColor)
            nWidth = 60
            nLeft = (GadgetWidth(\cntFixturePhysicalInfo) - nWidth) >> 1
            \txtDMXStartChannel=scsStringGadget(nLeft,1,nWidth,19,"",0,"txtDMXStartChannel"+sFixtureId,#SCS_G4EH_PR_TXTDMXSTARTCHANNEL)
            nLastGadgetNo = \txtDMXStartChannel
          scsCloseGadgetList()
        scsCloseGadgetList()
        grWEP\nFixtureId + 1
      EndIf
      WEP_setDMXStartChannelsTooltip(\txtDMXStartChannel)
      ED_fcFixtureCode(gnWEPFixtureCurrItem)
      setVisible(\cntFixture, #True)
    EndWith
  scsCloseGadgetList()
  If nFirstGadgetNo <> 0
    colorEditorComponent(#WEP, nFirstGadgetNo, nLastGadgetNo)
  EndIf
  
  setWEPFixturePositions()
  gnCurrentEditorComponent = 0

EndProcedure

Procedure createWEPCtrlSendDevs()
  PROCNAMEC()
  ; creates new control send devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaCtrlDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblCtrlDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblCtrlDevNo(nReqdArraySize)
        ReDim \cvsCtrlDevType(nReqdArraySize)
        ReDim \cvsCtrlDevTypeText(nReqdArraySize)
        ReDim \txtCtrlLogicalDev(nReqdArraySize)
        ReDim \cntCtrlPhysDev(nReqdArraySize)
        ReDim \txtCtrlPhysDevInfo(nReqdArraySize)
        ReDim \chkCtrlActive(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblCtrlDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblCtrlDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblCtrlDevNo(nIndex)=scsStringGadget(2,nTop+1,34,19,"S"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblCtrlDevNo"+sNr)
          SetGadgetColor(\lblCtrlDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblCtrlDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \cvsCtrlDevType(nIndex)=scsCanvasGadget(gnNextX+2,nTop,100,21,0,"cvsCtrlDevType"+sNr)
          \cvsCtrlDevTypeText(nIndex) = ""
          \txtCtrlLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtCtrlLogicalDev"+sNr)
          ; physical dev info
          nLeft = gnNextX+4
          If GadgetX(\lnCtrlVertSepInSCA) <> nLeft
            ResizeGadget(\lnCtrlVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntCtrlPhysDevLabels)
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntCtrlPhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntCtrlPhysDev"+sNr)
            nTop = 0
            \txtCtrlPhysDevInfo(nIndex)=scsStringGadget(6,nTop,300,21,"",0,"txtCtrlPhysDevInfo"+sNr)
            setEnabled(\txtCtrlPhysDevInfo(nIndex), #False)
            setTextBoxBackColor(\txtCtrlPhysDevInfo(nIndex))
            nLeft = gnNextX + 12
            \chkCtrlActive(nIndex)=scsCheckBoxGadget2(nLeft,nTop+2,17,17,"",0,"chkCtrlActive"+sNr)
            setOwnEnabled(\chkCtrlActive(nIndex), #False)
            setAllowEditorColors(\cntCtrlPhysDev(nIndex),#False)
            setAllowEditorColors(\chkCtrlActive(nIndex),#False)
            SetGadgetColor(\cntCtrlPhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
            setOwnColor(\chkCtrlActive(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
          WEP_setCtrlDevTypeText(nIndex)
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_CTRL_SEND)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPCueCtrlDevs()
  PROCNAMEC()
  ; creates new cue control devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaCueDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxCueCtrlLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblCueDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblCueDevNo(nReqdArraySize)
        ReDim \cboCueDevType(nReqdArraySize)
        ReDim \cntCuePhysDev(nReqdArraySize)
        ; debugMsg0(sProcName, "ReDim \cntCuePhysDev(" + nReqdArraySize + ")")
        ReDim \txtCuePhysDevInfo(nReqdArraySize)
        ReDim \chkCueActive(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblCueDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblCueDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblCueDevNo(nIndex)=scsStringGadget(12,nTop+1,32,19,"C"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblCueDevNo"+sNr)
          SetGadgetColor(\lblCueDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblCueDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          \cboCueDevType(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,100,21,0,"cboCueDevType"+sNr)
          ; physical dev info
          nLeft = gnNextX+40
          If GadgetX(\lnCueVertSepInSCA) <> nLeft
            ResizeGadget(\lnCueVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntCuePhysDevLabels) ; use this if scrollbar is NOT visible
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntCuePhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntCuePhysDev"+sNr)
            nTop = 0
            \txtCuePhysDevInfo(nIndex)=scsStringGadget(7,nTop,300,21,"",0,"txtCuePhysDevInfo"+sNr)
            setEnabled(\txtCuePhysDevInfo(nIndex), #False)
            setTextBoxBackColor(\txtCuePhysDevInfo(nIndex))
            \chkCueActive(nIndex)=scsCheckBoxGadget2(gnNextX+12,nTop+2,17,17,"",0,"chkCueActive"+sNr)
            setOwnEnabled(\chkCueActive(nIndex), #False)
            setAllowEditorColors(\cntCuePhysDev(nIndex),#False)
            setAllowEditorColors(\chkCueActive(nIndex),#False)
            SetGadgetColor(\cntCuePhysDev(nIndex),#PB_Gadget_BackColor, \nPhysBackColor)
            ; debugMsg0(sProcName, "SetGadgetColor(\cntCuePhysDev(" + nIndex + "),#PB_Gadget_BackColor,\nPhysBackColor)")
            setOwnColor(\chkCueActive(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_CUE_CTRL)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPLiveInputDevs()
  PROCNAMEC()
  ; creates new live input devices
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  gnCurrentEditorComponent = #WEP
  
  debugMsg(sProcName, "grProdForDevChgs\nMaxLiveInputLogicalDevDisplay=" + grProdForDevChgs\nMaxLiveInputLogicalDevDisplay)
  
  With WEP
    scsOpenGadgetList(\scaLiveDevs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxLiveInputLogicalDevDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblLiveDevNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblLiveDevNo(nReqdArraySize)
        ReDim \txtLiveLogicalDev(nReqdArraySize)
        ReDim \cboNumInputChans(nReqdArraySize)
        ReDim \cntLivePhysDev(nReqdArraySize)
        ReDim \cboLivePhysicalDev(nReqdArraySize)
        ReDim \cboInputRange(nReqdArraySize)
        ReDim \sldInputGain(nReqdArraySize)
        ReDim \txtInputGainDB(nReqdArraySize)
        ReDim \chkLiveActive(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblLiveDevNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblLiveDevNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblLiveDevNo(nIndex)=scsStringGadget(2,nTop+1,32,19,"L"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblLiveDevNo"+sNr)
          SetGadgetColor(\lblLiveDevNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblLiveDevNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black)
          ; logical dev info
          \txtLiveLogicalDev(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtLiveLogicalDev"+sNr)
          \cboNumInputChans(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,73,21,0,"cboNumInputChans"+sNr)
          ; physical dev info
          nLeft = gnNextX+6
          If GadgetX(\lnLiveVertSepInSCA) <> nLeft
            ResizeGadget(\lnLiveVertSepInSCA, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
          nWidth = GadgetWidth(\cntLivePhysDevLabels)
          nLeft + 1 ; adjust left so that vertical line on the left will be visible
          \cntLivePhysDev(nIndex)=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntLivePhysDev"+sNr)
            nTop = 0
            \cboLivePhysicalDev(nIndex)=scsComboBoxGadget(7,nTop,160,21,0,"cboLivePhysicalDev"+sNr)
            \cboInputRange(nIndex)=scsComboBoxGadget(gnNextX+2,nTop,60,21,0,"cboInputRange"+sNr)
            \sldInputGain(nIndex)=SLD_New("PR_InputGain"+Str(nIndex+1),\cntLivePhysDev(nIndex),0,gnNextX+2,nTop,94,21,#SCS_ST_HLEVELNODB,0,1000)
            \txtInputGainDB(nIndex)=scsStringGadget(gnNextX+2,nTop,34,21,"",0,"txtInputGainDB"+sNr)
            nLeft = gnNextX + 4
            \chkLiveActive(nIndex)=scsCheckBoxGadget2(nLeft,nTop+2,17,17,"",0,"chkLiveActive"+sNr)
            setOwnEnabled(\chkLiveActive(nIndex), #False)
            setAllowEditorColors(\cntLivePhysDev(nIndex),#False)
            setAllowEditorColors(\chkLiveActive(nIndex),#False)
            SetGadgetColor(\cntLivePhysDev(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
            setOwnColor(\chkLiveActive(nIndex),#PB_Gadget_BackColor,\nPhysBackColor)
          scsCloseGadgetList()
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_LIVE_INPUT)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPInputGroups()
  PROCNAMEC()
  ; creates new live input groups
  Protected nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nIndex, nReqdArraySize
  
  debugMsg(sProcName, #SCS_START + ", grProdForDevChgs\nMaxInGrpDisplay=" + grProdForDevChgs\nMaxInGrpDisplay)
  
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaInGrps)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\nMaxInGrpDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\lblInGrpNo())
        ; see also ED_displayOrHideDeviceLine()
        ReDim \lblInGrpNo(nReqdArraySize)
        ReDim \txtInGrpName(nReqdArraySize)
        ReDim \txtInGrpInfo(nReqdArraySize)
      EndIf
      For nIndex = 0 To nReqdArraySize
        If IsGadget(\lblInGrpNo(nIndex)) = #False
          nTop = nIndex * 21
          sNr = "(" + nIndex + ")"
          ; nb using a StringGadget rather than a TextGadget for \lblInGrpNo(nIndex) so we receive an event when the user clicks on the gadget
          \lblInGrpNo(nIndex)=scsStringGadget(2,nTop+1,32,19,"G"+Str(nIndex+1),#PB_String_ReadOnly|#ES_CENTER,"lblInGrpNo"+sNr)
          SetGadgetColor(\lblInGrpNo(nIndex), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\lblInGrpNo(nIndex), #PB_Gadget_FrontColor, #SCS_Black) ; input group info
          \txtInGrpName(nIndex)=scsStringGadget(gnNextX+2,nTop,68,21,"",0,"txtInGrpName"+sNr)
          \txtInGrpInfo(nIndex)=scsStringGadget(gnNextX+8,nTop,400,21,"",#PB_String_ReadOnly,"txtInGrpInfo"+sNr)
          ; nb commented out the following so that tabbing out of \txtInGrpName(nIndex) doesn't go down to the next line but stays on the current item
          ; by setting focus to the readonly field \txtInGrpInfo(nIndex)
          ; setEnabled(\txtInGrpInfo(nIndex), #False)
          ; setTextBoxBackColor(\txtInGrpInfo(nIndex))
        EndIf
      Next nIndex
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_IN_GRP)
  EndWith
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure createWEPInputGroupLiveInputs(nInGrpNo)
  PROCNAMEC()
  ; creates new live input entries for a live input group
  Protected nTop, sNr.s
  Protected nInGrpItemNo, nReqdArraySize, nReqdInnerHeight
  Static nPrevInGrpNo = -1
  
  debugMsg(sProcName, #SCS_START + ", nInGrpNo=" + nInGrpNo)
  
  gnCurrentEditorComponent = #WEP
  
  With WEP
    scsOpenGadgetList(\scaInGrpLiveInputs)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      nReqdArraySize = grProdForDevChgs\aInGrps(nInGrpNo)\nMaxInGrpItemDisplay + 1 ; Added +1 so that part of an extra line can be displayed by ED_displayOrHideDeviceLine()
      If nReqdArraySize > ArraySize(\cboInGrpLiveInput())
        ReDim \cboInGrpLiveInput(nReqdArraySize)
      EndIf
      For nInGrpItemNo = 0 To nReqdArraySize
        If IsGadget(\cboInGrpLiveInput(nInGrpItemNo)) = #False
          nTop = nInGrpItemNo * 21
          sNr = "(" + nInGrpItemNo + ")"
          \cboInGrpLiveInput(nInGrpItemNo)=scsComboBoxGadget(4,nTop,160,21,0,"cboInGrpLiveInput"+sNr)
        Else
          If getVisible(\cboInGrpLiveInput(nInGrpItemNo)) = #False
            setVisible(\cboInGrpLiveInput(nInGrpItemNo), #True)
          EndIf
        EndIf
        If CountGadgetItems(\cboInGrpLiveInput(nInGrpItemNo)) = 0 Or nInGrpNo <> nPrevInGrpNo Or grWEP\bReloadInGrpLiveInputs
          WEP_populateInGrpLiveInputs(nInGrpNo, nInGrpItemNo)
        EndIf
      Next nInGrpItemNo
      nPrevInGrpNo = nInGrpNo
      grWEP\bReloadInGrpLiveInputs = #False
    scsCloseGadgetList()
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_IN_GRP_LIVE_INPUT, nInGrpNo)
  EndWith
  
  gnCurrentEditorComponent = 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Macro setWEPPhysDevLabelsLeftTopAndWidth(nPrevCntGadgetNo)
  nCntGadgetNo = nPrevCntGadgetNo
  nTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
  nLeft = GadgetX(nCntGadgetNo) + 1       ; + 1 and -2 (for width) to match the position and width of \cntDevMap WITHIN it's 'flat' borders
  nWidth = GadgetWidth(nCntGadgetNo) - 2  ; as the corresponding left and right borders will be created separately
EndMacro

Procedure createfmEditProd()
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, nHeight, nGap
  Protected nTop2
  Protected nLblLeft, nLblWidth, nItemLeft, nItemWidth
  Protected nCntLeft, nCntWidth, nCntGadgetNo
  Protected nPanTextWidth, nTiltTextWidth
  Protected sNr.s
  Protected nNextLeft
  Protected nPanelItemWidth, nPanelItemHeight
  Protected nScaCueDevsHeight, nScaLightingDevsHeight
  Protected nScaFixturesLeft, nScaFixturesTop, nScaFixturesWidth, nScaFixturesHeight
  Protected nFixturesInnerWidth, nFixturesInnerHeight
  Protected nInnerWidth, nInnerHeight
  Protected nSettingsTop, nSettingsHeight
  Protected sDefTimeTT.s
  Protected sText.s, nTextWidth
  Protected nScaWidth, nScaInnerWidth, nScaInnerHeight
  Protected nMsgActionWidth, nReceiveMsgWidth, nReplyMsgWidth
  Protected sTextKey.s
  Protected nLastNextXInSca
  Protected nMaxWidth
  Protected sTabDesc.s
  Protected nCSDevTypeIndex
  Protected sChkM2TSkipEarlierCSMsgs.s
  Protected nScaDevsExtraDepth = 6 ; allows for a 'border' area below the last displayed device in a device group
  Protected nDevDetailGap = 4 ; the vertical gap between the device scrollable area and the details for the currently-selected device
  Protected nDevRowHeight = 21; height of each device row
  Protected nLineLeft, nLineWidth
  
  debugMsg(sProcName, #SCS_START)
  
  WEP\nPhysBackColor = #SCS_Phys_BackColor
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WEP
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    With WEP
      \scaProdProperties=scsScrollAreaGadget(0, 0, gnEditorCntRightFixedWidth, GadgetHeight(WED\cntRight), gnEditorScaPropertiesInnerWidth, 610, 30, #PB_ScrollArea_Flat, "scaProdProperties")
        ; heading
        \lblProdProperties=scsTextGadget(0,0,gnEditorScaPropertiesInnerWidth,18," "+Lang("WEP","lblProdProperties"),0,"lblProdProperties")
        scsSetGadgetFont(\lblProdProperties, #SCS_FONT_GEN_BOLD)
        setReverseEditorColors(\lblProdProperties, #True)
        
        nTop = 22
        nHeight = GetGadgetAttribute(\scaProdProperties, #PB_ScrollArea_InnerHeight) - nTop - 4
        \pnlProd=scsPanelGadget(2,nTop,gnEditorScaPropertiesInnerWidth-2,nHeight,"pnlProd")
          
          ; =================
          ;- PROD General tab
          ; =================
          WMI_displayInfoMsg2(Lang("WEP","tbsGeneral"))
          sTabDesc = "\pnlProd tab: general"
          debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
          ;{
          addGadgetItemWithData(\pnlProd, Lang("WEP","tbsGeneral"), #SCS_PROD_TAB_GENERAL)
          
          nPanelItemWidth = GetGadgetAttribute(\pnlProd, #PB_Panel_ItemWidth)      ; requires at least one item
          nPanelItemHeight = GetGadgetAttribute(\pnlProd, #PB_Panel_ItemHeight)
          sDefTimeTT = Lang("WEP", "DefTimeTT")
          
          \cntTabGeneral=scsContainerGadget(0,0,nPanelItemWidth,nPanelItemHeight,0,"cntTabGeneral")
            
            nLineWidth = GadgetWidth(\cntTabGeneral) * 0.95 ; lines to be 95% of container width
            nLineLeft = (GadgetWidth(\cntTabGeneral) - nLineWidth) / 2
            
            ; name of production
            nTop = 12
            \lblTitle=scsTextGadget(11,nTop+4,131,17,Lang("WEP","lblTitle"), #PB_Text_Right, "lblTitle")
            scsSetGadgetFont(\lblTitle, #SCS_FONT_GEN_BOLD)
            \txtTitle=scsStringGadget(148,nTop,400,20,"",0,"txtTitle")
            scsSetGadgetFont(\txtTitle, #SCS_FONT_GEN_BOLD10)
            
            ; name and description of template (mutually exclusive with title)
            ; NB grProd\bTemplate = #True if the user is editing a template, but we don't know that yet and createfmEditProd() is only called once per session if required at all.
            \lblTmName=scsTextGadget(11,nTop+4,131,17,Lang("WEP","lblTmName"), #PB_Text_Right, "lblTmName")
            scsSetGadgetFont(\lblTmName, #SCS_FONT_GEN_BOLD)
            \txtTmName=scsStringGadget(148,nTop,400,20,"",0,"txtTmName")
            scsSetGadgetFont(\txtTmName, #SCS_FONT_GEN_BOLD10)
            nTop + 24
            \lblTmDesc=scsTextGadget(11,nTop+4,131,17,Lang("WEP","lblTmDesc"), #PB_Text_Right, "lblTmDesc")
            \edgTmDesc=scsStringGadget(148,nTop,400,35,"",#PB_Editor_WordWrap,"edgTmDesc")
            
            nTop + 24
            \cntGenProps=scsContainerGadget(0,nTop,GadgetWidth(\cntTabGeneral),GadgetHeight(\cntTabGeneral)-nTop,#PB_Container_BorderLess,"cntGenProps")
              ; \cntGenProps allows us to position the remaining 'general' properties up or down depending on whether or not this is a template
              nTop = 0
              sText = Lang("WEP","lblCueLabelIncrement")
              nWidth = GetTextWidth(sText)
              \lblCueLabelIncrement=scsTextGadget(148,nTop+4,nWidth,17,Lang("WEP","lblCueLabelIncrement"),#PB_Text_Right,"lblCueLabelIncrement")
              \cboCueLabelIncrement=scsComboBoxGadget(gnNextX+7,nTop,50,21,0,"cboCueLabelIncrement")
              scsToolTip(\cboCueLabelIncrement,Lang("WEP","cboCueLabelIncrementTT"))
              nTop + 25
              \chkLabelsUCase=scsCheckBoxGadget2(148,nTop,430,17,Lang("WEP","chkLabelsUCase"),0,"chkLabelsUCase")
              scsToolTip(\chkLabelsUCase,Lang("WEP","chkLabelsUCaseTT"))
              nTop + 21
              \chkLabelsFrozen=scsCheckBoxGadget2(148,nTop,430,17,Lang("WEP","chkLabelsFrozen"),0,"chkLabelsFrozen")
              scsToolTip(\chkLabelsFrozen,Lang("WEP","chkLabelsFrozenTT"))
              nTop + 21
              \chkEnableMidiCue=scsCheckBoxGadget2(148,nTop,430,17,Lang("WEP","chkEnableMidiCue"),0,"chkEnableMidiCue")
              scsToolTip(\chkEnableMidiCue,Lang("WEP","chkEnableMidiCueTT"))
              
              If grLicInfo\nLicLevel >= #SCS_LIC_PRO
                nTop + 24
                \lblMemoDispOptForPrim=scsTextGadget(148,nTop,360,15,Lang("WEP","lblMemoDispOptForPrim")+" :-",0,"lblMemoDispOptForPrim")
                setGadgetWidth(\lblMemoDispOptForPrim)
                nTop + 20
                \cboMemoDispOptForPrim=scsComboBoxGadget(148,nTop,120,21,0,"cboMemoDispOptForPrim")
                addGadgetItemWithData(\cboMemoDispOptForPrim,Lang("WEP","MemoPopup"),#SCS_MEMO_DISP_PRIM_POPUP)
                addGadgetItemWithData(\cboMemoDispOptForPrim,Lang("WEP","MemoShareCueList"),#SCS_MEMO_DISP_PRIM_SHARE_CUE_LIST)
                addGadgetItemWithData(\cboMemoDispOptForPrim,Lang("WEP","MemoShareMain"),#SCS_MEMO_DISP_PRIM_SHARE_MAIN)
                setComboBoxWidth(\cboMemoDispOptForPrim)
              EndIf
              
              nLblWidth = 330
              nTop + 21 + 8
              \lnDefCueTypeSeperator[0]=scsLineGadget(nLineLeft,nTop,nLineWidth,1,#SCS_Light_Grey,0,"lnDefCueTypeSeperator[0]")
              nTop + 1 + 6
              \lblDefFadeInTime=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeInTime"),#PB_Text_Right,"lblDefFadeInTime")
              \txtDefFadeInTime=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeInTime")
              setValidChars(\txtDefFadeInTime, "0123456789.:")
              scsToolTip(\txtDefFadeInTime, sDefTimeTT)
              nTop + 21
              \lblDefFadeOutTime=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeOutTime"),#PB_Text_Right,"lblDefFadeOutTime")
              \txtDefFadeOutTime=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeOutTime")
              setValidChars(\txtDefFadeOutTime, "0123456789.:")
              scsToolTip(\txtDefFadeOutTime, sDefTimeTT)
              nTop + 21
              \lblDefLoopXFadeTime=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefLoopXFadeTime"),#PB_Text_Right,"lblDefLoopXFadeTime")
              \txtDefLoopXFadeTime=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefLoopXFadeTime")
              setValidChars(\txtDefLoopXFadeTime, "0123456789.:")
              scsToolTip(\txtDefLoopXFadeTime, sDefTimeTT)
              
              If grLicInfo\nLicLevel >= #SCS_LIC_STD
                nTop + 21 + 6
                \lnDefCueTypeSeperator[1]=scsLineGadget(nLineLeft,nTop,nLineWidth,1,#SCS_Light_Grey,0,"lnDefCueTypeSeperator[1]")
                nTop + 1 + 6
                ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
                \lblDefFadeInTimeA=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeInTimeA"),#PB_Text_Right,"lblDefFadeInTimeA")
                \txtDefFadeInTimeA=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeInTimeA")
                setValidChars(\txtDefFadeInTimeA, "0123456789.:")
                scsToolTip(\txtDefFadeInTimeA, sDefTimeTT)
                nTop + 21
                \lblDefFadeOutTimeA=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeOutTimeA"),#PB_Text_Right,"lblDefFadeOutTimeA")
                \txtDefFadeOutTimeA=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeOutTimeA")
                setValidChars(\txtDefFadeOutTimeA, "0123456789.:")
                scsToolTip(\txtDefFadeOutTimeA, sDefTimeTT)
                nTop + 21
                \lblDefDisplayTimeA=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefDisplayTimeA"),#PB_Text_Right,"lblDefDisplayTimeA")
                \txtDefDisplayTimeA=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefDisplayTimeA")
                setValidChars(\txtDefDisplayTimeA, "0123456789.:")
                scsToolTip(\txtDefDisplayTimeA, sDefTimeTT)
                nTop + 25
                nLeft = GadgetX(\txtDefDisplayTimeA)
                \chkDefRepeatA=scsCheckBoxGadget2(nLeft,nTop,430,17,Lang("WEP","chkDefRepeatA"),0,"chkDefRepeatA")
                nTop + 21
                \chkDefPauseAtEndA=scsCheckBoxGadget2(nLeft,nTop,430,17,Lang("WEP","chkDefPauseAtEndA"),0,"chkDefPauseAtEndA")
                nTop + 21
                ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
                \lblDefOutputScreen=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefOutputScreen"),#PB_Text_Right,"lblDefOutputScreen")
                \cboDefOutputScreen=scsComboBoxGadget(gnNextX+7,nTop,50,21,0,"cboDefOutputScreen")
              EndIf
              
              nTop + 21 + 6
              \lnDefCueTypeSeperator[2]=scsLineGadget(nLineLeft,nTop,nLineWidth,1,#SCS_Light_Grey,0,"lnDefCueTypeSeperator[2]")
              nTop + 1 + 6
              \lblDefSFRTimeOverride=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefSFRTimeOverride"),#PB_Text_Right,"lblDefSFRTimeOverride")
              \txtDefSFRTimeOverride=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefSFRTimeOverride")
              setValidChars(\txtDefSFRTimeOverride, "0123456789.:")
              scsToolTip(\txtDefSFRTimeOverride, sDefTimeTT)
              
              If grLicInfo\nMaxLiveDevPerProd > 0
                nTop + 21 + 6
                \lnDefCueTypeSeperator[3]=scsLineGadget(nLineLeft,nTop,nLineWidth,1,#SCS_Light_Grey,0,"lnDefCueTypeSeperator[3]")
                nTop + 1 + 6
                \lblDefFadeInTimeI=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeInTimeI"),#PB_Text_Right,"lblDefFadeInTimeI")
                \txtDefFadeInTimeI=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeInTimeI")
                setValidChars(\txtDefFadeInTimeI, "0123456789.:")
                scsToolTip(\txtDefFadeInTimeI, sDefTimeTT)
                nTop + 21
                \lblDefFadeOutTimeI=scsTextGadget(0,nTop+4,nLblWidth,15,Lang("WEP","lblDefFadeOutTimeI"),#PB_Text_Right,"lblDefFadeOutTimeI")
                \txtDefFadeOutTimeI=scsStringGadget(gnNextX+7,nTop,70,21,"",0,"txtDefFadeOutTimeI")
                setValidChars(\txtDefFadeOutTimeI, "0123456789.:")
                scsToolTip(\txtDefFadeOutTimeI, sDefTimeTT)
              EndIf
              
              ; template info (displayed if editing a template)
              ; NB grProd\bTemplate = #True if the user is editing a template, but we don't know that yet and createfmEditProd() is only called once per session if required at all.
              nTop + 42
              nWidth = 500
              nLeft = (GadgetWidth(\pnlProd) - nWidth) / 2
              \cntTemplate=scsContainerGadget(nLeft,nTop,nWidth,25,#PB_Container_Flat,"cntTemplate")
                setVisible(\cntTemplate,#False)
                SetGadgetColor(\cntTemplate, #PB_Gadget_BackColor, RGB(0,102,204))
                setAllowEditorColors(\cntTemplate, #False)
                \lblTemplateInfo=scsTextGadget(0,3,nWidth,17,"",#PB_Text_Center,"lblTemplateInfo")
                SetGadgetColors(\lblTemplateInfo, #SCS_White, RGB(0,102,204))
                scsSetGadgetFont(\lblTemplateInfo, #SCS_FONT_WMN_ITALIC)
                SetGadgetColor(\lblTemplateInfo, #PB_Gadget_BackColor, GetGadgetColor(\cntTemplate, #PB_Gadget_BackColor))
                setAllowEditorColors(\lblTemplateInfo, #False)
              scsCloseGadgetList() ; cntTemplate
              
            scsCloseGadgetList()  ; \cntGenProps
          scsCloseGadgetList()
          ;}
          grWEP\nLoadProgress + 1
          WMI_setProgress(grWEP\nLoadProgress)
          
          ; =================
          ;- PROD Devices tab
          ; =================
          debugMsg(sProcName, "\pnlProd tab: devices, gnContainerLevel=" + gnContainerLevel)
          addGadgetItemWithData(\pnlProd, Trim(LangPars("WEP","tbsDevices", "")), #SCS_PROD_TAB_DEVS)
          \cntDevices=scsContainerGadget(0,0,nPanelItemWidth,nPanelItemHeight,0,"cntDevices")
            
            \pnlDevs=scsPanelGadget(0,0,nPanelItemWidth,nPanelItemHeight-(gnBtnHeight*2)-2,"pnlDevs") ; NOTE: container for the tabs 'Audio Output, 'Video Audio', 'Video Capture', etc
              ; variables used by all or most devices tabs (audio output, video audio, video capture, etc)
              addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "AudioOutput"), #SCS_PROD_TAB_AUD_DEVS) ; creates devices tab 'Audio Output' (created here as following commands require at least on item)
              \nDevPanelItemWidth = GetGadgetAttribute(\pnlDevs, #PB_Panel_ItemWidth) ; requires at least one item
              \nDevPanelItemHeight = GetGadgetAttribute(\pnlDevs, #PB_Panel_ItemHeight)
              debugMsg(sProcName, "\nDevPanelItemWidth=" + \nDevPanelItemWidth + ", \nDevPanelItemHeight=" + \nDevPanelItemHeight)
              
              ; The SideBar contains the up and down arrow buttons for changing the order of the devices, and the + and - buttons for adding or removing devices.
              \nSideBarLeft = 1
              \nSideBarWidth = 28
              
              ; 'Sca' = scroll area gadget, which includes everything from the device number (eg A1, A2, etc) across to the final column, eg the 'Active' checkbox.
              ; Note that columns to the left of 'Physical Device' are saved in the cue file (the .scs11 file),
              ; whereas 'Physical Device' and following columns are stored with the device map, although 'Active?' is not saved anywhere as it is run-time specific.
              \nScaDevsLeft = \nSideBarLeft + \nSideBarWidth
              \nScaDevsWidth = \nDevPanelItemWidth - \nScaDevsLeft - 2
              \nScaDevsHeight = (8 * nDevRowHeight) + nScaDevsExtraDepth ; set for 8 rows plus a lower border area
              ; end of variables used by all or most devices tabs
              
              ; ==============================================
              ;- PROD Audio Output Devices tab within \pnlDevs
              ; ==============================================
              ;{
              WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_AUDIO_OUTPUT])
              sTabDesc = "\pnlDevs tab: devices - audio output"
              debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
              ;{
              ; The following addGadgetItemWithData() moved up to 'variables used by all devices tabs' as at least one tab must be created before panel width and height can be returned
              ; addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "AudioOutput"), #SCS_PROD_TAB_AUD_DEVS) ; creates devices tab 'Audio Output'
              
              \nDevDetailLeft = 0
              \nDevDetailWidth = \nDevPanelItemWidth - \nDevDetailLeft
              
              \cntTabAudDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,#PB_Container_BorderLess,"cntTabAudDevs")
                
                \lblAudDevsReqd=scsTextGadget(17,24,189,49,Lang("WEP","lblDevsReqd"),#PB_Text_Right,"lblAudDevsReqd")
                scsSetGadgetFont(\lblAudDevsReqd, #SCS_FONT_GEN_BOLDUL)
                
                nTop = 73
                \lblAudDevName=scsTextGadget(53,nTop,88,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblAudDevName")
                \lblNumChans=scsTextGadget(141,nTop,61,26,Lang("WEP","lblNumChans"),#PB_Text_Center,"lblNumChans")
                
                createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_AUD_DEVS, 214)
                createWEPAudioDriverInfo(#SCS_PROD_TAB_INDEX_AUD_DEVS)
                setWEPPhysDevLabelsLeftTopAndWidth(\cntAudioDriver[#SCS_PROD_TAB_INDEX_AUD_DEVS])
                \cntAudPhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntAudPhysDevLabels")
                  nTop = 2
                  If gbDelayTimeAvailable
                    \lblAudPhysical=scsTextGadget(9,nTop,120,17,Lang("WEP","lblPhysical"),0,"lblAudPhysical")
                    \lblOutputRange=scsTextGadget(gnNextX+2,nTop,51,17,Lang("WEP","lblOutputRange"),0,"lblOutputRange")
                    \lblDelayTime=scsTextGadget(gnNextX+2,nTop,51,17,Lang("WEP","lblDelayTime"),#PB_Text_Center,"lblDelayTime")
                    \lblGain=scsTextGadget(gnNextX+2,nTop,80,17,Lang("WEP","lblGain"),#PB_Text_Center,"lblGain")
                    \lblGainDB=scsTextGadget(gnNextX+14,nTop,17,17,"dB",#PB_Text_Center,"lblGainDB")
                  Else
                    \lblAudPhysical=scsTextGadget(9,nTop,160,17,Lang("WEP","lblPhysical"),0,"lblAudPhysical")
                    \lblOutputRange=scsTextGadget(gnNextX+2,nTop,51,17,Lang("WEP","lblOutputRange"),0,"lblOutputRange")
                    \lblGain=scsTextGadget(gnNextX+2,nTop,94,17,Lang("WEP","lblGain"),#PB_Text_Center,"lblGain")
                    \lblGainDB=scsTextGadget(gnNextX+14,nTop,17,17,"dB",#PB_Text_Center,"lblGainDB")
                  EndIf
                  \lblAudActive=scsTextGadget(gnNextX+8,nTop,106,17,Lang("WEP","lblActive"),0,"lblAudActive")
                  setGadgetWidth(\lblAudActive,-1,#True)
                  setAllowEditorColors(\cntAudPhysDevLabels,#False)
                  setAllowEditorColors(\lblAudPhysical,#False)
                  setAllowEditorColors(\lblOutputRange,#False)
                  setAllowEditorColors(\lblGain,#False)
                  setAllowEditorColors(\lblGainDB,#False)
                  setAllowEditorColors(\lblAudActive,#False)
                  SetGadgetColor(\cntAudPhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                  SetGadgetColor(\lblAudPhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                  SetGadgetColor(\lblOutputRange,#PB_Gadget_BackColor,\nPhysBackColor)
                  SetGadgetColor(\lblGain,#PB_Gadget_BackColor,\nPhysBackColor)
                  SetGadgetColor(\lblGainDB,#PB_Gadget_BackColor,\nPhysBackColor)
                  SetGadgetColor(\lblAudActive,#PB_Gadget_BackColor,\nPhysBackColor)
                  If gbDelayTimeAvailable
                    setAllowEditorColors(\lblDelayTime,#False)
                    SetGadgetColor(\lblDelayTime,#PB_Gadget_BackColor,\nPhysBackColor)
                  EndIf
                scsCloseGadgetList()
                ; create vertical lines to the left and right of \cntAudPhysDevLabels (the container gadget just created above)
                nCntGadgetNo = \cntAudPhysDevLabels
                \lnAudVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnAudVertSep")
                \lnAudVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnAudVertRight1")
                \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                
                ; device sidebar
                \cntAudDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntAudDevSideBar")
                  \imgAudButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgAudButtonTBS[0]")
                  \imgAudButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgAudButtonTBS[1]")
                  \imgAudButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgAudButtonTBS[2]")
                  \imgAudButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgAudButtonTBS[3]")
                scsCloseGadgetList() ; cntDevSideBar
                If grLicInfo\nMaxAudDevPerProd < 1
                  ; hide sidebar of only one device is allowed with this license type (eg SCS Lite)
                  setVisible(\cntAudDevSideBar, #False)
                EndIf
                
                ; devices
                \nDevInnerHeight = (grLicInfo\nMaxAudDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                \scaAudioDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaAudioDevs")
                  \nVertSepLeft = 0
                  \lnAudVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnAudVertSepInSCA") ; line to the left of the physical device combobox
                  \lnAudVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnAudVertRightInSCA") ; line on the far right (after the active checkbox)
                scsCloseGadgetList()
                
                ;/
                ; audio dev detail
                ;/
                \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                \pnlAudDevDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlAudDevDetail")
                  debugMsg(sProcName, "pnlAudDevDetail start")
                  scsSetGadgetFont(\pnlAudDevDetail,#SCS_FONT_GEN_BOLD)
                  
                  ; default settings
                  nLeft = 0
                  nTop = 0
                  AddGadgetItem(\pnlAudDevDetail, -1, "")
                  nWidth = GetGadgetAttribute(\pnlAudDevDetail, #PB_Panel_ItemWidth)
                  nHeight = GetGadgetAttribute(\pnlAudDevDetail, #PB_Panel_ItemHeight)
                  \cntAudDfltSettings=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntAudDfltSettings")
                    nTop = 16
                    \chkAutoInclude=scsCheckBoxGadget2(20,nTop,-1,17,Lang("WEP","chkAutoInclude"),0,"chkAutoInclude")
                    scsToolTip(\chkAutoInclude, Lang("WEP", "chkAutoIncludeTT"))
                    If grLicInfo\bLTCAvailable
                      nTop + 17
                      \chkForLTC=scsCheckBoxGadget2(20,nTop,-1,17,Lang("WEP","chkForLTC"),0,"chkForLTC")
                      scsToolTip(\chkForLTC,Lang("WEP","chkForLTCTT"))
                    EndIf
                    ; default level and pan settings for new cues
                    nTop + 40
                    \lblAudDefaults=scsTextGadget(20,nTop,400,15,Lang("WEP","lblAudDefaults"),0,"lblAudDefaults")
                    ; scsSetGadgetFont(\lblAudDefaults, #SCS_FONT_GEN_ITALIC)
                    nTop + 17
                    \lblDfltDevTrim=scsTextGadget(20,nTop,43,15,Lang("Common","Trim"), #PB_Text_Center,"lblDfltDevTrim")
                    \lblDfltDevLevel=scsTextGadget(gnNextX+2,nTop,130,15,Lang("Common","Level"), #PB_Text_Center,"lblDfltDevLevel")
                    \lblDfltDevDB=scsTextGadget(gnNextX+2,nTop,40,15,"dB", #PB_Text_Center,"lblDfltDevDB")
                    \lblDfltDevPan=scsTextGadget(gnNextX+2,nTop,90,15,Lang("Common","Pan"), #PB_Text_Center,"lblDfltDevPan")
                    ; default levels and pan
                    nTop + 15
                    \cboDfltDevTrim=scsComboBoxGadget(20,nTop,43,21,0,"cboDfltDevTrim")
                    \nLevelLeft = gnNextX+2
                    \sldDfltDevLevel=SLD_New("PR_DfltDevLevel"+Str(n+1),\cntAudDfltSettings,0,\nLevelLeft,nTop,130,21,#SCS_ST_HLEVELNODB,0,1000)
                    \txtDfltDevDBLevel=scsStringGadget(gnNextX+2,nTop,40,21,"",0,"txtProdDBLevel")
                    \sldDfltDevPan=SLD_New("PR_DfltDevPan"+Str(n+1),\cntAudDfltSettings,0,gnNextX+2,nTop,90,21,#SCS_ST_PANNOLR,0,1000)
                    \btnDfltDevCenter=scsButtonGadget(gnNextX+2,nTop,46,21,Lang("btns","Center"),0,"btnDfltDevCenter")
                    scsToolTip(\btnDfltDevCenter,Lang("btns","CenterTT"))
                    \txtDfltDevPan=scsStringGadget(gnNextX+2,nTop,40,21,"",#PB_String_Numeric,"txtDfltDevPan")
                  scsCloseGadgetList()
                  
                  ; test tone gadgets
                  nLeft = 0
                  nTop = 0
                  AddGadgetItem(\pnlAudDevDetail, -1, "")
                  grWEP\nTestToneTabNo = CountGadgetItems(\pnlAudDevDetail) - 1
                  nWidth = GetGadgetAttribute(\pnlAudDevDetail, #PB_Panel_ItemWidth)
                  nHeight = GetGadgetAttribute(\pnlAudDevDetail, #PB_Panel_ItemHeight)
                  \cntTestTone=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntTestTone")
                    nTop = 12
                    \lblTestSound=scsTextGadget(2,nTop+gnLblVOffsetC,100,17,Lang("WEP","lblTestSound"), #PB_Text_Right,"lblTestSound")
                    \cboTestSound=scsComboBoxGadget(gnNextX+7,nTop,130,21,0,"cboTestSound")
                    nTop + 28
                    \lblTestToneLevel=scsTextGadget(2,nTop+4,100,17,Lang("WEP","lblTestToneLevel"), #PB_Text_Right,"lblTestToneLevel")
                    \sldTestToneLevel=SLD_New("PR_TestToneLevel",\cntTestTone,0,gnNextX+7,nTop,130,21,#SCS_ST_HLEVELNODB,0,1000)
                    \lblTestTonePan=scsTextGadget(gnNextX+12,nTop+gnLblVOffsetC,60,17,grText\sTextPan,0,"lblTestTonePan")
                    setGadgetWidth(\lblTestTonePan, -1, #True)
                    \sldTestTonePan=SLD_New("PR_TestTonePan",\cntTestTone,0,gnNextX+gnGap,nTop,105,21,#SCS_ST_PAN,0,1000)
                    \btnTestToneCenter=scsButtonGadget(gnNextX,nTop,46,21,Lang("Btns","Center"),0,"btnTestToneCenter")
                    scsToolTip(\btnTestToneCenter,Lang("Btns","CenterTT"))
                    nTop + 34
                    nLeft = SLD_gadgetX(\sldTestToneLevel) + (SLD_gadgetWidth(\sldTestToneLevel) >> 1) ; = midpoint of \sldTestToneLevel
                    nLeft - (129 + (gnGap >> 1) ) ; minus half total width of the two buttons and gap
                    \btnTestToneShort=scsButtonGadget(nLeft,nTop,129,23,Trim(LangPars("WEP","btnTestToneShort", "")),0,"btnTestToneShort")
                    nLeft = gnNextX+gnGap
                    \btnTestToneCancel=scsButtonGadget(nLeft,nTop,129,23,Trim(LangPars("WEP","btnTestToneCancel", "")),0,"btnTestToneCancel")
                    setVisible(\btnTestToneCancel, #False)
                    \btnTestToneContinuous=scsButtonGadget(nLeft,nTop,129,23,Trim(LangPars("WEP","btnTestToneCont", "")),0,"btnTestToneContinuous")
                    nTop + 25
                    \lblTestToneConfirm=scsTextGadget(20,nTop,310,17,"",0,"lblTestToneConfirm")
                    scsSetGadgetFont(\lblTestToneConfirm, #SCS_FONT_GEN_BOLD)
                  scsCloseGadgetList()
                  
                  debugMsg(sProcName, "pnlAudDevDetail end")
                scsCloseGadgetList()
                
              scsCloseGadgetList()
              ;}
              grWEP\nLoadProgress + 1
              WMI_setProgress(grWEP\nLoadProgress)
              ;}
              
              ; =============================================
              ;- PROD Video Audio Devices tab within \pnlDevs
              ; =============================================
              ;{
              If grLicInfo\nMaxVidAudDevPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_VIDEO_AUDIO])
                sTabDesc = "\pnlDevs tab: devices - video audio"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "VideoAudio"), #SCS_PROD_TAB_VIDEO_AUD_DEVS)
                
                \cntTabVidAudDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabVidAudDevs")
                  \lblVidAudDevsReqd=scsTextGadget(23,20,108,49,Lang("WEP","lblDevsReqd"),#PB_Text_Center,"lblVidAudDevsReqd")
                  scsSetGadgetFont(\lblVidAudDevsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  nTop = 51
                  \lblVidAudDevName=scsTextGadget(53,nTop,88,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblVidAudDevName")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS, 139)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS])
                  \cntVidAudPhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntVidAudPhysDevLabels")
                    nTop = 2
                    \lblVidAudPhysical=scsTextGadget(8,nTop,171,17,Lang("WEP","lblPhysical"),0,"lblVidAudPhysical")
                    \lblVidAudGain=scsTextGadget(gnNextX+2,nTop,94,17,Lang("WEP","lblGain"),#PB_Text_Center,"lblVidAudGain")
                    \lblVidAudGainDB=scsTextGadget(gnNextX+14,nTop,17,17,"dB",#PB_Text_Center,"lblVidAudGainDB")
                    setAllowEditorColors(\cntVidAudPhysDevLabels,#False)
                    setAllowEditorColors(\lblVidAudPhysical,#False)
                    setAllowEditorColors(\lblVidAudGain,#False)
                    setAllowEditorColors(\lblVidAudGainDB,#False)
                    SetGadgetColor(\cntVidAudPhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblVidAudPhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblVidAudGain,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblVidAudGainDB,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntVidAudPhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntVidAudPhysDevLabels
                  \lnVidAudVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnVidAudVertSep")
                  \lnVidAudVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnVidAudVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                  
                  ; video audio device sidebar
                  \cntVidAudDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntVidAudDevSideBar")
                    \imgVidAudButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgVidAudButtonTBS[0]")
                    \imgVidAudButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgVidAudButtonTBS[1]")
                    \imgVidAudButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgVidAudButtonTBS[2]")
                    \imgVidAudButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgVidAudButtonTBS[3]")
                  scsCloseGadgetList() ; cntDevSideBar
                  If grLicInfo\nMaxVidAudDevPerProd < 1
                    ; hide sidebar of only one device is allowed with this license type (eg SCS Lite)
                    setVisible(\cntVidAudDevSideBar, #False)
                  EndIf
                  
                  ; video audio devices
                  \nDevInnerHeight = (grLicInfo\nMaxVidAudDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaVidAudDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaVidAudDevs")
                    \nVertSepLeft = 0
                    \lnVidAudVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnVidAudVertSepInSCA") ; line to the left of the physical device combobox
                    \lnVidAudVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnVidAudVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  ; video audio dev detail
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \pnlVidAudDevDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlVidAudDevDetail")
                    scsSetGadgetFont(\pnlVidAudDevDetail,#SCS_FONT_GEN_BOLD)
                    
                    ; default settings
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlVidAudDevDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlVidAudDevDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlVidAudDevDetail, #PB_Panel_ItemHeight)
                    \cntVidAudDfltSettings=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntVidAudDfltSettings")
                      nTop = 16
                      \chkVidAudAutoInclude=scsCheckBoxGadget2(20,nTop,-1,17,Lang("WEP","chkAutoInclude"),0,"chkVidAudAutoInclude")
                      scsToolTip(\chkVidAudAutoInclude, Lang("WEP", "chkAutoIncludeTT"))
                      ; default level and pan settings for new cues
                      nTop + 40
                      \lblVidAudDefaults=scsTextGadget(20,nTop,400,15,Lang("WEP","lblAudDefaults"),0,"lblVidAudDefaults")
                      nTop + 17
                      \lblDfltVidAudTrim=scsTextGadget(20,nTop,43,15,Lang("Common","Trim"), #PB_Text_Center,"lblDfltVidAudTrim")
                      \lblDfltVidAudLevel=scsTextGadget(gnNextX+2,nTop,130,15,Lang("Common","Level"), #PB_Text_Center,"lblDfltVidAudLevel")
                      \lblDfltVidAudDB=scsTextGadget(gnNextX+2,nTop,40,15,"dB", #PB_Text_Center,"lblDfltVidAudDB")
                      \lblDfltVidAudPan=scsTextGadget(gnNextX+2,nTop,90,15,Lang("Common","Pan"), #PB_Text_Center,"lblDfltVidAudPan")
                      ; default levels and pan
                      nTop + 15
                      \cboDfltVidAudTrim=scsComboBoxGadget(20,nTop,43,21,0,"cboDfltVidAudTrim")
                      \nLevelLeft = gnNextX+2
                      \sldDfltVidAudLevel=SLD_New("PR_DfltVidAudLevel"+Str(n+1),\cntVidAudDfltSettings,0,\nLevelLeft,nTop,130,21,#SCS_ST_HLEVELNODB,0,1000)
                      \txtDfltVidAudDBLevel=scsStringGadget(gnNextX+2,nTop,40,21,"",0,"txtProdDBLevel")
                      \sldDfltVidAudPan=SLD_New("PR_DfltVidAudPan"+Str(n+1),\cntVidAudDfltSettings,0,gnNextX+2,nTop,90,21,#SCS_ST_PANNOLR,0,1000)
                      \btnDfltVidAudCenter=scsButtonGadget(gnNextX+2,nTop,46,21,Lang("btns","Center"),0,"btnDfltVidAudCenter")
                      scsToolTip(\btnDfltVidAudCenter,Lang("btns","CenterTT"))
                      \txtDfltVidAudPan=scsStringGadget(gnNextX+2,nTop,40,21,"",#PB_String_Numeric,"txtDfltVidAudPan")
                      CompilerIf #c_allow_video_audio_routed_to_audio_device
                        nTop + 36
                        \lblVidAudRouteToAudLogicalDev=scsTextGadget(20,nTop+gnLblVOffsetC,100,15,"Route video audio to Audio Device",0,"lblVidAudRouteToAudLogicalDev")
                        setGadgetWidth(\lblVidAudRouteToAudLogicalDev,-1,#True)
                        \cboVidAudRouteToAudLogicalDev=scsComboBoxGadget(gnNextX,nTop,180,21,0,"cboVidAudRouteToAudLogicalDev")
                      CompilerEndIf
                    scsCloseGadgetList()
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxVidAudDevPerProd >= 0
              ;}
              
              ; ===============================================
              ;- PROD Video Capture Devices tab within \pnlDevs
              ; ===============================================
              ;{
              If grLicInfo\nMaxVidCapDevPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_VIDEO_CAPTURE])
                sTabDesc = "\pnlDevs tab: devices - video capture"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "VideoCapture"), #SCS_PROD_TAB_VIDEO_CAP_DEVS)
                
                \cntTabVidCapDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabVidCapDevs")
                  \lblVidCapDevsReqd=scsTextGadget(23,20,108,49,Lang("WEP","lblDevsReqd"),#PB_Text_Center,"lblVidCapDevsReqd")
                  scsSetGadgetFont(\lblVidCapDevsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  nTop = 51
                  \lblVidCapDevName=scsTextGadget(53,nTop,88,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblVidCapDevName")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS, 139)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS])
                  \cntVidCapPhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntVidCapPhysDevLabels")
                    nTop = 2
                    \lblVidCapPhysical=scsTextGadget(8,nTop,171,17,Lang("WEP","lblPhysical"),0,"lblVidCapPhysical")
                    setAllowEditorColors(\cntVidCapPhysDevLabels,#False)
                    setAllowEditorColors(\lblVidCapPhysical,#False)
                    SetGadgetColor(\cntVidCapPhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblVidCapPhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntVidCapPhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntVidCapPhysDevLabels
                  \lnVidCapVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnVidCapVertSep")
                  \lnVidCapVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnVidCapVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                  
                  ; video capture device sidebar
                  \cntVidCapDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntVidCapDevSideBar")
                    \imgVidCapButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgVidCapButtonTBS[0]")
                    \imgVidCapButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgVidCapButtonTBS[1]")
                    \imgVidCapButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgVidCapButtonTBS[2]")
                    \imgVidCapButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgVidCapButtonTBS[3]")
                  scsCloseGadgetList() ; cntDevSideBar
                  If grLicInfo\nMaxVidCapDevPerProd < 1
                    ; hide sidebar of only one device is allowed with this license type (eg SCS Lite)
                    setVisible(\cntVidCapDevSideBar, #False)
                  EndIf
                  
                  ; video capture devices
                  \nDevInnerHeight = (grLicInfo\nMaxVidCapDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaVidCapDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaVidCapDevs")
                    \nVertSepLeft = 0
                    \lnVidCapVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnVidCapVertSepInSCA") ; line to the left of the physical device combobox
                    \lnVidCapVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnVidCapVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  ;/
                  ; video capture dev detail
                  ;/
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \pnlVidCapDevDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlVidCapDevDetail")
                    scsSetGadgetFont(\pnlVidCapDevDetail,#SCS_FONT_GEN_BOLD)
                    
                    ; default settings
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlVidCapDevDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlVidCapDevDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlVidCapDevDetail, #PB_Panel_ItemHeight)
                    \cntVidCapDfltSettings=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntVidCapDfltSettings")
                      \cntVidCapDevFormatEtc=scsContainerGadget(20,12,288,59,#PB_Container_Flat,"cntVidCapDevFormatEtc")
                        setAllowEditorColors(\cntVidCapDevFormatEtc,#False)
                        SetGadgetColor(\cntVidCapDevFormatEtc,#PB_Gadget_BackColor,\nPhysBackColor)
                        nTop = 6
                        \lblVidCapDevFormat=scsTextGadget(4,nTop+gnLblVOffsetC,80,15,Lang("WEP","lblVidCapDevFormat"),#PB_Text_Right,"lblVidCapDevFormat")
                        setAllowEditorColors(\lblVidCapDevFormat,#False)
                        SetGadgetColor(\lblVidCapDevFormat,#PB_Gadget_BackColor,\nPhysBackColor)
                        \cboVidCapDevFormat=scsComboBoxGadget(gnNextX+gnGap,nTop,180,21,0,"cboVidCapDevFormat")
                        nTop + 24
                        \lblVidCapDevFrameRate=scsTextGadget(4,nTop+gnLblVOffsetS,80,15,Lang("WEP","lblVidCapDevFrameRate"),#PB_Text_Right,"lblVidCapDevFrameRate")
                        setAllowEditorColors(\lblVidCapDevFrameRate,#False)
                        SetGadgetColor(\lblVidCapDevFrameRate,#PB_Gadget_BackColor,\nPhysBackColor)
                        \txtVidCapDevFrameRate=scsStringGadget(gnNextX+gnGap,nTop,40,21,"0",0,"txtVidCapDevFrameRate")
                        scsToolTip(\txtVidCapDevFrameRate,Lang("WEP","txtVidCapDevFrameRateTT"))
                      scsCloseGadgetList()
                      nTop = GadgetHeight(\cntVidCapDevFormatEtc) + 20
                      nLeft = GadgetX(\cntVidCapDevFormatEtc) + GadgetX(\cboVidCapDevFormat) + gl3DBorderAllowanceX
                      \chkVidCapAutoInclude=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WEP","chkAutoInclude"),0,"chkVidCapAutoInclude")
                      scsToolTip(\chkVidCapAutoInclude, Lang("WEP", "chkAutoIncludeTT"))
                      nTop + 24
                    scsCloseGadgetList()
                    
                    ; video capture test gadgets
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlVidCapDevDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlVidCapDevDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlVidCapDevDetail, #PB_Panel_ItemHeight)
                    \cntTestVidCap=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_Flat,"cntTestVidCap")
                      nLeft = 20
                      nTop = (GadgetHeight(\cntTestVidCap) - 180) / 2  ; 180 will be height of \cvsTestVidCap, so the intention is to center \cvsTestVidCap vertically
                      If nTop < 0
                        nTop = 0
                      EndIf
                      nWidth = 70
                      \btnTestVidCapStart=scsButtonGadget(nLeft,nTop,nWidth,23,Trim(LangPars("WEP","btnTestVidCapStart", "")),0,"btnTestVidCapStart")
                      \btnTestVidCapStop=scsButtonGadget(nLeft,nTop,nWidth,23,Trim(LangPars("WEP","btnTestVidCapStop", "")),0,"btnTestVidCapStop")
                      nWidth = GadgetWidth(\btnTestVidCapStart, #PB_Gadget_RequiredSize)
                      If GadgetWidth(\btnTestVidCapStop, #PB_Gadget_RequiredSize) > nWidth
                        nWidth = GadgetWidth(\btnTestVidCapStop, #PB_Gadget_RequiredSize)
                      EndIf
                      ResizeGadget(\btnTestVidCapStart, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                      ResizeGadget(\btnTestVidCapStop, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                      setVisible(\btnTestVidCapStop, #False)
                      resetNextX(\btnTestVidCapStart)
                      nLeft = gnNextX+12
                      \cvsTestVidCap=scsCanvasGadget(nLeft,nTop,320,180,0,"cvsTestVidCap")
                      If StartDrawing(CanvasOutput(\cvsTestVidCap))
                        Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                        ; Box(0,0,OutputWidth(),OutputHeight(),#SCS_Blue)
                        StopDrawing()
                      EndIf
                    scsCloseGadgetList()
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxVidCapDevPerProd >= 0
              ;}
              
              ; =======================================
              ;- PROD Fixture Types tab within \pnlDevs
              ; =======================================
              ;{
              If grLicInfo\nMaxFixTypePerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_FIX_TYPE])
                sTabDesc = "\pnlDevs tab: devices - fixture types"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("WEP","FixTypes"), #SCS_PROD_TAB_FIX_TYPES)
                
                \cntTabFixTypesPre118=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabFixTypesPre118")
                  nLeft = 120
                  nWidth = GadgetWidth(\cntTabFixTypesPre118) - (nLeft << 1)
                  \lblFixtureTypesPre118=scsTextGadget(nLeft,24,nWidth,50,Lang("WEP","lblFixtureTypesPre118"),#PB_Text_Center,"lblFixtureTypesPre118")
                  scsSetGadgetFont(\lblFixtureTypesPre118, #SCS_FONT_GEN_NORMAL10)
                scsCloseGadgetList()
                setVisible(\cntTabFixTypesPre118, #False)
                
                \cntTabFixTypes=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabFixTypes")
                  \lblFixtureTypes=scsTextGadget(47,12,300,17,Lang("WEP","lblFixtureTypes"),0,"lblFixtureTypes")
                  scsSetGadgetFont(\lblFixtureTypes, #SCS_FONT_GEN_BOLDUL)
                  
                  nTop = 36
                  \lblFixTypeName=scsTextGadget(53,nTop,88,27,Lang("WEP","lblFixTypeName"),#PB_Text_Center,"lblFixTypeName")
                  \lblFixTypeInfo=scsTextGadget(gnNextX+8,nTop,240,27,Lang("WEP","lblFixTypeInfo"),0,"lblFixTypeInfo")
                  nCntGadgetNo = \lblFixTypeInfo
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo) + 2
                  
                  ; fixture types sidebar
                  \cntFixTypeSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntFixTypeSideBar")
                    \imgFixTypeButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgFixTypeButtonTBS[0]")
                    \imgFixTypeButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgFixTypeButtonTBS[1]")
                    \imgFixTypeButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgFixTypeButtonTBS[2]")
                    \imgFixTypeButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgFixTypeButtonTBS[3]")
                  scsCloseGadgetList() ; cntFixTypeSideBar
                  
                  ; fixture types
                  \nDevInnerHeight = (grLicInfo\nMaxFixTypePerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaFixTypes=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaFixTypes")
                  scsCloseGadgetList()
                  
                  ;/
                  ; fixture type detail
                  ;/
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \pnlFixTypeDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlFixTypeDetail")
                    scsSetGadgetFont(\pnlFixTypeDetail,#SCS_FONT_GEN_BOLD)
                    
                    ; general properties of the fixture type
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlFixTypeDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlFixTypeDetail, #PB_Panel_ItemWidth)
                    nHeight = 68
                    \cntFixTypeGeneral=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntFixTypeGeneral")
                      nLeft = 4
                      nTop = 12
                      nLblWidth = 100
                      \lblFixTypeDesc=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nLblWidth,17,Lang("Common","Description"),#PB_Text_Right,"lblFixTypeDesc")
                      \txtFixTypeDesc=scsStringGadget(gnNextX+gnGap,nTop,300,21,"",0,"lblFixTypeDesc")
                      nTop + 26
                      nItemWidth = 25
                      \lblFTTotalChans=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nLblWidth,17,Lang("WEP","lblFTTotalChans"),#PB_Text_Right,"lblFTTotalChans")
                      \txtFTTotalChans=scsStringGadget(gnNextX+gnGap,nTop,nItemWidth,21,"",#PB_String_Numeric,"txtFTTotalChans")
                    scsCloseGadgetList()  ; cntFixTypeGeneral
                    
                    ; fixture channel properties of the fixture type
                    nLeft = GadgetX(\cntFixTypeGeneral)
                    nTop = GadgetY(\cntFixTypeGeneral) + GadgetHeight(\cntFixTypeGeneral)
                    nWidth = GadgetWidth(\cntFixTypeGeneral)
                    nHeight = GetGadgetAttribute(\pnlFixTypeDetail, #PB_Panel_ItemHeight) - nTop
                    \cntFixTypeChannels=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntFixTypeChannels")
                      \lnFixTypeChannels=scsLineGadget(12,0,nWidth-24,1,#SCS_Light_Grey,0,"lnFixTypeChannels")
                      nLeft = 50 ; 28
                      nTop = 8 ; 12
                      \lblFTCChannel=scsTextGadget(nLeft,nTop,20,17,Lang("Common","Channel"),0,"lblFTCChannel")
                      setGadgetWidth(\lblFTCChannel,-1,#True)
                      ; \lblFTCChannelDesc=scsTextGadget(gnNextX+gnGap2,nTop,220,17,grText\sTextDescription,0,"lblFTCChannelDesc")
                      \lblFTCChannelDesc=scsTextGadget(gnNextX+gnGap2,nTop,160,17,Lang("WEP","lblFTCChannelDesc"),0,"lblFTCChannelDesc")
                      \lblFTCDimmerChan=scsTextGadget(gnNextX+gnGap2,nTop,17,26,Lang("WEP","lblFTCDimmerChan"),0,"lblFTCDimmerChan")
                      AutoSize(\lblFTCDimmerChan)
                      \lblFTCDefault=scsTextGadget(gnNextX+gnGap2,nTop,30,26,Lang("WEP","lblFTCDefault"),0,"lblFTCDefault")
                      AutoSize(\lblFTCDefault,0,30)  ; 30 is width to be assigned to \txtFTCDefault[n]
                      \lblFTCTextColor=scsTextGadget(gnNextX+gnGap2,nTop,58,26,Lang("WEP","lblFTCTextColor"),0,"lblFTCTextColor")
                      AutoSize(\lblFTCTextColor,0,58)
                      \lblFTCGridSample=scsTextGadget(gnNextX+gnGap2,nTop,58,26,Lang("WEP","lblFTCGridSample"),0,"lblFTCGridSample")
                      AutoSize(\lblFTCGridSample,0,58)
                      
                      nTop + 27
                      nHeight = GadgetHeight(\cntFixTypeChannels) - nTop - 2
                      nHeight = Round(nHeight / (21), #PB_Round_Down)
                      nHeight * 21
                      \nDevInnerHeight = #SCS_MAX_FIX_TYPE_CHANNEL * 21
                      \nDevInnerWidth = gnNextX + gnGap2
                      nWidth = \nDevInnerWidth + glScrollBarWidth + gl3DBorderAllowanceX
                      \scaFixTypeChans=scsScrollAreaGadget(0,nTop,nWidth,nHeight,\nDevInnerWidth, \nDevInnerHeight, 21, #PB_ScrollArea_BorderLess, "scaFixTypeChans")
                        nTop = 0
                        For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
                          sNr = "["+n+"]"
                          \cntFTCDetail[n]=scsContainerGadget(0,nTop,\nDevInnerWidth,21,#PB_Container_BorderLess,"cntFTCDetail"+sNr)
                            nWidth = 20
                            nLeft = GadgetX(\lblFTCChannel) + (GadgetWidth(\lblFTCChannel) / 2) - (nWidth / 2)
                            \lblFTCChanNo[n]=scsStringGadget(nLeft,0,nWidth,21,Str(n+1),#PB_String_ReadOnly|#ES_CENTER,"lblFTCChanNo"+sNr)
                            \txtFTCChannelDesc[n]=scsStringGadget(GadgetX(\lblFTCChannelDesc),0,160,21,"",0,"txtFTCChannelDesc"+sNr)
                            nWidth = 17
                            nLeft = GadgetX(\lblFTCDimmerChan) + (GadgetWidth(\lblFTCDimmerChan) / 2) - (nWidth / 2)
                            \chkFTCDimmerChan[n]=scsCheckBoxGadget2(nLeft,2,nWidth,17,"",0,"chkFTCDimmerChan"+sNr)
                            \txtFTCDefault[n]=scsStringGadget(GadgetX(\lblFTCDefault),0,40,21,"",0,"txtFTCDefault"+sNr)
                            \cvsFTCTextColor[n]=scsCanvasGadget(GadgetX(\lblFTCTextColor),1,58,19,0,"cntFTCTextColor"+sNr)
                            scsToolTip(\cvsFTCTextColor[n], Lang("WEP", "cvsFTCTextColorTT"))
                            \cvsFTCGridSample[n]=scsCanvasGadget(GadgetX(\lblFTCGridSample),2,40,17,0,"cvsFTCGridSample"+sNr)
                          scsCloseGadgetList()  ; cntFTCDetail[n]
                          nTop + 21
                        Next n
                      scsCloseGadgetList() ; scaFixTypeChans
                    scsCloseGadgetList() ; cntFixTypeChannels
                    
                  scsCloseGadgetList() ; pnlFixTypeDetail
                  
                scsCloseGadgetList() ; cntTabFixTypes
                ;}
                grWEP\nLoadProgress + 1
               WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxFixTypePerProd >= 0
              ;}
              
              ; ==========================================
              ;- PROD Lighting Devices tab within \pnlDevs
              ; ==========================================
              ;{
              If grLicInfo\nMaxLightingDevPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_LIGHTING])
                ; sTabDesc = "\pnlDevs tab: devices - lighting"
                ; debugMsg(sProcName,  sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "Lighting"), #SCS_PROD_TAB_LIGHTING_DEVS)
                
                \cntTabLightingDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabLightingDevs")
                  \lblLightingDevsReqd=scsTextGadget(47,22,210,18,Lang("WEP","lblDevsReqd"),0,"lblLightingDevsReqd")
                  scsSetGadgetFont(\lblLightingDevsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  \lblLightingDevType=scsTextGadget(65,44,100,26,Lang("WEP","lblDevType"),#PB_Text_Center,"lblLightingDevType")
                  \lblLightingDevName=scsTextGadget(gnNextX+2,44,68,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblLightingDevName")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_LIGHTING_DEVS, 241)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_LIGHTING_DEVS])
                  \cntLightingPhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntLightingPhysDevLabels")
                    nTop = 2
                    \lblLightingPhysical=scsTextGadget(9,nTop,300,17,Lang("WEP","lblPhysical"),0,"lblLightingPhysical")
                    \lblLightingActive=scsTextGadget(gnNextX,nTop,106,17,Lang("WEP","lblActive"),0,"lblLightingActive")
                    setGadgetWidth(\lblLightingActive,-1,#True)
                    setAllowEditorColors(\cntLightingPhysDevLabels,#False)
                    setAllowEditorColors(\lblLightingPhysical,#False)
                    setAllowEditorColors(\lblLightingActive,#False)
                    SetGadgetColor(\cntLightingPhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblLightingPhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblLightingActive,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntLightingPhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntLightingPhysDevLabels
                  \lnLightingVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnLightingVertSep")
                  \lnLightingVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnLightingVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)

                  ; Lighting device sidebar
                  \cntLightingDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntLightingDevSideBar")
                    \imgLightingButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgLightingButtonTBS[0]")
                    \imgLightingButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgLightingButtonTBS[1]")
                    \imgLightingButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgLightingButtonTBS[2]")
                    \imgLightingButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgLightingButtonTBS[3]")
                  scsCloseGadgetList() ; cntDevSideBar
                  If grLicInfo\nMaxLightingDevPerProd < 1
                    ; hide sidebar of only one device is allowed with this license type
                    setVisible(\cntLightingDevSideBar, #False)
                  EndIf
                  
                  ; Lighting devices
                  nScaLightingDevsHeight = (4 * nDevRowHeight) + nScaDevsExtraDepth ; set for 4 rows plus a lower border area
                  ; ensure the calculated height allows for the side bar buttons (up, down, + and -)
                  If nScaLightingDevsHeight < GadgetHeight(\cntLightingDevSideBar)
                    nScaLightingDevsHeight = GadgetHeight(\cntLightingDevSideBar) + nScaDevsExtraDepth
                  EndIf
                  \nDevInnerHeight = (grLicInfo\nMaxLightingDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaLightingDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,nScaLightingDevsHeight,\nDevInnerWidth,\nDevInnerHeight,nDevRowHeight,#PB_ScrollArea_BorderLess,"scaLightingDevs")
                    \nVertSepLeft = 0
                    \lnLightingVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnLightingVertSepInSCA") ; line to the left of the physical device combobox
                    \lnLightingVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnLightingVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  ;/
                  ; Lighting dev detail
                  ;/
                  \nDevDetailTop = \nScaDevsTop + nScaLightingDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  nScaFixturesLeft = \nScaDevsLeft
                  \cntLightingDevDetail=scsContainerGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,0,"cntLightingDevDetail")
                    \lblLightingDevDetail=scsTextGadget(0,0,\nDevDetailWidth,15,"",0,"lblLightingDevDetail")
                    setReverseEditorColors(\lblLightingDevDetail, #True)
                    ; Lighting DMX settings (NB index 0 = DMX send, ie lighting. Index 1 is used for cue control DMX device info.)
                    \cntDMXSettings[0]=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntDMXSettings[0]")
                      If grLicInfo\bDMXSendAvailable
                        nCntLeft = 2
                        nCntWidth = 350  ; nb container will be dynamically resized and some gadgets repositioned in WEP_resizeDMXOutDevInfo()
                        \cntPhysDMX[0]=scsContainerGadget(nCntLeft,4,nCntWidth,56,#PB_Container_Flat,"cntPhysDMX[0]")
                          setAllowEditorColors(\cntPhysDMX[0],#False)
                          SetGadgetColor(\cntPhysDMX[0],#PB_Gadget_BackColor,\nPhysBackColor)
                          ; physical device
                          nTop = 4
                          \lblDMXPhysDev[0]=scsTextGadget(6,nTop,181,15,Lang("WEP","lblPhysical"),0,"lblDMXPhysDev[0]")
                          setGadgetWidth(\lblDMXPhysDev[0])
                          setAllowEditorColors(\lblDMXPhysDev[0],#False)
                          SetGadgetColor(\lblDMXPhysDev[0],#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop + 19
                          \cboDMXPhysDev[0]=scsComboBoxGadget(4,nTop,181,21,0,"cboDMXPhysDev[0]")
                          scsToolTip(\cboDMXPhysDev[0],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblDMXPhysDev[0]))))
                          ; port
                          nTop = 4
                          \lblDMXPort[0]=scsTextGadget(192,nTop,80,15,Lang("WEP","lblDMXPort"),0,"lblDMXPort[0]")
                          setGadgetWidth(\lblDMXPort[0])
                          setAllowEditorColors(\lblDMXPort[0],#False)
                          SetGadgetColor(\lblDMXPort[0],#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop + 19
                          \cboDMXPort[0]=scsComboBoxGadget(190,nTop,50,21,0,"cboDMXPort[0]")
                          ; refresh rate
                          nTop = 4
                          \lblDMXRefreshRate=scsTextGadget(277,nTop,80,15,Lang("WEP","lblDMXRefreshRate"),0,"lblDMXRefreshRate")
                          setGadgetWidth(\lblDMXRefreshRate)
                          setAllowEditorColors(\lblDMXRefreshRate,#False)
                          SetGadgetColor(\lblDMXRefreshRate,#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop + 19
                          \cboDMXRefreshRate=scsComboBoxGadget(275,nTop,50,21,0,"cboDMXRefreshRate")
                          ; IP address
                          nTop = 4
                          \lblDMXIpAddress=scsTextGadget(277,nTop,48,15,Lang("WEP","lblDMXIpAddress"),0,"lblDMXIpAddress")
                          setGadgetWidth(\lblDMXIpAddress)
                          setAllowEditorColors(\lblDMXIpAddress,#False)
                          SetGadgetColor(\lblDMXIpAddress,#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop + 19
                          \cboDMXIpAddress=scsComboBoxGadget(275,nTop,130,21,0,"cboDMXIpAddress")
                          \btnDMXIPRefresh=scsButtonGadget(320,nTop,80,gnBtnHeight,Lang("WEP","btnDMXIPRefresh"),0,"btnDMXIPRefresh")
                        scsCloseGadgetList()
                        
                        nScaFixturesLeft = \nSideBarLeft + \nSideBarWidth
                        nScaFixturesWidth = \nDevPanelItemWidth - nScaFixturesLeft - 10
                        nScaFixturesHeight = 8 * 21
                        nTop = GadgetY(\cntPhysDMX[0]) + GadgetHeight(\cntPhysDMX[0]) + 14
                        nLeft = nScaFixturesLeft
                        nWidth = nScaFixturesWidth
                        \cntFixtureLabels=scsContainerGadget(nLeft,nTop,nWidth,38,#PB_Container_BorderLess,"cntFixtureLabels")
                          \lblFixtures=scsTextGadget(0,0,80,17,Lang("WEP","lblFixtures"),0,"lblFixtures")
                          scsSetGadgetFont(\lblFixtures,#SCS_FONT_GEN_BOLDUL)
                          nTop = 21
                          \lblFixtureCode=scsTextGadget(36,nTop,70,15,Lang("WEP","lblFixtureCode"),0,"lblFixtureCode")
                          ; as from SCS 11.8:
                          \lblFixtureDesc=scsTextGadget(gnNextX+2,nTop,100,15,grText\sTextDescription,0,"lblFixtureDesc")
                          \lblFixtureType=scsTextGadget(gnNextX+2,nTop,222,15,Lang("WEP","lblFixtureType"),0,"lblFixtureType")
                          ; pre SCS 11.8:
                          \lblFixtureDescPre118=scsTextGadget(GadgetX(\lblFixtureDesc),nTop,200,15,grText\sTextDescription,0,"lblFixtureDescPre118")
                          \lblDimmableChannels=scsTextGadget(gnNextX+2,nTop,120,15,Lang("WEP","lblDimmableChannels"),0,"lblDimmableChannels")
                          setVisible(\lblFixtureDescPre118,#False)
                          setVisible(\lblDimmableChannels,#False)
                          ; common
                          \cntDMXStartChannels=scsContainerGadget(gnNextX+gnGap2,0,110,GadgetHeight(\cntFixtureLabels),0,"cntDMXStartChannels")
                            setAllowEditorColors(\cntDMXStartChannels,#False)
                            SetGadgetColor(\cntDMXStartChannels,#PB_Gadget_BackColor,\nPhysBackColor)
                            nWidth = GadgetWidth(\cntDMXStartChannels)
                            \lblDMXStartChannel=scsTextGadget(0,1,nWidth,15,Lang("WEP","lblDMXStartChannel"),#PB_Text_Center,"lblDMXStartChannel")
                            setAllowEditorColors(\lblDMXStartChannel,#False)
                            SetGadgetColor(\lblDMXStartChannel,#PB_Gadget_BackColor,\nPhysBackColor)
                            \btnCopyDMXStartsFrom=scsButtonGadget(2,17,nWidth-4,21,LangEllipsis("Common","CopyFrom"),0,"btnCopyDMXStartsFrom")
                          scsCloseGadgetList()
                        scsCloseGadgetList()
                        nScaFixturesTop = GadgetY(\cntFixtureLabels) + GadgetHeight(\cntFixtureLabels)
                        ; Lighting fixtures sidebar
                        \cntLightingFixtureSideBar=scsContainerGadget(\nSideBarLeft,nScaFixturesTop,\nSideBarWidth,96,0,"cntLightingFixtureSideBar")
                          \imgFixtureButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgFixtureButtonTBS[0]")
                          \imgFixtureButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgFixtureButtonTBS[1]")
                          \imgFixtureButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgFixtureButtonTBS[2]")
                          \imgFixtureButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgFixtureButtonTBS[3]")
                        scsCloseGadgetList() ; cntLightingFixtureSideBar
                        nFixturesInnerHeight = 8 * 21  ; dynamically adjusted in setWEPFixturePositions()
                        nFixturesInnerWidth = nScaFixturesWidth - glScrollBarWidth - gl3DBorderAllowanceX
                        \scaFixtures=scsScrollAreaGadget(nScaFixturesLeft,nScaFixturesTop,nScaFixturesWidth,nScaFixturesHeight,nFixturesInnerWidth,nFixturesInnerHeight,21,#PB_ScrollArea_BorderLess,"scaFixtures")
                        scsCloseGadgetList()
                        
                      EndIf
                    scsCloseGadgetList()
                    setVisible(\cntDMXSettings[0], #False)
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxLightDevPerProd >= 0
              ;}
              
              ; ===========================================
              ;- PROD Ctrl Send Devices tab within \pnlDevs
              ; ===========================================
              ;{
              If grLicInfo\nMaxCtrlSendDevPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_CTRL_SEND])
                sTabDesc = "\pnlDevs tab: devices - ctrl send"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "CtrlSend"), #SCS_PROD_TAB_CTRL_DEVS)
                sChkM2TSkipEarlierCSMsgs = Lang("WEP", "chkM2TSkipEarlierCSMsgs")
                
                \cntTabCtrlDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabCtrlDevs")
                  \lblCtrlInfo=scsTextGadget(47,4,170,18,Lang("WEP","lblCtrlInfo"),0,"lblCtrlInfo")
                  scsSetGadgetFont(\lblCtrlInfo, #SCS_FONT_GEN_ITALIC)
                  \lblCtrlDevsReqd=scsTextGadget(47,22,210,18,Lang("WEP","lblDevsReqd"),0,"lblCtrlDevsReqd")
                  scsSetGadgetFont(\lblCtrlDevsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  \lblCtrlDevType=scsTextGadget(65,44,100,26,Lang("WEP","lblDevType"),#PB_Text_Center,"lblCtrlDevType")
                  \lblCtrlDevName=scsTextGadget(gnNextX+2,44,68,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblCtrlDevName")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_CTRL_DEVS, 241)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_CTRL_DEVS])
                  \cntCtrlPhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntCtrlPhysDevLabels")
                    nTop = 2
                    \lblCtrlPhysical=scsTextGadget(8,nTop,300,17,Lang("WEP","lblPhysical"),0,"lblCtrlPhysical")
                    \lblCtrlActive=scsTextGadget(gnNextX,nTop,106,17,Lang("WEP","lblActive"),0,"lblCtrlActive")
                    setGadgetWidth(\lblCtrlActive,-1,#True)
                    setAllowEditorColors(\cntCtrlPhysDevLabels,#False)
                    setAllowEditorColors(\lblCtrlPhysical,#False)
                    setAllowEditorColors(\lblCtrlActive,#False)
                    SetGadgetColor(\cntCtrlPhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblCtrlPhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblCtrlActive,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntCtrlPhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntCtrlPhysDevLabels
                  \lnCtrlVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnCtrlVertSep")
                  \lnCtrlVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnCtrlVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                  
                  ; ctrl send device sidebar
                  \cntCtrlDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntCtrlDevSideBar")
                    \imgCtrlButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgCtrlButtonTBS[0]")
                    \imgCtrlButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgCtrlButtonTBS[1]")
                    \imgCtrlButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgCtrlButtonTBS[2]")
                    \imgCtrlButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgCtrlButtonTBS[3]")
                  scsCloseGadgetList() ; cntDevSideBar
                  If grLicInfo\nMaxCtrlSendDevPerProd < 1
                    ; hide sidebar of only one device is allowed with this license type (eg SCS Lite)
                    setVisible(\cntCtrlDevSideBar, #False)
                  EndIf
                  
                  ; ctrl send devices
                  \nDevInnerHeight = (grLicInfo\nMaxCtrlSendDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaCtrlDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaCtrlDevs")
                    \nVertSepLeft = 0
                    \lnCtrlVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnCtrlVertSepInSCA") ; line to the left of the physical device combobox
                    \lnCtrlVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnCtrlVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  ; ctrl send dev detail
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \cntCtrlDevDetail=scsContainerGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,0,"cntCtrlDevDetail")
                    \lblCtrlDevDetail=scsTextGadget(0,0,\nDevDetailWidth,15,"",0,"lblCtrlDevDetail")
                    setReverseEditorColors(\lblCtrlDevDetail, #True)
                    nCSDevTypeIndex = -1
                    
                    ; ctrl send MIDI settings
                    nCSDevTypeIndex + 1
                    \cntMIDISettings[0]=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntMIDISettings[0]")
                      nTop = 4
                      \cntPhysMidi[0]=scsContainerGadget(4,nTop,300,31,#PB_Container_Flat,"cntPhysMidi[0]")
                        nTop2 = 3
                        \lblMidiOutPort=scsTextGadget(8,nTop2+gnLblVOffsetC,92,17,Lang("WEP","lblMidiOutPort"),#PB_Text_Right,"lblMidiOutPort")
                        \cboMidiOutPort=scsComboBoxGadget(gnNextX+7,nTop2,180,21,0,"cboMidiOutPort") ; should be wide enough for "Microsoft GS Wavetable Synth"
                        scsToolTip(\cboMidiOutPort,LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblMidiOutPort))))
                        setAllowEditorColors(\cntPhysMidi[0],#False)
                        setAllowEditorColors(\lblMidiOutPort,#False)
                        SetGadgetColor(\cntPhysMidi[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblMidiOutPort,#PB_Gadget_BackColor,\nPhysBackColor)
                        ResizeGadget(\cntPhysMidi[0],#PB_Ignore,#PB_Ignore,gnNextX+12,#PB_Ignore)
                      scsCloseGadgetList()
                      nTop = GadgetY(\cntPhysMidi[0]) + GadgetHeight(\cntPhysMidi[0]) + 6
                      If grLicInfo\bCSRDAvailable
                        nLeft = 0
                        nWidth = GadgetX(\cntPhysMidi[0]) + GadgetX(\cboMidiOutPort) + 1 - gnGap
                        \lblCtrlMidiRemoteDev=scsTextGadget(nLeft,nTop+4,nWidth,17,Lang("WEP","lblRemoteDev"),#PB_Text_Right,"lblCtrlMidiRemoteDev")
                        setGadgetWidth(\lblCtrlMidiRemoteDev, nWidth, #True) ; Added 18Jan2022 11.9am following test of French translation
                        \cboCtrlMidiRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboCtrlMidiRemoteDev")
                        \lblCtrlMidiChannel=scsTextGadget(gnNextX+12,nTop+4,nWidth,17,Lang("WEP","lblMidiChannel"),#PB_Text_Right,"lblCtrlMidiChannel")
                        setGadgetWidth(\lblCtrlMidiChannel, 20, #True)
                        \cboCtrlMidiChannel=scsComboBoxGadget(gnNextX+gnGap,nTop,50,21,0,"cboCtrlMidiChannel")
                        nTop + 25
                      EndIf
                      nLeft = GadgetX(\cntPhysMidi[0]) + GadgetX(\cboMidiOutPort) + 1
                      \chkForMTC=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WEP","chkForMTC"),0,"chkForMTC")
                      scsToolTip(\chkForMTC,Lang("WEP","chkForMTCTT"))
                      If grLicInfo\bM2TAvailable
                        nTop + 20
                        \chkM2TSkipEarlierCSMsgs_MidiOut=scsCheckBoxGadget2(nLeft,nTop,-1,17,sChkM2TSkipEarlierCSMsgs,0,"chkM2TSkipEarlierCSMsgs_MidiOut")
                      EndIf
                    scsCloseGadgetList()
                    setVisible(\cntMIDISettings[0], #False)
                    
                    ; ctrl send MIDI Thru settings
                    nCSDevTypeIndex + 1
                    \cntMidiThruSettings=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntMidiThruSettings")
                      nTop = 4
                      \cntPhysMidiThru=scsContainerGadget(4,nTop,300,76,#PB_Container_Flat,"cntPhysMidiThru")
                        nTop2 = 3
                        \lblMidiThruInPort=scsTextGadget(8,nTop2+gnLblVOffsetC,92,17,Lang("WEP","lblMidiInPort"),#PB_Text_Right,"lblMidiThruInPort")
                        \cboMidiThruInPort=scsComboBoxGadget(gnNextX+7,nTop2,180,21,0,"cboMidiThruInPort") ; should be wide enough for "Microsoft GS Wavetable Synth"
                        scsToolTip(\cboMidiThruInPort,LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblMidiThruInPort))))
                        nTop2 + 25
                        nWidth = 140
                        nLeft = GadgetX(\cboMidiThruInPort) - (nWidth >> 1) - 4
                        \lblConnectTo=scsTextGadget(nLeft,nTop2,nWidth,17,LangColon("WEP","lblConnectTo"),#PB_Text_Center,"lblConnectTo")
                        scsSetGadgetFont(\lblConnectTo, #SCS_FONT_GEN_ITALIC)
                        nTop2 + 19
                        \lblMidiThruOutPort=scsTextGadget(8,nTop2+gnLblVOffsetC,92,17,Lang("WEP","lblMidiOutPort"),#PB_Text_Right,"lblMidiThruOutPort")
                        \cboMidiThruOutPort=scsComboBoxGadget(gnNextX+7,nTop2,180,21,0,"cboMidiThruOutPort") ; should be wide enough for "Microsoft GS Wavetable Synth"
                        scsToolTip(\cboMidiThruOutPort,LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblMidiThruOutPort))))
                        setAllowEditorColors(\cntPhysMidiThru,#False)
                        setAllowEditorColors(\lblMidiThruOutPort,#False)
                        setAllowEditorColors(\lblConnectTo,#False)
                        setAllowEditorColors(\lblMidiThruInPort,#False)
                        SetGadgetColor(\cntPhysMidiThru,#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblMidiThruOutPort,#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblConnectTo,#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblMidiThruInPort,#PB_Gadget_BackColor,\nPhysBackColor)
                        ResizeGadget(\cntPhysMidiThru,#PB_Ignore,#PB_Ignore,gnNextX+12,#PB_Ignore)
                      scsCloseGadgetList()
                    scsCloseGadgetList()
                    setVisible(\cntMidiThruSettings, #False)
                    
                    ; ctrl send RS232 settings
                    nCSDevTypeIndex + 1
                    \cntRS232Settings[0]=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntRS232Settings[0]")
                      \cntPhysRS232[0]=scsContainerGadget(4,4,300,29,#PB_Container_Flat,"cntPhysRS232[0]")
                        \lblRS232Port[0]=scsTextGadget(8,7,72,15,Lang("WEP","lblRS232Port"), #PB_Text_Right,"lblRS232Port[0]")
                        \cboRS232Port[0]=scsComboBoxGadget(gnNextX+7,3,120,21,0,"cboRS232Port[0]")
                        scsToolTip(\cboRS232Port[0],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblRS232Port[0]))))
                        setAllowEditorColors(\cntPhysRS232[0],#False)
                        setAllowEditorColors(\lblRS232Port[0],#False)
                        SetGadgetColor(\cntPhysRS232[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblRS232Port[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        ResizeGadget(\cntPhysRS232[0],#PB_Ignore,#PB_Ignore,gnNextX+12,#PB_Ignore)
                      scsCloseGadgetList()
                      nTop = GadgetY(\cntPhysRS232[0]) + GadgetHeight(\cntPhysRS232[0]) + 4
                      \lblBaudRate[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblBaudRate"), #PB_Text_Right,"lblBaudRate[0]")
                      \cboRS232BaudRate[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232BaudRate[0]")
                      nTop + 21
                      \lblDataBits[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblDataBits"), #PB_Text_Right,"lblDataBits[0]")
                      \cboRS232DataBits[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232DataBits[0]")
                      nTop + 21
                      \lblStopBits[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblStopBits"), #PB_Text_Right,"lblStopBits[0]")
                      \cboRS232StopBits[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232StopBits[0]")
                      nTop + 21
                      \lblParity[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblParity"), #PB_Text_Right,"lblParity[0]")
                      \cboRS232Parity[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232Parity[0]")
                      nTop + 21
                      \lblRS232Handshaking[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblRS232Handshaking"), #PB_Text_Right,"lblRS232Handshaking[0]")
                      \cboRS232Handshaking[0]=scsComboBoxGadget(gnNextX+7,nTop,200,21,0,"cboRS232Handshaking[0]")
                      nTop + 21
                      \lblRS232RTSEnable[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblRS232RTSEnable"), #PB_Text_Right,"lblRS232RTSEnable[0]")
                      \cboRS232RTSEnable[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232RTSEnable[0]")
                      scsToolTip(\cboRS232RTSEnable[0],Lang("WEP","cboRS232RTSEnableTT"))
                      nTop + 21
                      \lblRS232DTREnable[0]=scsTextGadget(12,nTop+4,72,15,Lang("WEP","lblRS232DTREnable"), #PB_Text_Right,"lblRS232DTREnable[0]")
                      \cboRS232DTREnable[0]=scsComboBoxGadget(gnNextX+7,nTop,81,21,0,"cboRS232DTREnable[0]")
                      scsToolTip(\cboRS232DTREnable[0],Lang("WEP","cboRS232DTREnableTT"))
                      nTop + 25
                      \btnRS232Default[0]=scsButtonGadget(27,nTop,300,gnBtnHeight,Lang("WEP","btnRS232Default"),0,"btnRS232Default[0]")
                    scsCloseGadgetList()
                    setVisible(\cntRS232Settings[0], #False)
                    
                    ; ctrl send Network settings
                    nCSDevTypeIndex + 1
                    \cntNetworkSettings[0]=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntNetworkSettings[0]")
                      ; scsSetGadgetFont(\frNetworkConnection,#SCS_FONT_GEN_BOLD)
                      nTop = 5
                      \lblCtrlNetworkRemoteDev=scsTextGadget(4,nTop+4,94,17,Lang("WEP","lblRemoteDev"),#PB_Text_Right,"lblCtrlNetworkRemoteDev")
                      \cboCtrlNetworkRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboCtrlNetworkRemoteDev")
                      \lblOSCVersion[0]=scsTextGadget(gnNextX+gnGap2,nTop+4,94,17,Lang("Network","OSCVersion"),0,"lblOSCVersion[0]")
                      setGadgetWidth(\lblOSCVersion[0],-1,#True)
                      \cboOSCVersion[0]=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboOSCVersion")
                      nTop + 23
                      \lblNetworkProtocol[0]=scsTextGadget(4,nTop+4,94,17,Lang("Network","lblNetworkProtocol"),#PB_Text_Right,"lblNetworkProtocol[0]")
                      \cboNetworkProtocol[0]=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboNetworkProtocol[0]")
                      \lblNetworkRole[0]=scsTextGadget(gnNextX+gnGap,nTop+4,94,17,Lang("Network","lblNetworkRole"),#PB_Text_Right,"lblNetworkRole[0]")
                      setGadgetWidth(\lblNetworkRole[0], -1, #True) ; Added 19Sep2022 11.9.6
                      \cboNetworkRole[0]=scsComboBoxGadget(gnNextX+gnGap,nTop,40,21,0,"cboNetworkRole[0]")
                      \chkConnectWhenReqd=scsCheckBoxGadget2(gnNextX+gnGap2,nTop+2,-1,17,Lang("WEP","chkConnectWhenReqd"),0,"chkConnectWhenReqd") ; Added 19Sep2022 11.9.6
                      
                      nTop + 23
                      \cntPhysNetwork[0]=scsContainerGadget(4,nTop,442,35,#PB_Container_Flat,"cntPhysNetwork[0]")  ; modified width 2Nov2015 11.4.1.2g
                        nTop = 5
                        \chkNetworkDummy[0]=scsCheckBoxGadget2(4,nTop+2,120,17,Lang("Network","DummyConnection"),0,"chkNetworkDummy[0]")
                        ; \lblRemoteHost[0]=scsTextGadget(gnNextX+12,nTop+4,94,15,Lang("WEP","lblRemoteHost"),0,"lblRemoteHost[0]")
                        ; setGadgetWidth(\lblRemoteHost[0],-1,#True)
                        \lblRemoteHost[0]=scsTextGadget(gnNextX+gnGap2,nTop-2,80,28,Lang("WEP","lblRemoteHost2"),#PB_Text_Right,"lblRemoteHost[0]")
                        \txtRemoteHost[0]=scsStringGadget(gnNextX+gnGap,nTop,100,21,"",0,"txtRemoteHost[0]")
                        ; scsToolTip(\txtRemoteHost[0],Lang("WEP","txtRemoteHostTT"))
                        setVisible(\lblRemoteHost[0], #False)
                        setVisible(\txtRemoteHost[0], #False)
                        \lblRemotePort[0]=scsTextGadget(gnNextX+gnGap2,nTop+4,94,15,Lang("WEP","lblRemotePort"),#PB_Text_Right,"lblRemotePort[0]")
                        setGadgetWidth(\lblRemotePort[0],-1,#True)
                        \txtRemotePort[0]=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtRemotePort[0]")
                        ; scsToolTip(\txtRemotePort[0],Lang("WEP","txtRemotePortTT"))
                        setVisible(\lblRemotePort[0], #False)
                        setVisible(\txtRemotePort[0], #False)
                        \lblCtrlSendDelay=scsTextGadget(gnNextX+gnGap2,nTop-2,94,28,Lang("WEP","lblCtrlSendDelay"),#PB_Text_Right,"lblCtrlSendDelay")
                        ; setGadgetWidth(\lblCtrlSendDelay,-1,#True)
                        \txtCtrlSendDelay=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtCtrlSendDelay")
                        scsToolTip(\txtCtrlSendDelay,Lang("WEP","txtCtrlSendDelayTT"))
                        ; scsToolTip(\txtCSInterMsgDelay,Lang("WEP","txtRemotePortTT"))
                        setVisible(\lblCtrlSendDelay, #False)
                        setVisible(\txtCtrlSendDelay, #False)
                        ResizeGadget(\cntPhysNetwork[0],#PB_Ignore,#PB_Ignore,gnNextX+gnGap2,#PB_Ignore)
                        \lblLocalPort[0]=scsTextGadget(GadgetX(\lblRemoteHost[0]),nTop+4,94,15,Lang("Network","lblLocalPort"),#PB_Text_Right,"lblLocalPort[0]") ; modified 3Nov2015 11.4.1.2g
                        \txtLocalPort[0]=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtLocalPort[0]")
                        scsToolTip(\txtLocalPort[0],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblLocalPort[0]))))
                        setVisible(\lblLocalPort[0], #False)
                        setVisible(\txtLocalPort[0], #False)
                        \btnCompIPAddresses[0]=scsButtonGadget(60,nTop+26,200,21,LangEllipsis("Network","CompIPAddresses"),0,"btnCompIPAddresses[0]")
                        setVisible(\btnCompIPAddresses[0], #False)
                        setAllowEditorColors(\cntPhysNetwork[0],#False)
                        setAllowEditorColors(\lblRemoteHost[0],#False)
                        setAllowEditorColors(\lblRemotePort[0],#False)
                        setAllowEditorColors(\lblLocalPort[0],#False)
                        setAllowEditorColors(\chkNetworkDummy[0],#False)
                        setAllowEditorColors(\lblCtrlSendDelay,#False)
                        SetGadgetColor(\cntPhysNetwork[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblRemoteHost[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblRemotePort[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblLocalPort[0],#PB_Gadget_BackColor,\nPhysBackColor)
                        setOwnColor(\chkNetworkDummy[0],#PB_Gadget_BackColor,\nPhysBackColor)  ; added 2Nov2015 11.4.1.2g
                        setOwnColor(\chkNetworkDummy[0],#PB_Gadget_FrontColor,#SCS_Black)     ; added 2Nov2015 11.4.1.2g
                        SetGadgetColor(\lblCtrlSendDelay,#PB_Gadget_BackColor,\nPhysBackColor)
                      scsCloseGadgetList()
                      nTop = GadgetY(\cntPhysNetwork[0]) + GadgetHeight(\cntPhysNetwork[0]) + 8
                      
                      nLeft = GadgetX(\cboCtrlNetworkRemoteDev)
                      \chkGetRemDevScribbleStripNames=scsCheckBoxGadget2(nLeft+glBorderWidth,nTop,-1,17,Lang("WEP","chkGetRemDevScribbleStripNames"),0,"chkGetRemDevScribbleStripNames")
                      nTop + 20
                      \lblDelayBeforeReloadNames=scsTextGadget(nLeft,nTop+gnLblVOffsetC,94,15,Lang("WEP","lblDelayBeforeReloadNames"),0,"lblDelayBeforeReloadNames")
                      setGadgetWidth(\lblDelayBeforeReloadNames,50,#True)
                      \cboDelayBeforeReloadNames=scsComboBoxGadget(gnNextX+gnGap,nTop,50,21,0,"cboDelayBeforeReloadNames")
                      
                      nTop = GadgetY(\chkGetRemDevScribbleStripNames) ; the above scribble strip and reload names fields are mutually exclusive with network message responses
                      nLeft = 0
                      nWidth = GadgetWidth(\cntNetworkSettings[0])
                      nHeight = 160
                      
                      \cntCtrlNetworkRemoteDevPW=scsContainerGadget(4,nTop,\nDevDetailWidth-8,23,#PB_Container_BorderLess,"cntCtrlNetworkRemoteDevPW")
                        \lblCtrlNetworkRemoteDevPW=scsTextGadget(4,4,94,15,Lang("WEP","lblCtrlNetworkRemoteDevPW"),#PB_Text_Right,"lblCtrlNetworkRemoteDevPW")
                        setGadgetWidth(\lblCtrlNetworkRemoteDevPW,90,#True)
                        \txtCtrlNetworkRemoteDevPW=scsStringGadget(gnNextX+gnGap,0,150,21,"",0,"txtCtrlNetworkRemoteDevPW")
                        scsToolTip(\txtCtrlNetworkRemoteDevPW,Lang("WEP","txtCtrlNetworkRemoteDevPWTT"))
                      scsCloseGadgetList()
                      setVisible(\cntCtrlNetworkRemoteDevPW, #False)
                      
                      \cntNetworkMsgResponses=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntNetworkMsgResponses")
                        \lblNetworkMsgResponses=scsTextGadget(12,0,120,17,Lang("WEP","lblNetworkMsgResponses"),0,"lblNetworkMsgResponses")
                        scsSetGadgetFont(\lblNetworkMsgResponses, #SCS_FONT_GEN_BOLD)
                        setGadgetWidth(\lblNetworkMsgResponses,80,#True)
                        
                        nTop = 20
                        ; calc required width of cboNetworkMsgAction (it hasn't been created or populated yet)
                        ; this calculation based on code in setComboBoxWidth()
                        nMsgActionWidth = GetTextWidth(decodeNetworkMsgActionL(#SCS_NETWORK_ACT_READY)) + glScrollBarWidth + gl3DBorderAllowanceX + gl3DBorderAllowanceX
                        nReceiveMsgWidth = (GadgetWidth(\cntNetworkMsgResponses) - nMsgActionWidth - 120 - glScrollBarWidth - gl3DBorderAllowanceX) / 2
                        If nReceiveMsgWidth < 90
                          nReceiveMsgWidth = 90
                        EndIf
                        nReplyMsgWidth = nReceiveMsgWidth
                        
                        \lblNetworkReceiveMsg=scsTextGadget(14,nTop,nReceiveMsgWidth,15,Lang("WEP","lblNetworkReceiveMsg"),0,"lblNetworkReceiveMsg")
                        \lblNetworkMsgAction=scsTextGadget(gnNextX+gnGap,nTop,nMsgActionWidth,15,Lang("WEP","lblNetworkMsgAction"),0,"lblNetworkMsgAction")
                        \lblNetworkReplyMsg=scsTextGadget(gnNextX+gnGap,nTop,nReplyMsgWidth,15,Lang("WEP","lblNetworkReplyMsg"),0,"lblNetworkReplyMsg")
                        nTop + 15
                        nScaInnerHeight = (#SCS_MAX_NETWORK_MSG_RESPONSE + 1) * 21
                        nScaInnerWidth = GadgetX(\lblNetworkReplyMsg) + GadgetWidth(\lblNetworkReplyMsg) + 4
                        nScaWidth = nScaInnerWidth + glScrollBarWidth + gl3DBorderAllowanceX
                        \scaNetworkMsgResponses=scsScrollAreaGadget(0,nTop,nScaWidth,84,nScaInnerWidth,nScaInnerHeight,21,#PB_ScrollArea_BorderLess,"scaNetworkMsgResponses")
                          nTop = 0
                          For n = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
                            sNr = "["+n+"]"
                            \txtNetworkReceiveMsg[n]=scsStringGadget(12,nTop,nReceiveMsgWidth,21,"",0,"txtNetworkReceiveMsg"+sNr)
                            \cboNetworkMsgAction[n]=scsComboBoxGadget(gnNextX+gnGap,nTop,nMsgActionWidth,21,0,"cboNetworkMsgAction"+sNr)
                            \txtNetworkReplyMsg[n]=scsStringGadget(gnNextX+gnGap,nTop,nReplyMsgWidth,21,"",0,"txtNetworkReplyMsg"+sNr)
                            nTop + 21
                          Next n
                        scsCloseGadgetList()
                        nLeft = GadgetX(\scaNetworkMsgResponses) + GadgetWidth(\scaNetworkMsgResponses)
                        nTop = GadgetY(\scaNetworkMsgResponses)
                        nHeight = GadgetHeight(\scaNetworkMsgResponses)
                        \cntNetworkAddCRLF=scsContainerGadget(nLeft,nTop,100,nHeight,0,"cntNetworkAddCRLF")
                          nTop = (GadgetHeight(\cntNetworkAddCRLF) - 34) / 2
                          \chkNetworkReplyMsgAddCR=scsCheckBoxGadget2(12,nTop,80,17,Lang("WEP","chkNetworkReplyMsgAddCR"),0,"chkNetworkReplyMsgAddCR")
                          scsToolTip(\chkNetworkReplyMsgAddCR, Lang("WEP", "chkNetworkReplyMsgAddCRTT"))
                          nTop + 17
                          \chkNetworkReplyMsgAddLF=scsCheckBoxGadget2(12,nTop,80,17,Lang("WEP","chkNetworkReplyMsgAddLF"),0,"chkNetworkReplyMsgAddLF")
                          scsToolTip(\chkNetworkReplyMsgAddLF, Lang("WEP", "chkNetworkReplyMsgAddLFTT"))
                        scsCloseGadgetList()
                        If getGadgetReqdWidth(sProcName, \chkNetworkReplyMsgAddCR) > getGadgetReqdWidth(sProcName, \chkNetworkReplyMsgAddLF)
                          nWidth = getGadgetReqdWidth(sProcName, \chkNetworkReplyMsgAddCR)
                        Else
                          nWidth = getGadgetReqdWidth(sProcName, \chkNetworkReplyMsgAddLF)
                        EndIf
                        nWidth + (GadgetX(\chkNetworkReplyMsgAddCR) << 1) + 1
                        ResizeGadget(\cntNetworkAddCRLF,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
                      scsCloseGadgetList()
                      
                    scsCloseGadgetList()
                    setVisible(\cntNetworkSettings[0], #False)
                    
                    ; ctrl send HTTP settings
                    nCSDevTypeIndex + 1
                    \cntHTTPSettings=scsContainerGadget(4,17,\nDevDetailWidth-8,\nDevDetailHeight-19,0,"cntHTTPSettings")
                      nTop = 12
                      \lblHTTPStart=scsTextGadget(14,nTop,200,15,Lang("WEP","lblHTTPStart"),0,"lblHTTPStart")
                      nTop + 17
                      \txtHTTPStart=scsStringGadget(12,nTop,500,21,"",0,"txtHTTPStart")
                    scsCloseGadgetList()
                    setVisible(\cntHTTPSettings, #False)
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxCtrlSendDevPerProd >= 0
              ;}
              
              ; =============================================
              ;- PROD Cue Control Devices tab within \pnlDevs
              ; =============================================
              ;{
              If grLicInfo\nMaxCueCtrlDev >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_CUE_CTRL])
                sTabDesc = "\pnlDevs tab: devices - cue ctrl"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("DevGrp", "CueCtrl"), #SCS_PROD_TAB_CUE_DEVS)
                
                \cntTabCueDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabCueDevs")
                  \lblCueInfo=scsTextGadget(47,4,170,18,Lang("WEP","lblCueInfo"),0,"lblCueInfo")
                  scsSetGadgetFont(\lblCueInfo, #SCS_FONT_GEN_ITALIC)
                  \lblCueHdg=scsTextGadget(47,22,160,32,Lang("WEP","lblCueHdg"),#PB_Text_Center,"lblCueHdg")
                  scsSetGadgetFont(\lblCueHdg, #SCS_FONT_GEN_BOLDUL)
                  
                  \lblCueDevType=scsTextGadget(65,55,100,17,Lang("WEP","lblDevType"),#PB_Text_Center,"lblCueDevType")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_CUE_DEVS, 215)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntDevMap[#SCS_PROD_TAB_INDEX_CUE_DEVS])
                  \cntCuePhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntCuePhysDevLabels")
                    nTop = 2
                    \lblCuePhysical=scsTextGadget(8,nTop,300,17,Lang("WEP","lblPhysical"),0,"lblCuePhysical")
                    \lblCueActive=scsTextGadget(gnNextX,nTop,106,17,Lang("WEP","lblActive"),0,"lblCueActive")
                    setGadgetWidth(\lblCueActive,-1,#True)
                    setAllowEditorColors(\cntCuePhysDevLabels,#False)
                    setAllowEditorColors(\lblCuePhysical,#False)
                    setAllowEditorColors(\lblCueActive,#False)
                    SetGadgetColor(\cntCuePhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblCuePhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblCueActive,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntCuePhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntCuePhysDevLabels
                  \lnCueVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnCueVertSep")
                  \lnCueVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnCueVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                  
                  ; cue ctrl devices
                  nScaCueDevsHeight = (4 * nDevRowHeight) + nScaDevsExtraDepth ; set for 4 rows plus a lower border area
                  \nDevInnerHeight = (grLicInfo\nMaxCueCtrlDev + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaCueDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,nScaCueDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaCueDevs")
                    \nVertSepLeft = 0
                    \lnCueVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnCueVertSepInSCA") ; line to the left of the physical device combobox
                    \lnCueVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnCueVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  \nDevDetailTop = \nScaDevsTop + nScaCueDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  nSettingsTop = 17
                  nSettingsHeight = \nDevDetailHeight - nSettingsTop
                  
                  ; cue ctrl dev detail
                  \cntCueDevDetail=scsContainerGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,0,"cntCueDevDetail")
                    \lblCueDevDetail=scsTextGadget(0,0,\nDevDetailWidth,15,"",0,"lblCueDevDetail")
                    setReverseEditorColors(\lblCueDevDetail, #True)
                    
                    ; cue ctrl MIDI settings
                    ; debugMsg(sProcName, "MIDI settings")
                    \cntMIDISettings[1]=scsContainerGadget(0,nSettingsTop,\nDevDetailWidth,nSettingsHeight,0,"cntMIDISettings[1]")
                      \cntPhysMidi[1]=scsContainerGadget(2,4,185,45,#PB_Container_Flat,"cntPhysMidi[1]")
                        nTop = 3
                        \lblMidiInPort=scsTextGadget(4,nTop,72,15,Lang("WEP","lblMidiInPort"),0,"lblMidiInPort")
                        nTop + 16
                        \cboMidiInPort=scsComboBoxGadget(4,nTop,171,21,0,"cboMidiInPort")
                        scsToolTip(\cboMidiInPort,LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblMidiInPort))))
                        setAllowEditorColors(\cntPhysMidi[1],#False)
                        setAllowEditorColors(\lblMidiInPort,#False)
                        SetGadgetColor(\cntPhysMidi[1],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblMidiInPort,#PB_Gadget_BackColor,\nPhysBackColor)
                      scsCloseGadgetList()
                      nTop = GadgetY(\cntPhysMidi[1]) + GadgetHeight(\cntPhysMidi[1]) + 4
                      nHeight = nSettingsHeight - nTop
                      \cntMidiCueCtrl=scsContainerGadget(0,nTop,189,nHeight,0,"cntMidiCueCtrl")
                        nTop = 0
                        \lblCtrlMethod=scsTextGadget(4,nTop,101,15,Lang("WEP","lblCtrlMethod"),0,"lblCtrlMethod")
                        nTop + 16
                        \cboCtrlMethod=scsComboBoxGadget(4,nTop,180,21,0,"cboCtrlMethod")
                        scsToolTip(\cboCtrlMethod,Lang("WEP","cboCtrlMethodTT"))
                        
                        ; MSC or MMC
                        nTop + 25
                        \cntMSC=scsContainerGadget(0,nTop,185,91,0,"cntMSC")
                          nTop = 0
                          \lblMidiDevId=scsTextGadget(4,nTop+4,102,15,Lang("WEP","lblMidiDevId"),#PB_Text_Right,"lblMidiDevId")
                          \cboMidiDevId=scsComboBoxGadget(111,nTop,73,21,0,"cboMidiDevId")
                          scsToolTip(\cboMidiDevId,Lang("WEP","cboMidiDevIdTT"))
                          ; nb Command Format only applicable to MSC
                          nTop + 25
                          \lblMSCCommandFormat=scsTextGadget(4,nTop,146,15,Lang("WEP","lblMSCCommandFormat"),0,"lblMSCCommandFormat")
                          nTop + 16
                          \cboMSCCommandFormat=scsComboBoxGadget(4,nTop,180,21,0,"cboMSCCommandFormat")
                          scsToolTip(\cboMSCCommandFormat,Lang("WEP","cboMSCCommandFormatTT"))
                          ; nb GoMacro only applicable to MSC
                          nTop + 25
                          \lblGoMacro=scsTextGadget(4,nTop+4,102,15,Lang("WEP","lblGoMacro"), #PB_Text_Right,"lblGoMacro")
                          setVisible(\lblGoMacro, #False)
                          \cboGoMacro=scsComboBoxGadget(111,nTop,73,21,0,"cboGoMacro")
                          scsToolTip(\cboGoMacro,Lang("WEP","txtGoMacroTT"))
                          setVisible(\cboGoMacro, #False)
                          ; Added 16Nov2020 11.8.3.3ah
                          ; nb 'Apply Fade for Stop' only applicable to MMC
                          nTop = 25
                          \chkMMCApplyFadeForStop=scsCheckBoxGadget2(4,nTop,180,17,Lang("WEP","chkMMCApplyFadeForStop"),0,"chkMMCApplyFadeForStop")
                          scsToolTip(\chkMMCApplyFadeForStop,Lang("WEP","chkMMCApplyFadeForStopTT"))
                          setVisible(\chkMMCApplyFadeForStop,#False)
                        scsCloseGadgetList()
                        setVisible(\cntMSC, #False)
                        
                        ; not MSC or MMC
                        nTop = GadgetY(\cntMSC)
                        \cntNonMSC=scsContainerGadget(0,nTop,185,91,0,"cntNonMSC")
                          nTop = 0
                          \lblMidiChannel=scsTextGadget(4,nTop+4,102,15,Lang("WEP","lblMidiChannel"),#PB_Text_Right,"lblMidiChannel")
                          \cboMidiChannel=scsComboBoxGadget(111,nTop,73,21,0,"cboMidiChannel")
                          scsToolTip(\cboMidiChannel,Lang("WEP","cboMidiChannelTT"))
                        scsCloseGadgetList()
                        setVisible(\cntNonMSC, #False)
                        
                        nTop = GadgetHeight(\cntMidiCueCtrl) - 46
                        \lnMidi=scsLineGadget(4,nTop,181,1,#SCS_Light_Grey,0,"lnMidi")
                        \btnTestMidi=scsButtonGadget(33,nTop+7,122,gnBtnHeight,LangEllipsis("WEP","btnTestMidi"),0,"btnTestMidi")
                        scsToolTip(\btnTestMidi,Lang("WEP","btnTestMidiTT"))
                        
                      scsCloseGadgetList()
                      
                      ; cue ctrl MIDI Message Assignments
                      nLeft = 191
                      nWidth = \nDevDetailWidth - nLeft - 4
                      nHeight = nSettingsHeight - 127   ; fits 5 'special command' lines in the visible area
                      \cntMidiAssigns=scsContainerGadget(nLeft,0,nWidth,nHeight,0,"cntMidiAssigns")
                        \frMidiAssigns=scsFrameGadget(0,0,nWidth,nHeight,Lang("WEP","frMidiAssigns"),0,"frMidiAssigns")
                        \edgMidiAssigns=scsEditorGadget(4,15,nWidth-8,nHeight-15,#PB_Editor_ReadOnly,"edgMidiAssigns")
                        scsSetGadgetFont(\edgMidiAssigns,#SCS_FONT_WOP_LISTS)
                        ; setEnabled(\edgMidiAssigns, #False) ; do not disable because that also disables the gadget's scrollbar
                      scsCloseGadgetList()
                      
                      ; cue ctrl special commands (MIDI)
                      nTop = GadgetY(\cntMidiAssigns) + GadgetHeight(\cntMidiAssigns) + 1
                      nHeight = GadgetHeight(\cntMIDISettings[1]) - nTop  ; make height so that the bottom of the container and frame match the bottom of \cntMIDISettings[1]
                      \cntMidiSpecial=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntMidiSpecial")
                        \frMidiSpecial=scsFrameGadget(0,0,nWidth,nHeight,Lang("WEP","frMidiSpecial"),0,"frMidiSpecial")
                        ; scsSetGadgetFont(\frMidiSpecial,#SCS_FONT_GEN_BOLD)
                        nInnerWidth = (nWidth-8) - glScrollBarWidth - gl3DBorderAllowanceX
                        nInnerHeight = (gnMaxMidiCommand + 1) * 21
                        nTop = 17
                        nHeight = GadgetHeight(\cntMidiSpecial) - nTop - 4
                        \scaMidiSpecial=scsScrollAreaGadget(0,18,nWidth-4,nHeight,nInnerWidth,nInnerHeight,21,#PB_ScrollArea_BorderLess,"scaMidiSpecial")
                          ; Changes 6Jun2022
                          For n = 0 To gnMaxMidiCommand
                            nTop = n * 21
                            sNr = "["+n+"]"
                            \lblCommand[n]=scsTextGadget(0,nTop+4,131,15,"", #PB_Text_Right,"lblCommand"+sNr)
                            \cboMidiCommand[n]=scsComboBoxGadget(136,nTop,146,21,0,"cboMidiCommand"+sNr)
                            \lblCC[n]=scsTextGadget(284,nTop+4,28,15,"", #PB_Text_Right,"lblCC"+sNr)
                            \cboMidiCC[n]=scsComboBoxGadget(313,nTop,42,21,0,"cboMidiCC"+sNr)
                            \cboMidiVV[n]=scsComboBoxGadget(356,nTop,42,21,0,"cboMidiVV"+sNr)
                          Next n
                          nTop = 0 ; nb 'Y' of the following two gadgets will be changed dynamically
                          \lblThresholdVV=scsTextGadget(284,nTop+4,70,15,Lang("MIDI","Threshold")+" vv",#PB_Text_Right,"lblThresholdVV")
                          \cboThresholdVV=scsComboBoxGadget(356,nTop,38,21,0,"cboThresholdVV")
                          ; End changes 6Jun2022
                        scsCloseGadgetList()
                      scsCloseGadgetList() ; cntMidiSpecial
                      
                    scsCloseGadgetList()
                    setVisible(\cntMIDISettings[1], #False)
                    
                    ; cue ctrl RS232 settings
                    ; debugMsg(sProcName, "RS232 settings")
                    \cntRS232Settings[1]=scsContainerGadget(0,nSettingsTop,\nDevDetailWidth,nSettingsHeight,0,"cntRS232Settings[1]")
                      \cntSettingsReqd=scsContainerGadget(0,0,290,nSettingsHeight,0,"cntSettingsReqd")
                        \cntPhysRS232[1]=scsContainerGadget(2,4,266,29,#PB_Container_Flat,"cntPhysRS232[1]")
                          \lblRS232Port[1]=scsTextGadget(8,7,72,15,Lang("WEP","lblRS232Port"), #PB_Text_Right,"lblRS232Port[1]")
                          \cboRS232Port[1]=scsComboBoxGadget(gnNextX+7,3,120,21,0,"cboRS232Port[1]")
                          scsToolTip(\cboRS232Port[1],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblRS232Port[1]))))
                          setAllowEditorColors(\cntPhysRS232[1],#False)
                          setAllowEditorColors(\lblRS232Port[1],#False)
                          SetGadgetColor(\cntPhysRS232[1],#PB_Gadget_BackColor,\nPhysBackColor)
                          SetGadgetColor(\lblRS232Port[1],#PB_Gadget_BackColor,\nPhysBackColor)
;                           ResizeGadget(\cntPhysRS232[1],#PB_Ignore,#PB_Ignore,gnNextX+12,#PB_Ignore)
                        scsCloseGadgetList()
                        nTop = GadgetY(\cntPhysRS232[1]) + GadgetHeight(\cntPhysRS232[1]) + 4
                        \lblBaudRate[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblBaudRate"), #PB_Text_Right,"lblBaudRate[1]")
                        \cboRS232BaudRate[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232BaudRate[1]")
                        nTop + 21
                        \lblDataBits[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblDataBits"), #PB_Text_Right,"lblDataBits[1]")
                        \cboRS232DataBits[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232DataBits[1]")
                        nTop + 21
                        \lblStopBits[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblStopBits"), #PB_Text_Right,"lblStopBits[1]")
                        \cboRS232StopBits[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232StopBits[1]")
                        nTop + 21
                        \lblParity[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblParity"), #PB_Text_Right,"lblParity[1]")
                        \cboRS232Parity[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232Parity[1]")
                        nTop + 21
                        \lblRS232Handshaking[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblRS232Handshaking"), #PB_Text_Right,"lblRS232Handshaking[1]")
                        \cboRS232Handshaking[1]=scsComboBoxGadget(83,nTop,200,21,0,"cboRS232Handshaking[1]")
                        nTop + 21
                        \lblRS232RTSEnable[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblRS232RTSEnable"), #PB_Text_Right,"lblRS232RTSEnable[1]")
                        \cboRS232RTSEnable[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232RTSEnable[1]")
                        scsToolTip(\cboRS232RTSEnable[1],Lang("WEP","cboRS232RTSEnableTT"))
                        nTop + 21
                        \lblRS232DTREnable[1]=scsTextGadget(4,nTop+4,72,15,Lang("WEP","lblRS232DTREnable"), #PB_Text_Right,"lblRS232DTREnable[1]")
                        \cboRS232DTREnable[1]=scsComboBoxGadget(83,nTop,81,21,0,"cboRS232DTREnable[1]")
                        scsToolTip(\cboRS232DTREnable[1],Lang("WEP","cboRS232DTREnableTT"))
                        nTop + 27
                        \btnRS232Default[1]=scsButtonGadget(25,nTop,240,gnBtnHeight,Lang("WEP","btnRS232Default"),0,"btnRS232Default[1]")
                        
                        nTop = GadgetHeight(\cntSettingsReqd) - 46
                        \lnRS232=scsLineGadget(4,nTop,280,1,#SCS_Light_Grey,0,"lnRS232")
                        \btnTestRS232=scsButtonGadget(83,nTop+7,124,gnBtnHeight,LangEllipsis("WEP","btnTestRS232"),0,"btnTestRS232")
                        scsToolTip(\btnTestRS232,Lang("WEP","btnTestRS232TT"))
                      scsCloseGadgetList()
                      
                      ; cue ctrl RS232 message formats
                      nLeft = GadgetWidth(\cntSettingsReqd) + 2
                      nWidth = \nDevDetailWidth - nLeft - 2
                      \cntRS232Assigns=scsContainerGadget(nLeft,0,nWidth,nSettingsHeight,0,"cntRS232Assigns")
                        \frRS232Assigns=scsFrameGadget(0,0,nWidth,nSettingsHeight,Lang("WEP","frRS232Assigns"),0,"frRS232Assigns")
                        \edgRS232Assigns=scsEditorGadget(4,15,nWidth-8,nSettingsHeight-20,#PB_Editor_ReadOnly,"edgRS232Assigns")
                        scsSetGadgetFont(\edgRS232Assigns,#SCS_FONT_WOP_LISTS)
                        ; setEnabled(\edgRS232Assigns, #False) ; do not disable because that also disables the gadget's scrollbar
                      scsCloseGadgetList()
                      
                    scsCloseGadgetList()
                    setVisible(\cntRS232Settings[1], #False)
                    
                    ; cue ctrl Network settings
                    ; debugMsg(sProcName, "Network settings")
                    \cntNetworkSettings[1]=scsContainerGadget(0,nSettingsTop,\nDevDetailWidth,nSettingsHeight,0,"cntNetworkSettings[1]")
                      nTop = 5
                      \lblCueNetworkRemoteDev=scsTextGadget(4,nTop+4,94,17,Lang("WEP","lblRemoteDev"),#PB_Text_Right,"lblCueNetworkRemoteDev")
                      \cboCueNetworkRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboCueNetworkRemoteDev")
                      nTop + 23
                      \lblNetworkProtocol[1]=scsTextGadget(4,nTop+4,94,17,Lang("Network","lblNetworkProtocol"),#PB_Text_Right,"lblNetworkProtocol[1]")
                      \cboNetworkProtocol[1]=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboNetworkProtocol[1]")
                      nTop + 23
                      \lblNetworkRole[1]=scsTextGadget(4,nTop+4,94,17,Lang("Network","lblNetworkRole"),#PB_Text_Right,"lblNetworkRole[1]")
                      \cboNetworkRole[1]=scsComboBoxGadget(gnNextX+gnGap,nTop,40,21,0,"cboNetworkRole[1]")
                      nTop + 25
;                       \cntPhysNetwork[1]=scsContainerGadget(2,nTop,266,52,#PB_Container_Flat,"cntPhysNetwork[1]")
                      \cntPhysNetwork[1]=scsContainerGadget(2,nTop,266,83,#PB_Container_Flat,"cntPhysNetwork[1]")  ; modified 5Nov2015 11.4.1.2h
                        nTop = 3
                        \chkNetworkDummy[1]=scsCheckBoxGadget2(4,nTop+2,120,17,Lang("Network","DummyConnection"),0,"chkNetworkDummy[1]") ; added 5Nov2015 11.4.1.2h
                        nTop + 23  ; added 5Nov2015 11.4.1.2h
                        \lblRemoteHost[1]=scsTextGadget(4,nTop+4,94,29,Lang("WEP","lblRemoteHost"),0,"lblRemoteHost[1]")
                        ; \lblRemoteHost[1]=scsTextGadget(gnNextX+12,nTop+4,94,15,Lang("WEP","lblRemoteHost"),0,"lblRemoteHost[1]") ; modified left 5Nov2015 11.4.1.2h
                        setGadgetWidth(\lblRemoteHost[1],-1,#True)
                        nMaxWidth = GadgetWidth(\cntPhysNetwork[1]) - GadgetX(\lblRemoteHost[1]) - 100 - gnGap  ; 100 = width of txtRemoteHost[1]
                        If GadgetWidth(\lblRemoteHost[1]) > nMaxWidth
                          ResizeGadget(\lblRemoteHost[1],#PB_Ignore,#PB_Ignore,nMaxWidth,#PB_Ignore)
                          gnNextX = GadgetX(\lblRemoteHost[1]) + GadgetWidth(\lblRemoteHost[1])
                        EndIf
                        \txtRemoteHost[1]=scsStringGadget(gnNextX+gnGap,nTop,100,21,"",0,"txtRemoteHost[1]")
                        ; scsToolTip(\txtRemoteHost[1],Lang("WEP","txtRemoteHostTT"))
;                         ResizeGadget(\cntPhysNetwork[1],#PB_Ignore,#PB_Ignore,gnNextX+12,#PB_Ignore)
                        setVisible(\lblRemoteHost[1], #False)
                        setVisible(\txtRemoteHost[1], #False)
                        nTop + 23
                        \lblRemotePort[1]=scsTextGadget(GadgetX(\lblRemoteHost[1]),nTop+4,GadgetWidth(\lblRemoteHost[1]),15,Lang("WEP","lblRemotePort"),#PB_Text_Right,"lblRemotePort[1]")
                        \txtRemotePort[1]=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtRemotePort[1]")
                        ; scsToolTip(\txtRemotePort[1],Lang("WEP","txtRemotePortTT"))
                        setVisible(\lblRemotePort[1], #False)
                        setVisible(\txtRemotePort[1], #False)
                        ; nTop = 8 ; del 5Nov2015 11.4.1.2h (replaced by next line)
                        nTop = GadgetY(\chkNetworkDummy[1]) + 23 ; added 5Nov2015 11.4.1.2h
                        \lblLocalPort[1]=scsTextGadget(0,nTop+4,94,15,Lang("Network","lblLocalPort"),#PB_Text_Right,"lblLocalPort[1]")
                        ; \lblLocalPort[1]=scsTextGadget(GadgetX(\lblRemoteHost[1]),nTop+4,94,15,Lang("WEP","lblLocalPort"),#PB_Text_Right,"lblLocalPort[1]") ; modified 5Nov2015 11.4.1.2h
                        \txtLocalPort[1]=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtLocalPort[1]")
                        scsToolTip(\txtLocalPort[1],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblLocalPort[1]))))
                        setVisible(\lblLocalPort[1], #False)
                        setVisible(\txtLocalPort[1], #False)
                        \btnCompIPAddresses[1]=scsButtonGadget(60,nTop+26,200,21,LangEllipsis("Network","CompIPAddresses"),0,"btnCompIPAddresses[1]")
                        setGadgetWidth(\btnCompIPAddresses[1],50)
                        setVisible(\btnCompIPAddresses[1], #False)
                        setAllowEditorColors(\cntPhysNetwork[1],#False)
                        setAllowEditorColors(\lblRemoteHost[1],#False)
                        setAllowEditorColors(\lblRemotePort[1],#False)
                        setAllowEditorColors(\lblLocalPort[1],#False)
                        setAllowEditorColors(\chkNetworkDummy[1],#False)  ; added 5Nov2015 11.4.1.2h
                        SetGadgetColor(\cntPhysNetwork[1],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblRemoteHost[1],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblRemotePort[1],#PB_Gadget_BackColor,\nPhysBackColor)
                        SetGadgetColor(\lblLocalPort[1],#PB_Gadget_BackColor,\nPhysBackColor)
                        setOwnColor(\chkNetworkDummy[1],#PB_Gadget_BackColor,\nPhysBackColor)  ; added 5Nov2015 11.4.1.2h
                        setOwnColor(\chkNetworkDummy[1],#PB_Gadget_FrontColor,#SCS_Black)     ; added 5Nov2015 11.4.1.2h
                      scsCloseGadgetList()
                      nTop = GadgetY(\cntPhysNetwork[1]) + GadgetHeight(\cntPhysNetwork[1]) + 8
                      \lnNetwork=scsLineGadget(4,nTop,262,1,#SCS_Light_Grey,0,"lnNetwork")
                      \btnTestNetwork=scsButtonGadget(65,nTop+7,150,gnBtnHeight,LangEllipsis("WEP","btnTestNetwork"),0,"btnTestNetwork")
                      scsToolTip(\btnTestNetwork,Lang("WEP","btnTestNetworkTT"))
                      
                      nLeft = 272
                      nWidth = \nDevDetailWidth - nLeft - 2
                      nHeight = nSettingsHeight - 148   ; fits 6 'special command' lines in the visible area
                      \cntNetworkAssigns=scsContainerGadget(nLeft,0,nWidth,nHeight,0,"cntNetworkAssigns") ; Network Message Assignments
                        \frNetworkAssigns=scsFrameGadget(0,0,nWidth,nHeight,Lang("WEP","frNetworkAssigns"),0,"frNetworkAssigns")
                        \edgNetworkAssigns=scsEditorGadget(2,15,nWidth-4,nHeight-45,#PB_Editor_ReadOnly,"edgNetworkAssigns")
                        scsSetGadgetFont(\edgNetworkAssigns,#SCS_FONT_WOP_LISTS)
                        ; setEnabled(\edgNetworkAssigns, #False) ; do not disable because that also disables the gadget's scrollbar
                        nTop = GadgetHeight(\cntNetworkAssigns) - 23
                        \cboNetworkMsgFormat=scsComboBoxGadget(24,nTop,120,21)
                      scsCloseGadgetList()
                      ; cue ctrl special commands (X32)
                      nTop = GadgetY(\cntNetworkAssigns) + GadgetHeight(\cntNetworkAssigns) + 1
                      nHeight = GadgetHeight(\cntNetworkSettings[1]) - nTop  ; make height so that the bottom of the container and frame match the bottom of \cntNetworkSettings[1]
                      \cntX32Special=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntX32Special")
                        \frX32Special=scsFrameGadget(0,0,nWidth,nHeight,Lang("WEP","frX32Special"),0,"frX32Special")
                        nInnerWidth = (nWidth-8) - glScrollBarWidth - gl3DBorderAllowanceX
                        nInnerHeight = (#SCS_MAX_X32_COMMAND + 1) * 21
                        nTop = 17
                        nHeight = GadgetHeight(\cntX32Special) - nTop - 4
                        \scaX32Special=scsScrollAreaGadget(0,18,nWidth-4,nHeight,nInnerWidth,nInnerHeight,21,#PB_ScrollArea_BorderLess,"scaX32Special")
                          ; \scaX32Special=scsScrollAreaGadget(0,18,nWidth-4,nHeight,nInnerWidth,nInnerHeight,21,#PB_ScrollArea_Flat,"scaX32Special")
                          For n = 0 To #SCS_MAX_X32_COMMAND
                            nTop = n * 21
                            sNr = "["+n+"]"
                            \lblX32Command[n]=scsTextGadget(0,nTop+4,131,15,"", #PB_Text_Right,"lblX32Command"+sNr)
                            \cboX32Command[n]=scsComboBoxGadget(136,nTop,146,21,0,"cboX32Command"+sNr)
                          Next n
                        scsCloseGadgetList()
                      scsCloseGadgetList() ; cntX32Special
                      
                    scsCloseGadgetList()
                    setVisible(\cntNetworkSettings[1], #False)
                    
                    ; cue ctrl DMX settings
                    ; debugMsg(sProcName, "DMX settings")
                    \cntDMXSettings[1]=scsContainerGadget(0,nSettingsTop,\nDevDetailWidth,nSettingsHeight,0,"cntDMXSettings[1]")
                      If grLicInfo\bCCDMXAvailable
                        \cntPhysDMX[1]=scsContainerGadget(2,4,210,66,#PB_Container_Flat,"cntPhysDMX[1]")
                          setAllowEditorColors(\cntPhysDMX[1],#False)
                          SetGadgetColor(\cntPhysDMX[1],#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop = 3
                          \lblDMXPhysDev[1]=scsTextGadget(4,nTop,181,15,Lang("WEP","lblPhysical"),0,"lblDMXPhysDev[1]")
                          setAllowEditorColors(\lblDMXPhysDev[1],#False)
                          SetGadgetColor(\lblDMXPhysDev[1],#PB_Gadget_BackColor,\nPhysBackColor)
                          nTop + 16
                          \cboDMXPhysDev[1]=scsComboBoxGadget(4,nTop,181,21,0,"cboDMXPhysDev[1]")
                          scsToolTip(\cboDMXPhysDev[1],LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblDMXPhysDev[1]))))
                          nTop + 21
                          \lblDMXPort[1]=scsTextGadget(4,nTop+4,80,15,Lang("WEP","lblDMXPort"),#PB_Text_Right,"lblDMXPort[1]")
                          setGadgetWidth(\lblDMXPort[1],-1,#True)
                          setAllowEditorColors(\lblDMXPort[1],#False)
                          SetGadgetColor(\lblDMXPort[1],#PB_Gadget_BackColor,\nPhysBackColor)
                          \cboDMXPort[1]=scsComboBoxGadget(gnNextX+gnGap,nTop,50,21,0,"cboDMXPort[1]")
                        scsCloseGadgetList()
                        nTop = GadgetY(\cntPhysDMX[1]) + GadgetHeight(\cntPhysDMX[1]) + 3
                        nCntLeft = 2
                        nCntWidth = 216 - nCntLeft - 2  ; nb 216 will be the nLeft position of \cntDMXCommands
                        \cntDMXPref[1]=scsContainerGadget(nCntLeft,nTop,nCntWidth,46,#PB_Container_Flat,"cntDMXPref[1]")
                          nTop = 2
                          nLeft = 2
                          nWidth = nCntWidth - nLeft - nLeft
                          nHeight = 15
                          \lblDMXPref[1]=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WEP","lblDMXPref"),0,"lblDMXPref[1]")
                          scsSetGadgetFont(\lblDMXPref[1], #SCS_FONT_GEN_UL)
                          
                          nTop + nHeight + 2
                          \optDMXInPref[0]=scsOptionGadget(nLeft,nTop,58,21,"0-255","optDMXInPref[0]")
                          SGS(\optDMXInPref[0], #True)
                          \optDMXInPref[1]=scsOptionGadget(gnNextX + gnGap,nTop,58,21,"%","optDMXInPref[1]")
                        scsCloseGadgetList()
                        
                        nTop = GadgetY(\cntDMXPref[1]) + GadgetHeight(\cntDMXPref[1]) + 3
                        \cntDMXTrgCtrl=scsContainerGadget(nCntLeft,nTop,nCntWidth,152,#PB_Container_Flat,"cntDMXTrgCtrl")
                          nTop = 2
                          nLeft = 2
                          nWidth = nCntWidth - nLeft - nLeft
                          nHeight = 15
                          \lblDMXTrgCtrl=scsTextGadget(nLeft, nTop, nWidth, nHeight, Lang("WEP","lblDMXTrgCtrl"),0,"lblDMXTrgCtrl")
                          scsSetGadgetFont(\lblDMXTrgCtrl, #SCS_FONT_GEN_UL)
                          
                          nTop + nHeight + 2
                          \optDMXTrgCtrl[0]=scsOptionGadget(nLeft,nTop,nWidth,34,"","optDMXTrgCtrl[0]")
                          SGT(\optDMXTrgCtrl[0], WordWrapW(#WED, \optDMXTrgCtrl[0], Lang("WEP","optDMXTrgCtrl[0]"), nWidth - 15))
                          SetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[0]),#GWL_STYLE,GetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[0]),#GWL_STYLE)|$2000)
                          SGS(\optDMXTrgCtrl[0], #True)
                          
                          nTop + GadgetHeight(\optDMXTrgCtrl[0])
                          \optDMXTrgCtrl[1]=scsOptionGadget(nLeft,nTop,nWidth,34,"","optDMXTrgCtrl[1]")
                          SGT(\optDMXTrgCtrl[1], WordWrapW(#WED, \optDMXTrgCtrl[1], Lang("WEP","optDMXTrgCtrl[1]"), nWidth - 15))
                          SetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[1]),#GWL_STYLE,GetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[1]),#GWL_STYLE)|$2000)
                          
                          nTop + GadgetHeight(\optDMXTrgCtrl[1])
                          \optDMXTrgCtrl[2]=scsOptionGadget(nLeft,nTop,nWidth,34,"","optDMXTrgCtrl[2]")
                          SGT(\optDMXTrgCtrl[2], WordWrapW(#WED, \optDMXTrgCtrl[2], Lang("WEP","optDMXTrgCtrl[2]"), nWidth - 15))
                          SetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[2]),#GWL_STYLE,GetWindowLongPtr_(GadgetID(\optDMXTrgCtrl[2]),#GWL_STYLE)|$2000)
                          
                          nTop + GadgetHeight(\optDMXTrgCtrl[2]) + 4
                          \lblDMXTrgValue=scsTextGadget(12,nTop+gnLblVOffsetS,100,15,"* "+Lang("WEP","lblDMXTrgValue"),#PB_Text_Right,"lblDMXTrgValue")
                          nWidth = GadgetWidth(\lblDMXTrgValue, #PB_Gadget_RequiredSize)
                          ResizeGadget(\lblDMXTrgValue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
                          nLeft = GadgetX(\lblDMXTrgValue) + GadgetWidth(\lblDMXTrgValue) + gnGap
                          \cboDMXTrgValue=scsComboBoxGadget(nLeft,nTop,60,21,0,"cboDMXTrgValue")
                        scsCloseGadgetList()
                        
                        nTop = GadgetY(\cntDMXTrgCtrl) + GadgetHeight(\cntDMXTrgCtrl) + 3
                        \btnTestDMX=scsButtonGadget(47,nTop,122,gnBtnHeight,LangEllipsis("WEP","btnTestDMX"),0,"btnTestDMX")
                        scsToolTip(\btnTestDMX,Lang("WEP","btnTestDMXTT"))
                        
                        nLeft = 216
                        nWidth = \nDevDetailWidth - nLeft - 2
                        \cntDMXCommands=scsContainerGadget(nLeft,0,nWidth,nSettingsHeight,0,"cntDMXCommands")
                          \frDMXCommands=scsFrameGadget(0,0,nWidth,nSettingsHeight,Lang("WEP","frDMXCommands"),0,"frDMXCommands")
                          \lblDMXChannel=scsTextGadget(166,22,76,15,Lang("WEP","lblDMXChannel"),0,"lblDMXChannel")
                          scsSetGadgetFont(\lblDMXChannel,#SCS_FONT_GEN_UL)
                          For n = 0 To #SCS_MAX_DMX_COMMAND
                            nTop = 40 + (n * 22)
                            sNr = "[" + n + "]"
                            \lblDMXCommand[n]=scsTextGadget(27,nTop+4,132,15,"",#PB_Text_Right,"lblDMXCommand"+sNr)
                            \txtDMXChannel[n]=scsStringGadget(166,nTop,69,21,"",#PB_String_Numeric,"txtDMXChannel"+sNr)
                          Next n
                        scsCloseGadgetList()
                        
                      EndIf
                    scsCloseGadgetList()
                    setVisible(\cntDMXSettings[1], #False)
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxCueCtrlDev >= 0
              ;}
              
              ; =====================================
              ;- PROD Live Inputs tab within \pnlDevs
              ; =====================================
              ;{
              If grLicInfo\nMaxLiveDevPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_LIVE_INPUT])
                sTabDesc = "\pnlDevs tab: devices - live input"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("WEP","LiveInputs"), #SCS_PROD_TAB_LIVE_DEVS)
                
                \cntTabLiveDevs=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabLiveDevs")
                  \lblInputsReqd=scsTextGadget(17,24,189,49,Lang("WEP","lblInputsReqd"),#PB_Text_Right,"lblInputsReqd")
                  scsSetGadgetFont(\lblInputsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  nTop = 73
                  \lblLiveDevName=scsTextGadget(53,nTop,88,26,Lang("WEP","lblDevName"),#PB_Text_Center,"lblLiveDevName")
                  \lblNumInputChans=scsTextGadget(141,nTop,61,26,Lang("WEP","lblNumInputChans"),#PB_Text_Center,"lblNumInputChans")
                  
                  createWEPDevMapInfo(#SCS_PROD_TAB_INDEX_LIVE_DEVS, 214)
                  createWEPAudioDriverInfo(#SCS_PROD_TAB_INDEX_LIVE_DEVS)
                  setWEPPhysDevLabelsLeftTopAndWidth(\cntAudioDriver[#SCS_PROD_TAB_INDEX_LIVE_DEVS])
                  \cntLivePhysDevLabels=scsContainerGadget(nLeft,nTop,nWidth,21,#PB_Container_BorderLess,"cntLivePhysDevLabels")
                    nTop = 2
                    \lblLivePhysical=scsTextGadget(8,nTop,160,17,Lang("WEP","lblPhysical"),0,"lblLivePhysical")
                    \lblInputRange=scsTextGadget(gnNextX+2,nTop,51,17,Lang("WEP","lblInputRange"),0,"lblInputRange")
                    \lblInputGain=scsTextGadget(gnNextX+2,nTop,94,17,Lang("WEP","lblInputGain"),#PB_Text_Center,"lblInputGain")
                    \lblInputGainDB=scsTextGadget(gnNextX+14,nTop,17,17,"dB",#PB_Text_Center,"lblInputGainDB")
                    \lblLiveActive=scsTextGadget(gnNextX+8,nTop,106,17,Lang("WEP","lblActive"),0,"lblLiveActive")
                    setGadgetWidth(\lblLiveActive,-1,#True)
                    setAllowEditorColors(\cntLivePhysDevLabels,#False)
                    setAllowEditorColors(\lblLivePhysical,#False)
                    setAllowEditorColors(\lblInputRange,#False)
                    setAllowEditorColors(\lblInputGain,#False)
                    setAllowEditorColors(\lblInputGainDB,#False)
                    setAllowEditorColors(\lblLiveActive,#False)
                    SetGadgetColor(\cntLivePhysDevLabels,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblLivePhysical,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblInputRange,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblInputGain,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblInputGainDB,#PB_Gadget_BackColor,\nPhysBackColor)
                    SetGadgetColor(\lblLiveActive,#PB_Gadget_BackColor,\nPhysBackColor)
                  scsCloseGadgetList()
                  ; create vertical lines to the left and right of \cntLivePhysDevLabels (the container gadget just created above)
                  nCntGadgetNo = \cntLivePhysDevLabels
                  \lnLiveVertSep=scsLineGadget(GadgetX(nCntGadgetNo)-1,GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnLiveVertSep")
                  \lnLiveVertRight1=scsLineGadget(GadgetX(nCntGadgetNo)+GadgetWidth(nCntGadgetNo),GadgetY(nCntGadgetNo),1,GadgetHeight(nCntGadgetNo),#SCS_Line_Color,0,"lnLiveVertRight1")
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo)
                  
                  ; device sidebar
                  \cntLiveDevSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntLiveDevSideBar")
                    \imgLiveButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgLiveButtonTBS[0]")
                    \imgLiveButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgLiveButtonTBS[1]")
                    \imgLiveButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgLiveButtonTBS[2]")
                    \imgLiveButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgLiveButtonTBS[3]")
                  scsCloseGadgetList() ; cntLiveDevSideBar
                  
                  ; devices
                  \nDevInnerHeight = (grLicInfo\nMaxLiveDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaLiveDevs=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,\nScaDevsHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaLiveDevs")
                    \nVertSepLeft = 0
                    \lnLiveVertSepInSCA=scsLineGadget(\nVertSepLeft,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnLiveVertSepInSCA") ; line to the left of the physical device combobox
                    \lnLiveVertRightInSCA=scsLineGadget(\nScaDevsWidth-1,0,1,\nDevInnerHeight,#SCS_Line_Color,0,"lnLiveVertRightInSCA") ; line on the far right (after the active checkbox)
                  scsCloseGadgetList()
                  
                  ;/
                  ; live input dev detail
                  ;/
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \pnlLiveInputDevDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlLiveInputDevDetail")
                    scsSetGadgetFont(\pnlLiveInputDevDetail,#SCS_FONT_GEN_BOLD)
                    
                    ; settings
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlLiveInputDevDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlLiveInputDevDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlLiveInputDevDetail, #PB_Panel_ItemHeight)
                    \cntInputSettings=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntInputSettings")
                      nTop = 16
                      \lblInputDefaults=scsTextGadget(20,nTop,400,15,Lang("WEP","lblInputDefaults"),0,"lblInputDefaults")
                      nTop + 17
                      \lblDfltInputDevLevel=scsTextGadget(20,nTop,130,15,Lang("Common","Level"), #PB_Text_Center,"lblDfltInputDevLevel")
                      \lblDfltInputDevDB=scsTextGadget(gnNextX+2,nTop,40,15,"dB", #PB_Text_Center,"lblDfltInputDevDB")
                      ; default level
                      nTop + 15
                      \nLevelLeft = 20
                      \sldDfltInputDevLevel=SLD_New("PR_DfltInputDevLevel"+Str(n+1),\cntInputSettings,0,\nLevelLeft,nTop,130,21,#SCS_ST_HLEVELNODB,0,1000)
                      \txtDfltInputDevDBLevel=scsStringGadget(gnNextX+2,nTop,40,21,"",0,"txtDfltInputDevDBLevel")
                      CompilerIf #c_lock_audio_to_ltc
                        If grLicInfo\bLockAudioToLTCAvailable
                          ; for LTC
                          nTop + 35
                          nLeft = SLD_gadgetX(\sldDfltInputDevLevel)
                          \chkInputForLTC=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WEP","chkInputForLTC"),0,"chkInputForLTC")
                          scsToolTip(\chkInputForLTC,Lang("WEP","chkInputForLTCTT"))
                        EndIf
                      CompilerEndIf
                    scsCloseGadgetList()
                    
                    ; live input test gadgets
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlLiveInputDevDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlLiveInputDevDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlLiveInputDevDetail, #PB_Panel_ItemHeight)
                    \cntTestLiveInput=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntTestLiveInput")
                      nLeft = 20
                      nTop = 12
                      nWidth = 129  ; width of output device combo box and also width of test/cancel buttons displayed below the combo box
                      \lblOutputDevForTestLiveInput=scsTextGadget(nLeft,nTop+4,130,15,Lang("WEP", "lblOutputDevForTestLiveInput"),#PB_Text_Right,"lblOutputDevForTestLiveInput")
                      \cboOutputDevForTestLiveInput=scsComboBoxGadget(gnNextX+7,nTop,nWidth,23,0,"cboOutputDevForTestLiveInput")
                      nTop + 27
                      nLeft = GadgetX(\cboOutputDevForTestLiveInput)
                      \btnTestLiveInputStart=scsButtonGadget(nLeft,nTop,nWidth,23,Trim(LangPars("WEP","btnTestLiveInputStart", "")),0,"btnTestLiveInputStart")
                      \btnTestLiveInputCancel=scsButtonGadget(nLeft,nTop,nWidth,23,Trim(LangPars("WEP","btnTestLiveInputCancel", "")),0,"btnTestLiveInputCancel")
                      setVisible(\btnTestLiveInputCancel, #False)
                      nLeft = gnNextX+12
                      \cvsTestLiveInputVU=scsCanvasGadget(nLeft,nTop+10,120,7,0,"cvsTestLiveInputVU")
                    scsCloseGadgetList()
                    
                  scsCloseGadgetList()
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxLiveDevPerProd >= 0
              ;}
              
              ; ======================================
              ;- PROD Input Groups tab within \pnlDevs
              ; ======================================
              ;{
              If grLicInfo\nMaxInGrpPerProd >= 0
                WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_IN_GRP])
                sTabDesc = "\pnlDevs tab: devices - input groups"
                debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
                ;{
                addGadgetItemWithData(\pnlDevs, Lang("WEP","InGrps"), #SCS_PROD_TAB_IN_GRPS)
                
                \cntTabInGrps=scsContainerGadget(0,0,\nDevPanelItemWidth,\nDevPanelItemHeight,0,"cntTabInGrps")
                  \lblInGrpsReqd=scsTextGadget(47,12,300,17,Lang("WEP","lblInGrpsReqd"),0,"lblInGrpsReqd")
                  scsSetGadgetFont(\lblInGrpsReqd, #SCS_FONT_GEN_BOLDUL)
                  
                  nTop = 36
                  \lblInGrpName=scsTextGadget(53,nTop,88,17,Lang("WEP","lblInGrpName"),#PB_Text_Center,"lblInGrpName")
                  \lblInGrpInfo=scsTextGadget(gnNextX+8,nTop,240,17,Lang("WEP","lblInGrpInfo"),0,"lblInGrpInfo")
                  nCntGadgetNo = \lblInGrpInfo
                  \nScaDevsTop = GadgetY(nCntGadgetNo) + GadgetHeight(nCntGadgetNo) + 2
                  
                  ; device sidebar
                  \cntInGrpSideBar=scsContainerGadget(\nSideBarLeft,\nScaDevsTop,\nSideBarWidth,96,0,"cntInGrpSideBar")
                    \imgInGrpButtonTBS[0]=scsStandardButton(2,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgInGrpButtonTBS[0]")
                    \imgInGrpButtonTBS[1]=scsStandardButton(2,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgInGrpButtonTBS[1]")
                    \imgInGrpButtonTBS[2]=scsStandardButton(2,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgInGrpButtonTBS[2]")
                    \imgInGrpButtonTBS[3]=scsStandardButton(2,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgInGrpButtonTBS[3]")
                  scsCloseGadgetList() ; cntInGrpSideBar
                  
                  ; devices
                  nHeight = (8 * nDevRowHeight) + nScaDevsExtraDepth ; set for 8 rows plus a lower border area
                  \nDevInnerHeight = (grLicInfo\nMaxInGrpPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                  \nDevInnerWidth = \nScaDevsWidth ; may be reset later by setScaInnerWidth()
                  \scaInGrps=scsScrollAreaGadget(\nScaDevsLeft,\nScaDevsTop,\nScaDevsWidth,nHeight,\nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaInGrps")
                  scsCloseGadgetList()
                  
                  ;/
                  ; input group detail
                  ;/
                  \nDevDetailTop = \nScaDevsTop + \nScaDevsHeight + nDevDetailGap
                  \nDevDetailHeight = \nDevPanelItemHeight - \nDevDetailTop
                  \pnlInGrpDetail=scsPanelGadget(\nDevDetailLeft,\nDevDetailTop,\nDevDetailWidth,\nDevDetailHeight,"pnlInGrpDetail")
                    scsSetGadgetFont(\pnlInGrpDetail,#SCS_FONT_GEN_BOLD)
                    
                    ; default settings
                    nLeft = 0
                    nTop = 0
                    AddGadgetItem(\pnlInGrpDetail, -1, "")
                    nWidth = GetGadgetAttribute(\pnlInGrpDetail, #PB_Panel_ItemWidth)
                    nHeight = GetGadgetAttribute(\pnlInGrpDetail, #PB_Panel_ItemHeight)
                    \cntInGrpDetail=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntInGrpDetail")
                      nLeft = 48
                      nTop = 16
                      \lblInGrpInputs=scsTextGadget(nLeft,nTop,350,17,Lang("WEP","lblInGrpInputs"),0,"lblInGrpInputs")
                      nLeft = 44
                      nTop + 21
                      ; nWidth = GadgetWidth(\cntInGrpDetail) - nLeft - nLeft
                      nWidth = 200  ; based on position and width of last gadget (per line) to be placed in scroll area gadget
                      nHeight = GadgetHeight(\cntInGrpDetail) - nTop - 8
                      nHeight = Round(nHeight / nDevRowHeight, #PB_Round_Down)
                      nHeight * nDevRowHeight
                      \nDevInnerHeight = (grLicInfo\nMaxLiveDevPerProd + 1) * nDevRowHeight ; may be reset later by ED_setDevGrpScaInnerHeight()
                      \nDevInnerWidth = nWidth - glScrollBarWidth - gl3DBorderAllowanceX
                      \scaInGrpLiveInputs=scsScrollAreaGadget(nLeft, nTop, nWidth, nHeight, \nDevInnerWidth, \nDevInnerHeight, nDevRowHeight, #PB_ScrollArea_BorderLess, "scaInGrpLiveInputs")
                      scsCloseGadgetList()
                    scsCloseGadgetList()
                    
                  scsCloseGadgetList()
                  
                scsCloseGadgetList()
                ;}
                grWEP\nLoadProgress + 1
                WMI_setProgress(grWEP\nLoadProgress)
              EndIf ; EndIf grLicInfo\nMaxInGrpPerProd >= 0
              ;}
              
            scsCloseGadgetList()
            ; device map buttons
            ;{
            nTop = GadgetY(\pnlDevs) + GadgetHeight(\pnlDevs) + 1
            nTextWidth = GetTextWidth(Lang("WEP","btnRetryActivate"))
            If GetTextWidth(Lang("WEP","btnApplyDevChgs")) > nTextWidth
              nTextWidth = GetTextWidth(Lang("WEP","btnApplyDevChgs"))
            EndIf
            If GetTextWidth(Lang("WEP","btnUndoDevChgs")) > nTextWidth
              nTextWidth = GetTextWidth(Lang("WEP","btnUndoDevChgs"))
            EndIf
            If GetTextWidth(Lang("WEP","btnSaveAsDevMap")) > nTextWidth
              nTextWidth = GetTextWidth(Lang("WEP","btnSaveAsDevMap"))
            EndIf
            If GetTextWidth(Lang("WEP","btnRenameDevMap")) > nTextWidth
              nTextWidth = GetTextWidth(Lang("WEP","btnRenameDevMap"))
            EndIf
            If GetTextWidth(Lang("WEP","btnDeleteDevMap")) > nTextWidth
              nTextWidth = GetTextWidth(Lang("WEP","btnDeleteDevMap"))
            EndIf
            nWidth = nTextWidth + gl3DBorderAllowanceX + gl3DBorderAllowanceX
            If nWidth < 160
              nWidth = 160
            EndIf
            If (nWidth * 3) > nPanelItemWidth
              nWidth = (nPanelItemWidth / 3)
              nGap = 0
            Else
              nGap = (nPanelItemWidth - (nWidth * 3)) >> 1
              If nGap > 16
                nGap = 16
              EndIf
            EndIf
            nLeft = (nPanelItemWidth - (nWidth * 3) - (nGap * 2)) >> 1
            \btnRetryActivate=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,Lang("WEP","btnRetryActivate"),0,"btnRetryActivate")
            \btnApplyDevChgs=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,Lang("WEP","btnApplyDevChgs"),0,"btnApplyDevChgs")
            \btnUndoDevChgs=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,Lang("WEP","btnUndoDevChgs"),0,"btnUndoDevChgs")
            nTop + gnBtnHeight + 1
            \btnSaveAsDevMap=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,LangEllipsis("WEP","btnSaveAsDevMap"),0,"btnSaveAsDevMap")
            \btnRenameDevMap=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,LangEllipsis("WEP","btnRenameDevMap"),0,"btnRenameDevMap")
            \btnDeleteDevMap=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,Lang("WEP","btnDeleteDevMap"),0,"btnDeleteDevMap")
            setToolTipFromTextIfReqd(\btnRetryActivate)
            setToolTipFromTextIfReqd(\btnApplyDevChgs)
            setToolTipFromTextIfReqd(\btnUndoDevChgs)
            setToolTipFromTextIfReqd(\btnSaveAsDevMap)
            setToolTipFromTextIfReqd(\btnRenameDevMap)
            setToolTipFromTextIfReqd(\btnDeleteDevMap)
            ;}
          scsCloseGadgetList()
          
          ; =============================
          ;- PROD Time Profiles tab
          ; =============================
          If grLicInfo\bTimeProfilesAvailable
            WMI_displayInfoMsg2(Lang("WEP","tbsTimeProfiles"))
            sTabDesc = "\pnlProd tab: time profiles"
            debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
            ;{
            addGadgetItemWithData(\pnlProd, Lang("WEP","tbsTimeProfiles"), #SCS_PROD_TAB_TIME_PROFILES)
            \cntTabTimeProfiles=scsContainerGadget(0,0,nPanelItemWidth,nPanelItemHeight,0,"cntTabTimeProfiles")
              \lblTimeProfiles=scsTextGadget(28,19,350,17,Lang("WEP","lblTimeProfiles"),0,"lblTimeProfiles")
              scsSetGadgetFont(\lblTimeProfiles, #SCS_FONT_GEN_BOLD)
              nLeft = 28 ; 76
              nTop = 47
              \lblProfileName=scsTextGadget(nLeft+17,nTop,200,15,Lang("WEP","lblProfileName"),0,"lblProfileName")
              setGadgetWidth(\lblProfileName)
              nTop + 17
              For n = 0 To #SCS_MAX_TIME_PROFILE
                \lblProfileNo[n]=scsTextGadget(nLeft,nTop+gnLblVOffsetS,11,15,Str(n+1), #PB_Text_Right,"lblProfileNo[" + n +"]")
                \txtTimeProfile[n]=scsStringGadget(gnNextX+gnGap,nTop,120,21,"",0,"txtTimeProfile[" + n +"]")
                scsToolTip(\txtTimeProfile[n],Lang("WEP","txtTimeProfileTT"))
                nTop + 21
              Next n
              nTop + 11
              nLeft + 18
              \lblDfltTimeProfile=scsTextGadget(nLeft,nTop,200,15,Lang("WEP","lblDfltTimeProfile"),0,"lblDfltTimeProfile")
              setGadgetWidth(\lblDfltTimeProfile)
              nTop + 17
              \cboDfltTimeProfile=scsComboBoxGadget(nLeft,nTop,120,21,0,"cboDfltTimeProfile")
              scsToolTip(\cboDfltTimeProfile,Lang("WEP","cboDfltTimeProfileTT"))
              nTop + 33
              \lblResetTOD=scsTextGadget(nLeft,nTop,350,15,Lang("WEP","lblResetTOD"),0,"lblResetTOD")
              nTop + 17
              \cboResetTOD=scsComboBoxGadget(nLeft,nTop,120,21,0,"cboResetTOD")
              nLeft = 210
              nTop = 47
              \lblDfltTimeProfileByDay=scsTextGadget(nLeft,nTop,400,15,Lang("WEP","lblDfltTimeProfileByDay"),0,"lblDfltTimeProfileByDay")
              setGadgetWidth(\lblDfltTimeProfileByDay)
              nTop + 17
              For n = 0 To 6
                sTextKey = "Day_" + n
                \lblDfltTimeProfileDay[n]=scsTextGadget(nLeft,nTop+4,49,15,Lang("Common",sTextKey),#PB_Text_Right,"lblDfltTimeProfileDay[" + n + "]")
                \cboDfltTimeProfileForDay[n]=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboDfltTimeProfileForDay[" + n + "]")
                nTop + 21
              Next n
            scsCloseGadgetList()
            ;}
            grWEP\nLoadProgress + 1
            WMI_setProgress(grWEP\nLoadProgress)
          EndIf
          
          ; =============================
          ;- PROD Run Time Settings tab
          ; =============================
          WMI_displayInfoMsg2(Lang("WEP","tbsRunTimeSettings"))
          sTabDesc = "\pnlProd tab: run time settings"
          debugMsg(sProcName, sTabDesc + ", gnContainerLevel=" + gnContainerLevel)
          ;{
          addGadgetItemWithData(\pnlProd, Lang("WEP","tbsRunTimeSettings"), #SCS_PROD_TAB_RUN_TIME_SETTINGS)
          
          \cntTabRunTime=scsContainerGadget(0,0,nPanelItemWidth,nPanelItemHeight,#PB_Container_Flat,"cntTabRunTime")
            nLblLeft = 4
            nLblWidth = 192  ; was 160
            nItemLeft = nLblLeft + nLblWidth + gnGap
            
            \lblRunTimeSettings=scsTextGadget(28,19,400,17,Lang("WEP","lblRunTimeSettings"),0,"lblRunTimeSettings")
            scsSetGadgetFont(\lblRunTimeSettings, #SCS_FONT_GEN_BOLD)
            nTop = 53
            \lblRunMode=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblRunMode"), #PB_Text_Right,"lblRunMode")
            \cboRunMode=scsComboBoxGadget(nItemLeft,nTop,283,21,0,"cboRunMode")
            scsToolTip(\cboRunMode,Lang("WEP","cboRunModeTT"))
            
            nTop + 30
            \lblVisualWarningTime=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblVisualWarningTime"), #PB_Text_Right,"lblVisualWarningTime")
            \cboVisualWarningTime=scsComboBoxGadget(nItemLeft,nTop,200,21,0,"cboVisualWarningTime")
            scsToolTip(\cboVisualWarningTime,Lang("WEP","cboVisualWarningTimeTT"))
            nTop + 22
            \lblVisualWarningFormat=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblVisualWarningFormat"), #PB_Text_Right,"lblVisualWarningFormat")
            \cboVisualWarningFormat=scsComboBoxGadget(nItemLeft,nTop,200,21,0,"cboVisualWarningFormat")
            
            nTop + 26
            \chkPreLoadNextManualOnly=scsCheckBoxGadget2(nItemLeft,nTop,-1,17,Lang("WEP","chkPreLoadNextManualOnly"),0,"chkPreLoadNextManualOnly")
            nTop + 17
            \chkNoPreLoadVideoHotkeys=scsCheckBoxGadget2(nItemLeft,nTop,-1,17,Lang("WEP","chkNoPreLoadVideoHotkeys"),0,"chkNoPreLoadVideoHotkeys")
            nTop + 17
            \chkStopAllInclHib=scsCheckBoxGadget2(nItemLeft,nTop,-1,17,Lang("WEP","chkStopAllInclHib"),0,"chkStopAllInclHib")
            If grLicInfo\bHKClickAvailable
              nTop + 17
              \chkAllowHKeyClick=scsCheckBoxGadget2(nItemLeft,nTop,-1,17,Lang("WEP","chkAllowHKeyClick"),0,"chkAllowHKeyClick")
              scsToolTip(\chkAllowHKeyClick,Lang("WEP","chkAllowHKeyClickTT"))
            EndIf
            
            nTop + 30
            \lblFocusPoint=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblFocusPoint"), #PB_Text_Right,"lblFocusPoint")
            \cboFocusPoint=scsComboBoxGadget(nItemLeft,nTop,200,21,0,"cboFocusPoint")
            scsToolTip(\cboFocusPoint,Lang("WEP","cboFocusPointTT"))
            
            If grLicInfo\nLicLevel >= #SCS_LIC_PRO
              nTop + 30
              sText = Lang("WEP","lblGridClickAction")
              nWidth = GetTextWidth(sText)
              If nWidth <= nLblWidth
                ; requires 1 line
                \lblGridClickAction=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,sText,#PB_Text_Right,"lblGridClickAction")
                \cboGridClickAction=scsComboBoxGadget(nItemLeft,nTop,250,21,0,"cboGridClickAction")
              Else
                ; requires 2 lines
                \lblGridClickAction=scsTextGadget(nLblLeft,nTop,nLblWidth,30,sText,#PB_Text_Right,"lblGridClickAction")
                \cboGridClickAction=scsComboBoxGadget(nItemLeft,nTop+4,250,21,0,"cboGridClickAction")
                nTop + 4
              EndIf
            EndIf
            
            If grLicInfo\nLicLevel >= #SCS_LIC_PRO
              nTop + 30
              sText = Lang("WEP","lblLostFocusAction")
              nWidth = GetTextWidth(sText)
              If nWidth <= nLblWidth
                ; requires 1 line
                \lblLostFocusAction=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,sText,#PB_Text_Right,"lblLostFocusAction")
                \cboLostFocusAction=scsComboBoxGadget(nItemLeft,nTop,250,21,0,"cboLostFocusAction")
              Else
                ; requires 2 lines
                \lblLostFocusAction=scsTextGadget(nLblLeft,nTop,nLblWidth,30,sText,#PB_Text_Right,"lblLostFocusAction")
                \cboLostFocusAction=scsComboBoxGadget(nItemLeft,nTop+4,250,21,0,"cboLostFocusAction")
                nTop + 4
              EndIf
            EndIf
            
            nTop + 32
            \lnRunTimeAudio=scsLineGadget(4,nTop,nPanelItemWidth-8,1,#SCS_Light_Grey,0,"lnRunTimeAudio")
            nTop + 8
            If grLicInfo\nLicLevel >= #SCS_LIC_STD
              \lblMaxDBLevel=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WEP","lblMaxDBLevel"),#PB_Text_Right,"lblMaxDBLevel")
              \cboMaxDBLevel=scsComboBoxGadget(nItemLeft,nTop,435,21,0,"cboMaxDBLevel")
              nTop + 23
              \lblMinDBLevel=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WEP","lblMinDBLevel"),#PB_Text_Right,"lblMinDBLevel")
              \cboMinDBLevel=scsComboBoxGadget(nItemLeft,nTop,435,21,0,"cboMinDBLevel")
              scsToolTip(\cboMinDBLevel, Lang("WEP","cboMinDBLevelTT"))
              nTop + 26
            EndIf
            \lblDBLevelChangeIncrement=scsTextGadget(nLblLeft,nTop+gnLblVOffsetS,nLblWidth,15,Lang("WEP","lblDBLevelChangeIncrement"),#PB_Text_Right,"lblDBLevelChangeIncrement")
            setGadgetWidth(\lblDBLevelChangeIncrement, nLblWidth, #True)
            \txtDBLevelChangeIncrement=scsStringGadget(gnNextX+gnGap,nTop,40,21,"",0,"txtDBLevelChangeIncrement")
            \lblDBLevelChangeIncrementDB=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,20,15,"dB",0,"lblDBLevelChangeIncrementDB")
            nTop + 26
            \cntMasterFader=scsContainerGadget(0,nTop,GadgetWidth(\cntTabRunTime),23,#PB_Container_BorderLess,"cntMasterFader")
              nTop2 = 0
              \lblMasterFader=scsTextGadget(nLblLeft,nTop2+gnLblVOffsetS,nLblWidth,15,Lang("WEP","lblMasterFader"),#PB_Text_Right,"lblMasterFader")
              \sldMasterFader2=SLD_New("PR_Master",\cntMasterFader,nTop2,nItemLeft,0,200,22,#SCS_ST_HLEVELNODB,0,1000)
              \txtMasterFaderDB=scsStringGadget(gnNextX+2,nTop2,40,21,"",0,"txtMasterFaderDB")
              \lblMasterFaderDB=scsTextGadget(gnNextX+gnGap,nTop2+gnLblVOffsetS,20,15,"dB",0,"lblMasterFaderDB")
            scsCloseGadgetList()
            nTop + GadgetHeight(\cntMasterFader) + 6
            
            If grLicInfo\nMaxLightingDevPerProd >= 0
              ; commented out the gbDMXAvailable test following an issue reported by Dieter Edinger 19Aug2016 and earlier
              ; whereby the Default DMX Fade Time was not being displayed when he expected it to be
              nTop + 6
              \lnRunTimeDMX=scsLineGadget(4,nTop,nPanelItemWidth-8,1,#SCS_Light_Grey,0,"lnRunTimeDMX")
              nTop + 6
              sText = Lang("WEP","lblDefDMXFadeTime")
              nWidth = GetTextWidth(sText)
              If nWidth <= nLblWidth
                ; requires 1 line
                \lblDefDMXFadeTime=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,sText,#PB_Text_Right,"lblDefDMXFadeTime")
                \txtDefDMXFadeTime=scsStringGadget(nItemLeft,nTop,60,21,"",0,"txtDefDMXFadeTime")
                nTop + 21
              Else
                ; requires 2 lines
                \lblDefDMXFadeTime=scsTextGadget(nLblLeft,nTop+1,nLblWidth,30,sText,#PB_Text_Right,"lblDefDMXFadeTime")
                \txtDefDMXFadeTime=scsStringGadget(nItemLeft,nTop+5,60,21,"",0,"txtDefDMXFadeTime")
                nTop + 26
              EndIf
              setValidChars(\txtDefDMXFadeTime, "0123456789.:")
              scsToolTip(\txtDefDMXFadeTime, Lang("WEP","txtDefDMXFadeTimeTT"))
              nTop + 6
              \lblDefChaseSpeed=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblDefChaseSpeed"),#PB_Text_Right,"lblDefChaseSpeed")
              \txtDefChaseSpeed=scsStringGadget(nItemLeft,nTop,40,21,"",#PB_String_Numeric,"txtDefChaseSpeed")
              nTop + 27
              \cntDMXMasterFader=scsContainerGadget(0,nTop,GadgetWidth(\cntTabRunTime),22,#PB_Container_BorderLess,"cntDMXMasterFader")
                nTop2 = 0
                \lblDMXMasterFader=scsTextGadget(nLblLeft,nTop2+gnLblVOffsetS,nLblWidth,15,Lang("WEP","lblDMXMasterFader"),#PB_Text_Right,"lblDMXMasterFader")
                \sldDMXMasterFader2=SLD_New("PR_DMXMaster",\cntDMXMasterFader,nTop2,nItemLeft,0,200,22,#SCS_ST_HLIGHTING_PERCENT,0,100)
              scsCloseGadgetList()
              nTop + GadgetHeight(\cntDMXMasterFader) + 4
              \chkDoNotCalcCueStartValues=scsCheckBoxGadget2(nItemLeft,nTop,-1,17,Lang("WEP","chkDoNotCalcCueStartValues"),0,"chkDoNotCalcCueStartValues")
            EndIf
            
          scsCloseGadgetList()
          ;}
          grWEP\nLoadProgress + 1
          WMI_setProgress(grWEP\nLoadProgress)
          
        scsCloseGadgetList() ; pnlProd
        
        grWEP\nDisplayedTab = getCurrentItemData(WEP\pnlProd)
        
      scsCloseGadgetList() ; cntProdProperties
      
      setVisible(\scaProdProperties, #True)
      setEnabled(\scaProdProperties, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bProdCreated = #True
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Structure strWEX ; fmExport
  chkCopyFiles.i
  btnClearAll.i
  btnClose.i
  btnExport.i
  btnHelp.i
  btnSelectAll.i
  grdExport.i
  lblGridTitle.i
  lblProdTitle.i
  txtProdTitle.i
  lblExportStatus.i
EndStructure
Global WEX.strWEX ; fmExport

Procedure createfmExport()
  PROCNAMEC()
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WEX, 0, 0, 585, 550, Lang("WEX","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WEX, "WEX(fmExport)")
    ; SetWindowColor(#WEX,RGB(251,240,196))
    With WEX
      \btnSelectAll=scsButtonGadget(41,12,82,gnBtnHeight,Lang("WEX","btnSelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(128,12,82,gnBtnHeight,Lang("WEX","btnClearAll"),0,"btnClearAll")
      \lblGridTitle=scsTextGadget(229,15,312,24,Lang("WEX","lblGridTitle"),0,"lblGridTitle")
      scsSetGadgetFont(\lblGridTitle, #SCS_FONT_GEN_BOLD10)
      
      \grdExport=scsListIconGadget(32,37,521,387,grText\sTextSelect,55,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdExport")
      AddGadgetColumn(\grdExport,1,Lang("Common","Cue"),58)
      AddGadgetColumn(\grdExport,2,Lang("Common","Description"),308)
      AddGadgetColumn(\grdExport,3,Lang("Common","CueType"),120)
      autoFitGridCol(\grdExport, 2) ; autofit "Description" column
      
      \lblProdTitle=scsTextGadget(12,435,189,16,Lang("WEX","lblProdTitle"), #PB_Text_Right,"lblProdTitle")
      \txtProdTitle=scsStringGadget(208,432,345,19,"",0,"txtProdTitle")
      \chkCopyFiles=scsCheckBoxGadget(120,461,433,17,Lang("WEX","chkCopyFiles"),0,"chkCopyFiles")
      \btnExport=scsButtonGadget(120,497,152,gnBtnHeight,Lang("WEX","btnExport"),#PB_Button_Default,"btnExport")
      \btnClose=scsButtonGadget(287,497,81,gnBtnHeight,Lang("Btns","Close"),0,"btnClose")
      \btnHelp=scsButtonGadget(383,497,81,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      \lblExportStatus=scsTextGadget(0,532,585,17,"", #PB_Text_Center,"lblExportStatus")
      
      AddKeyboardShortcut(#WEX, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      AddKeyboardShortcut(#WEX, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
    EndWith
    setWindowEnabled(#WEX,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWFF ; fmFavFiles
  lblFavFiles.i
  grdFavFiles.i
  lblFileInfo.i
  btnOpen.i
  btnAddFile.i
  btnAddCurrent.i
  btnClearEntry.i
  btnMoveUp.i
  btnMoveDown.i
  btnRemoveEntry.i
  btnOK.i
  btnCancel.i
  btnApply.i
  btnHelp.i
EndStructure
Global WFF.strWFF ; fmFavFiles

Procedure createfmFavFiles(nParentWindow)
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight, nHeightAllowance, nGap
  
  If IsWindow(#WFF)
    If gaWindowProps(#WFF)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WFF)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFF, 0, 0, 443, 480, Lang("WFF","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WFF, "WFF(fmFavFiles)", nParentWindow)
    With WFF
      \lblFavFiles=scsTextGadget(15,8,172,16,Lang("WFF","lblFavFiles"),0,"lblFavFiles")
      
      \grdFavFiles=scsListIconGadget(15,27,283,369,"#",30,#PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines,"grdFavFiles")
      AddGadgetColumn(\grdFavFiles,1,grText\sTextFile,200)
      ; autoFitGridCol(\grdFavFiles,1)
      
      nLeft = 309
      nTop = 75
      nWidth = 113
      nHeight = 23
      nHeightAllowance = 32
      \btnOpen=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WFF","btnOpen"),#PB_Button_Default,"btnOpen")
      nTop + 46
      \btnAddFile=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WFF","btnAddFile"),0,"btnAddFile")
      nTop + nHeightAllowance
      \btnAddCurrent=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WFF","btnAddCurrent"),0,"btnAddCurrent")
      nTop + nHeightAllowance
      \btnClearEntry=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WFF","btnClearEntry"),0,"btnClearEntry")
      nTop + nHeightAllowance
      \btnRemoveEntry=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WFF","btnRemoveEntry"),0,"btnRemoveEntry")
      nTop + nHeightAllowance
      \btnMoveUp=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("Btns","MoveUp"),0,"btnMoveUp")
      nTop + nHeightAllowance
      \btnMoveDown=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("Btns","MoveDown"),0,"btnMoveDown")
      
      nTop = GadgetY(\grdFavFiles) + GadgetHeight(\grdFavFiles) + 8
      \lblFileInfo=scsTextGadget(15,nTop,420,42,"",0,"lblFileInfo")
      
      nTop + 43
      nWidth = 73
      nGap = 8
      nLeft = (WindowWidth(#WFF) - ((nWidth * 4) + (nGap * 3))) >> 1
      \btnOK=scsButtonGadget(nLeft, nTop, nWidth, nHeight, grText\sTextBtnOK,0,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nWidth,nHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnApply=scsButtonGadget(gnNextX+nGap,nTop,nWidth,nHeight,grText\sTextBtnApply,0,"btnApply")
      \btnHelp=scsButtonGadget(gnNextX+nGap,nTop,nWidth,nHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      AddKeyboardShortcut(#WFF, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WFF, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    ; setWindowVisible(#WFF,#True)
    setWindowEnabled(#WFF,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Structure strWFL ; fmFileLocator
  btnClose.i
  btnLocate.i
  lblFileList.i
  tvwFileList.i
EndStructure
Global WFL.strWFL ; fmFileLocator

Procedure createfmFileLocator()
  PROCNAMEC()
  Protected nFlags
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFL, 0, 0, 581, 431, Lang("WFL","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WFL, "WFL(fmFileLocator)")
    With WFL
      \lblFileList=scsTextGadget(13,11,554,19,"",0,"lblFileList")
      scsSetGadgetFont(\lblFileList, #SCS_FONT_GEN_BOLD)
      ; Originally used a ListViewGadget but that doesn't display a horizontal scrollbar, except by using SendMessage_().
      ; The TreeGadget, however, will display a horizontal scrollbar if necessary.
      nFlags = #PB_Tree_NoLines | #PB_Tree_AlwaysShowSelection | #PB_Tree_NoButtons | #PB_Tree_NoLines
      \tvwFileList=scsTreeGadget(13,37,554,350,nFlags,"tvwFileList")
      \btnLocate=scsButtonGadget(208,396,81,gnBtnHeight,LangEllipsis("WFL","btnLocate"),0,"btnLocate")
      \btnClose=scsButtonGadget(293,396,81,gnBtnHeight,Lang("Btns","Close"),0,"btnClose")
    EndWith
    ; setWindowVisible(#WFL,#True)
    setWindowEnabled(#WFL,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWFO  ; fmFileOpener
  btnCancel.i
  btnOpen.i
  btnPlay.i
  btnStop.i
  cboDevice.i
  cntSouth.i
  expListMulti.i
  expListSingle.i
  expTree.i
  lblFileName.i
  lblFiles.i
  lblFolders.i
  lblLevel.i
  lblPosition.i
  lblPreview.i
  lblTitle.i
  sldLevel.i
  sldPosition.i
  splOpenerV.i
  txtFileName.i
EndStructure
Global WFO.strWFO ; fmFileOpener

Procedure createfmFileOpener()
  PROCNAMEC()
  Protected nFlags, nTickInterval, n
  Protected nLeft, nTop, nWidth
  Protected nSldHeight
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFO, 0, 0, 850, 500, Lang("WFO","Window"), #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WFO, "WFO(fmFileOpener)")
    nSldHeight = 16
    ; make odd
    nSldHeight >> 1
    nSldHeight << 1
    nSldHeight + 1
    With WFO
      \lblFolders=scsTextGadget(18,10,50,15,Lang("WFO","lblFolders"),0,"lblFolders")
      setGadgetWidth(\lblFolders)
      \lblFiles=scsTextGadget(gnNextX,10,50,15,Lang("WFO","lblFiles"),0,"lblFiles")
      setGadgetWidth(\lblFiles)
      ; \expTree=scsExplorerTreeGadget(0, 0, 0, 0, "", #PB_Explorer_NoFiles|#PB_Explorer_NoDriveRequester|#PB_Explorer_AlwaysShowSelection)
      \expTree=scsExplorerTreeGadget(0, 0, 0, 0, "", #PB_Explorer_NoFiles|#PB_Explorer_NoDriveRequester|#PB_Explorer_AlwaysShowSelection|#PB_Explorer_NoMyDocuments)
      SetGadgetColor(\expTree, #PB_Gadget_BackColor, $D2D2D2)
      ; multiselect version of ExplorerListGadget
      \expListMulti=scsExplorerListGadget(0, 0, 0, 0, "", #PB_Explorer_MultiSelect|#PB_Explorer_FullRowSelect|#PB_Explorer_AlwaysShowSelection|#PB_Explorer_HeaderDragDrop|#PB_Explorer_AutoSort)
      SetGadgetColor(\expListMulti, #PB_Gadget_BackColor, $EFEFEF)
      registerGrid(@grWFO\rExpListInfo, \expListMulti, #SCS_GT_EXPWFO, "NM,TI,LN,SZ,TY,DM")
      ; singleselect version of ExplorerListGadget
      \expListSingle=scsExplorerListGadget(0, 0, 0, 0, "", #PB_Explorer_FullRowSelect|#PB_Explorer_AlwaysShowSelection|#PB_Explorer_HeaderDragDrop|#PB_Explorer_AutoSort)
      SetGadgetColor(\expListSingle, #PB_Gadget_BackColor, $EFEFEF)
      setVisible(\expListSingle, #False)
      \splOpenerV=scsSplitterGadget(10,25,830,355,\expTree,\expListMulti,#PB_Splitter_Separator|#PB_Splitter_Vertical,"splOpenerV")
      SetGadgetAttribute(\splOpenerV, #PB_Splitter_FirstMinimumSize, 80)
      SetGadgetAttribute(\splOpenerV, #PB_Splitter_SecondMinimumSize, 120)
      \cntSouth=scsContainerGadget(0,380,WindowWidth(#WFO),112,#PB_Container_BorderLess, "cntSouth")
        nTop = 10
        \lblFileName=scsTextGadget(20,nTop+gnLblVOffsetS,50,15,Lang("WFO","lblFileName"),0,"lblFileName")
        setGadgetWidth(\lblFileName, -1, #True)
        \txtFileName=scsStringGadget(gnNextX+gnGap,nTop,300,21,"",#PB_String_ReadOnly,"txtFileName")
        nWidth = 81
        \btnOpen=scsButtonGadget(gnNextX+24,nTop-1,nWidth,gnBtnHeight,Lang("Btns","Open"),#PB_Button_Default,"btnOpen")
        AddKeyboardShortcut(#WFO, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
        \btnCancel=scsButtonGadget(gnNextX+gnGap,nTop-1,nWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
        AddKeyboardShortcut(#WFO, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
        nTop + 32
        \lblPreview=scsTextGadget(20,nTop,70,15,Lang("WFO","lblPreview"),0,"lblPreview")
        nTop + 20
        \btnPlay=scsStandardButton(20,nTop-1,24,24,#SCS_STANDARD_BTN_PLAY,"btnPlay")
        \btnStop=scsStandardButton(gnNextX,nTop-1,24,24,#SCS_STANDARD_BTN_STOP,"btnStop")
        \cboDevice=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboDevice")
        \lblLevel=scsTextGadget(gnNextX+gnGap2,nTop+3,45,15,Lang("WFO","lblLevel"),#PB_Text_Right,"lblLevel")
        setGadgetWidth(\lblLevel,-1,#True)
        \sldLevel=SLD_New("WFO_Level", \cntSouth, 0, gnNextX+gnShortGap,nTop+1,120, nSldHeight, #SCS_ST_HLEVELRUN, 0, 1000, 0)
        \lblPosition=scsTextGadget(gnNextX+gnGap2,nTop+3,45,15,Lang("WFO","lblPosition"),#PB_Text_Right,"lblPosition")
        setGadgetWidth(\lblPosition,-1,#True)
        \sldPosition=SLD_New("WFO_Position", \cntSouth, 0, gnNextX+gnShortGap, nTop+1, 271, nSldHeight, #SCS_ST_PROGRESS, 0, 1000, 0)
        nTop + 28
        \lblTitle=scsTextGadget(20,nTop,70,15,"",0,"lblTitle")
      scsCloseGadgetList()
    EndWith
    ; setWindowVisible(#WFO,#True)
    setWindowEnabled(#WFO,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWFR ; fmFileRename
  lblCurrFilename.i
  txtCurrFilename.i
  lblReqdFilename.i
  txtReqdFilename.i
  cntInfo.i
  lblInfo.i[5]
  btnRename.i
  btnCancel.i
EndStructure
Global WFR.strWFR

Procedure createfmFileRename()
  PROCNAMEC()
  Protected n, nLeft, nTop, sNr.s
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFR, 0, 0, 408, 265, Lang("WFR","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WFR, "WFR(fmFileRename)")
    With WFR
      \lblCurrFilename=scsTextGadget(24,25,93,17,Lang("WFR", "lblCurrFilename"),#PB_Text_Right,"lblCurrFilename")
      \txtCurrFilename=scsStringGadget(gnNextX+7,22,246,21,"",#PB_String_ReadOnly,"txtCurrFilename")
      \lblReqdFilename=scsTextGadget(24,62,93,17,Lang("WFR", "lblReqdFilename"),#PB_Text_Right,"lblReqdFilename")
      \txtReqdFilename=scsStringGadget(gnNextX+7,59,246,21,"",0,"txtReqdFilename")
      \cntInfo=scsContainerGadget(22,105,357,102,#PB_Container_Flat,"cntInfo")
        SetGadgetColor(\cntInfo, #PB_Gadget_BackColor, RGB(255,255,223))
        nLeft = 5
        For n = 0 To 4
          nTop = (n * 18) + 4
          sNr = "["+n+"]"
          \lblInfo[n]=scsTextGadget(nLeft,nTop,345,18,Lang("WFR","lblInfo"+sNr),0,"lblInfo"+sNr)
          SetGadgetColor(\lblInfo[n], #PB_Gadget_FrontColor, RGB(146,75,114))
          SetGadgetColor(\lblInfo[n], #PB_Gadget_BackColor, RGB(255,255,223))
          nLeft = 9
        Next n
        scsSetGadgetFont(\lblInfo[0],#SCS_FONT_GEN_BOLD)
      scsCloseGadgetList()
      \btnRename=scsButtonGadget(102,230,81,gnBtnHeight,Lang("Btns","Rename"),#PB_Button_Default,"btnRename")
      AddKeyboardShortcut(#WFR, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      \btnCancel=scsButtonGadget(218,230,81,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      AddKeyboardShortcut(#WFR, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    EndWith
    ; setWindowVisible(#WFR,#True)
    setWindowEnabled(#WFR,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Structure strWFS ; fmFavFileSelector
  lblFavFiles.i
  grdFavFiles.i
  lblFileInfo.i
  btnOpen.i
  btnCancel.i
EndStructure
Global WFS.strWFS ; fmFavFileSelector

Procedure createfmFavFileSelector(nParentWindow)
  PROCNAMEC()
  Protected nTop
  
  If IsWindow(#WFS)
    If gaWindowProps(#WFS)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WFS)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFS, 0, 0, 312, 480, Lang("WFS","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WFS, "WFS(fmFavFileSelector)", nParentWindow)
    With WFS
      \lblFavFiles=scsTextGadget(15,8,172,16,Lang("WFF","lblFavFiles"),0,"lblFavFiles")
      
      \grdFavFiles=scsListIconGadget(15,27,283,369,"#",30,#PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines,"grdFavFiles")
      AddGadgetColumn(\grdFavFiles,1,grText\sTextFile,200)
      ; autoFitGridCol(\grdFavFiles,1)
      
      nTop = GadgetY(\grdFavFiles) + GadgetHeight(\grdFavFiles) + 8
      \lblFileInfo=scsTextGadget(15,nTop,420,42,"",0,"lblFileInfo")
      
      nTop + 43
      \btnOpen=scsButtonGadget(60,nTop,73,gnBtnHeight,Lang("Btns","Open"),0,"btnOpen")
      \btnCancel=scsButtonGadget(141,nTop,73,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      
      AddKeyboardShortcut(#WFS, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WFS, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    ; setWindowVisible(#WFS,#True)
    setWindowEnabled(#WFS,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Structure strWIM ; fmImport
  btnAddSelected.i
  btnBrowse.i
  btnClearAll.i
  btnClose.i
  btnFavorites.i
  btnHelp.i
  btnSelectAll.i
  cboTargetCue.i
  cntBelowGrid.i
  cntOptionGadgets.i
  cvsProgress.i
  grdAddCues.i
  lblCueFile.i
  lblGridTitle.i
  lblProdTitle.i
  lblTargetCue.i
  optGenerateCueNumbers.i
  optPreserveCueNumbers.i
  txtCueFile.i
  txtProdTitle.i
EndStructure
Global WIM.strWIM ; fmImport

Procedure createfmImport()
  PROCNAMEC()
  Protected nFlags
  Protected nLeft, nTop, nWidth, nHeight
  Protected nCntBelowGridHeight
  Protected sCueFileLabel.s, sProdTitleLabel.s
  Protected nLabelLength, nFieldWidth
  
  ; note: shares some language strings with WIC (fmImportCSV) and WID (fmImportDevs)
  
  nCntBelowGridHeight = 105
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nFlags = #PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible | #PB_Window_SizeGadget
  If OpenWindow(#WIM, 0, 0, 650, 571, Lang("WIM","Window"), nFlags, WindowID(#WED))
    registerWindow(#WIM, "WIM(fmImport)")
    ; ; SetWindowColor(#WIM,RGB(132,238,135))
    ; SetWindowColor(#WIM,RGB($9D,$C4,$91))
    With WIM
      nTop = 16  ; nb min value = 12 because of required 'top' position of btnBrowse
      sCueFileLabel = Lang("WIM","lblCueFile")
      sProdTitleLabel = Lang("WIM","lblProdTitle")
      nLabelLength = getMaxTextWidth(10,sCueFileLabel,sProdTitleLabel) + 8
      nFieldWidth = 459 - nLabelLength
      \lblCueFile=scsTextGadget(8,nTop+gnLblVOffsetS,nLabelLength,17,sCueFileLabel,#PB_Text_Right,"lblCueFile")
      \txtCueFile=scsStringGadget(gnNextX+gnGap,nTop,nFieldWidth,19,"",#PB_String_ReadOnly,"txtCueFile")
      ; setEnabled(\txtCueFile, #False)
      \btnBrowse=scsButtonGadget(476,nTop-12,100,gnBtnHeight,LangEllipsis("Btns","Browse"),0,"btnBrowse")
      \btnFavorites=scsButtonGadget(476,nTop+11,100,gnBtnHeight,LangEllipsis("WIM","btnFavorites"),0,"btnFavorites")
      nTop + 36
      \lblProdTitle=scsTextGadget(8,nTop+gnLblVOffsetS,nLabelLength,16,sProdTitleLabel,#PB_Text_Right,"lblProdTitle")
      \txtProdTitle=scsStringGadget(gnNextX+gnGap,nTop,nFieldWidth,19,"",#PB_String_ReadOnly,"txtProdTitle")
      ; setEnabled(\txtProdTitle, #False)
      nTop + 40
      \btnSelectAll=scsButtonGadget(41,nTop,82,gnBtnHeight,Lang("WIM","btnSelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(129,nTop,82,gnBtnHeight,Lang("WIM","btnClearAll"),0,"btnClearAll")
      \lblGridTitle=scsTextGadget(230,nTop+gnLblVOffsetS,312,21,Lang("WIM","lblGridTitle"),0,"lblGridTitle")
      scsSetGadgetFont(\lblGridTitle, #SCS_FONT_GEN_BOLD10)
      
      nTop + 25
      nHeight = WindowHeight(#WIM) - nTop - nCntBelowGridHeight
      nLeft = 32
      nWidth = WindowWidth(#WIM) - (nLeft << 1)
      \grdAddCues=scsListIconGadget(nLeft, nTop, nWidth, nHeight, grText\sTextSelect,55,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdAddCues")
      AddGadgetColumn(\grdAddCues,1,Lang("Common","Cue"),58)
      AddGadgetColumn(\grdAddCues,2,Lang("Common","Page"),58)
      AddGadgetColumn(\grdAddCues,3,Lang("Common","Description"),308)
      AddGadgetColumn(\grdAddCues,4,Lang("Common","CueType"),120)
      autoFitGridCol(\grdAddCues, 3) ; autofit "Description" column
      
      nTop = GadgetY(\grdAddCues) + GadgetHeight(\grdAddCues)
      nWidth = WindowWidth(#WIM)
      nHeight = WindowHeight(#WIM) - nTop
      \cntBelowGrid=scsContainerGadget(0,nTop,nWidth,nCntBelowGridHeight,0,"cntBelowGrid")
        nTop = 2
        nLeft = GadgetX(\grdAddCues) + 1
        nWidth = GadgetWidth(\grdAddCues) - 2
        \cvsProgress=scsCanvasGadget(nLeft,nTop,nWidth,6,0,"cvsProgress")
        nTop + 15
        \lblTargetCue=scsTextGadget(28,nTop+gnLblVOffsetS,197,18,Lang("WIM","lblTargetCue"), #PB_Text_Right,"lblTargetCue")
        scsSetGadgetFont(\lblTargetCue, #SCS_FONT_GEN_BOLD)
        \cboTargetCue=scsComboBoxGadget(232,nTop,345,21,0,"cboTargetCue")
        nTop + 28
        \cntOptionGadgets=scsContainerGadget(115,nTop,350,16,0,"cntOptionGadgets")
          \optGenerateCueNumbers=scsOptionGadget(0,0,175,16,Lang("WIM","optGenerateCueNumbers"),"optGenerateCueNumbers")
          \optPreserveCueNumbers=scsOptionGadget(gnNextX,0,175,16,Lang("WIM","optPreserveCueNumbers"),"optPreserveCueNumbers")
          SGS(\optGenerateCueNumbers, #True)
        scsCloseGadgetList()
        nTop + 27
        nHeight = 23
        \btnAddSelected=scsButtonGadget(134,nTop,130,nHeight,Lang("WIM","btnAddSelected"),#PB_Button_Default,"btnAddSelected")
        AddKeyboardShortcut(#WIM, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
        \btnClose=scsButtonGadget(277,nTop,81,nHeight,Lang("Btns","Close"),0,"btnClose")
        AddKeyboardShortcut(#WIM, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
        \btnHelp=scsButtonGadget(372,nTop,81,nHeight,grText\sTextBtnHelp,0,"btnHelp")
        ; plus 10 padding
      scsCloseGadgetList()
    EndWith
    setWindowEnabled(#WIM,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Structure strWIC ; fmImportCSV
  btnAddSelected.i
  btnBrowse.i
  btnClearAll.i
  btnClose.i
  btnHelp.i
  btnReadFile.i
  btnSelectAll.i
  cboFileType.i
  cboLogicalDev.i
  cboMSChannel.i
  cboTargetCue.i
  chkNewCueNos.l
  cntBelowGrid.i
  cntControls.i
  cntExtras.i
  cntMidi.i
  cvsProgress.i
  grdAddCues.i
  lblChannel.i
  lblCSVFile.i
  lblCuePrefix.i
  lblDescrSplit1.i
  lblDescrSplit2.i
  lblFileType.i
  lblGridTitle.i
  lblLogicalDev.i
  lblTargetCue.i
  lnSeparator.i
  txtCSVFile.i
  txtCuePrefix.i
  txtDescrSplit.i
EndStructure
Global WIC.strWIC ; fmImportCSV

Procedure createfmImportCSV()
  PROCNAMEC()
  Protected nFlags
  Protected nLeft, nTop, nWidth, nHeight
  Protected sCuePrefixLabel.s, sDescrSplitLabel.s
  Protected nLabelLength
  Protected nCntBelowGridHeight
  
  ; note: shares some language strings with WIM (fmImport)
  
  nCntBelowGridHeight = 97
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nFlags = #PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible | #PB_Window_SizeGadget
  If OpenWindow(#WIC, 0, 0, 700, 571, Lang("WIC","Window"), nFlags, WindowID(#WED))
    registerWindow(#WIC, "WIC(fmImportCSV)")
    With WIC
      nTop = 6
      \lblCSVFile=scsTextGadget(28,nTop+5,120,17,Lang("WIC","lblCSVFile"),#PB_Text_Right,"lblCSVFile")
      \txtCSVFile=scsStringGadget(gnNextX + 4,nTop+2,300,19,"",#PB_String_ReadOnly,"txtCSVFile")
      \btnBrowse=scsButtonGadget(gnNextX + 2,nTop,100,gnBtnHeight,LangEllipsis("Btns","Browse"),0,"btnBrowse")
      nTop + 23
      \lblFileType=scsTextGadget(28,nTop+4,120,17,Lang("WIC","lblFileType"),#PB_Text_Right,"lblFileType")
      \cboFileType=scsComboBoxGadget(gnNextX+gnGap,nTop,180,21,0,"cboFileType")
      
      nTop + 27
      nWidth = WindowWidth(#WIC)
      nHeight = 44
      \cntMidi=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntMidi")
        nTop = 0
        \lblLogicalDev=scsTextGadget(28,nTop+gnLblVOffsetS,120,17,Lang("WIC","lblLogicalDev"),#PB_Text_Right,"lblLogicalDev")
        \cboLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboLogicalDev")
        nTop + 21
        \lblChannel=scsTextGadget(28,nTop+gnLblVOffsetS,120,17,Lang("WIC","lblChannel"),#PB_Text_Right,"lblChannel")
        \cboMSChannel=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,0,"cboMSChannel")
      scsCloseGadgetList()
      setVisible(\cntMidi,#False)
      
      nTop = GadgetY(\cntMidi) + GadgetHeight(\cntMidi) + 3
      nWidth = WindowWidth(#WIC)
      nHeight = 44
      \cntExtras=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntOtherExtras")
        nTop = 0
        nLeft = GadgetX(\txtCSVFile)
        sCuePrefixLabel = Lang("WIC","lblCuePrefix")
        sDescrSplitLabel = Lang("WIC","lblDescrSplit1")
        nLabelLength = getMaxTextWidth(10,sCuePrefixLabel,sDescrSplitLabel) + 8
        \lblCuePrefix=scsTextGadget(8,nTop+5,nLabelLength,17,sCuePrefixLabel,#PB_Text_Right,"lblCuePrefix")
        If grProd\bLabelsUCase
          nFlags = #PB_String_UpperCase
        EndIf
        \txtCuePrefix=scsStringGadget(gnNextX+gnGap,nTop+2,40,19,"",nFlags,"txtCuePrefix")
        nTop + 22
        \lblDescrSplit1=scsTextGadget(8,nTop+5,nLabelLength,17,sDescrSplitLabel,#PB_Text_Right,"lblDescrSplit1")
        \txtDescrSplit=scsStringGadget(gnNextX+gnGap,nTop+2,23,19,"",0,"txtDescrSplit")
        SetGadgetAttribute(\txtDescrSplit,#PB_String_MaximumLength,1)
        \lblDescrSplit2=scsTextGadget(gnNextX+gnGap,nTop+5,320,17,Lang("WIC","lblDescrSplit2"),0,"lblDescrSplit2")
      scsCloseGadgetList()
      
      nTop = GadgetY(\cntExtras) + GadgetHeight(\cntExtras) + 3
      nHeight = 62
      \cntControls=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntControls")
        nTop = 0
        nLeft = GadgetX(\txtCSVFile)
        \btnReadFile=scsButtonGadget(nLeft,nTop,150,gnBtnHeight,Lang("WIC","btnReadFile"),0,"btnReadFile")
        
        nTop + 28
        \lnSeparator=scsLineGadget(0,nTop,WindowWidth(#WIC),1,#SCS_Light_Grey,0,"lnSeparator")
        
        nTop + 5
        \btnSelectAll=scsButtonGadget(41,nTop,82,gnBtnHeight,Lang("WIM","btnSelectAll"),0,"btnSelectAll")
        \btnClearAll=scsButtonGadget(129,nTop,82,gnBtnHeight,Lang("WIM","btnClearAll"),0,"btnClearAll")
        \lblGridTitle=scsTextGadget(230,nTop+gnLblVOffsetS,312,21,Lang("WIM","lblGridTitle"),0,"lblGridTitle")
        scsSetGadgetFont(\lblGridTitle, #SCS_FONT_GEN_BOLD10)
      scsCloseGadgetList()
      
      nTop = GadgetY(\cntControls) + GadgetHeight(\cntControls)
      nHeight = WindowHeight(#WIC) - nTop - nCntBelowGridHeight
      nLeft = 4
      nWidth = WindowWidth(#WIC) - (nLeft << 1)
      \grdAddCues=scsListIconGadget(nLeft, nTop, nWidth, nHeight, grText\sTextSelect,45,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdAddCues")
      AddGadgetColumn(\grdAddCues,1,Lang("Common","Cue"),65)
      AddGadgetColumn(\grdAddCues,2,Lang("Common","Page"),45)
      AddGadgetColumn(\grdAddCues,3,Lang("Common","Description"),210)
      AddGadgetColumn(\grdAddCues,4,Lang("Common","WhenReqd"),200)
      AddGadgetColumn(\grdAddCues,5,Lang("Common","CueType"),85)
      ; AddGadgetColumn(\grdAddCues,6,Lang("WIC","Disabled"),65)
      autoFitGridCol(\grdAddCues, 3) ; autofit "Description" column
      
      nTop = GadgetY(\grdAddCues) + GadgetHeight(\grdAddCues)
      nWidth = WindowWidth(#WIC)
      nHeight = WindowHeight(#WIC) - nTop
      \cntBelowGrid=scsContainerGadget(0,nTop,nWidth,nCntBelowGridHeight,0,"cntBelowGrid")
        nTop = 2
        nLeft = GadgetX(\grdAddCues) + 1
        nWidth = GadgetWidth(\grdAddCues) - 2
        \cvsProgress=scsCanvasGadget(nLeft,nTop,nWidth,6,0,"cvsProgress")
        nTop + 12
        \lblTargetCue=scsTextGadget(28,nTop+gnLblVOffsetS,197,18,Lang("WIM","lblTargetCue"), #PB_Text_Right,"lblTargetCue")
        scsSetGadgetFont(\lblTargetCue, #SCS_FONT_GEN_BOLD)
        \cboTargetCue=scsComboBoxGadget(232,nTop,282,21,0,"cboTargetCue")
        nTop + 27
        nLeft = 115
        \chkNewCueNos=scsCheckBoxGadget(nLeft,nTop,300,17,Lang("WIC","chkNewCueNos"),0,"chkNewCueNos")
        nWidth = GadgetWidth(\chkNewCueNos,#PB_Gadget_RequiredSize)
        ResizeGadget(\chkNewCueNos,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        nTop + 23
        nHeight = 23
        \btnAddSelected=scsButtonGadget(134,nTop,130,nHeight,Lang("WIM","btnAddSelected"),#PB_Button_Default,"btnAddSelected")
        AddKeyboardShortcut(#WIC, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
        \btnClose=scsButtonGadget(277,nTop,81,nHeight,Lang("Btns","Close"),0,"btnClose")
        AddKeyboardShortcut(#WIC, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
        \btnHelp=scsButtonGadget(372,nTop,81,nHeight,grText\sTextBtnHelp,0,"btnHelp")
        ; plus 10 padding
      scsCloseGadgetList()
    EndWith
    ; setWindowVisible(#WIC,#True)
    setWindowEnabled(#WIC,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWID ; fmImportDevs
  btnImportDevs.i
  btnBrowse.i
  btnCancel.i
  btnClearAll.i
  btnFavorites.i
  btnHelp.i
  btnSelectAll.i
  cntBelowGrid.i
  grdDevs.i
  lblCueFile.i
  lblGridTitle.i
  lblInfoMsg.i
  lblProdTitle.i
  txtCueFile.i
  txtProdTitle.i
EndStructure
Global WID.strWID ; fmImportDevs

Procedure createfmImportDevs()
  PROCNAMEC()
  Protected nFlags
  Protected nLeft, nTop, nWidth, nHeight
  Protected nCntBelowGridHeight
  Protected sCueFileLabel.s, sProdTitleLabel.s
  Protected nLabelLength, nFieldWidth
  
  ; note: shares some language strings with WIM (fmImport)
  
  ; nCntBelowGridHeight = 105
  nCntBelowGridHeight = 95 ; 50
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nFlags = #PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible ; | #PB_Window_SizeGadget
  If OpenWindow(#WID, 0, 0, 587, 560, Lang("WID","Window"), nFlags, WindowID(#WED))
    registerWindow(#WID, "WID(fmImportDevs)")
    With WID
      nTop = 16  ; nb min value = 12 because of required 'top' position of btnBrowse
      sCueFileLabel = Lang("WID","lblCueFile")
      sProdTitleLabel = Lang("WIM","lblProdTitle")
      nLabelLength = getMaxTextWidth(10,sCueFileLabel,sProdTitleLabel) + 8
      nFieldWidth = 459 - nLabelLength
      \lblCueFile=scsTextGadget(8,nTop+gnLblVOffsetS,nLabelLength,17,sCueFileLabel,#PB_Text_Right,"lblCueFile")
      \txtCueFile=scsStringGadget(gnNextX+gnGap,nTop,nFieldWidth,19,"",#PB_String_ReadOnly,"txtCueFile")
      \btnBrowse=scsButtonGadget(476,nTop-12,100,gnBtnHeight,LangEllipsis("Btns","Browse"),0,"btnBrowse")
      \btnFavorites=scsButtonGadget(476,nTop+11,100,gnBtnHeight,LangEllipsis("WIM","btnFavorites"),0,"btnFavorites")
      nTop + 36
      \lblProdTitle=scsTextGadget(8,nTop+gnLblVOffsetS,nLabelLength,16,sProdTitleLabel,#PB_Text_Right,"lblProdTitle")
      \txtProdTitle=scsStringGadget(gnNextX+gnGap,nTop,nFieldWidth,19,"",#PB_String_ReadOnly,"txtProdTitle")
      setEnabled(\txtProdTitle, #False)
      nTop + 40
      \btnSelectAll=scsButtonGadget(41,nTop,82,gnBtnHeight,Lang("WIM","btnSelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(129,nTop,82,gnBtnHeight,Lang("WIM","btnClearAll"),0,"btnClearAll")
      \lblGridTitle=scsTextGadget(230,nTop+gnLblVOffsetS,312,21,Lang("WID","lblGridTitle"),0,"lblGridTitle")
      scsSetGadgetFont(\lblGridTitle, #SCS_FONT_GEN_BOLD10)
      
      nTop + 25
      nHeight = WindowHeight(#WID) - nTop - nCntBelowGridHeight
      nLeft = 32
      nWidth = WindowWidth(#WID) - (nLeft << 1)
      \grdDevs=scsMyGridGadget(#WID,nLeft, nTop, nWidth, nHeight, 25,2,#True,#True,#False,"grdDevs")
      nTop + nHeight
      nWidth = WindowWidth(#WID)
      nHeight = WindowHeight(#WID) - nTop
      \cntBelowGrid=scsContainerGadget(0,nTop,nWidth,nCntBelowGridHeight,0,"cntBelowGrid")
        nTop = 8
        nLeft = GadgetX(\grdDevs) + 1
        nWidth = GadgetWidth(\cntBelowGrid) - nLeft - nLeft
        \lblInfoMsg=scsTextGadget(nLeft,nTop,nWidth-16,35,"",0,"lblInfoMsg")
        nTop + 37
        nHeight = 23
        \btnImportDevs=scsButtonGadget(124,nTop,150,nHeight,Lang("WID","btnImportDevs"),#PB_Button_Default,"btnImportDevs")
        AddKeyboardShortcut(#WID, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
        \btnCancel=scsButtonGadget(297,nTop,81,nHeight,grText\sTextBtnCancel,0,"btnCancel")
        AddKeyboardShortcut(#WID, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
        \btnHelp=scsButtonGadget(392,nTop,81,nHeight,grText\sTextBtnHelp,0,"btnHelp")
      scsCloseGadgetList()
    EndWith
    setWindowEnabled(#WID,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWMI ; fmInfoMsg
  cntInfoMsg.i
  lblInfoMsg1.i
  lblInfoMsg2.i
  prbInfoProgress.i
EndStructure
Global WMI.strWMI ; fmInfoMsg

Procedure createfmInfoMsg()
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight, bWindowCreated
  Protected nLeft, nTop, nWidth, nHeight
  Protected nPrevWindowNo

  debugMsg(sProcName, #SCS_START)
  
  nPrevWindowNo = gnCurrentWindowNo ; Added 28Jun2021 11.8.5ao
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL10)
  CompilerIf #c_show_infomsg_cancel
    nWindowHeight = 134
    nWindowWidth = 350
  CompilerElse
    nWindowHeight = 104
    nWindowWidth = 350
  CompilerEndIf
  If OpenWindow(#WMI, 0, 0, nWindowWidth, nWindowHeight, "", #PB_Window_ScreenCentered | #PB_Window_Invisible)  ; #PB_Window_BorderLess 
    registerWindow(#WMI, "WMI(fmInfoMsg)")
    With WMI
      nLeft = 12
      nTop = 12
      nWidth = nWindowWidth - (nLeft << 1)
      CompilerIf #c_show_infomsg_cancel
        nHeight = nWindowHeight - (nTop << 1) - 40
      CompilerElse
        nHeight = nWindowHeight - (nTop << 1)
      CompilerEndIf
      \cntInfoMsg=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntInfoMsg")
        \lblInfoMsg1=scsTextGadget(2,12,GadgetWidth(\cntInfoMsg)-4,18,"",#PB_Text_Center,"lblInfoMsg1")
        \lblInfoMsg2=scsTextGadget(2,30,GadgetWidth(\cntInfoMsg)-4,18,"",#PB_Text_Center,"lblInfoMsg2")
        nWidth = 200
        nLeft = (GadgetWidth(\cntInfoMsg) - nWidth) >> 1
        \prbInfoProgress=scsProgressBarGadget(nLeft,50,nWidth,12,1,10,#PB_ProgressBar_Smooth,"prbInfoProgress")
      scsCloseGadgetList()
      CompilerIf #c_show_infomsg_cancel
        nTop = GadgetY(\cntInfoMsg) + GadgetHeight(\cntInfoMsg) + 8
        \btnCancel=scsButtonGadget(250,nTop,81,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      CompilerEndIf
    EndWith
    setWindowEnabled(#WMI,#True)
    bWindowCreated = #True
  EndIf
  ; Added 28Jun2021 11.8.5ao
  If IsWindow(nPrevWindowNo)
    setCurrWindowGlobals(nPrevWindowNo)
  EndIf
  ; End added 28Jun2021 11.8.5ao
  
  ProcedureReturn bWindowCreated
  
EndProcedure

Structure strWCI ; fmCurrInfo
  btnOK.i
  cvsCurrInfo.i
EndStructure
Global WCI.strWCI ; fmCurrInfo

Procedure createfmCurrInfo()
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Protected nFlags
  Protected nLeft, nTop, nWidth, nWidthLeft, nWidthRight, nHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL10)
  nWindowHeight = 450
  nWindowWidth = 550
  nFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible
  If OpenWindow(#WCI, 0, 0, nWindowWidth, nWindowHeight, Lang("Info", "Hdg"), nFlags, WindowID(#WMN))
    registerWindow(#WCI, "WCI(fmCurrInfo)")
    With WCI
      nLeft = 12
      nTop = 12
      nWidth = nWindowWidth - (nLeft << 1)
      nHeight = nWindowHeight - (nTop << 1) - 40
      \cvsCurrInfo=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsCurrInfo")
      nLeft = nWindowWidth - 120
      nTop = GadgetY(\cvsCurrInfo) + GadgetHeight(\cvsCurrInfo) + 8
      \btnOK=scsButtonGadget(nLeft,nTop,81,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
    EndWith
    setWindowEnabled(#WCI,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWLC ; fmLabelChange
  btnCancel.i
  btnOK.i
  btnReset.i
  btnSelectAll.i
  btnViewChanges.i
  cboEndCue.i
  cboStartCue.i
  btnHelp.i
  grdPreview.i
  lblCueLabel.i
  lblEndCue.i
  lblPreview.i
  lblRenumberIncrement.i
  lblStartCue.i
  txtCueLabel.i
  txtRenumberIncrement.i
EndStructure
Global WLC.strWLC ; fmLabelChange

Procedure createfmLabelChange()
  PROCNAMEC()
  Protected nTop
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WLC, 0, 0, 700, 410, Lang("WLC","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WLC, "WLC(fmLabelChange)")
    With WLC
      nTop = 25
      \btnSelectAll=scsButtonGadget(13,nTop,178,gnBtnHeight,Lang("WLC","btnSelectAll"),0,"btnSelectAll")
      nTop + 29
      \lblStartCue=scsTextGadget(13,nTop,152,15,Lang("WLC","lblStartCue"),0,"lblStartCue")
      nTop + 16
      \cboStartCue=scsComboBoxGadget(13,nTop,178,21,0,"cboStartCue")
      scsToolTip(\cboStartCue,Lang("WLC","cboStartCueTT"))
      nTop + 29
      \lblEndCue=scsTextGadget(13,nTop,152,15,Lang("WLC","lblEndCue"),0,"lblEndCue")
      nTop + 16
      \cboEndCue=scsComboBoxGadget(13,nTop,178,21,0,"cboEndCue")
      scsToolTip(\cboEndCue,Lang("WLC","cboEndCueTT"))
      nTop + 35
      \lblCueLabel=scsTextGadget(13,nTop,155,29,Lang("WLC","lblCueLabel"),0,"lblCueLabel")
      nTop + 32
      \txtCueLabel=scsStringGadget(68,nTop,68,22,"",0,"txtCueLabel")
      nTop + 34
      \lblRenumberIncrement=scsTextGadget(13,nTop,155,17,Lang("WLC","lblRenumberIncrement"),0,"lblRenumberIncrement")
      nTop + 18
      \txtRenumberIncrement=scsStringGadget(68,nTop,68,22,"",#PB_String_Numeric,"txtRenumberIncrement")
      nTop + 65
      \btnViewChanges=scsButtonGadget(58,nTop,87,gnBtnHeight,Lang("WLC","btnViewChanges"),0,"btnViewChanges")
      scsToolTip(\btnViewChanges,Lang("WLC","btnViewChangesTT"))
      nTop + 35
      \btnReset=scsButtonGadget(58,nTop,87,gnBtnHeight,Lang("Btns","Reset"),0,"btnReset")
      scsToolTip(\btnReset,Lang("WLC","btnResetTT"))
      
      \lblPreview=scsTextGadget(211,9,136,12,Lang("WLC","lblPreview"),0,"lblPreview")
      \grdPreview=scsListIconGadget(202,26,486,340,Lang("WLC","CueNo"),60,
                                    #PB_ListIcon_GridLines|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_MultiSelect|#PB_ListIcon_FullRowSelect,"grdPreview")
      AddGadgetColumn(\grdPreview,1,Lang("WLC","NewNo"),60)
      AddGadgetColumn(\grdPreview,2,Lang("Common","Page"),50)
      AddGadgetColumn(\grdPreview,3,Lang("Common","CueType"),100)
      AddGadgetColumn(\grdPreview,4,Lang("Common","Description"),168)
      autoFitGridCol(\grdPreview,4) ; autofit "Description" column - see also call to autoFitGridCol() in WLC_formLoad()
      
      \btnOK=scsButtonGadget(214,378,81,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      scsToolTip(\btnOK,Lang("WLC","btnOKTT"))
      \btnCancel=scsButtonGadget(311,378,81,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(408,378,81,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
    EndWith
    ; setWindowVisible(#WLC,#True)
    setWindowEnabled(#WLC,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWMC ; fmMultiCueCopyEtc
  btnCancel.i
  btnNext.i
  btnPrev.i
  btnOK.i
  btnReset.i
  btnViewChanges.i
  cboActionReqd.i
  cboLastCue.i
  cboFirstCue.i
  cboSearchCC.i
  cboTargetCue.i
  cntSearchResults.i
  btnHelp.i
  frmSortType.i
  nFirstSelectedCueIndex.i
  nSecondSelectedCueIndex.i
  grdPreview.i
  nIdxSearchResultSelected.i
  lblActionReqd.i
  lblCueLabel.i
  lblLastCue.i
  lblPreview.i
  lblCueNumberIncrement.i
  lblFirstCue.i
  lblSearchCC.i
  lblSearchCount.i
  lblSearchTextCC.i
  lblTargetCue.i
  lblSortDirectionAsc.i
  lblSortDirectionDec.i
  txtCueLabel.i
  txtCueNumberIncrement.i
  txtSearchTextCC.i
  List nRowSelectors.i()
EndStructure
Global WMC.strWMC ; fmMultiCueCopyEtc

Procedure createfmMultiCueCopyEtc()
  PROCNAMEC()
  Protected nLeft, nTop
  Protected nLabelWidth
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WMC, 0, 0, 800, 410, LangWithAlt("WMC","Window2","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WMC, "WMC(fmMultiCueCopyEtc)")
    With WMC
      nLeft = 13
      nTop = 15
      nLabelWidth = 250
      \lblActionReqd=scsTextGadget(nLeft,nTop,nLabelWidth,15,Lang("WMC","lblActionReqd"),0,"lblActionReqd")
      \cboActionReqd=scsComboBoxGadget(nLeft,nTop+17,120,21,0,"cboActionReqd")
      \lblSearchCC=scsTextGadget(nLeft + 172,nTop,nLabelWidth,15,Lang("WMC","lblSearchCC"),0,"lblSearchCC")
      \cboSearchCC=scsComboBoxGadget(nLeft + 130,nTop + 18,120,21,0,"cboSearchCC")
      nTop + 48
      \lblSearchTextCC=scsTextGadget(nLeft,nTop,160,29,Lang("WMC","lblSearchTextCC"),0,"lblSearchTextCC")
      \txtSearchTextCC=scsStringGadget(nLeft,nTop + 18,120,21,"",0,"txtSearchTextCC")
      ;\btnOK=scsButtonGadget(164,378,81,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")

      ;nTop + 48 
      \lblFirstCue=scsTextGadget(nLeft,nTop,nLabelWidth,15,"",0,"lblFirstCue")
      \cboFirstCue=scsComboBoxGadget(nLeft,nTop+17,nLabelWidth,21,0,"cboFirstCue")
      nTop + 40
      \lblLastCue=scsTextGadget(nLeft,nTop,nLabelWidth,15,"",0,"lblLastCue")
      \cboLastCue=scsComboBoxGadget(nLeft,nTop+17,nLabelWidth,21,0,"cboLastCue")
      nTop + 48
      \lblTargetCue=scsTextGadget(nLeft,nTop,nLabelWidth,15,"",0,"lblTargetCue")
      \cboTargetCue=scsComboBoxGadget(nLeft,nTop+17,nLabelWidth,21,0,"cboTargetCue")
      nTop + 50
      \lblCueLabel=scsTextGadget(nLeft,nTop,160,29,Lang("WMC","lblCueLabel"),#PB_Text_Right,"lblCueLabel")
      \txtCueLabel=scsStringGadget(nLeft+167,nTop,50,21,"",0,"txtCueLabel")
      nTop + 34
      \lblCueNumberIncrement=scsTextGadget(nLeft,nTop+gnLblVOffsetS,160,15,Lang("WMC","lblCueNumberIncrement"),#PB_Text_Right,"lblCueNumberIncrement")
      ; \txtCueNumberIncrement=scsStringGadget(nLeft+167,nTop,50,22,"",#PB_String_Numeric,"txtCueNumberIncrement")
      \txtCueNumberIncrement=scsStringGadget(nLeft+167,nTop,50,22,"",0,"txtCueNumberIncrement")
      nTop + 48
      \btnViewChanges=scsButtonGadget(nLeft,nTop,87,gnBtnHeight,Lang("WMC","btnViewChanges"),0,"btnViewChanges")
      scsToolTip(\btnViewChanges,Lang("WMC","btnViewChangesTT"))
      \btnReset=scsButtonGadget(nLeft+130,nTop,87,gnBtnHeight,Lang("Btns","Reset"),0,"btnReset")
      scsToolTip(\btnReset,Lang("WMC","btnResetTT"))
      nTop + 34
      \lblSearchCount=scsTextGadget(nLeft+6,nTop+4,120,15,"",0, LangPars("WMC","lblSearchCount", "0", "0"))
      \btnPrev=scsButtonGadget(nLeft+126,nTop,60,gnBtnHeight,Lang("WMC","btnPrev"),0,"btnPrev")
      \btnNext=scsButtonGadget(nLeft+190,nTop,60,gnBtnHeight,Lang("WMC","btnNext"),0,"btnNext")
      
      nLeft = GadgetX(\lblActionReqd) + GadgetWidth(\lblActionReqd) + 20
      \lblPreview=scsTextGadget(nLeft+8,9,250,15,Lang("WMC","lblPreview1"),0,"lblPreview")
      \grdPreview=scsListIconGadget(nLeft,26,500,340,Lang("WMC","CueNo"),60,#PB_ListIcon_GridLines|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_MultiSelect|#PB_ListIcon_FullRowSelect,"grdPreview")
      AddGadgetColumn(\grdPreview,1,Lang("Common","Page"),50)
      AddGadgetColumn(\grdPreview,2,Lang("Common","CueType"),100)
      AddGadgetColumn(\grdPreview,3,Lang("Common","Description"),168)
      autoFitGridCol(\grdPreview,3) ; autofit "Description" column - see also call to autoFitGridCol() in WMC_resetGrid()

      \btnOK=scsButtonGadget(164,378,81,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      scsToolTip(\btnOK,Lang("WMC","btnOKTT"))
      \btnCancel=scsButtonGadget(261,378,81,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(358,378,81,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
    EndWith
    
    ; setWindowVisible(#WMC,#True)
    setWindowEnabled(#WMC,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWLE ; fmLockEditor
  btnCancel.i
  btnForgot.i
  btnLock.i
  btnSetPassword.i
  cntLock.i
  cntSetPassword.i
  cvsAuthStringEye.i
  cvsLockPasswordEye.i
  cvsNew1Eye.i
  cvsNew2Eye.i
  frLock.i
  frSetPassword.i
  lblLockIntro.i
  lblLockPassword.i
  lblNew1.i
  lblNew2.i
  lblAuthString.i
  lblSetPassword.i[2]
  txtAuthString.i
  txtLockPassword.i
  txtNew1.i
  txtNew2.i
EndStructure
Global WLE.strWLE ; fmLockEditor

Procedure createfmLockEditor()
  PROCNAMEC()
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WLE, 0, 0, 495, 307, Lang("WLE","WindowLock"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WOP))
    registerWindow(#WLE, "WLE(fmLockEditor)")
    With WLE
      \cntLock=scsContainerGadget(24,23,446,236,0,"cntLock")
        \frLock=scsFrameGadget(0,0,446,236,Lang("WLE","WindowLock"),0,"frLock")   ; this frame title is same as window title
        scsSetGadgetFont(\frLock, #SCS_FONT_GEN_BOLD)
        \lblLockIntro=scsTextGadget(19,44,394,27,Lang("WLE","IntroLock"),0,"lblLockIntro")
        \lblLockPassword=scsTextGadget(16,91,157,18,Lang("WLE","lblLockPassword"), #PB_Text_Right, "lblLockPassword")
        \txtLockPassword=scsStringGadget(180,87,155,21,"",#PB_String_Password,"txtLockPassword")
        \cvsLockPasswordEye=scsCanvasGadget(gnNextX,87,21,21,0,"cvsLockPasswordEye")
        \btnLock=scsButtonGadget(180,116,76,26,Lang("WLE","Lock"),#PB_Button_Default,"btnLock")
        \btnForgot=scsButtonGadget(60,160,325,50,Lang("WLE","btnForgot"),#PB_Button_MultiLine,"btnForgot")
      scsCloseGadgetList()
      
      \cntSetPassword=scsContainerGadget(24,23,446,236,0,"cntSetPassword")
        \frSetPassword=scsFrameGadget(0,0,446,236,Lang("WLE","frSetPassword"),0,"frSetPassword")
        scsSetGadgetFont(\frSetPassword, #SCS_FONT_GEN_BOLD)
        \lblSetPassword[0]=scsTextGadget(23,27,360,36,Lang("WLE","lblSetPassword[0]"))
        \lblAuthString=scsTextGadget(2,70,220,18,Lang("WLE","lblAuthString"),#PB_Text_Right,"lblAuthString")
        \txtAuthString=scsStringGadget(231,65,155,21,"",#PB_String_UpperCase|#PB_String_Password,"txtAuthString")
        \cvsAuthStringEye=scsCanvasGadget(gnNextX,65,21,21,0,"cvsAuthStringEye")
        \lblSetPassword[1]=scsTextGadget(25,100,400,25,Lang("WLE","lblSetPassword[1]"))
        \lblNew1=scsTextGadget(2,135,220,18,Lang("WLE","lblNew1"),#PB_Text_Right,"lblNew1")
        \txtNew1=scsStringGadget(231,129,155,21,"",#PB_String_Password,"txtNew1")
        \cvsNew1Eye=scsCanvasGadget(gnNextX,129,21,21,0,"cvsNew1Eye")
        \lblNew2=scsTextGadget(2,158,220,18,Lang("WLE","lblNew2"),#PB_Text_Right,"lblNew2")
        \txtNew2=scsStringGadget(231,154,155,21,"",#PB_String_Password,"txtNew2")
        \cvsNew2Eye=scsCanvasGadget(gnNextX,154,21,21,0,"cvsNew2Eye")
        \btnSetPassword=scsButtonGadget(231,193,89,26,Lang("WLE","btnSetPassword"),0,"btnSetPassword")
      scsCloseGadgetList()
      setVisible(\cntSetPassword,#False)
      
      \btnCancel=scsButtonGadget(394,272,76,26,grText\sTextBtnCancel,0,"btnCancel")
      
    EndWith
    ; setWindowVisible(#WLE,#True)
    setWindowEnabled(#WLE,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWLP ; fmLoadProd
  btnBrowseE.i
  btnCancel.i
  btnCloseSCS.i
  btnCreateNew.i
  btnCreateT.i
  btnManageF.i
  btnManageT.i
  btnOpenE.i
  btnOpenF.i
  btnOptions.i
  btnRegister.i
  cboAudioDriver.i
  cboAudPrimaryDev.i
  chkShowAtStart.i
  cntAction.i
  cntChoice.i
  cntNew.i
  cntUpdateAvailable.i
  imgLoadLogo.i
  lblAudioDriver.i
  lblAudPrimaryDev.i
  lblDevMapName.i
  lblTitle.i
  lblUpdateAvailable1.i
  lblUpdateAvailable2.i
  lnSeparator.i[3]
  scaFavorites.i
  scaFiles.i
  scaTemplates.i
  txtDevMapName.i
  txtTitle.i
  Array cvsChoice.i(3)
  Array cvsExisting.i(0)
  Array cvsFavorite.i(0)
  Array cvsTemplate.i(0)
EndStructure
Global WLP.strWLP ; fmLoadProd

Procedure createWLPExistingIfReqd()
  PROCNAMEC()
  Protected nReqdArraySize, n, nTop
  Protected nOldGadgetList
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nCanvasWidth
  
  With WLP
    nReqdArraySize = gnRecentFileCount - 1
    If nReqdArraySize < 0
      nReqdArraySize = 0
    ElseIf nReqdArraySize > #SCS_MAXRFL_DISPLAYED
      nReqdArraySize = #SCS_MAXRFL_DISPLAYED
    EndIf
    
    If IsGadget(\scaFiles)
      ; only recreate the gadgets if the array size is to be changed
      If ArraySize(\cvsExisting()) = nReqdArraySize
        ProcedureReturn
      EndIf
    EndIf
    
    nOldGadgetList = UseGadgetList(WindowID(#WLP))
    ; note: \scaFiles must be created within the scope of UseGadgetList() or the \cvsExisting events will not be reported as Gadget events
    If IsGadget(\scaFiles)
      scsFreeGadget(\scaFiles)
    EndIf
    
    nScrollAreaWidth = grWLP\nScaWidth - glScrollBarWidth - 4
    nScrollAreaHeight = (grWLP\nFileHeight * (nReqdArraySize + 1)) + gl3DBorderAllowanceY
    nCanvasWidth = grWLP\nScaWidth - glScrollBarWidth - 4
    ReDim \cvsExisting(nReqdArraySize)
    
    \scaFiles=scsScrollAreaGadget(0,grWLP\nScaTop,grWLP\nScaWidth,grWLP\nScaHeight,nScrollAreaWidth,nScrollAreaHeight,grWLP\nFileHeight,#PB_ScrollArea_BorderLess,"scaFiles")
      For n = 0 To nReqdArraySize
        \cvsExisting(n) = scsCanvasGadget(0,nTop,nCanvasWidth,grWLP\nFileHeight,0,"cvsExisting(" + n + ")")
        nTop + grWLP\nFileHeight
      Next n
    scsCloseGadgetList()
    setVisible(\scaFiles, #False)
    
    UseGadgetList(nOldGadgetList)
  EndWith
  
EndProcedure

Procedure createWLPFavoritesIfReqd()
  PROCNAMEC()
  Protected nReqdArraySize, n, nTop
  Protected nOldGadgetList
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nCanvasWidth
  
  With WLP
    nReqdArraySize = gnFavFileCount - 1
    If nReqdArraySize < 0
      nReqdArraySize = 0
    ElseIf nReqdArraySize > #SCS_MAXRFL_DISPLAYED
      nReqdArraySize = #SCS_MAXRFL_DISPLAYED
    EndIf
    
    If IsGadget(\scaFavorites)
      ; only recreate the gadgets if the array size is to be changed
      If ArraySize(\cvsFavorite()) = nReqdArraySize
        ProcedureReturn
      EndIf
    EndIf
    
    nOldGadgetList = UseGadgetList(WindowID(#WLP))
    ; note: \scaFavorites must be created within the scope of UseGadgetList() or the \cvsFavorite events will not be reported as Gadget events
    If IsGadget(\scaFavorites)
      scsFreeGadget(\scaFavorites)
    EndIf
    
    nScrollAreaWidth = grWLP\nScaWidth - glScrollBarWidth - 4
    nScrollAreaHeight = (grWLP\nFavoriteHeight * (nReqdArraySize + 1)) + gl3DBorderAllowanceY
    nCanvasWidth = grWLP\nScaWidth - glScrollBarWidth - 2
    ReDim \cvsFavorite(nReqdArraySize)
    
    \scaFavorites=scsScrollAreaGadget(0,grWLP\nScaTop,grWLP\nScaWidth,grWLP\nScaHeight,nScrollAreaWidth,nScrollAreaHeight,grWLP\nFavoriteHeight,#PB_ScrollArea_BorderLess,"scaFavorites")
      For n = 0 To nReqdArraySize
        \cvsFavorite(n) = scsCanvasGadget(0,nTop,nCanvasWidth,grWLP\nFavoriteHeight,0,"cvsFavorite(" + n + ")")
        nTop + grWLP\nFavoriteHeight
      Next n
    scsCloseGadgetList()
    setVisible(\scaFavorites, #False)
    
    UseGadgetList(nOldGadgetList)
  EndWith
  
EndProcedure

Procedure createWLPTemplatesIfReqd()
  PROCNAMEC()
  Protected nReqdArraySize, n, nTop
  Protected nOldGadgetList
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nCanvasWidth
  
  With WLP
    nReqdArraySize = gnTemplateCount - 1
    If nReqdArraySize < 0
      nReqdArraySize = 0
    ElseIf nReqdArraySize > #SCS_MAXRFL_DISPLAYED
      nReqdArraySize = #SCS_MAXRFL_DISPLAYED
    EndIf
    
    If IsGadget(\scaTemplates)
      ; only recreate the gadgets if the array size is to be changed
      If ArraySize(\cvsTemplate()) = nReqdArraySize
        ProcedureReturn
      EndIf
    EndIf
    
    nOldGadgetList = UseGadgetList(WindowID(#WLP))
    ; note: \scaTemplates must be created within the scope of UseGadgetList() or the \cvsTemplate events will not be reported as Gadget events
    If IsGadget(\scaTemplates)
      scsFreeGadget(\scaTemplates)
    EndIf
    
    nScrollAreaWidth = grWLP\nScaWidth - glScrollBarWidth - 4
    nScrollAreaHeight = (grWLP\nTemplateHeight * (nReqdArraySize + 1)) + gl3DBorderAllowanceY
    nCanvasWidth = grWLP\nScaWidth - glScrollBarWidth - 2
    ReDim \cvsTemplate(nReqdArraySize)
    
    \scaTemplates=scsScrollAreaGadget(0,grWLP\nScaTop,grWLP\nScaWidth,grWLP\nScaHeight,nScrollAreaWidth,nScrollAreaHeight,grWLP\nTemplateHeight,#PB_ScrollArea_BorderLess,"scaTemplates")
      For n = 0 To nReqdArraySize
        \cvsTemplate(n) = scsCanvasGadget(0,nTop,nCanvasWidth,grWLP\nTemplateHeight,0,"cvsTemplate(" + n + ")")
        nTop + grWLP\nTemplateHeight
      Next n
    scsCloseGadgetList()
    setVisible(\scaTemplates, #False)
    
    UseGadgetList(nOldGadgetList)
  EndWith
  
EndProcedure

Procedure createfmLoadProd(nParentWindow)
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight
  Protected nGap
  Protected nTextWidth
  Protected nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight
  Protected nFlags
  Protected n
  Protected nLogoLeft, nLogoTop, nLogoWidth, nLogoHeight
  Protected nChoiceLeft, nChoiceTop, nChoiceWidth, nChoiceHeight
  Protected nDetailTop, nDetailHeight
  Protected nActionTop, nActionHeight
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nItemWidth
  Protected nBtnLeft, nBtnWidth, nBtnHeight, nBtnGap
  Protected nReqdWidth, nReqdLeft
  Protected nArraySize
  Protected nLblLeft, nLblWidth
  Static nTextHeightNormal, nTextHeightNormal9, nTextHeightNormal10
  Static nBtnPadding  ; used for dynamically-sized buttons (btnCreate1, btnCreate2 and btnOpen)
  Static bStaticLoaded
  
  Debug sProcName + ": nParentWindow=" + decodeWindow(nParentWindow)
  
  If IsWindow(#WLP)
    If gaWindowProps(#WLP)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WLP)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  If bStaticLoaded = #False
    nTextHeightNormal = GetTextHeight("yY", #SCS_FONT_GEN_NORMAL)
    nTextHeightNormal9 = GetTextHeight("yY", #SCS_FONT_GEN_NORMAL9)
    nTextHeightNormal10 = GetTextHeight("yY", #SCS_FONT_GEN_BOLD10)
    nBtnPadding = 8
    bStaticLoaded = #True
  EndIf
  If grWLP\nFileHeight = 0
    grWLP\nFileHeight = nTextHeightNormal10 + nTextHeightNormal + 11
    grWLP\nFavoriteHeight = grWLP\nFileHeight
    ; grWLP\nTemplateHeight = nTextHeightNormal10 + (nTextHeightNormal9 * 2) + nTextHeightNormal + 13
    grWLP\nTemplateHeight = nTextHeightNormal10 + (nTextHeightNormal9 * 2) + 11
  EndIf

  nWindowWidth = 640
  nChoiceTop = 0
  nChoiceHeight = 60
  nLogoWidth = ImageWidth(hLoadScreenLogo)
  nLogoHeight = ImageHeight(hLoadScreenLogo)
  If nLogoHeight >= nChoiceHeight
    ; shouldn't happen
    nLogoHeight = nChoiceHeight
    nLogoWidth = nLogoHeight
  EndIf
  nLogoTop = (nChoiceHeight - nLogoHeight) >> 1
  nLogoLeft = nLogoTop
  nChoiceLeft = nLogoLeft + nLogoWidth
  nChoiceWidth = nWindowWidth - nChoiceLeft
  nDetailTop = nChoiceTop + nChoiceHeight + 1
  nDetailHeight = grWLP\nFileHeight * 9
  nActionHeight = 59 ; 38
  nActionTop = nDetailTop + nDetailHeight + 1
  nWindowHeight = nActionTop + nActionHeight
  
  nFlags = #PB_Window_SystemMenu | #PB_Window_TitleBar | #PB_Window_ScreenCentered | #PB_Window_MinimizeGadget
  adjustWindowPosIfReqd(@nWindowLeft, @nWindowTop, @nWindowWidth, @nWindowHeight, @nFlags)
  
  ; modified 15Jul2019 11.8.1.3ad because #WSP (the splash screen) becomes hidden, and if a hidden window is the parent of another window then
  ; that child window is not included in the task bar. Prior to this fix, when SCS was started and the Production Window (#WLP) was displayed,
  ; there was no SCS window shown in the task bar, which made it difficult to switch back to the SCS window if the user changed focus to
  ; some other application.
  If nParentWindow = #WSP
    If OpenWindow(#WLP, nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, Lang("WLP","Window"), nFlags)
      registerWindow(#WLP, "WLP(fmLoadProd)")
    EndIf
  ElseIf OpenWindow(#WLP, nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, Lang("WLP","Window"), nFlags, WindowID(nParentWindow))
    registerWindow(#WLP, "WLP(fmLoadProd)", nParentWindow)
  EndIf
  ; end modified 15Jul2019 11.8.1.3ad
  If IsWindow(#WLP)
    With WLP
      \imgLoadLogo=scsImageGadget(nLogoLeft,nLogoTop,nLogoWidth,nLogoHeight,ImageID(hLoadScreenLogo),0,"imgLoadLogo")
      DisableGadget(\imgLoadLogo, #True)
      \cntChoice=scsContainerGadget(nChoiceLeft,nChoiceTop,nChoiceWidth,nChoiceHeight,0,"cntChoice")
        nWidth = 120
        nGap = 4
        ; nLeft = (GadgetWidth(\cntChoice) - (nWidth * 4) - (nGap * 3)) >> 1
        ; nb \cvsChoice() gadgets will be repositioned etc in WLP_drawChoices() so what happens here doesn't really matter
        nLeft = GadgetWidth(\cntChoice) - (nWidth * 4) - (nGap * 3) - glScrollBarWidth - 8
        nTop = 4
        nHeight = GadgetHeight(\cntChoice) - (nTop * 2)
        For n = 0 To 3
          \cvsChoice(n)=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0, "cvsChoice(" + n + ")")
          nLeft + nWidth + nGap
        Next n
      scsCloseGadgetList()
      \lnSeparator[0]=scsLineGadget(0,(nDetailTop-1),nWindowWidth,1,#SCS_Line_Color,0,"lnSeparator[0]")
      \cntNew=scsContainerGadget(0,nDetailTop,nWindowWidth,nDetailHeight,0,"cntNew")
        nLblLeft = 4
        nLblWidth = 180
        nTop = 50
        \lblTitle=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblTitle"), #PB_Text_Right, "lblTitle")
        scsSetGadgetFont(\lblTitle, #SCS_FONT_GEN_BOLD)
        \txtTitle=scsStringGadget(gnNextX+gnGap,nTop,250,21,"",0,"txtTitle")
        scsSetGadgetFont(\txtTitle, #SCS_FONT_GEN_BOLD10)
        nTop + 50
        \lblDevMapName=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WLP","lblDevMapName"), #PB_Text_Right, "lblDevMapName")
        \txtDevMapName=scsStringGadget(gnNextX+gnGap,nTop,150,21,"",0,"txtDevMapName")
        nTop + 32
        \lblAudioDriver=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WEP","lblAudioDriver"),#PB_Text_Right,"lblAudioDriver")
        \cboAudioDriver=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboAudioDriver")
        scsToolTip(\cboAudioDriver,LangPars("WEP","OnThisComputerTT",Trim(GGT(\lblAudioDriver))))
        nTop + 32
        \lblAudPrimaryDev=scsTextGadget(nLblLeft,nTop+4,nLblWidth,15,Lang("WLP","lblAudPrimaryDev"),#PB_Text_Right,"lblAudPrimaryDev")
        \cboAudPrimaryDev=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboAudPrimaryDev")
      scsCloseGadgetList()
      setVisible(\cntNew, #False)
      
      nScrollAreaWidth = nWindowWidth - glScrollBarWidth - 4
      nItemWidth = nScrollAreaWidth
      
      ; \cvsFiles, \cvsFavorites and \cvsTemplates are mutually exclusive so occupy the same space (grWLP\nScaTop, etc)
      grWLP\nScaTop = nDetailTop
      grWLP\nScaWidth = WindowWidth(#WLP)
      grWLP\nScaHeight = nDetailHeight
      createWLPExistingIfReqd()
      createWLPFavoritesIfReqd()
      createWLPTemplatesIfReqd()
      
      CompilerIf #cDemo = #False And #cWorkshop = #False
        \lnSeparator[2]=scsLineGadget(0,(nActionTop-1),nWindowWidth,1,#SCS_Line_Color,0,"lnSeparator[2]")
        \cntUpdateAvailable=scsContainerGadget(0,nActionTop,nWindowWidth,42,0,"cntUpdateAvailable")
          \lblUpdateAvailable1=scsTextGadget(4,5,GadgetWidth(\cntUpdateAvailable)-8,15,"",#PB_Text_Center,"lblUpdateAvailable1")
          \lblUpdateAvailable2=scsTextGadget(4,22,GadgetWidth(\cntUpdateAvailable)-8,15,"",#PB_Text_Center,"lblUpdateAvailable2")
        scsCloseGadgetList()
        setVisible(\lnSeparator[2], #False)
        setVisible(\cntUpdateAvailable, #False)
      CompilerEndIf
      
      \lnSeparator[1]=scsLineGadget(0,(nActionTop-1),nWindowWidth,1,#SCS_Line_Color,0,"lnSeparator[1]")
      \cntAction=scsContainerGadget(0,nActionTop,nWindowWidth,nActionHeight,0,"cntAction")
        nBtnWidth = 81
        nBtnHeight = 27 ; gnBtnHeight
        nBtnGap = 8
        ; nTop = (nActionHeight - nBtnHeight) >> 1
        nTop = 2
        \chkShowAtStart = scsCheckBoxGadget(30,nTop+gnLblVOffsetS,80,17,Lang("WLP","chkShowAtStart"),0,"chkShowAtStart")
        setGadgetWidth(\chkShowAtStart)
        scsToolTip(\chkShowAtStart,Lang("WLP","chkShowAtStartTT"))
        nTop + 23
        ; close/cancel buttons - common to all choices (mutually exclusive as 'cancel' replaces 'close SCS' if NOT in initialization phase)
        nBtnLeft = GadgetWidth(\cntAction) - (nBtnWidth + nBtnGap)
        \btnCloseSCS = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("Btns","CloseSCS"),0,"btnCloseSCS")
        \btnCancel = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
        setVisible(\btnCancel, #False)
        
        ; register button - common to all choices
        nBtnLeft = GadgetX(\btnCloseSCS) - (nBtnWidth + nBtnGap)
        CompilerIf #cDemo = #False And #cWorkshop = #False
          \btnRegister = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnRegister"),0,"btnRegister")
          scsToolTip(\btnRegister, Lang("WLP","btnRegisterTT"))
          nReqdWidth = GadgetWidth(\btnRegister, #PB_Gadget_RequiredSize) + nBtnPadding
          nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
          ResizeGadget(\btnRegister, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
          nBtnLeft = GadgetX(\btnRegister) - (nBtnWidth + nBtnGap)
        CompilerEndIf
        
        ; options button - common to all choices
        \btnOptions = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnOptions"),0,"btnOptions")
        nReqdWidth = GadgetWidth(\btnOptions, #PB_Gadget_RequiredSize) + nBtnPadding
        nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
        ResizeGadget(\btnOptions, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        
        ; extra button for 'new' (btnCreateNew)
        nBtnLeft = GadgetX(\btnOptions) - (nBtnWidth + nBtnGap)
        \btnCreateNew = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnCreateNew"),#PB_Button_Default,"btnCreateNew")
        nReqdWidth = GadgetWidth(\btnCreateNew, #PB_Gadget_RequiredSize) + nBtnPadding
        nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
        ResizeGadget(\btnCreateNew, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        
        ; extra buttons for 'templates' (btnCreateT and btnManageT)
        nBtnLeft = GadgetX(\btnOptions) - ((nBtnWidth * 2) + (nBtnGap * 2))
        \btnCreateT = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnCreateT"),#PB_Button_Default,"btnCreateT")
        nReqdWidth = GadgetWidth(\btnCreateT, #PB_Gadget_RequiredSize) + nBtnPadding
        nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
        ResizeGadget(\btnCreateT, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        \btnManageT = scsButtonGadget(gnNextX+nBtnGap,nTop,nBtnWidth,nBtnHeight,Lang("Btns","Manage"),0,"btnManageT")
        
        ; extra buttons for 'favorites' (openF and manageF)
        nBtnLeft = GadgetX(\btnOptions) - ((nBtnWidth * 2) + (nBtnGap * 2))
        \btnOpenF = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnOpen"),#PB_Button_Default,"btnOpenF")
        nReqdWidth = GadgetWidth(\btnOpenF, #PB_Gadget_RequiredSize) + nBtnPadding
        nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
        ResizeGadget(\btnOpenF, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        \btnManageF = scsButtonGadget(gnNextX+nBtnGap,nTop,nBtnWidth,nBtnHeight,Lang("Btns","Manage"),0,"btnManageF")
        
        ; extra buttons for 'existing' (open4 and browse4)
        nBtnLeft = GadgetX(\btnOptions) - ((nBtnWidth * 2) + (nBtnGap * 2))
        \btnOpenE = scsButtonGadget(nBtnLeft,nTop,nBtnWidth,nBtnHeight,Lang("WLP","btnOpen"),#PB_Button_Default,"btnOpenE")
        nReqdWidth = GadgetWidth(\btnOpenE, #PB_Gadget_RequiredSize) + nBtnPadding
        nReqdLeft = nBtnLeft + nBtnWidth - nReqdWidth
        ResizeGadget(\btnOpenE, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        \btnBrowseE = scsButtonGadget(gnNextX+nBtnGap,nTop,nBtnWidth,nBtnHeight,Lang("Btns","Browse"),0,"btnBrowseE")
        
      scsCloseGadgetList()
      
      AddKeyboardShortcut(#WLP, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WLP, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    setWindowVisible(#WLP, #True)
    setWindowEnabled(#WLP, #True)
    StickyWindow(#WLP, #True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWNE ; fmNearEndWarning
  cvsNearEnd.i
EndStructure
Global WNE.strWNE ; fmNearEndWarning

Procedure createfmNearEndWarning()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  ; nb window and canvas will be resized in WNE_Form_Load() and possibly also in WNE_displayNearEndTime()
  If OpenWindow(#WNE, 0, 0, 350, 94, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WNE, "WNE(fmNearEndWarning)")
    SetWindowColor(#WNE, #SCS_Black)
    With WNE
      \cvsNearEnd=scsCanvasGadget(0,0,350,94,0,"cvsNearEnd")  ; do not use #PB_Canvas_ClipMouse as this limits dragging the window to the original canvas location
    EndWith
    ; setWindowVisible(#WNE,#True)
    setWindowEnabled(#WNE,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWCL ; fmClock
  cvsClock.i
  ; other fields
  sCurrentTime.s
  b12hrMode.i
  stt.s
EndStructure
Global WCL.strWCL ; fmClock

Procedure createfmClock()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  ; nb window and canvas will be resized in WCL_Form_Load() and possibly also in WCL_displayClock()
  If OpenWindow(#WCL, 0, 0, 250, 70, "", #PB_Window_SystemMenu| #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WCL, "WCL(fmClock)")
    SetWindowColor(#WCL, #SCS_Black)
    With WCL
      \cvsClock=scsCanvasGadget(0,0,250,70,0,"cvsClock")  ; do not use #PB_Canvas_ClipMouse as this limits dragging the window to the original canvas location
    EndWith
    setWindowEnabled(#WCL,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure

Structure strWCD ; fmCountdownClock
  cvsCountdown.i
  ; other fields
  sCompleteTime.s
  b12hrMode.i
  stt.s
  nTime.i
  bCountDownOccurred.i
  bFlashing.i
  nFlashingBackColor.l
  nCountDownTime.i
EndStructure
Global WCD.strWCD ; fmCountdownClock

Procedure createfmCountdownClock()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  ; nb window and canvas will be resized in WCD_Form_Load() and possibly also in WCD_displayCountdown()
  If OpenWindow(#WCD, 0, 0, 250, 70, "", #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WCD, "WCD(fmCountdownClock)")
    SetWindowColor(#WCD, #SCS_Black)
    With WCD
      \cvsCountdown=scsCanvasGadget(0,0,250,70,0,"cvsCountdown")  ; do not use #PB_Canvas_ClipMouse as this limits dragging the window to the original canvas location
    EndWith
    setWindowEnabled(#WCD,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf  
EndProcedure

Structure strWTC ; fmMTCDisplay
  cvsMTC.i
EndStructure
Global WTC.strWTC

Procedure createfmMTCDisplay()
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  ; nb window and canvas will be resized in WTC_Form_Load() and possibly also in WTC_displayNearEndTime()
  If OpenWindow(#WTC, 0, 0, 345, 87, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WTC, "WTC(fmMTCDisplay)")
    SetWindowColor(#WTC, #SCS_Black)
    With WTC
      \cvsMTC=scsCanvasGadget(0,0,345,87,0,"cvsMTC")  ; do not use #PB_Canvas_ClipMouse as this limits dragging the window to the original canvas location
    EndWith
    ; setWindowVisible(#WTC,#True)
    setWindowEnabled(#WTC,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWTI ; fmTimerDisplay
  cvsTimer.i
EndStructure
Global WTI.strWTI

Procedure createfmTimerDisplay()
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  ; nb window and canvas will be resized in WTI_Form_Load() and possibly also in WTI_displayNearEndTime()
  If OpenWindow(#WTI, 0, 0, 350, 94, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WTI, "WTI(fmTimerDisplay)")
    SetWindowColor(#WTI, #SCS_Black)
    With WTI
      \cvsTimer=scsCanvasGadget(0,0,350,94,0,"cvsTimer")  ; do not use #PB_Canvas_ClipMouse as this limits dragging the window to the original canvas location
    EndWith
    ; setWindowVisible(#WTI,#True)
    setWindowEnabled(#WTI,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWEN ; fmMemo
  cvsDragBar.i
  cvsCloseIcon.i
  cvsResizeIcon.i
  cvsStatusBar.i
  rchMemo.i
  rchMemoObject.RichEdit
EndStructure
Global Dim WEN.strWEN(1) ; fmMemo (index 0 = main; index 1 = preview)

Procedure createfmMemo(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected nIndex, sWENo.s
  Protected nParentWindow
  Protected nWindowWidth, nWindowHeight
  Protected nIconWidth
  Protected nMemoHeight, nDragBarHeight, nStatusBarHeight
  Protected nTop
  
  nIndex = nWindowNo - #WE1
  sWENo = Str(nIndex + 1)
  
  Select nWindowNo
    Case #WE1 ; main window
      nParentWindow = #WMN
      
    Case #WE2 ; preview window
      nParentWindow = #WED
      
  EndSelect
  
  ; scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nWindowWidth = 640
  nDragBarHeight = 15
  nMemoHeight = 480
  nStatusBarHeight = 15
  nIconWidth = 20
  nWindowHeight = nDragBarHeight + nMemoHeight + nStatusBarHeight
  
  If OpenWindow(nWindowNo, 0, 0, nWindowWidth, nWindowHeight, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(nWindowNo, "WE" + sWENo + "(fmMemo" + sWENo + ")")
    With WEN(nIndex)
      nTop = 0
      \cvsDragBar=scsCanvasGadget(0,nTop,nWindowWidth-nIconWidth,nDragBarHeight,0,"cvsDragBar")
      \cvsCloseIcon=scsCanvasGadget(gnNextX,nTop,nIconWidth,nDragBarHeight,0,"cvsCloseIcon")
      scsToolTip(\cvsCloseIcon,Lang("WEN","CloseTT"))
      nTop + nDragBarHeight
      \rchMemoObject = New_RichEdit(0, nTop, nWindowWidth, nMemoHeight)
      \rchMemoObject\SetInterface()
      \rchMemoObject\SetReadonly(#True)
      \rchMemo = \rchMemoObject\GetID()
      nTop + nMemoHeight
      \cvsStatusBar=scsCanvasGadget(0,nTop,nWindowWidth-nIconWidth,nStatusBarHeight,0,"cvsStatusBar")
      \cvsResizeIcon=scsCanvasGadget(gnNextX,nTop,nIconWidth,nDragBarHeight,0,"cvsResizeIcon")
      scsToolTip(\cvsResizeIcon,Lang("WEN","ResizeTT"))
    EndWith
    ; setWindowVisible(nWindowNo,#True)
    setWindowEnabled(nWindowNo,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWMN ; fmMain
  btnCloseTemplate.i
  btnShowFaders.i
  cntCtrlPanel.i
  cntDummyFirstForCueListMemoSplitter.i
  cntDummyFirstForMainMemoSplitter.i
  cntDummyFirstForPanelsHotkeysSplitter.i
  cntDummySecondForCueListMemoSplitter.i
  cntDummySecondForMainMemoSplitter.i
  cntGoAndMaster.i
  cntGoInfo.i
  cntLastPlayingInfo.i
  cntMasterFader.i
  cntMasterFaders.i
  cntMemo.i
  cntNorth.i
  cntSouth.i
  cntTemplate.i
  cntToolbarAndVU.i
  cvsMemoTitleBar.i
  cvsStatusBar.i
  cvsTouchPanel.i
  cvsVUDisplay.i
  cvsVULabels.i
  grdCues.i
  imgLastPlayingType.i
  imgType.i
  lblDemo.i
  lblGoInfo.i
  lblLastPlayingInfo.i
  lblLastPlayingCue.i
  lblMasterFader.i
  lblNextManualCue.i
  lblTemplateInfo.i
  lnGoAndMasterBorder.i
  rchMainMemo.i
  rchMainMemoObject.RichEdit
  scaCuePanels.l
  sldMasterFader.i
  splCueListMemo.i ; splitter between cue list (grdCues) and Memo, for memo that shares space with the cue list
  splMainMemo.i    ; splitter between cue list AND cue panels/hotkeys (cntNorthSouth) and Memo, for memo that shares space with the cue list
  splNorthSouth.i
  splPanelsHotkeys.i
  tbMain.i
  treHotkeys.i
  txtDummy.i
  ; the following used in and for Procedure SubclassedGrdCues()
  oldListIconCallback.i
  hHeader.i
  brush.i
EndStructure
Global WMN.strWMN ; fmMain

Procedure SubclassedGrdCues(hwnd, msg, wparam, lparam)
  ; derived from PB Forum posting by srod: https://www.purebasic.fr/english/viewtopic.php?p=229941
  Protected hdi.hd_item
  Protected result, *pnmh.NMHDR, *pnmcd.NMCUSTOMDRAW, text$
  Protected nGadgetNo
  
  nGadgetNo = WMN\grdCues
  
  result = CallWindowProc_(WMN\oldListIconCallback, hwnd, msg, wparam, lparam) 
  Select msg 
    Case #WM_NOTIFY 
      *pnmh.NMHDR = lparam 
      ;--> Get handle to ListIcon header control 
        If *pnmh\code = #NM_CUSTOMDRAW
        *pnmcd.NMCUSTOMDRAW = lparam 
        ;--> Determine drawing stage 
        Select *pnmcd\dwDrawStage 
          Case #CDDS_PREPAINT 
            result = #CDRF_NOTIFYITEMDRAW 
          Case #CDDS_ITEMPREPAINT 
;Get header text.
            text$ = " " + GetGadgetItemText(nGadgetNo, -1, *pnmcd\dwItemSpec) ; Added a " " at the start to provide better vertical alignment with text in the grid row columns
;Check button state.
            If *pnmcd\uItemState & #CDIS_SELECTED
              DrawFrameControl_(*pnmcd\hdc, *pnmcd\rc, #DFC_BUTTON, #DFCS_BUTTONPUSH|#DFCS_PUSHED)
;Offset text because of the selected button.
              *pnmcd\rc\left+2 : *pnmcd\rc\top+1
            Else
              DrawFrameControl_(*pnmcd\hdc, *pnmcd\rc, #DFC_BUTTON, #DFCS_BUTTONPUSH)
            EndIf
            *pnmcd\rc\bottom-1 : *pnmcd\rc\right-1
            SetBkMode_(*pnmcd\hdc,#TRANSPARENT)
;             If *pnmcd\dwItemSpec&1
;               FillRect_(*pnmcd\hdc, *pnmcd\rc, WMN\brush)
;               SetTextColor_(*pnmcd\hdc, #Blue) 
;             Else
;               FillRect_(*pnmcd\hdc, *pnmcd\rc, WMN\brush)
;               SetTextColor_(*pnmcd\hdc, #Red) 
;             EndIf
            FillRect_(*pnmcd\hdc, *pnmcd\rc, WMN\brush)
            SetTextColor_(*pnmcd\hdc, #SCS_GUI_TitleTextColor) 
            If *pnmcd\rc\right>*pnmcd\rc\left
              DrawText_(*pnmcd\hdc, @text$, Len(text$), *pnmcd\rc, #DT_LEFT|#DT_VCENTER|#DT_SINGLELINE|#DT_END_ELLIPSIS)
            EndIf
            result = #CDRF_SKIPDEFAULT
        EndSelect 
      EndIf 
  EndSelect 
  ProcedureReturn result 
EndProcedure 

Procedure createfmMain()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight, nTop2
  Protected nToolHeight
  Protected nCtrlPanelWidth, nCtrlPanelHeight
  Protected nCuePanelHeightStd, nCuePanelHeightSml
  Protected nCuePanelGap = 0
  Protected nMaxScreenHeight
  Protected n
  Protected nResult
  Protected nHeader
  Protected nFlags, sFlags.s
  Protected nInnerWidth, nInnerHeight
  Protected nWindowLeft, nWindowTop
  Protected nGoAndMasterWidth, nGoAndMasterHeight
  Protected nLastPlayingHeight, nGoInfoHeight
  Protected nMasterFadersWidth
  Protected nLabelLeft, nLabelWidth, nSliderLeft, nSliderWidth
  Protected sLabelPadding.s = Space(2)
  Protected nOldGadgetList
  Protected nStatusBarHeight = 17
  Protected style, newstyle, null.w
  
  debugMsg(sProcName, #SCS_START)
  
  nToolHeight = 80
  nCuePanelHeightStd = 58
  nCuePanelHeightSml = 20
  
  debugMsg(sProcName, "nToolHeight=" + nToolHeight + ", nCuePanelHeightStd=" + nCuePanelHeightStd + ", nCuePanelHeightSml=" + nCuePanelHeightSml)
  
  With grCuePanels
    \nCuePanelHeightStd = nCuePanelHeightStd
    \nCuePanelHeightSml = nCuePanelHeightSml
    \nCuePanelGap = nCuePanelGap
    \nCuePanelHeightStdPlusGap = \nCuePanelHeightStd + \nCuePanelGap
    \nCuePanelHeightSmlPlusGap = \nCuePanelHeightSml + \nCuePanelGap
  EndWith
  debugMsg(sProcName, "grCuePanels\nCuePanelHeightStd=" + grCuePanels\nCuePanelHeightStd)
  grCuePanelsInitValues = grCuePanels ; added grCuePanelsInitValues 23Mar2017 11.6.0 following email from C.Peters about audio graphs on cue panels > 25 being too large
  
  ; work out the maximum possible number of cue panels displayable on the connected screens
  For n = 1 To gnRealMonitors
    If gaMonitors(n)\nDeskTopHeight > nMaxScreenHeight
      nMaxScreenHeight = gaMonitors(n)\nDeskTopHeight
    EndIf
  Next n
  ; ; note: 0.75 in the following is for displaying cue panel heights at 75%, which is the smallest height, therefore producing the most possible panels
  ; gnMaxCuePanelCreated = Round(nMaxScreenHeight / ((nCuePanelHeightStd * 0.75) + nCuePanelGap), #PB_Round_Up)
  ; debugMsg(sProcName, "nMaxScreenHeight=" + nMaxScreenHeight + ", nCuePanelHeightStd=" + nCuePanelHeightStd + ", nCuePanelGap=" + nCuePanelGap)
  ; ; ; cap the max at 100 as we had to specify a fixed array size for WMN\ucCuePanel
  ; ; If gnMaxCuePanelCreated > 100
    ; ; gnMaxCuePanelCreated = 100
    ; ; EndIf
  
  ; Set gnMaxCuePanelCreated. Although not yet 'created', the cue panels WILL be created before the end of this Procedure
  If gnMaxCuePanelAvailable > 0
    gnMaxCuePanelCreated = gnMaxCuePanelAvailable ; Added 21Mar2022 11.9.1aq
  Else
    gnMaxCuePanelCreated = 24 ; start with 25 (0-24) cue panels (setting pre-11.9.1aq)
  EndIf
  ReDim gaDispPanel(gnMaxCuePanelCreated)
  ; debugMsg(sProcName, "ArraySize(gaDispPanel())=" + ArraySize(gaDispPanel()))
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_WMN_NORMAL)
  
  If IsWindow(#WMN) = #False
    
    If (gbSwapMonitors1and2) And (gnMonitors >= gnSwapMonitor)
      nWindowLeft = gaMonitors(gnSwapMonitor)\nDesktopLeft
      nWindowTop = gaMonitors(gnSwapMonitor)\nDesktopTop
    EndIf
    
    nFlags = #PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_NoActivate
    sFlags = "#PB_Window_SystemMenu|#PB_Window_SizeGadget|#PB_Window_MaximizeGadget|#PB_Window_MinimizeGadget|#PB_Window_Invisible|#PB_Window_NoActivate"
    
    debugMsg(sProcName, "calling OpenWindow(#WMN, " + nWindowLeft + ", " + nWindowTop + ", " + gnMainWindowDesignWidth + ", " + gnMainWindowDesignHeight +
                        ", " + #DQUOTE$ + #SCS_TITLE + " (" + #SCS_PROCESSOR + ")" + #DQUOTE$ + ", " + sFlags)
    If OpenWindow(#WMN, nWindowLeft, nWindowTop, gnMainWindowDesignWidth, gnMainWindowDesignHeight, #SCS_TITLE + " (" + #SCS_PROCESSOR + ")", nFlags)
      registerWindow(#WMN, "WMN(fmMain)")
      SetWindowColor(#WMN, grColorScheme\aItem[#SCS_COL_ITEM_MW]\nBackColor)
      SetWindowCallback(@WMN_windowCallback(), #WMN)  ; window callback
      SetWindowsHookEx_(#WH_KEYBOARD_LL,@WMN_KeyboardHook(),GetModuleHandle_(0),0) ; added 22Apr2019 11.8.1ah to enable vol up/down/mute keys to be trapped without also being processed by Windows
      
      setToolTipControls()
      
      With WMN
        scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)   ; Tool bar and VU display is not resizable, so do not use the WMN fonts
        
        ; \txtDummy added 13Jan2021 11.8.4aa - see M2T_clearAllMoveToTimeInfo() for an explanation
        \txtDummy=scsTextGadget(-40,-40,10,20,"",0,"txtDummy")
        setVisible(\txtDummy,#False)
        
        ; control panel
        nCtrlPanelWidth = WindowWidth(#WMN)
        nCtrlPanelHeight = nToolHeight + 21   ; 21 = height of cntGoAndMaster
        \cntCtrlPanel=scsContainerGadget(0,0,nCtrlPanelWidth,nCtrlPanelHeight,0,"cntCtrlPanel")
          setResizeFlags(\cntCtrlPanel, #SCS_RESIZE_FIX_TOP)
          
          ; Toolbar and VU display, etc
          \cntToolbarAndVU=scsContainerGadget(0,0,nCtrlPanelWidth,nToolHeight,0,"cntToolbarAndVU")
            setResizeFlags(\cntToolbarAndVU, #SCS_RESIZE_FIX_HEIGHT)
            
            ; tool bar
            WMN_createToolBar(0,0,602,nToolHeight,GadgetID(\cntToolbarAndVU))
            
            ; VU meters
            ;    labels
            \cvsVULabels=scsCanvasGadget(602,0,137,18,0,"cvsVULabels")
            setResizeFlags(\cvsVULabels, #SCS_RESIZE_IGNORE)
            ;    VU display
            nHeight = nToolHeight - GadgetHeight(\cvsVULabels)
            \cvsVUDisplay=scsCanvasGadget(602,18,197,nHeight,0,"cvsVUDisplay")
            setResizeFlags(\cvsVUDisplay, #SCS_RESIZE_IGNORE)
            
          scsCloseGadgetList()    ; cntToolbarAndVU
          
          scsSetGadgetFont(#PB_Default, #SCS_FONT_WMN_NORMAL)   ; reinstate WMN fonts
          
          ; GO and Master
          ; INFO see also WMN_resizeGoAndMaster()
          nGoAndMasterHeight = 21
          nGoAndMasterHeight * 2
          nGoAndMasterWidth = nCtrlPanelWidth
          nMasterFadersWidth = 189
          \cntGoAndMaster=scsContainerGadget(0, 20, nGoAndMasterWidth, nGoAndMasterHeight, 0, "cntGoAndMaster")
            SetGadgetColor(\cntGoAndMaster,#PB_Gadget_BackColor,#SCS_Black)
            nTop2 = 0
            ; last active cue info
            \cntLastPlayingInfo=scsContainerGadget(0, nTop2, nGoAndMasterWidth - nMasterFadersWidth, 21, 0, "cntLastPlayingInfo")
              \lblLastPlayingCue=scsTextGadget(0,0,125,GadgetHeight(\cntLastPlayingInfo),Lang("WMN","lblLastPlayingCue")+":", #PB_Text_Right,"lblLastPlayingCue")
              scsSetGadgetFont(\lblLastPlayingCue, #SCS_FONT_CUE_ITALIC10)
              \imgLastPlayingType=scsImageGadget(128,0,24,24,ImageID(hCueTypeAudio),0,"imgLastPlayingType")
              setResizeFlags(\imgLastPlayingType, #SCS_RESIZE_IGNORE)
              setVisible(\imgLastPlayingType, #False)
              \lblLastPlayingInfo=scsTextGadget(146,0,GadgetWidth(\cntLastPlayingInfo)-(146+2),GadgetHeight(\cntLastPlayingInfo),"",0,"lblLastPlayingInfo")
              scsSetGadgetFont(\lblLastPlayingInfo, #SCS_FONT_CUE_ITALIC10)
              setVisible(\lblLastPlayingInfo, #False)
            scsCloseGadgetList() ; cntLastPlayingInfo
            setVisible(\cntLastPlayingInfo, #False)
            nTop2 + GadgetHeight(\cntLastPlayingInfo)
            ; GO info
            \cntGoInfo=scsContainerGadget(0, nTop2, nGoAndMasterWidth - nMasterFadersWidth, 21, 0, "cntGoInfo")
              \lblNextManualCue=scsTextGadget(0,0,125,GadgetHeight(\cntGoInfo),Lang("WMN","lblNextManualCue")+":", #PB_Text_Right,"lblNextManualCue")
              scsSetGadgetFont(\lblNextManualCue, #SCS_FONT_CUE_ITALIC10)
              \imgType=scsImageGadget(128,0,24,24,ImageID(hCueTypeAudio),0,"imgType")
              setResizeFlags(\imgType, #SCS_RESIZE_IGNORE)
              setVisible(\imgType, #False)
              \lblGoInfo=scsTextGadget(146,0,GadgetWidth(\cntGoInfo)-(146+2),GadgetHeight(\cntGoInfo),"",0,"lblGoInfo")
              scsSetGadgetFont(\lblGoInfo, #SCS_FONT_CUE_ITALIC10)
              setVisible(\lblGoInfo, #False)
            scsCloseGadgetList() ; cntGoInfo
            
            ; demo label
            \lblDemo=scsTextGadget((nGoAndMasterWidth-(189+215)),0,215,19,"", #PB_Text_Center|#PB_Text_Border,"lblDemo")
            SetGadgetColors(\lblDemo, #SCS_White, RGB(255,128,0))
            setVisible(\lblDemo, #False)
            
            ; master fader
            nWidth = nMasterFadersWidth
            nLeft = nGoAndMasterWidth - nWidth - gl3DBorderWidth  ; included gl3DBorderWidth (2 pixels) so the scrollbar in scaMasterFader is not hard up against the edge of the window
            \cntMasterFaders=scsContainerGadget(nLeft, 0, nWidth, GadgetHeight(\cntGoAndMaster), #PB_Container_BorderLess, "cntMasterFaders")
              nTop = 0
              nHeight = GadgetHeight(\cntGoAndMaster) >> 1
              \cntMasterFader=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntMasterFader")
                \lblMasterFader=scsTextGadget(nLabelLeft,2,nLabelWidth,nHeight-2,sLabelPadding+ Lang("WMN","lblMasterFader")+sLabelPadding, #PB_Text_Center,"lblMasterFader")
                scsSetGadgetFont(\lblMasterFader, #SCS_FONT_CUE_NORMAL)
                ; \sldMasterFader=SLD_New("MasterFader",\cntMasterFader,0,nSliderLeft,1,nInnerWidth-nSliderLeft,nHeight-3,#SCS_ST_HLEVELRUN,0,1000,0,#SCS_SLD_NO_BASE,#True,#False,#True)
                nSliderLeft = nLabelLeft + nLabelWidth
                nSliderWidth = GadgetWidth(\cntMasterFader) - nSliderLeft
                \sldMasterFader=SLD_New("MasterFader",\cntMasterFader,0,nSliderLeft,1,nSliderWidth,nHeight-3,#SCS_ST_HLEVELRUN,0,1000,0,#SCS_SLD_NO_BASE,#True,#False,#True)
              scsCloseGadgetList()
              nTop + nHeight
              If grLicInfo\nLicLevel >= #SCS_LIC_PRO
                nWidth = getMaxTextWidth(40, Lang("WMN","ShowFaders"), Lang("WMN","HideFaders"), "", "", #SCS_FONT_WMN_NORMAL) + gl3DBorderAllowanceX + 10
                \btnShowFaders=scsButtonGadget(4,nTop,nWidth,nHeight-1,Lang("WMN","ShowFaders"),0,"btnShowFaders")
                ; setGadgetWidth(\btnShowFaders)
              EndIf
              nTop = GadgetHeight(\cntMasterFaders) - 1
              nWidth = GadgetWidth(\cntMasterFaders)
              \lnGoAndMasterBorder=scsLineGadget(0,nTop,nWidth,1,#SCS_Dark_Grey,0,"lnGoAndMasterBorder")
            scsCloseGadgetList() ; cntMasterFaders
            setVisible(\cntMasterFaders,#False)
            ; template info (displayed if viewing/editing a template)
            \cntTemplate=scsContainerGadget(GadgetX(\cntMasterFaders),GadgetY(\cntMasterFaders),GadgetWidth(\cntMasterFaders),GadgetHeight(\cntMasterFaders),#PB_Container_Flat,"cntTemplate")
              SetGadgetColor(\cntTemplate, #PB_Gadget_BackColor, RGB(0,102,204))
              \lblTemplateInfo=scsTextGadget(0,2,250,15,"",0,"lblTemplateInfo")
              SetGadgetColors(\lblTemplateInfo, #SCS_White, RGB(0,102,204))
              scsSetGadgetFont(\lblTemplateInfo, #SCS_FONT_WMN_ITALIC)
              SetGadgetColor(\lblTemplateInfo, #PB_Gadget_BackColor, GetGadgetColor(\cntTemplate, #PB_Gadget_BackColor))
              \btnCloseTemplate=scsButtonGadget(gnNextX+gnGap2,19,75,gnBtnHeight,Lang("WMN","btnCloseTemplate"),0,"btnCloseTemplate")
              scsSetGadgetFont(\btnCloseTemplate, #SCS_FONT_WMN_ITALIC)
            scsCloseGadgetList() ; cntTemplate
            setVisible(\cntTemplate,#False)
            
          scsCloseGadgetList() ; cntGoAndMaster
          
        scsCloseGadgetList()  ; cntCtrlPanel
        
        ; container above splitter bar of \splNorthSouth (ie \cntNorth will be #PB_Splitter_FirstGadget)
        \cntNorth=scsContainerGadget(0, 0, 0, 0, 0, "cntNorth")
          setResizeFlags(\cntNorth, #SCS_RESIZE_IGNORE)
          
          ; cue list
          CompilerIf #c_black_grey_scheme
            If gbEditorAndOptionsLocked
              nFlags = #PB_ListIcon_FullRowSelect
            Else
              nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_HeaderDragDrop
            EndIf
            WMN\brush = CreateSolidBrush_(#SCS_GUI_TitleBackColor)
          CompilerElseIf #c_color_scheme_classic
            If grColorScheme\sSchemeName = #SCS_COL_DEF_SCHEME_NAME
              If gbEditorAndOptionsLocked
                nFlags = #PB_ListIcon_FullRowSelect
              Else
                nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_HeaderDragDrop
              EndIf
            Else
              If gbEditorAndOptionsLocked
                nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines
              Else
                nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines | #PB_ListIcon_HeaderDragDrop
              EndIf
            EndIf
          CompilerElse
            If gbEditorAndOptionsLocked
              nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines
            Else
              nFlags = #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines | #PB_ListIcon_HeaderDragDrop
            EndIf
          CompilerEndIf
          \grdCues=scsListIconGadget(0, 0, nWidth, 143, "", 16, nFlags, "grdCues")
          CompilerIf #c_black_grey_scheme
            WMN\hHeader = SendMessage_(GadgetID(\grdCues), #LVM_GETHEADER, 0, 0) 
            ;Subclass ListIcon so we can customdraw the header text 
            WMN\oldListIconCallback = SetWindowLongPtr_(GadgetID(\grdCues), #GWL_WNDPROC, @SubclassedGrdCues()) 
          CompilerEndIf
          makeGadgetBorderless(\grdCues)  ; make the ListIconGadget borderless because a right-click on the border is not detected
          ; seems we need to use the callback for this gadget to detect right-mouse-down click on non-client areas (eg scrollbar)
          grMain\lpPrevWndFuncCues = SetWindowLongPtr_(GadgetID(\grdCues), #GWL_WNDPROC, @WMN_callback_cues())
          ; debugMsg(sProcName, "grMain\lpPrevWndFuncCues=" + grMain\lpPrevWndFuncCues)
          
          RemoveGadgetColumn(\grdCues, 0) ; remove column added by create function
          For n = 0 To #SCS_OPERMODE_LAST
            registerGrid(@grOperModeOptions(n)\rGrdCuesInfo, \grdCues, #SCS_GT_GRDCUES, "CU,DE,CT,CS,AC,FN,DU,SD,WR,MC,FT,PG,LV")
          Next n
          scsSetGadgetFont(\grdCues, #SCS_FONT_WMN_GRDCUES)
          setResizeFlags(\grdCues, #SCS_RESIZE_IGNORE)
          
        scsCloseGadgetList() ; cntNorth
        
        ; container below splitter bar of \splNorthSouth (ie \cntSouth will be #PB_Splitter_SecondGadget)
        \cntSouth=scsContainerGadget(0, 0, 0, 0, 0, "cntSouth")
          setResizeFlags(\cntSouth, #SCS_RESIZE_IGNORE)
          nInnerHeight = (gnMaxCuePanelCreated + 1) * (grCuePanels\nCuePanelHeightStdPlusGap)
          nInnerWidth = 711 - glScrollBarWidth - gl3DBorderAllowanceX
          \scaCuePanels=scsScrollAreaGadget(0, 0, 711, 186, nWidth, nHeight, 30, #PB_ScrollArea_BorderLess, "scaCuePanels")
            setResizeFlags(\scaCuePanels, #SCS_RESIZE_IGNORE)
            ; SetWindowLongPtr_(GadgetID(\scaCuePanels), #GWL_STYLE, GetWindowLong_(GadgetID(\scaCuePanels), #GWL_STYLE | #WS_CLIPCHILDREN))
            ; create cue panels
            For n = 0 To gnMaxCuePanelCreated
              WMN_createCuePanel(n, #False)
            Next n
          scsCloseGadgetList()
          \cntDummyFirstForPanelsHotkeysSplitter=scsContainerGadget(0,0,10,10,#PB_Container_BorderLess,"cntDummyFirstForPanelsHotkeysSplitter")
          scsCloseGadgetList()
          setVisible(\cntDummyFirstForPanelsHotkeysSplitter, #False)
          \treHotkeys=scsTreeGadget(711,0,81,186, #PB_Tree_NoButtons | #PB_Tree_NoLines, "treHotkeys")
          setResizeFlags(\treHotkeys, #SCS_RESIZE_FIX_ALL ! #SCS_RESIZE_FIX_WIDTH) ; fix all except for width
          ; seems we need to use the callback for this gadget to detect right-mouse-downclick on non-client areas (eg scrollbar)
          grMain\lpPrevWndFuncHotkeys = SetWindowLongPtr_(GadgetID(\treHotkeys), #GWL_WNDPROC, @WMN_callback_hotkeys())
          ; debugMsg(sProcName, "grMain\lpPrevWndFuncHotkeys=" + grMain\lpPrevWndFuncHotkeys)
        scsCloseGadgetList() ; cntSouth
        
        ; horizontal splitter
        nTop = GadgetY(\cntCtrlPanel) + GadgetHeight(\cntCtrlPanel)
        nHeight = WindowHeight(#WMN) - nTop - nStatusBarHeight
        nWidth = WindowWidth(#WMN)
        \splNorthSouth=scsSplitterGadget(0, nTop, nWidth, nHeight, \cntNorth, \cntSouth, #PB_Splitter_Separator, "splNorthSouth")
        setResizeFlags(\splNorthSouth, #SCS_RESIZE_FIX_HEIGHT)
        
        ; now create \splPanelsHotkeys, as this splitter is inside a container within splitter \splNorthSouth
        nOldGadgetList = UseGadgetList(GadgetID(\cntSouth))
        If nOldGadgetList
          ; vertical splitter for hot key array
          \splPanelsHotkeys=scsSplitterGadget(0, 0, GadgetWidth(\cntSouth), GadgetHeight(\cntSouth), \scaCuePanels, \treHotkeys, #PB_Splitter_Separator|#PB_Splitter_Vertical, "splPanelsHotkeys") ; nb resized after \splNorthSouth created
          setResizeFlags(\splPanelsHotkeys, #SCS_RESIZE_FIX_TOP)
          UseGadgetList(nOldGadgetList)
        EndIf
        
        \cntDummyFirstForMainMemoSplitter=scsContainerGadget(0,0,10,10,#PB_Container_BorderLess,"cntDummyFirstForMainMemoSplitter")
        scsCloseGadgetList()
        setVisible(\cntDummyFirstForMainMemoSplitter, #False)
        
        \cntDummySecondForMainMemoSplitter=scsContainerGadget(0,0,10,10,#PB_Container_BorderLess,"cntDummySecondForMainMemoSplitter")
        scsCloseGadgetList()
        setVisible(\cntDummySecondForMainMemoSplitter, #False)
        
        \cntDummyFirstForCueListMemoSplitter=scsContainerGadget(0,0,10,10,#PB_Container_BorderLess,"cntDummyFirstForCueListMemoSplitter")
        scsCloseGadgetList()
        setVisible(\cntDummyFirstForCueListMemoSplitter, #False)
        
        \cntDummySecondForCueListMemoSplitter=scsContainerGadget(0,0,10,10,#PB_Container_BorderLess,"cntDummySecondForCueListMemoSplitter")
        scsCloseGadgetList()
        setVisible(\cntDummySecondForCueListMemoSplitter, #False)
        
        ; now create \splCueListMemo, as this splitter is inside a container within splitter \splNorthSouth
        nOldGadgetList = UseGadgetList(GadgetID(\cntNorth))
        If nOldGadgetList
          ; vertical splitter for displaying memo alongside grdCues
          \splCueListMemo=scsSplitterGadget(0, 0, GadgetWidth(\cntNorth), GadgetHeight(\cntNorth), \cntDummyFirstForCueListMemoSplitter, \cntDummySecondForCueListMemoSplitter, #PB_Splitter_Separator|#PB_Splitter_Vertical, "splCueListMemo")
          setResizeFlags(\splCueListMemo, #SCS_RESIZE_FIX_TOP)
          UseGadgetList(nOldGadgetList)
          setVisible(\splCueListMemo, #False)
        EndIf
        
        \cntMemo=scsContainerGadget(0,0,120,120,#PB_Container_BorderLess,"cntMemo")
          SetGadgetColor(\cntMemo,#PB_Gadget_BackColor,#SCS_Black)
          \cvsMemoTitleBar=scsCanvasGadget(0,0,GadgetWidth(\cntMemo),22,0,"cvsMemoTitleBar")
          If StartDrawing(CanvasOutput(\cvsMemoTitleBar))
            Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
            StopDrawing()
          EndIf
          SetGadgetColor(\cntMemo, #PB_Gadget_BackColor, #SCS_Black)
          \rchMainMemoObject = New_RichEdit(0,GadgetHeight(\cvsMemoTitleBar),GadgetWidth(\cntMemo),GadgetHeight(\cntMemo)-GadgetHeight(\cvsMemoTitleBar))
          \rchMainMemoObject\SetInterface()
          \rchMainMemoObject\SetReadonly(#True)
          \rchMainMemoObject\SetCtrlBackColor(#SCS_Black)
          \rchMainMemo = \rchMainMemoObject\GetID()
          ; remove border from EditorGadget (code supplied by RASHAD in PB Coding Questions Forum topic "Border in editor gadget")
          ; NB the RichEdit gadget is a PB Editor gadget
          style = GetWindowLongPtr_(GadgetID(\rchMainMemo), #GWL_EXSTYLE)
          newstyle = style & (~#WS_EX_CLIENTEDGE)
          SetWindowLongPtr_(GadgetID(\rchMainMemo), #GWL_EXSTYLE, newstyle)
          \rchMainMemoObject\Resize(0,GadgetHeight(\cvsMemoTitleBar),GadgetWidth(\cntMemo),GadgetHeight(\cntMemo)-GadgetHeight(\cvsMemoTitleBar))
          SetWindowTheme_(GadgetID(\rchMainMemo), @null, @null)
          ; end of remove border from EditorGadget
        scsCloseGadgetList() ; cntMemo
        setResizeFlags(\cvsMemoTitleBar, #SCS_RESIZE_FIX_HEIGHT)
        setResizeFlags(\rchMainMemo, #SCS_RESIZE_FIX_TOP)
        setVisible(\cntMemo, #False)
        
        nTop = GadgetY(\cntCtrlPanel) + GadgetHeight(\cntCtrlPanel)
        nHeight = WindowHeight(#WMN) - nTop - nStatusBarHeight
        nWidth = WindowWidth(#WMN)
        \splMainMemo=scsSplitterGadget(0,GadgetY(\splNorthSouth),WindowWidth(#WMN),GadgetHeight(\splNorthSouth),\cntDummyFirstForMainMemoSplitter,\cntDummySecondForMainMemoSplitter,#PB_Splitter_Vertical|#PB_Splitter_Separator,"splMainMemo")
        If GadgetWidth(\splMainMemo) >= 600
          SetGadgetAttribute(\splMainMemo, #PB_Splitter_FirstMinimumSize, 400)
          SetGadgetAttribute(\splMainMemo, #PB_Splitter_SecondMinimumSize, 120)
        EndIf
        
        ; status bar
        \cvsStatusBar=scsCanvasGadget(0,543,800,17,0,"cvsStatusBar")
        
        CompilerIf #c_touch_panel
          \cvsTouchPanel=scsCanvasGadget(0,543,800,17,0,"cvsTouchPanel") ; will be resized and repositioned dynamically if required
          setVisible(\cvsTouchPanel, #False)
        CompilerEndIf
        
      EndWith
      
      WMN_buildPopupMenu_View()
      WMN_buildPopupMenu_Help()
      WMN_buildPopupMenu_Navigate()
      WMN_buildPopupMenu_SaveSettings()
      WMN_buildPopupMenu_DevMap()
      
      AddWindowTimer(#WMN, #SCS_TIMER_VU_METERS, 50) ; 50mS or 20 updates per second 
      
      ; setWindowVisible(#WMN,#True)  ; setWindowVisible deferred until window has been sized correctly
      setWindowEnabled(#WMN,#True)
      
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      debugMsg(sProcName, #SCS_END)
      ProcedureReturn #True
    Else
      debugMsg(sProcName, "WMN window open failed")
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      debugMsg(sProcName, #SCS_END)
      ProcedureReturn #False
    EndIf
  Else
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    debugMsg(sProcName, #SCS_END)
    ProcedureReturn #True
  EndIf
  
EndProcedure

Structure strWMT ; fmMidiTest
  btnClear.i
  btnOK.i
  lblMidiTestInfo.i
  lblMTC.i
  lblMTCValue.i
  lstTestMidiInfo.i
EndStructure
Global WMT.strWMT ; fmMidiTest

Procedure createfmMidiTest(nParentWindow=#WED)
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WMT, 0, 0, 621, 315, "", #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(nParentWindow))   ; nb window title populated dynamically
    registerWindow(#WMT, "WMT(fmMidiTest)")
    With WMT
      \lblMidiTestInfo=scsTextGadget(39,8,272,21,"",0,"lblMidiTestInfo")    ; populated dynamically
      \lstTestMidiInfo=scsListViewGadget(35,28,543,246,0,"lstTestMidiInfo")
      
      \lblMTC=scsTextGadget(GadgetX(\lblMidiTestInfo),287,60,15,Lang("WMT","lblMTC"),#PB_Text_Right,"lblMTC")
      setGadgetWidth(\lblMTC,20,#True)
      \lblMTCValue=scsTextGadget(gnNextX+gnGap,287,60,15," 00:00:00:00 ",#PB_Text_Center,"lblMTCValue")
      setGadgetWidth(\lblMTCValue,20)
      SetGadgetColor(\lblMTCValue,#PB_Gadget_FrontColor,#SCS_Yellow)
      SetGadgetColor(\lblMTCValue,#PB_Gadget_BackColor,#SCS_Black)
      
      \btnClear=scsButtonGadget(230,282,73,gnBtnHeight,Lang("Btns","Clear"),0,"btnClear")
      scsToolTip(\btnClear,Lang("WMT","btnClearTT"))
      \btnOK=scsButtonGadget(312,282,73,gnBtnHeight,Lang("Btns","Close"),#PB_Button_Default,"btnOK")
    EndWith
    
    AddKeyboardShortcut(#WMT, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
    AddKeyboardShortcut(#WMT, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    
    ; setWindowVisible(#WMT,#True)
    setWindowEnabled(#WMT,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure


Structure strWDD ; fmDMXDisplay
  cboDisplayPref.i
  cboLogicalDev.i
  cboGridType.i
  chkShowGridLines.i
  cvsDMXDisplay.i
  cvsDragBar.i
  cvsCloseIcon.i
  lblDisplayPref.i
  lblLogicalDev.i
  lblGridType.i
  mbgBackColor.i
  scaDMXDisplay.i
EndStructure
Global WDD.strWDD ; fmDMXDisplay

Procedure createfmDMXDisplay()
  Protected nWindowWidth, nWindowHeight, nMinWindowWidth, nMaxWindowWidth
  Protected nIconWidth
  Protected nDragBarHeight, nContentHeight ;, nStatusBarHeight
  Protected nLeft, nTop
  
  If IsWindow(#WDD) = #False
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    CompilerIf #c_new_gui
      nWindowWidth = 853
      nDragBarHeight = 38
      nContentHeight = 312
      nIconWidth = 20
      nWindowHeight = nDragBarHeight + nContentHeight ; + nStatusBarHeight
      
      If OpenWindow(#WDD, 0, 0, nWindowWidth, nWindowHeight, "", #PB_Window_ScreenCentered | #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
        registerWindow(#WDD, "WDD(fmDMXDisplay)")
        SetWindowColor(#WDD, grUIColors\nMainBackColor)
        With WDD
          nTop = 0
          \cvsDragBar=scsCanvasGadget(0,nTop,nWindowWidth-nIconWidth,nDragBarHeight,0,"cvsDragBar")
          \cvsCloseIcon=scsCanvasGadget(gnNextX,nTop,nIconWidth,nDragBarHeight,0,"cvsCloseIcon")
          scsToolTip(\cvsCloseIcon,Lang("WEN","CloseTT"))
          nTop + nDragBarHeight + 2
          nLeft = 9
          \lblLogicalDev=modTextGadget(nLeft,nTop+2,100,15,Lang("WDD","lblLogicalDev"),#PB_Text_Right,"lblLogicalDev")
          setGadgetWidth(\lblLogicalDev,-1,#True)
          \cboLogicalDev=modComboBoxGadget(gnNextX+gnGap, nTop, 120, 21, 80, 0, "cboLogicalDev")
          \lblDisplayPref=modTextGadget(gnNextX+24,nTop+2,100,15,Lang("WDD","lblDisplayPref"),#PB_Text_Right,"lblDisplayPref")
          setGadgetWidth(\lblDisplayPref,-1,#True)
          \cboDisplayPref=modComboBoxGadget(gnNextX+gnGap,nTop,140,21,80,0,"cboDisplayPref")
          nTop + 2
;          \cvsDMXDisplay=scsCanvasGadget(7,nTop,838,273,0,"cvsDMXDisplay")  ; height = 17 pixels x 16 rows + 1 extra for the bottom border line
          \scaDMXDisplay=scsScrollAreaGadget(7,nTop,nWindowWidth-15,273,nWindowWidth-37,262,17,#PB_ScrollArea_Flat,"scaDMXDisplay")  ; height = 17 pixels x 16 rows + 1 extra for the bottom border line
            \cvsDMXDisplay=scsCanvasGadget(0,0,GadgetWidth(\scaDMXDisplay)-20,GetGadgetAttribute(\scaDMXDisplay, #PB_ScrollArea_InnerHeight),0,"cvsDMXDisplay") ; -20 for Scrollbar to prevent the horizontal scrollbar from appearing
          scsCloseGadgetList()
        EndWith
        PostEvent(ModuleEx::#Event_Theme)
        setWindowEnabled(#WDD,#True)
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    CompilerElse
      ; nWindowWidth = 950
      nWindowWidth = 853 + glScrollBarWidth
      nMaxWindowWidth = 853 + glScrollBarWidth
      nMinWindowWidth = nMaxWindowWidth - 280
      If OpenWindow(#WDD, 0, 0, nWindowWidth, 312, Lang("WDD","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible | #PB_Window_SizeGadget, WindowID(#WMN))
        registerWindow(#WDD, "WDD(fmDMXDisplay)")
        With WDD
          nTop = 4
          \lblLogicalDev=scsTextGadget(9,nTop+gnLblVOffsetC,120,15,Lang("WDD","lblLogicalDev"),#PB_Text_Right,"lblLogicalDev")
          setGadgetWidth(\lblLogicalDev,-1,#True)
          \cboLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,50,21,0,"cboLogicalDev")
          
          \lblDisplayPref=scsTextGadget(gnNextX+24,nTop+gnLblVOffsetC,250,15,Lang("WDD","lblDisplayPref"),#PB_Text_Right,"lblDisplayPref")
          setGadgetWidth(\lblDisplayPref,-1,#True)
          \cboDisplayPref=scsComboBoxGadget(gnNextX+gnGap,nTop,50,21,0,"cboDisplayPref")
          
          \lblGridType=scsTextGadget(gnNextX+80,nTop+gnLblVOffsetC,250,15,Lang("WDD","lblGridType"),#PB_Text_Right,"lblGridType")
          setGadgetWidth(\lblGridType,-1,#True)
          \cboGridType=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboGridType")
          
          CompilerIf #c_dmx_display_drop_gridline_and_backcolor_choices = #False
            \mbgBackColor=scsMenuButtonGadget(gnNextX+20,nTop,120,22,Lang("WDD","mbgBackColor"),0,"mbgBackColor")
            
            \chkShowGridLines=scsCheckBoxGadget(gnNextX+20,nTop,120,21,Lang("WDD","chkShowGridLines"),0,"chkShowGridLines")
            setGadgetWidth(\chkShowGridLines,-1,#True)
          CompilerElse
            nWindowWidth - 280 ; 280 = widths and offsets of the above two now-omitted gadgets
          CompilerEndIf
          
          nTop + 25
          \scaDMXDisplay=scsScrollAreaGadget(7,nTop,nWindowWidth-15,273,nWindowWidth-37,262,17,#PB_ScrollArea_Flat,"scaDMXDisplay")  ; height = 17 pixels x 16 rows + 1 extra for the bottom border line
            \cvsDMXDisplay=scsCanvasGadget(0,0,GadgetWidth(\scaDMXDisplay)-20,GetGadgetAttribute(\scaDMXDisplay, #PB_ScrollArea_InnerHeight),0,"cvsDMXDisplay") ; -20 for Scrollbar to prevent the horizontal scrollbar from appearing
          scsCloseGadgetList()
        EndWith
        WindowBounds(#WDD, nMinWindowWidth, 100, nMaxWindowWidth, #PB_Ignore)
        setWindowEnabled(#WDD,#True)
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    CompilerEndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Structure strWDT ; fmDMXTest
  btnClear.i
  btnOK.i
  cvsDMXReceived.i
  lblChannelValues.i
  lstTestDMXInfo.i
EndStructure
Global WDT.strWDT ; fmDMXTest

Procedure createfmDMXTest()
  If IsWindow(#WDT) = #False
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    If OpenWindow(#WDT, 0, 0, 853, 462, Lang("WDT","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
      registerWindow(#WDT, "WDT(fmDMXTest)")
      With WDT
        \lblChannelValues=scsTextGadget(75,11,374,16,"",0,"lblChannelValues")
        
        \cvsDMXReceived=scsCanvasGadget(7,31,838,276,#PB_Canvas_Border,"cvsDMXReceived")
        \lstTestDMXInfo=scsListViewGadget(7,313,838,108,0,"lstTestDMXInfo")
        
        \btnClear=scsButtonGadget(349,429,73,25,Lang("Btns","Clear"),0,"btnClear")
        scsToolTip(\btnClear,Lang("WDT","btnClearTT"))
        \btnOK=scsButtonGadget(431,429,73,25,Lang("Btns","Close"),#PB_Button_Default,"btnOK")
      EndWith
      
      AddKeyboardShortcut(#WDT, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WDT, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
      ; setWindowVisible(#WDT,#True)
      setWindowEnabled(#WDT,#True)
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Structure strWOP ; fmOptions
  ; sorted
  btnApply.i
  btnAsioControlPanel.i
  btnAsioControlPanelSMS.i
  btnAudioEditorBrowse.i
  btnBrowse.i
  btnBrowseAudioFilesRootFolder.i
  btnCancel.i
  btnColDefaults.i
  btnColFit.i
  btnColorSchemeDesigner.i
  btnColRevert.i
  btnCopyModeSettings.i
  btnDefaultDisplayOptions.i
  btnDefaultShortcuts.i
  btnDfltFont.i
  btnFMIPInfo.i
  btnHelp.i
  btnImageEditorBrowse.i
  btnKeyAssign.i
  btnKeyRemove.i
  btnKeyReset.i
  btnLockEditing.i
  btnMoveDown.i
  btnMoveUp.i
  btnOK.i
  btnRAIIPInfo.i
  btnResetUserColumn1.i
  btnResetUserColumn2.i
  btnTestSMS.i
  btnUndoModeSettings.i
  btnUseSCSDfltFont.i
  btnVideoEditorBrowse.i
  cboAudioFileSelector.i
  cboAsioBufLen.i
  cboChangeOperMode.i
  cboColorScheme.i
  cboCopyModeSettings.i
  cboCtrlPanelPos.i
  cboCueListFontSize.i
  cboCuePanelHeight.i
  cboDBIncrement.i
  cboDoubleClick.i
  cboEditorCueListFontSize.i
  cboFadeAllTime.i
  cboFileBufLen.i
  cboFileScanMaxLengthAudio.i
  cboFileScanMaxLengthVideo.i
  cboFMFunctionalMode.i
  cboFMLocalIPAddr.i
  cboLanguage.i
  cboMaxMonitor.i
  cboMidiInDisplayTimeout.i
  cboMonitorSize.i
  cboMTCDispLocn.i
  cboRAIApp.i
  cboRAILocalIPAddr.i
  cboRAINetworkProtocol.i
  cboRAINetworkRole.i
  cboRAIOSCVersion.i
  cboSampleRate.i
  cboScreenVideoRenderer.i[#SCS_MAX_SPLIT_SCREENS+1]
  cboShortGroup.i
  cboSplitScreenCount.i[#SCS_MAX_SPLIT_SCREENS+1]
  cboSwapMonitor.i
  cboTimerDispLocn.i
  cboTimeFormat.i
  cboToolbarInfo.i
  cboTVGPlayerHwAccel.i
  cboVideoLibrary.i
  cboVideoRenderer.i
  cboVUDisplay.i
  chkActivateOCMAutoStarts.i
  chkAllowDisplayTimeout.i
  chkApplyTimeoutToOtherGos.i
  chkBackupIgnoreCtrlSendMIDI.i
  chkBackupIgnoreCtrlSendNETWORK.i
  chkBackupIgnoreCueCtrlDevs.i
  chkBackupIgnoreLIGHTING.i
  chkCheckMainLostFocusWhenEditorOpen.i
  chkCtrlOverridesExclCue.i
  chkDisableRightClick.i
  chkDisableVideoWarningMessage.i
  chkDisplayAllMidiIn.i
  chkDisplayLangIds.i
  chkEnableAutoCheckForUpdate.i
  chkShowMidiCueInCuePanels.i
  chkShowMidiCueInNextManual.i
  chkHotkeysOverrideExclCue.i
  chkIgnoreTitleTags.i
  chkIncludeAllLevelPointDevices.i
  chkLimitMovementOfMainWindowSplitterBar.i
  chkNoFloatingPoint.i
  chkNoWASAPI.i
  chkRAIEnabled.i
  chkRequestConfirmCueClick.i
  chkSaveAlwaysOn.i
  chkShowAudioGraph.i
  chkShowCueMarkers.i
  chkShowFaderAndPanControls.i
  chkShowHidden.i
  chkShowHKeyList.i
  chkShowHKeysInPanels.i
  chkShowLvlCurvesOther.i
  chkShowLvlCurvesPrim.i
  chkShowMasterFader.i
  chkShowNextManual.i
  chkShowPanCurvesOther.i
  chkShowPanCurvesPrim.i
  chkShowSubCues.i
  chkShowToolTips.i
  chkShowTransportControls.i
  chkSMSOnThisMachine.i
  chkSwap34with56.i
  chkSwapMonitors1and2.i
  chkTVGDisplayVUMeters.i
  cntAudioDriver.i
  cntBASSASIO.i
  cntBASSDS.i
  cntBASSMixer.i
  cntCheckForUpdate.i
  cntCtrlPanel.i
  cntCueListCols.i
  cntCueListEtc.i
  cntDfltFont.i
  cntDisableVideoWarningMessage.i
  cntDisplayOptions.i
  cntDriverFlags.i
  cntEditing.i
  cntExternalApps.i
  cntFM.i
  cntGeneral.i
  cntMainOther.i
  cntMidiEnabled.i
  cntOptions.i
  cntPlaybackBuffer.i
  cntPreviewFile.i
  cntProgressSliders.i
  cntRAI.i
  cntSession.i
  cntShortcuts.i
  cntSMS.i
  cntSplitScreenInfo.i
  cntTimeFormat.i
  cntUpdatePeriod.i
  cntVideoDriver.i
  frAudioDriver.i
  frBASSASIO.i
  frBASSDS.i
  frBASSMixer.i
  frCheckForUpdate.i
  frCtrlPanel.i
  frCueListCols.i
  frCueListEtc.i
  frDfltFont.i
  frDisableVideoWarningMessage.i
  frDisplayOptions.i
  frEditing.i
  frExternalApps.i
  frFM.i
  frGeneral.i
  frMainOther.i
  frFileScanMaxLength.i
  frPlaybackBuffer.i
  frProgressSliders.i
  frRAI.i
  frSession.i
  frSMS.i
  frSplitScreenInfo.i
  frTimeFormat.i
  frUpdatePeriod.i
  frVideoDriver.i
  grdCueListCols.i
  grdScreens.i
  grdShortcuts.i
  ipSMSHost.i
  lblAsioBufLen.i
  lblAudioEditor.i
  lblAudioFileSelector.i
  lblAudioFilesRootFolder.i
  lblChangeOperMode.i
  lblChanges.i
  lblCheckForUpdateMsg.i
  lblColorScheme.i
  lblCopyModeSettings.i
  lblCtrlPanelPos.i
  lblCtrlSendDevices.i
  lblCueCtrlDevices.i
  lblCueListFontSize.i
  lblCuePanelHeight.i
  lblCurrentAssignment.i
  lblCurrentInfo.i
  lblCurrOperMode.i[2]
  lblDaysBetweenChecks.i
  lblDBIncrement.i
  lblDfltFont.i
  lblDMXInEnabled.i
  lblDMXOutEnabled.i
  lblDoubleClick.i
  lblEditorCueListFontSize.i
  lblFadeAllTime.i
  lblFileBufLen.i
  lblFileScanMaxLengthAudio.i
  lblFileScanMaxLengthVideo.i
  lblFMDescription.i
  lblFMFuncMode.i
  lblFMFunctionalMode.i
  lblFMLocalIPAddr.i
  lblFMServerAddr.i
  lblFontSampleCueList.i
  lblFontSampleMain.i
  lblFontSampleOthers.i
  lblFontSamples.i
  lblGridCols.i
  lblImageEditor.i
  lblInitDir.i
  lblLanguage.i
  lblLinkSyncms.i
  lblLinkSyncPoint.i
  lblLocked.i
  lblMaxMonitor.i
  lblMaxPreOpenAudioFiles.i
  lblMaxPreOpenVideoImageFiles.i
  lblMidiInDisplayTimeout.i
  lblMidiInEnabled.i
  lblMidiOutEnabled.i
  lblMinPChansNonHK.i
  lblMonitorSize.i
  lblMTCDispLocn.i
  lblNetworkInEnabled.i
  lblNetworkOutEnabled.i
  lblNewKey.i
  lblOtherDevices.i
  lblPlaybackLength.i
  lblPrimaryDevices.i
  lblRAIApp.i
  lblRAILocalIPAddr.i
  lblRAILocalPort.i
  lblRAINetworkProtocol.i
  lblRAIOSCVersion.i
  lblRAIServerInfo.i
  lblRealScreenSize.i
  lblRequiresRestart.i
  lblRequiresRestart2.i
  lblRS232InEnabled.i
  lblRS232OutEnabled.i
  lblSampleRate.i
  lblScreens.i
  lblScreenVideoRenderer.i
  lblSelectedFunction.i
  lblSelectedInfo.i
  lblSessionInfo.i
  lblShortcutInfo.i
  lblSMSHost.i
  lblSMSPort.i
  lblSplitScreenCount.i
  lblSwapMonitors1and2Part2.i
  lblTestSMS.i
  lblTestSMSResult.i
  lblTimerDispLocn.i
  lblTimeFormat.i
  lblToolbarInfo.i
  lblTVGPlayerHwAccel.i
  lblUpdatePeriod.i
  lblUserColumn1.i
  lblUserColumn2.i
  lblVideoEditor.i
  lblUserColumnWarning.i
  lblVideoLibrary.i
  lblVideoRenderer.i
  lblVUDisplay.i
  lnColsOperMode.i
  lnDispOperMode.i
  optBASSMixer.i[2]
  optDMXInEnabled.i[3]
  optDMXOutEnabled.i[3]
  optMidiInEnabled.i[3]
  optMidiOutEnabled.i[3]
  optNetworkInEnabled.i[3]
  optNetworkOutEnabled.i[3]
  optPlaybackbuf.i[2]
  optRS232InEnabled.i[3]
  optRS232OutEnabled.i[3]
  optUpdatePeriod.i[2]
  scaScreenMapping.i
  scaSplitScreenInfo.i
  shcSelectShortcut.i
  txtAudioEditor.i
  txtAudioFilesRootFolder.i
  txtDaysBetweenChecks.i
  txtFMServerAddr.i
  txtImageEditor.i
  txtInitDir.i
  txtLinkSyncPoint.i
  txtMaxPreOpenAudioFiles.i
  txtMaxPreOpenVideoImageFiles.i
  txtMinPChansNonHK.i
  txtNotAvailable.i
  txtPlaybackBufLength.i
  txtRAILocalPort.i
  txtRealScreenSize.i[#SCS_MAX_SPLIT_SCREENS+1]
  txtScreenPosAndSize.i[#SCS_MAX_SPLIT_SCREENS+1]
  txtScreens.i[#SCS_MAX_SPLIT_SCREENS+1]
  txtSMSPort.i
  txtUpdatePeriodLength.i
  txtUserColumn1.i
  txtUserColumn2.i
  txtVideoEditor.i
  tvwPrefTree.i
EndStructure
Global WOP.strWOP ; fmOptions

Procedure createfmOptions(nParentWindow)
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, nHeight, nTop2
  Protected nPromptLeft, nPromptWidth
  Protected nResult, nLeft2
  Protected sNr.s
  Protected nTabWidth, nTabHeight
  Protected nDisplayNode, nNodeIndex
  Protected nColsNode, nAudioDriverNode
  Protected sNodeText.s, sFrameText.s
  Protected nBtnWidth, nTmpWidth
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nItemHeight, nMaxWidth
  Protected nMonitorNr
  Protected n2
  Protected sDSWASAPI.s, sName.s
  Protected nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, nFlags
  Protected sSwapMonitors1and2.s, sSwapMonitors1and2Part1.s, sSwapMonitors1and2Part2.s
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  nWindowWidth = 850
  ; nWindowHeight = 497
  ; nWindowHeight = 535 ; Changed 17Jan2022 11.9.0am
  nWindowHeight = 560 ; Changed 24Aug2023 11.10.0by
  nFlags = #PB_Window_SystemMenu | #PB_Window_Invisible
  adjustWindowPosIfReqd(@nWindowLeft, @nWindowTop, @nWindowWidth, @nWindowHeight, @nFlags)

  If OpenWindow(#WOP, nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, Lang("WOP","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WOP, "WOP(fmOptions)")
    setToolTipControls()
    With WOP
      ; \tvwPrefTree=scsTreeGadget(4,4,180,295,#PB_Tree_AlwaysShowSelection,"tvwPrefTree")
      \tvwPrefTree=scsTreeGadget(4,4,180,326,#PB_Tree_AlwaysShowSelection,"tvwPrefTree")
      AddGadgetItem(\tvwPrefTree, -1, Lang("WOP","Window"), 0, 0)
      SetGadgetItemData(\tvwPrefTree, (CountGadgetItems(\tvwPrefTree)-1), #SCS_OPTNODE_ROOT)
      
      nTop = GadgetY(\tvwPrefTree) + GadgetHeight(\tvwPrefTree) + 4
      \lblCurrOperMode[0]=scsTextGadget(4,nTop,180,17,Lang("WOP","lblCurrOperMode")+":",#PB_Text_Center,"lblCurrOperMode[0]")
      \lblCurrOperMode[1]=scsTextGadget(4,nTop+17,180,24,"",#PB_Text_Center|#PB_Text_Border,"lblCurrOperMode[1]")
      SetGadgetFont(\lblCurrOperMode[1],#SCS_FONT_GEN_BOLD12)
      
      nTop + 46
      \lblChangeOperMode=scsTextGadget(4,nTop,180,15,Lang("WOP","lblChangeOperMode")+":",#PB_Text_Center,"lblChangeOperMode")
      \cboChangeOperMode=scsComboBoxGadget(24,nTop+15,140,21,0,"cboChangeOperMode")
      
      nTop + 44
      \lblLocked=scsTextGadget(4,nTop,180,24,Lang("WOP","lblLocked"),#PB_Text_Center|#PB_Text_Border,"lblLocked")
      SetGadgetColor(\lblLocked,#PB_Gadget_BackColor,#SCS_Yellow)
      SetGadgetColor(\lblLocked,#PB_Gadget_FrontColor,#SCS_Black)
      setVisible(\lblLocked,#False)
      
      nTop + 26
      \btnLockEditing=scsButtonGadget(24,nTop,140,38,LangEllipsis("WOP","btnLockEditing"),#PB_Button_MultiLine,"btnLockEditing")
      
      nLeft = GadgetX(\tvwPrefTree) + GadgetWidth(\tvwPrefTree) + 4
      nTop = 4
      nHeight = nWindowHeight - nTop - 34
      \cntOptions=scsContainerGadget(nLeft,nTop,662,nHeight,0,"cntOptions")
        
        nTabWidth = GadgetWidth(\cntOptions)
        nTabHeight = GadgetHeight(\cntOptions)
        
        ; INFO Options: General Options
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabGeneral"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_GENERAL] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_GENERAL
        
        \cntGeneral=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntGeneral")
          \frGeneral=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabGeneral"),0,"frGeneral")
          scsSetGadgetFont(\frGeneral, #SCS_FONT_GEN_BOLD)
          
          nTop = 22
          \lblInitDir=scsTextGadget(6,nTop+gnLblVOffsetS,120,15,Lang("WOP","lblInitDir"), #PB_Text_Right,"lblInitDir")
          \txtInitDir=scsStringGadget(gnNextX+gnGap,nTop,395,19,"",#PB_String_ReadOnly,"txtInitDir")
          scsToolTip(\txtInitDir,Lang("WOP","txtInitDirTT"))
          \btnBrowse=scsButtonGadget(gnNextX+7,nTop-1,72,21,LangEllipsis("Btns","Browse"),0,"btnBrowse")
          setGadgetWidth(\btnBrowse)
          scsToolTip(\btnBrowse,Lang("WOP","btnBrowseTT"))
          
          nTop = 52
          \lblDoubleClick=scsTextGadget(6,nTop+gnLblVOffsetC,120,15,Lang("WOP","lblDoubleClick"), #PB_Text_Right,"lblDoubleClick")
          \cboDoubleClick=scsComboBoxGadget(gnNextX+gnGap,nTop,224,21,0,"cboDoubleClick")
          scsToolTip(\cboDoubleClick,Lang("WOP","cboDoubleClickTT"))
          nTop + 23
          nLeft = GadgetX(\cboDoubleClick)
          \chkApplyTimeoutToOtherGos=scsCheckBoxGadget(nLeft,nTop,450,17,Lang("WOP","chkApplyTimeoutToOtherGos"),0,"chkApplyTimeoutToOtherGos")
          nTop + 19
          \lblFadeAllTime=scsTextGadget(6,nTop+gnLblVOffsetC,120,15,Lang("WOP","lblFadeAllTime"), #PB_Text_Right,"lblFadeAllTime")
          \cboFadeAllTime=scsComboBoxGadget(gnNextX+gnGap,nTop,224,21,0,"cboFadeAllTime")
          scsToolTip(\cboFadeAllTime,Lang("WOP","cboFadeAllTimeTT"))
          
          nTop + 25
          nLeft = 11
          \lblMaxPreOpenAudioFiles=scsTextGadget(nLeft,nTop+gnLblVOffsetS,211,15,Lang("WOP","lblMaxPreOpenAudioFiles"), #PB_Text_Right,"lblMaxPreOpenAudioFiles")
          \txtMaxPreOpenAudioFiles=scsStringGadget(gnNextX+gnGap,nTop,34,21,"",#PB_String_Numeric,"txtMaxPreOpenAudioFiles")
          scsToolTip(\txtMaxPreOpenAudioFiles,Lang("WOP","txtMaxPreOpenAudioFilesTT"))
          
          nLeft = 290
          \lblMaxPreOpenVideoImageFiles=scsTextGadget(nLeft,nTop+gnLblVOffsetS,211,15,Lang("WOP","lblMaxPreOpenVideoImageFiles"), #PB_Text_Right,"lblMaxPreOpenVideoIMageFiles")
          \txtMaxPreOpenVideoImageFiles=scsStringGadget(gnNextX+gnGap,nTop,34,21,"",#PB_String_Numeric,"txtMaxPreOpenVideoImageFiles")
          scsToolTip(\txtMaxPreOpenVideoImageFiles,Lang("WOP","txtMaxPreOpenVideoImageFilesTT"))
          
          nTop + 28
          \cntTimeFormat=scsContainerGadget(10,nTop,602,54,0,"cntTimeFormat")
            \frTimeFormat=scsFrameGadget(0,0,602,54,Lang("WOP","frTimeFormat"),0,"frTimeFormat")
            \lblTimeFormat=scsTextGadget(6,nTop+gnLblVOffsetC,120,15,Lang("WOP","lblTimeFormat"), #PB_Text_Right,"lblTimeFormat")
            \cboTimeFormat=scsComboBoxGadget(11,20,577,19,0,"cboTimeFormat")
            scsToolTip(\cboTimeFormat,Lang("WOP","cboTimeFormatTT"))
          scsCloseGadgetList()
            
          nTop + GadgetHeight(\cntTimeFormat) + 2
          \cntDfltFont=scsContainerGadget(10,nTop,602,118,0,"cntDfltFont")
            \frDfltFont=scsFrameGadget(0,0,602,118,Lang("WOP","frDfltFont"),0,"frDfltFont")
            \lblDfltFont=scsTextGadget(1,20,111,15,Lang("WOP","lblDfltFont"),#PB_Text_Right,"lblDfltFont")
            \btnDfltFont=scsButtonGadget(gnNextX+7,17,150,23,"",0,"btnDfltFont")
            scsToolTip(\btnDfltFont,Lang("WOP","btnDfltFontTT"))
            \btnUseSCSDfltFont=scsButtonGadget(GadgetX(\btnDfltFont),40,200,23,"",0,"btnUseSCSDfltFont")
            nLeft = gnNextX+12
            \lblFontSamples=scsTextGadget(nLeft,8,240,15,Lang("WOP","lblFontSamples"),#PB_Text_Center,"lblFontSamples")
            \lblFontSampleCueList=scsTextGadget(nLeft,25,240,40,Lang("WOP","lblFontSampleCueList"),#PB_Text_Border|#PB_Text_Center, "lblFontSampleCueList")
            \lblFontSampleMain=scsTextGadget(nLeft,65,240,25,Lang("WOP","lblFontSampleMain"),#PB_Text_Border|#PB_Text_Center, "lblFontSampleMain")
            \lblFontSampleOthers=scsTextGadget(nLeft,92,240,21,Lang("WOP","lblFontSampleOthers"),#PB_Text_Border|#PB_Text_Center, "lblFontSampleOthers")
          scsCloseGadgetList()
          
          CompilerIf #cDemo = #False And #cWorkshop = #False
            nTop + GadgetHeight(\cntDfltFont) + 4
            \cntCheckForUpdate=scsContainerGadget(10,nTop,602,68,0,"cntCheckForUpdate")
              \frCheckForUpdate=scsFrameGadget(0,0,602,64,Lang("WOP","frCheckForUpdate"),0,"frCheckForUpdate")
              \chkEnableAutoCheckForUpdate=scsCheckBoxGadget(11,20,200,17,Lang("WOP","chkEnableAutoCheckForUpdate"),0,"chkEnableAutoCheckForUpdate")
              setGadgetWidth(\chkEnableAutoCheckForUpdate,80,#True)
              \lblDaysBetweenChecks=scsTextGadget(gnNextX+24,19+gnLblVOffsetS,100,15,Lang("WOP","lblDaysBetweenChecks"),0,"lblDaysBetweenChecks")
              setGadgetWidth(\lblDaysBetweenChecks,-1,#True)
              \txtDaysBetweenChecks=scsStringGadget(gnNextX+gnGap,19,34,21,"",#PB_String_Numeric,"txtDaysBetweenChecks")
              \lblCheckForUpdateMsg=scsTextGadget(11,43,500,15,Lang("WOP","lblCheckForUpdateMsg"),0,"lblCheckForUpdateMsg")
            scsCloseGadgetList()
            nTop + GadgetHeight(\cntCheckForUpdate) + 8
            nLeft = GadgetX(\cntCheckForUpdate) + GadgetX(\lblCheckForUpdateMsg)
          CompilerElse
            nTop + GadgetHeight(\cntDfltFont) + 2
            nLeft = GadgetX(\cntDfltFont) + GadgetX(\lblDfltFont)
          CompilerEndIf
          
          \lblLanguage=scsTextGadget(nLeft,nTop+gnLblVOffsetC,100,15,Lang("WOP","lblLanguage"),#PB_Text_Right,"lblLanguage")
          setGadgetWidth(\lblLanguage, -1, #True)
          \cboLanguage=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboLanguage")
          If #cTranslator
            \chkDisplayLangIds=scsCheckBoxGadget(gnNextX+7,nTop,200,21,Lang("WOP","chkDisplayLangIds"),0,"chkDisplayLangIds")
          Else
            gnNextX + 30  ; push chkSwapMonitors1and2 further right if not displaying chkDisplayLangIds
          EndIf
          sSwapMonitors1and2 = Lang("WOP","chkSwapMonitors1and2")                 ; eg "Bildschirm 1 und 2 tauschen" (German), or "Swap monitors 1 And 2" (English)
          sSwapMonitors1and2Part1 = Trim(StringField(sSwapMonitors1and2, 1, "2")) ; eg "Bildschirm 1 und",                     or "Swap monitors 1 and"
          sSwapMonitors1and2Part2 = Trim(StringField(sSwapMonitors1and2, 2, "2")) ; eg "tauschen",                             or ""
          ; sSwapMonitors1and2Part2 = "test"
          \chkSwapMonitors1and2=scsCheckBoxGadget(gnNextX+12,nTop,200,17,"* "+sSwapMonitors1and2Part1,0,"chkSwapMonitors1and2")
          scsToolTip(\chkSwapMonitors1and2, Lang("WOP","chkSwapMonitors1and2TT"))
          setGadgetWidth(\chkSwapMonitors1and2,20,#True)
          \cboSwapMonitor=scsComboBoxGadget(gnNextX,nTop-2,80,21,0,"cboSwapMonitor")
          If sSwapMonitors1and2Part2
            \lblSwapMonitors1and2Part2=scsTextGadget(gnNextX,GadgetY(\cboSwapMonitor)+gnLblVOffsetC,20,15," "+sSwapMonitors1and2Part2,0,"lblSwapMonitors1and2Part2") ; only created for some languages, eg DE
            setGadgetWidth(\lblSwapMonitors1and2Part2)
          EndIf
          nTop + 27
          \lblRequiresRestart=scsTextGadget(nLeft,nTop,400,15,Lang("WOP","lblRequiresRestart"),0,"lblRequiresRestart")
          scsSetGadgetFont(\lblRequiresRestart, #SCS_FONT_GEN_ITALIC)
          setGadgetWidth(\lblRequiresRestart)
          
        scsCloseGadgetList()
        setVisible(\cntGeneral,#False)
        ;}
        ; INFO Options: Display Options
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabDisplayOptions"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_DISPLAY] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_DISPLAY
        nDisplayNode = nNodeIndex
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabDesign"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_DISPLAY_DESIGN] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_DISPLAY_DESIGN
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabRehearsal"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_DISPLAY_REHEARSAL] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_DISPLAY_REHEARSAL
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabPerformance"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_DISPLAY_PERFORMANCE] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_DISPLAY_PERFORMANCE
        
        SetGadgetItemState(\tvwPrefTree, nDisplayNode, #PB_Tree_Expanded)
        
        \cntDisplayOptions=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntDisplayOptions")
          \frDisplayOptions=scsFrameGadget(0,0,nTabWidth-4,nTabHeight,Lang("WOP","tabDisplayOptions") + " - " + Lang("WOP","tabDesign"),0,"frDisplayOptions")
          scsSetGadgetFont(\frDisplayOptions,#SCS_FONT_GEN_BOLD)
          
          \lnDispOperMode=scsLineGadget(8,20,2,nTabHeight-28,0,0,"lnDispOperMode")
          
          \lblColorScheme=scsTextGadget(60,20,178,15,Lang("WOP","lblColorScheme"), #PB_Text_Right,"lblColorScheme")
          \cboColorScheme=scsComboBoxGadget(gnNextX+7,16,150,21,0,"cboColorScheme")
          \btnColorSchemeDesigner=scsButtonGadget(gnNextX+7,15,160,gnBtnHeight,LangEllipsis("WOP","btnColorSchemeDesigner"),0,"btnColorSchemeDesigner")
          
          \cntCtrlPanel=scsContainerGadget(18,38,nTabWidth-36,106+17,0,"cntCtrlPanel")
            \frCtrlPanel=scsFrameGadget(0,0,GadgetWidth(\cntCtrlPanel),GadgetHeight(\cntCtrlPanel),Lang("WOP","frCtrlPanel"),0,"frCtrlPanel")
            \lblCtrlPanelPos=scsTextGadget(10,20,210,15,Lang("WOP","lblCtrlPanelPos"), #PB_Text_Right,"lblCtrlPanelPos")
            \cboCtrlPanelPos=scsComboBoxGadget(gnNextX+7,16,200,21,0,"cboCtrlPanelPos")
            \lblToolbarInfo=scsTextGadget(10,41,210,15,Lang("WOP","lblToolbarInfo"), #PB_Text_Right,"lblToolbarInfo")
            \cboToolbarInfo=scsComboBoxGadget(gnNextX+7,37,200,21,0,"cboToolbarInfo")
            \lblVUDisplay=scsTextGadget(10,62,210,15,Lang("WOP","lblVUDisplay"), #PB_Text_Right,"lblVUDisplay")
            \cboVUDisplay=scsComboBoxGadget(gnNextX+7,58,200,21,0,"cboVUDisplay")
            nLeft = GadgetX(\cboVUDisplay)
            nTop = GadgetY(\cboVUDisplay) + 26
            \chkShowNextManual=scsCheckBoxGadget(nLeft,nTop,100,17,Lang("WOP","chkShowNextManual"),0,"chkShowNextManual")
            setGadgetWidth(\chkShowNextManual, -1, #True)
            \chkShowMasterFader=scsCheckBoxGadget(gnNextX+gnGap2,nTop,100,17,Lang("WOP","chkShowMasterFader"),0,"chkShowMasterFader")
            setGadgetWidth(\chkShowMasterFader)
            \chkShowMidiCueInNextManual=scsCheckBoxGadget(nLeft,nTop+17,100,17,Lang("WOP","chkShowMidiCueInNextManual"),0,"chkShowMidiCueInNextManual")
            setGadgetWidth(\chkShowMidiCueInNextManual)
          scsCloseGadgetList()
          
          nTop = GadgetY(\cntCtrlPanel) + GadgetHeight(\cntCtrlPanel) + 3
          \cntCueListEtc=scsContainerGadget(18,nTop,nTabWidth-36,170+34,0,"cntCueListEtc")
            \frCueListEtc=scsFrameGadget(0,0,GadgetWidth(\cntCueListEtc),GadgetHeight(\cntCueListEtc),Lang("WOP","frCueListEtc"),0,"frCueListEtc")
            nLeft = GadgetX(\cboCtrlPanelPos)
            nPromptLeft = 2
            nPromptWidth = nLeft - nPromptLeft - 7
            nTop = 16
            \lblCueListFontSize=scsTextGadget(nPromptLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblCueListFontSize"),#PB_Text_Right,"lblCueListFontSize")
            \cboCueListFontSize=scsComboBoxGadget(nLeft,nTop,75,21,0,"cboCueListFontSize")
            \lblCuePanelHeight=scsTextGadget(gnNextX+12,nTop+4,nPromptWidth,15,Lang("WOP","lblCuePanelHeight"),#PB_Text_Right,"lblCuePanelHeight")
            setGadgetWidth(\lblCuePanelHeight, -1, #True)
            \cboCuePanelHeight=scsComboBoxGadget(gnNextX+7,nTop,75,21,0,"cboCuePanelHeight")
            nLeft = 12
            nTop + 30
            nWidth = (GadgetWidth(\frCueListEtc) - gl3DBorderAllowanceX) >> 1 - nLeft
            \chkShowSubCues=scsCheckBoxGadget(nLeft,nTop,nWidth,17,Lang("WOP","chkShowSubCues"),0,"chkShowSubCues")
            \chkShowHidden=scsCheckBoxGadget(nLeft,nTop+17,nWidth,17,Lang("WOP","chkShowHidden"),0,"chkShowHidden")
            \chkShowHKeysInPanels=scsCheckBoxGadget(nLeft,nTop+34,nWidth,17,Lang("WOP","chkShowHKeysInPanels"),0,"chkShowHKeysInPanels")
            \chkShowHKeyList=scsCheckBoxGadget(nLeft,nTop+51,nWidth,17,Lang("WOP","chkShowHKeyList"),0,"chkShowHKeyList")
            \chkShowTransportControls=scsCheckBoxGadget(nLeft,nTop+68,nWidth,17,Lang("WOP","chkShowTransportControls"),0,"chkShowTransportControls")
            \chkShowFaderAndPanControls=scsCheckBoxGadget(nLeft,nTop+85,nWidth,17,Lang("WOP","chkShowFaderAndPanControls"),0,"chkShowFaderAndPanControls")
            \chkRequestConfirmCueClick=scsCheckBoxGadget(nLeft,nTop+102,nWidth,17,Lang("WOP","chkRequestConfirmCueClick"),0,"chkRequestConfirmCueClick")
            setGadgetWidth(\chkRequestConfirmCueClick)
            \chkShowMidiCueInCuePanels=scsCheckBoxGadget(nLeft,nTop+119,nWidth,17,Lang("WOP","chkShowMidiCueInCuePanels"),0,"chkShowMidiCueInCuePanels")
            setGadgetWidth(\chkShowMidiCueInCuePanels)
            \chkLimitMovementOfMainWindowSplitterBar=scsCheckBoxGadget(nLeft,nTop+136,nWidth,17,Lang("WOP","chkLimitMovementOfMainWindowSplitterBar"),0,"chkLimitMovementOfMainWindowSplitterBar")
            setGadgetWidth(\chkLimitMovementOfMainWindowSplitterBar)
            scsToolTip(\chkLimitMovementOfMainWindowSplitterBar, Lang("WOP", "chkLimitMovementOfMainWindowSplitterBarTT"))
            
            nLeft + nWidth
            nWidth = GadgetWidth(\frCueListEtc) - nLeft - gl3DBorderAllowanceX
            \cntProgressSliders=scsContainerGadget(nLeft,nTop,nWidth,100,0,"cntProgressSliders")
              \frProgressSliders=scsFrameGadget(0,0,GadgetWidth(\cntProgressSliders),GadgetHeight(\cntProgressSliders),Lang("WOP","frProgressSliders"),0,"frProgressSliders")
              nLeft = 8
              nWidth = GadgetWidth(\cntProgressSliders) - nLeft - 4
              nTop = 15
              \lblPrimaryDevices=scsTextGadget(nLeft, nTop, nWidth/2, 17, Lang("WOP","lblPrimaryDevices"),0, "lblPrimaryDevices")
              scsSetGadgetFont(\lblPrimaryDevices, #SCS_FONT_GEN_UL)
              \lblOtherDevices=scsTextGadget(nLeft+(nWidth/2)+5, nTop, (nWidth/2)-3, 17, Lang("WOP","lblOtherDevices"),0, "lblOtherDevices")
              scsSetGadgetFont(\lblOtherDevices, #SCS_FONT_GEN_UL)
              nTop + 16
              \chkShowLvlCurvesPrim=scsCheckBoxGadget(nLeft,nTop,nWidth/2,17,Lang("WOP","chkShowLvlCurves"),0,"chkShowLvlCurvesPrim")
              \chkShowLvlCurvesOther=scsCheckBoxGadget(nLeft+(nWidth/2)+5, nTop, (nWidth/2)-3, 17,Lang("WOP","chkShowLvlCurves"),0,"chkShowLvlCurvesOther")
              scsToolTip(\chkShowLvlCurvesOther, Lang("WOP","chkShowLvlCurvesOtherTT2"))
              nTop + 16
              \chkShowPanCurvesPrim=scsCheckBoxGadget(nLeft,nTop,nWidth/2,17,Lang("WOP","chkShowPanCurves"),0,"chkShowPanCurvesPrim")
              \chkShowPanCurvesOther=scsCheckBoxGadget(nLeft+(nWidth/2)+5, nTop, (nWidth/2)-3, 17,Lang("WOP","chkShowPanCurves"),0,"chkShowPanCurvesOther")
              scsToolTip(\chkShowPanCurvesOther, Lang("WOP","chkShowPanCurvesOtherTT2"))
              nTop + 18
              nLeft + 50
              \chkShowAudioGraph=scsCheckBoxGadget(nLeft,nTop,nWidth,17,Lang("WOP","chkShowAudioGraph"),0,"chkShowAudioGraph")
              scsToolTip(\chkShowAudioGraph, Lang("WOP","chkShowAudioGraphTT"))
              nTop + 16
              \chkShowCueMarkers=scsCheckBoxGadget(nLeft,nTop,nWidth,17,Lang("WOP","chkShowCueMarkers"),0,"chkShowCueMarkers")
              scsToolTip(\chkShowCueMarkers, Lang("WOP","chkShowCueMarkersTT"))
            scsCloseGadgetList()
            
          scsCloseGadgetList()
          
          nTop = GadgetY(\cntCueListEtc) + GadgetHeight(\cntCueListEtc) + 3
          \cntMainOther=scsContainerGadget(18,nTop,nTabWidth-36,106,0,"cntMainOther")
            \frMainOther=scsFrameGadget(0,0,GadgetWidth(\cntMainOther),GadgetHeight(\cntMainOther),Lang("WOP","frMainOther"),0,"frMainOther")
            nPromptLeft = 12
            nPromptWidth = 100
            nLeft = nPromptLeft + nPromptWidth + 7
            nTop = 16
            \lblMonitorSize=scsTextGadget(nPromptLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblMonitorSize"), #PB_Text_Right,"lblMonitorSize")
            \cboMonitorSize=scsComboBoxGadget(nLeft,nTop,150,21,0,"cboMonitorSize")
            nTop + 21
            \lblMTCDispLocn=scsTextGadget(nPromptLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblMTCDispLocn"), #PB_Text_Right,"lblMTCDispLocn")
            \cboMTCDispLocn=scsComboBoxGadget(nLeft,nTop,150,21,0,"cboMTCDispLocn")
            If grLicInfo\nLicLevel < #SCS_LIC_PRO
              setEnabled(\cboMTCDispLocn, #False)
            EndIf
            nTop + 21
            \lblTimerDispLocn=scsTextGadget(nPromptLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblTimerDispLocn"), #PB_Text_Right,"lblTimerDispLocn")
            \cboTimerDispLocn=scsComboBoxGadget(nLeft,nTop,150,21,0,"cboTimerDispLocn")
            If grLicInfo\nLicLevel < #SCS_LIC_STD
              setEnabled(\cboTimerDispLocn, #False)
            EndIf
            ; Deleted the following 8Jul2024 11.10.3as as part of removing the 'Max. Screen No.' display option - deemed unnecessary
;             nTop + 21
;             \lblMaxMonitor=scsTextGadget(nPromptLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblMaxMonitor"), #PB_Text_Right,"lblMaxMonitor")
;             \cboMaxMonitor=scsComboBoxGadget(nLeft,nTop,150,21,0,"cboMaxMonitor")
;             If grLicInfo\nLicLevel < #SCS_LIC_STD
;               setEnabled(\cboMaxMonitor, #False)
;             EndIf
;             nLeft = GadgetX(\cboMonitorSize) + GadgetWidth(\cboMonitorSize) + 20
            nLeft = GadgetX(\cboMonitorSize) + GadgetWidth(\cboMonitorSize) + 12
            nTop = 19
            \chkShowToolTips=scsCheckBoxGadget(nLeft,nTop,100,17,Lang("WOP","chkShowToolTips"),0,"chkShowToolTips")
            nTop + 17
            \chkAllowDisplayTimeout=scsCheckBoxGadget(nLeft,nTop,100,17,Lang("WOP","chkAllowDisplayTimeout"),0,"chkAllowDisplayTimeout")
            setGadgetWidth(\chkAllowDisplayTimeout)
            scsToolTip(\chkAllowDisplayTimeout, Lang("WOP", "chkAllowDisplayTimeoutTT"))
            nTop + 17
            \chkDisplayAllMidiIn=scsCheckBoxGadget(nLeft,nTop,270,17,Lang("WOP","chkDisplayAllMidiIn2"),0,"chkDisplayAllMidiIn")
            setGadgetWidth(\chkDisplayAllMidiIn)
            scsToolTip(\chkDisplayAllMidiIn, Lang("WOP", "chkDisplayAllMidiIn2TT"))
            nTop + 17
            \lblMidiInDisplayTimeout=scsTextGadget(nLeft,nTop+4,nPromptWidth,15,Lang("WOP","lblMidiInDisplayTimeout"),0,"lblMidiInDisplayTimeout")
            setGadgetWidth(\lblMidiInDisplayTimeout,-1,#True)
            \cboMidiInDisplayTimeout=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboMidiInDisplayTimeout")
          scsCloseGadgetList()
          
          nTop = GadgetY(\cntMainOther) + GadgetHeight(\cntMainOther) + 2
          \lblRequiresRestart2=scsTextGadget(GadgetX(\cntMainOther)+4,nTop+4,400,15,Lang("WOP","lblRequiresRestart"),0,"lblRequiresRestart")
          scsSetGadgetFont(\lblRequiresRestart2, #SCS_FONT_GEN_ITALIC)
          nWidth = 150
          nLeft = GadgetX(\cntMainOther) + GadgetWidth(\cntMainOther) - nWidth - 4
          \btnDefaultDisplayOptions=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,Lang("WOP","btnDefaultDisplayOptions"),0,"btnDefaultDisplayOptions")
          
        scsCloseGadgetList()
        setVisible(\cntDisplayOptions,#False)
        ;}
        ; INFO Options: Cue List Columns
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabCueListCols"), 0, 1)
        
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_COLS] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_COLS
        nColsNode = nNodeIndex
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabDesign"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_COLS_DESIGN] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_COLS_DESIGN
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabRehearsal"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_COLS_REHEARSAL] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_COLS_REHEARSAL
        
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabPerformance"), 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_COLS_PERFORMANCE] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_COLS_PERFORMANCE
        
        SetGadgetItemState(\tvwPrefTree, nColsNode, #PB_Tree_Expanded)
        
        \cntCueListCols=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntCueListCols")
          \frCueListCols=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP","tabCueListCols") + " - " + Lang("WOP","tabDesign"),0,"frCueListCols")
          scsSetGadgetFont(\frCueListCols, #SCS_FONT_GEN_BOLD)
          
          \lnColsOperMode=scsLineGadget(8,20,2,nTabHeight-28,0,0,"lnColsOperMode")
          
          \grdCueListCols=scsListIconGadget(100,40,200,250,Lang("WOP","grdCueListCols"),200,#PB_ListIcon_CheckBoxes|#PB_ListIcon_AlwaysShowSelection,"grdCueListCols")

          nBtnWidth = getMaxTextWidth(74, Lang("Btns","MoveUp"), Lang("Btns","MoveDown")) + gl3DBorderAllowanceX + gl3DBorderAllowanceX + 8
          \btnMoveUp=scsButtonGadget(307,70,nBtnWidth,gnBtnHeight,Lang("Btns","MoveUp"),0,"btnMoveUp")
          \btnMoveDown=scsButtonGadget(307,98,nBtnWidth,gnBtnHeight,Lang("Btns","MoveDown"),0,"btnMoveDown")
          nBtnWidth = getMaxTextWidth(140, Lang("WOP","btnColRevert"), Lang("WOP","btnColDefaults"), Lang("WOP","btnColFit")) + gl3DBorderAllowanceX + gl3DBorderAllowanceX + 8
          \btnColRevert=scsButtonGadget(307,146,nBtnWidth,gnBtnHeight,Lang("WOP","btnColRevert"),0,"btnColRevert")
          \btnColDefaults=scsButtonGadget(307,174,nBtnWidth,gnBtnHeight,Lang("WOP","btnColDefaults"),0,"btnColDefaults")
          \btnColFit=scsButtonGadget(307,202,nBtnWidth,gnBtnHeight,Lang("WOP","btnColFit"),0,"btnColFit")
          
          ; Added combobox to allow user to copy settings from another mode, Josh /05/2025
          \lblCopyModeSettings = scsTextGadget(100, 310, 200, 21, Lang("WOP", "lblCopyModeSettings"))
          \cboCopyModeSettings = scsComboBoxGadget(100, 326, 210, 21) 
          
          nBtnWidth = getMaxTextWidth(60, Lang("WOP", "btnCopyModeSettings"), Lang("WOP", "btnUndoModeSettings")) + gl3DBorderAllowanceX + gl3DBorderAllowanceX + 8
          \btnCopyModeSettings = scsButtonGadget(320, 325, 80, gnBtnHeight, Lang("WOP", "btnCopyModeSettings"))
          \btnUndoModeSettings = scsButtonGadget(410, 325, 80, gnBtnHeight, Lang("WOP", "btnUndoModeSettings"))
          
          ; Added user defined column header names with length parameter, Dee 24/03/2025.
          WOP\lblUserColumn1 = scsTextGadget(100,358,200,21,Lang("WOP","lblUserColumn1"),0,"lblUserColumn1")
          WOP\txtUserColumn1 = scsStringGadget(100,374,320,21,"",0,"txtUserColumn1", #SCS_USER_COLUMN_LENGTH)
          SetGadgetAttribute(WOP\txtUserColumn1, #PB_String_MaximumLength, #SCS_USER_COLUMN_LENGTH)
          nLeft2 = GetTextWidth(#SCS_USER_COLUMN_DUMMY_TEXT)
          ResizeGadget(WOP\txtUserColumn1, #PB_Ignore, #PB_Ignore, nLeft2, #PB_Ignore)
          nBtnWidth = getMaxTextWidth(60, Lang("Btns","reset")) + gl3DBorderAllowanceX + gl3DBorderAllowanceX + 8
          \btnResetUserColumn1=scsButtonGadget(100 + nLeft2 + 8,373,nBtnWidth,gnBtnHeight,Lang("Btns","reset"),0,"btnResetUserColumn1")
          WOP\lblUserColumn2 = scsTextGadget(100,406,200,21,Lang("WOP","lblUserColumn2"),0,"lblUserColumn2")
          WOP\txtUserColumn2 = scsStringGadget(100,422,320,21,"",0,"txtUserColumn2", #SCS_USER_COLUMN_LENGTH)
          WOP\lblUserColumnWarning = scsTextGadget(100,450,320,16,Lang("WOP","lblRequiresRestart"),0,"lblRequiresRestart")
          SetGadgetAttribute(WOP\txtUserColumn2, #PB_String_MaximumLength, #SCS_USER_COLUMN_LENGTH)
          ResizeGadget(WOP\txtUserColumn2, #PB_Ignore, #PB_Ignore, GetTextWidth(#SCS_USER_COLUMN_DUMMY_TEXT), #PB_Ignore)
          \btnResetUserColumn2=scsButtonGadget(100 + nLeft2 + 8,421,nBtnWidth,gnBtnHeight,Lang("Btns","reset"),0,"btnResetUserColumn2")
          
          If gnuserColumnChanged1 <> 0
            SetGadgetColor(WOP\txtUserColumn1, #PB_Gadget_BackColor, $c0c0ff)
            setEnabled(WOP\btnResetUserColumn1, #True)
          Else
            setEnabled(WOP\btnResetUserColumn1, #False)
          EndIf

          If gnuserColumnChanged2 <> 0
            SetGadgetColor(WOP\txtUserColumn2, #PB_Gadget_BackColor, $c0c0ff)
            setEnabled(WOP\btnResetUserColumn2, #True)
          Else
            setEnabled(WOP\btnResetUserColumn2, #False)
          EndIf

        SetGadgetColor(WOP\lblUserColumnWarning, #PB_Gadget_BackColor, $c0c0ff)
        scsCloseGadgetList()
        setVisible(\cntCueListCols,#False)
        ;}
        ; INFO Options: Audio Driver
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabAudio"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_AUDIO_DRIVER] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_AUDIO_DRIVER
        nAudioDriverNode = nNodeIndex
        
        \cntAudioDriver=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntAudioDriver")
          \frAudioDriver=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP","frAudioDriver"),0,"frAudioDriver")
          scsSetGadgetFont(\frAudioDriver, #SCS_FONT_GEN_BOLD)
        scsCloseGadgetList()
        setVisible(\cntAudioDriver,#False)
        
        ; BASS - DirectSound/WASAPI Settings
        sDSWASAPI = Lang("AudioDriver","BASS_DS") + "/" + Lang("AudioDriver","BASS_WASAPI")
        AddGadgetItem(\tvwPrefTree, -1, sDSWASAPI, 0, 2)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_BASS_DS] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_BASS_DS ; 'DS' originally just for DirectSound, but now also includes WASAPI
        
        \cntBASSDS=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntBASSDS")
          \frBASSDS=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP","frBASSDS"),0,"frBASSDS")
          scsSetGadgetFont(\frBASSDS, #SCS_FONT_GEN_BOLD)
          
          nTop = 24
          \cntDriverFlags=scsContainerGadget(8,nTop,280,62,0,"cntDriverFlags")
            \chkNoFloatingPoint=scsCheckBoxGadget(8,9,270,17,Lang("WOP","chkNoFloatingPoint"),0,"chkNoFloatingPoint")
            scsToolTip(\chkNoFloatingPoint,Lang("WOP","chkNoFloatingPointTT"))
            \chkSwap34with56=scsCheckBoxGadget(8,26,270,17,Lang("WOP","chkSwap34with56"),0,"chkSwap34with56")
            scsToolTip(\chkSwap34with56,Lang("WOP","chkSwap34with56TT"))
            \chkNoWASAPI=scsCheckBoxGadget(8,43,270,17,Lang("WOP","chkNoWASAPI"),0,"chkNoWASAPI")
            scsToolTip(\chkNoWASAPI,Lang("WOP","chkNoWASAPITT"))
          scsCloseGadgetList()
          
          \cntBASSMixer=scsContainerGadget(296,nTop,340,88,0,"cntBASSMixer")
            \frBASSMixer=scsFrameGadget(0,0,340,88,Lang("WOP","frBASSMixer"),0,"frBASSMixer")
            \optBASSMixer[0]=scsOptionGadget(21,15,316,17,Lang("WOP","optBASSMixer[0]"),"optBASSMixer[0]")
            \optBASSMixer[1]=scsOptionGadget(21,32,316,17,Lang("WOP","optBASSMixer[1]"),"optBASSMixer[1]")
          scsCloseGadgetList()
          
          nTop + GadgetHeight(\cntDriverFlags) + 12
          \cntPlaybackBuffer=scsContainerGadget(8,nTop,280,90,0,"cntPlaybackBuffer")
            \frPlaybackBuffer=scsFrameGadget(0,0,280,90,Lang("WOP","frPlaybackBuffer"),0,"frPlaybackBuffer")
            \optPlaybackbuf[0]=scsOptionGadget(21,20,255,15,"","optPlaybackbuf[0]") ; text and tooltip for [0] populated dynamically as it includes a variable
            \optPlaybackbuf[1]=scsOptionGadget(21,39,255,15,Lang("WOP","optPlaybackbuf[1]"),"optPlaybackbuf[1]")
            scsToolTip(\optPlaybackbuf[1],Lang("WOP","optPlaybackbufTT[1]"))
            \txtPlaybackBufLength=scsStringGadget(48,56,54,21,"",#PB_String_Numeric,"txtPlaybackBufLength")
            scsToolTip(\txtPlaybackBufLength,Lang("WOP","txtPlaybackBufLengthTT"))
            \lblPlaybackLength=scsTextGadget(110,58,70,17,Lang("WOP","lblPlaybackLength"),0,"lblPlaybackLength")
            setGadgetWidth(\lblPlaybackLength) ; Added 25May2021 11.8.5ad following an email from Francisco Gomez that contained a screenshot that had this translated text curtailed
          scsCloseGadgetList()
          
          \cntUpdatePeriod=scsContainerGadget(296,nTop,340,90,0,"cntUpdatePeriod")
            \frUpdatePeriod=scsFrameGadget(0,0,340,90,Lang("WOP","frUpdatePeriod"),0,"frUpdatePeriod")
            \optUpdatePeriod[0]=scsOptionGadget(21,20,300,15,"","optUpdatePeriod[0]") ; text and tooltip for [0] populated dynamically as it includes a variable
            \optUpdatePeriod[1]=scsOptionGadget(21,39,300,15,Lang("WOP","optUpdatePeriod[1]"),"optUpdatePeriod[1]")
            scsToolTip(\optUpdatePeriod[1],Lang("WOP","optUpdatePeriodTT[1]"))
            \txtUpdatePeriodLength=scsStringGadget(48,56,54,21,"",#PB_String_Numeric,"txtUpdatePeriodLength")
            scsToolTip(\txtUpdatePeriodLength,Lang("WOP","txtUpdatePeriodLengthTT"))
            \lblUpdatePeriod=scsTextGadget(110,58,70,17,Lang("WOP","lblUpdatePeriod"),0,"lblUpdatePeriod")
            setGadgetWidth(\lblUpdatePeriod) ; Added 25May2021 11.8.5ad following an email from Francisco Gomez that contained a screenshot that had this translated text curtailed
          scsCloseGadgetList()
          
          CompilerIf #cAlwaysUseMixerForBass
            ; added 28Dec2015
            setVisible(\cntBASSMixer, #False)
            setVisible(\cntPlaybackBuffer, #False)
            setVisible(\cntUpdatePeriod, #False)
            nTop = GadgetY(\cntDriverFlags) + GadgetHeight(\cntDriverFlags) + 20
            ; end of added 28Dec2015
          CompilerElse
            nTop + GadgetHeight(\cntPlaybackBuffer) + 20
          CompilerEndIf
          
          \lblSampleRate=scsTextGadget(0,nTop+4,146,18,Lang("WOP","lblSampleRate"),#PB_Text_Right,"lblSampleRate")
          \cboSampleRate=scsComboBoxGadget(152,nTop,102,21,0,"cboSampleRate")
          
          nTop + 40
          \lblLinkSyncPoint=scsTextGadget(0,nTop+4,146,17,Lang("WOP","lblLinkSyncPoint"),#PB_Text_Right,"lblLinkSyncPoint")
          \txtLinkSyncPoint=scsStringGadget(152,nTop,54,21,"",#PB_String_Numeric,"txtLinkSyncPoint")
          \lblLinkSyncms=scsTextGadget(213,nTop+4,70,17,Lang("WOP","lblLinkSyncms"),0,"lblLinkSyncms")
          setGadgetWidth(\lblLinkSyncms) ; Added 25May2021 11.8.5ad following an email from Francisco Gomez that contained a screenshot that had this translated text curtailed
          
        scsCloseGadgetList() ; cntBASSDS
        setVisible(\cntBASSDS,#False)
        
        ; BASS - ASIO Settings
        If grLicInfo\bASIOAvailable
          If grLicInfo\bSMSAvailable
            sNodeText = Lang("AudioDriver", "BASS_ASIO_PRO")
            sFrameText = Lang("WOP", "frBASSASIO")  ; currently the frame text is the same for both plus and lower, but that could change!
          Else
            sNodeText = Lang("AudioDriver", "BASS_ASIO")
            sFrameText = Lang("WOP", "frBASSASIO")
          EndIf
          AddGadgetItem(\tvwPrefTree, -1, sNodeText, 0, 2)
          nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
          grWOP\nNodeIndex[#SCS_OPTNODE_BASS_ASIO] = nNodeIndex
          grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_BASS_ASIO
          
          \cntBASSASIO=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntBASSASIO")
            \frBASSASIO=scsFrameGadget(0,0,nTabWidth,nTabHeight,sFrameText,0,"frBASSASIO")
            scsSetGadgetFont(\frBASSASIO, #SCS_FONT_GEN_BOLD)
            
            nTop = 32
            CompilerIf #cEnableASIOBufLen
              \lblAsioBufLen=scsTextGadget(10,nTop+4,139,17,Lang("WOP","lblAsioBufLen"),#PB_Text_Right,"lblAsioBufLen")
              \cboAsioBufLen=scsComboBoxGadget(gnNextX+7,nTop,200,23,0,"cboAsioBufLen")
              scsToolTip(\cboAsioBufLen,Lang("WOP","cboAsioBufLenTT"))
              nTop + 30
              nLeft = GadgetX(\cboAsioBufLen)
            CompilerElse
              nLeft = 156
            CompilerEndIf
            
            CompilerIf #cEnableFileBufLen
              \lblFileBufLen=scsTextGadget(10,nTop+4,139,15,Lang("WOP","lblFileBufLen"),#PB_Text_Right,"lblFileBufLen")
              \cboFileBufLen=scsComboBoxGadget(gnNextX+7,nTop,200,23,0,"cboFileBufLen")
              scsToolTip(\cboFileBufLen,Lang("WOP","cboFileBufLenTT"))
              nTop + 30
            CompilerEndIf
            
            nTop + 12   ; extra vertical spacing before ASIO Control Panel button
            \btnAsioControlPanel=scsButtonGadget(nLeft,nTop,125,gnBtnHeight,Lang("WOP","btnAsioControlPanel"),0,"btnAsioControlPanel")
            setGadgetWidth(\btnAsioControlPanel,25)
            
          scsCloseGadgetList() ; cntBASSASIO
          setVisible(\cntBASSASIO,#False)
          
        EndIf
        
        ;- SM-S Settings
        If grLicInfo\bSMSAvailable
          AddGadgetItem(\tvwPrefTree, -1, decodeDriverL(#SCS_DRV_SMS_ASIO), 0, 2)
          nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
          grWOP\nNodeIndex[#SCS_OPTNODE_SMS_ASIO] = nNodeIndex
          grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_SMS_ASIO
          
          \cntSMS=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntSMS")
            \frSMS=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP","frSMS"),0,"frSMS")
            scsSetGadgetFont(\frSMS,#SCS_FONT_GEN_BOLD)
            CompilerIf #cSMSOnThisMachineOnly = #False
              \chkSMSOnThisMachine=scsCheckBoxGadget(156,31,252,17,Lang("WOP","chkSMSOnThisMachine"),0,"chkSMSOnThisMachine")
            CompilerEndIf
            \lblSMSHost=scsTextGadget(69,60,82,15,Lang("WOP","lblSMSHost"),#PB_Text_Right,"lblSMSHost")
            \ipSMSHost=scsIPAddressGadget(gnNextX+gnGap2,57,100,21,"ipSMSHost")
            \lblSMSPort=scsTextGadget(gnNextX+gnGap,60,70,15,Lang("WOP","lblSMSPort"),#PB_Text_Right,"lblSMSPort")
            setGadgetWidth(\lblSMSPort, -1, #True)
            \txtSMSPort=scsStringGadget(gnNextX+gnGap,57,47,21,"20000",#PB_String_ReadOnly,"txtSMSPort")
            \btnTestSMS=scsButtonGadget(GadgetX(\ipSMSHost),88,150,gnBtnHeight,Lang("WOP","btnTestSMS"),0,"btnTestSMS")
            \lblTestSMSResult=scsTextGadget(gnNextX+gnGap2,93,222,15,"",0,"lblTestSMSResult")
            \lblTestSMS=scsTextGadget(72,112,440,31,Lang("WOP","lblTestSMS"),#PB_Text3D_Left,"lblTestSMS")

            ; Added/changed 28Dec2022 11.9.8ab
            nTop = 93 + 23
            CompilerIf #cSMSOnThisMachineOnly = #False
              nTop = 144
              \lblAudioFilesRootFolder=scsTextGadget(4,nTop+4,145,15,Lang("WOP","lblAudioFilesRootFolder"),#PB_Text_Right,"lblAudioFilesRootFolder")
              \txtAudioFilesRootFolder=scsStringGadget(156,nTop+1,382,21,"",#PB_String_ReadOnly,"txtAudioFilesRootFolder")
              scsToolTip(\txtAudioFilesRootFolder,Lang("WOP","txtAudioFilesRootFolderTT"))
              \btnBrowseAudioFilesRootFolder=scsButtonGadget(542,nTop,73,gnBtnHeight,LangEllipsis("Btns","Browse"),0,"btnBrowseAudioFilesRootFolder")
              nTop + 23
            CompilerEndIf
            CompilerIf 1=2 ; blocked out because BASS_ASIO_ControlPanel() cannot be successfully called for ASIO devices currently open in SM-S
              nTop + 12   ; extra vertical spacing before ASIO Control Panel button
              \btnAsioControlPanelSMS=scsButtonGadget(nLeft,nTop,125,gnBtnHeight,Lang("WOP","btnAsioControlPanel"),0,"btnAsioControlPanelSMS")
              setGadgetWidth(\btnAsioControlPanelSMS,25)
            CompilerEndIf
            ; End added/changed 28Dec2022 11.9.8ab
            nTop + 30
            \lblMinPChansNonHK=scsTextGadget(52,nTop+gnLblVOffsetS,386,15,Lang("WOP","lblMinPChansNonHK"),#PB_Text_Right,"lblMinPChansNonHK")
            \txtMinPChansNonHK=scsStringGadget(gnNextX+gnGap,nTop,35,21,"",#PB_String_Numeric,"txtMinPChansNonHK")
          scsCloseGadgetList()
          setVisible(\cntSMS,#False)
          
        EndIf
        
        SetGadgetItemState(\tvwPrefTree, nAudioDriverNode, #PB_Tree_Expanded)
        ;}
        ; INFO Options: Video Driver Options
        ;{
        If grLicInfo\nLicLevel >= #SCS_LIC_STD
          AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabVideo"), 0, 1)
          nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
          grWOP\nNodeIndex[#SCS_OPTNODE_VIDEO_DRIVER] = nNodeIndex
          grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_VIDEO_DRIVER
          
          \cntVideoDriver=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntVideoDriver")
            \frVideoDriver=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabVideo"),0,"frVideoDriver")
            scsSetGadgetFont(\frVideoDriver, #SCS_FONT_GEN_BOLD)
            
            nTop = 24
            \lblVideoLibrary=scsTextGadget(4,nTop+gnLblVOffsetC,200,15,Lang("WOP","lblVideoLibrary"),#PB_Text_Right,"lblVideoLibrary")
            \cboVideoLibrary=scsComboBoxGadget(gnNextX+7,nTop,140,21,0,"cboVideoLibrary")
            CompilerIf #c_blackmagic_card_support = #False
              nTop + 23
              \lblVideoRenderer=scsTextGadget(4,nTop+gnLblVOffsetC,200,15,Lang("WOP","lblVideoRenderer"),#PB_Text_Right,"lblVideoRenderer")
              \cboVideoRenderer=scsComboBoxGadget(gnNextX+7,nTop,240,21,0,"cboVideoRenderer")
            CompilerEndIf
            nTop + 23
            \lblTVGPlayerHwAccel=scsTextGadget(4,nTop+gnLblVOffsetC,200,15,Lang("WOP","lblTVGPlayerHWAccel"),#PB_Text_Right,"lblTVGPlayerHWAccel")
            \cboTVGPlayerHWAccel=scsComboBoxGadget(gnNextX+7,nTop,240,21,0,"cboTVGPlayerHWAccel")
            nTop + 23
            \chkTVGDisplayVUMeters=scsCheckBoxGadget(GadgetX(\cboTVGPlayerHwAccel),nTop,200,17,Lang("WOP","chkTVGDisplayVUMeters"),0,"chkTVGDisplayVUMeters")
            setGadgetWidth(\chkTVGDisplayVUMeters)
            scsToolTip(\chkTVGDisplayVUMeters, Lang("WOP", "chkTVGDisplayVUMetersTT"))
            nTop + 19
            \chkDisableVideoWarningMessage=scsCheckBoxGadget(GadgetX(\chkTVGDisplayVUMeters),nTop,270,17,Lang("WOP","chkDisableVideoWarningMessage"),0,"chkDisableVideoWarningMessage")
            setGadgetWidth(\chkDisableVideoWarningMessage)
            scsToolTip(\chkDisableVideoWarningMessage, Lang("WOP", "chkDisableVideoWarningMessageTT"))
            
            nLeft = 40
            nTop + 40
            CompilerIf #c_blackmagic_card_support
              nWidth = 520
            CompilerElse
              nWidth = 392
            CompilerEndIf
            nHeight = 200
            \cntSplitScreenInfo=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntSplitScreenInfo")
              \frSplitScreenInfo=scsFrameGadget(0,0,nWidth,nHeight,Lang("WOP","frSplitScreenInfo"),0,"frSplitScreenInfo")
              nTop = 24
              \lblRealScreenSize=scsTextGadget(12,nTop,110,15,Lang("WOP","lblRealScreenSize"),0,"lblRealScreenSize")
              CompilerIf #c_blackmagic_card_support
                \lblScreenVideoRenderer=scsTextGadget(gnNextX,nTop,129,15,Lang("WOP","lblVideoRenderer"),0,"lblScreenVideoRenderer")
              CompilerEndIf
              \lblSplitScreenCount=scsTextGadget(gnNextX,nTop,128,15,Lang("WOP","lblSplitScreenCount"),0,"lblSplitScreenCount")
              \lblScreens=scsTextGadget(gnNextX,nTop,120,15,Lang("WOP","lblScreens"),0,"lblScreens")
              nLeft = 4
              nTop + 17
              nWidth = GadgetWidth(\cntSplitScreenInfo) - 8
              nHeight = GadgetHeight(\cntSplitScreenInfo) - nTop - 12
              nScrollAreaWidth = nWidth - glScrollBarWidth - 4
              nItemHeight = 21
              nScrollAreaHeight = (nItemHeight * grVideoDriver\nRealScreensConnected) + gl3DBorderAllowanceY
              If nHeight > (nScrollAreaHeight + gl3DBorderAllowanceY)
                nHeight = (nScrollAreaHeight + gl3DBorderAllowanceY)
              EndIf
              \scaSplitScreenInfo=scsScrollAreaGadget(nLeft, nTop, nWidth, nHeight, nScrollAreaWidth,nScrollAreaHeight,nItemHeight,#PB_ScrollArea_BorderLess,"scaSplitScreenInfo")
                debugMsg(sProcName, "grVideoDriver\nRealScreensConnected=" + grVideoDriver\nRealScreensConnected)
                For nMonitorNr = 1 To grVideoDriver\nRealScreensConnected
                  debugMsg(sProcName, "nMonitorNr=" + nMonitorNr)
                  For n = 0 To grVideoDriver\nSplitScreenArrayMax
                    If grVideoDriver\aSplitScreenInfo[n]\nCurrentMonitorIndex = nMonitorNr
                      n2 = nMonitorNr - 1
                      nTop = n2 * nItemHeight
                      If n2 < 10
                        sNr = "[0" + n2 + "]"
                      Else
                        sNr = "[" + n2 + "]"
                      EndIf
                      \txtRealScreenSize[n2]=scsStringGadget(4,nTop,103,21,"",#PB_String_ReadOnly,"txtRealScreenSize"+sNr)
                      CompilerIf #c_blackmagic_card_support
                        \cboScreenVideoRenderer[n2]=scsComboBoxGadget(gnNextX+7,nTop,123,21,0,"cboScreenVideoRenderer"+sNr)
                      CompilerEndIf
                      \cboSplitScreenCount[n2]=scsComboBoxGadget(gnNextX+7,nTop,120,21,0,"cboSplitScreenCount"+sNr)
                      SetGadgetData(\cboSplitScreenCount[n2], n) ; save aSplitScreenInfo[] array index as the data item
                      \txtScreens[n2]=scsStringGadget(gnNextX+7,nTop+1,120,21,"",#PB_String_ReadOnly,"txtScreens"+sNr)
                      scsToolTip(\txtScreens[n2],Lang("WOP","txtScreensTT"))
                    EndIf
                  Next n
                Next nMonitorNr
              scsCloseGadgetList()
            scsCloseGadgetList()
            
            nHeight = GadgetY(\scaSplitScreenInfo) + GadgetHeight(\scaSplitScreenInfo) + 8
            If nHeight < GadgetHeight(\cntSplitScreenInfo)
              ResizeGadget(\cntSplitScreenInfo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
              ResizeGadget(\frSplitScreenInfo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
            EndIf
            
            nLeft = GadgetX(\cntSplitScreenInfo) + GadgetX(\scaSplitScreenInfo)
            nTop = GadgetY(\cntSplitScreenInfo) + GadgetHeight(\cntSplitScreenInfo) + 8
            nWidth = 330
            nHeight = 50
            \grdScreens=scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("WOP","colScreen"),110,#PB_ListIcon_GridLines,"grdScreens")
            AddGadgetColumn(\grdScreens,1,Lang("WOP","colPosAndSize"),180)
            
            nTop = GadgetHeight(\cntVideoDriver) - 40 ; Changed 16Jan2025 11.10.6-b05 
            \lblChanges=scsTextGadget(106,nTop,350,17,Lang("WOP","lblChanges"),0,"lblChanges")
            scsSetGadgetFont(\lblChanges, #SCS_FONT_GEN_ITALIC)
            setGadgetWidth(\lblChanges)
            
          scsCloseGadgetList()
          
          setVisible(\cntVideoDriver,#False)
        EndIf
        ;}
        ; INFO Options: Remote App Interface
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabRAI"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_RAI] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_RAI
        \cntRAI=scsContainerGadget(0,0,nTabWidth,nTabHeight,#PB_Container_Flat,"cntRAI")
          \frRAI=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabRAI"),0,"frRAI")
          scsSetGadgetFont(\frRAI, #SCS_FONT_GEN_BOLD)
          nLeft = 98 + gnGap
          nTop = 32
          \chkRAIEnabled=scsCheckBoxGadget(nLeft,nTop,252,17,Lang("WOP","chkRAIEnabled"),0,"chkRAIEnabled")
          nleft = 4
          nTop + 32
          \lblRAIApp=scsTextGadget(nLeft,nTop+4,94,17,Lang("WOP","lblRAIApp"),#PB_Text_Right,"lblRAIApp")
          \cboRAIApp=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboRAIApp")
          nTop + 23
          \lblRAINetworkProtocol=scsTextGadget(nLeft,nTop+4,94,17,Lang("Network","lblNetworkProtocol"),#PB_Text_Right,"lblRAINetworkProtocol")
          \cboRAINetworkProtocol=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboRAINetworkProtocol")
          nTop + 23
          \lblRAIOSCVersion=scsTextGadget(nLeft,nTop+4,94,17,Lang("Network","OSCVersion"),#PB_Text_Right,"lblRAIOSCVersion")
          \cboRAIOSCVersion=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboRAIOSCVersion")
          nTop + 40
          \lblRAIServerInfo=scsTextGadget(nLeft+12,nTop,94,17,Lang("WOP","lblRAIServerInfo"),0,"lblRAIServerInfo")
          scsSetGadgetFont(\lblRAIServerInfo, #SCS_FONT_GEN_ITALIC)
          nMaxWidth = GadgetWidth(\cntRAI) - GadgetX(\lblRAIServerInfo) - 12
          setGadgetWidth(\lblRAIServerInfo, -1, #False, nMaxWidth, #True)
          nTop + GadgetHeight(\lblRAIServerInfo) + 3
          \lblRAILocalIPAddr=scsTextGadget(nLeft,nTop+4,94,15,Lang("Network","IPAddr"),#PB_Text_Right,"lblRAILocalIPAddr")
          \cboRAILocalIPAddr=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboRAILocalIPAddr")
          scsToolTip(\cboRAILocalIPAddr, Lang("WOP","cboRAILocalIPAddrTT"))
          \btnRAIIPInfo=scsButtonGadget(gnNextX+gnGap,nTop,100,21,LangEllipsis("WOP","btnRAIIPInfo"),0,"btnRAIIPInfo")
          nTop + 23
          \lblRAILocalPort=scsTextGadget(nLeft,nTop+4,94,15,Lang("Network","PortNo"),#PB_Text_Right,"lblRAILocalPort")
          \txtRAILocalPort=scsStringGadget(gnNextX+gnGap,nTop,50,21,"",#PB_String_Numeric,"txtRAILocalPort")
        scsCloseGadgetList()
        setVisible(\cntRAI,#False)
        ;}
        ; INFO Options: Functional Mode
        ;{
        If (grLicInfo\nLicLevel >= #SCS_LIC_PLUS)
          AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabFM"), 0, 1)
          nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
          grWOP\nNodeIndex[#SCS_OPTNODE_FUNCTIONAL_MODE] = nNodeIndex
          grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_FUNCTIONAL_MODE
          \cntFM=scsContainerGadget(0,0,nTabWidth,nTabHeight,#PB_Container_Flat,"cntFM")
            \frFM=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabFM"),0,"frFM")
            scsSetGadgetFont(\frFM, #SCS_FONT_GEN_BOLD)
            nLeft = 98 + gnGap
            nTop = 30
            nLeft = 10
            \lblFMDescription = scsTextGadget(nLeft, nTop, 300, 27, Lang("Common","StandAlone"), 0, "lblFMDescription")
            scsSetGadgetFont(\lblFMDescription, #SCS_FONT_GEN_ITALIC)
            setGadgetWidth(\lblFMDescription, -1)
            nTop + 40
            ;nLeft = 1
            \lblFMFunctionalMode=scsTextGadget(nLeft, nTop+4,94,17,Lang("Common","FunctionalMode"),#PB_Text_Right,"lblFMNetworkRole")
            \cboFMFunctionalMode=scsComboBoxGadget(gnNextX+gnGap,nTop,40,21,0,"cboFMFunctionalMode")
            setEnabled(\cboFMFunctionalMode, #True)  
            nTop + 40
            nLeft + 10
            \lblFMFuncMode=scsTextGadget(nLeft,nTop,200,17,Lang("WOP","IPDescription"),#PB_Text_Right,"lblFMFuncMode")
            setGadgetWidth(\lblFMFuncMode, -1)
            nLeft = GadgetX(\lblFMFunctionalMode)
            \lblFMServerAddr=scsTextGadget(nLeft, nTop+4, 150,17, Lang("WOP", "ServerAddress"),#PB_Text_Right, "lblFMServerAddr")
            sName = Lang("WOP","txtFMServerAddr")
            \txtFMServerAddr=scsStringGadget(gnNextX+gnGap,nTop,150,21, "", 0, sName)
            setGadgetWidth(\txtFMServerAddr, 300)
            scsToolTip(\txtFMServerAddr, Lang("WOP", "txtFMServerAddrTT"))
            nTop + 20
            \lblFMLocalIPAddr=scsTextGadget(nLeft,nTop+4,94,15,Lang("Network","IPAddr"),#PB_Text_Right,"lblFMLocalIPAddr")
            \cboFMLocalIPAddr=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboFMLocalIPAddr")
            scsToolTip(\cboFMLocalIPAddr, Lang("WOP","cboFMLocalIPAddrTT"))
            \btnFMIPInfo=scsButtonGadget(gnNextX+gnGap,nTop,100,21,LangEllipsis("WOP","btnFMAIIPInfo"),0,"btnFMIPInfo")
            nTop + 23
            nLeft + 158
            \chkBackupIgnoreLIGHTING=scsCheckBoxGadget(nLeft, nTop, 200, 21, Lang("WOP", "BackupIgnoreLighting"), 0, "chkBackupIgnoreLIGHTING")
            scsToolTip(\chkBackupIgnoreLIGHTING, Lang("WOP", "BackupIgnoreLightingTT"))
            nTop+23
            \chkBackupIgnoreCtrlSendMIDI=scsCheckBoxGadget(nLeft, nTop, 200, 21, Lang("WOP", "BackupIgnoreMidi"),0, "chkBackupIgnoreCtrlSendMIDI") 
            scsToolTip(\chkBackupIgnoreCtrlSendMIDI, Lang("WOP", "BackupIgnoreMidiTT"))
            nTop+23
            \chkBackupIgnoreCtrlSendNETWORK=scsCheckBoxGadget(nLeft, nTop, 200, 21, Lang("WOP", "BackupIgnoreNetwork"), 0, "chkBackupIgnoreCtrlSendNETWORK") 
            scsToolTip(\chkBackupIgnoreCtrlSendNETWORK, Lang("WOP", "BackupIgnoreNetworkTT"))
            nTop+23
            \chkBackupIgnoreCueCtrlDevs=scsCheckBoxGadget(nLeft, nTop, 200, 21, Lang("WOP", "BackupIgnoreCCDevs"), 0, "chkBackupIgnoreCueCtrlDevs") 
            scsToolTip(\chkBackupIgnoreCueCtrlDevs, Lang("WOP", "BackupIgnoreCCDevsTT"))
          scsCloseGadgetList()
          setVisible(\cntFM,#False)
        EndIf
        ;}
        ; INFO Options: Shortcuts
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabShortcuts"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_SHORTCUTS] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_SHORTCUTS
        
        \cntShortcuts=scsContainerGadget(0,0,nTabWidth,nTabHeight,#PB_Container_Flat,"cntShortcuts")
          \cboShortGroup=scsComboBoxGadget(16,4,100,21,0,"cboShortGroup")
          
          \grdShortcuts=scsListIconGadget(2,29,356,372,Lang("WOP","grdFunction"),168,
                                          #PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines,"grdShortcuts")
          AddGadgetColumn(\grdShortcuts,1,Lang("WOP","grdShortcut"),84) ; nb width was 136
          ; commented out the following 14Jan2016 11.4.2 RC4 as this is now set unconditionally in scsListIconGadget()
          ; SendMessage_(GadgetID(\grdShortcuts), #LVM_SETEXTENDEDLISTVIEWSTYLE, #LVS_EX_LABELTIP, -1) ; causes values wider than the column width to be displayed as a tooltip
          
          nLeft = 370
          \lblSelectedFunction=scsTextGadget(nLeft,64,165,17,Lang("WOP","lblSelectedFunction"),0,"lblSelectedFunction")
          \lblSelectedInfo=scsTextGadget(nLeft,81,165,32,"",#PB_Text_Border,"lblSelectedInfo")
          
          \lblNewKey=scsTextGadget(nLeft,116,151,31,Lang("WOP","lblNewKey"),0,"lblNewKey")
          \shcSelectShortcut=scsShortcutGadget(nLeft,147,149,21,0,"shcSelectShortcut")
          
          \lblCurrentAssignment=scsTextGadget(nLeft,182,165,17,Lang("WOP","lblCurrentAssignment"),0,"lblCurrentAssignment")
          \lblCurrentInfo=scsTextGadget(nLeft,199,165,32,"",#PB_Text_Border,"lblCurrentInfo")
          
          nLeft = 539
          \btnDefaultShortcuts=scsButtonGadget(nLeft,32,110,38,Lang("WOP","btnDefaultShortcuts"),#PB_Button_MultiLine,"btnDefaultShortcuts")
          \btnKeyRemove=scsButtonGadget(nLeft,117,110,38,Lang("WOP","btnKeyRemove"),#PB_Button_MultiLine,"btnKeyRemove")
          \btnKeyAssign=scsButtonGadget(nLeft,160,110,38,Lang("WOP","btnKeyAssign"),#PB_Button_MultiLine,"btnKeyAssign")
          \btnKeyReset=scsButtonGadget(nLeft,203,110,38,Lang("WOP","btnKeyReset"),#PB_Button_MultiLine,"btnKeyReset")
          
          nLeft = 370
          nTop = 270
          nWidth = 273
          \chkCtrlOverridesExclCue=scsCheckBoxGadget(nLeft,nTop,nWidth,17,Lang("WOP","chkCtrlOverridesExclCue"),0,"chkCtrlOverridesExclCue")
          scsToolTip(\chkCtrlOverridesExclCue,Lang("WOP","chkCtrlOverridesExclCueTT"))
          nWidth = GadgetWidth(\chkCtrlOverridesExclCue, #PB_Gadget_RequiredSize)
          ResizeGadget(\chkCtrlOverridesExclCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
          nTop + 25
          \chkHotkeysOverrideExclCue=scsCheckBoxGadget(nLeft,nTop,nWidth,17,Lang("WOP","chkHotkeysOverrideExclCue"),0,"chkHotkeysOverrideExclCue")
          scsToolTip(\chkHotkeysOverrideExclCue,Lang("WOP","chkHotkeysOverrideExclCueTT"))
          nWidth = GadgetWidth(\chkHotkeysOverrideExclCue, #PB_Gadget_RequiredSize)
          ResizeGadget(\chkHotkeysOverrideExclCue,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
          nTop + 25
          \chkDisableRightClick=scsCheckBoxGadget(nLeft,nTop,273,17,Lang("WOP","chkDisableRightClick"),0,"chkDisableRightClick")
          scsToolTip(\chkDisableRightClick,Lang("WOP","chkDisableRightClickTT"))
          nWidth = GadgetWidth(\chkDisableRightClick, #PB_Gadget_RequiredSize)
          ResizeGadget(\chkDisableRightClick,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
          nTop + 30
          \lblDBIncrement = scsTextGadget(nLeft,nTop,273,15,Lang("WOP","lblDBIncrement"),0,"lblDBIncrement")
          nTop + GadgetHeight(\lblDBIncrement)
          \cboDBIncrement = scsComboBoxGadget(nLeft,nTop,80,21,0,"cboDBIncrement")
          
          \lblShortcutInfo=scsTextGadget(16,410,617,17,Lang("WOP","lblShortcutInfo"),0,"lblShortcutInfo")
          
        scsCloseGadgetList()
        setVisible(\cntShortcuts,#False)
        ;}
        ; INFO Options: Editing Options
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabEditing"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_EDITING] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_EDITING
        
        \cntEditing=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntEditing")
          \frEditing=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabEditing"),0,"frEditing")
          scsSetGadgetFont(\frEditing, #SCS_FONT_GEN_BOLD)
          
          nTop = 4
          
          If grLicInfo\bExternalEditorsIncluded
            nTop = 22
            \cntExternalApps=scsContainerGadget(12,nTop,600,104,0,"cntExternalApps")
              \frExternalApps=scsFrameGadget(0,0,600,104,Lang("WOP","frExternalApps"),0,"frExternalApps")
              nTop2 = 22
              \lblAudioEditor=scsTextGadget(4,nTop2+gnLblVOffsetS,100,15,Lang("WOP","lblAudioEditor"),#PB_Text_Right,"lblAudioEditor")
              \txtAudioEditor=scsStringGadget(gnNextX+gnGap,nTop2,380,21,"",#PB_String_ReadOnly,"txtAudioEditor")
              scsToolTip(\txtAudioEditor,Lang("WOP","lblAudioEditorTT"))
              \btnAudioEditorBrowse=scsButtonGadget(gnNextX+3,nTop2,72,21,LangEllipsis("Btns","Browse"),0,"btnAudioEditorBrowse")
              nTop2 + 25
              \lblImageEditor=scsTextGadget(4,nTop2+gnLblVOffsetS,100,15,Lang("WOP","lblImageEditor"),#PB_Text_Right,"lblImageEditor")
              \txtImageEditor=scsStringGadget(gnNextX+gnGap,nTop2,380,21,"",#PB_String_ReadOnly,"txtImageEditor")
              scsToolTip(\txtImageEditor,Lang("WOP","lblImageEditorTT"))
              \btnImageEditorBrowse=scsButtonGadget(gnNextX+3,nTop2,72,21,LangEllipsis("Btns","Browse"),0,"btnImageEditorBrowse")
              nTop2 + 25
              \lblVideoEditor=scsTextGadget(4,nTop2+gnLblVOffsetS,100,15,Lang("WOP","lblVideoEditor"),#PB_Text_Right,"lblVideoEditor")
              \txtVideoEditor=scsStringGadget(gnNextX+gnGap,nTop2,380,21,"",#PB_String_ReadOnly,"txtVideoEditor")
              scsToolTip(\txtVideoEditor,Lang("WOP","lblVideoEditorTT"))
              \btnVideoEditorBrowse=scsButtonGadget(gnNextX+3,nTop2,72,21,LangEllipsis("Btns","Browse"),0,"btnVideoEditorBrowse")
            scsCloseGadgetList()
            nTop + GadgetHeight(\cntExternalApps)
          EndIf
          
          ; comboboxes
          nTop + 12
          nLeft = 40
          \frFileScanMaxLength=scsFrameGadget(12,nTop,600,77,Lang("WOP","lblFileScanMaxLength"),0,"frFileScanMaxLength")
          nTop + 22
          \lblFileScanMaxLengthAudio=scsTextGadget(nLeft,nTop+gnLblVOffsetS,100,15,Lang("Common","AudioFiles"),#PB_Text_Right,"lblFileScanMaxLengthAudio")
          \cboFileScanMaxLengthAudio=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboFileScanMaxLengthAudio")
          nTop + 23
          \lblFileScanMaxLengthVideo=scsTextGadget(nLeft,nTop+gnLblVOffsetS,100,15,Lang("Common","VideoFiles"),#PB_Text_Right,"lblFileScanMaxLengthVideo")
          \cboFileScanMaxLengthVideo=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboFileScanMaxLengthVideo")
          nTop + 23
          nLeft = 10
          nWidth = nLeft + GadgetWidth(\lblFileScanMaxLengthVideo)
          nTop + 22
          
          \lblAudioFileSelector=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("WOP","lblAudioFileSelector"),#PB_Text_Right,"lblAudioFileSelector")
          ; setGadgetWidth(\lblAudioFileSelector,nWidth,#True) ; increase length if necessary
          \cboAudioFileSelector=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboAudioFileSelector")
          addGadgetItemWithData(\cboAudioFileSelector, Lang("WOP", "SCS_AFS"), #SCS_FO_SCS_AFS)
          addGadgetItemWithData(\cboAudioFileSelector, Lang("WOP", "Windows_FS"), #SCS_FO_WINDOWS_FS)
          setComboBoxWidth(\cboAudioFileSelector)
          nTop + 26
          \lblEditorCueListFontSize=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("WOP","lblEditorCueListFontSize"),#PB_Text_Right,"lblEditorCueListFontSize")
          setGadgetWidth(\lblEditorCueListFontSize,nWidth,#True) ; increase length if necessary
          \cboEditorCueListFontSize=scsComboBoxGadget(gnNextX+gnGap,nTop,75,21,0,"cboEditorCueListFontSize")
          ; now make sure these last two items (file selector and font size) align together
          If GadgetWidth(\lblEditorCueListFontSize) > GadgetWidth(\lblAudioFileSelector)
            ResizeGadget(\cboAudioFileSelector,GadgetX(\cboEditorCueListFontSize),#PB_Ignore,#PB_Ignore,#PB_Ignore)
            ResizeGadget(\lblAudioFileSelector,#PB_Ignore,#PB_Ignore,GadgetWidth(\lblEditorCueListFontSize),#PB_Ignore)
          EndIf
          
          ; checkboxes
          nTop + 50
          nLeft = 70
          \chkSaveAlwaysOn=scsCheckBoxGadget(nLeft,nTop,270,17,Lang("WOP","chkSaveAlwaysOn"),0,"chkSaveAlwaysOn")
          setGadgetWidth(\chkSaveAlwaysOn)
          nTop + 25
          \chkIgnoreTitleTags=scsCheckBoxGadget(nLeft,nTop,270,17,Lang("WOP","chkIgnoreTitleTags"),0,"chkIgnoreTitleTags")
          setGadgetWidth(\chkIgnoreTitleTags)
          scsToolTip(\chkIgnoreTitleTags, Lang("WOP", "chkIgnoreTitleTagsTT"))
          nTop + 25
          \chkIncludeAllLevelPointDevices=scsCheckBoxGadget(nLeft, nTop, 270, 17, Lang("WOP", "chkIncludeAllLPDevices"),0,"chkIncludeAllLPDevs")
          setGadgetWidth(\chkIncludeAllLevelPointDevices)
          nTop + 25
          \chkCheckMainLostFocusWhenEditorOpen=scsCheckBoxGadget(nLeft,nTop,270,17,Lang("WOP","chkCheckMainLostFocusWhenEditorOpen"),0,"chkCheckMainLostFocusWhenEditorOpen")
          setGadgetWidth(\chkCheckMainLostFocusWhenEditorOpen)
          scsToolTip(\chkCheckMainLostFocusWhenEditorOpen, Lang("WOP", "chkCheckMainLostFocusWhenEditorOpenTT"))
          nTop + 25
          \chkActivateOCMAutoStarts=scsCheckBoxGadget(nLeft,nTop,270,17,Lang("WOP","chkActivateOCMAutoStarts"),0,"chkActivateOCMAutoStarts")
          setGadgetWidth(\chkActivateOCMAutoStarts)
          scsToolTip(\chkActivateOCMAutoStarts, Lang("WOP", "chkActivateOCMAutoStartsTT"))
          
        scsCloseGadgetList()
        setVisible(\cntEditing,#False)
        ;}
        ; INFO Options: Session Options
        ;{
        AddGadgetItem(\tvwPrefTree, -1, Lang("WOP", "tabSession"), 0, 1)
        nNodeIndex = CountGadgetItems(\tvwPrefTree)-1
        grWOP\nNodeIndex[#SCS_OPTNODE_SESSION] = nNodeIndex
        grWOP\nNodeKey[nNodeIndex] = #SCS_OPTNODE_SESSION
        
        \cntSession=scsContainerGadget(0,0,nTabWidth,nTabHeight,0,"cntSession")
          \frSession=scsFrameGadget(0,0,nTabWidth,nTabHeight,Lang("WOP", "tabSession"),0,"frSession")
          scsSetGadgetFont(\frSession, #SCS_FONT_GEN_BOLD)
          
          nTop = 30
          \lblCtrlSendDevices=scsTextGadget(48,nTop,nTabWidth-52,17,Lang("WOP","lblCtrlSendDevices"),0,"lblCtrlSendDevices")
          scsSetGadgetFont(\lblCtrlSendDevices, #SCS_FONT_GEN_BOLD)
          
          nTop + 20
          \lblMidiOutEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblMidiOutEnabled"),#PB_Text_Right,"lblMidiOutEnabled")
          \optMidiOutEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optMidiOutEnabled[0]")
          \optMidiOutEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optMidiOutEnabled[1]")
          \optMidiOutEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optMidiOutEnabled[2]")
          
          nTop + 23
          \lblRS232OutEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblRS232OutEnabled"),#PB_Text_Right,"lblRS232OutEnabled")
          \optRS232OutEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optRS232OutEnabled[0]")
          \optRS232OutEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optRS232OutEnabled[1]")
          \optRS232OutEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optRS232OutEnabled[2]")
          
          nTop + 23
          \lblDMXOutEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblDMXOutEnabled"),#PB_Text_Right,"lblDMXOutEnabled")
          \optDMXOutEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optDMXOutEnabled[0]")
          \optDMXOutEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optDMXOutEnabled[1]")
          \optDMXOutEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optDMXOutEnabled[2]")
          
          nTop + 23
          \lblNetworkOutEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblNetworkOutEnabled"),#PB_Text_Right,"lblNetworkOutEnabled")
          \optNetworkOutEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optNetworkOutEnabled[0]")
          \optNetworkOutEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optNetworkOutEnabled[1]")
          \optNetworkOutEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optNetworkOutEnabled[2]")
          
          nTop + 50
          \lblCueCtrlDevices=scsTextGadget(48,nTop,nTabWidth-52,17,Lang("WOP","lblCueCtrlDevices"),0,"lblCueCtrlDevices")
          scsSetGadgetFont(\lblCueCtrlDevices, #SCS_FONT_GEN_BOLD)
          
          nTop + 20
          \lblMidiInEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblMidiInEnabled"),#PB_Text_Right,"lblMidiInEnabled")
          \optMidiInEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optMidiInEnabled[0]")
          \optMidiInEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optMidiInEnabled[1]")
          \optMidiInEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optMidiInEnabled[2]")
          
          nTop + 23
          \lblRS232InEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblRS232InEnabled"),#PB_Text_Right,"lblRS232InEnabled")
          \optRS232InEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optRS232InEnabled[0]")
          \optRS232InEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optRS232InEnabled[1]")
          \optRS232InEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optRS232InEnabled[2]")
          
          nTop + 23
          \lblDMXInEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblDMXInEnabled"),#PB_Text_Right,"lblDMXInEnabled")
          \optDMXInEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optDMXInEnabled[0]")
          \optDMXInEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optDMXInEnabled[1]")
          \optDMXInEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optDMXInEnabled[2]")
          
          nTop + 23
          \lblNetworkInEnabled=scsTextGadget(8,nTop+4,160,15,Lang("WOP","lblNetworkInEnabled"),#PB_Text_Right,"lblNetworkInEnabled")
          \optNetworkInEnabled[0]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optEnabled"),"optNetworkInEnabled[0]")
          \optNetworkInEnabled[1]=scsOptionGadget(gnNextX+16,nTop,75,21,Lang("WOP","optDisabled"),"optNetworkInEnabled[1]")
          \optNetworkInEnabled[2]=scsOptionGadget(gnNextX+16,nTop,240,21,Lang("WOP","optNotReqd"),"optNetworkInEnabled[2]")
          
          nTop + 50
          \lblSessionInfo=scsTextGadget(48,nTop,nTabWidth-96,45,Lang("WOP","lblSessionInfoA"),0,"lblSessionInfo")
          scsSetGadgetFont(\lblSessionInfo, #SCS_FONT_GEN_ITALIC)
          
        scsCloseGadgetList()
        setVisible(\cntSession,#False)
        ;}
      scsCloseGadgetList() ; tbsOptions
      
      SetGadgetItemState(\tvwPrefTree,0,#PB_Tree_Expanded)
      SetGadgetItemState(\tvwPrefTree,1,#PB_Tree_Selected)
      
      nTop = GadgetY(\cntOptions) + GadgetHeight(\cntOptions) + 4
      \btnOK=scsButtonGadget(283,nTop,73,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      scsToolTip(\btnOK,Lang("WOP","btnOKTT"))
      \btnCancel=scsButtonGadget(gnNextX+7,nTop,73,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      scsToolTip(\btnCancel,Lang("WOP","btnCancelTT"))
      \btnApply=scsButtonGadget(gnNextX+7,nTop,73,gnBtnHeight,grText\sTextBtnApply,0,"btnApply")
      scsToolTip(\btnApply,Lang("WOP","btnApplyTT"))
      CompilerIf #c_new_button
        \btnHelp=scsButtonGadget2(gnNextX+7,nTop,73,gnBtnHeight,grText\sTextBtnHelp,0,#SCS_OGF_BUTTON_ROUNDED,"btnHelp")
      CompilerElse
        \btnHelp=scsButtonGadget(gnNextX+7,nTop,73,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
        scsToolTip(\btnHelp,Lang("WOP","btnHelpTT"))
      CompilerEndIf
      
    EndWith
    setWindowEnabled(#WOP,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWPF ; fmCollectFiles
  btnCancel.i
  btnCollect.i
  btnShowExclusions.i
  chkCopyColorFile.i
  chkExclPlaylists.i
  chkInclDevMaps.i
  chkOverwriteFiles.i
  btnBrowse.i
  btnHelp.i
  cntBelowSpaceReqd.i
  cntSwitch.i
  cvsProgress.i
  cvsSpaceReqd.i
  frSwitch.i
  lblCollect.i
  lblInfo1.i
  lblInfo2.i
  lblProdFolder.i
  lblSpaceReqd.i
  lblStatus.i
  optSwitch.i[2]
  txtProdFolder.i
EndStructure
Global WPF.strWPF ; fmCollectFiles

Procedure createfmCollectFiles()
  PROCNAMEC()
  Protected nLeft, nTop
  Protected nLblLeft, nLblWidth, nTxtLeft
  Protected nBtnWidth, nWideBtnWidth
  Protected nInfoWidth
  Protected nCheckBoxLeft, nCheckBoxWidth
  Protected nOptionLeft, nOptionWidth
  Protected nCntLeft, nCntWidth, nCntHeight
  Protected sText.s
  Protected nSpaceReqdLeft, nSpaceReqdWidth
  Protected nGap
  Protected nReqdCanvasHeight, nReqdWindowHeight
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WPF, 0, 0, 600, 395, Lang("WPF","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WPF, "WPF(fmCollectFiles)")
    With WPF
      nSpaceReqdLeft = 40
      nSpaceReqdWidth = 480
      nLblLeft = 0
      nTxtLeft = 120
      nLblWidth = nTxtLeft - nLblLeft - gnGap
      nCheckBoxLeft = nTxtLeft
      nCheckBoxWidth = 200
      nCntLeft = nSpaceReqdLeft
      nCntWidth = WindowWidth(#WPF) - nCntLeft - 40
      nOptionLeft = 12
      nOptionWidth = nCntWidth - nOptionLeft - 12
      
      nLeft = 40
      nTop = 11
      nInfoWidth = WindowWidth(#WPF) - (nLeft * 2)
      \lblCollect=scsTextGadget(nLeft,nTop,505,17,GetWindowTitle(#WPF),0,"lblCollect")
      scsSetGadgetFont(\lblCollect, #SCS_FONT_GEN_BOLD10)
      nTop + 20
      \lblInfo1=scsTextGadget(nLeft,nTop,nInfoWidth,44,Lang("WPF","lblInfo1"),0,"lblInfo1")
      nTop + 50
      \lblProdFolder=scsTextGadget(nLblLeft,nTop+3,nLblWidth,20,Lang("WPF","lblProdFolder"), #PB_Text_Right,"lblProdFolder")
      \txtProdFolder=scsStringGadget(nTxtLeft,nTop,360,21,"",#PB_String_ReadOnly,"txtProdFolder")
      \btnBrowse=scsButtonGadget(gnNextX,nTop,67,21,LangEllipsis("Btns","Browse"),0,"btnBrowse")
      setGadgetWidth(\btnBrowse)
      scsToolTip(\btnBrowse,Lang("WPF","btnBrowseTT"))
      nTop + 25
      ; \chkOverwriteFiles=scsCheckBoxGadget(nCheckBoxLeft,nTop,nCheckBoxWidth,17,Lang("WPF","chkOverwriteFiles"),0,"chkOverwriteFiles")
      ; nTop + 17
      \chkCopyColorFile=scsCheckBoxGadget(nCheckBoxLeft,nTop,nCheckBoxWidth,17,Lang("WPF","chkCopyColorFile"),0,"chkCopyColorFile")
      nTop + 17
      \chkExclPlaylists=scsCheckBoxGadget(nCheckBoxLeft,nTop,nCheckBoxWidth,17,Lang("WPF","chkExclPlaylists"),0,"chkExclPlaylists")
      nTop + 17
      \chkInclDevMaps=scsCheckBoxGadget(nCheckBoxLeft,nTop,nCheckBoxWidth,17,Lang("WPF","chkInclDevMaps"),0,"chkInclDevMaps")
      scsToolTip(\chkInclDevMaps, Lang("WPF", "chkInclDevMapsTT"))
      nTop + 23
      \lblSpaceReqd=scsTextGadget(nSpaceReqdLeft+8,nTop,nSpaceReqdWidth,17,Lang("WPF","lblSpaceReqd"),0,"lblSpaceReqd")
      scsSetGadgetFont(\lblSpaceReqd, #SCS_FONT_GEN_BOLD)
      nTop + GadgetHeight(\lblSpaceReqd)
      \cvsSpaceReqd=scsCanvasGadget(nSpaceReqdLeft,nTop,nSpaceReqdWidth,164,#PB_Canvas_Border,"cvsSpaceReqd")
      nTop + GadgetHeight(\cvsSpaceReqd) + 6
      
      \cntBelowSpaceReqd=scsContainerGadget(0,nTop,WindowWidth(#WPF),WindowHeight(#WPF)-nTop,#PB_Container_BorderLess,"cntBelowSpaceReqd")
        nTop = 0
        
        nCntHeight = 82
        \cntSwitch=scsContainerGadget(nCntLeft,nTop,nCntWidth,nCntHeight,#PB_Container_BorderLess,"cntSwitch")
          \frSwitch=scsFrameGadget(0,0,nCntWidth,nCntHeight,Lang("WPF","frSwitch"),0,"frSwitch")
          scsSetGadgetFont(\frSwitch,#SCS_FONT_GEN_BOLD)
          \optSwitch[0]=scsOptionGadget(nOptionLeft,16,nOptionWidth,30,"","optSwitch[0]")
          SGT(\optSwitch[0], WordWrapW(#WPF, \optSwitch[0], Lang("WPF","optSwitch[0]"), nOptionWidth - 15))
          SetWindowLongPtr_(GadgetID(\optSwitch[0]),#GWL_STYLE,GetWindowLongPtr_(GadgetID(\optSwitch[0]),#GWL_STYLE)|$2000)
          \optSwitch[1]=scsOptionGadget(nOptionLeft,46,nOptionWidth,30,"","optSwitch[1]")
          SGT(\optSwitch[1], WordWrapW(#WPF, \optSwitch[1], Lang("WPF","optSwitch[1]"), nOptionWidth - 15))
          SetWindowLongPtr_(GadgetID(\optSwitch[1]),#GWL_STYLE,GetWindowLongPtr_(GadgetID(\optSwitch[1]),#GWL_STYLE)|$2000)
        scsCloseGadgetList()
        nTop + GadgetHeight(\cntSwitch) + 12
        
        \cvsProgress=scsCanvasGadget(nSpaceReqdLeft,nTop,nSpaceReqdWidth,6,0,"cvsProgress")
        nTop + GadgetHeight(\cvsProgress) + 6
        \lblStatus=scsTextGadget(nSpaceReqdLeft,nTop,nSpaceReqdWidth,15,"",#PB_Text_Center,"lblStatus")
        nTop + GadgetHeight(\lblStatus) + 12
        
        nBtnWidth = 81
        nWideBtnWidth = 121
        nGap = 12
        nLeft = (WindowWidth(#WPF) - (nWideBtnWidth + (nBtnWidth * 3) + (nGap * 3))) >> 1
        \btnShowExclusions=scsButtonGadget(nLeft,nTop,nWideBtnWidth,gnBtnHeight,"* "+Lang("WPF","btnShowExclusions"),0,"btnShowExclusions")
        \btnCollect=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,Lang("WPF","btnCollect"),#PB_Button_Default,"btnCollect")
        \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
        \btnHelp=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
        nReqdCanvasHeight = GadgetY(\btnCollect) + GadgetHeight(\btnCollect) + 12
        ResizeGadget(\cntBelowSpaceReqd,#PB_Ignore,#PB_Ignore,#PB_Ignore,nReqdCanvasHeight)
      scsCloseGadgetList()  ; close \cntBelowSpaceReqd
      nReqdWindowHeight = GadgetY(\cntBelowSpaceReqd) + GadgetHeight(\cntBelowSpaceReqd)
      ResizeWindow(#WPF,#PB_Ignore,#PB_Ignore,#PB_Ignore,nReqdWindowHeight)
    EndWith
    
    AddKeyboardShortcut(#WPF, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
    AddKeyboardShortcut(#WPF, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    
    ; setWindowVisible(#WPF,#True)
    setWindowEnabled(#WPF,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWPR ; fmPrintCueList
  cdlPrint.i
  chkA.i
  chkE.i
  chkF.i
  chkG.i
  chkI.i
  chkJ.i
  chkK.i
  chkL.i
  chkM.i
  chkN.i
  chkP.i
  chkQ.i
  chkR.i
  chkS.i
  chkT.i
  chkU.i
  chkIncludeHotkeys.i
  chkIncludeSubCues.i
  chkManualCuesOnly.i ; Added 20Apr2022 11.9.1bd following email request from Gérard Schiphorst
  btnClose.i
  btnCopy.i
  btnHelp.i
  btnPrint.i
  btnSelectAll.i
  btnClearAll.i
  cntCueSel.i
  frCueSel.i
  grdCuePrint.i
  lblCueLengthsTotal.i
  lblCueListTitle.i
  mnuColAC.i
  mnuColCT.i
  mnuColCU.i
  mnuColDU.i
  mnuColDe.i
  mnuColDefaults.i
  mnuColFN.i
  mnuColFT.i
  mnuColMC.i
  mnuColRevert.i
  mnuCols.i
  mnuColSD.i
  mnuColSep1.i
  mnuColWR.i
  mnuFile.i
  mnuFileClose.i
  mnuFilePrint.i
  mnuFileSep1.i
  txtCueListTitle.i
EndStructure
Global WPR.strWPR ; fmPrintCueList

Procedure createfmPrintCueList(nParentWindow)
  PROCNAMEC()
  Protected nBackColor = RGB(218,220,241)
  Protected nParentID
  Protected nLeft, nTop, nWidth, nHeight, nGap
  
  debugMsg(sProcName, #SCS_START + ", nParentWindow=" + nParentWindow)
  If IsWindow(nParentWindow)
    debugMsg(sProcName, "IsWindow(" + nParentWindow + ") returned #True")
    nParentID = WindowID(nParentWindow)
    debugMsg(sProcName, "nParentID=" + nParentID)
  Else
    debugMsg(sProcName, "IsWindow(" + nParentWindow + ") returned #False")
  EndIf
  
  If IsWindow(#WPR)
    If gaWindowProps(#WPR)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WPR)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WPR, 0, 0, 750, 500, Lang("WPR","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WPR, "WPR(fmPrintCueList)", nParentWindow)
    SetWindowColor(#WPR, nBackColor)
    debugMsg(sProcName, "WindowHeight(#WPR)=" + WindowHeight(#WPR))
    
    WPR_buildWindowMenu()
    
    With WPR
      \lblCueListTitle=scsTextGadget(8,7,123,17,Lang("WPR","lblCueListTitle"), #PB_Text_Right,"lblCueListTitle")
      scsSetGadgetFont(\lblCueListTitle, #SCS_FONT_GEN_BOLD)
      SetGadgetColor(\lblCueListTitle, #PB_Gadget_BackColor, nBackColor)
      \txtCueListTitle=scsStringGadget(136,4,413,21,"",0,"txtCueListTitle")
      \cntCueSel=scsContainerGadget(10,30,730,106,0,"cntCueSel")
        \frCueSel=scsFrameGadget(0,0,728,106,Lang("WPR","frCueSel"),0,"frCueSel")
        nLeft = 4
        nTop = 18
        nWidth = 114
        nHeight = 17
        ; nb place checkboxes with longest descriptions (\chkS, \chkJ and \chkU) at the end of each line
        \chkF=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, grText\sTextCueTypeF,0,"chkF")
        \chkA=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeA,0,"chkA")
        \chkI=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeI,0,"chkI")
        \chkK=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeK,0,"chkK")
        \chkL=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeL,0,"chkL")
        \chkS=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeS,0,"chkS")
        setGadgetWidth(\chkS)
        nTop + 18
        \chkP=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, grText\sTextCueTypeP,0,"chkP")
        \chkM=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeM,0,"chkM")
        \chkN=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeN,0,"chkN")
        \chkE=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeE,0,"chkE")
        \chkJ=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeJ,0,"chkJ")
        setGadgetWidth(\chkJ)
        nTop + 18
        \chkG=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, grText\sTextCueTypeG,0,"chkG")
        \chkT=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeT,0,"chkT")
        \chkQ=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeQ,0,"chkQ")
        \chkR=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeR,0,"chkR")
        \chkU=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,grText\sTextCueTypeU,0,"chkU")
        setGadgetWidth(\chkU)
        nTop + 27
        nWidth = 135
        nLeft = (GadgetWidth(\cntCueSel) - ((nWidth * 3) + (162 + gnGap)))
        nLeft >> 1
        \chkIncludeHotkeys=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, Lang("WPR","chkIncludeHotkeys"),0,"chkIncludeHotkeys")
        \chkIncludeSubCues=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,Lang("WPR","chkIncludeSubCues"),0,"chkIncludeSubCues")
        \chkManualCuesOnly=scsCheckBoxGadget(gnNextX,nTop,nWidth,nHeight,Lang("WPR","chkManualCuesOnly"),0,"chkManualCuesOnly")
        \btnSelectAll=scsButtonGadget(gnNextX,nTop-3,81,gnBtnHeight,Lang("Btns","SelectAll"),0,"btnSelectAll")
        \btnClearAll=scsButtonGadget(gnNextX+gnGap,nTop-3,81,gnBtnHeight,Lang("Btns","ClearAll"),0,"btnClearAll")
      scsCloseGadgetList()
      
      nLeft = GadgetX(\cntCueSel)
      nTop = GadgetY(\cntCueSel) + GadgetHeight(\cntCueSel)
      nWidth = GadgetWidth(\cntCueSel)
      nHeight = WindowHeight(#WPR) - nTop - 58 - 20
      \grdCuePrint=scsListIconGadget(nLeft, nTop, nWidth, nHeight, "",16,#PB_ListIcon_FullRowSelect|#PB_ListIcon_GridLines|#PB_ListIcon_HeaderDragDrop, "grdCuePrint")
      RemoveGadgetColumn(\grdCuePrint, 0) ; remove column added by create function
      ; sColTypes in the following call MUST be same order as and count of Enumeration #SCS_GRDCUEPRINT_xx - comment obsolete as at 11.3.0
      ; (NB the order does NOT have to be the same as the default display order)
      registerGrid(@grGrdCuePrintInfo, \grdCuePrint, #SCS_GT_GRDCUEPRINT, "CU,DE,CT,AC,FN,DU,SD,WR,MC,FT,PG,LV")
      
      nTop = WindowHeight(#WPR) - 70
      nWidth = 140
      nLeft = WindowWidth(#WPR) - nWidth - 40
      \lblCueLengthsTotal=scsTextGadget(nLeft,nTop,nWidth,15,"",0,"lblCueLengthsTotal")
      nWidth = calcTextWidth(#WPR, \lblCueLengthsTotal, "  " + Lang("WPR","lblCueLengthsTotal") + " 12:12:12 ")
      nLeft = WindowWidth(#WPR) - nWidth - 40
      If nLeft > 0
        ResizeGadget(\lblCueLengthsTotal,nLeft,#PB_Ignore,nWidth,#PB_Ignore)
      EndIf
      nGap = 11
      nLeft = (WindowWidth(#WPR) - (166 + (73 * 3) + (nGap * 3)))
      nLeft >> 1
      nTop = WindowHeight(#WPR) - 50
      \btnCopy=scsButtonGadget(nLeft,nTop,166,gnBtnHeight,Lang("WPR","btnCopy"),0,"btnCopy")
      scsToolTip(\btnCopy,Lang("WPR","btnCopyTT"))
      \btnPrint=scsButtonGadget(gnNextX+nGap,nTop,73,gnBtnHeight,Lang("WPR","btnPrint"),#PB_Button_Default,"btnPrint")
      \btnClose=scsButtonGadget(gnNextX+nGap,nTop,73,gnBtnHeight,Lang("Btns","Close"),0,"btnClose")
      \btnHelp=scsButtonGadget(gnNextX+nGap,nTop,73,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      AddKeyboardShortcut(#WPR, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WPR, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    ; setWindowVisible(#WPR,#True)
    setWindowEnabled(#WPR,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure tyWPTCue
  cboProdTimerAction.i
  lnSeparator.i
  nCuePtr.i
  txtCue.i
  txtDescr.i
EndStructure
Global Dim aWPTCue.tyWPTCue(0)

Structure strWPT ; fmProdTimer
  btnHelp.i
  chkSaveProdTimerHistory.i
  chkTimeStampProdTimerHistoryFiles.i
  btnApply.i
  btnCancel.i
  btnOK.i
  cntHistFile.i
  lblProdTimer.i
  lblHistFileName.i
  lblHistFileName2.i
  scaCueList.i
  ;
  nCountEnabledCues.i
EndStructure
Global WPT.strWPT ; fmProdTimer

Procedure createfmProdTimer(nParentWindow)
  PROCNAMEC()
  Protected i, n
  Protected nWindowWidth
  Protected nHistContainerWidth
  Protected nLeft, nTop, nWidth, nHeight
  Protected sNr.s
  Protected nLineHeight
  Protected nSCAWidth, nSCAHeight
  Protected nContentWidth, nContentHeight
  Protected nGadgetPropsIndex
  Protected nReqdWidth1, nReqdWidth2, nGapSize, nTotalReqdWidth
  
  If IsWindow(#WPT)
    ; force recreate window so that aWPTCue() is redimensioned (and populated)
    scsCloseWindow(#WPT)
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WPT, 0, 0, 534, 532, Lang("WPT","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WPT, "WPT(fmProdTimer)", nParentWindow)
    nWindowWidth = WindowWidth(#WPT)
    With WPT
      \lblProdTimer=scsTextGadget(15,8,172,16,Lang("WPT","lblProdTimer"),0,"lblProdTimer")
      
      \nCountEnabledCues = 0
      For i = 1 To gnLastCue
        If aCue(i)\bCueEnabled
          \nCountEnabledCues + 1
        EndIf
      Next i
      ReDim aWPTCue(\nCountEnabledCues)
      
      nLineHeight = 22
      nContentWidth = 474 + gl3DBorderAllowanceX + gl3DBorderAllowanceX
      nContentHeight = \nCountEnabledCues * nLineHeight
      nSCAWidth = nContentWidth + glScrollBarWidth + gl3DBorderAllowanceX ; + gl3DBorderAllowanceX
      nSCAHeight = (nLineHeight * 18) + gl3DBorderAllowanceY
      
      \scaCueList=scsScrollAreaGadget(15,27,nSCAWidth,nSCAHeight,nContentWidth,nContentHeight,nLineHeight,0,"scaCueList")
        nWidth = GetGadgetAttribute(\scaCueList, #PB_ScrollArea_InnerWidth)
        For n = 1 To \nCountEnabledCues
          sNr = "[" + n + "]"
          nTop = (n-1) * nLineHeight
          aWPTCue(n)\txtCue=scsTextGadget(4,nTop+gnLblVOffsetS,50,15,"",0,"txtCue" + sNr)
          aWPTCue(n)\txtDescr=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,200,15,"",0,"txtDescr" + sNr)
          aWPTCue(n)\cboProdTimerAction=scsComboBoxGadget(gnNextX+gnGap,nTop,220,21,0,"cboProdTimer" + sNr)
          ; now set nGadgetNoForEvHdlr manually because procedure newGadget() doesn't handle arrays like aWPTCue()
          nGadgetPropsIndex = getGadgetPropsIndex(aWPTCue(n)\cboProdTimerAction)
          gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr = aWPTCue(0)\cboProdTimerAction
          aWPTCue(n)\lnSeparator=scsLineGadget(0,nTop+nLineHeight-1,nWidth,1,#SCS_Light_Grey,0,"lnSeparator" + sNr)
        Next n
      scsCloseGadgetList()
      
      ; reposition \lblProdTimer over \cboProdTimer
      If \nCountEnabledCues >= 1
        nLeft = GadgetX(\scaCueList) + GadgetX(aWPTCue(1)\cboProdTimerAction) + gl3DBorderAllowanceX + 2
        ResizeGadget(\lblProdTimer, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
      
      nTop = GadgetY(\scaCueList) + GadgetHeight(\scaCueList) + 8
      nLeft = GadgetX(\scaCueList)
      nHistContainerWidth = GadgetWidth(\scaCueList)
      nHeight = 60
      \cntHistFile=scsContainerGadget(nLeft,nTop,nHistContainerWidth,nHeight,#PB_Container_Single,"cntHistFile")
        nTop = 4
        nWidth = 150
        nLeft = (nHistContainerWidth - nWidth - nWidth) >> 1
        nHeight = 17
        \chkSaveProdTimerHistory=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, Lang("WPT","chkSavePTHist"),0,"chkSaveProdTimerHistory")
        scsToolTip(\chkSaveProdTimerHistory, Lang("WPT","chkSavePTHistTT"))
        nLeft + nWidth
        \chkTimeStampProdTimerHistoryFiles=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, Lang("WPT","chkTimeStampPTHist"),0,"chkTimeStampProdTimerHistoryFiles")
        nReqdWidth1 = GadgetWidth(\chkSaveProdTimerHistory, #PB_Gadget_RequiredSize)
        nReqdWidth2 = GadgetWidth(\chkTimeStampProdTimerHistoryFiles, #PB_Gadget_RequiredSize)
        nGapSize = 12
        nTotalReqdWidth = nReqdWidth1 + nGapSize + nReqdWidth2
        If nHistContainerWidth > nTotalReqdWidth
          nLeft = (nHistContainerWidth - nTotalReqdWidth) >> 1
        Else
          nLeft = 0
        EndIf
        ResizeGadget(\chkSaveProdTimerHistory,nLeft,#PB_Ignore,nReqdWidth1,#PB_Ignore)
        nLeft + nReqdWidth1 + nGapSize
        ResizeGadget(\chkTimeStampProdTimerHistoryFiles,nLeft,#PB_Ignore,nReqdWidth2,#PB_Ignore)
        
        nTop + 20
        nLeft = 12
        nWidth = nHistContainerWidth - nLeft - nLeft
        \lblHistFileName=scsTextGadget(nLeft,nTop,nWidth,15,"",#PB_Text_Center,"lblHistFileName")
        nTop + 15
        \lblHistFileName2=scsTextGadget(nLeft,nTop,nWidth,15,"",#PB_Text_Center,"lblHistFileName2")
      scsCloseGadgetList()
            
      nTop = GadgetY(\cntHistFile) + GadgetHeight(\cntHistFile) + 8
      nWidth = 73
      nLeft = (WindowWidth(#WPT) - (nWidth * 4) - (8 * 3))
      nLeft >> 1
      \btnOK=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+8,nTop,nWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnApply=scsButtonGadget(gnNextX+8,nTop,nWidth,gnBtnHeight,grText\sTextBtnApply,0,"btnApply")
      \btnHelp=scsButtonGadget(gnNextX+8,nTop,nWidth,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
      AddKeyboardShortcut(#WPT, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    ; setWindowVisible(#WPT,#True)
    setWindowEnabled(#WPT,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWQA ; fmEditQA
  SUBCUE_HEADER_FIELDS()
  btnBrowse.i
  btnEditExternally.i
  btnFadeOut.i
  btnFirst.i
  btnLast.i
  btnNext.i
  btnPause.i
  btnPlay.i
  btnPrev.i
  btnRename.i
  btnScreens.i
  btnStop.i
  btnSubCenter.i
  cboAspectRatioType.i
  ; cboOther - see mbgOther, ie 'menu button gadget Other'
  cboQATransType.i
  ; cboRotate - see mbgRotate, ie 'menu button gadget Rotate'
  cboSubTrim.i
  cboVidAudLogicalDev.i
  cboVidCapLogicalDev.i ; Selected Video Capture Device
  cboVideoSource.i ; Video Capture
  chkContinuous.i
  chkLogo.i
  chkOverlay.i
  chkPLRepeat.i
  chkPauseAtEnd.i
  chkPreviewOnOutputScreen.i
  chkShowFileFolders.i
  cntAudio.i
  cntForCaptureFrame.i
  cntGraphDisplayQA.i
  cntGraphQA.i
  cntHighlightFileName.i
  cntImageAndCaptureFields.i
  cntImageOnlyFields.i
  cntMoveAddDeleteRename.i
  cntPreview.i
  cntRHS.i
  cntSelectedItem.i
  cntSubDetailA.i
  cntTest.i
  cntTransition.i
  cntVideoFields.i
  cntXPosAndAspect.i
  cntYPosAndSize.i
  cvsCapture.i      ; Capture container for preview
  cvsDummy.i        ; an alternative to txtDummy as cvsDummy can check keyboard actions for left and right arrows (for changing highlighted item)
  cvsGraphQA.i
  cvsPreview.i
  cvsSideLabelsQA.i
  imgBlankItem.i
  imgButtonTBS.i[4]
  imgCaptureLogo.i  ; The default display image for video capture
  imgPreview.i
  imgPreviewBlack.i
  imgPreviewBlank.i
  imgPreviewBlended.i
  lblAspectRatioType.i
  lblDisplayTime.i
  lblEndAt.i
  lblFadeInTime.i
  lblFadeOutTime.i
  lblLength.i
  lblPlayLength.i
  ; lblPnlHdg.i
  lblRelLevel.i
  lblRotateInfo.i
  lblScreens.i
  lblSelectedItem.i
  lblSize.i
  lblSoundDevice.i
  lblStartAt.i
  lblSubDb.i
  lblSubLevel.i
  lblSubPan.i
  lblSubTrim.i
  lblTotalTime.i
  lblTransTime.i
  lblTransType.i
  lblVidCapLogicalDev.i
  lblXPos.i
  lblYPos.i
  lnDropMarker.i
  lnHighlight.i
  lnSelectedItem.i[4]
  mbgOther.i
  mbgRotate.i
  scaSlideShow.i
  scaTimeLine.i
  sldAspectRatioHVal.i
  sldProgress.i[2]
  sldRelLevel.i
  sldSize.i
  sldSubLevel.i
  sldSubPan.i
  sldXPos.i
  sldYPos.i
  txtDisplayTime.i
  txtEndAt.i
  txtFadeInTime.i
  txtFadeOutTime.i
  txtFileName.i
  txtFileTypeExt.i
  txtPlayLength.i
  txtQATransTime.i
  txtScreens.i
  txtSize.i
  txtStartAt.i
  txtSubDBLevel.i
  txtSubPan.i
  txtTotalTime.i
  txtXPos.i
  txtYPos.i
EndStructure

; This is effectively a Timeline Entry - - related to window drawing
Structure strWQAFile
  bSelected.i
  bTimelineUpdateReqd.i
  cntFile.i
  cntImage.i
  cntPicSize.i
  cvsTimeLineImage.i
  lblFileName.i
  lblDuration.i
  nFileAudPtr.i
  nFileId.i
  nFileNameLen.i
EndStructure

Global WQA.strWQA ; fmEditQA
Global Dim WQAFile.strWQAFile(0)
Global gnWQACurrItem
Global gnWQALastItem

Procedure createWQAFile()
  ; creates a new 'file' entry in the timeline, after the currently selected element
  PROCNAMEC()
  Protected nLeft, sFileId.s
  Protected nReqdInnerWidth
  Protected n
  Protected nTop
  Protected nBackColorQA, nTextColorQA
  
  ; debugMsg(sProcName, #SCS_START)
  
  nBackColorQA = grColorScheme\aItem[#SCS_COL_ITEM_QA]\nBackColor
  nTextColorQA = grColorScheme\aItem[#SCS_COL_ITEM_QA]\nTextColor
  
  gnWQACurrItem + 1
  gnWQALastItem + 1
  If gnWQALastItem > ArraySize(WQAFile())
    ReDim WQAFile(gnWQALastItem + 20)
  EndIf
  For n = (gnWQALastItem-1) To gnWQACurrItem Step -1
    WQAFile(n+1) = WQAFile(n)
    WQAFile(n+1)\bTimelineUpdateReqd = #True
  Next n
  
  gnCurrentEditorComponent = #WQA
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  scsOpenGadgetList(WQA\scaTimeLine)
    
    With WQAFile(gnWQACurrItem)
      \nFileAudPtr = -1
      ; debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + \nFileAudPtr)
      \nFileNameLen = 0
      \bSelected = #False
      nLeft = (gnWQACurrItem * #SCS_QAITEM_WIDTH)
      \nFileId = rWQA\nFileId    ; unique id for this entry
      sFileId = "[" + \nFileId + "]"
      \cntFile=scsContainerGadget(nLeft,0,#SCS_QAITEM_WIDTH,#SCS_QAITEM_HEIGHT,0,"cntFile"+sFileId, #SCS_G4EH_QA_CNTFILE)
        SetGadgetColor(\cntFile, #PB_Gadget_BackColor, nBackColorQA)
        
        nTop = 0
        \cntImage=scsContainerGadget(3,nTop,#SCS_QATIMELINE_IMAGE_WIDTH+6,#SCS_QATIMELINE_IMAGE_HEIGHT+4,0,"cntImage"+sFileId, #SCS_G4EH_QA_CNTIMAGE)
          SetGadgetColor(\cntImage, #PB_Gadget_BackColor, nBackColorQA)
          \cntPicSize=scsContainerGadget(3,2,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT,0,"cntPicSize"+sFileId, #SCS_G4EH_QA_CNTPICSIZE)
            \cvsTimeLineImage=scsCanvasGadget(0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT,0,"cvsTimeLineImage"+sFileId, #SCS_G4EH_QA_PICIMAGE)
            If StartDrawing(CanvasOutput(\cvsTimeLineImage))
              DrawImage(ImageID(WQA\imgBlankItem),0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT)
              StopDrawing()
            EndIf
            ; nb \cvsTimeLineImage initialised with the own-drawn 'blank item' image, WQA\imgBlankItem
          scsCloseGadgetList()
        scsCloseGadgetList()
        
        nTop + GadgetHeight(\cntImage)
        \lblFileName=scsTextGadget(5,nTop,#SCS_QAITEM_WIDTH,15,"",0,"lblFileName"+sFileId)
        SetGadgetColor(\lblFileName, #PB_Gadget_BackColor, nBackColorQA)
        SetGadgetColor(\lblFileName, #PB_Gadget_FrontColor, nTextColorQA)
        
        nTop + GadgetHeight(\lblFileName)
        \lblDuration=scsTextGadget(5,nTop,#SCS_QAITEM_WIDTH,15,"",0,"lblDuration"+sFileId)
        SetGadgetColor(\lblDuration, #PB_Gadget_BackColor, nBackColorQA)
        SetGadgetColor(\lblDuration, #PB_Gadget_FrontColor, nTextColorQA)
        
      scsCloseGadgetList()
      rWQA\nFileId + 1
    EndWith
    
    ; the following code also exists in WQA_adjustForSplitterSize(), so make any changes in both places
    nReqdInnerWidth = (gnWQALastItem + 1) * #SCS_QAITEM_WIDTH
    If nReqdInnerWidth < (GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX)
      nReqdInnerWidth = GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX
    EndIf
    SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_InnerWidth, nReqdInnerWidth)
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure insertWQAFile(bInsertAfterCurrentEntry=#False)
  ; inserts a blank 'file' entry in the timeline immediately before (or after) the current entry
  ; returns the listindex of new row
  PROCNAMEC()
  Protected nListIndex, nLeft
  
  If bInsertAfterCurrentEntry = #False
    gnWQACurrItem - 1
  EndIf
  debugMsg(sProcName, "calling createWQAFile()")
  createWQAFile()   ; adds blank entry after the current entry
  
  For nListIndex = 0 To gnWQALastItem
    nLeft = nListIndex * #SCS_QAITEM_WIDTH
    If IsGadget(WQAFile(nListIndex)\cntFile)
      ResizeGadget(WQAFile(nListIndex)\cntFile, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
  Next nListIndex
  
  ProcedureReturn gnWQACurrItem
  
EndProcedure

Procedure removeWQAFile()
  ; removes the currently selected 'file' entry in the timeline
  ; returns listindex of now-selected item
  PROCNAMEC()
  Protected nListIndex, nLeft
  Protected nReqdInnerWidth
  Protected n
  
  If gnWQACurrItem < 0
    ProcedureReturn gnWQACurrItem
  EndIf
  
  scsOpenGadgetList(WQA\scaTimeLine)
    
    If IsGadget(WQAFile(gnWQACurrItem)\cntFile)
      scsFreeGadget(WQAFile(gnWQACurrItem)\cntFile)
      debugMsg(sProcName, "scsFreeGadget(G" + WQAFile(gnWQACurrItem)\cntFile + ")")
    EndIf
    For n = (gnWQACurrItem + 1) To gnWQALastItem
      WQAFile(n-1) = WQAFile(n)
      WQAFile(n-1)\bTimelineUpdateReqd = #True
    Next n
    gnWQALastItem - 1
    If gnWQACurrItem > gnWQALastItem
      gnWQACurrItem = gnWQALastItem
    EndIf
    
    For nListIndex = gnWQACurrItem To gnWQALastItem
      nLeft = nListIndex * #SCS_QAITEM_WIDTH
      If IsGadget(WQAFile(nListIndex)\cntFile)
        ResizeGadget(WQAFile(nListIndex)\cntFile, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
    Next nListIndex
    
    nReqdInnerWidth = (gnWQALastItem + 1) * #SCS_QAITEM_WIDTH
    If nReqdInnerWidth < (GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX)
      nReqdInnerWidth = GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX
    EndIf
    SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_InnerWidth, nReqdInnerWidth)
    
  scsCloseGadgetList()
  
  ProcedureReturn gnWQACurrItem
  
EndProcedure

Procedure createfmEditQA()
  PROCNAMEC()
  Protected nLeft, nTop, nHeight, nWidth, nInnerWidth, nWidth2, nLeft2
  Protected nSldLeft, nSldWidth
  Protected nExtEditBtnWidth, nExtEditBtnLeft
  Protected nReqdWidth, nReqdHeight, nPosAndSizeWidth
  Protected nSpecialQAHeight, nSpecialQAInnerHeight
  Protected nWQAInnerHeight
  Protected nMainHeight
  Protected nBackColorQA, nTextColorQA
  
  debugMsg(sProcName, #SCS_START)
  
  nBackColorQA = grColorScheme\aItem[#SCS_COL_ITEM_QA]\nBackColor
  nTextColorQA = grColorScheme\aItem[#SCS_COL_ITEM_QA]\nTextColor
  
  nSpecialQAInnerHeight = #SCS_QAITEM_HEIGHT
  nSpecialQAHeight = nSpecialQAInnerHeight + glScrollBarHeight + 2
  nMainHeight = WindowHeight(#WED) - GadgetY(WED\cntRight) - nSpecialQAHeight
  ResizeGadget(WED\cntLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore,nMainHeight)
  ; debugMsg(sProcName, "ResizeGadget(WED\cntLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore," + nMainHeight + ")")
  ResizeGadget(WED\cntRight,#PB_Ignore,#PB_Ignore,#PB_Ignore,nMainHeight)
  ; debugMsg(sProcName, "ResizeGadget(WED\cntRight,#PB_Ignore,#PB_Ignore,#PB_Ignore," + nMainHeight + ")")
  nTop = WindowHeight(#WED) - nSpecialQAInnerHeight
  ResizeGadget(WED\cntSpecialQA,#PB_Ignore,nTop,#PB_Ignore,nSpecialQAHeight)
  SetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerWidth, GadgetWidth(WED\cntSpecialQA))
  SetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerHeight, GadgetHeight(WED\cntSpecialQA))
  ; debugMsg(sProcName, "GadgetWidth(WED\cntSpecialQA)=" + GadgetWidth(WED\cntSpecialQA) + ", GadgetHeight(WED\cntSpecialQA)=" + GadgetHeight(WED\cntSpecialQA) +
  ;                     ", GetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerHeight)=" + GetGadgetAttribute(WED\cntSpecialQA, #PB_ScrollArea_InnerHeight))
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQA
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQA
      ; create various images for later use
      \imgBlankItem=scsCreateImage(#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT)  ; timeline image
      logCreateImage(30, \imgBlankItem, -1, #SCS_VID_PIC_TARGET_NONE, "blank timeline image", "WQA.TimelineBlank")
      ; now draw the detail of the blank timeline image
      If \imgBlankItem
        If StartDrawing(ImageOutput(\imgBlankItem))
          Box(0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT,nBackColorQA)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT,nTextColorQA)
          StopDrawing()
        EndIf
      EndIf
      
      \imgPreview=scsCreateImage(#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT) ; preview image
      logCreateImage(31, \imgPreview, -1, #SCS_VID_PIC_TARGET_NONE, "WQA\imgPreview - preview image", "WQA.PreviewImage")
      \imgPreviewBlack=scsCreateImage(#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT)  ; black image
      logCreateImage(33, \imgPreviewBlack, -1, #SCS_VID_PIC_TARGET_NONE, "WQA\imgPreviewBlack - black preview image", "WQA.PreviewBlack")
      \imgPreviewBlank=scsCreateImage(#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT)  ; blank image
      logCreateImage(34, \imgPreviewBlank, -1, #SCS_VID_PIC_TARGET_NONE, "WQA\imgPreviewBlank - blank preview image", "WQA.PreviewBlank")
      \imgCaptureLogo=scsCreateImage(#SCS_QAPREVIEW_WIDTH, #SCS_QAPREVIEW_HEIGHT) ; capture logo image  
      logCreateImage(35, \imgCaptureLogo, -1, #SCS_VID_PIC_TARGET_NONE, "WQA\imgCaptureLogo - video capture preview image", "WQA.CaptureLogo")
      ; now draw the detail of the blank preview image
      If \imgPreviewBlank
        If StartDrawing(ImageOutput(\imgPreviewBlank))
          Box(0,0,#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT,nBackColorQA)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(0,0,#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT,nTextColorQA)
          StopDrawing()
        EndIf
      EndIf
      \imgPreviewBlended=scsCreateImage(#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT)  ; blended image
      logCreateImage(36, \imgPreviewBlended, -1, #SCS_VID_PIC_TARGET_NONE, "WQA\imgPreviewBlended - blended preview image", "WQA.PreviewBlended")
      
      ; create hidden container for playing video file for CaptureFrame()
      nLeft = GadgetWidth(WED\cntRight+10)
      \cntForCaptureFrame=scsContainerGadget(nLeft,0,0,0,#PB_Container_BorderLess,"cntForCaptureFrame")
      scsCloseGadgetList()
      setVisible(\cntForCaptureFrame, #False)
      
      nWQAInnerHeight = 485  ; see also WQA_adjustForSplitterSize()
      \scaSlideShow=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, nWQAInnerHeight, 30, #PB_ScrollArea_Flat, "scaSlideShow") ; innerheight was 482
        setVisible(\scaSlideShow, #False)
        \cvsDummy=scsCanvasGadget(-2000,0,75,15,#PB_Canvas_Keyboard,"cvsDummy") ; see comment above against cvsDummy.i
        
        ; header
        SUBCUE_HEADER_CODE(WQA)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader)
        nHeight = nWQAInnerHeight - nTop ; was 482 - nTop
        \cntSubDetailA=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,#PB_Container_BorderLess,"cntSubDetailA")
          
          \lblFadeInTime=scsTextGadget(0,5,120,15,Lang("WQA","lblFadeInTime"),#PB_Text_Right,"lblFadeInTime")
          \txtFadeInTime=scsStringGadget(gnNextX+gnGap,2,40,21,"",0,"txtFadeInTime")
          scsToolTip(\txtFadeInTime,Lang("WQA","txtFadeInTimeTT"))
          setValidChars(\txtFadeInTime, "0123456789.:")
          
          \lblFadeOutTime=scsTextGadget(gnNextX,5,90,15,Lang("WQA","lblFadeOutTime"),#PB_Text_Right,"lblFadeOutTime")
          \txtFadeOutTime=scsStringGadget(gnNextX+gnGap,2,40,21,"",0,"txtFadeOutTime")
          scsToolTip(\txtFadeOutTime,Lang("WQA","txtFadeOutTimeTT"))
          setValidChars(\txtFadeOutTime, "0123456789.:")
          
          \lblTotalTime=scsTextGadget(gnNextX,5,100,15,Lang("WQA","lblTotalTime"),#PB_Text_Right,"lblTotalTime")
          \txtTotalTime=scsStringGadget(gnNextX+gnGap,2,64,21,"",0,"txtTotalTime")
          setEnabled(\txtTotalTime, #False)
          
          \chkPLRepeat=scsCheckBoxGadget2(gnNextX+12,4,92,17,Lang("WQA","chkPLRepeat"),0,"chkPLRepeat")
          scsToolTip(\chkPLRepeat,Lang("WQA","chkPLRepeatTT"))
          nReqdWidth = getGadgetReqdWidth(sProcName,\chkPLRepeat)
          ResizeGadget(\chkPLRepeat,#PB_Ignore,#PB_Ignore,nReqdWidth,#PB_Ignore)
          nLeft = GadgetX(\chkPLRepeat) + GadgetWidth(\chkPLRepeat) + 12
          \chkPauseAtEnd=scsCheckBoxGadget2(nLeft,4,92,17,Lang("WQA","chkPauseAtEnd"),0,"chkPauseAtEnd")
          
          ; screen/audio fields
          \cntAudio=scsContainerGadget(4,25,gnEditorScaPropertiesInnerWidth-2,36,#PB_Container_BorderLess,"cntAudio")
            \btnScreens=scsButtonGadget(2,0,53,21,Lang("WQA","lblOutputScreen"),0,"btnScreens")
            \lblScreens=scsTextGadget(0,21,57,15,"",#PB_Text_Center,"lblScreens")
            \lblSoundDevice=scsTextGadget(63,0,106,15,Lang("WQA","lblSoundDevice"),0,"lblSoundDevice") ; "Audio Device"
            \cboVidAudLogicalDev=scsComboBoxGadget(62,15,113,21,0,"cboVidAudLogicalDev")
            scsToolTip(\cboVidAudLogicalDev,Lang("WQA","cboVidAudLogicalDevTT"))
            \lblSubTrim=scsTextGadget(171,0,39,15,Lang("Common","Trim"), #PB_Text_Center,"lblSubTrim")
            \cboSubTrim=scsComboBoxGadget(177,15,43,21,0,"cboSubTrim")
            \lblSubLevel=scsTextGadget(223,0,126,15,Lang("WQA","lblSubLevel"), #PB_Text_Center,"lblSubLevel")
            \sldSubLevel=SLD_New("QA_Level_1",\cntAudio,0,222,15,129,21,#SCS_ST_HLEVELNODB,0,1000)
            \lblSubDb=scsTextGadget(348,0,35,15,"dB", #PB_Text_Center,"lblSubDb")
            \txtSubDBLevel=scsStringGadget(351,15,52,21,"",0,"txtSubDBLevel")
            \lblSubPan=scsTextGadget(454,0,26,15,Lang("Common","Pan"), #PB_Text_Center,"lblSubPan")
            \sldSubPan=SLD_New("QA_Pan_1",\cntAudio,0,415,15,105,21,#SCS_ST_PAN,0,1000)
            \btnSubCenter=scsButtonGadget(522,15,46,21,Lang("Btns","Center"),0,"btnSubCenter")
            scsToolTip(\btnSubCenter,Lang("Btns","CenterTT"))
            \txtSubPan=scsStringGadget(573,15,52,21,"",#PB_String_Numeric,"txtSubPan")
          scsCloseGadgetList()
          
          \cntSelectedItem=scsContainerGadget(1,65,gnEditorScaPropertiesInnerWidth-2,265,#PB_Container_BorderLess,"\cntSelectedItem")
            ; NOTE: Container for ALL the info for one video/image/capture for this sub-cue, ie including the preview image, xPos, yPos, file name, start, end, etc
            ; nb \cntSelectedItem resized later in this Procedure
            \lblSelectedItem=scsTextGadget(0,0,GadgetWidth(\cntSelectedItem),17,"",0,"lblSelectedItem") ; eg will display something like "File 1: Wildlife.wmv" in reverse color, bold font
            scsSetGadgetFont(\lblSelectedItem, #SCS_FONT_GEN_BOLD9)
            setReverseEditorColors(\lblSelectedItem, #True)
            
            \cntPreview=scsContainerGadget(2,20,#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT,#PB_Container_BorderLess,"cntPreview")
              ; NOTE: Container for the preview image canvas
              SetGadgetColor(\cntPreview, #PB_Gadget_BackColor, #SCS_Light_Grey) ; making this non-black helps show the limits of a non-16x9 target display, because the preview container itself is 16x9
              setAllowEditorColors(\cntPreview, #False)
              \cvsPreview=scsCanvasGadget(0,0,#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT,#PB_Canvas_Keyboard,"cvsPreview")
              If StartDrawing(CanvasOutput(\cvsPreview))
                Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                StopDrawing()
              EndIf
            scsCloseGadgetList()
            
            nLeft = GadgetX(\cntPreview) + GadgetWidth(\cntPreview) + 1
            nTop = GadgetY(\cntPreview)
            nWidth = 40
            nHeight = 200
            nPosAndSizeWidth = 36
            \cntYPosAndSize=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntYPosAndSize")
              ; NOTE: Container to the right of the preview image, for yPos and Size
              nLeft = 4
              nTop = 0
              \lblYPos=scsTextGadget(nLeft,nTop,35,15,Lang("WQA","sldYPos"),0,"lblYPos")
              nTop + 15
              \sldYPos=SLD_New("QA_yPos",\cntYPosAndSize,0,nLeft,nTop,19,70,#SCS_ST_VGENERAL,-5000,5000) ; NB range -5000 to +5000 must NEVER be changed or existing cue files with non-zero yPos values will be incorrect
              SLD_setControlKeyAction(\sldYPos, #SCS_SLD_CCK_ZERO)
              nTop + 70
              \txtYPos=scsStringGadget(0,nTop,nPosAndSizeWidth,15,"",#PB_String_BorderLess,"txtYPos")
              nTop + 15
              \lblSize=scsTextGadget(nLeft,nTop,35,15,Lang("WQA","sldSize"),0,"lblSize")
              nTop + 15
              \sldSize=SLD_New("QA_Size",\cntYPosAndSize,0,nLeft,nTop,19,70,#SCS_ST_VGENERAL,-500,500) ; NB range -500 to +500 must NEVER be changed or existing cue files with non-zero Size values will be incorrect
              SLD_setControlKeyAction(\sldSize, #SCS_SLD_CCK_ZERO)
              nTop + 70
              \txtSize=scsStringGadget(0,nTop,nPosAndSizeWidth,15,"",#PB_String_BorderLess,"txtSize")
            scsCloseGadgetList()
            
            nLeft = 3
            nTop = GadgetY(\cntPreview) + GadgetHeight(\cntPreview) + 1
            nWidth = GadgetX(\cntPreview) + GadgetWidth(\cntPreview) - nLeft
            nHeight = 42
            \cntXPosAndAspect=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntXPosAndAspect")
              ; NOTE: Container below the preview image, for xPos, aspect, and 'Other'
              nLeft = 0
              nTop = 0
              \lblXPos=scsTextGadget(nLeft,nTop+gnLblVOffsetS,40,15,Lang("WQA","sldXPos"),#PB_Text_Right,"lblXPos")
              \sldXPos=SLD_New("QA_xPos",\cntXPosAndAspect,0,gnNextX+gnGap,nTop,104,19,#SCS_ST_HGENERAL,-5000,5000) ; NB range -5000 to +5000 must NEVER be changed or existing cue files with non-zero xPos values will be incorrect
              SLD_setControlKeyAction(\sldXPos, #SCS_SLD_CCK_ZERO)
              \txtXPos=scsStringGadget(gnNextX,nTop+2,nPosAndSizeWidth,15,"",#PB_String_BorderLess,"txtXPos")
              nLeft = 0
              nTop + 21
              \lblAspectRatioType=scsTextGadget(nLeft,nTop+4,40,15,Lang("WQA","lblAspectRatioType"),#PB_Text_Right,"lblAspectRatioType")
              \cboAspectRatioType=scsComboBoxGadget(gnNextX+gnGap,nTop,104,21,0,"cboAspectRatioType")
              \sldAspectRatioHVal=SLD_New("QA_Aspect",\cntXPosAndAspect,0,gnNextX+gnGap,nTop+1,104,19,#SCS_ST_HGENERAL,-500,500) ; NB range -500 to +500 must NEVER be changed or existing cue files with non-zero aspect ratio values will be incorrect
              SLD_setControlKeyAction(\sldAspectRatioHVal, #SCS_SLD_CCK_ZERO)
              nWidth = 60
              nLeft = GadgetX(\cntPreview) + GadgetWidth(\cntPreview) - nWidth - GadgetX(\cntXPosAndAspect) - 2
              nTop = 0
              \mbgOther=scsMenuButtonGadget(nLeft,nTop,nWidth,21,Lang("WQA", "mbgOther"),0,"mbgOther")
            scsCloseGadgetList()
            
            ; NOTE: \sldProgress[0] and \cntGraphDisplayQA are mutually exclusive. \cntGraphDisplayQA is displayed for video files, \sldProgress[0] is displayed for images and captures
            nLeft = GadgetX(\cntPreview)
            nTop = GadgetY(\cntXPosAndAspect) + GadgetHeight(\cntXPosAndAspect) + 12
            nWidth = GadgetX(\cntYPosAndSize) + 23 - nLeft  ; sets width to right-align Progress slider with vertical yPos and Size sliders
            \sldProgress[0]=SLD_New("QA_FileProg",\cntSelectedItem,0,nLeft,nTop,nWidth,25,#SCS_ST_PROGRESS,0,1000)
            SLD_setVisible(\sldProgress[0], #False)
            nTop = GadgetY(\cntXPosAndAspect) + GadgetHeight(\cntXPosAndAspect) + 5
            nWidth = GadgetWidth(\cntSubDetailA) - nLeft - 2
            nHeight = 73
            \cntGraphDisplayQA=scsContainerGadget(nLeft,nTop,nWidth,nHeight,#PB_Container_BorderLess,"cntGraphDisplayQA")
              nWidth = 25 ; required width for side labels
              \cvsSideLabelsQA=scsCanvasGadget(0, 0, nWidth, nHeight, 0,"cvsSideLabelsQA")
              nWidth = GadgetWidth(\cntGraphDisplayQA) - GadgetWidth(\cvsSideLabelsQA) - GadgetX(\cvsSideLabelsQA) - 2 ; 2 pixels to allow for 'flat' border of \cntQAGraphDisplay
              \cntGraphQA=scsContainerGadget(gnNextX,0,nWidth,nHeight,#PB_Container_BorderLess,"cntGraphQA")
                CompilerIf #PB_Compiler_Debugger
                  \cvsGraphQA=scsCanvasGadget(0,0,nWidth,nHeight,#PB_Canvas_Keyboard,"cvsGraphQA")
                CompilerElse
                  \cvsGraphQA=scsCanvasGadget(0,0,nWidth,nHeight,#PB_Canvas_ClipMouse|#PB_Canvas_Keyboard,"cvsGraphQA")
                CompilerEndIf
              scsCloseGadgetList()
            scsCloseGadgetList() ; cntGraphDisplayQA
            
            nLeft = GadgetX(\cntYPosAndSize) + GadgetWidth(\cntYPosAndSize)
            nTop = GadgetY(\cntPreview) ; GadgetY(\lblSelectedItem) + GadgetHeight(\lblSelectedItem) + 4
            nWidth = GadgetWidth(\cntSelectedItem) - nLeft
            nHeight = GadgetY(\cntXPosAndAspect) + GadgetHeight(\cntXPosAndAspect) - nTop - 20  ; -20 to leave space for \chkPreviewOnOutputScreen BELOW \cntRHS
            \cntRHS=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntRHS")
              ; NOTE: Container to the right of the preview image and associated yPos and xPos containers, to contain the file details, including file, start/end, etc
              nLeft = 2
              nWidth = GadgetWidth(\cntRHS) - 4
              \cntHighlightFileName=scsContainerGadget(nLeft,1,nWidth,77,#PB_Container_BorderLess,"cntHighlightFileName")
                nLeft = 4 ; was 6 (pre 18Sep2023)
                nTop = 2
                \cboVideoSource=scsComboBoxGadget(nLeft,nTop,100,21,0,"cboVideoSource")
                addGadgetItemWithData(\cboVideoSource, Lang("VIDCAP", "Video/Image File"), #SCS_VID_SRC_FILE)
                addGadgetItemWithData(\cboVideoSource, Lang("VIDCAP", "VideoCapture"), #SCS_VID_SRC_CAPTURE)
                setComboBoxWidth(\cboVideoSource)
                SGS(\cboVideoSource, 0) ; Default to Video/Image File
                \chkShowFileFolders=scsCheckBoxGadget2(gnNextX+gnGap2,nTop,-1,17,Lang("Common","ShowFileFolders"),0,"chkShowFileFolders") ; nb -ve width = autosize
                ; now right-justify \chkShowFileFolders within \cntHighlightFileName, leaving a right margin same as left margin, ie nLeft
                nLeft2 = GadgetWidth(\cntHighlightFileName) - GadgetWidth(\chkShowFileFolders) - nLeft
                If nLeft2 > 0
                  ResizeGadget(\chkShowFileFolders, nLeft2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                EndIf
                
                nTop + 26
                ; nb vidcaplogicaldev and filename/browse are mutually exclusive (selection applied in WQA_displaySub()), so assigned to the same space in the screen
                \lblVidCapLogicalDev=scsTextGadget(nLeft,nTop+gnLblVOffsetS,70,15,Lang("WQA","lblVidCapLogicalDev"),0,"lblVidCapLogicalDev")
                setGadgetWidth(\lblVidCapLogicalDev,-1,#True)
                \cboVidCapLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,nWidth2,21,0,"cboVidCapLogicalDev")
                setVisible(\lblVidCapLogicalDev, #False)
                setVisible(\cboVidCapLogicalDev, #False)
                \txtFileName=scsStringGadget(nLeft,nTop,(nWidth-30),21,"",#PB_String_ReadOnly,"txtFileName")
                \btnBrowse=scsButtonGadget(gnNextX+1,nTop+1,20,20,"...",0,"btnBrowse")
                scsToolTip(\btnBrowse,Lang("WQA","btnBrowseTT"))
                nTop + 25
                \lnHighlight=scsLineGadget(0,nTop,nWidth,1,nTextColorQA,0,"lnHighlight")
                nTop + 5
                nExtEditBtnWidth = 100 ; width for \btnEditExternally
                nExtEditBtnLeft = GadgetWidth(\cntHighlightFileName) - nExtEditBtnWidth - gnGap ; left for \btnEditExternally
                nWidth = nExtEditBtnLeft - nLeft - gnGap
                \txtFileTypeExt=scsStringGadget(nLeft,nTop,nWidth,17,"",#PB_String_ReadOnly|#PB_String_BorderLess,"txtFileTypeExt")
                \btnEditExternally = scsButtonGadget(nExtEditBtnLeft, nTop-4, nExtEditBtnWidth, 20, LangEllipsis("WQA","btnEditExternally"), 0,"btnEditExternally")
                scsToolTip(\btnEditExternally,Lang("WQA","btnEditExternallyTT"))
              scsCloseGadgetList() ; CloseGadgetList for \cntHighlightFileName
              
              nTop = GadgetY(\cntHighlightFileName) + GadgetHeight(\cntHighlightFileName) ; + 2 ; see also WQA_displaySub()
              ; video fields
              \cntVideoFields=scsContainerGadget(1,nTop,GadgetWidth(\cntRHS)-2,67,#PB_Container_BorderLess,"cntVideoFields")
                nTop = 0
                \lblStartAt=scsTextGadget(10,nTop+4,70,15,Lang("Common","StartAt"), #PB_Text_Right,"lblStartAt")  ; "Start at"
                \txtStartAt=scsStringGadget(gnNextX+7,nTop,64,21,"",0,"txtStartAt")
                scsToolTip(\txtStartAt,Lang("WQA","txtStartAtTT"))
                setValidChars(\txtStartAt, "0123456789.:")
                \lblEndAt=scsTextGadget(160,nTop+4,35,15,Lang("Common","EndAt"), #PB_Text_Right, "lblEndAt")       ; "End at"
                \txtEndAt=scsStringGadget(gnNextX+7,nTop,64,21,"",0,"txtEndAt")
                scsToolTip(\txtEndAt,Lang("WQA","txtEndAtTT"))
                setValidChars(\txtEndAt, "0123456789.:")
                nTop + 21
                \lblPlayLength=scsTextGadget(10,nTop+4,70,15,Lang("WQA","lblPlayLength"), #PB_Text_Right,"lblPlayLength") ; "Play length"
                \txtPlayLength=scsStringGadget(gnNextX+7,nTop,64,21,"",#PB_String_ReadOnly,"txtPlayLength")
                scsToolTip(\txtPlayLength,Lang("WQA","txtPlayLengthTT"))
                nTop + 22
                \lblRelLevel=scsTextGadget(10,nTop+4,70,15,Lang("WQA","lblRelLevel"),#PB_Text_Right,"lblRelLevel")
                \sldRelLevel=SLD_New("QA_RelLevel",\cntVideoFields,0,87,nTop,150,21,#SCS_ST_HPERCENT,0,100)
              scsCloseGadgetList() ; CloseGadgetList for \cntVideoFields
              setVisible(\cntVideoFields, #False)
              
              ; image and capture fields
              \cntImageAndCaptureFields=scsContainerGadget(GadgetX(\cntVideoFields),GadgetY(\cntVideoFields),GadgetWidth(\cntVideoFields),GadgetHeight(\cntVideoFields),#PB_Container_BorderLess,"cntImageAndCaptureFields")
                nTop = 0
                \lblDisplayTime=scsTextGadget(10,nTop+gnLblVOffsetS,69,15,Lang("WQA","lblDisplayTime"), #PB_Text_Right, "lblDisplayTime")
                \txtDisplayTime=scsStringGadget(gnNextX+7,nTop,64,21,"",0,"txtDisplayTime")
                scsToolTip(\txtDisplayTime,Lang("WQA","txtDisplayTimeTT"))
                setValidChars(\txtDisplayTime, "0123456789.:")
                \chkContinuous=scsCheckBoxGadget2(gnNextX+16,nTop+1,92,17,Lang("WQA","chkContinuous"),#PB_CheckBox_ThreeState,"chkContinuous") ; 3-state to handle multiple-selection of items
                scsToolTip(\chkContinuous,Lang("WQA","chkContinuousTT"))
                nLeft = GadgetX(\txtDisplayTime)
                nTop + 25
                nHeight = GadgetHeight(\cntImageAndCaptureFields) - nTop
                nWidth = GadgetWidth(\cntImageAndCaptureFields)
                \cntImageOnlyFields=scsContainerGadget(0,nTop,nWidth,nHeight,#PB_Container_BorderLess,"cntImageOnlyFields")
                  nLeft = GadgetX(\txtDisplayTime) + GadgetX(\cntImageOnlyFields)
                  nTop = 0
                  \chkLogo=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WQA","chkLogo"),0,"chkLogo") ; nb width -1 = auto-size
                  scsToolTip(\chkLogo,Lang("WQA","chkLogoTT"))
                  CompilerIf #c_include_video_overlays
                    nTop + 19
                    \chkOverlay=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WQA","chkOverlay"),0,"chkOverlay")
                    scsToolTip(\chkOverlay,Lang("WQA","chkOverlayTT"))
                    nTop + 22
                  CompilerElse
                    nTop + 20
                  CompilerEndIf
                  nLeft - 1 ; back 1 for appearance relative to above gadgets
                  \mbgRotate=scsMenuButtonGadget(nLeft,nTop,70,21,Lang("WQA", "mbgRotate"),0,"mbgRotate")
                  \lblRotateInfo=scsTextGadget(gnNextX+6,nTop+gnLblVOffsetS,200,30,"",0,"lblRotateInfo")
                scsCloseGadgetList() ; CloseGadgetList for \cntImageOnlyFields
              scsCloseGadgetList() ; CloseGadgetList for \cntImageAndCaptureFields
              setVisible(\cntImageAndCaptureFields, #False)
              
              nTop = GadgetY(\cntVideoFields) + GadgetHeight(\cntVideoFields) + 2
              \cntTransition=scsContainerGadget(GadgetX(\cntVideoFields),nTop,GadgetWidth(\cntVideoFields),37,#PB_Container_BorderLess,"cntTransition")
                nTop = 0
                \lblTransType=scsTextGadget(30,nTop,113,15,Lang("WQA","lblTransType"),0,"lblTransType")
                \lblTransTime=scsTextGadget(143,nTop,72,15,Lang("WQA","lblTransTime"),0,"lblTransTime")
                nTop + 16
                \cboQATransType=scsComboBoxGadget(31,nTop,104,21,0,"cboTransType")
                scsToolTip(\cboQATransType,Lang("WQA","cboTransTypeTT"))
                \txtQATransTime=scsStringGadget(144,nTop,64,21,"",0,"txtTransTime")
                scsToolTip(\txtQATransTime,Lang("WQA","txtTransTimeTT"))
              scsCloseGadgetList() ; CloseGadgetList for \cntTransition
              
              nHeight = GadgetY(\cntTransition) + GadgetHeight(\cntTransition) + 4
              If GadgetHeight(\cntRHS) <> nHeight
                ResizeGadget(\cntRHS, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
              EndIf
              
              ; the 'flat' border color of a container gadget is grey, so use lines to draw the border as nTextColorQA
              nWidth = GadgetWidth(\cntRHS)
              \lnSelectedItem[0]=scsLineGadget(0,0,nWidth-1,1,nTextColorQA,0,"lnSelectedItem[0]")
              \lnSelectedItem[1]=scsLineGadget(0,nHeight-1,nWidth-1,1,nTextColorQA,0,"lnSelectedItem[1]")
              \lnSelectedItem[2]=scsLineGadget(0,0,1,nHeight-1,nTextColorQA,0,"lnSelectedItem[2]")
              \lnSelectedItem[3]=scsLineGadget(nWidth-1,0,1,nHeight-1,nTextColorQA,0,"lnSelectedItem[3]")
              
            scsCloseGadgetList() ; CloseGadgetList for \cntRHS
            
            nTop = GadgetY(\cntRHS) + GadgetHeight(\cntRHS) + 3
            nLeft = GadgetX(\cntRHS) + 12
            \chkPreviewOnOutputScreen=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WQA","chkPreviewOnOutputScreen")+"   ",0,"chkPreviewOnOutputScreen") ; nb width -1 = auto-size, which is why the 3 spaces have been added to the end
            nWidth = GadgetWidth(\cntSelectedItem) - nLeft - 4

          scsCloseGadgetList()
          
          ; resize \cntSelectedItem
          ; nHeight = SLD_gadgetY(\sldProgress[0]) + SLD_gadgetHeight(\sldProgress[0]) + 4
          nHeight = GadgetY(\cntGraphDisplayQA) + GadgetHeight(\cntGraphDisplayQA) + 4
          ; debugMsg(sProcName, "new height for \cntSelectedItem = " + nHeight)
          ResizeGadget(\cntSelectedItem, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
          
          nTop = GadgetY(\cntSelectedItem) + GadgetHeight(\cntSelectedItem)
          \cntMoveAddDeleteRename=scsContainerGadget(3,nTop,150,28,#PB_Container_BorderLess,"cntMoveAddDeleteRename")
            ; NOTE sub-cue level container with <-, ->, +, -, Rename buttons
            setAllowEditorColors(\cntMoveAddDeleteRename, #False)    ; prevent toolbar being colored
            \imgButtonTBS[0]=scsStandardButton(2,2,24,24,#SCS_STANDARD_BTN_MOVE_LEFT,"imgButtonTBS[0]")
            \imgButtonTBS[1]=scsStandardButton(26,2,24,24,#SCS_STANDARD_BTN_MOVE_RIGHT,"imgButtonTBS[1]")
            \imgButtonTBS[2]=scsStandardButton(50,2,24,24,#SCS_STANDARD_BTN_PLUS,"imgButtonTBS[2]")
            \imgButtonTBS[3]=scsStandardButton(74,2,24,24,#SCS_STANDARD_BTN_MINUS,"imgButtonTBS[3]")
            \btnRename=scsButtonGadget(98,2,50,gnBtnHeight,Lang("Btns","Rename"),0,"btnRename")
          scsCloseGadgetList() ; cntMoveAddDeleteRename
          
          nLeft = GadgetX(\cntMoveAddDeleteRename) + GadgetWidth(\cntMoveAddDeleteRename) + 8
          nTop = GadgetY(\cntMoveAddDeleteRename)
          nWidth = GadgetWidth(\cntSubDetailA) - nLeft - 2
          \cntTest=scsContainerGadget(nLeft,nTop,nWidth,28,#PB_Container_BorderLess,"cntTest")
            ; NOTE sub-cue level container with transport controls and progress slider for the ENTIRE sub-cue
            ; If the user clicks the Play button then playback for this test starts from the currently-selected video/image/capture
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            ; transport controls
            \btnFirst=scsStandardButton(4,2,24,24,#SCS_STANDARD_BTN_FIRST,"btnFirst")
            \btnPrev=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_PREV,"btnPrev")
            \btnPlay=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_PLAY,"btnPlay")
            scsToolTip(\btnPlay, Lang("Btns", "PlayFromHereTT"))  ; replaces "PlayTT" tooltip
            \btnPause=scsStandardButton(GadgetX(\btnPlay),2,24,24,#SCS_STANDARD_BTN_PAUSE,"btnPause")
            setVisible(\btnPause, #False)
            \btnNext=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_NEXT,"btnNext")
            \btnLast=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_LAST,"btnLast")
            \btnFadeOut=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_FADEOUT,"btnFadeOut")
            \btnStop=scsStandardButton(gnNextX,2,24,24,#SCS_STANDARD_BTN_STOP,"btnStop")
            ; progress slider
            nSldLeft = gnNextX + 8
            nSldWidth = GadgetWidth(\cntTest) - nSldLeft - 8
            \sldProgress[1]=SLD_New("QA_TestProg",\cntTest,0,nSldLeft,4,nSldWidth,19,#SCS_ST_PROGRESS,0,1000)
          scsCloseGadgetList() ; cntTest
          
        scsCloseGadgetList() ; cntSubDetailA
        
      scsCloseGadgetList() ; scaSlideShow
      
      scsOpenGadgetList(WED\cntSpecialQA)
        nWidth = GadgetWidth(WED\cntSpecialQA) - 4
        nInnerWidth = nWidth - 2
        nTop = 0
        \scaTimeLine=scsScrollAreaGadget(1,nTop,nWidth,nSpecialQAHeight,nInnerWidth,nSpecialQAInnerHeight,#SCS_QAITEM_WIDTH,#PB_ScrollArea_Flat,"scaTimeLine")
        scsCloseGadgetList()
        \lnDropMarker=scsLineGadget(0,nTop,2,nSpecialQAInnerHeight,#SCS_Black,0,"lnDropMarker")
        setVisible(\lnDropMarker, #False)
      scsCloseGadgetList() ; WED\cntSpecialQA
      setVisible(WED\cntSpecialQA, #True)
      
      If scsCreatePopupMenu(#WQA_mnu_GraphContextMenu)
        If grLicInfo\bCueMarkersAvailable
          ; MenuBar()
          ; OpenSubMenu(Lang("Menu", "mnuCueMarkers"))
          ; NB Cue Markers originally included for Audio Files only, so language translations included under WQF
            scsMenuItem(#WQA_mnu_AddQuickCueMarkers, "mnuWQFAddQuickCueMarker")
            scsMenuItem(#WQA_mnu_EditCueMarker, "mnuWQFEditCueMarker")
            scsMenuItem(#WQA_mnu_SetCueMarkerPos, "mnuWQFSetCueMarkerPos")
            scsMenuItem(#WQA_mnu_RemoveCueMarker, "mnuWQFRemoveCueMarker")
            MenuBar()
            scsMenuItem(#WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile, "mnuWQFRemoveAllUnusedCueMarkersThisFile")
            scsMenuItem(#WQA_mnu_RemoveAllUnusedCueMarkers, "mnuWQFRemoveAllUnusedCueMarkers")
            scsMenuItem(#WQA_mnu_ViewOnCues, "mnuWQFViewOnCues")
            scsMenuItem(#WQA_mnu_ViewCueMarkersUsage, "mnuWQFViewCueMarkersUsage")
          ; CloseSubMenu()
        EndIf
      EndIf
      
      setEnabled(\scaSlideShow, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  WQA_buildPopupMenu_Rotate()
  WQA_buildPopupMenu_Other()
  
  gnCurrentEditorComponent = 0
  grCED\bQACreated = #True
  
EndProcedure

Structure strWQQ ; fmEditQQ
  SUBCUE_HEADER_FIELDS()
  cboActionReqd.i
  cboCallCue.i
  cboSelHKBank.i
  cntCallCue.i
  cntParams.i
  cntSelHKBank.i
  cntSubDetailQ.i
  lblCallCue.i
  lblActionReqd.i
  lblParams.i
  lblSelHKBank.i
  scaCallCue.i
  Array txtParamId.i(#SCS_MAX_CALLABLE_CUE_PARAM)
  Array txtParamValue.i(#SCS_MAX_CALLABLE_CUE_PARAM)
  Array lblParamDefault.i(#SCS_MAX_CALLABLE_CUE_PARAM)
EndStructure
Global WQQ.strWQQ ; fmEditQQ

Procedure createfmEditQQ()
  ; 'Call Cue' Cues
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight
  Protected nLeft2, n
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQQ
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQQ
      \scaCallCue=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaCallCue")
        setVisible(\scaCallCue, #False)
        ; header
        SUBCUE_HEADER_CODE(WQQ)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailQ=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailQ")
          nLeft = 12
          nTop = 25
          nWidth = 164
          \lblActionReqd=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("Common","ActionReqd"),#PB_Text_Right,"lblActionReqd")
          \cboActionReqd=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboActionReqd")
          addGadgetItemWithData(\cboActionReqd,Lang("WQQ","lblCallCue"),#SCS_QQ_CALLCUE)
          If grLicInfo\nMaxHotkeyBank > 0
            addGadgetItemWithData(\cboActionReqd,Lang("WQQ","lblSelHKBank"),#SCS_QQ_SELHKBANK)
          EndIf
          setComboBoxWidth(\cboActionReqd)
          nTop + 40
          ; NOTE: \cntCallCue and \cntSelHKBank are mutually exclusive, as determined by the selected cboActionReqd. See the SCS Help for "Editor / 'Call Cue' Cues" for more info.
          \cntCallCue=scsContainerGadget(0,nTop,GadgetWidth(\cntSubDetailQ),100,#PB_Container_BorderLess,"cntCallCue")
            nTop = 0
            \lblCallCue=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("WQQ","lblCallCue"),#PB_Text_Right,"lblCallCue")
            \cboCallCue=scsComboBoxGadget(gnNextX+gnGap,nTop,400,21,0,"cboCallCue")
            nTop + 27
            \lblParams=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("WQQ","lblParams"),#PB_Text_Right,"lblParams")
            nLeft2 = GadgetX(\cboCallCue)
            For n = 0 To #SCS_MAX_CALLABLE_CUE_PARAM
              \txtParamId(n)=scsStringGadget(nLeft2,nTop,60,21,"",#PB_String_ReadOnly,"txtParamId(" + n + ")")
              DisableGadget(\txtParamId(n), #True)
              \txtParamValue(n)=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtParamValue(" + n + ")")
              \lblParamDefault(n)=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,140,15,"",0,"lblParamDefault(" + n + ")")
              nTop + 23
            Next n
            ResizeGadget(\cntCallCue, #PB_Ignore, #PB_Ignore, #PB_Ignore, nTop)
          scsCloseGadgetList()
          If grLicInfo\nMaxHotkeyBank > 0
            \cntSelHKBank=scsContainerGadget(0,GadgetY(\cntCallCue),GadgetWidth(\cntSubDetailQ),40,#PB_Container_BorderLess,"cntSelHKBank")
              \lblSelHKBank=scsTextGadget(nLeft,gnLblVOffsetS,nWidth,15,Lang("WQQ","lblSelHKBank"),#PB_Text_Right,"lblSelHKBank")
              \cboSelHKBank=scsComboBoxGadget(gnNextX+gnGap,0,150,21,0,"cboSelHKBank")
            scsCloseGadgetList()
            setVisible(\cntSelHKBank,#False)
          EndIf
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaCallCue
      
      ; setVisible(WQQ\scaCallCue, #True)
      setEnabled(WQQ\scaCallCue, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQQCreated = #True
  
EndProcedure

Structure strWQE ; fmEditQE
  SUBCUE_HEADER_FIELDS()
  cboAspectRatio.i
  cboMemoScreen.i
  cboSyncSizeWithCue.i
  chkContinuous.i
  chkResizeFont.i
  btnPreview.i
  cntMemoControls.i
  cntRichEdit.i
  cntSubDetailE.i
  lblAspectRatio.i
  lblDisplayTime.i
  lblMemoScreen.i
  rchMemo.i
  rchMemoObject.RichEdit
  sbStatusBar.i
  scaMemo.i
  tbToolBar.i
  txtDisplayTime.i
EndStructure
Global WQE.strWQE ; fmEditQE

Procedure createfmEditQE()
  ; Memo Cues
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight
  Protected nInnerHeight
  Protected nReqdWidth, nLblWidthLine1, nLblWidthLine2, nLblWidthLine3
  Protected nFirstCtrlLeft, nTopLine1, nTopLine2, nTopLine3
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWQE
    If \bTextLoaded = #False
      \sTextLine  = " " + Lang("WQE", "Line") + ": "
      \sTextCol   = " " + Lang("WQE", "Col") + ": "
      \sTextFont  = " " + Lang("WQE", "Font") + ": "
      \sTextCount = " " + Lang("WQE", "Count") + ": "
      \sTextZoom  = " " + Lang("WQE", "Zoom") + ": "
      \bTextLoaded = #True
    EndIf
  EndWith
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQE
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQE
      nInnerHeight = 490
      \scaMemo=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, nInnerHeight, 30, #PB_ScrollArea_Flat, "scaMemo")
        setVisible(\scaMemo, #False)
        ; header
        SUBCUE_HEADER_CODE(WQE)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = nInnerHeight - nTop
        \cntSubDetailE=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailE")
          
          nLeft = 40
          nTop = 4
          nWidth = GadgetWidth(\cntSubDetailE) - nLeft - nLeft
          If nWidth <> grSubDef\nMemoDesignWidth
            sMsg = "grSubDef\nMemoDesignWidth=" + grSubDef\nMemoDesignWidth + " but calculated nWidth=" + nWidth +  "." + Chr(10)
            sMsg + "You may continue processing, but please advise SCS support of this discrepancy."
            debugMsg(sProcName, "!!!!!!!! " + sMsg)
            scsMessageRequester(sProcName, sMsg, #MB_ICONEXCLAMATION)
          EndIf
          ; Debug "RichEdit width = " + nWidth
          nHeight = nWidth * 9 / 16
          \cntRichEdit=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntRichEdit")
            \tbToolBar = WQE_createToolbar()
            \sbStatusBar = WQE_createStatusBar()
            nTop = ToolBarHeight(\tbToolBar)
            nHeight = GadgetHeight(\cntRichEdit) - nTop - StatusBarHeight(\sbStatusBar)
            debugMsg(sProcName, "New_RichEdit(0, " + nTop + ", " + nWidth + ", " + nHeight + ")")
            \rchMemoObject = New_RichEdit(0, nTop, nWidth, nHeight)
            \rchMemoObject\SetLeftMargin(5)
            \rchMemoObject\SetRightMargin(5)
            \rchMemoObject\SetInterface()
            \rchMemo = \rchMemoObject\GetID()
            \rchMemoObject\SetCtrlBackColor(grWEN\nLastMemoPageColor)
            If grWEN\nLastMemoTextBackColor <> -1
              \rchMemoObject\SetTextBackColor(grWEN\nLastMemoTextBackColor)
            EndIf
            \rchMemoObject\SetTextColor(grWEN\nLastMemoTextColor)
          scsCloseGadgetList()
          
          nLeft = 20
          nTop = GadgetY(\cntRichEdit) + GadgetHeight(\cntRichEdit) + 8
          nWidth = GadgetWidth(\cntSubDetailE) - nLeft - nLeft
          nHeight = 50
          \cntMemoControls=scsContainerGadget(nLeft, nTop, nWidth, nHeight, 0,"cntMemoControls")
            nLeft = 0
            nTop = 0
            \lblDisplayTime=scsTextGadget(nLeft,nTop+gnLblVOffsetS,100,15,Lang("WQE","lblDisplayTime"),#PB_Text_Right,"lblDisplayTime")
            nLblWidthLine1 = GadgetWidth(\lblDisplayTime,#PB_Gadget_RequiredSize)
            \lblMemoScreen=scsTextGadget(nLeft,nTop+30,100,15,Lang("WQE","lblMemoScreen"),#PB_Text_Right,"lblMemoScreen")
            nLblWidthLine2 = GadgetWidth(\lblMemoScreen,#PB_Gadget_RequiredSize)
            If nLblWidthLine1 > nLblWidthLine2
              nReqdWidth = nLblWidthLine1
            Else
              nReqdWidth = nLblWidthLine2
            EndIf
            nReqdWidth + 8
            ResizeGadget(\lblDisplayTime,#PB_Ignore,#PB_Ignore,nReqdWidth,#PB_Ignore)
            ResizeGadget(\lblMemoScreen,#PB_Ignore,#PB_Ignore,nReqdWidth,#PB_Ignore)
            nLeft = GadgetX(\lblDisplayTime) + GadgetWidth(\lblDisplayTime) + gnGap
            \txtDisplayTime=scsStringGadget(nLeft,nTop,64,21,"",0,"txtDisplayTime")
            scsToolTip(\txtDisplayTime,Lang("WQE","txtDisplayTimeTT"))
            setValidChars(\txtDisplayTime, "0123456789.:")
            \chkContinuous=scsCheckBoxGadget2(gnNextX+16,nTop+1,92,17,Lang("WQE","chkContinuous"),0,"chkContinuous")
            scsToolTip(\chkContinuous,Lang("WQE","chkContinuousTT"))
            \lblAspectRatio=scsTextGadget(gnNextX+8,nTop+gnLblVOffsetS,80,15,Lang("WQE","lblAspectRatio"), #PB_Text_Right, "lblAspectRatio")
            \cboAspectRatio=scsComboBoxGadget(gnNextX+gnGap,nTop,60,21,0,"cboAspectRatio")
            nTop + 27
            nLeft = GadgetX(\lblMemoScreen) + GadgetWidth(\lblMemoScreen) + gnGap
            \cboMemoScreen=scsComboBoxGadget(nLeft,nTop,40,21,0,"cboMemoScreen")
            WQE_populateCboMemoScreen()
            nLeft = GadgetX(\cboMemoScreen) + GadgetWidth(\cboMemoScreen) + 8
            \chkResizeFont=scsCheckBoxGadget2(nLeft,nTop+1,92,17,Lang("WQE","chkResizeFont"),0,"chkResizeFont")
            nReqdWidth = getGadgetReqdWidth(sProcName,\chkResizeFont)
            ResizeGadget(\chkResizeFont,#PB_Ignore,#PB_Ignore,nReqdWidth,#PB_Ignore)
            nWidth = 100
            nLeft = GadgetWidth(\cntMemoControls)
            nHeight = 23
            nTop = (GadgetHeight(\cntMemoControls) - nHeight) >> 1
            \btnPreview=scsButtonGadget(nLeft, nTop, nWidth, nHeight, Lang("WQE","CancelPreview"),0,"btnPreview")
            nReqdWidth = GadgetWidth(\btnPreview, #PB_Gadget_RequiredSize)
            nLeft = GadgetWidth(\cntMemoControls) - (nReqdWidth * 1.2)
            ResizeGadget(\btnPreview,nLeft,#PB_Ignore,nReqdWidth,#PB_Ignore)
            SGT(\btnPreview, Lang("WQE","btnPreview"))
            scsToolTip(\btnPreview, Lang("WQE","btnPreviewTT"))
          scsCloseGadgetList()
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaMemo
      
      ; setVisible(\scaMemo, #True)
      setEnabled(\scaMemo, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQECreated = #True
  
EndProcedure

Structure strWQF ; fmEditQF
  SUBCUE_HEADER_FIELDS()
  btnBrowse.i
  btnCenter.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  btnEditFadeOut.i
  btnEditPause.i
  btnEditPlay.i
  btnEditRelease.i
  btnEditRewind.i
  btnEditStop.i
  btnEndAt.i
  btnFadeInTime.i
  btnFadeOutTime.i
  btnInsertDev.i
  btnLoopAdd.i
  btnLoopDel.i
  btnLoopEnd.i
  btnLoopNrLeft.i
  btnLoopNrRight.i
  btnLoopStart.i
  btnMoveDevDown.i
  btnMoveDevUp.i
  btnOther.i
  btnRemoveDev.i
  btnStartAt.i
  btnVCMOK.i
  btnViewAll.i
  btnViewPlayable.i
  cboDevSel.i
  cboGraphDisplayMode.i
  cboLevelSel.i
  cboLogicalDevF.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cboPanSel.i
  ; cboRelStartSubcue.i
  cboTracks.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cboTrim.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblVSTPlugin.i
  cboVSTPlugin.i
  chkAutoScroll.i
  chkBypassVST.i ; VST Plugins Bypass
  chkDevInclude.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  chkLoop.i
  chkLoopLinked.i   ; added 2Nov2015 11.4.1.2g
  CompilerIf #c_include_sync_levels
    chkSyncLevels.i   ; not implemented yet
  CompilerEndIf
  chkViewVST.i ; VST Plugins
  cntAudioControls.i
  cntCurrPos.i
  cntDevLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cntDevRelLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cntLevelLabels.i
  cntMiscFields.i
  cntRelLevelLabels.i
  cntGraph.i
  cntGraphDisplay.i
  cntSubDetailF.i
  cntTest.i
  cvsGraph.i
  cvsSideLabels.i
  lblCueDuration.i
  lblCuePosTimeOffset.i
  lblCurrPos.i
  lbldB.i
  lblDevNo.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblEnd.i
  lblEndAt.i
  lblFadeInTime.i
  lblFadeOutTime.i
  lblFileName.i
  lblGraphDev.i
  lblInclude.i
  lblInfo.i
  lblLevel.i
  lblLoop.i
  lblLoopEnd.i
  lblLoopNr.i
  lblLoops.i
  lblLoopStart.i
  lblLoopXFadeTime.i
  lblNumLoops.i
  lblNumLoops2.i
  lblOtherInfo.i
  lblPan.i
  lblPosition.i
  lblStart.i
  lblStartAt.i
  lblTempoEtcInfo.i
  lblTestCue.i
  lblTracks.i
  lblTrim.i
  lblZoom.i
  lnDevs.i
  lnLoopDetail.i
  lnLoops.i
  lnTimes.i
  scaDevs.i
  scaSoundFile.i
  sldLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldPosition.i
  sldProgress.i
  trbZoom.i
  txtCueDuration.i
  txtCuePosTimeOffset.i
  txtCurrPos.i
  txtDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtDevDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtEndAt.i
  txtFadeInTime.i
  txtFadeOutTime.i
  txtFileDuration.i
  txtFileTypeExt.i
  txtFileName.i
  txtLoopEnd.i
  txtLoopNr.i
  txtLoopStart.i
  txtLoopXFadeTime.i
  txtNumLoops.i
  txtPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtPlayDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtRelDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtStartAt.i
  ; other fields
  nMaxGraphDevWidth.i
EndStructure
Global WQF.strWQF ; fmEditQF

Procedure createfmEditQF()
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, sNr.s, l2
  Protected nScaLeft, nScaTop, nScaWidth, nDevWidth
  Protected nDevInnerWidth, nDevInnerHeight
  Protected nHeight, nScrollAreaHeight
  Protected nInnerHeight
  Protected sBtnText.s
  Protected nSpecialQFHeight
  Protected nMainHeight
  Protected nReqdWidth
  
  debugMsg(sProcName, #SCS_START)
  
  ; added 8Oct2019 11.8.2at following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
  ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
  If GetWindowState(#WED) = #PB_Window_Minimize
    debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
    SetWindowState(#WED, #PB_Window_Normal)
    debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
  EndIf
  ; end added 8Oct2019 11.8.2at
  
  nSpecialQFHeight = 176
  nMainHeight = WindowHeight(#WED) - GadgetY(WED\cntRight) - nSpecialQFHeight
  ResizeGadget(WED\cntLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore,nMainHeight)
  ; debugMsg(sProcName, ".ResizeGadget(WED\cntLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore," + nMainHeight + ")")
  ResizeGadget(WED\cntRight,#PB_Ignore,#PB_Ignore,#PB_Ignore,nMainHeight+80)
  ; debugMsg(sProcName, ".ResizeGadget(WED\cntRight,#PB_Ignore,#PB_Ignore,#PB_Ignore," + Str(nMainHeight+80) + ")")
  nTop = WindowHeight(#WED) - nSpecialQFHeight
  
  ; 21/08/2014 (11.3.3) included resetting the width of WED\cntSpecialQF because this container seemed to have lost 1 pixel in width - don't know why
  nWidth = WindowWidth(#WED)
  ResizeGadget(WED\cntSpecialQF,#PB_Ignore,nTop,nWidth,nSpecialQFHeight)
  debugMsg(sProcName, "ResizeGadget(WED\cntSpecialQF,#PB_Ignore," + nTop + "," + nWidth + "," + nSpecialQFHeight + ")")

  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQF
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQF
      nInnerHeight = (41 + 4 + 403 + 40 + 2) ; 41 = height of subcue header; 4 = gap before detail; 403 = top of last container within detail; 40 = height of last container within detail
      ; debugMsg(sProcName, "nInnerHeight=" + nInnerHeight)
      ; x, y, width and height do not need to be specified in scaSoundFile as it will be linked to a splitter gadget - see setEditorComponentVisible()
      \scaSoundFile=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, nInnerHeight, 30, #PB_ScrollArea_Flat, "scaSoundFile")  ; innerheight was 515
        setVisible(\scaSoundFile, #False)
        ; header
        SUBCUE_HEADER_CODE(WQF)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 2 ; was 4 pre 11.9.1aq
        nHeight = GetGadgetAttribute(\scaSoundFile, #PB_ScrollArea_InnerHeight) - nTop
        debugMsg(sProcName, "nHeight=" + nHeight)
        \cntSubDetailF=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailF")
          
          \lblFileName=scsTextGadget(0,4,66,17,Lang("WQF","lblFileName"), #PB_Text_Right,"lblFileName")
          \txtFileName=scsStringGadget(72,0,416,21,"",#PB_String_ReadOnly,"txtFileName")
          EnableGadgetDrop(\txtFileName, #PB_Drop_Files, #PB_Drag_Copy)
          \btnBrowse=scsButtonGadget(489,1,20,20,"...",0,"btnBrowse")
          scsToolTip(\btnBrowse,Lang("WQF","btnBrowseTT"))
          \btnOther=scsButtonGadget(513,0,70,22,LangEllipsis("Btns","OtherActions"),0,"btnOther")
          setGadgetWidth(\btnOther)
          nLeft = 12
          nWidth = GadgetWidth(\cntSubDetailF) - (nLeft * 2)
          \txtFileTypeExt=scsStringGadget(nLeft,24,nWidth,17,"",#PB_String_ReadOnly|#PB_String_BorderLess,"txtFileTypeExt")
          
          ; Add the GUI for VST Selection if we have VST Plugins stored
          \lblVSTPlugin=scsTextGadget(190,24,50,17,Lang("VST","lblVSTPlugin"),#PB_Text_Right,"lblVSTPlugin")
          \cboVSTPlugin=scsComboBoxGadget(gnNextX+gnGap, 21, 160, 20, 0, "cboVSTPlugin") 
          \chkViewVST=scsCheckBoxGadget2(gnNextX+GnGap2, 21, 38, 20, Lang("VST","chkView"), 0, "chkViewVST")
          \chkBypassVST=scsCheckBoxGadget2(gnNextX+GnGap2, 21 ,50, 20, Lang("VST","chkBypass"), 0 , "chkBypassVST")
          
          ; start, end, and fade times
          nTop = 55
          \lblStartAt=scsTextGadget(8,nTop,84,15,Lang("Common","StartAt"),0,"lblStartAt") ; "Start at"
          \lblEndAt=scsTextGadget(gnNextX+2,nTop,84,15,Lang("Common","EndAt"),0,"lblEndAt") ; "End at"
          nTop - 11 ; double-height labels
          \lblCueDuration=scsTextGadget(gnNextX+2,nTop,76,26,Lang("WQF","lblCueDuration"),0,"lblCueDuration")  ; "Play Length"
          \lblFadeInTime=scsTextGadget(gnNextX+2,nTop,70,26,Lang("WQF","lblFadeInTime2"),0,"lblFadeInTime")    ; "Fade In Time/Type" ; Changed 25Jan2023 11.9.9ac
          \lblFadeOutTime=scsTextGadget(gnNextX+2,nTop,70,26,Lang("WQF","lblFadeOutTime2"),0,"lblFadeOutTime") ; "Fade Out Time/Type" ; Changed 25Jan2023 11.9.9ac
          nTop = 71
          nWidth = 70
          sBtnText = "»"
          \txtStartAt=scsStringGadget(4,nTop,nWidth,20,"",0,"txtStartAt")
          scsToolTip(\txtStartAt,Lang("WQF","txtStartAtTT"))
          \btnStartAt=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnStartAt")
          \txtEndAt=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",0,"txtEndAt")
          scsToolTip(\txtEndAt,Lang("WQF","txtEndAtTT"))
          \btnEndAt=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnEndAt")
          nWidth = 76
          \txtCueDuration=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",#PB_String_ReadOnly,"txtCueDuration")
          scsToolTip(\txtCueDuration,Lang("WQF","txtCueDurationTT"))
          setEnabled(\txtCueDuration, #False)
          scsSetGadgetFont(\txtCueDuration, #SCS_FONT_GEN_BOLD)
          nWidth = 56
          \txtFadeInTime=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",0,"txtFadeInTime")
          setValidChars(\txtFadeInTime, "0123456789.:") ; will be disabled on 'GetFocus' if the parent cue is a callable cue
          scsToolTip(\txtFadeInTime,Lang("WQF","txtFadeInTimeTT"))
          \btnFadeInTime=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnFadeInTime")
          \txtFadeOutTime=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",0,"txtFadeOutTime")
          setValidChars(\txtFadeOutTime, "0123456789.:") ; will be disabled on 'GetFocus' if the parent cue is a callable cue
          scsToolTip(\txtFadeOutTime,Lang("WQF","txtFadeOutTimeTT"))
          \btnFadeOutTime=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnFadeOutTime")
          
          ; misc info
          nTop = GadgetY(\txtStartAt) + 20
          nLeft = 0
          nWidth = GadgetX(\txtCueDuration) - nLeft - gnGap ; will align \txtCurrPos with \txtCueDuration
          \lblCurrPos=scsTextGadget(nLeft,nTop+3,nWidth,15,Lang("WQF","lblCurrPos"),#PB_Text_Right,"lblCurrPos") ; "Current Position"
          ; setGadgetWidth(\lblCurrPos,-1,#True)
          \txtCurrPos=scsStringGadget(gnNextX+gnGap,nTop,GadgetWidth(\txtCueDuration),20,"",0,"txtCurrPos")
          scsToolTip(\txtCurrPos,Lang("WQF","txtCurrPosTT"))
          \chkLoopLinked=scsCheckBoxGadget2(gnNextX+12,nTop+2,80,17,Lang("WQF","chkLoopLinked"),0,"chkLoopLinked")  ; added 2Nov2015 11.4.1.2g
          scsToolTip(\chkLoopLinked,Lang("WQF","chkLoopLinkedTT"))
          
          nTop + 20
          \lblCuePosTimeOffset=scsTextGadget(GadgetX(\lblCurrPos),nTop+3,GadgetWidth(\lblCurrPos),15,Lang("WQF","lblCuePosTimeOffset"),#PB_Text_Right,"lblCuePosTimeOffset")
          ; setGadgetWidth(\lblCuePosTimeOffset,-1,#True)
          \txtCuePosTimeOffset=scsStringGadget(gnNextX+gnGap,nTop,GadgetWidth(\txtCurrPos),20,"",0,"txtCuePosTimeOffset")
          scsToolTip(\txtCuePosTimeOffset,Lang("WQF","txtCuePosTimeOffsetTT"))
;           nWidth = GadgetWidth(\lblCuePosTimeOffset)
;           If nWidth > GadgetWidth(\lblCurrPos)
;             ResizeGadget(\lblCurrPos, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
;             ResizeGadget(\txtCurrPos, (GadgetX(\lblCurrPos) + GadgetWidth(\lblCurrPos) + gnGap), #PB_Ignore, #PB_Ignore, #PB_Ignore)
;             ResizeGadget(\chkLoopLinked, (GadgetX(\txtCurrPos) + GadgetWidth(\txtCurrPos) + 12), #PB_Ignore, #PB_Ignore, #PB_Ignore)
;           EndIf
          
          ; tempo etc info
          nLeft = GadgetX(\txtCuePosTimeOffset) + GadgetWidth(\txtCuePosTimeOffset) + gnGap2
          nTop = GadgetY(\txtCuePosTimeOffset)
          nWidth = 398 - nLeft ; vertical line \lnLoops will be at X=400
          \lblTempoEtcInfo=scsTextGadget(nLeft,nTop,nWidth,15,"",0,"lblTempoEtcInfo")
          scsSetGadgetFont(\lblTempoEtcInfo, #SCS_FONT_GEN_BOLD)
          
          ; loop info
          nLeft = 406
          nTop = 44
          \lblLoops=scsTextGadget(nLeft,nTop+4,100,15,Lang("WQF","lblLoops"),0,"lblLoops")
          setGadgetWidth(\lblLoops,-1,#True)
          \btnLoopAdd=scsStandardButton(gnNextX,nTop,18,20,#SCS_STANDARD_BTN_PLUS,"btnLoopAdd",#True)
          scsToolTip(\btnLoopAdd, Lang("WQF", "btnLoopAddTT"))
          \btnLoopDel=scsStandardButton(gnNextX,nTop,18,20,#SCS_STANDARD_BTN_MINUS,"btnLoopDel",#True)
          scsToolTip(\btnLoopDel, Lang("WQF", "btnLoopDelTT"))
          \lblLoopNr=scsTextGadget(gnNextX+12,nTop+4,70,15,Lang("WQF","lblLoopNr"),0,"lblLoopNr")
          scsSetGadgetFont(\lblLoopNr, #SCS_FONT_GEN_UL)
          setGadgetWidth(\lblLoopNr,-1,#True)
          \btnLoopNrLeft=scsButtonGadget(gnNextX,nTop,16,20,"<",0,"btnLoopNrLeft")
          \txtLoopNr=scsStringGadget(gnNextX,nTop+1,20,19,"",#PB_String_ReadOnly|#ES_CENTER,"txtLoopNr")
          setEnabled(\txtLoopNr, #False)
          \btnLoopNrRight=scsButtonGadget(gnNextX,nTop,16,20,">",0,"btnLoopNrRight")
          nTop + 24
          nLeft = GadgetX(\lblLoops)
          \lblLoopStart=scsTextGadget(nLeft,nTop,84,15,Lang("WQF","lblLoopStart"),0,"lblLoopStart")
          \lblLoopEnd=scsTextGadget(gnNextX+2,nTop,84,15,Lang("WQF","lblLoopEnd"),0,"lblLoopEnd")
          \lblLoopXFadeTime=scsTextGadget(gnNextX+2,nTop,70,15,Lang("WQF","lblLoopXFadeTime"),0,"lblLoopXFadeTime") ; Changed 30Mar2022 11.9.1ax
          nWidth = 70
          nLeft = GadgetX(\lblLoopStart) - 2
          nTop = GadgetY(\lblLoopStart) + 16
          \txtLoopStart=scsStringGadget(nLeft,nTop,nWidth,20,"",0,"txtLoopStart")
          scsToolTip(\txtLoopStart,Lang("WQF","txtLoopStartTT"))
          \btnLoopStart=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnLoopStart")
          \txtLoopEnd=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",0,"txtLoopEnd")
          scsToolTip(\txtLoopEnd,Lang("WQF","txtLoopEndTT"))
          \btnLoopEnd=scsButtonGadget(gnNextX,nTop,14,20,sBtnText,0,"btnLoopEnd")
          nWidth = 56
          \txtLoopXFadeTime=scsStringGadget(gnNextX+2,nTop,nWidth,20,"",0,"txtLoopXFadeTime")
          scsToolTip(\txtLoopXFadeTime,Lang("WQF","txtLoopXFadeTimeTT"))
          nTop + 22
          nLeft = GadgetX(\lblLoopStart)
          nWidth = GadgetX(\txtLoopEnd) - nLeft - gnShortGap
          debugMsg(sProcName, "nWidth=" + nWidth)
          \lblNumLoops=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nWidth,15,Lang("WQF","lblNumLoops"),#PB_Text_Right,"lblNumLoops")
          \txtNumLoops=scsStringGadget(gnNextX+gnShortGap,nTop,25,20,"",#PB_String_Numeric,"txtNumLoops")
          scsToolTip(\txtNumLoops,Lang("WQF","txtNumLoopsTT"))
          \lblNumLoops2=scsTextGadget(gnNextX+gnShortGap,nTop+gnLblVOffsetS,50,15,Lang("WQF","lblNumLoops2"),0,"lblNumLoops2")
          
          \lnTimes=scsLineGadget(1,41,gnEditorScaPropertiesInnerWidth-2,1,#SCS_Black,0,"lnTimes") ; not sure where this line is displayed
          ; nTop = 131
          nTop + 22
          \lnDevs=scsLineGadget(1,nTop,gnEditorScaPropertiesInnerWidth-2,1,#SCS_Black,0,"lnDevs") ; the horizontal line immediately above 'Audio Devices'
          \lnLoops=scsLineGadget(400,GadgetY(\lnTimes)+1,1,(GadgetY(\lnDevs)-GadgetY(\lnTimes)-1),#SCS_Grey,0,"lnLoops") ; the vertical line to the left of the loop info area, ie immediately to the right of 'Fade Out Time'
          \lnLoopDetail=scsLineGadget(401,GadgetY(\txtLoopNr)+22,gnEditorScaPropertiesInnerWidth-401,1,#SCS_Light_Grey,0,"lnLoopDetail") ; the horizontal line inside the loop info area, immediately above 'Loop Start', etc
          
          ; audio control
          nHeight = 93
          \cntAudioControls=scsContainerGadget(0,nTop+2,640,nHeight,0,"cntAudioControls")
            
            \cboDevSel=scsComboBoxGadget(6,0,150,21,0,"cboDevSel")
            scsSetGadgetFont(\cboDevSel, #SCS_FONT_GEN_BOLD)
            ignoreMouseWheelEvents(\cboDevSel)
            \lblTracks=scsTextGadget(160,4,43,15,Lang("WQF","lblTracks"),0,"lblTracks")  ; "Tracks"
            \cntLevelLabels=scsContainerGadget(205,0,400,21,0,"cntLevelLabels")
              \lblTrim=scsTextGadget(0,4,46,15,Lang("Common","Trim"),0,"lblTrim")  ; "Trim"
              \lblLevel=scsTextGadget(46,4,120,15,Lang("Common","Level"), #PB_Text_Center,"lblLevel")  ; "Level"
              \lbldB=scsTextGadget(169,4,39,15,"dB", #PB_Text_Center, "lbldB")   ; "dB"
              \lblPan=scsTextGadget(256,4,28,15,Lang("Common","Pan"), #PB_Text_Center, "lblPan")  ; "Pan"
            scsCloseGadgetList()
            \cntRelLevelLabels=scsContainerGadget(205,0,400,21,0,"cntRelLevelLabels")
              \lblInclude=scsTextGadget(0,4,45,15,Lang("WQF","lblInclude"),#PB_Text_Center,"lblInclude")
              \cboLevelSel=scsComboBoxGadget(58,0,150,21,0,"cboLevelSel")
              \cboPanSel=scsComboBoxGadget(212,0,200,21,0,"cboPanSel")
              scsToolTip(\cboLevelSel, Lang("WQF", "LvlPanSelTT"))
              scsToolTip(\cboPanSel, Lang("WQF", "LvlPanSelTT"))
            scsCloseGadgetList()
            setVisible(\cntRelLevelLabels,#False)
            
            nScaLeft = 6
            nScaTop = 22
            nScaWidth = 621
            nDevWidth = 128
            If grLicInfo\nLicLevel >= #SCS_LIC_PRO
              nLeft = 5
              \btnMoveDevUp=scsStandardButton(nLeft,nScaTop,22,22,#SCS_STANDARD_BTN_MOVE_UP,"btnMoveDevUp")
              \btnMoveDevDown=scsStandardButton(nLeft,nScaTop+22,22,22,#SCS_STANDARD_BTN_MOVE_DOWN,"btnMoveDevDown")
              \btnInsertDev=scsStandardButton(nLeft,nScaTop+44,22,22,#SCS_STANDARD_BTN_PLUS,"btnInsertDev")  ; Added 21Mar2022 11.9.1aq
              \btnRemoveDev=scsStandardButton(nLeft,nScaTop+66,22,22,#SCS_STANDARD_BTN_MINUS,"btnRemoveDev") ; Added 21Mar2022 11.9.1aq
              nScaLeft = 30
              nScaWidth - nScaLeft + nLeft + 1
              nDevWidth - nScaLeft + nLeft + 1
            EndIf
            
            nDevInnerHeight = (grLicInfo\nMaxAudDevPerAud + 1) * 22
            nDevInnerWidth = nScaWidth - glScrollBarWidth - gl3DBorderAllowanceX
            \scaDevs=scsScrollAreaGadget(nScaLeft,nScaTop,nScaWidth,87,nDevInnerWidth, nDevInnerHeight, 22, #PB_ScrollArea_BorderLess, "scaDevs")
              For n = 0 To grLicInfo\nMaxAudDevPerAud
                nLeft = 0
                nTop = n * 22
                sNr = "["+n+"]"
                ; nb using a StringGadget rather than a TextGadget for \lblDevNo[n] so we receive an event when the user clicks on the gadget
                \lblDevNo[n]=scsStringGadget(nLeft,nTop+1,19,19,Str(n+1),#PB_String_ReadOnly|#ES_CENTER,"lblDevNo"+sNr)
                SetGadgetColor(\lblDevNo[n], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
                SetGadgetColor(\lblDevNo[n], #PB_Gadget_FrontColor, #SCS_Black)
                \cboLogicalDevF[n]=scsComboBoxGadget(nLeft+22,nTop,nDevWidth,21,0,"cboLogicalDevF"+sNr)
                scsToolTip(\cboLogicalDevF[n],Lang("WQF","cboLogicalDevTT"))
                ignoreMouseWheelEvents(\cboLogicalDevF[n], grLicInfo\nMaxAudDevPerAud)
                \cboTracks[n]=scsComboBoxGadget(gnNextX+3,nTop,43,21,0,"cboTracks"+sNr)
                \cntDevLevel[n]=scsContainerGadget(gnNextX,nTop,218,21,0,"cntDevLevel"+sNr)
                  \cboTrim[n]=scsComboBoxGadget(0,0,43,21,0,"cboTrim"+sNr)
                  \sldLevel[n]=SLD_New("QF_Level_"+Str(n+1),\cntDevLevel[n],0,45,0,129,21,#SCS_ST_HLEVELNODB,0,10000)
                  \txtDBLevel[n]=scsStringGadget(174,0,44,21,"",0,"txtDBLevel"+sNr)
                scsCloseGadgetList()
                \cntDevRelLevel[n]=scsContainerGadget(GadgetX(\cntDevLevel[n]),nTop,218,21,0,"cntDevRelLevel"+sNr)
                  \chkDevInclude[n]=scsCheckBoxGadget2(16,3,18,17,"",0,"chkDevInclude"+sNr)
                  scsToolTip(\chkDevInclude[n],Lang("WQF","chkDevIncludeTT"))
                  \txtDevDBLevel[n]=scsStringGadget(63,0,44,21,"",0,"txtDevDBLevel"+sNr)
                  setEnabled(\txtDevDBLevel[n], #False)
                  setTextBoxBackColor(\txtDevDBLevel[n])
                  \txtRelDBLevel[n]=scsStringGadget(108,0,44,21,"",0,"txtRelDBLevel"+sNr)
                  scsToolTip(\txtRelDBLevel[n],Lang("WQF","txtRelDBLevel"))
                  \txtPlayDBLevel[n]=scsStringGadget(153,0,52,21,"",0,"txtPlayDBLevel"+sNr)
                  setEnabled(\txtPlayDBLevel[n], #False)
                  setTextBoxBackColor(\txtPlayDBLevel[n])
                scsCloseGadgetList()
                setVisible(\cntDevRelLevel[n],#False)
                nLeft = GadgetX(\cntDevRelLevel[n]) + GadgetWidth(\cntDevRelLevel[n]) + 2
                \sldPan[n]=SLD_New("QF_Pan_"+Str(n+1),\scaDevs,0,nLeft,nTop,105,21,#SCS_ST_PAN)
                \btnCenter[n]=scsButtonGadget(gnNextX,nTop,46,21,Lang("Btns","Center"),0,"btnCenter"+sNr)
                scsToolTip(\btnCenter[n],Lang("Btns","CenterTT"))
                \txtPan[n]=scsStringGadget(gnNextX+2,nTop,33,21,"",#PB_String_Numeric,"txtPan"+sNr)
              Next n
            scsCloseGadgetList()
            setEnabled(WQF\scaDevs, #True)
            
          scsCloseGadgetList()  ; \cntAudioControls
          
          ; test
          nTop = GadgetY(\cntAudioControls) + GadgetHeight(\cntAudioControls) + 5
          \cntTest=scsContainerGadget(10,nTop,616,40,#PB_Container_Flat,"cntTest")
            
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            
            \lblTestCue=scsTextGadget(4,5,26,15,Lang("Common","Test"), #PB_Text_Right,"lblTestCue") ; "Test"
            scsSetGadgetFont(\lblTestCue, #SCS_FONT_GEN_BOLDUL)
            SetGadgetColors(\lblTestCue, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblTestCue, #False)
            
            ; transport controls
            \btnEditRewind=scsStandardButton(37,1,24,24,#SCS_STANDARD_BTN_REWIND,"btnEditRewind")
            \btnEditPlay=scsStandardButton(61,1,24,24,#SCS_STANDARD_BTN_PLAY,"btnEditPlay")
            \btnEditPause=scsStandardButton(61,1,24,24,#SCS_STANDARD_BTN_PAUSE,"btnEditPause")
            setVisible(\btnEditPause, #False)
            \btnEditRelease=scsStandardButton(85,1,24,24,#SCS_STANDARD_BTN_RELEASE,"btnEditRelease")
            \btnEditFadeOut=scsStandardButton(109,1,24,24,#SCS_STANDARD_BTN_FADEOUT,"btnEditFadeOut")
            \btnEditStop=scsStandardButton(133,1,24,24,#SCS_STANDARD_BTN_STOP,"btnEditStop")
            
            \lblInfo=scsTextGadget(157,5,80,18,"", #PB_Text_Center,"lblInfo")
            SetGadgetColors(\lblInfo, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblInfo, #False)
            
            ; \lblOtherInfo=scsTextGadget(0,25,293,15,"", #PB_Text_Center,"lblOtherInfo")
            \lblOtherInfo=scsTextGadget(0,25,293,15,"",0,"lblOtherInfo") ; Removed #PB_Text_Center 30Mar2022 11.9.1ax
            SetGadgetColors(\lblOtherInfo, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblOtherInfo, #False)
            
            \sldProgress=SLD_New("QF_Progress",\cntTest,0,237,3,375,21,#SCS_ST_PROGRESS,0,1000)
            
          scsCloseGadgetList() ; cntTest
          
        scsCloseGadgetList()
        
      scsCloseGadgetList()
      
      scsOpenGadgetList(WED\cntSpecialQF)
        debugMsg(sProcName,"WindowWidth(#WED)=" + WindowWidth(#WED) + ", GadgetWidth(WED\cntSpecialQF)=" + GadgetWidth(WED\cntSpecialQF))
        ; graph display
        ; nb width calculations below should be the same as used in WQF_adjustForSplitterSize()
        nWidth = GadgetWidth(WED\cntSpecialQF) - gl3DBorderAllowanceX
        nHeight = GadgetHeight(WED\cntSpecialQF)
        \cntGraphDisplay=scsContainerGadget(0,0,nWidth,nHeight,#PB_Container_Flat,"cntGraphDisplay")
          nLeft = 0
          nTop = 0
          nWidth = 38
          nHeight = 148
          \cvsSideLabels=scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0,"cvsSideLabels")
          nWidth = GadgetWidth(\cntGraphDisplay) - GadgetWidth(\cvsSideLabels) - GadgetX(\cvsSideLabels) - 2 ; 2 pixels to allow for 'flat' border of \cntGraphDisplay
          \cntGraph=scsContainerGadget(gnNextX,nTop,nWidth,nHeight,0,"cntGraph")
            CompilerIf #PB_Compiler_Debugger
              \cvsGraph=scsCanvasGadget(0,0,nWidth,nHeight,#PB_Canvas_Keyboard,"cvsGraph")
            CompilerElse
              \cvsGraph=scsCanvasGadget(0,0,nWidth,nHeight,#PB_Canvas_ClipMouse|#PB_Canvas_Keyboard,"cvsGraph")
            CompilerEndIf
          scsCloseGadgetList()
          
          nTop = GadgetY(\cntGraph) + GadgetHeight(\cntGraph) + 2
          \lblGraphDev=scsTextGadget(4,nTop+2,120,18,LangPars("WQF","lblGraphDev","Front R"),0,"lblGraphDev")
          scsSetGadgetFont(\lblGraphDev, #SCS_FONT_GEN_NORMAL10)
          nWidth = GadgetWidth(\lblGraphDev, #PB_Gadget_RequiredSize)
          ResizeGadget(\lblGraphDev,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
          SGT(\lblGraphDev,"")
          \nMaxGraphDevWidth = nWidth
          setReverseEditorColors(\lblGraphDev, #True)
          nLeft = GadgetX(\lblGraphDev) + GadgetWidth(\lblGraphDev) + 12
          \lblZoom=scsTextGadget(nLeft,nTop+4,40,15,Lang("WQF","lblZoom"),#PB_Text_Right,"lblZoom")
          setGadgetWidth(\lblZoom)
          nLeft = GadgetX(\lblZoom) + GadgetWidth(\lblZoom) + gnGap
          ; \trbZoom=scsTrackBarGadget(nLeft,nTop,120,23,1,20,#PB_TrackBar_Ticks,"trbZoom")   ; allow up to 20 steps
          \trbZoom=scsTrackBarGadget(nLeft,nTop,120,23,1,100,0,"trbZoom") ; allow up to 100 steps
          \btnViewPlayable=scsButtonGadget(gnNextX+8,nTop+2,80,20,Lang("WQF","btnViewPlayable"),0,"btnViewPlayable") ; "View Playable" button
          scsToolTip(\btnViewPlayable,Lang("WQF","btnViewPlayableTT"))
          setGadgetWidth(\btnViewPlayable)
          nLeft = GadgetX(\btnViewPlayable) + GadgetWidth(\btnViewPlayable) + 8
          \btnViewAll=scsButtonGadget(nLeft,nTop+2,80,20,Lang("WQF","btnViewAll"),0,"btnViewAll")  ; "View All" button
          scsToolTip(\btnViewAll,Lang("WQF","btnViewAllTT"))
          setGadgetWidth(\btnViewAll)
          nLeft = GadgetX(\btnViewAll) + GadgetWidth(\btnViewAll) + 8
          \lblPosition=scsTextGadget(nLeft,nTop+4,40,15,Lang("WQF","lblPosition"), #PB_Text_Right,"lblPosition")
          \sldPosition=SLD_New("QF_Position",\cntGraphDisplay,0,gnNextX+gnGap,nTop+2,120,18,#SCS_ST_HSCROLLBAR,0,10000)
          SLD_setPageLength(\sldPosition, 1000)
          \chkAutoScroll=scsCheckBoxGadget2(gnNextX+19,nTop+2,90,17,Lang("WQF","chkAutoScroll"),0,"chkAutoScroll")
          nReqdWidth = getGadgetReqdWidth(sProcName, \chkAutoScroll)
          ResizeGadget(\chkAutoScroll,#PB_Ignore,#PB_Ignore,nReqdWidth,#PB_Ignore)
          drawCheckBoxGadget2(\chkAutoScroll)
          gnNextX = GadgetX(\chkAutoScroll) + GadgetWidth(\chkAutoScroll)
          \cboGraphDisplayMode=scsComboBoxGadget(gnNextX+12,nTop,90,21,0,"cboGraphDisplayMode")
          scsToolTip(\cboGraphDisplayMode, Lang("WQF", "cboGraphDisplayModeTT"))
          
        scsCloseGadgetList()    ; cntGraphDisplay
      scsCloseGadgetList()
      
      If scsCreatePopupMenu(#WQF_mnu_GraphContextMenu)
        If (grLicInfo\bStartEndAvailable) Or (grLicInfo\bAudFileLoopsAvailable)
          If grLicInfo\bStartEndAvailable
            scsMenuItem(#WQF_mnu_SetStartAt, "mnuWQFSetStartAt")
            scsMenuItem(#WQF_mnu_SetEndAt, "mnuWQFSetEndAt")
          EndIf
          If grLicInfo\bAudFileLoopsAvailable
            scsMenuItem(#WQF_mnu_SetLoopStart, "mnuWQFSetLoopStart")
            scsMenuItem(#WQF_mnu_SetLoopEnd, "mnuWQFSetLoopEnd")
          EndIf
        EndIf
        OpenSubMenu(Lang("Menu", "mnuLevelPoints"))
          scsMenuItem(#WQF_mnu_AddFadeInLvlPt, "mnuWQFAddFadeInLvlPt")
          If grLicInfo\bStdLvlPtsAvailable
            scsMenuItem(#WQF_mnu_AddStdLvlPt, "mnuWQFAddStdLvlPt")
          EndIf
          scsMenuItem(#WQF_mnu_AddFadeOutLvlPt, "mnuWQFAddFadeOutLvlPt")
          scsMenuItem(#WQF_mnu_SetPos, "mnuWQFSetPos")
          If grLicInfo\bStdLvlPtsAvailable
            scsMenuItem(#WQF_mnu_RemoveLvlPt, "mnuWQFRemoveLvlPt")
            MenuBar()
            scsMenuItem(#WQF_mnu_SameLvlAsPrev, "mnuWQFSameLvlAsPrev")
            scsMenuItem(#WQF_mnu_SameLvlAsNext, "mnuWQFSameLvlAsNext")
            scsMenuItem(#WQF_mnu_SamePanAsPrev, "mnuWQFSamePanAsPrev")
            scsMenuItem(#WQF_mnu_SamePanAsNext, "mnuWQFSamePanAsNext")
            scsMenuItem(#WQF_mnu_SameAsPrev, "mnuWQFSameAsPrev")
            scsMenuItem(#WQF_mnu_SameAsNext, "mnuWQFSameAsNext")
          EndIf
        CloseSubMenu()
        If grLicInfo\bCueMarkersAvailable
          ; MenuBar()
          OpenSubMenu(Lang("Menu", "mnuCueMarkers"))
            scsMenuItem(#WQF_mnu_AddQuickCueMarkers, "mnuWQFAddQuickCueMarker")
            scsMenuItem(#WQF_mnu_EditCueMarker, "mnuWQFEditCueMarker")
            scsMenuItem(#WQF_mnu_SetCueMarkerPos, "mnuWQFSetCueMarkerPos")
            scsMenuItem(#WQF_mnu_RemoveCueMarker, "mnuWQFRemoveCueMarker")
            MenuBar()
            scsMenuItem(#WQF_mnu_RemoveAllUnusedCueMarkersFromThisFile, "mnuWQFRemoveAllUnusedCueMarkersThisFile")
            scsMenuItem(#WQF_mnu_RemoveAllUnusedCueMarkers, "mnuWQFRemoveAllUnusedCueMarkers")
            scsMenuItem(#WQF_mnu_ViewOnCues, "mnuWQFViewOnCues")
            scsMenuItem(#WQF_mnu_ViewCueMarkersUsage, "mnuWQFViewCueMarkersUsage")
          CloseSubMenu()
        EndIf
      EndIf
      
      If scsCreatePopupMenu(#WQF_mnu_Other)
        debugMsg(sProcName, "populating PopupMenu #WQF_mnu_Other")
        scsMenuItem(#WQF_mnu_ResetAll, "mnuWQFResetAll")
        scsMenuItem(#WQF_mnu_ClearAll, "mnuWQFClearAll")
        MenuBar()
        scsMenuItem(#WQF_mnu_StartTrimSilence, "mnuWQFStartTrimSilence")
        scsMenuItem(#WQF_mnu_StartTrim75, LangPars("Menu", "mnuWQFStartTrimDB", "-75dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQF_mnu_StartTrim60, LangPars("Menu", "mnuWQFStartTrimDB", "-60dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQF_mnu_StartTrim45, LangPars("Menu", "mnuWQFStartTrimDB", "-45dB"), "", #False)
        scsMenuItem(#WQF_mnu_StartTrim30, LangPars("Menu", "mnuWQFStartTrimDB", "-30dB"), "", #False)
        MenuBar()
        scsMenuItem(#WQF_mnu_EndTrimSilence, "mnuWQFEndTrimSilence")
        scsMenuItem(#WQF_mnu_EndTrim75, LangPars("Menu", "mnuWQFEndTrimDB", "-75dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQF_mnu_EndTrim60, LangPars("Menu", "mnuWQFEndTrimDB", "-60dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQF_mnu_EndTrim45, LangPars("Menu", "mnuWQFEndTrimDB", "-45dB"), "", #False)
        scsMenuItem(#WQF_mnu_EndTrim30, LangPars("Menu", "mnuWQFEndTrimDB", "-30dB"), "", #False)
        If grLicInfo\bTempoAndPitchAvailable
          MenuBar()
          scsMenuItem(#WQF_mnu_ChangeFreqTempoPitch, LangEllipsis("Menu", "mnuWQFChangeFreqTempoPitch"), "", #False)
        EndIf
        If grLicInfo\bDevLinkAvailable
          MenuBar()
          scsMenuItem(#WQF_mnu_CallLinkDevs, LangEllipsis("Menu", "mnuWQFLinkDevs"), "", #False)
        EndIf
        MenuBar()
        scsMenuItem(#WQF_mnu_RenameFile, LangEllipsis("Menu", "mnuWQFRenameFile"), "", #False)
        If grLicInfo\bExternalEditorsIncluded
          MenuBar()
          scsMenuItem(#WQF_mnu_ExternalAudioEditor, LangEllipsis("Menu", "mnuWQFExternalAudioEditor"), "", #False)
        EndIf
      EndIf
      
      setEnabled(WQF\scaSoundFile, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQFCreated = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Structure strWQG ; fmEditQG
  SUBCUE_HEADER_FIELDS()
  cboCueToGoTo.i
  cntSubDetailG.i
  lblCueToGoTo.i
  optStartOption.i[2]
  scaGoTo.i
EndStructure
Global WQG.strWQG ; fmEditQG

Procedure createfmEditQG()
  PROCNAMEC()
  Protected nTop, nHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQG
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQG
      \scaGoTo=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaGoTo")
        setVisible(\scaGoTo, #False)
        ; header
        SUBCUE_HEADER_CODE(WQG)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailG=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailG")
          
          \lblCueToGoTo=scsTextGadget(12,29,164,15,Lang("WQG","lblCueToGoTo"), #PB_Text_Right,"lblCueToGoTo")
          \cboCueToGoTo=scsComboBoxGadget(183,25,300,21,0,"cboCueToGoTo")
          ; scsToolTip(\cboCueToGoTo,Lang("WQG","cboCueToGoToTT"))
          \optStartOption[0]=scsOptionGadget2(183,54,-1,17,Lang("WQG","optStartOption[0]"),"optStartOption[0]")
          \optStartOption[1]=scsOptionGadget2(183,74,-1,17,Lang("WQG","optStartOption[1]"),"optStartOption[1]")
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaGoTo
      
      ; setVisible(WQG\scaGoTo, #True)
      setEnabled(WQG\scaGoTo, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQGCreated = #True
  
EndProcedure


Structure strWQI ; fmEditQI
  SUBCUE_HEADER_FIELDS()
  btnCenter.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  btnEditFadeOut.i
  btnEditPause.i
  btnEditPlay.i
  btnEditStop.i
  btnFadeInTime.i
  btnFadeOutTime.i
  cboFadeType.i[2]
  cboInGrp.i
  cboInputLogicalDev.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  cboLogicalDev.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cboTrim.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  chkMuteAllInputs.i
  chkMuteInput.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cntAudioControls.i
  cntInputDevs.i
  cntOnOff.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cntSubDetailI.i
  cntTest.i
  lbldB.i
  lblDevNo.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblInputDb.i
  lblInputDevice.i
  lblInputDevNo.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  lblFadeInTime.i
  lblFadeOutTime.i
  lblInfo.i
  lblInGrp.i
  lblInputLevel.i
  lblLevel.i
  lblOff.i
  lblOn.i
  lblPan.i
  lblSoundDevice.i
  lblTestCue.i
  lblTrim.i
  optOff.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  optOn.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  scaAudioDevs.i
  scaInputDevs.i
  scaLiveInput.i
  sldInputLevel.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  sldLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtInputDBLevel.i[#SCS_MAX_LIVE_INPUT_DEV_PER_AUD+1]
  txtFadeInTime.i
  txtFadeOutTime.i
  txtPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
EndStructure
Global WQI.strWQI ; fmEditQI

Procedure createfmEditQI()
  PROCNAMEC()
  Protected n, nLeft, nTop, sNr.s
  Protected nDevInnerWidth, nDevInnerHeight
  Protected nWidth, nHeight, nScrollAreaHeight
  Protected sBtnText.s
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQI
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQI
      \scaLiveInput=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaLiveInput")
        setVisible(\scaLiveInput, #False)
        ; header
        SUBCUE_HEADER_CODE(WQI)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailI=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailI")
          
          ; live inputs
          \cntInputDevs=scsContainerGadget(0,0,640,236,#PB_Container_Flat,"cntInputDevs")
            nTop = 6
            \lblInputDevice=scsTextGadget(10,nTop,146,15,Lang("WQI","lblInputDevice"),0,"lblInputDevice")  ; "Live Inputs"
            ; scsSetGadgetFont(\lblInputDevice, #SCS_FONT_GEN_BOLD)
            \lblOn=scsTextGadget(gnNextX+12,nTop+1,30,15,Lang("WQI","lblOn"),0,"lblOn")
            \lblOff=scsTextGadget(gnNextX,nTop+1,30,15,Lang("WQI","lblOff"),0,"lblOff")
            \lblInputLevel=scsTextGadget(gnNextX+12,nTop+1,129,15,Lang("Common","Level"), #PB_Text_Center,"lblInputLevel")  ; "Level"
            \lblInputDb=scsTextGadget(gnNextX+1,nTop+1,52,15,"dB", #PB_Text_Center, "lblInputDb")   ; "dB"
            
            nTop + 16
            nDevInnerHeight = (grLicInfo\nMaxLiveDevPerAud + 1) * 22
            nDevInnerWidth = 621 - glScrollBarWidth - gl3DBorderAllowanceX
            \scaInputDevs=scsScrollAreaGadget(5,nTop,621,176,nDevInnerWidth, nDevInnerHeight, 30, #PB_ScrollArea_BorderLess, "scaInputDevs")
              For n = 0 To grLicInfo\nMaxLiveDevPerAud
                nTop = n * 22
                sNr = "["+n+"]"
                \lblInputDevNo[n]=scsTextGadget(0,nTop+4,17,15,Str(n+1), #PB_Text_Right, "lblInputDevNo"+sNr)
                \cboInputLogicalDev[n]=scsComboBoxGadget(gnNextX+8,nTop,127,21,0,"cboInputLogicalDev"+sNr)
                scsToolTip(\cboInputLogicalDev[n],Lang("WQI","cboInputLogicalDevTT"))
                \cntOnOff[n]=scsContainerGadget(gnNextX+11,nTop,60,17,0,"cntOnOff"+sNr)
                  \optOn[n]=scsOptionGadget2(0,0,17,17,"","optOn"+sNr)
                  \optOff[n]=scsOptionGadget2(gnNextX+13,0,17,17,"","optOff"+sNr)
                  ; setOwnState(\optOn[n],#True)
                scsCloseGadgetList()
                nLeft = GadgetX(\cntOnOff[n]) + GadgetWidth(\cntOnOff[n]) + 8
                ; \cboTrim[n]=scsComboBoxGadget(gnNextX+7,nTop,43,21,0,"cboTrim"+sNr)
                \sldInputLevel[n]=SLD_New("QI_Input_Level_"+Str(n+1),\scaInputDevs,0,nLeft,nTop,129,21,#SCS_ST_HLEVELNODB,0,10000)
                \txtInputDBLevel[n]=scsStringGadget(gnNextX+1,nTop,52,21,"",0,"txtInputDBLevel"+sNr)
                ; \chkMuteInput[n]=scsCheckBoxGadget2(gnNextX+20,nTop,17,17,"",0,"chkMuteInput"+sNr)
              Next n
            scsCloseGadgetList()
            setEnabled(WQI\scaInputDevs, #True)
            
            nTop = GadgetY(\scaInputDevs) + GadgetHeight(\scaInputDevs) + 8
            \lblInGrp=scsTextGadget(4,nTop+gnLblVOffsetS,220,15,Lang("WQI","lblInGrp"),#PB_Text_Right,"lblInGrp")  ; "Add Live Input Devices from Input Group"
            \cboInGrp=scsComboBoxGadget(gnNextX+gnGap,nTop,100,21,0,"cboInGrp")
          scsCloseGadgetList()
          
          ; audio control
          nTop = GadgetY(\cntInputDevs) + GadgetHeight(\cntInputDevs)
          \cntAudioControls=scsContainerGadget(0,nTop,640,140,#PB_Container_Flat,"cntAudioControls")
            
            nLeft = 80
            nTop = 4
            nWidth = 56
            sBtnText = "»"
            \lblFadeInTime=scsTextGadget(nLeft,nTop+gnLblVOffsetS,120,15,Lang("WQI","lblFadeInTime2"),#PB_Text_Right,"lblFadeInTime")  ; "Fade In Time" ; Changed 25Jan2023 11.9.9ac
            \txtFadeInTime=scsStringGadget(gnNextX+7,nTop,nWidth,21,"",0,"txtFadeInTime")
            scsToolTip(\txtFadeInTime,Lang("WQI","txtFadeInTimeTT"))
            \btnFadeInTime=scsButtonGadget(gnNextX,nTop,14,21,sBtnText,0,"btnFadeInTime")
            
            \lblFadeOutTime=scsTextGadget(gnNextX+2,nTop+gnLblVOffsetS,120,15,Lang("WQI","lblFadeOutTime2"),#PB_Text_Right,"lblFadeOutTime")  ; "Fade Out Time" ; Changed 25Jan2023 11.9.9ac
            \txtFadeOutTime=scsStringGadget(gnNextX+7,nTop,nWidth,21,"",0,"txtFadeOutTime")
            scsToolTip(\txtFadeOutTime,Lang("WQI","txtFadeOutTimeTT"))
            \btnFadeOutTime=scsButtonGadget(gnNextX,nTop,14,21,sBtnText,0,"btnFadeOutTime")
            
            nTop + 25
            \lblSoundDevice=scsTextGadget(10,nTop,142,15,Lang("WQI","lblSoundDevice"),0,"lblSoundDevice")  ; "Audio Devices"
            scsSetGadgetFont(\lblSoundDevice, #SCS_FONT_GEN_BOLD)
            ; \lblTrim=scsTextGadget(gnNextX+gnGap,nTop+1,39,15,Lang("Common","Trim"), #PB_Text_Center,"lblTrim")  ; "Trim"
            \lblLevel=scsTextGadget(gnNextX+gnGap,nTop+1,129,15,Lang("Common","Level"), #PB_Text_Center,"lblLevel")  ; "Level"
            \lbldB=scsTextGadget(gnNextX+1,nTop+1,52,15,"dB", #PB_Text_Center, "lbldB")   ; "dB"
            \lblPan=scsTextGadget(gnNextX+7,nTop+1,105,15,Lang("Common","Pan"), #PB_Text_Center, "lblPan")  ; "Pan"
            
            nTop + 16
            nDevInnerHeight = (grLicInfo\nMaxAudDevPerAud + 1) * 22
            nDevInnerWidth = 621 - glScrollBarWidth - gl3DBorderAllowanceX
            \scaAudioDevs=scsScrollAreaGadget(5,nTop,621,87,nDevInnerWidth, nDevInnerHeight, 30, #PB_ScrollArea_BorderLess, "scaAudioDevs")
              For n = 0 To grLicInfo\nMaxAudDevPerAud
                nTop = n * 22
                sNr = "["+n+"]"
                \lblDevNo[n]=scsTextGadget(0,nTop+4,17,15,Str(n+1), #PB_Text_Right, "lblDevNo"+sNr)
                \cboLogicalDev[n]=scsComboBoxGadget(gnNextX+8,nTop,127,21,0,"cboLogicalDev"+sNr)
                scsToolTip(\cboLogicalDev[n],Lang("WQI","cboLogicalDevTT"))
                ; \cboTrim[n]=scsComboBoxGadget(gnNextX+7,nTop,43,21,0,"cboTrim"+sNr)
                \sldLevel[n]=SLD_New("QI_Level_"+Str(n+1),\scaAudioDevs,0,gnNextX+gnGap,nTop,129,21,#SCS_ST_HLEVELNODB,0,10000)
                \txtDBLevel[n]=scsStringGadget(gnNextX+1,nTop,52,21,"",0,"txtDBLevel"+sNr)
                \sldPan[n]=SLD_New("QI_Pan_"+Str(n+1),\scaAudioDevs,0,gnNextX+7,nTop,105,21,#SCS_ST_PAN)
                \btnCenter[n]=scsButtonGadget(gnNextX+2,nTop,46,21,Lang("Btns","Center"),0,"btnCenter"+sNr)
                scsToolTip(\btnCenter[n],Lang("Btns","CenterTT"))
                \txtPan[n]=scsStringGadget(gnNextX+1,nTop,52,21,"",#PB_String_Numeric,"txtPan"+sNr)
              Next n
            scsCloseGadgetList()
            setEnabled(WQI\scaAudioDevs, #True)
            
          scsCloseGadgetList()  ; cntAudioControl
          
          ; test
          nTop = GadgetY(\cntAudioControls) + GadgetHeight(\cntAudioControls) + 4
          \cntTest=scsContainerGadget(10,nTop,616,40,#PB_Container_Flat,"cntTest")
            
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            
            \lblTestCue=scsTextGadget(4,5,26,15,Lang("Common","Test"), #PB_Text_Right,"lblTestCue") ; "Test"
            scsSetGadgetFont(\lblTestCue, #SCS_FONT_GEN_BOLDUL)
            SetGadgetColors(\lblTestCue, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblTestCue, #False)
            
            ; transport controls
            \btnEditPlay=scsStandardButton(61,1,24,24,#SCS_STANDARD_BTN_PLAY,"btnEditPlay")
            \btnEditPause=scsStandardButton(61,1,24,24,#SCS_STANDARD_BTN_PAUSE,"btnEditPause")
            setVisible(\btnEditPause, #False)
            \btnEditFadeOut=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_FADEOUT,"btnEditFadeOut")
            \btnEditStop=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_STOP,"btnEditStop")
            
            \lblInfo=scsTextGadget(157,5,200,18,"",0,"lblInfo")
            SetGadgetColors(\lblInfo, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblInfo, #False)
            
          scsCloseGadgetList() ; cntTest
          
        scsCloseGadgetList()  ; cntSubDetailI
        
      scsCloseGadgetList() ; scaLiveInput
      
      ; setVisible(WQI\scaLiveInput, #True)
      setEnabled(WQI\scaLiveInput, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQICreated = #True
  
EndProcedure

Structure strWQJ ; fmEditQJ
  SUBCUE_HEADER_FIELDS()
  cboFirstCue.i[#SCS_MAX_ENABLE_DISABLE+1]
  cboLastCue.i[#SCS_MAX_ENABLE_DISABLE+1]
  cntAction.i[#SCS_MAX_ENABLE_DISABLE+1]
  cntCues.i
  cntSubDetailJ.i
  lblDash.i[#SCS_MAX_ENABLE_DISABLE+1]
  lblFirstCue.i
  lblLastCue.i
  lblListHdr.i
  lblRangeNo.i[#SCS_MAX_ENABLE_DISABLE+1]
  optDisable.i[#SCS_MAX_ENABLE_DISABLE+1]
  optEnable.i[#SCS_MAX_ENABLE_DISABLE+1]
  scaEnableDisable.i
EndStructure
Global WQJ.strWQJ ; fmEditQJ

Procedure createfmEditQJ()
  PROCNAMEC()
  Protected nLeft, nTop, nHeight, sNr.s
  Protected n
  Protected sEnable.s, sDisable.s
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQJ
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    sEnable = Lang("WQJ", "optEnable")
    sDisable = Lang("WQJ", "optDisable")
    
    With WQJ
      \scaEnableDisable=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaEnableDisable")
        setVisible(\scaEnableDisable, #False)
        ; header
        SUBCUE_HEADER_CODE(WQJ)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailJ=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailJ")
          nTop = 20
          \lblListHdr=scsTextGadget(28,nTop,220,15,Lang("WQJ","lblListHdr"),0,"lblListHdr")
          scsSetGadgetFont(\lblListHdr, #SCS_FONT_GEN_NORMAL10)
          nTop + 20
          \lblFirstCue=scsTextGadget(156,nTop,220,15,Lang("WQJ","lblFirstCue"),0,"lblFirstCue")
          \lblLastCue=scsTextGadget(gnNextX+24,nTop,220,15,Lang("WQJ","lblLastCue") + " (" + grText\sTextOptional + ")",0,"lblLastCue")
          nTop + 18
          \cntCues=scsContainerGadget(0,nTop,GadgetWidth(\cntSubDetailJ),(30*(#SCS_MAX_ENABLE_DISABLE+1)),0, "cntCues")
            For n = 0 To #SCS_MAX_ENABLE_DISABLE
              nTop = n * 28
              sNr = "[" + n + "]"
              \lblRangeNo[n]=scsTextGadget(8,nTop+gnLblVOffsetS,16,17,Str(n+1),#PB_Text_Right,"lblRangeNo"+sNr)
              \cntAction[n]=scsContainerGadget(gnNextX+8,nTop,120,21,0,"cntAction"+sNr)
                \optEnable[n]=scsOptionGadget2(0,0,60,21,sEnable,"optEnable"+sNr)
                \optDisable[n]=scsOptionGadget2(gnNextX,0,60,21,sDisable,"optDisable"+sNr)
              scsCloseGadgetList()
              nLeft = GadgetX(\cntAction[n]) + GadgetWidth(\cntAction[n])
              \cboFirstCue[n]=scsComboBoxGadget(nLeft,nTop,220,21,0,"cboFirstCue"+sNr)
              \lblDash[n]=scsTextGadget(gnNextX,nTop,24,21,"-",#PB_Text_Center,"cboDash"+sNr)
              scsSetGadgetFont(\lblDash[n], #SCS_FONT_GEN_BOLD12) ; make dash larger
              \cboLastCue[n]=scsComboBoxGadget(gnNextX,nTop,220,21,0,"cboLastCue"+sNr)
            Next n
          scsCloseGadgetList()
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaEnableDisable
      
      ; setVisible(WQJ\scaEnableDisable, #True)
      setEnabled(WQJ\scaEnableDisable, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQJCreated = #True
  
EndProcedure

Structure strFix
  cboFixture.i
EndStructure

Structure strFix1
  cboFixture1.i
  chkFixtureChanApplyFadeTime1.i
  chkFixtureChanIncluded1.i
  cvsFixtureNo1.i
  sldFixtureChannelValue1.i
  txtFixtureChannel1.i
  txtFixtureChannelValue1.i
  txtFixtureLinkGroup1.i
EndStructure

Structure strWQK ; fmEditQK
  SUBCUE_HEADER_FIELDS()
  Array aFix.strFix(0)
  Array aFix1.strFix1(0)
  btnNextStep.i
  btnPrevStep.i
  btnReset.i
  cboBLFadeAction.i
  cboChaseMode.i
  cboDCFadeDownAction.i
  cboDCFadeOutOthersAction.i
  cboDCFadeUpAction.i
  cboDefFadeAction.i
  cboDIFadeDownAction.i
  cboDIFadeOutOthersAction.i
  cboDIFadeUpAction.i
  cboDisplayMode.i
  cboEntryType.i
  cboFIFadeDownAction.i
  cboFIFadeOutOthersAction.i
  cboFIFadeUpAction.i
  cboFixture.i[#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB+1]
  cboFixtureDisplay.i
  cboLogicalDev.i
  chkApplyCurrValuesAsMins.i
  chkChase.i
  chkDoNotBlackoutOthers.i
  chkFixtureChanApplyFadeTime.i[#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB+1]
  chkFixtureChanIncluded.i[#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB+1]
  chkInclude.i
  chkLiveDMXTest.i
  chkMonitorTapDelay.i
  chkNextLTStopsChase.i
  chkSingleStep.i
  cntBLFade.i
  cntChase.i
  cntChaseStep.i
  cntDCFadeDown.i
  cntDCFadeOutOthers.i
  cntDCFadeUp.i
  cntDIFadeDown.i
  cntDIFadeOutOthers.i
  cntDIFadeUp.i
  cntDMX.i
  cntDMXValues.i
  cntFIFadeDown.i
  cntFIFadeOutOthers.i
  cntFIFadeUp.i
  cntFades.i
  cntFixtures.i
  cntFixtures1.i
  cntItems.i
  cntLightingSideBar.i
  cntSubDetailK.i
  cntTest.i
  cntTestBtns.i
  cvsCaptureButton.i
  cvsCapturingDMXLight.i
  cvsChaseStep.i
  cvsFixtureNo.i[#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB+1]
  imgQKButtonTBS.i[6]
  lblBLFadeAction.i
  lblBLFadeSeconds.i
  lblCaptureInfoMsg.i
  lblCapturingDMX.i
  lblChaseMode.i
  lblChaseSpeed.i
  lblChaseSteps.i
  lblDCFadeDownAction.i
  lblDCFadeDownSeconds.i
  lblDCFadeDownTime.i
  lblDCFadeOutOthersAction.i
  lblDCFadeOutOthersSeconds.i
  lblDCFadeOutOthersTime.i
  lblDCFadeUpAction.i
  lblDCFadeUpSeconds.i
  lblDCFadeUpTime.i
  lblDIFadeDownAction.i
  lblDIFadeDownSeconds.i
  lblDIFadeDownTime.i
  lblDIFadeOutOthersAction.i
  lblDIFadeOutOthersSeconds.i
  lblDIFadeOutOthersTime.i
  lblDIFadeUpAction.i
  lblDIFadeUpSeconds.i
  lblDIFadeUpTime.i
  lblDMXItems.i
  lblDMXValue.i
  lblDMXValue2.i
  lblDMXValue21.i
  lblDMXValues.i
  lblDefFadeAction.i
  lblDisplayMode.i
  lblEntryType.i
  lblFIFadeDownAction.i
  lblFIFadeDownSeconds.i
  lblFIFadeDownTime.i
  lblFIFadeOutOthersAction.i
  lblFIFadeOutOthersSeconds.i
  lblFIFadeOutOthersTime.i
  lblFIFadeUpAction.i
  lblFIFadeUpSeconds.i
  lblFIFadeUpTime.i
  lblFade.i
  lblFade1.i
  lblFixtureDisplay.i
  lblFixtureLinkGroup.i
  lblFixtureLinkGroup1.i
  lblFixtures.i
  lblFixtures1.i
  lblInclude.i
  lblInclude1.i
  lblInfo.i
  lblLogicalDev.i
  lnFixtureChannels.i
  scaDMXItems.i
  scaFixtureChans.i
  scaFixtures.i
  scaFixtures1.i
  scaLighting.i
  sldFixtureChannelValue.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  txtBLFadeTime.i
  txtChaseSpeed.i
  txtChaseSteps.i
  txtDCFadeDownTime.i
  txtDCFadeOutOthersTime.i
  txtDCFadeUpTime.i
  txtDIFadeDownTime.i
  txtDIFadeOutOthersTime.i
  txtDIFadeUpTime.i
  txtDMXValues.i
  txtFIFadeDownTime.i
  txtFIFadeOutOthersTime.i
  txtFIFadeUpTime.i
  txtFixtureChannel.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  txtFixtureChannelValue.i[#SCS_MAX_FIX_TYPE_CHANNEL]
  txtFixtureLinkGroup.i[#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB+1]
EndStructure
Global WQK.strWQK ; fmEditQK

Structure strWQKItem
  nItemId.i
  cntItem.i
  cvsItemNo.i
  sldDMXValue.i
  txtDMXItemStr.i
  sDMXItemStr.s
  nDMXDisplayValue.i
  bSelected.i
  nRowNo.i
EndStructure
Global NewList WQKItem.strWQKItem()

Procedure createWQKItem()
  ; creates a new 'DMX Item', after the currently selected element
  ; PROCNAMECS(nEditSubPtr)
  Protected nListIndex, nTop, nHeight, sItemId.s
  Static sItemStringTT.s, bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sItemStringTT = Lang("WQK", "txtDMXItemStrTT")
    bStaticLoaded = #True
  EndIf

  AddElement(WQKItem())
  WQKItem()\sDMXItemStr = ""
  WQKItem()\nDMXDisplayValue = 0
  
  nListIndex = ListIndex(WQKItem())
  ; debugMsg0(sProcName, "ListIndex(WQKItem()) returned " + nListIndex)
  
  gnCurrentEditorComponent = #WQK
  scsOpenGadgetList(WQK\scaDMXItems)
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQKItem()
      nHeight = #SCS_QKROW_HEIGHT
      nListIndex = ListIndex(WQKItem())
      nTop = nListIndex * nHeight
      WQKItem()\nItemId = grWQK\nItemId ; unique id for this entry
      sItemId = "[" + \nItemId + "]"
      
      \cntItem=scsContainerGadget(0,nTop,GetGadgetAttribute(WQK\scaDMXItems,#PB_ScrollArea_InnerWidth),nHeight,0,"cntItem"+sItemId,#SCS_G4EH_QK_CNTITEM)
        \cvsItemNo=scsCanvasGadget(0,0,10,nHeight,0,"cvsItemNo"+sItemId,#SCS_G4EH_QK_CVSITEMNO)
        \txtDMXItemStr=scsStringGadget(gnNextX+gnGap,0,240,nHeight,"",0,"txtDMXItemStr"+sItemId,#SCS_G4EH_QK_TXTDMXITEMSTR)
        scsToolTip(\txtDMXItemStr, sItemStringTT)
        \sldDMXValue=SLD_New("QK_DMXValue"+sItemId,\cntItem,0,gnNextX+gnGap,0,200,nHeight,#SCS_ST_HLIGHTING_GENERAL,0,100)  ; nb maximum value may be changed at run time
        setGadgetNoForEvHdlr(gaSlider(\sldDMXValue)\cvsSlider, #SCS_G4EH_QK_SLDDMXVALUE)
        SLD_setEnabled(\sldDMXValue, #False)
      scsCloseGadgetList()
      grWQK\nItemId + 1
    EndWith
    
  scsCloseGadgetList()
  gnCurrentEditorComponent = 0
  
EndProcedure

Procedure insertWQKItem()
  ; inserts a blank DMX item immediately before the current entry
  ; returns the listindex of new row
  ; PROCNAMEC()
  Protected nListIndex, nLastElement, nTop
  Protected *oldElement, *firstElement, *secondElement
  
  If ListSize(WQKItem()) = 0
    ProcedureReturn
  EndIf
  
  If ListIndex(WQKItem()) = -1
    ProcedureReturn
  EndIf
  
  *firstElement = @WQKItem()
  createWQKItem()   ; adds blank entry AFTER the current entry
  *secondElement = @WQKItem()
  SwapElements(WQKItem(), *firstElement, *secondElement)  ; swap the new blank entry with the preceding current entry
  
  *oldElement = @WQKItem()
  
  ForEach WQKItem()
    nListIndex = ListIndex(WQKItem())
    nTop = nListIndex * #SCS_QKROW_HEIGHT
    If IsGadget(WQKItem()\cntItem)
      ResizeGadget(WQKItem()\cntItem, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    EndIf
  Next WQKItem()
  
  ChangeCurrentElement(WQKItem(), *oldElement)
  nListIndex = ListIndex(WQKItem())
  
  ProcedureReturn nListIndex
  
EndProcedure

Procedure removeWQKItem()
  ; removes the currently selected DMX item
  ; returns listindex of now-selected row
  PROCNAMEC()
  Protected nListIndex, nLastElement, nTop
  
  nListIndex = ListIndex(WQKItem())
  If nListIndex < 0
    ProcedureReturn nListIndex
  EndIf
  
  scsOpenGadgetList(WQK\scaDMXItems)
    
    If IsGadget(WQKItem()\cntItem)
      scsFreeGadget(WQKItem()\cntItem)
      debugMsg(sProcName, "scsFreeGadget(G" + WQKItem()\cntItem + ")")
    EndIf
    DeleteElement(WQKItem(), 1)
    
    nListIndex = ListIndex(WQKItem())
    nLastElement = ListSize(WQKItem()) - 1
    
    nTop = nListIndex * #SCS_QKROW_HEIGHT
    If nListIndex <= nLastElement
      ; move subsequent entries up one position
      While NextElement(WQKItem()) <> 0
        nTop + #SCS_QKROW_HEIGHT
        ResizeGadget(WQKItem()\cntItem, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      Wend
      ; reset current element to the element after the one deleted unless it is blank
      If nListIndex < nLastElement
        nListIndex + 1
      EndIf
      SelectElement(WQKItem(), nListIndex)
      If Len(Trim(WQKItem()\sDMXItemStr)) = 0 And nListIndex > 0
        nListIndex - 1
        SelectElement(WQKItem(), nListIndex)
      EndIf
    EndIf
    
  scsCloseGadgetList()
  
  ProcedureReturn nListIndex
  
EndProcedure

Procedure createfmEditQK()
  PROCNAMEC()
  Protected n, nTop, sNr.s, nLeft, nWidth, nHeight
  Protected nLeft2, nLeft3, nWidth2, nWidth3, nLeft4, nLeft5
  Protected nNumberWidth
  Protected nItemsWidth, nItemsHeight, nItemsInnerWidth, nItemsInnerHeight, nItemsRowsVisible
  Protected sChkBoxText.s, nChkBoxWidth
  Protected sLblText.s, nLblWidth
  Protected nCntChaseWidth
  Protected nChaseStepWidth
  Protected nTopHold
  Protected nOldGadgetList
  Protected sItemStringTT.s
  Protected sFadeUp.s, sFadeDown.s, sFadeOut.s, sNone.s, sProdDef.s
  Protected nFadeTimeWidth = 50
  
  debugMsg(sProcName, #SCS_START)
  
  sFadeUp = LCase(Lang("Common", "FadeUp"))
  sFadeDown = LCase(Lang("Common", "FadeDown"))
  sFadeOut = LCase(Lang("Common", "FadeOut"))
  sNone = Lang("Common", "None")
  sProdDef = Lang("WQK", "ProdDef") ; "Use production default"
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQK
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQK
      \scaLighting=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaLighting")
        setVisible(\scaLighting, #False)
        ; header
        SUBCUE_HEADER_CODE(WQK)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailK=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailK")
          nTop = 1
          nLeft = 8
          \lblLogicalDev=scsTextGadget(nLeft,nTop+gnLblVOffsetC,110,15,Lang("WQK","lblLogicalDev"),#PB_Text_Right,"lblLogicalDev")
          setGadgetWidth(\lblLogicalDev,-1,#True)
          \cboLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboLogicalDev")
          nTop + 26
          \lblEntryType=scsTextGadget(nLeft,nTop+gnLblVOffsetC,GadgetWidth(\lblLogicalDev),15,Lang("WQK","lblEntryType"),#PB_Text_Right,"lblEntryType")
          \cboEntryType=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboEntryType")
          nLeft = gnNextX+gnGap2
          \lblFixtureDisplay=scsTextGadget(nLeft,nTop+gnLblVOffsetC,50,15,Lang("WQK","lblFixtureDisplay"),#PB_Text_Right,"lblFixtureDisplay")
          setGadgetWidth(\lblFixtureDisplay,-1,#True)
          \cboFixtureDisplay=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboFixtureDisplay")
          scsToolTip(\cboFixtureDisplay, Lang("WQK","cboFixtureDisplayTT"))
          If grLicInfo\bExtFaderCueControlAvailable
            \chkApplyCurrValuesAsMins=scsCheckBoxGadget2(gnNextX+20,nTop+2,-1,17,Lang("WQK","chkApplyCurrValuesAsMins"),0,"chkApplyCurrValuesAsMins")
            scsToolTip(\chkApplyCurrValuesAsMins, Lang("WQK","chkApplyCurrValuesAsMinsTT"))
            setVisible(\chkApplyCurrValuesAsMins, #False)
          EndIf
          If grLicInfo\bDMXCaptureAvailable
            ; nb the following 'capture' controls may be repositioned in WQK_displaySub()
            nTop - 2 ; Deduct 2 from nTop to show the button gadgets with apparently the same 'top' position as the combobox, because
                     ; PB button gadgets have a 1-pixel near-white border. Need to revisit this when we change the GUI objects.
            \cvsCaptureButton=scsCanvasGadget(nLeft,nTop+gnLblVOffsetC-1,130,19,0,"cvsCaptureButton")
            setVisible(\cvsCaptureButton, #False)
            \lblCapturingDMX=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetC,150,17,"  "+Lang("WQK","lblCapturingDMX")+"  ",#PB_Text_Center,"lblCapturingDMX")
            setGadgetWidth(\lblCapturingDMX, -1, #True)
            \cvsCapturingDMXLight=scsCanvasGadget(gnNextX+gnGap,nTop,23,23,0,"cvsCapturingDMXLight")
          EndIf
          nLeft = 305
          nTop = GadgetY(\cboLogicalDev) + 2
          \chkChase=scsCheckBoxGadget2(nLeft,nTop,-1,17,Lang("WQK","chkChase"),0,"chkChase")
          nTop + 2
          \cntChase=scsContainerGadget(gnNextX+gnGap,nTop,100,73,#PB_Container_Flat,"cntChase")
            nTop = 4
            \lblChaseSteps=scsTextGadget(8,nTop+gnLblVOffsetS,40,15,Lang("WQK","lblChaseSteps"),#PB_Text_Right,"lblChaseSteps")
            setGadgetWidth(\lblChaseSteps, -1, #True)
            \txtChaseSteps=scsStringGadget(gnNextX+gnGap,nTop,25,21,"",#PB_String_Numeric,"txtChaseSteps")
            scsToolTip(\txtChaseSteps, Lang("WQK", "txtChaseStepsTT"))
            \lblChaseSpeed=scsTextGadget(gnNextX+12,nTop+gnLblVOffsetS,40,15,Lang("WQK","lblChaseSpeed"),#PB_Text_Right,"lblChaseSpeed")
            setGadgetWidth(\lblChaseSpeed, -1, #True)
            \txtChaseSpeed=scsStringGadget(gnNextX+gnGap,nTop,37,21,"",#PB_String_Numeric,"txtChaseSpeed")
            ; scsToolTip(\txtChaseSpeed, Lang("WQK", "txtChaseSpeedTT"))
            scsToolTip(\txtChaseSpeed, LangPars("WQK", "txtChaseSpeedTT", gaShortcutsEditor(#SCS_ShortEditor_TapDelay)\sDefaultShortcutStr))
            nCntChaseWidth = gnNextX + 14
            ResizeGadget(\cntChase, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
            nTop + 23
            ; the following makes sure the \cboChaseMode combobox will be aligned with \txtChaseSteps
            nWidth = GadgetX(\lblChaseSteps) + GadgetWidth(\lblChaseSteps)
            \lblChaseMode=scsTextGadget(0,nTop+gnLblVOffsetS,nWidth,17,Lang("WQK","lblChaseMode"),#PB_Text_Right,"lblChaseMode")
            \cboChaseMode=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboChaseMode")
            addGadgetItemWithData(\cboChaseMode,Lang("DMX","ModeFor"),#SCS_DMX_CHASE_MODE_FORWARD)
            addGadgetItemWithData(\cboChaseMode,Lang("DMX","ModeRev"),#SCS_DMX_CHASE_MODE_REVERSE)
            addGadgetItemWithData(\cboChaseMode,Lang("DMX","ModeBnc"),#SCS_DMX_CHASE_MODE_BOUNCE)
            addGadgetItemWithData(\cboChaseMode,Lang("DMX","ModeRdm"),#SCS_DMX_CHASE_MODE_RANDOM)
            setComboBoxWidth(\cboChaseMode)
            gnNextX = GadgetX(\cboChaseMode) + GadgetWidth(\cboChaseMode)
            \chkMonitorTapDelay=scsCheckBoxGadget2(gnNextX+16,nTop+2,-1,17,Lang("WQK","chkMonitorTapDelay"),0,"chkMonitorTapDelay")
            nWidth = gnNextX + 14
            If nWidth > nCntChaseWidth
              nCntChaseWidth = nWidth
            EndIf
            nTop + 23
            \chkNextLTStopsChase=scsCheckBoxGadget2(GadgetX(\cboChaseMode),nTop,-1,17,Lang("WQK","chkNextLTStopsChase"),0,"chkNextLTStopsChase")
            nWidth = gnNextX + 14
            If nWidth > nCntChaseWidth
              nCntChaseWidth = nWidth
            EndIf
            ResizeGadget(\cntChase, #PB_Ignore, #PB_Ignore, nCntChaseWidth, #PB_Ignore)
          scsCloseGadgetList()
          
          nLeft = 36
          nWidth = GadgetX(\cntChase) - nLeft
          nHeight = 23
          nTop = GadgetY(\cntChase) + GadgetHeight(\cntChase) - nHeight
          \cntChaseStep=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntChaseStep")
            \btnPrevStep=scsButtonGadget(19,0,23,23,"<",0,"btnPrevStep")
            nChaseStepWidth = 194
            \cvsChaseStep=scsCanvasGadget(gnNextX,0,nChaseStepWidth,23,0,"cvsChaseStep")
            \btnNextStep=scsButtonGadget(gnNextX,0,23,23,">",0,"btnNextStep")
          scsCloseGadgetList() ; cntChaseStep
          setVisible(\cntChaseStep, #False) ; will be made visible if required, in which case \cntDMX will be moved down and resized
          
          ; sidebar
          \cntLightingSideBar=scsContainerGadget(3,57,30,144,0,"cntLightingSideBar")
            setAllowEditorColors(\cntLightingSideBar, #False)    ; prevent toolbar being colored
            \imgQKButtonTBS[0]=scsStandardButton(3,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgQKButtonTBS[0]")
            \imgQKButtonTBS[1]=scsStandardButton(3,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgQKButtonTBS[1]")
            \imgQKButtonTBS[2]=scsStandardButton(3,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgQKButtonTBS[2]")
            \imgQKButtonTBS[3]=scsStandardButton(3,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgQKButtonTBS[3]")
            \imgQKButtonTBS[4]=scsStandardButton(3,96,24,24,#SCS_STANDARD_BTN_COPY,"imgQKButtonTBS[4]")
            \imgQKButtonTBS[5]=scsStandardButton(3,120,24,24,#SCS_STANDARD_BTN_PASTE,"imgQKButtonTBS[5]")
          scsCloseGadgetList() ; cntLightingSideBar
          
          ; DMX
          nLeft = 36
          nTop = GadgetY(\cboEntryType) + GadgetHeight(\cboEntryType)
          \cntDMX=scsContainerGadget(nLeft,nTop,gnEditorScaPropertiesInnerWidth-nLeft,250,0,"cntDMX")
            
            ;INFO: Lighting Cue Pre-11.8 DMX Items (\cntItems was functionally replaced in SCS 11.8 by \cntFixtures (see below) but \cntItems is still required for cue files with lighting cues created pre 11.8)
            \cntItems=scsContainerGadget(0,0,GadgetWidth(\cntDMX),186,#PB_Container_Flat,"cntItems")
              nTop = 0
              nNumberWidth = 10
              nLeft = 4 + nNumberWidth + 2
              nWidth = 240
              nLeft2 = nLeft + nWidth + 14 + gnGap
              nWidth2 = 200
              sItemStringTT = Lang("WQK", "txtDMXItemStrTT")
              \lblDMXItems=scsTextGadget(nLeft+8,nTop,nWidth-8,17,Lang("WQK","lblDMXItems"),0,"lblDMXItems")
              \lblDMXValue=scsTextGadget(nLeft2,nTop,nWidth2,17,Lang("WQK","lblDMXValue"),#PB_Text_Center,"lblDMXValue")
              nTop + 17
              nHeight = 19
              nItemsInnerHeight = (grLicInfo\nMaxDMXItemPerLightingSub + 1) * nHeight
              nItemsInnerWidth = nNumberWidth + nWidth + nWidth2 + (gnGap * 3)
              nItemsWidth = nItemsInnerWidth + glScrollBarWidth + gl3DBorderAllowanceX + gnGap
              nItemsRowsVisible = Round((GadgetHeight(\cntItems) - nTop - 4) / nHeight, #PB_Round_Down)
              nItemsHeight = nHeight * nItemsRowsVisible
              \scaDMXItems=scsScrollAreaGadget(4,nTop,nItemsWidth,nItemsHeight,nItemsInnerWidth,nItemsInnerHeight,nHeight,#PB_ScrollArea_BorderLess,"scaDMXItems")
                ; populated separately
              scsCloseGadgetList() ; scaDMXItems
            scsCloseGadgetList() ; cntItems
            setVisible(\cntItems, #False)
            
            ;INFO: Lighting Cue Fixtures (\cntFixtures is for Fixture selection, link groups, DMX channel values, etc)
            \cntFixtures=scsContainerGadget(0,0,GadgetWidth(\cntItems),GadgetHeight(\cntItems),#PB_Container_Flat,"cntFixtures")
              nTop = 2
              nNumberWidth = 16
              nLeft = 4
              nWidth = 180
              \lblFixtures=scsTextGadget(26,nTop,166,17,Lang("WQK","lblFixtures"),0,"lblFixtures")
              \lblFixtureLinkGroup=scsTextGadget(gnNextX,nTop,83,17,Lang("WQK","lblFixtureLinkGroup"),0,"lblFixtureLinkGroup")
              \chkInclude=scsCheckBoxGadget2(gnNextX,nTop-1,66,15,Lang("Common","Include"),#PB_CheckBox_ThreeState,"chkInclude")
              \lblDMXValue2=scsTextGadget(gnNextX,nTop,228,17,LangPars("WQK","lblDMXValue2",""),0,"lblDMXValue2")
              scsSetGadgetFont(\lblDMXValue2, #SCS_FONT_GEN_BOLD)
              setGadgetWidth(\lblDMXValue2)
              \lblFade=scsTextGadget(551,nTop,60,17,Lang("Common","Fade"),0,"lblFade")
              nTop + 17
              nHeight = 19
              nWidth3 = 20  ; for \txtFixtureLinkGroup[n]
              nItemsInnerHeight = (grLicInfo\nMaxFixtureItemPerLightingSub + 1) * nHeight
              nItemsInnerWidth = nNumberWidth + nWidth + nWidth3 + (gnGap * 2)
              nItemsWidth = nItemsInnerWidth + glScrollBarWidth + gnGap
              nItemsHeight = nHeight * 8
              \scaFixtures=scsScrollAreaGadget(4,nTop,nItemsWidth,nItemsHeight,nItemsInnerWidth,nItemsInnerHeight,nHeight,#PB_ScrollArea_BorderLess,"scaFixtures")
                nLeft = 0
                nTop = 0
                For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
                  \cvsFixtureNo[n]=scsCanvasGadget(nLeft,nTop,nNumberWidth,nHeight,0,"cvsFixtureNo[" + n + "]")
                  nTop + nHeight
                Next n
                nLeft = GadgetX(\cvsFixtureNo[0]) + GadgetWidth(\cvsFixtureNo[0]) + gnGap
                nTop = 0
                For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
                  \cboFixture[n]=scsComboBoxGadget(nLeft, nTop, nWidth, nHeight, 0,"cboFixture[" + n + "]")
                  ignoreMouseWheelEvents(\cboFixture[n], grLicInfo\nMaxFixtureItemPerLightingSub)
                  \txtFixtureLinkGroup[n]=scsStringGadget(gnNextX+gnGap,nTop,nWidth3,nHeight,"",#PB_String_Numeric,"txtFixtureLinkGroup[" + n + "]")
                  nTop + nHeight
                Next n
              scsCloseGadgetList() ; scaFixtures
              
              nLeft = GadgetX(\scaFixtures) + GadgetWidth(\scaFixtures) + 16
              nTop = GadgetY(\scaFixtures)
              \lnFixtureChannels=scsLineGadget(nLeft,nTop,1,GadgetHeight(\scaFixtures),#SCS_Grey,0,"lnFixtureChannels")
              nLeft = GadgetX(\lnFixtureChannels) + GadgetWidth(\lnFixtureChannels) + 16
              
              nHeight = 19
              nItemsInnerHeight = (#SCS_MAX_FIX_TYPE_CHANNEL + 1) * nHeight
              nItemsWidth = GadgetWidth(\cntFixtures) - nLeft - gnGap
              nItemsInnerWidth = nItemsWidth - glScrollBarWidth - gnGap
              \scaFixtureChans=scsScrollAreaGadget(nLeft,nTop,nItemsWidth,nItemsHeight,nItemsInnerWidth,nItemsInnerHeight,nHeight,#PB_ScrollArea_BorderLess,"scaFixtureChans")
                nTop = 0
                For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
                  \chkFixtureChanIncluded[n]=scsCheckBoxGadget2(0,nTop+1,17,17,"",0,"chkFixtureChanIncluded[" + n + "]")
                  scsToolTip(\chkFixtureChanIncluded[n],Lang("WQK","chkFixtureChanIncludedTT"))
                  \txtFixtureChannel[n]=scsStringGadget(gnNextX+gnGap,nTop,60,nHeight,Str(n+1),#PB_String_ReadOnly,"txtFixtureChannel[" + n + "]")
                  ; nb tooltip for \txtFixtureChannel[n] added dynamically
                  \txtFixtureChannelValue[n]=scsStringGadget(gnNextX+gnGap,nTop,40,nHeight,Str(n+1),0,"txtFixtureChannelValue[" + n + "]")
                  If n = 0
                    nLeft2 = gnNextX + gnGap
                    nWidth2 = nItemsInnerWidth - nLeft2 - gnGap - (17 + gnGap2) ; (17 + gnGap) to allow for \chkFixtureChanApplyFadeTime[n]
                  EndIf
                  \sldFixtureChannelValue[n]=SLD_New("QK_FixtureChannelValue[" + n + "]",\scaFixtureChans,0,nLeft2,nTop,nWidth2,nHeight,#SCS_ST_HLIGHTING_GENERAL,0,100)  ; nb maximum value may be changed at run time
                  \chkFixtureChanApplyFadeTime[n]=scsCheckBoxGadget2(gnNextX+gnGap2,nTop+1,17,17,"",0,"chkFixtureChanApplyFadeTime[" + n + "]")
                  scsToolTip(\chkFixtureChanApplyFadeTime[n],Lang("WQK","chkFixtureChanApplyFadeTimeTT"))
                  nTop + nHeight
                Next n
              scsCloseGadgetList() ; scaFixtureChans
            scsCloseGadgetList() ; cntFixtures
            setVisible(\cntFixtures, #False)
            
            ;INFO: Lighting Cue Fixtures - Single Channel Display (\cntFixtures1 is similar to \cntFixtures but just displays the first channel of each fixture)
            \cntFixtures1=scsContainerGadget(0,0,GadgetWidth(\cntItems),GadgetHeight(\cntItems),#PB_Container_Flat,"cntFixtures1")
              ReDim \aFix1(grLicInfo\nMaxFixtureItemPerLightingSub)
              nTop = 0
              nNumberWidth = 16
              nLeft = 4
              nWidth = 180
              \lblFixtures1=scsTextGadget(26,nTop,166,17,Lang("WQK","lblFixtures"),0,"lblFixtures1")
              \lblFixtureLinkGroup1=scsTextGadget(gnNextX,nTop,83,17,Lang("WQK","lblFixtureLinkGroup"),0,"lblFixtureLinkGroup1")
              setGadgetWidth(\lblFixtureLinkGroup1,-1,#True)
              \lblInclude1=scsTextGadget(gnNextX+gnGap,nTop,49,17,Lang("Common","Include"),0,"lblInclude1")
              setGadgetWidth(\lblInclude1,-1,#True)
              \lblDMXValue21=scsTextGadget(gnNextX+gnGap2,nTop,220,17,Lang("WQK","lblDMXValue21"),0,"lblDMXValue21")
              \lblFade1=scsTextGadget(gnNextX,nTop,60,17,Lang("Common","Fade"),0,"lblFade1")
              setGadgetWidth(\lblFade1)
              nTop + 17
              nHeight = 19
              nWidth3 = 20  ; for \txtFixtureLinkGroup[n]
              nItemsInnerHeight = (grLicInfo\nMaxFixtureItemPerLightingSub + 1) * nHeight
              nItemsInnerWidth = GadgetWidth(\cntFixtures1) - nLeft - glScrollBarWidth - (2 * gnGap)
              nItemsWidth = nItemsInnerWidth + glScrollBarWidth + gnGap
              nItemsHeight = nHeight * 8
              \scaFixtures1=scsScrollAreaGadget(4,nTop,nItemsWidth,nItemsHeight,nItemsInnerWidth,nItemsInnerHeight,nHeight,#PB_ScrollArea_BorderLess,"scaFixtures1")
                nLeft = 0
                nTop = 0
                For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
                  \aFix1(n)\cvsFixtureNo1=scsCanvasGadget(nLeft,nTop,nNumberWidth,nHeight,0,"cvsFixtureNo1[" + n + "]")
                  nTop + nHeight
                Next n
                nLeft = GadgetX(\aFix1(0)\cvsFixtureNo1) + GadgetWidth(\aFix1(0)\cvsFixtureNo1) + gnGap
                nLeft3 = GadgetX(\lblInclude1) + (GadgetWidth(\lblInclude1) >> 1) - 8
                nLeft4 = GadgetX(\lblDMXValue21) - 6
                nTop = 0
                For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
                  \aFix1(n)\cboFixture1=scsComboBoxGadget(nLeft, nTop, nWidth, nHeight, 0,"cboFixture1[" + n + "]")
                  \aFix1(n)\txtFixtureLinkGroup1=scsStringGadget(gnNextX+gnGap,nTop,nWidth3,nHeight,"",#PB_String_Numeric,"txtFixtureLinkGroup1[" + n + "]")
                  \aFix1(n)\chkFixtureChanIncluded1=scsCheckBoxGadget2(nLeft3,nTop+1,17,17,"",0,"chkFixtureChanIncluded1[" + n + "]")
                  scsToolTip(\aFix1(n)\chkFixtureChanIncluded1,Lang("WQK","chkFixtureChanIncludedTT"))
                  \aFix1(n)\txtFixtureChannel1=scsStringGadget(nLeft4,nTop,60,nHeight,"",#PB_String_ReadOnly,"txtFixtureChannel1[" + n + "]")
                  ; nb tooltip for \aFix1(n)\txtFixtureChannel added dynamically
                  \aFix1(n)\txtFixtureChannelValue1=scsStringGadget(gnNextX+gnGap,nTop,40,nHeight,"",0,"txtFixtureChannelValue1[" + n + "]")
                  If n = 0
                    nLeft2 = gnNextX + gnGap
                    nWidth2 = nItemsInnerWidth - nLeft2 - gnGap - (17 + gnGap2) ; (17 + gnGap) to allow for \chkFixtureChanApplyFadeTime[n]
                  EndIf
                  \aFix1(n)\sldFixtureChannelValue1=SLD_New("QK_FixtureChannelValue1[" + n + "]",\scaFixtures1,0,nLeft2,nTop,nWidth2,nHeight,#SCS_ST_HLIGHTING_GENERAL,0,100)  ; nb maximum value may be changed at run time
                  \aFix1(n)\chkFixtureChanApplyFadeTime1=scsCheckBoxGadget2(gnNextX+gnGap2,nTop+1,17,17,"",0,"chkFixtureChanApplyFadeTime1[" + n + "]")
                  scsToolTip(\aFix1(n)\chkFixtureChanApplyFadeTime1,Lang("WQK","chkFixtureChanApplyFadeTimeTT"))
                  If n = 0
                    ResizeGadget(\lblFade1, (GadgetX(\aFix1(n)\chkFixtureChanApplyFadeTime1) + 12 - (GadgetWidth(\lblFade1) >> 1)), #PB_Ignore, #PB_Ignore, #PB_Ignore)
                  EndIf
                  nTop + nHeight
                Next n
              scsCloseGadgetList() ; scaFixtures1
            scsCloseGadgetList() ; cntFixtures1
            setVisible(\cntFixtures1, #False)
            
            ;INFO: Lighting Cue Fades (\cntFades is for 'Fade time for the above fixtures' etc)
            nLeft = GadgetX(\cntItems)
            nTop = GadgetY(\cntItems) + GadgetHeight(\cntItems)
            nWidth = GadgetWidth(\cntItems)
            nHeight = 79
            \cntFades=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntFades")
              nTop = 0
              nLeft = 0 ; GadgetX(\scaDMXItems) ; + 15 ; GadgetX(\txtDMXItemStr[0])
              \cntFIFadeUp=scsContainerGadget(nLeft,nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntFIFadeUp")
                \lblFIFadeUpAction=scsTextGadget(8,6,100,17,Lang("WQK","lblFIFadeUpAction"),#PB_Text_Right,"lblFIFadeUpAction")
                setGadgetWidth(\lblFIFadeUpAction, -1, #True)
                \cboFIFadeUpAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboFIFadeUpAction")
                addGadgetItemWithData(\cboFIFadeUpAction, sNone, #SCS_DMX_FI_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboFIFadeUpAction, sProdDef, #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT)
                addGadgetItemWithData(\cboFIFadeUpAction, LangPars("WQK", "UserFade", sFadeUp) + " -->", #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME)
                \txtFIFadeUpTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtFIFadeUpTime")
                \lblFIFadeUpSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblFIFadeUpSeconds")
                setGadgetWidth(\lblFIFadeUpSeconds)
              scsCloseGadgetList() ; cntFIFadeUp
              
              nTop = GadgetY(\cntFIFadeUp) + GadgetHeight(\cntFIFadeUp) - 1
              \cntFIFadeDown=scsContainerGadget(GadgetX(\cntFIFadeUp),nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntFIFadeDown")
                \lblFIFadeDownAction=scsTextGadget(8,6,100,17,Lang("WQK","lblFIFadeDownAction"),#PB_Text_Right,"lblFIFadeDownAction")
                setGadgetWidth(\lblFIFadeDownAction)
                \cboFIFadeDownAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboFIFadeDownAction")
                addGadgetItemWithData(\cboFIFadeDownAction, sNone, #SCS_DMX_FI_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboFIFadeDownAction, Lang("WQK", "UseAboveFadeTime"), #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME)
                addGadgetItemWithData(\cboFIFadeDownAction, LangPars("WQK", "UserFade", sFadeDown) + " -->", #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME)
                \txtFIFadeDownTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtFIFadeDownTime")
                \lblFIFadeDownSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblFIFadeDownSeconds")
                setGadgetWidth(\lblFIFadeDownSeconds)
              scsCloseGadgetList() ; cntFIFadeDown
              
              nTop = GadgetY(\cntFIFadeDown) + GadgetHeight(\cntFIFadeDown) - 1
              \cntFIFadeOutOthers=scsContainerGadget(GadgetX(\cntFIFadeDown),nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntFIFadeOutOthers")
                \lblFIFadeOutOthersAction=scsTextGadget(8,6,100,17,Lang("WQK","lblFIFadeOutOthersAction"),#PB_Text_Right,"lblFIFadeOutOthersAction")
                setGadgetWidth(\lblFIFadeOutOthersAction)
                \cboFIFadeOutOthersAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboFIFadeOutOthersAction")
                addGadgetItemWithData(\cboFIFadeOutOthersAction, Lang("WQK", "DoNotFadeOutOthers"), #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS)
                addGadgetItemWithData(\cboFIFadeOutOthersAction, Lang("WQK", "UseAboveFadeTime"), #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME)
                addGadgetItemWithData(\cboFIFadeOutOthersAction, LangPars("WQK", "UserFade", sFadeOut) + " -->",#SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME)
                scsToolTip(\cboFIFadeOutOthersAction, Lang("WQK", "cboFadeOutOthersActionTT"))
                \txtFIFadeOutOthersTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtFIFadeOutOthersTime")
                \lblFIFadeOutOthersSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblFIFadeOutOthersSeconds")
                setGadgetWidth(\lblFIFadeOutOthersSeconds)
              scsCloseGadgetList() ; cntFIFadeOutOthers
              
              CompilerIf #True ; CompilerIf around gadget resizing just to enable collapsing in the IDE
                ; obtain maximum width of the \lblFIFade... labels just created
                nWidth = GadgetWidth(\lblFIFadeUpAction)
                If GadgetWidth(\lblFIFadeDownAction) > nWidth
                  nWidth = GadgetWidth(\lblFIFadeDownAction)
                EndIf
                If GadgetWidth(\lblFIFadeOutOthersAction) > nWidth
                  nWidth = GadgetWidth(\lblFIFadeOutOthersAction)
                EndIf
                ; now resize gadgets according to the maximum width just calculated
                ResizeGadget(\lblFIFadeUpAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\lblFIFadeDownAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\lblFIFadeOutOthersAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                nLeft = GadgetX(\lblFIFadeUpAction) + GadgetWidth(\lblFIFadeUpAction) + gnGap
                setComboBoxesWidth(-1, \cboFIFadeUpAction, \cboFIFadeDownAction, \cboFIFadeOutOthersAction)
                ResizeGadget(\cboFIFadeUpAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\cboFIFadeDownAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\cboFIFadeOutOthersAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nLeft = GadgetX(\cboFIFadeUpAction) + GadgetWidth(\cboFIFadeUpAction) + gnGap
                ResizeGadget(\txtFIFadeUpTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\txtFIFadeDownTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\txtFIFadeOutOthersTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nLeft = GadgetX(\txtFIFadeUpTime) + GadgetWidth(\txtFIFadeUpTime) + gnGap
                ResizeGadget(\lblFIFadeUpSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\lblFIFadeDownSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\lblFIFadeOutOthersSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nWidth = GadgetX(\lblFIFadeUpSeconds) + GadgetWidth(\lblFIFadeUpSeconds) + GadgetX(\lblFIFadeUpAction) + 2
                ResizeGadget(\cntFIFadeUp, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\cntFIFadeDown, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\cntFIFadeOutOthers, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              CompilerEndIf
              
              ; borderless container for 'blackout fade'
              nTop = 0
              nLeft = GadgetX(\cntFIFadeUp)
              \cntBLFade=scsContainerGadget(nLeft,nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_BorderLess,"cntBLFade")
                \lblBLFadeAction=scsTextGadget(8,6,100,17,Lang("WQK","lblBLFadeAction"),#PB_Text_Right,"lblBLFadeAction")
                setGadgetWidth(\lblBLFadeAction, -1, #True)
                \cboBLFadeAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboBLFadeAction")
                addGadgetItemWithData(\cboBLFadeAction, sNone, #SCS_DMX_BL_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboBLFadeAction, sProdDef, #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT)
                addGadgetItemWithData(\cboBLFadeAction, LangPars("WQK", "UserFade", sFadeOut) + " -->",#SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME)
                ; scsToolTip(\cboBLFadeAction, Lang("WQK", "cboBLFadeActionTT"))
                setComboBoxesWidth(-1, \cboBLFadeAction)
                gnNextX = GadgetX(\cboBLFadeAction) + GadgetWidth(\cboBLFadeAction)
                \txtBLFadeTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtBLFadeTime")
                \lblBLFadeSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblBLFadeSeconds")
                setGadgetWidth(\lblBLFadeSeconds)
              scsCloseGadgetList() ; cntBLFade
              nWidth = GadgetX(\lblBLFadeSeconds) + GadgetWidth(\lblBLFadeSeconds) + GadgetX(\lblBLFadeAction) + 2
              ResizeGadget(\cntBLFade, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              
              ; containers for DMX Items fade times
              nTop = GadgetY(\cntFIFadeUp) ; nb \cntFIFadeUp and \cntDIFadeUp are mutually exclusive
              nLeft = GadgetX(\cntFIFadeUp)
              \cntDIFadeUp=scsContainerGadget(nLeft,nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDIFadeUp")
                \lblDIFadeUpAction=scsTextGadget(8,6,100,17,Lang("WQK","lblDIFadeUpAction"),#PB_Text_Right,"lblDIFadeUpAction")
                setGadgetWidth(\lblDIFadeUpAction, -1, #True)
                \cboDIFadeUpAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDIFadeUpAction")
                addGadgetItemWithData(\cboDIFadeUpAction, sNone, #SCS_DMX_DI_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboDIFadeUpAction, sProdDef, #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT)
                addGadgetItemWithData(\cboDIFadeUpAction, LangPars("WQK", "UserFade", sFadeUp) + " -->", #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME)
                \txtDIFadeUpTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDIFadeUpTime")
                \lblDIFadeUpSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDIFadeUpSeconds")
                setGadgetWidth(\lblDIFadeUpSeconds)
              scsCloseGadgetList() ; cntDIFadeUp
              
              nTop = GadgetY(\cntDIFadeUp) + GadgetHeight(\cntDIFadeUp) - 1
              \cntDIFadeDown=scsContainerGadget(GadgetX(\cntDIFadeUp),nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDIFadeDown")
                \lblDIFadeDownAction=scsTextGadget(8,6,100,17,Lang("WQK","lblDIFadeDownAction"),#PB_Text_Right,"lblDIFadeDownAction")
                setGadgetWidth(\lblDIFadeDownAction)
                \cboDIFadeDownAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDIFadeDownAction")
                addGadgetItemWithData(\cboDIFadeDownAction, sNone, #SCS_DMX_DI_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboDIFadeDownAction, Lang("WQK","UseAboveFadeTime"), #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME)
                addGadgetItemWithData(\cboDIFadeDownAction, LangPars("WQK", "UserFade", sFadeDown) + " -->", #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME)
                \txtDIFadeDownTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDIFadeDownFadeTime")
                \lblDIFadeDownSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDIFadeDownSeconds")
                setGadgetWidth(\lblDIFadeDownSeconds)
              scsCloseGadgetList() ; cntDIFadeDown
              
              nTop = GadgetY(\cntDIFadeDown) + GadgetHeight(\cntDIFadeDown) - 1
              nLeft = GadgetX(\cntDIFadeDown)
              
              \cntDIFadeOutOthers=scsContainerGadget( nLeft,nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDIFadeOutOthers")
                \lblDIFadeOutOthersAction=scsTextGadget(8,6,100,17,Lang("WQK","lblFadeOutOthersAction"),#PB_Text_Right,"lblDIFadeOutOthersAction")
                setGadgetWidth(\lblDIFadeOutOthersAction)
                \cboDIFadeOutOthersAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDIFadeOutOthersAction")
                addGadgetItemWithData(\cboDIFadeOutOthersAction, Lang("WQK", "DoNotFadeOutOthers"), #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS)
                addGadgetItemWithData(\cboDIFadeOutOthersAction, Lang("WQK", "UseAboveFadeTime"), #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME)
                addGadgetItemWithData(\cboDIFadeOutOthersAction, LangPars("WQK", "UserFade", sFadeOut) + " -->",#SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME)
                scsToolTip(\cboDIFadeOutOthersAction, Lang("WQK", "cboFadeOutOthersActionTT"))
                \txtDIFadeOutOthersTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDIFadeOutOthersFadeTime")
                \lblDIFadeOutOthersSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDIFadeOutOthersSeconds")
                setGadgetWidth(\lblDIFadeOutOthersSeconds)
              scsCloseGadgetList() ; cntDIFadeOutOthers
              
              nWidth = GadgetWidth(\lblDIFadeUpAction)
              If GadgetWidth(\lblDIFadeDownAction) > nWidth
                nWidth = GadgetWidth(\lblDIFadeDownAction)
              EndIf
              If GadgetWidth(\lblDIFadeOutOthersAction) > nWidth
                nWidth = GadgetWidth(\lblDIFadeOutOthersAction)
              EndIf
              ; now resize gadgets according to the maximum width just calculated
              ResizeGadget(\lblDIFadeUpAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              ResizeGadget(\lblDIFadeDownAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              ResizeGadget(\lblDIFadeOutOthersAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              nLeft = GadgetX(\lblDIFadeUpAction) + GadgetWidth(\lblDIFadeUpAction) + gnGap
              setComboBoxesWidth(-1, \cboDIFadeUpAction, \cboDIFadeDownAction, \cboDIFadeOutOthersAction)
              ResizeGadget(\cboDIFadeUpAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\cboDIFadeDownAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\cboDIFadeOutOthersAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              nLeft = GadgetX(\cboDIFadeUpAction) + GadgetWidth(\cboDIFadeUpAction) + gnGap
              ResizeGadget(\txtDIFadeUpTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\txtDIFadeDownTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\txtDIFadeOutOthersTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              nLeft = GadgetX(\txtDIFadeUpTime) + GadgetWidth(\txtDIFadeUpTime) + gnGap
              ResizeGadget(\lblDIFadeUpSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\lblDIFadeDownSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ResizeGadget(\lblDIFadeOutOthersSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              nWidth = GadgetX(\lblDIFadeUpSeconds) + GadgetWidth(\lblDIFadeUpSeconds) + GadgetX(\lblDIFadeUpAction) + 2
              ResizeGadget(\cntDIFadeUp, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              ResizeGadget(\cntDIFadeDown, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              ResizeGadget(\cntDIFadeOutOthers, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              
              ; containers for DMX Capture fade times
              nTop = GadgetY(\cntFIFadeUp) ; nb \cntFIFadeUp and \cntDCFadeUp are mutually exclusive
              nLeft = GadgetX(\cntFIFadeUp)
              \cntDCFadeUp=scsContainerGadget(nLeft,nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDCFadeUp")
                \lblDCFadeUpAction=scsTextGadget(8,6,100,17,Lang("WQK","lblDCFadeUpAction"),#PB_Text_Right,"lblDCFadeUpAction")
                setGadgetWidth(\lblDCFadeUpAction, -1, #True)
                \cboDCFadeUpAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDCFadeUpAction")
                addGadgetItemWithData(\cboDCFadeUpAction, sNone, #SCS_DMX_DC_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboDCFadeUpAction, sProdDef, #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT)
                addGadgetItemWithData(\cboDCFadeUpAction, LangPars("WQK", "UserFade", sFadeUp) + " -->", #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME)
                \txtDCFadeUpTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDCFadeUpTime")
                \lblDCFadeUpSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDCFadeUpSeconds")
                setGadgetWidth(\lblDCFadeUpSeconds)
              scsCloseGadgetList() ; cntDCFadeUp
              
              nTop = GadgetY(\cntDCFadeUp) + GadgetHeight(\cntDCFadeUp) - 1
              \cntDCFadeDown=scsContainerGadget(GadgetX(\cntDCFadeUp),nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDCFadeDown")
                \lblDCFadeDownAction=scsTextGadget(8,6,100,17,Lang("WQK","lblDCFadeDownAction"),#PB_Text_Right,"lblDCFadeDownAction")
                setGadgetWidth(\lblDCFadeDownAction)
                \cboDCFadeDownAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDCFadeDownAction")
                addGadgetItemWithData(\cboDCFadeDownAction, sNone, #SCS_DMX_DC_FADE_ACTION_NONE)
                addGadgetItemWithData(\cboDCFadeDownAction, Lang("WQK","UseAboveFadeTime"), #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME)
                addGadgetItemWithData(\cboDCFadeDownAction, LangPars("WQK", "UserFade", sFadeDown) + " -->", #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME)
                \txtDCFadeDownTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDCFadeDownFadeTime")
                \lblDCFadeDownSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDCFadeDownSeconds")
                setGadgetWidth(\lblDCFadeDownSeconds)
              scsCloseGadgetList() ; cntDCFadeDown
              
              nTop = GadgetY(\cntDCFadeDown) + GadgetHeight(\cntDCFadeDown) - 1
              \cntDCFadeOutOthers=scsContainerGadget(GadgetX(\cntDCFadeUp),nTop,GadgetWidth(\scaDMXItems),27,#PB_Container_Flat,"cntDCFadeOutOthers")
                \lblDCFadeOutOthersAction=scsTextGadget(8,6,100,17,Lang("WQK","lblFadeOutOthersAction"),#PB_Text_Right,"lblDCFadeOutOthersAction")
                setGadgetWidth(\lblDCFadeOutOthersAction)
                \cboDCFadeOutOthersAction=scsComboBoxGadget(gnNextX+gnGap,2,50,21,0,"cboDCFadeOutOthersAction")
                addGadgetItemWithData(\cboDCFadeOutOthersAction, Lang("WQK", "DoNotFadeOutOthers"), #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS)
                addGadgetItemWithData(\cboDCFadeOutOthersAction, Lang("WQK", "UseAboveFadeTime"), #SCS_DMX_DC_FADE_ACTION_USE_FADEDOWN_TIME)
                addGadgetItemWithData(\cboDCFadeOutOthersAction, LangPars("WQK", "UserFade", sFadeOut) + " -->",#SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME)
                scsToolTip(\cboDCFadeOutOthersAction, Lang("WQK", "cboFadeOutOthersActionTT"))
                \txtDCFadeOutOthersTime=scsStringGadget(gnNextX+gnGap,2,nFadeTimeWidth,21,"",0,"txtDCFadeOutOthersFadeTime")
                \lblDCFadeOutOthersSeconds=scsTextGadget(gnNextX+gnGap,6,100,17,Lang("Common","Seconds"),0,"lblDCFadeOutOthersSeconds")
                setGadgetWidth(\lblDCFadeOutOthersSeconds)
              scsCloseGadgetList() ; cntDCFadeOutOthers
              
              CompilerIf #True ; CompilerIf around gadget resizing just to enable collapsing in the IDE
                ; obtain maximum width of the \lblDCFade... labels just created
                nWidth = GadgetWidth(\lblDCFadeUpAction)
                If GadgetWidth(\lblDCFadeDownAction) > nWidth
                  nWidth = GadgetWidth(\lblDCFadeDownAction)
                EndIf
                If GadgetWidth(\lblDCFadeOutOthersAction) > nWidth
                  nWidth = GadgetWidth(\lblDCFadeOutOthersAction)
                EndIf
                ; now resize gadgets according to the maximum width just calculated
                ResizeGadget(\lblDCFadeUpAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\lblDCFadeDownAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\lblDCFadeOutOthersAction, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                nLeft = GadgetX(\lblDCFadeUpAction) + GadgetWidth(\lblDCFadeUpAction) + gnGap
                setComboBoxesWidth(-1, \cboDCFadeUpAction, \cboDCFadeDownAction, \cboDCFadeOutOthersAction)
                ResizeGadget(\cboDCFadeUpAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\cboDCFadeDownAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\cboDCFadeOutOthersAction, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nLeft = GadgetX(\cboDCFadeUpAction) + GadgetWidth(\cboDCFadeUpAction) + gnGap
                ResizeGadget(\txtDCFadeUpTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\txtDCFadeDownTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\txtDCFadeOutOthersTime, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nLeft = GadgetX(\txtDCFadeUpTime) + GadgetWidth(\txtDCFadeUpTime) + gnGap
                ResizeGadget(\lblDCFadeUpSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\lblDCFadeDownSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                ResizeGadget(\lblDCFadeOutOthersSeconds, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                nWidth = GadgetX(\lblDCFadeUpSeconds) + GadgetWidth(\lblDCFadeUpSeconds) + GadgetX(\lblDCFadeUpAction) + 2
                ResizeGadget(\cntDCFadeUp, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\cntDCFadeDown, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
                ResizeGadget(\cntDCFadeOutOthers, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
              CompilerEndIf
              
            scsCloseGadgetList() ; cntFades
            
          scsCloseGadgetList()   ; cntDMX
          
          CompilerIf 1=2 ; blocked out 10Jul2023 11.10.0bq as 'fade out others' replaces this
            nLeft = GadgetX(\cntDMX) + 12
            nTop = GadgetY(\cntDMX) - 34
            nWidth = GadgetWidth(\cntDMX) - 24
            \lblCaptureInfoMsg=scsTextGadget(nLeft,nTop,nWidth,30,"",0,"lblCaptureInfoMsg")
            setVisible(\lblCaptureInfoMsg,#False)
          CompilerEndIf
          
          ;INFO: Lighting Cue Test Panel (\cntTest is for the grey panel containing the 'Live DMX Test' checkbox, etc)
          nLeft = GadgetX(\cntDMX)
          nHeight = 62
          nTop = GadgetHeight(\cntSubDetailK) - nHeight - 4
          nWidth = GadgetWidth(\cntDMX) - 12
          \cntTest=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntTest")
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            
            \cntTestBtns=scsContainerGadget(0,4,GadgetWidth(\cntTest),54,#PB_Container_BorderLess,"cntTestBtns")
              SetGadgetColor(\cntTestBtns,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\cntTestBtns, #False)
              nLeft = 24
              nTop = 5
              sChkBoxText = Lang("WQK","chkDoNotBlackoutOthers")
              nChkBoxWidth = GetTextWidth(sChkBoxText,#SCS_FONT_CUE_BOLD) + 20
              \chkDoNotBlackoutOthers=scsCheckBoxGadget2(nLeft,nTop,nChkBoxWidth,17,sChkBoxText,0,"chkDoNotBlackoutOthers")
              scsToolTip(\chkDoNotBlackoutOthers,Lang("WQK","chkDoNotBlackoutOthersTT"))
              scsSetGadgetFont(\chkDoNotBlackoutOthers, #SCS_FONT_GEN_BOLD)
              setOwnColor(\chkDoNotBlackoutOthers,#PB_Gadget_FrontColor,#SCS_White)
              setOwnColor(\chkDoNotBlackoutOthers,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\chkDoNotBlackoutOthers, #False)
              nTop + 23
              sChkBoxText = Lang("WQK","chkLiveDMXTest")
              nChkBoxWidth = GetTextWidth(sChkBoxText,#SCS_FONT_CUE_BOLD) + 20
              nLeft = 24
              \chkLiveDMXTest=scsCheckBoxGadget2(nLeft,nTop,nChkBoxWidth,17,sChkBoxText,0,"chkLiveDMXTest")
              scsToolTip(\chkLiveDMXTest,Lang("WQK","chkLiveDMXTestTT"))
              scsSetGadgetFont(\chkLiveDMXTest, #SCS_FONT_GEN_BOLD)
              setOwnColor(\chkLiveDMXTest,#PB_Gadget_FrontColor,#SCS_White)
              setOwnColor(\chkLiveDMXTest,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\chkLiveDMXTest, #False)
              sChkBoxText = Lang("WQK","chkSingleStep")
              nChkBoxWidth = GetTextWidth(sChkBoxText,#SCS_FONT_CUE_BOLD) + 20
              \chkSingleStep=scsCheckBoxGadget2(gnNextX+12,nTop,nChkBoxWidth,17,sChkBoxText,0,"chkSingleStep")
              scsToolTip(\chkSingleStep,Lang("WQK","chkSingleStepTT"))
              scsSetGadgetFont(\chkSingleStep, #SCS_FONT_GEN_BOLD)
              setOwnColor(\chkSingleStep,#PB_Gadget_FrontColor,#SCS_White)
              setOwnColor(\chkSingleStep,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\chkSingleStep, #False)
              \btnReset=scsButtonGadget(gnNextX+12,nTop,120,21,Lang("WQK","btnReset"),0,"btnReset")
              setGadgetWidth(\btnReset)
            scsCloseGadgetList()
            
          scsCloseGadgetList() ; cntTest
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaLighting
      
      ;setVisible(WQK\scaLighting, #True)
      setEnabled(WQK\scaLighting, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQKCreated = #True
  
EndProcedure

Structure strWQL ; fmEditQL
  SUBCUE_HEADER_FIELDS()
  btnLCCenter.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  btnLCPause.i
  btnLCPlay.i
  btnLCRewind.i
  btnLCStop.i
  btnTempoEtcReset.i
  cboLCAction.i
  cboLCCue.i
  cboLCType.i
  chkLCInclude.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  chkLCSameLevel.i
  chkLCSameTime.i
  btnLCReset.i
  btnTestLevelChange.i
  cntLCComment.i
  cntLCDevs.i
  cntLCInfoBelowDevs.i
  cntLCTempoEtc.i
  cntSubDetailL.i
  cntTest.i
  lblAudStatus.i ; status of target aAud
  lblChangeTime.i
  lblCueToAdjust.i
  lbldB.i
  lblDevNo.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblDevice.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblLCAction.i
  lblLCComment.i
  lblLCInclude.i
  lblLCInfo.i
  lblLCSubStatus.i ; status of this level change sub
  lblLCTempoEtcInfo.i
  lblLCTempoEtcTime.i
  lblLCTempoEtcSeconds.i
  lblLCTempoEtcValue.i
  lblLCTestSeconds.i
  lblLCTestStartAt.i
  lblLCTrim.i
  lblLCType.i
  lblReqdDBChange.i
  lblReqdNewLevel.i
  lblReqdNewPan.i
  lblSoundCueControl.i
  lnTestLine.i
  scaLCDevs.i
  scaLevelChange.i
  sldLCLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldLCPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldLCProgress.i
  sldLCTempoEtcValue.i
  txtLCDBActualLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtLCDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtLCPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtLCStartAt.i
  txtLCTempoEtcTime.i
  txtLCTempoEtcValue.i
  txtLCTime.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtLCTrim.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
EndStructure
Global WQL.strWQL ; fmEditQL

Procedure createfmEditQL()
  PROCNAMEC()
  Protected n, sNr.s
  Protected nTop, nLeft1, nWidth1, nLeft2, nWidth, nHeight
  Protected nDevInnerWidth, nDevInnerHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQL
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQL
      \scaLevelChange=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaLevelChange")
        setVisible(\scaLevelChange, #False)
        ; header
        SUBCUE_HEADER_CODE(WQL)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailL=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,#PB_Container_BorderLess,"cntSubDetailL")
          nLeft1 = 0
          nWidth1 = 173
          nLeft2 = nLeft1 + nWidth1 + GnGap
          nTop = 12
          \lblCueToAdjust=scsTextGadget(nLeft1,nTop-gnLblVOffsetC,nWidth1,30,Lang("WQL","lblCueToAdjust"), #PB_Text_Right,"lblCueToAdjust")
          \cboLCCue=scsComboBoxGadget(nLeft2,nTop,293,21,0,"cboLCCue")
          scsToolTip(\cboLCCue,Lang("WQL","cboLCCueTT"))
          nTop + 31
          \lblLCAction=scsTextGadget(nLeft1,nTop+gnLblVOffsetC,nWidth1,15,Lang("WQL","lblLCAction"),#PB_Text_Right,"lblLCAction")
          \cboLCAction=scsComboBoxGadget(nLeft2,nTop,95,21,0,"cboLCAction")
          nTop + 29
          \cntLCDevs=scsContainerGadget(nLeft1,nTop,GadgetWidth(\cntSubDetailL),171,#PB_Container_BorderLess,"cntLCDevs")
            nTop = 0
            \chkLCSameLevel=scsCheckBoxGadget2(nLeft2,nTop,450,17,Lang("WQL","chkLCSameLevel"),0,"chkLCSameLevel")
            nTop + 17
            \chkLCSameTime=scsCheckBoxGadget2(nLeft2,nTop,300,17,Lang("WQL","chkLCSameTime"),0,"chkLCSameTime")
            nTop + 17
            ; devices
            ; DISPLAY ALL HEADINGS AS 3 LINES
            nHeight = 42
            \lblLCInclude=scsTextGadget(61,nTop,50,nHeight,Lang("WQL","lblLCInclude"), #PB_Text_Center,"lblLCInclude")
            \lblLCTrim=scsTextGadget(105,nTop,35,nHeight,Chr(10)+Chr(10)+Lang("Common","Trim"), #PB_Text_Center, "lblLCTrim")
            ; absolute level change
            \lblReqdNewLevel=scsTextGadget(152,nTop,113,nHeight,Chr(10)+Lang("WQL","lblReqdNewLevel"), #PB_Text_Center,"lblReqdNewLevel")
            \lbldB=scsTextGadget(272,nTop,35,nHeight,Chr(10)+Chr(10)+"dB", #PB_Text_Center, "lbldB")
            ; relative level change
            \lblReqdDBChange=scsTextGadget(152,nTop,102,nHeight,Chr(10)+Lang("WQL","lblReqdDBChange"), #PB_Text_Center,"lblReqdDBChange")
            setVisible(\lblReqdDBChange, #False)
            ; pan
            \lblReqdNewPan=scsTextGadget(318,nTop,105,nHeight,Chr(10)+Lang("WQL","lblReqdNewPan"), #PB_Text_Center,"lblReqdNewPan")
            ; duration of change
            \lblChangeTime=scsTextGadget(510,nTop,87,nHeight,Lang("WQL","lblChangeTime"), #PB_Text_Center,"lblChangeTime")
            nTop + 46
            
            nDevInnerHeight = (grLicInfo\nMaxAudDevPerAud + 1) * (22)
            nDevInnerWidth = 620 - glScrollBarWidth - gl3DBorderAllowanceX
            nHeight = GadgetHeight(\cntLCDevs) - nTop - 3
            \scaLCDevs=scsScrollAreaGadget(5,nTop,620,nHeight,nDevInnerWidth, nDevInnerHeight, 22, #PB_ScrollArea_BorderLess, "scaLCDevs")
              For n = 0 To grLicInfo\nMaxAudDevPerAud
                nTop = n * (22)
                sNr = "["+n+"]"
                \lblDevNo[n]=scsTextGadget(0,nTop+gnLblVOffsetS,17,15,Str(n+1), #PB_Text_Right,"lblDevNo"+sNr)
                \lblDevice[n]=scsTextGadget(25,nTop+gnLblVOffsetS,50,15,grText\sTextDevice, #PB_Text_Right,"lblDevice"+sNr)
                \chkLCInclude[n]=scsCheckBoxGadget2(80,nTop+gnLblVOffsetS,18,17,"",0,"chkLCInclude"+sNr)
                scsToolTip(\chkLCInclude[n],Lang("WQL","chkLCIncludeTT"))
                setOwnState(\chkLCInclude[n], #True)
                \txtLCTrim[n]=scsStringGadget(gnNextX+gnGap,nTop,30,21,"",0,"txtLCTrim"+sNr)
                setEnabled(\txtLCTrim[n],#False)
                \sldLCLevel[n]=SLD_New("QL_Level_"+Str(n+1),\scaLCDevs,0,gnNextX+gnGap,nTop,129,21,#SCS_ST_HLEVELNODB,0,10000)
                \txtLCDBLevel[n]=scsStringGadget(gnNextX,nTop,44,21,"",0,"txtLCDBLevel"+sNr)
                \sldLCPan[n]=SLD_New("QL_Pan_"+Str(n+1),\scaLCDevs,0,gnNextX+gnGap,nTop,105,21,#SCS_ST_PAN,0,1000)
                \btnLCCenter[n]=scsButtonGadget(gnNextX,nTop,46,21,Lang("Btns","Center"),0,"btnLCCenter"+sNr)
                scsToolTip(\btnLCCenter[n],Lang("Btns","CenterTT"))
                \txtLCPan[n]=scsStringGadget(gnNextX,nTop,52,21,"",#PB_String_Numeric,"txtLCPan"+sNr)
                \txtLCTime[n]=scsStringGadget(gnNextX+3,nTop,65,21,"",0,"txtLCTime"+sNr)
                scsToolTip(\txtLCTime[n],Lang("WQL","txtLCTimeTT"))
                setValidChars(\txtLCTime[n], "0123456789.:") ; will be disabled on 'GetFocus' if the parent cue is a callable cue
                \txtLCDBActualLevel[n]=scsStringGadget(gnNextX,nTop,60,21,"",#PB_String_ReadOnly,"txtLCDBActualLevel"+sNr)
                setVisible(\txtLCDBActualLevel[n],#False)
              Next n
            scsCloseGadgetList()
          scsCloseGadgetList()
          
          ; tempo, etc
          nTop = GadgetY(\cntLCDevs)
          \cntLCTempoEtc=scsContainerGadget(0,nTop,GadgetWidth(\cntLCDevs),80,#PB_Container_BorderLess,"cntLCTempoEtc")
            nTop = 0
            nHeight = 15
            \lblLCTempoEtcValue=scsTextGadget(nLeft1,nTop+gnLblVOffsetS,nWidth1,nHeight,"",#PB_Text_Right,"lblLCTempoEtcValue")
            \sldLCTempoEtcValue=SLD_New("QL_Tempo",\cntLCTempoEtc,0,nLeft2,nTop,200,21,#SCS_ST_HGENERAL,-1000,1000)
            \txtLCTempoEtcValue=scsStringGadget(gnNextX,nTop,44,21,"",0,"txtLCTempoEtcValue")
            \lblLCTempoEtcInfo=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,100,nHeight,"",0,"lblLCTempoEtcInfo")
            nTop + 28
            \btnTempoEtcReset=scsButtonGadget(nLeft2,nTop,120,gnBtnHeight,LangPars("Btns","btnTempoEtcReset","123456"),0,"btnTempoEtcReset")
            ; button text will be set dynamically, so this initial text setting is just to enable the maximum required width to be calculated
            setGadgetWidth(\btnTempoEtcReset)
            nTop + 30
            \lblLCTempoEtcTime=scsTextGadget(nLeft1,nTop+gnLblVOffsetS,nWidth1,nHeight,Lang("WQL","lblLCTempoEtcTime"),#PB_Text_Right,"lblLCTempoEtcTime")
            \txtLCTempoEtcTime=scsStringGadget(nLeft2,nTop,44,21,"",0,"txtLCTempoEtcTime")
            \lblLCTempoEtcSeconds=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,80,nHeight,Lang("Common","Seconds"),0,"lblLCTempoEtcSeconds")
          scsCloseGadgetList()
          setVisible(\cntLCTempoEtc, #False)
          
          nTop = GadgetY(\cntLCDevs) + GadgetHeight(\cntLCDevs)
          nWidth = GadgetWidth(\cntSubDetailL)
          \cntLCInfoBelowDevs=scsContainerGadget(0,nTop,nWidth,54,#PB_Container_BorderLess,"cntLCInfoBelowDevs")
            \lblLCType=scsTextGadget(64,4,93,15,Lang("WQL","lblLCType"), #PB_Text_Right,"lblLCType")  ; "Level Change Type"
            \cboLCType=scsComboBoxGadget(gnNextX+7,0,180,21,0,"cboLCType")
            scsToolTip(\cboLCType,Lang("WQL","cboLCTypeTT"))
            \btnLCReset=scsButtonGadget(gnNextX+30,0,135,21,Lang("WQL","btnLCReset"),0,"btnLCReset") ; "Reset Level and Pan" button
            scsToolTip(\btnLCReset,Lang("WQL","btnLCResetTT"))
            \lblLCComment=scsTextGadget(61,24,515,28,"", #PB_Text_Center,"lblLCComment")
            setReverseEditorColors(\lblLCComment, #True)
          scsCloseGadgetList()
          
          ; test
          nTop = GadgetY(\cntLCInfoBelowDevs) + GadgetHeight(\cntLCInfoBelowDevs)
          \cntTest=scsContainerGadget(49,71,539,95,#PB_Container_Flat,"cntTest")
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            \lblSoundCueControl=scsTextGadget(10,7,105,15,Lang("WQL","lblSoundCueControl"), #PB_Text_Right,"lblSoundCueControl")
            scsSetGadgetFont(\lblSoundCueControl, #SCS_FONT_GEN_BOLD)
            SetGadgetColors(\lblSoundCueControl, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblSoundCueControl, #False)
            ; transport controls
            \btnLCRewind=scsStandardButton(120,2,24,24,#SCS_STANDARD_BTN_REWIND,"btnLCRewind")
            \btnLCPlay=scsStandardButton(144,2,24,24,#SCS_STANDARD_BTN_PLAY,"btnLCPlay")
            scsToolTip(\btnLCPlay,Lang("WQL","btnLCPlayTT"))   ; different tooltip for LC play button
            \btnLCPause=scsStandardButton(144,2,24,24,#SCS_STANDARD_BTN_PAUSE,"btnLCPause")
            setVisible(\btnLCPause, #False)
            \btnLCStop=scsStandardButton(168,2,24,24,#SCS_STANDARD_BTN_STOP,"btnLCStop")
            
            \lblLCTestStartAt=scsTextGadget(244,7,142,15,Lang("WQL","lblLCTestStartAt"), #PB_Text_Right,"lblLCTestStartAt")
            SetGadgetColors(\lblLCTestStartAt, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblLCTestStartAt, #False)
            \txtLCStartAt=scsStringGadget(390,4,50,21,"",0,"txtLCStartAt")
            scsToolTip(\txtLCStartAt,Lang("WQL","txtLCStartAtTT"))
            \lblLCTestSeconds=scsTextGadget(444,7,40,15,Lang("WQL","lblLCTestSeconds"),0,"lblLCTestSeconds")
            SetGadgetColors(\lblLCTestSeconds, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblLCTestSeconds, #False)
            
            \lblAudStatus=scsTextGadget(9,28,184,15,"", #PB_Text_Center,"lblAudStatus")
            scsSetGadgetFont(\lblAudStatus, #SCS_FONT_GEN_BOLD)
            SetGadgetColors(\lblAudStatus, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblAudStatus, #False)
            \lblLCInfo=scsTextGadget(216,28,292,15,"", #PB_Text_Center,"lblLCInfo")
            scsSetGadgetFont(\lblLCInfo, #SCS_FONT_GEN_BOLD)
            SetGadgetColors(\lblLCInfo, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblLCInfo, #False)
            
            ; line
            \lnTestLine=scsLineGadget(0,48,540,1,$E0E0E0,0,"lnTestLine")
            
            \btnTestLevelChange=scsButtonGadget(27,53,150,gnBtnHeight,Lang("WQL","btnTestLevelChange2"),0,"btnTestLevelChange") ; "Test Level/Pan Change" button
            ; scsToolTip(\btnTestLevelChange,Lang("WQL","btnTestLevelChangeTT")) ; commented out, or we would need to dynamically change and refresh the tooltip text, as we now do with the button itself
            \sldLCProgress=SLD_New("QL_Progress",\cntTest,0,227,54,271,20,#SCS_ST_PROGRESS,0,1000)
            \lblLCSubStatus=scsTextGadget(9,78,184,15,"", #PB_Text_Center,"lblLCSubStatus")
            scsSetGadgetFont(\lblLCSubStatus, #SCS_FONT_GEN_BOLD)
            SetGadgetColors(\lblLCSubStatus, #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblLCSubStatus, #False)
            
          scsCloseGadgetList() ; cntTest
          
        scsCloseGadgetList()  ; cntSubDetailL
        
      scsCloseGadgetList() ; scaLevelChange
      
      ; setVisible(WQL\scaLevelChange, #True)
      setEnabled(WQL\scaLevelChange, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQLCreated = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Structure strWQM ; fmEditQM
  SUBCUE_HEADER_FIELDS()
  btnBrowse.i
  btnEditPause.i
  btnEditPlay.i
  btnEditRewind.i
  btnEditScribbleStrip.i
  btnEditStop.i
  btnMidiCapture.i
  btnNRPNCapture.i
  btnNRPNSave.i
  btnTestCtrlSend.i[4]
  btnX32Capture.i
  cboCtrlMidiRemoteDev.i
  cboCtrlNetworkRemoteDev.i
  cboLogicalDev.i
  cboMFEntryMode.i
  cboMSChannel.i
  cboMSMacro.i
  cboMSParam1.i
  cboMSParam2.i
  cboMSParam3.i
  cboMSParam4.i
  cboMidiCapturePort.i
  cboMsgType.i
  cboNRPNCapturePort.i
  cboNWEntryMode.i
  cboOSCCmdType.i
  cboOSCItemSelect.i
  cboOSCParam1.i
  cboRemDevCboItem.i
  cboRSEntryMode.i
  chkNWAddCR.i
  chkNWAddLF.i
  chkOSCReloadNamesGoCue.i
  chkOSCReloadNamesGoScene.i
  chkOSCReloadNamesGoSnippet.i
  chkRSAddCR.i
  chkRSAddLF.i
  cntCtrlSendSideBar.i
  cntHTTP1.i
  cntHTTP2.i
  cntLiveDMXTest.i
  cntMidi.i
  cntMidiCapture.i
  cntMidiFile.i
  cntMidiFreeFormat.i
  cntMidiMsg.i
  cntMidiStructured.i
  cntNRPNCapture.i
  cntNetwork.i
  cntOSC.i
  cntOSCItem.i
  cntOSCFaderEtc.i
  cntOSCMsg.i
  cntOSCOverMidi.i
  cntOther.i
  cntRS232.i
  cntRemDev.i
  cntRemDevTest.i
  cntSubDetailM.i
  cntTest.i
  cntTestBtns.i
  cntTestMidiFile.i
  cvsRemDevMute.i
  fraMidiCapture.i
  grdCtrlSends.i
  grdOSCGrdItem.i
  grdRemDevGrdItem.i
  imgButtonTBS.i[4]
  lblChannel.i
  lblCtrlMidiRemoteDev.i
  lblCtrlNetworkRemoteDev.i
  lblCueDuration.i
  lblEditMidiInfo.i[2]
  lblEndAt.i
  lblFileDuration.i
  lblHTEnteredString.i
  lblHTItemDesc.i
  lblHTTPMsg.i
  lblInfo.i
  lblLogicalDev.i
  lblMFEnteredString.i
  lblMFEntryMode.i
  lblMSItemDesc.i
  lblMSMacro.i
  lblMidiCaptureDone.i
  lblMidiCapturePort.i
  lblMidiFile.i
  lblMidiMsg.i
  lblMsgType.i
  lblMsgTypeEmphasis.i
  lblNRPNCapturePort.i
  lblNWEnteredString.i
  lblNWEntryMode.i
  lblNWItemDesc.i
  lblOMEnteredString.i
  lblOSCCmdType.i
  lblOSCEnteredString.i
  lblOSCFader.i
  lblOSCItemSelect.i
  lblOSCMsg.i
  lblOSCParam1.i
  lblParam1.i ; added for NRPN
  lblParam2.i
  lblParam3.i
  lblParam4.i
  lblQList.i
  lblQNumber.i
  lblQPath.i
  lblRemDevAction.i
  lblRemDevCboItem.i
  lblRemDevFader.i
  lblHttpResponse.i
  lblRSDevice.i
  lblRSEnteredString.i
  lblRSEntryMode.i
  lblRSItemDesc.i
  lblStartAt.i
  lblTestMidiFile.i
  scaCtrlSend.i
  shpMoverTBS.i
  sldOSCFader.i
  sldProgress.i
  sldRemDevFader.i
  txtCueDuration.i
  txtEndAt.i
  txtFileDuration.i
  txtHTEnteredString.i
  txtHTItemDesc.i
  txtHTTPMsg.i
  txtHttpResponse.i
  txtMFEnteredString.i
  txtMSItemDesc.i
  txtMSParam1Info.i ; added for NRPN
  txtMSParam2Info.i
  txtMSParam3Info.i
  txtMSParam4Info.i
  txtMidiFile.i
  txtMidiMsg.i
  txtNRPNCapture.i
  txtNWEnteredString.i
  txtNWItemDesc.i
  txtOMEnteredString.i
  txtOSCDevDBLevel.i
  txtOSCEnteredString.i
  txtOSCItemString.i
  txtOSCMsg.i
  txtQList.i
  txtQNumber.i
  txtQPath.i
  txtRemDevDBLevel.i
  txtRSEnteredString.i
  txtRSItemDesc.i
  txtStartAt.i
  nQFieldsTop.i
  nQLblFieldsYOffset.i
  nQFieldsHeight.i
EndStructure
Global WQM.strWQM ; fmEditQM

Procedure createfmEditQM()
  PROCNAMEC()
  Protected n, nTop, sNr.s, nLeft, nWidth, nHeight, nWidth2, nWidth3
  Protected nDevInnerWidth, nDevInnerHeight
  Protected sChkBoxText.s, nChkBoxWidth
  Protected sLblText.s, nLblWidth
  Protected nTopHold, nMSParamFlags, sInfoTooltip.s
  Protected nInfoCntLeft, nInfoCntTop, nInfoCntWidth, nInfoCntHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQM
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQM
      \scaCtrlSend=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, 0, "scaCtrlSend")
        setVisible(\scaCtrlSend, #False)
        ; header
        SUBCUE_HEADER_CODE(WQM)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailM=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailM")
          
          ; sidebar
          \cntCtrlSendSideBar=scsContainerGadget(1,25,20,96,0,"cntCtrlSendSideBar")
            \imgButtonTBS[0]=scsStandardButton(0,0,20,20,#SCS_STANDARD_BTN_MOVE_UP,"imgButtonTBS[0]",#True)
            \imgButtonTBS[1]=scsStandardButton(0,20,20,20,#SCS_STANDARD_BTN_MOVE_DOWN,"imgButtonTBS[1]",#True)
            \imgButtonTBS[2]=scsStandardButton(0,40,20,20,#SCS_STANDARD_BTN_PLUS,"imgButtonTBS[2]",#True)
            \imgButtonTBS[3]=scsStandardButton(0,60,20,20,#SCS_STANDARD_BTN_MINUS,"imgButtonTBS[3]",#True)
          scsCloseGadgetList() ; cntCtrlSendSideBar
          
          \grdCtrlSends=scsListIconGadget(22,0,280,184,"#",25,#PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect,"grdCtrlSends")
          AddGadgetColumn(\grdCtrlSends, 1, Lang("WQM", "ControlMessage"), 50)
          autoFitGridCol(\grdCtrlSends,1) ; autofit 2nd column
          
          nTop = 6
          \lblLogicalDev=scsTextGadget(305,nTop+4,110,17,Lang("Common","Device"),#PB_Text_Right,"lblLogicalDev")
          \cboLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,150,21,0,"cboLogicalDev")
          nTop + 23
          
          ; control message info
          ; NOTE: set position and size to be used by all the info control containers
          nInfoCntLeft = 305
          nInfoCntTop = nTop
          nInfoCntWidth = gnEditorScaPropertiesInnerWidth - nInfoCntLeft
          nInfoCntHeight = 273
          
          ; INFO Control Send: MIDI
          \cntMidi=scsContainerGadget(nInfoCntLeft,nInfoCntTop,nInfoCntWidth,nInfoCntHeight,0,"cntMidi")
            nTop = 0
            \lblMSItemDesc=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblItemDesc"), #PB_Text_Right,"lblMSItemDesc")
            \txtMSItemDesc=scsStringGadget(gnNextX+gnGap,nTop,70,21,"",0,"txtItemMSDesc") ; deliberately short as the entry will be used to prefix the display info
            SetGadgetAttribute(\txtMSItemDesc, #PB_String_MaximumLength, 10)
            scsToolTip(\txtMSItemDesc,LangPars("WQM","txtItemDescTT", "10"))
            nTop + 23
            If grLicInfo\bCSRDAvailable
              nWidth = (GadgetX(\lblLogicalDev) - GadgetX(\cntMidi)) + GadgetWidth(\lblLogicalDev)
              \lblCtrlMidiRemoteDev=scsTextGadget(0,nTop+4,nWidth,17,Lang("WQM","RemoteDev"),#PB_Text_Right,"lblCtrlMidiRemoteDev")
              \cboCtrlMidiRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboCtrlMidiRemoteDev")
              setEnabled(\cboCtrlMidiRemoteDev,#False)
              nTop + 23
            EndIf
            \lblMsgType=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblMsgType"), #PB_Text_Right,"lblMsgType")
            \cboMsgType=scsComboBoxGadget(gnNextX+gnGap,nTop,180,21,0,"cboMsgType")
            nTop + 23
            
            \cntMidiStructured=scsContainerGadget(0,nTop,GadgetWidth(\cntMidi),GadgetHeight(\cntMidi)-nTop,0,"cntMidiStructured")
              nMSParamFlags = #PB_ComboBox_Editable|#PB_ComboBox_UpperCase
              sInfoTooltip = Lang("WQM", "txtMSParamTT")
              nTop = 0
              \lblChannel=scsTextGadget(0,nTop+4,110,17,"", #PB_Text_Right,"lblChannel")
              \cboMSChannel=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,nMSParamFlags,"cboMSChannel")
              nTop + 21
              ; NOTE: See also WQM_fcCboMsMsgType() where \cboMSParam1/2/3/4 may be resized, so the common width is '80'
              \lblParam1=scsTextGadget(0,nTop+4,110,17,"", #PB_Text_Right,"lblParam1")
              \cboMSParam1=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,nMSParamFlags,"cboMSParam1")
              \txtMSParam1Info=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtMSParam1Info")
              scsToolTip(\txtMSParam1Info, sInfoTooltip)
              nTop + 21
              \lblParam2=scsTextGadget(0,nTop+4,110,17,"", #PB_Text_Right,"lblParam2")
              \cboMSParam2=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,nMSParamFlags,"cboMSParam2")
              \txtMSParam2Info=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtMSParam2Info")
              scsToolTip(\txtMSParam2Info, sInfoTooltip)
              nTop + 21
              \lblParam3=scsTextGadget(0,nTop+4,110,17,"", #PB_Text_Right,"lblParam3")
              \cboMSParam3=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,nMSParamFlags,"cboMSParam3")
              \txtMSParam3Info=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtMSParam3Info")
              scsToolTip(\txtMSParam3Info, sInfoTooltip)
              nTop + 21
              \lblParam4=scsTextGadget(0,nTop+4,110,17,"", #PB_Text_Right,"lblParam4")
              \cboMSParam4=scsComboBoxGadget(gnNextX+gnGap,nTop,80,21,nMSParamFlags,"cboMSParam4")
              \txtMSParam4Info=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtMSParam4Info")
              scsToolTip(\txtMSParam4Info, sInfoTooltip)
              ; QFields mutually exclusive with Params3 and Params4, which were added Feb2020 for NRPN
              nTop = GadgetY(\cboMSParam3)
              \nQFieldsTop = nTop
              \nQLblFieldsYOffset = 4
              \nQFieldsHeight = 21
              \lblQNumber=scsTextGadget(0,nTop+\nQLblFieldsYOffset,110,17,Lang("WQM","lblQNumber1"), #PB_Text_Right,"lblQNumber")  ; "Q Number"
              \txtQNumber=scsStringGadget(gnNextX+gnGap,nTop,99,\nQFieldsHeight,"",0,"txtQNumber")
              scsToolTip(\txtQNumber,Lang("WQM","txtQNumber1TT"))
              nTop + \nQFieldsHeight
              \lblQList=scsTextGadget(0,nTop+\nQLblFieldsYOffset,110,17,Lang("WQM","lblQList1"), #PB_Text_Right,"lblQList")  ; "Q List"
              \txtQList=scsStringGadget(gnNextX+gnGap,nTop,99,\nQFieldsHeight,"",0,"txtQList")
              scsToolTip(\txtQList,Lang("WQM","txtQList1TT"))
              nTop + \nQFieldsHeight
              \lblQPath=scsTextGadget(0,nTop+\nQLblFieldsYOffset,110,17,Lang("WQM","lblQPath1"), #PB_Text_Right,"lblQPath")  ; "Q Path"
              \txtQPath=scsStringGadget(gnNextX+gnGap,nTop,99,\nQFieldsHeight,"",0,"txtQPath")
              scsToolTip(\txtQPath,Lang("WQM","txtQPath1TT"))
              ; MSMacro in same position as QNumber (mutally exclusive so never displayed together)
              nTop = \nQFieldsTop
              \lblMSMacro=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblMSMacro"), #PB_Text_Right,"lblMSMacro")
              \cboMSMacro=scsComboBoxGadget(gnNextX+gnGap,nTop,99,21,nMSParamFlags,"cboMSMacro")
              setVisible(\lblMSMacro, #False)
              setVisible(\cboMSMacro, #False)
              
              \lblMsgTypeEmphasis=scsTextGadget(95,100,90,21,"",#PB_Text_Center,"lblMsgTypeEmphasis")
              scsSetGadgetFont(\lblMsgTypeEmphasis, #SCS_FONT_GEN_BOLD10)
              setVisible(\lblMsgTypeEmphasis, #False)
              
              nTop = GadgetY(\cboMSParam4) + 28
              \cntNRPNCapture=scsContainerGadget(0,nTop,320,79,#PB_Container_Flat,"cntNRPNCapture")
                nTop = 4
                \lblNRPNCapturePort=scsTextGadget(2,nTop+4,108,17,Lang("WQM","lblNRPNCapturePort"),#PB_Text_Right,"lblNRPNCapturePort")
                setGadgetWidth(\lblNRPNCapturePort, 108, #True)
                nLeft = gnNextX + gnGap
                nWidth = GadgetWidth(\cntNRPNCapture) - nLeft - 2
                If nWidth > 170
                  nWidth = 170
                EndIf
                \cboNRPNCapturePort=scsComboBoxGadget(gnNextX+gnGap,nTop,nWidth,21,0,"cboNRPNCapturePort")
                nTop + 23
                nLeft = 8
                nWidth = GadgetWidth(\cntNRPNCapture) - (nLeft * 2)
                \txtNRPNCapture=scsStringGadget(nLeft,nTop,nWidth,21,"",#PB_String_ReadOnly,"txtNRPNCapture")
                nTop + 23
                nWidth = getMaxTextWidth(100, Lang("WQM","btnNRPNCapture"), Lang("WQM","CancelNRPNCapture"), LangPars("WQM","btnNRPNSave","1")) + 16 ; +16 to allow for button width padding
                If ((nWidth * 2) + gnGap2) > GadgetWidth(\cntNRPNCapture)
                  nWidth = (GadgetWidth(\cntNRPNCapture) - gnGap) >> 1
                EndIf
                nLeft = (GadgetWidth(\cntNRPNCapture) - 2 - (nWidth * 2) - gnGap) >> 1
                \btnNRPNCapture=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,Lang("WQM","btnNRPNCapture"),0,"btnNRPNCapture")
                \btnNRPNSave=scsButtonGadget(gnNextX+gnGap,nTop,nWidth,gnBtnHeight,LangPars("WQM","btnNRPNSave","1"),0,"btnNRPNSave")
              scsCloseGadgetList()
              setVisible(\cntNRPNCapture, #False)

            scsCloseGadgetList()
            setVisible(\cntMidiStructured, #False)
            
            \cntMidiFreeFormat=scsContainerGadget(0,GadgetY(\cntMidiStructured),GadgetWidth(\cntMidiStructured),GadgetHeight(\cntMidiStructured),0,"cntMidiFreeFormat")   ; cntMidiFreeFormat
              nTop = 0
              \lblMFEntryMode=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblEntryMode"), #PB_Text_Right,"lblMFEntryMode")
              \cboMFEntryMode=scsComboBoxGadget(gnNextX+gnGap,nTop,99,21,0,"cboMFEntryMode")
              nTop + 21
              \lblMFEnteredString=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblMFEnteredString"), #PB_Text_Right,"lblMFEnteredString")
              \txtMFEnteredString=scsStringGadget(gnNextX+gnGap,nTop,218,21,"",0,"txtMFEnteredString")
              nTop + 33
              \cntMidiCapture=scsContainerGadget(0,nTop,333,86,0,"cntMidiCapture")
                \fraMidiCapture=scsFrameGadget(0,0,333,86,Lang("WQM","fraMidiCapture"),0,"fraMidiCapture")
                nTop = 23
                \lblMidiCapturePort=scsTextGadget(4,nTop+4,106,17,Lang("WQM","lblMidiCapturePort"),#PB_Text_Right,"lblMidiCapturePort")
                \cboMidiCapturePort=scsComboBoxGadget(gnNextX+gnGap,nTop,170,21,0,"cboMidiCapturePort")
                nTop + 28
                \lblMidiCaptureDone=scsTextGadget(4,nTop+4,106,17,"",#PB_Text_Right,"lblMidiCaptureDone")
                \btnMidiCapture=scsButtonGadget(gnNextX+gnGap,nTop,170,gnBtnHeight,Lang("WQM","CaptureNext"),0,"btnMidiCapture")
                scsSetGadgetFont(\lblMidiCaptureDone,#SCS_FONT_GEN_ITALIC)
              scsCloseGadgetList()
            scsCloseGadgetList()
            setVisible(\cntMidiFreeFormat, #False)
            
            \cntOSCOverMidi=scsContainerGadget(0,GadgetY(\cntMidiStructured),GadgetWidth(\cntMidiStructured),GadgetHeight(\cntMidiStructured),0,"cntOSCOverMidi")   ; cntOSCOverMidi
              nTop = 0
              \lblOMEnteredString=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblOMEnteredString"), #PB_Text_Right,"lblOMEnteredString")
              \txtOMEnteredString=scsStringGadget(gnNextX+gnGap,nTop,218,21,"",0,"txtOMEnteredString")
            scsCloseGadgetList()
            setVisible(\cntOSCOverMidi, #False)
            
            \cntMidiFile=scsContainerGadget(0,GadgetY(\cntMidiStructured),GadgetWidth(\cntMidiStructured),GadgetHeight(\cntMidiStructured),0,"cntMidiFile")   ; cntMidiFile
              nTop = 8
              \lblMidiFile=scsTextGadget(0,nTop+4,58,15,Lang("WQM","lblMidiFile"),#PB_Text_Right,"lblMidiFile")
              \txtMidiFile=scsStringGadget(gnNextX+gnGap,nTop,232,21,"",0,"txtMidiFile")
              setEnabled(\txtMidiFile, #False)
              scsToolTip(\txtMidiFile,Lang("WQM","txtMidiFileTT"))
              \btnBrowse=scsButtonGadget(gnNextX+1,nTop+1,20,20,"...",0,"btnBrowse")
              scsToolTip(\btnBrowse,Lang("WQM","btnBrowseTT"))
              nTop + 28
              \lblFileDuration=scsTextGadget(0,nTop+4,110,15,Lang("WQM","lblFileDuration"),#PB_Text_Right,"lblFileDuration") ; "File length"
              \txtFileDuration=scsStringGadget(gnNextX+gnGap,nTop,57,21,"",#PB_String_ReadOnly,"txtFileDuration")
              setEnabled(\txtFileDuration, #False)
              nTop + 21
              \lblStartAt=scsTextGadget(0,nTop+4,110,15,Lang("Common","StartAt"),#PB_Text_Right,"lblStartAt") ; "Start at"
              \txtStartAt=scsStringGadget(gnNextX+gnGap,nTop,57,21,"",0,"txtStartAt")
              scsToolTip(\txtStartAt,Lang("WQM","txtStartAtTT"))
              nTop + 21
              \lblEndAt=scsTextGadget(0,nTop+4,110,15,Lang("Common","EndAt"),#PB_Text_Right,"lblEndAt")  ; "End at"
              \txtEndAt=scsStringGadget(gnNextX+gnGap,nTop,57,21,"",0,"txtEndAt")
              scsToolTip(\txtEndAt,Lang("WQM","txtEndAtTT"))
              nTop + 21
              \lblCueDuration=scsTextGadget(0,nTop+4,110,15,Lang("WQM","lblCueDuration"),#PB_Text_Right,"lblCueDuration")  ; "Play length"
              \txtCueDuration=scsStringGadget(gnNextX+gnGap,nTop,57,21,"",#PB_String_ReadOnly,"txtCueDuration")
              setEnabled(\txtCueDuration, #False)
            scsCloseGadgetList()
            setVisible(\cntMidiFile, #False)
            
            \cntRemDev=scsContainerGadget(0,GadgetY(\cntMidiStructured),GadgetWidth(\cntMidiStructured),GadgetHeight(\cntMidiStructured),0,"cntRemDev")   ; cntRemDev
              nTop = 0
              \lblRemDevAction=scsTextGadget(0,nTop+4,110,17,Lang("WQM","Action"),#PB_Text_Right,"lblRemDevAction")
              \cvsRemDevMute=scsCanvasGadget(gnNextX+gnGap,nTop+2,60,17,0,"cvsRemDevMute")
              
              nTop = 0
              \lblRemDevCboItem=scsTextGadget(0,nTop+4,110,17,"",#PB_Text_Right,"lblRemDevCboItem")
              nWidth = GadgetWidth(\cboMsgType)
              \cboRemDevCboItem=scsComboBoxGadget(gnNextX+gnGap,nTop,nWidth,21,0,"cboRemDevCboItem")
              setVisible(\lblRemDevCboItem, #False)
              setVisible(\cboRemDevCboItem, #False)
              
              nTop = 0
              \lblRemDevFader=scsTextGadget(0,nTop+4,110,17,"",#PB_Text_Right,"lblRemDevFader")
              nLeft = gnNextX+gnGap
              nWidth = GadgetWidth(\cntRemDev) - nLeft - 44 ; 44 = width of \txtRemDevDBLevel
              \sldRemDevFader=SLD_New("RemDevFader",\cntRemDev,0,nLeft,nTop,nWidth,21,#SCS_ST_REMDEV_FADER_LEVEL,0,1000)
              \txtRemDevDBLevel=scsStringGadget(gnNextX,nTop,44,21,"",0,"txtRemDevDBLevel")
              setVisible(\lblRemDevFader, #False)
              SLD_setVisible(\sldRemDevFader, #False)
              setVisible(\txtRemDevDBLevel, #False)
              
              nTop = 0
              \btnEditScribbleStrip=scsButtonGadget(GadgetX(\cboRemDevCboItem),nTop,GadgetWidth(\cboMsgType),23,LangEllipsis("WQM","btnEditScribbleStrip"),0,"btnEditScribbleStrip")
              setVisible(\btnEditScribbleStrip, #False)
              
              nTop = 23
              nHeight = GadgetHeight(\cntRemDev) - nTop - 8
              \grdRemDevGrdItem=scsListIconGadget(GadgetX(\cboRemDevCboItem),nTop,150,nHeight,"",150-glScrollBarWidth-gl3DBorderAllowanceX,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdRemDevGrdItem")
              setVisible(\grdRemDevGrdItem, #False)
              
            scsCloseGadgetList()
            setVisible(\cntRemDev, #False)
            
          scsCloseGadgetList()
          setVisible(\cntMidi, #False)
          
          ; INFO Control Send: RS232
          \cntRS232=scsContainerGadget(nInfoCntLeft,nInfoCntTop,nInfoCntWidth,nInfoCntHeight,0,"cntRS232")
            nTop = 0
            \lblRSItemDesc=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblItemDesc"), #PB_Text_Right,"lblRSItemDesc")
            \txtRSItemDesc=scsStringGadget(gnNextX+gnGap,nTop,60,21,"",0,"txtRSItemDesc") ; deliberately short as the entry will be used to prefix the display info
            SetGadgetAttribute(\txtRSItemDesc, #PB_String_MaximumLength, 10)
            scsToolTip(\txtRSItemDesc,LangPars("WQM","txtItemDescTT", "10"))
            nTop + 23
            \lblRSEntryMode=scsTextGadget(8,nTop+4,81,17,Lang("WQM","lblEntryMode"), #PB_Text_Right,"lblRSEntryMode")
            \cboRSEntryMode=scsComboBoxGadget(95,nTop,99,21,0,"cboRSEntryMode")
            nTop + 26
            \chkRSAddCR=scsCheckBoxGadget2(95,nTop,229,17,Lang("WQM","chkAddCR"),0,"chkRSAddCR")
            nTop + 18
            \chkRSAddLF=scsCheckBoxGadget2(95,nTop,229,17,Lang("WQM","chkAddLF"),0,"chkRSAddLF")
            nTop + 26
            \lblRSEnteredString=scsTextGadget(8,nTop+4,81,17,Lang("WQM","lblRSEnteredString"), #PB_Text_Right,"lblRSEnteredString")
            \txtRSEnteredString=scsStringGadget(95,nTop,218,21,"",0,"txtRSEnteredString")
          scsCloseGadgetList()
          setVisible(\cntRS232, #False)
          
          ; INFO Control Send: Network
          \cntNetwork=scsContainerGadget(nInfoCntLeft,nInfoCntTop,nInfoCntWidth,nInfoCntHeight,0,"cntNetwork")
            nLeft = 0
            nTop = 0
            \lblNWItemDesc=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblItemDesc"), #PB_Text_Right,"lblNWItemDesc")
            \txtNWItemDesc=scsStringGadget(gnNextX+gnGap,nTop,60,21,"",0,"txtNWItemDesc") ; deliberately short as the entry will be used to prefix the display info
            SetGadgetAttribute(\txtNWItemDesc, #PB_String_MaximumLength, 10)
            scsToolTip(\txtNWItemDesc,LangPars("WQM","txtItemDescTT", "10"))
            nTop + 23
            nWidth = (GadgetX(\lblLogicalDev) - GadgetX(\cntNetwork)) + GadgetWidth(\lblLogicalDev)
            \lblCtrlNetworkRemoteDev=scsTextGadget(nLeft,nTop+4,nWidth,17,Lang("WQM","RemoteDev"),#PB_Text_Right,"RemoteDev")
            \cboCtrlNetworkRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboCtrlNetworkRemoteDev")
            setEnabled(\cboCtrlNetworkRemoteDev,#False)
            
            nTop + 23
            \cntOSC=scsContainerGadget(0,nTop,GadgetWidth(\cntNetwork),GadgetHeight(\cntNetwork)-nTop,0,"cntOSC")
              nLeft = 0
              nTop = 0
              nWidth = GadgetWidth(\lblCtrlNetworkRemoteDev)
              \lblOSCCmdType=scsTextGadget(nLeft,nTop+4,nWidth,17,Lang("WQM","lblOSCCmdType"), #PB_Text_Right,"lblOSCCmdType")
              \cboOSCCmdType=scsComboBoxGadget(gnNextX+gnGap,nTop,99,21,0,"cboOSCCmdType")
              nTop + 23
              \cntOSCItem=scsContainerGadget(0,nTop,GadgetWidth(\cntOSC),GadgetHeight(\cntOSC)-nTop,0,"cntOSCItem")
                nTop = 0
                \lblOSCItemSelect=scsTextGadget(nLeft,nTop+4,nWidth,17,"",#PB_Text_Right,"lblOSCItemSelect")
                \cboOSCItemSelect=scsComboBoxGadget(gnNextX+gnGap,nTop,99,21,0,"cboOSCItemSelect")
                \txtOSCItemString=scsStringGadget(gnNextX+gnGap,nTop,70,21,"",0,"txtOSCItemString")
                nTop + 23
                \lblOSCParam1=scsTextGadget(nLeft,nTop+4,nWidth,30,"",#PB_Text_Right,"lblOSCParam1")
                \cboOSCParam1=scsComboBoxGadget(gnNextX+gnGap,nTop,99,21,0,"cboOSCParam1")
                setVisible(\lblOSCParam1,#False)
                setVisible(\cboOSCParam1,#False)
                nLeft = GadgetX(\cboOSCItemSelect)
                ; nb \chkOSCReloadNamesGoScene, \chkOSCReloadNamesGoSnippet and \chkOSCReloadNamesGoCue are mutually exclusive
                ; \chkOSCReloadNamesGoScene displayed for 'go scene'
                \chkOSCReloadNamesGoScene=scsCheckBoxGadget2(nLeft,nTop,0,17,Lang("WQM","chkOSCReloadNames"),0,"chkOSCReloadNamesGoScene")
                setVisible(\chkOSCReloadNamesGoScene,#False)
                ; \chkOSCReloadNamesGoSnippet displayed for 'go snippet'
                \chkOSCReloadNamesGoSnippet=scsCheckBoxGadget2(nLeft,nTop,0,17,Lang("WQM","chkOSCReloadNamesGoSnippet"),0,"chkOSCReloadNamesGoSnippet")
                setVisible(\chkOSCReloadNamesGoSnippet,#False)
                ; \chkOSCReloadNamesGoCue displayed for 'go cue'
                \chkOSCReloadNamesGoCue=scsCheckBoxGadget2(nLeft,nTop,0,17,Lang("WQM","chkOSCReloadNamesGoCue"),0,"chkOSCReloadNamesGoCue")
                setVisible(\chkOSCReloadNamesGoCue,#False)
                nLeft = GadgetX(\lblOSCItemSelect)
                nTop = GadgetY(\cboOSCItemSelect)
                nWidth = GadgetWidth(\lblOSCItemSelect)
                \lblOSCEnteredString=scsTextGadget(nLeft,nTop+4,nWidth,17,Lang("WQM","lblOSCEnteredString"), #PB_Text_Right,"lblOSCEnteredString")
                \txtOSCEnteredString=scsStringGadget(gnNextX+gnGap,nTop,218,21,"",0,"txtOSCEnteredString")
                setVisible(\lblOSCEnteredString,#False)
                setVisible(\txtOSCEnteredString,#False)
                nTop = GadgetY(\chkOSCReloadNamesGoScene) + 25
                \btnX32Capture=scsButtonGadget(GadgetX(\cboOSCParam1),nTop,200,gnBtnHeight,LangEllipsis("WQM","btnX32Capture"),0,"btnX32Capture")
                setGadgetWidth(\btnX32Capture)
              scsCloseGadgetList()
              \cntOSCFaderEtc=scsContainerGadget(0,GadgetY(\cntOSCItem),GadgetWidth(\cntOSCItem),GadgetHeight(\cntOSCItem),0,"cntOSCFaderEtc")
                nTop = 0
                \lblOSCFader=scsTextGadget(0,nTop+4,110,17,"",#PB_Text_Right,"lblOSCFader")
                nLeft = gnNextX+gnGap
                nWidth = GadgetWidth(\cntOSCFaderEtc) - nLeft - 44 ; 44 = width of \txtOSCDevDBLevel
                \sldOSCFader=SLD_New("OSCFader",\cntOSCFaderEtc,0,nLeft,nTop,nWidth,21,#SCS_ST_REMDEV_FADER_LEVEL,0,1000)
                \txtOSCDevDBLevel=scsStringGadget(gnNextX,nTop,44,21,"",0,"txtOSCDevDBLevel")
                setVisible(\lblOSCFader, #False)
                SLD_setVisible(\sldOSCFader, #False)
                setVisible(\txtOSCDevDBLevel, #False)
                nTop = 23
                nHeight = GadgetHeight(\cntOSCFaderEtc) - nTop - 8
                \grdOSCGrdItem=scsListIconGadget(SLD_gadgetX(\sldOSCFader),nTop,150,nHeight,"",150-glScrollBarWidth-gl3DBorderAllowanceX,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdOSCGrdItem")
                setVisible(\grdOSCGrdItem, #False)
              scsCloseGadgetList()
              setVisible(\cntOSCFaderEtc, #False)

            scsCloseGadgetList()
            setVisible(\cntOSC, #False)
            
            nTop = GadgetY(\cntOSC)
            \cntOther=scsContainerGadget(0,nTop,GadgetWidth(\cntNetwork),GadgetHeight(\cntNetwork)-nTop,0,"cntOther")
              nLeft = 0
              nWidth = GadgetWidth(\lblCtrlNetworkRemoteDev)
              \lblNWEntryMode=scsTextGadget(nLeft,4,nWidth,17,Lang("WQM","lblEntryMode"), #PB_Text_Right,"lblNWEntryMode")
              \cboNWEntryMode=scsComboBoxGadget(gnNextX+gnGap,0,99,21,0,"cboNWEntryMode")
              \chkNWAddCR=scsCheckBoxGadget2(GadgetX(\cboNWEntryMode),26,229,17,Lang("WQM","chkAddCR"),0,"chkNWAddCR")
              \chkNWAddLF=scsCheckBoxGadget2(GadgetX(\cboNWEntryMode),44,229,17,Lang("WQM","chkAddLF"),0,"chkNWAddLF")
              nLeft = 12
              nWidth = GadgetWidth(\cntOther) - nLeft
              \lblNWEnteredString=scsTextGadget(nLeft+5,64,nWidth,17,Lang("WQM","lblNWEnteredString"), 0,"lblNWEnteredString") ; X = 5 greater than X for associated text gadget so that text left-aligns
              \txtNWEnteredString=scsStringGadget(nLeft,81,nWidth,21,"",0,"txtNWEnteredString")
            scsCloseGadgetList()
            
          scsCloseGadgetList() ; \cntNetwork
          setVisible(\cntNetwork, #False)
          
          ; INFO Control Send: HTTP
          \cntHTTP1=scsContainerGadget(nInfoCntLeft,nInfoCntTop,nInfoCntWidth,nInfoCntHeight,0,"cntHTTP1")
            nTop = 0
            \lblHTItemDesc=scsTextGadget(0,nTop+4,110,17,Lang("WQM","lblItemDesc"), #PB_Text_Right,"lblHTItemDesc")
            \txtHTItemDesc=scsStringGadget(gnNextX+gnGap,nTop,60,21,"",0,"txtHTItemDesc") ; deliberately short as the entry will be used to prefix the display info
            SetGadgetAttribute(\txtHTItemDesc, #PB_String_MaximumLength, 10)
            scsToolTip(\txtHTItemDesc,LangPars("WQM","txtItemDescTT", "10"))
          scsCloseGadgetList()
          setVisible(\cntHTTP1, #False)
          
          nTop = GadgetY(\grdCtrlSends) + GadgetHeight(\grdCtrlSends) + 12
          \cntHTTP2=scsContainerGadget(10,nTop,gnEditorScaPropertiesInnerWidth-10,142,0,"cntHTTP2")
            nTop = 0
            \lblHTEnteredString=scsTextGadget(0,nTop+4,90,17,Lang("WQM","lblHTEnteredString"),#PB_Text_Right,"lblHTEnteredString")
            nLeft = gnNextX + gnGap
            nWidth = GadgetWidth(\cntHTTP2) - nLeft - 4
            \txtHTEnteredString=scsStringGadget(nLeft,nTop,nWidth,20,"",0,"txtHTEnteredString")
            nTop + 24
            \lblHTTPMsg=scsTextGadget(0,nTop+4,90,17,Lang("WQM","lblHTTPMsg"), #PB_Text_Right,"lblHTTPMsg")
            \txtHTTPMsg=scsStringGadget(nLeft,nTop,nWidth,20,"",#PB_String_ReadOnly,"txtHTTPMsg")
            ntop + 24
            \lblHTTPResponse=scsTextGadget(0,nTop+4,90,17,Lang("WQM","lblHTTPResponse"), #PB_Text_Right,"lblHTTPResponse")
            \txtHttpResponse = scsEditorGadget(nLeft,nTop,nWidth,96,#PB_Editor_ReadOnly | #PB_Editor_WordWrap, "Http response")
            SetGadgetColors(\txtHttpresponse, #SCS_Black, #SCS_Light_Grey)
          scsCloseGadgetList()
          setVisible(\cntHTTP2, #False)
          
          ; INFO Control Send: End of device type containers
          
          ; The following containers overlap but are mutually exclusive
          nTop = GadgetY(\cntMidi) + GadgetHeight(\cntMidi)
          nLeft = 40
          nWidth = GadgetWidth(\cntSubDetailM) - nLeft
          nWidth2 = 92
          nWidth3 = nWidth - nWidth2 - gnGap
          \cntMidiMsg=scsContainerGadget(nLeft,nTop,nWidth,25,#PB_Container_BorderLess,"cntMidiMsg")
            \lblMidiMsg=scsTextGadget(0,3,nWidth2,22,Lang("WQM","lblMidiMsg"),#PB_Text_Right,"lblMidiMsg")
            \txtMidiMsg=scsStringGadget(gnNextX+gnGap,0,nWidth3,20,"",#PB_String_ReadOnly,"txtMidiMsg")
          scsCloseGadgetList()
          \cntOSCMsg=scsContainerGadget(nLeft,nTop,nWidth,25,#PB_Container_BorderLess,"cntOSCMsg")
            \lblOSCMsg=scsTextGadget(0,3,nWidth2,22,Lang("WQM","lblOSCMsg"),#PB_Text_Right,"lblOSCMsg")
            \txtOSCMsg=scsStringGadget(gnNextX+gnGap,0,nWidth3,20,"",#PB_String_ReadOnly,"txtOSCMsg")
          scsCloseGadgetList()
          
          ; test
          nHeight = 102
          nTop = GadgetHeight(\cntSubDetailM) - nHeight - 8
          \cntTest=scsContainerGadget(14,nTop,604,nHeight,0,"cntTest")
            SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntTest, #False)
            
            \cntTestBtns=scsContainerGadget(0,13,GadgetWidth(\cntTest),62,0,"cntTestBtns")
              SetGadgetColor(\cntTestBtns,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\cntTestBtns, #False)
              \btnTestCtrlSend[0]=scsButtonGadget(43,0,250,gnBtnHeight,Lang("WQM","btnTestCtrlSend[0]"),0,"btnTestCtrlSend[0]")
              \btnTestCtrlSend[1]=scsButtonGadget(310,0,250,gnBtnHeight,Lang("WQM","btnTestCtrlSend[1]"),0,"btnTestCtrlSend[1]")
              \lblEditMidiInfo[0]=scsTextGadget(24,28,553,30,"",#PB_Text_Center,"lblEditMidiInfo")
              scsSetGadgetFont(\lblEditMidiInfo[0], #SCS_FONT_GEN_BOLD)
              SetGadgetColors(\lblEditMidiInfo[0], #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblEditMidiInfo[0], #False)
            scsCloseGadgetList() ; cntTestBtns
            
            \cntTestMidiFile=scsContainerGadget(0,75,GadgetWidth(\cntTest),24,0,"cntTestMidiFile")
              SetGadgetColor(\cntTestMidiFile,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\cntTestMidiFile, #False)
              
              \lblTestMidiFile=scsTextGadget(4,4,70,15,Lang("WQM","lblTestMidiFile"), #PB_Text_Right,"lblTestMidiFile") ; "Test"
              scsSetGadgetFont(\lblTestMidiFile, #SCS_FONT_GEN_BOLD)
              SetGadgetColors(\lblTestMidiFile, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblTestMidiFile, #False)
              
              ; transport controls
              \btnEditRewind=scsStandardButton(gnNextX+8,0,24,24,#SCS_STANDARD_BTN_REWIND,"btnEditRewind")
              \btnEditPlay=scsStandardButton(gnNextX,0,24,24,#SCS_STANDARD_BTN_PLAY,"btnEditPlay")
              \btnEditPause=scsStandardButton(GadgetX(\btnEditPlay),0,24,24,#SCS_STANDARD_BTN_PAUSE,"btnEditPause")
              setVisible(\btnEditPause, #False)
              \btnEditStop=scsStandardButton(gnNextX,0,24,24,#SCS_STANDARD_BTN_STOP,"btnEditStop")
              
              \lblInfo=scsTextGadget(gnNextX,4,80,18,"", #PB_Text_Center,"lblInfo")
              SetGadgetColors(\lblInfo, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblInfo, #False)
              
              nLeft = gnNextX
              nWidth = GadgetWidth(\cntTestMidiFile) - nLeft - 4
              \sldProgress=SLD_New("QM_Progress",\cntTestMidiFile,0,nLeft,2,nWidth,21,#SCS_ST_PROGRESS,0,1000)
              SLD_setEnabled(\sldProgress, #False)
              
            scsCloseGadgetList() ; cntTestMidiFile
            setVisible(\cntTestMidiFile, #False)  ; only made visible if there is a MIDI file
            
          scsCloseGadgetList() ; cntTest
          
          nTop = GadgetHeight(\cntSubDetailM) - nHeight - 8
          nLeft = 12
          nWidth = GadgetX(\cntMidi) - (nLeft << 1)
          \cntRemDevTest=scsContainerGadget(nLeft,nTop,nWidth,100,0,"cntRemDevTest")
            SetGadgetColor(\cntRemDevTest,#PB_Gadget_BackColor,#SCS_Grey)
            setAllowEditorColors(\cntRemDevTest, #False)
            nWidth = 250
            nLeft = (GadgetWidth(\cntRemDevTest) - nWidth) >> 1
            nTop = 8
            \btnTestCtrlSend[2]=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,Lang("WQM","btnTestCtrlSend[0]"),0,"btnTestCtrlSend[2]") ; Text$ same as for \btnTestCtrlSend[0]
            nTop + gnBtnHeight + 4
            \btnTestCtrlSend[3]=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,Lang("WQM","btnTestCtrlSend[1]"),0,"btnTestCtrlSend[3]") ; Text$ same as for \btnTestCtrlSend[1]
            nTop + gnBtnHeight + 4
            nLeft = 4
            nWidth = GadgetWidth(\cntRemDevTest) - (nLeft << 1)
            \lblEditMidiInfo[1]=scsTextGadget(nLeft,nTop,nWidth,30,"",#PB_Text_Center,"lblEditMidiInfo[1]")
            scsSetGadgetFont(\lblEditMidiInfo[1], #SCS_FONT_GEN_BOLD)
            SetGadgetColors(\lblEditMidiInfo[1], #SCS_White, #SCS_Grey)
            setAllowEditorColors(\lblEditMidiInfo[1], #False)
          scsCloseGadgetList() ; cntRemDevTest
          setVisible(\cntRemDevTest, #False)
          
        scsCloseGadgetList() ; cntSubDetailM
        
      scsCloseGadgetList() ; scaCtrlSend
      
      ;setVisible(WQM\scaCtrlSend, #True)
      setEnabled(WQM\scaCtrlSend, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQMCreated = #True
  
EndProcedure

Structure strWQP ; fmEditQP
  SUBCUE_HEADER_FIELDS()
  btnApplyToAll.i
  btnPLCenter.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  btnPLFadeOut.i
  btnPLOther.i
  btnPLPause.i
  btnPLPlay.i
  btnPLRewind.i
  btnPLShuffle.i
  btnPLStop.i
  btnRename.i
  cboPLLogicalDev.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cboPLTracks.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  cboPLTestMode.i
  cboTransType.i
  cboSubTrim.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  chkPLRandom.i
  chkPLRepeat.i
  chkPLSavePos.i
  chkShowFileFolders.i
  cntInfoBelowFiles.i
  cntPlaylistSideBar.i
  cntSubDetailP.i
  cntTest.i
  grdPlaylist.i
  imgButtonTBS.i[4]
  lblEndAt.i
  lblFile.i
  lblLength.i
  lblMastDb.i
  lblNo.i
  lblPlayLength.i
  lblPLDevNo.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  lblPLFadeInTime.i
  lblPLFadeOutTime.i
  lblPLInfo.i
  lblPLMasterLevels.i
  lblRelLevel.i
  lblRelLevel2.i
  lblPLSoundDevices.i
  lblPLTest.i
  lblPLTestFile.i
  lblPLThisTest.i
  lblPLTitle.i
  lblPLTotalTime.i
  lblPLTracks.i
  lblSubPan.i
  lblTransTime.i
  lblTransType.i
  lblSubTrim.i
  lblPlayOrder.i
  lblStartAt.i
  lnDropMarker.i
  lnPlaylist.i[5]
  scaDevs.i
  scaPlaylist.i
  scaFiles.i
  sldSubLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldSubPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  sldPLProgress.i[2]
  sldRelLevel.i
  txtPLFadeInTime.i
  txtPLFadeOutTime.i
  txtSubDBLevel.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtSubPan.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  txtPLTitle.i
  txtPLTotalTime.i
  txtTransTime.i
EndStructure
Structure strWQPFile
  nFileId.i
  CompilerIf #c_include_mygrid_for_playlists = #False
    cntFile.i
    txtTrkNo.i
    txtFileNameP.i
    btnBrowse.i
    txtLength.i
    txtStartAt.i
    txtEndAt.i
    txtPlayLength.i
    txtRelLevel.i
  CompilerEndIf
  nAudPtr.i
  nFileNameLen.i
EndStructure
Global WQP.strWQP ; fmEditQP
Global NewList WQPFile.strWQPFile()

Procedure createWQPFile()
  ; creates a new 'file' entry in the playlist file list, after the currently selected element
  PROCNAMEC()
  CompilerIf #c_include_mygrid_for_playlists = #False
    Protected nListIndex, nTop, sFileId.s
    Protected nReqdInnerHeight
  CompilerEndIf
  
  ; debugMsg0(sProcName, #SCS_START)
  
  AddElement(WQPFile())
  WQPFile()\nAudPtr = -1
  WQPFile()\nFileNameLen = 0
  
  rWQP\nVisibleFiles + 1
  
  CompilerIf #c_include_mygrid_for_playlists
    WQPFile()\nFileId = rWQP\nFileId    ; unique id for this entry
    rWQP\nFileId + 1
  CompilerElse
    gnCurrentEditorComponent = #WQP
    scsOpenGadgetList(WQP\scaFiles)
      scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
      
      With WQPFile()
        nListIndex = ListIndex(WQPFile())
        nTop = nListIndex * #SCS_QPROW_HEIGHT
        ; debugMsg(sProcName, "ListIndex(WQPFile())=" + ListIndex(WQPFile()) + ", nListIndex=" + nListIndex + ", nTop=" + nTop)
        WQPFile()\nFileId = rWQP\nFileId    ; unique id for this entry
        sFileId = "[" + \nFileId + "]"
        \cntFile=scsContainerGadget(0,nTop,GetGadgetAttribute(WQP\scaFiles,#PB_ScrollArea_InnerWidth),#SCS_QPROW_HEIGHT,0,"cntFile"+sFileId, #SCS_G4EH_PL_CNTFILE)
          ; nb using a StringGadget rather than a TextGadget for \txtNo so we receive an event when the user clicks on the gadget
          \txtTrkNo=scsStringGadget(0,0,30,#SCS_QPROW_HEIGHT,"",#PB_String_ReadOnly|#ES_CENTER,"txtTrkNo"+sFileId, #SCS_G4EH_PL_TXTTRKNO)
          SetGadgetColor(\txtTrkNo, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
          SetGadgetColor(\txtTrkNo, #PB_Gadget_FrontColor, #SCS_Black)
          \txtFileNameP=scsStringGadget(gnNextX,0,232,#SCS_QPROW_HEIGHT,"",#PB_String_ReadOnly,"txtFileNameP"+sFileId, #SCS_G4EH_PL_TXTFILENAME)
          \btnBrowse=scsButtonGadget(gnNextX,0,20,20,"...",0,"btnBrowse"+sFileId, #SCS_G4EH_PL_CMDBROWSE)
          \txtLength=scsStringGadget(gnNextX+gnGap,0,68,#SCS_QPROW_HEIGHT,"",#PB_String_ReadOnly,"txtLength"+sFileId, #SCS_G4EH_PL_TXTLENGTH)
          \txtStartAt=scsStringGadget(gnNextX,0,54,#SCS_QPROW_HEIGHT,"",0,"txtStartAt"+sFileId, #SCS_G4EH_PL_TXTSTARTAT)
          \txtEndAt=scsStringGadget(gnNextX,0,54,#SCS_QPROW_HEIGHT,"",0,"txtEndAt"+sFileId, #SCS_G4EH_PL_TXTENDAT)
          \txtPlayLength=scsStringGadget(gnNextX,0,68,#SCS_QPROW_HEIGHT,"",#PB_String_ReadOnly,"txtPlayLength"+sFileId, #SCS_G4EH_PL_TXTPLAYLENGTH)
          \txtRelLevel=scsStringGadget(gnNextX,0,40,#SCS_QPROW_HEIGHT,"",#PB_String_ReadOnly,"txtRelLevel"+sFileId, #SCS_G4EH_PL_TXTRELLEVEL)
        scsCloseGadgetList()
        rWQP\nFileId + 1
      EndWith
      
      nReqdInnerHeight = ListSize(WQPFile()) * #SCS_QPROW_HEIGHT
      SetGadgetAttribute(WQP\scaFiles, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
      
    scsCloseGadgetList()
    gnCurrentEditorComponent = 0
  CompilerEndIf
  
EndProcedure

Procedure insertWQPFile()
  ; inserts a blank 'file' entry in the playlist file list immediately before the current entry
  ; returns the listindex of new row
  PROCNAMEC()
  Protected nListIndex, nLastElement, nTop
  Protected nReqdInnerHeight
  Protected *oldElement, *firstElement, *secondElement
  
  If ListSize(WQPFile()) = 0
    ProcedureReturn
  EndIf
  
  If ListIndex(WQPFile()) = -1
    ProcedureReturn
  EndIf
  
  *firstElement = @WQPFile()
  createWQPFile()   ; adds blank entry AFTER the current entry
  *secondElement = @WQPFile()
  SwapElements(WQPFile(), *firstElement, *secondElement)  ; swap the new blank entry with the preceding current entry
  
  *oldElement = @WQPFile()
  
  CompilerIf #c_include_mygrid_for_playlists = #False
    ForEach WQPFile()
      nListIndex = ListIndex(WQPFile())
      nTop = nListIndex * #SCS_QPROW_HEIGHT
      If IsGadget(WQPFile()\cntFile)
        ResizeGadget(WQPFile()\cntFile, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      EndIf
    Next WQPFile()
  CompilerEndIf
  
  ChangeCurrentElement(WQPFile(), *oldElement)
  nListIndex = ListIndex(WQPFile())
  
  rWQP\nVisibleFiles + 1
  
  nReqdInnerHeight = ListSize(WQPFile()) * #SCS_QPROW_HEIGHT
  SetGadgetAttribute(WQP\scaFiles, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
  
  ProcedureReturn nListIndex
  
EndProcedure

Procedure removeWQPFile()
  ; removes the currently selected 'file' entry in the playlist file list
  ; returns listindex of now-selected row
  PROCNAMEC()
  Protected nListIndex, nLastElement, nTop
  Protected nReqdInnerHeight
  
  nListIndex = ListIndex(WQPFile())
  If nListIndex < 0
    ProcedureReturn nListIndex
  EndIf
  
  CompilerIf #c_include_mygrid_for_playlists
    DeleteElement(WQPFile(), 1)
    nListIndex = ListIndex(WQPFile())
    nLastElement = ListSize(WQPFile()) - 1
    rWQP\nVisibleFiles - 1
  CompilerElse
    scsOpenGadgetList(WQP\scaFiles)
      If IsGadget(WQPFile()\cntFile)
        scsFreeGadget(WQPFile()\cntFile)
        debugMsg(sProcName, "scsFreeGadget(G" + WQPFile()\cntFile + ")")
      EndIf
      DeleteElement(WQPFile(), 1)
      nListIndex = ListIndex(WQPFile())
      nLastElement = ListSize(WQPFile()) - 1
      rWQP\nVisibleFiles - 1
      nTop = nListIndex * #SCS_QPROW_HEIGHT
      If nListIndex <= nLastElement
        ; move subsequent entries up one position
        While NextElement(WQPFile()) <> 0
          nTop + #SCS_QPROW_HEIGHT
          ResizeGadget(WQPFile()\cntFile, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
        Wend
        ; reset current element to the element after the one deleted unless it is blank
        If nListIndex < nLastElement
          nListIndex + 1
        EndIf
        SelectElement(WQPFile(), nListIndex)
        If WQPFile()\nFileNameLen = 0 And nListIndex > 0
          nListIndex - 1
          SelectElement(WQPFile(), nListIndex)
        EndIf
      EndIf
      nReqdInnerHeight = ListSize(WQPFile()) * #SCS_QPROW_HEIGHT
      SetGadgetAttribute(WQP\scaFiles, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
    scsCloseGadgetList()
  CompilerEndIf
  
  ProcedureReturn nListIndex
  
EndProcedure

Procedure createfmEditQP()
  PROCNAMEC()
  Protected n, nLeft, nTop, nWidth, nHeight, sNr.s
  Protected nFilesInnerWidth, nFilesInnerHeight
  Protected nDevInnerWidth, nDevInnerHeight
  Protected nInnerHeight
  Protected sText.s, nTextWidth
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQP
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQP
      nInnerHeight = (41 + 4 + 379 + 50 + 2) ; 41 = height of subcue header; 4 = gap before detail; 379 = top of last container within detail; 50 = height of last container within detail
      
      \scaPlaylist=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaPlaylist") ; inner height was nInnerHeight
        setVisible(\scaPlaylist, #False)
        ; header
        SUBCUE_HEADER_CODE(WQP)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailP=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,#PB_Container_BorderLess,"cntSubDetailP")
          
          ; nLeft = GadgetX(\txtSubDescr)
          nLeft = 40  ; same 'left' as will be used for \lblNo further down this procedure
          sText = Lang("WQP","chkPLRepeat")
          nTextWidth = GetTextWidth(sText)
          \chkPLRepeat=scsCheckBoxGadget2(nLeft,1,nTextWidth+30,17,sText,0,"chkPLRepeat")
          scsToolTip(\chkPLRepeat,Lang("WQP","chkPLRepeatTT"))
          sText = Lang("WQP","chkPLRandom")
          nTextWidth = GetTextWidth(sText)
          \chkPLRandom=scsCheckBoxGadget2(gnNextX+gnGap,1,nTextWidth+30,17,sText,0,"chkPLRandom")
          scsToolTip(\chkPLRandom,Lang("WQP","chkPLRandomTT"))
          sText = Lang("WQP","chkPLSavePos")
          nTextWidth = GetTextWidth(sText)
          \chkPLSavePos=scsCheckBoxGadget2(gnNextX+gnGap,1,nTextWidth+30,17,sText,0,"chkPLSavePos")
          scsToolTip(\chkPLSavePos,Lang("WQP","chkPLSavePosTT"))
          CompilerIf #c_include_mygrid_for_playlists
            sText = Lang("Common","ShowFileFolders")
            nTextWidth = GetTextWidth(sText)
            \chkShowFileFolders=scsCheckBoxGadget2(gnNextX+gnGap,1,nTextWidth+30,17,sText,0,"chkShowFileFolders")
            \btnPLOther=scsButtonGadget(gnNextX+gnGap,0,70,20,LangEllipsis("Btns","OtherActions"),0,"btnPLOther")
            setGadgetWidth(\btnPLOther)
          CompilerElse
            \btnPLOther=scsButtonGadget(389,0,70,20,LangEllipsis("Btns","OtherActions"),0,"btnPLOther")
            setGadgetWidth(\btnPLOther)
          CompilerEndIf
          
          CompilerIf #c_include_mygrid_for_playlists = #False
            ; file list header line
            nTop = 22
            nLeft = 40
            \lblNo=scsTextGadget(nLeft,nTop,30,15,Lang("Common","No."),0,"lblNo")
            \lblFile=scsTextGadget(gnNextX,nTop,76,15,Lang("Common","AudioFile"),0,"lblFile")
            \chkShowFileFolders=scsCheckBoxGadget2(gnNextX,nTop-2,118,17,Lang("Common","ShowFileFolders"),0,"chkShowFileFolders")
            \lblLength=scsTextGadget(gnNextX+60,nTop,68,15,Lang("Common","FileLength"),0,"lblLength")
            \lblStartAt=scsTextGadget(gnNextX,nTop,54,15,Lang("Common","StartAt"),0,"lblStartAt")
            \lblEndAt=scsTextGadget(gnNextX,nTop,54,15,Lang("Common","EndAt"),0,"lblEndAt")
            \lblPlayLength=scsTextGadget(gnNextX,nTop,68,15,Lang("Common","PlayLength"),0,"lblPlayLength")
            \lblRelLevel2=scsTextGadget(gnNextX,nTop,50,15,Lang("WQP","lblRelLevel2"),0,"lblRelLevel2")
          CompilerEndIf
          
          ; sidebar
          CompilerIf #c_include_mygrid_for_playlists
            nTop = 23 + 20 ; 23 will be top of grdPlayList, 20 = height of header row
          CompilerElse
            nTop + 15
          CompilerEndIf
          \cntPlaylistSideBar=scsContainerGadget(3,nTop-2,30,121,0,"cntPlaylistSideBar")
            setAllowEditorColors(\cntPlaylistSideBar, #False)    ; prevent toolbar being colored
            \imgButtonTBS[0]=scsStandardButton(3,0,24,24,#SCS_STANDARD_BTN_MOVE_UP,"imgButtonTBS[0]")
            \imgButtonTBS[1]=scsStandardButton(3,24,24,24,#SCS_STANDARD_BTN_MOVE_DOWN,"imgButtonTBS[1]")
            \imgButtonTBS[2]=scsStandardButton(3,48,24,24,#SCS_STANDARD_BTN_PLUS,"imgButtonTBS[2]")
            \imgButtonTBS[3]=scsStandardButton(3,72,24,24,#SCS_STANDARD_BTN_MINUS,"imgButtonTBS[3]")
            \btnRename=scsButtonGadget(0,98,30,23,"Ren",0,"btnRename")
          scsCloseGadgetList() ; cntCtrlSendSideBar
          
          CompilerIf #c_include_mygrid_for_playlists
            nTop = 23
            nLeft = 36
            nWidth = 589  ; GadgetWidth(\cntSubDetailP) - nLeft - glScrollBarWidth
            nFilesInnerWidth = nWidth - glScrollBarWidth - gl3DBorderAllowanceX
            nHeight = 20 * 7   ; 20 is default row height in MyGrid
            nFilesInnerHeight = 20 * 7
            \grdPlaylist=scsMyGridGadget(#WED, nLeft, nTop, nWidth, nHeight, 25, 8, #True, #True, #False, "grdPlaylist")
            debugMsg2(sProcName, "scsMyGridGadget(#WED, " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ", 25, 8, #True, #True, #False,'grdPlaylist')", \grdPlaylist)
            MyGrid_SetAttribute(\grdPlaylist, #MyGrid_Att_RowScrollPageSize, 7)
          CompilerElse
            nLeft = 36
            nWidth = 591  ; GadgetWidth(\cntSubDetailP) - nLeft - glScrollBarWidth + 2
            nFilesInnerWidth = nWidth - glScrollBarWidth - gl3DBorderAllowanceX
            nHeight = 21 * 7
            nFilesInnerHeight = 21 * 7
            ; about to reset WQPFile() so destroy any existing gadgets associated with WQPFile()
            ForEach WQPFile()
              If IsGadget(WQPFile()\cntFile)
                scsFreeGadget(WQPFile()\cntFile)
                debugMsg(sProcName, "scsFreeGadget(G" + WQPFile()\cntFile + ")")
              EndIf
            Next WQPFile()
            ResetList(WQPFile())
            rWQP\nVisibleFiles = 0
            rWQP\nCurrentTrkNoHandle = 0
            rWQP\nCurrentTrkNo = 0
            \scaFiles=scsScrollAreaGadget(nLeft, nTop, nWidth, nHeight, nFilesInnerWidth,nFilesInnerHeight,21,#PB_ScrollArea_BorderLess,"scaFiles")
            scsCloseGadgetList()
            \lnDropMarker=scsLineGadget(nLeft,nTop,nFilesInnerWidth,2,#SCS_Black,0,"lnDropMarker")
            setVisible(\lnDropMarker, #False)
          CompilerEndIf
          
          nTop = 187
          nWidth = GadgetWidth(\cntSubDetailP)
          nHeight = 233
          \cntInfoBelowFiles=scsContainerGadget(0,nTop,nWidth,nHeight,0,"cntInfoBelowFiles")
            
            ; file fields
            \lblPLTitle=scsTextGadget(10,0,61,15,Lang("WQP","lblPLTitle"),0,"lblPLTitle")
            \txtPLTitle=scsStringGadget(9,16,254,21,"",#PB_String_ReadOnly,"txtPLTitle")
            \lblRelLevel=scsTextGadget(277,0,140,15,Lang("WQP","lblRelLevel"),#PB_Text_Center,"lblRelLevel")
            \sldRelLevel=SLD_New("QP_Percent",\cntInfoBelowFiles,0,277,16,140,21,#SCS_ST_HPERCENT,0,100)
            \lblTransType=scsTextGadget(434,0,113,15,Lang("WQP","lblTransType"),0,"lblTransType")
            \cboTransType=scsComboBoxGadget(435,16,104,21,0,"cboTransType")
            scsToolTip(\cboTransType,Lang("WQP","cboTransTypeTT"))
            \lblTransTime=scsTextGadget(547,0,72,15,Lang("WQP","lblTransTime"),0,"lblTransTime")
            \txtTransTime=scsStringGadget(548,16,64,21,"",0,"txtTransTime")
            scsToolTip(\txtTransTime,Lang("WQP","txtTransTimeTT"))
            sText = Lang("WQP","btnApplyToAll")
            nTextWidth = GetTextWidth(sText)
            If nTextWidth < 170
              nHeight = 23
            Else
              nHeight = 35
            EndIf
            \btnApplyToAll=scsButtonGadget(435,40,178,nHeight,sText,#PB_Button_MultiLine,"btnApplyToAll")
            scsToolTip(\btnApplyToAll,Lang("WQP","btnApplyToAllTT"))
            
            ; playlist fields (starting with lines to draw boxes)
            \lnPlaylist[0]=scsLineGadget(4,44,426,1,#SCS_Black,0,"lnPlayList[0]")
            \lnPlaylist[1]=scsLineGadget(4,72,426,1,#SCS_Black,0,"lnPlayList[1]")
            \lnPlaylist[2]=scsLineGadget(4,44,1,28,#SCS_Black,0,"lnPlayList[2]")
            \lnPlaylist[3]=scsLineGadget(299,44,1,28,#SCS_Black,0,"lnPlayList[3]")
            \lnPlaylist[4]=scsLineGadget(430,44,1,28,#SCS_Black,0,"lnPlayList[4]")
            \lblPLFadeInTime=scsTextGadget(9,52,104,15,Lang("WQP","lblPLFadeInTime"), #PB_Text_Right,"lblPLFadeInTime")
            \txtPLFadeInTime=scsStringGadget(116,48,45,21,"",0,"txtPLFadeInTime")
            scsToolTip(\txtPLFadeInTime,Lang("WQP","txtPLFadeInTimeTT"))
            \lblPLFadeOutTime=scsTextGadget(163,52,76,15,Lang("WQP","lblPLFadeOutTime"), #PB_Text_Right,"lblPLFadeOutTime")
            \txtPLFadeOutTime=scsStringGadget(242,48,45,21,"",0,"txtPLFadeOutTime")
            scsToolTip(\txtPLFadeOutTime,Lang("WQP","txtPLFadeOutTimeTT"))
            \lblPLTotalTime=scsTextGadget(301,52,58,15,Lang("WQP","lblPLTotalTime"), #PB_Text_Right,"lblPLTotalTime")
            \txtPLTotalTime=scsStringGadget(362,48,65,21,"",#PB_String_ReadOnly,"txtPLTotalTime")
            ; setEnabled(\txtPLTotalTime, #False)
            
            ; audio devices
            \lblPLSoundDevices=scsTextGadget(9,75,120,15,Lang("WQP","lblPLSoundDevices"),0,"lblPLSoundDevices") ; "Audio Devices"
            scsSetGadgetFont(\lblPLSoundDevices, #SCS_FONT_GEN_BOLD)
            \lblPLTracks=scsTextGadget(159,75,43,15,Lang("WQP","lblPLTracks"),0,"lblPLTracks")
            \lblSubTrim=scsTextGadget(gnNextX+2,75,43,15,Lang("Common","Trim"),0,"lblSubTrim")  ; "Trim"
            \lblPLMasterLevels=scsTextGadget(gnNextX+2,75,129,15,Lang("WQP","lblPLMasterLevels"), #PB_Text_Center,"lblPLMasterLevels") ; "Playlist Levels"
            \lblMastDb=scsTextGadget(gnNextX,75,35,15,"dB", #PB_Text_Center,"lblMastDb")  ; "dB"
            \lblSubPan=scsTextGadget(gnNextX+20,75,87,15,Lang("Common","Pan"), #PB_Text_Center,"lblSubPan") ; "Pan"
            nDevInnerHeight = (grLicInfo\nMaxAudDevPerAud + 1) * 21
            nDevInnerWidth = 624 - glScrollBarWidth - gl3DBorderAllowanceX
            \scaDevs=scsScrollAreaGadget(5,91,624,87,nDevInnerWidth, nDevInnerHeight, 30, #PB_ScrollArea_BorderLess, "scaDevs")
              For n = 0 To grLicInfo\nMaxAudDevPerSub
                nTop = n * 22
                sNr = "["+n+"]"
                \lblPLDevNo[n]=scsTextGadget(8,nTop+4,7,15,Str(n+1), #PB_Text_Center,"lblPLDevNo"+sNr)
                \cboPLLogicalDev[n]=scsComboBoxGadget(21,nTop,127,21,0,"cboPLLogicalDev"+sNr)
                scsToolTip(\cboPLLogicalDev[n],Lang("WQP","cboPLLogicalDevTT"))
                \cboPLTracks[n]=scsComboBoxGadget(152,nTop,43,21,0,"cboPLTracks"+sNr)
                \cboSubTrim[n]=scsComboBoxGadget(197,nTop,43,21,0,"cboSubTrim"+sNr)
                \sldSubLevel[n]=SLD_New("QP_Level_"+Str(n+1),\scaDevs,0,242,nTop,129,21,#SCS_ST_HLEVELNODB,0,1000)
                \txtSubDBLevel[n]=scsStringGadget(371,nTop,35,21,"",0,"txtSubDBLevel"+sNr)
                \sldSubPan[n]=SLD_New("QP_Pan_"+Str(n+1),\scaDevs,0,417,nTop,105,21,#SCS_ST_PAN,0,1000)
                \btnPLCenter[n]=scsButtonGadget(522,nTop,47,21,Lang("Btns","Center"),0,"btnPLCenter"+sNr)
                scsToolTip(\btnPLCenter[n],Lang("Btns","CenterTT"))
                \txtSubPan[n]=scsStringGadget(570,nTop,33,21,"",#PB_String_Numeric,"txtSubPan"+sNr)
              Next n
            scsCloseGadgetList()  ; scaDevs
            
            ; test
            \cntTest=scsContainerGadget(6,183,624,50,#PB_Container_Flat,"cntTest")
              
              SetGadgetColor(\cntTest,#PB_Gadget_BackColor,#SCS_Grey)
              setAllowEditorColors(\cntTest, #False)
              
              \lblPLTest=scsTextGadget(2,5,32,15,Lang("Common","Test"), #PB_Text_Right,"lblPLTest")
              scsSetGadgetFont(\lblPLTest, #SCS_FONT_GEN_BOLD)
              SetGadgetColors(\lblPLTest, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblPLTest, #False)
              \cboPLTestMode=scsComboBoxGadget(gnNextX+gnGap,2,170,21,0,"cboPLTestMode")
              ; transport controls
              \btnPLShuffle=scsStandardButton(gnNextX+gnGap,1,24,24,#SCS_STANDARD_BTN_SHUFFLE,"btnPLShuffle")
              \btnPLRewind=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_REWIND,"btnPLRewind")
              \btnPLPlay=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_PLAY,"btnPLPlay")
              \btnPLPause=scsStandardButton(GadgetX(\btnPLPlay),1,24,24,#SCS_STANDARD_BTN_PAUSE,"btnPLPause")
              setVisible(\btnPLPause, #False)
              \btnPLFadeOut=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_FADEOUT,"btnPLFadeOut")
              \btnPLStop=scsStandardButton(gnNextX,1,24,24,#SCS_STANDARD_BTN_STOP,"btnPLStop")
              
              \lblPlayOrder=scsTextGadget(gnNextX+7,0,281,26,Lang("WQP","lblPlayOrder"),0,"lblPlayOrder")
              SetGadgetColors(\lblPlayOrder, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblPlayOrder, #False)
              
              \lblPLInfo=scsTextGadget(5,28,81,18,"", #PB_Text_Center,"lblPLInfo")
              SetGadgetColors(\lblPLInfo, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblPLInfo, #False)
              
              \lblPLTestFile=scsTextGadget(90,28,39,18,Lang("WQP","lblPLTestFile")+":", #PB_Text_Right,"lblPLTestFile")
              SetGadgetColors(\lblPLTestFile, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblPLTestFile, #False)
              \sldPLProgress[0]=SLD_New("QP_FileProg",\cntTest,0,133,26,220,18,#SCS_ST_PROGRESS,0,1000)
              
              \lblPLThisTest=scsTextGadget(354,28,34,18,Lang("Common","Test")+":", #PB_Text_Right, "lblPLThisTest")
              SetGadgetColors(\lblPLThisTest, #SCS_White, #SCS_Grey)
              setAllowEditorColors(\lblPLThisTest, #False)
              \sldPLProgress[1]=SLD_New("QP_TestProg",\cntTest,0,392,26,220,18,#SCS_ST_PROGRESS,0,1000)
              
            scsCloseGadgetList() ; cntTest
            
          scsCloseGadgetList() ; cntInfoBelowFiles
          
        scsCloseGadgetList()  ; cntSubDetailP
        
      scsCloseGadgetList() ; scaPlaylist
      
      If scsCreatePopupMenu(#WQP_mnu_Other)
        CompilerIf #c_lufs_support
          scsMenuItem(#WQP_mnu_LUFSNorm100All, LangPars("Menu", "mnuWQPLUFSNormAll", "100%"), "", #False)
          scsMenuItem(#WQP_mnu_LUFSNorm90All, LangPars("Menu", "mnuWQPLUFSNormAll", "90%"), "", #False)
          scsMenuItem(#WQP_mnu_LUFSNorm80All, LangPars("Menu", "mnuWQPLUFSNormAll", "80%"), "", #False)
          CompilerIf #c_include_peak
            scsMenuItem(#WQP_mnu_PeakNormAll, Lang("Menu", "mnuWQPPeakNormAll"), "", #False)
          CompilerEndIf
          scsMenuItem(#WQP_mnu_TruePeakNorm100All, LangPars("Menu", "mnuWQPTruePeakNormAll", "100%"), "", #False)
          scsMenuItem(#WQP_mnu_TruePeakNorm90All, LangPars("Menu", "mnuWQPTruePeakNormAll", "90%"), "", #False)
          scsMenuItem(#WQP_mnu_TruePeakNorm80All, LangPars("Menu", "mnuWQPTruePeakNormAll", "80%"), "", #False)
        CompilerElse
          scsMenuItem(#WQP_mnu_PeakNorm100All, LangPars("Menu", "mnuWQPPeakNormAll", "100%"), "", #False)
          scsMenuItem(#WQP_mnu_PeakNorm90All, LangPars("Menu", "mnuWQPPeakNormAll", "90%"), "", #False)
          scsMenuItem(#WQP_mnu_PeakNorm80All, LangPars("Menu", "mnuWQPPeakNormAll", "80%"), "", #False)
        CompilerEndIf
        MenuBar()
        scsMenuItem(#WQP_mnu_TrimSilenceSel, "mnuWQPTrimSilenceSel")
        scsMenuItem(#WQP_mnu_Trim75Sel, LangPars("Menu", "mnuWQPTrimDBSel", "-75dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQP_mnu_Trim60Sel, LangPars("Menu", "mnuWQPTrimDBSel", "-60dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQP_mnu_Trim45Sel, LangPars("Menu", "mnuWQPTrimDBSel", "-45dB"), "", #False)
        scsMenuItem(#WQP_mnu_Trim30Sel, LangPars("Menu", "mnuWQPTrimDBSel", "-30dB"), "", #False)
        scsMenuItem(#WQP_mnu_ResetSel, "mnuWQPResetSel")
        scsMenuItem(#WQP_mnu_ClearSel, "mnuWQPClearSel")
        MenuBar()
        scsMenuItem(#WQP_mnu_TrimSilenceAll, "mnuWQPTrimSilenceAll")
        scsMenuItem(#WQP_mnu_Trim75All, LangPars("Menu", "mnuWQPTrimDBAll", "-75dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQP_mnu_Trim60All, LangPars("Menu", "mnuWQPTrimDBAll", "-60dB"), "", #False) ; Added 3Oct2022 11.9.6
        scsMenuItem(#WQP_mnu_Trim45All, LangPars("Menu", "mnuWQPTrimDBAll", "-45dB"), "", #False)
        scsMenuItem(#WQP_mnu_Trim30All, LangPars("Menu", "mnuWQPTrimDBAll", "-30dB"), "", #False)
        scsMenuItem(#WQP_mnu_ResetAll, "mnuWQPResetAll")
        scsMenuItem(#WQP_mnu_ClearAll, "mnuWQPClearAll")
        MenuBar()
        scsMenuItem(#WQP_mnu_RemoveAllFiles, "mnuWQPRemoveAllFiles")
      EndIf
      
      ; setVisible(WQP\scaPlaylist, #True)
      setEnabled(WQP\scaPlaylist, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQPCreated = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Structure strWQS ; fmEditQS
  SUBCUE_HEADER_FIELDS()
  cboSFRAction.i[#SCS_MAX_SFR+1]
  cboSFRCue.i[#SCS_MAX_SFR+1]
  chkCompleteAssocAutoStartCues.i
  chkHoldAssocAutoStartCues.i
  chkGoNext.i
  cntCues.i
  cntGoNext.i
  cntSubDetailS.i
  fraGoNext.i
  lblActionReqd.i
  lblGoNextDelay.i
  lblSFRCue.i
  lblTimeOverride.i
  scaSFRCues.i
  txtGoNextDelay.i
  txtTimeOverride.i
EndStructure
Global WQS.strWQS ; fmEditQS

Procedure createfmEditQS()
  PROCNAMEC()
  Protected n, nTop, nHeight, sNr.s
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQS
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQS
      \scaSFRCues=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaSFRCues") ; inner heght was 363
        setVisible(\scaSFRCues, #False)
        ; header
        SUBCUE_HEADER_CODE(WQS)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailS=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailS")
          
          \lblActionReqd=scsTextGadget(24,5,300,15,Lang("WQS","lblActionReqd"),0,"lblActionReqd") ; "Action Required"
          \lblSFRCue=scsTextGadget(gnNextX+1,5,300,15,Lang("WQS","lblSFRCue"),0,"lblSFRCue") ; "Cue to be Actioned"
          \cntCues=scsContainerGadget(0,22,630,125,0, "cntCues")
            For n = 0 To #SCS_MAX_SFR
              nTop = n * 25
              sNr = "["+n+"]"
              \cboSFRAction[n]=scsComboBoxGadget(20,nTop,300,21,0,"cboSFRAction"+sNr)
              \cboSFRCue[n]=scsComboBoxGadget(gnNextX+1,nTop,300,21,0,"cboSFRCue"+sNr)
              scsToolTip(\cboSFRCue[n],Lang("WQS","cboSFRCueTT"))
              ; \shpSFRAction[n]=scsTextGadget(gnNextX+6,nTop+4,15,15,"",#PB_Text_Border,"shpSFRAction"+sNr)  ; use a text box instead of a circular shape
            Next n
          scsCloseGadgetList()
          
          nTop = GadgetY(\cntCues) + GadgetHeight(\cntCues) + 22
          \lblTimeOverride=scsTextGadget(70,nTop+gnLblVOffsetS,228,17,Lang("WQS","lblTimeOverride"), #PB_Text_Right,"lblTimeOverride")  ; "Time Override for Fades"
          \txtTimeOverride=scsStringGadget(305,nTop,67,21,"",0,"txtTimeOverride")
          scsToolTip(\txtTimeOverride,Lang("WQS","txtTimeOverrideTT"))
          setValidChars(\txtTimeOverride, "0123456789.:") ; will be disabled on 'GetFocus' if the parent cue is a callable cue
          
          nTop + 30
          \chkCompleteAssocAutoStartCues=scsCheckBoxGadget2(193,nTop,254,17,Lang("WQS","chkCompleteAssocAutoStartCues"),0,"chkCompleteAssocAutoStartCues")
          \chkHoldAssocAutoStartCues=scsCheckBoxGadget2(193,nTop+17,254,17,Lang("WQS","chkHoldAssocAutoStartCues"),0,"chkHoldAssocAutoStartCues")
          
          nTop + 52
          \cntGoNext=scsContainerGadget(168,nTop,304,77,0,"cntGoNext")
            \fraGoNext=scsFrameGadget(0,0,304,77,Lang("WQS","fraGoNext"),0,"fraGoNext")
            \chkGoNext=scsCheckBoxGadget2(62,17,175,17,Lang("WQS","chkGoNext"),0,"chkGoNext")
            scsToolTip(\chkGoNext,Lang("WQS","chkGoNextTT"))
            \lblGoNextDelay=scsTextGadget(5,46,171,15,Lang("WQS","lblGoNextDelay"),#PB_Text_Right,"lblGoNextDelay")
            \txtGoNextDelay=scsStringGadget(183,43,67,21,"",0,"txtGoNextDelay")
            scsToolTip(\txtGoNextDelay,Lang("WQS","txtGoNextDelayTT"))
            setValidChars(\txtGoNextDelay, "0123456789.:") 
          scsCloseGadgetList()
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaSFRCues
      
      ; setVisible(\scaSFRCues, #True)
      setEnabled(\scaSFRCues, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQSCreated = #True
  
EndProcedure


Structure strWQR ; fmEditQR
  SUBCUE_HEADER_FIELDS()
  chkHideSCS.i
  chkInvisible.i
  btnBrowse.i[2]
  cntSubDetailR.i
  lblFileName.i
  lblParams.i
  lblStartFolder.i
  scaRunProg.i
  txtFileName.i
  txtParams.i
  txtStartFolder.i
EndStructure
Global WQR.strWQR ; fmEditQR

Procedure createfmEditQR()
  PROCNAMEC()
  Protected nTop, nHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQR
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQR
      \scaRunProg=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaRunProg")
        setVisible(\scaRunProg, #False)
        ; header
        SUBCUE_HEADER_CODE(WQR)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailR=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailT")
          
          nTop = 25
          \lblFileName=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQR","lblFileName"),#PB_Text_Right,"lblFileName")
          \txtFileName=scsStringGadget(gnNextX+gnGap,nTop,400,21,"",0,"txtFileName")
          scsToolTip(\txtFileName, Lang("WQR", "txtFileNameTT"))
          ; setEnabled(\txtFileName, #False)
          \btnBrowse[0]=scsButtonGadget(gnNextX,nTop+1,20,20,"...",0,"btnBrowse[0]")
          scsToolTip(\btnBrowse[0], Lang("WQR", "txtFileNameTT"))
          
          nTop + 25
          \lblParams=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQR","lblParams"),#PB_Text_Right,"lblParams")
          \txtParams=scsStringGadget(gnNextX+gnGap,nTop,400,21,"",0,"txtParams")
          scsToolTip(\txtParams, Lang("WQR", "txtParamsTT"))
          
          nTop + 25
          \lblStartFolder=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQR","lblStartFolder"),#PB_Text_Right,"lblStartFolder")
          \txtStartFolder=scsStringGadget(gnNextX+gnGap,nTop,400,21,"",0,"txtStartFolder")
          scsToolTip(\txtStartFolder, Lang("WQR", "txtStartFolderTT"))
          ; setEnabled(\txtStartFolder, #False)
          \btnBrowse[1]=scsButtonGadget(gnNextX,nTop+1,20,20,"...",0,"btnBrowse[1]")
          scsToolTip(\btnBrowse[1], Lang("WQR", "txtStartFolderTT"))
          
          nTop + 30
          \chkHideSCS=scsCheckBoxGadget2(180,nTop,-1,17,Lang("WQR","chkHideSCS"),0,"chkHideSCS")
          nTop + 22
          \chkInvisible=scsCheckBoxGadget2(180,nTop,-1,17,Lang("WQR","chkInvisible"),0,"chkInvisible")
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaRunProg
      
      ; setVisible(WQR\scaRunProg, #True)
      setEnabled(WQR\scaRunProg, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQRCreated = #True
  
EndProcedure

Structure strWQT ; fmEditQT - set position
  SUBCUE_HEADER_FIELDS()
  cboPosType.i
  cboSetPosCue.i
  cboSetPosCueMarker.i
  cntSubDetailT.i
  lblPosType.i
  lblSetPosCue.i
  lblSetPosCueMarker.i
  lblSetPosTime.i
  scaSetPos.i
  txtSetPosTime.i
EndStructure
Global WQT.strWQT ; fmEditQT

Procedure createfmEditQT() ; set position
  PROCNAMEC()
  Protected nTop, nHeight
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQT
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQT
      \scaSetPos=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaSetPos")
        setVisible(\scaSetPos, #False)
        ; header
        SUBCUE_HEADER_CODE(WQT)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailT=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailT")
          
          nTop = 25
          \lblSetPosCue=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQT","lblSetPosCue"), #PB_Text_Right,"lblSetPosCue")
          \cboSetPosCue=scsComboBoxGadget(183,nTop,293,21,0,"cboSetPosCue")
          
          nTop + 33
          \lblPosType=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQT","lblPosType"), #PB_Text_Right,"lblPosType")
          \cboPosType=scsComboBoxGadget(183,nTop,95,21,0,"cboPosType")
          
          nTop + 33
          \lblSetPosTime=scsTextGadget(14,nTop+gnLblVOffsetS,162,15,Lang("WQT","lblSetPosTime"), #PB_Text_Right,"lblSetPosTime")
          \txtSetPosTime=scsStringGadget(183,nTop,64,21,"",0,"txtSetPosTime")
          scsToolTip(\txtSetPosTime,Lang("WQT","txtSetPosTimeTT"))
          setValidChars(\txtSetPosTime, "+-0123456789.:")
          \lblSetPosCueMarker=scsTextGadget(14,GadgetY(\lblSetPosTime),162,15,Lang("WQT","lblSetPosCueMarker"), #PB_Text_Right,"lblSetPosCueMarker")
          \cboSetPosCueMarker=scsComboBoxGadget(183,nTop,293,21,0,"cboSetPosCueMarker")
          setVisible(\lblSetPosCueMarker, #False)
          setVisible(\cboSetPosCueMarker, #False)
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaSetPos
      
      ; setVisible(WQT\scaSetPos, #True)
      setEnabled(WQT\scaSetPos, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQTCreated = #True
  
EndProcedure

Structure strWQU ; fmEditQU
  SUBCUE_HEADER_FIELDS()
  cboMTCFrameRate.i
  cboMTCType.i
  cntMTCStartTime.i
  cntSubDetailU.i
  lblMTCDuration.i
  lblMTCFrameRate.i
  lblMTCPreRoll.i
  lblMTCStartSep.i[4]
  lblMTCStartTime.i
  lblMTCType.i
  scaMTCCue.i
  txtMTCDuration.i
  txtMTCPreRoll.i
  txtMTCStartPart.i[4]
EndStructure
Global WQU.strWQU ; fmEditQU

Procedure createfmEditQU()
  PROCNAMEC()
  Protected nTop, nWidth, nHeight
  Protected sTmpText.s, sComboBoxText.s
  Protected n
  Protected nSepWidth, nPartWidth, nFlag
  Protected ttip
  
  debugMsg(sProcName, #SCS_START)
  
  scsOpenGadgetList(WED\cntRight)
    gnCurrentEditorComponent = #WQU
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    
    With WQU
      \scaMTCCue=scsScrollAreaGadget(0, 0, 0, 0, gnEditorScaPropertiesInnerWidth, gnEditorScaSubCueInnerHeight, 30, #PB_ScrollArea_Flat, "scaMTCCue")
        setVisible(\scaMTCCue, #False)
        ; header
        SUBCUE_HEADER_CODE(WQU)
        
        ; detail
        nTop = GadgetHeight(\cntSubHeader) + 4
        nHeight = gnEditorScaSubCueInnerHeight - nTop
        \cntSubDetailU=scsContainerGadget(0,nTop,gnEditorScaPropertiesInnerWidth,nHeight,0,"cntSubDetailU")
          
          nTop = 40
          If grLicInfo\bLTCAvailable
            \lblMTCType=scsTextGadget(0,nTop+gnLblVOffsetS,176,15,Lang("WQU","lblMTCType"),#PB_Text_Right,"lblMTCType")
            \cboMTCType=scsComboBoxGadget(gnNextX+7,nTop,40,21,0,"cboMTCType")
          EndIf
          nTop + 30
          \lblMTCStartTime=scsTextGadget(0,nTop+gnLblVOffsetS,176,15,Lang("WQU","lblMTCStartTime"),#PB_Text_Right,"lblMTCStartTime")
          ; the following code for creating an 'MTC Gadget' is based on code from the PB Forum topic "Customized IPAddressGadget() is need" (sic)
          ; at https://www.purebasic.fr/english/viewtopic.php?f=13&t=37929
          nPartWidth = GetTextWidth(" 88 ")
          nSepWidth = GetTextWidth(":") + 1
          nWidth = (4 * nPartWidth) + (3 * nSepWidth) + gl3DBorderAllowanceX + gl3DBorderAllowanceX
          \cntMTCStartTime=scsContainerGadget(183,nTop,nWidth,22,#PB_Container_Double,"cntMTCStartTime")
            SetGadgetColor(\cntMTCStartTime, #PB_Gadget_BackColor, #SCS_White)
            setAllowEditorColors(\cntMTCStartTime, #False)
            ; nFlag = #PB_String_Numeric | #PB_String_BorderLess | #ES_CENTER
            nFlag = #PB_String_BorderLess | #ES_CENTER
            \txtMTCStartPart[0]=scsStringGadget(1,1,nPartWidth,20,"",nFlag,"txtMTCStartPart[0]")
            \txtMTCStartPart[1]=scsStringGadget(gnNextX+nSepWidth,1,nPartWidth,20,"",nFlag,"txtMTCStartPart[1]")
            \txtMTCStartPart[2]=scsStringGadget(gnNextX+nSepWidth,1,nPartWidth,20,"",nFlag,"txtMTCStartPart[2]")
            \txtMTCStartPart[3]=scsStringGadget(gnNextX+nSepWidth,1,nPartWidth,20,"",nFlag,"txtMTCStartPart[3]")
            ; Create separators 
            For n = 0 To 2
              \lblMTCStartSep[n]=scsTextGadget(GadgetX(\txtMTCStartPart[n])+GadgetWidth(\txtMTCStartPart[n])+1,1,nSepWidth,20,":",#PB_Text_Center,"lblMTCStartSep["+n+"]")
              SetGadgetColor(\lblMTCStartSep[n], #PB_Gadget_BackColor, #SCS_White)
              setAllowEditorColors(\lblMTCStartSep[n], #False)
            Next n
          scsCloseGadgetList() 
          ;Set length of per field, and tooltip
          For n = 0 To 3
            SendMessage_(\txtMTCStartPart[n], #EM_LIMITTEXT, 2, 0) 
            scsToolTip(\txtMTCStartPart[n],Lang("WQU","txtMTCStartTimeTT"))
          Next n
          
          nTop + 30
          \lblMTCFrameRate=scsTextGadget(0,nTop+4,176,15,Lang("WQU","lblMTCFrameRate"),#PB_Text_Right,"lblMTCFrameRate")
          sComboBoxText = ""
          For n = 0 To #SCS_MTC_LAST
            sTmpText = decodeMTCFrameRateL(n)
            If Len(sTmpText) > Len(sComboBoxText)
              sComboBoxText = sTmpText
            EndIf
          Next n
          nWidth = GetTextWidth(sComboBoxText) + glThumbWidth + gl3DBorderAllowanceX + 8
          \cboMTCFrameRate=scsComboBoxGadget(gnNextX+7,nTop,nWidth,21,0,"cboMTCFrameRate")
          
          nTop + 30
          \lblMTCPreRoll=scsTextGadget(0,nTop+gnLblVOffsetS,176,15,Lang("WQU","lblMTCPreRoll"),#PB_Text_Right,"lblMTCPreRoll")
          \txtMTCPreRoll=scsStringGadget(gnNextX+7,nTop,48,21,"",0,"txtMTCPreRoll")
          setValidChars(\txtMTCPreRoll, "0123456789.")  ; omitted ":" as time not expected to be more than about 5 seconds and should definitely be less than a minute
          scsToolTip(\txtMTCPreRoll,Lang("WQU","txtMTCPreRollTT"))
          
          nTop + 30
          \lblMTCDuration=scsTextGadget(0,nTop+gnLblVOffsetS,176,15,Lang("WQU","lblMTCDuration"),#PB_Text_Right,"lblMTCDuration")
          \txtMTCDuration=scsStringGadget(gnNextX+7,nTop,67,21,"",0,"txtMTCDuration")
          setValidChars(\txtMTCDuration, "0123456789.:")
          scsToolTip(\txtMTCDuration,Lang("WQU","txtMTCDurationTT"))
          
        scsCloseGadgetList()
        
      scsCloseGadgetList() ; scaMTCCue
      
      ; setVisible(WQU\scaMTCCue, #True)
      setEnabled(WQU\scaMTCCue, #True)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentEditorComponent = 0
  grCED\bQUCreated = #True
  
EndProcedure

Structure strWSP ; fmSplash
  cvsSplash.i
EndStructure
Global WSP.strWSP ; fmSplash

Procedure createfmSplash()
  PROCNAMEC()
  Protected nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, nWindowFlags
  
  If IsWindow(#WSP)
    ; already created
    ProcedureReturn #True
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  ; normal production use - no border
  ; #PB_Window_Invisible is NOT included in the flags because doing so causes the window to be initially displayed as a black box when made 'visible',
  ; and the contents of the box are not immediately seen. By making the window visible at 'OpenWindow', this problems goes away. However, it then
  ; becomes necessary to place certain gadgets outside the window until they are required - see comments: "X was ...".
  
  nWindowWidth = 637
  nWindowHeight = 320
  nWindowFlags = #PB_Window_ScreenCentered | #PB_Window_BorderLess
  adjustWindowPosIfReqd(@nWindowLeft, @nWindowTop, @nWindowWidth, @nWindowHeight, @nWindowFlags)
  
  If OpenWindow(#WSP, nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, "", nWindowFlags)
    registerWindow(#WSP, "WSP(fmSplash)")
    SetWindowColor(#WSP, #SCS_Black)
    WSP\cvsSplash=scsCanvasGadget(0, 0, WindowWidth(#WSP), WindowHeight(#WSP), 0, "cvsSplash")
    
    If gbInitialising
      debugMsg(sProcName, "calling loadArrayVideoAudioDevs()")
      loadArrayVideoAudioDevs()
      gbVideoAudioDevsLoaded = #True
    EndIf
    
    setWindowEnabled(#WSP,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWFI ; fmFind
  btnCancel.i
  btnHelp.i
  btnSelect.i
  chkFullPathNames.i
  cntCueOptions.i
  grdFindResults.i
  lblFind.i
  optAllCues.i
  optAudVidOnly.i
  txtFind.i
EndStructure
Global WFI.strWFI ; fmFind

Procedure createfmFind(nParentWindow)
  PROCNAMEC()
  Protected nLeft, nTop, nWidth
  
  If IsWindow(#WFI)
    If gaWindowProps(#WFI)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WFI)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WFI, 0, 0, 740, 410, Lang("WFI","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WFI, "WFI(fmFind)")
    With WFI
      nTop = 15
      \lblFind=scsTextGadget(13,nTop+gnLblVOffsetS,50,15,Lang("WFI","lblFind"),#PB_Text_Right,"lblFind")
      \txtFind=scsStringGadget(gnNextX+7,nTop,150,21,"",0,"txtFind")
      setGType(\txtFind, #SCS_GTYPE_STRING_NO_SELECT_WHOLE_FIELD)
      \cntCueOptions=scsContainerGadget(gnNextX+20,nTop,300,21,0,"cntCueOptions")
        nLeft = 0
;         nWidth = GetTextWidth(Lang("WFI","optAudVidOnly")) + 20
;         \optAudVidOnly=scsOptionGadget(nLeft,0,nWidth,21,Lang("WFI","optAudVidOnly"),"optAudVidOnly")
;         \optAllCues=scsOptionGadget(gnNextX+12,0,110,21,Lang("WFI","optAllCues"),"optAllCues")
        nWidth = GetTextWidth(Lang("WFI","optAllCues")) + 20
        \optAllCues=scsOptionGadget(nLeft,0,nWidth,21,Lang("WFI","optAllCues"),"optAllCues")
        \optAudVidOnly=scsOptionGadget(gnNextX+12,0,200,21,Lang("WFI","optAudVidOnly"),"optAudVidOnly")
      scsCloseGadgetList()
      nTop + 21
;       nLeft = GadgetX(\cntCueOptions) + GadgetX(\optAudVidOnly)
      nLeft = GadgetX(\cntCueOptions) + GadgetX(\optAllCues)
      \chkFullPathNames=scsCheckBoxGadget(nLeft,nTop,200,17,Lang("WFI","chkFullPathNames"),0,"chkFullPathNames")
      nTop + 20
      nLeft = 13
      nWidth = WindowWidth(#WFI) - nLeft - nLeft
      \grdFindResults=scsListIconGadget(nLeft,nTop,nWidth,300,grText\sTextCue,50,#PB_ListIcon_GridLines|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect,"grdFindResults")
      AddGadgetColumn(\grdFindResults,1,Lang("WFI","Description"),220)
      AddGadgetColumn(\grdFindResults,2,Lang("WFI","FileName"),240)
      autoFitGridCol(\grdFindResults,2) ; autofit "FileName" column
      
      nTop = GadgetY(\grdFindResults) + GadgetHeight(\grdFindResults) + 12
      nLeft = (WindowWidth(#WFI) - 304) / 2.0
      \btnSelect=scsButtonGadget(nLeft,nTop,120,23,"",#PB_Button_Default,"btnSelect")  ; caption populated dynamically
      ; scsToolTip(\btnSelect,Lang("WFI","btnSelectTT"))
      \btnCancel=scsButtonGadget(gnNextX+12,nTop,80,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(gnNextX+12,nTop,80,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
    EndWith
    
    AddKeyboardShortcut(#WFI, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    AddKeyboardShortcut(#WFI, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
    
    ; setWindowVisible(#WFI,#True)
    setWindowEnabled(#WFI,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWIR ; fmInputRequester
  btnCancel.i
  btnOK.i
  lblHeading.i
  lblItem.i
  txtItem.i
EndStructure
Global WIR.strWIR ; fmInputRequester

Procedure createfmInputRequester(nParentWindow)
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nGap
  
  ; debugMsg(sProcName, #SCS_START + ", nParentWindow=" + decodeWindow(nParentWindow))
  
  If IsWindow(#WIR)
    If gaWindowProps(#WIR)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WIR)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WIR, 0, 0, 500, 150, "", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WIR, "WIR(fmInputRequester)")
    With WIR
      nLeft = 40
      nTop = 21
      \lblHeading=scsTextGadget(nLeft,nTop,50,17,"",0,"lblHeading")
      scsSetGadgetFont(\lblHeading, #SCS_FONT_GEN_BOLD10)
      nTop + 34
      \lblItem=scsTextGadget(nLeft,nTop,120,15,"",#PB_Text_Right,"lblItem")
      nTop + 17
      \txtItem=scsStringGadget(nLeft,nTop,400,21,"",0,"txtItem")
      nTop + 40
      nWidth = 80
      nGap = 12
      nLeft = (WindowWidth(#WIR) - (nWidth + nGap + nWidth)) >> 1
      \btnOK=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
    EndWith
    
    AddKeyboardShortcut(#WIR, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    AddKeyboardShortcut(#WIR, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
    
    ; setWindowVisible(#WIR,#True)
    setWindowEnabled(#WIR,#True)
    
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWRG ; fmRegister
  btnCancel.i
  btnOK.i
  btnRegister.i
  cntDemo.i
  cntRegister.i
  cvsAuthStringEye.i
  hypRegLink.i
  lblAuthString.i
  lblDemoInfo1.i
  lblDemoInfo2.i
  lblDemoInfo3.i
  lblDemoInfo4.i
  lblEnterRego.i
  lblUserName.i
  txtAuthString.i
  txtLicUser.i
  ; other data
  nParentWindow.i
EndStructure
Global WRG.strWRG ; fmRegister

Procedure createfmRegister(nParentWindow)
  PROCNAMEC()
  Protected nFlags, nLeft, nTop, nWidth, nHeight
  Protected nInfoLeft, nInfoWidth
  Protected sText.s
  
  If IsWindow(#WRG)
    ; already created
    ProcedureReturn #True
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WRG, 0, 0, 388, 210, Lang("WRG","Window"), #PB_Window_SystemMenu|#PB_Window_ScreenCentered|#PB_Window_Invisible,WindowID(nParentWindow))
    registerWindow(#WRG, "WRG(fmRegister)")
    With WRG
      CompilerIf #cDemo
        \cntDemo=scsContainerGadget(0,0,WindowWidth(#WRG),WindowHeight(#WRG),#PB_Container_BorderLess,"cntDemo")
          nInfoLeft = 18
          nInfoWidth = GadgetWidth(\cntDemo) - (nInfoLeft * 2)
          nTop = 12
          ; \lblDemoInfo1: "This is a demo-only version of SCS."
          \lblDemoInfo1=scsTextGadget(nInfoLeft,nTop,nInfoWidth,17,Lang("WRG","lblDemoInfo1"),#PB_Text_Center,"lblDemoInfo1")
          scsSetGadgetFont(\lblDemoInfo1, #SCS_FONT_GEN_NORMAL9)
          nHeight = setTextGadgetHeight(\lblDemoInfo1)
          nTop + nHeight + 12
          ; \lblDemoInfo2: "To register SCS on this computer you need to install a full version of SCS."
          \lblDemoInfo2=scsTextGadget(nInfoLeft,nTop,nInfoWidth,45,Lang("WRG","lblDemoInfo2"),#PB_Text_Center,"lblDemoInfo2")
          nHeight = setTextGadgetHeight(\lblDemoInfo2)
          nTop + nHeight + 3
          ; \lblDemoInfo3: "To purchase a full version of SCS, please click on this link:"
          \lblDemoInfo3=scsTextGadget(nInfoLeft,nTop,nInfoWidth,45,Lang("WRG","lblDemoInfo3"),#PB_Text_Center,"lblDemoInfo3")
          nHeight = setTextGadgetHeight(\lblDemoInfo3)
          nTop + nHeight + 3
          ; \hypRegLink - nb #SCS_REGISTER_URL_DISPLAY = "www.showcuesystems.com/cms/purchase" for regular demo version, "www.lambertstudios.net/scs" for agent David Lambert demo version, etc
          sText = #SCS_REGISTER_URL_DISPLAY
          \hypRegLink=scsHyperLinkGadget(30, nTop, 200, 20, sText, #SCS_Blue, #PB_HyperLink_Underline, "hypRegLink")
          SetGadgetColor(\hypRegLink, #PB_Gadget_FrontColor, #SCS_Blue)
          nWidth = calcTextWidth(#WRG, \hypRegLink, sText)
          nLeft = (GadgetWidth(\cntDemo) - nWidth) >> 1
          ResizeGadget(\hypRegLink,nLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore)
          nTop + 42
          ; \lblDemoInfo4: "If you have already purchased an SCS license then you need to download and install the program using the information supplied in your registration email."
          \lblDemoInfo4=scsTextGadget(nInfoLeft,nTop,nInfoWidth,17,Lang("WRG","lblDemoInfo4"),#PB_Text_Center,"lblDemoInfo4")
          nHeight = setTextGadgetHeight(\lblDemoInfo4)
          nTop = GadgetHeight(\cntDemo) - 36
          nWidth = 80
          nLeft = (GadgetWidth(\cntDemo) - nWidth) >> 1
          \btnOK=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
        scsCloseGadgetList()
      CompilerElseIf #cWorkshop
        ; no action
      CompilerElse
        \cntRegister=scsContainerGadget(0,0,WindowWidth(#WRG),WindowHeight(#WRG),#PB_Container_BorderLess,"cntRegister")
          \lblEnterRego=scsTextGadget(8,18,283,16,Lang("WRG","lblEnterRego"),#PB_Text_Center,"lblEnterRego")
          scsSetGadgetFont(\lblEnterRego, #SCS_FONT_GEN_BOLD10)
          \lblUserName=scsTextGadget(26,50,81,21,Lang("WRG","lblUserName"),0,"lblUserName")
          \txtLicUser=scsStringGadget(26,66,250,21,"",0,"txtLicUser")
          \lblAuthString=scsTextGadget(26,96,103,21,Lang("WRG","lblAuthString"),0,"lblAuthString")
          \txtAuthString=scsStringGadget(26,112,140,21,"",#PB_String_UpperCase|#PB_String_Password,"txtAuthString")
          \cvsAuthStringEye=scsCanvasGadget(gnNextX,112,21,21,0,"cvsAuthStringEye")
          \btnRegister=scsButtonGadget(26,156,80,gnBtnHeight,Lang("WRG","Register"),#PB_Button_Default,"btnRegister")
          \btnCancel=scsButtonGadget(126,156,80,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
        scsCloseGadgetList()
      CompilerEndIf
      AddKeyboardShortcut(#WRG, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WRG, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
    EndWith
    ; setWindowVisible(#WRG,#True)
    setWindowEnabled(#WRG,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWTM ; fmTemplates
  btnBack.i
  btnCreateCueFile.i
  btnCreateTemplate.i
  btnClose.i
  btnDelete.i
  btnDiscard.i
  btnFullEdit.i
  btnHelp.i
  btnNext.i
;  btnOpen.i
  btnQuickEdit.i
  btnSave.i
  btnSaveAs.i
  chkCopyFiles.i
  cntButtons.i
  cntTemplates.i
  edgTmDesc.i
  grdCuesChk.i   ; with checkbox
  grdCuesNoChk.i ; no checkbox
  grdDevMapsChk.i
  grdDevMapsNoChk.i
  grdDevsChk.i
  grdDevsNoChk.i
  grdTemplates.i
  lblCues.i
  lblDevMaps.i
  lblDevs.i
  lblProdTitle.i
  lblTemplates.i
  lblTemplatesStatus.i
  lblTmDesc.i
  lblTmName.i
  pnlProps.i
  scaFiles.i
  txtProdTitle.i
  txtTmName.i
EndStructure
Global WTM.strWTM ; fmTemplates

Procedure createfmTemplates(nParentWindow)
  PROCNAMEC()
  Protected n
  Protected nLeft, nTop, nWidth, nHeight
  Protected nPanelLeft, nPanelTop, nPanelWidth, nPanelHeight
  Protected nScrollAreaWidth, nScrollAreaHeight
  Protected nContainerWidth, nContainerHeight
  Protected nItemWidth, nItemHeight
  Protected nBtnLeft, nBtnTop, nBtnWidth, nBtnHeight, nBtnGap
  Protected nWideBtnWidth, nTallBtnHeight
  Protected nArraySize
  
  If IsWindow(#WTM)
    If gaWindowProps(#WTM)\nParentWindow = nParentWindow
      ProcedureReturn #True
    Else
      ; different parent to last time, so force window to be recreated
      scsCloseWindow(#WTM)
    EndIf
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  
  If OpenWindow(#WTM, 0, 0, 640, 550, Lang("WTM","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WTM, "WTM(fmTemplates)", nParentWindow)
    SetWindowCallback(@WTM_windowCallback(), #WTM)  ; window callback
    With WTM
      nLeft = 8
      nTop = 8
      nWidth = 200
      nHeight = WindowHeight(#WTM) - nTop - 72
      nContainerWidth = nWidth ; - glScrollBarWidth - 4
      nContainerHeight = nHeight
      \cntTemplates=scsContainerGadget(0,nTop,nWidth,nHeight,#PB_Container_BorderLess,"cntTemplates")
        nTop = 3
        \lblTemplates=scsTextGadget(12,nTop,nWidth,15,Lang("WTM","lblTemplates"),0,"lblTemplates")
        nTop + 19
        nHeight = GadgetHeight(\cntTemplates) - nTop
        \grdTemplates=scsListViewGadget(nLeft, nTop, nWidth, nHeight, 0,"grdTemplates")
      scsCloseGadgetList()
      nPanelLeft = GadgetX(\cntTemplates) + GadgetWidth(\cntTemplates) + gnGap2
      nPanelTop = GadgetY(\cntTemplates)
      nPanelWidth = 420
      nPanelHeight = GadgetHeight(\cntTemplates) - 31
      \pnlProps=scsPanelGadget(nPanelLeft,nPanelTop,nPanelWidth,nPanelHeight,"pnlProps")
        addGadgetItemWithData(\pnlProps, Lang("WTM", "TabTemplate"), #SCS_WTM_TAB_TEMPLATE)
        nTop = 12
        \lblTmName=scsTextGadget(0,nTop+gnLblVOffsetS,100,15,Lang("WTM","lblTmName"),#PB_Text_Right,"lblTmName")
        \txtTmName=scsStringGadget(gnNextX+gnGap,nTop,300,21,"",0,"txtTmName")
        nTop + GadgetHeight(\txtTmName) + 4
        \lblTmDesc=scsTextGadget(0,nTop+gnLblVOffsetS,100,29,Lang("WTM","lblTmDesc"),#PB_Text_Right,"lblTmDesc")
        \edgTmDesc=scsEditorGadget(gnNextX+gnGap,nTop,300,75,#PB_Editor_WordWrap,"edgTmDesc")
        
        addGadgetItemWithData(\pnlProps, Lang("WTM", "TabCues"), #SCS_WTM_TAB_CUES)
        nLeft = 4
        nTop = 8
        nWidth = nPanelWidth - ((nLeft + gl3DBorderAllowanceX) * 2)
        \lblCues=scsTextGadget(12,nTop,nWidth,15,Lang("WTM","lblCues"),0,"lblCues")
        SetGadgetFont(\lblCues, #SCS_FONT_GEN_BOLD)
        nTop + 19
        nHeight = nPanelHeight - nTop - 32 - gl3DBorderAllowanceY
        
        \grdCuesChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, "",21,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdCuesChk")
        AddGadgetColumn(\grdCuesChk,1,Lang("Common","Cue"),45)
        AddGadgetColumn(\grdCuesChk,2,Lang("Common","Description"),120)
        AddGadgetColumn(\grdCuesChk,3,Lang("Common","CueType"),80)
        AddGadgetColumn(\grdCuesChk,4,Lang("Common","Activation"),76)
        autoFitGridCol(\grdCuesChk, 2) ; autofit "Description" column
        ; now add a checkbox to the header of the grdCuesChk ListIconGadget
        ; based on code supplied by RASHAD in reply to my PB Forum Topic "ListIconGadget checkbox in column header?" posted in Oct 2016
        grWTM\nCuesHeader = SendMessage_(GadgetID(\grdCuesChk), #LVM_GETHEADER, 0, 0)
        SetWindowLongPtr_(grWTM\nCuesHeader, #GWL_STYLE, GetWindowLongPtr_(grWTM\nCuesHeader, #GWL_STYLE)|#HDS_CHECKBOXES)
        grWTM\rCuesHDItem\mask = #HDI_FORMAT
        grWTM\rCuesHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
        SendMessage_(grWTM\nCuesHeader, #HDM_SETITEM, 0, grWTM\rCuesHDItem)
        
        \grdCuesNoChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("Common","Cue"),45,#PB_ListIcon_GridLines,"grdCuesNoChk")
        AddGadgetColumn(\grdCuesNoChk,1,Lang("Common","Description"),120)
        AddGadgetColumn(\grdCuesNoChk,2,Lang("Common","CueType"),80)
        AddGadgetColumn(\grdCuesNoChk,3,Lang("Common","Activation"),76)
        autoFitGridCol(\grdCuesNoChk, 1) ; autofit "Description" column
        
        addGadgetItemWithData(\pnlProps, Lang("WTM", "TabDevs"), #SCS_WTM_TAB_DEVS)
        nLeft = 4
        nTop = 8
        nWidth = nPanelWidth - ((nLeft + gl3DBorderAllowanceX) * 2)
        \lblDevs=scsTextGadget(12,nTop,nWidth,15,Lang("WTM","lblDevs"),0,"lblDevs")
        SetGadgetFont(\lblDevs, #SCS_FONT_GEN_BOLD)
        nTop + 19
        nHeight = (nPanelHeight - nTop - 32 - gl3DBorderAllowanceY) * 0.7
        
        \grdDevsChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, "",21,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdDevsChk")
        AddGadgetColumn(\grdDevsChk,1,Lang("WEP","lblDevType"),160)
        AddGadgetColumn(\grdDevsChk,2,grText\sTextDevice,100)
        autoFitGridCol(\grdDevsChk, 2) ; autofit "Device" column
        ; now add a checkbox to the header of the grdDevsChk ListIconGadget
        ; based on code supplied by RASHAD in reply to my PB Forum Topic "ListIconGadget checkbox in column header?" posted in Oct 2016
        grWTM\nDevsHeader = SendMessage_(GadgetID(\grdDevsChk), #LVM_GETHEADER, 0, 0)
        SetWindowLongPtr_(grWTM\nDevsHeader, #GWL_STYLE, GetWindowLongPtr_(grWTM\nDevsHeader, #GWL_STYLE)|#HDS_CHECKBOXES)
        grWTM\rDevsHDItem\mask = #HDI_FORMAT
        grWTM\rDevsHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
        SendMessage_(grWTM\nDevsHeader, #HDM_SETITEM, 0, grWTM\rDevsHDItem)
        
        \grdDevsNoChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("WEP","lblDevType"),160,#PB_ListIcon_GridLines,"grdDevsNoChk")
        AddGadgetColumn(\grdDevsNoChk,1,grText\sTextDevice,100)
        autoFitGridCol(\grdDevsNoChk, 1) ; autofit "Device" column
        
        nTop + nHeight + 12
        \lblDevMaps=scsTextGadget(12,nTop,nWidth,15,Lang("WTM","lblDevMaps"),0,"lblDevMaps")
        SetGadgetFont(\lblDevMaps, #SCS_FONT_GEN_BOLD)
        nTop + 19
        nHeight = nPanelHeight - nTop - 32 - gl3DBorderAllowanceY
        
        \grdDevMapsChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, "",21,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdDevMapsChk")
        AddGadgetColumn(\grdDevMapsChk,1,Lang("WEP","lblDevMap"),160)
        AddGadgetColumn(\grdDevMapsChk,2,Lang("WEP","lblAudioDriver"),100)
        autoFitGridCol(\grdDevMapsChk, 2) ; autofit "Audio Driver" column
        ; now add a checkbox to the header of the grdDevMapsChk ListIconGadget
        ; based on code supplied by RASHAD in reply to my PB Forum Topic "ListIconGadget checkbox in column header?" posted in Oct 2016
        grWTM\nDevMapsHeader = SendMessage_(GadgetID(\grdDevMapsChk), #LVM_GETHEADER, 0, 0)
        SetWindowLongPtr_(grWTM\nDevMapsHeader, #GWL_STYLE, GetWindowLongPtr_(grWTM\nDevMapsHeader, #GWL_STYLE)|#HDS_CHECKBOXES)
        grWTM\rDevMapsHDItem\mask = #HDI_FORMAT
        grWTM\rDevMapsHDItem\fmt = #HDF_CHECKBOX|#HDF_FIXEDWIDTH|#HDF_CHECKED
        SendMessage_(grWTM\nDevMapsHeader, #HDM_SETITEM, 0, grWTM\rDevMapsHDItem)
        
        \grdDevMapsNoChk=scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("WEP","lblDevMap"),160,#PB_ListIcon_GridLines,"grdDevMapsNoChk")
        AddGadgetColumn(\grdDevMapsNoChk,1,Lang("WEP","lblAudioDriver"),100)
        autoFitGridCol(\grdDevMapsNoChk, 1) ; autofit "Audio Driver" column
        
      scsCloseGadgetList()
      nBtnTop = nPanelTop + nPanelHeight + 4
      nBtnHeight = gnBtnHeight
      nBtnWidth = 81
      nBtnGap = gnGap
      nBtnLeft = nPanelLeft + 12
      \btnSave=scsButtonGadget(nBtnLeft,nBtnTop,nBtnWidth,nBtnHeight,Lang("Btns","Save"),0,"btnSave")
      \btnDiscard=scsButtonGadget(gnNextX+nBtnGap,nBtnTop,nBtnWidth,nBtnHeight,Lang("Btns","Discard"),0,"btnDiscard")
      nBtnWidth = 50
      nBtnLeft = nPanelLeft + nPanelWidth - ((nBtnWidth * 2) + nBtnGap + gl3DBorderWidth)
      \btnBack=scsButtonGadget(nBtnLeft,nBtnTop,nBtnWidth,nBtnHeight,"< "+Lang("Btns","Back"),0,"btnBack")
      \btnNext=scsButtonGadget(gnNextX+nBtnGap,nBtnTop,nBtnWidth,nBtnHeight,Lang("Btns","Next")+" >",0,"btnNext")
      ; now resize and position the back and next buttons following report from Lluís Vilarrasa about buttons being too narrow for Catalan text
      setGadgetWidth(\btnBack)
      setGadgetWidth(\btnNext)
      If GadgetWidth(\btnBack) > nBtnWidth
        nBtnWidth = GadgetWidth(\btnBack)
      EndIf
      If GadgetWidth(\btnNext) > nBtnWidth
        nBtnWidth = GadgetWidth(\btnNext)
      EndIf
      nBtnLeft = nPanelLeft + nPanelWidth - ((nBtnWidth * 2) + nBtnGap + gl3DBorderWidth)
      ResizeGadget(\btnBack, nBtnLeft, #PB_Ignore, nBtnWidth, #PB_Ignore)
      nBtnLeft + nBtnWidth + nBtnGap
      ResizeGadget(\btnNext, nBtnLeft, #PB_Ignore, nBtnWidth, #PB_Ignore)
      
      nLeft = 0
      nTop = WindowHeight(#WTM) - 60
      nWidth = WindowWidth(#WTM)
      nHeight = 48
      \cntButtons=scsContainerGadget(nLeft, nTop, nWidth, nHeight, #PB_Container_BorderLess,"cntButtons")
        nBtnTop = 0
        nBtnHeight = gnBtnHeight
        nBtnWidth = 84
        nTallBtnHeight = 48
        nWideBtnWidth = 150
        nBtnGap = gnGap
        nBtnLeft = (GadgetWidth(\cntButtons) - ((nWideBtnWidth * 2) + (nBtnWidth * 3) + (nBtnGap * 4))) >> 1
        \btnCreateCueFile=scsButtonGadget(nBtnLeft,nBtnTop,nWideBtnWidth,nTallBtnHeight,Lang("WTM","btnCreateCueFile"),#PB_Button_MultiLine,"btnCreateCueFile")
        nBtnLeft = gnNextX+nBtnGap
        \btnCreateTemplate=scsButtonGadget(nBtnLeft,nBtnTop,nWideBtnWidth,nTallBtnHeight,Lang("WTM","btnCreateTemplate"),#PB_Button_MultiLine,"btnCreateTemplate")
        nBtnLeft = gnNextX+nBtnGap
        \btnQuickEdit=scsButtonGadget(nBtnLeft,0,nBtnWidth,nBtnHeight,Lang("Btns","QuickEdit"),0,"btnQuickEdit")
        \btnFullEdit=scsButtonGadget(nBtnLeft,25,nBtnWidth,nBtnHeight,Lang("Btns","FullEdit"),0,"btnFullEdit")
        nBtnLeft = gnNextX+nBtnGap
        \btnSaveAs=scsButtonGadget(nBtnLeft,0,nBtnWidth,nBtnHeight,LangEllipsis("Btns","SaveAs"),0,"btnSaveAs")
        \btnDelete=scsButtonGadget(nBtnLeft,25,nBtnWidth,nBtnHeight,Lang("Btns","Delete"),0,"btnDelete")
        nBtnLeft = gnNextX+nBtnGap
        \btnHelp=scsButtonGadget(nBtnLeft,0,nBtnWidth,nBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
        \btnClose=scsButtonGadget(nBtnLeft,25,nBtnWidth,nBtnHeight,Lang("Btns","Close"),0,"btnClose")
      scsCloseGadgetList()
    EndWith
    setWindowEnabled(#WTM,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWTP ; fmTimeProfile
  btnCancel.i
  btnOK.i
  cboTimeProfile.i
  lblTimeProfile.i
EndStructure
Global WTP.strWTP ; fmTimeProfile

Procedure createfmTimeProfile(nParentWindow)
  PROCNAMEC()
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WTP, 0, 0, 348, 154, Lang("WTP","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(nParentWindow))
    registerWindow(#WTP, "WTP(fmTimeProfile)")
    With WTP
      \lblTimeProfile=scsTextGadget(10,26,328,15,Lang("WTP","lblTimeProfile"),#PB_Text_Center,"lblTimeProfile")
      \cboTimeProfile=scsComboBoxGadget(71,51,206,21,0,"cboTimeProfile")
      \btnOK=scsButtonGadget(83,107,81,25,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      \btnCancel=scsButtonGadget(183,107,81,25,grText\sTextBtnCancel,0,"btnCancel")
      
      AddKeyboardShortcut(#WTP, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WTP, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    ; setWindowVisible(#WTP,#True)
    setWindowEnabled(#WTP,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWSS ; fmSpecialStart
  btnCancel.i
  btnCloseSCS.i
  btnOK.i
  chkDoNotOpenMRF.i
  chkFactoryReset.i
  chkIgnoreWindows.i
  chkNoWASAPI.i
  lblSpecialStart.i
EndStructure
Global WSS.strWSS ; fmSpecialStart

Procedure createfmSpecialStart()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth
  Protected nGap
  Protected sFactoryReset.s
  Protected nTextWidth, nItemWidth, nWindowWidth, nWindowHeight
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  sFactoryReset = Lang("WSS","chkFactoryReset")
  nTextWidth = GetTextWidth(sFactoryReset,#SCS_FONT_GEN_BOLD)
  nItemWidth = nTextWidth + 24
  If nItemWidth < 400
    nItemWidth = 400
  EndIf
  nWindowWidth = nItemWidth + 40  ; 40 = twice nLeft
  nWindowHeight = 180
  
  If OpenWindow(#WSS, 0, 0, nWindowWidth, nWindowHeight, Lang("WSS","Window"), #PB_Window_TitleBar | #PB_Window_ScreenCentered)
    registerWindow(#WSS, "WSS(fmSpecialStart)")
    With WSS
      nWidth = 380
      nLeft = (WindowWidth(#WSS) - nWidth) >> 1
      \lblSpecialStart=scsTextGadget(nLeft,12,nWidth,23,Lang("WSS","lblSpecialStart"),#PB_Text_Center,"lblSpecialStart")
      scsSetGadgetFont(\lblSpecialStart,#SCS_FONT_GEN_BOLD12)
      nTop = 40
      nLeft = 20
      \chkDoNotOpenMRF=scsCheckBoxGadget(nLeft,nTop,nItemWidth,21,Lang("WSS","chkDoNotOpenMRF"),0,"chkDoNotOpenMRF")
      nTop + 24
      \chkIgnoreWindows=scsCheckBoxGadget(nLeft,nTop,nItemWidth,21,Lang("WSS","chkIgnoreWindows"))
      ; Added 30Aug2019 11.8.2ai following report from John Zimmerman that SCS hung on initialising.
      nTop + 24
      \chkNoWASAPI=scsCheckBoxGadget(nLeft,nTop,nItemWidth,21,Lang("WOP","chkNoWASAPI")) ; nb this option also in Options - Audio Driver - DirectSound/WASAPI
      scsToolTip(\chkNoWASAPI,Lang("WOP","chkNoWASAPITT"))
      ; End added 30Aug2019 11.8.2ai
      nTop + 24
      \chkFactoryReset=scsCheckBoxGadget(nLeft,nTop,nItemWidth,21,sFactoryReset)
      scsSetGadgetFont(\chkFactoryReset,#SCS_FONT_GEN_BOLD)
      scsToolTip(\chkFactoryReset,Lang("WSS","chkFactoryResetTT"))
      nTop + 32
      nWidth = 81
      nGap = 8
      nLeft = (WindowWidth(#WSS) - ((nWidth * 3) + (nGap * 2))) >> 1
      nTop = WindowHeight(#WSS) - 40
      \btnOK=scsButtonGadget(nLeft,nTop,nWidth,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnCloseSCS=scsButtonGadget(gnNextX+nGap,nTop,nWidth,gnBtnHeight,Lang("Btns","CloseSCS"),0,"btnCloseSCS")
      
      AddKeyboardShortcut(#WSS, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WSS, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    setWindowVisible(#WSS,#True)
    setWindowEnabled(#WSS,#True)
    StickyWindow(#WSS, #True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWEM ; fmEditModal
  btnCancel.i
  btnCuePointsClear.i
  btnCuePointsClearSelection.i
  btnCuePointsReset.i
  btnFadeClear.i
  btnFadeReset.i
  btnOK.i
  btnTempoEtcReset.i
  btnUseDefaults.i
  cboDMXStartsDevMap.i
  cboFadeType.i
  cboTempoEtcAction.i
  chkOutputScreen.i[9]
  cntButtons.i
  cntCueMarkersUsage.i
  cntCuePoints.i
  cntDMXStarts.i
  cntFadeTime.i
  cntTempoEtc.i
  cntScreens.i
  grdCueMarkersUsage.i
  grdCuePoints.i
  grdDMXStarts.i
  lblCPName.i
  lblCuePoints.i
  lblDMXChannels.i
  lblDMXComment.i
  lblDMXFadeTime.i
  lblDMXItem.i
  lblDMXValue.i
  lblDMXDevice.i
  lblDMXFixtures.i
  lblDMXFixturesHdg.i
  lblDMXStarts.i
  lblFadeField.i
  lblFadeType.i
  lblField.i
  lblScreens.i
  lblTempoEtcAction.i
  lblTempoEtcInfo.i
  lblTempoEtcValue.i
  sldTempoEtcValue.i
  txtDMXDevice.i
  txtFadeValue.i
  txtTempoEtcValue.i
  txtValue.i
EndStructure
Global WEM.strWEM ; fmEditModal

Procedure createfmEditModal(nParentWindow)
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight, nCntHeight, nFlags
  Protected n, nScreenNo
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nFlags = #PB_Window_SystemMenu | #PB_Window_Invisible | #PB_Window_SizeGadget
  If OpenWindow(#WEM, 0, 0, 348, 400, "", nFlags, WindowID(nParentWindow))
    ; NOTE: Window may be resized in WEM_Form_Show() based on the parameter nSourceField
    registerWindow(#WEM, "WEM(fmEditModal)")
    With WEM
      ; DMX start channels dev map
      \cntDMXStarts=scsContainerGadget(0,0,360,380,0,"cntDMXStarts")
        nTop = 8
        \lblDMXStarts=scsTextGadget(22,nTop,320,15,LangColon("WEM","lblDMXStarts"),0,"lblDMXStarts")
        nTop + 17
        \cboDMXStartsDevMap=scsComboBoxGadget(20,nTop,320,21,0,"cboDMXStartsDevMap")
        nTop + 25
        \lblDMXDevice=scsTextGadget(22,nTop+gnLblVOffsetS,80,15,grText\sTextDevice,0,"lblDMXDevice")
        setGadgetWidth(\lblDMXDevice,-1,#True)
        nLeft = gnNextX+gnGap
        nWidth = GadgetWidth(\cboDMXStartsDevMap) - (nLeft - GadgetX(\cboDMXStartsDevMap)) - 32
        \txtDMXDevice=scsStringGadget(nLeft,nTop,nWidth,21,"",0,"txtDMXDevice")
        setEnabled(\txtDMXDevice, #False)
        setTextBoxBackColor(\txtDMXDevice)
        nTop + 25
        \grdDMXStarts=scsListIconGadget(20,nTop,320,300,Lang("WEP","lblFixtures"),200,#PB_ListIcon_GridLines|#PB_ListIcon_FullRowSelect)
        AddGadgetColumn(\grdDMXStarts,1,Lang("WEP","lblDMXStartChannel"),110)
      scsCloseGadgetList()
      setVisible(\cntDMXStarts, #False)
      
      ; cue points
      \cntCuePoints=scsContainerGadget(0,0,348,368,0,"cntCuePoints")
        \lblField=scsTextGadget(2,8,60,15,"",#PB_Text_Right,"lblField")
        \txtValue=scsStringGadget(gnNextX+7,5,80,21,"",0,"txtValue")
        setValidChars(\txtValue, "0123456789.:")
        \lblCPName=scsTextGadget(gnNextX+7,7,200,15,"",0,"lblCPName")
        \lblCuePoints=scsTextGadget(8,28,100,15,Lang("WEM","lblCuePoints")+":",0,"lblCuePoints")
        \grdCuePoints=scsListIconGadget(2,44,332,295,Lang("Common","No."),30,#PB_ListIcon_FullRowSelect|#PB_ListIcon_AlwaysShowSelection,"grdCuePoints")
        AddGadgetColumn(\grdCuePoints,1,Lang("WEM","Position"),100)
        AddGadgetColumn(\grdCuePoints,2,Lang("WEM","Name"),190)
        nTop = 342
        \btnCuePointsReset=scsButtonGadget(8,nTop,60,gnBtnHeight,Lang("Btns","Reset"),0,"btnCuePointsReset")
        \btnCuePointsClear=scsButtonGadget(gnNextX+gnGap,nTop,114,gnBtnHeight,Lang("Btns","Clear"),0,"btnCuePointsClear")
        \btnCuePointsClearSelection=scsButtonGadget(gnNextX+gnGap,nTop,150,gnBtnHeight,Lang("WEM", "btnClearSelection"),0,"btnCuePointsClearSelection")
      scsCloseGadgetList()
      setVisible(\cntCuePoints, #False)
      
      ; fade type
      \cntFadeTime=scsContainerGadget(0,0,348,0,0,"cntFadeTime")
        nTop = 8
        \lblFadeField=scsTextGadget(2,nTop+gnLblVOffsetS,100,15,"",#PB_Text_Right,"lblFadeField")
        \txtFadeValue=scsStringGadget(gnNextX+gnGap,nTop,70,21,"",0,"txtFadeValue")
        setValidChars(\txtFadeValue, "0123456789.:")
        nTop + 23
        \lblFadeType=scsTextGadget(2,nTop+gnLblVOffsetC,100,15,"",#PB_Text_Right,"lblFadeType")
        \cboFadeType=scsComboBoxGadget(gnNextX+gnGap,nTop,180,21,0,"cboFadeType")
        nTop + 40
        nLeft = (GadgetWidth(\cntFadeTime) - (80 + gnGap + 60 + gnGap + 60)) >> 1
        \btnUseDefaults=scsButtonGadget(nLeft,nTop,80,gnBtnHeight,Lang("WEM","btnUseDefaults"),0,"btnUseDefaults")
        \btnFadeReset=scsButtonGadget(gnNextX+gnGap,nTop,60,gnBtnHeight,Lang("Btns","Reset"),0,"btnFadeReset")
        \btnFadeClear=scsButtonGadget(gnNextX+gnGap,nTop,60,gnBtnHeight,Lang("Btns","Clear"),0,"btnFadeClear")
        nCntHeight = nTop + gnBtnHeight + 8
        ResizeGadget(\cntFadeTime, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntHeight)
      scsCloseGadgetList()
      setVisible(\cntFadeTime, #False)
      
      ; output screens
      \cntScreens=scsContainerGadget(0,0,370,0,0,"cntScreens")
        \lblScreens=scsTextGadget(42,20,100,15,"",0,"lblScreens") ; populated dynamically
        nLeft = 70
        nTop = 40
        nWidth = 100
        nHeight = 17
        For n = 0 To (grLicInfo\nLastVideoWindowNo - #WV2)
          nScreenNo = n + 2
          \chkOutputScreen[n]=scsCheckBoxGadget(nLeft, nTop, nWidth, nHeight, "Screen "+nScreenNo,0,"chkOutputScreen["+n+"]")
          nTop + nHeight
        Next n
        nCntHeight = nTop + 8
        ResizeGadget(\cntScreens, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntHeight) ; width set dynamically in WEM_Form_Show()
      scsCloseGadgetList()
      setVisible(\cntScreens, #False)
      
      ; cue markers usage
      \cntCueMarkersUsage=scsContainerGadget(0,0,560+gl3DBorderAllowanceX,380,0,"cntCueMarkersUsage")
        \grdCueMarkersUsage=scsListIconGadget(0,0,GadgetWidth(\cntCueMarkersUsage),GadgetHeight(\cntCueMarkersUsage),
                                              Lang("WEM","Name"),75,#PB_ListIcon_GridLines|#PB_ListIcon_AlwaysShowSelection|#PB_ListIcon_FullRowSelect,"grdCueMarkersUsage")
        AddGadgetColumn(\grdCueMarkersUsage, 1, Lang("Common","Time"), 65)
        AddGadgetColumn(\grdCueMarkersUsage, 2, Lang("Common","Cue"), 80)
        AddGadgetColumn(\grdCueMarkersUsage, 3, Lang("Common","CueType"), 90)
        AddGadgetColumn(\grdCueMarkersUsage, 4, Lang("Common","FileInfo"), 250)
        autoFitGridCol(\grdCueMarkersUsage, 4) ; autofit "File Info" column
      scsCloseGadgetList()
      setVisible(\cntCueMarkersUsage, #False)
      
      ; frequency / tempo / pitch
      \cntTempoEtc=scsContainerGadget(0,0,540,0,#PB_Container_BorderLess,"cntTempoEtc")
        nLeft = 4
        nTop = 12
        \lblTempoEtcAction=scsTextGadget(nLeft,nTop+gnLblVOffsetC,130,15,Lang("WQL","lblLCAction"),#PB_Text_Right,"lblTempoEtcAction")
        \cboTempoEtcAction=scsComboBoxGadget(gnNextX+gnGap,nTop,95,21,0,"cboTempoEtcAction")
        nTop + 29
        \lblTempoEtcValue=scsTextGadget(nLeft,nTop+gnLblVOffsetS,130,30,"",#PB_Text_Right,"lblTempoEtcValue")
        \sldTempoEtcValue=SLD_New("WEM_Tempo",\cntTempoEtc,0,gnNextX+gnGap,nTop,140,21,#SCS_ST_TEMPO) ; max, min, etc will be dynamically changed for Freq, Tempo or Pitch
        \txtTempoEtcValue=scsStringGadget(gnNextX,nTop,40,21,"",0,"txtTempoEtcValue")
        \lblTempoEtcInfo=scsTextGadget(gnNextX+gnGap,nTop+gnLblVOffsetS,200,15,"",0,"lblTempoEtcInfo")
        setGadgetWidth(\lblTempoEtcInfo)
        nLeft = GadgetX(\cboTempoEtcAction)
        nTop + 28
        \btnTempoEtcReset=scsButtonGadget(nLeft,nTop,120,gnBtnHeight,Lang("Btns","btnTempoEtcReset"),0,"btnTempoEtcReset")
        setGadgetWidth(\btnTempoEtcReset)
        nCntHeight = nTop + gnBtnHeight + 8
        ResizeGadget(\cntTempoEtc, #PB_Ignore, #PB_Ignore, #PB_Ignore, nCntHeight)
      scsCloseGadgetList()
      setVisible(\cntTempoEtc, #False)

      \cntButtons=scsContainerGadget(83,370,162+gnGap,gnBtnHeight,#PB_Container_BorderLess,"cntButtons")
        \btnOK=scsButtonGadget(0,0,81,gnBtnHeight,grText\sTextBtnOK,#PB_Button_Default,"btnOK")
        \btnCancel=scsButtonGadget(gnNextX+gnGap,0,81,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      scsCloseGadgetList()
      
      AddKeyboardShortcut(#WEM, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WEM, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
    EndWith
    setWindowEnabled(#WEM,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWUP ; fmCheckForUpdate
  btnClose.i
  cntDownloadInfo.i
  cntUpdateInfo.i
  lblUpdateStatus.i
  lblCurVersion.i
  lblCurVersionHdg.i
  lblDownloadLink.i
  lblDownloadMsg.i
  lblUpdVersion.i
  lblUpdVersionHdg.i
EndStructure
Global WUP.strWUP ; fmCheckForUpdate

Procedure createfmCheckForUpdate()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth
  Protected sText.s
  
  If IsWindow(#WUP)
    ; already created
    ProcedureReturn
  EndIf
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  With WUP
    If scsOpenWindow(#WUP, 0, 0, 382, 260, Lang("WUP","Window"), #PB_Window_SystemMenu|#PB_Window_WindowCentered | #PB_Window_Invisible, #WMN)
      registerWindow(#WUP, "WUP(fmCheckForUpdate)")
      
      nLeft = 12
      nTop = 12
      nWidth = WindowWidth(#WUP) - nLeft - nLeft
      \lblUpdateStatus=scsTextGadget(nLeft,nTop,nWidth,15,"",0,"lblUpdateStatus")
      scsSetGadgetFont(\lblUpdateStatus,#SCS_FONT_GEN_BOLD)
      
      nTop + 30
      \cntUpdateInfo=scsContainerGadget(nLeft,nTop,nWidth,46,0,"cntUpdateInfo")
        \lblCurVersionHdg=scsTextGadget(0,0,100,15,LangColon("WUP","lblCurVersionHdg"),0,"lblCurVersionHdg")
        \lblCurVersion=scsTextGadget(100,0,50,15,"",0,"lblCurVersion")
        \lblUpdVersionHdg=scsTextGadget(0,17,100,15,LangColon("WUP","lblUpdVersionHdg"),0,"lblUpdVersionHdg")
        \lblUpdVersion=scsTextGadget(100,17,50,15,"",0,"lblUpdVersion")
      scsCloseGadgetList()
      
      nTop + GadgetHeight(\cntUpdateInfo)
      \cntDownloadInfo=scsContainerGadget(nLeft,nTop,nWidth,122,0,"cntDownloadInfo")
        \lblDownloadMsg=scsTextGadget(0,0,nWidth,90,"",0,"lblDownloadMsg")
        sText = Lang("WUP","lblDownloadLink")
        \lblDownloadLink=scsHyperLinkGadget(30,96,200,20,sText, #SCS_Blue, #PB_HyperLink_Underline, "lblDownloadLink")
        SetGadgetColor(\lblDownloadLink, #PB_Gadget_FrontColor, #SCS_Blue)
        nWidth = calcTextWidth(#WUP, \lblDownloadLink, sText)
        nLeft = (GadgetWidth(\cntUpdateInfo) - nWidth) >> 1
        ResizeGadget(\lblDownloadLink,nLeft,#PB_Ignore,#PB_Ignore,#PB_Ignore)
      scsCloseGadgetList()
      
      nWidth = 84
      nLeft = (WindowWidth(#WUP) - nWidth) >> 1
      \btnClose=scsButtonGadget(nLeft,225,nWidth,gnBtnHeight,Lang("Btns","Close"),#PB_Button_Default,"btnClose")
      
      AddKeyboardShortcut(#WUP, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
      AddKeyboardShortcut(#WUP, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      
      ; setWindowVisible(#WUP,#True)
      setWindowEnabled(#WUP,#True)
    EndIf
  EndWith
EndProcedure


Structure tyVideoCanvas
  cvsCanvas.i
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
EndStructure

Structure strWVN ; fmVideo
  sWVNo.s
  cntMainPicture.i
  cvsDragBar.i
  imgMainPicture.i
  imgMainBlack.i
  imgMainBlended.i
  rchMemo.i
  rchMemoObject.RichEdit
  Array aVideo.tyVideoCanvas(0)
  nMaxVideoIndex.i
EndStructure
Global Dim WVN.strWVN(0)  ; dimensioned in setVidPicTargets()

Procedure createfmVideo(nWindowNo, nUseLeft=0, nUseTop=0, nUseWidth=0, nUseHeight=0, nWinLeft=0, nWinTop=0, nWinWidth=0, nWinHeight=0)
  PROCNAME(#PB_Compiler_Procedure + "[" + decodeWindow(nWindowNo) + "]")
  Protected nIndex, sWVNo.s, nFlags, sFlags.s
  Protected nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, nDragBarHeight
  Protected n
  Protected nVidPicTarget
  Protected nLeft, nTop, nWidth, nHeight
  Protected nCntLeft, nCntTop
  Protected nWinBackColor = #SCS_Black, nCntBackColor = #SCS_Black
  
  debugMsg(sProcName, #SCS_START + ", nUseLeft=" + nUseLeft + ", nUseTop=" + nUseTop + ", nUseWidth=" + nUseWidth + ", nUseHeight=" + nUseHeight +
                      ", nWinLeft=" + nWinLeft + ", nWinTop=" + nWinTop + ", nWinWidth=" + nWinWidth + ", nWinHeight=" + nWinHeight)
  
  ; INFO TEST START !!!!!!!!!!!!!!!!!!!!!
  CompilerIf 1=2
    Select nWindowNo
      Case #WV2
        nWinBackColor = #SCS_Red
        nCntBackColor = RGB(128,0,0)
      Case #WV3
        nWinBackColor = #SCS_Green
        nCntBackColor = RGB(0,128,0)
      Case #WV4
        nWinBackColor = #SCS_Blue
        nCntBackColor = RGB(0,0,128)
      Case #WV5
        nWinBackColor = #SCS_Yellow
        nCntBackColor = #SCS_Light_Yellow
    EndSelect
  CompilerEndIf
  ; INFO TEST END !!!!!!!!!!!!!!!!!!!!!
  
  If nUseWidth = 0
    nWidth = 320
    nHeight = 240
  Else
    nLeft = nUseLeft
    nTop = nUseTop
    nWidth = nUseWidth
    nHeight = nUseHeight
  EndIf

  nIndex = getIndexForVideoWindowNo(nWindowNo)
  nVidPicTarget = #SCS_VID_PIC_TARGET_F2 + nIndex
  sWVNo = Str(nIndex + 2)
  
  If IsWindow(nWindowNo) = #False
    
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    If nWinLeft = 0 Or gbVideosOnMainWindow Or nWidth < nWinWidth Or nHeight < nWinHeight
      nWindowLeft = nLeft
      nWindowTop = nTop
      nWindowWidth = nWidth
      nWindowHeight = nHeight
      nFlags = #PB_Window_BorderLess | #PB_Window_Invisible
      sFlags = "#PB_Window_BorderLess | #PB_Window_Invisible"
    Else
      nWindowLeft = nWinLeft
      nWindowTop = nWinTop
      nWindowWidth = nWinWidth
      nWindowHeight = nWinHeight
      nFlags = #PB_Window_BorderLess | #PB_Window_Maximize | #PB_Window_Invisible
      sFlags = "#PB_Window_BorderLess | #PB_Window_Maximize | #PB_Window_Invisible"
    EndIf
    If gbVideosOnMainWindow
      debugMsg(sProcName, "gbVideosOnMainWindow=" + strB(gbVideosOnMainWindow))
      nDragBarHeight = 15
      nWindowHeight + nDragBarHeight
    EndIf
    
    debugMsg(sProcName, "calling OpenWindow(" + nWindowNo + ", " + nWindowLeft + ", " + nWindowTop + ", " + nWindowWidth + ", " + nWindowHeight + ", " + #DQUOTE$ + #DQUOTE$ + ", " + sFlags + ", WindowID(#WMN)")
    If OpenWindow(nWindowNo, nWindowLeft, nWindowTop, nWindowWidth, nWindowHeight, "", nFlags, WindowID(#WMN))
      debugMsg(sProcName, "WindowX(" + nWindowNo + ")=" + WindowX(nWindowNo) + ", WindowY()=" + WindowY(nWindowNo) + ", WindowWidth()=" + WindowWidth(nWindowNo) + ", WindowHeight()=" + WindowHeight(nWindowNo))
      registerWindow(nWindowNo, "WV" + sWVNo + "(fmVideo" + sWVNo + ")")
      SetWindowColor(nWindowNo, nWinBackColor)
      With WVN(nIndex)
        \sWVNo = sWVNo
        If gbVideosOnMainWindow
          ; drag bar (only used if window displayed on main window)
          \cvsDragBar=scsCanvasGadget(0,0,nWidth,nDragBarHeight,0,"cvsDragBar")
          If StartDrawing(CanvasOutput(\cvsDragBar))
            Box(0,0,OutputWidth(),OutputHeight(),nWinBackColor)
            StopDrawing()
          EndIf
        EndIf
        ; picture and video container
        nCntLeft = nLeft - nWindowLeft
        nCntTop = nTop - nWindowTop + nDragBarHeight
        debugMsg(sProcName, "nLeft=" + nLeft + ", nWindowLeft=" + nWindowLeft + ", nCntLeft=" + nCntLeft + ", nTop=" + nTop + ", nWindowTop=" + nWindowTop + ", nCntTop=" + nCntTop)
        \cntMainPicture=scsContainerGadget(nCntLeft,nCntTop,nWidth,nHeight,0,"cntMainPicture")
          SetGadgetColor(\cntMainPicture,#PB_Gadget_BackColor,nCntBackColor)
          \imgMainPicture=scsCreateImage(nWidth,nHeight)
          logCreateImage(40, \imgMainPicture, -1, nVidPicTarget, "for main picture", "V"+sWVNo+".main") ; nb use "V" as "v" is used in the 'Device' column of the main window's cue list
          \imgMainBlack=scsCreateImage(nWidth,nHeight)
          logCreateImage(41, \imgMainBlack, -1, nVidPicTarget, "for main black", "V"+sWVNo+".black")
          \imgMainBlended=scsCreateImage(nWidth,nHeight)
          logCreateImage(42, \imgMainBlended, -1, nVidPicTarget, "for main blended", "V"+sWVNo+".blended")
          
          \aVideo(0)\cvsCanvas=scsCanvasGadget(0,0,nWidth,nHeight,0,"aVideo(0)\cvsCanvas")
          ; debugMsg(sProcName, "WV" + sWVNo + " \aVideo(0)\cvsCanvas=G" + \aVideo(0)\cvsCanvas)
          setGadgetNoForEvHdlr(\aVideo(0)\cvsCanvas, \aVideo(0)\cvsCanvas)
          \aVideo(0)\nLeft = 0
          \aVideo(0)\nTop = 0
          \aVideo(0)\nWidth = nWidth
          \aVideo(0)\nHeight = nHeight
          If StartDrawing(CanvasOutput(\aVideo(0)\cvsCanvas))
            Box(0,0,OutputWidth(),OutputHeight(),nCntBackColor)
            StopDrawing()
          EndIf
          \nMaxVideoIndex = 0
          setVisible(\aVideo(0)\cvsCanvas, #False)
          
          ; memo gadget
          \rchMemoObject = New_RichEdit(0, 0, nWidth, nHeight)
          \rchMemoObject\SetInterface()
          \rchMemoObject\SetReadonly(#True)
          \rchMemo = \rchMemoObject\GetID()
          HideGadget(\rchMemo, #True)
          
        scsCloseGadgetList()
        
      EndWith
      SmartWindowRefresh(nWindowNo, #True)
      If (gbVideosOnMainWindow = #False)
        setWindowEnabled(nWindowNo, #False) ; fmVideo not to be enabled unless on main window, where it needs to be enabled so it can be dragged
      Else
        setWindowEnabled(nWindowNo, #True) ; fmVideo not to be enabled unless on main window, where it needs to be enabled so it can be dragged
      EndIf
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure getVideoCanvas(nWindowNo, nLeft, nTop, nWidth, nHeight)
  PROCNAMEC()
  ; note: specifically-sized video canvases are only required for videos played using xVideo_SetMixingWindow().
  ; this is because none of the xVideo resize functions seem to work correctly for the Mixing Window, so always setting
  ; the mixing window to the required position and size (including aspect ratio) achieves the required result.
  Protected nCanvasNo
  Protected nIndex
  Protected n
  Protected nOldGadgetList
  
  ; debugMsg(sProcName, #SCS_START + ", nWindowNo=" + decodeWindow(nWindowNo) + ", nLeft=" + nLeft + ", nTop=" + nTop + ", nWidth=" + nWidth + ", nHeight=" + nHeight)
  
  If IsWindow(nWindowNo)
    nIndex = getIndexForVideoWindowNo(nWindowNo)
    ; debugMsg(sProcName, "nIndex=" + nIndex)
    If nIndex >= 0
      With WVN(nIndex)
        If IsGadget(\cntMainPicture)
          For n = 0 To \nMaxVideoIndex
            If (\aVideo(n)\nWidth = nWidth) And (\aVideo(n)\nHeight = nHeight)
              If (\aVideo(n)\nLeft = nLeft) And (\aVideo(n)\nTop = nTop)
                nCanvasNo = \aVideo(n)\cvsCanvas
                Break
              EndIf
            EndIf
          Next n
          ; debugMsg(sProcName, "nCanvasNo=" + nCanvasNo)
          If IsGadget(nCanvasNo) = #False
            \nMaxVideoIndex + 1
            ReDim \aVideo(\nMaxVideoIndex)
            n = \nMaxVideoIndex
            nOldGadgetList = UseGadgetList(GadgetID(\cntMainPicture))
            nCanvasNo = scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0, "aVideo(" + n + ")\cvsCanvas", \aVideo(0)\cvsCanvas)
            ; debugMsg(sProcName, "nCanvasNo=" + nCanvasNo)
            If IsGadget(nCanvasNo)
              \aVideo(n)\cvsCanvas = nCanvasNo
              \aVideo(n)\nLeft = nLeft
              \aVideo(n)\nTop = nTop
              \aVideo(n)\nWidth = nWidth
              \aVideo(n)\nHeight = nHeight
              If StartDrawing(CanvasOutput(nCanvasNo))
                  Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                StopDrawing()
              EndIf
              setVisible(nCanvasNo, #False)
            EndIf
            UseGadgetList(nOldGadgetList)
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  ProcedureReturn nCanvasNo
EndProcedure

Structure tyMonitorCanvas
  cvsMonitorCanvas.i
  nLeft.i
  nTop.i
  nWidth.i
  nHeight.i
EndStructure

Structure strWMO ; fmMonitor
  sWMO.s
  cntMonitor.i
  cvsMonitorDragBar.i
  Array aMonitor.tyMonitorCanvas(0) ; potentially different canvases will be created to match different required video/image sizes (width and height)
  nMaxMonitorIndex.i
EndStructure
Global Dim WMO.strWMO(0)  ; dimensioned in setVidPicTargets()

Procedure createfmMonitor(nWindowNo)
  PROCNAMECW(nWindowNo)
  Protected n
  Protected nIndex, sWMO.s
  Protected nWindowHeight, nDragBarHeight
  Protected nMonitorWidth, nMonitorHeight
  Protected nTextHeight
  
  nIndex = getIndexForMonitorWindowNo(nWindowNo)
  sWMO = Str(nIndex + 2)
  
  If IsWindow(nWindowNo) = #False
    scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
    nDragBarHeight = 15     ; fixed
    nTextHeight = GetTextHeight("2", #SCS_FONT_GEN_NORMAL)
    If nTextHeight > nDragBarHeight
      nDragBarHeight = nTextHeight
    EndIf
    nMonitorWidth = 320     ; may be changed in positionVideoMonitorsOrWindows()
    nMonitorHeight = 180    ; may be changed in positionVideoMonitorsOrWindows()
    nWindowHeight = nMonitorHeight + nDragBarHeight
    debugMsg(sProcName, "nDragBarHeight=" + nDragBarHeight + ", nMonitorWidth=" + nMonitorWidth + ", nMonitorHeight=" + nMonitorHeight + ", nWindowHeight=" + nWindowHeight)
    If OpenWindow(nWindowNo, 0, 0, nMonitorWidth, nWindowHeight, "", #PB_Window_BorderLess | #PB_Window_Invisible, WindowID(#WMN))
      registerWindow(nWindowNo, "WM" + sWMO + "(fmMonitor" + sWMO + ")")
      SetWindowColor(nWindowNo, #SCS_Black)
      With WMO(nIndex)
        \sWMO = sWMO
        \cvsMonitorDragBar=scsCanvasGadget(0,0,nMonitorWidth,nDragBarHeight,0,"cvsMonitorDragBar")
        \cntMonitor=scsContainerGadget(0,nDragBarHeight,nMonitorWidth,nMonitorHeight,0,"cntMonitor")
          SetGadgetColor(\cntMonitor,#PB_Gadget_BackColor,#SCS_Black)
          \aMonitor(0)\cvsMonitorCanvas=scsCanvasGadget(0,0,nMonitorWidth,nMonitorHeight,0,"aMonitor(0)\cvsMonitorCanvas")
          debugMsg(sProcName, "WM" + sWMO + " \aMonitor(0)\cvsMonitorCanvas=G" + \aMonitor(0)\cvsMonitorCanvas)
          setGadgetNoForEvHdlr(\aMonitor(0)\cvsMonitorCanvas, \aMonitor(0)\cvsMonitorCanvas)
          \aMonitor(0)\nLeft = 0
          \aMonitor(0)\nTop = 0
          \aMonitor(0)\nWidth = nMonitorWidth
          \aMonitor(0)\nHeight = nMonitorHeight
          If StartDrawing(CanvasOutput(\aMonitor(0)\cvsMonitorCanvas))
            Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
            StopDrawing()
          EndIf
          setVisible(\aMonitor(0)\cvsMonitorCanvas, #False)
          \nMaxMonitorIndex = 0
        scsCloseGadgetList()
      EndWith
      SmartWindowRefresh(nWindowNo, #True)
      setWindowVisible(nWindowNo, #False) ; fmMonitor initially remains hidden
      debugMsg3(sProcName, "WindowX=" + WindowX(nWindowNo) + ", WindowY=" + WindowY(nWindowNo) + ", WindowWidth=" + WindowWidth(nWindowNo) + ", WindowHeight=" + WindowHeight(nWindowNo))
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  Else
    ProcedureReturn #True
  EndIf
EndProcedure

Procedure getMonitorCanvas(nWindowNo, nLeft, nTop, nWidth, nHeight)
  PROCNAMEC()
  Protected nCanvasNo
  Protected nIndex
  Protected n
  Protected nOldGadgetList
  
  debugMsg(sProcName, #SCS_START + ", nWindowNo=" + decodeWindow(nWindowNo) + ", nLeft=" + nLeft + ", nTop=" + nTop + ", nWidth=" + nWidth + ", nHeight=" + nHeight)
  
  If IsWindow(nWindowNo)
    nIndex = getIndexForMonitorWindowNo(nWindowNo)
    debugMsg(sProcName, "nIndex=" + nIndex)
    If nIndex >= 0
      With WMO(nIndex)
        If IsGadget(\cntMonitor)
          For n = 0 To \nMaxMonitorIndex
            ; debugMsg(sProcName, "\aMonitor(" + n + ")\nLeft=" + \aMonitor(n)\nLeft + ", \nTop=" + \aMonitor(n)\nTop +
            ;                     ", \nWidth=" + \aMonitor(n)\nWidth + ", \nHeight=" + \aMonitor(n)\nHeight)
            If (\aMonitor(n)\nWidth = nWidth) And (\aMonitor(n)\nHeight = nHeight)
              If (\aMonitor(n)\nLeft = nLeft) And (\aMonitor(n)\nTop = nTop)
                nCanvasNo = \aMonitor(n)\cvsMonitorCanvas
                Break
              EndIf
            EndIf
          Next n
          debugMsg(sProcName, "nCanvasNo=" + nCanvasNo)
          If IsGadget(nCanvasNo) = #False
            \nMaxMonitorIndex + 1
            ReDim \aMonitor(\nMaxMonitorIndex)
            n = \nMaxMonitorIndex
            setCurrWindowGlobals(nWindowNo)
            nOldGadgetList = UseGadgetList(GadgetID(\cntMonitor))
            nCanvasNo = scsCanvasGadget(nLeft, nTop, nWidth, nHeight, 0, "aMonitor(" + n + ")\cvsMonitorCanvas", \aMonitor(0)\cvsMonitorCanvas)
            ; debugMsg(sProcName, "nCanvasNo=" + nCanvasNo)
            If IsGadget(nCanvasNo)
              \aMonitor(n)\cvsMonitorCanvas = nCanvasNo
              \aMonitor(n)\nLeft = nLeft
              \aMonitor(n)\nTop = nTop
              \aMonitor(n)\nWidth = nWidth
              \aMonitor(n)\nHeight = nHeight
              If StartDrawing(CanvasOutput(nCanvasNo))
                Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
                StopDrawing()
              EndIf
              setVisible(nCanvasNo, #False)
            EndIf
            UseGadgetList(nOldGadgetList)
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  ProcedureReturn nCanvasNo
EndProcedure

Structure strWOC ; fmOSCCapture
  btnCancel.i
  btnClearAll.i
  btnHelp.i
  btnIncludeAll.i
  btnIncludeNamed.i
  btnOK.i
  cboCtrlNetworkRemoteDev.i
  cboLogicalDev.i
  cboOSCCmdType.i
  grdOSCCapture.i
  lblCtrlNetworkRemoteDev.i
  lblLogicalDev.i
  lblOSCCmdType.i
  lblSubCueInfo.i
  lnSubCueInfo.i
EndStructure
Global WOC.strWOC ; fmOSCCapture

Procedure createfmOSCCapture()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight
  Protected nLblWidth, nCboWidth
  Protected nBtnTop, nBtnWidth, nGap
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WOC, 0, 0, 650, 433, Lang("WOC","Window"), #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible, WindowID(#WED))
    registerWindow(#WOC, "WOC(fmOSCCapture)")
    With WOC
      
      nLeft = 4
      nTop = 8
      nLblWidth = 110
      nCboWidth = 150
      nWidth = 275
      \lblSubCueInfo=scsTextGadget(nLeft,nTop,nWidth,21,"",#PB_Text_Center,"lblSubCueInfo")
      scsSetGadgetFont(\lblSubCueInfo, #SCS_FONT_GEN_BOLD10)
      nTop + 25
      \lnSubCueInfo=scsLineGadget(nLeft,nTop,nWidth,1,#SCS_Grey,0,"lnSubCueInfo")
      nTop + 40
      \lblLogicalDev=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nLblWidth,17,Lang("WQM","lblLogicalDev"),#PB_Text_Right,"lblLogicalDev")
      \cboLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,nCboWidth,21,0,"cboLogicalDev")
      setEnabled(\cboLogicalDev, #False)
      nTop + 23
      \lblCtrlNetworkRemoteDev=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nLblWidth,17,Lang("WQM","RemoteDev"),#PB_Text_Right,"RemoteDev")
      \cboCtrlNetworkRemoteDev=scsComboBoxGadget(gnNextX+gnGap,nTop,nCboWidth,21,0,"cboCtrlNetworkRemoteDev")
      setEnabled(\cboCtrlNetworkRemoteDev,#False)
      nTop + 23
      \lblOSCCmdType=scsTextGadget(nLeft,nTop+gnLblVOffsetS,nLblWidth,17,Lang("WQM","lblOSCCmdType"), #PB_Text_Right,"lblOSCCmdType")
      \cboOSCCmdType=scsComboBoxGadget(gnNextX+gnGap,nTop,nCboWidth,21,0,"cboOSCCmdType")
      
      nLeft = GadgetX(\lnSubCueInfo) + GadgetWidth(\lnSubCueInfo) + gnGap2
      nTop = 16
      \btnIncludeNamed=scsButtonGadget(nLeft+4,nTop,81,gnBtnHeight,Lang("Btns","IncludeNamed"),0,"btnIncludeNamed")
      \btnIncludeAll=scsButtonGadget(gnNextX+6,nTop,81,gnBtnHeight,Lang("Btns","IncludeAll"),0,"btnIncludeAll")
      \btnClearAll=scsButtonGadget(gnNextX+6,nTop,81,gnBtnHeight,Lang("Btns","ClearAll"),0,"btnClearAll")
      nTop + gnBtnHeight + 4
      nBtnTop = WindowHeight(#WOC) - gnBtnHeight - 8
      ; OSC capture grid
      nWidth = WindowWidth(#WOC) - nLeft - gnGap2
      nHeight = nBtnTop - nTop - 8
      \grdOSCCapture=scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("Common", "Include"),75,#PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdOSCCapture")
      grWOC\nMaxColNo = 0
      
      ; dialog buttons
      nGap = 12
      nBtnWidth = 81
      nLeft = (WindowWidth(#WOC) - (nBtnWidth * 3) - (nGap * 2)) >> 1
      \btnOK=scsButtonGadget(nLeft,nBtnTop,nBtnWidth,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nBtnTop,nBtnWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
      \btnHelp=scsButtonGadget(gnNextX+nGap,nBtnTop,nBtnWidth,gnBtnHeight,grText\sTextBtnHelp,0,"btnHelp")
      
    EndWith
    setWindowVisible(#WOC,#True)
    setWindowEnabled(#WOC,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; fmVSTPlugins
Structure strWVPDevVSTPlugin
  cboDevVSTPlugin.i
  chkDevBypassVST.i
  chkDevViewVST.i
  lblDevVSTOrder.i
  txtDevVSTComment.i
EndStructure

Structure strWVP
  ; ---- common controls
  btnApplyVSTChgs.i
  btnClose.i
  btnHelp.i
  btnUndoVSTChgs.i
  pnlVSTPlugins.i
  ; ---- 'VST Plugins' (libary) tab
  btnLibVSTPluginLoad.i[8];[#SCS_PROD_TAB_INDEX_LAST+1]
  cntLibSideBar.i
  cntLibVSTInfo.i
  cntLibVSTPlugins.i
  imgLibButtonTBS.i[4]
  lblLibVSTNo.i[#SCS_MAX_VST_LIB_PLUGIN+1]
  lblLibVSTPluginLoad.i
  lblLibVSTPluginLocation.i
  lblLibVSTPluginName.i
  lnLibVSTPluginLineSep.i
  txtLibVSTPluginFile.i[#SCS_MAX_VST_LIB_PLUGIN+1]
  txtLibVSTPluginName.i[#SCS_MAX_VST_LIB_PLUGIN+1]
  ; ---- 'Device Plugins' tab
  Array aDevVSTPlugin.strWVPDevVSTPlugin(#SCS_MAX_VST_DEV_PLUGIN)
  cboDevLogicalDev.i
  cntDevSidebar.i
  cntDevVSTPlugins.i
  imgDevButtonTBS.i[2]
  lblDevDevice.i
  lblDevVSTBypass.i
  lblDevVSTComment.i
  lblDevVSTOrder.i
  lblDevVSTPlugin.i
  lblDevVSTView.i
  lnDevDeviceLineSep.i
  ; ---- 'Cue Plugins' tab
  btnCueOpen.i
  chkOnlyCuesWithAPlugin.i
  cntCueVSTPlugins.i
  grdCueVSTPlugins.i
  lblCueVSTPlugins.i
EndStructure
Global WVP.strWVP ; fmVSTPlugins

Procedure createfmVSTPlugins()
  PROCNAMEC()
  Protected nLeft, nTop, nWidth, nHeight
  Protected nPanelItemLeft, nPanelItemTop, nPanelItemWidth, nPanelItemHeight
  Protected nSideBarLeft, nSideBarWidth
  Protected nTextWidth, nOrderWidth
  Protected n, sNr.s
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  If OpenWindow(#WVP, 0, 0, 650, 320, Lang("WVP","Window"), #PB_Window_SystemMenu | #PB_Window_Invisible, WindowID(#WMN))
    registerWindow(#WVP, "WVP(fmVSTPlugins)")
    With WVP
      nLeft = 8
      nTop = 4
      nHeight = WindowHeight(#WVP) - nTop - 41
      nWidth = WindowWidth(#WVP) - (nLeft * 2)
      nSideBarLeft = 2
      nSideBarWidth = 24
      \pnlVSTPlugins=scsPanelGadget(nLeft, nTop, nWidth, nHeight, "pnlVSTPlugins")
        ;- 'VST Plugins' (library) tab
        ; the 'library' tab will contain a list of VST plugins that the user has selected for use in this production
        addGadgetItemWithData(\pnlVSTPlugins, Lang("VST","VSTPlugins"), #SCS_WVP_TAB_LIBRARY)
        nPanelItemLeft = 0
        nPanelItemTop = 0
        nPanelItemWidth = GetGadgetAttribute(\pnlVSTPlugins, #PB_Panel_ItemWidth) ; GetGadgetAttribute(\pnlVSTPlugins, #PB_Panel_Item...) requires at least one item
        nPanelItemHeight = GetGadgetAttribute(\pnlVSTPlugins, #PB_Panel_ItemHeight)
        \cntLibVSTPlugins=scsContainerGadget(nPanelItemLeft,nPanelItemTop,nPanelItemWidth,nPanelItemHeight,#PB_Container_Flat,"cntLibVSTPlugins")
          \cntLibSideBar=scsContainerGadget(nSideBarLeft,0,nSideBarWidth,88,0,"cntLibSideBar") ; nb 'Y' will be reset further down this procedure - see ResizeGadget(\cntVSTSideBar,...)
            \imgLibButtonTBS[0]=scsStandardButton(2,0,20,20,#SCS_STANDARD_BTN_MOVE_UP,"imgLibButtonTBS[0]",#True)
            \imgLibButtonTBS[1]=scsStandardButton(2,22,20,20,#SCS_STANDARD_BTN_MOVE_DOWN,"imgLibButtonTBS[1]",#True)
            \imgLibButtonTBS[2]=scsStandardButton(2,44,20,20,#SCS_STANDARD_BTN_PLUS,"imgLibButtonTBS[2]",#True)
            \imgLibButtonTBS[3]=scsStandardButton(2,66,20,20,#SCS_STANDARD_BTN_MINUS,"imgLibButtonTBS[3]",#True)
          scsCloseGadgetList()
          
          ; VST plugin files (ie file locations)
          nLeft = nSideBarLeft + nSideBarWidth + 26
          \cntLibVSTInfo=scsContainerGadget(nLeft,4,400,GadgetHeight(\cntLibVSTPlugins),#PB_Container_Flat,"cntLibVSTInfo")
            SetGadgetColor(\cntLibVSTInfo,#PB_Gadget_BackColor,#SCS_Phys_BackColor)
            nLeft = 10
            nTop = 8
            \lblLibVSTPluginLocation=scsTextGadget(nLeft+2,nTop,300,15,LangPars("VST","lblLibVSTPluginLocation",gsProcBits),0,"lblLibVSTPluginLocation")
            setAllowEditorColors(\lblLibVSTPluginLocation,#False)
            SetGadgetColor(\lblLibVSTPluginLocation,#PB_Gadget_BackColor,#SCS_Phys_BackColor)
            setGadgetWidth(\lblLibVSTPluginLocation)
            nTop + GadgetHeight(\lblLibVSTPluginLocation) + 8
            ResizeGadget(\cntLibSideBar,#PB_Ignore,(GadgetY(\cntLibVSTInfo)+nTop+4),#PB_Ignore,#PB_Ignore)
            nWidth = GadgetWidth(\cntLibVSTInfo) - 31 ; 31 = width of button (20) + (left position (4) * 2 (for right padding)) + gap between text and button (1) + (2 * width of container border (1))
            For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
              \txtLibVSTPluginFile[n]=scsStringGadget(4,nTop,nWidth,21,"",#PB_String_ReadOnly,"txtLibVSTPluginFile["+n+"]")
              \btnLibVSTPluginLoad[n]=scsButtonGadget(gnNextX+1,nTop+1,20,20,"...",0,"btnLibVSTPluginLoad["+n+"]")
              scsToolTip(\btnLibVSTPluginLoad[n],Lang("VST","btnLibVSTPluginLoadTT"))
              nTop + 24
            Next n
            nHeight = nTop + 8
            ResizeGadget(\cntLibVSTInfo, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
          scsCloseGadgetList() ; cntLibVSTInfo
          
          ; VST numbers
          nLeft = nSideBarLeft + nSideBarWidth + 2
          nTop = GadgetY(\cntLibVSTInfo) + GadgetY(\txtLibVSTPluginFile[0]) + 1
          For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
            ; nb using a StringGadget rather than a TextGadget for \lblLibVSTNo[n] so we receive an event when the user clicks on the gadget
            \lblLibVSTNo[n]=scsStringGadget(nLeft,nTop+1,19,19,Str(n+1),#PB_String_ReadOnly|#ES_CENTER,"lblLibVSTNo["+n+"]",#SCS_G4EH_VP_LBLLIBVSTNO)
            SetGadgetColor(\lblLibVSTNo[n], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
            SetGadgetColor(\lblLibVSTNo[n], #PB_Gadget_FrontColor, #SCS_Black)
            nTop + 24
          Next n
          
          ; VST plugin names
          nLeft = GadgetX(\cntLibVSTInfo) + GadgetWidth(\cntLibVSTInfo) + 4
          nTop = GadgetY(\cntLibVSTInfo) + GadgetY(\lblLibVSTPluginLocation) + 1
          nWidth = GadgetWidth(\cntLibVSTPlugins) - nLeft - 8
          nHeight = 21
          \lblLibVSTPluginName=scsTextGadget(nLeft+2,nTop,nWidth,15,Lang("WVP","lblLibVSTPluginName"),0,"lblLibVSTPluginName")
          nTop = GadgetY(\cntLibVSTInfo) + GadgetY(\txtLibVSTPluginFile[0]) + 1
          For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
            \txtLibVSTPluginName[n]=scsStringGadget(nLeft, nTop, nWidth, nHeight, "",0,"txtLibVSTPluginName["+n+"]",#SCS_G4EH_VP_TXTLIBVSTPLUGINNAME)
            scsToolTip(\txtLibVSTPluginName[n], Lang("WVP","txtLibVSTPluginNameTT"))
            nTop + 24
          Next n
          
        scsCloseGadgetList() ; cntLibVSTPlugins
        
        ;- 'Device Plugins' tab
        ; audio output device VST plugin gadgets
        addGadgetItemWithData(\pnlVSTPlugins, Lang("WVP","DevPlugins"), #SCS_WVP_TAB_DEV_PLUGINS)
        \cntDevVSTPlugins=scsContainerGadget(nPanelItemLeft,nPanelItemTop,nPanelItemWidth,nPanelItemHeight,#PB_Container_Flat,"cntDevVSTPlugins")
          nTop = 8
          \lblDevDevice=scsTextGadget(24,nTop+gnLblVOffsetS,120,15,Lang("WVP","lblDevDevice"),#PB_Text_Right,"lblDevDevice")
          setGadgetWidth(\lblDevDevice,120,#True)
          \cboDevLogicalDev=scsComboBoxGadget(gnNextX+gnGap,nTop,120,21,0,"cboDevLogicalDev")
          nTop + GadgetHeight(\cboDevLogicalDev) + 8
          \lnDevDeviceLineSep=scsLineGadget(0,nTop,GadgetWidth(\cntDevVSTPlugins),1,#SCS_Light_Grey,0,"lnDevDeviceLineSep")
          nTop + 12
          nSideBarLeft = 8
          nLeft = nSideBarLeft + nSideBarWidth
          nOrderWidth = 22 ; width to be used for \aDevVSTPlugin(n)\lblVSTOrder
          \lblDevVSTOrder=scsTextGadget(nLeft,nTop,100,17,Lang("WVP","lblDevVSTOrder"),0,"lblDevVSTOrder")
          setGadgetWidth(\lblDevVSTOrder,nOrderWidth,#True)
          \lblDevVSTPlugin=scsTextGadget(gnNextX+gnGap2,nTop,160,17,Lang("VST","lblVSTPlugin"),0,"lblVSTPlugin")
          \lblDevVSTView=scsTextGadget(gnNextX+gnGap2,nTop,80,17,Lang("VST","chkView"),0,"lblDevVSTView")
          setGadgetWidth(\lblDevVSTView,20,#True)
          \lblDevVSTBypass=scsTextGadget(gnNextX+gnGap2,nTop,80,17,Lang("VST","chkBypass"),0,"lblDevVSTBypass")
          setGadgetWidth(\lblDevVSTBypass,20,#True)
          \lblDevVSTComment=scsTextGadget(gnNextX+gnGap2,nTop,80,17,Lang("VST","lblVSTComment"),0,"lblDevVSTComment")
          setGadgetWidth(\lblDevVSTComment,20,#True)
          nTop + 21
          \cntDevSideBar=scsContainerGadget(nSideBarLeft,nTop-1,nSideBarWidth,44,#PB_Container_BorderLess,"cntDevSideBar")
            \imgDevButtonTBS[0]=scsStandardButton(0,0,20,20,#SCS_STANDARD_BTN_MOVE_UP,"imgDevButtonTBS[0]",#True)
            \imgDevButtonTBS[1]=scsStandardButton(0,22,20,20,#SCS_STANDARD_BTN_MOVE_DOWN,"imgDevButtonTBS[1]",#True)
          scsCloseGadgetList()
          ; calculate 'left' position for lblVSTOrder fields so that they are centred below lblDevVSTOrder
          nLeft = GadgetX(\lblDevVSTOrder) + (GadgetWidth(\lblDevVSTOrder) >> 1) - (nOrderWidth >> 1)
          For n = 0 To grLicInfo\nMaxVSTDevPlugin
            sNr = "["+n+"]"
            \aDevVSTPlugin(n)\lblDevVSTOrder=scsStringGadget(nLeft,nTop,nOrderWidth,20,Str(n+1),#PB_String_ReadOnly|#ES_CENTER,"lblDevVSTOrder"+sNr,#SCS_G4EH_VP_LBLDEVVSTORDER)
            \aDevVSTPlugin(n)\cboDevVSTPlugin=scsComboBoxGadget(GadgetX(\lblDevVSTPlugin),nTop,160,20,0,"cboDevVSTPlugin"+sNr,#SCS_G4EH_VP_CBODEVVSTPLUGIN)
            \aDevVSTPlugin(n)\chkDevViewVST=scsCheckBoxGadget(GadgetX(\lblDevVSTView)+(GadgetWidth(\lblDevVSTView)>>1)-6,nTop,20,20,"",0,"chkDevViewVST"+sNr,#SCS_G4EH_VP_CHKDEVVIEWVST)
            \aDevVSTPlugin(n)\chkDevBypassVST=scsCheckBoxGadget(GadgetX(\lblDevVSTBypass)+(GadgetWidth(\lblDevVSTBypass)>>1)-6,nTop,20,20,"",0,"chkDevBypassVST"+sNr,#SCS_G4EH_VP_CHKDEVBYPASSVST)
            \aDevVSTPlugin(n)\txtDevVSTComment=scsStringGadget(GadgetX(\lblDevVSTComment),nTop,GadgetWidth(\cntDevVSTPlugins)-GadgetX(\lblDevVSTComment)-12,20,"",0,"txtDevVSTComment"+sNr,#SCS_G4EH_VP_TXTDEVVSTCOMMENT)
            nTop + 23
          Next n
        scsCloseGadgetList() ; cntDevVSTPlugins
        
        ;- 'Cue Plugins' tab
        ; cue audio device VST plugin gadgets
        addGadgetItemWithData(\pnlVSTPlugins, Lang("WVP","CuePlugins"), #SCS_WVP_TAB_CUE_PLUGINS)
        \cntCueVSTPlugins=scsContainerGadget(nPanelItemLeft,nPanelItemTop,nPanelItemWidth,nPanelItemHeight,#PB_Container_Flat,"cntCueVSTPlugins")
          nTop = 6
          nLeft = 24
          \lblCueVSTPlugins=scsTextGadget(nLeft,nTop,80,15,Lang("WVP","lblCueVSTPlugins"),0,"lblCueVSTPlugins")
          setGadgetWidth(\lblCueVSTPlugins, -1, #True)
          \chkOnlyCuesWithAPlugin=scsCheckBoxGadget(gnNextX+20,nTop-2,200,17,Lang("WVP","chkOnlyCuesWithAPlugin"),0,"chkOnlyCuesWithAPlugin")
          setGadgetWidth(\chkOnlyCuesWithAPlugin)
          nTop + 19
          nWidth = GadgetWidth(\cntCueVSTPlugins) - (nLeft * 2)
          nHeight = GadgetHeight(\cntCueVSTPlugins) - nTop - 33
          \grdCueVSTPlugins=scsListIconGadget(nLeft, nTop, nWidth, nHeight, grText\sTextCue,40,#PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_FullRowSelect | #PB_ListIcon_GridLines,"grdCueVSTPlugins")
          nTop + GadgetHeight(\grdCueVSTPlugins) + 4
          \btnCueOpen=scsButtonGadget(nLeft,nTop,100,23,LangPars("WVP","btnCueOpen","?"),#PB_Button_Default,"btnCueOpen")
          scsToolTip(\btnCueOpen,Lang("WVP","btnCueOpenTT"))
          setGadgetWidth(\btnCueOpen)
        scsCloseGadgetList() ; cntCueVSTPlugins
        
      scsCloseGadgetList() ; pnlVSTPlugins
      
      nTop = GadgetY(\pnlVSTPlugins) + GadgetHeight(\pnlVSTPlugins) + 8
      ; determine button widths
      nTextWidth = GetTextWidth(Lang("WVP","btnApplyVSTChgs"))
      If GetTextWidth(Lang("WVP","btnUndoVSTChgs")) > nTextWidth
        nTextWidth = GetTextWidth(Lang("WVP","btnUndoVSTChgs"))
      EndIf
      nWidth = nTextWidth + GetTextWidth(Space(6)) + gl3DBorderAllowanceX + gl3DBorderAllowanceX
      \btnApplyVSTChgs=scsButtonGadget(12,nTop,nWidth,23,Lang("WVP","btnApplyVSTChgs"),0,"btnApplyVSTChgs")
      \btnUndoVSTChgs=scsButtonGadget(gnNextX+gnGap,nTop,nWidth,23,Lang("WVP","btnUndoVSTChgs"),0,"btnUndoVSTChgs")
      nWidth = 81
      nLeft = WindowWidth(#WVP) - (nWidth * 2) - gnGap - 12
      \btnClose=scsButtonGadget(nLeft,nTop,nWidth,23,Lang("Btns","Close"),0,"btnClose")
      \btnHelp=scsButtonGadget(gnNextX+gnGap,nTop,nWidth,23,grText\sTextBtnHelp,0,"btnHelp")
      
    EndWith
    setWindowVisible(#WVP,#True)
    setWindowEnabled(#WVP,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure

Procedure createfmDummy()
  PROCNAMEC()
  ; dummy hidden window for BASS_Init() calls
  
  debugMsg(sProcName, #SCS_START)
  
  If OpenWindow(#WDU, 0, 0, 100, 100, "", #PB_Window_Invisible)
    registerWindow(#WDU, "WDU(fmDummy)")
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWES ; fmScribbleStrip
  btnCancel.i
  btnOK.i
  cntBelowGrid.i
  lblDevName.i
  lblItemType.i
  lblItemName.i
  pnlCategories.i
  scaCategoryItems.i
  Array txtCategoryItemCode.i(0)
  Array txtCategoryItemName.i(0)
  txtDevName.i
EndStructure
Global WES.strWES ; fmScribbleStrip

Procedure createfmScribbleStrip()
  PROCNAMEC()
  Protected nFlags
  Protected nLeft, nTop, nWidth, nHeight, nGap
  Protected nItemHeight, nInnerWidth, nInnerHeight, nItemCount, nItemIndex, nPadding, nTabHeight
  Protected nCntBelowGridHeight
  
  nCntBelowGridHeight = 35
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL)
  nFlags = #PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Invisible | #PB_Window_SizeGadget
  If OpenWindow(#WES, 0, 0, 300, 300, Lang("WES","Window"), nFlags, WindowID(#WED))
    registerWindow(#WES, "WES(fmScribbleStrip)")
    With WES
      nLeft = 4
      nTop = 12
      \lblDevName=scsTextGadget(nLeft+12,nTop+gnLblVOffsetS,80,15,grText\sTextDevice,0,"lblDevName")
      setGadgetWidth(\lblDevName,-1,#True)
      \txtDevName=scsStringGadget(gnNextX+gnGap,nTop,120,21,"",#PB_String_ReadOnly,"txtDevName")
      nTop + 25
      nWidth = WindowWidth(#WES) - (nLeft << 1)
      nHeight = WindowHeight(#WES) - nTop - nCntBelowGridHeight - 12
      \pnlCategories=scsPanelGadget(nLeft, nTop, nWidth, nHeight, "pnlCategories")
        AddGadgetItem(\pnlCategories, -1, "X") ; temporary - to enable TabHeight to be calculated. Will be removed when panel categories are loaded in WES_loadPnlCategories()
      scsCloseGadgetList()
      nTabHeight = GetGadgetAttribute(\pnlCategories, #PB_Panel_TabHeight)
      ; debugMsg0(sProcName, "nHeight=" + nHeight + ", nTabHeight=" + nTabHeight)
      ResizeGadget(\pnlCategories, #PB_Ignore, #PB_Ignore, #PB_Ignore, nTabHeight)
      nPadding = 4
      nLeft = GadgetX(\pnlCategories) + glBorderWidth
      nTop = GadgetY(\pnlCategories) + nTabHeight + 7
      \lblItemType=scsTextGadget(nLeft+8,nTop,80,15,"",0,"lblItemType")
      \lblItemName=scsTextGadget(gnNextX+gnGap,nTop,80,15,Lang("WES","lblItemName"),0,"lblItemName")
      nTop + 17
      nWidth = GadgetWidth(\pnlCategories) - (nLeft << 1)
      nHeight = WindowHeight(#WES) - nTop - nCntBelowGridHeight - 12
      grWES\nMaxItem = -1
      nItemCount = 2
      ReDim \txtCategoryItemCode(nItemCount-1)
      ReDim \txtCategoryItemName(nItemCount-1)
      nItemHeight = 21
      nInnerWidth = nWidth - gl3DBorderAllowanceX - glScrollBarWidth
      nInnerHeight = (nItemCount * nItemHeight) + gl3DBorderAllowanceY + 1
      \scaCategoryItems=scsScrollAreaGadget(nLeft, nTop, nWidth, nHeight, nInnerWidth,nInnerHeight,nItemHeight,#PB_ScrollArea_Flat,"scaCategoryItems")
        nLeft = 0
        nTop = 0
        For nItemIndex = 0 To (nItemCount - 1)
          \txtCategoryItemCode(nItemIndex)=scsStringGadget(nLeft,nTop,80,21,"",#PB_String_ReadOnly,"txtCategoryItemCode[" + nItemIndex + "]")
          \txtCategoryItemName(nItemIndex)=scsStringGadget(gnNextX+gnGap,nTop,80,21,"",0,"txtCategoryItemName[" + nItemIndex + "]")
          nTop + nItemHeight
        Next nItemIndex
      scsCloseGadgetList()
      nTop = WindowHeight(#WES) - nCntBelowGridHeight
      nWidth = WindowWidth(#WES)
      \cntBelowGrid=scsContainerGadget(0,nTop,nWidth,nCntBelowGridHeight,#PB_Container_BorderLess,"cntBelowGrid")
        nTop = 6
        nWidth = 80
        nGap = 24
        nLeft = (WindowWidth(#WES) - (2 * nWidth) - nGap) / 2
        nHeight = 23
        \btnOK=scsButtonGadget(nLeft, nTop, nWidth, nHeight, grText\sTextBtnOK,#PB_Button_Default,"btnOK")
        \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nWidth,nHeight,grText\sTextBtnCancel,0,"btnCancel")
        AddKeyboardShortcut(#WES, #PB_Shortcut_Return, #SCS_mnuKeyboardReturn)
        AddKeyboardShortcut(#WES, #PB_Shortcut_Escape, #SCS_mnuKeyboardEscape)
      scsCloseGadgetList()
    EndWith
    setWindowEnabled(#WES,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWLV ; fmCboListView
  lstComboValues.i
EndStructure
Global WLV.strWLV ; fmCboListView

Procedure createfmCboListView()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ; Window and ListView gadget will be sized dynamically
  If OpenWindow(#WLV, 0, 0, 0, 0, "", #PB_Window_BorderLess|#PB_Window_Invisible)
    With WLV
      \lstComboValues = scsListViewGadget(0, 0, 0, 0, 0, "lstComboValues")
      StickyWindow(#WLV, #True)
    EndWith
    setWindowEnabled(#WLV,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Structure strWLD ; fmLinkDevs
  btnCancel.i
  btnClearAll.i
  btnOK.i
  btnSelectAll.i
  grdLinkDevs.i
  lblTitle.i
  txtTitle.i
  ; Other fields
  nParentWindow.i
  nCaller.i ; 1 = called from fmEditQF; 2 = called from fmMain (for cue panels, etc)
            ; NB nCaller not currently used. Added initially for use in WLD_applyChanges(), but decided it was not required for actions in that procedure.
            ; Decided to keep nCaller for possible future use.
  nLinkDevSubPtr.i
  nLinkDevAudPtr.i
  bDeviceSelected.i[#SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB+1]
  bChanges.i
EndStructure
Global WLD.strWLD ; fmLinkDevs

Procedure createfmLinkDevs(nParentWindow)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Protected nFlags
  Protected nLeft, nTop, nWidth, nHeight
  Protected nGap, nBtnWidth, nColWidth
  
  debugMsg(sProcName, #SCS_START)
  
  scsSetGadgetFont(#PB_Default, #SCS_FONT_GEN_NORMAL10)
  nWindowHeight = 300
  nWindowWidth = 250
  nFlags = #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_Invisible | #PB_Window_SizeGadget
  If OpenWindow(#WLD, 0, 0, nWindowWidth, nWindowHeight, Lang("WLD", "Window"), nFlags, WindowID(nParentWindow))
    registerWindow(#WLD, "WLD(fmLinkDevs)")
    With WLD
      nLeft = 8
      nTop = 4
      \lblTitle=scsTextGadget(nLeft,nTop,70,17,Lang("WLD","lblTitle"),0,"lblTiotle")
      setGadgetWidth(\lblTitle, -1, #True)
      nTop + 18
      nWidth = nWindowWidth - nLeft - nLeft
      \txtTitle=scsStringGadget(nLeft,nTop,nWidth,21,"",0,"txtTitle")
      setEnabled(\txtTitle, #False)
      setTextBoxBackColor(\txtTitle)
      scsSetGadgetFont(\txtTitle, #SCS_FONT_GEN_BOLD10)
      nTop + 27
      \btnSelectAll=scsButtonGadget(nLeft,nTop,81,gnBtnHeight,Lang("Btns","SelectAll"),0,"btnSelectAll")
      \btnClearAll=scsButtonGadget(gnNextX+6,nTop,81,gnBtnHeight,Lang("Btns","ClearAll"),0,"btnClearAll")
      nTop + 28
      nHeight = nWindowHeight - nTop - (gnBtnHeight) - 16 ; also used in WLD_Form_Resized()
      nColWidth = nWidth - (glBorderAllowanceX * 2) - glScrollBarWidth ; see also comments about autoFitGridCol() in WLD_loadGrid()
      \grdLinkDevs = scsListIconGadget(nLeft, nTop, nWidth, nHeight, Lang("Common","AudioDevice"), nColWidth, #PB_ListIcon_CheckBoxes|#PB_ListIcon_GridLines,"grdLinkDevs")
      nTop = GadgetY(\grdLinkDevs) + GadgetHeight(\grdLinkDevs) + 8 ; also used in WLD_Form_Resized()
      nGap = 12
      nBtnWidth = 81
      nLeft = (WindowWidth(#WLD) - (nBtnWidth * 2) - (nGap)) >> 1
      \btnOK=scsButtonGadget(nLeft,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnOK,0,"btnOK")
      \btnCancel=scsButtonGadget(gnNextX+nGap,nTop,nBtnWidth,gnBtnHeight,grText\sTextBtnCancel,0,"btnCancel")
    EndWith
    WindowBounds(#WLD, nWindowWidth, 100, nWindowWidth, #PB_Ignore) ; Prevents user from adjusting the width of the window but enabling the height to be changed
    setWindowEnabled(#WLD,#True)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

; EOF