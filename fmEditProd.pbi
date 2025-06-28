; File: fmEditProd.pbi

EnableExplicit

Procedure WEP_btnTestToneCenter_Click()
  ; Added 4May2022am 11.9.1
  PROCNAMEC()
  Protected u
  
  With grProd ; nb grProd, NOT grProdForDevChgs as \fTestTonePan etc is not related to device maps
    u = preChangeProdF(\fTestTonePan, GGT(WEP\lblTestTonePan))
    \fTestTonePan = #SCS_PANCENTRE_SINGLE
    grProdForDevChgs\fTestTonePan = \fTestTonePan ; copy to grProdForDevChgs as this may be active at the time
    postChangeProdF(u, \fTestTonePan)
    SLD_setValue(WEP\sldTestTonePan, panToSliderValue(\fTestTonePan))
    WEP_enableTestTonePanControls()
    setTestTonePan()
  EndWith
EndProcedure

Procedure WEP_cboTestSound_Click()
  PROCNAMEC()
  Protected u
  
  With grProd ; nb grProd, NOT grProdForDevChgs as \nTestSound etc is not related to device maps
    u = preChangeProdL(\nTestSound, GGT(WEP\lblTestSound))
    \nTestSound = getCurrentItemData(WEP\cboTestSound, #SCS_TEST_TONE_SINE)
    grProdForDevChgs\nTestSound = \nTestSound ; copy to grProdForDevChgs as this may be active at the time
    postChangeProdL(u, \nTestSound)
    WEP_enableTestTonePanControls()
;     If gbUseBASS
      setTestToneLevel()
;     Else ; SM-S
;       samAddRequest(#SCS_SAM_SET_TEST_TONE_LEVEL, 0)
;     EndIf
    setTestTonePan() ; 4May2022 11.9.1
  EndWith
EndProcedure

Procedure WEP_btnDfltDevCenter_Click()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      SLD_setValue(WEP\sldDfltDevPan, #SCS_PANCENTRE_SLD)
      ED_fcSldDfltDevPan()
    EndWith
  EndIf
EndProcedure

Procedure WEP_btnDfltVidAudCenter_Click()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      SLD_setValue(WEP\sldDfltVidAudPan, #SCS_PANCENTRE_SLD)
      ED_fcSldDfltVidAudPan()
    EndWith
  EndIf
EndProcedure

Procedure WEP_cboDfltDevTrim_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected fOldTrim.f, fNewTrim.f
  Protected fOldDBLevelSingle.f, fNewDBLevelSingle.f
  Protected fOldLevel.f, fNewLevel.f
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      If \sDfltDBTrim <> GGT(WEP\cboDfltDevTrim)
        fOldTrim = dbTrimStringToSingle(\sDfltDBTrim)
        fNewTrim = getCurrentItemData(WEP\cboDfltDevTrim)
        fOldDBLevelSingle = convertDBStringToDBLevel(\sDfltDBLevel)
        fNewDBLevelSingle = fOldDBLevelSingle + (fNewTrim - fOldTrim)
        If fNewDBLevelSingle > 0.0
          fNewDBLevelSingle = 0.0
        ElseIf fNewDBLevelSingle < -75.0
          fNewDBLevelSingle = -75.0
        EndIf
        ; debugMsg(sProcName, "fOldTrim=" + StrF(fOldTrim,2) + ", fNewTrim=" + StrF(fNewTrim,2) + ", fOldDBLevelSingle=" + StrF(fOldDBLevelSingle,2) + ", fNewDBLevelSingle=" + StrF(fNewDBLevelSingle,2))
        \sDfltDBTrim = GGT(WEP\cboDfltDevTrim)
        \sDfltDBLevel = StrF(fNewDBLevelSingle,1)
        \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
        \fDfltTrimFactor = dbTrimStringToFactor(\sDfltDBTrim)
        If (SLD_getLevel(WEP\sldDfltDevLevel) <> \fDfltBVLevel) Or (SLD_getTrimFactor(WEP\sldDfltDevLevel) <> \fDfltTrimFactor)
          SLD_setLevel(WEP\sldDfltDevLevel, \fDfltBVLevel, \fDfltTrimFactor)
        EndIf
        ED_fcSldDfltDevLevel()
        SGT(WEP\txtDfltDevDBLevel, \sDfltDBLevel)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf

EndProcedure

Procedure WEP_cboDfltVidAudTrim_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected fOldTrim.f, fNewTrim.f
  Protected fOldDBLevelSingle.f, fNewDBLevelSingle.f
  Protected fOldLevel.f, fNewLevel.f
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      If \sDfltDBTrim <> GGT(WEP\cboDfltVidAudTrim)
        fOldTrim = dbTrimStringToSingle(\sDfltDBTrim)
        fNewTrim = getCurrentItemData(WEP\cboDfltVidAudTrim)
        fOldDBLevelSingle = convertDBStringToDBLevel(\sDfltDBLevel)
        fNewDBLevelSingle = fOldDBLevelSingle + (fNewTrim - fOldTrim)
        If fNewDBLevelSingle > 0.0
          fNewDBLevelSingle = 0.0
        ElseIf fNewDBLevelSingle < -75.0
          fNewDBLevelSingle = -75.0
        EndIf
        ; debugMsg(sProcName, "fOldTrim=" + StrF(fOldTrim,2) + ", fNewTrim=" + StrF(fNewTrim,2) + ", fOldDBLevelSingle=" + StrF(fOldDBLevelSingle,2) + ", fNewDBLevelSingle=" + StrF(fNewDBLevelSingle,2))
        \sDfltDBTrim = GGT(WEP\cboDfltVidAudTrim)
        \sDfltDBLevel = StrF(fNewDBLevelSingle,1)
        \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
        \fDfltTrimFactor = dbTrimStringToFactor(\sDfltDBTrim)
        If (SLD_getLevel(WEP\sldDfltVidAudLevel) <> \fDfltBVLevel) Or (SLD_getTrimFactor(WEP\sldDfltVidAudLevel) <> \fDfltTrimFactor)
          SLD_setLevel(WEP\sldDfltVidAudLevel, \fDfltBVLevel, \fDfltTrimFactor)
          ; debugMsg0(sProcName, "SLD_setLevel(WEP\sldDfltVidAudLevel, " + traceLevel(\fDfltBVLevel) + ", " + \fDfltTrimFactor + ")")
        EndIf
        ED_fcSldDfltVidAudLevel()
        SGT(WEP\txtDfltDevDBLevel, \sDfltDBLevel)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboDevMap_Click()
  PROCNAMEC()
  Protected sDevMapName.s, nDevMapPtr
  Protected nCheckDevMapResult
  Protected nAudioDriver, bResult
  
  debugMsg(sProcName, #SCS_START)
  
  setMouseCursorBusy()    ; can take a while, especially if changing to SM-S
  
  sDevMapName = GGT(WEP\cboDevMap)
  nDevMapPtr = getDevMapPtr(@grMapsForDevChgs, sDevMapName)
  debugMsg(sProcName, "sDevMapName=" + sDevMapName + ", nDevMapPtr=" + nDevMapPtr)
  
  grProdForDevChgs\nSelectedDevMapPtr = nDevMapPtr
  grProdForDevChgs\sSelectedDevMapName = sDevMapName
  grMapsForDevChgs\sSelectedDevMapName = sDevMapName
  
  ; 21Dec2023 11.10.0ds - the following moved to changeOfDevMap() as this processing must be done AFTER applying device changes
  
;   ; added 31Oct2017 11.7.0av following test of a cue file that had a network cue control device which was not recongised on changing the device map
;   ; that was because loadNetworkControl() only functions with the currently-selected device map, so needs to be called again if the device map is changed.
;   ; nb must be called AFTER setting grProdForDevChgs\nSelectedDevMapPtr for the new device map
;   debugMsg(sProcName, "calling loadNetworkControl(#True)")
;   loadNetworkControl(#True)
;   ; end added 31Oct2017 11.7.0av
;   
;   ; debugMsg(sProcName, "calling listAllDevMaps()")
;   ; listAllDevMaps()
;   
;   If nDevMapPtr >= 0
;     nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
;     debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
;     If gnCurrAudioDriver <> nAudioDriver
;       debugMsg3(sProcName, "calling closeDevices(" + decodeDriver(gnCurrAudioDriver) + ")")
;       closeDevices(gnCurrAudioDriver)
;       setCurrAudioDriver(nAudioDriver)
;       setMasterFader(grMasterLevel\fProdMasterBVLevel, #True)
;       debugMsg(sProcName, "calling setAllInputGains(#True)")
;       setAllInputGains(#True)
;     EndIf
;     updateDevMapPhysicalDevPtrs()
;     
;     debugMsg(sProcName, "calling setDefaultVidAudDeviceIfReqd(#True, #True)")
;     setDefaultVidAudDeviceIfReqd(#True, #True)
;     
;   EndIf
  
  nCheckDevMapResult = ED_checkDevMapForDevChgs(nDevMapPtr)
  debugMsg(sProcName, "ED_checkDevMapForDevChgs(" + nDevMapPtr + ") returned " + nCheckDevMapResult)
  
  WEP_loadDevsForProd()
  
  WEP_displayDevChgsItems()
  
;   debugMsg(sProcName, "calling WEP_displayAudDev()")
;   WEP_displayAudDev() ; Added 13Mar2023
  
  If grLicInfo\nMaxVidAudDevPerProd >= 1
    debugMsg(sProcName, "calling WEP_displayVidAudDev()")
    WEP_displayVidAudDev()
  EndIf
  If grLicInfo\nMaxVidCapDevPerProd >= 0
    WEP_displayVidCapDev()
  EndIf
  If grLicInfo\nMaxLiveDevPerProd >= 0
    WEP_displayLiveDev()
  EndIf
  If grLicInfo\nMaxInGrpPerProd >= 0
    WEP_displayInGrp()
  EndIf
  If grLicInfo\nMaxLightingDevPerProd >= 0
    grWEP\bReloadFixtureTypesComboBox = #True ; force FixtureType combo boxes to be re-populated
    WEP_displayLightingDev()
  EndIf
  If grLicInfo\nMaxCtrlSendDevPerProd >= 0
    WEP_displayCtrlDev()
  EndIf
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    WEP_displayCueDev()
  EndIf
  
  WEP_setDevChgsBtns()
  WEP_setRetryActivateBtn()
  WEP_setDevMapButtons()
  
  setMouseCursorNormal()
  
  If grCED\bChangeDevMap
    grCED\bDisplayApplyMsg = #True
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboAudioDriver_Click()
  PROCNAMEC()
  Protected nDevMapPtr
  Protected nCheckDevMapResult
  Protected nAudioDriver, nResult
  Protected bChangingAudioDriver
  
  debugMsg(sProcName, #SCS_START)
  
  nAudioDriver = getCurrentItemData(WEP\cboAudioDriver)
  debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver))
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  setMouseCursorBusy()    ; can take a while, especially if changing to SM-S
  
  If gnCurrAudioDriver <> nAudioDriver
    bChangingAudioDriver = #True
    debugMsg3(sProcName, "calling closeDevices(" + decodeDriver(gnCurrAudioDriver) + ")")
    closeDevices(gnCurrAudioDriver)
    setCurrAudioDriver(nAudioDriver)
    setMasterFader(grProd\fMasterBVLevel, #True)
    debugMsg(sProcName, "calling setAllInputGains(#True)")
    setAllInputGains(#True)
  EndIf
  
  grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver = nAudioDriver
  debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver))
  
  If nAudioDriver >= 0
    debugMsg(sProcName, "calling adjustPhysDevsForNewAudioDriver()")
    adjustPhysDevsForNewAudioDriver()
  EndIf
  
  ; debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + getDevMapName(nDevMapPtr) + ")")
  nCheckDevMapResult = ED_checkDevMapForDevChgs(nDevMapPtr)
  ; debugMsg(sProcName, "ED_checkDevMapForDevChgs(" + getDevMapName(nDevMapPtr) + ") returned " + nCheckDevMapResult)
  
  debugMsg(sProcName, "calling WEP_loadDevsForProd(" + strB(bChangingAudioDriver) + ")")
  WEP_loadDevsForProd(bChangingAudioDriver)
  
  debugMsg(sProcName, "calling WEP_displayDevChgsItems()")
  WEP_displayDevChgsItems()
  If grLicInfo\nMaxLightingDevPerProd >= 0
    WEP_displayLightingDev()
  EndIf
  If grLicInfo\nMaxCtrlSendDevPerProd >= 0
    WEP_displayCtrlDev()
  EndIf
  If grLicInfo\nMaxCueCtrlDev >= 0
    WEP_displayCueDev()
  EndIf
  If grLicInfo\nMaxLiveDevPerProd >= 0
    WEP_displayLiveDev()
  EndIf
  If grLicInfo\nMaxInGrpPerProd >= 0
    WEP_displayInGrp()
  EndIf
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns() etc")
  WEP_setDevChgsBtns()
  WEP_setRetryActivateBtn()
  WEP_setDevMapButtons()
  
  debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver))
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_txtOutputGainDB_Validate(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If validateDbField(GGT(WEP\txtAudOutputGainDB(Index)), GGT(WEP\lblGainDB)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WEP\txtAudOutputGainDB(Index)) <> gsTmpString
    SGT(WEP\txtAudOutputGainDB(Index), gsTmpString)
  EndIf
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \sDevOutputGainDB = Trim(GGT(WEP\txtAudOutputGainDB(Index)))
      \fDevOutputGain = convertDBStringToBVLevel(\sDevOutputGainDB)
      ED_fcTxtOutputGainDB(Index)
    EndWith
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtVidAudOutputGainDB_Validate(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If validateDbField(GGT(WEP\txtVidAudOutputGainDB(Index)), GGT(WEP\lblVidAudGainDB)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WEP\txtVidAudOutputGainDB(Index)) <> gsTmpString
    SGT(WEP\txtVidAudOutputGainDB(Index), gsTmpString)
  EndIf
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxVidAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \sDevOutputGainDB = Trim(GGT(WEP\txtVidAudOutputGainDB(Index)))
      \fDevOutputGain = convertDBStringToBVLevel(\sDevOutputGainDB)
      ED_fcTxtVidAudOutputGainDB(Index)
    EndWith
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtInputGainDB_Validate(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If validateDbField(GGT(WEP\txtInputGainDB(Index)), GGT(WEP\lblGainDB)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WEP\txtInputGainDB(Index)) <> gsTmpString
    SGT(WEP\txtInputGainDB(Index), gsTmpString)
  EndIf
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxLiveDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \sInputGainDB = Trim(GGT(WEP\txtInputGainDB(Index)))
      \fInputGain = convertDBStringToBVLevel(\sInputGainDB)
      ED_fcTxtInputGainDB(Index)
    EndWith
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_cboLightingDevType_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevTypeNew, nDevTypeOld
  Protected sLogicalDevOld.s, sLogicalDevNew.s ;, sLogicalDevBase.s
  Protected d, i, j, n
  Protected bChangeOK, sMsg.s
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
; debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
; listAllDevMapsForDevChgs()
  
  nDevNo = Index 
  With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
    nDevTypeOld = \nDevType
    nDevTypeNew = getCurrentItemData(WEP\cboLightingDevType(Index))
    debugMsg(sProcName, "nDevTypeOld=" + decodeDevType(nDevTypeOld) + ", nDevTypeNew=" + decodeDevType(nDevTypeNew))
    If nDevTypeNew = nDevTypeOld
      ; no change - nothing to validate
      debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + Index + ")")
      WEP_setCurrentLightingDevInfo(Index)
      WEP_setTBSButtons(Index)
      ProcedureReturn
    EndIf
    
    ; can only change or remove device type if the logical device is not currently used in cues
    sLogicalDevOld = \sLogicalDev
    bChangeOK = #True
    If Len(sLogicalDevOld) > 0
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeK
            If aSub(j)\sLTLogicalDev = sLogicalDevOld
              sMsg = LangPars("Errors", "CannotChangeDevType", sLogicalDevOld, getSubLabel(j))
              bChangeOK = #False
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If bChangeOK = #False
          Break
        EndIf
      Next i
      If bChangeOK = #False
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + Index + ")")
        WEP_setCurrentLightingDevInfo(Index)
        WEP_setTBSButtons(Index)
        ProcedureReturn
      EndIf
    EndIf
    
    ; validation passed - new code
    If nDevNo > grProdForDevChgs\nMaxLightingLogicalDev
      addOneLightingLogicalDev(@grProdForDevChgs)
    EndIf

    \nDevType = nDevTypeNew
    If \nDevId < 0
      gnNextDevId + 1
      \nDevId = gnNextDevId
    EndIf
    
    Select nDevTypeNew
      Case #SCS_DEVTYPE_NONE
        ; deleted device
        \sLogicalDev = ""
        \sLightingDevDesc = ""
        sLogicalDevNew = ""
        
      Case #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDevNew = WEP_makeNewLightingLogicalDev(nDevNo)
        debugMsg(sProcName, "WEP_makeNewLightingLogicalDev(" + nDevNo + ") returned " + sLogicalDevNew)
        
    EndSelect
    
    \sLogicalDev = sLogicalDevNew
    SGT(WEP\txtLightingLogicalDev(Index), sLogicalDevNew)
    
    debugMsg(sProcName, "calling resetSessionOptions()")
    resetSessionOptions(#True)

    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDevNew)
    If nDevMapDevPtr = -1
      debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, " + decodeDevType(nDevTypeNew) + ", " + \nDevId + ", " + sLogicalDevNew + ")")
      nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, nDevTypeNew, \nDevId, sLogicalDevNew)
      debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
      resetDevMapForDevChgsDevPtrs()  ; removes old device from device maps, if necessary
    EndIf
    
    debugMsg(sProcName, "calling setDevChgsDevDefaults(" + nDevMapDevPtr + ", #False)")
    setDevChgsDevDefaults(nDevMapDevPtr, #False)
    
    setDevChgsPhysDevIfReqd(nDevMapDevPtr, nDevNo)
    
    ED_fcLightingDevType(Index)
    
    ; change device types in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(#SCS_DEVGRP_LIGHTING, " + decodeDevType(nDevTypeNew) + ", " + nDevNo + ", " + sLogicalDevOld + ")")
    updateDevChgsDev(#SCS_DEVGRP_LIGHTING, nDevTypeNew, nDevNo, sLogicalDevOld)
    
    WEP_updateProdDev(#SCS_DEVGRP_LIGHTING, nDevNo)
    
    debugMsg(sProcName, "calling loadMidiControl(#True)")
    loadMidiControl(#True)
    
    debugMsg(sProcName, "calling loadNetworkControl(#True)")
    loadNetworkControl(#True)

    debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
    DMX_loadDMXControl(#True)
    
    debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + Index + ")")
    WEP_setCurrentLightingDevInfo(Index)
    WEP_displayLightingPhysInfo(Index)
    
    If nDevNo < grLicInfo\nMaxLightingDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_LIGHTING, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_LIGHTING, nDevNo+1)
    EndIf

    WEP_CheckForDMXPortDuplication(#SCS_WEP_DMX_CONFLICT_STATUSBAR)
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
  EndWith
  
; debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
; listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_CtrlDevType_Changed(Index, nDevTypeNew)
  PROCNAMEC()
  Protected nDevNo, nDevTypeOld
  Protected sLogicalDevOld.s, sLogicalDevNew.s, sLogicalDevBase.s
  Protected d, i, j, n
  Protected bChangeOK, sMsg.s
  Protected nDevMapDevPtr
  Protected bForMTCNew
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nDevTypeNew=" + decodeDevType(nDevTypeNew))
  
  nDevNo = Index
  debugMsg(sProcName, "grProdForDevChgs\nMaxCtrlSendLogicalDev=" + grProdForDevChgs\nMaxCtrlSendLogicalDev + ", ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())=" + ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs()))
  If nDevNo > grProdForDevChgs\nMaxCtrlSendLogicalDev
    If nDevTypeNew = #SCS_DEVTYPE_NONE
      ProcedureReturn
    EndIf
;     debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, " + nDevNo + ")")
;     WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, nDevNo)
;     debugMsg(sProcName, "grProdForDevChgs\nMaxCtrlSendLogicalDev=" + grProdForDevChgs\nMaxCtrlSendLogicalDev + ", ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())=" + ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs()))
  EndIf
  
  With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
    nDevTypeOld = \nDevType
    debugMsg(sProcName, "nDevTypeOld=" + decodeDevType(nDevTypeOld) + ", nDevTypeNew=" + decodeDevType(nDevTypeNew))
    If nDevTypeNew = nDevTypeOld
      ; no change - nothing to validate
      WEP_setCurrentCtrlDevInfo(Index)
      WEP_setTBSButtons(Index)
      ProcedureReturn
    EndIf
    
    ; can only change or remove device type if the logical device is not currently used in cues
    sLogicalDevOld = \sLogicalDev
    bChangeOK = #True
    If Len(sLogicalDevOld) > 0
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeM
            For n = 0 To #SCS_MAX_CTRL_SEND
              If aSub(j)\aCtrlSend[n]\sCSLogicalDev = sLogicalDevOld
                sMsg = LangPars("Errors", "CannotChangeDevType", sLogicalDevOld, getSubLabel(j))
                bChangeOK = #False
                Break
              EndIf
            Next n
            If bChangeOK = #False
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If bChangeOK = #False
          Break
        EndIf
      Next i
      If bChangeOK = #False
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        WEP_setCurrentCtrlDevInfo(Index)
        WEP_setTBSButtons(Index)
        ProcedureReturn
      EndIf
    EndIf
    
    ; validation passed - new code
    If nDevNo > grProdForDevChgs\nMaxCtrlSendLogicalDev
      addOneCtrlSendLogicalDev(@grProdForDevChgs)
    EndIf
    
    \nDevType = nDevTypeNew
    If \nDevId < 0
      gnNextDevId + 1
      \nDevId = gnNextDevId
    EndIf
    
    bForMTCNew = #False
    Select nDevTypeNew
      Case #SCS_DEVTYPE_NONE
        ; deleted device
        \sLogicalDev = ""
        \sCtrlSendDevDesc = ""
        sLogicalDevNew = ""
        
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        bForMTCNew = \bCtrlMidiForMTC
        
      Case #SCS_DEVTYPE_CS_RS232_OUT
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        
      Case #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        debugMsg(sProcName, "WEP_makeNewCtrlLogicalDev(" + nDevNo + ") returned " + sLogicalDevNew)
        
    EndSelect
    
    \sLogicalDev = sLogicalDevNew
    SGT(WEP\txtCtrlLogicalDev(nDevNo), sLogicalDevNew)
    \bCtrlMidiForMTC = bForMTCNew
    
    debugMsg(sProcName, "calling resetSessionOptions()")
    resetSessionOptions(#True)

    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sLogicalDevNew)
    If nDevMapDevPtr = -1
      debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, " + decodeDevType(nDevTypeNew) + ", " + \nDevId + ", " + sLogicalDevNew + ")")
      nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, nDevTypeNew, \nDevId, sLogicalDevNew)
      debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
      resetDevMapForDevChgsDevPtrs()  ; removes old device from device maps, if necessary
    EndIf
    
    debugMsg(sProcName, "calling setDevChgsDevDefaults(" + nDevMapDevPtr + ", #False)")
    setDevChgsDevDefaults(nDevMapDevPtr, #False)
    
    setDevChgsPhysDevIfReqd(nDevMapDevPtr, nDevNo)
    
    ED_fcCtrlDevType(Index)
    
    ; change device types in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(#SCS_DEVGRP_CTRL_SEND, " + decodeDevType(nDevTypeNew) + ", " + nDevNo + ", " + sLogicalDevOld + ")")
    updateDevChgsDev(#SCS_DEVGRP_CTRL_SEND, nDevTypeNew, nDevNo, sLogicalDevOld)
    
    WEP_updateProdDev(#SCS_DEVGRP_CTRL_SEND, nDevNo)
    
    debugMsg(sProcName, "calling loadMidiControl(#True)")
    loadMidiControl(#True)
    
    debugMsg(sProcName, "calling loadNetworkControl(#True)")
    loadNetworkControl(#True)

    debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
    DMX_loadDMXControl(#True)

    WEP_setCurrentCtrlDevInfo(Index)
    WEP_displayCtrlPhysInfo(nDevNo)
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_mnuCSDevType_Selection(nEventMenu)
  PROCNAMEC()
  Protected nDevNo, nNewDevType
  
  debugMsg(sProcName, #SCS_START + ", nEventMenu=" + decodeMenuItem(nEventMenu) + ", grWEP\nCtrlDevClicked=" + grWEP\nCtrlDevClicked)
  
  nDevNo = grWEP\nCtrlDevClicked
  If nDevNo >= 0
    Select nEventMenu
      Case #WEP_mnuCSDevTypeMidiOut
        nNewDevType = #SCS_DEVTYPE_CS_MIDI_OUT
      Case #WEP_mnuCSDevTypeMidiThru
        nNewDevType = #SCS_DEVTYPE_CS_MIDI_THRU
      Case #WEP_mnuCSDevTypeRS232Out
        nNewDevType = #SCS_DEVTYPE_CS_RS232_OUT
      Case #WEP_mnuCSDevTypeNetworkOut
        nNewDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
      Case #WEP_mnuCSDevTypeHTTPRequest
        nNewDevType = #SCS_DEVTYPE_CS_HTTP_REQUEST
      Default
        nNewDevType = #SCS_DEVTYPE_NONE
    EndSelect
    WEP_CtrlDevType_Changed(nDevNo, nNewDevType)
    WEP_setCtrlDevTypeText(nDevNo)
    If nNewDevType <> #SCS_DEVTYPE_NONE And nDevNo < grLicInfo\nMaxCtrlSendDevPerProd
      WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, nDevNo+1)
    EndIf
  EndIf  
EndProcedure

Procedure WEP_cboCueDevType_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevTypeNew, nDevTypeOld
  Protected sLogicalDev.s
  Protected d, i, j, n
  Protected bChangeOK, sMsg.s
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index 
  
  With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
    
    nDevTypeOld = \nDevType
    nDevTypeNew = getCurrentItemData(WEP\cboCueDevType(Index))
    debugMsg(sProcName, "nDevTypeOld=" + decodeDevType(nDevTypeOld) + ", nDevTypeNew=" + decodeDevType(nDevTypeNew))
    If nDevTypeNew = nDevTypeOld
      ; no change - nothing to process
      debugMsg(sProcName, "calling WEP_setCurrentCueDevInfo(" + Index + ")")
      WEP_setCurrentCueDevInfo(Index)
      ProcedureReturn
    EndIf
    
    sLogicalDev = \sCueCtrlLogicalDev
    ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev)
    
    grWEP\bCueMidiInDevsChanged = #True ; used by TestMIDI
    ; debugMsg(sProcName, "grWEP\bCueMidiInDevsChanged=" + strB(grWEP\bCueMidiInDevsChanged))
    
    grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo) = grCueCtrlLogicalDevsDef
    grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\sCueCtrlLogicalDev = "C" + Str(nDevNo+1)
    
    ; debugMsg0(sProcName, "nDevNo=" + nDevNo + ", grProdForDevChgs\nMaxCueCtrlLogicalDev=" + grProdForDevChgs\nMaxCueCtrlLogicalDev + ", \nMaxCueCtrlLogicalDevDisplay=" + grProdForDevChgs\nMaxCueCtrlLogicalDevDisplay)
    If nDevNo > grProdForDevChgs\nMaxCueCtrlLogicalDev
      addOneCueCtrlLogicalDev(@grProdForDevChgs)
    EndIf
    
    \nDevType = nDevTypeNew
    ; Sep2024 11.10.3bx: The following moved BEFORE changes to grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo) because they altered \sCueCtrlLogicalDev
;     sLogicalDev = \sCueCtrlLogicalDev
;     ; debugMsg(sProcName, "sLogicalDev=" + sLogicalDev)
    
    debugMsg(sProcName, "calling resetSessionOptions()")
    resetSessionOptions(#True)

    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
    debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr +", nDevTypeNew=" + decodeDevType(nDevTypeNew))
    If nDevMapDevPtr = -1
      debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_CUE_CTRL, " + decodeDevType(nDevTypeNew) + ", " + \nDevId + ", " + sLogicalDev + ")")
      nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CUE_CTRL, nDevTypeNew, \nDevId, sLogicalDev)
      debugMsg(sProcName, "calling setDevChgsDevDefaults(" + nDevMapDevPtr + ", #True)")
      setDevChgsDevDefaults(nDevMapDevPtr, #True)
      debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
      resetDevMapForDevChgsDevPtrs()  ; removes old device from device maps, if necessary
    Else
      grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevType = nDevTypeNew
      grMapsForDevChgs\aDev(nDevMapDevPtr)\sLogicalDev = sLogicalDev
      debugMsg(sProcName, "calling setDevChgsDevDefaults(" + nDevMapDevPtr + ", #True)")
      setDevChgsDevDefaults(nDevMapDevPtr, #True)
    EndIf
    
    grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = grDevMapDevDef\nPhysicalDevPtr
    setDevChgsPhysDevIfReqd(nDevMapDevPtr, nDevNo)
    
    ; change device types in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(#SCS_DEVGRP_CUE_CTRL, " + decodeDevType(nDevTypeNew) + ", " + nDevNo + ", " + sLogicalDev + ")")
    updateDevChgsDev(#SCS_DEVGRP_CUE_CTRL, nDevTypeNew, nDevNo, sLogicalDev)
    
    WEP_updateProdDev(#SCS_DEVGRP_CUE_CTRL, nDevNo)
    
    debugMsg(sProcName, "calling loadMidiControl(#True)")
    loadMidiControl(#True)
    
    debugMsg(sProcName, "calling loadNetworkControl(#True)")
    loadNetworkControl(#True)
    
    If \nDevType = #SCS_DEVTYPE_NONE
      WEP_removeDevice(#SCS_DEVGRP_CUE_CTRL, nDevNo)
    ElseIf nDevNo < grLicInfo\nMaxCueCtrlDev
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_CUE_CTRL, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_CUE_CTRL, nDevNo+1)
    EndIf

    debugMsg(sProcName, "calling WEP_displayCuePhysInfo(" + Index + ")")
    WEP_displayCuePhysInfo(Index)
    debugMsg(sProcName, "calling WEP_setCurrentCueDevInfo(" + Index + ")")
    WEP_setCurrentCueDevInfo(Index)
    ; debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    ; WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboDfltTimeProfile_Click()
  Protected u

  u = preChangeProdS(grProd\sDefaultTimeProfile, GGT(WEP\lblDfltTimeProfile))
  grProd\sDefaultTimeProfile = GGT(WEP\cboDfltTimeProfile)
  grCED\bProdChanged = #True
  postChangeProdS(u, grProd\sDefaultTimeProfile)
EndProcedure

Procedure WEP_cboDfltTimeProfileForDay_Click(Index)
  Protected u

  u = preChangeProdS(grProd\sDefaultTimeProfileForDay[Index], GGT(WEP\lblDfltTimeProfileDay[Index]))
  grProd\sDefaultTimeProfileForDay[Index] = GGT(WEP\cboDfltTimeProfileForDay[Index])
  grCED\bProdChanged = #True
  postChangeProdS(u, grProd\sDefaultTimeProfileForDay[Index])
EndProcedure

Procedure WEP_txtDBLevelChangeIncrement_Validate()
  PROCNAMEC()
  Protected u
  Protected sDBLevelChangeIncrement.s
  
  If validateDbIncrementField(GGT(WEP\txtDBLevelChangeIncrement), GGT(WEP\lblDBLevelChangeIncrement)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WEP\txtDBLevelChangeIncrement) <> gsTmpString
    SGT(WEP\txtDBLevelChangeIncrement, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdS(\sDBLevelChangeIncrement, GGT(WEP\lblDBLevelChangeIncrement))
    sDBLevelChangeIncrement = Trim(GGT(WEP\txtDBLevelChangeIncrement))
    If Len(sDBLevelChangeIncrement) = 0
      sDBLevelChangeIncrement = grProdDef\sDBLevelChangeIncrement
    EndIf
    \sDBLevelChangeIncrement = sDBLevelChangeIncrement
    grCED\bProdChanged = #True
    postChangeProdS(u, \sDBLevelChangeIncrement)
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_cboOutputDevForTestLiveInput_Click()
  Protected d
  
  With grProdForDevChgs
    d = getCurrentItemData(WEP\cboOutputDevForTestLiveInput, -1)
    If d >= 0
      \sOutputDevForTestLiveInput = \aAudioLogicalDevs(d)\sLogicalDev
    Else
      \sOutputDevForTestLiveInput = ""
    EndIf
  EndWith
EndProcedure

Procedure WEP_cboRunMode_Click()
  Protected u

  u = preChangeProdL(grProd\nRunMode, GGT(WEP\lblRunMode))
  
  With grProd
    grProd\nRunMode = GGS(WEP\cboRunMode)
    Select \nRunMode
      Case #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL, #SCS_RUN_MODE_BOTH_PREOPEN_ALL
        \bPreOpenNonLinearCues = #True
      Default
        \bPreOpenNonLinearCues = #False
    EndSelect
  EndWith
  
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nRunMode)
  
  setNonLinearCueFlags()

EndProcedure

Procedure WEP_cboCueLabelIncrement_Click()
  Protected u
  
  u = preChangeProdL(grProd\nCueLabelIncrement, GGT(WEP\lblCueLabelIncrement))
  grProd\nCueLabelIncrement = Val(GGT(WEP\cboCueLabelIncrement))
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nCueLabelIncrement)
  
EndProcedure

Procedure WEP_cboFocusPoint_Click()
  Protected u
  
  u = preChangeProdL(grProd\nFocusPoint, GGT(WEP\lblFocusPoint))
  grProd\nFocusPoint = getCurrentItemData(WEP\cboFocusPoint)
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nFocusPoint)
  
EndProcedure

Procedure WEP_cboGridClickAction_Click()
  Protected u
  
  u = preChangeProdL(grProd\nGridClickAction, GGT(WEP\lblGridClickAction))
  grProd\nGridClickAction = getCurrentItemData(WEP\cboGridClickAction)
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nGridClickAction)
  
EndProcedure

Procedure WEP_cboLostFocusAction_Click()
  Protected u
  
  u = preChangeProdL(grProd\nLostFocusAction, GGT(WEP\lblLostFocusAction))
  grProd\nLostFocusAction = getCurrentItemData(WEP\cboLostFocusAction)
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nLostFocusAction)
  
EndProcedure

Procedure WEP_cboMaxDBLevel_Click()
  PROCNAMEC()
  Protected u
  Protected nNewMaxDBLevel
  Protected fNewMaxBVLevel.f
  Protected fCurrentMaxBVLevel.f
  Protected sMsg.s, sItem.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nNewMaxDBLevel = getCurrentItemData(WEP\cboMaxDBLevel)
  Select nNewMaxDBLevel
    Case 12
      fNewMaxBVLevel = grLevels\f12BVLevel
    Default
      fNewMaxBVLevel = grLevels\fZeroBVLevel
  EndSelect
  fCurrentMaxBVLevel = getMaxBVLevelInUse()
  debugMsg(sProcName, "fCurrentMaxBVLevel=" + traceLevel(fCurrentMaxBVLevel) + ", fNewMaxBVLevel=" + traceLevel(fNewMaxBVLevel) + ", gnMaxBVLevelSubPtr=" + getSubLabel(gnMaxBVLevelSubPtr))
  If fCurrentMaxBVLevel > fNewMaxBVLevel
    If gnMaxBVLevelSubPtr >= 0
      sItem = grText\sTextCue + " " + getSubLabel(gnMaxBVLevelSubPtr) ; nb identify the sub-cue but use 'Cue' in the message as most cues only have one sub-cue
    Else
      Select gnMaxBVLevelSubPtr ; see getMaxBVLevelInUse() for meanings of negative values
        Case -1
          sItem = "'" + Lang("WEP", "lblMasterFader") + "'"
        Case -2, -3
          sItem = "'" + Lang("WEP", "lblAudDefaults") + "'"
        Case -4
          sItem = "'" + Lang("WEP", "lblInputDefaults") + "'"
      EndSelect
    EndIf
    If Len(sItem) = 0
      ; shouldn't happen
      sItem = Str(gnMaxBVLevelSubPtr)
    EndIf
    sMsg = LangPars("Errors", "CannotChangeMaxMinLevel", Lang("WEP", "lblMaxDBLevel"), convertBVLevelToDBString(fNewMaxBVLevel, #False, #True), sItem, convertBVLevelToDBString(fCurrentMaxBVLevel, #False, #True))
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    nListIndex = indexForComboBoxData(WEP\cboMaxDBLevel, grProd\nMaxDBLevel, 0)
    SGS(WEP\cboMaxDBLevel, nListIndex)
    ProcedureReturn
  EndIf
  
  u = preChangeProdL(grProd\nMaxDBLevel, GGT(WEP\lblMaxDBLevel), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_MAX_LEVEL)
  grProd\nMaxDBLevel = nNewMaxDBLevel
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nMaxDBLevel)
  
  debugMsg(sProcName, "calling setProdGlobals()")
  setProdGlobals()  ; nb also calls redrawAllLevelSliders()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboMinDBLevel_Click()
  PROCNAMEC()
  Protected u
  Protected nNewMinDBLevel
  Protected fNewMinBVLevel.f
  Protected fCurrentMinBVLevel.f
  Protected sMsg.s, sItem.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nNewMinDBLevel = getCurrentItemData(WEP\cboMinDBLevel)
  Select nNewMinDBLevel
    Case -160
      fNewMinBVLevel = convertDBStringToBVLevel("-160")
    Case -140
      fNewMinBVLevel = convertDBStringToBVLevel("-140")
    Case -120
      fNewMinBVLevel = convertDBStringToBVLevel("-120")
    Case -100
      fNewMinBVLevel = convertDBStringToBVLevel("-100")
    Default
      fNewMinBVLevel = convertDBStringToBVLevel("-75")
  EndSelect
  fCurrentMinBVLevel = getMinBVLevelInUse()
  debugMsg(sProcName, "fCurrentMinBVLevel=" + traceLevel(fCurrentMinBVLevel) + ", fNewMinBVLevel=" + traceLevel(fNewMinBVLevel) + ", gnMinBVLevelSubPtr=" + getSubLabel(gnMinBVLevelSubPtr))
  If fCurrentMinBVLevel < fNewMinBVLevel
    If gnMinBVLevelSubPtr >= 0
      sItem = grText\sTextCue + " " + getSubLabel(gnMinBVLevelSubPtr) ; nb identify the sub-cue but use 'Cue' in the message as most cues only have one sub-cue
    Else
      Select gnMinBVLevelSubPtr ; see getMinBVLevelInUse() for meanings of negative values
        Case -1
          sItem = "'" + Lang("WEP", "lblMasterFader") + "'"
        Case -2, -3
          sItem = "'" + Lang("WEP", "lblAudDefaults") + "'"
        Case -4
          sItem = "'" + Lang("WEP", "lblInputDefaults") + "'"
      EndSelect
    EndIf
    If Len(sItem) = 0
      ; shouldn't happen
      sItem = Str(gnMinBVLevelSubPtr)
    EndIf
    sMsg = LangPars("Errors", "CannotChangeMaxMinLevel", Lang("WEP", "lblMinDBLevel"), convertBVLevelToDBString(fNewMinBVLevel, #False, #True), sItem, convertBVLevelToDBString(fCurrentMinBVLevel, #False, #True))
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    nListIndex = indexForComboBoxData(WEP\cboMinDBLevel, grProd\nMinDBLevel, 0)
    SGS(WEP\cboMinDBLevel, nListIndex)
    ProcedureReturn
  EndIf
  
  u = preChangeProdL(grProd\nMinDBLevel, GGT(WEP\lblMinDBLevel), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_LOW_LEVEL)
  grProd\nMinDBLevel = nNewMinDBLevel
  grCED\bProdChanged = #True
  postChangeProdL(u, grProd\nMinDBLevel)
  
  debugMsg(sProcName, "calling setProdGlobals()")
  setProdGlobals()  ; nb also calls redrawAllLevelSliders()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboNumChans_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected u
  Protected nNrOfOutputChansOld, nNrOfOutputChansNew
  Protected sLogicalDev.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = Index
  
  With grProdForDevChgs
    
    If GGS(WEP\cboNumChans(Index)) >= 0
      nNrOfOutputChansNew = GGS(WEP\cboNumChans(Index)) + 1
    Else
      nNrOfOutputChansNew = 0
    EndIf
    nNrOfOutputChansOld = \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans
    If nNrOfOutputChansNew = nNrOfOutputChansOld
      ; no change - nothing to validate
      debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
      WEP_setCurrentAudDevInfo(Index)
      debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
      WEP_setTBSButtons(Index)
      ProcedureReturn
    EndIf
    
    If nNrOfOutputChansNew < 1
      ; can only blank out number of channels only if logical device name is clear
      If Trim(\aAudioLogicalDevs(nDevNo)\sLogicalDev)
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "MustBeEntered", GGT(WEP\lblNumChans)), #PB_MessageRequester_Error)
        debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
        WEP_setCurrentAudDevInfo(Index)
        debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
        WEP_setTBSButtons(Index)
        ProcedureReturn
      EndIf
    EndIf
    
    ; validation passed - new code
    \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans = nNrOfOutputChansNew
    
    setEditLogicalDevsDerivedFields()
    
    ; change number of channels in device maps
    sLogicalDev = \aAudioLogicalDevs(nDevNo)\sLogicalDev
    updateDevChgsDev(#SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVTYPE_AUDIO_OUTPUT, nDevNo, sLogicalDev)
    
    WEP_updateProdDev(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
    
    debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
    WEP_setCurrentAudDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboOutputRange_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldOutputRange.s, sNewOutputRange.s
  Protected nNewFirst1BasedOutputChan
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxAudDevPerProd
    CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      sOldOutputRange = \s1BasedOutputRange
      sNewOutputRange = Trim(GGT(WEP\cboOutputRange(Index)))
      nNewFirst1BasedOutputChan = getFirst1BasedChanFromRange(sNewOutputRange)
      \s1BasedOutputRange = sNewOutputRange
      \nFirst1BasedOutputChan = nNewFirst1BasedOutputChan
      debugMsg(sProcName, "\s1BasedOutputRange=" + \s1BasedOutputRange + ", \nFirst1BasedOutputChan=" + \nFirst1BasedOutputChan)
    EndWith
  EndIf
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + grProdForDevChgs\nSelectedDevMapPtr + ")")
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
      setOwnState(WEP\chkAudActive(Index), #True)
    Else
      setOwnState(WEP\chkAudActive(Index), #False)
    EndIf
    debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
    WEP_setCurrentAudDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboNumInputChans_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected u
  Protected nNrOfInputChansOld, nNrOfInputChansNew
  Protected sLogicalDev.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = Index
  
  With grProdForDevChgs
    
    If GGS(WEP\cboNumInputChans(Index)) >= 0
      nNrOfInputChansNew = GGS(WEP\cboNumInputChans(Index)) + 1
    Else
      nNrOfInputChansNew = 0
    EndIf
    nNrOfInputChansOld = \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans
    If nNrOfInputChansNew = nNrOfInputChansOld
      ; no change - nothing to validate
      debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
      WEP_setCurrentLiveDevInfo(Index)
      debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
      WEP_setTBSButtons(Index)
      ProcedureReturn
    EndIf
    
    If nNrOfInputChansNew < 1
      ; can only blank out number of channels only if logical device name is clear
      If Len(Trim(\aLiveInputLogicalDevs(nDevNo)\sLogicalDev)) > 0
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "MustBeEntered", GGT(WEP\lblNumInputChans)), #PB_MessageRequester_Error)
        debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
        WEP_setCurrentLiveDevInfo(Index)
        debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
        WEP_setTBSButtons(Index)
        ProcedureReturn
      EndIf
    EndIf
    
    ; validation passed - new code
    \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans = nNrOfInputChansNew
    
    setEditLogicalDevsDerivedFields()
    
    ; change number of channels in device maps
    sLogicalDev = \aLiveInputLogicalDevs(nDevNo)\sLogicalDev
    updateDevChgsDev(#SCS_DEVGRP_LIVE_INPUT, #SCS_DEVTYPE_LIVE_INPUT, nDevNo, sLogicalDev)
    
    WEP_updateProdDev(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
    
    debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
    WEP_setCurrentLiveDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboInputRange_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldInputRange.s, sNewInputRange.s
  Protected nNewFirst1BasedInputChan
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  debugMsg(sProcName, "GetGadgetState(WEP\cboInputRange(" + Index + ")=" + GetGadgetState(WEP\cboInputRange(Index)))
  nDevNo = Index
  
  With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
    debugMsg(sProcName, "grProdForDevChgs\aLiveInputLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nInputs=" + \nInputs + ", \bDummyDev=" + strB(\bDummyDev))
  EndWith
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
  
  If nDevNo <= grProdForDevChgs\nMaxLiveInputLogicalDevDisplay ; grLicInfo\nMaxLiveDevPerProd
    CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      sOldInputRange = \s1BasedInputRange
      sNewInputRange = Trim(GGT(WEP\cboInputRange(Index)))
      nNewFirst1BasedInputChan = getFirst1BasedChanFromRange(sNewInputRange)
      \s1BasedInputRange = sNewInputRange
      \nFirst1BasedInputChan = nNewFirst1BasedInputChan
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\s1BasedInputRange=" + \s1BasedInputRange + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan)
    EndWith
    If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
      setDevTypeVariablesForSMS(@grMapsForDevChgs\aDev(nDevMapDevPtr)) ; Added 14Jun2021 11.8.5ai
    EndIf
  EndIf
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + grProdForDevChgs\nSelectedDevMapPtr + ")")
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
      setOwnState(WEP\chkLiveActive(Index), #True)
    Else
      setOwnState(WEP\chkLiveActive(Index), #False)
    EndIf
    debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
    WEP_setCurrentLiveDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
    debugMsg(sProcName, "grProdForDevChgs\aLiveInputLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nInputs=" + \nInputs + ", \bDummyDev=" + strB(\bDummyDev))
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboAudioPhysicalDev_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldDevDesc.s, sNewDevDesc.s
  Protected nPhysicalDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", cboAudioPhysicalDev(" + Index + ")=" + GGT(WEP\cboAudioPhysicalDev(Index)) + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
  debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  ; check that nDevNo is within range of grMapsForDevChgs\aDev(nDevMapDevPtr) array, as it may be out of range after 'Undo Device Changes', for devices that were added
  If nDevMapDevPtr >= 0
    If nDevNo <= grLicInfo\nMaxAudDevPerProd
      CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        sOldDevDesc = \sPhysicalDev
        sNewDevDesc = Trim(GGT(WEP\cboAudioPhysicalDev(Index)))
        debugMsg(sProcName, "sOldDevDesc=" + sOldDevDesc + ", sNewDevDesc=" + sNewDevDesc)
        \sPhysicalDev = sNewDevDesc
        If Len(sNewDevDesc) > 0
          nPhysicalDevPtr = getPhysicalDevPtr(\nDevType, sNewDevDesc, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
          debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
        Else
          nPhysicalDevPtr = -1
        EndIf
        debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
        \nPhysicalDevPtr = nPhysicalDevPtr
        If nPhysicalDevPtr >= 0
          \bDefaultDev = gaAudioDev(nPhysicalDevPtr)\bDefaultDev
        EndIf
        debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bDefaultDev=" + strB(\bDefaultDev))
      EndWith
      ED_fcAudPhysicalDev(Index)
    EndIf
  EndIf
  
  With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
    \nPhysicalDevPtr = nPhysicalDevPtr
    debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
    If nPhysicalDevPtr >= 0
      ; \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
      \nOutputs = gaAudioDev(nPhysicalDevPtr)\nOutputs
      \bNoDevice = gaAudioDev(nPhysicalDevPtr)\bNoDevice
      \nBassASIODevice = gaAudioDev(nPhysicalDevPtr)\nDevBassASIODevice
      \nBassDevice = gaAudioDev(nPhysicalDevPtr)\nBassDevice
    Else
      ; \nDevType = #SCS_DEVTYPE_NONE
      \nOutputs = 0
      \bNoDevice = #False
      \nBassASIODevice = -1
      \nBassDevice = -1
    EndIf
    
    updateDevChgsDev(#SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVTYPE_AUDIO_OUTPUT, nDevNo, \sLogicalDev) ; Added 9Mar2021 11.8.4ar
    
  EndWith
  
  setEditLogicalDevsDerivedFields()
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
    WEP_setCurrentAudDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevMap = #False
    If (sNewDevDesc <> sOldDevDesc) Or (grWEP\bInDisplayDevProd = #True)
      WEP_updateProdDev(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboVidAudPhysicalDev_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldDevDesc.s, sNewDevDesc.s
  Protected nPhysicalDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", cboVidAudPhysicalDev(" + Index + ")=" + GGT(WEP\cboVidAudPhysicalDev(Index)) + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  ; listAllDevMapsForDevChgs()
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
  debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  ; debugMsg(sProcName, "devmap before change:")
  ; listDevMap(@grMapsForDevChgs\aMap(nDevMapPtr), grMapsForDevChgs\aDev())
  
  ; check that nDevNo is within range of grMapsForDevChgs\aDev(nDevMapDevPtr) array, as it may be out of range after 'Undo Device Changes', for devices that were added
  If nDevNo <= grLicInfo\nMaxVidAudDevPerProd
    CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      sOldDevDesc = \sPhysicalDev
      sNewDevDesc = Trim(GGT(WEP\cboVidAudPhysicalDev(Index)))
      debugMsg(sProcName, "sOldDevDesc=" + sOldDevDesc + ", sNewDevDesc=" + sNewDevDesc)
      \sPhysicalDev = sNewDevDesc
      If Len(sNewDevDesc) > 0
        nPhysicalDevPtr = getPhysicalDevPtr(\nDevType, sNewDevDesc, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
      Else
        nPhysicalDevPtr = -1
      EndIf
      debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
      \nPhysicalDevPtr = nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        \bDefaultDev = gaVideoAudioDev(nPhysicalDevPtr)\bDefaultDev
      EndIf
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bDefaultDev=" + strB(\bDefaultDev))
    EndWith
    ED_fcVidAudPhysicalDev(Index)
  EndIf
  
  With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
    \nPhysicalDevPtr = nPhysicalDevPtr
    debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
  EndWith
  
  ;    Call debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
  setEditLogicalDevsDerivedFields()
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    debugMsg(sProcName, "calling WEP_setCurrentVidAudDevInfo(" + Index + ")")
    WEP_setCurrentVidAudDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevMap = #False
    If (sNewDevDesc <> sOldDevDesc) Or (grWEP\bInDisplayDevProd = #True)
      WEP_updateProdDev(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
  EndIf
  
  ; debugMsg(sProcName, "devmap after change:")
  ; listDevMap(@grMapsForDevChgs\aMap(nDevMapPtr), grMapsForDevChgs\aDev())
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboVidCapPhysicalDev_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldDevDesc.s, sNewDevDesc.s
  Protected nPhysicalDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", cboVidCapPhysicalDev[" + Index + "]=" + GGT(WEP\cboVidCapPhysicalDev(Index)) + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  nDevNo = Index
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_CAPTURE, nDevNo)
  debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  ; check that nDevNo is within range of grMapsForDevChgs\aDev(nDevMapDevPtr) array, as it may be out of range after 'Undo Device Changes', for devices that were added
  If nDevNo <= grLicInfo\nMaxVidCapDevPerProd
    CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      sOldDevDesc = \sPhysicalDev
      sNewDevDesc = Trim(GGT(WEP\cboVidCapPhysicalDev(Index)))
      debugMsg(sProcName, "sOldDevDesc=" + sOldDevDesc + ", sNewDevDesc=" + sNewDevDesc)
      \sPhysicalDev = sNewDevDesc
      If sNewDevDesc
        nPhysicalDevPtr = getPhysicalDevPtr(\nDevType, sNewDevDesc, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
      Else
        nPhysicalDevPtr = -1
      EndIf
      debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
      \nPhysicalDevPtr = nPhysicalDevPtr
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
    EndWith
    debugMsg(sProcName, "calling ED_fcVidCapPhysicalDev(" + Index + ")")
    ED_fcVidCapPhysicalDev(Index)
  EndIf
  
  With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
    \nPhysicalDevPtr = nPhysicalDevPtr
    debugMsg(sProcName, "grProdForDevChgs\aCaptureLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
  EndWith
  
  setEditLogicalDevsDerivedFields()
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    debugMsg(sProcName, "calling WEP_setCurrentVidCapDevInfo(" + Index + ")")
    WEP_setCurrentVidCapDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevMap = #False
    If (sNewDevDesc <> sOldDevDesc) Or (grWEP\bInDisplayDevProd = #True)
      WEP_updateProdDev(#SCS_DEVGRP_VIDEO_CAPTURE, nDevNo)
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboLivePhysicalDev_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected sOldDevDesc.s, sNewDevDesc.s
  Protected nPhysicalDevPtr
  Protected nDevMapPtr, nDevMapDevPtr, nDevData
  
  debugMsg(sProcName, #SCS_START + ", cboLivePhysicalDev(" + Index + ")=" + GGT(WEP\cboLivePhysicalDev(Index)) + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  ; listAllDevMapsForDevChgs()
  
  nDevNo = Index
  nDevData = getCurrentItemData(WEP\cboLivePhysicalDev(Index), -99)
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
  debugMsg(sProcName, "nDevNo=" + nDevNo + ", nDevData=" + nDevData + ", nDevMapPtr=" + nDevMapPtr + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  ; debugMsg(sProcName, "devmap before change:")
  ; listDevMap(@grMapsForDevChgs\aMap(nDevMapPtr), grMapsForDevChgs\aDev())
  
  ; check that nDevNo is within range of grMapsForDevChgs\aDev(nDevMapDevPtr) array, as it may be out of range after 'Undo Device Changes', for devices that were added
  If nDevNo <= grLicInfo\nMaxLiveDevPerProd
    CheckSubInRange(nDevMapDevPtr, ArraySize(grMapsForDevChgs\aDev()), "grMapsForDevChgs\aDev()")
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      sOldDevDesc = \sPhysicalDev
      sNewDevDesc = Trim(GGT(WEP\cboLivePhysicalDev(Index)))
      debugMsg(sProcName, "sOldDevDesc=" + sOldDevDesc + ", sNewDevDesc=" + sNewDevDesc)
      \sPhysicalDev = sNewDevDesc
      If sNewDevDesc
        nPhysicalDevPtr = getPhysicalDevPtr(\nDevType, sNewDevDesc, grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver, "", 0, \bDummy, \bDefaultDev)
      Else
        nPhysicalDevPtr = -1
      EndIf
      \nPhysicalDevPtr = nPhysicalDevPtr
      If nDevData = -2
        \bDummy = #True
        \nFirst0BasedInputChan = 0
        \nFirst1BasedInputChan = 1
        \s1BasedInputRange = "1"
      Else
        \bDummy = #False
      EndIf
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bDummy=" + strB(\bDummy) + ", \nFirst0BasedInputChan=" + \nFirst0BasedInputChan + ", \nFirst1BasedInputChan=" + \nFirst1BasedInputChan)
    EndWith
    If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO
      setDevTypeVariablesForSMS(@grMapsForDevChgs\aDev(nDevMapDevPtr)) ; Added 14Jun2021 11.8.5ai
    EndIf
    ED_fcLivePhysicalDev(Index)
  EndIf
  
  With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
    \nPhysicalDevPtr = nPhysicalDevPtr
    If nPhysicalDevPtr >= 0
      \nInputs = gaAudioDev(nPhysicalDevPtr)\nInputs
      \bNoDevice = gaAudioDev(nPhysicalDevPtr)\bNoDevice
      \bDummyDev = #False
    ElseIf nDevData = -2
      \nInputs = \nNrOfInputChans
      \bNoDevice = #False
      \bDummyDev= #True
    Else
      \nInputs = 0
      \bNoDevice = #False
      \bDummyDev = #False
    EndIf
    debugMsg(sProcName, "grProdForDevChgs\aLiveInputLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nInputs=" + \nInputs + ", \bDummyDev=" + strB(\bDummyDev))
  EndWith
  
  setEditLogicalDevsDerivedFields()
  
  If (grWEP\bInDisplayDevProd = #False) And (grWEP\bInDisplayDevMap = #False)
    ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
    debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
    WEP_setCurrentLiveDevInfo(Index)
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
  EndIf
  
  If grWEP\bInDisplayDevMap = #False
    debugMsg(sProcName, "sNewDevDesc=" + sNewDevDesc + ", sOldDevDesc=" + sOldDevDesc)
    If (sNewDevDesc <> sOldDevDesc) Or (grWEP\bInDisplayDevProd = #True)
      debugMsg(sProcName, "calling WEP_updateProdDev(#SCS_DEVGRP_LIVE_INPUT, " + nDevNo + ")")
      WEP_updateProdDev(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
    debugMsg(sProcName, "grProdForDevChgs\aLiveInputLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nInputs=" + \nInputs + ", \bDummyDev=" + strB(\bDummyDev))
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboInGrpLiveInput_Click(Index)
  PROCNAMEC()
  Protected nItemNo, nInputDev
  Protected nDevType, sLogicalDev.s
  Protected n
  Protected sMsg.s
  Protected nListIndex
  Protected bDuplicateFound
  Protected sInGrpInfo.s
  
  debugMsg(sProcName, #SCS_START + ", cboInGrpLiveInput(" + Index + ")=" + GGT(WEP\cboInGrpLiveInput(Index)) + ", bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  nItemNo = Index
  debugMsg(sProcName, "grWEP\nCurrentInGrpNo=" + grWEP\nCurrentInGrpNo + ", nItemNo=" + nItemNo)
  
  If grWEP\nCurrentInGrpNo < 0 Or grWEP\nCurrentInGrpNo > grLicInfo\nMaxInGrpPerProd
    debugMsg(sProcName, "exiting because grWEP\nCurrentInGrpNo=" + grWEP\nCurrentInGrpNo)
    ProcedureReturn
  EndIf
  
  If nItemNo < 0 Or nItemNo > grLicInfo\nMaxInGrpItemPerInGrp
    debugMsg(sProcName, "exiting because nItemNo=" + nItemNo)
    ProcedureReturn
  EndIf
  
  ; debugMsg0(sProcName, "grProdForDevChgs\aInGrps(" + grWEP\nCurrentInGrpNo + ")\nMaxInGrpItem=" + grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\nMaxInGrpItem)
  If nItemNo > grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\nMaxInGrpItem
    addOneInGrpLiveInput(@grProdForDevChgs, grWEP\nCurrentInGrpNo)
  EndIf
  
  With grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\aInGrpItem(nItemNo)
    nInputDev = getCurrentItemData(WEP\cboInGrpLiveInput(Index), -1)
    debugMsg(sProcName, "nInputDev=" + nInputDev)
    If nInputDev < 0
      \sInGrpItemLiveInput = ""
      \nInGrpItemDevType = #SCS_DEVTYPE_NONE
    Else
      sLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(nInputDev)\sLogicalDev
      debugMsg(sProcName, "sLogicalDev=" + sLogicalDev)
      nDevType = grProdForDevChgs\aLiveInputLogicalDevs(nInputDev)\nDevType
      ; check for duplicates
      For n = 0 To grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\nMaxInGrpItem
        If n <> Index
          If grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\aInGrpItem(n)\sInGrpItemLiveInput = sLogicalDev
            If grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)\aInGrpItem(n)\nInGrpItemDevType = nDevType
              bDuplicateFound = #True
              Break
            EndIf
          EndIf
        EndIf
      Next n
      If bDuplicateFound
        sMsg = LangPars("Errors", "InGrpDuplicateDev", sLogicalDev)
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ; reset this item
        nListIndex = 0
        If \nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT And \sInGrpItemLiveInput
          nListIndex = indexForComboBoxRow(WEP\cboInGrpLiveInput(Index), \sInGrpItemLiveInput, 0)
        EndIf
        SGS(WEP\cboInGrpLiveInput(Index), nListIndex)
        debugMsg(sProcName, "SGS(WEP\cboInGrpLiveInput(" + Index + "), " + nListIndex + ")")
        ProcedureReturn
      EndIf
      \sInGrpItemLiveInput = sLogicalDev
      \nInGrpItemDevType = nDevType
    EndIf
  EndWith
  
  If nItemNo < grProdForDevChgs\nMaxLiveInputLogicalDev
    debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_IN_GRP_LIVE_INPUT, " + Str(nItemNo+1) + ", " + grWEP\nCurrentInGrpNo + ")")
    ; NB 'input group live inputs' are the live inputs assigned to this input group
    WEP_addDeviceIfReqd(#SCS_DEVGRP_IN_GRP_LIVE_INPUT, nItemNo+1, grWEP\nCurrentInGrpNo)
  EndIf
  
  With grProdForDevChgs\aInGrps(grWEP\nCurrentInGrpNo)
    If \sInGrpName
      sInGrpInfo = WEP_buildInGrpInfo(grWEP\nCurrentInGrpNo)
    Else
      sInGrpInfo = ""
    EndIf
    debugMsg(sProcName, "grProdForDevChgs\aInGrps(" + grWEP\nCurrentInGrpNo + ")\sInGrpName=" + \sInGrpName + ", sInGrpInfo=" + sInGrpInfo)
    SGT(WEP\txtInGrpInfo(grWEP\nCurrentInGrpNo), sInGrpInfo)
  EndWith
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
  WEP_setDevChgsBtns()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboResetTOD_Click()
  PROCNAMEC()
  Protected u, nListIndex
  
  debugMsg(sProcName, "cboResetTOD\text=" + GGT(WEP\cboResetTOD))
  With grProd
    u = preChangeProdL(\nResetTOD, GGT(WEP\lblResetTOD))
    nListIndex = GGS(WEP\cboResetTOD)
    \nResetTOD = GetGadgetItemData(WEP\cboResetTOD, nListIndex)
    grCED\bProdChanged = #True
    postChangeProdL(u, \nResetTOD)
  EndWith
EndProcedure

Procedure WEP_cboDMXPhysDev_Click(Index)
  PROCNAMEC()
  Protected nItemData
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  Protected bEnableTest
  Protected nPrevPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentLightingDevMapDevPtr
    nDevNo = grWEP\nCurrentLightingDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      nItemData = getCurrentItemData(WEP\cboDMXPhysDev[Index])
      If \nPhysicalDevPtr <> nItemData
        debugMsg(sProcName, "calling DMX_closeDMXDevs()")
        DMX_closeDMXDevs()
      EndIf
      
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\nMaxDevFixture=" + \nMaxDevFixture)
      nPrevPhysicalDevPtr = \nPhysicalDevPtr
      \nPhysicalDevPtr = nItemData
      If nItemData >= 0
        \sPhysicalDev = gaDMXDevice(nItemData)\sName
        \sDMXSerial = gaDMXDevice(nItemData)\sSerial
        \nDMXSerial = gaDMXDevice(nItemData)\nSerial
        \nDMXPorts = gaDMXDevice(nItemData)\nDMXPorts
        \sDMXIpAddress = gaDMXDevice(nItemData)\sDMXIpAddress
        If grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)\nDMXPort > grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)\nDMXPorts
          \nDMXPort = 1
        EndIf
        \bDummy = gaDMXDevice(nItemData)\bDummy
        debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\sPhysicalDev=" + \sPhysicalDev +
                            ", \sDMXSerial=" + \sDMXSerial + ", \nDMXSerial=" + \nDMXSerial + ", \nDMXPorts=" + \nDMXPorts +
                            ", \bDummy=" + strB(\bDummy) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
      Else
        \sPhysicalDev = ""
        \sDMXSerial = ""
        \nDMXSerial = 0
        \nDMXPorts = 0
        \nDMXPort = 0
        \bDummy = #False
      EndIf
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\nDMXPorts=" + \nDMXPorts + ", \nDMXPort=" + \nDMXPort)
      
      ED_fcDMXPhysDev(Index, nCurrentDevMapDevPtr)
      
      grCED\bProdChanged = #True
      
      If Index = 0
        debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
        DMX_loadDMXControl(#True)
        debugMsg(sProcName, "calling DMX_openDMXDevs()")
        DMX_openDMXDevs()
        Delay(10)
        debugMsg(sProcName, "calling loadDevMapLightingFixturesIfReqd(@grProdForDevChgs, @grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + "))")
        loadDevMapLightingFixturesIfReqd(@grProdForDevChgs, @grMapsForDevChgs\aDev(nCurrentDevMapDevPtr))
        WEP_displayLightingPhysInfo(nDevNo)
        debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + nDevNo + ")")
        WEP_setCurrentLightingDevInfo(nDevNo)
      Else
        WEP_displayCuePhysInfo(nDevNo)
      EndIf
      
      If Index = 1  ; test added 16Jan2017 11.5.3 following error report from Simon Paulekuhn
        If \nPhysicalDevPtr >= 0
          If gaDMXDevice(\nPhysicalDevPtr)\bDummy = #False
            bEnableTest = #True
          EndIf
        EndIf
        setEnabled(WEP\btnTestDMX, bEnableTest)
      EndIf
      
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; Check for dmx devices using the same port (Universe), this uses a map and should handle more than the current 2 universes
; bSetWarningMessage: 0 = no message
; bSetWarningMessage: 1 = display a warning message on the status bar
; bSetWarningMessage; 2 = display a MessageRequester box with yes/No
; returns 1 If there is a conflict, 0 if no conflict
Procedure.a WEP_CheckForDMXPortDuplication(bSetWarningMessage.a=1)
  PROCNAMEC()
  Protected d, nDMXPortUsageError.i
  Protected NewMap gmDMXPortsInUse.a()
  Protected sDMXPort.s, sErrorMsg.s
  Protected nArraySize.i, nResult.i
  
  debugMsg(sProcName, #SCS_START + "")
  nArraySize = ArraySize(grMapsForDevChgs\aDev())
  
  For d = 0 To nArraySize
    If grMapsForDevChgs\aDev(d)\bExists And (grMapsForDevChgs\aDev(d)\sPhysicalDev = "Art-Net" Or grMapsForDevChgs\aDev(d)\sPhysicalDev = "sACN")
      debugMsg(sProcName, "Port for device: " + Str(d) + " " + grMapsForDevChgs\aDev(d)\sOrigPhysicalDev + " Port: " + Str(grMapsForDevChgs\aDev(d)\nDMXPort))
      gmDMXPortsInUse(Str(grMapsForDevChgs\aDev(d)\nDMXPort)) + 1
    EndIf
  Next 
  ResetMap(gmDMXPortsInUse())
            
  While NextMapElement(gmDMXPortsInUse())
    If gmDMXPortsInUse() > 1
      nDMXPortUsageError = 1
      sDMXPort = MapKey(gmDMXPortsInUse())
    EndIf
  Wend

  If bSetWarningMessage
    If nDMXPortUsageError
      sErrorMsg = LangPars("Errors", "PortConflict", sDMXPort)
      
      If bSetWarningMessage = 1
        WMN_setStatusField(sErrorMsg, #SCS_STATUS_ERROR)
      Else
        nResult = scsMessageRequester(Lang("Errors", "PortConflictMessageTitle"), Lang("Errors", "PortConflictMessage"), #PB_MessageRequester_Warning | #PB_MessageRequester_YesNo)
        If nResult = #PB_MessageRequester_Yes 
          nDMXPortUsageError = 0
        Else      
          nDMXPortUsageError = 1
        EndIf
      EndIf
    Else
      sErrorMsg = ""
      WMN_setStatusField(sErrorMsg, #SCS_STATUS_ERROR)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn nDMXPortUsageError
EndProcedure

Procedure WEP_cboDMXPort_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo, d
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentLightingDevMapDevPtr
    nDevNo = grWEP\nCurrentLightingDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      \nDMXPort = getCurrentItemData(WEP\cboDMXPort[Index])
      debugMsg(sProcName, "WEP\cboDMXPort[Index]=" + GGT(WEP\cboDMXPort[Index]) + ", grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\nDMXPort=" + \nDMXPort)
      grCED\bProdChanged = #True
      
      debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
      DMX_loadDMXControl(#True)
      
      If Index = 0
        debugMsg(sProcName, "calling WEP_displayLightingPhysInfo(" + nDevNo + ")")
        WEP_displayLightingPhysInfo(nDevNo)
      Else
        WEP_displayCuePhysInfo(nDevNo)
      EndIf
      
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
    WEP_CheckForDMXPortDuplication(#SCS_WEP_DMX_CONFLICT_STATUSBAR)
  EndIf
  debugMsg(sProcName, #SCS_END)
 
EndProcedure

Procedure WEP_btnDMXIPRefresh_Click()
  Protected n.i
  
  ClearGadgetItems(WEP\cboDMXIpAddress)                                         ; Added 17-Jan 2025 by Dee, fix for customers selecting incorrect IP's   
  addGadgetItemWithData(WEP\cboDMXIpAddress, "127.0.0.1", 0)                    ; The local loopback always exists                            
  GetAdaptersInfo()
  n = 1
  
  ForEach myIpAdaptor_l.MyIP_ADAPTER_INFO() 
    If myIpAdaptor_l()\ipAddress <> "0.0.0.0"                                  
      addGadgetItemWithData(WEP\cboDMXIpAddress,  myIpAdaptor_l()\ipAddress, n)
      n + 1
    EndIf
  Next
  
  If GetGadgetState(WEP\cboDMXIpAddress) = -1
    SetGadgetState(WEP\cboDMXIpAddress, 0)
  EndIf
  
EndProcedure  
  
Procedure WEP_cboDMXIpAddress_Click()
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  Protected nResult.i
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentLightingDevNo
  nCurrentDevMapDevPtr = grWEP\nCurrentLightingDevMapDevPtr
  
  If nCurrentDevMapDevPtr >= 0
    nResult = getCurrentItemData(WEP\cboDMXIpAddress)
    grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)\sDMXIpAddress = GetGadgetItemText(WEP\cboDMXIpAddress, nResult, 0)
    grCED\bProdChanged = #True
    
    debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
    DMX_loadDMXControl(#True)
    
    debugMsg(sProcName, "calling WEP_displayLightingPhysInfo(" + nDevNo + ")")
    WEP_displayLightingPhysInfo(nDevNo)
    
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_optDMXPref_Click(Index)
  PROCNAMEC()
  Protected nDMXPref
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  Select Index
    Case 0  ; DMX Out (Control Send)
;       nDevNo = grWEP\nCurrentCtrlDevNo
;       If nDevNo >= 0
;         With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
;           If GGS(WEP\optDMXOutPref[0])
;             nDMXPref = #SCS_DMX_NOTATION_0_255
;           Else
;             nDMXPref = #SCS_DMX_NOTATION_PERCENT
;           EndIf
;           If nDMXPref <> \nDMXOutPref
;             \nDMXOutPref = nDMXPref
;             grCED\bProdChanged = #True
;           EndIf
;         EndWith
;       EndIf
      
    Case 1  ; DMX In (Cue Control)
      nDevNo = grWEP\nCurrentCueDevNo
      If nDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          If GGS(WEP\optDMXInPref[0])
            nDMXPref = #SCS_DMX_NOTATION_0_255
          Else
            nDMXPref = #SCS_DMX_NOTATION_PERCENT
          EndIf
          If nDMXPref <> \nDMXInPref
            \nDMXInPref = nDMXPref
            grCED\bProdChanged = #True
          EndIf
        EndWith
        WEP_populateDMXTrgValue()
      EndIf
      
  EndSelect
  
  WEP_setDevChgsBtns()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_optDMXTrgCtrl_Click()
  PROCNAMEC()
  Protected nDMXTrgCtrl
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      If GGS(WEP\optDMXTrgCtrl[0])
        nDMXTrgCtrl = #SCS_DMX_TRG_CHG_UP_TO_VALUE
      ElseIf GGS(WEP\optDMXTrgCtrl[1])
        nDMXTrgCtrl = #SCS_DMX_TRG_CHG_FROM_ZERO
      Else
        nDMXTrgCtrl = #SCS_DMX_TRG_ANY_CHG
      EndIf
      If nDMXTrgCtrl <> \nDMXTrgCtrl
        \nDMXTrgCtrl = nDMXTrgCtrl
        grCED\bProdChanged = #True
      EndIf
      ED_fcDMXTrgCtrl()
    EndWith
    WEP_setDevChgsBtns()
  EndIf
EndProcedure

Procedure WEP_cboMidiOutPort_Click()
  PROCNAMEC()
  Protected nItemData
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grWEP\nCurrentCtrlDevMapDevPtr=" + grWEP\nCurrentCtrlDevMapDevPtr)
  If grWEP\nCurrentCtrlDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
      nItemData = getCurrentItemData(WEP\cboMidiOutPort)
      \nPhysicalDevPtr = nItemData
      \sPhysicalDev = gaMidiOutDevice(nItemData)\sName
      \bDummy = gaMidiOutDevice(nItemData)\bDummy
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboMidiInPort_Click()
  PROCNAMEC()
  Protected nItemData
  Protected sPhysicalDev.s
  Protected nDevMapPtr, nDevMapDevPtr
  Protected sErrorMsg.s
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  ; check that this device has not already been used
  debugMsg(sProcName, "grWEP\nCurrentCueDevMapDevPtr=" + grWEP\nCurrentCueDevMapDevPtr)
  If grWEP\nCurrentCueDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
      nItemData = getCurrentItemData(WEP\cboMidiInPort)
      sPhysicalDev = gaMidiInDevice(nItemData)\sName
      nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
      If nDevMapPtr >= 0
        nDevMapDevPtr = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
        While nDevMapDevPtr >= 0
          If nDevMapDevPtr <> grWEP\nCurrentCueDevMapDevPtr
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev = sPhysicalDev
              ; same name - now check that it's the same device type
              If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevGrp = \nDevGrp) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevType = \nDevType)
                If grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy = #False ; added \bDummy test 6Nov2015 11.4.1.2h (OK for dummy assignment to be duplicated)
                  sErrorMsg = LangPars("Errors", "DevAlreadyAssigned", sPhysicalDev)
                  debugMsg(sProcName, sErrorMsg)
                  ensureSplashNotOnTop()
                  scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
                  ; reset cboMidiInPort
                  nListIndex = indexForComboBoxRow(WEP\cboMidiInPort, \sPhysicalDev, -1)
                  SGS(WEP\cboMidiInPort, nListIndex)
                  ProcedureReturn
                EndIf
              EndIf
            EndIf
          EndIf
          nDevMapDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nNextDevIndex
        Wend
      EndIf
      \nPhysicalDevPtr = nItemData
      \sPhysicalDev = gaMidiInDevice(nItemData)\sName
      \nMidiInPhysicalDevPtr = nItemData
      \bDummy = gaMidiInDevice(nItemData)\bDummy
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  grWEP\bCueMidiInDevsChanged = #True ; used by TestMIDI
  debugMsg(sProcName, "grWEP\bCueMidiInDevsChanged=" + strB(grWEP\bCueMidiInDevsChanged))
  
EndProcedure

Procedure WEP_cboMidiThruOutPort_Click()
  PROCNAMEC()
  Protected nItemData
  
  If grWEP\nCurrentCtrlDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
      nItemData = getCurrentItemData(WEP\cboMidiThruOutPort)
      \nPhysicalDevPtr = nItemData
      \sPhysicalDev = gaMidiOutDevice(nItemData)\sName
      \nMidiOutPhysicalDevPtr = nItemData
      \bDummy = gaMidiOutDevice(nItemData)\bDummy
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboMidiThruInPort_Click()
  PROCNAMEC()
  Protected nItemData
  
  If grWEP\nCurrentCtrlDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
      nItemData = getCurrentItemData(WEP\cboMidiThruInPort)
      \nMidiThruInPhysicalDevPtr = nItemData
      \sMidiThruInPhysicalDev = gaMidiInDevice(nItemData)\sName
      \bMidiThruInDummy = gaMidiInDevice(nItemData)\bDummy
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboCtrlMethod_Click()
  PROCNAMEC()
  Protected nCtrlMethod
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START + ", grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nCtrlMethod = getCurrentItemData(WEP\cboCtrlMethod)
      debugMsg(sProcName, "nCtrlMethod=" + decodeCtrlMethod(nCtrlMethod))
      If nCtrlMethod <> \nCtrlMethod
        \nCtrlMethod = nCtrlMethod
        debugMsg(sProcName, "calling WEP_displaySpecialCueCmds()")
        WEP_displaySpecialCueCmds()
        debugMsg(sProcName, "calling ED_fcCtrlMethod(#False)")
        ED_fcCtrlMethod(#False)
        grCED\bProdChanged = #True
      EndIf
      debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
      debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboGoMacro_Click()
  PROCNAMEC()
  Protected nListIndex
  Protected nGoMacro
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nListIndex = GGS(WEP\cboGoMacro)
      If nListIndex < 0
        nGoMacro = -1
      Else
        nGoMacro = nListIndex
      EndIf
      If nGoMacro <> \nGoMacro
        \nGoMacro = nGoMacro
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboMidiCC_Click(Index)
  PROCNAMEC()
  Protected nListIndex, nCC, nDevNo, nCmdIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    nCmdIndex = GetGadgetData(WEP\cboMidiCommand[Index])
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nListIndex = GGS(WEP\cboMidiCC[Index])
      If nListIndex <= 0
        nCC = -1
      Else
        nCC = nListIndex - 1
      EndIf
      If nCC <> \aMidiCommand[nCmdIndex]\nCC
        \aMidiCommand[nCmdIndex]\nCC = nCC
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_cboMidiChannel_Click()
  PROCNAMEC()
  Protected nListIndex
  Protected nMidiChannel
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nListIndex = GGS(WEP\cboMidiChannel)
      nMidiChannel = nListIndex
      If nMidiChannel <> \nMidiChannel
        \nMidiChannel = nMidiChannel
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboMidiCommand_Click(Index)
  PROCNAMEC()
  Protected nCmd, nDevNo, nCmdIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    nCmdIndex = GetGadgetData(WEP\cboMidiCommand[Index])
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nCmd = getCurrentItemData(WEP\cboMidiCommand[Index])
      ; debugMsg0(sProcName, "\aMidiCommand[" + nCmdIndex + "]\nCmd=$" + hex2(\aMidiCommand[nCmdIndex]\nCmd))
      If nCmd <> \aMidiCommand[nCmdIndex]\nCmd
        \aMidiCommand[nCmdIndex]\nCmd = nCmd
        debugMsg(sProcName, "\aMidiCommand[" + nCmdIndex + "]\nCmd=$" + hex2(\aMidiCommand[nCmdIndex]\nCmd))
        ; Added 3Jan2025 11.10.6ce
        If nCmd = $E ; pitch bend
          Select nCmdIndex
            Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER, #SCS_MIDI_DMX_MASTER
              ; Clear CC and VV
              \aMidiCommand[nCmdIndex]\nCC = grMidiCommandDef\nCC
              \aMidiCommand[nCmdIndex]\nVV = grMidiCommandDef\nVV
          EndSelect
        EndIf
        ; End added 3Jan2025 11.10.6ce
        ; call WEP_displaySpecialCueCmds() so that CC etc can be displayed if necessary
        WEP_displaySpecialCueCmds()
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboMidiDevId_Click()
  PROCNAMEC()
  Protected nListIndex, nMscMmcMidiDevId, nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nListIndex = GGS(WEP\cboMidiDevId)
      nMscMmcMidiDevId = nListIndex - 1
      If nMscMmcMidiDevId <> \nMscMmcMidiDevId
        \nMscMmcMidiDevId = nMscMmcMidiDevId
        grCED\bProdChanged = #True
        grWEP\bCueMidiInDevsChanged = #True ; used by TestMIDI
        debugMsg(sProcName, "grWEP\bCueMidiInDevsChanged=" + strB(grWEP\bCueMidiInDevsChanged))
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboMidiVV_Click(Index)
  PROCNAMEC()
  Protected nVV, nDevNo, nCmdIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    nCmdIndex = GetGadgetData(WEP\cboMidiCommand[Index])
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nVV = getCurrentItemData(WEP\cboMidiVV[Index])
      If nVV <> \aMidiCommand[nCmdIndex]\nVV
        \aMidiCommand[nCmdIndex]\nVV = nVV
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboThresholdVV_Click()
  PROCNAMEC()
  Protected nVV, nDevNo, nCmdIndex = #SCS_MIDI_EXT_FADER
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nVV = getCurrentItemData(WEP\cboThresholdVV)
      If nVV <> \aMidiCommand[nCmdIndex]\nVV
        \aMidiCommand[nCmdIndex]\nVV = nVV
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_cboMSCCommandFormat_Click()
  PROCNAMEC()
  Protected nListIndex
  Protected nMscCommandFormat
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nListIndex = GGS(WEP\cboMSCCommandFormat)
      nMscCommandFormat = nListIndex - 1
      If nMscCommandFormat <> \nMscCommandFormat
        \nMscCommandFormat = nMscCommandFormat
        grCED\bProdChanged = #True
      EndIf
      WEP_displayMidiAssigns()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_displaySpecialCueCmds()
  PROCNAMEC()
  Protected d, m
  Protected nCmdNo, nCmdListIndex, nCCListIndex, nVVListIndex
  Protected bShowCC, bShowVV, bShowCCThreshold
  Protected nCtrlMethod, nThisCmd
  Protected bDisplayThis, nDisplayIndex, nInnerHeight
  Protected nTop, sNr.s, nOldGadgetList
  Protected rMidiCommand.tyMidiCommand
  
  debugMsg(sProcName, #SCS_START + ", grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
  
  If grWEP\nCurrentCueDevNo < 0
    debugMsg(sProcName, "exiting because grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
    ProcedureReturn
  EndIf
  
  nCtrlMethod = grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nCtrlMethod
  Select nCtrlMethod
    Case #SCS_CTRLMETHOD_NONE, #SCS_CTRLMETHOD_MTC, #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
      debugMsg(sProcName, "exiting because nCtrlMethod=" + decodeCtrlMethod(nCtrlMethod))
      ProcedureReturn
  EndSelect
  
  nDisplayIndex = -1
  For nCmdNo = 0 To gnMaxMidiCommand
    bShowCC = #False
    bShowVV = #False
    bShowCCThreshold = #False
    bDisplayThis = WEP_setDisplayThisForMidiCmd(nCmdNo)
    If bDisplayThis = #False
      Continue
    EndIf
    
    nDisplayIndex + 1
    ; debugMsg(sProcName, "nDisplayIndex=" + nDisplayIndex + ", nCmdNo=" + decodeMidiCommand(nCmdNo))
    
    rMidiCommand = grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\aMidiCommand[nCmdNo]
    With rMidiCommand ; grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\aMidiCommand[nCmdNo]
      
      SGT(WEP\lblCommand[nDisplayIndex], midiCmdDescrForCmdNo(nCmdNo))
      
      nCmdListIndex = indexForComboBoxData(WEP\cboMidiCommand[nDisplayIndex], \nCmd)
      SGS(WEP\cboMidiCommand[nDisplayIndex], nCmdListIndex)
      SetGadgetData(WEP\cboMidiCommand[nDisplayIndex], nCmdNo)
      setEnabled(WEP\cboMidiCommand[nDisplayIndex], \bModifiable)
      
      nThisCmd = \nCmd & $FF ; to allow $200B to be treated correctly as $B in the following tests
      If nCmdNo = #SCS_MIDI_EXT_FADER
        If (nThisCmd = $B)
          bShowCCThreshold = #True
        EndIf
        
      ElseIf (nCmdNo > #SCS_MIDI_LAST_SCS_CUE_RELATED)
        If (nThisCmd >= $8 And nThisCmd <= $D) ; Changed $E to $D 2Jan2024 11.10.6cd
          bShowCC = #True
        EndIf
        ; Added 2Jan2025 11.10.6cd
        If (nThisCmd = $E) ; pitch bend
          Select nCmdNo
            Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER, #SCS_MIDI_DMX_MASTER
              ; CC (actually LSB) not to be shown
            Default
              bShowCC = #True
          EndSelect
        EndIf
        ; End added 2Jan2025 11.10.6cd
        If (nThisCmd = $A Or nThisCmd = $B)
          Select nCmdNo
            Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_OPEN_FAV_FILE, #SCS_MIDI_SET_HOTKEY_BANK,
                 #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER,
                 #SCS_MIDI_DMX_MASTER, #SCS_MIDI_CUE_MARKER_PREV, #SCS_MIDI_CUE_MARKER_NEXT
              ; VV not to be shown
            Default
              bShowVV = #True
          EndSelect
        EndIf
        
      Else
        ; If (nThisCmd = $B)
        If (\nCmd = $B)
          bShowCC = #True
        EndIf
      EndIf
      
      ; debugMsg0(sProcName, "bShowCC=" + strB(bShowCC) + ", bShowVV=" + strB(bShowVV) + ", bShowCCThreshold=" + strB(bShowCCThreshold) + ", IsGadget(WEP\cboThresholdVV)=" + IsGadget(WEP\cboThresholdVV))
      
      If nCmdNo = #SCS_MIDI_EXT_FADER
        If IsGadget(WEP\cboThresholdVV)
          If bShowCCThreshold
            WEP_populateThresholdVVIfReqd(WEP\cboThresholdVV)
            nVVListIndex = indexForComboBoxData(WEP\cboThresholdVV, \nVV, 0)
            If GGS(WEP\cboThresholdVV) <> nVVListIndex
              SGS(WEP\cboThresholdVV, nVVListIndex)
            EndIf
            setVisible(WEP\lblThresholdVV, #True)
            setVisible(WEP\cboThresholdVV, #True)
            setEnabled(WEP\cboThresholdVV, \bModifiable)
          Else
            setVisible(WEP\lblThresholdVV, #False)
            setVisible(WEP\cboThresholdVV, #False)
            setEnabled(WEP\cboThresholdVV, #False)
          EndIf
        EndIf
      EndIf
      
      If bShowCC
        ClearGadgetItems(WEP\cboMidiCC[nDisplayIndex])
        AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, #SCS_BLANK_CBO_ENTRY)
        If (nCtrlMethod = #SCS_CTRLMETHOD_PC128) And (nThisCmd = $C)   ; $C = program change
          For m = 1 To 128
            AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, Trim(Str(m)))
          Next m
        Else
          For m = 0 To 127
            AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, Trim(Str(m)))
          Next m
        EndIf
      EndIf
      
      If bShowCC
        SGT(WEP\lblCC[nDisplayIndex], midiCCAbbrForCmd(nThisCmd, nCmdNo))
        setVisible(WEP\lblCC[nDisplayIndex], #True)
        nCCListIndex = indexForComboBoxRow(WEP\cboMidiCC[nDisplayIndex], Trim(Str(\nCC)))
        If GGS(WEP\cboMidiCC[nDisplayIndex]) <> nCCListIndex
          SGS(WEP\cboMidiCC[nDisplayIndex], nCCListIndex)
        EndIf
        scsToolTip(WEP\cboMidiCC[nDisplayIndex], midiCCDescrForCmd(nThisCmd))
        setVisible(WEP\cboMidiCC[nDisplayIndex], #True)
        setEnabled(WEP\cboMidiCC[nDisplayIndex], \bModifiable)
      ElseIf IsGadget(WEP\cboMidiCC[nDisplayIndex])
        SGT(WEP\lblCC[nDisplayIndex], "")
        setVisible(WEP\lblCC[nDisplayIndex], #False)
        \nCC = -1
        nCCListIndex = 0
        If GGS(WEP\cboMidiCC[nDisplayIndex]) <> nCCListIndex
          SGS(WEP\cboMidiCC[nDisplayIndex], nCCListIndex)
        EndIf
        scsToolTip(WEP\lblCC[nDisplayIndex], "")
        setVisible(WEP\cboMidiCC[nDisplayIndex], #False)
        setEnabled(WEP\cboMidiCC[nDisplayIndex], #False)
      EndIf
      
      If bShowVV
        WEP_populateMidiVVIfReqd(WEP\cboMidiVV[nDisplayIndex])
        nVVListIndex = indexForComboBoxData(WEP\cboMidiVV[nDisplayIndex], \nVV)
        If GGS(WEP\cboMidiVV[nDisplayIndex]) <> nVVListIndex
          SGS(WEP\cboMidiVV[nDisplayIndex], nVVListIndex)
        EndIf
        scsToolTip(WEP\cboMidiVV[nDisplayIndex], midiVVDescrForCmd(nThisCmd))
        setVisible(WEP\cboMidiVV[nDisplayIndex], #True)
        setEnabled(WEP\cboMidiVV[nDisplayIndex], \bModifiable)
      ElseIf nCmdNo <> #SCS_MIDI_EXT_FADER And IsGadget(WEP\cboMidiVV[nDisplayIndex]) ; Changed 6Jun2022
        WEP_populateMidiVVIfReqd(WEP\cboMidiVV[nDisplayIndex])
        \nVV = -1
        nVVListIndex = 0
        If GGS(WEP\cboMidiVV[nDisplayIndex]) <> nVVListIndex
          SGS(WEP\cboMidiVV[nDisplayIndex], nVVListIndex)
        EndIf
        setVisible(WEP\cboMidiVV[nDisplayIndex], #False)
        setEnabled(WEP\cboMidiVV[nDisplayIndex], #False)
      ElseIf nCmdNo = #SCS_MIDI_EXT_FADER ; Added 6Jun2022
        setVisible(WEP\cboMidiVV[nDisplayIndex], #False)
        setEnabled(WEP\cboMidiVV[nDisplayIndex], #False)
      EndIf
      
    EndWith
  Next nCmdNo
  
  nInnerHeight = (nDisplayIndex + 1) * 21
  If GetGadgetAttribute(WEP\scaMidiSpecial, #PB_ScrollArea_InnerHeight) <> nInnerHeight
    SetGadgetAttribute(WEP\scaMidiSpecial, #PB_ScrollArea_InnerHeight, nInnerHeight)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayX32SpecialCueCmds(bForceReload=#False)
  PROCNAMEC()
  Protected n
  Protected nSet, nButton, nDataValue
  Protected sSet.s
  Protected sText.s
  Protected nCmdListIndex
  Protected nFirstButton, nLastButton
  Static sButton.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sButton = LangSpace("OSC", "Button")
    bStaticLoaded = #True
  EndIf
  
  If grWEP\nCurrentCueDevNo < 0
    debugMsg(sProcName, "exiting because grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
    ProcedureReturn
  EndIf
  
  Select grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nCueNetworkRemoteDev
    Case #SCS_CC_NETWORK_REM_OSC_X32
      nFirstButton = 5
      nLastButton = 12
    Case #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
      nFirstButton = 1
      nLastButton = 8
  EndSelect
  
  For n = 0 To #SCS_MAX_X32_COMMAND
    If (CountGadgetItems(WEP\cboX32Command[n]) = 0) Or (bForceReload)
      ClearGadgetItems(WEP\cboX32Command[n])
      nDataValue = 0
      For nSet = 0 To 2
        sSet = Chr(Asc("A") + nSet)
        For nButton = nFirstButton To nLastButton
          nDataValue + 1
          sText = sButton + sSet + "-" + Str(nButton)
          addGadgetItemWithData(WEP\cboX32Command[n], sText, nDataValue)
        Next nButton
      Next nSet
    EndIf
    
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\aX32Command[n]
      SGT(WEP\lblX32Command[n], X32CmdDescrForCmdNo(n))
      nCmdListIndex = indexForComboBoxData(WEP\cboX32Command[n], \nX32Button)
      SGS(WEP\cboX32Command[n], nCmdListIndex)
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboRS232Port_Click(Index)
  PROCNAMEC()
  Protected nItemData
  Protected nCurrentDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
  EndIf
  
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      nItemData = getCurrentItemData(gnEventGadgetNo) ; must use original gadget no.
      \nPhysicalDevPtr = nItemData
      \sPhysicalDev = gaRS232Control(nItemData)\sRS232PortAddress
      \bDummy = gaRS232Control(nItemData)\bDummy
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\sPhysicalDev=" + \sPhysicalDev + ", \bDummy=" + strB(\bDummy))
    EndWith
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboRS232BaudRate_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232BaudRate = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232BaudRate = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()

  EndIf
  
EndProcedure

Procedure WEP_cboRS232DataBits_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232DataBits = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232DataBits = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboRS232StopBits_Click(Index)
  PROCNAMEC()
  Protected nItemData
  Protected fRS232StopBits.f
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  nItemData = getCurrentItemData(gnEventGadgetNo)
  Select nItemData
    Case 10
      fRS232StopBits = 1
    Case 15
      fRS232StopBits = 1.5
    Case 20
      fRS232StopBits = 2
  EndSelect
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\fRS232StopBits = fRS232StopBits
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\fRS232StopBits = fRS232StopBits
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboRS232Parity_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232Parity = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232Parity = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboRS232Handshaking_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  debugMsg(sProcName, "nDevNo=" + nDevNo)
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232Handshaking = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232Handshaking = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()

  EndIf
  
EndProcedure

Procedure WEP_cboRS232RTSEnable_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232RTSEnable = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232RTSEnable = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboRS232DTREnable_Click(Index)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nRS232DTREnable = getCurrentItemData(gnEventGadgetNo)
        
      Case #SCS_DEVGRP_CUE_CTRL
        grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nRS232DTREnable = getCurrentItemData(gnEventGadgetNo)
        
    EndSelect
    grCED\bProdChanged = #True
    
    WEP_setRS232Buttons(nCurrentDevMapDevPtr, Index)
    If Index = 0
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    Else
      WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboCtrlMidiRemoteDev_Click()
  PROCNAMEC()
  Protected nDevNo, sPrevDevCode.s, nNewRemDevId, sNewDevCode.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      sPrevDevCode = \sCtrlMidiRemoteDevCode
      nNewRemDevId = getCurrentItemData(WEP\cboCtrlMidiRemoteDev)
      sNewDevCode = CSRD_GetDevCodeForRemDevId(nNewRemDevId)
      debugMsg(sProcName, "nNewRemDevId=" + nNewRemDevId + ", sNewDevCode=" + sNewDevCode)
      If sNewDevCode <> sPrevDevCode
        \sCtrlMidiRemoteDevCode = sNewDevCode
        \nCtrlMidiRemDevId = nNewRemDevId
        If nNewRemDevId >= 0
          \nCtrlMidiChannel = CSRD_GetDfltMidiChanForRemDevId(nNewRemDevId)
        EndIf
        debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\sCtrlMidiRemoteDevCode=" + \sCtrlMidiRemoteDevCode + ", \nCtrlMidiRemDevId=" + \nCtrlMidiRemDevId + ", \nCtrlMidiChannel=" + \nCtrlMidiChannel)
        ED_fcCtrlMidiRemoteDevCode(sPrevDevCode)
      EndIf
      ; debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboCtrlMidiChannel_Click()
  PROCNAMEC()
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \nCtrlMidiChannel = getCurrentItemData(WEP\cboCtrlMidiChannel)
      debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\nCtrlMidiChannel=" + \nCtrlMidiChannel)
      ; debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboOSCVersion_Click()
  PROCNAMEC()
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \nOSCVersion = getCurrentItemData(WEP\cboOSCVersion[0])
      debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
      debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboCtrlNetworkRemoteDev_Click()
  PROCNAMEC()
  Protected nDevNo, nCtrlNetworkRemoteDev
  Protected nPrevCtrlNetworkRemoteDev
  Protected sLogicalDevNew.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      nPrevCtrlNetworkRemoteDev = \nCtrlNetworkRemoteDev
      nCtrlNetworkRemoteDev = getCurrentItemData(WEP\cboCtrlNetworkRemoteDev)
      If \nCtrlNetworkRemoteDev <> nCtrlNetworkRemoteDev
        \nCtrlNetworkRemoteDev = nCtrlNetworkRemoteDev
        sLogicalDevNew = WEP_makeNewCtrlLogicalDev(nDevNo)
        ED_fcCtrlNetworkRemoteDev(nPrevCtrlNetworkRemoteDev)
        WEP_displayCtrlPhysInfo(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
      WEP_setDevChgsBtns()
      debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
      WEP_setRetryActivateBtn()
      
      If sLogicalDevNew
        If sLogicalDevNew <> \sLogicalDev
          SGT(WEP\txtCtrlLogicalDev(nDevNo), sLogicalDevNew)
          debugMsg(sProcName, "calling WEP_txtCtrlLogicalDev_Validate(" + nDevNo + ")")
          WEP_txtCtrlLogicalDev_Validate(nDevNo)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboCueNetworkRemoteDev_Click()
  PROCNAMEC()
  Protected nDevNo, nCueNetworkRemoteDev
  Protected nPrevCueNetworkRemoteDev
  Protected nSettingsHeight
  Protected bShowMsgFormatCombo
  Protected nTop
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nPrevCueNetworkRemoteDev = \nCueNetworkRemoteDev
      nCueNetworkRemoteDev = getCurrentItemData(WEP\cboCueNetworkRemoteDev)
      debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev) + ", nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(nCueNetworkRemoteDev))
      If \nCueNetworkRemoteDev <> nCueNetworkRemoteDev
        \nCueNetworkRemoteDev = nCueNetworkRemoteDev
        ED_fcCueNetworkRemoteDev(nPrevCueNetworkRemoteDev)
        Select \nCueNetworkRemoteDev
          Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
            WEP_displayX32SpecialCueCmds(#True)
            setVisible(WEP\cntX32Special, #True)
            nSettingsHeight = GadgetY(WEP\cntX32Special) - GadgetY(WEp\cntNetworkAssigns) - 5
          Default
            setVisible(WEP\cntX32Special, #False)
            nSettingsHeight = GadgetHeight(WEP\cntCueDevDetail) - GadgetY(WEP\cntNetworkAssigns) - 4
            bShowMsgFormatCombo = #True
        EndSelect
        ResizeGadget(WEP\cntNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSettingsHeight)
        ResizeGadget(WEP\frNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSettingsHeight)
        If bShowMsgFormatCombo
          ResizeGadget(WEP\edgNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, (nSettingsHeight-60))
          nTop = GadgetY(WEP\edgNetworkAssigns) + GadgetHeight(WEP\edgNetworkAssigns) + 4
          ResizeGadget(WEP\cboNetworkMsgFormat, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
          setVisible(WEP\cboNetworkMsgFormat, #True)
        Else
          ResizeGadget(WEP\edgNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, (nSettingsHeight-20))
          setVisible(WEP\cboNetworkMsgFormat, #False)
        EndIf
        debugMsg(sProcName, "calling WEP_displayNetworkAssigns(" + nDevNo + ")")
        WEP_displayNetworkAssigns(nDevNo)
        WEP_displayCuePhysInfo(nDevNo)
      EndIf
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_cboNetworkProtocol_Click(Index)
  PROCNAMEC()
  ; Index 0 = Control Send, 1 = Cue Control
  Protected nDevNo, nNetworkProtocol
  Protected nCurrentDevMapDevPtr
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If (nCurrentDevMapDevPtr >= 0) And (nDevNo >= 0)
    nNetworkProtocol = getCurrentItemData(WEP\cboNetworkProtocol[Index])
    If Index = 0
      ; control send
      If grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkProtocol <> nNetworkProtocol
        grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkProtocol = nNetworkProtocol
        If nNetworkProtocol = #SCS_NETWORK_PR_UDP
          SGT(WEP\txtCtrlSendDelay, Str(#SCS_NETWORK_DELAY_UDP))
        ElseIf grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_VMIX
          ; NB an email response from vMix on 20Sep2020 stated that "The vMix API does not need message boundaries to process messages"
          ; so therefore it is not necessary to impose a delay between consecutive messages.
          SGT(WEP\txtCtrlSendDelay, "0")
        Else
          SGT(WEP\txtCtrlSendDelay, Str(#SCS_NETWORK_DELAY_TCP))
        EndIf
        ED_fcNetworkRole() ; Added 9Jul2024 11.10.3as - will hide inter-message delay if UDP
      EndIf
    Else
      ; cue control
      grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkProtocol = nNetworkProtocol
    EndIf
    
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        gaNetworkControl(nPhysicalDevPtr)\nNetworkProtocol = nNetworkProtocol
        buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
      EndIf
    EndWith
    
    If Index = 0
      WEP_displayCtrlPhysInfo(nDevNo)
    Else
      WEP_displayCuePhysInfo(nDevNo)
    EndIf
    
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboNetworkRole_Click(Index)
  PROCNAMEC()
  Protected nDevNo, nNetworkRole
  Protected nCurrentDevMapDevPtr
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
    nDevNo = grWEP\nCurrentCtrlDevNo
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
    nDevNo = grWEP\nCurrentCueDevNo
  EndIf
  
  If (nCurrentDevMapDevPtr >= 0) And (nDevNo >= 0)
    nNetworkRole = getCurrentItemData(WEP\cboNetworkRole[Index])
    If Index = 0
      grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole = nNetworkRole
    Else
      grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole = nNetworkRole
    EndIf
    
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If (nPhysicalDevPtr < 0) And (gnMaxNetworkControl >= 0)
        nPhysicalDevPtr = 0
      EndIf
      If nPhysicalDevPtr >= 0
        ; gaNetworkControl(nPhysicalDevPtr) = grNetworkControlDef
        gaNetworkControl(nPhysicalDevPtr)\nNetworkRole = nNetworkRole
        Select nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT, #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            gaNetworkControl(nPhysicalDevPtr)\bNWDummy = #False
          Case #SCS_ROLE_DUMMY
            gaNetworkControl(nPhysicalDevPtr)\bNWDummy = #True
        EndSelect
        \bDummy = gaNetworkControl(nPhysicalDevPtr)\bNWDummy
        \sRemoteHost = gaNetworkControl(nPhysicalDevPtr)\sRemoteHost
        \nRemotePort = gaNetworkControl(nPhysicalDevPtr)\nRemotePort
        \nLocalPort = gaNetworkControl(nPhysicalDevPtr)\nLocalPort
        \nCtrlSendDelay = gaNetworkControl(nPhysicalDevPtr)\nCtrlSendDelay
        ED_fcNetworkRole()
        buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
        \nPhysicalDevPtr = nPhysicalDevPtr
        \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
        debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
      EndIf
    EndWith
    
    If Index = 0
      WEP_displayCtrlPhysInfo(nDevNo)
    Else
      WEP_displayCuePhysInfo(nDevNo)
    EndIf
    
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_cboNetworkMsgAction_Click(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nMsgAction
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[Index]
      nMsgAction = getCurrentItemData(WEP\cboNetworkMsgAction[Index])
      If nMsgAction <> \nMsgAction
        \nMsgAction = nMsgAction
        ED_fcNetworkMsgAction(Index)
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_cboNetworkMsgFormat_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected nNetworkMsgFormat
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nNetworkMsgFormat = getCurrentItemData(WEP\cboNetworkMsgFormat)
      If nNetworkMsgFormat <> \nNetworkMsgFormat
        \nNetworkMsgFormat = nNetworkMsgFormat
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  WEP_displayNetworkDetails()
  
EndProcedure

Procedure WEP_chkGetRemDevScribbleStripNames_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected bGetRemDevScribbleStripNames
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      bGetRemDevScribbleStripNames = getOwnState(WEP\chkGetRemDevScribbleStripNames)
      If bGetRemDevScribbleStripNames <> \bGetRemDevScribbleStripNames
        \bGetRemDevScribbleStripNames = bGetRemDevScribbleStripNames
        grCED\bProdChanged = #True
        If \bGetRemDevScribbleStripNames
          setEnabled(WEP\cboDelayBeforeReloadNames, #True)
        Else
          setEnabled(WEP\cboDelayBeforeReloadNames, #False)
        EndIf
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_cboDelayBeforeReloadNames_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected nDelayBeforeReloadNames
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      nDelayBeforeReloadNames = getCurrentItemData(WEP\cboDelayBeforeReloadNames)
      If nDelayBeforeReloadNames <> \nDelayBeforeReloadNames
        \nDelayBeforeReloadNames = nDelayBeforeReloadNames
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_chkNetworkReplyMsgAddCR_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected bReplyMsgAddCR
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      bReplyMsgAddCR = getOwnState(WEP\chkNetworkReplyMsgAddCR)
      If bReplyMsgAddCR <> \bReplyMsgAddCR
        \bReplyMsgAddCR = bReplyMsgAddCR
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_chkNetworkReplyMsgAddLF_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected bReplyMsgAddLF
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      bReplyMsgAddLF = getOwnState(WEP\chkNetworkReplyMsgAddLF)
      If bReplyMsgAddLF <> \bReplyMsgAddLF
        \bReplyMsgAddLF = bReplyMsgAddLF
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_txtNetworkReceiveMsg_Validate(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected n
  Protected nMaxMsgResponse
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[Index]
      \sReceiveMsg = GGT(WEP\txtNetworkReceiveMsg[Index])
      \sComparisonMsg = makeComparisonMsg(\sReceiveMsg)
    EndWith
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      nMaxMsgResponse = -1
      For n = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
        If \aMsgResponse[n]\sReceiveMsg
          nMaxMsgResponse = n
        EndIf
      Next n
      \nMaxMsgResponse = nMaxMsgResponse
    EndWith    
    WEP_setDevChgsBtns()
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtNetworkReplyMsg_Validate(Index)
  PROCNAMEC()
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[Index]
      \sReplyMsg = GGT(WEP\txtNetworkReplyMsg[Index])
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_cboVisualWarningTime_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "cboVisualWarningTime=" + GGT(WEP\cboVisualWarningTime))
  With grProd
    u = preChangeProdL(\nVisualWarningTime, GGT(WEP\lblVisualWarningTime))
    \nVisualWarningTime = getCurrentItemData(WEP\cboVisualWarningTime)
    postChangeProdL(u, \nVisualWarningTime)
    grCED\bProdChanged = #True
  EndWith
EndProcedure

Procedure WEP_cboVisualWarningFormat_Click()
  PROCNAMEC()
  Protected u
  
  With grProd
    u = preChangeProdL(\nVisualWarningFormat, GGT(WEP\lblVisualWarningFormat))
    \nVisualWarningFormat = getCurrentItemData(WEP\cboVisualWarningFormat)
    grCED\bProdChanged = #True
    postChangeProdL(u, \nVisualWarningFormat)
  EndWith
EndProcedure

Procedure WEP_chkAutoInclude_Click()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      \bAutoInclude = getOwnState(WEP\chkAutoInclude)
      ED_fcAutoInclude()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure WEP_chkVidAudAutoInclude_Click()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      \bAutoInclude = getOwnState(WEP\chkVidAudAutoInclude)
      ED_fcVidAudAutoInclude()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure WEP_chkVidCapAutoInclude_Click()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidCapDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
      \bAutoInclude = getOwnState(WEP\chkVidCapAutoInclude)
      ED_fcVidCapAutoInclude()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure WEP_chkForLTC_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected n
  Protected bOldForLTC, bNewForLTC, nFirstLTCCue, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      bOldForLTC = \bForLTC
      bNewForLTC = getOwnState(WEP\chkForLTC)
      If (bOldForLTC) And (bNewForLTC = #False)
        ; user has cleared the checkbox
        nFirstLTCCue = getFirstLTCCue()
        If nFirstLTCCue >= 0
          sErrorMsg = LangPars("Errors", "CannotClearMTCLTC", getOwnText(WEP\chkForLTC), getCueLabel(nFirstLTCCue))
          ensureSplashNotOnTop()
          scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
          setOwnState(WEP\chkForLTC, bOldForLTC)
          ProcedureReturn
        EndIf
      EndIf
      \bForLTC = bNewForLTC ; Added 10Apr2021 11.8.4.2ad following bug reported by Dmitriy Velikanov
      debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + nDevNo + ")\bForLTC=" + strB(\bForLTC))
      If \bForLTC
        ; this device marked for LTC, so clear any other device marked for LTC
        For n = 0 To grProdForDevChgs\nMaxAudioLogicalDev
          If n <> nDevNo
            grProdForDevChgs\aAudioLogicalDevs(n)\bForLTC = #False
          EndIf
        Next n
      EndIf
      grCED\bProdChanged = #True
      grCED\bProdForLTCChanged = #True
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_chkForMTC_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected n
  Protected bOldForMTC, bNewForMTC, nFirstMTCCue, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      bOldForMTC = \bCtrlMidiForMTC
      bNewForMTC = getOwnState(WEP\chkForMTC)
      If (bOldForMTC) And (bNewForMTC = #False)
        ; user has cleared the checkbox
        nFirstMTCCue = getFirstMTCCue()
        If nFirstMTCCue >= 0
          sErrorMsg = LangPars("Errors", "CannotClearMTCLTC", getOwnText(WEP\chkForMTC), getCueLabel(nFirstMTCCue))
          ensureSplashNotOnTop()
          scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
          setOwnState(WEP\chkForMTC, bOldForMTC)
          ProcedureReturn
        EndIf
      EndIf
      \bCtrlMidiForMTC = bNewForMTC
      If \bCtrlMidiForMTC
        ; this device marked for MTC, so clear any other device marked for MTC
        For n = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
          If n <> nDevNo
            grProdForDevChgs\aCtrlSendLogicalDevs(n)\bCtrlMidiForMTC = #False
          EndIf
        Next n
      EndIf
      grCED\bProdChanged = #True
      grCED\bProdForMTCChanged = #True
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\bCtrlMidiForMTC=" + strB(grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bCtrlMidiForMTC))
  
EndProcedure

Procedure WEP_chkInputForLTC_Click()
  PROCNAMEC()
  Protected nDevNo
  Protected n
  Protected bOldForLTC, bNewForLTC, nFirstLTCCue, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentLiveDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
      bOldForLTC = \bInputForLTC
      bNewForLTC = getOwnState(WEP\chkInputForLTC)
      If (bOldForLTC) And (bNewForLTC = #False)
        ; user has cleared the checkbox
        nFirstLTCCue = getFirstLTCCue()
        If nFirstLTCCue >= 0
          sErrorMsg = LangPars("Errors", "CannotClearMTCLTC", getOwnText(WEP\chkInputForLTC), getCueLabel(nFirstLTCCue))
          ensureSplashNotOnTop()
          scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
          setOwnState(WEP\chkForLTC, bOldForLTC)
          ProcedureReturn
        EndIf
      EndIf
      \bInputForLTC = bNewForLTC
      If \bInputForLTC
        ; this device marked for LTC, so clear any other device marked for LTC
        For n = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
          If n <> nDevNo
            grProdForDevChgs\aLiveInputLogicalDevs(n)\bInputForLTC = #False
          EndIf
        Next n
      EndIf
      grCED\bProdChanged = #True
      grCED\bProdForLTCChanged = #True
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grProdForDevChgs\aLiveInputLogicalDevs(" + nDevNo + ")\bInputForLTC=" + strB(grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\bInputForLTC))
  
EndProcedure

Procedure WEP_chkM2TSkipEarlierCtrlMsgs_Click(nGadgetNo)
  PROCNAMEC()
  Protected nDevNo, n
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \bM2TSkipEarlierCtrlMsgs = getOwnState(nGadgetNo)
      grCED\bProdChanged = #True
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\bM2TSkipEarlierCtrlMsgs=" + strB(grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bM2TSkipEarlierCtrlMsgs))
  
EndProcedure

Procedure WEP_chkConnectWhenReqd_Click(nGadgetNo)
  ; Added 19Sep2022 11.9.6
  PROCNAMEC()
  Protected nDevNo, n
  Protected nDevMapDevPtr
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \bConnectWhenReqd = getOwnState(nGadgetNo)
      ; Added 1Feb2024 11.10.2ad
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev)
      ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
      If nDevMapDevPtr >= 0
        grMapsForDevChgs\aDev(nDevMapDevPtr)\bConnectWhenReqd = \bConnectWhenReqd
        ; Added 7Feb2024 11.10.2af
        nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
        If nPhysicalDevPtr >= 0
          gaNetworkControl(nPhysicalDevPtr)\bConnectWhenReqd = \bConnectWhenReqd
        EndIf
        ; End added 7Feb2024 11.10.2af
      EndIf
      ; End added 1Feb2024 11.10.2ad
      grCED\bProdChanged = #True
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\bConnectWhenReqd=" + strB(grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bConnectWhenReqd))
  
EndProcedure

Procedure WEP_chkLabelsFrozen_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "chkLabelsFrozen=" + strB(getOwnState(WEP\chkLabelsFrozen)))
  With grProd
    u = preChangeProdL(\bLabelsFrozen, getOwnText(WEP\chkLabelsFrozen))
    \bLabelsFrozen = getOwnState(WEP\chkLabelsFrozen)
    fcEditLabelsFrozen()
    grCED\bProdChanged = #True
    postChangeProdL(u, \bLabelsFrozen)
  EndWith
EndProcedure

Procedure WEP_chkEnableMidiCue_Click()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, "chkEnableMidiCue=" + strB(getOwnState(WEP\chkEnableMidiCue)))
  With grProd
    u = preChangeProdL(\bEnableMidiCue, getOwnText(WEP\chkEnableMidiCue))
    \bEnableMidiCue = getOwnState(WEP\chkEnableMidiCue)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bEnableMidiCue)
  EndWith
EndProcedure

Procedure WEP_chkLabelsUCase_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "chkLabelsUCase=" + strB(getOwnState(WEP\chkLabelsUCase)))
  With grProd
    u = preChangeProdL(\bLabelsUCase, getOwnText(WEP\chkLabelsUCase))
    \bLabelsUCase = getOwnState(WEP\chkLabelsUCase)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bLabelsUCase)
  EndWith
EndProcedure

Procedure WEP_chkPreLoadNextManualOnly_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "chkPreLoadNextManualOnly=" + strB(getOwnState(WEP\chkPreLoadNextManualOnly)))
  With grProd
    u = preChangeProdL(\bPreLoadNextManualOnly, getOwnText(WEP\chkPreLoadNextManualOnly))
    \bPreLoadNextManualOnly = getOwnState(WEP\chkPreLoadNextManualOnly)
    loadCueBrackets()
    grCED\bProdChanged = #True
    postChangeProdL(u, \bPreLoadNextManualOnly)
  EndWith
EndProcedure

Procedure WEP_chkNoPreLoadVideoHotkeys_Click()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, "chkNoPreLoadVideoHotkeys=" + strB(getOwnState(WEP\chkNoPreLoadVideoHotkeys)))
  With grProd
    u = preChangeProdL(\bNoPreLoadVideoHotkeys, getOwnText(WEP\chkNoPreLoadVideoHotkeys))
    \bNoPreLoadVideoHotkeys = getOwnState(WEP\chkNoPreLoadVideoHotkeys)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bNoPreLoadVideoHotkeys)
  EndWith
EndProcedure

Procedure WEP_chkAllowHKeyClick_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "chkAllowHKeyClick=" + strB(getOwnState(WEP\chkAllowHKeyClick)))
  With grProd
    u = preChangeProdL(\bAllowHKeyClick, getOwnText(WEP\chkAllowHKeyClick))
    \bAllowHKeyClick = getOwnState(WEP\chkAllowHKeyClick)
    loadCueBrackets()
    grCED\bProdChanged = #True
    postChangeProdL(u, \bAllowHKeyClick)
  EndWith
EndProcedure

Procedure WEP_chkDoNotCalcCueStartValues_Click()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, "chkDoNotCalcCueStartValues=" + strB(getOwnState(WEP\chkDoNotCalcCueStartValues)))
  With grProd
    u = preChangeProdL(\bDoNotCalcCueStartValues, getOwnText(WEP\chkDoNotCalcCueStartValues))
    \bDoNotCalcCueStartValues = getOwnState(WEP\chkDoNotCalcCueStartValues)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bDoNotCalcCueStartValues)
  EndWith
EndProcedure

Procedure WEP_cboMemoDispOptForPrim_Click()
  PROCNAMEC()
  Protected u, nMemoDispOptForPrim
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    nMemoDispOptForPrim = getCurrentItemData(WEP\cboMemoDispOptForPrim)
    If \nMemoDispOptForPrim <> nMemoDispOptForPrim
      u = preChangeProdL(\nMemoDispOptForPrim, GGT(WEP\lblMemoDispOptForPrim))
      \nMemoDispOptForPrim = nMemoDispOptForPrim
      debugMsg(sProcName, "\nMemoDispOptForPrim=" + decodeMemoDispOptForPrim(\nMemoDispOptForPrim))
      grCED\bProdChanged = #True
      postChangeProdL(u, \nMemoDispOptForPrim)
      debugMsg(sProcName, "calling WMN_displayOrHideMemoPanel()")
      WMN_displayOrHideMemoPanel()
      debugMsg(sProcName, "calling WMN_resizeGadgetsForSplitters()")
      WMN_resizeGadgetsForSplitters()
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_chkStopAllInclHib_Click()
  PROCNAMEC()
  Protected u

  debugMsg(sProcName, "chkStopAllInclHib=" + strB(getOwnState(WEP\chkStopAllInclHib)))
  With grProd
    u = preChangeProdL(\bStopAllInclHib, getOwnText(WEP\chkStopAllInclHib))
    \bStopAllInclHib = getOwnState(WEP\chkStopAllInclHib)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bStopAllInclHib)
  EndWith
EndProcedure

Procedure WEP_txtDefFadeInTime_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeInTime), GGT(WEP\lblDefFadeInTime), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeInTime) <> gsTmpString
    SGT(WEP\txtDefFadeInTime, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeInTime, GGT(WEP\lblDefFadeInTime))
    \nDefFadeInTime = stringToTime(GGT(WEP\txtDefFadeInTime))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeInTime)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefFadeOutTime_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeOutTime), GGT(WEP\lblDefFadeOutTime), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeOutTime) <> gsTmpString
    SGT(WEP\txtDefFadeOutTime, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeOutTime, GGT(WEP\lblDefFadeOutTime))
    \nDefFadeOutTime = stringToTime(GGT(WEP\txtDefFadeOutTime))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeOutTime)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefFadeInTimeA_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeInTimeA), GGT(WEP\lblDefFadeInTimeA), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeInTimeA) <> gsTmpString
    SGT(WEP\txtDefFadeInTimeA, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeInTimeA, GGT(WEP\lblDefFadeInTimeA))
    \nDefFadeInTimeA = stringToTime(GGT(WEP\txtDefFadeInTimeA))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeInTimeA)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefFadeOutTimeA_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeOutTimeA), GGT(WEP\lblDefFadeOutTimeA), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeOutTimeA) <> gsTmpString
    SGT(WEP\txtDefFadeOutTimeA, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeOutTimeA, GGT(WEP\lblDefFadeOutTimeA))
    \nDefFadeOutTimeA = stringToTime(GGT(WEP\txtDefFadeOutTimeA))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeOutTimeA)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefDisplayTimeA_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefDisplayTimeA), GGT(WEP\lblDefDisplayTimeA), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefDisplayTimeA) <> gsTmpString
    SGT(WEP\txtDefDisplayTimeA, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefDisplayTimeA, GGT(WEP\lblDefDisplayTimeA))
    \nDefDisplayTimeA = stringToTime(GGT(WEP\txtDefDisplayTimeA))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefDisplayTimeA)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_chkDefRepeatA_Click()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, "chkDefRepeatA=" + strB(getOwnState(WEP\chkDefRepeatA)))
  With grProd
    u = preChangeProdL(\bDefRepeatA, getOwnText(WEP\chkDefRepeatA))
    \bDefRepeatA = getOwnState(WEP\chkDefRepeatA)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bDefRepeatA)
  EndWith
EndProcedure

Procedure WEP_chkDefPauseAtEndA_Click()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, "chkDefPauseAtEndA=" + strB(getOwnState(WEP\chkDefPauseAtEndA)))
  With grProd
    u = preChangeProdL(\bDefPauseAtEndA, getOwnText(WEP\chkDefPauseAtEndA))
    \bDefPauseAtEndA = getOwnState(WEP\chkDefPauseAtEndA)
    grCED\bProdChanged = #True
    postChangeProdL(u, \bDefPauseAtEndA)
  EndWith
EndProcedure

Procedure WEP_txtDefFadeInTimeI_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeInTimeI), GGT(WEP\lblDefFadeInTimeI), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeInTimeI) <> gsTmpString
    SGT(WEP\txtDefFadeInTimeI, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeInTimeI, GGT(WEP\lblDefFadeInTimeI))
    \nDefFadeInTimeI = stringToTime(GGT(WEP\txtDefFadeInTimeI))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeInTimeI)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefFadeOutTimeI_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefFadeOutTimeI), GGT(WEP\lblDefFadeOutTimeI), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefFadeOutTimeI) <> gsTmpString
    SGT(WEP\txtDefFadeOutTimeI, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefFadeOutTimeI, GGT(WEP\lblDefFadeOutTimeI))
    \nDefFadeOutTimeI = stringToTime(GGT(WEP\txtDefFadeOutTimeI))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefFadeOutTimeI)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefLoopXFadeTime_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefLoopXFadeTime), GGT(WEP\lblDefLoopXFadeTime), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefLoopXFadeTime) <> gsTmpString
    SGT(WEP\txtDefLoopXFadeTime, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefLoopXFadeTime, GGT(WEP\lblDefLoopXFadeTime))
    \nDefLoopXFadeTime = stringToTime(GGT(WEP\txtDefLoopXFadeTime))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefLoopXFadeTime)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefChaseSpeed_Validate()
  PROCNAMEC()
  Protected nDefChaseSpeed
  Protected u
  Protected sPrompt.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  sPrompt = GGT(WEP\lblDefChaseSpeed)
  
  nDefChaseSpeed = Val(Trim(GGT(WEP\txtDefChaseSpeed)))
  If (nDefChaseSpeed < 1) Or (nDefChaseSpeed > 480)
    sMsg = LangPars("Errors", "MustBeBetween", sPrompt, "1", "480")
    debugMsg(sProcName, sMsg)
    scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
    ProcedureReturn #False
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefChaseSpeed, GGT(WEP\lblDefChaseSpeed))
    \nDefChaseSpeed = nDefChaseSpeed
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefChaseSpeed)
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefDMXFadeTime_Validate()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeFieldD(GGT(WEP\txtDefDMXFadeTime), GGT(WEP\lblDefDMXFadeTime), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefDMXFadeTime) <> gsTmpString
    SGT(WEP\txtDefDMXFadeTime, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefDMXFadeTime, GGT(WEP\lblDefDMXFadeTime))
    \nDefDMXFadeTime = stringToTime(GGT(WEP\txtDefDMXFadeTime))
    grCED\bProdChanged = #True
    grCED\bProdDefDMXFadeTimeChanged = #True
    postChangeProdL(u, \nDefDMXFadeTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtDefSFRTimeOverride_Validate()
  PROCNAMEC()
  Protected u
  
  If validateTimeFieldT(GGT(WEP\txtDefSFRTimeOverride), GGT(WEP\lblDefSFRTimeOverride), #False, #False, 0, #True) = #False
    ProcedureReturn #False
  ElseIf GGT(WEP\txtDefSFRTimeOverride) <> gsTmpString
    SGT(WEP\txtDefSFRTimeOverride, gsTmpString)
  EndIf
  
  With grProd
    u = preChangeProdL(\nDefSFRTimeOverride, GGT(WEP\lblDefSFRTimeOverride))
    \nDefSFRTimeOverride = stringToTime(GGT(WEP\txtDefSFRTimeOverride))
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefSFRTimeOverride)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WEP_cboDefOutputScreen_Click()
  PROCNAMEC()
  Protected u
  
  With grProd
    u = preChangeProdL(\nDefOutputScreen, GGT(WEP\lblDefOutputScreen))
    \nDefOutputScreen = getCurrentItemData(WEP\cboDefOutputScreen)
    grCED\bProdChanged = #True
    postChangeProdL(u, \nDefOutputScreen)
  EndWith
EndProcedure

Procedure WEP_resetCurrentDataFields()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  With grWEP
    \nCurrentAudDevMapDevPtr = -1
    \nCurrentAudDevNo = -1
    \nCurrentAudDevType = #SCS_DEVTYPE_NONE
    \sCurrentAudDevName = ""
    
    \nCurrentVidAudDevMapDevPtr = -1
    \nCurrentVidAudDevNo = -1
    \nCurrentVidAudDevType = #SCS_DEVTYPE_NONE
    \sCurrentVidAudDevName = ""
    
    \nCurrentVidCapDevMapDevPtr = -1
    \nCurrentVidCapDevNo = -1
    \nCurrentVidCapDevType = #SCS_DEVTYPE_NONE
    \sCurrentVidCapDevName = ""
    
    \nCurrentLiveDevMapDevPtr = -1
    \nCurrentLiveDevNo = -1
    \nCurrentLiveDevType = #SCS_DEVTYPE_NONE
    \sCurrentLiveInputDevName = ""
    
    \nCurrentInGrpNo = -1
    
    \nCurrentFixTypeNo = -1
    
    \nCurrentLightingDevMapDevPtr = -1
    \nCurrentLightingDevNo = -1
    \nCurrentLightingDevType = #SCS_DEVTYPE_NONE
    \sCurrentLightingDevName = ""
    ; \nCurrentFixtureIndex = -1
    \bReloadFixtureTypesComboBox = #True ; Added 7Oct2024 11.10.6ag following bug reported by email from Martin Smith 4Oct2024
    \bReloadInGrpLiveInputs = #True
    
    \nCurrentCtrlDevMapDevPtr = -1
    \nCurrentCtrlDevNo = -1
    \nCurrentCtrlDevType = #SCS_DEVTYPE_NONE
    \sCurrentCtrlDevName = ""
    
    \nCurrentCueDevMapDevPtr = -1
    \nCurrentCueDevNo = -1
    \nCurrentCueDevType = #SCS_DEVTYPE_NONE
    \sCurrentCueDevName = ""
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_primeTabIfReqd(nProdTab)
  PROCNAMEC()
  Static Dim bProdTabPrimed(#SCS_PROD_TAB_LAST)
  Protected m, nOutputScreen
  
  With WEP
    If bProdTabPrimed(nProdTab) = #False
      Select nProdTab
        Case #SCS_PROD_TAB_GENERAL
          ClearGadgetItems(\cboCueLabelIncrement)
          AddGadgetItem(\cboCueLabelIncrement, -1, "1")
          AddGadgetItem(\cboCueLabelIncrement, -1, "2")
          AddGadgetItem(\cboCueLabelIncrement, -1, "3")
          AddGadgetItem(\cboCueLabelIncrement, -1, "4")
          AddGadgetItem(\cboCueLabelIncrement, -1, "5")
          AddGadgetItem(\cboCueLabelIncrement, -1, "10")
          AddGadgetItem(\cboCueLabelIncrement, -1, "20")
          AddGadgetItem(\cboCueLabelIncrement, -1, "50")
          AddGadgetItem(\cboCueLabelIncrement, -1, "100")
          AddGadgetItem(\cboCueLabelIncrement, -1, "1000")
          
          If IsGadget(\cboDefOutputScreen)
            ClearGadgetItems(\cboDefOutputScreen)
            For nOutputScreen = #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
              addGadgetItemWithData(\cboDefOutputScreen, Str(nOutputScreen), nOutputScreen)
            Next nOutputScreen
          EndIf
          
        Case #SCS_PROD_TAB_DEVS
        Case #SCS_PROD_TAB_AUD_DEVS        ; audio output devices (device group #SCS_DEVGRP_AUDIO_OUTPUT)
        Case #SCS_PROD_TAB_VIDEO_AUD_DEVS  ; video audio devices (device group #SCS_DEVGRP_VIDEO_AUDIO)
        Case #SCS_PROD_TAB_VIDEO_CAP_DEVS  ; video capture devices (device group #SCS_DEVGRP_VIDEO_CAPTURE)
        Case #SCS_PROD_TAB_LIVE_DEVS       ; live input devices (device group #SCS_DEVGRP_LIVE_INPUT)
        Case #SCS_PROD_TAB_IN_GRPS         ; input groups
        Case #SCS_PROD_TAB_SUB_GRPS        ; sub groups
        Case #SCS_PROD_TAB_FIX_TYPES       ; fixture types
        Case #SCS_PROD_TAB_LIGHTING_DEVS   ; lighting devices (device group #SCS_DEVGRP_LIGHT)
        Case #SCS_PROD_TAB_CTRL_DEVS       ; ctrl send devices (device group #SCS_DEVGRP_CTRL_SEND)
        Case #SCS_PROD_TAB_CUE_DEVS        ; cue control devices (device group #SCS_DEVGRP_CUE_CTRL)
        Case #SCS_PROD_TAB_TIME_PROFILES
        Case #SCS_PROD_TAB_RUN_TIME_SETTINGS
      EndSelect
      bProdTabPrimed(nProdTab) = #True
    EndIf ; EndIf bProdTabPrimed(nProdTab) = #False
    
  EndWith

EndProcedure

Procedure WEP_Form_Load()
  PROCNAMEC()
  Protected sResetTODTime.s
  Protected d, n, m
  Protected bDelayVisible
  Protected sMidiOut.s, sMidiThru.s, sRS232Out.s, sNetworkOut.s, sHTTPRequest.s
  Protected sMidiIn.s, sRS232In.s, sNetworkIn.s, sDMXIn.s
  Protected sVisualWarningText.s, sLimiterText.s
  Protected nLeft
  Protected nOutputScreen
  Protected nNewDevCount
  Protected sInfoMsg1.s
  
  debugMsg(sProcName, #SCS_START)
  
  setCurrWindowGlobals(#WED)
  
  If grCED\bProdCreated = #False
    grWEP\bCtrlRS232ComboBoxesPopulated = #False
    grWEP\bCtrlMidiOutComboBoxesPopulated = #False
    grWEP\bCtrlMidiThruComboBoxesPopulated = #False
    grWEP\bCtrlNetworkComboBoxesPopulated = #False
    grWEP\bCueRS232ComboBoxesPopulated = #False
    grWEP\bCueMidiInComboBoxesPopulated = #False
    grWEP\bCueNetworkComboBoxesPopulated = #False
    grWEP\bCueDMXComboBoxesPopulated = #False
    grWEP\nCurrentFixTypeNo = -1
    gnWEPFixtureCurrItem = -1
    gnWEPFixtureLastItem = -1
    createfmEditProd()
    grWEP\nDisplayedTab = -1
    grWEP\nDisplayedDevTab = -1
    If grLicInfo\nMaxCtrlSendDevPerProd >= 0    ; if < 0 then gadgets will not have been created
      grWEP\nCntMidiAssignsOriginalHeight = GadgetHeight(WEP\cntMidiAssigns)
      grWEP\nEdgMidiAssignsOriginalHeight = GadgetHeight(WEP\edgMidiAssigns)
      grWEP\nHeightChangeIfHideSpecial = GadgetHeight(WEP\cntMidiSpecial)
    EndIf
  EndIf
  
  With WEP
    gbEditProdFormLoaded = #True
    grWEP\bInValidate = #False
    
    debugMsg(sProcName, "calling WEP_resetCurrentDataFields()")
    WEP_resetCurrentDataFields()
    
    If gbClosingDown = #False
      sInfoMsg1 = Lang("WMI", "LoadingProdProps") + " (" + LangPars("Common", "Pass", "2") + ")"
      WMI_updateInfoMsg1(sInfoMsg1)
    EndIf
    
    ; INFO: General tab
    WMI_displayInfoMsg2(Lang("WEP","tbsGeneral"))
    ;{
    WEP_primeTabIfReqd(#SCS_PROD_TAB_GENERAL)
    ;}
    grWEP\nLoadProgress + 1
    If gbClosingDown = #False
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    
    ; INFO: Audio Output Devices tab
    ;{
    WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_AUDIO_OUTPUT])
    ;{
    createWEPAudDevs() ; create WEP gadgets for audio devices
    ClearGadgetItems(\cboAudioDriver)
    If gnDSDeviceCount > 0
      addGadgetItemWithData(\cboAudioDriver,decodeDriverL(#SCS_DRV_BASS_DS), #SCS_DRV_BASS_DS)
    EndIf
    If gnWASAPIDeviceCount > 0 And gbWasapiAvailable
      addGadgetItemWithData(\cboAudioDriver,decodeDriverL(#SCS_DRV_BASS_WASAPI),#SCS_DRV_BASS_WASAPI)
    EndIf
    If grLicInfo\bASIOAvailable
      If gnAsioDeviceCount > 0
        addGadgetItemWithData(\cboAudioDriver,decodeDriverL(#SCS_DRV_BASS_ASIO),#SCS_DRV_BASS_ASIO)
      EndIf
    EndIf
    If grLicInfo\bSMSAvailable
      If gnAsioDeviceCount > 0
        addGadgetItemWithData(\cboAudioDriver,decodeDriverL(#SCS_DRV_SMS_ASIO), #SCS_DRV_SMS_ASIO)
      EndIf
    EndIf
    ;}
    grWEP\nLoadProgress + 1
    WMI_setProgress(grWEP\nLoadProgress)
    ;}
    
    ; INFO: Video Audio Devices tab
    ;{
    If grLicInfo\nMaxVidAudDevPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_VIDEO_AUDIO])
      ;{
      createWEPVidAudDevs() ; create WEP gadgets for video audio devices
      ; \cboDfltVidAudTrim is populated here as it only needs to be populated once - it is not dependant on any other device property
      If IsGadget(\cboDfltVidAudTrim)
        ClearGadgetItems(\cboDfltVidAudTrim)
        addGadgetItemWithData(\cboDfltVidAudTrim, #SCS_ZERO_DBTRIM, 0)
        addGadgetItemWithData(\cboDfltVidAudTrim, "-10", -10)
        addGadgetItemWithData(\cboDfltVidAudTrim, "-20", -20)
        addGadgetItemWithData(\cboDfltVidAudTrim, "-30", -30)
        addGadgetItemWithData(\cboDfltVidAudTrim, "-40", -40)
        addGadgetItemWithData(\cboDfltVidAudTrim, "-50", -50)
      EndIf
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Video Capture Devices tab
    ;{
    debugMsg(sProcName, "grLicInfo\nMaxVidCapDevPerProd=" + grLicInfo\nMaxVidCapDevPerProd)
    If grLicInfo\nMaxVidCapDevPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_VIDEO_CAPTURE])
      ;{
      debugMsg(sProcName, "calling createWEPVidCapDevs()")
      createWEPVidCapDevs() ; create WEP gadgets for video capture devices
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Fixture Types tab
    ;{
    If grLicInfo\nMaxFixTypePerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_FIX_TYPE])
      ;{
      createWEPFixTypes()
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO Lighting Devices tab
    ;{
    If grLicInfo\nMaxLightingDevPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_LIGHTING])
      ;{
      createWEPLightingDevs() ; create WEP gadgets for lighting devices
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Ctrl Send Devices tab
    ;{
    If grLicInfo\nMaxCtrlSendDevPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_CTRL_SEND])
      ;{
      createWEPCtrlSendDevs() ; create WEP gadgets for control send devices
      If grLicInfo\bCSRDAvailable
        ClearGadgetItems(\cboCtrlMidiRemoteDev)
        addGadgetItemWithData(\cboCtrlMidiRemoteDev, Lang("MIDI", "AnyDev"), -1)
        For n = 0 To grCSRD\nMaxRemDev
          If grCSRD\aRemDev(n)\nCSRD_DevType = #SCS_DEVTYPE_CS_MIDI_OUT
            addGadgetItemWithData(\cboCtrlMidiRemoteDev, grCSRD\aRemDev(n)\sCSRD_DevName, grCSRD\aRemDev(n)\nCSRD_RemDevId)
          EndIf
        Next n
        setComboBoxWidth(\cboCtrlMidiRemoteDev)
        nLeft = GadgetX(\cboCtrlMidiRemoteDev) + GadgetWidth(\cboCtrlMidiRemoteDev) + 12
        ResizeGadget(\lblCtrlMidiChannel, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        nLeft + GadgetWidth(\lblCtrlMidiChannel) + gnGap
        ResizeGadget(\cboCtrlMidiChannel, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        ClearGadgetItems(\cboCtrlMidiChannel)
        For n = 1 To 16
          addGadgetItemWithData(\cboCtrlMidiChannel, Trim(Str(n)), n)
        Next n
      EndIf ; EndIf grLicInfo\bCSRDAvailable
      
      ClearGadgetItems(\cboCtrlNetworkRemoteDev)
      If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
        For n = 0 To #SCS_MAX_CS_NETWORK_REM_DEV
          addGadgetItemWithData(\cboCtrlNetworkRemoteDev, decodeCtrlNetworkRemoteDevL(n), n)
        Next n
        ; OSC Version
        setComboBoxWidth(\cboCtrlNetworkRemoteDev)
        ResizeGadget(\lblOSCVersion[0], GadgetX(\cboCtrlNetworkRemoteDev) + GadgetWidth(\cboCtrlNetworkRemoteDev) + gnGap2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\cboOSCVersion[0], GadgetX(\lblOSCVersion[0]) + GadgetWidth(\lblOSCVersion[0]) + gnGap, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        For n = 0 To #SCS_MAX_OSC_VER
          AddGadgetItemWithData(\cboOSCVersion[0], decodeOSCVersionL(n), n)
        Next n
        setComboBoxWidth(\cboOSCVersion[0])
        setVisible(\lblOSCVersion[0], #False)
        setVisible(\cboOSCVersion[0], #False)
      EndIf
      ClearGadgetItems(\cboNetworkProtocol[0])
      addGadgetItemWithData(\cboNetworkProtocol[0], "TCP", #SCS_NETWORK_PR_TCP)
      addGadgetItemWithData(\cboNetworkProtocol[0], "UDP", #SCS_NETWORK_PR_UDP)
      setComboBoxWidth(\cboNetworkProtocol[0])
      For n = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
        ClearGadgetItems(\cboNetworkMsgAction[n])
        If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
          addGadgetItemWithData(\cboNetworkMsgAction[n], "", #SCS_NETWORK_ACT_NOT_SET)
          addGadgetItemWithData(\cboNetworkMsgAction[n], decodeNetworkMsgActionL(#SCS_NETWORK_ACT_NONE), #SCS_NETWORK_ACT_NONE)
          addGadgetItemWithData(\cboNetworkMsgAction[n], decodeNetworkMsgActionL(#SCS_NETWORK_ACT_REPLY), #SCS_NETWORK_ACT_REPLY)
          addGadgetItemWithData(\cboNetworkMsgAction[n], decodeNetworkMsgActionL(#SCS_NETWORK_ACT_READY), #SCS_NETWORK_ACT_READY)
          addGadgetItemWithData(\cboNetworkMsgAction[n], decodeNetworkMsgActionL(#SCS_NETWORK_ACT_AUTHENTICATE), #SCS_NETWORK_ACT_AUTHENTICATE)
        EndIf
      Next n
      ClearGadgetItems(\cboDelayBeforeReloadNames)
      For n = 100 To 1000 Step 100
        addGadgetItemWithData(\cboDelayBeforeReloadNames, Str(n), n)
      Next n
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Cue Control Devices tab
    ;{
    If grLicInfo\nMaxCueCtrlDev >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_CUE_CTRL])
      ;{
      createWEPCueCtrlDevs() ; create WEP gadgets for cue control devices
      sMidiIn = decodeDevTypeL(#SCS_DEVTYPE_CC_MIDI_IN)
      sRS232In = decodeDevTypeL(#SCS_DEVTYPE_CC_RS232_IN)
      sNetworkIn = decodeDevTypeL(#SCS_DEVTYPE_CC_NETWORK_IN)
      sDMXIn = decodeDevTypeL(#SCS_DEVTYPE_CC_DMX_IN)
      ClearGadgetItems(\cboCueNetworkRemoteDev)
      If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
        For n = 0 To #SCS_MAX_CC_NETWORK_REM_DEV
          addGadgetItemWithData(\cboCueNetworkRemoteDev, decodeCueNetworkRemoteDevL(n), n)
        Next n
        setComboBoxWidth(\cboCueNetworkRemoteDev)
      EndIf
      ClearGadgetItems(\cboNetworkProtocol[1])
      addGadgetItemWithData(\cboNetworkProtocol[1], "TCP", #SCS_NETWORK_PR_TCP)
      addGadgetItemWithData(\cboNetworkProtocol[1], "UDP", #SCS_NETWORK_PR_UDP)
      setComboBoxWidth(\cboNetworkProtocol[1])
      For d = 0 To grProdForChecker\nMaxCueCtrlLogicalDevDisplay ; grLicInfo\nMaxCueCtrlDev
        If IsGadget(\cboCueDevType(d))
          ClearGadgetItems(\cboCueDevType(d))
          addGadgetItemWithData(\cboCueDevType(d), "", #SCS_DEVTYPE_NONE)
          addGadgetItemWithData(\cboCueDevType(d), sMidiIn, #SCS_DEVTYPE_CC_MIDI_IN)
          addGadgetItemWithData(\cboCueDevType(d), sRS232In, #SCS_DEVTYPE_CC_RS232_IN)
          If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
            addGadgetItemWithData(\cboCueDevType(d), sNetworkIn, #SCS_DEVTYPE_CC_NETWORK_IN)
            addGadgetItemWithData(\cboCueDevType(d), sDMXIn, #SCS_DEVTYPE_CC_DMX_IN)
          EndIf
        EndIf
      Next d
      ClearGadgetItems(\cboNetworkMsgFormat)
      addGadgetItemWithData(\cboNetworkMsgFormat, Lang("WEP", "MsgFormatASCII"), #SCS_NETWORK_MSG_ASCII)
      addGadgetItemWithData(\cboNetworkMsgFormat, Lang("WEP", "MsgFormatOSC"), #SCS_NETWORK_MSG_OSC)
      setComboBoxWidth(\cboNetworkMsgFormat)
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Live Input Devices tab
    ;{
    If grLicInfo\nMaxLiveDevPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_LIVE_INPUT])
      ;{
      createWEPLiveInputDevs() ; create WEP gadgets for live input devices
;       For d = 0 To grProdForDevChgs\nMaxLiveInputLogicalDevDisplay ; grLicInfo\nMaxLiveDevPerProd
;         If IsGadget(\cboNumInputChans(d))
;           ClearGadgetItems(\cboNumInputChans(d))
;           For n = 1 To 2  ; mono or stereo only for live inputs
;             AddGadgetItem(\cboNumInputChans(d), -1, decodeNumChans(n))
;           Next n
;         EndIf
;       Next d
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO: Input Groups 'Devices' tab
    ;{
    If grLicInfo\nMaxInGrpPerProd >= 0
      WMI_displayInfoMsg2(grText\sTextDevGrp[#SCS_DEVGRP_IN_GRP])
      ;{
      debugMsg(sProcName, "calling createWEPInputGroups()")
      createWEPInputGroups() ; create WEP gadgets for input group 'devices'
      debugMsg(sProcName, "calling createWEPInputGroupLiveInputs(0)")
      createWEPInputGroupLiveInputs(0)
      ;}
      grWEP\nLoadProgress + 1
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    ;}
    
    ; INFO Time Profiles tab
    ;{
    WMI_displayInfoMsg2(Lang("WEP", "tbsTimeProfiles"))
    ;{
    ; no action required in 'pass 2'
    ;}
    grWEP\nLoadProgress + 1
    WMI_setProgress(grWEP\nLoadProgress)
    ;}

    ; INFO Run Time Settings tab
    ;{
    WMI_displayInfoMsg2(Lang("WEP", "tbsRunTimeSettings"))
    ;{
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      ClearGadgetItems(\cboRunMode)
      addGadgetItemWithData(\cboRunMode, Lang("WEP", "cboRunMode0"), #SCS_RUN_MODE_LINEAR)
      addGadgetItemWithData(\cboRunMode, Lang("WEP", "cboRunMode1"), #SCS_RUN_MODE_NON_LINEAR_OPEN_ON_DEMAND)
      addGadgetItemWithData(\cboRunMode, Lang("WEP", "cboRunMode2"), #SCS_RUN_MODE_NON_LINEAR_PREOPEN_ALL)
      addGadgetItemWithData(\cboRunMode, Lang("WEP", "cboRunMode3"), #SCS_RUN_MODE_BOTH_OPEN_ON_DEMAND)
      addGadgetItemWithData(\cboRunMode, Lang("WEP", "cboRunMode4"), #SCS_RUN_MODE_BOTH_PREOPEN_ALL)
      setComboBoxWidth(\cboRunMode)
      setVisible(\lblRunMode, #True)
      setVisible(\cboRunMode, #True)
    Else
      setVisible(\lblRunMode, #False)
      setVisible(\cboRunMode, #False)
    EndIf
    
    ; populate cboVisualWarning
    sVisualWarningText = Lang("WEP", "cboVisualWarning")
    ClearGadgetItems(\cboVisualWarningTime)
    ; Note: all #SCS_VWT_... constants are negative, but count down times are positive
    addGadgetItemWithData(\cboVisualWarningTime, #SCS_BLANK_CBO_ENTRY, #SCS_VWT_NOT_SET)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "5"), 5000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "10"), 10000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "15"), 15000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "20"), 20000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "25"), 25000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "30"), 30000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "40"), 40000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "50"), 50000)
    addGadgetItemWithData(\cboVisualWarningTime, ReplaceString(sVisualWarningText, "$1", "60"), 60000)
    addGadgetItemWithData(\cboVisualWarningTime, Lang("WEP", "WholeCueDn"), #SCS_VWT_COUNT_DOWN_WHOLE_CUE)
    ; addGadgetItemWithData(\cboVisualWarningTime, Lang("WEP", "WholeCueUp"), #SCS_VWT_CUEPOS)
    addGadgetItemWithData(\cboVisualWarningTime, Lang("WEP", "CuePos"), #SCS_VWT_CUEPOS)
    addGadgetItemWithData(\cboVisualWarningTime, Lang("WEP", "CuePos+Offset"), #SCS_VWT_CUEPOS_PLUS_TIME_OFFSET)
    addGadgetItemWithData(\cboVisualWarningTime, Lang("WEP", "FilePos"), #SCS_VWT_FILEPOS)
    setComboBoxWidth(\cboVisualWarningTime)
    
    ; populate cboVisualWarningFormat
    ClearGadgetItems(\cboVisualWarningFormat)
    addGadgetItemWithData(\cboVisualWarningFormat, Lang("WEP", "cboVisualWarningFormatSecs"), #SCS_VWF_SECS)
    addGadgetItemWithData(\cboVisualWarningFormat, Lang("WEP", "cboVisualWarningFormatTime"), #SCS_VWF_TIME)
    addGadgetItemWithData(\cboVisualWarningFormat, Lang("WEP", "cboVisualWarningFormatHHMMSS"), #SCS_VWF_HHMMSS)
    setComboBoxWidth(\cboVisualWarningFormat)
    
    If IsGadget(\cboResetTOD)
      ; time profiles not available in lite
      ; populate cboResetTOD (data is time of day in seconds, or -1 for 'no reset')
      ClearGadgetItems(\cboResetTOD)
      addGadgetItemWithData(\cboResetTOD, Lang("WEP", "cboResetTODDefault"), -1)
      addGadgetItemWithData(\cboResetTOD, Lang("WEP", "cboResetTODMidnight"), 0)
      sResetTODTime = Lang("WEP", "cboResetTODTime")
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", "12:30"),  1800)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 1:00"),  3600)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 1:30"),  5400)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 2:00"),  7200)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 2:30"),  9000)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 3:00"), 10800)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 3:30"), 12600)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 4:00"), 14400)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 4:30"), 16200)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 5:00"), 18000)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 5:30"), 19800)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 6:00"), 21600)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 6:30"), 23400)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 7:00"), 25200)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 7:30"), 27000)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 8:00"), 28800)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 8:30"), 30600)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 9:00"), 32400)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 9:15"), 33300)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 9:30"), 34200)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 9:45"), 35100)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 10:00"), 36000)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 10:15"), 36900)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 10:30"), 37800)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 10:45"), 38700)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 11:00"), 39600)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 11:15"), 40500)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 11:30"), 41400)
      addGadgetItemWithData(\cboResetTOD, ReplaceString(sResetTODTime, "$1", " 11:45"), 42300)
    EndIf
    
    ClearGadgetItems(\cboFocusPoint)
    addGadgetItemWithData(\cboFocusPoint, Lang("WEP", "cboFocusPointManual"), #SCS_FOCUS_NEXT_MANUAL)
    addGadgetItemWithData(\cboFocusPoint, Lang("WEP", "cboFocusPointPlaying"), #SCS_FOCUS_LAST_PLAYING)
    setComboBoxWidth(\cboFocusPoint)
    
    If IsGadget(\cboMaxDBLevel)
      ClearGadgetItems(\cboMaxDBLevel)
      addGadgetItemWithData(\cboMaxDBLevel, Lang("WEP", "MaxLevel0"), 0)
      addGadgetItemWithData(\cboMaxDBLevel, Lang("WEP", "MaxLevel12"), 12)
      setComboBoxWidth(\cboMaxDBLevel)
    EndIf
    
    If IsGadget(\cboMinDBLevel)
      ClearGadgetItems(\cboMinDBLevel)
      addGadgetItemWithData(\cboMinDBLevel, "-75dB", -75)
      addGadgetItemWithData(\cboMinDBLevel, "-100dB", -100)
      addGadgetItemWithData(\cboMinDBLevel, "-120dB", -120)
      addGadgetItemWithData(\cboMinDBLevel, "-140dB", -140)
      addGadgetItemWithData(\cboMinDBLevel, "-160dB", -160)
      setComboBoxWidth(\cboMinDBLevel,60)
    EndIf
    
    If IsGadget(\cboGridClickAction)
      ClearGadgetItems(\cboGridClickAction)
      addGadgetItemWithData(\cboGridClickAction, Lang("WEP", "GoToCue"), #SCS_GRDCLICK_GOTO_CUE)
      addGadgetItemWithData(\cboGridClickAction, Lang("WEP", "GoButtonOnly"), #SCS_GRDCLICK_SET_GO_BUTTON_ONLY)
      addGadgetItemWithData(\cboGridClickAction, Lang("WEP", "IgnoreClick"), #SCS_GRDCLICK_IGNORE)
      setComboBoxWidth(\cboGridClickAction)
    EndIf
    
    If IsGadget(\cboLostFocusAction)
      ClearGadgetItems(\cboLostFocusAction)
      addGadgetItemWithData(\cboLostFocusAction, decodeLostFocusActionL(#SCS_LOSTFOCUS_WARN), #SCS_LOSTFOCUS_WARN)
      addGadgetItemWithData(\cboLostFocusAction, decodeLostFocusActionL(#SCS_LOSTFOCUS_IGNORE), #SCS_LOSTFOCUS_IGNORE)
      setComboBoxWidth(\cboLostFocusAction)
    EndIf
    ;}
    grWEP\nLoadProgress + 1
    WMI_setProgress(grWEP\nLoadProgress)
    ;}
    
    ; INFO: Draw Form
    If gbClosingDown = #False
      WMI_displayInfoMsg2("") ; clear InfoMsg2
    EndIf
    ;{
    If gbClosingDown = #False
      debugMsg(sProcName, "calling WEP_drawForm()")
      WEP_drawForm()
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndIf
    ;}
    grWEP\nLoadProgress + 1
    If gbClosingDown = #False
      WMI_setProgress(grWEP\nLoadProgress)
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_Form_Unload(Cancel)
  gbEditProdFormLoaded = #False
EndProcedure

Procedure WEP_setChkEnableMidiCue()
  PROCNAMEC()
  Protected bEnabled, bVisible
  Protected nDevMapPtr
  Protected d
  
  With grProd
    
    If \bUsingMidiCueNumbers
      \bEnableMidiCue = #True
      bEnabled = #False   ; checkbox (on) will be disabled as user is already using MIDI cue numbers so cannot cancel
      bVisible = #True
      
    ElseIf grLicInfo\nLicLevel < #SCS_LIC_PRO
      \bEnableMidiCue = #False
      bVisible = #False   ; checkbox will be hidden as the option is not available at this license level
      
    Else
      bEnabled = #True
      bVisible = #True
      nDevMapPtr = \nSelectedDevMapPtr
      If nDevMapPtr >= 0
        d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
        While d >= 0
          If grMaps\aDev(d)\nDevGrp = #SCS_DEVGRP_CUE_CTRL
            If grMaps\aDev(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN Or grMaps\aDev(d)\nDevType = #SCS_DEVTYPE_CC_DMX_IN
              \bEnableMidiCue = #True
              bEnabled = #False   ; checkbox (on) will be disabled as user has specified cue control via midi or dmx
              Break
            EndIf
          EndIf
          d = grMaps\aDev(d)\nNextDevIndex
        Wend
      EndIf
    EndIf
    
    debugMsg(sProcName, "\bUsingMidiCueNumbers=" + strB(\bUsingMidiCueNumbers) + ", bVisible=" + strB(bVisible) + ", bEnabled=" + strB(bEnabled))
    setVisible(WEP\chkEnableMidiCue, bVisible)
    If bVisible
      setOwnState(WEP\chkEnableMidiCue, \bEnableMidiCue)
      setOwnEnabled(WEP\chkEnableMidiCue, bEnabled)
    EndIf
  EndWith
EndProcedure

Procedure WEP_populateProdProperties()
  PROCNAMEC()
  Protected n, m
  Protected bTrueIfTemplate, bTrueIfProd
  Protected nGenPropsTop
  Static bCboTestSoundPopulated ; 3May2022pm 11.9.1

  debugMsg(sProcName, #SCS_START)
  
  ; Commented out 28Oct2024 11.10.6ax as gbGoToProdPropDevices is tested later in this Procedure
  ;   If gbGoToProdPropDevices
  ;     gbGoToProdPropDevices = #False
  ;     debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
  ;   EndIf
  
  With grProd
    
    WEP_setPageTitle()
    
    If \bTemplate
      bTrueIfTemplate = #True
      SGT(WEP\txtTmName, \sTmName)
      SGT(WEP\edgTmDesc, \sTmDesc)
      WED_displayTemplateInfoIfReqd(#True)
      nGenPropsTop = GadgetY(WEP\edgTmDesc) + GadgetHeight(WEP\edgTmDesc) + 20
    Else
      bTrueIfProd = #True
      SGT(WEP\txtTitle, \sTitle)
      nGenPropsTop = GadgetY(WEP\txtTitle) + GadgetHeight(WEP\txtTitle) + 20
    EndIf
    setVisible(WEP\lblTitle, bTrueIfProd)
    setVisible(WEP\txtTitle, bTrueIfProd)
    setVisible(WEP\lblTmName, bTrueIfTemplate)
    setVisible(WEP\txtTmName, bTrueIfTemplate)
    setVisible(WEP\lblTmDesc, bTrueIfTemplate)
    setVisible(WEP\edgTmDesc, bTrueIfTemplate)
    setVisible(WEP\cntTemplate, bTrueIfTemplate)
    ResizeGadget(WEP\cntGenProps, #PB_Ignore, nGenPropsTop, #PB_Ignore, #PB_Ignore)
    
    debugMsg(sProcName, "calling WEP_loadAndDisplayDevsForProd()")
    WEP_loadAndDisplayDevsForProd()
    
    SLD_setMax(WEP\sldTestToneLevel, #SCS_MAXVOLUME_SLD)
    SLD_setLevel(WEP\sldTestToneLevel, \fTestToneBVLevel)
    SLD_setValue(WEP\sldTestTonePan, panToSliderValue(\fTestTonePan)) ; 4May2022am 11.9.1
    WEP_enableTestTonePanControls()
    
    ; Added 3May2022pm 11.9.1
    If bCboTestSoundPopulated = #False
      ClearGadgetItems(WEP\cboTestSound)
      addGadgetItemWithData(WEP\cboTestSound, LangPars("WEP", "SineWave", "440"), #SCS_TEST_TONE_SINE)
      addGadgetItemWithData(WEP\cboTestSound, Lang("WEP", "PinkNoise"), #SCS_TEST_TONE_PINK)
      bCboTestSoundPopulated = #True
    EndIf
    setComboBoxByData(WEP\cboTestSound, \nTestSound, 0)
    ; End added 3May2022pm 11.9.1
    
    SGT(WEP\cboCueLabelIncrement, Str(\nCueLabelIncrement))
    
    SLD_setMax(WEP\sldMasterFader2, #SCS_MAXVOLUME_SLD)
    SLD_setLevel(WEP\sldMasterFader2, \fMasterBVLevel)
    SGT(WEP\txtMasterFaderDB, \sMasterDBVol)
    
    SGT(WEP\txtDBLevelChangeIncrement, \sDBLevelChangeIncrement)
    
    If WEP\sldDMXMasterFader2
      SLD_setValue(WEP\sldDMXMasterFader2, \nDMXMasterFaderValue)
    EndIf
    
    If grLicInfo\nLicLevel >= #SCS_LIC_STD
      ; time profiles not available in lite
      m = 0
      For n = 0 To #SCS_MAX_TIME_PROFILE
        SGT(WEP\txtTimeProfile[m], \sTimeProfile[n])
        m + 1
      Next n
      WEP_populateDefaultTimeProfile()
      setComboBoxByData(WEP\cboResetTOD, \nResetTOD, 0)
    EndIf
    
    setComboBoxByData(WEP\cboFocusPoint, \nFocusPoint, 0)
    
    setOwnState(WEP\chkLabelsFrozen, \bLabelsFrozen)
    setOwnState(WEP\chkLabelsUCase, \bLabelsUCase)
    setOwnState(WEP\chkPreLoadNextManualOnly, \bPreLoadNextManualOnly)
    setOwnState(WEP\chkNoPreLoadVideoHotkeys, \bNoPreLoadVideoHotkeys)
    setOwnState(WEP\chkStopAllInclHib, \bStopAllInclHib)
    If grLicInfo\bHKClickAvailable
      setOwnState(WEP\chkAllowHKeyClick, \bAllowHKeyClick)
    EndIf
    If IsGadget(WEP\chkDoNotCalcCueStartValues) ; Test added 14May2022 11.9.1
      setOwnState(WEP\chkDoNotCalcCueStartValues, \bDoNotCalcCueStartValues)
    EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PRO
      setComboBoxByData(WEP\cboMemoDispOptForPrim, \nMemoDispOptForPrim, 0)
    EndIf
    
    SGT(WEP\txtDefFadeInTime, timeToStringT(\nDefFadeInTime))
    SGT(WEP\txtDefFadeOutTime, timeToStringT(\nDefFadeOutTime))
    SGT(WEP\txtDefLoopXFadeTime, timeToStringT(\nDefLoopXFadeTime))
    SGT(WEP\txtDefSFRTimeOverride, timeToStringT(\nDefSFRTimeOverride))
    If grLicInfo\nMaxLiveDevPerProd > 0
      SGT(WEP\txtDefFadeInTimeI, timeToStringT(\nDefFadeInTimeI))
      SGT(WEP\txtDefFadeOutTimeI, timeToStringT(\nDefFadeOutTimeI))
    EndIf
    If IsGadget(WEP\txtDefDMXFadeTime)
      SGT(WEP\txtDefDMXFadeTime, timeToStringD(\nDefDMXFadeTime))
    EndIf
    If IsGadget(WEP\txtDefChaseSpeed)
      SGT(WEP\txtDefChaseSpeed, Str(\nDefChaseSpeed))
    EndIf
    If IsGadget(WEP\cboDefOutputScreen)
      setComboBoxByData(WEP\cboDefOutputScreen, \nDefOutputScreen, 0)
      ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
      SGT(WEP\txtDefFadeInTimeA, timeToStringT(\nDefFadeInTimeA))
      SGT(WEP\txtDefFadeOutTimeA, timeToStringT(\nDefFadeOutTimeA))
      SGT(WEP\txtDefDisplayTimeA, timeToStringT(\nDefDisplayTimeA))
      setOwnState(WEP\chkDefRepeatA, \bDefRepeatA)
      setOwnState(WEP\chkDefPauseAtEndA, \bDefPauseAtEndA)
      ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
    EndIf
    
    WEP_setChkEnableMidiCue()
    
    setComboBoxByData(WEP\cboVisualWarningTime, \nVisualWarningTime, 0)
    setComboBoxByData(WEP\cboVisualWarningFormat, \nVisualWarningFormat, 0)
    
    If IsGadget(WEP\cboRunMode)
      setComboBoxByData(WEP\cboRunMode, \nRunMode, 0)
    EndIf
    
    If IsGadget(WEP\cboMaxDBLevel)
      setComboBoxByData(WEP\cboMaxDBLevel, \nMaxDBLevel, 0)
    EndIf
    
    If IsGadget(WEP\cboMinDBLevel)
      setComboBoxByData(WEP\cboMinDBLevel, \nMinDBLevel, 0)
    EndIf
    
    If IsGadget(WEP\cboGridClickAction)
      setComboBoxByData(WEP\cboGridClickAction, \nGridClickAction, 0)
    EndIf
    
    If IsGadget(WEP\cboLostFocusAction)
      setComboBoxByData(WEP\cboLostFocusAction, \nLostFocusAction, 0)
    EndIf
    
    If (\bTemplate = #False) And ((Len(\sTitle) = 0) Or (\sTitle = #SCS_UNTITLED))
      ; set focus to production title if this has not yet been supplied
      SAG(WEP\txtTitle)
    Else
      SAG(-1)
    EndIf
    
    If gbGoToProdPropDevices
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      WEP_pnlProd_Click()
      ; nb do not clear gbGoToProdPropDevices until device changes have been applied
      
    ElseIf grWEP\bDisplayAudioTab
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      WEP_pnlProd_Click()
      grWEP\bDisplayAudioTab = #False
      
    ElseIf grWEP\bDisplayLightingTab
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      WEP_pnlProd_Click()
      grWEP\bDisplayLightingTab = #False
      
    ElseIf grWEP\bDisplayCtrlSendTab
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      WEP_pnlProd_Click()
      grWEP\bDisplayCtrlSendTab = #False
      
    ElseIf grWEP\bDisplayCueCtrlTab ; 14Jun2022 11.9.4
      setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
      WEP_pnlProd_Click()
      grWEP\bDisplayCueCtrlTab = #False
      
    ElseIf grWEP\nDisplayedTab < 0
      SGS(WEP\pnlProd, 0)
      WEP_pnlProd_Click()
      
    EndIf
    
    grCED\bProdChanged = #False
    grCED\bProdDefDMXFadeTimeChanged = #False
    
  EndWith
  
  ; Added 19Nov2024 11.10.6bl (moved from start of procedure)
  If gbGoToProdPropDevices
    gbGoToProdPropDevices = #False
    debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
  EndIf
  ; End added 19Nov2024 11.10.6bl
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_populateDefaultTimeProfile()
  PROCNAMEC()
  Protected n, m, bEnable
  Protected n2
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\nLicLevel >= #SCS_LIC_STD
    ; time profiles not available in lite
    With grProd
      m = -1
      ClearGadgetItems(WEP\cboDfltTimeProfile)
      For n = 0 To #SCS_MAX_TIME_PROFILE
        If Len(\sTimeProfile[n]) <> 0
          AddGadgetItem(WEP\cboDfltTimeProfile, -1, \sTimeProfile[n])
          bEnable = #True
          If \sTimeProfile[n] = \sDefaultTimeProfile
            m = n
          EndIf
        EndIf
      Next n
      If m >= 0
        SGS(WEP\cboDfltTimeProfile, m)
      EndIf
      setEnabled(WEP\cboDfltTimeProfile, bEnable)
      
      For n2 = 0 To 6
        m = -1
        ClearGadgetItems(WEP\cboDfltTimeProfileForDay[n2])
        AddGadgetItem(WEP\cboDfltTimeProfileForDay[n2], -1, "")
        m = 0
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If \sTimeProfile[n]
            AddGadgetItem(WEP\cboDfltTimeProfileForDay[n2], -1, \sTimeProfile[n])
            If \sTimeProfile[n] = \sDefaultTimeProfileForDay[n2]
              m = n + 1
            EndIf
          EndIf
        Next n
        If m >= 0
          SGS(WEP\cboDfltTimeProfileForDay[n2], m)
        EndIf
        setEnabled(WEP\cboDfltTimeProfileForDay[n2], bEnable)
      Next n2
      
      setEnabled(WEP\cboResetTOD, bEnable)
    EndWith
  EndIf

EndProcedure

Procedure WEP_drawForm()
  PROCNAMEC()
  Protected n

  colorEditorComponent(#WEP)
  
  With WEP
    If grLicInfo\bTimeProfilesAvailable
      For n = 0 To #SCS_MAX_TIME_PROFILE
        setTextBoxBackColor(\txtTimeProfile[n])
      Next n
    EndIf
    If grLicInfo\nMaxLiveDevPerProd >= 0
      clearTestLiveInputVUDisplay()
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_txtTimeProfile_Validate(Index)
  PROCNAMEC()
  Protected n, sOldName.s, sNewName.s
  Protected i, sCues.s, nResponse
  Protected u, u2
  
  sOldName = grProd\sTimeProfile[Index]
  sNewName = Trim(GGT(WEP\txtTimeProfile[Index]))
  
  ; debugMsg0(sProcName, "Index=" + Index + ", sOldName=" + sOldName + ", sNewName=" + sNewName)

  If sNewName = sOldName
    ; no change, not even to case
    ProcedureReturn #True
  EndIf

  If sNewName
    For n = 0 To #SCS_MAX_TIME_PROFILE
      If n <> Index
        If UCase(sNewName) = UCase(sOldName)
          ensureSplashNotOnTop()
          scsMessageRequester(grText\sTextValErr, LangPars("Errors", "ProfileAlreadyUsed", sNewName), #PB_MessageRequester_Error)
          ProcedureReturn #False
        EndIf
      EndIf
    Next n
  Else ; sNewName = ""
    sCues = ""
    For i = 1 To gnLastCue
      If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If UCase(aCue(i)\sTimeProfile[n]) = UCase(sOldName)
            sCues = ", " + aCue(i)\sCue
            Break
          EndIf
        Next n
      EndIf
    Next i
    If sCues
      nResponse = scsMessageRequester(grText\sTextEditor, LangPars("Errors", "ProfileUsedByCues", sOldName, Mid(sCues,3)), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
      If nResponse = #PB_MessageRequester_No
        ProcedureReturn #False
      EndIf
    EndIf
  EndIf

  u = preChangeProdS(sOldName, GGT(WEP\lblProfileName), -5, #SCS_UNDO_ACTION_CHANGE, Index)
  grProd\sTimeProfile[Index] = sNewName

  If sOldName
    For i = 1 To gnLastCue
      If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If UCase(aCue(i)\sTimeProfile[n]) = UCase(sOldName)
            u2 = preChangeCueS(aCue(i)\sTimeProfile[n], GGT(WEP\lblProfileName), i, #SCS_UNDO_ACTION_CHANGE, n)
            aCue(i)\sTimeProfile[n] = sNewName
            If Len(sNewName) = 0
              aCue(i)\sTimeBasedStart[n] = ""
            EndIf
            postChangeCueS(u2, aCue(i)\sTimeProfile[n], i, n)
          EndIf
        Next n
      EndIf
    Next i
  EndIf

  If grProd\sDefaultTimeProfile = sOldName
    If sNewName
      grProd\sDefaultTimeProfile = sNewName
    Else
      ; previous default time profile is now deleted
      ; so select first available time profile
      For n = 0 To #SCS_MAX_TIME_PROFILE
        If Len(grProd\sTimeProfile[n]) <> 0
          grProd\sDefaultTimeProfile = grProd\sTimeProfile[n]
          Break
        EndIf
      Next n
    EndIf
  EndIf
  
  setTimeProfileCount(@grProd) ; added 17Mar2020 11.8.2.3aa

  ; populate the default time profile combo box
  WEP_populateDefaultTimeProfile()

  postChangeProdS(u, sNewName, -5, Index)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_chkNetworkDummy_Click(Index)
  PROCNAMEC()
  ; procedure added 3Nov2015 11.4.1.2g
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
;   debugMsg(sProcName, "calling listNetworkControl()")
;   listNetworkControl()

  WEP_displayCurrNetworkDevDesc()
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      debugMsg(sProcName, "grWEP\nCurrentCtrlDevMapDevPtr=" + grWEP\nCurrentCtrlDevMapDevPtr)
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + grWEP\nCurrentCtrlDevMapDevPtr + ")\nPhysicalDevPtr=" + grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)\nPhysicalDevPtr)
          \bDummy = getOwnState(WEP\chkNetworkDummy[0])
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + grWEP\nCurrentCtrlDevMapDevPtr + ")\bDummy=" + strB(\bDummy))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\bNWDummy = \bDummy
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
            debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
            Select gaNetworkControl(nPhysicalDevPtr)\nCtrlNetworkRemoteDev
              Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
                debugMsg(sProcName, "calling getX32Data(" + nPhysicalDevPtr + ")")
                getX32Data(nPhysicalDevPtr)
            EndSelect
          EndIf
          WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If grWEP\nCurrentCueDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
          \bDummy = getOwnState(WEP\chkNetworkDummy[1])
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + grWEP\nCurrentCueDevMapDevPtr + ")\bDummy=" + strB(\bDummy))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\bNWDummy = \bDummy
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
            debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, "calling ED_fcNetworkDummy()")
  ED_fcNetworkDummy()
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      ED_fcCtrlNetworkRemoteDev(-1)
    Case #SCS_DEVGRP_CUE_CTRL
      ED_fcCueNetworkRemoteDev(-1)
  EndSelect
  
;   debugMsg(sProcName, "calling listNetworkControl()")
;   listNetworkControl()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_txtRemoteHost_Change(Index)
  PROCNAMEC()
  ; Comment 13Jan2022 11.9.0aj - not sure why this was processed for every character changed in the field, so now modified to becalled only in the 'Validate' process
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  WEP_displayCurrNetworkDevDesc()
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
          \sRemoteHost = Trim(GGT(WEP\txtRemoteHost[0]))
          debugMsg(sProcName, "\sRemoteHost=" + \sRemoteHost + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\sRemoteHost = \sRemoteHost
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
            debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If grWEP\nCurrentCueDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
          \sRemoteHost = Trim(GGT(WEP\txtRemoteHost[1]))
          debugMsg(sProcName, "\sRemoteHost=" + \sRemoteHost + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\sRemoteHost = \sRemoteHost
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
            debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sRemoteHost=" + gaNetworkControl(nPhysicalDevPtr)\sRemoteHost)
            debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
  EndSelect
  
EndProcedure

Procedure WEP_txtRemoteHost_Validate(Index)
  PROCNAMEC()
  Protected sRemoteHost.s
  
  debugMsg(sProcName, #SCS_START)
  
  sRemoteHost = Trim(GGT(WEP\txtRemoteHost[Index]))
  debugMsg(sProcName, "sRemoteHost=" + sRemoteHost)
  If looksLikeIPAddress(sRemoteHost)
    debugMsg(sProcName, "looksLikeIPAddress('" + sRemoteHost + "') returned #True")
    If validateIPAddressFormat(sRemoteHost, GGT(WEP\lblRemoteHost[Index])) = #False
      debugMsg(sProcName, "validateIPAddressFormat('" + sRemoteHost + "', '" + GGT(WEP\lblRemoteHost[Index]) + "') returned #False")
      ProcedureReturn #False
    EndIf
  EndIf
  WEP_txtRemoteHost_Change(Index)
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtRemotePort_Change(Index)
  PROCNAMEC()
  Protected nPhysicalDevPtr
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
          \nRemotePort = portStrToInt(GGT(WEP\txtRemotePort[0]))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\nRemotePort = \nRemotePort
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
;             debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If grWEP\nCurrentCueDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
          \nRemotePort = portStrToInt(GGT(WEP\txtRemotePort[1]))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\nRemotePort = \nRemotePort
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
;             debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\nRemotePort=" + gaNetworkControl(nPhysicalDevPtr)\nRemotePort)
;             debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
  EndSelect

EndProcedure

Procedure WEP_txtRemotePort_Validate(Index)
  PROCNAMEC()
  Protected sRemotePort.s
  
  debugMsg(sProcName, #SCS_START)
  
  sRemotePort = Trim(GGT(WEP\txtRemotePort[Index]))
  If validateIPPortNumber(sRemotePort, GGT(WEP\lblRemotePort[Index])) = #False
    ProcedureReturn #False
  EndIf
  
  WEP_txtRemotePort_Change(Index)
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtLocalPort_Change(Index)
  PROCNAMEC()
  Protected nPhysicalDevPtr
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
          \nLocalPort = portStrToInt(GGT(WEP\txtLocalPort[0]))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\nLocalPort = \nLocalPort
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
;             debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If grWEP\nCurrentCueDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
          \nLocalPort = portStrToInt(GGT(WEP\txtLocalPort[1]))
          nPhysicalDevPtr = \nPhysicalDevPtr
          If nPhysicalDevPtr >= 0
            gaNetworkControl(nPhysicalDevPtr)\nLocalPort = \nLocalPort
            buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
            \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
;             debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
          EndIf
          WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
          WEP_setDevChgsBtns()
          WEP_setRetryActivateBtn()
        EndWith
      EndIf
      
  EndSelect
EndProcedure

Procedure WEP_txtLocalPort_Validate(Index)
  PROCNAMEC()
  Protected sLocalPort.s
  
  debugMsg(sProcName, #SCS_START)
  
  sLocalPort = Trim(GGT(WEP\txtLocalPort[Index]))
  If validateIPPortNumber(sLocalPort, GGT(WEP\lblLocalPort[Index])) = #False
    ProcedureReturn #False
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_btnCompIPAddresses_Click(Index)
  ; PROCNAMEC()
  
  displayCompIPAddresses()
  
EndProcedure

Procedure WEP_txtHTTPStart_Change()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \sHTTPStart = Trim(GGT(WEP\txtHTTPStart))
      WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
    EndWith
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
EndProcedure

Procedure WEP_txtHTTPStart_Validate()
  ; PROCNAMEC()
  ; no action required
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtCtrlNetworkRemoteDevPW_Validate()
  PROCNAMEC()
  Protected nDevNo, nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      \sCtrlNetworkRemoteDevPassword = Trim(GGT(WEP\txtCtrlNetworkRemoteDevPW))
      debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\sCtrlNetworkRemoteDevPassword=" + \sCtrlNetworkRemoteDevPassword)
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        nPhysicalDevPtr = grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)\nPhysicalDevPtr
        If nPhysicalDevPtr >= 0
          gaNetworkControl(nPhysicalDevPtr)\sCtrlNetworkRemoteDevPassword = \sCtrlNetworkRemoteDevPassword
        EndIf
      EndWith
    EndIf
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtCtrlSendDelay_Validate()
  PROCNAMEC()
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEP\nCurrentCtrlDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
      \nCtrlSendDelay = Val(GGT(WEP\txtCtrlSendDelay))
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + grWEP\nCurrentCtrlDevMapDevPtr + ")\nCtrlSendDelay=" + \nCtrlSendDelay)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        gaNetworkControl(nPhysicalDevPtr)\nCtrlSendDelay = \nCtrlSendDelay
        debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\nCtrlSendDelay=" + gaNetworkControl(nPhysicalDevPtr)\nCtrlSendDelay)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDMXChannel_Change(Index)
  ; no action required
EndProcedure

Procedure WEP_txtDMXChannel_Validate(Index)
  PROCNAMEC()
  Protected nCmdNo
  Protected nTmp, sTmp.s
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nCmdNo = WEP_indexToCmdNo(Index)
      sTmp = Trim(GGT(WEP\txtDMXChannel[Index]))
      If sTmp
        nTmp = Val(sTmp)
      Else
        nTmp = -2
      EndIf
      If (nTmp <> -2) And (nTmp < 1 Or nTmp > 512)
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "DMXChannel", GGT(WEP\lblDMXCommand[Index])), #PB_MessageRequester_Error)
        ProcedureReturn #False
      Else
        If nTmp <> \aDMXCommand[nCmdNo]\nChannel
          \aDMXCommand[nCmdNo]\nChannel = nTmp
          grCED\bProdChanged = #True
        EndIf
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WEP_cboDMXTrgValue_Click()
  PROCNAMEC()
  Protected nDMXTrgValue
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nDMXTrgValue = getCurrentItemData(WEP\cboDMXTrgValue)
      If nDMXTrgValue <> \nDMXTrgValue
        \nDMXTrgValue = getCurrentItemData(WEP\cboDMXTrgValue)
        grCED\bProdChanged = #True
      EndIf
    EndWith
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure WEP_cboDMXRefreshRate_Click()
  PROCNAMEC()
  ;Protected nDMXRefreshRate
  Protected nCurrentDevMapDevPtr
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentLightingDevNo
  nCurrentDevMapDevPtr = grWEP\nCurrentLightingDevMapDevPtr
  
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      \nDMXRefreshRate = getCurrentItemData(WEP\cboDMXRefreshRate)
      grCED\bProdChanged = #True
      debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
      DMX_loadDMXControl(#True)
      debugMsg(sProcName, "calling WEP_displayLightingPhysInfo(" + nDevNo + ")")
      WEP_displayLightingPhysInfo(nDevNo)
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_txtTitle_Validate()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    u = preChangeProdS(\sTitle, GGT(WEP\lblTitle), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_PROD_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
    \sTitle = Trim(GGT(WEP\txtTitle))
    WED_setProdNodeText()
    WEP_setPageTitle()
    WED_setWindowTitle()
    WMN_setWindowTitle()
    grCED\bProdChanged = #True
    postChangeProdS(u, \sTitle)
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtTmName_Validate()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    If valTemplateName(WEP\lblTmName, WEP\txtTmName) = #False
      ProcedureReturn #False
    EndIf
    u = preChangeProdS(\sTmName, GGT(WEP\lblTmName), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_PROD_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
    \sTmName = Trim(GGT(WEP\txtTmName))
    WED_setProdNodeText()
    WEP_setPageTitle()
    WED_setWindowTitle()
    WMN_setWindowTitle()
    WED_displayTemplateInfoIfReqd(#True)
    WMN_displayTemplateInfoIfReqd(#True)
    grCED\bProdChanged = #True
    postChangeProdS(u, \sTmName)
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_edgTmDesc_Validate()
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    u = preChangeProdS(\sTmDesc, GGT(WEP\lblTmDesc))
    \sTmDesc = Trim(GGT(WEP\edgTmDesc))
    grCED\bProdChanged = #True
    postChangeProdS(u, \sTmDesc)
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    debugMsg(sProcName, "calling WEP_valGadget(gnValidateGadgetNo)")
    bValidationOK = WEP_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WEP_populateOutputDevForTestLiveInput()
  PROCNAMEC()
  Protected d, sLogicalDev.s
  Protected nListIndex
  
  With WEP
    ClearGadgetItems(\cboOutputDevForTestLiveInput)
    For d = 0 To grProdForDevChgs\nMaxAudioLogicalDev
      sLogicalDev = grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev
      If sLogicalDev
        addGadgetItemWithData(\cboOutputDevForTestLiveInput, sLogicalDev, d)
      EndIf
    Next d
    If Len(grProdForDevChgs\sOutputDevForTestLiveInput) > 0
      nListIndex = indexForComboBoxRow(\cboOutputDevForTestLiveInput, grProdForDevChgs\sOutputDevForTestLiveInput, 0)
    Else
      nListIndex = 0
    EndIf
    SGS(\cboOutputDevForTestLiveInput, nListIndex)
  EndWith
EndProcedure

Procedure WEP_pnlDevs_Click()
  PROCNAMEC()
  Protected nDevMapPtr, nCurrentDevNo, nCurrentInGrpNo, nCurrentFixTypeNo, nFixtureItemIndex
  Protected bEnableMultiple
  Protected qTabStartTime.q, qTimeNow.q, sTabDesc.s
  Static bStaticLoaded, sSettings.s
  
  debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sSettings = Lang("Common", "Settings")
    bStaticLoaded = #True
  EndIf
  
  WEP_stopProdTestIfRunning()
  
  With grWEP
    qTabStartTime = ElapsedMilliseconds()
    \nDisplayedDevTab = getCurrentItemData(WEP\pnlDevs)
    debugMsg(sProcName, "\nDisplayedDevTab=" + \nDisplayedDevTab)
    ; debugMsg(sProcName, "\nCurrentAudDevNo=" + \nCurrentAudDevNo + ", \nCurrentLiveDevNo=" + \nCurrentLiveDevNo + ", \nCurrentCtrlDevNo=" + \nCurrentCtrlDevNo + ", \nCurrentCueDevNo=" + \nCurrentCueDevNo)
    
    Select \nDisplayedDevTab
      Case #SCS_PROD_TAB_AUD_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
        nCurrentDevNo = \nCurrentAudDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Audio tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentAudDevInfo(nCurrentDevNo)
        bEnableMultiple = #True
        
      Case #SCS_PROD_TAB_VIDEO_AUD_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
        nCurrentDevNo = \nCurrentVidAudDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Video tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentVidAudDevInfo(nCurrentDevNo)
        
      Case #SCS_PROD_TAB_VIDEO_CAP_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
        nCurrentDevNo = \nCurrentVidCapDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "VidCap tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentVidCapDevInfo(nCurrentDevNo)
        
      Case #SCS_PROD_TAB_FIX_TYPES
        If IsMenu(#WEP_mnuGridColors) = #False
          WEP_buildPopupMenu_GridColors()
        EndIf
        \nCurrentDevGrp = #SCS_DEVGRP_FIX_TYPE
        nCurrentFixTypeNo = \nCurrentFixTypeNo
        If nCurrentFixTypeNo < 0
          nCurrentFixTypeNo = 0
        EndIf
        debugMsg(sProcName, "Fixture Types tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentFixTypeNo=" + nCurrentFixTypeNo)
        WEP_setCurrentFixType(nCurrentFixTypeNo)
        
      Case #SCS_PROD_TAB_LIGHTING_DEVS
        If grWEP\bReloadFixtureTypesComboBox
          For nFixtureItemIndex = 0 To ArraySize(WEPFixture())
            WEP_populateCboFixtureType(nFixtureItemIndex)
          Next nFixtureItemIndex
          grWEP\bReloadFixtureTypesComboBox = #False
        EndIf
        \nCurrentDevGrp = #SCS_DEVGRP_LIGHTING
        nCurrentDevNo = \nCurrentLightingDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Lighting tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentLightingDevInfo(nCurrentDevNo)
        
      Case #SCS_PROD_TAB_LIVE_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_LIVE_INPUT
        nCurrentDevNo = \nCurrentLiveDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Live Input tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_populateOutputDevForTestLiveInput()
        WEP_setCurrentLiveDevInfo(nCurrentDevNo)
        
      Case #SCS_PROD_TAB_IN_GRPS
        \nCurrentDevGrp = #SCS_DEVGRP_IN_GRP
        nCurrentInGrpNo = \nCurrentInGrpNo
        If nCurrentInGrpNo < 0
          nCurrentInGrpNo = 0
        EndIf
        debugMsg(sProcName, "Input Groups tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentInGrpNo=" + nCurrentInGrpNo)
        WEP_populateInGrpLiveInputs(nCurrentInGrpNo)
        WEP_setCurrentInGrpInfo(nCurrentInGrpNo)
        
      Case #SCS_PROD_TAB_CTRL_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_CTRL_SEND
        nCurrentDevNo = \nCurrentCtrlDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Ctrl Send tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentCtrlDevInfo(nCurrentDevNo)
        
      Case #SCS_PROD_TAB_CUE_DEVS
        \nCurrentDevGrp = #SCS_DEVGRP_CUE_CTRL
        nCurrentDevNo = \nCurrentCueDevNo
        If nCurrentDevNo < 0
          nCurrentDevNo = 0
        EndIf
        debugMsg(sProcName, "Cue Ctrl tab: \nCurrentDevGrp=" + decodeDevGrp(\nCurrentDevGrp) + ", nCurrentDevNo=" + nCurrentDevNo)
        WEP_setCurrentCueDevInfo(nCurrentDevNo)
        
    EndSelect
    
    qTimeNow = ElapsedMilliseconds()
    debugMsg(sProcName, "tab time: " + Str(qTimeNow - qTabStartTime) + ", " + decodeDevGrp(\nCurrentDevGrp))
    
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      \sDevDetailFrameTitle = sSettings
    EndIf
    
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
    debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
    WEP_setRetryActivateBtn()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_pnlProd_Click()
  PROCNAMEC()
  Protected nSelectedTab, Index
  
  debugMsg(sProcName, #SCS_START)
  
  WEP_stopProdTestIfRunning()
  
  With grWEP
    nSelectedTab = getCurrentItemData(WEP\pnlProd)
    ; debugMsg(sProcName, "grWEP\nDisplayedTab=" + \nDisplayedTab + ", nSelectedTab=" + nSelectedTab + ", GGS(WEP\pnlProd)=" + GGS(WEP\pnlProd))
    If nSelectedTab = \nDisplayedTab
      ; no tab change
      ProcedureReturn
    EndIf
    
    \nDisplayedTab = nSelectedTab
    Select \nDisplayedTab
      Case #SCS_PROD_TAB_DEVS
        WEP_setDevMapButtons()
        If gbGoToProdPropDevices
          setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_AUD_DEVS)
          WEP_pnlDevs_Click()
          
        ElseIf grWEP\bDisplayAudioTab
          setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_AUD_DEVS)
          WEP_pnlDevs_Click()
          
        ElseIf grWEP\bDisplayLightingTab
          setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_LIGHTING_DEVS)
          WEP_pnlDevs_Click()
          
        ElseIf grWEP\bDisplayCtrlSendTab
          setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_CTRL_DEVS)
          WEP_pnlDevs_Click()
          
        ElseIf grWEP\bDisplayCueCtrlTab ; 14Jun2022 11.9.4
          setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_CUE_DEVS)
          WEP_pnlDevs_Click()
          
        ElseIf \nDisplayedDevTab < 0
          SGS(WEP\pnlDevs, 0)
          WEP_pnlDevs_Click()
          
        EndIf
    EndSelect
  EndWith
  
EndProcedure

Procedure WEP_setPageTitle()
  Static sProdProperties.s
  Static bStaticLoaded
  Protected sTitleOrName.s
  
  If bStaticLoaded = #False
    sProdProperties = Lang("WEP","lblProdProperties")
    bStaticLoaded = #True
  EndIf
  
  With grProd
    If \bTemplate
      sTitleOrName = \sTmName
    ElseIf \sTitle <> #SCS_UNTITLED
      sTitleOrName = \sTitle
    EndIf
    If IsGadget(WEP\lblProdProperties)
      If sTitleOrName
        SGT(WEP\lblProdProperties, " " + sProdProperties + " - " + sTitleOrName)
      Else
        SGT(WEP\lblProdProperties, " " + sProdProperties)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure WEP_valProdProperties(bForceCheckTitle)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ; added 27Sep2019 11.8.2ao following a crash when testing "ASIO test 8 mono outputs.scs11" regarding a gadget not initialized, which was detected in ED_valProdDevices()
  If grCED\bProdCreated = #False
    displayProd()
  EndIf
  ; end added 27Sep2019 11.8.2ao

  debugMsg(sProcName, "calling validateAll")
  If validateAll() = #False
    debugMsg(sProcName, "calling publicNodeClick(" + grProd\nNodeKey + ")")
    WED_publicNodeClick(grProd\nNodeKey)
    ProcedureReturn #False
  EndIf
  
  If grProd\bTemplate
    If Len(Trim(grProd\sTmName)) = 0
      If grCED\bProdChanged Or bForceCheckTitle
        debugMsg(sProcName, "calling publicNodeClick(" + grProd\nNodeKey + ")")
        WED_publicNodeClick(grProd\nNodeKey)
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "MustBeEntered", GGT(WEP\lblTmName)), #PB_MessageRequester_Error)
        SAG(WEP\txtTmName)
        ProcedureReturn #False
      EndIf
    EndIf
  Else
    If Len(Trim(grProd\sTitle)) = 0 Or Trim(grProd\sTitle) = #SCS_UNTITLED
      If grCED\bProdChanged Or bForceCheckTitle
        debugMsg(sProcName, "calling publicNodeClick(" + grProd\nNodeKey + ")")
        WED_publicNodeClick(grProd\nNodeKey)
        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "MustBeEntered", GGT(WEP\lblTitle)), #PB_MessageRequester_Error)
        SAG(WEP\txtTitle)
        ProcedureReturn #False
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling ED_valProdDevices(#True)")
  If ED_valProdDevices(#True) = #False
    debugMsg(sProcName, "calling publicNodeClick(" + grProd\nNodeKey + ")")
    WED_publicNodeClick(grProd\nNodeKey)
    SGS(WED\tvwProdTree, 0) ; Added 3Oct2023 11.10.0cf
                            ; NB Known problem: the above SGS() successfully highlights the production properties entry in the \tvwProdTree TreeGadget,
                            ; BUT the currently selected node of the TreeGadget (eg a cue in the list) remains highlighted.
                            ; Tried adding SGS(WED\tvwProdTree, -1) before the above call, but that didn't make any difference
    ProcedureReturn #False
  EndIf
  
  If grCED\bProdDefDMXFadeTimeChanged
    debugMsg(sProcName, "calling propagateProdDefDMXFadeTime()")
    propagateProdDefDMXFadeTime()
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtMasterFaderDB_Validate()
  PROCNAMEC()
  Protected u
  Protected fMainSliderLevel, fMainBaseLevel, nUndoFlags
  
  If validateDbField(GGT(WEP\txtMasterFaderDB), GGT(WEP\lblMasterFader)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WEP\txtMasterFaderDB) <> gsTmpString
    SGT(WEP\txtMasterFaderDB, gsTmpString)
  EndIf
  
  With grProd
    fMainSliderLevel = SLD_getLevel(WMN\sldMasterFader)
    fMainBaseLevel = SLD_getBaseLevel(WMN\sldMasterFader)
    If fMainSliderLevel = fMainBaseLevel
      nUndoFlags = #SCS_UNDO_FLAG_SET_MASTER_VOL
    EndIf
    u = preChangeProdS(\sMasterDBVol, GGT(WEP\lblMasterFader), -5, #SCS_UNDO_ACTION_CHANGE, -1, nUndoFlags)
    \sMasterDBVol = Trim(GGT(WEP\txtMasterFaderDB))
    \fMasterBVLevel = convertDBStringToBVLevel(\sMasterDBVol)
    grMasterLevel\fProdMasterBVLevel = \fMasterBVLevel
    debugMsg(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
    SLD_setLevel(WEP\sldMasterFader2, \fMasterBVLevel)
    If fMainSliderLevel = fMainBaseLevel
      setMasterFader(\fMasterBVLevel)
      SLD_setLevel(WMN\sldMasterFader, \fMasterBVLevel)
      SLD_setBaseLevel(WMN\sldMasterFader, \fMasterBVLevel)
    Else
      SLD_setBaseLevel(WMN\sldMasterFader, \fMasterBVLevel)
    EndIf
    postChangeProdS(u, \sMasterDBVol)
    grCED\bProdChanged = #True
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_btnRenameDevMap()
  PROCNAMEC()
  Protected sOldDevMapName.s, sNewDevMapName.s
  Protected sTitle.s
  Protected n, nListIndex
  Protected nDevMapPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ; shouldn't happen
    ProcedureReturn
  EndIf
  
  sOldDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
  
  sTitle = Lang("WEP","btnRenameDevMap")
  sNewDevMapName = Trim(InputRequester(sTitle, Lang("WEP", "NewDevMapName"), sOldDevMapName))
  debugMsg(sProcName, "sOldDevMapName=" + sOldDevMapName + ", sNewDevMapName=" + sNewDevMapName)
  
  If Len(sNewDevMapName) = 0
    ; no new name entered, so ignore
    ProcedureReturn
  EndIf
  
  If sNewDevMapName <> sOldDevMapName
    If UCase(sNewDevMapName) <> UCase(sOldDevMapName)   ; this test reqd because the user may be just changing the case
      For n = 0 To grMapsForDevChgs\nMaxMapIndex
        If LCase(grMapsForDevChgs\aMap(n)\sDevMapName) = LCase(sNewDevMapName)
          scsMessageRequester(sTitle, LangPars("DevMap", "DevMapNameAlreadyUsed", sNewDevMapName), #MB_ICONEXCLAMATION)
          ProcedureReturn
        EndIf
      Next n
    EndIf
    
    grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName = sNewDevMapName
    debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName)
    grProdForDevChgs\sSelectedDevMapName = sNewDevMapName
    grMapsForDevChgs\sSelectedDevMapName = sNewDevMapName
    debugMsg(sProcName, "grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
    
    ; re-populate cboDevMap
    WEP_populateDevMapComboBox()
    nListIndex = indexForComboBoxRow(WEP\cboDevMap, sNewDevMapName, 0)
    SGS(WEP\cboDevMap, nListIndex)
    For n = 0 To #SCS_PROD_TAB_INDEX_LAST
      If IsGadget(WEP\txtDevMap[n])
        SGT(WEP\txtDevMap[n], sNewDevMapName)
      EndIf
    Next n
    
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
  EndIf
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnSaveAsDevMap_Click()
  PROCNAMEC()
  Protected sCurrDevMapName.s, sSaveAsDevMapName.s
  Protected sTitle.s
  Protected nListIndex
  Protected n
  Protected nCurrDevMapPtr, nSaveAsDevMapPtr
  Protected nCurrDevMapDevPtr, nSaveAsDevPtr, nNewPrevDevPtr
  Protected nOrigDevMapPtr, nOrigDevPtr
  ; Protected nHoldPrevDevPtr, nHoldNextDevPtr
  Protected nDevMapId
  Protected nProdDevMapPtr, nProdDevMapDevPtr
  Protected nCurrDevMapId
  Protected nCheckDevMapResult
  
  debugMsg(sProcName, #SCS_START)
  
  If grProdForDevChgs\nSelectedDevMapPtr < 0
    ; shouldn't happen
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + getDevChgsDevMapName(grProdForDevChgs\nSelectedDevMapPtr) + ")")
  nCheckDevMapResult = ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
  debugMsg(sProcName, "ED_checkDevMapForDevChgs(" + grProdForDevChgs\nSelectedDevMapPtr + ") returned " + nCheckDevMapResult)
  If (nCheckDevMapResult < 0) And (gsCheckDevMapMsg)
    scsMessageRequester(GGT(WEP\btnSaveAsDevMap), gsCheckDevMapMsg, #PB_MessageRequester_Ok | #MB_ICONERROR)
    ProcedureReturn
  EndIf
  
  sTitle = Lang("WEP","btnSaveAsDevMap")
  sSaveAsDevMapName = Trim(InputRequester(sTitle, Lang("WEP", "NewDevMapName"), ""))
  If Len(sSaveAsDevMapName) = 0
    ; no new name entered, so ignore
    ProcedureReturn
  EndIf
  
  nCurrDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  sCurrDevMapName = grMapsForDevChgs\aMap(nCurrDevMapPtr)\sDevMapName
  nCurrDevMapId = grMapsForDevChgs\aMap(nCurrDevMapPtr)\nDevMapId
  debugMsg(sProcName, "sCurrDevMapName=" + sCurrDevMapName + ", sSaveAsDevMapName=" + sSaveAsDevMapName)
  
  If sSaveAsDevMapName <> sCurrDevMapName
    For n = 0 To grMapsForDevChgs\nMaxMapIndex
      If LCase(grMapsForDevChgs\aMap(n)\sDevMapName) = LCase(sSaveAsDevMapName)
        scsMessageRequester(sTitle, LangPars("DevMap", "DevMapNameAlreadyUsed", sSaveAsDevMapName), #MB_ICONEXCLAMATION)
        ProcedureReturn
      EndIf
    Next n
    
    setMouseCursorBusy()    ; can take while, especially if changing to SM-S
    
    grMapsForDevChgs\nMaxMapIndex + 1
    If grMapsForDevChgs\nMaxMapIndex > ArraySize(grMapsForDevChgs\aMap())
      REDIM_ARRAY(grMapsForDevChgs\aMap, grMapsForDevChgs\nMaxMapIndex, grDevMapDef, "grMapsForDevChgs\aMap()")
    EndIf
    nSaveAsDevMapPtr = grMapsForDevChgs\nMaxMapIndex
    
    ; copy device map header
    grMapsForDevChgs\aMap(nSaveAsDevMapPtr) = grMapsForDevChgs\aMap(nCurrDevMapPtr)
    ; set new values in device map header
    gnUniqueDevMapId + 1
    nDevMapId = gnUniqueDevMapId
    grMapsForDevChgs\aMap(nSaveAsDevMapPtr)\nDevMapId = nDevMapId
    debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nSaveAsDevMapPtr + ")\nDevMapId=" + grMapsForDevChgs\aDev(nSaveAsDevMapPtr)\nDevMapId)
    grMapsForDevChgs\aMap(nSaveAsDevMapPtr)\sDevMapName = sSaveAsDevMapName
    grProdForDevChgs\sSelectedDevMapName = sSaveAsDevMapName
    grProdForDevChgs\nSelectedDevMapPtr = nSaveAsDevMapPtr
    grMapsForDevChgs\sSelectedDevMapName = sSaveAsDevMapName
    debugMsg(sProcName, "grProdForDevChgs\sSelectedDevMapName=" + grProdForDevChgs\sSelectedDevMapName + ", grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
    nCurrDevMapDevPtr = grMapsForDevChgs\aMap(nCurrDevMapPtr)\nFirstDevIndex
    If nCurrDevMapDevPtr >= 0
      nNewPrevDevPtr = -1
      grMapsForDevChgs\nMaxDevIndex + 1
      nSaveAsDevPtr = grMapsForDevChgs\nMaxDevIndex
      grMapsForDevChgs\aMap(nSaveAsDevMapPtr)\nFirstDevIndex = nSaveAsDevPtr
      While nCurrDevMapDevPtr >= 0
        If nSaveAsDevPtr > ArraySize(grMapsForDevChgs\aDev())
          REDIM_ARRAY(grMapsForDevChgs\aDev, nSaveAsDevPtr+20, grDevMapDevDef, "grMapsForDevChgs\aDev()")
        EndIf
        grMapsForDevChgs\aDev(nSaveAsDevPtr) = grMapsForDevChgs\aDev(nCurrDevMapDevPtr)
        grMapsForDevChgs\aDev(nSaveAsDevPtr)\nDevMapId = nDevMapId
        debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nSaveAsDevPtr + ")\nDevMapId=" + grMapsForDevChgs\aDev(nSaveAsDevPtr)\nDevMapId)
        grMapsForDevChgs\aDev(nSaveAsDevPtr)\nPrevDevIndex = nNewPrevDevPtr
        If grMapsForDevChgs\aDev(nCurrDevMapDevPtr)\nNextDevIndex >= 0
          grMapsForDevChgs\aDev(nSaveAsDevPtr)\nNextDevIndex = nSaveAsDevPtr + 1
          nNewPrevDevPtr = nSaveAsDevPtr
          grMapsForDevChgs\nMaxDevIndex + 1
          nSaveAsDevPtr = grMapsForDevChgs\nMaxDevIndex
        EndIf
        nCurrDevMapDevPtr = grMapsForDevChgs\aDev(nCurrDevMapDevPtr)\nNextDevIndex
      Wend
    EndIf
    
    debugMsg(sProcName, "calling resetDevMapForDevChgs(" + nCurrDevMapId + ")")
    resetDevMapForDevChgs(nCurrDevMapId)
    
    ; re-populate cboDevMap
    WEP_populateDevMapComboBox()
    nListIndex = indexForComboBoxRow(WEP\cboDevMap, sSaveAsDevMapName, 0)
    SGS(WEP\cboDevMap, nListIndex)
    For n = 0 To #SCS_PROD_TAB_INDEX_LAST
      If IsGadget(WEP\txtDevMap[n])
        SGT(WEP\txtDevMap[n], sSaveAsDevMapName)
      EndIf
    Next n
    
    WEP_applyDevChgs()
    
  EndIf
  
  ; SAG(-1) ; already done in WEP_applyDevChgs()
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnApplyDevChgs_Click()
  PROCNAMEC()
  Protected d, n
  Protected nDevMapPtr
  Protected sOrigPhysicalDev.s, sPhysicalDev.s, sChar.s
  Protected nOrigAudioDriver, nAudioDriver, nResult
  Protected bChangeFound
  Protected sTitle.s, sButtons.s, nReply, sMsg.s, sMsg2.s
  Protected nCheckDevMapResult, nArtnetCount.i, n_sACNCount.i
  NewMap sACNDevCountMap()
  debugMsg(sProcName, #SCS_START)
  
  If WEP_CheckForDMXPortDuplication(#SCS_WEP_DMX_CONFLICT_MESSAGEREQUESTER)
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + getDevChgsDevMapName(grProdForDevChgs\nSelectedDevMapPtr) + ")")
  nCheckDevMapResult = ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr)
  debugMsg(sProcName, "ED_checkDevMapForDevChgs(" + grProdForDevChgs\nSelectedDevMapPtr + ") returned " + nCheckDevMapResult)
  If (nCheckDevMapResult < 0) And (gsCheckDevMapMsg)
    scsMessageRequester(GGT(WEP\btnApplyDevChgs), gsCheckDevMapMsg, #PB_MessageRequester_Ok | #MB_ICONERROR)
    ProcedureReturn
  EndIf
  
  setMouseCursorBusy()    ; can take a while, especially if changing to SM-S

  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    If gnCurrAudioDriver <> nAudioDriver
      debugMsg3(sProcName, "calling closeDevices(" + decodeDriver(gnCurrAudioDriver) + ")")
      closeDevices(gnCurrAudioDriver)
      setCurrAudioDriver(nAudioDriver)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "calling debugProd(@grProd)")
  ; debugProd(@grProd)
  
  ; debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
  ; listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, "calling ED_valProdDevices(#False)")
  If ED_valProdDevices(#False) = #False
    debugMsg(sProcName, "exiting because ED_valProdDevices returned False")
    setMouseCursorNormal()
    ProcedureReturn
  EndIf
  
  ; check if user has changed any physical devices which appear to be different (ie ignoring changes in numbers like changing from "1-2 (UA-101)" to "3-4 (UA-101)")
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If grMapsForDevChgs\aMap(nDevMapPtr)\bNewDevMap = #False
    
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    nOrigAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nOrigAudioDriver
    
    If (nAudioDriver <> nOrigAudioDriver) And (nOrigAudioDriver > 0)
      bChangeFound = #True
      sMsg2 = LangPars("DevMap", "ChgAudioDriver", decodeDriverL(nOrigAudioDriver), decodeDriverL(nAudioDriver))
    EndIf
    
    If bChangeFound = #False
      d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
      While d >= 0
        With grMapsForDevChgs\aDev(d)
          ; look for change of physical device, but if cue ctrl then ignore added or removed devices
          sOrigPhysicalDev = \sOrigPhysicalDev
          sPhysicalDev = \sPhysicalDev
          If sOrigPhysicalDev And sPhysicalDev
            If sPhysicalDev <> sOrigPhysicalDev
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d + ")\nDevGrp=" + decodeDevGrp(\nDevGrp) +
                                  ", sPhysicalDev=" + sPhysicalDev + ", sOrigPhysicalDev=" + sOrigPhysicalDev +
                                  ", \nPhysicalDevPtr=" + \nPhysicalDevPtr)
            EndIf
            If \nDevGrp <> #SCS_DEVGRP_CUE_CTRL
              If sPhysicalDev = sOrigPhysicalDev
                ; no change - ok
                d = \nNextDevIndex
                Continue
              EndIf
              ; remove numerics
              For n = 0 To 9
                sChar = Str(n)
                sOrigPhysicalDev = RemoveString(sOrigPhysicalDev, sChar)
                sPhysicalDev = RemoveString(sPhysicalDev, sChar)
              Next n
              If sPhysicalDev = sOrigPhysicalDev
                ; no change except for numerics - ok
                d = \nNextDevIndex
                Continue
              EndIf
              bChangeFound = #True
              sMsg2 = LangPars("DevMap", "ChgPhysDev", decodeDevGrpL(\nDevGrp), \sLogicalDev, \sOrigPhysicalDev, \sPhysicalDev)
              Break
            EndIf
          EndIf
          d = \nNextDevIndex
        EndWith
      Wend
    EndIf
    
    If bChangeFound
      sTitle = GGT(WEP\btnApplyDevChgs) + "|" + sMsg2 + "||" + Lang("DevMap", "AskAboutSaveAs") + "|"
      debugMsg(sProcName, sTitle)
      sButtons = LangEllipsis("DevMap", "SaveAs") + "|" +
                 Lang("DevMap", "Apply") + "|" +
                 Lang("Btns", "Cancel")
      setMouseCursorNormal()
      nReply = OptionRequester(0, 0, sTitle, sButtons, 140, #IDI_QUESTION)
      Select nReply
        Case 1   ; save as...
          debugMsg(sProcName, "nReply=SaveAs")
          WEP_btnSaveAsDevMap_Click()
          ProcedureReturn
        Case 2  ; apply
          debugMsg(sProcName, "nReply=Apply")
          ; allow to drop thru
        Case 3  ;cancel
          debugMsg(sProcName, "nReply=Cancel")
          ProcedureReturn
      EndSelect
    EndIf
    
  EndIf
  
  gsArtnetBroadcastIp = StringField(gsArtnetIpToBindTo, 1, ".") + "." + StringField(gsArtnetIpToBindTo, 2, ".") + "." +
                      StringField(gsArtnetIpToBindTo, 3, ".") + ".255"
  d = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
  
  ; scan through the devices and if we have Artnet or sACN reset the IP and restart them.
  While d >= 0
    If grMapsForDevChgs\aDev(d)\nDevGrp = #SCS_DEVGRP_LIGHTING
      sPhysicalDev = grMapsForDevChgs\aDev(d)\sPhysicalDev
      
      Select sPhysicalDev
        Case "Artnet", "Art-Net"                                  ; Artnet is one instance with a different universe number
          nArtnetCount + 1
          
        Case "sACN"                                               ; sACN is multiple instances, one for each universe
          n_sACNCount + 1
          AddMapElement(sACNDevCountMap(), Str(d))                ; store the device number in the map key
          sACNDevCountMap() = grMaps\aDev(n)\nDMXPort             ; store the original dmxport number as the value
      EndSelect
          
    EndIf
    d = grMapsForDevChgs\aDev(d)\nNextDevIndex
  Wend
  
  If gnArtnetHandle And nArtnetCount
    Artnet_close()
    gnArtnetHandle = Artnet_init()
    
    If gnArtnetHandle <= 0
        debugMsg(sProcName, "Art-net failed to re-initialise. IP:" + gsArtnetIpToBindTo + " Port:" + grMapsForDevChgs\aDev(d)\nDMXPort)
    EndIf
  EndIf
  
  If n_sACNCount
    ResetMap(sACNDevCountMap())
    
    For d = 1 To n_sACNCount
      NextMapElement(sACNDevCountMap())                           ; After a resetMap this will move us to the first map element
      sACNFinish(sACNDevCountMap())                               ; close the original sACN universe
      
      If sACNInitialise(gs_sACNIpToBindTo, grMapsForDevChgs\aDev(Val(MapKey(sACNDevCountMap())))\nDMXPort) < 0
        debugMsg(sProcName, "sACN failed to re-initialise. IP:" + gs_sACNIpToBindTo + " Port: " + grMapsForDevChgs\aDev(Val(MapKey(sACNDevCountMap())))\nDMXPort)
      EndIf
    Next
  EndIf
  
  setMouseCursorBusy()    ; can take while, especially if changing to SM-S

  debugMsg(sProcName, "calling WEP_applyDevChgs()")
  WEP_applyDevChgs()
  
  debugMsg(sProcName, "calling WEP_displayDevChgsItems()")
  WEP_displayDevChgsItems()   ; mainly to refresh 'active' indicators (ie \nDevState variables)
  debugMsg(sProcName, "calling copyDevStatesFromDevChgsToDev()")
  copyDevStatesFromDevChgsToDev()
  
  debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
  WEP_setRetryActivateBtn()
  
  debugMsg(sProcName, "calling WMN_buildPopupMenu_DevMap()")
  WMN_buildPopupMenu_DevMap()
  
  debugMsg(sProcName, "calling debugProd(@grProd)")
  debugProd(@grProd)
  
  debugMsg(sProcName, "calling listAllDevMaps()")
  listAllDevMaps()
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_applyDevChgs()
  PROCNAMEC()
  Protected d, nDevNo, n, nListIndex, nInGrpNo, nFixtureIndex
  Protected nDevMapPtr, nDevMapDevPtr
  Protected u
  Protected bEnablePan
  Protected bAllDevInitialized
  Protected nAudioDriver, nResult
  Protected sCheckMsg.s
  Protected sOldFixtureCode.s, sNewFixtureCode.s
  
  debugMsg(sProcName, #SCS_START)
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  
  If WEP_validateAudTab() = #False
    debugMsg(sProcName, "WEP_validateAudTab() returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateVidAudTab() = #False
    debugMsg(sProcName, "WEP_validateVidAudTab() returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateVidCapTab() = #False
    debugMsg(sProcName, "WEP_validateVidCapTab() returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateFixtureTypeTab() = #False
    debugMsg(sProcName, "WEP_validateFixtureTypeTab() returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateLightingTab(nDevMapPtr) = #False
    debugMsg(sProcName, "WEP_validateLightingTab(" + nDevMapPtr + ") returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateCtrlSendTab(nDevMapPtr) = #False
    debugMsg(sProcName, "WEP_validateCtrlSendTab(" + nDevMapPtr + ") returned #False")
    ProcedureReturn
  EndIf
  
  If WEP_validateCueCtrlTab(nDevMapPtr) = #False
    debugMsg(sProcName, "WEP_validateCueCtrlTab(" + nDevMapPtr + ") returned #False")
    ProcedureReturn
  EndIf
  
  SetMouseCursorBusy()
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  bAllDevInitialized = #True
  If nDevMapPtr >= 0
    If getDevMapName(nDevMapPtr) <> grMaps\sSelectedDevMapName ; gsSelectedDevMapName
      ; gsSelectedDevMapName = getDevMapName(nDevMapPtr)
      grMVUD\bDevMapDisplayed = #False
      grMVUD\bDevMapCurrentlyDisplayed = #False
    EndIf
  EndIf
  
  debugMsg(sProcName, "check audio devs")
  ;{
  For nDevNo = 0 To grProdForDevChgs\nMaxAudioLogicalDev
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      If \sLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev, nDevMapPtr)
        ; debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + nDevNo + ")\sLogicalDev=" + \sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr < 0
          bAllDevInitialized = #False
          debugMsg(sProcName, "device not initialized for " + \sLogicalDev)
          sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_AUDIO_OUTPUT), \sLogicalDev) + #LF$
        ElseIf grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False
          If Len(grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev) = 0 Or grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr < 0
            bAllDevInitialized = #False
            debugMsg(sProcName, "device not initialized for " + \sLogicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_AUDIO_OUTPUT), \sLogicalDev) + #LF$
          Else
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            \nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
              debugMsg(sProcName, "device not initialized for " + \sLogicalDev)
              debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
              initDevice(\nPhysicalDevPtr)
            EndIf
            If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
              debugMsg(sProcName, "device not initialized for " + \sLogicalDev)
              bAllDevInitialized = #False
              sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_AUDIO_OUTPUT), \sLogicalDev) + #LF$
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next nDevNo
  ;}
  
  debugMsg(sProcName, "check video audio devs")
  ;{
  For nDevNo = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      If \sVidAudLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_AUDIO, \sVidAudLogicalDev, nDevMapPtr)
        ; debugMsg(sProcName, "grProdForDevChgs\aVidAudLogicalDevs(" + nDevNo + ")\sVidAudLogicalDev=" + \sVidAudLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr < 0
          bAllDevInitialized = #False
          debugMsg(sProcName, "vid aud device not initialized for " + \sVidAudLogicalDev)
          sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_AUDIO), \sVidAudLogicalDev) + #LF$
        ElseIf grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False
          If Len(grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev) = 0 Or grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr < 0
            bAllDevInitialized = #False
            debugMsg(sProcName, "device not initialized for " + \sVidAudLogicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_AUDIO), \sVidAudLogicalDev) + #LF$
          Else
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            \nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            If gaVideoAudioDev(\nPhysicalDevPtr)\bVidAudInitialized = #False
              debugMsg(sProcName, "vid aud device not initialized for " + \sVidAudLogicalDev)
              debugMsg(sProcName, "calling initVidAudDevice(" + \nPhysicalDevPtr + ")")
              initVidAudDevice(\nPhysicalDevPtr)
            EndIf
            If gaVideoAudioDev(\nPhysicalDevPtr)\bVidAudInitialized = #False
              debugMsg(sProcName, "vid aud device not initialized for " + \sVidAudLogicalDev)
              bAllDevInitialized = #False
              sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_AUDIO), \sVidAudLogicalDev) + #LF$
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next nDevNo
  ;}
  
  debugMsg(sProcName, "check video capture devs")
  ;{
  For nDevNo = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
    With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
      If \sLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_capture, \sLogicalDev, nDevMapPtr)
        ; debugMsg(sProcName, "grProdForDevChgs\aVidCapLogicalDevs(" + nDevNo + ")\sLogicalDev=" + \sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr < 0
          bAllDevInitialized = #False
          debugMsg(sProcName, "vid aud device not initialized for " + \sLogicalDev)
          sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_capture), \sLogicalDev) + #LF$
        ElseIf grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False
          If Len(grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev) = 0 Or grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr < 0
            bAllDevInitialized = #False
            debugMsg(sProcName, "device not initialized for " + \sLogicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_capture), \sLogicalDev) + #LF$
          Else
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + Str(grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr))
            \nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
            If gaVideoCaptureDev(\nPhysicalDevPtr)\bVidCapInitialized = #False
              debugMsg(sProcName, "vid aud device not initialized for " + \sLogicalDev)
              debugMsg(sProcName, "calling initVidCapDevice(" + \nPhysicalDevPtr + ")")
              initVidCapDevice(\nPhysicalDevPtr)
            EndIf
            If gaVideoCaptureDev(\nPhysicalDevPtr)\bVidCapInitialized = #False
              debugMsg(sProcName, "vid aud device not initialized for " + \sLogicalDev)
              bAllDevInitialized = #False
              sCheckMsg + LangPars("DevMap", "DevNotActive", decodeDevTypeL(#SCS_DEVTYPE_VIDEO_capture), \sLogicalDev) + #LF$
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  Next nDevNo
  ;}
  
  debugMsg(sProcName, "bAllDevInitialized=" + strB(bAllDevInitialized))
  If bAllDevInitialized = #False
    SetMouseCursorNormal()
    sCheckMsg = RTrim(sCheckMsg, #LF$)
    debugMsg(sProcName, sCheckMsg)
    MessageRequester(GGT(WEP\btnApplyDevChgs), sCheckMsg, #MB_ICONEXCLAMATION)
    debugMsg(sProcName, "exiting because bAllDevInitialized = #False")
    ProcedureReturn
  EndIf
  
  gbInApplyDevChanges = #True ; Added 9Feb2024 11.10.2aj
  
  ; debugMsg0(sProcName, "callng preChangeProdL(#True, ...)")
  u = preChangeProdL(#True, GGT(WEP\btnApplyDevChgs), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_PROD_LOGICAL_DEVS | #SCS_UNDO_FLAG_REDO_PHYSICAL_DEVS)
  
  If gbProdDevChgs = #False And (gbProdDevOutputGainChgs Or gbProdDevInputGainChgs)
    ; output or input gain changes only
    If gbProdDevOutputGainChgs
      debugMsg(sProcName, "changes to output gains")
      For nDevNo = 0 To grProd\nMaxAudioLogicalDev
        grProd\aAudioLogicalDevs(nDevNo) = grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      Next nDevNo
    EndIf
    If gbProdDevInputGainChgs
      debugMsg(sProcName, "changes to input gains")
      For nDevNo = 0 To grProd\nMaxLiveInputLogicalDev
        grProd\aLiveInputLogicalDevs(nDevNo) = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
      Next nDevNo
    EndIf
    applyDevMapsForDevChgs()
    clearVUDisplay()
    
  Else  ; other changes
    For nDevNo = 0 To grProdForDevChgs\nMaxAudioLogicalDev
      With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
        \bDevChanged = #False
        If nDevNo > grProd\nMaxAudioLogicalDev
          \bDevChanged = #True
        ElseIf (Trim(grProd\aAudioLogicalDevs(nDevNo)\sLogicalDev)) Or (Trim(\sLogicalDev))
          If grProd\aAudioLogicalDevs(nDevNo)\sLogicalDev <> \sLogicalDev
            \bDevChanged = #True
          ElseIf \nNrOfOutputChans <> grProd\aAudioLogicalDevs(nDevNo)\nNrOfOutputChans
            \bDevChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
   
    For nDevNo = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
      With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
        \bDevChanged = #False
        If nDevNo > grProd\nMaxVidAudLogicalDev
          \bDevChanged = #True
        ElseIf (Len(Trim(grProd\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev)) > 0) Or (Trim(\sVidAudLogicalDev))
          If grProd\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev <> \sVidAudLogicalDev
            \bDevChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
      With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
        \bDevChanged = #False
        If nDevNo > grProd\nMaxVidCapLogicalDev
          \bDevChanged = #True
        ElseIf (Len(Trim(grProd\aVidCapLogicalDevs(nDevNo)\sLogicalDev)) > 0) Or (Trim(\sLogicalDev))
          If grProd\aVidCapLogicalDevs(nDevNo)\sLogicalDev <> \sLogicalDev
            \bDevChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxFixType
      With grProdForDevChgs\aFixTypes(nDevNo)
        \bFixTypeChanged = #False
        If nDevNo > grProd\nMaxFixType
          \bFixTypeChanged = #True
        ElseIf (Len(Trim(grProd\aFixTypes(nDevNo)\sFixTypeName)) > 0) Or (Trim(\sFixTypeName))
          If grProd\aFixTypes(nDevNo)\sFixTypeName <> \sFixTypeName
            \bFixTypeChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    ; Added 6Sep2023 11.10.0ca
    For nDevNo = 0 To grProdForDevChgs\nMaxLightingLogicalDev
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        \bDevChanged = #False
        If nDevNo > grProd\nMaxLightingLogicalDev
          \bDevChanged = #True
        ElseIf (Trim(grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev)) Or (Trim(\sLogicalDev))
          If grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev <> \sLogicalDev
            \bDevChanged = #True
          EndIf
        EndIf
        For n = 0 To grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nMaxFixture
          If n <= grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture
            ; sOldFixtureCode = grProd\aLightingLogicalDevs(nDevNo)\aFixture(n)\sFixtureCode              ; Replaced 14Oct2024 11.10.6am following bug reported by Andrea Gambuzza
            sOldFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(n)\sOrigFixtureCode  ; Replacement 14Oct2024 11.10.6am
            sNewFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(n)\sFixtureCode
            If sNewFixtureCode <> sOldFixtureCode
              debugMsg(sProcName, "nDevNo=" + nDevNo + ", n=" + n + ", sOldFixtureCode=" + sOldFixtureCode + ", sNewFixtureCode=" + sNewFixtureCode)
              If sOldFixtureCode
                ; sOldFixtureCode is not blank so the user is changing an existing fixture code
                DMX_changeFixtureCodeInLightingCues(sOldFixtureCode, sNewFixtureCode)
              EndIf
            EndIf
          EndIf
        Next n
      EndWith
    Next nDevNo
    ; End added 6Sep2023 11.10.0ca
    
    For nDevNo = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
      With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
        \bDevChanged = #False
        If nDevNo > grProd\nMaxLiveInputLogicalDev
          \bDevChanged = #True
        ElseIf (Trim(grProd\aLiveInputLogicalDevs(nDevNo)\sLogicalDev)) Or (Trim(\sLogicalDev))
          If grProd\aLiveInputLogicalDevs(nDevNo)\sLogicalDev <> \sLogicalDev
            \bDevChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProdForDevChgs\nMaxInGrp
      With grProdForDevChgs\aInGrps(nDevNo)
        \bInGrpChanged = #False
        If nDevNo > grProd\nMaxInGrp
          \bInGrpChanged = #True
        ElseIf Trim(grProd\aInGrps(nDevNo)\sInGrpName) Or Trim(\sInGrpName)
          If grProd\aInGrps(nDevNo)\sInGrpName <> \sInGrpName
            \bInGrpChanged = #True
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    ED_copyProdDevArrays(@grProdForDevChgs, @grProd)
    
    debugMsg(sProcName, "calling applyDevMapsForDevChgs()")
    applyDevMapsForDevChgs()
    
    For nDevNo = 0 To grProd\nMaxAudioLogicalDev
      With grProd\aAudioLogicalDevs(nDevNo)
        If \nPhysicalDevPtr >= 0
          ; debugMsg(sProcName, "grProd\aAudioLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          \nOutputs = gaAudioDev(\nPhysicalDevPtr)\nOutputs
          \bNoDevice = gaAudioDev(\nPhysicalDevPtr)\bNoDevice
          ; debugMsg(sProcName, "gaAudioDev(" + \nPhysicalDevPtr + ")\nOutputs=" + gaAudioDev(\nPhysicalDevPtr)\nOutputs + ", \bInitialized=" + strB(gaAudioDev(\nPhysicalDevPtr)\bInitialized))
          If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
            debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
            initDevice(\nPhysicalDevPtr)
          EndIf
        Else
          \nOutputs = 0
          \bNoDevice = #False
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProd\nMaxVidAudLogicalDev
      With grProd\aVidAudLogicalDevs(nDevNo)
        If \nPhysicalDevPtr >= 0
          ; debugMsg(sProcName, "grProd\aVidAudLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          \nOutputs = gaVideoAudioDev(\nPhysicalDevPtr)\nVidAudOutputs
          ; debugMsg(sProcName, "gaVideoAudioDev(" + \nPhysicalDevPtr + ")\nVidAudOutputs=" + gaVideoAudioDev(\nPhysicalDevPtr)\nVidAudOutputs)
          If gaVideoAudioDev(\nPhysicalDevPtr)\bVidAudInitialized = #False
            debugMsg(sProcName, "calling initVidAudDevice(" + \nPhysicalDevPtr + ")")
            initVidAudDevice(\nPhysicalDevPtr)
          EndIf
        Else
          \nOutputs = 0
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProd\nMaxVidCapLogicalDev
      With grProd\aVidCapLogicalDevs(nDevNo)
        If \nPhysicalDevPtr >= 0
          ; debugMsg(sProcName, "grProd\aVidCapLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          If gaVideoCaptureDev(\nPhysicalDevPtr)\bVidCapInitialized = #False
            debugMsg(sProcName, "calling initVidCapDevice(" + \nPhysicalDevPtr + ")")
            initVidCapDevice(\nPhysicalDevPtr)
          EndIf
        EndIf
      EndWith
    Next nDevNo
    
    For nDevNo = 0 To grProd\nMaxLiveInputLogicalDev
      With grProd\aLiveInputLogicalDevs(nDevNo)
        If \nPhysicalDevPtr >= 0
          ; debugMsg(sProcName, "grProd\aLiveInputLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
          \nInputs = gaAudioDev(\nPhysicalDevPtr)\nInputs
          \bNoDevice = gaAudioDev(\nPhysicalDevPtr)\bNoDevice
          ; debugMsg(sProcName, "gaAudioDev(" + \nPhysicalDevPtr + ")\nInputs=" + gaAudioDev(\nPhysicalDevPtr)\nInputs + ", \bInitialized=" + strB(gaAudioDev(\nPhysicalDevPtr)\bInitialized))
          If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
            debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
            initDevice(\nPhysicalDevPtr)
          EndIf
        Else
          \nInputs = 0
          \bNoDevice = #False
        EndIf
      EndWith
    Next nDevNo
    
    debugMsg(sProcName, "calling applyDevChanges()")
    applyDevChanges()
    
    debugMsg(sProcName, "calling setMidiEnabled()")
    setMidiEnabled()
    debugMsg(sProcName, "calling setRS232Enabled()")
    setRS232Enabled()
    debugMsg(sProcName, "calling setDMXEnabled()")
    setDMXEnabled()
    
    debugMsg(sProcName, "calling redoPhysicalDevs()")
    redoPhysicalDevs()
    
    debugMsg(sProcName, "calling initBassForAudioDriver(" + decodeDriver(gnCurrAudioDriver) + ")")
    initBassForAudioDriver(gnCurrAudioDriver)
    
    debugMsg(sProcName, "calling mergeDuplicateAsioDevs()")
    mergeDuplicateAsioDevs()
    debugMsg(sProcName, "calling clearVUDisplay()")
    clearVUDisplay()
    
    debugMsg(sProcName, "calling loadNetworkControl(#False)")
    loadNetworkControl(#False)
    
    ; reset \sOrigLogicalDev fields - may be used when applying device changes next time
    With grProd
      For n = 0 To \nMaxAudioLogicalDev
        \aAudioLogicalDevs(n)\sOrigLogicalDev = \aAudioLogicalDevs(n)\sLogicalDev
      Next n
      For n = 0 To \nMaxVidAudLogicalDev
        \aVidAudLogicalDevs(n)\sOrigLogicalDev = \aVidAudLogicalDevs(n)\sVidAudLogicalDev
      Next n
      For n = 0 To \nMaxVidCapLogicalDev
        \aVidCapLogicalDevs(n)\sOrigLogicalDev = \aVidCapLogicalDevs(n)\sLogicalDev
      Next n
      For n = 0 To \nMaxFixType
        \aFixTypes(n)\sOrigFixTypeName = \aFixTypes(n)\sFixTypeName
      Next n
      For n = 0 To \nMaxLightingLogicalDev
        \aLightingLogicalDevs(n)\sOrigLogicalDev = \aLightingLogicalDevs(n)\sLogicalDev
        For nFixtureIndex = 0 To \aLightingLogicalDevs(n)\nMaxFixture
          \aLightingLogicalDevs(n)\aFixture(nFixtureIndex)\sOrigFixtureCode = \aLightingLogicalDevs(n)\aFixture(nFixtureIndex)\sFixtureCode
        Next nFixtureIndex
      Next n
      For n = 0 To \nMaxCtrlSendLogicalDev
        \aCtrlSendLogicalDevs(n)\sOrigLogicalDev = \aCtrlSendLogicalDevs(n)\sLogicalDev
      Next n
      For n = 0 To \nMaxCueCtrlLogicalDev
        \aCueCtrlLogicalDevs(n)\sOrigLogicalDev = \aCueCtrlLogicalDevs(n)\sCueCtrlLogicalDev
      Next n
      For n = 0 To \nMaxLiveInputLogicalDev
        \aLiveInputLogicalDevs(n)\sOrigLogicalDev = \aLiveInputLogicalDevs(n)\sLogicalDev
      Next n
      For n = 0 To \nMaxInGrp
        \aInGrps(n)\sOrigInGrpName = \aInGrps(n)\sInGrpName
      Next n
    EndWith
    
  EndIf
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
  WEP_setDevChgsBtns()
  debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
  WEP_setRetryActivateBtn()
  
  ED_copyProdDevArrays(@grProd, @grProdForDevChgs)
  
  gnCallOpenNextCues = 1
  gbCallPopulateGrid = #True
  gbCallLoadDispPanels = #True
  grWQK\nFixtureComboboxesPopulatedForDevNo = -1
  
  WEP_setChkEnableMidiCue()
  
  ; debugMsg0(sProcName, "calling postChangeProdL(u, #False)")
  postChangeProdL(u, #False)

  If gbGoToProdPropDevices
    ; it's now OK to clear this flag as we have a valid device map
    gbGoToProdPropDevices = #False
  EndIf
  
  ; Added 28Oct2024 11.10.6ax
  If gbReviewDevMap
    gbReviewDevMap = #False
    debugMsg(sProcName, "gbReviewDevMap=" + strB(gbReviewDevMap))
  EndIf
  ; End added 28Oct2024 11.10.6ax

  WEP_setDevMapButtons()
  
  debugMsg(sProcName, "calling setMasterFader(" + traceLevel(grMasterLevel\fProdMasterBVLevel) + ")")
  setMasterFader(grMasterLevel\fProdMasterBVLevel)
  debugMsg(sProcName, "calling setAllInputGains()")
  setAllInputGains()
  debugMsg(sProcName, "calling setAllLiveEQ()")
  setAllLiveEQ()
  DMX_setChaseCueCount()  ; counts lighting cues that contain chase
  
  CSRD_SetRemDevUsedInProd()
  
  grWQMDevPopulated = grWQMDevPopulatedDef
  
  ; refresh faders window if reqd
  WCN_refreshControllers()
  
;   debugMsg(sProcName, "calling debugProd(@grProd)")
;   debugProd(@grProd)
  
  If IsWindow(#WDD)
    WDD_setCanvasSize() ; Fixtures list may need refreshing
    WDD_forceDisplayDMXSendData()
  EndIf
  
  gbInApplyDevChanges = #False ; Added 9Feb2024 11.10.2aj
  
  SetMouseCursorNormal()
  
  SAW(#WED)
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnDriverSettings_Click()
  PROCNAMEC()
  Protected nAudioDriver, nOptNode
  
  nAudioDriver = getCurrentItemData(WEP\cboAudioDriver)
  Select nAudioDriver
    Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI
      nOptNode = #SCS_OPTNODE_BASS_DS
    Case #SCS_DRV_BASS_ASIO
      nOptNode = #SCS_OPTNODE_BASS_ASIO
    Case #SCS_DRV_SMS_ASIO
      nOptNode = #SCS_OPTNODE_SMS_ASIO
  EndSelect
  WOP_Form_Show(#True, #WED, nOptNode)
EndProcedure

Procedure WEP_btnDeleteDevMap_Click()
  PROCNAMEC()
  Protected nResponse
  Protected nListIndex
  Protected nDevMapPtr
  Protected sDevMapName.s
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If grMapsForDevChgs\nMaxMapIndex < 1
    ; shouldn't occur as button should be disabled, but must always leave at least one device map
    ProcedureReturn
  EndIf
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  sDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
  
  nResponse = scsMessageRequester(GGT(WEP\btnDeleteDevMap), LangPars("DevMap","CheckDel",sDevMapName), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)

  If nResponse = #PB_MessageRequester_Yes
    
    ; move any following device maps up one position
    For n = (nDevMapPtr + 1) To grMapsForDevChgs\nMaxMapIndex
      grMapsForDevChgs\aMap(n - 1) = grMapsForDevChgs\aMap(n)
    Next n
    grMapsForDevChgs\nMaxMapIndex - 1
    
    If nDevMapPtr > grMapsForDevChgs\nMaxMapIndex
      nDevMapPtr = grMapsForDevChgs\nMaxMapIndex
    EndIf
    sDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
    grProdForDevChgs\nSelectedDevMapPtr = nDevMapPtr
    grProdForDevChgs\sSelectedDevMapName = sDevMapName
    
    ; re-populate cboDevMap
    WEP_populateDevMapComboBox()
    nListIndex = indexForComboBoxRow(WEP\cboDevMap, sDevMapName, 0)
    SGS(WEP\cboDevMap, nListIndex)
    WEP_cboDevMap_Click()
    
    WEP_setDevMapButtons()
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
  EndIf
  
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_doTestToneConfirm(bContinuousTestTone, sLogicalDev.s)
  PROCNAMEC()
  
  SGT(WEP\lblTestToneConfirm, LangPars("WEP", "lblTestToneConfirm", sLogicalDev))
  debugMsg(sProcName, GGT(WEP\lblTestToneConfirm))
  setEnabled(WEP\cboTestSound, #False) ; 3May2022pm 11.9.1
  
  If bContinuousTestTone
    setVisible(WEP\btnTestToneContinuous, #False)
    setVisible(WEP\btnTestToneCancel, #True)
    setEnabled(WEP\btnTestToneShort, #False)
  Else
    setVisible(WEP\btnTestToneCancel, #False)
    setVisible(WEP\btnTestToneContinuous, #True)
    AddWindowTimer(#WED, #SCS_TIMER_TEST_TONE, 1000)
    debugMsg(sProcName, "AddWindowTimer(#WED, #SCS_TIMER_TEST_TONE, 1000)")
  EndIf
  
EndProcedure

Procedure WEP_btnTestToneCommon_Click(bContinuousTestTone)
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapDevPtr, nAudioDriver
  Protected fDevLevel.f
  
  debugMsg(sProcName, #SCS_START + ", nCurrentAudDevNo=" + grWEP\nCurrentAudDevNo + ", grTestTone\bPlayingTestTone=" + strB(grTestTone\bPlayingTestTone))
  
  If grTestTone\bPlayingTestTone
    debugMsg(sProcName, "calling WEP_cancelTestTone()")
    WEP_cancelTestTone()
  EndIf
  
  If grWEP\nCurrentAudDevNo >= 0
    
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, grWEP\nCurrentAudDevNo)
    If nDevMapPtr < 0 Or nDevMapDevPtr < 0
      ProcedureReturn
    EndIf
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr + ", nAudioDriver=" + decodeDriver(nAudioDriver))
    
    Select nAudioDriver
      Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI ; BASS_DS, BASS_WASAPI
        If ED_valOneProdAudioDevice(grWEP\nCurrentAudDevNo)
          debugMsg(sProcName, "ED_valOneProdAudioDevice(" + grWEP\nCurrentAudDevNo + ") returned #True")
          ; added 10Jan2018 11.8.0cx as playing a DirectSound test tone via the mixer was throwing an error in playStreamProcTestToneToMixerStream() because \nMixerStreamPtr was -1
          If gbUseBASSMixer
            If getEnabled(WEP\btnApplyDevChgs)
              ; Error message: "When using the BASS Mixer, test tones cannot be processed while there are unapplied device changes. Please Apply or Undo your device changes."
              scsMessageRequester(grText\sTextValErr, Lang("Errors", "TestToneMixer"), #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
              ProcedureReturn
            EndIf
          EndIf
          ; end added 10Jan2018 11.8.0cx
          With grMapsForDevChgs\aDev(nDevMapDevPtr)
            If \sPhysicalDev
              If grProd\nTestSound = #SCS_TEST_TONE_PINK ; added 3May2022pm 11.9.1
                If playTestTone(grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan) ; Changed 4May2022 11.9.1
                  WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
                EndIf
              Else
                fDevLevel = grProdForDevChgs\aAudioLogicalDevs(grWEP\nCurrentAudDevNo)\fDfltBVLevel
                debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + grWEP\nCurrentAudDevNo + ")\fDfltBVLevel=" + traceLevel(fDevLevel))
                ; nb need to use \fDfltAudioLevel for streamTestTone() as this procedure will access grProd\fTestToneBVLevel
                If gbUseBASSMixer
                  debugMsg(sProcName, "calling playStreamProcTestToneToMixerStream(" + \nMixerStreamPtr + ", " + grWEP\nCurrentAudDevNo + ", " + formatLevel(grProd\fTestToneBVLevel) + ", " + formatPan(grProd\fTestTonePan) + ")")
                  If playStreamProcTestToneToMixerStream(\nMixerStreamPtr, grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan) ; Modified 4May2022 11.9.1
                    WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
                  EndIf
                Else
                  If playStreamProcTestTone(grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan)
                    WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
                  EndIf
                EndIf
              EndIf
            EndIf
          EndWith
        Else
          debugMsg(sProcName, "ED_valOneProdAudioDevice(" + grWEP\nCurrentAudDevNo + ") returned #False")
        EndIf
        
      Case #SCS_DRV_BASS_ASIO ; BASS_ASIO
        If ED_valOneProdAudioDevice(grWEP\nCurrentAudDevNo)
          debugMsg(sProcName, "ED_valOneProdAudioDevice(" + grWEP\nCurrentAudDevNo + ") returned #True")
          
          If getEnabled(WEP\btnApplyDevChgs)
            ; Error message: "Test tones for an ASIO device cannot be processed while there are unapplied device changes. Please Apply or Undo your device changes."
            scsMessageRequester(grText\sTextValErr, Lang("Errors", "TestToneASIO"), #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
            ProcedureReturn
          EndIf
          ; With gaDevForDevChgs(nDevMapDevPtr)
          With grMaps\aDev(nDevMapDevPtr)
            If \nMixerStreamPtr < 0
              debugMsg(sProcName, "calling mapAudLogicalDevsToPhysicalDevs(" + decodeDriver(nAudioDriver) + ")")
              mapAudLogicalDevsToPhysicalDevs(nAudioDriver)
              debugMsg(sProcName, "calling setCueBassDevsAndMidiPortNos()")
              setCueBassDevsAndMidiPortNos()
            EndIf
            ; debugMsg(sProcName, "gaDevForDevChgs(" + nDevMapDevPtr + ")\nMixerStreamPtr=" + \nMixerStreamPtr)
            debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\nMixerStreamPtr=" + \nMixerStreamPtr)
            If \nMixerStreamPtr >= 0
              
              ; the following commented out as it is repeated in playTestToneToMixerStream()
              ;If gaMixerStreams(\nMixerStreamPtr)\bRecreateMixerStream
              ;    createOneMixerStream(\nMixerStreamPtr, grWEP\nCurrentAudDevNo)
              ;    createMixerStreams()     ; calling createMixerStreams() forces any ASIO streams to be re-built
              ;EndIf
              If gbAsioInitDone
                If gbAsioStarted = #False
                  startAsioDevices()
                EndIf
              EndIf
              
              startVUDisplayIfReqd(#True)
              If grProd\nTestSound = #SCS_TEST_TONE_PINK ; added 3May2022pm 11.9.1
                If playTestTone(grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan) ; Modifed 4May2022 11.9.1
                  WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
                EndIf
              Else
                ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\nReassignDevMapDevPtr=" + \nReassignDevMapDevPtr)
                debugMsg(sProcName, "calling playStreamProcTestToneToMixerStream(" + \nMixerStreamPtr + ", " + grWEP\nCurrentAudDevNo + ", " + formatLevel(grProd\fTestToneBVLevel) + ", " + formatPan(grProd\fTestTonePan) + ", " + nDevMapDevPtr + ")")
                If playStreamProcTestToneToMixerStream(\nMixerStreamPtr, grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan, nDevMapDevPtr)
                  WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
                EndIf
              EndIf
              
            EndIf
          EndWith
          
        Else
          debugMsg(sProcName, "ED_valOneProdAudioDevice(" + grWEP\nCurrentAudDevNo + ") returned #False")
        EndIf
        
      Case #SCS_DRV_SMS_ASIO ; SM-S
        debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
        setEditLogicalDevsDerivedFields()
        If ED_valOneProdAudioDevice(grWEP\nCurrentAudDevNo)
          With grMapsForDevChgs\aDev(nDevMapDevPtr)
            If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
              debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
              initDevice(\nPhysicalDevPtr)
            EndIf
            startVUDisplayIfReqd(#True)
            If playTestTone(grWEP\nCurrentAudDevNo, grProd\fTestToneBVLevel, grProd\fTestTonePan) ; Modifed 4May2022 11.9.1
              WEP_doTestToneConfirm(bContinuousTestTone, \sLogicalDev)
            EndIf
          EndWith
        EndIf
        
    EndSelect
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnTestLiveInputStart_Click()
  PROCNAMEC()
  Protected nDevMapPtr, nDevMapDevPtr, nAudioDriver
  Protected nOutputDevNo
  
  debugMsg(sProcName, #SCS_START + ", nCurrentLiveDevNo=" + grWEP\nCurrentLiveDevNo + ", grTestLiveInput\bRunningTestLiveInput=" + strB(grTestLiveInput\bRunningTestLiveInput))
  
  If grTestLiveInput\bRunningTestLiveInput
    WEP_cancelTestLiveInput()
  EndIf
  
  If grWEP\nCurrentLiveDevNo >= 0
    
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, grWEP\nCurrentLiveDevNo)
    If nDevMapPtr < 0 Or nDevMapDevPtr < 0
      ProcedureReturn
    EndIf
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr + ", nAudioDriver=" + decodeDriver(nAudioDriver))
    
    Select nAudioDriver
      Case #SCS_DRV_SMS_ASIO ; SM-S
        debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
        setEditLogicalDevsDerivedFields()
        
        If ED_valOneProdAudioDevice(grWEP\nCurrentLiveDevNo)
          With grMapsForDevChgs\aDev(nDevMapDevPtr)
            If gaAudioDev(\nPhysicalDevPtr)\bInitialized = #False
              debugMsg(sProcName, "calling initDevice(" + \nPhysicalDevPtr + ")")
              initDevice(\nPhysicalDevPtr)
            EndIf
            nOutputDevNo = getCurrentItemData(WEP\cboOutputDevForTestLiveInput, -1)
            If nOutputDevNo >= 0
              startVUDisplayIfReqd(#True)
              If doTestLiveInput(grWEP\nCurrentLiveDevNo, nOutputDevNo)
                setVisible(WEP\btnTestLiveInputStart, #False)
                setVisible(WEP\btnTestLiveInputCancel, #True)
                setEnabled(WEP\cboOutputDevForTestLiveInput, #False)
              EndIf
            EndIf
          EndWith
        EndIf
        
    EndSelect
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnUndoDevChgs_Click()
  PROCNAMEC()
  Protected nDevMapPtr, nAudioDriver
  Protected d
  Protected bDMXPortUsageError.a
  Protected NewMap gmDMXPortsInUse.a()

  debugMsg(sProcName, #SCS_START)
  
  gbInUndoOrRedo = #True
  
  WEP_stopProdTestIfRunning()
  ;WEP_CheckForDMXPortDuplication(#SCS_WEP_DMX_CONFLICT_STATUSBAR)
  ED_loadDevChgsFromProd()
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    If gnCurrAudioDriver <> nAudioDriver
      debugMsg3(sProcName, "calling closeDevices(" + decodeDriver(gnCurrAudioDriver) + ")")
      closeDevices(gnCurrAudioDriver)
      setCurrAudioDriver(nAudioDriver)
    EndIf
  EndIf
  
  debugMsg(sProcName, "calling WEP_resetCurrentDataFields()")
  WEP_resetCurrentDataFields()
  
  debugMsg(sProcName, "calling wEP_clearDeviceFields()")
  WEP_clearDeviceFields()
  
  debugMsg(sProcName, "calling WEP_loadAndDisplayDevsForProd()")
  WEP_loadAndDisplayDevsForProd()
  
  debugMsg(sProcName, "calling loadMidiControl(#True)")
  loadMidiControl(#True)
  
  debugMsg(sProcName, "calling loadNetworkControl(#True)")
  loadNetworkControl(#True)

  ; debugMsg(sProcName, "devmap after undo:")
  ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev())
  
  WEP_setDevChgsBtns()
  WEP_setRetryActivateBtn()
  
  debugMsg(sProcName, "calling WEP_displayAudDev()")
  WEP_displayAudDev()
  If grLicInfo\nMaxVidAudDevPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayVidAudDev()")
    WEP_displayVidAudDev()
  EndIf
  If grLicInfo\nMaxVidCapDevPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayVidCapDev()")
    WEP_displayVidCapDev()
  EndIf
  If grLicInfo\nMaxFixTypePerProd >= 0
    debugMsg(sProcName, "calling WEP_displayFixType()")
    WEP_displayFixType()
  EndIf
  If grLicInfo\nMaxLightingDevPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayLightingDev()")
    WEP_displayLightingDev()
  EndIf
  If grLicInfo\nMaxCtrlSendDevPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayCtrlDev()")
    WEP_displayCtrlDev()
  EndIf
  If grLicInfo\nMaxCueCtrlDev >= 0
    debugMsg(sProcName, "calling WEP_displayCueDev()")
    WEP_displayCueDev()
  EndIf
  If grLicInfo\nMaxLiveDevPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayLiveDev()")
    WEP_displayLiveDev()
  EndIf
  If grLicInfo\nMaxInGrpPerProd >= 0
    debugMsg(sProcName, "calling WEP_displayInGrp()")
    WEP_displayInGrp()
  EndIf
  
  WEP_setDevMapButtons()
  
  debugMsg(sProcName, "calling setMasterFader(" + formatLevel(grMasterLevel\fProdMasterBVLevel) + ")")
  setMasterFader(grMasterLevel\fProdMasterBVLevel)
  debugMsg(sProcName, "calling setAllInputGains()")
  setAllInputGains()
  debugMsg(sProcName, "calling setAllLiveEQ()")
  setAllLiveEQ()
  
  SAG(-1)
  
  gbInUndoOrRedo = #False
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_cancelTestTone()
  PROCNAMEC()
  ; called by timer or by user clicking the cancel button
  
  RemoveWindowTimer(#WED, #SCS_TIMER_TEST_TONE)
  debugMsg(sProcName, "RemoveWindowTimer(#WED, #SCS_TIMER_TEST_TONE)")
  
  SGT(WEP\lblTestToneConfirm, "")
  debugMsg(sProcName, "calling stopTestTone()")
  stopTestTone()
  setEnabled(WEP\cboTestSound, #True) ; 3May2022pm 11.9.1
  WEP_setTestToneButtonsEnabledState()
  
EndProcedure

Procedure WEP_cancelTestLiveInput()
  PROCNAMEC()
  ; called by user clicking the cancel button
  
  debugMsg(sProcName, "calling stopTestLiveInput()")
  stopTestLiveInput()
  setVisible(WEP\btnTestLiveInputCancel, #False)
  setVisible(WEP\btnTestLiveInputStart, #True)
  WEP_setTestLiveInputButtonsEnabledState()
  
EndProcedure

Procedure WEP_populateOutputRange(Index)
  PROCNAMEC()
  Protected nNrOfOutputChans, nPhysicalDevPtr, nOutputs
  Protected n, s1BasedOutputRange.s
  Protected nDevMapPtr, nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  ClearGadgetItems(WEP\cboOutputRange(Index))

  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, Index)
  nNrOfOutputChans = grProdForDevChgs\aAudioLogicalDevs(Index)\nNrOfOutputChans
  
  If (nDevMapDevPtr >= 0) And (nNrOfOutputChans > 0)
    nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
    If nPhysicalDevPtr >= 0
      nOutputs = gaAudioDev(nPhysicalDevPtr)\nOutputs
      ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr + ", nNrOfOutputChans=" + Str(nNrOfOutputChans) + ", nPhysicalDevPtr=" + nPhysicalDevPtr + ",nOutputs=" + nOutputs)
      If gaAudioDev(nPhysicalDevPtr)\bASIO = #False And nOutputs = 2
        If nNrOfOutputChans = 1
          AddGadgetItem(WEP\cboOutputRange(Index), -1, "L")
          AddGadgetItem(WEP\cboOutputRange(Index), -1, "R")
        Else
          AddGadgetItem(WEP\cboOutputRange(Index), -1, "L-R")
        EndIf
      Else
        For n = 1 To (nOutputs - nNrOfOutputChans + 1)
          If nNrOfOutputChans = 1
            s1BasedOutputRange = Str(n)
          Else
            s1BasedOutputRange = Str(n) + "-" + Str(n + nNrOfOutputChans - 1)
          EndIf
          AddGadgetItem(WEP\cboOutputRange(Index), -1, s1BasedOutputRange)
        Next n
      EndIf
    Else
      AddGadgetItem(WEP\cboOutputRange(Index), -1, grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange)
    EndIf
  EndIf
  ; debugMsg(sProcName, "CountGadgetItems(WEP\cboOutputRange(" + Index + "))=" + CountGadgetItems(WEP\cboOutputRange(Index)))
  
EndProcedure

Procedure WEP_populateInGrpLiveInputs(nInGrpNo, nInGrpItemNo=-1)
  PROCNAMEC()
  Protected d, n
  Protected sLogicalDev.s
  Protected nFirstInGrpItemNo, nLastInGrpItemNo
  Protected nComboBoxWidth
  
  ; debugMsg(sProcName, #SCS_START + ", nInGrpNo=" + nInGrpNo + ", nInGrpItemNo=" + nInGrpItemNo)
  If nInGrpItemNo >= 0
    nFirstInGrpItemNo = nInGrpItemNo
    nLastInGrpItemNo = nInGrpItemNo
  Else
    nFirstInGrpItemNo = 0
    nLastInGrpItemNo = grProdForDevChgs\aInGrps(nInGrpNo)\nMaxInGrpItemDisplay
  EndIf
  ; debugMsg(sProcName, "nFirstInGrpItemNo=" + nFirstInGrpItemNo + ", nLastInGrpItemNo=" + nLastInGrpItemNo)
  
  With WEP
    For n = nFirstInGrpItemNo To nLastInGrpItemNo
      ; debugMsg0(sProcName, "ClearGadgetItems(\cboInGrpLiveInput(" + n + "))")
      ClearGadgetItems(\cboInGrpLiveInput(n))
      addGadgetItemWithData(\cboInGrpLiveInput(n), #SCS_BLANK_CBO_ENTRY, -1)
      For d = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
        sLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(d)\sLogicalDev
        If sLogicalDev
          ; debugMsg(sProcName, "addGadgetItemWithData(\cboInGrpLiveInput(" + n + "), " + sLogicalDev + ", " + d + ")")
          addGadgetItemWithData(\cboInGrpLiveInput(n), sLogicalDev, d)
          If nComboBoxWidth = 0
            setComboBoxWidth(\cboInGrpLiveInput(n))
            nComboBoxWidth = GadgetWidth(\cboInGrpLiveInput(n))
          Else
            If GadgetWidth(\cboInGrpLiveInput(n)) <> nComboBoxWidth
              ResizeGadget(\cboInGrpLiveInput(n), #PB_Ignore, #PB_Ignore, nComboBoxWidth, #PB_Ignore)
            EndIf
          EndIf
        EndIf
      Next d
    Next n
    ; now hide any remaining live input group items
    nFirstInGrpItemNo = grProdForDevChgs\aInGrps(nInGrpNo)\nMaxInGrpItemDisplay + 1
    nLastInGrpItemNo = ArraySize(\cboInGrpLiveInput())
    For n = nFirstInGrpItemNo To nLastInGrpItemNo
      If getVisible(\cboInGrpLiveInput(n))
        setVisible(\cboInGrpLiveInput(n), #False)
        SGS(\cboInGrpLiveInput(n), -1) ; ensures combobox doesn't automatically display some previous entry when next made visible
      EndIf
    Next n
  EndWith
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_populateInputRange(Index)
  PROCNAMEC()
  Protected nNrOfInputChans, nPhysicalDevPtr, nInputs
  Protected n, s1BasedInputRange.s
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  ClearGadgetItems(WEP\cboInputRange(Index))
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, Index)
  nNrOfInputChans = grProdForDevChgs\aLiveInputLogicalDevs(Index)\nNrOfInputChans
  debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr + ", nNrOfInputChans=" + nNrOfInputChans)
  If (nDevMapDevPtr >= 0) And (nNrOfInputChans > 0)
    nPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
    debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
    If nPhysicalDevPtr >= 0
      nInputs = gaAudioDev(nPhysicalDevPtr)\nInputs
    ElseIf grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
      nInputs = nNrOfInputChans
    EndIf
    debugMsg(sProcName, "nInputs=" + nInputs)
    For n = 1 To (nInputs - nNrOfInputChans + 1)
      If nNrOfInputChans = 1
        s1BasedInputRange = Str(n)
      Else
        s1BasedInputRange = Str(n) + "-" + Str(n + nNrOfInputChans - 1)
      EndIf
      AddGadgetItem(WEP\cboInputRange(Index), -1, s1BasedInputRange)
    Next n
  EndIf
  debugMsg(sProcName, "CountGadgetItems(WEP\cboInputRange[" + Index + "])=" + CountGadgetItems(WEP\cboInputRange(Index)))
  
EndProcedure

Procedure WEP_resizeDMXOutDevInfo(bPortVisible, bRefreshRateVisible, bArtnetIpAddressVisible)
  PROCNAMEC()
  Protected nComboBoxWidth, nContainerWidth
  Protected nLabelRight, nComboBoxRight
  Protected nLeft, nWidth
  
  With WEP
    ; make combobox wider if necessary (which may be necessary for the Pro Mk2 port info)
    nComboBoxWidth = GadgetWidth(\cboDMXPhysDev[0])
    setComboBoxWidth(\cboDMXPhysDev[0], nComboBoxWidth)
    nLabelRight = GadgetX(\lblDMXPhysDev[0]) + GadgetWidth(\lblDMXPhysDev[0])
    nComboBoxRight = GadgetX(\cboDMXPhysDev[0]) + GadgetWidth(\cboDMXPhysDev[0])
    If nComboBoxRight > nLabelRight
      nLeft = nComboBoxRight + 12
    Else
      nLeft = nLabelRight + 12
    EndIf
    If bPortVisible
      ResizeGadget(\lblDMXPort[0], nLeft+2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cboDMXPort[0], nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLabelRight = GadgetX(\lblDMXPort[0]) + GadgetWidth(\lblDMXPort[0])
      nComboBoxRight = GadgetX(\cboDMXPort[0]) + GadgetWidth(\cboDMXPort[0])
      If nComboBoxRight > nLabelRight
        nLeft = nComboBoxRight + 12
      Else
        nLeft = nLabelRight + 12
      EndIf
    EndIf
    If bRefreshRateVisible
      ResizeGadget(\lblDMXRefreshRate, nLeft+2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cboDMXRefreshRate, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLabelRight = GadgetX(\lblDMXRefreshRate) + GadgetWidth(\lblDMXRefreshRate)
      nComboBoxRight = GadgetX(\cboDMXRefreshRate) + GadgetWidth(\cboDMXRefreshRate)
      If nComboBoxRight > nLabelRight
        nLeft = nComboBoxRight + 12
      Else
        nLeft = nLabelRight + 12
      EndIf
    EndIf
    nContainerWidth = nLeft
    ResizeGadget(\cntPhysDMX[0], #PB_Ignore, #PB_Ignore, nContainerWidth, #PB_Ignore)
    
    If bArtnetIpAddressVisible
      ResizeGadget(\lblDMXIpAddress, nLeft+2, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ResizeGadget(\cboDMXIpAddress, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nLabelRight = GadgetX(\lblDMXIpAddress) + GadgetWidth(\lblDMXIpAddress)
      nComboBoxRight = GadgetX(\cboDMXIpAddress) + GadgetWidth(\cboDMXIpAddress)
      
      If nComboBoxRight > nLabelRight
        nLeft = nComboBoxRight + 12
      Else
        nLeft = nLabelRight + 12
      EndIf
      
      ResizeGadget(\btnDMXIPRefresh, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      nComboBoxRight = GadgetX(\btnDMXIPRefresh) + GadgetWidth(\btnDMXIPRefresh)
      
      If nComboBoxRight > nLabelRight
        nLeft = nComboBoxRight + 12
      Else
        nLeft = nLabelRight + 12
      EndIf

    EndIf
    nContainerWidth = nLeft
    ResizeGadget(\cntPhysDMX[0], #PB_Ignore, #PB_Ignore, nContainerWidth, #PB_Ignore)
  EndWith
  
EndProcedure

Procedure WEP_populateDevTypeComboBoxes(nDevType)
  PROCNAMEC()
  Protected m, n, nIndex, sHexValue.s, sTmp.s
  Protected d2, d3, bFound, sPhysicalDev.s
  Protected sDMXSerial.s, nDMXSerial.l
  Protected sDMXPhysicalDev.s
  Protected nDevMapPtr
  Protected nLeft
  Protected nGadgetNo
  Protected qTimeNow.q, qStartTime.q, qPartTime.q
  Protected nCmdNo, nDisplayIndex, bDisplayThis, d ; Added 6Jun2022 11.9.2ag
  
  debugMsg(sProcName, #SCS_START + ", nDevType=" + decodeDevType(nDevType))
  
  qStartTime = ElapsedMilliseconds()
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  
  Select nDevType
    Case #SCS_DEVTYPE_CS_MIDI_OUT ; NOTE: #SCS_DEVTYPE_CS_MIDI_OUT
      ;{
      ClearGadgetItems(WEP\cboMidiOutPort)
      For n = 0 To (gnNumMidiOutDevs-1)
        If gaMidiOutDevice(n)\bIgnoreDev = #False
          addGadgetItemWithData(WEP\cboMidiOutPort, gaMidiOutDevice(n)\sName, n)
        EndIf
      Next n
      grWEP\bCtrlMidiOutComboBoxesPopulated = #True
      ;}
    Case #SCS_DEVTYPE_CS_MIDI_THRU ; NOTE: #SCS_DEVTYPE_CS_MIDI_THRU
      ;{
      ClearGadgetItems(WEP\cboMidiThruOutPort)
      For n = 0 To (gnNumMidiOutDevs-1)
        If gaMidiOutDevice(n)\bIgnoreDev = #False
          addGadgetItemWithData(WEP\cboMidiThruOutPort, gaMidiOutDevice(n)\sName, n)
        EndIf
      Next n
      ClearGadgetItems(WEP\cboMidiThruInPort)
      For n = 0 To (gnNumMidiInDevs-1)
        addGadgetItemWithData(WEP\cboMidiThruInPort, gaMidiInDevice(n)\sName, n)
      Next n
      grWEP\bCtrlMidiThruComboBoxesPopulated = #True
      ;}
    Case #SCS_DEVTYPE_CC_MIDI_IN ; NOTE: #SCS_DEVTYPE_CC_MIDI_IN
      ;{
      ClearGadgetItems(WEP\cboMidiInPort)
      For n = 0 To (gnNumMidiInDevs-1)
        addGadgetItemWithData(WEP\cboMidiInPort, gaMidiInDevice(n)\sName, n)
      Next n
      
      ; debugMsg(sProcName, "WEP\cboMidiChannel")
      ClearGadgetItems(WEP\cboMidiChannel)
      AddGadgetItem(WEP\cboMidiChannel, -1, (#SCS_BLANK_CBO_ENTRY))
      For n = 1 To 16
        AddGadgetItem(WEP\cboMidiChannel, -1, Trim(Str(n)))
      Next n
      
      ; debugMsg(sProcName, "WEP\cboMidiDevId")
      ClearGadgetItems(WEP\cboMidiDevId)
      AddGadgetItem(WEP\cboMidiDevId, -1, #SCS_BLANK_CBO_ENTRY)
      For n = 0 To 127
        sHexValue = Right("0" + Hex(n), 2)
        AddGadgetItem(WEP\cboMidiDevId, -1, Trim(Str(n) + "   " + sHexValue + "H"))
      Next n
      
      ; debugMsg(sProcName, "WEP\cboGoMacro")
      ClearGadgetItems(WEP\cboGoMacro)
      ; AddGadgetItem(WEP\cboGoMacro, -1, #SCS_BLANK_CBO_ENTRY)
      For n = 0 To 127
        sHexValue = Right("0" + Hex(n), 2)
        AddGadgetItem(WEP\cboGoMacro, -1, Trim(Str(n) + "   " + sHexValue + "H"))
      Next n
      
      ; debugMsg(sProcName, "WEP\cboMSCCommandFormat")
      ClearGadgetItems(WEP\cboMSCCommandFormat)
      AddGadgetItem(WEP\cboMSCCommandFormat, -1, #SCS_BLANK_CBO_ENTRY)
      For n = 0 To 126
        sTmp = Trim(Right("0" + Hex(n), 2) + "H  " + decodeCommandFormatL(n))
        AddGadgetItem(WEP\cboMSCCommandFormat, -1, sTmp)
      Next n
      
      ; debugMsg(sProcName, "WEP\cboCtrlMethod")
      ClearGadgetItems(WEP\cboCtrlMethod)
      addGadgetItemWithData(WEP\cboCtrlMethod, #SCS_BLANK_CBO_ENTRY, #SCS_CTRLMETHOD_NONE)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_NOTE), #SCS_CTRLMETHOD_NOTE)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_PC127), #SCS_CTRLMETHOD_PC127)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_PC128), #SCS_CTRLMETHOD_PC128)
      If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
        addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_MTC), #SCS_CTRLMETHOD_MTC)
      EndIf
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_MSC), #SCS_CTRLMETHOD_MSC)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_MMC), #SCS_CTRLMETHOD_MMC)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_ETC_AB), #SCS_CTRLMETHOD_ETC_AB)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_ETC_CD), #SCS_CTRLMETHOD_ETC_CD)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_PALLADIUM), #SCS_CTRLMETHOD_PALLADIUM)
      addGadgetItemWithData(WEP\cboCtrlMethod, decodeCtrlMethodL(#SCS_CTRLMETHOD_CUSTOM), #SCS_CTRLMETHOD_CUSTOM)
      
      qPartTime = ElapsedMilliseconds()
      nDisplayIndex = -1 ; Added 6Jun2022
      For nCmdNo = 0 To gnMaxMidiCommand ; Changed 6Jun2022
        bDisplayThis = WEP_setDisplayThisForMidiCmd(nCmdNo)
        If bDisplayThis = #False
          Continue
        EndIf
        nDisplayIndex + 1
        nGadgetNo = WEP\cboMidiCommand[nDisplayIndex]
        ClearGadgetItems(nGadgetNo)
        ; NOTE: gadget item data is MIDI command 'status' value, eg $8 is the Note Off
        addGadgetItemWithData(nGadgetNo, #SCS_BLANK_CBO_ENTRY, -1)
        If nCmdNo = #SCS_MIDI_EXT_FADER
          addGadgetItemWithData(nGadgetNo, "Control Change", $B)
          If GadgetY(WEP\cboThresholdVV) <> GadgetY(nGadgetNo)
            ResizeGadget(WEP\cboThresholdVV, #PB_Ignore, GadgetY(nGadgetNo), #PB_Ignore, #PB_Ignore)
            ResizeGadget(WEP\lblThresholdVV, #PB_Ignore, GadgetY(nGadgetNo) + gnLblVOffsetC, #PB_Ignore, #PB_Ignore)
          EndIf
        Else
          addGadgetItemWithData(nGadgetNo, "Note Off", $8)
          addGadgetItemWithData(nGadgetNo, "Note On", $9)
          addGadgetItemWithData(nGadgetNo, "Key Pressure", $A)
          addGadgetItemWithData(nGadgetNo, "Control Change (value)", $B)
          If nCmdNo = #SCS_MIDI_PLAY_CUE
            addGadgetItemWithData(nGadgetNo, "Control Change (number)", $200B)
          EndIf
          If (nCmdNo <> #SCS_MIDI_OPEN_FAV_FILE) And (nCmdNo <> #SCS_MIDI_SET_HOTKEY_BANK)
            addGadgetItemWithData(nGadgetNo, "Program Change", $C)
            addGadgetItemWithData(nGadgetNo, "Channel Pressure", $D)
            addGadgetItemWithData(nGadgetNo, "Pitch Bend", $E)
          EndIf
        EndIf
        
      Next nCmdNo
      
      grWEP\bCueMidiInComboBoxesPopulated = #True
      qTimeNow = ElapsedMilliseconds()
      debugMsg(sProcName, "part time: " + Str(qTimeNow - qPartTime))
      ;}
    Case #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CC_RS232_IN ; NOTE: #SCS_DEVTYPE_CS_RS232_OUT, #SCS_DEVTYPE_CC_RS232_IN
      ;{
      If nDevType = #SCS_DEVTYPE_CS_RS232_OUT
        nIndex = 0
      Else
        nIndex = 1
      EndIf
      ClearGadgetItems(WEP\cboRS232Port[nIndex])
      For n = 0 To gnMaxRS232Control
        With gaRS232Control(n)
          addGadgetItemWithData(WEP\cboRS232Port[nIndex], \sRS232PortAddress, n)
        EndWith
      Next n
      
      ClearGadgetItems(WEP\cboRS232DataBits[nIndex])
      AddGadgetItemWithData(WEP\cboRS232DataBits[nIndex], "5", 5)
      AddGadgetItemWithData(WEP\cboRS232DataBits[nIndex], "6", 6)
      AddGadgetItemWithData(WEP\cboRS232DataBits[nIndex], "7", 7)
      AddGadgetItemWithData(WEP\cboRS232DataBits[nIndex], "8", 8)
      
      ClearGadgetItems(WEP\cboRS232StopBits[nIndex])
      AddGadgetItemWithData(WEP\cboRS232StopBits[nIndex], "1", 10)
      AddGadgetItemWithData(WEP\cboRS232StopBits[nIndex], "1.5", 15)
      AddGadgetItemWithData(WEP\cboRS232StopBits[nIndex], "2", 20)
      
      ClearGadgetItems(WEP\cboRS232Parity[nIndex])
      ; text taken from PB help for OpenSerialPort()
      AddGadgetItemWithData(WEP\cboRS232Parity[nIndex], Lang("RS232", "NoParity"), #PB_SerialPort_NoParity)
      AddGadgetItemWithData(WEP\cboRS232Parity[nIndex], Lang("RS232", "EvenParity"), #PB_SerialPort_EvenParity)
      AddGadgetItemWithData(WEP\cboRS232Parity[nIndex], Lang("RS232", "MarkParity"), #PB_SerialPort_MarkParity)
      AddGadgetItemWithData(WEP\cboRS232Parity[nIndex], Lang("RS232", "OddParity"), #PB_SerialPort_OddParity)
      AddGadgetItemWithData(WEP\cboRS232Parity[nIndex], Lang("RS232", "SpaceParity"), #PB_SerialPort_SpaceParity)
      
      ClearGadgetItems(WEP\cboRS232BaudRate[nIndex])
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "300", 300)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "600", 600)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "1200", 1200)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "2400", 2400)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "4800", 4800)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "9600", 9600)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "14400", 14400)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "19200", 19200)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "28800", 28800)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "38400", 38400)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "56000", 56000)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "57600", 57600)
      AddGadgetItemWithData(WEP\cboRS232BaudRate[nIndex], "115200", 115200)
      
      ClearGadgetItems(WEP\cboRS232Handshaking[nIndex])
      ; text taken from PB help for OpenSerialPort()
      AddGadgetItemWithData(WEP\cboRS232Handshaking[nIndex], Lang("RS232", "NoHandshake"), #PB_SerialPort_NoHandshake)
      AddGadgetItemWithData(WEP\cboRS232Handshaking[nIndex], Lang("RS232", "XonXoffHandshake"), #PB_SerialPort_XonXoffHandshake)
      AddGadgetItemWithData(WEP\cboRS232Handshaking[nIndex], Lang("RS232", "RtsCtsHandshake"), #PB_SerialPort_RtsCtsHandshake)
      AddGadgetItemWithData(WEP\cboRS232Handshaking[nIndex], Lang("RS232", "RtsHandshake"), #PB_SerialPort_RtsHandshake)
      
      ClearGadgetItems(WEP\cboRS232RTSEnable[nIndex])
      AddGadgetItemWithData(WEP\cboRS232RTSEnable[nIndex], Lang("Common", "No"), 0)
      AddGadgetItemWithData(WEP\cboRS232RTSEnable[nIndex], Lang("Common", "Yes"), 1)
      
      ClearGadgetItems(WEP\cboRS232DTREnable[nIndex])
      AddGadgetItemWithData(WEP\cboRS232DTREnable[nIndex], Lang("Common", "No"), 0)
      AddGadgetItemWithData(WEP\cboRS232DTREnable[nIndex], Lang("Common", "Yes"), 1)
      
      If nDevType = #SCS_DEVTYPE_CS_RS232_OUT
        grWEP\bCtrlRS232ComboBoxesPopulated = #True
      Else
        grWEP\bCueRS232ComboBoxesPopulated = #True
      EndIf
      ;}
    Case #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_CC_NETWORK_IN ; NOTE: #SCS_DEVTYPE_CS_NETWORK_OUT, #SCS_DEVTYPE_CC_NETWORK_IN
      ;{
      If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
        nIndex = 0
      Else
        nIndex = 1
      EndIf
      ClearGadgetItems(WEP\cboNetworkRole[nIndex])
      addGadgetItemWithData(WEP\cboNetworkRole[nIndex], Lang("Network", "Client(Long)"), #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT)
      addGadgetItemWithData(WEP\cboNetworkRole[nIndex], Lang("Network", "Server(Long)"), #SCS_NETWORK_ROLE_SCS_IS_A_SERVER)
      addGadgetItemWithData(WEP\cboNetworkRole[nIndex], Lang("Network", "Dummy"), #SCS_ROLE_DUMMY)
      setComboBoxWidth(WEP\cboNetworkRole[nIndex])
      ; Added 19Sep2022 11.9.6
      If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
        nLeft = GadgetX(WEP\cboNetworkRole[nIndex]) + GadgetWidth(WEP\cboNetworkRole[nIndex]) + 12
        ResizeGadget(WEP\chkConnectWhenReqd, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
      ; End added 19Sep2022 11.9.6
      If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
        grWEP\bCtrlNetworkComboBoxesPopulated = #True
      Else
        grWEP\bCueNetworkComboBoxesPopulated = #True
      EndIf
      ;}
    Case #SCS_DEVTYPE_LT_DMX_OUT, #SCS_DEVTYPE_CC_DMX_IN ; NOTE: #SCS_DEVTYPE_LT_DMX_OUT, #SCS_DEVTYPE_CC_DMX_IN
      ;{
      If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        nIndex = 0
      Else
        nIndex = 1
      EndIf
      ClearGadgetItems(WEP\cboDMXPhysDev[nIndex])
      For n = 0 To grDMX\nNumDMXDevs - 1
        debugMsg(sProcName, "gaDMXDevice(" + n + ")\sName=" + gaDMXDevice(n)\sName + ", \nSerial=" + gaDMXDevice(n)\nSerial + ", \sSerial=" + gaDMXDevice(n)\sSerial)
        sTmp = gaDMXDevice(n)\sName
        If gaDMXDevice(n)\nSerial
          sTmp + " (" + gaDMXDevice(n)\nSerial + ")"
        ElseIf Len(gaDMXDevice(n)\sSerial) > 0
          sTmp + " (" + gaDMXDevice(n)\sSerial + ")"
        EndIf
        
        ; Added to Skip devices with DMX input until the DMX input routine can handle these devices as it currently has no way to process anything other than FTDI devices.
        If (gaDMXDevice(n)\sName ="Art-Net" Or gaDMXDevice(n)\sName = "sACN") And nDevType = #SCS_DEVTYPE_CC_DMX_IN
          debugMsg(sProcName, "Skipped addGadgetItemWithData(WEP\cboDMXPhysDev[" + nIndex + "], " + #DQUOTE$ + sTmp + #DQUOTE$ + ", " + n + ")")
        Else
          addGadgetItemWithData(WEP\cboDMXPhysDev[nIndex], sTmp, n)
          debugMsg(sProcName, "addGadgetItemWithData(WEP\cboDMXPhysDev[" + nIndex + "], " + #DQUOTE$ + sTmp + #DQUOTE$ + ", " + n + ")")
        EndIf
      Next n
      ; ClearGadgetItems(WEP\cboDMXPort[nIndex])
      ; add any physical dmx devices listed in the device map which are not in the list of currently available devices
      d3 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
      While d3 >= 0
        debugMsg(sProcName, "d3=" + d3 + ", grMapsForDevChgs\aDev(" + d3 + ")\nDevType=" + decodeDevType(grMapsForDevChgs\aDev(d3)\nDevType) + ", grMapsForDevChgs\aDev(" + d3 + ")\bExists=" + strB(grMapsForDevChgs\aDev(d3)\bExists))
        If (grMapsForDevChgs\aDev(d3)\nDevType = nDevType) And (grMapsForDevChgs\aDev(d3)\bExists)
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d3 + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(d3)\sPhysicalDev)
          sPhysicalDev = grMapsForDevChgs\aDev(d3)\sPhysicalDev
          nDMXSerial = grMapsForDevChgs\aDev(d3)\nDMXSerial
          sDMXSerial = grMapsForDevChgs\aDev(d3)\sDMXSerial
          If sPhysicalDev
            bFound = #False
            If nDMXSerial
              For d2 = 0 To (grDMX\nNumDMXDevs-1)
                If (gaDMXDevice(d2)\sName = sPhysicalDev) And (gaDMXDevice(d2)\nSerial = nDMXSerial)
                  bFound = #True
                  Break
                EndIf
              Next d2
            EndIf
            If bFound = #False
              ; nb do not check for sDMXSerial being present as it will be blank for 'Dummy DMX Port'
              For d2 = 0 To (grDMX\nNumDMXDevs-1)
                If (gaDMXDevice(d2)\sName = sPhysicalDev) And (gaDMXDevice(d2)\sSerial = sDMXSerial)
                  bFound = #True
                  Break
                EndIf
              Next d2
            EndIf
            If bFound = #False
              sDMXPhysicalDev = sPhysicalDev
              If nDMXSerial
                sDMXPhysicalDev + " (" + nDMXSerial + ")"
              ElseIf sDMXSerial
                sDMXPhysicalDev + " (" + sDMXSerial + ")"
              EndIf
              addGadgetItemWithData(WEP\cboDMXPhysDev[nIndex],  sDMXPhysicalDev, -1)   ; -1 in data indicates unavailable device
              debugMsg(sProcName, "addGadgetItemWithData(WEP\cboAudioPhysicalDev(" + nIndex + "), " + #DQUOTE$ + sDMXPhysicalDev + #DQUOTE$ + ", -1)")
            EndIf
          EndIf
        EndIf
        d3 = grMapsForDevChgs\aDev(d3)\nNextDevIndex
      Wend
      If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        ClearGadgetItems(WEP\cboDMXRefreshRate)
        ; addGadgetItemWithData(WEP\cboDMXRefreshRate, Lang("Common", "None"), 0)
        For n = 25 To 40
          addGadgetItemWithData(WEP\cboDMXRefreshRate, Str(n)+" fps", n)
        Next n
        addGadgetItemWithData(WEP\cboDMXRefreshRate, Lang("Common", "None"), 0)
        setComboBoxWidth(WEP\cboDMXRefreshRate)
        ; WEP_resizeDMXOutDevInfo()
        
        ClearGadgetItems(WEP\cboDMXIpAddress)                                         ; Added 17-Jan 2025 by Dee, fix for customers selecting incorrect IP's   
        addGadgetItemWithData(WEP\cboDMXIpAddress, "127.0.0.1", 0)                    ; The local loopback always exists                            
        GetAdaptersInfo()
        n = 1
     
        ForEach myIpAdaptor_l.MyIP_ADAPTER_INFO() 
          If myIpAdaptor_l()\ipAddress <> "0.0.0.0"                                  
            addGadgetItemWithData(WEP\cboDMXIpAddress,  myIpAdaptor_l()\ipAddress, n)
            n + 1
          EndIf
        Next
      EndIf
      
      If GetGadgetState(WEP\cboDMXIpAddress) = -1
        SetGadgetState(WEP\cboDMXIpAddress, 0)
      EndIf
      grWEP\bLightingComboBoxesPopulated = #True
      ;}
    Case #SCS_DEVTYPE_CS_HTTP_REQUEST ; NOTE: #SCS_DEVTYPE_CS_HTTP_REQUEST
      ; no action
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayDevChgsItems()
  PROCNAMEC()
  Protected d, nListIndex, n
  Protected nDevMapPtr, nDevMapDevPtr
  Protected sDevMapName.s
  Protected sMyLogicalDev.s
  Protected nAudioDriver
  
  debugMsg(sProcName, #SCS_START)
  
  grWEP\bInDisplayDevMap = #True
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  ED_setDevDisplayMaximums(@grProdForDevChgs)
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    sDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver))
  EndIf
  
  WEP_populateDevMapComboBox()
  nListIndex = indexForComboBoxRow(WEP\cboDevMap, sDevMapName, 0)
  SGS(WEP\cboDevMap, nListIndex)
  
  nListIndex = indexForComboBoxData(WEP\cboAudioDriver, nAudioDriver, -1)
  If nListIndex >= 0
    SGS(WEP\cboAudioDriver, nListIndex)
  EndIf
  
  ; audio output
  ;{
  For d = 0 To grProdForDevChgs\nMaxAudioLogicalDev
    If nDevMapPtr < 0
      SGS(WEP\cboAudioPhysicalDev(d), -1)
      scsToolTip(WEP\cboAudioPhysicalDev(d), "")
      SGS(WEP\cboOutputRange(d), -1)
      If gbDelayTimeAvailable
        SGT(WEP\txtOutputDelayTime(d), "")
      EndIf
      SLD_setLevel(WEP\sldAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
      SGT(WEP\txtAudOutputGainDB(d), "")
      setOwnState(WEP\chkAudActive(d), #False)
    Else
      sMyLogicalDev = grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev
      If Len(sMyLogicalDev) = 0
        SGS(WEP\cboAudioPhysicalDev(d), -1)
        setCboToolTipAtSelectedText(WEP\cboAudioPhysicalDev(d))
        ClearGadgetItems(WEP\cboOutputRange(d))
        If gbDelayTimeAvailable
          SGT(WEP\txtOutputDelayTime(d), "")
        EndIf
        SLD_setLevel(WEP\sldAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
        SGT(WEP\txtAudOutputGainDB(d), "")
        setOwnState(WEP\chkAudActive(d), #False)
      Else
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev, nDevMapPtr)
        ; debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + d + ")\sLogicalDev=" + grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr >= 0
          With grMapsForDevChgs\aDev(nDevMapDevPtr)
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + \sPhysicalDev + ", \bDefaultDev=" + strB(\bDefaultDev))
            nListIndex = indexForComboBoxRow(WEP\cboAudioPhysicalDev(d), \sPhysicalDev, -1)
            SGS(WEP\cboAudioPhysicalDev(d), nListIndex)
            ; debugMsg(sProcName, "SetGadgetState(WEP\cboAudioPhysicalDev(" + d + "), " + nListIndex + ")")
            setCboToolTipAtSelectedText(WEP\cboAudioPhysicalDev(d))
            ; debugMsg(sProcName, "calling WEP_populateOutputRange(" + d + ")")
            WEP_populateOutputRange(d)
            nListIndex = indexForComboBoxRow(WEP\cboOutputRange(d), \s1BasedOutputRange, -1)
            ; debugMsg2(sProcName, "indexForComboBoxRow(WEP\cboOutputRange[" + d + "], " + \s1BasedOutputRange + ", -1)", nListIndex)
            SGS(WEP\cboOutputRange(d), nListIndex)
            If gbDelayTimeAvailable
              SGT(WEP\txtOutputDelayTime(d), IntToStrBWZ(\nDelayTime))
            EndIf
            SLD_setLevel(WEP\sldAudOutputGain(d), convertDBStringToBVLevel(\sDevOutputGainDB))
            SGT(WEP\txtAudOutputGainDB(d), \sDevOutputGainDB)
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(\nDevState) + ", \sLogicalDev=" + \sLogicalDev)
            If \nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkAudActive(d), #True)
            Else
              setOwnState(WEP\chkAudActive(d), #False)
            EndIf
          EndWith
        Else
          setOwnState(WEP\chkAudActive(d), #False)
        EndIf
      EndIf
    EndIf
  Next d
  For d = grProdForDevChgs\nMaxAudioLogicalDev + 1 To ArraySize(WEP\lblAudDevNo())
    SGS(WEP\cboAudioPhysicalDev(d), -1)
    scsToolTip(WEP\cboAudioPhysicalDev(d), "")
    SGS(WEP\cboOutputRange(d), -1)
    If gbDelayTimeAvailable
      SGT(WEP\txtOutputDelayTime(d), "")
    EndIf
    SLD_setLevel(WEP\sldAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
    SGT(WEP\txtAudOutputGainDB(d), "")
    setOwnState(WEP\chkAudActive(d), #False)
  Next d
  ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_AUDIO_OUTPUT) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  ;}
  ; video audio output
  ;{
  If grLicInfo\nMaxVidAudDevPerProd >= 0
    For d = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
      If nDevMapPtr < 0
        SGS(WEP\cboVidAudPhysicalDev(d), -1)
        scsToolTip(WEP\cboVidAudPhysicalDev(d), "")
        SLD_setLevel(WEP\sldVidAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
        SGT(WEP\txtVidAudOutputGainDB(d), "")
      Else
        sMyLogicalDev = grProdForDevChgs\aVidAudLogicalDevs(d)\sVidAudLogicalDev
        If Len(sMyLogicalDev) = 0
          SGS(WEP\cboVidAudPhysicalDev(d), -1)
          ; debugMsg(sProcName, "SGS(WEP\cboVidAudPhysicalDev(" + d + "), -1)")
          setCboToolTipAtSelectedText(WEP\cboVidAudPhysicalDev(d))
          SLD_setLevel(WEP\sldVidAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
          SGT(WEP\txtVidAudOutputGainDB(d), "")
        Else
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_AUDIO, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "grProdForDevChgs\aVidAudLogicalDevs(" + d + ")\sVidAudLogicalDev=" + grProdForDevChgs\aVidAudLogicalDevs(d)\sVidAudLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            With grMapsForDevChgs\aDev(nDevMapDevPtr)
              nListIndex = indexForComboBoxRow(WEP\cboVidAudPhysicalDev(d), \sPhysicalDev, -1)
              SGS(WEP\cboVidAudPhysicalDev(d), nListIndex)
              ; debugMsg(sProcName, "SGS(WEP\cboVidAudPhysicalDev(" + d + "), " + nListIndex + ")")
              setCboToolTipAtSelectedText(WEP\cboVidAudPhysicalDev(d))
              SLD_setLevel(WEP\sldVidAudOutputGain(d), convertDBStringToBVLevel(\sDevOutputGainDB))
              SGT(WEP\txtVidAudOutputGainDB(d), \sDevOutputGainDB)
              ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(\nDevState) + ", \sLogicalDev=" + \sLogicalDev)
            EndWith
          EndIf
        EndIf
      EndIf
    Next d
    For d = grProdForDevChgs\nMaxVidAudLogicalDev + 1 To ArraySize(WEP\lblVidAudDevNo())
      SGS(WEP\cboVidAudPhysicalDev(d), -1)
      scsToolTip(WEP\cboVidAudPhysicalDev(d), "")
      SLD_setLevel(WEP\sldVidAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
      SGT(WEP\txtVidAudOutputGainDB(d), "")
    Next d
;     d = grProdForDevChgs\nMaxVidAudLogicalDevDisplay
;     If IsGadget(WEP\cboVidAudPhysicalDev(d))
;       If Len(GGT(WEP\txtVidAudLogicalDev(d))) = 0 And CountGadgetItems(WEP\cboVidAudPhysicalDev(d)) > 0
;         SGS(WEP\cboVidAudPhysicalDev(d), -1)
;         ; debugMsg(sProcName, "SGS(WEP\cboVidAudPhysicalDev(" + d + "), -1)")
;       EndIf
;     EndIf
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_VIDEO_AUDIO) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  EndIf
  ;}
  ; video capture
  ;{
  If grLicInfo\nMaxVidCapDevPerProd >= 0 ; test added 24Jan2024 11.10.1
    For d = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
      If nDevMapPtr < 0
        SGS(WEP\cboVidCapPhysicalDev(d), -1)
        scsToolTip(WEP\cboVidCapPhysicalDev(d), "")
      Else
        sMyLogicalDev = grProdForDevChgs\aVidCapLogicalDevs(d)\sLogicalDev
        If Len(sMyLogicalDev) = 0
          ; debugMsg(sProcName, "SGS(WEP\cboVidCapPhysicalDev(" + d + "), -1)")
          SGS(WEP\cboVidCapPhysicalDev(d), -1)
          setCboToolTipAtSelectedText(WEP\cboVidCapPhysicalDev(d))
        Else
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_CAPTURE, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "grProdForDevChgs\aVidCapLogicalDevs(" + d + ")\sLogicalDev=" + grProdForDevChgs\aVidCapLogicalDevs(d)\sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            With grMapsForDevChgs\aDev(nDevMapDevPtr)
              nListIndex = indexForComboBoxRow(WEP\cboVidCapPhysicalDev(d), \sPhysicalDev, -1)
              SGS(WEP\cboVidCapPhysicalDev(d), nListIndex)
              ; debugMsg(sProcName, "SGS(WEP\cboVidCapPhysicalDev(" + d + "), " + nListIndex + ")")
              setCboToolTipAtSelectedText(WEP\cboVidCapPhysicalDev(d))
              ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(\nDevState) + ", \sLogicalDev=" + \sLogicalDev)
            EndWith
          EndIf
        EndIf
      EndIf
    Next d
    For d = grProdForDevChgs\nMaxVidCapLogicalDev + 1 To ArraySize(WEP\lblVidCapDevNo())
      SGS(WEP\cboVidCapPhysicalDev(d), -1)
      scsToolTip(WEP\cboVidCapPhysicalDev(d), "")
    Next d
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_VIDEO_CAPTURE) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  EndIf
  ;}
  ; fixture types
  If grLicInfo\nMaxFixTypePerProd >= 0 ; test added 24Jan2024 11.10.1
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_FIX_TYPE)
  EndIf
  ; lighting
  ;{
  If grLicInfo\nMaxLightingDevPerProd >= 0 ; test added 24Jan2024 11.10.1
    For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
      If nDevMapPtr < 0
        SGT(WEP\txtLightingPhysDevInfo(d), "")
        setOwnState(WEP\chkLightingActive(d), #False)
      Else
        sMyLogicalDev = grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev
        If Len(sMyLogicalDev) = 0
          SGT(WEP\txtLightingPhysDevInfo(d), "")
          setOwnState(WEP\chkLightingActive(d), #False)
        Else
          WEP_displayLightingPhysInfo(d)
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + d + ")\sLogicalDev=" + grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkLightingActive(d), #True)
            Else
              setOwnState(WEP\chkLightingActive(d), #False)
            EndIf
          Else
            setOwnState(WEP\chkLightingActive(d), #False)
          EndIf
          ; debugMsg(sProcName, "getOwnState(WEP\chkLightingActive[" + d + "])=" + getOwnState(WEP\chkLightingActive(d)))
        EndIf
      EndIf
    Next d
    For d = grProdForDevChgs\nMaxLightingLogicalDev + 1 To ArraySize(WEP\lblLightingDevNo())
      SGT(WEP\txtLightingPhysDevInfo(d), "")
      setOwnState(WEP\chkLightingActive(d), #False)
    Next d
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_LIGHTING) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  EndIf
  ;}
  ; ctrl send
  ;{
  If grLicInfo\nMaxCtrlSendDevPerProd >= 0 ; test added 24Jan2024 11.10.1
    For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
      If nDevMapPtr < 0
        SGT(WEP\txtCtrlPhysDevInfo(d), "")
        setOwnState(WEP\chkCtrlActive(d), #False)
      Else
        sMyLogicalDev = grProdForDevChgs\aCtrlSendLogicalDevs(d)\sLogicalDev
        If Len(sMyLogicalDev) = 0
          SGT(WEP\txtCtrlPhysDevInfo(d), "")
          setOwnState(WEP\chkCtrlActive(d), #False)
        Else
          WEP_displayCtrlPhysInfo(d)
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + d + ")\sLogicalDev=" + grProdForDevChgs\aCtrlSendLogicalDevs(d)\sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState)
          If nDevMapDevPtr >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkCtrlActive(d), #True)
            Else
              setOwnState(WEP\chkCtrlActive(d), #False)
            EndIf
          Else
            setOwnState(WEP\chkCtrlActive(d), #False)
          EndIf
          ; debugMsg(sProcName, "getOwnState(WEP\chkCtrlActive[" + d + "])=" + getOwnState(WEP\chkCtrlActive(d)))
        EndIf
      EndIf
    Next d
    ;   debugMsg0(sProcName, "grProdForDevChgs\nMaxCtrlSendLogicalDev=" + grProdForDevChgs\nMaxCtrlSendLogicalDev +
    ;                        ", ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())=" + ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs()) +
    ;                        ", ArraySize(WEP\lblCtrlDevNo())=" + ArraySize(WEP\lblCtrlDevNo()))
    For d = grProdForDevChgs\nMaxCtrlSendLogicalDev + 1 To ArraySize(WEP\lblCtrlDevNo())
      If d <= ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())
        grProdForDevChgs\aCtrlSendLogicalDevs(d) = grCtrlSendLogicalDevsDef
      EndIf
      WEP_setCtrlDevTypeText(d) ; draws WEP\cvsCtrlDevType(d) and stores text in WEP\cvsCtrlDevTypeText(d)
      SGT(WEP\txtCtrlPhysDevInfo(d), "")
      SGT(WEP\txtCtrlLogicalDev(d), "")
      setOwnState(WEP\chkCtrlActive(d), #False)
    Next d
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_CTRL_SEND) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  EndIf
  ;}
  ; cue ctrl
  ;{
  If grLicInfo\nMaxCueCtrlDev >= 0 ; test added 24Jan2024 11.10.1
    For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      If nDevMapPtr < 0
        SGS(WEP\cboCueDevType(d), -1)
        SGT(WEP\txtCuePhysDevInfo(d), "")
        setOwnState(WEP\chkCueActive(d), #False)
      Else
        sMyLogicalDev = buildCueCtrlLogicalDev(d)
        If Len(sMyLogicalDev) = 0
          SGT(WEP\txtCuePhysDevInfo(d), "")
          setOwnState(WEP\chkCueActive(d), #False)
        Else
          WEP_displayCuePhysInfo(d)
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "Cue Ctrl sMyLogicalDev=" + sMyLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkCueActive(d), #True)
            Else
              setOwnState(WEP\chkCueActive(d), #False)
            EndIf
          Else
            setOwnState(WEP\chkCueActive(d), #False)
          EndIf
        EndIf
      EndIf
      ; debugMsg0(sProcName, "CueCtrl d=" + d + ", WEP\txtCuePhysDevInfo(" + d + ")=" + GGT(WEP\txtCuePhysDevInfo(d)))
    Next d
    For d = grProdForDevChgs\nMaxCueCtrlLogicalDev + 1 To ArraySize(WEP\lblCueDevNo())
      SGS(WEP\cboCueDevType(d), -1)
      SGT(WEP\txtCuePhysDevInfo(d), "")
      setOwnState(WEP\chkCueActive(d), #False)
    Next d
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_CUE_CTRL) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
  EndIf
  ;}
  ; live input
  ;{
  If grLicInfo\nMaxLiveDevPerProd >= 0 ; Test added 24Jan2024 11.10.1 to prevent the following being executed if live inputs not available with the license level, which means that the gadgets were not created.
    For d = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
      If nDevMapPtr < 0
        SGS(WEP\cboLivePhysicalDev(d), -1)
        scsToolTip(WEP\cboLivePhysicalDev(d), "")
        SGS(WEP\cboInputRange(d), -1)
        ; If gbDelayTimeAvailable
        ; SGT(WEP\txtInputDelayTime[d], "")
        ; EndIf
        SLD_setLevel(WEP\sldInputGain(d), #SCS_MINVOLUME_SINGLE)
        SGT(WEP\txtInputGainDB(d), "")
        setOwnState(WEP\chkLiveActive(d), #False)
      Else
        sMyLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(d)\sLogicalDev
        If Len(sMyLogicalDev) = 0
          SGS(WEP\cboLivePhysicalDev(d), -1)
          setCboToolTipAtSelectedText(WEP\cboLivePhysicalDev(d))
          ClearGadgetItems(WEP\cboInputRange(d))
          ; If gbDelayTimeAvailable
          ; SGT(WEP\txtInputDelayTime[d], "")
          ; EndIf
          SLD_setLevel(WEP\sldInputGain(d), #SCS_MINVOLUME_SINGLE)
          SGT(WEP\txtInputGainDB(d), "")
          setOwnState(WEP\chkLiveActive(d), #False)
        Else
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sMyLogicalDev, nDevMapPtr)
          ; debugMsg(sProcName, "grProdForDevChgs\aLiveInputLogicalDevs(" + d + ")\sLogicalDev=" + grProdForDevChgs\aLiveInputLogicalDevs(d)\sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            With grMapsForDevChgs\aDev(nDevMapDevPtr)
              nListIndex = indexForComboBoxRow(WEP\cboLivePhysicalDev(d), \sPhysicalDev, -1)
              If nListIndex >= 0 And nListIndex = GGS(WEP\cboLivePhysicalDev(d))
                ; no change in physical dev so no need to refresh input range (for performance reasons)
              Else
                SGS(WEP\cboLivePhysicalDev(d), nListIndex)
                setCboToolTipAtSelectedText(WEP\cboLivePhysicalDev(d))
                ; debugMsg(sProcName, "calling WEP_populateInputRange(" + d + ")")
                WEP_populateInputRange(d)
              EndIf
              nListIndex = indexForComboBoxRow(WEP\cboInputRange(d), \s1BasedInputRange, -1)
              SGS(WEP\cboInputRange(d), nListIndex)
              ; If gbDelayTimeAvailable
              ; SGT(WEP\txtInputDelayTime[d], IntToStrBWZ(\nDelayTime))
              ; EndIf
              SLD_setLevel(WEP\sldInputGain(d), convertDBStringToBVLevel(\sInputGainDB))
              SGT(WEP\txtInputGainDB(d), \sInputGainDB)
              ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(\nDevState) + ", \sLogicalDev=" + \sLogicalDev)
              If \nDevState = #SCS_DEVSTATE_ACTIVE
                setOwnState(WEP\chkLiveActive(d), #True)
              Else
                setOwnState(WEP\chkLiveActive(d), #False)
              EndIf
            EndWith
          Else
            setOwnState(WEP\chkLiveActive(d), #False)
          EndIf
        EndIf
      EndIf
    Next d
    For d = grProdForDevChgs\nMaxLiveInputLogicalDev + 1 To ArraySize(WEP\lblLiveDevNo())
      SGS(WEP\cboLivePhysicalDev(d), -1)
      scsToolTip(WEP\cboLivePhysicalDev(d), "")
      SGS(WEP\cboInputRange(d), -1)
      ; If gbDelayTimeAvailable
      ; SGT(WEP\txtInputDelayTime[d], "")
      ; EndIf
      SLD_setLevel(WEP\sldInputGain(d), #SCS_MINVOLUME_SINGLE)
      SGT(WEP\txtInputGainDB(d), "")
      setOwnState(WEP\chkLiveActive(d), #False)
    Next d
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_LIVE_INPUT) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight() - see call near the top of this procedure
    ;}
    ; input group
    ED_setDevGrpScaInnerHeight(#SCS_DEVGRP_IN_GRP)
  EndIf
  
  grWEP\bInDisplayDevMap = #False
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_setTestToneButtonsEnabledState()
  setEnabled(WEP\btnTestToneShort, grWEP\bEnableTestTone)
  setVisible(WEP\btnTestToneCancel, #False)
  setVisible(WEP\btnTestToneContinuous, #True)
  setEnabled(WEP\btnTestToneContinuous, grWEP\bEnableTestTone)
  SLD_setEnabled(WEP\sldTestToneLevel, grWEP\bEnableTestTone)
EndProcedure

Procedure WEP_setTestLiveInputButtonsEnabledState()
  With WEP
    If CountGadgetItems(WEP\cboOutputDevForTestLiveInput) = 0 Or grTestLiveInput\bRunningTestLiveInput
      setEnabled(\cboOutputDevForTestLiveInput, #False)
    Else
      setEnabled(\cboOutputDevForTestLiveInput, grWEP\bEnableTestLiveInput)
    EndIf
    setEnabled(\btnTestLiveInputStart, grWEP\bEnableTestLiveInput)
  EndWith
EndProcedure

Procedure WEP_setVidCaptureTestButtonEnabledState()
  PROCNAMEC()
  Protected nDevNo, bEnableTestVidCap
  
  nDevNo = grWEP\nCurrentVidCapDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
      If (Trim(\sLogicalDev)) And (\nPhysicalDevPtr >= 0)
        If gaVideoCaptureDev(\nPhysicalDevPtr)\nVidCapDevId >= 0
          bEnableTestVidCap = #True
        EndIf
      EndIf
    EndWith
  EndIf
  setEnabled(WEP\btnTestVidCapStart, bEnableTestVidCap)
  setVisible(WEP\btnTestVidCapStart, #True)
  setVisible(WEP\btnTestVidCapStop, #False)
EndProcedure

Procedure WEP_setCurrentAudDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected n, nVSTNo
  Protected nListIndex
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  Static bStaticLoaded
  Static sAudDfltSettingsFrameTitle.s
  Static sVSTPluginsFrameTitle.s
  Static sTestToneFrameTitle.s
  Static sShortTT.s
  Static sContTT.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grTestTone\bPlayingTestTone
    debugMsg(sProcName, "calling stopTestTone()")
    stopTestTone()
    SGT(WEP\lblTestToneConfirm, "")
    setEnabled(WEP\cboTestSound, #True)
  EndIf
  
  If (grWEP\bInDisplayDevProd) Or (grWEP\nCurrentDevGrp <> #SCS_DEVGRP_AUDIO_OUTPUT)
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  ; load language constants into static variables
  If bStaticLoaded = #False
    sAudDfltSettingsFrameTitle = Lang("WEP","frDfltSettings")
    sVSTPluginsFrameTitle = Lang("WEP", "frVSTPlugins")
    sTestToneFrameTitle = Lang("WEP","frTestTone")
    sShortTT = Lang("WEP","btnTestToneShortTT")
    sContTT = Lang("WEP","btnTestToneContTT")
    bStaticLoaded = #True
  EndIf
  
  nDisplayedDevType = grWEP\nCurrentAudDevType
  nDisplayedDevNo = grWEP\nCurrentAudDevNo
  
  nReqdDevNo = Index
  If nReqdDevNo >= 0
    nReqdDevType = grProdForDevChgs\aAudioLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aAudioLogicalDevs(nReqdDevNo)\sLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblAudDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblAudDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentAudDevNo = nReqdDevNo
  grWEP\nCurrentAudDevType = nReqdDevType
  grWEP\nCurrentAudDevMapDevPtr = nDevMapDevPtr
  
  If sDevName
    grWEP\sCurrentAudDevName = sDevName
  Else
    grWEP\sCurrentAudDevName = GGT(WEP\lblAudDevNo(nReqdDevNo))
  EndIf
  
  ; panel titles
  SetGadgetItemText(WEP\pnlAudDevDetail, 0, LTrim(grWEP\sCurrentAudDevName + ": " + sAudDfltSettingsFrameTitle))
  SetGadgetItemText(WEP\pnlAudDevDetail, grWEP\nTestToneTabNo, LTrim(grWEP\sCurrentAudDevName + ": " + sTestToneFrameTitle))
  
  ; debugMsg(sProcName, "Index=" + Index)
  If Index < 0
    
    ; default settings tab
    setOwnState(WEP\chkAutoInclude, #False)
    ED_fcAutoInclude()
    If grLicInfo\bLTCAvailable
      setOwnState(WEP\chkForLTC, #False)
    EndIf
    SGS(WEP\cboDfltDevTrim, -1)
    
    SLD_setMax(WEP\sldDfltDevLevel, #SCS_MAXVOLUME_SLD)
    SLD_setLevel(WEP\sldDfltDevLevel, grAudioLogicalDevsDef\fDfltBVLevel, grAudioLogicalDevsDef\fDfltTrimFactor)
    SGT(WEP\txtDfltDevDBLevel, grAudioLogicalDevsDef\sDfltDBLevel)
    
    SLD_setMax(WEP\sldDfltDevPan, #SCS_MAXPAN_SLD)   ; forces control to be formatted
    SLD_setValue(WEP\sldDfltDevPan, panToSliderValue(grAudioLogicalDevsDef\fDfltPan))
    SGT(WEP\txtDfltDevPan, panSingleToString(grAudioLogicalDevsDef\fDfltPan))
    ED_fcSldDfltDevPan()
    
    ; test tone tab
    grWEP\bEnableTestTone = #False
    WEP_enableTestTonePanControls()
    WEP_setTestToneButtonsEnabledState()
    
  Else
    
    With grProdForDevChgs\aAudioLogicalDevs(Index)
      
      ; default settings tab
      setOwnState(WEP\chkAutoInclude, \bAutoInclude)
      ED_fcAutoInclude()
      If grLicInfo\bLTCAvailable
        setOwnState(WEP\chkForLTC, \bForLTC)
      EndIf
      nListIndex = indexForComboBoxRow(WEP\cboDfltDevTrim, \sDfltDBTrim, 0)
      If GGS(WEP\cboDfltDevTrim) <> nListIndex
        SGS(WEP\cboDfltDevTrim, nListIndex)
      EndIf
      
      SLD_setMax(WEP\sldDfltDevLevel, #SCS_MAXVOLUME_SLD)
      SLD_setLevel(WEP\sldDfltDevLevel, \fDfltBVLevel, \fDfltTrimFactor)
      SGT(WEP\txtDfltDevDBLevel, \sDfltDBLevel)
      
      SLD_setMax(WEP\sldDfltDevPan, #SCS_MAXPAN_SLD)   ; forces control to be formatted
      SLD_setValue(WEP\sldDfltDevPan, panToSliderValue(\fDfltPan))
      SGT(WEP\txtDfltDevPan, panSingleToString(\fDfltPan))
      ED_fcSldDfltDevPan()
      
      ; test tone tab
      If (Trim(\sLogicalDev)) And (\bNoDevice = #False)
        grWEP\bEnableTestTone = #True
      Else
        grWEP\bEnableTestTone = #False
      EndIf
      If grWEP\bEnableTestTone
        scsToolTip(WEP\btnTestToneShort, ReplaceString(sShortTT, "$1", grWEP\sCurrentAudDevName))
        scsToolTip(WEP\btnTestToneContinuous, ReplaceString(sContTT, "$1", grWEP\sCurrentAudDevName))
      EndIf
      WEP_enableTestTonePanControls()
      WEP_setTestToneButtonsEnabledState()
      
    EndWith
    
  EndIf
  
  ensureScrollAreaItemVisible(WEP\scaAudioDevs, -1, Index)
  ; debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
  WEP_setTBSButtons(Index)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentVidAudDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected n
  Protected nListIndex
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  Static bStaticLoaded
  Static sVidAudDfltSettingsFrameTitle.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWEP\bInDisplayDevProd Or grWEP\nCurrentDevGrp <> #SCS_DEVGRP_VIDEO_AUDIO
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  ; load language constants into static variables
  If bStaticLoaded = #False
    sVidAudDfltSettingsFrameTitle = Lang("WEP","frDfltSettings")
    bStaticLoaded = #True
  EndIf
  
  nDisplayedDevType = grWEP\nCurrentVidAudDevType
  nDisplayedDevNo = grWEP\nCurrentVidAudDevNo
  
  nReqdDevNo = Index
  If nReqdDevNo >= 0
    nReqdDevType = grProdForDevChgs\aVidAudLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aVidAudLogicalDevs(nReqdDevNo)\sVidAudLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_AUDIO, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblVidAudDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblVidAudDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentVidAudDevNo = nReqdDevNo
  grWEP\nCurrentVidAudDevType = nReqdDevType
  grWEP\nCurrentVidAudDevMapDevPtr = nDevMapDevPtr
  ; debugMsg(sProcName, "grWEP\nCurrentVidAudDevNo=" + grWEP\nCurrentVidAudDevNo + ", grWEP\nCurrentVidAudDevMapDevPtr=" + grWEP\nCurrentVidAudDevMapDevPtr)
  
  If Len(sDevName) > 0
    grWEP\sCurrentVidAudDevName = sDevName
  Else
    grWEP\sCurrentVidAudDevName = GGT(WEP\lblVidAudDevNo(nReqdDevNo))
  EndIf
  
  ; panel titles
  SetGadgetItemText(WEP\pnlVidAudDevDetail, 0, LTrim(grWEP\sCurrentVidAudDevName + ": " + sVidAudDfltSettingsFrameTitle))
  
  If Index < 0
    
    ; default settings panel
    setOwnState(WEP\chkVidAudAutoInclude, #False)
    ED_fcVidAudAutoInclude()
    SGS(WEP\cboDfltVidAudTrim, -1)
    
    SLD_setMax(WEP\sldDfltVidAudLevel, #SCS_MAXVOLUME_SLD)
    SLD_setLevel(WEP\sldDfltVidAudLevel, grVidAudLogicalDevsDef\fDfltBVLevel, grVidAudLogicalDevsDef\fDfltTrimFactor)
    ; debugMsg0(sProcName, "SLD_setLevel(WEP\sldDfltVidAudLevel, " + traceLevel(grVidAudLogicalDevsDef\fDfltBVLevel) + ", " + grVidAudLogicalDevsDef\fDfltTrimFactor + ")")
    SGT(WEP\txtDfltVidAudDBLevel, grVidAudLogicalDevsDef\sDfltDBLevel)
    
    SLD_setMax(WEP\sldDfltVidAudPan, #SCS_MAXPAN_SLD)   ; forces control to be formatted
    SLD_setValue(WEP\sldDfltVidAudPan, panToSliderValue(grVidAudLogicalDevsDef\fDfltPan))
    SGT(WEP\txtDfltVidAudPan, panSingleToString(grVidAudLogicalDevsDef\fDfltPan))
    ED_fcSldDfltVidAudPan()
    
  Else
    
    With grProdForDevChgs\aVidAudLogicalDevs(Index)
      ; default settings panel
      setOwnState(WEP\chkVidAudAutoInclude, \bAutoInclude)
      ED_fcVidAudAutoInclude()
      nListIndex = indexForComboBoxRow(WEP\cboDfltVidAudTrim, \sDfltDBTrim, 0)
      If GGS(WEP\cboDfltVidAudTrim) <> nListIndex
        SGS(WEP\cboDfltVidAudTrim, nListIndex)
      EndIf
      
      SLD_setMax(WEP\sldDfltVidAudLevel, #SCS_MAXVOLUME_SLD)
      SLD_setLevel(WEP\sldDfltVidAudLevel, \fDfltBVLevel, \fDfltTrimFactor)
      ; debugMsg0(sProcName, "SLD_setLevel(WEP\sldDfltVidAudLevel, " + traceLevel(\fDfltBVLevel) + ", " + \fDfltTrimFactor + ")")
      SGT(WEP\txtDfltVidAudDBLevel, \sDfltDBLevel)
      
      SLD_setMax(WEP\sldDfltVidAudPan, #SCS_MAXPAN_SLD)   ; forces control to be formatted
      SLD_setValue(WEP\sldDfltVidAudPan, panToSliderValue(\fDfltPan))
      SGT(WEP\txtDfltVidAudPan, panSingleToString(\fDfltPan))
      ED_fcSldDfltVidAudPan()
    EndWith
    
  EndIf
  
  ensureScrollAreaItemVisible(WEP\scaVidAudDevs, -1, Index)
  ; debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
  WEP_setTBSButtons(Index)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentVidCapDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nCboState
  Protected nDevMapDevPtr, nConnectedDevPtr, n, sVidCapFormats.s, sVidCapFormat.s
  Static bStaticLoaded
  Static sVidCapDfltSettingsFrameTitle.s
  Static sCaptureTestFrameTitle.s
  Static sStart.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWEP\bInDisplayDevProd Or grWEP\nCurrentDevGrp <> #SCS_DEVGRP_VIDEO_CAPTURE
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  ; load language constants into static variables
  If bStaticLoaded = #False
    sVidCapDfltSettingsFrameTitle = Lang("Common","Settings")
    sCaptureTestFrameTitle = Lang("WEP","frCaptureTest")
    sStart = Lang("WEP","btnTestVidCapStart")
    bStaticLoaded = #True
  EndIf
  
  WEP_stopProdTestIfRunning()
  
  nDisplayedDevType = grWEP\nCurrentVidCapDevType
  nDisplayedDevNo = grWEP\nCurrentVidCapDevNo
  
  nReqdDevNo = Index
  
  If nReqdDevNo >= 0
    nReqdDevType = grProdForDevChgs\aVidCapLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aVidCapLogicalDevs(nReqdDevNo)\sLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_CAPTURE, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblVidCapDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblVidCapDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentVidCapDevNo = nReqdDevNo
  grWEP\nCurrentVidCapDevType = nReqdDevType
  grWEP\nCurrentVidCapDevMapDevPtr = nDevMapDevPtr
  debugMsg(sProcName, "grWEP\nCurrentVidCapDevNo=" + grWEP\nCurrentVidCapDevNo + ", grWEP\nCurrentVidCapDevMapDevPtr=" + grWEP\nCurrentVidCapDevMapDevPtr)
  
  If sDevName
    grWEP\sCurrentVidCapDevName = sDevName
  ElseIf nReqdDevNo >= 0
    grWEP\sCurrentVidCapDevName = GGT(WEP\lblVidCapDevNo(nReqdDevNo))
  Else
    grWEP\sCurrentVidCapDevName = ""
  EndIf
  
  ; panel titles
  SetGadgetItemText(WEP\pnlVidCapDevDetail, 0, LTrim(grWEP\sCurrentVidCapDevName + ": " + sVidCapDfltSettingsFrameTitle))
  SetGadgetItemText(WEP\pnlVidCapDevDetail, 1, LTrim(grWEP\sCurrentVidCapDevName + ": " + sCaptureTestFrameTitle))
  
  ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_CAPTURE, " + Index + ")")
  ClearGadgetItems(WEP\cboVidCapDevFormat)
  debugMsg(sProcName, "ClearGadgetItems(WEP\cboVidCapDevFormat)")
  If nDevMapDevPtr >= 0
    nConnectedDevPtr = -1
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + \sPhysicalDev)
      For n = 0 To gnMaxConnectedDev
        ; debugMsg(sProcName, "gaConnectedDev(" + n + ")\nDevType=" + decodeDevType(gaConnectedDev(n)\nDevType) + ", \sPhysicalDevDesc=" + gaConnectedDev(n)\sPhysicalDevDesc)
        If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
          If gaConnectedDev(n)\sPhysicalDevDesc = \sPhysicalDev
            nConnectedDevPtr = n
            Break
          EndIf
        EndIf
      Next n
      debugMsg(sProcName, "nConnectedDevPtr=" + nConnectedDevPtr)
      If nConnectedDevPtr >= 0
        sVidCapFormats = gaConnectedDev(nConnectedDevPtr)\sFormatsSorted
        debugMsg(sProcName, "sVidCapFormats=" + #DQUOTE$ + ReplaceString(sVidCapFormats, Chr(10), ", ") + #DQUOTE$)
        For n = 1 To CountString(sVidCapFormats, Chr(10)) + 1
          sVidCapFormat = Trim(StringField(sVidCapFormats, n, Chr(10)))
          debugMsg(sProcName, "sVidCapFormat=" + sVidCapFormat)
          AddGadgetItem(WEP\cboVidCapDevFormat, -1, sVidCapFormat)
          debugMsg(sProcName, "AddGadgetItem(WEP\cboVidCapDevFormat, -1, " + sVidCapFormat + ")")
        Next n
      EndIf
    EndWith
  EndIf
  
  If nReqdDevNo < 0
    ; settings panel
    setOwnState(WEP\chkVidCapAutoInclude, #False)
    ED_fcVidCapAutoInclude()
  Else
    If nDevMapDevPtr >= 0
      sVidCapFormat = grMapsForDevChgs\aDev(nDevMapDevPtr)\sVidCapFormat
      nCboState = setComboBoxForText(WEP\cboVidCapDevFormat, sVidCapFormat)
      If nCboState < 0
        ; sVidCapFormat blank (default) or not found in list
        SGS(WEP\cboVidCapDevFormat, 0)
      EndIf
      SGT(WEP\txtVidCapDevFrameRate, strDTrimmed(grMapsForDevChgs\aDev(nDevMapDevPtr)\dVidCapFrameRate, 2))
    Else
      SGS(WEP\cboVidCapDevFormat, 0)
      SGT(WEP\txtVidCapDevFrameRate, "")
    EndIf
    With grProdForDevChgs\aVidCapLogicalDevs(nReqdDevNo)
      setOwnState(WEP\chkVidCapAutoInclude, \bAutoInclude)
      ED_fcVidCapAutoInclude()
    EndWith
  EndIf
  
  WEP_setVidCaptureTestButtonEnabledState()
  
  ensureScrollAreaItemVisible(WEP\scaVidCapDevs, -1, nReqdDevNo)
  ; debugMsg(sProcName, "calling WEP_setTBSButtons(" + nReqdDevNo + ")")
  WEP_setTBSButtons(nReqdDevNo)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setRS232Buttons(nDevMapDevPtr, Index)
  PROCNAMEC()
  Protected bEnabled, bTestEnabled
  Protected nDevNo, nDevType
  Protected nRS232BaudRate, nRS232Parity, nRS232DataBits, fRS232StopBits.f, nRS232Handshaking, nRS232RTSEnable, nRS232DTREnable
  Protected bDummy
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      SGT(WEP\btnRS232Default[Index], LangPars("WEP", "btnRS232Default", \sPhysicalDev))
      bDummy = \bDummy
    EndWith
  EndIf
  
  nDevNo = -1
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      nDevNo = grWEP\nCurrentCtrlDevNo
      If nDevNo >= 0
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          nDevType = \nDevType
          nRS232BaudRate = \nRS232BaudRate
          nRS232Parity = \nRS232Parity
          nRS232DataBits = \nRS232DataBits
          fRS232StopBits = \fRS232StopBits
          nRS232Handshaking = \nRS232Handshaking
          nRS232RTSEnable = \nRS232RTSEnable
          nRS232DTREnable = \nRS232DTREnable
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      nDevNo = grWEP\nCurrentCueDevNo
      If nDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          nDevType = \nDevType
          nRS232BaudRate = \nRS232BaudRate
          nRS232Parity = \nRS232Parity
          nRS232DataBits = \nRS232DataBits
          fRS232StopBits = \fRS232StopBits
          nRS232Handshaking = \nRS232Handshaking
          nRS232RTSEnable = \nRS232RTSEnable
          nRS232DTREnable = \nRS232DTREnable
        EndWith
      EndIf
      
  EndSelect
  
  If nDevNo >= 0
    If nRS232BaudRate <> grRS232ControlDefault\nRS232BaudRate
      bEnabled = #True
    EndIf
    If nRS232DataBits <> grRS232ControlDefault\nRS232DataBits
      bEnabled = #True
    EndIf
    If nRS232Parity <> grRS232ControlDefault\nRS232Parity
      bEnabled = #True
    EndIf
    If fRS232StopBits <> grRS232ControlDefault\fRS232StopBits
      bEnabled = #True
    EndIf
    If nRS232Handshaking <> grRS232ControlDefault\nRS232Handshaking
      bEnabled = #True
    EndIf
    If nRS232RTSEnable <> grRS232ControlDefault\nRS232RTSEnable
      bEnabled = #True
    EndIf
    If nRS232DTREnable <> grRS232ControlDefault\nRS232DTREnable
      bEnabled = #True
    EndIf
    If bDummy = #False And nDevType = #SCS_DEVTYPE_CC_RS232_IN
      bTestEnabled = #True
    EndIf
  EndIf
  
  debugMsg(sProcName, "bEnabled=" + strB(bEnabled) + ", bTestEnabled=" + strB(bTestEnabled))
  
  setEnabled(WEP\btnRS232Default[Index], bEnabled)
  
  If grWEP\nCurrentDevGrp = #SCS_DEVGRP_CUE_CTRL
    setEnabled(WEP\btnTestRS232, bTestEnabled)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_paintDMXTextColor(nFTIndex, nFTCIndex)
  PROCNAMEC()
  Protected nDMXTextColor, nDMXBackColor
  Static sSampleText.s, nSampleTextWidth, nSampleTextLeft, nSampleTextHeight, nSampleTextTop
  
  If nFTIndex >= 0 And nFTCIndex >= 0
;     debugMsg(sProcName, "nFTIndex=" + nFTIndex + ", nFTCIndex=" + nFTCIndex)
;     debugMsg(sProcName, "ArraySize(grProdForDevChgs\aFixTypes())=" + ArraySize(grProdForDevChgs\aFixTypes()))
;     debugMsg(sProcName, "ArraySize(grProdForDevChgs\aFixTypes(" + nFTIndex + ")\aFixTypeChan())=" + ArraySize(grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan()))
    nDMXTextColor = grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan(nFTCIndex)\nDMXTextColor
    If nDMXTextColor = grFixTypeChanDef\nDMXTextColor ; nb grFixTypeChanDef\nDMXTextColor = -1
      nDMXTextColor = #SCS_Black
    EndIf
    nDMXBackColor = WDD_getReqdCanvasBackColor()
    
    ; Draw color button
    If StartDrawing(CanvasOutput(WEP\cvsFTCTextColor[nFTCIndex]))
      Box(0, 0, OutputWidth(), OutputHeight(), nDMXTextColor)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Very_Light_Grey)
      StopDrawing()
    EndIf
    
    ; Draw text sample
    If StartDrawing(CanvasOutput(WEP\cvsFTCGridSample[nFTCIndex]))
      Box(0, 0, OutputWidth(), OutputHeight(), nDMXBackColor)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      If nSampleTextWidth = 0
        sSampleText = "100"
        nSampleTextWidth = TextWidth(sSampleText)
        If nSampleTextWidth < OutputWidth()
          nSampleTextLeft = (OutputWidth() - nSampleTextWidth) >> 1
        EndIf
        nSampleTextHeight = TextHeight(sSampleText)
        If nSampleTextHeight < OutputHeight()
          nSampleTextTop = (OutputHeight() - nSampleTextHeight) >> 1
        EndIf
      EndIf
      If grMemoryPrefs\bDMXShowGridLines
        DrawingMode(#PB_2DDrawing_Outlined)
        Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Light_Grey) ; Colour MUST be the same as that used in DMX_displayDMXAllFixturesData()
      EndIf
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(nSampleTextLeft, nSampleTextTop, sSampleText, nDMXTextColor)
      StopDrawing()
    EndIf
    
  EndIf ; EndIf nFTIndex >= 0 And nFTCIndex >= 0
  
EndProcedure

Procedure WEP_repaintDMXTextColors()
  ; PROCNAMEC()
  Protected nFTIndex, nFTCIndex
  
  If IsGadget(WEP\cvsFTCGridSample[0])
    nFTIndex = grWEP\nCurrentFixTypeNo   
    If nFTIndex >= 0
      With grProdForDevChgs\aFixTypes(nFTIndex)
        For nFTCIndex = 0 To (\nTotalChans-1)
          WEP_paintDMXTextColor(nFTIndex, nFTCIndex)
        Next nFTCIndex
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure WEP_btnRS232Default_Click(Index)
  PROCNAMEC()
  Protected nStopBitsCode
  Protected nDevGrp, nDevNo, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If Index = 0
    nDevGrp = #SCS_DEVGRP_CTRL_SEND
    nDevNo = grWEP\nCurrentCtrlDevNo
    nDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
  Else
    nDevGrp = #SCS_DEVGRP_CUE_CTRL
    nDevNo = grWEP\nCurrentCueDevNo
    nDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
  EndIf
  
  If nDevNo >= 0
    setDevChgsDevDefaults(nDevMapDevPtr)
    Select nDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          \nRS232BaudRate = grRS232ControlDefault\nRS232BaudRate
          \nRS232DataBits = grRS232ControlDefault\nRS232DataBits
          \nRS232Parity = grRS232ControlDefault\nRS232Parity
          \fRS232StopBits = grRS232ControlDefault\fRS232StopBits
          \nRS232Handshaking = grRS232ControlDefault\nRS232Handshaking
          \nRS232RTSEnable = grRS232ControlDefault\nRS232RTSEnable
          \nRS232DTREnable = grRS232ControlDefault\nRS232DTREnable
          setComboBoxByData(WEP\cboRS232BaudRate[Index], \nRS232BaudRate)
          setComboBoxByData(WEP\cboRS232Parity[Index], \nRS232Parity)
          setComboBoxByData(WEP\cboRS232DataBits[Index], \nRS232DataBits)
          nStopBitsCode = \fRS232StopBits * 10   ; convert 1.5 to integer value 15
          setComboBoxByData(WEP\cboRS232StopBits[Index], nStopBitsCode)
          setComboBoxByData(WEP\cboRS232Handshaking[Index], \nRS232Handshaking)
          setComboBoxByData(WEP\cboRS232RTSEnable[Index], \nRS232RTSEnable)
          setComboBoxByData(WEP\cboRS232DTREnable[Index], \nRS232DTREnable)
        EndWith
        
      Case #SCS_DEVGRP_CUE_CTRL
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          \nRS232BaudRate = grRS232ControlDefault\nRS232BaudRate
          \nRS232DataBits = grRS232ControlDefault\nRS232DataBits
          \nRS232Parity = grRS232ControlDefault\nRS232Parity
          \fRS232StopBits = grRS232ControlDefault\fRS232StopBits
          \nRS232Handshaking = grRS232ControlDefault\nRS232Handshaking
          \nRS232RTSEnable = grRS232ControlDefault\nRS232RTSEnable
          \nRS232DTREnable = grRS232ControlDefault\nRS232DTREnable
          setComboBoxByData(WEP\cboRS232BaudRate[Index], \nRS232BaudRate)
          setComboBoxByData(WEP\cboRS232Parity[Index], \nRS232Parity)
          setComboBoxByData(WEP\cboRS232DataBits[Index], \nRS232DataBits)
          nStopBitsCode = \fRS232StopBits * 10   ; convert 1.5 to integer value 15
          setComboBoxByData(WEP\cboRS232StopBits[Index], nStopBitsCode)
          setComboBoxByData(WEP\cboRS232Handshaking[Index], \nRS232Handshaking)
          setComboBoxByData(WEP\cboRS232RTSEnable[Index], \nRS232RTSEnable)
          setComboBoxByData(WEP\cboRS232DTREnable[Index], \nRS232DTREnable)
        EndWith
        
    EndSelect
    grCED\bProdChanged = #True
    
  EndIf
  
  WEP_setRS232Buttons(nDevMapDevPtr, Index)
  
  If Index = 0
    WEP_displayCtrlPhysInfo(grWEP\nCurrentCtrlDevNo)
  Else
    WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
  EndIf
  
  WEP_setDevChgsBtns()
  WEP_setRetryActivateBtn()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayMidiDetails()
  PROCNAMEC()
  Protected nListIndex
  Protected nDevMapDevPtr
  Protected nRemDevId, bMidiChannelVisible
  
  ; debugMsg(sProcName, #SCS_START + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      If grWEP\nCurrentCtrlDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
          nListIndex = indexForComboBoxRow(WEP\cboMidiOutPort, \sPhysicalDev, -1)
          SGS(WEP\cboMidiOutPort, nListIndex)
        EndWith
      EndIf
      If grWEP\nCurrentCtrlDevNo >= 0
        With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)
          If grLicInfo\bCSRDAvailable
            nRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_MIDI_OUT, \sCtrlMidiRemoteDevCode)
            ; debugMsg(sProcName, "CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_MIDI_OUT, " + \sCtrlMidiRemoteDevCode + ") returned nRemDevId=" + nRemDevId)
            setComboBoxByData(WEP\cboCtrlMidiRemoteDev, nRemDevId)
            If nRemDevId >= 0
              If CSRD_GetDfltMidiChanForRemDevId(nRemDevId) > 0
                bMidiChannelVisible = #True
                setComboBoxByData(WEP\cboCtrlMidiChannel, \nCtrlMidiChannel)
              EndIf
            EndIf
            setVisible(WEP\lblCtrlMidiChannel, bMidiChannelVisible)
            setVisible(WEP\cboCtrlMidiChannel, bMidiChannelVisible)
          EndIf
          setOwnState(WEP\chkForMTC, \bCtrlMidiForMTC)
          If IsGadget(WEP\chkM2TSkipEarlierCSMsgs_MidiOut)
            setOwnState(WEP\chkM2TSkipEarlierCSMsgs_MidiOut, \bM2TSkipEarlierCtrlMsgs)
          EndIf
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If grWEP\nCurrentCueDevMapDevPtr >= 0
        With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
          nListIndex = indexForComboBoxRow(WEP\cboMidiInPort, \sPhysicalDev, -1)
          SGS(WEP\cboMidiInPort, nListIndex)
        EndWith
      EndIf
      If grWEP\nCurrentCueDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
          nListIndex = indexForComboBoxData(WEP\cboCtrlMethod, \nCtrlMethod)
          SGS(WEP\cboCtrlMethod, nListIndex)
          ED_fcCtrlMethod(#True)
          If \nMidiChannel >= 0
            SGS(WEP\cboMidiChannel, \nMidiChannel)
          Else
            SGS(WEP\cboMidiChannel, -1)
          EndIf
        EndWith
      EndIf
      
  EndSelect
  
EndProcedure

Procedure WEP_displayMidiThruDetails()
  PROCNAMEC()
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEP\nCurrentCtrlDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + grWEP\nCurrentCtrlDevMapDevPtr + ")\sMidiThruInPhysicalDev=" + \sMidiThruInPhysicalDev)
      nListIndex = indexForComboBoxRow(WEP\cboMidiThruInPort, \sMidiThruInPhysicalDev, -1)
      SGS(WEP\cboMidiThruInPort, nListIndex)
      nListIndex = indexForComboBoxRow(WEP\cboMidiThruOutPort, \sPhysicalDev, -1)
      SGS(WEP\cboMidiThruOutPort, nListIndex)
    EndWith
  EndIf
  
  ; commented out the following because an output port for MTC must be opened in the MTC Thread, which is inconsistent with the input port
;   debugMsg(sProcName, "grWEP\nCurrentCtrlDevNo=" + grWEP\nCurrentCtrlDevNo)
;   If grWEP\nCurrentCtrlDevNo >= 0
;     With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)
;       setOwnState(WEP\chkMidiThruForMTC, \bCtrlMidiForMTC)
;     EndWith
;   EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayRS232Details()
  PROCNAMEC()
  Protected nListIndex
  Protected nDevMapDevPtr
  Protected nIndex
  Protected nStopBitsCode
  Protected nDevNo
  Protected sPhysicalDev.s
  Protected nRS232BaudRate, nRS232Parity, nRS232DataBits, fRS232StopBits.f, nRS232Handshaking, nRS232RTSEnable, nRS232DTREnable
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = -1
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND  ; #SCS_DEVGRP_CTRL_SEND
      nIndex = 0
      nDevNo = grWEP\nCurrentCtrlDevNo
      nDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
      If nDevNo >= 0
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          nRS232BaudRate = \nRS232BaudRate
          nRS232Parity = \nRS232Parity
          nRS232DataBits = \nRS232DataBits
          fRS232StopBits = \fRS232StopBits
          nRS232Handshaking = \nRS232Handshaking
          nRS232RTSEnable = \nRS232RTSEnable
          nRS232DTREnable = \nRS232DTREnable
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL ; #SCS_DEVGRP_CUE_CTRL
      nIndex = 1
      nDevNo = grWEP\nCurrentCueDevNo
      nDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
      If nDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          nRS232BaudRate = \nRS232BaudRate
          nRS232Parity = \nRS232Parity
          nRS232DataBits = \nRS232DataBits
          fRS232StopBits = \fRS232StopBits
          nRS232Handshaking = \nRS232Handshaking
          nRS232RTSEnable = \nRS232RTSEnable
          nRS232DTREnable = \nRS232DTREnable
        EndWith
      EndIf
      
  EndSelect
  
  If (nDevMapDevPtr >= 0) And (nDevNo >= 0)
    With WEP
      sPhysicalDev = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
      nListIndex = indexForComboBoxRow(\cboRS232Port[nIndex], sPhysicalDev)
      SGS(\cboRS232Port[nIndex], nListIndex)
      setComboBoxByData(\cboRS232BaudRate[nIndex], nRS232BaudRate)
      setComboBoxByData(\cboRS232Parity[nIndex], nRS232Parity)
      setComboBoxByData(\cboRS232DataBits[nIndex], nRS232DataBits)
      nStopBitsCode = fRS232StopBits * 10   ; convert 1.5 to integer value 15
      setComboBoxByData(\cboRS232StopBits[nIndex], nStopBitsCode)
      setComboBoxByData(\cboRS232Handshaking[nIndex], nRS232Handshaking)
      setComboBoxByData(\cboRS232RTSEnable[nIndex], nRS232RTSEnable)
      setComboBoxByData(\cboRS232DTREnable[nIndex], nRS232DTREnable)
      If grWEP\nCurrentDevGrp = #SCS_DEVGRP_CUE_CTRL
        ClearGadgetItems(\edgRS232Assigns)
        AddGadgetItem(\edgRS232Assigns, -1, "'Go' button:     scsGo(" + #DQUOTE$ + "0" + #DQUOTE$ + ") NB 0 is zero")
        AddGadgetItem(\edgRS232Assigns, -1, "Activate Cue x:  scsGo(" + #DQUOTE$ + "X" + #DQUOTE$ + ")")
        AddGadgetItem(\edgRS232Assigns, -1, "Go To Top:       scsGoTop")
        AddGadgetItem(\edgRS232Assigns, -1, "Stop Cue x:      scsStop(" + #DQUOTE$ + "X" + #DQUOTE$ + ")")
        AddGadgetItem(\edgRS232Assigns, -1, "Stop Everything: scsStopAll")
        AddGadgetItem(\edgRS232Assigns, -1, " ")
        AddGadgetItem(\edgRS232Assigns, -1, "Every RS232 command must be terminated")
        AddGadgetItem(\edgRS232Assigns, -1, "by a carriage return (0DH)")
      EndIf
    EndWith
  EndIf
  
  WEP_setRS232Buttons(nDevMapDevPtr, nIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_syncRS232InOutPorts(nPriorityIndex)
  PROCNAMEC()
  Protected d1, d2
  Protected nDevId, nDevMapDevPtr
  Protected nOutputPhysDevPtr, nInputPhysDevPtr
  
  For d1 = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
    If grProdForDevChgs\aCtrlSendLogicalDevs(d1)\nDevType = #SCS_DEVTYPE_CS_RS232_OUT
      nDevId = grProdForDevChgs\aCtrlSendLogicalDevs(d1)\nDevId
      nDevMapDevPtr = getDevChgsDevPtrForDevId(#SCS_DEVGRP_CTRL_SEND, nDevId)
      If nDevMapDevPtr >= 0
        nOutputPhysDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
        If nOutputPhysDevPtr >= 0
          ; we now have the physical device ptr for this (d1) ctrl send RS232 device
          ; now look to see if there's a cue ctrl RS232 device with the same physical device ptr, ie that's using the same RS232 port
          For d2 = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
            If grProdForDevChgs\aCueCtrlLogicalDevs(d2)\nDevType = #SCS_DEVTYPE_CC_RS232_IN
              nDevId = grProdForDevChgs\aCueCtrlLogicalDevs(d2)\nDevId
              nDevMapDevPtr = getDevChgsDevPtrForDevId(#SCS_DEVGRP_CUE_CTRL, nDevId)
              If nDevMapDevPtr >= 0
                nInputPhysDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
                If nInputPhysDevPtr = nOutputPhysDevPtr
                  ; input/output match found
                EndIf
              EndIf
            EndIf
          Next d2
        EndIf
      EndIf
    EndIf
  Next d1
  
EndProcedure

Procedure WEP_setNetworkButtons()
  PROCNAMEC()
  Protected bTestEnabled
  
  If grWEP\nCurrentDevGrp = #SCS_DEVGRP_CUE_CTRL
    If grWEP\nCurrentCueDevMapDevPtr >= 0
      With grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)
        If (\bDummy = #False) And (\nDevType = #SCS_DEVTYPE_CC_NETWORK_IN)
          bTestEnabled = #True
        EndIf
      EndWith
    EndIf
    setEnabled(WEP\btnTestNetwork, bTestEnabled)
  EndIf
  
EndProcedure

Procedure WEP_displayNetworkAssigns(nDevNo)
  PROCNAMEC()
  Protected m, n
  Protected nX32Button, sOSCText.s
  Static Dim sOSCCmmands.s(17)
  Static Dim sASCIICommands.s(7)
  Static nMaxOSCCommandLen, nMaxASCIICommandLen
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo)
  
  If bStaticLoaded = #False
    ; Load and format OSC command desciptions
    sOSCCmmands(0) = decodeCtrlCommandL(#SCS_CCC_GO)
    sOSCCmmands(1) = decodeCtrlCommandL(#SCS_CCC_STOP_ALL)
    sOSCCmmands(2) = decodeCtrlCommandL(#SCS_CCC_FADE_ALL)
    sOSCCmmands(3) = decodeCtrlCommandL(#SCS_CCC_PAUSE_RESUME_ALL)
    sOSCCmmands(4) = decodeCtrlCommandL(#SCS_CCC_GO_TO_TOP)
    sOSCCmmands(5) = decodeCtrlCommandL(#SCS_CCC_GO_BACK)
    sOSCCmmands(6) = decodeCtrlCommandL(#SCS_CCC_GO_TO_NEXT)
    sOSCCmmands(7) = decodeCtrlCommandL(#SCS_CCC_GO_TO_END)
    sOSCCmmands(8) = decodeCtrlCommandL(#SCS_CCC_GO_TO_CUE_X, "x")
    sOSCCmmands(9) = decodeCtrlCommandL(#SCS_CCC_PLAY_CUE_X, "x")
    sOSCCmmands(10) = decodeCtrlCommandL(#SCS_CCC_STOP_CUE_X, "x")
    sOSCCmmands(11) = decodeCtrlCommandL(#SCS_CCC_PAUSE_RESUME_CUE_X, "x")
    sOSCCmmands(12) = decodeCtrlCommandL(#SCS_CCC_PLAY_HOTKEY_X, "x")
    sOSCCmmands(13) = decodeCtrlCommandL(#SCS_CCC_START_NOTE_HOTKEY_X, "x")
    sOSCCmmands(14) = decodeCtrlCommandL(#SCS_CCC_STOP_NOTE_HOTKEY_X, "x")
    sOSCCmmands(15) = decodeCtrlCommandL(#SCS_CCC_SET_MASTER_FADER_DB)
    sOSCCmmands(16) = decodeCtrlCommandL(#SCS_CCC_SET_DEVICE_FADER_DB)
    sOSCCmmands(17) = decodeCtrlCommandL(#SCS_CCC_GO_CONFIRM)
    For n = 0 To ArraySize(sOSCCmmands())
      sOSCCmmands(n) + ": "
      If Len(sOSCCmmands(n)) > nMaxOSCCommandLen
        nMaxOSCCommandLen = Len(sOSCCmmands(n))
      EndIf
    Next n
    If nMaxOSCCommandLen > 21
      nMaxOSCCommandLen = 21
    EndIf
    For n = 0 To ArraySize(sOSCCmmands())
      sOSCCmmands(n) = LSet(sOSCCmmands(n), nMaxOSCCommandLen)
    Next n
    ; Load and format ASCII command desciptions
    sASCIICommands(0) = decodeCtrlCommandL(#SCS_CCC_GO)
    sASCIICommands(1) = decodeCtrlCommandL(#SCS_CCC_PLAY_CUE_X, "x")
    sASCIICommands(2) = decodeCtrlCommandL(#SCS_CCC_GO_TO_TOP)
    sASCIICommands(3) = decodeCtrlCommandL(#SCS_CCC_GO_BACK)
    sASCIICommands(4) = decodeCtrlCommandL(#SCS_CCC_GO_TO_NEXT)
    sASCIICommands(5) = decodeCtrlCommandL(#SCS_CCC_STOP_CUE_X, "x")
    sASCIICommands(6) = decodeCtrlCommandL(#SCS_CCC_STOP_ALL)
    sASCIICommands(7) = decodeCtrlCommandL(#SCS_CCC_GO_CONFIRM)
    For n = 0 To ArraySize(sASCIICommands())
      sASCIICommands(n) + ": "
      If Len(sASCIICommands(n)) > nMaxASCIICommandLen
        nMaxASCIICommandLen = Len(sASCIICommands(n))
      EndIf
    Next n
    If nMaxASCIICommandLen > 21
      nMaxASCIICommandLen = 21
    EndIf
    For n = 0 To ArraySize(sASCIICommands())
      sASCIICommands(n) = LSet(sASCIICommands(n), nMaxASCIICommandLen)
    Next n
    ; all static items loaded
    bStaticLoaded = #True
  EndIf
  
  With WEP
    ClearGadgetItems(\edgNetworkAssigns)
    
    debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nDevNo + ")\nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nCueNetworkRemoteDev))
    Select grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nCueNetworkRemoteDev
      Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
        For m = 0 To #SCS_MAX_X32_COMMAND
          nX32Button = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\aX32Command[m]\nX32Button
          If nX32Button > 0
            ; sOSCText = "/-stat/userpar/" + RSet(Str(nX32Button),2,"0") + "/value ,i [127]"
            sOSCText = "/-stat/userpar/" + RSet(Str(nX32Button),2,"0") + "/value ,i 127"
            AddGadgetItem(WEP\edgNetworkAssigns, -1, X32CmdDescrForCmdNo(m) + ": " + sOSCText)
          EndIf
        Next m
        
      Default
        Select grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkMsgFormat
          Case #SCS_NETWORK_MSG_OSC
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(0) + "/ctrl/go")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(1) + "/ctrl/stopall")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(2) + "/ctrl/fadeall")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(3) + "/ctrl/pauseresumeall")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(4) + "/ctrl/gotop")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(5) + "/ctrl/goback")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(6) + "/ctrl/gotonext")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(7) + "/ctrl/gotoend")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(8) + "/ctrl/gotocue ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(9) + "/cue/go ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(10) + "/cue/stop ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(11) + "/cue/pauseresume ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(12) + "/hkey/go ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(13) + "/hkey/on ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(14) + "/hkey/off ,s x")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(15) + "/fader/setmaster ,f n.n")   ; corrected 26Oct2016 11.5.2.4 (was "/fader/master ,f n.n")
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(16) + "/fader/setdevice ,sf x n.n") ; Added 2Feb2021 11.8.4
            AddGadgetItem(\edgNetworkAssigns, -1, sOSCCmmands(17) + "/ctrl/goconfirm") ; Added 31Dec2024 11.10.6ca
            ; Commented out the following 2Feb2021 11.8.4 as there is insufficient height in \edgNetworkAssigns to display these lines, and they are not really necessary
            ; AddGadgetItem(\edgNetworkAssigns, -1, " ")
            ; AddGadgetItem(\edgNetworkAssigns, -1, "Messages may optionally be preceded by /scs")
            ; AddGadgetItem(\edgNetworkAssigns, -1, "eg /scs/ctrl/go")
            
          Default ; ASCII
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(0) + "scsGo(" + #DQUOTE$ + "0" + #DQUOTE$ + ") NB 0 is zero")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(1) + "scsGo(" + #DQUOTE$ + "x" + #DQUOTE$ + ")")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(2) + "scsGoTop")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(3) + "scsGoBack")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(4) + "scsGoToNext")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(5) + "scsStop(" + #DQUOTE$ + "x" + #DQUOTE$ + ")")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(6) + "scsStopAll")
            AddGadgetItem(\edgNetworkAssigns, -1, sASCIICommands(7) + "scsGoConfirm")
            AddGadgetItem(\edgNetworkAssigns, -1, " ")
            AddGadgetItem(\edgNetworkAssigns, -1, "Individual Network commands MAY be terminated by")
            AddGadgetItem(\edgNetworkAssigns, -1, "a carriage return (0DH) or 'pipe character' (|)")
            AddGadgetItem(\edgNetworkAssigns, -1, " ")
            AddGadgetItem(\edgNetworkAssigns, -1, "If multiple Network commands are received")
            AddGadgetItem(\edgNetworkAssigns, -1, "together, each command MUST be terminated by")
            AddGadgetItem(\edgNetworkAssigns, -1, "a carriage return (0DH) or 'pipe character' (|)")
            
        EndSelect
    EndSelect
  EndWith
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayNetworkDetails()
  PROCNAMEC()
  Protected nIndex
  Protected nDevNo
  Protected nNetworkRole
  Protected m
  Protected nSettingsHeight
  Protected bShowMsgFormatCombo
  Protected nTop
  
  debugMsg(sProcName, #SCS_START)
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND  ; #SCS_DEVGRP_CTRL_SEND
      nIndex = 0
      nDevNo = grWEP\nCurrentCtrlDevNo
      If nDevNo >= 0
        nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL ; #SCS_DEVGRP_CUE_CTRL
      nIndex = 1
      nDevNo = grWEP\nCurrentCueDevNo
      If nDevNo >= 0
        nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole
      EndIf
      
  EndSelect
  
  setComboBoxByData(WEP\cboNetworkRole[nIndex], nNetworkRole)
  ED_fcNetworkRole()
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      If nDevNo >= 0
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev) +
                              ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
          setComboBoxByData(WEP\cboCtrlNetworkRemoteDev, \nCtrlNetworkRemoteDev)
          setComboBoxByData(WEP\cboNetworkProtocol[0], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[0], \nNetworkRole)
          setOwnState(WEP\chkNetworkReplyMsgAddCR, \bReplyMsgAddCR)
          setOwnState(WEP\chkNetworkReplyMsgAddLF, \bReplyMsgAddLF)
          For m = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
            SGT(WEP\txtNetworkReceiveMsg[m], \aMsgResponse[m]\sReceiveMsg)
            setComboBoxByData(WEP\cboNetworkMsgAction[m], \aMsgResponse[m]\nMsgAction)
            SGT(WEP\txtNetworkReplyMsg[m], \aMsgResponse[m]\sReplyMsg)
          Next m
          ED_fcCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev)
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      If nDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nDevNo + ")\nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev) +
                              ", \nNetworkProtocol=" + decodeNetworkProtocol(\nNetworkProtocol) + ", \nNetworkRole=" + decodeNetworkRole(\nNetworkRole))
          setComboBoxByData(WEP\cboCueNetworkRemoteDev, \nCueNetworkRemoteDev)
          setComboBoxByData(WEP\cboNetworkProtocol[1], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[1], \nNetworkRole)
          ED_fcCueNetworkRemoteDev(\nCueNetworkRemoteDev)
          Select \nCueNetworkRemoteDev
            Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
              WEP_displayX32SpecialCueCmds()
              setVisible(WEP\cntX32Special, #True)
              nSettingsHeight = GadgetY(WEP\cntX32Special) - GadgetY(WEp\cntNetworkAssigns) - 5
            Default
              setVisible(WEP\cntX32Special, #False)
              nSettingsHeight = GadgetHeight(WEP\cntCueDevDetail) - GadgetY(WEP\cntNetworkAssigns) - 4
              bShowMsgFormatCombo = #True
          EndSelect
          ResizeGadget(WEP\cntNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSettingsHeight)
          ResizeGadget(WEP\frNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSettingsHeight)
          If bShowMsgFormatCombo
            ResizeGadget(WEP\edgNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, (nSettingsHeight-60))
            nTop = GadgetY(WEP\edgNetworkAssigns) + GadgetHeight(WEP\edgNetworkAssigns) + 4
            setComboBoxByData(WEP\cboNetworkMsgFormat, \nNetworkMsgFormat, 0)
            ResizeGadget(WEP\cboNetworkMsgFormat, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
            setVisible(WEP\cboNetworkMsgFormat, #True)
          Else
            ResizeGadget(WEP\edgNetworkAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, (nSettingsHeight-20))
            setVisible(WEP\cboNetworkMsgFormat, #False)
          EndIf
        EndWith
        debugMsg(sProcName, "calling WEP_displayNetworkAssigns(" + nDevNo + ")")
        WEP_displayNetworkAssigns(nDevNo)
      EndIf
      
  EndSelect
  
  WEP_setNetworkButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayCtrlNetworkDetails()
  PROCNAMEC()
  Protected m
  
  debugMsg(sProcName, #SCS_START)
  
  If (grWEP\nCurrentDevGrp <> #SCS_DEVGRP_CTRL_SEND) Or (grWEP\nCurrentCtrlDevNo < 0)
    ProcedureReturn
  EndIf
  
  With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)
    setComboBoxByData(WEP\cboCtrlNetworkRemoteDev, \nCtrlNetworkRemoteDev)
    ED_fcCtrlNetworkRemoteDev(\nCtrlNetworkRemoteDev)
    setComboBoxByData(WEP\cboNetworkProtocol[0], \nNetworkProtocol)
    setComboBoxByData(WEP\cboNetworkRole[0], \nNetworkRole)
    ED_fcNetworkRole()
    setOwnState(WEP\chkNetworkReplyMsgAddCR, \bReplyMsgAddCR)
    setOwnState(WEP\chkNetworkReplyMsgAddLF, \bReplyMsgAddLF)
    For m = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
      SGT(WEP\txtNetworkReceiveMsg[m], \aMsgResponse[m]\sReceiveMsg)
      setComboBoxByData(WEP\cboNetworkMsgAction[m], \aMsgResponse[m]\nMsgAction)
      SGT(WEP\txtNetworkReplyMsg[m], \aMsgResponse[m]\sReplyMsg)
    Next m
    setComboBoxByData(WEP\cboDelayBeforeReloadNames, \nDelayBeforeReloadNames, 0)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayHTTPDetails()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEP\nCurrentCtrlDevNo >= 0 
    With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)
      SGT(WEP\txtHTTPStart, \sHTTPStart)
    EndWith
  EndIf
  
EndProcedure

Procedure.s WEP_buildAssignForSpecial(Index, pCmd, pCC, pVV)
  PROCNAMEC()
  Protected sAssign.s, sCommand.s, sRange.s
  
  If Index <= #SCS_MIDI_LAST_SCS_CUE_RELATED
    If pCmd = $B
      ; controller change
      If pCC >= 0
        sRange = Str(pCC) + ", value 1-127"
      EndIf
    ElseIf pCmd = $200B
      sRange = "CtrlNo 1-127, value > 0"
    Else
      sRange = "1-127"
    EndIf
    
  ElseIf Index = #SCS_MIDI_EXT_FADER
    If pCmd = $B
      If pVV >= 0
        sRange + ", threshold value " + Str(pVV)
      EndIf
    EndIf
    
  Else
    If pCC >= 0
      sRange = Str(pCC)
      ; changed 26Aug2019 11.8.2ah following request / bug report from Masashi Doi regarding 'Key Pressure' not handling the pressure value
      ; If pCmd = $B
      If pCmd = $A Or pCmd = $B
        If pVV = #SCS_MIDI_ANY_VALUE
          sRange + ", value *"
        ElseIf pVV >= 0
          sRange + ", value " + Str(pVV)
        EndIf
      EndIf
    EndIf
    
  EndIf
  
  Select pCmd
    Case $8
      sCommand = "Note Off"
    Case $9
      sCommand = "Note On"
    Case $A
      sCommand = "Key Pressure"
    Case $B
      sCommand = "Ctrl Chg"
    Case $C
      sCommand = "Prg Chg"
    Case $D
      sCommand = "Channel Pressure"
    Case $E
      sCommand = "Pitch Bend"
      If sRange
        sRange + "(LSB)"
      EndIf
  EndSelect
  sAssign = sCommand
  If sRange
    If Left(sRange, 1) = ","
      sAssign + sRange
    Else
      sAssign + " " + sRange
    EndIf
  EndIf    
  
  If Index = #SCS_MIDI_OPEN_FAV_FILE
    If pCmd > 0
      sAssign + ", velocity 1-20"
    EndIf
  ElseIf Index = #SCS_MIDI_SET_HOTKEY_BANK
    If pCmd > 0
      sAssign + ", velocity 0-12"
    EndIf
  EndIf
  
  ; debugMsg0(sProcName, "Index=" + Index + ", pCmd=$" + Hex(pCmd) + ", pCC=" + Str(pCC) + ", pVV=" + Str(pVV) + ", sAssign=" + sAssign + ", sRange=" + sRange)
  ProcedureReturn Trim(sAssign)
  
EndProcedure

Procedure.s WEP_fixLeft(pFunction.s)
  ProcedureReturn Left(pFunction + Space(23), 23)
EndProcedure

Procedure WEP_populateCmdInfo(sWhichCmdInfo.s, nIndex, nAltCmd = 0)
  PROCNAMEC()
  Protected nCtrlMethod
  Protected nWorkCmd, nWorkCC, nWorkVV, nWorkCCVVFrom, nWorkCCVVUpto, bWorkCueRelated
  
  If grWEP\nCurrentCueDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
      nCtrlMethod = \nCtrlMethod
      If nAltCmd = 0
        nWorkCmd = \aMidiCommand[nIndex]\nCmd
      Else
        nWorkCmd = nAltCmd
      EndIf
      nWorkCC = \aMidiCommand[nIndex]\nCC
      nWorkVV = \aMidiCommand[nIndex]\nVV
      If nIndex <= #SCS_MIDI_LAST_SCS_CUE_RELATED
        bWorkCueRelated = #True
      EndIf
      
      If nWorkCmd > 0
        nWorkCCVVFrom = -1
        nWorkCCVVUpto = -1
        If bWorkCueRelated
          If nIndex = #SCS_MIDI_PLAY_CUE
            Select nCtrlMethod
              Case #SCS_CTRLMETHOD_ETC_AB
                If nWorkCmd = $C  ; program change
                  nWorkCC = 1
                  nWorkCCVVFrom = 1000
                  nWorkCCVVUpto = 127000
                ElseIf nWorkCmd = $B  ; control change
                  nWorkCC = 70
                  nWorkCCVVFrom = 70000
                  nWorkCCVVUpto = 76103
                EndIf
              Case #SCS_CTRLMETHOD_ETC_CD
                If nWorkCmd = $B  ; control change
                  nWorkCC = 77
                  nWorkCCVVFrom = 77001
                  nWorkCCVVUpto = 84103
                EndIf
              Default
                ; Added control change test 25Mar2023 11.10.2bk following bug report from Davide Bellucci reporting "DUPLICATED: Play Cue 1-127 and Stop Cue 1-127" which was due to nWorkCC not being left as set by the user.
                If nWorkCmd = $B ; control change
                  nWorkCCVVFrom = (nWorkCC * 1000)
                  nWorkCCVVUpto = (nWorkCC * 1000) + 127
                Else
                  nWorkCC = 1
                  nWorkCCVVFrom = 1000
                  nWorkCCVVUpto = 127000
                EndIf
            EndSelect
            
          Else    ; not #SCS_MIDI_PLAY_CUE
            If nWorkCmd = $B  ; control change
              nWorkCCVVFrom = (nWorkCC * 1000)
              nWorkCCVVUpto = (nWorkCC * 1000) + 127
            Else
              nWorkCCVVFrom = 1000
              nWorkCCVVUpto = 127000
            EndIf
          EndIf
          
        Else    ; not cue-related
          If (nWorkCmd = $B) And (nIndex <> #SCS_MIDI_MASTER_FADER) And (nIndex <> #SCS_MIDI_OPEN_FAV_FILE) And (nIndex <> #SCS_MIDI_SET_HOTKEY_BANK) And (nIndex <> #SCS_MIDI_DMX_MASTER) And
             (nIndex <> #SCS_MIDI_CUE_MARKER_PREV) And (nIndex <> #SCS_MIDI_CUE_MARKER_NEXT) And ; 3May2022 11.9.1
             (nIndex < #SCS_MIDI_DEVICE_1_FADER Or nIndex > #SCS_MIDI_DEVICE_LAST_FADER)
            ; control change (not master fader or open fav file)
            If nWorkVV = #SCS_MIDI_ANY_VALUE
              nWorkCCVVFrom = (nWorkCC * 1000)
              nWorkCCVVUpto = nWorkCCVVFrom + 127
            Else
              nWorkCCVVFrom = (nWorkCC * 1000) + nWorkVV
              nWorkCCVVUpto = nWorkCCVVFrom
            EndIf
          Else
            nWorkCCVVFrom = (nWorkCC * 1000)
            nWorkCCVVUpto = nWorkCCVVFrom
          EndIf
        EndIf
      EndIf
    EndWith
    
    If sWhichCmdInfo = "ORIG"
      With grWEP\rOrigInfo
        \nCmd = nWorkCmd
        \nCC = nWorkCC
        \nVV = nWorkVV
        \nCCVVFrom = nWorkCCVVFrom
        \nCCVVUpto = nWorkCCVVUpto
        \bCueRelated = bWorkCueRelated
      EndWith
    Else
      With grWEP\rThisInfo
        \nCmd = nWorkCmd
        \nCC = nWorkCC
        \nVV = nWorkVV
        \nCCVVFrom = nWorkCCVVFrom
        \nCCVVUpto = nWorkCCVVUpto
        \bCueRelated = bWorkCueRelated
      EndWith
    EndIf
  EndIf
EndProcedure

Procedure WEP_checkForMidiDuplicates(bErrorsOnly)
  PROCNAMEC()
  Protected nCtrlMethod
  Protected nOrigIndex, nThisIndex
  Protected nErrMax, nWrnMax
  Protected nCheckResult
  Protected Dim aError.tyMidiDupInfo(0)
  Protected Dim aWarning.tyMidiDupInfo(0)
  Protected n, nAltCmd, sMidiCue.s
  Protected sOriginal.s, sDuplicate.s
  Protected sMyErrorMsg.s
  Protected nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START + ", bErrorsOnly=" + strB(bErrorsOnly))
  
  If grWEP\nCurrentCueDevNo >= 0
    
;     debugMsg(sProcName, "calling loadMidiControl(#True)")
;     loadMidiControl(#True)
    
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
      
      If \aMidiCommand[nOrigIndex]\nCmd <= 0
        grWEP\sErrorMsg = ""
        ProcedureReturn 0
      EndIf
      
      nErrMax = -1
      nWrnMax = -1
      
      nCtrlMethod = nCtrlMethod
      
      nAltCmd = 0    ; used to support two command types for ETC AB Play Cue (Prg Chg and Ctrl Chg)
      nOrigIndex = 0
      While nOrigIndex <= gnMaxMidiCommand
        
        WEP_populateCmdInfo("ORIG", nOrigIndex, nAltCmd)
        nAltCmd = 0
        
        If grWEP\rOrigInfo\nCmd > 0
          
          debugMsg(sProcName, "nOrigIndex=" + nOrigIndex + ", rOrigInfo\nCmd=&H" + Hex(grWEP\rOrigInfo\nCmd) + ", rOrigInfo\nCC=" + grWEP\rOrigInfo\nCC + ", rOrigInfo\nVV=" + grWEP\rOrigInfo\nVV + ", rOrigInfo\nCCVVFrom=" + grWEP\rOrigInfo\nCCVVFrom + ", rOrigInfo\nCCVVUpto=" + grWEP\rOrigInfo\nCCVVUpto)
          
          For nThisIndex = (nOrigIndex + 1) To gnMaxMidiCommand
            
            WEP_populateCmdInfo("THIS", nThisIndex)
            
            If grWEP\rThisInfo\nCmd > 0
              
              debugMsg(sProcName, "nThisIndex=" + nThisIndex + ", rThisInfo\nCmd=&H" + Hex(grWEP\rThisInfo\nCmd) + ", rThisInfo\nCC=" + grWEP\rThisInfo\nCC + ", rThisInfo\nVV=" + grWEP\rThisInfo\nVV + ", rThisInfo\nCCVVFrom=" + grWEP\rThisInfo\nCCVVFrom + ", rThisInfo\nCCVVUpto=" + grWEP\rThisInfo\nCCVVUpto)
              
              If (grWEP\rThisInfo\nCmd = grWEP\rOrigInfo\nCmd)
                
                sDuplicate = midiCmdDescrForCmdNo(nThisIndex, 0, "", nCtrlMethod, grWEP\rThisInfo\nCmd, grWEP\rThisInfo\nCC)
                sOriginal = midiCmdDescrForCmdNo(nOrigIndex, 0, "", nCtrlMethod, grWEP\rThisInfo\nCmd, grWEP\rThisInfo\nCC)
                debugMsg(sProcName, "sDuplicate=" + sDuplicate + ", sOriginal=" + sOriginal + ", grWEP\rOrigInfo\bCueRelated=" + strB(grWEP\rOrigInfo\bCueRelated) + ", grWEP\rThisInfo\bCueRelated=" + strB(grWEP\rThisInfo\bCueRelated))
                
                If (grWEP\rOrigInfo\bCueRelated = grWEP\rThisInfo\bCueRelated) And (grWEP\rOrigInfo\nCCVVFrom >= 0 And grWEP\rThisInfo\nCCVVFrom >= 0)
                  If (grWEP\rThisInfo\nCCVVFrom <= grWEP\rOrigInfo\nCCVVUpto) And (grWEP\rThisInfo\nCCVVUpto >= grWEP\rOrigInfo\nCCVVFrom)
                    nErrMax + 1
                    ReDim aError(nErrMax)
                    aError(nErrMax)\sDuplicate = sDuplicate
                    aError(nErrMax)\sOriginal = sOriginal
                    debugMsg(sProcName, "Error " + nErrMax + ", " + sDuplicate)
                  EndIf
                  
                ElseIf (grWEP\rOrigInfo\bCueRelated <> grWEP\rThisInfo\bCueRelated) And (grWEP\rOrigInfo\nCCVVFrom >= 0 And grWEP\rThisInfo\nCCVVFrom >= 0)
                  If (grWEP\rThisInfo\nCCVVFrom <= grWEP\rOrigInfo\nCCVVUpto) And (grWEP\rThisInfo\nCCVVUpto >= grWEP\rOrigInfo\nCCVVFrom)
                    For nPhysicalDevPtr = 0 To (gnNumMidiInDevs-1)
                      If gaMidiInDevice(nPhysicalDevPtr)\bCueControl
                        sMidiCue = setMidiCueForCueRelated(nPhysicalDevPtr, grWEP\rThisInfo\nCmd, grWEP\rThisInfo\nCC, grWEP\rThisInfo\nVV)
                        If Len(Trim(sMidiCue)) <> 0
                          nWrnMax + 1
                          ReDim aWarning(nWrnMax)
                          aWarning(nWrnMax)\sDuplicate = sDuplicate
                          aWarning(nWrnMax)\sOriginal = sOriginal
                          aWarning(nWrnMax)\sMidiCueDupl = sMidiCue
                          debugMsg(sProcName, "Warning " + nWrnMax + ", " + sDuplicate)
                        EndIf
                      EndIf
                    Next nPhysicalDevPtr
                  EndIf
                EndIf
              EndIf
              
            EndIf
            
          Next nThisIndex
          
        EndIf
        
        If nOrigIndex = #SCS_MIDI_PLAY_CUE
          If nCtrlMethod = #SCS_CTRLMETHOD_ETC_AB And grWEP\rOrigInfo\nCmd = $C
            ; for ETC AB, if we've just checked the Program Change play cue set, force a repeat of the loop to check the Control Change play cue set
            nAltCmd = $B
            nOrigIndex - 1
          EndIf
        EndIf
        nOrigIndex + 1
        
      Wend
      
      sMyErrorMsg = ""
      If nErrMax >= 0
        For n = 0 To nErrMax
          sMyErrorMsg + #CRLF$ + "DUPLICATED: " + aError(n)\sOriginal + " and " + aError(n)\sDuplicate
        Next n
      EndIf
      
      If (bErrorsOnly = #False) And (nWrnMax >= 0)
        For n = 0 To nWrnMax
          sMyErrorMsg + #CRLF$ + "WARNING: MIDI Cue Number " + aWarning(n)\sMidiCueDupl + " will not be available due to" + #CRLF$ +
                        " duplication in " + aWarning(n)\sOriginal + " and " + aWarning(n)\sDuplicate
        Next n
      EndIf
      
      If (nErrMax >= 0)
        grWEP\sErrorMsg = Mid(sMyErrorMsg, Len(#CRLF$) + 1)
        nCheckResult = 2
      ElseIf (bErrorsOnly = #False) And (nWrnMax >= 0)
        grWEP\sErrorMsg = Mid(sMyErrorMsg, Len(#CRLF$) + 1)
        nCheckResult = 1
      Else
        grWEP\sErrorMsg = sMyErrorMsg
        nCheckResult = 0
      EndIf
      
    EndWith
  EndIf
  
  
  debugMsg(sProcName, #SCS_END + " returning " + nCheckResult + ", grWEP\sErrorMsg=" + ReplaceString(grWEP\sErrorMsg, #CRLF$, " ")) ; Changed 14Jun2022 11.9.4

  ProcedureReturn nCheckResult
EndProcedure

Procedure WEP_displayMidiAssigns()
  PROCNAMEC()
  Protected n
  Protected sHex.s, sErrorMsg.s
  Protected nDuplicatesError, bGoDisplayed
  
  debugMsg(sProcName, #SCS_START)
  
  If grWEP\nCurrentCueDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
      
      ClearGadgetItems(WEP\edgMidiAssigns)
      
      Select \nCtrlMethod
        Case #SCS_CTRLMETHOD_NONE ; #SCS_CTRLMETHOD_NONE
          ; display nothing
          
        Case #SCS_CTRLMETHOD_MTC  ; #SCS_CTRLMETHOD_MTC
          ; display nothing
          
        Case #SCS_CTRLMETHOD_MSC  ; #SCS_CTRLMETHOD_MSC
          AddGadgetItem(WEP\edgMidiAssigns, -1, "MIDI Show Control System Exclusive message format:")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "Byte Type  Value  Explanation")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Start      F0H   Start of System Exclusive Message")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "            7FH   Start of message")
          If \nMscMmcMidiDevId >= 0
            sHex = Right("0" + Hex(\nMscMmcMidiDevId), 2) + "H"
          Else
            sHex = " ? "
          EndIf
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Dev.ID     " + sHex + "   SCS device ID")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " MSC ID     02H   Indicates SysEx is MSC")
          If (\nMscCommandFormat >= $1) And (\nMscCommandFormat <= $FF)
            sHex = Right("0" + Hex(\nMscCommandFormat), 2)
            AddGadgetItem(WEP\edgMidiAssigns, -1, " Format     " + sHex + "H   " + decodeCommandFormatL(\nMscCommandFormat))
          EndIf
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Command    01H(GO), 02H(STOP), 07H(FIRE)")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "Data for GO and STOP commands:")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Q_number         Cue no.(if reqd) ASCII 0-9 and .")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "                  Example: 74.5 = hex 37 34 2E 35")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Delimiter  00H   May omit if Q_list omitted")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Q_list           Cue list (not used)")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Delimiter  00H   May omit if Q_path omitted")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Q_path           Cue path (not used)")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "Data for FIRE command:")
          If (\nGoMacro >= 0) And (\nGoMacro <= 127)
            sHex = Right("0" + Hex(\nGoMacro), 2)
            AddGadgetItem(WEP\edgMidiAssigns, -1, " Macro #    mmH   Macro " + \nGoMacro + "(" + sHex + "H)=GO, else=MIDI Cue #")
          EndIf
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Stop byte  F7H   (All commands) End of SysEx message")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "See 'Help' for more info on MSC or other MIDI formats")
          
        Case #SCS_CTRLMETHOD_MMC  ; #SCS_CTRLMETHOD_MMC
          AddGadgetItem(WEP\edgMidiAssigns, -1, "MIDI Machine Control System Exclusive message format:")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "Byte Type  Value  Explanation")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Start      F0H   Start of System Exclusive Message")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "            7FH   Start of message")
          If \nMscMmcMidiDevId >= 0
            sHex = Right("0" + Hex(\nMscMmcMidiDevId), 2) + "H"
          Else
            sHex = " ? "
          EndIf
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Dev.ID     " + sHex + "   SCS device ID")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " MMC ID     06H   Indicates SysEx is MMC")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Command    01H(Stop), 02H(Play), etc")
          AddGadgetItem(WEP\edgMidiAssigns, -1, " Stop byte  F7H   End of SysEx message")
          AddGadgetItem(WEP\edgMidiAssigns, -1, "See 'Help' for more info on MMC or other MIDI formats")
          
        Default   ; Default
          If \nMidiChannel > 0
            AddGadgetItem(WEP\edgMidiAssigns, -1, "MIDI Channel: " + \nMidiChannel)
          EndIf
          
          If \nCtrlMethod <> #SCS_CTRLMETHOD_PC128
            ; if ctrl method not PC128 then display the GO button assignment first
            n = #SCS_MIDI_GO_BUTTON
            If \aMidiCommand[n]\nCmd >= 0
              AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft(midiCmdDescrForCmdNo(n)) + WEP_buildAssignForSpecial(n, \aMidiCommand[n]\nCmd, \aMidiCommand[n]\nCC, \aMidiCommand[n]\nVV))
              bGoDisplayed = #True
            EndIf
          EndIf
          
          For n = 0 To gnMaxMidiCommand
            If (n <> #SCS_MIDI_GO_BUTTON) Or (bGoDisplayed = #False)
              If \aMidiCommand[n]\nCmd >= 0
                AddGadgetItem(WEP\edgMidiAssigns, -1, (WEP_fixLeft(midiCmdDescrForCmdNo(n)) + WEP_buildAssignForSpecial(n, \aMidiCommand[n]\nCmd, \aMidiCommand[n]\nCC, \aMidiCommand[n]\nVV)))
                If n = #SCS_MIDI_PLAY_CUE
                  ; add any extra 'play cue' commands
                  If \nCtrlMethod = #SCS_CTRLMETHOD_ETC_AB
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 128-255") + "Ctrl Chg 70, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 256-383") + "Ctrl Chg 71, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 384-511") + "Ctrl Chg 72, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 512-639") + "Ctrl Chg 73, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 640-767") + "Ctrl Chg 74, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 768-895") + "Ctrl Chg 75, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 896-999") + "Ctrl Chg 76, value 0-103")
                  ElseIf \nCtrlMethod = #SCS_CTRLMETHOD_ETC_CD
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 128-255") + "Ctrl Chg 78, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 256-383") + "Ctrl Chg 79, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 384-511") + "Ctrl Chg 80, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 512-639") + "Ctrl Chg 81, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 640-767") + "Ctrl Chg 82, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 768-895") + "Ctrl Chg 83, value 0-127")
                    AddGadgetItem(WEP\edgMidiAssigns, -1, WEP_fixLeft("Play Cue 896-999") + "Ctrl Chg 84, value 0-103")
                  EndIf
                EndIf
              EndIf
            EndIf
          Next n
          
          nDuplicatesError = WEP_checkForMidiDuplicates(#False)
          If nDuplicatesError > 0
            ; display errors and warnings
            AddGadgetItem(WEP\edgMidiAssigns, -1, grWEP\sErrorMsg)
          EndIf
          
      EndSelect
      
    EndWith
    
  EndIf
  
EndProcedure

Procedure WEP_displayDMXDetails()
  PROCNAMEC()
  Protected nListIndex
  Protected n
  Protected bEnableTest
  Protected sDevMapName.s, nOtherDevMapCount
  Protected nDevMapDevPtr, nDevNo = -1
  
  debugMsg(sProcName, #SCS_START)
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_LIGHTING
      nDevMapDevPtr = grWEP\nCurrentLightingDevMapDevPtr
      nDevNo = grWEP\nCurrentLightingDevNo
    Case #SCS_DEVGRP_CUE_CTRL
      nDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
      nDevNo = grWEP\nCurrentCueDevNo
  EndSelect
  debugMsg(sProcName, "grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp) + ", nDevMapDevPtr=" + nDevMapDevPtr + ", nDevNo=" + nDevNo)
  
  If grWEP\nCurrentDevGrp = #SCS_DEVGRP_LIGHTING
    For n = 0 To grMapsForDevChgs\nMaxMapIndex
      sDevMapName = grMapsForDevChgs\aMap(n)\sDevMapName
      If sDevMapName <> grProdForDevChgs\sSelectedDevMapName
        nOtherDevMapCount + 1
      EndIf
    Next n
    If nOtherDevMapCount > 0
      ; enable the 'copy from...' button because there is at least one other device map specified
      setEnabled(WEP\btnCopyDMXStartsFrom, #True)
    Else
      setEnabled(WEP\btnCopyDMXStartsFrom, #False)
    EndIf
  EndIf

  If (nDevMapDevPtr >= 0) And (nDevNo >= 0)
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_LIGHTING
        With grMapsForDevChgs\aDev(nDevMapDevPtr)
          debugMsg(sProcName, "grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \nDMXPort=" + \nDMXPort)
          nListIndex = indexForComboBoxData(WEP\cboDMXPhysDev[0], \nPhysicalDevPtr, -1)
          SGS(WEP\cboDMXPhysDev[0], nListIndex)
          setComboBoxByString(WEP\cboDMXIpAddress, \sDMXIpAddress, 0)
          setComboBoxByData(WEP\cboDMXPort[0], \nDMXPort, -1)
          setComboBoxByData(WEP\cboDMXRefreshRate, \nDMXRefreshRate, -1)
          ED_fcDMXPhysDev(0, nDevMapDevPtr)
        EndWith
        
      Case #SCS_DEVGRP_CUE_CTRL
        With grMapsForDevChgs\aDev(nDevMapDevPtr)
          nListIndex = indexForComboBoxData(WEP\cboDMXPhysDev[1], \nPhysicalDevPtr, -1)
          SGS(WEP\cboDMXPhysDev[1], nListIndex)
          If \nPhysicalDevPtr >= 0
            If gaDMXDevice(\nPhysicalDevPtr)\bDummy = #False
              bEnableTest = #True
            EndIf
          EndIf
          setComboBoxByData(WEP\cboDMXPort[1], \nDMXPort, -1)
          ED_fcDMXPhysDev(1, nDevMapDevPtr)
          ; Added 11Aug2022 11.10.0
          If \nDevState = #SCS_DEVSTATE_ACTIVE
            setOwnState(WEP\chkCueActive(nDevNo), #True)
          Else
            setOwnState(WEP\chkCueActive(nDevNo), #False)
          EndIf
          ; End added 11Aug2022 11.10.0
        EndWith
        With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
          Select \nDMXInPref
            Case #SCS_DMX_NOTATION_0_255
              SGS(WEP\optDMXInPref[0], #True)
            Case #SCS_DMX_NOTATION_PERCENT
              SGS(WEP\optDMXInPref[1], #True)
          EndSelect
          
          debugMsg(sProcName, "\nDMXTrgCtrl=" + decodeDMXTrgCtrl(\nDMXTrgCtrl))
          Select \nDMXTrgCtrl
            Case #SCS_DMX_TRG_CHG_UP_TO_VALUE
              SGS(WEP\optDMXTrgCtrl[0], #True)
            Case #SCS_DMX_TRG_CHG_FROM_ZERO
              SGS(WEP\optDMXTrgCtrl[1], #True)
            Case #SCS_DMX_TRG_ANY_CHG
              SGS(WEP\optDMXTrgCtrl[2], #True)
          EndSelect
          ED_fcDMXTrgCtrl()
          WEP_populateDMXTrgValue()
          
          For n = 0 To #SCS_MAX_DMX_COMMAND
            debugMsg(sProcName, "\aDMXCommand[" + decodeDMXCommand(n) + "]\nChannel=" + \aDMXCommand[n]\nChannel)
            SGT(WEP\lblDMXCommand[n], decodeDMXCommandL(n))
            If \aDMXCommand[n]\nChannel < 1
              SGT(WEP\txtDMXChannel[n], "")
            Else
              SGT(WEP\txtDMXChannel[n], Str(\aDMXCommand[n]\nChannel))
            EndIf
          Next n
          
          setEnabled(WEP\btnTestDMX, bEnableTest)
          
        EndWith
        
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentCtrlDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected n
  Protected nListIndex
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  Protected bMidiOutReqd, bMidiThruReqd, bRS232Reqd, bNetworkReqd, bHTTPReqd, bDMXReqd
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWEP\bInDisplayDevProd
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
    ProcedureReturn
  EndIf
  
  If gbInUndoOrRedo = #False
    If grWEP\nCurrentCtrlDevNo <> Index
      If grWEP\bDeletingDevice = #False
        debugMsg(sProcName, "calling WEP_valDisplayedDev()")
        If WEP_valDisplayedDev() = #False
          debugMsg(sProcName, "exiting - WEP_valDisplayedDev() returned false")
          ProcedureReturn
        EndIf
      EndIf
    EndIf
  EndIf
  
  If grWEP\nCurrentDevGrp <> #SCS_DEVGRP_CTRL_SEND
    debugMsg(sProcName, "exiting - grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  nDisplayedDevType = grWEP\nCurrentCtrlDevType
  nDisplayedDevNo = grWEP\nCurrentCtrlDevNo
  
  ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev(), "@grMapsForDevChgs\aMap()")
  nReqdDevNo = Index
  If nReqdDevNo >= 0 And nReqdDevNo <= grProdForDevChgs\nMaxCtrlSendLogicalDev
    debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nReqdDevNo + ")\nDevType=" + decodeDevType(grProdForDevChgs\aCtrlSendLogicalDevs(nReqdDevNo)\nDevType) + ", \sLogicalDev=" + grProdForDevChgs\aCtrlSendLogicalDevs(nReqdDevNo)\sLogicalDev)
    nReqdDevType = grProdForDevChgs\aCtrlSendLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aCtrlSendLogicalDevs(nReqdDevNo)\sLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblCtrlDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblCtrlDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentCtrlDevNo = nReqdDevNo
  debugMsg(sProcName, "grWEP\nCurrentCtrlDevNo=" + grWEP\nCurrentCtrlDevNo)
  grWEP\nCurrentCtrlDevType = nReqdDevType
  grWEP\nCurrentCtrlDevMapDevPtr = nDevMapDevPtr
  
  If (Len(sDevName) <> 0) Or (nReqdDevNo < 0)
    grWEP\sCurrentCtrlDevName = sDevName
  Else
    grWEP\sCurrentCtrlDevName = GGT(WEP\lblCtrlDevNo(nReqdDevNo))
  EndIf
  
  ; device detail panel
  If grWEP\nCurrentCtrlDevType <> #SCS_DEVTYPE_NONE
    SGT(WEP\lblCtrlDevDetail, " " + grWEP\sCurrentCtrlDevName + " (" + decodeDevTypeL(grWEP\nCurrentCtrlDevType) + ") " + grWEP\sDevDetailFrameTitle)
    setVisible(WEP\lblCtrlDevDetail, #True)
  Else
    SGT(WEP\lblCtrlDevDetail, "")
    setVisible(WEP\lblCtrlDevDetail, #False)
  EndIf
  
  debugMsg(sProcName, "grWEP\sCurrentCtrlDevName=" + grWEP\sCurrentCtrlDevName + ", Index=" + Index + ", nDevMapDevPtr=" + nDevMapDevPtr)

  If Index >= 0 And Index <= grProdForDevChgs\nMaxCtrlSendLogicalDev
    With grProdForDevChgs\aCtrlSendLogicalDevs(Index)
      debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", nDisplayedDevType=" + decodeDevType(nDisplayedDevType))
      ; display required device settings
      Select \nDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT
          bMidiOutReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCtrlMidiOutComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CS_MIDI_OUT)
          EndIf
          WEP_displayMidiDetails()
          setVisible(WEP\cntMIDISettings[0], #True)
          
        Case #SCS_DEVTYPE_CS_MIDI_THRU
          bMidiThruReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCtrlMidiThruComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CS_MIDI_THRU)
          EndIf
          WEP_displayMidiThruDetails()
          setVisible(WEP\cntMidiThruSettings, #True)
          
        Case #SCS_DEVTYPE_CS_RS232_OUT
          bRS232Reqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCtrlRS232ComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CS_RS232_OUT)
          EndIf
          WEP_displayRS232Details()
          setVisible(WEP\cntRS232Settings[0], #True)
          
        Case #SCS_DEVTYPE_CS_NETWORK_OUT
          bNetworkReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCtrlNetworkComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CS_NETWORK_OUT)
          EndIf
          WEP_displayCtrlNetworkDetails()
          setVisible(WEP\cntNetworkSettings[0], #True)
          
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST
          bHTTPReqd = #True ; added 30Jan2019 11.8.0.2ae
          WEP_displayHTTPDetails()
          setVisible(WEP\cntHTTPSettings, #True)
          
        Case #SCS_DEVTYPE_LT_DMX_OUT
          bDMXReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCtrlNetworkComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_LT_DMX_OUT)
          EndIf
          WEP_displayDMXDetails()
          debugMsg(sProcName, "calling setVisible(WEP\cntDMXSettings[0], #True)")
          setVisible(WEP\cntDMXSettings[0], #True)
          
      EndSelect
      
    EndWith
    
  EndIf
  
  ; added 30Jan2019 11.8.0.2ae because loading a new cue file with different control send device settings would not hide the previous cue file's control send settings
  setVisible(WEP\cntMIDISettings[0], bMidiOutReqd)
  setVisible(WEP\cntMidiThruSettings, bMidiThruReqd)
  setVisible(WEP\cntRS232Settings[0], bRS232Reqd)
  setVisible(WEP\cntNetworkSettings[0], bNetworkReqd)
  setVisible(WEP\cntHTTPSettings, bHTTPReqd)
  setVisible(WEP\cntDMXSettings[0], bDMXReqd)
  ; end added 30Jan2019 11.8.0.2ae
  
  ensureScrollAreaItemVisible(WEP\scaCtrlDevs, -1, Index)
  ; debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
  WEP_setTBSButtons(Index)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayFixtures(nDevIndex, nFixtureIndex=-1)
  PROCNAMEC()
  Protected n
  Protected rFixtureLogical.tyFixtureLogical
  Protected nDevMapDevPtr
  Protected nFirstGadgetNo, nLastGadgetNo
  Protected nDMXStartChannel, nFixTypeId, sDMXStartChannels.s
  Protected bDimmableChannelsReqd
  
  ; debugMsg(sProcName, #SCS_START + ", nDevIndex=" + nDevIndex + ", nFixtureIndex=" + nFixtureIndex)
  
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, grProdForDevChgs\aLightingLogicalDevs(nDevIndex)\sLogicalDev)
  ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
  
  If grProd\bLightingPre118
    bDimmableChannelsReqd = #True
  EndIf
  
  If bDimmableChannelsReqd
    setVisible(WEP\lblDimmableChannels, #True)
    setVisible(WEP\lblFixtureType, #False)
  Else
    setVisible(WEP\lblFixtureType, #True)
    setVisible(WEP\lblDimmableChannels, #False)
  EndIf

  For n = 0 To gnWEPFixtureLastItem
    With WEPFixture(n)
      If IsGadget(\cntFixture)
        setVisible(\cntFixture, #False)
      EndIf
      \bFixtureUpdated = #False
    EndWith
  Next n
  gnWEPFixtureLastItem = -1
  gnWEPFixtureCurrItem = -1
  
  ; debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevIndex + ")\nMaxFixture=" + grProdForDevChgs\aLightingLogicalDevs(nDevIndex)\nMaxFixture)
  For n = 0 To grProdForDevChgs\aLightingLogicalDevs(nDevIndex)\nMaxFixture
    createWEPFixture()
    With WEPFixture(n)
      If grWEP\bReloadFixtureTypesComboBox
        ; debugMsg(sProcName, "calling WEP_populateCboFixtureType(" + n + ")")
        WEP_populateCboFixtureType(n)
      EndIf
      rFixtureLogical = grProdForDevChgs\aLightingLogicalDevs(nDevIndex)\aFixture(n)
      ; debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevIndex + ")\aFixture(" + n + ")\sFixtureCode=" + rFixtureLogical\sFixtureCode +
      ;                     ", \sFixtureDesc=" + rFixtureLogical\sFixtureDesc + ", \nDefaultDMXStartChannel=" + rFixtureLogical\nDefaultDMXStartChannel +
      ;                     ", \sFixTypeName=" + rFixtureLogical\sFixTypeName)
      SGT(\txtFixtureCode, rFixtureLogical\sFixtureCode)
      SGT(\txtFixtureDesc, rFixtureLogical\sFixtureDesc)
      If bDimmableChannelsReqd
        SGT(\txtDimmableChannels, rFixtureLogical\sDimmableChannels)
        WEP_setDimmableChannelsTooltip(\txtDimmableChannels)
      Else
        nFixTypeId = DMX_getFixTypeId(@grProdForDevChgs, rFixtureLogical\sFixTypeName)
        ; debugMsg(sProcName, "DMX_getFixTypeId(@grProdForDevChgs, " + rFixtureLogical\sFixTypeName + ") returned " + nFixTypeId)
        setComboBoxByData(\cboFixtureType, nFixTypeId, 0)
        ; debugMsg(sProcName, "GGS(WEPFixture(" + n + ")\cboFixtureType)=" + GGS(\cboFixtureType))
      EndIf
      If nDevMapDevPtr >= 0
        sDMXStartChannels = DMX_getFixtureDMXStartChannelsForDevChgs(nDevMapDevPtr, rFixtureLogical\sFixtureCode)
        If sDMXStartChannels
          SGT(\txtDMXStartChannel, sDMXStartChannels)
        Else
          nDMXStartChannel = DMX_getFixtureDMXStartChannelForDevChgs(nDevMapDevPtr, rFixtureLogical\sFixtureCode)
          If nDMXStartChannel > 0
            SGT(\txtDMXStartChannel, Str(nDMXStartChannel))
          ElseIf rFixtureLogical\nDefaultDMXStartChannel ; Added 26Jan2023
            SGT(\txtDMXStartChannel, Str(rFixtureLogical\nDefaultDMXStartChannel)) ; Added 26Jan2023
          Else
            SGT(\txtDMXStartChannel, "")
          EndIf
          ; debugMsg(sProcName, "WEPFixture(" + n + ")\txtDMXStartChannel=" + GGT(\txtDMXStartChannel))
        EndIf
        WEP_setDMXStartChannelsTooltip(\txtDMXStartChannel)
      EndIf
    EndWith
    ED_fcFixtureCode(n)
  Next n
  
  createWEPFixture() ; extra item for inserts
  
  grWEP\bReloadFixtureTypesComboBox = #False
  grWEP\bFixtureTypeTabPopulated = #True
  
  If (nFixtureIndex >= 0) And (nFixtureIndex <= gnWEPFixtureLastItem)
    gnWEPFixtureCurrItem = nFixtureIndex
  Else
    gnWEPFixtureCurrItem = 0
  EndIf
  ; debugMsg(sProcName, "calling WEP_setCurrentFixture(" + gnWEPFixtureCurrItem + ")")
  WEP_setCurrentFixture(gnWEPFixtureCurrItem)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentLightingDevInfo(nDevPtr)
  PROCNAMEC()
  Protected sDevName.s
  Protected n
  Protected nListIndex
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", nDevPtr=" + nDevPtr)
  
  If grWEP\bInDisplayDevProd
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
    ProcedureReturn
  EndIf
  
  If gbInUndoOrRedo = #False
    If grWEP\nCurrentLightingDevNo <> nDevPtr
      debugMsg(sProcName, "calling WEP_valDisplayedDev()")
      If WEP_valDisplayedDev() = #False
        debugMsg(sProcName, "exiting - WEP_valDisplayedDev() returned false")
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  If grWEP\nCurrentDevGrp <> #SCS_DEVGRP_LIGHTING
    debugMsg(sProcName, "exiting - grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  nDisplayedDevType = grWEP\nCurrentLightingDevType
  nDisplayedDevNo = grWEP\nCurrentLightingDevNo
  
  nReqdDevNo = nDevPtr
  If nReqdDevNo >= 0
    debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nReqdDevNo + ")\nDevType=" + decodeDevType(grProdForDevChgs\aLightingLogicalDevs(nReqdDevNo)\nDevType) +
                        ", \sLogicalDev=" + grProdForDevChgs\aLightingLogicalDevs(nReqdDevNo)\sLogicalDev)
    nReqdDevType = grProdForDevChgs\aLightingLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aLightingLogicalDevs(nReqdDevNo)\sLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  debugMsg(sProcName, "nReqdDevNo=" + nReqdDevNo + ", nDisplayedDevNo=" + nDisplayedDevNo)
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblLightingDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblLightingDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentLightingDevNo = nReqdDevNo
  debugMsg(sProcName, "grWEP\nCurrentLightingDevNo=" + grWEP\nCurrentLightingDevNo)
  grWEP\nCurrentLightingDevType = nReqdDevType
  grWEP\nCurrentLightingDevMapDevPtr = nDevMapDevPtr
  
  If (sDevName) Or (nReqdDevNo < 0)
    grWEP\sCurrentLightingDevName = sDevName
  Else
    grWEP\sCurrentLightingDevName = GGT(WEP\lblLightingDevNo(nReqdDevNo))
  EndIf
  
  ; device detail panel
  If grWEP\nCurrentLightingDevType <> #SCS_DEVTYPE_NONE
    SGT(WEP\lblLightingDevDetail, " " + grWEP\sCurrentLightingDevName + " (" + decodeDevTypeL(grWEP\nCurrentLightingDevType) + ") " + grWEP\sDevDetailFrameTitle)
    setVisible(WEP\lblLightingDevDetail, #True)
  Else
    SGT(WEP\lblLightingDevDetail, "")
    setVisible(WEP\lblLightingDevDetail, #False)
  EndIf
  
  debugMsg(sProcName, "grWEP\sCurrentLightingDevName=" + grWEP\sCurrentLightingDevName + ", nDevPtr=" + nDevPtr + ", nDevMapDevPtr=" + nDevMapDevPtr)

  If nDevPtr < 0
    ; hide currently-displayed device type settings
    Select nDisplayedDevType
      Case #SCS_DEVTYPE_LT_DMX_OUT
        setVisible(WEP\cntDMXSettings[0], #False)
    EndSelect
  Else
    With grProdForDevChgs\aLightingLogicalDevs(nDevPtr)
      debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", nDisplayedDevType=" + decodeDevType(nDisplayedDevType))
      If nDisplayedDevType <> \nDevType
        ; change of displayed device type, so hide currently-displayed device type settings
        Select nDisplayedDevType
          Case #SCS_DEVTYPE_LT_DMX_OUT
            setVisible(WEP\cntDMXSettings[0], #False)
        EndSelect
      ElseIf nDisplayedDevType = -1
        If getVisible(WEP\cntDMXSettings[0])
          setVisible(WEP\cntDMXSettings[0], #False)
        EndIf
      EndIf
      ; display required device settings
      Select \nDevType
        Case #SCS_DEVTYPE_LT_DMX_OUT
          If grWEP\bLightingComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_LT_DMX_OUT)
          EndIf
          WEP_displayDMXDetails()
          debugMsg(sProcName, "calling setVisible(WEP\cntDMXSettings[0], #True)")
          setVisible(WEP\cntDMXSettings[0], #True)
          debugMsg(sProcName, "calling WEP_displayFixtures(" + nDevPtr + ")")
          WEP_displayFixtures(nDevPtr)
      EndSelect
    EndWith
  EndIf
  
  ensureScrollAreaItemVisible(WEP\scaLightingDevs, -1, nDevPtr)
  WEP_setTBSButtons(nDevPtr)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentFixture(Index)
  PROCNAMEC()
  Protected nDisplayedFixtureIndex, nReqdFixtureIndex
  Protected bValidationResult
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", gnWEPFixtureCurrItem=" + gnWEPFixtureCurrItem)
  
  nDisplayedFixtureIndex = gnWEPFixtureCurrItem
  nReqdFixtureIndex = Index
  
  If (nReqdFixtureIndex <> nDisplayedFixtureIndex) And (nDisplayedFixtureIndex >= 0)
    bValidationResult = WEP_validateFixture(grWEP\nCurrentLightingDevNo, nDisplayedFixtureIndex)
    ; debugMsg(sProcName, "WEP_validateFixture(" + grWEP\nCurrentLightingDevNo + ", " + nDisplayedFixtureIndex + ") returned " + strB(bValidationResult))
    If bValidationResult = #False
      ProcedureReturn #False
    EndIf
  EndIf
  
  If nDisplayedFixtureIndex >= 0
    If nReqdFixtureIndex <> nDisplayedFixtureIndex
      SetGadgetColor(WEPFixture(nDisplayedFixtureIndex)\lblFixtureNo, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      ; debugMsg(sProcName, "SetGadgetColor(WEPFixture(" + nDisplayedFixtureIndex + ")\lblFixtureNo, #PB_Gadget_BackColor, #SCS_Very_Light_Grey)")
    EndIf
  EndIf
  If nReqdFixtureIndex >= 0
    SetGadgetColor(WEPFixture(nReqdFixtureIndex)\lblFixtureNo, #PB_Gadget_BackColor, #SCS_Light_Green)
    ; debugMsg(sProcName, "SetGadgetColor(WEPFixture(" + nReqdFixtureIndex + ")\lblFixtureNo, #PB_Gadget_BackColor, #SCS_Light_Green)")
  EndIf
  
  gnWEPFixtureCurrItem = nReqdFixtureIndex
  ensureScrollAreaItemVisible(WEP\scaFixtures, GadgetHeight(WEPFixture(0)\cntFixture), nReqdFixtureIndex)
  WEP_setFixtureButtons(Index)
  
  ; debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_setCurrentLiveDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  Static sLiveSettingsFrameTitle.s
  Static sTestLiveInputFrameTitle.s
  Static bStaticLoaded

  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If bStaticLoaded = #False
    CompilerIf #c_lock_audio_to_ltc
      sLiveSettingsFrameTitle = Lang("Common", "Settings")
    CompilerElse
      sLiveSettingsFrameTitle = Lang("WEP", "frDfltSettings")
    CompilerEndIf
    sTestLiveInputFrameTitle = Lang("WEP", "frTestLiveInput")
    bStaticLoaded = #True
  EndIf
  
  nReqdDevNo = Index
  nDisplayedDevType = grWEP\nCurrentLiveDevType
  nDisplayedDevNo = grWEP\nCurrentLiveDevNo
  
  If grTestLiveInput\bRunningTestLiveInput
    If nReqdDevNo <> nDisplayedDevNo
      debugMsg(sProcName, "calling stopTestLiveInput()")
      stopTestLiveInput()
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd Or grWEP\nCurrentDevGrp <> #SCS_DEVGRP_LIVE_INPUT
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  If nReqdDevNo >= 0
    nReqdDevType = grProdForDevChgs\aLiveInputLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aLiveInputLogicalDevs(nReqdDevNo)\sLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblLiveDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblLiveDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentLiveDevNo = nReqdDevNo
  grWEP\nCurrentLiveDevType = nReqdDevType
  grWEP\nCurrentLiveDevMapDevPtr = nDevMapDevPtr
  
  If Len(sDevName) > 0
    grWEP\sCurrentLiveInputDevName = sDevName
  ElseIf nReqdDevNo >= 0
    grWEP\sCurrentLiveInputDevName = GGT(WEP\lblLiveDevNo(nReqdDevNo))
  Else
    grWEP\sCurrentLiveInputDevName = ""
  EndIf
  
  ; panel titles
  SetGadgetItemText(WEP\pnlLiveInputDevDetail, 0, LTrim(grWEP\sCurrentLiveInputDevName + ": " + sLiveSettingsFrameTitle))
  SetGadgetItemText(WEP\pnlLiveInputDevDetail, 1, LTrim(grWEP\sCurrentLiveInputDevName + ": " + sTestLiveInputFrameTitle))
  
  If Index < 0
    
    ; settings panel
    SLD_setMax(WEP\sldDfltInputDevLevel, #SCS_MAXVOLUME_SLD)
    SLD_setLevel(WEP\sldDfltInputDevLevel, grLiveInputLogicalDevsDef\fDfltInputLevel)
    SGT(WEP\txtDfltInputDevDBLevel, grLiveInputLogicalDevsDef\sDfltInputDBLevel)
    CompilerIf #c_lock_audio_to_ltc
      If IsGadget(WEP\chkInputForLTC)
        setOwnState(WEP\chkInputForLTC, grLiveInputLogicalDevsDef\bInputForLTC)
      EndIf
    CompilerEndIf
    
    ; live test panel
    grWEP\bEnableTestLiveInput = #False
    WEP_setTestLiveInputButtonsEnabledState()
    
  Else
    
    With grProdForDevChgs\aLiveInputLogicalDevs(Index)
      
      ; settings panel
      SLD_setMax(WEP\sldDfltInputDevLevel, #SCS_MAXVOLUME_SLD)
      SLD_setLevel(WEP\sldDfltInputDevLevel, \fDfltInputLevel)
      SGT(WEP\txtDfltInputDevDBLevel, \sDfltInputDBLevel)
      CompilerIf #c_lock_audio_to_ltc
        If IsGadget(WEP\chkInputForLTC)
          setOwnState(WEP\chkInputForLTC, \bInputForLTC)
        EndIf
      CompilerEndIf
      
      ; live test panel
      If (Len(Trim(\sLogicalDev))) > 0 And (\bNoDevice = #False)
        grWEP\bEnableTestLiveInput = #True
      Else
        grWEP\bEnableTestLiveInput = #False
      EndIf
      WEP_setTestLiveInputButtonsEnabledState()
      
    EndWith
    
  EndIf
  
  ensureScrollAreaItemVisible(WEP\scaLiveDevs, -1, Index)
  WEP_setTBSButtons(Index)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentInGrpInfo(Index)
  PROCNAMEC()
  Protected n
  Protected sLogicalDev.s
  Protected nListIndex
  Protected nDisplayedInGrpNo, nReqdInGrpNo
  Protected bEnabled
  Protected bLiveInputsPresent
  Protected sInGrpName.s
  Static sInGrpAssignmentsFrameTitle.s, bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nReqdInGrpNo = Index
  nDisplayedInGrpNo = grWEP\nCurrentInGrpNo

  If grWEP\bInDisplayDevProd Or grWEP\nCurrentDevGrp <> #SCS_DEVGRP_IN_GRP
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  ; load language constants into static variables
  If bStaticLoaded = #False
    sInGrpAssignmentsFrameTitle = Lang("WEP", "frInGrpAssignments")
    bStaticLoaded = #True
  EndIf
  
  If nReqdInGrpNo >= 0
    sInGrpName = grProdForDevChgs\aInGrps(nReqdInGrpNo)\sInGrpName
  Else
    sInGrpName = ""
  EndIf
  
  If nReqdInGrpNo <> nDisplayedInGrpNo
    If nDisplayedInGrpNo >= 0
      SetGadgetColor(WEP\lblInGrpNo(nDisplayedInGrpNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdInGrpNo >= 0
      SetGadgetColor(WEP\lblInGrpNo(nReqdInGrpNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentInGrpNo = nReqdInGrpNo
  
  If Len(sInGrpName) > 0
    grWEP\sCurrentInGrpName = sInGrpName
  ElseIf nReqdInGrpNo >= 0
    grWEP\sCurrentInGrpName = GGT(WEP\lblInGrpNo(nReqdInGrpNo))
  Else
    grWEP\sCurrentInGrpName = ""
  EndIf

  ; panel titles
  SetGadgetItemText(WEP\pnlInGrpDetail, 0, LTrim(grWEP\sCurrentInGrpName + ": " + sInGrpAssignmentsFrameTitle))
  
  If sInGrpName
    bEnabled = #True
    For n = 0 To grProdForDevChgs\nMaxLiveInputLogicalDev
      If Trim(grProdForDevChgs\aLiveInputLogicalDevs(n)\sLogicalDev)
        bLiveInputsPresent = #True
        Break
      EndIf
    Next n
  EndIf
  
  debugMsg(sProcName, "calling WEP_populateInGrpLiveInputs(" + Index + ")")
  WEP_populateInGrpLiveInputs(Index)
  
  With grProdForDevChgs\aInGrps(Index)
    For n = 0 To \nMaxInGrpItem
      If bEnabled And bLiveInputsPresent
        setEnabled(WEP\cboInGrpLiveInput(n), #True)
        sLogicalDev = \aInGrpItem(n)\sInGrpItemLiveInput
        nListIndex = indexForComboBoxRow(WEP\cboInGrpLiveInput(n), sLogicalDev, -1)
        SGS(WEP\cboInGrpLiveInput(n), nListIndex)
        ; debugMsg0(sProcName, "SGS(WEP\cboInGrpLiveInput(" + n + "), " + nListIndex + ")")
      Else
        setEnabled(WEP\cboInGrpLiveInput(n), #False)
        If GGS(WEP\cboInGrpLiveInput(n)) >= 0
          SGS(WEP\cboInGrpLiveInput(n), -1)
          ; debugMsg0(sProcName, "SGS(WEP\cboInGrpLiveInput(" + n + "), -1)")
        EndIf
      EndIf
    Next n
    If bEnabled And bLiveInputsPresent
      If \nMaxInGrpItemDisplay > \nMaxInGrpItem
        n = \nMaxInGrpItemDisplay
        If IsGadget(WEP\cboInGrpLiveInput(n)) ; the 'spare' item at the end of the list
          If getVisible(WEP\cboInGrpLiveInput(n)) = #False
            setVisible(WEP\cboInGrpLiveInput(n), #True)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  ensureScrollAreaItemVisible(WEP\scaInGrps, -1, Index)
  WEP_setTBSButtons(Index)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentFixType(nFTIndex)
  PROCNAMEC()
  Protected nListIndex
  Protected nDisplayedFixTypeNo, nReqdFixTypeNo, nFTCIndex
  Protected bEnabled
  Protected sFixTypeName.s
  Protected bValidationResult
  Protected bDisplayFirstTab
  Static bStaticLoaded
  Static sFixTypeDetailFrameTitle.s, sFixTypeChannelsFrameTitle.s
  
  debugMsg(sProcName, #SCS_START + ", nFTIndex=" + nFTIndex)
  
  nReqdFixTypeNo = nFTIndex
  nDisplayedFixTypeNo = grWEP\nCurrentFixTypeNo
  
  If (nReqdFixTypeNo <> nDisplayedFixTypeNo) And (nDisplayedFixTypeNo >= 0)
    debugMsg(sProcName, "calling WEP_validateFixtureType(" + nDisplayedFixTypeNo + ")")
    bValidationResult = WEP_validateFixtureType(nDisplayedFixTypeNo)
    debugMsg(sProcName, "WEP_validateFixtureType(" + nDisplayedFixTypeNo + ") returned " + strB(bValidationResult))
    If bValidationResult = #False
      ProcedureReturn #False
    EndIf
  EndIf
  
  If grWEP\bInDisplayDevProd Or grWEP\nCurrentDevGrp <> #SCS_DEVGRP_FIX_TYPE
    debugMsg(sProcName, "exiting - grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  ; load language constants into static variables
  If bStaticLoaded = #False
    sFixTypeDetailFrameTitle = Lang("WEP","frFixTypeDetail")
    sFixTypeChannelsFrameTitle = Lang("WEP","frFixTypeChannels")
    bStaticLoaded = #True
  EndIf
  
  If nReqdFixTypeNo >= 0
    sFixTypeName = grProdForDevChgs\aFixTypes(nReqdFixTypeNo)\sFixTypeName
  Else
    sFixTypeName = ""
  EndIf
  
  If nDisplayedFixTypeNo >= 0
    SetGadgetColor(WEP\lblFixTypeNo(nDisplayedFixTypeNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
  EndIf
  If nReqdFixTypeNo >= 0
    SetGadgetColor(WEP\lblFixTypeNo(nReqdFixTypeNo), #PB_Gadget_BackColor, #SCS_Light_Green)
  EndIf
  
  grWEP\nCurrentFixTypeNo = nReqdFixTypeNo
  
  If sFixTypeName
    grWEP\sCurrentFixTypeName = sFixTypeName
  ElseIf nReqdFixTypeNo >= 0
    grWEP\sCurrentFixTypeName = GGT(WEP\lblFixTypeNo(nReqdFixTypeNo))
    bDisplayFirstTab = #True
  Else
    grWEP\sCurrentFixTypeName = ""
  EndIf
  
  ; panel titles
  SetGadgetItemText(WEP\pnlFixTypeDetail, 0, LTrim(grWEP\sCurrentFixTypeName + ": " + sFixTypeDetailFrameTitle))
  SetGadgetItemText(WEP\pnlFixTypeDetail, 1, LTrim(grWEP\sCurrentFixTypeName + ": " + sFixTypeChannelsFrameTitle))
  
  If nReqdFixTypeNo >= 0
    With grProdForDevChgs\aFixTypes(nReqdFixTypeNo)
      SGT(WEP\txtFixTypeDesc, \sFixTypeDesc)
      If \nTotalChans > 0
        SGT(WEP\txtFTTotalChans, Str(\nTotalChans))
      Else
        SGT(WEP\txtFTTotalChans, "")
      EndIf
    EndWith
  Else
    SGT(WEP\txtFTTotalChans, "")
  EndIf
  
  If nReqdFixTypeNo >= 0
    WEP_displayFixTypeChans(nReqdFixTypeNo)
    ensureScrollAreaItemVisible(WEP\scaFixTypes, -1, nReqdFixTypeNo)
    WEP_setTBSButtons(nReqdFixTypeNo)
  Else
    WEP_displayFixTypeChans(0)
    ensureScrollAreaItemVisible(WEP\scaFixTypes, -1, 0)
    WEP_setTBSButtons(0)
  EndIf
  
  If bDisplayFirstTab
    SGS(WEP\pnlFixTypeDetail, 0)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setCurrentFixTypeChan(nFTCIndex)
  PROCNAMEC()
  Protected nReqdFixTypeChanNo, nDisplayedFixTypeChanNo
  
  nReqdFixTypeChanNo = nFTCIndex
  nDisplayedFixTypeChanNo = grWEP\nCurrentFixTypeChanNo
  
  If (nDisplayedFixTypeChanNo >= 0) And (nDisplayedFixTypeChanNo <> nReqdFixTypeChanNo)
    SetGadgetColor(WEP\lblFTCChanNo[nDisplayedFixTypeChanNo], #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
  EndIf
  If nReqdFixTypeChanNo >= 0
    SetGadgetColor(WEP\lblFTCChanNo[nReqdFixTypeChanNo], #PB_Gadget_BackColor, #SCS_Light_Green)
  EndIf
  
  grWEP\nCurrentFixTypeChanNo = nReqdFixTypeChanNo
  
  ensureScrollAreaItemVisible(WEP\scaFixTypeChans, -1, nFTCIndex)
  
EndProcedure

Procedure WEP_setCurrentCueDevInfo(Index)
  PROCNAMEC()
  Protected sDevName.s
  Protected n
  Protected nListIndex
  Protected nDisplayedDevType, nDisplayedDevNo
  Protected nReqdDevType, nReqdDevNo
  Protected nDevMapDevPtr
  Protected bMidiReqd, bRS232Reqd, bNetworkReqd, bDMXReqd
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWEP\bInDisplayDevProd
    debugMsg(sProcName, "exiting because grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
    ProcedureReturn
  EndIf
  
  If gbInUndoOrRedo = #False
    If grWEP\nCurrentCueDevNo <> Index
      If grWEP\bDeletingDevice = #False
        debugMsg(sProcName, "calling WEP_valDisplayedDev()")
        If WEP_valDisplayedDev() = #False
          debugMsg(sProcName, "exiting - WEP_valDisplayedDev() returned false")
          ProcedureReturn
        EndIf
      EndIf
    EndIf
  EndIf
  
  If grWEP\nCurrentDevGrp <> #SCS_DEVGRP_CUE_CTRL
    debugMsg(sProcName, "exiting - grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
    ProcedureReturn
  EndIf
  
  nDisplayedDevType = grWEP\nCurrentCueDevType
  nDisplayedDevNo = grWEP\nCurrentCueDevNo
  
  nReqdDevNo = Index
  If nReqdDevNo >= 0
    debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nReqdDevNo + ")\nDevType=" + decodeDevType(grProdForDevChgs\aCueCtrlLogicalDevs(nReqdDevNo)\nDevType) +
                        ", \sCueCtrlLogicalDev=" + grProdForDevChgs\aCueCtrlLogicalDevs(nReqdDevNo)\sCueCtrlLogicalDev)
    nReqdDevType = grProdForDevChgs\aCueCtrlLogicalDevs(nReqdDevNo)\nDevType
    sDevName = grProdForDevChgs\aCueCtrlLogicalDevs(nReqdDevNo)\sCueCtrlLogicalDev
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sDevName)
  Else
    nReqdDevType = #SCS_DEVTYPE_NONE
    sDevName = ""
    nDevMapDevPtr = -1
  EndIf
  
  If nReqdDevNo <> nDisplayedDevNo
    If nDisplayedDevNo >= 0
      SetGadgetColor(WEP\lblCueDevNo(nDisplayedDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
    EndIf
    If nReqdDevNo >= 0
      SetGadgetColor(WEP\lblCueDevNo(nReqdDevNo), #PB_Gadget_BackColor, #SCS_Light_Green)
    EndIf
  EndIf
  
  grWEP\nCurrentCueDevNo = nReqdDevNo
  grWEP\nCurrentCueDevType = nReqdDevType
  grWEP\nCurrentCueDevMapDevPtr = nDevMapDevPtr
  grWEP\sCurrentCueDevName = sDevName
  debugMsg(sProcName, "grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo + ", \nCurrentCueDevType=" + decodeDevType(grWEP\nCurrentCueDevType) +
                      ", \nCurrentCueDevMapDevPtr=" + grWEP\nCurrentCueDevMapDevPtr + ", \sCurrentCueDevName=" + grWEP\sCurrentCueDevName)
  
  ; device detail panel
  If grWEP\nCurrentCueDevType <> #SCS_DEVTYPE_NONE
    SGT(WEP\lblCueDevDetail, " " + grWEP\sCurrentCueDevName + " (" + decodeDevTypeL(grWEP\nCurrentCueDevType) + ") " + grWEP\sDevDetailFrameTitle)
    setVisible(WEP\lblCueDevDetail, #True)
  Else
    SGT(WEP\lblCueDevDetail, "")
    setVisible(WEP\lblCueDevDetail, #False)
  EndIf
  
  
  If Index >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(Index)
      ; display required device settings
      Select \nDevType
        Case #SCS_DEVTYPE_CC_DMX_IN
          bDMXReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCueDMXComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CC_DMX_IN)
          EndIf
          WEP_displayDMXDetails()
          ; setVisible(WEP\cntDMXSettings[1], #True)
          
        Case #SCS_DEVTYPE_CC_MIDI_IN
          bMidiReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCueMidiInComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CC_MIDI_IN)
          EndIf
          WEP_displayMidiDetails()
          ; setVisible(WEP\cntMIDISettings[1], #True)
          
        Case #SCS_DEVTYPE_CC_NETWORK_IN
          bNetworkReqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCueNetworkComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CC_NETWORK_IN)
          EndIf
          WEP_displayNetworkDetails()
          ; setVisible(WEP\cntNetworkSettings[1], #True)
          
        Case #SCS_DEVTYPE_CC_RS232_IN
          bRS232Reqd = #True ; added 30Jan2019 11.8.0.2ae
          If grWEP\bCueRS232ComboBoxesPopulated = #False
            WEP_populateDevTypeComboBoxes(#SCS_DEVTYPE_CC_RS232_IN)
          EndIf
          WEP_displayRS232Details()
          ; setVisible(WEP\cntRS232Settings[1], #True)
          
      EndSelect
      
    EndWith
    
  EndIf
  
  setVisible(WEP\cntMIDISettings[1], bMidiReqd)
  setVisible(WEP\cntRS232Settings[1], bRS232Reqd)
  setVisible(WEP\cntNetworkSettings[1], bNetworkReqd)
  setVisible(WEP\cntDMXSettings[1], bDMXReqd)
  
  ensureScrollAreaItemVisible(WEP\scaCueDevs, -1, Index)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setFixtureButtons(Index)
  ; PROCNAMEC()
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsFixture, sToolTipInsFixture.s
  Protected bEnableDelFixture, sToolTipDelFixture.s
  Protected sFixtureCode.s, bFixtureCodePresent
  Protected nMaxFixture, nLastFixture
  Protected n, nDevNo
  Static sToolTipUp.s, sToolTipDown.s, sToolTipIns.s, sToolTipDel.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If grWEP\bInDisplayDevProd
    ProcedureReturn
  EndIf

  If bStaticLoaded = #False
    ; populate static strings, but do not use LangPars() as $1 will be replaced by the current line's logical Fixture name
    sToolTipUp = Lang("WEP", "btnMoveUpTT")
    sToolTipDown = Lang("WEP", "btnMoveDownTT")
    sToolTipIns = Lang("WEP", "btnInsTT")
    sToolTipDel = Lang("WEP", "btnDelTT")
    bStaticLoaded = #True
  EndIf
  
  nLastFixture = -1 ; Added 24Nov2023 11.10.0-b06
  nMaxFixture = -1  ; Added 24Nov2023 11.10.0-b06
  nDevNo = grWEP\nCurrentLightingDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
      nMaxFixture = \nMaxFixture
      For n = 0 To nMaxFixture
        If Trim(\aFixture(n)\sFixtureCode)
          nLastFixture = n
        EndIf
      Next n
    EndWith
    
    ; debugMsg(sProcName, "nMaxFixture=" + nMaxFixture + ", nLastFixture=" + nLastFixture)
    If Index >= 0
      ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", nLastFixture=" + nLastFixture)
      If Index <= nMaxFixture
        sFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(Index)\sFixtureCode
      EndIf
      
      If sFixtureCode
        bFixtureCodePresent = #True
      Else
        bFixtureCodePresent = #False
        sFixtureCode = grText\sTextFixture + " " + Str(Index+1)
      EndIf
      ; debugMsg(sProcName, "bFixtureCodePresent=" + strB(bFixtureCodePresent) + ", sFixtureCode=" + sFixtureCode)
      
      If (Index >= 0) And (Index <= nLastFixture)
        bEnableDelFixture = #True
        sToolTipDelFixture = ReplaceString(sToolTipDel, "$1", sFixtureCode)
      EndIf
      If (Index > 0) And (Index <= nLastFixture)
        bEnableMoveUp = #True
        sToolTipMoveUp = ReplaceString(sToolTipUp, "$1", sFixtureCode)
      EndIf
      If Index < nLastFixture
        bEnableMoveDown = #True
        sToolTipMoveDown = ReplaceString(sToolTipDown, "$1", sFixtureCode)
      EndIf
      If bFixtureCodePresent
        bEnableInsFixture = #True
        sToolTipInsFixture = ReplaceString(sToolTipIns, "$1", sFixtureCode)
      EndIf
      ; debugMsg(sProcName, "bFixtureCodePresent=" + strB(bFixtureCodePresent) + ", sFixtureCode=" + sFixtureCode + ", bEnableInsFixture=" + strB(bEnableInsFixture))
      
    EndIf
    
    With WEP
      If IsGadget(\imgFixtureButtonTBS[0])
        setEnabled(\imgFixtureButtonTBS[0], bEnableMoveUp)
        scsToolTip(\imgFixtureButtonTBS[0], sToolTipMoveUp)
        setEnabled(\imgFixtureButtonTBS[1], bEnableMoveDown)
        scsToolTip(\imgFixtureButtonTBS[1], sToolTipMoveDown)
        setEnabled(\imgFixtureButtonTBS[2], bEnableInsFixture)
        scsToolTip(\imgFixtureButtonTBS[2], sToolTipInsFixture)
        setEnabled(\imgFixtureButtonTBS[3], bEnableDelFixture)
        scsToolTip(\imgFixtureButtonTBS[3], sToolTipDelFixture)
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setTBSButtons(Index)
  PROCNAMEC()
  Protected bEnableMoveUp, sToolTipMoveUp.s
  Protected bEnableMoveDown, sToolTipMoveDown.s
  Protected bEnableInsDevice, sToolTipInsDevice.s
  Protected bEnableDelDevice, sToolTipDelDevice.s
  Protected sDevName.s, bDevNamePresent
  Protected nLastDev, nMaxDevPerProd
  Protected n
  Protected nDevGrp
  Protected Dim nGadgetNo(3)
  Static sToolTipUp.s, sToolTipDown.s, sToolTipIns.s, sToolTipDel.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp) + ", grWEP\bInDisplayDevProd=" + strB(grWEP\bInDisplayDevProd))
  
  If grWEP\bInDisplayDevProd
    ProcedureReturn
  EndIf

  If bStaticLoaded = #False
    ; populate static strings, but do not use LangPars() as $1 will be replaced by the current line's logical device name
    sToolTipUp = Lang("WEP", "btnMoveUpTT")
    sToolTipDown = Lang("WEP", "btnMoveDownTT")
    sToolTipIns = Lang("WEP", "btnInsTT")
    sToolTipDel = Lang("WEP", "btnDelTT")
    bStaticLoaded = #True
  EndIf
  
  nLastDev = -1
  
  With grProdForDevChgs
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgAudButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxAudDevPerProd ; nb NOT \nMaxAudioLogicalDev or '+' will never be enabled (ditto for other device groups)
          sDevName = Trim(\aAudioLogicalDevs(Index)\sLogicalDev)
          For n = 0 To \nMaxAudioLogicalDev
            If Trim(\aAudioLogicalDevs(n)\sLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgVidAudButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxVidAudDevPerProd
          sDevName = Trim(\aVidAudLogicalDevs(Index)\sVidAudLogicalDev)
          For n = 0 To \nMaxVidAudLogicalDev
            If Trim(\aVidAudLogicalDevs(n)\sVidAudLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgVidCapButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxVidCapDevPerProd
          sDevName = Trim(\aVidCapLogicalDevs(Index)\sLogicalDev)
          For n = 0 To \nMaxVidCapLogicalDev
            If Trim(\aVidCapLogicalDevs(n)\sLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_FIX_TYPE
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgFixTypeButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxFixTypePerProd
          sDevName = Trim(\aFixTypes(Index)\sFixTypeName)
          For n = 0 To \nMaxFixType
            If Trim(\aFixTypes(n)\sFixTypeName)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_LIGHTING
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgLightingButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxLightingDevPerProd
          sDevName = Trim(\aLightingLogicalDevs(Index)\sLogicalDev)
          For n = 0 To \nMaxLightingLogicalDev
            If Trim(\aLightingLogicalDevs(n)\sLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_CTRL_SEND
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgCtrlButtonTBS[n]
        Next n
        nMaxDevPerProd = grLicInfo\nMaxCtrlSendDevPerProd
        If Index >= 0 And Index <= nMaxDevPerProd
          sDevName = Trim(\aCtrlSendLogicalDevs(Index)\sLogicalDev)
          For n = 0 To \nMaxCtrlSendLogicalDev
            If Trim(\aCtrlSendLogicalDevs(n)\sLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_LIVE_INPUT
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgLiveButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxLiveDevPerProd
          sDevName = Trim(\aLiveInputLogicalDevs(Index)\sLogicalDev)
          For n = 0 To \nMaxLiveInputLogicalDev
            If Trim(\aLiveInputLogicalDevs(n)\sLogicalDev)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
      Case #SCS_DEVGRP_IN_GRP
        For n = 0 To 3
          nGadgetNo(n) = WEP\imgInGrpButtonTBS[n]
        Next n
        If Index >= 0
          nMaxDevPerProd = grLicInfo\nMaxInGrpPerProd
          sDevName = Trim(\aInGrps(Index)\sInGrpName)
          For n = 0 To \nMaxInGrp
            If Trim(\aInGrps(n)\sInGrpName)
              nLastDev = n
            EndIf
          Next n
        EndIf
        
    EndSelect
  EndWith
  
  If Index >= 0
    
    If sDevName
      bDevNamePresent = #True
    Else
      bDevNamePresent = #False
      sDevName = grText\sTextDevice + " " + Str(Index+1)
    EndIf
    
    If (Index > 0) And (Index <= nLastDev)
      bEnableMoveUp = #True
      sToolTipMoveUp = ReplaceString(sToolTipUp, "$1", sDevName)
    EndIf
    If Index < nLastDev
      bEnableMoveDown = #True
      sToolTipMoveDown = ReplaceString(sToolTipDown, "$1", sDevName)
    EndIf
    If bDevNamePresent
      If (nLastDev < nMaxDevPerProd)
        bEnableInsDevice = #True
        sToolTipInsDevice = ReplaceString(sToolTipIns, "$1", sDevName)
      EndIf
      Select grWEP\nCurrentDevGrp
        Case #SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVGRP_VIDEO_AUDIO
          ; must leave at least one audio output device, so for audio outputs check (nLastDev > 0)
          If (nLastDev > 0) And (Index <= nLastDev)
            bEnableDelDevice = #True
            sToolTipDelDevice = ReplaceString(sToolTipDel, "$1", sDevName)
          EndIf
        Default
          If (Index <= nLastDev)
            bEnableDelDevice = #True
            sToolTipDelDevice = ReplaceString(sToolTipDel, "$1", sDevName)
          EndIf
      EndSelect
    EndIf
    
  EndIf
  
  If nGadgetNo(0) <> 0
    setEnabled(nGadgetNo(0), bEnableMoveUp)
    scsToolTip(nGadgetNo(0), sToolTipMoveUp)
    setEnabled(nGadgetNo(1), bEnableMoveDown)
    scsToolTip(nGadgetNo(1), sToolTipMoveDown)
    
    ; For 2 universes (current maximum) we don't need to add or subtract devices as there are 2 defined by default and you can set 
    ; them to a device or blank. Having the plus - minus buttons makes no sense and complicates the logic.
    If grLicInfo\nMaxLightingDevPerProd And grWEP\nCurrentDevGrp = #SCS_DEVGRP_LIGHTING         ; only enable if the licence allows for 2 or more DMX devices
      If grLicInfo\nMaxLightingDevPerProd <= 1                                                  ; disable the +- buttons
        bEnableInsDevice = 0
        bEnableDelDevice = 0
        sToolTipInsDevice = ""
        sToolTipDelDevice = ""
      EndIf
    
      setEnabled(nGadgetNo(2), bEnableInsDevice)
      scsToolTip(nGadgetNo(2), sToolTipInsDevice)
      setEnabled(nGadgetNo(3), bEnableDelDevice)
      scsToolTip(nGadgetNo(3), sToolTipDelDevice)
    EndIf
  EndIf
  
EndProcedure

Procedure WEP_populateCboFixtureType(nFixtureItemIndex)
  PROCNAMEC()
  Protected n, sFixtureInfo.s
  Static sChannel.s, sChannels.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START + ", nFixtureItemIndex=" + nFixtureItemIndex)
  
  If bStaticLoaded = #False
    sChannel = " " + Lang("Common", "Channel")
    sChannels = " " + Lang("Common", "Channels")
    bStaticLoaded = #True
  EndIf
  
  With WEPFixture(nFixtureItemIndex)
    If IsGadget(\cboFixtureType)
      ClearGadgetItems(\cboFixtureType)
      ; debugMsg(sProcName, "ClearGadgetItems(WEPFixture(" + nFixtureItemIndex + ")\cboFixtureType)")
      addGadgetItemWithData(\cboFixtureType, "", -1)
      For n = 0 To grProdForDevChgs\nMaxFixType
        sFixtureInfo = grProdForDevChgs\aFixTypes(n)\sFixTypeName + " (" + grProdForDevChgs\aFixTypes(n)\sFixTypeDesc + ") "
        If grProdForDevChgs\aFixTypes(n)\nTotalChans > 0
          sFixtureInfo + grProdForDevChgs\aFixTypes(n)\nTotalChans
          If grProdForDevChgs\aFixTypes(n)\nTotalChans = 1
            sFixtureInfo + sChannel
          Else
            sFixtureInfo + sChannels
          EndIf
        EndIf
        addGadgetItemWithData(\cboFixtureType, Trim(sFixtureInfo), grProdForDevChgs\aFixTypes(n)\nFixTypeId)
        ; debugMsg(sProcName, "addGadgetItemWithData(WEPFixture(" + nFixtureItemIndex + ")\cboFixtureType, " + grProdForDevChgs\aFixTypes(n)\sFixTypeName + ", " + grProdForDevChgs\aFixTypes(n)\nFixTypeId + ")")
      Next n
    EndIf
  EndWith
  
EndProcedure

Procedure WEP_loadDevsForProd(bChangingAudioDriver=#False, nDevGrp=-1)
  PROCNAMEC()
  Protected d, d2, d3
  Protected nDevMapPtr
  Protected sPhysicalDev.s, bFound
  Protected nAudioDriver
  Protected nFixtureItemIndex
  Protected bForceReload
  
  debugMsg(sProcName, #SCS_START + ", bChangingAudioDriver=" + strB(bChangingAudioDriver) + ", nDevGrp=" + decodeDevGrp(nDevGrp))
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT
    ;{ audio outputs
    If nDevMapPtr >= 0
      nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    EndIf
    
    debugMsg(sProcName, "calling sortAudioDevs(" + decodeDriver(nAudioDriver) + ")")
    sortAudioDevs(nAudioDriver)
    debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr + ", gnSortedAudioDevs=" + gnSortedAudioDevs)
    
    If bChangingAudioDriver
      bForceReload = #True
    EndIf
    debugMsg(sProcName, "calling WEP_loadDevTabAudio(" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", -1, " + strB(bForceReload) + ")")
    WEP_loadDevTabAudio(nDevMapPtr, -1, bForceReload)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO
    ;{ video audio outputs
    WEP_loadDevTabVidAud(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE
    ;{ video capture devices
    WEP_loadDevTabVidCap(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_FIX_TYPE
    ;{ fixture types
    WEP_loadDevTabFixType(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_LIGHTING
    ;{ lighting device fixtures
    WEP_loadDevTabLighting(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_CTRL_SEND
    ;{ control send devices
    debugMsg(sProcName, "calling WEP_loadDevTabCtrlSend(" + nDevMapPtr + ")")
    WEP_loadDevTabCtrlSend(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_CUE_CTRL
    ;{ cue control devices
    WEP_loadDevTabCueCtrl(nDevMapPtr)
    ;}
  EndIf
  
  If nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_LIVE_INPUT
    ;{ live inputs
    WEP_loadDevTabLiveInput(nDevMapPtr)
    ;}
  EndIf
  
  debugMsg(sProcName, "calling setDevChgsDerivedFieldsForLogicalDevs()")
  setDevChgsDerivedFieldsForLogicalDevs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_loadAndDisplayDevsForProd()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling WEP_loadDevsForProd()")
  WEP_loadDevsForProd()
  
  WEP_displayAudDev()
  If grLicInfo\nMaxVidAudDevPerProd >= 0
    WEP_displayVidAudDev()
  EndIf
  If grLicInfo\nMaxVidCapDevPerProd >= 0
    WEP_displayVidCapDev()
  EndIf
  If grLicInfo\nMaxFixTypePerProd >= 0
    WEP_displayFixType()
  EndIf
  If grLicInfo\nMaxLightingDevPerProd >= 0
    WEP_displayLightingDev()
  EndIf
  If grLicInfo\nMaxCtrlSendDevPerProd >= 0
    WEP_displayCtrlDev()
  EndIf
  If grLicInfo\nMaxCueCtrlDev >= 0
    WEP_displayCueDev()
  EndIf
  If grLicInfo\nMaxLiveDevPerProd >= 0
    WEP_displayLiveDev()
  EndIf
  If grLicInfo\nMaxInGrpPerProd >= 0
    WEP_displayInGrp()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayAudDev(nSetIndex=0)
  PROCNAMEC()
  Protected d2
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex + ", grProdForDevChgs\sSelectedDevMapName=" + grProdForDevChgs\sSelectedDevMapName + ", \nDevMapPtr=" + grProdForDevChgs\nSelectedDevMapPtr)

  grWEP\bInDisplayDevProd = #True
  
  With grProdForDevChgs
    For d2 = 0 To \nMaxAudioLogicalDevDisplay
      If d2 <= \nMaxAudioLogicalDev
        SGT(WEP\txtAudLogicalDev(d2), \aAudioLogicalDevs(d2)\sLogicalDev)  ; device name used in cues
      Else
        SGT(WEP\txtAudLogicalDev(d2), "")
      EndIf
      nListIndex = \aAudioLogicalDevs(d2)\nNrOfOutputChans - 1
      SGS(WEP\cboNumChans(d2), nListIndex)
      ED_fcAudLogicalDev(d2)
    Next d2
  EndWith
  
  nListIndex = indexForComboBoxRow(WEP\cboDevMap, grProdForDevChgs\sSelectedDevMapName, -1)
  SGS(WEP\cboDevMap, nListIndex)
  
  WEP_displayDevChgsItems()
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling setCurrentAudDevInfo()
  WEP_setCurrentAudDevInfo(nSetIndex)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayVidAudDev(nSetIndex=0)
  PROCNAMEC()
  Protected d2
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  With grProdForDevChgs
    ; debugMsg0(sProcName, "grProdForDevChgs\nMaxVidAudLogicalDev=" + \nMaxVidAudLogicalDev + ", \nMaxVidAudLogicalDevDisplay=" + \nMaxVidAudLogicalDevDisplay)
    For d2 = 0 To \nMaxVidAudLogicalDevDisplay
      If d2 <= \nMaxVidAudLogicalDev
        SGT(WEP\txtVidAudLogicalDev(d2), \aVidAudLogicalDevs(d2)\sVidAudLogicalDev)  ; device name used in cues
      Else
        SGT(WEP\txtVidAudLogicalDev(d2), "")
      EndIf
      ED_fcVidAudLogicalDev(d2)
    Next d2
  EndWith
  
  WEP_displayDevChgsItems()
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_VIDEO_AUD_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling WEP_setCurrentVidAudDevInfo()
  WEP_setCurrentVidAudDevInfo(nSetIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayVidCapDev(nSetIndex=0)
  PROCNAMEC()
  Protected d2
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  With grProdForDevChgs
    debugMsg(sProcName, "\nMaxVidCapLogicalDevDisplay=" + \nMaxVidCapLogicalDevDisplay + ", \nMaxVidCapLogicalDev=" + \nMaxVidCapLogicalDev)
    For d2 = 0 To \nMaxVidCapLogicalDevDisplay
      If d2 <= \nMaxVidCapLogicalDev
        SGT(WEP\txtVidCapLogicalDev(d2), \aVidCapLogicalDevs(d2)\sLogicalDev)  ; device name used in cues
      Else
        SGT(WEP\txtVidCapLogicalDev(d2), "")
      EndIf
      debugMsg(sProcName, "calling ED_fcVidCapLogicalDev(" + d2 + ")")
      ED_fcVidCapLogicalDev(d2)
    Next d2
  EndWith
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_VIDEO_CAP_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  WEP_displayDevChgsItems()
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling WEP_setCurrentVidCapDevInfo()
  WEP_setCurrentVidCapDevInfo(nSetIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s WEP_buildFixTypeInfo(nItemNo)
  PROCNAMEC()
  Protected sFixTypeInfo.s
  Static sLblChannel.s, sLblChannels.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sLblChannel = Lang("Common", "Channel")
    sLblChannels = Lang("Common", "Channels")
    bStaticLoaded = #True
  EndIf
  
  With grProdForDevChgs\aFixTypes(nItemNo)
    sFixTypeInfo = \sFixTypeDesc
    If \nTotalChans = 1
      sFixTypeInfo + ", 1 " + sLblChannel
    ElseIf \nTotalChans > 1
      sFixTypeInfo + ", " + \nTotalChans + " " + sLblChannels
    EndIf
  EndWith
  
  ProcedureReturn sFixTypeInfo
  
EndProcedure

Procedure WEP_displayFixTypeInfo(nFTIndex)
  PROCNAMEC()
  Protected sFixTypeInfo.s
  
  ; debugMsg(sProcName, #SCS_START + ", nFTIndex=" + nFTIndex)
  
  If nFTIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)
      If \sFixTypeName
        sFixTypeInfo = WEP_buildFixTypeInfo(nFTIndex)
      Else
        sFixTypeInfo = ""
      EndIf
      SGT(WEP\txtFixTypeInfo(nFTIndex), sFixTypeInfo)
      debugMsg(sProcName, "GGT(WEP\txtFixTypeInfo(" + nFTIndex + "))=" + GGT(WEP\txtFixTypeInfo(nFTIndex)))
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_displayFixTypeChans(nFTIndex)
  PROCNAMEC()
  Protected nFTCIndex, n, nMaxChanNo, nDMXTextColor
  Protected rFixTypeChan.tyFixTypeChan
  Static sSampleText.s, nSampleTextWidth, nSampleTextLeft, nSampleTextHeight, nSampleTextTop
  
  debugMsg(sProcName, #SCS_START + ", bFTIndex=" + nFTIndex)
  
  With grProdForDevChgs\aFixTypes(nFTIndex)
    debugMsg(sProcName, "grProdForDevChgs\aFixTypes(" + nFTIndex + ")\sFixTypeName=" + \sFixTypeName + ", \nTotalChans=" + \nTotalChans)
    If \sFixTypeName
      setEnabled(WEP\cntFixTypeGeneral, #True)
      setEnabled(WEP\cntFixTypeChannels, #True)
    Else
      setEnabled(WEP\cntFixTypeGeneral, #False)
      setEnabled(WEP\cntFixTypeChannels, #False)
    EndIf
    nMaxChanNo = \nTotalChans
    If nMaxChanNo > #SCS_MAX_FIX_TYPE_CHANNEL
      nMaxChanNo = #SCS_MAX_FIX_TYPE_CHANNEL
    EndIf
    For nFTCIndex = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
      If nFTCIndex <= ArraySize(\aFixTypeChan())
        rFixTypeChan = \aFixTypeChan(nFTCIndex)
      Else
        rFixTypeChan = grFixTypeChanDef
      EndIf
      SGT(WEP\txtFTCChannelDesc[nFTCIndex], rFixTypeChan\sChannelDesc)
      SGT(WEP\txtFTCDefault[nFTCIndex], rFixTypeChan\sDefault)
      
      If rFixTypeChan\bDimmerChan
        setOwnState(WEP\chkFTCDimmerChan[nFTCIndex], #PB_Checkbox_Checked)
      Else
        setOwnState(WEP\chkFTCDimmerChan[nFTCIndex], #PB_Checkbox_Unchecked)
      EndIf
      If rFixTypeChan\sDefault
        SGT(WEP\txtFTCDefault[nFTCIndex], rFixTypeChan\sDefault)
      Else
        SGT(WEP\txtFTCDefault[nFTCIndex], "0")
      EndIf
      
      WEP_paintDMXTextColor(nFTIndex, nFTCIndex)
      
    Next nFTCIndex
    
    SetGadgetAttribute(WEP\scaFixTypeChans, #PB_ScrollArea_InnerHeight, (nMaxChanNo * 21))
    For n = 0 To (#SCS_MAX_FIX_TYPE_CHANNEL - 1)
      If n <= (nMaxChanNo-1)
        setVisible(WEP\cntFTCDetail[n], #True)
      Else
        setVisible(WEP\cntFTCDetail[n], #False)
      EndIf
    Next n
  EndWith
  
  WEP_setCurrentFixTypeChan(0)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayFixType(nFTIndex=0)
  PROCNAMEC()
  Protected n
  
  ; debugMsg(sProcName, #SCS_START + ", nFTIndex=" + nFTIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  With grProdForDevChgs
    ; debugMsg0(sProcName, "grProdForDevChgs\nMaxFixType=" + \nMaxFixType + ", \nMaxFixTypeDisplay=" + \nMaxFixTypeDisplay)
    For n = 0 To \nMaxFixTypeDisplay
      If n <= \nMaxFixType
        ; debugMsg(sProcName, "grProdForDevChgs\aFixTypes(" + n + ")\sFixTypeName=" + \aFixTypes(n)\sFixTypeName)
;         debugMsg(sProcName, "n=" + n + ", \nMaxFixType=" + \nMaxFixType + ", \nMaxFixTypeDisplay=" + \nMaxFixTypeDisplay +
;                             ", ArraySize(WEP\txtFixTypeName())=" + ArraySize(WEP\txtFixTypeName()) + ", ArraySize(\aFixTypes())=" + ArraySize(\aFixTypes()))
        SGT(WEP\txtFixTypeName(n), \aFixTypes(n)\sFixTypeName)
      Else
        SGT(WEP\txtFixTypeName(n), "")
      EndIf
      WEP_displayFixTypeInfo(n)
    Next n
  EndWith
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling WEP_setCurrentFixType()
  WEP_setCurrentFixType(nFTIndex)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayLightingPhysInfo(nDevNo)
  PROCNAMEC()
  Protected sPhysDevInfo.s, nDevMapDevPtr, sLogicalDev.s
  Protected nMyDevState = #SCS_DEVSTATE_NA

  ; debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo)
  
  If nDevNo >= 0
    With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
      sLogicalDev = \sLogicalDev
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev)
      ; debugMsg2(sProcName, "getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, " + sLogicalDev + ")", nDevMapDevPtr)
    EndWith
    
    If nDevMapDevPtr >= 0
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        
        Select \nDevType
          Case #SCS_DEVTYPE_NONE
            nDevMapDevPtr = -1  ; prevents checking nDevState
            
          Case #SCS_DEVTYPE_LT_DMX_OUT
            sPhysDevInfo = \sPhysicalDev
            If \bDummy = #False
              If \nDMXSerial
                sPhysDevInfo + " (" + \nDMXSerial + ")"
              ElseIf \sDMXSerial
                sPhysDevInfo + " (" + \sDMXSerial + ")"
              EndIf
              If \nPhysicalDevPtr >= 0
                If (gaDMXDevice(\nPhysicalDevPtr)\nDMXPorts > 1) And (\nDMXPort > 0)
                  sPhysDevInfo + " DMX" + \nDMXPort
                EndIf
              EndIf
            EndIf
            
        EndSelect
        
        If nDevMapDevPtr >= 0
          ; debugMsg(sProcName, "calling setDevChgsDevStatus(" + nDevMapDevPtr + ", #SCS_DEVGRP_LIGHTING, " + nDevNo + ")")
          setDevChgsDevStatus(nDevMapDevPtr, #SCS_DEVGRP_LIGHTING, nDevNo)
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState))
          nMyDevState = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState
        EndIf
        
      EndWith
    EndIf
    
    If GGT(WEP\txtLightingPhysDevInfo(nDevNo)) <> sPhysDevInfo
      SGT(WEP\txtLightingPhysDevInfo(nDevNo), sPhysDevInfo)
    EndIf
    
    If nMyDevState = #SCS_DEVSTATE_ACTIVE
      setOwnState(WEP\chkLightingActive(nDevNo), #True)
    Else
      setOwnState(WEP\chkLightingActive(nDevNo), #False)
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayLightingDev(Index=0)
  PROCNAMEC()
  Protected d
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  grWEP\bInDisplayDevProd = #True
  
  With grProdForDevChgs
    debugMsg(sProcName, "grProdForDevChgs\nMaxLightingLogicalDev=" + \nMaxLightingLogicalDev + ", \nMaxLightingLogicalDevDisplay=" + \nMaxLightingLogicalDevDisplay)
    For d = 0 To \nMaxLightingLogicalDevDisplay
      If d <= \nMaxLightingLogicalDev
        nListIndex = indexForComboBoxData(WEP\cboLightingDevType(d), \aLightingLogicalDevs(d)\nDevType, -1)
        SGS(WEP\cboLightingDevType(d), nListIndex)
        SGT(WEP\txtLightingLogicalDev(d), \aLightingLogicalDevs(d)\sLogicalDev)  ; device name used in cues
        WEP_displayLightingPhysInfo(d)
      Else
        SGS(WEP\cboLightingDevType(d), -1)
        SGT(WEP\txtLightingLogicalDev(d), "")  ; device name used in cues
      EndIf
      If Index >= 0
        debugMsg(sProcName, "GGS(WEP\cboLightingDevType(" + Index + ")=" + GGS(WEP\cboLightingDevType(Index)))
      EndIf
      ED_fcLightingDevType(d)
    Next d
  EndWith
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_LIGHTING_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_LIGHTING_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  WEP_displayDevChgsItems()
 
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling setCurrentLightingDevInfo()
  debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + Index + ")")
  WEP_setCurrentLightingDevInfo(Index)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayCtrlPhysInfo(nDevNo)
  PROCNAMEC()
  Protected sPhysDevInfo.s, nDevMapDevPtr, sLogicalDev.s
  Protected nRS232BaudRate
  Protected nMyDevState = #SCS_DEVSTATE_NA

; debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo)
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CTRL_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CTRL_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  If nDevNo >= 0 And nDevNo <= grProdForDevChgs\nMaxCtrlSendLogicalDev
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      sLogicalDev = \sLogicalDev
      nRS232BaudRate = \nRS232BaudRate
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sLogicalDev)
      ; debugMsg2(sProcName, "getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, " + sLogicalDev + ")", nDevMapDevPtr)
    EndWith
    
    If nDevMapDevPtr >= 0
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        
        Select \nDevType
          Case #SCS_DEVTYPE_NONE
            nDevMapDevPtr = -1  ; prevents checking nDevState
            
          Case #SCS_DEVTYPE_LT_DMX_OUT
            sPhysDevInfo = \sPhysicalDev
            If \bDummy = #False
              If \nDMXSerial
                sPhysDevInfo + " (" + \nDMXSerial + ")"
              ElseIf \sDMXSerial
                sPhysDevInfo + " (" + \sDMXSerial + ")"
              EndIf
            EndIf
            
          Case #SCS_DEVTYPE_CS_HTTP_REQUEST
            sPhysDevInfo = decodeDevTypeL(\nDevType)
            
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            sPhysDevInfo = \sPhysicalDev
            
          Case #SCS_DEVTYPE_CS_MIDI_THRU
            sPhysDevInfo = \sMidiThruInPhysicalDev + " -> " + \sPhysicalDev
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            sPhysDevInfo = makeNetworkDevDesc(#SCS_DEVGRP_CTRL_SEND, nDevNo)
            ; debugMsg(sProcName, "makeNetworkDevDesc(#SCS_DEVGRP_CTRL_SEND, " + nDevNo + ") returned " + sPhysDevInfo)
            
          Case #SCS_DEVTYPE_CS_RS232_OUT
            sPhysDevInfo = Trim(RemoveString(\sPhysicalDev, "\\.\"))  ; \\.\ is used in serial port names, eg \\.\COM12
            If \bDummy = #False
              If nRS232BaudRate > 0
                sPhysDevInfo + ", " + nRS232BaudRate
              EndIf
            EndIf
            
        EndSelect
        
        If nDevMapDevPtr >= 0
          debugMsg(sProcName, "calling setDevChgsDevStatus(" + nDevMapDevPtr + ", #SCS_DEVGRP_CTRL_SEND, " + nDevNo + ")")
          setDevChgsDevStatus(nDevMapDevPtr, #SCS_DEVGRP_CTRL_SEND, nDevNo)
          debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevState=" + decodeDevState(grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState))
          nMyDevState = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState
        EndIf
        
      EndWith
    EndIf
    
    If nDevNo < grLicInfo\nMaxCtrlSendDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, nDevNo+1)
    EndIf
    
    ; debugMsg(sProcName, "nDevNo=" + nDevNo + ", ArraySize(WEP\txtCtrlPhysDevInfo())=" + ArraySize(WEP\txtCtrlPhysDevInfo()) + ", ArraySize(WEP\txtCtrlLogicalDev())=" + ArraySize(WEP\txtCtrlLogicalDev()))
    If GGT(WEP\txtCtrlPhysDevInfo(nDevNo)) <> sPhysDevInfo
      SGT(WEP\txtCtrlPhysDevInfo(nDevNo), sPhysDevInfo)
    EndIf
    
    If nMyDevState = #SCS_DEVSTATE_ACTIVE
      setOwnState(WEP\chkCtrlActive(nDevNo), #True)
    Else
      setOwnState(WEP\chkCtrlActive(nDevNo), #False)
    EndIf
  EndIf
  
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayCuePhysInfo(nDevNo)
  PROCNAMEC()
  Protected sPhysDevInfo.s, nDevMapDevPtr, sLogicalDev.s
  Protected nRS232BaudRate
  Protected nMyDevState = #SCS_DEVSTATE_NA
  
  ; debugMsg0(sProcName, #SCS_START + ", nDevNo=" + nDevNo + ", grProdForDevChgs\nMaxCueCtrlLogicalDev=" + grProdForDevChgs\nMaxCueCtrlLogicalDev)
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CUE_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CUE_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  If nDevNo >= 0 And nDevNo <= grProdForDevChgs\nMaxCueCtrlLogicalDev
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      sLogicalDev = \sCueCtrlLogicalDev
      nRS232BaudRate = \nRS232BaudRate
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
      ; debugMsg(sProcName, "sLogicalDev='" + sLogicalDev + "', nDevMapDevPtr=" + nDevMapDevPtr)
    EndWith
    If nDevMapDevPtr >= 0
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        ; debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nDevNo + ")\sCueCtrlLogicalDev=" + grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\sCueCtrlLogicalDev + ", \nDevType=" + decodeDevType(grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nDevType))
        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevType=" + decodeDevType(\nDevType))
        
        Select \nDevType
          Case #SCS_DEVTYPE_NONE
            nDevMapDevPtr = -1  ; prevents checking nDevState
            
          Case #SCS_DEVTYPE_CC_DMX_IN
            sPhysDevInfo = \sPhysicalDev
            If \bDummy = #False
              If \nDMXSerial
                sPhysDevInfo + " (" + \nDMXSerial + ")"
              ElseIf \sDMXSerial
                sPhysDevInfo + " (" + \sDMXSerial + ")"
              EndIf
              If \nPhysicalDevPtr >= 0
                If (gaDMXDevice(\nPhysicalDevPtr)\nDMXPorts > 1) And (\nDMXPort > 0)
                  sPhysDevInfo + " DMX" + \nDMXPort
                EndIf
              EndIf
            EndIf
            
          Case #SCS_DEVTYPE_CC_MIDI_IN
            sPhysDevInfo = \sPhysicalDev
            
          Case #SCS_DEVTYPE_CC_NETWORK_IN
            sPhysDevInfo = makeNetworkDevDesc(#SCS_DEVGRP_CUE_CTRL, nDevNo)
            ; debugMsg(sProcName, "makeNetworkDevDesc(#SCS_DEVGRP_CUE_CTRL, " + nDevNo + ") returned " + sPhysDevInfo)
            
          Case #SCS_DEVTYPE_CC_RS232_IN
            sPhysDevInfo = Trim(RemoveString(\sPhysicalDev, "\\.\"))  ; \\.\ is used in serial port names, eg \\.\COM12
            If \bDummy = #False
              If nRS232BaudRate > 0
                sPhysDevInfo + ", " + nRS232BaudRate
              EndIf
            EndIf
            
        EndSelect
        
        If nDevMapDevPtr >= 0
          debugMsg(sProcName, "calling setDevChgsDevStatus(" + nDevMapDevPtr + ", #SCS_DEVGRP_CUE_CTRL, " + nDevNo+ ")")
          setDevChgsDevStatus(nDevMapDevPtr, #SCS_DEVGRP_CUE_CTRL, nDevNo)
          nMyDevState = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState
        EndIf
        
      EndWith
    EndIf
    
    ; debugMsg(sProcName, "nDevNo=" + nDevNo + ", sPhysDevInfo=" + sPhysDevInfo)
    If GGT(WEP\txtCuePhysDevInfo(nDevNo)) <> sPhysDevInfo
      SGT(WEP\txtCuePhysDevInfo(nDevNo), sPhysDevInfo)
      ; debugMsg0(sProcName, "SGT(\txtCuePhysDevInfo(" + nDevNo + "), '" + sPhysDevInfo + "')")
    EndIf
    
    If nMyDevState = #SCS_DEVSTATE_ACTIVE
      setOwnState(WEP\chkCueActive(nDevNo), #True)
    Else
      setOwnState(WEP\chkCueActive(nDevNo), #False)
    EndIf
    
  EndIf
  
EndProcedure

Procedure WEP_displayCtrlDev(nSetIndex=0)
  PROCNAMEC()
  Protected d
  Protected nListIndex, nPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  debugMsg(sProcName, "grProdForDevChgs\nMaxCtrlSendLogicalDev=" + grProdForDevChgs\nMaxCtrlSendLogicalDev + ", \nMaxCtrlSendLogicalDevDisplay=" + grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay)
  
  For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
    With grProdForDevChgs\aCtrlSendLogicalDevs(d)
      ; debugMsg0(sProcName, "calling WEP_setCtrlDevTypeText(" + d + ")")
      WEP_setCtrlDevTypeText(d)
      SGT(WEP\txtCtrlLogicalDev(d), \sLogicalDev)  ; device name used in cues
      WEP_displayCtrlPhysInfo(d)
      ED_fcCtrlDevType(d)
    EndWith
  Next d
  d = grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay
  ; debugMsg0(sProcName, "calling WEP_setCtrlDevTypeText(" + d + ")")
  WEP_setCtrlDevTypeText(d)
  SGT(WEP\txtCtrlLogicalDev(d), "")  ; device name used in cues
  WEP_displayCtrlPhysInfo(d)
  ED_fcCtrlDevType(d)
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CTRL_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CTRL_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling setCurrentCtrlDevInfo
  WEP_setCurrentCtrlDevInfo(nSetIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayCueDev(nSetIndex=0)
  PROCNAMEC()
  Protected d, nDevMapPtr, nDevMapDevPtr
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  ; debugMsg(sProcName, "grProdForDevChgs\sSelectedDevMapName=" + grProdForDevChgs\sSelectedDevMapName + ", \nDevMapPtr=" + nDevMapPtr)
  
  d = -1
  If nDevMapPtr >= 0
    nDevMapDevPtr = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    ; debugMsg(sProcName, "grProdForDevChgs\nMaxCueCtrlLogicalDev=" + grProdForDevChgs\nMaxCueCtrlLogicalDev)
    While nDevMapDevPtr >= 0 And d < grProdForDevChgs\nMaxCueCtrlLogicalDev
      With grMapsForDevChgs\aDev(nDevMapDevPtr)
        If \bExists And \nDevGrp = #SCS_DEVGRP_CUE_CTRL
          d + 1
          nListIndex = indexForComboBoxData(WEP\cboCueDevType(d), \nDevType, -1)
          SGS(WEP\cboCueDevType(d), nListIndex)
          WEP_displayCuePhysInfo(d)
        EndIf
        nDevMapDevPtr = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  While d < grProdForDevChgs\nMaxCueCtrlLogicalDev
    d + 1
    SGS(WEP\cboCueDevType(d), -1)
    WEP_displayCuePhysInfo(d)
  Wend
  
  If IsGadget(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CUE_DEVS])
    SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_CUE_DEVS], grProdForDevChgs\sSelectedDevMapName)
  EndIf
  
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling WEP_setCurrentCueDevInfo()
  WEP_setCurrentCueDevInfo(nSetIndex)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_displayLiveDev(nSetIndex=0)
  PROCNAMEC()
  Protected d2
  Protected nListIndex
  Protected nDevMapPtr
  Protected sDevMapName.s
  Protected nAudioDriver, sDriver.s
  Protected nCheckDevMapResult
  
  debugMsg(sProcName, #SCS_START + ", nSetIndex=" + nSetIndex)
  
  grWEP\bInDisplayDevProd = #True
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    sDevMapName = grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName
    nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
    debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nAudioDriver=" + decodeDriver(grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver))
    If nAudioDriver >= 0
      sDriver = decodeDriverL(nAudioDriver)
    EndIf
  EndIf
  SGT(WEP\txtDevMap[#SCS_PROD_TAB_INDEX_LIVE_DEVS], sDevMapName)
  SGT(WEP\txtAudioDriver[#SCS_PROD_TAB_INDEX_LIVE_DEVS], sDriver)
  
  With grProdForDevChgs
    For d2 = 0 To grProdForDevChgs\nMaxLiveInputLogicalDevDisplay
      If d2 <= \nMaxLiveInputLogicalDev
        SGT(WEP\txtLiveLogicalDev(d2), \aLiveInputLogicalDevs(d2)\sLogicalDev)  ; device name used in cues
        nListIndex = \aLiveInputLogicalDevs(d2)\nNrOfInputChans - 1
        SGS(WEP\cboNumInputChans(d2), nListIndex)
        CompilerIf #c_lock_audio_to_ltc
          If IsGadget(WEP\chkInputForLTC)
            setOwnState(WEP\chkInputForLTC, \aLiveInputLogicalDevs(d2)\bInputForLTC)
          EndIf
        CompilerEndIf
      Else
        SGT(WEP\txtLiveLogicalDev(d2), "")
        CompilerIf #c_lock_audio_to_ltc
          If IsGadget(WEP\chkInputForLTC)
            setOwnState(WEP\chkInputForLTC, grLiveInputLogicalDevsDef\bInputForLTC)
          EndIf
        CompilerEndIf
      EndIf
      ED_fcLiveLogicalDev(d2)
    Next d2
  EndWith
  
  WEP_populateOutputDevForTestLiveInput()
  WEP_displayDevChgsItems()
 
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling setCurrentAudDevInfo
  WEP_setCurrentLiveDevInfo(nSetIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s WEP_buildInGrpInfo(nItemNo)
  PROCNAMEC()
  Protected n2
  Protected nMaxInGrpItem
  Protected sInGrpInfo.s
  
  With grProdForDevChgs\aInGrps(nItemNo)
    ; debugMsg0(sProcName, "nItemNo=" + nItemNo + ", grProdForDevChgs\aInGrps(" + nItemNo + ")\nMaxInGrpItem=" + grProdForDevChgs\aInGrps(nItemNo)\nMaxInGrpItem)
    nMaxInGrpItem = -1
    If \sInGrpName
      For n2 = 0 To \nMaxInGrpItem
        If Trim(\aInGrpItem(n2)\sInGrpItemLiveInput)
          nMaxInGrpItem = n2
          If sInGrpInfo
            sInGrpInfo + " + "
          EndIf
          sInGrpInfo + \aInGrpItem(n2)\sInGrpItemLiveInput
        EndIf
      Next n2
    EndIf
    \nMaxInGrpItem = nMaxInGrpItem
    \nMaxInGrpItemDisplay = nMaxInGrpItem + 1 ; + 1 for a blank entry for entering a new Live Input
    ; debugMsg0(sProcName, "grProdForDevChgs\aInGrps(" + nItemNo + ")\nMaxInGrpItem=" + \nMaxInGrpItem)
  EndWith
  
  ProcedureReturn sInGrpInfo
  
EndProcedure

Procedure WEP_displayInGrp(nInGrpNo=0)
  PROCNAMEC()
  Protected n
  Protected sInGrpInfo.s
  
  debugMsg(sProcName, #SCS_START + ", nInGrpNo=" + nInGrpNo)
  
  grWEP\bInDisplayDevProd = #True
  
  For n = 0 To grProdForDevChgs\nMaxInGrp
    With grProdForDevChgs\aInGrps(n)
      SGT(WEP\txtInGrpName(n), \sInGrpName)
      If \sInGrpName
        sInGrpInfo = WEP_buildInGrpInfo(n)
      Else
        sInGrpInfo = ""
      EndIf
      SGT(WEP\txtInGrpInfo(n), sInGrpInfo)
    EndWith
  Next n
  
  debugMsg(sProcName, "calling createWEPInputGroupLiveInputs(" + nInGrpNo + ")")
  createWEPInputGroupLiveInputs(nInGrpNo) ; necessary to call this now for change of nInGrpNo
  
  WEP_populateInGrpLiveInputs(nInGrpNo)
  WEP_displayDevChgsItems()
 
  grWEP\bInDisplayDevProd = #False   ; set this to False BEFORE calling setCurrentInGrpInfo()
  WEP_setCurrentInGrpInfo(nInGrpNo)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_lblAudDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentAudDevInfo(Index)
  If Len(grProdForDevChgs\aAudioLogicalDevs(Index)\sLogicalDev) = 0
    ; set focus to txtAudLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtAudLogicalDev(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblVidAudDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentVidAudDevInfo(Index)
  If Len(grProdForDevChgs\aVidAudLogicalDevs(Index)\sVidAudLogicalDev) = 0
    ; set focus to txtVidAudLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtVidAudLogicalDev(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblVidCapDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentVidCapDevInfo(Index)
  If Len(grProdForDevChgs\aVidCapLogicalDevs(Index)\sLogicalDev) = 0
    ; set focus to txtVidCapLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtVidCapLogicalDev(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblCtrlDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentCtrlDevInfo(Index)
  SAG(-1)
EndProcedure

Procedure WEP_lblCueDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentCueDevInfo(Index)
  SAG(-1)
EndProcedure

Procedure WEP_lblLiveDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentLiveDevInfo(Index)
  If Len(grProdForDevChgs\aLiveInputLogicalDevs(Index)\sLogicalDev) = 0
    ; set focus to txtLiveLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtLiveLogicalDev(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblInGrpNo_Focus(Index)
  PROCNAMEC()
  
  createWEPInputGroupLiveInputs(Index)
  WEP_setCurrentInGrpInfo(Index)
  If Len(grProdForDevChgs\aInGrps(Index)\sInGrpName) = 0
    ; set focus to txtLiveLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtInGrpName(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblFTCChanNo_Focus(Index)
  WEP_setCurrentFixTypeChan(Index)
  If Len(Trim(GGT(WEP\txtFTCChannelDesc[Index]))) = 0
    ; set focus to txtFTCChannelDesc[Index] if it is currently blank, primarily to set focus logically when tabbing through on adding new fixture types
    SAG(WEP\txtFTCChannelDesc[Index])
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblLightingDevNo_Focus(Index)
  PROCNAMEC()
  
  WEP_setCurrentLightingDevInfo(Index)
  If Len(grProdForDevChgs\aLightingLogicalDevs(Index)\sLogicalDev) = 0
    ; set focus to txtLightingLogicalDev(Index) if it is currently blank, primarily to set focus logically when tabbing through on adding new devices
    SAG(WEP\txtLightingLogicalDev(Index))
  Else
    SAG(-1)
  EndIf
EndProcedure

Procedure WEP_lblFixtureNo_Focus(Index)
  PROCNAMEC()
  Protected nReqdFixtureFocusGadget
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If IsGadget(grWEP\nReqdFixtureFocusGadget)
    nReqdFixtureFocusGadget = grWEP\nReqdFixtureFocusGadget
    grWEP\nReqdFixtureFocusGadget = 0
    SAG(nReqdFixtureFocusGadget)
  Else
    ; debugMsg(sProcName, "calling WEP_setCurrentFixture(" + Index + ")")
    If WEP_setCurrentFixture(Index)
      ; debugMsg(sProcName, "calling SAG(WEPFixture(" + Index + ")\txtFixtureCode)")
      SAG(WEPFixture(Index)\txtFixtureCode)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_txtDfltDevDBLevel_Validate()
  ; PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    If validateDbField(GGT(WEP\txtDfltDevDBLevel), GGT(WEP\lblDfltDevLevel)) = #False
      ProcedureReturn #False
    EndIf
    If GGT(WEP\txtDfltDevDBLevel) <> gsTmpString
      SGT(WEP\txtDfltDevDBLevel, gsTmpString)
    EndIf
    
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      \sDfltDBLevel = Trim(GGT(WEP\txtDfltDevDBLevel))
      \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
      ED_fcTxtDfltDevDBLevel()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDfltDevPan_Validate()
  ; PROCNAMEC()
  
  If validatePanTextField(GGT(WEP\txtDfltDevPan), GGT(WEP\lblDfltDevPan)) = #False
    ProcedureReturn #False
  EndIf
  
  ED_fcTxtDfltDevPan()
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDfltVidAudDBLevel_Validate()
  ; PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    If validateDbField(GGT(WEP\txtDfltVidAudDBLevel), GGT(WEP\lblDfltVidAudLevel)) = #False
      ProcedureReturn #False
    EndIf
    If GGT(WEP\txtDfltVidAudDBLevel) <> gsTmpString
      SGT(WEP\txtDfltVidAudDBLevel, gsTmpString)
    EndIf
    
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      \sDfltDBLevel = Trim(GGT(WEP\txtDfltVidAudDBLevel))
      \fDfltBVLevel = convertDBStringToBVLevel(\sDfltDBLevel)
      ED_fcTxtDfltVidAudDBLevel()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDfltVidAudPan_Validate()
  ; PROCNAMEC()
  
  If validatePanTextField(GGT(WEP\txtDfltVidAudPan), GGT(WEP\lblDfltVidAudPan)) = #False
    ProcedureReturn #False
  EndIf
  
  ED_fcTxtDfltVidAudPan()
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDfltInputDevDBLevel_Validate()
  ; PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentLiveDevNo
  If nDevNo >= 0
    If validateDbField(GGT(WEP\txtDfltInputDevDBLevel), GGT(WEP\lblDfltInputDevDB)) = #False
      ProcedureReturn #False
    EndIf
    If GGT(WEP\txtDfltInputDevDBLevel) <> gsTmpString
      SGT(WEP\txtDfltInputDevDBLevel, gsTmpString)
    EndIf
    
    With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
      \sDfltInputDBLevel = Trim(GGT(WEP\txtDfltInputDevDBLevel))
      \fDfltInputLevel = convertDBStringToBVLevel(\sDfltInputDBLevel)
      ED_fcTxtDfltInputDevDBLevel()
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_updateProdDev(nDevGrp, nDevNo)
  PROCNAMEC()
  Protected d, nListIndex
  Protected nDevMapPtr, nDevMapDevPtr
  Protected sMyLogicalDev.s
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevNo=" + nDevNo)
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  Select nDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT  ; audio output
      sMyLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev
    Case #SCS_DEVGRP_VIDEO_AUDIO  ; video audio output
      sMyLogicalDev = grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev
    Case #SCS_DEVGRP_VIDEO_CAPTURE  ; video capture
      sMyLogicalDev = grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev
    Case #SCS_DEVGRP_LIVE_INPUT  ; live input
      sMyLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\sLogicalDev
    Default
      debugMsg(sProcName, "exiting because nothing to do for this devgrp")
      ProcedureReturn
  EndSelect
  
  ; debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\nFirstDevIndex=" + grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex)
  nDevMapDevPtr = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
  While nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nDevGrp=" + decodeDevGrp(grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevGrp) + ", \sLogicalDev=" + \sLogicalDev + ", \nNextDevIndex=" + \nNextDevIndex)
      If (\nDevGrp = nDevGrp) And (\sLogicalDev = sMyLogicalDev)
        ; debugMsg(sProcName, "Break")
        Break
      EndIf
      nDevMapDevPtr = \nNextDevIndex
    EndWith
  Wend
  If nDevMapDevPtr < 0
    debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
    listAllDevMapsForDevChgs()
    debugMsg(sProcName, "exiting because cannot find " + sMyLogicalDev + " in device map")
    ProcedureReturn
  EndIf
  
  d = nDevNo
  
  Select nDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT  ; audio output
      ;{
      If (d >= 0) And (d <= grLicInfo\nMaxAudDevPerProd)
        With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
          If GGT(WEP\txtAudLogicalDev(d)) <> \sLogicalDev
            SGT(WEP\txtAudLogicalDev(d), \sLogicalDev)  ; device name used in cues
          EndIf
          nListIndex = \nNrOfOutputChans - 1
          If GGS(WEP\cboNumChans(d)) <> nListIndex
            SGS(WEP\cboNumChans(d), nListIndex)
          EndIf
          If Len(\sLogicalDev) = 0
            SGS(WEP\cboAudioPhysicalDev(d), -1)
            debugMsg(sProcName, "SetGadgetState(WEP\cboAudioPhysicalDev(" + d + "), -1)")
            setCboToolTipAtSelectedText(WEP\cboAudioPhysicalDev(d))
            SGS(WEP\cboOutputRange(d), -1)
            If gbDelayTimeAvailable
              SGT(WEP\txtOutputDelayTime(d), "")
            EndIf
            ; SLD_setValue(WEP\sldAudOutputGain(d), 0)
            SLD_setLevel(WEP\sldAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
            SGT(WEP\txtAudOutputGainDB(d), "")
            setOwnState(WEP\chkAudActive(d), #False)
          Else
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            nListIndex = indexForComboBoxRow(WEP\cboAudioPhysicalDev(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev, -1)
            SGS(WEP\cboAudioPhysicalDev(d), nListIndex)
            debugMsg(sProcName, "SetGadgetState(WEP\cboAudioPhysicalDev(" + d + "), " + nListIndex + ")")
            setCboToolTipAtSelectedText(WEP\cboAudioPhysicalDev(d))
            debugMsg(sProcName, "calling WEP_populateOutputRange(" + d + ")")
            WEP_populateOutputRange(d)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr +")\s1BasedOutputRange=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange + ", nFirst1BasedOutputChan=" + Str(grMapsForDevChgs\aDev(nDevMapPtr)\nFirst1BasedOutputChan))
            If (Len(grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange) = 0) And (CountGadgetItems(WEP\cboOutputRange(d)) > 0)
              nListIndex = 0
            Else
              ; nListIndex = indexForComboBoxRow(WEP\cboOutputRange(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange, -1)
              ; mod 3Oct2016 11.6.0 - changed 'not found' default from -1 to 0 to select the first output range, especially useful for changing from a device with "L-R" to a device with "1-2" etc
              nListIndex = indexForComboBoxRow(WEP\cboOutputRange(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange, 0)
            EndIf
            debugMsg(sProcName, "nListIndex=" + nListIndex + ", CountGadgetItems(WEP\cboOutputRange[" + d + "])=" + Str(CountGadgetItems(WEP\cboOutputRange(d))))
            If nListIndex = -1
              grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange = ""
              grMapsForDevChgs\aDev(nDevMapDevPtr)\s0BasedOutputRangeAG = ""
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nFirst1BasedOutputChan = grDevMapDevDef\nFirst1BasedOutputChan
            EndIf
            SGS(WEP\cboOutputRange(d), nListIndex)
            WEP_cboOutputRange_Click(d)
            If gbDelayTimeAvailable
              SGT(WEP\txtOutputDelayTime(d), intToStrBWZ(grMapsForDevChgs\aDev(nDevMapDevPtr)\nDelayTime))
            EndIf
;             SLD_setValue(WEP\sldAudOutputGain(d), SLD_levelToValue(convertDBStringToBVLevel(grMapsForDevChgs\aDev(nDevMapDevPtr)\sDevOutputGainDB)))
            SLD_setLevel(WEP\sldAudOutputGain(d), convertDBStringToBVLevel(grMapsForDevChgs\aDev(nDevMapDevPtr)\sDevOutputGainDB))
            SGT(WEP\txtAudOutputGainDB(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sDevOutputGainDB)
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkAudActive(d), #True)
            Else
              setOwnState(WEP\chkAudActive(d), #False)
            EndIf
          EndIf
        EndWith
      EndIf
      ;}
      
    Case #SCS_DEVGRP_VIDEO_AUDIO  ; video audio output
      ;{
      ; debugMsg(sProcName, "d=" + d + ", nDevNo=" + nDevNo + ", grProdForDevChgs\aVidAudLogicalDevs(0)\sVidAudLogicalDev=" + grProdForDevChgs\aVidAudLogicalDevs(0)\sVidAudLogicalDev)
      If (d >= 0) And (d <= grLicInfo\nMaxVidAudDevPerProd)
        With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
          If GGT(WEP\txtVidAudLogicalDev(d)) <> \sVidAudLogicalDev
            SGT(WEP\txtVidAudLogicalDev(d), \sVidAudLogicalDev) ; device name used in cues
          EndIf
          If Len(\sVidAudLogicalDev) = 0
            SGS(WEP\cboVidAudPhysicalDev(d), -1)
            debugMsg(sProcName, "SGS(WEP\cboVidAudPhysicalDev(" + d + "), -1)")
            setCboToolTipAtSelectedText(WEP\cboVidAudPhysicalDev(d))
            SLD_setLevel(WEP\sldVidAudOutputGain(d), #SCS_MINVOLUME_SINGLE)
            SGT(WEP\txtVidAudOutputGainDB(d), "")
          Else
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            nListIndex = indexForComboBoxRow(WEP\cboVidAudPhysicalDev(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev, -1)
            SGS(WEP\cboVidAudPhysicalDev(d), nListIndex)
            debugMsg(sProcName, "SGS(WEP\cboVidAudPhysicalDev(" + d + "), " + nListIndex + ")")
            setCboToolTipAtSelectedText(WEP\cboVidAudPhysicalDev(d))
            SLD_setLevel(WEP\sldVidAudOutputGain(d), convertDBStringToBVLevel(grMapsForDevChgs\aDev(nDevMapDevPtr)\sDevOutputGainDB))
            SGT(WEP\txtVidAudOutputGainDB(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sDevOutputGainDB)
          EndIf
        EndWith
      EndIf
      ;}
      
    Case #SCS_DEVGRP_VIDEO_CAPTURE  ; video capture
      ;{
      ; debugMsg(sProcName, "d=" + d + ", nDevNo=" + nDevNo + ", grProdForDevChgs\aVidCapLogicalDevs(0)\sLogicalDev=" + grProdForDevChgs\aVidCapLogicalDevs(0)\sLogicalDev)
      If (d >= 0) And (d <= grLicInfo\nMaxVidCapDevPerProd)
        With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
          If GGT(WEP\txtVidCapLogicalDev(d)) <> \sLogicalDev
            SGT(WEP\txtVidCapLogicalDev(d), \sLogicalDev) ; device name used in cues
          EndIf
          If Len(\sLogicalDev) = 0
            SGS(WEP\cboVidCapPhysicalDev(d), -1)
            debugMsg(sProcName, "SGS(WEP\cboVidCapPhysicalDev(" + d + "), -1)")
            setCboToolTipAtSelectedText(WEP\cboVidCapPhysicalDev(d))
          Else
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            nListIndex = indexForComboBoxRow(WEP\cboVidCapPhysicalDev(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev, -1)
            SGS(WEP\cboVidCapPhysicalDev(d), nListIndex)
            debugMsg(sProcName, "SGS(WEP\cboVidCapPhysicalDev(" + d + "), " + nListIndex + ")")
            setCboToolTipAtSelectedText(WEP\cboVidCapPhysicalDev(d))
          EndIf
        EndWith
      EndIf
      ;}
      
    Case #SCS_DEVGRP_LIVE_INPUT  ; live input
      ;{
      If (d >= 0) And (d <= grLicInfo\nMaxLiveDevPerProd)
        With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
          If GGT(WEP\txtLiveLogicalDev(d)) <> \sLogicalDev
            SGT(WEP\txtLiveLogicalDev(d), \sLogicalDev)  ; device name used in cues
          EndIf
          nListIndex = \nNrOfInputChans - 1
          If GGS(WEP\cboNumInputChans(d)) <> nListIndex
            ; debugMsg0(sProcName, "calling SGS(WEP\cboNumInputChans(" + d + "), " + nListIndex + ")")
            SGS(WEP\cboNumInputChans(d), nListIndex)
          EndIf
          If Len(\sLogicalDev) = 0
            SGS(WEP\cboLivePhysicalDev(d), -1)
            setCboToolTipAtSelectedText(WEP\cboLivePhysicalDev(d))
            ; debugMsg0(sProcName, "calling SGS(WEP\cboInputRange(" + d + "), -1)")
            SGS(WEP\cboInputRange(d), -1)
            SLD_setLevel(WEP\sldInputGain(d), #SCS_MINVOLUME_SINGLE)
            SGT(WEP\txtInputGainDB(d), "")
            setOwnState(WEP\chkLiveActive(d), #False)
          Else
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev)
            nListIndex = indexForComboBoxRow(WEP\cboLivePhysicalDev(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev, -1)
            SGS(WEP\cboLivePhysicalDev(d), nListIndex)
            setCboToolTipAtSelectedText(WEP\cboLivePhysicalDev(d))
            debugMsg(sProcName, "calling WEP_populateInputRange(" + d + ")")
            WEP_populateInputRange(d)
            debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr +")\s1BasedInputRange=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedInputRange + ", \nFirst1BasedInputChan=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nFirst1BasedInputChan)
            If (Len(grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedInputRange) = 0) And (CountGadgetItems(WEP\cboInputRange(d)) > 0)
              nListIndex = 0
            Else
              nListIndex = indexForComboBoxRow(WEP\cboInputRange(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedInputRange, -1)
            EndIf
            debugMsg(sProcName, "nListIndex=" + nListIndex + ", CountGadgetItems(WEP\cboInputRange(" + d + "))=" + CountGadgetItems(WEP\cboInputRange(d)))
            If nListIndex = -1
              grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedInputRange = ""
              grMapsForDevChgs\aDev(nDevMapDevPtr)\s0BasedInputRangeAG = ""
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nFirst1BasedInputChan = grDevMapDevDef\nFirst1BasedInputChan
            EndIf
            debugMsg(sProcName, "nListIndex=" + nListIndex + ", grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nFirst1BasedInputChan=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nFirst1BasedInputChan + ", \s1BasedInputRange=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedInputRange)
            SGS(WEP\cboInputRange(d), nListIndex)
            WEP_cboInputRange_Click(d)
            SLD_setLevel(WEP\sldInputGain(d), convertDBStringToBVLevel(grMapsForDevChgs\aDev(nDevMapDevPtr)\sInputGainDB))
            SGT(WEP\txtInputGainDB(d), grMapsForDevChgs\aDev(nDevMapDevPtr)\sInputGainDB)
            If grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_ACTIVE
              setOwnState(WEP\chkLiveActive(d), #True)
            Else
              setOwnState(WEP\chkLiveActive(d), #False)
            EndIf
          EndIf
        EndWith
      EndIf
      ;}
      
  EndSelect
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_txtAudLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, k, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s
  Protected nDevNo
  Protected nListIndex
  Protected u
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "txtAudLogicalDev(" + Index + ")=" + GGT(WEP\txtAudLogicalDev(Index)))
  nDevNo = Index
  
  With grProdForDevChgs
    
    sLogicalDevNew = Trim(GGT(WEP\txtAudLogicalDev(Index)))
    sLogicalDevOld = \aAudioLogicalDevs(nDevNo)\sLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To \nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
        If d <> nDevNo
          If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues
      For j = 1 To gnLastSub
        If aSub(j)\bExists
          If aSub(j)\bSubTypeP
            For n = 0 To grLicInfo\nMaxAudDevPerSub
              If aSub(j)\sPLLogicalDev[n] = sLogicalDevOld
                ensureSplashNotOnTop()
                ; MsgBox("Device name " + sLogicalDevOld + " cannot be cleared as it is used by cue " + aSub(j)\sCue, #PB_MessageRequester_Error, grText\sTextValErr)
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev", sLogicalDevOld, aSub(j)\sCue), #PB_MessageRequester_Error)
                SGT(WEP\txtAudLogicalDev(Index), sLogicalDevOld)
                ProcedureReturn #False
              EndIf
            Next n
          EndIf
        EndIf
      Next j
      For k = 1 To gnLastAud
        If aAud(k)\bExists
          If aAud(k)\bAudTypeF Or aAud(k)\bAudTypeI
            For n = 0 To grLicInfo\nMaxAudDevPerAud
              If aAud(k)\sLogicalDev[n] = sLogicalDevOld
                ensureSplashNotOnTop()
                ; MsgBox("Device name " + sLogicalDevOld + " cannot be cleared as it is used by cue " + aAud(k)\sCue, #PB_MessageRequester_Error, grText\sTextValErr)
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev", sLogicalDevOld, aAud(k)\sCue), #PB_MessageRequester_Error)
                SGT(WEP\txtAudLogicalDev(Index), sLogicalDevOld)
                ProcedureReturn #False
              EndIf
            Next n
          EndIf
        EndIf
      Next k
    EndIf
    
    ; validation passed - new code
    If nDevNo > \nMaxAudioLogicalDev
      addOneAudioLogicalDev(@grProdForDevChgs)
    EndIf
    
    \aAudioLogicalDevs(nDevNo)\sLogicalDev = sLogicalDevNew
    If sLogicalDevNew
      If \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans < 1
        If nDevNo > 0
          \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans = \aAudioLogicalDevs(nDevNo-1)\nNrOfOutputChans
        EndIf
        If \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans < 1
          \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans = 1
        EndIf
      EndIf
    Else
      \aAudioLogicalDevs(nDevNo)\nNrOfOutputChans = 0
    EndIf
    
    If \aAudioLogicalDevs(nDevNo)\nDevId <= 0
      gnNextDevId + 1
      \aAudioLogicalDevs(nDevNo)\nDevId = gnNextDevId
    EndIf
    
    If sLogicalDevNew
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
      If nDevMapDevPtr = -1
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVTYPE_AUDIO_OUTPUT, \aAudioLogicalDevs(nDevNo)\nDevId, sLogicalDevNew)
      EndIf
    EndIf
    debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(" + nDevNo + ")")
    updateDevChgsDev(#SCS_DEVGRP_AUDIO_OUTPUT, #SCS_DEVTYPE_AUDIO_OUTPUT, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling changeLogicalDevsInLvlPts(" + sLogicalDevOld + ", " + sLogicalDevNew + ")")
    changeLogicalDevsInLvlPts(sLogicalDevOld, sLogicalDevNew)
    
    debugMsg(sProcName, "calling changeLogicalDevsInLvlPts(" + sLogicalDevOld + ", " + sLogicalDevNew + ")")
    VST_changeLogicalDev(sLogicalDevOld, sLogicalDevNew)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcAudLogicalDev(" + Index + ")")
    ED_fcAudLogicalDev(Index)
    
    debugMsg(sProcName, "calling WEP_setCurrentAudDevInfo(" + Index + ")")
    WEP_setCurrentAudDevInfo(Index)
    
    If nDevNo < grLicInfo\nMaxAudDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_AUDIO_OUTPUT, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo+1)
    EndIf
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
    ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev(), "@grMapsForDevChgs\aMap()")
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtVidAudLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, k, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s
  Protected nDevNo
  Protected nListIndex
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = Index
  
  With grProdForDevChgs
    sLogicalDevNew = Trim(GGT(WEP\txtVidAudLogicalDev(Index)))
    sLogicalDevOld = \aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To \nMaxVidAudLogicalDev
        If d <> nDevNo
          If \aVidAudLogicalDevs(d)\sVidAudLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues
      For j = 1 To gnLastSub
        If aSub(j)\bExists
          If aSub(j)\bSubTypeA
            If aSub(j)\sVidAudLogicalDev = sLogicalDevOld
              ensureSplashNotOnTop()
              scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev", sLogicalDevOld, aSub(j)\sCue), #PB_MessageRequester_Error)
              SGT(WEP\txtVidAudLogicalDev(Index), sLogicalDevOld)
              ProcedureReturn #False
            EndIf
          EndIf
        EndIf
      Next j
    EndIf
    
    ; validation passed - new code
    If nDevNo > \nMaxVidAudLogicalDev
      addOneVidAudLogicalDev(@grProdForDevChgs)
    EndIf
    \aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev = sLogicalDevNew
    If \aVidAudLogicalDevs(nDevNo)\nDevId <= 0
      gnNextDevId + 1
      \aVidAudLogicalDevs(nDevNo)\nDevId = gnNextDevId
    EndIf
    debugMsg(sProcName, "grProdForDevChgs\aVidAudLogicalDevs(" + nDevNo + ")\nDevId=" + \aVidAudLogicalDevs(nDevNo)\nDevId)

    If sLogicalDevNew
      \aVidAudLogicalDevs(nDevNo)\nNrOfOutputChans = 2  ; set number of output channels = 2 as there's no separate field for this item
      ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, " + nDevNo + ")")
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
      If nDevMapDevPtr = -1
        ; debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVTYPE_VIDEO_AUDIO, " + \aVidAudLogicalDevs(nDevNo)\nDevId + ", " + sLogicalDevNew + ")")
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVTYPE_VIDEO_AUDIO, \aVidAudLogicalDevs(nDevNo)\nDevId, sLogicalDevNew, 2)
      EndIf
    EndIf
    ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(" + nDevNo + ")")
    updateDevChgsDev(#SCS_DEVGRP_VIDEO_AUDIO, #SCS_DEVTYPE_VIDEO_AUDIO, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcVidAudLogicalDev(" + nDevNo + ")")
    ED_fcVidAudLogicalDev(nDevNo)
    
    debugMsg(sProcName, "calling WEP_setCurrentVidAudDevInfo(" + nDevNo + ")")
    WEP_setCurrentVidAudDevInfo(nDevNo)
    
    If nDevNo < grLicInfo\nMaxVidAudDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_VIDEO_AUDIO, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo+1)
    EndIf
    
    WEP_setTBSButtons(nDevNo)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
    ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev(), "@grMapsForDevChgs\aMap()")
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtVidCapLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, k, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s
  Protected nDevNo
  Protected nListIndex
  Protected u
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = Index
  
  With grProdForDevChgs
    sLogicalDevNew = Trim(GGT(WEP\txtVidCapLogicalDev(Index)))
    sLogicalDevOld = \aVidCapLogicalDevs(nDevNo)\sLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To \nMaxVidCapLogicalDev
        If d <> nDevNo
          If \aVidCapLogicalDevs(d)\sLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues
      For j = 1 To gnLastSub
        If aSub(j)\bExists
          If aSub(j)\bSubTypeA
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
                If aAud(k)\sVideoCaptureLogicalDevice = sLogicalDevOld
                  ensureSplashNotOnTop()
                  scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev", sLogicalDevOld, aSub(j)\sCue), #PB_MessageRequester_Error)
                  SGT(WEP\txtVidCapLogicalDev(Index), sLogicalDevOld)
                  ProcedureReturn #False
                EndIf
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
        EndIf
      Next j
    EndIf
    
    ; validation passed - new code
    If nDevNo > \nMaxVidCapLogicalDev
      addOneVidCapLogicalDev(@grProdForDevChgs)
    EndIf
    \aVidCapLogicalDevs(nDevNo)\sLogicalDev = sLogicalDevNew
    If \aVidCapLogicalDevs(nDevNo)\nDevId <= 0
      gnNextDevId + 1
      \aVidCapLogicalDevs(nDevNo)\nDevId = gnNextDevId
    EndIf
    
    If sLogicalDevNew
      debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_CAPTURE, " + nDevNo + ")")
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_CAPTURE, nDevNo)
      If nDevMapDevPtr = -1
        debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_CAPTURE, #SCS_DEVTYPE_VIDEO_CAPTURE, " + \aVidCapLogicalDevs(nDevNo)\nDevId + ", " + sLogicalDevNew + ")")
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_VIDEO_CAPTURE, #SCS_DEVTYPE_VIDEO_CAPTURE, \aVidCapLogicalDevs(nDevNo)\nDevId, sLogicalDevNew, 2)
      EndIf
    EndIf
    ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(" + nDevNo + ")")
    updateDevChgsDev(#SCS_DEVGRP_VIDEO_CAPTURE, #SCS_DEVTYPE_VIDEO_CAPTURE, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_VIDEO_CAPTURE, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcVidCapLogicalDev(" + Index + ")")
    ED_fcVidCapLogicalDev(Index)
    
    debugMsg(sProcName, "calling WEP_setCurrentVidCapDevInfo(" + Index + ")")
    WEP_setCurrentVidCapDevInfo(Index)
    
    If nDevNo < grLicInfo\nMaxVidCapDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_VIDEO_CAPTURE, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_VIDEO_CAPTURE, nDevNo+1)
    EndIf
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtLiveLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, d2, k, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s, sInGrpName.s
  Protected nDevNo
  Protected nListIndex
  Protected u
  Protected nNrOfInputChansOld, nNrOfInputChansNew
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  Protected bInGrpChanged
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, "txtLiveLogicalDev(" + Index + ")=" + GGT(WEP\txtLiveLogicalDev(Index)))
  nDevNo = Index
  
  With grProdForDevChgs
    
    sLogicalDevNew = Trim(GGT(WEP\txtLiveLogicalDev(Index)))
    sLogicalDevOld = \aLiveInputLogicalDevs(nDevNo)\sLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To \nMaxLiveInputLogicalDev
        If d <> nDevNo
          If \aLiveInputLogicalDevs(d)\sLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues or input groups
      For d = 0 To \nMaxInGrp
        sInGrpName = \aInGrps(d)\sInGrpName
        If Len(sInGrpName) > 0
          For d2 = 0 To \aInGrps(d)\nMaxInGrpItem
            If \aInGrps(d)\aInGrpItem(d2)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
              If \aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput = sLogicalDevOld
                ensureSplashNotOnTop()
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev2", sLogicalDevOld, sInGrpName), #PB_MessageRequester_Error)
                SGT(WEP\txtLiveLogicalDev(Index), sLogicalDevOld)
                ProcedureReturn #False
              EndIf
            EndIf
          Next d2
        EndIf
      Next d
      For k = 1 To gnLastAud
        If aAud(k)\bExists
          If aAud(k)\bAudTypeI
            For n = 0 To grLicInfo\nMaxLiveDevPerAud
              If aAud(k)\sLogicalDev[n] = sLogicalDevOld
                ensureSplashNotOnTop()
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotClearDev", sLogicalDevOld, aAud(k)\sCue), #PB_MessageRequester_Error)
                SGT(WEP\txtLiveLogicalDev(Index), sLogicalDevOld)
                ProcedureReturn #False
              EndIf
            Next n
          EndIf
        EndIf
      Next k
    EndIf
    
    ; validation passed - new code
    If nDevNo > \nMaxLiveInputLogicalDev
      addOneLiveInputLogicalDev(@grProdForDevChgs)
    EndIf
    \aLiveInputLogicalDevs(nDevNo)\sLogicalDev = sLogicalDevNew
    nNrOfInputChansOld = \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans
    If sLogicalDevNew
      If \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans < 1
        If nDevNo > 0
          \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans = \aLiveInputLogicalDevs(nDevNo-1)\nNrOfInputChans
        EndIf
        If \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans < 1
          \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans = 1
        EndIf
      EndIf
    Else
      \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans = 0
    EndIf
    nNrOfInputChansNew = \aLiveInputLogicalDevs(nDevNo)\nNrOfInputChans
    
    If \aLiveInputLogicalDevs(nDevNo)\nDevId <= 0
      gnNextDevId + 1
      \aLiveInputLogicalDevs(nDevNo)\nDevId = gnNextDevId
    EndIf
    
    If Len(sLogicalDevNew) = 0
      \aLiveInputLogicalDevs(nDevNo)\nDevType = #SCS_DEVTYPE_NONE
    Else
      \aLiveInputLogicalDevs(nDevNo)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
      If nDevMapDevPtr = -1
        debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_LIVE_INPUT, #SCS_DEVTYPE_LIVE_INPUT, " +
                            \aLiveInputLogicalDevs(nDevNo)\nDevId + ", " +
                            sLogicalDevNew + ")")
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIVE_INPUT, #SCS_DEVTYPE_LIVE_INPUT, \aLiveInputLogicalDevs(nDevNo)\nDevId, sLogicalDevNew)
      EndIf
    EndIf
    debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
    
    grWEP\bReloadInGrpLiveInputs = #True ; Force comboboxes cboInGrpLiveInput() to be reloaded as a live input name may have been changed, added or deleted
    
    ; change name where used in input groups
    If sLogicalDevNew
      For d = 0 To \nMaxInGrp
        sInGrpName = \aInGrps(d)\sInGrpName
        If sInGrpName
          For d2 = 0 To \aInGrps(d)\nMaxInGrpItem
            If \aInGrps(d)\aInGrpItem(d2)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
              If \aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput = sLogicalDevOld
                \aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput = sLogicalDevNew
                bInGrpChanged = #True
              EndIf
            EndIf
          Next d2
        EndIf
      Next d
    EndIf
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(" + nDevNo + ")")
    updateDevChgsDev(#SCS_DEVGRP_LIVE_INPUT, #SCS_DEVTYPE_LIVE_INPUT, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcLiveLogicalDev(" + Index + ")")
    ED_fcLiveLogicalDev(Index)
    
    debugMsg(sProcName, "calling WEP_setCurrentLiveDevInfo(" + Index + ")")
    WEP_setCurrentLiveDevInfo(Index)
    
    If bInGrpChanged
      debugMsg(sProcName, "calling WEP_displayInGrp()")
      WEP_displayInGrp()
    EndIf
    
    If nDevNo < grLicInfo\nMaxLiveDevPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_LIVE_INPUT, " + Str(nDevNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_LIVE_INPUT, nDevNo+1)
    EndIf
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()

    ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev(), "@grMapsForDevChgs\aMap()")
    
  EndWith
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtInGrpName_Validate(Index)
  PROCNAMEC()
  Protected d, k, j, n
  Protected sInGrpNameNew.s, sInGrpNameOld.s
  Protected nInGrpNo
  Protected nListIndex
  Protected u
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "txtInGrpName(" + Index + ")=" + GGT(WEP\txtInGrpName(Index)))
  nInGrpNo = Index
  
  With grProdForDevChgs
    
    sInGrpNameNew = Trim(GGT(WEP\txtInGrpName(Index)))
    sInGrpNameOld = \aInGrps(nInGrpNo)\sInGrpName
    If sInGrpNameNew = sInGrpNameOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If Len(sInGrpNameNew) > 0
      ; ensure name is unique
      For d = 0 To \nMaxInGrp
        If d <> nInGrpNo
          If \aInGrps(d)\sInGrpName = sInGrpNameNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("Errors", "GrpNameAlreadyUsed", sInGrpNameNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    ; validation passed - new code
    If nInGrpNo > \nMaxInGrp
      addOneInGrp(@grProdForDevChgs)
    EndIf
    \aInGrps(nInGrpNo)\sInGrpName = sInGrpNameNew
    If \aInGrps(nInGrpNo)\nInGrpId <= 0
      gnNextInGrpId + 1
      \aInGrps(nInGrpNo)\nInGrpId = gnNextInGrpId
    EndIf
    
    If Len(sInGrpNameNew) = 0
      \aInGrps(nInGrpNo)\nMaxInGrpItem = -1
      \aInGrps(nInGrpNo)\nMaxInGrpItemDisplay = 0
    EndIf
    
    debugMsg(sProcName, "calling ED_fcInGrpName(" + Index + ")")
    ED_fcInGrpName(Index)
    
    debugMsg(sProcName, "calling createWEPInputGroupLiveInputs(" + nInGrpNo + ")")
    createWEPInputGroupLiveInputs(nInGrpNo) ; necessary to call this now for change of nInGrpNo

    debugMsg(sProcName, "calling WEP_setCurrentInGrpInfo(" + Index + ")")
    WEP_setCurrentInGrpInfo(Index)
    
    If nInGrpNo < grLicInfo\nMaxInGrpPerProd
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_IN_GRP, " + Str(nInGrpNo+1) + ")")
      WEP_addDeviceIfReqd(#SCS_DEVGRP_IN_GRP, nInGrpNo+1)
    EndIf
    
    debugMsg(sProcName, "calling WEP_setTBSButtons(" + Index + ")")
    WEP_setTBSButtons(Index)
    
    debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
    ; listDevMap(@grMapsForDevChgs\aMap(grProdForDevChgs\nSelectedDevMapPtr), grMapsForDevChgs\aDev(), "@grMapsForDevChgs\aMap()")
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFixTypeName_Validate(Index)
  PROCNAMEC()
  Protected d, k, j, n
  Protected sFixTypeNameNew.s, sFixTypeNameOld.s
  Protected bError, sMsg.s, bResetName
  Protected nFixTypeNo
  Protected nListIndex
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "txtFixTypeName(" + Index + ")=" + GGT(WEP\txtFixTypeName(Index)))
  nFixTypeNo = Index
  
  With grProdForDevChgs
    sFixTypeNameNew = Trim(GGT(WEP\txtFixTypeName(Index)))
    sFixTypeNameOld = \aFixTypes(nFixTypeNo)\sFixTypeName
    If sFixTypeNameNew = sFixTypeNameOld
      ; no change - nothing to validate
      If GetActiveGadget() = WEP\txtFixTypeInfo(Index)
        SAG(WEP\txtFixTypeDesc)
      EndIf
      ProcedureReturn #True
    EndIf
    
    If sFixTypeNameNew
      ; ensure name is unique
      For d = 0 To ArraySize(\aFixTypes())
        If d <> nFixTypeNo
          If LCase(\aFixTypes(d)\sFixTypeName) = LCase(sFixTypeNameNew)
            bError = #True
            sMsg = LangPars("Errors", "FixtureTypeAlreadyUsed", sFixTypeNameNew)
            Break
          EndIf
        EndIf
      Next d
    Else
      ; if user has blanked out name then make sure the original name is not in use
      For d = 0 To \nMaxLightingLogicalDev
        If \aLightingLogicalDevs(d)\sLogicalDev
          For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
            If \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sFixTypeNameOld
              bError = #True
              sMsg = LangPars("Errors", "CannotClearFixType", GGT(WEP\lblFixTypeName), sFixTypeNameOld, \aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode)
              bResetName = #True
              Break 2 ; Break n, d
            EndIf
          Next n
        EndIf
      Next d
    EndIf
    
    If bError
      ensureSplashNotOnTop()
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      If bResetName
        SGT(WEP\txtFixTypeName(Index), sFixTypeNameOld)
      EndIf
      ProcedureReturn #False
    EndIf
    
    ; validation passed - new code
    If nFixTypeNo > \nMaxFixType
      addOneFixType(@grProdForDevChgs)
    EndIf
    \aFixTypes(nFixTypeNo)\sFixTypeName = sFixTypeNameNew
    If \aFixTypes(nFixTypeNo)\nFixTypeId <= 0
      gnNextFixTypeId + 1
      \aFixTypes(nFixTypeNo)\nFixTypeId = gnNextFixTypeId
    EndIf
    
    ; change the fixture type name where used in any fixtures
    For d = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(d)\sLogicalDev
        For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
          If \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sFixTypeNameOld
            \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sFixTypeNameNew
          EndIf
        Next n
      EndIf
    Next d
    
    debugMsg(sProcName, "calling ED_fcFixTypeName(" + Index + ")")
    ED_fcFixTypeName(Index)
    
    debugMsg(sProcName, "calling WEP_setCurrentFixType(" + Index + ")")
    WEP_setCurrentFixType(Index)
    
    SGS(WEP\pnlFixTypeDetail, 0) ; force first fixture type detail panel to be displayed
    
    \nMaxFixType = -1
    For d = 0 To ArraySize(\aFixTypes())
      If \aFixTypes(d)\sFixTypeName
        \nMaxFixType = d
      EndIf
    Next d
    If \nMaxFixType < grLicInfo\nMaxFixTypePerProd
      \nMaxFixTypeDisplay = \nMaxFixType + 1
    Else
      \nMaxFixTypeDisplay = \nMaxFixType
    EndIf
    debugMsg(sProcName, "grProdForDevChgs\nMaxFixType=" + \nMaxFixType + ", \nMaxFixTypeDisplay=" + \nMaxFixTypeDisplay + ", ArraySize(\aFixTypes())=" + ArraySize(\aFixTypes()))
    
    ; propagate changed fixture type name to fixtures that use this fixture type name
    For d = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(d)\sLogicalDev
        For n = 0 To \aLightingLogicalDevs(d)\nMaxFixture
          If \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sFixTypeNameOld
            \aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sFixTypeNameNew
          EndIf
        Next n
      EndIf
    Next d
    
    If nFixTypeNo < grLicInfo\nMaxFixTypePerProd
      WEP_addDeviceIfReqd(#SCS_DEVGRP_FIX_TYPE, nFixTypeNo+1)
    EndIf
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    
  EndWith
  
  grWEP\bReloadFixtureTypesComboBox = #True ; force FixtureType combo box to be re-populated under Lighting tab
  
  If GetActiveGadget() = WEP\txtFixTypeInfo(Index)
    SAG(WEP\txtFixTypeDesc)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFTDesc_Validate()
  ; PROCNAMEC()
  Protected nFixTypeNo
  
  nFixTypeNo = grWEP\nCurrentFixTypeNo
  If nFixTypeNo >= 0
    With grProdForDevChgs\aFixTypes(nFixTypeNo)
      \sFixTypeDesc = Trim(GGT(WEP\txtFixTypeDesc))
      WEP_displayFixTypeInfo(nFixTypeNo)
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFTTotalChans_Validate()
  PROCNAMEC()
  Protected nFTIndex, nFTCIndex
  Protected sTotalChans.s, nTotalChans
  Protected bValueError, sField.s, sMsg.s, bResetTotalChans
  Protected sFixTypeName.s, sFixtureCode.s
  Protected nProdDevIndex, nProdFixtureIndex, nCueIndex, nSubIndex, nSubFixtureIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nFTIndex = grWEP\nCurrentFixTypeNo
  debugMsg(sProcName, "grWEP\nCurrentFixTypeNo=" + grWEP\nCurrentFixTypeNo)
  If nFTIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)
      sTotalChans = Trim(GGT(WEP\txtFTTotalChans))
      ; debugMsg(sProcName, "sTotalChans=" + sTotalChans)
      sField = Lang("WEP", "lblFTTotalChans")
      bValueError = #True
      If sTotalChans
        If IsNumeric(sTotalChans)
          nTotalChans = Val(sTotalChans)
          If (nTotalChans >= 1) And (nTotalChans <= #SCS_MAX_FIX_TYPE_CHANNEL)
            bValueError = #False
          EndIf
        EndIf
      EndIf
      If bValueError
        sMsg = LangPars("Errors", "MustBeBetween", sField, "1", Str(#SCS_MAX_FIX_TYPE_CHANNEL))
      Else
        If nTotalChans <> \nTotalChans
          ; value OK and the value has been changed, so now make sure no existing lighting cues are using fixtures of this fixture type
          sFixTypeName = \sFixTypeName
          For nProdDevIndex = 0 To grProdForDevChgs\nMaxLightingLogicalDev
            If grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\sLogicalDev
              For nProdFixtureIndex = 0 To grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\nMaxFixture
                If grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\aFixture(nProdFixtureIndex)\sFixTypeName = sFixTypeName
                  sFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\aFixture(nProdFixtureIndex)\sFixtureCode
                  For nCueIndex = 1 To gnLastCue
                    If aCue(nCueIndex)\bSubTypeK
                      nSubIndex = aCue(nCueIndex)\nFirstSubIndex
                      While nSubIndex >= 0
                        If aSub(nSubIndex)\bSubTypeK
                          For nSubFixtureIndex = 0 To aSub(nSubIndex)\nMaxFixture
                            If aSub(nSubIndex)\aLTFixture(nSubFixtureIndex)\sLTFixtureCode = sFixtureCode
                              sMsg = LangPars("Errors", "CannotChangeTotalChans", sField, getSubLabel(nSubIndex), sFixtureCode)
                              bResetTotalChans = #True
                              Break 5 ; Break nSubFixtureIndex, nSubIndex, nCueIndex, nProdFixtureIndex, nProdDevIndex
                            EndIf
                          Next nSubFixtureIndex
                        EndIf
                        nSubIndex = aSub(nSubIndex)\nNextSubIndex
                      Wend
                    EndIf ; EndIf aCue(nCueIndex)\bSubTypeK
                  Next nCueIndex
                EndIf ; EndIf grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\aFixture(nProdFixtureIndex)\sFixTypeName = sFixTypeName
              Next nProdFixtureIndex
            EndIf ; EndIf grProdForDevChgs\aLightingLogicalDevs(nProdDevIndex)\sLogicalDev
          Next nProdDevIndex
        EndIf
      EndIf
      If sMsg
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        If bResetTotalChans
          SGT(WEP\txtFTTotalChans, Str(\nTotalChans))
        EndIf
        ProcedureReturn #False
      EndIf
      
      ; validation OK
      \nTotalChans = nTotalChans
      debugMsg(sProcName, "grProdForDevChgs\aFixTypes(" + nFTIndex + ")\nTotalChans=" + grProdForDevChgs\aFixTypes(nFTIndex)\nTotalChans)
      If (\nTotalChans - 1) > ArraySize(\aFixTypeChan())
        REDIM_ARRAY(\aFixTypeChan, (\nTotalChans - 1), grFixTypeChanDef, "\aFixTypeChan")
      EndIf
      For nFTCIndex = 0 To (\nTotalChans - 1)
        \aFixTypeChan(nFTCIndex)\nChanNo = (nFTCIndex + 1)
      Next nFTCIndex
      WEP_displayFixTypeInfo(nFTIndex)
      WEP_displayFixTypeChans(nFTIndex)
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  grWEP\bReloadFixtureTypesComboBox = #True ; force FixtureType combo box to be re-populated
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFTCChannelDesc_Validate(nFTCIndex)
  PROCNAMEC()
  Protected nFTIndex
  Protected nReqdDMXTextColor
  
  debugMsg(sProcName, #SCS_START)
  
  nFTIndex = grWEP\nCurrentFixTypeNo
  If nFTIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan(nFTCIndex)
      \sChannelDesc = Trim(GGT(WEP\txtFTCChannelDesc[nFTCIndex]))
      If \sChannelDesc
        nReqdDMXTextColor = DMX_setDMXTextColorFromDesc(\sChannelDesc)
        If nReqdDMXTextColor >= 0
          \nDMXTextColor = nReqdDMXTextColor
          WEP_paintDMXTextColor(nFTIndex, nFTCIndex)
        EndIf
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_chkFTCDimmerChan_Click(nFTCIndex)
  PROCNAMEC()
  Protected nFTIndex, nState
  
  debugMsg(sProcName, #SCS_START)
  
  nFTIndex = grWEP\nCurrentFixTypeNo
  If nFTIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan(nFTCIndex)
      nState = getOwnState(WEP\chkFTCDimmerChan[nFTCIndex])
      If nState = #PB_Checkbox_Checked
        \bDimmerChan = #True
      Else
        \bDimmerChan = #False
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  WEP_setCurrentFixTypeChan(nFTCIndex)
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
EndProcedure

Procedure WEP_txtFTCDefault_Validate(nFTCIndex)
  PROCNAMEC()
  Protected nFTIndex
  Protected sDefault.s, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  nFTIndex = grWEP\nCurrentFixTypeNo
  If nFTIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan(nFTCIndex)
      sDefault = Trim(GGT(WEP\txtFTCDefault[nFTCIndex]))
      If Len(sDefault) = 0
        sMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblFTCDefault))
      ElseIf DMX_valDMXValue(sDefault) = #False
        sMsg = Lang("DMX", "InvalidDMXValue")
      EndIf
      If sMsg
        ensureSplashNotOnTop()
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      \sDefault = sDefault
      \nDMXDefault = DMX_convertDMXValueStringToDMXValue(\sDefault)
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtLightingLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, i, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s
  Protected nDevNo
  Protected nListIndex
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "txtLightingLogicalDev[" + Index + "]=" + GGT(WEP\txtLightingLogicalDev(Index)))
  nDevNo = Index
  
  With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
    
    sLogicalDevNew = Trim(GGT(WEP\txtLightingLogicalDev(Index)))
    sLogicalDevOld = \sLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
        If d <> nDevNo
          If grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            SGT(WEP\txtLightingLogicalDev(Index), sLogicalDevOld) ; reinstate old name
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
      ; ensure new name is not the same as a fixture code
      For n = 0 To \nMaxFixture
        If UCase(sLogicalDevNew) = UCase(\aFixture(n)\sFixtureCode)
          ensureSplashNotOnTop()
          scsMessageRequester(grText\sTextValErr, LangPars("Errors", "FixtureDeviceConflict", sLogicalDevNew), #PB_MessageRequester_Error)
          SGT(WEP\txtLightingLogicalDev(Index), sLogicalDevOld) ; reinstate old name
          ProcedureReturn #False
        EndIf
      Next n
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeK
            If aSub(j)\sLTLogicalDev = sLogicalDevOld
              ensureSplashNotOnTop()
              ; MsgBox(LangPars("Errors", "DevNameUsedByCue", sLogicalDevOld, getSubLabel(j)), #PB_MessageRequester_Error, grText\sTextValErr)
              scsMessageRequester(grText\sTextValErr, LangPars("Errors", "DevNameUsedByCue", sLogicalDevOld, getSubLabel(j)), #PB_MessageRequester_Error)
              SGT(WEP\txtLightingLogicalDev(Index), sLogicalDevOld)
              ProcedureReturn #False
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      Next i
    EndIf
    
    ; validation passed - new code
    If nDevNo > grProdForDevChgs\nMaxLightingLogicalDev
      addOneLightingLogicalDev(@grProdForDevChgs)
    EndIf
    \sLogicalDev = sLogicalDevNew
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew + ", grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\sLogicalDev=" + \sLogicalDev)
    
    If \nDevId <= 0
      gnNextDevId + 1
      \nDevId = gnNextDevId
    EndIf
    
    If Len(sLogicalDevNew) = 0
      \nDevType = #SCS_DEVTYPE_NONE
      \sLightingDevDesc = ""
      If GGS(WEP\cboLightingDevType(Index)) <> -1
        SGS(WEP\cboLightingDevType(Index), -1)
        debugMsg(sProcName, "GGS(WEP\cboLightingDevType(" + Index + ")=" + GGS(WEP\cboLightingDevType(Index)))
        ED_fcLightingDevType(Index)
        ProcedureReturn
      EndIf
    EndIf
    
    If sLogicalDevNew
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
      If nDevMapDevPtr = -1
        debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + sLogicalDevNew + ")")
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_LIGHTING, \nDevType, \nDevId, sLogicalDevNew)
      EndIf
    EndIf
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(#SCS_DEVGRP_LIGHTING, " + decodeDevType(\nDevType) + ", " + nDevNo + ", " + sLogicalDevOld + ")")
    updateDevChgsDev(#SCS_DEVGRP_LIGHTING, \nDevType, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_LIGHTING, nDevNo)
    
    debugMsg(sProcName, "calling WEP_setCurrentLightingDevInfo(" + Index + ")")
    WEP_setCurrentLightingDevInfo(Index)
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFixtureCode_Validate(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, d, j, n, nMaxFixture, nDevMapDevPtr
  Protected sOldFixtureCode.s, sNewFixtureCode.s
  Protected nChar, sChar.s
  Protected sValidFirstChar.s = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  Protected sValidOtherChar.s = "#ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
  Protected bFixtureCodeValid = #True
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  debugMsg(sProcName, "gnWEPFixtureCurrItem=" + gnWEPFixtureCurrItem + ", gnWEPFixtureLastItem=" + gnWEPFixtureLastItem)
  nGadgetNo = gnEventGadgetNo
  debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo))
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        debugMsg(sProcName, "getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, " + nDevNo + ") returned nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxFixture = \nMaxFixture
          If Index <= \nMaxFixture
            sOldFixtureCode = \aFixture(Index)\sFixtureCode
          EndIf
          sNewFixtureCode = Trim(GGT(nGadgetNo))
          debugMsg(sProcName, "sOldFixtureCode=" + sOldFixtureCode + ", sNewFixtureCode=" + sNewFixtureCode)
          If sNewFixtureCode
            If UCase(sNewFixtureCode) <> UCase(sOldFixtureCode)
              For n = 0 To nMaxFixture
                If n <> Index
                  If UCase(\aFixture(n)\sFixtureCode) = UCase(sNewFixtureCode)
                    ensureSplashNotOnTop()
                    valErrMsg(nGadgetNo, LangPars("Errors", "FixtureDeviceConflict", sNewFixtureCode))
                    ProcedureReturn #False
                  EndIf
                EndIf
              Next n
              If UCase(Left(sNewFixtureCode, 3)) = "DBO"
                ensureSplashNotOnTop()
                valErrMsg(nGadgetNo, LangPars("Errors", "FixtureDeviceConflict", sNewFixtureCode))
                ProcedureReturn #False
              EndIf
              For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
                If UCase(sNewFixtureCode) = UCase(grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev)
                  ensureSplashNotOnTop()
                  valErrMsg(nGadgetNo, LangPars("Errors", "AlreadyExists", grText\sTextFixture + " " + Trim(sNewFixtureCode)))
                  ProcedureReturn #False
                EndIf
              Next d
            EndIf
          EndIf
          If sNewFixtureCode <> sOldFixtureCode
            ; validate content of the fixture code
            If Len(sNewFixtureCode) = 0
              ; can only blank out this name if it is not being used in cues
              For j = 1 To gnLastSub
                If aSub(j)\bExists
                  If aSub(j)\bSubTypeK
                    For n = 0 To aSub(j)\nMaxFixture
                      If aSub(j)\aLTFixture(n)\sLTFixtureCode = sOldFixtureCode
                        ensureSplashNotOnTop()
                        valErrMsg(nGadgetNo, LangPars("Errors", "CannotClearFixCode", sOldFixtureCode, aSub(j)\sCue))
                        SGT(nGadgetNo, sOldFixtureCode)
                        ProcedureReturn #False
                      EndIf
                    Next n
                  EndIf
                EndIf
              Next j
            EndIf
            For nChar = 1 To Len(sNewFixtureCode)
              sChar = Mid(sNewFixtureCode, nChar, 1)
              If nChar = 1
                If FindString(sValidFirstChar, sChar, 1, #PB_String_NoCase) = 0
                  ; unacceptable first character of a fixture code
                  bFixtureCodeValid = #False
                  Break
                EndIf
              Else
                If FindString(sValidOtherChar, sChar, 1, #PB_String_NoCase) = 0
                  ; unacceptable character in a fixture code
                  bFixtureCodeValid = #False
                  Break
                EndIf
              EndIf
            Next nChar
            If bFixtureCodeValid = #False
              ensureSplashNotOnTop()
              valErrMsg(nGadgetNo, Lang("Errors", "FixtureCodeInvalid"))
              ProcedureReturn #False
            EndIf
            debugMsg(sProcName, "Index=" + Index + ", ArraySize(\aFixture())=" + ArraySize(\aFixture()))
            If Index > ArraySize(\aFixture())
              ReDim \aFixture(Index)
            EndIf
            If Index > ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture())
              ReDim grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)
            EndIf
            If Index > \nMaxFixture
              \nMaxFixture = Index
              debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nMaxFixture=" + \nMaxFixture)
            EndIf
            If Index > grMapsForDevChgs\aDev(nDevMapDevPtr)\nMaxDevFixture
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nMaxDevFixture = Index
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nMaxDevFixture=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nMaxDevFixture)
            EndIf
            \aFixture(Index)\sFixtureCode = sNewFixtureCode
            grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\sDevFixtureCode = sNewFixtureCode
            debugMsg(sProcName, "calling WEP_createNewFixtureIfReqd()")
            WEP_createNewFixtureIfReqd()
;             debugMsg(sProcName, "calling DMX_changeFixtureCodeInLightingCues(" + sOldFixtureCode + ", " + sNewFixtureCode + ")")
;             DMX_changeFixtureCodeInLightingCues(sOldFixtureCode, sNewFixtureCode)
            debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
            WEP_setDevChgsBtns()
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtFixtureDesc_Validate(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, nMaxFixture, nDevMapDevPtr
  Protected sOldFixtureDesc.s, sNewFixtureDesc.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nGadgetNo = gnEventGadgetNo
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxFixture = \nMaxFixture
          If Index <= \nMaxFixture
            sOldFixtureDesc = \aFixture(Index)\sFixtureDesc
          EndIf
          sNewFixtureDesc = Trim(GGT(nGadgetNo))
          debugMsg(sProcName, "sOldFixtureDesc=" + sOldFixtureDesc + ", sNewFixtureDesc=" + sNewFixtureDesc)
          If sNewFixtureDesc <> sOldFixtureDesc
            If Index > ArraySize(\aFixture())
              ReDim \aFixture(Index)
            EndIf
            If Index > ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture())
              ReDim grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)
            EndIf
            If Index > \nMaxFixture
              \nMaxFixture = Index
              debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nMaxFixture=" + \nMaxFixture)
            EndIf
            If Index > ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture())
              ReDim grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)
            EndIf
            \aFixture(Index)\sFixtureDesc = sNewFixtureDesc
            WEP_createNewFixtureIfReqd()
            WEP_setDevChgsBtns()
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_cboFixtureType_Click(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, nMaxFixture, nDevMapDevPtr
  Protected nOldFixTypeId, nNewFixTypeId, n
  Protected sOldFixTypeName.s, sNewFixTypeName.s
  Protected nOldFixTypeIndex, nNewFixTypeIndex, nOldFixTypeTotalChans, nNewFixTypeTotalChans
  Protected sDMXChannels.s, sComment.s, sLightingLogicalDev.s
  Protected nErrorCode, sErrorMsg.s
  Protected i, j, sCurrFixtureCode.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nGadgetNo = gnEventGadgetNo
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        sLightingLogicalDev = \sLogicalDev ; Added 7Oct2021 11.8.6ax
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxFixture = \nMaxFixture
          If Index <= \nMaxFixture
            sOldFixTypeName = \aFixture(Index)\sFixTypeName
            nOldFixTypeId = DMX_getFixTypeId(@grProdForDevChgs, sOldFixTypeName)
            nOldFixTypeIndex = DMX_getFixTypeIndex(@grProdForDevChgs, sOldFixTypeName)
            If nOldFixTypeIndex >= 0
              nOldFixTypeTotalChans = grProdForDevChgs\aFixTypes(nOldFixTypeIndex)\nTotalChans
            EndIf
          EndIf
          nNewFixTypeId = getCurrentItemData(nGadgetNo)
          For n = 0 To grProdForDevChgs\nMaxFixType
            If grProdForDevChgs\aFixTypes(n)\nFixTypeId = nNewFixTypeId
              sNewFixTypeName = grProdForDevChgs\aFixTypes(n)\sFixTypeName
              nNewFixTypeIndex = n
              If nNewFixTypeIndex >= 0
                nNewFixTypeTotalChans = grProdForDevChgs\aFixTypes(nNewFixTypeIndex)\nTotalChans
              EndIf
              Break
            EndIf
          Next n
          debugMsg(sProcName, "sOldFixTypeName=" + sOldFixTypeName + ", sNewFixTypeName=" + sNewFixTypeName + ", nOldFixTypeId=" + nOldFixTypeId + ", nNewFixTypeId=" + nNewFixTypeId +
                              ", nOldFixTypeTotalChans=" + nOldFixTypeTotalChans + ", nNewFixTypeTotalChans=" + nNewFixTypeTotalChans)
          If sNewFixTypeName <> sOldFixTypeName And nNewFixTypeTotalChans <> nOldFixTypeTotalChans
            If sOldFixTypeName And nOldFixTypeId >= 0
              sCurrFixtureCode = \aFixture(Index)\sFixtureCode
              For i = 1 To gnLastCue
                If aCue(i)\bSubTypeK
                  j = aCue(i)\nFirstSubIndex
                  While j >= 0
                    If aSub(j)\bSubTypeK
                      If aSub(j)\sLTLogicalDev = sLightingLogicalDev ; Test added 7Oct2021 11.8.6ax
                        For n = 0 To aSub(j)\nMaxFixture
                          If aSub(j)\aLTFixture(n)\sLTFixtureCode = sCurrFixtureCode
                            sErrorMsg = LangPars("Errors", "CannotChangeFixType", sCurrFixtureCode, getSubLabel(j))
                            ensureSplashNotOnTop()
                            valErrMsg(nGadgetNo, sErrorMsg)
                            setComboBoxByData(nGadgetNo, nOldFixTypeId)
                            ProcedureReturn #False
                          EndIf
                        Next n
                      EndIf
                    EndIf ; EndIf aSub(j)\bSubTypeK
                    j = aSub(j)\nNextSubIndex
                  Wend
                EndIf ; EndIf aCue(i)\bSubTypeK
              Next i
            EndIf ; EndIf sOldFixTypeName
          EndIf
          If sNewFixTypeName <> sOldFixTypeName
            If Index > ArraySize(\aFixture())
              ReDim \aFixture(Index)
            EndIf
            If Index > ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture())
              ReDim grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)
            EndIf
            If Index > \nMaxFixture
              \nMaxFixture = Index
              debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nMaxFixture=" + \nMaxFixture)
            EndIf
            \aFixture(Index)\sFixTypeName = sNewFixTypeName
            debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\aFixture(" + Index + ")\sFixTypeName=" + \aFixture(Index)\sFixTypeName)
            WEP_createNewFixtureIfReqd()
            WEP_setDevChgsBtns()
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDimmableChannels_Validate(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, nMaxFixture, nDevMapDevPtr
  Protected sOldDimmableChannels.s, sNewDimmableChannels.s
  Protected sDMXChannels.s, sComment.s
  Protected nErrorCode, sErrorMsg.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nGadgetNo = gnEventGadgetNo
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxFixture = \nMaxFixture
          If Index <= \nMaxFixture
            sOldDimmableChannels = \aFixture(Index)\sDimmableChannels
          EndIf
          sNewDimmableChannels = Trim(GGT(nGadgetNo))
          debugMsg(sProcName, "sOldDimmableChannels=" + sOldDimmableChannels + ", sNewDimmableChannels=" + sNewDimmableChannels)
          If sNewDimmableChannels <> sOldDimmableChannels
            sComment = RTrim(StringField(sNewDimmableChannels, 2, "//"))
            sDMXChannels = RemoveString(StringField(sNewDimmableChannels, 1, "//"), " ")  ; removes ALL spaces, not just those at the beginning and end
            debugMsg(sProcName, "sDMXChannels=" + sDMXChannels + ", sComment=" + sComment)
            If sDMXChannels
              nErrorCode = DMX_valDMXChannels(sDMXChannels)
              debugMsg2(sProcName, "DMX_valDMXChannels(" + #DQUOTE$ + sDMXChannels + #DQUOTE$ + ")", nErrorCode)
              If nErrorCode <> 0
                If nErrorCode = 405
                  ; Changed 15Mar2022 11.9.1an
                  ; sErrorMsg = LangPars("Errors", "DMXChannelLimit", Str(grLicInfo\nMaxDMXChannel))
                  DMX_ChannelLimitWarning()
                  sErrorMsg = ""
                  ; End changed 15Mar2022 11.9.1an
                Else
                  sErrorMsg = Lang("Errors", "DMXChannelsInvalid")
                EndIf
                If sErrorMsg ; Test added 15Mar2022 11.9.1an
                  debugMsg(sProcName, "sErrorMgs=" + sErrorMsg)
                  scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
                  ProcedureReturn #False
                EndIf
              EndIf
            EndIf
            If Index > ArraySize(\aFixture())
              ReDim \aFixture(Index)
            EndIf
            If Index > ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture())
              ReDim grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)
            EndIf
            If Index > \nMaxFixture
              \nMaxFixture = Index
              debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nMaxFixture=" + \nMaxFixture)
            EndIf
            \aFixture(Index)\sDimmableChannels = sNewDimmableChannels
            WEP_setDimmableChannelsTooltip(nGadgetNo)
            WEP_createNewFixtureIfReqd()
            WEP_setDevChgsBtns()
          EndIf
        EndIf
      EndWith
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_setDimmableChannelsTooltip(nGadgetNo)
  PROCNAMEC()
  Protected sTooltip.s
  Protected sText.s, nTextLength
  Static sDefaultTooltip.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sDefaultTooltip = Lang("WEP", "txtDimmableChannelsTT")
    bStaticLoaded = #True
  EndIf
  
  With WEP
    sTooltip = sDefaultTooltip
    sText = RTrim(GGT(nGadgetNo))
    If Len(sText) > 50  ; nb do not check text length if there's no way it would be greater than the field length
      nTextLength = GetTextWidthForGadget(sText, nGadgetNo)
      If nTextLength > (GadgetWidth(nGadgetNo) - gl3DBorderAllowanceX)
        sTooltip = sText
      EndIf
    EndIf
    scsToolTip(nGadgetNo, sTooltip)
  EndWith
  
EndProcedure

Procedure WEP_setDMXStartChannelsTooltip(nGadgetNo)
  ; PROCNAMEC()
  Protected sTooltip.s, sText.s, nTextLength
  Static sDefaultTooltip.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sDefaultTooltip = Lang("WEP", "txtDMXStartChannelsTT")
    bStaticLoaded = #True
  EndIf
  
  With WEP
    sTooltip = sDefaultTooltip
    sText = Trim(GGT(nGadgetNo))
    ; debugMsg0(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo,#False) + ", sText=" + sText + ", Len(sText)=" + Len(sText))
    nTextLength = GetTextWidthForGadget(sText, nGadgetNo)
    If nTextLength > (GadgetWidth(nGadgetNo) - gl3DBorderAllowanceX)
      sTooltip = sText
    EndIf
    scsToolTip(nGadgetNo, sTooltip)
  EndWith
  
EndProcedure

Procedure WEP_txtDMXStartChannel_Validate(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, nDevMapDevPtr
  Protected nDMXStartChannel, sDMXStartChannels.s, nErrorCode, nChannelCount, sErrorMsg.s
  Protected sFixtureType.s, sFixtureCode.s, nTotalChans, nMaxDMXChannel
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nGadgetNo = gnEventGadgetNo
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    ; debugMsg(sProcName, "nDevNo=" + nDevNo)
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxDMXChannel = 512
          sFixtureCode = \aFixture(Index)\sFixtureCode
          sFixtureType = getFixtureTypeForLightingDeviceFixtureCode(@grProdForDevChgs, \sLogicalDev, sFixtureCode)
          If sFixtureType
            nTotalChans = getTotalChansForFixtureType(@grProdForDevChgs, sFixtureType)
            If nTotalChans > 0
              nMaxDMXChannel = 513 - nTotalChans
            EndIf
          EndIf
          sDMXStartChannels = Trim(GGT(nGadgetNo))
          If sDMXStartChannels
            nErrorCode = DMX_valDMXStartChannels(sDMXStartChannels, sFixtureCode, nTotalChans, @nChannelCount)
            debugMsg(sProcName, "DMX_valDMXStartChannels(" + #DQUOTE$ + sDMXStartChannels + #DQUOTE$ +
                                ", " + #DQUOTE$ + sFixtureCode + #DQUOTE$ + ", " + nTotalChans + ", @nChannelCount) returned nErrorCode=" + nErrorCode + ", nChannelCount=" + nChannelCount)
            If nErrorCode <> 0
              Select nErrorCode
                Case 405
                  ; Changed 15Mar2022 11.9.1an
                  ; sErrorMsg = LangPars("Errors", "DMXChannelLimit", Str(grLicInfo\nMaxDMXChannel))
                  DMX_ChannelLimitWarning()
                  sErrorMsg = ""
                  ; End changed 15Mar2022 11.9.1an
                Case 406, 407
                  sErrorMsg = grDMX\sChannelErrorMsg
                Default
                  sErrorMsg = Lang("Errors", "DMXChannelsInvalid")
              EndSelect
              If sErrorMsg
                debugMsg(sProcName, "sErrorMgs=" + sErrorMsg)
                scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
                ProcedureReturn #False
              EndIf
            EndIf
            If nChannelCount = 1
              nDMXStartChannel = Val(sDMXStartChannels)
              sDMXStartChannels = ""
            EndIf
            If nDMXStartChannel <> grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel
              grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel = nDMXStartChannel
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + Index + ")\nDevDMXStartChannel=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel)
              grCED\bProdChanged = #True
            EndIf
            If sDMXStartChannels <> grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\sDevDMXStartChannels
              grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\sDevDMXStartChannels = sDMXStartChannels
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + Index + ")\sDevDMXStartChannels=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\sDevDMXStartChannels)
              grCED\bProdChanged = #True
            EndIf
          EndIf
          WEP_setDMXStartChannelsTooltip(nGadgetNo)
        EndIf
      EndWith
      WEP_setDevChgsBtns()
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtDMXStartChannel_Validate_OLD(Index)
  PROCNAMEC()
  Protected nGadgetNo, nDevNo, nDevMapDevPtr
  Protected nTmp, sTmp.s
  Protected sFixtureType.s, nTotalChans, nMaxDMXChannel
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nGadgetNo = gnEventGadgetNo
  If IsGadget(nGadgetNo)
    nDevNo = grWEP\nCurrentLightingDevNo
    ; debugMsg(sProcName, "nDevNo=" + nDevNo)
    If nDevNo >= 0
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0 ; nb should always be true
          nMaxDMXChannel = 512
          sFixtureType = getFixtureTypeForLightingDeviceFixtureCode(@grProdForDevChgs, \sLogicalDev, \aFixture(Index)\sFixtureCode)
          If sFixtureType
            nTotalChans = getTotalChansForFixtureType(@grProdForDevChgs, sFixtureType)
            If nTotalChans > 0
              nMaxDMXChannel = 513 - nTotalChans
            EndIf
          EndIf
          sTmp = Trim(GGT(nGadgetNo))
          If sTmp
            nTmp = Val(sTmp)
          Else
            nTmp = -2
          EndIf
          debugMsg(sProcName, "nTmp=" + nTmp)
          If (nTmp <> -2) And (nTmp < 1 Or nTmp > nMaxDMXChannel)
            scsMessageRequester(grText\sTextValErr, LangPars("Errors", "DMXChannelForFix", GGT(WEP\lblDMXStartChannel), Str(nMaxDMXChannel), sFixtureType, Str(nTotalChans)), #PB_MessageRequester_Error)
            ProcedureReturn #False
          Else
            If nTmp <> grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel
              grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel = nTmp
              debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + Index + ")\nDevDMXStartChannel=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(Index)\nDevDMXStartChannel)
              grCED\bProdChanged = #True
            EndIf
          EndIf
        EndIf
      EndWith
      WEP_setDevChgsBtns()
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_txtCtrlLogicalDev_Validate(Index)
  PROCNAMEC()
  Protected d, i, j, n
  Protected sLogicalDevNew.s, sLogicalDevOld.s
  Protected nDevNo
  Protected nListIndex
  Protected nDevCount, nMaxDevPtr
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "txtCtrlLogicalDev(" + Index + ")=" + GGT(WEP\txtCtrlLogicalDev(Index)))
  nDevNo = Index
  
  With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
    
    sLogicalDevNew = Trim(GGT(WEP\txtCtrlLogicalDev(Index)))
    sLogicalDevOld = \sLogicalDev
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew)
    If sLogicalDevNew = sLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn #True
    EndIf
    
    If sLogicalDevNew
      ; ensure name is unique
      For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
        If d <> nDevNo
          If grProdForDevChgs\aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDevNew
            ensureSplashNotOnTop()
            scsMessageRequester(grText\sTextValErr, LangPars("DevMap", "DevNameAlreadyUsed", sLogicalDevNew), #PB_MessageRequester_Error)
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
    EndIf
    
    If Len(sLogicalDevNew) = 0
      ; can only blank out this name if it is not being used in cues
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeM
            For n = 0 To #SCS_MAX_CTRL_SEND
              If aSub(j)\aCtrlSend[n]\sCSLogicalDev = sLogicalDevOld
                ensureSplashNotOnTop()
                ; MsgBox(LangPars("Errors", "DevNameUsedByCue", sLogicalDevOld, getSubLabel(j)), #PB_MessageRequester_Error, grText\sTextValErr)
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "DevNameUsedByCue", sLogicalDevOld, getSubLabel(j)), #PB_MessageRequester_Error)
                SGT(WEP\txtCtrlLogicalDev(Index), sLogicalDevOld)
                ProcedureReturn #False
              EndIf
            Next n
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      Next i
    EndIf
    
    ; validation passed - new code
    If nDevNo > grProdForDevChgs\nMaxCtrlSendLogicalDev
      addOneCtrlSendLogicalDev(@grProdForDevChgs)
    EndIf
    \sLogicalDev = sLogicalDevNew
    debugMsg(sProcName, "sLogicalDevOld=" + sLogicalDevOld + ", sLogicalDevNew=" + sLogicalDevNew + ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\sLogicalDev=" + \sLogicalDev)
    
    If \nDevId <= 0
      gnNextDevId + 1
      \nDevId = gnNextDevId
    EndIf
    
    If Len(sLogicalDevNew) = 0
      \nDevType = #SCS_DEVTYPE_NONE
      \sCtrlSendDevDesc = ""
    EndIf
    
    If sLogicalDevNew
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_CTRL_SEND, nDevNo)
      If nDevMapDevPtr = -1
        debugMsg(sProcName, "calling addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, " + decodeDevType(\nDevType) + ", " + \nDevId + ", " + sLogicalDevNew + ")")
        nDevMapDevPtr = addDevToDevChgsDevMap(#SCS_DEVGRP_CTRL_SEND, \nDevType, \nDevId, sLogicalDevNew)
      EndIf
    EndIf
    
    ; change name where used in device maps
    debugMsg(sProcName, "calling updateDevChgsDev(#SCS_DEVGRP_CTRL_SEND, " + decodeDevType(\nDevType) + ", " + nDevNo + ", " + sLogicalDevOld + ")")
    updateDevChgsDev(#SCS_DEVGRP_CTRL_SEND, \nDevType, nDevNo, sLogicalDevOld)
    
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
    
    debugMsg(sProcName, "calling setEditLogicalDevsDerivedFields")
    setEditLogicalDevsDerivedFields()
    
    debugMsg(sProcName, "calling updateProdDev(" + nDevNo + ")")
    WEP_updateProdDev(#SCS_DEVGRP_CTRL_SEND, nDevNo)
    
    debugMsg(sProcName, "calling WEP_setCurrentCtrlDevInfo(" + Index + ")")
    WEP_setCurrentCtrlDevInfo(Index)
    
    WEP_setTBSButtons(Index)
    WEP_setDevChgsBtns()
    WEP_setRetryActivateBtn()
    WEP_setDevMapButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure WEP_swapDevices(nDevGrp, nOrigDevPtr, nOtherDevPtr)
  PROCNAMEC()
  Protected rHoldAudioLogicalDev.tyAudioLogicalDevs
  Protected rHoldVidAudLogicalDev.tyVidAudLogicalDevs
  Protected rHoldVidCapLogicalDev.tyVidCapLogicalDevs
  Protected rHoldLiveInputLogicalDev.tyLiveInputLogicalDevs
  Protected rHoldInGrp.tyInGrp
  Protected rHoldFixType.tyFixType
  Protected rHoldLightingLogicalDev.tyLightingLogicalDevs
  Protected rHoldCtrlSendLogicalDev.tyCtrlSendLogicalDevs
  Protected rHoldCueCtrlLogicalDev.tyCueCtrlLogicalDevs
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nOrigDevPtr=" + nOrigDevPtr + ", nOtherDevPtr=" + nOtherDevPtr)
  
  With grProdForDevChgs
    ; swap devices in grProdForDevChgs
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        rHoldAudioLogicalDev = \aAudioLogicalDevs(nOrigDevPtr)
        \aAudioLogicalDevs(nOrigDevPtr) = \aAudioLogicalDevs(nOtherDevPtr)
        \aAudioLogicalDevs(nOtherDevPtr) = rHoldAudioLogicalDev
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        rHoldVidAudLogicalDev = \aVidAudLogicalDevs(nOrigDevPtr)
        \aVidAudLogicalDevs(nOrigDevPtr) = \aVidAudLogicalDevs(nOtherDevPtr)
        \aVidAudLogicalDevs(nOtherDevPtr) = rHoldVidAudLogicalDev
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        rHoldVidCapLogicalDev = \aVidCapLogicalDevs(nOrigDevPtr)
        \aVidCapLogicalDevs(nOrigDevPtr) = \aVidCapLogicalDevs(nOtherDevPtr)
        \aVidCapLogicalDevs(nOtherDevPtr) = rHoldVidCapLogicalDev
        
      Case #SCS_DEVGRP_LIVE_INPUT
        rHoldLiveInputLogicalDev = \aLiveInputLogicalDevs(nOrigDevPtr)
        \aLiveInputLogicalDevs(nOrigDevPtr) = \aLiveInputLogicalDevs(nOtherDevPtr)
        \aLiveInputLogicalDevs(nOtherDevPtr) = rHoldLiveInputLogicalDev
        
      Case #SCS_DEVGRP_IN_GRP
        rHoldInGrp = \aInGrps(nOrigDevPtr)
        \aInGrps(nOrigDevPtr) = \aInGrps(nOtherDevPtr)
        \aInGrps(nOtherDevPtr) = rHoldInGrp
        
      Case #SCS_DEVGRP_FIX_TYPE
        rHoldFixType = \aFixTypes(nOrigDevPtr)
        \aFixTypes(nOrigDevPtr) = \aFixTypes(nOtherDevPtr)
        \aFixTypes(nOtherDevPtr) = rHoldFixType
        
      Case #SCS_DEVGRP_LIGHTING
        rHoldLightingLogicalDev = \aLightingLogicalDevs(nOrigDevPtr)
        \aLightingLogicalDevs(nOrigDevPtr) = \aLightingLogicalDevs(nOtherDevPtr)
        \aLightingLogicalDevs(nOtherDevPtr) = rHoldLightingLogicalDev
        
      Case #SCS_DEVGRP_CTRL_SEND
        rHoldCtrlSendLogicalDev = \aCtrlSendLogicalDevs(nOrigDevPtr)
        \aCtrlSendLogicalDevs(nOrigDevPtr) = \aCtrlSendLogicalDevs(nOtherDevPtr)
        \aCtrlSendLogicalDevs(nOtherDevPtr) = rHoldCtrlSendLogicalDev
        
      Case #SCS_DEVGRP_CUE_CTRL
        rHoldCueCtrlLogicalDev = \aCueCtrlLogicalDevs(nOrigDevPtr)
        \aCueCtrlLogicalDevs(nOrigDevPtr) = \aCueCtrlLogicalDevs(nOtherDevPtr)
        \aCueCtrlLogicalDevs(nOtherDevPtr) = rHoldCueCtrlLogicalDev
        
    EndSelect
  EndWith
  
  ; reset pointers in device maps
  resetDevMapForDevChgsDevPtrs()
  
EndProcedure

Procedure WEP_swapFixtures(nDevPtr, nOrigFixtureIndex, nOtherFixtureIndex)
  PROCNAMEC()
  Protected rHoldFixture.tyFixtureLogical
  
  debugMsg(sProcName, #SCS_START + ", nDevPtr=" + nDevPtr + ", nOrigFixtureIndex=" + nOrigFixtureIndex + ", nOtherFixtureIndex=" + nOtherFixtureIndex)
  
  With grProdForDevChgs
    ; swap fixtures in grProdForDevChgs
    rHoldFixture = \aLightingLogicalDevs(nDevPtr)\aFixture(nOrigFixtureIndex)
    \aLightingLogicalDevs(nDevPtr)\aFixture(nOrigFixtureIndex) = \aLightingLogicalDevs(nDevPtr)\aFixture(nOtherFixtureIndex)
    \aLightingLogicalDevs(nDevPtr)\aFixture(nOtherFixtureIndex) = rHoldFixture
  EndWith
  
  debugMsg(sProcName, "calling syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)")
  syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)
  
  WEP_displayFixtures(nDevPtr, nOrigFixtureIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_insertDevice(nDevGrp, nDevPtr)
  PROCNAMEC()
  Protected n, nOldArraySize
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevPtr=" + nDevPtr)
  
  With grProdForDevChgs
    gnNextDevId + 1
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        addOneAudioLogicalDev(@grProdForDevChgs)
        For n = \nMaxAudioLogicalDev To (nDevPtr+1) Step -1
          \aAudioLogicalDevs(n) = \aAudioLogicalDevs(n-1)
        Next n
        \aAudioLogicalDevs(nDevPtr) = grAudioLogicalDevsDef
        \aAudioLogicalDevs(nDevPtr)\sLogicalDev = ""
        \aAudioLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        addOneVidAudLogicalDev(@grProdForDevChgs)
        For n = \nMaxVidAudLogicalDev To (nDevPtr+1) Step -1
          \aVidAudLogicalDevs(n) = \aVidAudLogicalDevs(n-1)
        Next n
        \aVidAudLogicalDevs(nDevPtr) = grVidAudLogicalDevsDef
        \aVidAudLogicalDevs(nDevPtr)\sVidAudLogicalDev = ""
        \aVidAudLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        addOneVidCapLogicalDev(@grProdForDevChgs)
        For n = \nMaxVidCapLogicalDev To (nDevPtr+1) Step -1
          \aVidCapLogicalDevs(n) = \aVidCapLogicalDevs(n-1)
        Next n
        \aVidCapLogicalDevs(nDevPtr) = grVidCapLogicalDevsDef
        \aVidCapLogicalDevs(nDevPtr)\sLogicalDev = ""
        \aVidCapLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_FIX_TYPE
        addOneFixType(@grProdForDevChgs)
        For n = \nMaxFixType To (nDevPtr+1) Step -1
          \aFixTypes(n) = \aFixTypes(n-1)
        Next n
        \aFixTypes(nDevPtr) = grFixTypesDef
        \aFixTypes(nDevPtr)\sFixTypeName = ""
        \aFixTypes(nDevPtr)\nFixTypeId = gnNextDevId
        
      Case #SCS_DEVGRP_LIGHTING
        addOneLightingLogicalDev(@grProdForDevChgs)
        For n = grProdForDevChgs\nMaxLightingLogicalDev To (nDevPtr+1) Step -1
          grProdForDevChgs\aLightingLogicalDevs(n) = grProdForDevChgs\aLightingLogicalDevs(n-1)
        Next n
        grProdForDevChgs\aLightingLogicalDevs(nDevPtr) = grLightingLogicalDevsDef
        grProdForDevChgs\aLightingLogicalDevs(nDevPtr)\sLogicalDev = ""
        grProdForDevChgs\aLightingLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_CTRL_SEND
        addOneCtrlSendLogicalDev(@grProdForDevChgs)
        For n = \nMaxCtrlSendLogicalDev To (nDevPtr+1) Step -1
          \aCtrlSendLogicalDevs(n) = \aCtrlSendLogicalDevs(n-1)
        Next n
        \aCtrlSendLogicalDevs(nDevPtr) = grCtrlSendLogicalDevsDef
        \aCtrlSendLogicalDevs(nDevPtr)\sLogicalDev = ""
        \aCtrlSendLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_CUE_CTRL
        addOneCueCtrlLogicalDev(@grProdForDevChgs)
        For n = \nMaxCueCtrlLogicalDev To (nDevPtr+1) Step -1
          \aCueCtrlLogicalDevs(n) = \aCueCtrlLogicalDevs(n-1)
        Next n
        \aCueCtrlLogicalDevs(nDevPtr) = grCueCtrlLogicalDevsDef
        \aCueCtrlLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        \aCueCtrlLogicalDevs(nDevPtr)\sCueCtrlLogicalDev = "C" + Str(nDevPtr + 1)
        ED_renumberCueCtrlLogicalDevs(@grProdForDevChgs)
        
      Case #SCS_DEVGRP_LIVE_INPUT
        addOneLiveInputLogicalDev(@grProdForDevChgs)
        For n = \nMaxLiveInputLogicalDev To (nDevPtr+1) Step -1
          \aLiveInputLogicalDevs(n) = \aLiveInputLogicalDevs(n-1)
        Next n
        \aLiveInputLogicalDevs(nDevPtr) = grLiveInputLogicalDevsDef
        \aLiveInputLogicalDevs(nDevPtr)\sLogicalDev = ""
        \aLiveInputLogicalDevs(nDevPtr)\nDevId = gnNextDevId
        
      Case #SCS_DEVGRP_IN_GRP
        addOneInGrp(@grProdForDevChgs)
        For n = \nMaxInGrp To (nDevPtr+1) Step -1
          \aInGrps(n) = \aInGrps(n-1)
        Next n
        \aInGrps(nDevPtr) = grInGrpsDef
        \aInGrps(nDevPtr)\sInGrpName = ""
        \aInGrps(nDevPtr)\nInGrpId = gnNextDevId
        
    EndSelect
    ED_setDevGrpScaInnerHeight(nDevGrp)
  EndWith
  
  ; reset pointers in device maps
  resetDevMapForDevChgsDevPtrs()
  
EndProcedure

Procedure WEP_insertLightingDevFixture(nDevPtr, nFixtureIndex)
  PROCNAMEC()
  Protected n, nMaxFixture
  
  debugMsg(sProcName, #SCS_START + ", nDevPtr=" + nDevPtr + ", nFixtureIndex=" + nFixtureIndex)
  
  With grProdForDevChgs\aLightingLogicalDevs(nDevPtr)
    nMaxFixture = \nMaxFixture + 1
    If ArraySize(\aFixture()) < nMaxFixture
      ReDim \aFixture(nMaxFixture)
    EndIf
    For n = nMaxFixture To (nFixtureIndex+1) Step -1
      \aFixture(n) = \aFixture(n-1)
    Next n
    \aFixture(nFixtureIndex) = grFixtureLogicalDef
    \nMaxFixture = nMaxFixture
  EndWith
  
  debugMsg(sProcName, "calling syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)")
  syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)
  
  WEP_displayFixtures(nDevPtr, nFixtureIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_removeDevice(nDevGrp, nDevPtr)
  PROCNAMEC()
  Protected n, nOrigCountAutoInclude, nNewCountAutoInclude
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nDevPtr=" + nDevPtr)
  
  With grProdForDevChgs
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        ;{
        For n = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(n)\bAutoInclude
            nOrigCountAutoInclude + 1
          EndIf
        Next n
        
        For n = nDevPtr To (\nMaxAudioLogicalDev-1)
          \aAudioLogicalDevs(n) = \aAudioLogicalDevs(n+1)
        Next n
        \aAudioLogicalDevs(\nMaxAudioLogicalDev) = grAudioLogicalDevsDef
        \nMaxAudioLogicalDev - 1
        
        For n = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(n)\bAutoInclude
            nNewCountAutoInclude + 1
          EndIf
        Next n
        ; if there are no auto-include audio devices left, but there was one before we removed this device, then set the first device as auto-include
        If nNewCountAutoInclude = 0 And nOrigCountAutoInclude > 0
          \aAudioLogicalDevs(0)\bAutoInclude = #True
        EndIf
        ;}
      Case #SCS_DEVGRP_VIDEO_AUDIO
        ;{
        For n = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(n)\bAutoInclude
            nOrigCountAutoInclude + 1
          EndIf
        Next n
        
        For n = nDevPtr To (\nMaxVidAudLogicalDev-1)
          \aVidAudLogicalDevs(n) = \aVidAudLogicalDevs(n+1)
        Next n
        \aVidAudLogicalDevs(\nMaxVidAudLogicalDev) = grVidAudLogicalDevsDef
        \nMaxVidAudLogicalDev - 1
        
        For n = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(n)\bAutoInclude
            nNewCountAutoInclude + 1
          EndIf
        Next n
        ; if there are no auto-include audio devices left, but there was one before we removed this device, then set the first device as auto-include
        If nNewCountAutoInclude = 0 And nOrigCountAutoInclude > 0
          \aVidAudLogicalDevs(0)\bAutoInclude = #True
        EndIf
        ;}
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        ;{
        For n = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(n)\bAutoInclude
            nOrigCountAutoInclude + 1
          EndIf
        Next n
        
        For n = nDevPtr To (\nMaxVidCapLogicalDev-1)
          \aVidCapLogicalDevs(n) = \aVidCapLogicalDevs(n+1)
        Next n
        \aVidCapLogicalDevs(\nMaxVidCapLogicalDev) = grVidCapLogicalDevsDef
        \nMaxVidCapLogicalDev - 1
        
        For n = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(n)\bAutoInclude
            nNewCountAutoInclude + 1
          EndIf
        Next n
        ; if there are no auto-include audio devices left, but there was one before we removed this device, then set the first device as auto-include
        If nNewCountAutoInclude = 0 And nOrigCountAutoInclude > 0
          \aVidCapLogicalDevs(0)\bAutoInclude = #True
        EndIf
        ;}
      Case #SCS_DEVGRP_FIX_TYPE
        ;{
        For n = nDevPtr To (\nMaxFixType-1)
          \aFixTypes(n) = \aFixTypes(n+1)
        Next n
        \aFixTypes(\nMaxFixType) = grFixTypesDef
        \nMaxFixType - 1
        ;}
      Case #SCS_DEVGRP_LIGHTING
        ;{
        For n = nDevPtr To (\nMaxLightingLogicalDev-1)
          \aLightingLogicalDevs(n) = \aLightingLogicalDevs(n+1)
        Next n
        \aLightingLogicalDevs(\nMaxLightingLogicalDev) = grLightingLogicalDevsDef
        \nMaxLightingLogicalDev - 1
        ;}
      Case #SCS_DEVGRP_CTRL_SEND
        ;{
        For n = nDevPtr To (\nMaxCtrlSendLogicalDev-1)
          \aCtrlSendLogicalDevs(n) = \aCtrlSendLogicalDevs(n+1)
        Next n
        \aCtrlSendLogicalDevs(\nMaxCtrlSendLogicalDev) = grCtrlSendLogicalDevsDef
        \nMaxCtrlSendLogicalDev - 1
        ;}
      Case #SCS_DEVGRP_CUE_CTRL
        ;{
        ED_renumberCueCtrlLogicalDevs(@grProdForDevChgs)
        ;}
      Case #SCS_DEVGRP_LIVE_INPUT
        ;{
        For n = nDevPtr To (\nMaxLiveInputLogicalDev-1)
          \aLiveInputLogicalDevs(n) = \aLiveInputLogicalDevs(n+1)
        Next n
        \aLiveInputLogicalDevs(\nMaxLiveInputLogicalDev) = grLiveInputLogicalDevsDef
        \nMaxLiveInputLogicalDev - 1
        ;}
      Case #SCS_DEVGRP_IN_GRP
        ;{
        For n = nDevPtr To (\nMaxInGrp-1)
          \aInGrps(n) = \aInGrps(n+1)
        Next n
        \aInGrps(\nMaxInGrp) = grInGrpsDef
        \nMaxInGrp - 1
        ;}
    EndSelect
  EndWith

  ED_setDevDisplayMaximums(@grProdForDevChgs)
  ED_setDevGrpScaInnerHeight(nDevGrp) ; must call ED_setDevDisplayMaximums() BEFORE calling ED_setDevGrpScaInnerHeight()
  
  ; reset pointers in device maps
  If nDevGrp = #SCS_DEVGRP_CUE_CTRL
    debugMsg(sProcName, "calling WEP_displayCueDev()")
    WEP_displayCueDev()
  Else
    debugMsg(sProcName, "calling resetDevMapForDevChgsDevPtrs()")
    resetDevMapForDevChgsDevPtrs()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_removeLightingDevFixture(nDevPtr, nFixtureIndex)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nDevPtr=" + nDevPtr + ", nFixtureIndex=" + nFixtureIndex)
  
  With grProdForDevChgs\aLightingLogicalDevs(nDevPtr)
    For n = nFixtureIndex To (\nMaxFixture-1)
      \aFixture(n) = \aFixture(n+1)
    Next n
    \nMaxFixture - 1
  EndWith
  
  debugMsg(sProcName, "calling syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)")
  syncFixturesInDev(@grProdForDevChgs, @grMapsForDevChgs)
  
  WEP_displayFixtures(nDevPtr, nFixtureIndex)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_imgFixtureButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected i, j, c, m, n
  Protected nDevNo
  Protected nFixtureIndex, nNewFixtureIndex, nMaxFixtureIndex
  Protected sLogicalDev.s, sFixtureCode.s
  Protected sDMXItemStr.s, sFixtureString.s
  Protected nWordCount, nWordNo, sWord.s
  
  debugMsg(sProcName, #SCS_START + ", nButtonId=" + nButtonId + ", gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo))
  
  nDevNo = grWEP\nCurrentLightingDevNo
  nFixtureIndex = gnWEPFixtureCurrItem
  nMaxFixtureIndex = gnWEPFixtureLastItem

  If nFixtureIndex < 0 Or nFixtureIndex > nMaxFixtureIndex
    ; shouldn't happen!
    debugMsg(sProcName, "exiting because nFixtureIndex=" + nFixtureIndex)
    ProcedureReturn
  EndIf
  
  nNewFixtureIndex = -1
  
  Select nButtonId
      
    Case #SCS_STANDARD_BTN_MOVE_UP  ; #SCS_STANDARD_BTN_MOVE_UP
      WEP_swapFixtures(nDevNo, nFixtureIndex, nFixtureIndex-1)
      nNewFixtureIndex = nFixtureIndex - 1
      
    Case #SCS_STANDARD_BTN_MOVE_DOWN  ; #SCS_STANDARD_BTN_MOVE_DOWN
      WEP_swapFixtures(nDevNo, nFixtureIndex, nFixtureIndex+1)
      nNewFixtureIndex = nFixtureIndex + 1
      
    Case #SCS_STANDARD_BTN_PLUS   ; #SCS_STANDARD_BTN_PLUS
      ; move this and following fixtures down one position
      WEP_insertLightingDevFixture(nDevNo, nFixtureIndex)
      nNewFixtureIndex = nFixtureIndex
      
    Case #SCS_STANDARD_BTN_MINUS  ; #SCS_STANDARD_BTN_MINUS
      ; can only delete this fixture if it is not being used in cues
      sLogicalDev = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\sLogicalDev
      sFixtureCode = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
      If (sLogicalDev) And (sFixtureCode)
        For i = 1 To gnLastCue
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            With aSub(j)
              If \bSubTypeK
                If \sLTLogicalDev = sLogicalDev
                  For n = 0 To \nMaxFixture
                    If UCase(\aLTFixture(n)\sLTFixtureCode) = UCase(sFixtureCode)
                      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveFixture", sFixtureCode, aSub(j)\sCue), #PB_MessageRequester_Error)
                      ProcedureReturn
                    EndIf
                    Next n
                EndIf ; EndIf \sLTLogicalDev = sLogicalDev
              EndIf ; EndIf \bSubTypeK
            EndWith
            j = aSub(j)\nNextSubIndex
          Wend
        Next i
      EndIf ; EndIf (sLogicalDev) And (sFixtureCode)
      grWEP\bDeletingFixture = #True    ; to prevent a validation error being displayed for a fixture being deleted
      WEP_removeLightingDevFixture(nDevNo, nFixtureIndex)
      nNewFixtureIndex = nFixtureIndex
      If nNewFixtureIndex < grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nMaxFixture
        nNewFixtureIndex - 1
      EndIf
      
  EndSelect
  
  If (nNewFixtureIndex >= 0) And (nNewFixtureIndex <= ArraySize(WEPFixture()))
    If IsGadget(WEPFixture(nNewFixtureIndex)\txtFixtureCode)
      debugMsg(sProcName, "calling WEP_setCurrentFixture(" + nNewFixtureIndex + ")")
      If WEP_setCurrentFixture(nNewFixtureIndex)
        debugMsg(sProcName, "calling SAG(WEPFixture(" + nNewFixtureIndex + ")\txtFixtureCode)")
        SAG(WEPFixture(nNewFixtureIndex)\txtFixtureCode)
      EndIf
    EndIf
  EndIf
  
  WEP_setDevChgsBtns()
  WEP_setRetryActivateBtn()
  
  grWEP\bDeletingFixture = #False ; see comment earlier in this procedure re grWEP\bDeletingFixture
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_imgButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected nDevGrp, nDevNo, nNewDevNo, nMaxDevNoDisplay   ; also used for InGrp items and FixType items
  Protected rLogicalDev.tyAudioLogicalDevs
  Protected sLogicalDev.s, sInGrpName.s
  Protected i, j, k, d, d2, m, n, sCueIDs.s, bCannotRemove
  
  debugMsg(sProcName, #SCS_START + ", nButtonId=" + decodeStdBtnType(nButtonId))
  
  nDevGrp = grWEP\nCurrentDevGrp
  With grProdForDevChgs
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        nDevNo = grWEP\nCurrentAudDevNo
      Case #SCS_DEVGRP_VIDEO_AUDIO
        nDevNo = grWEP\nCurrentVidAudDevNo
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        nDevNo = grWEP\nCurrentVidCapDevNo
      Case #SCS_DEVGRP_FIX_TYPE
        nDevNo = grWEP\nCurrentFixTypeNo
      Case #SCS_DEVGRP_LIGHTING
        nDevNo = grWEP\nCurrentLightingDevNo
      Case #SCS_DEVGRP_CTRL_SEND
        nDevNo = grWEP\nCurrentCtrlDevNo
      Case #SCS_DEVGRP_CUE_CTRL
        nDevNo = grWEP\nCurrentCueDevNo
      Case #SCS_DEVGRP_LIVE_INPUT
        nDevNo = grWEP\nCurrentLiveDevNo
      Case #SCS_DEVGRP_IN_GRP
        nDevNo = grWEP\nCurrentInGrpNo
    EndSelect
  EndWith

  If nDevNo < 0
    ; shouldn't happen!
    debugMsg(sProcName, "exiting because nDevNo=" + nDevNo)
    ProcedureReturn
  EndIf
  
  nNewDevNo = -1
  
  Select nButtonId
    Case #SCS_STANDARD_BTN_MOVE_UP
      ;{
      WEP_swapDevices(nDevGrp, nDevNo, nDevNo-1)
      nNewDevNo = nDevNo - 1
      ;}
    Case #SCS_STANDARD_BTN_MOVE_DOWN
      ;{
      WEP_swapDevices(nDevGrp, nDevNo, nDevNo+1)
      nNewDevNo = nDevNo + 1
      ;}
    Case #SCS_STANDARD_BTN_PLUS
      ;{
      ; move this and following devices down one position
      WEP_insertDevice(nDevGrp, nDevNo)
      With grProdForDevChgs
        Select nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT
            nMaxDevNoDisplay = \nMaxAudioLogicalDevDisplay
          Case #SCS_DEVGRP_VIDEO_AUDIO
            nMaxDevNoDisplay = \nMaxVidAudLogicalDevDisplay
          Case #SCS_DEVGRP_VIDEO_CAPTURE
            nMaxDevNoDisplay = \nMaxVidCapLogicalDevDisplay
          Case #SCS_DEVGRP_FIX_TYPE
            nMaxDevNoDisplay = \nMaxFixTypeDisplay
          Case #SCS_DEVGRP_LIGHTING
            nMaxDevNoDisplay = \nMaxLightingLogicalDevDisplay
          Case #SCS_DEVGRP_CTRL_SEND
            nMaxDevNoDisplay = \nMaxCtrlSendLogicalDevDisplay
          Case #SCS_DEVGRP_CUE_CTRL
            nMaxDevNoDisplay = \nMaxCueCtrlLogicalDevDisplay
          Case #SCS_DEVGRP_LIVE_INPUT
            nMaxDevNoDisplay = \nMaxLiveInputLogicalDevDisplay
          Case #SCS_DEVGRP_IN_GRP
            nMaxDevNoDisplay = \nMaxInGrpDisplay
        EndSelect
      EndWith
      debugMsg(sProcName, "calling WEP_addDeviceIfReqd(" + decodeDevGrp(nDevGrp) + ", " + nMaxDevNoDisplay + ")")
      WEP_addDeviceIfReqd(nDevGrp, nMaxDevNoDisplay)
      nNewDevNo = nDevNo
      ;}
    Case #SCS_STANDARD_BTN_MINUS
      ;{
      ; can only delete this name if it is not being used in cues
      Select nDevGrp
        Case #SCS_DEVGRP_AUDIO_OUTPUT
          ;{
          sLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev
          If Trim(sLogicalDev)
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeI
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    For d = 0 To grLicInfo\nMaxAudDevPerAud
                      If aAud(k)\sLogicalDev[d] = sLogicalDev
                        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aAud(k)\sCue), #PB_MessageRequester_Error)
                        ProcedureReturn
                      EndIf
                    Next d
                    k = aAud(k)\nNextAudIndex
                  Wend
                ElseIf aSub(j)\bSubTypeP
                  For d = 0 To grLicInfo\nMaxAudDevPerSub
                    If aSub(j)\sPLLogicalDev[d] = sLogicalDev
                      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aSub(j)\sCue), #PB_MessageRequester_Error)
                      ProcedureReturn
                    EndIf
                  Next d
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_VIDEO_AUDIO
          ;{
          sLogicalDev = grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev
          If Trim(sLogicalDev)
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeA
                  If aSub(j)\sVidAudLogicalDev = sLogicalDev
                    scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aSub(j)\sCue), #PB_MessageRequester_Error)
                    ProcedureReturn
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_VIDEO_CAPTURE
          ;{
          sLogicalDev = grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev
          If Trim(sLogicalDev)
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeA
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    If aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
                      If aAud(k)\sVideoCaptureLogicalDevice = sLogicalDev
                        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aSub(j)\sCue), #PB_MessageRequester_Error)
                        ProcedureReturn
                      EndIf
                    EndIf
                    k = aAud(k)\nNextAudIndex
                  Wend
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_FIX_TYPE
          ;{
          sLogicalDev = grProdForDevChgs\aFixTypes(nDevNo)\sFixTypeName
          For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
            For n = 0 To grProdForDevChgs\aLightingLogicalDevs(d)\nMaxFixture
              If grProdForDevChgs\aLightingLogicalDevs(d)\aFixture(n)\sFixTypeName = sLogicalDev
                scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveFixType", sLogicalDev, grProdForDevChgs\aLightingLogicalDevs(d)\aFixture(n)\sFixtureCode), #PB_MessageRequester_Error)
                ProcedureReturn
              EndIf
            Next n
          Next d
          ;}
        Case #SCS_DEVGRP_LIGHTING
          ;{
          sLogicalDev = grProdForDevChgs\aLightingLogicalDevs(nDevNo)\sLogicalDev
          If Trim(sLogicalDev)
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeK
                  If aSub(j)\sLTLogicalDev = sLogicalDev
                    scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aSub(j)\sCue), #PB_MessageRequester_Error)
                    ProcedureReturn
                  EndIf
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_CTRL_SEND
          ;{
          sLogicalDev = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sLogicalDev
          If Trim(sLogicalDev)
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeM
                  For m = 0 To #SCS_MAX_CTRL_SEND
                    If aSub(j)\aCtrlSend[m]\sCSLogicalDev = sLogicalDev
                      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aSub(j)\sCue), #PB_MessageRequester_Error)
                      ProcedureReturn
                    EndIf
                  Next m
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_LIVE_INPUT
          ;{
          ; can only delete this name if it is not being used in cues or input groups
          sLogicalDev = grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\sLogicalDev
          If Trim(sLogicalDev)
            For d = 0 To grProdForDevChgs\nMaxInGrp
              sInGrpName = grProdForDevChgs\aInGrps(d)\sInGrpName
              If Trim(sInGrpName)
                For d2 = 0 To grProdForDevChgs\aInGrps(d)\nMaxInGrpItem
                  If grProdForDevChgs\aInGrps(d)\aInGrpItem(d2)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
                    If grProdForDevChgs\aInGrps(d)\aInGrpItem(d2)\sInGrpItemLiveInput = sLogicalDev
                      scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev2", sLogicalDev, sInGrpName), #PB_MessageRequester_Error)
                      ProcedureReturn
                    EndIf
                  EndIf
                Next d2
              EndIf
            Next d
            For i = 1 To gnLastCue
              j = aCue(i)\nFirstSubIndex
              While j >= 0
                If aSub(j)\bSubTypeI
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    For d = 0 To grLicInfo\nMaxLiveDevPerAud
                      If aAud(k)\sInputLogicalDev[d] = sLogicalDev
                        scsMessageRequester(grText\sTextValErr, LangPars("Errors", "CannotRemoveDev", sLogicalDev, aAud(k)\sCue), #PB_MessageRequester_Error)
                        ProcedureReturn
                      EndIf
                    Next d
                    k = aAud(k)\nNextAudIndex
                  Wend
                EndIf
                j = aSub(j)\nNextSubIndex
              Wend
            Next i
          EndIf
          ;}
        Case #SCS_DEVGRP_IN_GRP
          ; no testing required - not used permanently in cues or production properties
      EndSelect
      
      grWEP\bDeletingDevice = #True    ; added 19Sep2016 11.5.2.1 to prevent a validation error being displayed for a device being deleted
      WEP_removeDevice(nDevGrp, nDevNo)
      nNewDevNo = nDevNo
      With grProdForDevChgs
        Select nDevGrp
          Case #SCS_DEVGRP_AUDIO_OUTPUT
            If nNewDevNo > \nMaxAudioLogicalDev : nNewDevNo = \nMaxAudioLogicalDev : EndIf
          Case #SCS_DEVGRP_VIDEO_AUDIO
            If nNewDevNo > \nMaxVidAudLogicalDev : nNewDevNo = \nMaxVidAudLogicalDev : EndIf
          Case #SCS_DEVGRP_VIDEO_CAPTURE
            If nNewDevNo > \nMaxVidCapLogicalDev : nNewDevNo = \nMaxVidCapLogicalDev : EndIf
          Case #SCS_DEVGRP_FIX_TYPE
            If nNewDevNo > \nMaxFixType : nNewDevNo = \nMaxFixType : EndIf
          Case #SCS_DEVGRP_LIGHTING
            If nNewDevNo > \nMaxLightingLogicalDev : nNewDevNo = \nMaxLightingLogicalDev : EndIf
          Case #SCS_DEVGRP_CTRL_SEND
            If nNewDevNo > \nMaxCtrlSendLogicalDev : nNewDevNo = \nMaxCtrlSendLogicalDev : EndIf
          Case #SCS_DEVGRP_CUE_CTRL
            If nNewDevNo > \nMaxCueCtrlLogicalDev : nNewDevNo = \nMaxCueCtrlLogicalDev : EndIf
          Case #SCS_DEVGRP_LIVE_INPUT
            If nNewDevNo > \nMaxLiveInputLogicalDev : nNewDevNo = \nMaxLiveInputLogicalDev : EndIf
          Case #SCS_DEVGRP_IN_GRP
            If nNewDevNo > \nMaxInGrp : nNewDevNo = \nMaxInGrp : EndIf
        EndSelect
      EndWith
      ;}
  EndSelect
  
  Select nDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayAudDev(" + nDevNo + ")")
        WEP_displayAudDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayAudDev(" + nNewDevNo + ")")
      WEP_displayAudDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtAudLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_VIDEO_AUDIO
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayVidAudDev(" + nDevNo + ")")
        WEP_displayVidAudDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayVidAudDev(" + nNewDevNo + ")")
      WEP_displayVidAudDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtVidAudLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_VIDEO_CAPTURE
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayVidCapDev(" + nDevNo + ")")
        WEP_displayVidCapDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayVidCapDev(" + nNewDevNo + ")")
      WEP_displayVidCapDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtVidCapLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_FIX_TYPE
      ;{
      ; nb nDevNo and nNewDevNo here mean fixture type numbers - see comment at top of procedure
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayFixType(" + nDevNo + ")")
        WEP_displayFixType(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayFixType(" + nNewDevNo + ")")
      WEP_displayFixType(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtFixTypeName(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_LIGHTING
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayLightingDev(" + nDevNo + ")")
        WEP_displayLightingDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayLightingDev(" + nNewDevNo + ")")
      WEP_displayLightingDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtLightingLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_CTRL_SEND
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayCtrlDev(" + nDevNo + ")")
        WEP_displayCtrlDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayCtrlDev(" + nNewDevNo + ")")
      WEP_displayCtrlDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtCtrlLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_LIVE_INPUT
      ;{
      If nButtonId = #SCS_STANDARD_BTN_MINUS And nDevNo >= 0 And nDevNo <> nNewDevNo
        debugMsg(sProcName, "calling WEP_displayLiveDev(" + nDevNo + ")")
        WEP_displayLiveDev(nDevNo)
      EndIf
      debugMsg(sProcName, "calling WEP_displayLiveDev(" + nNewDevNo + ")")
      WEP_displayLiveDev(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtLiveLogicalDev(nNewDevNo))
      EndIf
      ;}
    Case #SCS_DEVGRP_IN_GRP
      ;{
      ; nb nNewDevNo here means input group no. - see comment at top of procedure
      WEP_displayInGrp(nNewDevNo)
      If nButtonId = #SCS_STANDARD_BTN_PLUS And nNewDevNo >= 0
        SAG(WEP\txtInGrpName(nNewDevNo))
      EndIf
      ;}
  EndSelect
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
  WEP_setDevChgsBtns()
  debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
  WEP_setRetryActivateBtn()
  
  grWEP\bDeletingDevice = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_indexToCmdNo(nIndex)
  PROCNAMEC()
  Protected nCmdNo
  
  Select nIndex
    Case 0
      nCmdNo = #SCS_DMX_GO_BUTTON
    Case 1
      nCmdNo = #SCS_DMX_STOP_ALL
    Case 2
      nCmdNo = #SCS_DMX_PAUSE_RESUME_ALL
    Case 3
      nCmdNo = #SCS_DMX_GO_TO_TOP
    Case 4
      nCmdNo = #SCS_DMX_GO_BACK
    Case 5
      nCmdNo = #SCS_DMX_GO_TO_NEXT
    Case 6
      nCmdNo = #SCS_DMX_MASTER_FADER
    Case 7
      nCmdNo = #SCS_DMX_PLAY_DMX_CUE_0
    Case 8
      nCmdNo = #SCS_DMX_PLAY_DMX_CUE_MAX
    Default
      nCmdNo = -1
  EndSelect
  ProcedureReturn nCmdNo
EndProcedure

Procedure WEP_setDevMapButtons()
  PROCNAMEC()
  Protected bEnableSaveAs
  Protected nOldDevMapPtr, nNewDevMapPtr
  Protected nOldDevPtr, nNewDevPtr
  Protected nLabel
  
  debugMsg(sProcName, #SCS_START)
  
  If grMapsForDevChgs\nMaxMapIndex > 0 ; must keep at least one dev map
    setEnabled(WEP\btnDeleteDevMap, #True)
  Else
    setEnabled(WEP\btnDeleteDevMap, #False)
  EndIf
  
  ; 'Save As Device Map' cannot be enabled if user has added or removed a logical device, or has changed a logical device setting (eg nNrOfOutputChans)
  ; This is because 'save as' needs to rollback any changes made to the original device map, wich cannot be done if the rolled back version would be incompatible with the latest logical device settings
  nOldDevMapPtr = grProd\nSelectedDevMapPtr
  nNewDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nLabel = 100
  If (nOldDevMapPtr >= 0) And (nNewDevMapPtr >= 0)
    bEnableSaveAs = #True
    nOldDevPtr = grMaps\aMap(nOldDevMapPtr)\nFirstDevIndex
    nNewDevPtr = grMapsForDevChgs\aMap(nNewDevMapPtr)\nFirstDevIndex
    nLabel = 200
    While nOldDevPtr >= 0
      If nNewDevPtr = -1
        bEnableSaveAs = #False
        nLabel = 300
        Break
      EndIf
      If grMaps\aDev(nOldDevPtr)\nDevGrp <> grMapsForDevChgs\aDev(nNewDevPtr)\nDevGrp
        bEnableSaveAs = #False
        nLabel = 400
        Break
      EndIf
      If grMaps\aDev(nOldDevPtr)\nDevType <> grMapsForDevChgs\aDev(nNewDevPtr)\nDevType
        bEnableSaveAs = #False
        nLabel = 500
        Break
      EndIf
      If grMaps\aDev(nOldDevPtr)\sLogicalDev <> grMapsForDevChgs\aDev(nNewDevPtr)\sLogicalDev
        bEnableSaveAs = #False
        nLabel = 600
        Break
      EndIf
      If grMaps\aDev(nOldDevPtr)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        If grMaps\aDev(nOldDevPtr)\nNrOfDevOutputChans <> grMapsForDevChgs\aDev(nNewDevPtr)\nNrOfDevOutputChans
          bEnableSaveAs = #False
          nLabel = 700
          Break
        EndIf
      EndIf
      nOldDevPtr = grMaps\aDev(nOldDevPtr)\nNextDevIndex
      nNewDevPtr = grMapsForDevChgs\aDev(nNewDevPtr)\nNextDevIndex
    Wend
  EndIf
  If bEnableSaveAs = #False
    debugMsg(sProcName, "nLabel=" + nLabel)
  EndIf
  ; debugMsg(sProcName, "bEnableSaveAs=" + strB(bEnableSaveAs) + ", nLabel=" + nLabel)
  setEnabled(WEP\btnSaveAsDevMap, bEnableSaveAs)
  
EndProcedure

Procedure WEP_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  debugMsg(sProcName, #SCS_START)
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)

  With WEP
    Select nEventGadgetNoForEvHdlr
        
      Case \edgTmDesc
        ETVAL2(WEP_edgTmDesc_Validate())
        
      Case \txtAudLogicalDev(0)
        ETVAL2(WEP_txtAudLogicalDev_Validate(nArrayIndex))
        
      Case \txtAudOutputGainDB(0)
        ETVAL2(WEP_txtOutputGainDB_Validate(nArrayIndex))
        
      Case \txtCtrlLogicalDev(0)
        ETVAL2(WEP_txtCtrlLogicalDev_Validate(nArrayIndex))
        
      Case \txtCtrlNetworkRemoteDevPW
        ETVAL2(WEP_txtCtrlNetworkRemoteDevPW_Validate())
        
      Case \txtCtrlSendDelay
        ETVAL2(WEP_txtCtrlSendDelay_Validate())
        
      Case \txtDBLevelChangeIncrement
        ETVAL2(WEP_txtDBLevelChangeIncrement_Validate())
        
      Case \txtDefChaseSpeed
        ETVAL2(WEP_txtDefChaseSpeed_Validate())
        
      Case \txtDefDisplayTimeA
        ETVAL2(WEP_txtDefDisplayTimeA_Validate())
        
      Case \txtDefDMXFadeTime
        ETVAL2(WEP_txtDefDMXFadeTime_Validate())
        
      Case \txtDefFadeInTime
        ETVAL2(WEP_txtDefFadeInTime_Validate())
        
      Case \txtDefFadeInTimeA
        ETVAL2(WEP_txtDefFadeInTimeA_Validate())
        
      Case \txtDefFadeInTimeI
        ETVAL2(WEP_txtDefFadeInTimeI_Validate())
        
      Case \txtDefFadeOutTime
        ETVAL2(WEP_txtDefFadeOutTime_Validate())
        
      Case \txtDefFadeOutTimeA
        ETVAL2(WEP_txtDefFadeOutTimeA_Validate())
        
      Case \txtDefFadeOutTimeI
        ETVAL2(WEP_txtDefFadeOutTimeI_Validate())
        
      Case \txtDefLoopXFadeTime
        ETVAL2(WEP_txtDefLoopXFadeTime_Validate())
        
      Case \txtDefSFRTimeOverride
        ETVAL2(WEP_txtDefSFRTimeOverride_Validate())
        
      Case \txtDfltDevDBLevel
        ETVAL2(WEP_txtDfltDevDBLevel_Validate())
        
      Case \txtDfltDevPan
        ETVAL2(WEP_txtDfltDevPan_Validate())
        
      Case \txtDfltInputDevDBLevel
        ETVAL2(WEP_txtDfltInputDevDBLevel_Validate())
        
      Case \txtDfltVidAudDBLevel
        ETVAL2(WEP_txtDfltVidAudDBLevel_Validate())
        
      Case \txtDfltVidAudPan
        ETVAL2(WEP_txtDfltVidAudPan_Validate())
        
      Case \txtDMXChannel[0]
        ETVAL2(WEP_txtDMXChannel_Validate(nArrayIndex))
        
      Case \txtFixTypeDesc
        ETVAL2(WEP_txtFTDesc_Validate())
        
      Case \txtFixTypeName(0)
        ETVAL2(WEP_txtFixTypeName_Validate(nArrayIndex))
        
      Case \txtFTCChannelDesc[0]
        ETVAL2(WEP_txtFTCChannelDesc_Validate(nArrayIndex))
        
      Case \txtFTCDefault[0]
        ETVAL2(WEP_txtFTCDefault_Validate(nArrayIndex))
  
      Case \txtFTTotalChans
        ETVAL2(WEP_txtFTTotalChans_Validate())
        
      Case \txtHTTPStart
        ETVAL2(WEP_txtHTTPStart_Validate())
        
      Case \txtLightingLogicalDev(0)
        ETVAL2(WEP_txtLightingLogicalDev_Validate(nArrayIndex))
        
      Case \txtLiveLogicalDev(0)
        ETVAL2(WEP_txtLiveLogicalDev_Validate(nArrayIndex))
        
      Case \txtLocalPort[0]
        ETVAL2(WEP_txtLocalPort_Validate(nArrayIndex))
        
      Case \txtMasterFaderDB
        ETVAL2(WEP_txtMasterFaderDB_Validate())
        
      Case \txtNetworkReceiveMsg[0]
        ETVAL2(WEP_txtNetworkReceiveMsg_Validate(nArrayIndex))
        
      Case \txtNetworkReplyMsg[0]
        ETVAL2(WEP_txtNetworkReplyMsg_Validate(nArrayIndex))
        
      Case \txtRemoteHost[0]
        ETVAL2(WEP_txtRemoteHost_Validate(nArrayIndex))
        
      Case \txtRemotePort[0]
        ETVAL2(WEP_txtRemotePort_Validate(nArrayIndex))
        
      Case \txtTimeProfile
        ETVAL2(WEP_txtTimeProfile_Validate(nArrayIndex))
        
      Case \txtTitle
        ETVAL2(WEP_txtTitle_Validate())
        
      Case \txtTmName
        ETVAL2(WEP_txtTmName_Validate())
        
      Case \txtVidAudLogicalDev(0)
        ETVAL2(WEP_txtVidAudLogicalDev_Validate(nArrayIndex))
        
      Case \txtVidAudOutputGainDB(0)
        ETVAL2(WEP_txtVidAudOutputGainDB_Validate(nArrayIndex))
        
      Case \txtVidCapDevFrameRate
        ETVAL2(WEP_txtVidCapFrameRate_Validate())
        
      Case \txtVidCapLogicalDev(0)
        ETVAL2(WEP_txtVidCapLogicalDev_Validate(nArrayIndex))
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
    debugMsg(sProcName, "gaGadgetProps(" + Str(nGadgetPropsIndex) + ")\bValidationReqd=" + strB(gaGadgetProps(nGadgetPropsIndex)\bValidationReqd))
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      debugMsg(sProcName, #SCS_END + ", returning #False")
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      debugMsg(sProcName, #SCS_END + ", returning #True")
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    debugMsg(sProcName, #SCS_END + ", returning #True")
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WEP__EventHandler()
  PROCNAMEC()
  Protected bFound, n, nActiveGadgetNo, nGadgetPropsIndex, nNewIndex, nPanelIndex
  
  With WEP
    
    If gnEventSliderNo > 0
      ; debugMsg(sProcName, "gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=G" + gnEventSliderNo)
      
      Select gnEventSliderNo
          
        Case \sldDfltDevLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDfltDevLevel()
          EndSelect
          
        Case \sldDfltDevPan
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDfltDevPan()
          EndSelect
          
        Case \sldDfltInputDevLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDfltInputDevLevel()
          EndSelect
          
        Case \sldDfltVidAudLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDfltVidAudLevel()
          EndSelect
          
        Case \sldDfltVidAudPan
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDfltVidAudPan()
          EndSelect
          
        Case \sldDMXMasterFader2
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldDMXMasterFader()
          EndSelect
          
        Case \sldMasterFader2
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldMasterFader()
          EndSelect
          
        Case \sldTestToneLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldTestToneLevel()
          EndSelect
          
        Case \sldTestTonePan
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              ED_fcSldTestTonePan()
          EndSelect
          
        Default
          For n = 0 To grProdForDevChgs\nMaxAudioLogicalDevDisplay
            If SLD_isSlider(\sldAudOutputGain(n))
              If \sldAudOutputGain(n) = gnEventSliderNo
                bFound = #True
                Select gnSliderEvent
                  Case #SCS_SLD_EVENT_GOT_FOCUS
                    WEP_setCurrentAudDevInfo(n)
                  Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                    ED_fcSldOutputGain(n)
                EndSelect
                Break
              EndIf
            EndIf
          Next n
          
          If bFound = #False
            For n = 0 To grProdForDevChgs\nMaxLiveInputLogicalDevDisplay
              If SLD_isSlider(\sldInputGain(n))
                If \sldInputGain(n) = gnEventSliderNo
                  bFound = #True
                  Select gnSliderEvent
                    Case #SCS_SLD_EVENT_GOT_FOCUS
                      WEP_setCurrentLiveDevInfo(n)
                    Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                      ED_fcSldInputGain(n)
                  EndSelect
                  Break
                EndIf
              EndIf
            Next n
          EndIf
          
          If bFound = #False
            For n = 0 To grProdForDevChgs\nMaxVidAudLogicalDevDisplay
              If SLD_isSlider(\sldVidAudOutputGain(n))
                If \sldVidAudOutputGain(n) = gnEventSliderNo
                  bFound = #True
                  Select gnSliderEvent
                    Case #SCS_SLD_EVENT_GOT_FOCUS
                      WEP_setCurrentVidAudDevInfo(n)
                    Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                      ED_fcSldVidAudOutputGain(n)
                  EndSelect
                  Break
                EndIf
              EndIf
            Next n
          EndIf
          
      EndSelect
      
      If bFound
        ProcedureReturn
      EndIf
      
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Menu
        ; see WED_EventHandler
        
      Case #PB_Event_Gadget
        If gnEventButtonId <> 0
          ; debugMsg(sProcName, "gnEventButtonId=" + gnEventButtonId + ", gnEventGadgetNo=" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + ")")
          Select gnEventButtonId
            Case #SCS_STANDARD_BTN_MOVE_UP, #SCS_STANDARD_BTN_MOVE_DOWN, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS
              WEP_stopProdTestIfRunning()
              Select gnEventGadgetNo
                Case WEP\imgFixtureButtonTBS[0], WEP\imgFixtureButtonTBS[1], WEP\imgFixtureButtonTBS[2], WEP\imgFixtureButtonTBS[3]
                  WEP_imgFixtureButtonTBS_Click(gnEventButtonId)
                Default
                  WEP_imgButtonTBS_Click(gnEventButtonId)
              EndSelect
          EndSelect
          
        Else
          
          ; debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + "(" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType() + ", gnEventType=" + decodeEventType(gnEventGadgetNo))
          Select gnEventGadgetNoForEvHdlr   
              
            Case \btnApplyDevChgs
              BTNCLICK(WEP_btnApplyDevChgs_Click())
              
            Case \btnCompIPAddresses[0]
              BTNCLICK(WEP_btnCompIPAddresses_Click(gnEventGadgetArrayIndex))
              
            Case \btnCopyDMXStartsFrom
              BTNCLICK(WEP_btnCopyDMXStartsFrom_Click())
              
            Case \btnDeleteDevMap
              BTNCLICK(WEP_btnDeleteDevMap_Click())
              
            Case \btnDfltDevCenter
              BTNCLICK(WEP_btnDfltDevCenter_Click())
              
            Case \btnDfltVidAudCenter
              BTNCLICK(WEP_btnDfltVidAudCenter_Click())
              
            Case \btnDriverSettings
              BTNCLICK(WEP_btnDriverSettings_Click())              
              
            Case \btnRenameDevMap
              BTNCLICK(WEP_btnRenameDevMap())
              
            Case \btnRetryActivate
              BTNCLICK(WEP_btnRetryActivate_Click())
              
            Case \btnRS232Default[0]
              BTNCLICK(WEP_btnRS232Default_Click(gnEventGadgetArrayIndex))
              
            Case \btnSaveAsDevMap
              BTNCLICK(WEP_btnSaveAsDevMap_Click())
              
            Case \btnTestDMX
              BTNCLICK(WEP_btnTestDMX_Click())
              
            Case \btnTestLiveInputCancel
              BTNCLICK(WEP_cancelTestLiveInput())
              
            Case \btnTestLiveInputStart
              BTNCLICK(WEP_btnTestLiveInputStart_Click())
              
            Case \btnTestMidi
              BTNCLICK(WEP_btnTestMidi_Click())
              
            Case \btnTestRS232
              BTNCLICK(WEP_btnTestRS232_Click())
              
            Case \btnTestNetwork
              BTNCLICK(WEP_btnTestNetwork_Click())
              
            Case \btnTestToneCenter
              BTNCLICK(WEP_btnTestToneCenter_Click())
              
            Case \btnTestToneCancel
              BTNCLICK(WEP_cancelTestTone())
              
            Case \btnTestToneContinuous
              BTNCLICK(WEP_btnTestToneCommon_Click(#True))
              
            Case \btnTestToneShort
              BTNCLICK(WEP_btnTestToneCommon_Click(#False))
              
            Case \btnUndoDevChgs
              BTNCLICK(WEP_btnUndoDevChgs_Click())
              
            Case \btnTestVidCapStop
              BTNCLICK(WEP_btnTestVidCapStop_Click())
              
            Case \btnTestVidCapStart
              BTNCLICK(WEP_btnTestVidCapStart_Click())
              
            Case \cboAudioDriver
              CBOCHG(WEP_cboAudioDriver_Click())
              
            Case \cboAudioPhysicalDev(0)
              CBOCHG(WEP_cboAudioPhysicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboCtrlMethod
              CBOCHG(WEP_cboCtrlMethod_Click())
              
            Case \cboCtrlMidiChannel
              CBOCHG(WEP_cboCtrlMidiChannel_Click())
              
            Case \cboCtrlMidiRemoteDev
              CBOCHG(WEP_cboCtrlMidiRemoteDev_Click())
              
            Case \cboCtrlNetworkRemoteDev
              CBOCHG(WEP_cboCtrlNetworkRemoteDev_Click())
              
            Case \cboCueDevType(0)
              CBOCHG(WEP_cboCueDevType_Click(gnEventGadgetArrayIndex))
              
            Case \cboCueLabelIncrement
              CBOCHG(WEP_cboCueLabelIncrement_Click())
              
            Case \cboCueNetworkRemoteDev
              CBOCHG(WEP_cboCueNetworkRemoteDev_Click())
              
            Case \cboDefOutputScreen
              CBOCHG(WEP_cboDefOutputScreen_Click())
              
            Case \cboDelayBeforeReloadNames
              CBOCHG(WEP_cboDelayBeforeReloadNames_Click())
              
            Case \cboDevMap
              CBOCHG(WEP_cboDevMap_Click())
              
            Case \cboDfltDevTrim
              CBOCHG(WEP_cboDfltDevTrim_Click())
              
            Case \cboDfltTimeProfile
              CBOCHG(WEP_cboDfltTimeProfile_Click())
              
            Case \cboDfltTimeProfileForDay[0]
              CBOCHG(WEP_cboDfltTimeProfileForDay_Click(gnEventGadgetArrayIndex))
              
            Case \cboDfltVidAudTrim
              CBOCHG(WEP_cboDfltVidAudTrim_Click())
              
            Case \cboDMXPhysDev[0]
              CBOCHG(WEP_cboDMXPhysDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboDMXPort[0]
              CBOCHG(WEP_cboDMXPort_Click(gnEventGadgetArrayIndex))
              
            Case \cboDMXRefreshRate
              CBOCHG(WEP_cboDMXRefreshRate_Click())
              
            Case \cboDMXIpAddress
              CBOCHG(WEP_cboDMXIpAddress_Click())
              
            Case \btnDMXIPRefresh
              BTNCLICK(WEP_btnDMXIPRefresh_Click())
              
            Case \cboDMXTrgValue
              CBOCHG(WEP_cboDMXTrgValue_Click())
              
            Case #SCS_G4EH_PR_CBOFIXTURETYPE ; \cboFixtureType()
              CBOCHG(WEP_cboFixtureType_Click(gnEventGadgetArrayIndex))
              
            Case \cboFocusPoint
              CBOCHG(WEP_cboFocusPoint_Click())
              
            Case \cboGoMacro
              CBOCHG(WEP_cboGoMacro_Click())
              
            Case \cboGridClickAction
              CBOCHG(WEP_cboGridClickAction_Click())
              
            Case \cboInGrpLiveInput(0)
              CBOCHG(WEP_cboInGrpLiveInput_Click(gnEventGadgetArrayIndex))
              
            Case \cboInputRange(0)
              CBOCHG(WEP_cboInputRange_Click(gnEventGadgetArrayIndex))
              
            Case \cboLightingDevType(0)
              CBOCHG(WEP_cboLightingDevType_Click(gnEventGadgetArrayIndex))
              
            Case \cboLivePhysicalDev(0)
              CBOCHG(WEP_cboLivePhysicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboLostFocusAction
              CBOCHG(WEP_cboLostFocusAction_Click())
              
            Case \cboMinDBLevel
              CBOCHG(WEP_cboMinDBLevel_Click())
              
            Case \cboMaxDBLevel
              CBOCHG(WEP_cboMaxDBLevel_Click())
              
            Case \cboMemoDispOptForPrim
              CBOCHG(WEP_cboMemoDispOptForPrim_Click())
              
            Case \cboMidiCC[0]
              CBOCHG(WEP_cboMidiCC_Click(gnEventGadgetArrayIndex))
              
            Case \cboMidiChannel
              CBOCHG(WEP_cboMidiChannel_Click())
              
            Case \cboMidiCommand[0]
              CBOCHG(WEP_cboMidiCommand_Click(gnEventGadgetArrayIndex))
              
            Case \cboMidiDevId
              CBOCHG(WEP_cboMidiDevId_Click())
              
            Case \cboMidiInPort
              CBOCHG(WEP_cboMidiInPort_Click())
              
            Case \cboMidiOutPort
              CBOCHG(WEP_cboMidiOutPort_Click())
              
            Case \cboMidiThruInPort
              CBOCHG(WEP_cboMidiThruInPort_Click())
              
            Case \cboMidiThruOutPort
              CBOCHG(WEP_cboMidiThruOutPort_Click())
              
            Case \cboMidiVV[0]
              CBOCHG(WEP_cboMidiVV_Click(gnEventGadgetArrayIndex))
              
            Case \cboMSCCommandFormat
              CBOCHG(WEP_cboMSCCommandFormat_Click())
              
            Case \cboNetworkMsgAction[0]
              CBOCHG(WEP_cboNetworkMsgAction_Click(gnEventGadgetArrayIndex))
              
            Case \cboNetworkMsgFormat
              CBOCHG(WEP_cboNetworkMsgFormat_Click())
              
            Case \cboNetworkProtocol[0]
              CBOCHG(WEP_cboNetworkProtocol_Click(gnEventGadgetArrayIndex))
              
            Case \cboNetworkRole[0]
              CBOCHG(WEP_cboNetworkRole_Click(gnEventGadgetArrayIndex))
              
            Case \cboNumChans(0)
              CBOCHG(WEP_cboNumChans_Click(gnEventGadgetArrayIndex))
              
            Case \cboNumInputChans(0)
              CBOCHG(WEP_cboNumInputChans_Click(gnEventGadgetArrayIndex))
              
            Case \cboOSCVersion[0]
              CBOCHG(WEP_cboOSCVersion_Click())
              
            Case \cboOutputDevForTestLiveInput
              CBOCHG(WEP_cboOutputDevForTestLiveInput_Click())
              
            Case \cboOutputRange(0)
              CBOCHG(WEP_cboOutputRange_Click(gnEventGadgetArrayIndex))
              
            Case \cboResetTOD
              CBOCHG(WEP_cboResetTOD_Click())
              
            Case \cboRS232BaudRate[0]
              CBOCHG(WEP_cboRS232BaudRate_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232DataBits[0]
              CBOCHG(WEP_cboRS232DataBits_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232DTREnable[0]
              CBOCHG(WEP_cboRS232DTREnable_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232Handshaking[0]
              CBOCHG(WEP_cboRS232Handshaking_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232Parity[0]
              CBOCHG(WEP_cboRS232Parity_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232Port[0]
              CBOCHG(WEP_cboRS232Port_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232RTSEnable[0]
              CBOCHG(WEP_cboRS232RTSEnable_Click(gnEventGadgetArrayIndex))
              
            Case \cboRS232StopBits[0]
              CBOCHG(WEP_cboRS232StopBits_Click(gnEventGadgetArrayIndex))
              
            Case \cboRunMode
              CBOCHG(WEP_cboRunMode_Click())
              
            Case \cboTestSound
              CBOCHG(WEP_cboTestSound_Click())
              
            Case \cboThresholdVV
              CBOCHG(WEP_cboThresholdVV_Click())
              
            Case \cboVidAudPhysicalDev(0)
              CBOCHG(WEP_cboVidAudPhysicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboVidCapDevFormat
              CBOCHG(WEP_cboVidCapFormat_Click())
              
            Case \cboVidCapPhysicalDev(0)
              CBOCHG(WEP_cboVidCapPhysicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboVisualWarningFormat
              CBOCHG(WEP_cboVisualWarningFormat_Click())
              
            Case \cboVisualWarningTime
              CBOCHG(WEP_cboVisualWarningTime_Click())
              
            Case \cboX32Command[0]
              CBOCHG(WEP_cboX32Command_Click(gnEventGadgetArrayIndex))
              
            Case \chkAllowHKeyClick
              CHKOWNCHG(WEP_chkAllowHKeyClick_Click())
              
            Case \chkAutoInclude
              CHKOWNCHG(WEP_chkAutoInclude_Click())
              
            Case \chkConnectWhenReqd ; Added 19Sep2022 11.9.6
              CHKOWNCHG(WEP_chkConnectWhenReqd_Click(gnEventGadgetNoForEvHdlr))
              
            Case \chkDefPauseAtEndA
              CHKOWNCHG(WEP_chkDefPauseAtEndA_Click())
              
            Case \chkDefRepeatA
              CHKOWNCHG(WEP_chkDefRepeatA_Click())
              
            Case \chkDoNotCalcCueStartValues
              CHKOWNCHG(WEP_chkDoNotCalcCueStartValues_Click())
              
            Case \chkEnableMidiCue
              CHKOWNCHG(WEP_chkEnableMidiCue_Click())
              
            Case \chkForLTC
              CHKOWNCHG(WEP_chkForLTC_Click())
              
            Case \chkForMTC
              CHKOWNCHG(WEP_chkForMTC_Click())
              
            Case \chkFTCDimmerChan[0]
              CHKOWNCHG(WEP_chkFTCDimmerChan_Click(gnEventGadgetArrayIndex))
              
            Case \chkInputForLTC
              CHKOWNCHG(WEP_chkInputForLTC_Click())
              
            Case \chkLabelsFrozen
              CHKOWNCHG(WEP_chkLabelsFrozen_Click())
              
            Case \chkLabelsUCase
              CHKOWNCHG(WEP_chkLabelsUCase_Click())
              
            Case \chkM2TSkipEarlierCSMsgs_MidiOut
              CHKOWNCHG(WEP_chkM2TSkipEarlierCtrlMsgs_Click(gnEventGadgetNoForEvHdlr))
              
            Case \chkMMCApplyFadeForStop
              CHKOWNCHG(WEP_chkMMCApplyFadeForStop_Click())
              
            Case \chkNetworkDummy[0]
              CHKOWNCHG(WEP_chkNetworkDummy_Click(gnEventGadgetArrayIndex))
              
            Case \chkNetworkReplyMsgAddCR
              CHKOWNCHG(WEP_chkNetworkReplyMsgAddCR_Click())
              
            Case \chkNetworkReplyMsgAddLF
              CHKOWNCHG(WEP_chkNetworkReplyMsgAddLF_Click())
              
            Case \chkNoPreLoadVideoHotkeys
              CHKOWNCHG(WEP_chkNoPreLoadVideoHotkeys_Click())
              
            Case \chkPreLoadNextManualOnly
              CHKOWNCHG(WEP_chkPreLoadNextManualOnly_Click())
              
            Case \chkStopAllInclHib
              CHKOWNCHG(WEP_chkStopAllInclHib_Click())
              
            Case \chkGetRemDevScribbleStripNames
              CHKOWNCHG(WEP_chkGetRemDevScribbleStripNames_Click())
              
            Case \chkVidAudAutoInclude
              CHKOWNCHG(WEP_chkVidAudAutoInclude_Click())
              
            Case \chkVidCapAutoInclude
              CHKOWNCHG(WEP_chkVidCapAutoInclude_Click())
              
            Case \cvsCtrlDevType(0)
              If gnEventType = #PB_EventType_LeftClick
;                 debugMsg(sProcName, "\cvsCtrlDevType(" + gnEventGadgetArrayIndex + ") clicked")
                grWEP\nCtrlDevClicked = gnEventGadgetArrayIndex
;                 If gnEventGadgetArrayIndex > grProdForDevChgs\nMaxCtrlSendLogicalDev ; ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())
;                   WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, gnEventGadgetArrayIndex)
;                 EndIf
                If gnEventGadgetArrayIndex <= grProdForDevChgs\nMaxCtrlSendLogicalDev
                  WEP_buildPopupMenu_CSDevTypes(grProdForDevChgs\aCtrlSendLogicalDevs(gnEventGadgetArrayIndex)\nDevType)
                Else
                  WEP_buildPopupMenu_CSDevTypes(#SCS_DEVTYPE_NONE)
                EndIf
                DisplayPopupMenu(#WEP_mnuCSDevTypes, WindowID(#WED))
              EndIf                   
              
            Case \cvsFTCGridSample[0]
              ; no action
              
            Case \cvsFTCTextColor[0]
              If gnEventType = #PB_EventType_LeftClick
                WEP_setCurrentFixTypeChan(gnEventGadgetArrayIndex)
                DisplayPopupMenu(#WEP_mnuGridColors, WindowID(#WED))
              EndIf                   
              
            Case \cvsTestLiveInputVU
              ; no action
              
            Case \cvsTestVidCap
              ; no action
              
            Case \edgMidiAssigns, \edgRS232Assigns, \edgNetworkAssigns
              ; no action
              
            Case \edgTmDesc
              Select gnEventType
                Case #PB_EventType_Change
                  gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd = #True
                  gnValidateGadgetNo = gnEventGadgetNo
                Case #PB_EventType_LostFocus
                  WEP_edgTmDesc_Validate()
              EndSelect
              
            Case \lblAudDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblAudDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblCtrlDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblCtrlDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblCueDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblCueDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case #SCS_G4EH_PR_LBLFIXTURENO  ; \lblFixtureNo()
              If gnEventType = #PB_EventType_Focus
                WEP_lblFixtureNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblFixTypeNo(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  debugMsg(sProcName, "calling WEP_setCurrentFixType(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixType(gnEventGadgetArrayIndex)
              EndSelect
              
            Case \lblFTCChanNo[0]
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_lblFTCChanNo_Focus(gnEventGadgetArrayIndex)
;                   WEP_setCurrentFixTypeChan(gnEventGadgetArrayIndex)
              EndSelect
             
              
            Case \lblInGrpNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblInGrpNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblLightingDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblLightingDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblLiveDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblLiveDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblVidAudDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblVidAudDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \lblVidCapDevNo(0)
              If gnEventType = #PB_EventType_Focus
                WEP_lblVidCapDevNo_Focus(gnEventGadgetArrayIndex)
              EndIf
              
            Case \optDMXInPref[0]
              WEP_optDMXPref_Click(1)
              
            Case \optDMXOutPref[0]
              WEP_optDMXPref_Click(0)
              
            Case \optDMXTrgCtrl[0]
              WEP_optDMXTrgCtrl_Click()
              
            Case \pnlDevs
              If gnEventType = #PB_EventType_Change
                WEP_pnlDevs_Click()
              EndIf
              
            Case \pnlProd
              If gnEventType = #PB_EventType_Change
                WEP_pnlProd_Click()
              EndIf
              
            Case \txtAudLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentAudDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtAudLogicalDev_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtAudOutputGainDB(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentAudDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtOutputGainDB_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtCtrlLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentCtrlDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtCtrlLogicalDev_Validate(gnEventGadgetArrayIndex))
                  If gnEventGadgetArrayIndex > ArraySize(grProdForDevChgs\aCtrlSendLogicalDevs())
                    debugMsg(sProcName, "calling WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, " + gnEventGadgetArrayIndex + ")")
                    WEP_addDeviceIfReqd(#SCS_DEVGRP_CTRL_SEND, gnEventGadgetArrayIndex)
                  EndIf
              EndSelect
              
            Case \txtCtrlNetworkRemoteDevPW
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtCtrlNetworkRemoteDevPW_Validate())
              EndSelect
              
            Case \txtCtrlSendDelay
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtCtrlSendDelay_Validate())
              EndSelect
              
            Case \txtDBLevelChangeIncrement
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDBLevelChangeIncrement_Validate())
              EndSelect
              
            Case \txtDefChaseSpeed
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefChaseSpeed_Validate())
              EndIf
              
            Case \txtDefDisplayTimeA
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefDisplayTimeA_Validate())
              EndIf
              
            Case \txtDefDMXFadeTime
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefDMXFadeTime_Validate())
              EndIf
              
            Case \txtDefFadeInTime
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeInTime_Validate())
              EndIf
              
            Case \txtDefFadeInTimeA
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeInTimeA_Validate())
              EndIf
              
            Case \txtDefFadeInTimeI
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeInTimeI_Validate())
              EndIf
              
            Case \txtDefFadeOutTime
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeOutTime_Validate())
              EndIf
              
            Case \txtDefFadeOutTimeA
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeOutTimeA_Validate())
              EndIf
              
            Case \txtDefFadeOutTimeI
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefFadeOutTimeI_Validate())
              EndIf
              
            Case \txtDefLoopXFadeTime
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefLoopXFadeTime_Validate())
              EndIf
              
            Case \txtDefSFRTimeOverride
              If gnEventType = #PB_EventType_LostFocus
                ETVAL(WEP_txtDefSFRTimeOverride_Validate())
              EndIf
              
            Case \txtDfltDevDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDfltDevDBLevel_Validate())
              EndSelect
              
            Case \txtDfltDevPan
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDfltDevPan_Validate())
              EndSelect
              
            Case \txtDfltInputDevDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDfltInputDevDBLevel_Validate())
              EndSelect
              
            Case \txtDfltVidAudDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDfltVidAudDBLevel_Validate())
              EndSelect
              
            Case \txtDfltVidAudPan
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDfltVidAudPan_Validate())
              EndSelect
              
            Case \txtDMXChannel[0]
              Select gnEventType
                Case #PB_EventType_Change
                  WEP_txtDMXChannel_Change(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDMXChannel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case #SCS_G4EH_PR_TXTDMXSTARTCHANNEL  ; \txtDMXStartChannel
              Select gnEventType
                Case #PB_EventType_Focus
                  ; debugMsg(sProcName, "\txtDimmableChannels focus calling WEP_setCurrentFixture(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixture(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDMXStartChannel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case #SCS_G4EH_PR_TXTDIMMABLECHANNELS  ; \txtDimmableChannels
              Select gnEventType
                Case #PB_EventType_Focus
                  ; debugMsg(sProcName, "\txtDimmableChannels focus calling WEP_setCurrentFixture(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixture(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtDimmableChannels_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case #SCS_G4EH_PR_TXTFIXTURECODE  ; \txtFixtureCode
              Select gnEventType
                Case #PB_EventType_Focus
                  ; debugMsg(sProcName, "\txtFixtureCode focus calling WEP_setCurrentFixture(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixture(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFixtureCode_Validate(gnEventGadgetArrayIndex))
                  ED_fcFixtureCode(gnEventGadgetArrayIndex)
                  ; commented out 20Sep2021 11.8.6aj - prevented focus being set to a blank entry at the start
;                   If gbLastVALResult
;                     nActiveGadgetNo = GetActiveGadget()
;                     If IsGadget(nActiveGadgetNo)
;                       nGadgetPropsIndex = getGadgetPropsIndex(nActiveGadgetNo)
;                       If Left(gaGadgetProps(nGadgetPropsIndex)\sName, 12) = "lblFixtureNo"
;                         ; must have back-tabbed
;                         ; debugMsg(sProcName, "back-tabbed")
;                         If gnEventGadgetArrayIndex > 0
;                           nNewIndex = gnEventGadgetArrayIndex - 1
;                           ; debugMsg(sProcName, "setting grWEP\nReqdFixtureFocusGadget = WEPFixture(" + nNewIndex + ")\txtDMXStartChannel")
;                           grWEP\nReqdFixtureFocusGadget = WEPFixture(nNewIndex)\txtDMXStartChannel
;                         EndIf
;                       EndIf
;                     EndIf
;                   EndIf
              EndSelect
              
            Case #SCS_G4EH_PR_TXTFIXTUREDESC  ; \txtFixtureDesc
              Select gnEventType
                Case #PB_EventType_Focus
                  ; debugMsg(sProcName, "\txtFixtureDesc focus calling WEP_setCurrentFixture(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixture(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFixtureDesc_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtFixTypeDesc
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFTDesc_Validate())
              EndSelect
              
            Case \txtFixTypeInfo(0)
              ; no action (read-only gadget)
              
            Case \txtFixTypeName(0)
              ; Debug "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType(gnEventGadgetNo)
              Select gnEventType
                Case #PB_EventType_Focus
                  debugMsg(sProcName, "calling WEP_setCurrentFixType(" + gnEventGadgetArrayIndex + ")")
                  WEP_setCurrentFixType(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  If gaGadgetProps(gnEventGadgetPropsIndex)\bValidationReqd
                    ETVAL(WEP_txtFixTypeName_Validate(gnEventGadgetArrayIndex))
                  Else
                    If GetActiveGadget() = WEP\txtFixTypeInfo(gnEventGadgetArrayIndex)
                      SAG(WEP\txtFixTypeDesc)
                    EndIf
                  EndIf
              EndSelect
              
            Case \txtFTCChannelDesc[0]
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentFixTypeChan(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFTCChannelDesc_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtFTCDefault[0]
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentFixTypeChan(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFTCDefault_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtFTTotalChans
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtFTTotalChans_Validate())
              EndSelect
              
            Case \txtHTTPStart
              Select gnEventType
                Case #PB_EventType_Change
                  WEP_txtHTTPStart_Change()
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtHTTPStart_Validate())
              EndSelect
              
            Case \txtInGrpInfo(0)
              ; no action
              
            Case \txtInGrpName(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentInGrpInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtInGrpName_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtInputGainDB(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentLiveDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtInputGainDB_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtLightingLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentLightingDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtLightingLogicalDev_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtLiveLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentLiveDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtLiveLogicalDev_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtLocalPort[0]
              Select gnEventType
                Case #PB_EventType_Change
                  WEP_txtLocalPort_Change(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtLocalPort_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtMasterFaderDB
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtMasterFaderDB_Validate())
              EndSelect
              
            Case \txtNetworkReceiveMsg[0]
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtNetworkReceiveMsg_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtNetworkReplyMsg[0]
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtNetworkReplyMsg_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtRemoteHost[0]
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtRemoteHost_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtRemotePort[0]
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtRemotePort_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtTimeProfile[0]
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtTimeProfile_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtTitle
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtTitle_Validate())
              EndSelect
              
            Case \txtTmName
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtTmName_Validate())
              EndSelect
              
            Case \txtVidAudLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentVidAudDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtVidAudLogicalDev_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtVidAudOutputGainDB(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentVidAudDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtVidAudOutputGainDB_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtVidCapDummy(0)
              ; no action - see comment about this field in createWEPVidCapDevs()
              
            Case \txtVidCapDevFrameRate
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtVidCapFrameRate_Validate())
              EndSelect
              
            Case \txtVidCapLogicalDev(0)
              Select gnEventType
                Case #PB_EventType_Focus
                  WEP_setCurrentVidCapDevInfo(gnEventGadgetArrayIndex)
                Case #PB_EventType_LostFocus
                  ETVAL(WEP_txtVidCapLogicalDev_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Default
              If gnEventType <> #PB_EventType_Resize
                Select GadgetType(gnEventGadgetNo)
                  Case #PB_GadgetType_Container, #PB_GadgetType_ScrollArea
                    ; no action or tracing
                  Default
                    Select gnEventType
                      Case #PB_EventType_Resize
                        ; ignore
                      Default
                        debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
                    EndSelect
                EndSelect
              EndIf
              
          EndSelect
          
        EndIf
        
      Case #PB_Event_Timer
        debugMsg(sProcName, "#PB_Event_Timer")
        If EventTimer() = #SCS_TIMER_TEST_TONE
          debugMsg(sProcName, "calling WEP_cancelTestTone()")
          WEP_cancelTestTone()
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WEP_setDevChgsBtns()
  PROCNAMEC()
  Protected nChanged, nOutputGainChanged, nInputGainChanged
  Protected n, n2, n3, nFixtureIndex
  Protected m
  Protected nDevMapPtr
  Protected nDevMapDevPtrOld, nDevMapDevPtrNew
  Protected sLogicalDev.s
  Protected sInGrpName.s
  Protected nCheckDevMapResult
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grMapsForDevChgs\nMaxMapIndex <> grMaps\nMaxMapIndex
    ; possibly due to a device map being deleted
    nChanged = 900
  ElseIf grMapsForDevChgs\nMaxDevIndex <> grMaps\nMaxDevIndex
    nChanged = 910
  ElseIf grMapsForDevChgs\nMaxLiveGrpIndex <> grMaps\nMaxLiveGrpIndex
    nChanged = 920
  EndIf
  
  If nChanged = 0
    ; check for change of device map or audio driver
    If grProdForDevChgs\nSelectedDevMapPtr <> grProd\nSelectedDevMapPtr
      ; debugMsg(sProcName, "grProdForDevChgs\nSelectedDevMapPtr=" + grProdForDevChgs\nSelectedDevMapPtr + ", grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
      nChanged = 1000
    ElseIf grProdForDevChgs\sSelectedDevMapName <> grProd\sSelectedDevMapName
      nChanged = 1010
    Else
      nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
      If nDevMapPtr >= 0
        If grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName <> grMaps\aMap(nDevMapPtr)\sDevMapName
          ; debugMsg(sProcName, "grMapsForDevChgs\aMap(" + nDevMapPtr + ")\sDevMapName=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", grMaps\aMap(nDevMapPtr)\sDevMapName=" + grMaps\aMap(nDevMapPtr)\sDevMapName)
          nChanged = 1020
        ElseIf grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver <> grMaps\aMap(nDevMapPtr)\nAudioDriver
          nChanged = 1030
        EndIf
      EndIf
    EndIf
  EndIf
  
  With grProdForDevChgs
    ; INFO: check for audio output device changes
    ;{
    If nChanged = 0
      If \nMaxAudioLogicalDev <> grProd\nMaxAudioLogicalDev
        nChanged = 2005
      Else
        For n = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(n)\sLogicalDev <> grProd\aAudioLogicalDevs(n)\sLogicalDev
            nChanged = 2010
            Break
          EndIf
          If \aAudioLogicalDevs(n)\nNrOfOutputChans <> grProd\aAudioLogicalDevs(n)\nNrOfOutputChans
            nChanged = 2020
            Break
          EndIf
          If \aAudioLogicalDevs(n)\nPhysicalDevPtr <> grProd\aAudioLogicalDevs(n)\nPhysicalDevPtr
            nChanged = 2030
            Break
          EndIf
          If \aAudioLogicalDevs(n)\bAutoInclude <> grProd\aAudioLogicalDevs(n)\bAutoInclude
            nChanged = 2050
            Break
          EndIf
          If \aAudioLogicalDevs(n)\bForLTC <> grProd\aAudioLogicalDevs(n)\bForLTC
            nChanged = 2055
            Break
          EndIf
          If \aAudioLogicalDevs(n)\sDfltDBTrim <> grProd\aAudioLogicalDevs(n)\sDfltDBTrim
            nChanged = 2060
            Break
          EndIf
          If \aAudioLogicalDevs(n)\sDfltDBLevel <> grProd\aAudioLogicalDevs(n)\sDfltDBLevel
            nChanged = 2070
            Break
          EndIf
          If \aAudioLogicalDevs(n)\fDfltPan <> grProd\aAudioLogicalDevs(n)\fDfltPan
            nChanged = 2080
            Break
          EndIf
          sLogicalDev = \aAudioLogicalDevs(n)\sLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 2110
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 2115
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 2130
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\s1BasedOutputRange <> grMaps\aDev(nDevMapDevPtrOld)\s1BasedOutputRange
              nChanged = 2140
              Break
            EndIf
            If gbDelayTimeAvailable
              If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nDelayTime <> grMaps\aDev(nDevMapDevPtrOld)\nDelayTime
                nChanged = 2150
                Break
              EndIf
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sDevOutputGainDB <> grMaps\aDev(nDevMapDevPtrOld)\sDevOutputGainDB
              nOutputGainChanged = 2160
              ; do NOT Break ; ??? 5mar2022 WHY 'do not break'?
            EndIf
          EndIf
          If nChanged <> 0
            Break
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for video audio device changes
    ;{
    If nChanged = 0
      If \nMaxVidAudLogicalDev <> grProd\nMaxVidAudLogicalDev
        nChanged = 2405
      Else
        For n = 0 To \nMaxVidAudLogicalDev
          If \aVidAudLogicalDevs(n)\sVidAudLogicalDev <> grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev
            nChanged = 2410
            Break
          EndIf
          If \aVidAudLogicalDevs(n)\nPhysicalDevPtr <> grProd\aVidAudLogicalDevs(n)\nPhysicalDevPtr
            nChanged = 2430
            Break
          EndIf
          If \aVidAudLogicalDevs(n)\bAutoInclude <> grProd\aVidAudLogicalDevs(n)\bAutoInclude
            nChanged = 2450
            Break
          EndIf
          If \aVidAudLogicalDevs(n)\sDfltDBTrim <> grProd\aVidAudLogicalDevs(n)\sDfltDBTrim
            nChanged = 2460
            Break
          EndIf
          If \aVidAudLogicalDevs(n)\sDfltDBLevel <> grProd\aVidAudLogicalDevs(n)\sDfltDBLevel
            nChanged = 2470
            Break
          EndIf
          If \aVidAudLogicalDevs(n)\fDfltPan <> grProd\aVidAudLogicalDevs(n)\fDfltPan
            nChanged = 2480
            Break
          EndIf
          sLogicalDev = grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_AUDIO, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, sLogicalDev)
          ; debugMsg(sProcName, "nDevMapDevPtrNew=" + nDevMapDevPtrNew + ", nDevMapDevPtrOld=" + nDevMapDevPtrOld)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 2510
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 2515
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtrNew + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev + ", grMaps\aDev(" + nDevMapDevPtrOld + ")\sPhysicalDev=" + grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev)
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 2530
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sDevOutputGainDB <> grMaps\aDev(nDevMapDevPtrOld)\sDevOutputGainDB
              nOutputGainChanged = 2560
              ; do NOT Break ; ??? 5mar2022 WHY 'do not break'?
            EndIf
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for video capture device changes
    ;{
    If nChanged = 0
      If \nMaxVidCapLogicalDev <> grProd\nMaxVidCapLogicalDev
        nChanged = 2605
      Else
        For n = 0 To \nMaxVidCapLogicalDev
          If \aVidCapLogicalDevs(n)\sLogicalDev <> grProd\aVidCapLogicalDevs(n)\sLogicalDev
            nChanged = 2610
            Break
          EndIf
          If \aVidCapLogicalDevs(n)\nPhysicalDevPtr <> grProd\aVidCapLogicalDevs(n)\nPhysicalDevPtr
            nChanged = 2630
            Break
          EndIf
          If \aVidCapLogicalDevs(n)\bAutoInclude <> grProd\aVidCapLogicalDevs(n)\bAutoInclude
            nChanged = 2650
            Break
          EndIf
          sLogicalDev = grProd\aVidCapLogicalDevs(n)\sLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_VIDEO_CAPTURE, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_CAPTURE, sLogicalDev)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 2710
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 2715
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 2730
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sVidCapFormat <> grMaps\aDev(nDevMapDevPtrOld)\sVidCapFormat
              nChanged = 2740
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\dVidCapFrameRate <> grMaps\aDev(nDevMapDevPtrOld)\dVidCapFrameRate
              nChanged = 2750
              Break
            EndIf
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for live input device changes
    ;{
    If nChanged = 0
      If \nMaxLiveInputLogicalDev <> grProd\nMaxLiveInputLogicalDev
        nChanged = 3005
      Else
        For n = 0 To \nMaxLiveInputLogicalDev
          If \aLiveInputLogicalDevs(n)\sLogicalDev <> grProd\aLiveInputLogicalDevs(n)\sLogicalDev
            nChanged = 3010
            Break
          EndIf
          sLogicalDev = \aLiveInputLogicalDevs(n)\sLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          If \aLiveInputLogicalDevs(n)\sDfltInputDBLevel <> grProd\aLiveInputLogicalDevs(n)\sDfltInputDBLevel
            nChanged = 3020
            Break
          EndIf
          If \aLiveInputLogicalDevs(n)\bInputForLTC <> grProd\aLiveInputLogicalDevs(n)\bInputForLTC
            nChanged = 3030
            Break
          EndIf
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 3110
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 3115
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 3130
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\s1BasedInputRange <> grMaps\aDev(nDevMapDevPtrOld)\s1BasedInputRange
              nChanged = 3140
              Break
            EndIf
            If gbDelayTimeAvailable
              If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nInputDelayTime <> grMaps\aDev(nDevMapDevPtrOld)\nInputDelayTime
                nChanged = 3150
                Break
              EndIf
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sInputGainDB <> grMaps\aDev(nDevMapDevPtrOld)\sInputGainDB
              nInputGainChanged = 3160
              ; do NOT Break
            EndIf
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for input group changes
    ;{
    If nChanged = 0
      If \nMaxInGrp <> grProd\nMaxInGrp
        nChanged = 3205
      Else
        For n = 0 To \nMaxInGrp
          If \aInGrps(n)\sInGrpName <> grProd\aInGrps(n)\sInGrpName
            nChanged = 3210
            Break
          EndIf
          sInGrpName = grProd\aInGrps(n)\sInGrpName
          If Len(Trim(sInGrpName)) = 0
            Continue
          EndIf
          If \aInGrps(n)\nMaxInGrpItem <> grProd\aInGrps(n)\nMaxInGrpItem
            nChanged = 3215
            Break
          EndIf
          For n2 = 0 To \aInGrps(n)\nMaxInGrpItem
            If \aInGrps(n)\aInGrpItem(n2)\nInGrpItemDevType <> grProd\aInGrps(n)\aInGrpItem(n2)\nInGrpItemDevType
              nChanged = 3220
              Break
            EndIf
            If \aInGrps(n)\aInGrpItem(n2)\nInGrpItemDevType <> #SCS_DEVTYPE_NONE
              If \aInGrps(n)\aInGrpItem(n2)\sInGrpItemLiveInput <> grProd\aInGrps(n)\aInGrpItem(n2)\sInGrpItemLiveInput
                nChanged = 3230
                Break
              EndIf
            EndIf
          Next n2
          If nChanged <> 0
            Break
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for fixture type changes
    ;{
    If nChanged = 0
      If \nMaxFixType <> grProd\nMaxFixType
        nChanged = 3405
      Else
        For n = 0 To \nMaxFixType
          If (n <= ArraySize(\aFixTypes())) And (n <= ArraySize(grProd\aFixTypes()))
            If \aFixTypes(n)\sFixTypeName <> grProd\aFixTypes(n)\sFixTypeName
              nChanged = 3410
              Break
            EndIf
            If \aFixTypes(n)\sFixTypeDesc <> grProd\aFixTypes(n)\sFixTypeDesc
              nChanged = 3412
              Break
            EndIf
            If \aFixTypes(n)\nTotalChans <> grProd\aFixTypes(n)\nTotalChans
              nChanged = 3430
              Break
            EndIf
            For n2 = 0 To \aFixTypes(n)\nTotalChans - 1
              If (n2 <= ArraySize(\aFixTypes(n)\aFixTypeChan())) And (n2 <= ArraySize(grProd\aFixTypes(n)\aFixTypeChan()))
                If \aFixTypes(n)\aFixTypeChan(n2)\sChannelDesc <> grProd\aFixTypes(n)\aFixTypeChan(n2)\sChannelDesc
                  nChanged = 3440
                  Break 2
                EndIf
                If \aFixTypes(n)\aFixTypeChan(n2)\bDimmerChan <> grProd\aFixTypes(n)\aFixTypeChan(n2)\bDimmerChan
                  nChanged = 3442
                  Break 2
                EndIf
                If \aFixTypes(n)\aFixTypeChan(n2)\sDefault <> grProd\aFixTypes(n)\aFixTypeChan(n2)\sDefault
                  nChanged = 3444
                  Break 2
                EndIf
                If \aFixTypes(n)\aFixTypeChan(n2)\nDMXTextColor <> grProd\aFixTypes(n)\aFixTypeChan(n2)\nDMXTextColor
                  nChanged = 3446
                  Break 2
                EndIf
              EndIf
            Next n2
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for lighting device changes
    ;{
    If nChanged = 0
      If \nMaxLightingLogicalDev <> grProd\nMaxLightingLogicalDev
        nChanged = 3505
      Else
        For n = 0 To \nMaxLightingLogicalDev
          If \aLightingLogicalDevs(n)\nDevType <> grProd\aLightingLogicalDevs(n)\nDevType
            nChanged = 3510
            Break
          EndIf
          If \aLightingLogicalDevs(n)\sLogicalDev <> grProd\aLightingLogicalDevs(n)\sLogicalDev
            nChanged = 3520
            Break
          EndIf
          sLogicalDev = grProd\aLightingLogicalDevs(n)\sLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          If \aLightingLogicalDevs(n)\nMaxFixture <> grProd\aLightingLogicalDevs(n)\nMaxFixture
            nChanged = 3530
            Break
          EndIf
          For n2 = 0 To \aLightingLogicalDevs(n)\nMaxFixture
            If \aLightingLogicalDevs(n)\aFixture(n2)\sFixtureCode <> grProd\aLightingLogicalDevs(n)\aFixture(n2)\sFixtureCode
              nChanged = 3550
              Break 2
            EndIf
            If \aLightingLogicalDevs(n)\aFixture(n2)\sFixtureDesc <> grProd\aLightingLogicalDevs(n)\aFixture(n2)\sFixtureDesc
              nChanged = 3555
              Break 2
            EndIf
            If \aLightingLogicalDevs(n)\aFixture(n2)\sFixTypeName <> grProd\aLightingLogicalDevs(n)\aFixture(n2)\sFixTypeName
              nChanged = 3557
              Break 2
            EndIf
            If \aLightingLogicalDevs(n)\aFixture(n2)\sDimmableChannels <> grProd\aLightingLogicalDevs(n)\aFixture(n2)\sDimmableChannels
              nChanged = 3560
              Break 2
            EndIf
          Next n2
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, sLogicalDev)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 3630
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 3640
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 3650
              Break
            EndIf
            Select \aLightingLogicalDevs(n)\nDevType  ; nb already checked for a change of nDevType so no need to separately test nDevType of nDevMapDevPtrOld
              Case #SCS_DEVTYPE_LT_DMX_OUT
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nDMXPort <> grMaps\aDev(nDevMapDevPtrOld)\nDMXPort
                  nChanged = 3660
                  Break
                EndIf
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nMaxDevFixture <> grMaps\aDev(nDevMapDevPtrOld)\nMaxDevFixture
                  nChanged = 3670
                  Break
                EndIf
                For n2 = 0 To \aLightingLogicalDevs(n)\nMaxFixture
                  If (n2 <= ArraySize(grMapsForDevChgs\aDev(nDevMapDevPtrNew)\aDevFixture())) And (n2 <= ArraySize(grMaps\aDev(nDevMapDevPtrOld)\aDevFixture()))
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\aDevFixture(n2)\sDevFixtureCode <> grMaps\aDev(nDevMapDevPtrOld)\aDevFixture(n2)\sDevFixtureCode
                      nChanged = 3672
                      Break 2
                    EndIf
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\aDevFixture(n2)\nDevDMXStartChannel <> grMaps\aDev(nDevMapDevPtrOld)\aDevFixture(n2)\nDevDMXStartChannel
                      nChanged = 3674
                      Break 2
                    EndIf
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\aDevFixture(n2)\sDevDMXStartChannels <> grMaps\aDev(nDevMapDevPtrOld)\aDevFixture(n2)\sDevDMXStartChannels
                      nChanged = 3676
                      Break 2
                    EndIf
                  EndIf
                Next n2
            EndSelect
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nDMXRefreshRate <> grMaps\aDev(nDevMapDevPtrOld)\nDMXRefreshRate
              nChanged = 3680
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nDMXPort <> grMaps\aDev(nDevMapDevPtrOld)\nDMXPort
              nChanged = 3682
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sDMXIpAddress <> grMaps\aDev(nDevMapDevPtrOld)\sDMXIpAddress
              nChanged = 3684
            EndIf
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for ctrl send device changes
    ;{
    If nChanged = 0
      If \nMaxCtrlSendLogicalDev <> grProd\nMaxCtrlSendLogicalDev
        nChanged = 4002
      Else
        For n = 0 To \nMaxCtrlSendLogicalDev
          If \nMaxCtrlSendLogicalDev <> grProd\nMaxCtrlSendLogicalDev
            nChanged = 4005
            Break
          EndIf
          If \aCtrlSendLogicalDevs(n)\nDevType <> grProd\aCtrlSendLogicalDevs(n)\nDevType
            nChanged = 4010
            Break
          EndIf
          If \aCtrlSendLogicalDevs(n)\sLogicalDev <> grProd\aCtrlSendLogicalDevs(n)\sLogicalDev
            nChanged = 4020
            Break
          EndIf
          If \aCtrlSendLogicalDevs(n)\bM2TSkipEarlierCtrlMsgs <> grProd\aCtrlSendLogicalDevs(n)\bM2TSkipEarlierCtrlMsgs
            nChanged = 4025
            Break
          EndIf
          sLogicalDev = grProd\aCtrlSendLogicalDevs(n)\sLogicalDev
          If Len(Trim(sLogicalDev)) = 0
            Continue
          EndIf
          Select \aCtrlSendLogicalDevs(n)\nDevType
            Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
              If \aCtrlSendLogicalDevs(n)\bCtrlMidiForMTC <> grProd\aCtrlSendLogicalDevs(n)\bCtrlMidiForMTC
                nChanged = 4030
                Break
              EndIf
          EndSelect
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CTRL_SEND, sLogicalDev)
          If nDevMapDevPtrNew <> nDevMapDevPtrOld
            nChanged = 4110
            Break
          EndIf
          If nDevMapDevPtrNew < 0 ; And sLogicalDev
            nChanged = 4115
            Break
          EndIf
          If nDevMapDevPtrNew >= 0
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 4130
              Break
            EndIf
            Select \aCtrlSendLogicalDevs(n)\nDevType  ; nb already checked for a change of nDevType so no need to separately test nDevType of nDevMapDevPtrOld
              Case #SCS_DEVTYPE_CS_RS232_OUT
                If \aCtrlSendLogicalDevs(n)\nRS232DataBits <> grProd\aCtrlSendLogicalDevs(n)\nRS232DataBits
                  nChanged = 4210
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\fRS232StopBits <> grProd\aCtrlSendLogicalDevs(n)\fRS232StopBits
                  nChanged = 4220
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nRS232Parity <> grProd\aCtrlSendLogicalDevs(n)\nRS232Parity
                  nChanged = 4230
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nRS232BaudRate <> grProd\aCtrlSendLogicalDevs(n)\nRS232BaudRate
                  nChanged = 4240
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nRS232Handshaking <> grProd\aCtrlSendLogicalDevs(n)\nRS232Handshaking
                  nChanged = 4250
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nRS232RTSEnable <> grProd\aCtrlSendLogicalDevs(n)\nRS232RTSEnable
                  nChanged = 4260
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nRS232DTREnable <> grProd\aCtrlSendLogicalDevs(n)\nRS232DTREnable
                  nChanged = 4270
                  Break
                EndIf
                
              Case #SCS_DEVTYPE_CS_MIDI_OUT
                ; MIDI Out Port (sPhysicalDev) already checked
                If \aCtrlSendLogicalDevs(n)\sCtrlMidiRemoteDevCode <> grProd\aCtrlSendLogicalDevs(n)\sCtrlMidiRemoteDevCode
                  nChanged = 4280
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nCtrlMidiChannel <> grProd\aCtrlSendLogicalDevs(n)\nCtrlMidiChannel
                  nChanged = 4282
                  Break
                EndIf
                
              Case #SCS_DEVTYPE_CS_MIDI_THRU
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sMidiThruInPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sMidiThruInPhysicalDev
                  nChanged = 4310
                  Break
                EndIf
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\bMidiThruInDummy <> grMaps\aDev(nDevMapDevPtrOld)\bMidiThruInDummy
                  nChanged = 4320
                  Break
                EndIf
                
              Case #SCS_DEVTYPE_CS_NETWORK_OUT
                If \aCtrlSendLogicalDevs(n)\nOSCVersion <> grProd\aCtrlSendLogicalDevs(n)\nOSCVersion
                  nChanged = 4405
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nNetworkProtocol <> grProd\aCtrlSendLogicalDevs(n)\nNetworkProtocol
                  nChanged = 4410
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nNetworkRole <> grProd\aCtrlSendLogicalDevs(n)\nNetworkRole
                  nChanged = 4415
                  Break
                EndIf
                Select \aCtrlSendLogicalDevs(n)\nNetworkRole
                  Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sRemoteHost <> grMaps\aDev(nDevMapDevPtrOld)\sRemoteHost
                      nChanged = 4420
                      Break
                    EndIf
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nRemotePort <> grMaps\aDev(nDevMapDevPtrOld)\nRemotePort
                      nChanged = 4421
                      Break
                    EndIf
                  Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nLocalPort <> grMaps\aDev(nDevMapDevPtrOld)\nLocalPort
                      nChanged = 4430
                      Break
                    EndIf
                EndSelect
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nCtrlSendDelay <> grMaps\aDev(nDevMapDevPtrOld)\nCtrlSendDelay
                  nChanged = 4440
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\nCtrlNetworkRemoteDev <> grProd\aCtrlSendLogicalDevs(n)\nCtrlNetworkRemoteDev
                  nChanged = 4450
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\bReplyMsgAddCR <> grProd\aCtrlSendLogicalDevs(n)\bReplyMsgAddCR
                  nChanged = 4451
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\bReplyMsgAddLF <> grProd\aCtrlSendLogicalDevs(n)\bReplyMsgAddLF
                  nChanged = 4452
                  Break
                EndIf
                For m = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
                  If \aCtrlSendLogicalDevs(n)\aMsgResponse[m]\sReceiveMsg <> grProd\aCtrlSendLogicalDevs(n)\aMsgResponse[m]\sReceiveMsg
                    nChanged = 4453
                    Break
                  EndIf
                  If \aCtrlSendLogicalDevs(n)\aMsgResponse[m]\nMsgAction <> grProd\aCtrlSendLogicalDevs(n)\aMsgResponse[m]\nMsgAction
                    nChanged = 4454
                    Break
                  EndIf
                  If \aCtrlSendLogicalDevs(n)\aMsgResponse[m]\sReplyMsg <> grProd\aCtrlSendLogicalDevs(n)\aMsgResponse[m]\sReplyMsg
                    nChanged = 4455
                    Break
                  EndIf
                Next m
                If \aCtrlSendLogicalDevs(n)\nDelayBeforeReloadNames <> grProd\aCtrlSendLogicalDevs(n)\nDelayBeforeReloadNames
                  nChanged = 4456
                  Break
                EndIf
                If \aCtrlSendLogicalDevs(n)\sCtrlNetworkRemoteDevPassword <> grProd\aCtrlSendLogicalDevs(n)\sCtrlNetworkRemoteDevPassword
                  nChanged = 4457
                  Break
                EndIf
                ; Added 19Sep2022 11.9.6
                If grProdForDevChgs\aCtrlSendLogicalDevs(n)\bConnectWhenReqd <> grProd\aCtrlSendLogicalDevs(n)\bConnectWhenReqd
                  nChanged = 4458
                  Break
                EndIf
                ; End added 19Sep2022 11.9.6
                ; Added 7May2024 11.10.2cn
                If grProdForDevChgs\aCtrlSendLogicalDevs(n)\bGetRemDevScribbleStripNames <> grProd\aCtrlSendLogicalDevs(n)\bGetRemDevScribbleStripNames
                  nChanged = 4459
                  Break
                EndIf
                ; End added 7May2024 11.10.2cn
                
              Case #SCS_DEVTYPE_LT_DMX_OUT
                
              Case #SCS_DEVTYPE_CS_HTTP_REQUEST
                If \aCtrlSendLogicalDevs(n)\sHTTPStart <> grProd\aCtrlSendLogicalDevs(n)\sHTTPStart
                  nChanged = 4710
                  Break
                EndIf
                
            EndSelect
          EndIf
        Next n
      EndIf
    EndIf
    ;}
    
    ; INFO: check for cue control device changes
    ;{
    If nChanged = 0
      If \nMaxCueCtrlLogicalDev <> grProd\nMaxCueCtrlLogicalDev
        nChanged = 5005
      Else
        For n = 0 To \nMaxCueCtrlLogicalDev
          sLogicalDev = buildCueCtrlLogicalDev(n)  ; pseudo dev name
          nDevMapDevPtrNew = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
          nDevMapDevPtrOld = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
          If nDevMapDevPtrOld = -1 And nDevMapDevPtrNew >= 0
            ; device has been added
            nChanged = 5010
            Break
          EndIf
          If nDevMapDevPtrOld >= 0 And nDevMapDevPtrNew = -1
            ; device has been removed
            nChanged = 5020
            Break
          EndIf
          
          If nDevMapDevPtrNew >= 0 And nDevMapDevPtrOld >= 0
            If \aCueCtrlLogicalDevs(n)\nDevType <> grProd\aCueCtrlLogicalDevs(n)\nDevType
              nChanged = 5110
              Break
            EndIf
            If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sPhysicalDev <> grMaps\aDev(nDevMapDevPtrOld)\sPhysicalDev
              nChanged = 5130
              Break
            EndIf
            Select \aCueCtrlLogicalDevs(n)\nDevType  ; nb already checked for a change of nDevType so no need to separately test nDevType of nDevMapDevPtrOld
              Case #SCS_DEVTYPE_CC_RS232_IN
                If \aCueCtrlLogicalDevs(n)\nRS232DataBits <> grProd\aCueCtrlLogicalDevs(n)\nRS232DataBits
                  nChanged = 5210
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\fRS232StopBits <> grProd\aCueCtrlLogicalDevs(n)\fRS232StopBits
                  nChanged = 5220
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nRS232Parity <> grProd\aCueCtrlLogicalDevs(n)\nRS232Parity
                  nChanged = 5230
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nRS232BaudRate <> grProd\aCueCtrlLogicalDevs(n)\nRS232BaudRate
                  nChanged = 5240
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nRS232Handshaking <> grProd\aCueCtrlLogicalDevs(n)\nRS232Handshaking
                  nChanged = 5250
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nRS232RTSEnable <> grProd\aCueCtrlLogicalDevs(n)\nRS232RTSEnable
                  nChanged = 5260
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nRS232DTREnable <> grProd\aCueCtrlLogicalDevs(n)\nRS232DTREnable
                  nChanged = 5270
                  Break
                EndIf
                
              Case #SCS_DEVTYPE_CC_MIDI_IN
                ; MIDI In Port (sPhysicalDev) already checked
                If \aCueCtrlLogicalDevs(n)\nCtrlMethod <> grProd\aCueCtrlLogicalDevs(n)\nCtrlMethod
                  nChanged = 5310
                  Break
                EndIf
                Select \aCueCtrlLogicalDevs(n)\nCtrlMethod
                  Case #SCS_CTRLMETHOD_NONE
                    ; no action
                  Case #SCS_CTRLMETHOD_MTC
                    ; no action
                  Case #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
                    If \aCueCtrlLogicalDevs(n)\nMscMmcMidiDevId <> grProd\aCueCtrlLogicalDevs(n)\nMscMmcMidiDevId
                      nChanged = 5320
                      Break
                    EndIf
                    If \aCueCtrlLogicalDevs(n)\nMscCommandFormat <> grProd\aCueCtrlLogicalDevs(n)\nMscCommandFormat
                      nChanged = 5323
                      Break
                    EndIf
                    If \aCueCtrlLogicalDevs(n)\nCtrlMethod = #SCS_CTRLMETHOD_MSC
                      If \aCueCtrlLogicalDevs(n)\nGoMacro <> grProd\aCueCtrlLogicalDevs(n)\nGoMacro
                        nChanged = 5326
                        Break
                      EndIf
                    EndIf
                    If \aCueCtrlLogicalDevs(n)\nCtrlMethod = #SCS_CTRLMETHOD_MMC
                      If \aCueCtrlLogicalDevs(n)\bMMCApplyFadeForStop <> grProd\aCueCtrlLogicalDevs(n)\bMMCApplyFadeForStop
                        nChanged = 5327
                        Break
                      EndIf
                    EndIf
                  Default
                    If \aCueCtrlLogicalDevs(n)\nMidiChannel <> grProd\aCueCtrlLogicalDevs(n)\nMidiChannel
                      nChanged = 5330
                      Break
                    EndIf
                    For n2 = 0 To gnMaxMidiCommand
                      If \aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nCmd <> grProd\aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nCmd
                        nChanged = 534000 + n2
                        Break
                      EndIf
                      If \aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nCmd > 0
                        If \aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nCC <> grProd\aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nCC
                          nChanged = 534100 + n2
                          Break
                        EndIf
                        If \aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nVV <> grProd\aCueCtrlLogicalDevs(n)\aMidiCommand[n2]\nVV
                          nChanged = 534200 + n2
                          Break
                        EndIf
                      EndIf
                    Next n2
                EndSelect
                
              Case #SCS_DEVTYPE_CC_NETWORK_IN
                If \aCueCtrlLogicalDevs(n)\nNetworkProtocol <> grProd\aCueCtrlLogicalDevs(n)\nNetworkProtocol
                  nChanged = 5410
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nNetworkRole <> grProd\aCueCtrlLogicalDevs(n)\nNetworkRole
                  nChanged = 5415
                  Break
                EndIf
                Select \aCueCtrlLogicalDevs(n)\nNetworkRole
                  Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\sRemoteHost <> grMaps\aDev(nDevMapDevPtrOld)\sRemoteHost
                      nChanged = 5420
                      Break
                    EndIf
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nRemotePort <> grMaps\aDev(nDevMapDevPtrOld)\nRemotePort
                      nChanged = 5430
                      Break
                    EndIf
                  Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
                    If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nLocalPort <> grMaps\aDev(nDevMapDevPtrOld)\nLocalPort
                      nChanged = 5440
                      Break
                    EndIf
                EndSelect
                If \aCueCtrlLogicalDevs(n)\nCueNetworkRemoteDev <> grProd\aCueCtrlLogicalDevs(n)\nCueNetworkRemoteDev
                  nChanged = 5450
                  Break
                EndIf
                Select \aCueCtrlLogicalDevs(n)\nCueNetworkRemoteDev
                  Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                    For n2 = 0 To #SCS_MAX_X32_COMMAND
                      If \aCueCtrlLogicalDevs(n)\aX32Command[n2]\nX32Button <> grProd\aCueCtrlLogicalDevs(n)\aX32Command[n2]\nX32Button
                        nChanged = 546000 + n2
                        Break
                      EndIf
                    Next n2
                  Default
                    If \aCueCtrlLogicalDevs(n)\nNetworkMsgFormat <> grProd\aCueCtrlLogicalDevs(n)\nNetworkMsgFormat
                      nChanged = 5470
                      Break
                    EndIf
                EndSelect
                
              Case #SCS_DEVTYPE_CC_DMX_IN
                ; DMX In Port (sPhysicalDev) already checked
                If grMapsForDevChgs\aDev(nDevMapDevPtrNew)\nDMXPort <> grMaps\aDev(nDevMapDevPtrOld)\nDMXPort
                  nChanged = 5605
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nDMXInPref <> grProd\aCueCtrlLogicalDevs(n)\nDMXInPref
                  nChanged = 5610
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nDMXTrgCtrl <> grProd\aCueCtrlLogicalDevs(n)\nDMXTrgCtrl
                  nChanged = 5620
                  Break
                EndIf
                If \aCueCtrlLogicalDevs(n)\nDMXTrgValue <> grProd\aCueCtrlLogicalDevs(n)\nDMXTrgValue
                  nChanged = 5630
                  Break
                EndIf
                For n2 = 0 To #SCS_MAX_DMX_COMMAND
                  If \aCueCtrlLogicalDevs(n)\aDMXCommand[n2]\nChannel <> grProd\aCueCtrlLogicalDevs(n)\aDMXCommand[n2]\nChannel
                    nChanged = 564000 + n2
                    Break
                  EndIf
                Next n2
                
            EndSelect
          EndIf
          
        Next n
        
      EndIf
    EndIf
    ;}
    
    If nChanged = 0
      ; debugMsg(sProcName, "calling ED_checkDevMapForDevChgs(" + getDevChgsDevMapName(\nSelectedDevMapPtr) + ")")
      nCheckDevMapResult = ED_checkDevMapForDevChgs(\nSelectedDevMapPtr)
      ; debugMsg(sProcName, "ED_checkDevMapForDevChgs(" + \nSelectedDevMapPtr + ") returned " + nCheckDevMapResult)
      If (nCheckDevMapResult < 0) And (gsCheckDevMapMsg)
        nChanged = 9000
      EndIf
    EndIf
  EndWith

  If nChanged <= 0
    gbProdDevChgs = #False
  Else
    gbProdDevChgs = #True
    WEP_CheckForDMXPortDuplication(#SCS_WEP_DMX_CONFLICT_STATUSBAR)
    debugMsg(sProcName, "nChanged=" + nChanged + ", n=" + n + ", n2=" + n2)
  EndIf
  
  If nOutputGainChanged <= 0
    gbProdDevOutputGainChgs = #False
  Else
    gbProdDevOutputGainChgs = #True
    debugMsg(sProcName, "nOutputGainChanged=" + nOutputGainChanged + ", n=" + n)
  EndIf
  If nInputGainChanged <= 0
    gbProdDevInputGainChgs = #False
  Else
    gbProdDevInputGainChgs = #True
    debugMsg(sProcName, "nInputGainChanged=" + nInputGainChanged + ", n=" + n)
  EndIf
  
  If gbEditProdFormLoaded
    ; Should be #True
    If (nChanged <= 0) And (nOutputGainChanged <= 0) And (nInputGainChanged <= 0)
      setEnabled(WEP\btnApplyDevChgs, #False)
      setEnabled(WEP\btnUndoDevChgs, #False)
    Else
      setEnabled(WEP\btnApplyDevChgs, #True)
      setEnabled(WEP\btnUndoDevChgs, #True)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_setRetryActivateBtn()
  PROCNAMEC()
  Protected nInactive ; will be set to the device group of the first inactive device found
  Protected n
  Protected nDevMapPtr, nDevMapDevPtr
  Protected sLogicalDev.s, sDevInfo.s
  Protected sDevNotActiveMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grProdForDevChgs
    nDevMapPtr = \nSelectedDevMapPtr
    If nDevMapPtr < 0
      ProcedureReturn
    EndIf
    
    ; check for inactive audio output devices
    For n = 0 To \nMaxAudioLogicalDev
      sLogicalDev = \aAudioLogicalDevs(n)\sLogicalDev
      If Len(Trim(sLogicalDev)) = 0
        Continue
      EndIf
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
      If nDevMapDevPtr >= 0
        If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_INACTIVE) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False)
          sDevInfo = sLogicalDev + " (" + grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev + " " + grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange + ")"
          nInactive = #SCS_DEVGRP_AUDIO_OUTPUT
          sDevNotActiveMsg + LangPars("DevMap", "DevNotActive", decodeDevGrp(#SCS_DEVGRP_AUDIO_OUTPUT), sDevInfo) + #LF$
        EndIf
      EndIf
    Next n
    
    ; check for inactive live input devices
    If nInactive = 0
      For n = 0 To \nMaxLiveInputLogicalDev
        sLogicalDev = \aLiveInputLogicalDevs(n)\sLogicalDev
        If Len(Trim(sLogicalDev)) = 0
          Continue
        EndIf
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
        If nDevMapDevPtr >= 0
          If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_INACTIVE) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False)
            nInactive = #SCS_DEVGRP_LIVE_INPUT
            sDevNotActiveMsg + LangPars("DevMap", "DevNotActive", decodeDevGrp(#SCS_DEVGRP_LIVE_INPUT), sLogicalDev) + #LF$
          EndIf
        EndIf
      Next n
    EndIf
    
    ; check for inactive lighting devices
    If nInactive = 0
      For n = 0 To \nMaxLightingLogicalDev
        sLogicalDev = \aLightingLogicalDevs(n)\sLogicalDev
        If Len(Trim(sLogicalDev)) = 0
          Continue
        EndIf
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, sLogicalDev)
        If nDevMapDevPtr >= 0
          If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_INACTIVE) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False)
            nInactive = #SCS_DEVGRP_LIGHTING
            sDevNotActiveMsg + LangPars("DevMap", "DevNotActive", decodeDevGrp(#SCS_DEVGRP_LIGHTING), sLogicalDev) + #LF$
          EndIf
        EndIf
      Next n
    EndIf
    
    ; check for inactive ctrl send devices
    If nInactive = 0
      For n = 0 To \nMaxCtrlSendLogicalDev
        sLogicalDev = \aCtrlSendLogicalDevs(n)\sLogicalDev
        If Len(Trim(sLogicalDev)) = 0
          Continue
        EndIf
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, sLogicalDev)
        If nDevMapDevPtr >= 0
          If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_INACTIVE) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False)
            nInactive = #SCS_DEVGRP_CTRL_SEND
            sDevNotActiveMsg + LangPars("DevMap", "DevNotActive", decodeDevGrp(#SCS_DEVGRP_CTRL_SEND), sLogicalDev) + #LF$
          EndIf
        EndIf
      Next n
    EndIf
    
    ; check for inactive cue ctrl devices
    If nInactive = 0
      ; debugMsg0(sProcName, "grProdForDevChgs\nMaxCueCtrlLogicalDev=" + \nMaxCueCtrlLogicalDev)
      For n = 0 To \nMaxCueCtrlLogicalDev
        ; debugMsg0(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + n + ")\sCueCtrlLogicalDev=" + \aCueCtrlLogicalDevs(n)\sCueCtrlLogicalDev + ", \nDevType=" + decodeDevType(\aCueCtrlLogicalDevs(n)\nDevType))
        If \aCueCtrlLogicalDevs(n)\nDevType <> #SCS_DEVTYPE_NONE
          sLogicalDev = \aCueCtrlLogicalDevs(n)\sCueCtrlLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
          If nDevMapDevPtr >= 0
            If (grMapsForDevChgs\aDev(nDevMapDevPtr)\nDevState = #SCS_DEVSTATE_INACTIVE) And (grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun = #False)
              nInactive = #SCS_DEVGRP_CUE_CTRL
              sDevNotActiveMsg + LangPars("DevMap", "DevNotActive", decodeDevGrp(#SCS_DEVGRP_CUE_CTRL), sLogicalDev) + #LF$
            EndIf
          EndIf
        EndIf
      Next n
    EndIf
  EndWith
  
  If nInactive > 0
    debugMsg(sProcName, "nInactive=" + decodeDevGrp(nInactive) + ", sDevNotActiveMsg=" + sDevNotActiveMsg)
  EndIf
  
  If gbEditProdFormLoaded
    If nInactive <= 0
      setEnabled(WEP\btnRetryActivate, #False)
    Else
      setEnabled(WEP\btnRetryActivate, #True)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_btnRetryActivate_Click()
  PROCNAMEC()
  Protected sMsg.s, sTitle.s
  
  debugMsg(sProcName, #SCS_START)
  
  sTitle = GGT(WEP\btnRetryActivate)  ; use button text as title for MessageRequester()
  
  If ED_checkDevMapForDevChgs(grProdForDevChgs\nSelectedDevMapPtr) = 0
    sMsg = Lang("WEP", "RetrySuccessful")
  Else
    sMsg = gsCheckDevMapMsg
  EndIf
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns()")
  WEP_setDevChgsBtns()
  debugMsg(sProcName, "calling WEP_setRetryActivateBtn()")
  WEP_setRetryActivateBtn()
  debugMsg(sProcName, "calling WEP_refreshCurrentTabPhysInfo()")
  WEP_refreshCurrentTabPhysInfo()
  
  debugMsg(sProcName, sMsg)
  scsMessageRequester(sTitle, sMsg)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_valDisplayedDev()
  PROCNAMEC()
  Protected bResult = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWEP
    Select \nDisplayedDevTab
      Case #SCS_PROD_TAB_CTRL_DEVS
        ; debugMsg(sProcName, "grWEP\nDisplayedDevTab=#SCS_PROD_TAB_CTRL_DEVS, \nCurrentCtrlDevType=" + decodeDevType(\nCurrentCtrlDevType))
        Select \nCurrentCtrlDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU, #SCS_DEVTYPE_CS_HTTP_REQUEST
            ; no validation
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            debugMsg(sProcName, "calling WEP_valNetworkDev(0, " + \nCurrentCtrlDevNo + ", " + \nCurrentCtrlDevMapDevPtr + ")")
            bResult = WEP_valNetworkDev(0, \nCurrentCtrlDevNo, \nCurrentCtrlDevMapDevPtr)
            
          Case #SCS_DEVTYPE_CS_RS232_OUT
            debugMsg(sProcName, "calling WEP_validateCueCtrlTabForRS232Devs()")
            bResult = WEP_validateCueCtrlTabForRS232Devs()
            
        EndSelect
        
      Case #SCS_PROD_TAB_CUE_DEVS
        ; debugMsg(sProcName, "grWEP\nDisplayedDevTab=#SCS_PROD_TAB_CUE_DEVS, \nCurrentCueDevType=" + decodeDevType(\nCurrentCueDevType))
        Select \nCurrentCueDevType
          Case #SCS_DEVTYPE_CC_DMX_IN
            debugMsg(sProcName, "calling WEP_valDMXDev(1, " + \nCurrentCueDevNo + ", " + \nCurrentCueDevMapDevPtr + ")")
            bResult = WEP_valDMXDev(1, \nCurrentCueDevNo, \nCurrentCueDevMapDevPtr)
            If bResult
              debugMsg(sProcName, "calling WEP_validateCueCtrlTabForDMXDevs()")
              bResult = WEP_validateCueCtrlTabForDMXDevs()
            EndIf
            
          Case #SCS_DEVTYPE_CC_MIDI_IN
            debugMsg(sProcName, "calling WEP_valMidiDev(1, " + \nCurrentCueDevNo + ", " + \nCurrentCueDevMapDevPtr + ")")
            bResult = WEP_valMidiDev(1, \nCurrentCueDevNo, \nCurrentCueDevMapDevPtr)
            
          Case #SCS_DEVTYPE_CC_NETWORK_IN
            debugMsg(sProcName, "calling WEP_valNetworkDev(1, " + \nCurrentCueDevNo + ", " + \nCurrentCueDevMapDevPtr + ")")
            bResult = WEP_valNetworkDev(1, \nCurrentCueDevNo, \nCurrentCueDevMapDevPtr)
            
          Case #SCS_DEVTYPE_CC_RS232_IN
            debugMsg(sProcName, "calling WEP_validateCueCtrlTabForRS232Devs()")
            bResult = WEP_validateCueCtrlTabForRS232Devs()
            
        EndSelect
        
      Default
        debugMsg(sProcName, "grWEP\nDisplayedDevTab=" + \nDisplayedDevTab)
        
    EndSelect
  EndWith
  
  If bResult = #False
    debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  EndIf
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_valMidiDev(Index, nDevNo, nDevMapDevPtr)
  PROCNAMEC()
  Protected bResult = #True
  Protected bDuplicatesError, sErrorMsg.s, sParam1.s, sParam2.s
  Protected nDuplicatesResult
  Protected nThisCmd, nThisCC, nThisVV
  Protected n
  Protected nFocusGadget
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  If (nDevNo < 0) Or (nDevMapDevPtr < 0)
    ProcedureReturn #True
  EndIf
  
  While #True
    If Index = 0
      ; no validation
      
    Else  ; Index = 1
      With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
        If \nDevType <> #SCS_DEVTYPE_CC_MIDI_IN
          Break
        EndIf
        If grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = -1
          sErrorMsg = MustBeSelected(WEP\lblMidiInPort)
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_NONE
          sErrorMsg = MustBeSelected(WEP\lblCtrlMethod)
          nFocusGadget = WEP\cboCtrlMethod
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_MSC And \nMscMmcMidiDevId = -1
          sErrorMsg = LangPars("MIDI", "DevIdReqd", "MSC")   ; "The Device Id must be selected for MSC messages"
          nFocusGadget = WEP\cboMidiDevId
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_MMC And \nMscMmcMidiDevId = -1
          sErrorMsg = LangPars("MIDI", "DevIdReqd", "MMC")   ; "The Device Id must be selected for MMC messages"
          nFocusGadget = WEP\cboMidiDevId
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_MSC And \nMscCommandFormat = -1
          sErrorMsg = LangPars("MIDI", "CmdFmtReqd", "MSC") ; "The MSC Command Format must be selected for MSC messages"
          nFocusGadget = WEP\cboMSCCommandFormat
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_MSC And \nGoMacro < 0
          sErrorMsg = LangPars("MIDI", "GoMacroReqd", "MSC") ; "The Go Macro must be selected for MSC messages (even if you do not intend to use the Fire command)"
          nFocusGadget = WEP\cboGoMacro
          bResult = #False
          Break
        EndIf
        If \nCtrlMethod = #SCS_CTRLMETHOD_MSC And \nGoMacro > 127
          sErrorMsg = LangPars("MIDI", "GoMacroRange", "MSC") ; "The Go Macro must be <= 127 for MSC messages (even if you do not intend to use the Fire command)"
          nFocusGadget = WEP\cboGoMacro
          bResult = #False
          Break
        EndIf
        
        Select \nCtrlMethod
          Case #SCS_CTRLMETHOD_MTC, #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
            ; no action
          Default
            If \nMidiChannel <= 0
              sErrorMsg = MustBeSelected(WEP\lblMidiChannel)
              nFocusGadget = WEP\cboMidiChannel
              bResult = #False
              Break
            EndIf
        EndSelect
        
        Select \nCtrlMethod
          Case #SCS_CTRLMETHOD_MTC, #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
            ; no action
            
          Default
            For n = 0 To gnMaxMidiCommand
              nThisCmd = \aMidiCommand[n]\nCmd
              nThisCC = \aMidiCommand[n]\nCC
              nThisVV = \aMidiCommand[n]\nVV
              If nThisCmd > 0
                If n > #SCS_MIDI_LAST_SCS_CUE_RELATED
                  If n = #SCS_MIDI_EXT_FADER
                    If nThisCmd = $B
                      If nThisVV = -1
                        sParam1 = GGT(WEP\lblThresholdVV)
                        sParam2 = midiCmdDescrForCmdNo(n)
                        sErrorMsg = LangPars("Errors", "MustBeSelectedFor", sParam1, sParam2)
                        bResult = #False
                        Break
                      EndIf
                    EndIf
                  ElseIf nThisCmd = $E ; pitch bend ; Added 3Jan2025 11.10.6ce
                    Select n
                      Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER, #SCS_MIDI_DMX_MASTER
                        ; cc not required
                        Break
                      Default
                        ; controller change requires value
                        If nThisCC = -1
                          sParam1 = midiCCAbbrForCmd(nThisCmd, n) + " (" + LCase(midiCCDescrForCmd(nThisCmd)) + ")"
                          sParam2 = midiCmdDescrForCmdNo(n)
                          sErrorMsg = LangPars("Errors", "MustBeSelectedFor", sParam1, sParam2)
                          ; sErrorMsg = midiCCAbbrForCmd(nThisCmd, n) + " (" + LCase(midiCCDescrForCmd(nThisCmd)) + ") must be selected for " + midiCmdDescrForCmdNo(n)
                          bResult = #False
                          Break
                        EndIf
                    EndSelect
                  Else
                    ; controller change requires value
                    If nThisCC = -1
                      sParam1 = midiCCAbbrForCmd(nThisCmd, n) + " (" + LCase(midiCCDescrForCmd(nThisCmd)) + ")"
                      sParam2 = midiCmdDescrForCmdNo(n)
                      sErrorMsg = LangPars("Errors", "MustBeSelectedFor", sParam1, sParam2)
                      ; sErrorMsg = midiCCAbbrForCmd(nThisCmd, n) + " (" + LCase(midiCCDescrForCmd(nThisCmd)) + ") must be selected for " + midiCmdDescrForCmdNo(n)
                      bResult = #False
                      Break
                    EndIf
                    If (nThisCmd = $B)
                      Select n
                        Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_OPEN_FAV_FILE, #SCS_MIDI_SET_HOTKEY_BANK,
                             #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER,
                             #SCS_MIDI_DMX_MASTER, #SCS_MIDI_CUE_MARKER_PREV, #SCS_MIDI_CUE_MARKER_NEXT
                          ; vv not required
                        Default
                          ; controller change requires value
                          If nThisVV = -1
                            sParam1 = midiVVAbbrForCmd(nThisCmd) + " (" + LCase(midiVVDescrForCmd(nThisCmd)) + ")"
                            sParam2 = midiCmdDescrForCmdNo(n)
                            sErrorMsg = LangPars("Errors", "MustBeSelectedFor", sParam1, sParam2)
                            ; sErrorMsg = midiVVAbbrForCmd(nThisCmd) + " (" + LCase(midiVVDescrForCmd(nThisCmd)) + ") must be selected for " + midiCmdDescrForCmdNo(n)
                            bResult = #False
                            Break
                          EndIf
                      EndSelect
                    EndIf
                  EndIf
                EndIf ; EndIf n > #SCS_MIDI_LAST_SCS_CUE_RELATED
              EndIf ; EndIf nThisCmd > 0
            Next n
            
            If bResult
              debugMsg(sProcName, "calling WEP_checkForMidiDuplicates(True, ...)")
              nDuplicatesResult = WEP_checkForMidiDuplicates(#True)
              If nDuplicatesResult = 2
                sErrorMsg = grWEP\sErrorMsg
                bResult = #False
              EndIf
            EndIf
            
        EndSelect
        
      EndWith
      
    EndIf
    
    If bResult
      debugMsg(sProcName, "calling checkMTCLTCIntegrity(@grProdForDevChgs)")
      sErrorMsg = checkMTCLTCIntegrity(@grProdForDevChgs)
      If sErrorMsg
        bResult = #False
      EndIf
    EndIf
    
    Break
  Wend
  
  If bResult = #False
    ; move focus away from current gadget BEFORE calling MessageRequester() or error may get reported twice
    If IsGadget(nFocusGadget)
      SAG(nFocusGadget)
    Else
      SAG(-1)
    EndIf
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_valDMXDev(Index, nDevNo, nDevMapDevPtr)
  PROCNAMEC()
  Protected bResult = #True
  Protected sErrorMsg.s
  Protected nFocusGadget
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  If (nDevNo < 0) Or (nDevMapDevPtr < 0)
    ProcedureReturn #True
  EndIf
  
  While #True
    If Index = 0
      ; lighting device
      With grProdForDevChgs\aLightingLogicalDevs(nDevNo)
        ; debugMsg(sProcName, "grProdForDevChgs\aLightingLogicalDevs(" + nDevNo + ")\nDevType=" + decodeDevType(\nDevType))
        If \nDevType <> #SCS_DEVTYPE_LT_DMX_OUT
          Break
        EndIf
        ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr)
        If grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = -1
          sErrorMsg = "Lighting device:" + MustBeSelected(WEP\lblDMXPhysDev[Index])
          bResult = #False
          Break
        EndIf
      EndWith
      
    Else  ; Index = 1
      ; cue control device
      With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
        If \nDevType <> #SCS_DEVTYPE_CC_DMX_IN
          Break
        EndIf
        If grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr = -1
          sErrorMsg = "Cue control device: " + MustBeSelected(WEP\lblDMXPhysDev[Index])
          bResult = #False
          Break
        EndIf
        If (\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]\nChannel >= 0) Or (\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]\nChannel >= 0)
          ; at least one of these fields has been entered
          If (\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]\nChannel < 0)
            sErrorMsg = LangPars("Errors", "MustBeEnteredIf", GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]), GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]))
            nFocusGadget = WEP\txtDMXChannel[#SCS_DMX_PLAY_DMX_CUE_0]
            bResult = #False
          ElseIf (\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]\nChannel < 0)
            sErrorMsg = LangPars("Errors", "MustBeEnteredIf", GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]), GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]))
            nFocusGadget = WEP\txtDMXChannel[#SCS_DMX_PLAY_DMX_CUE_MAX]
            bResult = #False
          ElseIf (\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]\nChannel < \aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]\nChannel)
            sErrorMsg = LangPars("Errors", "MustBeGreaterOrEqual", GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]), GGT(WEP\lblDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]))
            bResult = #False
            nFocusGadget = WEP\txtDMXChannel[#SCS_DMX_PLAY_DMX_CUE_MAX]
          EndIf
        EndIf
      EndWith
    EndIf
    Break
  Wend
  
  If bResult = #False
    ; move focus away from current gadget BEFORE calling MessageRequester() or error may get reported twice
    If IsGadget(nFocusGadget)
      SAG(nFocusGadget)
    Else
      SAG(-1)
    EndIf
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult

EndProcedure

Procedure WEP_valNetworkDev(Index, nDevNo, nDevMapDevPtr)
  PROCNAMEC()
  Protected bResult = #True
  Protected sErrorMsg.s
  Protected nFocusGadget
  Protected nNetworkRole, sRemoteHost.s, nRemotePort, nLocalPort
  Protected bDummy
  Protected n
  Protected nDevType, sLogicalDev.s
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nDevNo=" + nDevNo + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  If (nDevNo < 0) Or (nDevMapDevPtr < 0)
    ProcedureReturn #True
  EndIf
  
  While #True
    If Index = 0
      nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole
      nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
    Else
      nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole
      nDevType = #SCS_DEVTYPE_CC_NETWORK_IN
    EndIf
    
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + \sLogicalDev + ", \sRemoteHost=" + \sRemoteHost + ", \nRemotePort=" + \nRemotePort + ", \nLocalPort=" + \nLocalPort + ", \bDummy=" + strB(\bDummy))
      sLogicalDev = \sLogicalDev
      sRemoteHost = \sRemoteHost
      nRemotePort = \nRemotePort
      nLocalPort = \nLocalPort
      bDummy = \bDummy
      If \nPhysicalDevPtr = -1
        \nPhysicalDevPtr = getNetworkControlPtrForDevNo(nDevType, nDevNo)
        debugMsg(sProcName, "getNetworkControlPtrForDevNo(" + decodeDevType(nDevType) + ", " + nDevNo + ") returned " + \nPhysicalDevPtr)
      EndIf
    EndWith
    
    If bDummy = #False
      Select nNetworkRole
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          If Len(Trim(sRemoteHost)) = 0
            sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblRemoteHost[Index]))
            nFocusGadget = WEP\txtRemoteHost[Index]
            bResult = #False
            Break
          ElseIf nRemotePort = -2
            sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblRemotePort[Index]))
            nFocusGadget = WEP\txtRemotePort[Index]
            bResult = #False
            Break
          EndIf
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          If nLocalPort = -2
            sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblLocalPort[Index]))
            nFocusGadget = WEP\txtLocalPort[Index]
            bResult = #False
            Break
          EndIf
          
      EndSelect
    EndIf
    
    If Index = 0
      For n = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\aMsgResponse[n]
          ; debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\aMsgResponse[" + n + "]sReceiveMsg=" + \sReceiveMsg + ", \nMsgAction=" + decodeNetworkMsgAction(\nMsgAction))
          If Trim(\sReceiveMsg)
            If \nMsgAction = #SCS_NETWORK_ACT_NOT_SET
              sErrorMsg = LangPars("Errors", "MustBeSelected", GGT(WEP\lblNetworkMsgAction))
              nFocusGadget = WEP\cboNetworkMsgAction[n]
              bResult = #False
              Break
            EndIf
          EndIf
        EndWith
      Next n
    EndIf
    
    Break
  Wend
  
  If bResult = #False
    ; move focus away from current gadget BEFORE calling MessageRequester() or error may get reported twice
    If IsGadget(nFocusGadget)
      SAG(nFocusGadget)
    Else
      SAG(-1)
    EndIf
    sErrorMsg + " (" + decodeDevTypeL(nDevType) + " " + sLogicalDev + ")"
    debugMsg(sProcName, sErrorMsg)
    debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult

EndProcedure

Procedure WEP_validateCueCtrlTabForRS232Devs()
  PROCNAMEC()
  Protected bResult, sErrorMsg.s
  Protected n, nInCount
  Protected nDevMapPtr
  Protected nDevPtr1, nDevPtr2
  Protected sPhysicalDev1.s, sPhysicalDev2.s
  Protected d1, d2
  Protected sFields.s
  
  debugMsg(sProcName, #SCS_START)
  
  bResult = #True
  nInCount = 0
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    nDevPtr1 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    While nDevPtr1 >= 0
      With grMapsForDevChgs\aDev(nDevPtr1)
        If (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\nDevType = #SCS_DEVTYPE_CC_RS232_IN)
          nInCount + 1
        EndIf
        nDevPtr1 = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  If nInCount > 1
    sErrorMsg = Lang("RS232", "OneInput") ; "You cannot select more than one port for input"
    bResult = #False
  EndIf
  
  If bResult
    For d1 = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      With grProdForDevChgs\aCueCtrlLogicalDevs(d1)
        If \nDevType = #SCS_DEVTYPE_CC_RS232_IN
          nInCount + 1
          nDevPtr1 = getDevChgsDevPtrForDevId(#SCS_DEVGRP_CUE_CTRL, \nDevId)
          If nDevPtr1 >= 0
            If grMapsForDevChgs\aDev(nDevPtr1)\bDummy = #False
              ; cue control device is RS232 and is not dummy, so now check if there is a control send RS232 device for the same port
              sPhysicalDev1 = grMapsForDevChgs\aDev(nDevPtr1)\sPhysicalDev
              For d2 = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
                If grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nDevType = #SCS_DEVTYPE_CS_RS232_OUT
                  nDevPtr2 = getDevChgsDevPtrForDevId(#SCS_DEVGRP_CTRL_SEND, grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nDevId)
                  If nDevPtr2 >= 0
                    If grMapsForDevChgs\aDev(nDevPtr2)\bDummy = #False
                      sPhysicalDev2 = grMapsForDevChgs\aDev(nDevPtr2)\sPhysicalDev
                      If sPhysicalDev1 = sPhysicalDev2
                        ; if the same RS232 COM port is being used for control send and cue control then check that all the RS232 settings are identical
                        sFields = ""
                        If \nRS232BaudRate <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232BaudRate
                          sFields + #CRLF$ + Lang("WEP", "lblBaudRate") + " (" + Str(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232BaudRate) + " / " + Str(\nRS232BaudRate) + ")"
                        EndIf
                        If \nRS232DataBits <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232DataBits
                          sFields + #CRLF$ + Lang("WEP", "lblDataBits") + " (" + Str(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232DataBits) + " / " + Str(\nRS232DataBits) + ")"
                        EndIf
                        If \fRS232StopBits <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\fRS232StopBits
                          sFields + #CRLF$ + Lang("WEP", "lblStopBits") + " (" + StrF(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\fRS232StopBits,1) + " / " + StrF(\fRS232StopBits,1) + ")"
                        EndIf
                        If \nRS232Parity <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232Parity
                          sFields + #CRLF$ + Lang("WEP", "lblParity") + " (" + decodeParity(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232Parity) + " / " + decodeParity(\nRS232Parity) + ")"
                        EndIf
                        If \nRS232Handshaking <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232Handshaking
                          sFields + #CRLF$ + Lang("WEP", "lblRS232Handshaking") + " (" + decodeHandshaking(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232Handshaking) + " / " + decodeHandshaking(\nRS232Handshaking) + ")"
                        EndIf
                        If \nRS232RTSEnable <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232RTSEnable
                          sFields + #CRLF$ + Lang("WEP", "lblRS232RTSEnable") + " (" + decodeYesNoL(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232RTSEnable) + " / " + decodeYesNoL(\nRS232RTSEnable) + ")"
                        EndIf
                        If \nRS232DTREnable <> grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232DTREnable
                          sFields + #CRLF$ + Lang("WEP", "lblRS232DTREnable") + " (" + decodeYesNoL(grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nRS232DTREnable) + " / " + decodeYesNoL(\nRS232DTREnable) + ")"
                        EndIf
                        If sFields
                          sErrorMsg = LangPars("RS232", "DiffSettings", sPhysicalDev1) + sFields
                          bResult = #False
                          Break 2
                        EndIf
                      EndIf ; EndIf sPhysicalDev1 = sPhysicalDev2
                    EndIf ; EndIf grMapsForDevChgs\aDev(nDevPtr2)\bDummy = #False
                  EndIf ; EndIf nDevPtr2 >= 0
                EndIf ; EndIf grProdForDevChgs\aCtrlSendLogicalDevs(d2)\nDevType = #SCS_DEVTYPE_CS_RS232_OUT
              Next d2
            EndIf ; EndIf grMapsForDevChgs\aDev(nDevPtr1)\bDummy = #False
          EndIf ; EndIf nDevPtr1 >= 0
        EndIf ; EndIf \nDevType = #SCS_DEVTYPE_CC_RS232_IN
      EndWith
    Next d1
  EndIf ; EndIf bResult
  
  If bResult = #False
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure WEP_validateVidAudTab()
  PROCNAMEC()
  Protected bResult, sErrorMsg.s
  Protected nDevCount, nAutoIncludeCount
  Protected d
  
  bResult = #True
  
  If grLicInfo\nMaxVidAudDevPerProd < 0
    ProcedureReturn #True
  EndIf
  
  For d = 0 To grProdForDevChgs\nMaxVidAudLogicalDev
    With grProdForDevChgs\aVidAudLogicalDevs(d)
      If \sVidAudLogicalDev
        nDevCount + 1
        If \bAutoInclude
          nAutoIncludeCount + 1
        EndIf
      EndIf
    EndWith
  Next d
  
  If nDevCount = 0
    sErrorMsg = Lang("Errors", "AtLeast1VidAudReqd")
    bResult = #False
  EndIf
  
  If bResult
    If nAutoIncludeCount <> 1
      sErrorMsg = Lang("Errors", "OneVidAudAutoReqd")
      bResult = #False
    EndIf
  EndIf
  
  If bResult = #False
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_validateVidCapTab()
  PROCNAMEC()
  Protected bResult, sErrorMsg.s
  Protected nDevCount, nAutoIncludeCount
  Protected d
  
  bResult = #True
  
  If grLicInfo\nMaxVidCapDevPerProd < 0
    ProcedureReturn #True
  EndIf
  
  For d = 0 To grProdForDevChgs\nMaxVidCapLogicalDev
    With grProdForDevChgs\aVidCapLogicalDevs(d)
      If \sLogicalDev
        nDevCount + 1
        If \bAutoInclude
          nAutoIncludeCount + 1
        EndIf
      EndIf
    EndWith
  Next d
  
  If nDevCount > 0
    If nAutoIncludeCount <> 1
      sErrorMsg = Lang("Errors", "OneVidCapAutoReqd")
      bResult = #False
    EndIf
  EndIf
  
  If bResult = #False
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_validateFixture(nDevNo, nFixtureIndex)
  PROCNAMEC()
  Protected bResult, nErrorGadget, sErrorMsg.s
  Protected nDevMapDevPtr
  Protected bItemPresent, bDMXStartChannelPresent
  
  ; debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo + ", nFixtureIndex=" + nFixtureIndex)
  
  If grWEP\bFixtureTypeTabPopulated = #False
    ; tab not yet populated so no need to validate
    ProcedureReturn #True
  EndIf
  
  bResult = #True
  
  While #True
    If nDevNo >= 0
      If nFixtureIndex <= grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nMaxFixture
        nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, nDevNo)
        If nDevMapDevPtr >= 0
          With grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)
            If (\sFixtureCode) Or (\sFixtureDesc) Or (grProdForDevChgs\bLightingPre118 And \sDimmableChannels)
              bItemPresent = #True
            ElseIf nFixtureIndex <= grMapsForDevChgs\aDev(nDevMapDevPtr)\nMaxDevFixture
              If grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\nDevDMXStartChannel > 1
                bItemPresent = #True
              EndIf
            EndIf
            If bItemPresent
              If Len(\sFixtureCode) = 0
                sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblFixtureCode))
                nErrorGadget = WEPFixture(nFixtureIndex)\txtFixtureCode
                Break
              EndIf
              If Len(\sFixtureDesc) = 0
                sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblFixtureDesc))
                nErrorGadget = WEPFixture(nFixtureIndex)\txtFixtureDesc
                Break
              EndIf
              If grProdForDevChgs\nMaxFixType >= 0
                If Len(\sFixTypeName) = 0
                  sErrorMsg = LangPars("Errors", "MustBeSelected", GGT(WEP\lblFixtureType))
                  nErrorGadget = WEPFixture(nFixtureIndex)\cboFixtureType
                  Break
                EndIf
              EndIf
              If grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\nDevDMXStartChannel > 0 Or
                 Trim(grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\sDevDMXStartChannels)
                bDMXStartChannelPresent = #True
              EndIf
              If bDMXStartChannelPresent = #False
                debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + nFixtureIndex + ")\sDevFixtureCode=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\sDevFixtureCode +
                                    ", \nDevDMXStartChannel=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\nDevDMXStartChannel +
                                    ", \sDevDMXStartChannels=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\aDevFixture(nFixtureIndex)\sDevDMXStartChannels)
                sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblDMXStartChannel))
                nErrorGadget = WEPFixture(nFixtureIndex)\txtDMXStartChannel
                Break
              EndIf
            EndIf ; EndIf bItemPresent
          EndWith
        EndIf ; EndIf nDevMapDevPtr >= 0
      EndIf ; EndIf nFixtureIndex <= grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nMaxFixture
    EndIf ; EndIf nDevNo >= 0
    Break
  Wend
  
  If nErrorGadget
    bResult = #False
    ; nb must SetActiveGadget(nErrorGadget) BEFORE calling MessageRequester or focus initially bounces back to nErrorGadget after closing the MessageRequester dialog
    SAG(nErrorGadget)
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_validateFixtureType(nFTIndex)
  PROCNAMEC()
  Protected bResult, sErrorMsg.s, nErrorGadget
  Protected bItemPresent
  
  ; debugMsg(sProcName, #SCS_START)
  
  bResult = #True
  While #True
    ; nb array index and gadget index are in sync - see WEP_displayFixType()
    With grProdForDevChgs\aFixTypes(nFTIndex)
      ; debugMsg(sProcName, "grProdForDevChgs\aFixTypes(" + nFTIndex + ")\sFixTypeName=" + \sFixTypeName + ", \sFixTypeDesc=" + \sFixTypeDesc)
      If (\sFixTypeName) Or (\sFixTypeDesc)
        bItemPresent = #True
      EndIf
      If bItemPresent
        If Len(\sFixTypeName) = 0
          sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblFixTypeName))
          nErrorGadget = WEP\txtFixTypeName(nFTIndex)
          bResult = #False
          Break
        EndIf
        If Len(\sFixTypeDesc) = 0
          sErrorMsg = LangPars("Errors", "MustBeEntered", GGT(WEP\lblFixTypeDesc))
          nErrorGadget = WEP\txtFixTypeDesc
          bResult = #False
          Break
        EndIf
      EndIf
    EndWith
    Break
  Wend
  
  If bResult = #False
    ; SAG(nErrorGadget)
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
    ; Added 9Apr2021 11.8.4.2ac following email from Dave Jenkins where SCS was stuck in a loop throwing the error "Description must be entered"
    ; Tried all sorts of SetActiveGadget() calls to set the focus back, but events continued to be raised against the original gadget which now has focus.
    ; Eventually decided the only way to avoid this was to set a global variable (gbDisableEventChecking) to ignore all such events, and to resume
    ; checking after that was completed. The event #SCS_Event_EnableEventChecking will clear gbDisableEventChecking.
    SetActiveWindow(#WED)
    SGS(WEP\pnlFixTypeDetail, 0) ; ensure the first tab has focus, because that's where txtFixTypeDesc is located
    SetActiveGadget(nErrorGadget)
    If nErrorGadget <> gnEventGadgetNo
      gnDisableEventCheckingForGadgetNo = gnEventGadgetNo
      debugMsg(sProcName, "gnDisableEventCheckingForGadgetNo=" + getGadgetName(gnDisableEventCheckingForGadgetNo))
    EndIf
    ; debugMsg0(sProcName, "nErrorGadget=" + getGadgetName(nErrorGadget) + ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
    ; debugMsg0(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventGadgetArrayIndex=" + gnEventGadgetArrayIndex)
    ; End added 9Apr2021 11.8.4.2ac
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_validateFixtureTypeTab()
  PROCNAMEC()
  Protected nFTIndex, bResult
  
  debugMsg(sProcName, #SCS_START)
  
  bResult = #True
  For nFTIndex = 0 To grProdForDevChgs\nMaxFixType
    bResult = WEP_validateFixtureType(nFTIndex)
    If bResult = #False
      Break
    EndIf
  Next nFTIndex
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure WEP_validateLightingTab(nDevMapPtr)
  PROCNAMEC()
  Protected bResult
  Protected d, nDevMapDevPtr, nFixtureIndex
  
  bResult = #True
  For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
    With grProdForDevChgs\aLightingLogicalDevs(d)
      If \nDevType <> #SCS_DEVTYPE_NONE
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_LIGHTING, \sLogicalDev, nDevMapPtr)
        Select \nDevType
          Case #SCS_DEVTYPE_LT_DMX_OUT
            If WEP_valDMXDev(0, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valDMXDev(0, " + d + ", " + nDevMapDevPtr + ") returned #False")
              bResult = #False
              Break
            EndIf
            If grWEP\bFixtureTypeTabPopulated
              For nFixtureIndex = 0 To \nMaxFixture
                If WEP_validateFixture(d, nFixtureIndex) = #False
                  debugMsg(sProcName, "WEP_validateFixture(" + d + ", " + nFixtureIndex + ") returned #False")
                  bResult = #False
                  Break
                EndIf
              Next nFixtureIndex
            EndIf
        EndSelect
      EndIf
    EndWith
  Next d
  ProcedureReturn bResult
EndProcedure

Procedure WEP_validateCtrlSendTab(nDevMapPtr)
  PROCNAMEC()
  Protected bResult
  Protected d, nDevMapDevPtr
  
  bResult = #True
  For d = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
    With grProdForDevChgs\aCtrlSendLogicalDevs(d)
      If \nDevType <> #SCS_DEVTYPE_NONE
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CTRL_SEND, \sLogicalDev, nDevMapPtr)
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            If WEP_valMidiDev(0, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valMidiDev(0, " + d + ", " + nDevMapDevPtr + ") returned #False")
              ProcedureReturn
            EndIf
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            If WEP_valNetworkDev(0, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valNetworkDev(0, " + d + ", " + nDevMapDevPtr + ") returned #False")
              ProcedureReturn
            EndIf
        EndSelect
      EndIf
    EndWith
  Next d

  ProcedureReturn bResult
EndProcedure

Procedure WEP_validateCueCtrlTab(nDevMapPtr)
  PROCNAMEC()
  Protected bResult
  Protected d, nDevMapDevPtr
  
  bResult = #True
  For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
    With grProdForDevChgs\aCueCtrlLogicalDevs(d)
      If \nDevType <> #SCS_DEVTYPE_NONE
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, \sCueCtrlLogicalDev, nDevMapPtr)
        Select \nDevType
          Case #SCS_DEVTYPE_CC_DMX_IN
            If WEP_valDMXDev(1, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valDMXDev(1, " + d + ", " + nDevMapDevPtr + ") returned #False")
              bResult = #False
              Break
            EndIf
          Case #SCS_DEVTYPE_CC_MIDI_IN
            If WEP_valMidiDev(1, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valMidiDev(1, " + d + ", " + nDevMapDevPtr + ") returned #False")
              bResult = #False
              Break
            EndIf
          Case #SCS_DEVTYPE_CC_NETWORK_IN
            If WEP_valNetworkDev(1, d, nDevMapDevPtr) = #False
              debugMsg(sProcName, "WEP_valNetworkDev(1, " + d + ", " + nDevMapDevPtr + ") returned #False")
              bResult = #False
              Break
            EndIf
        EndSelect
      EndIf
    EndWith
  Next d
  
  If bResult
    If WEP_validateCueCtrlTabForRS232Devs() = #False
      debugMsg(sProcName, "WEP_validateCueCtrlTabForRS232Devs() returned #False")
      bResult = #False
    EndIf
  EndIf
  
  If bResult
    If WEP_validateCueCtrlTabForDMXDevs() = #False
      debugMsg(sProcName, "WEP_validateCueCtrlTabForDMXDevs() returned #False")
      bResult = #False
    EndIf
  EndIf
  
  ProcedureReturn bResult
EndProcedure

Procedure WEP_validateCueCtrlTabForDMXDevs()
  PROCNAMEC()
  Protected bResult, sErrorMsg.s
  Protected nInCount
  Protected nDevMapPtr, nDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  bResult = #True
  nInCount = 0
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  If nDevMapPtr >= 0
    nDevPtr = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
    While nDevPtr >= 0
      With grMapsForDevChgs\aDev(nDevPtr)
        If (\nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (\nDevType = #SCS_DEVTYPE_CC_DMX_IN)
          nInCount + 1
        EndIf
        nDevPtr = \nNextDevIndex
      EndWith
    Wend
  EndIf
  
  If nInCount > 1
    sErrorMsg = Lang("DMX", "OneInput") ; "You cannot select more than one port for input"
    bResult = #False
  EndIf
  
  If bResult = #False
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure WEP_populateDMXTrgValue()
  PROCNAMEC()
  Protected n, nListIndex
  Protected nPercentage
  
  If grWEP\nCurrentCueDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
      ClearGadgetItems(WEP\cboDMXTrgValue)
      Select \nDMXInPref  ; preferred value notation: 0 = 0-255, 1 = %
        Case 0
          For n = 255 To 1 Step -1  ; nb do NOT include 0 as command is triggered by an increase in value to \nDMXTrgValue, so \nDMXTrgValue must be > 0
            addGadgetItemWithData(WEP\cboDMXTrgValue, Str(n), n)
          Next n
          
        Case 1
          For n = 100 To 1 Step -1  ; see comment above
            addGadgetItemWithData(WEP\cboDMXTrgValue, Str(n) + "%", (n * 2.55))
          Next n
      EndSelect
      
      If \nDMXTrgValue < 1 Or \nDMXTrgValue > 255
        ; shouldn't happen
        \nDMXTrgValue = grProdDef\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nDMXTrgValue
      EndIf
      
      nListIndex = indexForComboBoxData(WEP\cboDMXTrgValue, \nDMXTrgValue, -1)
      If nListIndex = -1
        If \nDMXInPref = 1
          ; preference is % so find nearest value
          nPercentage = \nDMXTrgValue / 2.55
          \nDMXTrgValue = nPercentage * 2.55
          nListIndex = indexForComboBoxData(WEP\cboDMXTrgValue, \nDMXTrgValue, -1)
          If nListIndex = -1
            ; shouldn't happen
            \nDMXTrgValue = grProdDef\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nDMXTrgValue
            nListIndex = indexForComboBoxData(WEP\cboDMXTrgValue, \nDMXTrgValue, -1)
          EndIf
        EndIf
      EndIf
      SGS(WEP\cboDMXTrgValue, nListIndex)
      
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_validateAudTab()
  PROCNAMEC()
  Protected bResult, sErrorMsg.s
  Protected nDevCount, nAutoIncludeCount
  Protected d
  Protected nFirstDevIndex, sFirstLogicalDev.s
  Protected nResponse
  
  bResult = #True
  
  For d = 0 To grProdForDevChgs\nMaxAudioLogicalDev
    With grProdForDevChgs\aAudioLogicalDevs(d)
      If \sLogicalDev
        nDevCount + 1
        If nDevCount = 1
          nFirstDevIndex = d
          sFirstLogicalDev = \sLogicalDev
        EndIf
        If \bAutoInclude
          nAutoIncludeCount + 1
        EndIf
      EndIf
    EndWith
  Next d
  
  If nDevCount = 0
    sErrorMsg = Lang("Errors", "AtLeast1AudReqd")
    bResult = #False
  EndIf
  
  If bResult
    If nAutoIncludeCount = 0
      sErrorMsg = LangPars("Errors", "NoAutoIncludeAud", sFirstLogicalDev)
      debugMsg(sProcName, sErrorMsg)
      nResponse = scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_YesNoCancel | #MB_ICONQUESTION)
      Select nResponse
        Case #PB_MessageRequester_Yes
          grProdForDevChgs\aAudioLogicalDevs(nFirstDevIndex)\bAutoInclude = #True
          If grWEP\nCurrentAudDevNo = nFirstDevIndex
            setOwnState(WEP\chkAutoInclude, #True)
            ED_fcAutoInclude()
          EndIf
          ; return #True as detected 'error' is now fixed
          ProcedureReturn #True
          
        Case #PB_MessageRequester_No
          ; return #True as user doesn't want any device to be auto-included
          ProcedureReturn #True
          
        Case #PB_MessageRequester_Cancel
          ; return #False so device changes are not yet applied
          ProcedureReturn #False
          
      EndSelect
    EndIf
  EndIf
  
  If bResult = #False
    debugMsg(sProcName, sErrorMsg)
    scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
  EndIf
  
  ProcedureReturn bResult
  
EndProcedure

Procedure WEP_btnTestDMX_Click()
  PROCNAMEC()
  Protected nMsgResult
  Protected nDevType, nDMXControlPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If WEP_valDisplayedDev() = #False
    debugMsg(sProcName, "exiting because WEP_valDisplayedDev() returned #False")
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "grSession\nDMXInEnabled=" + grSession\nDMXInEnabled)
  Select grSession\nDMXInEnabled
    Case #SCS_DEVTYPE_NOT_REQD
      grSession\nDMXInEnabled = #SCS_DEVTYPE_ENABLED
      debugMsg(sProcName, "nDMXInEnabled=" + grSession\nDMXInEnabled)
      setDMXEnabled(#True)
      
    Case #SCS_DEVTYPE_DISABLED
      nMsgResult = scsMessageRequester(GGT(WEP\btnTestDMX), Lang("DMX", "EnableDMX?"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nMsgResult = #PB_MessageRequester_Yes
        grSession\nDMXInEnabled = #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "nDMXInEnabled=" + grSession\nDMXInEnabled)
        setDMXEnabled(#True)
      Else
        ProcedureReturn
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, "grWEP\nCurrentCueDevMapDevPtr=" + grWEP\nCurrentCueDevMapDevPtr)
  If (grWEP\nCurrentCueDevMapDevPtr >= 0) And (grWEP\nCurrentCueDevNo >= 0)
    debugMsg(sProcName, "calling DMX_loadDMXControl(#True)")
    DMX_loadDMXControl(#True)
    nDMXControlPtr = DMX_getDMXControlPtrForDevNo(#SCS_DEVTYPE_CC_DMX_IN, grWEP\nCurrentCueDevNo)
    If nDMXControlPtr >= 0
      With gaDMXControl(nDMXControlPtr)
        If \nFTHandle
          debugMsg(sProcName, "calling DMX_closeDMXDev(" + nDMXControlPtr + ")")
          DMX_closeDMXDev(nDMXControlPtr)
          Delay(10)
        EndIf
      EndWith
    EndIf
    debugMsg(sProcName, "calling DMX_openDMXDevs()")
    DMX_openDMXDevs()
    Delay(10)
  EndIf
  
  WDT_Form_Show(#True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnTestMidi_Click()
  PROCNAMEC()
  Protected nMsgResult
  
  debugMsg(sProcName, #SCS_START)
  
  If WEP_valDisplayedDev() = #False
    debugMsg(sProcName, "exiting because WEP_valDisplayedDev() returned #False")
    ProcedureReturn
  EndIf
  
  Select grSession\nMidiInEnabled
    Case #SCS_DEVTYPE_NOT_REQD
      grSession\nMidiInEnabled = #SCS_DEVTYPE_ENABLED
      debugMsg(sProcName, "grSession\nMidiInEnabled=" + Str(grSession\nMidiInEnabled))
      setMidiEnabled(#True)
      
    Case #SCS_DEVTYPE_DISABLED
      nMsgResult = scsMessageRequester(GGT(WEP\btnTestMidi), Lang("MIDI", "EnableMidiIn?"), #PB_MessageRequester_YesNo|#MB_ICONQUESTION)
      If nMsgResult = #PB_MessageRequester_Yes
        grSession\nMidiInEnabled = #SCS_DEVTYPE_ENABLED
        debugMsg(sProcName, "grSession\nMidiInEnabled=" + Str(grSession\nMidiInEnabled))
        setMidiEnabled(#True)
      Else
        ProcedureReturn
      EndIf
      
  EndSelect
  
  If grWEP\bCueMidiInDevsChanged
    debugMsg(sProcName, "calling closeMidiPorts")
    closeMidiPorts()
    DoEvents()
  EndIf
  
  debugMsg(sProcName, "calling loadMidiControl(#True)")
  loadMidiControl(#True)
  
  If grWEP\bCueMidiInDevsChanged
    debugMsg(sProcName, "calling openMidiPorts()")
    openMidiPorts()
    DoEvents()
    grWEP\bCueMidiInDevsChanged = #False
    ; debugMsg0(sProcName, "grWEP\bCueMidiInDevsChanged=" + strB(grWEP\bCueMidiInDevsChanged))
  EndIf
  
  WMT_Form_Show(#SCS_WMT_MIDI, grWEP\nCurrentCueDevType, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnTestNetwork_Click()
  PROCNAMEC()
  Protected sTitle.s
  Protected sMsg.s
  Protected nNetworkControlPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If WEP_valDisplayedDev() = #False
    debugMsg(sProcName, "exiting because WEP_valDisplayedDev() returned #False")
    ProcedureReturn
  EndIf
  
  nNetworkControlPtr = getNetworkControlPtrForDevNo(grWEP\nCurrentCueDevType, grWEP\nCurrentCueDevNo)
  If nNetworkControlPtr >= 0
    ; closeNetwork()
    If startNetwork(nNetworkControlPtr, #True) = #False
      sTitle = Trim(RemoveString(GGT(WEP\btnTestNetwork), "..."))
      sMsg = Lang("Network", "CannotStart")
      debugMsg(sProcName, "sMsg=" + sMsg)
      scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_Ok)
    Else
      WMT_Form_Show(#SCS_WMT_NETWORK, grWEP\nCurrentCueDevType, #True)
    EndIf
  EndIf
  
EndProcedure

Procedure WEP_btnTestRS232_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If WEP_valDisplayedDev() = #False
    debugMsg(sProcName, "exiting because WEP_valDisplayedDev() returned #False")
    ProcedureReturn
  EndIf
  
  closeRS232()
  DoEvents()
  
  setRS232InOutInds(#True)
  startRS232()
  DoEvents()
  
  WMT_Form_Show(#SCS_WMT_RS232, grWEP\nCurrentCueDevType, #True)
  
EndProcedure

Procedure WEP_displayCurrNetworkDevDesc()
  PROCNAMEC()
  Static sClient.s, sServer.s, sDummy.s, sRemote.s, sLocal.s
  Static bStaticLoaded
  Protected nNetworkProtocol, nNetworkRole = -1
  Protected nDevNo
  Protected sRemoteHost.s, sRemotePort.s, sLocalPort.s
  Protected bDummy
  Protected sPhysDevInfo.s
  
  ; populate static variables if necessary
  If bStaticLoaded = #False
    sDummy = Lang("Network", "Dummy")
    sRemote = Lang("Network", "Remote")
    sLocal = Lang("Network", "Local")
    bStaticLoaded = #True
  EndIf
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      nDevNo = grWEP\nCurrentCtrlDevNo
      nNetworkProtocol = getCurrentItemData(WEP\cboNetworkProtocol[0])
      nNetworkRole = getCurrentItemData(WEP\cboNetworkRole[0])
      sRemoteHost = Trim(GGT(WEP\txtRemoteHost[0]))
      sRemotePort = Trim(GGT(WEP\txtRemotePort[0]))
      sLocalPort = Trim(GGT(WEP\txtLocalPort[0]))
      bDummy = getOwnState(WEP\chkNetworkDummy[0])  ; added 5Nov2015 11.4.1.2h
      
    Case #SCS_DEVGRP_CUE_CTRL
      nDevNo = grWEP\nCurrentCueDevNo
      nNetworkProtocol = getCurrentItemData(WEP\cboNetworkProtocol[1])
      nNetworkRole = getCurrentItemData(WEP\cboNetworkRole[1])
      sRemoteHost = Trim(GGT(WEP\txtRemoteHost[1]))
      sRemotePort = Trim(GGT(WEP\txtRemotePort[1]))
      sLocalPort = Trim(GGT(WEP\txtLocalPort[1]))
      bDummy = getOwnState(WEP\chkNetworkDummy[1])  ; added 5Nov2015 11.4.1.2h
      
  EndSelect
  
  Select nNetworkProtocol
    Case #SCS_NETWORK_PR_TCP
      sPhysDevInfo = "TCP "  ; nb display 'TCP', not 'Telnet', in the device description
    Case #SCS_NETWORK_PR_UDP
      sPhysDevInfo = "UDP "
  EndSelect
  
  Select nNetworkRole
    Case #SCS_ROLE_DUMMY
      sPhysDevInfo + sDummy
      
    Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
      sPhysDevInfo + sRemote + " = "
      If bDummy ; bDummy processing added 5Nov2015 11.4.1.2h
        sPhysDevInfo + sDummy
      Else
        sPhysDevInfo + stringNVL(sRemoteHost,"?") + ":" + stringNVL(sRemotePort,"?")
      EndIf
      
    Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
      sPhysDevInfo + sLocal + " = "
      If bDummy ; bDummy processing added 5Nov2015 11.4.1.2h
        sPhysDevInfo + sDummy
      Else
        sPhysDevInfo + stringNVL(sLocalPort,"?")
      EndIf
      
  EndSelect
  
  If nDevNo >= 0
    Select grWEP\nCurrentDevGrp
      Case #SCS_DEVGRP_CTRL_SEND
        If GGT(WEP\txtCtrlPhysDevInfo(nDevNo)) <> sPhysDevInfo
          SGT(WEP\txtCtrlPhysDevInfo(nDevNo), sPhysDevInfo)
        EndIf
      Case #SCS_DEVGRP_CUE_CTRL
        If GGT(WEP\txtCuePhysDevInfo(nDevNo)) <> sPhysDevInfo
          SGT(WEP\txtCuePhysDevInfo(nDevNo), sPhysDevInfo)
        EndIf
    EndSelect
  EndIf

EndProcedure

Procedure WEP_populateDevMapComboBox()
  PROCNAMEC()
  Protected n
  
  ClearGadgetItems(WEP\cboDevMap)
  For n = 0 To grMapsForDevChgs\nMaxMapIndex
    AddGadgetItem(WEP\cboDevMap, -1, grMapsForDevChgs\aMap(n)\sDevMapName)
  Next n
EndProcedure

Procedure.s WEP_makeNewLightingLogicalDev(nDevNo)
  PROCNAMEC()
  Protected nDevType
  Protected sLogicalDevNew.s
  Protected sLogicalDevBase.s
  Protected n, d
  Protected bChangeOK
  
  With grProdForDevChgs
    nDevType = \aLightingLogicalDevs(nDevNo)\nDevType
    Select nDevType
      Case #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDevNew = #SCS_DEFAULT_DMX_LOGICALDEV
    EndSelect
    
    ; check that the proposed new sLogicalDev name is not already in use (ignore case)
    ; debugMsg(sProcName, "sLogicalDevNew=" + sLogicalDevNew)
    bChangeOK = #True
    If sLogicalDevNew
      sLogicalDevBase = sLogicalDevNew
      For n = 1 To 500
        If n > 1
          sLogicalDevNew = sLogicalDevBase + "." + n
        EndIf
        bChangeOK = #True
        For d = 0 To \nMaxLightingLogicalDev
          If d <> nDevNo
            If \aLightingLogicalDevs(d)\sLogicalDev = sLogicalDevNew
              bChangeOK = #False
              Break
            EndIf
          EndIf
        Next d
        If bChangeOK
          Break
        EndIf
      Next n
    EndIf
    
    If bChangeOK = #False
      ; shouldn't get here
      sLogicalDevNew = ""
    EndIf
    
  EndWith
  
  ProcedureReturn sLogicalDevNew
EndProcedure

Procedure.s WEP_makeNewCtrlLogicalDev(nDevNo)
  PROCNAMEC()
  Protected nDevType
  Protected sLogicalDevNew.s
  Protected sLogicalDevBase.s
  Protected n, d
  Protected bChangeOK
  
  With grProdForDevChgs
    nDevType = \aCtrlSendLogicalDevs(nDevNo)\nDevType
    Select nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        sLogicalDevNew = #SCS_DEFAULT_MIDI_LOGICALDEV
        
      Case #SCS_DEVTYPE_CS_RS232_OUT
        sLogicalDevNew = #SCS_DEFAULT_RS232_LOGICALDEV
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT
        Select \aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev
          Case #SCS_CS_NETWORK_REM_SCS
            sLogicalDevNew = "SCS"
          Case #SCS_CS_NETWORK_REM_PJLINK, #SCS_CS_NETWORK_REM_PJNET
            sLogicalDevNew = "Projector"
          Case #SCS_CS_NETWORK_REM_OSC_X32
            sLogicalDevNew = "OSC-X32"
          Case #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
            sLogicalDevNew = "OSC-X32C"
          Case #SCS_CS_NETWORK_REM_OSC_X32TC
            ; sLogicalDevNew = "OSC-X32TC"
            sLogicalDevNew = "ThMix" ; 'TheatreMix' - the new name for 'X32 Theatre Control'
          Case #SCS_CS_NETWORK_REM_LF
            sLogicalDevNew = "LF"
          Case #SCS_CS_NETWORK_REM_VMIX
            sLogicalDevNew = "vMix"
          Default
            sLogicalDevNew = #SCS_DEFAULT_NETWORK_LOGICALDEV
        EndSelect
        
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST
        sLogicalDevNew = #SCS_DEFAULT_HTTP_LOGICALDEV
        
      Case #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDevNew = #SCS_DEFAULT_DMX_LOGICALDEV
        
    EndSelect
    
    ; check that the proposed new sLogicalDev name is not already in use (ignore case)
    ; debugMsg(sProcName, "sLogicalDevNew=" + sLogicalDevNew)
    bChangeOK = #True
    If sLogicalDevNew
      sLogicalDevBase = sLogicalDevNew
      For n = 1 To 500
        If n > 1
          sLogicalDevNew = sLogicalDevBase + "." + n
        EndIf
        bChangeOK = #True
        For d = 0 To \nMaxCtrlSendLogicalDev
          If d <> nDevNo
            If \aCtrlSendLogicalDevs(d)\sLogicalDev = sLogicalDevNew
              bChangeOK = #False
              Break
            EndIf
          EndIf
        Next d
        If bChangeOK
          Break
        EndIf
      Next n
    EndIf
    
    If bChangeOK = #False
      ; shouldn't get here
      sLogicalDevNew = ""
    EndIf
    
  EndWith
  
  ProcedureReturn sLogicalDevNew
EndProcedure

Procedure WEP_refreshCurrentTabPhysInfo()
  PROCNAMEC()
  Protected nDevno
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_AUDIO_OUTPUT
      
    Case #SCS_DEVGRP_LIGHTING
      For nDevno = 0 To grProdForDevChgs\nMaxLightingLogicalDev
        WEP_displayLightingDev(nDevno)
      Next nDevno
      
    Case #SCS_DEVGRP_CTRL_SEND
      For nDevno = 0 To grProdForDevChgs\nMaxCtrlSendLogicalDev
        WEP_displayCtrlPhysInfo(nDevno)
      Next nDevno
      
    Case #SCS_DEVGRP_CUE_CTRL
      For nDevno = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
        WEP_displayCuePhysInfo(nDevno)
      Next nDevno
      
  EndSelect
  
EndProcedure

Procedure WEP_cboX32Command_Click(Index)
  PROCNAMEC()
  Protected nX32Button
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nX32Button = getCurrentItemData(WEP\cboX32Command[Index])
      If nX32Button <> \aX32Command[Index]\nX32Button
        \aX32Command[Index]\nX32Button = nX32Button
        grCED\bProdChanged = #True
      EndIf
      debugMsg(sProcName, "calling WEP_displayNetworkAssigns(" + nDevNo + ")")
      WEP_displayNetworkAssigns(nDevNo)
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_setCboDevMapForChange()
  PROCNAMEC()
  Protected nListIndex
  
  With grCED
    If \bChangeDevMap
      debugMsg(sProcName, "grCED\bChangeDevMap=" + strB(\bChangeDevMap) + ", \sNewDevMapName=" + \sNewDevMapName)
      If getCurrentItemData(WEP\pnlDevs) <> #SCS_PROD_TAB_AUD_DEVS
        setGadgetItemByData(WEP\pnlDevs, #SCS_PROD_TAB_AUD_DEVS)
        WEP_pnlDevs_Click()
      EndIf
      nListIndex = indexForComboBoxRow(WEP\cboDevMap, \sNewDevMapName)
      If nListIndex >= 0
        SGS(WEP\cboDevMap, nListIndex)
        WEP_cboDevMap_Click()
      EndIf
      \bChangeDevMap = #False
      \sNewDevMapName = ""
    EndIf
  EndWith
EndProcedure

Procedure WEP_btnTestVidCapStart_Click()
  PROCNAMEC()
  Protected nDevNo, nPhysicalDevPtr, nTVGIndex, nVidCapDevId
  Protected nHandle.i, sHandle.s
  Protected nReqdTargetWidth.l, nReqdTargetHeight.l
  Protected nTargetLeft.l, nTargetTop.l, nTargetWidth.l, nTargetHeight.l
  
  debugMsg(sProcName, #SCS_START + ", grWEP\nCurrentVidCapDevNo=" + grWEP\nCurrentVidCapDevNo)
  
  SetTopMostWindow(#WED, #True)
  
  nDevNo = grWEP\nCurrentVidCapDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
      debugMsg(sProcName, "grProdForDevChgs\aVidCapLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\nPhysicalDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        nVidCapDevId = gaVideoCaptureDev(nPhysicalDevPtr)\nVidCapDevId
        debugMsg(sProcName, "gaVideoCaptureDev(" + nPhysicalDevPtr + ")\bVidCapInitialized=" + strB(gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized) + ", nVidCapDevId=" + nVidCapDevId)
        If nVidCapDevId >= 0
          If gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized
            nTVGIndex = getTVGIndexForCapture(#SCS_VID_PIC_TARGET_TEST)
            debugMsg(sProcName, "nTVGIndex=" + nTVGIndex)
            If nTVGIndex >= 0
              nHandle = *gmVideoGrabber(nTVGIndex)
              sHandle = decodeHandle(nHandle)
              TVG_SetVideoDevice(nHandle, nVidCapDevId)
              debugMsgT(sProcName, "TVG_SetVideoDevice(" + sHandle + ", " + nVidCapDevId + ")")
              nReqdTargetWidth = GadgetWidth(WEP\cvsTestVidCap)
              nReqdTargetHeight = GadgetHeight(WEP\cvsTestVidCap)
              TVG_UseNearestVideoSize(nHandle, nReqdTargetWidth, nReqdTargetHeight, #tvc_false)
              debugMsgT(sProcName, "TVG_UseNearestVideoSize(" + sHandle + ", " + nReqdTargetWidth + ", " + nReqdTargetHeight + ", #tvc_false)")
              debugMsgT(sProcName, "TVG_GetVideoWidth(" + sHandle + ")=" + TVG_GetVideoWidth(nHandle) + ", TVG_GetVideoHeight(" + sHandle + ")=" + TVG_GetVideoHeight(nHandle))
              TVG_SetDisplayEmbedded(nHandle, 0, #tvc_false)
              debugMsgT(sProcName, "TVG_SetDisplayEmbedded(" + sHandle + ", 0, #tvc_false)")
              TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Box)
              debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ",0 , #tvc_ar_Box)")
              TVG_SetMuteAudioRendering(nHandle, #tvc_true)
              debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_true)")
              nTargetLeft = GadgetX(WEP\cvsTestVidCap, #PB_Gadget_ScreenCoordinate)
              nTargetTop = GadgetY(WEP\cvsTestVidCap, #PB_Gadget_ScreenCoordinate)
              nTargetWidth = GadgetWidth(WEP\cvsTestVidCap)
              nTargetHeight = GadgetHeight(WEP\cvsTestVidCap)
              TVG_Display_SetLocation(nHandle, nTargetLeft, nTargetTop, nTargetWidth, nTargetHeight)
              debugMsgT(sProcName, "TVG_Display_SetLocation(" + sHandle + ", " + nTargetLeft + ", " + nTargetTop + ", " + nTargetWidth + ", " + nTargetHeight + ")")
              TVG_SetDisplayStayOnTop(nHandle, 0, #tvc_true)
              debugMsg(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", 0, #tvc_true)")
              TVG_SetDisplayMonitor(nHandle, 0, 0)
              debugMsg(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", 0, 0)")
              TVG_SetParentWindow(nHandle, GadgetID(WEP\cvsTestVidCap))
              debugMsgT(sProcName, "TVG_SetParentWindow(" + sHandle + ", GadgetID(WEP\cvsTestVidCap))")
              TVG_StartPreview(nHandle)
              debugMsgT(sProcName, "TVG_StartPreview(" + sHandle + ")")
              ; When using TVG_StartPreview, hiding the window icons must be called AFTER TVG_StartPreview()
              debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
              hideTVGWindowIcons(nTVGIndex)
              setVisible(WEP\btnTestVidCapStart, #False)
              setVisible(WEP\btnTestVidCapStop, #True)
              If GetActiveWindow() <> #WED
                SAW(#WED)
              EndIf
            EndIf ; EndIf nTVGIndex >= 0
          EndIf ; EndIf gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized
        EndIf ; EndIf nVidCapDevId >= 0
      EndIf ; EndIf nPhysicalDevPtr >= 0
    EndWith
  EndIf ; EndIf nDevNo >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_btnTestVidCapStop_Click()
  PROCNAMEC()
  Protected nDevNo, nPhysicalDevPtr, nTVGIndex, nVidCapDevId
  Protected nHandle.i, sHandle.s
  
  debugMsg(sProcName, #SCS_START + ", grWEP\nCurrentVidCapDevNo=" + grWEP\nCurrentVidCapDevNo)
  
  nDevNo = grWEP\nCurrentVidCapDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidCapLogicalDevs(nDevNo)
      debugMsg(sProcName, "grProdForDevChgs\aVidCapLogicalDevs(" + nDevNo + ")\nPhysicalDevPtr=" + grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\nPhysicalDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        nVidCapDevId = gaVideoCaptureDev(nPhysicalDevPtr)\nVidCapDevId
        debugMsg(sProcName, "gaVideoCaptureDev(" + nPhysicalDevPtr + ")\bVidCapInitialized=" + strB(gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized) + ", nVidCapDevId=" + nVidCapDevId)
        If gaVideoCaptureDev(nPhysicalDevPtr)\bVidCapInitialized
          nTVGIndex = getTVGIndexForCapture(#SCS_VID_PIC_TARGET_TEST)
          debugMsg(sProcName, "nTVGIndex=" + nTVGIndex)
          If nTVGIndex >= 0
            nHandle = *gmVideoGrabber(nTVGIndex)
            sHandle = decodeHandle(nHandle)
            TVG_StopPreview(nHandle)
            debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ")")
            setVisible(WEP\btnTestVidCapStop, #False)
            setVisible(WEP\btnTestVidCapStart, #True)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure WEP_createNewFixtureIfReqd()
  PROCNAMEC()
  Protected nDevNo, bFixtureInfoPresent
  Protected nHoldCurrItem
  
  debugMsg(sProcName, #SCS_START + ", gnWEPFixtureCurrItem=" + gnWEPFixtureCurrItem + ", gnWEPFixtureLastItem=" + gnWEPFixtureLastItem)
  
  If (gnWEPFixtureCurrItem >= 0) And (gnWEPFixtureCurrItem >= gnWEPFixtureLastItem)
    nDevNo = grWEP\nCurrentLightingDevNo
    With grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(gnWEPFixtureCurrItem)
      If \sFixtureCode Or \sFixtureDesc Or \sDimmableChannels
        bFixtureInfoPresent = #True
        If \nFixtureId <= 0
          gnUniqueRef + 1
          \nFixtureId = gnUniqueRef
        EndIf
      EndIf
    EndWith
    If bFixtureInfoPresent
      debugMsg(sProcName, "create new fixture")
      nHoldCurrItem = gnWEPFixtureCurrItem
      createWEPFixture()
      gnWEPFixtureCurrItem = nHoldCurrItem
      ; WEP_setCurrentFixture(nHoldCurrItem)
    EndIf
  EndIf
  
EndProcedure

Procedure WEP_btnCopyDMXStartsFrom_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling WEM_Form_Show(#True, #WED, #WEP, #SCS_WEM_LT_COPYFROM)")
  WEM_Form_Show(#True, #WED, #WEP, #SCS_WEM_LT_COPYFROM)
  ; must return now because PB doesn't block processing while the modal form is displayed
  ProcedureReturn
  
EndProcedure

Procedure WEP_stopProdTestIfRunning()
  PROCNAMEC()
  
  ; added 3Mar2019 11.8.0.2ax following bug reported by email by Ian Norman, 1Mar2019
  If IsGadget(WEP\btnTestVidCapStop)
    If getVisible(WEP\btnTestVidCapStop)
      WEP_btnTestVidCapStop_Click()
    EndIf
  EndIf
  If IsGadget(WEP\btnTestToneCancel)
    If getVisible(WEP\btnTestToneCancel)
      debugMsg(sProcName, "calling WEP_cancelTestTone()")
      WEP_cancelTestTone()
    EndIf
  EndIf
  If IsGadget(WEP\btnTestLiveInputCancel)
    If getVisible(WEP\btnTestLiveInputCancel)
      WEP_cancelTestLiveInput()
    EndIf
  EndIf
  ; nb may need to add other 'stop test' calls to this procedure
  ; end added 3Mar2019 11.8.0.2ax following bug reported by email by Ian Norman, 1Mar2019
  
EndProcedure

Procedure WEP_buildPopupMenu_GridColors()
  ; Build popup menu for fixture type channel colors in the DMX display window (see fmDMXDisplay.pbi)
  PROCNAMEC()
  ; debugMsg(sProcName, #SCS_START)
  If scsCreatePopupMenu(#WEP_mnuGridColors)
    scsMenuItem(#WEP_mnuGrdColBlack, "mnuGrdColBlack")
    scsMenuItem(#WEP_mnuGrdColWhite, "mnuGrdColWhite")
    scsMenuItem(#WEP_mnuGrdColRed, "mnuGrdColRed")
    scsMenuItem(#WEP_mnuGrdColGreen, "mnuGrdColGreen")
    scsMenuItem(#WEP_mnuGrdColBlue, "mnuGrdColBlue")
    scsMenuItem(#WEP_mnuGrdColAmber, "mnuGrdColAmber")
    scsMenuItem(#WEP_mnuGrdColUV, "mnuGrdColUV")
    scsMenuItem(#WEP_mnuGrdColPicker, "mnuGrdColPicker")
  EndIf
EndProcedure

Procedure WEP_buildPopupMenu_CSDevTypes(nCurrDevType)
  ; Build popup menu for control send device types
  PROCNAMEC()
  ; debugMsg0(sProcName, #SCS_START + ", nCurrDevType=" + decodeDevType(nCurrDevType))
  If IsMenu(#WEP_mnuCSDevTypes) = #False
    If scsCreatePopupMenu(#WEP_mnuCSDevTypes)
      If grLicInfo\nLicLevel >= #SCS_LIC_PRO
        scsMenuItem(#WEP_mnuCSDevTypeMidiOut, decodeDevTypeL(#SCS_DEVTYPE_CS_MIDI_OUT), "", #False)
        scsMenuItem(#WEP_mnuCSDevTypeMidiThru, decodeDevTypeL(#SCS_DEVTYPE_CS_MIDI_THRU), "", #False)
        scsMenuItem(#WEP_mnuCSDevTypeRS232Out, decodeDevTypeL(#SCS_DEVTYPE_CS_RS232_OUT), "", #False)
        If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
          scsMenuItem(#WEP_mnuCSDevTypeNetworkOut, decodeDevTypeL(#SCS_DEVTYPE_CS_NETWORK_OUT), "", #False)
          scsMenuItem(#WEP_mnuCSDevTypeHTTPRequest, decodeDevTypeL(#SCS_DEVTYPE_CS_HTTP_REQUEST), "", #False)
        EndIf
      EndIf
    EndIf
  EndIf
  If grLicInfo\nLicLevel >= #SCS_LIC_PRO
    If nCurrDevType = #SCS_DEVTYPE_CS_MIDI_OUT : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeMidiOut, 1) : Else : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeMidiOut, 0) : EndIf
    If nCurrDevType = #SCS_DEVTYPE_CS_MIDI_THRU : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeMidiThru, 1) : Else : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeMidiThru, 0) : EndIf
    If nCurrDevType = #SCS_DEVTYPE_CS_RS232_OUT : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeRS232Out, 1) : Else : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeRS232Out, 0) : EndIf
    If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
      If nCurrDevType = #SCS_DEVTYPE_CS_NETWORK_OUT : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeNetworkOut, 1) : Else : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeNetworkOut, 0) : EndIf
      If nCurrDevType = #SCS_DEVTYPE_CS_HTTP_REQUEST : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeHTTPRequest, 1) : Else : SetMenuItemState(#WEP_mnuCSDevTypes, #WEP_mnuCSDevTypeHTTPRequest, 0) : EndIf
    EndIf
  EndIf
EndProcedure

Procedure WEP_mnuGridColor_Selection(nEventMenu)
  PROCNAMEC()
  Protected nFTIndex, nFTCIndex
  Protected nCurrItemColor, nSelectedColor
  
  nFTIndex = grWEP\nCurrentFixTypeNo
  nFTCIndex = grWEP\nCurrentFixTypeChanNo
  If nFTIndex >= 0 And nFTCIndex >= 0
    With grProdForDevChgs\aFixTypes(nFTIndex)\aFixTypeChan(nFTCIndex)      
      nCurrItemColor = \nDMXTextColor
      Select nEventMenu
        Case #WEP_mnuGrdColBlack
          nSelectedColor = #SCS_Black
        Case #WEP_mnuGrdColWhite
          nSelectedColor = #SCS_White
        Case #WEP_mnuGrdColRed
          nSelectedColor = #SCS_Red
        Case #WEP_mnuGrdColGreen
          nSelectedColor = #SCS_Dark_Green ; a darker green than RGB(0,255,0) as this shows up better against the 'very light grey' background
        Case #WEP_mnuGrdColBlue
          nSelectedColor = #SCS_Blue
        Case #WEP_mnuGrdColYellow
          nSelectedColor = #SCS_Yellow
        Case #WEP_mnuGrdColCyan
          nSelectedColor = RGB(0,255,255) ; Also in DMX_setDMXTextColorFromDesc()
        Case #WEP_mnuGrdColAmber
          nSelectedColor = RGB(255,191,0) ; Also in DMX_setDMXTextColorFromDesc()
        Case #WEP_mnuGrdColUV
          nSelectedColor = RGB(158,0,255) ; Also in DMX_setDMXTextColorFromDesc()
        Case #WEP_mnuGrdColPicker
          nSelectedColor = ColorRequester(nCurrItemColor)
          If nSelectedColor = -1
            nSelectedColor = nCurrItemColor
          EndIf
      EndSelect
      If nSelectedColor <> \nDMXTextColor
        \nDMXTextColor = nSelectedColor
        WEP_paintDMXTextColor(nFTIndex, nFTCIndex)
        WEP_setDevChgsBtns()          
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_chkMMCApplyFadeForStop_Click()
  PROCNAMEC()
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCueDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      \bMMCApplyFadeForStop = getOwnState(WEP\chkMMCApplyFadeForStop)
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure WEP_populateMidiCCIfReqd(nCmdNo, nDisplayIndex, nCtrlMethod, nThisCmd)
  Protected m
  Static Dim nPrevDisplayIndex(#SCS_MAX_MIDI_COMMAND), Dim nPrevCtrlMethod(#SCS_MAX_MIDI_COMMAND), Dim nPrevThisCmd(#SCS_MAX_MIDI_COMMAND)
  
  If nDisplayIndex <> nPrevDisplayIndex(nCmdNo) Or nCtrlMethod <> nPrevCtrlMethod(nCmdNo) Or nThisCmd <> nPrevThisCmd(nCmdNo)
    ClearGadgetItems(WEP\cboMidiCC[nDisplayIndex])
    AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, #SCS_BLANK_CBO_ENTRY)
    If (nCtrlMethod = #SCS_CTRLMETHOD_PC128) And (nThisCmd = $C)   ; $C = program change
      For m = 1 To 128
        gnLabelSpecial = #PB_Compiler_Line
        AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, Trim(Str(m)))
      Next m
    Else
      For m = 0 To 127
        AddGadgetItem(WEP\cboMidiCC[nDisplayIndex], -1, Trim(Str(m)))
      Next m
    EndIf
    nPrevThisCmd(nCmdNo) = nThisCmd
    nPrevCtrlMethod(nCmdNo) = nCtrlMethod
    nPrevDisplayIndex(nCmdNo) = nDisplayIndex
  EndIf
EndProcedure

Procedure WEP_populateMidiVVIfReqd(nGadgetNo)
;   PROCNAMEC()
  Protected m
;   Protected qStartTime.q, qEndTime.q
;   qStartTime = ElapsedMilliseconds()
  If CountGadgetItems(nGadgetNo) < 2
    ClearGadgetItems(nGadgetNo)
    addGadgetItemWithData(nGadgetNo, #SCS_BLANK_CBO_ENTRY, -1)
    addGadgetItemWithData(nGadgetNo, "*", #SCS_MIDI_ANY_VALUE)
    For m = 0 To 127
      addGadgetItemWithData(nGadgetNo, Str(m), m)
    Next m
  EndIf
;   qEndTime = ElapsedMilliseconds()
;   debugMsg(sProcName, "time=" + Str(qEndTime - qStartTime))
EndProcedure

Procedure WEP_populateThresholdVVIfReqd(nGadgetNo)
  Protected m
  If CountGadgetItems(nGadgetNo) = 0
    ClearGadgetItems(nGadgetNo)
    For m = 0 To 9
      addGadgetItemWithData(WEP\cboThresholdVV, Str(m), m)
    Next m
  EndIf
EndProcedure

Procedure WEP_loadDevTabAudio(nDevMapPtr, nDevIndex=-1, bForceReload=#False)
  PROCNAMEC()
  Protected d, d2, d3, n
  Protected sPhysicalDev.s, bFound, nAudioDriver, bAlreadyInComboBox
  Protected nFirstDevIndex, nLastDevIndex
  
  ; debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex + ", bForceReload=" + strB(bForceReload))
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxAudioLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  ; debugMsg(sProcName, "nFirstDevIndex=" + nFirstDevIndex + ", nLastDevIndex=" + nLastDevIndex + ", gnSortedAudioDevs=" + gnSortedAudioDevs)
  
  With WEP
    If IsGadget(\cboAudioPhysicalDev(0))
      If nLastDevIndex > ArraySize(\cboAudioPhysicalDev())
        createWEPAudDevs()
      EndIf
    EndIf
    If nDevMapPtr >= 0
      nAudioDriver = grMapsForDevChgs\aMap(nDevMapPtr)\nAudioDriver
      ; debugMsg(sProcName, "grMapsForDevChgs\aMap(" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ")\nAudioDriver=" + decodeDriver(nAudioDriver))
    EndIf
    For d = nFirstDevIndex To nLastDevIndex
      If IsGadget(WEP\cboAudioPhysicalDev(d))
        If bForceReload Or CountGadgetItems(WEP\cboAudioPhysicalDev(d)) = 0 Or 1=1
          ClearGadgetItems(WEP\cboAudioPhysicalDev(d))
          ; debugMsg(sProcName, "ClearGadgetItems(WEP\cboAudioPhysicalDev(" + d + "))")
          If nDevMapPtr >= 0
            For d2 = 0 To (gnSortedAudioDevs-1)
              ; debugMsg(sProcName, "nAudioDriver=" + decodeDriver(nAudioDriver) + ", gaAudioDevSorted(" + d2 + ")\nAudioDriver=" + decodeDriver(gaAudioDevSorted(d2)\nAudioDriver) + ", \sDesc=" + gaAudioDevSorted(d2)\sDesc)
              If gaAudioDevSorted(d2)\nAudioDriver = nAudioDriver
                addGadgetItemWithData(WEP\cboAudioPhysicalDev(d), gaAudioDevSorted(d2)\sDesc, d2)
                ; debugMsg(sProcName, "addGadgetItemWithData(WEP\cboAudioPhysicalDev(" + d + "), " + gaAudioDevSorted(d2)\sDesc + ", " + d2 + ")")
              EndIf
            Next d2
            ; add any physical audio devices listed in the device map which are not in the list of currently available devices
            d3 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
            While d3 >= 0
              If (grMapsForDevChgs\aDev(d3)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (grMapsForDevChgs\aDev(d3)\bExists)
                sPhysicalDev = grMapsForDevChgs\aDev(d3)\sPhysicalDev
                If sPhysicalDev
                  bFound = #False
                  For d2 = 0 To (gnSortedAudioDevs-1)
                    If gaAudioDevSorted(d2)\sDesc = sPhysicalDev
                      bFound = #True
                      Break
                    EndIf
                  Next d2
                  If bFound = #False
                    bAlreadyInComboBox = #False
                    For n = 0 To CountGadgetItems(WEP\cboAudioPhysicalDev(d)) - 1
                      If GetGadgetItemText(WEP\cboAudioPhysicalDev(d), n) = sPhysicalDev
                        bAlreadyInComboBox = #True
                        Break
                      EndIf
                    Next n
                    If bAlreadyInComboBox = #False
                      addGadgetItemWithData(WEP\cboAudioPhysicalDev(d), sPhysicalDev, -1) ; -1 in data indicates unavailable device
                      ; debugMsg(sProcName, "addGadgetItemWithData(WEP\cboAudioPhysicalDev(" + d + "), " + sPhysicalDev + ", -1)")
                    EndIf
                  EndIf
                EndIf ; EndIf sPhysicalDev
              EndIf
              d3 = grMapsForDevChgs\aDev(d3)\nNextDevIndex
            Wend
          EndIf ; EndIf nDevMapPtr >= 0
        EndIf ; EndIf CountGadgetItems(WEP\cboAudioPhysicalDev(d)) = 0
      EndIf ; EndIf IsGadget(WEP\cboAudioPhysicalDev(d))
      
      ; debugMsg0(sProcName, "IsGadget(\cboNumChans(" + d + "))=" + IsGadget(\cboNumChans(d)))
      If IsGadget(\cboNumChans(d))
        ; debugMsg0(sProcName, "CountGadgetItems(\cboNumChans(" + d + "))=" + CountGadgetItems(\cboNumChans(d)))
        If CountGadgetItems(\cboNumChans(d)) = 0
          ClearGadgetItems(\cboNumChans(d))
          For n = 1 To 16
            AddGadgetItem(\cboNumChans(d), -1, decodeNumChans(n))
          Next n
        EndIf
      EndIf
      
    Next d
    
    If IsGadget(\cboDfltDevTrim)
      If CountGadgetItems(\cboDfltDevTrim) = 0
        ClearGadgetItems(\cboDfltDevTrim)
        addGadgetItemWithData(\cboDfltDevTrim, #SCS_ZERO_DBTRIM, 0)
        addGadgetItemWithData(\cboDfltDevTrim, "-10", -10)
        addGadgetItemWithData(\cboDfltDevTrim, "-20", -20)
        addGadgetItemWithData(\cboDfltDevTrim, "-30", -30)
        addGadgetItemWithData(\cboDfltDevTrim, "-40", -40)
        addGadgetItemWithData(\cboDfltDevTrim, "-50", -50)
      EndIf
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_loadDevTabVidAud(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected d, d2, d3
  Protected sPhysicalDev.s, bFound
  Protected nFirstDevIndex, nLastDevIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex)
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxVidAudLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  With WEP
    If IsGadget(\cboVidAudPhysicalDev(0))
      If nLastDevIndex > ArraySize(\cboVidAudPhysicalDev())
        createWEPVidAudDevs()
      EndIf
    EndIf
    For d = nFirstDevIndex To nLastDevIndex
      If IsGadget(WEP\cboVidAudPhysicalDev(d))
        If CountGadgetItems(WEP\cboVidAudPhysicalDev(d)) = 0
          ClearGadgetItems(WEP\cboVidAudPhysicalDev(d))
          ; debugMsg(sProcName, "ClearGadgetItems(WEP\cboVidAudPhysicalDev(" + d + "))")
          If nDevMapPtr >= 0
            For d2 = 0 To (gnNumVideoAudioDevs-1)
              addGadgetItemWithData(WEP\cboVidAudPhysicalDev(d), gaVideoAudioDev(d2)\sVidAudName, d2)
              ; debugMsg(sProcName, "addGadgetItemWithData(WEP\cboVidAudPhysicalDev(" + d + "), " + gaVideoAudioDev(d2)\sVidAudName + ", " +d2 + ")")
            Next d2
            ; add any physical audio devices listed in the device map which are not in the list of currently available devices
            d3 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
            While d3 >= 0
              If (grMapsForDevChgs\aDev(d3)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE) And (grMapsForDevChgs\aDev(d3)\bExists)
                sPhysicalDev = grMapsForDevChgs\aDev(d3)\sPhysicalDev
                If sPhysicalDev
                  bFound = #False
                  For d2 = 0 To (gnNumVideoAudioDevs-1)
                    If gaVideoAudioDev(d2)\sVidAudName = sPhysicalDev
                      bFound = #True
                      Break
                    EndIf
                  Next d2
                  If bFound = #False
                    addGadgetItemWithData(WEP\cboVidAudPhysicalDev(d), sPhysicalDev, -1) ; -1 in data indicates unavailable device
                    ; debugMsg(sProcName, "addGadgetItemWithData(WEP\cboVidAudPhysicalDev(" + d + "), " + sPhysicalDev + ", -1)")
                  EndIf
                EndIf ; EndIf sPhysicalDev
              EndIf
              d3 = grMapsForDevChgs\aDev(d3)\nNextDevIndex
            Wend
          EndIf ; EndIf nDevMapPtr >= 0
        EndIf ; EndIf CountGadgetItems(WEP\cboVidAudPhysicalDev(d)) = 0
      EndIf ; EndIf IsGadget(WEP\cboVidAudPhysicalDev(d))
    Next d
  EndWith
  
EndProcedure

Procedure WEP_loadDevTabVidCap(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected d, d2, d3
  Protected sPhysicalDev.s, bFound
  Protected nFirstDevIndex, nLastDevIndex
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxVidCapLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  With WEP
    If IsGadget(\cboVidCapPhysicalDev(0))
      If nLastDevIndex > ArraySize(\cboVidCapPhysicalDev())
        createWEPVidCapDevs()
      EndIf
    EndIf
    For d = nFirstDevIndex To nLastDevIndex
      If IsGadget(\cboVidCapPhysicalDev(d))
        If CountGadgetItems(\cboVidCapPhysicalDev(d)) = 0
          ClearGadgetItems(\cboVidCapPhysicalDev(d))
          If nDevMapPtr >= 0
            For d2 = 0 To (gnNumVideoCaptureDevs-1)
              addGadgetItemWithData(\cboVidCapPhysicalDev(d), gaVideoCaptureDev(d2)\sVidCapName, d2)
            Next d2
            ; add any physical capture devices listed in the device map which are not in the list of currently available devices
            d3 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
            While d3 >= 0
              If (grMapsForDevChgs\aDev(d3)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE) And (grMapsForDevChgs\aDev(d3)\bExists)
                sPhysicalDev = grMapsForDevChgs\aDev(d3)\sPhysicalDev
                If sPhysicalDev
                  bFound = #False
                  For d2 = 0 To (gnNumVideoCaptureDevs-1)
                    If gaVideoCaptureDev(d2)\sVidCapName = sPhysicalDev
                      bFound = #True
                      Break
                    EndIf
                  Next d2
                  If bFound = #False
                    addGadgetItemWithData(WEP\cboVidCapPhysicalDev(d), sPhysicalDev, -1)   ; -1 in data indicates unavailable device
                  EndIf
                EndIf
              EndIf
              d3 = grMapsForDevChgs\aDev(d3)\nNextDevIndex
            Wend
          EndIf
        EndIf
      EndIf
    Next d
  EndWith
  
EndProcedure

Procedure WEP_loadDevTabFixType(nDevMapPtr, nFixTypeIndex=-1)
  PROCNAMEC()
  Protected nFirstFixTypeIndex, nLastFixTypeIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nFixTypeIndex=" + nFixTypeIndex)
  
  If nFixTypeIndex = -1
    nFirstFixTypeIndex = 0
    nLastFixTypeIndex = grProdForDevChgs\nMaxFixTypeDisplay
  Else
    nFirstFixTypeIndex = nFixTypeIndex
    nLastFixTypeIndex = nFixTypeIndex
  EndIf
  debugMsg(sProcName, "nFirstFixTypeIndex=" + nFirstFixTypeIndex + ", nLastFixTypeIndex=" + nLastFixTypeIndex + ", ArraySize(WEP\cboLightingDevType())=" + ArraySize(WEP\cboLightingDevType()) + ", grProdForDevChgs\nMaxLightingLogicalDevDisplay=" + grProdForDevChgs\nMaxLightingLogicalDevDisplay)
  
  With WEP
    If IsGadget(\cntTabFixTypes)
      If (grProd\bLightingPre118) Or (grLicInfo\nMaxFixTypes < 0)
        setVisible(\cntTabFixTypes, #False)
        setVisible(\cntTabFixTypesPre118, #True)
      Else
        setVisible(\cntTabFixTypes, #True)
        setVisible(\cntTabFixTypesPre118, #False)
      EndIf
    EndIf
    If IsGadget(\txtFixTypeName(0))
      If nLastFixTypeIndex > ArraySize(\txtFixTypeName())
        createWEPFixTypes()
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WEP_loadDevTabLighting(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected nFirstDevIndex, nLastDevIndex, d, sDMXOut.s, nDevType
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex)
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxLightingLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  debugMsg(sProcName, "nFirstDevIndex=" + nFirstDevIndex + ", nLastDevIndex=" + nLastDevIndex + ", ArraySize(WEP\cboLightingDevType())=" + ArraySize(WEP\cboLightingDevType()) + ", grProdForDevChgs\nMaxLightingLogicalDevDisplay=" + grProdForDevChgs\nMaxLightingLogicalDevDisplay)
  
  With WEP
    If IsGadget(\cboLightingDevType(0))
      If nLastDevIndex > ArraySize(\cboLightingDevType())
        createWEPLightingDevs()
      EndIf
    EndIf
    sDMXOut = decodeDevTypeL(#SCS_DEVTYPE_LT_DMX_OUT)
    For d = nFirstDevIndex To nLastDevIndex
      If IsGadget(\cboLightingDevType(d))
        If CountGadgetItems(\cboLightingDevType(d)) = 0
          addGadgetItemWithData(\cboLightingDevType(d), "", #SCS_DEVTYPE_NONE)
          addGadgetItemWithData(\cboLightingDevType(d), sDMXOut, #SCS_DEVTYPE_LT_DMX_OUT)
        EndIf
        nDevType = grProdForDevChgs\aLightingLogicalDevs(d)\nDevType
        setComboBoxByData(\cboLightingDevType(d), nDevType)
      EndIf
    Next d
  EndWith
  
EndProcedure

Procedure WEP_loadDevTabLiveInput(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected d, d2, d3, n
  Protected sPhysicalDev.s, bFound
  Protected nFirstDevIndex, nLastDevIndex
  Protected nAudioDriver
  Static nPrevAudioDriver
  Static bStaticLoaded, sDummyText.s
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex)
  
  If bStaticLoaded = #False
    sDummyText = Lang("Misc", "DummyLiveInput")
    bStaticLoaded = #True
  EndIf
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxLiveInputLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  nAudioDriver = gnCurrAudioDriver
  With WEP
    If IsGadget(\cboLivePhysicalDev(0))
      If nLastDevIndex > ArraySize(\cboLivePhysicalDev())
        createWEPLiveInputDevs()
      EndIf
    EndIf
    For d = nFirstDevIndex To nLastDevIndex
      ; debugMsg(sProcName, "d=" + d + " --------------------------")
      If IsGadget(WEP\cboLivePhysicalDev(d))
        If CountGadgetItems(WEP\cboLivePhysicalDev(d)) = 0 Or nAudioDriver <> nPrevAudioDriver
          ClearGadgetItems(\cboLivePhysicalDev(d))
          If nAudioDriver = #SCS_DRV_SMS_ASIO
            ; live input only available with SoundMan-Server
            If nDevMapPtr >= 0
              For d2 = 0 To gnMaxConnectedDev
                ; debugMsg(sProcName, "gaConnectedDev(" + d2 + ")\nDevType=" + decodeDevType(gaConnectedDev(d2)\nDevType) + ", \nDriver=" + decodeDriver(gaConnectedDev(d2)\nDriver) + ", nAudioDriver=" + decodeDriver(nAudioDriver))
                If (gaConnectedDev(d2)\nDevType = #SCS_DEVTYPE_LIVE_INPUT) And (gaConnectedDev(d2)\nDriver = nAudioDriver)
                  ; debugMsg(sProcName, "gaConnectedDev(" + d2 + ")\nInputs=" + gaConnectedDev(d2)\nInputs + ", \sPhysicalDevDesc=" + gaConnectedDev(d2)\sPhysicalDevDesc)
                  If gaConnectedDev(d2)\nInputs > 0
                    debugMsg(sProcName, "calling addGadgetItemWithData(\cboLivePhysicalDev(" + d + "), " + gaConnectedDev(d2)\sPhysicalDevDesc + ", " + d2 + ")")
                    addGadgetItemWithData(\cboLivePhysicalDev(d), gaConnectedDev(d2)\sPhysicalDevDesc, d2)
                  EndIf
                EndIf
              Next d2
              ; add any physical live input devices listed in the device map which are not in the list of currently available devices
              d3 = grMapsForDevChgs\aMap(nDevMapPtr)\nFirstDevIndex
              While d3 >= 0
                If (grMapsForDevChgs\aDev(d3)\nDevType = #SCS_DEVTYPE_LIVE_INPUT) And (grMapsForDevChgs\aDev(d3)\bExists)
                  ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + d3 + ")\sPhysicalDev=" + grMapsForDevChgs\aDev(d3)\sPhysicalDev)
                  sPhysicalDev = grMapsForDevChgs\aDev(d3)\sPhysicalDev
                  If sPhysicalDev
                    bFound = #False
                    For d2 = 0 To CountGadgetItems(\cboLivePhysicalDev(d))
                      If GetGadgetItemText(\cboLivePhysicalDev(d), d2) = sPhysicalDev
                        bFound = #True
                        Break
                      EndIf
                    Next d2
                    If bFound = #False
                      ; debugMsg(sProcName, "calling addGadgetItemWithData(\cboLivePhysicalDev(" + d + "), " + sPhysicalDev + ", -1)")
                      If sPhysicalDev <> sDummyText ; nb 'dummy' will be added unconditionally after this loop
                        addGadgetItemWithData(\cboLivePhysicalDev(d), sPhysicalDev, -1) ; -1 in data indicates unavailable device
                      EndIf
                    EndIf
                  EndIf
                EndIf
                d3 = grMapsForDevChgs\aDev(d3)\nNextDevIndex
              Wend
            EndIf ; EndIf nDevMapPtr >= 0
          EndIf ; EndIf nAudioDriver = #SCS_DRV_SMS_ASIO
          debugMsg(sProcName, "calling addGadgetItemWithData(\cboLivePhysicalDev(" + d + "), " + #DQUOTE$ + Lang("Misc", "DummyLiveInput") + #DQUOTE$ + ", -2)")
          addGadgetItemWithData(\cboLivePhysicalDev(d), sDummyText, -2) ; -2 indicates dummy
          
          If IsGadget(\cboNumInputChans(d))
            ClearGadgetItems(\cboNumInputChans(d))
            For n = 1 To 2  ; mono or stereo only for live inputs
              AddGadgetItem(\cboNumInputChans(d), -1, decodeNumChans(n))
            Next n
          EndIf
        EndIf
      EndIf
    Next d
  EndWith
  nPrevAudioDriver = nAudioDriver
  
EndProcedure

Procedure WEP_cboVidCapFormat_Click()
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nCurrentDevMapDevPtr = grWEP\nCurrentVidCapDevMapDevPtr
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      If GGS(WEP\cboVidCapDevFormat) = 0
        \sVidCapFormat = "" ; default
      Else
        \sVidCapFormat = GGT(WEP\cboVidCapDevFormat)
      EndIf
      debugMsg(sProcName, "WEP\cboVidCapDevFormat=" + GGT(WEP\cboVidCapDevFormat) + ", grMapsForDevChgs\aDev(" + nCurrentDevMapDevPtr + ")\sVidCapFormat=" + \sVidCapFormat)
      grCED\bProdChanged = #True
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_txtVidCapFrameRate_Validate()
  PROCNAMEC()
  Protected sVidCapFrameRate.s, dVidCapFrameRate.d, bError, sErrorMsg.s
  Protected nCurrentDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  sVidCapFrameRate = Trim(GGT(WEP\txtVidCapDevFrameRate))
  If sVidCapFrameRate
    If IsNumeric(sVidCapFrameRate) = #False
      bError = #False
    Else
      dVidCapFrameRate = ValD(sVidCapFrameRate)
      If dVidCapFrameRate = 0
        ; OK
      ElseIf dVidCapFrameRate >= 5 And dVidCapFrameRate <= 60
        ; OK
      Else
        bError = #True
      EndIf
    EndIf
    If bError
      sErrorMsg = LangPars("Errors", "FrameRate", "5", "60")
      scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
      ProcedureReturn #False
    EndIf
  EndIf
  nCurrentDevMapDevPtr = grWEP\nCurrentVidCapDevMapDevPtr
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      \dVidCapFrameRate = dVidCapFrameRate
      If sVidCapFrameRate <> strDTrimmed(\dVidCapFrameRate,2)
        SGT(WEP\txtVidCapDevFrameRate, strDTrimmed(\dVidCapFrameRate,2))
      EndIf
      WEP_setDevChgsBtns()
      WEP_setRetryActivateBtn()
    EndWith
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WEP_loadDevTabCtrlSend(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected nFirstDevIndex, nLastDevIndex
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex)
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  debugMsg(sProcName, "nFirstDevIndex=" + nFirstDevIndex + ", nLastDevIndex=" + nLastDevIndex + ", ArraySize(WEP\cboLightingDevType())=" + ArraySize(WEP\cboLightingDevType()) + ", grProdForDevChgs\nMaxLightingLogicalDevDisplay=" + grProdForDevChgs\nMaxLightingLogicalDevDisplay)
  
  With WEP
    If IsGadget(\lblCtrlDevNo(0))
      If nLastDevIndex > ArraySize(\lblCtrlDevNo())
        createWEPCtrlSendDevs()
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WEP_setCtrlDevTypeText(nDevNo)
  PROCNAMEC()
  Static sMidiOut.s, sMidiThru.s, sRS232Out.s, sNetworkOut.s, sHTTPRequest.s, sDMXOut.s, sDownArrow.s
  Static nTextHeight, nLeft, nTop, nArrowLeft, hFont
  Static bStaticLoaded
  Protected sItemText.s
  
  ; debugMsg(sProcName, #SCS_START + ", nDevNo=" + nDevNo)
  
  If bStaticLoaded = #False
    sDownArrow = Chr(709)
    sMidiOut = decodeDevTypeL(#SCS_DEVTYPE_CS_MIDI_OUT)
    sMidiThru = decodeDevTypeL(#SCS_DEVTYPE_CS_MIDI_THRU)
    sRS232Out = decodeDevTypeL(#SCS_DEVTYPE_CS_RS232_OUT)
    sNetworkOut = decodeDevTypeL(#SCS_DEVTYPE_CS_NETWORK_OUT)
    sHTTPRequest = decodeDevTypeL(#SCS_DEVTYPE_CS_HTTP_REQUEST)
    hFont = GetGadgetFont(WEP\txtCtrlLogicalDev(0))
    bStaticLoaded = #True
  EndIf
  
  If nDevNo <= grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay
    With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
      Select \nDevType
        Case #SCS_DEVTYPE_CS_MIDI_OUT : sItemText = sMidiOut
        Case #SCS_DEVTYPE_CS_MIDI_THRU : sItemText = sMidiThru
        Case #SCS_DEVTYPE_CS_RS232_OUT : sItemText = sRS232Out
        Case #SCS_DEVTYPE_CS_NETWORK_OUT : sItemText = sNetworkOut
        Case #SCS_DEVTYPE_CS_HTTP_REQUEST : sItemText = sHTTPRequest
        Default : sItemText = ""
      EndSelect
    EndWith
  Else
    sItemText = ""
  EndIf
  If StartDrawing(CanvasOutput(WEP\cvsCtrlDevType(nDevNo)))
    DrawingFont(hFont)
    If nTextHeight = 0
      nTextHeight = TextHeight("Gg")
      nTop = (GadgetHeight(WEP\cvsCtrlDevType(nDevNo)) - nTextHeight) >> 1
      nLeft = 4
      nArrowLeft = GadgetWidth(WEP\cvsCtrlDevType(nDevNo)) - TextWidth(sDownArrow) - nLeft
    EndIf
    Box(0,0,OutputWidth(),OutputHeight(),#SCS_Very_Light_Grey)
    DrawingMode(#PB_2DDrawing_Outlined)
    Box(0,0,OutputWidth(),OutputHeight(),#SCS_Mid_Grey)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(nLeft, nTop, sItemText, #SCS_Black)
    DrawText(nArrowLeft, nTop, sDownArrow, #SCS_Black)
    StopDrawing()
    WEP\cvsCtrlDevTypeText(nDevNo) = sItemText
  EndIf
  ED_fcCtrlDevType(nDevNo)
EndProcedure

Procedure WEP_loadDevTabCueCtrl(nDevMapPtr, nDevIndex=-1)
  PROCNAMEC()
  Protected d
  Protected nFirstDevIndex, nLastDevIndex
  Static bStaticLoaded, sMidiIn.s, sRS232In.s, sNetworkIn.s, sDMXIn.s
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + grMapsForDevChgs\aMap(nDevMapPtr)\sDevMapName + ", nDevIndex=" + nDevIndex)
  
  If bStaticLoaded = #False
    sMidiIn = decodeDevTypeL(#SCS_DEVTYPE_CC_MIDI_IN)
    sRS232In = decodeDevTypeL(#SCS_DEVTYPE_CC_RS232_IN)
    sNetworkIn = decodeDevTypeL(#SCS_DEVTYPE_CC_NETWORK_IN)
    sDMXIn = decodeDevTypeL(#SCS_DEVTYPE_CC_DMX_IN)
    bStaticLoaded = #True
  EndIf
  
  If nDevIndex = -1
    nFirstDevIndex = 0
    nLastDevIndex = grProdForDevChgs\nMaxCueCtrlLogicalDevDisplay
  Else
    nFirstDevIndex = nDevIndex
    nLastDevIndex = nDevIndex
  EndIf
  With WEP
    If IsGadget(\cboCueDevType(0))
      If nLastDevIndex > ArraySize(\cboCueDevType())
        createWEPCueCtrlDevs()
      EndIf
    EndIf
    For d = nFirstDevIndex To nLastDevIndex
      If IsGadget(\cboCueDevType(d))
        If CountGadgetItems(\cboCueDevType(d)) = 0
          ClearGadgetItems(\cboCueDevType(d))
          addGadgetItemWithData(\cboCueDevType(d), "", #SCS_DEVTYPE_NONE)
          addGadgetItemWithData(\cboCueDevType(d), sMidiIn, #SCS_DEVTYPE_CC_MIDI_IN)
          addGadgetItemWithData(\cboCueDevType(d), sRS232In, #SCS_DEVTYPE_CC_RS232_IN)
          If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
            addGadgetItemWithData(\cboCueDevType(d), sNetworkIn, #SCS_DEVTYPE_CC_NETWORK_IN)
            addGadgetItemWithData(\cboCueDevType(d), sDMXIn, #SCS_DEVTYPE_CC_DMX_IN)
          EndIf
        EndIf
      EndIf
    Next d
  EndWith
  
EndProcedure

Procedure WEP_addDeviceIfReqd(nDevGrp, nIndex, nParentIndex=-1)
  PROCNAMEC()
  Protected nDevMapPtr
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nIndex=" + nIndex + ", nParentIndex=" + nParentIndex)
  
  With grProdForDevChgs
    debugMsg(sProcName, "grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
    nDevMapPtr = getDevMapPtr(@grMapsForDevChgs, grMapsForDevChgs\sSelectedDevMapName)
    debugMsg(sProcName, "getDevMapPtr(@grMapsForDevChgs, " + #DQUOTE$ + grMapsForDevChgs\sSelectedDevMapName + #DQUOTE$ + ") returned " + nDevMapPtr)
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        createWEPAudDevs() ; create WEP gadgets for any new audio devices
        WEP_loadDevTabAudio(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaAudioDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        createWEPVidAudDevs() ; create WEP gadgets for any new video audio devices
        WEP_loadDevTabVidAud(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaVidAudDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        createWEPVidCapDevs() ; create WEP gadgets for any new video capture devices
        WEP_loadDevTabVidCap(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaVidCapDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_FIX_TYPE
        createWEPFixTypes() ; create WEP gadgets for any new fixture types
        WEP_loadDevTabFixType(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaFixTypes, -1, nIndex)
        
      Case #SCS_DEVGRP_LIGHTING
        createWEPLightingDevs() ; create WEP gadgets for any new lighting devices
        WEP_loadDevTabLighting(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaLightingDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_CTRL_SEND
        createWEPCtrlSendDevs() ; create WEP gadgets for any new control send devices
        debugMsg(sProcName, "calling WEP_loadDevTabCtrlSend(" + nDevMapPtr + ", " + nIndex + ")")
        WEP_loadDevTabCtrlSend(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaCtrlDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_CUE_CTRL
        createWEPCueCtrlDevs() ; create WEP gadgets for any new cue control devices
        WEP_loadDevTabCueCtrl(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaCueDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_LIVE_INPUT
        createWEPLiveInputDevs() ; create WEP gadgets for any new live input devices
        WEP_loadDevTabLiveInput(nDevMapPtr, nIndex)
        ensureScrollAreaItemVisible(WEP\scaLiveDevs, -1, nIndex)
        
      Case #SCS_DEVGRP_IN_GRP
        createWEPInputGroups() ; create WEP gadgets for any new input groups
        ensureScrollAreaItemVisible(WEP\scaInGrps, -1, nIndex)
        
      Case #SCS_DEVGRP_IN_GRP_LIVE_INPUT
        ; NB 'input group live inputs' are the live inputs assigned to this input group
        createWEPInputGroupLiveInputs(nParentIndex) ; create WEP gadgets for any new input group live inputs
        ensureScrollAreaItemVisible(WEP\scaInGrpLiveInputs, -1, nIndex)
        
    EndSelect
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WEP_enableTestTonePanControls()
  PROCNAMEC()
  Protected bEnablePan, bEnableCenter
  
  With grProdForDevChgs
    If grWEP\nCurrentAudDevNo >= 0
      If \aAudioLogicalDevs(grWEP\nCurrentAudDevNo)\nNrOfOutputChans = 2
        bEnablePan = #True
      EndIf
    EndIf
    If bEnablePan
      If \fTestTonePan <> #SCS_PANCENTRE_SINGLE
        bEnableCenter = #True
      EndIf
    EndIf
    If SLD_getEnabled(WEP\sldTestTonePan) <> bEnablePan
      SLD_setEnabled(WEP\sldTestTonePan, bEnablePan)
    EndIf
    setEnabled(WEP\btnTestToneCenter, bEnableCenter)
  EndWith

EndProcedure

Procedure WEP_setDisplayThisForMidiCmd(nMidiCommand)
  PROCNAMEC()
  Protected bDisplayThis, d, nDevPtr, sFixtureCode.s
  
  bDisplayThis = #True
  Select nMidiCommand
    Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER
      d = nMidiCommand - #SCS_MIDI_DEVICE_1_FADER
      If d > grProdForDevChgs\nMaxAudioLogicalDev
        bDisplayThis = #False
      ElseIf Len(Trim(grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev)) = 0
        bDisplayThis = #False
      EndIf
      
    Case #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER
      d = nMidiCommand - #SCS_MIDI_DIMMER_1_FADER
      sFixtureCode = WCN_getDimmerIndexFixtureCode(d)
      If Len(sFixtureCode) = 0
        bDisplayThis = #False
      EndIf
      
    Case #SCS_MIDI_DMX_MASTER
      If gbDMXAvailable
        If DMX_IsDMXOutDevPresent() = #False
          bDisplayThis = #False
        EndIf
      Else
        bDisplayThis = #False
      EndIf
  EndSelect
  
;   If sFixtureCode
;     debugMsg(sProcName, "nMidiCommand=" + nMidiCommand + " (" + decodeMidiCommand(nMidiCommand) + "), sFixtureCode=" + sFixtureCode + ", bDisplayThis=" + strB(bDisplayThis))
;   Else
;     debugMsg(sProcName, "nMidiCommand=" + nMidiCommand + " (" + decodeMidiCommand(nMidiCommand) + "), bDisplayThis=" + strB(bDisplayThis))
;   EndIf
  ProcedureReturn bDisplayThis
  
EndProcedure

Procedure WEP_clearDeviceFields(nDevGrp=-1)
  PROCNAMEC()
  Protected nDevNo
  
  debugMsg(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp))
  
  With WEP
    ; audio devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_AUDIO_OUTPUT) And (grLicInfo\nMaxAudDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtAudLogicalDev())
        SGT(\txtAudLogicalDev(nDevNo), "")
        ED_fcAudLogicalDev(nDevNo)
        SetGadgetColor(\lblAudDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; video audio devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_VIDEO_AUDIO) And (grLicInfo\nMaxVidAudDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtVidAudLogicalDev())
        SGT(\txtVidAudLogicalDev(nDevNo), "")
        ED_fcVidAudLogicalDev(nDevNo)
        SetGadgetColor(\lblVidAudDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; video capture devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_VIDEO_CAPTURE) And (grLicInfo\nMaxVidCapDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtVidCapLogicalDev())
        SGT(\txtVidCapLogicalDev(nDevNo), "")
        ED_fcVidCapLogicalDev(nDevNo)
        SetGadgetColor(\lblVidCapDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; fixture types
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_FIX_TYPE) And (grLicInfo\nMaxFixTypePerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtFixTypeName())
        SGT(\txtFixTypeName(nDevNo), "")
        ED_fcFixTypeName(nDevNo)
        SetGadgetColor(\lblFixTypeNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; lighting devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_LIGHTING) And (grLicInfo\nMaxLightingDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\cboLightingDevType())
        SGS(\cboLightingDevType(nDevNo), -1)
        ED_fcLightingDevType(nDevNo)
        SetGadgetColor(\lblLightingDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; control send devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_CTRL_SEND) And (grLicInfo\nMaxCtrlSendDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\cvsCtrlDevType())
        WEP_setCtrlDevTypeText(nDevNo) ; sets \cvsCtrlDevType(nDevNo)
        SGT(\txtCtrlLogicalDev(nDevNo), "")
        ED_fcCtrlDevType(nDevNo)
        SetGadgetColor(\lblCtrlDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; cue control devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_CUE_CTRL) And (grLicInfo\nMaxCueCtrlDev >= 0)
      For nDevNo = 0 To ArraySize(\cboCueDevType())
        SGS(\cboCueDevType(nDevNo), -1)
        SGT(\txtCuePhysDevInfo(nDevNo), "")
        ED_fcCueDevType(nDevNo)
        SetGadgetColor(\lblCueDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; live input devices
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_LIVE_INPUT) And (grLicInfo\nMaxLiveDevPerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtLiveLogicalDev())
        SGT(\txtLiveLogicalDev(nDevNo), "")
        ED_fcLiveLogicalDev(nDevNo)
        SetGadgetColor(\lblLiveDevNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
    ; live input groups
    If (nDevGrp = -1 Or nDevGrp = #SCS_DEVGRP_IN_GRP) And (grLicInfo\nMaxInGrpPerProd >= 0)
      For nDevNo = 0 To ArraySize(\txtInGrpName())
        SGT(\txtInGrpName(nDevNo), "")
        ED_fcInGrpName(nDevNo)
        SetGadgetColor(\lblInGrpNo(nDevNo), #PB_Gadget_BackColor, #SCS_Very_Light_Grey)
      Next nDevNo
    EndIf
  EndWith
  
EndProcedure

; EOF