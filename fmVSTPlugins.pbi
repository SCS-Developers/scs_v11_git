; File: fmVSTPlugins.pbi

EnableExplicit

Procedure WVP__EventHandler()
  PROCNAMEC()
  Protected nRow
  
  With WVP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WVP_Form_Unload()
        
      Case #PB_Event_Gadget
        If gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + ")")
          Select gnEventButtonId
            Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS
              Select gnEventGadgetNo
                Case \imgLibButtonTBS[0],  \imgLibButtonTBS[1], \imgLibButtonTBS[2], \imgLibButtonTBS[3]
                  WVP_imgLibButtonTBS_Click(gnEventButtonId)
                Case \imgDevButtonTBS[0], \imgDevButtonTBS[1]
                  WVP_imgDevButtonTBS_Click(gnEventButtonId)
              EndSelect
          EndSelect
          
        Else
          
          ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventType=" + decodeEventType(gnEventGadgetNo))
          Select gnEventGadgetNoForEvHdlr   
              
            Case \btnClose
              WVP_Form_Unload()
              
            Case \btnHelp
              displayHelpTopic("VST_Plugins.htm")
              
            Case \btnApplyVSTChgs
              WVP_btnApplyVSTChgs_Click()
              
            Case \btnCueOpen
              WVP_btnCueOpen_Click()
              
            Case \btnUndoVSTChgs
              WVP_btnUndoVSTChgs_Click()
              
            Case \btnLibVSTPluginLoad[0]
              BTNCLICK(WVP_btnLibVSTPluginLoad_Click(gnEventGadgetArrayIndex))               
              
            Case \cboDevLogicalDev
              CBOCHG(WVP_cboDevLogicalDev_Click())
              
            Case #SCS_G4EH_VP_CBODEVVSTPLUGIN ; \cboDevVSTPlugin
              CBOCHG(WVP_cboDevVSTPlugin_Click(gnEventGadgetArrayIndex))
              
            Case \chkOnlyCuesWithAPlugin
              CHKCHG(WVP_chkOnlyCuesWithAPlugin_Click())
              
            Case #SCS_G4EH_VP_CHKDEVBYPASSVST ; \chkDevBypassVST
              CHKCHG(WVP_chkDevBypassVST_Click(gnEventGadgetArrayIndex)) 
              
            Case #SCS_G4EH_VP_CHKDEVVIEWVST ; \chkDevViewVST
              CHKCHG(WVP_chkDevViewVST_Click(gnEventGadgetArrayIndex)) 
              
            Case \cntCueVSTPlugins, \cntDevSidebar, \cntDevVSTPlugins, \cntLibSideBar, \cntLibVSTInfo, \cntLibVSTPlugins
              ; no action
              
            Case \grdCueVSTPlugins
              Select gnEventType
                Case #PB_EventType_LeftClick
                  WVP_grdCueVSTPlugins_Click()
                Case #PB_EventType_LeftDoubleClick
                  WVP_grdCueVSTPlugins_DblClick()
              EndSelect
              
            Case #SCS_G4EH_VP_LBLDEVVSTORDER ; \lblDevVSTOrder
              If gnEventType = #PB_EventType_Focus
                WVP_lblDevVSTOrder_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case #SCS_G4EH_VP_LBLLIBVSTNO ; \lblLibVSTNo
              If gnEventType = #PB_EventType_Focus
                WVP_lblLibVSTNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \pnlVSTPlugins
              If gnEventType = #PB_EventType_Change
                WVP_pnlVSTPlugins_Click()
              EndIf

            Case #SCS_G4EH_VP_TXTDEVVSTCOMMENT ; \txtDevVSTComment
              Select gnEventType
                Case #PB_EventType_Focus
                  WVP_setCurrentDevVSTInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WVP_txtDevVSTComment_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case #SCS_G4EH_VP_TXTLIBVSTPLUGINNAME ; \txtLibVSTPluginName
              Select gnEventType
                Case #PB_EventType_Focus
                  WVP_setCurrentLibVSTPlugin(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WVP_txtLibVSTPluginName_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Default
              debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
              
          EndSelect
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WVP_Form_Show()
  PROCNAMEC()
  Protected d, bFound
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WVP) = #False
    createfmVSTPlugins()
    With WVP
      If IsGadget(\grdCueVSTPlugins)
        ; remove existing columns
        removeAllGadgetColumns(\grdCueVSTPlugins)
        AddGadgetColumn(\grdCueVSTPlugins, 0, grText\sTextCue, 70)
        AddGadgetColumn(\grdCueVSTPlugins, 1, grText\sTextDescription, 200)
        AddGadgetColumn(\grdCueVSTPlugins, 2, Lang("VST", "VSTPlugin"), 200)
      EndIf
    EndWith
  EndIf
  setFormPosition(#WVP, @grVSTPluginsWindow)
  
  grVSTHold = grVST
  
  With grWVP
    If \sDevCurrentLogicalDev
      For d = 0 To grProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD ; Changed 15Dec2022 11.10.0ac
        If grProd\aAudioLogicalDevs(d)\sLogicalDev = \sDevCurrentLogicalDev
          bFound = #True
          Break
        EndIf
      Next d
    EndIf
    If bFound = #False
      \sDevCurrentLogicalDev = grAudioLogicalDevsDef\sLogicalDev
    EndIf
    \nLibCurrentLineIndex = 0
    \nDevCurrentLineIndex = 0
    ; force tabs to be (re-)populated
    \bLibTabPopulated = #False
    \bDevTabPopulated = #False
    \bWindowActive = #True
    \bChanged = #False
  EndWith
  
  WVP_pnlVSTPlugins_Click()
  
  WVP_checkForChanges()
  
  setWindowVisible(#WVP, #True)
  SetActiveWindow(#WVP)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WVP)
    getFormPosition(#WVP, @grVSTPluginsWindow)
    If grWVP\bChanged
      nResponse = scsMessageRequester(GWT(#WVP), Lang("Common", "ApplyChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
      Select nResponse
        Case #PB_MessageRequester_Cancel
          ProcedureReturn
        Case #PB_MessageRequester_Yes
          WVP_btnApplyVSTChgs_Click()
        Case #PB_MessageRequester_No
          WVP_btnUndoVSTChgs_Click()
      EndSelect
    EndIf
    setWindowVisible(#WVP, #False)
  EndIf
  grWVP\bWindowActive = #False
  
  WPL_hideWindowIfDisplayed(#SCS_VST_HOST_DEV) ; hide VST plugin editor window if displaying a 'device' plugin
  
  SAW(#WMN)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_hideWindowIfDisplayed()
  PROCNAMEC()
  Protected rWVP.tyWVP
  
  If IsWindow(#WVP)
    setWindowVisible(#WVP, #False)
    grWVP = rWVP ; clear grWVP
  EndIf
  
EndProcedure

Procedure WVP_displayDevVSTPluginInfo(sLogicalDev.s)
  PROCNAMEC()
  Protected n, nPluginIndex, nLineIndex, nListIndex, nVSTOrder, nReqdViewState, nReqdBypassState, bEnabled
  Protected sReqdViewState.s
  Protected rDevVSTPlugin.tyDevVSTPlugin
  
  debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev)
  
  For nLineIndex = 0 To grLicInfo\nMaxVSTDevPlugin
    nVSTOrder = nLineIndex + 1
    With WVP\aDevVSTPlugin(nLineIndex)
      nPluginIndex = -1
      nReqdViewState = #PB_Checkbox_Unchecked
      sReqdViewState = "#PB_Checkbox_Unchecked"
      nReqdBypassState = #PB_Checkbox_Unchecked
      For n = 0 To grVST\nMaxDevVSTPlugin
        If (grVST\aDevVSTPlugin(n)\sDevVSTLogicalDev = sLogicalDev) And (grVST\aDevVSTPlugin(n)\nDevVSTOrder = nVSTOrder)
          nPluginIndex = n
          Break
        EndIf
      Next n
      If nPluginIndex >= 0
        rDevVSTPlugin = grVST\aDevVSTPlugin(nPluginIndex)
      Else
        rDevVSTPlugin = grDevVSTPluginDef
      EndIf
      nListIndex = indexForComboBoxRow(\cboDevVSTPlugin, rDevVSTPlugin\sDevVSTPluginName, 0)
;       debugMsg(sProcName, "nLineIndex=" + nLineIndex + ", nPluginIndex=" + nPluginIndex + ", rDevVSTPlugin\sDevVSTPluginName=" + rDevVSTPlugin\sDevVSTPluginName +
;                           ", \nDevVSTOrder=" + rDevVSTPlugin\nDevVSTOrder + ", \bDevVSTBypass=" + strB(rDevVSTPlugin\bDevVSTBypass) + ", \sDevVSTComment=" + rDevVSTPlugin\sDevVSTComment)
      SGS(\cboDevVSTPlugin, nListIndex)
      If nListIndex = 0
        setVisibleAndEnabled(\chkDevViewVST, #False)
        setVisibleAndEnabled(\chkDevBypassVST, #False)
        setVisibleAndEnabled(\txtDevVSTComment, #False)
        SGT(\txtDevVSTComment, "")
      Else
        setVisible(\chkDevViewVST, #True)
        setVisible(\chkDevBypassVST, #True)
        setVisible(\txtDevVSTComment, #True)
        If gbEditorAndOptionsLocked
          bEnabled = #False
        Else
          bEnabled = #True
        EndIf
        setEnabled(\chkDevViewVST, bEnabled)
        setEnabled(\chkDevBypassVST, bEnabled)
        setEnabled(\txtDevVSTComment, bEnabled)
        If (grWPL\bPluginShowing) And (grWPL\nVSTHost = #SCS_VST_HOST_DEV) And (grWPL\nHostPluginIndex = nPluginIndex)
          nReqdViewState = #PB_Checkbox_Checked
          sReqdViewState = "#PB_Checkbox_Checked"
        EndIf
        If rDevVSTPlugin\bDevVSTBypass
          nReqdBypassState = #PB_Checkbox_Checked
        EndIf
        SGT(\txtDevVSTComment, rDevVSTPlugin\sDevVSTComment)
      EndIf
      debugMsg(sProcName, "calling SGS(WVP\aDevVSTPlugin(" + nLineIndex + ")\chkDevViewVST, " + sReqdViewState + ")")
      SGS(\chkDevViewVST, nReqdViewState)
      SGS(\chkDevBypassVST, nReqdBypassState)
    EndWith
  Next nLineIndex
  
EndProcedure

Procedure WVP_setCurrentDevVSTInfo(nLineIndex)
  PROCNAMEC()
  Protected nReqdLineIndex, nDisplayedLineIndex, n
  Protected bUpEnabled, bDownEnabled
  
  If nLineIndex >= 0
    nReqdLineIndex = nLineIndex
  Else
    ; negative nLineIndex means set nReadLineIndex to the first populated entry, or to 0 if no populated entries found
    nReqdLineIndex = 0
    For n = 0 To grLicInfo\nMaxVSTDevPlugin
      If GGT(WVP\aDevVSTPlugin(n)\cboDevVSTPlugin)
        nReqdLineIndex = n
        Break
      EndIf
    Next n
  EndIf
;   nDisplayedLineIndex = grWVP\nDevCurrentLineIndex
;   
;   If (nDisplayedLineIndex >= 0) And (nDisplayedLineIndex <> nReqdLineIndex)
;     SetGadgetColor(WVP\aDevVSTPlugin(nDisplayedLineIndex)\lblDevVSTOrder, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
;   EndIf
;   If nReqdLineIndex >= 0
;     SetGadgetColor(WVP\aDevVSTPlugin(nReqdLineIndex)\lblDevVSTOrder, #PB_Gadget_BackColor, #SCS_Light_Green)
;   EndIf
  For n = 0 To grLicInfo\nMaxVSTDevPlugin
    If n = nReqdLineIndex
      SetGadgetColor(WVP\aDevVSTPlugin(n)\lblDevVSTOrder, #PB_Gadget_BackColor, #SCS_Light_Green)
    Else
      SetGadgetColor(WVP\aDevVSTPlugin(n)\lblDevVSTOrder, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
  Next n
  
  grWVP\nDevCurrentLineIndex = nReqdLineIndex
  WVP_setTBSButtons(nReqdLineIndex)
  
  If GGT(WVP\aDevVSTPlugin(nReqdLineIndex)\cboDevVSTPlugin)
    ; plugin selected
    If nReqdLineIndex > 0
      bUpEnabled = #True
    EndIf
    If nReqdLineIndex < grLicInfo\nMaxVSTDevPlugin
      bDownEnabled = #True
    EndIf
  EndIf
  setEnabled(WVP\imgDevButtonTBS[0], bUpEnabled)
  setEnabled(WVP\imgDevButtonTBS[1], bDownEnabled)
  
EndProcedure

Procedure WVP_populateCboLogicalDev()
  PROCNAMEC()
  Protected d
  
  ClearGadgetItems(WVP\cboDevLogicalDev)
  For d = 0 To grProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD ; Changed 15Dec2022 11.10.0ac
    With grProd\aAudioLogicalDevs(d)
      If Trim(\sLogicalDev)
        addGadgetItemWithData(WVP\cboDevLogicalDev, Trim(\sLogicalDev), d)
      EndIf
    EndWith
  Next d
  
EndProcedure

Procedure WVP_lblLibVSTNo_Focus(nLineIndex)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  WVP_setCurrentLibVSTPlugin(nLineIndex)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_cboDevLogicalDev_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", GGT(WVP\cboDevLogicalDev)=" + GGT(WVP\cboDevLogicalDev))
  
  With grWVP
    \sDevCurrentLogicalDev = GGT(WVP\cboDevLogicalDev)
    WVP_displayDevVSTPluginInfo(\sDevCurrentLogicalDev)
    WVP_setCurrentDevVSTInfo(-1)
    SAG(-1)
  EndWith
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_lblDevVSTOrder_Focus(nLineIndex)
  PROCNAMEC()
  
  WVP_setCurrentDevVSTInfo(nLineIndex)
  
EndProcedure

Procedure WVP_showDevVSTViewBypassAndComment(nLineIndex, bShowVST)
  PROCNAMEC()
  Protected bPluginFound, n, bMyShowVST
  Protected sPluginName.s, sLogicalDev.s, nVSTOrder, nLibPluginIndex, nDevPluginIndex
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex + ", bShowVST=" + strB(bShowVST))
  
  If bShowVST
    sLogicalDev = grWVP\sDevCurrentLogicalDev
    nVSTOrder = nLineIndex + 1
    nDevPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
    If nDevPluginIndex >= 0
      sPluginName = grVST\aDevVSTPlugin(nDevPluginIndex)\sDevVSTPluginName
      If sPluginName
        nLibPluginIndex = VST_getLibPluginIndex(sPluginName)
        If nLibPluginIndex >= 0
          CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
            For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
              If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64
                bPluginFound = #True
                Break
              EndIf
            Next n
          CompilerElse
            For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
              If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32
                bPluginFound = #True
                Break
              EndIf
            Next n
          CompilerEndIf
        EndIf
        If bPluginFound
          bMyShowVST = bShowVST
        EndIf
      EndIf ; EndIf sPluginName
    EndIf ; EndIf nDevPluginIndex >= 0
  EndIf ; EndIf bShowVST
  
  With WVP\aDevVSTPlugin(nLineIndex)
    setVisibleAndEnabled(\chkDevViewVST, bMyShowVST)
    setVisibleAndEnabled(\chkDevBypassVST, bMyShowVST)
    setVisibleAndEnabled(\txtDevVSTComment, bMyShowVST)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure  

Procedure WVP_chkDevBypassVST_Click(nLineIndex)
  PROCNAMEC()
  Protected nPluginIndex, nVSTOrder, sLogicalDev.s, bReqdPypass
  
  debugMsg(sProcName, #SCS_START)
  
  WVP_setCurrentDevVSTInfo(nLineIndex)
  
  sLogicalDev = grWVP\sDevCurrentLogicalDev
  nVSTOrder = nLineIndex + 1
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    If GGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevBypassVST) = #PB_Checkbox_Checked
      bReqdPypass = #True
    EndIf
    If grVST\aDevVSTPlugin(nPluginIndex)\bDevVSTBypass <> bReqdPypass
      grVST\aDevVSTPlugin(nPluginIndex)\bDevVSTBypass = bReqdPypass
      VST_setDevPluginBypass(sLogicalDev, nVSTOrder)
    EndIf
    SAG(-1)
  EndIf
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_chkDevViewVST_Click(nLineIndex)
  PROCNAMEC()
  Protected bShowEditor
  Protected sLogicalDev.s, nVSTOrder, nPluginIndex, nVSTHandle.l
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  WVP_setCurrentDevVSTInfo(nLineIndex)
  
  If GGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevViewVST) = #PB_Checkbox_Checked
    bShowEditor = #True
  EndIf
  
  sLogicalDev = grWVP\sDevCurrentLogicalDev
  nVSTOrder = nLineIndex + 1
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    nVSTHandle = grVST\aDevVSTPlugin(nPluginIndex)\nDevVSTHandle
    If bShowEditor
      If grWPL\bPluginShowing
        debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
        WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False)
      EndIf
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_DEV, " + nPluginIndex + ", " + decodeHandle(nVSTHandle) + ", #True)")
      WPL_showVSTEditor(#SCS_VST_HOST_DEV, nPluginIndex, nVSTHandle, #True)
    Else
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(nVSTHandle) + ", #False)")
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, nVSTHandle, #False)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_cboDevVSTPlugin_Click(nLineIndex)
  PROCNAMEC()
  Protected sOldPluginName.s, sNewPluginName.s, bPluginLoaded
  Protected nDevNo, sLogicalDev.s, n, nVSTOrder, nPluginIndex
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  WVP_setCurrentDevVSTInfo(nLineIndex)
  
  sLogicalDev = grWVP\sDevCurrentLogicalDev
  nVSTOrder = nLineIndex + 1
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder + ", nPluginIndex=" + nPluginIndex)
  
  With grVST\aDevVSTPlugin(nPluginIndex)
    sOldPluginName = \sDevVSTPluginName
    sNewPluginName = Trim(GGT(WVP\aDevVSTPlugin(nLineIndex)\cboDevVSTPlugin))
    debugMsg(sProcName, "sOldPluginName=" + sOldPluginName + ", sNewPluginName=" + sNewPluginName)
    If sNewPluginName = sOldPluginName
      ; no change so exit immediately
      ProcedureReturn
    EndIf
    
    If (grWPL\bPluginShowing) And (grWPL\nVSTHost = #SCS_VST_HOST_DEV) And (grWPL\nHostPluginIndex = nPluginIndex)
      ; if the viewer of the current plugin is showing then close the viewer
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False)
    EndIf
    
    ; clear any existing plugin for this device and processing order
    VST_clearDevPlugin(sLogicalDev, nVSTOrder)
    
    ; Change (or clear) the plugin
    \sDevVSTPluginName = sNewPluginName
    
    If sNewPluginName
      bPluginLoaded = VST_loadDevVSTPlugin(sLogicalDev, nVSTOrder)
    EndIf
    debugMsg(sProcName, "bPluginLoaded=" + strB(bPluginLoaded))
    If bPluginLoaded
      WVP_showDevVSTViewBypassAndComment(nLineIndex, #True)
      ; nb \bVSTBypass has already been actioned for the plugin itself within VST_loadDevVSTPlugin()
      If \bDevVSTBypass
        SGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevBypassVST, #PB_Checkbox_Checked)
      Else
        SGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevBypassVST, #PB_Checkbox_Unchecked)
      EndIf
    Else
      WVP_showDevVSTViewBypassAndComment(nLineIndex, #True)
      SGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevBypassVST, #PB_Checkbox_Unchecked)
      debugMsg(sProcName, "calling SGS(WVP\aDevVSTPlugin(" + nLineIndex + ")\chkDevViewVST, #PB_Checkbox_Unchecked)")
      SGS(WVP\aDevVSTPlugin(nLineIndex)\chkDevViewVST, #PB_Checkbox_Unchecked)
    EndIf
    
  EndWith
  
  If bPluginLoaded
    SAG(WVP\aDevVSTPlugin(nLineIndex)\txtDevVSTComment)
  EndIf
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_populateCboDevVSTPlugins()
  PROCNAMEC()
  Protected nLineIndex, sVSTPluginName.s, nPluginNo
  
  debugMsg(sProcName, #SCS_START)
  
  For nLineIndex = 0 To grLicInfo\nMaxVSTDevPlugin
    With WVP\aDevVSTPlugin(nLineIndex)
      ClearGadgetItems(\cboDevVSTPlugin)
      AddGadgetItem(\cboDevVSTPlugin, -1, "")
      For nPluginNo = 0 To grVST\nMaxLibVSTPlugin
        sVSTPluginName = Trim(grVST\aLibVSTPlugin(nPluginNo)\sLibVSTPluginName)
        If sVSTPluginName
          AddGadgetItem(\cboDevVSTPlugin, -1, sVSTPluginName)
        EndIf
      Next nPluginNo
    EndWith
  Next nLineIndex
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_imgLibButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected nLineIndex, nMaxLineIndex, nNewLineIndex, sPluginName.s
  Protected i, j, k, d
  
  debugMsg(sProcName, #SCS_START + ", nButtonId=" + nButtonId)
  
  nLineIndex = grWVP\nLibCurrentLineIndex
  nMaxLineIndex = #SCS_MAX_VST_LIB_PLUGIN
  
  If nLineIndex < 0 Or nLineIndex > nMaxLineIndex
    ; shouldn't happen!
    debugMsg(sProcName, "exiting because nLineIndex=" + nLineIndex)
    ProcedureReturn
  EndIf
  
  nNewLineIndex = -1
  
  Select nButtonId
      
    Case #SCS_STANDARD_BTN_MOVE_UP
      WVP_swapLibPlugins(nLineIndex, nLineIndex-1)
      nNewLineIndex = nLineIndex - 1
      
    Case #SCS_STANDARD_BTN_MOVE_DOWN
      WVP_swapLibPlugins(nLineIndex, nLineIndex+1)
      nNewLineIndex = nLineIndex + 1
      
    Case #SCS_STANDARD_BTN_PLUS
      ; move this and following plugins down one position
      WVP_insertLibPlugin(nLineIndex)
      nNewLineIndex = nLineIndex
      
    Case #SCS_STANDARD_BTN_MINUS
      ; can only delete this plugin if it is not being used in devices or cues
      sPluginName = Trim(grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName)
      If sPluginName
        For d = 0 To grVST\nMaxDevVSTPlugin
          If LCase(grVST\aDevVSTPlugin(d)\sDevVSTPluginName) = LCase(sPluginName)
            scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveVSTPlugin2", sPluginName, grVST\aDevVSTPlugin(d)\sDevVSTLogicalDev), #PB_MessageRequester_Error)
            ProcedureReturn
          EndIf
        Next d
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            With aSub(j)
              If \bSubTypeF
                k = aSub(j)\nFirstAudIndex
                If k >= 0
                  If LCase(aAud(k)\sVSTPluginName) = LCase(sPluginName)
                    scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveVSTPlugin", sPluginName, getCueLabel(i)), #PB_MessageRequester_Error)
                    ProcedureReturn
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex 
            EndWith 
          Wend      
        Next i
      EndIf
      WVP_removeLibPlugin(nLineIndex)
      nNewLineIndex = nLineIndex
      If Len(grVST\aLibVSTPlugin(nNewLineIndex)\sLibVSTPluginName) = 0
        nNewLineIndex - 1
      EndIf
  EndSelect
  
  WVP_populateLibTab()
  WVP_setCurrentLibVSTPlugin(nNewLineIndex)
  If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewLineIndex >= 0
    SAG(WVP\btnLibVSTPluginLoad[nNewLineIndex])
  EndIf
  
  grWVP\bDevTabPopulated = #False ; Added 8Mar2022 11.9.1ah
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_imgDevButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected sLogicalDev.s, nLineIndex, nVSTOrder, nPluginIndex, nNewVSTOrder
  Protected nOtherPluginIndex
  
  debugMsg(sProcName, #SCS_START + ", nButtonId=" + nButtonId + ", gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo))
  
  sLogicalDev = grWVP\sDevCurrentLogicalDev
  nLineIndex = grWVP\nDevCurrentLineIndex
  If (sLogicalDev) And (nLineIndex >= 0)
    ; should be #True
    nVSTOrder = nLineIndex + 1
    nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
    Select nButtonId
      Case #SCS_STANDARD_BTN_MOVE_UP  ; #SCS_STANDARD_BTN_MOVE_UP
        nNewVSTOrder = nVSTOrder - 1
      Case #SCS_STANDARD_BTN_MOVE_DOWN  ; #SCS_STANDARD_BTN_MOVE_DOWN
        nNewVSTOrder = nVSTOrder + 1
    EndSelect
    debugMsg(sProcName, "nVSTOrder=" + nVSTOrder + ", nNewVSTOrder=" + nNewVSTOrder)
    If nNewVSTOrder > 0
      ; should be #True
      nOtherPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nNewVSTOrder)
      grVST\aDevVSTPlugin(nPluginIndex)\nDevVSTOrder = nNewVSTOrder
      If nOtherPluginIndex >= 0
        grVST\aDevVSTPlugin(nOtherPluginIndex)\nDevVSTOrder = nVSTOrder
      EndIf
      nLineIndex = nNewVSTOrder - 1
      WVP_displayDevVSTPluginInfo(sLogicalDev)
      WVP_setCurrentDevVSTInfo(nLineIndex)
      SAG(-1)
    EndIf
  EndIf
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_txtDevVSTComment_Validate(nLineIndex)
  PROCNAMEC()
  Protected nPluginIndex, nVSTOrder, sLogicalDev.s, sComment.s
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  WVP_setCurrentDevVSTInfo(nLineIndex)
  
  sLogicalDev = grWVP\sDevCurrentLogicalDev
  nVSTOrder = nLineIndex + 1
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    sComment = Trim(GGT(WVP\aDevVSTPlugin(nLineIndex)\txtDevVSTComment))
    debugMsg(sProcName, "sComment=" + #DQUOTE$ + sComment + #DQUOTE$)
    grVST\aDevVSTPlugin(nPluginIndex)\sDevVSTComment = sComment
  EndIf
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WVP_btnApplyVSTChgs_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grVSTHold = grVST
  grWVP\bChanged = #False
  setEnabled(WVP\btnApplyVSTChgs, #False)
  setEnabled(WVP\btnUndoVSTChgs, #False)
  
  grWVP\bReadyToSaveToCueFile = #True
  setFileSave(#False)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_btnUndoVSTChgs_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grWPL
    If (\bPluginShowing) And (\nVSTHost = #SCS_VST_HOST_DEV)
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, \nVSTHandleForPluginShowing, #False)
    EndIf
  EndWith
  
  grVST = grVSTHold
  
  VST_loadAllDevVSTPlugins()
  
  WVP_Form_Show()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_btnLibVSTPluginLoad_Click(nLineIndex)
  PROCNAMEC()
  Protected sOldVSTFilePath.s, sNewVSTFilePath.s, sVST_DLL_Name.s, sVSTExistingPluginName.s
  Protected bUserEnteredPluginName, sUserEnteredPluginName.s
  Protected rVSTInfo.BASS_VST_INFO, sTitle.s, sErrorMsg.s
  Protected nDLLType, nReqdDLLType, n
  Static sDefaultPath.s
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  WVP_setCurrentLibVSTPlugin(nLineIndex)
  
  ; set the default path if required, using the path of the last plugin in the array,
  ; or the program directory if no plugins currently registered
  If Len(sDefaultPath) = 0
    For n = 0 To grVST\nMaxLibVSTPlugin
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64
          sDefaultPath = GetPathPart(grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64)
        EndIf
      CompilerElse
        If grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32
          sDefaultPath = GetPathPart(grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32)
        EndIf
      CompilerEndIf
    Next n
    If Len(sDefaultPath) = 0
      sDefaultPath = GetUserDirectory(#PB_Directory_Programs)
    EndIf
  EndIf
  debugMsg(sProcName, "sDefaultPath=" + #DQUOTE$ + sDefaultPath + #DQUOTE$)
  
  ; Load the File Name & Path of the VST Plugin
  ; NOTE: The following changed 5Mar2022 11.9.1ag, as vst3 is not supported by BASS_VST (see BASS Forum posting https://www.un4seen.com/forum/?topic=18807.msg134608#msg134608)
  ; sNewVSTFilePath = OpenFileRequester(Lang("WVP","LoadTitle"), sDefaultPath, Lang("VST","VSTPlugins") + " (*.dll,*.vst2,*.vst3)|*.dll;*.vst2;*.vst3", 0)
  sNewVSTFilePath = OpenFileRequester(Lang("WVP","LoadTitle"), sDefaultPath, Lang("VST","VSTPlugins") + " (*.dll,*.vst2)|*.dll;*.vst2", 0)
  debugMsg(sProcName, "sNewVSTFilePath=" + #DQUOTE$ + sNewVSTFilePath + #DQUOTE$)
  
  ; Check if a file path is provided
  If sNewVSTFilePath = ""
    ProcedureReturn
  EndIf
  
  nDLLType = getDLLType(sNewVSTFilePath)
  debugMsg2(sProcName, "getDLLType(" + #DQUOTE$ + sNewVSTFilePath + #DQUOTE$ + ")", nDLLType)
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    nReqdDLLType = 64
  CompilerElse
    nReqdDLLType = 32
  CompilerEndIf
  If nDLLType <> nReqdDLLType
    sTitle = Lang("VST", "lblVSTPlugin")
    sErrorMsg = LangPars("VST", "WrongType", Str(nReqdDLLType))
    scsMessageRequester(sTitle, sErrorMsg, #PB_MessageRequester_Warning)
    ProcedureReturn 
  EndIf
  
  If VST_getInfo(sNewVSTFilePath, @rVSTInfo)
    sVST_DLL_Name = Trim(PeekS(@rVSTInfo\effectName,-1,#PB_Ascii))
    debugMsg(sProcName, "sVST_DLL_Name=" + sVST_DLL_Name)
    If sVST_DLL_Name = ""
      sVST_DLL_Name = Trim(GetFilePart(sNewVSTFilePath, #PB_FileSystem_NoExtension))
    EndIf
    debugMsg(sProcName, "rVSTInfo\isInstrument=" + rVSTInfo\isInstrument)
    If rVSTInfo\isInstrument = 1
      VST_showWarning(#SCS_VST_PLUGIN_ERROR_INSTRUMENT, sVST_DLL_Name, "", sNewVSTFilePath)
      ProcedureReturn 
    EndIf
  Else
    sTitle = Lang("VST", "lblVSTPlugin")
    sErrorMsg = LangPars("VST", "CannotLoad", #DQUOTE$ + sNewVSTFilePath + #DQUOTE$, gsVSTError)
    scsMessageRequester(sTitle, sErrorMsg, #PB_MessageRequester_Warning)
    ProcedureReturn 
  EndIf
  
  sDefaultPath = GetPathPart(sNewVSTFilePath)
  
  ; Check if User has already entered a Plugin Name
  bUserEnteredPluginName = #False
  sUserEnteredPluginName = Trim(GGT(WVP\txtLibVSTPluginName[nLineIndex]))
  If sUserEnteredPluginName
    bUserEnteredPluginName = #True
  EndIf 
  
  ; Check if current loading plugin already exists
  If sVST_DLL_Name <> sUserEnteredPluginName ; ie either user-entered or existing displayed plugin name
    If VST_checkPluginInList(sVST_DLL_Name)
      debugMsg(sProcName, "VST_checkPluginInList(" + #DQUOTE$ + sVST_DLL_Name + #DQUOTE$ + ") returned #True")
      VST_showWarning(#SCS_VST_PLUGIN_ERROR_ALREADY_EXISTS, sVST_DLL_Name)
      ProcedureReturn
    EndIf
  EndIf
  
  ; Populate the correct control with the pathway and filename
  With WVP
    
    If nLineIndex > ArraySize(grVST\aLibVSTPlugin())
      ReDim grVST\aLibVSTPlugin(nLineIndex)
    EndIf
    
    ; Populate the File Path Text
    ; NB sNewVSTFilePath may be blank
    SGT(\txtLibVSTPluginFile[nLineIndex], sNewVSTFilePath)
    ; Populate the Live Data Global File Path
    
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      sOldVSTFilePath = grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile64
    CompilerElse
      sOldVSTFilePath = grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile32
    CompilerEndIf
    
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile64 = sNewVSTFilePath
    CompilerElse
      grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile32 = sNewVSTFilePath
    CompilerEndIf
    
    sVSTExistingPluginName = Trim(grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName)
    If sVSTExistingPluginName = ""
      If bUserEnteredPluginName
        sVST_DLL_Name = sUserEnteredPluginName
      EndIf
      SGT(\txtLibVSTPluginName[nLineIndex], sVST_DLL_Name)
      grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName = sVST_DLL_Name
    Else
      grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName = sVSTExistingPluginName
    EndIf
    
    If nLineIndex > grVST\nMaxLibVSTPlugin
      grVST\nMaxLibVSTPlugin = nLineIndex
    EndIf
    
  EndWith
  debugMsg(sProcName, "calling WVP_populateLibTab()")
  WVP_populateLibTab() ; nb also enables/disables the plugin name fields
  WVP_setCurrentLibVSTPlugin(nLineIndex)
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_txtLibVSTPluginName_Validate(nLineIndex)
  PROCNAMEC()
  Protected sOldPluginName.s, sNewPluginName.s, sPluginFile.s
  Protected sVST_DLL_Name.s, n
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    sPluginFile = grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile64
  CompilerElse
    sPluginFile = grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginFile32
  CompilerEndIf
  
  If nLineIndex < 0 
    WVP_setCurrentLibVSTPlugin(0)
  Else
    WVP_setCurrentLibVSTPlugin(nLineIndex)
  EndIf
  With WVP
    If nLineIndex >= 0
      sOldPluginName = grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName
      sNewPluginName = Trim(GGT(\txtLibVSTPluginName[nLineIndex]))
      If sNewPluginName <> sOldPluginName
        If (Len(sNewPluginName) = 0) And (Len(sPluginFile) > 0)
          scsMessageRequester(grText\sTextValErr, LangPars("Errors", "MustBeEntered", GGT(\lblLibVSTPluginName)), #PB_MessageRequester_Error)
          SAG(\txtLibVSTPluginName[nLineIndex])
          ProcedureReturn #False
        EndIf
        For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
          If n <> nLineIndex
            If LCase(sNewPluginName) = LCase(Trim(GGT(\txtLibVSTPluginName[n])))
              scsMessageRequester(grText\sTextValErr, LangPars("Errors", "AlreadyExists", GGT(\lblLibVSTPluginName)) + " " + sNewPluginName, #PB_MessageRequester_Error)
              SAG(\txtLibVSTPluginName[nLineIndex])
              ProcedureReturn #False
            EndIf
          EndIf
        Next n
        grVST\aLibVSTPlugin(nLineIndex)\sLibVSTPluginName = sNewPluginName
        VST_changePluginName(sOldPluginName, sNewPluginName)
      EndIf
      If getEnabled(WVP\btnLibVSTPluginLoad[nLineIndex])
        SAG(WVP\btnLibVSTPluginLoad[nLineIndex])
      EndIf
    EndIf
  EndWith
  
  WVP_checkForChanges()
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WVP_setCurrentLibVSTPlugin(nLineIndex)
  PROCNAMEC()
;   Protected nDisplayedLineIndex
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nLineIndex=" + nLineIndex)
  
;   nDisplayedLineIndex = grWVP\nLibCurrentLineIndex
;   
;   If (nDisplayedLineIndex >= 0) And (nDisplayedLineIndex <> nLineIndex)
;     SetGadgetColor(WVP\lblLibVSTNo[nDisplayedLineIndex], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
;   EndIf
;   If nLineIndex >= 0
;     SetGadgetColor(WVP\lblLibVSTNo[nLineIndex], #PB_Gadget_BackColor, #SCS_Light_Green)
;   EndIf
  For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
    If n = nLineIndex
      SetGadgetColor(WVP\lblLibVSTNo[n], #PB_Gadget_BackColor, #SCS_Light_Green)
    Else
      SetGadgetColor(WVP\lblLibVSTNo[n], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
  Next n
  
  grWVP\nLibCurrentLineIndex = nLineIndex
  WVP_setTBSButtons(nLineIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_populateLibTab()
  PROCNAMEC()
  Protected n, sVSTPluginName.s, sVSTPluginFile.s
  Protected bPluginsFound
  
  debugMsg(sProcName, #SCS_START)
  
  With WVP
    
    For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
      SGT(\txtLibVSTPluginFile[n], "")
      SGT(\txtLibVSTPluginName[n], "")
      setEnabled(\txtLibVSTPluginName[n], #False)
    Next n
    
    For n = 0 To grVST\nMaxLibVSTPlugin
      CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
        sVSTPluginFile = grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64
      CompilerElse
        sVSTPluginFile = grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32
      CompilerEndIf
      sVSTPluginName = grVST\aLibVSTPlugin(n)\sLibVSTPluginName
      If sVSTPluginFile
        debugMsg(sProcName, "sVSTPluginFile=" + #DQUOTE$ + sVSTPluginFile + #DQUOTE$ + ", sVSTPluginName=" + #DQUOTE$ + sVSTPluginName + #DQUOTE$)
      EndIf
      
      If (sVSTPluginFile <> "") And (sVSTPluginName <> "")
        SGT(\txtLibVSTPluginFile[n], sVSTPluginFile)
        scsToolTip(\txtLibVSTPluginFile[n], GGT(\txtLibVSTPluginFile[n]))
        SGT(\txtLibVSTPluginName[n], sVSTPluginName)
        
      ElseIf (sVSTPluginName <> "") And (sVSTPluginFile = "")
        If Not grVST\aLibVSTPlugin(n)\bLibWarningShown
          VST_showWarning(#SCS_VST_PLUGIN_ERROR_FILE_LOCATION, sVSTPluginName)
        EndIf
        grVST\aLibVSTPlugin(n)\bLibWarningShown = #True
        SGT(\txtLibVSTPluginName[n], sVSTPluginName)
        
      ElseIf (sVSTPluginFile = "") And (sVSTPluginName = "") 
        SGT(\txtLibVSTPluginFile[n], "")
        SGT(\txtLibVSTPluginName[n], "")
        
      EndIf
      
      If sVSTPluginFile
        setEnabled(\txtLibVSTPluginName[n], #True)
      EndIf
      ; nb if sVSTPluginFile is blank, do NOT clear plugin name as the (valid) plugin file may have been set under a different #PB_Compiler_Processor
      ; however, still leave the plugin name field disabled (as set at the start of this procedure) as it would still be valid for the original #PB_Compiler_Processor run
      
    Next n
    
  EndWith
  
  For n = 0 To grVST\nMaxLibVSTPlugin
    If grVST\aLibVSTPlugin(n)\sLibVSTPluginName
      bPluginsFound = #True
    EndIf
  Next n
  
  If bPluginsFound
    debugMsg(sProcName, "calling WQF_populatecboVSTPlugin()")
    WQF_populatecboVSTPlugin()
  EndIf
  
  WVP_setLibVSTLoadButtons() ; Added 2Mar2022 11.9.1ad
  
  grWVP\bLibTabPopulated = #True
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_populateDevTab()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  WVP_populateCboLogicalDev()
  WVP_populateCboDevVSTPlugins()
  
  grWVP\bDevTabPopulated = #True
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_setLibVSTLoadButtons()
  PROCNAMEC()
  Protected n, bEnabled, nEnabled
  Protected sVSTPluginFile.s, sTooltip.s
  Protected bLibVSTPluginUsed
  Protected i, j, k
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To #SCS_MAX_VST_LIB_PLUGIN
    ; debugMsg0(sProcName, "n=" + n)
    bLibVSTPluginUsed = #False
    If n <= grVST\nMaxLibVSTPlugin
      If grVST\aLibVSTPlugin(n)\sLibVSTPluginName
        debugMsg(sProcName, "grVST\aLibVSTPlugin(" + n + ")\sLibVSTPluginName=" + #DQUOTE$ + grVST\aLibVSTPlugin(n)\sLibVSTPluginName + #DQUOTE$)
        For i = 1 To gnLastCue
          If aCue(i)\bSubTypeF
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubTypeF
                k = aSub(j)\nFirstAudIndex
                If k >= 0
                  If aAud(k)\sVSTPluginName
                    debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sVSTPluginName=" + #DQUOTE$ + aAud(k)\sVSTPluginName + #DQUOTE$)
                    If aAud(k)\sVSTPluginName = grVST\aLibVSTPlugin(n)\sLibVSTPluginName
                      bLibVSTPluginUsed = #True
                      debugMsg(sProcName, "bLibVSTPluginUsed=" + strB(bLibVSTPluginUsed))
                      Break 2 ; Break j, i (no loop for k as sub type F contains only one aAud
                    EndIf
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf ; EndIf aCue(i)\bSubTypeF
        Next i
      EndIf ; EndIf grVST\aLibVSTPlugin(n)\sLibVSTPluginName
    EndIf ; EndIf n < grVST\nMaxLibVSTPlugin
    ; debugMsg0(sProcName, "bLibVSTPluginUsed=" + strB(bLibVSTPluginUsed))
    
    With WVP
      If bLibVSTPluginUsed
        bEnabled = #False
      Else
        bEnabled = #True
      EndIf
      sVSTPluginFile = Trim(GGT(\txtLibVSTPluginFile[n]))
      SetGadgetColor(\txtLibVSTPluginFile[n], #PB_Gadget_FrontColor, #Black)
      scsToolTip(\txtLibVSTPluginFile[n], sVSTPluginFile)
      If gbEditorAndOptionsLocked = #False
        If Len(sVSTPluginFile) = 0
          bEnabled = #True
          nEnabled + 1 ; for debugging only
        ElseIf FileExists(sVSTPluginFile) = #False
          bEnabled = #True
          nEnabled + 1 ; for debugging only
          SetGadgetColor(\txtLibVSTPluginFile[n], #PB_Gadget_FrontColor, #Red)
          scsToolTip(\txtLibVSTPluginFile[n], LangPars("Errors", "FileNotFound", sVSTPluginFile))
        EndIf
      EndIf
      setEnabled(\btnLibVSTPluginLoad[n], bEnabled)
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END + ", nEnabled=" + nEnabled)
  
EndProcedure

Procedure WVP_displayLibTab()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  WVP_setCurrentLibVSTPlugin(grWVP\nLibCurrentLineIndex)
  WVP_setLibVSTLoadButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_displayDevTab()
  PROCNAMEC()
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nListIndex = indexForComboBoxRow(WVP\cboDevLogicalDev, grWVP\sDevCurrentLogicalDev, 0)
  SGS(WVP\cboDevLogicalDev, nListIndex)
  WVP_cboDevLogicalDev_Click()
  
  WVP_setCurrentDevVSTInfo(grWVP\nDevCurrentLineIndex)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_grdCueVSTPlugins_Click()
  PROCNAMEC()
  Protected nAudPtr, nCuePtr, sCue.s, nReqdWidth, bEnabled
  
  With WVP
    nAudPtr = getCurrentItemData(\grdCueVSTPlugins, -1)
    If nAudPtr >= 0
      nCuePtr = aAud(nAudPtr)\nCueIndex
      sCue = getCueLabel(nCuePtr)
      bEnabled = #True
    Else
      sCue = "?"
    EndIf
    SetGadgetText(\btnCueOpen, LangPars("WVP", "btnCueOpen", sCue))
    nReqdWidth = GadgetWidth(\btnCueOpen, #PB_Gadget_RequiredSize)
    If nReqdWidth > GadgetWidth(\btnCueOpen)
      ResizeGadget(\btnCueOpen, #PB_Ignore, #PB_Ignore, nReqdWidth, #PB_Ignore)
    EndIf
    If gbEditorAndOptionsLocked
      bEnabled = #False
    EndIf
    setEnabled(\btnCueOpen, bEnabled)
  EndWith
EndProcedure

Procedure WVP_grdCueVSTPlugins_DblClick()
  PROCNAMEC()
  
  WVP_grdCueVSTPlugins_Click()
  If getEnabled(WVP\btnCueOpen)
    WVP_btnCueOpen_Click()
  EndIf
  
EndProcedure

Procedure WVP_displayCueTab(bSetFocusOnFirstCue=#True, bSetActiveGadget=#True)
  PROCNAMEC()
  Protected i, j, k
  Protected sLine.s, sPluginName.s, bOnlyCuesWithAPlugin
  
  debugMsg(sProcName, #SCS_START)
  
  With WVP
    If GGS(\chkOnlyCuesWithAPlugin) = #PB_Checkbox_Checked
      bOnlyCuesWithAPlugin = #True
    EndIf
    
    ClearGadgetItems(\grdCueVSTPlugins)
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeF
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If (aSub(j)\bSubTypeF) And (aSub(j)\bSubPlaceHolder = #False)
            k = aSub(j)\nFirstAudIndex
            If k >= 0
              sPluginName = Trim(aAud(k)\sVSTPluginName)
              If (sPluginName) Or (bOnlyCuesWithAPlugin = #False)
                sLine = getAudLabel(k) + Chr(10) + aAud(k)\sAudDescr + Chr(10) + sPluginName
                addGadgetItemWithData(\grdCueVSTPlugins, sLine, k)
              EndIf
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    Next i
    If bSetFocusOnFirstCue
      If CountGadgetItems(\grdCueVSTPlugins) > 0
        ; select the first row
        SGS(\grdCueVSTPlugins, 0)
      EndIf
      WVP_grdCueVSTPlugins_Click()
      If bSetActiveGadget
        SAG(\grdCueVSTPlugins)
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_refreshCuePluginsTab(bSetActiveGadget=#True)
  PROCNAMEC()
  Protected nAudPtr, nListIndex
  
  With WVP
    nAudPtr = getCurrentItemData(\grdCueVSTPlugins)
    WVP_displayCueTab(#False, bSetActiveGadget)
    If nAudPtr >= 0
      nListIndex = indexForGadgetItemData(\grdCueVSTPlugins, nAudPtr, 0)
    EndIf
    SGS(\grdCueVSTPlugins, nListIndex)
    WVP_grdCueVSTPlugins_Click()
    If bSetActiveGadget
      SAG(\grdCueVSTPlugins)
    EndIf
  EndWith
EndProcedure

Procedure WVP_refreshWindow(bSetActiveGadget=#True)
  PROCNAMEC()
  Protected nActiveWindow
  
  nActiveWindow = GetActiveWindow()
  If IsWindow(#WVP)
    If IsGadget(WVP\pnlVSTPlugins)
      If getCurrentItemData(WVP\pnlVSTPlugins) = #SCS_WVP_TAB_CUE_PLUGINS
        debugMsg(sProcName, "calling WVP_refreshCuePluginsTab()")
        WVP_refreshCuePluginsTab(bSetActiveGadget)
      EndIf
    EndIf
  EndIf
  If GetActiveWindow() <> nActiveWindow
    debugMsg(sProcName, "calling SAW(" + decodeWindow(nActiveWindow) + ")")
    SAW(nActiveWindow)
  EndIf
EndProcedure

Procedure WVP_chkOnlyCuesWithAPlugin_Click()
  WVP_refreshCuePluginsTab()
EndProcedure

Procedure WVP_btnCueOpen_Click()
  PROCNAMEC()
  Protected nAudPtr, nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  nAudPtr = getCurrentItemData(WVP\grdCueVSTPlugins)
  If nAudPtr >= 0
    nCuePtr = aAud(nAudPtr)\nCueIndex
    debugMsg(sProcName, "calling callEditor(" + getCueLabel(nCuePtr) + ")")
    callEditor(nCuePtr)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_pnlVSTPlugins_Click()
  PROCNAMEC()
  
  With grWVP
    \nDisplayedTab = getCurrentItemData(WVP\pnlVSTPlugins, #SCS_WVP_TAB_LIBRARY)
    Select \nDisplayedTab
      Case #SCS_WVP_TAB_LIBRARY
        If \bLibTabPopulated = #False
          WVP_populateLibTab()
        EndIf
        WVP_displayLibTab()
        
      Case #SCS_WVP_TAB_DEV_PLUGINS
        If \bDevTabPopulated = #False
          WVP_populateDevTab()
        EndIf
        WVP_displayDevTab()
        
      Case #SCS_WVP_TAB_CUE_PLUGINS
        WVP_displayCueTab()
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WVP_setTBSButtons(Index)
  PROCNAMEC()
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsDevice, sToolTipInsDevice.s
  Protected bEnableDelDevice, sToolTipDelDevice.s
  Protected nLastItem, nMaxItem, sItemName.s, bItemNamePresent
  Protected n
  Protected Dim nGadgetNo(3)
  Static sToolTipUp.s, sToolTipDown.s, sToolTipIns.s, sToolTipDel.s, sVSTPlugin.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If bStaticLoaded = #False
    ; populate static strings
    sVSTPlugin = Lang("VST", "VSTPlugin")
    ; do not use LangPars() for the tooltip strings as $1 will be replaced by the current line's plugin name
    sToolTipUp = Lang("Btns", "btnMoveUpTT")
    sToolTipDown = Lang("Btns", "btnMoveDownTT")
    sToolTipIns = ReplaceString(Lang("Btns", "btnInsTT"), "$2", sVSTPlugin) ; the 'insert' tooltip includes $2 for the insertion type
    sToolTipDel = Lang("Btns", "btnDelTT")
    bStaticLoaded = #True
  EndIf
  
  nLastItem = -1
  
  Select grWVP\nDisplayedTab
    Case #SCS_WVP_TAB_LIBRARY
      debugMsg(sProcName, "grWVP\nDisplayedTab=#SCS_WVP_TAB_LIBRARY")
      For n = 0 To 3
        nGadgetNo(n) = WVP\imgLibButtonTBS[n]
      Next n
      If Index >= 0
        nMaxItem = #SCS_MAX_VST_LIB_PLUGIN
        If Index <= grVST\nMaxLibVSTPlugin
          sItemName = Trim(grVST\aLibVSTPlugin(Index)\sLibVSTPluginName)
        EndIf
        For n = 0 To grVST\nMaxLibVSTPlugin
          If Trim(grVST\aLibVSTPlugin(n)\sLibVSTPluginName)
            nLastItem = n
          EndIf
        Next n
      EndIf
      
    Case #SCS_WVP_TAB_DEV_PLUGINS
      debugMsg(sProcName, "grWVP\nDisplayedTab=#SCS_WVP_TAB_DEV_PLUGINS")
      
    Default
      debugMsg(sProcName, "grWVP\nDisplayedTab=" + grWVP\nDisplayedTab)
      
  EndSelect
  
  If Index >= 0
    ; debugMsg(sProcName, "sItemName=" + sItemName + ", nLastItem=" + Str(nLastItem))
    If sItemName
      bItemNamePresent = #True
    Else
      bItemNamePresent = #False
    EndIf
    
    If (Index > 0) And (Index <= nLastItem)
      bEnableMoveUp = #True
      sToolTipMoveUp = ReplaceString(sToolTipUp, "$1", sItemName)
    EndIf
    If Index < nLastItem
      bEnableMoveDown = #True
      sToolTipMoveDown = ReplaceString(sToolTipDown, "$1", sItemName)
    EndIf
    If bItemNamePresent
      If (nLastItem < nMaxItem)
        bEnableInsDevice = #True
        sToolTipInsDevice = ReplaceString(sToolTipIns, "$1", sItemName)
      EndIf
      If (Index <= nLastItem)
        bEnableDelDevice = #True
        sToolTipDelDevice = ReplaceString(sToolTipDel, "$1", sItemName)
      EndIf
    EndIf
  EndIf
  
  If nGadgetNo(0) <> 0
    setEnabled(nGadgetNo(0), bEnableMoveUp)
    scsToolTip(nGadgetNo(0), sToolTipMoveUp)
    setEnabled(nGadgetNo(1), bEnableMoveDown)
    scsToolTip(nGadgetNo(1), sToolTipMoveDown)
    setEnabled(nGadgetNo(2), bEnableInsDevice)
    scsToolTip(nGadgetNo(2), sToolTipInsDevice)
    setEnabled(nGadgetNo(3), bEnableDelDevice)
    scsToolTip(nGadgetNo(3), sToolTipDelDevice)
  EndIf
  
EndProcedure

Procedure WVP_swapLibPlugins(nOrigVSTNo, nOtherVSTNo)
  PROCNAMEC()
  Protected rHoldLibVSTPlugin.tyLibVSTPlugin
  
  debugMsg(sProcName, #SCS_START + ", nOrigVSTNo=" + nOrigVSTNo + ", nOtherVSTNo=" + nOtherVSTNo)
  
  With grVST
    rHoldLibVSTPlugin = \aLibVSTPlugin(nOrigVSTNo)
    \aLibVSTPlugin(nOrigVSTNo) = \aLibVSTPlugin(nOtherVSTNo)
    \aLibVSTPlugin(nOtherVSTNo) = rHoldLibVSTPlugin
  EndWith
  
EndProcedure

Procedure WVP_insertLibPlugin(nVSTNo)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nVSTNo=" + nVSTNo)
  
  With grVST
    \nMaxLibVSTPlugin + 1
    If \nMaxLibVSTPlugin > ArraySize(\aLibVSTPlugin())
      debugMsg(sProcName, "calling ReDim \aLibVSTPlugin(" + \nMaxLibVSTPlugin + ")")
      ReDim \aLibVSTPlugin(\nMaxLibVSTPlugin)
    EndIf
    For n = \nMaxLibVSTPlugin To (nVSTNo+1) Step -1
      \aLibVSTPlugin(n) = \aLibVSTPlugin(n-1)
    Next n
    \aLibVSTPlugin(nVSTNo) = grLibVSTPluginDef
  EndWith

  WVP_populateLibTab()
  
EndProcedure

Procedure WVP_removeLibPlugin(nVSTNo)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nVSTNo=" + nVSTNo)
  
  With grVST
    For n = nVSTNo To \nMaxLibVSTPlugin-1  
      \aLibVSTPlugin(n) = \aLibVSTPlugin(n+1)
    Next n
    If \nMaxLibVSTPlugin >= 0
      ; nb should be #True
      \aLibVSTPlugin(\nMaxLibVSTPlugin) = grLibVSTPluginDef
      \nMaxLibVSTPlugin - 1
    EndIf
  EndWith
  
  grWVP\bDevTabPopulated = #False ; Added 8Mar2022 11.9.1ah
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WVP_checkForChanges()
  PROCNAMEC()
  Protected nChanged, n1, n2
  
  If grVST\nMaxLibVSTPlugin <> grVSTHold\nMaxLibVSTPlugin
    nChanged = 1
  ElseIf grVST\nMaxDevVSTPlugin <> grVSTHold\nMaxDevVSTPlugin
    nChanged = 2
  EndIf
  If nChanged = 0
    For n1 = 0 To grVST\nMaxLibVSTPlugin
      If grVST\aLibVSTPlugin(n1)\sLibVSTPluginName <> grVSTHold\aLibVSTPlugin(n1)\sLibVSTPluginName
        nChanged = 11
      ElseIf grVST\aLibVSTPlugin(n1)\sLibVSTPluginFile64 <> grVSTHold\aLibVSTPlugin(n1)\sLibVSTPluginFile64
        nChanged = 12
      ElseIf grVST\aLibVSTPlugin(n1)\sLibVSTPluginFile32 <> grVSTHold\aLibVSTPlugin(n1)\sLibVSTPluginFile32
        nChanged = 13
      EndIf
      If nChanged <> 0
        Break
      EndIf
    Next n1
  EndIf
  If nChanged = 0
    For n1 = 0 To grVST\nMaxDevVSTPlugin
      If grVST\aDevVSTPlugin(n1)\sDevVSTLogicalDev <> grVSTHold\aDevVSTPlugin(n1)\sDevVSTLogicalDev
        nChanged = 21
      ElseIf grVST\aDevVSTPlugin(n1)\nDevVSTOrder <> grVSTHold\aDevVSTPlugin(n1)\nDevVSTOrder
        nChanged = 22
      ElseIf grVST\aDevVSTPlugin(n1)\sDevVSTPluginName <> grVSTHold\aDevVSTPlugin(n1)\sDevVSTPluginName
        nChanged = 23
      ElseIf grVST\aDevVSTPlugin(n1)\bDevVSTBypass <> grVSTHold\aDevVSTPlugin(n1)\bDevVSTBypass
        nChanged = 24
      ElseIf grVST\aDevVSTPlugin(n1)\sDevVSTComment <> grVSTHold\aDevVSTPlugin(n1)\sDevVSTComment
        nChanged = 25
      ElseIf grVST\aDevVSTPlugin(n1)\nDevVSTProgram <> grVSTHold\aDevVSTPlugin(n1)\nDevVSTProgram
        nChanged = 26
      ElseIf grVST\aDevVSTPlugin(n1)\nDevVSTMaxParam <> grVSTHold\aDevVSTPlugin(n1)\nDevVSTMaxParam
        nChanged = 27
      EndIf
      If nChanged <> 0
        Break
      EndIf
      For n2 = 0 To grVST\aDevVSTPlugin(n1)\nDevVSTMaxParam
        If grVST\aDevVSTPlugin(n1)\aDevVSTParam(n2)\fVSTParamValue <> grVSTHold\aDevVSTPlugin(n1)\aDevVSTParam(n2)\fVSTParamValue
          nChanged = 31
        ElseIf grVST\aDevVSTPlugin(n1)\aDevVSTParam(n2)\nVSTParamIndex <> grVSTHold\aDevVSTPlugin(n1)\aDevVSTParam(n2)\nVSTParamIndex
          nChanged = 32
        ElseIf grVST\aDevVSTPlugin(n1)\aDevVSTParam(n2)\fVSTParamDefaultValue <> grVSTHold\aDevVSTPlugin(n1)\aDevVSTParam(n2)\fVSTParamDefaultValue
          nChanged = 33
        EndIf
        If nChanged <> 0
          Break 2
        EndIf
      Next n2
      If grVST\aDevVSTPlugin(n1)\rDevVSTChunk\nByteSize <> grVSTHold\aDevVSTPlugin(n1)\rDevVSTChunk\nByteSize
        nChanged = 41
      ElseIf grVST\aDevVSTPlugin(n1)\rDevVSTChunk\sChunkData <> grVSTHold\aDevVSTPlugin(n1)\rDevVSTChunk\sChunkData
        nChanged = 42
      ElseIf grVST\aDevVSTPlugin(n1)\rDevVSTChunk\sChunkMagic <> grVSTHold\aDevVSTPlugin(n1)\rDevVSTChunk\sChunkMagic
        nChanged = 43
      EndIf
      If nChanged <> 0
        Break
      EndIf
    Next n1
  EndIf
  If nChanged <> 0
    ; debugMsg(sProcName, "nChanged=" + nChanged)
    grWVP\bChanged = #True
  Else
    grWVP\bChanged = #False
  EndIf
  
  setEnabled(WVP\btnApplyVSTChgs, grWVP\bChanged)
  setEnabled(WVP\btnUndoVSTChgs, grWVP\bChanged)
  
  ProcedureReturn grWVP\bChanged
  
EndProcedure

Procedure WVP_setViewCheckboxes()
  PROCNAMEC()
  Protected n, nReqdViewState, nPluginIndex, sLogicalDev.s, nVSTOrder, sReqdViewState.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWPL
    If (\bPluginShowing) And (\nVSTHost = #SCS_VST_HOST_DEV)
      debugMsg(sProcName, "grWPL\bPluginShowing=#True, \nVSTHost=#SCS_VST_HOST_DEV, \nHostPluginIndex=" + \nHostPluginIndex + ", grWVP\sDevCurrentLogicalDev=" + grWVP\sDevCurrentLogicalDev)
    EndIf
    sLogicalDev = grWVP\sDevCurrentLogicalDev
    For n = 0 To #SCS_MAX_VST_DEV_PLUGIN
      nReqdViewState = #PB_Checkbox_Unchecked
      sReqdViewState = "#PB_Checkbox_Unchecked"
      If (\bPluginShowing) And (\nVSTHost = #SCS_VST_HOST_DEV)
        nVSTOrder = n + 1
        nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
        If \nHostPluginIndex = nPluginIndex
          nReqdViewState = #PB_Checkbox_Checked
          sReqdViewState = "#PB_Checkbox_Checked"
        EndIf
      EndIf
      debugMsg(sProcName, "n=" + n + ", nReqdViewState=" + sReqdViewState)
      If GGS(WVP\aDevVSTPlugin(n)\chkDevViewVST) <> nReqdViewState
        debugMsg(sProcName, "calling SGS(WVP\aDevVSTPlugin(" + n + ")\chkDevViewVST, " + sReqdViewState + ")")
        SGS(WVP\aDevVSTPlugin(n)\chkDevViewVST, nReqdViewState)
      EndIf
    Next n
  EndWith
  
EndProcedure

; EOF
