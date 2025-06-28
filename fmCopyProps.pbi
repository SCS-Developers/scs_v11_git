; File: fmCopyProps.pbi

EnableExplicit

Procedure WCP_Form_Unload()
  getFormPosition(#WCP, @grCopyPropsWindow)
  unsetWindowModal(#WCP)
  scsCloseWindow(#WCP)
EndProcedure

Procedure WCP_copyPropsForF()
  PROCNAMEC()
  Protected d, n, m, sPropCode.s, sPropDesc.s
  Protected sUndoDescr.s
  Protected bError
  Protected nAudPtr, nSubPtr
  Protected rAud.tyAud
  Protected nMaxStartTime
  Protected nMinEndTime, nMaxEndTime
  Protected nMaxFadeInTime, nMaxFadeOutTime
  Protected l2
  
  debugMsg(sProcName, #SCS_START)
  
  nAudPtr = aSub(grCopyProps\nCFSubPtr)\nFirstAudIndex
  If nAudPtr >= 0
    rAud = aAud(nAudPtr)
    grCopyProps\sCopyTitle = LangPars("WCP", "CopyTitle", getAudLabel(nAudPtr), getAudLabel(nEditAudPtr))
    
    With aAud(nEditAudPtr)
      sUndoDescr = GWT(#WCP)
      For n = 1 To (grCopyProps\nPropCount)
        If GGS(WCP\chkProperty[n-1]) = #PB_Checkbox_Checked
          bError = #False
          sPropCode = StringField(grCopyProps\sPropsF, n, ",")
          sPropDesc = Lang("WCP", sPropCode)
          Select sPropCode
            Case "FAF"    ; audio file
              WQF_setPropertyFileName(rAud\sFileName, #WCP)
              SUB_setSubDescr(aSub(rAud\nSubIndex)\sSubDescr, WQF\txtSubDescr)
              
            Case "FSE"    ; start at and end at
              nMaxStartTime = getMaxTimeForPoint(nEditAudPtr, rAud\nAbsStartAt)
              If nMaxStartTime >= \nFileDuration
                nMaxStartTime = \nFileDuration - 1
              EndIf
              If (nMaxStartTime >= 0) And (rAud\nAbsStartAt > nMaxStartTime)
                bError = #True
              EndIf
              If bError = #False
                nMinEndTime = getMinTimeForPoint(nEditAudPtr, rAud\nAbsEndAt)
                nMaxEndTime = getMaxTimeForPoint(nEditAudPtr, rAud\nAbsEndAt)
                If nMaxEndTime >= \nFileDuration
                  nMaxEndTime = \nFileDuration - 1
                EndIf
                If ((nMinEndTime >= 0) And (rAud\nAbsEndAt < nMinEndTime)) Or (nMaxEndTime >= 0) And (rAud\nAbsEndAt > nMaxEndTime)
                  bError = #True
                EndIf
              EndIf
              If bError = #False
                WQF_setPropertyStartAt(rAud\nStartAt, GGT(WQF\lblStartAt), #False, #WCP)
                WQF_setPropertyEndAt(rAud\nEndAt, GGT(WQF\lblEndAt), #False, #WCP)
              EndIf
              
            Case "FFA"    ; Fade in and out times
              If rAud\nFadeInTime > 0
                nMaxFadeInTime = getMaxFadeInTime(nEditAudPtr)
                If rAud\nFadeInTime > nMaxFadeInTime
                  bError = #True
                EndIf
              EndIf
              If bError = #False
                If rAud\nFadeOutTime > 0
                  nMaxFadeOutTime = getMaxFadeOutTime(nEditAudPtr)
                  If rAud\nFadeOutTime > nMaxFadeOutTime
                    bError = #True
                  EndIf
                EndIf
              EndIf
              If bError = #False
                WQF_setPropertyFadeInTime(rAud\sFadeInTime, rAud\nFadeInTime, GGT(WQF\lblFadeInTime), #WCP)
                WQF_setPropertyFadeOutTime(rAud\sFadeOutTime, rAud\nFadeOutTime, GGT(WQF\lblFadeOutTime), #WCP)
              EndIf
              
            Case "FLP"    ; Loop properties (start, end, cross-fade, #loops, linked)
              For l2 = 0 To rAud\nMaxLoopInfo
                If rAud\aLoopInfo(l2)\bContainsLoop
                  If rAud\aLoopInfo(l2)\nAbsLoopStart >= \nFileDuration
                    bError = #True
                  ElseIf rAud\aLoopInfo(l2)\nAbsLoopEnd >= \nFileDuration
                    bError = #True
                  EndIf
                EndIf
                If bError = #False
                  WQF_setPropertyContainsLoop(l2, rAud\aLoopInfo(l2)\bContainsLoop)
                  If \aLoopInfo(l2)\bContainsLoop
                    ; nb if \bContainsLoop = #False then WQF_setPropertyContainsLoop(l2, #False) will have cleared all loop fields, ie set then to the grAudDef (default) values
                    WQF_setPropertyLoopStart(l2, rAud\aLoopInfo(l2)\nLoopStart, #False, #WCP)
                    WQF_setPropertyLoopEnd(l2, rAud\aLoopInfo(l2)\nLoopEnd, #False, #WCP)
                    WQF_setPropertyLoopXFadeTime(l2, rAud\aLoopInfo(l2)\nLoopXFadeTime)
                    WQF_setPropertyNumLoops(l2, rAud\aLoopInfo(l2)\nNumLoops)
                  EndIf
                EndIf
              Next l2
              WQF_setPropertyLoopLinked(rAud\bLoopLinked)
              
            Case "FAD"    ; Audio devices, including level and pan settings
              If bError = #False
                For d = 0 To grLicInfo\nMaxAudDevPerAud
                  If (rAud\sLogicalDev[d]) Or (\sLogicalDev[d])
                    WQF_setPropertyLogicalDev(d, rAud\sLogicalDev[d])
                    WQF_setPropertyDBLevel(d, rAud\sDBLevel[d])
                    WQF_setPropertyPan(d, rAud\fPan[d])
                  EndIf
                Next d
                WQF_setCurrentDevInfo(0, #True, #True)
              EndIf
              
            Case "FLE"    ; Level envelope
              
          EndSelect
          If grCopyProps\sCopyMsg
            grCopyProps\sCopyMsg + #CRLF$
          EndIf
          If bError
            grCopyProps\nErrorCount + 1
            grCopyProps\sCopyMsg + "- " + LangPars("WCP", "CannotCopy", sPropDesc, getAudLabel(nAudPtr), getAudLabel(nEditAudPtr))
          Else
            grCopyProps\nSuccessCount + 1
            grCopyProps\sCopyMsg + "- " + LangPars("WCP", "Copied", sPropDesc)
          EndIf
        EndIf
      Next n
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCP_copyPropsForK()
  PROCNAMEC()
  Protected c, n, m, sPropCode.s, sPropDesc.s
  Protected sUndoDescr.s
  Protected bError
  Protected nSubPtr
  Protected rSub.tySub
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  nSubPtr = grCopyProps\nCFSubPtr
  rSub = aSub(nSubPtr)
  grCopyProps\sCopyTitle = LangPars("WCP", "CopyTitle", getSubLabel(nSubPtr), getSubLabel(nEditSubPtr))
  
  With aSub(nEditSubPtr)
    For n = 1 To (grCopyProps\nPropCount)
      If GGS(WCP\chkProperty[n-1]) = #PB_Checkbox_Checked
        bError = #False
        sPropCode = StringField(grCopyProps\sPropsK, n, ",")
        sPropDesc = WCP_getPropDesc(sPropCode)
        u = preChangeSubL(#True, sPropDesc)
        Select sPropCode
;           Case "KLD" ; Lighting Device
;             \sLTLogicalDev = rSub\sLTLogicalDev
;             \nLTDevType = rSub\nLTDevType
;             
;           Case "KDM" ; DMX Items
;             \nMaxChaseStepIndex = rSub\nMaxChaseStepIndex
;             For c = 0 To \nMaxChaseStepIndex
;               CopyArray(rSub\aChaseStep(c)\aDMXSendItem(), \aChaseStep(c)\aDMXSendItem())
;               \aChaseStep(c)\nDMXSendItemCount = rSub\aChaseStep(c)\nDMXSendItemCount
;             Next c
            
          Case "KFX" ; Lighting device, entry type, fixtures, DMX channel values, etc
            \sLTLogicalDev = rSub\sLTLogicalDev
            \nLTDevType = rSub\nLTDevType
            \nLTEntryType = rSub\nLTEntryType
            \sLTDisplayInfo = rSub\sLTDisplayInfo
            \bChase = rSub\bChase
            \nChaseMode = rSub\nChaseMode
            \nChaseSteps = rSub\nChaseSteps
            \nChaseSpeed = rSub\nChaseSpeed
            \bMonitorTapDelay = rSub\bMonitorTapDelay
            \nMaxChaseStepIndex = rSub\nMaxChaseStepIndex
            \bNextLTStopsChase = rSub\bNextLTStopsChase
            \bLTApplyCurrValuesAsMins = rSub\bLTApplyCurrValuesAsMins
            \nMaxFixture = rSub\nMaxFixture
            CopyArray(rSub\aLTFixture(), \aLTFixture())
            \nMaxChaseStepIndex = rSub\nMaxChaseStepIndex
            For c = 0 To \nMaxChaseStepIndex
              CopyArray(rSub\aChaseStep(c)\aFixtureItem(), \aChaseStep(c)\aFixtureItem())
            Next c
            
          Case "KFI" ; Fade time settings
            \nLTBLFadeAction = rSub\nLTBLFadeAction
            \nLTBLFadeUserTime = rSub\nLTBLFadeUserTime
            \nLTDCFadeUpAction = rSub\nLTDCFadeUpAction
            \nLTDCFadeUpUserTime = rSub\nLTDCFadeUpUserTime
            \nLTDCFadeDownAction = rSub\nLTDCFadeDownAction
            \nLTDCFadeDownUserTime = rSub\nLTDCFadeDownUserTime
            \nLTDIFadeUpAction = rSub\nLTDIFadeUpAction
            \nLTDIFadeUpUserTime = rSub\nLTDIFadeUpUserTime
            \nLTDIFadeDownAction = rSub\nLTDIFadeDownAction
            \nLTDIFadeDownUserTime = rSub\nLTDIFadeDownUserTime
            \nLTDIFadeOutOthersAction = rSub\nLTDIFadeOutOthersAction
            \nLTDIFadeOutOthersUserTime = rSub\nLTDIFadeOutOthersUserTime
            \nLTFIFadeUpAction = rSub\nLTFIFadeUpAction
            \nLTFIFadeUpUserTime = rSub\nLTFIFadeUpUserTime
            \nLTFIFadeDownAction = rSub\nLTFIFadeDownAction
            \nLTFIFadeDownUserTime = rSub\nLTFIFadeDownUserTime
            \nLTFIFadeOutOthersAction = rSub\nLTFIFadeOutOthersAction
            \nLTFIFadeOutOthersUserTime = rSub\nLTFIFadeOutOthersUserTime
            \sLTBLFadeUserTime = rSub\sLTBLFadeUserTime
            \sLTDCFadeUpUserTime = rSub\sLTDCFadeUpUserTime
            \sLTDCFadeDownUserTime = rSub\sLTDCFadeDownUserTime
            \sLTDIFadeUpUserTime = rSub\sLTDIFadeUpUserTime
            \sLTDIFadeDownUserTime = rSub\sLTDIFadeDownUserTime
            \sLTDIFadeOutOthersUserTime = rSub\sLTDIFadeOutOthersUserTime
            \sLTFIFadeUpUserTime = rSub\sLTFIFadeUpUserTime
            \sLTFIFadeDownUserTime = rSub\sLTFIFadeDownUserTime
            \sLTFIFadeOutOthersUserTime = rSub\sLTFIFadeOutOthersUserTime
            
        EndSelect
        postChangeSubL(u, #False)
        If Len(grCopyProps\sCopyMsg) > 0
          grCopyProps\sCopyMsg + #CRLF$
        EndIf
        If bError
          grCopyProps\nErrorCount + 1
          grCopyProps\sCopyMsg + "- " + LangPars("WCP", "CannotCopy", sPropDesc, getSubLabel(nSubPtr), getSubLabel(nEditSubPtr))
        Else
          grCopyProps\nSuccessCount + 1
          grCopyProps\sCopyMsg + "- " + LangPars("WCP", "Copied", sPropDesc)
        EndIf
      EndIf
    Next n
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCP_btnCopy_Click()
  PROCNAMEC()
  Protected n, bItemSelected
  Protected sProps.s, sSelected.s
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grCopyProps\nCFSubPtr=" + getSubLabel(grCopyProps\nCFSubPtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr))
  If (grCopyProps\nCFSubPtr >= 0) And (nEditSubPtr >= 0) And (grCopyProps\nCFSubPtr <> nEditSubPtr)
    
    With grCopyProps
      \sCopyMsg = ""
      \nErrorCount = 0
      \nSuccessCount = 0
      ; populate sSelected with the codes of the selected checkboxes
      Select \sCFSubType
        Case "F"
          sProps = \sPropsF
        Case "K"
          sProps = \sPropsK
      EndSelect
      For n = 1 To \nPropCount
        If GGS(WCP\chkProperty[n-1]) = #PB_Checkbox_Checked
          sSelected + StringField(sProps, n, ",") + ","
          bItemSelected = #True
        EndIf
      Next n
      ; copy sSelected to the appropriate \sSelected[x] string
      Select \sCFSubType
        Case "F"
          \sSelectedF = sSelected
        Case "K"
          \sSelectedK = sSelected
      EndSelect
    EndWith
    
    If bItemSelected
      With aSub(nEditSubPtr)
        Select \sSubType
          Case "F"
            WCP_copyPropsForF()
          Case "K"
            WCP_copyPropsForK()
        EndSelect
        debugMsg(sProcName, "calling displaySub(" + getSubLabel(nEditSubPtr) + ")")
        displaySub(nEditSubPtr)
      EndWith
    EndIf
    
    With grCopyProps
      If \nErrorCount > 0
        debugMsg(sProcName, \sCopyMsg)
        scsMessageRequester(\sCopyTitle, \sCopyMsg, #PB_MessageRequester_Ok|#MB_ICONEXCLAMATION)
      EndIf
    EndWith
    
  EndIf ; EndIf (grCopyProps\nCFSubPtr >= 0) And (nEditSubPtr >= 0) And (grCopyProps\nCFSubPtr <> nEditSubPtr)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCP_checkSubTypeSupported(sSubType.s)
  PROCNAMEC()
  Protected bSupported
  
  Select sSubType
    Case "F"
      bSupported = #True
    Case "K"
      If grLicInfo\bCueTypeKAvailable
        bSupported = #True
      EndIf
  EndSelect
  ProcedureReturn bSupported
EndProcedure

Procedure.s WCP_getPropDesc(sPropCode.s)
  PROCNAMEC()
  Protected sPropDesc.s
  
  Select sPropCode
    Case "KLD"
      sPropDesc = Lang("WQK", "lblLogicalDev")
;     Case "KDM"
;       sPropDesc = Lang("WQK", "lblDMXItems")
    Default
      sPropDesc = Lang("WCP", sPropCode)
  EndSelect
  
  ProcedureReturn sPropDesc
EndProcedure

Procedure WCP_loadCheckBoxes(sPropCodes.s, sSelectedCodes.s)
  PROCNAMEC()
  Protected n
  Protected Dim sCheckBox.s(#SCS_MAX_ITEM_IN_COPY_PROPERTIES)
  Protected sPropCode.s, sPropDesc.s
  
  With WCP
    For n = 0 To #SCS_MAX_ITEM_IN_COPY_PROPERTIES
      setVisible(\chkProperty[n], #False)
    Next n
    
    grCopyProps\nPropCount = CountString(sPropCodes, ",")
    For n = 1 To grCopyProps\nPropCount
      sPropCode = StringField(sPropCodes, n, ",")
      sPropDesc = WCP_getPropDesc(sPropCode)
      SGT(\chkProperty[n-1], sPropDesc)
      setGadgetWidth(\chkProperty[n-1], 100)
      setVisible(\chkProperty[n-1], #True)
      If FindString(sSelectedCodes, sPropCode)
        SGS(\chkProperty[n-1], #PB_Checkbox_Checked)
      EndIf
    Next n
    
  EndWith
  
EndProcedure

Procedure WCP_populateForm()
  PROCNAMEC()
  Protected nSubPtr = -1
  Protected sThisCue.s, sCFCue.s
  Protected sThisSubType.s, sSubTypeDescr.s
  Protected i, j
  Protected sPropCodes.s, sSelectedCodes.s
  Protected bCurrSubFound, nInitCFCueData
  
  debugMsg(sProcName, #SCS_START)
  
  With grCopyProps
    \sPropsF = "FAF,FSE,FFA,FLP,FAD,"
    ; \sPropsK = "KLD,KDM,KFI,"
    \sPropsK = "KFX,KFI,"
    \nCFSubPtr = -1
  EndWith

  If nEditSubPtr >= 0
    nSubPtr = nEditSubPtr
  ElseIf nEditCuePtr >= 0
    nSubPtr = aCue(nEditCuePtr)\nFirstSubIndex
  EndIf
  
  If nSubPtr >= 0
    sThisCue = buildLCCueForCBO(nSubPtr)
    sThisSubType = aSub(nSubPtr)\sSubType
    sSubTypeDescr = Lang("CueType", sThisSubType)
  EndIf
  
  With WCP
    SGT(\txtThisCue, sThisCue)
    SGT(\txtCueType, sSubTypeDescr)
    ClearGadgetItems(\cboCFCue)
    For i = 1 To gnLastCue
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\sSubType = sThisSubType
          If j = nSubPtr
            bCurrSubFound = #True
          Else
            sCFCue = buildLCCueForCBO(j)
            addGadgetItemWithData(\cboCFCue, sCFCue, j)
            If (bCurrSubFound = #False) Or (grCopyProps\nCFSubPtr = -1)
              grCopyProps\nCFSubPtr = j
              grCopyProps\sCFSubType = sThisSubType
            EndIf
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    Next i
    
    If CountGadgetItems(\cboCFCue) > 0
      If grCopyProps\nCFSubPtr > 0
        setComboBoxByData(\cboCFCue, grCopyProps\nCFSubPtr)
      EndIf
    EndIf
    
  EndWith
  
  With grCopyProps
    Select \sCFSubType
      Case "F"
        sPropCodes = \sPropsF
        sSelectedCodes = \sSelectedF
      Case "K"
        sPropCodes = \sPropsK
        sSelectedCodes = \sSelectedK
    EndSelect
    WCP_loadCheckBoxes(sPropCodes, sSelectedCodes)
  EndWith
  
  WCP_setButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCP_Form_Show(bModal)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WCP) = #False
    createfmCopyProps()
  EndIf
  setFormPosition(#WCP, @grCopyPropsWindow)
  
  debugMsg(sProcName, "calling WCP_populateForm()")
  WCP_populateForm()
  
  setWindowModal(#WCP, bModal)
  setWindowVisible(#WCP, #True)
  SetActiveWindow(#WCP)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCP_EventHandler()
  PROCNAMEC()
  Protected n
  
  With WCP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WCP_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            If getEnabled(\btnCopy)
              WCP_btnCopy_Click()
              WCP_Form_Unload()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            If getEnabled(\btnCancel)
              WCP_Form_Unload()
            EndIf
            
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnCancel
            WCP_Form_Unload()
            
          Case \btnClearAll
            For n = 1 To grCopyProps\nPropCount
              SGS(WCP\chkProperty[n-1], #False)
            Next n
            WCP_setButtons()
            
          Case \btnCopy
            WCP_btnCopy_Click()
            If (grCopyProps\nErrorCount > 0) And (grCopyProps\nSuccessCount = 0)
              ; if error(s) reported any no copy successful, then stay in the form
            Else
              ; else close the form
              WCP_Form_Unload()
            EndIf
            
          Case \btnHelp
            displayHelpTopic("copy_props.htm")
            
          Case \btnSelectAll
            For n = 1 To grCopyProps\nPropCount
              SGS(WCP\chkProperty[n-1], #True)
            Next n
            WCP_setButtons()
            
          Case \cboCFCue
            grCopyProps\nCFSubPtr = getCurrentItemData(\cboCFCue)
            
          Case \chkProperty[0]
            debugMsg(sProcName, "gnEventGadgetNo=G" + getGadgetName(gnEventGadgetNo))
            WCP_setButtons()
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCP_setButtons()
  PROCNAMEC()
  Protected n, bEnableCopy
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grCopyProps\nCFSubPtr=" + getSubLabel(grCopyProps\nCFSubPtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr))
  If (grCopyProps\nCFSubPtr >= 0) And (nEditSubPtr >= 0) And (grCopyProps\nCFSubPtr <> nEditSubPtr)
    For n = 0 To (grCopyProps\nPropCount-1)
      If GGS(WCP\chkProperty[n]) = #PB_Checkbox_Checked
        bEnableCopy = #True
        Break
      EndIf
    Next n
  EndIf
  
  setEnabled(WCP\btnCopy, bEnableCopy)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF