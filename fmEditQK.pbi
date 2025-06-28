; File: fmEditQK.pbi (Lighting cue)

EnableExplicit

Procedure WQK_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nDevNo, nListIndex, bWaitDisplayed, nLeft, nLeft2
  Static sDMXItems.s, sFixtureItems.s, sBlackout.s, sChanAll.s, sChan1st.s, sDMXCaptureSnap.s, sDMXCaptureSeq.s
  Static bStaticLoaded
  Protected bDevFixturesExist ; Added 9Oct2024 11.10.6aj
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQKCreated = #False
    WMI_displayInfoMsg1(LangPars("WMI", "InitEditCueProps", grText\sTextCueTypeK)) ; "Initializing Editor Lighting Cue Properties"
    bWaitDisplayed = #True
    WQK_Form_Load()
  EndIf
  
  If bStaticLoaded = #False
    sDMXItems = Lang("WQK","DI")
    sFixtureItems = Lang("WQK","FI")
    sBlackout = Lang("WQK","DBO")
    sChanAll = Lang("WQK", "ChanAll")
    sChan1st = Lang("WQK", "Chan1st")
    sDMXCaptureSnap = Lang("WQK", "CAPSN")
    sDMXCaptureSeq = Lang("WQK", "CAPSE")
    bStaticLoaded = #True
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQK\lblSubCueType, pSubPtr)
  
  WQK_populateCboLogicalDev()
  
  With grWQK
    If \nCurrStepIndex <> 0 ; nb If test only to ensure that debugMsg() is only called if \nCurrStepIndex is changed
      \nCurrStepIndex = 0
      debugMsg(sProcName, "\nCurrStepIndex=" + \nCurrStepIndex)
    EndIf
  EndWith
  
  ; Added 9Oct2024 11.10.6aj
  For nDevNo = 0 To grProd\nMaxLightingLogicalDev
    If grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture >= 0
      bDevFixturesExist = #True
      Break
    EndIf
  Next nDevNo
  ; End added 9Oct2024 11.10.6aj
  
  With WQK
    ClearGadgetItems(\cboEntryType)
    ; THe following commented out 9Oct2024 11.10.6ah following bugs reported by Octavio Alcober
;     If grProd\bLightingPre118 Or grProd\nMaxFixType < 0 ; mod 8Jan2020 11.8.2.2ab - added "Or grProd\nMaxFixType < 0"
;       If grLicInfo\bDMXCaptureAvailable
;         addGadgetItemWithData(\cboEntryType, sDMXCaptureSnap, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP)
;         addGadgetItemWithData(\cboEntryType, sDMXCaptureSeq, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ)
;       EndIf
;       addGadgetItemWithData(\cboEntryType, sBlackout, #SCS_LT_ENTRY_TYPE_BLACKOUT)
;       addGadgetItemWithData(\cboEntryType, sDMXItems, #SCS_LT_ENTRY_TYPE_DMX_ITEMS)
;     Else
      If bDevFixturesExist ; Test added 9Oct2024 11.10.6aj
        addGadgetItemWithData(\cboEntryType, sFixtureItems, #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS)
      EndIf
      addGadgetItemWithData(\cboEntryType, sBlackout, #SCS_LT_ENTRY_TYPE_BLACKOUT)
      addGadgetItemWithData(\cboEntryType, sDMXItems, #SCS_LT_ENTRY_TYPE_DMX_ITEMS)
      If grLicInfo\bDMXCaptureAvailable
        addGadgetItemWithData(\cboEntryType, sDMXCaptureSnap, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP)
        addGadgetItemWithData(\cboEntryType, sDMXCaptureSeq, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ)
      EndIf
;     EndIf
    setComboBoxWidth(\cboEntryType)
    nLeft = GadgetX(\cboEntryType) + GadgetWidth(\cboEntryType) + gnGap2
    ResizeGadget(\lblFixtureDisplay, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    nLeft + GadgetWidth(\lblFixtureDisplay) + gnGap
    ResizeGadget(\cboFixtureDisplay, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    ClearGadgetItems(\cboFixtureDisplay)
    addGadgetItemWithData(\cboFixtureDisplay, sChanAll, #SCS_LT_DISP_ALL)
    addGadgetItemWithData(\cboFixtureDisplay, sChan1st, #SCS_LT_DISP_1ST)
    setComboBoxWidth(\cboFixtureDisplay)
    setComboBoxByData(\cboFixtureDisplay, grMemoryPrefs\nDMXFixtureDisplayData, 0)
    If IsGadget(\chkApplyCurrValuesAsMins)
      nLeft = GadgetX(\cboFixtureDisplay) + GadgetWidth(\cboFixtureDisplay) + 20
      ResizeGadget(\chkApplyCurrValuesAsMins, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
    nLeft = GadgetX(\cboFixtureDisplay) + GadgetWidth(\cboFixtureDisplay) + gnGap2
    ; Added 30Nov2022 11.9.7aq following email from Jason Mai that showed \cntChase too far to the left when the Chinese language was chosen.
    ; Modified further 2Dec2022 11.9.7ar after finding opposite issue when using the Japanese translation.
    nLeft2 = GadgetX(\chkChase) + GadgetWidth(\chkChase) + gnGap2
    If nLeft2 > nLeft
      nLeft = nLeft2
    EndIf
    If nLeft + GadgetWidth(\cntChase) > GadgetWidth(\cntSubDetailK)
      setGadgetWidth(\lblEntryType)
      ResizeGadget(\lblEntryType, 2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft2 = GadgetX(\lblEntryType) + GadgetWidth(\lblEntryType) + gnGap
      ResizeGadget(\cboEntryType, nLeft2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft2 = GadgetX(\cboEntryType) + GadgetWidth(\cboEntryType) + gnGap2
      ResizeGadget(\lblFixtureDisplay, nLeft2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft2 = GadgetX(\lblFixtureDisplay) + GadgetWidth(\lblFixtureDisplay) + gnGap
      ResizeGadget(\cboFixtureDisplay, nLeft2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft2 = GadgetX(\cboFixtureDisplay) + GadgetWidth(\cboFixtureDisplay) + gnGap2
      nLeft = GadgetX(\chkChase) + GadgetWidth(\chkChase) + gnGap2
      If nLeft2 > nLeft
        nLeft = nleft2
      EndIf
      WQK_fcChase()
    EndIf
    ; End added 30Nov2022 11.9.7aq
    ResizeGadget(\cntChase, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    If grLicInfo\bDMXCaptureAvailable
      nLeft = GadgetX(\lblFixtureDisplay)
      ResizeGadget(\cvsCaptureButton, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      WQK_drawCaptureButton(#False)
      nLeft + GadgetWidth(\cvsCaptureButton) + gnGap
      ResizeGadget(\lblCapturingDMX, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft + GadgetWidth(\lblCapturingDMX) + gnGap
      ResizeGadget(\cvsCapturingDMXLight, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
  EndWith
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "K", WQK)
    
    nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, \sLTLogicalDev)
    debugMsg(sProcName, "\sLTLogicalDev=" + \sLTLogicalDev + ", nDevNo=" + nDevNo)
    If nDevNo >= 0
      nListIndex = indexForComboBoxData(WQK\cboLogicalDev, nDevNo)
    ElseIf CountGadgetItems(WQK\cboLogicalDev) > 0
      nListIndex = 0
    Else
      nListIndex = -1
    EndIf
    ; debugMsg(sProcName, "nListIndex=" + nListIndex)
    SGS(WQK\cboLogicalDev, nListIndex)
    
    ; debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLTEntryType=" + \nLTEntryType + " (" + decodeLTEntryType(\nLTEntryType) + ")")
    setComboBoxByData(WQK\cboEntryType, \nLTEntryType, 0)
    WQK_fcEntryType()
    
    debugMsg(sProcName, "\nLTDevType=" + decodeDevType(\nLTDevType) + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType))
    Select \nLTDevType
      Case #SCS_DEVTYPE_LT_DMX_OUT
        Select \nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            WQK_populateDMXItemsEtc()
            setVisible(WQK\cntItems, #True)
            setVisible(WQK\cntFixtures, #False)
            setVisible(WQK\cntFixtures1, #False)
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            Select grMemoryPrefs\nDMXFixtureDisplayData
              Case #SCS_LT_DISP_ALL
                WQK_displayInfoForEntryType()
                setVisible(WQK\cntItems, #False)
                setVisible(WQK\cntFixtures, #True)
                setVisible(WQK\cntFixtures1, #False)
              Case #SCS_LT_DISP_1ST
                WQK_displayInfoForEntryType()
                setVisible(WQK\cntItems, #False)
                setVisible(WQK\cntFixtures, #False)
                setVisible(WQK\cntFixtures1, #True)
            EndSelect
            
          Case #SCS_LT_ENTRY_TYPE_BLACKOUT
            setVisible(WQK\cntItems, #False)
            setVisible(WQK\cntFixtures, #False)
            setVisible(WQK\cntFixtures1, #False)
            
        EndSelect
    EndSelect
    
    If getVisible(WQK\chkChase)
      setOwnState(WQK\chkChase, \bChase)
      If (\bChase) And (\nChaseSteps > 0)
        SGT(WQK\txtChaseSteps, Str(\nChaseSteps))
      Else
        SGT(WQK\txtChaseSteps, "")
      EndIf
      setComboBoxByData(WQK\cboChaseMode, \nChaseMode, 0)
      WQK_fcChase()
      setOwnState(WQK\chkNextLTStopsChase, \bNextLTStopsChase)
      setOwnState(WQK\chkMonitorTapDelay, \bMonitorTapDelay)
    EndIf
    
    If IsGadget(WQK\chkApplyCurrValuesAsMins)
      If getVisible(WQK\chkApplyCurrValuesAsMins)
        setOwnState(WQK\chkApplyCurrValuesAsMins, \bLTApplyCurrValuesAsMins)
      EndIf
    EndIf
    
    WQK_setFadeAndLiveDMXTestGadgets()
    WQK_setTBSButtons()
    
    ; debugMsg(sProcName, "calling WQK_buildAndDisplayLightingMessage()")
    WQK_buildAndDisplayLightingMessage()
    
    WQK_saveInitDMXItems(pSubPtr)
    
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  If bWaitDisplayed
    WMI_clearInfoMsgs()
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_drawForm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  colorEditorComponent(#WQK)
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_fcFIFadeUpAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtFIFadeUpTime
    nSecondsGadget = WQK\lblFIFadeUpSeconds
    With aSub(nEditSubPtr)
      Select \nLTFIFadeUpAction
        Case #SCS_DMX_FI_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
          nFadeTime = DMX_getDefFadeTimeForProd(@grProd)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_fcFIFadeDownAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtFIFadeDownTime
    nSecondsGadget = WQK\lblFIFadeDownSeconds
    With aSub(nEditSubPtr)
      Select \nLTFIFadeDownAction
        Case #SCS_DMX_FI_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
          SGT(nTimeGadget, GGT(WQK\txtFIFadeUpTime))
;           nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEUP, \nLTFIFadeUpAction, @aSub(nEditSubPtr), @grProd)
;           SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_fcFIFadeOutOthersAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nTimeGadget = WQK\txtFIFadeOutOthersTime
      nSecondsGadget = WQK\lblFIFadeOutOthersSeconds
      Select \nLTFIFadeOutOthersAction
        Case #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
          
        Case #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
          SGT(nTimeGadget, GGT(WQK\txtFIFadeDownTime))
;           nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEDOWN, \nLTFIFadeDownAction, @aSub(nEditSubPtr), @grProd)
;           SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf

EndProcedure

Procedure WQK_fcBLFadeAction()
  ; PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtBLFadeTime
    nSecondsGadget = WQK\lblBLFadeSeconds
    With aSub(nEditSubPtr)
      Select \nLTBLFadeAction
        Case #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
          nFadeTime = DMX_getDefFadeTimeForProd(@grProd)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTBLFadeUserTime, \nLTBLFadeUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_fcDIFadeUpAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtDIFadeUpTime
    nSecondsGadget = WQK\lblDIFadeUpSeconds
    With aSub(nEditSubPtr)
      Select \nLTDIFadeUpAction
        Case #SCS_DMX_DI_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
          nFadeTime = DMX_getDefFadeTimeForProd(@grProd)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
EndProcedure

Procedure WQK_fcDIFadeDownAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtDIFadeDownTime
    nSecondsGadget = WQK\lblDIFadeDownSeconds
    With aSub(nEditSubPtr)
      Select \nLTDIFadeDownAction
        Case #SCS_DMX_DI_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
          nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEUP, \nLTDIFadeUpAction, @aSub(nEditSubPtr), @grProd)
          ; debugMsg0(sProcName, "nFadeTime=" + nFadeTime)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
EndProcedure

Procedure WQK_fcDIFadeOutOthersAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nTimeGadget = WQK\txtDIFadeOutOthersTime
      nSecondsGadget = WQK\lblDIFadeOutOthersSeconds
      Select \nLTDIFadeOutOthersAction
        Case #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
          
        Case #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
          nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEDOWN, \nLTDIFadeDownAction, @aSub(nEditSubPtr), @grProd)
          ; debugMsg0(sProcName, "nFadeTime=" + nFadeTime)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf

EndProcedure

Procedure WQK_fcDCFadeUpAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtDCFadeUpTime
    nSecondsGadget = WQK\lblDCFadeUpSeconds
    With aSub(nEditSubPtr)
      Select \nLTDCFadeUpAction
        Case #SCS_DMX_DC_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
          nFadeTime = DMX_getDefFadeTimeForProd(@grProd)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDCFadeUpUserTime,\nLTDCFadeUpUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_fcDCFadeDownAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  If nEditSubPtr >= 0
    nTimeGadget = WQK\txtDCFadeDownTime
    nSecondsGadget = WQK\lblDCFadeDownSeconds
    With aSub(nEditSubPtr)
      Select \nLTDCFadeDownAction
        Case #SCS_DMX_DC_FADE_ACTION_NONE
          SGT(nTimeGadget, timeToStringD(0))
          bTimeVisible = #True
          
        Case #SCS_DMX_DC_FADE_ACTION_USE_FADEUP_TIME
          nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEUP, \nLTDCFadeUpAction, @aSub(nEditSubPtr), @grProd)
          ; debugMsg0(sProcName, "nFadeTime=" + nFadeTime)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_fcDCFadeOutOthersAction()
  PROCNAMECS(nEditSubPtr)
  Protected bTimeVisible, bTimeEnabled, nTimeGadget, nSecondsGadget, nFadeTime
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nTimeGadget = WQK\txtDCFadeOutOthersTime
      nSecondsGadget = WQK\lblDCFadeOutOthersSeconds
      Select \nLTDCFadeOutOthersAction
        Case #SCS_DMX_DC_FADE_ACTION_DO_NOT_FADEOUTOTHERS
          
        Case #SCS_DMX_DC_FADE_ACTION_USE_FADEDOWN_TIME
          nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEDOWN, \nLTDCFadeDownAction, @aSub(nEditSubPtr), @grProd)
          ; debugMsg0(sProcName, "nFadeTime=" + nFadeTime)
          SGT(nTimeGadget, timeToStringD(nFadeTime))
          bTimeVisible = #True
          
        Case #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
          SGT(nTimeGadget, makeDisplayTimeValueD(\sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime))
          bTimeVisible = #True
          bTimeEnabled = #True
          
      EndSelect
      setVisible(nTimeGadget, bTimeVisible)
      setEnabled(nTimeGadget, bTimeEnabled)
      setVisible(nSecondsGadget, bTimeVisible)
    EndWith
  EndIf

EndProcedure

Procedure WQK_cboDIFadeUpAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDIFadeUpAction, GGT(WQK\lblDIFadeUpAction))
      \nLTDIFadeUpAction = getCurrentItemData(WQK\cboDIFadeUpAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDIFadeUpAction()
      ; now call WQK_fcDIFadeDownAction() and WQK_fcDIFadeOutOthersAction() because the 'fade up action' may be to use the default fade time, which the user has probably just changed
      WQK_fcDIFadeDownAction()
      WQK_fcDIFadeOutOthersAction()
      grWQK\nLastDIFadeUpAction = \nLTDIFadeUpAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDIFadeUpAction)
      WQK_doLiveDMXTestIfReqd()
      If \nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDIFadeUpTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboDIFadeDownAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDIFadeDownAction, GGT(WQK\lblDIFadeDownAction))
      \nLTDIFadeDownAction = getCurrentItemData(WQK\cboDIFadeDownAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDIFadeDownAction()
      ; now call WQK_fcDIFadeOutOthersAction() because the 'fade down action' may be to use the default fade time, which the user has probably just changed
      WQK_fcDIFadeOutOthersAction()
      grWQK\nLastDIFadeDownAction = \nLTDIFadeDownAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDIFadeDownAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDIFadeDownTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboDIFadeOutOthersAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDIFadeOutOthersAction, GGT(WQK\lblDIFadeOutOthersAction))
      \nLTDIFadeOutOthersAction = getCurrentItemData(WQK\cboDIFadeOutOthersAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDIFadeOutOthersAction()
      grWQK\nLastDIFadeOutOthersAction = \nLTDIFadeOutOthersAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDIFadeOutOthersAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDIFadeOutOthersTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboFIFadeUpAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTFIFadeUpAction, GGT(WQK\lblFIFadeUpAction))
      \nLTFIFadeUpAction = getCurrentItemData(WQK\cboFIFadeUpAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcFIFadeUpAction()
      ; now call WQK_fcFIFadeDownAction() and WQK_fcFIFadeOutOthersAction() because the 'fade up action' may be to use the default fade time, which the user has probably just changed
      WQK_fcFIFadeDownAction()
      WQK_fcFIFadeOutOthersAction()
      grWQK\nLastFIFadeUpAction = \nLTFIFadeUpAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTFIFadeUpAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtFIFadeUpTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboFIFadeDownAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTFIFadeDownAction, GGT(WQK\lblFIFadeDownAction))
      \nLTFIFadeDownAction = getCurrentItemData(WQK\cboFIFadeDownAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcFIFadeDownAction()
      ; now call WQK_fcFIFadeOutOthersAction() because the 'fade down action' may be to use the default fade time, which the user has probably just changed
      WQK_fcFIFadeOutOthersAction()
      grWQK\nLastFIFadeDownAction = \nLTFIFadeDownAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTFIFadeDownAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtFIFadeDownTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboFIFadeOutOthersAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTFIFadeOutOthersAction, GGT(WQK\lblFIFadeOutOthersAction))
      \nLTFIFadeOutOthersAction = getCurrentItemData(WQK\cboFIFadeOutOthersAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcFIFadeOutOthersAction()
      grWQK\nLastFIFadeOutOthersAction = \nLTFIFadeOutOthersAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTFIFadeOutOthersAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtFIFadeOutOthersTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboBLFadeAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTBLFadeAction, GGT(WQK\lblBLFadeAction))
      \nLTBLFadeAction = getCurrentItemData(WQK\cboBLFadeAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcBLFadeAction()
      grWQK\nLastBLFadeAction = \nLTBLFadeAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      setDefaultSubDescr()
      setDefaultCueDescr()
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTBLFadeAction)
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTBLFadeAction = #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtBLFadeTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboDCFadeUpAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDCFadeUpAction, GGT(WQK\lblDCFadeUpAction))
      \nLTDCFadeUpAction = getCurrentItemData(WQK\cboDCFadeUpAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDCFadeUpAction()
      ; now call WQK_fcDCFadeDownAction() because the 'fade up action' may be to use the default fade time, which the user has probably just changed
      WQK_fcDCFadeDownAction()
      grWQK\nLastDCFadeUpAction = \nLTDCFadeUpAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDCFadeUpAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDCFadeUpTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboDCFadeDownAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDCFadeDownAction, GGT(WQK\lblDCFadeDownAction))
      \nLTDCFadeDownAction = getCurrentItemData(WQK\cboDCFadeDownAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDCFadeDownAction()
      grWQK\nLastDCFadeDownAction = \nLTDCFadeDownAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDCFadeDownAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDCFadeDownTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboDCFadeOutOthersAction_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nLTDCFadeOutOthersAction, GGT(WQK\lblDCFadeOutOthersAction))
      \nLTDCFadeOutOthersAction = getCurrentItemData(WQK\cboDCFadeOutOthersAction,0)
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_fcDCFadeOutOthersAction()
      grWQK\nLastDCFadeOutOthersAction = \nLTDCFadeOutOthersAction
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTDCFadeOutOthersAction)
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
      If \nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
        SAG(WQK\txtDCFadeOutOthersTime)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_txtDIFadeUpUserTime_Validate()
  ; Supports txtDIFadeUpUserTime being a time field (eg 1.5) or a callable cue parameter (eg FU)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDIFadeUpTime
  sPrompt = GGT(WQK\lblDIFadeUpAction) ; nb no separate label for WQK\txtDIFadeUpTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime, grSubDef\nLTDIFadeUpUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDIFadeUpUserTime and \nLTDIFadeUpUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcDIFadeDownAction() and WQK_fcDIFadeOutOthersAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcDIFadeDownAction()
    WQK_fcDIFadeOutOthersAction()
    grWQK\nLastDIFadeUpUserTime = \nLTDIFadeUpUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime)
    postChangeSubS(u, sNew)
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtDIFadeDownUserTime_Validate()
  ; Supports txtDIFadeDownUserTime being a time field (eg 1.5) or a callable cue parameter (eg FD)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDIFadeDownTime
  sPrompt = GGT(WQK\lblDIFadeDownAction) ; nb no separate label for WQK\txtFadeDownTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime, grSubDef\nLTDIFadeDownUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDIFadeDownUserTime and \nLTDIFadeDownUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcDIFadeOutOthersAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcDIFadeOutOthersAction()
    grWQK\nLastDIFadeDownUserTime = \nLTDIFadeDownUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime)
    postChangeSubS(u, sNew)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtDIFadeOutOthersUserTime_Validate()
  ; Supports txtDIFadeOutOthersUserTime being a time field (eg 1.5) or a callable cue parameter (eg OTH)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDIFadeOutOthersTime
  sPrompt = GGT(WQK\lblDIFadeOutOthersAction)
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime, grSubDef\nLTDIFadeOutOthersUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDIFadeOutOthersUserTime and \nLTDIFadeOutOthersUserTime from the value in sValue
    ; debugMsg0(sProcName, "\nLTDIFadeOutOthersUserTime=" + \nLTDIFadeOutOthersUserTime + ", \sLTDIFadeOutOthersUserTime=" + \sLTDIFadeOutOthersUserTime)
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    grWQK\nLastDIFadeOutOthersUserTime = \nLTDIFadeOutOthersUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    ; debugMsg0(sProcName, "\nSubDuration=" + \nSubDuration)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime)
    postChangeSubS(u, sNew)
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtFIFadeUpUserTime_Validate()
  ; Supports txtFIFadeUpUserTime being a time field (eg 1.5) or a callable cue parameter (eg FU)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtFIFadeUpTime
  sPrompt = GGT(WQK\lblFIFadeUpAction) ; nb no separate label for WQK\txtFIFadeUpTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime, grSubDef\nLTFIFadeUpUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTFIFadeUpUserTime and \nLTFIFadeUpUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcFIFadeDownAction() and WQK_fcFIFadeOutOthersAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcFIFadeDownAction()
    WQK_fcFIFadeOutOthersAction()
    grWQK\nLastFIFadeUpUserTime = \nLTFIFadeUpUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime)
    postChangeSubS(u, sNew)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtFIFadeDownUserTime_Validate()
  ; Supports txtFIFadeDownUserTime being a time field (eg 1.5) or a callable cue parameter (eg FD)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtFIFadeDownTime
  sPrompt = GGT(WQK\lblFIFadeDownAction) ; nb no separate label for WQK\txtFadeDownTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime, grSubDef\nLTFIFadeDownUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTFIFadeDownUserTime and \nLTFIFadeDownUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcFIFadeOutOthersAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcFIFadeOutOthersAction()
    grWQK\nLastFIFadeDownUserTime = \nLTFIFadeDownUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime)
    postChangeSubS(u, sNew)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtFIFadeOutOthersUserTime_Validate()
  ; Supports txtFIFadeOutOthersUserTime being a time field (eg 1.5) or a callable cue parameter (eg OTH)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtFIFadeOutOthersTime
  sPrompt = GGT(WQK\lblFIFadeOutOthersAction)
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime, grSubDef\nLTFIFadeOutOthersUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTFIFadeOutOthersUserTime and \nLTFIFadeOutOthersUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    grWQK\nLastFIFadeOutOthersUserTime = \nLTFIFadeOutOthersUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    postChangeSubL(u, \nLTFIFadeOutOthersUserTime)
    sNew = makeDisplayTimeValue(\sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime)
    postChangeSubS(u, sNew)
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtBLFadeUserTime_Validate()
  ; Supports txtBLFadeUserTime being a time field (eg 1.5) or a callable cue parameter (eg BL)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  ; debugMsg0(sProcName, #SCS_START + ", grWQK\bInValidate=" + strB(grWQK\bInValidate))
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtBLFadeTime
  sPrompt = GGT(WQK\lblBLFadeAction) ; nb no separate label for WQK\txtBlackoutFadeTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTBLFadeUserTime, \nLTBLFadeUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTBLFadeUserTime, \nLTBLFadeUserTime, grSubDef\nLTBLFadeUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTBLFadeUserTime and \nLTBLFadeUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcBLFadeAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcBLFadeAction()
    grWQK\nLastBLFadeUserTime = \nLTBLFadeUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    setDefaultSubDescr()
    setDefaultCueDescr()
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTBLFadeUserTime, \nLTBLFadeUserTime)
    postChangeSubS(u, sNew)
    ; The following two lines deleted 11Jul2023 11.10.0bq as they have already been called in WQK_commonUpdateProcessing()
    ;   loadGridRow(nEditCuePtr)
    ;   PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
    ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nLTBLFadeUserTime=" + \nLTBLFadeUserTime)
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtDCFadeUpUserTime_Validate()
  ; Supports txtDCFadeUpUserTime being a time field (eg 1.5) or a callable cue parameter (eg FU)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDCFadeUpTime
  sPrompt = GGT(WQK\lblDCFadeUpAction) ; nb no separate label for WQK\txtDCFadeUpTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime, grSubDef\nLTDCFadeUpUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDCFadeUpUserTime and \nLTDCFadeUpUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    ; now call WQK_fcDCFadeDownAction() because the 'fade out others action' may be to use the default fade time, which the user has probably just changed
    WQK_fcDCFadeDownAction()
    grWQK\nLastDCFadeUpUserTime = \nLTDCFadeUpUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime)
    postChangeSubS(u, sNew)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtDCFadeDownUserTime_Validate()
  ; Supports txtDCFadeDownUserTime being a time field (eg 1.5) or a callable cue parameter (eg FD)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDCFadeDownTime
  sPrompt = GGT(WQK\lblDCFadeDownAction) ; nb no separate label for WQK\txtFadeDownTime
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime, grSubDef\nLTDCFadeDownUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDCFadeDownUserTime and \nLTDCFadeDownUserTime from the value in sValue
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    grWQK\nLastDCFadeDownUserTime = \nLTDCFadeDownUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime)
    postChangeSubS(u, sNew)
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtDCFadeOutOthersUserTime_Validate()
  ; Supports txtDCFadeOutOthersUserTime being a time field (eg 1.5) or a callable cue parameter (eg OTH)
  PROCNAMECS(nEditSubPtr)
  Protected u, sPrompt.s, nTimeGadget, sValue.s, nTimeFieldIsParamId, sOld.s, sNew.s
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nTimeGadget = WQK\txtDCFadeOutOthersTime
  sPrompt = GGT(WQK\lblDCFadeOutOthersAction)
  macCommonTimeFieldValidationD(grWQK\bInValidate) ; nb populates sValue
  ; debugMsg0(sProcName, "GGT(nTimeGadget)=" + GGT(nTimeGadget) + ", sValue=" + sValue)
  
  With aSub(nEditSubPtr)
    sOld = makeDisplayTimeValue(\sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime)
    u = preChangeSubS(sOld, sPrompt)
    macReadNumericOrStringParam(sValue, \sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime, grSubDef\nLTDCFadeOutOthersUserTime, #True)
    ; Macro macReadNumericOrStringParam populates \sLTDCFadeOutOthersUserTime and \nLTDCFadeOutOthersUserTime from the value in sValue
    ; debugMsg0(sProcName, "\nLTDCFadeOutOthersUserTime=" + \nLTDCFadeOutOthersUserTime + ", \sLTDCFadeOutOthersUserTime=" + \sLTDCFadeOutOthersUserTime)
    WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
    grWQK\nLastDCFadeOutOthersUserTime = \nLTDCFadeOutOthersUserTime
    \nSubDuration = getSubLength(nEditSubPtr, #True)
    ; debugMsg0(sProcName, "\nSubDuration=" + \nSubDuration)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    sNew = makeDisplayTimeValue(\sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime)
    postChangeSubS(u, sNew)
  EndWith
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_stopLiveDMXTestIfRunning()
  PROCNAMECS(nEditSubPtr)
  
  With grWQK
    If (\bRunningLiveDMXTest) And (\nLiveDMXTestSubPtr >= 0)
      ; stop test chase if running
      debugMsg(sProcName, "calling DMX_stopChaseIfReqd(" + getSubLabel(\nLiveDMXTestSubPtr) + ")")
      DMX_stopChaseIfReqd(\nLiveDMXTestSubPtr)
    EndIf
  EndWith
  
EndProcedure

Procedure WQK_doLiveDMXTestIfReqd(bIncludeSettingPreSubValues=#False)
  PROCNAMECS(nEditSubPtr)
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START)
  
  With grWQK
    
    WQK_stopLiveDMXTestIfRunning()
    
    If \bLiveDMXTest Or \bSingleStep
      \bRunningLiveDMXTest = #True
      \nLiveDMXTestSubPtr = nEditSubPtr
      
      LockDMXSendMutex(789)
      
      If aSub(nEditSubPtr)\bChase
        If \bSingleStep
          \bTestingChase = #False
          If \nCurrStepIndex >= 0
            debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #True, #True, #False, #True, #False, " + \nCurrStepIndex + ")")
            DMX_prepareDMXForSend(nEditSubPtr, #True, #True, #False, #True, #False, \nCurrStepIndex)
          EndIf
        Else ; not single-step
          \bTestingChase = #True
          Select aSub(nEditSubPtr)\nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
              debugMsg(sProcName, "calling DMX_loadDMXChaseItems(" + getSubLabel(nEditSubPtr) + ")")
              DMX_loadDMXChaseItems(nEditSubPtr)
            Default
              debugMsg(sProcName, "calling DMX_loadDMXChaseItemsFI(" + getSubLabel(nEditSubPtr) + ")")
              DMX_loadDMXChaseItemsFI(nEditSubPtr)
          EndSelect
          grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
          debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
          UnlockDMXSendMutex()
          ; The following moved 18Sep2024 11.10.4aa further down this Procedure so that performed whether or not this is a chae lighting cue
          ; (Problem reported by Dave Jenkins, 17Sep2024)
          ; If THR_getThreadState(#SCS_THREAD_DMX_SEND) <> #SCS_THREAD_STATE_ACTIVE
          ;   debugMsg3(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)")
          ;   THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)
          ; EndIf
        EndIf
      Else
        ; live test of non-chase
        \bTestingChase = #False
;         debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #True, #True, " + strB(bIncludeSettingPreSubValues) + ", #True)")
;         DMX_prepareDMXForSend(nEditSubPtr, #True, #True, bIncludeSettingPreSubValues, #True)
        ; 20Jan2021 11.8.3ab Modified to allow live test to apply the fades
        debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #True, #True, " + strB(bIncludeSettingPreSubValues) + ")")
        DMX_prepareDMXForSend(nEditSubPtr, #True, #True, bIncludeSettingPreSubValues)
      EndIf
      
      If bLockedMutex
        UnlockDMXSendMutex()
      EndIf
      
    Else
      \bRunningLiveDMXTest = #False
      
    EndIf ; EndIf \bLiveDMXTest
    
  EndWith
  
  If THR_getThreadState(#SCS_THREAD_DMX_SEND) <> #SCS_THREAD_STATE_ACTIVE
    debugMsg3(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)")
    THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)
  EndIf

  If IsWindow(#WDD)
    debugMsg(sProcName, "calling WDD_forceDisplayDMXSendData()")
    WDD_forceDisplayDMXSendData()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_LiveDMXTestCommon()
  PROCNAMECS(nEditSubPtr)
  Protected bOriginalSetting, bIncludeSettingPreSubValues
  
  debugMsg(sProcName, #SCS_START)
  
  With grWQK
    ; force 'lost focus' if focus currently on a text field, such as a DMX Items field
    SAG(-1)
    
    bOriginalSetting = \bLiveDMXTest
    \bLiveDMXTest = getOwnState(WQK\chkLiveDMXTest)
    \bSingleStep = getOwnState(WQK\chkSingleStep)
    Select aSub(nEditSubPtr)\nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        \bDoNotBlackoutOthers = #True
      Default
        \bDoNotBlackoutOthers = getOwnState(WQK\chkDoNotBlackoutOthers)
    EndSelect
    debugMsg(sProcName, "grWQK\bLiveDMXTest=" + strB(\bLiveDMXTest) + ", \bSingleStep=" + strB(\bSingleStep) + ", \bDoNotBlackoutOthers=" + strB(\bDoNotBlackoutOthers))
    
    If (bOriginalSetting = #False) And (\bDoNotBlackoutOthers = #False)
      If aSub(nEditSubPtr)\bChase = #False
        bIncludeSettingPreSubValues = #True
      EndIf
    EndIf
    debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd(" + strB(bIncludeSettingPreSubValues) + ")")
    WQK_doLiveDMXTestIfReqd(bIncludeSettingPreSubValues)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_chkLiveDMXTest_Click()
  PROCNAMECS(nEditSubPtr)
  
  With WQK
    ; \chkLiveDMXTest and \chkSingleStep are mutually exclusive
    If getOwnState(\chkLiveDMXTest)
      If getOwnState(\chkSingleStep)
        setOwnState(\chkSingleStep, #False)
      EndIf
    EndIf
    debugMsg(sProcName, "calling WQK_LiveDMXTestCommon()")
    WQK_LiveDMXTestCommon()
  EndWith
  
EndProcedure

Procedure WQK_chkSingleStep_Click()
  PROCNAMECS(nEditSubPtr)
  
  With WQK
    ; \chkSingleStep and \chkLiveDMXTest are mutually exclusive
    If getOwnState(\chkSingleStep)
      If getOwnState(\chkLiveDMXTest)
        setOwnState(\chkLiveDMXTest, #False)
      EndIf
    EndIf
    debugMsg(sProcName, "calling WQK_LiveDMXTestCommon()")
    WQK_LiveDMXTestCommon()
  EndWith
EndProcedure

Procedure WQK_chkDoNotBlackoutOthers_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, "calling WQK_LiveDMXTestCommon()")
  WQK_LiveDMXTestCommon()

EndProcedure

Procedure WQK_resetCurrentDataFields()
  ; PROCNAMECS(nEditSubPtr)
  With grWQK
    \bInValidate = #False
    \sSelectedLogicalDev = ""
    \nSelectedDevType = #SCS_DEVTYPE_NONE
    \nSelectedItem = 0
    \nSelectedFixture = 0
    \bLiveDMXTest = #False
    \nFixtureComboboxesPopulatedForDevNo = -1
    ; debugMsg(sProcName, "grWQK\nFixtureComboboxesPopulatedForDevNo=" + \nFixtureComboboxesPopulatedForDevNo)
  EndWith
EndProcedure

Procedure WQK_Form_Load()
  PROCNAMEC()
  Protected qStartTime.q

  debugMsg(sProcName, #SCS_START)
  
  qStartTime = ElapsedMilliseconds()
  
  createfmEditQK()
  SUB_loadOrResizeHeaderFields("K", #True)
  ; KeyPreview = #True
  debugMsg(sProcName, "time since start of procedure: " + Str(ElapsedMilliseconds() - qStartTime))
  
  WQK_drawForm()
  
  WQK_resetCurrentDataFields()
  
  With WQK
    ; side toolbar
    debugMsg(sProcName, "calling makeTBS")
    WQK_makeTBS()
  EndWith
  
  debugMsg(sProcName, "time since start of procedure: " + Str(ElapsedMilliseconds() - qStartTime))

EndProcedure

Procedure WQK_imgQKButtonTBS_Click(nButtonId)
  PROCNAME(#PB_Compiler_Procedure + "(" + nButtonId + ")")
  Protected nCurrStepIndex, nStepIndex, nFromStep, nUpToStep, nCurrItemIndex=-1, nNewItemIndex
  Protected u, sUndoDesc.s
  Protected rDMXItem.tyDMXSendItem
  Protected rFixtureItem.tyLTFixtureItem
  Protected rFixtureItemDef.tyLTFixtureItem
  Protected rLTSubFixture.tyLTSubFixture
  Protected n
  Protected nGoToRow
  Protected sFixtureCodes.s
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr < 0
    ProcedureReturn
  EndIf
  
  Select aSub(nEditSubPtr)\nLTEntryType
    Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
      nCurrItemIndex = grWQK\nSelectedItem
      ; debugMsg(sProcName, "nCurrItemIndex=" + nCurrItemIndex + ", ListIndex(WQKItem())=" + ListIndex(WQKItem()))
    Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
      nCurrItemIndex = grWQK\nSelectedFixture
  EndSelect
  
  nCurrStepIndex = grWQK\nCurrStepIndex
  nGoToRow = 0
  
  With aSub(nEditSubPtr)
    
    Select \nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        Select nButtonId
          Case #SCS_STANDARD_BTN_MOVE_UP  ; move row up
            sUndoDesc = "Move DMX Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            nNewItemIndex = nCurrItemIndex - 1
            rDMXItem = \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex)
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex) = \aChaseStep(nCurrStepIndex)\aDMXSendItem(nNewItemIndex)
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(nNewItemIndex) = rDMXItem
            WQK_commonUpdateProcessing()
            WQK_populateDMXItemsEtc(nNewItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_MOVE_DOWN  ; move row down
            sUndoDesc = "Move DMX Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            nNewItemIndex = nCurrItemIndex + 1
            If nNewItemIndex > ArraySize(\aChaseStep(nCurrStepIndex)\aDMXSendItem())
              ReDim \aChaseStep(nCurrStepIndex)\aDMXSendItem(nNewItemIndex)
            EndIf
            rDMXItem = \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex)
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex) = \aChaseStep(nCurrStepIndex)\aDMXSendItem(nNewItemIndex)
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(nNewItemIndex) = rDMXItem
            WQK_commonUpdateProcessing()
            WQK_populateDMXItemsEtc(nNewItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_PLUS  ; insert row
            sUndoDesc = "Insert DMX Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            ; move this and following items down one position
            If (nCurrItemIndex + 1) > ArraySize(\aChaseStep(nCurrStepIndex)\aDMXSendItem())
              ReDim \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex + 1)
            EndIf
            For n = (\aChaseStep(nCurrStepIndex)\nDMXSendItemCount - 1) To (nCurrItemIndex + 1) Step -1
              \aChaseStep(nCurrStepIndex)\aDMXSendItem(n) = \aChaseStep(nCurrStepIndex)\aDMXSendItem(n-1)
            Next n
            ; clear this item
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex) = grChaseStepDef\aDMXSendItem(0)
            \aChaseStep(nCurrStepIndex)\nDMXSendItemCount + 1
            WQK_commonUpdateProcessing()
            WQK_populateDMXItemsEtc(nCurrItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_MINUS  ; delete row
            sUndoDesc = "Remove DMX Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            sFixtureCodes = DMX_getCurrFixtureCodes(nEditSubPtr, nCurrStepIndex, nCurrItemIndex) ; get 'current fixture' as at the item about to be removed
            ; move following messages up one position
            For n = nCurrItemIndex To (\aChaseStep(nCurrStepIndex)\nDMXSendItemCount - 1) - 1 ; (grLicInfo\nMaxDMXItemPerLightingSub - 1)
              \aChaseStep(nCurrStepIndex)\aDMXSendItem(n) = \aChaseStep(nCurrStepIndex)\aDMXSendItem(n+1)
            Next n
            ; clear last item
            n = \aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount - 1 ; grLicInfo\nMaxDMXItemPerLightingSub
            \aChaseStep(nCurrStepIndex)\aDMXSendItem(n) = grChaseStepDef\aDMXSendItem(0)
            \aChaseStep(nCurrStepIndex)\nDMXSendItemCount - 1
            If sFixtureCodes
              rDMXItem = \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex) ; new 'current item'
              If FindString(rDMXItem\sDMXItemStr, ":") = 1
                ; new 'current item' inherits the fixture from the previous entry
                ; so insert the fixtures entry from the item just removed
                \aChaseStep(nCurrStepIndex)\aDMXSendItem(nCurrItemIndex)\sDMXItemStr = sFixtureCodes + rDMXItem\sDMXItemStr
              EndIf
            EndIf
            nGoToRow = 0
            For n = nCurrItemIndex To 0 Step -1
              If \aChaseStep(nCurrStepIndex)\aDMXSendItem(n)\sDMXItemStr
                nGoToRow = n
                Break
              EndIf
            Next n
            WQK_commonUpdateProcessing()
            WQK_populateDMXItemsEtc(nGoToRow)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
            ; Copy and Paste buttons for DMX Items and Capture disabled 1Sep2020 11.8.3.2at as they are confusing because they operate at the entire 'chase step' level, not at the individual item level
            ; NOTE: Reinstated 20Feb2024 11.10.2as follwoing FB posting by Sascha Pirkowski
          Case #SCS_STANDARD_BTN_COPY ; copy dmx items
            grClipChaseStep = \aChaseStep(nCurrStepIndex)
            gsClipChaseStepDescr = getSubLabel(nEditSubPtr) + " " + Trim(GGT(WQK\lblDMXItems))
            gbClipChaseStepPopulated = #True
            debugMsg(sProcName, "(copy) nCurrItemIndex=" + nCurrStepIndex + ", grClipChaseStep\nDMXSendItemCount=" + grClipChaseStep\nDMXSendItemCount +
                                ", \aDMXSendItem(0)\sDMXItemStr=" + grClipChaseStep\aDMXSendItem(0)\sDMXItemStr + ", \aDMXSendItem(1)\sDMXItemStr=" + grClipChaseStep\aDMXSendItem(1)\sDMXItemStr)
            
          Case #SCS_STANDARD_BTN_PASTE  ; paste dmx items
            If gbClipChaseStepPopulated
              sUndoDesc = "Paste DMX Items"
              u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrStepIndex)
              debugMsg(sProcName, "(paste) nCurrStepIndex=" + nCurrStepIndex + ", grClipChaseStep\nDMXSendItemCount=" + grClipChaseStep\nDMXSendItemCount +
                                  ", \aDMXSendItem(0)\sDMXItemStr=" + grClipChaseStep\aDMXSendItem(0)\sDMXItemStr + ", \aDMXSendItem(1)\sDMXItemStr=" + grClipChaseStep\aDMXSendItem(1)\sDMXItemStr)
              \aChaseStep(nCurrStepIndex) = grClipChaseStep
              WQK_commonUpdateProcessing()
              WQK_populateDMXItemsEtc()
              postChangeSubL(u, #False, -5, nCurrStepIndex, sUndoDesc)
            EndIf
            
        EndSelect
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + grWQK\nCurrStepIndex + ")\nDMXSendItemCount=" + \aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount)
        ; debugMsg(sProcName, "calling WQK_setScaDMXItemsInnerHeight()")
        WQK_setScaDMXItemsInnerHeight()
        
      Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        nFromStep = 0
        If (\bChase) And (\nChaseSteps > 1)
          nUpToStep = \nChaseSteps - 1
        Else
          nUpToStep = 0
        EndIf
        Select nButtonId
          Case #SCS_STANDARD_BTN_MOVE_UP  ; move row up
            sUndoDesc = "Move Fixture Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            nNewItemIndex = nCurrItemIndex - 1
            rLTSubFixture = \aLTFixture(nCurrItemIndex)
            \aLTFixture(nCurrItemIndex) = \aLTFixture(nNewItemIndex)
            \aLTFixture(nNewItemIndex) = rLTSubFixture
            For nStepIndex = nFromStep To nUpToStep
              rFixtureItem = \aChaseStep(nStepIndex)\aFixtureItem(nCurrItemIndex)
              \aChaseStep(nStepIndex)\aFixtureItem(nCurrItemIndex) = \aChaseStep(nStepIndex)\aFixtureItem(nNewItemIndex)
              \aChaseStep(nStepIndex)\aFixtureItem(nNewItemIndex) = rFixtureItem
            Next nStepIndex
            WQK_commonUpdateProcessing()
            WQK_displayInfoForEntryType(nNewItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_MOVE_DOWN  ; move row down
            sUndoDesc = "Move Fixture Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            nNewItemIndex = nCurrItemIndex + 1
            rLTSubFixture = \aLTFixture(nCurrItemIndex)
            \aLTFixture(nCurrItemIndex) = \aLTFixture(nNewItemIndex)
            \aLTFixture(nNewItemIndex) = rLTSubFixture
            For nStepIndex = nFromStep To nUpToStep
              rFixtureItem = \aChaseStep(nStepIndex)\aFixtureItem(nCurrItemIndex)
              \aChaseStep(nStepIndex)\aFixtureItem(nCurrItemIndex) = \aChaseStep(nStepIndex)\aFixtureItem(nNewItemIndex)
              \aChaseStep(nStepIndex)\aFixtureItem(nNewItemIndex) = rFixtureItem
            Next nStepIndex
            WQK_commonUpdateProcessing()
            WQK_displayInfoForEntryType(nNewItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_PLUS  ; insert row
            sUndoDesc = "Insert Fixture Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            ; move this and following items down one position
            \nMaxFixture + 1
            If \nMaxFixture > ArraySize(\aLTFixture())
              REDIM_ARRAY(\aLTFixture, \nMaxFixture, grLTSubFixtureDef, "aLTFixture()")
              ReDim grWQK\nChanIndex1(\nMaxFixture)
            EndIf
            For nStepIndex = nFromStep To nUpToStep
              If \nMaxFixture > ArraySize(\aChaseStep(nStepIndex)\aFixtureItem())
                ReDim \aChaseStep(nStepIndex)\aFixtureItem(\nMaxFixture)
                debugMsg(sProcName, "ReDim \aChaseStep(" + nStepIndex + ")\aFixtureItem(" + \nMaxFixture + ")")
              EndIf
            Next nStepIndex
            For n = \nMaxFixture To (nCurrItemIndex + 1) Step -1
              \aLTFixture(n) = \aLTFixture(n-1)
              For nStepIndex = nFromStep To nUpToStep
                \aChaseStep(nStepIndex)\aFixtureItem(n) = \aChaseStep(nStepIndex)\aFixtureItem(n-1)
              Next nStepIndex
            Next n
            ; clear this item
            \aLTFixture(nCurrItemIndex) = grLTSubFixtureDef
            For nStepIndex = nFromStep To nUpToStep
              \aChaseStep(nStepIndex)\aFixtureItem(nCurrItemIndex) = rFixtureItemDef
            Next nStepIndex
            WQK_commonUpdateProcessing()
            WQK_displayInfoForEntryType(nCurrItemIndex)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_MINUS  ; delete row
            sUndoDesc = "Remove Fixture Item"
            u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrItemIndex)
            For n = nCurrItemIndex To (\nMaxFixture - 1)
              \aLTFixture(n) = \aLTFixture(n+1)
              For nStepIndex = nFromStep To nUpToStep
                \aChaseStep(nStepIndex)\aFixtureItem(n) = \aChaseStep(nStepIndex)\aFixtureItem(n+1)
              Next nStepIndex
            Next n
            \nMaxFixture - 1
            nGoToRow = nCurrItemIndex
            If nGoToRow > \nMaxFixture
              nGoToRow = \nMaxFixture
            EndIf
            WQK_commonUpdateProcessing()
            WQK_displayInfoForEntryType(nGoToRow)
            postChangeSubL(u, #False, -5, nCurrItemIndex, sUndoDesc)
            
          Case #SCS_STANDARD_BTN_COPY ; copy fixture items
            grLightingCueClipboard\rChaseStep = \aChaseStep(nCurrStepIndex)
            grLightingCueClipboard\nMaxFixture = \nMaxFixture
            CopyArray(\aLTFixture(), grLightingCueClipboard\aLTSubFixture())
            gsClipChaseStepDescr = getSubLabel(nEditSubPtr) + " " + Trim(GGT(WQK\lblDMXItems))
            gbClipChaseStepPopulatedFI = #True
            debugMsg(sProcName, "(copy) nCurrItemIndex=" + nCurrStepIndex + ", grLightingCueClipboard\nMaxFixture=" + grLightingCueClipboard\nMaxFixture)
            
          Case #SCS_STANDARD_BTN_PASTE  ; paste fixture items
            If (gbClipChaseStepPopulatedFI) And (nCurrStepIndex = 0) And (grLightingCueClipboard\nMaxFixture >= 0)
              sUndoDesc = "Paste Fixture Items"
              u = preChangeSubL(#True, sUndoDesc, -5, #SCS_UNDO_ACTION_CHANGE, nCurrStepIndex)
              debugMsg(sProcName, "(paste) nCurrStepIndex=" + nCurrStepIndex + ", grLightingCueClipboard\nMaxFixture=" + grLightingCueClipboard\nMaxFixture)
              \aChaseStep(nCurrStepIndex) = grLightingCueClipboard\rChaseStep
              \nMaxFixture = grLightingCueClipboard\nMaxFixture
              CopyArray(grLightingCueClipboard\aLTSubFixture(), \aLTFixture())
              WQK_commonUpdateProcessing()
              WQK_displayInfoForEntryType()
              postChangeSubL(u, #False, -5, nCurrStepIndex, sUndoDesc)
            EndIf
            
        EndSelect
        
    EndSelect
    
    WQK_setTBSButtons()
    WQK_setLightingTestButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_formValidation()
  PROCNAMECS(nEditSubPtr)
  Protected bValidationOK = #True
  
  debugMsg(sProcName, #SCS_START)
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQK_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WQK_commonUpdateProcessing()
  ; PROCNAMECS(nEditSubPtr)

  DMX_setDMXItemCount(nEditSubPtr)
  WQK_buildAndDisplayLightingMessage()
  setSubLTDisplayInfo(@aSub(nEditSubPtr)) ; Added 11Jul2023 11.10.0bq
  WQK_setResetButtonEnabledState()
  If grWQK\bLiveDMXTest
    DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
  EndIf
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, -1, #True)
  
EndProcedure

Procedure WQK_txtDMXItemStr_Validate(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u, nGadgetNo
  Protected sItem.s
  Protected sText.s, sDMXItemStr.s, sComment.s
  Protected nErrorCode, sErrorMsg.s
  Protected nProdDevNo
  Protected nCurrStepIndex, sCurrFixtureCodes.s
  Protected sReformattedStr.s
  Protected bNewRowAdded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nGadgetNo = WQKItem()\txtDMXItemStr
  ; debugMsg(sProcName, "nGadgetNo=" + nGadgetNo + ", ListIndex(WQKItem())=" + ListIndex(WQKItem()))
  sText = GGT(nGadgetNo)
  sReformattedStr = DMX_reformatDMXItemStr(sText)
  If sReformattedStr <> sText
    sText = sReformattedStr
    SGT(nGadgetNo, sText)
  EndIf
  sComment = RTrim(StringField(sText, 2, "//"))
  sDMXItemStr = RemoveString(StringField(sText, 1, "//"), " ")  ; removes ALL spaces, not just those at the beginning and end
  sItem = GGT(WQK\lblDMXItems) + " [" + Str(Index+1) + "]"  ; eg "DMX Channels [2]" for the DMX channels on the 2nd row
  debugMsg(sProcName, "sItem=" + sItem + ", sDMXItemStr=" + sDMXItemStr + ", sComment=" + sComment)
  
  nCurrStepIndex = grWQK\nCurrStepIndex
  sCurrFixtureCodes = DMX_getCurrFixtureCodes(nEditSubPtr, nCurrStepIndex, Index)
  
  If sDMXItemStr
    nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
    nErrorCode = DMX_valDMXItemStr(sDMXItemStr, nProdDevNo, sCurrFixtureCodes)
    If nErrorCode > 0
      debugMsg2(sProcName, "DMX_valDMXItemStr(" + #DQUOTE$ + sDMXItemStr + #DQUOTE$ + ", " + nProdDevNo + ", " + #DQUOTE$ + sCurrFixtureCodes + #DQUOTE$ + ")", nErrorCode)
      Select nErrorCode
        Case 40500 To 40599
          ; Changed 15Mar2022 11.9.1an
          ; sErrorMsg = LangPars("Errors", "DMXChannelLimit", Str(grLicInfo\nMaxDMXChannel))
          DMX_ChannelLimitWarning()
          sErrorMsg = ""
          ; End changed 15Mar2022 11.9.1an
        Case 50100 To 59999
          sErrorMsg = Lang("Errors", "DMXItemStrFixtureInvalid")
        Default ; other error codes
          sErrorMsg = Lang("Errors", "DMXItemStrInvalid")
      EndSelect
    Else
      If LCase(Left(sDMXItemStr, 3)) <> "dbo"
        If CountString(sDMXItemStr,"@") = 0
          sDMXItemStr + "@0"
          If sComment
            SGT(nGadgetNo, sDMXItemStr + " //" + sComment)
          Else
            SGT(nGadgetNo, sDMXItemStr)
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  If sErrorMsg
    debugMsg(sProcName, "sErrorMgs=" + sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    grWQK\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  ; Moved here 23Jun2021 11.8.5am following bug reported by Michel Winogradoff (was previously AFTER code that accessed aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem(Index)\sDMXItemStr) so that code crashed if Index was out of range
  ; added 3Feb2020 11.8.2.2af
  If Index > aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount - 1
    aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount = Index + 1
    If Index > ArraySize(aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem())
      ReDim aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem(Index)
    EndIf
    bNewRowAdded = #True
    ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + nCurrStepIndex + ")\nDMXSendItemCount=" + aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount)
  EndIf
  ; end added 3Feb2020 11.8.2.2af
  ; End moved here 23Jun2021 11.8.5am following bug reported by Michel Winogradoff
  
  ; Added 23Jun2021 11.8.5am to try to sort out bug reported by Michel Winogradoff
  ; debugMsg(sProcName, "nCurrStepIndex=" + nCurrStepIndex + ", ArraySize(aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep()=" + ArraySize(aSub(nEditSubPtr)\aChaseStep()))
  CheckSubInRange(nCurrStepIndex, ArraySize(aSub(nEditSubPtr)\aChaseStep()), "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep()")
  ; debugMsg(sProcName, "Index=" + Index + ", ArraySize(aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + nCurrStepIndex + ")\aDMXSendItem())=" + ArraySize(aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem()))
  CheckSubInRange(Index, ArraySize(aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem()), "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + nCurrStepIndex + ")\aDMXSendItem")
  ; End added 23Jun2021 11.8.5am to try to sort out bug reported by Michel Winogradoff
  
  With aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem(Index)
    u = preChangeSubS(\sDMXItemStr, sItem)
    \sDMXItemStr = sDMXItemStr
    If sComment
      If sDMXItemStr
        \sDMXItemStr + " //" + sComment
      Else
        \sDMXItemStr = "//" + sComment
      EndIf
    EndIf
;     ; added 3Feb2020 11.8.2.2af (23Jun2021 11.8.5am: moved further up this Procedure)
;     If Index > aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount - 1
;       aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount = Index + 1
;       If Index > ArraySize(aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem())
;         ReDim aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem(Index)
;       EndIf
;       bNewRowAdded = #True
;       ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + nCurrStepIndex + ")\nDMXSendItemCount=" + aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\nDMXSendItemCount)
;     EndIf
;     ; end added 3Feb2020 11.8.2.2af
    DMX_unpackDMXSendItemStr(@aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aDMXSendItem(Index), @grProd, aSub(nEditSubPtr)\sLTLogicalDev) ; populates \sDMXChannels, \nDMXValue, etc
    WQK_setSldDMXValueMax(nEditSubPtr, Index)
    ; debugMsg(sProcName, "calling SLD_setValue(WQKItem()\sldDMXValue, " + \nDMXDisplayValue + ")")
    SLD_setValue(WQKItem()\sldDMXValue, \nDMXDisplayValue)
    ; debugMsg(sProcName, "ListIndex(WQKItem())=" + ListIndex(WQKItem()) + ", \aChaseStep(" + nCurrStepIndex + ")\aDMXSendItem(" + Index + ")\sDMXItemStr=" + \sDMXItemStr)
    If \bDBO Or Len(Trim(\sDMXItemStr)) = 0
      SLD_setEnabled(WQKItem()\sldDMXValue, #False)
    Else
      SLD_setEnabled(WQKItem()\sldDMXValue, #True)
    EndIf
    WQK_commonUpdateProcessing()
    postChangeSubS(u, \sDMXItemStr)
  EndWith
  
  WQK_setDMXItemStrTooltip(Index)
  If bNewRowAdded
    WQK_createExtraRowForInserts()
    WQK_setScaDMXItemsInnerHeight()
  EndIf
  WQK_setTBSButtons()
  
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_setDMXItemStrTooltip(Index)
  Protected sTooltip.s
  Static sDefaultTooltip.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sDefaultTooltip = Lang("WQK", "txtDMXItemStrTT")
    bStaticLoaded = #True
  EndIf
  
  With aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(Index)
    If Trim(\sDMXItemStr)
      sTooltip = Trim(\sDMXItemStr)
    Else
      sTooltip = sDefaultTooltip
    EndIf
    scsToolTip(WQKItem()\txtDMXItemStr, sTooltip)
  EndWith
  
EndProcedure

Procedure WQK_sldDMXValueCommon(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected dNewDisplayValue.d, dNewValue.d
  Protected sItem.s
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", grWQK\nSelectedItem=" + grWQK\nSelectedItem)
  
  If grWQK\nSelectedItem <> Index
    debugMsg(sProcName, "calling WQK_setCurrentItemInfo(" + Index + ")")
    WQK_setCurrentItemInfo(Index)
  EndIf
  
  sItem = GGT(WQK\lblDMXValue) + " [" + Str(Index+1) + "]"  ; eg "DMX Value [2]" for the DMX channel on the 2nd row
  
  With aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(Index)
    dNewDisplayValue = SLD_getValue(WQKItem()\sldDMXValue)
    If \bDMXAbsValue
      dNewValue = dNewDisplayValue
    Else
      dNewValue = dNewDisplayValue * 2.55
    EndIf
    ; debugMsg(sProcName, "Index=" + Index + ", ListIndex(WQKItem())=" + ListIndex(WQKItem()) +
    ;                     ", \aChaseStep(" + grWQK\nCurrStepIndex + ")\aDMXSendItem(" + Index + ")\nDMXValue=" + \nDMXValue + ", nNewValue=" + nNewValue)
    If \nDMXValue <> dNewValue
      u = preChangeSubL(\nDMXValue, sItem) ; Changed 19Jul2022
      \nDMXValue = dNewValue
      \nDMXDisplayValue = dNewDisplayValue
      DMX_packDMXSendItemStr(@aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(Index)) ; nb populates \sDMXItemStr
      SGT(WQKItem()\txtDMXItemStr, \sDMXItemStr)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      postChangeSubL(u, \nDMXValue)
      If grWQK\bLiveDMXTest
        ; debugMsg(sProcName, "calling prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, " + StrB(grWQK\bLiveDMXTest) + ")")
        DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
      EndIf
      WQK_setDMXItemStrTooltip(Index)
      WQK_setResetButtonEnabledState()
    EndIf
  EndWith
  
EndProcedure

Procedure WQK_makeTBS()
  ; PROCNAMECS(nEditSubPtr)
  Protected n

  ; debugMsg(sProcName, #SCS_START)
  
  For n = 0 To 3
    setEnabled(WQK\imgQKButtonTBS[n], #True)
  Next n

EndProcedure

Procedure WQK_enableTBSButton(nButtonType, bEnable, sToolTipText.s = "")
  ; PROCNAMEC()
  Protected nIndex
  
  nIndex = WQK_getTBSIndex(nButtonType)
  
  setEnabled(WQK\imgQKButtonTBS[nIndex], bEnable)
  If Len(sToolTipText) > 0
    scsToolTip(WQK\imgQKButtonTBS[nIndex], sToolTipText)
  EndIf
  
EndProcedure

Procedure WQK_setCurrentItemInfo(Index)
  ; PROCNAMECS(nEditSubPtr)
  Protected nListIndex, nColor
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With grWQK
    \nSelectedItem = Index
    ForEach WQKItem()
      nListIndex = ListIndex(WQKItem())
      If nListIndex = \nSelectedItem
        nColor = #SCS_Blue
      Else
        nColor = #SCS_Very_Light_Grey
      EndIf
      If StartDrawing(CanvasOutput(WQKItem()\cvsItemNo))
        Box(0, 0, OutputWidth(), OutputHeight(), nColor)
        StopDrawing()
      EndIf
    Next WQKItem()
    SelectElement(WQKItem(), Index)
  EndWith
  
  ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
  WQK_doLiveDMXTestIfReqd()
  
  ; debugMsg(sProcName, "ListSize(WQKItem())=" + ListSize(WQKItem()) + ", ListIndex(WQKItem())=" + ListIndex(WQKItem()))
  ; debugMsg(sProcName, "IsGadget(WQKItem()\cvsItemNo)=" + IsGadget(WQKItem()\cvsItemNo))
  ensureScrollAreaItemVisible(WQK\scaDMXItems, GadgetHeight(WQKItem()\cvsItemNo), Index)
  WQK_setTBSButtons()

EndProcedure

Procedure WQK_cvsItemNo_Click(Index)
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, "calling WQK_setCurrentItemInfo(" + Index + ")")
  WQK_setCurrentItemInfo(Index)
  SAG(-1)
  
EndProcedure

Procedure WQK_setCurrentFixtureInfo(nReqdFixtureIndex)
  PROCNAMECS(nEditSubPtr)
  Protected m, n, nColor
  Protected nProdDevNo
  ; Protected nDevMapDevPtr, nDMXStartChannel  ; decided not to display the actual DMX channels as having too many numbers (relative channel, DMX channel and DMX value) can be confusing
  Protected nCurrStepIndex, sFixtureCode.s, nChanIndex
  Protected nFixtureIndex, sFixTypeName.s, nFixTypeIndex=-1, nTotalChans, nInternalHeight1
  Protected sDMXDisplayValue.s, nDMXDisplayValue, sFixtureChannel.s
  Protected nScrollStep
  Static sDMXValue2.s, nMaxWidthForLblDMXValue2
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex)
  
  If bStaticLoaded = #False
    sDMXValue2 = Lang("WQK","lblDMXValue2")
    nMaxWidthForLblDMXValue2 = GadgetX(WQK\lblFade) - GadgetX(WQK\lblDMXValue2) - gnGap
    bStaticLoaded = #True
  EndIf
  
  nFixtureIndex = nReqdFixtureIndex
  
  grWQK\nSelectedFixture = nFixtureIndex
  
  For m = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
    If m = nFixtureIndex
      nColor = #SCS_Blue
    Else
      nColor = #SCS_Very_Light_Grey
    EndIf
    StartDrawing(CanvasOutput(WQK\cvsFixtureNo[m]))
    Box(0, 0, OutputWidth(), OutputHeight(), nColor)
    LineXY(0, 0, OutputWidth(), 0, #SCS_Light_Grey)
    LineXY(0, OutputHeight()-1, OutputWidth(), OutputHeight()-1, #SCS_Light_Grey)
    StopDrawing()
  Next m
  
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
  ; nDevMapDevPtr = getDevMapDevPtrForLogicalDev(#SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev, #False)
  
  nCurrStepIndex = grWQK\nCurrStepIndex
  If (nCurrStepIndex >= 0) And (nFixtureIndex >= 0)
    If nFixtureIndex <= aSub(nEditSubPtr)\nMaxFixture
      sFixtureCode = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
      For n = 0 To grProd\aLightingLogicalDevs(nProdDevNo)\nMaxFixture
        If grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixtureCode = sFixtureCode
          sFixTypeName = grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixTypeName
          Break
        EndIf
      Next n
      nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
      If nFixTypeIndex >= 0
        nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
      EndIf
    EndIf
    ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", sFixTypeName=" + sFixTypeName + ", nFixTypeIndex=" + nFixTypeIndex + ", nTotalChans=" + nTotalChans)
    SGT(WQK\lblDMXValue2, ReplaceString(sDMXValue2, "$1", sFixtureCode))
    setGadgetWidth(WQK\lblDMXValue2, -1, #False, nMaxWidthForLblDMXValue2)
    If sFixtureCode
      With aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)
        For nChanIndex = 0 To nTotalChans-1
          WQK_setSldFixtureChannelValueMax(nEditSubPtr, nFixtureIndex, nChanIndex)
          sFixtureChannel = Str(nChanIndex+1) + ": " + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\sChannelDesc
          SGT(WQK\txtFixtureChannel[nChanIndex], sFixtureChannel)
          scsToolTip(WQK\txtFixtureChannel[nChanIndex], sFixtureChannel)
          If \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bRelChanIncluded
            setOwnState(WQK\chkFixtureChanIncluded[nChanIndex], #PB_Checkbox_Checked)
          Else
            setOwnState(WQK\chkFixtureChanIncluded[nChanIndex], #PB_Checkbox_Unchecked)
          EndIf
          WQK_fcFixtureChanIncluded(nFixtureIndex, nChanIndex)
          sDMXDisplayValue = \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue
          If sDMXDisplayValue
            SGT(WQK\txtFixtureChannelValue[nChanIndex], sDMXDisplayValue)
          Else
            SGT(WQK\txtFixtureChannelValue[nChanIndex], "0")
          EndIf
          nDMXDisplayValue = \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nDMXDisplayValue
          SLD_setValue(WQK\sldFixtureChannelValue[nChanIndex], nDMXDisplayValue)
          If (\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bApplyFadeTime) And (aSub(nEditSubPtr)\bChase = #False)
            setOwnState(WQK\chkFixtureChanApplyFadeTime[nChanIndex], #PB_Checkbox_Checked)
          Else
            setOwnState(WQK\chkFixtureChanApplyFadeTime[nChanIndex], #PB_Checkbox_Unchecked)
          EndIf
        Next nChanIndex
      EndWith
    EndIf
  EndIf
  nScrollStep = GetGadgetAttribute(WQK\scaFixtureChans, #PB_ScrollArea_ScrollStep)
  nInternalHeight1 = nTotalChans * nScrollStep
  SetGadgetAttribute(WQK\scaFixtureChans, #PB_ScrollArea_InnerHeight, nInternalHeight1)
  
  WQK_setChkInclude(nFixtureIndex)
  
  ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
  WQK_doLiveDMXTestIfReqd()
  
  ensureScrollAreaItemVisible(WQK\scaFixtures, nScrollStep, nReqdFixtureIndex)
  WQK_setTBSButtons()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_getFirstIncludedFadeableChannel(nCurrStepIndex, nFixtureIndex, nTotalChans)
  PROCNAMECS(nEditSubPtr)
  Protected nChanIndex, nFirstIncludeChan, n
  
  With aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)
    ; find first included fadeable channel, or use first channel if no included channels marked as fadeable
    nChanIndex = -1
    nFirstIncludeChan = -1
    For n = 0 To nTotalChans-1
      If \aFixtureItem(nFixtureIndex)\aFixChan(n)\bRelChanIncluded
        If nFirstIncludeChan < 0
          nFirstIncludeChan = n
        EndIf
        If \aFixtureItem(nFixtureIndex)\aFixChan(n)\bApplyFadeTime
          nChanIndex = n
          Break
        EndIf
      EndIf
    Next n
    If nChanIndex < 0
      If nFirstIncludeChan >= 0
        nChanIndex = nFirstIncludeChan
      Else
        nChanIndex = 0
      EndIf
    EndIf
  EndWith
  ProcedureReturn nChanIndex
EndProcedure

Procedure WQK_setCurrentFixtureInfo1(nReqdFixtureIndex)
  PROCNAMECS(nEditSubPtr)
  Protected n, nColor
  Protected nProdDevNo
  Protected nCurrStepIndex, sFixtureCode.s, nChanIndex, nFirstIncludeChan
  Protected nFixtureIndex, sFixTypeName.s, nFixTypeIndex=-1, nTotalChans, nInternalHeight1
  Protected sDMXDisplayValue.s, nDMXDisplayValue, sFixtureChannel.s
  Protected nScrollStep
  
  debugMsg(sProcName, #SCS_START + ", nReqdFixtureIndex=" + nReqdFixtureIndex)
  
  If grLicInfo\nMaxFixtureItemPerLightingSub > ArraySize(grWQK\nChanIndex1())
    ReDim grWQK\nChanIndex1(grLicInfo\nMaxFixtureItemPerLightingSub)
  EndIf
  
  grWQK\nSelectedFixture = nReqdFixtureIndex
  For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
    If n = nReqdFixtureIndex
      nColor = #SCS_Blue
    Else
      nColor = #SCS_Very_Light_Grey
    EndIf
    StartDrawing(CanvasOutput(WQK\aFix1(n)\cvsFixtureNo1))
    Box(0, 0, OutputWidth(), OutputHeight(), nColor)
    LineXY(0, 0, OutputWidth(), 0, #SCS_Light_Grey)
    LineXY(0, OutputHeight()-1, OutputWidth(), OutputHeight()-1, #SCS_Light_Grey)
    StopDrawing()
  Next n
  
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
  nCurrStepIndex = grWQK\nCurrStepIndex
  If nCurrStepIndex >= 0
    For nFixtureIndex = 0 To grLicInfo\nMaxFixtureItemPerLightingSub ; #SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB ; Changed 7Jul2024 11.10.3ar
      If nFixtureIndex <= aSub(nEditSubPtr)\nMaxFixture
        sFixtureCode = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
        sFixTypeName = ""
        nTotalChans = 0
        For n = 0 To grProd\aLightingLogicalDevs(nProdDevNo)\nMaxFixture
          If grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixtureCode = sFixtureCode
            sFixTypeName = grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixTypeName
            Break
          EndIf
        Next n
        nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
        If nFixTypeIndex >= 0
          nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
        EndIf
        ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sFixtureCode(" + nFixtureIndex + ")=" + aSub(nEditSubPtr)\sFixtureCode(nFixtureIndex) + ", sFixTypeName=" + sFixTypeName + ", nFixTypeIndex=" + nFixTypeIndex + ", nTotalChans=" + nTotalChans)
        If sFixtureCode
          With aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)
            ; find first included fadeable channel, or use first channel if no included channels marked as fadeable
            nChanIndex = WQK_getFirstIncludedFadeableChannel(nCurrStepIndex, nFixtureIndex, nTotalChans)
            grWQK\nChanIndex1(nFixtureIndex) = nChanIndex
            WQK_setSldFixtureChannelValueMax(nEditSubPtr, nFixtureIndex, nChanIndex)
            sFixtureChannel = Str(nChanIndex+1) + ": " + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\sChannelDesc
            SGT(WQK\aFix1(nFixtureIndex)\txtFixtureChannel1, sFixtureChannel)
            scsToolTip(WQK\aFix1(nFixtureIndex)\txtFixtureChannel1, sFixtureChannel)
            If \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bRelChanIncluded
              setOwnState(WQK\aFix1(nFixtureIndex)\chkFixtureChanIncluded1, #PB_Checkbox_Checked)
            Else
              setOwnState(WQK\aFix1(nFixtureIndex)\chkFixtureChanIncluded1, #PB_Checkbox_Unchecked)
            EndIf
            WQK_fcFixtureChanIncluded(nFixtureIndex, nChanIndex)
            sDMXDisplayValue = \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue
            If sDMXDisplayValue
              SGT(WQK\aFix1(nFixtureIndex)\txtFixtureChannelValue1, sDMXDisplayValue)
            Else
              SGT(WQK\aFix1(nFixtureIndex)\txtFixtureChannelValue1, "0")
            EndIf
            nDMXDisplayValue = \aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nDMXDisplayValue
            SLD_setValue(WQK\aFix1(nFixtureIndex)\sldFixtureChannelValue1, nDMXDisplayValue)
            If (\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bApplyFadeTime) And (aSub(nEditSubPtr)\bChase = #False)
              setOwnState(WQK\aFix1(nFixtureIndex)\chkFixtureChanApplyFadeTime1, #PB_Checkbox_Checked)
            Else
              setOwnState(WQK\aFix1(nFixtureIndex)\chkFixtureChanApplyFadeTime1, #PB_Checkbox_Unchecked)
            EndIf
          EndWith
        EndIf ; EndIf sFixtureCode
      EndIf ; EndIf nFixtureIndex <= aSub(nEditSubPtr)\nMaxFixture
      ; debugMsg(sProcName, "calling WQK_fcFixture1(" + nFixtureIndex + ")")
      WQK_fcFixture1(nFixtureIndex)
    Next nFixtureIndex
  EndIf ; EndIf nCurrStepIndex >= 0
  
  ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
  WQK_doLiveDMXTestIfReqd()
  nScrollStep = GetGadgetAttribute(WQK\scaFixtures1, #PB_ScrollArea_ScrollStep)
  ensureScrollAreaItemVisible(WQK\scaFixtures1, nScrollStep, nReqdFixtureIndex)
  WQK_setTBSButtons()

EndProcedure

Procedure WQK_cvsFixtureNo_Click(nFixtureIndex)
  PROCNAMECS(nEditSubPtr)
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      ; debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + nFixtureIndex + ")")
      WQK_setCurrentFixtureInfo(nFixtureIndex)
    Case #SCS_LT_DISP_1ST
      ; debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + nFixtureIndex + ")")
      WQK_setCurrentFixtureInfo1(nFixtureIndex)
  EndSelect
  SAG(-1)
  
EndProcedure

Procedure WQK_getTBSIndex(nButtonType)
  Protected n, nIndex
  
  nIndex = -1
  For n = 0 To 5
    If getButtonType(WQK\imgQKButtonTBS[n]) = nButtonType
      nIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nIndex
EndProcedure

Procedure WQK_setTBSButtons()
  PROCNAMECS(nEditSubPtr)
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsItem, sToolTipInsItem.s
  Protected bEnableDelItem, sToolTipDelItem.s
  Protected bEnableCopy, sToolTipCopy.s
  Protected bEnablePaste, sToolTipPaste.s
  Protected nItemNo, sDisplayInfo.s, bDisplayInfoPresent
  Protected nLastItem
  Protected n, nDevNo, nMaxFixture
  Static sCopyToClip.s, sPasteFromClip.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sCopyToClip = Lang("Common", "CopyToClip")
    sPasteFromClip = Lang("Common", "PasteFromClip")
    bStaticLoaded = #True
  EndIf
  
  nLastItem = -1
  ; debugMsg0(sProcName, "nLastItem=" + nLastItem)
  
  Select aSub(nEditSubPtr)\nLTEntryType
    Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
      nItemNo = grWQK\nSelectedItem
      For n = 0 To aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount - 1 ; #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB
        If Trim(aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(n)\sDMXItemStr)
          nLastItem = n
          ; debugMsg0(sProcName, "nLastItem=" + nLastItem)
        EndIf
      Next n
      ; debugMsg0(sProcName, "nItemNo=" + nItemNo + ", nLastItem=" + nLastItem + ", aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + grWQK\nCurrStepIndex + ")\nDMXSendItemCount=" + aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount)
      If (nItemNo >= 0) And (nItemNo <= nLastItem)
        ; debugMsg(sProcName, "ArraySize(aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep())=" + ArraySize(aSub(nEditSubPtr)\aChaseStep()))
        ; debugMsg(sProcName, "ArraySize(aSub(nEditSubPtr)\aChaseStep(" + grWQK\nCurrStepIndex + ")\aDMXSendItem())=" + ArraySize(aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem()))
        sDisplayInfo = Trim(aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(nItemNo)\sDMXItemStr)
        If sDisplayInfo
          bDisplayInfoPresent = #True
        EndIf
      EndIf
      If bDisplayInfoPresent = #False
        sDisplayInfo = "#" + Str(nItemNo + 1)
      EndIf
      debugMsg(sProcName, "sDisplayInfo=" + sDisplayInfo)
      
      If (nItemNo > 0) And (nItemNo <= nLastItem)
        bEnableMoveUp = #True
        sToolTipMoveUp = "Move up: " + sDisplayInfo
      EndIf
      If nItemNo < nLastItem
        bEnableMoveDown = #True
        sToolTipMoveDown = "Move down: " + sDisplayInfo
      EndIf
      If bDisplayInfoPresent
        If nLastItem < (aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount - 1) ; grLicInfo\nMaxDMXItemPerLightingSub
          bEnableInsItem = #True
          sToolTipInsItem = "Insert a DMX Item before: " + sDisplayInfo
        EndIf
      EndIf
      If (nLastItem >= 0) And (nItemNo <= nLastItem)
        ; debugMsg0(sProcName, "nItemNo=" + nItemNo + ", nLastItem=" + nLastItem + ", sDisplayInfo=" + sDisplayInfo)
        bEnableDelItem = #True
        sToolTipDelItem = "Remove: " + sDisplayInfo
      EndIf
      
      ; Copy and Paste buttons for DMX Items and Capture disabled 1Sep2020 11.8.3.2at as they are confusing because they operate at the entire 'chase step' level, not at the individual item level
      ; NOTE: Reinstated 20Feb2024 11.10.2as follwoing FB posting by Sascha Pirkowski
      If bDisplayInfoPresent
        bEnableCopy = #True
        sToolTipCopy = ReplaceString(sCopyToClip, "$1", getSubLabel(nEditSubPtr) + " " + Trim(GGT(WQK\lblDMXItems)))
      EndIf
      If gbClipChaseStepPopulated
        bEnablePaste = #True
        sToolTipPaste = ReplaceString(sPasteFromClip, "$1", gsClipChaseStepDescr)
      EndIf
      
    Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
      If (aSub(nEditSubPtr)\bChase) And (grWQK\nCurrStepIndex > 0)
        ; all sidebar buttons disabled if not in first step of a chase
      Else
        nItemNo = grWQK\nSelectedFixture
        nLastItem = aSub(nEditSubPtr)\nMaxFixture
        nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
        If nDevNo >= 0
          ; should be #True
          nMaxFixture = grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture
        EndIf
        
        If nItemNo >= 0
          sDisplayInfo = GGT(WQK\cboFixture[nItemNo])
        EndIf
        If sDisplayInfo
          bDisplayInfoPresent = #True
        Else
          sDisplayInfo = "#" + Str(nItemNo + 1)
          bDisplayInfoPresent = #False
        EndIf
        ; debugMsg(sProcName, "sDisplayInfo=" + sDisplayInfo)
        
        If (nItemNo > 0) And (nItemNo <= nLastItem)
          bEnableMoveUp = #True
          sToolTipMoveUp = "Move up: " + sDisplayInfo
        EndIf
        If nItemNo < nLastItem
          bEnableMoveDown = #True
          sToolTipMoveDown = "Move down: " + sDisplayInfo
        EndIf
        ; Deleted 10Nov2020 11.8.3.3ae - 'insert fixture' should never be enabled as there will be one line already displayed for every defined fixture (although not initially assigned)
        ; If bDisplayInfoPresent
        ;   If (nLastItem < grLicInfo\nMaxDMXItemPerLightingSub)
        ;     bEnableInsItem = #True
        ;     sToolTipInsItem = "Insert a Fixture before: " + sDisplayInfo
        ;   EndIf
        ; EndIf
        ; End deleted 10Nov2020 11.8.3.3ae
        ; Reinstated 19Aug2021 11.8.5.1ac because now there is NOT one line already displayed for every defined fixture
        If bDisplayInfoPresent
          ; If nLastItem < grLicInfo\nMaxDMXItemPerLightingSub
          If nLastItem < nMaxFixture
            bEnableInsItem = #True
            sToolTipInsItem = "Insert a Fixture before: " + sDisplayInfo
          EndIf
        EndIf
        ; End reinstated 19Aug2021 11.8.5.1ac
        If (nLastItem >= 0) And (nItemNo <= nLastItem)
          bEnableDelItem = #True
          sToolTipDelItem = "Remove: " + sDisplayInfo
        EndIf
      EndIf
      
      If aSub(nEditSubPtr)\bChase = #False
        If bDisplayInfoPresent
          bEnableCopy = #True
          sToolTipCopy = ReplaceString(sCopyToClip, "$1", getSubLabel(nEditSubPtr) + " " + Trim(GGT(WQK\lblDMXItems)))
        EndIf
        If gbClipChaseStepPopulatedFI
          bEnablePaste = #True
          sToolTipPaste = ReplaceString(sPasteFromClip, "$1", gsClipChaseStepDescr)
        EndIf
      EndIf
      
  EndSelect
  
  ; debugMsg(sProcName, "bEnableInsItem=" + strB(bEnableInsItem))
  WQK_enableTBSButton(#SCS_STANDARD_BTN_MOVE_UP, bEnableMoveUp, sToolTipMoveUp)
  WQK_enableTBSButton(#SCS_STANDARD_BTN_MOVE_DOWN, bEnableMoveDown, sToolTipMoveDown)
  WQK_enableTBSButton(#SCS_STANDARD_BTN_PLUS, bEnableInsItem, sToolTipInsItem)
  WQK_enableTBSButton(#SCS_STANDARD_BTN_MINUS, bEnableDelItem, sToolTipDelItem)
  WQK_enableTBSButton(#SCS_STANDARD_BTN_COPY, bEnableCopy, sToolTipCopy)
  WQK_enableTBSButton(#SCS_STANDARD_BTN_PASTE, bEnablePaste, sToolTipPaste)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_setLightingTestButtons()
  PROCNAMECS(nEditSubPtr)
  Protected m, n
  Protected bEnableAll
  Protected bDMXSend
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      bDMXSend = \bDMXSend
      If bDMXSend
        For n = 0 To \nMaxChaseStepIndex
          For m = 0 To \aChaseStep(n)\nDMXSendItemCount - 1 ; grLicInfo\nMaxDMXItemPerLightingSub
            If \aChaseStep(n)\aDMXSendItem(m)\sDMXItemStr
              bEnableAll = #True
              Break 2
            EndIf
          Next m
        Next n
      EndIf
    EndWith
  EndIf
  
  If bDMXSend
    setVisible(WQK\chkLiveDMXTest, #True)
  Else
    setVisible(WQK\chkLiveDMXTest, #False)
  EndIf
  
EndProcedure

Procedure WQK_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQK
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQK)
        
        ; detail gadgets
      Case \txtBLFadeTime
        ETVAL2(WQK_txtBLFadeUserTime_Validate())
        
      Case \txtChaseSpeed
        ETVAL2(WQK_txtChaseSpeed_Validate())
        
      Case \txtChaseSteps
        ETVAL2(WQK_txtChaseSteps_Validate())
        
      Case \txtDCFadeDownTime
        ETVAL2(WQK_txtDCFadeDownUserTime_Validate())
        
      Case \txtDCFadeOutOthersTime
        ETVAL2(WQK_txtDCFadeOutOthersUserTime_Validate())
        
      Case \txtDCFadeUpTime
        ETVAL2(WQK_txtDCFadeUpUserTime_Validate())
        
      Case \txtDIFadeDownTime
        ETVAL2(WQK_txtDIFadeDownUserTime_Validate())
        
      Case \txtDIFadeOutOthersTime
        ETVAL2(WQK_txtDIFadeOutOthersUserTime_Validate())
        
      Case \txtDIFadeUpTime
        ETVAL2(WQK_txtDIFadeUpUserTime_Validate())
        
      Case #SCS_G4EH_QK_TXTDMXITEMSTR ; \txtDMXItemStr
        ETVAL2(WQK_txtDMXItemStr_Validate(WQK_calcGadgetRow()))
        
      Case \txtFIFadeDownTime
        ETVAL2(WQK_txtFIFadeDownUserTime_Validate())
        
      Case \txtFIFadeOutOthersTime
        ETVAL2(WQK_txtFIFadeOutOthersUserTime_Validate())
        
      Case \txtFIFadeUpTime
        ETVAL2(WQK_txtFIFadeUpUserTime_Validate())
        
      Case \txtFixtureChannelValue[0]
        ETVAL2(WQK_txtFixtureChannelValue_Validate(nArrayIndex))
        
      Case \txtFixtureLinkGroup[0]
        ETVAL2(WQK_txtFixtureLinkGroup_Validate(nArrayIndex))
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      debugMsg(sProcName, "returning #True (a)")
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    debugMsg(sProcName, "returning #True (b)")
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WQK__EventHandler()
  PROCNAMECS(nEditSubPtr)
  Protected bFound
  Protected nEventGadgetNo, nActiveGadgetNo, nEventGadgetPropsIndex, nActiveGadgetPropsIndex, nEventGadgetArrayIndex, nActiveGadgetArrayIndex
  
  With WQK
    
    If gnEventSliderNo > 0
      
      ; debugMsg0(sProcName, "gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=" + gnEventSliderNo + ", gnEventGadgetNo=" + gnEventGadgetNo + ", gnEventGadgetNoForEvHdlr=" + gnEventGadgetNoForEvHdlr + ", #SCS_G4EH_QK_SLDDMXVALUE=" + #SCS_G4EH_QK_SLDDMXVALUE)
      
      If gnEventGadgetNoForEvHdlr = #SCS_G4EH_QK_SLDDMXVALUE
        bFound = #True
        Select gnSliderEvent
          Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
            WQK_sldDMXValueCommon(WQK_calcGadgetRow())
        EndSelect
        
      ElseIf gnEventGadgetArrayIndex <= #SCS_MAX_DMX_ITEM_PER_LIGHTING_SUB
        Select gnEventSliderNo
          Case \sldFixtureChannelValue[gnEventGadgetArrayIndex], \aFix1(gnEventGadgetArrayIndex)\sldFixtureChannelValue1
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQK_sldFixtureChannelValueCommon(gnEventGadgetArrayIndex)
            EndSelect
        EndSelect
      EndIf
      
      If bFound = #False
        If gnEventGadgetArrayIndex <= ArraySize(\aFix1())
          Select gnEventSliderNo
            Case \aFix1(gnEventGadgetArrayIndex)\sldFixtureChannelValue1
              bFound = #True
              Select gnSliderEvent
                Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                  WQK_sldFixtureChannelValueCommon(gnEventGadgetArrayIndex)
              EndSelect
          EndSelect
        EndIf
      EndIf
      
      If bFound
        ProcedureReturn
      EndIf
      
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Menu
        Select gnEventMenu
          Case #SCS_WEDK_TapDelay
            WQK_processTapDelayShortcut()
        EndSelect
        
      Case #PB_Event_Gadget
        If gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId)
          Select gnEventButtonId
            Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS, #SCS_STANDARD_BTN_COPY, #SCS_STANDARD_BTN_PASTE
              WQK_imgQKButtonTBS_Click(gnEventButtonId)
          EndSelect
          
        Else
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQK)
              
              ; detail gadgets in alphabetical order
            Case \btnNextStep
              WQK_btnNext_Click()
              
            Case \btnPrevStep
              WQK_btnPrev_Click()
              
            Case \btnReset
              WQK_btnReset_Click()
              
            Case \cboBLFadeAction
              CBOCHG(WQK_cboBLFadeAction_Click())
              
            Case \cboChaseMode
              CBOCHG(WQK_cboChaseMode_Click())
              
            Case \cboDCFadeDownAction
              CBOCHG(WQK_cboDCFadeDownAction_Click())
              
            Case \cboDCFadeOutOthersAction
              CBOCHG(WQK_cboDCFadeOutOthersAction_Click())
              
            Case \cboDCFadeUpAction
              CBOCHG(WQK_cboDCFadeUpAction_Click())
              
            Case \cboDIFadeDownAction
              CBOCHG(WQK_cboDIFadeDownAction_Click())
              
            Case \cboDIFadeOutOthersAction
              CBOCHG(WQK_cboDIFadeOutOthersAction_Click())
              
            Case \cboDIFadeUpAction
              CBOCHG(WQK_cboDIFadeUpAction_Click())
              
            Case \cboEntryType
              CBOCHG(WQK_cboEntryType_Click())
              
            Case \cboFIFadeDownAction
              CBOCHG(WQK_cboFIFadeDownAction_Click())
              
            Case \cboFIFadeOutOthersAction
              CBOCHG(WQK_cboFIFadeOutOthersAction_Click())
              
            Case \cboFIFadeUpAction
              CBOCHG(WQK_cboFIFadeUpAction_Click())
              
            Case \cboFixture[0], \aFix1(0)\cboFixture1
              CBOCHG(WQK_cboFixture_Click(gnEventGadgetArrayIndex))
              
            Case \cboFixtureDisplay
              CBOCHG(WQK_cboFixtureDisplay_Click())
              
            Case \cboLogicalDev
              CBOCHG(WQK_cboLogicalDev_Click())
              
            Case \chkApplyCurrValuesAsMins
              CHKOWNCHG(WQK_chkApplyCurrValuesAsMins_Click())
              
            Case \chkChase
              CHKOWNCHG(WQK_chkChase_Click())
              
            Case \chkDoNotBlackoutOthers
              CHKOWNCHG(WQK_chkDoNotBlackoutOthers_Click())
              
            Case \chkFixtureChanApplyFadeTime[0]
              CHKOWNCHG(WQK_chkFixtureChanApplyFadeTime_Click(grWQK\nSelectedFixture, gnEventGadgetArrayIndex))
              
            Case \aFix1(0)\chkFixtureChanApplyFadeTime1
              CHKOWNCHG(WQK_chkFixtureChanApplyFadeTime_Click(gnEventGadgetArrayIndex, grWQK\nChanIndex1(gnEventGadgetArrayIndex)))

            Case \chkFixtureChanIncluded[0]
              CHKOWNCHG(WQK_chkFixtureChanIncluded_Click(grWQK\nSelectedFixture, gnEventGadgetArrayIndex))
              
            Case \aFix1(0)\chkFixtureChanIncluded1
              CHKOWNCHG(WQK_chkFixtureChanIncluded_Click(gnEventGadgetArrayIndex, grWQK\nChanIndex1(gnEventGadgetArrayIndex)))
              
            Case \chkInclude
              CHKOWNCHG(WQK_chkInclude_Click(grWQK\nSelectedFixture))
              
            Case \chkLiveDMXTest
              CHKOWNCHG(WQK_chkLiveDMXTest_Click())
              
            Case \chkMonitorTapDelay
              CHKOWNCHG(WQK_chkMonitorTapDelay_Click())
              
            Case \chkNextLTStopsChase
              CHKOWNCHG(WQK_chkNextLTStopsChase_Click())
              
            Case \chkSingleStep
              CHKOWNCHG(WQK_chkSingleStep_Click())
              
            Case \cntChase, \cntChaseStep, \cntDMX, \cntDMXValues, \cntFades, \cntFixtures, \cntItems, \cntLightingSideBar, \cntSubDetailK, \cntSubHeader, \cntTest, \cntTestBtns,
                 \cntBLFade, \cntDIFadeDown, \cntDIFadeOutOthers, \cntDIFadeUp, \cntFIFadeDown, \cntFIFadeOutOthers, \cntFIFadeUp, \cntDCFadeDown, \cntDCFadeUp, \cntDCFadeOutOthers
              ; ignore
              
            Case \cvsCaptureButton
              WQK_cvsCaptureButton_Event(gnEventType)
              
            Case \cvsCapturingDMXLight
              ; ignore
              
            Case \cvsChaseStep
              ; ignore
              
            Case \cvsFixtureNo[0], \aFix1(0)\cvsFixtureNo1
              If gnEventType = #PB_EventType_LeftClick
                WQK_cvsFixtureNo_Click(gnEventGadgetArrayIndex)
              EndIf
              
            Case \cntFixtures, \cntFixtures1
              ; ignore
              
            Case #SCS_G4EH_QK_CVSITEMNO ; \cvsItemNo
              If gnEventType = #PB_EventType_LeftClick
                WQK_cvsItemNo_Click(WQK_calcGadgetRow())
              EndIf
              
            Case \scaDMXItems, \scaFixtureChans, \scaFixtures, \scaFixtures1, \scaLighting
              ; no action required on scroll area events
              
            Case \txtBLFadeTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtBLFadeUserTime_Validate())
              EndSelect
              
            Case \txtChaseSpeed
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtChaseSpeed_Validate())
              EndSelect
              
            Case \txtChaseSteps
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtChaseSteps_Validate())
              EndSelect
              
            Case \txtDCFadeDownTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDCFadeDownUserTime_Validate())
              EndSelect
              
            Case \txtDCFadeOutOthersTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDCFadeOutOthersUserTime_Validate())
              EndSelect
              
            Case \txtDCFadeUpTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDCFadeUpUserTime_Validate())
              EndSelect
              
            Case \txtDIFadeDownTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDIFadeDownUserTime_Validate())
              EndSelect
              
            Case \txtDIFadeOutOthersTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDIFadeOutOthersUserTime_Validate())
              EndSelect
              
            Case \txtDIFadeUpTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDIFadeUpUserTime_Validate())
              EndSelect
              
            Case #SCS_G4EH_QK_TXTDMXITEMSTR ; \txtDMXItemStr
              Select gnEventType
                Case #PB_EventType_Focus
                  WQK_setCurrentItemInfo(WQK_calcGadgetRow())
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtDMXItemStr_Validate(WQK_calcGadgetRow()))
              EndSelect
              
            Case \txtDMXValues
              ; ignore events - not an enterable field
              
            Case \txtFIFadeDownTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtFIFadeDownUserTime_Validate())
              EndSelect
              
            Case \txtFIFadeOutOthersTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtFIFadeOutOthersUserTime_Validate())
              EndSelect
              
            Case \txtFIFadeUpTime
              Select gnEventType
                Case #PB_EventType_Focus
                  setOrClearGadgetValidValuesFlag()
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtFIFadeUpUserTime_Validate())
              EndSelect
              
            Case \txtFixtureChannelValue[0], \aFix1(0)\txtFixtureChannelValue1
              Select gnEventType
                Case #PB_EventType_Focus
                  Select grMemoryPrefs\nDMXFixtureDisplayData
                      ; Deleted 10Nov2020 11.8.3.3ae - shouldn't change 'current fixture' if only selecting another channel of the currently-selected fixture
                      ; Case #SCS_LT_DISP_ALL
                      ;   debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + gnEventGadgetArrayIndex + ")")
                      ;   (gnEventGadgetArrayIndex)
                      ; End deleted 10Nov2020 11.8.3.3ae
                    Case #SCS_LT_DISP_1ST
                      ; NB only displaying the first channel for each fixture, so by clicking on another 'channel value' we do need to change the 'current fixture'
                      debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + gnEventGadgetArrayIndex + ")")
                      WQK_setCurrentFixtureInfo1(gnEventGadgetArrayIndex)
                  EndSelect
                  selectWholeField(gnEventGadgetNo)
                Case #PB_EventType_LostFocus
                  ETVAL(WQK_txtFixtureChannelValue_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtFixtureLinkGroup[0], \aFix1(0)\txtFixtureLinkGroup1
              Select gnEventType
                Case #PB_EventType_Focus
                  Select grMemoryPrefs\nDMXFixtureDisplayData
                    Case #SCS_LT_DISP_ALL
                      ; debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + gnEventGadgetArrayIndex + ")")
                      WQK_setCurrentFixtureInfo(gnEventGadgetArrayIndex)
                    Case #SCS_LT_DISP_1ST
                      ; debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + gnEventGadgetArrayIndex + ")")
                      WQK_setCurrentFixtureInfo1(gnEventGadgetArrayIndex)
                  EndSelect
                Case #PB_EventType_LostFocus
                  ; Note: The following code that checks the active gadget against the event gadget is to find out if the lost focus event has taken the focus to the next row.
                  ; This test is necessary in this case because tabbing out of a link group text field is expected to set focus to the combobox at the start of the next row, but
                  ; since the combobox gadget doesn't raise a focus event (unless it's an editable combobox, which this one isn't) then we use the code below to check if we need
                  ; to call WQK_setCurrentFixtureInfo().
                  nEventGadgetNo = gnEventGadgetNo
                  ETVAL(WQK_txtFixtureLinkGroup_Validate(gnEventGadgetArrayIndex))
                  nActiveGadgetNo = GetActiveGadget()
                  If (nActiveGadgetNo <> nEventGadgetNo) And (nActiveGadgetNo > 0)
                    nEventGadgetPropsIndex = getGadgetPropsIndex(nEventGadgetNo)
                    nActiveGadgetPropsIndex = getGadgetPropsIndex(nActiveGadgetNo)
                    If gaGadgetProps(nActiveGadgetPropsIndex)\nContainerGadgetNo = gaGadgetProps(nEventGadgetPropsIndex)\nContainerGadgetNo
                      ; only check for calling WQK_setCurrentFixtureInfo() if the active gadget is in the same container as the event gadget,
                      ; eg that the user hasn't clicked elsewhere
                      nEventGadgetArrayIndex = gaGadgetProps(nEventGadgetPropsIndex)\nArrayIndex
                      nActiveGadgetArrayIndex = gaGadgetProps(nActiveGadgetPropsIndex)\nArrayIndex
                      If nActiveGadgetArrayIndex <> nEventGadgetArrayIndex
                        Select grMemoryPrefs\nDMXFixtureDisplayData
                          Case #SCS_LT_DISP_ALL
                            debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + nActiveGadgetArrayIndex + ")")
                            WQK_setCurrentFixtureInfo(nActiveGadgetArrayIndex)
                          Case #SCS_LT_DISP_1ST
                            debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + nActiveGadgetArrayIndex + ")")
                            WQK_setCurrentFixtureInfo1(nActiveGadgetArrayIndex)
                        EndSelect
                      EndIf
                    EndIf
                  EndIf
              EndSelect
              
            Default
              If gnEventType <> #PB_EventType_Resize
                debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
              EndIf
          EndSelect
          
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WQK_populateCboLogicalDev()
  PROCNAMECS(nEditSubPtr)
  Protected d
  
  ; debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WQK\cboLogicalDev)
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If \sLogicalDev
        Select \nDevType
          Case #SCS_DEVTYPE_LT_DMX_OUT
            addGadgetItemWithData(WQK\cboLogicalDev, \sLogicalDev, d)
        EndSelect
      EndIf
    EndWith
  Next d
  
EndProcedure

Procedure WQK_fcLogicalDev()
  PROCNAMECS(nEditSubPtr)
  Protected nDevNo, nDevType, sMyLogicalDev.s
  
  nDevNo = getCurrentItemData(WQK\cboLogicalDev)
  If nDevNo >= 0
    nDevType = grProd\aLightingLogicalDevs(nDevNo)\nDevType
    sMyLogicalDev = grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev
  Else
    nDevType = #SCS_DEVTYPE_NONE
    sMyLogicalDev = ""
  EndIf
  grWQK\nSelectedDevType = nDevType
  grWQK\sSelectedLogicalDev = sMyLogicalDev
  
  Select nDevType
    Case #SCS_DEVTYPE_LT_DMX_OUT
      setVisible(WQK\cntDMX, #True)
  EndSelect
  
EndProcedure

Procedure WQK_populateChaseFields()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      setOwnState(WQK\chkChase, \bChase)
      If \bChase
        SGT(WQK\txtChaseSteps, Str(\nChaseSteps))
        SGT(WQK\txtChaseSpeed, Str(\nChaseSpeed))
        setComboBoxByData(WQK\cboChaseMode, \nChaseMode, 0)
        setOwnState(WQK\chkNextLTStopsChase, \bNextLTStopsChase)
        setOwnState(WQK\chkMonitorTapDelay, \bMonitorTapDelay)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_setFadeAndLiveDMXTestGadgets()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If \bChase = #False
        Select \nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_BLACKOUT
            setComboBoxByData(WQK\cboBLFadeAction, \nLTBLFadeAction, 0)
            WQK_fcBLFadeAction()
            
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
            
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            setComboBoxByData(WQK\cboDCFadeUpAction, \nLTDCFadeUpAction, 0)
            WQK_fcDCFadeUpAction()
            setComboBoxByData(WQK\cboDCFadeDownAction, \nLTDCFadeDownAction, 0)
            WQK_fcDCFadeDownAction()
            setComboBoxByData(WQK\cboDCFadeOutOthersAction, \nLTDCFadeOutOthersAction, 0)
            WQK_fcDCFadeOutOthersAction()
            
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            setComboBoxByData(WQK\cboDIFadeUpAction, \nLTDIFadeUpAction, 0)
            WQK_fcDIFadeUpAction()
            setComboBoxByData(WQK\cboDIFadeDownAction, \nLTDIFadeDownAction, 0)
            WQK_fcDIFadeDownAction()
            setComboBoxByData(WQK\cboDIFadeOutOthersAction, \nLTDIFadeOutOthersAction, 0)
            WQK_fcDIFadeOutOthersAction()
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            setComboBoxByData(WQK\cboFIFadeUpAction, \nLTFIFadeUpAction, 0)
            WQK_fcFIFadeUpAction()
            setComboBoxByData(WQK\cboFIFadeDownAction, \nLTFIFadeDownAction, 0)
            WQK_fcFIFadeDownAction()
            setComboBoxByData(WQK\cboFIFadeOutOthersAction, \nLTFIFadeOutOthersAction, 0)
            WQK_fcFIFadeOutOthersAction()
            
        EndSelect
      EndIf
      
      ; nb the following two checkboxes are mutually-exclusive, but that should already be indicated by the states of the two booleans
      setOwnState(WQK\chkLiveDMXTest, grWQK\bLiveDMXTest)
      setOwnState(WQK\chkSingleStep, grWQK\bSingleStep)
      Select \nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP, #SCS_LT_ENTRY_TYPE_BLACKOUT
          setVisible(WQK\chkDoNotBlackoutOthers, #False)
        Default
          setOwnState(WQK\chkDoNotBlackoutOthers, grWQK\bDoNotBlackoutOthers)
          setVisible(WQK\chkDoNotBlackoutOthers, #True)
      EndSelect
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_setScaDMXItemsInnerHeight()
  Protected nRowCount, nReqdInnerHeight
  
  nRowCount = aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount + 1
  nReqdInnerHeight = nRowCount * #SCS_QKROW_HEIGHT
  SetGadgetAttribute(WQK\scaDMXItems, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)

EndProcedure

Procedure WQK_createExtraRowForInserts()
  PROCNAMECS(nEditSubPtr)
  Protected m
  Protected *oldElement
  Protected nCurrLastIndex, nReqdLastIndex, nReqdInnerHeight
  
  If ListSize(WQKItem()) > 0
    *oldElement = @WQKItem() ; need to save and reinstate the current element
  EndIf
  
  nCurrLastIndex = ListSize(WQKItem()) - 1
  nReqdLastIndex = aSub(nEditSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount
  ; debugMsg0(sProcName, "nCurrLastIndex=" + nCurrLastIndex + ", nReqdLastIndex=" + nReqdLastIndex)
  For m = (nCurrLastIndex + 1) To nReqdLastIndex
    ; nb should only pass this loop once, or not at all
    createWQKItem()
  Next m
  SelectElement(WQKItem(), nReqdLastIndex)
  WQKItem()\sDMXItemStr = ""
  WQKItem()\nDMXDisplayValue = 0
  SGT(WQKItem()\txtDMXItemStr, WQKItem()\sDMXItemStr)
  SLD_setValue(WQKItem()\sldDMXValue, WQKItem()\nDMXDisplayValue)
  SLD_setEnabled(WQKItem()\sldDMXValue, #False)
  
  If *oldElement
    ChangeCurrentElement(WQKItem(), *oldElement) ; reinstate what was saved as the current element
  EndIf
  
EndProcedure

Procedure WQK_getFirstExcludedChannel()
  PROCNAMECS(nEditSubPtr)
  Protected nFirstExcludedChannel = -1
  Protected m
  Protected Dim bChannelDataPresent(512)
  Protected sDMXChannels.s
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected nDMXChannel
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If (\bChase = #False) Or (grWQK\nCurrStepIndex > \nMaxChaseStepIndex) Or (grWQK\nInitSubPtr <> nEditSubPtr)
        grWQK\nCurrStepIndex = 0
      EndIf
      For m = 0 To \aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount - 1
        If \aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\nDMXDelayTime <= 0
          sDMXChannels = \aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\sDMXChannels
          ; process channels
          nPartCount = CountString(sDMXChannels, ",") + 1
          For nPart = 1 To nPartCount
            sPart = StringField(sDMXChannels, nPart, ",")
            nDashCount = CountString(sPart, "-")
            Select nDashCount
              Case 0
                sFromChannel = sPart
                sUpToChannel = sPart
              Case 1
                sFromChannel = StringField(sPart, 1, "-")
                sUpToChannel = StringField(sPart, 2, "-")
            EndSelect
            nFromChannel = Val(sFromChannel) ; + nFixtureOffset
            nUpToChannel = Val(sUpToChannel) ; + nFixtureOffset
            ; process channels for this part
            For nDMXChannel = nFromChannel To nUpToChannel
              If nDMXChannel >= 1 And nDMXChannel <= 512
                bChannelDataPresent(nDMXChannel) = #True
              EndIf
            Next nDMXChannel
          Next nPart
        EndIf
      Next m
    EndWith
    For nDMXChannel = 1 To 512
      If bChannelDataPresent(nDMXChannel) = #False
        nFirstExcludedChannel = nDMXChannel
        Break
      EndIf
    Next nDMXChannel
  EndIf
  
  ProcedureReturn nFirstExcludedChannel
EndProcedure

Procedure WQK_populateDMXItemsEtc(nSetCurrentItem=0)
  PROCNAMECS(nEditSubPtr)
  Protected m, nReqdInnerHeight
  Protected sDMXItemsText.s
  Static sDMXItems.s, sStep.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nSetCurrentItem=" + nSetCurrentItem)
  
  If bStaticLoaded = #False
    sDMXItems = Lang("WQK", "lblDMXItems")
    sStep = Lang("DMX", "Step") ; nb do not use LangPars()
    bStaticLoaded = #True
  EndIf

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; debugMsg(sProcName, "grWQK\nCurrStepIndex=" + grWQK\nCurrStepIndex + ", \nMaxChaseStepIndex=" + \nMaxChaseStepIndex + ", grWQK\nInitSubPtr=" + getSubLabel(grWQK\nInitSubPtr))
      If (\bChase = #False) Or (grWQK\nCurrStepIndex > \nMaxChaseStepIndex) Or (grWQK\nInitSubPtr <> nEditSubPtr)
        grWQK\nCurrStepIndex = 0
      EndIf
      sDMXItemsText = sDMXItems
      If \bChase
        sDMXItemsText + " (" + ReplaceString(sStep, "$1", Str(grWQK\nCurrStepIndex+1)) + ")"
      EndIf
      SGT(WQK\lblDMXItems, sDMXItemsText)
      
      For m = 0 To \aChaseStep(grWQK\nCurrStepIndex)\nDMXSendItemCount - 1
        If m > (ListSize(WQKItem()) - 1)
          createWQKItem()
        EndIf
        SelectElement(WQKItem(), m)
        WQKItem()\sDMXItemStr = Trim(\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\sDMXItemStr)
        WQKItem()\nDMXDisplayValue = \aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\nDMXDisplayValue
        WQK_setSldDMXValueMax(nEditSubPtr, m)
        SGT(WQKItem()\txtDMXItemStr, WQKItem()\sDMXItemStr)
        ; debugMsg(sProcName, "calling SLD_setValue(" + WQKItem()\sldDMXValue + ", " + WQKItem()\nDMXDisplayValue + ")")
        SLD_setValue(WQKItem()\sldDMXValue, WQKItem()\nDMXDisplayValue)
        ; debugMsg(sProcName, "ListIndex(WQKItem())=" + ListIndex(WQKItem()) + ", \aChaseStep(" + grWQK\nCurrStepIndex + ")\aDMXSendItem(" + m + ")\sDMXItemStr=" + \aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\sDMXItemStr)
        If \aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\bDBO Or Len(Trim(\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(m)\sDMXItemStr)) = 0
          SLD_setEnabled(WQKItem()\sldDMXValue, #False)
        Else
          SLD_setEnabled(WQKItem()\sldDMXValue, #True)
        EndIf
      Next m
      ; extra row for inserts
      WQK_createExtraRowForInserts()
      WQK_setScaDMXItemsInnerHeight()
      
      WQK_setFadeAndLiveDMXTestGadgets()
      
      If nSetCurrentItem >= 0
        debugMsg(sProcName, "calling WQK_setCurrentItemInfo(" + nSetCurrentItem + ")")
        WQK_setCurrentItemInfo(nSetCurrentItem)
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_cboLogicalDev_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubS(\sLTLogicalDev, GGT(WQK\lblLogicalDev))
      \sLTLogicalDev = GGT(WQK\cboLogicalDev)
      debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sLTLogicalDev=" + \sLTLogicalDev)
      d = getCurrentItemData(WQK\cboLogicalDev, -1)
      If d >= 0
        \nLTDevType = grProd\aLightingLogicalDevs(d)\nDevType
      Else
        \nLTDevType = #SCS_DEVTYPE_NONE
      EndIf
      debugMsg(sProcName, "d=" + d + ", \sLTLogicalDev=" + \sLTLogicalDev + ", \nLTDevType=" + decodeDevType(\nLTDevType))
      grWQK\nSelectedDevType = \nLTDevType
      grWQK\sSelectedLogicalDev = \sLTLogicalDev
      
      Select \nLTDevType
        Case  #SCS_DEVTYPE_LT_DMX_OUT
          \nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, \sLTLogicalDev)
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
              WQK_populateDMXItemsEtc()
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              WQK_displayInfoForEntryType()
          EndSelect
        Default
          \bDMXSend = #False
      EndSelect
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubS(u, \sLTLogicalDev)
    EndWith
  EndIf
  
  debugMsg(sProcName, "calling WQK_fcLogicalDev()")
  WQK_fcLogicalDev()
  debugMsg(sProcName, "calling WQK_setLightingTestButtons()")
  WQK_setLightingTestButtons()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_setSldDMXValueMax(pSubPtr, nDMXItemIndex)
  ; PROCNAMECS(nEditSubPtr)
  Protected nGadgetNo
  
  ; debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr) + ", nDMXItemIndex=" + nDMXItemIndex)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aDMXSendItem(nDMXItemIndex)
      nGadgetNo = WQKItem()\sldDMXValue
      ; debugMsg(sProcName, "\bDMXAbsValue=" + strB(\bDMXAbsValue))
      If \bDMXAbsValue
        ; an absolute DMX value (0-255)
        SLD_setMax(nGadgetNo, 255)
        SLD_setKeyFactorL(nGadgetNo, 255) ; KeyFactorL governs increment used by left and right arrows
      Else
        ; a percentage value (0-100)
        SLD_setMax(nGadgetNo, 100)
        SLD_setKeyFactorL(nGadgetNo, 100) ; KeyFactorL governs increment used by left and right arrows
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_setSldFixtureChannelValueMax(pSubPtr, nFixtureItemIndex, nFixtureChanIndex)
  PROCNAMECS(pSubPtr)
  
debugMsg(sProcName, #SCS_START + ", nFixtureItemIndex=" + nFixtureItemIndex + ", nFixtureChanIndex=" + nFixtureChanIndex)
  
  If pSubPtr >= 0
    CheckSubInRange(grWQK\nCurrStepIndex, ArraySize(aSub(pSubPtr)\aChaseStep()), "\aChaseStep()")
    CheckSubInRange(nFixtureItemIndex, ArraySize(aSub(pSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aFixtureItem()), "\aChaseStep(" + grWQK\nCurrStepIndex + ")\aFixtureItem")
    CheckSubInRange(nFixtureChanIndex, ArraySize(aSub(pSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan()), "\aChaseStep(" + grWQK\nCurrStepIndex + ")\aFixtureItem(" + nFixtureItemIndex + ")\aFixChan()")
    With aSub(pSubPtr)\aChaseStep(grWQK\nCurrStepIndex)\aFixtureItem(nFixtureItemIndex)\aFixChan(nFixtureChanIndex)
      Select grMemoryPrefs\nDMXFixtureDisplayData
        Case #SCS_LT_DISP_ALL
          If \bDMXAbsValue
            ; an absolute DMX value (0-255)
            SLD_setMax(WQK\sldFixtureChannelValue[nFixtureChanIndex], 255)
            SLD_setKeyFactorL(WQK\sldFixtureChannelValue[nFixtureChanIndex], 255) ; KeyFactorL governs increment used by left and right arrows
          Else
            ; a percentage value (0-100)
            SLD_setMax(WQK\sldFixtureChannelValue[nFixtureChanIndex], 100)
            SLD_setKeyFactorL(WQK\sldFixtureChannelValue[nFixtureChanIndex], 100) ; KeyFactorL governs increment used by left and right arrows
          EndIf
        Case #SCS_LT_DISP_1ST
          If \bDMXAbsValue
            ; an absolute DMX value (0-255)
            SLD_setMax(WQK\aFix1(nFixtureItemIndex)\sldFixtureChannelValue1, 255)
            SLD_setKeyFactorL(WQK\aFix1(nFixtureItemIndex)\sldFixtureChannelValue1, 255) ; KeyFactorL governs increment used by left and right arrows
          Else
            ; a percentage value (0-100)
            SLD_setMax(WQK\aFix1(nFixtureItemIndex)\sldFixtureChannelValue1, 100)
            SLD_setKeyFactorL(WQK\aFix1(nFixtureItemIndex)\sldFixtureChannelValue1, 100) ; KeyFactorL governs increment used by left and right arrows
          EndIf
      EndSelect
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQK
    If IsGadget(\scaLighting)
      ; \scaLighting automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaLighting) - gl3DBorderHeight
      nMinInnerHeight = #SCS_EDITOR_MIN_SCROLLAREA_INNERHEIGHT ; was 448
      ; debugMsg0(sProcName, "nInnerHeight=" + nInnerHeight + ", nMinInnerHeight=" + nMinInnerHeight)
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaLighting, #PB_ScrollArea_InnerHeight, nInnerHeight)
      ; adjust the height of \cntSubDetailK
      nHeight = nInnerHeight - GadgetY(\cntSubDetailK)
      ResizeGadget(\cntSubDetailK, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      ; debugMsg0(sProcName, "calling WQK_resizeContainers()")
      WQK_resizeContainers()
    EndIf
  EndWith
EndProcedure

Procedure WQK_btnReset_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  grDMX\bCaptureDMX = #False
  If nEditSubPtr >= 0
    grWQK\bProcessingReset = #True ; Added 31Jul2020 11.8.3.2ap
    u = preChangeSubL(#True, GGT(WQK\btnReset))
    WQK_resetInitDMXItems(nEditSubPtr)
    With aSub(nEditSubPtr)
      ; debugMsg(sProcName, "\nLTDevType=" + decodeDevType(\nLTDevType))
      WQK_populateChaseFields() ; Moved 2Dec2022 11.9.7ar from start of LT_DMX_OUT select below
      Select \nLTDevType
        Case #SCS_DEVTYPE_LT_DMX_OUT
          If getCurrentItemData(WQK\cboEntryType) <> \nLTEntryType
            setComboBoxByData(WQK\cboEntryType, \nLTEntryType, 0)
            WQK_fcEntryType()
          EndIf
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
              WQK_populateDMXItemsEtc()
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              WQK_displayInfoForEntryType()
          EndSelect
      EndSelect
      WQK_fcChase() ; Moved 2Dec2022 11.9.7ar from within LT_DMX_OUT select below
      debugMsg(sProcName, "calling WQK_buildAndDisplayLightingMessage()")
      WQK_buildAndDisplayLightingMessage()
      WQK_setResetButtonEnabledState()
      WQK_populateChaseFields() ; Moved 2Dec2022 11.9.7ar from \bChase test below
      If \bChase
        WQK_displayCurrChaseStep()
      Else
        debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd(#True)")
        WQK_doLiveDMXTestIfReqd(#True)
      EndIf
    EndWith
    setDefaultSubDescr()
    setDefaultCueDescr()
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    postChangeSubL(u, #False)
    loadGridRow(nEditCuePtr)
    PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    grWQK\bProcessingReset = #False ; Added 31Jul2020 11.8.3.2ap
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_setResetButtonEnabledState()
  ; PROCNAMECS(nEditSubPtr)
  Protected bEnable
  Protected m, n, sFixtureCode.s, nTotalChans, nChanIndex
  
  If nEditSubPtr >= 0
    If grWQK\nInitSubPtr = nEditSubPtr
      With aSub(nEditSubPtr)
        If \nLTEntryType <> grWQK\nInitLTEntryType
          bEnable = #True
        ElseIf \bChase <> grWQK\bInitChase
          bEnable = #True
        ElseIf (\bChase) And ((\nChaseSteps <> grWQK\nInitChaseSteps) Or (\nChaseSpeed <> grWQK\nInitChaseSpeed) Or (\nChaseMode <> grWQK\nInitChaseMode) Or (\bNextLTStopsChase <> grWQK\bInitNextLTStopsChase))
          bEnable = #True
        ElseIf \nMaxChaseStepIndex <> grWQK\nInitMaxChaseStepIndex
          bEnable = #True
        EndIf
        If bEnable = #False
          Select \nLTEntryType
            Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
              For n = 0 To \nMaxChaseStepIndex
                If \aChaseStep(n)\nDMXSendItemCount <> grWQK\aInitChaseStep(n)\nDMXSendItemCount ; Test added 5Apr2023 11.10.0at following bug reported by Peter Mount
                  bEnable = #True
                  Break ; Break n
                Else
                  For m = 0 To \aChaseStep(n)\nDMXSendItemCount - 1 ; grLicInfo\nMaxDMXItemPerLightingSub
                    If \aChaseStep(n)\aDMXSendItem(m)\sDMXItemStr <> grWQK\aInitChaseStep(n)\aDMXSendItem(m)\sDMXItemStr
                      bEnable = #True
                      Break 2 ; Break m, n
                    EndIf
                  Next m
                EndIf
              Next n
              
            Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
              If \nMaxFixture <> grWQK\nInitMaxFixture
                bEnable = #True
              Else
                For n = 0 To \nMaxFixture
                  If (\aLTFixture(n)\sLTFixtureCode <> grWQK\aInitLTFixture(n)\sLTFixtureCode) Or (\aLTFixture(n)\nFixtureLinkGroup <> grWQK\aInitLTFixture(n)\nFixtureLinkGroup)
                    bEnable = #True
                    Break
                  EndIf
                Next n
                If bEnable = #False
                  For n = 0 To \nMaxChaseStepIndex
                    For m = 0 To \nMaxFixture
                      sFixtureCode = \aLTFixture(m)\sLTFixtureCode
                      nTotalChans = getTotalChansForFixture(@grProd, @aSub(nEditSubPtr), sFixtureCode)
                      For nChanIndex = 0 To (nTotalChans - 1)
                        If \aChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\bRelChanIncluded <> grWQK\aInitChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\bRelChanIncluded Or
                           \aChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\sDMXDisplayValue <> grWQK\aInitChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\sDMXDisplayValue Or
                           \aChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\bApplyFadeTime <> grWQK\aInitChaseStep(n)\aFixtureItem(m)\aFixChan(nChanIndex)\bApplyFadeTime
                          bEnable = #True
                          Break 3 ; Break nChanIndex, m, n
                        EndIf
                      Next nChanIndex
                    Next m
                  Next n
                EndIf
              EndIf
          EndSelect
        EndIf
      EndWith
    EndIf
  EndIf
  
  ; debugMsg0(sProcName, "bEnable=" + strB(bEnable))
  setEnabled(WQK\btnReset, bEnable)
  
EndProcedure

Procedure WQK_saveInitDMXItems(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected m, n
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      grWQK\nInitSubPtr = pSubPtr
      grWQK\nInitLTEntryType = \nLTEntryType
      grWQK\bInitChase = \bChase
      grWQK\nInitChaseSteps = \nChaseSteps
      grWQK\nInitChaseSpeed = \nChaseSpeed
      grWQK\nInitChaseMode = \nChaseMode
      grWQK\bInitNextLTStopsChase = \bNextLTStopsChase
      grWQK\nInitMaxChaseStepIndex = \nMaxChaseStepIndex
      CopyArray(\aChaseStep(), grWQK\aInitChaseStep())
      grWQK\nInitMaxFixture = \nMaxFixture
      CopyArray(\aLTFixture(), grWQK\aInitLTFixture())
    EndWith
    With grWQK
      \nInitCurrItemIndex = \nCurrItemIndex
      \nInitCurrStepIndex = \nCurrStepIndex
    EndWith
  EndIf
  
  WQK_setResetButtonEnabledState()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_resetInitDMXItems(pSubPtr)
  PROCNAMECS(pSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If grWQK\nInitSubPtr = pSubPtr
        \nLTEntryType = grWQK\nInitLTEntryType
        \bChase = grWQK\bInitChase
        \nChaseSteps = grWQK\nInitChaseSteps
        \nChaseSpeed = grWQK\nInitChaseSpeed
        \nChaseMode = grWQK\nInitChaseMode
        \bNextLTStopsChase = grWQK\bInitNextLTStopsChase
        \nMaxChaseStepIndex = grWQK\nInitMaxChaseStepIndex
        CopyArray(grWQK\aInitChaseStep(), \aChaseStep())
        \nMaxFixture = grWQK\nInitMaxFixture
        CopyArray(grWQK\aInitLTFixture(), \aLTFixture())
      EndIf
      \nSubDuration = getSubLength(pSubPtr, #True)
    EndWith
    With grWQK
      \nCurrItemIndex = \nInitCurrItemIndex
      \nCurrStepIndex = \nInitCurrStepIndex
    EndWith
  EndIf
  
  ; WQK_setResetButtonEnabledState()  ; not necessary here as will be called outside of this procedure
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_fcEntryType()
  PROCNAMECS(nEditSubPtr)
  Protected nEntryType, n, nPosition
  Protected bFadesVisible, bFadeOutOthersVisible, bChaseVisible, bFixtureDisplayVisible, bCaptureSeqVisible, bCaptureSnapVisible, bLightingSideBarVisible, bApplyCurrValuesAsMins
  Protected bFIFadesVisible, bBLFadeVisible, bDIFadesVisible, bDCFadesVisible
  Protected bCaptureButtonVisible, nCaptureButtonType
  
  With aSub(nEditSubPtr)
    nEntryType = getCurrentItemData(WQK\cboEntryType)
    ; debugMsg0(sProcName, "nEntryType=" + decodeLTEntryType(nEntryType))
    Select nEntryType
      Case #SCS_LT_ENTRY_TYPE_BLACKOUT
        setGadgetItemByData(WQK\cboBLFadeAction, \nLTBLFadeAction)
        SGT(WQK\txtBLFadeTime, makeDisplayTimeValueD(\sLTBLFadeUserTime, \nLTBLFadeUserTime))
        bFadesVisible = #True
        bBLFadeVisible = #True
        WQK_fcBLFadeAction()
        
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
        setGadgetItemByData(WQK\cboDIFadeUpAction, \nLTDIFadeUpAction)
        SGT(WQK\txtDIFadeUpTime, makeDisplayTimeValueD(\sLTDIFadeUpUserTime, \nLTDIFadeUpUserTime))
        setGadgetItemByData(WQK\cboDIFadeDownAction, \nLTDIFadeDownAction)
        SGT(WQK\txtDIFadeDownTime, makeDisplayTimeValueD(\sLTDIFadeDownUserTime, \nLTDIFadeDownUserTime))
        setGadgetItemByData(WQK\cboDIFadeOutOthersAction, \nLTDIFadeOutOthersAction)
        SGT(WQK\txtDIFadeOutOthersTime, makeDisplayTimeValueD(\sLTDIFadeOutOthersUserTime, \nLTDIFadeOutOthersUserTime))
        setGadgetItemByData(WQK\cboFixtureDisplay, grMemoryPrefs\nDMXFixtureDisplayData, 0)
        bFixtureDisplayVisible = #True
        bLightingSideBarVisible = #True
        If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_EXT_FADER
          bApplyCurrValuesAsMins = #True
        Else
          bFadesVisible = #True
          bDIFadesVisible = #True
          bChaseVisible = #True
          WQK_fcDIFadeUpAction()
          WQK_fcDIFadeDownAction()
          WQK_fcDIFadeOutOthersAction()
        EndIf
        
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
        bCaptureSeqVisible = #True
        bCaptureButtonVisible = #True
        nCaptureButtonType = #SCS_LT_CAPTURE_BTN_SEQ_START
        bLightingSideBarVisible = #True
        
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        setGadgetItemByData(WQK\cboDCFadeUpAction, \nLTDCFadeUpAction)
        SGT(WQK\txtDCFadeUpTime, makeDisplayTimeValueD(\sLTDCFadeUpUserTime, \nLTDCFadeUpUserTime))
        setGadgetItemByData(WQK\cboDCFadeDownAction, \nLTDCFadeDownAction)
        SGT(WQK\txtDCFadeDownTime, makeDisplayTimeValueD(\sLTDCFadeDownUserTime, \nLTDCFadeDownUserTime))
        setGadgetItemByData(WQK\cboDCFadeOutOthersAction, \nLTDCFadeOutOthersAction)
        SGT(WQK\txtDCFadeOutOthersTime, makeDisplayTimeValueD(\sLTDCFadeOutOthersUserTime, \nLTDCFadeOutOthersUserTime))
        bCaptureSnapVisible = #True
        bCaptureButtonVisible = #True
        nCaptureButtonType = #SCS_LT_CAPTURE_BTN_SNAP
        bFadesVisible = #True
        bDCFadesVisible = #True
        bLightingSideBarVisible = #True
        WQK_fcDCFadeUpAction()
        WQK_fcDCFadeDownAction()
        
      Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        ; Fade up time for fixtures that need to be faded up
        setGadgetItemByData(WQK\cboFIFadeUpAction, \nLTFIFadeUpAction)
        SGT(WQK\txtFIFadeUpTime, makeDisplayTimeValueD(\sLTFIFadeUpUserTime, \nLTFIFadeUpUserTime))
        ; Fade down time for fixtures that need to be faded down
        setGadgetItemByData(WQK\cboFIFadeDownAction, \nLTFIFadeDownAction)
        If \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
          SGT(WQK\txtFIFadeDownTime, GGT(WQK\txtFIFadeUpTime))
        Else
          SGT(WQK\txtFIFadeDownTime, makeDisplayTimeValueD(\sLTFIFadeDownUserTime, \nLTFIFadeDownUserTime))
        EndIf
        ; Fade out time for other active fixtures
        setGadgetItemByData(WQK\cboFIFadeOutOthersAction, \nLTFIFadeOutOthersAction)
        If \nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
          SGT(WQK\txtFIFadeOutOthersTime, GGT(WQK\txtFIFadeDownTime))
        Else
          SGT(WQK\txtFIFadeOutOthersTime, makeDisplayTimeValueD(\sLTFIFadeOutOthersUserTime, \nLTFIFadeOutOthersUserTime))
        EndIf
        setGadgetItemByData(WQK\cboFixtureDisplay, grMemoryPrefs\nDMXFixtureDisplayData, 0)
        bFixtureDisplayVisible = #True
        bLightingSideBarVisible = #True
        If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_EXT_FADER
          bApplyCurrValuesAsMins = #True
        Else
          bFadesVisible = #True
          bFIFadesVisible = #True
          bChaseVisible = #True
          WQK_fcFIFadeUpAction()
          WQK_fcFIFadeDownAction()
          WQK_fcFIFadeOutOthersAction()
        EndIf
        
    EndSelect
  EndWith
  
  With WQK
    setVisible(\cntFades, bFadesVisible)
    setVisible(\cntBLFade, bBLFadeVisible)
    setVisible(\cntDIFadeUp, bDIFadesVisible)
    setVisible(\cntDIFadeDown, bDIFadesVisible)
    setVisible(\cntDIFadeOutOthers, bDIFadesVisible)
    setVisible(\cntFIFadeUp, bFIFadesVisible)
    setVisible(\cntFIFadeDown, bFIFadesVisible)
    setVisible(\cntFIFadeOutOthers, bFIFadesVisible)
    setVisible(\cntDCFadeUp, bDCFadesVisible)
    setVisible(\cntDCFadeDown, bDCFadesVisible)
    setVisible(\cntDCFadeOutOthers, bDCFadesVisible)
    setVisible(\chkChase, bChaseVisible) ; see also call to WQK_fcChase() below
    ; setVisible(\cntChase, bChaseVisible) ; deleted 9Oct2021 11.8.6ay
    If IsGadget(\chkApplyCurrValuesAsMins)
      setVisible(\chkApplyCurrValuesAsMins, bApplyCurrValuesAsMins)
    EndIf
    setVisible(\lblFixtureDisplay, bFixtureDisplayVisible)
    setVisible(\cboFixtureDisplay, bFixtureDisplayVisible)
    If grLicInfo\bDMXCaptureAvailable
      setVisible(\cvsCaptureButton, bCaptureButtonVisible)
      If bCaptureButtonVisible
        SetGadgetData(\cvsCaptureButton, nCaptureButtonType)
        WQK_drawCaptureButton(#False)
      EndIf
      setVisible(\lblCapturingDMX, #False)
      setVisible(\cvsCapturingDMXLight, #False)
    EndIf
    setVisible(\cntLightingSideBar, bLightingSideBarVisible)
    ; debugMsg0(sProcName, "calling WQK_resizeContainers()")
    WQK_resizeContainers()
    WQK_fcChase() ; added 9Oct2021 11.8.6ay
  EndWith
  
EndProcedure

Procedure WQK_fcChase()
  PROCNAMECS(nEditSubPtr)
  Protected n, nOldMaxChaseStepIndex, nFirstExcludedChannel, nEntryType, bChaseAvailable
  ; Static bStaticLoaded, sCaptureInfoMsg.s, sCaptureInfoMsg2.s
  
  ; debugMsg(sProcName, #SCS_START)
  
;   If bStaticLoaded = #False
;     sCaptureInfoMsg = Lang("WQK", "lblCaptureInfoMsg") ; nb do NOT use LangPars() as the $1 parameter will be populated at run time
;     sCaptureInfoMsg2 = Lang("WQK", "lblCaptureInfoMsg2") ; used for capture snapshot
;     bStaticLoaded = #True
;   EndIf
  
  With aSub(nEditSubPtr)
    nEntryType = \nLTEntryType
    ; Added 2Dec2022 11.9.7ar
    Select nEntryType
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        bChaseAvailable = #True
    EndSelect
    ; End added 2Dec2022 11.9.7ar
    nOldMaxChaseStepIndex = \nMaxChaseStepIndex
    ; If (\bChase) And (nEntryType <> #SCS_LT_ENTRY_TYPE_BLACKOUT) And (aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER)
    If (\bChase) And (bChaseAvailable) And (aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER) ; Changed 2Dec2022 11.9.7ar
      ; chase steps
      setVisible(WQK\cntChase, #True)
      setVisible(WQK\cntChaseStep, #True)
      If \nChaseSteps <= 1
        \nChaseSteps = #SCS_LT_DEF_CHASE_STEPS
        setLTMaxChaseStepIndex(@grProd, @aSub(nEditSubPtr))
      EndIf
      setEnabled(WQK\txtChaseSteps, #True)
      If grWQK\nCurrStepIndex > \nMaxChaseStepIndex
        grWQK\nCurrStepIndex = 0
      EndIf
      ; chase speed
      If \nChaseSpeed <= 0
        \nChaseSpeed = grProd\nDefChaseSpeed
      EndIf
      setEnabled(WQK\txtChaseSpeed, #True)
      ; other chase controls
      setEnabled(WQK\cboChaseMode, #True)
      setOwnEnabled(WQK\chkNextLTStopsChase, #True)
      setOwnEnabled(WQK\chkMonitorTapDelay, #True)
      setVisible(WQK\chkSingleStep, #True)
    Else
      setVisible(WQK\cntChase, #False)
      setVisible(WQK\cntChaseStep, #False)
      setEnabled(WQK\txtChaseSteps, #False)
      setEnabled(WQK\txtChaseSpeed, #False)
      setEnabled(WQK\cboChaseMode, #False)
      setOwnEnabled(WQK\chkNextLTStopsChase, #False)
      setOwnEnabled(WQK\chkMonitorTapDelay, #False)
      setVisible(WQK\chkSingleStep, #False)
    EndIf
    
    If nEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
      setVisible(WQK\lblCaptureInfoMsg, #False)
    Else
      If \bChase Or nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ Or nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP Or aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_EXT_FADER
        If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ Or nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
;           If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
;             SGT(WQK\lblCaptureInfoMsg, sCaptureInfoMsg2)
;             setVisible(WQK\lblCaptureInfoMsg, #True)
;           Else
;             nFirstExcludedChannel = WQK_getFirstExcludedChannel()
;             If nFirstExcludedChannel > 0
;               SGT(WQK\lblCaptureInfoMsg, ReplaceString(sCaptureInfoMsg, "$1", Str(nFirstExcludedChannel)))
;               setVisible(WQK\lblCaptureInfoMsg, #True)
;             Else
;               ; unlikely to get here as that would imply settings for all 512 channels had been found
;               setVisible(WQK\lblCaptureInfoMsg, #False)
;             EndIf
;           EndIf
          If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            setVisible(WQK\cntFades, #True)
          Else
            setVisible(WQK\cntFades, #False)
          EndIf
        Else
          setVisible(WQK\cntFades, #False)
;           setVisible(WQK\lblCaptureInfoMsg, #False)
        EndIf
        setVisible(WQK\lblFade, #False)
        If aCue(\nCueIndex)\nActivationMethod = #SCS_ACMETH_EXT_FADER And \bChase = #False
          For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
            setVisible(WQK\chkFixtureChanApplyFadeTime[n], #True)
          Next n
        Else
          For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
            setVisible(WQK\chkFixtureChanApplyFadeTime[n], #False)
          Next n
        EndIf
        WQK_populateChaseFields() ; Moved 2Dec2022 11.9.7ar from within \bChase test below
        If \bChase
          WQK_displayCurrChaseStep()
        EndIf
      Else
;         setVisible(WQK\lblCaptureInfoMsg, #False)
        setVisible(WQK\cntFades, #True)
        setVisible(WQK\lblFade, #True)
        For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
          setVisible(WQK\chkFixtureChanApplyFadeTime[n], #True)
        Next n
        WQK_populateChaseFields() ; Moved 2Dec2022 11.9.7ar from within \bChase test below
        If \bChase
          WQK_displayCurrChaseStep()
        EndIf
      EndIf
    EndIf ; EndIf \nLTEntryType <> #SCS_LT_ENTRY_TYPE_BLACKOUT
    
    ; debugMsg0(sProcName, "calling WQK_resizeContainers()")
    WQK_resizeContainers()
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_chkChase_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected bOldChaseState, bNewChaseState
  Protected sMsg.s, nResponse
  Protected bProcessChange = #True
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    bOldChaseState = \bChase
    bNewChaseState = getOwnState(WQK\chkChase)
    If (bOldChaseState) And (bNewChaseState = #False)
      ; stop live test if it's running
      DMX_stopChaseIfReqd(nEditSubPtr)
    EndIf
    If (bNewChaseState = #False) And (bOldChaseState) And (\nChaseSteps > 1)
      sMsg = LangPars("WQK", "ConfirmNoChase", Str(\nChaseSteps))
      debugMsg(sProcName, sMsg)
      nResponse = scsMessageRequester(grText\sTextCueTypeK, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_Yes
        debugMsg(sProcName, "nResponse=Yes")
      Else
        debugMsg(sProcName, "nResponse=No")
        bProcessChange = #False
        ; reinstate 'checked' state
        setOwnState(WQK\chkChase, #True)
      EndIf
    EndIf
    
    If bProcessChange
      u = preChangeSubL(\bChase, getOwnText(WQK\chkChase))
      \bChase = bNewChaseState
      WQK_fcChase()
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \bChase)
      WQK_setResetButtonEnabledState()
      WQK_setTBSButtons()
      DMX_setChaseCueCount()  ; counts lighting cues that contain chase
    EndIf
    
    WQK_setFixtureInfoEnabledState()
    
    If bNewChaseState = #False
      grWQK\nCurrStepIndex = 0
      debugMsg(sProcName, "calling WQK_displayInfoForEntryType")
      WQK_displayInfoForEntryType()
    EndIf
    
  EndWith
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_chkApplyCurrValuesAsMins_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bLTApplyCurrValuesAsMins, getOwnText(WQK\chkApplyCurrValuesAsMins))
    \bLTApplyCurrValuesAsMins = getOwnState(WQK\chkApplyCurrValuesAsMins)
    postChangeSubL(u, \bLTApplyCurrValuesAsMins)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_chkNextLTStopsChase_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bNextLTStopsChase, getOwnText(WQK\chkNextLTStopsChase))
    \bNextLTStopsChase = getOwnState(WQK\chkNextLTStopsChase)
    postChangeSubL(u, \bNextLTStopsChase)
    WQK_setResetButtonEnabledState()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_chkMonitorTapDelay_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\bMonitorTapDelay, getOwnText(WQK\chkMonitorTapDelay))
    \bMonitorTapDelay = getOwnState(WQK\chkMonitorTapDelay)
    WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
    postChangeSubL(u, \bMonitorTapDelay)
    WQK_setResetButtonEnabledState()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_txtChaseSteps_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nChaseSteps, nOldMaxChaseStepIndex
  Protected u
  Protected sPrompt.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  sPrompt = GGT(WQK\lblChaseSteps)
  
  nChaseSteps = Val(Trim(GGT(WQK\txtChaseSteps)))
  If (nChaseSteps < 2) Or (nChaseSteps > grLicInfo\nMaxChaseSteps)
    sMsg = LangPars("Errors", "MustBeBetween", sPrompt, "2", Str(grLicInfo\nMaxChaseSteps))
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    grWQK\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nChaseSteps, sPrompt)
    nOldMaxChaseStepIndex = \nMaxChaseStepIndex
    \nChaseSteps = nChaseSteps
    setLTMaxChaseStepIndex(@grProd, @aSub(nEditSubPtr))
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nChaseSteps=" + \nChaseSteps + ", \nMaxChaseStepIndex=" + \nMaxChaseStepIndex)
    WQK_commonUpdateProcessing()
    postChangeSubL(u, \nChaseSteps)
  EndWith
  
  With grWQK
    If \nCurrStepIndex > aSub(nEditSubPtr)\nMaxChaseStepIndex
      \nCurrStepIndex = 0
    EndIf
    WQK_displayCurrChaseStep(grWQK\nSelectedFixture)
  EndWith
  
  grWQK\bInValidate = #False
  
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtChaseSpeed_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nChaseSpeed
  Protected u
  Protected sPrompt.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  sPrompt = GGT(WQK\lblChaseSpeed)
  
  nChaseSpeed = Val(Trim(GGT(WQK\txtChaseSpeed)))
  If (nChaseSpeed < 1) Or (nChaseSpeed > 480) ; see also WQK_processTapDelayShortcut()
    sMsg = LangPars("Errors", "MustBeBetween", sPrompt, "1", "480")
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    grWQK\bInValidate = #False
    ProcedureReturn #False
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nChaseSpeed, sPrompt)
    \nChaseSpeed = nChaseSpeed
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nChaseSpeed=" + \nChaseSpeed)
    postChangeSubL(u, \nChaseSpeed)
    WQK_setResetButtonEnabledState()
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
  EndWith
  
  grWQK\bInValidate = #False
  
  ProcedureReturn #True
EndProcedure

Procedure WQK_setFixtureInfoEnabledState()
  ; PROCNAMECS(nEditSubPtr)
  Protected bEnable, nCboGadgetNo, nTxtGadgetNo, n
  
  ; debugMsg(sProcName, #SCS_START)
  
  If (aSub(nEditSubPtr)\bChase) And (grWQK\nCurrStepIndex > 0)
    bEnable = #False
  Else
    bEnable = #True
  EndIf
  
  With WQK
    For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub ; #SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB ; Changed 7Jul2024 11.10.3ar
      If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_ALL
        nCboGadgetNo = \cboFixture[n]
        nTxtGadgetNo = \txtFixtureLinkGroup[n]
      Else
        nCboGadgetNo = \aFix1(n)\cboFixture1
        nTxtGadgetNo = \aFix1(n)\txtFixtureLinkGroup1
      EndIf
      If IsGadget(nCboGadgetNo)
        setEnabled(nCboGadgetNo, bEnable)
        If (bEnable) And (getCurrentItemData(nCboGadgetNo) >= 0)
          setEnabled(nTxtGadgetNo, #True, #True)
        Else
          setEnabled(nTxtGadgetNo, #False, #True)
        EndIf
      EndIf
    Next n
  EndWith
  
EndProcedure

Procedure WQK_setScaFixturesInnerHeight()
  PROCNAMECS(nEditSubPtr)
  Protected nGadgetNo, n, nRowCount, nReqdInnerHeight
  Protected nDevNo, nFixtureCount
  
  With WQK
    For n = 0 To grLicInfo\nMaxFixtureItemPerLightingSub ; #SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB ; Changed 7Jul2024 11.10.3ar
      If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_ALL
        nGadgetNo = \cboFixture[n]
      Else
        nGadgetNo = \aFix1(n)\cboFixture1
      EndIf
      If IsGadget(nGadgetNo)
        ; debugMsg(sProcName, "getCurrentItemData(\cboFixture[" + n + "])=" + getCurrentItemData(\cboFixture[n]))
        If getCurrentItemData(nGadgetNo) >= 0
          nRowCount = n + 1
        EndIf
      EndIf
    Next n
    If nRowCount < (#SCS_MAX_FIXTURE_ITEM_PER_LIGHTING_SUB + 1)
      ; Fixture count test added 12Feb2024 11.10.2ak to limit number of lighting cue fixtures to the actual number of fixtures defined
      nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
      If nDevNo >= 0
        ; should be #True
        nFixtureCount = grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture + 1
        If nRowCount < nFixtureCount
          nRowCount + 1 ; add 1 row for new fixture item
        EndIf
      EndIf
    EndIf
    nReqdInnerHeight = nRowCount * #SCS_QKROW_HEIGHT
    ; debugMsg(sProcName, "nRowCount=" + nRowCount + ", nReqdInnerHeight=" + nReqdInnerHeight)
    If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_ALL
      SetGadgetAttribute(\scaFixtures, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
    Else
      SetGadgetAttribute(\scaFixtures1, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
    EndIf
  EndWith

EndProcedure

Procedure WQK_displayCurrChaseStep(nDisplayFixtureIndex=0)
  PROCNAMECS(nEditSubPtr)
  Static sChaseStepText.s
  Static bStaticLoaded
  Protected nChaseStep, nChaseSteps
  Protected sChaseStep.s
  Protected nLeft, nTop
  Protected nTextWidth, nTextHeight
  
  debugMsg(sProcName, #SCS_START + ", nDisplayFixtureIndex=" + nDisplayFixtureIndex + ", grWQK\nCurrStepIndex=" + grWQK\nCurrStepIndex)
  
  If bStaticLoaded = #False
    sChaseStepText = Lang("WQK", "ChaseStep") ; nb do not use LangPars()
    bStaticLoaded = #True
  EndIf
  
  With WQK
    nChaseStep = grWQK\nCurrStepIndex + 1
    nChaseSteps = aSub(nEditSubPtr)\nChaseSteps
    sChaseStep = ReplaceString(sChaseStepText, "$1", Str(nChaseStep) + "/" + Str(nChaseSteps))
    If StartDrawing(CanvasOutput(\cvsChaseStep))
      Box(0,0,OutputWidth(),OutputHeight(),glSysColInactiveCaption)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0,0,OutputWidth(),OutputHeight(),glSysColBtnFace)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
      nTextWidth = TextWidth(sChaseStep)
      nTextHeight = TextHeight(sChaseStep)
      If nTextWidth < OutputWidth()
        nLeft = (OutputWidth() - nTextWidth) >> 1
      EndIf
      If nTextHeight < OutputHeight()
        nTop = (OutputHeight() - nTextHeight) >> 1
      EndIf
      DrawText(nLeft, nTop, sChaseStep, glSysColInactiveCaptionText)
      StopDrawing()
    EndIf
    If nChaseStep <= 1
      setEnabled(\btnPrevStep, #False)
    Else
      setEnabled(\btnPrevStep, #True)
    EndIf
    If nChaseStep >= nChaseSteps
      setEnabled(\btnNextStep, #False)
    Else
      setEnabled(\btnNextStep, #True)
    EndIf
    
    Select aSub(nEditSubPtr)\nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
        WQK_populateDMXItemsEtc()
      Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        WQK_displayInfoForEntryType(nDisplayFixtureIndex)
    EndSelect
    
    ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
    WQK_doLiveDMXTestIfReqd()
    
  EndWith
  
EndProcedure

Procedure WQK_btnPrev_Click()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If grWQK\nCurrStepIndex > 0
        grWQK\nCurrStepIndex - 1
      EndIf
      debugMsg(sProcName, "grWQK\nCurrStepIndex=" + grWQK\nCurrStepIndex + ", \nMaxChaseStepIndex=" + \nMaxChaseStepIndex + ", ArraySize(\aChaseStep())=" + ArraySize(\aChaseStep()))
    EndWith
  EndIf
  WQK_displayCurrChaseStep(grWQK\nSelectedFixture)
  
EndProcedure

Procedure WQK_btnNext_Click()
  PROCNAMECS(nEditSubPtr)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If grWQK\nCurrStepIndex < \nMaxChaseStepIndex
        grWQK\nCurrStepIndex + 1
      EndIf
      debugMsg(sProcName, "grWQK\nCurrStepIndex=" + grWQK\nCurrStepIndex + ", \nMaxChaseStepIndex=" + \nMaxChaseStepIndex + ", ArraySize(\aChaseStep())=" + ArraySize(\aChaseStep()))
    EndWith
  EndIf
  WQK_displayCurrChaseStep(grWQK\nSelectedFixture)
  
EndProcedure

Procedure WQK_cboChaseMode_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nChaseMode, GGT(WQK\lblChaseMode))
      \nChaseMode = getCurrentItemData(WQK\cboChaseMode, 0)
      postChangeSubL(u, \nChaseMode)
      WQK_setResetButtonEnabledState()
      ; debugMsg(sProcName, "calling WQK_doLiveDMXTestIfReqd()")
      WQK_doLiveDMXTestIfReqd()
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboEntryType_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u

  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      WQK_clearLiveTestInfo()
      u = preChangeSubL(\nLTEntryType, GGT(WQK\lblEntryType))
      \nLTEntryType = getCurrentItemData(WQK\cboEntryType, 0)
      debugMsg(sProcName, "\nLTEntryType=" + decodeLTEntryType(\nLTEntryType))
      If \nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
        \bChase = #False
        \nChaseSteps = grSubDef\nChaseSteps
        \nMaxChaseStepIndex = grSubDef\nMaxChaseStepIndex
      EndIf
      setDefaultSubDescr()
      setDefaultCueDescr()
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, \nLTEntryType)
      WQK_displayInfoForEntryType()
      WQK_fcEntryType()
      WQK_setResetButtonEnabledState()
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboFixtureDisplay_Click()
  PROCNAMECS(nEditSubPtr)
  
  grMemoryPrefs\nDMXFixtureDisplayData = getCurrentItemData(WQK\cboFixtureDisplay, #SCS_LT_DISP_ALL)
  grMemoryPrefs\nDMXFixtureDisplayData = grMemoryPrefs\nDMXFixtureDisplayData
  WQK_displayInfoForEntryType(grWQK\nSelectedFixture)
  
EndProcedure

Procedure WQK_displayInfoForEntryType(nSetCurrentItem=0)
  PROCNAMECS(nEditSubPtr)
  Protected nDevNo, nRowNo, nFixtureIndex
  Protected nMaxProdFixture, nMaxFixtureRow, sSubFixtureCode.s, nFixtureLinkGroup
  Protected sProdFixtureCode.s, sProdFixtureDesc.s, nProdFixtureId
  Protected nListIndex
  Protected nFixTypeIndex, nLTEntryType
  
  debugMsg(sProcName, #SCS_START + ", nSetCurrentItem=" + nSetCurrentItem)
  
  ; NB This procedure can take a couple of seconds if there are quite a few fixtures, as found when testing cue file with 54 fixtures, from Dieter Edinger, 16Nov2018
  ; Not sure how we can speed it up. Mainly slowed down, I believe, by populating the \cboFixture combo boxes
  
  If nEditSubPtr >= 0
    
    With aSub(nEditSubPtr)
      nLTEntryType = \nLTEntryType
     ;  debugMsg(sProcName, "nLTEntryType=" + decodeLTEntryType(nLTEntryType))
      Select nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
          nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, \sLTLogicalDev)
          If nDevNo >= 0
            If nDevNo <> grWQK\nFixtureComboboxesPopulatedForDevNo Or gbInUndoOrRedo
              WQK_populateCboFixturesForDevNo(nDevNo)
            EndIf
            nMaxProdFixture = grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture
            nMaxFixtureRow = nMaxProdFixture
            If nMaxFixtureRow > grLicInfo\nMaxFixtureItemPerLightingSub
              nMaxFixtureRow = grLicInfo\nMaxFixtureItemPerLightingSub
            EndIf
            If nMaxFixtureRow < 0
              nMaxFixtureRow = 0
            EndIf
            ; debugMsg(sProcName, "ArraySize(\sFixtureCode())=" + ArraySize(\sFixtureCode()) + ", nMaxFixtureRow=" + nMaxFixtureRow)
            For nRowNo = 0 To nMaxFixtureRow
              ; debugMsg(sProcName, "nRowNo=" + nRowNo)
              If (nRowNo <= ArraySize(\aLTFixture())) And (nRowNo <= \nMaxFixture)
                sSubFixtureCode = \aLTFixture(nRowNo)\sLTFixtureCode
                nFixtureLinkGroup = \aLTFixture(nRowNo)\nFixtureLinkGroup
              Else
                sSubFixtureCode = ""
                nFixtureLinkGroup = 0
              EndIf
              nListIndex = -1
              If sSubFixtureCode
                nFixtureIndex = DMX_getProdFixtureIndex(nDevNo, sSubFixtureCode)
                ; debugMsg(sProcName, "nFixtureIndex=" + nFixtureIndex)
                If nFixtureIndex >= 0
                  nProdFixtureId = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\nFixtureId
                  Select grMemoryPrefs\nDMXFixtureDisplayData
                    Case #SCS_LT_DISP_ALL
                      nListIndex = indexForComboBoxData(WQK\cboFixture[nRowNo], nProdFixtureId)
                    Case #SCS_LT_DISP_1ST
                      nListIndex = indexForComboBoxData(WQK\aFix1(nRowNo)\cboFixture1, nProdFixtureId)
                  EndSelect
                  ; debugMsg(sProcName, "nRowNo=" + nRowNo + ", sSubFixtureCode=" + sSubFixtureCode + ", nProdFixtureId=" + nProdFixtureId + ", nListIndex=" + nListIndex)
                EndIf
              EndIf
              Select grMemoryPrefs\nDMXFixtureDisplayData
                Case #SCS_LT_DISP_ALL
                  SGS(WQK\cboFixture[nRowNo], nListIndex)
                  If nFixtureLinkGroup > 0
                    SGT(WQK\txtFixtureLinkGroup[nRowNo], Str(nFixtureLinkGroup))
                  Else
                    SGT(WQK\txtFixtureLinkGroup[nRowNo], "")
                  EndIf
                  If sSubFixtureCode
                    setEnabled(WQK\txtFixtureLinkGroup[nRowNo], #True, #True)
                  Else
                    setEnabled(WQK\txtFixtureLinkGroup[nRowNo], #False, #True)
                  EndIf
                Case #SCS_LT_DISP_1ST
                  SGS(WQK\aFix1(nRowNo)\cboFixture1, nListIndex)
                  If nFixtureLinkGroup > 0
                    SGT(WQK\aFix1(nRowNo)\txtFixtureLinkGroup1, Str(nFixtureLinkGroup))
                  Else
                    SGT(WQK\aFix1(nRowNo)\txtFixtureLinkGroup1, "")
                  EndIf
                  If sSubFixtureCode
                    setEnabled(WQK\aFix1(nRowNo)\txtFixtureLinkGroup1, #True, #True)
                  Else
                    setEnabled(WQK\aFix1(nRowNo)\txtFixtureLinkGroup1, #False, #True)
                  EndIf
              EndSelect
            Next nRowNo
            For nRowNo = (nMaxFixtureRow + 1) To grLicInfo\nMaxLightingDevPerSub
              SGT(WQK\txtFixtureLinkGroup[nRowNo], "")
            Next nRowNo
            For nRowNo = (nMaxFixtureRow + 1) To ArraySize(WQK\aFix1())
              SGT(WQK\aFix1(nRowNo)\txtFixtureLinkGroup1, "")
            Next nRowNo
            Select grMemoryPrefs\nDMXFixtureDisplayData
              Case #SCS_LT_DISP_ALL
                debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + nSetCurrentItem + ")")
                WQK_setCurrentFixtureInfo(nSetCurrentItem)
                setVisible(WQK\cntFixtures, #True)
                setVisible(WQK\cntFixtures1, #False)
              Case #SCS_LT_DISP_1ST
                debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + nSetCurrentItem + ")")
                WQK_setCurrentFixtureInfo1(nSetCurrentItem)
                setVisible(WQK\cntFixtures1, #True)
                setVisible(WQK\cntFixtures, #False)
            EndSelect
            ; debugMsg0(sProcName, "calling WQK_setScaFixturesInnerHeight()")
            WQK_setScaFixturesInnerHeight()
            setVisible(WQK\cntItems, #False)
            WQK_setFixtureInfoEnabledState()
          EndIf
          
        Case #SCS_LT_ENTRY_TYPE_BLACKOUT
          setVisible(WQK\cntItems, #False)
          setVisible(WQK\cntFixtures, #False)
          setVisible(WQK\cntFixtures1, #False)
          
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          WQK_populateDMXItemsEtc()
          setVisible(WQK\cntItems, #True)
          setVisible(WQK\cntFixtures, #False)
          setVisible(WQK\cntFixtures1, #False)

        Default
          setVisible(WQK\cntItems, #True)
          setVisible(WQK\cntFixtures, #False)
          setVisible(WQK\cntFixtures1, #False)
          
      EndSelect
      
      WQK_setFadeAndLiveDMXTestGadgets()
      
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_End)
  
EndProcedure

Procedure WQK_fcFixture1(Index)
  PROCNAMECS(nEditSubPtr)
  Protected bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_1ST
    If Index <= aSub(nEditSubPtr)\nMaxFixture
      If aSub(nEditSubPtr)\aLTFixture(Index)\sLTFixtureCode
        bEnabled = #True
      EndIf
    EndIf
    With WQK\aFix1(Index)
      If bEnabled = #False
        SGT(\txtFixtureLinkGroup1, "")
        setOwnState(\chkFixtureChanIncluded1, #PB_Checkbox_Unchecked)
        SGT(\txtFixtureChannel1, "")
        SGT(\txtFixtureChannelValue1, "")
        SLD_setValue(\sldFixtureChannelValue1, 0)
        setOwnState(\chkFixtureChanApplyFadeTime1, #PB_Checkbox_Unchecked)
      EndIf
      setEnabled(\txtFixtureLinkGroup1, bEnabled)
      setOwnEnabled(\chkFixtureChanIncluded1, bEnabled)
      setEnabled(\txtFixtureChannel1, bEnabled)
      setEnabled(\txtFixtureChannelValue1, bEnabled)
      SLD_setEnabled(\sldFixtureChannelValue1, bEnabled)
      setOwnEnabled(\chkFixtureChanApplyFadeTime1, bEnabled)
    EndWith
  EndIf
EndProcedure

Procedure WQK_cboFixture_Click(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u, n, nStepIndex
  Protected sItem.s
  Protected sOldFixtureCode.s, sNewFixtureCode.s, nNewFixtureId, sNewFixtureInfo.s
  Protected nOldFixTypeIndex=-1, nNewFixTypeIndex=-1
  Protected nProdDevNo
  Protected nLTEntryType, nFixtureGadgetNo, nLinkGroupGadgetNo
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  nLTEntryType = aSub(nEditSubPtr)\nLTEntryType
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      sItem = GGT(WQK\lblFixtures) + " [" + Str(Index+1) + "]"  ; eg "Fixtures to be included in this cue [2]" for the fixture on the 2nd row
      nFixtureGadgetNo = WQK\cboFixture[Index]
      nLinkGroupGadgetNo = WQK\txtFixtureLinkGroup[Index]
    Case #SCS_LT_DISP_1ST
      sItem = GGT(WQK\lblFixtures1) + " [" + Str(Index+1) + "]"  ; eg "Fixtures to be included in this cue [2]" for the fixture on the 2nd row
      nFixtureGadgetNo = WQK\aFix1(Index)\cboFixture1
      nLinkGroupGadgetNo = WQK\aFix1(Index)\txtFixtureLinkGroup1
  EndSelect
  
  nNewFixtureId = getCurrentItemData(nFixtureGadgetNo)
  sNewFixtureInfo = GetGadgetText(nFixtureGadgetNo)
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
  With grProd\aLightingLogicalDevs(nProdDevNo)
    For n = 0 To \nMaxFixture
      If \aFixture(n)\nFixtureId = nNewFixtureId
        sNewFixtureCode = \aFixture(n)\sFixtureCode
        Break
      EndIf
    Next n
  EndWith
  
  With aSub(nEditSubPtr)
    If Index <= ArraySize(\aLTFixture()) And Index <= \nMaxFixture
      sOldFixtureCode = \aLTFixture(Index)\sLTFixtureCode
    Else
      sOldFixtureCode = ""
    EndIf
    debugMsg(sProcName, "sOldFixtureCode=" + sOldFixtureCode + ", sNewFixtureCode=" + sNewFixtureCode + ", nNewFixtureId=" + nNewFixtureId + ", sNewFixtureInfo=" + sNewFixtureInfo)
    If sNewFixtureCode <> sOldFixtureCode
      If sOldFixtureCode
        nOldFixTypeIndex = getFixTypeIndexForFixture(@grProd, @aSub(nEditSubPtr), sOldFixtureCode)
      EndIf
      If sNewFixtureCode
        nNewFixTypeIndex = getFixTypeIndexForFixture(@grProd, @aSub(nEditSubPtr), sNewFixtureCode)
      EndIf
      u = preChangeSubS(sOldFixtureCode, sItem)
      If sNewFixtureCode
        If Index > ArraySize(\aLTFixture())
          REDIM_ARRAY(\aLTFixture, Index, grLTSubFixtureDef, "aLTFixture()")
          ReDim grWQK\nChanIndex1(Index)
        EndIf
        If Index > \nMaxFixture
          \nMaxFixture = Index
        EndIf
        For nStepIndex = 0 To \nMaxChaseStepIndex
          If \nMaxFixture > ArraySize(\aChaseStep(nStepIndex)\aFixtureItem())
            ReDim \aChaseStep(nStepIndex)\aFixtureItem(\nMaxFixture)
            debugMsg(sProcName, "ReDim \aChaseStep(" + nStepIndex + ")\aFixtureItem(" + \nMaxFixture + ")")
          EndIf
        Next nStepIndex
      EndIf
      \aLTFixture(Index)\sLTFixtureCode = sNewFixtureCode
      If sNewFixtureCode <> sOldFixtureCode
        syncLightingSubForFixtures(@grProd, @aSub(nEditSubPtr), -1, Index)
      EndIf
      If (nNewFixTypeIndex <> nOldFixTypeIndex) Or (nNewFixTypeIndex < 0)
        \aLTFixture(Index)\nFixtureLinkGroup = 0
        SGT(nLinkGroupGadgetNo, "")
      EndIf
      WQK_commonUpdateProcessing()
      postChangeSubS(u, sNewFixtureCode)
      If sNewFixtureCode
        setEnabled(nLinkGroupGadgetNo, #True, #True)
      Else
        setEnabled(nLinkGroupGadgetNo, #False, #True)
      EndIf
    EndIf
  EndWith
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      WQK_setCurrentFixtureInfo(Index)
    Case #SCS_LT_DISP_1ST
      WQK_setCurrentFixtureInfo1(Index)
      WQK_fcFixture1(Index)
  EndSelect
  
  ; debugMsg0(sProcName, "calling WQK_setScaFixturesInnerHeight()")
  WQK_setScaFixturesInnerHeight()
  
  grWQK\bInValidate = #False
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WQK_txtFixtureLinkGroup_Validate(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sItem.s, sLinkGroup.s, sNewLinkGroup.s, nOldLinkGroup, nNewLinkGroup, nErrorCode, sMsg.s
  Protected sFixtureCode.s ; only used to ensure we don't save a link group for a non-present fixture code
  Protected nLinkGroupGadgetNo
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWQK\bInValidate
    ProcedureReturn #True
  EndIf
  grWQK\bInValidate = #True
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      sLinkGroup = GGT(WQK\lblFixtureLinkGroup)
      nLinkGroupGadgetNo = WQK\txtFixtureLinkGroup[Index]
    Case #SCS_LT_DISP_1ST
      sLinkGroup = GGT(WQK\lblFixtureLinkGroup1)
      nLinkGroupGadgetNo = WQK\aFix1(Index)\txtFixtureLinkGroup1
  EndSelect
  sItem = sLinkGroup + " [" + Str(Index+1) + "]"  ; eg "Link Group [2]" for the link group on the 2nd row
  
  With aSub(nEditSubPtr)
    If (Index <= ArraySize(\aLTFixture())) And (Index <= \nMaxFixture)
      sFixtureCode = \aLTFixture(Index)\sLTFixtureCode
    EndIf
    If Len(sFixtureCode) = 0
      ; no fixture code present, so ignore this link group setting (shouldn't get here)
      grWQK\bInValidate = #False
      ProcedureReturn #True
    EndIf
    
    sNewLinkGroup = Trim(GGT(nLinkGroupGadgetNo))
    If sNewLinkGroup And IsNumeric(sNewLinkGroup)
      nNewLinkGroup = Val(sNewLinkGroup)
      If (nNewLinkGroup < 1) Or (nNewLinkGroup > 9)
        ; sMsg = LangPars("Errors", "MustBeBetween", GGT(nLinkGroupGadgetNo), "1", "9")
        sMsg = LangPars("Errors", "MustBeBetween", sLinkGroup + " (" + sNewLinkGroup + ")", "1", "9") ; Mod 18Aug2021 11.8.5.1ab
      Else
        nErrorCode = WQK_newFixtureInLinkGroup(Index, nNewLinkGroup, #True)
        If nErrorCode = 1
          sMsg = Lang("Errors", "LinkGroupFixType")
        EndIf
      EndIf
    Else
      nNewLinkGroup = 0
    EndIf
    
    If sMsg
      ensureSplashNotOnTop()
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      grWQK\bInValidate = #False
      ProcedureReturn #False
    EndIf
    
    If (Index <= ArraySize(\aLTFixture())) And (Index <= \nMaxFixture)
      nOldLinkGroup = \aLTFixture(Index)\nFixtureLinkGroup
    Else
      nOldLinkGroup = 0
    EndIf
    debugMsg(sProcName, "nOldLinkGroup=" + nOldLinkGroup + ", nNewLinkGroup=" + nNewLinkGroup)
    If nNewLinkGroup <> nOldLinkGroup
      u = preChangeSubL(nOldLinkGroup, sItem)
      \aLTFixture(Index)\nFixtureLinkGroup = nNewLinkGroup
      WQK_newFixtureInLinkGroup(Index, nNewLinkGroup)
      WQK_commonUpdateProcessing()
      postChangeSubL(u, nNewLinkGroup)
    EndIf
  EndWith
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo(" + Index + ")")
      WQK_setCurrentFixtureInfo(Index)
    Case #SCS_LT_DISP_1ST
      debugMsg(sProcName, "calling WQK_setCurrentFixtureInfo1(" + Index + ")")
      WQK_setCurrentFixtureInfo1(Index)
  EndSelect
  
  grWQK\bInValidate = #False
  ProcedureReturn #True
EndProcedure

Procedure WQK_txtFixtureChannelValue_Validate(Index)
  PROCNAMECS(nEditSubPtr)
  Protected u, sItem.s
  Protected nStepIndex, nFixtureIndex, nChanIndex
  Protected sOlnDMXDisplayValue.s, sNewDMXDisplayValue.s, sMsg.s
  Protected nChanValGadgetNo, nLabelGadgetNo
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nStepIndex = grWQK\nCurrStepIndex
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      nFixtureIndex = grWQK\nSelectedFixture
      nChanIndex = Index
      nChanValGadgetNo = WQK\txtFixtureChannelValue[nChanIndex]
      nLabelGadgetNo = WQK\lblDMXValue2
      sItem = WQK_buildFixtureChanPreChangeDesc(nFixtureIndex, nChanIndex)
    Case #SCS_LT_DISP_1ST
      nFixtureIndex = Index
      nChanIndex = grWQK\nChanIndex1(nFixtureIndex)
      nChanValGadgetNo = WQK\aFix1(Index)\txtFixtureChannelValue1
      nLabelGadgetNo = WQK\lblDMXValue21
      sItem = GGT(nLabelGadgetNo) + " [" + nStepIndex + "." + nFixtureIndex + "." + Str(nChanIndex+1) + "]"
  EndSelect
  
  sNewDMXDisplayValue = Trim(GGT(nChanValGadgetNo))

  If Len(sNewDMXDisplayValue) = 0
    sMsg = LangPars("Errors", "MustBeEntered", GGT(nLabelGadgetNo))
  ElseIf DMX_validateAndConvertDMXDisplayValue(sNewDMXDisplayValue) = #False
    sMsg = Lang("DMX", "InvalidDMXValue")
  EndIf
  If sMsg
    ensureSplashNotOnTop()
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  With aSub(nEditSubPtr)
    If nStepIndex >= 0
      If (nFixtureIndex <= ArraySize(\aChaseStep(nStepIndex)\aFixtureItem())) And (nFixtureIndex <= \nMaxFixture)
        sOlnDMXDisplayValue = \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue
        If sNewDMXDisplayValue <> sOlnDMXDisplayValue
          u = preChangeSubS(sOlnDMXDisplayValue, sItem)
          \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue = sNewDMXDisplayValue
          \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nDMXDisplayValue = grDMXValueInfo\nDMXDisplayValue
          \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nDMXAbsValue = grDMXValueInfo\nDMXAbsValue
          \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bDMXAbsValue = grDMXValueInfo\bDMXAbsValue
          ; now set slider value
          WQK_setSldFixtureChannelValueMax(nEditSubPtr, nFixtureIndex, nChanIndex)
          SLD_setValue(WQK\sldFixtureChannelValue[nChanIndex], grDMXValueInfo\nDMXDisplayValue)
          WQK_applyFixtureSettingsToLinkGroupIfReqd(nFixtureIndex, nChanIndex)
          If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_1ST
            WQK_setCurrentFixtureInfo1(nFixtureIndex) ; re-populates other rows, which is necessary if in a link group
          EndIf
          WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
          postChangeSubS(u, sNewDMXDisplayValue)
          WQK_setResetButtonEnabledState()
          If grWQK\bLiveDMXTest
            ; debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, " + StrB(grWQK\bLiveDMXTest) + ")")
            DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WQK_applyFixtureSettingsToLinkGroupIfReqd(nFixtureIndex, nChanIndex)
  PROCNAMECS(nEditSubPtr)
  Protected nStepIndex
  Protected nLinkGroup, n
  
  ; debugMsg(sProcName, #SCS_START + ", nChanIndex=" + nChanIndex)
  
  nStepIndex = grWQK\nCurrStepIndex
  
  If nFixtureIndex <= ArraySize(aSub(nEditSubPtr)\aLTFixture())
    nLinkGroup = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\nFixtureLinkGroup
    ; debugMsg(sProcName, "nFixtureIndex=" + nFixtureIndex + ", nChanIndex=" + nChanIndex + ", nLinkGroup=" + nLinkGroup)
    If nLinkGroup > 0
      With aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
        For n = 0 To aSub(nEditSubPtr)\nMaxFixture
          If n <> nFixtureIndex
            If aSub(nEditSubPtr)\aLTFixture(n)\nFixtureLinkGroup = nLinkGroup
              ; found another fixture in this lighting sub-cue that is in the same link group, so apply the same change to this fixture channel
              If nChanIndex <= ArraySize(aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(n)\aFixChan())
                aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(n)\aFixChan(nChanIndex) = aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
              Else
                debugMsg0(sProcName, "ignoring nChanIndex=" + nChanIndex + " for fixture " + aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(n)\sFixtureCode)
              EndIf
            EndIf
          EndIf
        Next n
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure WQK_sldFixtureChannelValueCommon(Index)
  ; PROCNAMECS(nEditSubPtr)
  Protected u, sItem.s
  Protected nStepIndex, nFixtureIndex, nChanIndex
  Protected nOlnDMXDisplayValue, nNewDMXDisplayValue
  Protected nSliderGadgetNo, nChanValGadgetNo
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nStepIndex = grWQK\nCurrStepIndex
  
  Select grMemoryPrefs\nDMXFixtureDisplayData
    Case #SCS_LT_DISP_ALL
      nFixtureIndex = grWQK\nSelectedFixture
      nChanIndex = Index
      ; sItem = GGT(WQK\lblDMXValue2) + " [" + nStepIndex + "." + nFixtureIndex + "." + Str(nChanIndex+1) + "]"
      sItem = WQK_buildFixtureChanPreChangeDesc(nFixtureIndex, nChanIndex)
      nSliderGadgetNo = WQK\sldFixtureChannelValue[nChanIndex]
      nChanValGadgetNo = WQK\txtFixtureChannelValue[nChanIndex]
    Case #SCS_LT_DISP_1ST
      nFixtureIndex = Index
      nChanIndex = grWQK\nChanIndex1(Index)
      sItem = GGT(WQK\lblDMXValue21) + " [" + nStepIndex + "." + nFixtureIndex + "." + Str(nChanIndex+1) + "]"
      nSliderGadgetNo = WQK\aFix1(nFixtureIndex)\sldFixtureChannelValue1
      nChanValGadgetNo = WQK\aFix1(nFixtureIndex)\txtFixtureChannelValue1
  EndSelect
  
  With aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
    nOlnDMXDisplayValue = \nDMXDisplayValue
    nNewDMXDisplayValue = SLD_getValue(nSliderGadgetNo)
    If nNewDMXDisplayValue <> nOlnDMXDisplayValue
      u = preChangeSubL(nOlnDMXDisplayValue, sItem)
      \nDMXDisplayValue = nNewDMXDisplayValue
      If \bDMXAbsValue
        \nDMXAbsValue = nNewDMXDisplayValue
        \sDMXDisplayValue = "d" + Str(\nDMXAbsValue)
      Else
        \nDMXAbsValue = nNewDMXDisplayValue * 2.55
        \sDMXDisplayValue = Str(nNewDMXDisplayValue)
      EndIf
      WQK_applyFixtureSettingsToLinkGroupIfReqd(nFixtureIndex, nChanIndex)
      If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_1ST
        WQK_setCurrentFixtureInfo1(nFixtureIndex) ; re-populates other rows, which is necessary if in a link group
      EndIf
      If \sDMXDisplayValue
        SGT(nChanValGadgetNo, \sDMXDisplayValue)
      Else
        SGT(nChanValGadgetNo, "0")
      EndIf
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      postChangeSubL(u, nNewDMXDisplayValue)
      If grWQK\bLiveDMXTest
        ; debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, #True)")
        DMX_prepareDMXForSend(nEditSubPtr, #False, #True)
      EndIf
      WQK_setResetButtonEnabledState()
    EndIf
  EndWith
  
EndProcedure

Procedure WQK_fcFixtureChanIncluded(nFixtureIndex, nChanIndex)
  ; PROCNAMECS(nEditSubPtr)
  Protected nStepIndex, bEnableGadgets
  
  nStepIndex = grWQK\nCurrStepIndex
  ; debugMsg(sProcName, "nStepIndex=" + nStepIndex + ", nFixtureIndex=" + nFixtureIndex + ", nChanIndex=" + nChanIndex + ", aSub(" + getSubLabel(nEditSubPtr) + ")\nLTEntryType=" + decodeLTEntryType(aSub(nEditSubPtr)\nLTEntryType))
  With aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
    If \bRelChanIncluded
      bEnableGadgets = #True
    EndIf
    Select grMemoryPrefs\nDMXFixtureDisplayData
      Case #SCS_LT_DISP_ALL
        setEnabled(WQK\txtFixtureChannelValue[nChanIndex], bEnableGadgets, #True)
        SLD_setEnabled(WQK\sldFixtureChannelValue[nChanIndex], bEnableGadgets)
        If aSub(nEditSubPtr)\bChase = #False
          setOwnEnabled(WQK\chkFixtureChanApplyFadeTime[nChanIndex], bEnableGadgets)
        Else
          setOwnEnabled(WQK\chkFixtureChanApplyFadeTime[nChanIndex], #False)
        EndIf
      Case #SCS_LT_DISP_1ST
        setEnabled(WQK\aFix1(nFixtureIndex)\txtFixtureChannelValue1, bEnableGadgets, #True)
        SLD_setEnabled(WQK\aFix1(nFixtureIndex)\sldFixtureChannelValue1, bEnableGadgets)
        If aSub(nEditSubPtr)\bChase = #False
          setOwnEnabled(WQK\aFix1(nFixtureIndex)\chkFixtureChanApplyFadeTime1, bEnableGadgets)
        Else
          setOwnEnabled(WQK\aFix1(nFixtureIndex)\chkFixtureChanApplyFadeTime1, #False)
        EndIf
    EndSelect
  EndWith
  
EndProcedure

Procedure.s WQK_buildFixtureChanPreChangeDesc(nFixtureIndex, nChanIndex)
  PROCNAMECS(nEditSubPtr)
  Protected sPreChangeDesc.s, sFixtureCode.s
  Static sChannelsAndValues.s, sChannel.s, sChaseStep.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sChannelsAndValues = Lang("WQK", "lblDMXValue2")
    sChannel = Lang("Common", "Channel")
    sChaseStep = Lang("WQK", "ChaseStep")
    bStaticLoaded = #True
  EndIf
  
  sFixtureCode = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
  sPreChangeDesc = ReplaceString(sChannelsAndValues, "$1", sFixtureCode) + ", " + sChannel + " " + Str(nChanIndex+1)
  If aSub(nEditSubPtr)\bChase Or grWQK\nCurrStepIndex > 0
    sPreChangeDesc + ", " + ReplaceString(sChaseStep, "$1", Str(grWQK\nCurrStepIndex+1))
  EndIf
  
  ProcedureReturn sPreChangeDesc
  
EndProcedure

Procedure WQK_chkFixtureChanIncluded_Click(nFixtureIndex, nChanIndex, bInChkIncludeProcessing=#False)
  PROCNAMECS(nEditSubPtr)
  Protected u, sItem.s
  Protected nStepIndex, nLabelGadgetNo, nCheckboxGadgetNo, nLTEntryType
  Protected bOldRelChanIncluded, bNewRelChanIncluded
  
  debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex + ", nChanIndex=" + nChanIndex)
  
  nStepIndex = grWQK\nCurrStepIndex
  nLTEntryType = aSub(nEditSubPtr)\nLTEntryType
  
  With WQK
    Select grMemoryPrefs\nDMXFixtureDisplayData
      Case #SCS_LT_DISP_ALL
        nLabelGadgetNo = \lblDMXValue2
        nCheckboxGadgetNo = \chkFixtureChanIncluded[nChanIndex]
      Case #SCS_LT_DISP_1ST
        nLabelGadgetNo = \lblDMXValue21
        nCheckboxGadgetNo = \aFix1(nFixtureIndex)\chkFixtureChanIncluded1
    EndSelect
  EndWith
  
  ; sItem = GGT(nLabelGadgetNo) + " [" + nStepIndex + "." + nFixtureIndex + "." + Str(nChanIndex+1) + "]"
  sItem = WQK_buildFixtureChanPreChangeDesc(nFixtureIndex, nChanIndex)

  With aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
    bOldRelChanIncluded = \bRelChanIncluded
    If getOwnState(nCheckboxGadgetNo) = #PB_Checkbox_Checked
      bNewRelChanIncluded = #True
    EndIf
    If bNewRelChanIncluded <> bOldRelChanIncluded
      u = preChangeSubL(bOldRelChanIncluded, sItem)
      \bRelChanIncluded = bNewRelChanIncluded
      WQK_applyFixtureSettingsToLinkGroupIfReqd(nFixtureIndex, nChanIndex)
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, bNewRelChanIncluded)
      WQK_fcFixtureChanIncluded(nFixtureIndex, nChanIndex)
      If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_1ST
        WQK_setCurrentFixtureInfo1(nFixtureIndex) ; re-populates other rows, which is necessary if in a link group
      EndIf
      If bInChkIncludeProcessing = #False
        ; See also WQK_chkInclude_Click()
        WQK_setResetButtonEnabledState()
        If grWQK\bLiveDMXTest
          ; debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, " + StrB(grWQK\bLiveDMXTest) + ")")
          DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
        EndIf
        WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
        WQK_setChkInclude(nFixtureIndex)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WQK_chkFixtureChanApplyFadeTime_Click(nFixtureIndex, nChanIndex)
  PROCNAMECS(nEditSubPtr)
  Protected u, sItem.s
  Protected nStepIndex, nLabelGadgetNo, nCheckboxGadgetNo, nLTEntryType
  Protected bOldChanApplyFadeTime, bNewChanApplyFadeTime
  
  debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex + ", nChanIndex=" + nChanIndex)
  
  nStepIndex = grWQK\nCurrStepIndex
  nLTEntryType = aSub(nEditSubPtr)\nLTEntryType
  
  With WQK
    Select grMemoryPrefs\nDMXFixtureDisplayData
      Case #SCS_LT_DISP_ALL
        nLabelGadgetNo = \lblDMXValue2
        nCheckboxGadgetNo = \chkFixtureChanApplyFadeTime[nChanIndex]
        sItem = WQK_buildFixtureChanPreChangeDesc(nFixtureIndex, nChanIndex)
      Case #SCS_LT_DISP_1ST
        nLabelGadgetNo = \lblDMXValue21
        nCheckboxGadgetNo = \aFix1(nFixtureIndex)\chkFixtureChanApplyFadeTime1
        sItem = GGT(nLabelGadgetNo) + " [" + nStepIndex + "." + nFixtureIndex + "." + Str(nChanIndex+1) + "]"
    EndSelect
  EndWith
  debugMsg(sProcName, "\nLTEntryType=" + decodeLTEntryType(aSub(nEditSubPtr)\nLTEntryType) + ", nLabelGadgetNo=" + getGadgetName(nLabelGadgetNo) + ", nCheckboxGadgetNo=" + getGadgetName(nCheckboxGadgetNo))

  With aSub(nEditSubPtr)\aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)
    bOldChanApplyFadeTime = \bApplyFadeTime
    If getOwnState(nCheckboxGadgetNo) = #PB_Checkbox_Checked
      bNewChanApplyFadeTime = #True
    EndIf
    debugMsg(sProcName, "bOldChanApplyFadeTime=" + strB(bOldChanApplyFadeTime) + ", bNewChanApplyFadeTime=" + strB(bNewChanApplyFadeTime) + ", getOwnState(" + getGadgetName(nCheckboxGadgetNo) + ")=" + getOwnState(nCheckboxGadgetNo))
    If bNewChanApplyFadeTime <> bOldChanApplyFadeTime
      u = preChangeSubL(bOldChanApplyFadeTime, sItem)
      \bApplyFadeTime = bNewChanApplyFadeTime
      debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aChaseStep(" + nStepIndex + ")\aFixtureItem(" + nFixtureIndex + ")\aFixChan(" + nChanIndex + ")\bApplyFadeTime=" + strB(\bApplyFadeTime))
      WQK_applyFixtureSettingsToLinkGroupIfReqd(nFixtureIndex, nChanIndex)
      If grMemoryPrefs\nDMXFixtureDisplayData = #SCS_LT_DISP_1ST
        WQK_setCurrentFixtureInfo1(nFixtureIndex) ; re-populates other rows, which is necessary if in a link group
      EndIf
      WQK_commonUpdateProcessing() ; Added 19Aug2021 11.8.5.1ab
      postChangeSubL(u, bNewChanApplyFadeTime)
      WQK_setResetButtonEnabledState()
      If grWQK\bLiveDMXTest
        ; debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, " + StrB(grWQK\bLiveDMXTest) + ")")
        DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WQK_newFixtureInLinkGroup(nFixtureIndex, nNewLinkGroup, bCheckOnly=#False)
  PROCNAMECS(nEditSubPtr)
  Protected nErrorCode
  Protected n, nStepIndex, nFromStepIndex, nUpToStepIndex, nTotalChans, nChanIndex
  Protected sThisFixtureCode.s, sFirstEntryFixtureCode.s, nThisFixTypeIndex, nFirstEntryFixTypeIndex
  
  debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex + ", nNewLinkGroup=" + nNewLinkGroup + ", bCheckOnly=" + strB(bCheckOnly))
  
  With aSub(nEditSubPtr)
    sThisFixtureCode = \aLTFixture(nFixtureIndex)\sLTFixtureCode
    nThisFixTypeIndex = getFixTypeIndexForFixture(@grProd, @aSub(nEditSubPtr), sThisFixtureCode)
    If (sThisFixtureCode) And (nNewLinkGroup > 0)
      For n = 0 To \nMaxFixture
        If n <> nFixtureIndex
          ; make sure we're not looking at the new entry
          If \aLTFixture(n)\nFixtureLinkGroup = nNewLinkGroup
            ; found the first selected fixture that is assigned to the group of the new entry
            ; IMPORTANT: check the fixture type of the new entry's fixture matches that of the first fixture in this link group
            sFirstEntryFixtureCode = \aLTFixture(n)\slTFixtureCode
            nFirstEntryFixTypeIndex = getFixTypeIndexForFixture(@grProd, @aSub(nEditSubPtr), sFirstEntryFixtureCode)
            If nThisFixTypeIndex <> nFirstEntryFixTypeIndex
              nErrorCode = 1
              Break ; quit processing
            EndIf
            If bCheckOnly = #False
              ; now copy the channel values etc from the first fixture in this link group, to the new fixture
              nFromStepIndex = 0
              If \nChaseSteps > 1
                nUpToStepIndex = (\nChaseSteps - 1)
              Else
                nUpToStepIndex = 0
              EndIf
              For nStepIndex = nFromStepIndex To nUpToStepIndex
                CopyArray(\aChaseStep(nStepIndex)\aFixtureItem(n)\aFixChan(), \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan())
              Next nStepIndex
            EndIf
            Break ; job done - get out
          EndIf
        EndIf
      Next n
    EndIf
  EndWith
  ProcedureReturn nErrorCode
EndProcedure

Procedure WQK_buildAndDisplayLightingMessage()
  PROCNAMECS(nEditSubPtr)
  ; NOTE: calls a procedure that updates *rSub so if editing then this must be called within a PreChangeSub/PostChangeSub sequence
  
  ; Prior to SCS 11.10.0bq this procedure included code to build messages:
  ;  "All DMX channels not listed above with no delay time (such as channel $1) will be set to 0 (zero) on starting this Lighting Cue (or Sub-Cue)." and
  ;  "All DMX channels not listed above will be set to 0 (zero) on starting this Lighting Cue (or Sub-Cue)."
  ; This functionality has now been removed as it is not applicable, as the 'fade out others' property replaces this.
  
  Protected sMsg.s
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      Select \nLTDevType
        Case #SCS_DEVTYPE_LT_DMX_OUT
          ; debugMsg0(sProcName, "calling DMX_buildDMXValuesString(" + getSubLabel(nEditSubPtr) + ")")
          sMsg = DMX_buildDMXValuesString(nEditSubPtr)
      EndSelect
      ; debugMsg(sProcName, "sMsg=" + sMsg)
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_populateNewChaseSteps(nOldMaxChaseStepIndex)
  PROCNAMECS(nEditSubPtr)
  Protected nFirstNewChaseStepIndex, nChaseStepIndex, nMaxChaseStepIndex
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If \bChase
        nMaxChaseStepIndex = \nMaxChaseStepIndex
        nFirstNewChaseStepIndex = nOldMaxChaseStepIndex + 1
        For nChaseStepIndex = nFirstNewChaseStepIndex To nMaxChaseStepIndex
          If nChaseStepIndex > 0
            \aChaseStep(nChaseStepIndex) = \aChaseStep(nChaseStepIndex-1)
            debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ") = \aChaseStep(" + Str(nChaseStepIndex-1) + ")")
          EndIf
        Next nChaseStepIndex
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQK_processTapDelayShortcut()
  PROCNAMECS(nEditSubPtr)
  Protected nDelayTime, nOldChaseSpeed, nNewChaseSpeed
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If \bChase
        nOldChaseSpeed = \nChaseSpeed
        nNewChaseSpeed = nOldChaseSpeed
        nDelayTime = DMX_calcTapDelayTime()
        debugMsg(sProcName, "nDelayTime=" + nDelayTime)
        If nDelayTime > 0
          nNewChaseSpeed = 60000 / nDelayTime
        EndIf
        If nNewChaseSpeed <> nOldChaseSpeed
          ; WQK_txtChaseSpeed_Validate() will throw an error if the chase speed is outside the range 1-480 BPM, so check that now to avoid the error being thrown
          If (nNewChaseSpeed >= 1) And (nNewChaseSpeed <= 480)
            SGT(WQK\txtChaseSpeed, Str(nNewChaseSpeed))
            WQK_txtChaseSpeed_Validate()
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQK_populateCboFixturesForDevNo(nDevNo)
  PROCNAMECS(nEditSubPtr)
  Protected nRowNo, nFixtureIndex
  Protected nMaxProdFixture, nMaxFixtureRow
  Protected sProdFixtureCode.s, sProdFixtureDesc.s, nProdFixtureId
  Protected nInternalHeight1, nCboGadgetNo, nCboGadgetNo1
  Protected qStartTime.q
  
  debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo)
  qStartTime = ElapsedMilliseconds()
  
  If nDevNo >= 0
    nMaxProdFixture = grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture
    nMaxFixtureRow = nMaxProdFixture
    If nMaxFixtureRow > grLicInfo\nMaxFixtureItemPerLightingSub
      nMaxFixtureRow = grLicInfo\nMaxFixtureItemPerLightingSub
    EndIf
    If nMaxFixtureRow < 0
      nMaxFixtureRow = 0
    EndIf
    ; debugMsg0(sProcName, "nMaxFixtureRow=" + nMaxFixtureRow)
    For nRowNo = 0 To grLicInfo\nMaxFixtureItemPerLightingSub
      ; nb must clear ALL visible rows to allow for opening a cue file with fewer fixtures than the cue file previously opened in this session
      nCboGadgetNo = WQK\cboFixture[nRowNo]
      ClearGadgetItems(nCboGadgetNo)
      nCboGadgetNo1 = WQK\aFix1(nRowNo)\cboFixture1
      ClearGadgetItems(nCboGadgetNo1)
      ; debugMsg0(sProcName, "nRowNo=" + nRowNo + ", nCboGadgetNo=" + getGadgetName(nCboGadgetNo) + ", nCboGadgetNo1=" + getGadgetName(nCboGadgetNo1))
      If nRowNo <= nMaxFixtureRow
        addGadgetItemWithData(nCboGadgetNo, "", -1)
        addGadgetItemWithData(nCboGadgetNo1, "", -1)
        For nFixtureIndex = 0 To nMaxProdFixture
          sProdFixtureCode = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
          sProdFixtureDesc = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureDesc
          nProdFixtureId = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\nFixtureId
          ; debugMsg0(sProcName, "sProdFixtureCode=" + sProdFixtureCode)
          If sProdFixtureCode
            addGadgetItemWithData(nCboGadgetNo, sProdFixtureCode + " (" + sProdFixtureDesc + ")", nProdFixtureId)
            addGadgetItemWithData(nCboGadgetNo1, sProdFixtureCode + " (" + sProdFixtureDesc + ")", nProdFixtureId)
          EndIf
        Next nFixtureIndex
      EndIf
    Next nRowNo
    nInternalHeight1 = (nMaxFixtureRow + 1) * 19
    SGAIR(WQK\scaFixtures, #PB_ScrollArea_InnerHeight, nInternalHeight1)
    SGAIR(WQK\scaFixtures1, #PB_ScrollArea_InnerHeight, nInternalHeight1)
    
    grWQK\nFixtureComboboxesPopulatedForDevNo = nDevNo
    ; debugMsg(sProcName, "grWQK\nFixtureComboboxesPopulatedForDevNo=" + grWQK\nFixtureComboboxesPopulatedForDevNo)
    
  EndIf
  
  debugMsg(sProcName, "time since start of procedure: " + Str(ElapsedMilliseconds() - qStartTime))
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_CaptureCheck(nBtnGadgetNo)
  ; The purpose of this procedure is to check if the user is trying to capture DMX into a Lighting Sub-Cue that already contains DMX items.
  ; If this is true then the user is asked if they want to continue with the capture, because the captured DMX will REPLACE the existing content.
  PROCNAMECS(nEditSubPtr)
  Protected bContinue = #True
  Protected nResponse
  
  If aSub(nEditSubPtr)\aChaseStep(0)\nDMXSendItemCount > 0
    ; At least one DMX item already exists in this Lighting Sub-Cue.
    nResponse = MessageRequester(GGT(nBtnGadgetNo), Lang("WQK", "ConfirmCapture"), #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning)
    If nResponse = #PB_MessageRequester_No
      bContinue = #False
    Else
      ; User wants to continue, so clear the existing data.
      aSub(nEditSubPtr)\aChaseStep(0)\nDMXSendItemCount = 0
      WQK_displayInfoForEntryType()
    EndIf
  EndIf
  
  ProcedureReturn bContinue
EndProcedure

Procedure WQK_btnCaptureSnapshot_Click()
  PROCNAMECS(nEditSubPtr)
  Protected bFTDIResult, ftStatus.l, ftHandle.i
  Protected send_on_change_flag.a
  
  debugMsg(sProcName, #SCS_START)
  
  WQK_clearLiveTestInfo()
  If WQK_CaptureCheck(WQK\cvsCaptureButton)
    With grDMX
      \nMaxDMXCapture = -1
      \nDMXCaptureNo + 1
      \bDMXCaptureSingleShot = #True
      \nDMXCaptureLimit = 5000
      \bDMXCaptureLimitWarningDisplayed = #False
      \bCaptureComplete = #False
      \nDMXCaptureControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, aSub(nEditSubPtr)\sLTLogicalDev)
      \qDMXCaptureStartTime = ElapsedMilliseconds()
      \bCaptureDMX = #True
      \bDMXSaveCapture = #True
      debugMsg(sProcName, "grDMX\bCaptureDMX=" + strB(grDMX\bCaptureDMX) + ", \bDMXSaveCapture=" + strB(\bDMXSaveCapture))
      ftHandle = gaDMXControl(\nDMXCaptureControlPtr)\nFTHandle
      DMX_getDMXCurrValues(ftHandle, gaDMXControl(\nDMXCaptureControlPtr)\nDMXPort, #True)
      WQK_processDMXCaptureComplete(5)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_btnCaptureStart_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nContainerBackColor
  Protected bFTDIResult, ftStatus.l, ftHandle
  Protected send_on_change_flag.a, nReqdLabel.a
  
  debugMsg(sProcName, #SCS_START)
  
  WQK_clearLiveTestInfo()
  
  grWQK\bStartingCapture = #True ; Added 15Jun2023 11.10.0bg
  debugMsg(sProcName, "grWQK\bStartingCapture=#True")
  
  With grDMX
    ; Implies button action requested is 'Start DMX Capture Sequence'
    debugMsg(sProcName, "Start DMX Capture Sequence")
    If WQK_CaptureCheck(WQK\cvsCaptureButton)
      grWQK\bCapturingDMXSequence = #True
      \nMaxDMXCapture = -1
      \nDMXCaptureNo + 1
      \bDMXCaptureSingleShot = #False
      \nDMXCaptureLimit = 5000
      \bDMXCaptureLimitWarningDisplayed = #False
      \bCaptureComplete = #False
      \nDMXCaptureControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, aSub(nEditSubPtr)\sLTLogicalDev)
      ftHandle = gaDMXControl(\nDMXCaptureControlPtr)\nFTHandle
      DMX_getDMXCurrValues(ftHandle, gaDMXControl(\nDMXCaptureControlPtr)\nDMXPort)
      Delay(200)
      Select gaDMXControl(\nDMXCaptureControlPtr)\nDMXPort
        Case 1
          nReqdLabel = #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1
        Case 2
          nReqdLabel = #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT2
      EndSelect
      send_on_change_flag = 1
      bFTDIResult = DMX_FTDI_SendData(ftHandle, nReqdLabel, @send_on_change_flag, 1)
      debugMsg(sProcName, "DMX_FTDI_SendData(" + decodeHandle(ftHandle) + ", " + decodeDMXAPILabel(nReqdLabel) + ", @send_on_change_flag, 1) returned " + strB(bFTDIResult) + ", send_on_change_flag=" + send_on_change_flag)
      Delay(200)
      \qDMXCaptureStartTime = ElapsedMilliseconds()
      \qTimeFirstPacket9Received = 0
      \bCaptureDMX = #True
      debugMsg(sProcName, "grDMX\bCaptureDMX=" + strB(grDMX\bCaptureDMX))
      \bDMXSaveCapture = #True
      debugMsg(sProcName, "calling DMX_requestData(" + \nDMXCaptureControlPtr + ", #True)")
      DMX_requestData(\nDMXCaptureControlPtr, #True)
      grDMX\bRequestNextImmediately = #True
      SetGadgetColors(WQK\lblCapturingDMX, #SCS_White, #SCS_Dark_Green)
      setVisible(WQK\lblCapturingDMX, #True)
      nContainerBackColor = GetGadgetColor(WQK\cntSubDetailK, #PB_Gadget_BackColor)
      If StartDrawing(CanvasOutput(WQK\cvsCapturingDMXLight))
        Box(0, 0, OutputWidth(), OutputHeight(), nContainerBackColor)
        Circle(11, 11, 5, RGB(255, 128, 0))
        StopDrawing()
      EndIf
      setVisible(WQK\cvsCapturingDMXLight, #True)
      SetGadgetData(WQK\cvsCaptureButton, #SCS_LT_CAPTURE_BTN_SEQ_STOP)
      WQK_drawCaptureButton(#False)
      setEnabled(WQK\chkLiveDMXTest, #False) ; disable live test during DMX capture (checkbox already cleared near start of this procedure)
      debugMsg(sProcName, "ArraySize(gaDMXCaptureItem())=" + ArraySize(gaDMXCaptureItem()))
      If ArraySize(gaDMXCaptureItem()) < 100
        ReDim gaDMXCaptureItem(100) ; reduce the overhead of redim while capturing DMX
      EndIf
      CompilerIf #c_dmx_receive_in_main_thread = #False
        debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_DMX_RECEIVE)")
        THR_createOrResumeAThread(#SCS_THREAD_DMX_RECEIVE)
      CompilerEndIf
    EndIf ; EndIf WQK_CaptureCheck(WQK\cvsCaptureButton)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_btnCaptureStop_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  CompilerIf #c_dmx_receive_in_main_thread = #False
    ; debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_DMX_RECEIVE)")
    THR_suspendAThreadAndWait(#SCS_THREAD_DMX_RECEIVE)
    ; debugMsg(sProcName, "returned from THR_suspendAThreadAndWait(#SCS_THREAD_DMX_RECEIVE)")
  CompilerEndIf
  
  WQK_clearLiveTestInfo()
  
  grWQK\bCapturingDMXSequence = #False
  setVisible(WQK\lblCapturingDMX, #False)
  setVisible(WQK\cvsCapturingDMXLight, #False)
  SetGadgetData(WQK\cvsCaptureButton, #SCS_LT_CAPTURE_BTN_SEQ_START)
  WQK_drawCaptureButton(#False)
  grDMX\qDMXCaptureStopTime = ElapsedMilliseconds()
  WQK_processDMXCaptureComplete(9)
  setEnabled(WQK\chkLiveDMXTest, #True)
  
  debugMsg0(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_processDMXCaptureComplete(nLabel)
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nCaptureItemIndex, nDMXItemIndex, nChaseStepIndex
  Protected sLabel.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START + ", nLabel=" + nLabel)
  
  ; debugMsg(sProcName, "calling DMX_loadDMXCaptureItemArray()")
  DMX_loadDMXCaptureItemArray()
  DMX_removeCaptureShakes()
  DMX_removeItemsToBeDeleted()
  DMX_deriveCaptureFades()
  
  ; debugMsg0(sProcName, "grDMX\nMaxDMXCaptureItem=" + grDMX\nMaxDMXCaptureItem)
  ; Now load the derived captured items into the sub-cue
  With aSub(nEditSubPtr)
    If grDMX\nMaxDMXCaptureItem < 0
      sLabel = Trim(GGT(WQK\lblLogicalDev))
      sMsg = LangPars("WQK", "NothingCaptured", sLabel, aSub(nEditSubPtr)\sLTLogicalDev)
      scsMessageRequester(getSubLabel(nEditSubPtr), sMsg, #PB_MessageRequester_Info)
    Else
      u = preChangeSubL(#False, "Capture DMX")
      \nChaseSteps = 1
      \nMaxChaseStepIndex = 0
      nChaseStepIndex = 0
      nDMXItemIndex = -1
      For nCaptureItemIndex = 0 To grDMX\nMaxDMXCaptureItem
        nDMXItemIndex + 1
        If nDMXItemIndex > ArraySize(\aChaseStep(nChaseStepIndex)\aDMXSendItem())
          ReDim \aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXItemIndex)
        EndIf
        \aChaseStep(nChaseStepIndex)\nDMXSendItemCount + 1
        \aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXItemIndex)\sDMXItemStr = gaDMXCaptureItem(nCaptureItemIndex)\sItemData
        DMX_unpackDMXSendItemStr(@aSub(nEditSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXItemIndex), @grProd, aSub(nEditSubPtr)\sLTLogicalDev)
        ; debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ")\aDMXSendItem(" + nDMXItemIndex + ")\sDMXItemStr=" + \aChaseStep(nChaseStepIndex)\aDMXSendItem(nDMXItemIndex)\sDMXItemStr)
      Next nCaptureItemIndex
      \nSubDuration = getSubLength(nEditSubPtr, #True)
      \sDMXSendString = DMX_buildDMXValuesString(nEditSubPtr)
      ; debugMsg(sProcName, "\nSubDuration=" + \nSubDuration + ", \sDMXSendString=" + \sDMXSendString)
      ; debugMsg(sProcName, "calling WQK_displayInfoForEntryType()")
      WQK_displayInfoForEntryType()
      WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
      debugMsg(sProcName, "\nSubDuration=" + \nSubDuration + ", \sDMXSendString=" + \sDMXSendString + ", \sLTDisplayInfo=" + \sLTDisplayInfo)
      postChangeSubL(u, #True)
      debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(\nCueIndex) + ")")
      loadGridRow(\nCueIndex)
    EndIf
  EndWith
  
  grDMX\bCaptureDMX = #False
  ; debugMsg(sProcName, "grDMX\bCaptureDMX=" + strB(grDMX\bCaptureDMX))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQK_calcGadgetRow()
  ; PROCNAMEC()
  ; procedure to calculate the row number of a gadget in the scaDMXItems scrollable area.
  ;  the procedure determines the row number from the position of the container of this gadget.
  ;  we cannot use the usual nGadgetArrayIndex because the user may have moved or deleted some rows, so the nGadgetArrayIndex then becomes
  ;  out-of-sync with the currently-displayed position.
  Protected nRow, nContainerGadgetNo
  
  nContainerGadgetNo = gaGadgetProps(gnEventGadgetPropsIndex)\nContainerGadgetNo
  nRow = Round(GadgetY(nContainerGadgetNo) / GadgetHeight(nContainerGadgetNo), #PB_Round_Down)
  
  ; debugMsg(sProcName, "nRow=" + nRow)
  ProcedureReturn nRow
EndProcedure

Procedure WQK_processCapturingInd()
  ; PROCNAMEC()
  Protected qTimeNow.q, qTimeDiff.q, nContainerBackColor, bPaintCapturingInd
  
  With grWQK
    If nEditSubPtr >= 0
      If aSub(nEditSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
        qTimeNow = ElapsedMilliseconds()
        If grDMX\qTimeLastDMXPacketForCaptureSaved > \qTimeOfLastDisplayChange
          \nCapturingDisplaySeq = 0
          bPaintCapturingInd = #True
          ; debugMsg(sProcName, "bPaintCapturingInd=" + strB(bPaintCapturingInd))
        ElseIf \nCapturingDisplaySeq = 0 And qTimeNow > (\qTimeOfLastDisplayChange + 200)
          \nCapturingDisplaySeq = 1
          bPaintCapturingInd = #True
          ; debugMsg(sProcName, "bPaintCapturingInd=" + strB(bPaintCapturingInd))
        Else
          ; debugMsg(sProcName, "bPaintCapturingInd=" + strB(bPaintCapturingInd))
        EndIf
        If bPaintCapturingInd
          If IsGadget(WQK\cntSubDetailK) And IsGadget(WQK\cvsCapturingDMXLight)
            nContainerBackColor = GetGadgetColor(WQK\cntSubDetailK, #PB_Gadget_BackColor)
            If StartDrawing(CanvasOutput(WQK\cvsCapturingDMXLight))
              Box(0, 0, OutputWidth(), OutputHeight(), nContainerBackColor)
              ; debugMsg(sProcName, "grWQK\nCapturingDisplaySeq=" + \nCapturingDisplaySeq)
              If \nCapturingDisplaySeq = 0
                Circle(11, 11, 5, RGB(255, 128, 0))
              EndIf
              \qTimeOfLastDisplayChange = qTimeNow
              StopDrawing()
            EndIf ; EndIf StartDrawing(CanvasOutput(WQK\cvsCapturingDMXLight))
          EndIf ; EndIf IsGadget(WQK\cntSubDetailK) And IsGadget(WQK\cvsCapturingDMXLight))
        EndIf ; EndIf bPaintCapturingInd
      EndIf ; EndIf aSub(nEditSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE
    EndIf ; EndIf nEditSubPtr >= 0
  EndWith
  
EndProcedure

Procedure WQK_clearLiveTestInfo()
  WQK_stopLiveDMXTestIfRunning()
  grWQK\bLiveDMXTest = #False ; turn off DMX live test
  grWQK\bSingleStep = #False ; turn off DMX single step live test
EndProcedure

Procedure WQK_resizeContainers()
  ; PROCNAMEC()
  Protected nSubDetailHeight, nTop, nHeight, nEntryType, nCntFadesHeight
  
  If nEditSubPtr >= 0 ; Test added 26Deb2025 11.10.7-b05 following email from Fabian
    nEntryType = aSub(nEditSubPtr)\nLTEntryType
    
    With WQK
      nSubDetailHeight = GadgetHeight(\cntSubDetailK)
      nTop = nSubDetailHeight - GadgetHeight(\cntTest) - 8
      ResizeGadget(\cntTest, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      
      If aSub(nEditSubPtr)\bChase And getVisible(\cntChase)
        nTop = GadgetY(\cntChase) + GadgetHeight(\cntChase) + 4
      Else
        nTop = GadgetY(\cboEntryType) + GadgetHeight(\cboEntryType) + 4
      EndIf
      nHeight = GadgetY(\cntTest) - nTop - 8
      
      ResizeGadget(\cntDMX, #PB_Ignore, nTop, #PB_Ignore, nHeight)
      
      If getVisible(\cntFades)
        Select nEntryType
          Case #SCS_LT_ENTRY_TYPE_BLACKOUT
            nCntFadesHeight = GadgetType(\cntBLFade) + GadgetHeight(\cntBLFade)
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            nCntFadesHeight = GadgetY(\cntDCFadeOutOthers) + GadgetHeight(\cntDCFadeOutOthers)
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            nCntFadesHeight = GadgetY(\cntDIFadeOutOthers) + GadgetHeight(\cntDIFadeOutOthers)
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            nCntFadesHeight = GadgetY(\cntFIFadeOutOthers) + GadgetHeight(\cntFIFadeOutOthers)
        EndSelect
        If nEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
          ResizeGadget(\cntFades, #PB_Ignore, 0, #PB_Ignore, nCntFadesHeight) ; position at top of \cntDMX
        Else
          nTop = GadgetHeight(\cntDMX) - GadgetHeight(\cntFades)
          ResizeGadget(\cntFades, #PB_Ignore, nTop, #PB_Ignore, nCntFadesHeight)
          nHeight = GadgetY(\cntFades) - GadgetY(\cntItems) - 8
        EndIf
      Else
        nHeight = GadgetHeight(\cntDMX) - GadgetY(\cntItems)
      EndIf
      
      If nEntryType <> #SCS_LT_ENTRY_TYPE_BLACKOUT
        ResizeGadget(\cntItems, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ResizeGadget(\cntFixtures, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ResizeGadget(\cntFixtures1, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        
        nHeight = GadgetHeight(\cntItems) - GadgetY(\scaDMXItems) - 4 ; minus 4 for a reasonable margin below the scrollarea
        ResizeGadget(\scaDMXItems, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        
        nHeight = GadgetHeight(\cntFixtures) - GadgetY(\scaFixtures) - 4 ; minus 4 for a reasonable margin below the scrollarea
        ResizeGadget(\scaFixtures, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ResizeGadget(\scaFixtureChans, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ResizeGadget(\lnFixtureChannels, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        
        nHeight = GadgetHeight(\cntFixtures1) - GadgetY(\scaFixtures1) - 4 ; minus 4 for a reasonable margin below the scrollarea
        ResizeGadget(\scaFixtures1, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        
        nTop = GadgetY(\cntDMX) + 17
        ResizeGadget(\cntLightingSideBar, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
      EndIf
    EndWith
  EndIf ; EndIf nEditSubPtr >= 0
  
EndProcedure

Procedure WQK_setChkInclude(nFixtureIndex)
  PROCNAMECS(nEditSubPtr)
  Protected nIncludeCount, nExcludeCount, n
  Protected nProdDevNo, nCurrStepIndex, nChanIndex, sFixtureCode.s, nFixTypeIndex, sFixTypeName.s, nTotalChans, nReqdCheckboxState
  
  debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex)
  
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
  nCurrStepIndex = grWQK\nCurrStepIndex
  If (nCurrStepIndex >= 0) And (nFixtureIndex >= 0)
    If nFixtureIndex <= aSub(nEditSubPtr)\nMaxFixture
      sFixtureCode = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
      For n = 0 To grProd\aLightingLogicalDevs(nProdDevNo)\nMaxFixture
        If grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixtureCode = sFixtureCode
          sFixTypeName = grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixTypeName
          Break
        EndIf
      Next n
      nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
      If nFixTypeIndex >= 0
        nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
      EndIf
    EndIf
    If sFixtureCode
      For nChanIndex = 0 To nTotalChans-1
        If aSub(nEditSubPtr)\aChaseStep(nCurrStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bRelChanIncluded
          nIncludeCount + 1
        Else
          nExcludeCount + 1
        EndIf
      Next nChanIndex
    EndIf
  EndIf
  If nIncludeCount = nTotalChans
    nReqdCheckboxState = #PB_Checkbox_Checked
  ElseIf nExcludeCount = nTotalChans
    nReqdCheckboxState = #PB_Checkbox_Unchecked
  Else
    nReqdCheckboxState = #PB_Checkbox_Inbetween
  EndIf
  setOwnState(WQK\chkInclude, nReqdCheckboxState)
  
EndProcedure

Procedure WQK_chkInclude_Click(nFixtureIndex)
  PROCNAMECS(nEditSubPtr)
  Protected u, sItem.s, bChangeState
  Protected n, nProdDevNo, nCurrStepIndex, nChanIndex, sFixtureCode.s, nFixTypeIndex, sFixTypeName.s, nTotalChans, nIncludeState
  Static IncludeForFixture.s, sChaseStep.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nFixtureIndex=" + nFixtureIndex)
  
  If bStaticLoaded = #False
    ; nb do not use LangPars() as parameters will be replaced dynamically
    IncludeForFixture = Lang("WQK", "IncludeForFixture")
    sChaseStep = Lang("WQK", "ChaseStep")
    bStaticLoaded = #True
  EndIf
  
  nIncludeState = getOwnState(WQK\chkInclude)
  Select nIncludeState
    Case #PB_Checkbox_Checked
      debugMsg(sProcName, "Checked")
    Case #PB_Checkbox_Unchecked
      debugMsg(sProcName, "Unchecked")
    Case #PB_Checkbox_Inbetween
      ; shouldn't get here
      debugMsg(sProcName, "Inbetween")
      ProcedureReturn
  EndSelect
  
  nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(nEditSubPtr)\sLTLogicalDev)
  nCurrStepIndex = grWQK\nCurrStepIndex
  If (nCurrStepIndex >= 0) And (nFixtureIndex >= 0)
    If nFixtureIndex <= aSub(nEditSubPtr)\nMaxFixture
      sFixtureCode = aSub(nEditSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
      sItem = ReplaceString(IncludeForFixture, "$1", sFixtureCode)
      If aSub(nEditSubPtr)\bChase Or nCurrStepIndex > 0
        sItem + ", " + ReplaceString(sChaseStep, "$1", Str(nCurrStepIndex+1))
      EndIf
      u = preChangeSubL(bChangeState, sItem)
      For n = 0 To grProd\aLightingLogicalDevs(nProdDevNo)\nMaxFixture
        If grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixtureCode = sFixtureCode
          sFixTypeName = grProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixTypeName
          Break
        EndIf
      Next n
      nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
      If nFixTypeIndex >= 0
        nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
      EndIf
      If sFixtureCode
        For nChanIndex = 0 To nTotalChans-1
          If getOwnState(WQK\chkFixtureChanIncluded[nChanIndex]) <> nIncludeState
            bChangeState = #True
            setOwnState(WQK\chkFixtureChanIncluded[nChanIndex], nIncludeState)
            WQK_chkFixtureChanIncluded_Click(nFixtureIndex, nChanIndex, #True)
          EndIf
        Next nChanIndex
        ; The following copied from WQK_chkFixtureChanIncluded_Click()
        WQK_setResetButtonEnabledState()
        If grWQK\bLiveDMXTest
          ; debugMsg(sProcName, "calling DMX_prepareDMXForSend(" + getSubLabel(nEditSubPtr) + ", #False, " + StrB(grWQK\bLiveDMXTest) + ")")
          DMX_prepareDMXForSend(nEditSubPtr, #False, grWQK\bLiveDMXTest)
        EndIf
        WQK_buildAndDisplayLightingMessage() ; nb updates aSub(nEditSubPtr)
        WQK_setChkInclude(nFixtureIndex)
        ; End of code copied from WQK_chkFixtureChanIncluded_Click()
      EndIf
      postChangeSubL(u, bChangeState)
    EndIf
  EndIf ; EndIf (nCurrStepIndex >= 0) And (nFixtureIndex >= 0)
  
EndProcedure

Procedure WQK_drawCaptureButton(bMouseOver)
  PROCNAMECS(nEditSubPtr)
  Protected nBtnType
  Protected nBackColor, nTextColor, sText.s, nTextWidth, nTextHeight, nLeft, nTop, nBorderColor, nContainerBackColor
  Static sSnap.s, sSeqStart.s, sSeqStop.s, bStaticLoaded
  
  ; debugMsg0(sProcName, "bMouseOver=" + strB(bMouseOver))
  
  If bStaticLoaded = #False
    sSnap = Lang("WQK", "RecordSnap")
    sSeqStart = Lang("WQK", "StartRec")
    sSeqStop = Lang("WQK", "StopRec")
    bStaticLoaded = #True
  EndIf
  
  If bMouseOver
    nBorderColor = RGB(128, 206, 255) ; light blue
  Else
    nBorderColor = RGB(173, 173, 173) ; grey
  EndIf
  
  nBtnType = GetGadgetData(WQK\cvsCaptureButton)
  
  Select nBtnType
    Case #SCS_LT_CAPTURE_BTN_SNAP
      sText = sSnap
      nBackColor = #SCS_Green
      nTextColor = #SCS_Black
    Case #SCS_LT_CAPTURE_BTN_SEQ_START
      sText = sSeqStart
      nBackColor = #SCS_Green
      nTextColor = #SCS_Black
    Case #SCS_LT_CAPTURE_BTN_SEQ_STOP
      sText = sSeqStop
      nBackColor = #SCS_Red
      nTextColor = #SCS_Black
  EndSelect
  
  If StartDrawing(CanvasOutput(WQK\cvsCaptureButton))
    nContainerBackColor = getGadgetContainerBackColor(WQK\cvsCaptureButton)
    Box(0, 0, OutputWidth(), OutputHeight(), nContainerBackColor)
    RoundBox(0, 0, OutputWidth(), OutputHeight(), 2, 2, nBorderColor)
    RoundBox(1, 1, OutputWidth()-2, OutputHeight()-2, 2, 2, nBackColor)
    scsDrawingFont(#SCS_FONT_GEN_NORMAL)
    nTextWidth = TextWidth(sText)
    nTextHeight = TextHeight(sText)
    nLeft = (OutputWidth() - nTextWidth) >> 1
    nTop = (OutputHeight() - nTextHeight) >> 1
    DrawText(nLeft, nTop, sText, nTextColor, nBackColor)
    StopDrawing()
  EndIf
  
EndProcedure

Procedure WQK_cvsCaptureButton_Event(nEventType)
  ; PROCNAMECS(nEditSubPtr)
  Protected nBtnType, bMouseOver
  
  nBtnType = GetGadgetData(WQK\cvsCaptureButton)
  Select nEventType
    Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
      bMouseOver = #True
    Case #PB_EventType_MouseLeave
      bMouseOver = #False
    Case #PB_EventType_LeftButtonDown ; #PB_EventType_LeftClick
      ; Changed from LeftClick to LeftButtonDown 15Jul2023 11.10.0bq as LeftButtonDown is processed sooner than LeftClick,
      ; and that appears to be significant while capturing DMX data.
      bMouseOver = #True
      Select nBtnType
        Case #SCS_LT_CAPTURE_BTN_SNAP
          WQK_btnCaptureSnapshot_Click()
        Case #SCS_LT_CAPTURE_BTN_SEQ_START
          WQK_btnCaptureStart_Click()
        Case #SCS_LT_CAPTURE_BTN_SEQ_STOP
          WQK_btnCaptureStop_Click()
      EndSelect
  EndSelect
  WQK_drawCaptureButton(bMouseOver)
EndProcedure

; EOF