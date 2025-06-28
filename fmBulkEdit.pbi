; File: fmBulkEdit.pbi

EnableExplicit

Procedure WBE_WinCallbackProc(hWnd,uMsg,wParam,lParam)
  PROCNAMEC()
  Protected Result, Col, nBoldCol
  Protected *pnmh.NMHDR,*LVCDHeader.NMLVCUSTOMDRAW
  
  result = #PB_ProcessPureBasicEvents
  Select uMsg
    Case #WM_NOTIFY
      If IsGadget(WBE\grdBulkEdit)
        If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
          CompilerIf #c_include_peak
            Select grEditMem\nLastNormToApply
              Case #SCS_NORMALIZE_LUFS
                nBoldCol = 6
              Case #SCS_NORMALIZE_PEAK
                nBoldCol = 7
              Case #SCS_NORMALIZE_TRUE_PEAK
                nBoldCol = 8
            EndSelect
          CompilerElse
            Select grEditMem\nLastNormToApply
              Case #SCS_NORMALIZE_LUFS
                nBoldCol = 6
              Case #SCS_NORMALIZE_TRUE_PEAK
                nBoldCol = 7
            EndSelect
          CompilerEndIf
        Else
          nBoldCol = 99
        EndIf
        If nBoldCol > 0
          *pnmh.NMHDR = lParam
          *LVCDHeader.NMLVCUSTOMDRAW = lParam
          If *LVCDHeader\nmcd\hdr\hwndFrom = GadgetID(WBE\grdBulkEdit)
            Select *LVCDHeader\nmcd\dwDrawStage
              Case #CDDS_ITEMPREPAINT | #CDDS_SUBITEM
                Col = *LVCDHeader\iSubItem
                Select Col
                  Case nBoldCol
                    SelectObject_(*LVCDHeader\nmcd\hdc, FontID(#SCS_FONT_GEN_BOLD))
                  Case 6, 7, 8, 99 ; nb obviously excludes nBoldCol which has already been processed
                    SelectObject_(*LVCDHeader\nmcd\hdc, FontID(#SCS_FONT_GEN_NORMAL))
                EndSelect
            EndSelect
          EndIf
        EndIf
      EndIf
  EndSelect
  ProcedureReturn Result
EndProcedure

Procedure WBE_sizeCallBack()
  PROCNAMEC()
  If IsGadget(WBE\grdBulkEdit)
    ResizeGadget(WBE\grdBulkEdit, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
  EndIf
EndProcedure

Procedure WBE_grdBulkEdit_CallBack(hWnd, uMsg, WParam, LParam)
  PROCNAMEC()
  Protected *NMCUSTOMDRAW.NMCUSTOMDRAW
  Protected *NMHDR.NMHDR
  Protected Result
  Protected nBoldCol
  
  Result = CallWindowProc_(grWBE\nOldCallBack, hWnd, uMsg, wParam, lParam)
  
  Select  uMsg
    Case #WM_NOTIFY
      *NMHDR = lParam
      
      If *NMHDR\code = #NM_CUSTOMDRAW
        *NMCUSTOMDRAW = lParam
        
        Select *NMCUSTOMDRAW\dwDrawStage
          Case #CDDS_PREPAINT
            Result = #CDRF_NOTIFYITEMDRAW
          Case #CDDS_ITEMPREPAINT
            If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
              CompilerIf #c_include_peak
                Select grEditMem\nLastNormToApply
                  Case #SCS_NORMALIZE_LUFS
                    nBoldCol = 6
                  Case #SCS_NORMALIZE_PEAK
                    nBoldCol = 7
                  Case #SCS_NORMALIZE_TRUE_PEAK
                    nBoldCol = 8
                EndSelect
              CompilerElse
                Select grEditMem\nLastNormToApply
                  Case #SCS_NORMALIZE_LUFS
                    nBoldCol = 6
                  Case #SCS_NORMALIZE_TRUE_PEAK
                    nBoldCol = 7
                EndSelect
              CompilerEndIf
            Else
              nBoldCol = 99
            EndIf
            If *NMCUSTOMDRAW\dwItemSpec >= 6
              If *NMCUSTOMDRAW\dwItemSpec = nBoldCol
                SelectObject_(*NMCUSTOMDRAW\hdc, FontID(#SCS_FONT_GEN_BOLD))
              Else
                SelectObject_(*NMCUSTOMDRAW\hdc, FontID(#SCS_FONT_GEN_NORMAL))
              EndIf
            EndIf
        EndSelect
      EndIf
  EndSelect
  
  ProcedureReturn Result
EndProcedure

Procedure WBE_btnOK_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If WBE_applyBulkEdit() = #False
    SAW(#WBE)
    ProcedureReturn
  EndIf
  WBE_Form_Unload()
  
EndProcedure

Procedure WBE_btnApply_Click()
  PROCNAMEC()
  Protected nFirstRowVisible, nLastRowVisible
  
  debugMsg(sProcName, #SCS_START)
  
  getGridRowInfo(WBE\grdBulkEdit)
  With grGridRowInfo
    nFirstRowVisible = \nFirstRowVisible
    nLastRowVisible = \nLastRowVisible
    debugMsg(sProcName, "nFirstRowVisible=" + nFirstRowVisible + ", nLastRowVisible=" + nLastRowVisible)
  EndWith
  
  If WBE_applyBulkEdit() = #False
    debugMsg0(sProcName, "WBE_applyBulkEdit() = #False")
    SAW(#WBE)
    ProcedureReturn
  EndIf
  WBE_populateBulkEditScreen()
  
  If nLastRowVisible >= 0
    SendMessage_(GadgetID(WBE\grdBulkEdit), #LVM_ENSUREVISIBLE, nLastRowVisible, 0)
  EndIf
  If nFirstRowVisible >= 0
    SendMessage_(GadgetID(WBE\grdBulkEdit), #LVM_ENSUREVISIBLE, nFirstRowVisible, 0)
  EndIf
  
EndProcedure

Procedure WBE_applyNormalization()
  PROCNAMEC()
  Protected nRow, nAudPtr, nMaxRowNo, nNormalizationType
  Protected fTarget.f, fIntegrated.f, fPeak.f, fTruePeak.f
  Protected fCalcLevel.f, fMaxLevel.f, fMaxPeakLevel.f, fMaxTruePeakLevel.f
  Protected fMaxPeakDBLevelDiff.f, fMaxTruePeakDBLevelDiff.f, fTempDBLevel.f
  Protected nIntegratedCount, nSelectedCount, nCalcReqdCount, bDisplayProgress, nProgress
  Protected sProgress.s
  Protected qStartTime.q, qFinishTime.q
  Protected nDevIndex, sReqdLogicalDev.s, fDevDefaultDBLevel.f, sLogMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  qStartTime = ElapsedMilliseconds()
  
  fTarget = grWBE\fTarget ; eg -23.0
  
  sReqdLogicalDev = Trim(GGT(WBE\cboDevice))
  For nDevIndex = 0 To grProd\nMaxAudioLogicalDev
    If grProd\aAudioLogicalDevs(nDevIndex)\sLogicalDev = sReqdLogicalDev
      fDevDefaultDBLevel = convertBVLevelToDBLevel(grProd\aAudioLogicalDevs(nDevIndex)\fDfltBVLevel)
      Break
    EndIf
  Next nDevIndex
  debugMsg(sProcName, "sReqdLogicalDev=" + sReqdLogicalDev + ", fDevDefaultDBLevel=" + StrF(fDevDefaultDBLevel,1) + "dB, grProd\nMaxDBLevel=" + grProd\nMaxDBLevel)
  
  nMaxRowNo = CountGadgetItems(WBE\grdBulkEdit) - 1
  
  For nRow = 0 To nMaxRowNo
    With gaBulkEditItem(nRow)
      \nDeviceIndex = -1
      If \bSelected And \nPtr >= 0
        nAudPtr = \nPtr
        If aAud(nAudPtr)\bAudPlaceHolder = #False
          For nDevIndex = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
            If aAud(nAudPtr)\sLogicalDev[nDevIndex]
              If aAud(nAudPtr)\sLogicalDev[nDevIndex] = sReqdLogicalDev
                \nDeviceIndex = nDevIndex
                nSelectedCount + 1
                If aAud(nAudPtr)\bAudNormSet = #False
                  nCalcReqdCount + 1
                EndIf
                Break ; Break nDevIndex
              EndIf
            EndIf
          Next nDevIndex
        EndIf
      EndIf
    EndWith
  Next nRow
  
  If nSelectedCount = 0
    ProcedureReturn
  EndIf
  
  If nCalcReqdCount > 0
    setMouseCursorBusy()
  EndIf
  
  If nCalcReqdCount > 1
    WMI_displayInfoMsg1(Lang("WBE", "LUFSCalcTitle"), nCalcReqdCount)
    bDisplayProgress = #True
  EndIf
  
  CompilerIf #c_include_peak
    nNormalizationType = #SCS_NORMALIZE_LUFS | #SCS_NORMALIZE_PEAK | #SCS_NORMALIZE_TRUE_PEAK
  CompilerElse
    nNormalizationType = #SCS_NORMALIZE_LUFS | #SCS_NORMALIZE_TRUE_PEAK
  CompilerEndIf
  fMaxLevel = convertDBStringToBVLevel(GGT(WBE\txtMaxLevel))
  fMaxPeakLevel = convertDBLevelToBVLevel(-200)
  fMaxTruePeakLevel = convertDBLevelToBVLevel(-200)
  For nRow = 0 To nMaxRowNo
    With gaBulkEditItem(nRow)
      \bIncluded = #False
      \bIntegrated = #False
      If \bSelected And \nPtr >= 0 And \nDeviceIndex >= 0
        nAudPtr = \nPtr
        If bDisplayProgress And aAud(nAudPtr)\bAudNormSet = #False
          sProgress = getAudLabel(nAudPtr) + " " + GetFilePart(aAud(nAudPtr)\sFileName)
          WMI_displayInfoMsg2(sProgress)
          nProgress + 1
          WMI_setProgress(nProgress)
        EndIf
        \bIncluded = #True
        sLogMsg = getAudLabel(nAudPtr)
        If aAud(nAudPtr)\bAudNormSet = #False
          calcAudLoudness(nAudPtr, nNormalizationType)
        EndIf
        If nNormalizationType & #SCS_NORMALIZE_LUFS
          fIntegrated = aAud(nAudPtr)\fAudNormIntegrated
          If fIntegrated = -Infinity() ; no loudness level available (too short Or silent)
            \bIntegrated = #False
          Else
            \bIntegrated = #True
            nIntegratedCount + 1
            fCalcLevel = convertDBLevelToBVLevel(fTarget - fIntegrated)
            ; debugMsg0(sProcName, getAudLabel(nAudPtr) + ", fIntegrated=" + StrF(fIntegrated,4) + ", fTarget=" + StrF(fTarget,4) + ", fCalcLevel=" + StrF(fCalcLevel,4) + " (" + convertBVLevelToDBString(fCalcLevel) + ")")
            \fIntegratedValue = fCalcLevel
            \fNewValue = \fIntegratedValue ; TEMP???
            ; debugMsg0(sProcName, getAudLabel(nAudPtr) + ", \fNewValue=" + StrF(\fNewValue,4) + " (" + convertBVLevelToDBString(\fNewValue) + ")")
            sLogMsg + " Integrated=" + convertBVLevelToDBString(\fIntegratedValue) + "dB"
          EndIf
        EndIf
        CompilerIf #c_include_peak
          If nNormalizationType & #SCS_NORMALIZE_PEAK
            fPeak = convertBVLevelToDBLevel(aAud(nAudPtr)\fAudNormPeak)
            fCalcLevel = convertDBLevelToBVLevel(fDevDefaultDBLevel - fPeak)
            If fCalcLevel > fMaxPeakLevel
              fMaxPeakLevel = fCalcLevel
            EndIf
            \fPeakValue = fCalcLevel
            sLogMsg + ", Peak=" + convertBVLevelToDBString(\fPeakValue) + "dB"
          EndIf
        CompilerEndIf
        If nNormalizationType & #SCS_NORMALIZE_TRUE_PEAK
          fTruePeak = convertBVLevelToDBLevel(aAud(nAudPtr)\fAudNormTruePeak)
          fCalcLevel = convertDBLevelToBVLevel(fDevDefaultDBLevel - fTruePeak)
          If fCalcLevel > fMaxTruePeakLevel
            fMaxTruePeakLevel = fCalcLevel
          EndIf
          \fTruePeakValue = fCalcLevel
          sLogMsg + ", TruePeak=" + convertBVLevelToDBString(\fTruePeakValue) + "dB"
        EndIf
        ; debugMsg0(sProcName, sLogMsg)
      EndIf
    EndWith
    ; WBE_populateNewValueForRow(nRow)
  Next nRow
  
  fMaxPeakDBLevelDiff = convertBVLevelToDBLevel(fMaxLevel) - convertBVLevelToDBLevel(fMaxPeakLevel)
  fMaxTruePeakDBLevelDiff = convertBVLevelToDBLevel(fMaxLevel) - convertBVLevelToDBLevel(fMaxTruePeakLevel)
  ; debugMsg0(sProcName, "fMaxLevel=" + StrF(fMaxLevel,2) + " (" + convertBVLevelToDBString(fMaxLevel) + "), fMaxPeakDBLevelDiff=" + StrF(fMaxPeakDBLevelDiff,2))
  ; debugMsg0(sProcName, "fMaxLevel=" + StrF(fMaxLevel,2) + " (" + convertBVLevelToDBString(fMaxLevel) + "), fMaxTruePeakDBLevelDiff=" + StrF(fMaxTruePeakDBLevelDiff,2))
  For nRow = 0 To nMaxRowNo
    With gaBulkEditItem(nRow)
      If \bIncluded
        fTempDBLevel = convertBVLevelToDBLevel(\fPeakValue) + fMaxPeakDBLevelDiff
        ; debugMsg0(sProcName, Str(nRow) + ": changing fPeakValue from " + convertBVLevelToDBString(\fPeakValue) + " to " + StrF(fTempDBLevel,2))
        \fPeakValue = convertDBLevelToBVLevel(fTempDBLevel)
        fTempDBLevel = convertBVLevelToDBLevel(\fTruePeakValue) + fMaxTruePeakDBLevelDiff
        ; debugMsg0(sProcName, Str(nRow) + ": changing fTruePeakValue from " + convertBVLevelToDBString(\fTruePeakValue) + " to " + StrF(fTempDBLevel,2))
        \fTruePeakValue = convertDBLevelToBVLevel(fTempDBLevel)
      EndIf
    EndWith
    WBE_populateNewValueForRow(nRow)
  Next nrow

  If getWindowVisible(#WMI)
    debugMsg(sProcName, "calling WMI_Form_Unload()")
    WMI_Form_Unload()
  EndIf
  
  If nCalcReqdCount > 0
    setMouseCursorNormal()
  EndIf
  
  qFinishTime = ElapsedMilliseconds()
  debugMsg(sProcName, "nSelectedCount=" + nSelectedCount + ", nIntegratedCount=" + nIntegratedCount + ", processing time = " + Str(qFinishTime - qStartTime) + " milliseconds")
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WBE_btnViewChanges_Click()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  Select grWBE\nBEField
    Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_REL_START_TIME, #SCS_BE_QA_DISPLAY_TIME
      If WBE_validateNewValue() = #False
        ProcedureReturn
      EndIf
  EndSelect
  
  Select grWBE\nBEField
    Case #SCS_BE_AUDIO_LEVELS
      If grWBE\nChangeType = #SCS_BECT_NORMALIZE
        WBE_applyNormalization()
      EndIf
  EndSelect
  
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  
EndProcedure

Procedure WBE_fcDevice()
  If getCurrentItemData(WBE\cboDevice) = -1
    grWBE\bAllAudioDevs = #True
    grWBE\sAudioDevice = ""
  Else
    grWBE\bAllAudioDevs = #False
    grWBE\sAudioDevice = Trim(GGT(WBE\cboDevice))
  EndIf
EndProcedure

Procedure WBE_cboDevice_Click()
  WBE_fcDevice()
  WBE_populateBulkEditScreen()
EndProcedure

Procedure WBE_cboChangeType_Click()
  
  With WBE
    debugMsg(sProcName, "GGS(\cboChangeType)=" + GGS(\cboChangeType) + ", GetGadgetItemData(\cboChangeType, GGS(\cboChangeType))=" + GetGadgetItemData(\cboChangeType, GGS(\cboChangeType)))
    ; grWBE\nChangeType = GGS(\cboChangeType)
    grWBE\nChangeType = GetGadgetItemData(\cboChangeType, GGS(\cboChangeType))
    WBE_populateCboDevice()
    If (GGS(\cboDevice) < 0) And (CountGadgetItems(\cboDevice) > 0)
      SGS(\cboDevice, 0)
    EndIf
    WBE_fcDevice()
    WBE_populateBulkEditScreen()
  EndWith
  
EndProcedure

Procedure WBE_cboField_Click()
  PROCNAMEC()
  
  grWBE\bInFieldChange = #True
  With WBE
    grWBE\nBEField = GetGadgetItemData(\cboField, GGS(\cboField))
    grWBE\sBEField = Trim(GGT(\cboField))
    
    Select grWBE\nBEField
      Case #SCS_BE_CUE_ENABLED, #SCS_BE_EXCL_CUE, #SCS_BE_WARN_B4_END, #SCS_BE_QA_PAUSE_AT_END, #SCS_BE_QA_REPEAT
        SGS(\chkNewValue, #True)
        SAG(-1)
        
      Case #SCS_BE_AUDIO_LEVELS
        SGS(\cboChangeType, grWBE\nChangeType)
        WBE_populateCboDevice()
        If (GGS(\cboDevice) < 0) And (CountGadgetItems(\cboDevice) > 0)
          SGS(\cboDevice, 0)
        EndIf
        WBE_fcDevice()
        SetActiveGadget(\cboChangeType)
        
      Case #SCS_BE_FADE_IN_TYPE, #SCS_BE_FADE_OUT_TYPE, #SCS_BE_LVL_CHG_TYPE, #SCS_BE_HIDE_CUE_OPT
        If (GGS(\cboNewValue) < 0) And (CountGadgetItems(\cboNewValue) > 0)
          SGS(\cboNewValue, 0)
          scsToolTip(WBE\cboNewValue, GGT(WBE\cboNewValue))
        EndIf
        
      Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_PAGE_NO
        SGT(\txtNewValue, "")
        SAG(\txtNewValue)
        
      Case #SCS_BE_QA_DISPLAY_TIME
        SGT(\txtNewValue, "")
        SGS(\chkContinuous, #PB_Checkbox_Unchecked) ; Added 14Feb2022 11.9.0
        SAG(\txtNewValue)
        
    EndSelect
    
    WBE_populateBulkEditScreen()
    
  EndWith
  grWBE\bInFieldChange = #False
EndProcedure

Procedure WBE_cboLUFS_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  grWBE\fTarget = getCurrentItemData(WBE\cboLUFS)
  debugMsg(sProcName, "grWBE\fTarget=" + StrF(grWBE\fTarget,1))
  WBE_applyNormalization()
  WBE_colorRows()
  
EndProcedure

Procedure WBE_cboNormToApply_Click()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  grEditMem\nLastNormToApply = getCurrentItemData(WBE\cboNormToApply)
  WBE_setNormToApplyVisibleStates()
  WBE_colorRows()
  
EndProcedure

Procedure WBE_cboNewValue_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, "cboNewValue=" + GGT(WBE\cboNewValue))
  scsToolTip(WBE\cboNewValue, GGT(WBE\cboNewValue))
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  
EndProcedure

Procedure WBE_chkNewValue_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, "chkNewValue=" + strB(GetGadgetState(WBE\chkNewValue)))
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  SAG(-1)
  
EndProcedure

Procedure WBE_btnClearAll_Click()
  PROCNAMEC()
  Protected nRow
  
  For nRow = 0 To (CountGadgetItems(WBE\grdBulkEdit)-1)
    SetGadgetItemState(WBE\grdBulkEdit, nRow, 0)
    gaBulkEditItem(nRow)\bSelected = #False
  Next nRow
  
  If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS
    If grWBE\nChangeType = #SCS_BECT_NORMALIZE
      WBE_applyNormalization()
    EndIf
  EndIf
  
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  SAG(-1)
EndProcedure

Procedure WBE_btnHelp_Click()
  displayHelpTopic("bulk_edit.htm")
EndProcedure

Procedure WBE_btnSelectAll_Click()
  PROCNAMEC()
  Protected nRow
  
  For nRow = 0 To (CountGadgetItems(WBE\grdBulkEdit)-1)
    SetGadgetItemState(WBE\grdBulkEdit, nRow, #PB_ListIcon_Checked)
    gaBulkEditItem(nRow)\bSelected = #True
  Next nRow
  
  If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
    WBE_applyNormalization()
  EndIf
  
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  SAG(-1)
EndProcedure

Procedure WBE_populateCboDevice()
  Protected d
  
  With WBE
    ClearGadgetItems(\cboDevice)
    If grWBE\nChangeType <> #SCS_BECT_NORMALIZE
      addGadgetItemWithData(\cboDevice, Lang("Common", "AllDevs"), -1) ; "All Devices" nb data = -1 for 'all devices'
    EndIf
    For d = 0 To grProd\nMaxAudioLogicalDev
      If Trim(grProd\aAudioLogicalDevs(d)\sLogicalDev)
        addGadgetItemWithData(\cboDevice, grProd\aAudioLogicalDevs(d)\sLogicalDev, 0)
      EndIf
    Next d
    If grWBE\nChangeType <> #SCS_BECT_NORMALIZE
      For d = 0 To grProd\nMaxVidAudLogicalDev
        If Trim(grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev)
          addGadgetItemWithData(\cboDevice, grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev, 2)
        EndIf
      Next d
    EndIf
    setComboBoxWidth(\cboDevice)
  EndWith
  
EndProcedure

Procedure WBE_Form_Load()
  PROCNAMEC()
  Protected nRow, i, j, d
  Protected nDevices
  Protected nMaxRows
  Protected bVideoFound, bSFRFound, bLvlChangeFound
  Protected Header
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If IsWindow(#WBE) = #False
    createfmBulkEdit()
  EndIf
  setFormPosition(#WBE, @grBulkEditWindow)
  
  Header = SendMessage_(GadgetID(wbe\grdBulkEdit), #LVM_GETHEADER, 0, 0)
  SendMessage_(Header, #WM_SETFONT, FontID(#SCS_FONT_GEN_NORMAL), 0)
  grWBE\nOldCallBack = SetWindowLongPtr_(GadgetID(wbe\grdBulkEdit), #GWL_WNDPROC, @WBE_grdBulkEdit_CallBack())
  BindEvent(#PB_Event_SizeWindow,@WBE_sizeCallBack())

  With WBE
    ; initialise form-level variables, which may be left at their previous state if the form has been unloaded and reloaded
    grWBE\nBEField = 0
    grWBE\sBEField = ""
    grWBE\nBERowTypes = 0
    grWBE\nBERowCount = 0
    grWBE\bAllAudioDevs = #False
    grWBE\sAudioDevice = ""
    ; end of initialise form-level variables
    
    grWBE\bAllAudioDevs = #True
    
    grWBE\nNoChangeColor = RGB(142, 255, 148)     ; light green
    grWBE\nChangeColor = RGB(255, 255, 0)         ; yellow
    ; grWBE\nCappedColor = RGB(255, 121, 75)        ; orange
    grWBE\nCappedColor =  RGB(255, 183, 160)        ; orange
    grWBE\nIgnoredColor = #SCS_Light_Grey         ; light grey
    
    SetGadgetColor(\txtColorKey[0], #PB_Gadget_BackColor, grWBE\nNoChangeColor)
    SetGadgetColor(\txtColorKey[1], #PB_Gadget_BackColor, grWBE\nChangeColor)
    SetGadgetColor(\txtColorKey[2], #PB_Gadget_BackColor, grWBE\nCappedColor)
    SetGadgetColor(\txtColorKey[3], #PB_Gadget_BackColor, grWBE\nIgnoredColor)
    SetGadgetColor(\lblCappedLevelWarning, #PB_Gadget_BackColor, grWBE\nCappedColor)
    
    If gnLastAud > 0
      For d = 0 To grProd\nMaxAudioLogicalDev
        If Trim(grProd\aAudioLogicalDevs(d)\sLogicalDev)
          nDevices + 1
        EndIf
      Next d
      nMaxRows = gnLastAud * nDevices
    EndIf
    
    If gnLastCue > 0
      If gnLastCue > nMaxRows
        nMaxRows = gnLastCue
      EndIf
    EndIf
    
    If gnLastSub > 0
      If (gnLastSub * nDevices) > nMaxRows
        nMaxRows = (gnLastSub * nDevices)
      EndIf
    EndIf
    
    For i = 1 To gnLastCue
      If aCue(i)\bCueEnabled
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubEnabled
            If aSub(j)\bSubTypeA
              bVideoFound = #True
            EndIf
            If aSub(j)\bSubTypeL
              bLvlChangeFound = #True
            EndIf
            If aSub(j)\bSubTypeS
              bSFRFound = #True
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    Next i
    
    debugMsg(sProcName, "gnLastCue=" + gnLastCue + ", gnLastAud=" + gnLastAud + ", nDevices=" + nDevices + ", nMaxRows=" + nMaxRows)
    ReDim gaBulkEditItem(nMaxRows)
    
    ClearGadgetItems(\cboField)
    addGadgetItemWithData(\cboField, #SCS_BLANK_CBO_ENTRY, 0)
    addGadgetItemWithData(\cboField, Lang("WBE", "AudioLevels"), #SCS_BE_AUDIO_LEVELS)
    addGadgetItemWithData(\cboField, Lang("WBE", "CueEnabled"), #SCS_BE_CUE_ENABLED)
    addGadgetItemWithData(\cboField, Lang("WBE", "HideCueOpt"), #SCS_BE_HIDE_CUE_OPT)
    addGadgetItemWithData(\cboField, Lang("WBE", "ExclusiveCue"), #SCS_BE_EXCL_CUE)
    addGadgetItemWithData(\cboField, Lang("WBE", "PageNo"), #SCS_BE_PAGE_NO)
    addGadgetItemWithData(\cboField, Lang("WBE", "RelStartTime"), #SCS_BE_REL_START_TIME)
    addGadgetItemWithData(\cboField, Lang("WBE", "FadeInTime"), #SCS_BE_FADE_IN_TIME)
    addGadgetItemWithData(\cboField, Lang("WBE", "FadeInType"), #SCS_BE_FADE_IN_TYPE)
    addGadgetItemWithData(\cboField, Lang("WBE", "FadeOutTime"), #SCS_BE_FADE_OUT_TIME)
    addGadgetItemWithData(\cboField, Lang("WBE", "FadeOutType"), #SCS_BE_FADE_OUT_TYPE)
    If bLvlChangeFound
      addGadgetItemWithData(\cboField, Lang("WBE", "LevelChangeType"), #SCS_BE_LVL_CHG_TYPE)
    EndIf
    If bSFRFound
      addGadgetItemWithData(\cboField, Lang("WBE", "SFRTimeOverride"), #SCS_BE_SFR_TIME_OVERRIDE)
      addGadgetItemWithData(\cboField, Lang("WBE", "SFRCompleteAssoc"), #SCS_BE_SFR_COMPLETE_ASSOC)
      addGadgetItemWithData(\cboField, Lang("WBE", "SFRHoldAssoc"), #SCS_BE_SFR_HOLD_ASSOC)
      addGadgetItemWithData(\cboField, Lang("WBE", "SFRGoNext"), #SCS_BE_SFR_GO_NEXT)
    EndIf
    If bVideoFound
      addGadgetItemWithData(\cboField, Lang("WBE", "QARepeat"), #SCS_BE_QA_REPEAT)
      addGadgetItemWithData(\cboField, Lang("WBE", "QAPauseAtEnd"), #SCS_BE_QA_PAUSE_AT_END)
      addGadgetItemWithData(\cboField, Lang("WBE", "QADisplayTime"), #SCS_BE_QA_DISPLAY_TIME)
    EndIf
    If grProd\nVisualWarningTime <> #SCS_VWT_NOT_SET
      addGadgetItemWithData(\cboField, Lang("WBE", "WarnBeforeEnd"), #SCS_BE_WARN_B4_END)
    EndIf
    setComboBoxWidth(\cboField)
    
    ClearGadgetItems(\cboChangeType)
    addGadgetItemWithData(\cboChangeType, Lang("WBE", "Normalize"), #SCS_BECT_NORMALIZE)              ; "Normalize"
    addGadgetItemWithData(\cboChangeType, Lang("WBE", "LevelChangeDesc"), #SCS_BECT_CHANGE_IN_LEVEL)  ; "Change in dB Level (+/-)"
    addGadgetItemWithData(\cboChangeType, Lang("WBE", "NewLevel"), #SCS_BECT_NEW_LEVEL)               ; "New dB Level"
    setComboBoxWidth(\cboChangeType)
    
    WBE_populateCboDevice()
    
    WBE_populateBulkEditScreen()
  EndWith
  
  setWindowVisible(#WBE, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WBE_grdBulkEdit_LeftClick()
  PROCNAMEC()
  Protected nRow
  
  debugMsg(sProcName, #SCS_START)
  
  For nRow = 0 To (CountGadgetItems(WBE\grdBulkEdit)-1)
    If GetGadgetItemState(WBE\grdBulkEdit, nRow) & #PB_ListIcon_Checked   ; nb use & not = as value contains a combination of flags
      gaBulkEditItem(nRow)\bSelected = #True
    Else
      gaBulkEditItem(nRow)\bSelected = #False
    EndIf
  Next nRow
  
  If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS
    If grWBE\nChangeType = #SCS_BECT_NORMALIZE
      WBE_applyNormalization()
    EndIf
  EndIf
  WBE_populateNewValuesForAllRows()
  
  WBE_colorRows()
  WBE_setButtons()
  
  If grWBE\nBEField = #SCS_BE_CUE_ENABLED
    SGT(WBE\txtTotalPlayLength, timeToString(WBE_calcTotalPlayLength(), 0, #True))
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WBE_applyBulkEdit()
  PROCNAMEC()
  Protected n
  Protected i, j, k, d
  Protected sUndoDescr.s
  Protected u, u2, u3
  Protected bRedisplayCue
  Protected bRedoCueListTree
  Protected nNodeKey
  Protected sMsgStart.s
  Protected bValidationOK
  Protected nOldFadeInTime, nNewFadeInTime, nOldFadeOutTime, nNewFadeOutTime
  Protected nReply, sMessage.s, fTempValue.f
  
  debugMsg(sProcName, #SCS_START)
  
  If getEnabled(WBE\btnApply) = #False
    ProcedureReturn #True
  EndIf
  
  bValidationOK = #True
  
  If grWBE\nBEField = #SCS_BE_CUE_ENABLED
    ; if changing the 'enabled' flag check the validity of the changes before proceeding
    For n = 0 To (grWBE\nBERowCount-1)
      If gaBulkEditItem(n)\bSelected
        If gaBulkEditItem(n)\sNewDispValue <> gaBulkEditItem(n)\sOldDispValue
          i = gaBulkEditItem(n)\nPtr
          If i >= 0
            If gaBulkEditItem(n)\bNewValue = #False
              ; sMsgStart = "Cannot disable cue " +  aCue(i)\sCue
              sMsgStart = LangPars("Errors", "CannotDisableCue3", aCue(i)\sCue)
              If checkDelCueRI(i, sMsgStart, 1, #WBE) = #False
                bValidationOK = #False
                Break
              EndIf
            Else
              ; sMsgStart = "Cannot enable cue "  + aCue(i)\sCue
              sMsgStart = LangPars("Errors", "CannotEnableCue3", aCue(i)\sCue)
              If checkDelCueRI(i, sMsgStart, 2, #WBE) = #False
                bValidationOK = #False
                Break
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Next n
  EndIf
  
  If bValidationOK
    Select grWBE\nBEField
      Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_REL_START_TIME, #SCS_BE_QA_DISPLAY_TIME
        If WBE_validateNewValue() = #False
          bValidationOK = #False
        EndIf
    EndSelect
  EndIf
  
  If bValidationOK = #False
    ProcedureReturn #False
  EndIf
  
  If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
    sMessage = LangPars("WBE", "ConfirmNormalization", GGT(WBE\cboNormToApply), GGT(WBE\cboDevice))
    nReply = scsMessageRequester(GetWindowTitle(#WBE), sMessage, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    If nReply <> #PB_MessageRequester_Yes
      SAW(#WBE)
      ProcedureReturn #False
    EndIf
    SAW(#WBE)
  EndIf
  
  setMouseCursorBusy()
  
  sUndoDescr = "Bulk Edit " + GGT(WBE\cboField)
  u = preChangeProdL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_BULK_EDIT, -1, #SCS_UNDO_FLAG_REDO_TREE, grProd\nProdId)
  
  For n = 0 To (grWBE\nBERowCount-1)
    If gaBulkEditItem(n)\bSelected
      If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
        If gaBulkEditItem(n)\sItemType = "AUD"
          k = gaBulkEditItem(n)\nPtr
          d = gaBulkEditItem(n)\nDevNo
          With aAud(k)
            If \bAudTypeF
              u2 = preChangeAudS(\sDBLevel[d], grWBE\sBEField + "[" + gaBulkEditItem(n)\sDevice + "]", k)
              CompilerIf #c_include_peak
                Select grEditMem\nLastNormToApply
                  Case #SCS_NORMALIZE_LUFS
                    fTempValue = gaBulkEditItem(n)\fIntegratedValue
                  Case #SCS_NORMALIZE_PEAK
                    fTempValue = gaBulkEditItem(n)\fPeakValue
                  Case #SCS_NORMALIZE_TRUE_PEAK
                    fTempValue = gaBulkEditItem(n)\fTruePeakValue
                EndSelect
              CompilerElse
                Select grEditMem\nLastNormToApply
                  Case #SCS_NORMALIZE_LUFS
                    fTempValue = gaBulkEditItem(n)\fIntegratedValue
                  Case #SCS_NORMALIZE_TRUE_PEAK
                    fTempValue = gaBulkEditItem(n)\fTruePeakValue
                EndSelect
              CompilerEndIf
              If fTempValue > grLevels\fMaxBVLevel
                fTempValue = grLevels\fMaxBVLevel
              EndIf
              \fBVLevel[d] = fTempValue
              \sDBLevel[d] = convertBVLevelToDBString(fTempValue)
              \fAudPlayBVLevel[d] = fTempValue
              \fSavedBVLevel[d] = fTempValue
              postChangeAudS(u2, \sDBLevel[d], k)
            EndIf
            If \nSubIndex = nEditSubPtr
              bRedisplayCue = #True
            EndIf
          EndWith
        EndIf
       
      ElseIf gaBulkEditItem(n)\sNewDispValue <> gaBulkEditItem(n)\sOldDispValue
        Select grWBE\nBEField
          Case #SCS_BE_CUE_ENABLED ; INFO Apply #SCS_BE_CUE_ENABLED
            ;{
            i = gaBulkEditItem(n)\nPtr
            With aCue(i)
              u2 = preChangeCueL(\bCueEnabled, grWBE\sBEField, i)
              \bCueEnabled = gaBulkEditItem(n)\bNewValue
              \bCueCurrentlyEnabled = \bCueEnabled
              postChangeCueL(u2, \bCueEnabled, i)
              If i = nEditCuePtr
                bRedisplayCue = #True
              EndIf
              bRedoCueListTree = #True
            EndWith
            ;}
          Case #SCS_BE_EXCL_CUE ; INFO Apply #SCS_BE_EXCL_CUE
            ;{
            i = gaBulkEditItem(n)\nPtr
            With aCue(i)
              u2 = preChangeCueL(\bExclusiveCue, grWBE\sBEField, i)
              \bExclusiveCue = gaBulkEditItem(n)\bNewValue
              postChangeCueL(u2, \bExclusiveCue, i)
              If i = nEditCuePtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_PAGE_NO ; INFO Apply #SCS_BE_PAGE_NO
            ;{
            i = gaBulkEditItem(n)\nPtr
            With aCue(i)
              u2 = preChangeCueS(\sPageNo, grWBE\sBEField, i)
              \sPageNo = gaBulkEditItem(n)\sNewValue
              postChangeCueS(u2, \sPageNo, i)
              If i = nEditCuePtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_WARN_B4_END ; INFO Apply #SCS_BE_WARN_B4_END
            ;{
            i = gaBulkEditItem(n)\nPtr
            With aCue(i)
              u2 = preChangeCueL(\bWarningBeforeEnd, grWBE\sBEField, i)
              \bWarningBeforeEnd = gaBulkEditItem(n)\bNewValue
              postChangeCueL(u2, \bWarningBeforeEnd, i)
              If i = nEditCuePtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_HIDE_CUE_OPT  ; INFO Apply #SCS_BE_HIDE_CUE_OPT
            ;{
            i = gaBulkEditItem(n)\nPtr
            With aCue(i)
              u2 = preChangeCueL(\nHideCueOpt, grWBE\sBEField, i)
              \nHideCueOpt = gaBulkEditItem(n)\nNewValue
              postChangeCueL(u2, \nHideCueOpt, i)
              If i = nEditCuePtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_REL_START_TIME ; INFO Apply #SCS_BE_REL_START_TIME
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              u2 = preChangeSubL(\nRelStartTime, grWBE\sBEField, j)
              \nRelStartTime = gaBulkEditItem(n)\nNewValue
              postChangeSubL(u2, \nRelStartTime, j)
              If j = nEditSubPtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_FADE_IN_TYPE ; INFO Apply #SCS_BE_FADE_IN_TYPE
            ;{
            k = gaBulkEditItem(n)\nPtr
            With aAud(k)
              u2 = preChangeAudL(\nFadeInType, grWBE\sBEField, k)
              \nFadeInType = gaBulkEditItem(n)\nNewValue
              postChangeAudL(u2, \nFadeInType, k)
              If \nSubIndex = nEditSubPtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_FADE_OUT_TYPE  ; INFO Apply #SCS_BE_FADE_OUT_TYPE
            ;{
            k = gaBulkEditItem(n)\nPtr
            With aAud(k)
              u2 = preChangeAudL(\nFadeOutType, grWBE\sBEField, k)
              \nFadeOutType = gaBulkEditItem(n)\nNewValue
              postChangeAudL(u2, \nFadeOutType, k)
              If \nSubIndex = nEditSubPtr
                bRedisplayCue = #True
              EndIf
            EndWith
            ;}
          Case #SCS_BE_LVL_CHG_TYPE ; INFO Apply #SCS_BE_LVL_CHG_TYPE
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeL
                u2 = preChangeSubL(\nLCType, grWBE\sBEField, j)
                \nLCType = gaBulkEditItem(n)\nNewValue
                postChangeSubL(u2, \nLCType, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_AUDIO_LEVELS ; INFO Apply #SCS_BE_AUDIO_LEVELS
            ;{
            ; See also earlier code in the procedure for grWBE\nChangeType = #SCS_BECT_NORMALIZE_LUFS
            If gaBulkEditItem(n)\sItemType = "SUB"
              j = gaBulkEditItem(n)\nPtr
              d = gaBulkEditItem(n)\nDevNo
              With aSub(j)
                If \bSubTypeAorP
                  u2 = preChangeSubS(\sPLMastDBLevel[d], grWBE\sBEField + "[" + gaBulkEditItem(n)\sDevice + "]", j)
                  \sPLMastDBLevel[d] = gaBulkEditItem(n)\sNewValue
                  \fSubMastBVLevel[d] = convertDBStringToBVLevel(\sPLMastDBLevel[d])
                  setAudLevelsForSubAorP(j)
                  postChangeSubS(u2, \sPLMastDBLevel[d], j)
                  
                ElseIf \bSubTypeL
                  Select \nLCAction
                    Case #SCS_LC_ACTION_ABSOLUTE, #SCS_LC_ACTION_RELATIVE
                      u2 = preChangeSubS(\sLCReqdDBLevel[d], grWBE\sBEField + "[" + gaBulkEditItem(n)\sDevice + "]", j)
                      \sLCReqdDBLevel[d] = gaBulkEditItem(n)\sNewValue
                      \fLCReqdBVLevel[d] = convertDBStringToBVLevel(\sLCReqdDBLevel[d])
                      postChangeSubS(u2, \sLCReqdDBLevel[d], j)
                  EndSelect
                EndIf
                
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndWith
              
            ElseIf gaBulkEditItem(n)\sItemType = "AUD"
              k = gaBulkEditItem(n)\nPtr
              d = gaBulkEditItem(n)\nDevNo
              With aAud(k)
                If \bAudTypeF Or \bAudTypeI
                  u2 = preChangeAudS(\sDBLevel[d], grWBE\sBEField + "[" + gaBulkEditItem(n)\sDevice + "]", k)
                  \sDBLevel[d] = gaBulkEditItem(n)\sNewValue
                  \fBVLevel[d] = convertDBStringToBVLevel(\sDBLevel[d])
                  \fAudPlayBVLevel[d] = \fBVLevel[d]
                  \fSavedBVLevel[d] = \fBVLevel[d]
                  postChangeAudS(u2, \sDBLevel[d], k)
                EndIf
                If \nSubIndex = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndWith
              
            EndIf
            ;}
          Case #SCS_BE_FADE_IN_TIME ; INFO Apply #SCS_BE_FADE_IN_TIME
            ;{
            Select gaBulkEditItem(n)\sItemType
              Case "AUD"
                k = gaBulkEditItem(n)\nPtr
                With aAud(k)
                  If \nFadeInTime <> gaBulkEditItem(n)\nNewValue ; Test added 12Jan2023 11.9.8ac
                    u2 = preChangeAudL(\nFadeInTime, grWBE\sBEField, k)
                    nOldFadeInTime = \nFadeInTime
                    nNewFadeInTime = gaBulkEditItem(n)\nNewValue
                    \nFadeInTime = nNewFadeInTime
                    \nCurrFadeInTime = \nFadeInTime
                    ; Added 13Dec2022 11.10.0ac
                    debugMsg(sProcName, "calling maintainFadeInLevelPoint(" + getAudLabel(k) + ", " + nOldFadeInTime + ", " + nNewFadeInTime + ")")
                    maintainFadeInLevelPoint(k, nOldFadeInTime, nNewFadeInTime)
                    ; End added 13Dec2022 11.10.0ac
                    postChangeAudL(u2, \nFadeInTime, k)
                    If \nSubIndex = nEditSubPtr
                      bRedisplayCue = #True
                    EndIf
                  EndIf
                EndWith
              Case "SUB"
                j = gaBulkEditItem(n)\nPtr
                With aSub(j)
                  If \bSubTypeAorP
                    u2 = preChangeSubL(\nPLFadeInTime, grWBE\sBEField, j)
                    \nPLFadeInTime = gaBulkEditItem(n)\nNewValue
                    \nPLCurrFadeInTime = \nPLFadeInTime ; Added 13Dec2022 11.10.0ac
                    postChangeSubL(u2, \nPLFadeInTime, j)
                    If j = nEditSubPtr
                      bRedisplayCue = #True
                    EndIf
                  EndIf
                EndWith
            EndSelect
            ;}
          Case #SCS_BE_FADE_OUT_TIME  ; INFO Apply #SCS_BE_FADE_OUT_TIME
            ;{
            Select gaBulkEditItem(n)\sItemType
              Case "AUD"
                k = gaBulkEditItem(n)\nPtr
                With aAud(k)
                  If \nFadeOutTime <> gaBulkEditItem(n)\nNewValue ; Test added 12Jan2023 11.9.8ac
                    u2 = preChangeAudL(\nFadeOutTime, grWBE\sBEField, k)
                    nOldFadeOutTime = \nFadeOutTime
                    nNewFadeOutTime = gaBulkEditItem(n)\nNewValue
                    \nFadeOutTime = nNewFadeOutTime
                    \nCurrFadeOutTime = \nFadeOutTime
                    ; Added 13Dec2022 11.10.0ac
                    debugMsg(sProcName, "calling maintainFadeOutLevelPoint(" + getAudLabel(k) + ", " + nOldFadeOutTime + ", " + nNewFadeOutTime + ")")
                    maintainFadeOutLevelPoint(k, nOldFadeOutTime, nNewFadeOutTime)
                    ; End added 13Dec2022 11.10.0ac
                    postChangeAudL(u2, \nFadeOutTime, k)
                    If \nSubIndex = nEditSubPtr
                      bRedisplayCue = #True
                    EndIf
                  EndIf
                EndWith
              Case "SUB"
                j = gaBulkEditItem(n)\nPtr
                With aSub(j)
                  If \bSubTypeAorP
                    u2 = preChangeSubL(\nPLFadeOutTime, grWBE\sBEField, j)
                    \nPLFadeOutTime = gaBulkEditItem(n)\nNewValue
                    \nPLCurrFadeOutTime = \nPLFadeOutTime ; Added 13Dec2022 11.10.0ac
                    postChangeSubL(u2, \nPLFadeOutTime, j)
                    If j = nEditSubPtr
                      bRedisplayCue = #True
                    EndIf
                    debugMsg(sProcName, "grWBE\nBEField=" + grWBE\nBEField + ", aSub(" + getSubLabel(j) + ")\nPLFadeInTime=" + aSub(j)\nPLFadeInTime + ", \nPLFadeOutTime=" + aSub(j)\nPLFadeOutTime)
                  EndIf
                EndWith
            EndSelect
            ;}
          Case #SCS_BE_SFR_TIME_OVERRIDE ; INFO Apply #SCS_BE_SFR_TIME_OVERRIDE
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeS
                u2 = preChangeSubL(\nSFRTimeOverride, grWBE\sBEField, j)
                \nSFRTimeOverride = gaBulkEditItem(n)\nNewValue
                postChangeSubL(u2, \nSFRTimeOverride, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_SFR_COMPLETE_ASSOC ; INFO Apply #SCS_BE_SFR_COMPLETE_ASSOC
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeS
                u2 = preChangeSubL(\bSFRCompleteAssocAutoStartCues, grWBE\sBEField, j)
                \bSFRCompleteAssocAutoStartCues = gaBulkEditItem(n)\bNewValue
                ; \bSFRCompleteAssocAutoStartCues and \bSFRHoldAssocAutoStartCues are mutually exclusive
                If \bSFRCompleteAssocAutoStartCues
                  \bSFRHoldAssocAutoStartCues = #False
                EndIf
                postChangeSubL(u2, \bSFRCompleteAssocAutoStartCues, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_SFR_HOLD_ASSOC ; INFO Apply #SCS_BE_SFR_HOLD_ASSOC
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeS
                u2 = preChangeSubL(\bSFRHoldAssocAutoStartCues, grWBE\sBEField, j)
                \bSFRHoldAssocAutoStartCues = gaBulkEditItem(n)\bNewValue
                ; \bSFRHoldAssocAutoStartCues and \bSFRCompleteAssocAutoStartCues are mutually exclusive
                If \bSFRHoldAssocAutoStartCues
                  \bSFRCompleteAssocAutoStartCues = #False
                EndIf
                postChangeSubL(u2, \bSFRHoldAssocAutoStartCues, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_SFR_GO_NEXT ; INFO Apply #SCS_BE_SFR_GO_NEXT
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeS
                u2 = preChangeSubL(\bSFRGoNext, grWBE\sBEField, j)
                \bSFRGoNext = gaBulkEditItem(n)\bNewValue
                If \bSFRGoNext = #False
                  \nSFRGoNextDelay = grSubDef\nSFRGoNextDelay
                EndIf
                postChangeSubL(u2, \bSFRGoNext, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_QA_PAUSE_AT_END ; INFO Apply #SCS_BE_QA_PAUSE_AT_END
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeA
                u2 = preChangeSubL(\bPauseAtEnd, grWBE\sBEField, j)
                \bPauseAtEnd = gaBulkEditItem(n)\bNewValue
                postChangeSubL(u2, \bPauseAtEnd, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_QA_REPEAT ; INFO Apply #SCS_BE_QA_REPEAT
            ;{
            j = gaBulkEditItem(n)\nPtr
            With aSub(j)
              If \bSubTypeA
                u2 = preChangeSubL(\bPLRepeat, grWBE\sBEField, j)
                \bPLRepeat= gaBulkEditItem(n)\bNewValue
                postChangeSubL(u2, \bPLRepeat, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
          Case #SCS_BE_QA_DISPLAY_TIME ; INFO Apply #SCS_BE_QA_DISPLAY_TIME
            ;{
            j = gaBulkEditItem(n)\nPtr
            debugMsg(sProcName, "gaBulkEditItem(" + n + ")\nPtr=" + getSubLabel(j) + ", \bNewValue=" + strB(gaBulkEditItem(n)\bNewValue) + ", \nNewValue-" + gaBulkEditItem(n)\nNewValue + ", \sNewDispValue=" + gaBulkEditItem(n)\sNewDispValue)
            With aSub(j)
              If \bSubTypeA
                u2 = preChangeSubL(#True, grWBE\sBEField, j)
                k = \nFirstAudIndex
                While k >= 0
                  If aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                    If gaBulkEditItem(n)\bNewValue
                      ; new 'continuous'
                      If aAud(k)\nNextAudIndex < 0
                        ; last aAud() for this aSub()
                        u3 = preChangeAudL(aAud(k)\bContinuous, grWBE\sBEField, k)
                        aAud(k)\bContinuous = #True
                        aAud(k)\nEndAt = grAudDef\nEndAt
                        aAud(k)\nAbsEndAt = getAbsTime(k, "EN")
                        ; debugMsg0(sProcName, "aAud(" + getAudLabel(k) + ")\bContinuous=" + strB(aAud(k)\bContinuous) + ", \nEndAt=" + aAud(k)\nEndAt + ", \nAbsEndAt=" + aAud(k)\nAbsEndAt)
                        setDerivedAudFields(k)
                        postChangeAudL(u3, aAud(k)\bContinuous, k)
                      Else
                        ; when setting 'continuous' (on the last aAud() for the aSub()), NO changes are made to the 'end at' of the other aAud's
                      EndIf
                    Else
                      ; not 'continuous'
                      If aAud(k)\bContinuous
                        ; clear existing 'continuous' and apply new 'end at'
                        u3 = preChangeAudL(aAud(k)\bContinuous, grWBE\sBEField, k)
                        aAud(k)\bContinuous = #False
                        aAud(k)\nEndAt = gaBulkEditItem(n)\nNewValue
                        aAud(k)\nAbsEndAt = getAbsTime(k, "EN")
                        ; debugMsg0(sProcName, "aAud(" + getAudLabel(k) + ")\bContinuous=" + strB(aAud(k)\bContinuous) + ", \nEndAt=" + aAud(k)\nEndAt + ", \nAbsEndAt=" + aAud(k)\nAbsEndAt)
                        setDerivedAudFields(k)
                        postChangeAudL(u3, aAud(k)\bContinuous, k)
                      Else
                        ; apply new 'end at' to other aAud's
                        u3 = preChangeAudL(aAud(k)\nEndAt, grWBE\sBEField, k)
                        aAud(k)\nEndAt = gaBulkEditItem(n)\nNewValue
                        aAud(k)\nAbsEndAt = getAbsTime(k, "EN")
                        ; debugMsg0(sProcName, "aAud(" + getAudLabel(k) + ")\bContinuous=" + strB(aAud(k)\bContinuous) + ", \nEndAt=" + aAud(k)\nEndAt + ", \nAbsEndAt=" + aAud(k)\nAbsEndAt)
                        setDerivedAudFields(k)
                        postChangeAudL(u3, aAud(k)\nEndAt, k)
                      EndIf
                    EndIf
                  EndIf ; EndIf aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                  k = aAud(k)\nNextAudIndex
                Wend
                calcPLTotalTime(j)
                debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nPLTotalTime=" + \nPLTotalTime + ", \nSubDuration=" + \nSubDuration)
                postChangeSubL(u2, #False, j)
                If j = nEditSubPtr
                  bRedisplayCue = #True
                EndIf
              EndIf
            EndWith
            ;}
        EndSelect
      EndIf
    EndIf
  Next n
  
  postChangeProdL(u, #False)
  
  If bRedoCueListTree
    If nEditCuePtr >= 0
      nNodeKey = aCue(nEditCuePtr)\nNodeKey
    Else
      nNodeKey = grProd\nNodeKey
    EndIf
    redoCueListTree(nNodeKey)
  EndIf
  
  If bRedisplayCue
    displayCue(nEditCuePtr, nEditSubPtr)
  EndIf
  
  If grWBE\nBEField = #SCS_BE_CUE_ENABLED
    loadHotkeyArray()
    samAddRequest(#SCS_SAM_DISPLAY_OR_HIDE_HOTKEYS)
  EndIf
  loadCueMarkerArrays()
  
  Select grWBE\nBEField
    Case #SCS_BE_CUE_ENABLED, #SCS_BE_EXCL_CUE, #SCS_BE_HIDE_CUE_OPT, #SCS_BE_AUDIO_LEVELS, #SCS_BE_PAGE_NO, #SCS_BE_QA_DISPLAY_TIME
      gbCallPopulateGrid = #True
      gbCallLoadDispPanels = #True
  EndSelect
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure WBE_setNormToApplyVisibleStates()
  PROCNAMEC()
  Protected nNormToApply, bLUFSVisible, bMaxLevelVisible
  
  With WBE
    nNormToApply = getCurrentItemData(\cboNormToApply)
    CompilerIf #c_include_peak
      Select nNormToApply
        Case #SCS_NORMALIZE_LUFS
          bLUFSVisible = #True
        Case #SCS_NORMALIZE_PEAK, #SCS_NORMALIZE_TRUE_PEAK
          bMaxLevelVisible = #True
      EndSelect
    CompilerElse
      Select nNormToApply
        Case #SCS_NORMALIZE_LUFS
          bLUFSVisible = #True
        Case #SCS_NORMALIZE_TRUE_PEAK
          bMaxLevelVisible = #True
      EndSelect
    CompilerEndIf
    
    setVisible(\lblLUFS, bLUFSVisible)
    setVisible(\cboLUFS, bLUFSVisible)
    setVisible(\lblLUFSComment, bLUFSVisible)
    setVisible(\lblMaxLevel, bMaxLevelVisible)
    setVisible(\txtMaxLevel, bMaxLevelVisible)
    
  EndWith
  
EndProcedure

Procedure WBE_populateBulkEditScreen()
  PROCNAMEC()
  Protected i, j, k, n, d
  Protected rBulkEditItem.tyBulkEditItem
  Protected bWantThis, bAudioLevelInfoVisible, bNormalize, nDevNo
  Protected sCue.s, sCueType.s
  Protected nRow, nTop, nLeft
  Protected sLabelHeader.s
  Protected nImageCount, nContinuousCount, nDisplayTimeCount, nMinDisplayTime, nMaxDisplayTime, bContinuous
  Protected bFirstTime, nTime, sOldValue.s
  
  debugMsg(sProcName, #SCS_START)
  
  With WBE
    setVisible(\cntAudioLevelInfo, #False)
    setVisible(\lblNewValue, #False)
    setVisible(\cboNewValue, #False)
    setVisible(\txtNewValue, #False)
    setVisible(\lblContinuous, #False)
    setVisible(\chkContinuous, #False)
    setVisible(\chkNewValue, #False)
    setVisible(\btnViewChanges, #False)
    setVisible(\lblLUFS, #False)
    setVisible(\cboLUFS, #False)
    setVisible(\lblLUFSComment, #False)
    setVisible(\lblNormToApply, #False)
    setVisible(\cboNormToApply, #False)
    
    SGT(\lblNewValue, Lang("WBE", "lblNewValue")) ; "New value for this field"
    SGT(\txtNewValue, "")
    scsToolTip(\txtNewValue, "")
    setValidChars(\txtNewValue, "") ; clear any 'valid chars' settings when used for numeric fields
    
    grWBE\nBERowTypes = 0
    grWBE\nBERowCount = 0
    
    Select grWBE\nBEField
      Case #SCS_BE_CUE_ENABLED ; INFO Populate #SCS_BE_CUE_ENABLED
        ;{
        grWBE\nBERowTypes = #SCS_BE_CUES
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "CueEnabled"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          rBulkEditItem = grBulkEditItemDef
          rBulkEditItem\nPtr = i
          rBulkEditItem\nCuePtr = i
          rBulkEditItem\sItemType = "CUE"
          sCue = aCue(i)\sCue
          j = aCue(i)\nFirstSubIndex
          If j >= 0
            sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
            If aSub(j)\nNextSubIndex >= 0
              sCue + "+"
            EndIf
          EndIf
          rBulkEditItem\sLabel = sCue
          rBulkEditItem\sCueType = sCueType
          rBulkEditItem\sDescr = aCue(i)\sCueDescr
          rBulkEditItem\bOldValue = aCue(i)\bCueEnabled
          rBulkEditItem\nNewValue = rBulkEditItem\bOldValue
          rBulkEditItem\sOldDispValue = WBE_decodeEnabled(rBulkEditItem\bOldValue)
          rBulkEditItem\sNewDispValue = WBE_decodeEnabled(rBulkEditItem\bNewValue)
          If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
            ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
          EndIf
          gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
          grWBE\nBERowCount + 1
        Next i
        ;}
      Case #SCS_BE_EXCL_CUE ; INFO Populate #SCS_BE_EXCL_CUE
        ;{
        grWBE\nBERowTypes = #SCS_BE_CUES
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "ExclusiveCue"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            rBulkEditItem = grBulkEditItemDef
            rBulkEditItem\nPtr = i
            rBulkEditItem\nCuePtr = i
            rBulkEditItem\sItemType = "CUE"
            sCue = aCue(i)\sCue
            j = aCue(i)\nFirstSubIndex
            If j >= 0
              sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
              If aSub(j)\nNextSubIndex >= 0
                sCue + "+"
              EndIf
            EndIf
            rBulkEditItem\sLabel = sCue
            rBulkEditItem\sCueType = sCueType
            rBulkEditItem\sDescr = aCue(i)\sCueDescr
            rBulkEditItem\bOldValue = aCue(i)\bExclusiveCue
            rBulkEditItem\nNewValue = rBulkEditItem\bOldValue
            rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_EXCL_CUE, rBulkEditItem\bOldValue)
            rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_EXCL_CUE,rBulkEditItem\bNewValue)
            If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
              ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
            EndIf
            gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
            grWBE\nBERowCount + 1
          EndIf
        Next i
        ;}
      Case #SCS_BE_PAGE_NO ; INFO Populate #SCS_BE_PAGE_NO
        ;{
        grWBE\nBERowTypes = #SCS_BE_CUES
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "PageNo"))
        setVisible(\txtNewValue, #True)
        setVisible(\btnViewChanges, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            rBulkEditItem = grBulkEditItemDef
            rBulkEditItem\nPtr = i
            rBulkEditItem\nCuePtr = i
            rBulkEditItem\sItemType = "CUE"
            sCue = aCue(i)\sCue
            j = aCue(i)\nFirstSubIndex
            If j >= 0
              sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
              If aSub(j)\nNextSubIndex >= 0
                sCue + "+"
              EndIf
            EndIf
            rBulkEditItem\sLabel = sCue
            rBulkEditItem\sCueType = sCueType
            rBulkEditItem\sDescr = aCue(i)\sCueDescr
            rBulkEditItem\sOldValue = aCue(i)\sPageNo
            rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
            rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
            rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
            If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
              ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
            EndIf
            gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
            grWBE\nBERowCount + 1
          EndIf
        Next i
        ;}
      Case #SCS_BE_WARN_B4_END ; INFO Populate #SCS_BE_WARN_B4_END
        ;{
        grWBE\nBERowTypes = #SCS_BE_CUES
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "WarnBeforeEnd"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            rBulkEditItem = grBulkEditItemDef
            rBulkEditItem\nPtr = i
            rBulkEditItem\nCuePtr = i
            rBulkEditItem\sItemType = "CUE"
            sCue = aCue(i)\sCue
            j = aCue(i)\nFirstSubIndex
            If j >= 0
              sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
              If aSub(j)\nNextSubIndex >= 0
                sCue + "+"
              EndIf
            EndIf
            rBulkEditItem\sLabel = sCue
            rBulkEditItem\sCueType = sCueType
            rBulkEditItem\sDescr = aCue(i)\sCueDescr
            rBulkEditItem\bOldValue = aCue(i)\bWarningBeforeEnd
            rBulkEditItem\nNewValue = rBulkEditItem\bOldValue
            rBulkEditItem\sOldDispValue = WBE_decodeWarnBeforeEnd(rBulkEditItem\bOldValue)
            rBulkEditItem\sNewDispValue = WBE_decodeWarnBeforeEnd(rBulkEditItem\bNewValue)
            If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
              ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
            EndIf
            gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
            grWBE\nBERowCount + 1
          EndIf
        Next i
        ;}
      Case #SCS_BE_HIDE_CUE_OPT ; INFO Populate #SCS_BE_HIDE_CUE_OPT
        ;{
        grWBE\nBERowTypes = #SCS_BE_CUES
        setVisible(\lblNewValue, #True)
        buildEditCBO(\cboNewValue, "HideCueOpt")
        setVisible(\cboNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            rBulkEditItem = grBulkEditItemDef
            rBulkEditItem\nPtr = i
            rBulkEditItem\nCuePtr = i
            rBulkEditItem\sItemType = "CUE"
            sCue = aCue(i)\sCue
            j = aCue(i)\nFirstSubIndex
            If j >= 0
              sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
              If aSub(j)\nNextSubIndex >= 0
                sCue + "+"
              EndIf
            EndIf
            rBulkEditItem\sLabel = sCue
            rBulkEditItem\sCueType = sCueType
            rBulkEditItem\sDescr = aCue(i)\sCueDescr
            rBulkEditItem\nOldValue = aCue(i)\nHideCueOpt
            rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
            rBulkEditItem\sOldDispValue = decodeHideCueOptL(rBulkEditItem\nOldValue)
            rBulkEditItem\sNewDispValue = decodeHideCueOptL(rBulkEditItem\nNewValue)
            If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
              ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
            EndIf
            gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
            grWBE\nBERowCount + 1
          EndIf
        Next i
        ;}
      Case #SCS_BE_REL_START_TIME ; INFO Populate #SCS_BE_REL_START_TIME
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        setVisible(\txtNewValue, #True)
        setValidChars(\txtNewValue, "1234567890.:")
        setVisible(\btnViewChanges, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                rBulkEditItem = grBulkEditItemDef
                rBulkEditItem\nPtr = j
                rBulkEditItem\nCuePtr = i
                rBulkEditItem\sItemType = "SUB"
                rBulkEditItem\sSubType = aSub(j)\sSubType
                rBulkEditItem\sLabel = aSub(j)\sSubLabel
                rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                rBulkEditItem\sDescr = aSub(j)\sSubDescr
                rBulkEditItem\nOldValue = aSub(j)\nRelStartTime
                rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                rBulkEditItem\sOldDispValue = timeToString(rBulkEditItem\nOldValue)
                rBulkEditItem\sNewDispValue = timeToString(rBulkEditItem\nNewValue)
                If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                  ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                EndIf
                gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                grWBE\nBERowCount + 1
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_AUDIO_LEVELS ; INFO Populate #SCS_BE_AUDIO_LEVELS
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        bAudioLevelInfoVisible = #True
        Select grWBE\nChangeType
          Case #SCS_BECT_CHANGE_IN_LEVEL
            SGT(\lblNewValue, Lang("WBE", "LevelChangeDesc")) ; "Change in dB Level (+/-)"
            scsToolTip(\txtNewValue, Lang("WBE", "LevelChangeTT"))  ; "Enter required dB change starting with + or -. Examples: +3 to increase level 3dB; -4.5 to decrease level 4.5dB."
            setValidChars(\txtNewValue, "1234567890.+-")
          Case #SCS_BECT_NEW_LEVEL
            SGT(\lblNewValue, Lang("WBE", "NewLevel")) ; "New dB Level"
            ; for #SCS_BECT_NEW_LEVEL do NOT call setValidChars() with the numeric characters as the user is permitted to enter -INF for the new level
          Case #SCS_BECT_NORMALIZE
            bNormalize = #True
            ClearGadgetItems(\cboNormToApply)
            addGadgetItemWithData(\cboNormToApply, Lang("WBE","IntegratedLUFS"), #SCS_NORMALIZE_LUFS)
            CompilerIf #c_include_peak
              addGadgetItemWithData(\cboNormToApply, Lang("WBE","Peak"), #SCS_NORMALIZE_PEAK)
            CompilerEndIf
            addGadgetItemWithData(\cboNormToApply, Lang("WBE","TruePeak"), #SCS_NORMALIZE_TRUE_PEAK)
            setComboBoxWidth(\cboNormToApply)
            setComboBoxByData(\cboNormToApply, grEditMem\nLastNormToApply)
            setVisible(\lblNormToApply, #True)
            setVisible(\cboNormToApply, #True)
            ; LUFS info
            ClearGadgetItems(\cboLUFS)
            For n = -23 To -13
              addGadgetItemWithData(\cboLUFS, Str(n)+".0", n)
            Next n
            SetGadgetState(\cboLUFS, 0)
            grWBE\fTarget = getCurrentItemData(WBE\cboLUFS) ; must be actgioned AFTER populating \cboLUFS and setting the gadget state
            setComboBoxWidth(\cboLUFS)
            nLeft = GadgetX(\cboLUFS) + GadgetWidth(\cboLUFS) + gnGap2
            ResizeGadget(\lblLUFSComment, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
            WBE_setNormToApplyVisibleStates()
            ; Peak and True Peak info
            SGT(\lblMaxLevel, Lang("WBE", "MaxLevel")) ; "Maximum dB Level"
            ; for normalize, pre-populate \txtMaxLevel with the selected audio device's default dB level (user can change \txtMaxLevel if required)
            nDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_AUDIO_OUTPUT, grWBE\sAudioDevice)
            If nDevNo >= 0
              SGT(\txtMaxLevel, grProd\aAudioLogicalDevs(nDevNo)\sDfltDBLevel)
            EndIf
            setValidChars(\txtMaxLevel, "1234567890.+-")
        EndSelect
        If grWBE\nChangeType <> #SCS_BECT_NORMALIZE
          setVisible(\lblNewValue, #True)
          setVisible(\txtNewValue, #True)
          setVisible(\btnViewChanges, #True)
        EndIf
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If (aSub(j)\bSubTypeA) And (bNormalize = #False)
                  d = 0
                  If (aSub(j)\bMuteVideoAudio = #False) And (aSub(j)\sVidAudLogicalDev)
                    If (grWBE\bAllAudioDevs) Or (aSub(j)\sVidAudLogicalDev = grWBE\sAudioDevice)
                      rBulkEditItem = grBulkEditItemDef
                      rBulkEditItem\nPtr = j
                      rBulkEditItem\nCuePtr = i
                      rBulkEditItem\sItemType = "SUB"
                      rBulkEditItem\sSubType = aSub(j)\sSubType
                      rBulkEditItem\sLabel = aSub(j)\sSubLabel
                      rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                      rBulkEditItem\sDescr = aSub(j)\sSubDescr
                      rBulkEditItem\nDevNo = d
                      rBulkEditItem\sDevice = aSub(j)\sVidAudLogicalDev
                      rBulkEditItem\sOldValue = aSub(j)\sPLMastDBLevel[d]
                      rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
                      rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
                      rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
                      If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                        ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                      EndIf
                      gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                      grWBE\nBERowCount + 1
                    EndIf
                  EndIf
                  
                ElseIf (aSub(j)\bSubTypeP) And (bNormalize = #False)
                  For d = 0 To grLicInfo\nMaxAudDevPerAud
                    If aSub(j)\sPLLogicalDev[d]
                      If (grWBE\bAllAudioDevs) Or (aSub(j)\sPLLogicalDev[d] = grWBE\sAudioDevice)
                        rBulkEditItem = grBulkEditItemDef
                        rBulkEditItem\nPtr = j
                        rBulkEditItem\nCuePtr = i
                        rBulkEditItem\sItemType = "SUB"
                        rBulkEditItem\sSubType = aSub(j)\sSubType
                        rBulkEditItem\sLabel = aSub(j)\sSubLabel
                        rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                        rBulkEditItem\sDescr = aSub(j)\sSubDescr
                        rBulkEditItem\nDevNo = d
                        rBulkEditItem\sDevice = aSub(j)\sPLLogicalDev[d]
                        rBulkEditItem\sOldValue = aSub(j)\sPLMastDBLevel[d]
                        rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
                        If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                          ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                        EndIf
                        gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                        grWBE\nBERowCount + 1
                      EndIf
                    EndIf
                  Next d
                  
                ElseIf (aSub(j)\bSubTypeL) And (bNormalize = #False)
                  populateLCAudioDevs(@aSub(j))
                  For d = 0 To grLicInfo\nMaxAudDevPerAud
                    If (aSub(j)\sLCLogicalDev[d]) And (aSub(j)\bLCInclude[d])
                      If (grWBE\bAllAudioDevs) Or (aSub(j)\sLCLogicalDev[d] = grWBE\sAudioDevice)
                        rBulkEditItem = grBulkEditItemDef
                        rBulkEditItem\nPtr = j
                        rBulkEditItem\nCuePtr = i
                        rBulkEditItem\sItemType = "SUB"
                        rBulkEditItem\sSubType = aSub(j)\sSubType
                        rBulkEditItem\sLabel = aSub(j)\sSubLabel
                        rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                        rBulkEditItem\sDescr = aSub(j)\sSubDescr
                        rBulkEditItem\nDevNo = d
                        rBulkEditItem\sDevice = aSub(j)\sLCLogicalDev[d]
                        rBulkEditItem\sOldValue = aSub(j)\sLCReqdDBLevel[d]
                        rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
                        If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                          ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                        EndIf
                        gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                        grWBE\nBERowCount + 1
                      EndIf
                    EndIf
                  Next d
                  
                ElseIf (aSub(j)\bSubTypeF) Or ((aSub(j)\bSubTypeI) And (bNormalize = #False))
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    For d = 0 To grLicInfo\nMaxAudDevPerAud
                      bWantThis = #False
                      If aAud(k)\sLogicalDev[d]
                        If (grWBE\bAllAudioDevs) Or (aAud(k)\sLogicalDev[d] = grWBE\sAudioDevice)
                          bWantThis = #True
                        EndIf
                      EndIf
                      If bWantThis
                        rBulkEditItem = grBulkEditItemDef
                        rBulkEditItem\nPtr = k
                        rBulkEditItem\nCuePtr = i
                        rBulkEditItem\sItemType = "AUD"
                        rBulkEditItem\sSubType = aSub(j)\sSubType
                        rBulkEditItem\sLabel = aSub(j)\sSubLabel
                        rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                        rBulkEditItem\sDescr = aSub(j)\sSubDescr
                        rBulkEditItem\nDevNo = d
                        rBulkEditItem\sDevice = aAud(k)\sLogicalDev[d]
                        rBulkEditItem\nFileStatsPtr = aAud(k)\nFileStatsPtr
                        rBulkEditItem\sOldValue = aAud(k)\sDBLevel[d]
                        rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
                        rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
                        If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                          ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                        EndIf
                        gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                        grWBE\nBERowCount + 1
                      EndIf
                    Next d
                    k = aAud(k)\nNextAudIndex
                  Wend
                  
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_FADE_IN_TYPE ; INFO Populate #SCS_BE_FADE_IN_TYPE
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        buildEditCBO(\cboNewValue, "FadeIn")
        setVisible(\cboNewValue, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeF
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    rBulkEditItem = grBulkEditItemDef
                    rBulkEditItem\nPtr = k
                    rBulkEditItem\nCuePtr = i
                    rBulkEditItem\sItemType = "AUD"
                    rBulkEditItem\sSubType = aSub(j)\sSubType
                    rBulkEditItem\sLabel = aSub(j)\sSubLabel
                    rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                    rBulkEditItem\sDescr = aSub(j)\sSubDescr
                    rBulkEditItem\nOldValue = aAud(k)\nFadeInType
                    rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                    rBulkEditItem\sOldDispValue = decodeFadeTypeL(rBulkEditItem\nOldValue)
                    rBulkEditItem\sNewDispValue = decodeFadeTypeL(rBulkEditItem\nNewValue)
                    If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                      ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                    EndIf
                    gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                    grWBE\nBERowCount + 1
                    k = aAud(k)\nNextAudIndex
                  Wend
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_FADE_OUT_TYPE  ; INFO Populate #SCS_BE_FADE_OUT_TYPE
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        buildEditCBO(\cboNewValue, "FadeOut")
        setVisible(\cboNewValue, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeF
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    rBulkEditItem = grBulkEditItemDef
                    rBulkEditItem\nPtr = k
                    rBulkEditItem\nCuePtr = i
                    rBulkEditItem\sItemType = "AUD"
                    rBulkEditItem\sSubType = aSub(j)\sSubType
                    rBulkEditItem\sLabel = aSub(j)\sSubLabel
                    rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                    rBulkEditItem\sDescr = aSub(j)\sSubDescr
                    rBulkEditItem\nOldValue = aAud(k)\nFadeOutType
                    rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                    rBulkEditItem\sOldDispValue = decodeFadeTypeL(rBulkEditItem\nOldValue)
                    rBulkEditItem\sNewDispValue = decodeFadeTypeL(rBulkEditItem\nNewValue)
                    If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                      ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                    EndIf
                    gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                    grWBE\nBERowCount + 1
                    k = aAud(k)\nNextAudIndex
                  Wend
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_LVL_CHG_TYPE ; INFO Populate #SCS_BE_LVL_CHG_TYPE
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        buildEditCBO(\cboNewValue, "LevelChange")
        setVisible(\cboNewValue, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeL
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\nOldValue = aSub(j)\nLCType
                  rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                  rBulkEditItem\sOldDispValue = decodeFadeTypeL(rBulkEditItem\nOldValue)
                  rBulkEditItem\sNewDispValue = decodeFadeTypeL(rBulkEditItem\nNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME  ; INFO Populate #SCS_BE_FADE_IN_TIME
                                                        ; INFO Populate #SCS_BE_FADE_OUT_TIME
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        setVisible(\txtNewValue, #True)
        setValidChars(\txtNewValue, "1234567890.:")
        setVisible(\btnViewChanges, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeI
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    rBulkEditItem = grBulkEditItemDef
                    rBulkEditItem\nPtr = k
                    rBulkEditItem\nCuePtr = i
                    rBulkEditItem\sItemType = "AUD"
                    rBulkEditItem\sSubType = aSub(j)\sSubType
                    rBulkEditItem\sLabel = aSub(j)\sSubLabel
                    rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                    rBulkEditItem\sDescr = aSub(j)\sSubDescr
                    If grWBE\nBEField = #SCS_BE_FADE_IN_TIME
                      rBulkEditItem\nOldValue = aAud(k)\nFadeInTime
                    Else
                      rBulkEditItem\nOldValue = aAud(k)\nFadeOutTime
                    EndIf
                    rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                    rBulkEditItem\sOldDispValue = timeToString(rBulkEditItem\nOldValue)
                    rBulkEditItem\sNewDispValue = timeToString(rBulkEditItem\nNewValue)
                    If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                      ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                    EndIf
                    gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                    grWBE\nBERowCount + 1
                    k = aAud(k)\nNextAudIndex
                  Wend
                ElseIf aSub(j)\bSubTypeAorP
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  debugMsg(sProcName, "grWBE\nBEField=" + grWBE\nBEField + ", aSub(" + getSubLabel(j) + ")\nPLFadeInTime=" + aSub(j)\nPLFadeInTime + ", \nPLFadeOutTime=" + aSub(j)\nPLFadeOutTime)
                  If grWBE\nBEField = #SCS_BE_FADE_IN_TIME
                    rBulkEditItem\nOldValue = aSub(j)\nPLFadeInTime
                  Else
                    rBulkEditItem\nOldValue = aSub(j)\nPLFadeOutTime
                  EndIf
                  rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                  rBulkEditItem\sOldDispValue = timeToString(rBulkEditItem\nOldValue)
                  rBulkEditItem\sNewDispValue = timeToString(rBulkEditItem\nNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_SFR_TIME_OVERRIDE ; INFO Populate #SCS_BE_SFR_TIME_OVERRIDE
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        setVisible(\txtNewValue, #True)
        setValidChars(\txtNewValue, "1234567890.:")
        setVisible(\btnViewChanges, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeS
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\nOldValue = aSub(j)\nSFRTimeOverride
                  rBulkEditItem\nNewValue = rBulkEditItem\nOldValue
                  rBulkEditItem\sOldDispValue = timeToString(rBulkEditItem\nOldValue)
                  rBulkEditItem\sNewDispValue = timeToString(rBulkEditItem\nNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_SFR_COMPLETE_ASSOC   ; INFO Populate #SCS_BE_SFR_COMPLETE_ASSOC
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "CompleteAssoc"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeS
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\bOldValue = aSub(j)\bSFRCompleteAssocAutoStartCues
                  rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                  rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_SFR_COMPLETE_ASSOC, rBulkEditItem\bOldValue)
                  rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_COMPLETE_ASSOC, rBulkEditItem\bNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_SFR_HOLD_ASSOC   ; INFO Populate #SCS_BE_SFR_HOLD_ASSOC
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "HoldAssoc"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeS
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\bOldValue = aSub(j)\bSFRHoldAssocAutoStartCues
                  rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                  rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_SFR_HOLD_ASSOC, rBulkEditItem\bOldValue)
                  rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_HOLD_ASSOC, rBulkEditItem\bNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_SFR_GO_NEXT   ; INFO Populate #SCS_BE_SFR_GO_NEXT
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WBE", "GoNextCue"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeS
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\bOldValue = aSub(j)\bSFRGoNext
                  rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                  rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_SFR_GO_NEXT, rBulkEditItem\bOldValue)
                  rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_GO_NEXT, rBulkEditItem\bNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_QA_REPEAT   ; INFO Populate #SCS_BE_QA_REPEAT
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WQA", "chkPLRepeat"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeA
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\bOldValue = aSub(j)\bPLRepeat
                  rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                  rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_QA_REPEAT, rBulkEditItem\bOldValue)
                  rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_QA_REPEAT, rBulkEditItem\bNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_QA_PAUSE_AT_END   ; INFO Populate #SCS_BE_QA_PAUSE_AT_END
        ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setVisible(\lblNewValue, #True)
        SetGadgetText(\chkNewValue, Lang("WQA", "chkPauseAtEnd"))
        setVisible(\chkNewValue, #True)
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If aSub(j)\bSubTypeA
                  rBulkEditItem = grBulkEditItemDef
                  rBulkEditItem\nPtr = j
                  rBulkEditItem\nCuePtr = i
                  rBulkEditItem\sItemType = "SUB"
                  rBulkEditItem\sSubType = aSub(j)\sSubType
                  rBulkEditItem\sLabel = aSub(j)\sSubLabel
                  rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                  rBulkEditItem\sDescr = aSub(j)\sSubDescr
                  rBulkEditItem\bOldValue = aSub(j)\bPauseAtEnd
                  rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                  rBulkEditItem\sOldDispValue = WBE_decodeBoolean(#SCS_BE_QA_PAUSE_AT_END, rBulkEditItem\bOldValue)
                  rBulkEditItem\sNewDispValue = WBE_decodeBoolean(#SCS_BE_QA_PAUSE_AT_END, rBulkEditItem\bNewValue)
                  If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                    ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                  EndIf
                  gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                  grWBE\nBERowCount + 1
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
      Case #SCS_BE_QA_DISPLAY_TIME ; INFO Populate #SCS_BE_QA_DISPLAY_TIME
                                   ;{
        grWBE\nBERowTypes = #SCS_BE_SUBS
        setValidChars(\txtNewValue, "1234567890.")
        setVisible(\lblNewValue, #True)
        setVisible(\txtNewValue, #True)
        setVisible(\lblContinuous, #True)
        setVisible(\chkContinuous, #True)
        setVisible(\btnViewChanges, #True)
        
        For i = 1 To gnLastCue
          If aCue(i)\bCueEnabled
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                If (aSub(j)\bSubTypeA) And (aSub(j)\bSubPlaceHolder = #False)
                  nImageCount = 0
                  nContinuousCount = 0
                  bContinuous = #False
                  nDisplayTimeCount = 0
                  nMinDisplayTime = 0
                  nMaxDisplayTime = 0
                  bFirstTime = #True
                  k = aSub(j)\nFirstAudIndex
                  While k >= 0
                    If aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                      nImageCount + 1
                      If aAud(k)\bContinuous
                        nContinuousCount + 1
                      Else
                        nDisplayTimeCount + 1
                        nTime = aAud(k)\nEndAt
                        If nTime >= 0
                          If (nTime < nMinDisplayTime) Or (bFirstTime)
                            nMinDisplayTime = nTime
                            bFirstTime = #False
                          EndIf
                          If nTime > nMaxDisplayTime
                            nMaxDisplayTime = nTime
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                    k = aAud(k)\nNextAudIndex
                  Wend
                  If nImageCount > 0
                    rBulkEditItem = grBulkEditItemDef
                    rBulkEditItem\nPtr = j
                    rBulkEditItem\nCuePtr = i
                    rBulkEditItem\sItemType = "SUB"
                    rBulkEditItem\sSubType = aSub(j)\sSubType
                    rBulkEditItem\sLabel = aSub(j)\sSubLabel
                    rBulkEditItem\sCueType = decodeSubTypeL(aSub(j)\sSubType, j)
                    rBulkEditItem\sDescr = aSub(j)\sSubDescr
                    sOldValue = ""
                    If nDisplayTimeCount > 0
                      sOldValue = timeToString(nMinDisplayTime)
                      If nMaxDisplayTime > nMinDisplayTime
                        sOldValue + " - " + timeToString(nMaxDisplayTime)
                      EndIf
                      If nContinuousCount > 0
                        sOldValue + ", & "
                      EndIf
                    EndIf
                    If nContinuousCount > 0
                      sOldValue + Lang("WQA", "chkContinuous")
                      bContinuous = #True
                    EndIf
                    rBulkEditItem\sOldValue = sOldValue
                    rBulkEditItem\sNewValue = rBulkEditItem\sOldValue
                    rBulkEditItem\sOldDispValue = rBulkEditItem\sOldValue
                    rBulkEditItem\sNewDispValue = rBulkEditItem\sNewValue
                    rBulkEditItem\bOldValue = bContinuous
                    rBulkEditItem\bNewValue = rBulkEditItem\bOldValue
                    If grWBE\nBERowCount > ArraySize(gaBulkEditItem())
                      ReDim gaBulkEditItem(grWBE\nBERowCount + 20)
                    EndIf
                    gaBulkEditItem(grWBE\nBERowCount) = rBulkEditItem
                    grWBE\nBERowCount + 1
                  EndIf
                EndIf
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        Next i
        ;}
    EndSelect
    
    Select grWBE\nBERowTypes
      Case #SCS_BE_CUES
        sLabelHeader = "Cue"
      Case #SCS_BE_SUBS
        sLabelHeader = "Sub-Cue"
      Default
        sLabelHeader = "Label"
    EndSelect
    
    If bAudioLevelInfoVisible
      setVisible(\cntAudioLevelInfo, #True)
      nTop = GadgetY(\cntAudioLevelInfo) + GadgetHeight(\cntAudioLevelInfo)
    Else
      setVisible(\cntAudioLevelInfo, #False)
      nTop = GadgetY(\cntAudioLevelInfo)
    EndIf
    ResizeGadget(\cntNewValues, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    
    WBE_setupGrdBulkEdit()
    WBE_populateGrdBulkEdit()
    
    WBE_setButtons()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s WBE_decodeEnabled(bCueEnabled)
  If bCueEnabled
    ProcedureReturn Lang("WBE", "Enabled")          ; returns "Enabled"
  Else
    ProcedureReturn UCase(Lang("WBE", "Disabled"))  ; returns "DISABLED"
  EndIf
EndProcedure

Procedure.s WBE_decodeWarnBeforeEnd(bWarnBeforeEnd)
  If bWarnBeforeEnd
    ProcedureReturn Lang("WBE", "Warning")
  Else
    ProcedureReturn Lang("WBE", "NoWarning")
  EndIf
EndProcedure

Procedure.s WBE_decodeBoolean(nItemCode, bItemValue)
  Protected sDecodedItem.s
  If bItemValue
    Select nItemCode
      Case #SCS_BE_EXCL_CUE
        sDecodedItem = Lang("WBE", "Exclusive")
      Case #SCS_BE_SFR_COMPLETE_ASSOC
        sDecodedItem = Lang("WBE", "Complete")
      Case #SCS_BE_SFR_GO_NEXT
        sDecodedItem = Lang("WBE", "GoNext")
      Case #SCS_BE_SFR_HOLD_ASSOC
        sDecodedItem = Lang("WBE", "DoNotStart")
      Case #SCS_BE_QA_PAUSE_AT_END
        sDecodedItem = Lang("WQA", "chkPauseAtEnd")
      Case #SCS_BE_QA_REPEAT
        sDecodedItem = Lang("WQA", "chkPLRepeat")
    EndSelect
  EndIf
  ProcedureReturn sDecodedItem
EndProcedure

Procedure WBE_setButtons()
  PROCNAMEC()
  Protected nRow
  Protected nRowCount, nRowsChecked
  Protected n
  Protected bEnableApply
  
  With WBE
    
    nRowCount = CountGadgetItems(\grdBulkEdit)
    For nRow = 0 To (nRowCount-1)
      If GetGadgetItemState(\grdBulkEdit, nRow) & #PB_ListIcon_Checked
        nRowsChecked + 1
      EndIf
    Next nRow
    
    If nRowCount = 0 Or nRowsChecked = nRowCount
      setEnabled(\btnSelectAll, #False)
    Else
      setEnabled(\btnSelectAll, #True)
    EndIf
    
    If nRowsChecked = 0
      setEnabled(\btnClearAll, #False)
    Else
      setEnabled(\btnClearAll, #True)
    EndIf
    
    For n = 0 To (grWBE\nBERowCount - 1)
      If gaBulkEditItem(n)\bSelected
        If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
          If gaBulkEditItem(n)\bIntegrated
            bEnableApply = #True
          EndIf
        Else
          If gaBulkEditItem(n)\sNewDispValue <> gaBulkEditItem(n)\sOldDispValue
            bEnableApply = #True
          EndIf
        EndIf
      EndIf
      If bEnableApply
        Break
      EndIf
    Next n
    setEnabled(\btnApply, bEnableApply)
    
  EndWith
EndProcedure

Procedure WBE_colorRows()
  PROCNAMEC()
  Protected n, nBackColor, nTextColor, nNormToApply
  Protected bDisplayCappedWarning
  
  nTextColor = #SCS_Black
  nNormToApply = getCurrentItemData(WBE\cboNormToApply)
  
  For n = 0 To (grWBE\nBERowCount - 1)
    If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
      nBackColor = grWBE\nNoChangeColor
      SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, nBackColor, -1)
      SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_FrontColor, nTextColor, -1)
      With gaBulkEditItem(n)
        If \bSelected
          If nNormToApply = #SCS_NORMALIZE_LUFS
            If \sIntegratedValue <> \sOldDispValue
              If convertBVLevelToDBLevel(\fIntegratedValue) > grProd\nMaxDBLevel
                SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nCappedColor, grWBE\nColNoNew)
                bDisplayCappedWarning = #True
              Else
                SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nChangeColor, grWBE\nColNoNew)
              EndIf
            EndIf
          Else
            SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nIgnoredColor, grWBE\nColNoNew)
          EndIf
          CompilerIf #c_include_peak
            If nNormToApply = #SCS_NORMALIZE_PEAK
              If \sPeakValue <> \sOldDispValue
                If convertBVLevelToDBLevel(\fPeakValue) > grProd\nMaxDBLevel
                  SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nCappedColor, grWBE\nColNoNew+1)
                  bDisplayCappedWarning = #True
                Else
                  SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nChangeColor, grWBE\nColNoNew+1)
                EndIf
              EndIf
            Else
              SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nIgnoredColor, grWBE\nColNoNew+1)
            EndIf
          CompilerEndIf
          If nNormToApply = #SCS_NORMALIZE_TRUE_PEAK
            If \sTruePeakValue <> \sOldDispValue
              If convertBVLevelToDBLevel(\fTruePeakValue) > grProd\nMaxDBLevel
                SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nCappedColor, grWBE\nColNoNew+1) ; NB "grWBE\nColNoNew+1" should be "grWBE\nColNoNew+2" if #c_include_peak = #True
                bDisplayCappedWarning = #True
              Else
                SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nChangeColor, grWBE\nColNoNew+1)
              EndIf
            EndIf
          Else
            SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, grWBE\nIgnoredColor, grWBE\nColNoNew+1)
          EndIf
        EndIf
      EndWith
    Else
      With gaBulkEditItem(n)
        nBackColor = grWBE\nNoChangeColor
        If \bSelected
          If \sNewDispValue <> \sOldDispValue
            If \bCapped
              nBackColor = grWBE\nCappedColor
              bDisplayCappedWarning = #True
            ElseIf \bIgnored
              nBackColor = grWBE\nIgnoredColor
            Else
              nBackColor = grWBE\nChangeColor
            EndIf
          EndIf
        EndIf
      EndWith
      SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_BackColor, nBackColor, -1)
      SetGadgetItemColor(WBE\grdBulkEdit, n, #PB_Gadget_FrontColor, nTextColor, -1)
    EndIf
  Next n
  
  setVisible(WBE\lblCappedLevelWarning, bDisplayCappedWarning)
  
EndProcedure

Procedure WBE_populateNewValueForRow(nRow)
  PROCNAMEC()
  Protected sTmp.s
  Protected bMyNewValue, bMyNewContinuous
  Protected sMyNewValue.s
  Protected nMyNewValue
  Protected dMydBChange.d, dNewLevel.d, fNewValue.f
  Protected fIntegratedValue.f, fPeakValue,f, fTruePeakValue.f
  Protected dTmpdB.d
  Protected bUseNewLevel, bUseNewValue
  Protected j, k, nImageCount, nContinuousCount, nDisplayTimeCount, nMinDisplayTime, nMaxDisplayTime, bFirstTime, nTime
  Protected sActualValue.s
  
  ; debugMsg(sProcName, #SCS_START + ", nRow=" + nRow)
  
  With WBE
    Select grWBE\nBEField
      Case #SCS_BE_CUE_ENABLED, #SCS_BE_EXCL_CUE, #SCS_BE_WARN_B4_END,
           #SCS_BE_SFR_COMPLETE_ASSOC, #SCS_BE_SFR_HOLD_ASSOC, #SCS_BE_SFR_GO_NEXT,
           #SCS_BE_QA_PAUSE_AT_END, #SCS_BE_QA_REPEAT
        bMyNewValue = GetGadgetState(\chkNewValue)
        
      Case #SCS_BE_HIDE_CUE_OPT
        If GGS(\cboNewValue) < 0
          nMyNewValue = #SCS_HIDE_NO
        Else
          nMyNewValue = getCurrentItemData(\cboNewValue)
        EndIf
        
      Case #SCS_BE_FADE_IN_TYPE, #SCS_BE_FADE_OUT_TYPE, #SCS_BE_LVL_CHG_TYPE
        If GetGadgetState(\cboNewValue) < 0
          nMyNewValue = #SCS_FADE_STD
        Else
          nMyNewValue = getCurrentItemData(\cboNewValue)
        EndIf
        
      Case #SCS_BE_AUDIO_LEVELS
        If grWBE\nChangeType = #SCS_BECT_NORMALIZE
          If gaBulkEditItem(nRow)\bIgnored = #False
            fIntegratedValue = gaBulkEditItem(nRow)\fIntegratedValue
            CompilerIf #c_include_peak
              fPeakValue = gaBulkEditItem(nRow)\fPeakValue
            CompilerEndIf
            fTruePeakValue = gaBulkEditItem(nRow)\fTruePeakValue
            bUseNewValue = #False
          EndIf
        Else
          sMyNewValue = Trim(GGT(\txtNewValue))
          If sMyNewValue
            ; \txtNewValue must be present for ANY audio level change type to be actioned
            Select grWBE\nChangeType
              Case #SCS_BECT_CHANGE_IN_LEVEL
                dMydBChange = ValD(sMyNewValue)
              Case #SCS_BECT_NEW_LEVEL
                If UCase(sMyNewValue) = UCase(#SCS_INF_DBLEVEL)
                  dNewLevel = grLevels\fSilentBVLevel
                Else
                  dNewLevel = ValD(sMyNewValue)
                EndIf
                bUseNewLevel = #True
            EndSelect
          EndIf
        EndIf
        
      Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_REL_START_TIME
        nMyNewValue = stringToTime(GGT(\txtNewValue))
        If nMyNewValue = 0
          nMyNewValue = -2
        EndIf
        
      Case #SCS_BE_QA_DISPLAY_TIME
        nMyNewValue = stringToTime(GGT(\txtNewValue))
        If GGS(\chkContinuous) = #PB_Checkbox_Checked
          bMyNewContinuous = #True
        EndIf
        j = gaBulkEditItem(nRow)\nPtr
        If gaBulkEditItem(nRow)\bSelected
          If bMyNewContinuous And aSub(j)\bPLRepeat
            ; Repeat and Continuous are mutually exclusive
            valErrMsg(WBE\chkContinuous, getSubLabel(j) + ": " + Lang("Errors", "ContNotWithRepeat"))
            ProcedureReturn #False
          EndIf
        EndIf
        If bMyNewContinuous = #False
          nDisplayTimeCount = 1
          nMinDisplayTime = nMyNewValue
          nMaxDisplayTime = nMyNewValue
        Else ; bMyNewContinuous = #True
          nDisplayTimeCount = 0
          nMinDisplayTime = 0
          nMaxDisplayTime = 0
          bFirstTime = #True
          bMyNewValue = #True ; for 'continuous'
          If j >= 0
            ; should be #True
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
                If aAud(k)\nNextAudIndex < 0
                  ; final aAud() for this aSub()
                  nContinuousCount + 1
                Else
                  nDisplayTimeCount + 1
                  nTime = aAud(k)\nEndAt
                  If nTime >= 0
                    If (nTime < nMinDisplayTime) Or (bFirstTime)
                      nMinDisplayTime = nTime
                      bFirstTime = #False
                    EndIf
                    If nTime > nMaxDisplayTime
                      nMaxDisplayTime = nTime
                    EndIf
                  EndIf
                EndIf
              EndIf ; EndIf aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf ; EndIf j >= 0
        EndIf ; EndIf bMyNewContinuous = #False / Else
        sMyNewValue = ""
        If nDisplayTimeCount > 0
          sMyNewValue = timeToString(nMinDisplayTime)
          If nMaxDisplayTime > nMinDisplayTime
            sMyNewValue + " - " + timeToString(nMaxDisplayTime)
          EndIf
          If nContinuousCount > 0
            sMyNewValue + ", & "
          EndIf
        EndIf
        If nContinuousCount > 0
          sMyNewValue + Lang("WQA", "chkContinuous")
        EndIf
        
      Case #SCS_BE_PAGE_NO
        sMyNewValue = Trim(GGT(\txtNewValue))
        
    EndSelect
  EndWith
  
  If (nRow >= 0) And (nRow < CountGadgetItems(WBE\grdBulkEdit))
    With gaBulkEditItem(nRow)
      If \bSelected = #False
        \nNewValue = \nOldValue
        \fNewValue = \fOldValue
        \sNewValue = \sOldValue
        \bNewValue = \bOldValue
        \sNewDispValue = \sOldDispValue
        \sIntegratedValue = ""
        \sPeakValue = ""
        \sTruePeakValue = ""
        \bCapped = #False
        \bIgnored = #False
        
      ElseIf \bIgnored = #False
        Select grWBE\nBEField
          Case #SCS_BE_CUE_ENABLED   ; #SCS_BE_CUE_ENABLED
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeEnabled(\bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_EXCL_CUE   ; #SCS_BE_EXCL_CUE
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_EXCL_CUE, \bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_PAGE_NO   ; #SCS_BE_PAGE_NO
            \sNewValue = sMyNewValue
            \sNewDispValue = \sNewValue
            \bCapped = #False
            
          Case #SCS_BE_WARN_B4_END   ; #SCS_BE_WARN_B4_END
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeWarnBeforeEnd(\bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_HIDE_CUE_OPT   ; #SCS_BE_HIDE_CUE_OPT
            \nNewValue = nMyNewValue
            \sNewDispValue = decodeHideCueOptL(\nNewValue)
            \bCapped = #False
            
          Case #SCS_BE_FADE_IN_TYPE, #SCS_BE_FADE_OUT_TYPE, #SCS_BE_LVL_CHG_TYPE  ; #SCS_BE_FADE_IN_TYPE, #SCS_BE_FADE_OUT_TYPE, #SCS_BE_LVL_CHG_TYPE
            \nNewValue = nMyNewValue
            \sNewDispValue = decodeFadeTypeL(\nNewValue)
            \bCapped = #False
            
          Case #SCS_BE_AUDIO_LEVELS   ; #SCS_BE_AUDIO_LEVELS
            If grWBE\nChangeType = #SCS_BECT_NORMALIZE
              \bCapped = #False
              If \fIntegratedValue > grLevels\fMaxBVLevel
                sActualValue = " (" + convertBVLevelToDBString(\fIntegratedValue) + ")"
                \sIntegratedValue = convertBVLevelToDBString(grLevels\fMaxBVLevel) + sActualValue
              Else
                \sIntegratedValue = convertBVLevelToDBString(\fIntegratedValue)
              EndIf
              ; debugMsg0(sProcName, "\sIntegratedValue=" + \sIntegratedValue)
              CompilerIf #c_include_peak
                If \fPeakValue > grLevels\fMaxBVLevel
                  sActualValue = " (" + convertBVLevelToDBString(\fPeakValue) + ")"
                  \sPeakValue = convertBVLevelToDBString(grLevels\fMaxBVLevel) + sActualValue
                Else
                  \sPeakValue = convertBVLevelToDBString(\fPeakValue)
                EndIf
              CompilerEndIf
              If \fTruePeakValue > grLevels\fMaxBVLevel
                sActualValue = " (" + convertBVLevelToDBString(\fTruePeakValue) + ")"
                \sTruePeakValue = convertBVLevelToDBString(grLevels\fMaxBVLevel) + sActualValue
              Else
                \sTruePeakValue = convertBVLevelToDBString(\fTruePeakValue)
              EndIf
            Else
              \bCapped = #False
              If Len(\sOldValue) = 0 Or \sOldValue = grLevels\sMaxDBLevel
                dTmpdB = ValD(grLevels\sMaxDBLevel)
              ElseIf (\sOldValue = grLevels\sMinDBLevel) Or (\sOldValue = #SCS_INF_DBLEVEL)
                dTmpdB = ValD(grLevels\sMinDBLevel)
              Else
                dTmpdB = ValD(\sOldValue)
              EndIf
              If dTmpdB < ValD(grLevels\sMinDBLevel)
                dTmpdB = ValD(grLevels\sMinDBLevel)
              ElseIf dTmpdB > ValD(grLevels\sMaxDBLevel)
                dTmpdB = ValD(grLevels\sMaxDBLevel)
              EndIf
              
              If bUseNewLevel
                dTmpdB = dNewLevel
              Else
                dTmpdB + dMydBChange
              EndIf
              
              If dTmpdB < ValD(grLevels\sMinDBLevel)
                dTmpdB = ValD(grLevels\sMinDBLevel)
                \bCapped = #True
              ElseIf dTmpdB > ValD(grLevels\sMaxDBLevel)
                dTmpdB = ValD(grLevels\sMaxDBLevel)
                \bCapped = #True
              EndIf
              
              \fNewValue = dTmpdB
              If \fNewValue = ValF(grLevels\sMinDBLevel)
                \sNewValue = #SCS_INF_DBLEVEL
              Else
                \sNewValue = StrF(\fNewValue, 1)
              EndIf
              \sNewDispValue = \sNewValue
            EndIf
            
          Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_REL_START_TIME
            \nNewValue = nMyNewValue
            \sNewDispValue = timeToString(\nNewValue)
            \bCapped = #False
            
          Case #SCS_BE_QA_DISPLAY_TIME
            \nNewValue = nMyNewValue
            \bNewValue = bMyNewValue
            \sNewDispValue = sMyNewValue
            \bCapped = #False
            
          Case #SCS_BE_SFR_COMPLETE_ASSOC ; #SCS_BE_SFR_COMPLETE_ASSOC
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_COMPLETE_ASSOC, \bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_SFR_HOLD_ASSOC ; #SCS_BE_SFR_HOLD_ASSOC
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_HOLD_ASSOC, \bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_SFR_GO_NEXT ; #SCS_BE_SFR_GO_NEXT
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_SFR_GO_NEXT, \bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_QA_PAUSE_AT_END ; #SCS_BE_QA_PAUSE_AT_END
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_QA_PAUSE_AT_END, \bNewValue)
            \bCapped = #False
            
          Case #SCS_BE_QA_REPEAT ; #SCS_BE_QA_REPEAT
            \bNewValue = bMyNewValue
            \sNewDispValue = WBE_decodeBoolean(#SCS_BE_QA_REPEAT, \bNewValue)
            \bCapped = #False
            
        EndSelect
      EndIf
      
      If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
        SetGadgetItemText(WBE\grdBulkEdit, nRow, \sIntegratedValue, grWBE\nColNoNew)
        CompilerIf #c_include_peak
          SetGadgetItemText(WBE\grdBulkEdit, nRow, \sPeakValue, grWBE\nColNoNew+1)
          SetGadgetItemText(WBE\grdBulkEdit, nRow, \sTruePeakValue, grWBE\nColNoNew+2)
        CompilerElse
          SetGadgetItemText(WBE\grdBulkEdit, nRow, \sTruePeakValue, grWBE\nColNoNew+1)
        CompilerEndIf
      Else
        SetGadgetItemText(WBE\grdBulkEdit, nRow, \sNewDispValue, grWBE\nColNoNew)
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure WBE_populateNewValuesForAllRows()
  PROCNAMEC()
  Protected nRow
  
  For nRow = 0 To (CountGadgetItems(WBE\grdBulkEdit)-1)
    WBE_populateNewValueForRow(nRow)
  Next nRow
  
  WBE_colorRows()
  
  If grWBE\nBEField = #SCS_BE_CUE_ENABLED
    SGT(WBE\txtTotalPlayLength, timeToString(WBE_calcTotalPlayLength(), 0, #True))
    setVisible(WBE\lblTotalPlayLength, #True)
    setVisible(WBE\txtTotalPlayLength, #True)
  Else
    setVisible(WBE\lblTotalPlayLength, #False)
    setVisible(WBE\txtTotalPlayLength, #False)
  EndIf
  
EndProcedure

Procedure WBE_txtNewValue_Validate()
  PROCNAMEC()
  Protected sNewValue.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWBE\bInFieldChange
    ProcedureReturn
  EndIf
  
  If grWBE\bInValidate
    ProcedureReturn
  EndIf
  grWBE\bInValidate = #True
  
  sNewValue = Trim(GGT(WBE\txtNewValue))
  
  Select grWBE\nBEField
    Case #SCS_BE_AUDIO_LEVELS
      If sNewValue <> UCase(sNewValue)
        sNewValue = UCase(sNewValue)  ; to convert -inf to -INF
        SGT(WBE\txtNewValue, sNewValue)
      EndIf
      Select grWBE\nChangeType
        Case #SCS_BECT_CHANGE_IN_LEVEL
          If validateDbChangeField(sNewValue, GGT(WBE\lblNewValue)) = #False
            grWBE\bInValidate = #False
            ProcedureReturn #False
          EndIf
        Case #SCS_BECT_NEW_LEVEL
          If validateDbField(sNewValue, GGT(WBE\lblNewValue)) = #False
            grWBE\bInValidate = #False
            ProcedureReturn #False
          EndIf
          debugMsg(sProcName, "GGT(WBE\txtNewValue)=" + GGT(WBE\txtNewValue))
;         Case #SCS_BECT_NORMALIZE
;           If validateDbField(sNewValue, GGT(WBE\lblNewValue), #False, #False) = #False
;             grWBE\bInValidate = #False
;             ProcedureReturn #False
;           EndIf
;           WBE_applyNormalization()
      EndSelect
      
    Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME, #SCS_BE_SFR_TIME_OVERRIDE, #SCS_BE_REL_START_TIME, #SCS_BE_QA_DISPLAY_TIME
      If WBE_validateNewValue() = #False
        grWBE\bInValidate = #False
        ProcedureReturn #False
      EndIf
      
  EndSelect
  
  debugMsg(sProcName, "calling WBE_populateNewValuesForAllRows()")
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  
  grWBE\bInValidate = #False
  ProcedureReturn #True
  
EndProcedure

Procedure WBE_txtMaxLevel_Validate()
  PROCNAMEC()
  Protected sMaxLevel.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grWBE\bInFieldChange
    ProcedureReturn
  EndIf
  
  If grWBE\bInValidate
    ProcedureReturn
  EndIf
  grWBE\bInValidate = #True
  
  sMaxLevel = Trim(GGT(WBE\txtMaxLevel))
  
  Select grWBE\nBEField
    Case #SCS_BE_AUDIO_LEVELS
      If sMaxLevel <> UCase(sMaxLevel)
        sMaxLevel = UCase(sMaxLevel)  ; to convert -inf to -INF
        SGT(WBE\txtMaxLevel, sMaxLevel)
      EndIf
      Select grWBE\nChangeType
        Case #SCS_BECT_NORMALIZE
          If validateDbField(sMaxLevel, GGT(WBE\lblMaxLevel), #False, #False) = #False
            grWBE\bInValidate = #False
            ProcedureReturn #False
          EndIf
          WBE_applyNormalization()
      EndSelect
  EndSelect
  
  debugMsg(sProcName, "calling WBE_populateNewValuesForAllRows()")
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
  
  grWBE\bInValidate = #False
  ProcedureReturn #True
  
EndProcedure

Procedure WBE_chkContinuous_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling WBE_populateNewValuesForAllRows()")
  WBE_populateNewValuesForAllRows()
  WBE_setButtons()
EndProcedure

Procedure WBE_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WBE) = #False
    WBE_Form_Load()
  EndIf
  setWindowModal(#WBE, bModal)
  setWindowVisible(#WBE, #True)
  SetActiveWindow(#WBE)
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WBE_Form_Unload()
  getFormPosition(#WBE, @grBulkEditWindow)
  unsetWindowModal(#WBE)
  scsCloseWindow(#WBE)
EndProcedure

Procedure WBE_setupGrdBulkEdit()
  PROCNAMEC()
  Protected n
  Protected sPad.s = Space(6)
  Protected nDeviceWidth
  Protected nIntegratedLevelWidth, nOtherLevelWidth
  Protected nReqdGridWidth, nReqdWindowWidth
  Protected nDerivedHdgX, nDerivedHdgWidth, bDisplayDerivedHdg
  
  debugMsg(sProcName, #SCS_START)
  
  With WBE
    ; remove all columns except the "Select" column (column 0)
    For n = grWBE\nMaxColNo To 1 Step -1
      RemoveGadgetColumn(\grdBulkEdit, n)
    Next n
    
    nReqdGridWidth = grWBE\nDefaultGridWidth
    nReqdWindowWidth = grWBE\nDefaultWindowWidth
    
    If StartDrawing(WindowOutput(#WBE))
      DrawingFont(GetGadgetFont(WBE\grdBulkEdit))
      
      ; AddGadgetColumn(\grdBulkEdit, 1, grText\sTextCue, TextWidth("Q 999S"+sPad))
      AddGadgetColumn(\grdBulkEdit, 1, grText\sTextCue, TextWidth("Q123<2>"+sPad))
      AddGadgetColumn(\grdBulkEdit, 2, grText\sTextDescription, TextWidth("This is a description of a Show Cue"))
      AddGadgetColumn(\grdBulkEdit, 3, Lang("WBE","CueType"), TextWidth("Level Change"+sPad))
      
      If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS
        nDeviceWidth = TextWidth(grText\sTextDevice+sPad)
        DrawingFont(FontID(#SCS_FONT_GEN_BOLD))
        nIntegratedLevelWidth = TextWidth("Integrated LUFS"+sPad) ; NB use hard-coded "Integrated LUFS" to determine level width, not Lang(...), as translated text could be MUCH larger.
        nOtherLevelWidth = TextWidth("Old dB Level"+sPad)
        DrawingFont(FontID(#SCS_FONT_GEN_NORMAL))
        Select grWBE\nChangeType
          Case #SCS_BECT_NORMALIZE
            AddGadgetColumn(\grdBulkEdit, 4, grText\sTextDevice, nDeviceWidth)
            AddGadgetColumn(\grdBulkEdit, 5, Lang("WBE","OldLevel"), nOtherLevelWidth)
            grWBE\nColNoOld = 5
            AddGadgetColumn(\grdBulkEdit, 6, Lang("WBE","IntegratedLUFS"), nIntegratedLevelWidth)
            CompilerIf #c_include_peak
              AddGadgetColumn(\grdBulkEdit, 7, Lang("WBE","Peak"), nOtherLevelWidth)
              AddGadgetColumn(\grdBulkEdit, 8, Lang("WBE","TruePeak"), nOtherLevelWidth)
              grWBE\nColNoNew = 6
              grWBE\nMaxColNo = 8
            CompilerElse
              AddGadgetColumn(\grdBulkEdit, 7, Lang("WBE","TruePeak"), nOtherLevelWidth)
              grWBE\nColNoNew = 6
              grWBE\nMaxColNo = 7
            CompilerEndIf
            nReqdGridWidth + (nOtherLevelWidth + nIntegratedLevelWidth)
            nReqdWindowWidth + (nOtherLevelWidth + nIntegratedLevelWidth)
            CompilerIf #c_include_peak
              nDerivedHdgWidth = (nOtherLevelWidth * 2) + nIntegratedLevelWidth
            CompilerElse
              nDerivedHdgWidth = nOtherLevelWidth + nIntegratedLevelWidth
            CompilerEndIf
            nDerivedHdgX = GadgetX(\grdBulkEdit) + nReqdGridWidth - nDerivedHdgWidth - gl3DBorderWidth
            If grWBE\nBERowCount > 20
              ; Assume vertical scrollbar is displayed - can't find out how to check that condition by code ;-(
              nDerivedHdgX - glScrollBarWidth
            EndIf
            bDisplayDerivedHdg = #True
          Default
            AddGadgetColumn(\grdBulkEdit, 4, grText\sTextDevice, nDeviceWidth)
            AddGadgetColumn(\grdBulkEdit, 5, Lang("WBE","OldLevel"), nOtherLevelWidth)
            grWBE\nColNoOld = 5
            AddGadgetColumn(\grdBulkEdit, 6, Lang("WBE","NewLevel"), nOtherLevelWidth)
            grWBE\nColNoNew = 6
            grWBE\nMaxColNo = 6
        EndSelect
      Else
        AddGadgetColumn(\grdBulkEdit, 4, grText\sTextActivation, TextWidth("0.00 ae Prev"+sPad))
        AddGadgetColumn(\grdBulkEdit, 5, Lang("WBE","OldValue"), TextWidth("Do not start"+sPad))
        grWBE\nColNoOld = 5
        AddGadgetColumn(\grdBulkEdit, 6, Lang("WBE","NewValue"), TextWidth("Do not start"+sPad))
        grWBE\nColNoNew = 6
        grWBE\nMaxColNo = 6
      EndIf
      
      If WindowWidth(#WBE) <> nReqdWindowWidth
        ResizeWindow(#WBE, #PB_Ignore, #PB_Ignore, nReqdWindowWidth, #PB_Ignore)
      EndIf
      If GadgetWidth(\grdBulkEdit) <> nReqdGridWidth
        ResizeGadget(\grdBulkEdit, #PB_Ignore, #PB_Ignore, nReqdGridWidth, #PB_Ignore)
      EndIf
      If bDisplayDerivedHdg
        ResizeGadget(\lblNewLevelDerived, nDerivedHdgX, #PB_Ignore, nDerivedHdgWidth, #PB_Ignore)
        SetGadgetColor(\lblNewLevelDerived, #PB_Gadget_BackColor, #SCS_White)
      EndIf
      setVisible(\lblNewLevelDerived, bDisplayDerivedHdg)
      
      autoFitGridCol(\grdBulkEdit, 2) ; autofit Description column
      
      StopDrawing()
    EndIf
    
  EndWith
  
EndProcedure

Procedure WBE_populateGrdBulkEdit()
  PROCNAMEC()
  Protected n, sText.s, nCuePtr
  
  With WBE
    ClearGadgetItems(\grdBulkEdit)
    For n = 0 To (grWBE\nBERowCount - 1)
      sText = ""   ; 'select' column
      sText + Chr(10) + gaBulkEditItem(n)\sLabel
      sText + Chr(10) + gaBulkEditItem(n)\sDescr
      sText + Chr(10) + gaBulkEditItem(n)\sCueType
      If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS
        sText + Chr(10) + gaBulkEditItem(n)\sDevice
      Else
        nCuePtr = gaBulkEditItem(n)\nCuePtr
        sText + Chr(10) + getCueActivationMethodForDisplay(nCuePtr)
      EndIf
      sText + Chr(10) + gaBulkEditItem(n)\sOldDispValue
      If grWBE\nBEField = #SCS_BE_AUDIO_LEVELS And grWBE\nChangeType = #SCS_BECT_NORMALIZE
        sText + Chr(10) + gaBulkEditItem(n)\sIntegratedValue
        sText + Chr(10) + gaBulkEditItem(n)\sPeakValue
        sText + Chr(10) + gaBulkEditItem(n)\sTruePeakValue
      Else
        sText + Chr(10) + gaBulkEditItem(n)\sNewDispValue
      EndIf
      AddGadgetItem(\grdBulkEdit, -1, sText)
    Next n
    WBE_populateNewValuesForAllRows()
    autoFitGridCol(\grdBulkEdit, 2) ; autofit Description column
  EndWith
  
EndProcedure

Procedure WBE_EventHandler()
  PROCNAMEC()
  
  With WBE
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WBE_Form_Unload()
        
      Case #PB_Event_Gadget
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnApply
            WBE_btnApply_Click()
            
          Case \btnCancel
            WBE_Form_Unload()
            
          Case \btnOK
            WBE_btnOK_Click()
            
          Case \btnViewChanges
            WBE_btnViewChanges_Click()
            
          Case \cboChangeType
            CBOCHG(WBE_cboChangeType_Click())
            
          Case \cboDevice
            CBOCHG(WBE_cboDevice_Click())
            
          Case \cboField
            CBOCHG(WBE_cboField_Click())
            
          Case \cboLUFS
            CBOCHG(WBE_cboLUFS_Click())
            
          Case \cboNewValue
            CBOCHG(WBE_cboNewValue_Click())
            
          Case \cboNormToApply
            CBOCHG(WBE_cboNormToApply_Click())
            
          Case \chkContinuous
            WBE_chkContinuous_Click()
            
          Case \chkNewValue
            WBE_chkNewValue_Click()
            
          Case \btnClearAll
            WBE_btnClearAll_Click()
            
          Case \btnHelp
            WBE_btnHelp_Click()
            
          Case \btnSelectAll
            WBE_btnSelectAll_Click()
            
          Case \grdBulkEdit
            If gnEventType = #PB_EventType_LeftClick
              WBE_grdBulkEdit_LeftClick()
            EndIf
            
          Case \txtMaxLevel
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WBE_txtMaxLevel_Validate())
            EndIf
            
          Case \txtNewValue
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WBE_txtNewValue_Validate())
            EndIf
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WBE_getNewEnabledForCue(sCue.s)
  PROCNAMEC()
  Protected n, bEnabled
  
  For n = 0 To (grWBE\nBERowCount-1)
    If gaBulkEditItem(n)\sLabel = sCue
      bEnabled = gaBulkEditItem(n)\bNewValue
      Break
    EndIf
  Next n
  
  ProcedureReturn bEnabled
  
EndProcedure

Procedure WBE_calcTotalPlayLength()
  PROCNAMEC()
  Protected i, j, k
  Protected bWantThisCue
  Protected nCuePlayLength
  Protected nTotalPlayLength
  Protected nThisSubEndTime
  Protected nPrevSubEndTime
  Protected sCue.s
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    bWantThisCue = #False
    sCue = aCue(i)\sCue
    j = aCue(i)\nFirstSubIndex
    If j >= 0
      If aSub(j)\nNextSubIndex >= 0
        sCue + "+"
      EndIf
    EndIf
    If WBE_getNewEnabledForCue(sCue)
      Select aCue(i)\nActivationMethod
        Case #SCS_ACMETH_MAN, #SCS_ACMETH_MAN_PLUS_CONF
          bWantThisCue = #True
        Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
          Select aCue(i)\nAutoActPosn
            Case #SCS_ACPOSN_LOAD, #SCS_ACPOSN_AE, #SCS_ACPOSN_BE
              bWantThisCue = #True
          EndSelect
      EndSelect
      If bWantThisCue
        nCuePlayLength = 0
        nPrevSubEndTime = 0
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeF
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\nFileFormat <> #SCS_FILEFORMAT_MIDI
                If aSub(j)\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB
                  nThisSubEndTime = nPrevSubEndTime + aAud(k)\nCueDuration + aSub(j)\nRelStartTime
                Else
                  nThisSubEndTime = aAud(k)\nCueDuration + aSub(j)\nRelStartTime
                EndIf
                If nThisSubEndTime > nCuePlayLength
                  nCuePlayLength = nThisSubEndTime
                EndIf
                nPrevSubEndTime = nThisSubEndTime
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        ; debugMsg(sProcName, "sCue=" + sCue + ", bWantThisCue=" + strB(bWantThisCue) + ", nCuePlayLength=" + nCuePlayLength)
        nTotalPlayLength + nCuePlayLength
      EndIf
    EndIf
  Next i
  debugMsg(sProcName, #SCS_END + ", nTotalPlayLength=" + nTotalPlayLength)
  ProcedureReturn nTotalPlayLength
EndProcedure

Procedure WBE_validateNewValue()
  PROCNAMEC()
  Protected sNewValue.s, bContinuous, bBlankOK
  
  With WBE
    sNewValue = Trim(GGT(\txtNewValue))
    Select grWBE\nBEField
      Case #SCS_BE_QA_DISPLAY_TIME
        If GGS(\chkContinuous) = #PB_Checkbox_Checked
          bContinuous = #True
        EndIf
      Case #SCS_BE_FADE_IN_TIME, #SCS_BE_FADE_OUT_TIME
        ; Added 11Dec2022 11.10.0ac
        bBlankOK = #True
    EndSelect
    
    If Len(sNewValue) = 0 And bContinuous = #False And bBlankOK = #False
      valErrMsg(\txtNewValue, LangPars("Errors", "MustBeEntered", GGT(\lblNewValue)))
      ProcedureReturn #False
    EndIf
    
    If sNewValue
      If validateTimeField(sNewValue, GGT(\lblNewValue), #False, #False, 0, #True) = #False
        ProcedureReturn #False
      ElseIf GGT(\txtNewValue) <> gsTmpString
        SGT(\txtNewValue, gsTmpString)
      EndIf
    EndIf
    
    If sNewValue And bContinuous
      valErrMsg(WBE\txtNewValue, Lang("WBE", "QADisplayTimeOrContinuous"))
      ProcedureReturn #False
    EndIf
    
  EndWith
  ProcedureReturn #True
EndProcedure

; EOF
