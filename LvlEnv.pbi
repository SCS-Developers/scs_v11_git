; file: LvlEnv.pbi

EnableExplicit

Procedure addOneLevelPoint(pAudPtr, nPointTime, nPointType)
  PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex
  
  ; debugMsg(sProcName, #SCS_START + ", nPointTime=" + nPointTime + ", nPointType=" + decodeLevelPointType(nPointType))
  
  nLevelPointIndex = -1
  If pAudPtr >= 0
    
    With aAud(pAudPtr)
      \nMaxLevelPoint + 1
      nLevelPointIndex = \nMaxLevelPoint
      If ArraySize(\aPoint()) < nLevelPointIndex
        ReDim \aPoint(nLevelPointIndex)
      EndIf
      \aPoint(nLevelPointIndex) = grLevelPointDef
    EndWith
    
    With aAud(pAudPtr)\aPoint(nLevelPointIndex)
      gnUniquePointId + 1
      \nPointId = gnUniquePointId
      \nPointTime = nPointTime
      \nPointType = nPointType
      setLevelPointDesc(pAudPtr, nLevelPointIndex)
    EndWith
    
    ; debugMsg(sProcName, "a1 calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
    ; listLevelPoints(pAudPtr)
    sortLevelPointsArray(pAudPtr)
    ; debugMsg(sProcName, "a2 calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
    ; listLevelPoints(pAudPtr)
    
    nLevelPointIndex = getLevelPointIndexForType(pAudPtr, nPointType, nPointTime)
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning nLevelPointIndex=" + nLevelPointIndex)
  
  ProcedureReturn nLevelPointIndex
EndProcedure

Procedure addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev.s, sTracks.s, bReqdItemInclude, fReqdItemRelDBLevel.f, fReqdItemPan.f)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected nDevNo
  
  ; debugMsg(sProcName, #SCS_START + ", nLevelPointIndex=" + nLevelPointIndex + ", sLogicalDev=" + sLogicalDev + ", sTracks=" + sTracks +
  ;                     ", bReqdItemInclude=" + strB(bReqdItemInclude) + ", fReqdItemRelDBLevel=" + StrF(fReqdItemRelDBLevel,2))
  
  nItemIndex = -1
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    
    With aAud(pAudPtr)\aPoint(nLevelPointIndex)
      \nPointMaxItem + 1
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointMaxItem=" + \nPointMaxItem)
      nItemIndex = \nPointMaxItem
      If ArraySize(\aItem()) < nItemIndex
        ReDim \aItem(nItemIndex)
      EndIf
      \aItem(nItemIndex) = grLevelPointItemDef
    EndWith
    
    nDevNo = getAudDevNoForLogicalDev(pAudPtr, sLogicalDev, sTracks)
    With aAud(pAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)
      \sItemLogicalDev = sLogicalDev
      \sItemTracks = sTracks
      \nItemDevNo = nDevNo
      ; debugMsg(sProcName, "getAudDevNoForLogicalDev(" + getAudLabel(pAudPtr) + ", " + sLogicalDev + ", " + sTracks + ") returned \nItemDevNo=" + \nItemDevNo)
      \nItemGraphChannels = getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sLogicalDev)
      \bItemInclude = bReqdItemInclude
      \fItemRelDBLevel = fReqdItemRelDBLevel
      \fItemPan = fReqdItemPan
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\fItemPan))
    EndWith
    
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning nItemIndex=" + nItemIndex)
  
  ProcedureReturn nItemIndex
EndProcedure

Procedure removeOneLevelPoint(pAudPtr, nLevelPointIndex)
  PROCNAMECA(pAudPtr)
  Protected n
  
  ; debugMsg(sProcName, #SCS_START + ", nLevelPointIndex=" + nLevelPointIndex)
  
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    With aAud(pAudPtr)
      For n = (nLevelPointIndex + 1) To \nMaxLevelPoint
        \aPoint(n-1) = \aPoint(n)
      Next n
      \nMaxLevelPoint - 1
    EndWith
  EndIf
EndProcedure

Procedure addDBLevelPointItemsWithSameSettings(pAudPtr, nLevelPointIndex, fItemRelDBLevel.f, fItemPan.f)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected sLogicalDev.s, sTracks.s
  Protected nItemIndex
  Protected bItemInclude = #True
  
  ; debugMsg(sProcName, #SCS_START)
  
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    With aAud(pAudPtr)
      For d = \nFirstDev To \nLastDev
        sLogicalDev = \sLogicalDev[d]
        If sLogicalDev
          sTracks = \sTracks[d]
          nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
          If nItemIndex >= 0
            \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel = fItemRelDBLevel
          Else
            ; debugMsg(sProcName, "calling addOneDBLevelPointItem(...)")
            nItemIndex = addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bItemInclude, fItemRelDBLevel, fItemPan)
          EndIf
        EndIf
      Next d
    EndWith
  EndIf
EndProcedure

Procedure addLevelPointItemsForNewDevice(pAudPtr, pDevNo)
  PROCNAMECA(pAudPtr)
  Protected sLogicalDev.s, sTracks.s
  Protected nLevelPointIndex, nItemIndex
  Protected nMaxLevelPoint
  Protected bReqdItemInclude
  Protected fReqdItemRelDBLevel.f
  Protected fReqdItemPan.f
  Protected bPanAvailable
  Protected nLvlPtLvlSel, nLvlPtPanSel
  
  debugMsg(sProcName, #SCS_START)
  
  ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
  ; listLevelPoints(pAudPtr)
  
  With aAud(pAudPtr)
    sLogicalDev = \sLogicalDev[pDevNo]
    bPanAvailable = getPanAvailableForLogicalDev(sLogicalDev)
    sTracks = \sTracks[pDevNo]
    nLvlPtLvlSel = \nLvlPtLvlSel
    nLvlPtPanSel = \nLvlPtPanSel
    nMaxLevelPoint = \nMaxLevelPoint
    debugMsg(sProcName, "\nMaxLevelPoint=" + Str(\nMaxLevelPoint) + ", \sLogicalDev[" + Str(pDevNo) + "]=" + \sLogicalDev[pDevNo])
    For nLevelPointIndex = 0 To nMaxLevelPoint
      nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
      debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + nItemIndex)
      If nItemIndex = -1
        ; item does not currently exist
        ; set defaults
        Select \aPoint(nLevelPointIndex)\nPointType
          Case #SCS_PT_STD
            bReqdItemInclude = grLevelPointItemDef\bItemInclude
          Default
            bReqdItemInclude = #True
        EndSelect
        fReqdItemRelDBLevel = grLevelPointItemDef\fItemRelDBLevel
        fReqdItemPan = grLevelPointItemDef\fItemPan
        Select nLvlPtLvlSel
          Case #SCS_LVLSEL_SYNC
            If \aPoint(nLevelPointIndex)\nPointMaxItem >= 0
              fReqdItemRelDBLevel = \aPoint(nLevelPointIndex)\aItem(0)\fItemRelDBLevel
            EndIf
        EndSelect
        If bPanAvailable
          Select nLvlPtPanSel
            Case #SCS_PANSEL_SYNC
              If \aPoint(nLevelPointIndex)\nPointMaxItem >= 0
                fReqdItemPan = \aPoint(nLevelPointIndex)\aItem(0)\fItemPan
              EndIf
          EndSelect
        EndIf
        debugMsg(sProcName, "calling addOneDBLevelPointItem(...)")
        addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bReqdItemInclude, fReqdItemRelDBLevel, fReqdItemPan)
      EndIf
    Next nLevelPointIndex
  EndWith
  
  ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
  ; listLevelPoints(pAudPtr)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setLevelPointDesc(pAudPtr, nLevelPointIndex)
  PROCNAMECA(pAudPtr)
  Protected sPointType.s
  Static sLevelPoint.s, sPanPoint.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sLevelPoint = Lang("WQF", "LevelPoint")
    sPanPoint = Lang("WQF", "PanPoint")
    bStaticLoaded = #True
  EndIf
  
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    With aAud(pAudPtr)\aPoint(nLevelPointIndex)
      Select \nPointType
        Case #SCS_PT_STD
          sPointType = timeToStringT(\nPointTime)
        Default
          sPointType = decodeLevelPointTypeL(\nPointType)
      EndSelect
      \sPointDesc = ReplaceString(sLevelPoint, "$1", sPointType)
      \sPanPointDesc = ReplaceString(sPanPoint, "$1", sPointType)
    EndWith
  EndIf
  
EndProcedure
  
Procedure setDerivedLevelPointInfo2(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nReqdPointTime
  Protected fReqdItemRelDBLevel.f
  Protected fReqdItemPan.f
  Protected bReqdItemInclude
  Protected bForceSetItemRelLevel
  Protected nLevelPointIndex, nItemIndex
  Protected nPrevLevelPointIndex, nPrevItemIndex
  Protected d
  Protected sLogicalDev.s, sTracks.s
  Protected Dim aPoint.tyLevelPoint(0)
  Protected nTmpIndex
  Protected bNewLevelPoint
  Protected nFirstItemIndex
  Protected nLvlPtLvlSel, nLvlPtPanSel
  Protected bSortArrayReqd
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START)
  
;   debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
;   listLevelPoints(pAudPtr)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      ; set item devno's
      setLevelPointItemDevNos(pAudPtr)
      
      fReqdItemPan = grLevelPointItemDef\fItemPan
      
      nLvlPtLvlSel = \nLvlPtLvlSel
      nLvlPtPanSel = \nLvlPtPanSel
      
      ; start by clearing out the existing 'unused' points to allow them to be re-created
      ; this helps handling movements to the 'start' and 'end' level points, which may also require changes to the 'unused_min' and 'unused_max' level points
      If \nMaxLevelPoint >= 0
        ReDim aPoint(\nMaxLevelPoint)
        nTmpIndex = -1
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          Select \aPoint(nLevelPointIndex)\nPointType
            Case #SCS_PT_UNUSED_BOF, #SCS_PT_UNUSED_EOF, #SCS_PT_UNUSED_MAX, #SCS_PT_UNUSED_MIN
              ; ignore
            Default
              ; keep
              nTmpIndex + 1
              aPoint(nTmpIndex) = \aPoint(nLevelPointIndex)
          EndSelect
        Next nLevelPointIndex
        \nMaxLevelPoint = -1
        For nLevelPointIndex = 0 To nTmpIndex
          \nMaxLevelPoint + 1
          \aPoint(nLevelPointIndex) = aPoint(nLevelPointIndex)
        Next nLevelPointIndex
      EndIf
      
      If \bAudPlaceHolder
        ProcedureReturn
      EndIf
      
      ; set times in existing level points where required
      For nLevelPointIndex = 0 To \nMaxLevelPoint
        Select \aPoint(nLevelPointIndex)\nPointType
          Case #SCS_PT_START
            \aPoint(nLevelPointIndex)\nPointTime = \nAbsStartAt
          Case #SCS_PT_FADE_IN
            If \nFadeInTime > 0
              \aPoint(nLevelPointIndex)\nPointTime = \nAbsStartAt + \nFadeInTime
            EndIf
          Case #SCS_PT_FADE_OUT
            If \nFadeOutTime > 0
              \aPoint(nLevelPointIndex)\nPointTime = \nAbsEndAt - \nFadeOutTime
            EndIf
          Case #SCS_PT_END
            \aPoint(nLevelPointIndex)\nPointTime = \nAbsEndAt
        EndSelect
      Next nLevelPointIndex
      
      ; create or set 'UNUSED' level points at START, if required
      ; nb use \nAbsStartAt, not \nAbsMin, because loops and level points are mutually exclusive
      If \nAbsStartAt > 1
        nReqdPointTime = 0
        nLevelPointIndex = getLevelPointIndexForTime(pAudPtr, nReqdPointTime)
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        Else
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_UNUSED_BOF)
          addDBLevelPointItemsWithSameSettings(pAudPtr, nLevelPointIndex, 0.0, 0)
        EndIf
        nReqdPointTime = \nAbsStartAt - 1
        nLevelPointIndex = getLevelPointIndexForTime(pAudPtr, nReqdPointTime)
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        Else
          debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_UNUSED_MIN)")
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_UNUSED_MIN)
          addDBLevelPointItemsWithSameSettings(pAudPtr, nLevelPointIndex, 0.0, 0)
        EndIf
      EndIf
      
      ; create or set START level point if required
      nReqdPointTime = \nAbsStartAt
      nLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_START)
      If nLevelPointIndex >= 0
        \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        bNewLevelPoint = #False
      Else
        debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_START)")
        nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_START)
        bNewLevelPoint = #True
      EndIf
      If nLevelPointIndex >= 0
        If \nFadeInTime > 0
          fReqdItemRelDBLevel = grLevels\nMinRelDBLevel
        Else
          fReqdItemRelDBLevel = 0.0
        EndIf
        For d = \nFirstDev To \nLastDev
          sLogicalDev = \sLogicalDev[d]
          If sLogicalDev
            sTracks = \sTracks[d]
            nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
            If nItemIndex >= 0
              If bNewLevelPoint
                \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
              EndIf
            Else
              debugMsgC(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                   ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
              nItemIndex = addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              ; nb pan may be reset later in this procedure
            EndIf
          EndIf
        Next d
      EndIf
      
      ; create, set or remove FADE-IN level point if required
      nLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_FADE_IN)
      If \nFadeInTime > 0
        ; debugMsg(sProcName, "fade in nLevelPointIndex=" + nLevelPointIndex + ", aAud(" + getAudLabel(pAudPtr) + ")\nFadeInTime=" + \nFadeInTime)
        nReqdPointTime = \nAbsStartAt + \nFadeInTime
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
          bNewLevelPoint = #False
        Else
          debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_FADE_IN)")
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_FADE_IN)
          bNewLevelPoint = #True
        EndIf
        If nLevelPointIndex >= 0
          fReqdItemRelDBLevel = 0.0
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
              If nItemIndex = -1
                ; new item
                bReqdItemInclude = #True  ; all devices must be included in a fade-in level point
                debugMsgC(sProcName, "calling addOneDBLevelPointItem(...)")
                nItemIndex = addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bReqdItemInclude, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
        EndIf
      Else
        If nLevelPointIndex >= 0
          ; remove fade-in level point as it's no longer required
          debugMsgC(sProcName, "calling removeOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + nLevelPointIndex + ") to remove fade-in level point")
          removeOneLevelPoint(pAudPtr, nLevelPointIndex)
        EndIf
      EndIf
      
      sortLevelPointsArray(pAudPtr)
      
      ; create or set FADE-OUT level point if required
      nLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_FADE_OUT)
      If \nFadeOutTime > 0
        debugMsgC(sProcName, "fade out nLevelPointIndex=" + nLevelPointIndex + ", aAud(" + getAudLabel(pAudPtr) + ")\nFadeOutTime=" + \nFadeOutTime)
        nReqdPointTime = \nAbsEndAt - \nFadeOutTime
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
          bNewLevelPoint = #False
        Else
          debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_FADE_OUT)")
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_FADE_OUT)
          bNewLevelPoint = #True
        EndIf
        If nLevelPointIndex >= 0
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
              If nItemIndex = -1
                ; new item
                nPrevLevelPointIndex = getPrevIncludedLevelPointIndex(pAudPtr, d, nReqdPointTime)
                If nPrevLevelPointIndex >= 0
                  fReqdItemRelDBLevel = grLevelPointItem\fItemRelDBLevel
                  fReqdItemPan = grLevelPointItem\fItemPan
                Else
                  fReqdItemRelDBLevel = 0.0
                  fReqdItemPan = 0
                EndIf
                bReqdItemInclude = #True  ; all devices must be included in a fade-out level point
                debugMsgC(sProcName, "calling addOneDBLevelPointItem(...)")
                nItemIndex = addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, bReqdItemInclude, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
        EndIf
      Else
        If nLevelPointIndex >= 0
          ; remove fade-out level point as it's no longer required
          debugMsgC(sProcName, "calling removeOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + nLevelPointIndex + ") to remove fade-out level point")
          removeOneLevelPoint(pAudPtr, nLevelPointIndex)
        EndIf
      EndIf
      
      sortLevelPointsArray(pAudPtr)
      
      ; create or set END level point if required
      nReqdPointTime = \nAbsEndAt
      nLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_END)
      If nLevelPointIndex >= 0
        \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        bNewLevelPoint = #False
      Else
        debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_END)")
        nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_END)
        bNewLevelPoint = #True
      EndIf
      debugMsgC(sProcName, "#SCS_PT_END nLevelPointIndex=" + nLevelPointIndex + ", bNewLevelPoint=" + strB(bNewLevelPoint) + ", \nFadeOutTime=" + \nFadeOutTime)
      If nLevelPointIndex >= 0
        For d = \nFirstDev To \nLastDev
          sLogicalDev = \sLogicalDev[d]
          If sLogicalDev
            sTracks = \sTracks[d]
            nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
            ; debugMsg(sProcName, "nItemIndex=" + nItemIndex)
            nPrevLevelPointIndex = getPrevIncludedLevelPointIndex(pAudPtr, d, nReqdPointTime)
            debugMsgC(sProcName, "d=" + d + ", sLogicalDev=" + sLogicalDev + ", nReqdPointTime=" + nReqdPointTime + ", nPrevLevelPointIndex=" + nPrevLevelPointIndex)
            
            If \nFadeOutTime > 0
              ; if fade-out time specified then 'end' level must be -INF
              fReqdItemRelDBLevel = grLevels\nMinRelDBLevel
            ElseIf (bNewLevelPoint = #False) And (nItemIndex >= 0)
              ; do not alter an existing relative dB level that the user has specified
              fReqdItemRelDBLevel = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel
            ElseIf nPrevLevelPointIndex >= 0
              ; use relative dB level of previous level point
              fReqdItemRelDBLevel = grLevelPointItem\fItemRelDBLevel
            Else
              ; if none of the above then no change to be applied in the level, ie relative level change is 0.0dB
              fReqdItemRelDBLevel = 0.0
            EndIf
            
            If (bNewLevelPoint = #False) And (nItemIndex >= 0)
              ; do not alter existing pan setting that the user has specified
              fReqdItemPan = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan
            ElseIf nPrevLevelPointIndex >= 0
              ; use pan setting of previous level point
              fReqdItemPan = grLevelPointItem\fItemPan
            Else
              ; if none of the above then pan center
              fReqdItemPan = 0
            EndIf
              
            If nItemIndex >= 0
              \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
              \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan = fReqdItemPan
            Else
              debugMsgC(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                   ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
              nItemIndex = addOneDBLevelPointItem(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
            EndIf
          EndIf
        Next d
      EndIf
      
      sortLevelPointsArray(pAudPtr)
      
      ; create or set 'UNUSED' level points at END, if required
      If (\nAbsEndAt + 1) < \nFileDuration
        nReqdPointTime = \nAbsEndAt + 1
        nLevelPointIndex = getLevelPointIndexForTime(pAudPtr, nReqdPointTime)
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        Else
          debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_UNUSED_MAX)")
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_UNUSED_MAX)
          addDBLevelPointItemsWithSameSettings(pAudPtr, nLevelPointIndex, 0.0, 0)
        EndIf
        nReqdPointTime = \nFileDuration
        nLevelPointIndex = getLevelPointIndexForTime(pAudPtr, nReqdPointTime)
        If nLevelPointIndex >= 0
          \aPoint(nLevelPointIndex)\nPointTime = nReqdPointTime
        Else
          debugMsgC(sProcName, "calling addOneLevelPoint(" + getAudLabel(pAudPtr) + ", " + timeToStringT(nReqdPointTime) + ", #SCS_PT_UNUSED_EOF)")
          nLevelPointIndex = addOneLevelPoint(pAudPtr, nReqdPointTime, #SCS_PT_UNUSED_EOF)
          addDBLevelPointItemsWithSameSettings(pAudPtr, nLevelPointIndex, 0.0, 0)
        EndIf
      EndIf
      
    EndWith
    
    ; set level point descriptions
    For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
      setLevelPointDesc(pAudPtr, nLevelPointIndex)
    Next nLevelPointIndex
    
    ; force pans to audio device pan where required
    With aAud(pAudPtr)
      If \nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
        ; debugMsg(sProcName, "calling setLvlPtPansAtAudDevPan(" + getAudLabel(pAudPtr) + ")")
        setLvlPtPansAtAudDevPan(pAudPtr)
      EndIf
    EndWith
    
    ; set item devno's
    setLevelPointItemDevNos(pAudPtr)
    
    ; sort level points (in time order)
    sortLevelPointsArray(pAudPtr)
    
;     debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
;     listLevelPoints(pAudPtr)
    
    ; 'sync' levels and pans where required
    ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nMaxLevelPoint=" + aAud(pAudPtr)\nMaxLevelPoint)
    For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(nLevelPointIndex)
        If nLvlPtLvlSel = #SCS_LVLSEL_SYNC
          ; sync levels
          nFirstItemIndex = -1
          For d = aAud(pAudPtr)\nFirstDev To aAud(pAudPtr)\nLastDev
            sLogicalDev = aAud(pAudPtr)\sLogicalDev[d]
            If sLogicalDev
              sTracks = aAud(pAudPtr)\sTracks[d]
              nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
              ; debugMsg(sProcName, "getLevelPointItemIndex(" + getAudLabel(pAudPtr) + ", " + nLevelPointIndex + ", " + sLogicalDev + ", " + sTracks + ") returned " + nItemIndex)
              If nItemIndex >= 0
                If nFirstItemIndex = -1
                  nFirstItemIndex = nItemIndex
                Else
                  \aItem(nItemIndex)\fItemRelDBLevel = \aItem(nFirstItemIndex)\fItemRelDBLevel
                  ; debugMsg(sProcName, "\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + StrF(\aItem(nItemIndex)\fItemRelDBLevel,2))
                EndIf
              EndIf
            EndIf
          Next d
        EndIf
        If nLvlPtPanSel = #SCS_PANSEL_SYNC
          ; sync pans
          nFirstItemIndex = -1
          For d = aAud(pAudPtr)\nFirstDev To aAud(pAudPtr)\nLastDev
            sLogicalDev = aAud(pAudPtr)\sLogicalDev[d]
            If sLogicalDev
              sTracks = aAud(pAudPtr)\sTracks[d]
              nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
              debugMsgC(sProcName, "d=" + d + ", nItemIndex=" + nItemIndex + ", \aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\aItem(nItemIndex)\fItemPan))
              If nItemIndex >= 0
                If nFirstItemIndex = -1
                  nFirstItemIndex = nItemIndex
                Else
                  \aItem(nItemIndex)\fItemPan = \aItem(nFirstItemIndex)\fItemPan
                  debugMsgC(sProcName, "\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\aItem(nItemIndex)\fItemPan))
                EndIf
              EndIf
            EndIf
          Next d
        EndIf
      EndWith
    Next nLevelPointIndex
    
  EndIf
  
  ; debugMsg(sProcName, "calling sanityCheckLevelPoints(" + getAudLabel(pAudPtr) + ")")
  sanityCheckLevelPoints(pAudPtr)
  
  ; debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
  ; listLevelPoints(pAudPtr)
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure clearLevelPoints(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      \nMaxLevelPoint = -1
    EndWith
  EndIf
  
EndProcedure

Procedure recalcLvlPtLevels(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected d
  Protected fDevLevel.f
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      For d = \nFirstDev To \nLastDev
        fDevLevel = \fBVLevel[d]
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bCueVolManual[" + d + "]=" + strB(\bCueVolManual[d]) + ", \fBVLevel[" + d + "]=" + traceLevel(\fBVLevel[d]))
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          For nItemIndex = 0 To \aPoint(nLevelPointIndex)\nPointMaxItem
            If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemDevNo = d
              If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                \aLvlPtRun[d]\fFromLevel = relDBLevelToLevel(\aLvlPtRun[d]\fFromRelDBLevel, fDevLevel)
                \aLvlPtRun[d]\fToLevel = relDBLevelToLevel(\aLvlPtRun[d]\fToRelDBLevel, fDevLevel)
;                 debugMsg(sProcName, "fDevLevel=" + traceLevel(fDevLevel) +
;                                     ", \aLvlPtRun[" + d + "]\fFromRelDBLevel=" + traceLevel(\aLvlPtRun[d]\fFromRelDBLevel) +
;                                     ", \aLvlPtRun[" + d + "]\fFromLevel=" + traceLevel(\aLvlPtRun[d]\fFromLevel) +
;                                     ", \aLvlPtRun[" + d + "]\fToLevel=" + traceLevel(\aLvlPtRun[d]\fToLevel))
              EndIf
            EndIf
          Next nItemIndex
        Next nLevelPointIndex
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure recalcLvlPtPans(pAudPtr)
  ; PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected d
  Protected fItemPan.f
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      For d = \nFirstDev To \nLastDev
        fItemPan = \fPan[d]
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fPan[" + d + "]=" + formatPan(\fPan[d]))
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          For nItemIndex = 0 To \aPoint(nLevelPointIndex)\nPointMaxItem
            If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemDevNo = d
              If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                \aLvlPtRun[d]\fFromPan = fItemPan
                \aLvlPtRun[d]\fToPan = fItemPan
              EndIf
            EndIf
          Next nItemIndex
        Next nLevelPointIndex
      Next d
    EndWith
  EndIf
  
EndProcedure

Procedure removeNonExistentDevsFromLvlPts(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected sItemLogicalDev.s
  Protected bDevExists
  Protected d, n
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
;     debugMsg(sProcName, "\nMaxLevelPoint=" + aAud(pAudPtr)\nMaxLevelPoint)
    For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
      nItemIndex = 0
;       debugMsg(sProcName, "\aPoint(" + nLevelPointIndex + ")\nPointMaxItem=" + aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem)
      While nItemIndex <= aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem
        With aAud(pAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)
          sItemLogicalDev = \sItemLogicalDev
          bDevExists = #False
          For d = 0 To grProd\nMaxAudioLogicalDev ; #SCS_MAX_AUDIO_DEV_PER_PROD
            If grProd\aAudioLogicalDevs(d)\sLogicalDev = sItemLogicalDev
              ; device found in production properties
              bDevExists = #True
              Break
            EndIf
          Next d
          If bDevExists
            bDevExists = #False
            For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
              If aAud(pAudPtr)\sLogicalDev[d] = sItemLogicalDev
                ; device found in both production properties and in the aud
                bDevExists = #True
                Break
              EndIf
            Next d
          EndIf
          If bDevExists = #False
            ; device not found in production properties or not found in the aud
            debugMsg(sProcName, "deleting aAud(" + getAudLabel(pAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ") for " + sItemLogicalDev)
            For n = nItemIndex + 1 To aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem
              aAud(pAudPtr)\aPoint(nLevelPointIndex)\aItem(n - 1) = aAud(pAudPtr)\aPoint(nLevelPointIndex)\aItem(n)
            Next n
            aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem - 1
          Else
            nItemIndex + 1
          EndIf
        EndWith
      Wend
    Next nLevelPointIndex
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure changeLogicalDevsInLvlPts(sLogicalDevOld.s, sLogicalDevNew.s)
  PROCNAMEC()
  Protected i, j, k
  Protected nLevelPointIndex, nItemIndex
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            With aAud(k)
              For nLevelPointIndex = 0 To \nMaxLevelPoint
                For nItemIndex = 0 To \aPoint(nLevelPointIndex)\nPointMaxItem
                  If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\sItemLogicalDev = sLogicalDevOld
                    \aPoint(nLevelPointIndex)\aItem(nItemIndex)\sItemLogicalDev = sLogicalDevNew
                  EndIf
                Next nItemIndex
              Next nLevelPointIndex
            EndWith
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
EndProcedure

Procedure propagateLvlPtLevelAndPanSelection(pAudPtr, pLevelPointIndex, bDoLevelSel=#True, bDoPanSel=#True)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected fReqdItemRelDBLevel.f
  Protected fReqdItemPan.f
  Protected d
  Protected sLogicalDev.s, sTracks.s
  Protected nLvlPtLvlSel, nLvlPtPanSel
  Protected nFromIndex, nUpToIndex, nIndex
  
  If pAudPtr >= 0
    If pLevelPointIndex = -1
      nFromIndex = 0
      nUpToIndex = aAud(pAudPtr)\nMaxLevelPoint
    Else
      nFromIndex = pLevelPointIndex
      nUpToIndex = pLevelPointIndex
    EndIf
    nLvlPtLvlSel = aAud(pAudPtr)\nLvlPtLvlSel
    nLvlPtPanSel = aAud(pAudPtr)\nLvlPtPanSel
    For nIndex = nFromIndex To nUpToIndex
      With aAud(pAudPtr)\aPoint(nIndex)
        If bDoLevelSel
          Select nLvlPtLvlSel
            Case #SCS_LVLSEL_SYNC
              If \nPointMaxItem > 0
                fReqdItemRelDBLevel = \aItem(0)\fItemRelDBLevel
                For nItemIndex = 1 To \nPointMaxItem
                  \aItem(nItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                Next nItemIndex
              EndIf
          EndSelect
        EndIf
        
        If bDoPanSel
          Select nLvlPtPanSel
            Case #SCS_PANSEL_SYNC
              If \nPointMaxItem > 0
                fReqdItemPan = \aItem(0)\fItemPan
                For nItemIndex = 1 To \nPointMaxItem
                  \aItem(nItemIndex)\fItemPan = fReqdItemPan
                  debugMsg(sProcName, "\aPoint(" + nIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\aItem(nItemIndex)\fItemPan))
                Next nItemIndex
              EndIf
          EndSelect
        EndIf
      EndWith
    Next nIndex
  EndIf
EndProcedure

Procedure setLevelPointItemDevNos(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected sLogicalDev.s, sTracks.s
  
  If pAudPtr >= 0
    For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(nLevelPointIndex)
        For nItemIndex = 0 To \nPointMaxItem
          sLogicalDev = \aItem(nItemIndex)\sItemLogicalDev
          sTracks = \aItem(nItemIndex)\sItemTracks
          \aItem(nItemIndex)\nItemDevNo = getAudDevNoForLogicalDev(pAudPtr, sLogicalDev, sTracks)
;           debugMsg(sProcName, "getAudDevNoForLogicalDev(" + getAudLabel(pAudPtr) + ", " + sLogicalDev + ", " + sTracks + ") returned \aItem(" + nItemIndex + ")\nItemDevNo=" + \aItem(nItemIndex)\nItemDevNo)
          \aItem(nItemIndex)\nItemGraphChannels = getNrOfOutputChansForLogicalDev(#SCS_DEVTYPE_AUDIO_OUTPUT, sLogicalDev)
        Next nItemIndex
      EndWith
    Next nLevelPointIndex
  EndIf
EndProcedure

Procedure getMaxTimeForPoint(pAudPtr, nPointTime)
  PROCNAMECA(pAudPtr)
  Protected nMaxTime
  Protected nNextLevelPointIndex
  
  nMaxTime = nPointTime
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nNextLevelPointIndex = getNextLevelPointIndex(pAudPtr, nPointTime)
      If nNextLevelPointIndex >= 0
        nMaxTime = \aPoint(nNextLevelPointIndex)\nPointTime - 1   ; max position is 1 millisecond before next level point
        If \aPoint(nNextLevelPointIndex)\nPointType = #SCS_PT_FADE_IN
          ; get next level point after fade-in
          nNextLevelPointIndex = getNextLevelPointIndex(pAudPtr, nPointTime + \nFadeInTime)
          If nNextLevelPointIndex >= 0
            ; make sure max fade-in level point is 1 millisecond before the following level point
            nMaxTime = \aPoint(nNextLevelPointIndex)\nPointTime - \nFadeInTime - 1
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  ProcedureReturn nMaxTime
EndProcedure

Procedure getMinTimeForPoint(pAudPtr, nPointTime)
  PROCNAMECA(pAudPtr)
  Protected nMinTime
  Protected nPrevLevelPointIndex
  
  nMinTime = nPointTime
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nPrevLevelPointIndex = getPrevLevelPointIndex(pAudPtr, nPointTime)
      debugMsg(sProcName, "nPointTime=" + nPointTime + ", nPrevLevelPointIndex=" + nPrevLevelPointIndex)
      If nPrevLevelPointIndex >= 0
        nMinTime = \aPoint(nPrevLevelPointIndex)\nPointTime + 1   ; min position is 1 millisecond after previous level point
        If \aPoint(nPrevLevelPointIndex)\nPointType = #SCS_PT_FADE_OUT
          ; get previous level point before fade-out
          nPrevLevelPointIndex = getPrevLevelPointIndex(pAudPtr, nPointTime - \nFadeOutTime)
          If nPrevLevelPointIndex >= 0
            ; make sure min fade-out level point is 1 millisecond after the preceding level point
            nMinTime = \aPoint(nPrevLevelPointIndex)\nPointTime + \nFadeOutTime + 1
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  ProcedureReturn nMinTime
EndProcedure

Procedure getMaxFadeInTime(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nMaxFadeInTime
  Protected nNextLevelPointIndex
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nNextLevelPointIndex = getNextLevelPointIndex(pAudPtr,\nAbsStartAt)
      If nNextLevelPointIndex >= 0
        If \aPoint(nNextLevelPointIndex)\nPointType = #SCS_PT_FADE_IN
          ; get next level point after fade-in
          nNextLevelPointIndex = getNextLevelPointIndex(pAudPtr, \nAbsStartAt + \nFadeInTime)
        EndIf
        If nNextLevelPointIndex >= 0
          nMaxFadeInTime = \aPoint(nNextLevelPointIndex)\nPointTime - \nAbsStartAt - 1
        EndIf
      EndIf
    EndWith
  EndIf
  ProcedureReturn nMaxFadeInTime
EndProcedure

Procedure getMaxFadeOutTime(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nMaxFadeOutTime
  Protected nPrevLevelPointIndex
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nPrevLevelPointIndex = getPrevLevelPointIndex(pAudPtr,\nAbsEndAt)
      If nPrevLevelPointIndex >= 0
        If \aPoint(nPrevLevelPointIndex)\nPointType = #SCS_PT_FADE_OUT
          ; get previous level point before fade-out
          nPrevLevelPointIndex = getPrevLevelPointIndex(pAudPtr, \nAbsEndAt - \nFadeOutTime)
        EndIf
        If nPrevLevelPointIndex >= 0
          nMaxFadeOutTime = \nAbsEndAt - \aPoint(nPrevLevelPointIndex)\nPointTime - 1
        EndIf
      EndIf
    EndWith
  EndIf
  ProcedureReturn nMaxFadeOutTime
EndProcedure

Procedure.f relDBLevelToLevel(fRelDBLevel.f, fDevLevel.f)
  PROCNAMEC()
  Protected fDevDBSingle.f
  Protected fDBSingle.f, fBVLevel.f
  
  fDevDBSingle = convertBVLevelToDBLevel(fDevLevel)
  fDBSingle = fDevDBSingle + fRelDBLevel
  If fDBSingle > grProd\nMaxDBLevel  ; grProd\nMaxDBLevel is integer, 0(dB) or 12(dB)
    fDBSingle = grProd\nMaxDBLevel
  EndIf
  fBVLevel = convertDBLevelToBVLevel(fDBSingle)
  
  ProcedureReturn fBVLevel
  
EndProcedure

Procedure.f getTrimmedDBLevel(pAudPtr, pDevNo)
  PROCNAMECA(pAudPtr)
  Protected fDBLevel.f, fDBTrim.f
  Protected fTrimmedDBLevel.f
  
  If (pAudPtr >= 0) And (pDevNo >= 0)
    With aAud(pAudPtr)
      fDBLevel = convertDBStringToDBLevel(\sDBLevel[pDevNo])
      fDBTrim = convertDBStringToDBLevel(\sDBTrim[pDevNo])
      fTrimmedDBLevel = fDBLevel - fDBTrim
      ; debugMsg(sProcName, "pDevNo=" + pDevNo + ", fDBLevel=" + StrF(fDBLevel,2) + ", fDBTrim=" + StrF(fDBTrim,2) + ", fTrimmedDBLevel=" + StrF(fTrimmedDBLevel,2))
    EndWith
  EndIf
  ProcedureReturn fTrimmedDBLevel
EndProcedure

Procedure setLinkRelLevels(pAudPtr, pLevelPointIndex)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected nLvlPtLvlSel
  Protected nFromIndex, nUpToIndex, nIndex
  
  If pAudPtr >= 0
    If pLevelPointIndex = -1
      nFromIndex = 0
      nUpToIndex = aAud(pAudPtr)\nMaxLevelPoint
    Else
      nFromIndex = pLevelPointIndex
      nUpToIndex = pLevelPointIndex
    EndIf
    nLvlPtLvlSel = aAud(pAudPtr)\nLvlPtLvlSel
    For nIndex = nFromIndex To nUpToIndex
      With aAud(pAudPtr)\aPoint(nIndex)
        If nLvlPtLvlSel = #SCS_LVLSEL_LINK
          For nItemIndex = 0 To \nPointMaxItem
            \aItem(nItemIndex)\fItemSyncRelDBLevel = \aItem(nItemIndex)\fItemRelDBLevel
          Next nItemIndex
        EndIf
      EndWith
    Next nIndex
  EndIf
EndProcedure

Procedure adjustRelLevelsForLink(pAudPtr, pLevelPointIndex, fRelDBLevelChangeExt.f)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected nLvlPtLvlSel
  Protected nFromIndex, nUpToIndex, nIndex
  
  If pAudPtr >= 0
    If pLevelPointIndex = -1
      nFromIndex = 0
      nUpToIndex = aAud(pAudPtr)\nMaxLevelPoint
    Else
      nFromIndex = pLevelPointIndex
      nUpToIndex = pLevelPointIndex
    EndIf
    nLvlPtLvlSel = aAud(pAudPtr)\nLvlPtLvlSel
    For nIndex = nFromIndex To nUpToIndex
      With aAud(pAudPtr)\aPoint(nIndex)
        If nLvlPtLvlSel = #SCS_LVLSEL_LINK
          For nItemIndex = 0 To \nPointMaxItem
            \aItem(nItemIndex)\fItemRelDBLevel + fRelDBLevelChangeExt
            ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aPoint(" + Str(nLevelPointIndex) + ")\aItem(" + Str(nItemIndex) + ")\fItemRelDBLevel=" + StrF(\aItem(nItemIndex)\fItemRelDBLevel,2))
          Next nItemIndex
        EndIf
      EndWith
    Next nIndex
  EndIf
EndProcedure

Procedure setRelLevelsForSync(pAudPtr, pLevelPointIndex, fReqdDBLevel.f)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected nLvlPtLvlSel
  Protected nFromIndex, nUpToIndex, nIndex
  
  ; Debug sProcName + ": pLevelPointIndex=" + pLevelPointIndex + ", fReqdDBLevel=" + convertDBLevelToDBString(fReqdDBLevel)
  If pAudPtr >= 0
    If pLevelPointIndex = -1
      nFromIndex = 0
      nUpToIndex = aAud(pAudPtr)\nMaxLevelPoint
    Else
      nFromIndex = pLevelPointIndex
      nUpToIndex = pLevelPointIndex
    EndIf
    nLvlPtLvlSel = aAud(pAudPtr)\nLvlPtLvlSel
    For nIndex = nFromIndex To nUpToIndex
      With aAud(pAudPtr)\aPoint(nIndex)
        If nLvlPtLvlSel = #SCS_LVLSEL_SYNC
          For nItemIndex = 0 To \nPointMaxItem
            \aItem(nItemIndex)\fItemRelDBLevel = fReqdDBLevel
            ; Debug "\aPoint(" + nIndex + ")\aItem(" + nItemIndex + ")\fItemRelDBLevel=" + convertDBLevelToDBString(\aItem(nItemIndex)\fItemRelDBLevel)
          Next nItemIndex
        EndIf
      EndWith
    Next nIndex
  EndIf
EndProcedure

Procedure setLvlPtPansAtAudDevPan(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sLogicalDev.s, sTracks.s
  Protected nLevelPointIndex, nItemIndex
  Protected d
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If \nLvlPtPanSel = #SCS_PANSEL_USEAUDDEV
        For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nItemIndex = getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev, sTracks)
              If nItemIndex >= 0
                \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan = \fPan[d]
                ; debugMsg(sProcName, "\aPoint(" + nLevelPointIndex + ")\aItem(" + nItemIndex + ")\fItemPan=" + formatPan(\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan))
              EndIf
            EndIf
          Next d
        Next nLevelPointIndex
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure sanityCheckLevelPoints(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nLevelPointIndex, nItemIndex
  Protected nErrorCode, sErrorInfo.s
  Protected sMsg.s
  Protected nLevelPointType, nLevelPointTime
  Protected nPrevLevelPointType, nPrevLevelPointTime
  
  If pAudPtr >= 0
    If aAud(pAudPtr)\nFileState = #SCS_FILESTATE_OPEN ; nb if file isn't open then level point times may be incorrect, so skip sanity check
      For nLevelPointIndex = 0 To aAud(pAudPtr)\nMaxLevelPoint
        With aAud(pAudPtr)\aPoint(nLevelPointIndex)
          nLevelPointType = \nPointType
          nLevelPointTime = \nPointTime
          If nLevelPointIndex > 0
            If nLevelPointType < nPrevLevelPointType
              nErrorCode = 1
              Break
            EndIf
            If (nLevelPointType = nPrevLevelPointType) And (nLevelPointType <> #SCS_PT_STD)
              nErrorCode = 2
              Break
            EndIf
            If nLevelPointTime <= nPrevLevelPointTime
              nErrorCode = 3
              Break
            EndIf
          EndIf
          If (nLevelPointType = #SCS_PT_FADE_IN) And (aAud(pAudPtr)\nFadeInTime <= 0)
            nErrorCode = 4
            sErrorInfo = ", \nFadeInTime=" + aAud(pAudPtr)\nFadeInTime
            Break
          EndIf
          If (nLevelPointType = #SCS_PT_FADE_OUT) And (aAud(pAudPtr)\nFadeOutTime <= 0)
            nErrorCode = 5
            sErrorInfo = ", \nFadeOutTime=" + aAud(pAudPtr)\nFadeOutTime
            Break
          EndIf
          nPrevLevelPointType = nLevelPointType
          nPrevLevelPointTime = nLevelPointTime
        EndWith
      Next nLevelPointIndex
      
      If nErrorCode > 0
        sMsg = "Error found in Level Point array for " + getAudLabel(pAudPtr) + ", nErrorCode=" + nErrorCode
        Select nErrorCode
          Case 1 To 3
            sMsg + Chr(10) + "nLevelPointIndex=" + nLevelPointIndex + ", nLevelPointType=" + decodeLevelPointType(nLevelPointType) + ", nLevelPointTime=" + timeToStringT(nLevelPointTime) +
            ", nPrevLevelPointType=" + decodeLevelPointType(nPrevLevelPointType) + ", nPrevLevelPointTime=" + timeToStringT(nPrevLevelPointTime)
          Case 4 To 5
            sMsg + Chr(10) + "nLevelPointIndex=" + nLevelPointIndex + ", nLevelPointType=" + decodeLevelPointType(nLevelPointType) + ", nLevelPointTime=" + timeToStringT(nLevelPointTime) +
                   sErrorInfo
        EndSelect
        sMsg + Chr(10) + Chr(10) + "Please 'undo' at least the last change you have made and report this error to " + #SCS_EMAIL_SUPPORT + ", together with the above details."
        debugMsg(sProcName, "calling listLevelPoints(" + getAudLabel(pAudPtr) + ")")
        listLevelPoints(pAudPtr)
        debugMsg(sProcName, sMsg)
        If IsGadget(WQF\cvsGraph)
          SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
        EndIf
        scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
      EndIf ; EndIf nErrorCode > 0
      
    EndIf ; EndIf aAud(pAudPtr)\nFileState = #SCS_FILESTATE_OPEN
    
  EndIf ; EndIf pAudPtr >= 0
EndProcedure

Procedure getNextLevelPointIndex(pAudPtr, nPosInFile)
  PROCNAMECA(pAudPtr)
  Protected nNextLevelPointIndex, n
  
  nNextLevelPointIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime > nPosInFile
          nNextLevelPointIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nNextLevelPointIndex
EndProcedure

Procedure getNextIncludedLevelPointIndex(pAudPtr, pDevNo, nPosInFile)
  ; nb also populates grLevelPointItem with the relevant \aItem() of the next included level point
  PROCNAMECA(pAudPtr)
  Protected nNextLevelPointIndex
  Protected n, n2
  
  nNextLevelPointIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime > nPosInFile
          For n2 = 0 To \nPointMaxItem
            If \aItem(n2)\nItemDevNo = pDevNo
              If \aItem(n2)\bItemInclude
                nNextLevelPointIndex = n
                grLevelPointItem = \aItem(n2)
              EndIf
              Break
            EndIf
          Next n2
          If nNextLevelPointIndex >= 0
            Break
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nNextLevelPointIndex
EndProcedure

Procedure getPrevLevelPointIndex(pAudPtr, nPosInFile)
  PROCNAMECA(pAudPtr)
  Protected nPrevLevelPointIndex, n
  
  nPrevLevelPointIndex = -1
  If pAudPtr >= 0
    For n = aAud(pAudPtr)\nMaxLevelPoint To 0 Step -1
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime < nPosInFile
          If \nPointMaxItem >= 0 ; added this test 28Nov2019 11.8.2rc5b following investigation of Gene LeFave's 'Chess' Q159 issue, where he could not add a std lvl pt because existing std lvl pts (in the cue file) had no items
            nPrevLevelPointIndex = n
            Break
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nPrevLevelPointIndex
EndProcedure

Procedure getPrevIncludedLevelPointIndex(pAudPtr, pDevNo, nPosInFile)
  ; nb also populates grLevelPointItem with the relevant \aItem() of the previous included level point
  PROCNAMECA(pAudPtr)
  Protected nPrevLevelPointIndex
  Protected n, n2
  
  ; debugMsg(sProcName, #SCS_START + ", pDevNo=" + Str(pDevNo) + ", nPosInFile=" + Str(nPosInFile) + " (" + timeToStringT(nPosInFile) + ")")
  
  nPrevLevelPointIndex = -1
  grLevelPointItem = grLevelPointItemDef
  If pAudPtr >= 0
;     debugMsg(sProcName, "\nMaxLevelPoint=" + Str(aAud(pAudPtr)\nMaxLevelPoint))
    For n = aAud(pAudPtr)\nMaxLevelPoint To 0 Step -1
      With aAud(pAudPtr)\aPoint(n)
;         debugMsg(sProcName, "aPoint(" + Str(n) + ")\nPointTime=" + Str(\nPointTime) + " (" + timeToStringT(\nPointTime) + ")" + ", \nPointMaxItem=" + Str(\nPointMaxItem))
        If \nPointTime < nPosInFile
          For n2 = 0 To \nPointMaxItem
;             debugMsg(sProcName, "\aItem(" + n2 + ")\nItemDevNo=" + Str(\aItem(n2)\nItemDevNo) + ", \bItemInclude=" + strB(\aItem(n2)\bItemInclude))
            If \aItem(n2)\nItemDevNo = pDevNo
              If \aItem(n2)\bItemInclude
                nPrevLevelPointIndex = n
                grLevelPointItem = \aItem(n2)
              EndIf
              Break
            EndIf
          Next n2
          If nPrevLevelPointIndex >= 0
            Break
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
;   debugMsg(sProcName, #SCS_END + ", returning nPrevLevelPointIndex=" + nPrevLevelPointIndex)
  ProcedureReturn nPrevLevelPointIndex
  
EndProcedure

Procedure getTimeOfFirstNonStartLevelPoint(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nPointTime, n
  
  nPointTime = -1000
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        Select \nPointType
          Case #SCS_PT_START, #SCS_PT_UNUSED_BOF, #SCS_PT_UNUSED_MIN
            ; skip
          Default
            nPointTime = \nPointTime
            Break
        EndSelect
      EndWith
    Next n
  EndIf
  ProcedureReturn nPointTime
EndProcedure

Procedure getItemIndexForDevNo(pAudPtr, nLevelPointIndex, pDevNo)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex
  Protected n2
  
  nItemIndex = -1
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    With aAud(pAudPtr)\aPoint(nLevelPointIndex)
      For n2 = 0 To \nPointMaxItem
        If \aItem(n2)\nItemDevNo = pDevNo
          nItemIndex = n2
          Break
        EndIf
      Next n2
    EndWith
  EndIf
  ProcedureReturn nItemIndex
EndProcedure

Procedure getLevelPointIndexForId(pAudPtr, nLevelPointId)
  Protected nLevelPointIndex, n
  
  nLevelPointIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointId = nLevelPointId
          nLevelPointIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nLevelPointIndex
EndProcedure

Procedure getLevelPointIndexForTime(pAudPtr, nLevelPointTime)
  Protected nLevelPointIndex, n
  
  nLevelPointIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime = nLevelPointTime  ; nb must be an exact match - not even 1 millisecond out
          nLevelPointIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nLevelPointIndex
EndProcedure

Procedure getLevelPointIdForTime(pAudPtr, nLevelPointTime)
  Protected nLevelPointId, n
  
  nLevelPointId = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime = nLevelPointTime  ; nb must be an exact match - not even 1 millisecond out
          nLevelPointId = \nPointId
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nLevelPointId
EndProcedure

Procedure getLevelPointIndexForType(pAudPtr, nLevelPointType, nLevelPointTime=-1)
  Protected nLevelPointIndex, n
  
  nLevelPointIndex = -1
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointType = nLevelPointType
          If nLevelPointType = #SCS_PT_STD
            If \nPointTime = nLevelPointTime
              nLevelPointIndex = n
              Break
            EndIf
          Else ; nLevelPointType <> #SCS_PT_STD
            nLevelPointIndex = n
            Break
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nLevelPointIndex
EndProcedure

Procedure getLevelPointIdForType(pAudPtr, nLevelPointType, nLevelPointTime=-1)
  Protected nLevelPointIndex, nLevelPointId
  
  nLevelPointId = -1
  nLevelPointIndex = getLevelPointIndexForType(pAudPtr, nLevelPointType, nLevelPointTime)
  If nLevelPointIndex >= 0
    nLevelPointId = aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointId
  EndIf
  ProcedureReturn nLevelPointId
EndProcedure

Procedure getLevelPointTypeForTime(pAudPtr, nLevelPointTime)
  Protected nLevelPointType, n
  
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        If \nPointTime = nLevelPointTime  ; nb must be an exact match - not even 1 millisecond out
          nLevelPointType = \nPointType
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nLevelPointType
EndProcedure

Procedure getLevelPointItemIndex(pAudPtr, nLevelPointIndex, sLogicalDev.s, sTracks.s)
  PROCNAMECA(pAudPtr)
  Protected nItemIndex, n
  
  nItemIndex = -1
  If (pAudPtr >= 0) And (nLevelPointIndex >= 0)
    For n = 0 To aAud(pAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem
      With aAud(pAudPtr)\aPoint(nLevelPointIndex)\aItem(n)
        If (\sItemLogicalDev = sLogicalDev) And (\sItemTracks = sTracks)
          nItemIndex = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nItemIndex
EndProcedure

Procedure maintainFadeInLevelPoint(pAudPtr, nOldFadeInTime, nNewFadeInTime)
  PROCNAMECA(pAudPtr)
  Protected nFadeInLevelPointIndex, nStartLevelPointIndex
  Protected nFadeInItemIndex, nStartTimeIndex
  Protected d
  Protected sLogicalDev.s, sTracks.s
  Protected fReqdItemRelDBLevel.f, fReqdItemPan.f
  
  debugMsg(sProcName, #SCS_START + ", nOldFadeInTime=" + nOldFadeInTime + ", nNewFadeInTime=" + nNewFadeInTime)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nFadeInLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_FADE_IN)
      nStartLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_START)
      
      ; case 1: fade-in added: add 'fade-in' level point if required; set 'fade-in' levels to the existing 'start' levels, and set the 'start' levels to min
      If (nOldFadeInTime <= 0) And (nNewFadeInTime > 0)
        If nFadeInLevelPointIndex = -1
          nFadeInLevelPointIndex = addOneLevelPoint(pAudPtr, (\nAbsStartAt + nNewFadeInTime), #SCS_PT_FADE_IN)
          ; re-obtain nStartLevelPointIndex as it may have changed due to addOneLevelPoint() calling sortLevelPointsArray()
          nStartLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_START)
        EndIf
        If (nStartLevelPointIndex >= 0) And (nFadeInLevelPointIndex >= 0)
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nStartTimeIndex = getLevelPointItemIndex(pAudPtr, nStartLevelPointIndex, sLogicalDev, sTracks)
              nFadeInItemIndex = getLevelPointItemIndex(pAudPtr, nFadeInLevelPointIndex, sLogicalDev, sTracks)
              If nStartTimeIndex >= 0
                fReqdItemRelDBLevel = \aPoint(nStartLevelPointIndex)\aItem(nStartTimeIndex)\fItemRelDBLevel
                fReqdItemPan = \aPoint(nStartLevelPointIndex)\aItem(nStartTimeIndex)\fItemPan
              Else
                fReqdItemRelDBLevel = 0.0
                fReqdItemPan = \fPan[d] ; audio device pan
              EndIf
              If nFadeInItemIndex >= 0
                \aPoint(nFadeInLevelPointIndex)\aItem(nFadeInItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                \aPoint(nFadeInLevelPointIndex)\aItem(nFadeInItemIndex)\fItemPan = fReqdItemPan
              Else
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nFadeInLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nFadeInItemIndex = addOneDBLevelPointItem(pAudPtr, nFadeInLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
              fReqdItemRelDBLevel = grLevels\nMinRelDBLevel
              If nStartTimeIndex >= 0
                \aPoint(nStartLevelPointIndex)\aItem(nStartTimeIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                ; leave pan in 'start' item unchanged
              Else
                ; shouldn't get here as items should already be present for all devices in 'start' level point
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nStartLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nStartTimeIndex = addOneDBLevelPointItem(pAudPtr, nStartLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
        EndIf
      EndIf
      
      ; case 2: fade-in removed: set 'start' levels to the existing 'fade-in' levels, and then remove the fade-in level point
      If (nOldFadeInTime > 0) And (nNewFadeInTime <= 0)
        If (nStartLevelPointIndex >= 0) And (nFadeInLevelPointIndex >= 0)
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nStartTimeIndex = getLevelPointItemIndex(pAudPtr, nStartLevelPointIndex, sLogicalDev, sTracks)
              nFadeInItemIndex = getLevelPointItemIndex(pAudPtr, nFadeInLevelPointIndex, sLogicalDev, sTracks)
              If nFadeInItemIndex >= 0
                fReqdItemRelDBLevel = \aPoint(nFadeInLevelPointIndex)\aItem(nFadeInItemIndex)\fItemRelDBLevel
                fReqdItemPan = \aPoint(nFadeInLevelPointIndex)\aItem(nFadeInItemIndex)\fItemPan
              Else
                ; new device
                fReqdItemRelDBLevel = 0.0
                fReqdItemPan = \fPan[d] ; audio device pan
              EndIf
              If nStartTimeIndex >= 0
                \aPoint(nStartLevelPointIndex)\aItem(nStartTimeIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                \aPoint(nStartLevelPointIndex)\aItem(nStartTimeIndex)\fItemPan = fReqdItemPan
              Else
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nStartLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nStartTimeIndex = addOneDBLevelPointItem(pAudPtr, nStartLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
          removeOneLevelPoint(pAudPtr, nFadeInLevelPointIndex)
        EndIf
      EndIf
      
      ; case 3: fade-in time changed: change time of fade-in level point
      If (nOldFadeInTime > 0) And (nNewFadeInTime > 0)
        ; nb do the following even if nNewFadeInTime = nOldFadeInTime because \nAbsStartAt may have changed
        If nFadeInLevelPointIndex >= 0
          \aPoint(nFadeInLevelPointIndex)\nPointTime = (\nAbsStartAt + nNewFadeInTime)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure maintainFadeOutLevelPoint(pAudPtr, nOldFadeOutTime, nNewFadeOutTime)
  PROCNAMECA(pAudPtr)
  Protected nFadeOutLevelPointIndex, nEndLevelPointIndex
  Protected nFadeOutItemIndex, nEndItemIndex
  Protected d
  Protected sLogicalDev.s, sTracks.s
  Protected fReqdItemRelDBLevel.f, fReqdItemPan.f
  
  debugMsg(sProcName, #SCS_START + ", nOldFadeOutTime=" + nOldFadeOutTime + ", nNewFadeOutTime=" + nNewFadeOutTime)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nFadeOutLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_FADE_OUT)
      nEndLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_END)
      
      ; case 1: fade-out added: add 'fade-out' level point if required; set 'fade-out' levels to the existing 'end' levels, and set the 'end' levels to min
      If (nOldFadeOutTime <= 0) And (nNewFadeOutTime > 0)
        If nFadeOutLevelPointIndex = -1
          nFadeOutLevelPointIndex = addOneLevelPoint(pAudPtr, (\nAbsEndAt - nNewFadeOutTime), #SCS_PT_FADE_OUT)
          ; re-obtain nEndLevelPointIndex as it may have changed due to addOneLevelPoint() calling sortLevelPointsArray()
          nEndLevelPointIndex = getLevelPointIndexForType(pAudPtr, #SCS_PT_END)
        EndIf
        If (nEndLevelPointIndex >= 0) And (nFadeOutLevelPointIndex >= 0)
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nEndItemIndex = getLevelPointItemIndex(pAudPtr, nEndLevelPointIndex, sLogicalDev, sTracks)
              nFadeOutItemIndex = getLevelPointItemIndex(pAudPtr, nFadeOutLevelPointIndex, sLogicalDev, sTracks)
              If nEndItemIndex >= 0
                fReqdItemRelDBLevel = \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemRelDBLevel
                fReqdItemPan = \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemPan
              Else
                fReqdItemRelDBLevel = 0.0
                fReqdItemPan = \fPan[d] ; audio device pan
              EndIf
              If nFadeOutItemIndex >= 0
                \aPoint(nFadeOutLevelPointIndex)\aItem(nFadeOutItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                \aPoint(nFadeOutLevelPointIndex)\aItem(nFadeOutItemIndex)\fItemPan = fReqdItemPan
              Else
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nFadeOutLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nFadeOutItemIndex = addOneDBLevelPointItem(pAudPtr, nFadeOutLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
              fReqdItemRelDBLevel = grLevels\nMinRelDBLevel
              If nEndItemIndex >= 0
                \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemPan = fReqdItemPan
              Else
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nEndLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nEndItemIndex = addOneDBLevelPointItem(pAudPtr, nEndLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
        EndIf
      EndIf
      
      ; case 2: fade-out removed: set 'end' levels to the existing 'fade-out' levels, and then remove the fade-out level point
      If (nOldFadeOutTime > 0) And (nNewFadeOutTime <= 0)
        If (nEndLevelPointIndex >= 0) And (nFadeOutLevelPointIndex >= 0)
          For d = \nFirstDev To \nLastDev
            sLogicalDev = \sLogicalDev[d]
            If sLogicalDev
              sTracks = \sTracks[d]
              nEndItemIndex = getLevelPointItemIndex(pAudPtr, nEndLevelPointIndex, sLogicalDev, sTracks)
              nFadeOutItemIndex = getLevelPointItemIndex(pAudPtr, nFadeOutLevelPointIndex, sLogicalDev, sTracks)
              If nFadeOutItemIndex >= 0
                fReqdItemRelDBLevel = \aPoint(nFadeOutLevelPointIndex)\aItem(nFadeOutItemIndex)\fItemRelDBLevel
                fReqdItemPan = \aPoint(nFadeOutLevelPointIndex)\aItem(nFadeOutItemIndex)\fItemPan
              Else
                ; new device
                fReqdItemRelDBLevel = 0.0
                fReqdItemPan = \fPan[d] ; audio device pan
              EndIf
              If nEndItemIndex >= 0
                \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemRelDBLevel = fReqdItemRelDBLevel
                \aPoint(nEndLevelPointIndex)\aItem(nEndItemIndex)\fItemPan = fReqdItemPan
              Else
                debugMsg(sProcName, "calling addOneDBLevelPointItem(" + getAudLabel(pAudPtr) + ", " + nEndLevelPointIndex + ", " + sLogicalDev + ", " + sTracks +
                                    ", #True, " + StrF(fReqdItemRelDBLevel,1) + ", " + StrF(fReqdItemPan,1) + ")")
                nEndItemIndex = addOneDBLevelPointItem(pAudPtr, nEndLevelPointIndex, sLogicalDev, sTracks, #True, fReqdItemRelDBLevel, fReqdItemPan)
              EndIf
            EndIf
          Next d
          removeOneLevelPoint(pAudPtr, nFadeOutLevelPointIndex)
        EndIf
      EndIf
      
      ; case 3: fade-out time changed: change time of fade-out level point
      If (nOldFadeOutTime > 0) And (nNewFadeOutTime > 0)
        ; nb do the following even if nNewFadeOutTime = nOldFadeOutTime because \nAbsEndAt may have changed
        If nFadeOutLevelPointIndex >= 0
          \aPoint(nFadeOutLevelPointIndex)\nPointTime = (\nAbsEndAt - nNewFadeOutTime)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure listLevelPoints(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, n2
  Protected sLevelPoint.s, sItem.s
  
  If pAudPtr >= 0
    For n = 0 To aAud(pAudPtr)\nMaxLevelPoint
      With aAud(pAudPtr)\aPoint(n)
        sLevelPoint = "\aPoint(" + n + ")\nPointTime=" + \nPointTime + " (" + timeToStringT(\nPointTime) + ")"
        sLevelPoint + ", \nPointType=" + decodeLevelPointType(\nPointType)
        sLevelPoint + ", \nPointId=" + \nPointId
        sLevelPoint + ", \sPointDesc=" + \sPointDesc
        sLevelPoint + ", \nPointMaxItem=" + \nPointMaxItem
        debugMsg(sProcName, sLevelPoint)
      EndWith
      For n2 = 0 To aAud(pAudPtr)\aPoint(n)\nPointMaxItem
        With aAud(pAudPtr)\aPoint(n)\aItem(n2)
          sItem = ".  \aItem(" + n2 + ")\sItemLogicalDev=" + \sItemLogicalDev
          sItem + ", \nItemDevNo=" + \nItemDevNo
          sItem + ", \sItemTracks=" + \sItemTracks
          sItem + ", \bItemInclude=" + strB(\bItemInclude)
          sItem + ", \fItemRelDBLevel=" + StrF(\fItemRelDBLevel,2)
          sItem + ", \fItemPan=" + formatPan(\fItemPan)
          debugMsg(sProcName, sItem)
        EndWith
      Next n2
    Next n
  EndIf

EndProcedure

Procedure listLvlPtRun(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected sMsg.s
  
  For d = aAud(pAudPtr)\nFirstDev To aAud(pAudPtr)\nLastDev
    With aAud(pAudPtr)\aLvlPtRun[d]
      sMsg = "aLvlPtRun[" + d + "]\nFromTime=" + \nFromTime + ", \nToTime=" + \nToTime
      sMsg + ", \nFromType=" + decodeLevelPointType(\nFromType) + ", \nToType=" + decodeLevelPointType(\nToType)
      sMsg + ", \fFromLevel=" + traceLevel(\fFromLevel) + ", \fToLevel=" + traceLevel(\fToLevel)
      sMsg + ", \fFromPan=" + formatPan(\fFromPan) + ", \fToPan=" + formatPan(\fToPan)
      sMsg + ", \bNoChange=" + strB(\bNoChange)
      debugMsg(sProcName, sMsg)
      ; Debug "aAud(" + getAudLabel(pAudPtr) + ")\" + sMsg
    EndWith
  Next d
  debugMsg(sProcName, "\nLvlPtRunToTime=" + timeToStringT(aAud(pAudPtr)\nLvlPtRunToTime))
  
EndProcedure

Procedure loadLvlPtRun(pAudPtr, pCuePos, bClearSuspendFlags, bTrace=#False)
  PROCNAMECA(pAudPtr)
  Protected nPosInFile
  Protected d
  Protected fDevLevel.f
  Protected nLevelPointIndex, nItemIndex
  Protected nFromTime, nToTime
  Protected nFromType, nToType
  Protected fFromRelDBLevel.f, fToRelDBLevel.f
  Protected fFromPan.f, fToPan.f
  Protected bToFound
  Protected sMsg.s
  Protected nNextLevelPointIndex
  
  debugMsgC(sProcName, #SCS_START + ", pCuePos=" + pCuePos + ", bClearSuspendFlags=" + strB(bClearSuspendFlags))
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      nPosInFile = pCuePos + \nAbsMin ; \nAbsStartAt ; Changed 29Aug2024 11.10.3ap
      ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAbsMin=" + \nAbsMin + ", nPosInFile=" + nPosInFile)
      For d = \nFirstDev To \nLastDev
        fDevLevel = \fBVLevel[d]
        bToFound = #False
        For nLevelPointIndex = 0 To \nMaxLevelPoint
          ; debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
          For nItemIndex = 0 To \aPoint(nLevelPointIndex)\nPointMaxItem
            If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemDevNo = d
              If \aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointTime=" + \aPoint(nLevelPointIndex)\nPointTime)
                If \aPoint(nLevelPointIndex)\nPointTime <= nPosInFile
                  nFromTime = \aPoint(nLevelPointIndex)\nPointTime
                  nFromType = \aPoint(nLevelPointIndex)\nPointType
                  fFromRelDBLevel = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel
                  fFromPan = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan
                  ; debugMsg(sProcName, "fFromRelDBLevel=" + StrF(fFromRelDBLevel,2))
                Else
                  nToTime = \aPoint(nLevelPointIndex)\nPointTime
                  ; debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex + ", nToTime=" + nToTime)
                  nToType = \aPoint(nLevelPointIndex)\nPointType
                  fToRelDBLevel = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel
                  fToPan = \aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan
                  ; debugMsg(sProcName, "fToRelDBLevel=" + StrF(fToRelDBLevel,2))
                  bToFound = #True
                  Break ; Added 2Feb2022 11.9.0rc7
                EndIf
              EndIf
            EndIf
          Next nItemIndex
          If bToFound
            Break
          EndIf
        Next nLevelPointIndex
        \aLvlPtRun[d]\nFromTime = nFromTime
        \aLvlPtRun[d]\nFromType = nFromType
        ; debugMsg(sProcName, "d=" + d + ", nFromType=" + decodeLevelPointType(nFromType) + ", nPosInFile=" + nPosInFile + ", nFromTime=" + nFromTime + ", \nFadeInTime=" + \nFadeInTime + ", nToTime=" + nToTime)
        If nFromType = #SCS_PT_FADE_IN And nPosInFile < nFromTime
          \aLvlPtRun[d]\fFromLevel = convertDBLevelToBVLevel(grProd\nMinDBLevel)
          ; debugMsg(sProcName, "\aLvlPtRun[" + d + "]\fFromLevel=" + traceLevel(\aLvlPtRun[d]\fFromLevel))
        Else
          ; Added 6Dec2024 to fix issue of level point relative dB adjustments handling scenarios like "-Inf + 80dB = -Inf". Fix reults in something like "-120dB + 80dB = -40dB"
          If fDevLevel < grLevels\fMinBVLevel
            fDevLevel = grLevels\fMinBVLevel
          EndIf
          ; End added 6Dec2024
          \aLvlPtRun[d]\fFromLevel = relDBLevelToLevel(fFromRelDBLevel, fDevLevel)
          ; debugMsg(sProcName, "\aLvlPtRun[" + d + "]\fFromLevel=" + traceLevel(\aLvlPtRun[d]\fFromLevel))
        EndIf
        \aLvlPtRun[d]\fFromPan = fFromPan
        \aLvlPtRun[d]\nToTime = nToTime
        \aLvlPtRun[d]\nToType = nToType
        If nFromType = #SCS_PT_FADE_OUT ; NB checking nFromType, not nToType, because this is the level point to start for fading out. ; Test added 2Feb2022 11.9.0rc7
          \aLvlPtRun[d]\fToLevel = convertDBLevelToBVLevel(grProd\nMinDBLevel)
        Else
          \aLvlPtRun[d]\fToLevel = relDBLevelToLevel(fToRelDBLevel, fDevLevel)
        EndIf
        \aLvlPtRun[d]\fToPan = fToPan
        If (fToRelDBLevel = fFromRelDBLevel) And (fToPan = fFromPan)
          \aLvlPtRun[d]\bNoChange = #True
        Else
          \aLvlPtRun[d]\bNoChange = #False
        EndIf
        If bClearSuspendFlags
          \aLvlPtRun[d]\bSuspendItemProc = #False
        EndIf
        \aLvlPtRun[d]\fFromRelDBLevel = fFromRelDBLevel ; required by recalcLvlPtLevels()
        \aLvlPtRun[d]\fToRelDBLevel = fToRelDBLevel     ; ditto
        debugMsgC(sProcName, "fFromRelDBLevel=" + StrF(fFromRelDBLevel,2) + ", fToRelDBLevel=" + StrF(fToRelDBLevel,2) + ", fDevLevel=" + traceLevel(fDevLevel) +
                             ", \aLvlPtRun[" + d + "]\fFromLevel=" + traceLevel(\aLvlPtRun[d]\fFromLevel) +
                             ", \aLvlPtRun[" + d + "]\fToLevel=" + traceLevel(\aLvlPtRun[d]\fToLevel))
      Next d
      
      ; force level and pan to be set the next time doLvlPtRun() is called, regardless of the \bNoChange settings
      ; this is primarily to force level and pan to be set after cue repositioning, when the reposition may be in a 'no change' area
      \bLvlPtRunForceSettings = #True
      
      nNextLevelPointIndex = getNextLevelPointIndex(pAudPtr, nPosInFile)
      If nNextLevelPointIndex >= 0
        \nLvlPtRunToTime = \aPoint(nNextLevelPointIndex)\nPointTime
      EndIf
      
      ; Commented out thread test below 4Nov2024 11.10.6bg because this could cause a change of state to be delayed (eg changing from fading in to playing), as found when checking Q58 in cue file from provided Jonathan Trenholme 2Nov2024
      ; If gnThreadNo = #SCS_THREAD_MAIN ; Added Thread test 12Aug2024 11.10.3be following test of Tutorial 2 where loadLvlPtRun() was being called from doLvlPtRun() in the Control Thread (#2)
        If \bAudTypeF ; Extra test added 20May2024 11.10.3ac to fix the error reported by 'eightacre' in the SCS Bug Reports forum topic 'Trouble with playlists' 
          ; Added 10May2024 11.10.2co following bug reported by Christian Peters
          debugMsgC(sProcName, "calling SC_SubTypeF_or_SubTypeM_MIDI(" + getAudLabel(pAudPtr) + ", #True)")
          SC_SubTypeF_or_SubTypeM_MIDI(pAudPtr, #True)
          ; End added 10May2024 11.10.2co
        EndIf
;       EndIf
      
    EndWith
    
    If bTrace
      listLvlPtRun(pAudPtr)
      listLevelPoints(pAudPtr)
    EndIf
    
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure doLvlPtRun(pAudPtr, pCuePos)
  PROCNAMECA(pAudPtr)
  Protected d
  Protected nTime, nPos
  Protected fReqdBVLevel.f, fReqdPan.f
  Protected bGetNextLevelPoint
  Protected fFromLevel.f, fToLevel.f, bIgnorePan
  Protected bSkipLvlPtProcessing
  Protected bLvlChangeActive ; bLvlChangeActive was added 13Jun2003 11.10.0bg to ensure 'standard' fade-ins reached the required level.
                             ; Previously they could stop short of the required level due to the fade-in time expiring.
                             ; Problem reported by Joe Eaton 13Jun2023, but also reported earlier by another user.
  
  Static bInDoLvlPtRun ; Added 20Sep2024 11.10.4ad following test of loop for Tutorial 2 where the loop start point was earlier than the sub-cue start point.
  
  CompilerIf (#cTraceSetLevels And 1=1)
    debugMsg(sProcName, #SCS_START + ", pCuePos=" + pCuePos)
  CompilerEndIf
  
  If bInDoLvlPtRun
    debugMsg(sProcName, "pCuePos=" + pCuePos + ", exiting because recursive call")
    ProcedureReturn
  EndIf
  bInDoLvlPtRun = #True
  
  With aAud(pAudPtr)
    nPos = pCuePos + \nAbsMin ; \nAbsStartAt
    If nPos >= \nLvlPtRunToTime
      bGetNextLevelPoint = #True
    EndIf
    For d = \nFirstDev To \nLastDev
      If (\aLvlPtRun[d]\bSuspendItemProc = #False) Or (\bFadingInFromHibernate)
        If (\aLvlPtRun[d]\bNoChange = #False) Or (\bLvlPtRunForceSettings) Or (\nAudState = #SCS_CUE_FADING_IN)
          If \nAudState = #SCS_CUE_FADING_IN And (\aLvlPtRun[d]\nFromType = #SCS_PT_START Or \aLvlPtRun[d]\nFromType = #SCS_PT_FADE_IN Or \bFadingInFromHibernate)
            If (\nFadeInType = #SCS_FADE_LIN) And (gbUseBASS)
              bSkipLvlPtProcessing = #True  ; skip processing because fadeInOneAud() issued a BASS_ChannelSlideAttribute() for the whole fade-in time
            Else
              nTime = \nCurrFadeInTime
              nPos = pCuePos - \nCuePosAtFadeStart
              CompilerIf #cTraceSetLevels
                debugMsg(sProcName, "pCuePos=" + pCuePos + ", aAud(" + getAudLabel(pAudPtr) + ")\nCuePosAtFadeStart=" + \nCuePosAtFadeStart + ", nPos=" + nPos + ", nTime=" + nTime)
              CompilerEndIf
              fFromLevel = #SCS_MINVOLUME_SINGLE
              If \bFadingInFromHibernate
                CompilerIf #cTraceSetLevels
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fBVLevelWhenFadeOutStarted[" + d + "]=" + traceLevel(\fBVLevelWhenFadeOutStarted[d]))
                CompilerEndIf
                fToLevel = \fBVLevelWhenFadeOutStarted[d]
                bIgnorePan = #True
              Else
                fToLevel = \aLvlPtRun[d]\fToLevel
              EndIf
            EndIf
          Else
            nTime = \aLvlPtRun[d]\nToTime - \aLvlPtRun[d]\nFromTime
            nPos = pCuePos + \nAbsStartAt - \aLvlPtRun[d]\nFromTime
            CompilerIf #cTraceSetLevels
              debugMsg(sProcName, "pCuePos=" + pCuePos + ", \nAbsStartAt=" + \nAbsStartAt + ", \aLvlPtRun[" + d + "]\nFromTime=" + \aLvlPtRun[d]\nFromTime + ", \aLvlPtRun[" + d + "]\nToTime=" + \aLvlPtRun[d]\nToTime + ", nTime=" + nTime)
            CompilerEndIf
            fFromLevel = \aLvlPtRun[d]\fFromLevel
            fToLevel = \aLvlPtRun[d]\fToLevel
          EndIf
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "calling calcBVLevel(" + decodeFadeType(\nFadeInType) + ", nTime=" + nTime + ", nPos=" + nPos + ", " + traceLevel(fFromLevel) + ", " + traceLevel(fToLevel) + ", " + \fTrimFactor[d] + ")")
          CompilerEndIf
          fReqdBVLevel = calcBVLevel(\nFadeInType, nTime, nPos, fFromLevel, fToLevel, \fTrimFactor[d])
          CompilerIf #cTraceSetLevels
            debugMsg(sProcName, "calcBVLevel(" + decodeFadeType(\nFadeInType) + ", " + nTime + ", " + nPos + ", " + traceLevel(fFromLevel) + ", " + traceLevel(fToLevel) + ", " + formatTrim(\fTrimFactor[d]) +
                                ", \nAudState=" + decodeCueState(\nAudState) + ") returned fReqdBVLevel=" + formatLevel(fReqdBVLevel))
          CompilerEndIf
          \bFinalSlide = grMMedia\bMMFinalSlide
          
          If bIgnorePan
            fReqdPan = \fCuePanNow[d]
          Else
            fReqdPan = calcPan(nTime, nPos, \aLvlPtRun[d]\fFromPan, \aLvlPtRun[d]\fToPan)
          EndIf
          
          ; debugMsg(sProcName, "pAudPtr=" + getAudLabel(pAudPtr) + ", nPos=" + nPos + ", fReqdBVLevel=" + formatLevel(fReqdBVLevel) + ", fReqdPan=" + formatPan(fReqdPan))
          
          If bSkipLvlPtProcessing = #False
            If gbUseSMS ; SM-S
              If (fReqdBVLevel <> \fCueTotalVolNow[d]) Or (fReqdPan <> \fCuePanNow[d]) Or (\bLvlPtRunForceSettings)
                CompilerIf #cTraceSetLevels
                  debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(pAudPtr) + ", " + d + ", " + traceLevel(fReqdBVLevel) + ", " + formatPan(fReqdPan) + ", -1, " + Str(gnTimerInterval) + ")")
                CompilerEndIf
                setLevelsAny(pAudPtr, d, fReqdBVLevel, fReqdPan, -1, gnTimerInterval)
                bLvlChangeActive = #True
              EndIf
            Else
              If (fReqdBVLevel <> \fCueTotalVolNow[d]) Or (\bLvlPtRunForceSettings)
                CompilerIf #cTraceSetLevels
                  debugMsg(sProcName, "fReqdBVLevel=" + formatLevel(fReqdBVLevel) + ", \fCueTotalVolNow[" + d + "]=" + formatLevel(\fCueTotalVolNow[d]) +
                                      ", \bLvlPtRunForceSettings=" + strB(\bLvlPtRunForceSettings))
                  debugMsg(sProcName, "calling slideChannelAttributes(" + getAudLabel(pAudPtr) + ", " + d + ", " + traceLevel(fReqdBVLevel) +
                                      ", #SCS_NOPANCHANGE_SINGLE, " + gnTimerInterval + ", 1234)")
                CompilerEndIf
                slideChannelAttributes(pAudPtr, d, fReqdBVLevel, #SCS_NOPANCHANGE_SINGLE, gnTimerInterval, 1234)
                bLvlChangeActive = #True
              Else
                CompilerIf #cTraceCueTotalVolNow
                  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\fAudPlayBVLevel[" + d + "]=" + traceLevel(aAud(pAudPtr)\fAudPlayBVLevel[d]) +
                                      ", \fCueTotalVolNow[" + d + "]=" + traceLevel(\fCueTotalVolNow[d]) + ", fcLevel " + traceLevel(fReqdBVLevel))
                CompilerEndIf
              EndIf
              If (fReqdPan <> \fCuePanNow[d]) Or (\bLvlPtRunForceSettings)
                If \bUseMatrix[d] = #False
                  CompilerIf #cTraceSetLevels
                    debugMsg(sProcName, "fReqdPan=" + formatPan(fReqdPan) + ", \fCuePanNow[" + d + "]=" + formatPan(\fCuePanNow[d]) +
                                        ", \bLvlPtRunForceSettings=" + strB(\bLvlPtRunForceSettings))
                    debugMsg(sProcName, "calling slideChannelAttributes(" + getAudLabel(pAudPtr) + ", " + d + ", #SCS_NOVOLCHANGE_SINGLE, " + tracePan(fReqdPan) +
                                        ", " + gnTimerInterval + ", 1235)")
                  CompilerEndIf
                  slideChannelAttributes(pAudPtr, d, #SCS_NOVOLCHANGE_SINGLE, fReqdPan, gnTimerInterval, 1235)
                  bLvlChangeActive = #True
                Else
                  CompilerIf #cTraceSetLevels
                    debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(pAudPtr) + ", " + d + ", #SCS_NOVOLCHANGE_SINGLE, " + formatPan(fReqdPan) + ")")
                  CompilerEndIf
                  setLevelsAny(pAudPtr, d, #SCS_NOVOLCHANGE_SINGLE, fReqdPan)
                  bLvlChangeActive = #True
                EndIf
              EndIf
            EndIf
          EndIf
          
        EndIf
      EndIf
    Next d
    
    \bLvlPtRunForceSettings = #False
    
    If bGetNextLevelPoint
      bLvlChangeActive = #False
      ; debugMsg(sProcName, "calling loadLvlPtRun(" + getAudLabel(pAudPtr) + ", " + Str(pCuePos+1) + ", #False, " + strB(#cTraceSetLevels) + ")")
      loadLvlPtRun(pAudPtr, pCuePos+1, #False, #cTraceSetLevels)
    EndIf
    
  EndWith
  
  CompilerIf (#cTraceSetLevels And 1=1)
    debugMsg(sProcName, #SCS_END + ", returning bLvlChangeActive=" + strB(bLvlChangeActive))
  CompilerEndIf
  bInDoLvlPtRun = #False
  
  ProcedureReturn bLvlChangeActive
  
EndProcedure

Procedure suspendLvlPtProcessing(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected d
  
  debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      For d = \nFirstDev To \nLastDev
        \aLvlPtRun[d]\bSuspendItemProc = #True
      Next d
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addSelectedCtrlHoldLP(nPointId)
  PROCNAMEC()
  Protected aValue, aCurrentListSize
  
  aCurrentListSize = ListSize(CtrlHoldLevelPoints()) 
  ; Debug sProcName + ": aCurrentListSize=" + aCurrentListSize
  If aCurrentListSize >= 1
    If checkLevelPointInCtrlHoldList(nPointId)
      ; Do Not add To List just updated the Selected parameter  
      ResetList(CtrlHoldLevelPoints())
      While NextElement(CtrlHoldLevelPoints())
        aValue = CtrlHoldLevelPoints()\nLPPointId
        If aValue = nPointId
          If CtrlHoldLevelPoints()\bLPSelected
            CtrlHoldLevelPoints()\bLPSelected = #False
          Else
            CtrlHoldLevelPoints()\bLPSelected = #True
          EndIf
          ; Debug sProcName + ": (aa) nPointId=" + nPointId + ", CtrlHoldLevelPoints()\bLPSelected=" + strB(CtrlHoldLevelPoints()\bLPSelected)
        EndIf
      Wend        
    Else
      ; Not already in the list then add and set to selected
      debugMsg(sProcName, "Added to the List - nPointId = "+nPointId+" and Selected = True")
      ; Debug sProcName + ": (a) Added to the List - nPointId = "+nPointId+" and Selected = True"
      AddElement(CtrlHoldLevelPoints())
      CtrlHoldLevelPoints()\nLPPointId = nPointId
      CtrlHoldLevelPoints()\bLPSelected = #True
    EndIf
  Else
    ; Not already in the list then add and set to selected
    debugMsg(sProcName, "Added to the List - nPointId = "+nPointId+" and Selected = True")
    ; Debug sProcName + ": (b) Added to the List - nPointId = "+nPointId+" and Selected = True"
    AddElement(CtrlHoldLevelPoints())
    CtrlHoldLevelPoints()\nLPPointId = nPointId
    CtrlHoldLevelPoints()\bLPSelected = #True
  EndIf
EndProcedure

Procedure removeSelectedCtrlHoldLP(nPointId)
  PROCNAMEC()
  
  If ListSize(CtrlHoldLevelPoints()) < 1
    ProcedureReturn
  EndIf
  
  ResetList(CtrlHoldLevelPoints())
  While NextElement(CtrlHoldLevelPoints())
    If CtrlHoldLevelPoints()\nLPPointId = nPointId
      CtrlHoldLevelPoints()\bLPSelected = #False
      debugMsg(sProcName, "nPointId=" + nPointId + ", CtrlHoldLevelPoints()\bLPSelected=" + strB(CtrlHoldLevelPoints()\bLPSelected))
      ; Debug sProcName + ": nPointId=" + nPointId + ", CtrlHoldLevelPoints()\bLPSelected=" + strB(CtrlHoldLevelPoints()\bLPSelected)
    EndIf
  Wend  
EndProcedure

Procedure clearCtrlHoldLP()
  ClearList(CtrlHoldLevelPoints())
EndProcedure

Procedure checkSelectedCtrlHoldLP(nPointId)
  ; PROCNAMEC()
  Protected n, aValue, aListSize
  
  If ListSize(CtrlHoldLevelPoints()) < 1
    ProcedureReturn #False
  EndIf
  
  ;MessageRequester("List Size", "Current List Total:"+ListSize(CtrlHoldLevelPoints()), #PB_MessageRequester_Ok) 
  
  FirstElement(CtrlHoldLevelPoints())
  aListSize = ListSize(CtrlHoldLevelPoints())-1
  For n = 0 To aListSize
    aValue = CtrlHoldLevelPoints()\nLPPointId
    ; Debug sProcName + ": nPointId=" + nPointId + ", aValue=" + aValue
    If aValue = nPointId
      ;debugMsg(sProcName, "FOUND LP in List")
      If CtrlHoldLevelPoints()\bLPSelected
        ; Debug sProcName + ": LP <"+nPointId+"> in List is currently SELECTED"
        ProcedureReturn #True
      Else
        ;debugMsg(sProcName, "LP <"+nPointId+"> in List is currently Not SELECTED")
        ; Debug sProcName + ": LP <"+nPointId+"> in List is currently Not SELECTED"
        ProcedureReturn #False
      EndIf
    EndIf
    NextElement(CtrlHoldLevelPoints())
  Next n
  ; Not in the List at all
  ;debugMsg(sProcName, "Did NOT FIND LP <"+nPointId+"> in List")
  ; Debug sProcName + ": Did NOT FIND LP <"+nPointId+"> in List"
  ProcedureReturn #False
EndProcedure

Procedure checkLevelPointInCtrlHoldList(nPointId)
  
  ResetList(CtrlHoldLevelPoints())
  While NextElement(CtrlHoldLevelPoints())
    If CtrlHoldLevelPoints()\nLPPointId = nPointId
      ProcedureReturn #True
    EndIf
  Wend
  ProcedureReturn #False
  
EndProcedure

Procedure countSelectedLevelPointsInCtrlHoldList()
  Protected nSelected
  
  If ListSize(CtrlHoldLevelPoints()) > 0
    ResetList(CtrlHoldLevelPoints())
    While NextElement(CtrlHoldLevelPoints())
      If CtrlHoldLevelPoints()\bLPSelected
        nSelected + 1
      EndIf
    Wend
  EndIf
  ProcedureReturn nSelected
  
EndProcedure

; EOF