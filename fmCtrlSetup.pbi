; File: fmCtrlSetup.pbi

EnableExplicit

Procedure WCM_closeWindow()
  PROCNAMEC()
  Protected nResponse
  
  WCM_checkChanged()
  If mrCtrlSetup\bDataChanged
    nResponse = scsMessageRequester(GWT(#WCM), Lang("Common", "ApplyChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        ProcedureReturn
        
      Case #PB_MessageRequester_Yes
        WCM_btnOK_Click() ; nb calls WCM_applyChanges() followed by WCM_Form_Unload()
        
      Case #PB_MessageRequester_No
        WCM_btnCancel_Click()
        
    EndSelect
    
  Else
    WCM_btnCancel_Click()
    
  EndIf
  
EndProcedure

Procedure WCM_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WCM, @grCtrlSetupWindow)
  unsetWindowModal(#WCM)
  scsCloseWindow(#WCM)
  
  debugMsg(sProcName, "calling closeMidiPorts()")
  closeMidiPorts()
  ; Added 13May2024 11.10.2
  debugMsg(sProcName, "calling loadMidiControl(#False)")
  loadMidiControl(#False)
  With grCtrlSetup
    If \nCtrlMidiInPhysicalDevPtr >= 0
      gaMidiInDevice(\nCtrlMidiInPhysicalDevPtr)\bCueControl = #True
      debugMsg(sProcName, "gaMidiInDevice(" + \nCtrlMidiInPhysicalDevPtr + ")\bCueControl=" + strB(gaMidiInDevice(\nCtrlMidiInPhysicalDevPtr)\bCueControl))
    EndIf
  EndWith
  ; End added 13May2024 11.10.2
  debugMsg(sProcName, "calling openMidiPorts()")
  openMidiPorts()
  
  If grCtrlSetup\bRecreateWCN
    CloseWindow(#WCN)
    WCN_Form_Show()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCM_applyChanges()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With mrCtrlSetup
    setBooleanUseExternalController(@mrCtrlSetup)
    If \bUseExternalController
      \nCtrlMidiInPhysicalDevPtr = getPhysicalDevPtr(#SCS_DEVTYPE_EXTCTRL_MIDI_IN, \sCtrlMidiInPort)
      If \sCtrlMidiOutPort
        \nCtrlMidiOutPhysicalDevPtr = getPhysicalDevPtr(#SCS_DEVTYPE_EXTCTRL_MIDI_OUT, \sCtrlMidiOutPort)
      Else
        \nCtrlMidiOutPhysicalDevPtr = grCtrlSetupDef\nCtrlMidiOutPhysicalDevPtr
      EndIf
    EndIf
    debugMsg(sProcName, "mrCtrlSetup\bUseExternalController=" + strB(\bUseExternalController) + ", \sCtrlMidiInPort=" + \sCtrlMidiInPort + ", \nCtrlMidiInPhysicalDevPtr=" + \nCtrlMidiInPhysicalDevPtr +
                        ", \sCtrlMidiOutPort=" + \sCtrlMidiOutPort + ", \nCtrlMidiOutPhysicalDevPtr=" + \nCtrlMidiOutPhysicalDevPtr)
  EndWith
  
  WCM_checkChanged()
  
  grCtrlSetup = mrCtrlSetup
  
  If IsWindow(#WMN)
    ; should be #True
    WCN\nPlayingSubTypeF = -1 ; forces playing faders to be reloaded if required
    If grCtrlSetup\bUseExternalController
      WCN_primeControllers()
      WCN_primeKnobs()
    EndIf
    ; debugMsg0(sProcName, "calling WCN_setPlayingControlsIfReqd")
    WCN_setPlayingControlsIfReqd()
  EndIf
  
  setFileSave(#True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCM_btnOK_Click()
  PROCNAMEC()

  WCM_applyChanges()
  WCM_Form_Unload()
  
EndProcedure

Procedure WCM_btnCancel_Click()
  PROCNAMEC()
  
  WCM_Form_Unload()
  
EndProcedure

Procedure WCM_cboController_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With mrCtrlSetup
    \nController = getCurrentItemData(WCM\cboController)
    \sCtrlMidiInPort = ""  ; will be determined by WCM_fcController()
    \sCtrlMidiOutPort = "" ; will be determined by WCM_fcController()
    WCM_fcController()
  EndWith
EndProcedure

Procedure WCM_cboMidiInPort_Click()
  PROCNAMEC()
  Protected nPhysicalDevPtr
  
  With mrCtrlSetup
    nPhysicalDevPtr = getCurrentItemData(WCM\cboMidiInPort)
    \sCtrlMidiInPort = gaMidiInDevice(nPhysicalDevPtr)\sName
    WCM_fcController()
  EndWith
EndProcedure

Procedure WCM_cboMidiOutPort_Click()
  PROCNAMEC()
  Protected nPhysicalDevPtr
  
  With mrCtrlSetup
    nPhysicalDevPtr = getCurrentItemData(WCM\cboMidiOutPort)
    \sCtrlMidiOutPort = gaMidiOutDevice(nPhysicalDevPtr)\sName
    WCM_fcController()
  EndWith
EndProcedure

Procedure WCM_cboCtrlConfig_Click()
  PROCNAMEC()
  
  With mrCtrlSetup
    \nCtrlConfig = getCurrentItemData(WCM\cboCtrlConfig)
    WCM_displayCtrlDetail()
  EndWith
EndProcedure

Procedure WCM_chkIncludeGoEtc_Click()
  PROCNAMEC()
  
  With mrCtrlSetup
    \bIncludeGoEtc = GGS(WCM\chkIncludeGoEtc)
    WCM_displayCtrlDetail()
  EndWith
  
EndProcedure

Procedure WCM_checkChanged()
  ; Changed 25Jun2022 11.9.4
  PROCNAMEC()
  Protected bChangeFound
  
  With mrCtrlSetup
    If \nController <> grCtrlSetup\nController
      bChangeFound = #True
      \bRecreateWCN = #True
    ElseIf \nCtrlConfig <> grCtrlSetup\nCtrlConfig
      bChangeFound = #True
      \bRecreateWCN = #True
    ElseIf \sCtrlMidiInPort <> grCtrlSetup\sCtrlMidiInPort
      bChangeFound = #True
    ElseIf \sCtrlMidiOutPort <> grCtrlSetup\sCtrlMidiOutPort
      bChangeFound = #True
    ElseIf \bIncludeGoEtc <> grCtrlSetup\bIncludeGoEtc
      bChangeFound = #True
    ElseIf \bShowMidi <> grCtrlSetup\bShowMidi
      bChangeFound = #True
    EndIf
    \bDataChanged = bChangeFound
    debugMsg(sProcName, "mrCtrlSetup\bDataChanged=" + strB(\bDataChanged) + ", \bRecreateWCN=" + strB(\bRecreateWCN))
  EndWith
  ProcedureReturn bChangeFound
EndProcedure

Procedure WCM_Form_Show()
  PROCNAMEC()
  Protected nListIndex
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If IsImage(hWCM_BCR2000) = #False
    IMG_catchControlSurfaceImages()
  EndIf
  
  mrCtrlSetup = grCtrlSetup
  
  If IsWindow(#WCM) = #False
    createfmCtrlSetup()
  EndIf
  setFormPosition(#WCM, @grCtrlSetupWindow)
  
  With WCM
    ClearGadgetItems(\cboController)
    addGadgetItemWithData(\cboController, decodeControllerL(#SCS_CTRL_NONE), #SCS_CTRL_NONE) ; 20Jun2022 11.9.4
    addGadgetItemWithData(\cboController, decodeControllerL(#SCS_CTRL_MIDI_CUE_CONTROL), #SCS_CTRL_MIDI_CUE_CONTROL)
    addGadgetItemWithData(\cboController, decodeControllerL(#SCS_CTRL_BCF2000), #SCS_CTRL_BCF2000)
    addGadgetItemWithData(\cboController, decodeControllerL(#SCS_CTRL_BCR2000), #SCS_CTRL_BCR2000)
    addGadgetItemWithData(\cboController, decodeControllerL(#SCS_CTRL_NK2), #SCS_CTRL_NK2) ; 14Jun2022 11.9.4
    nListIndex = indexForComboBoxData(\cboController, mrCtrlSetup\nController, 0)
    SGS(\cboController, nListIndex)
    
    ClearGadgetItems(\cboMidiInPort)
    For n = 0 To (gnNumMidiInDevs-1)
      addGadgetItemWithData(\cboMidiInPort, gaMidiInDevice(n)\sName, n)
    Next n
    nListIndex = indexForComboBoxRow(\cboMidiInPort, mrCtrlSetup\sCtrlMidiInPort, -1)
    SGS(\cboMidiInPort, nListIndex)
    
    ClearGadgetItems(\cboMidiOutPort)
    For n = 0 To (gnNumMidiOutDevs-1)
      If gaMidiOutDevice(n)\bIgnoreDev = #False
        addGadgetItemWithData(\cboMidiOutPort, gaMidiOutDevice(n)\sName, n)
      EndIf
    Next n
    nListIndex = indexForComboBoxRow(\cboMidiOutPort, mrCtrlSetup\sCtrlMidiOutPort, -1)
    SGS(\cboMidiOutPort, nListIndex)
    
    SGS(\chkIncludeGoEtc, mrCtrlSetup\bIncludeGoEtc)
    
  EndWith
  
  WCM_fcController()
  
  setWindowModal(#WCM, #True)
  setWindowVisible(#WCM, #True)
  SAW(#WCM)
  
EndProcedure

Procedure WCM_EventHandler()
  PROCNAMEC()
  Protected n
  Protected bFound
  
  With WCM
    
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WCM_closeWindow()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WCM_btnCancel_Click()
            
          Case \btnHelp
            displayHelpTopic("ControllerMIDISetup.htm")
            
          Case \btnOK
            WCM_btnOK_Click()
            
          Case \cboController
            CBOCHG(WCM_cboController_Click())
            
          Case \cboCtrlConfig
            CBOCHG(WCM_cboCtrlConfig_Click())
            
          Case \cboMidiInPort
            CBOCHG(WCM_cboMidiInPort_Click())
            
          Case \cboMidiOutPort
            CBOCHG(WCM_cboMidiOutPort_Click())
            
          Case \chkIncludeGoEtc
            WCM_chkIncludeGoEtc_Click()
            
          Case \cvsCueCtrlDetail, \cvsStdCtrlDetail
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCM_drawItem(sText.s, nLeft, nTop, nWidth, nHeight, nTextOffSet=8, bMinLineGap=#False, nAlignPosition=#SCS_ALIGN_MIDDLE, bNarrowLines=#False)
  ; Note: When calling WCM_drawItem() set nTextOffSet to -1 to centre the text
  PROCNAMEC()
  Protected nTextWidth, nTextHeight, nTextTop, nTextLeft
  Protected nLineCount, nLineGap, nTotalHeight, nLineWidth
  Protected n
  Protected sLine.s
  
  DrawingMode(#PB_2DDrawing_Outlined | #PB_2DDrawing_Transparent)
  scsDrawingFont(#SCS_FONT_GEN_NORMAL)
  Box(nLeft,nTop,nWidth,nHeight,#SCS_Red)
  If bNarrowLines = #False
    Box(nLeft+1,nTop+1,nWidth-2,nHeight-2,#SCS_Red)
  EndIf
  If sText
    nLineCount = CountString(sText, Chr(10)) + 1
    nTextHeight = TextHeight(sText)
    If bMinLineGap = #False
      nLineGap = nTextHeight >> 1
    EndIf
    nTotalHeight = (nTextHeight * nLineCount) + (nLineGap * (nLineCount - 1))
    Select nAlignPosition
      Case #SCS_ALIGN_TOP
        nTextTop = nTop + (nTextHeight >> 1) ; allow half a text line height from top of item area
      Case #SCS_ALIGN_MIDDLE ; (default position)
        nTextTop = nTop + ((nHeight - nTotalHeight) >> 1)
      Case #SCS_ALIGN_BOTTOM
        nTextTop = nTop + nHeight - nTotalHeight - (nTextHeight >> 1) ; allow half a text line height from bottom of item area
    EndSelect
    ; debugMsg0(sProcName, "sText=" + sText + ", nTextOffSet=" + nTextOffSet + ", nLineCount=" + nLineCount)
    For n = 1 To nLineCount
      sLine = StringField(sText, n, Chr(10))
      If nTextOffSet >= 0
        nTextLeft = nTextOffSet
      Else ; if nTextOffSet negative then centre the text
        nLineWidth = TextWidth(sLine)
        If nLineWidth < nWidth
          nTextLeft = (nWidth - nLineWidth) >> 1
        Else
          nTextLeft = 0
        EndIf
      EndIf
      ; debugMsg0(sProcName, "nLeft=" + nLeft + ", nTextLeft=" + nTextLeft)
      DrawText(nLeft+nTextLeft, nTextTop, sLine, #SCS_White)
      nTextTop + nTextHeight + nLineGap
    Next n
  EndIf
  
EndProcedure

Procedure WCM_displayCtrlDetail()
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  Protected nImageLeft, nImageTop, nImageWidth, nImageHeight
  Protected nItemLeft, nItemTop, nItemWidth, nItemHeight, nItemWidthPrev, nItemWidthNext
  Protected sItemText.s, sItemTextPrev.s, sItemTextNext.s
  Protected nTextLeft, nTextTop, nTextWidth, nTextHeight
  Protected nCellLeft, nCellTop, nCellWidth, nCellHeight
  Protected sCellText.s
  Protected sInfoLine1.s, sInfoLine2.s
  Protected d, n, nMidiDevCount, bDeviceUsed, nDevMapDevPtr
  
  Select mrCtrlSetup\nController
    Case #SCS_CTRL_NONE ; Added 20Jun2022 11.9.4
      If StartDrawing(CanvasOutput(WCM\cvsCueCtrlDetail))
        Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
        StopDrawing()
      EndIf
      setVisible(WCM\cntStdCtrl, #False)
      setVisible(WCM\cntCueCtrl, #True)
      
    Case #SCS_CTRL_BCR2000, #SCS_CTRL_BCF2000, #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
      If StartDrawing(CanvasOutput(WCM\cvsStdCtrlDetail))
        nCanvasWidth = GadgetWidth(WCM\cvsStdCtrlDetail)
        nCanvasHeight = GadgetHeight(WCM\cvsStdCtrlDetail)
        Box(0,0,nCanvasWidth,nCanvasHeight,#SCS_Black)
        
        Select mrCtrlSetup\nController
          Case #SCS_CTRL_BCR2000  ; BCR2000
            ;{-
            nImageLeft = 172
            nImageWidth = ImageWidth(hWCM_BCR2000)
            nImageHeight = ImageHeight(hWCM_BCR2000)
            ; nImageTop = (nCanvasHeight - nImageHeight) >> 1
            ; debugMsg(sProcName, "nCanvasHeight=" + Str(nCanvasHeight) + ", BCR2000 nImageHeight=" + Str(nImageHeight) + ", nImageTop=" + Str(nImageTop))
            nImageTop = 12
            DrawImage(ImageID(hWCM_BCR2000), nImageLeft, nImageTop)
            
            Select mrCtrlSetup\nCtrlConfig
              Case #SCS_CTRLCONF_BCR2000_PRESET_A To #SCS_CTRLCONF_BCR2000_PRESET_C ; BCR2000 PRESET_A to PRESET_C
                sInfoLine1 = LangPars("WCM", "lblInfo1BCR/BCF", "BCR2000")
                sInfoLine2 = LangPars("WCM", "lblInfo2BCR/BCF", "110")
                
                ; change BCR LED display to 'P- 1' (Preset 1)
                nItemLeft = nImageLeft + 272
                nItemTop = nImageTop + 27
                nItemWidth = 41
                nItemHeight = 12
                DrawingMode(#PB_2DDrawing_Default)
                Box(nItemLeft,nItemTop,nItemWidth,nItemHeight,RGB(33,29,30))  ; backcolor picked from image - close to black
                DrawingMode(#PB_2DDrawing_Transparent)
                scsDrawingFont(#SCS_FONT_GEN_ITALIC10)
                sItemText = "P- 1"
                nTextWidth = TextWidth(sItemText)
                nTextLeft = nItemLeft + ((nItemWidth - nTextWidth) / 2)
                nTextHeight = TextHeight(sItemText)
                nTextTop = nItemTop + ((nItemHeight - nTextHeight) / 2) ; nb use "/ 2", not ">> 1", to handle negative settings
                DrawText(nTextLeft,nTextTop,sItemText,#SCS_Light_Grey)
                
                nItemLeft = 12
                nItemWidth = nImageLeft + 260 - nItemLeft
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_C
                  nItemTop = nImageTop + 222
                  nItemHeight = 36
                  sItemText = LangPars("WCM", "Playing", "1-7") + " | " + Lang("Common", "Master")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  ; draw vertical line (double-width) between playing outputs and master
                  Box(nItemLeft+nItemWidth-33,nItemTop,2,nItemHeight,#SCS_Red)
                  
                Else
                  nItemTop = nImageTop + 17
                  nItemHeight = 34
                  sItemText = Lang("WCM", "EQ")
                  WCM_drawItem(sItemText,nItemLeft,nItemTop,nItemWidth-32,nItemHeight)
                  
                  Select mrCtrlSetup\nCtrlConfig
                    Case #SCS_CTRLCONF_BCR2000_PRESET_A
                      nItemTop = nImageTop + 49
                      nItemHeight = 22
                      sItemText = LangPars("WCM", "EQSelect", "1-8")
                      WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                      
                      nItemTop = nImageTop + 69
                      nItemHeight = 22
                      sItemText = LangPars("WCM", "MuteSelect", "1-8")
                      WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                      
                    Case #SCS_CTRLCONF_BCR2000_PRESET_B
                      nItemTop = nImageTop + 49
                      nItemHeight = 43
                      sItemText = ""
                      WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                      sItemText = LangPars("WCM", "EQSelect", "9-16")
                      nTextTop = nItemTop + 3
                      DrawText(nItemLeft+8,nTextTop,sItemText,#SCS_White)
                      sItemText = LangPars("WCM", "EQSelect", "1-8")
                      nTextTop + 19
                      DrawText(nItemLeft+8,nTextTop,sItemText,#SCS_White)
                      
                  EndSelect
                  
                  nItemTop = nImageTop + 17
                  nItemHeight = 34
                  sItemText = LangPars("WCM", "DMXEncoder", "8")
                  WCM_drawItem(sItemText,(nItemLeft+nItemWidth-34),nItemTop,222,nItemHeight,130,#True)
                  ; draw vertical line (double-width) after encoder 8
                  Box(nItemLeft+nItemWidth-2,nItemTop,2,nItemHeight,#SCS_Red)
                  
                  nItemTop = nImageTop + 117
                  nItemHeight = 36
                  sItemText = LangPars("WCM", "Outputs", "1-7") + " | " + Lang("Common", "Master")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  ; draw vertical line (double-width) between outputs and master
                  Box(nItemLeft+nItemWidth-33,nItemTop,2,nItemHeight,#SCS_Red)
                  
                  If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_B
                    nItemTop = nImageTop + 169
                    sItemText = LangPars("WCM", "Inputs", "9-16")
                    WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  EndIf
                  
                  nItemTop = nImageTop + 222
                  nItemWidth = nImageLeft + 261 - nItemLeft
                  sItemText = LangPars("WCM", "Inputs", "1-8")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                EndIf
                
                If mrCtrlSetup\bIncludeGoEtc
                  ; 4 control buttons - bottom right of BCR2000
                  nItemLeft = nImageLeft + 266
                  nItemTop = nImageTop + 211
                  nItemWidth = nCanvasWidth - nItemLeft - 12
                  nItemHeight = 44
                  WCM_drawItem("",nItemLeft,nItemTop,nItemWidth,nItemHeight)
                  
                  nCellLeft = nImageLeft + nImageWidth + 4
                  nCellWidth = ((nItemLeft + nItemWidth) - (nCellLeft)) >> 1
                  nCellHeight = nItemHeight >> 1
                  nCellTop = nItemTop
                  LineXY(nCellLeft, (nCellTop + nCellHeight), (nCellLeft + (nCellWidth << 1) - 1), (nCellTop + nCellHeight),#SCS_Red) ; centre horizontal line
                  LineXY((nCellLeft), nItemTop, (nCellLeft), (nItemTop + nItemHeight - 1), #SCS_Red)                                  ; left vertical line
                  LineXY((nCellLeft + nCellWidth), nItemTop, (nCellLeft + nCellWidth), (nItemTop + nItemHeight - 1), #SCS_Red)        ; middle vertical line
                  DrawingMode(#PB_2DDrawing_Transparent)
                  scsDrawingFont(#SCS_FONT_GEN_NORMAL)
                  nTextHeight = TextHeight("Gg")
                  nTextTop = nCellTop + ((nCellHeight - nTextHeight) >> 1)
                  
                  sCellText = Lang("WCM", "PrevCue")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                  sCellText = Lang("WCM", "NextCue")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + nCellWidth + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                  nTextTop + nCellHeight
                  
                  sCellText = Lang("WCM", "StopAll")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                  sCellText = Lang("WCM", "Go")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + nCellWidth + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                EndIf
            EndSelect
            ;}
            
          Case #SCS_CTRL_BCF2000  ; BCF2000
            ;{-
            nImageLeft = 172
            nImageWidth = ImageWidth(hWCM_BCF2000)
            nImageHeight = ImageHeight(hWCM_BCF2000)
            nImageTop = 12
            DrawImage(ImageID(hWCM_BCF2000), nImageLeft, nImageTop)
            
            Select mrCtrlSetup\nCtrlConfig
              Case #SCS_CTRLCONF_BCF2000_PRESET_A To #SCS_CTRLCONF_BCF2000_PRESET_C ; BCF2000 PRESET_A to PRESET_C
                sInfoLine1 = LangPars("WCM", "lblInfo1BCR/BCF", "BCF2000")
                sInfoLine2 = LangPars("WCM", "lblInfo2BCR/BCF", "94")
                
                ; change BCF LED display to 'P- 1' (Preset 1)
                nItemLeft = nImageLeft + 272
                nItemTop = nImageTop + 27
                nItemWidth = 41
                nItemHeight = 12
                DrawingMode(#PB_2DDrawing_Default)
                Box(nItemLeft,nItemTop,nItemWidth,nItemHeight,RGB(33,29,30))  ; backcolor picked from image - close to black
                DrawingMode(#PB_2DDrawing_Transparent)
                scsDrawingFont(#SCS_FONT_GEN_ITALIC10)
                sItemText = "P- 1"
                nTextWidth = TextWidth(sItemText)
                nTextLeft = nItemLeft + ((nItemWidth - nTextWidth) / 2)
                nTextHeight = TextHeight(sItemText)
                nTextTop = nItemTop + ((nItemHeight - nTextHeight) / 2) ; nb use "/ 2", not ">> 1", to handle negative settings
                DrawText(nTextLeft,nTextTop,sItemText,#SCS_Light_Grey)
                
                nItemLeft = 12
                nItemWidth = nImageLeft + 261 - nItemLeft
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
                  nItemTop = nImageTop + 17
                  nItemHeight = 34
                  sItemText = Lang("WCM", "EQ")
                  WCM_drawItem(sItemText,nItemLeft,nItemTop,nItemWidth-32,nItemHeight)
                  
                  nItemTop = nImageTop + 49
                  nItemHeight = 22
                  sItemText = LangPars("WCM", "EQSelect", "1-8")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  
                  nItemTop = nImageTop + 69
                  nItemHeight = 22
                  sItemText = LangPars("WCM", "MuteSelect", "1-8")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  
                  nItemTop = nImageTop + 128
                  nItemWidth = nImageLeft + 261 - nItemLeft
                  nItemHeight = 134
                  sItemText = LangPars("WCM", "Inputs", "1-8")
                  sItemText + Chr(10) + Space(6) + Lang("Common", "Or") + Chr(10)
                  sItemText + LangPars("WCM", "Outputs", "1-7") + " | " + Lang("Common", "Master")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  
                Else ; #SCS_CTRLCONF_BCF2000_PRESET_C
                  nItemTop = nImageTop + 128
                  nItemWidth = nImageLeft + 261 - nItemLeft
                  nItemHeight = 134
                  sItemText = LangPars("WCM", "Playing", "1-7") + " | " + Lang("Common", "Master")
;                   sItemText + Chr(10) + Space(6) + Lang("Common", "Or") + Chr(10)
;                   sItemText + LangPars("WCM", "Outputs", "1-7") + " | " + Lang("Common", "Master")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight)
                  ; draw vertical line (double-width) between playing outputs and master
                  Box(nItemLeft+nItemWidth-33,nItemTop,2,nItemHeight,#SCS_Red)
                  
                  
                EndIf
                
                ; 4 control buttons - bottom right of BCF2000
                nItemLeft = nImageLeft + 266
                nItemTop = nImageTop + 211
                nItemWidth = nCanvasWidth - nItemLeft - 12
                nItemHeight = 44
                WCM_drawItem("",nItemLeft,nItemTop,nItemWidth,nItemHeight)
                
                nCellLeft = nImageLeft + nImageWidth + 4
                nCellWidth = ((nItemLeft + nItemWidth) - (nCellLeft)) >> 1
                nCellHeight = nItemHeight >> 1
                nCellTop = nItemTop
                LineXY(nCellLeft, (nCellTop + nCellHeight), (nCellLeft + (nCellWidth << 1) - 1), (nCellTop + nCellHeight),#SCS_Red) ; centre horizontal line
                LineXY((nCellLeft), nItemTop, (nCellLeft), (nItemTop + nItemHeight - 1), #SCS_Red)                                  ; left vertical line
                LineXY((nCellLeft + nCellWidth), nItemTop, (nCellLeft + nCellWidth), (nItemTop + nItemHeight - 1), #SCS_Red)        ; middle vertical line
                DrawingMode(#PB_2DDrawing_Transparent)
                scsDrawingFont(#SCS_FONT_GEN_NORMAL)
                nTextHeight = TextHeight("Gg")
                nTextTop = nCellTop + ((nCellHeight - nTextHeight) >> 1)
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
                  sCellText = Lang("WCM", "InputsBtn")
                Else ; #SCS_CTRLCONF_BCF2000_PRESET_C
                  sCellText = Lang("WCM", "PrevCue")
                EndIf
                nTextWidth = TextWidth(sCellText)
                If nTextWidth < nCellWidth
                  nTextLeft = nCellLeft + ((nCellWidth - nTextWidth) >> 1)
                Else
                  nTextLeft = nCellLeft
                EndIf
                DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
                  sCellText = Lang("WCM", "OutputsBtn")
                  nTextWidth = TextWidth(sCellText)
                Else ; #SCS_CTRLCONF_BCF2000_PRESET_C
                  sCellText = Lang("WCM", "NextCue")
                EndIf
                If nTextWidth < nCellWidth
                  nTextLeft = nCellLeft + nCellWidth + ((nCellWidth - nTextWidth) >> 1)
                Else
                  nTextLeft = nCellLeft + nCellWidth
                EndIf
                DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                
                nTextTop + nCellHeight
                
                If mrCtrlSetup\bIncludeGoEtc
                  sCellText = Lang("WCM", "StopAll")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                  sCellText = Lang("WCM", "Go")
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + nCellWidth + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                Else
                  sCellText = "-"
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                  sCellText = "-"
                  nTextWidth = TextWidth(sCellText)
                  nTextLeft = nCellLeft + nCellWidth + ((nCellWidth - nTextWidth) >> 1)
                  DrawText(nTextLeft, nTextTop, sCellText, #SCS_White)
                  
                EndIf
            EndSelect
            ;}
            
          Case #SCS_CTRL_NK2 ; Korg nanoKONTROL2
            ;{
            sInfoLine1 = Lang("WCM", "lblInfo1NK2")
            sInfoLine2 = Lang("WCM", "lblInfo2NK2")
            Select mrCtrlSetup\nCtrlConfig
              Case #SCS_CTRLCONF_NK2_PRESET_A To #SCS_CTRLCONF_NK2_PRESET_C
                nImageWidth = ImageWidth(hWCM_NK2)
                nImageHeight = ImageHeight(hWCM_NK2)
                If mrCtrlSetup\bIncludeGoEtc
                  nImageLeft = (nCanvasWidth - nImageWidth) - 30
                Else
                  nImageLeft = (nCanvasWidth - nImageWidth) >> 1
                EndIf
                nImageTop = (nCanvasHeight - nImageHeight) >> 1
                DrawImage(ImageID(hWCM_NK2), nImageLeft, nImageTop)
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
                  nItemLeft = 162 + nImageLeft
                  nItemWidth = 324 ; set this so that the right vertical border aligns with that of the sliders below
                  nItemTop = nImageTop - 26
                  nItemHeight = 60
                  sItemText = Lang("WCM", "DMXDimmers")
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_TOP, #False)
                EndIf
                
                nItemLeft = 142 + nImageLeft
                nItemTop = nImageTop + 37
                nItemHeight = nImageHeight - 37 + 34
                nItemWidth = (8 * 43) ; see comment above regarding the with of the 'dimmer channels' box
                WCM_drawItem("", nItemLeft, nItemTop, nItemWidth, nItemHeight) ; draw thicker box around multiple items
                Select mrCtrlSetup\nCtrlConfig
                  Case #SCS_CTRLCONF_NK2_PRESET_A
                    nItemWidth = (7 * 43) + 1
                    sItemText = LangPars("WCM", "Outputs", "1-7") + ", S=Solo, M=Mute" + Chr(10)
                  Case #SCS_CTRLCONF_NK2_PRESET_B
                    nItemWidth = (6 * 43) + 1
                    sItemText = LangPars("WCM", "Outputs", "1-6") + ", S=Solo, M=Mute" + Chr(10)
                  Case #SCS_CTRLCONF_NK2_PRESET_C
                    nItemWidth = (7 * 43) + 1
                    sItemText = LangPars("WCM", "Outputs", "1-7") + Chr(10) + "(" + Lang("WCM", "FirstPlaying") + ")"
                EndSelect
                WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_BOTTOM, #True)
                
                nItemLeft + nItemWidth - 1
                nItemWidth = 43
                sItemText = Lang("Common", "Master") + Chr(10)
                WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_BOTTOM, #True)
                
                If mrCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
                  nItemLeft + nItemWidth - 1
                  nItemWidth = 43
                  sItemText = ReplaceString(Lang("Common", "DMXMaster"), " ", Chr(10))
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_BOTTOM, #True)
                EndIf
                
                If mrCtrlSetup\bIncludeGoEtc
                  nItemLeft = 63 + nImageLeft
                  nItemWidth = 26
                  nItemTop = nImageTop + 91
                  nItemHeight = nImageHeight - 91 + 34
                  sItemText = ReplaceString(Lang("WCM", "StopAll"), " ", Chr(10))
                  WCM_drawItem("", nItemLeft-1, nItemTop-1, nItemWidth+nItemWidth+1, nItemHeight+2) ; draw thicker box around multiple items
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_BOTTOM, #True)
                  nItemLeft + nItemWidth - 1
                  sItemText = Lang("WCM", "Go") + Chr(10)
                  WCM_drawItem(sItemText, nItemLeft, nItemTop, nItemWidth, nItemHeight, -1, #True, #SCS_ALIGN_BOTTOM, #True)
                  
                  nItemHeight = TextHeight("Abg") + 12
                  sItemTextPrev = Lang("WCM", "PrevCue")
                  sItemTextNext = Lang("WCM", "NextCue")
                  nItemWidthPrev = TextWidth(sItemTextPrev) + 16
                  nItemWidthNext = TextWidth(sItemTextNext) + 16
                  If nItemWidthNext > nItemWidthPrev
                    nItemWidthPrev = nItemWidthNext
                  Else
                    nItemWidthNext = nItemWidthPrev
                  EndIf
                  nItemTop = nImageTop + 59 - (nItemHeight >> 1)
                  nItemLeft = nImageLeft - (nItemWidthPrev + nItemWidthNext) - 8
                  WCM_drawItem("", nItemLeft-1, nItemTop-1, nItemWidthPrev+nItemWidthNext, nItemHeight+2) ; draw thicker box around multiple items
                  WCM_drawItem(sItemTextPrev, nItemLeft, nItemTop, nItemWidthPrev, nItemHeight, -1, #True, #SCS_ALIGN_MIDDLE, #True)
                  nItemLeft + nItemWidthPrev - 1
                  WCM_drawItem(sItemTextNext, nItemLeft, nItemTop, nItemWidthNext, nItemHeight, -1, #True, #SCS_ALIGN_MIDDLE, #True)
                  nItemLeft + nItemWidthNext - 1
                  nItemTop + 5
                  nItemHeight - 9
                  nItemWidth = nImageLeft - nItemLeft + 68
                  WCM_drawItem("", nItemLeft-1, nItemTop-1, nItemWidth+1, nItemHeight+2, -1, #True, #SCS_ALIGN_MIDDLE, #False)
                EndIf
            EndSelect
            ;}
        EndSelect
        
        StopDrawing()
      EndIf
      SGT(WCM\lblInfoLine1, sInfoLine1)
      SGT(WCM\lblInfoLine2, sInfoLine2)
      setVisible(WCM\cntCueCtrl, #False)
      setVisible(WCM\cntStdCtrl, #True)
      
    Case #SCS_CTRL_MIDI_CUE_CONTROL
      If StartDrawing(CanvasOutput(WCM\cvsCueCtrlDetail))
        nCanvasWidth = GadgetWidth(WCM\cvsCueCtrlDetail)
        nCanvasHeight = GadgetHeight(WCM\cvsCueCtrlDetail)
        Box(0,0,nCanvasWidth,nCanvasHeight,#SCS_Black)
        scsDrawingFont(#SCS_FONT_WOP_LISTS)
        nMidiDevCount = 0
        nTextTop = 8
        For d = 0 To grProd\nMaxCueCtrlLogicalDev
          bDeviceUsed = #False
          With grProd\aCueCtrlLogicalDevs(d)
            If \nDevType = #SCS_DEVTYPE_CC_MIDI_IN
              For n = 0 To #SCS_MAX_MIDI_COMMAND
                Select n
                  Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_MASTER_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER, #SCS_MIDI_DMX_MASTER
                    If \aMidiCommand[n]\nCmd <> grMidiCommandDef\nCmd
                      bDeviceUsed = #True
                      Break
                    EndIf
                EndSelect
              Next n
              If bDeviceUsed
                nMidiDevCount + 1
                nTextLeft = 12
                nDevMapDevPtr = getDevMapDevPtrForDevNo(#SCS_DEVGRP_CUE_CTRL, d)
                debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
                If nDevMapDevPtr >= 0
                  sItemText = LangSpace("WEP", "lblMidiInPort") + grMaps\aDev(nDevMapDevPtr)\sPhysicalDev
                  sItemText + ", " + LangSpace("WEP", "lblMidiChannel") + \nMidiChannel
                  DrawText(nTextLeft, nTextTop, sItemText, #SCS_Very_Light_Grey, #SCS_Black)
                  nTextTop + 16
                  nTextLeft + 8
                  For n = 0 To #SCS_MAX_MIDI_COMMAND
                    Select n
                      Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_MASTER_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER, #SCS_MIDI_DMX_MASTER
                        If \aMidiCommand[n]\nCmd <> grMidiCommandDef\nCmd
                          sItemText = WEP_fixLeft(midiCmdDescrForCmdNo(n)) + WEP_buildAssignForSpecial(n, \aMidiCommand[n]\nCmd, \aMidiCommand[n]\nCC, \aMidiCommand[n]\nVV)
                          DrawText(nTextLeft, nTextTop, sItemText, #SCS_Very_Light_Grey, #SCS_Black)
                          nTextTop + 16
                        EndIf
                    EndSelect
                  Next n
                EndIf ; EndIf nDevMapDevPtr >= 0
              EndIf ; EndIf bDeviceUsed
            EndIf ; EndIf \nDevType = #SCS_DEVTYPE_CC_MIDI_IN
          EndWith
        Next d
        If nMidiDevCount = 0
          scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
          nTextLeft = 20
          nTextWidth = nCanvasWidth - (nTextLeft * 2)
          sItemText = Lang("WCM", "NoCueCtrlDev1") ; "No MIDI Cue Control device found that is set up for controlling the Master Fader, DMX Fader, or Audio Device Faders."
          WrapTextLeft(nTextLeft, nTextTop, sItemText, nTextWidth, #SCS_Yellow, #SCS_Black)
          nTextTop + 50
          sItemText = Lang("WCM", "NoCueCtrlDev2") ; "Fader control available only by using the displayed faders."
          WrapTextLeft(nTextLeft, nTextTop, sItemText, nTextWidth, #SCS_Yellow, #SCS_Black)
        EndIf
        StopDrawing()
      EndIf
      setVisible(WCM\cntStdCtrl, #False)
      setVisible(WCM\cntCueCtrl, #True)
      
  EndSelect
  
EndProcedure

Procedure WCM_fcController()
  PROCNAMEC()
  Protected nListIndex
  Protected sCtrlMidiInPort.s, sCtrlMidiOutPort.s, nCtrlMidiInChannel, nCtrlMidiOutChannel
  Protected bCtrlConfigVisible, bMidiOutVisible ; Changed 25Jun2022 11.9.4
  Protected nLeft
  
  debugMsg(sProcName, #SCS_START)
  
  With WCM
    debugMsg(sProcName, "mrCtrlSetup\nController=" + decodeController(mrCtrlSetup\nController) + ", \sCtrlMidiInPort=" + mrCtrlSetup\sCtrlMidiInPort + ", \sCtrlMidiOutPort=" + mrCtrlSetup\sCtrlMidiOutPort)
    ; Added 25Jun2022 11.9.4
    Select mrCtrlSetup\nController
      Case #SCS_CTRL_NK2
        bMidiOutVisible = #False
      Default
        bMidiOutVisible = #True
    EndSelect
    setVisible(\lblMidiOutPort, bMidiOutVisible)
    setVisible(\cboMidiOutPort, bMidiOutVisible)
    ; End added 25Jun2022 11.9.4
    
    ; try to set 'MIDI In Port' if currently blank
    If Len(mrCtrlSetup\sCtrlMidiInPort) = 0
      Select mrCtrlSetup\nController
        Case #SCS_CTRL_BCF2000
          sCtrlMidiInPort = "BCF2000"
        Case #SCS_CTRL_BCR2000
          sCtrlMidiInPort = "BCR2000"
        Case #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
          sCtrlMidiInPort = "nanoKONTROL2"
      EndSelect
      nListIndex = indexForComboBoxRow(\cboMidiInPort, sCtrlMidiInPort, -1)
      If nListIndex >= 0
        mrCtrlSetup\sCtrlMidiInPort = sCtrlMidiInPort
        nListIndex = indexForComboBoxRow(\cboMidiInPort, mrCtrlSetup\sCtrlMidiInPort, -1)
        If nListIndex >= 0
          SGS(\cboMidiInPort, nListIndex)
        EndIf
      EndIf
    EndIf
    
    ; try to set 'MIDI Out Port' if currently blank
    If Len(mrCtrlSetup\sCtrlMidiOutPort) = 0 And bMidiOutVisible ; Changed 25Jun2022 11.9.4
      Select mrCtrlSetup\nController
        Case #SCS_CTRL_BCF2000
          sCtrlMidiOutPort = "BCF2000"
        Case #SCS_CTRL_BCR2000
          sCtrlMidiOutPort = "BCR2000"
        Case #SCS_CTRL_NK2
          ; no MIDI out port supported by SCS for NK2
      EndSelect
      nListIndex = indexForComboBoxRow(\cboMidiOutPort, sCtrlMidiOutPort, -1)
      If nListIndex >= 0
        mrCtrlSetup\sCtrlMidiOutPort = sCtrlMidiOutPort
        nListIndex = indexForComboBoxRow(\cboMidiOutPort, mrCtrlSetup\sCtrlMidiOutPort, -1)
        If nListIndex >= 0
          SGS(\cboMidiOutPort, nListIndex)
        EndIf
      EndIf
    EndIf
    
    ; populate and set configuration
    ClearGadgetItems(\cboCtrlConfig)
    Select mrCtrlSetup\nController
      Case #SCS_CTRL_NONE ; Added 20Jun2022 11.9.4
        
      Case #SCS_CTRL_MIDI_CUE_CONTROL
        
      Case #SCS_CTRL_BCF2000
        bCtrlConfigVisible = #True
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_BCF2000_PRESET_A), #SCS_CTRLCONF_BCF2000_PRESET_A)
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_BCF2000_PRESET_C), #SCS_CTRLCONF_BCF2000_PRESET_C)
        
      Case #SCS_CTRL_BCR2000
        bCtrlConfigVisible = #True
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_BCR2000_PRESET_A), #SCS_CTRLCONF_BCR2000_PRESET_A)
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_BCR2000_PRESET_B), #SCS_CTRLCONF_BCR2000_PRESET_B)
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_BCR2000_PRESET_C), #SCS_CTRLCONF_BCR2000_PRESET_C)
        
      Case #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
        bCtrlConfigVisible = #True
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_NK2_PRESET_A), #SCS_CTRLCONF_NK2_PRESET_A) ; 22Jun2022 11.9.4
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_NK2_PRESET_B), #SCS_CTRLCONF_NK2_PRESET_B) ; 01Jul2022 11.9.4
        addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_NK2_PRESET_C), #SCS_CTRLCONF_NK2_PRESET_C) ; 25Aug2023 11.10.0
        
    EndSelect
;     If bCtrlConfigVisible
;       setComboBoxWidth(\cboCtrlConfig)
;     EndIf
    setComboBoxesWidth(60, \cboController, \cboCtrlConfig, \cboMidiInPort) ; nb setComboBoxesWidth() handles gadgets not present
    setComboBoxWidth(\cboMidiOutPort)
    setVisible(\lblCtrlConfig, bCtrlConfigVisible)
    setVisible(\cboCtrlConfig, bCtrlConfigVisible)
    If bCtrlConfigVisible
      ; addGadgetItemWithData(\cboCtrlConfig, decodeCtrlConfigL(#SCS_CTRLCONF_CUSTOM), #SCS_CTRLCONF_CUSTOM)
      nListIndex = indexForComboBoxData(\cboCtrlConfig, mrCtrlSetup\nCtrlConfig, -1)
      If (nListIndex = -1) And (CountGadgetItems(\cboCtrlConfig) > 0)
        nListIndex = 0
      EndIf
      SGS(\cboCtrlConfig, nListIndex)
      mrCtrlSetup\nCtrlConfig = getCurrentItemData(\cboCtrlConfig)
      nLeft = GadgetX(\cboCtrlConfig) + GadgetWidth(\cboCtrlConfig) + 8
      ResizeGadget(\lblMidiOutPort, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft + GadgetWidth(\lblMidiOutPort) + gnGap
      ResizeGadget(\cboMidiOutPort, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\chkIncludeGoEtc, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    Else
      mrCtrlSetup\nCtrlConfig = 0
    EndIf
    
    ; display control detail
    WCM_displayCtrlDetail()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF