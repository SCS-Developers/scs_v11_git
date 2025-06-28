; File: M2T.pbi
; M2T = 'Move to Time'

EnableExplicit

Procedure M2T_processMoveToTimeShortcut()
  PROCNAMEC()
  Protected nCuePtr, nSubPtr, nAudPtr, nDispPanel, n, bUseAudPtr
  Protected bError, sErrorMsg.s
  Protected i, nCueState
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\bM2TAvailable
    For i = 1 To gnLastCue
      nCueState = aCue(i)\nCueState
      If nCueState > #SCS_CUE_READY And nCueState < #SCS_CUE_PL_READY And nCueState <> #SCS_CUE_HIBERNATING
        bError = #True
        sErrorMsg = LangPars("Errors", "M2TCueRunning", getCueLabel(i), decodeCueStateL(nCueState))
        Break
      EndIf
    Next i
    If bError = #False
      nDispPanel = -1
      nCuePtr = gnCueToGo
      nAudPtr = -1
      If nCuePtr >= 0
        If aCue(nCuePtr)\nCueState > #SCS_CUE_READY
          bError = #True
          sErrorMsg = LangPars("Errors", "M2TCueRunning", getCueLabel(nCuePtr), decodeCueStateL(aCue(nCuePtr)\nCueState))
        Else
          nSubPtr = getFirstEnabledSubForCue(nCuePtr)
          If nSubPtr >= 0
            Select aSub(nSubPtr)\sSubType
              Case "A", "F"
                nAudPtr = aSub(nSubPtr)\nFirstPlayIndex
                For n = 0 To ArraySize(gaDispPanel())
                  If gaDispPanel(n)\nDPAudPtr = nAudPtr
                    nDispPanel = n
                    bUseAudPtr = #True
                    Break
                  EndIf
                Next n
              Case "U"
                For n = 0 To ArraySize(gaDispPanel())
                  If gaDispPanel(n)\nDPSubPtr = nSubPtr
                    nDispPanel = n
                    bUseAudPtr = #False
                    Break
                  EndIf
                Next n
              Default
                If grM2T\bProcessingApplyMoveToTime = #False
                  bError = #True
                  sErrorMsg = LangPars("Errors", "M2TBadCueType", getCueLabel(nCuePtr), decodeSubTypeL(aSub(nSubPtr)\sSubType, nSubPtr))
                EndIf
            EndSelect
          EndIf ; EndIf nSubPtr >= 0
          If bError = #False
            If M2T_loadMoveToTimeInfo(nCuePtr)
              bError = #True
              sErrorMsg = grM2T\sM2TErrorMsg
            EndIf
          EndIf
          If bError = #False
            ; debugMsg(sProcName, "nDispPanel=" + nDispPanel + ", nAudPtr=" + getAudLabel(nAudPtr) + ", bUseAudPtr=" + strB(bUseAudPtr))
            If (nDispPanel >= 0) And (nAudPtr >= 0 Or bUseAudPtr = #False)
              With gaPnlVars(nDispPanel)
                If gaDispPanel(nDispPanel)\bM2T_Active
                  gaDispPanel(nDispPanel)\bM2T_Active = #False
                  M2T_clearAllMoveToTimeInfo()
                Else
                  gaDispPanel(nDispPanel)\bM2T_Active = #True
                  setVisible(\cntTransportCtls, #False)
                  setVisible(\cntMoveToTimePrimary, #True)
                    ; The following changed 2-5Mar2024 11.10.2az-ba
                    ; debugMsg(sProcName, "gaPnlVars(" + nDispPanel + ")\nLastMoveToTime=" + ttszt(\nLastMoveToTime))
                  If bUseAudPtr
                    If aAud(nAudPtr)\nRelFilePos > 0
                      SGT(\txtMoveToTime, timeToString(aAud(nAudPtr)\nRelFilePos, (aAud(nAudPtr)\nAbsMax - aAud(nAudPtr)\nAbsMin)))
                      M2T_displayMoveToTimeValueIfActive(nDispPanel, aAud(nAudPtr)\nRelFilePos, #True)
                    Else
                      If grM2T\nM2TPrimaryCuePtr = \nLastM2TPrimaryCuePtr
                        grM2T\nMoveToTime = \nLastMoveToTime
                      Else
                        grM2T\nMoveToTime = 0
                      EndIf
                      SGT(\txtMoveToTime, timeToString(grM2T\nMoveToTime, aSub(nSubPtr)\nSubDuration))
                      M2T_displayMoveToTimeValueIfActive(nDispPanel, grM2T\nMoveToTime, #True)
                    EndIf
                  Else
                    ; SGT(\txtMoveToTime, timeToString(0, aSub(nSubPtr)\nSubDuration))
                    ; M2T_displayMoveToTimeValueIfActive(nDispPanel, 0, #True)
                    If grM2T\nM2TPrimaryCuePtr = \nLastM2TPrimaryCuePtr
                      grM2T\nMoveToTime = \nLastMoveToTime
                    Else
                      grM2T\nMoveToTime = 0
                    EndIf
                    SGT(\txtMoveToTime, timeToString(grM2T\nMoveToTime, aSub(nSubPtr)\nSubDuration))
                    M2T_displayMoveToTimeValueIfActive(nDispPanel, grM2T\nMoveToTime, #True)
                  EndIf
                  ; End of changed 2-5Mar2024
                  M2T_setMoveToTimeSlider(nDispPanel)
                  SAG(\txtMoveToTime)
                EndIf
              EndWith
            EndIf ; EndIf nDispPanel >= 0 And nAudPtr >= 0
          EndIf ; EndIf bError = #False
        EndIf ; EndIf aCue(nCuePtr)\nCueState > #SCS_CUE_READY / Else
      EndIf ; EndIf nCuePtr >= 0
    EndIf ; EndIf grLicInfo\bM2TAvailable
  EndIf ; EndIf bError = #False
  
  If bError
    If gbGlobalPause Or gbStoppingEverything
      scsMessageRequester(Lang("Init", "FnMoveToTime"), sErrorMsg, #PB_MessageRequester_Error)
    Else
      WMN_setStatusField(sErrorMsg, #SCS_STATUS_WARN)
    EndIf
  EndIf
  
EndProcedure

Procedure M2T_displayMoveToTimeValueIfActive(h, nTimeValue, bLoadM2T=#False, bTrace=#True)
  PROCNAMECP(h)
  Protected nSubPtr, nAudPtr, bWantThis, nSlider
  
  debugMsgC(sProcName, #SCS_START)
  
  With gaDispPanel(h)
    ; debugMsg(sProcName, "gaDispPanel(" + h + ")\bM2T_Active=" + strB(\bM2T_Active) + ", \sDPSubType=" + \sDPSubType)
    If \bM2T_Active
      Select \sDPSubType
        Case "A", "F"
          nAudPtr = \nDPAudPtr
          If nAudPtr >= 0
            bWantThis = #True
            SGT(gaPnlVars(h)\txtMoveToTime, timeToString(nTimeValue, (aAud(nAudPtr)\nAbsMax - aAud(nAudPtr)\nAbsMin)))
          EndIf
        Case "U"
          nSubPtr = \nDPSubPtr
          If nSubPtr >= 0
            bWantThis = #True
            SGT(gaPnlVars(h)\txtMoveToTime, timeToString(nTimeValue, aSub(nSubPtr)\nSubDuration))
          EndIf
      EndSelect
      If bWantThis
        nSlider = gaPnlVars(h)\sldMoveToTimePosition
        If bLoadM2T
          If grM2T\nM2TTotalLength > 0
            SLD_setMax(nSlider, (grM2T\nM2TTotalLength -1))
          Else
            SLD_setMax(gaPnlVars(h)\sldMoveToTimePosition, 0)
          EndIf
        Else
          M2T_adjustDependentCuesForMoveToTimeCue(\nDPCuePtr, nTimeValue, bTrace)
        EndIf
        M2T_displayMoveToTimeInfo(bTrace)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure M2T_getCueStartTime(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected n, nCueStartTime
  
  For n = 0 To grM2T\nM2TMaxItem
    With grM2T\aM2TItem(n)
      If \nThisCuePtr = pCuePtr
        nCueStartTime = \nThisCueStartTime
        Break
      EndIf
    EndWith
  Next n
  debugMsg(sProcName, #SCS_END + ", returning nCueStartTime=" + ttszt(nCueStartTime))
  ProcedureReturn nCueStartTime
  
EndProcedure

Procedure M2T_loadMoveToTimeInfo(pCuePtr, bTrace=#True)
  PROCNAMECQ(pCuePtr)
  Protected nSubPtr, nAudPtr, bError
  Protected i, j, k, nItemIndex, nMaxItemIndex, nInfoIndex, n3, nMaxThisPass, nRelStartTime, bFirstSubForCue
  Protected nControllingCuePtr, nControllingCueLength
  Protected bProcessThisCue, nCueLength
  Protected bProcessThisSub, nCueAutoStartTime, nSubAutoStartTime, nPrevSubAutoStartTime, nSubLength, nPrevSubLength
  Protected nOCMSubPtr, nOCMAudPtr, sOCMCueMarkerName.s
  Protected nAutoActCueMarkerId
  
  debugMsgC(sProcName, #SCS_START)
  
  With grM2T
    \nM2TPrimaryCuePtr = pCuePtr
    \nM2TPrimarySubPtr = getFirstEnabledSubForCue(pCuePtr)
    If \nM2TPrimarySubPtr >= 0
      \nM2TPrimaryAudPtr = aSub(\nM2TPrimarySubPtr)\nFirstAudIndex
    Else
      \nM2TPrimaryAudPtr = -1
    EndIf
    \nM2TPrimaryCueLength = getCueLength(pCuePtr)
    \nM2TMaxItem = -1
  EndWith
  
  nCueAutoStartTime = 0
  nPrevSubAutoStartTime = 0
  nPrevSubLength = 0
  bFirstSubForCue = #True
  j = aCue(pCuePtr)\nFirstSubIndex
  While j >= 0
    If aSub(j)\bSubEnabled
      bProcessThisSub = #True
      nSubAutoStartTime = 0
      Select aSub(j)\nSubStart
        Case #SCS_SUBSTART_REL_TIME
          nRelStartTime = aSub(j)\nRelStartTime
          If nRelStartTime < 0
            ; probably -2, which is the default value, where -2 means 'blank'
            nRelStartTime = 0
          EndIf
          Select aSub(j)\nRelStartMode
            Case #SCS_RELSTART_DEFAULT, #SCS_RELSTART_AS_CUE
              nSubAutoStartTime = nRelStartTime
            Case #SCS_RELSTART_AS_PREV_SUB
              nSubAutoStartTime = nPrevSubAutoStartTime + nRelStartTime
            Case #SCS_RELSTART_AE_PREV_SUB
              nSubAutoStartTime = nPrevSubAutoStartTime + nPrevSubLength + nRelStartTime
            Default
              debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nRelStartMode=" + decodeRelStartMode(aSub(j)\nRelStartMode))
              bProcessThisSub = #False
          EndSelect
          
        Case #SCS_SUBSTART_OCM
          If aSub(j)\sSubCueMarkerName
            For nInfoIndex = 0 To gnMaxCueMarkerInfo
              If gaCueMarkerInfo(nInfoIndex)\nCueMarkerId = aSub(j)\nSubCueMarkerId
                nOCMSubPtr = getSubPtrForCueSubNo(gaCueMarkerInfo(nInfoIndex)\nHostCuePtr, gaCueMarkerInfo(nInfoIndex)\nHostSubNo)
                nOCMAudPtr = gaCueMarkerInfo(nInfoIndex)\nHostAudPtr
                If nOCMSubPtr >= 0 And nOCMAudPtr >= 0
                  If (gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition >= aAud(nOCMAudPtr)\nAbsStartAt) And (gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition < aAud(nOCMAudPtr)\nAbsEndAt)
                    nSubAutoStartTime = gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition - aAud(nOCMAudPtr)\nAbsStartAt
                    For nItemIndex = 0 To grM2T\nM2TMaxItem
                      If grM2T\aM2TItem(nItemIndex)\nThisSubPtr = nOCMSubPtr
                        nSubAutoStartTime + grM2T\aM2TItem(nItemIndex)\nThisSubStartTime
                        Break
                      EndIf
                    Next nItemIndex
                  EndIf
                EndIf
                debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\sSubCueMarkerName=" + aSub(j)\sSubCueMarkerName + ", nSubAutoStartTime=" + ttszt(nSubAutoStartTime))
                Break ; Cue Marker found at index n
              EndIf
            Next nInfoIndex
          EndIf
          
      EndSelect
      If bProcessThisSub
        ; debugMsgC(sProcName, "Sub=" + getSubLabel(j) + ", nSubAutoStartTime=" + ttszt(nSubAutoStartTime))
        nSubLength = getSubLength(j)
        grM2T\nM2TMaxItem + 1
        If grM2T\nM2TMaxItem > ArraySize(grM2T\aM2TItem())
          ReDim grM2T\aM2TItem(grM2T\nM2TMaxItem+10)
        EndIf
        With grM2T\aM2TItem(grM2T\nM2TMaxItem)
          \nControllingCuePtr = -1
          \nThisCuePtr = pCuePtr
          \nThisCueStartTime = 0
          \nThisCueLength = getCueLength(pCuePtr)
          ; debugMsg(sProcName, "getCueLength(" + getCueLabel(pCuePtr) + ") returned grM2T\aM2TItem(" + grM2T\nM2TMaxItem + ")\nThisCueLength=" + ttszt(\nThisCueLength))
          \nOrigCueState = aCue(pCuePtr)\nCueState
          \nReqdCueState = \nOrigCueState
          \nThisSubPtr = j
          \nThisSubStartTime = nSubAutoStartTime
          \nThisSubLength = nSubLength
          \sThisSubType = aSub(j)\sSubType
          \bFirstSubForCue = bFirstSubForCue
          \nOrigSubState = aSub(j)\nSubState
          \nReqdSubState = \nOrigSubState
          If aSub(j)\bSubTypeHasAuds
            M2T_calcAudRelStartTimes(j)
            \nThisAudPtr = aSub(j)\nFirstAudIndex
            \nThisAudStartTime = \nThisSubStartTime
          Else
            \nThisAudPtr = -1
            \nThisAudStartTime = 0
          EndIf
          debugMsgC(sProcName, "ADDED grM2T\aM2TItem(" + grM2T\nM2TMaxItem + ")\nControllingCuePtr=" + getCueLabel(\nControllingCuePtr) + ", \nThisCuePtr=" + getCueLabel(\nThisCuePtr) + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) +
                               ", \sThisSubType=" + \sThisSubType + ", \nThisSubStartTime=" + ttszt(\nThisSubStartTime))
        EndWith
        nPrevSubAutoStartTime = nSubAutoStartTime
        nPrevSubLength = nSubLength
        bFirstSubForCue = #False
      EndIf ; EndIf bProcessThisSub
    EndIf
    j = aSub(j)\nNextSubIndex
  Wend
  
  nMaxItemIndex = grM2T\nM2TMaxItem
  For nItemIndex = 0 To nMaxItemIndex
    ; debugMsg(sProcName, "START OF LOOP nItemIndex=" + nItemIndex + ", nMaxItemIndex=" + nMaxItemIndex + ", grM2T\nM2TMaxItem=" + grM2T\nM2TMaxItem + ", grM2T\aM2TItem(" + nItemIndex + ")\bFirstSubForCue=" + strB(grM2T\aM2TItem(nItemIndex)\bFirstSubForCue))
    If grM2T\aM2TItem(nItemIndex)\bFirstSubForCue
      nControllingCuePtr = grM2T\aM2TItem(nItemIndex)\nThisCuePtr
      nControllingCueLength = getCueLength(nControllingCuePtr)
      debugMsgC(sProcName, ">>>> nItemIndex=" + nItemIndex + ", getCueLength(" + getCueLabel(nControllingCuePtr) + ")=" + ttszt(nControllingCueLength))
      For i = 1 To gnLastCue
        bProcessThisCue = #False
        ; debugMsg(sProcName, "bProcessThisCue=" + strB(bProcessThisCue) + ", aCue(" + getCueLabel(i) + ")\bCueEnabled=" + strB(aCue(i)\bCueEnabled) + ", \nActivationMethod=" + decodeActivationMethod(aCue(i)\nActivationMethod))
        bFirstSubForCue = #True
        If aCue(i)\bCueEnabled
          If aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO Or aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActCuePtr=" + getCueLabel(aCue(i)\nAutoActCuePtr) + ", nControllingCuePtr=" + getCueLabel(nControllingCuePtr))
            If aCue(i)\nAutoActCuePtr = nControllingCuePtr
              bProcessThisCue = #True
              ; debugMsg(sProcName, "bProcessThisCue=" + strB(bProcessThisCue))
              Select aCue(i)\nAutoActPosn
                Case #SCS_ACPOSN_AS
                  nCueAutoStartTime = aCue(i)\nAutoActTime
                Case #SCS_ACPOSN_BE
                  nCueAutoStartTime = nControllingCueLength - aCue(i)\nAutoActTime
                Case #SCS_ACPOSN_AE
                  nCueAutoStartTime = nControllingCueLength + aCue(i)\nAutoActTime
                Default
                  debugMsgC(sProcName, "aCue(" + getCueLabel(i) + ")\nAutoActPosn=" + decodeAutoActPosn(aCue(i)\nAutoActPosn))
                  bProcessThisCue = #False
                  ; debugMsg(sProcName, "bProcessThisCue=" + strB(bProcessThisCue))
              EndSelect
            EndIf
            
          ElseIf aCue(i)\nActivationMethod = #SCS_ACMETH_OCM
            ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\nActivationMethod=" + decodeActivationMethod(aCue(i)\nActivationMethod) +
            ;                     ", \nAutoActCuePtr=" + getCueLabel(aCue(i)\nAutoActCuePtr) + ", nControllingCuePtr=" + getCueLabel(nControllingCuePtr))
            If aCue(i)\nAutoActCuePtr = nControllingCuePtr
              For nInfoIndex = 0 To gnMaxCueMarkerInfo
                ; debugMsg(sProcName, "gaCueMarkerInfo(" + nInfoIndex + ")\nCueMarkerId=" + gaCueMarkerInfo(nInfoIndex)\nCueMarkerId)
                If gaCueMarkerInfo(nInfoIndex)\nCueMarkerId = aCue(i)\nAutoActCueMarkerId
                  nOCMSubPtr = getSubPtrForCueSubNo(gaCueMarkerInfo(nInfoIndex)\nHostCuePtr, gaCueMarkerInfo(nInfoIndex)\nHostSubNo)
                  nOCMAudPtr = gaCueMarkerInfo(nInfoIndex)\nHostAudPtr
                  sOCMCueMarkerName = gaCueMarkerInfo(nInfoIndex)\sCueMarkerName
                  ; debugMsg(sProcName, "nOCMSubPtr=" + getSubLabel(nOCMSubPtr) + ", nOCMAudPtr=" + getAudLabel(nOCMAudPtr) + ", sOCMCueMarkerName=" + sOCMCueMarkerName)
                  nCueAutoStartTime = 0
                  If nOCMSubPtr >= 0 And nOCMAudPtr >= 0
                    If (gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition >= aAud(nOCMAudPtr)\nAbsStartAt) And (gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition < aAud(nOCMAudPtr)\nAbsEndAt)
                      bProcessThisCue = #True ; Added 8Mar2023 11.10.2bc
                      nCueAutoStartTime = gaCueMarkerInfo(nInfoIndex)\nCueMarkerPosition - aAud(nOCMAudPtr)\nAbsStartAt
                      If aSub(nOCMSubPtr)\nSubStart = #SCS_SUBSTART_REL_TIME
                        nCueAutoStartTime + aSub(nOCMSubPtr)\nRelStartTime
                      EndIf
                    EndIf
                  EndIf
                  Break ; Cue Marker found at index nInfoIndex
                EndIf
              Next nInfoIndex
            EndIf
            If nCueAutoStartTime >= 0
              ; debugMsg(sProcName, "bProcessThisCue=" + strB(bProcessThisCue))
            EndIf
          EndIf
          ; debugMsg(sProcName, "i=" + getCueLabel(i) + ", bProcessThisCue=" + strB(bProcessThisCue))
          If bProcessThisCue
            nCueAutoStartTime + M2T_getCueStartTime(nControllingCuePtr)
            ; debugMsg(sProcName, "M2T_getCueStartTime(" + getCueLabel(nControllingCuePtr) + ") returned " + ttszt(nCueAutoStartTime))
            ; debugMsgC(sProcName, "Cue=" + getCueLabel(i) + ", nCueAutoStartTime=" + ttszt(nCueAutoStartTime))
            ; debugMsgC(sProcName, "processing cue " + getCueLabel(i))
            nPrevSubAutoStartTime = 0
            nPrevSubLength = 0
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\bSubEnabled
                bProcessThisSub = #True
                nSubAutoStartTime = 0
                nRelStartTime = aSub(j)\nRelStartTime
                If nRelStartTime < 0 ; probably -2, which is the default value, where -2 means 'blank'
                  nRelStartTime = 0
                EndIf
                Select aSub(j)\nRelStartMode
                  Case #SCS_RELSTART_DEFAULT, #SCS_RELSTART_AS_CUE
                    nSubAutoStartTime = nRelStartTime
                  Case #SCS_RELSTART_AS_PREV_SUB
                    nSubAutoStartTime = nPrevSubAutoStartTime + nRelStartTime
                  Case #SCS_RELSTART_AE_PREV_SUB
                    nSubAutoStartTime = nPrevSubAutoStartTime + nPrevSubLength + nRelStartTime
                  Default
                    debugMsgC(sProcName, "aSub(" + getSubLabel(j) + ")\nRelStartMode=" + decodeRelStartMode(aSub(j)\nRelStartMode))
                    bProcessThisSub = #False
                EndSelect
                If bProcessThisSub
                  ; debugMsgC(sProcName, "Sub=" + getSubLabel(j) + ", nSubAutoStartTime=" + ttszt(nSubAutoStartTime))
                  nSubLength = getSubLength(j)
                  grM2T\nM2TMaxItem + 1
                  If grM2T\nM2TMaxItem > ArraySize(grM2T\aM2TItem())
                    ReDim grM2T\aM2TItem(grM2T\nM2TMaxItem+10)
                  EndIf
                  With grM2T\aM2TItem(grM2T\nM2TMaxItem)
                    \nControllingCuePtr = nControllingCuePtr
                    \nThisCuePtr = i
                    \nThisCueStartTime = nCueAutoStartTime
                    \nThisCueLength = getCueLength(i)
                    ; debugMsg(sProcName, "getCueLength(" + getCueLabel(i) + ") returned grM2T\aM2TItem(" + grM2T\nM2TMaxItem + ")\nThisCueLength=" + ttszt(\nThisCueLength))
                    \nOrigCueState = aCue(i)\nCueState
                    \nThisSubPtr = j
                    \nThisSubStartTime = nCueAutoStartTime + nSubAutoStartTime
                    \nThisSubLength = nSubLength
                    \sThisSubType = aSub(j)\sSubType
                    \bFirstSubForCue = bFirstSubForCue
                    If aSub(j)\bSubTypeHasAuds
                      M2T_calcAudRelStartTimes(j)
                      \nThisAudPtr = aSub(j)\nFirstAudIndex
                      \nThisAudStartTime = \nThisSubStartTime
                    Else
                      \nThisAudPtr = -1
                      \nThisAudStartTime = 0
                    EndIf
                    debugMsgC(sProcName, "ADDED grM2T\aM2TItem(" + grM2T\nM2TMaxItem + ")\nControllingCuePtr=" + getCueLabel(\nControllingCuePtr) + ", \nThisCuePtr=" + getCueLabel(\nThisCuePtr) + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) +
                                         ", \sThisSubType=" + \sThisSubType + ", \nThisSubStartTime=" + ttszt(\nThisSubStartTime))
                  EndWith
                  nPrevSubAutoStartTime = nSubAutoStartTime
                  nPrevSubLength = nSubLength
                  bFirstSubForCue = #False
                EndIf ; EndIf bProcessThisSub
              EndIf ; EndIf aSub(j)\bSubEnabled
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf ; EndIf bProcessThisCue
        EndIf ; EndIf aCue(i)\bCueEnabled
      Next i
    EndIf ; EndIf grM2T\aM2TItem(n)\bFirstSubForCue
    ; debugMsg(sProcName, "END OF LOOP nItemIndex=" + nItemIndex)
  Next nItemIndex
  
  grM2T\nM2TTotalLength = 0
  For nItemIndex = 0 To grM2T\nM2TMaxItem
    With grM2T\aM2TItem(nItemIndex)
      If \nThisSubLength = 0 And \sThisSubType = "U"
        \nThisSubLength = \nThisCueLength - (\nThisSubStartTime - \nThisCueStartTime)
      EndIf
      If (\nThisCueStartTime + \nThisCueLength) > grM2T\nM2TTotalLength
        grM2T\nM2TTotalLength = (\nThisCueStartTime + \nThisCueLength)
      EndIf
    EndWith
  Next nItemIndex
  
  debugMsgC(sProcName, "grM2T\nM2TMaxItem=" + grM2T\nM2TMaxItem + ", grM2T\nM2TTotalLength=" + ttszt(grM2T\nM2TTotalLength))
  For nItemIndex = 0 To grM2T\nM2TMaxItem
    With grM2T\aM2TItem(nItemIndex)
      debugMsgC(sProcName, "grM2T\aM2TItem(" + nItemIndex + ")\nControllingCuePtr=" + getCueLabel(\nControllingCuePtr) +
                           ", \nThisCuePtr=" + getCueLabel(\nThisCuePtr) +
                           ", \nThisCueStartTime=" + ttszt(\nThisCueStartTime) +
                           ", \nThisCueLength=" + ttszt(\nThisCueLength) +
                           ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) +
                           ", \nThisSubStartTime=" + ttszt(\nThisSubStartTime) +
                           ", \nThisSubLength=" + ttszt(\nThisSubLength) +
                           ", \sThisSubType=" + \sThisSubType +
                           ", \bFirstSubForCue=" + strB(\bFirstSubForCue))
    EndWith
  Next nItemIndex
  
  For nItemIndex = 0 To grM2T\nM2TMaxItem
    With grM2T\aM2TItem(nItemIndex)
      Select \sThisSubType
        Case "A", "F", "L", "M", "S", "U" ; see also M2T_btnMoveToTimeApply_Click()
          Continue
        Default
          bError = #True
          grM2T\sM2TErrorMsg = LangPars("Errors", "M2TBadSubType", getCueLabel(pCuePtr), getSubLabel(\nThisSubPtr), decodeSubTypeL(\sThisSubType, \nThisSubPtr))
          Break
      EndSelect
    EndWith
  Next nItemIndex
  
  debugMsgC(sProcName, #SCS_END + ", returning bError=" + strB(bError))
  
EndProcedure

Procedure M2T_adjustDependentCuesForMoveToTimeCue(pCuePtr, nTimeValue, bTrace=#True)
  PROCNAMECQ(pCuePtr)
  
  debugMsgC(sProcName, #SCS_START + ", nTimeValue=" + ttszt(nTimeValue))
  grM2T\nMoveToTime = nTimeValue
  
  If grM2T\nM2TMaxItem >= 0 And grM2T\nM2TPrimaryCuePtr = pCuePtr
    debugMsgC(sProcName, "PROCESS!!! nTimeValue=" + nTimeValue)
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_displayMoveToTimeInfo(bTrace=#True)
  PROCNAMEC()
  Protected h, n
  Protected nDispCuePtr, nDispSubPtr, nDispAudPtr
  Protected nM2TIndex
  
  debugMsgC(sProcName, #SCS_START)
  
  For h = 0 To gnMaxDispPanel
    nM2TIndex = -1
    With gaDispPanel(h)
      nDispCuePtr = \nDPCuePtr
      nDispSubPtr = \nDPSubPtr
      nDispAudPtr = \nDPAudPtr
    EndWith
    If nDispCuePtr >= 0
      For n = 0 To grM2T\nM2TMaxItem
        With grM2T\aM2TItem(n)
          If \nThisSubPtr = nDispSubPtr
            debugMsgC(sProcName, "h=" + h + ", grM2T\aM2TItem(" + n + ")\nThisSubPtr=" + getSubLabel(\nThisSubPtr))
            nM2TIndex = n
            Break
          EndIf
        EndWith
      Next n
    EndIf
    With gaPnlVars(h)
      If nM2TIndex = 0
        If getVisible(\cntMoveToTimePrimary) = #False
          setVisible(\cntMoveToTimePrimary, #True)
          setVisible(\lblMoveToTimeSecondary, #False)
          setVisible(\cntTransportCtls, #False)
        EndIf
      ElseIf nM2TIndex > 0
        If getVisible(\lblMoveToTimeSecondary) = #False
          setVisible(\lblMoveToTimeSecondary, #True)
          setVisible(\cntMoveToTimePrimary, #False)
          setVisible(\cntTransportCtls, #False)
        EndIf
      Else
        If getVisible(\cntMoveToTimePrimary) Or getVisible(\lblMoveToTimeSecondary)
          setVisible(\cntMoveToTimePrimary, #False)
          setVisible(\lblMoveToTimeSecondary, #False)
          setVisible(\cntTransportCtls, grOperModeOptions(gnOperMode)\bShowTransportControls)
        EndIf
      EndIf
      M2T_setOtherInfoPos(h)
    EndWith
  Next h
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_cancelMoveToTime(h)
  PROCNAMECP(h)
  Protected nAudPtr, nMoveToTime, nAbsPosition
  
  debugMsg(sProcName, #SCS_START)
  
  With gaPnlVars(h)
    If gaDispPanel(h)\bM2T_Active
      gaDispPanel(h)\bM2T_Active = #False
      nAudPtr = gaDispPanel(h)\nDPAudPtr
      If nAudPtr >= 0
        If aAud(nAudPtr)\nAudState <= #SCS_CUE_READY
          nAbsPosition = nMoveToTime + aAud(nAudPtr)\nAbsMin
          debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nAbsPosition + ", #True, #True)")
          reposAuds(nAudPtr, nAbsPosition, #True, #True)
        EndIf
      EndIf
      M2T_clearAllMoveToTimeInfo()
    EndIf
  EndWith
  M2T_clearCueInds()
  colorCueListEntries()
  
EndProcedure

Procedure M2T_cancelMoveToTimeDisplayIfActive()
  PROCNAMEC()
  Protected nDispPanel
  
  debugMsg(sProcName, #SCS_START)
  
  If grLicInfo\bM2TAvailable
    For nDispPanel = 0 To gnMaxDispPanel
      With gaPnlVars(nDispPanel)
        If gaDispPanel(nDispPanel)\bM2T_Active
          M2T_cancelMoveToTime(nDispPanel)
          Break ; only one display panel can have 'Move To Time' active, so can Break now
        EndIf
      EndWith
    Next nDispPanel
  EndIf
  
EndProcedure

Procedure M2T_clearAllMoveToTimeInfo()
  PROCNAMEC()
  Protected h
  
  debugMsg(sProcName, #SCS_START)
  
  For h = 0 To gnMaxDispPanel
    With gaPnlVars(h)
      If getVisible(\cntMoveToTimePrimary) Or getVisible(\lblMoveToTimeSecondary)
        setVisible(\cntMoveToTimePrimary, #False)
        setVisible(\lblMoveToTimeSecondary, #False)
        setVisible(\cntTransportCtls, grOperModeOptions(gnOperMode)\bShowTransportControls)
      EndIf
      M2T_setOtherInfoPos(h)
    EndWith
  Next h
  
  With grM2T
    \nM2TPrimaryCuePtr = -1
    \nM2TPrimarySubPtr = -1
    \nM2TPrimaryAudPtr = -1
    \nM2TMaxItem = -1
    \nMoveToTime = 0
    If IsGadget(gaPnlVars(0)\txtMoveToTime)
      SGT(gaPnlVars(0)\txtMoveToTime, "")
      M2T_setMoveToTimeSlider(0)
    EndIf
  EndWith
  
  ; We now need to ensure focus is no longer on an M2T gadget (eg especially not on \txtMoveToTime), because if focus is \txtMoveToTime
  ; then any subsequent use of Space, Esc, Alt+U, etc will not be processed as a main window shortcut, but will processed against the
  ; currently active gadget, eg \txtMoveToTime.
  ; The dummy string gadget WMN\txtDummy has been created to provide a suitable gadget.
  SAG(WMN\txtDummy)
  ; debugMsg0(sProcName, "GetActiveGadget()=" + getGadgetName(GetActiveGadget()))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_setMoveToTimeSlider(h)
  With gaPnlVars(h)
    If (grM2T\nMoveToTime >= 0) And (grM2T\nMoveToTime <= SLD_getMax(\sldMoveToTimePosition))
      SLD_setValue(\sldMoveToTimePosition, grM2T\nMoveToTime)
    EndIf
  EndWith
EndProcedure

Procedure M2T_txtMoveToTime_Validate(h)
  PROCNAMECP(h)
  Protected sMoveToTime.s
  Protected nMoveToTime, nMaxTime, sMsg.s
  
  debugMsg(sProcName, #SCS_START)
  
  If grM2T\nM2TMaxItem < 0
    ; User probably pressed Esc, and the M2T info has now been cleared by M2T_clearAllMoveToTimeInfo(), so treat as 'valid'
    ProcedureReturn #True
  EndIf
  
  With gaPnlVars(h)
    sMoveToTime = Trim(GGT(\txtMoveToTime))
    If validateTimeFieldT(sMoveToTime, GGT(\lblMoveToTimePrimary), #False, #False, 0, #True, #False, #True) = #False
      ProcedureReturn #False
    ElseIf GGT(\txtMoveToTime) <> gsTmpString
      SGT(\txtMoveToTime, gsTmpString)
    EndIf
    If sMoveToTime
      ; grM2T\nMoveToTime = stringToTime(sMoveToTime)
      nMoveToTime = stringToRelativeTime(sMoveToTime)
      nMaxTime = grM2T\nM2TTotalLength
      debugMsg(sProcName, "nMoveToTime=" + nMoveToTime + ", nMaxTime=" + nMaxTime + ", Abs(nMoveToTime)=" + Abs(nMoveToTime))
      If nMaxTime >= 0
        If nMoveToTime > nMaxTime
          sMsg = LangPars("Errors", "MustBeLessThan", Trim(GGT(\lblMoveToTimePrimary)) + " (" + timeToString(nMoveToTime) + ")", timeToString(nMaxTime + 1))
          debugMsg(sProcName, sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          ProcedureReturn #False
        ElseIf nMoveToTime < 0 And Abs(nMoveToTime) > nMaxTime
          sMsg = LangPars("Errors", "MustBeGreaterThan", Trim(GGT(\lblMoveToTimePrimary)) + " (" + timeToString(nMoveToTime, 0, #False, #True) + ")", timeToString((nMaxTime + 1)*-1, 0, #False, #True))
          debugMsg(sProcName, sMsg)
          scsMessageRequester(grText\sTextValErr, sMsg, #PB_MessageRequester_Error)
          ProcedureReturn #False
        EndIf
      EndIf
      If nMoveToTime >= 0
        grM2T\nMoveToTime = nMoveToTime
      ElseIf nMaxTime > 0
        grM2T\nMoveToTime = nMaxTime + nMoveToTime ; nb adding nMoveToTime because the value in this field is negative
      EndIf
    EndIf
    
    M2T_setMoveToTimeSlider(h)
    
  EndWith
  
  ProcedureReturn #True
  
EndProcedure

Procedure M2T_setSubCountDownIfReqd(nM2TItemIndex)
  PROCNAMEC()
  Protected nCuePtr, nControllingCuePtr, nSubPtr, qReqdStartTime, bCheckThisSub
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    debugMsg(sProcName, "grM2T\aM2TItem(" + nM2TItemIndex + ")\nThisCuePtr=" + getCueLabel(\nThisCuePtr) + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nControllingCuePtr=" + getCueLabel(\nControllingCuePtr))
    nCuePtr = \nThisCuePtr
    If nCuePtr >= 0
      debugMsg(sProcName, "aCue(" + getCueLabel(nCuePtr) + ")\nCueState=" + decodeCueState(aCue(nCuePtr)\nCueState))
      If aCue(nCuePtr)\nCueState >= #SCS_CUE_FADING_IN
        bCheckThisSub = #True
      EndIf
    EndIf
    If bCheckThisSub = #False
      nControllingCuePtr = \nControllingCuePtr
      If nControllingCuePtr >= 0 And nCuePtr >= 0
        debugMsg(sProcName, "aCue(" + getCueLabel(nControllingCuePtr) + ")\nCueState=" + decodeCueState(aCue(nControllingCuePtr)\nCueState) +
                            ", aCue(" + getCueLabel(nCuePtr) + ")\nActivationMethodReqd=" + decodeActivationMethod(aCue(nCuePtr)\nActivationMethodReqd))
        If aCue(nControllingCuePtr)\nCueState >= #SCS_CUE_READY
          Select aCue(nCuePtr)\nActivationMethodReqd
            Case #SCS_ACMETH_AUTO, #SCS_ACMETH_AUTO_PLUS_CONF
              Select aCue(nCuePtr)\nAutoActPosn
                Case #SCS_ACPOSN_AE
                  ; no action
                Case #SCS_ACPOSN_AS, #SCS_ACPOSN_BE
                  bCheckThisSub = #True
                Default
                  ; no action
              EndSelect
          EndSelect
        EndIf
      EndIf
    EndIf
    If bCheckThisSub
      nSubPtr = \nThisSubPtr
      If nSubPtr >= 0
        If aSub(nSubPtr)\nSubStart <> #SCS_SUBSTART_OCM
          debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nSubState=" + decodeCueState(aSub(nSubPtr)\nSubState))
          If aSub(nSubPtr)\nSubState < #SCS_CUE_FADING_IN
            qReqdStartTime = gqTimeNow + \nThisSubStartTime - grM2T\nMoveToTime
            debugMsg(sProcName, "calling setSubToCountDown(" + getSubLabel(nSubPtr) + ", " + traceTime(qReqdStartTime) + ")")
            setSubToCountDown(nSubPtr, qReqdStartTime)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeA(nM2TItemIndex) ; Video/Image sub-cue
  PROCNAMECA(grM2T\aM2TItem(nM2TItemIndex)\nThisAudPtr)
  Protected k, nAudPtr, nSubPtr, nReqdPosition, nReqdAbsPosition
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime)
    If grM2T\nMoveToTime >= \nThisSubStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisSubStartTime
      debugMsg(sProcName, "nReqdPosition=" + nReqdPosition)
      nAudPtr = aSub(nSubPtr)\nFirstPlayIndex
      debugMsg(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\nFirstPlayIndex=" + getAudLabel(aSub(nSubPtr)\nFirstPlayIndex))
      k = nAudPtr
      While k >= 0
        debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudCalcRelStartTime=" + aAud(k)\nAudCalcRelStartTime)
        If aAud(k)\nAudCalcRelStartTime < nReqdPosition
          nAudPtr = k
        Else
          Break
        EndIf
        k = aAud(k)\nNextPlayIndex
      Wend  
      nReqdAbsPosition = nReqdPosition + aAud(nAudPtr)\nAbsMin - aAud(nAudPtr)\nAudCalcRelStartTime
      debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAbsMin=" + aAud(nAudPtr)\nAbsMin + ", \nAudCalcRelStartTime=" + aAud(nAudPtr)\nAudCalcRelStartTime + ", nReqdAbsPosition=" + nReqdAbsPosition)
      If nReqdAbsPosition <= aAud(nAudPtr)\nAbsMax
        debugMsg(sProcName, "calling playAud(" + getAudLabel(nAudPtr) + ")")
        playAud(nAudPtr)
        ; In call to reposAuds(), do NOT set bResyncOtherCues because this action is automatically performed during the M2T apply process,
        ; and to set bResyncOtherCues #True would incorrectly calculate other start times.
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nReqdAbsPosition + ", #True, #False, " + decodeVidPicTarget(aAud(nAudPtr)\nAudVidPicTarget) + ", #True)")
        reposAuds(nAudPtr, nReqdAbsPosition, #True, #False, aAud(nAudPtr)\nAudVidPicTarget, #True)
        ; Need to call getChannelAttributes() so that appropriate fields will be updated for PNL_updateDisplayPanel()
        debugMsg(sProcName, "calling getChannelAttributes(" + getAudLabel(nAudPtr) + ")")
        getChannelAttributes(nAudPtr)
        aAud(nAudPtr)\nAudState = #SCS_CUE_PLAYING ; will be changed to 'paused' by call to processPauseResumeAll() in M2T_btnMoveToTimeApply_Click(), but must NOT be 'paused' or 'ready' on calling processPauseResumeAll()
      Else
        debugMsg(sProcName, "calling closeAud(" + getAudLabel(nAudPtr) + ")")
        closeAud(nAudPtr)
        debugMsg(sProcName, "calling endOfAud(" + getAudLabel(nAudPtr) + ", " + decodeCueState(#SCS_CUE_COMPLETED) + ")")
        endOfAud(nAudPtr, #SCS_CUE_COMPLETED)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeF(nM2TItemIndex) ; Audio File sub-cue
  PROCNAMECA(grM2T\aM2TItem(nM2TItemIndex)\nThisAudPtr)
  Protected nAudPtr, nSubPtr, nReqdPosition, nReqdAbsPosition
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    nAudPtr = \nThisAudPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime + ", \nThisAudStartTime=" + \nThisAudStartTime)
    If grM2T\nMoveToTime >= \nThisAudStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisAudStartTime
      nReqdAbsPosition = nReqdPosition + aAud(nAudPtr)\nAbsMin
      If nReqdAbsPosition <= aAud(nAudPtr)\nAbsMax
        ; In call to reposAuds(), do NOT set bResyncOtherCues because this action is automatically performed during the M2T apply process,
        ; and to set bResyncOtherCues #True would incorrectly calculate other start times.
        debugMsg(sProcName, "calling reposAuds(" + getAudLabel(nAudPtr) + ", " + nReqdAbsPosition + ", #True, #False, #SCS_VID_PIC_TARGET_NONE, #True)")
        reposAuds(nAudPtr, nReqdAbsPosition, #True, #False, #SCS_VID_PIC_TARGET_NONE, #True)
        ; Changed 30Mar2021 11.8.4.1aj
        ; debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(nAudPtr) + ", " + grM2T\nMoveToTime + ")")
        ; doLvlPtRun(nAudPtr, grM2T\nMoveToTime)
        debugMsg(sProcName, "calling doLvlPtRun(" + getAudLabel(nAudPtr) + ", " + nReqdAbsPosition + ")")
        doLvlPtRun(nAudPtr, nReqdAbsPosition)
        ; End changed 30Mar2021 11.8.4.1aj
        ; Delay for at least the channel slide time used in calls to BASS_ChannelSlideAttribute() in doLvlPtRun(), so that getChannelAttributes() will get the final level/pan of the slide(s)
        Delay(gnTimerInterval+20)
        ; Need to call getChannelAttributes() so that appropriate fields will be updated for PNL_updateDisplayPanel()
        debugMsg(sProcName, "calling getChannelAttributes(" + getAudLabel(nAudPtr) + ")")
        getChannelAttributes(nAudPtr)
        aAud(nAudPtr)\nAudState = #SCS_CUE_PLAYING ; will be changed to 'paused' by call to processPauseResumeAll() in M2T_btnMoveToTimeApply_Click(), but must NOT be 'paused' or 'ready' on calling processPauseResumeAll()
        aAud(nAudPtr)\qTimeAudStarted = gqTimeNow - (grM2T\nMoveToTime - \nThisAudStartTime)
        aSub(nSubPtr)\qTimeSubStarted = aAud(nAudPtr)\qTimeAudStarted
        aSub(nSubPtr)\bTimeSubStartedSet = #True
      Else
        debugMsg(sProcName, "calling closeAud(" + getAudLabel(nAudPtr) + ")")
        closeAud(nAudPtr)
        debugMsg(sProcName, "calling endOfAud(" + getAudLabel(nAudPtr) + ", " + decodeCueState(#SCS_CUE_COMPLETED) + ")")
        endOfAud(nAudPtr, #SCS_CUE_COMPLETED)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeL(nM2TItemIndex) ; Level Change sub-cue
  PROCNAMECS(grM2T\aM2TItem(nM2TItemIndex)\nThisSubPtr)
  Protected nSubPtr, nReqdPosition
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime)
    If grM2T\nMoveToTime >= \nThisSubStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisSubStartTime
      debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubDuration=" + aSub(nSubPtr)\nSubDuration)
      If nReqdPosition <= aSub(nSubPtr)\nSubDuration
        playSubTypeL(nSubPtr, #False)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - (grM2T\nMoveToTime - \nThisSubStartTime)
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\qTimeSubStarted=" + traceTime(aSub(nSubPtr)\qTimeSubStarted))
      Else ; nReqdPosition > aSub(nSubPtr)\nSubDuration
        playSubTypeL(nSubPtr, #False)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - aSub(nSubPtr)\nSubDuration
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "calling SC_SubTypeL(" + getSubLabel(nSubPtr) + ")")
        SC_SubTypeL(nSubPtr)
        debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ")")
        closeSub(nSubPtr)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeM(nM2TItemIndex) ; Control Send sub-cue
  PROCNAMECS(grM2T\aM2TItem(nM2TItemIndex)\nThisSubPtr)
  Protected nSubPtr, nReqdPosition
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime)
    If grM2T\nMoveToTime >= \nThisSubStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisSubStartTime
      debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubDuration=" + aSub(nSubPtr)\nSubDuration)
      If nReqdPosition <= aSub(nSubPtr)\nSubDuration
        aSub(nSubPtr)\nSubPosition = nReqdPosition
        playSubTypeM(nSubPtr, #False, -1, #True) ; NB bMayBypassSendingForM2T set #True
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - (grM2T\nMoveToTime - \nThisSubStartTime)
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\qTimeSubStarted=" + traceTime(aSub(nSubPtr)\qTimeSubStarted))
      Else ; nReqdPosition > aSub(nSubPtr)\nSubDuration
        playSubTypeM(nSubPtr, #False, -1, #True) ; NB bMayBypassSendingForM2T set #True
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - aSub(nSubPtr)\nSubDuration
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "calling SC_SubTypeM(" + getSubLabel(nSubPtr) + ")")
        SC_SubTypeM(nSubPtr)
        debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ")")
        closeSub(nSubPtr)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeS(nM2TItemIndex) ; SFR sub-cue
  PROCNAMECS(grM2T\aM2TItem(nM2TItemIndex)\nThisSubPtr)
  Protected nSubPtr, nReqdPosition
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime)
    If grM2T\nMoveToTime >= \nThisSubStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisSubStartTime
      debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\nSubDuration=" + aSub(nSubPtr)\nSubDuration)
      If nReqdPosition <= aSub(nSubPtr)\nSubDuration
        aSub(nSubPtr)\nSubPosition = nReqdPosition
        playSubTypeS(nSubPtr, #False, #False, -1)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - (grM2T\nMoveToTime - \nThisSubStartTime)
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\qTimeSubStarted=" + traceTime(aSub(nSubPtr)\qTimeSubStarted))
      Else ; nReqdPosition > aSub(nSubPtr)\nSubDuration
        playSubTypeS(nSubPtr, #False, #False, -1)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - aSub(nSubPtr)\nSubDuration
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "calling SC_SubTypeM(" + getSubLabel(nSubPtr) + ")")
        SC_SubTypeS(nSubPtr)
        debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ")")
        closeSub(nSubPtr)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_processSubTypeU(nM2TItemIndex) ; MTC/LTC sub-cue
  PROCNAMECS(grM2T\aM2TItem(nM2TItemIndex)\nThisSubPtr)
  Protected nSubPtr, nReqdPosition, nThisSubDuration
  
  debugMsg(sProcName, #SCS_START + ", nM2TItemIndex=" + nM2TItemIndex)
  
  With grM2T\aM2TItem(nM2TItemIndex)
    nSubPtr = \nThisSubPtr
    debugMsg(sProcName, "grM2T\nMoveToTime=" + grM2T\nMoveToTime + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr) + ", \nThisSubStartTime=" + \nThisSubStartTime)
    If grM2T\nMoveToTime >= \nThisSubStartTime
      nReqdPosition = grM2T\nMoveToTime - \nThisSubStartTime
      nThisSubDuration = \nThisSubLength
      If nReqdPosition <= nThisSubDuration
        aSub(nSubPtr)\nSubPosition = nReqdPosition
        playSubTypeU(nSubPtr, #False, #True)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - (grM2T\nMoveToTime - \nThisSubStartTime)
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "nReqdPosition=" + nReqdPosition + ", aSub(" + getSubLabel(nSubPtr) + ")\qTimeSubStarted=" + traceTime(aSub(nSubPtr)\qTimeSubStarted))
      Else ; nReqdPosition > nThisSubDuration
        playSubTypeU(nSubPtr, #False, #True)
        aSub(nSubPtr)\qTimeSubStarted = gqTimeNow - nThisSubDuration
        aSub(nSubPtr)\bTimeSubStartedSet = #True
        debugMsg(sProcName, "calling SC_SubTypeU(" + getSubLabel(nSubPtr) + ")")
        SC_SubTypeU(nSubPtr)
        debugMsg(sProcName, "calling closeSub(" + getSubLabel(nSubPtr) + ")")
        closeSub(nSubPtr)
      EndIf
    Else
      debugMsg(sProcName, "calling M2T_setSubCountDownIfReqd(" + nM2TItemIndex + ")")
      M2T_setSubCountDownIfReqd(nM2TItemIndex)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_btnMoveToTimeApply_Click(h)
  PROCNAMECP(h)
  Protected bLockedMutex
  Protected nItemIndex, nThisSubPtr, nDispPanel, nPrevCuePtr
  Protected qEarliestTimeStarted.q, bEarliestTimeStartedSet
  
  debugMsg(sProcName, #SCS_START)
  
  LockCueListMutex(150)
  grM2T\bProcessingApplyMoveToTime = #True
  
  If gbGlobalPause = #False
    gqTimeNow = ElapsedMilliseconds()
    debugMsg(sProcName, "grM2T\nM2TMaxItem=" + grM2T\nM2TMaxItem)
    nPrevCuePtr = -1
    qEarliestTimeStarted = 0
    bEarliestTimeStartedSet = #False
    For nItemIndex = 0 To grM2T\nM2TMaxItem
      With grM2T\aM2TItem(nItemIndex)
        ; debugMsg(sProcName, "grM2T\aM2TItem(" + nItemIndex + ")\nThisCuePtr=" + getCueLabel(\nThisCuePtr) + ", \nThisSubPtr=" + getSubLabel(\nThisSubPtr))
        If \nThisCuePtr >= 0 And \nThisCuePtr <> nPrevCuePtr
          If nPrevCuePtr >= 0
            If aCue(nPrevCuePtr)\bTimeCueStartedSet = #False And bEarliestTimeStartedSet
              aCue(nPrevCuePtr)\qTimeCueStarted = qEarliestTimeStarted
              aCue(nPrevCuePtr)\bTimeCueStartedSet = #True
              aCue(nPrevCuePtr)\qTimeCueLastStarted = qEarliestTimeStarted ; Added 15Dec2022 11.10.0ac
              debugMsg(sProcName, "aCue(" + getCueLabel(nPrevCuePtr) + ")\qTimeCueStarted=" + traceTime(aCue(nPrevCuePtr)\qTimeCueStarted))
            EndIf
            setCueState(nPrevCuePtr, #True)
          EndIf
          nPrevCuePtr = \nThisCuePtr
          qEarliestTimeStarted = 0
          bEarliestTimeStartedSet = #False
        EndIf
        debugMsg(sProcName, "grM2T\aM2TItem(" + nItemIndex + ")\nThisSubPtr=" + getSubLabel(\nThisSubPtr))
        nThisSubPtr = \nThisSubPtr
        debugMsg(sProcName, "aSub(" + getSubLabel(nThisSubPtr) + ")\sSubType=" + aSub(nThisSubPtr)\sSubType)
        Select aSub(nThisSubPtr)\sSubType
          Case "A"
            M2T_processSubTypeA(nItemIndex)
          Case "F"
            M2T_processSubTypeF(nItemIndex)
          Case "L"
            M2T_processSubTypeL(nItemIndex)
          Case "M"
            M2T_processSubTypeM(nItemIndex)
          Case "S"
            M2T_processSubTypeS(nItemIndex)
          Case "U"
            M2T_processSubTypeU(nItemIndex)
        EndSelect
        ; see also checks on valid subtypes in M2T_loadMoveToTimeInfo()
        If aSub(nThisSubPtr)\bTimeSubStartedSet
          If aSub(nThisSubPtr)\qTimeSubStarted < qEarliestTimeStarted Or bEarliestTimeStartedSet = #False
            qEarliestTimeStarted = aSub(nThisSubPtr)\qTimeSubStarted
            bEarliestTimeStartedSet = #True
          EndIf
        EndIf
      EndWith
    Next nItemIndex
    If nPrevCuePtr >= 0
      If aCue(nPrevCuePtr)\bTimeCueStartedSet = #False And bEarliestTimeStartedSet
        aCue(nPrevCuePtr)\qTimeCueStarted = qEarliestTimeStarted
        aCue(nPrevCuePtr)\bTimeCueStartedSet = #True
        aCue(nPrevCuePtr)\qTimeCueLastStarted = qEarliestTimeStarted ; Added 15Dec2022 11.10.0ac
        debugMsg(sProcName, "aCue(" + getCueLabel(nPrevCuePtr) + ")\qTimeCueStarted=" + traceTime(aCue(nPrevCuePtr)\qTimeCueStarted))
      EndIf
      setCueState(nPrevCuePtr, #True)
    EndIf
    
    debugMsg(sProcName, "calling processPauseResumeAll()")
    processPauseResumeAll()
    
    For nItemIndex = 0 To grM2T\nM2TMaxItem
      With grM2T\aM2TItem(nItemIndex)
        ; debugMsg(sProcName, "grM2T\aM2TItem(" + nItemIndex + ")\nThisSubPtr=" + getSubLabel(\nThisSubPtr))
        nThisSubPtr = \nThisSubPtr
        ; debugMsg(sProcName, "aSub(" + getSubLabel(nThisSubPtr) + ")\nSubState=" + decodeCueState(aSub(nThisSubPtr)\nSubState))
        If aSub(nThisSubPtr)\nSubState < #SCS_CUE_COMPLETED
          Select aSub(nThisSubPtr)\sSubType
            Case "L"
              debugMsg(sProcName, "calling SC_SubTypeL(" + getSubLabel(nThisSubPtr) + ")")
              SC_SubTypeL(nThisSubPtr)
            Case "M"
              debugMsg(sProcName, "calling SC_SubTypeM(" + getSubLabel(nThisSubPtr) + ")")
              SC_SubTypeM(nThisSubPtr)
            Case "U"
              debugMsg(sProcName, "calling SC_SubTypeU(" + getSubLabel(nThisSubPtr) + ")")
              SC_SubTypeU(nThisSubPtr)
          EndSelect
        EndIf
      EndWith
    Next nItemIndex
    
    M2T_setCueInds()
    
  EndIf ; EndIf gbGlobalPause = #False
  
  For nDispPanel = 0 To gnMaxDispPanel
    With gaPnlVars(nDispPanel)
      If gaDispPanel(nDispPanel)\bM2T_Active
        gaDispPanel(nDispPanel)\bM2T_Active = #False
        Break ; only one display panel can have 'Move To Time' active, so can Break now
      EndIf
    EndWith
  Next nDispPanel
  
  gaPnlVars(h)\nLastMoveToTime = grM2T\nMoveToTime ; Must save this BEFORE calling M2T_clearAllMoveToTimeInfo() as that clears grM2T\nMoveToTime
  gaPnlVars(h)\nLastM2TPrimaryCuePtr =  grM2T\nM2TPrimaryCuePtr
  
  M2T_clearAllMoveToTimeInfo()
  
  colorCueListEntries()
  PNL_loadDispPanels()
  
  grM2T\bProcessingApplyMoveToTime = #False
  UnlockCueListMutex()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_btnMoveToTimeCancel_Click(h)
  PROCNAMECP(h)
  
  debugMsg(sProcName, #SCS_START)
  
  M2T_cancelMoveToTime(h)
  
EndProcedure

Procedure M2T_setOtherInfoPos(h)
  PROCNAMECP(h)
  Protected nLeft, nWidth
  
  With gaPnlVars(h)
    If getVisible(\cntMoveToTimePrimary)
      ; primary M2T display panel
      nLeft = GadgetX(\cntMoveToTimePrimary) + GadgetWidth(\cntMoveToTimePrimary)
      
    ElseIf getVisible(\lblMoveToTimeSecondary)
      ; secondary M2T display panel
      nLeft = GadgetX(\lblMoveToTimeSecondary) + GadgetWidth(\lblMoveToTimeSecondary)
      
    Else
      ; non-M2T display panel
      nLeft = GadgetX(\cntTransportCtls) + GadgetWidth(\cntTransportCtls)
      
    EndIf
    nLeft + gnGap2
    nWidth = GadgetX(\cntFaderAndPanCtls) - nLeft
    If GadgetX(\cvsPnlOtherInfo) <> nLeft Or GadgetWidth(\cvsPnlOtherInfo) <> nWidth
      ResizeGadget(\cvsPnlOtherInfo, nLeft, #PB_Ignore, nWidth, #PB_Ignore)
      PNL_drawOtherInfoText(h) ; nb need to redraw a canvas after resizing or it is cleared and displayed as a filled white box
    EndIf
  EndWith
  
EndProcedure

Procedure M2T_calcAudRelStartTimes(pSubPtr)
  ; See also calcPLTotalTime()
  PROCNAMECS(pSubPtr)
  Protected k, nRelStartTime
  
  debugMsg(sProcName, #SCS_START)
  
  If aSub(pSubPtr)\bSubTypeAorP
    k = aSub(pSubPtr)\nFirstPlayIndex
    While k >= 0
      With aAud(k)
        \nAudCalcRelStartTime = nRelStartTime
        nRelStartTime + \nCueDuration
        debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudCalcRelStartTime=" + ttszt(\nAudCalcRelStartTime) + ", \nCueDuration=" + ttszt(\nCueDuration) +
                            ", \nPLTransType=" + decodeTransType(\nPLTransType) + ", \nPLTransTime=" + \nPLTransTime + ", nRelStartTime=" + ttszt(nRelStartTime))
        Select \nPLTransType
          Case #SCS_TRANS_XFADE, #SCS_TRANS_MIX
            nRelStartTime - \nPLTransTime
          Case #SCS_TRANS_WAIT
            nRelStartTime + \nPLTransTime
        EndSelect
        k = \nNextPlayIndex
      EndWith
    Wend
  EndIf ; EndIf aSub(pSubPtr)\bSubTypeAorP
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure M2T_sldMoveToTimePosition_Common(h, nSliderEventType)
  PROCNAMEC()
  Protected nSliderHandle, nTimeValue
  
  nSliderHandle = gaPnlVars(h)\sldMoveToTimePosition
  nTimeValue = SLD_getValue(nSliderHandle)
  If nSliderEventType <> #SCS_SLD_EVENT_SCROLL
    debugMsg(sProcName, "nSliderEventType=" + SLD_decodeEvent(nSliderEventType) + ", nTimeValue=" + ttszt(nTimeValue))
  EndIf
  M2T_displayMoveToTimeValueIfActive(h, nTimeValue, #False, #False)
  
EndProcedure

Procedure M2T_setLinkedAudInfo(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  With grMTCSendControl
    \nMTCLinkedToAudPtr = pAudPtr
    ;     \nMTCChannelNo = getBassChannelForAud(pAudPtr)
    ;     debugMsg(sProcName, "grMTCSendControl\nMTCLinkedToAudPtr=" + getAudLabel(\nMTCLinkedToAudPtr) + ", \nMTCChannelNo=" + decodeHandle(\nMTCChannelNo))
    \nMTCLinkedAudChannel = getBassChannelForAud(pAudPtr)
    debugMsg(sProcName, "grMTCSendControl\nMTCLinkedToAudPtr=" + getAudLabel(\nMTCLinkedToAudPtr) + ", \nMTCLinkedAudChannel=" + decodeHandle(\nMTCLinkedAudChannel))
  EndWith
  
EndProcedure

Procedure M2T_clearCueInds()
  PROCNAMEC()
  Protected i
  
  For i = 1 To gnLastCue
    aCue(i)\bM2TCue = #False
  Next i
  grM2T\bM2TCueListColoringReqd = #False
  
EndProcedure

Procedure M2T_setCueInds()
  PROCNAMEC()
  Protected nIndex, nCuePtr
  
  M2T_clearCueInds()
  For nIndex = 0 To grM2T\nM2TMaxItem
    nCuePtr = grM2T\aM2TItem(nIndex)\nThisCuePtr
    If nCuePtr > 0
      aCue(nCuePtr)\bM2TCue = #True
      grM2T\bM2TCueListColoringReqd = #True
    EndIf
  Next nIndex
  
EndProcedure

; EOF