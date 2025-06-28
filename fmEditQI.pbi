; File: fmEditQI.pbi

EnableExplicit

Procedure WQI_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nListIndex
  Protected d
  Protected bDevPresent
  Protected fEditFadeInLevel.f
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQICreated = #False
    WQI_Form_Load()
  EndIf
  
  ; set sub-cue properties header line
  setSubHeader(WQI\lblSubCueType, pSubPtr)
  
  ; propogate input and audio devs into logical dev combo boxes if reqd
  propogateProdDevs("I")
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "I", WQI)
    setEditAudPtr(\nFirstAudIndex)
  EndWith
  
  With aAud(nEditAudPtr)
    
    If \nFileState = #SCS_FILESTATE_CLOSED
      debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
      setIgnoreDevInds(nEditAudPtr, #True)
      debugMsg(sProcName, "calling openInputChannels(" + getAudLabel(nEditAudPtr) + ")")
      openInputChannels(nEditAudPtr)
      debugMsg(sProcName, "calling setSyncPChanListForAud(" + getAudLabel(nEditAudPtr) + ")")
      setSyncPChanListForAud(nEditAudPtr)
    EndIf
    
    ; live input devices
    For d = 0 To grLicInfo\nMaxLiveDevPerAud
      
      SetGadgetText(WQI\lblInputDevNo[d], Str(d + 1))
      
      If Len(\sInputLogicalDev[d]) > 0
        bDevPresent = #True
      Else
        bDevPresent = #False
      EndIf
      
      If bDevPresent
        debugMsg(sProcName, "\sInputLogicalDev[" + d + "]=" + \sInputLogicalDev[d])
      EndIf
      nListIndex = indexForComboBoxRow(WQI\cboInputLogicalDev[d], \sInputLogicalDev[d], 0)
      SGS(WQI\cboInputLogicalDev[d], nListIndex)
      WQI_fcInputLogicalDev(d)
      WQI_fcInputOnOff(d)
      
      SLD_setMax(WQI\sldInputLevel[d], #SCS_MAXVOLUME_SLD)
      SLD_setLevel(WQI\sldInputLevel[d], \fInputLevel[d])
      SLD_setBaseLevel(WQI\sldInputLevel[d], #SCS_SLD_BASE_EQUALS_CURRENT)
      SGT(WQI\txtInputDBLevel[d], convertBVLevelToDBString(\fInputLevel[d], #False, #True))
      
    Next d
    
    ; live input group (only used for adding live inputs from a group - sInGrpName itself is not saved)
    SGS(WQI\cboInGrp, 0)
    
    ; fade times
    SGT(WQI\txtFadeInTime, timeToStringBWZT(\nFadeInTime))
    SGT(WQI\txtFadeOutTime, timeToStringBWZT(\nFadeOutTime))
    
    ; audio devices
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      
      SetGadgetText(WQI\lblDevNo[d], Str(d + 1))
      
      If \sLogicalDev[d]
        bDevPresent = #True
      Else
        bDevPresent = #False
      EndIf
      
      If bDevPresent
        debugMsg(sProcName, "\sLogicalDev[" + d + "]=" + \sLogicalDev[d])
      EndIf
      nListIndex = indexForComboBoxRow(WQI\cboLogicalDev[d], \sLogicalDev[d], 0)
      SGS(WQI\cboLogicalDev[d], nListIndex)
      WQI_fcLogicalDev(d)
      
      SLD_setMax(WQI\sldLevel[d], #SCS_MAXVOLUME_SLD)
      SLD_setLevel(WQI\sldLevel[d], \fBVLevel[d])
      SLD_setBaseLevel(WQI\sldLevel[d], #SCS_SLD_BASE_EQUALS_CURRENT)
      SLD_setMax(WQI\sldPan[d], #SCS_MAXPAN_SLD)   ; forces control to be formatted
      SLD_setValue(WQI\sldPan[d], panToSliderValue(\fPan[d]))
      SLD_setBaseValue(WQI\sldPan[d], #SCS_SLD_BASE_EQUALS_CURRENT)
      
      SGT(WQI\txtDBLevel[d], convertBVLevelToDBString(\fBVLevel[d], #False, #True))
      SGT(WQI\txtPan[d], panSingleToString(\fPan[d]))
      
      If bDevPresent
        If \nAudState < #SCS_CUE_FADING_IN
          If \nFadeInTime <= 0
            fEditFadeInLevel = \fBVLevel[d]
          Else
            fEditFadeInLevel = #SCS_MINVOLUME_SINGLE
          EndIf
        Else
          fEditFadeInLevel = \fBVLevel[d]
        EndIf
        
        If \nFileState = #SCS_FILESTATE_OPEN
          If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            setLevelsAny(nEditAudPtr, d, fEditFadeInLevel, \fPan[d])
          EndIf
        EndIf
        
        WQI_fcSldPan(d)
      EndIf
      
    Next d
    
    editSetDisplayButtonsI()
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQI_drawForm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  colorEditorComponent(#WQI)
  
EndProcedure

Procedure WQI_Form_Load()
  PROCNAMEC()
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQI()
  SUB_loadOrResizeHeaderFields("I", #True)
  
  debugMsg(sProcName, "calling WQI_populateForm()")
  WQI_populateForm()
  
  debugMsg(sProcName, "calling WQI_drawForm()")
  WQI_drawForm()

EndProcedure

Procedure WQI_fieldValidation()
  SetActiveGadget(-1)
EndProcedure

Procedure WQI_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQI_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQI_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQI
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQI)
        
        ; detail gadgets
      Case \txtDBLevel[0]
        ETVAL2(WQI_txtDBLevel_Validate(nArrayIndex))
        
      Case \txtFadeInTime
        ETVAL2(WQI_txtFadeInTime_Validate())
        
      Case \txtFadeOutTime
        ETVAL2(WQI_txtFadeOutTime_Validate())
        
      Case \txtInputDBLevel[0]
        ETVAL2(WQI_txtInputDBLevel_Validate(nArrayIndex))
        
      Case \txtPan[0]
        ETVAL2(WQI_txtPan_Validate(nArrayIndex))
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WQI_populateCboInGrps()
  PROCNAMEC()
  Protected n
  
  With WQI
    ClearGadgetItems(\cboInGrp)
    addGadgetItemWithData(\cboInGrp, #SCS_BLANK_CBO_ENTRY, -1)
    For n = 0 To grProd\nMaxInGrp
      If Len(grProd\aInGrps(n)\sInGrpName) > 0
        addGadgetItemWithData(\cboInGrp, grProd\aInGrps(n)\sInGrpName, n)
      EndIf
    Next n
  EndWith
  
EndProcedure

Procedure WQI_populateCboInputLogicalDevs()
  PROCNAMEC()
  Protected d, n
  
  debugMsg(sProcName, #SCS_START)

  With WQI
    For d = 0 To grLicInfo\nMaxLiveDevPerAud
      ClearGadgetItems(\cboInputLogicalDev[d])
      AddGadgetItem(\cboInputLogicalDev[d], -1, #SCS_BLANK_CBO_ENTRY)
      For n = 0 To grProd\nMaxLiveInputLogicalDev
        If Len(Trim(grProd\aLiveInputLogicalDevs(n)\sLogicalDev)) > 0
          AddGadgetItem(\cboInputLogicalDev[d], -1, grProd\aLiveInputLogicalDevs(n)\sLogicalDev)
        EndIf
      Next n
    Next d
  EndWith
  
EndProcedure

Procedure WQI_populateCboLogicalDevs()
  PROCNAMEC()
  Protected d, n
  
  debugMsg(sProcName, #SCS_START)
  
  With WQI
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      ClearGadgetItems(\cboLogicalDev[d])
      AddGadgetItem(\cboLogicalDev[d], -1, #SCS_BLANK_CBO_ENTRY)
      For n = 0 To grProd\nMaxAudioLogicalDev
        If Len(Trim(grProd\aAudioLogicalDevs(n)\sLogicalDev)) > 0
          AddGadgetItem(\cboLogicalDev[d], -1, grProd\aAudioLogicalDevs(n)\sLogicalDev)
        EndIf
      Next n
    Next d
  EndWith
  
EndProcedure

Procedure WQI_fcInputLogicalDev(Index)
  PROCNAMECA(nEditAudPtr)
  Protected bEnabled, bDevExists
  Protected nDevNo
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  nDevNo = Index
  With aAud(nEditAudPtr)
    If Len(\sInputLogicalDev[nDevNo]) > 0
      bEnabled = #True
      bDevExists = #True
    EndIf
    If bDevExists
      If \bInputOff[nDevNo]
        setOwnState(WQI\optOff[Index], #True)
        setOwnState(WQI\optOn[Index], #False)
      Else
        setOwnState(WQI\optOff[Index], #False)
        setOwnState(WQI\optOn[Index], #True)
      EndIf
    Else
      setOwnState(WQI\optOff[Index], #False)
      setOwnState(WQI\optOn[Index], #False)
    EndIf
    setOwnEnabled(WQI\optOn[Index], bEnabled)
    setOwnEnabled(WQI\optOff[Index], bEnabled)
    SLD_setEnabled(WQI\sldInputLevel[Index], bEnabled)
    setEnabled(WQI\txtInputDBLevel[Index], bEnabled)
    setTextBoxBackColor(WQI\txtInputDBLevel[Index])
  EndWith
EndProcedure

Procedure WQI_fcInputOnOff(Index)
  PROCNAMECA(nEditAudPtr)
  Protected bEnabled
  Protected nDevNo
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  nDevNo = Index
  With aAud(nEditAudPtr)
    If (\bInputOff[nDevNo] = #False) And (Len(\sInputLogicalDev[nDevNo]) > 0)
      bEnabled = #True
    EndIf
    SLD_setEnabled(WQI\sldInputLevel[Index], bEnabled)
    setEnabled(WQI\txtInputDBLevel[Index], bEnabled)
    setTextBoxBackColor(WQI\txtInputDBLevel[Index])
  EndWith
EndProcedure

Procedure WQI_fcLogicalDev(Index)
  PROCNAMECA(nEditAudPtr)
  Protected bEnabled, nDevIndex, nNrOfOutputChans
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WQI
    debugMsg(sProcName, "\sLogicalDev[" + Index + "]=" + aAud(nEditAudPtr)\sLogicalDev[Index])
    If GetGadgetState(\cboLogicalDev[Index]) <= 0
      bEnabled = #False
    ElseIf (aAud(nEditAudPtr)\bIgnoreDev[Index]) And (aAud(nEditAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nEditAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
      bEnabled = #False
    Else
      bEnabled = #True
      nDevIndex = devIndexForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, aAud(nEditAudPtr)\sLogicalDev[Index])
      If nDevIndex >= 0
        nNrOfOutputChans = grProd\aAudioLogicalDevs(nDevIndex)\nNrOfOutputChans
      EndIf
    EndIf
    ; debugMsg(sProcName, "nNrOfOutputChans=" + Str(nNrOfOutputChans))
    
    ; setEnabled(\cboTrim[Index], bEnabled)
    SLD_setEnabled(\sldLevel[Index], bEnabled)
    setEnabled(\txtDBLevel[Index], bEnabled)
    setTextBoxBackColor(\txtDBLevel[Index])
    If bEnabled = #False
      SetGadgetText(\txtDBLevel[Index], "")
    EndIf
    
    If nNrOfOutputChans = 2
      SLD_setEnabled(\sldPan[Index], bEnabled)
      If aAud(nEditAudPtr)\fPan[Index] = #SCS_PANCENTRE_SINGLE
        setEnabled(\btnCenter[Index], #False)
      Else
        setEnabled(\btnCenter[Index], bEnabled)
      EndIf
      setEnabled(\txtPan[Index], bEnabled)
    Else
      SLD_setEnabled(\sldPan[Index], #False)
      setEnabled(\btnCenter[Index], #False)
      setEnabled(\txtPan[Index], #False)
    EndIf
    setTextBoxBackColor(\txtPan[Index])
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQI_sldInputLevel_Common(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With aAud(nEditAudPtr)
    
    u = preChangeAudS(\sInputDBLevel[Index], GetGadgetText(WQI\lblInputDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fInputLevel[Index] = SLD_getLevel(WQI\sldInputLevel[Index])
    \sInputDBLevel[Index] = convertBVLevelToDBString(\fInputLevel[Index])
    \fCueInputVolNow[Index] = \fInputLevel[Index]
    debugMsg(sProcName, "\fCueInputVolNow[" + Index + "]=" + traceLevel(\fCueInputVolNow[Index]))
    \fCueInputTotalVolNow[Index] = \fInputLevel[Index]
    If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
      If \bIgnoreDev[Index]
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        If \bIgnoreDev[Index] = #False
          ; this device was ignored but now is not, so close and reopen Aud
          debugMsg(sProcName, "calling closeAud(" + getAudLabel(nEditAudPtr) + ")")
          closeAud(nEditAudPtr)
          debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
          setIgnoreDevInds(nEditAudPtr, #True)
          debugMsg(sProcName, "calling openInputChannels(" + getAudLabel(nEditAudPtr) + ")")
          openInputChannels(nEditAudPtr)
        EndIf
      EndIf
    EndIf
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        If gbUseSMS
          debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_SET_AUD_INPUT_DEV_LEVEL, " + getAudLabel(nEditAudPtr) + ", " + formatLevel(\fInputLevel[Index]) + ", " + Index + ")")
          samAddRequest(#SCS_SAM_SET_AUD_INPUT_DEV_LEVEL, nEditAudPtr, \fInputLevel[Index], Index)
        EndIf
      EndIf
    EndIf
    
    SetGadgetText(WQI\txtInputDBLevel[Index], convertBVLevelToDBString(\fCueInputVolNow[Index]))
    ; debugMsg(sProcName, "txtDBLevel(" + Index + ")=" + GetGadgetText(WQI\txtDBLevel[Index]) + ", sldLevel[Index].value=" + Str(SLD_get_value(WQI\sldLevel[Index]))+ ", .fCueVolNow(" + Index + ")=" + formatLevel(\fCueVolNow[Index]))
    
    postChangeAudS(u, \sInputDBLevel[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQI_sldLevel_Common(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  With aAud(nEditAudPtr)
    
    ; debugMsg(sProcName, ".sDBLevel(" + Index + ")=" + \sDBLevel[Index] + ", \nLevel(" + Index + ")=" + formatLevel(\fBVLevel[Index]))
    
    u = preChangeAudS(\sDBLevel[Index], GetGadgetText(WQI\lblDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fBVLevel[Index] = SLD_getLevel(WQI\sldLevel[Index])
    \sDBLevel[Index] = convertBVLevelToDBString(\fBVLevel[Index])
    \fSavedBVLevel[Index] = \fBVLevel[Index]
    \fCueVolNow[Index] = \fBVLevel[Index]
    \fCueAltVolNow[Index] = #SCS_MINVOLUME_SINGLE
    \fCueTotalVolNow[Index] = \fBVLevel[Index]
    If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
      If \bIgnoreDev[Index]
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        If \bIgnoreDev[Index] = #False
          ; this device was ignored but now is not, so close and reopen Aud
          debugMsg(sProcName, "calling closeAud(" + getAudLabel(nEditAudPtr) + ")")
          closeAud(nEditAudPtr)
          debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
          setIgnoreDevInds(nEditAudPtr, #True)
          debugMsg(sProcName, "calling openInputChannels(" + getAudLabel(nEditAudPtr) + ")")
          openInputChannels(nEditAudPtr)
        EndIf
      EndIf
    EndIf
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        If gbUseBASS
          setLevelsAny(nEditAudPtr, Index, \fBVLevel[Index], #SCS_NOPANCHANGE_SINGLE)
        Else ; SM-S
          debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, " + getAudLabel(nEditAudPtr) + ", " + formatLevel(\fBVLevel[Index]) + ", " + Index + ")")
          samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, nEditAudPtr, \fBVLevel[Index], Index)
        EndIf
        If SLD_getLevel(WQI\sldLevel[Index]) <> \fCueVolNow[Index]
          SLD_setLevel(WQI\sldLevel[Index], \fCueVolNow[Index])
        EndIf
        ;Call debugMsg(sProcName, "WQI.sldLevel(" & Index & ").value=" & WQI.sldLevel[Index].value)
      EndIf
    EndIf
    
    SetGadgetText(WQI\txtDBLevel[Index], convertBVLevelToDBString(\fCueVolNow[Index]))
    ; debugMsg(sProcName, "txtDBLevel(" + Index + ")=" + GetGadgetText(WQI\txtDBLevel[Index]) + ", sldLevel[Index].value=" + Str(SLD_get_value(WQI\sldLevel[Index]))+ ", .fCueVolNow(" + Index + ")=" + formatLevel(\fCueVolNow[Index]))
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
        If \nFadeInTime > 0
          If \fCueVolNow[Index] <> #SCS_MINVOLUME_SINGLE Or \fCueTotalVolNow[Index] <> #SCS_MINVOLUME_SINGLE
            If gbUseBASS
              setLevelsAny(nEditAudPtr, Index, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE)
            Else ; SM-S
              debugMsg(sProcName, "calling samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, " + getAudLabel(nEditAudPtr) + ", " + formatLevel(#SCS_MINVOLUME_SINGLE) + ", " + Index + ")")
              samAddRequest(#SCS_SAM_SET_AUD_DEV_LEVEL, nEditAudPtr, #SCS_MINVOLUME_SINGLE, Index)
            EndIf
            \fCueVolNow[Index] = #SCS_MINVOLUME_SINGLE
            \fCueTotalVolNow[Index] = #SCS_MINVOLUME_SINGLE
          EndIf
        EndIf
      EndIf
    EndIf
    
    postChangeAudS(u, \sDBLevel[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQI_fcSldPan(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    u = preChangeAudF(\fPan[Index], GetGadgetText(WQI\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    
    If gbInDisplaySub = #False
      ; debugMsg(sProcName, "SLD_get_value(WQI\sldPan[" + Index + "])=" + Str(SLD_get_value(WQI\sldPan[Index])))
      \fPan[Index] = panSliderValToSingle(SLD_getValue(WQI\sldPan[Index]))
      debugMsg(sProcName, "\fPan[" + Index + "]=" + StrF(\fPan[Index], 3))
      \fSavedPan[Index] = \fPan[Index]
      
      If \nFileState = #SCS_FILESTATE_OPEN
        If gbUseSMS
          samAddRequest(#SCS_SAM_SET_AUD_DEV_PAN, nEditAudPtr, \fPan[Index], Index)
        EndIf
      EndIf
    EndIf
    
    If \fPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQI\btnCenter[Index], #False)
    Else
      setEnabled(WQI\btnCenter[Index], #True)
    EndIf
    SetGadgetText(WQI\txtPan[Index], panSingleToString(\fPan[Index]))
    ; debugMsg(sProcName, "WQI\txtPan[" + Index + "]=" + GGT(WQI\txtPan[Index]))
    
    postChangeAudF(u, \fPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQI_fcTxtInputDBLevel(Index)
  PROCNAMECA(nEditAudPtr)
  Protected nSldValue
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        setLevelsForSMSInputDev(nEditAudPtr, Index)
      EndIf
    EndIf
    
    nSldValue = SLD_BVLevelToSliderValue(\fCueInputVolNow[Index])
    SLD_setValue(WQI\sldInputLevel[Index], nSldValue)
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
        setLevelsForSMSInputDev(nEditAudPtr, Index)
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQI_fcTxtDBLevel(Index)
  PROCNAMECA(nEditAudPtr)
;   Protected nSldValue
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    \fCueVolNow[Index] = \fBVLevel[Index]
    \fCueAltVolNow[Index] = #SCS_MINVOLUME_SINGLE
    \fCueTotalVolNow[Index] = \fBVLevel[Index]
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        setLevelsAny(nEditAudPtr, Index, \fBVLevel[Index], #SCS_NOPANCHANGE_SINGLE)
      EndIf
    EndIf
    
;     nSldValue = SLD_BVLevelToSliderValue(\fCueVolNow[Index])
;     SLD_setValue(WQI\sldLevel[Index], nSldValue)
    SLD_setLevel(WQI\sldLevel[Index], \fCueVolNow[Index])
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
        setLevelsAny(nEditAudPtr, Index, #SCS_MINVOLUME_SINGLE, #SCS_NOPANCHANGE_SINGLE)
        \fCueVolNow[Index] = #SCS_MINVOLUME_SINGLE
        \fCueTotalVolNow[Index] = #SCS_MINVOLUME_SINGLE
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQI_fcTxtPan(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    u = preChangeAudF(\fPan[Index], GetGadgetText(WQI\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fPan[Index] = panStringToSingle(GetGadgetText(WQI\txtPan[Index]))
    \fSavedPan[Index] = \fPan[Index]
    
    \fCuePanNow[Index] = \fPan[Index]
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
        setLevelsAny(nEditAudPtr, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
        \fCuePanNow[Index] = \fPan[Index]
      EndIf
    EndIf
    
    SLD_setValue(WQI\sldPan[Index], panToSliderValue(\fPan[Index]))
    
    If \nFileState = #SCS_FILESTATE_OPEN
      If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
        setLevelsAny(nEditAudPtr, Index, #SCS_NOVOLCHANGE_SINGLE, \fPan[Index])
        \fCuePanNow[Index] = \fPan[Index]
      EndIf
    EndIf
    
    If \fPan[Index] = #SCS_PANCENTRE_SINGLE
      setEnabled(WQI\btnCenter[Index], #False)
    Else
      setEnabled(WQI\btnCenter[Index], #True)
    EndIf
    
    postChangeAudF(u, \fPan[Index], -5, Index)
    
  EndWith
  
EndProcedure

Procedure WQI_populateForm()
  PROCNAMEC()
  Protected d
;   Protected nSldValue
  
  debugMsg(sProcName, #SCS_START)
  
  WQI_populateCboInGrps()
  WQI_populateCboInputLogicalDevs()
  WQI_populateCboLogicalDevs()
  
  debugMsg(sProcName, "nEditAudPtr=" + getAudLabel(nEditAudPtr) + ", gbInDisplaySub=" + strB(gbInDisplaySub))
  If gbInDisplaySub = #False And nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        debugMsg(sProcName, "\sInputLogicalDev[" + d + "]=" + \sInputLogicalDev[d] + ", \fInputLevel[" + d + "]=" + formatLevel(\fInputLevel[d]))
        If Len(\sInputLogicalDev[d]) > 0
          SetGadgetState(WQI\cboInputLogicalDev[d], indexForComboBoxRow(WQI\cboInputLogicalDev[d], \sInputLogicalDev[d]))
        Else
          SetGadgetState(WQI\cboInputLogicalDev[d], -1)
        EndIf
        SLD_setLevel(WQI\sldInputLevel[d], \fInputLevel[d])
        SLD_setBaseLevel(WQI\sldInputLevel[d], \fInputLevel[d])
        WQI_fcInputLogicalDev(d)
      Next d
      
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \sLogicalDev[d]
          SetGadgetState(WQI\cboLogicalDev[d], indexForComboBoxRow(WQI\cboLogicalDev[d], \sLogicalDev[d]))
        Else
          SetGadgetState(WQI\cboLogicalDev[d], -1)
        EndIf
        SLD_setLevel(WQI\sldLevel[d], \fBVLevel[d])
        SLD_setBaseLevel(WQI\sldLevel[d], \fBVLevel[d])
        SLD_setValue(WQI\sldPan[d], panToSliderValue(\fPan[d]))
        SLD_setBaseValue(WQI\sldPan[d], panToSliderValue(\fPan[d]))
        WQI_fcLogicalDev(d)
        WQI_fcSldPan(d)
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure WQI_cboInGrp_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u1, u2, u3
  Protected sUndoDescr.s
  Protected nInGrpIndex, d, d2
  Protected sLogicalDev.s
  Protected bWantThis, bAdded, bFound
  Protected nCounter
  Protected nInputLogicalDevPtr
  Protected nListIndex
  
  nInGrpIndex = getCurrentItemData(WQI\cboInGrp)
  If nInGrpIndex >= 0
    
    If nEditAudPtr >= 0
      With aAud(nEditAudPtr)
        sUndoDescr = GGT(WQI\lblInGrp)
        u1 = preChangeCueL(nCounter, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
        u2 = preChangeSubL(nCounter, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
        u3 = preChangeAudL(nCounter, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
        For d = 0 To grProd\aInGrps(nInGrpIndex)\nMaxInGrpItem
          If grProd\aInGrps(nInGrpIndex)\aInGrpItem(d)\nInGrpItemDevType = #SCS_DEVTYPE_LIVE_INPUT
            sLogicalDev = grProd\aInGrps(nInGrpIndex)\aInGrpItem(d)\sInGrpItemLiveInput
            If Len(sLogicalDev) > 0
              ; check if this live input device is already included
              bWantThis = #True
              For d2 = 0 To grLicInfo\nMaxLiveDevPerAud
                If \sInputLogicalDev[d2] = sLogicalDev
                  bWantThis = #False
                  Break
                EndIf
              Next d2
              If bWantThis
                bAdded = #False
                For d2 = 0 To grLicInfo\nMaxLiveDevPerAud
                  If Len(\sInputLogicalDev[d2]) = 0
                    \sInputLogicalDev[d2] = sLogicalDev
                    bAdded = #True
                    nCounter + 1
                    
                    nListIndex = indexForComboBoxRow(WQI\cboInputLogicalDev[d2], sLogicalDev, 0)
                    SGS(WQI\cboInputLogicalDev[d2], nListIndex)
                    
                    nInputLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(sLogicalDev, #SCS_DEVGRP_LIVE_INPUT)
                    If nInputLogicalDevPtr >= 0
                      bFound = #True
                      \sInputDBLevel[d2] = grProd\aLiveInputLogicalDevs(nInputLogicalDevPtr)\sDfltInputDBLevel
                      \fInputLevel[d2] = convertDBStringToBVLevel(\sInputDBLevel[d2])
                      debugMsg(sProcName, "\sInputDBLevel[" + d2 + "]=" + \sInputDBLevel[d2] + ", \fInputLevel[" + d2 + "]=" + formatLevel(\fInputLevel[d2]))
                    Else
                      ; shouldn't get here
                      bFound = #False
                      \sInputDBLevel[d2] = grLevels\sDefaultDBLevel
                      \fInputLevel[d2] = convertDBStringToBVLevel(\sInputDBLevel[d2])
                    EndIf
                    
                    If SLD_getLevel(WQI\sldInputLevel[d2]) <> \fInputLevel[d2]
                      SLD_setLevel(WQI\sldInputLevel[d2], \fInputLevel[d2])
                      SLD_setBaseLevel(WQI\sldInputLevel[d2], #SCS_SLD_BASE_EQUALS_CURRENT)
                    EndIf
                    If bFound
                      SGT(WQI\txtInputDBLevel[d2], \sInputDBLevel[d2])
                    Else
                      SGT(WQI\txtInputDBLevel[d2], "")
                    EndIf
                    
                    WQI_fcInputLogicalDev(d2)
                    
                    Break
                  EndIf
                Next d2
              EndIf
            EndIf
          EndIf
        Next d
        
        If nCounter > 0
          setDefaultSubDescr()
          setDefaultCueDescr()
          ; re-open input channels to use new devices
          debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
          setIgnoreDevInds(nEditAudPtr, #True)
          openInputChannels(nEditAudPtr)
        EndIf
        
        postChangeAudL(u3, nCounter, -5)
        postChangeSubL(u2, nCounter, -5)
        postChangeCueL(u1, nCounter, -5)
        
      EndWith
    EndIf
    
    SGS(WQI\cboInGrp, 0)
    SAG(-1)
    
  EndIf
  
EndProcedure

Procedure WQI_cboInputLogicalDev_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u1, u2, u3
  Protected sUndoDescr.s
  Protected nDevNo
  Protected d
  Protected nInputLogicalDevPtr
  Protected sInputLogicalDevOld.s, sInputLogicalDevNew.s
  Protected sSubDescrOld.s, sSubDescrNew.s
  Protected sCueDescrOld.s, sCueDescrNew.s
  Protected bValidationFailed
  Protected sErrorMsg.s
  Protected bDevPresent, bFound
  Protected nListIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nDevNo = Index
  With aAud(nEditAudPtr)
    
    sInputLogicalDevNew = Trim(GGT(WQI\cboInputLogicalDev[Index]))
    sInputLogicalDevOld = \sInputLogicalDev[nDevNo]
    If sInputLogicalDevNew = sInputLogicalDevOld
      ; no change - nothing to validate
      ProcedureReturn
    EndIf
    
    ; check that device is not duplicated
    If Len(sInputLogicalDevNew) > 0
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        If d <> nDevNo
          If \sInputLogicalDev[d] = sInputLogicalDevNew
            sErrorMsg = LangPars("WQI", "InputAlreadySelected", sInputLogicalDevNew)
            bValidationFailed = #True
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    If bValidationFailed
      debugMsg(sProcName, "sErrorMsg=" + sErrorMsg)
      scsMessageRequester(grText\sTextValErr, sErrorMsg, #PB_MessageRequester_Error)
      ; reinstate previous value
      nListIndex = indexForComboBoxRow(WQI\cboInputLogicalDev[Index], sInputLogicalDevOld, 0)
      SGS(WQI\cboInputLogicalDev[Index], nListIndex)
      ProcedureReturn
    EndIf
    
    ; validation passed - new code
    sUndoDescr = GGT(WQI\lblInputDevice)
    sCueDescrOld = aCue(\nCueIndex)\sCueDescr
    sSubDescrOld = aSub(\nSubIndex)\sSubDescr
    u1 = preChangeCueS(sInputLogicalDevOld + "." + sCueDescrOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
    u2 = preChangeSubS(sInputLogicalDevOld + "." + sSubDescrOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
    u3 = preChangeAudS(sInputLogicalDevOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
    If Len(sInputLogicalDevNew) > 0
      bDevPresent = #True
    EndIf
    \sInputLogicalDev[nDevNo] = sInputLogicalDevNew
    nInputLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(sInputLogicalDevNew, #SCS_DEVGRP_LIVE_INPUT)
    If nInputLogicalDevPtr >= 0
      bFound = #True
      \sInputDBLevel[Index] = grProd\aLiveInputLogicalDevs(nInputLogicalDevPtr)\sDfltInputDBLevel
      \fInputLevel[Index] = convertDBStringToBVLevel(\sInputDBLevel[Index])
      debugMsg(sProcName, "\sInputDBLevel[" + Index + "]=" + \sInputDBLevel[Index] + ", \fInputLevel[" + Index + "]=" + formatLevel(\fInputLevel[Index]))
      ; re-open input channels to use new device
      debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
      setIgnoreDevInds(nEditAudPtr, #True)
      openInputChannels(nEditAudPtr)
    Else ; new device is blank
      \sInputDBLevel[Index] = grLevels\sDefaultDBLevel
      \fInputLevel[Index] = convertDBStringToBVLevel(\sInputDBLevel[Index])
    EndIf
    
    If SLD_getLevel(WQI\sldInputLevel[Index]) <> \fInputLevel[Index]
      SLD_setLevel(WQI\sldInputLevel[Index], \fInputLevel[Index])
      SLD_setBaseLevel(WQI\sldInputLevel[Index], #SCS_SLD_BASE_EQUALS_CURRENT)
    EndIf
    If bFound
      SGT(WQI\txtInputDBLevel[Index], \sInputDBLevel[Index])
    Else
      SGT(WQI\txtInputDBLevel[Index], "")
    EndIf
    
    WQI_fcInputLogicalDev(Index)
    setDefaultSubDescr()
    setDefaultCueDescr()
    
    sCueDescrNew = aCue(\nCueIndex)\sCueDescr
    sSubDescrNew = aSub(\nSubIndex)\sSubDescr
    postChangeAudS(u3, sInputLogicalDevNew, -5)
    postChangeSubS(u2, sInputLogicalDevNew + "." + sSubDescrNew, -5)
    postChangeCueS(u1, sInputLogicalDevNew + "." + sCueDescrNew, -5)
    
  EndWith
  loadGridRow(nEditCuePtr)
  PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQI_cboLogicalDev_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected d, nNewBassDevice
  Protected bFound, nListIndex
  Protected sOldLogicalDev.s, sNewLogicalDev.s
  Protected nNrOfOutputChans
  Protected u, sAfterValue.s
  Protected nDefaultDevPtr
  Protected sMyTracks.s
  Protected bResetPanBase
  Protected bDevPresent
  
  debugMsg(sProcName, #SCS_START)
  
  rWQI\bInLogicalDevClick = #True
  
  With aAud(nEditAudPtr)
    
    bFound = #False
    sOldLogicalDev = \sLogicalDev[Index]
    sNewLogicalDev = ""
    nNewBassDevice = -1
    For d = 0 To grProd\nMaxAudioLogicalDev
      If Len(grProd\aAudioLogicalDevs(d)\sLogicalDev) > 0
        If grProd\aAudioLogicalDevs(d)\sLogicalDev = GGT(WQI\cboLogicalDev[Index])
          bFound = #True
          sNewLogicalDev = grProd\aAudioLogicalDevs(d)\sLogicalDev
          nNewBassDevice = grProd\aAudioLogicalDevs(d)\nBassDevice
          nNrOfOutputChans = grProd\aAudioLogicalDevs(d)\nNrOfOutputChans
          Break
        EndIf
      EndIf
    Next d
    
    debugMsg(sProcName, "sNewLogicalDev=" + sNewLogicalDev + ", \sLogicalDev[" + Index + "]=" + \sLogicalDev[Index] + ", bFound=" + strB(bFound))
    If Len(sNewLogicalDev) > 0
      bDevPresent = #True
    EndIf
    If (sNewLogicalDev <> \sLogicalDev[Index]) Or (gbAdding)
      u = preChangeAudL(#True, "Audio Device", -5, #SCS_UNDO_ACTION_CHANGE, Index, #SCS_UNDO_FLAG_OPEN_FILE)
      ; close current channel if open
      debugMsg(sProcName, "calling freeOneAudStream for nEditAudPtr=" + nEditAudPtr)
      debugMsg3(sProcName, "calling freeOneAudStream(" + nEditAudPtr + ", " + Index + ")")
      freeOneAudStream(nEditAudPtr, Index)
      
      \sLogicalDev[Index] = sNewLogicalDev
      sAfterValue = \sLogicalDev[Index]
      \nBassDevice[Index] = nNewBassDevice
      
      If bFound
        ; debugMsg(sProcName, "sOldLogicalDev=" + sOldLogicalDev + ", \fBVLevel[" + Index + "]=" + StrF(\fBVLevel[Index],4) + ", #SCS_MINVOLUME_SINGLE=" + StrF(#SCS_MINVOLUME_SINGLE,4) + ", gbAdding=" + strB(gbAdding))
        If (Len(sOldLogicalDev) = 0 And \fBVLevel[Index] = #SCS_MINVOLUME_SINGLE) Or (gbAdding)
          nDefaultDevPtr = getProdLogicalDevPtrForLogicalDev(sNewLogicalDev)
          If gbPasting = #False
            If nDefaultDevPtr >= 0
              \sDBLevel[Index] = grProd\aAudioLogicalDevs(nDefaultDevPtr)\sDfltDBLevel
              \fPan[Index] = grProd\aAudioLogicalDevs(nDefaultDevPtr)\fDfltPan
            ElseIf Index = 0
              \sDBLevel[Index] = grLevels\sDefaultDBLevel
              \fPan[Index] = #SCS_PANCENTRE_SINGLE
            Else
              If Len(\sLogicalDev[Index-1]) > 0
                \sDBLevel[Index] = \sDBLevel[Index-1]
                \fBVLevel[Index] = \fBVLevel[Index-1]
                \fTrimFactor[Index] = \fTrimFactor[Index-1]
              Else
                \sDBLevel[Index] = grLevels\sDefaultDBLevel
                \fPan[Index] = #SCS_PANCENTRE_SINGLE
              EndIf
            EndIf
          EndIf
          \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
          debugMsg(sProcName, "\sDBLevel[" + Index + "]=" + \sDBLevel[Index] + ", \fBVLevel[" + Index + "]=" + formatLevel(\fBVLevel[Index]))
          \fSavedBVLevel[Index] = \fBVLevel[Index]
          \fSavedPan[Index] = \fPan[Index]
        EndIf
        ; re-open input channels to use new device
        debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
        setIgnoreDevInds(nEditAudPtr, #True)
        openInputChannels(nEditAudPtr)
        
      Else ; new device is blank
        \sDBLevel[Index] = grLevels\sDefaultDBLevel
        \fPan[Index] = #SCS_PANCENTRE_SINGLE
        \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
        \fSavedBVLevel[Index] = \fBVLevel[Index]
        \fSavedPan[Index] = \fPan[Index]
      EndIf
      
      debugMsg(sProcName, "nNrOfOutputChans=" + Str(nNrOfOutputChans))
      If nNrOfOutputChans <> 2
        If \fPan[Index] <> #SCS_PANCENTRE_SINGLE
          \fPan[Index] = #SCS_PANCENTRE_SINGLE
          bResetPanBase = #True
        EndIf
      EndIf
      
      If SLD_getLevel(WQI\sldLevel[Index]) <> \fBVLevel[Index]
        SLD_setLevel(WQI\sldLevel[Index], \fBVLevel[Index])
        SLD_setBaseLevel(WQI\sldLevel[Index], #SCS_SLD_BASE_EQUALS_CURRENT)
      EndIf
      If bFound
        SGT(WQI\txtDBLevel[Index], \sDBLevel[Index])
      Else
        SGT(WQI\txtDBLevel[Index], "")
      EndIf
      
      If SLD_getValue(WQI\sldPan[Index]) <> panToSliderValue(\fPan[Index])
        SLD_setValue(WQI\sldPan[Index], panToSliderValue(\fPan[Index]))
        SLD_setBaseValue(WQI\sldPan[Index], #SCS_SLD_BASE_EQUALS_CURRENT)
        WQI_fcSldPan(Index)
      EndIf
      If bFound
        SGT(WQI\txtPan[Index], panSingleToString(\fPan[Index]))
      Else
        SGT(WQI\txtPan[Index], "")
      EndIf
      
      If bResetPanBase
        SLD_setBaseValue(WQI\sldPan[Index], panToSliderValue(\fPan[Index]))
      EndIf
      
      If nNrOfOutputChans = 2
        SLD_setEnabled(WQI\sldPan[Index], #True)
      Else
        SLD_setEnabled(WQI\sldPan[Index], #False)
      EndIf
      
    EndIf
    
    setFirstAndLastDev(nEditAudPtr)
    debugMsg(sProcName, "calling WQI_fcLogicalDev(" + Index + ")")
    WQI_fcLogicalDev(Index)
    
    editSetDisplayButtonsI()
    gbCallEditUpdateDisplay = #True
    
    postChangeAudL(u, #False, -5, Index)
    
  EndWith
  
  rWQI\bInLogicalDevClick = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQI_txtPan_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If validatePanTextField(GGT(WQI\txtPan[Index]), "Pan") = #False
    ProcedureReturn #False
  EndIf
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(\fPan[Index], GGT(WQI\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \fPan[Index] = panStringToSingle(GGT(WQI\txtPan[Index]))
    WQI_fcTxtPan(Index)
    postChangeAudL(u, \fPan[Index], -5, Index)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WQI_txtInputDBLevel_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If validateDbField(GGT(WQI\txtInputDBLevel[Index]), GGT(WQI\lblInputLevel)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WQI\txtInputDBLevel[Index]) <> gsTmpString
    SGT(WQI\txtInputDBLevel[Index], gsTmpString)
  EndIf
  
  With aAud(nEditAudPtr)
    u = preChangeAudS(\sInputDBLevel[Index], GGT(WQI\lblInputDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \sInputDBLevel[Index] = Trim(GGT(WQI\txtInputDBLevel[Index]))
    \fInputLevel[Index] = convertDBStringToBVLevel(\sInputDBLevel[Index])
    WQI_fcTxtInputDBLevel(Index)
    postChangeAudS(u, \sInputDBLevel[Index], -5, Index)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WQI_txtDBLevel_Validate(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If validateDbField(GGT(WQI\txtDBLevel[Index]), GGT(WQI\lblLevel)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WQI\txtDBLevel[Index]) <> gsTmpString
    SGT(WQI\txtDBLevel[Index], gsTmpString)
  EndIf
  
  With aAud(nEditAudPtr)
    u = preChangeAudS(\sDBLevel[Index], GGT(WQI\lblDb), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    \sDBLevel[Index] = Trim(GGT(WQI\txtDBLevel[Index]))
    \fBVLevel[Index] = convertDBStringToBVLevel(\sDBLevel[Index])
    \fSavedBVLevel[Index] = \fBVLevel[Index]
    WQI_fcTxtDBLevel(Index)
    postChangeAudS(u, \sDBLevel[Index], -5, Index)
  EndWith
  ProcedureReturn #True
EndProcedure

Procedure WQI_txtFadeInTime_Validate(pCallingModule=#WQI, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nTextGadget, nLabelGadget
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtFadeValue
    nLabelGadget = WEM\lblFadeField
  Else
    nTextGadget = WQI\txtFadeInTime
    nLabelGadget = WQI\lblFadeInTime
  EndIf
  
  If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #False, #False) = #False
    rWQI\bInValidate = #False
    ProcedureReturn #False
  ElseIf GGT(nTextGadget) <> gsTmpString
    SGT(nTextGadget, gsTmpString)
  EndIf
  
  If bReturnBeforeUpdate
    ProcedureReturn #True
  EndIf
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(\nFadeInTime, GGT(nLabelGadget))
    \nFadeInTime = stringToTime(GGT(nTextGadget))
    \nCurrFadeInTime = \nFadeInTime
    postChangeAudL(u, \nFadeInTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQI_txtFadeOutTime_Validate(pCallingModule=#WQI, bReturnBeforeUpdate=#False)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nTextGadget, nLabelGadget
  
  debugMsg(sProcName, #SCS_START + ", pCallingModule=" + Str(pCallingModule))
  
  If pCallingModule = #WEM
    nTextGadget = WEM\txtFadeValue
    nLabelGadget = WEM\lblFadeField
  Else
    nTextGadget = WQI\txtFadeOutTime
    nLabelGadget = WQI\lblFadeOutTime
  EndIf
  
  If validateTimeFieldT(GGT(nTextGadget), GGT(nLabelGadget), #False, #False) = #False
    rWQI\bInValidate = #False
    ProcedureReturn #False
  ElseIf GGT(nTextGadget) <> gsTmpString
    SGT(nTextGadget, gsTmpString)
  EndIf
  
  If bReturnBeforeUpdate
    ProcedureReturn #True
  EndIf
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(\nFadeOutTime, GGT(nLabelGadget))
    \nFadeOutTime = stringToTime(GGT(nTextGadget))
    \nCurrFadeOutTime = \nFadeOutTime
    postChangeAudL(u, \nFadeOutTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQI_btnCenter_Click(Index)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With aAud(nEditAudPtr)
    u = preChangeAudL(\fPan[Index], GGT(WQI\lblPan), -5, #SCS_UNDO_ACTION_CHANGE, Index)
    SLD_setValue(WQI\sldPan[Index], #SCS_PANCENTRE_SLD)
    \fPan[Index] = #SCS_PANCENTRE_SINGLE
    WQI_fcSldPan(Index)
    postChangeAudL(u, \fPan[Index], -5, Index)
  EndWith
  
EndProcedure

Procedure WQI_btnEditFadeOut_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel)
  fadeOutOneAud(nEditAudPtr)
  editSetDisplayButtonsI()
  gbCallEditUpdateDisplay = #True
  SAG(-1)
EndProcedure

Procedure WQI_btnEditPause_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, aAud(nEditAudPtr)\sAudLabel)
  If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
    resumeAud(nEditAudPtr)
  Else
    debugMsg(sProcName, "calling pauseAud(" + nEditAudPtr + ")")
    pauseAud(nEditAudPtr)
  EndIf
  debugMsg(sProcName, "calling editSetDisplayButtonsI()")
  editSetDisplayButtonsI()
  gbCallEditUpdateDisplay = #True
  debugMsg(sProcName, #SCS_END)
  SAG(-1)
EndProcedure

Procedure WQI_btnEditPlay_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, "\nAudState=" + decodeCueState(aAud(nEditAudPtr)\nAudState))
  If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
    debugMsg(sProcName, "calling resumeAud(" + nEditAudPtr + ")")
    resumeAud(nEditAudPtr)
  ElseIf aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN Or aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT
    debugMsg(sProcName, "calling editPlaySub")
    editPlaySub()
  Else
    debugMsg(sProcName, "calling restartAud(" + nEditAudPtr + ")")
    restartAud(nEditAudPtr)
  EndIf
  editSetDisplayButtonsI()
  gbCallEditUpdateDisplay = #True
  gbEditUpdateGraphMarkers = #True
  SAG(-1)
EndProcedure

Procedure WQI_btnEditStop_Click()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()
  stopAud(nEditAudPtr, #True)
  SAG(-1)
  
  ; now pause until stop slide has completed
  If gnStopFadeTime > 0
    Delay(gnStopFadeTime)
  EndIf
  
  WQI_resetSliders()  ; enables level and pan sliders for ignored devices (provided they have a logical device)
  editSetDisplayButtonsI()
  gbCallEditUpdateDisplay = #True
  gbEditUpdateGraphMarkers = #True
EndProcedure

Procedure WQI_resetSliders()
  PROCNAMECA(nEditAudPtr)
  Protected d
  Protected bIgnoreDevToBeCleared
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      For d = \nFirstDev To \nLastDev
        If \sLogicalDev[d]
          If \bIgnoreDev
            bIgnoreDevToBeCleared = #True
            Break
          EndIf
        EndIf
      Next d
      If bIgnoreDevToBeCleared
        setIgnoreDevInds(nEditAudPtr, #True)  ; also calls setFirstAndLastDev()
      EndIf
      For d = \nFirstDev To \nLastDev
        WQI_fcLogicalDev(d)
      Next d
    EndWith
  EndIf
EndProcedure

Procedure WQI_WEM_Button_Click(nGadgetNo)
  PROCNAMECA(nEditAudPtr)
  Protected nField
  
  debugMsg(sProcName, #SCS_START + ", nGadgetNo=" + GadgetNoAndName(nGadgetNo))
  
  With WQI
    Select nGadgetNo
      Case \btnFadeInTime
        nField = #SCS_WEM_I_FADEINTIME
      Case \btnFadeOutTime
        nField = #SCS_WEM_I_FADEOUTTIME
    EndSelect
    
    debugMsg(sProcName, "calling WEM_Form_Show()")
    WEM_Form_Show(#True, #WED, #WQI, nField)
    ; must return now - unlike VB, PB doesn't block processing while the modal form is displayed
    ProcedureReturn
    
  EndWith
  
EndProcedure

Procedure WQI_EventHandler()
  PROCNAMEC()
  Protected n
  Protected bFound
  
  With WQI
    
    If gnEventSliderNo > 0
      
      ; debugMsg(sProcName, "gnSliderEvent=" + Str(gnSliderEvent) + ", gnEventSliderNo=" + Str(gnEventSliderNo))
      ; debugMsg(sProcName, "gnTrackingSliderNo=" + Str(gnTrackingSliderNo))
      
      For n = 0 To grLicInfo\nMaxLiveDevPerAud
        If gnEventSliderNo = \sldInputLevel[n]
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQI_sldInputLevel_Common(n)
          EndSelect
          Break
        EndIf
      Next n
      
      If bFound = #False
        
        For n = 0 To grLicInfo\nMaxAudDevPerAud
          If gnEventSliderNo = \sldLevel[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQI_sldLevel_Common(n)
            EndSelect
            Break
            
          ElseIf gnEventSliderNo = \sldPan[n]
            bFound = #True
            Select gnSliderEvent
              Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
                WQI_fcSldPan(n)
            EndSelect
            Break
          EndIf
        Next n
        
      EndIf
      
    EndIf
    
    If bFound
      ProcedureReturn
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        If gnEventButtonId <> 0
          
          Select gnEventButtonId
              
            Case #SCS_STANDARD_BTN_FADEOUT
              WQI_btnEditFadeOut_Click()
              
            Case #SCS_STANDARD_BTN_PAUSE
              WQI_btnEditPause_Click()
              
            Case #SCS_STANDARD_BTN_PLAY
              WQI_btnEditPlay_Click()
              
            Case #SCS_STANDARD_BTN_STOP
              WQI_btnEditStop_Click()
              
          EndSelect
          
        Else
          
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQI)
              
              ; detail gadgets in alphabetical order
              
            Case \btnCenter[0]    ; btnCenter
              BTNCLICK(WQI_btnCenter_Click(gnEventGadgetArrayIndex))
              
            Case \btnFadeInTime, \btnFadeOutTime  ; btnFadeInTime, btnFadeOutTime
              BTNCLICK(WQI_WEM_Button_Click(gnEventGadgetNoForEvHdlr))
              
            Case \cboInGrp    ; cboInGrp
              CBOCHG(WQI_cboInGrp_Click())
              
            Case \cboInputLogicalDev[0] ; cboInputLogicalDev
              CBOCHG(WQI_cboInputLogicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \cboLogicalDev[0] ; cboLogicalDev
              CBOCHG(WQI_cboLogicalDev_Click(gnEventGadgetArrayIndex))
              
            Case \optOff[0] ; optOff
              WQI_optOnOff_Click(gnEventGadgetArrayIndex, #True)
              
            Case \optOn[0] ; optOn
              WQI_optOnOff_Click(gnEventGadgetArrayIndex, #False)
              
            Case \txtDBLevel[0]  ; txtDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQI_txtDBLevel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtFadeInTime  ; txtFadeInTime
              ; debugMsg(sProcName, "(\txtFadeInTime) gnEventGadgetNo=G" + Str(gnEventGadgetNo) + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQI_txtFadeInTime_Validate())
              EndSelect
              
            Case \txtFadeOutTime  ; txtFadeOutTime
              ; debugMsg(sProcName, "(\txtFadeOutTime) gnEventGadgetNo=G" + Str(gnEventGadgetNo) + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQI_txtFadeOutTime_Validate())
              EndSelect
              
            Case \txtInputDBLevel[0]  ; txtInputDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQI_txtInputDBLevel_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Case \txtPan[0]  ; txtPan
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQI_txtPan_Validate(gnEventGadgetArrayIndex))
              EndSelect
              
            Default
              debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
          EndSelect
          
        EndIf
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQI_optOnOff_Click(nIndex, bInputOff)
  PROCNAMECA(nEditAudPtr)
  Protected u1, u2, u3
  Protected sUndoDescr.s
  Protected nDevNo
  Protected bInputOffOld, bInputOffNew
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)

  If nEditAudPtr < 0
    ; shouldn't happen
    ProcedureReturn
  EndIf
  
  nDevNo = nIndex
  With WQI
    bInputOffOld = aAud(nEditAudPtr)\bInputOff[nDevNo]
    If bInputOff
      ; setOwnState(\optOn[nIndex], 0)
      bInputOffNew = #True
    Else
      ; setOwnState(\optOff[nIndex], 0)
      bInputOffNew = #False
    EndIf
    If bInputOffOld <> bInputOffNew
      sUndoDescr = GGT(\lblOn) + "/" + GGT(\lblOff) + " " + aAud(nEditAudPtr)\sInputLogicalDev[nDevNo]
      u1 = preChangeCueL(bInputOffOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
      u2 = preChangeSubL(bInputOffOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
      u3 = preChangeAudL(bInputOffOld, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
      aAud(nEditAudPtr)\bInputOff[nDevNo] = bInputOffNew
      
      setDefaultSubDescr()
      setDefaultCueDescr()
      
      postChangeAudL(u3, bInputOffNew, -5)
      postChangeSubL(u2, bInputOffNew, -5)
      postChangeCueL(u1, bInputOffNew, -5)
      
      WQI_fcInputOnOff(nIndex)
      
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr)
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQI_adjustForSplitterSize()
  PROCNAMEC()
  Protected nTop, nHeight, nInnerHeight, nMinInnerHeight
  
  With WQI
    If IsGadget(\scaLiveInput)
      ; \scaLiveInput automatically resized by splitter gadget, but need to adjust inner height
      nInnerHeight = GadgetHeight(\scaLiveInput) - gl3DBorderHeight
      nMinInnerHeight = 448
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      SetGadgetAttribute(\scaLiveInput, #PB_ScrollArea_InnerHeight, nInnerHeight)
      
      ; adjust the height of \cntSubDetailI
      nHeight = nInnerHeight - GadgetY(\cntSubDetailI)
      ResizeGadget(\cntSubDetailI, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
      
    EndIf
  EndWith
EndProcedure

; EOF