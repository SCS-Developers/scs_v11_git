; File: fmEditQA.pbi

EnableExplicit

Procedure WQA_displayAudioGraphIfReqd()
  PROCNAMECA(nEditAudPtr)
  Protected nFileDataPtr, bLoadResult, bSaveToTempDatabase, nReqdInnerWidth
  
  ; debugMsg0(sProcName, #SCS_START)
  
  If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\sFileName=" + GetFilePart(aAud(nEditAudPtr)\sFileName))
    nFileDataPtr = aAud(nEditAudPtr)\nFileDataPtr
    ; debugMsg(sProcName, "nFileDataPtr=" + nFileDataPtr)
    If nFileDataPtr >= 0
      ; debugMsg(sProcName, "calling calcViewStartAndEnd(@grMG5, " + getAudLabel(nEditAudPtr) + ")")
      calcViewStartAndEnd(@grMG5, nEditAudPtr)
      nReqdInnerWidth = GadgetWidth(WQA\cvsGraphQA)
      ; debugMsg(sProcName, "GadgetWidth(WQA\cvsGraphQA) returned " + nReqdInnerWidth)
      If aSub(nEditSubPtr)\sVidAudLogicalDev
        grMG5\bDeviceAssigned = #True
        ; debugMsg(sProcName, "grMG5\bDeviceAssigned=#True")
      Else
        grMG5\bDeviceAssigned = #False
        ; debugMsg(sProcName, "grMG5\bDeviceAssigned=#False")
      EndIf
      ; debugMsg(sProcName, "calling setGraphChannelsForLogicalDev(5, aSub(" + getSubLabel(nEditSubPtr) + ")\sVidAudLogicalDev)")
      setGraphChannelsForLogicalDev(5, aSub(nEditSubPtr)\sVidAudLogicalDev)
      ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(@grMG5, " + nFileDataPtr + ", " + nReqdInnerWidth + ", " + getAudLabel(nEditAudPtr) + ")")
      bLoadResult = loadSlicePeakAndMinArraysFromDatabase(@grMG5, nFileDataPtr, nReqdInnerWidth, nEditAudPtr)
      ; debugMsg(sProcName, "bLoadResult=" + strB(bLoadResult))
      If bLoadResult = #False
        ; debugMsg(sProcName, "grEditingOptions\nFileScanMaxLengthVideoMS=" + grEditingOptions\nFileScanMaxLengthVideoMS + ", grEditingOptions\nFileScanMaxLengthVideo=" + grEditingOptions\nFileScanMaxLengthVideo)
        If aAud(nEditAudPtr)\nFileDuration <= grEditingOptions\nFileScanMaxLengthVideoMS Or grEditingOptions\nFileScanMaxLengthVideo < 0
          bSaveToTempDatabase = #True
          ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(@grMG5, " + nFileDataPtr + ", " + nReqdInnerWidth + ", " + getAudLabel(nEditAudPtr) + ", " + strB(bSaveToTempDatabase) + ") for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
          loadSlicePeakAndMinArraysFromSamplesArray(@grMG5, nFileDataPtr, nReqdInnerWidth, nEditAudPtr, bSaveToTempDatabase)
        Else
          debugMsg(sProcName, "loadSlicePeakAndMinArraysFromSamplesArray() not called because aAud(" + getAudLabel(nEditAudPtr) + ")\nFileDuration=" + aAud(nEditAudPtr)\nFileDuration + ", and grEditingOptions\nFileScanMaxLengthVideoMS=" + grEditingOptions\nFileScanMaxLengthVideoMS)
        EndIf
      EndIf
    EndIf
    ; debugMsg(sProcName, "calling WQA_initGraphInfo()")
    WQA_initGraphInfo()
    debugMsg(sProcName, "calling prepareAndDisplayGraph(@grMG5, #True)")
    prepareAndDisplayGraph(@grMG5, #True)
  EndIf
  
EndProcedure
  
Procedure WQA_displaySub(pSubPtr, nItemIndex=0, nScrollPos=0)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected nListIndex, n
  Protected bAudStateChanged
  Protected nDisplayPos, bClearImage
  Protected bMuteAudio
  Protected nVidPicTarget
  Protected bMulti
  Protected bVidCapDevsDefined, bVidCapDevsChanged
  Static bFirstTime = #True
  Static bPrevVidCapDevsDefined
  Static sOutputScreenDefTooltip.s, sPreviewText.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", nItemIndex=" + nItemIndex + ", nScrollPos=" + nScrollPos + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If bStaticLoaded = #False
    sOutputScreenDefTooltip = Lang("WQA", "cboOutputScreenTT")
    sPreviewText = LangSpace("WQA", "chkPreviewOnOutputScreen")
    bStaticLoaded = #True
  EndIf
  
  If grCED\bQACreated = #False
    WQA_Form_Load()
  EndIf
  bVidCapDevsDefined = checkif_VidCapDevsDefined()
  If (bFirstTime) Or (bVidCapDevsDefined <> bPrevVidCapDevsDefined)
    bVidCapDevsChanged = #True
    bPrevVidCapDevsDefined = bVidCapDevsDefined
    ; nb bFirstTime will be set to #False at the end of this procedure
  EndIf
  
  If bVidCapDevsChanged
    With WQA
      If bVidCapDevsDefined
        ; at least one video capture device defined
        ClearGadgetItems(\cboVideoSource)
        addGadgetItemWithData(\cboVideoSource, Lang("VIDCAP", "Video/Image File"), #SCS_VID_SRC_FILE)
        addGadgetItemWithData(\cboVideoSource, Lang("VIDCAP", "VideoCapture"), #SCS_VID_SRC_CAPTURE)
        SGS(\cboVideoSource, 0)
      Else
        ; no video capture devices currently defined
        ClearGadgetItems(\cboVideoSource)
        addGadgetItemWithData(\cboVideoSource, Lang("VIDCAP", "Video/Image File"), #SCS_VID_SRC_FILE)
        SGS(\cboVideoSource, 0)
      EndIf
      debugMsg(sProcName, "calling WQA_setVisibleStates(" + getAudLabel(nEditAudPtr) + ")")
      WQA_setVisibleStates(nEditAudPtr)
    EndWith
  EndIf ; EndIf bVidCapDevsChanged
  
  debugMsg(sProcName, "calling WQA_clearCurrentInfo()")
  WQA_clearCurrentInfo()
  
  debugMsg(sProcName, "calling WQA_setPreviewPanel(" + getSubLabel(pSubPtr) + ")")
  WQA_setPreviewPanel(pSubPtr)
  
  ; set sub-cue properties header line
  setSubHeader(WQA\lblSubCueType, pSubPtr)
  
  ; propogate audio devs into logical dev combo boxes if reqd
  propogateProdDevs("A")
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "A", WQA)
    
    SGT(WQA\txtFadeInTime, timeToStringBWZ(\nPLFadeInTime))
    SGT(WQA\txtFadeOutTime, timeToStringBWZ(\nPLFadeOutTime))
    
    setEditAudPtr(\nFirstAudIndex)
    
    ; facility to reposition using sliders not yet implemented
    SLD_setEnabled(WQA\sldProgress[0], #False)
    SLD_setEnabled(WQA\sldProgress[1], #False)
    
    setOwnState(WQA\chkPLRepeat, \bPLRepeat)
    setOwnState(WQA\chkPauseAtEnd, \bPauseAtEnd)
    setOwnState(WQA\chkShowFileFolders, grEditorPrefs\bShowFileFoldersInEditor)
    If gbPreviewOnOutputScreen
      gnPreviewOnOutputScreenNo = \nOutputScreen
      setOwnState(WQA\chkPreviewOnOutputScreen, #True)
    Else
      setOwnState(WQA\chkPreviewOnOutputScreen, #False)
    EndIf
    
    nVidPicTarget = getVidPicTargetForOutputScreen(\nOutputScreen)
    WQA_setIncrements(nVidPicTarget)
    
    WQA_displayDev()
    WQA_fcSldLevelA()
    WQA_fcSldPanA()
    
    If Len(\sScreens) = 0
      loadArrayOutputScreenReqd(pSubPtr)
    EndIf
    ; compactLabel(WQA\lblScreens, \sScreens, 10)
    SGT(WQA\lblScreens, \sScreens)
    If GadgetWidth(WQA\lblScreens, #PB_Gadget_RequiredSize) > GadgetWidth(WQA\lblScreens)
      SGT(WQA\lblScreens, RemoveString(\sScreens, ","))
    EndIf
    setOwnText(WQA\chkPreviewOnOutputScreen, sPreviewText + \nOutputScreen)
    
    If IsGadget(grVidPicTarget(\nOutputScreen)\nTargetCanvasNo) = #False
      ; should only occur on creating a new video/image cue
      gbCallSetVidPicTargets = #True
    EndIf
    
  EndWith
  
  ; about to clear WQAFile() so destroy any existing gadgets associated with WQAFile()
  For n = 0 To gnWQALastItem
    With WQAFile(n)
      If IsGadget(\cntFile)
        setVisible(\cntFile, #False)
      EndIf
      \bSelected = #False
      \nFileAudPtr = -1
      ; debugMsg(sProcName, "WQAFile(" + n + ")\nFileAudPtr=" + getAudLabel(\nFileAudPtr))
      \cntFile = 0
      \nFileNameLen = 0
    EndWith
  Next n
  gnWQALastItem = -1
  gnWQACurrItem = -1
  rWQA\nFirstSelectedItem = 0
  
  k = aSub(pSubPtr)\nFirstAudIndex
  While k >= 0
    ; debugMsg(sProcName, "calling createWQAFile()")
    createWQAFile()   ; add an entry to the array WQAFile() and create the associated gadgets
    WQAFile(gnWQACurrItem)\nFileAudPtr = k
    debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + getAudLabel(WQAFile(gnWQACurrItem)\nFileAudPtr))
    WQAFile(gnWQACurrItem)\nFileNameLen = Len(aAud(k)\sStoredFileName)
    If Trim(aAud(k)\sFileName) Or aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
      With aAud(k)
        ; debugMsg(sProcName, "clear image")
        If StartDrawing(CanvasOutput(WQAFile(gnWQACurrItem)\cvsTimeLineImage))
          Box(0, 0, #SCS_QATIMELINE_IMAGE_WIDTH, #SCS_QATIMELINE_IMAGE_HEIGHT, #SCS_Black)
          StopDrawing()
        EndIf
        If \nVideoSource = #SCS_VID_SRC_CAPTURE
          SGT(WQAFile(gnWQACurrItem)\lblFileName, \sVideoCaptureLogicalDevice)
        Else
          SGT(WQAFile(gnWQACurrItem)\lblFileName, ignoreExtension(GetFilePart(\sFileName)))
        EndIf
        ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nCueDuration=" + \nCueDuration)
        SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
        ; debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\lblDuration=" + GGT(WQAFile(gnWQACurrItem)\lblDuration))
        If \nAudState >= #SCS_CUE_COMPLETED
          debugMsg(sProcName, "calling rewindAud(" + getAudLabel(k) + ")")
          rewindAud(k)
          If \nPrevPlayIndex = -1
            \nAudState = #SCS_CUE_READY
          Else
            \nAudState = #SCS_CUE_PL_READY
          EndIf
          bAudStateChanged = #True
        EndIf
      EndWith
    EndIf
    k = aAud(k)\nNextAudIndex
  Wend
  If bAudStateChanged
    setCueState(aSub(pSubPtr)\nCueIndex)
  EndIf
  
  debugMsg(sProcName, "calling createWQAFile()")
  createWQAFile() ; extra item for inserts
  
  If nScrollPos > 0
    SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X, nScrollPos)
  EndIf
  debugMsg(sProcName, "calling WQA_setCurrentItem(" + nItemIndex + ")")
  WQA_setCurrentItem(nItemIndex)
  
  With aSub(pSubPtr)
    debugMsg(sProcName, "calling calcPLTotalTime(" + getSubLabel(pSubPtr) + ")")
    calcPLTotalTime(pSubPtr)
    SGT(WQA\txtTotalTime, timeToStringBWZ(\nPLTotalTime))
    SLD_setMax(WQA\sldProgress[1], \nPLTestTime)
  EndWith
  
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO
      WQA_displayAudioGraphIfReqd()
    EndIf
  EndIf

  bFirstTime = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_displayDev()
  PROCNAMEC()
  Protected d
  Protected nListIndex
  Protected bDevPresent
  
  gbInDisplayDev = #True
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      d = 0
      If \bMuteVideoAudio
        nListIndex = indexForComboBoxData(WQA\cboVidAudLogicalDev, -1)
        bDevPresent = #True
      Else
        If Len(\sVidAudLogicalDev) > 0
          bDevPresent = #True
        Else
          bDevPresent = #False
        EndIf
        nListIndex = indexForComboBoxRow(WQA\cboVidAudLogicalDev, \sVidAudLogicalDev, -1)
        If nListIndex = -1 And bDevPresent
          nListIndex = 0
        EndIf
      EndIf
      SGS(WQA\cboVidAudLogicalDev, nListIndex)
      WQA_fcLogicalDevA()
      
      nListIndex = indexForComboBoxRow(WQA\cboSubTrim, \sPLDBTrim[d], -1)
      If nListIndex = -1 And bDevPresent
        nListIndex = 0
      EndIf
      If GetGadgetState(WQA\cboSubTrim) <> nListIndex
        SGS(WQA\cboSubTrim, nListIndex)
      EndIf
      SLD_setMax(WQA\sldSubLevel, #SCS_MAXVOLUME_SLD) ; set max to format slider
      SLD_setLevel(WQA\sldSubLevel, \fSubMastBVLevel[d], \fSubTrimFactor[d])
      SLD_setBaseLevel(WQA\sldSubLevel, #SCS_SLD_BASE_EQUALS_CURRENT)
      SGT(WQA\txtSubDBLevel, convertBVLevelToDBString(\fSubMastBVLevel[d], #False, #True))
      SLD_setMax(WQA\sldSubPan, #SCS_MAXPAN_SLD)   ; forces control to be formatted
      SLD_setValue(WQA\sldSubPan, panToSliderValue(\fPLPan[d]))
      SLD_setBaseValue(WQA\sldSubPan, #SCS_SLD_BASE_EQUALS_CURRENT)
    EndWith
  EndIf
  
  gbInDisplayDev = #False
  
EndProcedure

Procedure WQA_displaySubThumbnails2(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n
  Protected bDisplayProgress
  Protected qStartTime.q, qTimeNow.q
  Protected bCancelRequested
  Protected nAudPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr <> nEditSubPtr
    ; too late - user has changed to another sub
    ProcedureReturn
  EndIf
  
  qStartTime = ElapsedMilliseconds()
  For n = 0 To gnWQALastItem
    If (bDisplayProgress = #False) And (n > 0)
      If (ElapsedMilliseconds() - qStartTime) > 1000
        WMI_displayInfoMsg1(Lang("WQA", "LoadingThumbs"), gnWQALastItem)
        bDisplayProgress = #True
      EndIf
    EndIf
    If bDisplayProgress
      WMI_setProgress(n)
      nAudPtr = WQAFile(n)\nFileAudPtr
      If nAudPtr >= 0
        WMI_displayInfoMsg2(GetFilePart(aAud(nAudPtr)\sFileName))
      EndIf
      CompilerIf #c_show_infomsg_cancel
        If WMI_getCancelState()
          debugMsg(sProcName, "cancel requested")
          Break
        EndIf
      CompilerEndIf
    EndIf
    WQA_drawTimeLineImage2(n)
  Next n
  
  If bDisplayProgress
    WMI_clearInfoMsgs()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_setIncrements(pVidPicTarget)
  PROCNAMEC()
  Protected nCanvasWidth, nCanvasHeight
  
  debugMsg(sProcName, #SCS_START)
  
  With WQA
    rWQA\nXPosRange = SLD_getMax(\sldXPos) - SLD_getMin(\sldXPos)
    rWQA\nYPosRange = SLD_getMax(\sldYPos) - SLD_getMin(\sldYPos)
    rWQA\nSizeRange = SLD_getMax(\sldSize) - SLD_getMin(\sldSize)
    debugMsg(sProcName, "rWQA\nXPosRange=" + rWQA\nXPosRange + ", \nYPosRange=" + rWQA\nYPosRange + ", \nSizeRange=" + rWQA\nSizeRange)
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nCanvasWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
        nCanvasHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
      Default
        nCanvasWidth = GadgetWidth(\cvsPreview)
        nCanvasHeight = GadgetHeight(\cvsPreview)
    EndSelect
  EndWith
  
  With rWQA
    ; calculate slider factors for small (1 pixel) movements
    \fXPosIncrementS = \nXPosRange / nCanvasWidth
    \fYPosIncrementS = \nYPosRange / nCanvasHeight
    If nCanvasHeight < nCanvasWidth
      \fSizeIncrementS = \nSizeRange / nCanvasHeight
    Else
      \fSizeIncrementS = \nSizeRange / nCanvasWidth
    EndIf
    ; calculate slider factors for large (1% each direction) movements
    \fXPosIncrementL = \nXPosRange / 200
    \fYPosIncrementL = \nYPosRange / 200
    \fSizeIncrementL = \nSizeRange / 200
    SLD_setKeyFactorS(WQA\sldXPos, nCanvasWidth)
    SLD_setKeyFactorS(WQA\sldYPos, nCanvasHeight)
    If nCanvasHeight < nCanvasWidth
      SLD_setKeyFactorS(WQA\sldSize, nCanvasHeight)
    Else
      SLD_setKeyFactorS(WQA\sldSize, nCanvasWidth)
    EndIf
    ; SLD_setKeyFactorL(WQA\sldXPos, 200)
    ; SLD_setKeyFactorL(WQA\sldYPos, 200)
    ; SLD_setKeyFactorL(WQA\sldSize, 200)
    
    debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", rWQA\fXPosIncrementS=" + StrF(\fXPosIncrementS,2) + ", \fXPosIncrementL=" + StrF(\fXPosIncrementL,2))
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_Form_Load()
  PROCNAMEC()
  Protected nItemCode, nBackColor
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQA()
  SUB_loadOrResizeHeaderFields("A", #True)
  
  WQA_setIncrements(#SCS_VID_PIC_TARGET_P)
  
  With rWQA\rPreviewOrigPosAndSize
    \nLeft = GadgetX(WQA\cvsPreview)
    \nTop = GadgetY(WQA\cvsPreview)
    \nWidth = GadgetWidth(WQA\cvsPreview)
    \nHeight = GadgetHeight(WQA\cvsPreview)
  EndWith
  
  EnableGadgetDrop(WQA\scaTimeLine, #PB_Drop_Files, #PB_Drag_Copy) ; nb 'drop' processed by WED_DropCallback()
  
  With grVidPicTarget(#SCS_VID_PIC_TARGET_P)
    \nTargetCanvasNo = WQA\cvsPreview
    \nTargetImageNo = WQA\imgPreview
    \nTargetWidth = GadgetWidth(WQA\cvsPreview)
    \nTargetHeight = GadgetHeight(WQA\cvsPreview)
    \nBlackImageNo = WQA\imgPreviewBlack
    \nBlankImageNo = WQA\imgPreviewBlank
    \nBlendedImageNo = WQA\imgPreviewBlended
    ; Place Video Capture image holder here WQA\imgCapture
  EndWith
  
  With WQA
    
    WQA_populateCboVidAudLogicalDevs()
    WQA_populateCboVidCapLogicalDevs()
    
    populateCboTrim(\cboSubTrim)
    
    ClearGadgetItems(\cboQATransType)
    addGadgetItemWithData(\cboQATransType, Lang("WQA", "cboTransTypeNone"), #SCS_TRANS_NONE)
    addGadgetItemWithData(\cboQATransType, Lang("WQA", "cboTransTypeCrossFade"), #SCS_TRANS_XFADE)
    
    ClearGadgetItems(\cboAspectRatioType)
    addGadgetItemWithData(\cboAspectRatioType, Lang("WQA", "ART_Original"), #SCS_ART_ORIGINAL)
    addGadgetItemWithData(\cboAspectRatioType, Lang("WQA", "ART_Full"), #SCS_ART_FULL)
    addGadgetItemWithData(\cboAspectRatioType, "16:9", #SCS_ART_16_9)
    addGadgetItemWithData(\cboAspectRatioType, "4:3", #SCS_ART_4_3)
    addGadgetItemWithData(\cboAspectRatioType, "1.85:1", #SCS_ART_185_1)
    addGadgetItemWithData(\cboAspectRatioType, "2.35:1", #SCS_ART_235_1)
    addGadgetItemWithData(\cboAspectRatioType, Lang("WQA", "ART_Custom"), #SCS_ART_CUSTOM)
    
  EndWith
  
  colorEditorComponent(#WQA)
  
  ; Set the back color of the read-only string field for file type
  ; Changed 22Jan2024 11.10.1
  ; (The fix applied in SVN Rev 286 obviously doesn't work in all circumstances)
  nItemCode = encodeColorItemCode("QA")
  If nItemCode >= 0
    nBackColor = grColorScheme\aItem[nItemCode]\nBackColor
    SetGadgetColor(WQA\txtFileTypeExt, #PB_Gadget_BackColor, nBackColor)
  EndIf
  ; End changed 22Jan2024 11.10.1

  CompilerIf #c_cue_markers_for_video_files
    If grLicInfo\bCueMarkersAvailable
      ; debugMsg(sProcName, "calling graphInit(@grMG5)")
      graphInit(@grMG5)
    EndIf
  CompilerEndIf
  
  ; debugMsg(sProcName, "calling WQA_setPreviewPanel(-1)")
  WQA_setPreviewPanel(-1)
  
  With WQA
    ; Call "SLD_ToolTip(\sldProgress[0], #SCS_SLD_TTA_BUILD, ...)" now because if we wait until the tooltip is required then the first time the tooltip
    ; is displayed it will be displayed blank. I don't know why - tried adding some timing delays but they didn't help. But by 'building' the tooltip
    ; early (eg on creating the form), the tooltip displays correctly every time.
    ; Similarly for WQF and WQP.
    gaSlider(\sldProgress[0])\nSliderToolTipType = #SCS_SLD_TTT_GENERAL
    SLD_ToolTip(\sldProgress[0], #SCS_SLD_TTA_BUILD, buildSkipBackForwardTooltip())
  EndWith
  
  If grLicInfo\bExternalEditorsIncluded  ; unhide gadget if allowed
    HideGadget(WQA\btnEditExternally, 0)
  Else
    HideGadget(WQA\btnEditExternally, 1)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQA_valGadget(gnValidateGadgetNo)
  EndIf
  
  ; debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure WQA_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQA
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQA)
        
        ; detail gadgets
      Case \txtDisplayTime    ; txtDisplayTime
        ETVAL2(WQA_multiItemValidate())
        
      Case \txtEndAt    ; txtEndAt
        ETVAL2(WQA_multiItemValidate())
        
      Case \txtFadeInTime  ; txtFadeInTime
        ETVAL2(WQA_txtFadeInTime_Validate())
        
      Case \txtFadeOutTime  ; txtFadeOutTime
        ETVAL2(WQA_txtFadeOutTime_Validate())
        
      Case \txtQATransTime   ; txtQATransTime
        ETVAL2(WQA_multiItemValidate())
        
      Case \txtSize  ; txtSize
        ETVAL2(WQA_txtSize_Validate())
        
      Case \txtStartAt  ; txtStartAt
        ETVAL2(WQA_multiItemValidate())
        
      Case \txtSubDBLevel  ; txtSubDBLevel
        ETVAL2(WQA_txtSubDBLevel_Validate())
        
      Case \txtSubPan  ; txtSubPan
        ETVAL2(WQA_txtSubPan_Validate())
        
      Case \txtXPos  ; txtXPos
        ETVAL2(WQA_txtXPos_Validate())
        
      Case \txtYPos  ; txtYPos
        ETVAL2(WQA_txtYPos_Validate())
        
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

Procedure WQA_refreshCueMarkersDisplayEtc()
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, "calling loadCueMarkerArrays()")
  loadCueMarkerArrays()
  redrawGraphAfterMouseChange(@grMG5)
  
  ; debugMsg(sProcName, "calling redisplayCueMarkerInfoWhereReqd(" + getAudLabel(nEditAudPtr) + ")")
  redisplayCueMarkerInfoWhereReqd(nEditAudPtr)
  
  ; debugMsg(sProcName, "calling setTVGMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
  setTVGMarkerPositions(nEditAudPtr)
  
EndProcedure

Procedure WQA_setMarkerDragActionAndCursor()
  PROCNAMEC()
  Protected nCanvasCursor = -1
  
  With grMG5
    Select \nMouseDownSliceType
      Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
        If (isAltKeyDown() = #False) And (isCtrlKeyDown() = #False)
          \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION
          nCanvasCursor = #PB_Cursor_LeftRight
        EndIf        
    EndSelect
  EndWith
  ProcedureReturn nCanvasCursor
EndProcedure

Procedure WQA_cvsSideLabelsQA_Event()
  PROCNAMEC()
  Protected nMouseX, nMouseY, bDisplayHelp, bCheckDisplay
  Static bHelpDisplayed
  Static sGraphHelp.s,sHelpMessage0.s, sHelpMessage1.s, nMaxWidth, sFullMessage.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sGraphHelp = Lang("Graph", "GraphHelp")
    sHelpMessage0 = Lang("Graph", "HelpMsg0") ; "Press F7 while file is playing to create a QUICK CUE MARKER at the current playback position."
    sHelpMessage1 = Lang("Graph", "HelpMsg1QA") ; "To change the POSITION of an SCS Cue Marker, CLICK and DRAG the marker."
    nMaxWidth = GetTextWidth(sHelpMessage1 + Space(20)) ; seems to give a good result
    sFullMessage = sHelpMessage0
    sFullMessage + #CRLF$ + #CRLF$ + sHelpMessage1
    bStaticLoaded = #True
  EndIf
  
  With grMG5
    If \bDeviceAssigned = #False
      ProcedureReturn
    EndIf
    
    ; debugMsg(sProcName, "gnEventType=" + decodeEventType(WQA\cvsGraph))
    
    Select gnEventType
      Case #PB_EventType_MouseEnter, #PB_EventType_MouseMove
        nMouseX = GetGadgetAttribute(WQA\cvsSideLabelsQA, #PB_Canvas_MouseX)
        nMouseY = GetGadgetAttribute(WQA\cvsSideLabelsQA, #PB_Canvas_MouseY)
        If (nMouseX >= \nGraphHelpLeft) And (nMouseX <= \nGraphHelpRight) And (nMouseY >= \nGraphHelpTop) And (nMouseY <= \nGraphHelpBottom)
          bDisplayHelp = #True
        Else
          bDisplayHelp = #False
        EndIf
        bCheckDisplay = #True
        
      Case #PB_EventType_MouseLeave
        bDisplayHelp = #False
        bCheckDisplay = #True
        
    EndSelect
    
    If bCheckDisplay
      If bDisplayHelp <> bHelpDisplayed
        If bDisplayHelp
          GadToolTip(WQA\cvsSideLabelsQA, sFullMessage, nMaxWidth)
          SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_NO_ICON, @sGraphHelp)
        EndIf
        bHelpDisplayed = bDisplayHelp
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQA_graphContextMenuEnabledStates()
  PROCNAMECA(nEditAudPtr)
  Protected nPointTime, nPointType
  Protected bRemoveEnabled
  Protected bSetPosEnabled
  Protected nFirstPointTime
  Protected n, nGraphMarkerIndex
  Protected bEditCueMarker, bRemoveCueMarker, bSetCueMarkerPosition, bShowOnCues, bCueMarkersEnabled, nCueMarkerIndex, bShowOnAllGraphs, bRemoveAllUnusedCueMarkersFromFile
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nGraphMarkerIndex = checkMouseOnGraphMarker(@grMG5, grMG5\nMouseDownStartX, grMG5\nMouseDownStartY)
      debugMsg(sProcName, "nGraphMarkerIndex=" + nGraphMarkerIndex)
      If nGraphMarkerIndex >= 0
        Select grMG5\aGraphMarker(nGraphMarkerIndex)\nGraphMarkerType
          Case #SCS_GRAPH_MARKER_CM, #SCS_GRAPH_MARKER_CP
            nCueMarkerIndex = grMG5\aGraphMarker(nGraphMarkerIndex)\nMGCueMarkerIndex
            nPointTime = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
            debugMsg(sProcName, "Cue Marker nPointTime=" + nPointTime)
        EndSelect
      Else
        nPointTime = (grMG5\nMouseDownStartX - grMG5\nGraphLeft) * grMG5\fMillisecondsPerPixel
      EndIf
      If (nPointTime >= \nAbsMin) And (nPointTime <= \nAbsMax)
        bCueMarkersEnabled = #True
      EndIf
    EndWith 
  EndIf
  
  If grLicInfo\bCueMarkersAvailable
    bShowOnAllGraphs = #True
    If aAud(nEditAudPtr)\nMaxCueMarker >= 0
      bRemoveAllUnusedCueMarkersFromFile = #True
    EndIf
    If bCueMarkersEnabled
      bEditCueMarker = #True
      bShowOnCues = #True
      If grMG5\nGraphMarkerIndex >= 0
        bRemoveCueMarker = #True
        bSetCueMarkerPosition = #True
      EndIf
    EndIf
  EndIf
  
  If IsMenu(#WQA_mnu_GraphContextMenu)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_SetPos, bSetPosEnabled)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_SetCueMarkerPos, bSetCueMarkerPosition)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_AddQuickCueMarkers, bShowOnCues)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_EditCueMarker, bEditCueMarker)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_RemoveCueMarker, bRemoveCueMarker)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile, bRemoveAllUnusedCueMarkersFromFile)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_ViewOnCues, bShowOnAllGraphs)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_ViewCueMarkersUsage, bShowOnAllGraphs)
    scsEnableMenuItem(#WQA_mnu_GraphContextMenu, #WQA_mnu_RemoveAllUnusedCueMarkers, bShowOnAllGraphs)
  EndIf
  
EndProcedure

Procedure WQA_cvsGraphQA_Event()
  PROCNAMECA(nEditAudPtr)
  Protected nSliceType
  Protected nMouseX, nChangeInX, fChangeInTime.f
  Protected nMouseY, nChangeInY
  Protected nMouseTime, nFieldTime, nAfterValue
  Protected nLeft
  Protected n, u
  Protected nNewRelFilePos
  Protected nMouseDownSliceType, nMouseDownStartX, nMouseDownStartY, nMouseDownTime
  Protected nMinTime, nMaxTime
  Protected nCanvasCursor = -1
  Protected nCueMarkerId, nCueMarkerPosition, nCueMarkerType, nMGCueMarkerIndex, nOldMarkerPosition, nNewMarkerPosition, nCueMarkerIndex
  Protected bFound
  Protected bRefreshCuePanel
  Protected nTmpValue
  Protected bDisplayPlayLength, bUpdateTotalTime
  
  With grMG5
    
    If \bDeviceAssigned = #False
      ProcedureReturn
    EndIf
    
    ; debugMsg0(sProcName, "gnEventType=" + decodeEventType(WQA\cvsGraphQA))
    
    Select gnEventType
      Case #PB_EventType_MouseEnter ; INFO: cvsGraphQA #PB_EventType_MouseEnter
        ;{
        ; debugMsg(sProcName, "#PB_EventType_MouseEnter start")
        \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
        ; debugMsg(sProcName, "#PB_EventType_MouseEnter end")
        ;}
      Case #PB_EventType_RightButtonDown ; INFO: cvsGraphQA #PB_EventType_RightButtonDown
        ;{
        debugMsg(sProcName, "#PB_EventType_RightButtonDown start")
        nMouseDownSliceType = checkMousePosInGraphQA(#True)  ; nb also sets grMG5\nMouseDownLevelPointId if appropriate
        nMouseDownStartX = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseX)
        nMouseDownStartY = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseY)
        nMouseDownTime = (nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
        \nMouseDownSliceType = nMouseDownSliceType
        \nMouseDownStartX = nMouseDownStartX
        \nMouseDownStartY = nMouseDownStartY
        \nMouseDownTime = nMouseDownTime
        WQA_graphContextMenuEnabledStates()
        SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Clip, 0)
        DisplayPopupMenu(#WQA_mnu_GraphContextMenu, WindowID(#WED))
        ;}
      Case #PB_EventType_LeftButtonDown ; INFO: cvsGraphQA #PB_EventType_LeftButtonDown
        ;{
        ; debugMsg0(sProcName, "#PB_EventType_LeftButtonDown start")
        ; listGraphMarkers()
        \nMouseDownSliceType = checkMousePosInGraphQA(#True)
        ; nb checkMousePosInGraphQA() also sets grMG5\nMouseDownLevelPointId and grMG5\nMouseDownItemId if appropriate, and grMG5\nMouseMinTime and grMG5\nMouseMaxTime
        ; also sets grMG5\nMouseDownLoopInfoIndex is appropriate
        ; debugMsg0(sProcName, "grMG5\nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType) + ", \nMouseDownLevelPointId=" + \nMouseDownLevelPointId)
        \nMouseDownStartX = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseX)
        \nMouseDownStartY = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseY)
        \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_NO_ACTION ; may be changed later in this procedure
        ; debugMsg(sProcName, "\nGraphTop=" + Str(\nGraphTop) + ", \nGraphTopL=" + Str(\nGraphTopL) + ", \nGraphTopR=" + Str(\nGraphTopR) + ", \nGraphBottom=" + Str(\nGraphBottom) +
        ;                     ", \nGraphBottomL=" + Str(\nGraphBottomL) + ", \nGraphBottomR=" + Str(\nGraphBottomR))
        
        If isCtrlKeyDown()
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              addSelectedCtrlHoldLP(\nMouseDownLevelPointId) ; nb this procedure will de-select the level point if it is currently selected
          EndSelect
        ElseIf isAltKeyDown() = #False
          ; if neither a Ctrl key nor an Alt key is down, then initially clear the Ctrl Hold List for Level Points
          clearCtrlHoldLP()
          ; now add this entry to the Ctrl Hold List if required
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              addSelectedCtrlHoldLP(\nMouseDownLevelPointId) ; nb this procedure will de-select the level point if it is currently selected
          EndSelect
        ElseIf isAltKeyDown()
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN
              If checkSelectedCtrlHoldLP(\nMouseDownLevelPointId) = #False
                addSelectedCtrlHoldLP(\nMouseDownLevelPointId)
              EndIf
          EndSelect
        EndIf
        
        Select \nMouseDownSliceType
          Case #SCS_SLICE_TYPE_ST ; LeftButtonDown: #SCS_SLICE_TYPE_ST
            \nMouseDownTime = aAud(nEditAudPtr)\nAbsStartAt
            \nLastTimeMark = \nMouseDownTime
            \bSetFilePosAtStartAt = #False
            If (aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN) Or (aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT)
              If (aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin) = aAud(nEditAudPtr)\nAbsStartAt
                \bSetFilePosAtStartAt = #True
                ; debugMsg(sProcName, "\bSetFilePosAtStartAt=" + strB(\bSetFilePosAtStartAt))
              EndIf
            EndIf
            Select \nMouseDownGraphMarkerType
              Case #SCS_GRAPH_MARKER_ST, #SCS_GRAPH_MARKER_LP
                nCanvasCursor = WQA_setMarkerDragActionAndCursor()
                ; WQA_displayLevelPointInfo(#SCS_PT_START)
            EndSelect
            
          Case #SCS_SLICE_TYPE_EN ; LeftButtonDown: #SCS_SLICE_TYPE_EN
            \nMouseDownTime = aAud(nEditAudPtr)\nAbsEndAt
            If \nMouseDownTime >= aAud(nEditAudPtr)\nFileDuration
              \nMouseDownTime = aAud(nEditAudPtr)\nFileDuration - 1
            EndIf
            \nLastTimeMark = \nMouseDownTime
            ; debugMsg(sProcName, "\nMouseDownGraphMarkerType=" + decodeGraphMarkerType(\nMouseDownGraphMarkerType))
            Select \nMouseDownGraphMarkerType
              Case #SCS_GRAPH_MARKER_EN
                nCanvasCursor = WQA_setMarkerDragActionAndCursor()
            EndSelect
            ; WQF_displayLevelPointInfo(#SCS_PT_END)
            
          Case #SCS_SLICE_TYPE_CURR ; LeftButtonDown: #SCS_SLICE_TYPE_CURR
            \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
            ; debugMsg(sProcName, "LeftButtonDown: \nMouseDownStartX=" + \nMouseDownStartX + ", \nGraphLeft=" + \nGraphLeft + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2) + ", \nMouseDownTime=" + \nMouseDownTime)
            \nLastTimeMark = \nMouseDownTime
            
          Case #SCS_SLICE_TYPE_NORMAL ; LeftButtonDown: #SCS_SLICE_TYPE_NORMAL
            \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
            \nMouseDownCanvasLeft = \nGraphLeft
            ; debugMsg(sProcName, "LeftButtonDown: \nMouseDownStartX=" + \nMouseDownStartX + ", \nGraphLeft=" + \nGraphLeft + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2) + ", \nMouseDownTime=" + \nMouseDownTime)
            \nMouseDownGrabStartX = WindowMouseX(#WED)
            SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_CustomCursor, hCursorGrabbing)
            If (aAud(nEditAudPtr)\nAudState < #SCS_CUE_FADING_IN) Or (aAud(nEditAudPtr)\nAudState > #SCS_CUE_FADING_OUT)
              aAud(nEditAudPtr)\bResetFilePosToStartAtInMain = #True
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bResetFilePosToStartAtInMain=" + strB(aAud(nEditAudPtr)\bResetFilePosToStartAtInMain))
            EndIf
            
          Case #SCS_SLICE_TYPE_CM ;  ; LeftButtonDown: #SCS_SLICE_TYPE_CM
            nMGCueMarkerIndex = \nMouseDownGraphMarkerIndex
            nCueMarkerId = \nMouseDownCueMarkerId
            nCueMarkerIndex = -1
            nCueMarkerPosition = -1
            If nEditAudPtr >= 0
              bFound = #False
              For n = 0 To aAud(nEditAudPtr)\nMaxCueMarker
                If aAud(nEditAudPtr)\aCueMarker(n)\nCueMarkerId = nCueMarkerId
                  nCueMarkerIndex = n
                  Break
                EndIf
              Next n
              If nCueMarkerIndex >= 0
                nCueMarkerPosition = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
                If nCueMarkerPosition >= 0
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: nCueMarkerPosition=" + nCueMarkerPosition + ", nCueMarkerType=" + nCueMarkerType + ", sCueMarkerName=" + aAud(nEditAudPtr)\aCueMarker(n)\sCueMarkerName)
                  \nMouseDownTime = nCueMarkerPosition 
                  \nLastTimeMark = \nMouseDownTime
                EndIf
              EndIf
            EndIf
            
        EndSelect
        redrawGraphAfterMouseChange(@grMG5)
        ; nb do not rely on an earlier setting of nLevelPointIndex as the level point entry may have been moved by setDerivedLevelPointInfo()
        
        If \nMouseDownSliceType = #SCS_SLICE_TYPE_CM
          nCueMarkerIndex = \nMouseDownGraphMarkerIndex
          If nCueMarkerIndex >= 0
            drawTip(@grMG5, \nMouseDownSliceType, -1, -1, nCueMarkerIndex)
          EndIf
        EndIf
        
        If nCanvasCursor >= 0
          SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, nCanvasCursor)
        EndIf
        ;}
      Case #PB_EventType_LeftButtonUp ; INFO: cvsGraphQA #PB_EventType_LeftButtonUp
        ;{
        ; debugMsg(sProcName, "#PB_EventType_LeftButtonUp start, \nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType))
        Select \nMouseDownSliceType
          Case #SCS_SLICE_TYPE_ST
            If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
              debugMsg(sProcName, "calling reopenAudFileIfReqd(" + getAudLabel(nEditAudPtr) + ")")
              reopenAudFileIfReqd(nEditAudPtr)
              WQA_highlightItem()
            EndIf
            If \bSetFilePosAtStartAt
              aAud(nEditAudPtr)\nRelFilePos = aAud(nEditAudPtr)\nAbsStartAt - aAud(nEditAudPtr)\nAbsMin
              ; debugMsg(sProcName, "\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsMin=" + aAud(nEditAudPtr)\nAbsMin + ", \nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
              reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt, #True)
              WQA_SetTransportButtons()
              ; setDerivedLevelPointInfo2(nEditAudPtr) ; Commented out 24Sep2024 11.10.5 - level points not used in video cues, and could cause level envelope drawing on video's audio graph
              redrawGraphAfterMouseChange(@grMG5)
            EndIf
            bRefreshCuePanel = #True
            bDisplayPlayLength = #True
            bUpdateTotalTime = #True
            
          Case #SCS_SLICE_TYPE_EN
            If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
              debugMsg(sProcName, "calling reopenAudFileIfReqd(" + getAudLabel(nEditAudPtr) + ")")
              reopenAudFileIfReqd(nEditAudPtr)
              WQA_highlightItem()
            EndIf
            bRefreshCuePanel = #True
            bDisplayPlayLength = #True
            bUpdateTotalTime = #True
            
          Case #SCS_SLICE_TYPE_NORMAL
            If WindowMouseX(#WED) = \nMouseDownGrabStartX
              ; user just left-clicked on graph - didn't drag mouse - so reposition
              \nMouseDownTime = (\nMouseDownStartX - \nGraphLeft) * \fMillisecondsPerPixel
              nMouseTime = \nMouseDownTime
              If nMouseTime < aAud(nEditAudPtr)\nAbsMin
                nMouseTime = aAud(nEditAudPtr)\nAbsMin
              ElseIf nMouseTime > aAud(nEditAudPtr)\nAbsMax
                nMouseTime = aAud(nEditAudPtr)\nAbsMax
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin
              \nReposMouseTime = nMouseTime
              If nMouseTime <> nFieldTime
                aAud(nEditAudPtr)\nRelFilePos = nMouseTime - aAud(nEditAudPtr)\nAbsMin
                ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
                reposAuds(nEditAudPtr, nMouseTime, #True)
                WQA_SetTransportButtons()
                redrawGraphAfterMouseChange(@grMG5)
              EndIf
            EndIf
            SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, #PB_Cursor_Default)
            
          Case #SCS_SLICE_TYPE_CM ; #SCS_SLICE_TYPE_CM
            nCueMarkerId = \nMouseDownCueMarkerId
            ; debugMsg(sProcName, "calling setBassMarkerPositions(" + getAudLabel(nEditAudPtr) + ")")
            setBassMarkerPositions(nEditAudPtr)
            ; debugMsg(sProcName, "calling propogateCueMarkerPositionChange(" + getAudLabel(nEditAudPtr) + ", " + nCueMarkerId + ")")
            propogateCueMarkerPositionChange(nEditAudPtr, nCueMarkerId)
            gbForceReloadAllDispPanels = #True
            gbCallLoadDispPanels = #True
            redrawGraphAfterMouseChange(@grMG5)
            SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, #PB_Cursor_Default)
            
        EndSelect
        \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
        \nMarkerDragAction = #SCS_GRAPH_MARKER_DRAG_NO_ACTION
        If aAud(nEditAudPtr)\nMaxCueMarker >= 0
          WQA_refreshCueMarkersDisplayEtc()
        EndIf
        debugMsg(sProcName, "#PB_EventType_LeftButtonUp end")
        ;}
      Case #PB_EventType_MouseMove  ; INFO: cvsGraphQA #PB_EventType_MouseMove
        ;{
        ; debugMsg0(sProcName, "#PB_EventType_MouseMove start, \nMouseDownSliceType=" + decodeSliceType(\nMouseDownSliceType))
        If \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
          nSliceType = checkMousePosInGraphQA() ; sets cursor if over a hot spot, else resets default cursor
          ; debugMsg0(sProcName, "checkMousePosInGraphQA() returned nSliceType=" + decodeSliceType(nSliceType))
          nTmpValue = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseX)  
          If nSliceType = #SCS_SLICE_TYPE_CM Or nSliceType = #SCS_SLICE_TYPE_CP
            ; debugMsg0(sProcName, "\nMouseMoveMarkerIndex=" + \nMouseMoveMarkerIndex)
            nCueMarkerIndex = \nMouseMoveMarkerIndex
            If nCueMarkerIndex >= 0
              drawTip(@grMG5, nSliceType, -1, -1, nCueMarkerIndex)
            EndIf
          Else
            drawTip(@grMG5, nSliceType, -1, -1) ; clears cue marker tip if currently visible
          EndIf
          
        Else
          nMouseX = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseX)
          nChangeInX = nMouseX - \nMouseDownStartX
          fChangeInTime = nChangeInX * \fMillisecondsPerPixel
          nMouseTime = \nMouseDownTime + fChangeInTime
          If nMouseTime < 0
            nMouseTime = 0
          ElseIf nMouseTime >= aAud(nEditAudPtr)\nFileDuration
            nMouseTime = aAud(nEditAudPtr)\nFileDuration - 1
          EndIf
          ; debugMsg0(sProcName, "MM \nMouseDownGraphMarkerType=" + decodeGraphMarkerType(\nMouseDownGraphMarkerType) + ", rWQA\bDisplayingLevelPoint=" + strB(rWQA\bDisplayingLevelPoint) + ", grMG5\nMarkerDragAction=" + \nMarkerDragAction)
          ; debugMsg(sProcName, "MouseMove \nMouseDownSliceType=" + \nMouseDownSliceType + ", nChangeInX=" + Str(nChangeInX) + ", fChangeInTime=" + StrF(fChangeInTime,4) + ", nMouseTime=" + Str(nMouseTime))
          
          Select \nMouseDownSliceType
            Case #SCS_SLICE_TYPE_CURR ; MouseMove: #SCS_SLICE_TYPE_CURR
              If nMouseTime > \nMouseMaxTime
                nMouseTime = \nMouseMaxTime
              ElseIf nMouseTime < \nMouseMinTime
                nMouseTime = \nMouseMinTime
              EndIf
              \nLastTimeMark = nMouseTime
              nFieldTime = aAud(nEditAudPtr)\nRelFilePos + aAud(nEditAudPtr)\nAbsMin
              \nReposMouseTime = nMouseTime
              If nMouseTime <> nFieldTime
                aAud(nEditAudPtr)\nRelFilePos = nMouseTime - aAud(nEditAudPtr)\nAbsMin
                ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + aAud(nEditAudPtr)\nRelFilePos)
                reposAuds(nEditAudPtr, nMouseTime, #True)
                WQA_SetTransportButtons()
                redrawGraphAfterMouseChange(@grMG5)
              EndIf
              
            Case #SCS_SLICE_TYPE_ST ; MouseMove: #SCS_SLICE_TYPE_ST   START
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  ; debugMsg0(sProcName, "ST: nMouseTime=" + timeToStringT(nMouseTime) + ", \nMouseMaxTime=" + timeToStringT(\nMouseMaxTime))
                  If nMouseTime > \nMouseMaxTime
                    nMouseTime = \nMouseMaxTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  nFieldTime = aAud(nEditAudPtr)\nAbsStartAt
                  If nMouseTime <> nFieldTime
                    u = preChangeAudL(aAud(nEditAudPtr)\nStartAt, GGT(WQA\lblStartAt), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    aAud(nEditAudPtr)\nAbsStartAt = nMouseTime
                    If aAud(nEditAudPtr)\nAbsStartAt <= 0
                      aAud(nEditAudPtr)\nStartAt = -2
                    Else
                      aAud(nEditAudPtr)\nStartAt = aAud(nEditAudPtr)\nAbsStartAt
                    EndIf
                    ; debugMsg(sProcName, "calling setDerivedAudFields")
                    setDerivedAudFields(nEditAudPtr)
                    SGT(WQA\txtStartAt, timeToStringT(aAud(nEditAudPtr)\nStartAt, aAud(nEditAudPtr)\nFileDuration))
                    nAfterValue = aAud(nEditAudPtr)\nStartAt
                    ; debugMsg(sProcName, "nFieldTime=" + nFieldTime + ", nAfterValue=" + nAfterValue)
                    redrawGraphAfterMouseChange(@grMG5)
                    postChangeAudLN(u, nAfterValue)
                    ; bRefreshCuePanel = #True
                    bDisplayPlayLength = #True
                    bUpdateTotalTime = #True
                  EndIf
              EndSelect
              
            Case #SCS_SLICE_TYPE_EN ; MouseMove: #SCS_SLICE_TYPE_EN
              Select \nMarkerDragAction
                Case #SCS_GRAPH_MARKER_DRAG_CHANGES_POSITION  ; change position
                  nFieldTime = aAud(nEditAudPtr)\nAbsEndAt
                  ; debugMsg(sProcName, "EN: nMouseTime=" + nMouseTime + ", \nMouseMinTime=" + \nMouseMinTime + ", nFieldTime=" + nFieldTime + 
                  ;                     ", aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt)
                  If nMouseTime < \nMouseMinTime
                    nMouseTime = \nMouseMinTime
                  EndIf
                  \nLastTimeMark = nMouseTime
                  If nMouseTime <> nFieldTime
                    u = preChangeAudL(aAud(nEditAudPtr)\nEndAt, GGT(WQA\lblEndAt), -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                    aAud(nEditAudPtr)\nAbsEndAt = nMouseTime
                    If aAud(nEditAudPtr)\nAbsEndAt >= aAud(nEditAudPtr)\nFileDuration
                      aAud(nEditAudPtr)\nEndAt = -2
                    Else
                      aAud(nEditAudPtr)\nEndAt = aAud(nEditAudPtr)\nAbsEndAt
                    EndIf
                    ; debugMsg(sProcName, "EN: aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsStartAt=" + aAud(nEditAudPtr)\nAbsStartAt + ", \nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt)
                    ; debugMsg(sProcName, "calling setDerivedAudFields")
                    setDerivedAudFields(nEditAudPtr)
                    SGT(WQA\txtEndAt, timeToStringT(aAud(nEditAudPtr)\nEndAt, aAud(nEditAudPtr)\nFileDuration))
                    nAfterValue = aAud(nEditAudPtr)\nEndAt
                    redrawGraphAfterMouseChange(@grMG5)
                    postChangeAudLN(u, nAfterValue)
                    ; bRefreshCuePanel = #True
                    bDisplayPlayLength = #True
                    bUpdateTotalTime = #True
                  EndIf
              EndSelect
              
            Case #SCS_SLICE_TYPE_NORMAL ; MouseMove: #SCS_SLICE_TYPE_NORMAL
              nMouseX = WindowMouseX(#WED)
              nChangeInX = nMouseX - \nMouseDownGrabStartX
              If nChangeInX <> 0
                ; user is dragging the display
                nLeft = \nMouseDownCanvasLeft + nChangeInX
                If nLeft > 0
                  nLeft = 0
                ElseIf nLeft < (\nVisibleWidth - \nInnerWidth)
                  nLeft = (\nVisibleWidth - \nInnerWidth)
                EndIf
                ; debugMsg(sProcName, "nMouseX=" + Str(nMouseX) + ", nLeft=" + nLeft)
                If nLeft <> \nGraphLeft
                  \nGraphLeft = nLeft
                  debugMsg(sProcName, "calling drawWholeGraphArea()")
                  drawWholeGraphArea()
                  ; debugMsg(sProcName, "calling setViewStartAndEndFromVisibleGraph()")
                  setViewStartAndEndFromVisibleGraph()
                  ; WQA_setZoomAndPosSliders(#True)
                  ; debugMsg(sProcName, "calling WQA_setPosSlider()")
                EndIf
              EndIf
              
            Case #SCS_SLICE_TYPE_CM ; MouseMove: #SCS_SLICE_TYPE_CM  CUE MARKER
              ; Handle no sliding if audio file is currently playing
              If aAud(nEditAudPtr)\nAudState <> #SCS_CUE_PLAYING
                ; Handle any Slide Movement here
                nMGCueMarkerIndex = \nMouseDownGraphMarkerIndex
                If nMouseTime > \nMouseMaxTime
                  nMouseTime = \nMouseMaxTime
                ElseIf nMouseTime < \nMouseMinTime
                  nMouseTime = \nMouseMinTime
                EndIf
                \nLastTimeMark = nMouseTime
                
                nFieldTime = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition
                If nMouseTime <> nFieldTime
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: calling preChangeAudL(" + aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition + ",...)")
                  u = preChangeAudL(aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition , "Move Cue Marker", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
                  nOldMarkerPosition = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition
                  
                  If nMouseTime < aAud(nEditAudPtr)\nAbsStartAt
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = aAud(nEditAudPtr)\nAbsStartAt
                  ElseIf  nMouseTime > aAud(nEditAudPtr)\nAbsEndAt
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = aAud(nEditAudPtr)\nAbsEndAt
                  Else
                    aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition = nMouseTime
                  EndIf
                  nAfterValue = aAud(nEditAudPtr)\aCueMarker(nMGCueMarkerIndex)\nCueMarkerPosition  
                  ; debugMsg(sProcName, "About to Call (D) populate_ProcessMarkers() from inside fmEditQF.pbi")
                  ; debugMsg(sProcName, "#SCS_SLICE_TYPE_CM: calling postChangeAudLN(u, " + nAfterValue + ")")
                  postChangeAudLN(u, nAfterValue)
                  WQA_refreshCueMarkersDisplayEtc()
                EndIf
              EndIf
              
          EndSelect
          
          If \nMouseDownSliceType = #SCS_SLICE_TYPE_CM Or \nMouseDownSliceType = #SCS_SLICE_TYPE_CP
            nCueMarkerIndex = \nMouseMoveMarkerIndex
            If nCueMarkerIndex >= 0
              ; Draw the Tip for a Cue Marker with Mouse Moving
              drawTip(@grMG5, \nMouseDownSliceType, -1, -1, nCueMarkerIndex)
            EndIf
          EndIf
          
        EndIf
        ;}
    EndSelect
    
      If bDisplayPlayLength
        SGT(WQA\txtPlayLength, timeToStringBWZ(aAud(nEditAudPtr)\nCueDuration))
        SLD_setMax(WQA\sldProgress[0], (aAud(nEditAudPtr)\nCueDuration-1))
      EndIf
      
      If bUpdateTotalTime
        WQA_doSubTotals()
      EndIf
      
    If bRefreshCuePanel
      ; debugMsg(sProcName, "bRefreshCuePanel=" + strB(bRefreshCuePanel))
      loadGridRow(nEditCuePtr)
      PNL_refreshDispPanel(nEditCuePtr, nEditSubPtr, nEditAudPtr, #True)
    EndIf
    
  EndWith
  
EndProcedure

Procedure WQA_EventHandler()
  PROCNAMEC()
  Protected bFound
  
  With WQA
    
    If gnEventSliderNo > 0
      
      ; debugMsg(sProcName, "gnSliderEvent=" + gnSliderEvent + ", gnEventSliderNo=" + gnEventSliderNo)
      ; debugMsg(sProcName, "gnTrackingSliderNo=" + gnTrackingSliderNo)
      
      Select gnEventSliderNo
        Case \sldAspectRatioHVal
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_sldAspectRatio_Common()
          EndSelect
          
        Case \sldProgress[0]
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_sldProgress_Common(gnSliderEvent)
          EndSelect
          
        Case \sldProgress[1]
          bFound = #True
          ; do nothing
          
        Case \sldRelLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_fcSldRelLevel()
          EndSelect
          
        Case \sldSize
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_sldSize_Common()
          EndSelect
          
        Case \sldSubLevel
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_fcSldLevelA()
          EndSelect
          
        Case \sldSubPan
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_fcSldPanA()
          EndSelect
          
        Case \sldXPos
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_sldXPos_Common()
          EndSelect
          
        Case \sldYPos
          bFound = #True
          Select gnSliderEvent
            Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL, #SCS_SLD_EVENT_MOUSE_UP
              WQA_sldYPos_Common()
          EndSelect
          
      EndSelect
      
      If bFound
        ProcedureReturn
      EndIf
      
    EndIf
    
    Select gnWindowEvent
        
      Case #PB_Event_Menu ; see also WED_EventHandler() in fmEditor.pbi, which is where these menu events are originally caught
        debugMsg(sProcName, "gnEventMenu=" + decodeMenuItem(gnEventMenu))
        Select gnEventMenu
          Case #SCS_WEDF_SelectAll
            WQA_processItemSelected(-100)   ; -100 indicates 'select all'
            
          Case #WQA_mnuRotate To #WQA_mnuRotateDummyLast
            WQA_mnuRotate_Click(gnEventMenu)
            
          Case #WQA_mnuOther To #WQA_mnuOtherDummyLast
            WQA_mnuOther_Click(gnEventMenu)
            
          Case #SCS_WEDF_Rewind
            ; no 'rewind' button in WQA
            
          Case #SCS_WEDF_PlayPause
            If getVisible(\btnPlay) And getEnabled(\btnPlay)
              WQA_transportBtnClick(#SCS_STANDARD_BTN_PLAY)
            ElseIf getVisible(\btnPause) And getEnabled(\btnPause)
              WQA_transportBtnClick(#SCS_STANDARD_BTN_PAUSE)
            EndIf
            
          Case #SCS_WEDF_Stop
            If getVisible(\btnStop) And getEnabled(\btnStop)
              WQA_transportBtnClick(#SCS_STANDARD_BTN_STOP)
            EndIf
            
          Case #SCS_WEDF_SkipBack
            WQA_skipBackOrForward(-2000) ; skip back 2 seconds
            
          Case #SCS_WEDF_SkipForward
            WQA_skipBackOrForward(2000) ; skip forward 2 seconds
            
          Case #SCS_WEDF_AddCueMarker
            addCueMarker()
          Case #SCS_WEDF_CueMarkerNext, #SCS_WEDF_CueMarkerPrev
            skipCueMarker(gnEventMenu)
            
          Case #WQA_mnu_EditCueMarker
            editCueMarker(@grMG5)
          Case #WQA_mnu_RemoveCueMarker
            removeCueMarker(@grMG5)
          Case #WQA_mnu_SetCueMarkerPos
            WQA_mnuSetCueMarkerPosition()
          Case #WQA_mnu_ViewOnCues
            WQF_mnuViewOnCues()
          Case #WQA_mnu_ViewCueMarkersUsage
            WQF_mnuViewCueMarkersUsage(#WQA)
          Case #WQA_mnu_AddQuickCueMarkers
            ; Purpose is to add a Quick Cue Marker to the Current Video File at the mouse click position
            addQuickCueMarker(@grMG5)
          Case #WQA_mnu_RemoveAllUnusedCueMarkersFromThisFile
            removeAllUnusedCueMarkersFromThisFile(nEditAudPtr)
          Case #WQA_mnu_RemoveAllUnusedCueMarkers
            removeAllUnusedCueMarkers()
;           Case #SCS_WEDF_AddCueMarker
;             addCueMarker()
;           Case #SCS_WEDF_CueMarkerNext, #SCS_WEDF_CueMarkerPrev
;             skipCueMarker(gnEventMenu)
          Default
            debugMsg(sProcName, "NOT FOUND")
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg(sProcName, ">>> gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
        
        If gnEventButtonId <> 0
          If gnEventButtonId & #SCS_TRANSPORT_BTN
            WQA_transportBtnClick(gnEventButtonId)
          Else
            Select gnEventButtonId
              Case #SCS_STANDARD_BTN_MOVE_LEFT, #SCS_STANDARD_BTN_MOVE_RIGHT, #SCS_STANDARD_BTN_PLUS, #SCS_STANDARD_BTN_MINUS
                WQA_imgButtonTBS_Click(gnEventButtonId)
            EndSelect
          EndIf
          
        Else
          Select gnEventGadgetNoForEvHdlr
              ; header gadgets
              macHeaderEvents(WQA)
              
              ; detail gadgets in alphabetical order
              
            Case \btnBrowse   ; btnBrowse
              ; debugMsg(sProcName, "calling WQA_btnBrowse_Click()")
              WQA_btnBrowse_Click()
              
            Case WQA\btnEditExternally
              WEC_editFileExternal_Click()
              
            Case \btnRename   ; btnRename
              BTNCLICK(WQA_renameFile())
              
            Case \btnScreens   ; btnScreens
              BTNCLICK(WQA_btnScreens_Click())
              
            Case \btnSubCenter
              LOGEVENT()
              SLD_setValue(WQA\sldSubPan, #SCS_PANCENTRE_SLD)
              WQA_fcSldPanA()
              
            Case \cboAspectRatioType  ; cboAspectRatioType
              CBOCHG(WQA_cboAspectRatioType_Click())
              
            Case \cboQATransType  ; cboQATransType
              CBOCHG(WQA_multiItemValidate())
              
            Case \cboSubTrim  ; cboSubTrim
              CBOCHG(WQA_cboSubTrim_Click())
              
            Case \cboVidAudLogicalDev ; cboVidAudLogicalDev
              CBOCHG(WQA_cboVidAudLogicalDev_Click())
              
            Case \cboVidCapLogicalDev ; Video Capture Logical Device
              CBOCHG(WQA_cboVidCapLogicalDev_Click())         
              
            Case \cboVideoSource ; Video Source
              CBOCHG(WQA_cboVideoSource_Click())
              
            Case \chkContinuous   ; chkContinuous
              CHKOWNCHG(WQA_chkContinuous_Click())
              
            Case \chkLogo    ; chkLogo
              CHKOWNCHG(WQA_chkLogo_Click())
              
            Case \chkOverlay    ; chkOverlay
              CHKOWNCHG(WQA_chkOverlay_Click())
              
            Case \chkPauseAtEnd   ; chkPauseAtEnd
              CHKOWNCHG(WQA_chkPauseAtEnd_Click())
              
            Case \chkPLRepeat   ; chkPLRepeat
              CHKOWNCHG(WQA_chkPLRepeat_Click())
              
            Case \chkShowFileFolders    ; chkShowFileFolders
              CHKOWNCHG(WQA_chkShowFileFolders())
              
            Case \chkPreviewOnOutputScreen    ; chkPreviewOnOutputScreen
              CHKOWNCHG(WQA_chkPreviewOnOutputScreen())
              
            Case \cntForCaptureFrame, \cntSelectedItem, \cntSubDetailA
              ; no action
              
            Case \cvsDummy  ; cvsDummy
              WQA_cvsDummyEvent()
              
            Case \cvsGraphQA
              WQA_cvsGraphQA_Event()
              
            Case \cvsPreview  ; cvsPreview
              WQA_cvsPreviewOrVideoEvent(\cvsPreview, gnEventType, GetGadgetAttribute(\cvsPreview, #PB_Canvas_MouseX), GetGadgetAttribute(\cvsPreview, #PB_Canvas_MouseY))
              
            Case \cvsSideLabelsQA
              WQA_cvsSideLabelsQA_Event()
              
            Case #SCS_G4EH_QA_PICIMAGE  ; cvsTimeLineImage
              If gnEventType = #PB_EventType_LeftButtonDown
                If (aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY) Or (aSub(nEditSubPtr)\nSubState >= #SCS_CUE_PL_READY)
                  ; use sam process, slightly delayed, so that 'lost focus' has a chance to fire following SAG(WQA\txtDummy)
                  samAddRequest(#SCS_SAM_PROCESS_WQA_SELECTED_ITEM, WQA_calcGadgetItem(3), 0, 0, "", ElapsedMilliseconds()+100)
                  SAG(WQA\cvsDummy) ; force a LostFocus event on the current active gadget, if necessary (eg after setting the initial fade-in time)
                Else
                  debugMsg(sProcName, "cvsImage event ignored: aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState))
                EndIf
              EndIf
              
            Case \mbgOther
              WQA_mbgOther_Click()
              
            Case \mbgRotate
              WQA_mbgRotate_Click()
              
            Case \scaSlideShow
              ; do nothing
              
            Case \scaTimeLine
              ; do nothing
              
            Case \txtDisplayTime    ; txtDisplayTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_multiItemValidate())
              EndSelect
              
            Case \txtEndAt    ; txtEndAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_multiItemValidate())
              EndSelect
              
            Case \txtFadeInTime  ; txtFadeInTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtFadeInTime_Validate())
              EndSelect
              
            Case \txtFadeOutTime  ; txtFadeOutTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtFadeOutTime_Validate())
              EndSelect
              
            Case \txtQATransTime   ; txtQATransTime
              Select gnEventType
                Case #PB_EventType_LostFocus
                  debugMsg(sProcName, "\txtTransTime LostFocus")
                  ETVAL(WQA_multiItemValidate())
              EndSelect
              
            Case \txtSize  ; txtSize
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtSize_Validate())
              EndSelect
              
            Case \txtStartAt  ; txtStartAt
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_multiItemValidate())
              EndSelect
              
            Case \txtSubDBLevel  ; txtSubDBLevel
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtSubDBLevel_Validate())
              EndSelect
              
            Case \txtSubPan  ; txtSubPan
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtSubPan_Validate())
              EndSelect
              
            Case \txtXPos  ; txtXPos
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtXPos_Validate())
              EndSelect
              
            Case \txtYPos  ; txtYPos
              Select gnEventType
                Case #PB_EventType_LostFocus
                  ETVAL(WQA_txtYPos_Validate())
              EndSelect
              
            Default
              Select gnEventType
                Case #PB_EventType_Resize
                  ; ignore
                Default
                  debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + " (" + getGadgetName(gnEventGadgetNo) + "), gnEventType=" + decodeEventType())
              EndSelect
              
          EndSelect
          
        EndIf
        
      Case #PB_Event_GadgetDrop
        Select gnEventGadgetNoForEvHdlr
            
          Case \scaTimeLine
            debugMsg(sProcName, "gadget drop on scaTimeLine")
            WQA_processDroppedFiles()
            
          Default
            debugMsg(sProcName, "#PB_Event_GadgetDrop gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
            
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQA_setCurrentItem(nItem, bShowVideoPreviewImage=#True)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nItem=" + nItem)
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If (nItem >= 0) And (nItem <= gnWQALastItem)
    gnWQACurrItem = nItem
    debugMsg(sProcName, "calling WQA_highlightItem(" + strB(bShowVideoPreviewImage) + ")")
    WQA_highlightItem(bShowVideoPreviewImage)
  Else
    WQA_setEnabledStates()
    WQA_setTBSButtons()
    WQA_SetTransportButtons()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_buildMenuGroup_Other()
  PROCNAMEC()
  Protected sMenuText.s
  Protected bEnable
  
  debugMsg(sProcName, #SCS_START)
  
  scsMenuItem(#WQA_mnuOtherDefault, "mnuOtherDefault")
  scsMenuItem(#WQA_mnuOtherCopy, "mnuOtherCopy")
  With grPosSizeAndAspectClipboard
    debugMsg(sProcName, "grPosSizeAndAspectClipboard\bPopulated=" + strB(\bPopulated) + ", \sCopyInfo=" + \sCopyInfo)
    If (\bPopulated) And (Len(\sCopyInfo) > 0)
      sMenuText = LangPars("Menu", "mnuOtherPastePars", \sCopyInfo)
    Else
      sMenuText = Lang("Menu", "mnuOtherPaste")
    EndIf
    debugMsg(sProcName, "sMenuText=" + sMenuText)
    scsMenuItem(#WQA_mnuOtherPaste, sMenuText, "", #False)
  EndWith
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If (\nAspectRatioType <> grAudDef\nAspectRatioType) Or (\nAspectRatioHVal <> grAudDef\nAspectRatioHVal) Or (\nSize <> grAudDef\nSize) Or (\nXPos <> grAudDef\nXPos) Or (\nYPos <> grAudDef\nYPos)
        bEnable = #True
      EndIf
    EndWith
  EndIf
  scsEnableMenuItem(#WQA_mnuOther, #WQA_mnuOtherDefault, bEnable)
  
  If nEditAudPtr >= 0
    scsEnableMenuItem(#WQA_mnuOther, #WQA_mnuOtherCopy, #True)
  Else
    scsEnableMenuItem(#WQA_mnuOther, #WQA_mnuOtherCopy, #False)
  EndIf
  
  If (nEditAudPtr >= 0) And (grPosSizeAndAspectClipboard\bPopulated)
    scsEnableMenuItem(#WQA_mnuOther, #WQA_mnuOtherPaste, #True)
  Else
    scsEnableMenuItem(#WQA_mnuOther, #WQA_mnuOtherPaste, #False)
  EndIf
  
EndProcedure

Procedure WQA_calcGadgetItem(nContainerDepth)
  PROCNAMEC()
  ; procedure to calculate the item number of a gadget in the scaFiles scrollable area.
  ;  the procedure determines the item number from the position of the container of this gadget.
  ;  we cannot use the usual nGadgetArrayIndex because the user may have moved or deleted some items, so the nGadgetArrayIndex then becomes
  ;  out-of-sync with the currently-displayed position.
  ;  NB may need to go up 3 container levels.
  Protected n, nItem, nContainerGadgetNo, nContainerGadgetPropsIndex
  
  nContainerGadgetNo = gaGadgetProps(gnEventGadgetPropsIndex)\nContainerGadgetNo
  nContainerGadgetPropsIndex = getGadgetPropsIndex(nContainerGadgetNo)
  
  For n = 2 To nContainerDepth
    nContainerGadgetNo = gaGadgetProps(nContainerGadgetPropsIndex)\nContainerGadgetNo
    nContainerGadgetPropsIndex = getGadgetPropsIndex(nContainerGadgetNo)
  Next n
  
  nItem = Round(GadgetX(nContainerGadgetNo) / GadgetWidth(nContainerGadgetNo), #PB_Round_Down)
  ; debugMsg(sProcName, "nItem=" + nItem)
  ProcedureReturn nItem
EndProcedure

Procedure WQA_adjustPreviewImageForAspectEtc()
  PROCNAMECA(nEditAudPtr)
  Protected nAdjustedImage
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nAdjustedImage = \nImageAfterRotateAndFlip
    EndWith
  EndIf
  ProcedureReturn nAdjustedImage
EndProcedure

Procedure WQA_drawPreviewImage2(bPreviewCanvasOnly=#False, pFilePos=-1, bTrace=#False)
  PROCNAMECA(nEditAudPtr)
  Protected bDrawBlankImage = #True
  Protected nPreviewWidth, nPreviewHeight
  Protected nPreviewWidth2, nPreviewHeight2
  Protected nVidPicTarget
  Protected nCanvasNo, nCanvasNo2
  Protected sGadgetName.s, sGadgetName2.s
  Protected nPassesReqd, nPassNo
  Protected nMainCanvasNo, bCanvasDrawn
  Protected nImageNo, nDrawingImageNo
  Protected sSizeEtc.s
  Protected nFilePos
  Protected bPreviewCanvasVisible, bVideoCanvasVisible
  Static bStaticLoaded
  Static sUsingShellThumbnail.s
  Static nTextWidth, nTextHeight, nTextLeft, nTextTop
  Protected nIsImageResult
  
  debugMsgC(sProcName, #SCS_START + ", pFilePos=" + pFilePos + ", bPreviewCanvasOnly=" + strB(bPreviewCanvasOnly) + ", gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      debugMsgC(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nOutputScreen=" + \nOutputScreen + ", \sScreens=" + #DQUOTE$ + \sScreens + #DQUOTE$)
    EndWith
  EndIf
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      debugMsgC(sProcName, "calling vMix_PreviewInput(" + getAudLabel(nEditAudPtr) + ")")
      vMix_PreviewInput(nEditAudPtr)
      ; ProcedureReturn
    EndIf
  CompilerEndIf
  
  If (gnPreviewOnOutputScreenNo > 0) And (nEditSubPtr >= 0) And (bPreviewCanvasOnly = #False) And (grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX)
    nVidPicTarget = getVidPicTargetForOutputScreen(aSub(nEditSubPtr)\nOutputScreen)
    If nEditAudPtr >= 0
      ; debugMsg0(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudVideoCanvasNo=" + getGadgetName(aAud(nEditAudPtr)\nAudVideoCanvasNo))
      nCanvasNo = aAud(nEditAudPtr)\nAudVideoCanvasNo(nVidPicTarget)
    EndIf
    If IsGadget(nCanvasNo) = #False
      ; debugMsg0(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTargetCanvasNo=" + getGadgetName(grVidPicTarget(nVidPicTarget)\nTargetCanvasNo))
      nCanvasNo = grVidPicTarget(nVidPicTarget)\nTargetCanvasNo
    EndIf
    sGadgetName = decodeWindow(grVidPicTarget(nVidPicTarget)\nMainWindowNo, #True) + "\" + getGadgetName(nCanvasNo)
    nMainCanvasNo = nCanvasNo
    nCanvasNo2 = WQA\cvsPreview
    sGadgetName2 = "WQA\cvsPreview"
  Else
    nVidPicTarget = #SCS_VID_PIC_TARGET_P
    nCanvasNo = WQA\cvsPreview
    sGadgetName = "WQA\cvsPreview"
  EndIf
  
  If IsGadget(nCanvasNo)
    ; debugMsgC(sProcName, "nCanvasNo=" + getGadgetName(nCanvasNo))
    nPreviewWidth = GadgetWidth(nCanvasNo)
    nPreviewHeight = GadgetHeight(nCanvasNo)
    nPassesReqd = 1
    If IsGadget(nCanvasNo2)
      ; debugMsgC(sProcName, "nCanvasNo2=" + getGadgetName(nCanvasNo2))
      nPreviewWidth2 = GadgetWidth(nCanvasNo2)
      nPreviewHeight2 = GadgetHeight(nCanvasNo2)
      nPassesReqd = 2
    EndIf
    
    For nPassNo = 1 To nPassesReqd
      bCanvasDrawn = #False
      If nPassNo = 2
        nCanvasNo = nCanvasNo2
        sGadgetName = sGadgetName2
        nPreviewWidth = nPreviewWidth2
        nPreviewHeight = nPreviewHeight2
      EndIf
      debugMsgC(sProcName, "nPassNo=" + nPassNo + ", nCanvasNo=" + getGadgetName(nCanvasNo))
      
      If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
        CompilerIf #c_vMix_in_video_cues
          vMix_DrawPreviewText(nCanvasNo, nEditAudPtr)
        CompilerEndIf
        bCanvasDrawn = #True
        
      ElseIf nEditAudPtr >= 0
        With aAud(nEditAudPtr)
          nFilePos = pFilePos
          If nFilePos < 0
            nFilePos = \nAbsStartAt
          EndIf
          sSizeEtc = buildSizeEtc(nEditAudPtr)
          debugMsgC(sProcName, "sSizeEtc=" + sSizeEtc)
          Select \nVideoSource
            Case #SCS_VID_SRC_CAPTURE
              \nFileFormat = #SCS_FILEFORMAT_CAPTURE
              \bUsingShellThumbnail = #False
              If StartDrawing(CanvasOutput(nCanvasNo))
                Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
                StopDrawing()
                bCanvasDrawn = #True
              EndIf
              
            Default
              \bUsingShellThumbnail = #False
              If readImageFromTempDatabase(\sFileName, nPreviewWidth, nPreviewHeight, sSizeEtc, nFilePos, bTrace)
                ; preview image found in database
                debugMsgC(sProcName, "preview image found in database: " + \sFileName)
                If IsImage(grImageBlobInfo\nImageNo)
                  ; should always be #True
                  If StartDrawing(CanvasOutput(nCanvasNo))
                    debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + sGadgetName + "))")
                    DrawImage(ImageID(grImageBlobInfo\nImageNo),0,0)
                    debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(grImageBlobInfo\nImageNo) + "),0,0)")
                    StopDrawing()
                    bCanvasDrawn = #True
                  EndIf
                  \bUsingShellThumbnail = grImageBlobInfo\bShellThumbnail
                  ; don't need image anymore since it's been painted to the canvas
                  FreeImage(grImageBlobInfo\nImageNo)
                  debugMsgD(sProcName, "FreeImage(" + decodeHandle(grImageBlobInfo\nImageNo) + ")")
                  grImageBlobInfo\nImageNo = 0
                EndIf
              Else
                ; preview image NOT found in database, so create preview image AND store it to the database
                debugMsgC(sProcName, "preview image NOT FOUND in database: " + \sFileName)
                If pFilePos < 0
                  loadImageIfReqd(nEditAudPtr)
                  nDrawingImageNo = \nImageAfterRotateAndFlip
                Else
                  loadPosImageIfReqd(nEditAudPtr, pFilePos)
                  nDrawingImageNo = \nPosImageAfterRotateAndFlip
                EndIf
                If IsImage(nDrawingImageNo)
                  nImageNo = scsCreateImage(nPreviewWidth, nPreviewHeight)
                  debugMsgD(sProcName, "scsCreateImage(" + nPreviewWidth + ", " + nPreviewHeight + ") returned " + nImageNo)
                  debugMsgC(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(nEditAudPtr) + ", " + decodeHandle(nImageNo) + ", " + decodeHandle(nDrawingImageNo) + ", #False, " + strB(bTrace) + ")")
                  paintPictureAtPosAndSize(nEditAudPtr, nImageNo, nDrawingImageNo, #False, bTrace)
                  If IsImage(nImageNo)
                    debugMsgC(sProcName, "calling saveImageDataToTempDatabase(" + getAudLabel(nEditAudPtr) + ", " + nImageNo + ", " + nFilePos + ")")
                    saveImageDataToTempDatabase(nEditAudPtr, nImageNo, nFilePos)
                    If StartDrawing(CanvasOutput(nCanvasNo))
                      debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
                      DrawImage(ImageID(nImageNo),0,0)
                      debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(nImageNo) + "),0,0)")
                      StopDrawing()
                      bCanvasDrawn = #True
                    EndIf
                    If IsGadget(nCanvasNo2)
                      debugMsgC(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(nEditAudPtr) + ", " + getGadgetName(nCanvasNo2) + ", " + decodeHandle(\nImageAfterRotateAndFlip) + ", #True, " + strB(bTrace) + ")")
                      paintPictureAtPosAndSize(nEditAudPtr, nCanvasNo2, nDrawingImageNo, #True, bTrace)
                    EndIf
                    ; don't need image anymore since it's been painted to the canvas
                    FreeImage(nImageNo)
                    debugMsgD(sProcName, "FreeImage(" + decodeHandle(nImageNo) + ")")
                  EndIf
                  grVidPicTarget(nVidPicTarget)\bShowingPreviewImage = #True
                  debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShowingPreviewImage=" + strB(grVidPicTarget(nVidPicTarget)\bShowingPreviewImage))
                EndIf
              EndIf
              If \bUsingShellThumbnail
                If StartDrawing(CanvasOutput(nCanvasNo))
                  debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
                  DrawingFont(FontID(#SCS_FONT_GEN_NORMAL))
                  If bStaticLoaded = #False
                    sUsingShellThumbnail = " " + Lang("WQA", "DispShellThumbShort") + " "
                    nTextWidth = TextWidth(sUsingShellThumbnail)
                    nTextHeight = TextHeight(sUsingShellThumbnail)
                    If nTextWidth < GadgetWidth(nCanvasNo)
                      nTextLeft = (GadgetWidth(nCanvasNo) - nTextWidth) >> 1
                    EndIf
                    nTextTop = GadgetHeight(nCanvasNo) - nTextHeight - gl3DBorderHeight
                    bStaticLoaded = #True
                  EndIf
                  DrawText(nTextLeft, nTextTop, sUsingShellThumbnail, #SCS_Light_Yellow, #SCS_Black)
                  debugMsgD(sProcName, "DrawText(" + nTextLeft + ", " + nTextTop + ", '" + sUsingShellThumbnail + "', #SCS_Light_Yellow, #SCS_Black)")
                  StopDrawing()
                  bCanvasDrawn = #True
                EndIf
              EndIf
          EndSelect
          bDrawBlankImage = #False
        EndWith
      EndIf
      
      If bCanvasDrawn = #False And bDrawBlankImage
        debugMsgC(sProcName, "bDrawBlankImage=" + strB(bDrawBlankImage))
        If StartDrawing(CanvasOutput(nCanvasNo))
          debugMsgD(sProcName, "StartDrawing(CanvasOutput(" + sGadgetName + "))")
          DrawImage(ImageID(WQA\imgPreviewBlank), 0, 0, nPreviewWidth, nPreviewHeight)
          debugMsgD(sProcName, "DrawImage(ImageID(" + decodeHandle(WQA\imgPreviewBlank) + "), 0, 0, " + nPreviewWidth + ", " + nPreviewHeight + ") [blank]")
          StopDrawing()
          bCanvasDrawn = #True
        EndIf
      EndIf
      
      If getVisible(nCanvasNo) = #False
        If nCanvasNo = WQA\cvsPreview
          setVisible(nCanvasNo, #True)
        Else
          setVideoCanvasVisible(nVidPicTarget, nCanvasNo, #True)
        EndIf
      EndIf
      
      If bCanvasDrawn
        If nCanvasNo = nMainCanvasNo
          If grVidPicTarget(nVidPicTarget)\nTargetCanvasNo <> nCanvasNo
            grVidPicTarget(nVidPicTarget)\nTargetCanvasNo = nCanvasNo
            debugMsgC(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTargetCanvasNo=" + getGadgetName(grVidPicTarget(nVidPicTarget)\nTargetCanvasNo))
          EndIf
        EndIf
      EndIf
      
    Next nPassNo
    
  EndIf ; EndIf IsGadget(nCanvasNo)
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_drawPreviewImage(bPreviewCanvasOnly=#False, pFilePos=-1)
  PROCNAMECA(nEditAudPtr)
  Protected nVidPicTarget, nChannel.l
  
  debugMsg(sProcName, #SCS_START + ", pFilePos=" + pFilePos + ", bPreviewCanvasOnly=" + strB(bPreviewCanvasOnly) + ", gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo)
  
  If nEditSubPtr >= 0
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nOutputScreen=" + aSub(nEditSubPtr)\nOutputScreen + ", \sScreens=" + #DQUOTE$ + aSub(nEditSubPtr)\sScreens + #DQUOTE$)
  EndIf
  
  nVidPicTarget = #SCS_VID_PIC_TARGET_P
  debugMsg(sProcName, "calling openVideoFileForTVG(" + getAudLabel(nEditAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
  nChannel = openVideoFileForTVG(nEditAudPtr, nVidPicTarget)
  debugMsg(sProcName, "openVideoFileForTVG(" + getAudLabel(nEditAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ") returned nChannel=" + nChannel)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_drawPreviewPosImage2(pPos)
  PROCNAMECA(nEditAudPtr)
  Protected bDrawBlankImage = #True
  Protected nWidth, nHeight
  
  debugMsg(sProcName, #SCS_START + ", pPos=" + pPos)
  
  nWidth = GadgetWidth(WQA\cvsPreview)
  nHeight = GadgetHeight(WQA\cvsPreview)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      loadPosImageIfReqd(nEditAudPtr, pPos)
      If IsImage(\nPosImageAfterRotateAndFlip)
        debugMsg3(sProcName, "calling paintPictureAtPosAndSize(" + getAudLabel(nEditAudPtr) + ", WQA\cvsPreview, " + \nPosImageAfterRotateAndFlip + ", #True)")
        paintPictureAtPosAndSize(nEditAudPtr, WQA\cvsPreview, \nPosImageAfterRotateAndFlip, #True)
        bDrawBlankImage = #False
      EndIf
    EndWith
  EndIf
  
  If bDrawBlankImage
    If StartDrawing(CanvasOutput(WQA\cvsPreview))
      debugMsgD(sProcName, "StartDrawing(CanvasOutput(WQA\cvsPreview))")
      DrawImage(ImageID(WQA\imgPreviewBlank), 0, 0, nWidth, nHeight)
      debugMsgD(sProcName, "DrawImage(ImageID(" + WQA\imgPreviewBlank + "), 0, 0, " + nWidth + ", " + nHeight + ") [blank]")
      StopDrawing()
    EndIf
  EndIf
  
  If getVisible(WQA\cvsPreview) = #False
    setVisible(WQA\cvsPreview, #True)
    debugMsgD(sProcName, "setVisible(WQA\cvsPreview, #True)")
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_drawTimeLineImage()
  PROCNAMECA(nEditAudPtr)
  Protected bDrawBlankImage = #True
  Protected nLeft, nTop, nWidth, nHeight
  Protected nImageNo
  Protected nTimeLineImageWidth, nTimeLineImageHeight
  Protected nIsImageResult
  
  debugMsg(sProcName, #SCS_START)
  
  nTimeLineImageWidth = GadgetWidth(WQAFile(gnWQACurrItem)\cvsTimeLineImage)
  nTimeLineImageHeight = GadgetHeight(WQAFile(gnWQACurrItem)\cvsTimeLineImage)
  debugMsg(sProcName, "nTimeLineImageWidth=" + nTimeLineImageWidth + ", nTimeLineImageHeight=" + nTimeLineImageHeight + ", gnWQACurrItem=" + gnWQACurrItem)

  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      Select \nVideoSource
        Case #SCS_VID_SRC_CAPTURE
          debugMsg(sProcName, "Video Capture Source - Paint Image to Canvas")
          debugMsg(sProcName, "hVideoCaptionLogo="+hVideoCaptionLogo)
          nIsImageResult = IsImage(hVideoCaptionLogo)
          debugMsg(sProcName, "hVideoCaptionLogo="+hVideoCaptionLogo+" nIsImageResult="+nIsImageResult)
          If nIsImageResult ;TODO - This is coming up ZERO after the intitial loading and changing of Capture Mode to File mode and back again
            nImageNo = scsCreateImage(nTimeLineImageWidth, nTimeLineImageHeight)
            paintPictureAtPosAndSize(nEditAudPtr, nImageNo, hVideoCaptionLogo, #False)
            If StartDrawing(CanvasOutput(WQAFile(gnWQACurrItem)\cvsTimeLineImage))
              debugMsg3(sProcName, "StartDrawing(CanvasOutput(WQAFile(" + gnWQACurrItem + ")\cvsTimeLineImage))")
              debugMsg(sProcName, "drawing timeline image for " + GetFilePart(\sFileName))
              DrawImage(ImageID(nImageNo),0,0)
              debugMsg3(sProcName, "DrawImage(ImageID(" + nImageNo + "),0,0," + #SCS_QATIMELINE_IMAGE_WIDTH + "," + #SCS_QATIMELINE_IMAGE_HEIGHT + ")")
              StopDrawing()
              bDrawBlankImage = #False
            EndIf
          EndIf
        Default
          If IsImage(\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T))
            If StartDrawing(CanvasOutput(WQAFile(gnWQACurrItem)\cvsTimeLineImage))
              debugMsg3(sProcName, "StartDrawing(CanvasOutput(WQAFile(" + gnWQACurrItem + ")\cvsTimeLineImage))")
              debugMsg(sProcName, "drawing timeline image for " + GetFilePart(\sFileName))
              DrawImage(ImageID(\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T)),0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT)
              debugMsg3(sProcName, "DrawImage(ImageID(" + \nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_T) + "),0,0," + #SCS_QATIMELINE_IMAGE_WIDTH + "," + #SCS_QATIMELINE_IMAGE_HEIGHT + ")")
              StopDrawing()
              bDrawBlankImage = #False
            EndIf
          EndIf
      EndSelect
    EndWith
  EndIf
  
  If bDrawBlankImage
    If StartDrawing(CanvasOutput(WQAFile(gnWQACurrItem)\cvsTimeLineImage))
      debugMsg3(sProcName, "StartDrawing(CanvasOutput(WQAFile(" + gnWQACurrItem + ")\cvsTimeLineImage))")
      debugMsg(sProcName, "drawing blank image")
      DrawImage(ImageID(WQA\imgBlankItem),0,0,#SCS_QATIMELINE_IMAGE_WIDTH,#SCS_QATIMELINE_IMAGE_HEIGHT)
      debugMsg3(sProcName, "DrawImage(ImageID(" + WQA\imgBlankItem + "),0,0," + #SCS_QATIMELINE_IMAGE_WIDTH + "," + #SCS_QATIMELINE_IMAGE_HEIGHT + ") [blank]")
      StopDrawing()
    EndIf
  EndIf
  
EndProcedure

Procedure WQA_drawTimeLineImage2(nItemNo, bTrace=#False)
  PROCNAMEC()
  Protected nAudPtr
  Protected bDrawBlankImage = #True
  Protected sToolTip.s
  Protected nTimeLineImageWidth, nTimeLineImageHeight
  Protected nImageNo, sSizeEtc.s
  
  debugMsgC(sProcName, #SCS_START + ", nItemNo=" + nItemNo + ", bTrace=" + strB(bTrace))
  
  nTimeLineImageWidth = GadgetWidth(WQAFile(nItemNo)\cvsTimeLineImage)
  nTimeLineImageHeight = GadgetHeight(WQAFile(nItemNo)\cvsTimeLineImage)
  ; debugMsgC(sProcName, "nTimeLineImageWidth=" + nTimeLineImageWidth + ", nTimeLineImageHeight=" + nTimeLineImageHeight)
  
  If nItemNo >= 0
    nAudPtr = WQAFile(nItemNo)\nFileAudPtr
    ; debugMsgC(sProcName, "nAudPtr=" + getAudLabel(nAudPtr))
    If nAudPtr >= 0
      sProcName = buildAudProcName(#PB_Compiler_Procedure, nAudPtr)
      With aAud(nAudPtr)
        sSizeEtc = buildSizeEtc(nAudPtr)
        If readImageFromTempDatabase(\sFileName, nTimeLineImageWidth, nTimeLineImageHeight, sSizeEtc, \nAbsStartAt, bTrace)
          ; thumbnail found in database
          debugMsgC(sProcName, "thumbnail found in database: " + \sFileName)
          If IsImage(grImageBlobInfo\nImageNo)
            ; should always be #True
            If StartDrawing(CanvasOutput(WQAFile(nItemNo)\cvsTimeLineImage))
              DrawImage(ImageID(grImageBlobInfo\nImageNo),0,0)
              StopDrawing()
            EndIf
            ; don't need image anymore since it's been painted to the canvas
            FreeImage(grImageBlobInfo\nImageNo)
            debugMsgC(sProcName, "FreeImage(" + grImageBlobInfo\nImageNo + ")")
            grImageBlobInfo\nImageNo = 0
          EndIf
        Else
          ; thumbnail NOT found in database, so create thumbnail image AND store it to the database
          debugMsgC(sProcName, "thumbnail NOT FOUND in database: " + \sFileName)
          debugMsgC(sProcName, "\nLoadImageNo=" + \nLoadImageNo + ", \nImageAfterRotateAndFlip=" + \nImageAfterRotateAndFlip)
          ; debugMsgC(sProcName, "IsImage(" + \nLoadImageNo + ")=" + IsImage(\nLoadImageNo) + ", IsImage(" + \nImageAfterRotateAndFlip + ")=" + IsImage(\nImageAfterRotateAndFlip))
          debugMsgC(sProcName, "calling loadImageIfReqd(" + getAudLabel(nAudPtr) + ", " + strB(bTrace) + ")")
          loadImageIfReqd(nAudPtr, bTrace)
          debugMsgC(sProcName, "\nLoadImageNo=" + decodeHandle(\nLoadImageNo) + ", \nImageAfterRotateAndFlip=" + decodeHandle(\nImageAfterRotateAndFlip))
          If IsImage(\nImageAfterRotateAndFlip)
            debugMsgC(sProcName, "ImageWidth(" + decodeHandle(\nImageAfterRotateAndFlip) + ")=" + ImageWidth(\nImageAfterRotateAndFlip) + ", ImageHeight(" + decodeHandle(\nImageAfterRotateAndFlip) + ")=" + ImageHeight(\nImageAfterRotateAndFlip))
            nImageNo = scsCreateImage(nTimeLineImageWidth, nTimeLineImageHeight)
            paintPictureAtPosAndSize(nAudPtr, nImageNo, \nImageAfterRotateAndFlip, #False, bTrace)
            If IsImage(nImageNo)
              debugMsgC(sProcName, "calling saveImageDataToTempDatabase(" + getAudLabel(nAudPtr) + ", " + nImageNo + ", " + \nAbsStartAt + ", " + strB(bTrace) + ")")
              saveImageDataToTempDatabase(nAudPtr, nImageNo, \nAbsStartAt, bTrace)
              If StartDrawing(CanvasOutput(WQAFile(nItemNo)\cvsTimeLineImage))
                DrawImage(ImageID(nImageNo),0,0)
                StopDrawing()
              EndIf
              ; don't need image anymore since it's been painted to the canvas
              FreeImage(nImageNo)
              debugMsgC(sProcName, "FreeImage(" + nImageNo + ")")
            EndIf
            If \nImageAfterRotateAndFlip <> \nLoadImageNo
              FreeImage(aAud(nAudPtr)\nImageAfterRotateAndFlip)
              debugMsgC(sProcName, "FreeImage(" + aAud(nAudPtr)\nImageAfterRotateAndFlip + ")")
            EndIf
            \nImageAfterRotateAndFlip = grAudDef\nImageAfterRotateAndFlip
          EndIf
        EndIf
        bDrawBlankImage = #False
        sToolTip = \sFileName
        If \bUsingShellThumbnail
          sToolTip + Chr(10) + Lang("WQA", "DispShellThumbLong")
        EndIf
        If \nVideoSource = #SCS_VID_SRC_CAPTURE
          scsToolTip(WQAFile(nItemNo)\cvsTimeLineImage, "")
        Else
          scsToolTip(WQAFile(nItemNo)\cvsTimeLineImage, sToolTip)
        EndIf
      EndWith
    EndIf
  EndIf
  
  If bDrawBlankImage
    If StartDrawing(CanvasOutput(WQAFile(nItemNo)\cvsTimeLineImage))
      ; debugMsg3(sProcName, "StartDrawing(CanvasOutput(WQAFile(" + nItemNo + ")\cvsTimeLineImage))")
      ; debugMsgC(sProcName, "drawing blank image")
      DrawImage(ImageID(WQA\imgBlankItem),0,0,nTimeLineImageWidth,nTimeLineImageHeight)
      ; debugMsg3(sProcName, "DrawImage(ImageID(" + decodeHandle(WQA\imgBlankItem) + "),0,0," + nTimeLineImageWidth + "," + nTimeLineImageHeight + ") [blank]")
      StopDrawing()
    EndIf
  EndIf
  
  ; debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_processDroppedFiles()
  PROCNAMECS(nEditSubPtr)
  Protected sDroppedFiles.s
  Protected nFileCount
  Protected Dim sFileName.s(0)
  Protected nScrollAreaX, nFirstVisibleItemNo, nVisibleItemNo, nActualItemNo
  Protected sFileName.s, sFileExt.s, sStoredFileName.s
  Protected n, nNewIndex, bEmptyItemFound
  Protected u
  Protected Dim u4(0)
  Protected Dim sNewFileName.s(0)
  Protected Dim nNewAudPtr(0)
  Protected bInsertAfterCurrentEntry
  
  sDroppedFiles = EventDropFiles()
  nFileCount = CountString(sDroppedFiles, Chr(10)) + 1
  debugMsg(sProcName, "nFileCount=" + nFileCount)
  debugMsg(sProcName, "sDroppedFiles=" + sDroppedFiles)
  
  If nFileCount = 0
    ProcedureReturn
  EndIf
  
  nScrollAreaX = GetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X)
  nFirstVisibleItemNo = Round(nScrollAreaX / (#SCS_QAITEM_WIDTH), #PB_Round_Nearest)
  nVisibleItemNo = Round(EventDropX() / (#SCS_QAITEM_WIDTH), #PB_Round_Nearest)
  nActualItemNo = nFirstVisibleItemNo + nVisibleItemNo
  If nActualItemNo > aSub(nEditSubPtr)\nAudCount
    nActualItemNo = aSub(nEditSubPtr)\nAudCount
    If nActualItemNo < 0
      nActualItemNo = 0
    EndIf
  EndIf
  
  debugMsg(sProcName, "nActualItemNo=" + nActualItemNo)
  
  ; Check the data
  For n = 1 To nFileCount
    sFileName = StringField(sDroppedFiles, n, Chr(10))
    sFileExt = LCase(GetExtensionPart(sFileName))
    If FindString(gsVideoImageFileTypes, sFileExt) = 0
      scsMessageRequester(Lang("WQA", "Drag&Drop"), LangPars("Errors", "FileFormatNotSupported", GetFilePart(sFileName)), #PB_MessageRequester_Error)
      ProcedureReturn
    EndIf
  Next n
  
  If nActualItemNo <= gnWQALastItem
    gnWQACurrItem = nActualItemNo
  Else
    gnWQACurrItem = gnWQALastItem
    bInsertAfterCurrentEntry = #True
  EndIf
  
  ; Get the data
  ReDim u4(nFileCount)
  ReDim sNewFileName(nFileCount)
  ReDim nNewAudPtr(nFileCount)
  
  u = preChangeSubL(#True, "Video/Image Drag-and-Drop")
  For n = 1 To nFileCount
    sFileName = StringField(sDroppedFiles, n, Chr(10))
    nNewIndex = insertWQAFile(bInsertAfterCurrentEntry)
    setEditAudPtr(-1)
    u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
    If nEditAudPtr < 0
      ProcedureReturn
    EndIf
    debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr)
    With aAud(nEditAudPtr)
      nNewAudPtr(n) = nEditAudPtr
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
      \nFileFormat = getFileFormat(sFileName)
      debugMsg(sProcName, "\sFileName=" + \sFileName)
      If getInfoAboutFile(\sFileName)
        \nFileDuration = grInfoAboutFile\nFileDuration
        \nFileChannels = grInfoAboutFile\nFileChannels
        \sFileTitle = grInfoAboutFile\sFileTitle
      Else
        debugMsg(sProcName, "getInfoAboutFile returned false for " + \sFileName)
      EndIf
      setDerivedAudFields(nEditAudPtr)
      WQAFile(gnWQACurrItem)\nFileAudPtr = nEditAudPtr
      debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + getAudLabel(WQAFile(gnWQACurrItem)\nFileAudPtr))
      WQAFile(gnWQACurrItem)\nFileNameLen = Len(\sFileName)
      debugMsg(sProcName, "calling loadAndFitAPicture(" + getAudLabel(nEditAudPtr) + ", " + decodeVidPicTarget(#SCS_VID_PIC_TARGET_T) + ")")
      If loadAndFitAPicture(nEditAudPtr, #SCS_VID_PIC_TARGET_T)
        WQA_drawTimeLineImage()
      EndIf
      WQA_drawTimeLineImage2(gnWQACurrItem)
      SGT(WQAFile(gnWQACurrItem)\lblFileName, ignoreExtension(GetFilePart(\sFileName)))
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        \bContinuous = grLastPicInfo\bLastPicContinuous
        If \nEndAt > 0 And \bContinuous = #False
          \nEndAt = grLastPicInfo\nLastPicEndAt
        EndIf
        \nPLTransType = grLastPicInfo\nLastPicTransType
        \nPLTransTime = grLastPicInfo\nLastPicTransTime
      EndIf
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nCueDuration=" + \nCueDuration)
      SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      sNewFileName(n) = \sFileName
    EndWith
  Next n
  
  WQA_updateAudsFromWQAFile(nEditSubPtr)  ; nb sets nPlTrkNo's in aAud's
  setLabels(nEditCuePtr)
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  
  For n = 1 To nFileCount
    postChangeAudL(u4(n), #False, nNewAudPtr(n))
  Next n
  
  debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
  WQA_resetSubDescrIfReqd()
  
  postChangeSubL(u, #False)
  
  ; create an empty item if required
  bEmptyItemFound = #False
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileNameLen = 0
      bEmptyItemFound = #True
      Break
    EndIf
  Next n
  If bEmptyItemFound = #False
    debugMsg(sProcName, "calling createWQAFile()")
    createWQAFile()
  EndIf
  
  debugMsg(sProcName, "calling WQA_setCurrentItem(" + nActualItemNo + ")")
  WQA_setCurrentItem(nActualItemNo)   ; select first added row
  
  setFileSave()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_updateAudsFromWQAFile(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nPrevAudIndex, nAudPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  nPrevAudIndex = -1
  With aSub(pSubPtr)
    debugMsg(sProcName, "gnWQACurrItem=" + gnWQACurrItem + ", gnWQALastItem=" + gnWQALastItem)
    For n = 0 To gnWQALastItem
      debugMsg(sProcName, "WQAFile(" + n + ")\nFileAudPtr=" + WQAFile(n)\nFileAudPtr)
      nAudPtr = WQAFile(n)\nFileAudPtr
      If nAudPtr > 0 And nAudPtr <= gnLastAud
        debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr))
        If nPrevAudIndex = -1
          aSub(pSubPtr)\nFirstAudIndex = nAudPtr
        Else
          aAud(nPrevAudIndex)\nNextAudIndex = nAudPtr
        EndIf
        aAud(nAudPtr)\nPrevAudIndex = nPrevAudIndex
        nPrevAudIndex = nAudPtr
      EndIf
    Next n
    
    If nPrevAudIndex = -1
      aSub(pSubPtr)\nFirstAudIndex = -1
    Else
      aAud(nPrevAudIndex)\nNextAudIndex = -1
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, "calling setDerivedSubFields(" + getSubLabel(pSubPtr) + ")")
  setDerivedSubFields(pSubPtr)
  WQA_doSubTotals()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_resetSubDescrIfReqd(bForceReset=#False)
  PROCNAMECS(nEditSubPtr)
  Protected sOldSubDescr.s
  Protected bCueChanged, bSubChanged, k
  Protected u2
  
  ; debugMsg(sProcName, #SCS_START + ", bForceReset=" + strB(bForceReset))
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; debugMsg(sProcName, "\bDefaultSubDescrMayBeSet=" + strB(\bDefaultSubDescrMayBeSet) + ", \nAudCount=" + \nAudCount)
      If (\bDefaultSubDescrMayBeSet) And (\nAudCount >= 0)
        sOldSubDescr = \sSubDescr
        k = \nFirstAudIndex
        ; debugMsg(sProcName, "\nAudCount=" + \nAudCount + ", k=" + getAudLabel(k))
        If (\nAudCount = 1) And (k >= 0)
          If aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\sVideoCaptureLogicalDevice=" + aAud(k)\sVideoCaptureLogicalDevice)
            \sSubDescr = aAud(k)\sVideoCaptureLogicalDevice
          Else
            If (aAud(k)\sFileTitle) And (grEditingOptions\bIgnoreTitleTags = #False)
              \sSubDescr = aAud(k)\sFileTitle
            Else
              \sSubDescr = ignoreExtension(GetFilePart(aAud(k)\sFileName))
            EndIf
          EndIf
          \bSubPlaceHolder = #False
        ElseIf \nAudCount = 0
          \sSubDescr = grText\sTextPlaceHolder
          \bSubPlaceHolder = #True
        Else
          \sSubDescr = Lang("WQA", "dfltDescr")
          \bSubPlaceHolder = #False
        EndIf
        ; debugMsg(sProcName, "GGT(WQA\txtSubDescr)=" + GGT(WQA\txtSubDescr) + ", \sSubDescr=" + \sSubDescr)
        If GGT(WQA\txtSubDescr) <> \sSubDescr Or bForceReset
          SGT(WQA\txtSubDescr, \sSubDescr)
          setSubDescrToolTip(WQA\txtSubDescr)
          WED_setSubNodeText(nEditSubPtr)
          bSubChanged = #True
          If \nPrevSubIndex = -1
            If aCue(nEditCuePtr)\sCueDescr = sOldSubDescr
              u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, "Video Source") ; Trim(GGT(WQA\lblPnlHdg)))
              aCue(nEditCuePtr)\sCueDescr = \sSubDescr
              bCueChanged = #True
              If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
                SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
                WED_setCueNodeText(nEditCuePtr)
                aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
              EndIf
              postChangeCueS(u2, aCue(nEditCuePtr)\sCueDescr)
            EndIf
          EndIf
        EndIf
        PNL_reloadDispPanelForSub(nEditSubPtr)
      EndIf
      
      If bCueChanged
        loadGridRow(nEditCuePtr)
      EndIf
      
      ; debugMsg(sProcName, "bSubChanged=" + strB(bSubChanged) + ", \nPrevSubIndex=" + \nPrevSubIndex + ", \nNextSubIndex=" + \nNextSubIndex + ", \bSubPlaceHolder=" + strB(\bSubPlaceHolder))
      If bSubChanged
        If \nPrevSubIndex >= 0 Or \nNextSubIndex >= 0 Or \bSubPlaceHolder
          ; multiple sub-cues, or placeholder
          debugMsg(sProcName, "calling WED_setCueNodeText(" + getCueLabel(nEditCuePtr) + ")")
          WED_setCueNodeText(nEditCuePtr)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQA_setTBSButtons()
  PROCNAMEC()
  Protected bEnableMoveLeft, sToolTipMoveLeft.s
  Protected bEnableMoveRight, sToolTipMoveRight.s
  Protected bEnableInsFile, sToolTipInsFile.s
  Protected bEnableDelFile, sToolTipDelFile.s
  Protected bEnableRename, sToolTipRename.s
  Protected sFileName.s, bFileNamePresent
  Protected sToolTipFile.s
  Protected nLastFile
  Protected n, nAudPtr
  Protected nFirstSelectedItem, nLastSelectedItem, nSelectedItemCount
  Protected nVideoSource, bVideoCapturePresent
  
  debugMsg(sProcName, #SCS_START)
  
  If aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY Or aSub(nEditSubPtr)\nSubState >= #SCS_CUE_PL_READY
    
    nFirstSelectedItem = -1
    nLastSelectedItem = -1
    nLastFile = -1
    For n = 0 To gnWQALastItem
      With WQAFile(n)
        If \bSelected
          nSelectedItemCount + 1
          If nFirstSelectedItem = -1
            nFirstSelectedItem = n
          EndIf
          nLastSelectedItem = n
        EndIf
        If \nFileAudPtr > 0
          nLastFile = n
        EndIf
      EndWith
    Next n
    
    nAudPtr = -1
    If nSelectedItemCount = 1
      nAudPtr = WQAFile(nFirstSelectedItem)\nFileAudPtr
      sToolTipFile = Str(nFirstSelectedItem + 1)
    EndIf
    debugMsg(sProcName, "nSelectedItemCount=" + nSelectedItemCount + ", nFirstSelectedItem=" + nFirstSelectedItem + ", nAudPtr=" + nAudPtr)
    If nAudPtr >= 0
      CheckSubInRange(nAudPtr, ArraySize(aAud()), "aAud()")
      sFileName = GetFilePart(aAud(nAudPtr)\sFileName)
      If sFileName
        bFileNamePresent = #True
        sToolTipFile + " (" + sFileName + ")"
      EndIf
      ; Video Capture Setting
      If nEditAudPtr > -1
        nVideoSource = aAud(nEditAudPtr)\nVideoSource
        If nVideoSource = #SCS_VID_SRC_CAPTURE
          bVideoCapturePresent = #True
          sToolTipFile = ""
        EndIf 
      EndIf
    EndIf
    
    If (nFirstSelectedItem > 0) And (nFirstSelectedItem <= nLastFile)
      bEnableMoveLeft = #True
      sToolTipMoveLeft = LangPars("WQA", "tbsMoveFileLeftTT", sToolTipFile)
    EndIf
    If nLastSelectedItem < nLastFile
      bEnableMoveRight = #True
      sToolTipMoveRight = LangPars("WQA", "tbsMoveFileRightTT", sToolTipFile)
    EndIf
    If nSelectedItemCount = 1
      If bFileNamePresent Or bVideoCapturePresent
        bEnableDelFile = #True
      EndIf
    ElseIf nSelectedItemCount > 0
      bEnableDelFile = #True
    EndIf
    ; Added Video Capture Setting
    If bFileNamePresent Or bVideoCapturePresent
      bEnableInsFile = #True
      sToolTipInsFile = LangPars("WQA", "tbsInsFileTT", sToolTipFile)
      bEnableRename = #True
      sToolTipRename = LangPars("WQA", "tbsRenameTT", sToolTipFile)
      sToolTipDelFile = LangPars("WQA", "tbsDelFileTT", sToolTipFile)
    EndIf
    ; Video Capture Setting
    If bVideoCapturePresent
      bEnableRename = #False
    EndIf
    
  EndIf
  
  setEnabled(WQA\imgButtonTBS[0], bEnableMoveLeft)
  scsToolTip(WQA\imgButtonTBS[0], sToolTipMoveLeft)
  
  setEnabled(WQA\imgButtonTBS[1], bEnableMoveRight)
  scsToolTip(WQA\imgButtonTBS[1], sToolTipMoveRight)
  
  setEnabled(WQA\imgButtonTBS[2], bEnableInsFile)
  scsToolTip(WQA\imgButtonTBS[2], sToolTipInsFile)
  
  setEnabled(WQA\imgButtonTBS[3], bEnableDelFile)
  scsToolTip(WQA\imgButtonTBS[3], sToolTipDelFile)
  
  setEnabled(WQA\btnRename, bEnableRename)
  scsToolTip(WQA\btnRename, sToolTipRename)
  
EndProcedure

Procedure WQA_imgButtonTBS_Click(nButtonId)
  PROCNAMEC()
  Protected nIndex, nNewIndex, nAudPtr
  Protected u, u2
  Protected rTmpWQAFile.strWQAFile
  Protected n
  Protected bCueMarkerFound
  Protected nThisCueMarkerId, sMsg.s, sShortDescr1.s, sShortDescr2.s
  Protected i, j
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = gnWQACurrItem
  nNewIndex = gnWQACurrItem
  
  Select nButtonId
      
    Case #SCS_STANDARD_BTN_MOVE_LEFT  ; move left
      debugMsg(sProcName, "move left")
      u = preChangeSubL(#True, "Move Video/Image Left", -5, #SCS_UNDO_ACTION_CHANGE, -1)
      For n = 1 To gnWQALastItem  ; nb skip index 0 as we are moving items left, so item 0 cannot be moved
        If WQAFile(n)\bSelected
          ; move this element back one position, ie swap this element with the previous element
          rTmpWQAFile = WQAFile(n-1)
          WQAFile(n-1) = WQAFile(n)
          WQAFile(n) = rTmpWQAFile
          WQAFile(n-1)\bTimelineUpdateReqd = #True
          WQAFile(n)\bTimelineUpdateReqd = #True
        EndIf
      Next n
      nNewIndex - 1
      
    Case #SCS_STANDARD_BTN_MOVE_RIGHT  ; move right
      debugMsg(sProcName, "move right")
      u = preChangeSubL(#True, "Move Video/Image Right", -5, #SCS_UNDO_ACTION_CHANGE, -1)
      For n = (gnWQALastItem-1) To 0 Step -1  ; nb ignore index gnWQALastItem as we are moving items right, so item gnWQALastItem cannot be moved
        If WQAFile(n)\bSelected
          ; move this element forward one position, ie swap this element with the next element
          rTmpWQAFile = WQAFile(n+1)
          WQAFile(n+1) = WQAFile(n)
          WQAFile(n) = rTmpWQAFile
          WQAFile(n+1)\bTimelineUpdateReqd = #True
          WQAFile(n)\bTimelineUpdateReqd = #True
        EndIf
      Next n
      nNewIndex + 1
      
    Case #SCS_STANDARD_BTN_PLUS ; insert file
      debugMsg(sProcName, "insert file")
      u = preChangeSubL(#True, "Add Video/Image File", -5, #SCS_UNDO_ACTION_CHANGE, -1)
      debugMsg(sProcName, "BTN_PLUS calling WQA_btnBrowse_Click(#True)")
      WQA_btnBrowse_Click(#True)
      
    Case #SCS_STANDARD_BTN_MINUS  ; remove file
      debugMsg(sProcName, "remove file")
      For n = 0 To gnWQALastItem
        If WQAFile(n)\bSelected
          nAudPtr = WQAFile(n)\nFileAudPtr
          If nAudPtr >= 0
            With aAud(nAudPtr)
              ; debugMsg0(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nMaxCueMarker=" + \nMaxCueMarker)
              If \nMaxCueMarker >= 0
                ; This video file item contains one or more cue markers, so check that no other cues use any of these markers
                sShortDescr1 = makeShortDescr(getAudLabel(nAudPtr), aAud(nAudPtr)\sFileTitle)
                For n = 0 To \nMaxCueMarker
                  nThisCueMarkerId = \aCueMarker(n)\nCueMarkerId
                  For i = 1 To gnLastCue
                    If aCue(i)\nActivationMethod = #SCS_ACMETH_OCM
                      If aCue(i)\nAutoActCueMarkerId = nThisCueMarkerId
                        sShortDescr2 = makeShortDescr(getCueLabel(i), aCue(i)\sCueDescr)
                        sMsg = LangPars("Errors", "CannotDeleteItem", sShortDescr1, sShortDescr2)
                        debugMsg(sProcName, "sMsg=" + sMsg)
                        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
                        ProcedureReturn
                      EndIf
                    EndIf
                    j = aCue(i)\nFirstSubIndex
                    While j >= 0
                      If aSub(j)\nSubStart = #SCS_SUBSTART_OCM
                        If aSub(j)\nSubCueMarkerId = nThisCueMarkerId
                          sShortDescr2 = makeShortDescr(getSubLabel(j), aSub(j)\sSubDescr)
                          sMsg = LangPars("Errors", "CannotDeleteItem", sShortDescr1, sShortDescr2)
                          debugMsg(sProcName, "sMsg=" + sMsg)
                          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
                          ProcedureReturn
                        EndIf
                      EndIf
                      j = aSub(j)\nNextSubIndex
                    Wend ; End While j >= 0
                  Next i
                Next n
              EndIf ; EndIf \nMaxCueMarker > 0
              ; nAudPtr = \nNextAudIndex
            EndWith
          EndIf ; End While nAudPtr >= 0
        EndIf ; EndIf WQAFile(n)\bSelected
      Next n
      u = preChangeSubL(#True, "Remove Video/Image File", -5, #SCS_UNDO_ACTION_CHANGE, -1)
      n = 0
      While n <= gnWQALastItem
        If WQAFile(n)\bSelected
          nAudPtr = WQAFile(n)\nFileAudPtr
          If nAudPtr >= 0
            u2 = preChangeAudL(#True, "Remove Video/Image File", nAudPtr, #SCS_UNDO_ACTION_DELETE, -1)
            closeAud(nAudPtr)
            aAud(nAudPtr)\bExists = #False
            postChangeAudL(u2, #False, -1)
          EndIf
          gnWQACurrItem = n
          nNewIndex = removeWQAFile()
        Else
          n + 1
        EndIf
      Wend
      
  EndSelect
  
  If nNewIndex <= gnWQALastItem
    gnWQACurrItem = nNewIndex
  Else
    gnWQACurrItem = gnWQALastItem
  EndIf
  
  WQA_updateAudsFromWQAFile(nEditSubPtr)
  WQA_updateTimeLineElements()
  ; debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
  WQA_resetSubDescrIfReqd()
  
  setLabels(nEditCuePtr)
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  WQA_doSubTotals()
  
  ; debugMsg(sProcName, "calling syncCueAutoActInfoWithCueMarkerIds()")
  bCueMarkerFound = syncCueAutoActInfoWithCueMarkerIds()
  If bCueMarkerFound
    ; debugMsg(sProcName, "calling loadCueMarkerArrays()")
    loadCueMarkerArrays()
    gbCallPopulateGrid = #True
  EndIf
  
  ; debugMsg(sProcName, "calling WQA_highlightItem()")
  WQA_highlightItem()
  gbCallLoadDispPanels = #True
  If u <> 0
    ; should be #True
    postChangeSubL(u, #False)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_updateTimeLineElements()
  PROCNAMEC()
  Protected n, nLeft
  
  ; debugMsg(sProcName, #SCS_START)
  
  For n = 0 To gnWQALastItem
    If WQAFile(n)\bTimelineUpdateReqd
      nLeft = (n * #SCS_QAITEM_WIDTH)
      ResizeGadget(WQAFile(n)\cntFile, nLeft, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    EndIf
  Next n
  
EndProcedure

Procedure WQA_highlightItem(bShowVideoPreviewImage=#True)
  PROCNAMEC()
  Protected nCurrItem, d, nFileCount
  Protected nCntImageHandle
  Protected nFileDuration, sFileTitle.s
  Protected nSelectedItemCount, nListIndex
  Protected bDisplayFileProgress = #True
  Protected bDisplayPosAndSize = #True
  Protected bDisplayAudioGraph = #True
  Protected rDisplayAud.tyAud, rTmpAud.tyAud
  Protected nAudPtr, bFileNameEnabled, bRelLevelVisible, bContinuousVisible
  Protected nSelectedVideos, nSelectedImages, nSelectedCaptures
  Protected nSelectedFullScreenTrue, nSelectedFullScreenFalse
  Protected nSelectedContinuousTrue, nSelectedContinuousFalse
  Protected nFileTypes, bMultipleFileTypes
  Protected nCountRotated, bMultipleRotates
  Protected n
  Protected nAudState
  Protected bEnableTransTime
  Protected nVidPicTarget
  Protected bShowPreview, bPreviewCanvasOnly
  Protected nMyYPos, nMyXPos, nMySize, nMyAspectRatioType, nMyRotate, bMyLogo, bEnableFields
  Protected sFileTypeExt.s
  Static bStaticLoaded, sLength.s
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_HIGHLIGHT_PLAYLIST_ROW)
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sLength = LangColon("Common", "Length")
    bStaticLoaded = #True
  EndIf
  
  nCurrItem = gnWQACurrItem
  debugMsg(sProcName, #SCS_START + ", bShowVideoPreviewImage=" + strB(bShowVideoPreviewImage) + ", nCurrItem=" + nCurrItem)
  If nCurrItem = -1
    ; no current item
    sFileTitle = Trim(LangPars("WQA","lblSelectedItem", "", ""))
    SGT(WQA\lblSelectedItem, Space(4) + sFileTitle)
    rWQA\nSelectedItemCount = 0
    ProcedureReturn
  EndIf
  
  setEditAudPtr(WQAFile(nCurrItem)\nFileAudPtr)
  gnDisplayedAudPtr = nEditAudPtr
  ; debugMsg0(sProcName, "nEditAudPtr=" + getAudLabel(nEditAudPtr) + ", gnDisplayedAudPtr=" + getAudLabel(gnDisplayedAudPtr))
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
      If aAud(nEditAudPtr)\sFileName
        While #True
          CompilerIf #c_vMix_in_video_cues
            grvMixInfo\bInputLimitReached = #False
          CompilerEndIf
          debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #False, #SCS_VID_PIC_TARGET_P)")
          openMediaFile(nEditAudPtr, #False, #SCS_VID_PIC_TARGET_P)
          If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_OPEN Or grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX
            Break
          EndIf
          CompilerIf #c_vMix_in_video_cues
            ; the following only apply when using vMix
            If grvMixInfo\bInputLimitReached
              ; couldn't open the file because the vMix input limit was reached, so try to remove an input and try again
              If vMix_RemoveRequestedInputs(#False) > 0
                ; at least one input removed, so try again
                Continue
              EndIf
              ; try removing one non-playing input
              If vMix_RemoveInputsNotPlaying(#False, 1) > 0
                ; one input removed, so try again
                Continue
              EndIf
              ; can't find an input that can be removed, so continue normal processing
            Else
              ; couldn't open the file for some other reason, so continue normal processing
              Break
            EndIf
          CompilerEndIf
        Wend
      EndIf
    EndIf
    rDisplayAud = aAud(nEditAudPtr)
  Else
    rDisplayAud = grAudDef
  EndIf
  bFileNameEnabled = #True
  bRelLevelVisible = #True
  bContinuousVisible = #True
  rWQA\bPlayLengthMayBeDisplayed = #True
  With rDisplayAud
    If \nFileFormat = #SCS_FILEFORMAT_PICTURE And \nImageFrameCount > 1
      nMyYPos = grAudDef\nYPos
      nMyXPos = grAudDef\nXPos
      nMySize = grAudDef\nSize
      nMyAspectRatioType = grAudDef\nAspectRatioType
      nMyRotate = grAudDef\nRotate
      bMyLogo = grAudDef\bLogo
      bEnableFields = #False
    Else
      nMyYPos = \nYPos
      nMyXPos = \nXPos
      nMySize = \nSize
      nMyAspectRatioType = \nAspectRatioType
      nMyRotate = \nRotate
      bMyLogo = \bLogo
      bEnableFields = #True
    EndIf
  EndWith

  For n = 0 To gnWQALastItem
    If WQAFile(n)\bSelected
      nSelectedItemCount + 1
    EndIf
  Next n
  
  If nSelectedItemCount = 0
    ; nothing selected, either because the subcue has only just been displayed, or the user tried to deselect the only selected item
    ; so force select the current item
    WQAFile(gnWQACurrItem)\bSelected = #True
    nSelectedItemCount = 1
  EndIf
  
  rWQA\nSelectedItemCount = nSelectedItemCount  ; keep for use by updates
  
  If nSelectedItemCount > 1
    With rDisplayAud
      For n = 0 To gnWQALastItem
        If WQAFile(n)\bSelected
          nAudPtr = WQAFile(n)\nFileAudPtr
          If nAudPtr >= 0
            Select aAud(nAudPtr)\nFileFormat
              Case #SCS_FILEFORMAT_VIDEO
                nSelectedVideos + 1
              Case #SCS_FILEFORMAT_PICTURE
                nSelectedImages + 1
                If aAud(nAudPtr)\nRotate <> grAudDef\nRotate
                  nCountRotated + 1
                EndIf
                debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bContinuous=" + strB(aAud(nAudPtr)\bContinuous))
                If aAud(nAudPtr)\bContinuous
                  nSelectedContinuousTrue + 1
                Else
                  nSelectedContinuousFalse + 1
                EndIf
              Case #SCS_FILEFORMAT_CAPTURE
                ; This tells us that there are multiple Video Capture Slides selected
                nSelectedCaptures + 1                
            EndSelect
            nSelectedFullScreenFalse + 1
          EndIf
          If nAudPtr <> nEditAudPtr
            If nAudPtr >= 0
              rTmpAud = aAud(nAudPtr)
              debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\sFileType=" + rTmpAud\sFileType)
            Else
              rTmpAud = grAudDef
              debugMsg(sProcName, "grAudDef\sFileType=" + rTmpAud\sFileType)
            EndIf
            If \sFileName <> rTmpAud\sFileName
              \sFileName = grAudDef\sFileName
              \sStoredFileName = grAudDef\sStoredFileName
              bFileNameEnabled = #False
              debugMsg(sProcName, "bFileNameEnabled=" + strB(bFileNameEnabled))
            EndIf
            If \sFileType <> rTmpAud\sFileType
              \sFileType = grAudDef\sFileType
              debugMsg(sProcName, "rDisplayAud\sFileType=" + rDisplayAud\sFileType)
            EndIf
            If \nFileDuration <> rTmpAud\nFileDuration
              \nFileDuration = grAudDef\nFileDuration
            EndIf
            If \nStartAt <> rTmpAud\nStartAt
              \nStartAt = grAudDef\nStartAt
            EndIf
            If \nEndAt <> rTmpAud\nEndAt
              \nEndAt = grAudDef\nEndAt
            EndIf
            If \nRotate <> rTmpAud\nRotate
              \nRotate = grAudDef\nRotate
            EndIf
            If \nCueDuration <> rTmpAud\nCueDuration
              \nCueDuration = grAudDef\nCueDuration
              rWQA\bPlayLengthMayBeDisplayed = #False
            EndIf
            If \nPLTransType <> rTmpAud\nPLTransType
              \nPLTransType = grAudDef\nPLTransType
            EndIf
            If \nPLTransTime <> rTmpAud\nPLTransTime
              \nPLTransTime = grAudDef\nPLTransTime
            EndIf
            If \fPLRelLevel <> rTmpAud\fPLRelLevel
              \fPLRelLevel = grAudDef\fPLRelLevel
              bRelLevelVisible = #False
            EndIf
            If \bContinuous <> rTmpAud\bContinuous
              \bContinuous = grAudDef\bContinuous
              bContinuousVisible = #False
            EndIf
            
            ;- Video Capture Settings - to highlight an already entered item
            If \sVideoCaptureLogicalDevice <> rTmpAud\sVideoCaptureLogicalDevice
              \sVideoCaptureLogicalDevice = grAudDef\sVideoCaptureLogicalDevice
            EndIf
            If \nVideoCaptureDeviceType <> rTmpAud\nVideoCaptureDeviceType
              \nVideoCaptureDeviceType = grAudDef\nVideoCaptureDeviceType
            EndIf
            
          EndIf ; EndIf nAudPtr <> nEditAudPtr
          
        EndIf ; EndIf WQAFile(n)\bSelected
        
      Next n
    EndWith
  EndIf
  debugMsg(sProcName, "nSelectedItemCount=" + nSelectedItemCount + ", nSelectedVideos=" + nSelectedVideos + ", nSelectedImages=" + nSelectedImages)
  If nSelectedVideos > 0
    nFileTypes + 1
  EndIf
  If nSelectedImages > 0
    nFileTypes + 1
  EndIf
  If nSelectedCaptures > 0
    nFileTypes + 1
  EndIf
  If nFileTypes > 1
    bMultipleFileTypes = #True
  EndIf
  If nSelectedImages > 1
    If nCountRotated > 0
      bMultipleRotates = #True
    EndIf
  EndIf
  
  For n = 0 To gnWQALastItem
    nCntImageHandle = WQAFile(n)\cntImage
    If IsGadget(nCntImageHandle)
      If WQAFile(n)\bSelected
        SetGadgetColor(nCntImageHandle, #PB_Gadget_BackColor, getSubTextColor())
      Else
        SetGadgetColor(nCntImageHandle, #PB_Gadget_BackColor, getSubBackColor())
      EndIf
    EndIf
  Next n
  
  debugMsg(sProcName, "nCurrItem=" + nCurrItem + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If nSelectedItemCount > 1
    bFileNameEnabled = #False
    bDisplayFileProgress = #False
    bDisplayPosAndSize = #False
    bDisplayAudioGraph = #False
  EndIf
  
  WQA_fcFileFormat(bMultipleFileTypes)  ; make relevant container, if applicable, visible
  
  If nEditAudPtr >= 0
    debugMsg(sProcName, "SELECTED ENTRY")
    
    With rDisplayAud
      
      If nSelectedItemCount = 1
        sFileTitle = Trim(LangPars("WQA","lblSelectedItem", Str(nCurrItem+1), GetFilePart(rDisplayAud\sFileName)))
      Else
        sFileTitle = LangPars("WQA", "multiSelect", Str(nSelectedItemCount))
      EndIf
      SGT(WQA\lblSelectedItem, Space(4) + sFileTitle)
      
      If \nVideoSource <> #SCS_VID_SRC_CAPTURE
        If grEditorPrefs\bShowFileFoldersInEditor
          SGT(WQA\txtFileName, \sStoredFileName)
        Else
          SGT(WQA\txtFileName, GetFilePart(\sStoredFileName))
        EndIf
        scsToolTip(WQA\txtFileName, \sFileName)
        setEnabled(WQA\btnBrowse, bFileNameEnabled)
        ; debugMsg(sProcName, "rDisplayAud\sAudLabel=" + \sAudLabel + ", \sFileType=" + \sFileType)
        If \nFileDuration > 0
          sFileTypeExt = sLength + timeToString(\nFileDuration)
        EndIf
        If Len(\sFileType) > 0
          If Len(sFileTypeExt) > 0
            sFileTypeExt + ", "
          EndIf
          sFileTypeExt + \sFileType
        EndIf
        SGT(WQA\txtFileTypeExt, sFileTypeExt)
        scsToolTip(WQA\txtFileTypeExt, sFileTypeExt)
        scsSetGadgetFont(WQA\txtFileTypeExt, #SCS_FONT_GEN_NORMAL)
        SetGadgetColor(WQA\txtFileTypeExt, #PB_Gadget_FrontColor, glSysColGrayText)
      EndIf
        
      ; OK to use nEditAudPtr as we want to display the picture for the latest selected item
      nAudState = aAud(nEditAudPtr)\nAudState
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(nAudState))
      If (\nVideoSource = #SCS_VID_SRC_FILE) And (\nFileFormat = #SCS_FILEFORMAT_VIDEO)
        bShowPreview = bShowVideoPreviewImage
        If bShowPreview
          If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            If gbPreviewOnOutputScreen
              bPreviewCanvasOnly = #True  ; show preview but on preview canvas only as playback is being shown on the output screen
            Else
              bShowPreview = #False ; do not show preview as this will block the video playback
            EndIf
          EndIf
        EndIf
      Else
        bShowPreview = #True
      EndIf
      If bShowPreview
        If nAudState = #SCS_CUE_ERROR
          debugMsg(sProcName, "calling clearPicture(#SCS_VID_PIC_TARGET_P, #True, " + GGT(WQA\lblSelectedItem) + " " + \sErrorMsg + ", getSubTextColor(), #True)")
          clearPicture(#SCS_VID_PIC_TARGET_P, #True, GGT(WQA\lblSelectedItem) + Chr(10) + Chr(10) + \sErrorMsg, getSubTextColor(), #True)
          bDisplayFileProgress = #False
          bDisplayAudioGraph = #False
          debugMsg(sProcName, "bDisplayFileProgress=" + strB(bDisplayFileProgress) + ", bDisplayAudioGraph=" + strB(bDisplayAudioGraph))
        Else
          If \nVideoSource = #SCS_VID_SRC_CAPTURE
            debugMsg(sProcName, "calling WQA_drawPreviewImage2(" + strB(bPreviewCanvasOnly) + ")")
            WQA_drawPreviewImage2(bPreviewCanvasOnly)
            bDisplayAudioGraph = #False
          Else
            ; debugMsg(sProcName, "bFileNameEnabled=" + strB(bFileNameEnabled) + ", aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState) + ", \bStartedInEditor=" + strB(aSub(nEditSubPtr)\bStartedInEditor))
            If (bFileNameEnabled) Or ((aSub(nEditSubPtr)\nSubState = #SCS_CUE_PLAYING) And (aSub(nEditSubPtr)\bStartedInEditor))
              ; debugMsg(sProcName, "\nFileFormat=" + decodeFileFormat(\nFileFormat))
              If (grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG) Or (aSub(nEditSubPtr)\nSubState < #SCS_CUE_FADING_IN) Or (aSub(nEditSubPtr)\nSubState > #SCS_CUE_FADING_OUT)
                If \nAbsStartAt = 0
                  ; debugMsg(sProcName, "calling WQA_drawPreviewImage2(" + strB(bPreviewCanvasOnly) + ")")
                  WQA_drawPreviewImage2(bPreviewCanvasOnly)
                Else
                  ; debugMsg(sProcName, "calling WQA_drawPreviewPosImage2(" + \nAbsStartAt + ")")
                  WQA_drawPreviewPosImage2(\nAbsStartAt)
                EndIf
              EndIf
            Else
              ; debugMsg(sProcName, "calling clearPicture(#SCS_VID_PIC_TARGET_P, #True, " + GGT(WQA\lblSelectedItem) + ", getSubTextColor(), #True)")
              clearPicture(#SCS_VID_PIC_TARGET_P, #True, GGT(WQA\lblSelectedItem), getSubTextColor(), #True)
              bDisplayFileProgress = #False
              bDisplayAudioGraph = #False
              ; debugMsg(sProcName, "bDisplayFileProgress=" + strB(bDisplayFileProgress) + ", bDisplayAudioGraph=" + strB(bDisplayAudioGraph))
            EndIf
          EndIf
        EndIf
      EndIf
      
      If (nSelectedVideos > 0) And (nSelectedImages > 0)
        ; suppress video-specific and image-specific and capture-specific details if a combination of video and image and capture has been selected
      ElseIf (nSelectedVideos > 0) And (nSelectedCaptures > 0)
        ; suppress video-specific and image-specific and capture-specific details if a combination of video and image and capture has been selected
      ElseIf (nSelectedImages > 0)  And (nSelectedCaptures > 0)
        ; suppress video-specific and image-specific and capture-specific details if a combination of video and image and capture has been selected
      Else
        ; display video-specific or image-specific or capture-specific details if all selected files are of the same type
        ; times displayed to 1/100 sec, not 1/1000 sec as videos are typically only 24fps or thereabouts, so pointless to have precision greater than 1/100 sec
        Select aAud(nEditAudPtr)\nFileFormat
          Case #SCS_FILEFORMAT_VIDEO
            nFileDuration = \nFileDuration
            SGS(WQA\cboVideoSource, rDisplayAud\nVideoSource)
            SGT(WQA\txtStartAt, timeToStringBWZ(\nStartAt, nFileDuration))         ; Start At
            SGT(WQA\txtEndAt, timeToStringBWZ(\nEndAt, nFileDuration))             ; End At
            SGT(WQA\txtPlayLength, timeToStringBWZ(\nCueDuration, nFileDuration))  ; Play Length
            SLD_setValue(WQA\sldRelLevel, \fPLRelLevel)
            Sld_setVisible(WQA\sldRelLevel, bRelLevelVisible)
            setVisible(WQA\mbgRotate, #False)
            SGT(WQA\lblRotateInfo, "")
            
          Case #SCS_FILEFORMAT_PICTURE
            SGS(WQA\cboVideoSource, rDisplayAud\nVideoSource)
            SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
            rWQA\nContinuousState = \bContinuous
            If nSelectedItemCount > 1
              If (nSelectedContinuousFalse > 0) And (nSelectedContinuousTrue > 0)
                rWQA\nContinuousState = #PB_Checkbox_Inbetween
              EndIf
            EndIf
            setOwnState(WQA\chkContinuous, rWQA\nContinuousState)
            setOwnState(WQA\chkLogo, bMyLogo)
            setOwnEnabled(WQA\chkLogo, bEnableFields)
            CompilerIf #c_include_video_overlays
              setOwnState(WQA\chkOverlay, \bOverlay)
            CompilerEndIf
            setVisible(WQA\mbgRotate, #True)
            setEnabled(WQA\mbgRotate, bEnableFields)
            If bEnableFields
              WQA_displayRotateInfo(bMultipleRotates)
            Else
              SGT(WQA\lblRotateInfo, "")
            EndIf
            
          Case #SCS_FILEFORMAT_CAPTURE
            SGS(WQA\cboVideoSource, \nVideoSource)
            SGT(WQA\cboVidCapLogicalDev, \sVideoCaptureLogicalDevice) 
            SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
            rWQA\nContinuousState = \bContinuous
            If nSelectedItemCount > 1
              If (nSelectedContinuousFalse > 0) And (nSelectedContinuousTrue > 0)
                rWQA\nContinuousState = #PB_Checkbox_Inbetween
              EndIf
            EndIf
            setOwnState(WQA\chkContinuous, rWQA\nContinuousState)
            
          Default
            ; Nothing Testing Only
            
        EndSelect
      EndIf
      
      nListIndex = indexForComboBoxData(WQA\cboQATransType, \nPLTransType, 0)
      SGS(WQA\cboQATransType, nListIndex)
      If \nPLTransType > #SCS_TRANS_NONE
        bEnableTransTime = #True
      EndIf
      SGT(WQA\txtQATransTime, timeToStringBWZ(\nPLTransTime))
      setEnabled(WQA\txtQATransTime, bEnableTransTime)
      
      If bDisplayPosAndSize
        SLD_setValue(WQA\sldXPos, nMyXPos)
        SLD_setValue(WQA\sldYPos, nMyYPos)
        SLD_setValue(WQA\sldSize, nMySize)
        SLD_setEnabled(WQA\sldXPos, bEnableFields)
        SLD_setEnabled(WQA\sldYPos, bEnableFields)
        SLD_setEnabled(WQA\sldSize, bEnableFields)
        WQA_displayPosAndSizeTextFields()
        If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
          setEnabled(WQA\cboAspectRatioType, #False)
          SGS(WQA\cboAspectRatioType, 0)
        Else
          setEnabled(WQA\cboAspectRatioType, bEnableFields)
          nListIndex = indexForComboBoxData(WQA\cboAspectRatioType, nMyAspectRatioType, 0)
          SGS(WQA\cboAspectRatioType, nListIndex)
        EndIf
        If nMyAspectRatioType = #SCS_ART_CUSTOM And grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX
          SLD_setValue(WQA\sldAspectRatioHVal, \nAspectRatioHVal)
          SLD_setVisible(WQA\sldAspectRatioHVal, #True)
        Else
          SLD_setVisible(WQA\sldAspectRatioHVal, #False)
        EndIf
      EndIf
      setVisible(WQA\cntXPosAndAspect, bDisplayPosAndSize)
      setVisible(WQA\cntYPosAndSize, bDisplayPosAndSize)
      
      If \bContinuous
        bDisplayFileProgress = #False
      EndIf
      
      If \nFileFormat = #SCS_FILEFORMAT_VIDEO
        debugMsg(sProcName, "calling prepareAndDisplayGraph(@grMG5)")
        prepareAndDisplayGraph(@grMG5)
        setVisible(WQA\cntGraphDisplayQA, #True)
        bDisplayFileProgress = #False
      Else
        setVisible(WQA\cntGraphDisplayQA, #False)
      EndIf
      
      If bDisplayFileProgress
        SLD_setEnabled(WQA\sldProgress[0], #True)
        SLD_setMax(WQA\sldProgress[0], (aAud(nEditAudPtr)\nCueDuration-1))
        SLD_setValue(WQA\sldProgress[0], aAud(nEditAudPtr)\nCuePos)
        SLD_setVisible(WQA\sldProgress[0], #True)
      Else
        SLD_setVisible(WQA\sldProgress[0], #False)
        ; debugMsg(sProcName, "SLD_setVisible(WQA\sldProgress[0], #False)")
      EndIf
      
      debugMsg(sProcName, "calling calcPLPosition(" + nEditSubPtr + ")")
      calcPLPosition(nEditSubPtr)
      
      If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
        If SLD_getMax(WQA\sldProgress[1]) <> aSub(\nSubIndex)\nPLTestTime
          SLD_setMax(WQA\sldProgress[1], (aSub(\nSubIndex)\nPLTestTime-1))
        EndIf
        SLD_setValue(WQA\sldProgress[1], \nCuePos)
      Else
        If SLD_getMax(WQA\sldProgress[1]) <> \nCueDuration
          SLD_setMax(WQA\sldProgress[1], (\nCueDuration-1))
        EndIf
        SLD_setValue(WQA\sldProgress[1], aSub(\nSubIndex)\nPLCuePosition)
      EndIf
    EndWith
    
  Else ; current item is blank entry at end
    debugMsg(sProcName, "BLANK ENTRY")
    With rDisplayAud
      SGS(WQA\cboVideoSource, \nVideoSource)
      debugMsg(sProcName, "calling WQA_setVisibleStates(-1)")
      WQA_setVisibleStates(-1)
      
      If nSelectedItemCount = 1
        sFileTitle = Trim(LangPars("WQA","lblSelectedItem", Str(nCurrItem+1), ""))
      Else
        sFileTitle = LangPars("WQA", "multiSelect", Str(nSelectedItemCount))
      EndIf
      SGT(WQA\lblSelectedItem, Space(4) + sFileTitle)
      
      SGT(WQA\txtFileName, "")
      setEnabled(WQA\btnBrowse, bFileNameEnabled)
      SGT(WQA\txtFileTypeExt, "")
      ResizeGadget(WQA\cvsPreview, 0, 0, #SCS_QAPREVIEW_WIDTH, #SCS_QAPREVIEW_HEIGHT)
      debugMsg3(sProcName, "ResizeGadget(WQA\cvsPreview, 0, 0, " + #SCS_QAPREVIEW_WIDTH + ", " + #SCS_QAPREVIEW_HEIGHT + ")")
      If StartDrawing(CanvasOutput(WQA\cvsPreview))
        debugMsgD(sProcName, "StartDrawing(CanvasOutput(WQA\cvsPreview))")
        DrawImage(ImageID(WQA\imgPreviewBlank),0,0,#SCS_QAPREVIEW_WIDTH,#SCS_QAPREVIEW_HEIGHT)
        debugMsgD(sProcName, "DrawImage(ImageID(" + WQA\imgPreviewBlank + "),0,0," + #SCS_QAPREVIEW_WIDTH + "," + #SCS_QAPREVIEW_HEIGHT + ") [blank]")
        StopDrawing()
      EndIf
      setVisible(WQA\cvsPreview, #True)
      setVisible(WQA\mbgRotate, #False)
      SGT(WQA\lblRotateInfo, "")
      SGT(WQA\txtStartAt, "")
      SGT(WQA\txtEndAt, "")
      SGT(WQA\txtPlayLength, "")
      SLD_setValue(WQA\sldRelLevel, grAudDef\fPLRelLevel)
      SGS(WQA\cboQATransType, 0)
      SGT(WQA\txtQATransTime, "")
      SLD_setMax(WQA\sldProgress[1], (aSub(nEditSubPtr)\nPLTestTime-1))
      SLD_setValue(WQA\sldProgress[1], 0)
      SLD_setVisible(WQA\sldProgress[0], #False)
      setVisible(WQA\cntGraphDisplayQA, #False)
      setVisible(WQA\cntXPosAndAspect, #False)
      setVisible(WQA\cntYPosAndSize, #False)
    EndWith
  EndIf
  
  WQA_setEnabledStates()
  WQA_setTBSButtons()
  WQA_SetTransportButtons()
  
  debugMsg(sProcName, #SCS_END + ", SLD_getMax(WQA\sldProgress[0])=" + SLD_getMax(WQA\sldProgress[0]))
  
EndProcedure

Procedure WQA_btnBrowse_Click(bAddingRow=#False)
  PROCNAMEC()
  Protected sFileName.s
  Protected sUndoDescr.s
  Protected nLen, sStoredFileName.s
  Protected bEmptyItemFound
  Protected nFileCount, n
  Protected u1, u2
  Protected Dim u4(1)
  Protected Dim sNewFileName.s(1)
  Protected Dim nNewAudPtr(1)
  Protected Dim bAudAdded(1)
  Protected nItem
  Protected sOrigFileName.s
  Protected rPrevAud.tyAud
  
  debugMsg(sProcName, #SCS_START)
  
  nItem = gnWQACurrItem
  If nItem >= 0
    setEditAudPtr(WQAFile(nItem)\nFileAudPtr)
  Else
    setEditAudPtr(-1)
  EndIf
  
  If nEditAudPtr >= 0
    rPrevAud = aAud(nEditAudPtr)
  Else
    rPrevAud = grAudDefForAdd
  EndIf
  
  debugMsg(sProcName, "calling videoFileRequester()")
  nFileCount = videoFileRequester(Lang("Requesters", "VideoFiles"), #True)
  If nFileCount = 0
    ProcedureReturn
  ElseIf nFileCount > 50
    If checkManyFilesOK(nFileCount) = #False
      ProcedureReturn
    EndIf
  EndIf
  
  setMouseCursorBusy()
  
  sUndoDescr = "Video Source" ; GGT(WQA\lblPnlHdg)
  u1 = preChangeCueL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_CUE_PTRS|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
  u2 = preChangeSubL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
  ;   u2 = preChangeSubL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB|#SCS_UNDO_FLAG_SET_CUE_PTRS|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
  
  If nFileCount > ArraySize(u4())
    ReDim u4(nFileCount)
    ReDim sNewFileName(nFileCount)
    ReDim nNewAudPtr(nFileCount)
    ReDim bAudAdded(nFileCount)
  EndIf
  
  For n = 1 To gnSelectedFileCount
    sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
    
    If (n = 1) And (nEditAudPtr >= 0) And (bAddingRow = #False)
      u4(n) = preChangeAudS(aAud(nEditAudPtr)\sFileName, "File Name", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE)
      bAudAdded(n) = #False
    Else
      u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
      If nEditAudPtr < 0
        ; addAudToSub() failed
        ProcedureReturn
      EndIf
      bAudAdded(n) = #True
      If WQAFile(gnWQACurrItem)\nFileNameLen <> 0
        ; not positioned on a blank row, so insert a new row
        insertWQAFile()
      EndIf
    EndIf
    
    debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr + ", sFileName=" + GetFilePart(sFileName))
    With aAud(nEditAudPtr)
      
      If (\nMainVideoNo <> 0) Or (\nPreviewVideoNo <> 0)
        closeVideo(nEditAudPtr)
      EndIf
      If IsImage(\nImageAfterRotateAndFlip)
        If \nFileFormat = #SCS_FILEFORMAT_PICTURE
          closePicture(nEditAudPtr)
        EndIf
      EndIf
      freeAudImages(nEditAudPtr)
      
      nNewAudPtr(n) = nEditAudPtr
      
      sOrigFileName = \sFileName
      \sFileName = sFileName
      \bReloadImage = #True
      \bReloadMainImage = #True
      \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
      \nFileFormat = getFileFormat(sFileName)
      If \nAudNo = -1
        aSub(nEditSubPtr)\nAudCount + 1
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + Str(aSub(nEditSubPtr)\nAudCount))
        \nAudNo = aSub(nEditSubPtr)\nAudCount
      EndIf
      setLabels(nEditCuePtr)
      debugMsg(sProcName, "calling WQA_fcFileExtA(#False)")
      WQA_fcFileExtA(#False)
      debugMsg(sProcName, "returned from WQA_fcFileExtA(#False)")
      \nSourceWidth = grAudDef\nSourceWidth      ; force video/picture dimensions (if applicable) to be obtained from the file during openMediaFile
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nSourceWidth=" + \nSourceWidth)
      \nSourceHeight = grAudDef\nSourceHeight
      debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #True, " + decodeVidPicTarget(#SCS_VID_PIC_TARGET_P) + ", #True, #False, #True)")
      openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_P, #True, #False, #True)
      debugMsg(sProcName, \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState))
      ; Added 18Jan2024 11.10.0 following error reported by Steve Martin whereby because the file failed to open (because it was on one drive???) the width and height were 0 which later caused a 'division by zero' error
      If \nAudState = #SCS_CUE_ERROR
        scsMessageRequester(\sAudLabel, LangPars("MMedia", "FailedToOpenFile", #DQUOTE$ + GetFilePart(\sFileName) + #DQUOTE$), #PB_MessageRequester_Error)
        ProcedureReturn
      EndIf
      ; End added 18Jan2024 11.10.0
      \sFileTitle = grFileInfo\sFileTitle
      ; SGT(WQA\txtPLTitle, \sFileTitle)
      
      \nRotate = grAudDef\nRotate
      \nFlip = grAudDef\nFlip
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE And \nImageFrameCount < 2
        setVisible(WQA\mbgRotate, #True)
      Else
        setVisible(WQA\mbgRotate, #False)
      EndIf
      
      \nStartAt = grAudDef\nStartAt
      \nEndAt = grAudDef\nEndAt
      \nPLTransType = grAudDef\nPLTransType
      \nPLTransTime = grAudDef\nPLTransTime
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        If (n = 1) And (rPrevAud\nFileFormat = #SCS_FILEFORMAT_PICTURE)
          \bContinuous = rPrevAud\bContinuous
          \nEndAt = rPrevAud\nEndAt
          \nPLTransType = rPrevAud\nPLTransType
          \nPLTransTime = rPrevAud\nPLTransTime
        EndIf
        If Len(sOrigFileName) = 0
          \bContinuous = grLastPicInfo\bLastPicContinuous
          \nEndAt = grLastPicInfo\nLastPicEndAt
          \nPLTransType = grLastPicInfo\nLastPicTransType
          \nPLTransTime = grLastPicInfo\nLastPicTransTime
        EndIf
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
      WQAFile(gnWQACurrItem)\nFileAudPtr = nEditAudPtr
      debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + getAudLabel(WQAFile(gnWQACurrItem)\nFileAudPtr))
      WQAFile(gnWQACurrItem)\nFileNameLen = Len(\sStoredFileName)
      
      WQA_drawPreviewImage2()
      WQA_drawTimeLineImage2(gnWQACurrItem)
      
      SGT(WQAFile(gnWQACurrItem)\lblFileName, ignoreExtension(GetFilePart(\sFileName)))
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nCueDuration=" + \nCueDuration)
      SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        saveLastPicInfo(nEditAudPtr)
      EndIf
      
      If \nFileFormat = #SCS_FILEFORMAT_VIDEO
        WQA_displayAudioGraphIfReqd()
      EndIf
      
      sNewFileName(n) = \sFileName
      
    EndWith
    
    CheckSubInRange((n-1), ArraySize(gsSelectedFile()), "gsSelectedFile()")
    sFileName = gsSelectedFile(n-1)
    If sFileName
      If gnWQACurrItem < gnWQALastItem
        gnWQACurrItem + 1
      Else
        debugMsg(sProcName, "calling createWQAFile()")
        createWQAFile()
      EndIf
    EndIf
    
  Next n
  
  WQA_updateAudsFromWQAFile(nEditSubPtr)
  
  setLabels(nEditCuePtr)
  
  setLinksForCue(nEditCuePtr)
  setLinksForAudsWithinSubsForCue(nEditCuePtr)
  buildAudSetArray()
  
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  WQA_doSubTotals()
  
  For n = 1 To nFileCount
    If bAudAdded(n)
      postChangeAudL(u4(n), #False, nNewAudPtr(n))
    Else
      postChangeAudS(u4(n), sNewFileName(n), nNewAudPtr(n))
    EndIf
  Next n
  
  debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
  WQA_resetSubDescrIfReqd()
  
  postChangeSubL(u2, #False)
  postChangeCueL(u1, #False)
  
  ; create an empty row if required
  bEmptyItemFound = #False
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileNameLen = 0
      bEmptyItemFound = #True
      Break
    EndIf
  Next n
  If bEmptyItemFound = #False
    debugMsg(sProcName, "calling createWQAFile()")
    createWQAFile()
  EndIf
  
  debugMsg(sProcName, "calling WQA_setCurrentItem(" + nItem + ")")
  WQA_setCurrentItem(nItem)
  
  setFileSave()
  
  SAW(#WED)
  
  ; Added 5Dec2023 11.10.0de
  gnRefreshCuePtr = nEditCuePtr
  gnRefreshSubPtr = nEditSubPtr
  gnRefreshAudPtr = nEditAudPtr
  gbCallReloadDispPanel = #True ; cause this sub-cue's cue panel to be reloaded to show the new file
  ; End added 5Dec2023 11.10.0de
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_reloadImages(bAddingRow=#False)
  PROCNAMEC()
  Protected sFileName.s
  Protected sUndoDescr.s
  Protected nLen, sStoredFileName.s
  Protected bEmptyItemFound
  Protected nFileCount, n
  Protected u1, u2
  Protected Dim u4(1)
  Protected Dim sNewFileName.s(1)
  Protected Dim nNewAudPtr(1)
  Protected Dim bAudAdded(1)
  Protected nItem
  Protected sOrigFileName.s
  Protected rPrevAud.tyAud
  
  debugMsg(sProcName, #SCS_START)
  
  nItem = gnWQACurrItem
  If nItem >= 0
    setEditAudPtr(WQAFile(nItem)\nFileAudPtr)
  Else
    setEditAudPtr(-1)
  EndIf
  
  If nEditAudPtr >= 0
    rPrevAud = aAud(nEditAudPtr)
  Else
    rPrevAud = grAudDefForAdd
  EndIf
  
  ; debugMsg(sProcName, "calling videoFileRequester()")
  ; nFileCount = videoFileRequester(Lang("Requesters", "VideoFiles"), #True)
  sFileName = aAud(nEditAudPtr)\sFileName
  nFileCount = 0
  If sFileName
    gsSelectedDirectory = GetPathPart(sFileName)
    While sFileName
      If nFileCount > ArraySize(gsSelectedFile())
        doRedim(gsSelectedFile, (nFileCount+10), "gsSelectedFile()")
      EndIf
      gsSelectedFile(nFileCount) = GetFilePart(sFileName)
      nFileCount + 1
      sFileName = NextSelectedFileName()
    Wend
  EndIf
  gnSelectedFileCount = nFileCount
  
  If nFileCount = 0
    ; didn't select anything
    ProcedureReturn nFileCount
  EndIf
  
  gsVideoFileDialogInitDir = ""
  debugMsg(sProcName, "gsVideoFileDialogInitDir=" + gsVideoFileDialogInitDir)
  
  If nFileCount = 0
    ProcedureReturn
  ElseIf nFileCount > 50
    If checkManyFilesOK(nFileCount) = #False
      ProcedureReturn
    EndIf
  EndIf
  
  setMouseCursorBusy()
  
  sUndoDescr = "Video Source" ; GGT(WQA\lblPnlHdg)
  u1 = preChangeCueL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_CUE_PTRS|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
  u2 = preChangeSubL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
  ;   u2 = preChangeSubL(#True, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB|#SCS_UNDO_FLAG_SET_CUE_PTRS|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
  
  If nFileCount > ArraySize(u4())
    ReDim u4(nFileCount)
    ReDim sNewFileName(nFileCount)
    ReDim nNewAudPtr(nFileCount)
    ReDim bAudAdded(nFileCount)
  EndIf
  
  For n = 1 To gnSelectedFileCount
    sFileName = gsSelectedDirectory + gsSelectedFile(n-1)
    
    If (n = 1) And (nEditAudPtr >= 0) And (bAddingRow = #False)
      u4(n) = preChangeAudS(aAud(nEditAudPtr)\sFileName, "File Name", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_OPEN_FILE)
      bAudAdded(n) = #False
    Else
      u4(n) = addAudToSub(nEditCuePtr, nEditSubPtr)
      If nEditAudPtr < 0
        ; addAudToSub() failed
        ProcedureReturn
      EndIf
      bAudAdded(n) = #True
      If WQAFile(gnWQACurrItem)\nFileNameLen <> 0
        ; not positioned on a blank row, so insert a new row
        insertWQAFile()
      EndIf
    EndIf
    
    debugMsg(sProcName, "n=" + n + ", nEditAudPtr=" + nEditAudPtr + ", sFileName=" + GetFilePart(sFileName))
    With aAud(nEditAudPtr)
      
      If (\nMainVideoNo <> 0) Or (\nPreviewVideoNo <> 0)
        closeVideo(nEditAudPtr)
      EndIf
      If IsImage(\nImageAfterRotateAndFlip)
        If \nFileFormat = #SCS_FILEFORMAT_PICTURE
          closePicture(nEditAudPtr)
        EndIf
      EndIf
      freeAudImages(nEditAudPtr)
      
      nNewAudPtr(n) = nEditAudPtr
      
      sOrigFileName = \sFileName
      \sFileName = sFileName
      \bReloadImage = #True
      \bReloadMainImage = #True
      \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
      \nFileFormat = getFileFormat(sFileName)
      If \nAudNo = -1
        aSub(nEditSubPtr)\nAudCount + 1
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + Str(aSub(nEditSubPtr)\nAudCount))
        \nAudNo = aSub(nEditSubPtr)\nAudCount
      EndIf
      setLabels(nEditCuePtr)
      debugMsg(sProcName, "calling WQA_fcFileExtA(#False)")
      WQA_fcFileExtA(#False)
      debugMsg(sProcName, "returned from WQA_fcFileExtA(#False)")
      \nSourceWidth = grAudDef\nSourceWidth      ; force video/picture dimensions (if applicable) to be obtained from the file during openMediaFile
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nSourceWidth=" + \nSourceWidth)
      \nSourceHeight = grAudDef\nSourceHeight
      debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #True, " + decodeVidPicTarget(#SCS_VID_PIC_TARGET_P) + ", #True, #False, #True)")
      openMediaFile(nEditAudPtr, #True, #SCS_VID_PIC_TARGET_P, #True, #False, #True)
      \sFileTitle = grFileInfo\sFileTitle
      debugMsg(sProcName, \sAudLabel + ", \nAudState=" + decodeCueState(\nAudState))
      ; SGT(WQA\txtPLTitle, \sFileTitle)
      
      \nRotate = grAudDef\nRotate
      \nFlip = grAudDef\nFlip
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE And \nImageFrameCount < 2
        setVisible(WQA\mbgRotate, #True)
      Else
        setVisible(WQA\mbgRotate, #False)
      EndIf
      
      \nStartAt = grAudDef\nStartAt
      \nEndAt = grAudDef\nEndAt
      \nPLTransType = grAudDef\nPLTransType
      \nPLTransTime = grAudDef\nPLTransTime
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        If (n = 1) And (rPrevAud\nFileFormat = #SCS_FILEFORMAT_PICTURE)
          \bContinuous = rPrevAud\bContinuous
          \nEndAt = rPrevAud\nEndAt
          \nPLTransType = rPrevAud\nPLTransType
          \nPLTransTime = rPrevAud\nPLTransTime
        EndIf
        If Len(sOrigFileName) = 0
          \bContinuous = grLastPicInfo\bLastPicContinuous
          \nEndAt = grLastPicInfo\nLastPicEndAt
          \nPLTransType = grLastPicInfo\nLastPicTransType
          \nPLTransTime = grLastPicInfo\nLastPicTransTime
        EndIf
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
      WQAFile(gnWQACurrItem)\nFileAudPtr = nEditAudPtr
      debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + getAudLabel(WQAFile(gnWQACurrItem)\nFileAudPtr))
      WQAFile(gnWQACurrItem)\nFileNameLen = Len(\sStoredFileName)
      
      WQA_drawPreviewImage2()
      WQA_drawTimeLineImage2(gnWQACurrItem)
      
      SGT(WQAFile(gnWQACurrItem)\lblFileName, ignoreExtension(GetFilePart(\sFileName)))
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nCueDuration=" + \nCueDuration)
      SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        saveLastPicInfo(nEditAudPtr)
      EndIf
      
      sNewFileName(n) = \sFileName
      
    EndWith
    
    CheckSubInRange((n-1), ArraySize(gsSelectedFile()), "gsSelectedFile()")
    sFileName = gsSelectedFile(n-1)
    If sFileName
      If gnWQACurrItem < gnWQALastItem
        gnWQACurrItem + 1
      Else
        debugMsg(sProcName, "calling createWQAFile()")
        createWQAFile()
      EndIf
    EndIf
    
  Next n
  
  WQA_updateAudsFromWQAFile(nEditSubPtr)
  
  setLabels(nEditCuePtr)
  
  setLinksForCue(nEditCuePtr)
  setLinksForAudsWithinSubsForCue(nEditCuePtr)
  buildAudSetArray()
  
  generatePlayOrder(nEditSubPtr)
  setCueState(nEditCuePtr)
  WQA_doSubTotals()
  
  For n = 1 To nFileCount
    If bAudAdded(n)
      postChangeAudL(u4(n), #False, nNewAudPtr(n))
    Else
      postChangeAudS(u4(n), sNewFileName(n), nNewAudPtr(n))
    EndIf
  Next n
  
  debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
  WQA_resetSubDescrIfReqd()
  
  postChangeSubL(u2, #False)
  postChangeCueL(u1, #False)
  
  ; create an empty row if required
  bEmptyItemFound = #False
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileNameLen = 0
      bEmptyItemFound = #True
      Break
    EndIf
  Next n
  If bEmptyItemFound = #False
    debugMsg(sProcName, "calling createWQAFile()")
    createWQAFile()
  EndIf
  
  debugMsg(sProcName, "calling WQA_setCurrentItem(" + nItem + ")")
  WQA_setCurrentItem(nItem)
  
  setFileSave()
  
  SAW(#WED)
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_positionVideoForOption()
  PROCNAMEC()
  Protected nDisplayPos
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      ; nDisplayPos = ((\nAbsEndAt - \nAbsStartAt) / 2) + \nAbsStartAt
      nDisplayPos = \nAbsStartAt
      debugMsg(sProcName, "calling setVideoPosition(" + getAudLabel(nEditAudPtr) + ", " + Str(nDisplayPos) + ")")
      setVideoPosition(nEditAudPtr, #SCS_VID_PIC_TARGET_P, nDisplayPos)
      samAddRequest(#SCS_SAM_SHOW_VIDEO_FRAME, nEditAudPtr, 0, nDisplayPos)
      
    EndWith
  EndIf
  
EndProcedure

Procedure WQA_countSelectedItems()
  Protected nSelectedItemCount
  Protected n
  
  For n = 0 To gnWQALastItem
    If (WQAFile(n)\bSelected) And (WQAFile(n)\nFileAudPtr >= 0)
      nSelectedItemCount + 1
    EndIf
  Next n
  ProcedureReturn nSelectedItemCount
EndProcedure

Procedure WQA_chkContinuous_Click()
  PROCNAMEC()
  Protected u, u2
  Protected k, nSelectedItemCount
  Protected nCheckboxState, sUndoDescr.s
  Protected n
  Protected sMsg.s
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  nSelectedItemCount = WQA_countSelectedItems()
  debugMsg(sProcName, "nSelectedItemCount=" + nSelectedItemCount)
  nCheckboxState = getOwnState(WQA\chkContinuous)
  If nCheckboxState = #PB_Checkbox_Inbetween
    ; shouldn't happen
    ProcedureReturn
  EndIf
  sUndoDescr = getOwnText(WQA\chkContinuous)
  
  If nSelectedItemCount = 1
    n = WQA_getItemForAud(nEditAudPtr)
    With aAud(nEditAudPtr)
      If nCheckboxState = #PB_Checkbox_Checked
        If \nNextAudIndex >= 0
          sMsg = Lang("Errors", "OnlyLastContinuous")
          debugMsg(sProcName, "sMsg=" + sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          setOwnState(WQA\chkContinuous, rWQA\nContinuousState) ; reinstate displayed state
          ProcedureReturn #False
        EndIf
      EndIf
      u2 = preChangeSubL(#True, sUndoDescr)
      u = preChangeAudL(\bContinuous, sUndoDescr)
      \bContinuous = nCheckboxState
      If \bContinuous
        \nEndAt = grAudDef\nEndAt
        \nAbsEndAt = getAbsTime(nEditAudPtr, "EN")
        SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
        \bLogo = grAudDef\bLogo
        setOwnState(WQA\chkLogo, \bLogo)
      EndIf
      \bDoContinuous = \bContinuous
      setDerivedAudFields(nEditAudPtr)
      SGT(WQAFile(n)\lblDuration, timeToString(\nCueDuration))
      If \bContinuous
        SLD_setVisible(WQA\sldProgress[0], #False)
      Else
        SLD_setVisible(WQA\sldProgress[0], #True)
        SLD_setMax(WQA\sldProgress[0], (\nCueDuration-1))
        SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt)) ; Added 22Feb2024 11.10.2at
      EndIf
      postChangeAudL(u, \bContinuous)
      WQA_doSubTotals()
      postChangeSubLN(u2, #False)
      grLastPicInfo\bLastPicContinuous = \bContinuous
    EndWith
    
  ElseIf nSelectedItemCount > 1
    If nCheckboxState = #PB_Checkbox_Checked
      sMsg = Lang("Errors", "OnlyLastContinuous")
      debugMsg(sProcName, "sMsg=" + sMsg)
      scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
      setOwnState(WQA\chkContinuous, rWQA\nContinuousState) ; reinstate displayed state
      ProcedureReturn #False
    EndIf
    u2 = preChangeSubL(#True, sUndoDescr)
    For n = 0 To gnWQALastItem
      If (WQAFile(n)\bSelected) And (WQAFile(n)\nFileAudPtr >= 0)
        k = WQAFile(n)\nFileAudPtr
        With aAud(k)
          If \bContinuous <> nCheckboxState
            u = preChangeAudL(\bContinuous, sUndoDescr, k)
            \bContinuous = nCheckboxState
            If \bContinuous
              \nEndAt = grAudDef\nEndAt
              \nAbsEndAt = getAbsTime(k, "EN")
              SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
              \bLogo = grAudDef\bLogo
              setOwnState(WQA\chkLogo, \bLogo)
            EndIf
            setDerivedAudFields(k)
            SGT(WQAFile(n)\lblDuration, timeToString(\nCueDuration))
            postChangeAudL(u, \bContinuous, k)
          EndIf
          grLastPicInfo\bLastPicContinuous = \bContinuous
        EndWith
      EndIf
    Next n
    WQA_doSubTotals()
    postChangeSubLN(u2, #False)
  EndIf
  
EndProcedure

Procedure WQA_chkLogo_Click()
  PROCNAMEC()
  Protected u, u2
  Protected k, nSelectedItemCount
  Protected nCheckboxState, sUndoDescr.s
  Protected n
  Protected sMsg.s
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  nSelectedItemCount = WQA_countSelectedItems()
  debugMsg(sProcName, "nSelectedItemCount=" + Str(nSelectedItemCount))
  nCheckboxState = getOwnState(WQA\chkLogo)
  If nCheckboxState = #PB_Checkbox_Inbetween
    ; shouldn't happen
    ProcedureReturn
  EndIf
  sUndoDescr = getOwnText(WQA\chkLogo)
  
  n = WQA_getItemForAud(nEditAudPtr)
  With aAud(nEditAudPtr)
    If nCheckboxState = #PB_Checkbox_Checked
      If \nNextAudIndex >= 0 Or \nPrevAudIndex >= 0
        sMsg = Lang("Errors", "LogoAlone")
        debugMsg(sProcName, "sMsg=" + sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        setOwnState(WQA\chkLogo, #PB_Checkbox_Unchecked) ; reinstate displayed state
        ProcedureReturn #False
      EndIf
    EndIf
    u2 = preChangeSubL(#True, sUndoDescr)
    u = preChangeAudL(\bLogo, sUndoDescr)
    \bLogo = nCheckboxState
    If \bLogo
      \nEndAt = grAudDef\nEndAt
      \nAbsEndAt = getAbsTime(nEditAudPtr, "EN")
      SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
      \bContinuous = grAudDef\bContinuous
      setOwnState(WQA\chkContinuous, \bContinuous)
    EndIf
    setDerivedAudFields(nEditAudPtr)
    SGT(WQAFile(n)\lblDuration, timeToString(\nCueDuration))
    If \bLogo
      SLD_setVisible(WQA\sldProgress[0], #False)
    Else
      SLD_setVisible(WQA\sldProgress[0], #True)
      SLD_setMax(WQA\sldProgress[0], (\nCueDuration-1))
    EndIf
    postChangeAudL(u, \bLogo)
    WQA_doSubTotals()
    postChangeSubLN(u2, #False)
  EndWith
  
EndProcedure

Procedure WQA_chkOverlay_Click()
  PROCNAMEC()
  Protected u, u2
  Protected k, nSelectedItemCount
  Protected nCheckboxState, sUndoDescr.s
  Protected n
  Protected sMsg.s
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  nSelectedItemCount = WQA_countSelectedItems()
  debugMsg(sProcName, "nSelectedItemCount=" + Str(nSelectedItemCount))
  nCheckboxState = getOwnState(WQA\chkOverlay)
  If nCheckboxState = #PB_Checkbox_Inbetween
    ; shouldn't happen
    ProcedureReturn
  EndIf
  sUndoDescr = getOwnText(WQA\chkOverlay)
  
  n = WQA_getItemForAud(nEditAudPtr)
  With aAud(nEditAudPtr)
    If nCheckboxState = #PB_Checkbox_Checked
      If \nNextAudIndex >= 0 Or \nPrevAudIndex >= 0
        sMsg = Lang("Errors", "OverlayAlone")
        debugMsg(sProcName, "sMsg=" + sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        setOwnState(WQA\chkOverlay, #PB_Checkbox_Unchecked) ; reinstate displayed state
        ProcedureReturn #False
      EndIf
    EndIf
    u2 = preChangeSubL(#True, sUndoDescr)
    u = preChangeAudL(\bOverlay, sUndoDescr)
    \bOverlay = nCheckboxState
    postChangeAudL(u, \bOverlay)
    postChangeSubLN(u2, #False)
  EndWith
  
EndProcedure

Procedure WQA_chkPauseAtEnd_Click()
  PROCNAMEC()
  Protected u
  Protected bPauseAtEnd
  
  With aSub(nEditSubPtr)
    bPauseAtEnd = getOwnState(WQA\chkPauseAtEnd)
    debugMsg(sProcName, "bPauseAtEnd=" + strB(bPauseAtEnd) + ", aSub(" + getSubLabel(nEditSubPtr) + ")\bPauseAtEnd=" + strB(\bPauseAtEnd))
    If bPauseAtEnd <> \bPauseAtEnd
      u = preChangeSubL(\bPauseAtEnd, getOwnText(WQA\chkPauseAtEnd))
      \bPauseAtEnd = bPauseAtEnd
      ; \bPauseAtEnd and \bPLRepeat mutually exclusive
      If \bPauseAtEnd
        If \bPLRepeat
          \bPLRepeat = #False
          setOwnState(WQA\chkPLRepeat, \bPLRepeat)
        EndIf
      EndIf
      setDerivedFieldsForSubAuds(nEditSubPtr)
      debugMsg(sProcName, "calling WQA_doSubTotals()")
      WQA_doSubTotals()
      postChangeSubLN(u, \bPauseAtEnd)
    EndIf
  EndWith
EndProcedure

Procedure WQA_chkPLRepeat_Click()
  PROCNAMEC()
  Protected u
  Protected bPLRepeat
  
  With aSub(nEditSubPtr)
    bPLRepeat = getOwnState(WQA\chkPLRepeat)
    debugMsg(sProcName, "bPLRepeat=" + strB(bPLRepeat) + ", aSub(" + getSubLabel(nEditSubPtr) + ")\bPLRepeat=" + strB(\bPLRepeat))
    If bPLRepeat <> \bPLRepeat
      u = preChangeSubL(\bPLRepeat, getOwnText(WQA\chkPLRepeat))
      \bPLRepeat = bPLRepeat
      ; \bPLRepeat and \bPauseAtEnd mutually exclusive
      If \bPLRepeat
        If \bPauseAtEnd
          \bPauseAtEnd = #False
          setOwnState(WQA\chkPauseAtEnd, \bPauseAtEnd)
        EndIf
      EndIf
      \bPLRepeatCancelled = #False
      setDerivedFieldsForSubAuds(nEditSubPtr)
      debugMsg(sProcName, "calling WQA_doSubTotals()")
      WQA_doSubTotals()
      postChangeSubLN(u, \bPLRepeat)
    EndIf
  EndWith
EndProcedure

Procedure WQA_chkShowFileFolders()
  PROCNAMEC()
  
  grEditorPrefs\bShowFileFoldersInEditor = getOwnState(WQA\chkShowFileFolders)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If grEditorPrefs\bShowFileFoldersInEditor
        SGT(WQA\txtFileName, \sStoredFileName)
      Else
        SGT(WQA\txtFileName, GetFilePart(\sStoredFileName))
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_chkPreviewOnOutputScreen()
  PROCNAMECA(nEditAudPtr)
  Protected nPrevSetting
  Protected nTVGIndex
  
  debugMsg(sProcName, #SCS_START)
  
  ; listTVGControls(#False)
  
  nPrevSetting = gnPreviewOnOutputScreenNo
  gbPreviewOnOutputScreen = getOwnState(WQA\chkPreviewOnOutputScreen)
  If gbPreviewOnOutputScreen
    gnPreviewOnOutputScreenNo = aSub(nEditSubPtr)\nOutputScreen
  Else
    gnPreviewOnOutputScreenNo = 0
  EndIf
  If gbPreviewOnOutputScreen
    debugMsg(sProcName, "calling setVidPicTargets()")
    setVidPicTargets()
    SAW(#WED) ; added because throws back to main window after setVidPicTargets()
  EndIf
  debugMsg(sProcName, "gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo)
  debugMsg(sProcName, "calling WQA_drawPreviewImage2()")
  WQA_drawPreviewImage2()
  If gnPreviewOnOutputScreenNo = 0
    debugMsg(sProcName, "calling WQA_clearPreviewOnOutputScreen(" + nPrevSetting + ")")
    WQA_clearPreviewOnOutputScreen(nPrevSetting)
  EndIf
  
  CompilerIf #c_include_tvg
    ; nb the following must be called AFTER setting gnPreviewOnOutputScreenNo
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
        With gaTVG(nTVGIndex)
          If \nTVGVidPicTarget = #SCS_VID_PIC_TARGET_P
            ; debugMsg(sProcName, "nTVGIndex=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", gaTVG(" + nTVGIndex + ")\nTVGAudPtr=" + getAudLabel(\nTVGAudPtr) + ", \bAssigned=" + strB(\bAssigned) + ", \nChannel=" + \nChannel)
            If \nChannel <> 0
              debugMsgT(sProcName, "calling setTVGDisplayLocation(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
              setTVGDisplayLocation(nTVGIndex)
            EndIf
          EndIf
        EndWith
      Next nTVGIndex
    EndIf
  CompilerEndIf
  
  ; WQA_setCursorOnPreviewPanel()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_txtStartAt_Validate(bMultiSelect, bFirstSelectedItem, nCurrItem=-1)
  PROCNAMECA(nEditAudPtr)
  Protected nTime
  Protected u
  Protected n, nMinAbsEndAt, nMinAbsEndAtAudPtr
  Protected nAudPtr, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    If bFirstSelectedItem
      If validateTimeField(GGT(WQA\txtStartAt), GGT(WQA\lblStartAt), #False, #False, \nFileDuration) = #False
        ProcedureReturn #False
      ElseIf GGT(WQA\txtStartAt) <> gsTmpString
        SGT(WQA\txtStartAt, gsTmpString)
      EndIf
    EndIf
    
    nTime = stringToTime(GGT(WQA\txtStartAt))
    
    If bFirstSelectedItem
      If nTime >= 0
        nMinAbsEndAt = \nAbsEndAt
        nMinAbsEndAtAudPtr = nEditAudPtr
        For n = 0 To gnWQALastItem
          If WQAFile(n)\bSelected
            nAudPtr = WQAFile(n)\nFileAudPtr
            If nAudPtr >= 0
              If aAud(nAudPtr)\nAbsEndAt < nMinAbsEndAt
                nMinAbsEndAt = aAud(nAudPtr)\nAbsEndAt
                nMinAbsEndAtAudPtr = nAudPtr
              EndIf
            EndIf
          EndIf
        Next n
        If (nMinAbsEndAt >= 0) And (nTime > nMinAbsEndAt)
          sMsg = LangPars("Errors", "NotLessThan", Trim(GGT(WQA\lblStartAt) + " (" + ttsz(nTime) + ")"), Trim(GGT(WQA\lblEndAt) + " (" + ttsz(nMinAbsEndAt) + ")"))
          debugMsg(sProcName, "sMsg=" + sMsg + ", nMinAbsEndAtAudPtr=" + getAudLabel(nMinAbsEndAtAudPtr))
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
    
    If nTime <> \nAbsStartAt
      
      u = preChangeAudL(\nStartAt, GGT(WQA\lblStartAt))
      \nStartAt = nTime
      
      If \nStartAt = -2
        \nAbsStartAt = 0
      Else
        \nAbsStartAt = \nStartAt
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
      If bMultiSelect = #False
        setDerivedFieldsForSubAuds(nEditSubPtr)
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          setMouseCursorBusy()
          \bReloadImage = #True
          debugMsg(sProcName, "calling loadImageIfReqd(" + getAudLabel(nEditAudPtr) + ")")
          loadImageIfReqd(nEditAudPtr)
          debugMsg(sProcName, "calling setVideoPosition(" + getAudLabel(nEditAudPtr) + ", #SCS_VID_PIC_TARGET_P, " + \nAbsStartAt + ")")
          setVideoPosition(nEditAudPtr, #SCS_VID_PIC_TARGET_P, \nAbsStartAt)  ; includes call to showMyVideoFrame()
                                                                              ; for 'start at' we also need to refresh the timeline image
          debugMsg(sProcName, "calling WQA_drawTimeLineImage2(" + Str(gnWQACurrItem) + ")")
          WQA_drawTimeLineImage2(gnWQACurrItem)
          setMouseCursorNormal()
        EndIf
        SGT(WQA\txtPlayLength, timeToStringBWZ(\nCueDuration, \nFileDuration))
        SLD_setMax(WQA\sldProgress[0], (\nCueDuration-1))
        WQA_doSubTotals()
      EndIf
      
      If nCurrItem >= 0
        SGT(WQAFile(nCurrItem)\lblDuration, timeToString(\nCueDuration))
      Else
        SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      EndIf
      
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 5)  ; request SAM to call drawGraph
      
      postChangeAudLN(u, \nStartAt)
      
      If aAud(nEditAudPtr)\nMaxCueMarker >= 0
        WQA_refreshCueMarkersDisplayEtc()
      EndIf
      
    EndIf
    
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQA_txtEndAt_Validate(bMultiSelect, bFirstSelectedItem, nCurrItem=-1)
  PROCNAMECA(nEditAudPtr)
  Protected nTime
  Protected u
  Protected n, nMaxAbsStartAt, nMaxAbsStartAtAudPtr
  Protected nAudPtr, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    
    If bFirstSelectedItem
      If validateTimeField(GGT(WQA\txtEndAt), GGT(WQA\lblEndAt), #False, #True, \nFileDuration) = #False
        ProcedureReturn #False
      ElseIf GGT(WQA\txtEndAt) <> gsTmpString
        SGT(WQA\txtEndAt, gsTmpString)
      EndIf
    EndIf
    
    nTime = stringToTime(GGT(WQA\txtEndAt))
    
    If bFirstSelectedItem
      If nTime >= 0
        nMaxAbsStartAt = \nAbsStartAt
        nMaxAbsStartAtAudPtr = nEditAudPtr
        For n = 0 To gnWQALastItem
          If WQAFile(n)\bSelected
            nAudPtr = WQAFile(n)\nFileAudPtr
            If nAudPtr >= 0
              If aAud(nAudPtr)\nAbsStartAt > nMaxAbsStartAt
                nMaxAbsStartAt = aAud(nAudPtr)\nAbsStartAt
                nMaxAbsStartAtAudPtr = nAudPtr
              EndIf
            EndIf
          EndIf
        Next n
        If (nMaxAbsStartAt >= 0) And (nTime < nMaxAbsStartAt)
          sMsg = LangPars("Errors", "MustBeGreaterThan", Trim(GGT(WQA\lblEndAt) + " (" + ttsz(nTime) + ")"), Trim(GGT(WQA\lblStartAt) + " (" + ttsz(nMaxAbsStartAt) + ")"))
          debugMsg(sProcName, "sMsg=" + sMsg + ", nMaxAbsStartAtAudPtr=" + getAudLabel(nMaxAbsStartAtAudPtr))
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
    
    If nTime <> \nAbsEndAt
      
      u = preChangeAudL(\nEndAt, GGT(WQA\lblEndAt))
      \nEndAt = nTime
      
      If (\nEndAt = -2) And (\nFileDuration > 0)
        \nAbsEndAt = \nFileDuration - 1
      Else
        \nAbsEndAt = \nEndAt
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
      If bMultiSelect = #False
        setDerivedFieldsForSubAuds(nEditSubPtr)
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          setMouseCursorBusy()
          debugMsg(sProcName, "calling setVideoPosition(" + getAudLabel(nEditAudPtr) + ", #SCS_VID_PIC_TARGET_P, " + \nAbsEndAt + ")")
          setVideoPosition(nEditAudPtr, #SCS_VID_PIC_TARGET_P, \nAbsEndAt)  ; includes call to showMyVideoFrame()
          setMouseCursorNormal()
        EndIf
        SGT(WQA\txtPlayLength, timeToStringBWZ(\nCueDuration, \nFileDuration))
        SLD_setMax(WQA\sldProgress[0], (\nCueDuration-1))
        WQA_doSubTotals()
      EndIf
      
      If nCurrItem >= 0
        SGT(WQAFile(nCurrItem)\lblDuration, timeToString(\nCueDuration))
      Else
        SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      EndIf
      
      samAddRequest(#SCS_SAM_DRAW_GRAPH, 5)  ; request SAM to call drawGraph
      
      postChangeAudLN(u, \nEndAt)
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQA_txtDisplayTime_Validate(bMultiSelect, bFirstSelectedItem, nCurrItem=-1)
  PROCNAMECA(nEditAudPtr)
  Protected nTime
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", bMultiSelect=" + strB(bMultiSelect) + ", bFirstSelectedItem=" + strB(bFirstSelectedItem))
  
  With aAud(nEditAudPtr)
    
    If bFirstSelectedItem
      If validateTimeField(GGT(WQA\txtDisplayTime), GGT(WQA\lblDisplayTime), #False, #False) = #False
        ProcedureReturn #False
      ElseIf GGT(WQA\txtDisplayTime) <> gsTmpString
        SGT(WQA\txtDisplayTime, gsTmpString)
      EndIf
    EndIf
    
    nTime = stringToTime(GGT(WQA\txtDisplayTime))
    
    If nTime <> \nAbsEndAt
      
      u = preChangeAudL(\nEndAt, GGT(WQA\lblDisplayTime))
      \nEndAt = nTime
      \nAbsEndAt = getAbsTime(nEditAudPtr, "EN")
      
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE Or \nFileFormat = #SCS_FILEFORMAT_CAPTURE
        If nTime > 0
          \bContinuous = #False
          debugMsg(sProcName, "\nEndAt=" + \nEndAt + ", \bContinuous=" + strB(\bContinuous))
          If bFirstSelectedItem
            If getOwnState(WQA\chkContinuous) <> #PB_Checkbox_Unchecked
              setOwnState(WQA\chkContinuous, #PB_Checkbox_Unchecked)
            EndIf
          EndIf
          grLastPicInfo\nLastPicEndAt = nTime
          grLastPicInfo\bLastPicContinuous = \bContinuous
        EndIf
      EndIf
      
      ; debugMsg(sProcName, "calling setDerivedAudFields(" + getAudLabel(nEditAudPtr) + ")")
      setDerivedAudFields(nEditAudPtr)
      
      If bMultiSelect = #False
        ; debugMsg(sProcName, "set sldProgress[0]")
        SLD_setMax(WQA\sldProgress[0], (\nCueDuration-1))
        ; debugMsg(sProcName, "calling WQA_doSubTotals()")
        WQA_doSubTotals()
      EndIf
      
      If nCurrItem >= 0
        SGT(WQAFile(nCurrItem)\lblDuration, timeToString(\nCueDuration))
      Else
        SGT(WQAFile(gnWQACurrItem)\lblDuration, timeToString(\nCueDuration))
      EndIf
      
      postChangeAudLN(u, \nEndAt)
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

; Called when a file format is assigned - similar to WQA_setVisibleStates_NoFileFormat()
Procedure WQA_setVisibleStates(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected nFileFormat, sFileName.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    nFileFormat = aAud(pAudPtr)\nFileFormat
    If aAud(pAudPtr)\bAudPlaceHolder = #False
      sFileName = aAud(pAudPtr)\sFileName
    EndIf
  Else
    nFileFormat = grAudDef\nFileFormat
    sFileName = grAudDef\sFileName
  EndIf
  ; debugMsg(sProcName, "nFileFormat=" + decodeFileFormat(nFileFormat))
  
  With WQA
    If nFileFormat = #SCS_FILEFORMAT_CAPTURE
      setVisible(\txtFileName, #False)
      setVisible(\btnBrowse, #False)
      setVisible(\lblVidCapLogicalDev, #True)
      setVisible(\cboVidCapLogicalDev, #True)
      setVisible(\txtFileTypeExt, #False)
      setVisible(\chkShowFileFolders, #False)
      setVisible(\btnEditExternally, #False)
    Else
      setVisible(\lblVidCapLogicalDev, #False)
      setVisible(\cboVidCapLogicalDev, #False)
      setVisible(\txtFileName, #True)
      setVisible(\btnBrowse, #True)
      setVisible(\txtFileTypeExt, #True)
      setVisible(\chkShowFileFolders, #True)
      If grLicInfo\bExternalEditorsIncluded And sFileName
        setVisible(\btnEditExternally, #True)
      Else
        setVisible(\btnEditExternally, #False)
      EndIf
    EndIf
    
    If nFileFormat = #SCS_FILEFORMAT_VIDEO
      setVisible(\cntImageAndCaptureFields, #False)
      setVisible(\cntVideoFields, #True)
    Else
      setVisible(\cntVideoFields, #False)
      If nFileFormat = #SCS_FILEFORMAT_PICTURE
        setVisible(\cntImageOnlyFields, #True)
      Else
        setVisible(\cntImageOnlyFields, #False)
      EndIf
      setVisible(\cntImageAndCaptureFields, #True)
    EndIf
    
  EndWith

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_setEnabledStates()
  PROCNAMECA(nEditAudPtr)
  Protected bStartAtAvailable, bEndAtAvailable, bRelLevelAvailable
  Protected bOthersAvailable, bVideoOthersAvailable
  Protected bTransTypeAvailable, bTransTimeAvailable
  Protected bEditExternallyAvailable
  
  ; debugMsg(sProcName, #SCS_START)
  
  If (aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY) Or (aSub(nEditSubPtr)\nSubState >= #SCS_CUE_PL_READY)
    bOthersAvailable = #True
    If nEditAudPtr >= 0
      Select aAud(nEditAudPtr)\nFileFormat
          
        Case #SCS_FILEFORMAT_PICTURE
          bEndAtAvailable = #True
          bTransTypeAvailable = #True
          bEditExternallyAvailable = #True
          
        Case #SCS_FILEFORMAT_VIDEO
          bStartAtAvailable = #True
          bEndAtAvailable = #True
          bTransTypeAvailable = #True
          bEditExternallyAvailable = #True
          
        Case #SCS_FILEFORMAT_CAPTURE
          bVideoOthersAvailable = getVisible(WQA\cntVideoFields)
          bTransTypeAvailable = #True
          
        Default
          bVideoOthersAvailable = #False  
          bStartAtAvailable = #False
          bEndAtAvailable = #False
          
      EndSelect
    EndIf
  EndIf
  
  If nEditAudPtr >= 0
    If (aAud(nEditAudPtr)\nFileFormat <> #SCS_FILEFORMAT_PICTURE) And (aAud(nEditAudPtr)\bAudPlaceHolder = #False)
      bRelLevelAvailable = #True
      If (aAud(nEditAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nEditAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
        bEndAtAvailable = #True
        bStartAtAvailable = #True
      EndIf
    EndIf
  EndIf
  
  setEnabled(WQA\txtStartAt, bStartAtAvailable)
  setEnabled(WQA\txtEndAt, bEndAtAvailable)
  SLD_setEnabled(WQA\sldRelLevel, bRelLevelAvailable)
  
  setEnabled(WQA\txtFadeInTime, bOthersAvailable)
  setEnabled(WQA\txtFadeOutTime, bOthersAvailable)
  
  setEnabled(WQA\txtDisplayTime, bOthersAvailable)
  setOwnEnabled(WQA\chkContinuous, bOthersAvailable)
  
  setOwnEnabled(WQA\chkPauseAtEnd, bOthersAvailable)
  setOwnEnabled(WQA\chkPLRepeat, bOthersAvailable)
  setEnabled(WQA\btnBrowse, bOthersAvailable)
  
  If bVideoOthersAvailable
    setEnabled(WQA\txtDisplayTime, bVideoOthersAvailable)
    setOwnEnabled(WQA\chkContinuous, bVideoOthersAvailable)
  EndIf
  
  setEnabled(WQA\cboQATransType, bTransTypeAvailable)
  bTransTimeAvailable = bTransTypeAvailable
  If bTransTimeAvailable
    If getCurrentItemData(WQA\cboQATransType) <= #SCS_TRANS_NONE
      bTransTimeAvailable = #False
    EndIf
  EndIf
  setEnabled(WQA\txtQATransTime, bTransTimeAvailable)
  
  setEnabled(WQA\btnScreens, bOthersAvailable)
  Select grVideoDriver\nVideoPlaybackLibrary
    Case #SCS_VPL_TVG, #SCS_VPL_VMIX
      If gbVideosOnMainWindow ; Test added 15Sep2020 11.8.3.2ay
        setEnabled(WQA\chkPreviewOnOutputScreen, #False)
      Else
        setEnabled(WQA\chkPreviewOnOutputScreen, bOthersAvailable)
      EndIf
    Default
      setEnabled(WQA\chkPreviewOnOutputScreen, #False)
  EndSelect
  setEnabled(WQA\cboVidAudLogicalDev, bOthersAvailable)
  
  setEnabled(WQA\btnEditExternally, bEditExternallyAvailable)
  
  WQA_setVisibleStates(nEditAudPtr)    
  
EndProcedure

Procedure WQA_doSubTotals()
  PROCNAMECS(nEditSubPtr)
  Protected nTestTime
  
  debugMsg(sProcName, #SCS_START)
  
  setPLFades(nEditSubPtr)
  calcPLTotalTime(nEditSubPtr)
  debugMsg(sProcName, "aSub(" + buildSubLabel(nEditSubPtr) + ")\nPLTotalTime=" + Str(aSub(nEditSubPtr)\nPLTotalTime))
  If grCED\bQACreated
    SGT(WQA\txtTotalTime, timeToStringBWZ(aSub(nEditSubPtr)\nPLTotalTime))
    nTestTime = aSub(nEditSubPtr)\nPLTestTime
    If SLD_getMax(WQA\sldProgress[1]) <> nTestTime
      SLD_setValue(WQA\sldProgress[1], 0)
      SLD_setMax(WQA\sldProgress[1], (nTestTime-1))
    EndIf
  EndIf
  loadGridRow(nEditCuePtr)  ; refresh 'Length' field
  
EndProcedure

Procedure WQA_cboSubTrim_Click()
  PROCNAMEC()
  Protected u, d
  Protected fOldTrim.f, fNewTrim.f
  Protected fOldDBLevelSingle.f, fNewDBLevelSingle.f
  Protected fOldLevel.f, fNewLevel.f
  
  d = 0
  
  With aSub(nEditSubPtr)
    If \sPLDBTrim[d] <> GGT(WQA\cboSubTrim)
      u = preChangeSubS(\sPLDBTrim[d], GGT(WQA\lblSubTrim), -5, #SCS_UNDO_ACTION_CHANGE)
      fOldTrim = dbTrimStringToSingle(\sPLDBTrim[d])
      fNewTrim = getCurrentItemData(WQA\cboSubTrim)
      fOldDBLevelSingle = convertDBStringToDBLevel(\sPLMastDBLevel[d])
      fNewDBLevelSingle = fOldDBLevelSingle + (fNewTrim - fOldTrim)
;       If fNewDBLevelSingle > 0.0
;         fNewDBLevelSingle = 0.0
;       ElseIf fNewDBLevelSingle < -75.0
;         fNewDBLevelSingle = -75.0
;       EndIf
      If fNewDBLevelSingle > grProd\nMaxDBLevel
        fNewDBLevelSingle = grProd\nMaxDBLevel
      ElseIf fNewDBLevelSingle < grProd\nMinDBLevel
        fNewDBLevelSingle = grProd\nMinDBLevel
      EndIf
      ; debugMsg(sProcName, "fOldTrim=" + StrF(fOldTrim,2) + ", fNewTrim=" + StrF(fNewTrim,2) + ", fOldDBLevelSingle=" + StrF(fOldDBLevelSingle,2) + ", fNewDBLevelSingle=" + StrF(fNewDBLevelSingle,2))
      \sPLDBTrim[d] = GGT(WQA\cboSubTrim)
      \sPLMastDBLevel[d] = StrF(fNewDBLevelSingle,1)
      \fSubMastBVLevel[d] = convertDBStringToBVLevel(\sPLMastDBLevel[d])
      \fSubTrimFactor[d] = dbTrimStringToFactor(\sPLDBTrim[d])
      If (SLD_getLevel(WQA\sldSubLevel) <> \fSubMastBVLevel[d]) Or (SLD_getTrimFactor(WQA\sldSubLevel) <> \fSubTrimFactor[d])
        SLD_setLevel(WQA\sldSubLevel, \fSubMastBVLevel[d], \fSubTrimFactor[d])
      EndIf
      WQA_fcSldLevelA()
      SGT(WQA\txtSubDBLevel, \sPLMastDBLevel[d])
      postChangeSubSN(u, \sPLDBTrim[d], -5)
    EndIf
  EndWith
  
EndProcedure

Procedure WQA_cboVidAudLogicalDev_Click()
  PROCNAMEC()
  Protected d, sNewLogicalDev.s
  Protected sOldLogicalDev.s
  Protected bOldMuteVideoAudio, bNewMuteVideoAudio
  Protected bFound, nListIndex
  Protected u
  Protected nDevIndex
  Protected nData
  Protected i, j
  Protected sMsg.s
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START)
  
  With aSub(nEditSubPtr)
    
    bFound = #False
    sOldLogicalDev = \sVidAudLogicalDev
    bOldMuteVideoAudio = \bMuteVideoAudio
    sNewLogicalDev = ""
    
    nData = getCurrentItemData(WQA\cboVidAudLogicalDev)
    If nData = -1
      bNewMuteVideoAudio = #True
    Else
      bNewMuteVideoAudio = #False
      For d = 0 To grProd\nMaxVidAudLogicalDev
        If Len(grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev) > 0
          If grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev = Trim(GGT(WQA\cboVidAudLogicalDev))
            bFound = #True
            sNewLogicalDev = grProd\aVidAudLogicalDevs(d)\sVidAudLogicalDev
            Break
          EndIf
        EndIf
      Next d
    EndIf
    
    debugMsg(sProcName, "sOldLogicalDev=" + sOldLogicalDev + "sNewLogicalDev=" + sNewLogicalDev)
    debugMsg(sProcName, "bOldMuteVideoAudio=" + strB(bOldMuteVideoAudio) + ", bNewMuteVideoAudio=" + strB(bNewMuteVideoAudio))
    
    If (bNewMuteVideoAudio) And (bOldMuteVideoAudio = #False)
      ; only allow mute if there are no level change sub-cues referring to this video sub-cue
      For i = 1 To gnLastCue
        If aCue(i)\bSubTypeL
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeL
              If aSub(j)\nLCSubPtr = nEditSubPtr
                sMsg = LangPars("Errors", "CannotMute", getSubLabel(j))
                debugMsg(sProcName, "sMsg=" + sMsg)
                scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
                ; reinstate previous device selecction
                nListIndex = indexForComboBoxRow(WQA\cboVidAudLogicalDev, \sVidAudLogicalDev, 0)
                SGS(WQA\cboVidAudLogicalDev, nListIndex)
                ProcedureReturn
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      Next i
    EndIf
    
    If (sNewLogicalDev <> sOldLogicalDev) Or (bNewMuteVideoAudio <> bOldMuteVideoAudio) Or (gbAdding)
      u = preChangeSubL(#False, GGT(WQA\lblSoundDevice), -5, #SCS_UNDO_ACTION_CHANGE)
      ; close current channel if open
      If nEditAudPtr >= 0
        debugMsg(sProcName, "calling freeOneAudStream for nEditAudPtr=" + nEditAudPtr)
        debugMsg3(sProcName, "calling freeOneAudStream(" + nEditAudPtr + ", " + Str(0) + ")")
        freeOneAudStream(nEditAudPtr, 0)
      EndIf
      \sVidAudLogicalDev = sNewLogicalDev
      \bMuteVideoAudio = bNewMuteVideoAudio
      
      If bNewMuteVideoAudio
        nDevIndex = -1
      Else
        nDevIndex = getIndexForVidAudLogicalDev(sNewLogicalDev)
      EndIf
      debugMsg(sProcName, "nDevIndex=" + Str(nDevIndex))
      
      d = 0   ; only one audio device for video cues
      If (bNewMuteVideoAudio) And (nEditAudPtr >= 0)
        ; re-open video file
        setFirstAndLastDev(nEditAudPtr)
        debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
        openMediaFile(nEditAudPtr, #False, #SCS_VID_PIC_TARGET_P)
        
      ElseIf bFound
        debugMsg(sProcName, "sOldLogicalDev=" + sOldLogicalDev + ", \fSubMastBVLevel[" + d + "]=" + formatLevel(\fSubMastBVLevel[d]) + ", gbAdding=" + strB(gbAdding))
        If (Len(sOldLogicalDev) = 0 And \fSubMastBVLevel[d] = #SCS_MINVOLUME_SINGLE) Or (gbAdding)
          ; for a new device set the level at normal, but if this is not the first device then set the level the same as the previous device (if set)
          If gbPasting = #False
            If nDevIndex >= 0
              \fSubMastBVLevel[d] = grProd\aVidAudLogicalDevs(nDevIndex)\fDfltBVLevel
            Else
              \fSubMastBVLevel[d] = #SCS_NORMALVOLUME_SINGLE
            EndIf
          EndIf
        EndIf
        If nEditAudPtr >= 0
          ; re-open video file to use new device
          setFirstAndLastDev(nEditAudPtr)
          debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
          openMediaFile(nEditAudPtr, #False, #SCS_VID_PIC_TARGET_P)
        EndIf
        
      Else
        ; new device is blank
        \sPLDBTrim[d] = ""
        \fSubTrimFactor[d] = 0
        nListIndex = 0
        If GGS(WQA\cboSubTrim) <> nListIndex
          SGS(WQA\cboSubTrim, nListIndex)
        EndIf
        \fSubMastBVLevel[d] = #SCS_MINVOLUME_SINGLE
        \fPLPan[d] = #SCS_PANCENTRE_SINGLE
      EndIf
      
      \sPLMastDBLevel[d] = convertBVLevelToDBString(\fSubMastBVLevel[d])
      
      If (SLD_getLevel(WQA\sldSubLevel) <> \fSubMastBVLevel[d]) Or (SLD_getTrimFactor(WQA\sldSubLevel) <> \fSubTrimFactor[d])
        SLD_setLevel(WQA\sldSubLevel, \fSubMastBVLevel[d], \fSubTrimFactor[d])
        WQA_fcSldLevelA()
        If bFound
          SGT(WQA\txtSubDBLevel, \sPLMastDBLevel[d])    ; convertBVLevelToDBString(.fBVLevel[d])
        Else
          SGT(WQA\txtSubDBLevel, "")
        EndIf
      EndIf
      If SLD_getValue(WQA\sldSubPan) <> panToSliderValue(\fPLPan[d])
        SLD_setValue(WQA\sldSubPan, panToSliderValue(\fPLPan[d]))
        WQA_fcSldPanA()
        If bFound
          SGT(WQA\txtSubPan, panSingleToString(\fPLPan[d]))
        Else
          SGT(WQA\txtSubPan, "")
        EndIf
      EndIf
      
    EndIf
    
    If nEditAudPtr >= 0
      setFirstAndLastDev(nEditAudPtr)
    EndIf
    WQA_fcLogicalDevA()
    
    postChangeSubL(u, #True, -5)
    
  EndWith
  
EndProcedure

Procedure WQA_populateCboVidAudLogicalDevs()
  PROCNAMEC()
  Protected n
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WQA
    ClearGadgetItems(\cboVidAudLogicalDev)
    For n = 0 To grProd\nMaxVidAudLogicalDev
      If grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev
        debugMsg(sProcName, "grProd\aVidAudLogicalDevs(" + n + ")\sLogicalDev=" + grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev)
        addGadgetItemWithData(\cboVidAudLogicalDev, grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev, n)
      EndIf
    Next n
    addGadgetItemWithData(\cboVidAudLogicalDev, grText\sTextMuteAudio, -1)
    setEnabled(\cboVidAudLogicalDev, #True)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_populateCboVidCapLogicalDevs()
  PROCNAMEC()
  Protected n
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WQA
    ClearGadgetItems(\cboVidCapLogicalDev)
    For n = 0 To grProd\nMaxVidCapLogicalDev
      If grProd\aVidCapLogicalDevs(n)\sLogicalDev
        debugMsg(sProcName, "grProd\aVidCapLogicalDevs(" + n + ")\sLogicalDev=" + grProd\aVidCapLogicalDevs(n)\sLogicalDev)
        addGadgetItemWithData(\cboVidCapLogicalDev, grProd\aVidCapLogicalDevs(n)\sLogicalDev, n)
      EndIf
    Next n
    setComboBoxWidth(\cboVidCapLogicalDev, 80)
    setEnabled(\cboVidCapLogicalDev, #True)
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_cboVidCapLogicalDev_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u 
  Protected sUndoDescription.s
  Protected nGivenCurrentItem
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ; nEditAudPtr not assigned a value so return
    ProcedureReturn
  EndIf
  
  If nEditAudPtr >= 0  
    sUndoDescription = GGT(WQA\lblVidCapLogicalDev)
    u = preChangeAudS(aAud(nEditAudPtr)\sVideoCaptureLogicalDevice, sUndoDescription) 
    debugMsg(sProcName, "\sVideoCaptureLogicalDevice=" + GGT(WQA\cboVidCapLogicalDev))
    aAud(nEditAudPtr)\sVideoCaptureLogicalDevice = GGT(WQA\cboVidCapLogicalDev)    
    nGivenCurrentItem = gnWQACurrItem-1
    If nGivenCurrentItem >= 0 
      SGT(WQAFile(nGivenCurrentItem)\lblFileName, aAud(nEditAudPtr)\sVideoCaptureLogicalDevice)      
    EndIf
    postChangeAudS(u, aAud(nEditAudPtr)\sVideoCaptureLogicalDevice)
    
    debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
    WQA_resetSubDescrIfReqd()
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_fcVideoSource()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, "calling WQA_setVisibleStates(" + getAudLabel(nEditAudPtr) + ")")
  WQA_setVisibleStates(nEditAudPtr)
  
  ; Set up the Video Capture panel and acquire the aAud file
  debugMsg(sProcName, "calling WQA_processSetupVideoCapture(aAud(nEditAudPtr)\nVideoSource, nItem)")
  WQA_processSetupVideoCapture(aAud(nEditAudPtr)\nVideoSource, gnWQACurrItem)
  
EndProcedure

Procedure WQA_cboVideoSource_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u, u1, u2, n
  Protected nItem, bEmptyItemFound
  Protected sDescription.s, sUndoDescr.s
  Protected nVidPicTarget, nPhysicalDevPtr
  Protected nOldVideoSource, nNewVideoSource
  
  debugMsg(sProcName, #SCS_START)
  
  nItem = gnWQACurrItem
  If nItem >= 0
    setEditAudPtr(WQAFile(nItem)\nFileAudPtr)
  Else
    setEditAudPtr(-1)
  EndIf
  
  If nEditAudPtr < 0
    debugMsg(sProcName, "calling WQA_prepareVideoCapture(#True)")
    WQA_prepareVideoCapture(#True)
    debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
    setLabels(nEditCuePtr)
  EndIf
  
  debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nOldVideoSource = \nVideoSource
      nNewVideoSource = getCurrentItemData(WQA\cboVideoSource, #SCS_VID_SRC_FILE)
      If nNewVideoSource <> nOldVideoSource
        ; set sUndoDescr according to VideoSource BEFORE this change
        sUndoDescr = "Video Source" ; GGT(WQA\lblPnlHdg)
        u1 = preChangeCueL(nOldVideoSource, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_SET_CUE_PTRS|#SCS_UNDO_FLAG_SET_CUE_NODE_TEXT|#SCS_UNDO_FLAG_REDO_TREE)
        u2 = preChangeSubL(nOldVideoSource, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)
        u = preChangeAudL(nOldVideoSource, sUndoDescr, -5, #SCS_UNDO_ACTION_CHANGE)
        
        ; now apply this change
        \nVideoSource = nNewVideoSource
        debugMsg(sProcName, "calling WQA_setVisibleStates(" + getAudLabel(nEditAudPtr) + ")")
        WQA_setVisibleStates(nEditAudPtr)
        
        ; Set Up the Video Capture Panel and Acquire the aAud File
        WQA_processSetupVideoCapture(\nVideoSource, nItem)
        WQA_updateAudsFromWQAFile(nEditSubPtr)
        
        setLabels(nEditCuePtr)
        
        setLinksForCue(nEditCuePtr)
        setLinksForAudsWithinSubsForCue(nEditCuePtr)
        buildAudSetArray()
        
        generatePlayOrder(nEditSubPtr)
        setCueState(nEditCuePtr)
        WQA_doSubTotals()
        
        debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
        WQA_resetSubDescrIfReqd()
        
        postChangeAudL(u, nNewVideoSource)
        postChangeSubL(u2, nNewVideoSource)
        postChangeCueL(u1, nNewVideoSource)
      EndIf ; EndIf nNewVideoSource <> nOldVideoSource
      
      ; create an empty row if required
      bEmptyItemFound = #False
      For n = 0 To gnWQALastItem
        If WQAFile(n)\nFileNameLen = 0
          bEmptyItemFound = #True
          Break
        EndIf
      Next n
      If bEmptyItemFound = #False
        debugMsg(sProcName, "calling createWQAFile()")
        createWQAFile()
      EndIf
      
      debugMsg(sProcName, "calling WQA_setCurrentItem(" + nItem + ")")
      WQA_setCurrentItem(nItem)
      
      setFileSave()
      
      If nEditAudPtr >= 0
        If aAud(nEditAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
          nVidPicTarget = getVidPicTargetForOutputScreen(aSub(nEditSubPtr)\nOutputScreen)
          debugMsg(sProcName, "calling openVideoCaptureDevForTVG(" + getAudLabel(nEditAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ")")
          nPhysicalDevPtr = openVideoCaptureDevForTVG(nEditAudPtr, nVidPicTarget)
          debugMsg(sProcName, "openVideoCaptureDevForTVG(" + getAudLabel(nEditAudPtr) + ", " + decodeVidPicTarget(nVidPicTarget) + ") returned nPhysicalDevPtr=" + nPhysicalDevPtr)
        EndIf
      EndIf
    EndWith
  EndIf ; EndIf nEditAudPtr >= 0
  
  SAW(#WED)
  
  setMouseCursorNormal()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_populateVideoCapturePanel()
  PROCNAMECA(nEditAudPtr)
  
  Protected nImageNo, nPreviewHeight, nPreviewWidth, nCanvasNo, nItem
  
  debugMsg(sProcName, #SCS_START)
  
  ;- Populate Video Source Panel when ready
  If nEditAudPtr >= 0
    If Not IsImage(hVideoCaptionLogo)
      debugMsg(sProcName, "IMG_doCatchImage(hVideoCaptionLogo, WQA_pic_video_capture_logo) - loading again as IsImage returning ZERO")
      IMG_doCatchImage(hVideoCaptionLogo, WQA_pic_video_capture_logo)
    EndIf
    WQA_drawPreviewImage2()
    WQA_drawTimeLineImage()
  Else
    WQA_drawPreviewImage2()
    WQA_drawTimeLineImage()
  EndIf
  
  WQA_setEnabledStates()
  WQA_setVisibleStates(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_populateVideoImagePanel()
  PROCNAMEC()
  
  ;- Populate Video/Image Panel when ready  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      \nFileFormat = getFileFormat(\sFileName)
      \nVideoCaptureDeviceType = #SCS_DEVTYPE_NONE
    EndWith
  EndIf
  WQA_highlightItem()
  WQA_setEnabledStates()
  WQA_setVisibleStates(nEditAudPtr)
  
EndProcedure

Procedure WQA_prepareVideoCapture(bNewSlide=#False)
  PROCNAMEC()
  Protected nItem, nListIndex, d, n, sLogicalDev.s
  Protected nDefaultCapturePeriod = 0 
  
  debugMsg(sProcName, #SCS_START + ", bNewSlide=" + strB(bNewSlide))
  
  If (nEditAudPtr < 0) And (bNewSlide = #False)
    debugMsg(sProcName, "exiting because nEditAudPtr=" + nEditAudPtr + " and bNewSlide=#False")
    ProcedureReturn
  EndIf
  
  ; This is where we set the Video Capture Parameters inside the given aAud
  If bNewSlide
    debugMsg(sProcName, "calling addAudToSub(" + getCueLabel(nEditCuePtr) + ", " + getSubLabel(nEditSubPtr) + ")")
    addAudToSub(nEditCuePtr, nEditSubPtr)
  Else
    With aAud(nEditAudPtr)      
      If (\nMainVideoNo <> 0) Or (\nPreviewVideoNo <> 0)
        debugMsg(sProcName, "calling closeVideo(" + getAudLabel(nEditAudPtr) + ")")
        closeVideo(nEditAudPtr)
      EndIf
      If IsImage(\nImageAfterRotateAndFlip)
        If \nFileFormat = #SCS_FILEFORMAT_PICTURE Or #SCS_FILEFORMAT_CAPTURE
          debugMsg(sProcName, "\nFileFormat=" + decodeFileFormat(\nFileFormat))
          closePicture(nEditAudPtr)
        EndIf
      EndIf
      ;freeAudImages(nEditAudPtr)
    EndWith
  EndIf  
  
  ; Set the variables
  If nEditAudPtr >= 0
    ; should be true
    With aAud(nEditAudPtr)
      \nEndAt = nDefaultCapturePeriod
      nListIndex = 0
      For d = 0 To grProd\nMaxVidCapLogicalDev
        If grProd\aVidCapLogicalDevs(d)\sLogicalDev
          If grProd\aVidCapLogicalDevs(d)\bAutoInclude
            sLogicalDev = grProd\aVidCapLogicalDevs(d)\sLogicalDev
            Break
          EndIf
        EndIf
      Next d
      If sLogicalDev
        For n = 0 To CountGadgetItems(WQA\cboVidCapLogicalDev) - 1
          If GetGadgetItemText(WQA\cboVidCapLogicalDev, n) = sLogicalDev
            nListIndex = n
            Break
          EndIf
        Next n
      EndIf
      SGS(WQA\cboVidCapLogicalDev, nListIndex)
      \sVideoCaptureLogicalDevice = GGT(WQA\cboVidCapLogicalDev)
      SGT(WQAFile(gnWQACurrItem)\lblFileName, \sVideoCaptureLogicalDevice)
      \bContinuous = #True
      
      ; Set the Display Content
      SGT(WQA\txtDisplayTime, timeToStringBWZ(\nEndAt))
      setOwnState(WQA\chkContinuous, \bContinuous)
      SetGadgetState(WQA\cboQATransType, 0)
      SetGadgetState(WQA\cboVidCapLogicalDev, 0)
    EndWith
  EndIf
  
  WQA_setEnabledStates()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_processSetupVideoCapture(nVideoSource, nItem)
  PROCNAMEC()
  Protected nIndex              ; nIndex is the index of the drop down combo box list for video source
  Protected bNewSlide           ; bNewSlide is that we have a new slide or placeholder slide to deal with
  Protected bContainerCapture   ; bContainerCapture is if we are currently setting up the Video Capture Container
  Protected bEmptyItemFound, n  ; Test for Empty Record
  
  ; Use this process to drive the calls to set up and organise Video Capture for Sub Cues or reset to the Video/Image Container
  debugMsg(sProcName, #SCS_START + ", nVideoSource=" + decodeVideoSource(nVideoSource) + ", nItem=" + nItem)
  
  ; Check if the SLIDE selected is an existing one or a placeholder
  If nItem < 0 Or nEditAudPtr < 0
    bNewSlide = #True  
    debugMsg(sProcName, "New Slide is TRUE")
  EndIf
  
  ; UNDO Reference
  ;u = preChangeSubL(#True, "TEST CS VC TEST", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_DISPLAYSUB | #SCS_UNDO_FLAG_SET_CUE_PTRS)  ; Figure out what description I should have here!!!
  
  ; Set up the Video Capture Container
  nIndex = GGS(WQA\cboVideoSource)
  debugMsg(sProcName, "nIndex=" + nIndex + ", getCurrentItemData(WQA\cboVideoSource)=" + decodeVideoSource(getCurrentItemData(WQA\cboVideoSource)))
  
  ;- Change to the Video Source Panel or back to the Video/Image Panel
  If nEditAudPtr >=0
    aAud(nEditAudPtr)\nVideoSource = nVideoSource
    Select nVideoSource
      Case #SCS_VID_SRC_CAPTURE
        aAud(nEditAudPtr)\nVideoCaptureDeviceType = #SCS_DEVTYPE_VIDEO_CAPTURE
      Default
        aAud(nEditAudPtr)\nVideoCaptureDeviceType = #SCS_DEVTYPE_NONE
    EndSelect
  EndIf  
  
  ; Set up for the correct selected panel (Container)
  Select nIndex
    Case #SCS_CS_SOURCE_VIDIMG ; Show Video/Image Panel Container
      debugMsg(sProcName, "nIndex=#SCS_CS_SOURCE_VIDIMG")
      debugMsg(sProcName, "WQA_populateVideoImagePanel()")
      WQA_populateVideoImagePanel()
      
    Case #SCS_CS_SOURCE_CAPTURE ; Show Video Capture Panel Container
      debugMsg(sProcName, "nIndex=#SCS_CS_SOURCE_CAPTURE")
      If nEditAudPtr >= 0
        ;
      Else
        debugMsg(sProcName, "addAudToSub(nEditCuePtr, nEditSubPtr)")
        addAudToSub(nEditCuePtr, nEditSubPtr)
        bNewSlide = #False
        If nEditAudPtr < 0 
          ; addAudToSub Failed !!!!
          ProcedureReturn
        EndIf
      EndIf
      WQAFile(gnWQACurrItem)\nFileAudPtr = nEditAudPtr
      debugMsg(sProcName, "WQAFile(" + gnWQACurrItem + ")\nFileAudPtr=" + getAudLabel(WQAFile(gnWQACurrItem)\nFileAudPtr))
      
      debugMsg(sProcName, "We now have aEditAudPtr value="+nEditAudPtr) 
      aAud(nEditAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
      debugMsg(sProcName, "WQA_populateVideoCapturePanel()")
      WQA_populateVideoCapturePanel() 
      bContainerCapture = #True
      
    Default
      debugMsg(sProcName, "nIndex=" + nIndex)
      
  EndSelect
  
  ; Prepare the Slide with relevant data from the right panel
  If bContainerCapture
    ; Prepare the Slide with Video Capture Data
    debugMsg(sProcName, "WQA_prepareVideoCapture(bNewSlide)")
    WQA_prepareVideoCapture(bNewSlide)
  Else  
    ; Prepare the Slide with Video/Image Data
    If nEditAudPtr > -1 
      If Trim(aAud(nEditAudPtr)\sFileName) = Trim("")      
        WQA_btnBrowse_Click()
      EndIf
    Else
      WQA_btnBrowse_Click()
    EndIf
  EndIf 
  
  ; create an empty row if required
  bEmptyItemFound = #False
  For n = 0 To gnWQALastItem
    If nEditAudPtr < 0  
      Break 
    EndIf
    If (WQAFile(n)\nFileNameLen = 0) And (aAud(nEditAudPtr)\nVideoSource <> #SCS_VID_SRC_CAPTURE)
      bEmptyItemFound = #True
      Break
    EndIf
  Next n
  If bEmptyItemFound = #False
    debugMsg(sProcName, "calling createWQAFile()")
    createWQAFile()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_sldProgress_Common(nSliderEventType)
  PROCNAMECA(nEditAudPtr)
  Protected bReposition, nRepositionAt
  Protected nVidPicTarget
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      ; debugMsg(sProcName, "nSliderEventType=" + Str(nSliderEventType))
      Select nSliderEventType
        Case #SCS_SLD_EVENT_MOUSE_DOWN
          rWQA\bEditProgMouseDown = #True
        Case #SCS_SLD_EVENT_MOUSE_UP
          bReposition = #True
        Case #SCS_SLD_EVENT_SCROLL
          ; commented out due to the time taken to continually load and draw images, so wait for 'mouse up' event
          ; If \nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT
          ; bReposition = #True
          ; EndIf
      EndSelect
      
      If bReposition
        gqTimeNow = ElapsedMilliseconds()
        nRepositionAt = SLD_getValue(WQA\sldProgress[0]) + \nAbsMin
        debugMsg(sProcName, "nRepositionAt=" + nRepositionAt)
        nVidPicTarget = #SCS_VID_PIC_TARGET_P ; nVidPicTarget is always 'Preview' even if the user has selected preview on output screen
        reposAuds(nEditAudPtr, nRepositionAt, #True, #False, nVidPicTarget)
        rWQA\bEditProgMouseDown = #False
      EndIf
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_skipBackOrForward(nSkipTime)
  PROCNAMECA(nEditAudPtr)
  ; code based on WQA_sldProgress_Common()
  Protected nValue, nRepositionAt, nVidPicTarget
  
  debugMsg(sProcName, #SCS_START + ", nSkipTime=" + nSkipTime)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nValue = SLD_getValue(WQA\sldProgress[0]) + nSkipTime
      If nValue < SLD_getMin(WQA\sldProgress[0])
        nValue = SLD_getMin(WQA\sldProgress[0])
      ElseIf nValue > SLD_getMax(WQA\sldProgress[0])
        nValue = SLD_getMax(WQA\sldProgress[0])
      EndIf
      SLD_setValue(WQA\sldProgress[0], nValue, #True)
      
      gqTimeNow = ElapsedMilliseconds()
      nRepositionAt = SLD_getValue(WQA\sldProgress[0]) + \nAbsMin
      debugMsg(sProcName, "nRepositionAt=" + nRepositionAt)
      nVidPicTarget = #SCS_VID_PIC_TARGET_P ; nVidPicTarget is always 'Preview' even if the user has selected preview on output screen
      reposAuds(nEditAudPtr, nRepositionAt, #True, #False, nVidPicTarget)
      
    EndWith
  EndIf

EndProcedure

Procedure WQA_txtSubDBLevel_Validate()
  PROCNAMEC()
  
  If validateDbField(GGT(WQA\txtSubDBLevel), GGT(WQA\lblSubLevel)) = #False
    ProcedureReturn #False
  EndIf
  If GGT(WQA\txtSubDBLevel) <> gsTmpString
    SGT(WQA\txtSubDBLevel, gsTmpString)
  EndIf
  
  WQA_fcTxtDBLevelA()
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQA_txtSubPan_Validate()
  PROCNAMEC()
  Protected u, d
  
  If validatePanTextField(GGT(WQA\txtSubPan), "Pan") = #False
    ProcedureReturn #False
  EndIf
  
  d = 0
  
  With aSub(nEditSubPtr)
    u = preChangeSubF(\fPLPan[d], GGT(WQA\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE)
    \fPLPan[d] = panStringToSingle(GGT(WQA\txtSubPan))
    WQA_fcTxtPanA()
    postChangeSubFN(u, \fPLPan[d], -5)
  EndWith
EndProcedure

Procedure WQA_fcLogicalDevA()
  PROCNAMEC()
  
  WQA_fcMuteVideoAudio()
  With aSub(nEditSubPtr)
    SetGadgetText(WQA\txtSubPan, panSingleToString(\fPLPan[0]))
  EndWith
EndProcedure

Procedure WQA_fcSldPanA()
  PROCNAMEC()
  Protected d, k
  Protected u, u2
  
  If gbInDisplaySub = #False
    
    With aSub(nEditSubPtr)
      d = 0
      u = preChangeSubF(\fPLPan[d], GetGadgetText(WQA\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE, d)
      \fPLPan[d] = panSliderValToSingle(SLD_getValue(WQA\sldSubPan))
      \fSubPanNow[d] = \fPLPan[d]
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstPlayIndex
    While k >= 0
      With aAud(k)
        If \nFileState = #SCS_FILESTATE_OPEN
          u2 = preChangeAudF(\fPan[d], "Pan", k, #SCS_UNDO_ACTION_CHANGE, d)
          \fAudPlayPan[d] = aSub(nEditSubPtr)\fPLPan[d]
          \fPan[d] = \fAudPlayPan[d]
          If \nFileState = #SCS_FILESTATE_OPEN
            setLevelsAny(k, d, #SCS_NOVOLCHANGE_SINGLE, \fPan[d])
            \fCuePanNow[d] = \fPan[d]
          EndIf
          postChangeAudFN(u2, \fPan[d], k, d)
        EndIf
        k = \nNextPlayIndex
      EndWith
    Wend
    
    With aSub(nEditSubPtr)
      If (\fPLPan[d] = #SCS_PANCENTRE_SINGLE) Or (\bMuteVideoAudio)
        setEnabled(WQA\btnSubCenter, #False)
      Else
        setEnabled(WQA\btnSubCenter, #True)
      EndIf
      SetGadgetText(WQA\txtSubPan, panSingleToString(\fPLPan[d]))
      postChangeSubFN(u, \fPLPan[d], -5, d)
    EndWith
    
  EndIf
  
EndProcedure

Procedure WQA_fcSldLevelA()
  PROCNAMECA(nEditAudPtr)
  Protected k, d
  Protected u, u2
  
  If gbInDisplaySub = #False
    
    With aSub(nEditSubPtr)
      d = 0
      u = preChangeSubL(\fSubMastBVLevel[d], GetGadgetText(WQA\lblSubLevel), -5, #SCS_UNDO_ACTION_CHANGE, d)
      \fSubMastBVLevel[d] = SLD_getLevel(WQA\sldSubLevel)
      \sPLMastDBLevel[d] = convertBVLevelToDBString(\fSubMastBVLevel[d])
      \fSubBVLevelNow[d] = \fSubMastBVLevel[d]
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      With aAud(k)
        u2 = preChangeAudF(\fBVLevel[d], "Level", k, #SCS_UNDO_ACTION_CHANGE, d)
        \fAudPlayBVLevel[d] = aSub(\nSubIndex)\fSubMastBVLevel[d] * \fPLRelLevel / 100.0
        \fBVLevel[d] = \fAudPlayBVLevel[d]
        If \nFileState = #SCS_FILESTATE_OPEN
          If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
            setLevelsAny(k, d, \fBVLevel[d], #SCS_NOPANCHANGE_SINGLE)
            \fCueVolNow[d] = \fBVLevel[d]
            \fCueTotalVolNow[d] = \fCueVolNow[d]
          EndIf
        EndIf
        postChangeAudFN(u2, \fBVLevel[d], k, d)
        k = \nNextAudIndex
      EndWith
    Wend
    
    postChangeSubLN(u, aSub(nEditSubPtr)\fSubMastBVLevel[d], -5, d)
    
  EndIf
  
  If GetGadgetText(WQA\txtSubDBLevel) <> aSub(nEditSubPtr)\sPLMastDBLevel[d]
    SetGadgetText(WQA\txtSubDBLevel, aSub(nEditSubPtr)\sPLMastDBLevel[d])
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQA_fcTxtDBLevelA()
  PROCNAMEC()
  Protected k, d
  Protected u, u2
  
  If gbInDisplaySub = #False
    
    With aSub(nEditSubPtr)
      d = 0
      u = preChangeSubS(\sPLMastDBLevel[d], GetGadgetText(WQA\lblSubDb), -5, #SCS_UNDO_ACTION_CHANGE, d)
      \sPLMastDBLevel[d] = GetGadgetText(WQA\txtSubDBLevel)
      \fSubMastBVLevel[d] = convertDBStringToBVLevel(\sPLMastDBLevel[d])
      \fSubBVLevelNow[d] = \fSubMastBVLevel[d]
      SLD_setLevel(WQA\sldSubLevel, \fSubMastBVLevel[d], \fSubTrimFactor[d])
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstAudIndex
    While k >= 0
      With aAud(k)
        u2 = preChangeAudF(\fBVLevel[d], "Level", k, #SCS_UNDO_ACTION_CHANGE, d)
        \fAudPlayBVLevel[d] = aSub(nEditSubPtr)\fSubMastBVLevel[d] * \fPLRelLevel / 100.0
        \fBVLevel[d] = \fAudPlayBVLevel[d]
        If \nFileState = #SCS_FILESTATE_OPEN
          If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
            setLevelsAny(k, d, \fBVLevel[d], #SCS_NOPANCHANGE_SINGLE)
            \fCueVolNow[d] = \fBVLevel[d]
            \fCueTotalVolNow[d] = \fCueVolNow[d]
          EndIf
        EndIf
        postChangeAudFN(u2, \fBVLevel[d], k, d)
        k = \nNextAudIndex
      EndWith
    Wend
    
    postChangeSubSN(u, aSub(nEditSubPtr)\sPLMastDBLevel[d], -5, d)
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_fcTxtPanA()
  PROCNAMEC()
  Protected d, k
  Protected u, u2
  
  If gbInDisplaySub = #False
    
    With aSub(nEditSubPtr)
      d = 0
      u = preChangeSubF(\fPLPan[d], GetGadgetText(WQA\lblSubPan), -5, #SCS_UNDO_ACTION_CHANGE, d)
      \fPLPan[d] = panStringToSingle(GetGadgetText(WQA\txtSubPan))
      \fSubPanNow[d] = \fPLPan[d]
    EndWith
    
    k = aSub(nEditSubPtr)\nFirstPlayIndex
    While k >= 0
      With aAud(k)
        u2 = preChangeAudF(\fPan[d], "Pan", k, #SCS_UNDO_ACTION_CHANGE, d)
        \fAudPlayPan[d] = aSub(nEditSubPtr)\fPLPan[d]
        \fPan[d] = \fAudPlayPan[d]
        If \nFileState = #SCS_FILESTATE_OPEN
          setLevelsAny(k, d, #SCS_NOVOLCHANGE_SINGLE, \fPan[d])
          \fCuePanNow[d] = \fPan[d]
        EndIf
        postChangeAudFN(u2, \fPan[d], k, d)
        k = \nNextPlayIndex
      EndWith
    Wend
    
    With aSub(nEditSubPtr)
      SLD_setValue(WQA\sldSubPan, panToSliderValue(\fPLPan[d]))
      
      If \fPLPan[d] = #SCS_PANCENTRE_SINGLE
        setEnabled(WQA\btnSubCenter, #False)
      Else
        setEnabled(WQA\btnSubCenter, #True)
      EndIf
      
      postChangeSubFN(u, \fPLPan[d], -5, d)
    EndWith
    
  EndIf
  
EndProcedure

Procedure WQA_fcMuteVideoAudio()
  PROCNAMECS(nEditSubPtr)
  Protected bEnable
  Protected d
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      If \bMuteVideoAudio
        bEnable = #False
      Else
        bEnable = #True
      EndIf
      SLD_setEnabled(WQA\sldSubLevel, bEnable)
      setEnabled(WQA\txtSubDBLevel, bEnable)
      setEnabled(WQA\cboSubTrim, bEnable)
      
      SLD_setEnabled(WQA\sldSubPan, bEnable)
      setEnabled(WQA\txtSubPan, bEnable)
      If bEnable
        If \fPLPan[d] = #SCS_PANCENTRE_SINGLE
          setEnabled(WQA\btnSubCenter, #False)
        Else
          setEnabled(WQA\btnSubCenter, #True)
        EndIf
      Else
        setEnabled(WQA\btnSubCenter, #False)
      EndIf
      
    EndWith
  EndIf
EndProcedure

Procedure WQA_fcFileExtA(bForce)
  PROCNAMECA(nEditAudPtr)
  Protected bAvailable
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr <= 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    \sFileExt = GetExtensionPart(\sFileName)
    \nFileFormat = getFileFormat(\sFileName)
    SLD_setEnabled(WQA\sldProgress[0], #True)
    
    If \nFileFormat = #SCS_FILEFORMAT_PICTURE
      bAvailable = #False
    ElseIf \bAudPlaceHolder
      bAvailable = #False
    Else
      bAvailable = #True
    EndIf
    setEnabled(WQA\txtStartAt, bAvailable)
    ; setTextBoxBackColor(WQA\txtStartAt)
    
    debugMsg(sProcName, "\sFileExt=" + \sFileExt + ", \nFileFormat=" + \nFileFormat)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_fcSldRelLevel()
  PROCNAMEC()
  Protected d, k
  Protected u
  
  If gbInDisplaySub
    ProcedureReturn
  EndIf
  
  If gnWQACurrItem >= 0
    k = WQAFile(gnWQACurrItem)\nFileAudPtr
    If k > 0
      With aAud(k)
        u = preChangeAudF(\fPLRelLevel, GetGadgetText(WQA\lblRelLevel), k)
        \fPLRelLevel = SLD_getValue(WQA\sldRelLevel)
        
        d = 0
        debugMsg(sProcName, "aSub(\nSubIndex)\sVidAudLogicalDev=" + aSub(\nSubIndex)\sVidAudLogicalDev + ", aSub(\nSubIndex)\sPLLogicalDev[d]=" + aSub(\nSubIndex)\sPLLogicalDev[d])
        If Len(aSub(\nSubIndex)\sVidAudLogicalDev) > 0
          \fAudPlayBVLevel[d] = aSub(\nSubIndex)\fSubMastBVLevel[d] * \fPLRelLevel / 100.0
          debugMsg(sProcName, "\fAudPlayBVLevel[d]=" + formatLevel(\fAudPlayBVLevel[d]))
          \fBVLevel[d] = \fAudPlayBVLevel[d]
          \fCueVolNow[d] = \fBVLevel[d]
          \fCueTotalVolNow[d] = \fCueVolNow[d]
          If \nFileState = #SCS_FILESTATE_OPEN
            If \nAudState = #SCS_CUE_PLAYING Or ((\nAudState = #SCS_CUE_READY Or \nAudState = #SCS_CUE_COMPLETED) And \nFadeInTime = 0)
              setLevelsVideo(k, d, \fBVLevel[d], #SCS_NOPANCHANGE_SINGLE, #SCS_VID_PIC_TARGET_P)
              \fCueVolNow[d] = \fBVLevel[d]
              \fCueTotalVolNow[d] = \fCueVolNow[d]
            EndIf
          EndIf
        EndIf
        
        postChangeAudFN(u, \fPLRelLevel, k)
        
      EndWith
      
    EndIf
  EndIf
  
EndProcedure

Procedure WQA_btnScreens_Click()
  PROCNAMECS(nEditSubPtr)
  
  debugMsg(sProcName, "calling WEM_Form_Show(#True, #WED, #WQA, #SCS_WEM_A_SCREENS)")
  WEM_Form_Show(#True, #WED, #WQA, #SCS_WEM_A_SCREENS)
  ; must return now - unlike VB, PB doesn't block processing while the modal form is displayed
  ProcedureReturn
  
EndProcedure

Procedure WQA_displayPosAndSizeTextFields()
  PROCNAMECA(nEditAudPtr)
  Protected fSize.f, fDisplayValue.f
  Protected nFileDataPtr, nSourceWidth, nSourceHeight, nDisplayPos
  Protected nMyYPos, nMyXPos, nMySize, bEnableFields
  Static sXPosTT.s, sYPosTT.s
  Static bStaticLoaded
  Static nTooltipWidth, nTooltipHeight  ; not involved with bStaticLoaded
  Protected bTrace = #False ; conditional tracing because this procedure may be called many times while moving X, Y and Size sliders in the editor
  
  ; The xPos and yPos fields are held internally and in cue files as values in the range -5000 to +5000, representing full-left to full-right,
  ; and they have been like this ever since video/image cues were introduced. However, in #WQA we wish to display these fields as offsets based on
  ; the width and height of the source image (whether video or still image).
  ; For example, for an image size of 1280x720, if the image is to be displayed half-way to the right then the xPos should be displayed as -640;
  ; if half-way to the right then it should be displayed as 640. For no offset at all, the xPos should be displayed as 0.
  
  ; The size is held internally and in cue files as a value in the range -500 to +500, representing zero size to double-size.
  ; In #WQA we wish to display the size as a percentage in the range 0% to 200%. The default size is 100%.
  ; The size will be displayed to one decimal place if that decimal place is non-zero, eg 66.7% (non-zero decimal place), or 70% (zero decimal place).
  ; (NB: As from SCS 11.8.2.3ah, alwaya display whole number percentages, eg 67%, not 66.7%.)
  
  debugMsgC(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sXPosTT = Lang("WQA", "XPosTT")
    sYPosTT = Lang("WQA", "YPosTT")
    bStaticLoaded = #True
  EndIf
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      ; xPos and yPos
      nMyYPos = \nYPos
      nMyXPos = \nXPos
      nMySize = \nSize
      bEnableFields = #True
      Select \nVideoSource
        Case #SCS_VID_SRC_FILE
          nFileDataPtr = \nFileDataPtr
          If nFileDataPtr >= 0
            nSourceWidth = gaFileData(nFileDataPtr)\nSourceWidth
            nSourceHeight = gaFileData(nFileDataPtr)\nSourceHeight
          EndIf
        Case #SCS_VID_SRC_CAPTURE
          debugMsgC(sProcName, "\nAudVidPicTarget=" + decodeVidPicTarget(\nAudVidPicTarget) + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight + ", \sVideoCaptureLogicalDevice=" + \sVideoCaptureLogicalDevice)
          nSourceWidth = \nSourceWidth
          nSourceHeight = \nSourceHeight
      EndSelect
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        If \nImageFrameCount > 1
          nMyYPos = grAudDef\nYPos
          nMyXPos = grAudDef\nXPos
          nMySize = grAudDef\nSize
          bEnableFields = #False
        EndIf
        Select \nRotate
          Case 90, 270
            Swap nSourceWidth, nSourceHeight
        EndSelect
      EndIf
      debugMsgC(sProcName, "\nVideoSource=" + decodeVideoSource(\nVideoSource) + ", nFileDataPtr=" + nFileDataPtr + ", nSourceWidth=" + nSourceWidth + ", nSourceHeight=" + nSourceHeight)
      nDisplayPos =  Round(nSourceWidth * nMyXPos / 5000, #PB_Round_Nearest)
      SGT(WQA\txtXPos, Str(nDisplayPos))
      setEnabled(WQA\txtXPos, bEnableFields, #True)
      nDisplayPos =  Round(nSourceHeight * nMyYPos / 5000, #PB_Round_Nearest)
      SGT(WQA\txtYPos, Str(nDisplayPos))
      setEnabled(WQA\txtYPos, bEnableFields, #True)
      
      If nTooltipWidth <> nSourceWidth
        nTooltipWidth = nSourceWidth
        scsToolTip(WQA\txtXPos, ReplaceString(sXPosTT, "$1", Str(nTooltipWidth)))
      EndIf
      If nTooltipHeight <> nSourceHeight
        nTooltipHeight = nSourceHeight
        scsToolTip(WQA\txtYPos, ReplaceString(sYPosTT, "$1", Str(nTooltipHeight)))
      EndIf
      
      ; size
      If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
        fSize = nMySize * -1
        If fSize >= 0.0
          ; values 0 - 500 to be converted to vMix zoom values 1.0 to 5.0
          fDisplayValue = (fSize / 1.25) + 100.0
        Else
          ; values -500 to < 0.0 to be converted to vMix zoom values 0 to 1.0
          fDisplayValue = (fSize + 500) / 5
        EndIf
      Else
        ; fDisplayValue = ((0 - \nSize) / 5) + 100
        fDisplayValue = convertSizeToPercentage(nMySize)
      EndIf
      SGT(WQA\txtSize, StrF(fDisplayValue, 0) + "%")
      debugMsgC(sProcName, "GGT(WQA\txtSize)=" + GGT(WQA\txtSize))
      setEnabled(WQA\txtSize, bEnableFields, #True)
    EndWith
  EndIf
  
EndProcedure

Procedure WQA_displayRotateInfo(bMultipleRotates=#False)
  PROCNAMECA(nEditAudPtr)
  Protected sRotateInfo.s, nLineCount
  
  If bMultipleRotates = #False
    If nEditAudPtr >= 0
      With aAud(nEditAudPtr)
        Select \nRotate
          Case 90
            sRotateInfo = Lang("Menu", "mnuRotateR90")
          Case 180
            sRotateInfo = Lang("Menu", "mnuRotate180")
          Case 270
            sRotateInfo = Lang("Menu", "mnuRotateL90")
        EndSelect
        If \nFlip & #SCS_FLIPH = #SCS_FLIPH
          If sRotateInfo
            sRotateInfo + Chr(10)
          EndIf
          sRotateInfo + Lang("Menu", "mnuFlipH")
        EndIf
        If \nFlip & #SCS_FLIPV = #SCS_FLIPV
          If sRotateInfo
            sRotateInfo + Chr(10)
          EndIf
          sRotateInfo + Lang("Menu", "mnuFlipV")
        EndIf
      EndWith
    EndIf
  EndIf
  SGT(WQA\lblRotateInfo, sRotateInfo)
  
EndProcedure

Procedure WQA_mbgRotate_Click()
  PROCNAMECA(nEditAudPtr)
  
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE
      DisplayPopupMenu(#WQA_mnuRotate, WindowID(#WED))
    EndIf
  EndIf
  
EndProcedure

Procedure WQA_mnuRotate_Click(nMenuHandle)
  PROCNAMEC()
  Protected u
  Protected nThisRotate, nThisFlip, bResetImage
  Protected nNewRotate, nNewFlip
  Static sRotate.s
  
  debugMsg(sProcName, #SCS_START + ", nMenuHandle=" + decodeMenuItem(nMenuHandle))
  
  Select nMenuHandle
    Case #WQA_mnuRotateL90
      nThisRotate = 270
    Case #WQA_mnuRotateR90
      nThisRotate = 90
    Case #WQA_mnuRotate180
      nThisRotate = 180
    Case #WQA_mnuFlipH
      nThisFlip = #SCS_FLIPH
    Case #WQA_mnuFlipV
      nThisFlip = #SCS_FLIPV
    Case #WQA_mnuRotateReset
      bResetImage = #True
  EndSelect
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      debugMsg(sProcName, "nThisRotate=" + Str(nThisRotate) + ", nThisFlip=" + Str(nThisFlip) + ", bResetImage=" + strB(bResetImage))
      debugMsg(sProcName, "\nRotate=" + Str(\nRotate) + ", \nFlip=" + Str(\nFlip))
      If Len(sRotate) = 0
        sRotate = Lang("WQA", "mbgRotate")
      EndIf
      u = preChangeAudL((\nRotate + (\nFlip*1000)), sRotate)
      
      nNewRotate = \nRotate + nThisRotate
      If nNewRotate >= 360
        nNewRotate - 360
      EndIf
      nNewFlip = \nFlip ! nThisFlip ; exclusive Or to change state of horizontal or vertical flag if required
      
      debugMsg(sProcName, "bResetImage=" + strB(bResetImage) + ", nNewRotate=" + Str(nNewRotate) + ", nNewFlip=" + Str(nNewFlip))
      If (bResetImage) Or (nNewRotate = 0 And nNewFlip = 0)
        ; reset image if requested, or if changing back to original state
        ; debugMsg(sProcName, "resetting")
        nNewRotate = 0
        nNewFlip = 0
      EndIf
      
      \nRotate = nNewRotate
      \nFlip = nNewFlip
      \bReRotateImage = #True
      \bReRotatePosImage = #True
      
      WQA_drawPreviewImage2()
      WQA_drawTimeLineImage2(gnWQACurrItem)
      
      WQA_displayRotateInfo()
      
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      
      postChangeAudL(u, (\nRotate + (\nFlip*1000)))
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_mbgOther_Click()
  PROCNAMECA(nEditAudPtr)
  
  If nEditAudPtr >= 0
    WQA_buildPopupMenu_Other()
    DisplayPopupMenu(#WQA_mnuOther, WindowID(#WED))
  EndIf
  
EndProcedure

Procedure WQA_mnuOther_Click(nMenuHandle)
  PROCNAMEC()
  Protected u
  
  debugMsg(sProcName, #SCS_START + ", nMenuHandle=" + decodeMenuItem(nMenuHandle))
  
  Select nMenuHandle
    Case #WQA_mnuOtherDefault   ; #WQA_mnuOtherDefault
      With aAud(nEditAudPtr)
        u = preChangeAudL(#True, Lang("Menu", "mnuOtherDefault"))
        ; see also procedure isVideoDisplayDefault()
        \nXPos = grAudDef\nXPos
        \nYPos = grAudDef\nYPos
        \nSize = grAudDef\nSize
        \nAspect = grAudDef\nAspect
        \nAspectRatioType = grAudDef\nAspectRatioType
        \nAspectRatioHVal = grAudDef\nAspectRatioHVal
        \bReloadMainImage = #True
        \bReOpenVidFile = #True
        SLD_setValue(WQA\sldXPos, \nXPos)
        SLD_setValue(WQA\sldYPos, \nYPos)
        SLD_setValue(WQA\sldSize, \nSize)
        WQA_displayPosAndSizeTextFields()
        setComboBoxByData(WQA\cboAspectRatioType, \nAspectRatioType)
        SLD_setValue(WQA\sldAspectRatioHVal, \nAspectRatioHVal)
        postChangeAudLN(u, #False)
      EndWith
      WQA_fcAspectRatioType()
      WQA_setPosAndSize2(#SCS_PS_ALL)
      
    Case #WQA_mnuOtherCopy   ; #WQA_mnuOtherCopy
      copyPosSizeAndAspectToClipboard(nEditAudPtr)
      
    Case #WQA_mnuOtherPaste   ; #WQA_mnuOtherPaste
      With aAud(nEditAudPtr)
        u = preChangeAudL(#True, Lang("Menu", "mnuOtherPaste"))
        pastePosSizeAndAspectFromClipboard(nEditAudPtr)
        \bReloadMainImage = #True
        \bReOpenVidFile = #True
        SLD_setValue(WQA\sldXPos, \nXPos)
        SLD_setValue(WQA\sldYPos, \nYPos)
        SLD_setValue(WQA\sldSize, \nSize)
        WQA_displayPosAndSizeTextFields()
        setComboBoxByData(WQA\cboAspectRatioType, \nAspectRatioType)
        SLD_setValue(WQA\sldAspectRatioHVal, \nAspectRatioHVal)
        postChangeAudL(u, #False)
      EndWith
      WQA_fcAspectRatioType()
      WQA_setPosAndSize2(#SCS_PS_ALL)
      
  EndSelect
  
  ; WQA_setCursorOnPreviewPanel()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_mnuSetCueMarkerPosition()
  setCueMarkerPosition(@grMG5)
EndProcedure

Procedure  WQA_mnuAddQuickCueMarkers()
  ; Purpose is to add a Quick Cue Marker to the Current Video File at the mouse click position
  addQuickCueMarker(@grMG5)
EndProcedure

Procedure WQA_cboQATransType_Click(bMultiSelect, bFirstSelectedItem)
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudL(\nPLTransType, GGT(WQA\lblTransType))
      \nPLTransType = getCurrentItemData(WQA\cboQATransType, #SCS_TRANS_NONE)
      If \nPLTransType = #SCS_TRANS_NONE
        \nPLTransTime = grAudDef\nPLTransTime
      EndIf
      \nPLRunTimeTransType = \nPLTransType
      If bMultiSelect = #False
        WQA_fcQATransType()
      Else
        If \nPLTransType = #SCS_TRANS_NONE
          setEnabled(WQA\txtQATransTime, #False)
        Else
          SGT(WQA\txtQATransTime, "")
          setEnabled(WQA\txtQATransTime, #True)
        EndIf
      EndIf
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPLTransType=" + decodeTransType(\nPLTransType) + ", \nPLTransTime=" + \nPLTransTime)
      postChangeAudLN(u, \nPLTransType)
    EndWith
  EndIf
  ProcedureReturn #True   ; required by WQA_multiItemValidate()
EndProcedure

Procedure WQA_SizeOrPosChanged()
  ; PROCNAMECA(nEditAudPtr)
  ; nb must be called from within a PreChange/PostChange pair
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nFileFormat=" + decodeFileFormat(\nFileFormat) + ", \nPrimeVideoVidPicTarget=" + decodeVidPicTarget(\nPrimeVideoVidPicTarget))
      Select \nFileFormat
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
          \bReloadMainImage = #True
          \bReOpenVidFile = #True
        Case #SCS_FILEFORMAT_VIDEO
          Select \nPrimeVideoVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
              \bPrimeVideoReqd = #True
              ; debugMsg0(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bPrimeVideoReqd=" + strB(\bPrimeVideoReqd))
          EndSelect
      EndSelect
      If grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_VMIX
        ; debugMsg(sProcName, "calling assignCanvases(" + getSubLabel(\nSubIndex) + ", " + getAudLabel(nEditAudPtr) + ", #False)")
        assignCanvases(\nSubIndex, nEditAudPtr, #False)
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_cboAspectRatioType_Click()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      u = preChangeAudL(\nAspectRatioType, GGT(WQA\lblAspectRatioType))
      \nAspectRatioType = getCurrentItemData(WQA\cboAspectRatioType, #SCS_ART_ORIGINAL)
      debugMsg(sProcName, "\nAspectRatioType=" + decodeAspectRatioType(\nAspectRatioType))
      WQA_fcAspectRatioType()
      ; \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nAspectRatioType)
      WQA_setPosAndSize2()
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_txtQATransTime_Validate(bMultiSelect, bFirstSelectedItem)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nTime
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If bFirstSelectedItem
        If validateTimeField(GGT(WQA\txtQATransTime), GGT(WQA\lblTransTime), #False, #False, \nFileDuration) = #False
          ProcedureReturn #False
        ElseIf GGT(WQA\txtQATransTime) <> gsTmpString
          SGT(WQA\txtQATransTime, gsTmpString)
        EndIf
      EndIf
      nTime = stringToTime(GGT(WQA\txtQATransTime))
      If nTime <> \nPLTransTime
        u = preChangeAudL(\nPLTransTime, GGT(WQA\lblTransTime))
        \nPLTransTime = nTime
        \nPLRunTimeTransTime = \nPLTransTime
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPLTransTime=" + \nPLTransTime)
        If bMultiSelect = #False
          WQA_doSubTotals()
        EndIf
        postChangeAudLN(u, \nPLTransTime)
      EndIf
    EndWith
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure WQA_fcQATransType()
  PROCNAMECA(nEditAudPtr)
  Protected u
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \nPLTransType > #SCS_TRANS_NONE
        setEnabled(WQA\txtQATransTime, #True)
      Else
        setEnabled(WQA\txtQATransTime, #False)
        If Len(Trim(GetGadgetText(WQA\txtQATransTime))) > 0
          SetGadgetText(WQA\txtQATransTime, "")
          u = preChangeAudL(\nPLTransTime, GetGadgetText(WQA\lblTransTime))
          \nPLTransTime = grAudDef\nPLTransTime
          debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPLTransTime=" + \nPLTransTime)
          postChangeAudLN(u, \nPLTransTime)
        EndIf
      EndIf
      setTextBoxBackColor(WQA\txtQATransTime)
    EndWith
  EndIf
  
EndProcedure

Procedure WQA_fcAspectRatioType()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \nAspectRatioType = #SCS_ART_CUSTOM
        SLD_setValue(WQA\sldAspectRatioHVal, \nAspectRatioHVal)
        SLD_setVisible(WQA\sldAspectRatioHVal, #True)
      Else
        SLD_setVisible(WQA\sldAspectRatioHVal, #False)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQA_renameFile()
  PROCNAMEC()
  Protected nRow, nAudPtr
  
  nRow = gnWQACurrItem
  If nRow >= 0
    nAudPtr = WQAFile(gnWQACurrItem)\nFileAudPtr
    If nAudPtr >= 0 And WQAFile(gnWQACurrItem)\nFileNameLen > 0
      rWQA\nItemIndex = nRow
      rWQA\nScrollPos = GetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X)
      WFR_renameAudFile(aAud(nAudPtr)\sFileName, "A")
      ; no further action allowed here as WFR_renameAudFile() opens a modal window
    EndIf
  EndIf
EndProcedure

Procedure WQA_transportBtnClick(nButtonType)
  PROCNAMEC()
  Protected nListIndex, nLastFile, nFirstFile
  Protected k, bValidateOK
  Protected nState
  Protected nOriginalAudPtr, nOriginalAudState
  Protected n
  Protected bAudPlaying, bResetPlaylist
  Protected bShowVideoPreviewImage = #True
  Protected nPrimaryVidPicTarget
  Protected b2DDrawingImage
  
  debugMsg(sProcName, #SCS_START + ", nButtonType=" + decodeStdBtnType(nButtonType))
  
  nListIndex = gnWQACurrItem
  debugMsg(sProcName, "nListIndex=" + nListIndex)
  nLastFile = -1
  nFirstFile = -1
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileAudPtr > 0
      If nFirstFile = -1
        nFirstFile = n
      EndIf
      nLastFile = n
    EndIf
  Next n
  
  nOriginalAudPtr = nEditAudPtr
  If nOriginalAudPtr >= 0
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      If (aAud(nOriginalAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (checkUse2DDrawing(nEditSubPtr))
        b2DDrawingImage = #True
      EndIf
    EndIf
    nOriginalAudState = aAud(nOriginalAudPtr)\nAudState
    If (nOriginalAudState >= #SCS_CUE_FADING_IN) And (nOriginalAudState <= #SCS_CUE_FADING_OUT) And (nOriginalAudState <> #SCS_CUE_PAUSED)
      bAudPlaying = #True
      bShowVideoPreviewImage = #False ; to prevent preview image being briefly shown before the video itself starts playing
    EndIf
  EndIf
  debugMsg(sProcName, "nOriginalAudPtr=" + getAudLabel(nOriginalAudPtr) + ", nOriginalAudState=" + decodeCueState(nOriginalAudState) +
                      ", bAudPlaying=" + strB(bAudPlaying) + ", b2DDrawingImage=" + strB(b2DDrawingImage))
  If bAudPlaying = #False
    bResetPlaylist = #True
  EndIf
  
  nPrimaryVidPicTarget = #SCS_VID_PIC_TARGET_P
  If gbPreviewOnOutputScreen
    If nEditSubPtr >= 0
      If aSub(nEditSubPtr)\nOutputScreen >= 2
        gnPreviewOnOutputScreenNo = aSub(nEditSubPtr)\nOutputScreen
        If (grVideoDriver\nVideoPlaybackLibrary <> #SCS_VPL_TVG) Or (b2DDrawingImage)
          nPrimaryVidPicTarget = #SCS_VID_PIC_TARGET_F2 + aSub(nEditSubPtr)\nOutputScreen - 2
        EndIf
      EndIf
    EndIf
  EndIf
  debugMsg(sProcName, "gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo + ", nPrimaryVidPicTarget=" + decodeVidPicTarget(nPrimaryVidPicTarget))
  
  logKeyEvent(gaGadgetProps(gnEventGadgetPropsIndex)\sLogName + " button click, nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  Select nButtonType
      
    Case #SCS_STANDARD_BTN_FIRST  ; first file
      If bAudPlaying
        editQAStop(nEditSubPtr, bResetPlaylist)
      EndIf
      WQA_processItemSelected(nFirstFile, #True, bShowVideoPreviewImage)
      
    Case #SCS_STANDARD_BTN_PREV  ; previous file
      If bAudPlaying
        editQAStop(nEditSubPtr, bResetPlaylist)
      EndIf
      WQA_processItemSelected(nListIndex-1, #True, bShowVideoPreviewImage)
      
    Case #SCS_STANDARD_BTN_NEXT  ; next file
      If bAudPlaying
        editQAStop(nEditSubPtr, bResetPlaylist)
      EndIf
      WQA_processItemSelected(nListIndex+1, #True, bShowVideoPreviewImage)
      
    Case #SCS_STANDARD_BTN_LAST  ; last file
      If bAudPlaying
        editQAStop(nEditSubPtr, bResetPlaylist)
      EndIf
      WQA_processItemSelected(nLastFile, #True, bShowVideoPreviewImage)
      
    Case #SCS_STANDARD_BTN_REWIND  ; rewind
      nState = aAud(nEditAudPtr)\nAudState
      If (nState >= #SCS_CUE_FADING_IN) And (nState <= #SCS_CUE_FADING_OUT) And (nState <> #SCS_CUE_PAUSED)
        debugMsg(sProcName, "calling stopAud(" + getAudLabel(nEditAudPtr) + ", #True)")
        stopAud(nEditAudPtr, #True)
        debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + aAud(nEditAudPtr)\nAbsStartAt + ")")
        reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt)
        With aAud(nEditAudPtr)
          \qTimeAudStarted = gqTimeNow
          ; \qTimeAudEnded = 0
          \bTimeAudEndedSet = #False
          \qTimeAudRestarted = gqTimeNow
          \nTotalTimeOnPause = 0
          \nPriorTimeOnPause = 0
          \nPreFadeInTimeOnPause = 0
          \nPreFadeOutTimeOnPause = 0
          \nCuePosAtLoopStart = 0
        EndWith
        debugMsg(sProcName, "calling playAud(" + nEditAudPtr + ")")
        playAud(nEditAudPtr)
      Else
        debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + aAud(nEditAudPtr)\nAbsStartAt + ")")
        reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt)
        If aAud(nEditAudPtr)\nAudState = #SCS_CUE_PAUSED
          aAud(nEditAudPtr)\nAudState = #SCS_CUE_READY
          setCueState(nEditCuePtr)
        EndIf
      EndIf
      
    Case #SCS_STANDARD_BTN_PLAY  ; play
      gqTimeNow = ElapsedMilliseconds()
      
      With aSub(nEditSubPtr)
        k = \nFirstAudIndex
        bValidateOK = #True
        While (k >= 0) And (bValidateOK)
          bValidateOK = valAud(k)
          k = aAud(k)\nNextAudIndex
        Wend
        
        If bValidateOK = #False
          ProcedureReturn
        EndIf
        
        \bPLTerminating = #False
        \bPLFadingIn = #False
        \bPLFadingOut = #False
        \bStartedInEditor = #True
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(\nSubState) + ", aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(aAud(nEditAudPtr)\nAudState) + ", \nFileState=" + decodeFileState(aAud(nEditAudPtr)\nFileState))
        nState = \nSubState
        
        If nState = #SCS_CUE_PAUSED
          resumeAud(nEditAudPtr)
          
        ElseIf (nState < #SCS_CUE_FADING_IN) Or (nState = #SCS_CUE_PL_READY)
          grVidPicTarget(nPrimaryVidPicTarget)\nAudPtr1 = -1
          grVidPicTarget(nPrimaryVidPicTarget)\nImage1 = grVidPicTarget(nPrimaryVidPicTarget)\nBlackImageNo
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nPrimaryVidPicTarget) + ")\nAudPtr1=" + getAudLabel(grVidPicTarget(nPrimaryVidPicTarget)\nAudPtr1) + ", \nImage1=" + decodeHandle(grVidPicTarget(nPrimaryVidPicTarget)\nImage1) +
                              ", \nAudPtr2=" + getAudLabel(grVidPicTarget(nPrimaryVidPicTarget)\nAudPtr2) + ", \nImage2=" + decodeHandle(grVidPicTarget(nPrimaryVidPicTarget)\nImage2))
          Select aAud(nEditAudPtr)\nVideoSource
            Case #SCS_VID_SRC_FILE
              If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
                debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #False, " + decodeVidPicTarget(nPrimaryVidPicTarget) + ")")
                openMediaFile(nEditAudPtr, #False, nPrimaryVidPicTarget)
              EndIf
              If (grVidPicTarget(nPrimaryVidPicTarget)\nPrimaryAudPtr <> nEditAudPtr)
                If aAud(nEditAudPtr)\bAudUseGaplessStream
                  debugMsg(sProcName, "calling openVideoGaplessStreamForEditor(" + decodeVidPicTarget(nPrimaryVidPicTarget) + ")")
                  If openVideoGaplessStreamForEditor(nPrimaryVidPicTarget)
                    ; openVideoGaplessStreamForEditor() successful - continue
                    \bStartedInEditor = #True ; need to reset \bStartedInEditor as it may have been cleared in a procedure called via openVideoGaplessStreamForEditor()
                  Else
                    ; openVideoGaplessStreamForEditor() failed due to another gapless stream currently running, so cannot play this stream
                    ProcedureReturn
                  EndIf
                EndIf
              EndIf
              If aAud(nEditAudPtr)\bAudUseGaplessStream
                rWQA\nStartFileNo = 1 ; always start playing a gapless stream from the start of the stream
                ; debugMsg(sProcName, "rWQA\nStartFileNo=" + rWQA\nStartFileNo)
                \nCurrPlayIndex = aSub(nEditSubPtr)\nFirstAudIndex
                debugMsg(sProcName, "calling editPlaySub(-1, " + rWQA\nStartFileNo + ")")
                editPlaySub(-1, rWQA\nStartFileNo)
              Else
                If aAud(nEditAudPtr)\nFileState = #SCS_FILESTATE_OPEN
                  \nCurrPlayIndex = nEditAudPtr
                ElseIf (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (b2DDrawingImage = #False)
                  \nCurrPlayIndex = nEditAudPtr
                  openNextAudsForSubA(nEditSubPtr, nPrimaryVidPicTarget)
                Else
                  debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ", #False, " + decodeVidPicTarget(nPrimaryVidPicTarget) + ")")
                  openMediaFile(nEditAudPtr, #False, nPrimaryVidPicTarget)
                  \nCurrPlayIndex = nEditAudPtr
                EndIf
                rWQA\nStartFileNo = nListIndex + 1
                ; debugMsg(sProcName, "rWQA\nStartFileNo=" + rWQA\nStartFileNo)
                If (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (b2DDrawingImage = #False)
                  If gnPreviewOnOutputScreenNo > 0
                    debugMsg(sProcName, "calling WQA_clearPreviewOnOutputScreen(" + gnPreviewOnOutputScreenNo + ")")
                    WQA_clearPreviewOnOutputScreen(gnPreviewOnOutputScreenNo)
                  EndIf
                EndIf
                debugMsg(sProcName, "calling editPlaySub(-1, " + rWQA\nStartFileNo + ")")
                editPlaySub(-1, rWQA\nStartFileNo)
              EndIf
              
            Case #SCS_VID_SRC_CAPTURE
              debugMsg(sProcName, "calling setTVGDisplayLocationsForSub(" + getSubLabel(nEditSubPtr) + ")")
              rWQA\nStartFileNo = nListIndex + 1
              ; debugMsg(sProcName, "rWQA\nStartFileNo=" + rWQA\nStartFileNo)
              If (grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG) And (b2DDrawingImage = #False)
                If gnPreviewOnOutputScreenNo > 0
                  debugMsg(sProcName, "calling WQA_clearPreviewOnOutputScreen(" + gnPreviewOnOutputScreenNo + ")")
                  WQA_clearPreviewOnOutputScreen(gnPreviewOnOutputScreenNo)
                EndIf
              EndIf
              setTVGDisplayLocationsForSub(nEditSubPtr)
              debugMsg(sProcName, "calling editPlaySub(-1, " + rWQA\nStartFileNo + ")")
              editPlaySub(-1, rWQA\nStartFileNo)
          EndSelect
          
        Else
          rWQA\nStartFileNo = nListIndex + 1
          ; debugMsg(sProcName, "rWQA\nStartFileNo=" + rWQA\nStartFileNo)
          \nCurrPlayIndex = nEditAudPtr
          restartAud(nEditAudPtr)
          
        EndIf
      EndWith
      
    Case #SCS_STANDARD_BTN_PAUSE  ; pause
      gqTimeNow = ElapsedMilliseconds()
      debugMsg(sProcName, "calling pauseAud(" + nEditAudPtr + ")")
      pauseAud(nEditAudPtr)
      setCueState(nEditCuePtr)
      
    Case #SCS_STANDARD_BTN_FADEOUT  ; fadeout
      gqTimeNow = ElapsedMilliseconds()
      fadeOutSub(nEditSubPtr, #False)
      
    Case #SCS_STANDARD_BTN_STOP  ; stop
      editQAStop(nEditSubPtr)
      
  EndSelect
  
  Select nButtonType
    Case #SCS_STANDARD_BTN_FIRST, #SCS_STANDARD_BTN_PREV, #SCS_STANDARD_BTN_NEXT, #SCS_STANDARD_BTN_LAST
      gqTimeNow = ElapsedMilliseconds()
      If bAudPlaying
        If nOriginalAudPtr >= 0
          stopAud(nOriginalAudPtr, #True)
        EndIf
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nEditAudPtr) + ", " + aAud(nEditAudPtr)\nAbsStartAt + ")")
        reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt)
        With aAud(nEditAudPtr)
          \qTimeAudStarted = gqTimeNow
          ; \qTimeAudEnded = 0
          \bTimeAudEndedSet = #False
          \qTimeAudRestarted = gqTimeNow
          \nTotalTimeOnPause = 0
          \nPriorTimeOnPause = 0
          \nPreFadeInTimeOnPause = 0
          \nPreFadeOutTimeOnPause = 0
          \nCuePosAtLoopStart = 0
        EndWith
        With aSub(nEditSubPtr)
          \bStartedInEditor = #True
        EndWith
        ; debugMsg(sProcName, "calling playAud(" + getAudLabel(nEditAudPtr) + ")")
        playAud(nEditAudPtr)
      Else
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nEditAudPtr) + ", " + aAud(nEditAudPtr)\nAbsStartAt + ")")
        reposAuds(nEditAudPtr, aAud(nEditAudPtr)\nAbsStartAt)
        aAud(nEditAudPtr)\nAudState = #SCS_CUE_READY
      EndIf
      
      k = aAud(nEditAudPtr)\nNextPlayIndex
      While k >= 0
        debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(aAud(k)\nAudState))
        reposAuds(k, aAud(k)\nAbsStartAt)
        aAud(k)\nAudState = #SCS_CUE_PL_READY
        k = aAud(k)\nNextPlayIndex
      Wend
      setCueState(nEditCuePtr)
      
      aSub(nEditSubPtr)\nCurrPlayIndex = nEditAudPtr
      calcPLUnplayedFilesTime(nEditSubPtr)
      
  EndSelect
  
  ; setResyncLinksReqd(nEditAudPtr)
  WQA_SetTransportButtons()
  WQA_setTBSButtons()
  WQA_setEnabledStates()
  
  gbCallEditUpdateDisplay = #True
  SAG(WQA\cvsDummy)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_getItemForAud(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, nItem
  
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileAudPtr = pAudPtr
      nItem = n
      Break
    EndIf
  Next n
  ProcedureReturn nItem
EndProcedure

Procedure WQA_processItemSelected(nItem, bCheckKeyboard=#True, bShowVideoPreviewImage=#True)
  PROCNAMEC()
  Protected nCurrItem, nSelectedItemCount, nListIndex
  Protected nFirstInRange, nLastInRange
  Protected bBlankItemSelected
  Protected nLeft, nScrollAreaX, nScrollAreaVisibleWidth, nReqdScrollAreaX
  Protected n
  Protected bNoConnectedCaptureDevices
  
  debugMsg(sProcName, #SCS_START + ", nItem=" + Str(nItem))
  
  If nItem = -100
    ; user pressed Ctrl/A to select all items
    nCurrItem = gnWQACurrItem
    For n = 0 To gnWQALastItem
      If WQAFile(n)\nFileAudPtr >= 0
        WQAFile(n)\bSelected = #True
      Else
        WQAFile(n)\bSelected = #False
      EndIf
    Next n
  Else
    nCurrItem = nItem
  EndIf
  
  For n = 0 To gnWQALastItem
    If WQAFile(n)\bSelected
      nSelectedItemCount + 1
    EndIf
  Next n
  
  If nSelectedItemCount = 0
    rWQA\nFirstSelectedItem = nCurrItem
  EndIf
  
  If nItem <> -100
    ; not Ctrl/A
    If (bCheckKeyboard) And (GetAsyncKeyState_(#VK_SHIFT) & (1 << 15)) ; SHIFT KEY PRESSED
      debugMsg(sProcName, "Shift key pressed")
      ; clear any existing selected item indicators except for items within the range <nFirstSelectedItem> to <nCurrItem>
      If rWQA\nFirstSelectedItem <= nCurrItem
        nFirstInRange = rWQA\nFirstSelectedItem
        nLastInRange = nCurrItem
      Else
        nFirstInRange = nCurrItem
        nLastInRange = rWQA\nFirstSelectedItem
      EndIf
      For n = 0 To gnWQALastItem
        nListIndex = n
        If (nListIndex >= nFirstInRange) And (nListIndex <= nLastInRange)
          WQAFile(n)\bSelected = #True
        Else
          WQAFile(n)\bSelected = #False
        EndIf
      Next n
      
    ElseIf (bCheckKeyboard) And (GetAsyncKeyState_(#VK_CONTROL) & (1 << 15))   ; CONTROL KEY PRESSED
      debugMsg(sProcName, "Control key pressed")
      ; flip selected item indicator in the selected item, leaving any other selected item indicators unchanged
      If WQAFile(nCurrItem)\bSelected
        WQAFile(nCurrItem)\bSelected = #False
        debugMsg(sProcName, "item " + Str(nCurrItem) + " deselected")
        ; user has deselected the current item, so we need to change the 'current item' to a selected item - use the first selected item (if any)
        For n = 0 To gnWQALastItem
          If WQAFile(n)\bSelected
            nCurrItem = n
            Break
          EndIf
        Next n
      Else
        WQAFile(nCurrItem)\bSelected = #True
        debugMsg(sProcName, "item " + Str(nCurrItem) + " selected")
      EndIf
      
    Else  ; NEITHER SHIFT NOR CONTROL PRESSED, or bCheckKeyboard = #False
      If bCheckKeyboard = #False
        debugMsg(sProcName, "bCheckKeyboard=" + strB(bCheckKeyboard))
      Else
        debugMsg(sProcName, "Neither Shift nor Control pressed")
      EndIf
      ; clear any existing selected item indicators except for the currently selected item
      For n = 0 To gnWQALastItem
        If n = nCurrItem
          WQAFile(n)\bSelected = #True
        Else
          WQAFile(n)\bSelected = #False
        EndIf
      Next n
      rWQA\nFirstSelectedItem = nCurrItem
    EndIf
  EndIf
  
  nSelectedItemCount = 0
  For n = 0 To gnWQALastItem
    If WQAFile(n)\bSelected
      nSelectedItemCount + 1
      If WQAFile(n)\nFileAudPtr = -1
        bBlankItemSelected = #True
      EndIf
    EndIf
  Next n
  
  debugMsg(sProcName, "nSelectedItemCount=" + Str(nSelectedItemCount) + ", bBlankItemSelected=" + strB(bBlankItemSelected))
  If (nSelectedItemCount > 1) And (bBlankItemSelected)
    ; not permitted for a multi-select to include a blank item
    ; if the current item is a blank item then exit now, else just drop the blank item(s) out
    For n = 0 To gnWQALastItem
      If WQAFile(n)\bSelected
        If WQAFile(n)\nFileAudPtr = -1
          If n = nCurrItem
            ProcedureReturn
          Else
            WQAFile(n)\bSelected = #False
          EndIf
        EndIf
      EndIf
    Next n
  EndIf
  
  WQA_setCurrentItem(nCurrItem, bShowVideoPreviewImage)
  
  ; We want to know if we have connected capture devices here
  bNoConnectedCaptureDevices = checkif_VidCapDevsDefined()
  
  ;- Uncomment this line below to test normal functionality with no capture devices connected even if there are
  ;bNoConnectedCaptureDevices = #False
  
  If bBlankItemSelected And Not bNoConnectedCaptureDevices 
    debugMsg(sProcName, "(blank item selected) calling WQA_btnBrowse_Click()")
    WQA_btnBrowse_Click(#True)
  ElseIf bNoConnectedCaptureDevices
    debugMsg(sProcName, "(blank item selected) - Connected Capture Devices - adding blank place-holder")
    ; We have some capture devices connected
    ; Just add a place-holder here
    ; We need to setup for having video capture so change the display
  EndIf
  
  ; make sure selected item is fully visible
  If nItem >= 0
    nLeft = nItem * #SCS_QAITEM_WIDTH
    nScrollAreaX = GetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X)
    nScrollAreaVisibleWidth = GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX
    ; debugMsg(sProcName, "nLeft=" + nLeft + ", #SCS_QAITEM_WIDTH=" + Str(#SCS_QAITEM_WIDTH) + ", nScrollAreaX=" + Str(nScrollAreaX) + ", nScrollAreaVisibleWidth=" + Str(nScrollAreaVisibleWidth))
    If (nLeft + #SCS_QAITEM_WIDTH) > (nScrollAreaX + nScrollAreaVisibleWidth)
      ; wholly or partially to the right of the visible area
      nReqdScrollAreaX = nLeft - #SCS_QAITEM_WIDTH
      ; debugMsg(sProcName, "nReqdScrollAreaX=" + Str(nReqdScrollAreaX))
      SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X, nReqdScrollAreaX)
    ElseIf nLeft < nScrollAreaX
      ; wholly or partially to the left of the visible area
      nReqdScrollAreaX = nLeft
      ; debugMsg(sProcName, "nReqdScrollAreaX=" + Str(nReqdScrollAreaX))
      SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_X, nReqdScrollAreaX)
    Else
      ; debugMsg(sProcName, "no change")
    EndIf
  EndIf
  
  For n = 0 To gnWQALastItem
    If WQAFile(n)\bSelected
      gnWQACurrItem = n
      If WQAFile(n)\nFileAudPtr >= 0
        setEditAudPtr(WQAFile(n)\nFileAudPtr)
      EndIf
      Break
    EndIf
  Next n
  debugMsg(sProcName, "gnWQACurrItem=" + gnWQACurrItem + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  SAG(WQAFile(gnWQACurrItem)\cvsTimeLineImage)  ; added 29Sep2016 11.6.0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_multiItemValidate()
  PROCNAMECS(nEditSubPtr)
  Protected nHoldEditAudPtr
  Protected bFirstSelectedItem = #True
  Protected bValidationResult
  Protected nCueDuration
  Protected bDisplayPlayLength, bUpdateTotalTime
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", rWQA\nSelectedItemCount=" + Str(rWQA\nSelectedItemCount))
  
  With WQA
    
    If rWQA\nSelectedItemCount = 1
      ; single item selected
      If IsGadget(gnEventGadgetNoForEvHdlr)
        debugMsg(sProcName, "gnEventGadgetNoForEvHdlr=" + getGadgetName(gnEventGadgetNoForEvHdlr))
      Else
        debugMsg(sProcName, "gnEventGadgetNoForEvHdlr=G" + gnEventGadgetNoForEvHdlr)
      EndIf
      Select gnEventGadgetNoForEvHdlr
          
        Case \cboAspectRatioType  ; cboAspectRatioType
          bValidationResult = WQA_cboAspectRatioType_Click()
          
        Case \cboQATransType    ; cboQATransType
          bValidationResult = WQA_cboQATransType_Click(#False, bFirstSelectedItem)
          
        Case \txtDisplayTime  ; txtDisplayTime (image files only)
          debugMsg(sProcName, "calling WQA_txtDisplayTime_Validate(#False, " + strB(bFirstSelectedItem) + ")")
          bValidationResult = WQA_txtDisplayTime_Validate(#False, bFirstSelectedItem)
          
        Case \txtEndAt        ; txtEndAt (video files only)
          bValidationResult = WQA_txtEndAt_Validate(#False, bFirstSelectedItem)
          
        Case \txtQATransTime    ; txtQATransTime
          bValidationResult = WQA_txtQATransTime_Validate(#False, bFirstSelectedItem)
          
        Case \txtStartAt      ; txtStartAt (video files only)
          bValidationResult = WQA_txtStartAt_Validate(#False, bFirstSelectedItem)
          
      EndSelect
      
    Else
      ; multiple items selected
      nHoldEditAudPtr = nEditAudPtr
      For n = 0 To gnWQALastItem
        If WQAFile(n)\bSelected
          setEditAudPtr(WQAFile(n)\nFileAudPtr)
          Select gnEventGadgetNoForEvHdlr
              
              ; Case \cboAspectRatioType  ; cboAspectRatioType
              ; bValidationResult = WQA_cboAspectRatioType_Click(#True, bFirstSelectedItem)
              
            Case \cboQATransType  ; cboQATransType
              bValidationResult = WQA_cboQATransType_Click(#True, bFirstSelectedItem)
              
            Case \txtDisplayTime    ; txtDisplayTime (image files only)
              bValidationResult = WQA_txtDisplayTime_Validate(#True, bFirstSelectedItem, n)
              If bValidationResult = #True
                If bFirstSelectedItem
                  nCueDuration = aAud(nEditAudPtr)\nCueDuration
                Else
                  If nCueDuration <> aAud(nEditAudPtr)\nCueDuration
                    nCueDuration = grAudDef\nCueDuration
                  EndIf
                EndIf
                bUpdateTotalTime = #True
              EndIf
              
            Case \txtEndAt    ; txtEndAt (video files only)
              bValidationResult = WQA_txtEndAt_Validate(#True, bFirstSelectedItem, n)
              If bValidationResult = #True
                If bFirstSelectedItem
                  nCueDuration = aAud(nEditAudPtr)\nCueDuration
                Else
                  If nCueDuration <> aAud(nEditAudPtr)\nCueDuration
                    nCueDuration = grAudDef\nCueDuration
                  EndIf
                EndIf
                bDisplayPlayLength = #True
                bUpdateTotalTime = #True
              EndIf
              
            Case \txtQATransTime    ; txtQATransTime
              bValidationResult = WQA_txtQATransTime_Validate(#True, bFirstSelectedItem)
              bUpdateTotalTime = #True
              
            Case \txtStartAt    ; txtStartAt (video files only)
              bValidationResult = WQA_txtStartAt_Validate(#True, bFirstSelectedItem, n)
              If bValidationResult = #True
                If bFirstSelectedItem
                  nCueDuration = aAud(nEditAudPtr)\nCueDuration
                Else
                  If nCueDuration <> aAud(nEditAudPtr)\nCueDuration
                    nCueDuration = grAudDef\nCueDuration
                  EndIf
                EndIf
                bDisplayPlayLength = #True
                bUpdateTotalTime = #True
              EndIf
              
          EndSelect
          
          If bValidationResult = #False
            ; validation failed so do not 'validate' remaining selected items
            Break
          EndIf
          
          bFirstSelectedItem = #False
          
        EndIf
      Next n
      setEditAudPtr(nHoldEditAudPtr)
      setDerivedFieldsForSubAuds(nEditSubPtr)
      
      If bDisplayPlayLength
        SGT(WQA\txtPlayLength, timeToStringBWZ(nCueDuration))
        SLD_setMax(WQA\sldProgress[0], (nCueDuration-1))
      EndIf
      
      If bUpdateTotalTime
        WQA_doSubTotals()
      EndIf
      
    EndIf
    
    saveLastPicInfo(nEditAudPtr)
    
  EndWith
  ProcedureReturn bValidationResult
  
EndProcedure

Procedure WQA_SetTransportButtons()
  ; PROCNAMECS(nEditSubPtr)
  Protected nLastFile
  Protected bEnableFadeOut, bDoContinuous
  Protected n
  Protected nFirstSelectedItem, nLastSelectedItem, nSelectedItemCount
  Protected nAudPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  nFirstSelectedItem = -1
  nLastSelectedItem = -1
  nLastFile = -1
  For n = 0 To gnWQALastItem
    With WQAFile(n)
      If \bSelected
        nSelectedItemCount + 1
        If nFirstSelectedItem = -1
          nFirstSelectedItem = n
        EndIf
        nLastSelectedItem = n
      EndIf
      If \nFileAudPtr > 0
        nLastFile = n
      EndIf
    EndWith
  Next n
  
  With aSub(nEditSubPtr)
    If \nPLFadeOutTime > 0
      If Not (\nSubState = #SCS_CUE_PAUSED Or \nSubState = #SCS_CUE_FADING_OUT)
        bEnableFadeOut = #True
      EndIf
    EndIf
    
    If \bSubUseGaplessStream
      If nFirstSelectedItem > 0
        setEnabled(WQA\btnFirst, #True)
      Else
        setEnabled(WQA\btnFirst, #False)
      EndIf
      setEnabled(WQA\btnPrev, #False)
      setEnabled(WQA\btnLast, #False)
      setEnabled(WQA\btnNext, #False)
      
    Else  ; \bSubUseGaplessStream = #False
      If nFirstSelectedItem > 0
        setEnabled(WQA\btnFirst, #True)
        setEnabled(WQA\btnPrev, #True)
      Else
        setEnabled(WQA\btnFirst, #False)
        setEnabled(WQA\btnPrev, #False)
      EndIf
      
      If nLastSelectedItem < nLastFile
        setEnabled(WQA\btnLast, #True)
        setEnabled(WQA\btnNext, #True)
      Else
        setEnabled(WQA\btnLast, #False)
        setEnabled(WQA\btnNext, #False)
      EndIf
    EndIf
  EndWith
  
  nAudPtr = -1
  If nSelectedItemCount > 0
    nAudPtr = WQAFile(nFirstSelectedItem)\nFileAudPtr
  EndIf
  If nAudPtr >= 0
    With aAud(nAudPtr)
      Select \nFileFormat
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
          bDoContinuous = \bDoContinuous
      EndSelect
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(\nAudState) + ", \nFileState=" + decodeFileState(\nFileState))
      If (\nAudState <= #SCS_CUE_READY) Or (\nAudState >= #SCS_CUE_PL_READY)
        setVisible(WQA\btnPlay, #True)
        If \nVideoSource = #SCS_VID_SRC_CAPTURE
          If \sVideoCaptureLogicalDevice
            setEnabled(WQA\btnPlay, #True)
          Else
            setEnabled(WQA\btnPlay, #False)
          EndIf
        Else
          If \nFileState = #SCS_FILESTATE_OPEN
            If (\bAudUseGaplessStream = #False) Or (nFirstSelectedItem = 0)  ; nb with a gapless (crossfade) stream, playback can only start from the first file
              setEnabled(WQA\btnPlay, #True)
            Else
              setEnabled(WQA\btnPlay, #False)
            EndIf
          Else
            setEnabled(WQA\btnPlay, #False)
          EndIf
        EndIf
        setVisible(WQA\btnPause, #False)
        setEnabled(WQA\btnPause, #False)
        setEnabled(WQA\btnFadeOut, #False)
        setEnabled(WQA\btnStop, #False)
        setEnabled(WQA\cboVidAudLogicalDev, #True)
        
      Else
        If \nAudState = #SCS_CUE_PAUSED
          setVisible(WQA\btnPlay, #True)
          setEnabled(WQA\btnPlay, #True)
          setVisible(WQA\btnPause, #False)
          setEnabled(WQA\btnPause, #False)
        Else
          setVisible(WQA\btnPlay, #False)
          setEnabled(WQA\btnPlay, #False)
          setVisible(WQA\btnPause, #True)
          If bDoContinuous = #False
            setEnabled(WQA\btnPause, #True)
          Else
            setEnabled(WQA\btnPause, #False)
          EndIf
        EndIf
        setEnabled(WQA\btnFadeOut, bEnableFadeOut)
        setEnabled(WQA\btnStop, #True)
        setEnabled(WQA\cboVidAudLogicalDev, #False)
        
      EndIf
    EndWith
    
  Else  ; nEditAudPtr < 0 (ie currently selected item is blank)
    setVisible(WQA\btnPlay, #True)
    setEnabled(WQA\btnPlay, #False)
    setVisible(WQA\btnPause, #False)
    setEnabled(WQA\btnPause, #False)
    setEnabled(WQA\btnFadeOut, #False)
    setEnabled(WQA\btnStop, #False)
    
  EndIf
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure WQA_txtFadeInTime_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeField(GGT(WQA\txtFadeInTime), GGT(WQA\lblFadeInTime), #False, #False) = #False
    ProcedureReturn #False
  ElseIf GGT(WQA\txtFadeInTime) <> gsTmpString
    SGT(WQA\txtFadeInTime, gsTmpString)
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nPLFadeInTime, GGT(WQA\lblFadeInTime))
    \nPLFadeInTime = stringToTime(GGT(WQA\txtFadeInTime))
    \nPLCurrFadeInTime = \nPLFadeInTime
    setPLFades(nEditSubPtr)
    postChangeSubLN(u, \nPLFadeInTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQA_txtFadeOutTime_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If validateTimeField(GGT(WQA\txtFadeOutTime), GGT(WQA\lblFadeOutTime), #False, #False) = #False
    ProcedureReturn #False
  ElseIf GGT(WQA\txtFadeOutTime) <> gsTmpString
    SGT(WQA\txtFadeOutTime, gsTmpString)
  EndIf
  
  With aSub(nEditSubPtr)
    u = preChangeSubL(\nPLFadeOutTime, GGT(WQA\lblFadeOutTime))
    \nPLFadeOutTime = stringToTime(GGT(WQA\txtFadeOutTime))
    \nPLCurrFadeOutTime = \nPLFadeOutTime
    setPLFades(nEditSubPtr)
    debugMsg(sProcName, "\nPLCurrFadeInTime=" + Str(\nPLCurrFadeInTime) + ", \nPLCurrFadeOutTime=" + Str(\nPLCurrFadeOutTime))
    postChangeSubLN(u, \nPLFadeOutTime)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
EndProcedure

Procedure WQA_fcFileFormat(bMultipleFileTypes=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nFileFormat, nImageFrameCount, bEnableItems, bDefaults
  
  nFileFormat = #SCS_FILEFORMAT_UNKNOWN
  If (nEditAudPtr >= 0) And (bMultipleFileTypes = #False)
    nFileFormat = aAud(nEditAudPtr)\nFileFormat
    If nFileFormat = #SCS_FILEFORMAT_PICTURE
      nImageFrameCount = aAud(nEditAudPtr)\nImageFrameCount
    EndIf
  EndIf
  debugMsg(sProcName, "nFileFormat=" + decodeFileFormat(nFileFormat) + ", nImageFrameCount=" + nImageFrameCount)
  If nImageFrameCount > 1
    bEnableItems = #False
    bDefaults = #True
  Else
    bEnableItems = #True
    bDefaults = #False
  EndIf
  
  ; Note that WQA\cntImageOnlyFields is a container WITHIN WQA\cntImageAndCaptureFields, so WQA\cntImageOnlyFields only needs to be set visible or not if
  ; the parent container WQA\cntImageAndCaptureFields is visible.
  
  With WQA
    SLD_setEnabled(\sldYPos, bEnableItems)
  EndWith
  
  Select nFileFormat
    Case #SCS_FILEFORMAT_VIDEO
      setVisible(WQA\cntImageAndCaptureFields, #False)
      setVisible(WQA\cntVideoFields, #True)
      
    Case #SCS_FILEFORMAT_PICTURE
      setVisible(WQA\cntVideoFields, #False)
      setVisible(WQA\cntImageAndCaptureFields, #True)
      setVisible(WQA\cntImageOnlyFields, #True)
      
    Case #SCS_FILEFORMAT_CAPTURE
      setVisible(WQA\cntVideoFields, #False)
      setVisible(WQA\cntImageAndCaptureFields, #True)
      setVisible(WQA\cntImageOnlyFields, #False)
      
    Default
      setVisible(WQA\cntVideoFields, #False)
      setVisible(WQA\cntImageAndCaptureFields, #False)
      
  EndSelect
  
EndProcedure

Procedure WQA_updateCommonImageNo(nOldImageNo, nNewImageNo)
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nOldImageNo=" + nOldImageNo + ", nNewImageNo=" + nNewImageNo)
  
  With WQA
    Select nOldImageNo
      Case \imgPreview
        \imgPreview = nNewImageNo
        ; debugMsg(sProcName, "WQA\imgPreview=" + WQA\imgPreview)
        
    EndSelect
  EndWith
EndProcedure

Procedure WQA_clearCurrentInfo()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WQA
    ; clear preview panel
    If IsGadget(\cvsPreview)
      If StartDrawing(CanvasOutput(\cvsPreview))
        debugMsgV(sProcName, "StartDrawing(CanvasOutput(\cvsPreview))")
        Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
        debugMsgV(sProcName, "Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)")
        StopDrawing()
      EndIf
    EndIf
    If IsImage(\imgPreview)
      If StartDrawing(ImageOutput(\imgPreview))
        Box(0,0,ImageWidth(\imgPreview),ImageHeight(\imgPreview),#SCS_Black)
        StopDrawing()
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WQA_setPreviewPanel(pSubPtr)
  PROCNAMEC()
  Protected nCntPreviewWidth, nCntPreviewHeight, fCntPreviewAspectRatio.f
  Protected nOutputScreen, nOutputWindowNo, fOutputWindowAspectRatio.f
  Protected nReqdCvsLeft, nReqdCvsTop, nReqdCvsWidth, nReqdCvsHeight
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    nOutputScreen = aSub(pSubPtr)\nOutputScreen
  Else
    nOutputScreen = 0
  EndIf
  
  With WQA
    nCntPreviewWidth = GadgetWidth(\cntPreview)
    nCntPreviewHeight = GadgetHeight(\cntPreview)
    fCntPreviewAspectRatio = nCntPreviewWidth / nCntPreviewHeight
    If nOutputScreen = 0
      nReqdCvsLeft = 0
      nReqdCvsTop = 0
      nReqdCvsWidth = nCntPreviewWidth
      nReqdCvsHeight = nCntPreviewHeight
    Else
      nOutputWindowNo = #WV2 + (nOutputScreen - 2)
      If IsWindow(nOutputWindowNo)
        fOutputWindowAspectRatio = WindowWidth(nOutputWindowNo) / WindowHeight(nOutputWindowNo)
        debugMsg(sProcName, "WindowWidth(nOutputWindowNo)=" + WindowWidth(nOutputWindowNo) + ", WindowHeight(nOutputWindowNo)=" + WindowHeight(nOutputWindowNo) + ", fOutputWindowAspectRatio=" + StrF(fOutputWindowAspectRatio,4))
        debugMsg(sProcName, "nCntPreviewWidth=" + nCntPreviewWidth + ", nCntPreviewHeight=" + nCntPreviewHeight + ", fCntPreviewAspectRatio=" + StrF(fCntPreviewAspectRatio,4))
        If fOutputWindowAspectRatio = fCntPreviewAspectRatio And 1=2
          nReqdCvsWidth = nCntPreviewWidth
          nReqdCvsHeight = nCntPreviewHeight
        ElseIf fOutputWindowAspectRatio < fCntPreviewAspectRatio
          ; eg window is 1280x1024, ie relatively narrower than the preview container
          nReqdCvsHeight = nCntPreviewHeight
          nReqdCvsWidth = nReqdCvsHeight * fOutputWindowAspectRatio
        Else
          nReqdCvsWidth = nCntPreviewWidth
          nReqdCvsHeight = nReqdCvsWidth / fOutputWindowAspectRatio
        EndIf
        nReqdCvsLeft = (nCntPreviewWidth - nReqdCvsWidth) / 2
        nReqdCvsTop = (nCntPreviewHeight - nReqdCvsHeight) / 2
      EndIf
    EndIf
    If nReqdCvsWidth > 0
      If GadgetX(\cvsPreview) <> nReqdCvsLeft Or GadgetY(\cvsPreview) <> nReqdCvsTop Or GadgetWidth(\cvsPreview) <> nReqdCvsWidth Or GadgetHeight(\cvsPreview) <> nReqdCvsHeight
        ResizeGadget(\cvsPreview, nReqdCvsLeft, nReqdCvsTop, nReqdCvsWidth, nReqdCvsHeight)
        ; debugMsg3(sProcName, "ResizeGadget(WQA\cvsPreview, " + nReqdCvsLeft + ", " + nReqdCvsTop + ", " + nReqdCvsWidth + ", " + nReqdCvsHeight + ")")
        grVidPicTarget(#SCS_VID_PIC_TARGET_P)\nTargetWidth = nReqdCvsWidth
        grVidPicTarget(#SCS_VID_PIC_TARGET_P)\nTargetHeight = nReqdCvsHeight
        If nEditAudPtr >= 0
          If aAud(nEditAudPtr)\bAudTypeA
            condFreeImage(aAud(nEditAudPtr)\nVidPicTargetImageNo(#SCS_VID_PIC_TARGET_P))
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_setPosAndSize2(nPosSizeAdjustments=#SCS_PS_ALL, bTrace=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nVidPicTarget, nTVGIndex, nHandle.i
  Protected nItem
  Protected bPlaying
  
  debugMsgC(sProcName, #SCS_START)
  
  If gbInDisplaySub
    debugMsgC(sProcName, "exiting because gbInDisplaySub=" + strB(gbInDisplaySub))
    ProcedureReturn
  EndIf
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      If \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT
        bPlaying = #True
      EndIf
      nVidPicTarget = #SCS_VID_PIC_TARGET_P
      Select \nFileFormat
        Case #SCS_FILEFORMAT_VIDEO
          If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
            CompilerIf #c_vMix_in_video_cues
              vMix_SetXYPosAndSize(nEditAudPtr, nPosSizeAdjustments)
            CompilerEndIf
          Else
            If bPlaying = #False
              clearVideoImage(nVidPicTarget)
              debugMsgC(sProcName, "calling showMyVideoFrame(" + getAudLabel(nEditAudPtr) + ", " + Str(\nCuePos + \nAbsStartAt) + ")")
              showMyVideoFrame(nEditAudPtr, (\nCuePos + \nAbsStartAt))
            Else
              adjustVideoPosAndSize3(nEditAudPtr, nVidPicTarget, bTrace)
            EndIf
          EndIf
          nItem = WQA_getItemForAud(nEditAudPtr)
          If nItem >= 0
            WQA_drawTimeLineImage2(nItem, bTrace)
          EndIf
          
        Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_CAPTURE
          If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
            CompilerIf #c_vMix_in_video_cues
              vMix_SetXYPosAndSize(nEditAudPtr, nPosSizeAdjustments)
            CompilerEndIf
          Else
            WQA_drawPreviewImage2()
          EndIf
          nItem = WQA_getItemForAud(nEditAudPtr)
          If nItem >= 0
            WQA_drawTimeLineImage2(nItem, bTrace)
          EndIf
          
      EndSelect
      
      ; Added 11Jun2020 11.8.3.2aa
      nTVGIndex = getTVGIndexForAud(nEditAudPtr, nVidPicTarget)
      If nTVGIndex >= 0
        nHandle = *gmVideoGrabber(nTVGIndex)
        If nHandle <> 0
          setTVGCaptureSize(nEditAudPtr, nHandle, nVidPicTarget)
          setTVGCroppingData(nEditAudPtr, nTVGIndex, #True, bTrace)
        EndIf
      EndIf
      ; End added 11Jun2020 11.8.3.2aa
      
    EndWith
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_sldXPos_Common()
  ; PROCNAMECA(nEditAudPtr)
  Protected u
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    If \nXPos <> SLD_getValue(WQA\sldXPos)
      u = preChangeAudL(\nXPos, GGT(WQA\lblXPos))
      \nXPos = SLD_getValue(WQA\sldXPos)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nXPos=" + aAud(nEditAudPtr)\nXPos)
      WQA_displayPosAndSizeTextFields()
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nXPos)
      WQA_setPosAndSize2(#SCS_PS_XPOS, #False)
    EndIf
  EndWith

EndProcedure

Procedure WQA_txtXPos_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected bXPosValid, sMsg.s
  Protected nFileDataPtr, nSourceWidth, nSourceHeight
  Protected sNewXPosDisplay.s, nNewXPosDisplay, nNewXPos
  Protected nMinXPosDisplay, nMaxXPosDisplay
  
  ; see also WQA_displayPosAndSizeTextFields(), especially the comments at the start of that procedure
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nFileFormat=" + decodeFileFormat(\nFileFormat) + ", \nFileDataPtr=" + \nFileDataPtr + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
    Select \nVideoSource
      Case #SCS_VID_SRC_FILE
        nFileDataPtr = \nFileDataPtr
        If nFileDataPtr >= 0
          nSourceWidth = gaFileData(nFileDataPtr)\nSourceWidth
          nSourceHeight = gaFileData(nFileDataPtr)\nSourceHeight
        EndIf
      Case #SCS_VID_SRC_CAPTURE
        debugMsg(sProcName, "\nAudVidPicTarget=" + decodeVidPicTarget(\nAudVidPicTarget) + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight + ", \sVideoCaptureLogicalDevice=" + \sVideoCaptureLogicalDevice)
        nSourceWidth = \nSourceWidth
        nSourceHeight = \nSourceHeight
    EndSelect
    If \nFileFormat = #SCS_FILEFORMAT_PICTURE
      Select \nRotate
        Case 90, 270
          Swap nSourceWidth, nSourceHeight
      EndSelect
    EndIf
    nMinXPosDisplay = 0 - nSourceWidth
    nMaxXPosDisplay = nSourceWidth
    debugMsg(sProcName, "nSourceWidth=" + nSourceWidth)
    
    sNewXPosDisplay = Trim(GGT(WQA\txtXPos))
    If sNewXPosDisplay
      If IsInteger(sNewXPosDisplay)
        nNewXPos = Val(sNewXPosDisplay)
        If (nNewXPos >= nMinXPosDisplay) And (nNewXPos <= nMaxXPosDisplay)
          bXPosValid = #True
        EndIf
      EndIf
      If bXPosValid = #False
        ensureSplashNotOnTop()
        sMsg = LangPars("Errors", "MustBeBetween", GGT(WQA\lblXPos), Str(nMinXPosDisplay), Str(nMaxXPosDisplay))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      nNewXPos = 5000 * nNewXPos / nSourceWidth
    Else
      ; user blanked out the 'xPos' field, so use default xPos (0)
      nNewXPos = grAudDef\nXPos
    EndIf
    
    debugMsg(sProcName, "\nXPos=" + \nXPos + ", sNewXPosDisplay=" + sNewXPosDisplay + ", nNewXPos=" + nNewXPos)
    If \nXPos <> nNewXPos
      u = preChangeAudL(\nXPos, GGT(WQA\lblXPos))
      \nXPos = nNewXPos
      SLD_setValue(WQA\sldXPos, \nXPos)
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nXPos)
      WQA_setPosAndSize2(#SCS_PS_XPOS)
    EndIf
    WQA_displayPosAndSizeTextFields()
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQA_sldYPos_Common()
  ; PROCNAMECA(nEditAudPtr)
  Protected u
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    If \nYPos <> SLD_getValue(WQA\sldYPos)
      u = preChangeAudL(\nYPos, GGT(WQA\lblYPos))
      \nYPos = SLD_getValue(WQA\sldYPos)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nYPos=" + aAud(nEditAudPtr)\nYPos)
      WQA_displayPosAndSizeTextFields()
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nYPos)
      WQA_setPosAndSize2(#SCS_PS_YPOS, #False)
    EndIf
  EndWith
EndProcedure

Procedure WQA_txtYPos_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected bYPosValid, sMsg.s
  Protected nFileDataPtr, nSourceWidth, nSourceHeight
  Protected sNewYPosDisplay.s, nNewYPosDisplay, nNewYPos
  Protected nMinYPosDisplay, nMaxYPosDisplay
  
  ; see also WQA_displayPosAndSizeTextFields(), especially the comments at the start of that procedure
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    Select \nVideoSource
      Case #SCS_VID_SRC_FILE
        nFileDataPtr = \nFileDataPtr
        If nFileDataPtr >= 0
          nSourceWidth = gaFileData(nFileDataPtr)\nSourceWidth
          nSourceHeight = gaFileData(nFileDataPtr)\nSourceHeight
        EndIf
      Case #SCS_VID_SRC_CAPTURE
        debugMsg(sProcName, "\nAudVidPicTarget=" + decodeVidPicTarget(\nAudVidPicTarget) + ", \nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight + ", \sVideoCaptureLogicalDevice=" + \sVideoCaptureLogicalDevice)
        nSourceWidth = \nSourceWidth
        nSourceHeight = \nSourceHeight
    EndSelect
    If \nFileFormat = #SCS_FILEFORMAT_PICTURE
      Select \nRotate
        Case 90, 270
          Swap nSourceWidth, nSourceHeight
      EndSelect
    EndIf
    nMinYPosDisplay = 0 - nSourceHeight
    nMaxYPosDisplay = nSourceHeight
    debugMsg(sProcName, "nSourceHeight=" + nSourceHeight)
    
    sNewYPosDisplay = Trim(GGT(WQA\txtYPos))
    If sNewYPosDisplay
      If IsInteger(sNewYPosDisplay)
        nNewYPos = Val(sNewYPosDisplay)
        If (nNewYPos >= nMinYPosDisplay) And (nNewYPos <= nMaxYPosDisplay)
          bYPosValid = #True
        EndIf
      EndIf
      If bYPosValid = #False
        ensureSplashNotOnTop()
        sMsg = LangPars("Errors", "MustBeBetween", GGT(WQA\lblYPos), Str(nMinYPosDisplay), Str(nMaxYPosDisplay))
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      nNewYPos = 5000 * nNewYPos / nSourceHeight
    Else
      ; user blanked out the 'YPos' field, so use default YPos (0)
      nNewYPos = grAudDef\nYPos
    EndIf
    
    debugMsg(sProcName, "\nYPos=" + \nYPos + ", sNewYPosDisplay=" + sNewYPosDisplay + ", nNewYPos=" + nNewYPos)
    If \nYPos <> nNewYPos
      u = preChangeAudL(\nYPos, GGT(WQA\lblYPos))
      \nYPos = nNewYPos
      SLD_setValue(WQA\sldYPos, \nYPos)
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nYPos)
      WQA_setPosAndSize2(#SCS_PS_YPOS)
    EndIf
    WQA_displayPosAndSizeTextFields()
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQA_sldSize_Common()
  ; PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nNewSize
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    nNewSize = SLD_getValue(WQA\sldSize)
    ; debugMsg(sProcName, "\nSize=" + \nSize + ", nNewSize=" + nNewSize)
    If \nSize <> nNewSize
      u = preChangeAudL(\nSize, GGT(WQA\lblSize))
      \nSize = nNewSize
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nSize=" + aAud(nEditAudPtr)\nSize)
      WQA_displayPosAndSizeTextFields()
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nSize)
      WQA_setPosAndSize2(#SCS_PS_SIZE, #False)
    EndIf
  EndWith
  
EndProcedure

Procedure WQA_txtSize_Validate()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected bSizeValid, sMsg.s
  Protected sNewSize.s, fNewSize.f, nNewSize
  Static fMinSize.f, fMaxSize.f
  Static bStaticLoaded
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    fMinSize = ((0 - SLD_getMin(WQA\sldSize)) / 5) + 100
    fMaxSize = ((0 - SLD_getMax(WQA\sldSize)) / 5) + 100
    If fMinSize > fMaxSize
      Swap fMinSize, fMaxSize
    EndIf
    debugMsg(sProcName, "fMinSize=" + StrF(fMinSize,1) + ", fMaxSize=" + StrF(fMaxSize,1))
    bStaticLoaded = #True
  EndIf
  
  With aAud(nEditAudPtr)
    sNewSize = Trim(RemoveString(GGT(WQA\txtSize), "%"))
    If sNewSize
      If IsNumeric(sNewSize)
        fNewSize = ValF(sNewSize)
        If (fNewSize >= fMinSize) And (fNewSize <= fMaxSize)
          bSizeValid = #True
        EndIf
      EndIf
      If bSizeValid = #False
        ensureSplashNotOnTop()
        sMsg = LangPars("Errors", "MustBeBetween", GGT(WQA\lblSize), StrF(fMinSize,0)+"%", StrF(fMaxSize,0)+"%")
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
        ProcedureReturn #False
      EndIf
      ; convert display size (percentage, 0% to 200%) to internal value (-500 to +500)
      nNewSize = (fNewSize - 100) * -5
    Else
      ; user blanked out the 'size' field, so use default size (100%)
      nNewSize = grAudDef\nSize
    EndIf
    debugMsg(sProcName, "\nSize=" + \nSize + ", sNewSize=" + sNewSize + ", fNewSize=" + StrF(fNewSize,1) + ", nNewSize=" + nNewSize)
    If \nSize <> nNewSize
      u = preChangeAudL(\nSize, GGT(WQA\lblSize))
      \nSize = nNewSize
      SLD_setValue(WQA\sldSize, \nSize)
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, \nSize)
      WQA_setPosAndSize2(#SCS_PS_SIZE)
    EndIf
    WQA_displayPosAndSizeTextFields()
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure WQA_sldAspectRatio_Common()
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nNewAspectRatioType, nNewAspectRatioHVal
  
  If nEditAudPtr < 0
    ; can occur on the 'blank' entry
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    nNewAspectRatioType = getCurrentItemData(WQA\cboAspectRatioType, #SCS_ART_ORIGINAL)
    nNewAspectRatioHVal = SLD_getValue(WQA\sldAspectRatioHVal)
    debugMsg3(sProcName, "\nAspectRatioType=" + \nAspectRatioType + ", nNewAspectRatioType=" + nNewAspectRatioType)
    debugMsg3(sProcName, "\nAspectRatioHVal=" + \nAspectRatioHVal + ", nNewAspectRatioHVal=" + nNewAspectRatioHVal)
    If (\nAspectRatioType <> nNewAspectRatioType) Or (\nAspectRatioHVal <> nNewAspectRatioHVal)
      u = preChangeAudL(#True, GGT(WQA\lblAspectRatioType))
      \nAspectRatioType = nNewAspectRatioType
      \nAspectRatioHVal = nNewAspectRatioHVal
      \bReloadMainImage = #True
      \bReOpenVidFile = #True
      WQA_SizeOrPosChanged()
      postChangeAudLN(u, #False)
      WQA_setPosAndSize2()
    EndIf
    debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bReOpenVidFile=" + strB(\bReOpenVidFile))
  EndWith
EndProcedure

Procedure WQA_clearPreviewOnOutputScreen(nOutputScreen)
  PROCNAMEC()
  Protected nVidPicTarget
  Protected nCanvasNo
  
  debugMsg(sProcName, #SCS_START + ", nOutputScreen=" + Str(nOutputScreen))
  
  If nOutputScreen >= 2
    nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreen)
    debugMsg(sProcName, "nVidPicTarget=" + decodeVidPicTarget(nVidPicTarget))
    Select nVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTargetCanvasNo=" + getGadgetName(grVidPicTarget(nVidPicTarget)\nTargetCanvasNo))
        nCanvasNo = grVidPicTarget(nVidPicTarget)\nTargetCanvasNo
        If IsGadget(nCanvasNo)
          If StartDrawing(CanvasOutput(nCanvasNo))
            debugMsgV(sProcName, "StartDrawing(CanvasOutput(" + getGadgetName(nCanvasNo) + "))")
            Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)
            debugMsgV(sProcName, "Box(0,0,OutputWidth(),OutputHeight(),#SCS_Black)")
            StopDrawing()
          EndIf
        EndIf
    EndSelect
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_cvsPreviewOrVideoEvent(nCanvasNo, nEventType, nXPos, nYPos)
  PROCNAMECA(nEditAudPtr)
  Protected u
  Protected nChangeInX, nChangeInY
  Protected nNewXPos, nNewYPos, nNewSize
  Protected nXPosChange, nYPosChange, nSizeChange
  Protected nXSliderRange, nYSliderRange
  Protected bCallSetPosAndSize
  Protected nWheelDelta
  Protected nCanvasKey, nXIncrement, nYIncrement, nSizeIncrement
  Protected bXChange, bYChange, bSizeChange
  Protected sInputChar.s
  
  If IsGadget(nCanvasNo) = #False
    ProcedureReturn
  EndIf
  
  ; debugMsg0(sProcName, "nCanvasNo=" + getGadgetName(nCanvasNo) + ", nEventType=" + decodeEventType(nCanvasNo) +
  ;                      ", GadgetX(" + getGadgetName(nCanvasNo,#False) + ")=" + GadgetX(nCanvasNo) + ", GadgetY(" + getGadgetName(nCanvasNo,#False) + ")=" + GadgetY(nCanvasNo) +
  ;                      ", WindowX(#WED)=" + WindowX(#WED) + ", WindowY(#WED)=" + WindowY(#WED) +
  ;                      ", GadgetX(WED\cntRight)=" + GadgetX(WED\cntRight) + ", GadgetY(WED\cntRight)=" + GadgetY(WED\cntRight) +
  ;                      ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()) +
  ;                      ", getVisible(WQA\cvsPreview)=" + getVisible(WQA\cvsPreview)) ; + ", getVisible(WQA\cvsVideo)=" + getVisible(WQA\cvsVideo))
  
  If getVisible(nCanvasNo) = #False
    setVisible(nCanvasNo, #True)
  EndIf
  
  If (nEditAudPtr >= 0) ; And (GetActiveGadget() = WQA\cvsPreview Or GetActiveGadget() = WQA\cvsVideo)
    ; added "And (GetActiveGadget() = WQA\cvsPreview)" 9Sep2016 11.5.2 because an error message dialog displayed over the canvas would cause canvas events on closing the dialog
    ; (eg mouse enter, focus, etc) even though the program immediately set the active gadget back to the field in error that caused the message to be displayed.
    ; on testing, found that in these circumstances, GetActiveGadget() pointed to the field in error, not to this canvas.
    ; GetActiveGadget() always seems to point to WQA\cvsPreview for actions that DO need to be processed here.
    
    ;     debugMsg(sProcName, "gnEventType=" + decodeEventType(WQA\cvsPreview) + ", gnFocusGadgetNo=" + getGadgetName(gnFocusGadgetNo) +
    ;                         ", GetActiveGadget()=" + getGadgetName(GetActiveGadget()) + ", GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
    ; nCanvasNo = gnEventGadgetNo
    ; debugMsg(sProcName, "nCanvasNo=" + getGadgetName(nCanvasNo))
    
    If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE And aAud(nEditAudPtr)\nImageFrameCount > 1
      ; if an animated GIF then repositioning, etc, not supported
      ProcedureReturn
    EndIf
    
    With rWQA
      Select nEventType
        Case #PB_EventType_MouseEnter ; #PB_EventType_MouseEnter
          If (\bMouseDownOnCanvasProcessed) And (isLeftMouseButtonDown())
            \bMouseDownOnCanvas = #True
            SetGadgetAttribute(nCanvasNo, #PB_Canvas_CustomCursor, hCursorGrabbing)
          Else
            \bMouseDownOnCanvas = #False
            SetGadgetAttribute(nCanvasNo, #PB_Canvas_CustomCursor, hCursorGrab)
          EndIf
          ; make sure the preview panel (ie this canvas) has focus because the MouseWheel event only fires if the canvas has focus
          SetActiveGadget(nCanvasNo)
          
        Case #PB_EventType_MouseLeave ; #PB_EventType_MouseLeave
          SetGadgetAttribute(nCanvasNo, #PB_Canvas_Cursor, #PB_Cursor_Default)
          ; move focus away from the preview panel (ie this canvas) to prevent MouseWheel events firing when the cursor is not in the canvas
          SAG(WQA\cvsDummy)
          
        Case #PB_EventType_LeftButtonDown ; #PB_EventType_LeftButtonDown
          ; debugMsg0(sProcName, "#PB_EventType_LeftButtonDown")
          If GetActiveGadget() = -1
            debugMsg0(sProcName, "calling SAG(" + getGadgetName(nCanvasNo) + ")")
            SAG(nCanvasNo)
          EndIf
          \nMouseDownAudXPos = aAud(nEditAudPtr)\nXPos
          \nMouseDownAudYPos = aAud(nEditAudPtr)\nYPos
          \nMouseDownStartX = nXPos ; GetGadgetAttribute(nCanvasNo, #PB_Canvas_MouseX)
          \nMouseDownStartY = nYPos ; GetGadgetAttribute(nCanvasNo, #PB_Canvas_MouseY)
          nXSliderRange = SLD_getMax(WQA\sldXPos) - SLD_getMin(WQA\sldXPos)
          nYSliderRange = SLD_getMax(WQA\sldYPos) - SLD_getMin(WQA\sldYPos)
          \fMouseDownXFactor = (nXSliderRange / 2.0) / GadgetWidth(nCanvasNo)
          \fMouseDownYFactor = (nYSliderRange / 2.0) / GadgetHeight(nCanvasNo)
          \bMouseDownOnCanvas = #True
          \bMouseDownOnCanvasProcessed = #True
          SetGadgetAttribute(nCanvasNo, #PB_Canvas_CustomCursor, hCursorGrabbing)
          
        Case #PB_EventType_MouseMove  ; #PB_EventType_MouseMove
          ; debugMsg0(sProcName, "#PB_EventType_MouseMove, WQA\bMouseDownOnCanvas=" + strB(\bMouseDownOnCanvas))
          If GetActiveGadget() = -1
            debugMsg0(sProcName, "calling SAG(" + getGadgetName(nCanvasNo) + ")")
            SAG(nCanvasNo)
          EndIf
          If \bMouseDownOnCanvas
            nChangeInX = nXPos - \nMouseDownStartX ; GetGadgetAttribute(nCanvasNo, #PB_Canvas_MouseX) - \nMouseDownStartX
            nChangeInY = nYPos - \nMouseDownStartY ; GetGadgetAttribute(nCanvasNo, #PB_Canvas_MouseY) - \nMouseDownStartY
            nXPosChange = nChangeInX * \fMouseDownXFactor
            nYPosChange = nChangeInY * \fMouseDownYFactor
            nNewXPos = \nMouseDownAudXPos + nXPosChange
            nNewYPos = \nMouseDownAudYPos + nYPosChange
            If nNewXPos < SLD_getMin(WQA\sldXPos)
              nNewXPos = SLD_getMin(WQA\sldXPos)
            EndIf
            If nNewXPos > SLD_getMax(WQA\sldXPos)
              nNewXPos = SLD_getMax(WQA\sldXPos)
            EndIf
            aAud(nEditAudPtr)\nXPos = nNewXPos
            If nNewYPos < SLD_getMin(WQA\sldYPos)
              nNewYPos = SLD_getMin(WQA\sldYPos)
            EndIf
            If nNewYPos > SLD_getMax(WQA\sldYPos)
              nNewYPos = SLD_getMax(WQA\sldYPos)
            EndIf
            aAud(nEditAudPtr)\nYPos = nNewYPos
            ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nXPos=" + aAud(nEditAudPtr)\nXPos + ", \nYPos=" + aAud(nEditAudPtr)\nYPos)
            If SLD_getValue(WQA\sldXPos) <> nNewXPos
              SLD_setValue(WQA\sldXPos, nNewXPos)
              bCallSetPosAndSize = #True
            EndIf
            If SLD_getValue(WQA\sldYPos) <> nNewYPos
              SLD_setValue(WQA\sldYPos, nNewYPos)
              bCallSetPosAndSize = #True
            EndIf
            If bCallSetPosAndSize
              WQA_displayPosAndSizeTextFields()
              WQA_setPosAndSize2(#SCS_PS_XPOS | #SCS_PS_YPOS, #False)
            EndIf
            SetActiveGadget(nCanvasNo) ; Added 10Oct2024 11.10.6ak - seems to be necessary for video files
          EndIf
          
        Case #PB_EventType_LeftButtonUp ; #PB_EventType_LeftButtonUp
          ; debugMsg0(sProcName, "#PB_EventType_LeftButtonUp")
          If GetActiveGadget() = -1
            debugMsg0(sProcName, "calling SAG(" + getGadgetName(nCanvasNo) + ")")
            SAG(nCanvasNo)
          EndIf
          If \bMouseDownOnCanvas
            If (aAud(nEditAudPtr)\nXPos <> \nMouseDownAudXPos) Or (aAud(nEditAudPtr)\nYPos <> \nMouseDownAudYPos)
              ; need to reinstate the initial \nXPos and \nYPos before calling preChangeAudL(), and then set the latest values again
              nNewXPos = aAud(nEditAudPtr)\nXPos              ; hold the latest \nXPos
              nNewYPos = aAud(nEditAudPtr)\nYPos              ; and \nYPos
              aAud(nEditAudPtr)\nXPos = \nMouseDownAudXPos    ; reinstate the \nXPos as at the MouseDown event, ie at the start of this grab
              aAud(nEditAudPtr)\nYPos = \nMouseDownAudYPos    ; ditto for \nYPos
              u = preChangeAudL(#True, Lang("WQA", "XYPos"))  ; preChangeAudL()
              aAud(nEditAudPtr)\nXPos = nNewXPos              ; reload the saved latest \nXPos
              aAud(nEditAudPtr)\nYPos = nNewYPos              ; and \nYPos
              debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nXPos=" + aAud(nEditAudPtr)\nXPos + ", \nYPos=" + aAud(nEditAudPtr)\nYPos)
              WQA_SizeOrPosChanged()
              postChangeAudLN(u, #False)                       ; postChangeAudL()
            EndIf
            \bMouseDownOnCanvas = #False
          EndIf
          SetGadgetAttribute(nCanvasNo, #PB_Canvas_CustomCursor, hCursorGrab)
          debugMsg(sProcName, "#PB_EventType_LeftButtonUp end")
          
        Case #PB_EventType_KeyDown  ; #PB_EventType_KeyDown
          nCanvasKey = GetGadgetAttribute(nCanvasNo, #PB_Canvas_Key)
          If ShiftKeyDown()
            nXIncrement = \fXPosIncrementS
            nYIncrement = \fYPosIncrementS
          Else
            nXIncrement = \fXPosIncrementL
            nYIncrement = \fYPosIncrementL
          EndIf
          If nXIncrement = 0
            nXIncrement = 1
          EndIf
          If nYIncrement = 0
            nYIncrement = 1
          EndIf
          ; debugMsg(sProcName, "nXIncrement=" + Str(nXIncrement) + ", nYIncrement=" + Str(nYIncrement))
          nNewXPos = aAud(nEditAudPtr)\nXPos
          nNewYPos = aAud(nEditAudPtr)\nYPos
          Select nCanvasKey
            Case #PB_Shortcut_Left
              nNewXPos - nXIncrement
              bXChange = #True
            Case #PB_Shortcut_Right
              nNewXPos + nXIncrement
              bXChange = #True
            Case #PB_Shortcut_Up
              nNewYPos - nYIncrement
              bYChange = #True
            Case #PB_Shortcut_Down
              nNewYPos + nYIncrement
              bYChange = #True
          EndSelect
          ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nXPos=" + Str(aAud(nEditAudPtr)\nXPos) + ", nNewXPos=" + Str(nNewXPos))
          If bXChange
            If nNewXPos < SLD_getMin(WQA\sldXPos)
              nNewXPos = SLD_getMin(WQA\sldXPos)
            EndIf
            If nNewXPos > SLD_getMax(WQA\sldXPos)
              nNewXPos = SLD_getMax(WQA\sldXPos)
            EndIf
            If SLD_getValue(WQA\sldXPos) <> nNewXPos
              SLD_setValue(WQA\sldXPos, nNewXPos)
              WQA_displayPosAndSizeTextFields()
              WQA_sldXPos_Common()
            EndIf
          EndIf
          If bYChange
            If nNewYPos < SLD_getMin(WQA\sldYPos)
              nNewYPos = SLD_getMin(WQA\sldYPos)
            EndIf
            If nNewYPos > SLD_getMax(WQA\sldYPos)
              nNewYPos = SLD_getMax(WQA\sldYPos)
            EndIf
            If SLD_getValue(WQA\sldYPos) <> nNewYPos
              SLD_setValue(WQA\sldYPos, nNewYPos)
              WQA_displayPosAndSizeTextFields()
              WQA_sldYPos_Common()
            EndIf
          EndIf
          
        Case #PB_EventType_Input  ; #PB_EventType_Input
          sInputChar = Chr(GetGadgetAttribute(nCanvasNo, #PB_Canvas_Input))
          If ShiftKeyDown()
            nSizeIncrement = \fSizeIncrementS
          Else
            nSizeIncrement = \fSizeIncrementL
          EndIf
          If nSizeIncrement = 0
            nSizeIncrement = 1
          EndIf
          ; debugMsg(sProcName, "nSizeIncrement=" + Str(nSizeIncrement))
          nNewSize = aAud(nEditAudPtr)\nSize
          Select sInputChar
            Case "+"
              nNewSize - nSizeIncrement
              bSizeChange = #True
            Case "-"
              nNewSize + nSizeIncrement
              bSizeChange = #True
          EndSelect
          If bSizeChange
            If nNewSize < SLD_getMin(WQA\sldSize)
              nNewSize = SLD_getMin(WQA\sldSize)
            EndIf
            If nNewSize > SLD_getMax(WQA\sldSize)
              nNewSize = SLD_getMax(WQA\sldSize)
            EndIf
            If SLD_getValue(WQA\sldSize) <> nNewSize
              SLD_setValue(WQA\sldSize, nNewSize)
              WQA_displayPosAndSizeTextFields()
              WQA_sldSize_Common()
            EndIf
          EndIf
          
        Case #PB_EventType_MouseWheel  ; #PB_EventType_MouseWheel
          nWheelDelta = GetGadgetAttribute(nCanvasNo, #PB_Canvas_WheelDelta)
          If ShiftKeyDown()
            nSizeIncrement = \fSizeIncrementS
          Else
            nSizeIncrement = \fSizeIncrementL
          EndIf
          If nSizeIncrement = 0
            nSizeIncrement = 1
          EndIf
          ; debugMsg0(sProcName, "nWheelDelta=" + nWheelDelta + ", nSizeIncrement=" + nSizeIncrement)
          nWheelDelta * nSizeIncrement
          If nWheelDelta <> 0
            nNewSize = SLD_getValue(WQA\sldSize) - nWheelDelta
            If nNewSize < SLD_getMin(WQA\sldSize)
              nNewSize = SLD_getMin(WQA\sldSize)
            EndIf
            If nNewSize > SLD_getMax(WQA\sldSize)
              nNewSize = SLD_getMax(WQA\sldSize)
            EndIf
            ; debugMsg(sProcName, "nWheelDelta=" + Str(nWheelDelta) + ", nNewSize=" + Str(nNewSize))
            SLD_setValue(WQA\sldSize, nNewSize)
            WQA_displayPosAndSizeTextFields()
            WQA_sldSize_Common()
            SetActiveGadget(nCanvasNo) ; Added 10Oct2024 11.10.6ak - seems to be necessary for video files
          EndIf
          
      EndSelect
    EndWith
  EndIf
EndProcedure

Procedure WQA_cvsDummyEvent()
  PROCNAMECA(nEditAudPtr)
  Protected nCanvasNo, nCanvasKey
  Protected nItem = -1
  
  If (nEditAudPtr >= 0) And (GetActiveGadget() = WQA\cvsDummy)
    ; see comment under WQA_cvsPreviewOrVideoEvent() for an explanation of this test, even though it's probably not applicable for cvsDummy
    nCanvasNo = gnEventGadgetNo
    Select gnEventType
      Case #PB_EventType_KeyDown
        nCanvasKey = GetGadgetAttribute(nCanvasNo, #PB_Canvas_Key)
        If ShiftKeyDown() = #False
          debugMsg(sProcName, "gnWQACurrItem=" + gnWQACurrItem + ", gnWQALastItem=" + gnWQALastItem)
          Select nCanvasKey
            Case #PB_Shortcut_Left
              If gnWQACurrItem > 0
                nItem = gnWQACurrItem - 1
              EndIf
            Case #PB_Shortcut_Right
              If gnWQACurrItem < (gnWQALastItem - 1)  ; (gnWQALastItem - 1) so we ignore the blank entry at the end
                nItem = gnWQACurrItem + 1
              EndIf
          EndSelect
          If nItem >= 0
            If (aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY) Or (aSub(nEditSubPtr)\nSubState >= #SCS_CUE_PL_READY)
              WQA_processItemSelected(nItem, #False)
              debugMsg(sProcName, "calling SAG(WQA\cvsDummy)")
              SAG(WQA\cvsDummy)
            Else
              debugMsg(sProcName, "event ignored: aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState))
            EndIf
          EndIf
        EndIf
    EndSelect
  EndIf
  
EndProcedure

Procedure WQA_adjustForSplitterSize()
  PROCNAMEC()
  Protected nHeight, nInnerHeight, nMinInnerHeight
  Protected nWidth, nReqdInnerWidth
  Protected nMinCntRightHeight, nMinWindowHeight
  Static bInProcedure
  
  If bInProcedure
    ProcedureReturn
  EndIf
  bInProcedure = #True
  
  ; INFO: ScrollAreaGadget \scaSlideShow automatically resized by splitter gadget, but need to adjust inner height
  
  With WQA
    If IsGadget(\scaSlideShow)
; debugMsg0(sProcName, "(A) GadgetY(WQA\scaSlideShow)=" + GadgetY(\scaSlideShow) + ", GadgetHeight(\scaSlideShow)=" + GadgetHeight(\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
      nInnerHeight = GadgetHeight(\scaSlideShow) - gl3DBorderHeight
      ; debugMsg(sProcName, "GadgetY(WQA\cntSubDetailA)=" + GadgetY(\cntSubDetailA) + ", GadgetY(\cntMoveAddDeleteRename)=" + GadgetY(\cntMoveAddDeleteRename) + ", GadgetHeight(\cntMoveAddDeleteRename)=" + GadgetHeight(\cntMoveAddDeleteRename))
      nMinInnerHeight = GadgetY(\cntSubDetailA) + GadgetY(\cntMoveAddDeleteRename) + GadgetHeight(\cntMoveAddDeleteRename)
      ; debugMsg(sProcName, "nMinInnerHeight=" + nMinInnerHeight)
      If nInnerHeight < nMinInnerHeight
        nInnerHeight = nMinInnerHeight
      EndIf
      If nInnerHeight <> GetGadgetAttribute(\scaSlideShow, #PB_ScrollArea_InnerHeight)
        ; debugMsg(sProcName, "calling SetGadgetAttribute(\scaSlideShow, #PB_ScrollArea_InnerHeight, " + nInnerHeight + ")")
        SetGadgetAttribute(\scaSlideShow, #PB_ScrollArea_InnerHeight, nInnerHeight)
      EndIf
      nMinCntRightHeight = GadgetY(\scaSlideShow) + GadgetHeight(\scaSlideShow)
      If GadgetHeight(WED\cntRight) < nMinCntRightHeight
        ; debugMsg(sProcName, "calling ResizeGadget(WED\cntRight, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nMinCntRightHeight + ")")
        ResizeGadget(WED\cntRight, #PB_Ignore, #PB_Ignore, #PB_Ignore, nMinCntRightHeight)
      EndIf
      
      ; adjust the height of \cntSubDetailA
      nHeight = nInnerHeight - GadgetY(\cntSubDetailA)
      ; debugMsg(sProcName, "calling ResizeGadget(\cntSubDetailA, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nHeight + ")")
      ResizeGadget(\cntSubDetailA, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
; debugMsg(sProcName, "(G) GadgetY(WQA\scaSlideShow)=" + GadgetY(WQA\scaSlideShow) + ", GadgetHeight(WQA\scaSlideShow)=" + GadgetHeight(WQA\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
      
      ; debugMsg(sProcName, "GadgetY(WED\cntRight)=" + GadgetY(WED\cntRight) + ", GadgetHeight(WED\cntRight)=" + GadgetHeight(WED\cntRight) + ", GadgetHeight(\scaTimeLine)=" + GadgetHeight(\scaTimeLine))
      nMinWindowHeight = GadgetY(WED\cntRight) + GadgetHeight(WED\cntRight) + GadgetHeight(\scaTimeLine)
      If WindowHeight(#WED) < nMinWindowHeight
; debugMsg(sProcName, "(H) GadgetY(WQA\scaSlideShow)=" + GadgetY(WQA\scaSlideShow) + ", GadgetHeight(WQA\scaSlideShow)=" + GadgetHeight(WQA\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
        ; debugMsg(sProcName, "calling ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nMinWindowHeight + ")")
        ResizeWindow(#WED, #PB_Ignore, #PB_Ignore, #PB_Ignore, nMinWindowHeight)
; debugMsg(sProcName, "(I) GadgetY(WQA\scaSlideShow)=" + GadgetY(WQA\scaSlideShow) + ", GadgetHeight(WQA\scaSlideShow)=" + GadgetHeight(WQA\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
        ; debugMsg(sProcName, "Calling WED_Form_Resized()")
        WED_Form_Resized()
; debugMsg(sProcName, "(J) GadgetY(WQA\scaSlideShow)=" + GadgetY(WQA\scaSlideShow) + ", GadgetHeight(WQA\scaSlideShow)=" + GadgetHeight(WQA\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
      EndIf
      
      ; adjust the width of the timeline
      nWidth = WindowWidth(#WED) - 1
      If GadgetWidth(WED\cntSpecialQA) <> nWidth
        ResizeGadget(WED\cntSpecialQA,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        nWidth = GadgetWidth(WED\cntSpecialQA) - 4
        ResizeGadget(WQA\scaTimeLine,#PB_Ignore,#PB_Ignore,nWidth,#PB_Ignore)
        ; the following code also exists in createWQAFile(), so make any changes in both places
        nReqdInnerWidth = (gnWQALastItem + 1) * #SCS_QAITEM_WIDTH
        If nReqdInnerWidth < (GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX)
          nReqdInnerWidth = GadgetWidth(WQA\scaTimeLine) - gl3DBorderAllowanceX
        EndIf
        SetGadgetAttribute(WQA\scaTimeLine, #PB_ScrollArea_InnerWidth, nReqdInnerWidth)
      EndIf
; debugMsg0(sProcName, "(Z) GadgetY(WQA\scaSlideShow)=" + GadgetY(WQA\scaSlideShow) + ", GadgetHeight(WQA\scaSlideShow)=" + GadgetHeight(WQA\scaSlideShow) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
    EndIf
  EndWith
  bInProcedure = #False
EndProcedure

Procedure WQA_buildMenuGroup_Rotate()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  scsMenuItem(#WQA_mnuRotateL90, "mnuRotateL90", "", #True, hMiRotateL90)
  scsMenuItem(#WQA_mnuRotateR90, "mnuRotateR90", "", #True, hMiRotateR90)
  scsMenuItem(#WQA_mnuRotate180, "mnuRotate180", "", #True, hMiRotate180)
  MenuBar()
  scsMenuItem(#WQA_mnuFlipH, "mnuFlipH", "", #True, hMiFlipH)
  scsMenuItem(#WQA_mnuFlipV, "mnuFlipV", "", #True, hMiFlipV)
  MenuBar()
  scsMenuItem(#WQA_mnuRotateReset, "mnuRotateReset")  ; no image
EndProcedure

Procedure WQA_buildPopupMenu_Rotate()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If scsCreatePopupImageMenu(#WQA_mnuRotate)
    WQA_buildMenuGroup_Rotate()
  EndIf
EndProcedure

Procedure WQA_buildPopupMenu_Other()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If scsCreatePopupImageMenu(#WQA_mnuOther)
    WQA_buildMenuGroup_Other()
  EndIf
EndProcedure

Procedure WQA_checkPreviewOnOutputScreenAvailable(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, nOutputScreen, nVidPicTarget, nCurrAdPtr
  Protected bAvailable = #True
  
  If pAudPtr >= 0
    nSubPtr = aAud(pAudPtr)\nSubIndex
    nOutputScreen = aSub(nSubPtr)\nOutputScreen
    nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreen)
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nCurrAudPtr=" + getAudLabel(grVidPicTarget(nVidPicTarget)\nCurrAudPtr))
    Select nVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        nCurrAdPtr = grVidPicTarget(nVidPicTarget)\nCurrAudPtr
        If nCurrAdPtr >= 0
          With aAud(nCurrAdPtr)
            If \nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT
              If aSub(nSubPtr)\bStartedInEditor = #False
                bAvailable = #False
              EndIf
            EndIf
          EndWith
        EndIf
    EndSelect
  EndIf
  ProcedureReturn bAvailable
  
EndProcedure

Procedure WQA_initGraphInfo()
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling newGraph(@grMG5, " + getAudLabel(nEditAudPtr) + ")")
  newGraph(@grMG5, nEditAudPtr)
  
  debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(@grMG5)")
  loadSlicePeakAndMinArraysAndDrawGraph(@grMG5)
  
  debugMsg(sProcName, "calling resizeInnerAreaOfGraph(@grMG5)")
  resizeInnerAreaOfGraph(@grMG5)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_displayCueMarkerInfo()
;   PROCNAMECA(nEditAudPtr)
;   Protected nLineCount
;   Protected nCueMarkerIndex, nMarkerPos
;   
;   ; debugMsg(sProcName, #SCS_START)
;   
;   With aAud(nEditAudPtr)
;     For nCueMarkerIndex = 0 To \nMaxCueMarker
;       nMarkerPos = \aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
;       If (nMarkerPos >= \nAbsMin) And (nMarkerPos <= \nAbsMax)
;         SLD_setLinePos(WQA\sldProgress, nLineCount, nMarkerPos - \nAbsMin, #SCS_SLD_LT_CUE_MARKER)
;         nLineCount + 1
;       EndIf
;     Next nCueMarkerIndex   
;     SLD_setLineCount(WQA\sldProgress, nLineCount)
;     
;     WQA_setClearState()
;     
;     samAddRequest(#SCS_SAM_DRAW_GRAPH, 5) ; request SAM to call drawGraph
;     
;   EndWith
;   
;   ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQA_displayFileInfo()
  PROCNAMECA(nEditAudPtr)
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  WQA_displayCueMarkerInfo()
  
EndProcedure

; EOF