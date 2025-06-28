; File: EditDevs.pbi

EnableExplicit

; These procedures are used exclusively for Production Properties editing under the 'Devices' tab.
; The global grProdForDevChgs is initially populated from relevant items in grProd, gaDevMap, gaDevMapDev and grMaps\aLiveGrp
; When 'Apply Device Changes' is clicked then the content of the global will be copied back to the original source item (eg to grProd\aAudioLogicalDevs()).
; If 'Undo Device Changes' is clicked then any non-applied changes are discarded and the global will be repopulated from grProd, etc.

Procedure ED_unloadProdDataFromDevChgs(*rProd.tyProd)
  PROCNAMEC()
  Protected d
  
  ED_copyProdDevArrays(@grProdForDevChgs, *rProd)
  
  With grProdForDevChgs
    *rProd\sProdId = \sProdId
    *rProd\nProdId = \nProdId
    *rProd\bProdIdFoundInCueFile = \bProdIdFoundInCueFile
    *rProd\sTestToneDBLevel = \sTestToneDBLevel
    *rProd\fTestToneBVLevel = \fTestToneBVLevel
    *rProd\fTestTonePan = \fTestTonePan
    *rProd\nTestSound = \nTestSound
    *rProd\sOutputDevForTestLiveInput = \sOutputDevForTestLiveInput
    *rProd\bLightingPre118 = \bLightingPre118
    *rProd\bExistingDevMapFileFound = \bExistingDevMapFileFound
    *rProd\sDevMapFile = \sDevMapFile
    *rProd\sSelectedDevMapName = \sSelectedDevMapName
    *rProd\nSelectedDevMapPtr = \nSelectedDevMapPtr
  EndWith
EndProcedure

Procedure ED_loadDevChgsFromProd()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  grProdForDevChgs = grProd
  grMapsForDevChgs = grMaps
  debugMsg(sProcName, "grProdForDevChgs\nMaxVidAudLogicalDev=" + grProdForDevChgs\nMaxVidAudLogicalDev)
  debugMsg(sProcName, "grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
  
  With grMapsForDevChgs
    For n = 0 To \nMaxMapIndex
      \aMap(n)\nOrigAudioDriver = \aMap(n)\nAudioDriver ; used to check for changes in WEP_btnApplyDevChgs()
    Next n
    For n = 0 To \nMaxDevIndex
      \aDev(n)\sOrigPhysicalDev = \aDev(n)\sPhysicalDev ; used to check for changes in WEP_btnApplyDevChgs()
    Next n
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_loadDevChgsFromChecker()
  PROCNAMEC()
  
  grProdForDevChgs = grProdForChecker
  grMapsForDevChgs = grMapsForChecker
  debugMsg(sProcName, "grProdForDevChgs\nMaxVidAudLogicalDev=" + grProdForDevChgs\nMaxVidAudLogicalDev)
  debugMsg(sProcName, "grMapsForDevChgs\sSelectedDevMapName=" + grMapsForDevChgs\sSelectedDevMapName)
  
EndProcedure

Procedure ED_applyDevChgs()
  PROCNAMEC()
  
  ED_unloadProdDataFromDevChgs(@grProd)
  grMaps = grMapsForDevChgs
;   With grProdForDevChgs
;     ; device maps (all device maps)
;     CopyArray(\aMap(), grMaps\aMap())
;     grMaps\nMaxMapIndex = \nMaxMapIndex
;     
;     ; devices (for all device maps)
;     CopyArray(\aDev(), grMaps\aDev())
;     grMaps\nMaxDevIndex = \nMaxDevIndex
;     
;     ; live input groups (for all device maps)
;     CopyArray(\aLiveGrp(), grMaps\aLiveGrp())
;     grMaps\nMaxLiveGrpIndex = \nMaxLiveGrpIndex
;   EndWith
EndProcedure

Procedure ED_loadCheckerFromDevChgs(nDevMapPtr)
  PROCNAMEC()
  
  ED_unloadProdDataFromDevChgs(@grProdForChecker)
  grMapsForChecker = grMapsForDevChgs
;   With grProdForDevChgs
;     ; device map (only a single device map is used by the checker, which is held in grDevMapForChecker)
;     grMapsForChecker\aMap(nDevMapPtr) = \aMap(nDevMapPtr)
;     
;     ; devices (for all device maps)
;     CopyArray(\aDev(), grMapsForChecker\aDev())
;     grMapsForChecker\nMaxDevIndex = \nMaxDevIndex
;     
;     ; live input groups (for all device maps)
;     CopyArray(\aLiveGrp(), grMapsForChecker\aLiveGrp())
;     grMapsForChecker\nMaxLiveGrpIndex = \nMaxLiveGrpIndex
;   EndWith
  
EndProcedure

Procedure ED_checkDevMapForDevChgs(nDevMapPtr)
  PROCNAMEC()
  Protected nResult
  
  debugMsg(sProcName, #SCS_START + ", nDevMapPtr=" + nDevMapPtr + " (" + getDevMapName(nDevMapPtr) + ")")
  
;   debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;   listAllDevMapsForDevChgs()
  
  gsCheckDevMapMsg = ""
  grDevMapCheck = grDevMapCheckDef
  grDevMapCheckForSetIgnoreDevInds = grDevMapCheck
  ; debugMsg(sProcName, "grDevMapCheck\nCheckItemCount=" + grDevMapCheck\nCheckItemCount)
  
  If nDevMapPtr >= 0
    ED_loadCheckerFromDevChgs(nDevMapPtr)
    ; debugMsg(sProcName, "calling checkDevMapCommon(" + getDevMapName(nDevMapPtr) + ", #True)")
    nResult = checkDevMapCommon(nDevMapPtr, #True)
    ED_loadDevChgsFromChecker()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + nResult)
  ProcedureReturn nResult
EndProcedure

Procedure ED_valOneProdAudioDevice(pDevNo)
  PROCNAMEC()
  Protected bValidationOK
  Protected sMsg.s
  Protected nDevMapDevPtr
  Protected sPhysicalDev.s, s1BasedOutputRange.s
  Protected nDevId
  Protected d
  
  ; debugMsg(sProcName, #SCS_START + ", pDevNo=" + pDevNo)
  
  bValidationOK = #True
  
  With grProdForDevChgs\aAudioLogicalDevs(pDevNo)
    nDevId = \nDevId
    sMsg = \sLogicalDev + ": " ; common start for messages
    If \sLogicalDev
      ; debugMsg(sProcName, "grProdForDevChgs\aAudioLogicalDevs(" + pDevNo + ")\sLogicalDev=" + \sLogicalDev)
      ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, " + pDevNo + ")")
      nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, pDevNo)
      ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
      If nDevMapDevPtr < 0
        sMsg + LangPars("Errors", "MustBeSelected", GGT(WEP\lblAudPhysical))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
        bValidationOK = #False
      ElseIf grMapsForDevChgs\aDev(nDevMapDevPtr)\bIgnoreDevThisRun
        \nPhysicalDevPtr = -1
      Else
        sPhysicalDev = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
        s1BasedOutputRange = grMapsForDevChgs\aDev(nDevMapDevPtr)\s1BasedOutputRange
        \nPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, \sLogicalDev)
        ; debugMsg(sProcName, "\nPhysicalDevPtr=" + \nPhysicalDevPtr)
        If \nPhysicalDevPtr < 0
          If Len(sPhysicalDev) = 0
            sMsg + LangPars("Errors", "MustBeSelected", GGT(WEP\lblAudPhysical))
          Else
            sMsg + LangPars("DevMap", "DevNotActive", decodeDevGrpL(#SCS_DEVGRP_AUDIO_OUTPUT), sPhysicalDev)
            If gnPhysicalAudDevs > 0
              sMsg + #LF$ + #LF$ + LangPars("DevMap", "DevsAvailable", decodeDevGrpL(#SCS_DEVGRP_AUDIO_OUTPUT))
              For d = 0 To (gnPhysicalAudDevs-1)
                If gaAudioDevSorted(d)\nAudioDriver = gnCurrAudioDriver
                  sMsg + #LF$ + gaAudioDevSorted(d)\sDesc
                EndIf
              Next d
            EndIf
          EndIf
          debugMsg(sProcName, sMsg)
          scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
          bValidationOK = #False
          
        ElseIf (Len(Trim(s1BasedOutputRange)) = 0) And (\bNoDevice = #False)
          If Len(s1BasedOutputRange) = 0
            sMsg + LangPars("Errors", "MustBeSelected", GGT(WEP\lblOutputRange))
          Else
            sMsg + LangPars("DevMap", "OutsNotAvailable", s1BasedOutputRange)
          EndIf
          debugMsg(sProcName, sMsg)
          scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
          bValidationOK = #False
          
        EndIf
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure ED_valProdDevices(bCheckOutstandingChanges=#True, bResetTabIfNecessary=#False)
  PROCNAMEC()
  Protected d, bValidationOK
  Protected sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  bValidationOK = #True
  
  For d = 0 To grProdForDevChgs\nMaxAudioLogicalDev
    If grProdForDevChgs\aAudioLogicalDevs(d)\sLogicalDev
      debugMsg(sProcName, "calling ED_valOneProdAudioDevice(" + d + ")")
      If ED_valOneProdAudioDevice(d) = #False
        bValidationOK = #False
        Break
      EndIf
    EndIf
  Next d
  
  debugMsg(sProcName, "bValidationOK=" + strB(bValidationOK) + ", bCheckOutstandingChanges=" + strB(bCheckOutstandingChanges) + ", gbProdDevChgs=" + strB(gbProdDevChgs))
  If bValidationOK
    If bCheckOutstandingChanges
      If (gbProdDevChgs) Or (gbProdDevOutputGainChgs) Or (gbProdDevInputGainChgs)
        If bResetTabIfNecessary
          ; validation failed so stay in Devices tab
          setGadgetItemByData(WEP\pnlProd, #SCS_PROD_TAB_DEVS)
        EndIf
        sMsg = Lang("WEP", "UnappliedDevChgs")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
        bValidationOK = #False
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure ED_copyProdDevArrays(*rSourceProd.tyProd, *rDestinationProd.tyProd)
  PROCNAMEC()
  
  With *rSourceProd
    CopyArray(\aAudioLogicalDevs(), *rDestinationProd\aAudioLogicalDevs())
    *rDestinationProd\nMaxAudioLogicalDev = \nMaxAudioLogicalDev
    *rDestinationProd\nMaxAudioLogicalDevDisplay = \nMaxAudioLogicalDevDisplay
    
    CopyArray(\aVidAudLogicalDevs(), *rDestinationProd\aVidAudLogicalDevs())
    *rDestinationProd\nMaxVidAudLogicalDev = \nMaxVidAudLogicalDev
    *rDestinationProd\nMaxVidAudLogicalDevDisplay = \nMaxVidAudLogicalDevDisplay
    
    CopyArray(\aVidCapLogicalDevs(), *rDestinationProd\aVidCapLogicalDevs())
    *rDestinationProd\nMaxVidCapLogicalDev = \nMaxVidCapLogicalDev
    *rDestinationProd\nMaxVidCapLogicalDevDisplay = \nMaxVidCapLogicalDevDisplay
    
    CopyArray(\aFixTypes(), *rDestinationProd\aFixTypes())
    *rDestinationProd\nMaxFixType = \nMaxFixType
    *rDestinationProd\nMaxFixTypeDisplay = \nMaxFixTypeDisplay
    
    CopyArray(\aLightingLogicalDevs(), *rDestinationProd\aLightingLogicalDevs())
    *rDestinationProd\nMaxLightingLogicalDev = \nMaxLightingLogicalDev
    *rDestinationProd\nMaxLightingLogicalDevDisplay = \nMaxLightingLogicalDevDisplay
    
    CopyArray(\aCtrlSendLogicalDevs(), *rDestinationProd\aCtrlSendLogicalDevs())
    *rDestinationProd\nMaxCtrlSendLogicalDev = \nMaxCtrlSendLogicalDev
    *rDestinationProd\nMaxCtrlSendLogicalDevDisplay = \nMaxCtrlSendLogicalDevDisplay
    
    CopyArray(\aCueCtrlLogicalDevs(), *rDestinationProd\aCueCtrlLogicalDevs())
    *rDestinationProd\nMaxCueCtrlLogicalDev = \nMaxCueCtrlLogicalDev
    *rDestinationProd\nMaxCueCtrlLogicalDevDisplay = \nMaxCueCtrlLogicalDevDisplay
    
    CopyArray(\aLiveInputLogicalDevs(), *rDestinationProd\aLiveInputLogicalDevs())
    *rDestinationProd\nMaxLiveInputLogicalDev = \nMaxLiveInputLogicalDev
    *rDestinationProd\nMaxLiveInputLogicalDevDisplay = \nMaxLiveInputLogicalDevDisplay
    
    CopyArray(\aInGrps(), *rDestinationProd\aInGrps())
    *rDestinationProd\nMaxInGrp = \nMaxInGrp
    *rDestinationProd\nMaxInGrpDisplay = \nMaxInGrpDisplay
    
  EndWith
  
EndProcedure

Procedure ED_setDevDisplayMaximums(*rProd.tyProd)
  PROCNAMEC()
  Protected nGrpNo
  
  ; debugMsg0(sProcName, #SCS_START + ": " + getProdGlobal(*rProd))
  If grLicInfo\nMaxAudDevPerProd = 0
    MessageRequester(sProcName, "setLicLimits() has not been called", #PB_MessageRequester_Warning)
  EndIf
  
  ; note that the array sizes must ALWAYS be at least one greater than the corresponding \nMax...LogicalDev value to allow fmEditProd to display a blank item for a new entry
  
  With *rProd
    If \nMaxAudioLogicalDev >= grLicInfo\nMaxAudDevPerProd
      \nMaxAudioLogicalDevDisplay = \nMaxAudioLogicalDev
    Else
      \nMaxAudioLogicalDevDisplay = \nMaxAudioLogicalDev + 1
    EndIf
    If \nMaxAudioLogicalDevDisplay > ArraySize(\aAudioLogicalDevs())
      REDIM_ARRAY2(\aAudioLogicalDevs, \nMaxAudioLogicalDevDisplay, grAudioLogicalDevsDef)
    EndIf
    
    If \nMaxVidAudLogicalDev >= grLicInfo\nMaxVidAudDevPerProd
      \nMaxVidAudLogicalDevDisplay = \nMaxVidAudLogicalDev
    Else
      \nMaxVidAudLogicalDevDisplay = \nMaxVidAudLogicalDev + 1
    EndIf
    If \nMaxVidAudLogicalDevDisplay > ArraySize(\aVidAudLogicalDevs())
      REDIM_ARRAY2(\aVidAudLogicalDevs, \nMaxVidAudLogicalDevDisplay, grVidAudLogicalDevsDef)
    EndIf
    
    If \nMaxVidCapLogicalDev >= grLicInfo\nMaxVidCapDevPerProd
      \nMaxVidCapLogicalDevDisplay = \nMaxVidCapLogicalDev
    Else
      \nMaxVidCapLogicalDevDisplay = \nMaxVidCapLogicalDev + 1
    EndIf
    If \nMaxVidCapLogicalDevDisplay > ArraySize(\aVidCapLogicalDevs())
      REDIM_ARRAY2(\aVidCapLogicalDevs, \nMaxVidCapLogicalDevDisplay, grVidCapLogicalDevsDef)
    EndIf
    
    If \nMaxFixType >= grLicInfo\nMaxFixTypePerProd
      \nMaxFixTypeDisplay = \nMaxFixType
    Else
      \nMaxFixTypeDisplay = \nMaxFixType + 1
    EndIf
    If \nMaxFixTypeDisplay > ArraySize(\aFixTypes())
      REDIM_ARRAY2(\aFixTypes, \nMaxFixTypeDisplay, grFixTypesDef)
    EndIf
    
    If \nMaxLightingLogicalDev >= grLicInfo\nMaxLightingDevPerProd
      \nMaxLightingLogicalDevDisplay = \nMaxLightingLogicalDev
    Else
      \nMaxLightingLogicalDevDisplay = \nMaxLightingLogicalDev + 1
    EndIf
    If \nMaxLightingLogicalDevDisplay > ArraySize(\aLightingLogicalDevs())
      REDIM_ARRAY2(\aLightingLogicalDevs, \nMaxLightingLogicalDevDisplay, grLightingLogicalDevsDef)
    EndIf
    
    If \nMaxCtrlSendLogicalDev >= grLicInfo\nMaxCtrlSendDevPerProd
      \nMaxCtrlSendLogicalDevDisplay = \nMaxCtrlSendLogicalDev
    Else
      \nMaxCtrlSendLogicalDevDisplay = \nMaxCtrlSendLogicalDev + 1
    EndIf
    If \nMaxCtrlSendLogicalDevDisplay > ArraySize(\aCtrlSendLogicalDevs())
      REDIM_ARRAY2(\aCtrlSendLogicalDevs, \nMaxCtrlSendLogicalDevDisplay, grCtrlSendLogicalDevsDef)
    EndIf
    
    If \nMaxCueCtrlLogicalDev >= grLicInfo\nMaxCueCtrlDev
      \nMaxCueCtrlLogicalDevDisplay = \nMaxCueCtrlLogicalDev
    Else
      \nMaxCueCtrlLogicalDevDisplay = \nMaxCueCtrlLogicalDev + 1
    EndIf
    If \nMaxCueCtrlLogicalDevDisplay > ArraySize(\aCueCtrlLogicalDevs())
      REDIM_ARRAY2(\aCueCtrlLogicalDevs, \nMaxCueCtrlLogicalDevDisplay, grCueCtrlLogicalDevsDef)
    EndIf
    
    If \nMaxLiveInputLogicalDev >= grLicInfo\nMaxLiveDevPerProd
      \nMaxLiveInputLogicalDevDisplay = \nMaxLiveInputLogicalDev
    Else
      \nMaxLiveInputLogicalDevDisplay = \nMaxLiveInputLogicalDev + 1
    EndIf
    If \nMaxLiveInputLogicalDevDisplay > ArraySize(\aLiveInputLogicalDevs())
      REDIM_ARRAY2(\aLiveInputLogicalDevs, \nMaxLiveInputLogicalDevDisplay, grLiveInputLogicalDevsDef)
    EndIf
    
    If \nMaxInGrp >= grLicInfo\nMaxInGrpPerProd
      \nMaxInGrpDisplay = \nMaxInGrp
    Else
      \nMaxInGrpDisplay = \nMaxInGrp + 1
    EndIf
    If \nMaxInGrpDisplay > ArraySize(\aInGrps())
      REDIM_ARRAY2(\aInGrps, \nMaxInGrpDisplay, grInGrpsDef)
    EndIf
    
    For nGrpNo = 0 To \nMaxInGrp
      \aInGrps(nGrpNo)\nMaxInGrpItemDisplay = \aInGrps(nGrpNo)\nMaxInGrpItem + 1
      If \aInGrps(nGrpNo)\nMaxInGrpItemDisplay > ArraySize(\aInGrps(nGrpNo)\aInGrpItem())
        REDIM_ARRAY2(\aInGrps(nGrpNo)\aInGrpItem, \aInGrps(nGrpNo)\nMaxInGrpItemDisplay, grInGrpsDef\aInGrpItem(0))
      EndIf
    Next nGrpNo
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcAudLogicalDev(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected bEnabled
  
  ; debugMsg(sProcName, #SCS_START +", Index=" + Index)
  nDevNo = Index
  
  With WEP
    If nDevNo <= grProdForDevChgs\nMaxAudioLogicalDevDisplay
      If Trim(grProdForDevChgs\aAudioLogicalDevs(nDevNo)\sLogicalDev)
        bEnabled = #True
      EndIf
    EndIf
    If bEnabled = #False
      SGS(\cboNumChans(nDevNo), -1)
      SGS(\cboAudioPhysicalDev(nDevNo), -1)
      SGS(\cboOutputRange(nDevNo), -1)
      If gbDelayTimeAvailable
        SGT(\txtOutputDelayTime(nDevNo), "")
      EndIf
      SLD_setLevel(\sldAudOutputGain(nDevNo), #SCS_MINVOLUME_SINGLE)
      SGT(\txtAudOutputGainDB(nDevNo), "")
      setOwnState(\chkAudActive(nDevNo), #False)
    EndIf
    
    setEnabled(\cboAudioPhysicalDev(nDevNo), bEnabled)
    setEnabled(\cboOutputRange(nDevNo), bEnabled)
    If gbDelayTimeAvailable
      setEnabled(\txtOutputDelayTime(nDevNo), bEnabled)
    EndIf
    
    ED_fcAutoInclude()
    
    If bEnabled
      ; call ED_fcAudPhysicalDev() to enable/disable delay and gain based on presence of a physical device setting
      ED_fcAudPhysicalDev(nDevNo)
    Else
      If gbDelayTimeAvailable
        setEnabled(\txtOutputDelayTime(nDevNo), #False)
      EndIf
      SLD_setEnabled(\sldAudOutputGain(nDevNo), #False)
      setEnabled(\txtAudOutputGainDB(nDevNo), #False)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcVidAudLogicalDev(Index)
  PROCNAMEC()
  Protected nDevNo, bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  With WEP
    ; debugMsg(sProcName, "nDevNo=" + nDevNo + ", grProdForDevChgs\nMaxVidAudLogicalDev=" + grProdForDevChgs\nMaxVidAudLogicalDev)
    If nDevNo <= grProdForDevChgs\nMaxVidAudLogicalDevDisplay
      If Trim(grProdForDevChgs\aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev)
        bEnabled = #True
      EndIf
    EndIf
    If bEnabled = #False
      SGS(\cboVidAudPhysicalDev(nDevNo), -1)
      SLD_setLevel(\sldVidAudOutputGain(nDevNo), #SCS_MINVOLUME_SINGLE)
      SGT(\txtVidAudOutputGainDB(nDevNo), "")
    EndIf
    
    setEnabled(\cboVidAudPhysicalDev(Index), bEnabled)
    ED_fcVidAudAutoInclude()
    
    If bEnabled
      ; call ED_fcAudPhysicalDev() to enable/disable delay and gain based on presence of a physical device setting
      ED_fcVidAudPhysicalDev(Index)
    Else
      SLD_setEnabled(\sldVidAudOutputGain(Index), #False)
      setEnabled(\txtVidAudOutputGainDB(Index), #False)
    EndIf
  EndWith
  
EndProcedure

Procedure ED_fcVidCapLogicalDev(Index)
  PROCNAMEC()
  Protected nDevNo, bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  With WEP
    If nDevNo <= grProdForDevChgs\nMaxVidCapLogicalDevDisplay
      If Trim(grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev)
        bEnabled = #True
      EndIf
    EndIf
    If bEnabled = #False
      SGS(\cboVidCapPhysicalDev(nDevNo), -1)
    EndIf
    setEnabled(\cboVidCapPhysicalDev(Index), bEnabled)
    ED_fcVidCapAutoInclude()
    If bEnabled
      debugMsg(sProcName, "calling ED_fcVidCapPhysicalDev(" + Index + ")")
      ED_fcVidCapPhysicalDev(Index)
    Else
      ; no action
    EndIf
  EndWith
  
EndProcedure

Procedure ED_fcFixTypeName(nFTIndex)
  Protected bExists
  
  With WEP
    If nFTIndex <= grProdForDevChgs\nMaxFixTypeDisplay
      If Trim(grProdForDevChgs\aFixTypes(nFTIndex)\sFixTypeName)
        bExists = #True
      EndIf
    EndIf
    If bExists = #False
      SGT(\txtFixTypeInfo(nFTIndex), "")
    EndIf
  EndWith
  
EndProcedure

Procedure ED_fcLightingDevType(Index)
  Protected nDevNo, bEnabled
  
  nDevNo = Index
  With WEP
    If nDevNo <= grProdForDevChgs\nMaxLightingLogicalDevDisplay
      If grProdForDevChgs\aLightingLogicalDevs(nDevNo)\nDevType <> #SCS_DEVTYPE_NONE
        bEnabled = #True
      EndIf
    EndIf
    setEnabled(\txtLightingLogicalDev(nDevNo), bEnabled)
    If bEnabled = #False
      SGT(\txtLightingLogicalDev(nDevNo), "")
      SGT(\txtLightingPhysDevInfo(nDevNo), "")
      setOwnState(\chkLightingActive(nDevNo), #False)
    EndIf
  EndWith
  
EndProcedure

Procedure ED_fcFixtureCode(Index)
  PROCNAMEC()
  Protected nDevNo, bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = grWEP\nCurrentLightingDevNo
  If ArraySize(grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture()) >= Index
    If grProdForDevChgs\aLightingLogicalDevs(nDevNo)\aFixture(Index)\sFixtureCode
      bEnabled = #True
    EndIf
  EndIf
  With WEPFixture(Index)
    setEnabled(\txtDMXStartChannel, bEnabled)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcCtrlDevType(Index)
  PROCNAMEC()
  Protected nDevNo, nDevType, bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WEP
    nDevNo = Index
    nDevType = #SCS_DEVTYPE_NONE
    If nDevNo <= grProdForDevChgs\nMaxCtrlSendLogicalDev
      nDevType = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nDevType
      If nDevType <> #SCS_DEVTYPE_NONE
        bEnabled = #True
      EndIf
    EndIf
    setEnabled(WEP\txtCtrlLogicalDev(Index), bEnabled)
    If bEnabled = #False
      SGT(\txtCtrlPhysDevInfo(nDevNo), "")
      setOwnState(\chkCtrlActive(nDevNo), #False)
    EndIf
    If nDevType = #SCS_DEVTYPE_CS_NETWORK_OUT
      ED_fcNetworkDummy()
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcCueDevType(Index)
  PROCNAMEC()
  Protected nDevNo, nDevType, bEnabled
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WEP
    nDevNo = Index
    If nDevNo <= grProdForDevChgs\nMaxCueCtrlLogicalDev
      nDevType = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nDevType
      If nDevType <> #SCS_DEVTYPE_NONE
        bEnabled = #True
      EndIf
    EndIf
    If bEnabled = #False
      SGT(\txtCuePhysDevInfo(nDevNo), "")
      setOwnState(\chkCueActive(nDevNo), #False)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcLiveLogicalDev(Index)
  PROCNAMEC()
  Protected nDevNo, bEnabled
  
  With WEP
    nDevNo = Index
    If nDevNo <= grProdForDevChgs\nMaxLiveInputLogicalDev
      If Trim(grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)\sLogicalDev)
        bEnabled = #True
      EndIf
    EndIf
    If bEnabled = #False
      SGS(\cboNumInputChans(nDevNo), -1)
      SGS(\cboLivePhysicalDev(nDevNo), -1)
      SGS(\cboInputRange(nDevNo), -1)
      SLD_setLevel(\sldInputGain(nDevNo), #SCS_MINVOLUME_SINGLE)
      SGT(\txtInputGainDB(nDevNo), "")
    EndIf
    
    setEnabled(WEP\cboLivePhysicalDev(nDevNo), bEnabled)
    setEnabled(WEP\cboInputRange(nDevNo), bEnabled)
    
    If bEnabled
      ; call ED_fcLivePhysicalDev() to enable/disable delay and gain based on presence of a physical device setting
      ED_fcLivePhysicalDev(nDevNo)
    Else
      SLD_setEnabled(WEP\sldInputGain(nDevNo), #False)
      setEnabled(WEP\txtInputGainDB(nDevNo), #False)
      setOwnState(\chkLiveActive(nDevNo), #False)
    EndIf
  EndWith
  
EndProcedure

Procedure ED_fcInGrpName(Index)
  PROCNAMEC()
  Protected nInGrpNo
  
  nInGrpNo = Index
  
  ; nothing to do as no other group-level fields (placeholder for possible future changes)
  
EndProcedure

Procedure ED_fcAudPhysicalDev(Index)
  PROCNAMEC()
  Protected bDelayAndGainEnabled
  Protected nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, " + Index + ")")
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, Index)
  ; debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nPhysicalDevPtr=" + \nPhysicalDevPtr)
      If (\nPhysicalDevPtr >= 0) Or (1=1)
        bDelayAndGainEnabled = #True
      EndIf
      If gbDelayTimeAvailable
        setEnabled(WEP\txtOutputDelayTime(Index), bDelayAndGainEnabled)
      EndIf
      SLD_setEnabled(WEP\sldAudOutputGain(Index), bDelayAndGainEnabled)
      setEnabled(WEP\txtAudOutputGainDB(Index), bDelayAndGainEnabled)
      ; debugMsg(sProcName, "setEnabled(WEP\txtAudOutputGainDB[" + Index + "], " + strB(bDelayAndGainEnabled) + ")")
    EndWith
  EndIf
  setCboToolTipAtSelectedText(WEP\cboAudioPhysicalDev(Index))
  
EndProcedure

Procedure ED_fcVidAudPhysicalDev(Index)
  PROCNAMEC()
  Protected nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, " + Index + ")")
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, Index)
  If nDevMapDevPtr >= 0
    SLD_setEnabled(WEP\sldVidAudOutputGain(Index), #True)
    setEnabled(WEP\txtVidAudOutputGainDB(Index), #True)
  EndIf
  setCboToolTipAtSelectedText(WEP\cboVidAudPhysicalDev(Index))
  
EndProcedure

Procedure ED_fcVidCapPhysicalDev(Index)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  setCboToolTipAtSelectedText(WEP\cboVidCapPhysicalDev(Index))
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcLivePhysicalDev(Index)
  PROCNAMEC()
  Protected nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, " + Index + ")")
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, Index)
  If nDevMapDevPtr >= 0
    SLD_setEnabled(WEP\sldInputGain(Index), #True)
    setEnabled(WEP\txtInputGainDB(Index), #True)
  EndIf
  setCboToolTipAtSelectedText(WEP\cboLivePhysicalDev(Index))
  
EndProcedure

Procedure ED_fcDMXPhysDev(Index, nDevMapDevPtr)
  PROCNAMEC()
  Protected nPhysicalDevPtr
  Protected nDMXPort
  Protected bPortVisible, bRefreshRateVisible, bArtnetIpAddressVisible
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nDevMapDevPtr=" + nDevMapDevPtr)
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      debugMsg(sProcName, "nPhysicalDevPtr=" + nPhysicalDevPtr)
      If nPhysicalDevPtr >= 0
        debugMsg(sProcName, "gaDMXDevice(" + nPhysicalDevPtr + ")\nDMXPorts=" + gaDMXDevice(nPhysicalDevPtr)\nDMXPorts)
        If gaDMXDevice(nPhysicalDevPtr)\nDMXPorts <> CountGadgetItems(WEP\cboDMXPort[Index])
          ClearGadgetItems(WEP\cboDMXPort[Index])
          For nDMXPort = 1 To gaDMXDevice(nPhysicalDevPtr)\nDMXPorts
            If nDMXPort <= grLicInfo\nMaxDMXPort
              addGadgetItemWithData(WEP\cboDMXPort[Index], "DMX" + nDMXPort, nDMXPort)
            EndIf
          Next nDMXPort
          setComboBoxWidth(WEP\cboDMXPort[Index])
        EndIf
        setComboBoxByData(WEP\cboDMXPort[Index], grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXPort)
        If gaDMXDevice(nPhysicalDevPtr)\nDMXPorts > 1
          bPortVisible = #True
        EndIf
        If gaDMXDevice(nPhysicalDevPtr)\nDMXDevType = #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB Or gaDMXDevice(nPhysicalDevPtr)\nDMXDevType = #SCS_DMX_DEV_FTDI_USB_RS485
          ; Enttec OPEN DMX USB or equivalent needs DMX to be refreshed by SCS, whereas with DMX USB PRO and higher the interface intself handles DMX refresh
          setComboBoxByData(WEP\cboDMXRefreshRate, \nDMXRefreshRate)
          bRefreshRateVisible = #True
        ElseIf gaDMXDevice(nPhysicalDevPtr)\nDMXDevType = #SCS_DMX_DEV_ARTNET Or gaDMXDevice(nPhysicalDevPtr)\nDMXDevType = #SCS_DMX_DEV_SACN ; Handle ip address
          setComboBoxByString(WEP\cboDMXIpAddress, \sDMXIpAddress, 0)
          bRefreshRateVisible = #True
          bArtnetIpAddressVisible = #True
        EndIf
      EndIf
      ; Added 11Aug2022 11.10.0
      If nPhysicalDevPtr >= 0 Or \bDummy
        \nDevState = #SCS_DEVSTATE_ACTIVE
      Else
        \nDevState = #SCS_DEVSTATE_INACTIVE
      EndIf
      ; End added 11Aug2022 11.10.0
    EndWith
  EndIf
  
  WEP_resizeDMXOutDevInfo(bPortVisible, bRefreshRateVisible, bArtnetIpAddressVisible)
  setVisible(WEP\lblDMXPort[Index], bPortVisible)
  setVisible(WEP\cboDMXPort[Index], bPortVisible)
  setVisible(WEP\lblDMXRefreshRate, bRefreshRateVisible)
  setVisible(WEP\cboDMXRefreshRate, bRefreshRateVisible)
  setVisible(WEP\lblDMXIpAddress, bArtnetIpAddressVisible)
  setVisible(WEP\cboDMXIpAddress, bArtnetIpAddressVisible)
  setVisible(WEP\btnDMXIPRefresh, bArtnetIpAddressVisible)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, bDisplay)
  PROCNAMEC()
  
  With WEP
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        ; NOTE: list of gadgets obtained from createWEPAudDevs()
        If nLineIndex <= ArraySize(\lblAudDevNo())
          If IsGadget(\lblAudDevNo(nLineIndex))
            If getVisible(\lblAudDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblAudDevNo(nLineIndex), bDisplay)
              setVisible(\txtAudLogicalDev(nLineIndex), bDisplay)
              setVisible(\cboNumChans(nLineIndex), bDisplay)
              ; setVisible(\cntAudPhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\cboAudioPhysicalDev(nLineIndex), bDisplay)
              setVisible(\cboOutputRange(nLineIndex), bDisplay)
              SLD_setVisible(\sldAudOutputGain(nLineIndex), bDisplay)
              setVisible(\txtAudOutputGainDB(nLineIndex), bDisplay)
              setVisible(\chkAudActive(nLineIndex), bDisplay)
              setVisible(\txtOutputDelayTime(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_VIDEO_AUDIO
        ; NOTE: list of gadgets obtained from createWEPVidAudDevs()
        If nLineIndex <= ArraySize(\lblVidAudDevNo())
          If IsGadget(\lblVidAudDevNo(nLineIndex))
            If getVisible(\lblVidAudDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblVidAudDevNo(nLineIndex), bDisplay)
              setVisible(\txtVidAudLogicalDev(nLineIndex), bDisplay)
              ; setVisible(\cntVidAudPhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\cboVidAudPhysicalDev(nLineIndex), bDisplay)
              SLD_setVisible(\sldVidAudOutputGain(nLineIndex), bDisplay)
              setVisible(\txtVidAudOutputGainDB(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        ; NOTE: list of gadgets obtained from createWEPVidCapDevs()
        If nLineIndex <= ArraySize(\lblVidCapDevNo())
          If IsGadget(\lblVidCapDevNo(nLineIndex))
            If getVisible(\lblVidCapDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblVidCapDevNo(nLineIndex), bDisplay)
              setVisible(\txtVidCapLogicalDev(nLineIndex), bDisplay)
              ; setVisible(\cntVidCapPhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\cboVidCapPhysicalDev(nLineIndex), bDisplay)
              setVisible(\txtVidCapDummy(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_FIX_TYPE
        ; NOTE: list of gadgets obtained from createWEPFixTypes()
        If nLineIndex <= ArraySize(\lblFixTypeNo())
          If IsGadget(\lblFixTypeNo(nLineIndex))
            If getVisible(\lblFixTypeNo(nLineIndex)) <> bDisplay
              setVisible(\lblFixTypeNo(nLineIndex), bDisplay)
              setVisible(\txtFixTypeName(nLineIndex), bDisplay)
              setVisible(\txtFixTypeInfo(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_LIGHTING
        ; NOTE: list of gadgets obtained from createWEPLightingDevs()
        If nLineIndex <= ArraySize(\lblLightingDevNo())
          If IsGadget(\lblLightingDevNo(nLineIndex))
            If getVisible(\lblLightingDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblLightingDevNo(nLineIndex), bDisplay)
              setVisible(\cboLightingDevType(nLineIndex), bDisplay)
              setVisible(\txtLightingLogicalDev(nLineIndex), bDisplay)
              ; setVisible(\cntLightingPhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\txtLightingPhysDevInfo(nLineIndex), bDisplay)
              setVisible(\chkLightingActive(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_CTRL_SEND
        ; NOTE: list of gadgets obtained from createWEPCtrlSendDevs()
        If nLineIndex <= ArraySize(\lblCtrlDevNo())
          If IsGadget(\lblCtrlDevNo(nLineIndex))
            If getVisible(\lblCtrlDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblCtrlDevNo(nLineIndex), bDisplay)
              setVisible(\cvsCtrlDevType(nLineIndex), bDisplay)
              ; setVisible(\cvsCtrlDevTypeText(nLineIndex), bDisplay) ; not a gadget but 'text content of cvsCtrlDevType' (see Windows.api)
              setVisible(\txtCtrlLogicalDev(nLineIndex), bDisplay)
              ; setVisible(\cntCtrlPhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\txtCtrlPhysDevInfo(nLineIndex), bDisplay)
              setVisible(\chkCtrlActive(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_CUE_CTRL
        ; NOTE: list of gadgets obtained from createWEPCueCtrlDevs()
        If nLineIndex <= ArraySize(\lblCueDevNo())
          If IsGadget(\lblCueDevNo(nLineIndex))
            If getVisible(\lblCueDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblCueDevNo(nLineIndex), bDisplay)
              ; debugMsg0(sProcName, "setVisible(\lblCueDevNo(" + nLineIndex + "), " + strB(bDisplay) + ")")
              setVisible(\cboCueDevType(nLineIndex), bDisplay)
              ; setVisible(\cntCuePhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\txtCuePhysDevInfo(nLineIndex), bDisplay)
              setVisible(\chkCueActive(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_LIVE_INPUT
        ; NOTE: list of gadgets obtained from createWEPLiveInputDevs()
        If nLineIndex <= ArraySize(\lblLiveDevNo())
          If IsGadget(\lblLiveDevNo(nLineIndex))
            If getVisible(\lblLiveDevNo(nLineIndex)) <> bDisplay
              setVisible(\lblLiveDevNo(nLineIndex), bDisplay)
              setVisible(\txtLiveLogicalDev(nLineIndex), bDisplay)
              setVisible(\cboNumInputChans(nLineIndex), bDisplay)
              ; setVisible(\cntLivePhysDev(nLineIndex), bDisplay) ; this container is always displayed as it provides the required backcolor
              setVisible(\cboLivePhysicalDev(nLineIndex), bDisplay)
              setVisible(\cboInputRange(nLineIndex), bDisplay)
              SLD_setVisible(\sldInputGain(nLineIndex), bDisplay)
              setVisible(\txtInputGainDB(nLineIndex), bDisplay)
              setVisible(\chkLiveActive(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_IN_GRP
        ; NOTE: list of gadgets obtained from createWEPInputGroups()
        If nLineIndex <= ArraySize(\lblInGrpNo())
          If IsGadget(\lblInGrpNo(nLineIndex))
            If getVisible(\lblInGrpNo(nLineIndex)) <> bDisplay
              setVisible(\lblInGrpNo(nLineIndex), bDisplay)
              setVisible(\txtInGrpName(nLineIndex), bDisplay)
              setVisible(\txtInGrpInfo(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
      Case #SCS_DEVGRP_IN_GRP_LIVE_INPUT
        ; NB 'input group live inputs' are the live inputs assigned to this input group
        ; NOTE: list of gadgets obtained from createWEPInputGroupLiveInputs
        If nLineIndex <= ArraySize(\cboInGrpLiveInput())
          If IsGadget(\cboInGrpLiveInput(nLineIndex))
            If getVisible(\cboInGrpLiveInput(nLineIndex)) <> bDisplay
              setVisible(\cboInGrpLiveInput(nLineIndex), bDisplay)
            EndIf
          EndIf
        EndIf
    EndSelect
  EndWith
  
EndProcedure

Procedure ED_setDevGrpScaInnerHeight(nDevGrp, nIndex=-1)
  PROCNAMEC()
  ; Also calls setScaInnerWidth(), which is for ANY scrollable area gadget, not just device groups
  Protected nLineIndex, nMaxLogicalDevDisplay, nReqdInnerHeight
  
  ; debugMsg0(sProcName, #SCS_START + ", nDevGrp=" + decodeDevGrp(nDevGrp) + ", nIndex=" + nIndex)
  
  With WEP
    Select nDevGrp
      Case #SCS_DEVGRP_AUDIO_OUTPUT
        If IsGadget(\scaAudioDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxAudioLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaAudioDevs, #PB_ScrollArea_ScrollStep)) + 6
          ; +6 at the end to give an extra 'border' below the last item, by displaying a part of the next device line which is hidden in detail by
          ; the second call above to ED_displayOrHideDeviceLine().
          ; This gives a better display than just cutting off the display immediately under the last required device line.
          If GetGadgetAttribute(\scaAudioDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaAudioDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnAudVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnAudVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaAudioDevs)
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_AUDIO
        If IsGadget(\scaVidAudDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxVidAudLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaVidAudDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaVidAudDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaVidAudDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnVidAudVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnVidAudVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaVidAudDevs)
        EndIf
        
      Case #SCS_DEVGRP_VIDEO_CAPTURE
        If IsGadget(\scaVidCapDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxVidCapLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaVidCapDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaVidCapDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaVidCapDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnVidCapVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnVidCapVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaVidCapDevs)
        EndIf
        
      Case #SCS_DEVGRP_CTRL_SEND
        If IsGadget(\scaCtrlDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxCtrlSendLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaCtrlDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaCtrlDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaCtrlDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnCtrlVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnCtrlVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaCtrlDevs)
        EndIf
        
      Case #SCS_DEVGRP_CUE_CTRL
        If IsGadget(\scaCueDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxCueCtrlLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaCueDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaCueDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaCueDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnCueVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnCueVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaCueDevs)
        EndIf
        
      Case #SCS_DEVGRP_FIX_TYPE
        If IsGadget(\scaFixTypes)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxFixTypeDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaFixTypes, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaFixTypes, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaFixTypes, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ; nb no 'vertical separators' in fix types
          EndIf
          setScaInnerWidth(\scaFixTypes)
        EndIf
        
      Case #SCS_DEVGRP_LIGHTING
        If IsGadget(\scaLightingDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxLightingLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaLightingDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaLightingDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaLightingDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnLightingVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnLightingVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaLightingDevs)
        EndIf
        
      Case #SCS_DEVGRP_LIVE_INPUT
        If IsGadget(\scaLiveDevs)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxLiveInputLogicalDevDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaLiveDevs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaLiveDevs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaLiveDevs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ResizeGadget(\lnLiveVertSepInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
            ResizeGadget(\lnLiveVertRightInSCA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nReqdInnerHeight)
          EndIf
          setScaInnerWidth(\scaLiveDevs)
        EndIf
        
      Case #SCS_DEVGRP_IN_GRP
        If IsGadget(\scaInGrps)
          nMaxLogicalDevDisplay = grProdForDevChgs\nMaxInGrpDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaInGrps, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaInGrps, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaInGrps, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ; nb no 'vertical separators' in input groups
          EndIf
          setScaInnerWidth(\scaInGrps)
        EndIf
        
      Case #SCS_DEVGRP_IN_GRP_LIVE_INPUT
        ; NB 'input group live inputs' are the live inputs assigned to this input group
        If IsGadget(\scaInGrpLiveInputs)
          nMaxLogicalDevDisplay = grProdForDevChgs\aInGrps(nIndex)\nMaxInGrpItemDisplay
          If nMaxLogicalDevDisplay >= 0
            For nLineIndex = 0 To nMaxLogicalDevDisplay
              ED_displayOrHideDeviceLine(nDevGrp, nLineIndex, #True)
            Next nLineIndex
            ED_displayOrHideDeviceLine(nDevGrp, nMaxLogicalDevDisplay+1, #False)
          EndIf
          nReqdInnerHeight = ((nMaxLogicalDevDisplay + 1) * GetGadgetAttribute(\scaInGrpLiveInputs, #PB_ScrollArea_ScrollStep)) + 6 ; regarding +6 see comments above under #SCS_DEVGRP_AUDIO_OUTPUT
          If GetGadgetAttribute(\scaInGrpLiveInputs, #PB_ScrollArea_InnerHeight) <> nReqdInnerHeight
            SetGadgetAttribute(\scaInGrpLiveInputs, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
            ; nb no 'vertical separators' in input group live inputs
          EndIf
          setScaInnerWidth(\scaInGrpLiveInputs)
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure ED_fcAutoInclude()
  PROCNAMEC()
  Protected bLevelEnabled, bPanEnabled, bCenterEnabled, bAutoIncludeEnabled
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
;     debugMsg(sProcName, "grWEP\nCurrentAudDevNo=" + grWEP\nCurrentAudDevNo + ", grWEP\sCurrentAudDevName=" + grWEP\sCurrentAudDevName)
;     debugMsg(sProcName, "grProdForDevChgs\nMaxAudioLogicalDev=" + grProdForDevChgs\nMaxAudioLogicalDev + ", grProdForDevChgs\nMaxAudioLogicalDevDisplay=" + grProdForDevChgs\nMaxAudioLogicalDevDisplay)
;     debugMsg(sProcName, "ArraySize(grProdForDevChgs\aAudioLogicalDevs())=" + ArraySize(grProdForDevChgs\aAudioLogicalDevs()))
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      If \sLogicalDev
        bLevelEnabled = #True
        bAutoIncludeEnabled = #True
        If \nNrOfOutputChans = 2
          bPanEnabled = #True
          If \fDfltPan <> #SCS_PANCENTRE_SINGLE
            bCenterEnabled = #True
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  setOwnEnabled(WEP\chkAutoInclude, bAutoIncludeEnabled)
  setEnabled(WEP\cboDfltDevTrim, bLevelEnabled)
  SLD_setEnabled(WEP\sldDfltDevLevel, bLevelEnabled)
  setEnabled(WEP\txtDfltDevDBLevel, bLevelEnabled)
  SLD_setEnabled(WEP\sldDfltDevPan, bPanEnabled)
  setEnabled(WEP\btnDfltDevCenter, bCenterEnabled)
  setEnabled(WEP\txtDfltDevPan, bPanEnabled)

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcVidAudAutoInclude()
  PROCNAMEC()
  Protected bAutoIncludeAndLevelEnabled, bPanEnabled, bCenterEnabled
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    ; debugMsg(sProcName, "grWEP\nCurrentAudDevNo=" + grWEP\nCurrentAudDevNo + ", grWEP\sCurrentAudDevName=" + grWEP\sCurrentAudDevName)
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      If \sVidAudLogicalDev
        bAutoIncludeAndLevelEnabled = #True
        ; If \nNrOfOutputChans = 2
          bPanEnabled = #True
          If \fDfltPan <> #SCS_PANCENTRE_SINGLE
            bCenterEnabled = #True
          EndIf
        ; EndIf
      EndIf
    EndWith
  EndIf
  
  setEnabled(WEP\chkVidAudAutoInclude, bAutoIncludeAndLevelEnabled)
  setEnabled(WEP\cboDfltVidAudTrim, bAutoIncludeAndLevelEnabled)
  SLD_setEnabled(WEP\sldDfltVidAudLevel, bAutoIncludeAndLevelEnabled)
  setEnabled(WEP\txtDfltVidAudDBLevel, bAutoIncludeAndLevelEnabled)
  SLD_setEnabled(WEP\sldDfltVidAudPan, bPanEnabled)
  setEnabled(WEP\btnDfltVidAudCenter, bCenterEnabled)
  setEnabled(WEP\txtDfltVidAudPan, bPanEnabled)
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcVidCapAutoInclude()
  PROCNAMEC()
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentVidCapDevNo
  If nDevNo >= 0
    debugMsg(sProcName, "grWEP\nCurrentVidCapDevNo=" + grWEP\nCurrentVidCapDevNo + ", grWEP\sCurrentVidCapDevName=" + grWEP\sCurrentVidCapDevName)
    If grProdForDevChgs\aVidCapLogicalDevs(nDevNo)\sLogicalDev
      ; no action
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcSldTestToneLevel()
  PROCNAMEC()
  Protected u
  
  With grProd ; nb grProd, NOT grProdForDevChgs as \sTestToneDBLevel etc is not related to device maps
    u = preChangeProdS(\sTestToneDBLevel, GGT(WEP\lblTestToneLevel))
    \fTestToneBVLevel = SLD_getLevel(WEP\sldTestToneLevel)
    \sTestToneDBLevel = convertBVLevelToDBString(\fTestToneBVLevel)
    grProdForDevChgs\fTestToneBVLevel = \fTestToneBVLevel ; copy to grProdForDevChgs as this may be active at the time
    grProdForDevChgs\sTestToneDBLevel = \sTestToneDBLevel
    postChangeProdS(u, \sTestToneDBLevel)
    setTestToneLevel()
  EndWith
EndProcedure

Procedure ED_fcSldTestTonePan()
  ; Added 4May2022am 11.9.1
  PROCNAMEC()
  Protected u
  
  With grProd ; nb grProd, NOT grProdForDevChgs as \fTestTonePan etc is not related to device maps
    u = preChangeProdF(\fTestTonePan, GGT(WEP\lblTestTonePan))
    \fTestTonePan = panSliderValToSingle(SLD_getValue(WEP\sldTestTonePan))
    ; debugMsg0(sProcName, "grProd\fTestTonePan=" + formatPan(\fTestTonePan))
    grProdForDevChgs\fTestTonePan = \fTestTonePan ; copy to grProdForDevChgs as this may be active at the time
    postChangeProdF(u, \fTestTonePan)
    WEP_enableTestTonePanControls()
    setTestTonePan()
  EndWith
EndProcedure

Procedure ED_fcCtrlMethod(bDisplayingDetails)
  PROCNAMEC()
  Protected n
  Protected nHeight
  Protected bEnableTestMidi, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", bDisplayingDetails=" + strB(bDisplayingDetails) + ", grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo)
  
  If grWEP\nCurrentCueDevNo < 0
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ClearGadgetItems(WEP\edgMidiAssigns)
  
  bEnableTestMidi = #True
  
  With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
    Select \nCtrlMethod
      Case #SCS_CTRLMETHOD_NONE ; #SCS_CTRLMETHOD_NONE
        setVisible(WEP\cntNonMSC, #False)
        setVisible(WEP\cntMSC, #False)
        bEnableTestMidi = #False
        
      Case #SCS_CTRLMETHOD_MTC  ; #SCS_CTRLMETHOD_MTC
        setVisible(WEP\cntNonMSC, #False)
        setVisible(WEP\cntMSC, #False)
        SGS(WEP\cboMidiDevId, \nMscMmcMidiDevId + 1)
        setEnabled(WEP\cboMidiDevId, #True)
        
      Case #SCS_CTRLMETHOD_MSC  ; #SCS_CTRLMETHOD_MSC
        setVisible(WEP\cntNonMSC, #False)
        setVisible(WEP\cntMSC, #True)
        setVisible(WEP\lblMSCCommandFormat, #True)
        setVisible(WEP\cboMSCCommandFormat, #True)
        setVisible(WEP\lblGoMacro, #True)
        setVisible(WEP\cboGoMacro, #True)
        setVisible(WEP\chkMMCApplyFadeForStop, #False)
        
        ; nb set all required variables BEFORE setting cbo ListIndexes, as setting these ListIndexes may fire displayMidiAssigns
        ; which may fail if the required variables are not set
        ; nb format 00H ignored, ie treated as 'not defined'
        If \nMscCommandFormat <= 0
          \nMscCommandFormat = #MSC_DEFAULT_COMMAND_FORMAT
        EndIf
        
        SGS(WEP\cboMidiDevId, \nMscMmcMidiDevId + 1)
        setEnabled(WEP\cboMidiDevId, #True)
        
        SGS(WEP\cboMSCCommandFormat, \nMscCommandFormat + 1)
        setEnabled(WEP\cboMSCCommandFormat, #True)
        
      Case #SCS_CTRLMETHOD_MMC  ; #SCS_CTRLMETHOD_MMC
        setVisible(WEP\cntNonMSC, #False)
        setVisible(WEP\cntMSC, #True)
        setVisible(WEP\chkMMCApplyFadeForStop, #True)
        setVisible(WEP\lblMSCCommandFormat, #False)
        setVisible(WEP\cboMSCCommandFormat, #False)
        setVisible(WEP\lblGoMacro, #False)
        setVisible(WEP\cboGoMacro, #False)
        
        ; nb set all required variables BEFORE setting cbo ListIndexes, as setting these ListIndexes may fire displayMidiAssigns
        ; which may fail if the required variables are not set
        SGS(WEP\cboMidiDevId, \nMscMmcMidiDevId + 1)
        setEnabled(WEP\cboMidiDevId, #True)
        setOwnState(WEP\chkMMCApplyFadeForStop, \bMMCApplyFadeForStop) ; Added 16Nov2020 11.8.3.3ah
        
      Default ; Default
        setVisible(WEP\cntMSC, #False)
        setVisible(WEP\cntNonMSC, #True)
        
        SGS(WEP\cboMidiDevId, 0)
        setEnabled(WEP\cboMidiDevId, #False)
        
    EndSelect
    setEnabled(WEP\btnTestMidi, bEnableTestMidi)

    
    If \nCtrlMethod = #SCS_CTRLMETHOD_MSC
      setVisible(WEP\lblGoMacro, #True)
      If \nGoMacro = -1
        \nGoMacro = 0
      EndIf
      SGS(WEP\cboGoMacro, \nGoMacro)
      setVisible(WEP\cboGoMacro, #True)
      setEnabled(WEP\cboGoMacro, #True)
    Else
      setVisible(WEP\lblGoMacro, #False)
      \nGoMacro = -1
      SGS(WEP\cboGoMacro, -1)
      setEnabled(WEP\cboGoMacro, #False)
      setVisible(WEP\cboGoMacro, #False)
      
    EndIf
    
    Select \nCtrlMethod
      Case #SCS_CTRLMETHOD_NONE, #SCS_CTRLMETHOD_MTC, #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
        SGS(WEP\cboMidiChannel, -1)
        setEnabled(WEP\cboMidiChannel, #False)
        setVisible(WEP\cntMidiSpecial, #False)
        nHeight = grWEP\nCntMidiAssignsOriginalHeight + grWEP\nHeightChangeIfHideSpecial
        ResizeGadget(WEP\cntMidiAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ResizeGadget(WEP\frMidiAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        nHeight = grWEP\nEdgMidiAssignsOriginalHeight + grWEP\nHeightChangeIfHideSpecial
        ResizeGadget(WEP\edgMidiAssigns, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
        ; debugMsg(sProcName, "GadgetHeight(WEP\edgMidiAssigns)=" + Str(GadgetHeight(WEP\edgMidiAssigns)))
        For n = 0 To gnMaxMidiCommand
          \aMidiCommand[n]\nCmd = -1
          \aMidiCommand[n]\nCC = -1
          \aMidiCommand[n]\nVV = -1
          SGS(WEP\cboMidiCommand[n], -1)
          ; debugMsg0(sProcName, "SGS(WEP\cboMidiCommand[" + n + "], -1)")
          If n = #SCS_MIDI_EXT_FADER
            If IsGadget(WEP\cboThresholdVV)
              SGS(WEP\cboThresholdVV, -1)
            EndIf
          Else
            SGS(WEP\cboMidiCC[n], -1)
            SGS(WEP\cboMidiVV[n], -1)
          EndIf
        Next n
        
      Default
        SGS(WEP\cboMidiChannel, \nMidiChannel)
        setEnabled(WEP\cboMidiChannel, #True)
        ResizeGadget(WEP\edgMidiAssigns,#PB_Ignore,#PB_Ignore,#PB_Ignore,grWEP\nEdgMidiAssignsOriginalHeight)
        ; debugMsg(sProcName, "GadgetHeight(WEP\edgMidiAssigns)=" + GadgetHeight(WEP\edgMidiAssigns))
        ResizeGadget(WEP\frMidiAssigns,#PB_Ignore,#PB_Ignore,#PB_Ignore,grWEP\nCntMidiAssignsOriginalHeight)
        ResizeGadget(WEP\cntMidiAssigns,#PB_Ignore,#PB_Ignore,#PB_Ignore,grWEP\nCntMidiAssignsOriginalHeight)
        setVisible(WEP\cntMidiSpecial, #True)
        For n = 0 To gnMaxMidiCommand
          setEnabled(WEP\cboMidiCommand[n], #True)
        Next n
        
    EndSelect
    
    For n = 0 To gnMaxMidiCommand
      \aMidiCommand[n]\bModifiable = #True
      If bDisplayingDetails = #False
        If \nCtrlMethod <> #SCS_CTRLMETHOD_CUSTOM
          \aMidiCommand[n]\nCmd = -1
          \aMidiCommand[n]\nCC = -1
          \aMidiCommand[n]\nVV = -1
        EndIf
      EndIf
      setEnabled(WEP\cboMidiCommand[n], #False)
      If n = #SCS_MIDI_EXT_FADER
        If IsGadget(WEP\cboThresholdVV)
          setEnabled(WEP\cboThresholdVV, #False)
        EndIf
      Else
        setEnabled(WEP\cboMidiCC[n], #False)
        setEnabled(WEP\cboMidiVV[n], #False)
      EndIf
    Next n
    
    If bDisplayingDetails = #False
      Select \nCtrlMethod
        Case #SCS_CTRLMETHOD_NOTE
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $9     ; note on
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1      ; any value
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $9    ; note on
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 0      ; key 0
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = -1     ; any value
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_PC127
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $C             ; program change
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1              ; any value
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $C            ; program change
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 0              ; program 0
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = -1             ; any value
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_PC128
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $C             ; program change
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1              ; any value
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $C            ; program change
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 128            ; program 128
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = -1             ; any value
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_ETC_AB
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $C             ; program change
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1              ; any value
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $C            ; program change
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 0              ; program 0
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = -1             ; any value
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_ETC_CD
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $B             ; controller change
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = 77              ; controller 77
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1              ; any value (except 0)
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $B            ; controller change
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 77             ; controller 77
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = 0              ; value 0
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_PALLADIUM
          
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCmd = $9             ; note on: play cue
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PLAY_CUE]\nVV = -1              ; any value
          ; \aMidiCommand[#SCS_MIDI_PLAY_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCmd = $9            ; note on
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nCC = 0              ; key 0: 'Go' button
          \aMidiCommand[#SCS_MIDI_GO_BUTTON]\nVV = -1             ; any value
          ; \aMidiCommand[#SCS_MIDI_GO_BUTTON]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_STOP_ALL]\nCmd = $B             ; controller change
          \aMidiCommand[#SCS_MIDI_STOP_ALL]\nCC = $7B             ; 123 (= all notes off): stop everything
          \aMidiCommand[#SCS_MIDI_STOP_ALL]\nVV = 0
          ; \aMidiCommand[#SCS_MIDI_STOP_ALL]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_PAUSE_RESUME_CUE]\nCmd = $8     ; note off: pause/resume cue
          \aMidiCommand[#SCS_MIDI_PAUSE_RESUME_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_PAUSE_RESUME_CUE]\nVV = 0
          ; \aMidiCommand[#SCS_MIDI_PAUSE_RESUME_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_GO_TO_CUE]\nCmd = $C            ; program change: go to cue
          \aMidiCommand[#SCS_MIDI_GO_TO_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_GO_TO_CUE]\nVV = 0
          ; \aMidiCommand[#SCS_MIDI_GO_TO_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_LOAD_CUE]\nCmd = $A             ; key pressure: load cue
          \aMidiCommand[#SCS_MIDI_LOAD_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_LOAD_CUE]\nVV = -1
          ; \aMidiCommand[#SCS_MIDI_LOAD_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
          \aMidiCommand[#SCS_MIDI_UNLOAD_CUE]\nCmd = $D           ; channel pressure: unoad cue
          \aMidiCommand[#SCS_MIDI_UNLOAD_CUE]\nCC = -1
          \aMidiCommand[#SCS_MIDI_UNLOAD_CUE]\nVV = -1
          ; \aMidiCommand[#SCS_MIDI_UNLOAD_CUE]\bModifiable = #False      ; commented out following email from Sam Murez 5/1/2013
          
        Case #SCS_CTRLMETHOD_CUSTOM
          
      EndSelect
    EndIf
    
    WEP_displaySpecialCueCmds()
    
  EndWith
  
  WEP_displayMidiAssigns()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcNetworkDevGrp()
  PROCNAMEC()
  Protected nDevMapDevPtr = -1, nDevNo
  Protected nNetworkRole = -1
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      nDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
      nDevNo = grWEP\nCurrentCtrlDevNo
      If nDevNo >= 0
        nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nNetworkRole
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      nDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
      nDevNo = grWEP\nCurrentCueDevNo
      If nDevNo >= 0
        nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)\nNetworkRole
      EndIf
      
  EndSelect
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      Select nNetworkRole
        Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
          If Len(Trim(\sRemoteHost)) = 0
            SGT(WEP\txtRemoteHost, "")
          Else
            SGT(WEP\txtRemoteHost, \sRemoteHost)
          EndIf
          SGT(WEP\txtRemotePort, portIntToStr(\nRemotePort))
          
        Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
          SGT(WEP\txtLocalPort, portIntToStr(\nLocalPort))
          
      EndSelect
    EndWith
  EndIf

EndProcedure

Procedure ED_fcNetworkMsgAction(Index)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If (grWEP\nCurrentCtrlDevNo >= 0) And (Index >= 0)
    With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)\aMsgResponse[Index]
      Select \nMsgAction
        Case #SCS_NETWORK_ACT_REPLY
          setEnabled(WEP\txtNetworkReplyMsg[Index], #True, #True)
        Default
          If Len(\sReplyMsg) > 0
            \sReplyMsg = ""
            SGTIR(WEP\txtNetworkReplyMsg[Index], "")
          EndIf
          setEnabled(WEP\txtNetworkReplyMsg[Index], #False, #True)
      EndSelect
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcCtrlMidiRemoteDevCode(sPrevCtrlMidiRemoteDevCode.s)
  PROCNAMEC()
  Protected nPhysicalDevPtr
  Protected nDevMapDevPtr, nDevNo
  Protected sCtrlMidiRemoteDevCode.s, nRemDevId
  Protected bRemoteDevChanged
  Protected bMidiChannelVisible
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = grWEP\nCurrentCtrlDevNo
  nDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
  
  If (nDevNo >= 0) And (nDevMapDevPtr >= 0)
    debugMsg(sProcName, "sPrevCtrlMidiRemoteDevCode=" + sPrevCtrlMidiRemoteDevCode +
                        ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\sCtrlMidiRemoteDevCode=" + grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sCtrlMidiRemoteDevCode)
    
    If grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sCtrlMidiRemoteDevCode <> sPrevCtrlMidiRemoteDevCode
      bRemoteDevChanged = #True
    EndIf
    
    If bRemoteDevChanged
      sCtrlMidiRemoteDevCode = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\sCtrlMidiRemoteDevCode
      nRemDevId = CSRD_GetRemDevIdForDevCode(#SCS_DEVTYPE_CS_MIDI_OUT, sCtrlMidiRemoteDevCode)
      If nRemDevId >= 0
        If CSRD_GetDfltMidiChanForRemDevId(nRemDevId) > 0
          bMidiChannelVisible = #True
        EndIf
      EndIf
      setVisible(WEP\lblCtrlMidiChannel, bMidiChannelVisible)
      setVisible(WEP\cboCtrlMidiChannel, bMidiChannelVisible)
      If bMidiChannelVisible
        debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\nCtrlMidiChannel=" + grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlMidiChannel)
        setGadgetItemByData(WEP\cboCtrlMidiChannel, grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlMidiChannel, 0)
      EndIf
    EndIf
    
    WEP_displayCtrlPhysInfo(nDevNo)
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcCtrlNetworkRemoteDev(nPrevCtrlNetworkRemoteDev)
  PROCNAMEC()
  Protected n
  Protected nIndex
  Protected nPhysicalDevPtr
  Protected nDevMapDevPtr, nDevNo
  Protected nPrevDefPort
  Protected nCtrlNetworkRemoteDev
  Protected bRemoteDevChanged
  Protected bShowGetRemDevScribbleStripNames
  Protected bShowDelayBeforeReloadNames
  Protected bShowPassword
  Protected bShowNetworkMsgResponses
  Protected bDummy
  Protected bOSC
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = 0
  nDevNo = grWEP\nCurrentCtrlDevNo
  nDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
  
  If (nDevNo >= 0) And (nDevMapDevPtr >= 0)
    debugMsg(sProcName, "nPrevCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(nPrevCtrlNetworkRemoteDev) + ", nPrevDefPort=" + nPrevDefPort +
                        ", grProdForDevChgs\aCtrlSendLogicalDevs(" + nDevNo + ")\nCtrlNetworkRemoteDev=" + decodeCtrlNetworkRemoteDev(grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev) +
                        ", grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nRemotePort=" + grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort)
    
    If grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev <> nPrevCtrlNetworkRemoteDev
      bRemoteDevChanged = #True
    EndIf
    
    bDummy = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
    
    grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nMaxMsgResponse = 0   ; may be updated later in this procedure
    nCtrlNetworkRemoteDev = grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\nCtrlNetworkRemoteDev
    Select nCtrlNetworkRemoteDev
        
      Case #SCS_CS_NETWORK_REM_SCS
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_UDP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
          setEnabled(WEP\cboNetworkRole[nIndex], #False)
          If bDummy
            setEnabled(WEP\txtRemotePort[nIndex], #False)
          Else
            setEnabled(WEP\txtRemotePort[nIndex], #True)
          EndIf
        EndWith
        
      Case #SCS_CS_NETWORK_REM_PJLINK, #SCS_CS_NETWORK_REM_PJNET
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_TCP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_PJLINK
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 4352
              \sCtrlNetworkRemoteDevPassword = "JBMIAProjectorLink"
            Else
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 10000
              \sCtrlNetworkRemoteDevPassword = ""
            EndIf
            \bReplyMsgAddCR = #True
            \bReplyMsgAddLF = #False
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          setEnabled(WEP\cboNetworkRole[nIndex], #False)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\txtRemotePort[nIndex], #True)
          SGT(WEP\txtCtrlNetworkRemoteDevPW, \sCtrlNetworkRemoteDevPassword)
        EndWith
        bShowPassword = #True
        
      Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_UDP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 10023
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
          setEnabled(WEP\cboNetworkRole[nIndex], #False)
          If bDummy
            setEnabled(WEP\txtRemoteHost[nIndex], #False)
          Else
            setEnabled(WEP\txtRemoteHost[nIndex], #True)
          EndIf
          setEnabled(WEP\txtRemotePort[nIndex], #False)
          setComboBoxByData(WEP\cboDelayBeforeReloadNames, \nDelayBeforeReloadNames, 0)
          setOwnState(WEP\chkGetRemDevScribbleStripNames, grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bGetRemDevScribbleStripNames)
          If grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bGetRemDevScribbleStripNames
            setEnabled(WEP\cboDelayBeforeReloadNames, #True)
          Else
            setEnabled(WEP\cboDelayBeforeReloadNames, #False)
          EndIf
          bShowGetRemDevScribbleStripNames = #True
          bShowDelayBeforeReloadNames = #True
        EndWith
        
      Case #SCS_CS_NETWORK_REM_OSC_X32TC
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_UDP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 32000
            grMapsForDevChgs\aDev(nDevMapDevPtr)\sRemoteHost = "127.0.0.1" ; as suggested by James Holt (X32TC writer) 15Jun2021
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
          setEnabled(WEP\cboNetworkRole[nIndex], #False)
          setEnabled(WEP\txtRemotePort[nIndex], #False)
        EndWith
        
      Case #SCS_CS_NETWORK_REM_LF
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_TCP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 3100
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
          setEnabled(WEP\cboNetworkRole[nIndex], #True)
          setEnabled(WEP\txtRemotePort[nIndex], #True)
        EndWith
        
      Case #SCS_CS_NETWORK_REM_VMIX
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_TCP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 8099
            grMapsForDevChgs\aDev(nDevMapDevPtr)\nCtrlSendDelay = 0
          EndIf
          setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
          setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
          setEnabled(WEP\cboNetworkRole[nIndex], #False)
          setEnabled(WEP\txtRemotePort[nIndex], #False)
        EndWith
        
      Default
        With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
          If bRemoteDevChanged
            \nNetworkProtocol = #SCS_NETWORK_PR_TCP
            \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
          EndIf
          setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
          setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
          setEnabled(WEP\cboNetworkRole[nIndex], #True)
          setEnabled(WEP\txtRemotePort[nIndex], #True)
          For n = 0 To #SCS_MAX_NETWORK_MSG_RESPONSE
            setEnabled(WEP\txtNetworkReceiveMsg[n], #True, #True)
            setEnabled(WEP\cboNetworkMsgAction[n], #True)
            ED_fcNetworkMsgAction(n)
          Next n
          setEnabled(WEP\chkNetworkReplyMsgAddCR, #True)
          setEnabled(WEP\chkNetworkReplyMsgAddLF, #True)
          bShowNetworkMsgResponses = #True
        EndWith
    EndSelect
    
    If nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_OTHER
      setVisible(WEP\lblOSCVersion[0], #True)
      setVisible(WEP\cboOSCVersion[0], #True)
      With grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)
        setComboBoxByData(WEP\cboOSCVersion[0], \nOSCVersion)
      EndWith
    Else
      setVisible(WEP\lblOSCVersion[0], #False)
      setVisible(WEP\cboOSCVersion[0], #False)
    EndIf
    
    If getVisible(WEP\chkConnectWhenReqd)
      setOwnState(WEP\chkConnectWhenReqd, grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bConnectWhenReqd)
    EndIf
    
    If bShowGetRemDevScribbleStripNames
      setOwnState(WEP\chkGetRemDevScribbleStripNames, grProdForDevChgs\aCtrlSendLogicalDevs(nDevNo)\bGetRemDevScribbleStripNames)
    EndIf
    
    setVisible(WEP\chkGetRemDevScribbleStripNames, bShowGetRemDevScribbleStripNames)
    setVisible(WEP\lblDelayBeforeReloadNames, bShowDelayBeforeReloadNames)
    setVisible(WEP\cboDelayBeforeReloadNames, bShowDelayBeforeReloadNames)
    setVisible(WEP\cntCtrlNetworkRemoteDevPW, bShowPassword)
    setVisible(WEP\cntNetworkMsgResponses, bShowNetworkMsgResponses)
    
    debugMsg(sProcName, "calling updateNetworkControlForDevChgsDev(" + nDevMapDevPtr + ", " + nDevNo + ")")
    updateNetworkControlForDevChgsDev(nDevMapDevPtr, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcNetworkRole(" + strB(bRemoteDevChanged) + ")")
    ED_fcNetworkRole(bRemoteDevChanged)
    
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
        \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
        debugMsg(sProcName, "gaNetworkControl(" + Str(nPhysicalDevPtr) + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
      EndIf
    EndWith
    
    WEP_displayCtrlPhysInfo(nDevNo)
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcCueNetworkRemoteDev(nPrevCueNetworkRemoteDev)
  PROCNAMEC()
  Protected n
  Protected nIndex
  Protected nPhysicalDevPtr
  Protected nDevMapDevPtr, nDevNo
  Protected bRemoteDevChanged
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grWEP\nCurrentCueDevNo=" + grWEP\nCurrentCueDevNo + ", grWEP\nCurrentCueDevMapDevPtr=" + grWEP\nCurrentCueDevMapDevPtr)
  nIndex = 1
  nDevNo = grWEP\nCurrentCueDevNo
  
  If nDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(nDevNo)
      nDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
      If nDevMapDevPtr < 0
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, \sCueCtrlLogicalDev)
      EndIf
      debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
      If nDevMapDevPtr >= 0
        
        If \nCueNetworkRemoteDev <> nPrevCueNetworkRemoteDev
          bRemoteDevChanged = #True
        EndIf
        
        debugMsg(sProcName, "grProdForDevChgs\aCueCtrlLogicalDevs(" + nDevNo + ")\nCueNetworkRemoteDev=" + decodeCueNetworkRemoteDev(\nCueNetworkRemoteDev))
        Select \nCueNetworkRemoteDev
          Case #SCS_CC_NETWORK_REM_SCS
            If bRemoteDevChanged
              \nNetworkProtocol = #SCS_NETWORK_PR_UDP
              \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort = #SCS_DEFAULT_NETWORK_LOCAL_PORT
            EndIf
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
            setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
            setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
            setEnabled(WEP\cboNetworkRole[nIndex], #False)
            SGT(WEP\txtLocalPort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort))
            
          Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
            If bRemoteDevChanged
              \nNetworkProtocol = #SCS_NETWORK_PR_UDP
              \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort = 10023 ; see also macro macInitDevMap()
            EndIf
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
            setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
            SGT(WEP\txtRemotePort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nRemotePort))
            setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
            setEnabled(WEP\cboNetworkRole[nIndex], #False)
            setEnabled(WEP\txtRemotePort[nIndex], #False)
            
          Case #SCS_CC_NETWORK_REM_OSC_X32TC
            If bRemoteDevChanged
              \nNetworkProtocol = #SCS_NETWORK_PR_UDP
              \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort = 59000 ; see also macro macInitDevMap()
            EndIf
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
            setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
            SGT(WEP\txtLocalPort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort))
            setEnabled(WEP\cboNetworkProtocol[nIndex], #False)
            setEnabled(WEP\cboNetworkRole[nIndex], #False)
            setEnabled(WEP\txtLocalPort[nIndex], #False)
            
          Case #SCS_CC_NETWORK_REM_LF
            If bRemoteDevChanged
              \nNetworkProtocol = #SCS_NETWORK_PR_TCP
              \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
              grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort = 3100 ; see also macro macInitDevMap()
            EndIf
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
            setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
            setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
            setEnabled(WEP\cboNetworkRole[nIndex], #True)
            SGT(WEP\txtLocalPort[nIndex], portIntToStr(grMapsForDevChgs\aDev(nDevMapDevPtr)\nLocalPort))
            
          Default
            If bRemoteDevChanged
              \nNetworkProtocol = #SCS_NETWORK_PR_TCP
              \nNetworkRole = #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            EndIf
            setComboBoxByData(WEP\cboNetworkProtocol[nIndex], \nNetworkProtocol)
            setEnabled(WEP\cboNetworkProtocol[nIndex], #True)
            setComboBoxByData(WEP\cboNetworkRole[nIndex], \nNetworkRole)
            setEnabled(WEP\cboNetworkRole[nIndex], #True)
            
        EndSelect
        
      EndIf
      
    EndWith
    
    debugMsg(sProcName, "calling updateNetworkControlForDevChgsDev(" + nDevMapDevPtr + ", " + nDevNo + ")")
    updateNetworkControlForDevChgsDev(nDevMapDevPtr, nDevNo)
    
    debugMsg(sProcName, "calling ED_fcNetworkRole()")
    ED_fcNetworkRole()
    
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      nPhysicalDevPtr = \nPhysicalDevPtr
      If nPhysicalDevPtr >= 0
        buildNetworkDevDesc(@gaNetworkControl(nPhysicalDevPtr))
        \sPhysicalDev = gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc
        debugMsg(sProcName, "gaNetworkControl(" + nPhysicalDevPtr + ")\sNetworkDevDesc=" + gaNetworkControl(nPhysicalDevPtr)\sNetworkDevDesc)
        debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\sPhysicalDev=" + \sPhysicalDev)
      EndIf
    EndWith
    
    debugMsg(sProcName, "calling WEP_displayCuePhysInfo(" + grWEP\nCurrentCueDevNo + ")")
    WEP_displayCuePhysInfo(grWEP\nCurrentCueDevNo)
    
;     debugMsg(sProcName, "calling listAllDevMapsForDevChgs()")
;     listAllDevMapsForDevChgs()
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcNetworkRole(bRemoteDevChanged=#False)
  PROCNAMEC()
  Protected nCurrentDevMapDevPtr=-1, nIndex
  Protected nNetworkRole, sLogicalDev.s
  Protected sRemoteHost.s, nRemotePort, nLocalPort, nCtrlSendDelay
  Protected bDummy, bVMix
  Protected nNetworkProtocol = #SCS_NETWORK_PR_TCP
  Protected nRemoteDev, bCtrlSendDelayVisible
  
  debugMsg(sProcName, #SCS_START + ", bRemoteDevChanged=" + strB(bRemoteDevChanged) + ", grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      nIndex = 0
      debugMsg(sProcName, "grWEP\nCurrentCtrlDevMapDevPtr=" + grWEP\nCurrentCtrlDevMapDevPtr)
      nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
      If grWEP\nCurrentCtrlDevNo >= 0
        With grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)
          nNetworkRole = \nNetworkRole
          sLogicalDev = \sLogicalDev
          nNetworkProtocol = \nNetworkProtocol
          If nNetworkProtocol = #SCS_NETWORK_PR_TCP ; TCP test added 9Jul2024 as delay not required for UDP
            If \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_VMIX
              bVMix = #True
            EndIf
            If \nCtrlNetworkRemoteDev = #SCS_CS_NETWORK_REM_OSC_OTHER
              bCtrlSendDelayVisible = #False
            Else
              bCtrlSendDelayVisible = #True
            EndIf
          EndIf
        EndWith
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      nIndex = 1
      debugMsg(sProcName, "grWEP\nCurrentCueDevMapDevPtr=" + grWEP\nCurrentCueDevMapDevPtr)
      nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
      If grWEP\nCurrentCueDevNo >= 0
        With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
          nNetworkRole = \nNetworkRole
          sLogicalDev = \sCueCtrlLogicalDev
        EndWith
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, "nCurrentDevMapDevPtr=" + nCurrentDevMapDevPtr + ", nNetworkRole=" + decodeNetworkRole(nNetworkRole) + ", sLogicalDev=" + sLogicalDev)
  
  If nCurrentDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)
      sRemoteHost = \sRemoteHost
      nRemotePort = \nRemotePort
      nLocalPort = \nLocalPort
      bDummy = \bDummy
      nCtrlSendDelay = \nCtrlSendDelay
    EndWith
  Else
    With grDevMapDevDef
      sRemoteHost = \sRemoteHost
      nRemotePort = \nRemotePort
      nLocalPort = \nLocalPort
      bDummy = \bDummy
      nCtrlSendDelay = \nCtrlSendDelay
    EndWith
  EndIf
  
  If bCtrlSendDelayVisible = #False
    nCtrlSendDelay = 0
  Else
    If bVMix And bRemoteDevChanged
      ; NB an email response from vMix on 20Sep2020 stated that "The vMix API does not need message boundaries to process messages"
      ; so therefore it is not necessary to impose a delay between consecutive messages.
      nCtrlSendDelay = 0
    ElseIf nCtrlSendDelay < 0
      If nNetworkProtocol = #SCS_NETWORK_PR_UDP
        nCtrlSendDelay = #SCS_NETWORK_DELAY_UDP ; 0ms at time of coding (13Apr2019 11.8.1)
      Else
        nCtrlSendDelay = #SCS_NETWORK_DELAY_TCP ; 100ms at time of coding (13Apr2019 11.8.1)
      EndIf
    EndIf
    debugMsg(sProcName, "nCtrlSendDelay=" + nCtrlSendDelay)
  EndIf
  
  Select nNetworkRole
    Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
      setVisible(WEP\chkConnectWhenReqd, #True)
      setVisible(WEP\lblLocalPort[nIndex], #False)
      setVisible(WEP\txtLocalPort[nIndex], #False)
      setVisible(WEP\btnCompIPAddresses[nIndex], #False)
      setVisible(WEP\lblRemoteHost[nIndex], #True)
      setVisible(WEP\txtRemoteHost[nIndex], #True)
      setVisible(WEP\lblRemotePort[nIndex], #True)
      setVisible(WEP\txtRemotePort[nIndex], #True)
      SGT(WEP\txtRemoteHost[nIndex], sRemoteHost)
      SGT(WEP\txtRemotePort[nIndex], portIntToStr(nRemotePort))
      
    Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
      setVisible(WEP\chkConnectWhenReqd, #True)
      setVisible(WEP\lblRemoteHost[nIndex], #False)
      setVisible(WEP\txtRemoteHost[nIndex], #False)
      setVisible(WEP\lblRemotePort[nIndex], #False)
      setVisible(WEP\txtRemotePort[nIndex], #False)
      setVisible(WEP\lblLocalPort[nIndex], #True)
      setVisible(WEP\txtLocalPort[nIndex], #True)
      setVisible(WEP\btnCompIPAddresses[nIndex], #True)
      SGT(WEP\txtLocalPort[nIndex], portIntToStr(nLocalPort))
      
    Case #SCS_ROLE_DUMMY
      setVisible(WEP\chkConnectWhenReqd, #False)
      setVisible(WEP\lblRemoteHost[nIndex], #False)
      setVisible(WEP\txtRemoteHost[nIndex], #False)
      setVisible(WEP\lblRemotePort[nIndex], #False)
      setVisible(WEP\txtRemotePort[nIndex], #False)
      setVisible(WEP\lblLocalPort[nIndex], #False)
      setVisible(WEP\txtLocalPort[nIndex], #False)
      setVisible(WEP\btnCompIPAddresses[nIndex], #False)
      bCtrlSendDelayVisible = #False
      
  EndSelect
  
  setVisible(WEP\lblCtrlSendDelay, bCtrlSendDelayVisible)
  setVisible(WEP\txtCtrlSendDelay, bCtrlSendDelayVisible)
  If bCtrlSendDelayVisible
    SGT(WEP\txtCtrlSendDelay, Str(nCtrlSendDelay))
  EndIf
    
  setOwnState(WEP\chkNetworkDummy[nIndex], bDummy)
  debugMsg(sProcName, "calling ED_fcNetworkDummy()")
  ED_fcNetworkDummy()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcNetworkDummy()
  PROCNAMEC()
  Protected nIndex
  Protected nNetworkRole, bDummy
  Protected bEnableRemoteHost = #True, bEnableRemotePort = #True, bEnableLocalPort = #True
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grWEP\nCurrentDevGrp=" + decodeDevGrp(grWEP\nCurrentDevGrp))
  
  Select grWEP\nCurrentDevGrp
    Case #SCS_DEVGRP_CTRL_SEND
      nIndex = 0
      debugMsg(sProcName, "grWEP\nCurrentCtrlDevNo=" + grWEP\nCurrentCtrlDevNo + ", grWEP\nCurrentCtrlDevMapDevPtr=" + grWEP\nCurrentCtrlDevMapDevPtr)
      If (grWEP\nCurrentCtrlDevNo >= 0) And (grWEP\nCurrentCtrlDevMapDevPtr >= 0)
        nNetworkRole = grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)\nNetworkRole
        bDummy = grMapsForDevChgs\aDev(grWEP\nCurrentCtrlDevMapDevPtr)\bDummy
        debugMsg(sProcName, "nNetworkRole=" + decodeNetworkRole(nNetworkRole) + ", bDummy=" + strB(bDummy))
        
        Select nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            If bDummy
              bEnableRemoteHost = #False
              bEnableRemotePort = #False
            Else
              ; debugMsg(sProcName, "grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)\nCtrlNetworkRemoteDev=" + grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)\nCtrlNetworkRemoteDev)
              Select grProdForDevChgs\aCtrlSendLogicalDevs(grWEP\nCurrentCtrlDevNo)\nCtrlNetworkRemoteDev
                Case #SCS_CS_NETWORK_REM_OSC_X32, #SCS_CS_NETWORK_REM_OSC_X32_COMPACT, #SCS_CS_NETWORK_REM_OSC_X32TC, #SCS_CS_NETWORK_REM_VMIX
                  bEnableRemotePort = #False
              EndSelect
            EndIf
            setEnabled(WEP\txtRemoteHost[nIndex], bEnableRemoteHost)
            setEnabled(WEP\txtRemotePort[nIndex], bEnableRemotePort)
            
          Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            If bDummy
              bEnableLocalPort = #False
            EndIf
            setEnabled(WEP\txtLocalPort[nIndex], bEnableLocalPort)
            
        EndSelect
      EndIf
      
    Case #SCS_DEVGRP_CUE_CTRL
      nIndex = 1
      If (grWEP\nCurrentCueDevNo >= 0) And (grWEP\nCurrentCueDevMapDevPtr >= 0)
        nNetworkRole = grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nNetworkRole
        bDummy = grMapsForDevChgs\aDev(grWEP\nCurrentCueDevMapDevPtr)\bDummy
        
        Select nNetworkRole
          Case #SCS_NETWORK_ROLE_SCS_IS_A_CLIENT
            If bDummy
              bEnableRemoteHost = #False
              bEnableRemotePort = #False
            Else
              Select grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nCueNetworkRemoteDev
                Case #SCS_CC_NETWORK_REM_OSC_X32, #SCS_CC_NETWORK_REM_OSC_X32_COMPACT
                  bEnableRemotePort = #False
              EndSelect
            EndIf
            setEnabled(WEP\txtRemoteHost[nIndex], bEnableRemoteHost)
            setEnabled(WEP\txtRemotePort[nIndex], bEnableRemotePort)
            
          Case #SCS_NETWORK_ROLE_SCS_IS_A_SERVER
            If bDummy
              bEnableLocalPort = #False
            Else
              Select grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nCueNetworkRemoteDev
                Case #SCS_CC_NETWORK_REM_OSC_X32TC
                  bEnableLocalPort = #False
              EndSelect
            EndIf
            setEnabled(WEP\txtLocalPort[nIndex], bEnableLocalPort)
            
        EndSelect
      EndIf
      
  EndSelect
  
  WEP_setNetworkButtons()

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure ED_fcDMXTrgCtrl()
  PROCNAMEC()
  
  If grWEP\nCurrentCueDevNo >= 0
    With grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)
      If \nDMXTrgCtrl = #SCS_DMX_TRG_CHG_UP_TO_VALUE
        setEnabled(WEP\cboDMXTrgValue, #True)
      Else
        setEnabled(WEP\cboDMXTrgValue, #False)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcRS232Port(Index)
  PROCNAMEC()
  Protected nPhysicalDevPtr
  Protected nCurrentDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If Index = 0
    nCurrentDevMapDevPtr = grWEP\nCurrentCtrlDevMapDevPtr
  Else
    nCurrentDevMapDevPtr = grWEP\nCurrentCueDevMapDevPtr
  EndIf
  
  If nCurrentDevMapDevPtr >= 0
    nPhysicalDevPtr = grMapsForDevChgs\aDev(nCurrentDevMapDevPtr)\nPhysicalDevPtr
    If nPhysicalDevPtr >= 0
      If (gaRS232Control(nPhysicalDevPtr)\bRS232In) And (gaRS232Control(nPhysicalDevPtr)\bRS232Out)
        ; this RS232 port required for both input and output
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure ED_fcSldDfltDevLevel()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      \fDfltBVLevel = SLD_getLevel(WEP\sldDfltDevLevel)
      \sDfltDBLevel = convertBVLevelToDBString(\fDfltBVLevel, #False, #True)
      SGT(WEP\txtDfltDevDBLevel, convertBVLevelToDBString(\fDfltBVLevel, #False, #True))
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure ED_fcSldDfltVidAudLevel()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      \fDfltBVLevel = SLD_getLevel(WEP\sldDfltVidAudLevel)
      \sDfltDBLevel = convertBVLevelToDBString(\fDfltBVLevel, #False, #True)
      SGT(WEP\txtDfltVidAudDBLevel, convertBVLevelToDBString(\fDfltBVLevel, #False, #True))
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure ED_fcTxtDfltDevDBLevel()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      If SLD_getLevel(WEP\sldDfltDevLevel) <> \fDfltBVLevel
        SLD_setLevel(WEP\sldDfltDevLevel, \fDfltBVLevel, \fDfltTrimFactor)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure ED_fcTxtDfltDevPan()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      \fDfltPan = panStringToSingle(GGT(WEP\txtDfltDevPan))
      SLD_setValue(WEP\sldDfltDevPan, panToSliderValue(\fDfltPan))
      If \fDfltPan = #SCS_PANCENTRE_SINGLE
        setEnabled(WEP\btnDfltDevCenter, #False)
      Else
        setEnabled(WEP\btnDfltDevCenter, #True)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcTxtDfltVidAudDBLevel()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      If SLD_getLevel(WEP\sldDfltVidAudLevel) <> \fDfltBVLevel
        SLD_setLevel(WEP\sldDfltVidAudLevel, \fDfltBVLevel, \fDfltTrimFactor)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure ED_fcTxtDfltVidAudPan()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      \fDfltPan = panStringToSingle(GGT(WEP\txtDfltVidAudPan))
      SLD_setValue(WEP\sldDfltVidAudPan, panToSliderValue(\fDfltPan))
      If \fDfltPan = #SCS_PANCENTRE_SINGLE
        setEnabled(WEP\btnDfltVidAudCenter, #False)
      Else
        setEnabled(WEP\btnDfltVidAudCenter, #True)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcSldDfltInputDevLevel()
  PROCNAMEC()
  Protected nDevNo
  Protected nOutputDevNo
  
  nDevNo = grWEP\nCurrentLiveDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
      \fDfltInputLevel = SLD_getLevel(WEP\sldDfltInputDevLevel)
      \sDfltInputDBLevel = convertBVLevelToDBString(\fDfltInputLevel, #False, #True)
      SGT(WEP\txtDfltInputDevDBLevel, convertBVLevelToDBString(\fDfltInputLevel, #False, #True))
      ; commented out because the 'default level' does not affect the live input test level
      ; If grTestLiveInput\bRunningTestLiveInput
        ; nOutputDevNo = getCurrentItemData(WEP\cboOutputDevForTestLiveInput, -1)
        ; If nOutputDevNo >= 0
          ; adjustTestLiveInputLevel(nDevNo, nOutputDevNo)
        ; EndIf
      ; EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
EndProcedure

Procedure ED_fcTxtDfltInputDevDBLevel()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentLiveDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aLiveInputLogicalDevs(nDevNo)
      If SLD_getLevel(WEP\sldDfltInputDevLevel) <> \fDfltInputLevel
        SLD_setLevel(WEP\sldDfltInputDevLevel, \fDfltInputLevel)
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure ED_fcSldDfltDevPan()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aAudioLogicalDevs(nDevNo)
      \fDfltPan = panSliderValToSingle(SLD_getValue(WEP\sldDfltDevPan))
      SGT(WEP\txtDfltDevPan, panSingleToString(\fDfltPan))
      If \fDfltPan = #SCS_PANCENTRE_SINGLE
        setEnabled(WEP\btnDfltDevCenter, #False)
      Else
        setEnabled(WEP\btnDfltDevCenter, #True)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcSldDfltVidAudPan()
  PROCNAMEC()
  Protected nDevNo
  
  nDevNo = grWEP\nCurrentVidAudDevNo
  If nDevNo >= 0
    With grProdForDevChgs\aVidAudLogicalDevs(nDevNo)
      \fDfltPan = panSliderValToSingle(SLD_getValue(WEP\sldDfltVidAudPan))
      SGT(WEP\txtDfltVidAudPan, panSingleToString(\fDfltPan))
      If \fDfltPan = #SCS_PANCENTRE_SINGLE
        setEnabled(WEP\btnDfltVidAudCenter, #False)
      Else
        setEnabled(WEP\btnDfltVidAudCenter, #True)
      EndIf
      WEP_setDevChgsBtns()
    EndWith
  EndIf
  
EndProcedure

Procedure ED_fcSldDMXMasterFader()
  PROCNAMEC()
  Protected u
  Protected nCurrValue, nResetValue, nUndoFlags
  
  debugMsg(sProcName, #SCS_START)
  
  With grProd
    nCurrValue = grDMXMasterFader\nDMXMasterFaderValue
    nResetValue = grDMXMasterFader\nDMXMasterFaderResetValue
    debugMsg(sProcName, "nCurrValue=" + nCurrValue + ", nResetValue=" + nResetValue)
    If nCurrValue = nResetValue
      nUndoFlags = #SCS_UNDO_FLAG_SET_DMX_MASTER_FADER
    EndIf
    u = preChangeProdF(\nDMXMasterFaderValue, GGT(WEP\lblDMXMasterFader), -5, #SCS_UNDO_ACTION_CHANGE, -1, nUndoFlags)
    \nDMXMasterFaderValue = SLD_getValue(WEP\sldDMXMasterFader2)
    grDMXMasterFader\nDMXMasterFaderValue = \nDMXMasterFaderValue
    grDMXMasterFader\nDMXMasterFaderResetValue = \nDMXMasterFaderValue
    DMX_setDMXMasterFader(\nDMXMasterFaderValue)
    If SLD_isSlider(WCN\sldDMXMasterFader)
      SLD_setValue(WCN\sldDMXMasterFader, \nDMXMasterFaderValue)
    EndIf
    postChangeProdF(u, \nDMXMasterFaderValue)
    grCED\bProdChanged = #True
  EndWith
EndProcedure

Procedure ED_fcSldMasterFader()
  PROCNAMEC()
  Protected u
  Protected fMainSliderLevel.f, fMainBaseLevel.f, nUndoFlags
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grProd
    fMainSliderLevel = SLD_getLevel(WMN\sldMasterFader)
    fMainBaseLevel = SLD_getBaseLevel(WMN\sldMasterFader)
    ; debugMsg(sProcName, "fMainSliderLevel=" + fMainSliderLevel + ", fMainBaseLevel=" + fMainBaseLevel)
    If fMainSliderLevel = fMainBaseLevel
      nUndoFlags = #SCS_UNDO_FLAG_SET_MASTER_VOL
    EndIf
    u = preChangeProdF(\fMasterBVLevel, GGT(WEP\lblMasterFader), -5, #SCS_UNDO_ACTION_CHANGE, -1, nUndoFlags)
    ; debugMsg(sProcName, "SLD_getLevel(WEP\sldMasterFader2)=" + SLD_getLevel(WEP\sldMasterFader2))
    \fMasterBVLevel = SLD_getLevel(WEP\sldMasterFader2)
    grMasterLevel\fProdMasterBVLevel = \fMasterBVLevel
    ; debugMsg(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
    \sMasterDBVol = convertBVLevelToDBString(\fMasterBVLevel, #False, #True)
    SGT(WEP\txtMasterFaderDB, \sMasterDBVol)
    If fMainSliderLevel = fMainBaseLevel
      setMasterFader(\fMasterBVLevel)
      SLD_setLevel(WMN\sldMasterFader, \fMasterBVLevel)
      SLD_setBaseLevel(WMN\sldMasterFader, \fMasterBVLevel)
    Else
      SLD_setBaseLevel(WMN\sldMasterFader, \fMasterBVLevel)
    EndIf
    postChangeProdF(u, \fMasterBVLevel)
    grCED\bProdChanged = #True
  EndWith
EndProcedure

Procedure ED_fcSldInputGain(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxLiveDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \fInputGain = SLD_getLevel(WEP\sldInputGain(Index))
      \sInputGainDB = convertBVLevelToDBString(\fInputGain, #False, #True)
      SGT(WEP\txtInputGainDB(Index), \sInputGainDB)
    EndWith
    setInputGain(nDevNo, #True)
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure ED_fcTxtInputGainDB(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_LIVE_INPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxLiveDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      If SLD_getLevel(WEP\sldInputGain(Index)) <> \fInputGain
        SLD_setLevel(WEP\sldInputGain(Index), \fInputGain)
      EndIf
    EndWith
    setInputGain(nDevNo, #True)
  EndIf
  
EndProcedure

Procedure ED_fcSldOutputGain(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \fDevOutputGain = SLD_getLevel(WEP\sldAudOutputGain(Index))
      \sDevOutputGainDB = convertBVLevelToDBString(\fDevOutputGain, #False, #True)
      SGT(WEP\txtAudOutputGainDB(Index), \sDevOutputGainDB)
    EndWith
    setAudioDevOutputGain(nDevNo, #True)
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure ED_fcTxtOutputGainDB(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      If SLD_getLevel(WEP\sldAudOutputGain(Index)) <> \fDevOutputGain
        SLD_setLevel(WEP\sldAudOutputGain(Index), \fDevOutputGain)
      EndIf
    EndWith
    setAudioDevOutputGain(nDevNo, #True)
  EndIf
  
EndProcedure

Procedure ED_fcSldVidAudOutputGain(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxVidAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      \fDevOutputGain = SLD_getLevel(WEP\sldVidAudOutputGain(Index))
      \sDevOutputGainDB = convertBVLevelToDBString(\fDevOutputGain, #False, #True)
      SGT(WEP\txtVidAudOutputGainDB(Index), \sDevOutputGainDB)
    EndWith
    setVidAudDevOutputGain(nDevNo, #True)
  EndIf
  
  If grWEP\bInDisplayDevProd = #False
    WEP_setDevChgsBtns()
  EndIf
  
EndProcedure

Procedure ED_fcTxtVidAudOutputGainDB(Index)
  PROCNAMEC()
  Protected nDevNo
  Protected nDevMapPtr, nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  nDevNo = Index
  
  nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  nDevMapDevPtr = getDevChgsDevPtrForDevNo(#SCS_DEVGRP_VIDEO_AUDIO, nDevNo)
  
  If nDevNo <= grLicInfo\nMaxVidAudDevPerProd
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      If SLD_getLevel(WEP\sldVidAudOutputGain(Index)) <> \fDevOutputGain
        SLD_setLevel(WEP\sldVidAudOutputGain(Index), \fDevOutputGain)
      EndIf
    EndWith
    setVidAudDevOutputGain(nDevNo, #True)
  EndIf
  
EndProcedure

Procedure ED_renumberCueCtrlLogicalDevs(*rProd.tyProd)
  Protected d
  
  With *rProd
    For d = 0 To ArraySize(\aCueCtrlLogicalDevs()) ; \nMaxCueCtrlLogicalDevDisplay
      \aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev = "C" + Str(d+1)
    Next d
  EndWith
  
EndProcedure

; EOF