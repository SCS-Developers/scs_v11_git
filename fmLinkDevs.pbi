; File: fmLinkDevs.pbi

EnableExplicit

Procedure WLD_setButtons()
  PROCNAMEC()
  Protected d, sLogicalDev.s, nItemIndex, bSelectAll, bClearAll
  
  With WLD
    nItemIndex = -1
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      sLogicalDev = aAud(\nLinkDevAudPtr)\sLogicalDev[d]
      If sLogicalDev
        nItemIndex + 1
        If GetGadgetItemState(\grdLinkDevs, nItemIndex) & #PB_ListIcon_Checked
          bClearAll = #True
        Else
          bSelectAll = #True
        EndIf
      EndIf
    Next d
    setEnabled(\btnSelectAll, bSelectAll)
    setEnabled(\btnClearAll, bClearAll)
  EndWith
  
EndProcedure

Procedure WLD_grdLinkDevs_LeftClick()
  PROCNAMEC()
  Protected d, sLogicalDev.s, nItemIndex

  With WLD
    nItemIndex = -1
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      sLogicalDev = aAud(\nLinkDevAudPtr)\sLogicalDev[d]
      If sLogicalDev
        nItemIndex + 1
        If GetGadgetItemState(\grdLinkDevs, nItemIndex) & #PB_ListIcon_Checked
          \bDeviceSelected[d] = #True
        Else
          \bDeviceSelected[d] = #False
        EndIf
        \bChanges = #True
      EndIf
    Next d
    WLD_setButtons()
  EndWith
  
EndProcedure

Procedure WLD_loadGrid()
  PROCNAMEC()
  Protected d, sLogicalDev.s, nItemIndex
  
  With WLD
    ClearGadgetItems(\grdLinkDevs)
    nItemIndex = -1
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      sLogicalDev = aAud(\nLinkDevAudPtr)\sLogicalDev[d]
      If sLogicalDev
        nItemIndex + 1
        AddGadgetItem(\grdLinkDevs, nItemIndex, sLogicalDev)
        If \bDeviceSelected[d]
          SetGadgetItemState(\grdLinkDevs, nItemIndex, #PB_ListIcon_Checked)
        EndIf
      EndIf
    Next d
    ; The following line commented out as autoFitGridCol() doesn't currently (Apr2024) allow for the width of a vertical scrollbar
    ; so the width of this column is specifically set in createfmLinkDevs()
    ; autoFitGridCol(\grdLinkDevs, 1) ; autofit logical device column
    SGS(\grdLinkDevs, -1) ; This ensures no line in the grid is highlighted or partially highlighted
  EndWith
  
  WLD_setButtons()
  
EndProcedure

Procedure WLD_Form_Show(pSubPtr, pCaller, nParentWindow)
  PROCNAMECS(pSubPtr)
  Protected d, sTitle.s
  
  debugMsg(sProcName, #SCS_START)
  
  If (IsWindow(#WLD) = #False) Or (gaWindowProps(#WLD)\nParentWindow <> nParentWindow)
    createfmLinkDevs(nParentWindow)
  EndIf
  setFormPosition(#WLD, @grLinkDevsWindow)
  setWindowModal(#WLD, #True)
  
  With WLD
    \bChanges = #False
    \nLinkDevSubPtr = pSubPtr
    \nParentWindow = nParentWindow
    \nCaller = pCaller ; 1 = called from fmEditQF; 2 = called from fmMain (for cue panels, etc)
    sTitle = getSubLabel(\nLinkDevSubPtr) + " " + aSub(\nLinkDevSubPtr)\sSubDescr
    SGT(\txtTitle, sTitle)
    If aSub(\nLinkDevSubPtr)\bSubTypeF
      \nLinkDevAudPtr = aSub(\nLinkDevSubPtr)\nFirstAudIndex
      For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        \bDeviceSelected[d] = aAud(\nLinkDevAudPtr)\bDeviceSelected[d]
      Next d
    ElseIf aSub(\nLinkDevSubPtr)\bSubTypeL
      ; TBD
    EndIf
  EndWith
  
  WLD_loadGrid()
  setWindowVisible(#WLD, #True)
  
EndProcedure

Procedure WLD_Form_Unload()
  PROCNAMEC()
  Protected nResponse
  
  If WLD\bChanges
    nResponse = scsMessageRequester(GWT(#WLD), Lang("Common", "SaveChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    If nResponse = #PB_MessageRequester_Cancel
      debugMsg(sProcName, "nResponse = Cancel")
      ProcedureReturn #False
    ElseIf nResponse = #PB_MessageRequester_Yes
      debugMsg(sProcName, "nResponse = Yes")
      WLD_applyChanges()
    EndIf
    WLD\bChanges = #False
  EndIf
  
  getFormPosition(#WLD, @grLinkDevsWindow, #True)
  unsetWindowModal(#WLD)
  scsCloseWindow(#WLD)
  
EndProcedure

Procedure WLD_Form_Resized()
  PROCNAMEC()
  Protected nHeight, nTop
  
  If IsWindow(#WLD) = #False
    ; appears this procedure can be called after the window has been closed
    ProcedureReturn
  EndIf
  
  With WLD
    ; nHeight and nTop as per createfmLinkDevs()
    nHeight = WindowHeight(#WLD) - GadgetY(\grdLinkDevs) - (gnBtnHeight) - 16
    ResizeGadget(\grdLinkDevs, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
    nTop = GadgetY(\grdLinkDevs) + GadgetHeight(\grdLinkDevs) + 8
    ResizeGadget(\btnOK, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    ResizeGadget(\btnCancel, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
  EndWith
  
EndProcedure

Procedure WLD_btnSelectAll_Click()
  Protected d
  
  With aAud(WLD\nLinkDevAudPtr)
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      If \sLogicalDev[d]
        WLD\bDeviceSelected[d] = #True
      Else
        WLD\bDeviceSelected[d] = #False
      EndIf
    Next d
  EndWith
  WLD\bChanges = #True
  WLD_loadGrid()
  
EndProcedure

Procedure WLD_btnClearAll_Click()
  Protected d
  
  With aAud(WLD\nLinkDevAudPtr)
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      WLD\bDeviceSelected[d] = #False
    Next d
  EndWith
  WLD\bChanges = #True
  WLD_loadGrid()
  
EndProcedure

Procedure WLD_applyChanges()
  PROCNAMEC()
  Protected nAudPtr, d
  
  nAudPtr = WLD\nLinkDevAudPtr
  With aAud(nAudPtr)
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      \bDeviceSelected[d] = WLD\bDeviceSelected[d]
    Next d
    setDeviceInitialTotalVolWorksIfReqd(nAudPtr)
    If \bAudTypeF And nAudPtr = nEditAudPtr
      WQF_displaySub(\nSubIndex)
    EndIf
    PNL_loadDispPanels()
  EndWith
  
;   Protected n
;   With aAud(nAudPtr)
;     For n = 0 To 1
;       debugMsg0(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\fDeviceTotalVolWork[" + n + "]=" + StrF(\fDeviceTotalVolWork[n],2) +
;                            ", \fBVLevel[" + n + "]=" + StrF(\fBVLevel[n],2) + ", \fCueTotalVolNow[" + n + "]=" + StrF(\fCueInputVolNow[n],2) +
;                            ", \fCueVolNow[" + n + "]=" + StrF(\fCueVolNow[n],2))
;     Next n
;   EndWith
  
  listLinkedDevsForAud(nAudPtr)
  
  WLD\bChanges = #False
  
EndProcedure

Procedure WLD_btnOK_Click()
  PROCNAMEC()
  
  WLD_applyChanges()
  WLD_Form_Unload()
  
EndProcedure

Procedure WLD_EventHandler()
  PROCNAMEC()
  
  With WLD
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WLD_Form_Unload()
        
      Case #PB_Event_SizeWindow
        WLD_Form_Resized()
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel
            WLD_Form_Unload()
            
          Case \btnClearAll
            WLD_btnClearAll_Click()
            
          Case \btnOK
            WLD_btnOK_Click()
            
          Case \btnSelectAll
            WLD_btnSelectAll_Click()
            
          Case \grdLinkDevs
            If gnEventType = #PB_EventType_LeftClick
              WLD_grdLinkDevs_LeftClick()
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF