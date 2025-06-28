; File: fmEditModal.pbi

EnableExplicit

Procedure WEM_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  getFormPosition(#WEM, @grEditModalWindow)
  unsetWindowModal(#WEM)
  setWindowVisible(#WEM, #False)
  ; Added 30Aug2021 11.8.6af
  If grWEM\nSourceForm = #WQF
    WQF_refreshTempoEtcInfo()
  EndIf
  If IsWindow(grWEM\nPrevActiveWindow)
    SetActiveWindow(grWEM\nPrevActiveWindow)
  EndIf
  ; End added 30Aug2021 11.8.6af
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_closeWindow()
  PROCNAMEC()
  Protected nResponse
  
  If getVisible(WEM\btnCancel)
    nResponse = scsMessageRequester(GWT(#WEM), Lang("Common", "ApplyChanges"), #PB_MessageRequester_YesNoCancel|#MB_ICONQUESTION)
    Select nResponse
      Case #PB_MessageRequester_Cancel
        debugMsg(sProcName, "nResponse=Cancel")
        ProcedureReturn
      Case #PB_MessageRequester_Yes
        debugMsg(sProcName, "nResponse=Yes")
        WEM_btnOK_Click()
      Case #PB_MessageRequester_No
        debugMsg(sProcName, "nResponse=No")
        WEM_Form_Unload()
    EndSelect
  Else ; cancel button not visible
    WEM_Form_Unload()
  EndIf
  
EndProcedure

Procedure WEM_setButtons()
  PROCNAMEC()
  Protected bEnableReset, bEnableClear, bEnableClearSelection, bEnableUseDefaults, bEnableGrid
  
  With grWEM
    If \bCntCuePoints
      If \bMaxCuePointCuesReached
        bEnableGrid = #False
      Else
        bEnableGrid = #True
        If \bTxtChanged Or \sReqdCPName <> \sOrigCPName Or \dReqdCPTimePos <> \dOrigCPTimePos Or \nReqdTime <> \nOrigTime
          bEnableReset = #True
        EndIf
        If \sReqdCPName
          bEnableClear = #True
          bEnableClearSelection = #True
        ElseIf \nReqdTime >= 0 Or Trim(GGT(WEM\txtValue))
          bEnableClear = #True
        EndIf
      EndIf
      setEnabled(WEM\btnCuePointsReset, bEnableReset)
      setEnabled(WEM\btnCuePointsClear, bEnableClear)
      setEnabled(WEM\btnCuePointsClearSelection, bEnableClearSelection)
      setEnabled(WEM\grdCuePoints, bEnableGrid)
      
    ElseIf \bCntFadeTime
      If \bTxtChanged Or \nReqdTime <> \nOrigTime Or \nReqdFadeType <> \nOrigFadeType
        bEnableReset = #True
      EndIf
      If \nReqdTime >= 0 Or \nReqdFadeType <> #SCS_FADE_STD Or Trim(GGT(WEM\txtFadeValue))
        bEnableClear = #True
      EndIf
      If (\nReqdTime <> \nDefFadeTime And \nDefFadeTime >= 0) Or \nReqdFadeType <> \nDefFadeType
        bEnableUseDefaults = #True
      EndIf
      setEnabled(WEM\btnUseDefaults, bEnableUseDefaults)
      setEnabled(WEM\btnFadeReset, bEnableReset)
      setEnabled(WEM\btnFadeClear, bEnableClear)
      
    ElseIf \bCntTempoEtc
      If grTempoEtc\nAudTempoEtcCurrAction <> #SCS_AF_ACTION_NONE
        If grTempoEtc\fTempoEtcCurrValue <> grTempoEtc\fTempoEtcDefaultValue
          bEnableReset = #True
        EndIf
      EndIf
      setEnabled(WEM\btnTempoEtcReset, bEnableReset)
      
    EndIf
  EndWith

EndProcedure

Procedure WEM_txtField_Change()
  PROCNAMEC()
  
  grWEM\bTxtChanged = #True
  WEM_setButtons()
  
EndProcedure

Procedure WEM_txtValue_Validate()
  PROCNAMEC()
  Protected bValidationResult
  
  With grWEM
    ; call respective validation procedure with 'bReturnBeforeUpdate' = #True, as updating is deferred until WEM_btnOK_Click()
    Select \nSourceField
      Case #SCS_WEM_F_STARTAT
        bValidationResult = WQF_txtStartAt_Validate(#WEM, #False, #True)
      Case #SCS_WEM_F_LOOPSTART
        bValidationResult = WQF_txtLoopStart_Validate(#WEM, #False, #True)
      Case #SCS_WEM_F_LOOPEND
        bValidationResult = WQF_txtLoopEnd_Validate(#WEM, #False, #True)
      Case #SCS_WEM_F_ENDAT
        bValidationResult = WQF_txtEndAt_Validate(#WEM, #False, #True)
    EndSelect
    If bValidationResult
      \nReqdTime = stringToTime(GGT(WEM\txtValue))
      WEM_setButtons()
    EndIf
  EndWith
  
  debugMsg(sProcName, "bValidationResult=" + strB(bValidationResult))
  ProcedureReturn bValidationResult
EndProcedure

Procedure WEM_txtFadeValue_Validate()
  PROCNAMEC()
  Protected bValidationResult
  
  With grWEM
    ; call respective validation procedure with 'bReturnBeforeUpdate' = #True, as updating is deferred until WEM_btnOK_Click()
    Select \nSourceField
      Case #SCS_WEM_F_FADEINTIME
        bValidationResult = WQF_txtFadeInTime_Validate(#WEM, #True)
      Case #SCS_WEM_F_FADEOUTTIME
        bValidationResult = WQF_txtFadeOutTime_Validate(#WEM, #True)
      Case #SCS_WEM_I_FADEINTIME
        bValidationResult = WQI_txtFadeInTime_Validate(#WEM, #True)
      Case #SCS_WEM_I_FADEOUTTIME
        bValidationResult = WQI_txtFadeOutTime_Validate(#WEM, #True)
    EndSelect
    If bValidationResult
      \nReqdTime = stringToTime(GGT(WEM\txtFadeValue))
      WEM_setButtons()
    EndIf
  EndWith
  
  debugMsg(sProcName, "bValidationResult=" + strB(bValidationResult))
  ProcedureReturn bValidationResult
EndProcedure

Procedure WEM_applyTempoEtcFields()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  With grTempoEtc
    If aAud(nEditAudPtr)\nAudTempoEtcAction <> \nAudTempoEtcCurrAction Or aAud(nEditAudPtr)\fAudTempoEtcValue <> \fTempoEtcCurrValue
      u = preChangeAudL(1, GGT(WEM\lblTempoEtcValue))
      aAud(nEditAudPtr)\nAudTempoEtcAction = \nAudTempoEtcCurrAction
      aAud(nEditAudPtr)\fAudTempoEtcValue = \fTempoEtcCurrValue
      postChangeAudL(u, 2)
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudTempoEtcAction=" + decodeAFAction(aAud(nEditAudPtr)\nAudTempoEtcAction) + ", \fAudTempoEtcValue=" + aAud(nEditAudPtr)\fAudTempoEtcValue)
    EndIf
    Select \nAudTempoEtcCurrAction
      Case #SCS_AF_ACTION_FREQ, #SCS_AF_ACTION_TEMPO, #SCS_AF_ACTION_PITCH
        checkTempoEtcUsable()
    EndSelect
  EndWith
  
EndProcedure

Procedure WEM_btnOK_Click()
  PROCNAMEC()
  Protected u, u2, k, n
  Protected sScreens.s, nPrimaryOutputScreen
  Protected nPrevOutputScreen, nVidPicTarget
  Protected sMsg.s, nResponse
  Protected nDevNo, sLogicalDev.s, sFixtureCode.s, nOldDMXStartChannel, nNewDMXStartChannel, sOldDMXStartChannels.s, sNewDMXStartChannels.s
  Protected sCopyFromDevMapName.s, sCopyToDevMapName.s
  Protected nCopyFromDevMapPtr, nCopyToDevMapPtr
  Protected nCopyFromDevMapDevPtr, nCopyToDevMapDevPtr
  Protected bValidationResult
  Static sPreviewText.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sPreviewText = LangSpace("WQA", "chkPreviewOnOutputScreen")
    bStaticLoaded = #True
  EndIf
  
  bValidationResult = WEM_valGadget(GetActiveGadget())
  If bValidationResult = #False
    ProcedureReturn
  EndIf
  
  Select grWEM\nSourceField
    Case #SCS_WEM_LT_COPYFROM ; INFO: btnOK: #SCS_WEM_LT_COPYFROM
      sMsg = Lang("WEM", "CopyConfirm")
      nResponse = scsMessageRequester(GWT(#WEM), sMsg, #PB_MessageRequester_YesNoCancel)
      Select nResponse
        Case #PB_MessageRequester_Cancel
          debugMsg(sProcName, "cancel")
          ProcedureReturn
        Case #PB_MessageRequester_No
          debugMsg(sProcName, "no")
          ; no action - drop through to WEM_Form_Unload() etc
        Case #PB_MessageRequester_Yes
          debugMsg(sProcName, "yes")
          nDevNo = grWEP\nCurrentLightingDevNo
          sLogicalDev = grWEP\sCurrentLightingDevName
          sCopyFromDevMapName = GGT(WEM\cboDMXStartsDevMap)
          nCopyFromDevMapPtr = getDevMapPtr(@grMapsForDevChgs, sCopyFromDevMapName)
          nCopyFromDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev, nCopyFromDevMapPtr)
          sCopyToDevMapName = grProdForDevChgs\sSelectedDevMapName
          nCopyToDevMapPtr = getDevMapPtr(@grMapsForDevChgs, sCopyToDevMapName)
          nCopyToDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev, nCopyToDevMapPtr)
          debugMsg(sProcName, "sCopyFromDevMapName=" + sCopyFromDevMapName + ", nCopyFromDevMapPtr=" + nCopyFromDevMapPtr + ", nCopyFromDevMapDevPtr=" + nCopyFromDevMapDevPtr)
          debugMsg(sProcName, "sCopyToDevMapName=" + sCopyToDevMapName + ", nCopyToDevMapPtr=" + nCopyToDevMapPtr + ", nCopyToDevMapDevPtr=" + nCopyToDevMapDevPtr)
          With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
            debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nMaxFixture=" + \nMaxFixture)
            For n = 0 To \nMaxFixture
              sFixtureCode = Trim(\aFixture(n)\sFixtureCode)
              nOldDMXStartChannel = DMX_getFixtureDMXStartChannelForDevChgs(nCopyToDevMapDevPtr, sFixtureCode)
              nNewDMXStartChannel = DMX_getFixtureDMXStartChannelForDevChgs(nCopyFromDevMapDevPtr, sFixtureCode)
              If nNewDMXStartChannel <> nOldDMXStartChannel
                DMX_setFixtureDMXStartChannelForDevChgs(nCopyToDevMapDevPtr, sFixtureCode, nNewDMXStartChannel)
                grCED\bProdChanged = #True
              EndIf
              sOldDMXStartChannels = DMX_getFixtureDMXStartChannelsForDevChgs(nCopyToDevMapDevPtr, sFixtureCode)
              sNewDMXStartChannels = DMX_getFixtureDMXStartChannelsForDevChgs(nCopyFromDevMapDevPtr, sFixtureCode)
              If sNewDMXStartChannels <> sOldDMXStartChannels
                DMX_setFixtureDMXStartChannelsForDevChgs(nCopyToDevMapDevPtr, sFixtureCode, sNewDMXStartChannels)
                grCED\bProdChanged = #True
              EndIf
            Next n
            grCED\bProdChanged = #True
          EndWith
          debugMsg(sProcName, "calling WEP_displayFixtures(" + nDevNo + ")")
          WEP_displayFixtures(nDevNo)
          WEP_setDevChgsBtns()
      EndSelect
      
    Case #SCS_WEM_A_SCREENS ; INFO: btnOK: #SCS_WEM_A_SCREENS
      For n = 0 To grWEM\nCheckedScreenArraySize
        If grWEM\aCheckedScreen(n)
          If sScreens
            sScreens + ","
          EndIf
          sScreens + Str(n+2) ; output screen numbers start from 2
          If nPrimaryOutputScreen = 0
            nPrimaryOutputScreen = n + 2
          EndIf
        EndIf
      Next n
      If Len(sScreens) = 0
        sMsg = Lang("Errors", "AtLeast1Screen")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn
      EndIf
      With aSub(nEditSubPtr)
        If \sScreens <> sScreens
          u = preChangeSubS(\sScreens, grWEM\sLabel)
          \sScreens = sScreens
          If nPrimaryOutputScreen <> \nOutputScreen
            \nOutputScreen = nPrimaryOutputScreen
          EndIf
          debugMsg(sProcName, "calling loadArrayOutputScreenReqd(" + getSubLabel(nEditSubPtr) + ")")
          loadArrayOutputScreenReqd(nEditSubPtr)
          k = \nFirstAudIndex
          While k >= 0
            u2 = preChangeAudL(#True, grWEM\sLabel, k)
            setDerivedAudScreenInfoFields(k)
            postChangeAudL(u2, #False, k)
            k = aAud(k)\nNextAudIndex
          Wend
          postChangeSubS(u, \sScreens)
        EndIf
        SGT(WQA\lblScreens, \sScreens)
        If GadgetWidth(WQA\lblScreens, #PB_Gadget_RequiredSize) > GadgetWidth(WQA\lblScreens)
          SGT(WQA\lblScreens, RemoveString(\sScreens, ","))
        EndIf
        setOwnText(WQA\chkPreviewOnOutputScreen, sPreviewText + nPrimaryOutputScreen)
        nVidPicTarget = getVidPicTargetForOutputScreen(\nOutputScreen)
        WQA_setIncrements(nVidPicTarget)
        If gbPreviewOnOutputScreen
          If gnPreviewOnOutputScreenNo <> \nOutputScreen
            nPrevOutputScreen = gnPreviewOnOutputScreenNo
            gnPreviewOnOutputScreenNo = \nOutputScreen
            WQA_clearPreviewOnOutputScreen(nPrevOutputScreen)
          EndIf
          debugMsg(sProcName, "calling setVidPicTargets()")
          setVidPicTargets()
          SAW(#WED) ; added because throws back to main window after setVidPicTargets()
          debugMsg(sProcName, "calling WQA_drawPreviewImage2()")
          WQA_drawPreviewImage2()
        Else
          ; If IsGadget(grVidPicTarget(\nOutputScreen)\nTargetCanvasNo) = #False
            debugMsg(sProcName, "(b) calling setVidPicTargets()")
            setVidPicTargets()
            SAW(#WED) ; added because throws back to main window after setVidPicTargets()
          ; EndIf
        EndIf
      EndWith
      
    Case #SCS_WEM_F_FREQ_TEMPO_PITCH
      debugMsg(sProcName, "calling WEM_applyTempoEtcFields()")
      WEM_applyTempoEtcFields()
      
    Default ; not #SCS_WEM_LT_COPYFROM, #SCS_WEM_A_SCREENS, #SCS_WEM_F_TEMPO, #SCS_WEM_F_PITCH or #SCS_WEM_F_FREQ
      
      If nEditAudPtr < 0
        ; shouldn't happen
        ProcedureReturn
      EndIf
      
      With aAud(nEditAudPtr)
        
        Select grWEM\nSourceField
          Case #SCS_WEM_F_STARTAT   ; #SCS_WEM_F_STARTAT
            If grWEM\dReqdCPTimePos >= 0.0
              ; using a cue point
              If WQF_txtStartAt_Validate(#WEM, #True) = #False
                 ProcedureReturn
              EndIf
              SGT(WQF\txtStartAt, timeDblToStringHT(\dStartAtCPTime, \nFileDuration))
            Else
              ; not using a cue point
              If WQF_txtStartAt_Validate(#WEM, #False) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtStartAt, timeToStringBWZT(\nStartAt, \nFileDuration))
            EndIf
            
          Case #SCS_WEM_F_LOOPSTART   ; #SCS_WEM_F_LOOPSTART
            If grWEM\dReqdCPTimePos >= 0.0
              ; using a cue point
              If WQF_txtLoopStart_Validate(#WEM, #True) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtLoopStart, timeDblToStringHT(\aLoopInfo(grWEM\nLoopInfoIndex)\dLoopStartCPTime, \nFileDuration))
            Else
              ; not using a cue point
              If WQF_txtLoopStart_Validate(#WEM, #False) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtLoopStart, timeToStringBWZT(\aLoopInfo(grWEM\nLoopInfoIndex)\nLoopStart, \nFileDuration))
            EndIf
            
          Case #SCS_WEM_F_LOOPEND   ; #SCS_WEM_F_LOOPEND
            If grWEM\dReqdCPTimePos >= 0.0
              ; using a cue point
              If WQF_txtLoopEnd_Validate(#WEM, #True) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtLoopEnd, timeDblToStringHT(\aLoopInfo(grWEM\nLoopInfoIndex)\dLoopEndCPTime, \nFileDuration))
            Else
              ; not using a cue point
              If WQF_txtLoopEnd_Validate(#WEM, #False) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtLoopEnd, timeToStringBWZT(\aLoopInfo(grWEM\nLoopInfoIndex)\nLoopEnd, \nFileDuration))
            EndIf
            
          Case #SCS_WEM_F_ENDAT   ; #SCS_WEM_F_ENDAT
            If grWEM\dReqdCPTimePos >= 0.0
              ; using a cue point
              If WQF_txtEndAt_Validate(#WEM, #True) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtEndAt, timeDblToStringHT(\dEndAtCPTime, \nFileDuration))
            Else
              ; not using a cue point
              If WQF_txtEndAt_Validate(#WEM, #False) = #False
                ProcedureReturn
              EndIf
              SGT(WQF\txtEndAt, timeToStringBWZT(\nEndAt, \nFileDuration))
            EndIf
            
          Case #SCS_WEM_F_FADEINTIME  ; #SCS_WEM_F_FADEINTIME
            If WQF_txtFadeInTime_Validate(#WEM) = #False
              ProcedureReturn
            EndIf
            u = preChangeAudL(\nFadeInType, grWEM\sLabel)
            \nFadeInType = grWEM\nReqdFadeType
            postChangeAudL(u, \nFadeInType)
            SGT(WQF\txtFadeInTime, timeToStringBWZT(\nFadeInTime))
            ; fade type not displayed on WQF
            
          Case #SCS_WEM_F_FADEOUTTIME  ; #SCS_WEM_F_FADEOUTTIME
            If WQF_txtFadeOutTime_Validate(#WEM) = #False
              ProcedureReturn
            EndIf
            u = preChangeAudL(\nFadeOutType, grWEM\sLabel)
            \nFadeOutType = grWEM\nReqdFadeType
            postChangeAudL(u, \nFadeOutType)
            SGT(WQF\txtFadeOutTime, timeToStringBWZT(\nFadeOutTime))
            ; fade type not displayed on WQF
            
          Case #SCS_WEM_I_FADEINTIME  ; #SCS_WEM_I_FADEINTIME
            If WQI_txtFadeInTime_Validate(#WEM) = #False
              ProcedureReturn
            EndIf
            u = preChangeAudL(\nFadeInType, grWEM\sLabel)
            \nFadeInType = grWEM\nReqdFadeType
            postChangeAudL(u, \nFadeInType)
            SGT(WQI\txtFadeInTime, timeToStringBWZT(\nFadeInTime))
            ; fade type not displayed on WQI
            
          Case #SCS_WEM_I_FADEOUTTIME  ; #SCS_WEM_I_FADEOUTTIME
            If WQI_txtFadeOutTime_Validate(#WEM) = #False
              ProcedureReturn
            EndIf
            u = preChangeAudL(\nFadeOutType, grWEM\sLabel)
            \nFadeOutType = grWEM\nReqdFadeType
            postChangeAudL(u, \nFadeOutType)
            SGT(WQI\txtFadeOutTime, timeToStringBWZT(\nFadeOutTime))
            ; fade type not displayed on WQI
            
        EndSelect
        
        If grWEM\nSourceForm = #WQF
          debugMsg(sProcName, "calling WQF_refreshFileInfo()")
          WQF_refreshFileInfo()
          debugMsg(sProcName, "calling WQF_setTimeFieldEnabledStates()")
          WQF_setTimeFieldEnabledStates()
        EndIf
        
      EndWith
      
  EndSelect
  
  WEM_Form_Unload()
  SAW(#WED)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_displaySelection()
  PROCNAMEC()
  Protected nFileDuration
  
  If nEditAudPtr >= 0
    nFileDuration = aAud(nEditAudPtr)\nFileDuration
    
    If grWEM\nSelectedRow >= 0 And grWEM\dReqdCPTimePos >= 0.0
      SGT(WEM\txtValue, timeDblToStringHT(grWEM\dReqdCPTimePos, nFileDuration))
      setEnabled(WEM\txtValue, #False)
      SGT(WEM\lblCPName, grWEM\sReqdCPName)
    Else
      SGT(WEM\txtValue, timeToStringT(grWEM\nReqdTime, nFileDuration))
      setEnabled(WEM\txtValue, #True)
      SGT(WEM\lblCPName, "")
    EndIf
  EndIf
  
  WEM_setButtons()
  
  If grWEM\nSelectedRow >= 0
    SAG(WEM\grdCuePoints)   ; ensure selected row is clearly highlighted
  Else
    SAG(-1)
  EndIf
  
EndProcedure

Procedure WEM_displayFadeInfo()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grWEM
    SGT(WEM\txtFadeValue, timeToStringBWZT(\nReqdTime))
    setComboBoxByData(WEM\cboFadeType, \nReqdFadeType, 0)
  EndWith
  
  WEM_setButtons()
  
  SAG(-1)
  
EndProcedure

Procedure WEM_displayOutputScreenInfo()
  PROCNAMEC()
  Protected sScreens.s
  Protected n1, n2, nScreenNo, nScreenCount
  
  With grWEM
    sScreens = Trim(aSub(nEditSubPtr)\sScreens)
    If Len(sScreens) = 0
      sScreens = Str(aSub(nEditSubPtr)\nOutputScreen)
    EndIf
    If sScreens
      nScreenCount = CountString(sScreens, ",") + 1
    EndIf
    For n1 = 0 To \nCheckedScreenArraySize
      \aCheckedScreen(n1) = #False
    Next n1
    For n1 = 1 To nScreenCount
      nScreenNo = Val(StringField(sScreens, n1, ","))
      n2 = nScreenNo - 2
      If (n2 >= 0) And (n2 <= \nCheckedScreenArraySize)
        \aCheckedScreen(n2) = #True
      EndIf
    Next n1
    For n1 = 0 To \nCheckedScreenArraySize
      If IsGadget(WEM\chkOutputScreen[n1])
        SGS(WEM\chkOutputScreen[n1], \aCheckedScreen(n1))
      EndIf
    Next n1
  EndWith
  
EndProcedure

Procedure WEM_displayDMXStartsDetail(nDevMapPtr)
  PROCNAMEC()
  Protected n, nDevNo, nDevMapDevPtr
  Protected sFixtureCode.s, sFixture.s, nDMXStartChannel, sDMXStartChannel.s
  Protected sDevice.s
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + getDevMapName(nDevMapPtr))
  
  ClearGadgetItems(WEM\grdDMXStarts)
  nDevNo = grWEP\nCurrentLightingDevNo
  With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nDevMapPtr)
    If nDevMapDevPtr >= 0
      sDevice = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
      If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXPorts > 1
        sDevice + " " + LangSpace("Common", "Port") + grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXPort
      EndIf
      SGT(WEM\txtDMXDevice, sDevice)
      For n = 0 To \nMaxFixture
        sFixtureCode = Trim(\aFixture(n)\sFixtureCode)
        If sFixtureCode
          sFixture = sFixtureCode + " - " + \aFixture(n)\sFixtureDesc
          nDMXStartChannel = DMX_getFixtureDMXStartChannelForDevChgs(nDevMapDevPtr, sFixtureCode)
          If nDMXStartChannel > 0
            sDMXStartChannel = Str(nDMXStartChannel)
          Else
            sDMXStartChannel = ""
          EndIf
          AddGadgetItem(WEM\grdDMXStarts, -1, sFixture + Chr(10) + sDMXStartChannel)
        EndIf
      Next n
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_displayDMXStartsInfo()
  PROCNAMEC()
  Protected nDevMapPtr, sDevMapName.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWEM
    ClearGadgetItems(WEM\cboDMXStartsDevMap)
    For nDevMapPtr = 0 To grMapsForDevChgs\nMaxMapIndex
      sDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
      If sDevMapName <> grProdForDevChgs\sSelectedDevMapName
        addGadgetItemWithData(WEM\cboDMXStartsDevMap, sDevMapName, nDevMapPtr)
      EndIf
    Next nDevMapPtr
    If CountGadgetItems(WEM\cboDMXStartsDevMap) > 0
      SGS(WEM\cboDMXStartsDevMap, 0)
    EndIf
  EndWith
  
  nDevMapPtr = getCurrentItemData(WEM\cboDMXStartsDevMap)
  WEM_displayDMXStartsDetail(nDevMapPtr)
  
  WEM_setButtons()
  
  SAG(-1)
  
EndProcedure

Procedure WEM_displayCueMarkersUsage()
  PROCNAMEC()
  Protected n, i, j, nSubPtr
  Protected sName.s, sTime.s, sCueType.s, sFileName.s, sLine.s, sCue.s
  Protected bFound
  Protected Dim aMyCueMarker.tyCueMarker(10)
  
  debugMsg(sProcName, #SCS_START)
  
  ClearGadgetItems(WEM\grdCueMarkersUsage)
  CopyArray(aAud(nEditAudPtr)\aCueMarker(), aMyCueMarker())
  SortStructuredArray(aMyCueMarker(), #PB_Sort_Ascending, OffsetOf(tyCueMarker\nCueMarkerPosition), #PB_Integer)
  For n = 0 To aAud(nEditAudPtr)\nMaxCueMarker
    sName = aMyCueMarker(n)\sCueMarkerName
    sCue = aAud(nEditAudPtr)\sCue
    sTime = timeToString(aMyCueMarker(n)\nCueMarkerPosition)
    bFound = #False
    For i = 1 To gnLastCue
      With aCue(i)
        If \nActivationMethod = #SCS_ACMETH_OCM
          If (\sAutoActCue = sCue) And (\sAutoActCueMarkerName = sName)
            nSubPtr = \nFirstSubIndex
            If nSubPtr >= 0
              sCueType = decodeSubTypeL(aSub(nSubPtr)\sSubType, nSubPtr)
              sFileName = getSubFileNameForGrid(nSubPtr)
            Else
              sCueType = ""
              sFileName = ""
            EndIf
            If bFound = #False
              sLine = sName + Chr(10) + sTime + Chr(10) + \sCue + Chr(10) + sCueType + Chr(10) + sFileName
            Else
              sLine = Chr(10) + Chr(10) + \sCue + Chr(10) + sCueType + Chr(10) + sFileName
            EndIf
            AddGadgetItem(WEM\grdCueMarkersUsage, -1, sLine)
            bFound = #True
          EndIf
        EndIf
      EndWith
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \nSubStart = #SCS_SUBSTART_OCM
            If \sSubCueMarkerName = sName
              sCueType = decodeSubTypeL(\sSubType, j)
              sFileName = getSubFileNameForGrid(j)
              If bFound = #False
                sLine = sName + Chr(10) + sTime + Chr(10) + \sSubLabel + Chr(10) + sCueType + Chr(10) + sFileName
              Else
                sLine = Chr(10) + Chr(10) + \sCue + Chr(10) + \sSubLabel + Chr(10) + sFileName
              EndIf
              AddGadgetItem(WEM\grdCueMarkersUsage, -1, sLine)
              bFound = #True
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    Next i
    If bFound = #False
      sLine = sName + Chr(10) + sTime + Chr(10)
      AddGadgetItem(WEM\grdCueMarkersUsage, -1, sLine)
    EndIf
  Next n

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_checkForDuplicateCuePointNames(sFileName.s)
  PROCNAMEC()
  Protected n1, n2
  Protected sCuePointName.s
  Protected nDuplicateCount
  Protected sDuplicateNames.s
  Protected sMsg.s
  
  With grWEM
    
    For n1 = 1 To \nNrCheckedFiles
      If \aCheckedFile(n1) = sFileName
        ProcedureReturn
      EndIf
    Next n1
    
    For n1 = 0 To gnMaxCuePoint
      If gaCuePoint(n1)\sFileName = sFileName
        sCuePointName = gaCuePoint(n1)\sName
        For n2 = 0 To (n1 - 1)
          If gaCuePoint(n2)\sFileName = sFileName
            If gaCuePoint(n2)\sName = sCuePointName
              nDuplicateCount + 1
              If nDuplicateCount > 1
                sDuplicateNames + ", "
              EndIf
              sDuplicateNames + sCuePointName
            EndIf
          EndIf
        Next n2
      EndIf
    Next n1
    
    If nDuplicateCount > 0
      sMsg = LangPars("WEM", "DuplicateNames", Str(nDuplicateCount), GetFilePart(sFileName), sDuplicateNames)
      debugMsg(sProcName, "sFileName=" + GetFilePart(sFileName) + ", sMsg=" + sMsg)
      scsMessageRequester(GetFilePart(sFileName), sMsg, #MB_ICONWARNING)
    EndIf
    
    \nNrCheckedFiles + 1
    If ArraySize(\aCheckedFile()) < \nNrCheckedFiles
      ReDim \aCheckedFile(\nNrCheckedFiles + 10)
    EndIf
    \aCheckedFile(\nNrCheckedFiles) = sFileName
    
  EndWith
  
EndProcedure

Procedure WEM_setOkAndCancelButtons()
  PROCNAMEC()
  Protected bCancelVisible, nLeft, nWidth, nCntTop
  
  With grWEM
    Select \nSourceField
      Case #SCS_WEM_F_CUEMARKERSUSAGE
        bCancelVisible = #False
      Default
        bCancelVisible = #True
    EndSelect
    setVisible(WEM\btnCancel, bCancelVisible)
    nCntTop = WindowHeight(#WEM) - GadgetHeight(WEM\cntButtons) - 12
    ResizeGadget(WEM\cntButtons, 0, nCntTop, WindowWidth(#WEM), #PB_Ignore)
    If bCancelVisible
      nWidth = GadgetWidth(WEM\btnOK) + gnGap + GadgetWidth(WEM\btnCancel)
      nLeft = (GadgetWidth(WEM\cntButtons) - nWidth) >> 1
      ResizeGadget(WEM\btnOK, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLeft + GadgetWidth(WEM\btnOK) + gnGap
      ResizeGadget(WEM\btnCancel, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    Else
      nWidth = GadgetWidth(WEM\btnOK)
      nLeft = (GadgetWidth(WEM\cntButtons) - nWidth) >> 1
      ResizeGadget(WEM\btnOK, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
  EndWith
EndProcedure

Procedure WEM_Form_Show(bModal, nParentWindow, nSourceForm, nSourceField)
  PROCNAMEC()
  Protected i, p
  Protected sFileName.s
  Protected sPosition.s
  Protected nFileDuration
  Protected nRowNo
  Protected nCuePointCues
  Protected sMsg.s
  Protected nWindowX, nWindowY, nWindowWidth, nWindowHeight, bCreateWindow
  Protected nWindowMidPointX, nWindowMidPointY
  Protected nButtonsX, nButtonsY
  Protected nReqdLeft, nReqdWidth
  Protected nLeft, nWidth
  Protected nChangeCode
  Protected nCntWidth, nCntHeight
  
  debugMsg(sProcName, #SCS_START + ", bModal=" + strB(bModal))
  
  grWEM\nPrevActiveWindow = GetActiveWindow() ; Added 31Aug2021 11.8.6af
  
  If IsWindow(#WEM) = #False
    createfmEditModal(nParentWindow)
    grWEM\nDefaultWindowWidth = WindowWidth(#WEM)
    grWEM\nDefaultWindowHeight = WindowHeight(#WEM)
    setFormPosition(#WEM, @grEditModalWindow)
  EndIf
  setWindowModal(#WEM, bModal)
  
  With WEM
    setVisible(\cntCueMarkersUsage, #False)
    setVisible(\cntCuePoints, #False)
    setVisible(\cntDMXStarts, #False)
    setVisible(\cntFadeTime, #False)
    setVisible(\cntScreens, #False)
    setVisible(\cntTempoEtc, #False)
    setVisible(\btnCuePointsClearSelection, #False)
  EndWith
  
  With grWEM
    \sTitle = ""
    \nSourceForm = nSourceForm
    \nSourceField = nSourceField
    \bCntCueMarkersUsage = #False
    \bCntCuePoints = #False
    \bCntDMXStarts = #False
    \bCntFadeTime = #False
    \bCntScreens = #False
    \bCntTempoEtc = #False
    \bTxtChanged = #False
    \bAllowWindowResizeByUser = #False
    \nCheckedScreenArraySize = grLicInfo\nLastVideoWindowNo - #WV2
    If \nCheckedScreenArraySize >= 0
      ReDim \aCheckedScreen(\nCheckedScreenArraySize)
    EndIf
    
    nWindowWidth = grWEM\nDefaultWindowWidth
    nWindowHeight = grWEM\nDefaultWindowHeight
    
    \nHeightBelowMainContainer = GadgetHeight(WEM\cntButtons) + 24
    
    Select nSourceField
      Case #SCS_WEM_LT_COPYFROM
        \bCntDMXStarts = #True
        \sLabel = GGT(WEP\btnCopyDMXStartsFrom)
        nWindowWidth = GadgetWidth(WEM\cntDMXStarts)
        nWindowHeight = GadgetY(WEM\cntDMXStarts) + GadgetHeight(WEM\cntDMXStarts) + \nHeightBelowMainContainer
        
      Case #SCS_WEM_A_SCREENS
        \bCntScreens = #True
        \sLabel = GGT(WQA\btnScreens)
        nWindowWidth = 216
        nWindowHeight = 235
        
      Case #SCS_WEM_F_STARTAT
        \bCntCuePoints = #True ; indicates cntCuePoints to be displayed
        \sLabel = GGT(WQF\lblStartAt)
        \sOrigCPName = aAud(nEditAudPtr)\sStartAtCPName
        \qOrigSamplePos = aAud(nEditAudPtr)\qStartAtSamplePos
        \dOrigCPTimePos = aAud(nEditAudPtr)\dStartAtCPTime
        \nOrigTime = aAud(nEditAudPtr)\nStartAt
        
      Case #SCS_WEM_F_LOOPSTART
        \bCntCuePoints = #True
        \sLabel = GGT(WQF\lblLoopStart)
        \sOrigCPName = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\sLoopStartCPName
        \qOrigSamplePos = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\qLoopStartSamplePos
        \dOrigCPTimePos = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\dLoopStartCPTime
        \nOrigTime = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\nLoopStart
        
      Case #SCS_WEM_F_LOOPEND
        \bCntCuePoints = #True
        \sLabel = GGT(WQF\lblLoopEnd)
        \sOrigCPName = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\sLoopEndCPName
        \qOrigSamplePos = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\qLoopEndSamplePos
        \dOrigCPTimePos = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\dLoopEndCPTime
        \nOrigTime = aAud(nEditAudPtr)\aLoopInfo(grWEM\nLoopInfoIndex)\nLoopEnd
        
      Case #SCS_WEM_F_ENDAT
        \bCntCuePoints = #True
        \sLabel = GGT(WQF\lblEndAt)
        \sOrigCPName = aAud(nEditAudPtr)\sEndAtCPName
        \qOrigSamplePos = aAud(nEditAudPtr)\qEndAtSamplePos
        \dOrigCPTimePos = aAud(nEditAudPtr)\dEndAtCPTime
        \nOrigTime = aAud(nEditAudPtr)\nEndAt
        
      Case #SCS_WEM_F_FADEINTIME
        \bCntFadeTime = #True
        \sTitle = GGT(WQF\lblFadeInTime)
        \sLabel = Lang("WEM", "FadeInTime") ; GGT(WQF\lblFadeInTime) ; Changed 25Jan2023 11.9.9ac because WQF\lblFadeInTime now contains "Type" as well as "Time", ie "Fade In Time/Type"
        buildEditCBO(WEM\cboFadeType, "FadeIn")
        \nOrigTime = aAud(nEditAudPtr)\nFadeInTime
        \nOrigFadeType = aAud(nEditAudPtr)\nFadeInType
        \nDefFadeTime = grProd\nDefFadeInTime
        \nDefFadeType = #SCS_FADE_STD
        nWindowWidth = GadgetWidth(WEM\cntFadeTime)
        nWindowHeight = GadgetY(WEM\cntFadeTime) + GadgetHeight(WEM\cntFadeTime) + \nHeightBelowMainContainer
        
      Case #SCS_WEM_F_FADEOUTTIME
        \bCntFadeTime = #True
        \sTitle = GGT(WQF\lblFadeOutTime)
        \sLabel = Lang("WEM", "FadeOutTime") ; GGT(WQF\lblFadeOutTime) ; Changed 25Jan2023 11.9.9ac because WQF\lblFadeOutTime now contains "Type" as well as "Time", ie "Fade Out Time/Type"
        buildEditCBO(WEM\cboFadeType, "FadeOut")
        \nOrigTime = aAud(nEditAudPtr)\nFadeOutTime
        \nOrigFadeType = aAud(nEditAudPtr)\nFadeOutType
        \nDefFadeTime = grProd\nDefFadeOutTime
        \nDefFadeType = #SCS_FADE_STD
        nWindowWidth = GadgetWidth(WEM\cntFadeTime)
        nWindowHeight = GadgetY(WEM\cntFadeTime) + GadgetHeight(WEM\cntFadeTime) + \nHeightBelowMainContainer
        
      Case #SCS_WEM_F_CUEMARKERSUSAGE
        \bCntCueMarkersUsage = #True
        \sLabel = Lang("Menu", "mnuWQFViewCueMarkersUsage") + " (" + getAudLabel(nEditAudPtr) +")"
        \bAllowWindowResizeByUser = #True ; user may resize this window - hence the following
        If \sCntCueMarkersUsageDim
          nCntWidth = Val(StringField(\sCntCueMarkersUsageDim, 1, ","))
          nCntHeight = Val(StringField(\sCntCueMarkersUsageDim, 2, ","))
          ; debugMsg0(sProcName, "\sCntCueMarkersUsageDim=" + #DQUOTE$ + \sCntCueMarkersUsageDim + #DQUOTE$ + ", nCntWidth=" + nCntWidth + ", nCntHeight=" + nCntHeight)
          If nCntWidth > 0 And nCntHeight > 0
            ResizeGadget(WEM\cntCueMarkersUsage, #PB_Ignore, #PB_Ignore, nCntWidth, nCntHeight)
          EndIf
        EndIf
        nWindowWidth = GadgetWidth(WEM\cntCueMarkersUsage)
        nWindowHeight = GadgetY(WEM\cntCueMarkersUsage) + GadgetHeight(WEM\cntCueMarkersUsage) + \nHeightBelowMainContainer
        
      Case #SCS_WEM_F_FREQ_TEMPO_PITCH
        \bCntTempoEtc = #True
        \sLabel = Lang("Menu", "mnuWQFChangeFreqTempoPitch")
        WEM_populateCboTempEtcAction()
        grTempoEtc\nAudTempoEtcCurrAction = aAud(nEditAudPtr)\nAudTempoEtcAction
        grTempoEtc\nTempoEtcCurrChangeCode = getChangeCodeForAFAction(grTempoEtc\nAudTempoEtcCurrAction)
        grTempoEtc\fTempoEtcOrigValue = aAud(nEditAudPtr)\fAudTempoEtcValue
        grTempoEtc\fTempoEtcCurrValue = grTempoEtc\fTempoEtcOrigValue
        setGadgetItemByData(WEM\cboTempoEtcAction, grTempoEtc\nAudTempoEtcCurrAction, 0)
        WEM_setTempoEtcFields()
        nWindowWidth = GadgetWidth(WEM\cntTempoEtc)
        nWindowHeight = GadgetY(WEM\cntTempoEtc) + GadgetHeight(WEM\cntTempoEtc) + \nHeightBelowMainContainer
        
      Case #SCS_WEM_I_FADEINTIME
        \bCntFadeTime = #True
        \sTitle = GGT(WQI\lblFadeInTime)
        \sLabel = Lang("WEM", "FadeInTime") ; GGT(WQI\lblFadeInTime) ; Changed 25Jan2023 11.9.9ac because WQI\lblFadeInTime now contains "Type" as well as "Time", ie "Fade In Time/Type"
        buildEditCBO(WEM\cboFadeType, "FadeIn")
        \nOrigTime = aAud(nEditAudPtr)\nFadeInTime
        \nOrigFadeType = aAud(nEditAudPtr)\nFadeInType
        \nDefFadeTime = grProd\nDefFadeInTime
        \nDefFadeType = #SCS_FADE_STD
        ; Added 25Jan2023 11.9.9ac
        nWindowWidth = GadgetWidth(WEM\cntFadeTime)
        nWindowHeight = GadgetY(WEM\cntFadeTime) + GadgetHeight(WEM\cntFadeTime) + \nHeightBelowMainContainer
        ; End added 25Jan2023 11.9.9ac
        
      Case #SCS_WEM_I_FADEOUTTIME
        \bCntFadeTime = #True
        \sTitle = GGT(WQI\lblFadeOutTime)
        \sLabel = Lang("WEM", "FadeOutTime") ; GGT(WQI\lblFadeOutTime) ; Changed 25Jan2023 11.9.9ac because WQI\lblFadeOutTime now contains "Type" as well as "Time", ie "Fade Out Time/Type"
        buildEditCBO(WEM\cboFadeType, "FadeOut")
        \nOrigTime = aAud(nEditAudPtr)\nFadeOutTime
        \nOrigFadeType = aAud(nEditAudPtr)\nFadeOutType
        \nDefFadeTime = grProd\nDefFadeOutTime
        \nDefFadeType = #SCS_FADE_STD
        ; Added 25Jan2023 11.9.9ac
        nWindowWidth = GadgetWidth(WEM\cntFadeTime)
        nWindowHeight = GadgetY(WEM\cntFadeTime) + GadgetHeight(WEM\cntFadeTime) + \nHeightBelowMainContainer
        ; End added 25Jan2023 11.9.9ac
        
    EndSelect
    
    nWindowMidPointX = WindowX(nParentWindow) + (WindowWidth(nParentWindow) >> 1)
    nWindowMidPointY = WindowY(nParentWindow) + (WindowHeight(nParentWindow) >> 1)
    nWindowX = nWindowMidPointX - (nWindowWidth >> 1)
    If nWindowX < 0
      nWindowX = 0
    EndIf
    nWindowY = nWindowMidPointY - (nWindowHeight >> 1)
    If nWindowY < 0
      nWindowY = 0
    EndIf
    ; debugMsg0(sProcName, "calling ResizeWindow(#WEM, " + nWindowX + ", " + nWindowY + ", " + nWindowWidth + ", " + nWindowHeight + ")")
    ResizeWindow(#WEM, nWindowX, nWindowY, nWindowWidth, nWindowHeight)
    \nCurrWindowWidth = nWindowWidth
    \nCurrWindowHeight = nWindowHeight
    nButtonsX = (nWindowWidth - GadgetWidth(WEM\cntButtons)) >> 1
    nButtonsY = nWindowHeight - GadgetHeight(WEM\cntButtons) - 12
    ResizeGadget(WEM\cntButtons, nButtonsX, nButtonsY, #PB_Ignore, #PB_Ignore)
    
    \sLabel = Trim(ReplaceString(\sLabel, Chr(10), " "))
    ; Added 25Jan2023 11.9.9ac
    If Len(\sTitle) = 0
      \sTitle = \sLabel
    Else
      \sTitle = Trim(ReplaceString(\sTitle, Chr(10), " "))
    EndIf
    ; End added 25Jan2023 11.9.9ac
    
    If \bCntDMXStarts
      nReqdWidth = WindowWidth(#WEM) - (GadgetX(WEM\cntDMXStarts) * 2)
      ResizeGadget(WEM\cntDMXStarts, #PB_Ignore, #PB_Ignore, nReqdWidth, #PB_Ignore)
      SetWindowTitle(#WEM, \sTitle)
      WEM_displayDMXStartsInfo()
      setVisible(WEM\cntDMXStarts, #True)
    EndIf
    
    If \bCntScreens
      nReqdWidth = WindowWidth(#WEM) - (GadgetX(WEM\cntScreens) * 2)
      ResizeGadget(WEM\cntScreens, #PB_Ignore, #PB_Ignore, nReqdWidth, #PB_Ignore)
      SGT(WEM\lblField, \sLabel)
      SetWindowTitle(#WEM, \sTitle)
      SGT(WEM\lblScreens, LangPars("WEM", "lblScreens", getSubLabel(nEditSubPtr)))
      nReqdWidth = GadgetWidth(WEM\lblScreens, #PB_Gadget_RequiredSize)
      nReqdLeft = (GadgetWidth(WEM\cntScreens) - nReqdWidth) >> 1
      ResizeGadget(WEM\lblScreens, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
      WEM_displayOutputScreenInfo()
      setVisible(WEM\cntScreens, #True)
    EndIf
    
    If \bCntCuePoints
      ; cntCuePoints to be used
      \bMaxCuePointCuesReached = #False ; initially set this #False as it is used in WEM_setButtons()
      \nFirstCPIndex = -1
      \nLastCPIndex = -1
      \nSelectedRow = -1
      \sReqdCPName = \sOrigCPName
      \qReqdSamplePos = \qOrigSamplePos
      \dReqdCPTimePos = \dOrigCPTimePos
      \nReqdTime = \nOrigTime
      
      SGT(WEM\lblField, \sLabel)
      SetWindowTitle(#WEM, \sTitle)
      SGT(WEM\btnCuePointsClear, Lang("Btns","Clear") + " '" + \sLabel + "'")
      setVisible(WEM\btnCuePointsClearSelection, #True)
      
      ClearGadgetItems(WEM\grdCuePoints)
      nRowNo = -1
      If nEditAudPtr >= 0
        sFileName = aAud(nEditAudPtr)\sFileName
        nFileDuration = aAud(nEditAudPtr)\nFileDuration
        debugMsg(sProcName, "sFileName=" + sFileName)
        For p = 0 To gnMaxCuePoint
          debugMsg(sProcName, "gaCuePoint(" + p + ")\sFileName=" + gaCuePoint(p)\sFileName)
          If gaCuePoint(p)\sFileName = sFileName
            nRowNo + 1
            gaCuePoint(p)\nRowNo = nRowNo
            sPosition = timeDblToStringHT(gaCuePoint(p)\dTimePos, nFileDuration)
            debugMsg(sProcName, "gaCuePoint(" + p + ")\dTimePos=" + StrD(gaCuePoint(p)\dTimePos,5) + ", sPosition=" + sPosition + ", sName=" + gaCuePoint(p)\sName)
            addGadgetItemWithData(WEM\grdCuePoints, Str(nRowNo+1) + Chr(10) + sPosition + Chr(10) + gaCuePoint(p)\sName, p)
            If gaCuePoint(p)\sName = \sReqdCPName
              If \nSelectedRow = -1
                \nSelectedRow = nRowNo
              EndIf
            EndIf
            If \nFirstCPIndex = -1
              \nFirstCPIndex = p
            EndIf
            \nLastCPIndex = p
          EndIf
        Next p
      EndIf
      If \nSelectedRow >= 0
        SGS(WEM\grdCuePoints, \nSelectedRow)
      EndIf
      \nOrigSelectedRow = \nSelectedRow
      
      WEM_displaySelection()
      
      setVisible(WEM\cntCuePoints, #True)
      
    EndIf ; EndIf \bCntCuePoints
    
    If \bCntCueMarkersUsage
      nReqdWidth = WindowWidth(#WEM) - (GadgetX(WEM\cntCueMarkersUsage) * 2)
      ResizeGadget(WEM\cntCueMarkersUsage, #PB_Ignore, #PB_Ignore, nReqdWidth, #PB_Ignore)
      SetWindowTitle(#WEM, \sTitle)
      WEM_displayCueMarkersUsage()
      setVisible(WEM\cntCueMarkersUsage, #True)
    EndIf ; EndIf \bCntCueMarkersUsage
    
    If \bCntFadeTime
      \nReqdTime = \nOrigTime
      \nReqdFadeType = \nOrigFadeType
      SGT(WEM\lblFadeField, \sLabel)
      SetWindowTitle(#WEM, \sTitle)
      SGT(WEM\btnCuePointsClear, Lang("Btns","Clear"))
      Select nSourceField
        Case #SCS_WEM_F_FADEINTIME, #SCS_WEM_I_FADEINTIME
          SGT(WEM\lblFadeType, Lang("WEM", "FadeInType"))
          scsToolTip(WEM\cboFadeType, Lang("WEM", "cboFadeInTypeTT"))
        Case #SCS_WEM_F_FADEOUTTIME, #SCS_WEM_I_FADEOUTTIME
          SGT(WEM\lblFadeType, Lang("WEM", "FadeOutType"))
          scsToolTip(WEM\cboFadeType, Lang("WEM", "cboFadeOutTypeTT"))
      EndSelect
      WEM_displayFadeInfo()
      setVisible(WEM\cntFadeTime, #True)
    EndIf ; EndIf \bCntFadeTime
    
    If \bCntTempoEtc
      SetWindowTitle(#WEM, \sTitle)
      setVisible(WEM\cntTempoEtc, #True)
    EndIf
    
    WEM_setOkAndCancelButtons()
    
    setWindowVisible(#WEM, #True)
    
    If sFileName
      WEM_checkForDuplicateCuePointNames(sFileName)
    EndIf
    
    If \bMaxCuePointCuesReached
      Delay(500)
      scsMessageRequester(\sLabel, sMsg, #MB_ICONEXCLAMATION)
    EndIf
    
    SAW(#WEM)
    SAG(-1)
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_grdCuePoints_Change()
  PROCNAMEC()
  Protected sFileName.s
  Protected p
  
  debugMsg(sProcName, #SCS_START)

  grWEM\nSelectedRow = GetGadgetState(WEM\grdCuePoints)
  
  If nEditAudPtr >= 0
    sFileName = aAud(nEditAudPtr)\sFileName
    If sFileName
      For p = grWEM\nFirstCPIndex To grWEM\nLastCPIndex
        If gaCuePoint(p)\sFileName = sFileName
          If gaCuePoint(p)\nRowNo = grWEM\nSelectedRow
            grWEM\sReqdCPName = gaCuePoint(p)\sName
            grWEM\qReqdSamplePos = gaCuePoint(p)\qSamplePos
            grWEM\dReqdCPTimePos = gaCuePoint(p)\dTimePos
          EndIf
        EndIf
      Next p
      
    EndIf
  EndIf
  
  WEM_displaySelection()
  
EndProcedure

Procedure WEM_btnReset_Click()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWEM
    If \bCntCuePoints
      \sReqdCPName = \sOrigCPName
      \qReqdSamplePos = \qOrigSamplePos
      \dReqdCPTimePos = \dOrigCPTimePos
      \nReqdTime = \nOrigTime
      \nSelectedRow = \nOrigSelectedRow
      SGS(WEM\grdCuePoints, \nSelectedRow)
      \bTxtChanged = #False
      WEM_displaySelection()
      
    ElseIf \bCntFadeTime
      \nReqdTime = \nOrigTime
      \nReqdFadeType = \nOrigFadeType
      \bTxtChanged = #False
      WEM_displayFadeInfo()
      
    EndIf
  EndWith
  
EndProcedure

Procedure WEM_btnClear_Click()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWEM
    If \bCntCuePoints
      \sReqdCPName = ""
      \qReqdSamplePos = -2
      \dReqdCPTimePos = -2.0
      \nReqdTime = -2
      \nSelectedRow = -1
      SGS(WEM\grdCuePoints, \nSelectedRow)
      \bTxtChanged = #False
      WEM_displaySelection()
      
    ElseIf \bCntFadeTime
      \nReqdTime = -2
      \nReqdFadeType = #SCS_FADE_STD
      \bTxtChanged = #False
      WEM_displayFadeInfo()
      
    EndIf
  EndWith
  
EndProcedure

Procedure WEM_btnUseDefaults_Click()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWEM
    If \bCntFadeTime
      \nReqdTime = \nDefFadeTime
      \nReqdFadeType = \nDefFadeType
      \bTxtChanged = #False
      WEM_displayFadeInfo()
      
    EndIf
  EndWith
  
EndProcedure

Procedure WEM_btnClearSelection_Click()
  PROCNAMEC()
  
  With grWEM
    If \bCntCuePoints
      \sReqdCPName = ""
      \qReqdSamplePos = -2
      \dReqdCPTimePos = -2.0
      \nSelectedRow = -1
      SGS(WEM\grdCuePoints, \nSelectedRow)
      WEM_displaySelection()
    EndIf
  EndWith
  
EndProcedure

Procedure WEM_btnTempoEtcReset_Click()
  WEM_setTempoEtcFields(#True)
  WEM_setButtons()
EndProcedure

Procedure WEM_cboFadeType_Click()
  grWEM\nReqdFadeType = getCurrentItemData(WEM\cboFadeType, #SCS_FADE_STD)
  WEM_setButtons()
EndProcedure

Procedure WEM_cboDMXStartsDevMap_Click()
  Protected nDevMapPtr
  
  grWEM\sReqdDevMapName = GGT(WEM\cboDMXStartsDevMap)
  nDevMapPtr = getCurrentItemData(WEM\cboDMXStartsDevMap)
  WEM_displayDMXStartsDetail(nDevMapPtr)
  
  WEM_setButtons()
  
EndProcedure

Procedure WEM_chkOutputScreen_Click(nIndex)
  grWEM\aCheckedScreen(nIndex) = GGS(WEM\chkOutputScreen[nIndex])
EndProcedure

Procedure WEM_sldTempoEtcValue_Common()
  PROCNAMEC()
  With grTempoEtc
    \fTempoEtcCurrValue = SLD_getValue(WEM\sldTempoEtcValue) / \fTempoEtcFactor
    debugMsg(sProcName, "SLD_getValue(WEM\sldTempoEtcValue=" + SLD_getValue(WEM\sldTempoEtcValue) + ", \fTempoEtcFactor=" + StrF(\fTempoEtcFactor,3) + ", \fTempoEtcCurrValue=" + StrF(\fTempoEtcCurrValue,3))
  EndWith
  WEM_setTxtTempoEtcValue()
EndProcedure

Procedure WEM_txtTempoEtcValue_Validate()
  PROCNAMEC()
  Protected sNewTempoEtcValue.s, fNewTempoEtcValue.f, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START + ", GGT(WEM\txtTempoEtcValue)=" + GGT(WEM\txtTempoEtcValue))
  
  With grTempoEtc
    sNewTempoEtcValue = Trim(GGT(WEM\txtTempoEtcValue))
    If sNewTempoEtcValue
      If validateNumberField(sNewTempoEtcValue)
        fNewTempoEtcValue = ValF(sNewTempoEtcValue)
        If fNewTempoEtcValue < \fTempoEtcMinValue Or fNewTempoEtcValue > \fTempoEtcMaxValue
          sErrorMsg = LangPars("Errors", "MustBeBetween", GGT(WEM\lblTempoEtcValue), StrF(\fTempoEtcMinValue, \nTempoEtcDecimals), StrF(\fTempoEtcMaxValue, \nTempoEtcDecimals))
        EndIf
      Else
        sErrorMsg = LangPars("Errors", "MustBeBetween", GGT(WEM\lblTempoEtcValue), StrF(\fTempoEtcMinValue, \nTempoEtcDecimals), StrF(\fTempoEtcMaxValue, \nTempoEtcDecimals))
      EndIf
    Else
      sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEM\lblTempoEtcValue))
    EndIf
    
    If sErrorMsg
      debugMsg(sProcName, "sErrorMgs=" + sErrorMsg)
      scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    Else
      \fTempoEtcCurrValue = fNewTempoEtcValue
      debugMsg(sProcName, "\fTempoEtcCurrValue=" + StrF(\fTempoEtcCurrValue,3))
      WEM_setTxtTempoEtcValue()
      WEM_setSldTempoEtcValue()
      ProcedureReturn #True
    EndIf
  EndWith
EndProcedure

Procedure WEM_setSldTempoEtcValue()
  PROCNAMEC()
  Protected fSldValue.f
  
  With grTempoEtc
    debugMsg(sProcName, "\fTempoEtcCurrValue=" + StrF(\fTempoEtcCurrValue,3) + ", \fTempoEtcFactor=" + StrF(\fTempoEtcFactor,3) + ", fSldValue=" + StrF(fSldValue,3))
    fSldValue = \fTempoEtcCurrValue * \fTempoEtcFactor
    SLD_setValue(WEM\sldTempoEtcValue, fSldValue, #True)
    WEM_setButtons()
  EndWith
EndProcedure

Procedure WEM_setTxtTempoEtcValue()
  PROCNAMEC()
  Protected sNewTempoEtcValue.s
  
  With grTempoEtc
    sNewTempoEtcValue = StrF(\fTempoEtcCurrValue, \nTempoEtcDecimals)
    If \nAudTempoEtcCurrAction = #SCS_AF_ACTION_PITCH
      If \fTempoEtcCurrValue > 0.0
        sNewTempoEtcValue = "+" + sNewTempoEtcValue
      EndIf
    EndIf
    SGT(WEM\txtTempoEtcValue, sNewTempoEtcValue)
  EndWith
  WEM_setButtons()
EndProcedure

Procedure WEM_cboTempoEtcAction_Click()
  
  grTempoEtc\nAudTempoEtcCurrAction = getCurrentItemData(WEM\cboTempoEtcAction)
  WEM_setTempoEtcFields(#True)
  
EndProcedure

Procedure WEM_setTempoEtcFields(bForceDefault=#False)
  PROCNAMEC()
  Protected nLength, nMaxAvailableLength, bEnabled
  Static sTempo.s, sPitch.s, sFreq.s, sTempoInfo.s, sPitchInfo.s, sFreqInfo.s, sBtnTempoEtcReset.s, bStaticLoaded
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sFreq = Lang("WQL", "Freq")
    sTempo = Lang("WQL", "Tempo")
    sPitch = Lang("WQL", "Pitch")
    sFreqInfo = Lang("WQL", "FreqInfo")
    sTempoInfo = Lang("WQL", "TempoInfo")
    sPitchInfo = Lang("WQL", "PitchInfo")
    sBtnTempoEtcReset = Lang("Btns","btnTempoEtcReset")
    nLength = getMaxTextWidth(100, sTempoInfo, sPitchInfo, sFreqInfo)
    nMaxAvailableLength = GadgetWidth(WEM\cntTempoEtc) - GadgetX(WEM\lblTempoEtcInfo) - 4
    If nLength > nMaxAvailableLength
      nLength = nMaxAvailableLength
    EndIf
    ResizeGadget(WEM\lblTempoEtcInfo, #PB_Ignore, #PB_Ignore, nLength, #PB_Ignore)
    bStaticLoaded = #True
  EndIf
  
  With grTempoEtc
    \nTempoEtcCurrChangeCode = getChangeCodeForAFAction(\nAudTempoEtcCurrAction)
    setTempoEtcConstants(\nTempoEtcCurrChangeCode)
    If bForceDefault Or \nTempoEtcCurrChangeCode = #SCS_CHANGE_NONE
      \fTempoEtcCurrValue = \fTempoEtcDefaultValue
      \nTempoEtcCurrSliderValue = \nTempoEtcDefaultSliderValue
    Else
      \nTempoEtcCurrSliderValue = \fTempoEtcCurrValue * \fTempoEtcFactor
    EndIf
    
    Select \nTempoEtcCurrChangeCode
      Case #SCS_CHANGE_NONE
        debugMsg(sProcName, "#SCS_CHANGE_NONE")
        SGT(WEM\lblTempoEtcValue, "")
        SGT(WEM\lblTempoEtcInfo, "")
        ; display #SCS_CHANGE_NONE similarly to a #SCS_CHANGE_FREQ, as the fields themselves are not relevant and will be disabled (better to display disabled rather than to hide completely)
        SLD_setSliderType(WEM\sldTempoEtcValue, #SCS_ST_FREQ)
        SGT(WEM\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "100%"))
        bEnabled = #False
        
      Case #SCS_CHANGE_FREQ
        debugMsg(sProcName, "#SCS_CHANGE_FREQ")
        SGT(WEM\lblTempoEtcValue, sFreq)
        SGT(WEM\lblTempoEtcInfo, sFreqInfo)
        SLD_setSliderType(WEM\sldTempoEtcValue, #SCS_ST_FREQ)
        SGT(WEM\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "100%"))
        bEnabled = #True
        
      Case #SCS_CHANGE_TEMPO
        debugMsg(sProcName, "#SCS_CHANGE_TEMPO")
        SGT(WEM\lblTempoEtcValue, sTempo)
        SGT(WEM\lblTempoEtcInfo, sTempoInfo)
        SLD_setSliderType(WEM\sldTempoEtcValue, #SCS_ST_TEMPO)
        SGT(WEM\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "100%"))
        bEnabled = #True
        
      Case #SCS_CHANGE_PITCH
        debugMsg(sProcName, "#SCS_CHANGE_PITCH")
        SGT(WEM\lblTempoEtcValue, sPitch)
        SGT(WEM\lblTempoEtcInfo, sPitchInfo)
        SLD_setSliderType(WEM\sldTempoEtcValue, #SCS_ST_PITCH)
        SGT(WEM\btnTempoEtcReset, ReplaceString(sBtnTempoEtcReset, "$1", "0"))
        bEnabled = #True
        
    EndSelect
  
    SLD_setMin(WEM\sldTempoEtcValue, \fTempoEtcMinValue * \fTempoEtcFactor)
    SLD_setMax(WEM\sldTempoEtcValue, \fTempoEtcMaxValue * \fTempoEtcFactor)
    If \nTempoEtcCurrSliderValue < SLD_getMin(WEM\sldTempoEtcValue) Or \nTempoEtcCurrSliderValue > SLD_getMax(WEM\sldTempoEtcValue)
      \nTempoEtcCurrSliderValue = \nTempoEtcDefaultSliderValue
    EndIf
    ; nb SLD_setValue() must be called AFTER calling SLD_setSliderType() as this is used in SLD_drawTickLines()
    ; debugMsg(sProcName, "calling SLD_setValue(WEM\sldTempoEtcValue, " + \nTempoEtcCurrSliderValue + ")")
    SLD_setValue(WEM\sldTempoEtcValue, \nTempoEtcCurrSliderValue)
    SGT(WEM\txtTempoEtcValue, StrF(\nTempoEtcCurrSliderValue / \fTempoEtcFactor, \nTempoEtcDecimals))
    
    SLD_setEnabled(WEM\sldTempoEtcValue, bEnabled)
    setEnabled(WEM\txtTempoEtcValue, bEnabled)
    
    If \fTempoEtcCurrValue <> \fTempoEtcDefaultValue
      setEnabled(WEM\btnTempoEtcReset, #True)
    Else
      setEnabled(WEM\btnTempoEtcReset, #False)
    EndIf
    
    If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
      Select \nTempoEtcCurrChangeCode
        Case #SCS_CHANGE_TEMPO, #SCS_CHANGE_PITCH
          checkUsingPlaybackRateChangeOnly(#True)
      EndSelect
    EndIf

  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEM_sizeWindow()
  PROCNAMEC()
  Protected nCntWidth, nCntHeight
  
  With grWEM
    If \bAllowWindowResizeByUser = #False
      If WindowWidth(#WEM) <> \nCurrWindowWidth Or WindowHeight(#WEM) <> \nCurrWindowHeight
        ResizeWindow(#WEM, #PB_Ignore, #PB_Ignore, \nCurrWindowWidth, \nCurrWindowHeight)
      EndIf
    Else
      Select \nSourceField
        Case #SCS_WEM_F_CUEMARKERSUSAGE
          \nCurrWindowWidth = WindowWidth(#WEM)
          \nCurrWindowHeight = WindowHeight(#WEM)
          nCntWidth = \nCurrWindowWidth
          nCntHeight = \nCurrWindowHeight - GadgetY(WEM\cntCueMarkersUsage) - \nHeightBelowMainContainer
          If nCntWidth > 0 And nCntHeight > 0
            ResizeGadget(WEM\cntCueMarkersUsage, #PB_Ignore, #PB_Ignore, nCntWidth, nCntHeight)
            ResizeGadget(WEM\grdCueMarkersUsage, #PB_Ignore, #PB_Ignore, nCntWidth, nCntHeight)
            \sCntCueMarkersUsageDim = Str(nCntWidth) + "," + Str(nCntHeight)
            autoFitGridCol(WEM\grdCueMarkersUsage, 4) ; autofit "File Info" column
          EndIf
      EndSelect
      WEM_setOkAndCancelButtons()
    EndIf
  EndWith
  
EndProcedure

Procedure WEM_EventHandler()
  PROCNAMEC()
  Protected bFound
  
  ; debugMsg0(sProcName, "gnWindowEvent=" + gnWindowEvent + ", gnEventSliderNo=" + gnEventSliderNo)
  
  With WEM
    If gnEventSliderNo > 0
      Select gnEventSliderNo
        Case \sldTempoEtcValue
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WEM_sldTempoEtcValue_Common()
          EndSelect
      EndSelect
      If bFound
        ProcedureReturn
      EndIf
    EndIf ; EndIf gnEventSliderNo > 0
    
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WEM_closeWindow()
        ; WEM_Form_Unload()
        
      Case #PB_Event_SizeWindow
        WEM_sizeWindow()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn   ; Return
            WEM_btnOK_Click()
          Case #SCS_mnuKeyboardEscape   ; Escape
            WEM_closeWindow()
            ; WEM_Form_Unload()
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnCancel ; btnCancel
            WEM_Form_Unload()
            
          Case \btnCuePointsClear, \btnFadeClear ; btnCuePointsClear, btnFadeClear
            WEM_btnClear_Click()
            
          Case \btnCuePointsClearSelection ; btnClearSelection
            WEM_btnClearSelection_Click()
            
          Case \btnCuePointsReset, \btnFadeReset ; btnCuePointsReset, btnFadeReset
            WEM_btnReset_Click()
            
          Case \btnOK ; btnOK
            WEM_btnOK_Click()
            
          Case \btnTempoEtcReset ; btnTempoEtcReset
            WEM_btnTempoEtcReset_Click()
            
          Case \btnUseDefaults ; btnUseDefaults
            WEM_btnUseDefaults_Click()
            
          Case \cboDMXStartsDevMap ; cboDMXStartsDevMap
            CBOCHG(WEM_cboDMXStartsDevMap_Click())
            
          Case \cboFadeType ; cboFadeType
            CBOCHG(WEM_cboFadeType_Click())
            
          Case \cboTempoEtcAction ; cboTempoEtcAction
            CBOCHG(WEM_cboTempoEtcAction_Click())
            
          Case \chkOutputScreen[0] ; chkOutputScreen[]
            CHKOWNCHG(WEM_chkOutputScreen_Click(gnEventGadgetArrayIndex))
            
          Case \cntButtons, \cntCueMarkersUsage, \cntCuePoints, \cntDMXStarts, \cntFadeTime, \cntScreens, \cntTempoEtc
            ; no action
            
          Case \grdCueMarkersUsage ; grdCueMarkersUsage
            ; no action
            
          Case \grdCuePoints  ; grdCuePoints
            If gnEventType = #PB_EventType_Change
              WEM_grdCuePoints_Change()
            EndIf
            
          Case \grdDMXStarts ; grdDMXStarts
            ; no action
            
          Case \txtFadeValue  ; txtFadeValue
            Select gnEventType
              Case #PB_EventType_Change
                WEM_txtField_Change()
              Case #PB_EventType_LostFocus
                ETVAL(WEM_txtFadeValue_Validate())
            EndSelect
            
          Case \txtTempoEtcValue  ; txtTempoEtcValue
            Select gnEventType
              Case #PB_EventType_LostFocus
                ETVAL(WEM_txtTempoEtcValue_Validate())
            EndSelect
            
          Case \txtValue  ; txtValue
            Select gnEventType
              Case #PB_EventType_Change
                WEM_txtField_Change()
              Case #PB_EventType_LostFocus
                ETVAL(WEM_txtValue_Validate())
            EndSelect
            
          Default
            If gnEventType <> #PB_EventType_Resize
              debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
            EndIf
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WEM_populateCboTempEtcAction()
  Static bPopulated
  With WEM
    If bPopulated = #False
      ClearGadgetItems(\cboTempoEtcAction)
      addGadgetItemWithData(\cboTempoEtcAction, Lang("WQL", "ChgNone"), #SCS_AF_ACTION_NONE)
      addGadgetItemWithData(\cboTempoEtcAction, Lang("WQL", "ChgFreq"), #SCS_AF_ACTION_FREQ)
      addGadgetItemWithData(\cboTempoEtcAction, Lang("WQL", "ChgTempo"), #SCS_AF_ACTION_TEMPO)
      addGadgetItemWithData(\cboTempoEtcAction, Lang("WQL", "ChgPitch"), #SCS_AF_ACTION_PITCH)
      setComboBoxWidth(\cboTempoEtcAction)
      bPopulated = #True
    EndIf
  EndWith
EndProcedure

Procedure WEM_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected bValidationResult
  
  With WEM
    Select nGadgetNo
      Case \txtValue
        bValidationResult = WEM_txtValue_Validate()
      Case \txtFadeValue
        bValidationResult = WEM_txtFadeValue_Validate()
      Case \txtTempoEtcValue
        bValidationResult = WEM_txtTempoEtcValue_Validate()
      Default
        bValidationResult = #True
    EndSelect
  EndWith
  ProcedureReturn bValidationResult
  
EndProcedure

; EOF