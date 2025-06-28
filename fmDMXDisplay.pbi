; File: fmDMXDisplay.pbi

EnableExplicit

Procedure WDD_forceDisplayDMXSendData()
  PROCNAMEC()
  Protected nDMXDevPtr, nDMXPort
  
  ; debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WDD)
    If getWindowVisible(#WDD)
      With grWDD
        If \nDMXDisplayControlPtr >= 0
          nDMXDevPtr = gaDMXControl(\nDMXDisplayControlPtr)\nDMXDevPtr
          nDMXPort = gaDMXControl(\nDMXDisplayControlPtr)\nDMXPort
          \bDMXDisplayActive = #True
          debugMsg(sProcName, "grWDD\nDMXDisplayControlPtr=" + \nDMXDisplayControlPtr + ", \bDMXDisplayActive=" + strB(\bDMXDisplayActive))
          \bDMXDisplayFirstCall = #True
          \bForceRedisplay = #True
          If gbInCalcCueStartValues = #False
            If THR_getThreadState(#SCS_THREAD_DMX_SEND) <> #SCS_THREAD_STATE_ACTIVE
              debugMsg3(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)")
              THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)
            EndIf
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WDD_Form_Load()
  PROCNAMEC()
  
  With grWDD
    If IsWindow(#WDD) = #False
      createfmDMXDisplay()
      CompilerIf #c_new_gui
        WDD_drawCanvases(#True)
      CompilerEndIf
      \nSCABottomMargin = WindowHeight(#WDD) - GadgetY(WDD\scaDMXDisplay) - GadgetHeight(WDD\scaDMXDisplay)
      WDD_buildPopupMenu_BackColor()
    EndIf
    setFormPosition(#WDD, @grDMXDisplayWindow)
    
    If StartDrawing(CanvasOutput(WDD\cvsDMXDisplay))
      \nCanvasWidth = GadgetWidth(WDD\cvsDMXDisplay)
      \nCanvasHeight = GadgetHeight(WDD\cvsDMXDisplay)
      ; \nCanvasBackColor = #SCS_Very_Light_Grey ; See also drawing of WEP\cvsFTCGridSample[nFTCIndex] in FTCWEP_displayFixTypeChans()
      \nCanvasBackColor1 = WDD_getReqdCanvasBackColor()
      \nCanvasBackColor2 = RGB(Red(\nCanvasBackColor1)*92/100, Green(\nCanvasBackColor1)*92/100, Blue(\nCanvasBackColor1)*92/100)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      \nTextHeight = TextHeight("8")
      \nRowHeight = (\nCanvasHeight - 1) >> 4   ; 16 rows
      If \nTextHeight < (\nRowHeight - 1)
        \nTopMargin = (\nRowHeight - 1 - \nTextHeight) >> 1
      Else
        \nTopMargin = 0
      EndIf
      \nColWidth = 24
      \nTitleWidth = (\nCanvasWidth - 2) - (\nColWidth << 5) ; Set the title width to whatever is left after allowing for 32 column ("<< 5" = 2^5 = 32 columns)
      StopDrawing()
    EndIf
  EndWith
  
  WDD_Form_Resize()
  
  setWindowVisible(#WDD, #True)  
  SAG(-1)
  gbDMXDisplayDisplayed = #True
  
EndProcedure

Procedure WDD_setCanvasSize()
  PROCNAMEC()
  Protected nDevNo, nFixtureCount
  Protected nFixtureIndex, sRowTitle.s, nRowTitleWidth, nMaxRowTitleWidth, sMaxRowTitle.s
  Protected sFixtureCode.s, nFixtureChannels, nMaxFixtureChannels
  Static nTextImage
  Protected nTextWidth
  
  If IsImage(nTextImage) = #False
    nTextImage = scsCreateImage(16,16)
  EndIf
  
  With grWDD
    If IsImage(nTextImage)
      If StartDrawing(ImageOutput(nTextImage))
        scsDrawingFont(#SCS_FONT_GEN_NORMAL9) ; Changed 20Nov2024 11.10.6bm
        Select grMemoryPrefs\nDMXGridType
          Case #SCS_DMX_GRIDTYPE_UNIVERSE
            \nCanvasHeight = (16 * \nRowHeight) + 4
            ; \nTitleWidth = 70
            \nTitleWidth = TextWidth("888-888xx") ; As used in DMX_displayDMXSendData() in DMX.pbi
            \nCanvasWidth = \nTitleWidth + (\nColWidth * 32) + 2
            
          Case #SCS_DMX_GRIDTYPE_ALL_FIXTURES 
            ; Get Fixture Count
            nFixtureCount = 0
            For nDevNo = 0 To grProd\nMaxLightingLogicalDev
              If grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev = \sLTLogicalDev
                nFixtureCount + grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture + 1
                Break
              EndIf
            Next nDevNo
            If nFixtureCount > 0
              \nCanvasHeight = (nFixtureCount * \nRowHeight) + 4
              nMaxRowTitleWidth = 70 ; minimum width
              nMaxFixtureChannels = 4 ; minimum number of channels for calculating the canvas width
              For nFixtureIndex = 0 To grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture   ; Loop through all the fixtures in this device
                If grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
                  sRowTitle = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode + " (" +
                              grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureDesc + ")"
                  nRowTitleWidth = TextWidth(sRowTitle) + 8 ; allows for 8 pixels padding before the first DMX value
                  If nRowTitleWidth > nMaxRowTitleWidth
                    nMaxRowTitleWidth = nRowTitleWidth
                    sMaxRowTitle = sRowTitle
                  EndIf
                  sFixtureCode = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
                  nFixtureChannels = DMX_getFixtureChannelCount(nDevNo, sFixtureCode)
                  ; debugMsg(sProcName, "DMX_getFixtureChannelCount(" + nDevNo + ", " + #DQUOTE$ + sFixtureCode + #DQUOTE$ + ") returned " + nFixtureChannels)
                  If nFixtureChannels > nMaxFixtureChannels
                    nMaxFixtureChannels = nFixtureChannels
                  EndIf
                EndIf
              Next nFixtureIndex
              ; debugMsg(sProcName, "nMaxRowTitleWidth=" + nMaxRowTitleWidth + ", sMaxRowTitle=" + #DQUOTE$ + sMaxRowTitle + #DQUOTE$ + ", nMaxFixtureChannels=" + nMaxFixtureChannels)
              If nMaxRowTitleWidth > 200
                nMaxRowTitleWidth = 200 ; maximum width
              EndIf
              \nTitleWidth = nMaxRowTitleWidth
              \nCanvasWidth = \nTitleWidth + (\nColWidth * nMaxFixtureChannels) + 4
              CompilerIf 1=2
                ; Blocked out 8Nov2024 11.10.6bi
                If \nCanvasWidth < (GadgetWidth(WDD\scaDMXDisplay) - glScrollBarWidth - gl3DBorderAllowanceX)
                  ; Enlarge width of canvas for appearance sake only, so it fills the width of the scroll area
                  \nCanvasWidth = GadgetWidth(WDD\scaDMXDisplay) - glScrollBarWidth - gl3DBorderAllowanceX
                EndIf
              CompilerEndIf
            EndIf ; EndIf nFixtureCount > 0
            
        EndSelect
        StopDrawing()
      EndIf ; EndIf StartDrawing(ImageOutput(nTextImage))
    EndIf ; EndIf IsImage(nTextImage)
    
    ; debugMsg0(sProcName, "WindowWidth(#WDD)=" + WindowWidth(#WDD) + ", calling ResizeGadget(WDD\cvsDMXDisplay, #PB_Ignore, #PB_Ignore, " + \nCanvasWidth + ", " + \nCanvasHeight + ")")
    ResizeGadget(WDD\cvsDMXDisplay, #PB_Ignore, #PB_Ignore, \nCanvasWidth, \nCanvasHeight)
    SetGadgetAttribute(WDD\scaDMXDisplay, #PB_ScrollArea_InnerWidth, \nCanvasWidth)
    SetGadgetAttribute(WDD\scaDMXDisplay, #PB_ScrollArea_InnerHeight, \nCanvasHeight)

  EndWith
  
EndProcedure

Procedure WDD_Form_Show()
  PROCNAMEC()
  Protected d, sFirstLogicalDev.s, bLogicalDevFound
  Protected nItemIndex, nListIndex
  Protected nLeft
  Protected nLogicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
        If Len(sFirstLogicalDev) = 0
          sFirstLogicalDev = \sLogicalDev
        EndIf
        If grWDD\sLTLogicalDev = \sLogicalDev
          bLogicalDevFound = #True
          Break
        EndIf
      EndIf
    EndWith
  Next d
  If (bLogicalDevFound = #False) And (sFirstLogicalDev)
    grWDD\sLTLogicalDev = sFirstLogicalDev
    bLogicalDevFound = #True
  EndIf
  
  If bLogicalDevFound = #False
    ; no DMX output devices found
    ProcedureReturn
  EndIf
  
  If IsWindow(#WDD) = #False
    WDD_Form_Load()
  EndIf
  
  CompilerIf #c_new_gui
    nListIndex = -1
    nItemIndex = -1
    ComboBoxEx::ClearItems(WDD\cboLogicalDev)
    For d = 0 To grProd\nMaxLightingLogicalDev
      With grProd\aLightingLogicalDevs(d)
        If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
          nItemIndex + 1
          ComboBoxEx::AddItem(WDD\cboLogicalDev, ComboBoxEx::#LastItem, \sLogicalDev)
          ComboBoxEx::SetItemData(WDD\cboLogicalDev, nItemIndex,  d)
          If \sLogicalDev = grWDD\sLTLogicalDev
            nListIndex = nItemIndex
          EndIf
        EndIf
      EndWith
    Next d
    ComboBoxEx::SetState(WDD\cboLogicalDev, nListIndex)
    
    With WDD
      nLeft = GadgetX(\cboLogicalDev) + GadgetWidth(\cboLogicalDev) + 16
      ResizeGadget(\lblDisplayPref, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft = GadgetX(\lblDisplayPref) + GadgetWidth(\lblDisplayPref) + gnGap
      ResizeGadget(\cboDisplayPref, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ComboBoxEx::ClearItems(\cboDisplayPref)
      addGadgetItemWithData(\cboDisplayPref, Lang("DMX", "ValPercent"), #SCS_DMX_NOTATION_PERCENT)
      addGadgetItemWithData(\cboDisplayPref, Lang("DMX", "ValNum"), #SCS_DMX_NOTATION_0_255)
      setComboBoxWidth(\cboDisplayPref)
      nListIndex = indexForComboBoxData(\cboDisplayPref, grMemoryPrefs\nDMXDisplayPref, 0)
      ComboBoxEx::SetState(WDD\cboDisplayPref, nListIndex)
      nLeft = GadgetX(\cboDisplayPref) + GadgetWidth(\cboDisplayPref) + 16
    EndWith
  CompilerElse
    ClearGadgetItems(WDD\cboLogicalDev)
    For d = 0 To grProd\nMaxLightingLogicalDev
      With grProd\aLightingLogicalDevs(d)
        If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
          addGadgetItemWithData(WDD\cboLogicalDev, \sLogicalDev, d)
        EndIf
      EndWith
    Next d
    With WDD
      ; Logical Device
      If CountGadgetItems(\cboLogicalDev) > 0
        setComboBoxWidth(\cboLogicalDev, 40)
        nListIndex = indexForComboBoxRow(\cboLogicalDev, grWDD\sLTLogicalDev, 0)
        SGS(\cboLogicalDev, nListIndex)
      EndIf
      nLeft = GadgetX(\cboLogicalDev) + GadgetWidth(\cboLogicalDev) + 16
      ; Display Pref      
      ResizeGadget(\lblDisplayPref, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft = GadgetX(\lblDisplayPref) + GadgetWidth(\lblDisplayPref) + gnGap
      ResizeGadget(\cboDisplayPref, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ClearGadgetItems(\cboDisplayPref)
      addGadgetItemWithData(\cboDisplayPref, Lang("DMX", "ValPercent"), #SCS_DMX_NOTATION_PERCENT)
      addGadgetItemWithData(\cboDisplayPref, Lang("DMX", "ValNum"), #SCS_DMX_NOTATION_0_255)
      setComboBoxWidth(\cboDisplayPref)
      nListIndex = indexForComboBoxData(\cboDisplayPref, grMemoryPrefs\nDMXDisplayPref, 0)
      SGS(\cboDisplayPref, nListIndex)
      nLeft = GadgetX(\cboDisplayPref) + GadgetWidth(\cboDisplayPref) + 16
      ; Grid Type
      ResizeGadget(\lblGridType, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft = GadgetX(\lblGridType) + GadgetWidth(\lblGridType) + gnGap
      ResizeGadget(\cboGridType, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ClearGadgetItems(\cboGridType)
      addGadgetItemWithData(\cboGridType, Lang("DMX", "GridTypeUniverse"), #SCS_DMX_GRIDTYPE_UNIVERSE)
      addGadgetItemWithData(\cboGridType, Lang("DMX", "GridTypeAllFixtures"), #SCS_DMX_GRIDTYPE_ALL_FIXTURES)
      setComboBoxWidth(\cboGridType)      
      nListIndex = indexForComboBoxData(\cboGridType, grMemoryPrefs\nDMXGridType, 0)
      SGS(\cboGridType, nListIndex)
      nLeft = GadgetX(\cboGridType) + GadgetWidth(\cboGridType) + 16
      CompilerIf 1=2
        ResizeGadget(\mbgBackColor, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft = GadgetX(\mbgBackColor) + GadgetWidth(\mbgBackColor) + 16
        ResizeGadget(\chkShowGridLines, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        If grMemoryPrefs\bDMXShowGridLines
          SGS(\chkShowGridLines, #PB_Checkbox_Checked)
        Else
          SGS(\chkShowGridLines, #PB_Checkbox_Unchecked)
        EndIf
      CompilerEndIf
    EndWith
  CompilerEndIf
  
  With grWDD
    \nDMXDisplayControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, \sLTLogicalDev)
    If \nDMXDisplayControlPtr >= 0
      \nDMXSendDataBaseIndex = gaDMXControl(\nDMXDisplayControlPtr)\nDMXSendDataBaseIndex
    Else
      \nDMXSendDataBaseIndex = 0
    EndIf
    \bDMXDisplayActive = #True
    debugMsg(sProcName, "grWDD\nDMXDisplayControlPtr=" + \nDMXDisplayControlPtr + ", \nDMXSendDataBaseIndex=" + \nDMXSendDataBaseIndex + ", \bDMXDisplayActive=" + strB(\bDMXDisplayActive))
  EndWith
  
  WDD_Form_Resize()
  
  setWindowVisible(#WDD, #True)
  ; nb WDD_forceDisplayDMXSendData() must be called AFTER making sure the window is visible,
  ; because WDD_forceDisplayDMXSendData() will not do anything if the window is not visible.
  debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
  WDD_forceDisplayDMXSendData()
  
  SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsDMXDisplay, 1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WDD_Form_Resize()
  PROCNAMEC()
  Protected nReqdSCAWidth, nReqdSCAHeight, nReqdSCAInnerWidth, nReqdSCAInnerHeight
  
  With grWDD
    WDD_setCanvasSize() ; Added 8Nov2024
    ; nReqdSCAWidth = WindowWidth(#WDD) - GadgetX(WDD\scaDMXDisplay)
    nReqdSCAWidth = WindowWidth(#WDD) - 15
    nReqdSCAInnerWidth = GadgetWidth(WDD\cvsDMXDisplay)
    nReqdSCAHeight = WindowHeight(#WDD) - GadgetY(WDD\scaDMXDisplay) - \nSCABottomMargin
    If nReqdSCAWidth <> GadgetWidth(WDD\scaDMXDisplay) Or nReqdSCAHeight <> GadgetHeight(WDD\scaDMXDisplay)
      ResizeGadget(WDD\scaDMXDisplay, #PB_Ignore, #PB_Ignore, nReqdSCAWidth, nReqdSCAHeight)
      SetGadgetAttribute(WDD\scaDMXDisplay, #PB_ScrollArea_InnerWidth, nReqdSCAInnerWidth)
    EndIf
    SAW(#WMN) ; Added 18Nov2024 11.10.6bl Set focus back to the main window
  EndWith
  
EndProcedure

Procedure WDD_Form_Resized(bForceProcessing=#False)
  PROCNAMEC()
  Protected nWindowWidth, nWindowHeight
  Static nPrevWindowWidth, nPrevWindowHeight
  
  ; debugMsg0(sProcName, #SCS_START)
  
  If IsWindow(#WDD) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WDD
    nWindowWidth = WindowWidth(#WDD)
    nWindowHeight = WindowHeight(#WDD)
    If (nWindowWidth <> nPrevWindowWidth) Or (nWindowHeight <> nPrevWindowHeight) Or (bForceProcessing)
      nPrevWindowWidth = nWindowWidth
      nPrevWindowHeight = nWindowHeight
      WDD_Form_Resize()
    EndIf
  EndWith
  
EndProcedure

Procedure WDD_Form_Unload()
  PROCNAMEC()
  ; do not close window - just hide it and turn off updating. This is because the user may frequently want to display/hide this window.
  grWDD\bDMXDisplayActive = #False
  debugMsg(sProcName, "grWDD\bDMXDisplayActive=" + strB(grWDD\bDMXDisplayActive))
  setWindowVisible(#WDD, #False)
  SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsDMXDisplay, #False)
  gbDMXDisplayDisplayed = #False
EndProcedure

Procedure WDD_hideWindowIfDisplayed()
  PROCNAMEC()
  If IsWindow(#WDD)
    If grWDD\bDMXDisplayActive Or getWindowVisible(#WDD)
      grWDD\bDMXDisplayActive = #False
      debugMsg(sProcName, "grWDD\bDMXDisplayActive=" + strB(grWDD\bDMXDisplayActive))
      setWindowVisible(#WDD, #False)
      SetMenuItemState(#WMN_mnuView, #WMN_mnuMtrsDMXDisplay, #False)
    EndIf
  EndIf
EndProcedure

Procedure WDD_cboLogicalDev_Click()
  PROCNAMEC()
  Protected sLogicalDev.s
  Protected nLogicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  With grWDD
    CompilerIf #c_new_gui
      sLogicalDev = ComboBoxEx::GetText(WDD\cboLogicalDev)
    CompilerElse
      sLogicalDev = GGT(WDD\cboLogicalDev)
    CompilerEndIf
    debugMsg(sProcName, "sLogicalDev=" + sLogicalDev)
    If \sLTLogicalDev <> sLogicalDev
      \sLTLogicalDev = sLogicalDev
      \nDMXDisplayControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, sLogicalDev)
      If \nDMXDisplayControlPtr >= 0
        \nDMXSendDataBaseIndex = gaDMXControl(\nDMXDisplayControlPtr)\nDMXSendDataBaseIndex
      Else
        \nDMXSendDataBaseIndex = 0
      EndIf
      debugMsg(sProcName, "grWDD\nDMXDisplayControlPtr=" + \nDMXDisplayControlPtr + ", \nDMXSendDataBaseIndex=" + \nDMXSendDataBaseIndex)
      debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
      WDD_forceDisplayDMXSendData()
    EndIf
  EndWith
  
EndProcedure

Procedure WDD_cboDisplayPref_Click()
  PROCNAMEC()
  
  grMemoryPrefs\nDMXDisplayPref = getCurrentItemData(WDD\cboDisplayPref, 0)
  
  debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
  WDD_forceDisplayDMXSendData()
  
EndProcedure

Procedure WDD_cboGridType_Click()
  PROCNAMEC()
  
  grMemoryPrefs\nDMXGridType = getCurrentItemData(WDD\cboGridType, 0)
  
  WDD_setCanvasSize()
  debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
  WDD_forceDisplayDMXSendData()  
  
EndProcedure

Procedure WDD_chkShowGridLines_Click()
  PROCNAMEC()
  
  If GGS(WDD\chkShowGridLines) = #PB_Checkbox_Checked
    grMemoryPrefs\bDMXShowGridLines = 1
  Else
    grMemoryPrefs\bDMXShowGridLines = 0
  EndIf
  
  debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
  WDD_forceDisplayDMXSendData()
  
  If grProdForDevChgs\nProdId = grProd\nProdId
    WEP_repaintDMXTextColors()
  EndIf
  
EndProcedure

Procedure WDD_EventHandler()
  PROCNAMEC()
  Static qLastMoveWindowTime.q
  Protected qTimeNow
  
  With WDD
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WDD_Form_Unload()
        SAW(#WMN)
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #WDD_mnu_BackColor_Default, #WDD_mnu_BackColor_Picker
            WDD_mnuBackColor_Click(gnEventMenu)
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \cboGridType
            CBOCHG(WDD_cboGridType_Click())
            
          Case \cboDisplayPref
            CBOCHG(WDD_cboDisplayPref_Click())
            
          Case \cboLogicalDev
            CBOCHG(WDD_cboLogicalDev_Click())
            
          Case \chkShowGridLines
            CHKCHG(WDD_chkShowGridLines_Click())
            
          Case \cvsCloseIcon
            If gnEventType = #PB_EventType_LeftClick
              WDD_Form_Unload()
              SAW(#WMN)
            EndIf
            
          Case \cvsDMXDisplay
            ; ignore canvas events
            
          Case \cvsDragBar
            WDD_cvsDragBar_Event()
            
          Case \mbgBackColor
            WDD_mbgBackColor_Click()
            
          Case \scaDMXDisplay
            ; ignore events
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
      Case #PB_Event_SizeWindow
        WDD_Form_Resized()
        
      Case #PB_Event_MoveWindow
        ; Added 18Nov2024 11.10.6bl
        qTimeNow = ElapsedMilliseconds()
        If qTimeNow > qLastMoveWindowTime + 1000
          debugMsg(sProcName, "MoveWindow - calling SAM to reset WMN as active window")
          samAddRequest(#SCS_SAM_SET_WMN_AS_ACTIVE_WINDOW, 0, 0, 0, "", qTimeNow + 1000)
        EndIf
        qLastMoveWindowTime = qTimeNow
        ; End added 18Nov2024 11.10.6bl
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WDD_drawCloseIcon(bHovering=#False)
  Protected nWidth, nHeight, nBackColor, nFrontColor
  
  With WDD
    nWidth = GadgetWidth(\cvsCloseIcon)
    nHeight = GadgetHeight(\cvsCloseIcon)
    If bHovering
      nBackColor = #SCS_Red
      nFrontColor = #SCS_White
    Else
      nBackColor = $303030
      nFrontColor = #SCS_White
    EndIf
    If StartDrawing(CanvasOutput(\cvsCloseIcon))
      Box(0,0,nWidth,nHeight,nBackColor)
      LineXY(0, 3,  nWidth-11, 12, nFrontColor)
      LineXY(1, 3,  nWidth-10, 12, nFrontColor)
      LineXY(0, 12, nWidth-11, 3,  nFrontColor)
      LineXY(1, 12, nWidth-10, 3,  nFrontColor)
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure WDD_drawCanvases(bFirstTime=#False)
  PROCNAMECW(#WDD)
  Protected nWidth, nHeight
  Protected n
  
  With WDD
    nWidth = GadgetWidth(\cvsDragBar)
    nHeight = GadgetHeight(\cvsDragBar)
    If StartDrawing(CanvasOutput(\cvsDragBar))
      CompilerIf #c_new_gui
        Box(0,0,nWidth,nHeight,grUIColors\nTitleBackColor)
      CompilerElse
        Box(0,0,nWidth,nHeight,$303030)
      CompilerEndIf
      StopDrawing()
    EndIf
    
    If bFirstTime
      nWidth = GadgetWidth(\cvsCloseIcon)
      nHeight = GadgetHeight(\cvsCloseIcon)
      If StartDrawing(CanvasOutput(\cvsCloseIcon))
        Box(0,0,nWidth,nHeight,$303030)
        LineXY(0,3,nWidth-11,12,#SCS_White)
        LineXY(1,3,nWidth-10,12,#SCS_White)
        LineXY(0,12,nWidth-11,3,#SCS_White)
        LineXY(1,12,nWidth-10,3,#SCS_White)
        StopDrawing()
      EndIf
      
    EndIf
  EndWith
EndProcedure

Procedure WDD_cvsDragBar_Event()
  PROCNAMEC()
  Protected nDeltaX, nDeltaY
  Protected nNewLeft, nNewTop
  
  With grWDD
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        \nWindowStartLeft = WindowX(#WDD)
        \nWindowStartTop = WindowY(#WDD)
        \nDragBarStartX = DesktopMouseX()
        \nDragBarStartY = DesktopMouseY()
        \bDragBarMoving = #True
        
      Case #PB_EventType_MouseMove
        If \bDragBarMoving
          nDeltaX = \nDragBarStartX - DesktopMouseX()
          nDeltaY = \nDragBarStartY - DesktopMouseY()
          nNewLeft = \nWindowStartLeft - nDeltaX
          nNewTop = \nWindowStartTop - nDeltaY
          ; debugMsg(sProcName, "calling ResizeWindow(" + decodeWindow(#WDD) + ", " + nNewLeft + ", " + nNewTop + ", #PB_Ignore, #PB_Ignore)")
          ResizeWindow(#WDD, nNewLeft, nNewTop, #PB_Ignore, #PB_Ignore)
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bDragBarMoving = #False
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WDD_buildPopupMenu_BackColor()
  If scsCreatePopupMenu(#WDD_mnu_BackColor_Popup)
    scsMenuItem(#WDD_mnu_BackColor_Default, "mnuWDDBackColorDefault", "", #True)
    scsMenuItem(#WDD_mnu_BackColor_Picker, "mnuWDDBackColorPicker", "", #True)
  EndIf
EndProcedure

Procedure WDD_mbgBackColor_Click()
  DisplayPopupMenu(#WDD_mnu_BackColor_Popup, WindowID(#WDD))
EndProcedure

Procedure WDD_mnuBackColor_Click(nEventMenu)
  PROCNAMEC()
  Protected nOldColor, nNewColor
  
  With grMemoryPrefs
    Select nEventMenu
      Case #WDD_mnu_BackColor_Default
        \nDMXBackColor = -1
      Case #WDD_mnu_BackColor_Picker
        If \nDMXBackColor >= 0
          nOldColor = \nDMXBackColor
        Else
          nOldColor = #SCS_Very_Light_Grey
        EndIf
        nNewColor = ColorRequester(nOldColor)
        If nNewColor <> -1
          If nNewColor = #SCS_Very_Light_Grey
            \nDMXBackColor = -1
          Else
            \nDMXBackColor = nNewColor
          EndIf
        EndIf
    EndSelect
  EndWith
  With grWDD
    \nCanvasBackColor1 = WDD_getReqdCanvasBackColor()
    \nCanvasBackColor2 = RGB(Red(\nCanvasBackColor1)*92/100, Green(\nCanvasBackColor1)*92/100, Blue(\nCanvasBackColor1)*92/100)
  EndWith
  
  WDD_forceDisplayDMXSendData()
  If grProdForDevChgs\nProdId = grProd\nProdId
    WEP_repaintDMXTextColors()
  EndIf
  
EndProcedure

Procedure WDD_getReqdCanvasBackColor()
  Protected nReqdCanvasBackColor
  CompilerIf #c_dmx_display_drop_gridline_and_backcolor_choices = #False
    If grMemoryPrefs\nDMXBackColor >= 0
      nReqdCanvasBackColor = grMemoryPrefs\nDMXBackColor
    Else
      nReqdCanvasBackColor = #SCS_Very_Light_Grey
    EndIf
  CompilerElse
    nReqdCanvasBackColor = $DADADA ; Changed 28Nov2024 11.10.6bq - darker than #SCS_Very_Light_Grey but lighter than #SCS_Light_Grey - helps view white and amber values without being too dark
  CompilerEndIf
  ProcedureReturn nReqdCanvasBackColor
EndProcedure

Procedure WDD_displayDMXDisplayWindowIfReqd()
  PROCNAMEC()
  Protected d, bLightingDevFound
  
  If gbDMXDisplayDisplayed
    For d = 0 To grProd\nMaxLightingLogicalDev
      With grProd\aLightingLogicalDevs(d)
        If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
          bLightingDevFound = #True
          Break
        EndIf
      EndWith
    Next d
    If bLightingDevFound
      WDD_Form_Show()
    EndIf
  EndIf
EndProcedure

; EOF