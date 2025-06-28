; File: CueEditor.pbi

EnableExplicit

Procedure setSubDescrToolTip(nGadgetNo)
  PROCNAMEC()
  Static sDefaultToolTip.s, bStaticLoaded
  Protected sText.s, nTextLength
  
  If bStaticLoaded = #False
    sDefaultToolTip = Lang("CED","SubDescrTT")
    bStaticLoaded = #True
  EndIf
  sText = GGT(nGadgetNo)
  nTextLength = GetTextWidthForGadget(sText, nGadgetNo)
  If nTextLength > (GadgetWidth(nGadgetNo) - gl3DBorderAllowanceX)
    scsToolTip(nGadgetNo, sText)
  Else
    scsToolTip(nGadgetNo, sDefaultToolTip)
  EndIf
  
EndProcedure

Procedure holdDataForEditCancel()
  PROCNAMEC()
  Protected k, nDevNo, nFixtureIndex

  debugMsg(sProcName, #SCS_START)
  
  With grProd
    For nDevNo = 0 To \nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
      \aAudioLogicalDevs(nDevNo)\sOrigLogicalDev = \aAudioLogicalDevs(nDevNo)\sLogicalDev
      \aAudioLogicalDevs(nDevNo)\bDevChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxVidAudLogicalDev ; grLicInfo\nMaxVidAudDevPerProd
      \aVidAudLogicalDevs(nDevNo)\sOrigLogicalDev = \aVidAudLogicalDevs(nDevNo)\sVidAudLogicalDev
      \aVidAudLogicalDevs(nDevNo)\bDevChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxVidCapLogicalDev ; grLicInfo\nMaxVidCapDevPerProd
      \aVidCapLogicalDevs(nDevNo)\sOrigLogicalDev = \aVidCapLogicalDevs(nDevNo)\sLogicalDev
      \aVidCapLogicalDevs(nDevNo)\bDevChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxFixType
      \aFixTypes(nDevNo)\sOrigFixTypeName = \aFixTypes(nDevNo)\sFixTypeName
      \aFixTypes(nDevNo)\bFixTypeChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
      \aLightingLogicalDevs(nDevNo)\sOrigLogicalDev = \aLightingLogicalDevs(nDevNo)\sLogicalDev
      \aLightingLogicalDevs(nDevNo)\bDevChanged = #False
      For nFixtureIndex = 0 To \aLightingLogicalDevs(nDevNo)\nMaxFixture
        \aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sOrigFixtureCode = \aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
        \aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\bFixtureChanged = #False
      Next nFixtureIndex
    Next nDevNo
    
    For nDevNo = 0 To \nMaxCtrlSendLogicalDev
      \aCtrlSendLogicalDevs(nDevNo)\sOrigLogicalDev = \aCtrlSendLogicalDevs(nDevNo)\sLogicalDev
      \aCtrlSendLogicalDevs(nDevNo)\bDevChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
      \aLiveInputLogicalDevs(nDevNo)\sOrigLogicalDev = \aLiveInputLogicalDevs(nDevNo)\sLogicalDev
      \aLiveInputLogicalDevs(nDevNo)\bDevChanged = #False
    Next nDevNo
    
    For nDevNo = 0 To \nMaxInGrp ; grLicInfo\nMaxInGrpPerProd
      \aInGrps(nDevNo)\sOrigInGrpName = \aInGrps(nDevNo)\sInGrpName
      \aInGrps(nDevNo)\bInGrpChanged = #False
    Next nDevNo
    
  EndWith
  
  grHoldProd = grProd
  ED_loadDevChgsFromProd()
  
  debugMsg(sProcName, "calling WEP_setDevChgsBtns")
  WEP_setDevChgsBtns()
  
  debugMsg(sProcName, "copy auds")
  For k = 0 To ArraySize(aAud())
    aAud(k)\nPreEditPtr = k
  Next k
  CopyArray(aAud(), gaHoldAud())
  
  debugMsg(sProcName,#SCS_END)
  
EndProcedure

Procedure findChangesRequiringResettingGaplessInfoEtc()
  PROCNAMEC()
  Protected i, j, k
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      aSub(j)\bMajorChangeInEditor = #False
      If aSub(j)\bSubTypeA
      ElseIf aSub(j)\bSubTypeF
      ElseIf aSub(j)\bSubTypeP
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
EndProcedure

Procedure addAud(pCuePtr, pSubPtr, pAudPtr)
  PROCNAMEC()
  Protected k

  checkMaxAud(gnLastAud + 1)

  debugMsg(sProcName, "QP=" + pCuePtr + ", SP=" + pSubPtr + ", AP=" + pAudPtr)
  
  For k = (gnLastAud+1) To pAudPtr Step -1
    aAud(k) = aAud(k-1)
  Next k

  aAud(pAudPtr) = grAudDefForAdd
  With aAud(pAudPtr)
    If \nAudId = -1
      gnUniqueAudId + 1
      \nAudId = gnUniqueAudId
    EndIf
    \nCueIndex = pCuePtr
    \nSubIndex = pSubPtr
    \sCue = aCue(pCuePtr)\sCue
    setLabels(pCuePtr)  ; make sure we set the labels asap for tracing purposes
  EndWith
  setEditAudPtr(pAudPtr)
  gnLastAud + 1

  ProcedureReturn #True
EndProcedure

Procedure addAudToSub(pCuePtr, pSubPtr, nCtrlSendIndex=-1)
  PROCNAMEC()
  Protected nAudPtr, k, d, d2, nPrevAudIndex
  Protected rDevInfo.tyProd, nMaxDev
  Protected u4

  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr))
  
  nAudPtr = gnLastAud + 1
  If addAud(pCuePtr, pSubPtr, nAudPtr) = #False
    ProcedureReturn -1
  EndIf
  u4 = preChangeAudL(#True, "Add File", -1, #SCS_UNDO_ACTION_ADD_AUD, nCtrlSendIndex, 0, aAud(nAudPtr)\nAudId)

  gnLastAud = nAudPtr
  
  With aAud(nAudPtr)
    \sCue = aCue(pCuePtr)\sCue
    \nCueIndex = pCuePtr
    \nSubIndex = pSubPtr
    \nSubNo = aSub(pSubPtr)\nSubNo
    \bAudTypeA = aSub(pSubPtr)\bSubTypeA
    \bAudTypeF = aSub(pSubPtr)\bSubTypeF
    \bAudTypeI = aSub(pSubPtr)\bSubTypeI
    \bAudTypeM = aSub(pSubPtr)\bSubTypeM
    \bAudTypeP = aSub(pSubPtr)\bSubTypeP
    \bAudTypeAorF = aSub(pSubPtr)\bSubTypeAorF
    \bAudTypeAorP = aSub(pSubPtr)\bSubTypeAorP
    \bAudTypeForP = aSub(pSubPtr)\bSubTypeForP
    \bLiveInput = aSub(pSubPtr)\bLiveInput
    If \bAudTypeF
      \nFadeInTime = grProd\nDefFadeInTime
      \nFadeOutTime = grProd\nDefFadeOutTime
    ElseIf \bAudTypeA
      grLastPicInfo\nLastPicEndAt = grProd\nDefDisplayTimeA ; Added 5Feb2025 11.10.7aa for Image sub-cues
    ElseIf \bAudTypeI
      \nFileFormat = #SCS_FILEFORMAT_LIVE_INPUT
      \nFadeInTime = grProd\nDefFadeInTimeI
      \nFadeOutTime = grProd\nDefFadeOutTimeI
    EndIf
  EndWith

  rDevInfo = grProd
  nMaxDev = rDevInfo\nMaxAudioLogicalDev
  ; Added 21May2024 11.10.3ad
  If nMaxDev > #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
    nMaxDev = #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
  EndIf
  ; End added 21May2024 11.10.3ad

  If aSub(pSubPtr)\nFirstAudIndex = -1
    aSub(pSubPtr)\nFirstAudIndex = nAudPtr
  Else
    k = aSub(pSubPtr)\nFirstAudIndex
    While k >= 0
      With aAud(k)
        For d = 0 To nMaxDev
          rDevInfo\aAudioLogicalDevs(d)\sLogicalDev = \sLogicalDev[d]
          If rDevInfo\aAudioLogicalDevs(d)\sLogicalDev
            rDevInfo\aAudioLogicalDevs(d)\bAutoInclude = #True    ; forces auto-include of this device in the new aud being added
          Else
            rDevInfo\aAudioLogicalDevs(d)\bAutoInclude = #False
          EndIf
          rDevInfo\aAudioLogicalDevs(d)\nDfltBassDevice = \nBassDevice[d]
          rDevInfo\aAudioLogicalDevs(d)\sDfltDBTrim = \sDBTrim[d]
          rDevInfo\aAudioLogicalDevs(d)\fDfltTrimFactor = \fTrimFactor[d]
          rDevInfo\aAudioLogicalDevs(d)\sDfltDBLevel = \sDBLevel[d]
          rDevInfo\aAudioLogicalDevs(d)\fDfltBVLevel = \fBVLevel[d]
          rDevInfo\aAudioLogicalDevs(d)\fDfltPan = \fPan[d]
        Next d
      EndWith
      nPrevAudIndex = k
      k = aAud(k)\nNextAudIndex
    Wend
    aAud(nPrevAudIndex)\nNextAudIndex = nAudPtr
    debugMsg(sProcName, "aAud(" + getAudLabel(nPrevAudIndex) + ")\nNextAudIndex=" + getAudLabel(aAud(nPrevAudIndex)\nNextAudIndex))
    aAud(nAudPtr)\nPrevAudIndex = nPrevAudIndex
  EndIf

  With aAud(nAudPtr)
    debugMsg(sProcName, "\bAudTypeA=" + strB(\bAudTypeA) + ", \bAudTypeF=" + strB(\bAudTypeF) + ", \bAudTypeI=" + strB(\bAudTypeI) + ", \bAudTypeM=" + strB(\bAudTypeM) + ", \bAudTypeP=" + strB(\bAudTypeP))
    
    If \bAudTypeA
      d = 0
      \sLogicalDev[d] = aSub(pSubPtr)\sVidAudLogicalDev
      \sDBLevel[d] = grLevels\sZeroDBLevel
      \fBVLevel[d] = grLevels\fZeroBVLevel
      \fAudPlayBVLevel[d] = \fBVLevel[d]
      \fPan[d] = #SCS_PANCENTRE_SINGLE
      \fAudPlayPan[d] = \fPan[d]
      \fSavedBVLevel[d] = \fBVLevel[d]
      \fSavedPan[d] = \fPan[d]
      
    ElseIf \bAudTypeM
      If nCtrlSendIndex >= 0
        aSub(pSubPtr)\aCtrlSend[nCtrlSendIndex]\nAudPtr = nAudPtr
      EndIf
      For d2 = 0 To rDevInfo\nMaxCtrlSendLogicalDev
        If rDevInfo\aCtrlSendLogicalDevs(d2)\nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
          If rDevInfo\aCtrlSendLogicalDevs(d2)\sLogicalDev
            \sLogicalDev[0] = rDevInfo\aCtrlSendLogicalDevs(d2)\sLogicalDev
            Break
          EndIf
        EndIf
      Next d2
      \sDBLevel[0] = grLevels\sMaxDBLevel
      \fBVLevel[0] = grLevels\fMaxBVLevel
      \fPan[0] = #SCS_PANCENTRE_SINGLE
      \fSavedBVLevel[d] = \fBVLevel[d]
      \fSavedPan[d] = \fPan[d]
      
    Else
      d = -1
      For d2 = 0 To nMaxDev
        If rDevInfo\aAudioLogicalDevs(d2)\bAutoInclude
          d + 1
          \sLogicalDev[d] = rDevInfo\aAudioLogicalDevs(d2)\sLogicalDev
          \nBassDevice[d] = rDevInfo\aAudioLogicalDevs(d2)\nDfltBassDevice
          \sTracks[d] = grAudDef\sTracks[d2]
          \sDBTrim[d] = rDevInfo\aAudioLogicalDevs(d2)\sDfltDBTrim
          \fTrimFactor[d] = rDevInfo\aAudioLogicalDevs(d2)\fDfltTrimFactor
          \sDBLevel[d] = rDevInfo\aAudioLogicalDevs(d2)\sDfltDBLevel
          \fBVLevel[d] = rDevInfo\aAudioLogicalDevs(d2)\fDfltBVLevel
          \fAudPlayBVLevel[d] = \fBVLevel[d]
          \fPan[d] = rDevInfo\aAudioLogicalDevs(d2)\fDfltPan
          \fAudPlayPan[d] = \fPan[d]
          \fSavedBVLevel[d] = \fBVLevel[d]
          \fSavedPan[d] = \fPan[d]
        EndIf
      Next d2
    EndIf
    
    For d = 0 To 4
      If \sLogicalDev[d]
        debugMsg(sProcName, "\sLogicalDev[" + d + "]=" + \sLogicalDev[d] + ", \sDBLevel[" + d + "]=" + \sDBLevel[d] + ", \fBVLevel[" + d + "]=" + formatLevel(\fBVLevel[d]))
      EndIf
    Next d
    
  EndWith

  setFirstAndLastDev(nAudPtr)
  setDerivedFieldsForSubAuds(pSubPtr)
  
  setEditAudPtr(nAudPtr)
  
  ProcedureReturn u4

EndProcedure

Procedure addCue(pCuePtr)
  PROCNAMEC()
  Protected i, j, sCue.s, nCounter
  Protected sChar.s
  Protected nNumber
  Protected bDoingPrefix, bFound, bFound2
  
  debugMsg(sProcName, #SCS_START + ", pCuePtr=" + pCuePtr)
  
  If checkMaxCue(gnLastCue+1) = #False
    ; cue limit exceeded - ignore this
    ProcedureReturn #False
  EndIf

  If grCED\bCueCreated = #False
    WEC_Form_Load()
  EndIf
  
  For i = (gnLastCue+1) To pCuePtr Step -1
    aCue(i) = aCue(i-1)
  Next i

  aCue(pCuePtr) = grCueDef
  With aCue(pCuePtr)
    If \nCueId = -1
      gnUniqueCueId + 1
      \nCueId = gnUniqueCueId
    EndIf
    gnNodeId + 1
    \nNodeKey = gnNodeId
    \bDefaultCueDescrMayBeSet = #True
    WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  EndWith
  nEditCuePtr = pCuePtr
  gnLastCue + 1
  gnCueEnd + 1

  ; generate a new cue label
  If pCuePtr = 1
    sCue = generateNextCueLabel("", grProd\nCueLabelIncrement)
  Else
    sCue = generateNextCueLabel(aCue(pCuePtr-1)\sCue, grProd\nCueLabelIncrement)
  EndIf

  ; now check if that cue label is already in use
  bFound = #False
  For i = 1 To gnLastCue
    If UCase(aCue(i)\sCue) = UCase(sCue)
      bFound = #True
      Break
    EndIf
  Next i

  If bFound
    ; generated label already in use so create a unique label
    nCounter = 0
    bFound = #True
    While (bFound) And (nCounter < 10000) ; prevent endless loop
      nCounter + 1
      sCue = generateNextCueLabel(sCue, grProd\nCueLabelIncrement)
      bFound = #False
      For i = 1 To gnLastCue
        If UCase(aCue(i)\sCue) = UCase(sCue)
          bFound = #True
          Break
        EndIf
      Next i
    Wend
  EndIf

  debugMsg(sProcName, "calling resyncCuePtrs")
  resyncCuePtrs()
  debugMsg(sProcName, "calling displayOrHideVideoWindows()")
  displayOrHideVideoWindows()
  loadCueBrackets()
  If gbInDragDrop = #False
    debugMsg(sProcName, "calling loadHotkeyArray")
    loadHotkeyArray()
  EndIf
  loadCueMarkerArrays()

  If bFound
    debugMsg(sProcName, #SCS_END)
    ProcedureReturn #False
  Else
    aCue(pCuePtr)\sCue = sCue
    debugMsg(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nNodeKey=" + Str(aCue(pCuePtr)\nNodeKey))
    debugMsg(sProcName, #SCS_END)
    ProcedureReturn #True
  EndIf

EndProcedure

Procedure checkOKToAddLightingCue()
  PROCNAMEC()
  Protected bOK, d, nReply
  
  For d = 0 To grProd\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
    With grProd\aLightingLogicalDevs(d)
      If \sLogicalDev
        bOK = #True
        Break
      EndIf
    EndWith
  Next d
  
  If bOK = #False
    nReply = scsMessageRequester(#SCS_TITLE, Lang("WQK", "CannotCreate"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    ; message asks if user wants to set up a Lighting Device now
    If nReply = #PB_MessageRequester_Yes
      grWEP\bDisplayLightingTab = #True
      ; WED_publicNodeClick(grProd\nNodeKey)
      samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, grProd\nNodeKey)
    EndIf
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure checkOKToAddCtrlSendCue()
  PROCNAMEC()
  Protected bOK, d, nReply
  
  For d = 0 To grProd\nMaxCtrlSendLogicalDev
    With grProd\aCtrlSendLogicalDevs(d)
      If \sLogicalDev
        bOK = #True
        Break
      EndIf
    EndWith
  Next d
  
  If bOK = #False
    nReply = scsMessageRequester(#SCS_TITLE, Lang("WQM", "CannotCreate"), #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    ; message asks if user wants to set up a Control Send Device now
    If nReply = #PB_MessageRequester_Yes
      grWEP\bDisplayCtrlSendTab = #True
      samAddRequest(#SCS_SAM_EDITOR_NODE_CLICK, grProd\nNodeKey)
    EndIf
    ProcedureReturn #False
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure checkOKToAddLiveInputCue()
  PROCNAMEC()
  Protected nDevCount, nDummyCount, d, nDevPtr
  
  If gnCurrAudioDriver <> #SCS_DRV_SMS_ASIO
    For d = 0 To grProd\nMaxLiveInputLogicalDev ; #SCS_MAX_LIVE_INPUT_DEV_PER_PROD
      With grProd\aLiveInputLogicalDevs(d)
        If \sLogicalDev
          nDevCount + 1
          nDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, \sLogicalDev)
          If nDevPtr >= 0
            If grMaps\aDev(nDevPtr)\bDummy
              nDummyCount + 1
            EndIf
          EndIf
        EndIf
      EndWith
    Next d
    If nDummyCount > 0
      debugMsg(sProcName, "nDevCount=" + nDevCount + ", nDummyCount=" + nDummyCount)
    EndIf
    If nDevCount > nDummyCount
      scsMessageRequester(#SCS_TITLE, Lang("WQI", "NeedsSMS"), #MB_ICONEXCLAMATION)
      ProcedureReturn #False
    EndIf
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure addCueWithSubCue(pSubType.s, bRedoTree, bCallCreateCueType=#False, sFileName.s="", bSkipValidation=#False, bDragAndDrop=#False, sFileList.s="")
  PROCNAMEC()
  Protected nCuePtr, nNodeKey, sUndoDescr.s, bControlThreadSuspended
  Protected nBeforeNodeKey
  Protected u
  Protected sThisFileName.s, n
  Protected nFileCount, k, nAudCount
  
  debugMsg(sProcName, #SCS_START + ", pSubType=" + pSubType + ", bRedoTree=" + strB(bRedoTree) + ", bCallCreateCueType=" + strB(bCallCreateCueType))
  
  If bSkipValidation = #False   ; nb bSkipValidation should only be set #True from code that has already called WED_validateDisplayedItem() and received a #True result
    If WED_validateDisplayedItem() = #False
      ProcedureReturn
    EndIf
  EndIf
  
  Select pSubType
    Case "I"
      If checkOKToAddLiveInputCue() = #False
        ProcedureReturn
      EndIf
    Case "K"
      If checkOKToAddLightingCue() = #False
        ProcedureReturn
      EndIf
    Case "M"
      If checkOKToAddCtrlSendCue() = #False
        ProcedureReturn
      EndIf
    Case "U"
      If checkOKToAddMTCCue() = #False
        ProcedureReturn
      EndIf
  EndSelect
  
  ; gbAdding = #True ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If gbAdding = #False
    gbAdding = #True
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
    THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
    bControlThreadSuspended = #True
  EndIf
  ; End added 13Dec2021 11.8.6cw
  
  nCuePtr = nEditCuePtr + 1
  debugMsg(sProcName, "gbAdding=" + strB(gbAdding) + ", nCuePtr=" + nCuePtr + ", pSubType=" + pSubType + ", bRedoTree=" + strB(bRedoTree) + ", sFileName=" + sFileName)
  If nCuePtr <= 0
    nCuePtr = 1
  EndIf
  
  If addCue(nCuePtr)
    sUndoDescr = "Add Cue " + aCue(nCuePtr)\sCue
    debugMsg(sProcName, "calling preChangeCueL")
    u = preChangeCueL(#True, sUndoDescr, -1, #SCS_UNDO_ACTION_ADD_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(nCuePtr)\nCueId)
    
    debugMsg(sProcName, "calling addSubToCue(" + nCuePtr + ", 1, " + pSubType + ")")
    addSubToCue(nCuePtr, 1, pSubType)
    setCuePtrs(#False)
    setCueState(nCuePtr)
    nEditCuePtr = nCuePtr
    nEditSubPtr = aCue(nEditCuePtr)\nFirstSubIndex
    debugMsg(sProcName, "calling setDefaultSubDescr()")
    setDefaultSubDescr()
    debugMsg(sProcName, "calling setDefaultCueDescr()")
    setDefaultCueDescr()
    If nCuePtr <= gnLastCue
      nBeforeNodeKey = aCue(nCuePtr+1)\nNodeKey
    EndIf
    debugMsg(sProcName, "calling addCueNode(" + aCue(nEditCuePtr)\sCue + ")")
    addCueNode(nEditCuePtr, nBeforeNodeKey)
    
    aCue(nEditCuePtr)\sValidatedCue = aCue(nEditCuePtr)\sCue
    aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
    
    If bCallCreateCueType
      Select pSubType
        Case "A"
          ;{
          With aSub(nEditSubPtr)
            ; Added 5Feb2025 11.10.7aa for Video/Image sub-cues
            \nPLFadeInTime = grProd\nDefFadeInTimeA
            \nPLFadeOutTime = grProd\nDefFadeOutTimeA
            \bPLRepeat = grProd\bDefRepeatA
            \bPauseAtEnd = grProd\bDefPauseAtEndA
            ; End added 5Feb2025 11.10.7aa for Video/Image sub-cues
            \nOutputScreen = grProd\nDefOutputScreen
            \sScreens = Str(\nOutputScreen) ; Added 19Oct2022 11.9.6 following email from Gareth Edey
            ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")=" + aSub(nEditSubPtr)\nOutputScreen + ", \sScreens=" + \sScreens)
          EndWith
          If bDragAndDrop
            nFileCount = CountString(sFileList, Chr(10)) + 1
          Else
            nFileCount = gnSelectedFileCount
          EndIf
          If nFileCount = 0
            With aSub(nEditSubPtr)
              \bSubPlaceHolder = #True
              \nSubState = #SCS_CUE_READY
              ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\bSubPlaceHolder=" + strB(\bSubPlaceHolder) + ", \nSubState=" + decodeCueState(\nSubState))
            EndWith
          Else
            For n = 1 To nFileCount
              addAudToSub(nEditCuePtr, nEditSubPtr)
              If bDragAndDrop
                sThisFileName = StringField(sFileList, n, Chr(10))
              Else
                sThisFileName = gsSelectedDirectory + gsSelectedFile(n-1)
              EndIf
              debugMsg(sProcName, "calling createAudTypeA(" + sThisFileName + ")")
              createAudTypeA(sThisFileName)
            Next n
          EndIf
          setCuePtrs(#False)
          debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
          generatePlayOrder(nEditSubPtr)
          WQA_doSubTotals()
          debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd(#True)")
          WQA_resetSubDescrIfReqd(#True)
          ;}
        Case "F"
          ;{
          If bDragAndDrop
            sThisFileName = StringField(sFileList, 1, Chr(10))
          Else
            sThisFileName = sFileName
          EndIf
          debugMsg(sProcName, "calling createCueOrSubTypeF(" + GetFilePart(sThisFileName) + ")")
          createCueOrSubTypeF(sThisFileName)
          ;}
        Case "I"
          ;{
          debugMsg(sProcName, "calling createCueOrSubTypeI()")
          createCueOrSubTypeI()
          ;}
        Case "K"
          ;{
          With aSub(nEditSubPtr)
            If grProd\aLightingLogicalDevs(0)\nDevType <> #SCS_DEVTYPE_NONE
              \sLTLogicalDev = grProd\aLightingLogicalDevs(0)\sLogicalDev
              \nLTDevType = grProd\aLightingLogicalDevs(0)\nDevType
            EndIf
          EndWith
          ;}
        Case "P"
          ;{
          If bDragAndDrop
            nFileCount = CountString(sFileList, Chr(10)) + 1
          Else
            nFileCount = gnSelectedFileCount
          EndIf
          If nFileCount = 0
            With aSub(nEditSubPtr)
              \bSubPlaceHolder = #True
              \nSubState = #SCS_CUE_READY
              debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\bSubPlaceHolder=" + strB(\bSubPlaceHolder) + ", \nSubState=" + decodeCueState(\nSubState))
            EndWith
          Else
            For n = 1 To nFileCount
              addAudToSub(nEditCuePtr, nEditSubPtr)
              If bDragAndDrop
                sThisFileName = StringField(sFileList, n, Chr(10))
              Else
                sThisFileName = gsSelectedDirectory + gsSelectedFile(n-1)
              EndIf
              ; debugMsg(sProcName, "sThisFileName=" + sThisFileName)
              debugMsg(sProcName, "call createAudTypeP(" + GetFilePart(sThisFileName) + ")")
              createAudTypeP(sThisFileName)
            Next n
          EndIf
          setCuePtrs(#False)
          nAudCount = 0
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nFirstAudIndex=" + getAudLabel(aSub(nEditSubPtr)\nFirstAudIndex))
          k = aSub(nEditSubPtr)\nFirstAudIndex
          While k >= 0
            nAudCount + 1
            aAud(k)\nAudNo = nAudCount
            debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nNextAudIndex=" + getAudLabel(k))
            k = aAud(k)\nNextAudIndex
          Wend
          debugMsg(sProcName, "nAudCount=" + nAudCount)
          aSub(nEditSubPtr)\nAudCount = nAudCount
          debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
          generatePlayOrder(nEditSubPtr)
          WQP_doPLTotals()
          WQP_resetSubDescrIfReqd(#True)
          CompilerIf #c_include_mygrid_for_playlists
            debugMsg(sProcName, "calling WQP_displaySub(" + getSubLabel(nEditSubPtr) + ")")
            WQP_displaySub(nEditSubPtr)
          CompilerEndIf
          ;}
      EndSelect
    EndIf
    
    setCueSubsAllDisabledFlag(nCuePtr)
    setCueState(nCuePtr)
    setCueLength(nCuePtr)
    
    debugMsg(sProcName, "aCue(" + nCuePtr + ")\sCueDescr=" + aCue(nCuePtr)\sCueDescr)
    debugMsg(sProcName, "\nActivationMethod=" + decodeActivationMethod(aCue(nEditCuePtr)\nActivationMethod))
    postChangeCueL(u, #False, nCuePtr)
    
    If gbInDragDrop = #False
      If bRedoTree
        nNodeKey = aCue(nCuePtr)\nNodeKey
        debugMsg3(sProcName, "calling WED_publicNodeClick(" + nNodeKey + ")") 
        WED_publicNodeClick(nNodeKey)
      EndIf
      If gbInPaste = #False
        gbCallPopulateGrid = #True
        debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
        gbCallLoadDispPanels = #True
      EndIf
      SAW(#WED)
    EndIf
    
  EndIf
  
  ; gbAdding = #False ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If bControlThreadSuspended
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    gbAdding = #False
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
  EndIf
  ; End added 13Dec2021 11.8.6cw

  debugMsg(sProcName, #SCS_END + ", returning " + getCueLabel(nCuePtr))
  ProcedureReturn nCuePtr

EndProcedure

Procedure addSub(pCuePtr, pSubPtr)
  PROCNAMEC()
  Protected j

  debugMsg(sProcName, #SCS_START + ", pCuePtr=" + pCuePtr + ", pSubPtr=" + pSubPtr)
  
  If nEditSubPtr >= 1
    If valSub() = #False
      ProcedureReturn #False
    EndIf
  EndIf

  checkMaxSub(gnLastSub + 1)

  For j = (gnLastSub+1) To pSubPtr Step -1
    aSub(j) = aSub(j-1)
  Next j

  gnLastSub + 1
  aSub(pSubPtr) = grSubDefForAdd
  With aSub(pSubPtr)
    If \nSubId = -1
      gnUniqueSubId + 1
      \nSubId = gnUniqueSubId
    EndIf
    gnNodeId + 1
    \nNodeKey = gnNodeId
    WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
    \nCueIndex = pCuePtr
    \sCue = aCue(pCuePtr)\sCue
    \bDefaultSubDescrMayBeSet = #True
    setLabels(pCuePtr)  ; make sure we set the labels asap for tracing purposes
  EndWith
  nEditSubPtr = pSubPtr
  setCueSubsAllDisabledFlag(pCuePtr)

  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure addSubCue(pSubType.s, bCallCreateCueType=#False, sFileName.s="", bSkipValidation=#False)
  PROCNAMEC()
  Protected j, nSubNo, nNodeKey, bControlThreadSuspended
  Protected nCueNodeKey, nBeforeNodeKey
  Protected nItemNo
  Protected u
  Protected sThisFileName.s
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", pSubType=" + pSubType)
  
  If bSkipValidation = #False   ; nb bSkipValidation should only be set #True from code that has already called valSub() and received a #True result
    If nEditSubPtr >= 1
      If valSub() = #False
        ProcedureReturn
      EndIf
    EndIf
  EndIf
  
  Select pSubType
    Case "I"
      If checkOKToAddLiveInputCue() = #False
        ProcedureReturn
      EndIf
    Case "K"
      If checkOKToAddLightingCue() = #False
        ProcedureReturn
      EndIf
    Case "M"
      If checkOKToAddCtrlSendCue() = #False
        ProcedureReturn
      EndIf
    Case "U"
      If checkOKToAddMTCCue() = #False
        ProcedureReturn
      EndIf
  EndSelect
  
debugMsg(sProcName, "calling createfmEditSubIfReqd(" + pSubType + ")")
  createfmEditSubIfReqd(pSubType)

  ; Determine required nSubNo for the new sub-cue by adding one to
  ; the currently selected or latest. Use 1 if none found.
  If nEditSubPtr >= 0
    nSubNo = aSub(nEditSubPtr)\nSubNo
  Else
    nSubNo = 0
    If nEditCuePtr >= 0
      j = aCue(nEditCuePtr)\nFirstSubIndex
      While j >= 0
        nSubNo = aSub(j)\nSubNo
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  EndIf
  nSubNo + 1

  ; gbAdding = #True ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If gbAdding = #False
    gbAdding = #True
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
    THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
    bControlThreadSuspended = #True
  EndIf
  ; End added 13Dec2021 11.8.6cw
  debugMsg(sProcName, "pSubType=" + pSubType + ", nSubNo=" + nSubNo)
  
  u = preChangeCueL(#True, "Add Sub-Cue", -5, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)

  addSubToCue(nEditCuePtr, nSubNo, pSubType)
  setCuePtrs(#False)
  
  debugMsg(sProcName, "calling setDefaultSubDescr()")
  setDefaultSubDescr()
  If nSubNo = 1
    debugMsg(sProcName, "calling setDefaultCueDescr()")
    setDefaultCueDescr()
  EndIf

  ; cause node to be expanded if there is more than one subcue - unless we're in drag-n-drop
  If gbInDragDrop = #False
    If nEditCuePtr >= 0
      If nSubNo > 1
        aCue(nEditCuePtr)\bNodeExpanded = #True
      Else
        j = aCue(nEditCuePtr)\nFirstSubIndex
        If j >= 0
          If aSub(j)\nNextSubIndex >= 0
            aCue(nEditCuePtr)\bNodeExpanded = #True
          EndIf
        EndIf
      EndIf
    EndIf
  EndIf
  
  nCueNodeKey = aCue(nEditCuePtr)\nNodeKey
  nItemNo = getTreeItemNoForNodeKey(nCueNodeKey)
  If nItemNo >= 0
    debugMsg(sProcName, "calling RemoveGadgetItem(WED\tvwProdTree, " + Str(nItemNo) + ")")
    RemoveGadgetItem(WED\tvwProdTree, nItemNo)
  EndIf
  If nEditCuePtr <= gnLastCue
    nBeforeNodeKey = aCue(nEditCuePtr+1)\nNodeKey
  EndIf
  debugMsg(sProcName, "calling addCueNode(" + aCue(nEditCuePtr)\sCue + ")")
  addCueNode(nEditCuePtr, nBeforeNodeKey)

  aCue(nEditCuePtr)\sValidatedCue = aCue(nEditCuePtr)\sCue
  aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
  
  If bCallCreateCueType
    Select pSubType
      Case "A"
        For n = 1 To gnSelectedFileCount
          addAudToSub(nEditCuePtr, nEditSubPtr)
          sThisFileName = gsSelectedDirectory + gsSelectedFile(n-1)
          debugMsg(sProcName, "sThisFileName=" + sThisFileName)
          createAudTypeA(sThisFileName)
        Next n
        setCuePtrs(#False)
        debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
        generatePlayOrder(nEditSubPtr)
        WQA_doSubTotals()
        debugMsg(sProcName, "calling WQA_resetSubDescrIfReqd()")
        WQA_resetSubDescrIfReqd()
        
      Case "F"
        debugMsg(sProcName, "calling createCueOrSubTypeF(" + GetFilePart(sFileName) + ")")
        createCueOrSubTypeF(sFileName)
        
      Case "I"
        debugMsg(sProcName, "calling createCueOrSubTypeI()")
        createCueOrSubTypeI()
        
      Case "K"
        With aSub(nEditSubPtr)
          If grLightingLogicalDevsDef\nDevType <> #SCS_DEVTYPE_NONE
            \sLTLogicalDev = grLightingLogicalDevsDef\sLogicalDev
            \nLTDevType = grLightingLogicalDevsDef\nDevType
          EndIf
        EndWith
        
      Case "P"
        For n = 1 To gnSelectedFileCount
          addAudToSub(nEditCuePtr, nEditSubPtr)
          sThisFileName = gsSelectedDirectory + gsSelectedFile(n-1)
          ; debugMsg(sProcName, "sThisFileName=" + sThisFileName)
          debugMsg(sProcName, "call createAudTypeP(" + GetFilePart(sThisFileName) + ")")
          createAudTypeP(sThisFileName)
        Next n
        setCuePtrs(#False)
        debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nEditSubPtr) + ")")
        generatePlayOrder(nEditSubPtr)
        WQP_doPLTotals()
        WQP_resetSubDescrIfReqd()
        
    EndSelect
  EndIf
  setCueSubsAllDisabledFlag(nEditCuePtr)
  
  debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
  
  postChangeCueL(u, #False, -5, -1, "Add Sub-Cue " + aSub(nEditSubPtr)\sSubLabel)
  
  loadCueMarkerArrays()
  
  nNodeKey = aSub(nEditSubPtr)\nNodeKey
  debugMsg3(sProcName, "calling WED_publicNodeClick(nNodeKey)") 
  WED_publicNodeClick(nNodeKey)
  
  If gbInPaste = #False
    gbCallPopulateGrid = #True
    debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
    gbCallLoadDispPanels = #True
  EndIf
  
  ; gbAdding = #False ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If bControlThreadSuspended
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    gbAdding = #False
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
  EndIf
  ; End added 13Dec2021 11.8.6cw
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addSubToCue(pCuePtr, pSubNo, pSubType.s)
  PROCNAMECQ(pCuePtr)
  ; note: pSubNo is the nSubNo of the sub to be added
  Protected nSubPtr, i, j, k
  Protected nPrevSubIndex, nNextSubIndex
  Protected nAudPtr, nSubNo
  Protected nSFRCueType, sSFRCue.s, nSFRAction
  Protected bSFRCueFound
  Protected u2, u4

  debugMsg(sProcName, #SCS_START + "pCuePtr=" + pCuePtr + ", pSubNo=" + pSubNo + ", pSubType=" + pSubType)
  
  nSubPtr = gnLastSub + 1
  If addSub(pCuePtr, nSubPtr) = #False
    ; if addSub() fails then we cannot add the sub-cue
    ProcedureReturn #False
  EndIf
  
  ; Moved down 6Jan2024 11.10.0 - see relevant comments
  ;   debugMsg(sProcName, "calling createfmEditSubIfReqd(" + pSubType + ")")
  ;   createfmEditSubIfReqd(pSubType)
  ; End moved down 6Jan2024 11.10.0
  
  u2 = preChangeSubL(#True, "Add Sub-Cue", -1, #SCS_UNDO_ACTION_ADD_SUB, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aSub(nSubPtr)\nSubId)

  gnLastSub = nSubPtr

  With aSub(nSubPtr)
    \sCue = aCue(pCuePtr)\sCue
    \sSubType = pSubType
;     setDefaultSubDescr(nSubPtr, #False)
  EndWith
  setDerivedSubFields(nSubPtr, #True)
  
  ; Moved here from above 6Jan2024 11.10.0 as getSubBackColor() may be called before returning from createfmEditSubIfReqd(), and getSubBackColor() requires \sSubType to be set
  createfmEditSubIfReqd(pSubType)
  ; End moved here from above 6Jan2024 11.10.0
  
  ; Added 28Nov2022 11.9.7ap
  If pSubType = "A"
    setNew2DDrawingInd(nSubPtr)
  EndIf
  ; End added 28Nov2022 11.9.7ap
  
  If aCue(pCuePtr)\nFirstSubIndex = -1
    aCue(pCuePtr)\nFirstSubIndex = nSubPtr
  Else
    nPrevSubIndex = -1
    nNextSubIndex = -1
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\nSubNo >= pSubNo
        Break
      EndIf
      nPrevSubIndex = j
      j = aSub(j)\nNextSubIndex
    Wend
    If nPrevSubIndex >= 0
      nNextSubIndex = aSub(nPrevSubIndex)\nNextSubIndex
      aSub(nPrevSubIndex)\nNextSubIndex = nSubPtr
    EndIf
    aSub(nSubPtr)\nPrevSubIndex = nPrevSubIndex
    aSub(nSubPtr)\nNextSubIndex = nNextSubIndex
    ; 29/11/2013 (SCS 11.2.6a) added following bug reported by Sebastian Franke, 27/11/2013
    If nNextSubIndex >= 0
      aSub(nNextSubIndex)\nPrevSubIndex = nSubPtr
    EndIf
    ; 29/11/2013 end of fix
  EndIf
  
  ; debugMsg(sProcName, "calling setDefaultSubDescr(" + getSubLabel(nSubPtr) + ", #False)")
  setDefaultSubDescr(nSubPtr, #False)
  
  renumberSubNos(pCuePtr)
  
  nEditSubPtr = nSubPtr
  
  With aSub(nSubPtr)
    
    macSetSubTypeBooleansForSub(aSub(nSubPtr))
    
    Select pSubType
        
      Case "A"    ; Case "A"
        \nFirstAudIndex = -1
        
      Case "E"    ; Case "E"
        \nSubState = #SCS_CUE_READY
        \bMemoContinuous = grWEN\bLastMemoContinuous
        \nMemoDisplayTime = grWEN\nLastMemoDisplayTime
        \nMemoDisplayWidth = grWEN\nLastMemoDisplayWidth
        \nMemoDisplayHeight = grWEN\nLastMemoDisplayHeight
        \nMemoPageColor = grWEN\nLastMemoPageColor
        \nMemoTextBackColor = grWEN\nLastMemoTextBackColor
        \nMemoTextColor = grWEN\nLastMemoTextColor
        \nMemoScreen = grWEN\nLastMemoScreen
        \bMemoResizeFont = grWEN\bLastMemoResizeFont
        
      Case "F"    ; Case "F"
        \nFirstAudIndex = -1
        u4 = addAudToSub(pCuePtr, nSubPtr)
        If (gbInPaste = #False) And (gbInImportFromCueFile = #False) And (gbInImportAudioFiles = #False)
          WQF_displayFileInfo()
          ; debugMsg(sProcName, "calling drawScale(@grMG2)")
          drawScale(@grMG2)
          debugMsg(sProcName, "calling WQF_setViewControls()")
          WQF_setViewControls()
        EndIf
        postChangeAudL(u4, #False)
        
      Case "G"    ; Case "G"
        
      Case "I"    ; Case "I"
        \nFirstAudIndex = -1
        u4 = addAudToSub(pCuePtr, nSubPtr)
        postChangeAudL(u4, #False)
        
      Case "K"    ; Case "K"
        \nSubState = #SCS_CUE_READY
        If grProd\aLightingLogicalDevs(0)\nDevType <> #SCS_DEVTYPE_NONE
          \sLTLogicalDev = grProd\aLightingLogicalDevs(0)\sLogicalDev
          \nLTDevType = grProd\aLightingLogicalDevs(0)\nDevType
        EndIf
        \nLTEntryType = DMX_getDefLTEntryType(@grProd)
        
      Case "L"    ; Case "L"
        ; \nLCAbsRel = gnPrevLCAbsRel
        \nLCAction = gnPrevLCAction
        Select \nLCAction
          Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
            \bSubTypeHasDevs = #False
          Default
            \bSubTypeHasDevs = #True
        EndSelect
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nSubPtr) + "\nLCAction=" + decodeLCAction(\nLCAction) + ", \bSubTypeHasDevs=" + strB(\bSubTypeHasDevs))
        
      Case "M"    ; Case "M"
        \nFirstAudIndex = -1
        
      Case "N"    ; Case "N"
        \nSubState = #SCS_CUE_READY
        
      Case "P"    ; Case "P"
        \nFirstAudIndex = -1
        
      Case "Q"    ; Case "Q"
        \nSubState = #SCS_CUE_READY
        \nCallCueAction = grWQQ\nLastCallCueAction
        
      Case "R"    ; Case "R"
        \bRPHideSCS = grEditMem\bLastRPHideSCS
        \bRPInvisible = grEditMem\bLastRPInvisible
        
      Case "S"    ; Case "S"
        bSFRCueFound = #False
        ; auto set SFR cue values if possible
        For i = pCuePtr To 1 Step -1
          If aCue(i)\bSubTypeF Or aCue(i)\bSubTypeAorP Or aCue(i)\bSubTypeI Or aCue(i)\bSubTypeK
            j = aCue(i)\nFirstSubIndex
            If j >= 0
              If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeI
                k = aSub(j)\nFirstAudIndex
                If k >= 0
                  If aAud(k)\nLinkedToAudPtr < 0
                    bSFRCueFound = #True
                    nSFRCueType = #SCS_SFR_CUE_SEL
                    sSFRCue = aCue(i)\sCue
                    If (aAud(k)\nMaxLoopInfo >= 0) And (aAud(k)\aLoopInfo(0)\nAbsLoopEnd > 0)
                      nSFRAction = #SCS_SFR_ACT_RELEASE
                    ElseIf aAud(k)\nFadeOutTime > 0
                      nSFRAction = #SCS_SFR_ACT_FADEOUT
                    Else
                      nSFRAction = #SCS_SFR_ACT_STOP
                    EndIf
                  EndIf
                EndIf
              ElseIf aSub(j)\bSubTypeAorP
                bSFRCueFound = #True
                nSFRCueType = #SCS_SFR_CUE_SEL
                sSFRCue = aCue(i)\sCue
                If aSub(j)\nPLFadeOutTime > 0
                  nSFRAction = #SCS_SFR_ACT_FADEOUT
                Else
                  nSFRAction = #SCS_SFR_ACT_STOP
                EndIf
              ElseIf aSub(j)\bSubTypeK
                If aSub(j)\bChase
                  bSFRCueFound = #True
                  nSFRCueType = #SCS_SFR_CUE_SEL
                  sSFRCue = aCue(i)\sCue
                  nSFRAction = #SCS_SFR_ACT_STOPCHASE
                EndIf
              EndIf
            EndIf
            If bSFRCueFound
              Break
            EndIf
          EndIf
        Next i
        If bSFRCueFound
          \nSFRCueType[0] = nSFRCueType
          \sSFRCue[0] = sSFRCue
          \nSFRAction[0] = nSFRAction
          Select nSFRAction
            Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB, #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT
              If \nSFRTimeOverride < 0
                \nSFRTimeOverride = grProd\nDefSFRTimeOverride
              EndIf
          EndSelect
        EndIf
        
      Case "T"    ; Case "T"
        
      Case "U"    ; Case "U"
        If gnLastMTCType
          \nMTCType = gnLastMTCType
        Else
          \nMTCType = getDefaultMTCType()
        EndIf
        \nMTCFrameRate = gnLastMTCFrameRate
        \nMTCPreRoll = gnLastMTCPreRoll
        
    EndSelect
    
    postChangeSubL(u2, #False, nSubPtr, -1, "Add Sub-Cue " + \sSubLabel)
    
    loadCueMarkerArrays()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure autoSetNodeExpanded(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, bNodeExpanded

  If pCuePtr >= 0
    bNodeExpanded = aCue(pCuePtr)\bNodeExpanded     ; current state
    j = aCue(pCuePtr)\nFirstSubIndex
    If j >= 0
      If aSub(j)\nNextSubIndex >= 0
        ; at least two sub-cues
        bNodeExpanded = #True                    ; force node to be expanded
      EndIf
    EndIf
    aCue(pCuePtr)\bNodeExpanded = bNodeExpanded     ; set new state
  EndIf

EndProcedure

Procedure.s buildCueForCBO(pCuePtr, sLoopText.s="", bIncludePageNo=#False, bIncludeActivationMethod=#False)
  PROCNAMEC()
  Protected sBuild.s
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      sBuild = \sCue
      If bIncludeActivationMethod
        sBuild + " (" + decodeActivationMethodL(\nActivationMethod) + ")"
      EndIf
      sBuild + sLoopText + " "
      If bIncludePageNo And Trim(\sPageNo)
        sBuild + "[" + Trim(\sPageNo) + "] "
      EndIf
      sBuild + \sCueDescr
    EndWith
  EndIf
  ProcedureReturn sBuild
  
EndProcedure

Procedure.s buildSubCueForCBO(pSubPtr, sLoopText.s="")
  ; PROCNAMEC()
  If pSubPtr >= 0
    With aSub(pSubPtr)
      ProcedureReturn \sCue + " <" + \nSubNo + ">" + sLoopText + " " + \sSubDescr
    EndWith
  EndIf
EndProcedure

Procedure.s buildLCCueForCBO(pSubPtr)
  ; PROCNAMEC()
  ; nb originally written for level change cues but now also used by fmCopyProps
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If (\nPrevSubIndex = -1) And (\nNextSubIndex = -1)
        ProcedureReturn \sCue + "  " + aCue(\nCueIndex)\sCueDescr
      Else
        ProcedureReturn \sCue + " <" + \nSubNo + "> " + \sSubDescr
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure buildCtrlSendMessage(nCtrlSendIndex = -1)
  PROCNAMECS(nEditSubPtr)
  Protected nMyCtrlSendIndex
  Protected sMsg.s, n, sTmp.s
  Protected nTmp, nLSB, nMSB
  Protected bHTTPMsg, bOSCMsg, bDMXItem, bHideMidiMsg

  nMyCtrlSendIndex = nCtrlSendIndex
  If nMyCtrlSendIndex < 0
    nMyCtrlSendIndex = GGS(WQM\grdCtrlSends)
  EndIf
  
  If nMyCtrlSendIndex < 0
    SGT(WQM\txtMidiMsg, "")
    SGT(WQM\txtHTTPMsg, "")
    scsToolTip(WQM\txtHTTPMsg, "")
    SGT(WQM\txtOSCMsg, "")
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)\aCtrlSend[nMyCtrlSendIndex]
    ; debugMsg(sProcName, "\nDevType=" + decodeDevType(\nDevType) + ", \nMSMsgType=" + decodeMsgType(\nMSMsgType) + ", \nOSCCmdType=" + decodeOSCCmdType(\nOSCCmdType))
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT  ; #SCS_DEVTYPE_CS_MIDI_OUT
        Select \nMSMsgType
          Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128 ; Prog Change
            sMsg = "C"
            If \nMSChannel = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSChannel
              sMsg + "<channel>"
            Else
              sMsg + Right(decToHex2(\nMSChannel - 1), 1)
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam1
              sMsg + " <program_change_number>" + RTrim(" " + \sMSParam1)
            Else
              sMsg + " " + decToHex2(\nMSParam1)
            EndIf
            
          Case #SCS_MSGTYPE_CC ; Control Change
            sMsg = "B"
            If \nMSChannel = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSChannel
              sMsg + "<channel>"
            Else
              sMsg + Right(decToHex2(\nMSChannel - 1), 1)
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam1
              sMsg + " <control_number>" + RTrim(" " + \sMSParam1)
            Else
              sMsg + " " + decToHex2(\nMSParam1)
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam2
              sMsg + " <value>" + RTrim(" " + \sMSParam2)
            Else
              sMsg + " " + decToHex2(\nMSParam2)
            EndIf
            
          Case #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF ; Note ON, Note OFF
            If \nMSMsgType = #SCS_MSGTYPE_ON
              sMsg = "9" ; Note on
            Else
              sMsg = "8" ; Note off
            EndIf
            If \nMSChannel = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSChannel
              sMsg + "<channel>"
            Else
              sMsg + Right(decToHex2(\nMSChannel - 1), 1)
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam1
              sMsg + " <note_number>" + RTrim(" " + \sMSParam1)
            Else
              sMsg + " " + decToHex2(\nMSParam1)
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam2
              sMsg + " <velocity>" + RTrim(" " + \sMSParam2)
            Else
              sMsg + " " + decToHex2(\nMSParam2)
            EndIf
            
          Case #SCS_MSGTYPE_MSC ; MSC
            sMsg = "F0 7F"
            If \nMSChannel = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSChannel
              sMsg + " <device_id>"
            Else
              sMsg + " " + decToHex2(\nMSChannel - 1)
            EndIf
            sMsg + " 02"
            If \nMSParam1 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam1
              sMsg + " <command_format>"
            Else
              sMsg + " " + decToHex2(\nMSParam1)
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSParam2
              sMsg + " <command>"
            Else
              sMsg + " " + decToHex2(\nMSParam2)
            EndIf
            Select \nMSParam2
              Case $1, $2, $3, $5, $B, $10
                ; commands with q_number, q_list and q_path
                If \sMSQNumber <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQNumber
                  For n = 1 To Len(\sMSQNumber)
                    sTmp = Mid(\sMSQNumber, n, 1)
                    If sTmp = "."
                      sMsg + " 2E"
                    Else
                      sMsg + " " + stringToHexString(sTmp)
                    EndIf
                  Next n
                EndIf
                If (\sMSQList <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQList) Or (\sMSQPath <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQPath)
                  sMsg + " 00"
                  For n = 1 To Len(\sMSQList)
                    sTmp = Mid(\sMSQList, n, 1)
                    If sTmp = "."
                      sMsg + " 2E"
                    Else
                      sMsg + " " + stringToHexString(sTmp)
                    EndIf
                  Next n
                EndIf
                If \sMSQPath <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQPath
                  sMsg + " 00"
                  For n = 1 To Len(\sMSQPath)
                    sTmp = Mid(\sMSQPath, n, 1)
                    If sTmp = "."
                      sMsg + " 2E"
                    Else
                      sMsg + " " + stringToHexString(sTmp)
                    EndIf
                  Next n
                EndIf
                
              Case $6
                ; set command uses q_number and q_list for control number and control value
                If \sMSQNumber = grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQNumber
                  sMsg + " <control number>"
                Else
                  nTmp = Val(\sMSQNumber)
                  ; the LSB and MSB specified as 7-bit numbers
                  If nTmp < $80
                    nLSB = nTmp
                    nMSB = 0
                  Else
                    nMSB = Round(nTmp / $80, #PB_Round_Down)
                    nLSB = nTmp - (nMSB * $80)
                  EndIf
                  sMsg + " " + decToHex2(nLSB) + " " + decToHex2(nMSB)
                EndIf
                If \sMSQList = grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQList
                  sMsg + " <control value>"
                Else
                  nTmp = Val(\sMSQList)
                  ; the LSB and MSB specified as 7-bit numbers
                  If nTmp < $80
                    nLSB = nTmp
                    nMSB = 0
                  Else
                    nMSB = Round(nTmp / $80, #PB_Round_Down)
                    nLSB = nTmp - (nMSB * $80)
                  EndIf
                  sMsg + " " + decToHex2(nLSB) + " " + decToHex2(nMSB)
                EndIf
                
              Case $7
                ; command with macro number
                If \nMSMacro = grSubDef\aCtrlSend[nMyCtrlSendIndex]\nMSMacro
                  sMsg + " <macro number>"
                Else
                  sMsg + " " + decToHex2(\nMSMacro)
                EndIf
                
              Case $1B, $1C
                If (\sMSQList <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQList)
                  sMsg + " 00"
                  For n = 1 To Len(\sMSQList)
                    sTmp = Mid(\sMSQList, n, 1)
                    If sTmp = "."
                      sMsg + " 2E"
                    Else
                      sMsg + " " + stringToHexString(sTmp)
                    EndIf
                  Next n
                EndIf
                
              Case $1D, $1E
                If (\sMSQPath <> grSubDef\aCtrlSend[nMyCtrlSendIndex]\sMSQPath)
                  sMsg + " 00"
                  For n = 1 To Len(\sMSQPath)
                    sTmp = Mid(\sMSQPath, n, 1)
                    If sTmp = "."
                      sMsg + " 2E"
                    Else
                      sMsg + " " + stringToHexString(sTmp)
                    EndIf
                  Next n
                EndIf
                
              Default
                ; no extra info or unsupported
                
            EndSelect
            sMsg + " F7"
            
          Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
            sMsg = buildNRPNSendString(@aSub(nEditSubPtr)\aCtrlSend[nMyCtrlSendIndex])
            ; debugMsg(sProcName, "buildNRPNSendString(@aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + nMyCtrlSendIndex + "]) returned " + #DQUOTE$ + sMsg + #DQUOTE$)
            
          Case #SCS_MSGTYPE_FREE   ; MIDI Free Format
            sMsg = \sEnteredString
            
          Case #SCS_MSGTYPE_SCRIBBLE_STRIP
            bHideMidiMsg = #True
            
          Default
debugMsg0(sProcName, "\nRemDevMsgType=" + \nRemDevMsgType + ", \nRemDevId=" + \nRemDevId)
            If \nRemDevMsgType > 0
              bHideMidiMsg = #True
            EndIf
            
        EndSelect
        ; debugMsg(sProcName, "\nMSMsgType=" + decodeMsgType(\nMSMsgType) + ", sMsg=" + sMsg)
        
      Case #SCS_DEVTYPE_CS_RS232_OUT   ; #SCS_DEVTYPE_CS_RS232_OUT
        sMsg = buildSendString(nEditSubPtr, nMyCtrlSendIndex)
        
      Case #SCS_DEVTYPE_CS_NETWORK_OUT  ; #SCS_DEVTYPE_CS_NETWORK_OUT
        sMsg = buildNetworkSendString(nEditSubPtr, nMyCtrlSendIndex)
        ; debugMsg0(sProcName, "\nRemDevMsgType=" + \nRemDevMsgType + ", \nRemDevId=" + \nRemDevId)
        If \nRemDevMsgType > 0
          bHideMidiMsg = #True
        ElseIf \bIsOSC
          bOSCMsg = #True
        EndIf
        
      Case #SCS_DEVTYPE_LT_DMX_OUT
        sMsg = DMX_buildDMXValuesString(nEditSubPtr)
        bDMXItem = #True
        
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
        sMsg = buildHTTPSendString(nEditSubPtr, nMyCtrlSendIndex)
        bHTTPMsg = #True
        
    EndSelect
    
    ; debugMsg(sProcName, "nMyCtrlSendIndex=" + nMyCtrlSendIndex + ", sMsg=" + sMsg)
    If \bRS232Send
      debugMsg(sProcName, "\sSendString=" + ReplaceString(\sSendString, Chr($D), "<cr>"))
    EndIf
    
  EndWith
  
  With WQM
    If bHTTPMsg
      SGT(\txtHTTPMsg, sMsg)
      scsToolTip(WQM\txtHTTPMsg, sMsg)
      setVisible(\cntMidiMsg, #False)
      setVisible(\cntOSCMsg, #False)
      setVisible(\cntHTTP1, #True)
      setVisible(\cntHTTP2, #True)
    ElseIf bOSCMsg
      SGT(\txtOSCMsg, sMsg)
      setVisible(\cntMidiMsg, #False)
      setVisible(\cntHTTP1, #False)
      setVisible(\cntHTTP2, #False)
      setVisible(\cntOSCMsg, #True)
    ElseIf bHideMidiMsg
      setVisible(\cntMidiMsg, #False)
      setVisible(\cntHTTP1, #False)
      setVisible(\cntHTTP2, #False)
      setVisible(\cntOSCMsg, #False)
    Else
      ; MIDI, RS232, non-OSC-network, etc
      SGT(\txtMidiMsg, sMsg)
      setVisible(\cntOSCMsg, #False)
      setVisible(\cntHTTP1, #False)
      setVisible(\cntHTTP2, #False)
      setVisible(\cntMidiMsg, #True)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure calcPLTestTime(pSubPtr)
  PROCNAMECS(pSubPtr)

  ; !!!! SEE ALSO calcPLUnplayedFilesTime

  Protected nTestTime, nTmpTime, k
  Protected nPrevTransType
  Protected nPrevTransTime, nPrevFadeOutTime

  debugMsg(sProcName, #SCS_START + ", gnPLTestMode=" + Str(gnPLTestMode))
  
  If aSub(pSubPtr)\bSubTypeM
    ProcedureReturn
  EndIf
  
  If (gnPLTestMode = #SCS_PLTESTMODE_HIGHLIGHTED_FILE) And (gbEditHasFocus)
    If nEditAudPtr >= 0
      nTestTime = aAud(nEditAudPtr)\nCueDuration
    EndIf
  Else
    If (aSub(pSubPtr)\nSubState >= #SCS_CUE_READY) And (aSub(pSubPtr)\nSubState <= #SCS_CUE_COMPLETED)
      k = aSub(pSubPtr)\nFirstPlayIndex
      ; debugMsg(sProcName, "k=" + k)
      While k >= 0
        With aAud(k)
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nCueDuration=" + \nCueDuration)
          If \nCueDuration = #SCS_CONTINUOUS_LENGTH
            nTestTime = #SCS_CONTINUOUS_LENGTH
            Break
          EndIf
          ; round duration to hundredths of seconds so times add up correctly
          nTmpTime = (Round(\nCueDuration / 10, #PB_Round_Nearest) * 10)
          If gnPLFirstAndLastTime = -1
            nTestTime + nTmpTime
          ElseIf nTmpTime > (gnPLFirstAndLastTime + gnPLFirstAndLastTime)
            nTestTime + gnPLFirstAndLastTime + gnPLFirstAndLastTime
          Else
            nTestTime + nTmpTime
          EndIf
          Select nPrevTransType
            Case #SCS_TRANS_XFADE
              nTestTime - nPrevFadeOutTime
            Case #SCS_TRANS_MIX
              nTestTime - nPrevTransTime
            Case #SCS_TRANS_WAIT
              nTestTime + nPrevTransTime
          EndSelect
          nPrevTransType = \nPLTransType
          nPrevTransTime = \nPLTransTime
          nPrevFadeOutTime = \nFadeOutTime
          If (gnPLFirstAndLastTime <> -1) And (nPrevFadeOutTime > gnPLFirstAndLastTime)
            nPrevFadeOutTime = gnPLFirstAndLastTime
          EndIf
          k = \nNextPlayIndex
        EndWith
      Wend
      
      If nTestTime <> #SCS_CONTINUOUS_LENGTH
        If aSub(pSubPtr)\bPLRepeat
          Select nPrevTransType
            Case #SCS_TRANS_XFADE
              nTestTime - nPrevFadeOutTime
            Case #SCS_TRANS_MIX
              nTestTime - nPrevTransTime
            Case #SCS_TRANS_WAIT
              nTestTime + nPrevTransTime
          EndSelect
        EndIf
      EndIf
    EndIf
    
  EndIf

  aSub(pSubPtr)\nPLTestTime = nTestTime
  Select nTestTime
    Case #SCS_CONTINUOUS_END_AT, #SCS_CONTINUOUS_LENGTH
      debugMsg(sProcName, "nPLTestTime=" + aSub(pSubPtr)\nPLTestTime)
    Default
      debugMsg(sProcName, "nPLTestTime=" + ttszt(aSub(pSubPtr)\nPLTestTime))
  EndSelect

EndProcedure

Procedure callEditor(pCuePtr=-1, bCalledFromDevMapMenu=#False)
  PROCNAMEC()
  Protected nCurrentCue, nRow
  Protected n
  Protected bLockedMutex
  Protected bCueListMutexLockedByCaller
  Protected nTmpLength
  
  debugMsg(sProcName, #SCS_START + ", pCuePtr=" + pCuePtr + "(" + getCueLabel(pCuePtr) + "), bCalledFromDevMapMenu=" + strB(bCalledFromDevMapMenu))
  
  gbCallEditor = #False
  
  If grLicInfo\bPlayOnly
    ; shouldn't get here, but test included in case we do
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
  THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
  
  debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), gnCueListMutexLockThread=" + gnCueListMutexLockThread + ", gnThreadNo=" + gnThreadNo +
                       ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) + ", gnCueListMutexLockNo=" + gnCueListMutexLockNo + ", gnLabel=" + gnLabel)
  LockCueListMutex(815)
  debugMsg(sProcName, "LockCueListMutex(815)")
  bCueListMutexLockedByCaller = #True
  
  If grEditingOptions\bCheckMainLostFocusWhenEditorOpen
    ; added 14Mar2019 11.8.0.2cc following request from Scott Siegwald, 6Mar2019
    gbCheckForLostFocus = #True
  Else
    gbCheckForLostFocus = #False ; if editing then do not check for lost focus
  EndIf
  gbStartingEditor = #True
  
  If IsWindow(#WED) = #False
    WED_Form_Load()
    gbForceStartEditor = #True ; force startEditor() to be called so the newly-created or re-created form is properly populated
  EndIf
  
  ; added 7Oct2019 11.8.2as following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
  ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
  If GetWindowState(#WED) = #PB_Window_Minimize
    debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
    SetWindowState(#WED, #PB_Window_Normal)
    debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
  EndIf
  ; end added 7Oct2019 11.8.2as
  
  SAW(#WED)
  
  CompilerIf #c_include_tvg
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      debugMsg(sProcName, "calling createPreviewTVGControlsIfReqd()")
      createPreviewTVGControlsIfReqd()
    EndIf
  CompilerEndIf
  
  If bCalledFromDevMapMenu
    gbGoToProdPropDevices = #True
    debugMsg(sProcName, "gbGoToProdPropDevices=" + strB(gbGoToProdPropDevices))
  EndIf
  
  If (gbEditing) And (gbForceStartEditor = #False)
    setWindowVisible(#WED, #True)
    
    gbSkipValidation = #False
    If gbGoToProdPropDevices
      debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
      WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller)
      If grCED\bChangeDevMap
        WEP_setCboDevMapForChange()
      EndIf
    Else
      If (pCuePtr < 0) Or (pCuePtr = gnCueEnd)
        debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
        WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller)
      Else
        debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ", #True)")
        WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller, #True)  ; #True = suppress node display
        debugMsg(sProcName, "calling WED_publicNodeClick(" + aCue(pCuePtr)\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
        WED_publicNodeClick(aCue(pCuePtr)\nNodeKey, bCueListMutexLockedByCaller)
      EndIf
    EndIf
    
  Else
    setToolBarBtnEnabled(#SCS_TBMB_EDITOR, #False)
    setMouseCursorBusy()
    If bCalledFromDevMapMenu
      nCurrentCue = -1
    Else
      nCurrentCue = pCuePtr
      If nCurrentCue = -1
        nCurrentCue = gnHighlightedCue
        If nCurrentCue = -1
          nRow = GGS(WMN\grdCues)
          If nRow >= 0
            nCurrentCue = WMN_getCuePtrForRowNo(nRow)
          EndIf
        EndIf
      EndIf
      debugMsg(sProcName, "nCurrentCue=" + getCueLabel(nCurrentCue))
      If (nCurrentCue <= 0) Or (nCurrentCue >= gnCueEnd)
        nCurrentCue = -1
      EndIf
    EndIf
    debugMsg(sProcName, "calling startEditor(" + getCueLabel(nCurrentCue) + ", #True)")
    startEditor(nCurrentCue, #True)  ; startEditor
    gbForceStartEditor = #False
    setToolBarBtnEnabled(#SCS_TBMB_EDITOR, #True)
    setWindowVisible(#WED, #True)
    setMouseCursorNormal()
  EndIf
  
  gbStartingEditor = #False
  
  UnlockCueListMutex()
  bCueListMutexLockedByCaller = #False
  
  debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  SAW(#WED)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure changeDevLogicalName(sProdLogicalDevOld.s, sProdLogicalDevNew.s)
  PROCNAMEC()
  ; currently only used in undo/redo
  Protected d, j, k

  debugMsg(sProcName, #SCS_START + ", sProdLogicalDevOld=" + sProdLogicalDevOld + ", sProdLogicalDevNew=" + sProdLogicalDevNew)
  
  If Len(sProdLogicalDevOld) = 0
    ProcedureReturn
  EndIf

  With grProd
    ; change name if used for preview device
    If \sPreviewDevice = sProdLogicalDevOld
      \sPreviewDevice = sProdLogicalDevNew
    EndIf
  EndWith

  ; change name where used in playlist sub cues
  For j = 1 To gnLastSub
    With aSub(j)
      If \bExists
        If \bSubTypeP
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \sPLLogicalDev[d] = sProdLogicalDevOld
              \sPLLogicalDev[d] = sProdLogicalDevNew
            EndIf
          Next d
        EndIf
      EndIf
    EndWith
  Next j

  ; change name where used in audio file auds
  For k = 1 To gnLastAud
    With aAud(k)
      If (\bExists) And (\bAudTypeA Or \bAudTypeF Or \bAudTypeI Or \bAudTypeP)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \sLogicalDev[d] = sProdLogicalDevOld
            \sLogicalDev[d] = sProdLogicalDevNew
          EndIf
        Next d
      EndIf
    EndWith
  Next k

  gbDoProdDevsForA = #True
  gbDoProdDevsForF = #True
  gbDoProdDevsForI = #True
  gbDoProdDevsForK = #True
  gbDoProdDevsForP = #True

EndProcedure

Procedure setUnsavedChanges(bUnsavedChanges=#True)
  PROCNAMEC()
  
  If gbUnsavedChanges <> bUnsavedChanges
    gbUnsavedChanges = bUnsavedChanges
    If IsWindow(#WMN)
      WMN_setWindowTitle()
    EndIf
    If IsWindow(#WED)
      WED_setWindowTitle()
    EndIf
  EndIf
  
EndProcedure

Procedure checkDataChanged(bCreateProdDatabase, bUnloadingMain=#False)
  PROCNAMEC()
  Protected nResponse, bChangesApplied, bCancel, nReasonsForSaveExcludingEditorGraphsEtc
  Protected bEditorLoaded, bHoldEditing, bHoldEditHasFocus
  Protected sMsg.s
  Protected bSkipCreateProdDatabase

  debugMsg(sProcName, #SCS_START + ", bCreateProdDatabase=" + strB(bCreateProdDatabase) + ", bUnloadingMain=" + strB(bUnloadingMain) +
                      ", gbMainSaveEnabled=" + strB(gbMainSaveEnabled) + ", gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
  
  If gbMainSaveEnabled
    
    nReasonsForSaveExcludingEditorGraphsEtc = countReasonsForSave(#True, #True)
    If (nReasonsForSaveExcludingEditorGraphsEtc > 0) Or (gnUnsavedEditorGraphs > 0) Or (gbUnsavedPlaylistOrderInfo)
      ; the following modified 13Nov2017 11.7.0ax so that if the only reason for save being enabled is that there is unsaved audio graph data then the wrning message is NOT displayed
      ; also, even if there are other reasons for save being enabled, this procedure will exclude the message part regarding unsaved audio graph data
      ; this is because this warning message has caused some confusion with users, and is really not necessary as it only updates the .scsdb file, not the .scs11 file
      If nReasonsForSaveExcludingEditorGraphsEtc > 0
        sMsg = listReasonsForSave(#True, #True, #True)
        If sMsg
          sMsg + Chr(10) + Chr(10) 
        EndIf
        sMsg + Lang("Common", "SaveChanges")
        debugMsg(sProcName, "sMsg=" + sMsg)
        nResponse = scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_YesNoCancel | #MB_ICONQUESTION)
      ElseIf (gnUnsavedEditorGraphs > 0) Or (gbUnsavedPlaylistOrderInfo)
        nResponse = #PB_MessageRequester_Yes
      EndIf
      Select nResponse
        Case #PB_MessageRequester_Yes
          debugMsg(sProcName, "nResponse=Yes")
          bHoldEditing = gbEditing
          bHoldEditHasFocus = gbEditHasFocus
          If IsWindow(#WED)
            bEditorLoaded = #True
          Else
            callEditor() ; if fmEditor not currently loaded then loads it and starts editor
          EndIf
          bChangesApplied = WED_applyChangesWrapper()
          debugMsg(sProcName, "WED_applyChangesWrapper() returned " + strB(bChangesApplied))
          If bChangesApplied = #False
            ; probably not applied because of validation failure
            bCancel = #True
          Else
            If bEditorLoaded = #False
              If IsWindow(#WED)
                setWindowVisible(#WED, #False)
                gbEditorFormLoaded = #False
                gbInNodeClick = #False
              EndIf
            ElseIf bHoldEditing = #False
              If IsWindow(#WED)
                setWindowVisible(#WED, #False)
              EndIf
            EndIf
            If gbEditing <> bHoldEditing ; test added so that debugMsg() only called if gbEditing changed
              gbEditing = bHoldEditing
              debugMsg(sProcName, "gbEditing=" + strB(gbEditing))
            EndIf
            gbEditHasFocus = bHoldEditHasFocus
          EndIf
          
        Case #PB_MessageRequester_No
          debugMsg(sProcName, "nResponse=No")
          ; do not save; no need to rollback as we are either closing #SCS, opening another cue file, or starting a new cue file
          ;Call rollbackChanges
          bSkipCreateProdDatabase = #True
          
        Case #PB_MessageRequester_Cancel
          debugMsg(sProcName, "nResponse=Cancel")
          bCancel = #True
          bSkipCreateProdDatabase = #True
          
      EndSelect
      
    EndIf
    
  EndIf
  
  debugMsg(sProcName, "gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo) + ", bCreateProdDatabase=" + strB(bCreateProdDatabase) + ", bSkipCreateProdDatabase=" + strB(bSkipCreateProdDatabase))
  If (bCreateProdDatabase) And (bSkipCreateProdDatabase = #False)
    If grTempDB\bTempDatabaseChanged Or gbFileStatsChanged Or gbUnsavedPlaylistOrderInfo
      debugMsg(sProcName, "calling createProdDatabase()")
      createProdDatabase()
    EndIf
  EndIf
  
  If bCancel = #False
    killRecoveryFile()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bCancel))
  ProcedureReturn bCancel
EndProcedure

Procedure clearCtrlSendItemIfNotBuilt(nCtrlSendIndex)
  PROCNAMECS(nEditSubPtr)
  Protected bClear, nPhysicalDevPtr
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "gbNewCtrlSendItem(" + nCtrlSendIndex + ")=" + strB(gbNewCtrlSendItem(nCtrlSendIndex)))
  If gbNewCtrlSendItem(nCtrlSendIndex) = #False
    ProcedureReturn #False
  EndIf
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex]
      
      While #True   ; While 'loop' established so we can use 'Break' to jump to the end (rather than use 'GoTo...')
        
        bClear = #True
        
        If \nDevType <> gaCtrlSendItemB4Change(nCtrlSendIndex)\nDevType
          bClear = #False
          Break
        EndIf
        
        If \sCSLogicalDev <> gaCtrlSendItemB4Change(nCtrlSendIndex)\sCSLogicalDev
          bClear = #False
          Break
        EndIf
        
        If \sCSItemDesc <> gaCtrlSendItemB4Change(nCtrlSendIndex)\sCSItemDesc
          bClear = #False
          Break
        EndIf
        
        Select \nDevType
          Case #SCS_DEVTYPE_CS_MIDI_OUT
            If (\nMSMsgType <> gaCtrlSendItemB4Change(nCtrlSendIndex)\nMSMsgType) Or (\nMSChannel <> gaCtrlSendItemB4Change(nCtrlSendIndex)\nMSChannel)
              bClear = #False
              Break
            EndIf
            ; debugMsg0(sProcName, "nCtrlSendIndex=" + nCtrlSendIndex + ", \nMSMsgType=" + \nMSMsgType + ", \nRemDevMsgType=" + \nRemDevMsgType)
            If \nMSMsgType <> #SCS_MSGTYPE_NONE
              Select \nMSMsgType
                Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128 ; Program Change
                  If (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or \sMSParam1
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_CC ; Control Change
                  If (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or (\nMSParam2 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2) Or \sMSParam1 Or \sMSParam2
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_ON   ; Note ON
                  If (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or \sMSParam1
                    bClear = #False
                  EndIf
                  If \sMSParam2
                    bClear = #False
                  ElseIf (\nMSParam2 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2) And (\nMSParam2 <> 127)  ; 127 is default velocity for note on
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_OFF  ; Note OFF
                  If (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or \sMSParam1
                    bClear = #False
                  EndIf
                  If \sMSParam2
                    bClear = #False
                  ElseIf (\nMSParam2 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2) And (\nMSParam2 <> 0)    ; 0 is default velocity for note off
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_MSC ; MSC
                  If (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or (\nMSParam2 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2)
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
                  If \sMSParam1 Or \sMSParam2 Or \sMSParam3 Or \sMSParam4
                    bClear = #False
                  ElseIf (\nMSParam1 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam1) Or (\nMSParam2 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam2) Or
                     (\nMSParam3 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam3) Or (\nMSParam3 <> grSubDef\aCtrlSend[nCtrlSendIndex]\nMSParam3)
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_FREE ; MIDI Free Format
                  If Trim(\sEnteredString)
                    bClear = #False
                  EndIf
                  
                Case #SCS_MSGTYPE_FILE
                  If \nAudPtr >= 0
                    bClear = #False
                  EndIf
                  
              EndSelect
            EndIf
            
            If \nRemDevMsgType > 0
              If Trim(\sRemDevValue) Or Trim(\sRemDevLevel)
                bClear = #False
              EndIf
            EndIf
            
            If bClear = #False
              Break
            EndIf
            
          Case #SCS_DEVTYPE_CS_RS232_OUT
            If (\nEntryMode <> gaCtrlSendItemB4Change(nCtrlSendIndex)\nEntryMode) Or
               (\bAddCR <> gaCtrlSendItemB4Change(nCtrlSendIndex)\bAddCR) Or
               (\bAddLF <> gaCtrlSendItemB4Change(nCtrlSendIndex)\bAddLF)
              bClear = #False
              Break
            EndIf 
            If Trim(\sEnteredString)
              bClear = #False
              Break
            EndIf
            
          Case #SCS_DEVTYPE_CS_NETWORK_OUT
            If \bIsOSC
              Select \nOSCCmdType
                Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET,
                     #SCS_CS_OSC_MUTE_FIRST To #SCS_CS_OSC_MUTE_LAST,
                     #SCS_CS_OSC_FREEFORMAT
                  If (\sOSCItemString) Or (\bOSCItemPlaceHolder)
                    bClear = #False
                  EndIf
                Case #SCS_CS_OSC_TC_GO, #SCS_CS_OSC_TC_BACK
                  bClear = #False
                Case #SCS_CS_OSC_TC_JUMP
                  If \sOSCItemString
                    bClear = #False
                  EndIf
              EndSelect
            Else
              If (\nEntryMode <> gaCtrlSendItemB4Change(nCtrlSendIndex)\nEntryMode) Or
                 (\bAddCR <> gaCtrlSendItemB4Change(nCtrlSendIndex)\bAddCR) Or
                 (\bAddLF <> gaCtrlSendItemB4Change(nCtrlSendIndex)\bAddLF)
                bClear = #False
                Break
              EndIf
            EndIf
            If Trim(\sEnteredString)
              bClear = #False
              Break
            EndIf
            
          Case #SCS_DEVTYPE_LT_DMX_OUT
            If \sSendString
              bClear = #False
              Break
            EndIf
            
          Case #SCS_DEVTYPE_CS_HTTP_REQUEST
            bClear = #False
            Break
            
        EndSelect
        
        Break ; always exit - see comment at start of While loop
      Wend
      
    EndWith
    
    If bClear
      debugMsg(sProcName, "clearing item " + nCtrlSendIndex)
      aSub(nEditSubPtr)\aCtrlSend[nCtrlSendIndex] = grSubDef\aCtrlSend[nCtrlSendIndex]
      buildCtrlSendMessage(nCtrlSendIndex)
      buildDisplayInfoForCtrlSend(@aSub(nEditSubPtr), nCtrlSendIndex)
      updateCtrlSendGrid(nCtrlSendIndex)
    EndIf
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  ProcedureReturn bClear
  
EndProcedure

Procedure closeEditor()
  PROCNAMEC()
  Protected bCancel, bCuesChanged
  Protected d, i, j, k
  Protected nAudPtr, nCuePos
  Protected nCompletedCuePtr
  Protected nVideoIndex
  Protected nMainVideoAudPtr
  Protected nMainVideoAudState
  Protected nMainPictureAudState
  Protected nRow, nCol
  
  debugMsg(sProcName, #SCS_START + ", gnCueToGo=" + getCueLabel(gnCueToGo) + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue))
  
  grCED\bClosingEditor = #True
  
  nCompletedCuePtr = -1
  
  If grTestTone\bPlayingTestTone
    stopTestTone()
  EndIf
  
  If grTestLiveInput\bRunningTestLiveInput
    debugMsg(sProcName, "calling stopTestLiveInput()")
    stopTestLiveInput()
  EndIf
  
  CompilerIf #c_vMix_in_video_cues
    vMix_RemoveTargetPInput()
  CompilerEndIf
  
  If IsWindow(#WED)
    setWindowVisible(#WED, #False)
  EndIf
  
  debugMsg(sProcName, "calling setCueBassDevsAndMidiPortNos")
  bCuesChanged = setCueBassDevsAndMidiPortNos()
  debugMsg(sProcName, "bCuesChanged=" + strB(bCuesChanged))
  
  gbEditing = #False
  debugMsg(sProcName, "gbEditing=" + strB(gbEditing))
  gbEditHasFocus = #False
  gbCheckForLostFocus = #True
  
  If grWQE\nPreviewMemoScreen > 0
    WQE_closeMemoPreviewIfReqd()
  EndIf
  
  If gnPreviewOnOutputScreenNo > 0
    WQA_clearPreviewOnOutputScreen(gnPreviewOnOutputScreenNo)
    gnPreviewOnOutputScreenNo = 0
  EndIf
  
  For k = 1 To gnLastAud
    With aAud(k)
      If \bExists
        ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState))
        If (\nAudState = #SCS_CUE_READY) Or (\nAudState = #SCS_CUE_PL_READY)
          For d = \nFirstSoundingDev To \nLastSoundingDev
            If \nCurrFadeInTime > 0
              \fCueVolNow[d] = #SCS_MINVOLUME_SINGLE
            Else
              \fCueVolNow[d] = \fBVLevel[d]
            EndIf
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fCueVolNow[" + d + "]=" + formatLevel(\fCueVolNow[d]))
            \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
            \fCueTotalVolNow[d] = \fCueVolNow[d]
            CompilerIf #cTraceCueTotalVolNow
              debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(k)\fCueTotalVolNow[d]))
            CompilerEndIf
            \fCuePanNow[d] = \fPan[d]
          Next d
        EndIf
        
        If (\nAudState < #SCS_CUE_FADING_IN) Or (\nAudState > #SCS_CUE_FADING_OUT)
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bResetFilePosToStartAtInMain=" + strB(aAud(k)\bResetFilePosToStartAtInMain))
          If \bResetFilePosToStartAtInMain
            \nCuePosAtLoopStart = 0    ; must be cleared before calling reposAuds (added 27Nov2015 11.4.1.2p to fix bug reported by Philipp about loop being released immediately on playing after closing editor)
            debugMsg(sProcName, "calling reposAuds(" + getAudLabel(k) + ", " + \nAbsStartAt + ")")
            reposAuds(k, \nAbsStartAt)
            \bResetFilePosToStartAtInMain = #False
            ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bResetFilePosToStartAtInMain=" + strB(aAud(k)\bResetFilePosToStartAtInMain))
          EndIf
        EndIf
        
      EndIf
    EndWith
  Next k
  
  debugMsg(sProcName, "calling setGaplessInfo()")
  setGaplessInfo()
  ; see also call to recreateTimeLinesWhereReqd(gnCueToGo) after call to setCueToGo()
  
  setTimeBasedCues()
  debugMsg(sProcName, "calling resyncLinkedAuds")
  resyncLinkedAuds()   ; must do this AFTER setting gbEditing False
  debugMsg(sProcName, "returned from resyncLinkedAuds")
  
  For i = 1 To gnLastCue
    If aCue(i)\nActivationMethodReqd <> #SCS_ACMETH_TIME
      If aCue(i)\bCueCompletedBeforeOpenedInEditor
        debugMsg(sProcName, "calling stopCue(" + getCueLabel(i) + ", 'ALL', #False) because \bCueCompletedBeforeOpenedInEditor=True")
        stopCue(i, "ALL", #False)
        debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ", #False, #True) because \bCueCompletedBeforeOpenedInEditor=True")
        closeCue(i, #False, #True)
        debugMsg(sProcName, "setting aCue(" + getCueLabel(i) + ")\bCueCompletedBeforeOpenedInEditor=False")
        aCue(i)\bCueCompletedBeforeOpenedInEditor = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          aSub(j)\nSubStateBeforeOpenedInEditor = aSub(j)\nSubState
          debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\bSubCompletedBeforeOpenedInEditor=False")
          aSub(j)\bSubCompletedBeforeOpenedInEditor = #False
          If aSub(j)\bSubTypeHasAuds
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              aAud(k)\nAudState = #SCS_CUE_COMPLETED
              aAud(k)\bInLoopXFade = #False
              k = aAud(k)\nNextAudIndex
            Wend
          EndIf
          aSub(j)\nSubState = #SCS_CUE_COMPLETED
          aSub(j)\bStartedInEditor = #False
          debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState) + ", \bStartedInEditor=" + strB(aSub(j)\bStartedInEditor))
          j = aSub(j)\nNextSubIndex
        Wend
        aCue(i)\nCueState = #SCS_CUE_COMPLETED
        nCompletedCuePtr = i
      Else
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubCompletedBeforeOpenedInEditor
            debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ", #True, #True) because \bSubCompletedBeforeOpenedInEditor=True")
            closeSub(j, #True, #True)
            aSub(j)\nSubStateBeforeOpenedInEditor = aSub(j)\nSubState
            debugMsg(sProcName, "setting aSub(" + getSubLabel(j) + ")\bSubCompletedBeforeOpenedInEditor=False")
            aSub(j)\bSubCompletedBeforeOpenedInEditor = #False
            If aSub(j)\bSubTypeHasAuds
              k = aSub(j)\nFirstAudIndex
              While k >= 0
                aAud(k)\nAudState = #SCS_CUE_COMPLETED
                aAud(k)\bInLoopXFade = #False
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
            aSub(j)\nSubState = #SCS_CUE_COMPLETED
            aSub(j)\bStartedInEditor = #False
            debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState) + ", \bStartedInEditor=" + strB(aSub(j)\bStartedInEditor))
            nCompletedCuePtr = i
          ElseIf aSub(j)\bStartedInEditor
            If (aSub(j)\nSubState >= #SCS_CUE_FADING_IN) And (aSub(j)\nSubState < #SCS_CUE_COMPLETED)
              debugMsg(sProcName, "calling stopSub(" + aSub(j)\sSubLabel + ", 'ALL', #False, #True)")
              stopSub(j, "ALL", #False, #True)
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
  Next i
  
  debugMsg(sProcName, "nCompletedCuePtr=" + Str(nCompletedCuePtr))
  If nCompletedCuePtr <> -1
    debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
    gbCallLoadDispPanels = #True
    nRow = aCue(nCompletedCuePtr)\nGrdCuesRowNo
    If nRow >= 0
      WMN_setGrdCuesCellValue(nRow, #SCS_GRDCUES_CS, getCueStateForGrid(nCompletedCuePtr))
    EndIf
    colorLine(nCompletedCuePtr)
  EndIf
  
  nEditCuePtr = -1
  nEditSubPtr = -1
  setEditAudPtr(-1)
  
  For i = 1 To gnLastCue
    ; debugMsg(sProcName, ">>> aCue(" + getCueLabel(i) + ")\bCloseCueWhenLeavingEditor=" + strB(aCue(i)\bCloseCueWhenLeavingEditor))
    If aCue(i)\bCloseCueWhenLeavingEditor
      debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bCloseCueWhenLeavingEditor=" + strB(aCue(i)\bCloseCueWhenLeavingEditor))
      debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ")")
      closeCue(i)
    EndIf
  Next i
  
  CompilerIf #c_include_tvg
    freePreviewTVGControls()
  CompilerEndIf
  
  gnCallOpenNextCues = 1
  debugMsg(sProcName, "calling setCueToGo()")
  setCueToGo()
  
  gbCallSetNavigateButtons = #True
  gbCallLoadDispPanels = #True
  gqStopEverythingTime = 0        ; ensure time-based-cues not held up
  
  WQK_stopLiveDMXTestIfRunning()
  grWQK\bLiveDMXTest = #False ; turn off DMX live test
  grWQK\bSingleStep = #False ; turn off DMX single step live test
  
  If gbUseSMS
    debugMsg(sProcName, "calling buildGetSMSCurrInfoCommandStrings()")
    buildGetSMSCurrInfoCommandStrings()
  EndIf
  
  WCN_setLiveOnInds()
  
  CompilerIf #c_include_tvg
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
      debugMsgT(sProcName, "calling listTVGControls(#False)")
      listTVGControls(#False)
    EndIf
  CompilerEndIf
  
  If (grRAI\nStatus & 7) <> 0
    ; grRAI/nStatus contains at least one of #SCS_RAI_STATUS_FILE (1), #SCS_RAI_STATUS_PROD (2) or #SCS_RAI_STATUS_CUE (4)
    sendOSCStatus()
  EndIf
  
  listStreamStatuses()
  
  debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(#WMN)")
  SAW(#WMN)
  SAG(-1)
  gbCheckForLostFocus = #True
  
  THR_resumeAThread(#SCS_THREAD_CONTROL)
  
  grCED\bClosingEditor = #False
  logKeyEvent(#SCS_END + ", gnCueToGo=" + getCueLabel(gnCueToGo) + ", gnHighlightedCue=" + getCueLabel(gnHighlightedCue))
  
EndProcedure

Procedure copyCueOrSubToClipboard()
  PROCNAMEC()
  Protected d, j, k, j2, k2, n
  Protected sClipboardInfo.s
  
  debugMsg(sProcName, #SCS_START)
  
  gnClipCueCount = 0
  gnClipSubCount = 0
  gnClipAudCount = 0
  gbClipPopulated = #False
  gnClipCuePtr = -1
  sClipboardInfo = "Clipboard empty"

  ; pass 1: count cue, subs and auds
  ; --------------------------------
  If (gnSelectedNodeCuePtr >= 0) And (gnSelectedNodeSubPtr < 0)
    ; copying a complete cue to the clipboard
    gnClipCueCount + 1
    j = aCue(gnSelectedNodeCuePtr)\nFirstSubIndex
    While j >= 0
      gnClipSubCount + 1
      With aSub(j)
        If \bSubTypeHasAuds
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            gnClipAudCount + 1
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend

  ElseIf (gnSelectedNodeCuePtr >= 0) And (gnSelectedNodeSubPtr >= 0)
    ; copying a sub-cue to the clipboard
    gnClipSubCount + 1
    j = gnSelectedNodeSubPtr
    With aSub(j)
      If \bSubTypeHasAuds
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          gnClipAudCount + 1
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
    EndWith

  EndIf

  ReDim gaClipCue(gnClipCueCount)
  ReDim gaClipSub(gnClipSubCount)
  ReDim gaClipAud(gnClipAudCount)

  ; pass 2: copy cue, subs and auds
  ; -------------------------------
  j2 = -1
  k2 = -1

  If (gnSelectedNodeCuePtr >= 0) And (gnSelectedNodeSubPtr < 0)
    ; copying a complete cue to the clipboard
    gaClipCue(0) = aCue(gnSelectedNodeCuePtr)
    gbClipPopulated = #True
    gnClipCuePtr = gnSelectedNodeCuePtr
    With gaClipCue(0)
      sClipboardInfo = LangPars("WED", "CueInClipboard", \sCue + " (" + \sCueDescr + ")")
    EndWith
    j = aCue(gnSelectedNodeCuePtr)\nFirstSubIndex
    While j >= 0
      j2 + 1
      gaClipSub(j2) = aSub(j)
      With aSub(j)
        If \bSubTypeHasAuds
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            k2 + 1
            gaClipAud(k2) = aAud(k)
            debugMsg(sProcName, gaClipAud(k2)\sAudLabel + ", " + gaClipAud(k2)\sDBLevel[0] + ", " + formatLevel(gaClipAud(k2)\fBVLevel[0]))
            ; indicate aud info in clipboard as closed so paste will force an open
            gaClipAud(k2)\nFileState = #SCS_FILESTATE_CLOSED
            gaClipAud(k2)\nAudState = #SCS_CUE_NOT_LOADED
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              gaClipAud(k2)\nBassChannel[d] = grAudDef\nBassChannel[d]
            Next d
            clear_CueMarkerIdsEtc(@gaClipAud(k2))
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
    
  ElseIf (gnSelectedNodeCuePtr >= 0) And (gnSelectedNodeSubPtr >= 0)
    ; copying a sub-cue to the clipboard
    j2 + 1
    j = gnSelectedNodeSubPtr
    gaClipSub(j2) = aSub(j)
    gbClipPopulated = #True
    With gaClipSub(j2)
      sClipboardInfo = LangPars("WED", "SubInClipboard", \sCue + " <" + \nSubNo + "> (" + \sSubDescr + ")")
    EndWith
    With aSub(j)
      If \bSubTypeHasAuds
        k = \nFirstAudIndex
        While k >= 0
          k2 + 1
          gaClipAud(k2) = aAud(k)
          ; indicate aud info in clipboard as closed so paste will force an open
          gaClipAud(k2)\nFileState = #SCS_FILESTATE_CLOSED
          gaClipAud(k2)\nAudState = #SCS_CUE_NOT_LOADED
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            gaClipAud(k2)\nBassChannel[d] = grAudDef\nBassChannel[d]
          Next d
          clear_CueMarkerIdsEtc(@gaClipAud(k2))
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
    EndWith
    
  EndIf

  debugMsg(sProcName, "sClipboardInfo=" + sClipboardInfo)
  ; indicate on edit screen what is in clipboard
  SetGadgetText(WED\lblClipboardInfo, sClipboardInfo)
  WED_setTBTButtons()  ; turns on Paste
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createAudTypeP(sFileName.s)
  PROCNAMECA(nEditAudPtr)

  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      ; aSub(nEditSubPtr)\nAudCount + 1
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + aSub(nEditSubPtr)\nAudCount)
      ; \nAudNo = aSub(nEditSubPtr)\nAudCount
      ; debugMsg(sProcName, "nEditCuePtr=" + nEditCuePtr + ", nEditSubPtr=" + nEditSubPtr + ", nEditAudPtr=" + nEditAudPtr + ", \nAudNo=" + \nAudNo)
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
      \sFileExt = GetExtensionPart(\sFileName)
      \nFileFormat = getFileFormat(\sFileName)
      debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
      openMediaFile(nEditAudPtr, #True)
      setSyncPChanListForAud(nEditAudPtr)
      \sFileTitle = grFileInfo\sFileTitle
      debugMsg(sProcName, "nEditAudPtr=" + nEditAudPtr + ", \sStoredFileName=" + \sStoredFileName + ", nNodeKey=" + aCue(\nCueIndex)\nNodeKey)
      gsAudioFileDialogInitDir = GetPathPart(\sFileName)
      debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
      setDerivedAudFields(nEditAudPtr)
      CompilerIf #c_include_mygrid_for_playlists
        createWQPFile()
        WQPFile()\nAudPtr = nEditAudPtr
        WQPFile()\nFileNameLen = Len(\sFileName)
        WQPFile()\nFileId = rWQP\nFileId
        debugMsg(sProcName, "WQPFile()\nAudPtr=" + getAudLabel(WQPFile()\nAudPtr) + ", \nFileNameLen=" + WQPFile()\nFileNameLen + ", \nFileId=" + WQPFile()\nFileId)
      CompilerEndIf
    EndWith
  EndIf

EndProcedure

Procedure createAudTypeA(sFileName.s)
  PROCNAMECA(nEditAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      ; aSub(nEditSubPtr)\nAudCount + 1
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nAudCount=" + Str(aSub(nEditSubPtr)\nAudCount))
      ; \nAudNo = aSub(nEditSubPtr)\nAudCount
      ; debugMsg(sProcName, "nEditCuePtr=" + nEditCuePtr + ", nEditSubPtr=" + nEditSubPtr + ", nEditAudPtr=" + nEditAudPtr + ", \nAudNo=" + \nAudNo)
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
      \sFileExt = GetExtensionPart(\sFileName)
      \nFileFormat = getFileFormat(\sFileName)
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        \bContinuous = grLastPicInfo\bLastPicContinuous
        \bLogo = #False
        \nEndAt = grLastPicInfo\nLastPicEndAt
      EndIf
      debugMsg(sProcName, "calling getVideoInfoForAud(" + getAudLabel(nEditAudPtr) + ")")
      getVideoInfoForAud(nEditAudPtr)
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure createCueOrSubTypeF(sFileName.s)
  PROCNAMEC()
  Protected u1, u2, u3
  Protected nFirstSubIndex
  ; MUST be called from addCueWithSubCue() - or else it will be necessary to reinstate preChangeCue and postChangeCue etc
  
  debugMsg(sProcName, #SCS_START + ", sFileName=" + sFileName + ", nEditCuePtr=" + nEditCuePtr + ", nEditSubPtr=" + nEditSubPtr + ", nEditAudPtr=" + nEditAudPtr)
  
  ; addCueWithSubCue("F", #False)
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      ; u1 = preChangeCueS(aCue(\nCueIndex)\sCueDescr, "change", \nCueIndex)
      u2 = preChangeSubS(aSub(\nSubIndex)\sSubDescr, "change", \nSubIndex)
      u3 = preChangeAudS(\sFileName, GetGadgetText(WQF\lblFileName))
      
      \sFileName = sFileName
      If sFileName = grText\sTextPlaceHolder
        \bAudPlaceHolder = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bAudPlaceHolder=" + strB(\bAudPlaceHolder))
        \sStoredFileName = sFileName
        \sFileTitle = removeNonPrintingChars(sFileName)
      Else
        \bAudPlaceHolder = #False
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\bAudPlaceHolder=" + strB(\bAudPlaceHolder))
        \sStoredFileName = encodeFileName(sFileName, #False, grProd\bTemplate)
        WQF_fcFileExt(#True)
        openMediaFile(nEditAudPtr, #True)
        setSyncPChanListForAud(nEditAudPtr)
        \sFileTitle = grFileInfo\sFileTitle
      EndIf
      If grEditingOptions\bIgnoreTitleTags
        aSub(\nSubIndex)\sSubDescr = ignoreExtension(GetFilePart(\sFileName))
      Else
        aSub(\nSubIndex)\sSubDescr = \sFileTitle
      EndIf
      debugMsg(sProcName, "aSub(" + getSubLabel(\nSubIndex) + ")\sSubDescr=" + aSub(\nSubIndex)\sSubDescr)
      If aCue(nEditCuePtr)\nFirstSubIndex = \nSubIndex
        ; this is the first sub for the cue
        If aCue(nEditCuePtr)\bDefaultCueDescrMayBeSet
          If grEditingOptions\bIgnoreTitleTags
            aCue(nEditCuePtr)\sCueDescr = ignoreExtension(GetFilePart(\sFileName))
          Else
            aCue(nEditCuePtr)\sCueDescr = \sFileTitle
          EndIf
        EndIf
        WED_setCueNodeText(nEditCuePtr)
        loadGridRow(nEditCuePtr)
      Else
        WED_setSubNodeText(nEditSubPtr)
      EndIf
      If \bAudPlaceHolder = #False
        gsAudioFileDialogInitDir = GetPathPart(\sFileName)
        debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
      EndIf
      debugMsg(sProcName, "nEditAudPtr=" + nEditAudPtr + ", \sStoredFileName=" + \sStoredFileName + ", nNodeKey=" + Str(aCue(\nCueIndex)\nNodeKey))
      setDerivedAudFields(nEditAudPtr)
      
      postChangeAudS(u3, \sFileName)
      postChangeSubS(u2, aSub(\nSubIndex)\sSubDescr, \nSubIndex)
      ; postChangeCueS(u1, aCue(\nCueIndex)\sCueDescr, \nCueIndex)
      
      ; Added 10Apr2024 11.10.2by as part of the fix for a bug reported by Devin Froelicher that Bulk Edit was not processing audio peak normalization
      If \bAudPlaceHolder = #False
        THR_createOrResumeAThread(#SCS_THREAD_GET_FILE_STATS)
      EndIf
      ; End added 10Apr2024 11.10.2by
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure createCueTypeA(sFileName.s)
  PROCNAMEC()
  Protected u1, u2, u3
  
  debugMsg(sProcName, #SCS_START + ", nEditCuePtr=" + nEditCuePtr + ", nEditSubPtr=" + nEditSubPtr + ", nEditAudPtr=" + nEditAudPtr)
  addCueWithSubCue("A", #False)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      u1 = preChangeCueS(aCue(\nCueIndex)\sCueDescr, "change", \nCueIndex)
      u2 = preChangeSubS(aSub(\nSubIndex)\sSubDescr, "change", \nSubIndex)
      u3 = preChangeAudS(\sFileName, "Video/Image File")
      
      \sFileName = sFileName
      \sStoredFileName = encodeFileName(\sFileName, #False, grProd\bTemplate)
      WQA_fcFileExtA(#True) ; nb sets \nFileFormat
      
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE
        \bContinuous = grLastPicInfo\bLastPicContinuous
        \bLogo = #False
        \nEndAt = grLastPicInfo\nLastPicEndAt
      EndIf
      
      debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(nEditAudPtr) + ")")
      openMediaFile(nEditAudPtr, #True)
      \sFileTitle = grFileInfo\sFileTitle
      If grEditingOptions\bIgnoreTitleTags
        aSub(\nSubIndex)\sSubDescr = ignoreExtension(GetFilePart(\sFileName))
        aCue(nEditCuePtr)\sCueDescr = ignoreExtension(GetFilePart(\sFileName))
      Else
        aSub(\nSubIndex)\sSubDescr = \sFileTitle
        aCue(nEditCuePtr)\sCueDescr = \sFileTitle
      EndIf
      setDerivedAudFields(nEditAudPtr)
      gsAudioFileDialogInitDir = GetPathPart(\sFileName)
      debugMsg(sProcName, "gsAudioFileDialogInitDir=" + gsAudioFileDialogInitDir)
      debugMsg(sProcName, "nEditAudPtr=" + nEditAudPtr + ", \sStoredFileName=" + \sStoredFileName + ", nNodeKey=" + Str(aCue(\nCueIndex)\nNodeKey))
      
      postChangeAudS(u3, \sFileName)
      postChangeSubS(u2, aSub(\nSubIndex)\sSubDescr, \nSubIndex)
      postChangeCueS(u1, aCue(\nCueIndex)\sCueDescr, \nCueIndex)
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure createCueOrSubTypeI()
  PROCNAMEC()
  Protected u1, u2, u3
  Protected nFirstSubIndex
  ; MUST be called from addCueWithSubCue() - or else it will be necessary to reinstate preChangeCue and postChageCue etc
  
  debugMsg(sProcName, #SCS_START + ", nEditCuePtr=" + nEditCuePtr + ", nEditSubPtr=" + nEditSubPtr + ", nEditAudPtr=" + nEditAudPtr)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      
      ; u2 = preChangeSubS(aSub(\nSubIndex)\sSubDescr, "change", \nSubIndex)
      ; u3 = preChangeAudS(\sFileName, GetGadgetText(WQF\lblFileName))
      
      If aCue(nEditCuePtr)\nFirstSubIndex = \nSubIndex
        ; this is the first sub for the cue
        ; If aCue(nEditCuePtr)\bDefaultCueDescrMayBeSet
          ; aCue(nEditCuePtr)\sCueDescr = \sFileTitle
        ; EndIf
        WED_setCueNodeText(nEditCuePtr)
        loadGridRow(nEditCuePtr)
      Else
        WED_setSubNodeText(nEditSubPtr)
      EndIf
      setDerivedAudFields(nEditAudPtr)
      
      ; postChangeAudS(u3, \sFileName)
      ; postChangeSubS(u2, aSub(\nSubIndex)\sSubDescr, \nSubIndex)
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure delAudForAudPtr(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nSubPtr, nRow
  Protected k
  Protected nAudNo
  Protected n, n2
  Protected nPrevAudIndex
  
  If pAudPtr >= 0
    closeAud(pAudPtr)
    aAud(pAudPtr)\bExists = #False
    
    nSubPtr = aAud(pAudPtr)\nSubIndex
    
    nPrevAudIndex = aAud(pAudPtr)\nPrevAudIndex
    If nPrevAudIndex = -1
      aSub(nSubPtr)\nFirstAudIndex = aAud(pAudPtr)\nNextAudIndex
    Else
      aAud(nPrevAudIndex)\nNextAudIndex = aAud(pAudPtr)\nNextAudIndex
      debugMsg(sProcName, "(@@d) aAud(" + getAudLabel(nPrevAudIndex) + ")\nNextAudIndex=" + getAudLabel(aAud(nPrevAudIndex)\nNextAudIndex))
    EndIf
    
    If aAud(pAudPtr)\nNextAudIndex >= 0
      aAud(aAud(pAudPtr)\nNextAudIndex)\nPrevAudIndex = aAud(pAudPtr)\nPrevAudIndex
    EndIf
    
    nAudNo = 0
    k = aSub(nSubPtr)\nFirstAudIndex
    While k >= 0
      nAudNo + 1
      aAud(k)\nAudNo = nAudNo
      k = aAud(k)\nNextAudIndex
    Wend
    aSub(nSubPtr)\nAudCount = nAudNo
    debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nAudCount=" + Str(aSub(nSubPtr)\nAudCount))
    
    debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nSubPtr) + ")")
    generatePlayOrder(nSubPtr)
    
    If nSubPtr = nEditSubPtr
      If aSub(nSubPtr)\bSubTypeP
        debugMsg(sProcName, "calling WQP_displaySub(" + getSubLabel(nSubPtr) + ")")
        WQP_displaySub(nSubPtr)
      EndIf
    EndIf
    
    If (aAud(pAudPtr)\bAudTypeA) And (aAud(pAudPtr)\bLogo)
      debugMsg(sProcName, "calling freeLogoImagesIfRequired()")
      freeLogoImagesIfRequired()
    EndIf
    
  EndIf
  
EndProcedure

Procedure delCue(nNodeKey, pVerb.s)
  PROCNAMEC()
  Protected i, j, k, nCuePtr
  Protected u

  debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", pVerb=" + pVerb)
  nCuePtr = getCuePtrForNodeKey(nNodeKey)
  If nCuePtr < 0
    debugMsg(sProcName, "exiting because " + nNodeKey + " not found")
    ProcedureReturn
  EndIf

  stopCue(nCuePtr, "ALL", #False)
  closeCue(nCuePtr)

  u = preChangeCueL(#True, pVerb + " Cue", nCuePtr, #SCS_UNDO_ACTION_DELETE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS)
  
  debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr))
  
  ; mark sub and aud array entries as non-existent
  j = aCue(nCuePtr)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      If \bSubTypeHasAuds
        k = \nFirstAudIndex
        While k >= 0
          aAud(k)\bExists = #False
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      \bExists = #False
      j = \nNextSubIndex
    EndWith
  Wend
  
  For i = nCuePtr To gnLastCue
    If i < gnLastCue
      aCue(i) = aCue(i+1)
    EndIf
  Next i
  gnLastCue - 1
  gnCueEnd = gnLastCue + 1
  If nCuePtr > gnLastCue
    debugMsg(sProcName, "Setting nEditCuePtr (" + nEditCuePtr + ") to -1")
    nEditCuePtr = -1
    nEditSubPtr = -1
    setEditAudPtr(-1)
  Else
    nEditSubPtr = aCue(nCuePtr)\nFirstSubIndex
    setEditAudPtr(-1)
    If nEditSubPtr >= 0
      With aSub(nEditSubPtr)
        If \bSubTypeHasAuds
          setEditAudPtr(\nFirstAudIndex)
        EndIf
      EndWith
    EndIf
  EndIf
  
  If aCue(nCuePtr)\bSubTypeA
    debugMsg(sProcName, "calling freeLogoImagesIfRequired()")
    freeLogoImagesIfRequired()
  EndIf
  
;   debugMsg(sProcName, "calling debugCuePtrs()")
;   debugCuePtrs()
  debugMsg(sProcName, "calling resyncCuePtrs()")
  resyncCuePtrs()
  debugMsg(sProcName, "calling displayOrHideVideoWindows()")
  displayOrHideVideoWindows()
  loadCueBrackets()
;   debugMsg(sProcName, "calling debugCuePtrs()")
;   debugCuePtrs()
  debugMsg(sProcName, "calling WMN_loadHotkeyPanel()")
  WMN_loadHotkeyPanel()

  postChangeCueL(u, #False, -1)

EndProcedure

Procedure delCueOrSubCheck(pVerb.s, bSilent = #True)
  PROCNAMEC()
  Protected sCueInfo.s, nResponse
  Protected nThisCuePtr, nThisSubPtr, nPrevSubPtr
  Protected nThinNodeKey, nNextNodeKey
  Protected sMsgStart.s, sMsg.s
  Protected u, u2
  Protected bCallLoadHotkeyPanel
  Protected j

  debugMsg(sProcName, #SCS_START + ", pVerb=" + pVerb)
  
  nThisCuePtr = gnSelectedNodeCuePtr
  nThisSubPtr = gnSelectedNodeSubPtr
  debugMsg(sProcName, "nThisCuePtr=" + getCueLabel(nThisCuePtr) + ", nThisSubPtr=" + getSubLabel(nThisSubPtr))
  
  If (nThisCuePtr >= 0) And (nThisSubPtr < 0)
    
    Select LCase(pVerb)
      Case "cut"
        sMsgStart = LangPars("Errors", "CannotCutCue3", aCue(nThisCuePtr)\sCue)
      Case "delete"
        sMsgStart = LangPars("Errors", "CannotDeleteCue3", aCue(nThisCuePtr)\sCue)
    EndSelect
    If checkDelCueRI(nThisCuePtr, sMsgStart) = #False
      ProcedureReturn
    EndIf
    ; Added 13Oct2023 11.10.0cj
    j = aCue(nThisCuePtr)\nFirstSubIndex
    While j >= 0
      If checkDelSubRI(j, sMsgStart) = #False
        ProcedureReturn
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    ; End added 13Oct2023 11.10.0cj
    
    With aCue(nThisCuePtr)
      nThinNodeKey = \nNodeKey
      sCueInfo = \sCue
      If \sCueDescr
        If sCueInfo
          sCueInfo + " (" + \sCueDescr + ")"
        Else
          sCueInfo = \sCueDescr
        EndIf
      EndIf
      If \nActivationMethod & #SCS_ACMETH_HK_BIT
        bCallLoadHotkeyPanel = #True
      EndIf
    EndWith
    
    If bSilent
      nResponse = #PB_MessageRequester_Yes
    Else
      Select LCase(pVerb)
        Case "cut"
          sMsg = LangPars("Requesters", "CutCue?", sCueInfo)
        Case "delete"
          sMsg = LangPars("Requesters", "DeleteCue?", sCueInfo)
      EndSelect
      debugMsg(sProcName, sMsg)
      nResponse = scsMessageRequester(grText\sTextEditor, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    EndIf
    
    If nResponse = #PB_MessageRequester_Yes
      If nThisCuePtr < gnLastCue
        nNextNodeKey = aCue(nThisCuePtr + 1)\nNodeKey
      ElseIf nThisCuePtr > 1
        nNextNodeKey = aCue(nThisCuePtr - 1)\nNodeKey
      Else
        nNextNodeKey = grProd\nNodeKey
      EndIf
      If LCase(pVerb) = "cut"
        copyCueOrSubToClipboard()
      EndIf
      ; debugMsg(sProcName, "calling debugCuePtrs()")
      ; debugCuePtrs()
      delCue(nThinNodeKey, pVerb)
      ; debugMsg(sProcName, "calling debugCuePtrs()")
      ; debugCuePtrs()
      setCuePtrs(#False)
      redoCueListTree(nNextNodeKey)
      gbCallPopulateGrid = #True
      debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
      gbCallLoadDispPanels = #True
      
      debugMsg(sProcName, "Setting bSaveEnabled=True")
      WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
      WED_setEditorButtons()
      
    EndIf
    
    
  ElseIf (nThisCuePtr >= 0) And (nThisSubPtr >= 0)
    
    sMsgStart = LangPars("Errors", "CannotDeleteSub3", aCue(nThisCuePtr)\sCue)
    If checkDelSubRI(nThisSubPtr, sMsgStart, 0) = #False
      ProcedureReturn
    EndIf
    
    With aSub(nThisSubPtr)
      nThinNodeKey = \nNodeKey
      sCueInfo = \sCue
      If sCueInfo
        sCueInfo + " "
      EndIf
      sCueInfo + "<" + \nSubNo + ">"
      If \sSubDescr
        sCueInfo + " (" + \sSubDescr + ")"
      EndIf
    EndWith
    
    If bSilent
      nResponse = #PB_MessageRequester_Yes
    Else
      Select LCase(pVerb)
        Case "cut"
          sMsg = LangPars("Requesters", "CutSub?", sCueInfo)
        Case "delete"
          sMsg = LangPars("Requesters", "DeleteSub?", sCueInfo)
      EndSelect
      debugMsg(sProcName, sMsg)
      nResponse = scsMessageRequester(grText\sTextEditor, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
    EndIf
    
    If nResponse = #PB_MessageRequester_Yes
      
      u = preChangeCueL(#True, "Delete Sub-Cue", nThisCuePtr, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_REDO_MAIN | #SCS_UNDO_FLAG_SET_CUE_PTRS) ; Changed 15Oct2022 11.9.6
      u2 = preChangeSubL(#True, "Delete Sub-Cue", nThisSubPtr, #SCS_UNDO_ACTION_DELETE)
      
      If aSub(nThisSubPtr)\nNextSubIndex >= 0
        If aSub(nThisSubPtr)\nPrevSubIndex < 0 And aSub(aSub(nThisSubPtr)\nNextSubIndex)\nNextSubIndex < 0
          ; the next subcue will be the only one left so the sub will not be shown in the tree
          nNextNodeKey = aCue(aSub(nThisSubPtr)\nCueIndex)\nNodeKey
        Else
          ; the next subcue is not the only one remaining, so the subcue will be shown in the tree
          nNextNodeKey = aSub(aSub(nThisSubPtr)\nNextSubIndex)\nNodeKey
        EndIf
        
      ElseIf aSub(nThisSubPtr)\nPrevSubIndex >= 0
        nPrevSubPtr = aSub(nThisSubPtr)\nPrevSubIndex
        If aSub(nPrevSubPtr)\nPrevSubIndex >= 0
          ; not first sub
          nNextNodeKey = aSub(aSub(nThisSubPtr)\nPrevSubIndex)\nNodeKey
        Else
          ; if we get here then there is only one sub left for this cue
          ; so the sub will not be shown in the tree
          nNextNodeKey = aCue(aSub(nThisSubPtr)\nCueIndex)\nNodeKey
        EndIf
      Else
        nNextNodeKey = aCue(aSub(nThisSubPtr)\nCueIndex)\nNodeKey
      EndIf
      
      If LCase(pVerb) = "cut"
        copyCueOrSubToClipboard()
      EndIf
      delSubForNodeKey(nThinNodeKey)
      setCuePtrs(#False)
      debugMsg(sProcName, "calling redoCueListTree(" + Str(nNextNodeKey) + ")")
      redoCueListTree(nNextNodeKey)
      gbCallPopulateGrid = #True
      debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
      gbCallLoadDispPanels = #True
      
      debugMsg(sProcName, "Setting bSaveEnabled=True")
      WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
      WED_setEditorButtons()
      
      postChangeSubL(u2, #False, -1)
      setDefaultCueDescrMayBeSet(nThisCuePtr, #False)
      postChangeCueL(u, #False, nThisCuePtr)
      
    EndIf
    
  EndIf
  
  If bCallLoadHotkeyPanel
    debugMsg(sProcName, "calling WMN_loadHotkeyPanel()")
    WMN_loadHotkeyPanel()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure delSubForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected nSubPtr
  Protected bDelSubResult

  debugMsg(sProcName, #SCS_START + ", nNodeKey=" + nNodeKey)
  
  nSubPtr = getSubPtrForNodeKey(nNodeKey)
  debugMsg(sProcName, "nSubPtr=" + getSubLabel(nSubPtr))

  bDelSubResult = delSubForSubPtr(nSubPtr)
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bDelSubResult))
  ProcedureReturn bDelSubResult
  
EndProcedure

Procedure delSubForSubPtr(nSubPtr)
  PROCNAMECS(nSubPtr)
  Protected j, k, nCuePtr, nNewSubPtr

  debugMsg(sProcName, #SCS_START)
  
  If nSubPtr >= 0
    With aSub(nSubPtr)
      nCuePtr = \nCueIndex
      stopCue(nCuePtr, "ALL", #False)
      debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ")")
      closeSub(nSubPtr)
      
      nNewSubPtr = \nNextSubIndex
      If nNewSubPtr < 0
        nNewSubPtr = \nPrevSubIndex
      EndIf
      
      ; adjust the nPrevSubIndex and nNextSubIndex values to skip the deleted sub
      If \nPrevSubIndex = -1
        aCue(\nCueIndex)\nFirstSubIndex = \nNextSubIndex
        If \nNextSubIndex >= 0
          aSub(\nNextSubIndex)\nPrevSubIndex = \nPrevSubIndex
        EndIf
      Else
        aSub(\nPrevSubIndex)\nNextSubIndex = \nNextSubIndex
        If \nNextSubIndex >= 0
          aSub(\nNextSubIndex)\nPrevSubIndex = \nPrevSubIndex
        EndIf
      EndIf
      
      ; mark sub and aud array entries as non-existent
      If \bSubTypeHasAuds
        k = \nFirstAudIndex
        While k >= 0
          aAud(k)\bExists = #False
          ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\bExists=" + strB(aAud(k)\bExists))
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      \bExists = #False
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\bExists=" + strB(aSub(nSubPtr)\bExists))
      
      If \bSubTypeA
        debugMsg(sProcName, "calling freeLogoImagesIfRequired()")
        freeLogoImagesIfRequired()
      EndIf

    EndWith
    
    renumberSubNos(nCuePtr)
    
    If nNewSubPtr >= 0
      nEditSubPtr = nNewSubPtr
      setEditAudPtr(-1)
      With aSub(nNewSubPtr)
        If \bSubTypeHasAuds
          setEditAudPtr(\nFirstAudIndex)
        EndIf
      EndWith
    Else
      nEditSubPtr = -1
      setEditAudPtr(-1)
    EndIf
    
    setLabels(nCuePtr)
    setCueSubsAllDisabledFlag(nCuePtr)
    
  EndIf
  
  resyncCuePtrs()
  displayOrHideVideoWindows()
  loadHotkeyArray()
  loadCueMarkerArrays()
  
  ProcedureReturn #True
  
EndProcedure

Procedure displaySubUpdatableProcessing()
  ; Procedure added 27Feb2020 11.8.2.2av following issue reported by Bernie Howatt where displaying a 'blank' control send cue (in the editor) having previously displayed
  ; a control send NRPN cue, correctly populated the first entry of the 'blank' control send cue, but did not enable the Save button. That was because the update processing
  ; does not process the PreChange/PostChange when gbInDisplayCue or gbInDisplaySub is set.
  PROCNAMEC()
  
  ; Procedure originally writeen for Control Send sub-cues but other sub-cue types may be added later if required
  
  If (gbInDisplayCue = #False) And (gbInDisplaySub = #False)
    If nEditCuePtr >= 0
      If aCue(nEditCuePtr)\bSubTypeM
        If nEditSubPtr >= 0
          If aSub(nEditSubPtr)\bSubTypeM
            grWQM\nSelectedCtrlSendRow = -2  ; prevents WQM_grdCtrlSends_Change() working as an update 
            WQM_grdCtrlSends_Change()
            WQM_setCtrlSendTestButtons()
            editSetDisplayButtonsM()
          EndIf
        EndIf ; EndIf nEditSubPtr >= 0
      EndIf ; EndIf aCue(nEditCuePtr)\bSubTypeM
    EndIf ; EndIf nEditCuePtr >= 0
  EndIf ; EndIf (gbInDisplayCue = #False) And (gbInDisplaySub = #False)

EndProcedure

Procedure displaySub(pSubPtr, nItemIndex=0, nScrollPos=0)
  PROCNAMECS(pSubPtr)
  Protected i, k, bHideGadget,b
  Protected sTmp.s, sTmp2.s
  Protected sThisHotkey.s, sThisHotkeyEntry.s
  
  debugMsg(sProcName, #SCS_START + ", nItemIndex=" + nItemIndex + ", nScrollPos=" + nScrollPos)
  
  If IsWindow(#WED)
    ; added 8Oct2019 11.8.2at following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
    ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
    If GetWindowState(#WED) = #PB_Window_Minimize
      debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
      SetWindowState(#WED, #PB_Window_Normal)
      debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
    EndIf
    ; end added 8Oct2019 11.8.2at
  EndIf
  
  gbInDisplaySub = #True
  ; debugMsg(sProcName, "gbInDisplaySub=" + strB(gbInDisplaySub))
  
  gnEditPrevCueState = 99
  gnEditPrevLCState = 99
  
  If pSubPtr < 0
    setEditorComponentVisible("None")
    
  Else
    With aSub(pSubPtr)
      
      nEditSubPtr = pSubPtr
      If nEditCuePtr <> \nCueIndex
        debugMsg(sProcName, "changing nEditCuePtr from " + getCueLabel(nEditCuePtr) + " to " + getCueLabel(\nCueIndex))
        nEditCuePtr = \nCueIndex
      EndIf
      bHideGadget = #False ; hide by default

      Select \sSubType
          ; -------------------------------------- SUBTYPE A (Video/Image File)
        Case "A"
          WQA_displaySub(pSubPtr, nItemIndex, nScrollPos)
          bHideGadget = #True
          ; -------------------------------------- SUBTYPE E (Memo)
        Case "E"
          WQE_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE F (Audio File)
        Case "F"
          setEditAudPtr(\nFirstAudIndex)
          WQF_displaySub(pSubPtr)
          bHideGadget = #True
          ; -------------------------------------- SUBTYPE G (Go To Cue)
        Case "G"
          WQG_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE I (Live Input)
        Case "I"
          setEditAudPtr(\nFirstAudIndex)
          WQI_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE J (Enable/Disable Cues)
        Case "J"
          WQJ_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE K (Lighting)
        Case "K"
          WQK_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE L (Level Change)
        Case "L"
          WQL_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE M (Control Send)
        Case "M"
          WQM_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE N (Note)
        Case "N"
          ; displaySubN(pSubPtr)
          ; -------------------------------------- SUBTYPE P (Playlist)
        Case "P"
          setEditAudPtr(\nFirstAudIndex)
          WQP_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE Q (Call Cue)
        Case "Q"
          WQQ_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE R (Run External Program)
        Case "R"
          WQR_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE S (Stop Cues)
        Case "S"
          WQS_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE T (Set Position)
        Case "T"
          WQT_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE U (MTC) ; mtcq
        Case "U"
          WQU_displaySub(pSubPtr)
          ; -------------------------------------- SUBTYPE (None / Other)
      EndSelect
    
      setEditorComponentVisible("Q" + \sSubType)
      ; WED_EnableDisableMenuItems()
      
      If \bSubTypeA
        samAddRequest(#SCS_SAM_DISPLAY_THUMBNAILS, pSubPtr, 0, 0, "", ElapsedMilliseconds()+250)
        
      ElseIf \bSubTypeP
        debugMsg(sProcName, "calling listCueStates(" + getCueLabel(\nCueIndex) + ")")
        listCueStates(\nCueIndex)
        debugMsg(sProcName, "calling WQP_highlightPlayListRow()")
        WQP_highlightPlayListRow()
      EndIf
      
    EndWith
    
  EndIf
  WED_EnableDisableMenuItems()
  gbInDisplaySub = #False
  ; debugMsg(sProcName, "gbInDisplaySub=" + strB(gbInDisplaySub))
  
  ; added 27Feb2020 11.8.2.2av
  ; displaySubUpdatableProcessing() must be called AFTER gbInDisplaySub has been cleared
  displaySubUpdatableProcessing()
  ; end added 27Feb2020 11.8.2.2av
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure displayCue(pCuePtr, pSubPtr)
  PROCNAMECQ(pCuePtr)
  Protected qStartTime.q, qEndTime.q
  
  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr) + ", gbCallLoadDispPanels=" + strB(gbCallLoadDispPanels))
  
  If gbInImportFromCueFile Or gbInImportAudioFiles
    ProcedureReturn
  EndIf
  
  qStartTime = ElapsedMilliseconds()
  gbInDisplayCue = #True
  If pCuePtr >= 0
    debugMsg(sProcName, "calling WEC_displayCueDetail(" + pCuePtr + ", " + pSubPtr + ")")
    WEC_displayCueDetail(pCuePtr, pSubPtr)
    If pSubPtr >= 0
      debugMsg(sProcName, "calling fcEditSubType(" + aSub(pSubPtr)\sSubType + ")")
      fcEditSubType(aSub(pSubPtr)\sSubType)  ; nb calls displaySub
    EndIf
  EndIf
  gbInDisplayCue = #False
  
  ; displaySubUpdatableProcessing() must be called AFTER gbInDisplayCue has been cleared
  displaySubUpdatableProcessing()

  qEndTime = ElapsedMilliseconds()
  debugMsg(sProcName, #SCS_END + ", time in displayCue(): " + Str(qEndTime - qStartTime) + "ms")
  
EndProcedure

Procedure displayProd()
  PROCNAMEC()
  Protected nMousePointer, bWaitDisplayed, sInfoMsg1.s
  
  debugMsg(sProcName, #SCS_START)

  If IsWindow(#WED)
    ; added 8Oct2019 11.8.2at following bug reports from Michael Schulte-Eickholt and 'Trohwold' (Forum)
    ; if #WED is minimized when fmCreateQF() is processed then errors occur because WindowWidth(#WED) returns 0 if the window is minimized
    If GetWindowState(#WED) = #PB_Window_Minimize
      debugMsg(sProcName, "calling SetWindowState(#WED, #PB_Window_Normal) because #WED currently minimized")
      SetWindowState(#WED, #PB_Window_Normal)
      debugMsg(sProcName, "WindowWidth(#WED)=" + WindowWidth(#WED) + ", WindowHeight(#WED)=" + WindowHeight(#WED))
    EndIf
    ; end added 8Oct2019 11.8.2at
  EndIf
  
  gbInDisplayProd = #True
  nMousePointer = getMouseCursor()
  setMouseCursorBusy()
  
  ; debugMsg0(sProcName, "grCED\bProdCreated=" + strB(grCED\bProdCreated))
  If grCED\bProdCreated = #False
    If gbClosingDown = #False
      setWEPMaxLoadProgress()
      sInfoMsg1 = Lang("WMI", "LoadingProdProps") + " (" + LangPars("Common", "Pass", "1") + ")"
      WMI_displayInfoMsg1(sInfoMsg1, grWEP\nMaxLoadProgress) ; "Loading Production Properties"
      bWaitDisplayed = #True
    EndIf
    WEP_Form_Load()
  EndIf
  WEP_populateProdProperties()
  setEditorComponentVisible("Prod")
  If bWaitDisplayed
    WMI_clearInfoMsgs()
  EndIf
  setMouseCursor(nMousePointer)
  gbInDisplayProd = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure updateCtrlSendGrid(nCtrlSendIndex=-1, bForceUpdate=#False)
  PROCNAMECS(nEditSubPtr)
  Protected n

  debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex + ", bForceUpdate=" + strB(bForceUpdate))
  
  If nEditSubPtr < 0
    ProcedureReturn
  EndIf
  If bForceUpdate = #False
    If gbInDisplaySub
      debugMsg(sProcName, "exiting")
      ProcedureReturn
    EndIf
  EndIf
  
  n = nCtrlSendIndex
  If n < 0
    n = GGS(WQM\grdCtrlSends)
    debugMsg(sProcName, "GGS(WQM\grdCtrlSends) returned " + n)
  EndIf
  If n >= 0
    debugMsg(sProcName, "n=" + n + ", sDisplayInfo=" + aSub(nEditSubPtr)\aCtrlSend[n]\sDisplayInfo)
    SetGadgetItemText(WQM\grdCtrlSends, n, aSub(nEditSubPtr)\aCtrlSend[n]\sDisplayInfo, 1)
    WQM_setTBSButtons(n)
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure setLoopAddBtnEnabledState()
  ; PROCNAMECA(nEditAudPtr)
  Protected l2
  Protected bEnableAdd
  Protected bAudCueMarkers.b
  
  ; debugMsg(sProcName, #SCS_START)
  
  With aAud(nEditAudPtr)
    If grLicInfo\bAudFileLoopsAvailable
      l2 = rWQF\nDisplayedLoopInfoIndex
      If \nMaxLoopInfo < #SCS_MAX_LOOP
        bEnableAdd = #True
      EndIf
      If (bEnableAdd) And (l2 >= 0)
        If l2 = \nMaxLoopInfo
          If \aLoopInfo(l2)\nAbsLoopEnd >= \nAbsEndAt
            bEnableAdd = #False ; cannot start a loop after the 'end at' time because the cue has already ended
          EndIf
        ElseIf l2 < \nMaxLoopInfo
          If (\aLoopInfo(l2)\nAbsLoopEnd + 100) >= \aLoopInfo(l2+1)\nAbsLoopStart
            bEnableAdd = #False ; insufficient time between this loop and the next to create a new loop (using a 100ms 'minimum loop time')
          EndIf
        EndIf
      EndIf
    EndIf
    setEnabled(WQF\btnLoopAdd, bEnableAdd)
    ; debugMsg(sProcName, "setEnabled(WQF\btnLoopAdd, " + strB(bEnableAdd) + ")")
  EndWith
EndProcedure

Procedure editApplyChanges()
  PROCNAMEC()
  Protected nPrevRunMode
  Protected i
  Protected bTBCFound
  Protected bResult

  debugMsg(sProcName, #SCS_START)
  
  nPrevRunMode = grHoldProd\nRunMode
  If grCED\bProdCreated ; no need to validate prod properties if fmEditProd has not been created because that means the user hasn't made any changes to production properties
    If WEP_valProdProperties(#True) = #False
      debugMsg(sProcName, "WEP_valProdProperties() returned #False")
      ProcedureReturn #False
    EndIf
  EndIf

  If nEditCuePtr >= 0
    If valCue(#False) = #False
      debugMsg(sProcName, "valCue() returned #False")
      ProcedureReturn #False
    EndIf
  EndIf

  debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
  If writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
    holdDataForEditCancel()
    bResult = #True
    debugMsg(sProcName, "grTempDB\bTempDatabaseChanged=" + strB(grTempDB\bTempDatabaseChanged) + ", gbFileStatsChanged=" + strB(gbFileStatsChanged) + ", gbUnsavedPlaylistOrderInfo=" + strB(gbUnsavedPlaylistOrderInfo))
    If grTempDB\bTempDatabaseChanged Or gbFileStatsChanged Or gbUnsavedPlaylistOrderInfo
      debugMsg(sProcName, "calling createProdDatabase()")
      createProdDatabase()
    EndIf
    If grProd\bTemplate
      setCurrTemplateFileNames()
      renameTemplateFilesIfReqd()
    EndIf
  Else
    debugMsg(sProcName, "writeXMLCueFile() returned #False")
    bResult = #False
  EndIf
  
  WED_setWindowTitle()

  For i = 1 To gnLastCue
    If aCue(i)\nActivationMethod = #SCS_ACMETH_TIME
      bTBCFound = #True
      Break
    EndIf
  Next i
  If bTBCFound
    debugMsg(sProcName, "calling setTimeBasedCues")
    setTimeBasedCues()
    debugMsg(sProcName, "calling setCueDetailsInMain")
    setCueDetailsInMain()
  EndIf

  If grProd\nRunMode <> nPrevRunMode
    gnCallOpenNextCues = 1
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure closeAndReopenSub(pSubPtr)
  ; Added 5Jul2022 11.9.3.1ab
  PROCNAMECS(pSubPtr)
  Protected nAudPtr, l2, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  closeSub(pSubPtr)
  freeStreams(#True)  ; force freeing of streams before (re-)opening file
  clearSubGaplessInfo(pSubPtr)
  Select aSub(pSubPtr)\sSubType
    Case "F"
      nAudPtr = aSub(pSubPtr)\nFirstAudIndex
      If nAudPtr >= 0
        With aAud(nAudPtr)
          For l2 = 0 To \nMaxLoopInfo
            \aLoopInfo(l2)\nRelLoopStart = getRelTime(\aLoopInfo(l2)\nAbsLoopStart, \nStartAt)
            \aLoopInfo(l2)\nRelLoopEnd = getRelTime(\aLoopInfo(l2)\nAbsLoopEnd, \nStartAt)
          Next l2
          debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nAudPtr) + ", #True)")
          setIgnoreDevInds(nAudPtr, #True)
          openMediaFile(nAudPtr)
          If \nAudState = #SCS_CUE_ERROR
            sMsg = \sErrorMsg
            debugMsg(sProcName, sMsg)
            scsMessageRequester(grText\sTextError, sMsg)
            ProcedureReturn #False
          EndIf
          setSyncPChanListForAud(nAudPtr)
          debugMsg(sProcName, \sAudLabel + ", \nFileState=" + decodeFileState(\nFileState))
        EndWith
      EndIf
  EndSelect
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure editPlaySub(nCtrlSendIndex=-1, nStartAtTrkNo=-1)
  PROCNAMECS(nEditSubPtr)
  Protected nSldPos, fTmpLevel.f, d, k, l2
  Protected bHold
  Protected sMsg.s
  Protected sXChanList.s
  Protected nPlayFromPos, nLoopToGo

  debugMsg(sProcName, #SCS_START + ", nCtrlSendIndex=" + nCtrlSendIndex + ", nStartAtTrkNo=" + nStartAtTrkNo)
  
  gbInEditPlaySub = #True

  If valCue(#True) = #False
    debugMsg(sProcName, "exiting after valCue()")
    gbInEditPlaySub = #False
    ProcedureReturn
  EndIf

  debugMsg(sProcName, "grCED\sDisplayedSubType=" + grCED\sDisplayedSubType)

  ; clearSubGaplessInfo(nEditSubPtr)
  
  If grCED\sDisplayedSubType = "A"     ; ------------------------------------------- SubType A
    
    ; bring edit form to front (overcomes problem with Windows throwing back to the main window)
    SetTopMostWindow(#WED, #True)
    
    ; set initial nAudState values so that time remaining can be calculated correctly
    k = aSub(nEditSubPtr)\nFirstPlayIndex
    ; debugMsg(sProcName, "k=" + k)
    While k >= 0
      With aAud(k)
        If \nPlayNo = 1
          audSetState(k, #SCS_CUE_READY, 11)
        Else
          audSetState(k, #SCS_CUE_PL_READY, 12)
        EndIf
        If \nFileFormat <> #SCS_FILEFORMAT_PICTURE
          debugMsg(sProcName, "calling rewindAud(" + getAudLabel(k) + ")")
          rewindAud(k)
        EndIf
        k = \nNextPlayIndex
      EndWith
    Wend
    debugMsg(sProcName, "calling setCueState(" + getCueLabel(nEditCuePtr) + ")")
    setCueState(nEditCuePtr)
    debugMsg(sProcName, "calling calcPLPosition(" + getSubLabel(nEditSubPtr) + ")")
    calcPLPosition(nEditSubPtr)
    debugMsg(sProcName, "calling playSub(" + getSubLabel(nEditSubPtr) + ", 0, #False, #True, -1, -1, " + nStartAtTrkNo + ")")
    playSub(nEditSubPtr, 0, #False, #True, -1, -1, nStartAtTrkNo)
    ; editSetDisplayButtonsA()
    
    ; release edit form from topmost status (not needed now as form will now be displayed)
    SetTopMostWindow(#WED, #False)
    
  ElseIf grCED\sDisplayedSubType = "F"     ; ------------------------------------------- SubType F
    ; Added 5Jul2022 11.9.3.1ab
    If closeAndReopenSub(nEditSubPtr) = #False
      gbInEditPlaySub = #False
      ProcedureReturn
    EndIf
    ; End added 5Jul2022 11.9.3.1ab
    ; Deleted 5Jul2022 11.9.3.1ab
;     debugMsg(sProcName, "calling closeSub(" + getSubLabel(nEditSubPtr) + ")")
;     closeSub(nEditSubPtr)
;     freeStreams(#True)  ; force freeing of streams before (re-)opening file
;     clearSubGaplessInfo(nEditSubPtr)
;     With aAud(nEditAudPtr)
;       For l2 = 0 To \nMaxLoopInfo
;         \aLoopInfo(l2)\nRelLoopStart = getRelTime(\aLoopInfo(l2)\nAbsLoopStart, \nStartAt)
;         \aLoopInfo(l2)\nRelLoopEnd = getRelTime(\aLoopInfo(l2)\nAbsLoopEnd, \nStartAt)
;       Next l2
;       debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
;       setIgnoreDevInds(nEditAudPtr, #True)
;       openMediaFile(nEditAudPtr)
;       If \nAudState = #SCS_CUE_ERROR
;         sMsg = \sErrorMsg
;         debugMsg(sProcName, sMsg)
;         scsMessageRequester(grText\sTextError, sMsg)
;         gbInEditPlaySub = #False
;         ProcedureReturn
;       EndIf
;       setSyncPChanListForAud(nEditAudPtr)
;       debugMsg(sProcName, \sAudLabel + ", \nFileState=" + decodeFileState(\nFileState))
;     EndWith
    ; End deleted 5Jul2022 11.9.3.1ab
    
    If aAud(nEditAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
      ; don't try to play as file was not opened
      gbInEditPlaySub = #False
      ProcedureReturn
    EndIf
    
    With aAud(nEditAudPtr)
      nSldPos = SLD_getValue(WQF\sldProgress)
      If nSldPos >= SLD_getMax(WQF\sldProgress)
        ; if slider at end then reposition at start
        nSldPos = 0
      ElseIf nSldPos < 0
        nSldPos = 0
      EndIf
      ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, " + nSldPos + ")")
      SLD_setValue(WQF\sldProgress, nSldPos)
      If nSldPos = 0
        debugMsg(sProcName, "calling reposAuds(" + nEditAudPtr + ", " + \nAbsStartAt + ", #False)") ;, " + StrD(\dStartAtCPTime) + ")")
        reposAuds(nEditAudPtr, \nAbsStartAt, #False)                                                          ;, \dStartAtCPTime)
        \nPlayFromPos = grAudDef\nPlayFromPos
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPlayFromPos=" + \nPlayFromPos)
      Else
        nPlayFromPos = nSldPos + \nAbsMin
        l2 = getLoopInfoIndexForAbsPos(nEditAudPtr, nPlayFromPos)
        If l2 >= 0
          If (\aLoopInfo(l2)\bContainsLoop) And (\aLoopInfo(l2)\nLoopXFadeTime > 0)
            debugMsg(sProcName, "\aLoopInfo(" + l2 + ")\nLoopStart=" + \aLoopInfo(l2)\nLoopStart + ", \nLoopEnd=" + \aLoopInfo(l2)\nLoopEnd)
            If (nPlayFromPos >= (\aLoopInfo(l2)\nLoopEnd - \aLoopInfo(l2)\nLoopXFadeTime)) And (nPlayFromPos <= \aLoopInfo(l2)\nLoopEnd)
              nLoopToGo = \aLoopInfo(l2)\nLoopEnd - nPlayFromPos
              nPlayFromPos = \aLoopInfo(l2)\nLoopStart + nLoopToGo
              debugMsg(sProcName, "nLoopToGo=" + nLoopToGo + ", nPlayFromPos=" + nPlayFromPos)
            EndIf
          EndIf
        EndIf
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nEditAudPtr) + ", " + nPlayFromPos + ")")
        reposAuds(nEditAudPtr, nPlayFromPos)
        \nPlayFromPos = nPlayFromPos
        \bResetFilePosToStartAtInMain = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nPlayFromPos=" + \nPlayFromPos + ", \bResetFilePosToStartAtInMain=" + strB(\bResetFilePosToStartAtInMain))
      EndIf
      
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \sLogicalDev[d]
          If \nFadeInTime > 0
            fTmpLevel = #SCS_MINVOLUME_SINGLE
          Else
            fTmpLevel = \fBVLevel[d]
          EndIf
          debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nEditAudPtr) + ", " + d + ", " + traceLevel(fTmpLevel) + ", " + formatPan(\fPan[d]) + ")")
          setLevelsAny(nEditAudPtr, d, fTmpLevel, \fPan[d])
          SLD_setBaseLevel(WQF\sldLevel[d], \fBVLevel[d], \fTrimFactor[d])
        EndIf
      Next d
      
      setResyncLinksReqd(nEditAudPtr)
      
    EndWith
    
    playSub(nEditSubPtr, 0, #False, #True)
    
    If gbUseSMS ; SM-S
      With aSub(nEditSubPtr)
        If Len(\sSubSetGainCommandString) > 0
          sendSMSCommand("set " + Trim(\sSubSetGainCommandString))
          \sSubSetGainCommandString = ""
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sSubSetGainCommandString=" + \sSubSetGainCommandString)
        EndIf
        If Len(\sSubPlayCommandString) > 0
          sendSMSCommand("play " + Trim(\sSubPlayCommandString))
          \sSubPlayCommandString = ""
          buildGetSMSCurrInfoCommandStrings()
        EndIf
      EndWith
    EndIf
    
    editSetDisplayButtonsF()
    
  ElseIf grCED\sDisplayedSubType = "I"     ; ------------------------------------------- SubType I
    debugMsg(sProcName, "calling closeSub(" + getSubLabel(nEditSubPtr) + ")")
    closeSub(nEditSubPtr)
    With aAud(nEditAudPtr)
      debugMsg(sProcName, "calling setIgnoreDevInds(" + getAudLabel(nEditAudPtr) + ", #True)")
      setIgnoreDevInds(nEditAudPtr, #True)
      openInputChannels(nEditAudPtr)
      If \nAudState = #SCS_CUE_ERROR
        sMsg = \sErrorMsg
        debugMsg(sProcName, sMsg)
        scsMessageRequester(grText\sTextError, sMsg)
        gbInEditPlaySub = #False
        ProcedureReturn
      EndIf
      debugMsg(sProcName, \sAudLabel + ", \nFileState=" + decodeFileState(\nFileState))
    EndWith
    
    If aAud(nEditAudPtr)\nFileState <> #SCS_FILESTATE_OPEN
      ; don't try to play as file was not opened
      gbInEditPlaySub = #False
      ProcedureReturn
    EndIf
    
    With aAud(nEditAudPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \sLogicalDev[d]
          If \nFadeInTime > 0
            fTmpLevel = #SCS_MINVOLUME_SINGLE
          Else
            fTmpLevel = \fBVLevel[d]
          EndIf
          setLevelsAny(nEditAudPtr, d, fTmpLevel, \fPan[d])
          If \nFadeInTime > 0
            SLD_setBaseLevel(WQI\sldLevel[d], \fBVLevel[d], \fTrimFactor[d])
          EndIf
        EndIf
      Next d
      
    EndWith
    
    playSub(nEditSubPtr, 0, #False, #True)
    
    If gbUseSMS ; SM-S
      With aSub(nEditSubPtr)
        If \sSubSetGainCommandString
          sendSMSCommand("set " + Trim(\sSubSetGainCommandString))
          \sSubSetGainCommandString = ""
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sSubSetGainCommandString=" + \sSubSetGainCommandString)
        EndIf
        buildGetSMSCurrInfoCommandStrings()
        sXChanList = buildXChanListForSub(nEditSubPtr)
        If sXChanList
          sendSMSCommand("set chan " + sXChanList + " mute off")
        EndIf
      EndWith
    EndIf
    
    WCN_setLiveOnInds()
    
    editSetDisplayButtonsI()
    
  ElseIf grCED\sDisplayedSubType = "M"     ; ------------------------------------------- SubType M
    playSub(nEditSubPtr, 0, #False, #True, nCtrlSendIndex)
    SGT(WQM\lblEditMidiInfo[0], grCtrlSendSubData\sCtrlSendInfo)
    SGT(WQM\lblEditMidiInfo[1], grCtrlSendSubData\sCtrlSendInfo)
    gqEditMidiInfoDisplayed = ElapsedMilliseconds() + 6000    ; add 6 seconds so message stays up for 10 seconds
    gbEditMidiInfoDisplayedSet = #True
    ; start timer to clear info message
    editSetDisplayButtonsM()
    
  ElseIf grCED\sDisplayedSubType = "P"     ; ------------------------------------------- SubType P
    ; set initial nAudState values so that time remaining can be calculated correctly
    k = aSub(nEditSubPtr)\nFirstPlayIndex
    While k >= 0
      With aAud(k)
        setPlaylistTrackReadyState(k)
        ; modified 22Oct2019 11.8.2bc to allow the user to start part-way through the first file if they have just dragged or set the progess slider sldPLProgress[0]
        ; modification was to include "And (k <> aSub(nEditSubPtr)\nFirstPlayIndex)"
        If (\nFileState = #SCS_FILESTATE_OPEN) And (k <> aSub(nEditSubPtr)\nFirstPlayIndex)
          debugMsg(sProcName, "calling rewindAud(" + getAudLabel(k) + ")")
          rewindAud(k)
        EndIf
        k = \nNextPlayIndex
      EndWith
    Wend
    setCueState(nEditCuePtr)
    debugMsg(sProcName, "calling calcPLPosition(" + getSubLabel(nEditSubPtr) + ")")
    calcPLPosition(nEditSubPtr)
    debugMsg(sProcName, "calling playSub(" + getSubLabel(nEditSubPtr) + ", 0, #False, #True, -1, -1, " + nStartAtTrkNo + ")")
    playSub(nEditSubPtr, 0, #False, #True, -1, -1, nStartAtTrkNo)
    If gbUseSMS ; SM-S
      With aSub(nEditSubPtr)
        If Len(\sSubSetGainCommandString) > 0
          sendSMSCommand("set " + Trim(\sSubSetGainCommandString))
          \sSubSetGainCommandString = ""
          debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\sSubSetGainCommandString=" + \sSubSetGainCommandString)
        EndIf
        If Len(\sSubPlayCommandString) > 0
          sendSMSCommand("play " + Trim(\sSubPlayCommandString))
          \sSubPlayCommandString = ""
          buildGetSMSCurrInfoCommandStrings()
        EndIf
      EndWith
    EndIf
    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState))
    
    editSetDisplayButtonsP()
    
  EndIf

  gbInEditPlaySub = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure editPlayLCCue()
  PROCNAMECS(nEditSubPtr)
  Protected d, m
  Protected sSFRCue.s
  Protected nAbsStartAt
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr
  Protected fTmpLevel.f
  Protected fTmpDBLevel.f
  Protected bTempoEtc
  
  debugMsg(sProcName, #SCS_START)
  
  If valCue(#True) = #False
    debugMsg(sProcName, "valCue() returned #False")
    ProcedureReturn
  EndIf
  debugMsg(sProcName, "valCue() returned #True")
  
  gnEditPrevCueState = 99
  gnEditPrevLCState = 99
  With aSub(nEditSubPtr)
    nLCCuePtr = \nLCCuePtr
    nLCSubPtr = \nLCSubPtr
    If \bLCTargetIsP Or \bLCTargetIsA
      If aSub(nLCSubPtr)\nFirstPlayIndex >= 0
        \nLCAudPtr = aSub(nLCSubPtr)\nFirstPlayIndex
      EndIf
    EndIf
    nLCAudPtr = \nLCAudPtr
    Select \nLCAction
      Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
        bTempoEtc = #True
    EndSelect
  EndWith
  
  With aAud(nLCAudPtr)
    
    debugMsg(sProcName, "calling closeSub(" + getSubLabel(nLCSubPtr) + ")")
    closeSub(nLCSubPtr)
    openMediaFile(nLCAudPtr)
    setSyncPChanListForAud(nLCAudPtr)
    If \bLiveInput = #False
      debugMsg(sProcName, "nLCAudPtr=" + getAudLabel(nLCAudPtr) + ", \nAbsStartAt=" + \nAbsStartAt + ", aSub(" + getSubLabel(nEditSubPtr) + ")\nLCStartAt=" + Str(aSub(nEditSubPtr)\nLCStartAt))
      nAbsStartAt = \nAbsStartAt + aSub(nEditSubPtr)\nLCStartAt
      setAudChannelPositions(nLCAudPtr, nAbsStartAt)
    EndIf
    
    ; NOTE: Added 16Dec2024 11.10.6bv following issues found when testing for 'Tutorial 5C - Level Change Cues'
    debugMsg(sProcName, "calling loadLvlPtRun(" + getAudLabel(nLCAudPtr) + ", " + \nCuePos + ", #True, " + strB(#cTraceSetLevels) + ")")
    loadLvlPtRun(nLCAudPtr, \nCuePos, #True, #cTraceSetLevels)
    ; End added 16Dec2024
    
    ; set initial level and pan for this test
    debugMsg(sProcName, "gsLCPrevCueType=" + gsLCPrevCueType)
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      If \sLogicalDev[d]
        ; ignore fade in time if LCStartAt > 0 or expected level based on another type L
        If bTempoEtc
          If aSub(nEditSubPtr)\nLCStartAt > 0 Or gsLCPrevCueType = "L"
            fTmpLevel = \fBVLevel[d]
          ElseIf \nFadeInTime > 0
            fTmpLevel = #SCS_MINVOLUME_SINGLE
          Else
            fTmpLevel = \fBVLevel[d]
          EndIf
        ElseIf (\bLiveInput = #False) And ((aSub(nEditSubPtr)\nLCStartAt > 0) Or (gsLCPrevCueType = "L"))
          ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
          fTmpLevel = aSub(nEditSubPtr)\fLCInitBVLevel[d]
        ElseIf \nFadeInTime > 0
          fTmpLevel = #SCS_MINVOLUME_SINGLE
        Else
          fTmpLevel = aSub(nEditSubPtr)\fLCInitBVLevel[d]
        EndIf
        If bTempoEtc = #False And aSub(\nSubIndex)\bSubTypeAorP
          fTmpLevel * (\fPLRelLevel / 100.0)
        EndIf
        \fCueVolNow[d] = fTmpLevel
        \fCueAltVolNow[d] = #SCS_MINVOLUME_SINGLE
        \fCueTotalVolNow[d] = \fCueVolNow[d]
        CompilerIf #cTraceCueTotalVolNow
          debugMsg(sProcName, "aAud(" + getAudLabel(nLCAudPtr) + ")\fCueTotalVolNow[" + d + "]=" + traceLevel(aAud(nLCAudPtr)\fCueTotalVolNow[d]))
        CompilerEndIf
        
        If bTempoEtc = #False
          \fCuePanNow[d] = aSub(nEditSubPtr)\fLCInitPan[d]
          If aSub(\nSubIndex)\bSubTypeAorP
            aSub(\nSubIndex)\fSubBVLevelNow[d] = fTmpLevel
            aSub(\nSubIndex)\fSubPanNow[d] = \fCuePanNow[d]
          EndIf
        EndIf
        debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nLCAudPtr) + ", " + d + ", " + traceLevel(\fCueVolNow[d]) + ", " + formatPan(\fCuePanNow[d]) + ")")
        setLevelsAny(nLCAudPtr, d, \fCueVolNow[d], \fCuePanNow[d])
      EndIf
    Next d
    If (\bLiveInput = #False) And ((aSub(nEditSubPtr)\nLCStartAt > 0) Or (gsLCPrevCueType = "L"))
      \bIgnoreLevelEnvelope = #True
    Else
      \bIgnoreLevelEnvelope = #False
    EndIf
    playAudChannels(nLCAudPtr, #False, -1, #True)
    \qTimeAudStarted = gqTimeNow
    ; \qTimeAudEnded = 0
    \bTimeAudEndedSet = #False
    \qTimeAudRestarted = gqTimeNow
    \nTotalTimeOnPause = 0
    \nPreFadeInTimeOnPause = 0
    \nPreFadeOutTimeOnPause = 0
    
    ; ignore fade in time if LCStartAt > 0 or expected level based on another type L
    If (\bLiveInput = #False) And ((aSub(nEditSubPtr)\nLCStartAt > 0) Or (gsLCPrevCueType = "L"))
      If (\nFadeInTime > 0) And (\nFadeInType = #SCS_FADE_LIN)
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \sLogicalDev[d]
            slideChannelAttributes(nLCAudPtr, d, aSub(nEditSubPtr)\fLCInitBVLevel[d], #SCS_NOPANCHANGE_SINGLE, \nFadeInTime, 260001)
          EndIf
        Next d
      EndIf
    EndIf
    
    If (\nFadeInTime > 0) And (aSub(nEditSubPtr)\nLCStartAt = 0) And (gsLCPrevCueType <> "L")
      \nAudState = #SCS_CUE_FADING_IN
      \qTimeFadeInStarted = gqTimeNow
      \bTimeFadeInStartedSet = #True
      \nCuePosAtFadeStart = \nCuePos
    Else
      \nAudState = #SCS_CUE_PLAYING
      \qTimeFadeInStarted = 0
      \bTimeFadeInStartedSet = #False
      \nCuePosAtFadeStart = 0
    EndIf
    debugMsg(sProcName, "aAud(" + getAudLabel(nLCAudPtr) + ")\bTimeFadeInStartedSet=" + strB(\bTimeFadeInStartedSet))
    setCueState(\nCueIndex)
    debugMsg(sProcName, "aCue(" + getCueLabel(\nCueIndex) + "\nCueState=" + decodeCueState(aCue(\nCueIndex)\nCueState))
    \nTotalTimeOnPause = 0
    \nPriorTimeOnPause = 0
    \nPreFadeInTimeOnPause = 0
    \nPreFadeOutTimeOnPause = 0
    \nCuePosAtLoopStart = 0
    
  EndWith

  aSub(nLCSubPtr)\qTimeSubStarted = gqTimeNow
  aSub(nLCSubPtr)\qAdjTimeSubStarted = gqTimeNow
  aSub(nLCSubPtr)\bTimeSubStartedSet = #True
  aSub(nLCSubPtr)\qTimeSubRestarted = gqTimeNow
  aSub(nLCSubPtr)\nLCCtrlSubPtr = nEditSubPtr
  aSub(nLCSubPtr)\bStartedInEditor = #True

  With aSub(nEditSubPtr)
    \nSubState = #SCS_CUE_READY
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      \bLCActive[d] = \bLCInclude[d]
      If \bLCInclude[d]
        \nLCPosition[d] = 0
      EndIf
    Next d
    \nLCPositionMax = 0
    
    If aAud(\nLCAudPtr)\bLiveInput
      setEnabled(WQL\btnLCRewind, #False)
    Else
      setEnabled(WQL\btnLCRewind, #True)
    EndIf
    setEnabled(WQL\btnLCPlay, #True)
    setEnabled(WQL\btnLCPause, #True)
    setEnabled(WQL\btnLCStop, #True)
    setEnabled(WQL\btnTestLevelChange, #True)
    debugMsg(sProcName, "WQL\btnTestLevelChange enabled")
    
  EndWith

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure editPlayLevelChange()
  PROCNAMECS(nEditSubPtr)
  Protected d, fLCTargetBVLevel.f, fLCReqdPan.f
  Protected fTmpLevel.f
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr, nLCTime
  Protected sDevPXChanListLeft.s, sDevPXChanListRight.s
  Protected sAudSetGainCommandString.s, sSetCommandItem.s, sLevelInfo.s
  Protected sSetGainCommandString.s, sSubFinalSetGainCommandString.s
  
  debugMsg(sProcName, #SCS_START)
  
  gqTimeNow = ElapsedMilliseconds()

  With aSub(nEditSubPtr)
    nLCCuePtr = \nLCCuePtr
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
    \qTimeSubStarted = gqTimeNow
    \qAdjTimeSubStarted = gqTimeNow
    \bTimeSubStartedSet = #True
    \qTimeSubRestarted = gqTimeNow
    \nSubState = #SCS_CUE_CHANGING_LEVEL
    \bTestingLevelChange = #True
    \bStartedInEditor = #True
    debugMsg(sProcName, \sSubLabel + ", \bTestingLevelChange=" + strB(\bTestingLevelChange) + ", \bStartedInEditor=" + strB(\bStartedInEditor))
    setCueState(nEditCuePtr)
    If (nLCSubPtr >= 0) And (nLCAudPtr >= 0)
      Select \nLCAction
        Case #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH, #SCS_LC_ACTION_FREQ
          nLCTime = \nLCTimeMax
          ; debugMsg(sProcName, "calling setAudTempoEtcForLvlChgSub(" + getSubLabel(nEditSubPtr) + ")")
          setAudTempoEtcForLvlChgSub(nEditSubPtr)
        Default
          nLCTime = \nLCTimeMax
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \bLCInclude[d]
              fTmpLevel = aAud(nLCAudPtr)\fCueVolNow[d]
              If aSub(nLCSubPtr)\bSubTypeAorP
                fTmpLevel * (100.0 / aAud(nLCAudPtr)\fPLRelLevel)
              EndIf
              \fLCBVLevelWhenStarted[d] = fTmpLevel
              If \fLCBVLevelWhenStarted[d] < grLevels\fMinBVLevel
                ; Added 30Dec2024 11.10.6ca
                \fLCBVLevelWhenStarted[d] = grLevels\fMinBVLevel
              EndIf
              \fLCPanWhenStarted[d] = aAud(nLCAudPtr)\fCuePanNow[d]
              If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                \fLCTargetBVLevel[d] = \fLCReqdBVLevel[d]
              Else
                \fLCTargetBVLevel[d] = convertDBLevelToBVLevel(convertBVLevelToDBLevel(\fLCBVLevelWhenStarted[d]) + Val(\sLCReqdDBLevel[d]))
                ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCTargetBVLevel[" + d + "]=" + traceLevel(\fLCTargetBVLevel[d]))
                If \fLCTargetBVLevel[d] > grLevels\fMaxBVLevel
                  \fLCTargetBVLevel[d] = grLevels\fMaxBVLevel
                EndIf
                If \fLCTargetBVLevel[d] < #SCS_MINVOLUME_SINGLE
                  \fLCTargetBVLevel[d] = #SCS_MINVOLUME_SINGLE
                EndIf
              EndIf
              If gbUseBASS  ; BASS
                If aAud(nLCAudPtr)\nBassChannel[d] <> 0
                  fLCReqdPan = \fLCReqdPan[d]
                  If \nLCType = #SCS_FADE_LIN
                    fLCTargetBVLevel = \fLCTargetBVLevel[d]
                    If aSub(nLCSubPtr)\bSubTypeAorP
                      fLCTargetBVLevel * (aAud(nLCAudPtr)\fPLRelLevel / 100.0)
                    EndIf
                    slideChannelAttributes(nLCAudPtr, d, fLCTargetBVLevel, fLCReqdPan, \nLCTime[d], 270001)
                  Else
                    slideChannelAttributes(nLCAudPtr, d, #SCS_NOVOLCHANGE_SINGLE, fLCReqdPan, \nLCTime[d], 270002)
                  EndIf
                EndIf
                
              Else  ; SM-S
                sLevelInfo = setLevelsForSMSOutputDev(nLCAudPtr, d, \fLCTargetBVLevel[d], \fLCReqdPan[d], \nLCTime[d], \nLCType)
                debugMsg(sProcName, "d=" + d + ", sLevelInfo=" + sLevelInfo)
                sDevPXChanListLeft = aAud(nLCAudPtr)\sDevPXChanListLeft[d]
                sDevPXChanListRight = aAud(nLCAudPtr)\sDevPXChanListRight[d]
                If \fLCReqdPan[d] = #SCS_PANCENTRE_SINGLE
                  sSetCommandItem = " chan " + sDevPXChanListLeft + " " + sDevPXChanListRight + " " + StringField(sLevelInfo, 1, "|")
                Else
                  sSetCommandItem = " chan " + sDevPXChanListLeft + " " + StringField(sLevelInfo, 1, "|")
                  If Len(sDevPXChanListRight) > 0
                    sSetCommandItem + " chan " + sDevPXChanListRight + " " + StringField(sLevelInfo, 2, "|")
                  EndIf
                EndIf
                debugMsg(sProcName, "sSetCommandItem=" + sSetCommandItem)
                sAudSetGainCommandString + sSetCommandItem
                
              EndIf
            EndIf
          Next d
      EndSelect
    EndIf
    
    If gbUseSMS ; SM-S
      \sSubFinalSetGainCommandString = sSubFinalSetGainCommandString
      If sAudSetGainCommandString
        ; tidy up sAudSetGainCommandString, converting double-spaces to single-spaces, and trimming result
        sSetGainCommandString = Trim(ReplaceString(sAudSetGainCommandString, "  ", " "))
        sendSMSCommand("set " + sSetGainCommandString)
      EndIf
    EndIf
    
    If nLCTime <= 0
      SLD_setMax(WQL\sldLCProgress, 1000)
    Else
      SLD_setMax(WQL\sldLCProgress, nLCTime)
    EndIf
    
    debugMsg(sProcName, "Q=" + \sCue + ", \nSubState=" + decodeCueState(\nSubState))
  EndWith

  ; if target cue is fading in then switch to playing to stop fading in
  With aAud(nLCAudPtr)
    If \nAudState = #SCS_CUE_FADING_IN
      \nAudState = #SCS_CUE_PLAYING
      setCueState(nLCCuePtr)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_START)
  
EndProcedure

Procedure editPLRestart()
  PROCNAMECS(nEditSubPtr)

  debugMsg(sProcName, #SCS_START)
  If nEditAudPtr >= 0
    restartAud(nEditAudPtr)
  EndIf

EndProcedure

Procedure editPLStop(pSubPtr)
  PROCNAMECS(pSubPtr)
  
  debugMsg(sProcName, #SCS_START)
  gqTimeNow = ElapsedMilliseconds()
  debugMsg(sProcName, "calling stopSub(" + pSubPtr + ", 'P', False, True)")
  stopSub(pSubPtr, "P", #False, #True)
  debugMsg(sProcName, "calling resetPlayList(" + pSubPtr + ")")
  resetPlayList(pSubPtr)
  If aSub(pSubPtr)\bStartedInEditor
    If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
      debugMsg(sProcName, "calling SelectElement(WQPFile(), " + Str(rWQP\nStartTrkNo - 1) + ")")
      SelectElement(WQPFile(), rWQP\nStartTrkNo - 1)
      debugMsg(sProcName, "calling WQP_highlightPlayListRow()")
      WQP_highlightPlayListRow()
    EndIf
  EndIf
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure editQAStop(pSubPtr, bResetPlaylist=#True)
  PROCNAMECS(pSubPtr)
  Protected n
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_STOP_QA, pSubPtr, 0, bResetPlaylist)
    ProcedureReturn
  EndIf
  
  debugMsg(sProcName, #SCS_START + ", bResetPlaylist=" + strB(bResetPlaylist))
  
  gqTimeNow = ElapsedMilliseconds()
  
  If nEditAudPtr >= 0
    If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_PICTURE And aAud(nEditAudPtr)\nImageFrameCount > 1
      If aAud(nEditAudPtr)\nAnimatedImageTimer
        RemoveWindowTimer(#WMN, aAud(nEditAudPtr)\nAnimatedImageTimer)
      EndIf
    EndIf
  EndIf
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubUseGaplessStream
        debugMsg(sProcName, "calling closeSub(" + getSubLabel(pSubPtr) + ", #True, #False)")
        closeSub(pSubPtr, #True, #False)
      Else
        debugMsg(sProcName, "calling stopSub(" + getSubLabel(pSubPtr) + ", 'A', False, True)")
        stopSub(pSubPtr, "A", #False, #True)
      EndIf
    EndWith
  EndIf
  
  If bResetPlaylist
    
    debugMsg(sProcName, "calling resetPlayList(" + getSubLabel(pSubPtr) + ")")
    resetPlayList(pSubPtr)
    ; debugMsg(sProcName, "rWQA\nStartFileNo=" + Str(rWQA\nStartFileNo))
    
    For n = 0 To gnWQALastItem
      WQAFile(n)\bSelected = #False
    Next n
    
    gnWQACurrItem = rWQA\nStartFileNo - 1
    If gnWQACurrItem >= 0
      WQAFile(gnWQACurrItem)\bSelected = #True
    EndIf
    
    debugMsg(sProcName, "calling WQA_highlightItem()")
    WQA_highlightItem()
    
    ; listCueStates(nEditCuePtr)
    
  EndIf
  
  ; added 25May2017 11.6.2ai following email from C.Peters about starting (in the main window) a cue with a linked MTC sub-cue, and then
  ; stopping the cue in the editor - the MTC kept running
  If aSub(pSubPtr)\nSubState = #SCS_CUE_READY
    editStopMTCSubIfLinked(pSubPtr)
  EndIf
  ; end added 25May2017 11.6.2ai
  
  gbCallLoadDispPanels = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure editSetDisplayButtonsF()
  PROCNAMECA(nEditAudPtr)
  Protected bEnableRelease, bEnableFadeOut, d, l2, bEnableOther
  ; Protected bEnableRename
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    
    ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState))
    l2 = rWQF\nDisplayedLoopInfoIndex
    If l2 >= 0
      If \aLoopInfo(l2)\nAbsLoopEnd > 0
        If \aLoopInfo(l2)\bLoopReleased = #False
          bEnableRelease = #True
        EndIf
      EndIf
    EndIf
    
    If \nFadeOutTime > 0
      If Not (\nAudState = #SCS_CUE_PAUSED Or \nAudState = #SCS_CUE_FADING_OUT)
        bEnableFadeOut = #True
      EndIf
    EndIf
    
    If \bAudPlaceHolder = #False
      If \sFileName
        If (\nAudState < #SCS_CUE_FADING_IN Or \nAudState > #SCS_CUE_FADING_OUT) And \nAudState <= #SCS_CUE_COMPLETED
          ; bEnableRename = #True
          bEnableOther = #True
        EndIf
      EndIf
    EndIf
    ; setEnabled(WQF\btnRename, bEnableRename)
    setEnabled(WQF\btnOther, bEnableOther)
    
    ; debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nRelFilePos=" + \nRelFilePos + ", \nPlayFromPos=" + \nPlayFromPos)
    
    If \nAudState <= #SCS_CUE_READY Or \nAudState >= #SCS_CUE_STANDBY
      If \nRelFilePos = 0 Or \nAudState > #SCS_CUE_COMPLETED
        setEnabled(WQF\btnEditRewind, #False)
      Else
        setEnabled(WQF\btnEditRewind, #True)
      EndIf
      setVisible(WQF\btnEditPlay, #True)
      If \nFileState = #SCS_FILESTATE_OPEN
        setEnabled(WQF\btnEditPlay, #True)
      Else
        setEnabled(WQF\btnEditPlay, #False)
      EndIf
      setVisible(WQF\btnEditPause, #False)
      setEnabled(WQF\btnEditPause, #False)
      setEnabled(WQF\btnEditRelease, #False)
      setEnabled(WQF\btnEditFadeOut, #False)
      setEnabled(WQF\btnEditStop, #False)
      WQF_setCboLogicalDevsEnabled()
      WQF_setCboTracksEnabled()
      
    Else
      setEnabled(WQF\btnEditRewind, #True)
      If \nAudState = #SCS_CUE_PAUSED
        setVisible(WQF\btnEditPlay, #True)
        setEnabled(WQF\btnEditPlay, #True)
        setVisible(WQF\btnEditPause, #False)
        setEnabled(WQF\btnEditPause, #False)
      Else
        setVisible(WQF\btnEditPlay, #False)
        setEnabled(WQF\btnEditPlay, #False)
        setVisible(WQF\btnEditPause, #True)
        setEnabled(WQF\btnEditPause, #True)
      EndIf
      setEnabled(WQF\btnEditRelease, bEnableRelease)
      setEnabled(WQF\btnEditFadeOut, bEnableFadeOut)
      setEnabled(WQF\btnEditStop, #True)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        setEnabled(WQF\cboLogicalDevF[d], #False)
        setEnabled(WQF\cboTracks[d], #False)
      Next d
      
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure editSetDisplayButtonsI()
  PROCNAMEC()
  Protected bEnableFadeOut, d
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    
    debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState) + ", \nFileState=" + decodeFileState(\nFileState))
    
    If \nFadeOutTime > 0
      If Not (\nAudState = #SCS_CUE_PAUSED Or \nAudState = #SCS_CUE_FADING_OUT)
        bEnableFadeOut = #True
      EndIf
    EndIf
    
    If \nAudState <= #SCS_CUE_READY Or \nAudState >= #SCS_CUE_STANDBY
      setVisible(WQI\btnEditPlay, #True)
      If \nFileState = #SCS_FILESTATE_OPEN
        setEnabled(WQI\btnEditPlay, #True)
      Else
        setEnabled(WQI\btnEditPlay, #False)
      EndIf
      setVisible(WQI\btnEditPause, #False)
      setEnabled(WQI\btnEditPause, #False)
      setEnabled(WQI\btnEditFadeOut, #False)
      setEnabled(WQI\btnEditStop, #False)
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        setEnabled(WQI\cboInputLogicalDev[d], #True)
      Next d
      setEnabled(WQI\cboInGrp, #True)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        setEnabled(WQI\cboLogicalDev[d], #True)
      Next d
      
    Else
      If \nAudState = #SCS_CUE_PAUSED
        setVisible(WQI\btnEditPlay, #True)
        setEnabled(WQI\btnEditPlay, #True)
        setVisible(WQI\btnEditPause, #False)
        setEnabled(WQI\btnEditPause, #False)
      Else
        setVisible(WQI\btnEditPlay, #False)
        setEnabled(WQI\btnEditPlay, #False)
        setVisible(WQI\btnEditPause, #True)
        setEnabled(WQI\btnEditPause, #True)
      EndIf
      setEnabled(WQI\btnEditFadeOut, bEnableFadeOut)
      setEnabled(WQI\btnEditStop, #True)
      For d = 0 To grLicInfo\nMaxLiveDevPerAud
        setEnabled(WQI\cboInputLogicalDev[d], #False)
      Next d
      setEnabled(WQI\cboInGrp, #False)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        setEnabled(WQI\cboLogicalDev[d], #False)
      Next d
      
    EndIf
  EndWith
  ;    Call debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure editSetDisplayButtonsL()
  PROCNAMEC()
  Protected d, bEnableReset, nIndex, bPlaying, bEnable
  Protected nLCSubPtr, nLCAudPtr
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr < 0
    ; shouldn't happen
    ProcedureReturn
  EndIf
  
  With aSub(nEditSubPtr)
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
  EndWith
  
  ; debugMsg(sProcName, "nLCSubPtr=" + getSubLabel(nLCSubPtr))
  If nLCSubPtr >= 0
    If aSub(nLCSubPtr)\bSubTypeAorF Or aSub(nLCSubPtr)\bSubTypeI   ; target is A, F or I
      If nLCAudPtr >= 0
        With aAud(nLCAudPtr)
          If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            bPlaying = #True
          EndIf
          If \nAudState <= #SCS_CUE_READY Or \nAudState >= #SCS_CUE_STANDBY Or \nAudState = #SCS_CUE_PAUSED Or \nAudState = #SCS_CUE_PL_READY
            setVisibleAndEnabled(WQL\btnLCPlay, #True)
            setVisibleAndEnabled(WQL\btnLCPause, #False)
          Else
            setVisibleAndEnabled(WQL\btnLCPlay, #False)
            setVisibleAndEnabled(WQL\btnLCPause, #True)
          EndIf
          If \nAudState <= #SCS_CUE_READY Or \nAudState >= #SCS_CUE_STANDBY Or \nAudState = #SCS_CUE_PL_READY
            setEnabled(WQL\btnLCRewind, #False)
            setEnabled(WQL\btnLCStop, #False)
            setEnabled(WQL\btnTestLevelChange, #False)
          Else
            If aSub(nLCSubPtr)\bSubTypeI
              setEnabled(WQL\btnLCRewind, #False)
            Else
              setEnabled(WQL\btnLCRewind, #True)
            EndIf
            setEnabled(WQL\btnLCStop, #True)
            If aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY
              setEnabled(WQL\btnTestLevelChange, #True)
            Else
              setEnabled(WQL\btnTestLevelChange, #False)
            EndIf
          EndIf
        EndWith
      Else
        setEnabled(WQL\btnLCRewind, #False)
        setVisible(WQL\btnLCPlay, #True)
        setVisible(WQL\btnLCPause, #False)
        setEnabled(WQL\btnLCPlay, #False)
        setEnabled(WQL\btnLCPause, #False)
        setEnabled(WQL\btnLCStop, #False)
        setEnabled(WQL\btnTestLevelChange, #False)
      EndIf
      
      bEnableReset = #False
      With aSub(nEditSubPtr)
        If nLCAudPtr >= 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If \bLCInclude[d]
              If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                If \fLCReqdBVLevel[d] <> \fLCInitBVLevel[d]
                  bEnableReset = #True
                EndIf
              Else
                If \fLCReqdBVLevel[d] <> grLevels\fPlusZeroBV
                  bEnableReset = #True
                EndIf
              EndIf
              If \fLCReqdPan[d] <> \fLCInitPan[d]
                bEnableReset = #True
              EndIf
            EndIf
          Next d
        EndIf
      EndWith
      setEnabled(WQL\btnLCReset, bEnableReset)
      
    ElseIf aSub(nLCSubPtr)\bSubTypeP ; target is P
      With aSub(nLCSubPtr)
        If \nSubState >= #SCS_CUE_FADING_IN And \nSubState <= #SCS_CUE_FADING_OUT
          bPlaying = #True
        EndIf
        If \nSubState <= #SCS_CUE_READY Or \nSubState >= #SCS_CUE_STANDBY Or \nSubState = #SCS_CUE_PAUSED Or \nSubState = #SCS_CUE_PL_READY
          setVisibleAndEnabled(WQL\btnLCPlay, #True)
          setVisibleAndEnabled(WQL\btnLCPause, #False)
        Else
          setVisibleAndEnabled(WQL\btnLCPlay, #False)
          setVisibleAndEnabled(WQL\btnLCPause, #True)
        EndIf
        If \nSubState <= #SCS_CUE_READY Or \nSubState >= #SCS_CUE_STANDBY Or \nSubState = #SCS_CUE_PL_READY
          setEnabled(WQL\btnLCRewind, #False)
          setEnabled(WQL\btnLCStop, #False)
          setEnabled(WQL\btnTestLevelChange, #False)
        Else
          setEnabled(WQL\btnLCRewind, #True)
          setEnabled(WQL\btnLCStop, #True)
          If aSub(nEditSubPtr)\nSubState <= #SCS_CUE_READY
            setEnabled(WQL\btnTestLevelChange, #True)
          Else
            setEnabled(WQL\btnTestLevelChange, #False)
          EndIf
        EndIf
      EndWith
    Else
      setEnabled(WQL\btnLCRewind, #False)
      setVisible(WQL\btnLCPlay, #True)
      setVisible(WQL\btnLCPause, #False)
      setEnabled(WQL\btnLCPlay, #False)
      setEnabled(WQL\btnLCPause, #False)
      setEnabled(WQL\btnLCStop, #False)
      setEnabled(WQL\btnTestLevelChange, #False)
    EndIf
    
  Else
    setEnabled(WQL\btnLCRewind, #False)
    setVisible(WQL\btnLCPlay, #True)
    setVisible(WQL\btnLCPause, #False)
    setEnabled(WQL\btnLCPlay, #False)
    setEnabled(WQL\btnLCPause, #False)
    setEnabled(WQL\btnLCStop, #False)
    setEnabled(WQL\btnTestLevelChange, #False)
    
  EndIf
  
  With aSub(nEditSubPtr)
    If nLCSubPtr >= 0
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \bLCInclude[d]
          If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
            If \fLCReqdBVLevel[d] <> \fLCInitBVLevel[d]
              bEnableReset = #True
            EndIf
          Else
            If \fLCReqdBVLevel[d] <> grLevels\fPlusZeroBV
              bEnableReset = #True
            EndIf
          EndIf
          If \fLCReqdPan[d] <> \fLCInitPan[d]
            bEnableReset = #True
          EndIf
        EndIf
      Next d
    EndIf
  EndWith
  setEnabled(WQL\btnLCReset, bEnableReset)
  
  If bPlaying
    bEnable = #False
  Else
    bEnable = #True
  EndIf
  setEnabled(WQL\cboLCCue, bEnable)
  For d = 0 To grLicInfo\nMaxAudDevPerAud
    If IsGadget(WQL\chkLCInclude[d])
      setOwnEnabled(WQL\chkLCInclude[d], bEnable)
    EndIf
  Next d
  
EndProcedure

Procedure editSetDisplayButtonsM()
  PROCNAMEC()
  Protected bEnableRename
  Protected nAudPtr
  
  nAudPtr = aSub(nEditSubPtr)\nFirstAudIndex
  ; debugMsg(sProcName, "nAudPtr=" + nAudPtr)
  If nAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nAudPtr)
    
    debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(\nAudState))
    
    If (\nAudState <= #SCS_CUE_READY) Or (\nAudState >= #SCS_CUE_STANDBY)
      If \nRelFilePos = 0
        setEnabled(WQM\btnEditRewind, #False)
      Else
        setEnabled(WQM\btnEditRewind, #True)
      EndIf
      setVisible(WQM\btnEditPlay, #True)
      ; setEnabled(WQM\btnEditPlay, #False)     ; disable play if file playback not yet started as user must use one of the test buttons
      setEnabled(WQM\btnEditPlay, #True)
      setVisible(WQM\btnEditPause, #False)
      setEnabled(WQM\btnEditPause, #False)
      setEnabled(WQM\btnEditStop, #False)
      
    Else
      setEnabled(WQM\btnEditRewind, #True)
      If \nAudState = #SCS_CUE_PAUSED
        setVisible(WQM\btnEditPlay, #True)
        setEnabled(WQM\btnEditPlay, #True)    ; enable play if user has paused playback
        setVisible(WQM\btnEditPause, #False)
        setEnabled(WQM\btnEditPause, #False)
      Else
        setVisible(WQM\btnEditPlay, #False)
        setEnabled(WQM\btnEditPlay, #False)
        setVisible(WQM\btnEditPause, #True)
        setEnabled(WQM\btnEditPause, #True)
      EndIf
      setEnabled(WQM\btnEditStop, #True)
      
    EndIf
  EndWith
EndProcedure

Procedure editSetDisplayButtonsP()
  PROCNAMEC()
  Protected d, nState, bEnableIfNotPlaying
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If nEditSubPtr >= 0 And nEditAudPtr >= 0
    nState = aSub(nEditSubPtr)\nSubState
  Else
    nState = #SCS_CUE_NOT_LOADED
  EndIf
  
  If nEditAudPtr >= 0
    debugMsg(sProcName, "\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState) + ", aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(aAud(nEditAudPtr)\nAudState))
  Else
    debugMsg(sProcName, "\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState))
  EndIf
  
  If (nState <= #SCS_CUE_READY) Or (nState >= #SCS_CUE_STANDBY) Or (nState = #SCS_CUE_PL_READY)
    bEnableIfNotPlaying = #True
    setEnabled(WQP\btnPLRewind, #False)
    If nState = #SCS_CUE_NOT_LOADED
      setEnabled(WQP\btnPLPlay, #False)
      setEnabled(WQP\btnPLShuffle, #False)
      setEnabled(WQP\txtTransTime, #False)
      setEnabled(WQP\cboTransType, #False)
      setEnabled(WQP\btnPLOther, #False)
    Else
      setEnabled(WQP\btnPLPlay, #True)
      setEnabled(WQP\btnPLShuffle, aSub(nEditSubPtr)\bPLRandom)
      If aAud(nEditAudPtr)\nPLTransType = #SCS_TRANS_NONE
        setEnabled(WQP\txtTransTime, #False)
      Else
        setEnabled(WQP\txtTransTime, #True)
      EndIf
      setEnabled(WQP\cboTransType, #True)
      setEnabled(WQP\btnPLOther, #True)
    EndIf
    setVisible(WQP\btnPLPlay, #True)
    setEnabled(WQP\btnPLPause, #False)
    setVisible(WQP\btnPLPause, #False)
    setEnabled(WQP\btnPLFadeOut, #False)
    setEnabled(WQP\btnPLStop, #False)
    CompilerIf #c_include_mygrid_for_playlists = #False
      setEnabled(WQP\scaFiles, #True)
    CompilerEndIf
    setEnabled(WQP\cntPlaylistSideBar, #True)
    setOwnEnabled(WQP\chkPLRandom, #True)
    setOwnEnabled(WQP\chkPLRepeat, #True)
    setOwnEnabled(WQP\chkPLSavePos, #True)
    setEnabled(WQP\cboPLTestMode, #True)
    WQP_setCboPLLogicalDevsEnabled()
    WQP_setCboPLTracksEnabled()
  Else
    setEnabled(WQP\btnPLRewind, #True)
    If nState = #SCS_CUE_PAUSED
      setVisible(WQP\btnPLPlay, #True)
      setEnabled(WQP\btnPLPlay, #True)
      setVisible(WQP\btnPLPause, #False)
      setEnabled(WQP\btnPLPause, #False)
    Else
      setVisible(WQP\btnPLPlay, #False)
      setEnabled(WQP\btnPLPlay, #False)
      setVisible(WQP\btnPLPause, #True)
      setEnabled(WQP\btnPLPause, #True)
    EndIf
    If (nState = #SCS_CUE_PAUSED) Or (aSub(nEditSubPtr)\nSubState = #SCS_CUE_FADING_OUT) Or (aSub(nEditSubPtr)\nPLFadeOutTime <= 0)
      setEnabled(WQP\btnPLFadeOut, #False)
    Else
      setEnabled(WQP\btnPLFadeOut, #True)
    EndIf
    setEnabled(WQP\btnPLStop, #True)
    CompilerIf #c_include_mygrid_for_playlists = #False
      setEnabled(WQP\scaFiles, #False)
    CompilerEndIf
    setEnabled(WQP\cntPlaylistSideBar, #False)
    For d = 0 To grLicInfo\nMaxAudDevPerSub
      setEnabled(WQP\cboPLLogicalDev[d], #False)
      setEnabled(WQP\cboPLTracks[d], #False)
    Next d
    setOwnEnabled(WQP\chkPLRandom, #False)
    setEnabled(WQP\btnPLShuffle, #False)
    setOwnEnabled(WQP\chkPLRepeat, #False)
    setOwnEnabled(WQP\chkPLSavePos, #False)
    setEnabled(WQP\cboPLTestMode, #False)
    setEnabled(WQP\txtTransTime, #False)
    setEnabled(WQP\cboTransType, #False)
    setEnabled(WQP\btnPLOther, #True)
  EndIf
  
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_TrimSilenceSel, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim30Sel, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim45Sel, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim60Sel, bEnableIfNotPlaying) ; Added 3Oct2022 11.9.6
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim75Sel, bEnableIfNotPlaying) ; Added 3Oct2022 11.9.6
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_ResetSel, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_ClearSel, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_TrimSilenceAll, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim30All, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim45All, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim60All, bEnableIfNotPlaying) ; Added 3Oct2022 11.9.6
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_Trim75All, bEnableIfNotPlaying) ; Added 3Oct2022 11.9.6
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_ResetAll, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_ClearAll, bEnableIfNotPlaying)
  scsEnableMenuItem(#WQP_mnu_Other, #WQP_mnu_RemoveAllFiles, bEnableIfNotPlaying)
  
  setTextBoxBackColor(WQP\txtTransTime)
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure editStopLCSub(pSubPtr)
  ; NOTE: CHANGED 17Dec2024 11.10.6bv following issues found when testing for 'Tutorial 5C - Level Change Cues'
  PROCNAMECS(pSubPtr)
  Protected nLCSubPtr, nLCAudPtr

  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr < 0
    ProcedureReturn
  EndIf
  
  With aSub(pSubPtr)
    nLCSubPtr = \nLCSubPtr
    nLCAudPtr = \nLCAudPtr
  EndWith
  
  If nLCAudPtr < 0
    ProcedureReturn
  EndIf
  
  ; MUST be called from the main thread or the procedure can lock up in PNL_setDisplayButtons() which is called from reposAuds()
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_STOP_LC_SUB, pSubPtr)
    ProcedureReturn
  EndIf
  
  With aAud(nLCAudPtr)
    stopAud(nLCAudPtr, #True)
    reposAuds(nLCAudPtr, \nAbsStartAt)
    debugMsg(sProcName, "calling setCueState(" + getCueLabel(\nCueIndex) + ")")
    setCueState(\nCueIndex)
    updateScreenForCue(\nCueIndex)
  EndWith
  
  With aSub(pSubPtr)
    \nSubState = #SCS_CUE_READY
    debugMsg(sProcName, "calling setCueState(" + getCueLabel(\nCueIndex) + ")")
    setCueState(\nCueIndex)
    updateScreenForCue(\nCueIndex)
    \bTestingLevelChange = #False
  EndWith

  debugMsg(sProcName, "calling editUpdateDisplay()")
  editUpdateDisplay()
  
  editSetDisplayButtonsL()
  SAG(-1)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure editStopMTCSubIfLinked(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nCuePtr, j
  ; added 25May2017 11.6.2ai following email from C.Peters about starting (in the main window) a cue with a linked MTC sub-cue, and then
  ; stopping the cue in the editor - the MTC kept running
  
  If aSub(pSubPtr)\nSubState = #SCS_CUE_READY
    nCuePtr = aSub(pSubPtr)\nCueIndex
    If aCue(nCuePtr)\bSubTypeU
      j = aCue(nCuePtr)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeU
          If aSub(j)\nMTCLinkedToAFSubPtr = pSubPtr
            debugMsg(sProcName, "calling stopSub(" + getSubLabel(j) + ", 'U', #False, #False)")
            stopSub(j, "U", #False, #False)
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  EndIf
  ; end added 25May2017 11.6.2ai
EndProcedure

Procedure editUpdateDisplay(bForcePositionDisplay=#False)
  PROCNAMEC()
  Protected sInfo.s, sStatus.s, nState
  Protected nPos, nAbsPos, sAbsPos.s, nReqdLeft, nReqdWidth, d, l2
  Protected fTmpLevel.f, sOtherInfoText.s
  Protected nReqdSldValue
  Protected bRelativeLevel
  Protected fTmpPan.f
  Protected nSldPan
  Protected nAudPtr
  Protected nLCSubPtr, nLCAudPtr
  Protected sGoInfoText.s
  Protected bQAGraphDisplayed
  Protected bDisplayPan
  Static sCont5Secs.s
  Static bOtherInfoOriginalSettingsLoaded, nOtherInfoOriginalLeft, nOtherInfoOriginalWidth
  
  ; debugMsg(sProcName, #SCS_START + ", bForcePositionDisplay=" + strB(bForcePositionDisplay))
  
  If gbClosingDown
    debugMsg0(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  gbCallEditUpdateDisplay = #False

  If nEditSubPtr < 0
    debugMsg(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  ; added 29Oct2016 11.5.2.4 as procedure can be called after window has been closed in checkDataChanged()
  If IsWindow(#WED) = 0
    debugMsg0(sProcName, "exiting")
    ProcedureReturn
  EndIf
  ; end added 29Oct2016 11.5.2.4  
  
  gbInEditUpdateDisplay = #True
  
  If grWED\bFlickerTemplateInfo
    WED_flickerTemplateInfo()
  EndIf
  
  ; ------------------------------------------------- VIDEO
  If (grCED\sDisplayedSubType = "A") And (nEditAudPtr >= 0) And (aSub(nEditSubPtr)\bSubTypeA)
    ;{
    nState = aSub(nEditSubPtr)\nSubState
    
    If nEditAudPtr >= 0
      If aAud(nEditAudPtr)\nFileFormat = #SCS_FILEFORMAT_VIDEO
        bQAGraphDisplayed = #True
      EndIf
    EndIf
    
    If (nState >= #SCS_CUE_READY And nState <= #SCS_CUE_FADING_OUT) Or (nState = #SCS_CUE_PL_READY)
      calcPLPosition(nEditSubPtr)
      With aSub(nEditSubPtr)
        If \nPLCuePosition > SLD_getMax(WQA\sldProgress[1])
          SLD_setValue(WQA\sldProgress[1], SLD_getMax(WQA\sldProgress[1]))
        ElseIf \nPLCuePosition >= 0 And SLD_getValue(WQA\sldProgress[1]) <> \nPLCuePosition
          SLD_setValue(WQA\sldProgress[1], \nPLCuePosition)
        EndIf
      EndWith
      If nEditAudPtr >= 0
        With aAud(nEditAudPtr)
          If bQAGraphDisplayed
            drawPosSlice(@grMG5)
          Else
            If \nCuePos > SLD_getMax(WQA\sldProgress[0])
              SLD_setValue(WQA\sldProgress[0], SLD_getMax(WQA\sldProgress[0]))
            ElseIf \nCuePos >= 0 And SLD_getValue(WQA\sldProgress[0]) <> \nCuePos
              SLD_setValue(WQA\sldProgress[0], \nCuePos)
            EndIf
          EndIf
        EndWith
      Else
        If SLD_getValue(WQA\sldProgress[0]) <> 0
          SLD_setValue(WQA\sldProgress[0], 0)
        EndIf
      EndIf
      
    ElseIf nState = #SCS_CUE_COMPLETED
      If bQAGraphDisplayed = #False
        If SLD_getValue(WQA\sldProgress[0]) <> SLD_getMax(WQA\sldProgress[0])
          SLD_setValue(WQA\sldProgress[0], SLD_getMax(WQA\sldProgress[0]))
        EndIf
      EndIf
      If SLD_getValue(WQA\sldProgress[1]) <> SLD_getMax(WQA\sldProgress[1])
        SLD_setValue(WQA\sldProgress[1], SLD_getMax(WQA\sldProgress[1]))
      EndIf
      
    ElseIf nState >= #SCS_CUE_STANDBY
      If SLD_getValue(WQA\sldProgress[1]) <> aSub(nEditSubPtr)\nPLCuePosition
        SLD_setValue(WQA\sldProgress[1], aSub(nEditSubPtr)\nPLCuePosition)
      EndIf
      
    EndIf
    
    If gnEditPrevCueState <> nState
      gnEditPrevCueState = nState
      WQA_SetTransportButtons()
    EndIf
    ;}
    ; ------------------------------------------------- AUDIO FILE
  ElseIf (grCED\sDisplayedSubType = "F") And (nEditAudPtr >= 0) And (aSub(nEditSubPtr)\bSubTypeF) And (rWQF\bChangingCurrPos = #False)
    ;{
    With aAud(nEditAudPtr)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nRelFilePos=" + \nRelFilePos + ", \nAudState=" + decodeCueState(\nAudState) + ", bForcePositionDisplay=" + strB(bForcePositionDisplay))
      
      nReqdSldValue = \nRelFilePos
      If nReqdSldValue < 0
        nReqdSldValue = 0
      ElseIf nReqdSldValue > SLD_getMax(WQF\sldProgress)
        nReqdSldValue = SLD_getMax(WQF\sldProgress)
      EndIf
      ; debugMsg(sProcName, "nReqdSldValue=" + Str(nReqdSldValue))
      
      If bForcePositionDisplay
        ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, " + nReqdSldValue + ")")
        SLD_setValue(WQF\sldProgress, nReqdSldValue)
        drawPosSlice(@grMG2)
        
      ElseIf (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
        If rWQF\bEditProgMouseDown = #False
          If SLD_getValue(WQF\sldProgress) <> nReqdSldValue
            ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, " + nReqdSldValue + ")")
            SLD_setValue(WQF\sldProgress, nReqdSldValue)
          EndIf
        EndIf
        drawPosSlice(@grMG2)
        
      ElseIf SLD_getValue(WQF\sldProgress) <> nReqdSldValue
        ; debugMsg(sProcName, "calling SLD_setValue(WQF\sldProgress, " + nReqdSldValue + ")")
        SLD_setValue(WQF\sldProgress, nReqdSldValue)
        drawPosSlice(@grMG2)
        
      EndIf
      
      ; debugMsg(sProcName, "d=" + d + ", grLicInfo\nMaxAudDevPerAud=" + Str(grLicInfo\nMaxAudDevPerAud) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
      If rWQF\bDisplayingLevelPoint = #False
        For d = 0 To grLicInfo\nMaxAudDevPerAud
          If \nBassChannel[d] <> 0
            If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
              fTmpLevel = \fCueTotalVolNow[d]
              fTmpPan = \fCuePanNow[d]
            Else
              fTmpLevel = \fBVLevel[d]
              fTmpPan = \fPan[d]
            EndIf
            If (SLD_getLevel(WQF\sldLevel[d]) <> fTmpLevel) Or (SLD_getTrimFactor(WQF\sldLevel[d]) <> \fTrimFactor[d])
              ; debugMsg0(sProcName, "calling SLD_setLevel(), SLD_getLevel(WQF\sldLevel[d])=" + SLD_getLevel(WQF\sldLevel[d]) + ", fTmpLevel=" + fTmpLevel + ", SLD_getTrimFactor(WQF\sldLevel[d])=" + SLD_getTrimFactor(WQF\sldLevel[d]) + ", \fTrimFactor[d]=" + \fTrimFactor[d]) ; 17Feb2022
              SLD_setLevel(WQF\sldLevel[d], fTmpLevel, \fTrimFactor[d])
              SGT(WQF\txtDBLevel[d], convertBVLevelToDBStringWithMinusInf(fTmpLevel))
            EndIf
            If \bDisplayPan[d]
              nSldPan = panToSliderValue(fTmpPan)
              If SLD_getValue(WQF\sldPan[d]) <> nSldPan
                SLD_setValue(WQF\sldPan[d], nSldPan)
                ; debugMsg(sProcName, "SLD_setValue(WQF\sldPan[" + d + "], " + nSldPan + "), \fCuePanNow[" + d + "]=" + formatPan(\fCuePanNow[d]))
                If fTmpPan = #SCS_PANCENTRE_SINGLE
                  setEnabled(WQF\btnCenter[d], #False)
                Else
                  setEnabled(WQF\btnCenter[d], #True)
                EndIf
                SetGadgetText(WQF\txtPan[d], panSingleToString(fTmpPan))
              EndIf
            EndIf
          EndIf
        Next d
      EndIf
      
      nAbsPos = \nRelFilePos + \nAbsMin
      sAbsPos = timeToStringT(nAbsPos, \nFileDuration)
      If GGT(WQF\txtCurrPos) <> sAbsPos
        SGT(WQF\txtCurrPos, sAbsPos)
        ; debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos + ", \nAbsMin=" + \nAbsMin + ", sAbsPos=" + sAbsPos)
      EndIf
      
      If gnEditPrevCueState <> \nAudState
        gnEditPrevCueState = \nAudState
        SGT(WQF\lblInfo, gaCueState(\nAudState))
        editSetDisplayButtonsF()
      EndIf
      
      sOtherInfoText = loadOtherInfoTextForAud(nEditAudPtr, sOtherInfoText)
      If GetGadgetText(WQF\lblOtherInfo) <> sOtherInfoText
        debugMsg(sProcName, "\nRelFilePos=" + \nRelFilePos + ", sOtherInfoText=" + sOtherInfoText)
        SGT(WQF\lblOtherInfo, sOtherInfoText)
        ; Added 30Mar2022 11.9.1ax following email from Jason Mai about info being displayed 'under stop button', so now positiong left but preferably left as from the start position of the first transport button
        ; adjust position of \lblOtherInfo if required
        If bOtherInfoOriginalSettingsLoaded = #False
          nOtherInfoOriginalLeft = GadgetX(WQF\lblOtherInfo)
          nOtherInfoOriginalWidth = GadgetWidth(WQF\lblOtherInfo)
          bOtherInfoOriginalSettingsLoaded = #True
        EndIf
        nReqdLeft = GadgetX(WQF\btnEditRewind)
        nReqdWidth = nOtherInfoOriginalWidth - (nReqdLeft - nOtherInfoOriginalLeft)
        ; debugMsg0(sProcName, "nReqdLeft=" + nReqdLeft + ", nReqdWidth=" + nReqdWidth)
        If GadgetWidth(WQF\lblOtherInfo, #PB_Gadget_RequiredSize) > nReqdWidth
          nReqdLeft = nOtherInfoOriginalLeft
          nReqdWidth = nOtherInfoOriginalWidth
        EndIf
        If GadgetX(WQF\lblOtherInfo) <> nReqdLeft Or GadgetWidth(WQF\lblOtherInfo) <> nReqdWidth
          ResizeGadget(WQF\lblOtherInfo, nReqdLeft, #PB_Ignore, nReqdWidth, #PB_Ignore)
        EndIf
        ; End added 30Mar2022 11.9.1ax
        ; call WQF_setReleaseBtnState() because a new loop may now be current
        debugMsg(sProcName, "calling WQF_setReleaseBtnState()")
        WQF_setReleaseBtnState()
      EndIf
      
    EndWith
    ;}
    ; ------------------------------------------------- LIVE INPUT
  ElseIf (grCED\sDisplayedSubType = "I") And (nEditAudPtr >= 0) And (aSub(nEditSubPtr)\bSubTypeI)
    ;{
    With aAud(nEditAudPtr)
      
      ; debugMsg(sProcName, "d=" + d + ", grLicInfo\nMaxAudDevPerAud=" + Str(grLicInfo\nMaxAudDevPerAud) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If \nBassChannel[d] <> 0
          If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            fTmpLevel = \fCueTotalVolNow[d]
          Else
            fTmpLevel = \fBVLevel[d]
          EndIf
          If SLD_getLevel(WQI\sldLevel[d]) <> fTmpLevel
            SLD_setLevel(WQI\sldLevel[d], fTmpLevel)
            SGT(WQI\txtDBLevel[d], convertBVLevelToDBString(fTmpLevel, #False, #True))
          EndIf
        EndIf
      Next d
      
      If gnEditPrevCueState <> \nAudState
        gnEditPrevCueState = \nAudState
        SGT(WQI\lblInfo, gaCueState(\nAudState))
        editSetDisplayButtonsI()
      EndIf
      
    EndWith
    ;}
    ; ------------------------------------------------- CTRL SEND
  ElseIf (grCED\sDisplayedSubType = "M") And (aSub(nEditSubPtr)\bSubTypeM)
    ;{
    nAudPtr = aSub(nEditSubPtr)\nFirstAudIndex
    If nAudPtr >= 0
      With aAud(nAudPtr)
        
        If bForcePositionDisplay
          SLD_setValue(WQM\sldProgress, \nRelFilePos)
          
        ElseIf SLD_getValue(WQM\sldProgress) <> \nRelFilePos
          SLD_setValue(WQM\sldProgress, \nRelFilePos)
          
        EndIf
        
        If gnEditPrevCueState <> \nAudState
          gnEditPrevCueState = \nAudState
          SGT(WQM\lblInfo, gaCueState(\nAudState))
          editSetDisplayButtonsM()
        EndIf
        
      EndWith
    EndIf
    ;}
    ; ------------------------------------------------- PLAYLIST
  ElseIf (grCED\sDisplayedSubType = "P") And (nEditAudPtr >= 0) And (aSub(nEditSubPtr)\bSubTypeP)
    ;{
    If gnPLTestMode <> #SCS_PLTESTMODE_HIGHLIGHTED_FILE
      nState = aSub(nEditSubPtr)\nSubState
    ElseIf nEditAudPtr >= 0
      nState = aAud(nEditAudPtr)\nAudState
    Else
      nState = #SCS_CUE_NOT_LOADED
    EndIf
    
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nAudState=" + decodeCueState(aAud(nEditAudPtr)\nAudState))
    If (nState >= #SCS_CUE_READY And nState <= #SCS_CUE_FADING_OUT) Or (nState = #SCS_CUE_PL_READY)
      
      calcPLPosition(nEditSubPtr)
      ; debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nPLCuePosition=" + Str(aSub(nEditSubPtr)\nPLCuePosition))
      
      With aSub(nEditSubPtr)
        If \nPLCuePosition > SLD_getMax(WQP\sldPLProgress[1])
          SLD_setValue(WQP\sldPLProgress[1], SLD_getMax(WQP\sldPLProgress[1]))
          ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], " + Str(SLD_getMax(WQP\sldPLProgress[1])) + ")")
        ElseIf \nPLCuePosition >= 0 And SLD_getValue(WQP\sldPLProgress[1]) <> \nPLCuePosition
          SLD_setValue(WQP\sldPLProgress[1], \nPLCuePosition)
          ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], " + Str(\nPLCuePosition) + ")")
        EndIf
      EndWith
      
      If nEditAudPtr >= 0
        With aAud(nEditAudPtr)
          If \nCuePos > SLD_getMax(WQP\sldPLProgress[0])
            SLD_setValue(WQP\sldPLProgress[0], SLD_getMax(WQP\sldPLProgress[0]))
          ElseIf \nCuePos >= 0 And SLD_getValue(WQP\sldPLProgress[0]) <> \nCuePos
            SLD_setValue(WQP\sldPLProgress[0], \nCuePos)
          EndIf
        EndWith
      Else
        If SLD_getValue(WQP\sldPLProgress[0]) <> 0
          SLD_setValue(WQP\sldPLProgress[0], 0)
        EndIf
      EndIf
      
    ElseIf nState = #SCS_CUE_COMPLETED
      If SLD_getValue(WQP\sldPLProgress[0]) <> SLD_getMax(WQP\sldPLProgress[0])
        SLD_setValue(WQP\sldPLProgress[0], SLD_getMax(WQP\sldPLProgress[0]))
      EndIf
      If SLD_getValue(WQP\sldPLProgress[1]) <> SLD_getMax(WQP\sldPLProgress[1])
        SLD_setValue(WQP\sldPLProgress[1], SLD_getMax(WQP\sldPLProgress[1]))
      EndIf
      
    ElseIf nState >= #SCS_CUE_STANDBY
      If SLD_getValue(WQP\sldPLProgress[1]) <> aSub(nEditSubPtr)\nPLCuePosition
        SLD_setValue(WQP\sldPLProgress[1], aSub(nEditSubPtr)\nPLCuePosition)
        ; debugMsg(sProcName, "SLD_setValue(WQP\sldPLProgress[1], " + Str(aSub(nEditSubPtr)\nPLCuePosition) + ")")
      EndIf
      
    EndIf
    
    If gnEditPrevCueState <> nState
      gnEditPrevCueState = nState
      SGT(WQP\lblPLInfo, gaCueState(nState))
      editSetDisplayButtonsP()
    EndIf
    ;}
    ; ------------------------------------------------- LEVEL CHANGE
  ElseIf (grCED\sDisplayedSubType = "L") And (aSub(nEditSubPtr)\bSubTypeL)
    ;{
    With aSub(nEditSubPtr)
      nLCSubPtr = \nLCSubPtr
      nLCAudPtr = \nLCAudPtr
      If \nLCAction = #SCS_LC_ACTION_RELATIVE
        bRelativeLevel = #True
      EndIf
    EndWith
    
    sInfo = ""
    If nLCAudPtr >= 0
      With aAud(nLCAudPtr)
        If (\nAudState >= #SCS_CUE_FADING_IN And \nAudState <= #SCS_CUE_FADING_OUT)
          getChannelAttributes(nLCAudPtr)
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If (aSub(nEditSubPtr)\sLCLogicalDev[d] And aSub(nEditSubPtr)\bLCDevPresent[d]) And (aSub(nEditSubPtr)\bLCInclude[d])
              If bRelativeLevel = #False
                fTmpLevel = \fCueVolNow[d]
                fTmpPan   = \fCuePanNow[d]
                If aSub(\nSubIndex)\bSubTypeAorP
                  fTmpLevel * (100.0 / \fPLRelLevel)
                EndIf
                If rWQL\bLvlManualOverride[d] = #False
; NOTE: CHANGED 17Dec2024 11.10.6bv following issues found when testing for 'Tutorial 5C - Level Change Cues'
;                   If SLD_getLevel(WQL\sldLCLevel[d]) <> fTmpLevel
;                     SLD_setLevel(WQL\sldLCLevel[d], fTmpLevel, \fTrimFactor[d])
;                     SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(fTmpLevel, #False, #True))
;                   EndIf
                  If SLD_getBaseLevel(WQL\sldLCLevel[d]) <> fTmpLevel
                    SLD_setBaseLevel(WQL\sldLCLevel[d], fTmpLevel, \fTrimFactor[d])
                    ; SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(fTmpLevel, #False, #True))
                  EndIf
                EndIf
              EndIf
              If \bDisplayPan[d]
                If rWQL\bPanManualOverride[d] = #False
                  ; NOTE: CHANGED 23Dec2024 11.10.6by following issues found when testing for 'Tutorial 5C - Level Change Cues'
                  ;                 If SLD_getValue(WQL\sldLCPan[d]) <> panToSliderValue(\fCuePanNow[d])
                  ;                   SLD_setValue(WQL\sldLCPan[d], panToSliderValue(\fCuePanNow[d]))
                  ;                   SGT(WQL\txtLCPan[d], panSingleToString(\fCuePanNow[d]))
                  ;                 EndIf
                  If SLD_getBaseValue(WQL\sldLCPan[d]) <> panToSliderValue(fTmpPan)
                    ; debugMsg0(sProcName, "calling SLD_setBaseValue(WQL\sldLCPan[" + d + "], " + panToSliderValue(fTmpPan) + ")")
                    SLD_setBaseValue(WQL\sldLCPan[d], panToSliderValue(fTmpPan))
                    ; SGT(WQL\txtLCPan[d], panSingleToString(fTmpPan))
                  EndIf
                EndIf
              EndIf
            EndIf
          Next d
        Else
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If (aSub(nEditSubPtr)\sLCLogicalDev[d] And aSub(nEditSubPtr)\bLCDevPresent[d]) And (aSub(nEditSubPtr)\bLCInclude[d])
              If bRelativeLevel = #False
                fTmpLevel = \fSavedBVLevel[d]
                fTmpPan   = \fSavedPan[d]
; NOTE: CHANGED 17Dec2024 11.10.6bv following issues found when testing for 'Tutorial 5C - Level Change Cues'
;                 If SLD_getLevel(WQL\sldLCLevel[d]) <> fTmpLevel
;                   SLD_setLevel(WQL\sldLCLevel[d], fTmpLevel, \fTrimFactor[d])
;                   SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(fTmpLevel, #False, #True))
;                 EndIf
                If SLD_getBaseLevel(WQL\sldLCLevel[d]) <> fTmpLevel
                  SLD_setBaseLevel(WQL\sldLCLevel[d], fTmpLevel, \fTrimFactor[d])
                  ; SGT(WQL\txtLCDBLevel[d], convertBVLevelToDBString(fTmpLevel, #False, #True))
                EndIf
              EndIf
              If \bDisplayPan[d]
                ; NOTE: CHANGED 23Dec2024 11.10.6by following issues found when testing for 'Tutorial 5C - Level Change Cues'
                ;               If SLD_getValue(WQL\sldLCPan[d]) <> panToSliderValue(aSub(nEditSubPtr)\fLCReqdPan[d])
                ;                 SLD_setValue(WQL\sldLCPan[d], panToSliderValue(aSub(nEditSubPtr)\fLCReqdPan[d]))
                ;                 SGT(WQL\txtLCPan[d], panSingleToString(aSub(nEditSubPtr)\fLCReqdPan[d]))
                ;               EndIf
                If SLD_getBaseValue(WQL\sldLCPan[d]) <> panToSliderValue(fTmpPan)
                  ; debugMsg0(sProcName, "calling SLD_setBaseValue(WQL\sldLCPan[" + d + "], " + panToSliderValue(fTmpPan) + ")")
                  SLD_setBaseValue(WQL\sldLCPan[d], panToSliderValue(fTmpPan))
                  ; SGT(WQL\txtLCPan[d], panSingleToString(fTmpPan))
                EndIf
              EndIf
            EndIf
          Next d
        EndIf
        
        If gnEditPrevLCState <> \nAudState
          gnEditPrevLCState = \nAudState
          SGT(WQL\lblAudStatus, gaCueState(\nAudState))
          editSetDisplayButtonsL()
        EndIf
        If (\nFadeInTime > 0) And ((aSub(nEditSubPtr)\nLCStartAt > 0) Or (gsLCPrevCueType = "L"))
          sInfo = LTrim(sInfo + "  Fade In ignored.")
        EndIf
        
        If \nFadeOutTime > 0
          sInfo = LTrim(sInfo + "  Fade Out ignored.")
        EndIf
        
        If GetGadgetText(WQL\lblLCInfo) <> sInfo
          SGT(WQL\lblLCInfo, sInfo)
        EndIf
        
      EndWith
    EndIf
    
    If aSub(nEditSubPtr)\nSubState = #SCS_CUE_COMPLETED
      aSub(nEditSubPtr)\nLCPositionMax = 0
    EndIf
    
    nPos = aSub(nEditSubPtr)\nLCPositionMax
    If nPos > aSub(nEditSubPtr)\nLCTimeMax
      nPos = aSub(nEditSubPtr)\nLCTimeMax
    EndIf
    
    If nPos <> SLD_getValue(WQL\sldLCProgress)
      If nPos > SLD_getMax(WQL\sldLCProgress)
        SLD_setValue(WQL\sldLCProgress, SLD_getMax(WQL\sldLCProgress))
      Else
        If (nPos >= 0) And (nPos <= SLD_getMax(WQL\sldLCProgress))
          SLD_setValue(WQL\sldLCProgress, nPos)
        EndIf
      EndIf
    EndIf
    
    If gnEditPrevCueState <> aSub(nEditSubPtr)\nSubState
      gnEditPrevCueState = aSub(nEditSubPtr)\nSubState
      If aSub(nEditSubPtr)\nSubState = #SCS_CUE_NOT_LOADED
        SGT(WQL\lblLCSubStatus, "")
      Else
        SGT(WQL\lblLCSubStatus, gaCueState(aSub(nEditSubPtr)\nSubState))
      EndIf
      editSetDisplayButtonsL()
    EndIf
    
    If nLCSubPtr >= 0
      If aSub(nEditSubPtr)\bStartedInEditor ; Test added 22Nov2021 11.8.6cd
        ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nSubState=" + decodeCueState(aSub(nEditSubPtr)\nSubState) + ", aSub(" + getSubLabel(nLCSubPtr) + ")\nSubState=" + decodeCueState(aSub(nLCSubPtr)\nSubState))
        If (aSub(nEditSubPtr)\nSubState = #SCS_CUE_COMPLETED) And (aSub(nLCSubPtr)\nSubState = #SCS_CUE_PLAYING)
          If Len(sCont5Secs) = 0
            sCont5Secs = Lang("WQL", "cont5secs")
          EndIf
          sStatus = sCont5Secs  ; "Continuing for 5 seconds"
          ; Added 7Sep2021 11.8.6ag
          samAddRequest(#SCS_SAM_STOP_LC_SUB, nEditSubPtr, 0, 0, "", ElapsedMilliseconds()+5000)
          debugMsg(sProcName, "grMain\nSamRequestsWaiting=" + grMain\nSamRequestsWaiting + ", grMain\bControlThreadWaiting=" + strB(grMain\bControlThreadWaiting))
          ; End added 7Sep2021 11.8.6ag
          If GetGadgetText(WQL\lblAudStatus) <> sStatus
            SGT(WQL\lblAudStatus, sStatus)
          EndIf
        EndIf
      EndIf
    EndIf
    ;}
  EndIf
  
  gbInEditUpdateDisplay = #False
  
EndProcedure

Procedure valAud(pAudPtr, nFileNo=0)
  PROCNAMECA(pAudPtr)
  Protected blnFound, bOK
  Protected i, k, d, d2, l2
  Protected nTmpFileDuration
  Protected nTmpStartAt, nTmpEndAt, nTmpAbsLoopEnd
  Protected nTmpFadeInTime, nTmpFadeOutTime
  Protected fDBSingle.f, fDBTrim.f
  Protected fdB.f, sdB.s
  Protected fTrim.f
  Protected sMsg.s
  Protected nMaxLoopXFadeTime
  Protected sParam1.s, sParam2.s, sParam3.s
  Protected nMaxTime
  Protected nLblStartAt, nLblEndAt

  debugMsg(sProcName, #SCS_START + ", pAudPtr=" + pAudPtr)

  validateAll()

  If pAudPtr < 0
    ProcedureReturn #True
  EndIf

  With aAud(pAudPtr)
    
    debugMsg(sProcName, "\nAudState=" + decodeCueState(\nAudState))
    If \nAudState = #SCS_CUE_ERROR
      If FileExists(\sFileName) = #False
        debugMsg(sProcName, "file does not exist")
        ; skip validation (return #True) is the file does not exist, to prevent messages like 'Start At (24.310) must be less than File Duration (0.000)'
        ProcedureReturn #True
      EndIf
    EndIf
    
    If \bAudPlaceHolder = #False
      nMaxTime = \nFileDuration - 1
    EndIf
    
    If nMaxTime < 0
      ProcedureReturn #True
    EndIf
    
    ; reset \nRelEndAt as it may have been changed by midi.processMidiFadeOutCueCmd or ucCuePanel\btnFadeOut_Click
    \nRelEndAt = \nAbsEndAt - \nAbsMin
    
    If \bLiveInput = #False
      
      If Len(Trim(\sFileName)) = 0
        valAudErrMsg(pAudPtr, "FN", "File must be entered")
        ProcedureReturn #False
      EndIf
      
      debugMsg(sProcName, "\nFileFormat=" + decodeFileFormat(\nFileFormat) + ", \nEndAt=" + \nEndAt +
                          ", \nAbsEndAt=" + \nAbsEndAt + ", \nAbsMin=" + \nAbsMin + ", \nRelEndAt=" + \nRelEndAt +
                          ", \nNextAudIndex=" + getAudLabel(\nNextAudIndex))
      If \nFileFormat = #SCS_FILEFORMAT_PICTURE   ; image file
        
        If \bLogo
          If \nPrevAudIndex >= 0 Or \nNextAudIndex >= 0
            valAudErrMsg(pAudPtr, "LO", Lang("Errors", "LogoAlone"))
            ProcedureReturn #False
          EndIf
        Else
          If (\nEndAt <= 0) Or (\nEndAt = #SCS_CONTINUOUS_END_AT)
            If \nNextAudIndex >= 0
              ; "Display Time can only be left blank for the last item in a slideshow"
              valAudErrMsg(pAudPtr, "DI", LangPars("Errors", "CannotBeBlank", Trim(GLT(WQA\lblDisplayTime))))
              ProcedureReturn #False
            EndIf
          EndIf
        EndIf
        
      Else    ; audio or video file
        
        If \bAudPlaceHolder = #False
          
          If \bAudTypeA
            nLblStartAt = WQA\lblStartAt
            nLblEndAt = WQA\lblEndAt
          ElseIf \bAudTypeF
            nLblStartAt = WQF\lblStartAt
            nLblEndAt = WQF\lblEndAt
          ElseIf \bAudTypeP
            nLblStartAt = WQP\lblStartAt
            nLblEndAt = WQP\lblEndAt
          EndIf
          
          If \nStartAt > nMaxTime
            ; start at must be less than (file length - 1)
            sMsg = LangPars("Errors", "MustBeLessThan", GLT(nLblStartAt)+" ("+ttszt(\nStartAt)+")", ttszt(nMaxTime))
            valAudErrMsg(pAudPtr, "ST", sMsg, 0, nFileNo)
            ProcedureReturn #False
          EndIf
          
          If \nEndAt > nMaxTime
            ; end at cannot be greater than file length
            sMsg = LangPars("Errors", "NotGreaterThan", GLT(nLblEndAt)+" ("+ttszt(\nEndAt)+")", ttszt(nMaxTime))
            valAudErrMsg(pAudPtr, "EN", sMsg, 0, nFileNo)
            ProcedureReturn #False
          EndIf
          
          If (\nEndAt <> -2) And (\nEndAt <= \nStartAt)
            ; end at must be greater than start at
            sMsg = LangPars("Errors", "MustBeGreaterThan", GLT(nLblEndAt)+" ("+ttszt(\nEndAt)+")", GLT(nLblStartAt)+" ("+ttszt(\nStartAt)+")")
            valAudErrMsg(pAudPtr, "EN", sMsg, 0, nFileNo)
            ProcedureReturn #False
          EndIf
        
        EndIf ; EndIf \bAudPlaceHolder = #False
        
      EndIf
      
      If \bAudTypeA
        If \bAudPlaceHolder = #False
          If grCED\bQACreated
            WQA_displayCueMarkerInfo()
          EndIf
        EndIf
      EndIf

      If \bAudTypeF   ; \bAudTypeF
        If \bAudPlaceHolder = #False
          If \nMaxLoopInfo > 0
            ; mark loop that's currently-displayed
            For l2 = 0 To \nMaxLoopInfo
              If l2 = rWQF\nDisplayedLoopInfoIndex
                \aLoopInfo(l2)\bDisplayedLoop = #True
              Else
                \aLoopInfo(l2)\bDisplayedLoop = #False
              EndIf
            Next l2
            debugMsg(sProcName, "calling sortLoopInfoArray(" + getAudLabel(pAudPtr) + ")")
            If sortLoopInfoArray(pAudPtr)
              ; if returns #True then the array had to be re-sorted
              ; find the new index of the currently-displayed loop
              For l2 = 0 To \nMaxLoopInfo
                If \aLoopInfo(l2)\bDisplayedLoop
                  rWQF\nDisplayedLoopInfoIndex = l2 ; reset rWQF\nDisplayedLoopInfoIndex before calling WQF_displayLoopAndCueMarkerInfo()
                  Break
                EndIf
              Next l2
            EndIf
          EndIf
          If grCED\bQFCreated ; Test added 22Feb2021 11.8.4aj
            WQF_displayLoopAndCueMarkerInfo()
          EndIf
          
          If \nFadeInTime < 0
            nTmpFadeInTime = 0
          Else
            nTmpFadeInTime = \nFadeInTime
          EndIf
          If \nFadeOutTime < 0
            nTmpFadeOutTime = 0
          Else
            nTmpFadeOutTime = \nFadeOutTime
          EndIf
          
          If \nMaxLoopInfo >= 0
            debugMsg(sProcName, "calling listLoopInfoArray(" + getAudLabel(pAudPtr) + ")")
            listLoopInfoArray(pAudPtr)
          EndIf
          
          For l2 = 0 To \nMaxLoopInfo
            If \aLoopInfo(l2)\nAbsLoopStart > nMaxTime
              debugMsg(sProcName, "LS: \aLoopInfo(" + l2 + ")\nAbsLoopStart=" + \aLoopInfo(l2)\nAbsLoopStart + ", nMaxTime=" + nMaxTime + ", \nFileDuration=" + \nFileDuration)
              ; loop start cannot be greater than file length
              sMsg = LangPars("Errors", "NotGreaterThan", GLT(WQF\lblLoopStart)+" ("+ttszt(\aLoopInfo(l2)\nAbsLoopStart)+")", ttszt(nMaxTime))
              valAudErrMsg(pAudPtr, "LS", sMsg, 0, nFileNo)
              ProcedureReturn #False
            EndIf
            
            If \aLoopInfo(l2)\nAbsLoopStart > \nAbsEndAt
              debugMsg(sProcName, "LS: \aLoopInfo(" + l2 + ")\nAbsLoopStart=" + \aLoopInfo(l2)\nAbsLoopStart + ", nMaxTime=" + nMaxTime + ", \nAbsEndAt=" + \nAbsEndAt + ", \nEndAt=" + \nEndAt)
              valAudErrMsg(pAudPtr, "LS", "Loop Start (" + ttszt(\aLoopInfo(l2)\nAbsLoopStart) + ") cannot be greater than End At (" + ttszt(\nEndAt) + ")")
              ProcedureReturn #False
            EndIf
            
            If \aLoopInfo(l2)\nAbsLoopEnd > nMaxTime
              ; loop end cannot be greater than file length
              sMsg = LangPars("Errors", "NotGreaterThan", GLT(WQF\lblLoopEnd)+" ("+ttszt(\aLoopInfo(l2)\nAbsLoopEnd)+")", ttszt(nMaxTime))
              valAudErrMsg(pAudPtr, "LE", sMsg, 0, nFileNo)
              ProcedureReturn #False
            EndIf
            
            If (\aLoopInfo(l2)\nAbsLoopEnd > 0) And (\aLoopInfo(l2)\nAbsLoopEnd <= \aLoopInfo(l2)\nAbsLoopStart)
              ; loop end must be greater than loop start
              sMsg = LangPars("Errors", "MustBeGreaterThan", GLT(WQF\lblLoopEnd)+" ("+ttszt(\aLoopInfo(l2)\nAbsLoopEnd)+")", GLT(WQF\lblLoopStart)+" ("+ttszt(\aLoopInfo(l2)\nAbsLoopStart)+")")
              valAudErrMsg(pAudPtr, "LE", sMsg, l2, nFileNo)
              ProcedureReturn #False
            EndIf
            
            If (\aLoopInfo(l2)\nAbsLoopEnd > 0) And (\aLoopInfo(l2)\nAbsLoopEnd <= \nStartAt)
              ; loop end must be greater than start at
              sMsg = LangPars("Errors", "MustBeGreaterThan", GLT(WQF\lblLoopEnd)+" ("+ttszt(\aLoopInfo(l2)\nAbsLoopEnd)+")", GLT(WQF\lblStartAt)+" ("+ttszt(\nStartAt)+")")
              valAudErrMsg(pAudPtr, "LE", sMsg, l2, nFileNo)
              ProcedureReturn #False
            EndIf
            
            If ((nTmpFadeInTime + nTmpFadeOutTime) > \nRelEndAt) And (\aLoopInfo(l2)\nAbsLoopEnd <= 0)
              sParam1 = GLT(WQF\lblFadeInTime) + " (" + ttszt(nTmpFadeInTime) + ") + " + GLT(WQF\lblFadeOutTime) + " (" + ttszt(nTmpFadeOutTime) + ")"
              sParam2 = GLT(WQF\lblCueDuration) + " (" + ttszt(\nCueDuration) + ")"
              If \bAudTypeF
                sMsg = LangPars("Errors", "NotGreaterThanIfLoop", sParam1, sParam2)
              Else
                sMsg = LangPars("Errors", "NotGreaterThan", sParam1, sParam2)
              EndIf
              valAudErrMsg(pAudPtr, "FI", sMsg)
              ProcedureReturn #False
            EndIf
            
            If \aLoopInfo(l2)\nLoopXFadeTime > 0
              nMaxLoopXFadeTime = ((\aLoopInfo(l2)\nAbsLoopEnd - \aLoopInfo(l2)\nAbsLoopStart) >> 1) - 100
              ; debugMsg(sProcName, "\aLoopInfo(" + l2 + ")\nAbsLoopStart=" + \aLoopInfo(l2)\nAbsLoopStart + ", \nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd + ", nMaxLoopXFadeTime=" + nMaxLoopXFadeTime)
              If \aLoopInfo(l2)\nLoopXFadeTime >= nMaxLoopXFadeTime
                ; loop xfade time must be less than half the loop time - 100ms
                sMsg = LangPars("Errors", "LoopXFadeErr", timeToStringT(\aLoopInfo(l2)\nLoopXFadeTime), timeToStringT(nMaxLoopXFadeTime))
                valAudErrMsg(pAudPtr, "XF", sMsg)
                ProcedureReturn #False
              EndIf
            EndIf
            
            If l2 < \nMaxLoopInfo
              If \aLoopInfo(l2)\nAbsLoopEnd > \aLoopInfo(l2+1)\nAbsLoopStart
                debugMsg(sProcName, "\aLoopInfo(l2)\nAbsLoopEnd=" + \aLoopInfo(l2)\nAbsLoopEnd + ", \aLoopInfo(l2+1)\nAbsLoopStart=" + \aLoopInfo(l2+1)\nAbsLoopStart)
                sMsg = LangPars("Errors", "LoopOverlap", Str(l2+1), timeToStringT(\aLoopInfo(l2)\nAbsLoopEnd), timeToStringT(\aLoopInfo(l2+1)\nAbsLoopStart))
                valAudErrMsg(pAudPtr, "LE", sMsg, l2, nFileNo)
                ProcedureReturn #False
              EndIf
            EndIf
                
          Next l2
        EndIf ; EndIf \bAudPlaceHolder
        
        For d = \nFirstDev To \nLastDev
          If \sLogicalDev[d]
            For d2 = (d+1) To \nLastDev
              If \sLogicalDev[d2] = \sLogicalDev[d]
                sMsg = LangPars("Errors", "DevDuplicated", \sLogicalDev[d], Str(d+1), Str(d2+1))  ; add 1 to device numbers in error message as indexes are 0-based
                valAudErrMsg(pAudPtr, "LD", sMsg, d2)
                ProcedureReturn #False
              EndIf
            Next d2
          EndIf
        Next d
        
        For d = \nFirstDev To \nLastDev
          If \sLogicalDev[d]
            fDBSingle = convertDBStringToDBLevel(\sDBLevel[d])
            fDBTrim = convertDBStringToDBLevel(\sDBTrim[d])
            debugMsg(sProcName, "\fBVLevel(" + d + ")=" + StrF(\fBVLevel[d],2) + ", \fTrimFactor[d]=" + StrF(\fTrimFactor[d],2) + ", fDBSingle=" + StrF(fDBSingle) + ", fDBTrim=" + StrF(fDBTrim))
            If (fDBSingle > fDBTrim) And (fDBTrim <> 0)
              debugMsg(sProcName, "\sDBLevel[" + d + "]=" + \sDBLevel[d] + ", \sDBTrim[" + d + "]=" + \sDBTrim[d])
              ; dB cannot be greater than Trim for device d
              sParam1 = GLT(WQF\lblDb) + " (" + formatTrim(fDBSingle) + ")"
              sParam2 = GLT(WQF\lblTrim) + " (" + formatTrim(fDBTrim) + ")"
              sParam3 = GetGadgetText(WQF\lblDevNo[d]) + " " + \sLogicalDev[d]
              sMsg = LangPars("Errors", "NotGreaterThanForDev", sParam1, sParam2, sParam3)
              valAudErrMsg(pAudPtr, "DB", sMsg, d)
              ProcedureReturn #False
            EndIf
          EndIf
        Next d
        
      EndIf
      
    EndIf
    
    debugMsg(sProcName, "calling setDerivedAudFields()")
    setDerivedAudFields(pAudPtr)
    setDelayHideInds()
    
    If \bPrimeVideoReqd
      gbCheckForPrimeVideoReqd = #True
    EndIf
    
  EndWith

  ProcedureReturn #True
EndProcedure

Procedure valCue(bCuePlayOnly)
  PROCNAMEC()
  Protected bFound
  Protected j, n
  Protected nTmpFileDuration
  Protected nTmpStartAt, nTmpEndAt, nTmpAbsLoopEnd
  Protected nRelStartModeGadgetNo
  Protected sField.s
  Protected nMidiDmxDevCount, nOtherDevCount

  debugMsg(sProcName, #SCS_START + ", nEditCuePtr=" + nEditCuePtr)

  debugMsg(sProcName, "calling validateAll")
  If validateAll() = #False
    ProcedureReturn #False
  EndIf

  If nEditCuePtr < 0
    ProcedureReturn #True
  EndIf
  
  With aCue(nEditCuePtr)
    
    ; validate cue details
    If bCuePlayOnly = #False
      If Len(Trim(\sCue)) = 0
        valErrMsg(grCED\nCurrentCueLabelGadgetNo, LangPars("Errors", "MustBeEntered", GLT(WEC\lblCue)))
        ProcedureReturn #False
      EndIf
      
      If Len(Trim(\sCueDescr)) = 0
        valErrMsg(WEC\txtDescr, LangPars("Errors", "MustBeEntered", GLT(WEC\lblDescr)))
        ProcedureReturn #False
      EndIf
    EndIf
    
    If (\nActivationMethod & #SCS_ACMETH_HK_BIT) <> 0
      If Len(Trim(\sHotkey)) = 0
        sField = Lang("Common", "Hotkey")
        valErrMsg(WEC\cboHotkey, LangPars("Errors", "MustBeSelected", sField))
        ProcedureReturn #False
      EndIf
      
      If Len(Trim(\sHotkeyLabel)) = 0
        valErrMsg(WEC\txtHotkeyLabel, LangPars("Errors", "MustBeEntered", Trim(GLT(WEC\lblHotkeyLabel))))
        ProcedureReturn #False
      EndIf
      
    EndIf
    
    Select \nActivationMethod
      Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
        If \nAutoActTime < 0
          valErrMsg(WEC\txtAutoActivateTime, LangPars("Errors", "MustBeEntered", Lang("WEC", "AutoStartTime")))
          ProcedureReturn #False
        EndIf
        If \nAutoActPosn = #SCS_ACPOSN_DEFAULT
          valErrMsg(WEC\cboAutoActivatePosn, LangPars("Errors", "MustBeEntered", GLT(WEC\lblAutoStartPosition)))
          ProcedureReturn #False
        EndIf
        If \nAutoActPosn = #SCS_ACPOSN_LOAD
          If Len(Trim(\sAutoActCue)) > 0
            debugMsg(sProcName, "aCue(" + getCueLabel(nEditCuePtr) + ")\sAutoActCue=" + \sAutoActCue + ", \nAutoActCuePtr=" + \nAutoActCuePtr)
            valErrMsg(WEC\cboAutoActivatePosn, LangPars("Errors", "MustBeBlank", Lang("WEC", "AutoActivateCue")))
            ProcedureReturn #False
          EndIf
        Else
          If Len(\sAutoActCue) = 0
            valErrMsg(WEC\cboAutoActivateCue, LangPars("Errors", "MustBeSelected", Lang("WEC", "AutoActivateCue")))
            ProcedureReturn #False
          EndIf
          If \sAutoActCue = \sCue
            valErrMsg(WEC\cboAutoActivateCue, LangPars("Errors", "CannotSelectItself", \sCue, Lang("WEC", "AutoActivateCue")))
            ProcedureReturn #False
          EndIf
        EndIf
        
      Case #SCS_ACMETH_TIME
        bFound = #False
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If Len(Trim(\sTimeBasedStart[n])) > 0
            bFound = #True
            Break
          EndIf
        Next n
        If bFound = #False
          valErrMsg(WEC\txtTimeOfDay[0], Lang("WEC", "NoTime"))
          ProcedureReturn #False
        EndIf
        For n = 0 To #SCS_MAX_TIME_PROFILE
          If Len(Trim(\sTimeBasedLatestStart[n])) > 0
            If Len(Trim(\sTimeBasedStart[n])) = 0
              valErrMsg(WEC\txtTimeOfDay[n], LangPars("Errors", "MustBeEntered", Lang("WEC", "TimeOfDay")))
              ProcedureReturn #False
            Else
              If stringToDateSeconds(Trim(\sTimeBasedLatestStart[n])) < stringToDateSeconds(Trim(\sTimeBasedStart[n]))
                valErrMsg(WEC\txtLatestTimeOfDay[n], LangPars("Errors", "MustBeGreaterOrEqual", Lang("WEC", "lblLatestTimeOfDay"), Lang("WEC", "TimeOfDay")))
                ProcedureReturn #False
              EndIf
            EndIf
          EndIf
        Next n
        
      Case #SCS_ACMETH_EXT_TRIGGER, #SCS_ACMETH_EXT_TOGGLE, #SCS_ACMETH_EXT_NOTE, #SCS_ACMETH_EXT_COMPLETE
        For n = 0 To grProd\nMaxCueCtrlLogicalDev
          Select grProd\aCueCtrlLogicalDevs(n)\nDevType
            Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CC_DMX_IN
              nMidiDmxDevCount + 1
            Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CC_RS232_IN
              nOtherDevCount + 1
          EndSelect
        Next n
        If (nMidiDmxDevCount = 0) And (nOtherDevCount = 0)
          valErrMsg(WEC\cboActivationMethod, LangPars("Errors", "NoCCDev", \sCue, decodeActivationMethodL(\nActivationMethod)))
          ProcedureReturn #False
        EndIf
        If Len(Trim(\sMidiCue)) = 0
          If (nMidiDmxDevCount > 0) And (nOtherDevCount = 0)
            valErrMsg(WEC\txtMidiCue, LangPars("Errors", "MustBeEntered", Trim(GLT(WEC\lblMidiCue))))
            ProcedureReturn #False
          EndIf
        EndIf
        
      Case #SCS_ACMETH_OCM
        If \nAutoActCueMarkerId = grCueDef\nAutoActCueMarkerId
          valErrMsg(WEC\cboAutoActivateMarker, LangPars("Errors", "MustBeSelected", Lang("Common", "CueMarker")))
          ProcedureReturn #False
        EndIf
        
      Case #SCS_ACMETH_EXT_FADER
        If \nExtFaderCC = grCueDef\nExtFaderCC
          valErrMsg(WEC\cboExtFaderCC, LangPars("Errors", "MustBeSelected", decodeActivationMethodL(\nActivationMethod) + " " + GGT(WEC\lblExtFaderCC)))
          ProcedureReturn #False
        EndIf
        
      Case #SCS_ACMETH_LTC
        If getDevNoForInputForLTCDev(@grProd) < 0
          valErrMsg(WEC\cboActivationMethod, LangPars("Errors", "NoLTCInputDev", \sCue))
          ProcedureReturn #False
        EndIf

    EndSelect
    
    ; debugMsg(sProcName, "calling checkCallableCueParamsValid(" + getCueLabel(nEditCuePtr) + ")")
    If checkCallableCueParamsValid(nEditCuePtr) = #False
      valErrMsg(WEC\txtCallableCueParams, gsError)
      ProcedureReturn #False
    EndIf
    
    ; debugMsg(sProcName, "calling valSub")
    If valSub() = #False
      debugMsg(sProcName, "valSub failed")
      ProcedureReturn #False
    ; Else
    ;   debugMsg(sProcName, "valSub() returned #True")
    EndIf
    
    setCuePtrs(#False)
    ; replaced the following 3 lines with setCuePtrs(#False) so that other cues that were linked to this can now be unlinked, etc
    ; setLinksForCue(nEditCuePtr)
    ; setLinksForAudsWithinSubsForCue(nEditCuePtr)
    ; buildAudSetArray()
    
    If gbInPaste = #False
      debugMsg(sProcName, "calling loadGridRow(" + nEditCuePtr + ")")
      loadGridRow(nEditCuePtr)
      gnRefreshCuePtr = nEditCuePtr
      gnRefreshSubPtr = nEditSubPtr
      gnRefreshAudPtr = nEditAudPtr
      gbCallRefreshDispPanel = #True
      debugMsg(sProcName, "gbCallRefreshDispPanel=" + strB(gbCallRefreshDispPanel) + ", gnRefreshCuePtr=" + getCueLabel(gnRefreshCuePtr) + ", gnRefreshSubPtr=" + getSubLabel(gnRefreshSubPtr) + ", gnRefreshAudPtr=" + getAudLabel(gnRefreshAudPtr))
    EndIf
    
  EndWith
  
  ProcedureReturn #True
EndProcedure

Procedure valSub()
  PROCNAMECS(nEditSubPtr)
  Protected blnFound, bAudResult
  Protected d, h, i, j, k, n
  Protected nTmpFileDuration
  Protected nTmpStartAt, nTmpEndAt, nTmpAbsLoopEnd
  Protected nAudFileCount, nFileNo
  Protected bSFRTimeOverrideSensible
  Protected nCtrlSendItemCount
  Protected bRowCleared
  Protected fDBSingle.f, fDBTrim.f
  Protected fdB.f, sdB.s
  Protected fTrim.f
  Protected nRelStartModeGadgetNo
  Protected sMsg.s
  Protected nItemIndex
  Protected nLCSubPtr, nLCAudPtr
  Protected sFirstCue.s, nFirstCuePtr, sFirstCuePrompt.s
  Protected sLastCue.s, nLastCuePtr, sLastCuePrompt.s
  Protected sNr.s
  Protected sLabel.s, sChoice.s
  Protected bPrevMemoScreen1InUse
  Protected sMTCTime.s, sMTCFrame.s, nMTCMaxFrame
  Protected bItemPresent

  debugMsg(sProcName, #SCS_START)

  If nEditSubPtr < 0
    ProcedureReturn #True
  EndIf
  
  With aSub(nEditSubPtr)
    ; debugMsg(sProcName, "\sSubType=" + \sSubType)
    
    If \bSubTypeK
      If \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
        CompilerIf 1=2
          If getVisible(WQK\btnCaptureStop)
            ; 'Capture DMX Sequence' is currently active, to force this to stop now
            WQK_btnCaptureStop_Click()
          EndIf
        CompilerElse
          If getVisible(WQK\cvsCaptureButton)
            If GetGadgetData(WQK\cvsCaptureButton) = #SCS_LT_CAPTURE_BTN_SEQ_STOP
              ; 'Capture DMX Sequence' is currently active, to force this to stop now
              WQK_btnCaptureStop_Click()
            EndIf
          EndIf
        CompilerEndIf
      EndIf
    EndIf
        
    If (\nRelStartMode = #SCS_RELSTART_AS_PREV_SUB) Or (\nRelStartMode = #SCS_RELSTART_AE_PREV_SUB) Or (\nRelStartMode = #SCS_RELSTART_BE_PREV_SUB)
      If \nPrevSubIndex < 0
        Select \sSubType
          Case "A"
            nRelStartModeGadgetNo = WQA\cboRelStartMode
          Case "E"
            nRelStartModeGadgetNo = WQE\cboRelStartMode
          Case "F"
            nRelStartModeGadgetNo = WQF\cboRelStartMode
          Case "G"
            nRelStartModeGadgetNo = WQG\cboRelStartMode
          Case "I"
            nRelStartModeGadgetNo = WQI\cboRelStartMode
          Case "J"
            nRelStartModeGadgetNo = WQJ\cboRelStartMode
          Case "K"
            nRelStartModeGadgetNo = WQK\cboRelStartMode
          Case "L"
            nRelStartModeGadgetNo = WQL\cboRelStartMode
          Case "M"
            nRelStartModeGadgetNo = WQM\cboRelStartMode
          Case "P"
            nRelStartModeGadgetNo = WQP\cboRelStartMode
          Case "Q"
            nRelStartModeGadgetNo = WQQ\cboRelStartMode
          Case "R"
            nRelStartModeGadgetNo = WQR\cboRelStartMode
          Case "S"
            nRelStartModeGadgetNo = WQS\cboRelStartMode
          Case "T"
            nRelStartModeGadgetNo = WQT\cboRelStartMode
          Case "U"
            nRelStartModeGadgetNo = WQT\cboRelStartMode
        EndSelect
        valErrMsg(nRelStartModeGadgetNo, Lang("Errors", "NoPrevSub"))
        ProcedureReturn #False
      EndIf
    EndIf
    
    If \bSubTypeA  ; bSubTypeA - VIDEO SUBCUE VALIDATION
      ;{
      k = \nFirstAudIndex
      nFileNo = 0
      While k >= 0
        nFileNo + 1
        bAudResult = valAud(k, nFileNo)
        If bAudResult = #False
          ProcedureReturn #False
        EndIf
        If aAud(k)\nFileFormat = #SCS_FILEFORMAT_PICTURE Or aAud(k)\nFileFormat = #SCS_FILEFORMAT_CAPTURE
          If aAud(k)\bContinuous
            If aAud(k)\nNextAudIndex >= 0
              ; not last file in the sub-cue
              nItemIndex = WQA_getItemForAud(k)
              If nItemIndex >= 0
                WQA_processItemSelected(nItemIndex, #False)
              EndIf
              valErrMsg(WQA\chkContinuous, Lang("Errors", "OnlyLastContinuous"))
              ProcedureReturn #False
            EndIf
            If \bPLRepeat
              ; \bPLRepeat and aAud(k)\bContinuous are mutually exclusive
              nItemIndex = WQA_getItemForAud(k)
              If nItemIndex >= 0
                WQA_processItemSelected(nItemIndex, #False)
              EndIf
              valErrMsg(WQA\chkContinuous, Lang("Errors", "ContNotWithRepeat"))
              ProcedureReturn #False
            EndIf
          EndIf
          If aAud(k)\bLogo = #False
            If aAud(k)\nEndAt <= 0
              If aAud(k)\nNextAudIndex >= 0
                ; not last file in the sub-cue
                nItemIndex = WQA_getItemForAud(k)
                If nItemIndex >= 0
                  WQA_processItemSelected(nItemIndex, #False)
                EndIf
                valErrMustBeEntered(WQA\txtDisplayTime, WQA\lblDisplayTime)
                ProcedureReturn #False
              Else
                ; last file in the sub-cue
                If aAud(k)\bContinuous = #False
                  nItemIndex = WQA_getItemForAud(k)
                  If nItemIndex >= 0
                    WQA_processItemSelected(nItemIndex, #False)
                  EndIf
                  valErrMsg(WQA\txtDisplayTime, LangPars("Errors", "MustBeEnteredOrSelected", GLT(WQA\lblDisplayTime), getOwnText(WQA\chkContinuous)))
                  ProcedureReturn #False
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        k = aAud(k)\nNextAudIndex
      Wend
    EndIf
    ;}
    
    If \bSubTypeE  ; bSubTypeE - MEMO CUE VALIDATION
      ;{
      If (\nMemoDisplayTime <= 0) And (\bMemoContinuous = #False)
        valErrMsg(WQE\txtDisplayTime, LangPars("Errors", "MustBeEnteredOrSelected", GLT(WQE\lblDisplayTime), getOwnText(WQE\chkContinuous)))
        ProcedureReturn #False
      EndIf
      bPrevMemoScreen1InUse = grWMN\bMemoScreen1InUse
      setMemoScreen1InUseInd()
      debugMsg(sProcName, "bPrevMemoScreen1InUse=" + strB(bPrevMemoScreen1InUse) + ", grWMN\bMemoScreen1InUse=" + strB(grWMN\bMemoScreen1InUse))
      If grWMN\bMemoScreen1InUse <> bPrevMemoScreen1InUse
        debugMsg(sProcName, "calling WMN_displayOrHideMemoPanel()")
        WMN_displayOrHideMemoPanel()
        debugMsg(sProcName, "calling WMN_resizeGadgetsForSplitters()")
        WMN_resizeGadgetsForSplitters()
      EndIf
    EndIf
    ;}
    
    If \bSubTypeF  ; bSubTypeF - AUDIO FILE VALIDATION
      ;{
      If \nFirstAudIndex >= 0
        bAudResult = valAud(\nFirstAudIndex)
        If bAudResult = #False
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
    ;}
    
    If \bSubTypeG  ; bSubTypeG - GO TO CUE VALIDATION
      ;{
      If Len(\sCueToGoTo) = 0
        valErrMustBeEntered(WQG\cboCueToGoTo, WQG\lblCueToGoTo)
        ProcedureReturn #False
      EndIf
    EndIf
    ;}
    
    If \bSubTypeJ  ; bSubTypeJ - ENABLE/DISABLE CUES VALIDATION
      ;{
      bItemPresent = #False ; Added 4Jun2024 11.10.3ah
      sFirstCuePrompt = Lang("WQJ","lblFirstCue")
      sLastCuePrompt = Lang("WQJ","lblLastCue")
      For n = 0 To #SCS_MAX_ENABLE_DISABLE
        sFirstCue = \aEnableDisable[n]\sFirstCue
        sLastCue = \aEnableDisable[n]\sLastCue
        If Len(sLastCue) > 0 And Len(sFirstCue) = 0
          valErrMsg(WQJ\cboLastCue[n], LangPars("Errors", "MustBeBlankIf", sLastCuePrompt+" ("+sLastCue+")", sFirstCuePrompt+" ("+sFirstCue+")"))
          ProcedureReturn #False
        EndIf
        nFirstCuePtr = getCuePtr(sFirstCue)
        nLastCuePtr = getCuePtr(sLastCue)
        If nFirstCuePtr >= 0 And nLastCuePtr >= 0
          If nLastCuePtr < nFirstCuePtr
            valErrMsg(WQJ\cboLastCue[n], LangPars("Errors", "CannotBeBefore", sLastCuePrompt+" ("+sLastCue+")", sFirstCuePrompt+" ("+sFirstCue+")"))
            ProcedureReturn #False
          EndIf
        EndIf
        ; Added 4Jun2024 11.10.3ah
        If nFirstCuePtr >= 0
          bItemPresent = #True
        EndIf
        ; End added 4Jun2024 11.10.3ah
      Next n
      ; Added 4Jun2024 11.10.3ah
      If bItemPresent = #False
        valErrMsg(WQJ\cboFirstCue[0], LangPars("Errors", "AtLeast1", GGT(WQJ\lblFirstCue)))
        ProcedureReturn #False
      EndIf
      ; Added 4Jun2024 11.10.3ah
    EndIf
    ;}
    
    If \bSubTypeK  ; bSubTypeK - LIGHTING VALIDATION
      ;{
      If \bChase
        If (\nChaseSteps < 2) Or (\nChaseSteps > grLicInfo\nMaxChaseSteps)
          sLabel = Lang("WQK", "lblChaseSteps")
          valErrMsg(WQK\txtChaseSteps, LangPars("Errors", "MustBeBetween", sLabel, "2", Str(grLicInfo\nMaxChaseSteps)))
          ProcedureReturn #False
        EndIf
      EndIf
      Select \nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_BLACKOUT
          
        Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
          
        Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          If (\nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDCFadeUpUserTime < 0 And \sLTDCFadeUpUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtDCFadeUpTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDCFadeDownUserTime < 0 And \sLTDCFadeDownUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtDCFadeDownTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDCFadeOutOthersUserTime < 0 And \sLTDCFadeOutOthersUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "FO_User") + "'"
            valErrMsg(WQK\txtDCFadeOutOthersTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
          If (\nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDIFadeUpUserTime < 0 And \sLTDIFadeUpUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtDIFadeUpTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDIFadeDownUserTime < 0 And \sLTDIFadeDownUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtDIFadeDownTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTDIFadeOutOthersUserTime < 0 And \sLTDIFadeOutOthersUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "FO_User") + "'"
            valErrMsg(WQK\txtDIFadeOutOthersTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          
        Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
          If (\nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTFIFadeUpUserTime < 0 And \sLTFIFadeUpUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtFIFadeUpTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTFIFadeDownUserTime < 0 And \sLTFIFadeDownUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "DF_User") + "'"
            valErrMsg(WQK\txtFIFadeDownTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
          If (\nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME) And (\nLTFIFadeOutOthersUserTime < 0 And \sLTFIFadeOutOthersUserTime = "")
            sLabel = Lang("WQK", "FadeTime")
            sChoice = "'" + Lang("WQK", "FO_User") + "'"
            valErrMsg(WQK\txtFIFadeOutOthersTime, LangPars("Errors", "MustBeEnteredIfSel", sLabel, sChoice))
            ProcedureReturn #False
          EndIf
      EndSelect
    EndIf
    ;}
    
    If \bSubTypeL  ; bSubTypeL - LEVEL CHANGE VALIDATION
      ;{
      If Len(\sLCCue) = 0
        valErrMsg(WQL\cboLCCue, LangPars("Errors", "MustBeEntered", GetGadgetText(WQL\lblCueToAdjust)))
        ProcedureReturn #False
      EndIf
      nLCAudPtr = \nLCAudPtr
      nLCSubPtr = \nLCSubPtr
      debugMsg(sProcName, \sSubLabel +  ", nLCSubPtr=" + getSubLabel(nLCSubPtr) + ", nLCAudPtr=" + getAudLabel(nLCAudPtr))
      If \bLCTargetIsF Or \bLCTargetIsI
        If \nLCAudPtr >= 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If (aAud(nLCAudPtr)\sLogicalDev[d]) And (\bLCInclude[d])
              If (SLD_getLevel(WQL\sldLCLevel[d]) <> SLD_getBaseLevel(WQL\sldLCLevel[d])) Or (SLD_getValue(WQL\sldLCPan[d]) <> SLD_getBaseValue(WQL\sldLCPan[d]))
                If \nLCTime[d] < 0
                  valErrMsg(WQL\txtLCTime[d], LangPars("Errors", "MustBeEnteredMayBe0ForDev", GetGadgetText(WQL\lblChangeTime), GetGadgetText(WQL\lblDevNo[d]) + " " + aAud(nLCAudPtr)\sLogicalDev[d]))
                  ProcedureReturn #False
                EndIf
              EndIf
            EndIf
          Next d
        EndIf
      ElseIf \bLCTargetIsA Or \bLCTargetIsP
        If nLCSubPtr >= 0
          For d = 0 To grLicInfo\nMaxAudDevPerAud
            If (aSub(nLCSubPtr)\sPLLogicalDev[d]) And (\bLCInclude[d])
              If SLD_getLevel(WQL\sldLCLevel[d]) <> SLD_getBaseLevel(WQL\sldLCLevel[d]) Or (SLD_getValue(WQL\sldLCPan[d]) <> SLD_getBaseValue(WQL\sldLCPan[d]))
                If \nLCTime[d] < 0
                  valErrMsg(WQL\txtLCTime[d], LangPars("Errors", "MustBeEnteredMayBe0ForDev", GetGadgetText(WQL\lblChangeTime), GetGadgetText(WQL\lblDevNo[d]) + " " + aSub(nLCSubPtr)\sPLLogicalDev[d]))
                  ProcedureReturn #False
                EndIf
              EndIf
            EndIf
          Next d
        EndIf
      EndIf
      If \bLCTargetIsF
        Select \nLCAction
          Case #SCS_LC_ACTION_FREQ, #SCS_LC_ACTION_TEMPO, #SCS_LC_ACTION_PITCH
            checkTempoEtcUsable()
        EndSelect
      EndIf
    EndIf
    ;}
    
    If \bSubTypeM  ; bSubTypeM - CONTROL SEND VALIDATION
      ;{
      nCtrlSendItemCount = 0
      For n = 0 To #SCS_MAX_CTRL_SEND
        bRowCleared = #False
        If Trim(\aCtrlSend[n]\sCSLogicalDev)
          If gbInEditPlaySub = #False
            If n > 0
              bRowCleared = clearCtrlSendItemIfNotBuilt(n)
              debugMsg(sProcName, "clearCtrlSendItemIfNotBuilt(" + n + ") returned " + strB(bRowCleared))
            EndIf
          EndIf
          If bRowCleared = #False
            If valCtrlSendItem(n) = #False
              debugMsg(sProcName, "valCtrlSendItem(" + n + ") returned #False")
              ProcedureReturn #False
            EndIf
          EndIf
          nCtrlSendItemCount + 1
        EndIf
      Next n
      debugMsg(sProcName, "nCtrlSendItemCount=" + nCtrlSendItemCount)
      If nCtrlSendItemCount = 0
        valErrMsg(WQM\cboMsgType, LangPars("Errors", "MustBeSelected", GLT(WQM\lblLogicalDev))) ; "Control Send Device must be selected")
        ProcedureReturn #False
      EndIf
    EndIf
    ;}
    
    If \bSubTypeP  ; bSubTypeP - PLAYLIST VALIDATION
      ;{
      For d = 0 To grLicInfo\nMaxAudDevPerSub
        If \sPLLogicalDev[d]
          debugMsg(sProcName, "\sPLMastDBLevel[" + d + "]=" + \sPLMastDBLevel[d] + ", \sPLDBTrim[" + d + "]=" + \sPLDBTrim[d])
          fDBSingle = convertDBStringToDBLevel(\sPLMastDBLevel[d])
          fDBTrim = convertDBStringToDBLevel(\sPLDBTrim[d])
          If (fDBSingle > fDBTrim) And (fDBTrim <> 0)
            valErrMsg(WQP\txtSubDBLevel[d], LangPars("Errors", "dBCannotBeGTTrim", formatTrim(fDBSingle), formatTrim(fDBTrim)))
            ProcedureReturn #False
          EndIf
        EndIf
      Next d
      
      k = \nFirstAudIndex
      nAudFileCount = 0
      While k >= 0
        bAudResult = valAud(k)
        If bAudResult = #False
          ProcedureReturn #False
        EndIf
        nAudFileCount + 1
        k = aAud(k)\nNextAudIndex
      Wend
      If (\bPLRepeat) And (nAudFileCount < 2)
        valErrMsg(WQP\chkPLRepeat, Lang("Errors", "AtLeast2Files"))
        ProcedureReturn #False
      EndIf
    EndIf
    ;}
    
    If \bSubTypeQ  ; bSubTypeQ - 'CALL CUE' CUE VALIDATION
      ;{
      Select \nCallCueAction
        Case #SCS_QQ_CALLCUE
          debugMsg(sProcName, "\sCallCue=" + \sCallCue)
          If Len(\sCallCue) = 0
            valErrMustBeEntered(WQQ\cboCallCue, WQQ\lblCallCue)
            ProcedureReturn #False
          EndIf
          populateCallCueParamArray(@aSub(nEditSubPtr)) ; Added 31Jan2024 11.10.2ad
          For n = 0 To \nMaxCallCueParam
            If Len(Trim(\aCallCueParam(n)\sCallParamValue)) = 0
              If Len(Trim(\aCallCueParam(n)\sCallParamDefault)) = 0
                valErrMsg(WQQ\txtParamValue(n), LangPars("Errors", "ParamValueReqd", Str(n+1)))
                ProcedureReturn #False
              EndIf
            EndIf
          Next n
        Case #SCS_QQ_SELHKBANK
          If \nSelHKBank < 1
            valErrMustBeSelected(WQQ\cboSelHKBank, WQQ\lblSelHKBank)
            ProcedureReturn #False
          EndIf
        Default
          valErrMustBeSelected(WQQ\cboActionReqd, WQQ\lblActionReqd)
          ProcedureReturn #False
      EndSelect
    EndIf
    ;}
    
    If \bSubTypeR  ; bSubTypeR - RUN EXTERNAL PROGRAM VALIDATION
      ;{
      If Len(\sRPFileName) = 0
        valErrMustBeEntered(WQR\txtFileName, WQR\lblFileName)
        ProcedureReturn #False
      EndIf
    EndIf
    ;}
    
    If \bSubTypeS  ; bSubTypeS - SFR CUES VALIDATION
      ;{
      bItemPresent = #False ; Added 4Jun2024 11.10.3ah
      bSFRTimeOverrideSensible = #False
      For h = 0 To #SCS_MAX_SFR
        If (\sSFRCue[h]) Or (\nSFRCueType[h] <> #SCS_SFR_CUE_NA)
          bItemPresent = #True ; Added 4Jun2024 11.10.3ah
          If \nSFRAction[h] = #SCS_SFR_ACT_NA
            debugMsg(sProcName, "\sSFRCue[" + h + "]=" + \sSFRCue[h] + ", \nSFRCueType[" + h + "]=" + \nSFRCueType[h] + ", \nSFRAction[" + h + "]=" + \nSFRAction[h])
            valErrMsg(WQS\cboSFRAction[h], LangPars("Errors", "MustBeEnteredIf", GetGadgetText(WQS\lblActionReqd), GetGadgetText(WQS\lblSFRCue)))
            ProcedureReturn #False
          EndIf
        Else
          Select \nSFRAction[h]
            Case #SCS_SFR_ACT_NA
              ; blank 'cue' is valid if 'action' is also blank
            Case #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
              ; blank 'cue' is valid
              bItemPresent = #True ; Added 4Jun2024 11.10.3ah
            Default
              ; blank 'cue' is invalid
              valErrMsg(WQS\cboSFRAction[h], LangPars("Errors", "MustBeEnteredIf", GetGadgetText(WQS\lblSFRCue), GetGadgetText(WQS\cboSFRAction[h])))
              ProcedureReturn #False
          EndSelect
        EndIf
        
        If (Len(\sSFRCue[h]) = 0) And (\nSFRCueType[h] = #SCS_SFR_CUE_SEL)
          If \nSFRAction[h] <> #SCS_SFR_ACT_NA
            valErrMsg(WQS\cboSFRAction[h], LangPars("Errors", "MustBeBlankIf", GetGadgetText(WQS\lblActionReqd), GetGadgetText(WQS\lblSFRCue)))
            ProcedureReturn #False
          EndIf
        EndIf
        
        If (\sSFRCue[h]) Or (\nSFRCueType[h] <> #SCS_SFR_CUE_NA)
          Select \nSFRAction[h]
            Case #SCS_SFR_ACT_STOPALL, #SCS_SFR_ACT_FADEALL, #SCS_SFR_ACT_PAUSEALL, #SCS_SFR_ACT_STOPMTC
              valErrMsg(WQS\cboSFRCue[h], LangPars("Errors", "MustBeBlankFor", GetGadgetText(WQS\lblSFRCue), gaSFRAction(\nSFRAction[h])\sActDescr))
              ProcedureReturn #False
          EndSelect
        EndIf
        
        If \sSFRCue[h]
          For j = 0 To #SCS_MAX_SFR
            If j <> h
              If (\sSFRCue[j] = \sSFRCue[h]) And (\nSFRSubNo[j] = \nSFRSubNo[h])
                If \nSFRSubNo[h] > 0
                  valErrMsg(WQS\cboSFRCue[h], LangPars("Errors", "CueMoreThanOnce", \sSFRCue[h] + "<" + Str(\nSFRSubNo[h]) + ">"))
                Else
                  valErrMsg(WQS\cboSFRCue[h], LangPars("Errors", "CueMoreThanOnce", \sSFRCue[h]))
                EndIf
                ProcedureReturn #False
              EndIf
            EndIf
          Next j
        EndIf
        
        Select \nSFRAction[h]
          Case #SCS_SFR_ACT_FADEOUT, #SCS_SFR_ACT_FADEOUTHIB, #SCS_SFR_ACT_RESUMEHIB, #SCS_SFR_ACT_RESUMEHIBNEXT, #SCS_SFR_ACT_FADEALL
            bSFRTimeOverrideSensible = #True
        EndSelect
        
      Next h
      
      If (\nSFRTimeOverride >= 0) And (bSFRTimeOverrideSensible = #False)
        valErrMsg(WQS\txtTimeOverride, LangPars("Errors", "MustBeBlankNoFade", GetGadgetText(WQS\lblTimeOverride), GetGadgetText(WQS\lblActionReqd)))
        ProcedureReturn #False
      EndIf
      
      ; Added 4Jun2024 11.10.3ah
      If bItemPresent = #False
        valErrMsg(WQS\cboSFRAction[0], LangPars("Errors", "AtLeast1", GGT(WQS\lblActionReqd)))
        ProcedureReturn #False
      EndIf
      ; Added 4Jun2024 11.10.3ah
      
    EndIf
    ;}
    
    If \bSubTypeT  ; bSubTypeT - SET POSITION VALIDATION
      ;{
      If (\nSetPosCueType = #SCS_SETPOS_CUETYPE_NA) And Len(\sSetPosCue) = 0 ; Changed 7Jun2022 11.9.2
        valErrMustBeEntered(WQT\cboSetPosCue, WQT\lblSetPosCue)
        ProcedureReturn #False
      EndIf
      ; Added 8Jun2022 11.9.2
      ; debugMsg0(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\nSetPosCueType=" + decodeSetPosSetPosCueType(\nSetPosCueType) + ", \nSetPosAbsRel=" + decodeSetPosAbsRel(\nSetPosAbsRel) + ", \sSetPosCueMarker=" + \sSetPosCueMarker)
      If (\nSetPosAbsRel = #SCS_SETPOS_CUE_MARKER) And (Len(\sSetPosCueMarker) = 0)
        valErrMustBeEntered(WQT\cboSetPosCueMarker, WQT\lblSetPosCueMarker)
        ProcedureReturn #False
      EndIf
      ; End added 8Jun2022 11.9.2
      If (\nSetPosTime < 0) And (\nSetPosAbsRel = #SCS_SETPOS_ABSOLUTE Or \nSetPosAbsRel = #SCS_SETPOS_BEFORE_END) ; Changed 7Jun2022 11.9.2
        valErrMustBeEntered(WQT\txtSetPosTime, WQT\lblSetPosTime)
        ProcedureReturn #False
      EndIf
      If \nSetPosCueType = #SCS_SETPOS_CUETYPE_NA ; Test added 7Jun2022 11.9.2
        i = getCuePtr(\sSetPosCue)
        If i >= 0
          If aCue(i)\bSubTypeAorF
            ; OK
          Else
            sMsg = Lang("WQT", "InvalidCueType2")
            valErrMsg(WQT\cboSetPosCue, sMsg)
            ProcedureReturn #False
          EndIf
          j = aCue(i)\nFirstSubIndex
          While j >= 0
            If aSub(j)\bSubTypeAorF
              k = aSub(j)\nFirstAudIndex
              If k >= 0
                If aAud(k)\nAbsEndAt < \nSetPosTime
                  sMsg = LangPars("WQT", "PosTooHigh", timeToStringT(\nSetPosTime), timeToStringT(aAud(k)\nAbsEndAt), aSub(j)\sSubLabel)
                  valErrMsg(WQT\txtSetPosTime, sMsg)
                  ProcedureReturn #False
                EndIf
              EndIf
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
      EndIf
    EndIf
    ;}
    
    If \bSubTypeU  ; bSubTypeU - MTC/LTC
      ;{
      If \nMTCFrameRate = #SCS_MTC_FR_NOT_SET
        valErrMustBeEntered(WQU\cboMTCFrameRate, WQU\lblMTCFrameRate)
        ProcedureReturn #False
      EndIf
      ; Added 4Nov2020 11.8.3.3ac
      sMTCTime = decodeMTCTime(\nMTCStartTime)
      sMTCFrame = Right(sMTCTime, 2)
      Select \nMTCFrameRate
        Case #SCS_MTC_FR_24
          nMTCMaxFrame = 23
        Case #SCS_MTC_FR_25
          nMTCMaxFrame = 24
        Case #SCS_MTC_FR_29_97
          nMTCMaxFrame = 29
        Case #SCS_MTC_FR_30
          nMTCMaxFrame = 29
        Default
          ; Shouldn't get here
          nMTCMaxFrame = 0
      EndSelect
      If nMTCMaxFrame > 0
        If Val(sMTCFrame) > nMTCMaxFrame
          debugMsg(sProcName, "\nMTCStartTime=" + \nMTCStartTime + ", sMTCTime=" + sMTCTime + ", sMTCFrame=" + sMTCFrame + ", Val(sMTCFrame)=" + Val(sMTCFrame) +
                              ", \nMTCFrameRate=" + decodeMTCFrameRate(\nMTCFrameRate) + ", nMTCMaxFrame=" + nMTCMaxFrame)
          sMsg = Lang("WQU", "FrameTooHigh")
          valErrMsg(WQU\txtMTCStartPart[3], sMsg)
          ProcedureReturn #False
        EndIf
      EndIf
      ; Added 4Nov2020 11.8.3.3ac
    EndIf
    ;}
    
    If \bSubTypeA Or \bSubTypeE
      If gbVideosOnMainWindow = #False ; Test added 15Sep2020 11.8.3.2ay
        debugMsg(sProcName, "calling displayOrHideVideoWindows()")
        displayOrHideVideoWindows()
      EndIf
    EndIf
    
    ; debugMsg0(sProcName, "calling checkCallableCueParamsValid(" + getCueLabel(nEditCuePtr) + ", " + getSubLabel(nEditSubPtr) + ")")
    If checkCallableCueParamsValid(nEditCuePtr, nEditSubPtr) = #False
      valErrMsg(WEC\txtCallableCueParams, gsError)
      ProcedureReturn #False
    EndIf
    
  EndWith
  
  If gbInPaste = #False
    gnRefreshCuePtr = nEditCuePtr
    gnRefreshSubPtr = nEditSubPtr
    gnRefreshAudPtr = nEditAudPtr
    gbCallRefreshDispPanel = #True
    debugMsg(sProcName, "gbCallRefreshDispPanel=" + strB(gbCallRefreshDispPanel) + ", gnRefreshCuePtr=" + getCueLabel(gnRefreshCuePtr) + ", gnRefreshSubPtr=" + getSubLabel(gnRefreshSubPtr) + ", gnRefreshAudPtr=" + getAudLabel(gnRefreshAudPtr))
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure valCtrlSendItem(nIndex)
  PROCNAMECS(nEditSubPtr)
  Protected n, sSeq.s
  Protected sNoSpaces.s, sTmp.s
  Protected bSysExOK
  Protected m
  Protected sFileName.s
  Protected sMsg.s
  Protected bDMXFadeFound, bDMXItemFound
  Protected nRemDevMsgPtr, sRemDevValType.s
  
  debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex)
  
  n = nIndex
  sSeq = " (Control Message #" + Str(n+1) + ")"
  
  With aSub(nEditSubPtr)\aCtrlSend[n]
    
    Select \nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT ;#SCS_DEVTYPE_CS_MIDI_OUT
        ;{
        Select \nMSMsgType
          Case #SCS_MSGTYPE_PC127, #SCS_MSGTYPE_PC128 ; Program Change
            If \nMSChannel = grSubDef\aCtrlSend[n]\nMSChannel
              valErrMsg(WQM\cboMSChannel, "A Channel must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[n]\nMSParam1 And Len(\sMSParam1) = 0
              valErrMsg(WQM\cboMSParam1, "A Program # must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            
          Case #SCS_MSGTYPE_CC  ; Control Change
            If \nMSChannel = grSubDef\aCtrlSend[n]\nMSChannel
              valErrMsg(WQM\cboMSChannel, "A Channel must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[n]\nMSParam1 And Len(\sMSParam1) = 0
              valErrMsg(WQM\cboMSParam1, "A Control # must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[n]\nMSParam2 And Len(\sMSParam2) = 0
              valErrMsg(WQM\cboMSParam2, "A Value must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            
          Case #SCS_MSGTYPE_ON, #SCS_MSGTYPE_OFF  ; Note ON, Note OFF
            If \nMSChannel = grSubDef\aCtrlSend[n]\nMSChannel
              valErrMsg(WQM\cboMSChannel, "A Channel must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[n]\nMSParam1 And Len(\sMSParam1) = 0
              valErrMsg(WQM\cboMSParam1, "A Note # must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[n]\nMSParam2 And Len(\sMSParam2) = 0
              valErrMsg(WQM\cboMSParam2, "A Velocity must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            
          Case #SCS_MSGTYPE_MSC ; MIDI Show Control
            If \nMSChannel = grSubDef\aCtrlSend[n]\nMSChannel
              valErrMsg(WQM\cboMSChannel, "A Device Id must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[n]\nMSParam1
              valErrMsg(WQM\cboMSParam1, "A Command Format must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[n]\nMSParam2
              valErrMsg(WQM\cboMSParam2, "A Command must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            Select \nMSParam2
              Case $1, $2, $3, $5, $B, $10
                ; commands with q_number, q_list and q_path
                If Len(\sMSQNumber) = 0 And Len(\sMSQList) > 0
                  valErrMsg(WQM\txtQNumber, "A Q Number must be entered if a Q List is supplied" + sSeq)
                  ProcedureReturn #False
                EndIf
                If (\sMSQList = grSubDef\aCtrlSend[n]\sMSQList) And (\sMSQPath <> grSubDef\aCtrlSend[n]\sMSQPath)
                  valErrMsg(WQM\txtQList, "A Q List must be entered if a Q Path is supplied" + sSeq)
                  ProcedureReturn #False
                EndIf
                
              Case $6
                ; set command uses q_number and q_list for control number and control value
                If \sMSQNumber = grSubDef\aCtrlSend[n]\sMSQNumber
                  valErrMsg(WQM\txtQNumber, "A Control Number must be entered" + sSeq)
                  ProcedureReturn #False
                ElseIf Val(\sMSQNumber) > $3FFF
                  valErrMsg(WQM\txtQNumber, "Control Number must be less than " + Str($4000) + sSeq)
                  ProcedureReturn #False
                EndIf
                If \sMSQList = grSubDef\aCtrlSend[n]\sMSQList
                  valErrMsg(WQM\txtQList, "A Control Value must be entered")
                  ProcedureReturn #False
                ElseIf Val(\sMSQList) > $3FFF
                  valErrMsg(WQM\txtQList, "Control Value must be less than " + Str($4000) + sSeq)
                  ProcedureReturn #False
                EndIf
                
              Case $7
                ; command with macro number
                If \nMSMacro = grSubDef\aCtrlSend[n]\nMSMacro
                  valErrMsg(WQM\txtQList, "A Macro Number must be selected" + sSeq)
                  ProcedureReturn #False
                EndIf
                
              Case $1B, $1C
                If (\sMSQList = grSubDef\aCtrlSend[n]\sMSQList)
                  valErrMsg(WQM\txtQList, "A Q List must be entered" + sSeq)
                  ProcedureReturn #False
                EndIf
                
              Case $1D, $1E
                If (\sMSQPath = grSubDef\aCtrlSend[n]\sMSQPath)
                  valErrMsg(WQM\txtQList, "A Q Path must be entered" + sSeq)
                  ProcedureReturn #False
                EndIf
                
              Default
                ; no extra info or unsupported
                
            EndSelect
            
          Case #SCS_MSGTYPE_NRPN_GEN, #SCS_MSGTYPE_NRPN_YAM
            If \nMSChannel = grSubDef\aCtrlSend[n]\nMSChannel
              valErrMsg(WQM\cboMSChannel, "A MIDI Channel must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam1 = grSubDef\aCtrlSend[n]\nMSParam1 And Len(\sMSParam1) = 0
              valErrMsg(WQM\cboMSParam1, "An NRPN MSB must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam2 = grSubDef\aCtrlSend[n]\nMSParam2 And Len(\sMSParam2) = 0
              valErrMsg(WQM\cboMSParam2, "An NRPN LSB must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            If \nMSParam3 = grSubDef\aCtrlSend[n]\nMSParam3 And Len(\sMSParam3) = 0
              valErrMsg(WQM\cboMSParam3, "A Data MSB must be selected" + sSeq)
              ProcedureReturn #False
            EndIf
            ; nb "NRPN Data LSB" (\nMSParam4) is optional in the NRPN spec, so may be blank

          Case #SCS_MSGTYPE_FREE  ; MIDI Free Format
            sNoSpaces = ReplaceString(\sEnteredString, " ", "")     ; remove all spaces from entered string
            If Len(Trim(\sEnteredString)) = 0
              valErrMsg(WQM\txtMFEnteredString, "A MIDI Message must be entered" + sSeq)
              ProcedureReturn #False
            Else
              bSysExOK = #True
              If ((Len(sNoSpaces) << 1) >> 1) <> Len(sNoSpaces)
                bSysExOK = #False
              Else
                For m = 1 To Len(sNoSpaces)
                  sTmp = UCase(Mid(sNoSpaces, m, 1))
                  If FindString(#SCS_HEX_VALID_CHARS, sTmp, 1) = 0
                    bSysExOK = #False
                    Break
                  EndIf
                Next m
              EndIf
              If bSysExOK = #False
                valErrMsg(WQM\txtMFEnteredString, "A MIDI Message must be an even number of Hex digits long" + sSeq)
                ProcedureReturn #False
              EndIf
            EndIf
            
          Case #SCS_MSGTYPE_FILE   ; SCS_MSGTYPE_FILE
            sFileName = ""
            If \nAudPtr >= 0
              sFileName = aAud(\nAudPtr)\sFileName
            EndIf
            If Len(sFileName) = 0
              valErrMsg(WQM\txtMidiFile, MustBeEntered(WQM\lblMidiFile))
              ProcedureReturn #False
            EndIf
            If FileExists(sFileName) = #False
              valErrMsg(WQM\txtMidiFile, LangPars("Errors", "FileNotFound", sFileName))
              ProcedureReturn #False
            EndIf
            
          Default
            ; debugMsg(sProcName, "\nRemDevMsgType=" + \nRemDevMsgType + ", \sRemDevValue=" + \sRemDevValue)
            If \nRemDevMsgType > 0
              nRemDevMsgPtr = CSRD_GetMsgDataPtrForRemDevMsgType(\nRemDevMsgType)
              If nRemDevMsgPtr > 0
                If grCSRD\aRemDevMsgData(nRemDevMsgPtr)\sCSRD_ValData
                  If Len(Trim(\sRemDevValue)) = 0
                    valErrMsg(WQM\cboMsgType, LangPars("Errors", "MustBeSelected", CSRD_GetValDescForRemDevMsgType(\nRemDevMsgType, 1)) + sSeq) ; eg "Channel must be selected (Control Message #1)"
                    ProcedureReturn #False
                  EndIf
                EndIf
                If grCSRD\aRemDevMsgData(nRemDevMsgPtr)\sCSRD_ValData2
                  If Len(Trim(\sRemDevValue2)) = 0
                    valErrMsg(WQM\cboMsgType, LangPars("Errors", "MustBeSelected", CSRD_GetValDescForRemDevMsgType(\nRemDevMsgType, 2)) + sSeq) ; eg "Channel must be selected (Control Message #1)"
                    ProcedureReturn #False
                  EndIf
                EndIf
              EndIf
            EndIf
            
        EndSelect
        ;}
      Case #SCS_DEVTYPE_CS_RS232_OUT ; #SCS_DEVTYPE_CS_RS232_OUT
        ;{
        If Len(Trim(\sEnteredString)) = 0
          valErrMsg(WQM\txtRSEnteredString, "An RS232 Message must be entered" + sSeq)
          ProcedureReturn #False
        EndIf
        ;}
      Case #SCS_DEVTYPE_CS_NETWORK_OUT ; #SCS_DEVTYPE_CS_NETWORK_OUT
        ;{
        debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\aCtrlSend[" + n + "]\bIsOSC=" + strB(\bIsOSC) + ", \nOSCCmdType=" + decodeOSCCmdType(\nOSCCmdType) + ", \sEnteredString=" + #DQUOTE$ + \sEnteredString + #DQUOTE$ +
                            ", sOSCItemString=" + #DQUOTE$ + \sOSCItemString + #DQUOTE$)
        If \bIsOSC
          Select \nOSCCmdType
            Case #SCS_CS_OSC_GOCUE, #SCS_CS_OSC_GOSCENE, #SCS_CS_OSC_GOSNIPPET, #SCS_CS_OSC_MUTE_FIRST To #SCS_CS_OSC_MUTE_LAST
              If \nRemDevMsgType > 0
                If Len(Trim(\sRemDevValue)) = 0
                  sRemDevValType = CSRD_GetValTypeForRemDevMsgType(\nRemDevMsgType, 1)
                  valErrMsg(WQM\cboOSCItemSelect, LangPars("Errors", "MustBeSelected", sRemDevValType) + sSeq)
                  ProcedureReturn #False
                EndIf
              ElseIf Len(\sOSCItemString) = 0 And \bOSCItemPlaceHolder = #False ; And \nRemDevMsgType = 0
                If CountGadgetItems(WQM\cboOSCItemSelect) > 0
                  valErrMsg(WQM\cboOSCItemSelect, LangPars("Errors", "MustBeSelected", GGT(WQM\lblOSCItemSelect)) + sSeq)
                Else
                  valErrMsg(WQM\txtOSCItemString, LangPars("Errors", "MustBeEntered", GGT(WQM\lblOSCItemSelect)) + sSeq)
                EndIf
                ProcedureReturn #False
              EndIf
            Case #SCS_CS_OSC_FREEFORMAT
              If Len(\sEnteredString) = 0
                valErrMsg(WQM\txtOSCEnteredString, LangPars("Errors", "MustBeEntered", GGT(WQM\lblOSCEnteredString)) + sSeq)
                ProcedureReturn #False
              EndIf
            Case #SCS_CS_OSC_TC_GO, #SCS_CS_OSC_TC_BACK
              ; no further validation required
            Case #SCS_CS_OSC_TC_JUMP
              If Len(\sOSCItemString) = 0
                valErrMsg(WQM\txtOSCItemString, LangPars("Errors", "MustBeEntered", GGT(WQM\lblOSCItemSelect)) + sSeq)
                ProcedureReturn #False
              EndIf
            Case #SCS_CS_OSC_MUTE_FIRST To #SCS_CS_OSC_MUTE_LAST
              If Len(\sOSCItemString) = 0
                valErrMsg(WQM\txtOSCItemString, LangPars("Errors", "MustBeEntered", GGT(WQM\lblOSCItemSelect)) + sSeq)
                ProcedureReturn #False
              EndIf
            Case #SCS_CS_OSC_LEVEL_FIRST To #SCS_CS_OSC_LEVEL_LAST
              If Len(\sOSCItemString) = 0
                valErrMsg(WQM\txtOSCItemString, LangPars("Errors", "MustBeEntered", GGT(WQM\lblOSCItemSelect)) + sSeq)
                ProcedureReturn #False
              EndIf
            Default
              valErrMsg(WQM\cboOSCCmdType, LangPars("Errors", "MustBeSelected", GGT(WQM\lblOSCCmdType)) + sSeq)
              ProcedureReturn #False
          EndSelect
        Else
          If Len(Trim(\sEnteredString)) = 0
            valErrMsg(WQM\txtNWEnteredString, "A Network Message must be entered" + sSeq)
            ProcedureReturn #False
          EndIf
        EndIf
        ;}
      Case #SCS_DEVTYPE_LT_DMX_OUT ; #SCS_DEVTYPE_LT_DMX_OUT
        ;{
;         For m = 0 To #SCS_MAX_DMX_ITEM_PER_CTRL_SEND_ITEM
;           If \aDMXSendItem(m)\sDMXChannels
;             bDMXItemFound = #True
;             If \nDMXFadeTime > 0
;               If \aDMXSendItem(m)\bDMXFade
;                 bDMXFadeFound = #True
;                 Break
;               EndIf
;             EndIf
;           EndIf
;         Next m
;         If bDMXItemFound = #False
;           sMsg = Lang("DMX", "NoChannels")
;           valErrMsg(WQM\txtDMXChannels[0], sMsg)
;           ProcedureReturn #False
;         EndIf
;         If (\nDMXFadeTime > 0) And (bDMXFadeFound = #False)
;           sMsg = Lang("DMX", "NoFade")
;           valErrMsg(WQM\txtDMXFadeTime, sMsg)
;           ProcedureReturn #False
;         EndIf
        ;}
      Case #SCS_DEVTYPE_CS_HTTP_REQUEST  ; #SCS_DEVTYPE_CS_HTTP_REQUEST
        ;{
        If Len(Trim(\sEnteredString)) = 0
          valErrMsg(WQM\txtHTEnteredString, "An HTTP Message must be entered" + sSeq)
          ProcedureReturn #False
        EndIf
        ;}
    EndSelect
    
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
EndProcedure

Procedure getCuePtrForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected i, nCuePtr
  
  nCuePtr = -1
  For i = 1 To gnLastCue
    If aCue(i)\nNodeKey = nNodeKey
      nCuePtr = i
      Break
    EndIf
  Next i
  ProcedureReturn nCuePtr
EndProcedure

Procedure getSubPtrForNodeKey(nNodeKey)
  PROCNAMEC()
  Protected j, nSubPtr
  nSubPtr = -1
  For j = 1 To gnLastSub
    If aSub(j)\bExists
      If aSub(j)\nNodeKey = nNodeKey
        nSubPtr = j
        Break
      EndIf
    EndIf
  Next j
  ProcedureReturn nSubPtr
EndProcedure

Procedure getInitBVLevelAndPan()
  PROCNAMECS(nEditSubPtr)
  Protected d, i, j
  Protected sThisCue.s, sComment.s, sTmp.s
  Protected nLabel
  Protected bCheckThis
  Protected bUseThis
  Protected nEditSubNo
  Protected fTmpLevel.f
  Protected bPlaylist
  Protected nLCCuePtr, nLCSubPtr, nLCAudPtr
  Protected bDisplayPan
  
  debugMsg(sProcName, #SCS_START)
  
  nLabel = 1000
  sThisCue = GetGadgetText(WQL\cboLCCue)
  nEditSubNo = aSub(nEditSubPtr)\nSubNo
  
  If gbInDisplaySub = #False
    With aSub(nEditSubPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        \bLCInclude[d] = #False
      Next d
    EndWith
  EndIf
  
  nLCCuePtr = -1
  nLCSubPtr = -1
  nLCAudPtr = -1
  rWQL\nLatestCuePtr = -1
  rWQL\nLatestSubPtr = -1
  
  nLabel = 1001
  debugMsg(sProcName, "sThisCue=" + sThisCue)
  For i = 1 To nEditCuePtr
    nLabel = 1100
    bCheckThis = #False
    If i < nEditCuePtr
      bCheckThis = #True
    EndIf
    
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If i = nEditCuePtr 
          If \nSubNo < nEditSubNo
            bCheckThis = #True
          Else
            bCheckThis = #False
          EndIf
        EndIf
        If bCheckThis
          nLabel = 1200
          bUseThis = #False
          
          If \bSubTypeA
            nLabel = 1300
            If sThisCue = buildLCCueForCBO(j)
              bUseThis = #True
              nLCCuePtr = i
              nLCSubPtr = j
              nLCAudPtr = \nFirstAudIndex
              d = 0
              If gbInDisplaySub = #False
                aSub(nEditSubPtr)\bLCInclude[d] = #True
              EndIf
              aSub(nEditSubPtr)\fLCInitBVLevel[d] = aAud(nLCAudPtr)\fBVLevel[d]
              debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
              aSub(nEditSubPtr)\fLCInitPan[d] = aAud(nLCAudPtr)\fPan[d]
              gsLCPrevCueType = "A"
            EndIf
            
          ElseIf \bSubTypeF Or \bSubTypeI
            nLabel = 1400
            If sThisCue = buildLCCueForCBO(j)
              bUseThis = #True
              nLCCuePtr = i
              nLCSubPtr = j
              nLCAudPtr = \nFirstAudIndex
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If Len(Trim(aAud(nLCAudPtr)\sLogicalDev[d])) <> 0
                  If gbInDisplaySub = #False
                    aSub(nEditSubPtr)\bLCInclude[d] = #True
                  EndIf
                  aSub(nEditSubPtr)\fLCInitBVLevel[d] = aAud(nLCAudPtr)\fBVLevel[d]
                  debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
                  aSub(nEditSubPtr)\fLCInitPan[d] = aAud(nLCAudPtr)\fPan[d]
                EndIf
              Next d
              If \bSubTypeF
                gsLCPrevCueType = "F"
              ElseIf \bSubTypeI
                gsLCPrevCueType = "I"
              EndIf
            EndIf
            
          ElseIf \bSubTypeP
            nLabel = 1500
            If sThisCue = buildLCCueForCBO(j)
              bUseThis = #True
              nLCCuePtr = i
              nLCSubPtr = j
              nLCAudPtr = -1
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If Len(Trim(aSub(nLCSubPtr)\sPLLogicalDev[d])) <> 0
                  If gbInDisplaySub = #False
                    aSub(nEditSubPtr)\bLCInclude[d] = #True
                  EndIf
                  aSub(nEditSubPtr)\fLCInitBVLevel[d] = aSub(nLCSubPtr)\fSubMastBVLevel[d]
                  debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
                  aSub(nEditSubPtr)\fLCInitPan[d] = aSub(nLCSubPtr)\fPLPan[d]
                EndIf
              Next d
              gsLCPrevCueType = "P"
              bPlaylist = #True
            EndIf
            
          ElseIf \bSubTypeL
            nLabel = 1600
            If aSub(nEditSubPtr)\nLCCuePtr = \nLCCuePtr And aSub(nEditSubPtr)\nLCSubPtr = \nLCSubPtr
              ; nEditSubPtr level change operates on same cue and subcue as i, j
              bUseThis = #True
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                If \bLCInclude[d]
                  If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
                    aSub(nEditSubPtr)\fLCInitBVLevel[d] = \fLCReqdBVLevel[d]
                    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
                  Else
                    fTmpLevel = convertDBLevelToBVLevel(convertBVLevelToDBLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]) + convertBVLevelToDBLevel(\fLCReqdBVLevel[d]))
                    If fTmpLevel > grLevels\fMaxBVLevel
                      fTmpLevel = grLevels\fMaxBVLevel
                    ElseIf fTmpLevel < #SCS_MINVOLUME_SINGLE
                      fTmpLevel = #SCS_MINVOLUME_SINGLE
                    EndIf
                    aSub(nEditSubPtr)\fLCInitBVLevel[d] = fTmpLevel
                    debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
                  EndIf
                  aSub(nEditSubPtr)\fLCInitPan[d] = \fLCReqdPan[d]
                EndIf
              Next d
              gsLCPrevCueType = "L"
            EndIf
          EndIf
          
          nLabel = 1700
          If \bSubTypeL
            nLabel = 1800
            If bUseThis
              If \nPrevSubIndex = -1 And \nNextSubIndex = -1
;                 sComment = "  Level and Pan before change (shown with white markers) based on Level and Pan of " + \sCue + ".  "
                sComment = " " + LangPars("WQL", "CommentL", \sCue) + " "
              Else
;                 sComment = "  Level and Pan before change (shown with white markers) based on Level and Pan of " + \sCue + " <" + \nSubNo + ">.  "
                sComment = " " + LangPars("WQL", "CommentL", \sCue + " <" + \nSubNo + ">") + " "
              EndIf
              rWQL\nLatestCuePtr = i
              rWQL\nLatestSubPtr = j
            EndIf
          EndIf
        EndIf
        nLabel = 1900
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  nLabel = 2000
  
  If bPlaylist
    sTmp = " " + Lang("WQL", "CommentP") + " "
    If Len(sComment) = 0
      sComment = sTmp
    Else
      sComment + #CRLF$ + sTmp
    EndIf
  EndIf
  
  SGT(WQL\lblLCComment, sComment)
  If Len(Trim(sComment)) = 0
    setVisible(WQL\lblLCComment, #False)
  Else
    setVisible(WQL\lblLCComment, #True)
  EndIf
  
  If gbInDisplaySub = #False
    With WQL
      nLabel = 2100
      For d = 0 To grLicInfo\nMaxAudDevPerAud
        If aSub(nEditSubPtr)\bLCInclude[d]
          If d >= 0
            bDisplayPan = #True
            If aSub(nEditSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE
              If nLCAudPtr >= 0
                SLD_setBaseLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], aAud(nLCAudPtr)\fTrimFactor[d])
                SLD_setLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], aAud(nLCAudPtr)\fTrimFactor[d])
                bDisplayPan = aAud(nLCAudPtr)\bDisplayPan[d]
              ElseIf nLCSubPtr >= 0
                SLD_setBaseLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], aSub(nLCSubPtr)\fSubTrimFactor[d])
                SLD_setLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], aSub(nLCSubPtr)\fSubTrimFactor[d])
              Else
                SLD_setBaseLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], 1)
                SLD_setLevel(\sldLCLevel[d], aSub(nEditSubPtr)\fLCInitBVLevel[d], 1)
              EndIf
              debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitBVLevel[" + d + "]=" + traceLevel(aSub(nEditSubPtr)\fLCInitBVLevel[d]))
              ; SLD_setValue(\sldLCLevel[d], SLD_getBaseValue(\sldLCLevel[d]), #False)
            EndIf
            If bDisplayPan
              debugMsg(sProcName, "aSub(" + getSubLabel(nEditSubPtr) + ")\fLCInitPan[" + d + "]=" + formatPan(aSub(nEditSubPtr)\fLCInitPan[d]))
              SLD_setBaseValue(\sldLCPan[d], panToSliderValue(aSub(nEditSubPtr)\fLCInitPan[d]))
              SLD_setValue(\sldLCPan[d], SLD_getBaseValue(\sldLCPan[d]), #False)
            EndIf
          EndIf
        EndIf
      Next d
    EndWith
  EndIf
EndProcedure

Procedure getLastSubForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected j, nSubPtr

  nSubPtr = -1
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    nSubPtr = j
    j = aSub(j)\nNextSubIndex
  Wend

  ProcedureReturn nSubPtr

EndProcedure

Procedure getRelTime(pTime, pStartAt)
  PROCNAMEC()
  If pTime <= 0
    ; if -1, -2 or 0 then return exactly that
    ProcedureReturn pTime
  Else
    ; if > 0 then adjust by start at time
    If pStartAt = -3
      ; -3 = 'start' = 0
      ProcedureReturn pTime
    Else
      ProcedureReturn pTime - pStartAt
    EndIf
  EndIf
EndProcedure

Procedure moveUpOrDown(nSelectedNodeCuePtr, nSelectedNodeSubPtr, nSelectedNodeKey, bMoveUp)
  PROCNAMEC()
  Protected rTmpCue.tyCue
  Protected nCuePtr1, nCuePtr2, nThisSubPtr
  Protected nReqdCuePtr, nReqdSubNo
  Protected j
  Protected nNodeKeyToSelect
  Protected nCueNodeKey, nBeforeNodeKey, bRedoTree
  Protected u1, u2, u3
  Protected sUndoDescr.s

  debugMsg(sProcName, #SCS_START + ", nSelectedNodeCuePtr=" + getCueLabel(nSelectedNodeCuePtr) + ", nSelectedNodeSubPtr=" + getSubLabel(nSelectedNodeSubPtr) + ", nSelectedNodeKey=" + Str(nSelectedNodeKey) + ", bMoveUp=" + strB(bMoveUp))

  nCuePtr1 = -1
  nCuePtr2 = -1
  nThisSubPtr = -1
  nNodeKeyToSelect = nSelectedNodeKey
  bRedoTree = #True
  
  If nSelectedNodeCuePtr >= 0
    nCueNodeKey = aCue(nSelectedNodeCuePtr)\nNodeKey
    If nSelectedNodeSubPtr < 0
      ; move whole cue
      nCuePtr1 = nSelectedNodeCuePtr
      If bMoveUp
        nCuePtr2 = nCuePtr1 - 1
        bRedoTree = #False
      Else ; move down
        nCuePtr2 = nCuePtr1 + 1
        bRedoTree = #False
      EndIf
      sUndoDescr = "Move Cue " + getCueLabel(nCuePtr1)
      u1 = preChangeCueL(#True, sUndoDescr, nCuePtr1, #SCS_UNDO_ACTION_MOVE_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE)
      rTmpCue = aCue(nSelectedNodeCuePtr)
      aCue(nCuePtr1) = aCue(nCuePtr2)
      aCue(nCuePtr2) = rTmpCue
      
    Else
      ; move one sub
      nCuePtr1 = nSelectedNodeCuePtr
      nThisSubPtr = nSelectedNodeSubPtr
      If bMoveUp
        j = aSub(nThisSubPtr)\nPrevSubIndex
        If j >= 0
          ; move up one position within current cue
          nCuePtr2 = nCuePtr1
        Else
          ; move into last position of previous cue
          nCuePtr2 = nCuePtr1 - 1
        EndIf
      Else  ; move down
        j = aSub(nThisSubPtr)\nNextSubIndex
        If j >= 0
          ; move down one position within current cue
          nCuePtr2 = nCuePtr1
        Else
          ; move into first position of next cue
          nCuePtr2 = nCuePtr1 + 1
        EndIf
      EndIf
      
      sUndoDescr = "Move Sub-Cue " + getSubLabel(nThisSubPtr)
      u1 = preChangeCueL(#True, sUndoDescr, nCuePtr1, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(nCuePtr1)\nCueId)
      If nCuePtr2 <> nCuePtr1
        u2 = preChangeCueL(#True, sUndoDescr, nCuePtr2) ;, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_TREE)
      EndIf
      u3 = preChangeSubL(#True, sUndoDescr, nThisSubPtr, #SCS_UNDO_ACTION_MOVE_SUB) ;, -1, #SCS_UNDO_FLAG_REDO_TREE)
      
      If bMoveUp
        debugMsg(sProcName, "move sub up")
        If nCuePtr2 = nCuePtr1
          ; move up one position within current cue
          moveOneSub(nThisSubPtr, nCuePtr1, aSub(nThisSubPtr)\nSubNo - 1)
          bRedoTree = #False
        Else
          ; move into last position of previous cue
          moveOneSub(nThisSubPtr, nCuePtr2, -1)
          If aSub(nThisSubPtr)\nPrevSubIndex >= 0
            ; at least two subcues
            aCue(nCuePtr2)\bNodeExpanded = #True
          Else
            ; this is the first subcue
            nNodeKeyToSelect = aCue(nCuePtr2)\nNodeKey
          EndIf
        EndIf
        
      Else ; move down
        debugMsg(sProcName, "move sub down")
        If nCuePtr2 = nCuePtr1
          ; move down one position within current cue
          moveOneSub(nThisSubPtr, nCuePtr1, aSub(nThisSubPtr)\nSubNo + 1)
          bRedoTree = #False
        Else
          ; move into first position of next cue
          moveOneSub(nThisSubPtr, nCuePtr2, 1)
          If aSub(nThisSubPtr)\nNextSubIndex >= 0
            ; at least two subcues
            aCue(nCuePtr2)\bNodeExpanded = #True
          Else
            ; this is the first subcue
            nNodeKeyToSelect = aCue(nCuePtr2)\nNodeKey
          EndIf
        EndIf
      EndIf
      
    EndIf
    
    debugMsg(sProcName, "calling resyncCuePtrs()")
    resyncCuePtrs() ; Added 31Jan2024 11.10.2ad
    
    nEditCuePtr = nCuePtr2
    debugMsg(sProcName, "nCuePtr1=" + getCueLabel(nCuePtr1) + ", nCuePtr2=" + getCueLabel(nCuePtr2) + ", nEditCuePtr=" + getCueLabel(nEditCuePtr))
    
    If nCuePtr1 >= 0
      setLabels(nCuePtr1)
      setDerivedCueFields(nCuePtr1, #False)
      samAddRequest(#SCS_SAM_LOAD_GRID_ROW, nCuePtr1)
    EndIf
    
    If (nCuePtr2 >= 0) And (nCuePtr2 <> nCuePtr1)
      setLabels(nCuePtr2)
      setDerivedCueFields(nCuePtr2, #False)
      samAddRequest(#SCS_SAM_LOAD_GRID_ROW, nCuePtr2)
    EndIf
    
    setCuePtrs(#False)
    setTimeBasedCues()
    loadHotkeyArray()
    loadCueMarkerArrays()
    
    If nSelectedNodeSubPtr < 0
      ; moved whole cue
      postChangeCueL(u1, #False, nCuePtr2)
    Else
      ; moved one sub
      postChangeSubL(u3, #False, nThisSubPtr)
      If nCuePtr2 <> nCuePtr1
        setDefaultCueDescrMayBeSet(nCuePtr2, #False)
        postChangeCueL(u2, #False, nCuePtr2)
      EndIf
      setDefaultCueDescrMayBeSet(nCuePtr1, #False)
      postChangeCueL(u1, #False, nCuePtr1)
    EndIf
    
    gnSelectedNodeKey = -1  ; force WED_doNodeClick() to refresh tree (fixes first problem reported by Eric Snodgrass under "Moving Cues in Editor Window bugs 11.2.4")
    
    If bRedoTree
      debugMsg(sProcName, "calling redoCueListTree(" + Str(nNodeKeyToSelect) + ")")
      redoCueListTree(nNodeKeyToSelect)
    Else
      debugMsg(sProcName, "calling RemoveGadgetItem(WED\tvwProdTree, " + Str(getTreeItemNoForNodeKey(nCueNodeKey)) + ")")
      RemoveGadgetItem(WED\tvwProdTree, getTreeItemNoForNodeKey(nCueNodeKey))
      If nCuePtr2 < gnLastCue
        nBeforeNodeKey = aCue(nCuePtr2 + 1)\nNodeKey
      EndIf
      debugMsg(sProcName, "calling addCueNode(" + aCue(nCuePtr2)\sCue + ")")
      addCueNode(nCuePtr2, nBeforeNodeKey)
      debugMsg3(sProcName, "calling WED_publicNodeClick(nNodeKey)") 
      WED_publicNodeClick(nNodeKeyToSelect)
    EndIf
    
    gbCallSetGoButton = #True
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure moveLeft(nSelectedNodeCuePtr, nSelectedNodeSubPtr, nSelectedNodeKey)
  PROCNAMEC()
  Protected sCue.s, nNodeKey, nFirstGeneratedNodeKey
  Protected i, j, k, nSubNo, nPrevSubIndex
  Protected nNodeKeyToSelect
  Protected nCuePtr1, nCuePtr2, nSubPtr
  Protected nSubCount
  Protected Dim aSubPtr(0)    ; note: aSubPtr(0) is not used. data stored from aSubPtr(1).
  Protected sUndoDescr.s
  Protected u, u2
  
  debugMsg(sProcName, #SCS_START + ", nSelectedNodeCuePtr=" + getCueLabel(nSelectedNodeCuePtr) + ", nSelectedNodeSubPtr=" + getSubLabel(nSelectedNodeSubPtr) + ", nSelectedNodeKey=" + nSelectedNodeKey) ; left2

  nCuePtr1 = -1
  nCuePtr2 = -1
  nNodeKeyToSelect = nSelectedNodeKey
  
  If nSelectedNodeCuePtr >= 0 And nSelectedNodeSubPtr >= 0
    nCuePtr1 = nSelectedNodeCuePtr
    nCuePtr2 = nCuePtr1 + 1
    If addCue(nCuePtr2) = #False
      ProcedureReturn
    EndIf
    
    sCue = aCue(nCuePtr2)\sCue           ; hold generated cue label
    nNodeKey = aCue(nCuePtr2)\nNodeKey   ; hold generated node key
    
    sUndoDescr = "Make cue " + sCue + " from sub-cues of cue " + aCue(nCuePtr1)\sCue
    u = preChangeCueL(#True, sUndoDescr, nCuePtr1, #SCS_UNDO_ACTION_MAKE_SCS_CUE_FROM_SUBS, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(nCuePtr2)\nCueId)
    
    nNodeKeyToSelect = nNodeKey
    
    nSubCount = 0
    j = nSelectedNodeSubPtr
    While j >= 0
      nSubCount = nSubCount + 1
      j = aSub(j)\nNextSubIndex
    Wend
    ReDim aSubPtr(nSubCount)
    
    nSubCount = 0
    j = nSelectedNodeSubPtr
    While j >= 0
      nSubCount = nSubCount + 1
      aSubPtr(nSubCount) = j
      j = aSub(j)\nNextSubIndex
    Wend
    
    For nSubNo = 1 To nSubCount
      nSubPtr = aSubPtr(nSubNo)
      moveOneSub(nSubPtr, nCuePtr2, nSubNo)
    Next nSubNo
    
    setCueState(nCuePtr2)
    setDefaultCueDescr(nCuePtr2, nSelectedNodeSubPtr)
    
    resetSubStart(nSelectedNodeSubPtr)
    
    If nCuePtr1 >= 0
      autoSetNodeExpanded(nCuePtr1)
    EndIf
    
    If nCuePtr2 >= 0 And nCuePtr2 <> nCuePtr1
      autoSetNodeExpanded(nCuePtr2)
    EndIf
    
    setCuePtrs(#False)
    setTimeBasedCues()
    loadHotkeyArray()
    loadCueMarkerArrays()
    
    setDefaultCueDescrMayBeSet(nCuePtr2, #False)
    postChangeCueL(u, #False, nCuePtr2)
    
    debugMsg(sProcName, "calling redoCueListTree(" + nNodeKeyToSelect + ")")
    redoCueListTree(nNodeKeyToSelect)
    
    gbCallSetGoButton = #True
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure moveRightUp(nSelectedNodeCuePtr, nSelectedNodeSubPtr, nSelectedNodeKey)
  PROCNAMEC()
  Protected nCuePtr1, nCuePtr2
  Protected nNodeKeyToSelect
  Protected i, j, k
  Protected nLastSubPtr
  Protected u1, u2, u3, u4
  Protected sMsgStart.s, sShortDescr1.s, sShortDescr2.s
  
  debugMsg(sProcName, #SCS_START + ", nSelectedNodeCuePtr=" + getCueLabel(nSelectedNodeCuePtr) + ", nSelectedNodeSubPtr=" + getSubLabel(nSelectedNodeSubPtr) + ", nSelectedNodeKey=" + nSelectedNodeKey) ; 6Mar2025
  
  nCuePtr1 = -1
  nCuePtr2 = -1
  nNodeKeyToSelect = nSelectedNodeKey
  
  If nSelectedNodeCuePtr > 1 And nSelectedNodeSubPtr < 0
    nCuePtr1 = nSelectedNodeCuePtr          ; cue currently containing the subs
    nCuePtr2 = nSelectedNodeCuePtr - 1      ; target cue for the subs
    
    ; sMsgStart = LangPars("Errors", "CannotDeleteCue2", aCue(nCuePtr1)\sCue, aCue(nCuePtr2)\sCue)
    sShortDescr1 = makeShortDescr(getCueLabel(nCuePtr1), aCue(nCuePtr1)\sCueDescr)
    sShortDescr2 = makeShortDescr(getCueLabel(nCuePtr2), aCue(nCuePtr2)\sCueDescr)
    sMsgStart = LangPars("Errors", "CannotDeleteCue2", sShortDescr1, sShortDescr2)
    If checkDelCueRI(nCuePtr1, sMsgStart) = #False
      ProcedureReturn
    EndIf
    
    stopCue(nCuePtr1, "ALL", #False)
    closeCue(nCuePtr1)
    
    i = nCuePtr2    ; target cue
    nNodeKeyToSelect = aCue(i)\nNodeKey
    
    u1 = preChangeCueL(#True, "Move Sub-Cues to Previous Cue", nCuePtr1, #SCS_UNDO_ACTION_DELETE, -1, #SCS_UNDO_FLAG_SET_CUE_PTRS | #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_REDO_MAIN)
    u2 = preChangeCueL(#True, "Add Subs from Following Cue", nCuePtr2, #SCS_UNDO_ACTION_CHANGE, -1, #SCS_UNDO_FLAG_REDO_CUE)
    
    j = aCue(i)\nFirstSubIndex
    nLastSubPtr = j
    While j >= 0
      nLastSubPtr = j
      j = aSub(j)\nNextSubIndex
    Wend
    
    If nLastSubPtr = -1
      aCue(i)\nFirstSubIndex = aCue(nSelectedNodeCuePtr)\nFirstSubIndex
    Else
      With aSub(nLastSubPtr)
        u3 = preChangeSubL(\nNextSubIndex, "Change", nLastSubPtr)
        \nNextSubIndex = aCue(nSelectedNodeCuePtr)\nFirstSubIndex
        postChangeSubL(u3, \nNextSubIndex, nLastSubPtr)
      EndWith
    EndIf
    
    j = aCue(nSelectedNodeCuePtr)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        u3 = preChangeSubL(\nCueIndex, "Change", j)
        If \nPrevSubIndex = -1
          \nPrevSubIndex = nLastSubPtr
          nNodeKeyToSelect = \nNodeKey
          aCue(i)\bNodeExpanded = #True
        EndIf
        \nCueIndex = i
        \sCue = aCue(i)\sCue
        k = \nFirstAudIndex
        While k >= 0
          u4 = preChangeAudL(aAud(k)\nCueIndex, "Change", k)
          aAud(k)\nCueIndex = i
          aAud(k)\sCue = aCue(i)\sCue
          postChangeAudL(u4, aAud(k)\nCueIndex, k)
          k = aAud(k)\nNextAudIndex
        Wend
        postChangeSubL(u3, \nCueIndex, j)
        j = \nNextSubIndex
      EndWith
    Wend
    
    ; now delete origin cue
    For i = nCuePtr1 To gnLastCue
      If i < gnLastCue
        aCue(i) = aCue(i+1)
      EndIf
    Next i
    gnLastCue - 1
    gnCueEnd = gnLastCue + 1
    
    debugMsg(sProcName, "calling renumberSubNos()") ; 6Mar2025
    renumberSubNos(nCuePtr2)
    debugMsg(sProcName, "calling setLabels()") ; 6Mar2025
    setLabels(nCuePtr2)
    
    ; Change 6Mar2025 11.10.8ab: swapped the order of calling setDerivedCueFields and setCuePtrs()
    ; to fix the bug reported by Brian Howatt
;     debugMsg(sProcName, "calling setDerivedCueFields()") ; 6Mar2025
;     setDerivedCueFields(nCuePtr2, #False)
    debugMsg(sProcName, "calling setCuePtrs()") ; 6Mar2025
    setCuePtrs(#False)
    debugMsg(sProcName, "calling setDerivedCueFields()") ; 6Mar2025
    setDerivedCueFields(nCuePtr2, #False)
    ; End of change 6Mar2025
    
    debugMsg(sProcName, "calling setTimeBasedCues()") ; 6Mar2025
    setTimeBasedCues()
    debugMsg(sProcName, "calling loadHotkeyArray()") ; 6Mar2025
    loadHotkeyArray()
    debugMsg(sProcName, "calling loadCueMarkerArrays()") ; 6Mar2025
    loadCueMarkerArrays()
    
    debugMsg(sProcName, "calling redoCueListTree(" + Str(nNodeKeyToSelect) + ")")
    redoCueListTree(nNodeKeyToSelect)
    
    debugMsg(sProcName, "calling setCueDetailsInMain()")
    setCueDetailsInMain()
    
    setDefaultCueDescrMayBeSet(nCuePtr2, #False)
    postChangeCueL(u2, #False, nCuePtr2)
    postChangeCueL(u1, #False, -1) ; -1 means 'deleted'
    
    gbCallSetGoButton = #True
    gbCallPopulateGrid = #True
    gbCallLoadDispPanels = #True
    
  EndIf
  
  debugMsg(sProcName, #SCS_END) ; 6Mar2025
  
EndProcedure

Procedure moveOneSub(pSubPtr, pReqdCuePtr, pReqdSubNo)
  PROCNAMECS(pSubPtr)
  Protected rTmpSub.tySub
  Protected nReqdSubNo
  Protected nCuePtr1, nCuePtr2
  Protected j, j2
  Protected bFound
  Protected nPrevSubPtr, nNextSubPtr

  debugMsg(sProcName, #SCS_START + ", pSubPtr=" + pSubPtr + ", pReqdCuePtr=" + Str(pReqdCuePtr) + ", pReqdSubNo=" + Str(pReqdSubNo))
  
  ; if pReqdSubNo < 0 then this means the sub is to be moved to the last position in the cue, ie 1 greater than the current last nSubNo for the required cue

  If pReqdSubNo >= 0
    nReqdSubNo = pReqdSubNo
  Else
    j = getLastSubForCue(pReqdCuePtr)
    If j >= 0
      nReqdSubNo = aSub(j)\nSubNo + 1
    Else
      nReqdSubNo = 1
    EndIf
    debugMsg(sProcName, "nReqdSubNo=" + Str(nReqdSubNo))
  EndIf

  nCuePtr1 = -1
  nCuePtr2 = -1

  ; disconnect sub from current parent cue
  rTmpSub = aSub(pSubPtr)
  nCuePtr1 = rTmpSub\nCueIndex
  If rTmpSub\nPrevSubIndex < 0
    aCue(nCuePtr1)\nFirstSubIndex = rTmpSub\nNextSubIndex
  Else
    aSub(rTmpSub\nPrevSubIndex)\nNextSubIndex = rTmpSub\nNextSubIndex
  EndIf

  If rTmpSub\nNextSubIndex >= 0
    aSub(rTmpSub\nNextSubIndex)\nPrevSubIndex = rTmpSub\nPrevSubIndex
  EndIf

  renumberSubNos(nCuePtr1)

  ; connect sub to required cue at required position
  nCuePtr2 = pReqdCuePtr
  With aSub(pSubPtr)
    \sCue = aCue(nCuePtr2)\sCue
    \nCueIndex = nCuePtr2
    j = aCue(nCuePtr2)\nFirstSubIndex
    If nReqdSubNo = 1
      aCue(nCuePtr2)\nFirstSubIndex = pSubPtr
      \nPrevSubIndex = -1
      \nNextSubIndex = j
      If j >= 0
        aSub(j)\nPrevSubIndex = pSubPtr
      EndIf
    Else
      bFound = #False
      While j >= 0 And bFound = #False
        j2 = j  ; hold last j in case reqd subno not found
        If aSub(j)\nSubNo = nReqdSubNo
          bFound = #True
          nPrevSubPtr = aSub(j)\nPrevSubIndex
          nNextSubPtr = j
          ; set previous sub's next pointer to point to new sub
          If nPrevSubPtr < 0
            aCue(nCuePtr2)\nFirstSubIndex = pSubPtr
          Else
            aSub(nPrevSubPtr)\nNextSubIndex = pSubPtr
          EndIf
          ; set new sub's prev pointer to point to previous sub (or -1 if no previous sub)
          \nPrevSubIndex = nPrevSubPtr
          ; set new sub's next pointer to point to sub we are inserting before
          \nNextSubIndex = nNextSubPtr
          ; set the next sub's prev pointer to point to the new sub
          If nNextSubPtr >= 0
            aSub(nNextSubPtr)\nPrevSubIndex = pSubPtr
          EndIf
        EndIf
        If bFound = #False
          j = aSub(j)\nNextSubIndex
        EndIf
      Wend
      
      If bFound = #False
        ; nReqdSubNo not found
        nPrevSubPtr = j2
        nNextSubPtr = -1
        ; set previous sub's next pointer to point to new sub
        If nPrevSubPtr < 0
          aCue(nCuePtr2)\nFirstSubIndex = pSubPtr
        Else
          aSub(nPrevSubPtr)\nNextSubIndex = pSubPtr
        EndIf
        ; set new sub's prev pointer to point to previous sub (or -1 if no previous sub)
        \nPrevSubIndex = nPrevSubPtr
        ; set new sub's next pointer to point to sub we are inserting before
        \nNextSubIndex = nNextSubPtr
      EndIf
    EndIf
  EndWith

  ; set parent pointers etc
  setChildInfoForCue(nCuePtr2)

  renumberSubNos(nCuePtr2)

  If nCuePtr1 >= 0
    setLabels(nCuePtr1)
    setDerivedCueFields(nCuePtr1, #False)
    resyncCuePtrs(nCuePtr1)
  EndIf

  If nCuePtr2 >= 0 And nCuePtr2 <> nCuePtr1
    setLabels(nCuePtr2)
    setDerivedCueFields(nCuePtr2, #False)
    resyncCuePtrs(nCuePtr2)
  EndIf

  loadHotkeyArray()
  loadCueMarkerArrays()
  
  setCuePtrs(#False)
  
  gbCallPopulateGrid = #True
  gbCallLoadDispPanels = #True

  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure newProd()
  PROCNAMEC()
  Protected bCancel, nResponse, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  WEN_closeMemoWindowsIfOpen()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not start new file
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  If gnLastCue > 0
    sMsg = Lang("WED", "NewProd1") + " (" + GetFilePart(gsCueFile) + ")." + #CRLF$ + #CRLF$ + Lang("WED", "NewProd2")
    nResponse = scsMessageRequester(Lang("WED","Window"), sMsg, #PB_MessageRequester_YesNo | #MB_ICONEXCLAMATION)
    If nResponse <> #PB_MessageRequester_Yes
      debugMsg(sProcName, "user selected 'No'")
      ProcedureReturn
    EndIf
  EndIf
  
  samAddRequest(#SCS_SAM_NEW_CUE_FILE)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openProd()
  PROCNAMEC()
  Protected bCancel, nResponse
  Protected sTitle.s, sDefaultFile.s
  Protected sTmp.s
  
  WEN_closeMemoWindowsIfOpen()
  debugMsg(sProcName, "calling checkDataChanged(#True)")
  bCancel = checkDataChanged(#True)
  If bCancel
    ; either user cancelled when asked about saving, or an error was detected during validation, so do not open new file
    ProcedureReturn
  EndIf
  setMonitorPin()
  
  debugMsg(sProcName, "calling saveProdTimerHistIfReqd()")
  saveProdTimerHistIfReqd()
  
  sTitle = Lang("Common", "OpenSCSCueFile")
  If Len(Trim(gsCueFolder)) > 0
    sDefaultFile = Trim(gsCueFolder)
  ElseIf Len(Trim(grGeneralOptions\sInitDir)) > 0
    sDefaultFile = Trim(grGeneralOptions\sInitDir)
  EndIf
  
  ; Open the file for reading
  sTmp = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
  If Len(sTmp) = 0
    ProcedureReturn
  EndIf
  gsCueFile = sTmp
  gsCueFolder = GetPathPart(gsCueFile)
  debugMsg(sProcName, "gsCueFolder=" + gsCueFolder)
  
  samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, -1)  ; p1: 1 = primary file.  p3: -1 = call editor after loading, with -1 as the cueptr
  
EndProcedure

Procedure setChildInfoForCue(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k
  Protected sCue.s, nSubNo

  debugMsg(sProcName, #SCS_START)
  
  ; set parent pointers etc
  i = pCuePtr
  sCue = aCue(i)\sCue
  nSubNo = 0
  j = aCue(i)\nFirstSubIndex
  While j >= 0
    With aSub(j)
      \sCue = sCue
      \nCueIndex = i
      nSubNo = nSubNo + 1
      \nSubNo = nSubNo
      If \bSubTypeHasAuds
        k = \nFirstAudIndex
        While k >= 0
          aAud(k)\sCue = sCue
          aAud(k)\nCueIndex = i
          aAud(k)\nSubIndex = j
          aAud(k)\nSubNo = nSubNo
          debugMsg(sProcName, "aAud(" + k + ")\nCueIndex=" + aAud(k)\nCueIndex + ", \nSubIndex=" + aAud(k)\nSubIndex)
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      j = \nNextSubIndex
    EndWith
  Wend
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s buildLiveInputDescr(pSubPtr)
  PROCNAMEC()
  Protected sDescr.s, sDescrOn.s, sDescrOff.s
  Protected sInputLogicalDev.s
  Protected d
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If (\nAudCount = 1) And (\nFirstAudIndex >= 0)
        For d = 0 To grLicInfo\nMaxLiveDevPerAud
          sInputLogicalDev = aAud(\nFirstAudIndex)\sInputLogicalDev[d]
          If sInputLogicalDev
            If aAud(\nFirstAudIndex)\bInputOff[d]
              If sDescrOff
                sDescrOff + "+"
              EndIf
              sDescrOff + sInputLogicalDev
            Else
              If sDescrOn
                sDescrOn + "+"
              EndIf
              sDescrOn + sInputLogicalDev
            EndIf
          EndIf
        Next d
        If sDescrOff
          sDescr = sDescrOff + " " + UCase(grText\sTextOff)
          If sDescrOn
            sDescr + "; " + sDescrOn + " " + UCase(grText\sTextOn)
          EndIf
        Else
          sDescr = sDescrOn
        EndIf
      Else
        sDescr = Lang("WQI", "dfltDescr")
      EndIf
    EndWith
  EndIf
  ProcedureReturn sDescr
EndProcedure

Procedure setResyncLinksReqd(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected i, j, k
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    If \nFileFormat = #SCS_FILEFORMAT_AUDIO
      If \nLinkedToAudPtr > 0
        aAud(\nLinkedToAudPtr)\bResyncLinksReqd = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(\nLinkedToAudPtr) + ")\bResyncLinksReqd=" + strB(aAud(\nLinkedToAudPtr)\bResyncLinksReqd))
      ElseIf \nAudLinkCount > 0
        \bResyncLinksReqd = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bResyncLinksReqd=" + strB(\bResyncLinksReqd))
      EndIf
    EndIf
    
    If \bResyncLinksReqd = #False
      For i = 1 To gnLastCue
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeF
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              If aAud(k)\nLinkedToAudPtr = pAudPtr
                \bResyncLinksReqd = #True
                debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bResyncLinksReqd=" + strB(\bResyncLinksReqd))
                Break
              EndIf
              k = aAud(k)\nNextAudIndex
            Wend
            If \bResyncLinksReqd
              Break
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
        If \bResyncLinksReqd
          Break
        EndIf
      Next i
    EndIf
    
  EndWith
  
EndProcedure

Procedure startEditor(pCuePtr, bCueListMutexLockedByCaller=#False)
  PROCNAMECQ(pCuePtr)
  Protected n
  
  ; this procedure must ONLY be called from callEditor()

  logKeyEvent(#SCS_START + ", bCueListMutexLockedByCaller=" + strB(bCueListMutexLockedByCaller))

  gbEditing = #True
  debugMsg(sProcName, "gbEditing=" + strB(gbEditing))
  gbEditHasFocus = #True
  
  gbDoProdDevsForA = #True
  gbDoProdDevsForF = #True
  gbDoProdDevsForI = #True
  gbDoProdDevsForK = #True
  gbDoProdDevsForP = #True
  
  ED_loadDevChgsFromProd()
  
  If grTempDB\bTempDatabaseLoaded = #False
    debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
    loadTempDatabaseFromProdDatabase()
  EndIf
  
  WED_setWindowTitle()
  
  fcEditLabelsFrozen()
  
  debugMsg(sProcName, "calling populateProdTree()")
  populateProdTree()
  debugMsg(sProcName, "calling WED_displayTemplateInfoIfReqd(#True, #True)")
  WED_displayTemplateInfoIfReqd(#True, #True)
  
  debugMsg(sProcName, "calling holdDataForEditCancel()")
  holdDataForEditCancel()
  
  debugMsg(sProcName, "Setting nEditCuePtr (" + nEditCuePtr + ") to " + pCuePtr)
  nEditCuePtr = pCuePtr
  nEditSubPtr = -1
  setEditAudPtr(-1)
  gnDisplayedCuePtr = -1
  gnDisplayedSubPtr = -1
  gnDisplayedAudPtr = -1
  
  For n = 0 To (gnGaplessSeqCount - 1)
    gaGaplessSeqs(n)\bMajorChangeInEditor = #False
  Next n
  
  gbSkipValidation = #True

  If gbGoToProdPropDevices
    debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
    WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller)
  Else
    If (pCuePtr < 0) Or (pCuePtr = gnCueEnd)
      debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
      WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller)
    Else
      debugMsg(sProcName, "calling WED_publicNodeClick(" + grProd\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ", #True)")
      WED_publicNodeClick(grProd\nNodeKey, bCueListMutexLockedByCaller, #True)  ; #True = suppress node display
      debugMsg(sProcName, "calling WED_publicNodeClick(" + aCue(pCuePtr)\nNodeKey + ", " + strB(bCueListMutexLockedByCaller) + ")")
      WED_publicNodeClick(aCue(pCuePtr)\nNodeKey, bCueListMutexLockedByCaller)
    EndIf
    With WEP
      ; reset all panel gadgets in the editor to their first panel item
      ; (nb some of the following only have one panel item but are displayed as panel gadgets for a consistent appearance)
      If IsGadget(\pnlProd)
        SGS(\pnlProd, 0)
        If IsGadget(\pnlDevs) : SGS(\pnlDevs, 0) : EndIf
        If IsGadget(\pnlAudDevDetail) : SGS(\pnlAudDevDetail, 0) : EndIf
        If IsGadget(\pnlVidAudDevDetail) : SGS(\pnlVidAudDevDetail, 0) : EndIf
        If IsGadget(\pnlVidCapDevDetail) : SGS(\pnlVidCapDevDetail, 0) : EndIf
        If IsGadget(\pnlFixTypeDetail) : SGS(\pnlFixTypeDetail, 0) : EndIf
        If IsGadget(\pnlInGrpDetail) : SGS(\pnlInGrpDetail, 0) : EndIf
        If IsGadget(\pnlLiveInputDevDetail) : SGS(\pnlLiveInputDevDetail, 0) : EndIf
      EndIf
    EndWith
  EndIf

  If (grEditingOptions\bSaveAlwaysOn) And (gbEditorAndOptionsLocked = #False) And (grLicInfo\bPlayOnly = #False)
    WED_enableTBTButton(#SCS_TBEB_SAVE, #True)
  Else
    WED_enableTBTButton(#SCS_TBEB_SAVE, #False)
  EndIf

  debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  debugMsg(sProcName, "calling setFileSave")
  setFileSave()
  
  If gbUseSMS
    debugMsg(sProcName, "calling buildGetSMSCurrInfoCommandStrings()")
    buildGetSMSCurrInfoCommandStrings()
  EndIf
  
  WCN_setLiveOnInds()
  
  If grCED\bChangeDevMap
    WEP_setCboDevMapForChange()
  EndIf
  
  SetDropCallback(@WED_DropCallback())
  
  gbSkipValidation = #False
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure valAudErrMsg(pAudPtr, pField.s, pMsg.s, Index=0, nFileNo=0)
  PROCNAMEC()

  debugMsg(sProcName, aAud(pAudPtr)\sAudLabel + ", pAudPtr=" + pAudPtr + ", pField=" + pField + ", pMsg=" + pMsg)
  
  If aAud(pAudPtr)\bAudTypeA
    With WQA
      scsMessageRequester(grText\sTextValErr, grText\sTextFile + nFileNo + ": " + pMsg, #PB_MessageRequester_Error)
      WQA_setCurrentItem(WQA_getItemForAud(pAudPtr))
      Select pField
        Case "FN": SetActiveGadget(\txtFileName)
        Case "ST": SetActiveGadget(\txtStartAt)
        Case "EN": SetActiveGadget(\txtEndAt)
        Case "DI": SetActiveGadget(\txtDisplayTime)
        Case "LO": SetActiveGadget(\chkLogo)
        Case "OV": SetActiveGadget(\chkOverlay)
          ; Case "FI": SetActiveGadget(\txtFadeInTime)
        Case "DB": SetActiveGadget(\txtSubDBLevel)
        Case "CD": SetActiveGadget(\txtPlayLength)
        Case "TR": SetActiveGadget(\cboQATransType)
      EndSelect
    EndWith
    
  ElseIf aAud(pAudPtr)\bAudTypeF
    With WQF
      scsMessageRequester(grText\sTextValErr, aAud(pAudPtr)\sAudLabel + ": " + pMsg, #PB_MessageRequester_Error)
      Select pField
        Case "FN": SetActiveGadget(\txtFileName)
        Case "ST": SetActiveGadget(\txtStartAt)
        Case "EN": SetActiveGadget(\txtEndAt)
        Case "LS"
          If rWQF\nDisplayedLoopInfoIndex <> Index
            rWQF\nDisplayedLoopInfoIndex = Index
            WQF_displayLoopAndCueMarkerInfo()
          EndIf
          SetActiveGadget(\txtLoopStart)
        Case "LE"
          If rWQF\nDisplayedLoopInfoIndex <> Index
            rWQF\nDisplayedLoopInfoIndex = Index
            WQF_displayLoopAndCueMarkerInfo()
          EndIf
          SetActiveGadget(\txtLoopEnd)
        Case "FI": SetActiveGadget(\txtFadeInTime)
        Case "DB": SetActiveGadget(\txtDBLevel[Index])
        Case "XF": SAG(\txtLoopXFadeTime)
        Case "LD": SetActiveGadget(\cboLogicalDevF[Index])
      EndSelect
    EndWith
    
  ElseIf aAud(pAudPtr)\bAudTypeP
    scsMessageRequester(grText\sTextValErr, pMsg, #PB_MessageRequester_Error)
    WQP_setCurrentRow(WQP_getRowForAud(pAudPtr))
    CompilerIf #c_include_mygrid_for_playlists = #False
      With WQPFile()
        Select pField
          Case "FN": SetActiveGadget(\txtFileNameP)
          Case "ST": SetActiveGadget(\txtStartAt)
          Case "EN": SetActiveGadget(\txtEndAt)
        EndSelect
      EndWith
    CompilerEndIf
    
  EndIf
  
EndProcedure

Procedure valErrMsg(pGadgetNo, pMsg.s)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START + ", " + getGadgetName(pGadgetNo) + ", pMsg=" + pMsg) ; Changed 8Sep2022

  scsMessageRequester(grText\sTextValErr, pMsg, #PB_MessageRequester_Error)
  
  If (gnFocusGadgetNo = 0) And (IsGadget(pGadgetNo))
    gnFocusGadgetNo = pGadgetNo
  EndIf
  
EndProcedure

Procedure valErrMsgCbo(pTab.s, pField, pMsg.s)
  PROCNAMEC()
  
  debugMsg(sProcName, "pTab=" + pTab + ", pField=G" + pField + ", pMsg=" + pMsg)
  scsMessageRequester(grText\sTextValErr, pMsg, #PB_MessageRequester_Error)
  If Len(pTab) > 0
    fcEditSubType(pTab)
  EndIf
  If IsGadget(pField)
    SAG(pField)
  EndIf
EndProcedure

Procedure valErrMsgTxt(pField, pMsg.s)
  PROCNAMEC()
  
  debugMsg(sProcName, "pField=G" + pField + ", pMsg=" + pMsg)
  scsMessageRequester(grText\sTextValErr, pMsg, #PB_MessageRequester_Error)
  If IsGadget(pField)
    SAG(pField)
  EndIf
EndProcedure

Procedure valErrMustBeEntered(txtGadget, lblGadget)
  PROCNAMEC()
  Protected sMsg.s
  
  sMsg = LangPars("Errors", "MustBeEntered", GetGadgetText(lblGadget))
  scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
  If (gnFocusGadgetNo = 0) And (IsGadget(txtGadget))
    gnFocusGadgetNo = txtGadget
  EndIf
  
EndProcedure

Procedure valErrMustBeSelected(cboGadget, lblGadget)
  PROCNAMEC()
  Protected sMsg.s
  
  sMsg = LangPars("Errors", "MustBeSelected", GetGadgetText(lblGadget))
  scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
  If (gnFocusGadgetNo = 0) And (IsGadget(cboGadget))
    gnFocusGadgetNo = cboGadget
  EndIf
  
EndProcedure

Procedure valWarnMsg(pGadgetNo, pMsg.s)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START + ", G" + Str(pGadgetNo) + ", pMsg=" + pMsg)
  scsMessageRequester(grText\sTextValErr, pMsg, #PB_MessageRequester_Ok|#MB_ICONWARNING)
  If gnFocusGadgetNo = 0 And IsGadget(pGadgetNo)
    gnFocusGadgetNo = pGadgetNo
  EndIf
  
EndProcedure

Procedure pasteFromClipboard(bRedoCueListTree)
  PROCNAMEC()
  Protected nCuePtr, nSubPtr, nAudPtr
  Protected sCue.s, nNodeKey, bControlThreadSuspended
  Protected i, j, j2, k, d, n, h
  Protected bFirstAudForSub, nFirstGeneratedNodeKey
  Protected sUndoDescr.s
  Protected u2, u3, u4, u5
  Protected nCueId, nSubId, nAudId
  Protected sPasteCue.s
  Protected bUseNewCue
  Protected bSetDefaultActivationMethod
  Protected sHotkey.s, sHotkeyLabel.s
  Protected bCallLoadHotkeyPanel
  Protected sMidiCue.s
  Protected bSetDefaultMidiCue
  Protected bResetDescrIfReqd
  Protected nOldAudPtr, nAudNo, nNewAudPtr  ; added 10Nov2015 11.4.1.2h (to fix midi file copy-and-paste problem reported by Richard Borsey)
  Protected Dim nAddedSub(0)
  
  debugMsg(sProcName, #SCS_START + ", nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", bRedoCueListTree=" + strB(bRedoCueListTree))
  
  ; gbAdding = #True ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If gbAdding = #False
    gbAdding = #True
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)")
    THR_suspendAThreadAndWait(#SCS_THREAD_CONTROL)
    bControlThreadSuspended = #True
  EndIf
  ; End added 13Dec2021 11.8.6cw
  
  nCuePtr = nEditCuePtr
  nSubPtr = -1
  
  debugMsg(sProcName, "gnClipCueCount=" + gnClipCueCount)
  If gnClipCueCount > 0
    nCuePtr = nEditCuePtr + 1
    debugMsg(sProcName, "nCuePtr=" + nCuePtr)
    If nCuePtr <= 0
      nCuePtr = 1
    EndIf
    debugMsg(sProcName, "calling addCue(" + nCuePtr + ")")
    If addCue(nCuePtr) = #False
      ProcedureReturn
    EndIf
    
    sUndoDescr = "Paste Cue " + aCue(nCuePtr)\sCue
    u2 = preChangeCueL(#True, sUndoDescr, -1, #SCS_UNDO_ACTION_ADD_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(nCuePtr)\nCueId)
    debugMsg(sProcName, "u2=" + u2)
    
    sCue = aCue(nCuePtr)\sCue           ; hold generated cue label
    nCueId = aCue(nCuePtr)\nCueId       ; hold generated cue id
    nNodeKey = aCue(nCuePtr)\nNodeKey   ; hold generated node key
    If nFirstGeneratedNodeKey = 0
      nFirstGeneratedNodeKey = nNodeKey
    EndIf
    
    ; check if the cue label of the copied cue is still in use (which it probably will not be if the cue was 'cut')
    ; and set an indicator so a new cue label will be used ONLY if the copied cue label is used elsewhere
    ; (this test added to address an issue reported by Eric Snodgrass under "Moving Cues in Editor Window bugs 11.2.4")
    sPasteCue = gaClipCue(0)\sCue
    For i = 1 To gnLastCue
      If aCue(i)\sCue = sPasteCue
        bUseNewCue = #True
        Break
      EndIf
    Next i
    
    sMidiCue = Trim(gaClipCue(0)\sMidiCue)
    If sMidiCue
      For i = 1 To gnLastCue
        If aCue(i)\sMidiCue = sMidiCue
          bSetDefaultMidiCue = #True
          Break
        EndIf
      Next i
    EndIf
    
    With gaClipCue(0)
      If \nActivationMethod & #SCS_ACMETH_HK_BIT
        sHotkey = \sHotkey
        sHotkeyLabel = \sHotkeyLabel
        For i = 1 To gnLastCue
          If aCue(i)\nActivationMethod & #SCS_ACMETH_HK_BIT
            If (aCue(i)\sHotkey = sHotkey) Or (aCue(i)\sHotkeyLabel = sHotkeyLabel)
              bSetDefaultActivationMethod = #True
              Break
            EndIf
          EndIf
        Next i
      EndIf
    EndWith
    
    CheckSubInRange(nCuePtr, ArraySize(aCue()), "aCue()")
    CheckSubInRange(0, ArraySize(gaClipCue()), "gaClipCue()")
    aCue(nCuePtr) = gaClipCue(0)
    With aCue(nCuePtr)
      If bUseNewCue
        \sCue = sCue            ; reinstate generated cue label
      EndIf
      \nCueId = nCueId        ; reinstate generated cue id
      \nNodeKey = nNodeKey    ; reinstate generated node key
      debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nNodeKey=" + Str(aCue(nCuePtr)\nNodeKey))
      If bSetDefaultActivationMethod
        \nActivationMethod = grCueDef\nActivationMethod
        \sHotkey = grCueDef\sHotkey
        \sHotkeyLabel = grCueDef\sHotkeyLabel
      EndIf
      \nActivationMethodReqd = \nActivationMethod
      If \nActivationMethod & #SCS_ACMETH_HK_BIT
        bCallLoadHotkeyPanel = #True
      EndIf
      \nFirstSubIndex = grCueDef\nFirstSubIndex
      \nFirstCueLink = grCueDef\nFirstCueLink
      \nLinkedToCuePtr = grCueDef\nLinkedToCuePtr
      \nPreEditPtr = grCueDef\nPreEditPtr
      If bSetDefaultMidiCue
        \sMidiCue = grCueDef\sMidiCue
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, "gnClipSubCount=" + Str(gnClipSubCount))
  If gnClipSubCount > 0
    ReDim nAddedSub(gnClipSubCount - 1)
    For j = 0 To (gnClipSubCount - 1)
      debugMsg(sProcName, "j=" + j)
      nSubPtr = gnLastSub + 1
      debugMsg(sProcName, "calling addSub(" + nCuePtr + ", " + nSubPtr + ")")
      If addSub(nCuePtr, nSubPtr) = #False
        ProcedureReturn
      EndIf
      nAddedSub(j) = nSubPtr
      u3 = preChangeSubL(#True, "Add SubCue", -1, #SCS_UNDO_ACTION_ADD_SUB, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aSub(nSubPtr)\nSubId)
      nSubId = aSub(nSubPtr)\nSubId       ; hold generated sub id
      nNodeKey = aSub(nSubPtr)\nNodeKey   ; hold generated node key
      If nFirstGeneratedNodeKey = 0
        nFirstGeneratedNodeKey = nNodeKey
      EndIf
      gnLastSub = nSubPtr
      ; debugMsg(sProcName, "c")
      aSub(nSubPtr) = gaClipSub(j)
      ; debugMsg(sProcName, "d")
      With aSub(nSubPtr)
        \nCueIndex = nCuePtr
        \sCue = aCue(nCuePtr)\sCue
        \nSubId = nSubId        ; reinstate generated sub id
        \nNodeKey = nNodeKey    ; reinstate generated node key
        \sPlayOrder = ""
        gnUniqueRef + 1
        \nSubRef = gnUniqueRef
        debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nSubRef=" + \nSubRef)
        ; 23/09/2014 11.3.4 added following email from Martin Stevens (21/09/2014)
        \nFirstAudIndex = grSubDef\nFirstAudIndex
        \nAudCount = grSubDef\nAudCount
        ; 23/09/2014 11.3.4 end of added code
        
        If j = 0
          ; first sub being added
          If (gnClipCueCount = 0) And (gnSelectedNodeSubPtr >= 0)
            ; adding a subcue to an existing cue
            \nPrevSubIndex = gnSelectedNodeSubPtr
            \nNextSubIndex = aSub(gnSelectedNodeSubPtr)\nNextSubIndex
            aSub(gnSelectedNodeSubPtr)\nNextSubIndex = nSubPtr
            ; added 15/07/2014 - bug reported by Richard Borsey
            If \nNextSubIndex >= 0
              aSub(\nNextSubIndex)\nPrevSubIndex = nSubPtr
            EndIf
            ; end added 15/07/2014
          Else
            ; paste sub-cue at end of sub-cues for this cue
            j2 = aCue(nCuePtr)\nFirstSubIndex
            \nPrevSubIndex = j2
            While j2 >= 0
              \nPrevSubIndex = j2
              j2 = aSub(j2)\nNextSubIndex
            Wend
            ; \nPrevSubIndex now points to last sub, or -1 if no subs
            If \nPrevSubIndex = -1
              aCue(nCuePtr)\nFirstSubIndex = nSubPtr
            Else
              aSub(\nPrevSubIndex)\nNextSubIndex = nSubPtr
            EndIf
            \nNextSubIndex = -1
          EndIf
        Else
          \nPrevSubIndex = nSubPtr - 1
          aSub(\nPrevSubIndex)\nNextSubIndex = nSubPtr
          \nNextSubIndex = -1
        EndIf
        debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nNodeKey=" + aSub(nSubPtr)\nNodeKey +
                            ", nSubPtr=" + nSubPtr + ", j=" + j + ", \nSubNo=" + \nSubNo +
                            ", \nPrevSubIndex=" + \nPrevSubIndex + ", \nNextSubIndex=" + \nNextSubIndex)
        
        ; ; set parent pointers etc
        ; setChildInfoForCue(nCuePtr)
        
        ; renumberSubNos(nCuePtr, #True)    ; must do this each time so subno is set for aud's
        ; 15/07/2014: changed bSkipAuds to #False
        renumberSubNos(nCuePtr, #False)    ; must do this each time so subno is set for aud's
        
        If gnClipCuePtr >= 0
          bResetDescrIfReqd = #False
          If \bSubTypeS
            For h = 0 To #SCS_MAX_SFR
              If \nSFRCuePtr[h] = gnClipCuePtr
                \nSFRCuePtr[h] = nCuePtr
                \sSFRCue[h] = \sCue
                bResetDescrIfReqd = #True
              EndIf
            Next h
          ElseIf \bSubTypeL
            If \nLCCuePtr = gnClipCuePtr
              \nLCCuePtr = nCuePtr
              \sLCCue = \sCue
              \nLCSubPtr = getSubPtrForCueSubNo(nCuePtr, \nLCSubNo)
              \nLCSubRef = aSub(\nLCSubPtr)\nLCSubRef
              ; debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nLCSubRef=" + \nLCSubRef)
              \nLCAudPtr = aSub(\nLCSubPtr)\nFirstAudIndex
              bResetDescrIfReqd = #True
            EndIf
          EndIf
          If \bDefaultSubDescrMayBeSet
            setDefaultSubDescr(nSubPtr)
            If \nPrevSubIndex = -1
              If aCue(nCuePtr)\bDefaultCueDescrMayBeSet
                setDefaultCueDescr(nCuePtr)
              EndIf
            EndIf
          EndIf
        EndIf
          
        If \bSubTypeHasAuds
          bFirstAudForSub = #True
          For k = 0 To (gnClipAudCount - 1)
            If (gaClipAud(k)\sCue = gaClipSub(j)\sCue) And (gaClipAud(k)\nSubNo = gaClipSub(j)\nSubNo)
              nAudPtr = gnLastAud + 1
              If addAud(nCuePtr, nSubPtr, nAudPtr) = #False
                ProcedureReturn
              EndIf
              u5 = preChangeAudL(#True, "Add SubCue", -1, #SCS_UNDO_ACTION_ADD_AUD, -1, 0, aAud(nAudPtr)\nAudId)
              nAudId = aAud(nAudPtr)\nAudId   ; hold generated aud id
              aAud(nAudPtr) = gaClipAud(k)
              aAud(nAudPtr)\nCueIndex = nCuePtr
              aAud(nAudPtr)\sCue = aCue(nCuePtr)\sCue
              aAud(nAudPtr)\nSubIndex = nSubPtr
              aAud(nAudPtr)\nSubNo = aSub(nSubPtr)\nSubNo
              debugMsg(sProcName, "aAud(" + nAudPtr + ")\nSubIndex=" + aAud(nAudPtr)\nSubIndex + ", aAud(" + nAudPtr + ")\nSubNo=" + aAud(nAudPtr)\nSubNo)
              aAud(nAudPtr)\nAudId = nAudId   ; reinstate generated aud id
              For d = 0 To grLicInfo\nMaxAudDevPerAud
                aAud(nAudPtr)\nBassChannel[d] = grAudDef\nBassChannel[d]
                aAud(nAudPtr)\nBassAltChannel[d] = grAudDef\nBassAltChannel[d]
              Next d
              aAud(nAudPtr)\nSourceChannel = grAudDef\nSourceChannel
              aAud(nAudPtr)\nSourceAltChannel = grAudDef\nSourceAltChannel
              aAud(nAudPtr)\bUsingSplitStream = grAudDef\bUsingSplitStream
              CompilerIf #c_vMix_in_video_cues
                aAud(nAudPtr)\svMixInputKey = grAudDef\svMixInputKey
                aAud(nAudPtr)\nvMixInputNr = grAudDef\nvMixInputNr
              CompilerEndIf
              If bFirstAudForSub
                aSub(nSubPtr)\nFirstAudIndex = nAudPtr
                aAud(nAudPtr)\nPrevAudIndex = -1
                aAud(nAudPtr)\nNextAudIndex = -1
                debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nNextAudIndex=" + getAudLabel(aAud(nAudPtr)\nNextAudIndex))
                bFirstAudForSub = #False
              Else
                aAud(nAudPtr)\nPrevAudIndex = nAudPtr - 1
                aAud(aAud(nAudPtr)\nPrevAudIndex)\nNextAudIndex = nAudPtr
                aAud(nAudPtr)\nNextAudIndex = -1
                debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nNextAudIndex=" + getAudLabel(aAud(nAudPtr)\nNextAudIndex))
              EndIf
              setMissingCueMarkerIds(nAudPtr)
              debugMsg(sProcName, aAud(nAudPtr)\sAudLabel + ", " + aAud(nAudPtr)\sDBLevel[0] + ", " + aAud(nAudPtr)\fBVLevel[0] +
                                  ", \nAudState=" + decodeCueState(aAud(nAudPtr)\nAudState) + ", \nFileState=" + decodeFileState(aAud(nAudPtr)\nFileState) +
                                  ", \nBassChannel[0]=" + decodeHandle(aAud(nAudPtr)\nBassChannel[0]))
              postChangeAudL(u5, #False)
            EndIf
          Next k
          
          ; added 10Nov2015 11.4.1.2h (to fix midi file copy-and-paste problem reported by Richard Borsey)
          If gaClipSub(j)\bSubTypeM
            For n = 0 To #SCS_MAX_CTRL_SEND
              nOldAudPtr = gaClipSub(j)\aCtrlSend[n]\nAudPtr
              If nOldAudPtr >= 0
                nAudNo = aAud(nOldAudPtr)\nAudNo
                nNewAudPtr = getAudPtrForAudNo(nSubPtr, nAudNo)
                debugMsg(sProcName, "j=" + getSubLabel(j) + ", nOldAudPtr=" + nOldAudPtr + ", nAudNo=" + nAudNo + ", nNewAudPtr=" + nNewAudPtr)
                aSub(nSubPtr)\aCtrlSend[n]\nAudPtr = nNewAudPtr
              EndIf
            Next n
          EndIf
          ; end added 10Nov2015 11.4.1.2h
          
        EndIf
        
        ; 12Jan2018 11.7.0rc4: moved the following outside the 'sub' loop as setCuePtrs() must be called first
        ; If \bSubTypeHasAuds
        ;   debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nSubPtr) + ")")
        ;   generatePlayOrder(nSubPtr)
        ; EndIf
        
      EndWith ; EndWith aSub(nSubPtr)
      postChangeSubL(u3, #False, nSubPtr)
    Next j
    
    setCuePtrs(#False)
    
    ; 12Jan2018 11.7.0rc4: the following moved from inside the 'sub' loop, so it is after the call to setCuePtrs()
    If gnClipSubCount > 0
      For j = 0 To (gnClipSubCount - 1)
        nSubPtr = nAddedSub(j)
        If aSub(nSubPtr)\bSubTypeHasAuds
          debugMsg(sProcName, "calling generatePlayOrder(" + getSubLabel(nSubPtr) + ")")
          generatePlayOrder(nSubPtr)
        EndIf
      Next j
    EndIf
    ; end of 12Jan2018 11.7.0rc4 mod
    
    debugMsg(sProcName, "calling setTimeBasedCues()")
    setTimeBasedCues()
    
    debugMsg(sProcName, "Setting nEditCuePtr (" + getCueLabel(nEditCuePtr) + ") to " + getCueLabel(nCuePtr))
    nEditCuePtr = nCuePtr
    If nSubPtr = -1
      nEditSubPtr = aCue(nEditCuePtr)\nFirstSubIndex
    Else
      nEditSubPtr = nSubPtr
    EndIf
    
    setCueState(nEditCuePtr)
    setLabels(nEditCuePtr)
    debugMsg(sProcName, "calling setDefaultSubDescr()")
    setDefaultSubDescr()
    debugMsg(sProcName, "calling setDefaultCueDescr()")
    setDefaultCueDescr()
    aCue(nEditCuePtr)\sValidatedCue = aCue(nEditCuePtr)\sCue
    aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
    
    If bRedoCueListTree
      gbPasting = #True
      redoCueListTree(nFirstGeneratedNodeKey)
      gbPasting = #False
    EndIf
    
    WED_setEditorButtons()
    
    If bCallLoadHotkeyPanel
      debugMsg(sProcName, "calling WMN_loadHotkeyPanel()")
      WMN_loadHotkeyPanel()
    EndIf
    
    gbCallPopulateGrid = #True
    debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
    gbCallLoadDispPanels = #True
    gnCallOpenNextCues = 1
    
    postChangeCueL(u2, #False, nCuePtr, -1, "Add Cue " + aCue(nCuePtr)\sCue)
    
  EndIf
  
  If sanityCheck()
;     debugMsg(sProcName, "calling debugCuePtrs")
;     debugCuePtrs()
  EndIf
  
  ; gbAdding = #False ; Replaced by the following 13Dec2021 11.8.6cw
  ; Added 13Dec2021 11.8.6cw
  If bControlThreadSuspended
    debugMsg(sProcName, "calling THR_resumeAThread(#SCS_THREAD_CONTROL)")
    THR_resumeAThread(#SCS_THREAD_CONTROL)
    gbAdding = #False
    debugMsg(sProcName, "gbAdding=" + strB(gbAdding))
  EndIf
  ; End added 13Dec2021 11.8.6cw
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure askHowManyVideoCues(nVideoImageFiles, sTitle.s)
  PROCNAMEC()
  Protected nMousePointer, nReply, nVideoImageCues
  Protected bModalDisplayed
  Protected sPrompt.s, sButtons.s
  
  nMousePointer = GetMouseCursor()
  SetMouseCursorNormal()
  bModalDisplayed = gbModalDisplayed
  gbModalDisplayed = #True
  sPrompt = LangPars("CED", "VidFileRequest", Str(nVideoImageFiles))
  sButtons = LangPars("CED", "MultVidCues", Str(nVideoImageFiles))
  sButtons + "|" + Lang("CED", "1VidCue")
  sButtons + "|" + Lang("Btns", "Cancel")
  debugMsg(sProcName, sTitle + ": " + sPrompt)
  nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 150, #IDI_QUESTION, #WED)
  gbModalDisplayed = bModalDisplayed
  SetMouseCursor(nMousePointer)
  Select nReply
    Case 1 ; multiple video/image cues
      nVideoImageCues = nVideoImageFiles
    Case 2 ; single video/image cue
      nVideoImageCues = 1
    Case 3, 0 ; 3 = cancel, 0 = user pressed ESC
      nVideoImageCues = -1
  EndSelect
  ProcedureReturn nVideoImageCues
  
EndProcedure

Procedure pasteCuesFromOLE(sFileList.s)
  PROCNAMEC()
  Protected n
  Protected nFirstCueNodeKey
  Protected nReply
  Protected sPrompt.s, sTitle.s
  Protected sFileName.s
  Protected nFileCount
  Protected nMousePointer
  Protected bModalDisplayed
  Protected nAudioFiles, nVideoImageFiles
  Protected sAudioFiles.s, sVideoImageFiles.s
  Protected bAudioFileCues, bPlaylistCue, nVideoImageCues
  Protected nFileFormat
  Protected sButtons.s
  Protected bLockedMutex
  Protected nSelectedItem, nNodeKey
  Protected bCancel
  Protected nCuePtr

  debugMsg(sProcName, #SCS_START)
  
  nFirstCueNodeKey = -1
  
  If WED_validateDisplayedItem() = #False
    ProcedureReturn -1
  EndIf
  
  nFileCount = CountString(sFileList, Chr(10)) + 1
  
  ; check the data
  For n = 1 To nFileCount
    sFileName = StringField(sFileList, n, Chr(10))
    nFileFormat = getFileFormat(sFileName)
    Select nFileFormat
      Case #SCS_FILEFORMAT_AUDIO
        If nAudioFiles > 0
          sAudioFiles + Chr(10)
        EndIf
        sAudioFiles + sFileName
        nAudioFiles + 1
        
      Case #SCS_FILEFORMAT_PICTURE, #SCS_FILEFORMAT_VIDEO
        If nVideoImageFiles > 0
          sVideoImageFiles + Chr(10)
        EndIf
        sVideoImageFiles + sFileName
        nVideoImageFiles + 1
        
      Default
        scsMessageRequester(Lang("CED","ValErr"), LangPars("Errors", "FileFormatNotSupported", GetFilePart(sFileName)), #PB_MessageRequester_Error)
        ProcedureReturn -1
        
    EndSelect
  Next n
  
  If (nAudioFiles = 0) And (nVideoImageFiles = 0)
    bCancel = #True
  EndIf
  
  If bCancel = #False
    If nAudioFiles > 0
      If nAudioFiles = 1
        bAudioFileCues = #True
      Else  ; nAudioFiles > 1
        nMousePointer = GetMouseCursor()
        SetMouseCursorNormal()
        bModalDisplayed = gbModalDisplayed
        gbModalDisplayed = #True
        sPrompt = LangPars("CED", "AudFileRequest", Str(nAudioFiles))
        sTitle = Lang("CED","Drag&DropFiles")
        sButtons = LangPars("CED", "AudFileCues", Str(nAudioFiles))
        sButtons + "|" + Lang("CED", "PlaylistCue")
        sButtons + "|" + Lang("Btns", "Cancel")
        debugMsg(sProcName, sTitle + ": " + sPrompt)
        nReply = OptionRequester(0, 0, sTitle + "|" + sPrompt, sButtons, 150, #IDI_QUESTION, #WED)
        gbModalDisplayed = bModalDisplayed
        SetMouseCursor(nMousePointer)
        Select nReply
          Case 1 ; audio file cues
            bAudioFileCues = #True
          Case 2 ; playlist cue
            bPlaylistCue = #True
          Case 3, 0 ; 3 = cancel, 0 = user pressed ESC
            bCancel = #True
        EndSelect
      EndIf
    EndIf
  EndIf
  
  If bCancel = #False
    If nVideoImageFiles > 0
      If nVideoImageFiles = 1
        nVideoImageCues = 1
      Else  ; nVideoImageFiles > 1
        sTitle = Lang("CED","Drag&DropFiles")
        nVideoImageCues = askHowManyVideoCues(nVideoImageFiles, sTitle)
        If nVideoImageCues < 0
          bCancel = #True
        EndIf
      EndIf
    EndIf
  EndIf
  
  If bCancel
    debugMsg(sProcName, "cancel")
    If grCED\nSelectedItemForDragAndDrop >= 0
      nNodeKey = GetGadgetItemData(WED\tvwProdTree, grCED\nSelectedItemForDragAndDrop)
      debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", " + GetGadgetItemText(WED\tvwProdTree, grCED\nSelectedItemForDragAndDrop))
      WED_publicNodeClick(nNodeKey, #False, #False)
      grCED\nSelectedItemForDragAndDrop = -1
    EndIf
    ProcedureReturn -1
  EndIf
  
  If gnTraceMutexLocking > 0
    debugMsg3(sProcName, "calling LockMutex(gnCueListMutex), gnCueListMutexLockThread=" + Str(gnCueListMutexLockThread) + ", gnThreadNo=" + gnThreadNo +
                         ", gqCueListMutexLockTime=" + traceTime(gqCueListMutexLockTime) + ", gnCueListMutexLockNo=" + Str(gnCueListMutexLockNo))
  EndIf
  LockCueListMutex(835)
  
  debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  nSelectedItem = GetGadgetState(WED\tvwProdTree)
  debugMsg(sProcName, "nSelectedItem=" + nSelectedItem)
  If nSelectedItem >= 0
    nNodeKey = GetGadgetItemData(WED\tvwProdTree, nSelectedItem)
    debugMsg(sProcName, "nNodeKey=" + nNodeKey + ", " + GetGadgetItemText(WED\tvwProdTree, nSelectedItem))
    WED_publicNodeClick(nNodeKey, #True, #False)
  EndIf
  debugMsg(sProcName, "nEditCuePtr=" + getCueLabel(nEditCuePtr) + ", nEditSubPtr=" + getSubLabel(nEditSubPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
  
  If bAudioFileCues
    nFirstCueNodeKey = WED_importAudioFiles(#SCS_IMPORT_AUDIO_CUES, Lang("WED", "FavAddQF"), #True, sAudioFiles)
  EndIf
  
  If bPlaylistCue
    nCuePtr = addCueWithSubCue("P", #True, #True, "", #True, #True, sAudioFiles)
  EndIf
  
  If nVideoImageCues > 0
    If nVideoImageCues = 1
      nCuePtr = addCueWithSubCue("A", #True, #True, "", #True, #True, sVideoImageFiles)
    Else
      For n = 1 To nVideoImageCues
        sFileName = StringField(sVideoImageFiles, n, Chr(10))
        nCuePtr = addCueWithSubCue("A", #True, #True, "", #True, #True, sFileName)
        debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nCueState=" + decodeCueState(aCue(nCuePtr)\nCueState))
        If aCue(nCuePtr)\nCueState = #SCS_CUE_READY
          ; close the cue to free any TVG control - important if many video files are added in this paste
          debugMsg(sProcName, "calling closeCue(" + getCueLabel(nCuePtr) + ")")
          closeCue(nCuePtr)
        EndIf
        If nFirstCueNodeKey = -1
          nFirstCueNodeKey = aCue(nCuePtr)\nNodeKey
        EndIf
      Next n
    EndIf
  EndIf
  
  UnlockCueListMutex()
  
  If nFirstCueNodeKey = -1
    If nEditCuePtr >= 0
      nFirstCueNodeKey = aCue(nEditCuePtr)\nNodeKey
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nFirstCueNodeKey=" + nFirstCueNodeKey)
  ProcedureReturn nFirstCueNodeKey

EndProcedure

Procedure promoteSubDescrIfReqd(sOldSubDescr.s, sSubField.s)
  PROCNAMEC()
  Protected u
  
  With aSub(nEditSubPtr)
    ; debugMsg(sProcName, "sOldSubDescr=" + sOldSubDescr + ", aCue(\nCueIndex)\sCueDescr=" + aCue(\nCueIndex)\sCueDescr)
    If \nCueIndex = nEditCuePtr
      If \nPrevSubIndex = -1
        If Trim(sOldSubDescr) = Trim(aCue(\nCueIndex)\sCueDescr) Or Trim(aCue(\nCueIndex)\sCueDescr) = ""
          If \sSubDescr
            u = preChangeCueS(aCue(\nCueIndex)\sCueDescr, sSubField, \nCueIndex, #SCS_UNDO_ACTION_CHANGE, #SCS_UNDO_FLAG_SET_CUE_NODE_TEXT | #SCS_UNDO_FLAG_REDO_TREE)
            aCue(\nCueIndex)\sCueDescr = \sSubDescr
            SGT(WEC\txtDescr, aCue(\nCueIndex)\sCueDescr)
            WED_setCueNodeText(\nCueIndex)
            postChangeCueS(u, aCue(\nCueIndex)\sCueDescr, \nCueIndex)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure propogateProdDevs(pSubType.s)
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START + ", pSubType=" + pSubType + ", gbInUndoOrRedo=" + strB(gbInUndoOrRedo))
  
  ; gbInUndoOrRedo tests added 8Sep2023 11.10.0ca following tests that showed device comboboxes not being refreshed after 'undo' or 'redo'
  
  If (pSubType = "A") And (gbDoProdDevsForA Or gbInUndoOrRedo)
    WQA_populateCboVidAudLogicalDevs()
    WQA_populateCboVidCapLogicalDevs()
    gbDoProdDevsForA = #False
  EndIf

  If (pSubType = "F") And (gbDoProdDevsForF Or gbInUndoOrRedo)
    WQF_populateCboLogicalDevs()
    gbDoProdDevsForF = #False
  EndIf
  
  If (pSubType = "I") And (gbDoProdDevsForI Or gbInUndoOrRedo)
    WQI_populateCboInputLogicalDevs()
    WQI_populateCboLogicalDevs()
    gbDoProdDevsForI = #False
  EndIf
  
  If (pSubType = "K") And (gbDoProdDevsForK Or gbInUndoOrRedo)
    WQK_populateCboLogicalDev()
    gbDoProdDevsForK = #False
  EndIf

  If (pSubType = "P") And (gbDoProdDevsForP Or gbInUndoOrRedo)
    WQP_populateCboPLLogicalDevs()
    gbDoProdDevsForP = #False
  EndIf

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure redoCueListTree(nNodeKey)
  PROCNAMEC()
  Protected nTopIndex.l
  Protected nLongResult.l
  Protected nMinPos.l, nMaxPos.l

  debugMsg(sProcName, #SCS_START)
  
  nTopIndex = GetScrollPos_(GadgetID(WED\tvwProdTree), #SB_VERT)
  debugMsg(sProcName, "GetScrollPos_(GadgetID(WED\tvwProdTree), #SB_VERT) returned " + nTopIndex)
  
  debugMsg(sProcName, "calling populateProdTree()")
  populateProdTree()
  debugMsg(sProcName, "calling WED_displayTemplateInfoIfReqd(#True)")
  WED_displayTemplateInfoIfReqd(#True)

  If nNodeKey > 0
    debugMsg(sProcName, "calling WED_publicNodeClick(" + nNodeKey + ")")
    WED_publicNodeClick(nNodeKey)
  EndIf
  
  nLongResult = GetScrollRange_(GadgetID(WED\tvwProdTree), #SB_VERT, @nMinPos, @nMaxPos)
  debugMsg(sProcName, "nMinPos=" + nMinPos + ", nMaxPos=" + nMaxPos + ", nLongResult=" + nLongResult)
  If nTopIndex > nMaxPos
    nTopIndex = nMaxPos
  EndIf
  nLongResult = SetScrollPos_(GadgetID(WED\tvwProdTree), #SB_VERT, nTopIndex, 1)
  debugMsg(sProcName, "SetScrollPos_(GadgetID(WED\tvwProdTree), #SB_VERT, " + nTopIndex + ", 1) returned " + nLongResult)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure renumberSubNos(pCuePtr, bSkipAuds=#False)
  PROCNAMECQ(pCuePtr)
  Protected i, j, j2, nSubNo, k, h
  Protected nOldLCSubNo, nNewLCSubNo
  Protected nOldSFRSubNo, nNewSFRSubNo
  Protected nOldAutoSubNo, nNewAutoSubNo
  Protected nOldVSTSubNo, nNewVSTSubNo
  Protected sCue.s, bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", bSkipAuds=" + strB(bSkipAuds))
  
  If pCuePtr >= 0
    debugMsgC(sProcName, "aCue(" + getCueLabel(pCuePtr) + ")\nFirstSubIndex=" + aCue(pCuePtr)\nFirstSubIndex)
    j = aCue(pCuePtr)\nFirstSubIndex
    nSubNo = 0
    While j >= 0
      nSubNo + 1
      aSub(j)\nSubNo = nSubNo
      If bSkipAuds = #False
        debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nFirstAudIndex=" + aSub(j)\nFirstAudIndex)
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          aAud(k)\nSubNo = nSubNo
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nNextSubIndex=" + aSub(j)\nNextSubIndex)
      j = aSub(j)\nNextSubIndex
    Wend
    
    ; reset nVSTPluginSameAsSubNo values where required
    For j = 1 To gnLastSub
      With aSub(j)
        If \bExists
          If \bSubTypeF
            debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nFirstAudIndex=" + \nFirstAudIndex)
            k = \nFirstAudIndex
            If k >= 0
              If aAud(k)\nVSTPluginSameAsSubRef <> -1
                For j2 = 1 To gnLastSub
                  If aSub(j2)\bExists
                    If (aSub(j2)\sCue = aAud(k)\sVSTPluginSameAsCue) And (aSub(j2)\nSubRef = aAud(k)\nVSTPluginSameAsSubRef)
                      nOldVSTSubNo =  aAud(k)\nVSTPluginSameAsSubNo
                      nNewVSTSubNo = aSub(j2)\nSubNo
                      If nNewVSTSubNo <> nOldVSTSubNo
                        debugMsgC(sProcName, "changing aAud(" + getAudLabel(k) + ")\nVSTPluginSameAsSubNo from " + nOldVSTSubNo + " to " + nNewVSTSubNo)
                        aAud(k)\nVSTPluginSameAsSubNo = nNewVSTSubNo
                      EndIf
                      Break
                    EndIf
                  EndIf
                Next j2
              EndIf
            EndIf ;EndIf k >= 0
          EndIf ; EndIf \bSubTypeF
        EndIf ; EndIf \bExists
      EndWith
    Next j
    
    ; reset nLCSubNo and nSetPosSubNo values where required
    For j = 1 To gnLastSub
      With aSub(j)
        If \bExists
          If \bSubTypeL
            If \nLCSubRef <> -1
              For j2 = 1 To gnLastSub
                If aSub(j2)\bExists ; And aSub(j2)\bSubTypeF
                  If (aSub(j2)\sCue = \sLCCue) And (aSub(j2)\nSubRef = \nLCSubRef)
                    nOldLCSubNo = \nLCSubNo
                    nNewLCSubNo = aSub(j2)\nSubNo
                    If nNewLCSubNo <> nOldLCSubNo
                      debugMsgC(sProcName, "changing aSub(" + getSubLabel(j) + ")\nLCSubNo from " + \nLCSubNo + " to " + nNewLCSubNo)
                      \nLCSubNo = nNewLCSubNo
                    EndIf
                    Break
                  EndIf
                EndIf
              Next j2
            EndIf
          EndIf
        EndIf
      EndWith
    Next j
    
    ; reset nSFRSubNo values where required
    For j = 1 To gnLastSub
      With aSub(j)
        If (\bExists) And (\bSubTypeS)
          For h = 0 To #SCS_MAX_SFR
            If \nSFRSubRef[h] <> -1
              For j2 = 1 To gnLastSub
                If aSub(j2)\bExists
                  If (aSub(j2)\sCue = \sSFRCue[h]) And (aSub(j2)\nSubRef = \nSFRSubRef[h])
                    nOldSFRSubNo = \nSFRSubNo[h]
                    nNewSFRSubNo = aSub(j2)\nSubNo
                    If nNewSFRSubNo <> nOldSFRSubNo
                      debugMsgC(sProcName, "changing aSub(" + getSubLabel(j) + ")\nSFRSubNo[" + h + "] from " + \nSFRSubNo[h] + " to " + nNewSFRSubNo)
                      \nSFRSubNo[h] = nNewSFRSubNo
                    EndIf
                    Break
                  EndIf
                EndIf
              Next j2
            EndIf
          Next h
        EndIf
      EndWith
    Next j
    
    ; reset nLCSubNo and nSetPosSubNo values where required
    For j = 1 To gnLastSub
      With aSub(j)
        If \bExists
          If \bSubTypeF
            If \nLCSubRef <> -1
              For j2 = 1 To gnLastSub
                If aSub(j2)\bExists ; And aSub(j2)\bSubTypeF
                  If (aSub(j2)\sCue = \sLCCue) And (aSub(j2)\nSubRef = \nLCSubRef)
                    nOldLCSubNo = \nLCSubNo
                    nNewLCSubNo = aSub(j2)\nSubNo
                    If nNewLCSubNo <> nOldLCSubNo
                      debugMsgC(sProcName, "changing aSub(" + getSubLabel(j) + ")\nLCSubNo from " + \nLCSubNo + " to " + nNewLCSubNo)
                      \nLCSubNo = nNewLCSubNo
                    EndIf
                    Break
                  EndIf
                EndIf
              Next j2
            EndIf
          EndIf
        EndIf
      EndWith
    Next j
    
    ; reset nAutoActSubNo's and nAutoActAudNo's where required (used by activation method 'on cue marker')
    debugMsgC(sProcName, "calling setAutoActCueMarkerSubAndAudNos()")
    setAutoActCueMarkerSubAndAudNos()
    debugMsgC(sProcName, "calling loadCueMarkerArrays()")
    loadCueMarkerArrays()
    
  EndIf
  
  debugMsgC(sProcName, #SCS_END)

EndProcedure

Procedure resetPlayList(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k
  Protected nOrigAudState
  Protected nVidPicTarget
  Protected nFirstFile, n ; Added 7Oct2022 11.9.6
  
  debugMsg(sProcName, #SCS_START + ", nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState))

  With aSub(pSubPtr)
    debugMsg(sProcName, "\bStartedInEditor=" + strB(\bStartedInEditor))
    If (\bStartedInEditor) And (gbPreviewOnOutputScreen = #False)
      nVidPicTarget = #SCS_VID_PIC_TARGET_P
    Else
      If \nOutputScreen >= 2
        nVidPicTarget = getVidPicTargetForOutputScreen(\nOutputScreen)
      Else
        nVidPicTarget = #SCS_VID_PIC_TARGET_NONE
      EndIf
    EndIf
  EndWith
  
  k = aSub(pSubPtr)\nFirstPlayIndex
  While k >= 0
    With aAud(k)
      nOrigAudState = \nAudState
      If \nAudState = #SCS_CUE_NOT_LOADED
        debugMsg(sProcName, "calling openMediaFile(" + getAudLabel(k) + ")")
        openMediaFile(k)
      EndIf
      If \nAudState <> #SCS_CUE_ERROR And \nAudState <> #SCS_CUE_NOT_LOADED
        setPlaylistTrackReadyState(k)
      EndIf
      debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", nOrigAudState=" + decodeCueState(nOrigAudState))
      \nCuePos = 0
      \nCuePosWhenLastChecked = 0
      k = \nNextPlayIndex
    EndWith
  Wend
  aSub(pSubPtr)\nCurrPlayIndex = aSub(pSubPtr)\nFirstPlayIndex
  debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nCurrPlayIndex=" + getAudLabel(aSub(pSubPtr)\nCurrPlayIndex))
  setCueState(aSub(pSubPtr)\nCueIndex)

  debugMsg(sProcName, "calling calcPLTotalTime(" + getSubLabel(pSubPtr) + ")")
  calcPLTotalTime(pSubPtr)
  debugMsg(sProcName, "calling calcPLUnplayedFilesTime(" + getSubLabel(pSubPtr) + ")")
  calcPLUnplayedFilesTime(pSubPtr)
  debugMsg(sProcName, "calling calcPLPosition(" + getSubLabel(pSubPtr) + ")")
  calcPLPosition(pSubPtr)
  ; gbCallEditUpdateDisplay = #True

  ; Added 7Oct2022 11.9.6 following bug reported by James Lownie 6Oct2022
  nFirstFile = -1
  For n = 0 To gnWQALastItem
    If WQAFile(n)\nFileAudPtr > 0
      nFirstFile = n
      Break
    EndIf
  Next n
  debugMsg(sProcName, "gnWQALastItem=" + gnWQALastItem + ", nFirstFile=" + nFirstFile)
  rWQA\nStartFileNo = nFirstFile + 1
  ; End added 7Oct2022 11.9.6 following bug reported by James Lownie 6Oct2022

  debugMsg(sProcName, #SCS_END + ", pSubPtr=" + pSubPtr + ", nSubState=" + decodeCueState(aSub(pSubPtr)\nSubState) + ", rWQA\nStartFileNo=" + rWQA\nStartFileNo)

EndProcedure

Procedure resyncCuePtrs(pCuePtr = -1)
  PROCNAMECQ(pCuePtr)
  Protected i, j, k, n
  Protected nStartLoopCuePtr, nEndLoopCuePtr
  Protected sThisCue.s, nThisSubNo

  If pCuePtr >= 0
    nStartLoopCuePtr = pCuePtr
    nEndLoopCuePtr = pCuePtr
  Else
    nStartLoopCuePtr = 1
    nEndLoopCuePtr = gnLastCue
  EndIf

  debugMsg(sProcName, "nStartLoopCuePtr=" + nStartLoopCuePtr + ", nEndLoopCuePtr=" + nEndLoopCuePtr)
  
  For i = nStartLoopCuePtr To nEndLoopCuePtr
    sThisCue = aCue(i)\sCue
    ; debugMsg(sProcName, "i=" + i + ", sThisCue=" + sThisCue)
    If (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO) Or (aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF)
      If aCue(i)\nAutoActCueSelType = #SCS_ACCUESEL_DEFAULT
        aCue(i)\nAutoActCuePtr = getCuePtr(aCue(i)\sAutoActCue)
      ElseIf aCue(i)\nAutoActCueSelType = #SCS_ACCUESEL_PREV
        setCuePtrForAutoStartPrevCueType(i)
      EndIf
    EndIf
    
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        nThisSubNo = \nSubNo
        ; debugMsg(sProcName, "j=" + j + ", sThisCue=" + sThisCue + ", nThisSubNo=" + nThisSubNo + ", \nSubRef=" + \nSubRef)
        \nCueIndex = i
        \sCue = sThisCue
        
        If \bSubTypeL
          If \nLCSubRef >= 0
            \nLCSubPtr = getSubPtrForSubRef(\nLCSubRef)
            ; debugMsg(sProcName, "\nLCSubRef=" + \nLCSubRef + ", \nLCSubPtr=" + \nLCSubPtr)
            If \nLCSubPtr >= 0
              \nLCCuePtr = aSub(\nLCSubPtr)\nCueIndex
              \sLCCue = aSub(\nLCSubPtr)\sCue
              \nLCSubNo = aSub(\nLCSubPtr)\nSubNo
            EndIf
          EndIf
        EndIf
        
        If \bSubTypeHasAuds
          k = \nFirstAudIndex
          While k >= 0
            ; debugMsg(sProcName, "k=" + k + ", sThisCue=" + sThisCue)
            aAud(k)\nCueIndex = i
            aAud(k)\sCue = sThisCue
            aAud(k)\nSubIndex = j
            aAud(k)\nSubNo = nThisSubNo
            ; debugMsg(sProcName, "aAud(" + k + ")\nCueIndex=" + aAud(k)\nCueIndex + ", \nSubIndex=" + aAud(k)\nSubIndex)
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
        
        If \bSubTypeS
          For n = 0 To #SCS_MAX_SFR
            If Len(\sSFRCue[n]) > 0
              \nSFRCuePtr[n] = getCuePtr(\sSFRCue[n])
            EndIf
          Next n
        EndIf
        
        ; Added 31Jan2024 11.10.2ad
        If \bSubTypeQ
          \nCallCuePtr = getCuePtr(\sCallCue)
        EndIf
        ; End added 31Jan2024 11.10.2ad
        
        j = \nNextSubIndex
      EndWith
    Wend
    
  Next i
  
  debugMsg(sProcName, "calling loadCueMarkerArrays()")
  loadCueMarkerArrays()
  
  ; reset grWMN\bMemoScreen1InUse
  setMemoScreen1InUseInd()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setEditCueSubAudPtrs(pCuePtr)
  PROCNAMECQ(pCuePtr)
  
  debugMsg(sProcName, #SCS_START)
  
  If pCuePtr > gnLastCue
    nEditCuePtr = gnLastCue
  Else
    nEditCuePtr = pCuePtr
  EndIf
  If nEditCuePtr <= 0
    nEditCuePtr = -1
    nEditSubPtr = -1
    setEditAudPtr(-1)
  Else
    nEditSubPtr = aCue(nEditCuePtr)\nFirstSubIndex
    setEditAudPtr(-1)
    If nEditSubPtr >= 0
      With aSub(nEditSubPtr)
        If \bSubTypeHasAuds
          setEditAudPtr(\nFirstAudIndex)
        EndIf
      EndWith
    EndIf
  EndIf
  debugMsg(sProcName, "nEditCuePtr=" + nEditCuePtr + ", gnLastCue=" + gnLastCue + ", gnCueEnd=" + gnCueEnd + ", nEditSubPtr=" + nEditSubPtr)
  If nEditCuePtr >= 0
    debugMsg(sProcName, "aCue(" + nEditCuePtr + ")\sCue=" + aCue(nEditCuePtr)\sCue + ", \nNodeKey=" + aCue(nEditCuePtr)\nNodeKey)
  EndIf
EndProcedure

Procedure buildEditCBO(hCBO, sCBOType.s)
  PROCNAMEC()
  
  Select sCBOType
    Case "FadeIn", "LevelChange"
      ClearGadgetItems(hCBO)
      addGadgetItemWithData(hCBO, Lang("FadeType", "std"), #SCS_FADE_STD)
      addGadgetItemWithData(hCBO, Lang("FadeType", "lin"), #SCS_FADE_LIN)
      addGadgetItemWithData(hCBO, Lang("FadeType", "log"), #SCS_FADE_LOG)
      
    Case "FadeOut"
      ClearGadgetItems(hCBO)
      addGadgetItemWithData(hCBO, Lang("FadeType", "std"), #SCS_FADE_STD)
      addGadgetItemWithData(hCBO, Lang("FadeType", "lin"), #SCS_FADE_LIN)
      addGadgetItemWithData(hCBO, Lang("FadeType", "log"), #SCS_FADE_LOG)
      addGadgetItemWithData(hCBO, Lang("FadeType", "linse"), #SCS_FADE_LIN_SE)
      addGadgetItemWithData(hCBO, Lang("FadeType", "logse"), #SCS_FADE_LOG_SE)
      
    Case "HideCueOpt"
      ClearGadgetItems(hCBO)
      addGadgetItemWithData(hCBO, Lang("HideCueOpt", "NO"), #SCS_HIDE_NO)
      addGadgetItemWithData(hCBO, Lang("HideCueOpt", "EC"), #SCS_HIDE_ENTIRE_CUE)
      addGadgetItemWithData(hCBO, Lang("HideCueOpt", "CP"), #SCS_HIDE_CUE_PANEL)
      
  EndSelect
  
EndProcedure

Procedure.s getLabelAndValue(nLabelGadget, nValueGadget)
  ProcedureReturn Trim(GGT(nLabelGadget)) + " (" + Trim(GGT(nValueGadget)) + ")"
EndProcedure

Procedure.s generateNextCueLabel(pCue.s, nIncrement, fIncrement.f=0.0, pCuePrefix.s="", bInCueRenumbering=#False)
  ; PROCNAMEC()
  Protected sCue.s, sPrefix.s, bDoingPrefix
  Protected n, sChar.s, sNumber.s, nNumber, fNumber.f, nOldLeadingZeros, sNewNumber.s, nNewLeadingZeros, nLeadingZerosDiff
  Protected bAlphaCue
  Protected bCuePrefixPresent
  Protected nCuePrefixLength

  ; debugMsg(sProcName, #SCS_START + ", pCue=" + pCue + ", nIncrement=" + nIncrement + ", fIncrement=" + StrF(fIncrement,1) + ", pCuePrefix=" + pCuePrefix + ", bInCueRenumbering=" + strB(bInCueRenumbering))
  
  sCue = Trim(pCue)
  If Len(pCuePrefix) > 0
    bCuePrefixPresent = #True
  EndIf
  
  If Len(sCue) = 0
    If bCuePrefixPresent
      sPrefix = pCuePrefix
    Else
      sPrefix = "Q"
    EndIf
    If nIncrement > 0
      sCue = sPrefix + Str(nIncrement)
      nNumber = nIncrement
    ElseIf fIncrement > 0.0
      sCue = sPrefix + StrF(fIncrement,1)
      fNumber = fIncrement
    EndIf
    bAlphaCue = #False
  Else
    sPrefix = ""
    sNumber = ""
    bDoingPrefix = #True
    bAlphaCue = #True
    If bInCueRenumbering
      sChar = Right(sCue, 1)
      If (sChar >= "0" And sChar <= "9") Or (sChar = gsDecimalMarker)
        bAlphaCue = #False
        For n = Len(sCue) To 1 Step -1
          sChar = Mid(sCue, n, 1)
          If (sChar < "0" Or sChar > "9") Or (sChar = gsDecimalMarker)
            nCuePrefixLength = n
            sPrefix = Left(sCue, nCuePrefixLength)
            sNumber = Mid(sCue, nCuePrefixLength+1)
            ; debugMsg(sProcName, "sCue=" + sCue + ", n=" + n + ", sChar=" + sChar + ", sPrefix=" + sPrefix + ", sNumber=" + sNumber)
            Break
          EndIf
        Next n
      EndIf
    EndIf
    If nCuePrefixLength = 0
      For n = 1 To Len(sCue)
        sChar = Mid(sCue, n, 1)
        If (sChar >= "0" And sChar <= "9") Or (sChar = gsDecimalMarker)
          bDoingPrefix = #False
          bAlphaCue = #False
          If bCuePrefixPresent
            If sPrefix = pCuePrefix
              sNumber + sChar
            EndIf
          Else
            sNumber + sChar
          EndIf
        ElseIf bDoingPrefix
          sPrefix + sChar
        Else
          Break
        EndIf
      Next n
      nOldLeadingZeros = 0
      For n = 1 To Len(sNumber)
        If Mid(sNumber, n, 1) = "0"
          nOldLeadingZeros + 1
        Else
          Break
        EndIf
      Next n
      ; debugMsg(sProcName, "sPrefix=" + sPrefix + ", sNumber=" + sNumber + ", nOldLeadingZeros=" + nOldLeadingZeros)
    EndIf
    If bAlphaCue
      sChar = Right(sCue, 1)
      If sChar = "Z"
        sChar = "AA"
      ElseIf sChar = "z"
        sChar = "aa"
      Else
        sChar = Chr(Asc(sChar) + 1)
      EndIf
      If Len(sCue) = 1
        sCue = sChar
      Else
        sCue = Left(sCue, Len(sCue) - 1) + sChar
      EndIf
    Else
      If pCuePrefix
        ; override 
        sPrefix = pCuePrefix
      EndIf
      If nIncrement > 0
        nNumber = Val(sNumber) + nIncrement
        sCue = sPrefix + Str(nNumber)
      ElseIf fIncrement > 0.0
        fNumber = ValF(sNumber) + fIncrement
        sNewNumber = StrF(fNumber,1)
        nNewLeadingZeros = 0
        For n = 1 To Len(sNewNumber)
          If Mid(sNewNumber, n, 1) = "0"
            nNewLeadingZeros + 1
          Else
            Break
          EndIf
        Next n
        nLeadingZerosDiff = nNewLeadingZeros - nOldLeadingZeros
        If nLeadingZerosDiff > 0
          sNewNumber = Mid(sNewNumber, (nLeadingZerosDiff+1))
        EndIf
        ; debugMsg(sProcName, "sNewNumber=" + sNewNumber + ", fIncrement=" + StrF(fIncrement,1) + ", fNumber=" + StrF(fNumber,1))
        sCue = sPrefix + sNewNumber
      EndIf
      sPrefix = ""
      nNumber = -1
    EndIf
  EndIf
  ; debugMsg(sProcName, #SCS_End + ", returning sCue=" + sCue)
  ProcedureReturn sCue
EndProcedure

Procedure validateChanges()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bProdCreated ; no need to validate prod properties if fmEditProd has not been created because that means the user hasn't made any changes to production properties
    If WEP_valProdProperties(#False) = #False
      ProcedureReturn #False
    EndIf
  EndIf

  If nEditCuePtr >= 0
    If valCue(#False) = #False
      ProcedureReturn #False
    EndIf
  EndIf

  ProcedureReturn #True

EndProcedure

Procedure populateLCAudioDevs(*rSub.tySub, bPopulateDevsOnly=#False)
  PROCNAMEC()
  Protected d
  Protected rTargetSub.tySub, rTargetAud.tyAud

  With *rSub
    
    debugMsg(sProcName, #SCS_START + ", *rSub\sSubLabel=" + \sSubLabel)
    
    For d = 0 To grLicInfo\nMaxAudDevPerSub
      \sLCLogicalDev[d] = ""
      If bPopulateDevsOnly = #False
        \sLCDBTrim[d] = ""
        \fLCTrimFactor[d] = 1.0
      EndIf
    Next d
    
    debugMsg(sProcName, "\nLCSubPtr=" + getSubLabel(\nLCSubPtr) + ", \nLCAudPtr=" + getAudLabel(\nLCAudPtr) + ", \bLCTargetIsA=" + strB(\bLCTargetIsA) +
                        ", \bLCTargetIsF=" + strB(\bLCTargetIsF) + ", \bLCTargetIsI=" + strB(\bLCTargetIsI) + ", \bLCTargetIsP=" + strB(\bLCTargetIsP))
    
    If (\bLCTargetIsF Or \bLCTargetIsI) And (\nLCAudPtr >= 0)
      rTargetAud = aAud(\nLCAudPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerSub
        \sLCLogicalDev[d] = rTargetAud\sLogicalDev[d]
        If bPopulateDevsOnly = #False
          \sLCDBTrim[d] = rTargetAud\sDBTrim[d]
          \fLCTrimFactor[d] = rTargetAud\fTrimFactor[d]
        EndIf
      Next d
      
    ElseIf (\bLCTargetIsA) And (\nLCSubPtr >= 0)
      rTargetSub = aSub(\nLCSubPtr)
      d = 0
      \sLCLogicalDev[d] = rTargetSub\sVidAudLogicalDev
      If bPopulateDevsOnly = #False
        \sLCDBTrim[d] = rTargetSub\sPLDBTrim[d]
        \fLCTrimFactor[d] = rTargetSub\fSubTrimFactor[d]
      EndIf
      
    ElseIf (\bLCTargetIsP) And (\nLCSubPtr >= 0)
      rTargetSub = aSub(\nLCSubPtr)
      For d = 0 To grLicInfo\nMaxAudDevPerSub
        \sLCLogicalDev[d] = rTargetSub\sPLLogicalDev[d]
        If bPopulateDevsOnly = #False
          \sLCDBTrim[d] = rTargetSub\sPLDBTrim[d]
          \fLCTrimFactor[d] = rTargetSub\fSubTrimFactor[d]
        EndIf
      Next d
      
    EndIf
    
    \nLCMaxLogicalDev = -1
    For d = 0 To grLicInfo\nMaxAudDevPerSub
      If \sLCLogicalDev[d]
        \nLCMaxLogicalDev = d
      EndIf
    Next d
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure newCue()
  PROCNAMEC()
  Protected nCuePtr, sUndoDescr.s
  Protected u2
  
  If nEditCuePtr >= 1
    If valCue(#False) = #False
      ProcedureReturn -1
    EndIf
  EndIf
  
  nCuePtr = nEditCuePtr + 1
  If nCuePtr <= 0
    nCuePtr = 1
  EndIf
  
  If addCue(nCuePtr)
    sUndoDescr = "Add Cue " + aCue(nCuePtr)\sCue
    u2 = preChangeCueL(#True, sUndoDescr, -1, #SCS_UNDO_ACTION_ADD_CUE, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aCue(nCuePtr)\nCueId)
    nEditCuePtr = nCuePtr
  Else
    u2 = -1
  EndIf
  
  ProcedureReturn u2
EndProcedure

Procedure newSub(pCuePtr, pSubNo, pSubType.s)
  PROCNAMEC()
  ; note: pSubNo is the nSubNo of the sub to be added
  Protected nSubPtr, i, j, k
  Protected nPrevSubIndex, nNextSubIndex
  Protected nAudPtr, nSubNo
  Protected sSFRCueType.s, sSFRCue.s, sSFRAction.s
  Protected bSFRCueFound
  Protected u3
  
  debugMsg(sProcName, "pCuePtr=" + pCuePtr + ", pSubNo=" + Str(pSubNo) + ", pSubType=" + pSubType)
  
  nSubPtr = gnLastSub + 1
  If addSub(pCuePtr, nSubPtr) = #False
    ; if we get here then we cannot add the sub-cue
    ProcedureReturn -1
  EndIf
  u3 = preChangeSubL(#True, "Add Sub-Cue", -1, #SCS_UNDO_ACTION_ADD_SUB, -1, #SCS_UNDO_FLAG_REDO_TREE | #SCS_UNDO_FLAG_SET_CUE_PTRS, aSub(nSubPtr)\nSubId)
  
  gnLastSub = nSubPtr
  
  With aSub(nSubPtr)
    \sCue = aCue(pCuePtr)\sCue
    \sSubType = pSubType
  EndWith
  setDerivedSubFields(nSubPtr, #True)
  
  If aCue(pCuePtr)\nFirstSubIndex = -1
    aCue(pCuePtr)\nFirstSubIndex = nSubPtr
  Else
    nPrevSubIndex = -1
    nNextSubIndex = -1
    j = aCue(pCuePtr)\nFirstSubIndex
    While j >= 0
      If aSub(j)\nSubNo >= pSubNo
        Break
      EndIf
      nPrevSubIndex = j
      j = aSub(j)\nNextSubIndex
    Wend
    If nPrevSubIndex >= 0
      nNextSubIndex = aSub(nPrevSubIndex)\nNextSubIndex
      aSub(nPrevSubIndex)\nNextSubIndex = nSubPtr
    EndIf
    aSub(nSubPtr)\nPrevSubIndex = nPrevSubIndex
    aSub(nSubPtr)\nNextSubIndex = nNextSubIndex
  EndIf
  
  renumberSubNos(pCuePtr)
  
  nEditSubPtr = nSubPtr
  ; debugMsg(sProcName, "nEditSubPtr=" + nEditSubPtr)
  
  Select pSubType
    Case "L"
      ; aSub(nSubPtr)\nLCAbsRel = gnPrevLCAbsRel
      aSub(nSubPtr)\nLCAction = gnPrevLCAction
    Case "E", "N"
      aSub(nSubPtr)\nSubState = #SCS_CUE_READY
  EndSelect
  
  ProcedureReturn u3
EndProcedure

Procedure applyDevChanges()
  PROCNAMEC()
  Protected i, j, k, d, d1, bFound
  Protected n, m
  Protected nChaseStepIndex, nSendItemIndex, sDMXItemStr.s, sFixtureCodes.s, sNewFixtureCodes.s, sNewDMXItemStr.s
  Protected Dim sFixtureCode.s(0), Dim sNewFixtureCode.s(0), Dim sSeparator.s(0)
  Protected nCharPtr, sChar.s, sOneFixtureCode.s
  Protected nMaxFixtureCode, nFixtureArrayIndex, bFixtureChanged
  Protected u
  Protected sLogicalDev.s, sOrigLogicalDev.s
  Protected bCloseCue
  Protected bStopEverything
  
  debugMsg(sProcName, #SCS_START)
  
  ; NOTE: applyDevChanges() is called AFTER the required fields have been copied from grProdForDevChgs to grProd
  
  With grProd
    
    ; change name if used for preview device (nb 'preview device' is set and used only by the SCS File Opener (fmFileOpener))
    sLogicalDev = \sPreviewDevice
    bFound = #False
    If sLogicalDev
      For d = 0 To \nMaxAudioLogicalDev
        If \aAudioLogicalDevs(d)\sLogicalDev = sLogicalDev
          bFound = #True
          Break
        EndIf
      Next d
      If bFound = #False
        For d = 0 To \nMaxAudioLogicalDev
          If \aAudioLogicalDevs(d)\sOrigLogicalDev = sLogicalDev
            \sPreviewDevice = \aAudioLogicalDevs(d)\sLogicalDev
            Break
          EndIf
        Next d
      EndIf
    EndIf
    
    For d = 0 To \nMaxLiveInputLogicalDev
      sLogicalDev = \aLiveInputLogicalDevs(d)\sLogicalDev
      sOrigLogicalDev = \aLiveInputLogicalDevs(d)\sOrigLogicalDev
      If sLogicalDev <> sOrigLogicalDev
        For n = 0 To \nMaxInGrp
          If \aInGrps(n)\sInGrpName
            For d1 = 0 To \aInGrps(n)\nMaxInGrpItem
              If \aInGrps(n)\aInGrpItem(d1)\sInGrpItemLiveInput = sOrigLogicalDev
                \aInGrps(n)\aInGrpItem(d1)\sInGrpItemLiveInput = sLogicalDev
              EndIf
            Next d1
          EndIf
        Next n
      EndIf
    Next d
    
  EndWith
  
  setDefaults_PropogateProdDevs()
  
  For i = 1 To gnLastCue
    bCloseCue = #False
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubTypeA   ; \bSubTypeA
          ;{
          ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sVidAudLogicalDev=" + \sVidAudLogicalDev)
          sLogicalDev = \sVidAudLogicalDev
          bFound = #False
          If sLogicalDev
            For n = 0 To grProd\nMaxVidAudLogicalDev
              If grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev = sLogicalDev
                bFound = #True
                If grProd\aVidAudLogicalDevs(n)\bDevChanged
                  bCloseCue = #True
                EndIf
                Break
              EndIf
            Next n
            If bFound = #False
              For n = 0 To grProd\nMaxVidAudLogicalDev
                If grProd\aVidAudLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                  If grProd\aVidAudLogicalDevs(n)\bDevChanged
                    bCloseCue = #True
                  EndIf
                  u = preChangeSubS(\sVidAudLogicalDev, "\sVidAudLogicalDev", j)
                  \sVidAudLogicalDev = grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev
                  postChangeSubS(u, \sVidAudLogicalDev, j)
                  Break
                EndIf
              Next n
            EndIf
          EndIf
          ; now check for any video capture device name changes required
          k = \nFirstAudIndex
          While k >= 0
            If aAud(k)\nVideoSource = #SCS_VID_SRC_CAPTURE
              sLogicalDev = aAud(k)\sVideoCaptureLogicalDevice
              bFound = #False
              If sLogicalDev
                For n = 0 To grProd\nMaxVidCapLogicalDev
                  If grProd\aVidCapLogicalDevs(n)\sLogicalDev = sLogicalDev
                    bFound = #True
                    If grProd\aVidCapLogicalDevs(n)\bDevChanged
                      bCloseCue = #True
                    EndIf
                    Break
                  EndIf
                Next n
                If bFound = #False
                  For n = 0 To grProd\nMaxVidCapLogicalDev
                    If grProd\aVidCapLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                      If grProd\aVidCapLogicalDevs(n)\bDevChanged
                        bCloseCue = #True
                      EndIf
                      u = preChangeAudS(aAud(k)\sVideoCaptureLogicalDevice, "\sVideoCaptureLogicalDevice", k)
                      aAud(k)\sVideoCaptureLogicalDevice = grProd\aVidCapLogicalDevs(n)\sLogicalDev
                      postChangeAudS(u, aAud(k)\sVideoCaptureLogicalDevice, k)
                      Break
                    EndIf
                  Next n
                EndIf
              EndIf
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
          ;}
        ElseIf \bSubTypeP   ; \bSubTypeP
          ;{
          For d1 = 0 To grLicInfo\nMaxAudDevPerSub
            sLogicalDev = \sPLLogicalDev[d1]
            bFound = #False
            If sLogicalDev
              For n = 0 To grProd\nMaxAudioLogicalDev
                If grProd\aAudioLogicalDevs(n)\sLogicalDev = sLogicalDev
                  bFound = #True
                  If grProd\aAudioLogicalDevs(n)\bDevChanged
                    bCloseCue = #True
                  EndIf
                  Break
                EndIf
              Next n
              If bFound = #False
                For n = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
                  If grProd\aAudioLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                    If grProd\aAudioLogicalDevs(n)\bDevChanged
                      bCloseCue = #True
                    EndIf
                    u = preChangeSubS(\sPLLogicalDev[d1], "\sPLLogicalDev", j)
                    \sPLLogicalDev[d1] = grProd\aAudioLogicalDevs(n)\sLogicalDev
                    postChangeSubS(u, \sPLLogicalDev[d1], j)
                    Break
                  EndIf
                Next n
              EndIf
            EndIf
          Next d1
          ;}
        ElseIf \bSubTypeK   ; \bSubTypeK
          ;{
          sLogicalDev = \sLTLogicalDev
          bFound = #False
          If sLogicalDev
            For n = 0 To grProd\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
              ; debugMsg0(sProcName, "sLogicalDev=" + sLogicalDev + ", grProd\aLightingLogicalDevs(" + n + ")\sOrigLogicalDev=" + grProd\aLightingLogicalDevs(n)\sOrigLogicalDev + ", grProd\aLightingLogicalDevs(" + n + ")\sLogicalDev=" + grProd\aLightingLogicalDevs(n)\sLogicalDev)
              If grProd\aLightingLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                If grProd\aLightingLogicalDevs(n)\sLogicalDev <> sLogicalDev
                  If grProd\aLightingLogicalDevs(n)\bDevChanged
                    bCloseCue = #True
                  EndIf
                  u = preChangeSubS(\sLTLogicalDev, "\sLTLogicalDev", j)
                  \sLTLogicalDev = grProd\aLightingLogicalDevs(n)\sLogicalDev
                  postChangeSubS(u, \sLTLogicalDev, j)
                EndIf
              EndIf
            Next n
            For nChaseStepIndex = 0 To \nMaxChaseStepIndex
              For nSendItemIndex = 0 To \aChaseStep(nChaseStepIndex)\nDMXSendItemCount - 1
                sDMXItemStr = Trim(\aChaseStep(nChaseStepIndex)\aDMXSendItem(nSendItemIndex)\sDMXItemStr)
                If FindString(sDMXItemStr, ":") > 1
                  sFixtureCodes = Trim(StringField(sDMXItemStr, 1, ":")) + ":"
                  ; unpack fixture codes
                  nMaxFixtureCode = -1
                  bFixtureChanged = #False
                  sOneFixtureCode = ""
                  For nCharPtr = 1 To Len(sFixtureCodes)
                    sChar = Mid(sFixtureCodes, nCharPtr, 1)
                    Select sChar
                      Case ",", "-", ":"
                        If sOneFixtureCode
                          nMaxFixtureCode + 1
                          If nMaxFixtureCode > ArraySize(sFixtureCode())
                            ReDim sFixtureCode(nMaxFixtureCode+5)
                            ReDim sNewFixtureCode(nMaxFixtureCode+5)
                            ReDim sSeparator(nMaxFixtureCode+5)
                          EndIf
                          sFixtureCode(nMaxFixtureCode) = sOneFixtureCode
                          sNewFixtureCode(nMaxFixtureCode) = sOneFixtureCode
                          sSeparator(nMaxFixtureCode) = sChar
                          sOneFixtureCode = ""
                        EndIf
                      Default
                        sOneFixtureCode + sChar
                    EndSelect
                  Next nCharPtr
                  For nFixtureArrayIndex = 0 To nMaxFixtureCode
                    sOneFixtureCode = sFixtureCode(nFixtureArrayIndex)
                    For n = 0 To grProd\nMaxLightingLogicalDev ; grLicInfo\nMaxLightingDevPerProd
                      For m = 0 To grProd\aLightingLogicalDevs(n)\nMaxFixture
                        If grProd\aLightingLogicalDevs(n)\aFixture(m)\sOrigFixtureCode = sOneFixtureCode
                          If grProd\aLightingLogicalDevs(n)\aFixture(m)\sFixtureCode <> sOneFixtureCode
                            sNewFixtureCode(nFixtureArrayIndex) = grProd\aLightingLogicalDevs(n)\aFixture(m)\sFixtureCode
                            bFixtureChanged = #True
                            Goto endFixtureArrayLoop  ; instead of 'Break 3'
                          EndIf
                        EndIf
                      Next m
                    Next n
                  Next nFixtureArrayIndex
                  endFixtureArrayLoop:
                  If bFixtureChanged
                    u = preChangeSubS(sDMXItemStr, "\sDMXItemStr", j, #SCS_UNDO_ACTION_CHANGE, nSendItemIndex)
                    ; rebuild fixture codes and DMX item string, with new fixture codes
                    sNewFixtureCodes = ""
                    For nFixtureArrayIndex = 0 To nMaxFixtureCode
                      sNewFixtureCodes + sNewFixtureCode(nFixtureArrayIndex) + sSeparator(nFixtureArrayIndex)
                    Next nFixtureArrayIndex
                    sNewDMXItemStr = sNewFixtureCodes + StringField(sDMXItemStr, 2, ":")
                    \aChaseStep(nChaseStepIndex)\aDMXSendItem(nSendItemIndex)\sDMXItemStr = sNewDMXItemStr
                    \aChaseStep(nChaseStepIndex)\aDMXSendItem(nSendItemIndex)\sDMXChannels = StringField(sNewDMXItemStr, 1, "@")
                    postChangeSubS(u, sNewDMXItemStr, j, nSendItemIndex)
                  EndIf ; EndIf bFixtureChanged
                EndIf ; EndIf FindString(sDMXItemStr, ":") > 1
              Next nSendItemIndex
            Next nChaseStepIndex
          EndIf ; EndIf sLogicalDev
          ;}
        ElseIf \bSubTypeM   ; \bSubTypeM
          ;{
          For m = 0 To #SCS_MAX_CTRL_SEND
            sLogicalDev = \aCtrlSend[m]\sCSLogicalDev
            bFound = #False
            If sLogicalDev
              For n = 0 To grProd\nMaxCtrlSendLogicalDev
                If grProd\aCtrlSendLogicalDevs(n)\sLogicalDev = sLogicalDev
                  bFound = #True
                  If grProd\aCtrlSendLogicalDevs(n)\bDevChanged
                    bCloseCue = #True
                  EndIf
                  Break
                EndIf
              Next n
              If bFound = #False
                For n = 0 To grProd\nMaxCtrlSendLogicalDev
                  If grProd\aCtrlSendLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                    If grProd\aCtrlSendLogicalDevs(n)\bDevChanged
                      bCloseCue = #True
                    EndIf
                    u = preChangeSubS(\aCtrlSend[m]\sCSLogicalDev, "\sCSLogicalDev", j)
                    \aCtrlSend[m]\sCSLogicalDev = grProd\aCtrlSendLogicalDevs(n)\sLogicalDev
                    postChangeSubS(u, \aCtrlSend[m]\sCSLogicalDev, j)
                    Break
                  EndIf
                Next n
              EndIf
            EndIf
          Next m
          ;}
        EndIf
        
        If \bSubTypeHasAuds   ; \bSubTypeHasAuds
          k = \nFirstAudIndex
          While k >= 0
            Select aAud(k)\nFileFormat
              Case #SCS_FILEFORMAT_MIDI   ; #SCS_FILEFORMAT_MIDI (aud belongs to subtype M)
                d1 = 0
                sLogicalDev = aAud(k)\sLogicalDev[d1]
                bFound = #False
                If sLogicalDev
                  For n = 0 To grProd\nMaxCtrlSendLogicalDev
                    If grProd\aCtrlSendLogicalDevs(n)\sLogicalDev = sLogicalDev
                      bFound = #True
                      If grProd\aCtrlSendLogicalDevs(n)\bDevChanged
                        bCloseCue = #True
                      EndIf
                      Break
                    EndIf
                  Next n
                  If bFound = #False
                    For n = 0 To grProd\nMaxCtrlSendLogicalDev
                      If grProd\aCtrlSendLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                        If grProd\aCtrlSendLogicalDevs(n)\bDevChanged
                          bCloseCue = #True
                        EndIf
                        u = preChangeAudS(aAud(k)\sLogicalDev[d1], "\sAudioLogicalDev", k)
                        aAud(k)\sLogicalDev[d1] = grProd\aCtrlSendLogicalDevs(n)\sLogicalDev
                        postChangeAudS(u, aAud(k)\sLogicalDev[d1], k)
                        Break
                      EndIf
                    Next n
                  EndIf
                EndIf
                
              Case #SCS_FILEFORMAT_AUDIO, #SCS_FILEFORMAT_LIVE_INPUT  ; #SCS_FILEFORMAT_AUDIO, #SCS_FILEFORMAT_LIVE_INPUT
                For d1 = 0 To grLicInfo\nMaxAudDevPerAud
                  sLogicalDev = aAud(k)\sLogicalDev[d1]
                  bFound = #False
                  If sLogicalDev
                    For n = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
                      If grProd\aAudioLogicalDevs(n)\sLogicalDev = sLogicalDev
                        bFound = #True
                        If grProd\aAudioLogicalDevs(n)\bDevChanged
                          bCloseCue = #True
                        EndIf
                        Break
                      EndIf
                    Next n
                    If bFound = #False
                      For n = 0 To grProd\nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
                        If grProd\aAudioLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                          If grProd\aAudioLogicalDevs(n)\bDevChanged
                            bCloseCue = #True
                          EndIf
                          u = preChangeAudS(aAud(k)\sLogicalDev[d1], "\sAudioLogicalDev", k)
                          aAud(k)\sLogicalDev[d1] = grProd\aAudioLogicalDevs(n)\sLogicalDev
                          postChangeAudS(u, aAud(k)\sLogicalDev[d1], k)
                          Break
                        EndIf
                      Next n
                    EndIf
                  EndIf
                Next d1
                
                If aAud(k)\bAudTypeI ; \bAudTypeI
                  For d1 = 0 To grLicInfo\nMaxLiveDevPerAud
                    sLogicalDev = aAud(k)\sInputLogicalDev[d1]
                    bFound = #False
                    If sLogicalDev
                      For n = 0 To grProd\nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
                        If grProd\aLiveInputLogicalDevs(n)\sLogicalDev = sLogicalDev
                          bFound = #True
                          If grProd\aLiveInputLogicalDevs(n)\bDevChanged
                            bCloseCue = #True
                          EndIf
                          Break
                        EndIf
                      Next n
                      If bFound = #False
                        For n = 0 To grProd\nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
                          If grProd\aLiveInputLogicalDevs(n)\sOrigLogicalDev = sLogicalDev
                            If grProd\aLiveInputLogicalDevs(n)\bDevChanged
                              bCloseCue = #True
                            EndIf
                            u = preChangeAudS(aAud(k)\sInputLogicalDev[d1], "\sInputLogicalDev", k)
                            aAud(k)\sInputLogicalDev[d1] = grProd\aLiveInputLogicalDevs(n)\sLogicalDev
                            postChangeAudS(u, aAud(k)\sInputLogicalDev[d1], k)
                            Break
                          EndIf
                        Next n
                      EndIf
                    EndIf
                  Next d1
                EndIf
                
            EndSelect
            setFirstAndLastDev(k)
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
      EndWith
      j = aSub(j)\nNextSubIndex
    Wend
    
    If bCloseCue
      If (aCue(i)\nCueState > #SCS_CUE_NOT_LOADED) And (aCue(i)\nCueState < #SCS_CUE_FADING_IN)
        debugMsg(sProcName, "calling closeCue(" + getCueLabel(i) + ")")
        closeCue(i)
      EndIf
      bStopEverything = #True
    EndIf
  Next i
  
  If DMX_IsDMXOutDevPresent()
    ; force grFixturesRunTime to be reloaded when (if) a lighting cue is prepared
    ; this is because fixture info including start channels could have been changed in this device editing session
    grFixturesRunTime\bLoaded = #False
    debugMsg(sProcName, "grFixturesRunTime\bLoaded=" + strB(grFixturesRunTime\bLoaded))
    DMX_loadDMXControl()
    
    ; Added 24Sep2021 11.8.6ap
    debugMsg(sProcName, "calling syncFixturesInDev(@grProd, @grMaps)")
    syncFixturesInDev(@grProd, @grMaps)
    debugMsg(sProcName, "calling populateAllDevStartChannelArrays()")
    populateAllDevStartChannelArrays()
    ; End added 24Sep2021 11.8.6ap
    
    If grProd\bLightingPre118
      DMX_loadDMXDimmableChannelArray()
    Else
      DMX_loadDMXDimmableChannelArrayFI()
    EndIf
    DMX_loadDMXTextColorsArray()
  EndIf

  If bStopEverything
    processFadeAll()
  EndIf
  
  ; mod 8/1/2013: unconditionally set the following indicators so that any new logical devices will be included in the relevant drop-down lists
  gbDoProdDevsForA = #True
  gbDoProdDevsForF = #True
  gbDoProdDevsForI = #True
  gbDoProdDevsForK = #True
  gbDoProdDevsForP = #True
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure markValidationOK(nGadgetNo)
  ; PROCNAMEC()
  Protected nGadgetPropsIndex
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  gaGadgetProps(nGadgetPropsIndex)\bValidationReqd = #False
;   debugMsg(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo) + ", nGadgetPropsIndex=" + nGadgetPropsIndex +
;                       ", gaGadgetProps(" + nGadgetPropsIndex + ")\bValidationReqd=" + strB(gaGadgetProps(nGadgetPropsIndex)\bValidationReqd))
  
EndProcedure

Procedure redisplayEditorComponent()
  PROCNAMEC()
  
  With grCED
    If \bProdDisplayed
      debugMsg(sProcName, "calling displayProd()")
      displayProd()
    ElseIf \bCueDisplayed
      debugMsg(sProcName, "calling displayCue(" + getCueLabel(nEditCuePtr) + ", " + getSubLabel(nEditSubPtr) + ")")
      displayCue(nEditCuePtr, nEditSubPtr)
    EndIf
  EndWith
EndProcedure

Procedure valForLTC()
  PROCNAMEC()
  Protected i, j, bValidationOK
  Protected sMsg.s
  Protected d
  Protected bForLTCFound
  
  debugMsg(sProcName, #SCS_START)
  
  bValidationOK = #True
  
  If grCED\bProdForLTCChanged
    For d = 0 To grLicInfo\nMaxAudDevPerAud
      With grProd\aAudioLogicalDevs(d)
        If \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          If \bForLTC
            bForLTCFound = #True
            Break
          EndIf
        EndIf
      EndWith
    Next d
    
    If bForLTCFound = #False
      For i = 1 To gnLastCue
        With aCue(i)
          If \bSubTypeU ; MTC Cue
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If (aSub(j)\bSubTypeU) And (aSub(j)\nMTCType = #SCS_MTC_TYPE_LTC)
                sMsg = LangPars("Errors", "NoForLTC", getSubLabel(j))
                bValidationOK = #False
                Break 2
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndWith
      Next i
    EndIf
    
    If bValidationOK
      ; all OK so can now clear this flag which was only set to enforce this validation
      grCED\bProdForLTCChanged = #False
    Else
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
    EndIf
  EndIf

  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure valForMTC()
  PROCNAMEC()
  Protected i, j, bValidationOK
  Protected sMsg.s
  Protected d
  Protected bForMTCFound
  
  debugMsg(sProcName, #SCS_START)
  
  bValidationOK = #True
  
  If grCED\bProdForMTCChanged
    For d = 0 To grProd\nMaxCtrlSendLogicalDev
      With grProd\aCtrlSendLogicalDevs(d)
        If \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
          If \bCtrlMidiForMTC
            bForMTCFound = #True
            Break
          EndIf
        EndIf
      EndWith
    Next d
    
    If bForMTCFound = #False
      For i = 1 To gnLastCue
        With aCue(i)
          If \bSubTypeU   ; MTC Cue
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If (aSub(j)\bSubTypeU) And (aSub(j)\nMTCType = #SCS_MTC_TYPE_MTC)
                sMsg = LangPars("Errors", "NoForMTC", getSubLabel(j))
                bValidationOK = #False
                Break 2
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndWith
      Next i
    EndIf
    
    If bValidationOK
      ; all OK so can now clear this flag which was only set to enforce this validation
      grCED\bProdForMTCChanged = #False
    Else
      debugMsg(sProcName, sMsg)
      scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
    EndIf
  EndIf

  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure valProd()
  PROCNAMEC()
  Protected i, bValidationOK
  Protected sMsg.s, sField.s
  Protected nCurrSubrCuePtr
  Protected n
  Protected nMidiDmxDevCount, nOtherDevCount
  
  debugMsg(sProcName, #SCS_START)
  
  bValidationOK = #True
  
  If grCED\bProdForLTCChanged
    If valForLTC() = #False
      debugMsg(sProcName, "returning #False because valForLTC() returned #False")
      ProcedureReturn #False
    EndIf
  EndIf
  
  If grCED\bProdForMTCChanged
    If valForMTC() = #False
      debugMsg(sProcName, "returning #False because valForMTC() returned #False")
      ProcedureReturn #False
    EndIf
  EndIf
  
  If bValidationOK
    ; now check that all cues that require a MIDI/DMX Cue entered have this field entered
    ; (similar code to that in valCue())
    For n = 0 To grProd\nMaxCueCtrlLogicalDev
      Select grProd\aCueCtrlLogicalDevs(n)\nDevType
        Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CC_DMX_IN
          nMidiDmxDevCount + 1
        Case #SCS_DEVTYPE_CC_NETWORK_IN, #SCS_DEVTYPE_CC_RS232_IN
          nOtherDevCount + 1
      EndSelect
    Next n
    For i = 1 To gnLastCue
      With aCue(i)
        Select \nActivationMethod
          Case #SCS_ACMETH_EXT_TRIGGER, #SCS_ACMETH_EXT_TOGGLE, #SCS_ACMETH_EXT_NOTE, #SCS_ACMETH_EXT_COMPLETE
            If nMidiDmxDevCount = 0 And nOtherDevCount = 0
              sMsg = LangPars("Errors", "NoCCDev", \sCue, decodeActivationMethodL(\nActivationMethod))
              bValidationOK = #False
              Break
            ElseIf nMidiDmxDevCount > 0 And nOtherDevCount = 0
              If Len(Trim(\sMidiCue)) = 0
                sField = Lang("WEC", "lblMidiCue")
                sMsg = LangPars("Errors", "MustBeEnteredForCue", sField, \sCue)
                bValidationOK = #False
                Break
              EndIf
            EndIf
        EndSelect
      EndWith
    Next i
  EndIf
  
  If bValidationOK
    If grCED\bProdDefDMXFadeTimeChanged
      debugMsg(sProcName, "calling propagateProdDefDMXFadeTime()")
      propagateProdDefDMXFadeTime()
    EndIf
  EndIf
  
  If bValidationOK = #False
    debugMsg(sProcName, sMsg)
    scsMessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Error)
  EndIf

  debugMsg(sProcName, #SCS_END + " returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
  
EndProcedure

Procedure fcEditSubType(pSubType.s)
  PROCNAMECS(nEditSubPtr)
  Protected nItemIndex, nScrollPos, k
  
  debugMsg(sProcName, #SCS_START + ", pSubType=" + pSubType)
  
  ; Added 21Apr2020 11.8.2.3ay
  With aSub(nEditSubPtr)
    If pSubType = "A" And \bSubTypeA
      If \nSubState >= #SCS_CUE_FADING_IN And \nSubState <= #SCS_CUE_FADING_OUT
        If \nCurrPlayIndex >= 0
          k = \nFirstPlayIndex
          While k >= 0
            If k = \nCurrPlayIndex
              Break
            Else
              nItemIndex + 1
              k = aAud(k)\nNextPlayIndex
            EndIf
          Wend
        EndIf
      EndIf
    EndIf
  EndWith
  ; End added 21Apr2020 11.8.2.3ay
  
  displaySub(nEditSubPtr, nItemIndex, nScrollPos) ; Modified 21Apr2020 11.8.2.3ay (added nItemIndex, nScrollPos)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure fcEditLabelsFrozen()
  ; PROCNAMEC()
  If grProd\bLabelsFrozen
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuRenumberCues, #False)
  Else
    scsEnableMenuItem(#WED_mnuCuesMenu, #WED_mnuRenumberCues, #True)
  EndIf
EndProcedure

Procedure.f getMaxBVLevelInUse()
  PROCNAMEC()
  Protected fMaxBVLevel.f, fBVLevel.f
  Protected i, j, k, d
  
  With grProd  ; ForDevChgs ; nb use grProdForDevChgs rather than grProd because getMaxBVLevelsInUse() is currently only called from WEP_cboMaxDBLevel_Click()
    ; start with master fader level
    debugMsg(sProcName, "grProd\fMasterBVLevel=" + traceLevel(\fMasterBVLevel))
    fMaxBVLevel = \fMasterBVLevel
    gnMaxBVLevelSubPtr = -1
    
    ; check audio output default levels
    For d = 0 To \nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
      If \aAudioLogicalDevs(d)\sLogicalDev
        fBVLevel = \aAudioLogicalDevs(d)\fDfltBVLevel
        If fBVLevel > fMaxBVLevel
          fMaxBVLevel = fBVLevel
          gnMaxBVLevelSubPtr = -2
        EndIf
      EndIf
    Next d
    
    ; check video audio default levels
    For d = 0 To \nMaxVidAudLogicalDev ; grLicInfo\nMaxVidAudDevPerProd
      If \aVidAudLogicalDevs(d)\sVidAudLogicalDev
        fBVLevel = \aAudioLogicalDevs(d)\fDfltBVLevel
        If fBVLevel > fMaxBVLevel
          fMaxBVLevel = fBVLevel
          gnMaxBVLevelSubPtr = -3
        EndIf
      EndIf
    Next d
    
    ; check live input default levels
    For d = 0 To grProd\nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
      If \aLiveInputLogicalDevs(d)\sLogicalDev
        fBVLevel = \aLiveInputLogicalDevs(d)\fDfltInputLevel
        If fBVLevel > fMaxBVLevel
          fMaxBVLevel = fBVLevel
          gnMaxBVLevelSubPtr = -4
        EndIf
      EndIf
    Next d
  EndWith
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubTypeA
          ; check levels for video cues
          d = 0
          fBVLevel = \fSubMastBVLevel[d]
          If fBVLevel > fMaxBVLevel
            fMaxBVLevel = fBVLevel
            gnMaxBVLevelSubPtr = j
          EndIf
          
        ElseIf \bSubTypeF
          ; check levels for audio file cues
          k = \nFirstAudIndex
          If k >= 0
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If aAud(k)\sLogicalDev[d]
                fBVLevel = aAud(k)\fBVLevel[d]
                If fBVLevel > fMaxBVLevel
                  fMaxBVLevel = fBVLevel
                  gnMaxBVLevelSubPtr = j
                EndIf
              EndIf
            Next d
          EndIf
          
        ElseIf \bSubTypeL
          ; check levels for level change cues
          If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
            For d = 0 To grLicInfo\nMaxAudDevPerSub
              If \sLCLogicalDev[d]
                If \bLCInclude[d]
                  fBVLevel = \fSubMastBVLevel[d]
                  If fBVLevel > fMaxBVLevel
                    fMaxBVLevel = fBVLevel
                    gnMaxBVLevelSubPtr = j
                  EndIf
                EndIf
              EndIf
            Next d
          EndIf
          
        ElseIf \bSubTypeP
          ; check levels for playlists
          For d = 0 To grLicInfo\nMaxAudDevPerSub
            If \sPLLogicalDev[d]
              fBVLevel = \fSubMastBVLevel[d]
              If fBVLevel > fMaxBVLevel
                fMaxBVLevel = fBVLevel
                gnMaxBVLevelSubPtr = j
              EndIf
            EndIf
          Next d
          
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, #SCS_END + ", fMaxBVLevel=" + formatLevel(fMaxBVLevel) + ", gnMaxBVLevelSubPtr=" + getSubLabel(gnMaxBVLevelSubPtr))
  
  ProcedureReturn fMaxBVLevel
EndProcedure

Procedure.f getMinBVLevelInUse()
  PROCNAMEC()
  Protected fMinBVLevel.f, fBVLevel.f
  Protected i, j, k, d
  
  With grProd  ; ForDevChgs ; nb use grProdForDevChgs rather than grProd because getMinBVLevelsInUse() is currently only called from WEP_cboMinDBLevel_Click()
    ; start with master fader level
    debugMsg(sProcName, "grProd\fMasterBVLevel=" + traceLevel(\fMasterBVLevel))
    fMinBVLevel = \fMasterBVLevel
    gnMinBVLevelSubPtr = -1 ; -1 = master level
    
    ; check audio output default levels
    For d = 0 To \nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
      If \aAudioLogicalDevs(d)\sLogicalDev
        fBVLevel = \aAudioLogicalDevs(d)\fDfltBVLevel
        If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
          fMinBVLevel = fBVLevel
          gnMinBVLevelSubPtr = -2 ; -2 = minimum audio cue level
        EndIf
      EndIf
    Next d
    
    ; check video audio default levels
    For d = 0 To \nMaxVidAudLogicalDev ; grLicInfo\nMaxVidAudDevPerProd
      If \aVidAudLogicalDevs(d)\sVidAudLogicalDev
        fBVLevel = \aVidAudLogicalDevs(d)\fDfltBVLevel
        If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
          fMinBVLevel = fBVLevel
          gnMinBVLevelSubPtr = -3 ; -3 = minimum video audio cue level
        EndIf
      EndIf
    Next d
    
    ; check live input default levels
    For d = 0 To \nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
      If \aLiveInputLogicalDevs(d)\sLogicalDev
        fBVLevel = \aLiveInputLogicalDevs(d)\fDfltInputLevel
        If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
          fMinBVLevel = fBVLevel
          gnMinBVLevelSubPtr = -4 ; -4 = minimum live input level
        EndIf
      EndIf
    Next d
  EndWith
  
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      With aSub(j)
        If \bSubTypeA
          ; check levels for video cues
          d = 0
          fBVLevel = \fSubMastBVLevel[d]
          If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
            fMinBVLevel = fBVLevel
            gnMinBVLevelSubPtr = j
          EndIf
          
        ElseIf \bSubTypeF
          ; check levels for audio file cues
          k = \nFirstAudIndex
          If k >= 0
            For d = 0 To grLicInfo\nMaxAudDevPerAud
              If aAud(k)\sLogicalDev[d]
                fBVLevel = aAud(k)\fBVLevel[d]
                If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
                  fMinBVLevel = fBVLevel
                  gnMinBVLevelSubPtr = j
                EndIf
              EndIf
            Next d
          EndIf
          
        ElseIf \bSubTypeL
          ; check levels for level change cues
          If \nLCAction = #SCS_LC_ACTION_ABSOLUTE
            For d = 0 To grLicInfo\nMaxAudDevPerSub
              If \sLCLogicalDev[d]
                If \bLCInclude[d]
                  fBVLevel = \fSubMastBVLevel[d]
                  If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
                    fMinBVLevel = fBVLevel
                    gnMinBVLevelSubPtr = j
                  EndIf
                EndIf
              EndIf
            Next d
          EndIf
          
        ElseIf \bSubTypeP
          ; check levels for playlists
          For d = 0 To grLicInfo\nMaxAudDevPerSub
            If \sPLLogicalDev[d]
              fBVLevel = \fSubMastBVLevel[d]
              If fBVLevel <= fMinBVLevel And fBVLevel > 0.0
                fMinBVLevel = fBVLevel
                gnMinBVLevelSubPtr = j
              EndIf
            EndIf
          Next d
          
        EndIf
        j = \nNextSubIndex
      EndWith
    Wend
  Next i
  
  debugMsg(sProcName, #SCS_END + ", fMinBVLevel=" + formatLevel(fMinBVLevel) + ", gnMinBVLevelSubPtr=" + getSubLabel(gnMinBVLevelSubPtr))
  
  ProcedureReturn fMinBVLevel
EndProcedure

Procedure getMaxLoopXFadeTime(pAudPtr)
  Protected nMax, nThisMax, l2
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      For l2 = 0 To \nMaxLoopInfo
        If \aLoopInfo(l2)\bContainsLoop
          nThisMax = \aLoopInfo(l2)\nAbsLoopEnd - \aLoopInfo(l2)\nAbsLoopStart
          If nThisMax > nMax
            nMax = nThisMax
          EndIf
        EndIf
      Next l2
    EndWith
  EndIf
  ProcedureReturn nMax
  
EndProcedure

Procedure bumpKeyHandler()
  
  Select gnEventType
    Case #PB_EventType_Focus, #PB_EventType_LostFocus
      Select gnEventGadgetNoForEvHdlr
        Case WQF\txtStartAt, WQF\txtEndAt, WQF\txtLoopStart, WQF\txtLoopEnd, WQF\txtLoopXFadeTime, WQF\txtFadeInTime, WQF\txtFadeOutTime
          If gnEventType = #PB_EventType_Focus
            AddKeyboardShortcut(#WED, #PB_Shortcut_Control | #PB_Shortcut_Left, #SCS_ALLF_BumpLeft)
            AddKeyboardShortcut(#WED, #PB_Shortcut_Control | #PB_Shortcut_Right, #SCS_ALLF_BumpRight)
          Else
            RemoveKeyboardShortcut(#WED, #PB_Shortcut_Control | #PB_Shortcut_Left)
            RemoveKeyboardShortcut(#WED, #PB_Shortcut_Control | #PB_Shortcut_Right)
          EndIf
      EndSelect
  EndSelect
  
EndProcedure

Procedure bumpKey(nEventMenu)
  ; returns #True if user entered Ctrl/Left or Ctrl/Right
  If nEventMenu = #SCS_ALLF_BumpLeft Or nEventMenu = #SCS_ALLF_BumpRight
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure bumpTimeField(hTxtField, nMin, nMax, nBlankIs, nEventMenu)
  PROCNAMEC()
  Protected nTime, nInterval, nOriginalTime
  Protected bChanged, sTime.s
  
  If nEventMenu = #SCS_ALLF_BumpLeft
    nInterval = -10
  ElseIf nEventMenu = #SCS_ALLF_BumpRight
    nInterval = 10
  EndIf
  
  If nInterval <> 0
    sTime = GGT(hTxtField)
    nTime = stringToTime(sTime, #False)
    If nTime < 0
      Select nTime
        Case -1
          nTime = aAud(nEditAudPtr)\nAbsEndAt
        Case -2
          nTime = nBlankIs
        Case -3
          nTime = aAud(nEditAudPtr)\nAbsStartAt
      EndSelect
    EndIf
    nOriginalTime = nTime
    nTime + nInterval
    nTime = (nTime / 10) * 10  ; when using 'bump' we lock into hundredths
    If nTime < nMin
      nTime = nMin
    ElseIf nTime > nMax
      nTime = nMax
    EndIf
    If nTime <> nOriginalTime
      SetGadgetText(hTxtField, timeToStringT(nTime, nMax))
      bChanged = #True
    EndIf
  EndIf
  ProcedureReturn bChanged
EndProcedure

Procedure.s decodeDragAndDropState(nState)
  PROCNAMEC()
  Protected sDragAndDropState.s
  
  Select nState
    Case #PB_Drag_Enter
      sDragAndDropState = "#PB_Drag_Enter"
    Case #PB_Drag_Update
      sDragAndDropState = "#PB_Drag_Update"
    Case #PB_Drag_Leave
      sDragAndDropState = "#PB_Drag_Leave"
    Case #PB_Drag_Finish
      sDragAndDropState = "#PB_Drag_Finish"
    Default
      sDragAndDropState = Str(nState)
  EndSelect
  ProcedureReturn sDragAndDropState
EndProcedure

Procedure getIndexForVidAudLogicalDev(sLogicalDev.s)
  PROCNAMEC()
  Protected nIndex
  Protected n
  
  nIndex = -1
  For n = 0 To grProd\nMaxAudioLogicalDev
    If grProd\aVidAudLogicalDevs(n)\sVidAudLogicalDev = sLogicalDev
      nIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nIndex
EndProcedure

Procedure propagateProdDefDMXFadeTime()
  PROCNAMEC()
  Protected i, j
  Protected bCueChanged, bReloadDispPanels
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bProdDefDMXFadeTimeChanged
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeK
        bCueChanged = #False
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          With aSub(j)
            If \bSubTypeK
              ; nb no need to test \nLTEntryType for this process
              If \nLTBLFadeAction = #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDCFadeOutOthersUserTime = #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTDIFadeOutOthersUserTime = #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT Or
                 \nLTFIFadeOutOthersUserTime = #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
                ; debugMsg0(sProcName, "calling DMX_buildDMXValuesString(" + getSubLabel(j) + ")")
                DMX_buildDMXValuesString(j)
                bCueChanged = #True
              EndIf
            EndIf
            j = \nNextSubIndex
          EndWith
        Wend
        If bCueChanged
          debugMsg(sProcName, "calling loadGridRow(" + getCueLabel(i) + ")")
          loadGridRow(i)
          If aCue(i)\nCueState < #SCS_CUE_COMPLETED
            bReloadDispPanels = #True
          EndIf
        EndIf
      EndIf
    Next i
    grCED\bProdDefDMXFadeTimeChanged = #False
  EndIf
  
  If bReloadDispPanels
    debugMsg(sProcName, "calling PNL_loadDispPanels()")
    PNL_loadDispPanels()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure valTemplateName(lblField, txtField)
  PROCNAMEC()
  Protected sTemplateName.s
  Protected n
  
  sTemplateName = Trim(GGT(txtField))
  If Len(sTemplateName) = 0
    valErrMsgTxt(txtField, LangPars("Errors", "MustBeEntered", GLT(lblField)))
    ProcedureReturn #False
  EndIf
  If CheckFilename(sTemplateName) = #False
    valErrMsgTxt(txtField, LangPars("Errors", "TemplateNameInvalid", #DQUOTE$ + sTemplateName + #DQUOTE$))
    ProcedureReturn #False
  EndIf
  For n = 0 To (gnTemplateCount-1)
    If n <> grWTM\nTemplatePtr
      If UCase(gaTemplate(n)\sName) = UCase(sTemplateName)
        valErrMsgTxt(txtField, LangPars("Errors", "TemplateNameAlreadyUsed", #DQUOTE$ + sTemplateName + #DQUOTE$))
        ProcedureReturn #False
      EndIf
    EndIf
  Next n
  
  ProcedureReturn #True
EndProcedure

Procedure moveCue(nCueToMove, nTargetCuePtr)
  PROCNAMEC()
  Protected rCue.tyCue
  Protected i, nMyTargetPosition
  Dim aMyCue.tyCue(0)
  
  ; warning - 'undo' not available for 'move cue' - may add later if there is a demand for it (may need to hold pre- and post-images of many cues)
  
  debugMsg(sProcName, #SCS_START + ", nCueToMove=" + nCueToMove + " (" + getCueLabel(nCueToMove) + "), nTargetCuePtr=" + nTargetCuePtr + " (" + getCueLabel(nTargetCuePtr) + ")")
  
  ; old a copy of the cue to be moved
  rCue = aCue(nCueToMove)
  ; copy the entire aCue() array to aMyCue()
  ReDim aMyCue(gnLastCue)
  For i = 1 To gnLastCue
    aMyCue(i) = aCue(i)
  Next i
  ; in array aMyCue() take out the cue to be moved
  For i = (nCueToMove + 1) To gnLastCue
    aMyCue(i-1) = aMyCue(i)
  Next i
  
  nMyTargetPosition = nTargetCuePtr
  ; has target position moved due to the removal of the cue to be moved?
  If nTargetCuePtr < nCueToMove
    nMyTargetPosition + 1
  EndIf
  ; in array aMyCue() move cues that are beyond the target position down one position
  For i = (gnLastCue - 1) To nMyTargetPosition Step -1
    aMyCue(i+1) = aMyCue(i)
  Next i
  ; now slot the cue to be moved into the vacated slot in the array aMyCue()
  aMyCue(nMyTargetPosition) = rCue
  CompilerIf 1=2
    For i = 1 To gnLastCue
      debugMsg(sProcName, "aMyCue(" + i + ")\sCue=" + aMyCue(i)\sCue)
    Next i
  CompilerEndIf
  ; copy the entire aMyCue() array to aCue()
  For i = 1 To gnLastCue
    aCue(i) = aMyCue(i)
  Next i
  ; now call setCuePtrs() because we need to fix up cue ptrs in sub-cues, etc
  setCuePtrs(#False)
  loadCueBrackets()
  
  WED_setEditorButtons()
  gbCallPopulateGrid = #True
  debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
  gbCallLoadDispPanels = #True
  gnCallOpenNextCues = 1
  
  CompilerIf 1=2
    If sanityCheck()
      debugMsg(sProcName, "calling debugCuePtrs")
      debugCuePtrs()
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setEditAudPtr(nNewEditAudPtr)
  PROCNAMECA(nNewEditAudPtr)
  
  CompilerIf #c_vMix_in_video_cues
    If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_VMIX
      If nNewEditAudPtr <> nEditAudPtr
        If nEditAudPtr >= 0 And nEditSubPtr >= 0
          If aAud(nEditAudPtr)\bAudTypeA
            If grVidPicTarget(#SCS_VID_PIC_TARGET_P)\nCurrAudPtr = nEditAudPtr
              If aAud(nEditAudPtr)\svMixInputKey
                debugMsg(sProcName, "calling closeSub(" + getSubLabel(nEditSubPtr) + ")")
                closeSub(nEditSubPtr)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  CompilerEndIf

  nEditAudPtr = nNewEditAudPtr
EndProcedure

Procedure.s buildSkipBackForwardTooltip()
  PROCNAMEC()
  Protected sToolTip.s
  Static sRawText.s, bStaticLoaded
  
  If bStaticLoaded = #False
    sRawText = Lang("Common", "SkipBackForwardTT")
    bStaticLoaded = #True
  EndIf
  
  sToolTip = ReplaceString(sToolTip, "$1", decodeEditorShortcutFunction(#SCS_WEDF_SkipBack))
  sToolTip = ReplaceString(sToolTip, "$2", decodeEditorShortcutFunction(#SCS_WEDF_SkipForward))
  
  ProcedureReturn sToolTip
EndProcedure

Procedure setDefaultCueDescrMayBeSet(pCuePtr, bSaveUndoInfo)
  PROCNAMECQ(pCuePtr)
  Protected u, nSubPtr, bReqdSetting
  
  If pCuePtr >= 0
    With aCue(pCuePtr)
      nSubPtr = \nFirstSubIndex
      If nSubPtr >= 0
        If aSub(nSubPtr)\sSubDescr = \sCueDescr
          bReqdSetting = #True
        EndIf
      Else
        bReqdSetting = #True
      EndIf
      If \bDefaultCueDescrMayBeSet <> bReqdSetting
        If bSaveUndoInfo
          u = preChangeCueL(\bDefaultCueDescrMayBeSet, "(Internal Indicator)", pCuePtr)
          \bDefaultCueDescrMayBeSet = bReqdSetting
          postChangeCueL(u, \bDefaultCueDescrMayBeSet, pCuePtr)
        Else
          \bDefaultCueDescrMayBeSet = bReqdSetting
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure resetSubStart(pSubPtr)
  With aSub(pSubPtr)
    \nSubStart = grSubDef\nSubStart
    \sSubCueMarkerName = grSubDef\sSubCueMarkerName
    \nSubCueMarkerId = grSubDef\nSubCueMarkerId
    \nSubCueMarkerAudNo = grSubDef\nSubCueMarkerAudNo
    \nSubCueMarkerAudId = grSubDef\nSubCueMarkerAudId
    \nRelMTCStartTimeForSub = grSubDef\nRelMTCStartTimeForSub
  EndWith
EndProcedure

Procedure checkOneCallableCueParamValid(pSubPtr, sParamId.s)
  ; PROCNAMECS(pSubPtr)
  Protected nCuePtr, n, bValid, sChar.s
  
  If sParamId
    If sChar >= "A" And sChar <= "Z"
      ; Above test added 29Jan2023 11.10.2
      ; Callable cue parameters all start with a letter, ie in the range A-Z or a-z
      nCuePtr = aSub(pSubPtr)\nCueIndex
      With aCue(nCuePtr)
        If \nActivationMethod = #SCS_ACMETH_CALL_CUE
          For n = 0 To \nMaxCallableCueParam
            If UCase(\aCallableCueParam(n)\sCallableParamId) = UCase(sParamId)
              bValid = #True
              Break
            EndIf
          Next n
          If bValid = #False
            gsError = LangPars("Errors", "CallableParamNotFound", sParamId, aSub(pSubPtr)\sSubLabel, \sCue)
          EndIf
        Else
          gsError = LangPars("Errors", "CallableParamNotReqd", sParamId, aSub(pSubPtr)\sSubLabel, \sCue)
        EndIf
      EndWith
    Else
      bValid = #True
    EndIf
  Else
    ; not a callable cue parameter
    bValid = #True
  EndIf
  ProcedureReturn bValid
  
EndProcedure

Procedure checkCallableCueParamsValid(pCuePtr, pSubPtr=-1)
  PROCNAMECQ(pCuePtr)
  Protected j, bValid
  
  ; debugMsg(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr))
  
  bValid = #True
  gsError = ""
  
  If aCue(pCuePtr)\nActivationMethod = #SCS_ACMETH_CALL_CUE
    populateCallableCueParamArray(@aCue(pCuePtr))
  EndIf
  
  If pSubPtr = -1
    ; check all subs in this cue
    j = aCue(pCuePtr)\nFirstSubIndex
  Else
    ; check only the nominated sub
    j = pSubPtr
  EndIf
  
  With aSub(j)
    While j >= 0
      If \bSubTypeK
        ; debugMsg0(sProcName, "checking " + \sSubLabel)
        Select \nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_BLACKOUT
            If \nLTBLFadeAction = #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTBLFadeUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            If \nLTDCFadeUpAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDCFadeUpUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTDCFadeDownAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDCFadeDownUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTDCFadeOutOthersAction = #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDCFadeOutOthersUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            If \nLTDIFadeUpAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDIFadeUpUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTDIFadeDownAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDIFadeDownUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTDIFadeOutOthersAction = #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTDIFadeOutOthersUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            If \nLTFIFadeUpAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTFIFadeUpUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTFIFadeDownAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTFIFadeDownUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            If \nLTFIFadeOutOthersAction = #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
              bValid = checkOneCallableCueParamValid(j, \sLTFIFadeOutOthersUserTime)
              If bValid = #False : Break : EndIf
            EndIf
            
        EndSelect
      EndIf
      If pSubPtr >= 0
        ; completed checking for the nominated sub
        Break
      EndIf
      j = \nNextSubIndex
    Wend
  EndWith
  
  If bValid = #False
    debugMsg(sProcName, "Returning bValid=" + strB(bValid) + ", gsError=" + #DQUOTE$ + gsError + #DQUOTE$)
  EndIf
  ProcedureReturn bValid
  
EndProcedure

Procedure loadHotkeyStepNos()
  PROCNAMEC()
  ; Also used for "Reset 'Step' Hotkeys", with bDisplayMessage set to #True
  Protected i, sThisHotkey.s, nStepNo, bUnProcessedStepsFound
  
  ; initially clear all step numbers
  For i = 1 To gnLastCue
    With aCue(i)
      \nCueHotkeyStepNo = 0
    EndWith
  Next i
  
  While #True
    bUnProcessedStepsFound = #False
    sThisHotkey = ""
    nStepNo = 0
    For i = 1 To gnLastCue
      With aCue(i)
        If \nActivationMethod = #SCS_ACMETH_HK_STEP
          If \bCueEnabled And \nCueState <> #SCS_CUE_IGNORED
            If \nCueHotkeyStepNo = 0
              ; not yet processed
              If \sHotkey = sThisHotkey Or Len(sThisHotkey) = 0
                bUnProcessedStepsFound = #True
                sThisHotkey = \sHotkey
                nStepNo + 1
                \nCueHotkeyStepNo = nStepNo
                debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\sHotkey=" + \sHotkey + ", \nCueHotkeyStepNo=" + \nCueHotkeyStepNo)
              EndIf
            EndIf
          EndIf
        EndIf
      EndWith
    Next i
    If bUnProcessedStepsFound = #False
      Break
    EndIf
  Wend
  
EndProcedure

Procedure resetStepHotkeys(sTitle.s)
  PROCNAMEC()
  Protected nKeyIndex, nHotkeyNr, sHotkeysReset.s, sMessage.s
  Protected i
  
  debugMsg(sProcName, #SCS_START)

  For nKeyIndex = 0 To gnMaxCurrHotkey
    With gaCurrHotkeys(nKeyIndex)
      If \nActivationMethod = #SCS_ACMETH_HK_STEP
        nHotkeyNr = \nHotkeyNr
        If gnLastHotkeyStepProcessed(nHotkeyNr) > 0
          gnLastHotkeyStepProcessed(nHotkeyNr) = 0
          sHotkeysReset + " " + \sHotkey + ","
        EndIf
      EndIf
    EndWith
  Next nKeyIndex
  
  ; make sure all 'last step processed' items are cleared
  For nHotkeyNr = 0 To ArraySize(gnLastHotkeyStepProcessed())
    gnLastHotkeyStepProcessed(nHotkeyNr) = 0
  Next nHotkeyNr
  
  If sHotkeysReset
    For i = gnLastCue To 1 Step -1
      With aCue(i)
        If \nActivationMethod = #SCS_ACMETH_HK_STEP
          If \bCueEnabled And \nCueState <> #SCS_CUE_IGNORED
            goToCueNonLinear(i, #False)
          EndIf
        EndIf
      EndWith
    Next i
  EndIf
  
  setCueToGo()
  
  sHotkeysReset = RTrim(Trim(sHotkeysReset), ",") ; removes space character from the start, and the final comma, eg " A, B, F12," is returned as "A, B, F12"
  If sHotkeysReset
    sMessage = LangPars("HKeys", "StepResetDone", sHotkeysReset)
  Else
    ; no Step hotkeys reset
    sMessage = Lang("HKeys", "StepResetNone")
  EndIf
  scsMessageRequester(sTitle, sMessage)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF