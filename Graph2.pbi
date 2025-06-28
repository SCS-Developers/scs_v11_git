; File: Graph2.pbi
; handles the drawing of audio file graphs in the editor, ie from fmEditQF.pbi or from fmEditQA.pbi

EnableExplicit

Procedure condStartGraphDrawing(*rMG.tyMG)
  With *rMG
    If \bDrawingStarted = #False
      StartDrawing(CanvasOutput(\nCanvasGadget))
      \bDrawingStarted = #True
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndWith
EndProcedure

Procedure condStopGraphDrawing(*rMG.tyMG, bDrawingStartedByMe)
  With *rMG
    If bDrawingStartedByMe
      StopDrawing()
      \bDrawingStarted = #False
    EndIf
  EndWith
EndProcedure

Procedure drawNoAudioGraphMsg(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTextWidth, nTextHeight, nLeft, nTop, nHalfOutputHeight
  Protected sSubType.s, nFileScanMaxLength
  Static sMsg.s, nPrevScanMaxLengthAudio, nPrevScanMaxLengthVideo
  
  debugMsg(sProcName, #SCS_START)
  
  sSubType = getSubTypeForAud(pAudPtr)
  nFileScanMaxLength = getFileScanMaxLength(sSubType)
  If sSubType = "A"
    If nFileScanMaxLength <> nPrevScanMaxLengthVideo
      sMsg = " " + LangPars("Graph", "NoGraph3", Str(nFileScanMaxLength)) + " "
      nPrevScanMaxLengthVideo = nFileScanMaxLength
    EndIf
  Else
    If nFileScanMaxLength <> nPrevScanMaxLengthAudio
      sMsg = " " + LangPars("Graph", "NoGraph3", Str(nFileScanMaxLength)) + " "
      nPrevScanMaxLengthAudio = nFileScanMaxLength
    EndIf
  EndIf
  
  scsDrawingFont(#SCS_FONT_GEN_NORMAL9)
  nTextWidth = TextWidth(sMsg)
  nTextHeight = TextHeight(sMsg)
  ; horizontally centre the message within the graph area
  If nTextWidth < OutputWidth()
    nLeft = (OutputWidth() - nTextWidth) >> 1
  Else
    nLeft = 0
  EndIf
  ; vertically centre the message within the lower half of the graph area (the pan line will by default be in the very middle of the graph area)
  nHalfOutputHeight = OutputHeight() >> 1
  nTop = ((nHalfOutputHeight - nTextHeight) >> 1) + nHalfOutputHeight
  DrawingMode(#PB_2DDrawing_Transparent)
  DrawText(nLeft, nTop, sMsg, #SCS_Yellow)
  DrawingMode(#PB_2DDrawing_Default)
  
EndProcedure

Procedure drawSpecialSlice(*rMG.tyMG, nSliceType, nThisSlice, nLevelPointIndex=-1, nLoopInfoIndex=-1, nCueMarkerId=-1)
  ; PROCNAMECA(nEditAudPtr)
  Protected X, XST, XFI, XFO, XEN, XLS
  Protected YCM
  Protected sCurrLogicalDev.s, sCurrTracks.s
  Protected sItemLogicalDev.s, sItemTracks.s
  Protected n
  Protected nPrevLevelPointIndex, nPrevLevelPointType
  Protected XPrevLP
  Protected fThisLevel.f, fPrevLevel.f
  Protected fThisPan.f, fPrevPan.f
  Protected fFactorY.f
  Protected nPrevPanY, nThisPanY
  Protected nTopL, nTopR, nBottomL, nBottomR
  Protected nTopL2, nTopR2, nBottomL2, nBottomR2
  Protected nDevNo
  Protected fDevLevel.f, fDevPan.f
  Protected fDevDBLevel.f
  Protected nPointTime
  Protected nPointType
  Protected bCurrLevelPoint
  Protected nItemIndex, nPrevItemIndex
  Protected nItemFromIndex, nItemUpToIndex, nItemCurrIndex
  Protected nPassNo, bWantThis
  Protected nItemGraphChannels
  Protected nColor
  Protected nSliceArraySize, nMXQM
  
  ; debugMsg(sProcName, #SCS_START + ", nSliceType=" + decodeSliceType(nSliceType) + ", nThisSlice=" + nThisSlice + ", nLevelPointIndex=" + nLevelPointIndex +
  ;                     ", nLoopInfoIndex=" + nLoopInfoIndex + ", nCueMarkerId=" + nCueMarkerId)
  
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    If \bAudTypeF
      nDevNo = rWQF\nCurrDevNo
      If nDevNo < 0 Or nDevNo > #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
        ProcedureReturn
      EndIf
    ElseIf \bAudTypeA
      nDevNo = \nFirstDev
      If nDevNo < 0
        ProcedureReturn
      EndIf
    EndIf
    sCurrLogicalDev = \sLogicalDev[nDevNo]
    sCurrTracks = \sTracks[nDevNo]
    fDevLevel = \fBVLevel[nDevNo]
    ; Added 6Dec2024 to fix issue of level point relative dB adjustments handling scenarios like "-Inf + 80dB = -Inf". Fix reults in something like "-120dB + 80dB = -40dB"
    If fDevLevel < grLevels\fMinBVLevel
      fDevLevel = grLevels\fMinBVLevel
    EndIf
    ; End added 6Dec2024
    fDevDBLevel = convertBVLevelToDBLevel(fDevLevel)
    fDevPan = \fPan[nDevNo]
  EndWith
  ; debugMsg(sProcName, "nSliceType=" + decodeSliceType(nSliceType) + ", nThisSlice=" + nThisSlice + ", nDevNo=" + nDevNo + ", fDevLevel=" + traceLevel(fDevLevel) + ", nLevelPointIndex=" + nLevelPointIndex)
  
  With *rMG
    X = nThisSlice + \nGraphLeft  ; nb \nGraphLeft will be 0 or -ve
    XST = grGraph2\nSliceST + \nGraphLeft
    XFI = grGraph2\nSliceFI + \nGraphLeft
    XFO = grGraph2\nSliceFO + \nGraphLeft
    XEN = grGraph2\nSliceEN + \nGraphLeft
    ; debugMsg(sProcName, "X=" + X + ", XST=" + XST + ", XFI=" + XFI + ", XFO=" + XFO + ", XEN=" + XEN)
    If (X < -16000) Or (X > 16000)
      ; ignore if way out of range (16000 based on maximum canvas width in PB, but not really related to this)
      ; debugMsg(sProcName, "exiting because X=" + X)
      ProcedureReturn
    EndIf
    If \nMGNumber = 5 ; video cue graph in editor
      YCM = 1
    Else
      YCM = \nLoopBarTop
    EndIf
    
    Select nSliceType
      Case #SCS_SLICE_TYPE_CURR
        If (X >= 0) And (X < \nVisibleWidth)
          drawPosCursor(X, \nGraphTop, \nGraphBottom, \nCursorColor, \nCursorShadowColor, #False)
          ; debugMsg(sProcName, "curr x=" + X + ", nThisSlice=" + nThisSlice + ", \nGraphLeft=" + \nGraphLeft + ", \nAudPtr=" + getAudLabel(\nAudPtr) + ", nEditAudPtr=" + getAudLabel(nEditAudPtr))
        EndIf
        
      Case #SCS_SLICE_TYPE_ST   ; start at
        LineXY(X, \nGraphTop, X, \nSEBarBottom, \nSTColor)
        LineXY(X, \nSEBarBottom-9, X+9, \nSEBarBottom, \nSTColor)   ; diagonal line
        LineXY(X, \nSEBarBottom, X+9, \nSEBarBottom, \nSTColor)     ; base of triangle
        FillArea(X+1, \nSEBarBottom-1, \nSTColor, \nSTColor)
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_ST, nLevelPointIndex, #SCS_GRAPH_MARKER_LEVEL, -1, X, \nSEBarBottom-9, 9, 9)
        
      Case #SCS_SLICE_TYPE_EN   ; end at
        LineXY(X, \nGraphTop, X, \nSEBarBottom, \nENColor)
        LineXY(X, \nSEBarBottom-9, X-9, \nSEBarBottom, \nENColor)   ; diagonal line
        LineXY(X-9, \nSEBarBottom, X, \nSEBarBottom, \nENColor)     ; base of triangle
        FillArea(X-1, \nSEBarBottom-1, \nENColor, \nENColor)
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_EN, nLevelPointIndex, #SCS_GRAPH_MARKER_LEVEL, -1, X-9, \nSEBarBottom-9, 9, 9)
        
      Case #SCS_SLICE_TYPE_LS   ; loop start
        If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
          nColor = \nLSColorD
        Else
          nColor = \nLSColorN
        EndIf
        LineXY(X, \nLoopBarTop, X, \nGraphBottom, nColor)
        LineXY(X, \nLoopBarTop, X+9, \nLoopBarTop, nColor)       ; top of triangle
        LineXY(X, \nLoopBarTop+9, X+9, \nLoopBarTop, nColor)     ; diagonal line
        If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
          FillArea(X+1, \nLoopBarTop+1, nColor, nColor)
        EndIf
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LS, -1, -1, -1, X, \nLoopBarTop, 9, 9, -1, -1, nLoopInfoIndex)
        
      Case #SCS_SLICE_TYPE_LE   ; loop end
        If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
          nColor = \nLEColorD
        Else
          nColor = \nLEColorN
        EndIf
        LineXY(X, \nLoopBarTop, X, \nGraphBottom, nColor)
        LineXY(X, \nLoopBarTop, X-9, \nLoopBarTop, nColor)       ; top of triangle
        LineXY(X, \nLoopBarTop+9, X-9, \nLoopBarTop, nColor)     ; diagonal line
        If nLoopInfoIndex = rWQF\nDisplayedLoopInfoIndex
          FillArea(X-1, \nLoopBarTop+1, nColor, nColor)
        EndIf
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LE, -1, -1, -1, X-9, \nLoopBarTop, 9, 9, -1, -1, nLoopInfoIndex)
        XLS = grGraph2\nSliceLS(nLoopInfoIndex) + \nGraphLeft
        If (XLS >= \nGraphLeft) And (XLS < X)
          LineXY(XLS, \nGraphBottom, X, \nGraphBottom, nColor)
        EndIf
        
      Case #SCS_SLICE_TYPE_LP   ; level point
        If nLevelPointIndex >= 0
          nPointType = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType
          nPointTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
          nItemCurrIndex = getLevelPointItemIndex(nEditAudPtr, nLevelPointIndex, sCurrLogicalDev, sCurrTracks)
          ; debugMsg(sProcName, ">>>> nLevelPointIndex=" + nLevelPointIndex + ", nPointType=" + decodeLevelPointType(nPointType) + ", nItemCurrIndex=" + nItemCurrIndex)
          For nPassNo = 1 To 2
            ; debugMsg(sProcName, ">> nPassNo=" + nPassNo)
            ; in pass 1 we draw lines (if reqd) for devices other than the current device
            ; in pass 2 we draw lines and markers for the current device
            If nPassNo = 1
              If (grEditorPrefs\bEditShowLvlCurvesOther = #False) And (grEditorPrefs\bEditShowPanCurvesOther = #False)
                Continue
              EndIf
              nItemFromIndex = 0
              nItemUpToIndex = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointMaxItem=" + aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointMaxItem)
            Else
              nItemFromIndex = nItemCurrIndex
              nItemUpToIndex = nItemCurrIndex
            EndIf
            If nItemFromIndex >= 0
              For nItemIndex = nItemFromIndex To nItemUpToIndex
                If (nPassNo = 1) And (nItemIndex = nItemCurrIndex)
                  bWantThis = #False
                Else
                  bWantThis = #True
                EndIf
                ; debugMsg(sProcName, "nPassNo=" + nPassNo + ", nItemIndex=" + nItemIndex + ", bWantThis=" + strB(bWantThis))
                If bWantThis
                  If aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                    sItemLogicalDev = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\sItemLogicalDev
                    sItemTracks = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\sItemTracks
                    nItemGraphChannels = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemGraphChannels
                    nDevNo = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemDevNo
                    ; debugMsg(sProcName, "include, sItemLogicalDev=" + sItemLogicalDev + ", sItemTracks=" + sItemTracks + ", nPointType=" + decodeLevelPointType(nPointType))
                    If nPassNo = 2
                      If (grEditorPrefs\bEditShowLvlCurvesSel) Or (grEditorPrefs\bEditShowPanCurvesSel)
                        Select nPointType
                          Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
                            LineXY(X, \nGraphTop, X, \nGraphBottom, #SCS_Grey)
                        EndSelect
                      EndIf
                    EndIf
                    Select nPointType
                      Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
                        fThisLevel = convertDBLevelToBVLevel(fDevDBLevel + aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel)
                        ; debugMsg(sProcName, "fDevDBLevel=" + StrF(fDevDBLevel,2) + ", \fItemRelDBLevel=" + StrF(aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel,2) + ", fThisLevel=" + formatLevel(fThisLevel))
                        If fThisLevel > grLevels\fMaxBVLevel
                          fThisLevel = grLevels\fMaxBVLevel
                        ElseIf fThisLevel < 0
                          fThisLevel = 0
                        EndIf
                        fThisPan = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan
                        nPrevLevelPointIndex = getPrevIncludedLevelPointIndex(nEditAudPtr, nDevNo, nPointTime)
                        ; debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex + ", nPrevLevelPointIndex=" + nPrevLevelPointIndex + ", nDevNo=" + nDevNo + ", nPointTime=" + timeToStringT(nPointTime))
                        If nPrevLevelPointIndex >= 0
                          nPrevLevelPointType = aAud(nEditAudPtr)\aPoint(nPrevLevelPointIndex)\nPointType
                        Else
                          nPrevLevelPointType = 0
                        EndIf
                        nPrevItemIndex = getLevelPointItemIndex(nEditAudPtr, nPrevLevelPointIndex, sItemLogicalDev, sItemTracks)
                        ; debugMsg(sProcName, decodeLevelPointType(nPointType) + " nPrevLevelPointIndex=" + nPrevLevelPointIndex + ", nPrevItemIndex=" + nPrevItemIndex)
                        If (nPrevLevelPointIndex = -1) Or (nPrevItemIndex = -1)
                          If aAud(nEditAudPtr)\nFadeInTime > 0
                            If nPointTime > (aAud(nEditAudPtr)\nAbsStartAt + aAud(nEditAudPtr)\nFadeInTime)
                              XPrevLP = XFI
                              fPrevLevel = fDevLevel
                            Else
                              ; level point earlier than end of fade-in
                              XPrevLP = XST
                              fPrevLevel = #SCS_MINVOLUME_SINGLE
                            EndIf
                          Else
                            ; no fade-in
                            XPrevLP = XST
                            fPrevLevel = fDevLevel
                          EndIf
                          fPrevPan = fDevPan
                        Else
                          XPrevLP = (aAud(nEditAudPtr)\aPoint(nPrevLevelPointIndex)\nPointTime / \fMillisecondsPerPixel) + \nGraphLeft
                          fPrevLevel = convertDBLevelToBVLevel(fDevDBLevel + aAud(nEditAudPtr)\aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemRelDBLevel)
                          If fPrevLevel > grLevels\fMaxBVLevel
                            fPrevLevel = grLevels\fMaxBVLevel
                          ElseIf fPrevLevel < 0
                            fPrevLevel = 0
                          EndIf
                          fPrevPan = aAud(nEditAudPtr)\aPoint(nPrevLevelPointIndex)\aItem(nPrevItemIndex)\fItemPan
                        EndIf
                        nTopL = \nGraphBottom - (\nGraphHeight * SLD_BVLevelToSliderValue(fPrevLevel) / #SCS_MAXVOLUME_SLD)
                        nTopL2 = \nGraphBottom - (\nGraphHeight * SLD_BVLevelToSliderValue(fThisLevel) / #SCS_MAXVOLUME_SLD)
                        If (grEditorPrefs\bEditShowLvlCurvesSel) And (nPrevLevelPointType >= #SCS_PT_START)
                          If nPassNo = 1
                            If grEditorPrefs\bEditShowLvlCurvesOther
                              LineXY(XPrevLP, nTopL, X, nTopL2, \nLPColor)
                              ; debugMsg(sProcName, decodeLevelPointType(nPointType) + " LineXY(" + XPrevLP + ", " + nTopL + ", " + X + ", " + nTopL2 + ", $" + Hex(\nLPColor,#PB_Long) + ")")
                              LineXY(XPrevLP, nTopL+1, X, nTopL2+1, #SCS_LevelPointEmphasis_Color)
                            EndIf
                          Else
                            LineXY(XPrevLP, nTopL, X, nTopL2, \nLPColor)
                            ; debugMsg(sProcName, decodeLevelPointType(nPointType) + " LineXY(" + XPrevLP + ", " + nTopL + ", " + X + ", " + nTopL2 + ", $" + Hex(\nLPColor,#PB_Long) + ")")
                            LineXY(XPrevLP, nTopL+1, X, nTopL2+1, #SCS_LevelPointEmphasis_Color)
                            If (X - XPrevLP) > AbsInt(nTopL2 - nTopL)
                              LineXY(XPrevLP, nTopL-1, X, nTopL2-1, \nLPColor)
                              ; debugMsg(sProcName, decodeLevelPointType(nPointType) + " LineXY(" + XPrevLP + ", " + Str(nTopL-1) + ", " + X + ", " + Str(nTopL2-1) + ", $" + Hex(\nLPColor,#PB_Long) + ")")
                              LineXY(XPrevLP, nTopL, X, nTopL2, #SCS_LevelPointEmphasis_Color)
                            Else
                              LineXY(XPrevLP+1, nTopL, X+1, nTopL2, \nLPColor)
                              ; debugMsg(sProcName, decodeLevelPointType(nPointType) + " LineXY(" + Str(XPrevLP+1) + ", " + nTopL + ", " + Str(X+1) + ", " + nTopL2 + ", $" + Hex(\nLPColor,#PB_Long) + ")")
                              LineXY(XPrevLP+1, nTopL+1, X+1, nTopL2+1, #SCS_LevelPointEmphasis_Color)
                            EndIf
                          EndIf
                        EndIf
                        If (nItemGraphChannels = 2) And (\nGraphChannels = 2)
                          nPrevPanY = \nGraphYMidPoint + (\nGraphHalfHeight * fPrevPan)
                          nThisPanY = \nGraphYMidPoint + (\nGraphHalfHeight * fThisPan)
                          If (grEditorPrefs\bEditShowPanCurvesSel) And (nPrevLevelPointType >= #SCS_PT_START)
                            If nPassNo = 1
                              If grEditorPrefs\bEditShowPanCurvesOther
                                LineXY(XPrevLP, nPrevPanY, X, nThisPanY, \nPanColor)
                              EndIf
                            Else
                              LineXY(XPrevLP, nPrevPanY, X, nThisPanY, \nPanColor)
                              If (X - XPrevLP) > AbsInt(nThisPanY - nPrevPanY)
                                LineXY(XPrevLP, nPrevPanY-1, X, nThisPanY-1, \nPanColor)
                              Else
                                LineXY(XPrevLP+1, nPrevPanY, X+1, nThisPanY, \nPanColor)
                              EndIf
                            EndIf
                          EndIf
                        EndIf
                        
                        If nPassNo = 2
                          If rWQF\bDisplayingLevelPoint
                            If nPointTime = rWQF\nCurrLevelPointTime
                              bCurrLevelPoint = #True
                            EndIf
                          EndIf
                          If bCurrLevelPoint
                            addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LP, nLevelPointIndex, #SCS_GRAPH_MARKER_LEVEL, nItemIndex, X-4, nTopL2-4, 8, 8, rWQF\nCurrLevelPointTime)
                          Else
                            addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LP, nLevelPointIndex, #SCS_GRAPH_MARKER_LEVEL, nItemIndex, X-4, nTopL2-4, 8, 8)
                          EndIf
                          If \nGraphChannels = 2
                            If bCurrLevelPoint
                              addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LP, nLevelPointIndex, #SCS_GRAPH_MARKER_PAN, nItemIndex, X-4, nThisPanY-4, 8, 8, rWQF\nCurrLevelPointTime)
                            Else
                              addGraphMarker(*rMG, #SCS_GRAPH_MARKER_LP, nLevelPointIndex, #SCS_GRAPH_MARKER_PAN, nItemIndex, X-4, nThisPanY-4, 8, 8)
                            EndIf
                          EndIf
                        EndIf
                    EndSelect
                  EndIf ; EndIf aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                EndIf ; EndIf bWantThis
              Next nItemIndex
            EndIf ; EndIf nItemFromIndex >= 0
          Next nPassNo
        EndIf ; EndIf nLevelPointIndex >= 0
        
      Case #SCS_SLICE_TYPE_CM
        LineXY(X, \nGraphTop, X, \nGraphBottom, \nCMColor) 
        LineXY(X+1, \nGraphTop, X+1, \nGraphBottom, \nCMColor)
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_CM, -1, -1, -1, X, YCM, 12, 12, -1, nCueMarkerId)
        
      Case #SCS_SLICE_TYPE_CP
        LineXY(X, \nGraphTop, X, \nGraphBottom, \nCMColor) 
        LineXY(X+1, \nGraphTop, X+1, \nGraphBottom, \nCMColor)
        addGraphMarker(*rMG, #SCS_GRAPH_MARKER_CP, -1, -1, -1, X, \nLoopBarTop, 12, 12, -1, nCueMarkerId)
        
    EndSelect
  EndWith
  
EndProcedure

Procedure drawLevelPointMarkers()
  ; PROCNAMECA(nEditAudPtr)
  Protected n
  Protected bCurrLevelPoint, bOtherSelectedLevelPoint, nPointId, nSelectedLevelPointIndex, nSelectedLevelPointId
  Protected nPassNo, bDrawThis
  Protected nMarkerColor
  Protected nCanvasWidth
  Protected nReqdX
  
  ; debugMsg0(sProcName, #SCS_START + ", grMG2\nMaxGraphMarker=" + grMG2\nMaxGraphMarker)
  ; listGraphMarkers()
  
  If aAud(nEditAudPtr)\bAudTypeF = #False
    ; Level Points are only used with Audio Files (Aud Type F), not with Video Files (Aud Type A)
    ProcedureReturn
  EndIf
  
  nCanvasWidth = OutputWidth()
  
  nSelectedLevelPointIndex = getCurrentItemData(WQF\cboDevSel)
  If nSelectedLevelPointIndex >= 0
    nSelectedLevelPointId = aAud(nEditAudPtr)\aPoint(nSelectedLevelPointIndex)\nPointId
  EndIf
  ; debugMsg0(sProcName, "nSelectedLevelPointIndex=" + nSelectedLevelPointIndex + ", GGT(WQF\cboDevSel)=" + GGT(WQF\cboDevSel) + ", nSelectedLevelPointId=" + nSelectedLevelPointId)
  
  For nPassNo = 1 To 3
    ; multi-pass so that current level point is drawn in the 2nd pass and will therefore always be on top, even if the next level point is very close
    ; 1st pass - draw non-selected image for all level points
    ; 2nd pass - draw selected level points other than the current level point (level markers only, not pan markers as multiple pan markers canot be adjusted simultaneously)
    ; 3rd pass - draw the current level point only
    For n = 0 To grMG2\nMaxGraphMarker
      With grMG2\aGraphMarker(n)
        ; debugMsg0(sProcName, "nPass=" + nPassNo + ", grMG2\aGraphMarker(" + n + ")\nGraphMarkerType=" + decodeGraphMarkerType(grMG2\aGraphMarker(n)\nGraphMarkerType))
        Select \nGraphMarkerType
          Case #SCS_GRAPH_MARKER_LP
            bCurrLevelPoint = #False
            bOtherSelectedLevelPoint = #False
            ; Deleted 11Feb2022 11.9.0
;             If rWQF\bDisplayingLevelPoint
;               If \nGraphMarkerTime = rWQF\nCurrLevelPointTime
;                 bCurrLevelPoint = #True
;               EndIf
;             EndIf
            ; End deleted 11Feb2022 11.9.0
            ; Added 11Feb2022 11.9.0
            If \nLevelPointId = nSelectedLevelPointId And nSelectedLevelPointId > 0
              bCurrLevelPoint = #True
            EndIf
            ; End added 11Feb2022 11.9.0
            ; debugMsg0(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", rWQF\nCurrLevelPointTime=" + rWQF\nCurrLevelPointTime + ", \nGraphMarkerTime=" + \nGraphMarkerTime + ", bCurrLevelPoint=" + strB(bCurrLevelPoint))
            If bCurrLevelPoint = #False
              If \nLevelPointIndex >= 0
                nPointId = aAud(nEditAudPtr)\aPoint(\nLevelPointIndex)\nPointId
                If checkSelectedCtrlHoldLP(nPointId)
                  bOtherSelectedLevelPoint = #True
                EndIf
              EndIf
            EndIf
            ; debugMsg0(sProcName, "\aPoint(" + \nLevelPointIndex + ")\nPointTime=" + aAud(nEditAudPtr)\aPoint(\nLevelPointIndex)\nPointTime + ", bOtherSelectedLevelPoint=" + strB(bOtherSelectedLevelPoint))
            
            nReqdX = \nX
            If (nReqdX < \nWidth) And (nReqdX > (0 - \nWidth))
              nReqdX = 0
            ElseIf (nReqdX > (nCanvasWidth - \nWidth)) And (nReqdX < (nCanvasWidth + \nWidth))
              nReqdX = (nCanvasWidth - \nWidth)
            EndIf
            Select nPassNo
              Case 1
                ; 1st pass - draw non-selected image for all level points
                If (\nLevelOrPan = #SCS_GRAPH_MARKER_PAN) And (grEditorPrefs\bEditShowPanCurvesSel)
                  ; debugMsg(sProcName, "calling DrawImage(ImageID(hAudGraphPan), " + nReqdX + ", " + \nY + ")")
                  DrawImage(ImageID(hAudGraphPan), nReqdX, \nY)
                ElseIf (\nLevelOrPan = #SCS_GRAPH_MARKER_LEVEL) And (grEditorPrefs\bEditShowLvlCurvesSel)
                  ; debugMsg(sProcName, "calling DrawImage(ImageID(hAudGraphLevel), " + nReqdX + ", " + \nY + ")")
                  DrawImage(ImageID(hAudGraphLevel), nReqdX, \nY)
                EndIf
                \nHotAreaX = nReqdX - 2
                \nHotAreaY = \nY - 2
                \nHotAreaWidth = \nWidth + 4
                \nHotAreaHeight = \nHeight + 4
              Case 2, 3
                bDrawThis = #False
                If (nPassNo = 2) And (bOtherSelectedLevelPoint)
                  ; 2nd pass - draw selected level points other than the current level point (level markers only, not pan markers as multiple pan markers canot be adjusted simultaneously)
                  If (\nLevelOrPan = #SCS_GRAPH_MARKER_LEVEL) And (grEditorPrefs\bEditShowLvlCurvesSel)
                    bDrawThis = #True
                  EndIf
                ElseIf (nPassNo = 3) And (bCurrLevelPoint)
                  ; 3rd pass - draw the current level point only
                  bDrawThis = #True
                EndIf
                ; debugMsg(sProcName, "bDrawThis=" + strB(bDrawThis))
                If bDrawThis
                  If \nLevelOrPan = #SCS_GRAPH_MARKER_PAN
                    nMarkerColor = grMG2\nPanColor
                  Else
                    nMarkerColor = grMG2\nLPColor
                  EndIf
                  If (\nLevelOrPan = #SCS_GRAPH_MARKER_PAN) And (grEditorPrefs\bEditShowPanCurvesSel)
                    Box(nReqdX-2, \nY-2, \nWidth+4, \nHeight+4, nMarkerColor)
                    DrawingMode(#PB_2DDrawing_Outlined)
                    Box(nReqdX-1, \nY-1, \nWidth+2, \nHeight+2, #SCS_Black)
                    DrawingMode(#PB_2DDrawing_Default)
                    DrawImage(ImageID(hAudGraphPan), nReqdX, \nY)
                  ElseIf (\nLevelOrPan = #SCS_GRAPH_MARKER_LEVEL) And (grEditorPrefs\bEditShowLvlCurvesSel)
                    If bCurrLevelPoint Or bOtherSelectedLevelPoint
                      Box(nReqdX-2, \nY-2, \nWidth+4, \nHeight+4, #SCS_Level_Color)
                      Box(nReqdX-1, \nY-1, \nWidth+2, \nHeight+2, #SCS_Black)
                      DrawImage(ImageID(hAudGraphLevelSelected), nReqdX, \nY)
                      ; debugMsg0(sProcName, "SELECTED \nLevelPointIndex=" + \nLevelPointIndex + ", \nLevelPointId=" + \nLevelPointId + ", bCurrLevelPoint=" + strB(bCurrLevelPoint) + ", bOtherSelectedLevelPoint=" + strB(bOtherSelectedLevelPoint))
                    Else
                      Box(nReqdX-2, \nY-2, \nWidth+4, \nHeight+4, nMarkerColor)
                      DrawingMode(#PB_2DDrawing_Outlined)
                      Box(nReqdX-1, \nY-1, \nWidth+2, \nHeight+2, #SCS_Black)
                      DrawingMode(#PB_2DDrawing_Default)
                      DrawImage(ImageID(hAudGraphLevel), nReqdX, \nY)
                    EndIf
                  EndIf
                  \nHotAreaX = nReqdX - 4
                  \nHotAreaY = \nY - 4
                  \nHotAreaWidth = \nWidth + 8
                  \nHotAreaHeight = \nHeight + 8
                EndIf
            EndSelect
        EndSelect
      EndWith
    Next n
  Next nPassNo

  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

;Description: To plot a Cue Marker & it's Label
Procedure drawCueMarkers(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  Protected n
  Protected nMarkerColor, hAudGraph
  Protected nCanvasWidth
  Protected nReqdX
  
  nCanvasWidth = OutputWidth()
  
  For n = 0 To *rMG\nMaxGraphMarker
    With *rMG\aGraphMarker(n)
      ;debugMsg(sProcName, "*rMG\aGraphMarker(" + n + ")\nGraphMarkerType=" + decodeGraphMarkerType(*rMG\aGraphMarker(n)\nGraphMarkerType))
      Select \nGraphMarkerType
        Case #SCS_GRAPH_MARKER_CM, #SCS_GRAPH_MARKER_CP
          nReqdX = \nX
          If (nReqdX < \nWidth) And (nReqdX > (0 - \nWidth))
            nReqdX = 0
          ElseIf (nReqdX > (nCanvasWidth - \nWidth)) And (nReqdX < (nCanvasWidth + \nWidth))
            nReqdX = (nCanvasWidth - \nWidth)
          EndIf
          
          If \nGraphMarkerType = #SCS_GRAPH_MARKER_CM
            nMarkerColor = *rMG\nCMColor
            hAudGraph = hAudGraphCueMarker
          Else
            nMarkerColor = *rMG\nCPColor
            hAudGraph = hAudGraphCuePoint
          EndIf
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(nReqdX-6, \nY-1, \nWidth+2, \nHeight+2, nMarkerColor)
          DrawingMode(#PB_2DDrawing_Default)
          DrawImage(ImageID(hAudGraph), nReqdX-6, \nY)            
          
          ; Hot Area for Cue Marker
          \nHotAreaX = nReqdX - 2
          \nHotAreaY = \nY - 2
          \nHotAreaWidth = \nWidth + 6
          \nHotAreaHeight = \nHeight + 6
      EndSelect
    EndWith
  Next n
EndProcedure

Procedure drawPosSlice(*rMG.tyMG)
  PROCNAMEC()
  Protected fThisTime.f, nOldSlice, nThisSlice
  ; Protected nGraphChan.l  ; long
  Protected bDrawingStartedByMe
  Protected X, nOldX
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grGraph2\bInGraphScanFile
    ProcedureReturn
  EndIf
  
  If *rMG\bDeviceAssigned = #False
    debugMsg(sProcName, "*rMG\bDeviceAssigned=" + strB(*rMG\bDeviceAssigned))
    ProcedureReturn
  EndIf
  
  If *rMG\nMouseDownSliceType = #SCS_SLICE_TYPE_CURR
    ; user currently changing current position (mouse down) so do not change the 'position' pointer
    debugMsg(sProcName, "*rMG\nMouseDownSliceType=#SCS_SLICE_TYPE_CURR")
    ProcedureReturn
  EndIf
  
  If nEditAudPtr < 0
    debugMsg(sProcName, "nEditAudPtr=" + getAudLabel(nEditAudPtr))
    ProcedureReturn
  EndIf
  
  With aAud(nEditAudPtr)
    ; 4Feb2019 11.8.0.2af added "Or (\nFileDataPtr < 0)" to the following to avoid a graph for another cue being loaded in a cue whose file cannot be found (and therefore \nFileDataPtr = -1)
    If (\nFileDataPtr <> *rMG\nFileDataPtrForGraph) Or (\nFileDataPtr < 0)
      debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nFileDataPtr=" + \nFileDataPtr + ", *rMG\nFileDataPtrForGraph=" + *rMG\nFileDataPtrForGraph)
      ProcedureReturn
    EndIf
    nThisSlice = #SCS_NO_SLICE
    nOldSlice = #SCS_NO_SLICE
    If \bAudTypeF
      If gbUseBASS  ; BASS
        If *rMG\dSamplePositionsPerPixel = 0.0
          *rMG\dSamplePositionsPerPixel = aAud(nEditAudPtr)\qFileBytes / aAud(nEditAudPtr)\nBytesPerSamplePos / *rMG\nGraphWidth
          debugMsg(sProcName, "*rMG\dSamplePositionsPerPixel=" + StrD(*rMG\dSamplePositionsPerPixel,4))
        EndIf
        fThisTime = \nRelFilePos + \nAbsMin
        nThisSlice = Int(fThisTime / *rMG\fMillisecondsPerPixel) ; INFO the formula for calculating nThisSlice should be the same as that used for calculating grGraph2\nSlicePos in drawGraph()
      Else ; SM-S
        fThisTime = \nRelFilePos + \nAbsMin
        nThisSlice = Int(fThisTime / *rMG\fMillisecondsPerPixel)
      EndIf
    ElseIf \bAudTypeA
      fThisTime = \nRelFilePos + \nAbsMin
      nThisSlice = Int(fThisTime / *rMG\fMillisecondsPerPixel)
    EndIf
    
    If (grGraph2\nSlicePos <> nThisSlice) And (nThisSlice <> #SCS_NO_SLICE)
      nOldSlice = grGraph2\nSlicePos
      grGraph2\nSlicePos = nThisSlice
      X = nThisSlice + *rMG\nGraphLeft  ; nb \nGraphLeft will be 0 or -ve
      nOldX = nOldSlice + *rMG\nGraphLeft
      If (X < 0) Or (X > *rMG\nVisibleWidth)
        ; outside visible area
        If (\bAudTypeF) And (grEditorPrefs\bAutoScroll)
          ; debugMsg(sProcName, "AutoScroll Start")
          *rMG\bInAutoScroll = #True
          *rMG\nGraphLeft = 0 - nThisSlice
          X = nThisSlice + *rMG\nGraphLeft  ; nb \nGraphLeft will be 0 or -ve
          nOldX = nOldSlice + *rMG\nGraphLeft
          drawGraph(*rMG)
          drawScale(*rMg)
          setViewStartAndEndFromVisibleGraph()
          WQF_setPosSlider()
          *rMG\bInAutoScroll = #False
        EndIf
        If (X < 0) Or (X >= *rMG\nVisibleWidth)
          ; (still) outside visible area
          If nOldSlice = #SCS_NO_SLICE
            ; no previous slice pos
            ProcedureReturn
          ElseIf (nOldX < 0) Or (nOldX >= *rMG\nVisibleWidth)
            ; previous slice pos also outside visible area
            ProcedureReturn
          EndIf
        EndIf
      EndIf
      
      ; if current slice pos or previous slice pos inside visible area, then redraw the graph, etc
      bDrawingStartedByMe = condStartGraphDrawing(*rMG)
      DrawImage(ImageID(*rMG\nGraphImage),0,0)
      ; debugMsg(sProcName, "DrawImage(ImageID(" + *rMG\nGraphImage + "),0,0)")
      drawPosCursor(X, *rMG\nGraphTop, *rMG\nGraphBottom, *rMG\nCursorColor, *rMG\nCursorShadowColor, #False)
      If fThisTime >= 0
        *rMG\nLastTimeMark = fThisTime
        ; debugMsg(sProcName, "*rMG\nLastTimeMark=" + *rMG\nLastTimeMark + ", *rMG\fMillisecondsPerPixel=" + StrF(*rMG\fMillisecondsPerPixel,3))
      EndIf
      condStopGraphDrawing(*rMG, bDrawingStartedByMe)
    EndIf
    
  EndWith
  
EndProcedure

Procedure drawGraph(*rMG.tyMG, pAudPtr=-5)
  PROCNAMECA(pAudPtr)
  ; NOTE: Audio graphs are drawn using data stored in the arrays *rMG\aSlicePeakL(), *rMG\aSlicePeakR(), *rMG\aSliceMinL() and *rMG\aSliceMinR()
  ; NOTE: Those arrays are populated by Procedure loadSlicePeakAndMinArraysFromSamplesArray() or Procedure loadSlicePeakAndMinArraysFromDatabase()
  Protected nMGNumber
  Protected k, n, X, Y1, Y2, l2
  Protected nFirstDevChannel.l  ; long
  Protected nFirstIncludedSlice, nLastIncludedSlice
  Protected nCurrPos
  Protected nTextX, nTextY
  Protected bDrawingStartedByMe
  Protected byPeakL.b, byMinL.b, byPeakR.b, byMinR.b
  Protected nArraySize
  Protected bLineVisible
  Protected nIncludedLeft, nIncludedWidth
  Protected nStartSlice, nEndSlice, nFadeInSlice, nFadeOutSlice
  Protected nFadeInSliceSpan, nFadeOutSliceSpan
  Protected fFadeFactor.f
  Protected fPosInFile.f, nPosInFile
  Protected nDevNo
  Protected nGraphY
  Protected nAudPtr, sSubType.s
  Protected bGraphAdjLevels
  Protected bDisplayNormalized
  Protected qChannelBytePosition.q
  Protected nFileDataPtr
  Protected nBytesPerSamplePos
  Static nCallNumber
  
  nCallNumber + 1
  ; debugMsg(sProcName, #SCS_START + ", nCallNumber=" + nCallNumber + ", *rMG\sMGNumber=" + *rMG\sMGNumber +
  ;                     ", *rMG\nLastTimeMark=" + *rMG\nLastTimeMark + ", *rMG\bAudPlaceHolder=" + strB(*rMG\bAudPlaceHolder) + ", *rMG\bDeviceAssigned=" + strB(*rMG\bDeviceAssigned))
  
  nMGNumber = *rMG\nMGNumber
  
  If pAudPtr = -5
    nAudPtr = nEditAudPtr
  Else
    nAudPtr = pAudPtr
  EndIf
  
  If nAudPtr < 0
    ProcedureReturn
  EndIf
  
  With aAud(nAudPtr)
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bAudPlaceHolder=" + strB(\bAudPlaceHolder) + ", \qFileBytes=" + \qFileBytes + ", \nBytesPerSamplePos=" + \nBytesPerSamplePos)
    ; If \nFileDataPtr >= 0
    ;   debugMsg(sProcName, "gaFileData(" + \nFileDataPtr + ")\qFileSize=" + gaFileData(\nFileDataPtr)\qFileSize)
    ; EndIf
    If nMGNumber = 5
      If \bAudPlaceHolder
        ProcedureReturn
      EndIf
    ElseIf (\bAudPlaceHolder) Or (\qFileBytes = 0) Or (\nBytesPerSamplePos = 0)
      ProcedureReturn
    EndIf
    nBytesPerSamplePos = \nBytesPerSamplePos   ; added 30Oct2015 11.4.1.2f for handling files with more than 2 channels
    
    If \bAudTypeF
      ; The following only applies to Audio File graphs - see "Graph File Levels Normalized" etc in the Help for Editor/Audio File Cues
      ; If none of the following apply then "Graph File Levels: The whole graph is based on the levels recorded in the audio file. This is the default setting." applies.
      ; This is, therefore, also the setting for video file cues.
      Select grEditorPrefs\nGraphDisplayMode
        Case #SCS_GRAPH_ADJ
          bGraphAdjLevels = #True
        Case #SCS_GRAPH_ADJN
          bGraphAdjLevels = #True
          bDisplayNormalized = #True
        Case #SCS_GRAPH_FILEN
          bDisplayNormalized = #True
      EndSelect
    EndIf

  EndWith
  
  With *rMG
    If (\bAudPlaceHolder) Or (\bDeviceAssigned = #False)
      ProcedureReturn
    EndIf
    
    If \bInDrawGraph
      ProcedureReturn
    EndIf
    \bInDrawGraph = #True
    
    \bTipDrawn = #False
    
    clearGraphMarkers(*rMG)
    
    k = nAudPtr
    If aAud(k)\nFirstDev < 0
      \bInDrawGraph = #False
      ProcedureReturn
    EndIf
    nFirstDevChannel = aAud(k)\nBassChannel[aAud(k)\nFirstDev]
    If nFirstDevChannel = 0
      nFirstDevChannel = aAud(k)\nGraphChan
    EndIf
    If nMGNumber = 2
      nDevNo = rWQF\nCurrDevNo
    Else ; nMGNumber = 3, 4 or 5
      nDevNo = aAud(k)\nFirstDev
    EndIf
    ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nBytesPerSamplePos=" + aAud(k)\nBytesPerSamplePos + ", \nFileChannels=" + aAud(k)\nFileChannels + ", *rMG\nGraphChannels=" + \nGraphChannels)
    If aAud(k)\bAudTypeF
      If \dSamplePositionsPerPixel = 0.0
        \dSamplePositionsPerPixel = aAud(k)\qFileBytes / aAud(k)\nBytesPerSamplePos / \nGraphWidth
      EndIf
      ; debugMsg0(sProcName, "aAud(" + getAudLabel(k) + ")\qFileBytes=" + aAud(k)\qFileBytes + ", \nGraphWidth=" + \nGraphWidth + ", \dSamplePositionsPerPixel=" + StrD(\dSamplePositionsPerPixel,4))
    EndIf
    
    If StartDrawing(ImageOutput(\nGraphImage))
      ; debugMsg0(sProcName, "nCallNumber=" + nCallNumber + ", " + \sMGNumber + ", drawing \nGraphImage (" + \nGraphImage + ") For aAud(" + getAudLabel(k) + "), file " + GetFilePart(aAud(k)\sFileName))
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
      
      ; set nGraphLeftBaseY and nGraphRightBaseY at the mid-point (+0) of the left and right graphs
      If \nGraphChannels = 1
        \nGraphLeftBaseY = (\nGraphHeight >> 1)
        \nGraphLeftBaseY + \nGraphTop
        \nGraphPartHeight = \nGraphHeight >> 1
      Else
        \nGraphLeftBaseY = (\nGraphHeight >> 2)
        \nGraphRightBaseY = (\nGraphHeight * 3 / 4)
        \nGraphLeftBaseY + \nGraphTop
        \nGraphRightBaseY + \nGraphTop
        \nGraphPartHeight = \nGraphHeight >> 2
      EndIf
      ; debugMsg(sProcName, "\nGraphLeftBaseY=" + \nGraphLeftBaseY + ", \nGraphRightBaseY=" + \nGraphRightBaseY)
      
      \fYFactor = \nGraphPartHeight / 128
      If bDisplayNormalized
        \fYFactor * \fNormalizeFactor
      EndIf
      ; debugMsg(sProcName, "\nGraphPartHeight=" + \nGraphPartHeight + ", bDisplayNormalized=" + strB(bDisplayNormalized) + ", \fNormalizeFactor=" + StrF(\fNormalizeFactor,4) + ", \fYFactor=" + StrF(\fYFactor,4))
      
      nFirstIncludedSlice = 0
      nLastIncludedSlice = \nGraphMaxX
      
      If grGraph2\nSliceST > nFirstIncludedSlice
        nFirstIncludedSlice = grGraph2\nSliceST
      EndIf
      If grGraph2\nSliceMaxLoop >= 0
        If (grGraph2\nSliceLS(0) <> #SCS_NO_SLICE) And (grGraph2\nSliceLS(0) < nFirstIncludedSlice)
          nFirstIncludedSlice = grGraph2\nSliceLS(0)
        EndIf
      EndIf
      
      If grGraph2\nSliceEN <> #SCS_NO_SLICE
        nLastIncludedSlice = grGraph2\nSliceEN
      EndIf
      If grGraph2\nSliceMaxLoop >= 0
        If (grGraph2\nSliceLE(grGraph2\nSliceMaxLoop) <> #SCS_NO_SLICE) And (grGraph2\nSliceLE(grGraph2\nSliceMaxLoop) > nLastIncludedSlice)
          nLastIncludedSlice = grGraph2\nSliceLE(grGraph2\nSliceMaxLoop)
        EndIf
      EndIf
      
      nStartSlice = grGraph2\nSliceST
      If grGraph2\nSliceFI > 0
        nFadeInSlice = grGraph2\nSliceFI
        nFadeInSliceSpan = nFadeInSlice - nStartSlice
      Else
        nFadeInSlice = -1
      EndIf
      
      nEndSlice = grGraph2\nSliceEN
      If grGraph2\nSliceFO > 0
        nFadeOutSlice = grGraph2\nSliceFO
        nFadeOutSliceSpan = nEndSlice - nFadeOutSlice
      Else
        nFadeOutSlice = -1
      EndIf
      
      nArraySize = ArraySize(\aSlicePeakL())
      \nFirstIndex = 0 - \nGraphLeft
      \nLastIndex = \nFirstIndex + \nVisibleWidth - 1
      ; debugMsg(sProcName, "\nGraphLeft=" + \nGraphLeft + ", \nFirstIndex=" + \nFirstIndex + ", \nLastIndex=" + \nLastIndex + ", \nVisibleWidth=" + \nVisibleWidth + ", nArraySize=" + nArraySize)
      If \nLastIndex > nArraySize
        \nLastIndex = nArraySize
        debugMsg(sProcName, "\nLastIndex adjusted to " + \nLastIndex)
      EndIf
      If (nFirstIncludedSlice >= 0) Or (nLastIncludedSlice < \nInnerWidth)
        Box(0, \nGraphTop, \nVisibleWidth, \nGraphHeight, \nEXBGColor)
      EndIf
      nIncludedLeft = \nGraphLeft + nFirstIncludedSlice
      nIncludedWidth = nLastIncludedSlice - nFirstIncludedSlice
      ; debugMsg(sProcName, "\nInnerWidth=" + \nInnerWidth + ", \nGraphLeft=" + \nGraphLeft + ", nIncludedLeft=" + nIncludedLeft + ", nIncludedWidth=" + nIncludedWidth +
      ;                     ", nFirstIncludedSlice=" + nFirstIncludedSlice + ", nLastIncludedSlice=" + nLastIncludedSlice + ", \nGraphMaxX=" + \nGraphMaxX)
      If nIncludedLeft < 0
        nIncludedWidth + nIncludedLeft
        nIncludedLeft = 0
      EndIf
      If (nIncludedLeft + nIncludedWidth) > \nVisibleWidth
        nIncludedWidth = (\nVisibleWidth - nIncludedLeft)
        ; debugMsg(sProcName, "nIncludedWidth=" + Str(nIncludedWidth))
      EndIf
      Box(nIncludedLeft, \nGraphTop, nIncludedWidth, \nGraphHeight, \nINBGColor)
      ; debugMsg(sProcName, "Box(" + nIncludedLeft + ", " + \nGraphTop + ", " + nIncludedWidth + ", " + \nGraphHeight + ", \nINBGColor)")
      
      ; debugMsg(sProcName, "\nFileChannels=" + \nFileChannels + ", ArraySize(\aSlicePeakL())=" + ArraySize(\aSlicePeakL()) +
      ; ", nFirstIncludedSlice=" + nFirstIncludedSlice + ", nLastIncludedSlice=" + nLastIncludedSlice + ", nGraphLeftBaseY=" + \nGraphLeftBaseY)
      ; debugMsg(sProcName, "\nFileChannels=" + \nFileChannels + ", \nGraphChannels=" + \nGraphChannels + ", \nFirstIndex=" + \nFirstIndex + ", \nLastIndex=" + \nLastIndex)
      X = 0
      If \nGraphChannels = 1
        For n = \nFirstIndex To \nLastIndex
          byPeakL = \aSlicePeakL(n) * \fYFactor
          byMinL = \aSliceMinL(n) * \fYFactor
          ; added 21Dec2016 11.6.0 so that if there's any audio at all in the slice then this will show on the audio graph
          ; (just show either peak or min, not both, so a single pixel is drawn - note that to get here means the level represnts less than half a pixel, but we want to show there is audio here)
          If byPeakL = 0 And byMinL = 0
            If \aSlicePeakL(n) > 0
              byPeakL = 1
            ElseIf \aSliceMinL(n) < 0
              byMinL = -1
            EndIf
          EndIf
          ; end added 21Dec2016 11.6.0
          If bGraphAdjLevels
            fPosInFile = n * \fMillisecondsPerPixel
            nPosInFile = fPosInFile
            calcLevelsForPos(nMGNumber, nAudPtr, nDevNo, nPosInFile)
            While #True ; dummy loop to enable 'Break' after using fFadeFactor once
              If nFadeInSliceSpan > 0
                If (n >= nStartSlice) And (n < nFadeInSlice)
                  fFadeFactor = (n - nStartSlice) / nFadeInSliceSpan
                  byPeakL * (fFadeFactor * \fBVLevel)
                  byMinL * (fFadeFactor * \fBVLevel)
                  Break ; quit dummy loop
                EndIf
              EndIf
              If nFadeOutSliceSpan > 0
                If (n > nFadeOutSlice) And (n <= nEndSlice)
                  fFadeFactor = (nEndSlice - n) / nFadeOutSliceSpan
                  byPeakL * (fFadeFactor * \fBVLevel)
                  byMinL * (fFadeFactor * \fBVLevel)
                  Break ; quit dummy loop
                EndIf
              EndIf
              byPeakL * \fBVLevel
              byMinL * \fBVLevel
              Break ; quit dummy loop
            Wend
          EndIf
          If (byPeakL <> 0) Or (byMinL <> 0)
            If (n < nFirstIncludedSlice) Or (n > nLastIncludedSlice)
              LineXY(X, \nGraphLeftBaseY - byMinL, X, \nGraphLeftBaseY - byPeakL + 1, \nEXFGColorL)
            Else
              LineXY(X, \nGraphLeftBaseY - byMinL, X, \nGraphLeftBaseY - byPeakL + 1, \nINFGColorL)
            EndIf
          EndIf
          X + 1
        Next n
        
      Else
        ; Comment added 30Jul2024 11.10.3av
        ; In SCS, audio/video files that have more than 2 channels will have their audio graphs displayed as just two channels.
        ; The 'left' channel will be the sum of channels 1, 3, 5, etc, and the 'right' channel will be the sum of channels 2, 4, 6, etc.
        ; So the number of 'graph channels' for these files should be set to 2.
        ; End comment added 30Jul2024 11.10.3av
        ; debugMsg(sProcName, "\nFirstIndex=" + \nFirstIndex + ", \nLastIndex=" + \nLastIndex)
        For n = \nFirstIndex To \nLastIndex
          If n > ArraySize(\aSlicePeakL())
            debugMsg(sProcName, "\nGraphLeft=" + \nGraphLeft + ", \nGraphWidth=" + \nGraphWidth + ", \nInnerWidth=" + \nInnerWidth + ", \nVisibleWidth=" + \nVisibleWidth)
            debugMsg(sProcName, "n=" + n + ", \nFirstIndex=" + \nFirstIndex + ", \nLastIndex=" + \nLastIndex)
          EndIf
          CheckSubInRange(n, ArraySize(\aSlicePeakL()), "rMG" + nMGNumber + "\aSlicePeakL()")
          byPeakL = \aSlicePeakL(n) * \fYFactor
          byMinL = \aSliceMinL(n) * \fYFactor
          byPeakR = \aSlicePeakR(n) * \fYFactor
          byMinR = \aSliceMinR(n) * \fYFactor
          ; added 21Dec2016 11.6.0 so that if there's any audio at all in the slice then this will show on the audio graph
          ; (just show either peak or min, not both, so a single pixel is drawn - note that to get here means the level represnts less than half a pixel, but we want to show there is audio here)
          If byPeakL = 0 And byMinL = 0
            If \aSlicePeakL(n) > 0
              byPeakL = 1
            ElseIf \aSliceMinL(n) < 0
              byMinL = -1
            EndIf
          EndIf
          If byPeakR = 0 And byMinR = 0
            If \aSlicePeakR(n) > 0
              byPeakR = 1
            ElseIf \aSliceMinR(n) < 0
              byMinR = -1
            EndIf
          EndIf
          ; end added 21Dec2016 11.6.0
          ; debugMsg(sProcName, "\aSliceMinL(" + n + ")=" + \aSliceMinL(n) + ", \aSliceMinR(" + n + ")=" + \aSliceMinR(n) + ", \fYFactor=" + StrF(\fYFactor) + ", byMinL=" + byMinL + ", byMinR=" + byMinR)
          If bGraphAdjLevels
            While #True ; dummy loop to enable 'Break' after using fFadeFactor once
              fPosInFile = n * \fMillisecondsPerPixel
              nPosInFile = fPosInFile
              calcLevelsForPos(nMGNumber, nAudPtr, nDevNo, nPosInFile)
              ; debugMsg(sProcName, "n=" + n + ", nFadeInSliceSpan=" + Str(nFadeInSliceSpan) + ", nFadeOutSliceSpan=" + Str(nFadeOutSliceSpan) +
              ; ", nStartSlice=" + Str(nStartSlice) + ", nFadeInSlice=" + Str(nFadeInSlice) + ", nFadeOutSlice=" + Str(nFadeOutSlice) + ", nEndSlice=" + Str(nEndSlice))
              If nFadeInSliceSpan > 0
                If (n >= nStartSlice) And (n < nFadeInSlice)
                  fFadeFactor = (n - nStartSlice) / nFadeInSliceSpan
                  byPeakL * (fFadeFactor * \fBVLevelLeft)
                  byMinL * (fFadeFactor * \fBVLevelLeft)
                  byPeakR * (fFadeFactor * \fBVLevelRight)
                  byMinR * (fFadeFactor * \fBVLevelRight)
                  Break ; quit dummy loop
                EndIf
              EndIf
              If nFadeOutSliceSpan > 0
                If (n > nFadeOutSlice) And (n <= nEndSlice)
                  fFadeFactor = (nEndSlice - n) / nFadeOutSliceSpan
                  byPeakL * (fFadeFactor * \fBVLevelLeft)
                  byMinL * (fFadeFactor * \fBVLevelLeft)
                  byPeakR * (fFadeFactor * \fBVLevelRight)
                  byMinR * (fFadeFactor * \fBVLevelRight)
                  Break ; quit dummy loop
                EndIf
              EndIf
              ; debugMsg(sProcName, "n=" + n + ", \fBVLevelLeft=" + traceLevel(\fBVLevelLeft) + ", \fBVLevelRight=" + traceLevel(\fBVLevelRight))
              byPeakL * \fBVLevelLeft
              byMinL * \fBVLevelLeft
              byPeakR * \fBVLevelRight
              byMinR * \fBVLevelRight
              Break ; quit dummy loop
            Wend
          EndIf
;           If n < 10
;             debugMsg(sProcName, "nCallNumber=" + nCallNumber + ", bGraphAdjLevels=" + strB(bGraphAdjLevels) +
;                                 ", \aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", \aSliceMinL(" + n + ")=" + \aSliceMinL(n) +
;                                 ", \fBVLevelLeft=" + formatLevel(\fBVLevelLeft) + ", byPeakL=" + byPeakL + ", byMinL=" + byMinL)
;           EndIf
          ; debugMsg(sProcName, "X=" + X + ", n=" + n + ", \fBVLevelLeft=" + traceLevel(\fBVLevelLeft) + ", \fBVLevelRight=" + traceLevel(\fBVLevelRight) + ", byPeakL=" + byPeakL + ", byPeakR=" + byPeakR)
          ; debugMsg(sProcName, "X=" + X + ", \aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", \aSlicePeakR(" + n + ")=" + \aSlicePeakR(n) + ", byPeakL=" + byPeakL + ", byPeakR=" + byPeakR)
          ; debugMsg(sProcName, "X=" + X + ", \aSliceMinL(" + n + ")=" + \aSliceMinL(n) + ", \aSliceMinR(" + n + ")=" + \aSliceMinR(n) + ", byMinL=" + byMinL + ", byMinR=" + byMinR)
          If (byPeakL <> 0) Or (byMinL <> 0)
            If (n < nFirstIncludedSlice) Or (n > nLastIncludedSlice)
              LineXY(X, \nGraphLeftBaseY - byMinL, X, \nGraphLeftBaseY - byPeakL + 1, \nEXFGColorL)
            Else
              LineXY(X, \nGraphLeftBaseY - byMinL, X, \nGraphLeftBaseY - byPeakL + 1, \nINFGColorL)
            EndIf
          EndIf
          If (byPeakR <> 0) Or (byMinR <> 0)
            If (n < nFirstIncludedSlice) Or (n > nLastIncludedSlice)
              LineXY(X, \nGraphRightBaseY - byMinR, X, \nGraphRightBaseY - byPeakR + 1, \nEXFGColorR)
            Else
              LineXY(X, \nGraphRightBaseY - byMinR, X, \nGraphRightBaseY - byPeakR + 1, \nINFGColorR)
            EndIf
          EndIf
          X + 1
        Next n
        
      EndIf
      
      ; display horizontal lines, graph-width, for the selected device's level
      calcLevelsForDevNo(nMGNumber, nAudPtr, nDevNo, \nGraphChannels)
      Y1 = \nGraphBottom - (\nGraphHeight * SLD_BVLevelToSliderValue(\fBVLevel) / #SCS_MAXVOLUME_SLD)
      LineXY(0, Y1, OutputWidth(), Y1, \nLVColor)
      
      If \nGraphChannels = 2
        ; draw centre line
        LineXY(0, \nGraphYMidPoint, OutputWidth(), \nGraphYMidPoint, #SCS_Grey)
        ; debugMsg0(sProcName, "Centre line: LineXY(0, " + \nGraphYMidPoint + ", " + OutputWidth() + ", " + \nGraphYMidPoint + ", #SCS_Grey)")
      Else
        ; debugMsg0(sProcName, "\nGraphChannels=" + \nGraphChannels)
      EndIf
      
      ; NOTE the order of the following procedure calls is important, to ensure the 'most important' special slices are drawn last so that they appear on top of lesser important special slices
      ; The order is: (1) cue markers, with CP first, then CM; (2) level points; (3) start and end; (4) loops; (5) fade-in and fade-out
      ; (1) cue markers
      addGraphMarkersForCueMarkers(*rMG)
      drawCueMarkers(*rMG)
      
      ; (2) level points
      addGraphMarkersForLevelPoints(*rMG)
      drawLevelPointMarkers()
      
      ; (3) start and end
      If grGraph2\nSliceST <> #SCS_NO_SLICE
        ; draw 'start at' line
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_ST, grGraph2\nSliceST)
      EndIf
      If grGraph2\nSliceEN <> #SCS_NO_SLICE
        ; draw 'end at' line
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_EN, grGraph2\nSliceEN)
      EndIf
      
      ; (4) loops
      For l2 = 0 To grGraph2\nSliceMaxLoop
        ; draw 'loop start' line
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_LS, grGraph2\nSliceLS(l2), -1, l2)
        ; draw 'loop end' line
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_LE, grGraph2\nSliceLE(l2), -1, l2)
      Next l2
      
      ; (5) fade-in and fade-out
      ; debugMsg(sProcName, "grGraph2\nSliceFI=" + grGraph2\nSliceFI)
      If grGraph2\nSliceFI <> #SCS_NO_SLICE
        ; draw 'fade-in' line
        ; debugMsg(sProcName, "calling drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_FI, " + grGraph2\nSliceFI + ", " + grGraph2\nSliceST + ")")
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_FI, grGraph2\nSliceFI, grGraph2\nSliceST)
      EndIf
      If grGraph2\nSliceFO <> #SCS_NO_SLICE
        ; draw 'fade-out' line
        drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_FO, grGraph2\nSliceFO, grGraph2\nSliceEN)
      EndIf
      
      sSubType = getSubTypeForAud(k)
      If aAud(k)\nFileDuration > getFileScanMaxLengthMS(sSubType) And getFileScanMaxLength(sSubType) > 0
        drawNoAudioGraphMsg(k)
      EndIf
      
      StopDrawing()
    EndIf
    
    nFileDataPtr = aAud(k)\nFileDataPtr
    ; debugMsg(sProcName, "nFileDataPtr=" + nFileDataPtr)
    If nFileDataPtr >= 0
      sSubType = getSubTypeForAud(k)
      If aAud(k)\nFileDuration <= getFileScanMaxLengthMS(sSubType) Or getFileScanMaxLength(sSubType) < 0
        If IsImage(gaFileData(nFileDataPtr)\nInitGraphImage)
          If StartDrawing(ImageOutput(gaFileData(nFileDataPtr)\nInitGraphImage))
            DrawImage(ImageID(\nGraphImage),0,0)
            StopDrawing()
          EndIf
        EndIf
      EndIf
    EndIf
    
    Select nMGNumber
      Case 2
        ; grMG2 is used by fmEditQF and associated routines
        If StartDrawing(CanvasOutput(WQF\cvsGraph))
          ; debugMsg(sProcName, "WQF\cvsGraph OutputWidth()=" + OutputWidth() + ", OutputHeight()=" + OutputHeight() +
          ;                     ", ImageWidth(\nGraphImage)=" + ImageWidth(\nGraphImage) + ", ImageHeight(\nGraphImage)=" + ImageHeight(\nGraphImage))
          DrawImage(ImageID(\nGraphImage),0,0)
          If \nMouseDownSliceType = #SCS_SLICE_TYPE_CURR
            grGraph2\nSlicePos = \nReposMouseTime / \fMillisecondsPerPixel
          Else
            If gbUseBASS
              qChannelBytePosition = BASS_ChannelGetPosition(nFirstDevChannel, #BASS_POS_BYTE)
              If qChannelBytePosition >= 0
                fPosInFile = Int(BASS_ChannelBytes2Seconds(nFirstDevChannel, qChannelBytePosition) * 1000)
                grGraph2\nSlicePos = Int(fPosInFile / \fMillisecondsPerPixel) ; INFO the formula for calculating grGraph2\nSlicePos should be the same as that used for calculating nThisSlice in drawPosSlice()
              EndIf
            Else  ; SM-S
              If aAud(nAudPtr)\nSMSManualStartPos >= 0
                nCurrPos = aAud(nAudPtr)\nSMSManualStartPos
              Else
                nCurrPos = getSMSTrackTimeInMS(aAud(nAudPtr)\sPPrimaryChan)
                If (nCurrPos = 0) And (aAud(k)\nAbsStartAt > 0)
                  nCurrPos = aAud(nAudPtr)\nAbsStartAt
                EndIf
              EndIf
              grGraph2\nSlicePos = nCurrPos / \fMillisecondsPerPixel
            EndIf
          EndIf
          ; draw 'current position' line
          ; debugMsg(sProcName, "calling drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CURR, " + grGraph2\nSlicePos + ")")
          drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CURR, grGraph2\nSlicePos)
          StopDrawing()
        EndIf
      Case 5
        ; grMG5 is used by fmEditQA and associated routines
        If StartDrawing(CanvasOutput(WQA\cvsGraphQA))
          ; debugMsg(sProcName, "WQA\cvsGraphQA OutputWidth()=" + OutputWidth() + ", OutputHeight()=" + OutputHeight() +
          ;                     ", ImageWidth(\nGraphImage)=" + ImageWidth(\nGraphImage) + ", ImageHeight(\nGraphImage)=" + ImageHeight(\nGraphImage))
          DrawImage(ImageID(\nGraphImage),0,0)
          If \nMouseDownSliceType = #SCS_SLICE_TYPE_CURR
            grGraph2\nSlicePos = \nReposMouseTime / \fMillisecondsPerPixel
          EndIf
          ; draw 'current position' line
          ; debugMsg(sProcName, "calling drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CURR, " + grGraph2\nSlicePos + ")")
          drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CURR, grGraph2\nSlicePos)
          StopDrawing()
        EndIf
    EndSelect
    
    \bInitGraphDrawn = #True
    \bInDrawGraph = #False
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resizeInnerAreaOfGraph(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  
  ; debugMsg(sProcName, #SCS_START + ", *rMG\sMGNumber=" + *rMG\sMGNumber)
  
  If *rMG\nMGNumber = 2 Or *rMG\nMGNumber = 5
    ASSERT_THREAD(#SCS_THREAD_MAIN)
  EndIf
  
  With *rMG
    ; debugMsg0(sProcName, \sMGNumber + "\nInnerWidth=" + \nInnerWidth)
    Select \nMGNumber
      Case 2, 5
        ; grMG2 is used by fmEditQF and associated routines
        ; grMG5 is used by fmEditQA and associated routines
        If GadgetWidth(\nCanvasGadget) <> \nVisibleWidth
          ResizeGadget(\nCanvasGadget, #PB_Ignore, #PB_Ignore, \nVisibleWidth, #PB_Ignore)
          \bInitDataLoaded = #False
        EndIf
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        ; no action
    EndSelect
    \nCanvasWidth = \nInnerWidth
    \nGraphWidth = \nInnerWidth
    ; debugMsg(sProcName, "" + \sMGNumber + "\nInnerWidth=" + \nInnerWidth + ", \nGraphWidth=" + \nGraphWidth)
    \nGraphRight = \nGraphLeft + \nGraphWidth - 1
    \nLoopBarWidth = \nInnerWidth - \nLoopBarLeft
    \nSEBarWidth = \nInnerWidth - \nSEBarLeft
    \nTimeBarWidth = \nInnerWidth - \nTimeBarLeft
    ; debugMsg(sProcName, \sMGNumber + " calling createGraphImageIfReqd(*rMG)")
    createGraphImageIfReqd(*rMG)
    
    If \nMGNumber = 3
      ; duplicate into grMG4
      grMG4\nCanvasWidth = \nCanvasWidth
      grMG4\nGraphWidth = \nGraphWidth
      ; debugMsg(sProcName, "" + grMG4\sMGNumber + "\nInnerWidth=" + grMG4\nInnerWidth + ", \nGraphWidth=" + grMG4\nGraphWidth)
      grMG4\nGraphRight = \nGraphRight
      grMG4\nLoopBarWidth = \nLoopBarWidth
      grMG4\nSEBarWidth = \nSEBarWidth
      grMG4\nTimeBarWidth = \nTimeBarWidth
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resizeGraph(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  ; designed for width changes only, not height changes
  Protected nFileDataPtr
  Protected bSaveToTempDatabase
  
  debugMsg(sProcName, #SCS_START)
  
  ; Added 1Mar2025 11.10.7-b09 following email from Andrea Gambuzza where after disconnecting a monitor this procedure had been called with
  ; nEditAudPtr presumably negative, because the log showed the above 'start' message without an aud ptr, even though PROCNAMECA(nEditAudPtr)
  ; is set at the start
  If nEditAudPtr < 0
    ProcedureReturn
  EndIf
  ; End added 1Mar2025 11.10.7-b09
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With *rMG
    \nVisibleWidth = GadgetWidth(WQF\cntGraph)  ; visible width (ie the width of the container \cntGraph)
    ; debugMsg(sProcName, ">>1 \nVisibleWidth=" + \nVisibleWidth)
    \nInnerWidth = \nVisibleWidth
    ; debugMsg(sProcName, "calling resizeInnerAreaOfGraph(*rMG)")
    resizeInnerAreaOfGraph(*rMG)
    ; debugMsg(sProcName, "\nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth)
    \nGraphMaxX = \nGraphWidth - 1
    ; debugMsg(sProcName, "\nGraphMaxX=" + \nGraphMaxX)
    
    doReDim(\aSlicePeakL, \nGraphMaxX, \sMGNumber + "\aSlicePeakL()")
    doReDim(\aSlicePeakR, \nGraphMaxX, \sMGNumber + "\aSlicePeakR()")
    doReDim(\aSliceMinL, \nGraphMaxX, \sMGNumber + "\aSliceMinL()")
    doReDim(\aSliceMinR, \nGraphMaxX, \sMGNumber + "\aSliceMinR()")
    
    \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
    \bInitGraphDrawn = #False
    \bInDrawGraph = #False
    If getZoomValue() <= 1
      bSaveToTempDatabase = #True
    EndIf
    
    nFileDataPtr = \nFileDataPtrForGraph
    If nFileDataPtr >= 0
      ; File duration tests added 23Jan2024 11.10.1 as resizing the editor window could (re)draw the audio graph without checking the duration
      If aAud(nEditAudPtr)\bAudTypeA
        If aAud(nEditAudPtr)\nFileDuration <= grEditingOptions\nFileScanMaxLengthVideoMS Or grEditingOptions\nFileScanMaxLengthVideo < 0
          debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(*rMG, " + nFileDataPtr + ", -1, " + getAudLabel(nEditAudPtr) + ", " + strB(bSaveToTempDatabase) + ") for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
          loadSlicePeakAndMinArraysFromSamplesArray(*rMG, nFileDataPtr, -1, nEditAudPtr, bSaveToTempDatabase)
        EndIf
      Else
        If aAud(nEditAudPtr)\nFileDuration <= grEditingOptions\nFileScanMaxLengthAudioMS Or grEditingOptions\nFileScanMaxLengthAudio < 0
          debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(*rMG, " + nFileDataPtr + ", -1, " + getAudLabel(nEditAudPtr) + ", " + strB(bSaveToTempDatabase) + ") for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
          loadSlicePeakAndMinArraysFromSamplesArray(*rMG, nFileDataPtr, -1, nEditAudPtr, bSaveToTempDatabase)
        EndIf
      EndIf
    EndIf
    debugMsg(sProcName, "calling drawWholeGraphArea()")
    drawWholeGraphArea()
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setGraphColors(*rMG.tyMG)
  PROCNAMEC()
  Protected fCorrectionFactor.f
  
  With *rMG
    ; set graph colors
    \nINFGColorL = grColorScheme\rColorAudioGraph\nLeftColor
    \nINFGColorR = grColorScheme\rColorAudioGraph\nRightColor
    \nINFGColorLPlay = grColorScheme\rColorAudioGraph\nLeftColorPlay
    \nINFGColorRPlay = grColorScheme\rColorAudioGraph\nRightColorPlay
    \nCursorColor = grColorScheme\rColorAudioGraph\nCursorColor
    If grColorScheme\rColorAudioGraph\bRightSameAsLeft
      \nINFGColorR = \nINFGColorL
      \nEXFGColorR = \nEXFGColorL
      \nINFGColorRPlay = \nINFGColorLPlay
    EndIf
    ; nb \nEXFGColorL and \nEXFGColorR only used in the editor - not in audio graph sliders as these only show 'included' slices
    fCorrectionFactor = grColorScheme\rColorAudioGraph\nDarkenFactor / 100
    \nEXFGColorL = changeColorBrightness(\nINFGColorL, fCorrectionFactor)
    \nEXFGColorR = changeColorBrightness(\nINFGColorR, fCorrectionFactor)
  EndWith
  
EndProcedure

Procedure graphInit(*rMG.tyMG)
  PROCNAMEC()
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START + ", *rMG\sMGNumber=" + *rMG\sMGNumber)
  
  If *rMG\nMGNumber = 2 Or *rMG\nMGNumber = 5
    ASSERT_THREAD(#SCS_THREAD_MAIN)
  EndIf
  
  With *rMG
    setGraphColors(*rMG)
    
    Select \nMGNumber
      Case 2, 5
        ; grMG2 is used by fmEditQF and associated routines
        ; grMG5 is used by fmEditQA and associated routines
        \nMaxInnerWidth = #SCS_GRAPH_MAX_INNER_WIDTH
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        \nMaxInnerWidth = 300  ; will be reset in loadSlicePeakAndMinArraysFromDatabase()
    EndSelect
    
    Select \nMGNumber
      Case 2
        ; grMG2 is used by fmEditQF and associated routines
        \nLoopBarHeight = 11  ; height of space for the loop start and end markers - downward pointing right-angled triangles displayed in light blue
        \nSEBarHeight = 11    ; height of space for the playback start and end markers - upward pointing right-angled triangles displayed in light blue
        \nGraphHeight = 107   ; height of graph display area between the loop bar and the start/end (SE) bar - see also code below to make this 'odd'
        \nCanvasGadget = WQF\cvsGraph
        \nSideLabelsGadget = WQF\cvsSideLabels
        \nTimeBarHeight = 19
        \nVisibleWidth = GadgetWidth(WQF\cntGraph)
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        \nLoopBarHeight = 0
        \nSEBarHeight = 0
        \nGraphHeight = 16    ; taken from createCuePanelGadgets() - see also code below to make this 'odd'
        \nTimeBarHeight = 0
        \nVisibleWidth = 271  ; taken from createCuePanelGadgets()
      Case 5
        ; grMG5 is used by fmEditQA and associated routines
        \nLoopBarHeight = 0
        \nSEBarHeight = 11
        \nCanvasGadget = WQA\cvsGraphQA
        \nSideLabelsGadget = WQA\cvsSideLabelsQA
        \nGraphHeight = GadgetHeight(\nCanvasGadget) - \nSEBarHeight ; see also code below to make this 'odd'
        ; debugMsg0(sProcName, "GadgetHeight(\nCanvasGadget)=" + GadgetHeight(\nCanvasGadget) + ", \nGraphHeight=" + \nGraphHeight)
        \nTimeBarHeight = 0
        \nVisibleWidth = GadgetWidth(WQA\cntGraphQA)
    EndSelect
    
    ; ensure \nGraphHeight is odd to allow for centre line
    \nGraphHeight >> 1
    \nGraphHeight << 1
    \nGraphHeight - 1
    ; debugMsg0(sProcName, "\nGraphHeight=" + \nGraphHeight)
    \nGraphHalfHeight = \nGraphHeight >> 1
    \nLoopBarTop = 0
    \nGraphTop = \nLoopBarTop + \nLoopBarHeight
    \nSEBarTop = \nGraphTop + \nGraphHeight
    \nTimeBarTop = \nSEBarTop + \nSEBarHeight
    ; debugMsg(sProcName, \sMGNumber + "\nTimeBarTop=" + \nTimeBarTop)
    \nGraphYMidPoint = \nGraphTop + ((\nGraphHeight - 1) >> 1) ; -1 because \nGraphHeight is odd - see comment above regarding \nGraphHeight
    
    \nGraphLeft = 0   ; warning: if \nGraphLeft is not zero then it will be necessary to change code like LineXY(nThisSlice,...) to be LineXY(nThisSlice+\nGraphLeft,...)
    \nGraphWidth = \nVisibleWidth
    ; debugMsg(sProcName, "" +\sMGNumber + "\nVisibleWidth=" + \nVisibleWidth + ", \nGraphWidth=" + \nGraphWidth)
    \nLoopBarLeft = \nGraphLeft
    \nLoopBarWidth = \nGraphWidth
    \nSEBarLeft = \nGraphLeft
    \nSEBarWidth = \nGraphWidth
    \nTimeBarLeft = \nGraphLeft
    \nTimeBarWidth = \nGraphWidth
    
    \nLoopBarBottom = \nLoopBarTop + \nLoopBarHeight - 1
    \nSEBarBottom = \nSEBarTop + \nSEBarHeight - 1
    \nTimeBarBottom = \nTimeBarTop + \nTimeBarHeight - 1
    \nGraphBottom = \nGraphTop + \nGraphHeight - 1
    \nGraphRight = \nGraphLeft + \nGraphWidth - 1
    
    \nFadeMarkerTop = \nGraphTop - #SCS_FADE_GRAPH_MARKER_RADIUS - 1
    \nFadeMarkerBottom = \nFadeMarkerTop + #SCS_FADE_GRAPH_MARKER_DIAMETER
    
    \nCanvasWidth = \nGraphLeft + \nGraphWidth
    \nCanvasHeight = \nTimeBarTop + \nTimeBarHeight
    
    Select \nMGNumber
      Case 2
        ; grMG2 is used by fmEditQF and associated routines
        ResizeGadget(WQF\cvsGraph, #PB_Ignore, #PB_Ignore, \nCanvasWidth, \nCanvasHeight)
        ResizeGadget(WQF\cvsSideLabels, #PB_Ignore, #PB_Ignore, #PB_Ignore, \nCanvasHeight)
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        ; no action here
      Case 5
        ; grMG5 is used by fmEditQA and associated routines
        ResizeGadget(WQA\cvsGraphQA, #PB_Ignore, #PB_Ignore, \nCanvasWidth, \nCanvasHeight)
        ResizeGadget(WQA\cvsSideLabelsQA, #PB_Ignore, #PB_Ignore, #PB_Ignore, \nCanvasHeight)
    EndSelect
    createGraphImageIfReqd(*rMG)
    
    \nInnerWidth = \nGraphWidth
    \nGraphMaxX = \nGraphWidth - 1
    ; debugMsg(sProcName, "\nGraphWidth=" + \nGraphWidth + ", \nInnerWidth=" + \nInnerWidth + ", \nGraphMaxX=" + \nGraphMaxX)
    ; debugMsg(sProcName, "calling resizeInnerAreaOfGraph(*rMG)")
    resizeInnerAreaOfGraph(*rMG)
    ; debugMsg(sProcName, "\nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth)
    
    doReDim(\aSlicePeakL, \nGraphMaxX, \sMGNumber + "\aSlicePeakL()")
    doReDim(\aSlicePeakR, \nGraphMaxX, \sMGNumber + "\aSlicePeakR()")
    doReDim(\aSliceMinL, \nGraphMaxX, \sMGNumber + "\aSliceMinL()")
    doReDim(\aSliceMinR, \nGraphMaxX, \sMGNumber + "\aSliceMinR()")
    
    \nMouseDownSliceType = #SCS_SLICE_TYPE_NONE
    \bInitDataLoaded = #False
    \bInitGraphDrawn = #False
    \bInDrawGraph = #False
    \nFileDataPtrForGraph = -1
    \nFileDataPtrForSlicePeakAndMinArrays = -1
    ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
    \nFileDataPtrForSamplesArray = -1
    \nAudPtr = -1
    
;     debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays +
;                         ", \nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth +
;                         ", \nGraphTop=" + \nGraphTop + ", \nGraphTopL=" + \nGraphTopL + ", \nGraphTopR=" + \nGraphTopR +
;                         ", \nGraphBottom=" + \nGraphBottom + ", \nGraphBottomL=" + \nGraphBottomL + ", \nGraphBottomR=" + \nGraphBottomR)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure setGraphPoints(*rMG.tyMG)
  ; PROCNAMECA(nEditAudPtr)
  Protected nFirstDevChannel.l  ; long
  Protected nTmpPos, l2
  
  ; debugMsg(sProcName, #SCS_START)
  
  grGraph2\nSlicePos = #SCS_NO_SLICE
  grGraph2\nSliceST = #SCS_NO_SLICE
  grGraph2\nSliceEN = #SCS_NO_SLICE
  grGraph2\nSliceMaxLoop = -1
  grGraph2\nSliceFI = #SCS_NO_SLICE
  grGraph2\nSliceFO = #SCS_NO_SLICE
  
  With *rMG
    
    If nEditAudPtr < 0
      \nFileDuration = grAudDef\nFileDuration
      \nMGMaxLoop = grAudDef\nMaxLoopInfo
      ProcedureReturn
    EndIf
    
    ; debugMsg(sProcName, "calling resizeInnerAreaOfGraph(*rMG)")
    resizeInnerAreaOfGraph(*rMG)
    
    \nFileDuration = aAud(nEditAudPtr)\nFileDuration
    \nMGMaxLoop = aAud(nEditAudPtr)\nMaxLoopInfo
    
    Select \nGraphChannels
      Case 1
        \nGraphTopL = \nGraphTop
        \nGraphBottomL = \nGraphBottom
        ; 'Right' settings should not actually be used when there is only one graph channel
        \nGraphTopR = \nGraphTopL
        \nGraphBottomR = \nGraphBottomL
      Case 2
        \nGraphTopL = \nGraphTop
        \nGraphBottomL = \nGraphYMidPoint - 1
        \nGraphTopR = \nGraphYMidPoint + 1
        \nGraphBottomR = \nGraphBottom
    EndSelect
    \nGraphHeightL = \nGraphBottomL - \nGraphTopL + 1
    \nGraphHalfHeightL = \nGraphHeightL >> 1
    \nGraphYMidPointL = \nGraphTopL + \nGraphHalfHeightL
    \nGraphHeightR = \nGraphBottomR - \nGraphTopR + 1
    \nGraphHalfHeightR = \nGraphHeightR >> 1
    \nGraphYMidPointR = \nGraphTopR + \nGraphHalfHeightR
    
    \fMillisecondsPerPixel = \nFileDuration / \nInnerWidth
    
    If (\nFileDuration <= 0) Or (\fMillisecondsPerPixel <= 0)
      \nPos = 0
      \nST = 0
      \nMGMaxLoop = -1
      \nEN = 0
      \nFI = 0
      \nFO = 0
      grGraph2\nSlicePos = 0
      grGraph2\nSliceST = 0
      grGraph2\nSliceMaxLoop = -1
      grGraph2\nSliceEN = 0
      grGraph2\nSliceFI = 0
      grGraph2\nSliceFO = 0
      ProcedureReturn
    EndIf
    
    If aAud(nEditAudPtr)\nFirstDev < 0
      ProcedureReturn
    EndIf
    
    nFirstDevChannel = aAud(nEditAudPtr)\nBassChannel[aAud(nEditAudPtr)\nFirstDev]
    If nFirstDevChannel = 0
      nFirstDevChannel = aAud(nEditAudPtr)\nGraphChan
    EndIf
    
    If \nMouseDownSliceType = #SCS_SLICE_TYPE_NORMAL
      grGraph2\nSlicePos = \nReposMouseTime / \fMillisecondsPerPixel
      ; debugMsg(sProcName, "\nMouseDownSliceType=" + Str(\nMouseDownSliceType) + ", grGraph2\nSlicePos=" + Str(grGraph2\nSlicePos))
    Else
      If nFirstDevChannel <> 0
        \nPos = Int(BASS_ChannelBytes2Seconds(nFirstDevChannel, aAud(nEditAudPtr)\qChannelBytePosition) * 1000)
      Else
        \nPos = aAud(nEditAudPtr)\nAbsStartAt
      EndIf
      grGraph2\nSlicePos = \nPos / \fMillisecondsPerPixel
      ; debugMsg(sProcName, "grGraph2\nSlicePos=" + Str(grGraph2\nSlicePos) + ", aAud(" + getAudLabel(nEditAudPtr) + ")\qChannelBytePosition=" + Str(aAud(nEditAudPtr)\qChannelBytePosition))
    EndIf
    
    \nST = aAud(nEditAudPtr)\nStartAt
    If \nST > 0
      grGraph2\nSliceST = \nST / \fMillisecondsPerPixel
    ElseIf \nST <= 0
      grGraph2\nSliceST = 0
    EndIf
    ; debugMsg(sProcName, "grGraph2\nSliceST=" + grGraph2\nSliceST + ", \nST=" + \nST)
    
    \nMGMaxLoop = aAud(nEditAudPtr)\nMaxLoopInfo
    If ArraySize(\nLS()) < \nMGMaxLoop
      ReDim \nLS(\nMGMaxLoop)
      ReDim \nLE(\nMGMaxLoop)
    EndIf
    For l2 = 0 To \nMGMaxLoop
      If (aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart = -2) And (aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd <> -2)
        \nLS(l2) = aAud(nEditAudPtr)\nStartAt
      Else
        \nLS(l2) = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart
      EndIf
      
      If (aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd = -2) And (aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopStart <> -2)
        If aAud(nEditAudPtr)\nEndAt > 0
          aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd = aAud(nEditAudPtr)\nEndAt
        Else
          aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd = (aAud(nEditAudPtr)\nFileDuration - 1) ; 16Nov2015 11.4.1.2k: added "- 1"
        EndIf
      ElseIf aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd = -1
        \nLE(l2) = (aAud(nEditAudPtr)\nFileDuration - 1)  ; 16Nov2015 11.4.1.2k: added "- 1"
      Else
        \nLE(l2) = aAud(nEditAudPtr)\aLoopInfo(l2)\nAbsLoopEnd
      EndIf
      
      If \nLS(l2) > 0
        grGraph2\nSliceLS(l2) = \nLS(l2) / \fMillisecondsPerPixel
      ElseIf \nLS(l2) <= 0
        grGraph2\nSliceLS(l2) = 0
      EndIf
      grGraph2\nSliceLE(l2) = \nLE(l2) / \fMillisecondsPerPixel
      If grGraph2\nSliceLE(l2) >= \nInnerWidth
        grGraph2\nSliceLE(l2) = \nInnerWidth - 1
      EndIf
    Next l2
    grGraph2\nSliceMaxLoop = \nMGMaxLoop
    
    If aAud(nEditAudPtr)\nEndAt = -2
      \nEN = (aAud(nEditAudPtr)\nFileDuration - 1)
    Else
      \nEN = aAud(nEditAudPtr)\nEndAt
    EndIf
    If \nEN >= 0
      grGraph2\nSliceEN = \nEN / \fMillisecondsPerPixel
    EndIf
    If grGraph2\nSliceEN >= \nInnerWidth
      grGraph2\nSliceEN = \nInnerWidth - 1
    EndIf
    
    If aAud(nEditAudPtr)\nFadeInTime > 0
      nTmpPos = aAud(nEditAudPtr)\nAbsStartAt + aAud(nEditAudPtr)\nFadeInTime
      If nTmpPos <= aAud(nEditAudPtr)\nAbsEndAt
        \nFI = nTmpPos
        If \nFI >= 0
          grGraph2\nSliceFI = \nFI / \fMillisecondsPerPixel
        EndIf
      EndIf
    Else
      \nFI = \nST
      grGraph2\nSliceFI = grGraph2\nSliceST
    EndIf
    
    If aAud(nEditAudPtr)\nFadeOutTime > 0
      nTmpPos = aAud(nEditAudPtr)\nAbsEndAt - aAud(nEditAudPtr)\nFadeOutTime
      If nTmpPos >= aAud(nEditAudPtr)\nAbsStartAt
        \nFO = nTmpPos
        If \nFO >= 0
          grGraph2\nSliceFO = \nFO / \fMillisecondsPerPixel
        EndIf
      EndIf
    Else
      \nFO = \nEN
      grGraph2\nSliceFO = grGraph2\nSliceEN
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure graphNodeChange(pAudPtr, nDecoder.l)
  PROCNAMEC()
  Protected lBassResult.l
  
  If (gbKillNodeClick) Or (pAudPtr <> nEditAudPtr)
    ; node changed
    debugMsg(sProcName, "quitting because user probably clicked another node. pAudPtr=" + pAudPtr + ", nEditAudPtr=" + nEditAudPtr)
    If nDecoder <> 0
      lBassResult = BASS_StreamFree(nDecoder) ; free the decoder
      debugMsg2(sProcName, "BASS_StreamFree(" + Str(nDecoder) + ")", lBassResult)
      freeHandle(nDecoder)
    EndIf
    grGraph2\bInGraphScanFile = #False
    ProcedureReturn #True   ; indicate node changed
    
  Else
    ProcedureReturn #False  ; indicate node hasn't changed
  EndIf
  
EndProcedure

Procedure getRepeatCount()
  Protected sChar.s, nRepeatCount
  
  With grMG2
    nRepeatCount = 1
    sChar = Mid(\sBuff, \nBuffPtr, 1)
    Select sChar
      Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
        nRepeatCount = 0
        While (\nBuffPtr <= Len(\sBuff)) And (Mid(\sBuff, \nBuffPtr, 1) >= "0") And (Mid(\sBuff, \nBuffPtr, 1) <= "9")
          nRepeatCount = (nRepeatCount * 10) + Val(Mid(\sBuff, \nBuffPtr, 1))
          \nBuffPtr + 1
        Wend
    EndSelect
  EndWith
  
  ProcedureReturn nRepeatCount
EndProcedure

Procedure decodeGraphVal()
  PROCNAMEC()
  Protected sEncoded.s, nValue
  Protected nEncoded
  
  With grMG2
    sEncoded = Mid(\sBuff, \nBuffPtr, 1)
    nEncoded = Asc(sEncoded)
    Select sEncoded
      Case "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
        nValue = nEncoded - Asc("A")
        \nBuffPtr + 1
      Case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
        nValue = nEncoded - Asc("a") + 26
        \nBuffPtr + 1
      Case "("
        \nBuffPtr + 1
        nValue = 0
        While \nBuffPtr <= Len(\sBuff) And Mid(\sBuff, \nBuffPtr, 1) <> ")"
          nValue = (nValue * 10) + Val(Mid(\sBuff, \nBuffPtr, 1))
          \nBuffPtr + 1
        Wend
        \nBuffPtr + 1
      Default
        Select nEncoded
          Case 176 To 255
            nValue = nEncoded - 176 + 52
            \nBuffPtr + 1
          Default
            \nBuffPtr + 1
        EndSelect
    EndSelect
  EndWith
  
  ProcedureReturn nValue
EndProcedure

Procedure.s encodeGraphVal(nValue)
  PROCNAMEC()
  Protected sEncoded.s
  
  Select nValue
    Case 0 To 25
      sEncoded = Chr(Asc("A") + nValue)
    Case 26 To 51
      sEncoded = Chr(Asc("a") + nValue - 26)
    Case 52 To 131
      sEncoded = Chr(176 + nValue - 52)     ; Chr(176) = °, and 176 = Hex(B0)
    Default
      sEncoded = "(" + nValue + ")"
  EndSelect
  ProcedureReturn sEncoded
EndProcedure

Procedure drawScale(*rMG.tyMG)
  PROCNAMECA(nEditAudPtr)
  Protected n
  Protected fGap.f
  Protected fCounter.f
  Protected nTime
  Protected nSmallInterval, nLargeInterval, nTextInterval
  Protected X1, X2, Y1, Y2
  Protected nInitialGap, nForLoopStart
  Protected bDrawingStartedByMe
  Protected nTimeMultiplier
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rMG
    bDrawingStartedByMe = condStartGraphDrawing(*rMG)
    ; clear scale
    Box(0, \nTimeBarTop, \nVisibleWidth, \nTimeBarHeight, $C0C0C0)
    condStopGraphDrawing(*rMG, bDrawingStartedByMe) ; need to StopDrawing because we may issue a ProcedureReturn before the next set of drawing commands
    
    If (nEditAudPtr < 0) Or (\fMillisecondsPerPixel = 0)
      ProcedureReturn
    EndIf
    
    If \bAudPlaceHolder
      ProcedureReturn
    EndIf
    
    If (aAud(nEditAudPtr)\nFileFormat <> #SCS_FILEFORMAT_AUDIO And aAud(nEditAudPtr)\nFileFormat <> #SCS_FILEFORMAT_VIDEO) Or (aAud(nEditAudPtr)\nFileDuration <= 0) Or (aAud(nEditAudPtr)\nFileState <> #SCS_FILESTATE_OPEN)
      ProcedureReturn
    EndIf
    
    nTime = \fMillisecondsPerPixel * \nVisibleWidth   ; nTime = milliseconds in visible area of graph
    If nTime <= 5000                                  ; <= 5 seconds
      nSmallInterval = 100
      nLargeInterval = 500
      nTextInterval  = 500
    ElseIf nTime <= 10000  ; <= 10 seconds
      nSmallInterval = 250
      nLargeInterval = 1000
      nTextInterval  = 1000
    ElseIf nTime <= 30000  ; <= 30 seconds
      nSmallInterval = 1000
      nLargeInterval = 5000
      nTextInterval  = 5000
    ElseIf nTime <= 90000   ; <= 1.5 minutes
      nSmallInterval = 1000
      nLargeInterval = 5000
      nTextInterval  = 10000
    ElseIf nTime <= 180000   ; <= 3 minutes
      nSmallInterval = 1000
      nLargeInterval = 5000
      nTextInterval  = 20000
    ElseIf nTime <= 600000  ; <= 10 minutes
      nSmallInterval = 2000
      nLargeInterval = 10000
      nTextInterval  = 30000
    Else    ; > 10 minutes
      nTimeMultiplier = Round(nTime / 600000, #PB_Round_Nearest)
      If nTimeMultiplier = 0
        nTimeMultiplier = 1
      EndIf
      nSmallInterval = 10000 * nTimeMultiplier
      nLargeInterval = 20000 * nTimeMultiplier
      nTextInterval  = 60000 * nTimeMultiplier
    EndIf
    
    ; debugMsg(sProcName, "nTime=" + Str(nTime) + ", nSmallInterval=" + Str(nSmallInterval) + ", nLargeInterval=" + Str(nLargeInterval) + ", nTextInterval=" + Str(nTextInterval))
    fGap = nSmallInterval / \fMillisecondsPerPixel
    ;     debugMsg(sProcName, "\nVisibleWidth=" + \nVisibleWidth + ", \nTimeBarWidth=" + \nTimeBarWidth + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2) + ", fGap=" + StrF(fGap,2))
    
    nInitialGap = 0
    nForLoopStart = 0
    
    bDrawingStartedByMe = condStartGraphDrawing(*rMG)
    
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawingFont(FontID(#SCS_FONT_GEN_NORMAL))
    
    X1 = nInitialGap + \nTimeBarLeft + \nGraphLeft
    ;     debugMsg(sProcName, "nInitialGap=" + Str(nInitialGap) + ", \nTimeBarLeft=" + Str(\nTimeBarLeft) + ", \nGraphLeft=" + Str(\nGraphLeft) + ", X1=" + Str(X1))
    Y1 = \nTimeBarTop
    fCounter = 0
    n = nForLoopStart
    While n <= \nFileDuration
      X2 = X1
      If n % nTextInterval = 0
        Y2 = 7
      ElseIf n % nLargeInterval = 0
        Y2 = 5
      Else
        Y2 = 3
      EndIf
      Y2 + \nTimeBarTop
      If (X1 > -100) And (X1 < (\nVisibleWidth + 100))
        LineXY(X1, Y1, X2, Y2, #SCS_Black)
        ; debugMsg(sProcName, "LineXY(" + X1 + ", " + Y1 + ", " + X2 + ", " + Y2 + ", #SCS_Black)")
        If n % nTextInterval = 0
          DrawText(X1, \nTimeBarTop+6, timeToString(n), #SCS_Black)
          ; debugMsg(sProcName, "DrawText(" + Str(X1) + ", 6, " + timeToString(n) + ", #SCS_Black)")
        EndIf
      EndIf
      fCounter + 1
      X1 = (fGap * fCounter) + nInitialGap + \nGraphLeft
      n + nSmallInterval
    Wend
    
    condStopGraphDrawing(*rMG, bDrawingStartedByMe)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure drawSideLabels()
  ; See also drawSideLabelsQA() for AudTypeA
  PROCNAMEC()
  Protected nLeft, nTop, nRadius, nTextLeft, nTextTop
  Static sLoop.s, sLeft.s, sRight.s, sStart.s, sEnd.s, sHelp.s
  Static nSideWidth, nLoopX, nLeftX, nRightX, nStartX, nEndX
  Static nTextHeight, nHelpWidth, nHelpHeight
  Static bStaticLoaded
  Protected nFileChannels, sLeftMulti.s, sRightMulti.s, nLeftMultiX, nRightMultiX
  
  With grMG2
    If StartDrawing(CanvasOutput(\nSideLabelsGadget))
      
      If bStaticLoaded = #False
        scsDrawingFont(#SCS_FONT_GEN_NORMAL7)
        nTextHeight = TextHeight("S")
        sLoop  = Lang("WQF", "Loop")
        sLeft  = Lang("WQF", "Left")
        sRight = Lang("WQF", "Right")
        sStart = Lang("WQF", "Start") + "/"
        sEnd   = Lang("WQF", "End")
        nSideWidth = GadgetWidth(WQF\cvsSideLabels)
        nLoopX = (nSideWidth - 1 - TextWidth(sLoop)) / 2
        nLeftX = (nSideWidth - 1 - TextWidth(sLeft)) / 2
        nRightX = (nSideWidth - 1 - TextWidth(sRight)) / 2
        nStartX = (nSideWidth - 1 - TextWidth(sStart)) / 2
        nEndX = (nSideWidth - 1 - TextWidth(sEnd)) / 2
        scsDrawingFont(#SCS_FONT_GEN_BOLD9)
        sHelp = "?"
        nHelpWidth = TextWidth(sHelp)
        nHelpHeight = TextHeight(sHelp)
        bStaticLoaded = #True
      EndIf
      
      scsDrawingFont(#SCS_FONT_GEN_NORMAL7)
      
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
      nLeft = nSideWidth - 1
      LineXY(nLeft, 0, nLeft, \nCanvasHeight, $C0C0C0)
      
      If \bContainsLoop
        nTop = \nLoopBarTop
        DrawText(nLoopX, nTop, sLoop, \nLSColorD, #SCS_Black)
      EndIf
      
      If \nGraphChannels = 2
        nTop = \nGraphTop + (\nGraphHeight >> 2) - (nTextHeight >> 1)
        If \nFileDataPtrForGraph >= 0
          nFileChannels = gaFileData(\nFileDataPtrForGraph)\nxFileChannels
          If nFileChannels > 2
            If nFileChannels = 4
              sLeftMulti = "1+3"
              sRightMulti = "2+4"
            ElseIf nFileChannels = 6
              sLeftMulti = "1+3+5"
              sRightMulti = "2+4+6"
            EndIf
          EndIf
        EndIf
        If sLeftMulti
          nLeftMultiX = (nSideWidth - 1 - TextWidth(sLeftMulti)) / 2
          nRightMultiX = (nSideWidth - 1 - TextWidth(sRightMulti)) / 2
          DrawText(nLeftMultiX, nTop, sLeftMulti, \nINFGColorL, #SCS_Black)
          nTop + (\nGraphHeight >> 1)
          DrawText(nRightMultiX, nTop, sRightMulti, \nINFGColorR, #SCS_Black)
        Else
          DrawText(nLeftX, nTop, sLeft, \nINFGColorL, #SCS_Black)
          nTop + (\nGraphHeight >> 1)
          DrawText(nRightX, nTop, sRight, \nINFGColorR, #SCS_Black)
        EndIf
      EndIf
      
      nTop = \nSEBarTop - (nTextHeight >> 1)
      DrawText(nStartX, nTop, sStart, \nSTColor, #SCS_Black)
      nTop + nTextHeight
      DrawText(nEndX, nTop, sEnd, \nENColor, #SCS_Black)
      
      ; draw graph help question mark in circle
      scsDrawingFont(#SCS_FONT_GEN_BOLD9)
      DrawingMode(#PB_2DDrawing_Outlined)
      nLeft = (nSideWidth >> 1) - 1
      nTop = \nGraphTop + (\nGraphHeight >> 1) - 1
      If nHelpHeight > nHelpWidth
        nRadius = (nHelpHeight >> 1) + 2
      Else
        nRadius = (nHelpWidth >> 1) + 2
      EndIf
      Circle(nLeft, nTop, nRadius, \nLPColor)
      ; Debug "Circle(" + nLeft + ", " + nTop + ", " + nRadius + ", \nLPColor)"
      If \nGraphLeft = 0
        \nGraphHelpLeft = nLeft - nRadius
        \nGraphHelpRight = nLeft + nRadius
        \nGraphHelpTop = nTop - nRadius
        \nGraphHelpBottom = nTop + nRadius
        ; Debug "nRadius=" + nRadius + ", \nGraphHelpLeft=" + \nGraphHelpLeft + ", \nGraphHelpRight=" + \nGraphHelpRight + ", \nGraphHelpTop=" + \nGraphHelpTop + ", \nGraphHelpBottom=" + \nGraphHelpBottom
      EndIf
      nTextLeft = nLeft - (nHelpWidth >> 1)
      nTextTop = nTop - (nHelpHeight >> 1)
      DrawText(nTextLeft, nTextTop, sHelp, \nLPColor, #SCS_Black)
      
      StopDrawing()
    EndIf
  EndWith
  
EndProcedure

Procedure drawSideLabelsQA()
  PROCNAMECA(nEditAudPtr)
  Protected nLeft, nTop, nRadius, nTextLeft, nTextTop
  Static nSideWidth, sHelp.s, nHelpWidth, nHelpHeight
  Static bStaticLoaded
  
  With grMG5
    If StartDrawing(CanvasOutput(WQA\cvsSideLabelsQA))
      If bStaticLoaded = #False
        nSideWidth = GadgetWidth(WQA\cvsSideLabelsQA)
        scsDrawingFont(#SCS_FONT_GEN_BOLD9)
        sHelp = "?"
        nHelpWidth = TextWidth(sHelp)
        nHelpHeight = TextHeight(sHelp)
        bStaticLoaded = #True
      EndIf
      
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
      nLeft = nSideWidth - 1
      LineXY(nLeft, 0, nLeft, \nCanvasHeight, $C0C0C0)
      
      ; draw graph help question mark in circle
      scsDrawingFont(#SCS_FONT_GEN_BOLD9)
      DrawingMode(#PB_2DDrawing_Outlined)
      nLeft = (nSideWidth >> 1) - 1
      nTop = \nGraphTop + (\nGraphHeight >> 1) - 1
      If nHelpHeight > nHelpWidth
        nRadius = (nHelpHeight >> 1) + 2
      Else
        nRadius = (nHelpWidth >> 1) + 2
      EndIf
      Circle(nLeft, nTop, nRadius, \nLPColor)
      ; debugMsg0(sProcName, "Circle(" + nLeft + ", " + nTop + ", " + nRadius + ", \nLPColor)")
      If \nGraphLeft = 0
        \nGraphHelpLeft = nLeft - nRadius
        \nGraphHelpRight = nLeft + nRadius
        \nGraphHelpTop = nTop - nRadius
        \nGraphHelpBottom = nTop + nRadius
        ; debugMsg0(sProcName, "nRadius=" + nRadius + ", \nGraphHelpLeft=" + \nGraphHelpLeft + ", \nGraphHelpRight=" + \nGraphHelpRight + ", \nGraphHelpTop=" + \nGraphHelpTop + ", \nGraphHelpBottom=" + \nGraphHelpBottom)
      EndIf
      nTextLeft = nLeft - (nHelpWidth >> 1)
      nTextTop = nTop - (nHelpHeight >> 1)
      DrawText(nTextLeft, nTextTop, sHelp, \nLPColor, #SCS_Black)
      
      StopDrawing()
      ; debugMsg0(sProcName, "GadgetY(WQA\cntGraphDisplayQA)=" + GadgetY(WQA\cntGraphDisplayQA) + ", GadgetHeight(WQA\cntGraphDisplayQA)=" + GadgetHeight(WQA\cntGraphDisplayQA) +
      ;                      ", GadgetY(WQA\cvsSideLabelsQA)=" + GadgetHeight(WQA\cvsSideLabelsQA))
    EndIf
  EndWith
  
EndProcedure

Procedure setFileInfoForGraph(*rMG.tyMG, pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nFileDataPtr
  Protected bFileChanged
  
  debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber)
  
  nFileDataPtr = -1
  If pAudPtr >= 0
    With aAud(pAudPtr)
      If (\nFileFormat = #SCS_FILEFORMAT_AUDIO Or \nFileFormat = #SCS_FILEFORMAT_VIDEO) And (\nAudState <> #SCS_CUE_ERROR)
        If \bAudPlaceHolder = #False
          nFileDataPtr = \nFileDataPtr
          If nFileDataPtr >= 0
            debugMsg(sProcName, "nFileDataPtr=" + nFileDataPtr + ", gaFileData(" + nFileDataPtr + ")\sStoredFileName=" + gaFileData(nFileDataPtr)\sStoredFileName)
          Else
            debugMsg(sProcName, "nFileDataPtr=" + nFileDataPtr)
          EndIf
        EndIf
      EndIf
    EndWith
  EndIf
  
  If nFileDataPtr >= 0
    bFileChanged = checkFileChanged(pAudPtr)
    If bFileChanged
      debugMsg(sProcName, "checkFileChanged(" + getAudLabel(pAudPtr) + ") returned " + strB(bFileChanged))
      gaFileData(nFileDataPtr)\nSamplesArrayStatus = #SCS_SAP_NONE
      gaFileData(nFileDataPtr)\bForceReadFileBlob = #True
      debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nSamplesArrayStatus=#SCS_SAP_NONE")
    EndIf
  EndIf
  
  With *rMG
    \nFileDataPtrForGraph = nFileDataPtr
    If nFileDataPtr >= 0
      \nFileDuration = gaFileData(nFileDataPtr)\nFileDuration
      \nMGFileChannels = gaFileData(nFileDataPtr)\nxFileChannels
    Else
      \nFileDuration = 0
      \nMGFileChannels = 0
    EndIf
debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", \nFileDataPtrForGraph=" + \nFileDataPtrForGraph + ", \nFileDuration=" + \nFileDuration + ", \nMGFileChannels=" + \nMGFileChannels)
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning " + nFileDataPtr)
  ProcedureReturn nFileDataPtr
  
EndProcedure

Procedure loadSlicePeakAndMinArraysFromDatabase(*rMG.tyMG, nFileDataPtr, pReqdInnerWidth=-1, pAudPtr=-1)
  PROCNAMEC()
  ; *rMG = MG2 for fmEditQF or associated module (nMGNumber will be 2); *rMG = MG3 for 'audio graph' progress slider (nMGNumber will be 3).
  ; grMG2\nGraphChannels (or grMG3\nGraphChannels) must be set for the selected device
  ; pReqdInnerWidth MUST be set for 'audio graph' progress sliders, and is the required display width of the graph.
  ; pAudPtr only required for 'audio graph' progress slider as the progress slider is to show only the playable part of the file.
  Protected nMGNumber
  Protected byPeakL.b, byPeakR.b
  Protected byMinL.b, byMinR.b
  Protected n, m
  Protected nReqdInnerWidth, nReqdArraySize
  Protected nSlicePeakAndMinDataPtr
  Protected *mBlob, nBlobSize
  
  ; debugMsg0(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber + ", *rMG\nMGFileChannels=" + *rMG\nMGFileChannels + ", nFileDataPtr=" + nFileDataPtr + ", pReqdInnerWidth=" + pReqdInnerWidth + ", pAudPtr=" + getAudLabel(pAudPtr))
  
  nMGNumber = *rMG\nMGNumber
  
  If nFileDataPtr < 0
    debugMsg(sProcName, "exiting because nFileDataPtr=" + nFileDataPtr)
    ProcedureReturn #False
  EndIf
  
  With *rMG
    nReqdInnerWidth = pReqdInnerWidth
    If nReqdInnerWidth = -1
      If nMGNumber = 2 Or nMGNumber = 5
        nReqdInnerWidth = \nInnerWidth
      Else ; nMGNumber = 3 or 4
        debugMsg(sProcName, "exiting because pReqdInnerWidth has not been set for an 'audio graph' progress slider")
        ProcedureReturn #False
      EndIf
    EndIf
    ; debugMsg(sProcName, "nReqdInnerWidth=" + nReqdInnerWidth)
    
    \nFileDataPtrForSlicePeakAndMinArrays = -1
    ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
    
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\sFileName=" + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
    If FileExists(gaFileData(nFileDataPtr)\sFileName, #False) = #False
      debugMsg(sProcName, "exiting because file not found: " + gaFileData(nFileDataPtr)\sFileName)
      ProcedureReturn #False
    EndIf
    
    ; Added 10Jan2024 11.10.0
    If pAudPtr >= 0
      If aAud(pAudPtr)\bAudTypeA
        If grEditingOptions\nFileScanMaxLengthVideo = 0
          ProcedureReturn #False
        EndIf
      ElseIf aAud(pAudPtr)\bAudTypeF
        If grEditingOptions\nFileScanMaxLengthAudio = 0
          ProcedureReturn #False
        EndIf
      EndIf
    EndIf
    ; End added 10Jan2024 11.10.0
    
    Select nMGNumber
      Case 2, 5
        ; grMG2 is used by fmEditQF and associated routines
        ; grMG5 is used by fmEditQA and associated routines
        If nFileDataPtr >= 0
          gaFileData(nFileDataPtr)\bForceReadFileBlob = #True
        EndIf
        If readFileBlob(*rMG, nFileDataPtr)
          *mBlob = *gmFileBlob
        Else
          debugMsg(sProcName, "readFileBlob(*rMG, " + nFileDataPtr + ") returned #False")
          ProcedureReturn #False
        EndIf
        
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        If readProgSldrGraphFromTempDatabase(pAudPtr)
          *mBlob = *gmSldrBlob
        Else
          debugMsg(sProcName, "readProgSldrGraphFromTempDatabase(" + getAudLabel(pAudPtr) + ") returned #False")
          ProcedureReturn #False
        EndIf
        
    EndSelect
    
    nBlobSize = MemorySize(*mBlob)
    ; debugMsg(sProcName, "nBlobSize=" + nBlobSize)
    \nMGFileChannels = gaFileData(nFileDataPtr)\nxFileChannels
    ; debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", *rMG\nMGFileChannels=" + *rMG\nMGFileChannels + ", nFileDataPtr=" + nFileDataPtr)
    \nMaxInnerWidth = gaFileData(nFileDataPtr)\nMaxInnerWidth
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nFileDuration=" + gaFileData(nFileDataPtr)\nFileDuration + ", nReqdInnerWidth=" + nReqdInnerWidth)
    \nFileDuration = gaFileData(nFileDataPtr)\nFileDuration
    If nMGNumber = 2 Or nMGNumber = 5
      \fNormalizeFactor = gaFileData(nFileDataPtr)\fNormalizeFactor
    Else
      \fNormalizeFactor = grSldrBlobInfo\fNormalizeFactor
    EndIf
    ; debugMsg(sProcName, \sMGNumber + "\fNormalizeFactor=" + StrF(\fNormalizeFactor, 4))
    
    nReqdArraySize = nReqdInnerWidth - 1
    doReDim(\aSlicePeakL, nReqdArraySize, \sMGNumber + "\aSlicePeakL()")
    doReDim(\aSlicePeakR, nReqdArraySize, \sMGNumber + "\aSlicePeakR()")
    doReDim(\aSliceMinL, nReqdArraySize, \sMGNumber + "\aSliceMinL()")
    doReDim(\aSliceMinR, nReqdArraySize, \sMGNumber + "\aSliceMinR()")
    
    For n = 0 To nReqdArraySize
      \aSlicePeakL(n) = 0
      \aSlicePeakR(n) = 0
      \aSliceMinL(n) = 0
      \aSliceMinR(n) = 0
    Next n
    
    \nGraphMaxX = nReqdInnerWidth - 1
    ; debugMsg(sProcName, \sMGNumber + "\nGraphMaxX=" + \nGraphMaxX)
;     If nBlobSize < (\nGraphMaxX * 4)
;       debugMsg(sProcName, "calling ReAllocateMemory(*mBlob, " + Str(\nGraphMaxX * 4) + ")")
;       *mBlob = ReAllocateMemory(*mBlob, (\nGraphMaxX * 4))
;       nBlobSize = MemorySize(*mBlob)
;     EndIf
    
    \fMillisecondsPerPixel = \nFileDuration / nReqdInnerWidth
    ; debugMsg(sProcName, \sMGNumber + "\nFileDuration=" + \nFileDuration + ", nReqdInnerWidth=" + nReqdInnerWidth + ", >>\fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,4))
    
    If \nGraphChannels = 1
      nSlicePeakAndMinDataPtr = 0
      For n = 0 To \nGraphMaxX
        If n <= (nBlobSize - 1)
          ; Peak L
          byPeakL = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
          ; Min L
          byMinL = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
        Else
          ; shouldn't get here
          byPeakL = 0
          byMinL = 0
        EndIf
        \aSlicePeakL(n) = byPeakL
        \aSliceMinL(n) = byMinL
        ; debugMsg(sProcName, "(1a) MG" + \nMGNumber + "\aSlicePeakL(" + n + ")=" + \aSlicePeakL(n))
      Next n
      
    Else
      nSlicePeakAndMinDataPtr = 0
      ; debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", \nGraphMaxX=" + \nGraphMaxX + ", nBlobSize=" + nBlobSize + ", *mBlob=" + *mBlob + ", MemorySize(*mBlob)=" + MemorySize(*mBlob))
      For n = 0 To \nGraphMaxX
        If n <= (nBlobSize - 3)
          ; debugMsg(sProcName, "n=" + n + ", nSlicePeakAndMinDataPtr=" + nSlicePeakAndMinDataPtr + ", nBlobSize=" + nBlobSize + ", MemorySize(*mBlob)=" + MemorySize(*mBlob))
          ; Peak L
          byPeakL = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
          ; Min L
          byMinL = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
          ; Peak R
          byPeakR = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
          ; Min R
          byMinR = PeekB(*mBlob + nSlicePeakAndMinDataPtr)
          nSlicePeakAndMinDataPtr + 1
        Else
          ; shouldn't get here
          byPeakL = 0
          byMinL = 0
          byPeakR - 0
          byMinR = 0
        EndIf
        \aSlicePeakL(n) = byPeakL
        \aSliceMinL(n) = byMinL
        \aSlicePeakR(n) = byPeakR
        \aSliceMinR(n) = byMinR
        CompilerIf 1=2
          ; KEEP THIS
          ; the following is used for creating Data statements for AG_SampleData: in fmAGColors.pbi
          If n < 360 ; width of WAC\cvsSample
            debugMsg(sProcName, "Data.b " + byPeakL + ", " + byMinL + ", " + byPeakR + ", " + byMinR + " ; " + n)
          EndIf
        CompilerEndIf
        CompilerIf 1=2
          If n < 360
            debugMsg(sProcName, "MG" + \nMGNumber + "\aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", \aSlicePeakR(" + n + ")=" + \aSlicePeakR(n) + ", byPeakL=" + byPeakL + ", byPeakR=" + byPeakR)
            ; debugMsg(sProcName, "\aSliceMinL(" + n + ")=" + \aSliceMinL(n) + ", \aSliceMinR(" + n + ")=" + \aSliceMinR(n) + ", byMinL=" + byMinL + ", byMinR=" + byMinR)
          EndIf
        CompilerEndIf
        ; debugMsg(sProcName, "MG" + \nMGNumber + "\aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", \aSlicePeakR(" + n + ")=" + \aSlicePeakR(n) + ", byPeakL=" + byPeakL + ", byPeakR=" + byPeakR)
      Next n
    EndIf
    
    \nFileDataPtrForSlicePeakAndMinArrays = nFileDataPtr
    ; Commented out the following line 2Dec2023 because this was preventing the zoom control from working in WQF, due to a test in loadSlicePeakAndMinArraysFromSamplesArray()
    ;   \nFileDataPtrForSamplesArray = nFileDataPtr ; Added 25Sep2023 11.10.0
    ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning #True")
  ProcedureReturn #True
  
EndProcedure

Procedure drawWholeGraphArea(bForceDrawing=#False)
  PROCNAMECA(nEditAudPtr)
  Protected bDrawingStartedByMe
  Protected sMsg.s, nLeft, nTop, nTextWidth, nTextHeight
  Protected *rMG.tyMG
  Protected sSubType.s
  
  ; EXPLANATION
  ; ===========
  ; drawWholeGraphArea()
  ;   setGraphPoints()
  ;     resizeInnerAreaOfGraph()
  ;     set graph points such as ST, LS, LE, EN, FI and FO
  ;   drawGraph()
  ;   drawScale()
  ;     draw timebar on cvsGraph at (0, \nTimeBarTop, \nVisibleWidth, \nTimeBarWidth, \nTimeBarHeight)
  ;   drawSideLabels()
  ;     draw labels on cvsSideLabels
  ;   WQF_setViewControls()
  
  ; debugMsg(sProcName, #SCS_START + ", bForceDrawing=" + strB(bForceDrawing) + ", gnDisplayedAudPtr=" + getAudLabel(gnDisplayedAudPtr))
  
  If (nEditAudPtr < 0) Or (nEditAudPtr <> gnDisplayedAudPtr And bForceDrawing = #False And gnDisplayedAudPtr >= 0) ; Added "And gnDisplayedAudPtr >= 0" 7Oct2023 11.10.0ch
    ; can occur if drawWholeGraphArea() is called via the file loader thread, if the user has subsequently moved to another node
    ProcedureReturn
  EndIf
  
  If aAud(nEditAudPtr)\bAudTypeF
    *rMG = @grMG2
  ElseIf aAud(nEditAudPtr)\bAudTypeA
    *rMG = @grMG5
  Else
    ProcedureReturn
  EndIf
  
  *rMG\bAudPlaceHolder = aAud(nEditAudPtr)\bAudPlaceHolder
  sSubType = aSub(nEditSubPtr)\sSubType
  
  setGraphPoints(*rMG)
  
;   debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber +
;                       ", \nFileDataPtrForSlicePeakAndMinArrays=" + *rMG\nFileDataPtrForSlicePeakAndMinArrays +
;                       ", \bInitDataLoaded=" + strB(*rMG\bInitDataLoaded) +
;                       ", \bAudPlaceHolder=" + strB(*rMG\bAudPlaceHolder) +
;                       ", \bDeviceAssigned=" + strB(*rMG\bDeviceAssigned))
  If (*rMG\bAudPlaceHolder) Or (*rMG\bDeviceAssigned = #False) Or (*rMG\nFileDataPtrForSlicePeakAndMinArrays = -1) Or (aAud(nEditAudPtr)\nFileDuration > getFileScanMaxLengthMS(sSubType) And getFileScanMaxLength(sSubType) > 0)
    grGraph2\bGraphVisible = #False
    ; debugMsg(sProcName, "clearing whole graph area")
    bDrawingStartedByMe = condStartGraphDrawing(*rMG)
    Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)
    ; Added 1Aug2023 11.10.0bt
    grGraph2\bGraphVisible = #True
    condStopGraphDrawing(*rMG, bDrawingStartedByMe)
    ; debugMsg(sProcName, "calling drawGraph(*rMG)")
    drawGraph(*rMG)
    bDrawingStartedByMe = condStartGraphDrawing(*rMG)
    ; End added 1Aug2023 11.10.0bt
    condStopGraphDrawing(*rMG, bDrawingStartedByMe)
  Else
    grGraph2\bGraphVisible = #True
    ; debugMsg(sProcName, "calling drawGraph(*rMG)")
    drawGraph(*rMG)
    ; debugMsg(sProcName, "*rMG\nFileDataPtrForSlicePeakAndMinArrays=" + *rMG\nFileDataPtrForSlicePeakAndMinArrays + ", aAud(" + getAudLabel(nEditAudPtr) + ")\nFileDataPtr=" + aAud(nEditAudPtr)\nFileDataPtr)
    If *rMG\nFileDataPtrForSlicePeakAndMinArrays <> aAud(nEditAudPtr)\nFileDataPtr
      If getFileScanMaxLength(sSubType) > 0
        sMsg = " " + LangPars("Graph", "NoGraph1", Str(getFileScanMaxLength(sSubType))) + " "
      Else
        sMsg = " " + Lang("Graph", "NoGraph2")
      EndIf
      debugMsg(sProcName, "sMsg=" + sMsg)
      bDrawingStartedByMe = condStartGraphDrawing(*rMG)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL9)
      nTextWidth = TextWidth(sMsg)
      nTextHeight = TextHeight(sMsg)
      If nTextWidth < OutputWidth()
        nLeft = (OutputWidth() - nTextWidth) >> 1
      Else
        nLeft = 0
      EndIf
      nTop = (OutputHeight() - nTextHeight) >> 1
      DrawingMode(#PB_2DDrawing_Transparent)
      DrawText(nLeft, nTop, sMsg, #SCS_Yellow)
      DrawingMode(#PB_2DDrawing_Default)
      condStopGraphDrawing(*rMG, bDrawingStartedByMe)
    EndIf
  EndIf
  
  drawScale(*rMg)
  
  If aAud(nEditAudPtr)\bAudTypeF
    drawSideLabels()
    ; debugMsg(sProcName, "calling WQF_setViewControls()")
    WQF_setViewControls()
  ElseIf aAud(nEditAudPtr)\bAudTypeA
    drawSideLabelsQA()
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure redrawGraphAfterMouseChange(*rMG.tyMG)
  setGraphPoints(*rMG)
  drawGraph(*rMG)
EndProcedure

Procedure newGraph(*rMG.tyMG, nAudPtr, nAudioGraphWidth=-1)
  PROCNAMECA(nAudPtr)
  Protected nWidth
  
  ; debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber + ", nAudioGraphWidth=" + nAudioGraphWidth)
  
  If *rMG\nMGNumber = 2 Or *rMG\nMGNumber = 5
    ASSERT_THREAD(#SCS_THREAD_MAIN)
  EndIf
  
  With *rMG
    nWidth = 600
    Select \nMGNumber
      Case 2, 5
        ; grMG2 is used by fmEditQF and associated routines
        ; grMG5 is used by fmEditQA and associated routines
        If IsGadget(\nCanvasGadget) : nWidth = GadgetWidth(\nCanvasGadget) : EndIf
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        nWidth = nAudioGraphWidth
    EndSelect
    
    \sFileName = ""
    \nGraphedFileAudPtr = -1
    \bInitDataLoaded = #False
    \bInitGraphDrawn = #False
    \nFileDataPtrForGraph = -1
    \bContainsLoop = #False
    \bAudPlaceHolder = #False
    \nInnerWidth = nWidth
    \nLastTimeMark = 0
    \nPrevTimeMarkX = 10000000
    \nGraphMaxX = \nInnerWidth - 1
    ; debugMsg(sProcName, \sMGNumber + "\nGraphMaxX=" + \nGraphMaxX)
    \nMaxGraphMarker = -1
    \dSamplePositionsPerPixel = 0.0
    \nAudPtr = nAudPtr
    \nFileDuration = aAud(nAudPtr)\nFileDuration  ; added 27Oct2015 11.4.2b
                                                  ; debugMsg(sProcName, \sMGNumber + "\nFileDuration=" + \nFileDuration)
    Select \nMGNumber
      Case 2
        ; grMG2 is used by fmEditQF and associated routines
        \nMaxInnerWidth = #SCS_GRAPH_MAX_INNER_WIDTH
        ; debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
        ; debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
        SGS(WQF\trbZoom, 1)
        ; debugMsg(sProcName, "calling WQF_processZoom(#True)")
        WQF_processZoom(#True)
        SLD_setValue(WQF\sldPosition, 0)
        SLD_setEnabled(WQF\sldPosition, #False)
        ; debugMsg(sProcName, "calling clearSlicePeakAndMinArrays(2)")
        clearSlicePeakAndMinArrays(*rMG)
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        \nMaxInnerWidth = nWidth
        \nVisibleWidth = nWidth
      Case 5
        \nMaxInnerWidth = #SCS_GRAPH_MAX_INNER_WIDTH
        ; grMG5 is used by fmEditQA and associated routines
        clearSlicePeakAndMinArrays(*rMG)
    EndSelect
    ; debugMsg(sProcName, \sMGNumber + "\nGraphMaxX=" + \nGraphMaxX + ", \nFileDuration=" + \nFileDuration + ", \nVisibleWidth=" + \nVisibleWidth + ", \nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth)
    ; debugMsg(sProcName, "calling resizeInnerAreaOfGraph(*rMG)")
    resizeInnerAreaOfGraph(*rMG)
    ; debugMsg(sProcName, \sMGNumber + "\nGraphMaxX=" + \nGraphMaxX + ", \nFileDuration=" + \nFileDuration + ", \nVisibleWidth=" + \nVisibleWidth + ", \nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth)
  EndWith
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure prepareAndDisplayGraph(*rMG.tyMG, bForceDrawing=#False)
  PROCNAMECA(nEditAudPtr)
  Protected nFileDataPtr
  Protected bLoadResult
  Protected bSkipDraw
  Protected sSubType.s
  
  debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber)
  
  clearSlicePeakAndMinArrays(*rMG) ; Added 7Oct2023 11.10.0ch
  
  With *rMG
    If grTempDB\bTempDatabaseLoaded = #False
      debugMsg(sProcName, "calling loadTempDatabaseFromProdDatabase()")
      loadTempDatabaseFromProdDatabase()
    EndIf
    
    If nEditAudPtr >= 0
      \bAudPlaceHolder = aAud(nEditAudPtr)\bAudPlaceHolder
      sSubType = aSub(nEditSubPtr)\sSubType
      nFileDataPtr = setFileInfoForGraph(*rMG, nEditAudPtr)
      debugMsg(sProcName, "nFileDataPtr=" + nFileDataPtr + ", *rMG\nFileDataPtrForSlicePeakAndMinArrays=" + *rMG\nFileDataPtrForSlicePeakAndMinArrays)
      If nFileDataPtr >= 0
        If aAud(nEditAudPtr)\nFileDuration <= getFileScanMaxLengthMS(sSubType) Or getFileScanMaxLength(sSubType) < 0
          If *rMG\nFileDataPtrForSlicePeakAndMinArrays <> nFileDataPtr
            debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(*rMG, " + nFileDataPtr + ", -1, " + getAudLabel(nEditAudPtr) + ")")
            bLoadResult = loadSlicePeakAndMinArraysFromDatabase(*rMG, nFileDataPtr, -1, nEditAudPtr)
            debugMsg(sProcName, "bLoadResult=" + strB(bLoadResult) + ", *rMG\nFileDataPtrForSlicePeakAndMinArrays=" + *rMG\nFileDataPtrForSlicePeakAndMinArrays)
          EndIf
        EndIf
        
        debugMsg(sProcName, "*rMG\nFileDataPtrForSamplesArray=" + *rMG\nFileDataPtrForSamplesArray + ", nFileDataPtr=" + nFileDataPtr)
        If *rMG\nFileDataPtrForSamplesArray <> nFileDataPtr
          If *rMG\bInitDataLoaded = #False
            If aAud(nEditAudPtr)\bAudTypeF
              setEnabled(WQF\trbZoom, #False)
              debugMsg(sProcName, "calling SGS(WQF\trbZoom, 1)")
              SGS(WQF\trbZoom, 1)
              debugMsg(sProcName, "GGS(WQF\trbZoom)=" + GGS(WQF\trbZoom))
              debugMsg(sProcName, "calling WQF_processZoom(#True)")
              WQF_processZoom(#True)
              SLD_setEnabled(WQF\sldPosition, #False)
              SLD_setValue(WQF\sldPosition, 0)
            EndIf
            If sSubType <> "A" ; Test added 9Apr2024 11.10.2bx
              ; Not sure why the following test exists, ie why we would skip drawing if nFileDataPtr >= 0, but it stopped 2nd and subsequent audio graphs being displayed for a video cue in "Video Test 1 WMV File.scs11"
              ; so have now pypassed the test for SubType A
              If nFileDataPtr >= 0
                bSkipDraw = #True
                debugMsg(sProcName, "bSkipDraw=" + strB(bSkipDraw))
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
    EndIf
    
    If bSkipDraw = #False
      If \nFileDataPtrForSlicePeakAndMinArrays = -1
        debugMsg(sProcName, "calling loadSlicePeakAndMinArraysAndDrawGraph(*rMG)")
        loadSlicePeakAndMinArraysAndDrawGraph(*rMG)
      Else
        debugMsg(sProcName, "calling drawWholeGraphArea(" + strB(bForceDrawing) + ")")
        drawWholeGraphArea(bForceDrawing)
      EndIf
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getZoomValue()
  PROCNAMEC()
  Protected nZoomValue
  
  If IsGadget(WQF\trbZoom)
    nZoomValue = GGS(WQF\trbZoom)
  EndIf
  ProcedureReturn nZoomValue
EndProcedure

Procedure resetGraphView(*rMG.tyMG, nViewStart, nViewEnd, bForceSave=#False, bForceDoNotSave=#False)
  PROCNAMEC()
  Protected nMGNumber
  Protected nLeft
  Protected bSaveToTempDatabase
  Protected nOldFileDuration, nOldInnerWidth, fOldMillisecondsPerPixel.f
  Protected nSldLoaderThreadState
  Protected sSubType.s
  
  ; debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber + ", nViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd +  ", bForceSave=" + strB(bForceSave) + ", bForceDoNotSave=" + strB(bForceDoNotSave))
  
  With *rMG
    nMGNumber = \nMGNumber
    If (nViewStart < 0) Or (nViewEnd <= nViewStart) Or (\nFileDuration <= 0)
      debugMsg(sProcName, "exiting - nViewStart=" + nViewStart + ", nViewEnd=" + nViewEnd + ", \nFileDuration=" + \nFileDuration)
      ProcedureReturn
    EndIf
    
    If IsThread(#SCS_THREAD_SLIDER_FILE_LOADER)
      If gnThreadNo <> #SCS_THREAD_SLIDER_FILE_LOADER
        nSldLoaderThreadState = THR_getThreadState(#SCS_THREAD_SLIDER_FILE_LOADER)
        If nSldLoaderThreadState = #SCS_THREAD_STATE_ACTIVE
          debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_SLIDER_FILE_LOADER, 100, 20000)")
          THR_suspendAThreadAndWait(#SCS_THREAD_SLIDER_FILE_LOADER, 100, 20000)
          If THR_getThreadState(#SCS_THREAD_SLIDER_FILE_LOADER) <> #SCS_THREAD_STATE_SUSPENDED
            debugMsg(sProcName, "exiting because THR_getThreadState(#SCS_THREAD_SLIDER_FILE_LOADER)=" + THR_decodeThreadState(THR_getThreadState(#SCS_THREAD_SLIDER_FILE_LOADER)))
            ProcedureReturn
          Else
            debugMsg(sProcName, "Thread #SCS_THREAD_SLIDER_FILE_LOADER suspended OK")
          EndIf
        EndIf
      EndIf
    EndIf
    
    nOldFileDuration = \nFileDuration
    nOldInnerWidth = \nInnerWidth
    fOldMillisecondsPerPixel = \fMillisecondsPerPixel
    
    \nViewStart = nViewStart
    \nViewEnd = nViewEnd
    \nViewRange = \nViewEnd - \nViewStart + 1
    
    \fMillisecondsPerPixel = (nViewEnd - nViewStart + 1) / \nVisibleWidth
    ; debugMsg(sProcName, \sMGNumber + "\nVisibleWidth=" + \nVisibleWidth + ", \nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange + ", >>\fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel))
    If nMGNumber = 2 Or nMGNumber = 5
      \nInnerWidth = \nFileDuration / \fMillisecondsPerPixel
      ; debugMsg(sProcName, \sMGNumber + "\nFileDuration=" + \nFileDuration + ", \nInnerWidth=" + \nInnerWidth)
    Else ; nMGNumber = 3 or 4
      \nInnerWidth = \nVisibleWidth
    EndIf
    If \nInnerWidth > \nMaxInnerWidth
      \nInnerWidth = \nMaxInnerWidth
    EndIf
    ; debugMsg(sProcName, \sMGNumber + "\nInnerWidth=" + \nInnerWidth + ", \nMaxInnerWidth=" + \nMaxInnerWidth)
    
    If (\nFileDuration <> nOldFileDuration) Or (\nInnerWidth <> nOldInnerWidth) Or (\fMillisecondsPerPixel <> fOldMillisecondsPerPixel)
      ; debugMsg(sProcName, "setting \nFileDataPtrForSlicePeakAndMinArrays=-1 (was " + \nFileDataPtrForSlicePeakAndMinArrays + ")")
      \nFileDataPtrForSlicePeakAndMinArrays = -1
      ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
    EndIf
    
    ; debugMsg(sProcName, "calling resizeInnerAreaOfGraph(*rMG)")
    resizeInnerAreaOfGraph(*rMG)
    
    If bForceDoNotSave = #False
      If (getZoomValue() <= 1) Or (bForceSave)
        bSaveToTempDatabase = #True
      EndIf
    EndIf
    
    If \nAudPtr >= 0
      \nFileDataPtrForGraph = aAud(\nAudPtr)\nFileDataPtr
      If nMGNumber = 3 Or nMGNumber = 4
        If \nFileDataPtrForGraph >= 0
          \nGraphChannels = gaFileData(\nFileDataPtrForGraph)\nxFileChannels
        EndIf
      EndIf
    EndIf
    
    nLeft = nViewStart / \fMillisecondsPerPixel * -1
    ; debugMsg(sProcName, "nLeft=" + nLeft + ", nViewStart=" + nViewStart + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,4))
    \nGraphLeft = nLeft
    
    sSubType = getSubTypeForAud(\nAudPtr)
    If \nFileDuration <= getFileScanMaxLengthMS(sSubType) Or getFileScanMaxLength(sSubType) < 0
      If \nFileDataPtrForSlicePeakAndMinArrays <> \nFileDataPtrForGraph
        ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(*rMG, " + \nFileDataPtrForGraph + ", " + \nInnerWidth + ", " + getAudLabel(\nAudPtr) + ") for " + GetFilePart(gaFileData(\nFileDataPtrForGraph)\sFileName))
        loadSlicePeakAndMinArraysFromDatabase(*rMG, \nFileDataPtrForGraph, \nInnerWidth, \nAudPtr)
      EndIf
      If \nFileDataPtrForSlicePeakAndMinArrays <> \nFileDataPtrForGraph
        ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(*rMG, " + \nFileDataPtrForGraph + ", " + \nInnerWidth + ", " + getAudLabel(\nAudPtr) + ", " + strB(bSaveToTempDatabase) + ") for " + GetFilePart(gaFileData(\nFileDataPtrForGraph)\sFileName))
        loadSlicePeakAndMinArraysFromSamplesArray(*rMG, \nFileDataPtrForGraph, \nInnerWidth, \nAudPtr, bSaveToTempDatabase)
      EndIf
    EndIf

    Select nMGNumber
      Case 2, 5
        ; grMG2 is used by fmEditQF and associated routines
        ; grMG5 is used by fmEditQA and associated routines
        ; debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
      Case 3, 4
        ; grMG3 is used For creating an image for an 'audio graph' progress slider
        ; grMG4 is used by the slider graph loader thread
        ; no action here
    EndSelect
    
  EndWith
  
  If IsThread(#SCS_THREAD_SLIDER_FILE_LOADER)
    If gnThreadNo <> #SCS_THREAD_SLIDER_FILE_LOADER
      If nSldLoaderThreadState = #SCS_THREAD_STATE_ACTIVE
        ; debugMsg(sProcName, "calling ResumeThread(#SCS_THREAD_SLIDER_FILE_LOADER)")
        ResumeThread(#SCS_THREAD_SLIDER_FILE_LOADER)
      EndIf
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkMousePosInGraphQF(bMouseDownEvent=#False)
  PROCNAMEC()
  Protected nSliceType
  Protected nReqdCursorType ; 0=Default, 1=Hand, 2=Grab, 3=LeftRight
  Protected nMouseX, nMouseY
  Protected nAbsMouseX
  Protected nGraphMarkerIndex
  Protected nGraphMarkerType, nCueMarkerType
  Protected nLevelOrPan
  Protected nLevelPointIndex, nItemIndex
  Protected nPointTime, nMarkerTime
  Protected nLoopInfoIndex
  Protected nCueMarkerId, nCueMarkerIndex, nCueMarkerPosition
  Protected l2
  Protected nTmpMaxMouseTimeLevelPoint, nTmpMinMouseTimeLevelPoint, nTmpMaxMouseTimeCueMarker, nTmpMinMouseTimeCueMarker
  Protected nLowerValue, nHigherValue
  
  With grMG2
    nSliceType = #SCS_SLICE_TYPE_NONE
    nGraphMarkerType = #SCS_GRAPH_MARKER_NONE
    nLevelOrPan = -1
    nGraphMarkerIndex = -1
    nLoopInfoIndex = -1
    nCueMarkerId = -1
    nCueMarkerIndex = -1
    nCueMarkerPosition = -1
    nCueMarkerType = -1
    
    nMouseX = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseX)
    nMouseY = GetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_MouseY)
    nAbsMouseX = nMouseX - \nGraphLeft
    
    While #True   ; not really a loop - just a mechanism to allow the use of Break
      ; debugMsg0(sProcName, "nMouseY=" + nMouseY + ", grMG2\nSEBarTop=" + \nSEBarTop + ", \nSEBarBottom=" + \nSEBarBottom)
      If (nMouseY >= \nSEBarTop) And (nMouseY <= \nSEBarBottom)
        ; mouse over the start/end bar
        ; check 'end' before checking 'start'
        If (nAbsMouseX >= (grGraph2\nSliceEN-9)) And (nAbsMouseX <= grGraph2\nSliceEN)
          If getEnabled(WQF\txtEndAt)
            nGraphMarkerType = #SCS_GRAPH_MARKER_EN
          EndIf
        ElseIf (nAbsMouseX >= grGraph2\nSliceST) And (nAbsMouseX <= (grGraph2\nSliceST+9))
          If getEnabled(WQF\txtStartAt)
            nGraphMarkerType = #SCS_GRAPH_MARKER_ST
          EndIf
        EndIf
        ; Break ; commented out - do not 'Break' because a level point marker may be partially displayed in the SE Bar
      EndIf
      
      If (nMouseY >= \nLoopBarTop) And (nMouseY <= \nLoopBarBottom)
        ; mouse over the loop start/end bar
        ; debugMsg0(sProcName, "mouse over the loop start/end bar, \nMGMaxLoop=" + \nMGMaxLoop + ", rWQF\nDisplayedLoopInfoIndex=" + rWQF\nDisplayedLoopInfoIndex)
        If (\nMGMaxLoop >= 0) And (rWQF\nDisplayedLoopInfoIndex >= 0)
          ; cue contains a loop (otherwise ignore)
          ; check 'end' before checking 'start'
          l2 = rWQF\nDisplayedLoopInfoIndex
          If (nAbsMouseX >= (grGraph2\nSliceLE(l2)-9)) And (nAbsMouseX <= grGraph2\nSliceLE(l2))
            If getEnabled(WQF\txtLoopEnd)
              nGraphMarkerType = #SCS_GRAPH_MARKER_LE
              nLoopInfoIndex = l2
              ; debugMsg(sProcName, "rWQF\nDisplayedLoopInfoIndex=" + rWQF\nDisplayedLoopInfoIndex + ", l2=" + l2 + ", nGraphMarkerType=#SCS_GRAPH_MARKER_LE, nLoopInfoIndex=" + nLoopInfoIndex)
            EndIf
          EndIf
          If nGraphMarkerType = #SCS_GRAPH_MARKER_NONE
            If (nAbsMouseX >= grGraph2\nSliceLS(l2)) And (nAbsMouseX <= (grGraph2\nSliceLS(l2)+9))
              If getEnabled(WQF\txtLoopStart)
                nGraphMarkerType = #SCS_GRAPH_MARKER_LS
                nLoopInfoIndex = l2
                ; debugMsg(sProcName, "rWQF\nDisplayedLoopInfoIndex=" + rWQF\nDisplayedLoopInfoIndex + ", l2=" + l2 + ", nGraphMarkerType=#SCS_GRAPH_MARKER_LS, nLoopInfoIndex=" + nLoopInfoIndex)
              EndIf
            EndIf
          EndIf
        EndIf
        ; Break ; commented out - do not 'Break' because a level point marker may be partially displayed in the Loop Bar
      EndIf
      
      If nGraphMarkerType = #SCS_GRAPH_MARKER_NONE
        nGraphMarkerIndex = checkMouseOnGraphMarker(@grMG2, nMouseX, nMouseY)
        \nGraphMarkerIndex = nGraphMarkerIndex
        If nGraphMarkerIndex >= 0
          nGraphMarkerType = \aGraphMarker(nGraphMarkerIndex)\nGraphMarkerType
          nLevelOrPan = \aGraphMarker(nGraphMarkerIndex)\nLevelOrPan
          nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
          nCueMarkerIndex = \aGraphMarker(nGraphMarkerIndex)\nMGCueMarkerIndex
          nLoopInfoIndex = \aGraphMarker(nGraphMarkerIndex)\nLoopInfoIndex
          ; debugMsg(sProcName, "nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType) + ", nLoopInfoIndex=" + nLoopInfoIndex)
        EndIf
      EndIf
      
      If bMouseDownEvent
        \nMouseDownGraphMarkerIndex = nGraphMarkerIndex
        \nMouseDownCueMarkerId = nCueMarkerId
        \nMouseDownGraphMarkerType = nGraphMarkerType
        \nMouseDownLevelOrPan = nLevelOrPan
        ; set \nMouseMinTime and \nMouseMaxTime for all marker types (including 'none')
        ; these min and max times may be changed for level points later in this procedure
        \nMouseMinTime = aAud(nEditAudPtr)\nAbsMin
        \nMouseMaxTime = aAud(nEditAudPtr)\nAbsMax
        ; debugMsg(sProcName, "grMG2\nMouseMinTime=" + \nMouseMinTime + ", \nMouseMaxTime=" + \nMouseMaxTime)
      EndIf
      
      Select nGraphMarkerType
        Case #SCS_GRAPH_MARKER_ST
          nSliceType = #SCS_SLICE_TYPE_ST
          If bMouseDownEvent
            nTmpMaxMouseTimeCueMarker = getMaxTimeforCueMarkers(nEditAudPtr) ; returns -1 if no cue markers
            If nTmpMaxMouseTimeCueMarker >= 0
              \nMouseMaxTime = nTmpMaxMouseTimeCueMarker
            Else
              nPointTime = aAud(nEditAudPtr)\nAbsStartAt
              \nMouseMaxTime = getMaxTimeForPoint(nEditAudPtr, nPointTime)
            EndIf
            \nMouseDownLevelPointId = getLevelPointIdForType(nEditAudPtr, #SCS_PT_START)
            \nMouseDownItemIndex = -1
          EndIf
          
        Case #SCS_GRAPH_MARKER_EN
          nSliceType = #SCS_SLICE_TYPE_EN
          If bMouseDownEvent
            nTmpMinMouseTimeCueMarker = getMinTimeforCueMarkers(nEditAudPtr) ; returns -1 if no cue markers
            If nTmpMinMouseTimeCueMarker >= 0
              \nMouseMinTime = nTmpMinMouseTimeCueMarker
            Else
              nPointTime = aAud(nEditAudPtr)\nAbsEndAt
              \nMouseMinTime = getMinTimeForPoint(nEditAudPtr, nPointTime)
            EndIf
            ; debugMsg(sProcName, "EN: aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt + ", grMG2\nMouseMinTime=" + \nMouseMinTime + ", nTmpMinMouseTimeCueMarker=" + nTmpMinMouseTimeCueMarker)
            \nMouseDownLevelPointId = getLevelPointIdForType(nEditAudPtr, #SCS_PT_END)
            \nMouseDownItemIndex = -1
          EndIf
          
        Case #SCS_GRAPH_MARKER_FI
          nSliceType = #SCS_SLICE_TYPE_FI
        Case #SCS_GRAPH_MARKER_FO
          nSliceType = #SCS_SLICE_TYPE_FO
        Case #SCS_GRAPH_MARKER_LS
          nSliceType = #SCS_SLICE_TYPE_LS
          \nMouseDownLoopInfoIndex = nLoopInfoIndex
        Case #SCS_GRAPH_MARKER_LE
          nSliceType = #SCS_SLICE_TYPE_LE
          \nMouseDownLoopInfoIndex = nLoopInfoIndex
            
        Case #SCS_GRAPH_MARKER_LP
          nLevelPointIndex = \aGraphMarker(nGraphMarkerIndex)\nLevelPointIndex
          nItemIndex = \aGraphMarker(nGraphMarkerIndex)\nItemIndex
          ; Debug sProcName + ": (LP) nGraphMarkerIndex=" + nGraphMarkerIndex + ", nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + nItemIndex
          If (nLevelPointIndex >= 0) And (nEditAudPtr >= 0)
            nSliceType = #SCS_SLICE_TYPE_LP
            Select aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType
              Case #SCS_PT_FADE_IN
                nSliceType = #SCS_SLICE_TYPE_FI
              Case #SCS_PT_FADE_OUT
                nSliceType = #SCS_SLICE_TYPE_FO
              Case #SCS_PT_START
                If getEnabled(WQF\txtStartAt)
                  nSliceType = #SCS_SLICE_TYPE_ST
                EndIf
              Case #SCS_PT_END
                If getEnabled(WQF\txtEndAt)
                  nSliceType = #SCS_SLICE_TYPE_EN
                EndIf
            EndSelect
            If nSliceType = #SCS_SLICE_TYPE_LP
              If grLicInfo\bStdLvlPtsAvailable = #False
                nSliceType = #SCS_SLICE_TYPE_NONE
              EndIf
            EndIf
            If bMouseDownEvent
              \nMouseDownLevelPointId = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointId
              \nMouseDownItemIndex = nItemIndex
              \fMouseDownRelDBLevel = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel
              nPointTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
              \nMouseMinTime = getMinTimeForPoint(nEditAudPtr, nPointTime)
              \nMouseMaxTime = getMaxTimeForPoint(nEditAudPtr, nPointTime)
              ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointTime=" + aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime + ", grMG2\nMouseMinTime=" + \nMouseMinTime + ", \nMouseMaxTime=" + \nMouseMaxTime)
            Else
              \nMouseMoveLevelPointId = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointId
            EndIf
          Else
            nSliceType = #SCS_SLICE_TYPE_LP
            \nMouseMoveLevelPointId = -1
          EndIf
          
        Case #SCS_GRAPH_MARKER_CM ; Cue Marker Selection
          If nGraphMarkerIndex >= 0
            nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
            nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
            ; debugMsg(sProcName, "(CM) nCueMarkerId=" + nCueMarkerId + ", nGraphMarkerIndex=" + nGraphMarkerIndex + ", nCueMarkerIndex=" + nCueMarkerIndex + ", nMarkerTime=" + nMarkerTime)
            nSliceType = #SCS_SLICE_TYPE_CM
            If bMouseDownEvent
              \nMouseDownGraphMarkerIndex = nCueMarkerIndex
              \nMouseMinTime = getMinTimeforACueMarker(nEditAudPtr)
              \nMouseMaxTime = getMaxTimeforACueMarker(nEditAudPtr)
              ; debugMsg(sProcName, "(CM) nGraphMarkerIndex=" + nGraphMarkerIndex + ", nCueMarkerIndex=" + nCueMarkerIndex + ", \nMouseMinTime=" + \nMouseMinTime + ", \nMouseMaxTime=" + \nMouseMaxTime)
            Else
              \nMouseMoveMarkerIndex = nCueMarkerIndex
            EndIf
          EndIf
          
        Case #SCS_GRAPH_MARKER_CP
          If nGraphMarkerIndex >= 0
            nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
            nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
            nSliceType = #SCS_SLICE_TYPE_CP
            \nMouseMoveMarkerIndex = nCueMarkerIndex
          EndIf
          
      EndSelect
      
      If nSliceType = #SCS_SLICE_TYPE_NONE
        If (nMouseY >= \nGraphTop) And (nMouseY <= \nGraphBottom)
          If (nMouseX >= (grGraph2\nSlicePos-1)) And (nMouseX <= (grGraph2\nSlicePos+1))
            nSliceType = #SCS_SLICE_TYPE_CURR
          Else
            nSliceType = #SCS_SLICE_TYPE_NORMAL
          EndIf
          Break
        EndIf
      EndIf
      
      Break
    Wend
    ; debugMsg(sProcName,"nMouseX=" + Str(nMouseX) + ", \nGraphLeft=" + Str(\nGraphLeft) + ", \nGraphRight=" + Str(\nGraphRight) + ", grGraph2\nSlicePos=" + Str(grGraph2\nSlicePos) + ", nSliceType=" + Str(nSliceType))
    
    Select nSliceType
      Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN, #SCS_SLICE_TYPE_LS, #SCS_SLICE_TYPE_LE, #SCS_SLICE_TYPE_CURR, #SCS_SLICE_TYPE_FI, #SCS_SLICE_TYPE_FO, #SCS_SLICE_TYPE_LP, #SCS_SLICE_TYPE_CM
        ; nb exclude #SCS_SLICE_TYPE_CP from this as a cue point (a cue point set in a file) cannot be moved by SCS
        nReqdCursorType = 1   ; hand
      Case #SCS_SLICE_TYPE_NORMAL
        ; nReqdCursorType = 2   ; grab
        ; changed to 'default' at 11.3.0 to assist in successfully selecting level point for adjustment
        nReqdCursorType = 0   ; default
      Default
        nReqdCursorType = 0   ; default
    EndSelect
    
  EndWith
  
  Select nReqdCursorType
    Case 0  ; Default
      SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, #PB_Cursor_Default)
    Case 1  ; Hand
      SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, #PB_Cursor_Hand)
    Case 2  ; Grab
      SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_CustomCursor, hCursorGrab)
    Case 3  ; LeftRight
      SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
  EndSelect
  
  ; debugMsg(sProcName, #SCS_END + ", returning nSliceType=" + decodeSliceType(nSliceType) + ", nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType) + ", nLoopInfoIndex=" + nLoopInfoIndex)
  ProcedureReturn nSliceType
  
EndProcedure

Procedure checkMousePosInGraphQA(bMouseDownEvent=#False)
  PROCNAMEC()
  Protected nSliceType
  Protected nReqdCursorType ; 0=Default, 1=Hand, 2=Grab, 3=LeftRight
  Protected nMouseX, nMouseY
  Protected nAbsMouseX
  Protected nGraphMarkerIndex
  Protected nGraphMarkerType, nCueMarkerType
  Protected nLevelOrPan
  Protected nLevelPointIndex, nItemIndex
  Protected nPointTime, nMarkerTime
  Protected nCueMarkerId, nCueMarkerIndex, nCueMarkerPosition
  Protected l2
  Protected nTmpMaxMouseTimeCueMarker, nTmpMinMouseTimeCueMarker
  Protected nLowerValue, nHigherValue
  
  With grMG5
    nSliceType = #SCS_SLICE_TYPE_NONE
    nGraphMarkerType = #SCS_GRAPH_MARKER_NONE
    nLevelOrPan = -1
    nGraphMarkerIndex = -1
    nCueMarkerId = -1
    nCueMarkerIndex = -1
    nCueMarkerPosition = -1
    nCueMarkerType = -1
    
    nMouseX = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseX)
    nMouseY = GetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_MouseY)
    nAbsMouseX = nMouseX - \nGraphLeft
    
    While #True   ; not really a loop - just a mechanism to allow the use of Break
      ; debugMsg0(sProcName, "nMouseY=" + nMouseY + ", \nSEBarTop=" + \nSEBarTop + ", \nSEBarBottom=" + \nSEBarBottom)
      If (nMouseY >= \nSEBarTop) And (nMouseY <= \nSEBarBottom)
        ; mouse over the start/end bar
        ; check 'end' before checking 'start'
        If (nAbsMouseX >= (grGraph2\nSliceEN-9)) And (nAbsMouseX <= grGraph2\nSliceEN)
          If getEnabled(WQA\txtEndAt)
            nGraphMarkerType = #SCS_GRAPH_MARKER_EN
          EndIf
        ElseIf (nAbsMouseX >= grGraph2\nSliceST) And (nAbsMouseX <= (grGraph2\nSliceST+9))
          If getEnabled(WQA\txtStartAt)
            nGraphMarkerType = #SCS_GRAPH_MARKER_ST
          EndIf
        EndIf
        ; Break ; commented out - do not 'Break' because a level point marker may be partially displayed in the SE Bar
      EndIf
      ; debugMsg0(sProcName, "nAbsMouseX=" + nAbsMouseX + ", grGraph2\nSliceST=" + grGraph2\nSliceST + ", grGraph2\nSliceEN=" + grGraph2\nSliceEN + ", nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType))
      
      If nGraphMarkerType = #SCS_GRAPH_MARKER_NONE
        nGraphMarkerIndex = checkMouseOnGraphMarker(@grMG5, nMouseX, nMouseY)
        \nGraphMarkerIndex = nGraphMarkerIndex
        If nGraphMarkerIndex >= 0
          nGraphMarkerType = \aGraphMarker(nGraphMarkerIndex)\nGraphMarkerType
          nLevelOrPan = \aGraphMarker(nGraphMarkerIndex)\nLevelOrPan
          nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
          nCueMarkerIndex = \aGraphMarker(nGraphMarkerIndex)\nMGCueMarkerIndex
        EndIf
      EndIf
      
      If bMouseDownEvent
        \nMouseDownGraphMarkerIndex = nGraphMarkerIndex
        \nMouseDownCueMarkerId = nCueMarkerId
        \nMouseDownGraphMarkerType = nGraphMarkerType
        \nMouseDownLevelOrPan = nLevelOrPan
        ; set \nMouseMinTime and \nMouseMaxTime for all marker types (including 'none')
        ; these min and max times may be changed for level points later in this procedure
        \nMouseMinTime = aAud(nEditAudPtr)\nAbsMin
        \nMouseMaxTime = aAud(nEditAudPtr)\nAbsMax
        ; debugMsg0(sProcName, "grMG5\nMouseMinTime=" + \nMouseMinTime + ", \nMouseMaxTime=" + \nMouseMaxTime)
      EndIf
      
      Select nGraphMarkerType
        Case #SCS_GRAPH_MARKER_ST
          nSliceType = #SCS_SLICE_TYPE_ST
          If bMouseDownEvent
            nTmpMaxMouseTimeCueMarker = getMaxTimeforCueMarkers(nEditAudPtr) ; returns -1 if no cue markers
            If nTmpMaxMouseTimeCueMarker >= 0
              \nMouseMaxTime = nTmpMaxMouseTimeCueMarker
            Else
              ; Commented out 20Feb2024 11.10.2qt because video/image sub-cues do not have level envelopes,
              ; and the following code was setting \nMouseMaxTime to the passed in value of nPointTime, ie \nAbsStartAt
              ; nPointTime = aAud(nEditAudPtr)\nAbsStartAt
              ; \nMouseMaxTime = getMaxTimeForPoint(nEditAudPtr, nPointTime)
            EndIf
            \nMouseDownLevelPointId = getLevelPointIdForType(nEditAudPtr, #SCS_PT_START)
            \nMouseDownItemIndex = -1
          EndIf
          
        Case #SCS_GRAPH_MARKER_EN
          nSliceType = #SCS_SLICE_TYPE_EN
          If bMouseDownEvent
            nTmpMinMouseTimeCueMarker = getMinTimeforCueMarkers(nEditAudPtr) ; returns -1 if no cue markers
            If nTmpMinMouseTimeCueMarker >= 0
              \nMouseMinTime = nTmpMinMouseTimeCueMarker
            Else
              ; Commented out 20Feb2024 11.10.2qt because video/image sub-cues do not have level envelopes,
              ; and the following code was setting \nMouseMinTime to the passed in value of nPointTime, ie \nAbsEndAt
              ; nPointTime = aAud(nEditAudPtr)\nAbsEndAt
              ; \nMouseMinTime = getMinTimeForPoint(nEditAudPtr, nPointTime)
            EndIf
            ; debugMsg(sProcName, "EN: aAud(" + getAudLabel(nEditAudPtr) + ")\nAbsEndAt=" + aAud(nEditAudPtr)\nAbsEndAt + ", grMG5\nMouseMinTime=" + \nMouseMinTime + ", nTmpMinMouseTimeCueMarker=" + nTmpMinMouseTimeCueMarker)
            \nMouseDownLevelPointId = getLevelPointIdForType(nEditAudPtr, #SCS_PT_END)
            \nMouseDownItemIndex = -1
          EndIf
          
        Case #SCS_GRAPH_MARKER_CM ; Cue Marker Selection
          If nGraphMarkerIndex >= 0
            nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
            nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
            ; debugMsg(sProcName, "(CM) nCueMarkerId=" + nCueMarkerId + ", nGraphMarkerIndex=" + nGraphMarkerIndex + ", nCueMarkerIndex=" + nCueMarkerIndex + ", nMarkerTime=" + nMarkerTime)
            nSliceType = #SCS_SLICE_TYPE_CM
            If bMouseDownEvent
              \nMouseDownGraphMarkerIndex = nCueMarkerIndex
              \nMouseMinTime = getMinTimeforACueMarker(nEditAudPtr)
              \nMouseMaxTime = getMaxTimeforACueMarker(nEditAudPtr)
              ; debugMsg(sProcName, "(CM) nGraphMarkerIndex=" + nGraphMarkerIndex + ", nCueMarkerIndex=" + nCueMarkerIndex + ", \nMouseMinTime=" + \nMouseMinTime + ", \nMouseMaxTime=" + \nMouseMaxTime)
            Else
              \nMouseMoveMarkerIndex = nCueMarkerIndex
            EndIf
          EndIf
          
        Case #SCS_GRAPH_MARKER_CP
          If nGraphMarkerIndex >= 0
            nCueMarkerId = \aGraphMarker(nGraphMarkerIndex)\nCueMarkerId
            nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
            nSliceType = #SCS_SLICE_TYPE_CP
            \nMouseMoveMarkerIndex = nCueMarkerIndex
          EndIf
          
      EndSelect
      
      If nSliceType = #SCS_SLICE_TYPE_NONE
        If (nMouseY >= \nGraphTop) And (nMouseY <= \nGraphBottom)
          If (nMouseX >= (grGraph2\nSlicePos-1)) And (nMouseX <= (grGraph2\nSlicePos+1))
            nSliceType = #SCS_SLICE_TYPE_CURR
          Else
            nSliceType = #SCS_SLICE_TYPE_NORMAL
          EndIf
          Break
        EndIf
      EndIf
      
      Break
    Wend
    ; debugMsg(sProcName,"nMouseX=" + Str(nMouseX) + ", \nGraphLeft=" + Str(\nGraphLeft) + ", \nGraphRight=" + Str(\nGraphRight) + ", grGraph2\nSlicePos=" + Str(grGraph2\nSlicePos) + ", nSliceType=" + Str(nSliceType))
    
    Select nSliceType
      Case #SCS_SLICE_TYPE_ST, #SCS_SLICE_TYPE_EN, #SCS_SLICE_TYPE_CURR, #SCS_SLICE_TYPE_CM
        nReqdCursorType = 1   ; hand
      Default
        nReqdCursorType = 0   ; default
    EndSelect
    
  EndWith
  
  Select nReqdCursorType
    Case 0  ; Default
      SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, #PB_Cursor_Default)
    Case 1  ; Hand
      SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, #PB_Cursor_Hand)
    Case 2  ; Grab
      SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_CustomCursor, hCursorGrab)
    Case 3  ; LeftRight
      SetGadgetAttribute(WQA\cvsGraphQA, #PB_Canvas_Cursor, #PB_Cursor_LeftRight)
  EndSelect
  
  ; debugMsg(sProcName, #SCS_END + ", returning nSliceType=" + decodeSliceType(nSliceType) + ", nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType) + ", nLoopInfoIndex=" + nLoopInfoIndex)
  ProcedureReturn nSliceType
  
EndProcedure

Procedure drawTip(*rMG.tyMG, nSliceType, nLevelPointIndex, nLoopInfoIndex, nCueMarkerIndex=-1)
  ; PROCNAMEC()
  Static bStaticLoaded
  Static sStartAt.s, sEndAt.s, sLoopStart.s, sLoopEnd.s, sFadeIn.s, sFadeOut.s, sLevelPoint.s, sPanPoint.s, sCueMarker.s, sCueMarkerDesc.s, sCueMarkerTime.s
  Static nStartAtWidth, nEndAtWidth, nLoopStartWidth, nLoopEndWidth, nFadeInWidth, nFadeOutWidth, nLevelPointWidth, nPanPointWidth
  Static nTextHeight
  Static nSpacer1, nSpacer2
  Protected sTipText.s
  Protected nTextX, nTextY
  Protected bDrawingStartedByMe
  Protected nTextColor
  Protected nMouseX
  Protected nTipWidth
  Protected nLevelOrPan
  
  ; debugMsg(sProcName, #SCS_START + ", nSliceType=" + decodeSliceType(nSliceType) + ", nLevelPointIndex=" + nLevelPointIndex + ", nLoopInfoIndex=" + nLoopInfoIndex + ", nCueMarkerIndex=" + nCueMarkerIndex)
  
  With *rMG
    If bStaticLoaded = #False
      sStartAt = Lang("Graph", "StartAt")
      sEndAt = Lang("Graph", "EndAt")
      sLoopStart = Lang("Graph", "LoopStart")
      sLoopEnd = Lang("Graph", "LoopEnd")
      sFadeIn = Lang("Graph", "FadeIn")
      sFadeOut = Lang("Graph", "FadeOut")
      sLevelPoint = Lang("Graph", "LevelPoint")
      sPanPoint = Lang("Graph", "PanPoint")
      sCueMarker=Lang("Graph", "CueMarker")
      bDrawingStartedByMe = condStartGraphDrawing(*rMG)
      DrawingFont(FontID(#SCS_FONT_GEN_NORMAL))
      nStartAtWidth = TextWidth(sStartAt)
      nEndAtWidth = TextWidth(sEndAt)
      nLoopStartWidth = TextWidth(sLoopStart)
      nLoopEndWidth = TextWidth(sLoopEnd)
      nFadeInWidth = TextWidth(sFadeIn)
      nFadeOutWidth = TextWidth(sFadeOut)
      nLevelPointWidth = TextWidth(sLevelPoint)
      nPanPointWidth = TextWidth(sPanPoint)
      nTextHeight = TextHeight("Pg")
      nSpacer1 = TextWidth("x")
      nSpacer2 = nSpacer1 << 1
      condStopGraphDrawing(*rMG, bDrawingStartedByMe)
      bStaticLoaded = #True
    EndIf
    
    If \bTipDrawn
      If nSliceType <> \nTipSliceType
        drawGraph(*rMG)
        ProcedureReturn
      EndIf
    EndIf
    
    Select nSliceType
      Case #SCS_SLICE_TYPE_ST
        sTipText = sStartAt
        nTextX = grGraph2\nSliceST + nSpacer2 + \nGraphLeft
        nTextY = \nSEBarTop - 1
        
      Case #SCS_SLICE_TYPE_EN
        sTipText = sEndAt
        nTextX = grGraph2\nSliceEN - nEndAtWidth - nSpacer2 + \nGraphLeft
        nTextY = \nSEBarTop - 1
        
      Case #SCS_SLICE_TYPE_LS
        sTipText = sLoopStart
        nTextX = grGraph2\nSliceLS(nLoopInfoIndex) + nSpacer2 + \nGraphLeft
        nTextY = \nLoopBarTop - 1
        
      Case #SCS_SLICE_TYPE_LE
        sTipText = sLoopEnd
        nTextX = grGraph2\nSliceLE(nLoopInfoIndex) - nLoopEndWidth - nSpacer2 + \nGraphLeft
        nTextY = \nLoopBarTop - 1
        
      Case #SCS_SLICE_TYPE_FI
        sTipText = sFadeIn
        nTextX = grGraph2\nSliceFI + nSpacer1 + \nGraphLeft
        nTextY = \nLoopBarTop - 1
        
      Case #SCS_SLICE_TYPE_FO
        sTipText = sFadeOut
        nTextX = grGraph2\nSliceFO - nFadeOutWidth - nSpacer1 + \nGraphLeft
        nTextY = \nLoopBarTop - 1
        
      Case #SCS_SLICE_TYPE_LP
        sTipText = sLevelPoint
        If (nLevelPointIndex >= 0) And (nEditAudPtr >= 0)
          If aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType = #SCS_PT_STD
            If \nGraphMarkerIndex >= 0
              nLevelOrPan = \aGraphMarker(\nGraphMarkerIndex)\nLevelOrPan
            Else
              nLevelOrPan = #SCS_GRAPH_MARKER_LEVEL
            EndIf
            If nLevelOrPan = #SCS_GRAPH_MARKER_PAN
              sTipText = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\sPanPointDesc
            Else
              sTipText = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\sPointDesc
            EndIf
          EndIf
        EndIf
        nTextY = \nLoopBarTop - 1
        
      Case #SCS_SLICE_TYPE_CM, #SCS_SLICE_TYPE_CP
        ; debugMsg(sProcName, "CM nCueMarkerIndex=" + nCueMarkerIndex + ", \bTipDrawn=" + strB(\bTipDrawn))
        ; Debug sProcName + ": CM nCueMarkerIndex=" + nCueMarkerIndex
        If nCueMarkerIndex <> -1
          sCueMarkerTime = ttszt(aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition)
          sCueMarkerDesc = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\sCueMarkerName + ": " + sCueMarkerTime         
          If sCueMarkerDesc
            sTipText = sCueMarkerDesc
          Else
            sTipText = sCueMarker
          EndIf
          nTextY = \nLoopBarTop - 1
        EndIf
        
      Default
        If (\nTipSliceType <> #SCS_SLICE_TYPE_NONE) And (\nTipSliceType <> #SCS_SLICE_TYPE_CURR)
          gqMainThreadRequest | #SCS_MTH_DRAW_WQF_GRAPH
          \nTipSliceType = #SCS_SLICE_TYPE_NONE
        EndIf
        ProcedureReturn
        
    EndSelect
    
    If \bTipDrawn = #False
      bDrawingStartedByMe = condStartGraphDrawing(*rMG)
      ; DrawingMode(#PB_2DDrawing_Transparent); commented out 22Oct2019 11.8.2bc to make the tip easier to read
      DrawingFont(FontID(#SCS_FONT_GEN_NORMAL))
      Select nSliceType
        Case #SCS_SLICE_TYPE_LP, #SCS_SLICE_TYPE_CM, #SCS_SLICE_TYPE_CP
          nMouseX = GetGadgetAttribute(\nCanvasGadget, #PB_Canvas_MouseX)
          nTipWidth = TextWidth(sTipText)
          nTextX = nMouseX - (nTipWidth >> 1)
      EndSelect
      DrawText(nTextX, nTextY, sTipText, #SCS_White)
      condStopGraphDrawing(*rMG, bDrawingStartedByMe)
      \bTipDrawn = #True
    EndIf
    \nTipSliceType = nSliceType
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", bDrawingStartedByMe=" + strB(bDrawingStartedByMe))
  
EndProcedure

Procedure.s decodeSliceType(nSliceType)
  PROCNAMEC()
  Protected sSliceType.s
  
  Select nSliceType
    Case #SCS_SLICE_TYPE_NONE
      sSliceType = "SCS_SLICE_TYPE_NONE"
    Case #SCS_SLICE_TYPE_NORMAL
      sSliceType = "SCS_SLICE_TYPE_NORMAL"
    Case #SCS_SLICE_TYPE_CURR  ; current position
      sSliceType = "SCS_SLICE_TYPE_CURR"
    Case #SCS_SLICE_TYPE_ST    ; start at
      sSliceType = "SCS_SLICE_TYPE_ST"
    Case #SCS_SLICE_TYPE_EN    ; end at
      sSliceType = "SCS_SLICE_TYPE_EN"
    Case #SCS_SLICE_TYPE_LS    ; loop start
      sSliceType = "SCS_SLICE_TYPE_LS"
    Case #SCS_SLICE_TYPE_LE    ; loop end
      sSliceType = "SCS_SLICE_TYPE_LE"
    Case #SCS_SLICE_TYPE_FI    ; fade-in (end point)
      sSliceType = "SCS_SLICE_TYPE_FI"
    Case #SCS_SLICE_TYPE_FO    ; fade-out (start point)
      sSliceType = "SCS_SLICE_TYPE_FO"
    Case #SCS_SLICE_TYPE_LP    ; level point
      sSliceType = "SCS_SLICE_TYPE_LP"
    Case #SCS_SLICE_TYPE_CM    ; SCS cue marker
      sSliceType = "SCS_SLICE_TYPE_CM"
    Case #SCS_SLICE_TYPE_CP    ; file cue point
      sSliceType = "SCS_SLICE_TYPE_CP"
    Default
      sSliceType = Str(nSliceType)
  EndSelect
  ProcedureReturn sSliceType
EndProcedure

Procedure.s decodeGraphMarkerType(nGraphMarkerType)
  PROCNAMEC()
  Protected sGraphMarkerType.s
  
  Select nGraphMarkerType
    Case #SCS_GRAPH_MARKER_NONE
      sGraphMarkerType = "SCS_GRAPH_MARKER_NONE"
    Case #SCS_GRAPH_MARKER_ST    ; start at
      sGraphMarkerType = "SCS_GRAPH_MARKER_ST"
    Case #SCS_GRAPH_MARKER_EN    ; end at
      sGraphMarkerType = "SCS_GRAPH_MARKER_EN"
    Case #SCS_GRAPH_MARKER_LS    ; loop start
      sGraphMarkerType = "SCS_GRAPH_MARKER_LS"
    Case #SCS_GRAPH_MARKER_LE    ; loop end
      sGraphMarkerType = "SCS_GRAPH_MARKER_LE"
    Case #SCS_GRAPH_MARKER_FI    ; fade-in (end point)
      sGraphMarkerType = "SCS_GRAPH_MARKER_FI"
    Case #SCS_GRAPH_MARKER_FO    ; fade-out (start point)
      sGraphMarkerType = "SCS_GRAPH_MARKER_FO"
    Case #SCS_GRAPH_MARKER_LP    ; level point
      sGraphMarkerType = "SCS_GRAPH_MARKER_LP"
    Case #SCS_GRAPH_MARKER_CM    ; SCS Cue Marker
      sGraphMarkerType = "SCS_GRAPH_MARKER_CM"
    Case #SCS_GRAPH_MARKER_CP    ; File Cue Point
      sGraphMarkerType = "SCS_GRAPH_MARKER_CP"
    Default
      sGraphMarkerType = Str(nGraphMarkerType)
  EndSelect
  ProcedureReturn sGraphMarkerType
EndProcedure

Procedure addGraphMarker(*rMG.tyMG, nGraphMarkerType, nLevelPointIndex, nLevelOrPan, nItemIndex, nX, nY, nWidth, nHeight, nMarkerTime=-1, nCueMarkerId=-1, nLoopInfoIndex=-1)
  ; PROCNAMECA(nEditAudPtr)
  Protected n
  Protected bFound
  Protected nReqdMarkerTime
  Protected nLevelPointType
  Protected nCueMarkerIndex
  
  ; debugMsg0(sProcName, #SCS_START + ", nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType) + ", nLevelPointIndex=" + nLevelPointIndex + ", nX=" + nX + ", nY=" + nY + ", nMarkerTime=" + nMarkerTime)
  
  With *rMG
    If (nLevelOrPan = #SCS_GRAPH_MARKER_LEVEL) And (grEditorPrefs\bEditShowLvlCurvesSel = #False)
      ProcedureReturn
    EndIf
    If (nLevelOrPan = #SCS_GRAPH_MARKER_PAN) And (grEditorPrefs\bEditShowPanCurvesSel = #False)
      ProcedureReturn
    EndIf
    
    For n = 0 To \nMaxGraphMarker
      If (\aGraphMarker(n)\nGraphMarkerType = nGraphMarkerType) And (\aGraphMarker(n)\nLevelPointIndex = nLevelPointIndex) And (\aGraphMarker(n)\nLevelOrPan = nLevelOrPan) And (\aGraphMarker(n)\nCueMarkerId = nCueMarkerId)
        bFound = #True
        Break
      EndIf
    Next n
    If bFound = #False
      \nMaxGraphMarker + 1
      If \nMaxGraphMarker > ArraySize(\aGraphMarker())
        ReDim \aGraphMarker(\nMaxGraphMarker + 5)
      EndIf
      n = \nMaxGraphMarker
    EndIf
  EndWith
  
  With *rMG\aGraphMarker(n)
    \nGraphMarkerType = nGraphMarkerType
    ; Added 11Feb2022 11.9.0
    \nLevelPointIndex = nLevelPointIndex
    If nLevelPointIndex >= 0
      \nLevelPointId = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointId
    Else
      \nLevelPointId = -1
    EndIf
    ; End added 11Feb2022 11.9.0
    \nLevelOrPan = nLevelOrPan
    \nItemIndex = nItemIndex
    \nX = nX
    \nY = nY
    \nWidth = nWidth
    \nHeight = nHeight
    \fMidPointX = nX + ((nWidth - 1) / 2)
    \fMidPointY = nY + ((nHeight - 1) / 2)
    nReqdMarkerTime = nMarkerTime
    \nMGCueMarkerIndex = -1
    \nCueMarkerId = nCueMarkerId
    \nLoopInfoIndex = nLoopInfoIndex
    
    If nMarkerTime = -1
      If nLevelPointIndex >= 0
        nReqdMarkerTime = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointTime
        nLevelPointType = aAud(nEditAudPtr)\aPoint(nLevelPointIndex)\nPointType
      Else
        Select nGraphMarkerType
          Case #SCS_GRAPH_MARKER_ST
            nReqdMarkerTime = aAud(nEditAudPtr)\nAbsStartAt
            nLevelPointType = #SCS_PT_START
          Case #SCS_GRAPH_MARKER_FI
            nReqdMarkerTime = aAud(nEditAudPtr)\nAbsStartAt + aAud(nEditAudPtr)\nFadeInTime
            nLevelPointType = #SCS_PT_FADE_IN
          Case #SCS_GRAPH_MARKER_FO
            nReqdMarkerTime = aAud(nEditAudPtr)\nAbsEndAt - aAud(nEditAudPtr)\nFadeOutTime
            nLevelPointType = #SCS_PT_FADE_OUT
          Case #SCS_GRAPH_MARKER_EN
            nReqdMarkerTime = aAud(nEditAudPtr)\nAbsEndAt
            nLevelPointType = #SCS_PT_END
          Case #SCS_GRAPH_MARKER_CM, #SCS_GRAPH_MARKER_CP
            nCueMarkerIndex = getCueMarkerIndexForCueMarkerId(nEditAudPtr, nCueMarkerId)
            nReqdMarkerTime = aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)\nCueMarkerPosition
            ; debugmsg(sProcName, "\nMGCueMarkerIndex = "+ nCueMarkerIndex) 
            \nMGCueMarkerIndex = nCueMarkerIndex
        EndSelect
      EndIf
    EndIf
    ; debugMsg(sProcName, "rWQF\bDisplayingLevelPoint=" + strB(rWQF\bDisplayingLevelPoint) + ", rWQF\nLevelPointTime=" + timeToStringT(rWQF\nLevelPointTime) + ", nGraphMarkerType=" + decodeGraphMarkerType(nGraphMarkerType) + ", \nMarkerTime=" + timeToStringT(\nMarkerTime) + ", nReqdMarkerTime=" + timeToStringT(nReqdMarkerTime))
    If rWQF\bDisplayingLevelPoint
      If rWQF\nCurrLevelPointTime = \nGraphMarkerTime
        rWQF\nCurrLevelPointTime = nReqdMarkerTime
        rWQF\nCurrLevelPointType = nLevelPointType
        ; Debug "(mark) rWQF\nCurrLevelPointType=" + decodeLevelPointType(rWQF\nCurrLevelPointType)
      EndIf
    EndIf
    \nGraphMarkerTime = nReqdMarkerTime
  EndWith
  
EndProcedure

Procedure listGraphMarkers(*rMG.tyMG)
  PROCNAMEC()
  Protected n
  
  For n = 0 To *rMG\nMaxGraphMarker
    With *rMG\aGraphMarker(n)
      debugMsg(sProcName, "*rMG\sMGNumber=" + *rMG\sMGNumber + ", \aGraphMarker(" + n + ")\nGraphMarkerType=" + decodeGraphMarkerType(\nGraphMarkerType) +
                           ", \nLevelPointId=" + \nLevelPointId + ", \nLevelPointIndex=" + \nLevelPointIndex +
                           ", \nCueMarkerId=" + \nCueMarkerId + ", \nMGCueMarkerIndex=" + \nMGCueMarkerIndex +
                          ", \nLoopInfoIndex=" + \nLoopInfoIndex + ", \nLevelOrPan=" + \nLevelOrPan + ", \nGraphMarkerTime=" + \nGraphMarkerTime + ", \nX=" + \nX + ", \nY=" + \nY)
    EndWith
  Next n
  
EndProcedure

Procedure removeGraphMarkerForCueMarker(*rMG.tyMG, nCueMarkerId)
  PROCNAMEC()
  Protected n1, n2
  
  With *rMG
    n2 = -1
    For n1 = 0 To \nMaxGraphMarker
      If (\aGraphMarker(n1)\nGraphMarkerType = #SCS_GRAPH_MARKER_CM) And (\aGraphMarker(n1)\nCueMarkerId = nCueMarkerId)
        ; found an item to remove
        debugMsg(sProcName, "removing graph marker for nCueMarkerId=" + nCueMarkerId)
      Else
        ; else keep this item
        n2 + 1
        If n1 > n2
          \aGraphMarker(n2) = \aGraphMarker(n1)
        EndIf
      EndIf
    Next n1
    \nMaxGraphMarker = n2
  EndWith
  
EndProcedure

Procedure clearGraphMarkers(*rMG.tyMG)
  PROCNAMEC()
  Protected n
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rMG
    For n = 0 To \nMaxGraphMarker
      \aGraphMarker(n)\nGraphMarkerTime = -1
      \aGraphMarker(n)\nCueMarkerId = -1
    Next n
    \nMaxGraphMarker = -1
  EndWith
  
EndProcedure

Procedure addGraphMarkerForLevelPoint(*rMG.tyMG, nLevelPointIndex)
  PROCNAMECA(nEditAudPtr)
  Protected n
  Protected nThisSlice
  
  If *rMG\fMillisecondsPerPixel = 0
    debugMsg(sProcName, "exiting because *rMG\fMillisecondsPerPixel=" + StrF(*rMG\fMillisecondsPerPixel,4))
    ProcedureReturn
  EndIf
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)\aPoint(nLevelPointIndex)
      ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\aPoint(" + nLevelPointIndex + ")\nPointType=" + decodeLevelPointType(\nPointType))
      Select \nPointType
        Case #SCS_PT_START, #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT, #SCS_PT_END
          nThisSlice = \nPointTime / *rMG\fMillisecondsPerPixel
          drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_LP, nThisSlice, nLevelPointIndex)
      EndSelect
    EndWith
  EndIf
  
EndProcedure

Procedure addGraphMarkersForLevelPoints(*rMG.tyMG)
  ; PROCNAMECA(nEditAudPtr)
  Protected nLevelPointIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nEditAudPtr) + ")\nMaxLevelPoint=" + aAud(nEditAudPtr)\nMaxLevelPoint)
    For nLevelPointIndex = 0 To aAud(nEditAudPtr)\nMaxLevelPoint
      addGraphMarkerForLevelPoint(*rMG, nLevelPointIndex)
    Next nLevelPointIndex
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure addGraphMarkersForCueMarkers(*rMG.tyMG)
  ; PROCNAMEC()
  Protected nPass, nCueMarkerIndex, nThisSlice
  
  ;debugMsg(sProcName, #SCS_START) 
  
  If nEditAudPtr >= 0
    ; two passes - add any file cue point (CP) markers first, then any SCS cue markers (CM) so that CM's will be appear in front of any CP's that overlap
    For nPass = 1 To 2
      For nCueMarkerIndex = 0 To aAud(nEditAudPtr)\nMaxCueMarker
        With aAud(nEditAudPtr)\aCueMarker(nCueMarkerIndex)
          nThisSlice = \nCueMarkerPosition / *rMG\fMillisecondsPerPixel
          If (nPass = 1) And (\nCueMarkerType = #SCS_CMT_CP)
            drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CP, nThisSlice, -1, -1, \nCueMarkerId)
          ElseIf (nPass = 2) And (\nCueMarkerType = #SCS_CMT_CM)
            drawSpecialSlice(*rMG, #SCS_SLICE_TYPE_CM, nThisSlice, -1, -1, \nCueMarkerId)
          EndIf
        EndWith
      Next nCueMarkerIndex
    Next nPass
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkMouseOnGraphMarker(*rMG.tyMG, nMouseX, nMouseY, bTrace=#False)
  PROCNAMEC()
  Protected nGraphMarkerIndex, nNearestGraphMarker
  Protected n
  Protected nReqdBVLevelOrPan
  
  debugMsgC(sProcName, #SCS_START + ", nMouseX=" + nMouseX + ", nMouseY=" + nMouseY)
  
  nReqdBVLevelOrPan = -1
  nGraphMarkerIndex = -1
  For n = 0 To *rMG\nMaxGraphMarker
    With *rMG\aGraphMarker(n)
      debugMsgC(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", \aGraphMarker(" + n + ")\nLevelOrPan=" + \nLevelOrPan + ", \nHotAreaX=" + \nHotAreaX + ", \nHotAreaWidth=" + \nHotAreaWidth + ", \nHotAreaY=" + \nHotAreaY + ", \nHotAreaHeight=" + \nHotAreaHeight)
      If (\nLevelOrPan = nReqdBVLevelOrPan) Or (nReqdBVLevelOrPan = -1)
        If (nMouseX >= \nHotAreaX) And (nMouseX < (\nHotAreaX + \nHotAreaWidth))
          If (nMouseY >= \nHotAreaY) And (nMouseY < (\nHotAreaY + \nHotAreaHeight))
            nGraphMarkerIndex = n
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  debugMsgC(sProcName, "nGraphMarkerIndex=" + nGraphMarkerIndex)
  If nGraphMarkerIndex >= 0
    nNearestGraphMarker = findNearestGraphMarker(*rMG, nMouseX, nMouseY)
    debugMsgC(sProcName, "nNearestGraphMarker=" + nNearestGraphMarker)
    If nNearestGraphMarker >= 0
      nGraphMarkerIndex = nNearestGraphMarker
    EndIf
  EndIf
  debugMsgC(sProcName, #SCS_END + ", returning nGraphMarkerIndex=" + nGraphMarkerIndex)
  ProcedureReturn nGraphMarkerIndex
EndProcedure

Procedure findNearestGraphMarker(*rMG.tyMG, nMouseX, nMouseY)
  PROCNAMEC()
  ; the distance calculation derived from the PB Forum Topic "MathOn module PB 5.20" posted by DK_PETER on 31Aug2013 - see procedure Distance()
  Protected n
  Protected fNearestDistance.f, nNearestGraphMarker
  Protected fDistanceX.f, fDistanceY.f, fDistanceDirect.f
  Protected nReqdBVLevelOrPan
  
  ; debugMsg(sProcName, #SCS_START + ", nMouseX=" + nMouseX + ", nMouseY=" + nMouseY)
  
  nReqdBVLevelOrPan = -1
  nNearestGraphMarker = -1
  For n = 0 To *rMG\nMaxGraphMarker
    With *rMG\aGraphMarker(n)
      If (\nLevelOrPan = nReqdBVLevelOrPan) Or (nReqdBVLevelOrPan = -1)
        fDistanceX = nMouseX - \fMidPointX  ; horizontal difference
        fDistanceY = nMouseY - \fMidPointY  ; vertical difference
        fDistanceDirect = Sqr((fDistanceX * fDistanceX) + (fDistanceY * fDistanceY))  ; distance using Pythagoras theorem
        ; debugMsg(sProcName, "grMG2\aGraphMarker(" + n + ")\fMidPointX=" + StrF(\fMidPointX,1) + ", \fMidPointY=" + StrF(\fMidPointY,1) + 
        ; ", fDistanceX=" + StrF(fDistanceX,1) + ", fDistanceY=" + StrF(fDistanceY) + ", fDistanceDirect=" + StrF(fDistanceDirect,3))
        If nNearestGraphMarker = -1
          fNearestDistance = fDistanceDirect
          nNearestGraphMarker = n
        Else
          If fDistanceDirect < fNearestDistance
            fNearestDistance = fDistanceDirect
            nNearestGraphMarker = n
          EndIf
        EndIf
        ; debugMsg(sProcName, "n=" + n + ", fDistanceDirect=" + StrF(fDistanceDirect,3) + ", fNearestDistance=" + StrF(fNearestDistance,3) + ", nNearestGraphMarker=" + Str(nNearestGraphMarker))
      EndIf
    EndWith
  Next n
  ; Debug "nNearestGraphMarker=" + nNearestGraphMarker
  ProcedureReturn nNearestGraphMarker
  
EndProcedure

Procedure setMaxInnerWidthForFile(nFileDataPtr)
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nFileDataPtr=" + nFileDataPtr)
  
  If nFileDataPtr >= 0
    With gaFileData(nFileDataPtr)
      If \nFileDuration > 0
        \nMaxInnerWidth = \nFileDuration
      EndIf
      ; ensure \nMaxInnerWidth at least 2000 pixels so that short files (eg 1 second) are properly displayed
      If \nMaxInnerWidth < 2000
        \nMaxInnerWidth = 2000
      EndIf
      ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\sFileName=" + GetFilePart(\sFileName) + ", \nFileDuration=" + \nFileDuration + ", \nMaxInnerWidth=" + Str(\nMaxInnerWidth))
    EndWith
  EndIf
  
EndProcedure

Procedure createGraphImageIfReqd(*rMG.tyMG)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rMG
    ; debugMsg(sProcName, "*rMG\nMGNumber=" + \nMGNumber + ", \nVisibleWidth=" + \nVisibleWidth + ", \nTimeBarTop=" + \nTimeBarTop)
    If \nVisibleWidth > 20  ; abitrary minimum width, mainly to ensure width passed to CreateImage() will be greater than zero
      If IsImage(\nGraphImage) = #False
        gnNextImageNo + 1
        If CreateImage(gnNextImageNo, \nVisibleWidth, \nTimeBarTop)
          debugMsg(sProcName, "CreateImage(" + gnNextImageNo + ", " + \nVisibleWidth + ", " +\nTimeBarTop + ")")
          \nGraphImage = gnNextImageNo
          newHandle(#SCS_HANDLE_IMAGE, \nGraphImage)
          debugMsg(sProcName, \sMGNumber + "\nGraphImage=" + decodeHandle(\nGraphImage))
        EndIf
      Else
        If (ImageWidth(\nGraphImage) <> \nVisibleWidth) Or (ImageHeight(\nGraphImage) <> \nTimeBarTop)
          FreeImage(\nGraphImage)
          CreateImage(\nGraphImage, \nVisibleWidth, \nTimeBarTop)
          debugMsg(sProcName, "CreateImage(" + decodeHandle(\nGraphImage) + ", " + \nVisibleWidth + ", " +\nTimeBarTop + ")")
        EndIf
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure levelToGraphY(fBVLevel.f, nGraphChannels)
  ; PROCNAMEC()
  Protected nGraphY
  Protected nGraphPartHeight
  Protected fFactorY.f
  
  With grMG2
    If nGraphChannels = 2
      nGraphPartHeight = \nGraphHeight >> 2
    Else
      nGraphPartHeight = \nGraphHeight >> 1
    EndIf
  EndWith
  nGraphY = (fBVLevel * nGraphPartHeight)
  ; Debug "fBVLevel=" + traceLevel(fBVLevel) + ", nGraphY=" + Str(nGraphY)
  ; debugMsg(sProcName, "fBVLevel=" + traceLevel(fBVLevel) + ", nGraphY=" + Str(nGraphY))
  
  ProcedureReturn nGraphY
EndProcedure

Procedure.f graphYToLevel(nGraphY, nGraphChannels)
  ; PROCNAMEC()
  Protected fBVLevel.f
  
  With grMG2
    If nGraphY <= \nGraphBottom
      fBVLevel = 0.0
    Else
      fBVLevel = SLD_SliderValueToBVLevel(#SCS_MAXVOLUME_SLD / (\nGraphBottom - nGraphY) / \nGraphHeight)
      If fBVLevel > grLevels\fMaxBVLevel
        fBVLevel = grLevels\fMaxBVLevel
      ElseIf fBVLevel < 0.0
        fBVLevel = 0.0
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn fBVLevel
EndProcedure

Procedure.f graphYToRelDBLevel(nGraphY)
  ; PROCNAMEC()
  Protected fBVLevel.f
  Protected fDBLevel.f
  Protected fDevDBLevel.f
  Protected nGraphPartHeight
  Protected fFactorY.f
  Protected fItemRelDBLevel.f
  Protected fTmp.f, nSliderVal
  Protected nDevNo.i
  
  With grMG2
    ; Debug sProcName + ": nGraphY=" + nGraphY + ", \nGraphBottom=" + \nGraphBottom + ", \nGraphHeight=" + \nGraphHeight
    If nGraphY >= \nGraphBottom
      fBVLevel = 0.0
      ; Debug "(a) fBVLevel=" + StrF(fBVLevel,2)
    Else
      fTmp = (\nGraphBottom - nGraphY) / \nGraphHeight * #SCS_MAXVOLUME_SLD
      nSliderVal = fTmp
      ; Debug "fTmp=" + StrF(fTmp,4) + ", nSliderVal=" + nSliderVal
      fBVLevel = SLD_SliderValueToBVLevel(nSliderVal)
      ; Debug "(b) fBVLevel=" + StrF(fBVLevel,2)
      If fBVLevel > grLevels\fMaxBVLevel
        fBVLevel = grLevels\fMaxBVLevel
      ElseIf fBVLevel < 0.0
        fBVLevel = 0.0
      EndIf
    EndIf
    fDBLevel = convertBVLevelToDBLevel(fBVLevel)
    ; Debug "fDBLevel=" + StrF(fDBLevel,2)
    
    Select grMG2\nMarkerDragAction
      Case #SCS_GRAPH_MARKER_DRAG_CHANGES_LEVEL
        If rWQF\nCurrDevNo >= 0
          fDevDBLevel = convertBVLevelToDBLevel(aAud(nEditAudPtr)\fBVLevel[rWQF\nCurrDevNo])
          fItemRelDBLevel = fDBLevel - fDevDBLevel
        EndIf
     EndSelect
    
  EndWith
  ; Debug sProcName + ": fItemRelDBLevel=" + convertDBLevelToDBString(fItemRelDBLevel)
  
  ProcedureReturn fItemRelDBLevel
EndProcedure

Procedure.f graphYToPan(nGraphY)
  PROCNAMEC()
  Protected fPan.f
  Protected fItemPan.f
  
  With grMG2
    fItemPan = (nGraphY - \nGraphYMidPoint) / \nGraphHalfHeight
    If fItemPan > 1.0
      fItemPan = 1.0
    ElseIf fItemPan < -1.0
      fItemPan = -1.0
    EndIf
  EndWith
  ; Debug "fItemPan=" + StrF(fItemPan,2)
  
  ProcedureReturn fItemPan
EndProcedure

Procedure drawProgressBar(*rMG.tyMG)
  PROCNAMEC()
  Protected bDrawingStartedByMe
  Protected nProgess1, nProgess2
  Protected nCurValue1, nMaxValue1
  Protected nCurValue2, nMaxValue2
  Static nPrevValue1, nPrevValue2
  Static nPrevProgress1, nPrevProgress2
  Static nHeight, nHalfHeight
  
  With *rMG
    ; debugMsg(sProcName, #SCS_START + "grMG2\bInGetData=" + strB(\bInGetData) + ", \bInLoadSlicePeakAndMin=" + strB(\bInLoadSlicePeakAndMin))
    If \bInGetData Or \bInLoadSlicePeakAndMin
      If \nGetDataLimit <> 0 And \nGraphMaxX <> 0  ; <> 0 tests to avoid division by zero errors
        nMaxValue1 = \nGetDataLimit
        nMaxValue2 = \nGraphMaxX
        If \bInGetData
          nCurValue1 = \nGetDataCount
          nCurValue2 = 0
        ElseIf \bInLoadSlicePeakAndMin
          nCurValue1 = 0
          nCurValue2 = \nSlicePeakAndMinCount
        EndIf
        If (nCurValue1 <> nPrevValue1) Or (nCurValue2 <> nPrevValue2)
          bDrawingStartedByMe = condStartGraphDrawing(*rMG)
          If nHeight = 0
            scsDrawingFont(#SCS_FONT_GEN_NORMAL7)
            nHeight = TextHeight("Gg")
            nHalfHeight = nHeight >> 1
          EndIf
          gnErrorHandlerCode = #SCS_EHC_GRAPH_PROGRESS_BAR
          Box(\nSEBarLeft, \nSEBarTop, \nGraphWidth, nHeight, #SCS_Black)
          gnErrorHandlerCode = #SCS_EHC_NONE
          If nCurValue1 <> nPrevValue1
            nPrevValue1 = nCurValue1
            nProgess1 = \nGraphWidth * nCurValue1 / nMaxValue1
            Box(\nSEBarLeft, \nSEBarTop, nProgess1, nHalfHeight, #SCS_Light_Yellow)
          EndIf
          If nCurValue2 <> nPrevValue2
            nPrevValue2 = nCurValue2
            nProgess2 = \nGraphWidth * nCurValue2 / nMaxValue2
            Box(\nSEBarLeft, \nSEBarTop+nHalfHeight, nProgess2, nHalfHeight, #SCS_Green)
          EndIf
          ; debugMsg(sProcName, "\bInGetData=" + strB(\bInGetData) + ", \bInLoadSlicePeakAndMin=" + strB(\bInLoadSlicePeakAndMin) +
          ;                     ", \nGetDataLimit=" + \nGetDataLimit + ", \nGraphMaxX=" + \nGraphMaxX + ", \nGraphWidth=" + \nGraphWidth +
          ;                     ", nMaxValue1=" + nMaxValue1 + ", nCurValue1=" + nCurValue1 + ", nProgress1=" + nProgess1 +
          ;                     ", nMaxValue2=" + nMaxValue2 + ", nCurValue2=" + nCurValue2 + ", nProgress2=" + nProgess2)
          condStopGraphDrawing(*rMG, bDrawingStartedByMe)
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure loadSamplesArrayFromFile(*rMG.tyMG, nFileDataPtr)
  PROCNAMEC()
  ; WARNING! Although this procedure runs slowly under PB Debugger, it runs much faster without the debugger.
  ; NOTE: This procedure reads audio samples from a file and stores the samples in arrays *rMG\aFileSampleL() and *rMG\aFileSampleR().
  
  ; NOTE: If the file contains just a single mono channel, then the samples are stored in *rMG\aFileSampleL() only. The values in *rMG\aFileSampleR() will be zero but should not be used elsewhere for a mono file.
  ; NOTE: If the file is stereo, then the samples are stored in *rMG\aFileSampleL() and *rMG\aFileSampleR().
  ; NOTE: If the file contains more than 2 channels, then channels 1, 3, 5, etc are summed and stored in *rMG\aFileSampleL(), and channels 2, 4, 6, etc are summed and stored in *rMG\aFileSampleR().
  
  ; NOTE: The required filename is obtained from gaFileData(nFileDataPtr)\sFileName.
  ; The procedure is called for slider audio graphs (@grMG4) by THR_runSliderFileLoaderThread(), and also from SLD_processOneLoadFileRequest().
  
  Protected sFileName.s
  Protected nDecoderChannel.l       ; long
  Protected nBassResult.l           ; long
  Protected nFlags.l                ; long
  Protected qOffset.q, qLength.q    ; quads
  Protected qChannelLengthInBytes.q ; quad - as returned by BASS_ChannelGetLength()
  Protected qChannelLengthInSamples.q
  Protected nBuffLengthInBytes.l    ; long - as required by BASS_ChannelGetData()
  Protected nDataMax
  Protected n
  Protected nStreamCreateError.l
  Protected fPeakValue.f, fMaxByteVal.f
  Protected byValue.b
  Protected qSamplePositionCount.q
  Protected qTotalLengthInBytes.q
  Protected rChannelInfo.BASS_CHANNELINFO
  Protected qReqdArraySize.q
  Protected qSampleIndex.q
  Protected nChanNo
  Protected bScanKilled
  Protected qScanStartTime.q, nScanLoopCount, nRedimCount
  Protected qGetDataStartTime.q, nGetDataTotalTime
  Protected nGetDataLength = 262144
  Protected nReadDataBufferPtr
  Protected nExpectedLoopCount, bShowProgressBar
  Protected bFileTooLargeForGraph
  Protected bResult
  Protected bLockedMutex
  Static *mReadDataBuffer  ; buffer for BASS_ChannelReadData() for loading samples array (access controlled by mutex #SCS_MUTEX_LOAD_SAMPLES)
  
  debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber + ", nFileDataPtr=" + nFileDataPtr)
  
  If nFileDataPtr < 0
    ProcedureReturn bResult
  EndIf
  
  LockLoadSamplesMutex(3500)
  
  If *mReadDataBuffer = 0
    *mReadDataBuffer = AllocateMemory(nGetDataLength)
  EndIf
  
  With gaFileData(nFileDataPtr)
    sFileName = \sFileName
    debugMsg(sProcName, "sFileName=" + GetFilePart(sFileName))
    If FileExists(sFileName, #False) = #False
      debugMsg(sProcName, "File not found")
      UnlockLoadSamplesMutex()
      ProcedureReturn bResult
    EndIf
    \bKillScanRequested = #False
    \nSamplesArrayStatus = #SCS_SAP_IN_PROGRESS
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nSamplesArrayStatus=#SCS_SAP_IN_PROGRESS")
  EndWith
  
  *rMG\sSampleArrayFileName = sFileName
  *rMG\nFileDataPtrForSamplesArray = nFileDataPtr
  
  nFlags = #BASS_STREAM_DECODE | #SCS_BASS_UNICODE | #BASS_STREAM_PRESCAN | #BASS_SAMPLE_FLOAT
  nDecoderChannel = BASS_StreamCreateFile(#BASSFALSE, @sFileName, qOffset, qLength, nFlags)
  newHandle(#SCS_HANDLE_SOURCE, nDecoderChannel)
  debugMsg2(sProcName, "BASS_StreamCreateFile(BASSFALSE, " + GetFilePart(sFileName) + ", 0, 0, " + decodeStreamCreateFlags(nFlags) + ")", nDecoderChannel)
  If nDecoderChannel = 0
    nStreamCreateError = BASS_ErrorGetCode()
    debugMsg3(sProcName, getBassErrorDesc(nStreamCreateError))
    UnlockLoadSamplesMutex()
    ProcedureReturn bResult
  EndIf
  
  nBassResult = BASS_ChannelGetInfo(nDecoderChannel, @rChannelInfo)
  debugMsg2(sProcName, "BASS_ChannelGetInfo(" + decodeHandle(nDecoderChannel) + ", @rChannelInfo)", nBassResult)
  debugMsg(sProcName, "rChannelInfo\chans=" + rChannelInfo\chans + ", \freq=" + rChannelInfo\freq + ", \flags=$" + Hex(rChannelInfo\flags, #PB_Long))
  
  qChannelLengthInBytes = BASS_ChannelGetLength(nDecoderChannel, #BASS_POS_BYTE)
  debugMsg3(sProcName, "BASS_ChannelGetLength(" + decodeHandle(nDecoderChannel) + ", BASS_POS_BYTE) returned " + qChannelLengthInBytes)
  If qChannelLengthInBytes >= 0
    qChannelLengthInSamples = (qChannelLengthInBytes >> 2) / rChannelInfo\chans ; "qChannelLengthInBytes >> 2" divides the number of bytes by 4 as there are 4 bytes per (float) sample
    debugMsg(sProcName, "qChannelLengthInSamples=" + qChannelLengthInSamples)
    qReqdArraySize = qChannelLengthInSamples * 1.2 ; add 20% to reduce likelihood of arrays needing to be extended
    With *rMG
      ; debugMsg(sProcName, "qReqdArraySize=" + qReqdArraySize + ", ArraySize(" + \sMGNumber + "\aFileSampleL()=" + ArraySize(\aFileSampleL()) + ", ArraySize(\aFileSampleR()=" + ArraySize(\aFileSampleR()))
      If qReqdArraySize > ArraySize(\aFileSampleL())
        ReDim \aFileSampleL(qReqdArraySize)
        ReDim \aFileSampleR(qReqdArraySize)
        debugMsg(sProcName, "ArraySize(" + \sMGNumber + "\aFileSampleL())=" + ArraySize(\aFileSampleL()) + ", ArraySize(" + \sMGNumber + "\aFileSampleR())=" + ArraySize(\aFileSampleR()))
        If (ArraySize(\aFileSampleL()) < 0) Or (ArraySize(\aFileSampleR()) < 0)
          ; a ReDim failed - probably because the combined size is too large
          ; issue found when using a 300MB MP3 file from Jens Peter Schalow, 19May2016, where qReqdArraySize = 714210796
          ; \aFileSampleL(qReqdArraySize) was created OK, but \aFileSampleR(qReqdArraySize) failed, and ArraySize(\aFileSampleR()) returned -1
          FreeArray(\aFileSampleL())  ; need to 'FreeArray' and the 'Dim' it to reinstate, because just issuing 'ReDim' throws a memory error on an array of size -1
          FreeArray(\aFileSampleR())
          Dim \aFileSampleL(0)
          Dim \aFileSampleR(0)
          bFileTooLargeForGraph = #True
        EndIf
      EndIf
      ; debugMsg(sProcName, "ArraySize(" + \sMGNumber + "\aFileSampleL()=" + ArraySize(\aFileSampleL()) + ", ArraySize(" + \sMGNumber + "\aFileSampleR()=" + ArraySize(\aFileSampleR()))
      \sFileName = sFileName
      \nGetDataCount = 0
      \nGetDataLimit = qChannelLengthInBytes / nGetDataLength
      ; debugMsg(sProcName, \sMGNumber + "\nGetDataLimit=" + \nGetDataLimit)
      \bInGetData = #True
    EndWith
    
    ; determine if the progress bar is to be drawn - only applies to grMG2 (used in the editor)
    If gnThreadNo <= #SCS_THREAD_MAIN
      If *rMG\nMGNumber = 2 Or *rMG\nMGNumber = 5
        If bFileTooLargeForGraph = #False
          nExpectedLoopCount = qChannelLengthInBytes / nGetDataLength
          If nExpectedLoopCount > 20
            bShowProgressBar = #True
          EndIf
          debugMsg(sProcName, "nExpectedLoopCount=" + nExpectedLoopCount + ", bShowProgressBar=" + strB(bShowProgressBar))
        EndIf
      EndIf
    EndIf
    
    DisableDebugger
    
    qSampleIndex = 0
    nChanNo = 0
    qScanStartTime = ElapsedMilliseconds()
    If bFileTooLargeForGraph
      debugMsg(sProcName, "setting bScanKilled=#True because bFileTooLargeForGraph")
      bScanKilled = #True
    Else
      While #True
        If gnThreadNo = #SCS_THREAD_SLIDER_FILE_LOADER
          If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
            debugMsg(sProcName, "kill scan because 'Stop ASAP' requested")
            bScanKilled = #True
            qSampleIndex = 0
            Break
          EndIf
        EndIf
        qGetDataStartTime = ElapsedMilliseconds()
        nBuffLengthInBytes = BASS_ChannelGetData(nDecoderChannel, *mReadDataBuffer, nGetDataLength)
        ; NOTE: BASS_ChannelGetData() just reads a part of the file each call
        If nBuffLengthInBytes > 0
          nGetDataTotalTime + (ElapsedMilliseconds() - qGetDataStartTime)
        EndIf
        ; debugMsg2(sProcName, "BASS_ChannelGetData(" + decodeHandle(nDecoderChannel) + ", *mReadDataBuffer, " + nGetDataLength + ")", nBuffLengthInBytes)
        ; nb the above call to BASS_ChannelGetData() returns 32-bit float samples (-1.0 to +1.0)
        If nBuffLengthInBytes = -1
          If BASS_ErrorGetCode() = #BASS_ERROR_ENDED
            debugMsg(sProcName, "end of file")
            Break
          Else
            debugMsg(sProcName, "error")
            Break
          EndIf
          
        ElseIf gaFileData(nFileDataPtr)\bKillScanRequested
          debugMsg(sProcName, "kill scan requested")
          bScanKilled = #True
          qSampleIndex = 0
          Break
          
        Else
          *rMG\nGetDataCount + 1
          nScanLoopCount + 1
          ; NOTE: nBuffLengthInBytes = length of data read by the latest call (above) to BASS_ChannelGetData()
          ; buffer contains float samples so divide by 4 for number of bytes that will be required
          nDataMax = (nBuffLengthInBytes >> 2) - 1
          nReadDataBufferPtr = 0
          fMaxByteVal = 128.0
          ; debugMsg(sProcName, "nBuffLengthInBytes=" + nBuffLengthInBytes + ", nDataMax=" + nDataMax)
          For n = 0 To nDataMax
            fPeakValue = PeekF(*mReadDataBuffer + nReadDataBufferPtr)
            byValue = Round(fPeakValue * fMaxByteVal, #PB_Round_Nearest) ; store in a byte field (byte field has values -128 to +127)
            ; debugMsg(sProcName, "nChanNo=" + nChanNo + ", n=" + n + ", fPeakValue=" + StrF(fPeakValue,4) + ", byValue=" + byValue)
            CheckSubInRange(qSampleIndex, ArraySize(*rMG\aFileSampleR()), *rMG\sMGNumber + "\aFileSampleR(), nChanNo=" + nChanNo + ", rChannelInfo\chans=" + rChannelInfo\chans)
            Select nChanNo
              Case 0
                *rMG\aFileSampleL(qSampleIndex) = byValue
              Case 1
                *rMG\aFileSampleR(qSampleIndex) = byValue
              Default
                If (nChanNo & 1) = 0
                  *rMG\aFileSampleL(qSampleIndex) + byValue
                Else
                  *rMG\aFileSampleR(qSampleIndex) + byValue
                EndIf
            EndSelect
            nChanNo + 1
            If nChanNo >= rChannelInfo\chans
              ; debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", *rMG\aFileSampleL(" + qSampleIndex + ")=" + *rMG\aFileSampleL(qSampleIndex) + ", *rMG\aFileSampleR(" + qSampleIndex + ")=" + *rMG\aFileSampleR(qSampleIndex))
              nChanNo = 0
              qSampleIndex + 1
              If qSampleIndex > ArraySize(*rMG\aFileSampleL())
                doReDim(*rMG\aFileSampleL, (qSampleIndex + 1000), *rMG\sMGNumber + "\aFileSampleL()")
                doReDim(*rMG\aFileSampleR, (qSampleIndex + 1000), *rMG\sMGNumber + "\aFileSampleR()")
                nRedimCount + 1
              EndIf
            EndIf
            nReadDataBufferPtr + 4  ; + 4 because we're pulling out a float (4 bytes) each pass
          Next n
          If bShowProgressBar
            drawProgressBar(*rMG) ; nb draws editor graph's progress bar based on info in grMG2 so must only be called for grMG2 (which is checked when setting bShowProgressBar)
          EndIf
          qTotalLengthInBytes + nBuffLengthInBytes
        EndIf
      Wend
    EndIf
    *rMG\qMaxSamplePtr = qSampleIndex 
    debugMsg(sProcName, "ScanLoopTime=" + Str(ElapsedMilliseconds() - qScanStartTime) + ", ScanLoopCount=" + nScanLoopCount + ", RedimCount=" + nRedimCount + ", GetDataTotalTime=" + nGetDataTotalTime + ", *rMG\qMaxSamplePtr=" + *rMG\qMaxSamplePtr)
    
    EnableDebugger
    
;     Select rChannelInfo\chans
;       Case 1
;         qSamplePositionCount = (qTotalLengthInBytes >> 2)
;       Case 2
;         qSamplePositionCount = (qTotalLengthInBytes >> 3)
;       Default
;         qSamplePositionCount = (qTotalLengthInBytes / (rChannelInfo\chans * 4))
;     EndSelect
    qSamplePositionCount= *rMG\qMaxSamplePtr
    
    If bScanKilled = #False
      debugMsg(sProcName, "calling calcNormalizeFactor(*rMG)")
      calcNormalizeFactor(*rMG)
      With gaFileData(nFileDataPtr)
        \fNormalizeFactor = *rMG\fNormalizeFactor
        \nxFileChannels = rChannelInfo\chans
        \nSampleRate = rChannelInfo\freq
        \qSamplePositionCount = qSamplePositionCount
        debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\fNormalizeFactor=" + StrF(gaFileData(nFileDataPtr)\fNormalizeFactor,4) +
                            ", \nxFileChannels=" + \nxFileChannels +
                            ", \nSampleRate=" + \nSampleRate +
                            ", \qSamplePositionCount=" + \qSamplePositionCount +
                            ", \nFileDuration=" + \nFileDuration)
      EndWith
    EndIf ; EndIf bScanKilled = #False
    
  EndIf ; EndIf qChannelLengthInBytes >= 0
  
  With gaFileData(nFileDataPtr)
    If bScanKilled
      \nSamplesArrayStatus = #SCS_SAP_NONE
    Else
      \nSamplesArrayStatus = #SCS_SAP_DONE
      bResult = #True
    EndIf
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nSamplesArrayStatus=" + decodeSamplesArrayStatus(\nSamplesArrayStatus))
  EndWith
  
  nBassResult = BASS_StreamFree(nDecoderChannel)
  debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(nDecoderChannel) + ")", nBassResult)
  
  *rMG\bInGetData = #False
  
  With *rMG
    debugMsg(sProcName, "ArraySize(" + \sMGNumber + "\aFileSampleL())=" + ArraySize(\aFileSampleL()) + ", ArraySize(\aFileSampleR())=" + ArraySize(\aFileSampleR()) +
                        ", \nMGFileChannels=" + \nMGFileChannels +
                        ", \nFileDataPtrForGraph=" + \nFileDataPtrForGraph + ", \nFileDataPtrForSamplesArray=" + \nFileDataPtrForSamplesArray +
                        ", \nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays + ", \qMaxSamplePtr=" + \qMaxSamplePtr)
  EndWith
  
  UnlockLoadSamplesMutex()
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure clearSlicePeakAndMinArrays(*rMG.tyMG)
  PROCNAMEC()
  Protected n
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rMG
    For n = 0 To ArraySize(\aSlicePeakL())
      \aSlicePeakL(n) = 0
      \aSlicePeakR(n) = 0
      \aSliceMinL(n) = 0
      \aSliceMinR(n) = 0
    Next n
    \nFileDataPtrForSlicePeakAndMinArrays = -1
    ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
  EndWith
  
EndProcedure

Procedure loadSlicePeakAndMinArraysFromSamplesArray(*rMG.tyMG, nFileDataPtr, pReqdInnerWidth=-1, pAudPtr=-1, bSaveToTempDatabase=#True)
  PROCNAMEC()
  ; *rMG\nGraphChannels must be set for the selected device
  ; pReqdInnerWidth MUST be set for 'audio graph' progress sliders, and is the required display width of the graph.
  ; pAudPtr only required for 'audio graph' progress slider as the progress slider is to show only the playable part of the file.
  Protected byPeakL.b, byPeakR.b
  Protected byMinL.b, byMinR.b
  Protected n, m
  Protected nReqdInnerWidth, nReqdArraySize
  Protected qSamplePtr.q, qSamplesArraySize.q
  Protected bySampleL.b, bySampleR.b
  Protected nTmpValue
  Protected sMsg.s
  Protected nProgressBarIncrement, nPrevValue
  Protected nAbsMin, nAbsMax
  Protected qSamplePositions.q, qFirstSampleOffSet.q
  Protected qHoldSamplePtr.q
  Protected bScanKilled
  Protected nReqdSamplePositionsPerPixel
  
  debugMsg(sProcName, #SCS_START + ", *rMG\nMGNumber=" + *rMG\nMGNumber + ", nFileDataPtr=" + nFileDataPtr + ", pReqdInnerWidth=" + pReqdInnerWidth + ", bSaveToTempDatabase=" + strB(bSaveToTempDatabase))
  
  If nFileDataPtr < 0
    debugMsg(sProcName, "exiting because nFileDataPtr=" + nFileDataPtr)
    ProcedureReturn #False
  EndIf
  
  If pAudPtr >= 0
    If (*rMG\nMGNumber = 3) Or (*rMG\nMGNumber = 4)
      nAbsMin = aAud(pAudPtr)\nAbsMin
      nAbsMax = aAud(pAudPtr)\nAbsMax
    EndIf
  EndIf
  
  With *rMG
    ; debugMsg(sProcName, "ArraySize(\aFileSampleL()=" + ArraySize(\aFileSampleL()) + ", ArraySize(\aFileSampleR()=" + ArraySize(\aFileSampleR()))
    ; debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSamplesArray=" + \nFileDataPtrForSamplesArray + ", nFileDataPtr=" + nFileDataPtr)
    If pAudPtr >= 0
      If \sSampleArrayFileName <> aAud(pAudPtr)\sFileName
        debugMsg(sProcName, "(calling loadSamplesArrayFromFile(*rMG, " + nFileDataPtr + ")")
        loadSamplesArrayFromFile(*rMG, nFileDataPtr)
      EndIf
    EndIf
    
    If gaFileData(nFileDataPtr)\nSamplesArrayStatus <> #SCS_SAP_DONE
      debugMsg(sProcName, "exiting because gaFileData(" + nFileDataPtr + ")\nSamplesArrayStatus=" + decodeSamplesArrayStatus(gaFileData(nFileDataPtr)\nSamplesArrayStatus))
      ProcedureReturn #False
    EndIf
    
    nReqdInnerWidth = pReqdInnerWidth
    If nReqdInnerWidth = -1
      If \nMGNumber = 2 Or \nMGNumber = 5
        nReqdInnerWidth = \nInnerWidth
      Else ; nMGNumber = 3 or 4
        debugMsg(sProcName, "exiting because pReqdInnerWidth has not been set for an 'audio graph' progress slider")
        ProcedureReturn #False
      EndIf
    EndIf
    ; debugMsg(sProcName, "nReqdInnerWidth=" + nReqdInnerWidth)
    
    ; added 13Nov2018 11.8.0au following test by Dee Ireland
    If nReqdInnerWidth <= 0
      debugMsg(sProcName, "ProcedureReturn #False because nReqdInnerWidth=" + nReqdInnerWidth)
      ProcedureReturn #False
    EndIf
    ; end added 13Nov2018 11.8.0au
    
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\sFileName=" + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
    If FileExists(gaFileData(nFileDataPtr)\sFileName, #False) = #False
      debugMsg(sProcName, "exiting because file not found: " + gaFileData(nFileDataPtr)\sFileName)
      ProcedureReturn #False
    EndIf
    
    \nMGFileChannels = gaFileData(nFileDataPtr)\nxFileChannels
    ; debugMsg(sProcName, "*rMG\nMGNumber=" + *rMG\nMGNumber + ", *rMG\nMGFileChannels=" + *rMG\nMGFileChannels + ", nFileDataPtr=" + nFileDataPtr)
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\sFileName=" + gaFileData(nFileDataPtr)\sFileName)
    \nMaxInnerWidth = gaFileData(nFileDataPtr)\nMaxInnerWidth
    \nFileDuration = gaFileData(nFileDataPtr)\nFileDuration
    \fNormalizeFactor = gaFileData(nFileDataPtr)\fNormalizeFactor
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nFileDuration=" + gaFileData(nFileDataPtr)\nFileDuration + ", nReqdInnerWidth=" + nReqdInnerWidth + ", \fNormalizeFactor=" + StrF(\fNormalizeFactor, 4))
    qFirstSampleOffSet = 0
    If \nMGNumber = 3 Or \nMGNumber = 4
      \nAudPtr = pAudPtr
      \nAbsMin = nAbsMin
      \nAbsMax = nAbsMax
      If nAbsMin > 0
        qFirstSampleOffSet = nAbsMin * gaFileData(nFileDataPtr)\nSampleRate / 1000
        ; debugMsg(sProcName, "nAbsMin=" + nAbsMin + ", gaFileData(" + nFileDataPtr + ")\nSampleRate=" + gaFileData(nFileDataPtr)\nSampleRate + ", qFirstSampleOffSet=" + qFirstSampleOffSet)
      EndIf
    EndIf
    
    nReqdArraySize = nReqdInnerWidth - 1
    doReDim(\aSlicePeakL, nReqdArraySize, \sMGNumber + "\aSlicePeakL()")
    doReDim(\aSlicePeakR, nReqdArraySize, \sMGNumber + "\aSlicePeakR()")
    doReDim(\aSliceMinL, nReqdArraySize, \sMGNumber + "\aSliceMinL()")
    doReDim(\aSliceMinR, nReqdArraySize, \sMGNumber + "\aSliceMinR()")
    
    For n = 0 To nReqdArraySize
      \aSlicePeakL(n) = 0
      \aSlicePeakR(n) = 0
      \aSliceMinL(n) = 0
      \aSliceMinR(n) = 0
    Next n
    
    \nGraphMaxX = nReqdInnerWidth - 1
    ; debugMsg(sProcName, "\nGraphMaxX=" + \nGraphMaxX)
    qSamplesArraySize = gaFileData(nFileDataPtr)\qSamplePositionCount - 1
    
    If \nMGNumber = 2 Or \nMGNumber = 5
      \fMillisecondsPerPixel = \nFileDuration / nReqdInnerWidth
      ; debugMsg(sProcName, "\nFileDuration=" + \nFileDuration + ", nReqdInnerWidth=" + nReqdInnerWidth + ", >>\fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,4))
      qSamplePositions = gaFileData(nFileDataPtr)\qSamplePositionCount
    Else ; \nMGNumber = 3 or 4
      \fMillisecondsPerPixel = (\nAbsMax - \nAbsMin + 1) / nReqdInnerWidth
      ; debugMsg(sProcName, "\nAbsMax=" + \nAbsMax + ", \nAbsMin=" + \nAbsMin + ", nReqdInnerWidth=" + nReqdInnerWidth + ", >>\fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,4))
      qSamplePositions = (nAbsMax - nAbsMin + 1) * gaFileData(nFileDataPtr)\nSampleRate / 1000
    EndIf
    \dSamplePositionsPerPixel = qSamplePositions / nReqdInnerWidth
    If \dSamplePositionsPerPixel < 1.0
      \dSamplePositionsPerPixel = 1.0
    EndIf
    \nSamplePositionsPerPixel = \dSamplePositionsPerPixel ; create integer version for subsequent 'For' loops (only)
    ; debugMsg(sProcName, "\nMaxInnerWidth=" + \nMaxInnerWidth + ", nReqdInnerWidth=" + nReqdInnerWidth + ", \nGraphMaxX=" + \nGraphMaxX +
    ;                     ", qSamplePositions=" + qSamplePositions + ", \dSamplePositionsPerPixel=" + StrD(\dSamplePositionsPerPixel,4) +
    ;                     ", \nSamplePositionsPerPixel=" + \nSamplePositionsPerPixel)
    
    \nSlicePeakAndMinCount = 0
    \bInLoadSlicePeakAndMin = #True
    ; debugMsg(sProcName, "\bInLoadSlicePeakAndMin=" + strB(\bInLoadSlicePeakAndMin) + ", \nSlicePeakAndMinCount=" + \nSlicePeakAndMinCount + ", \nGraphChannels=" + \nGraphChannels)
    
    DisableDebugger
    
    nProgressBarIncrement = \nGraphMaxX / 100
    If \nGraphChannels = 1
      For n = 0 To \nGraphMaxX
        If gnThreadNo = #SCS_THREAD_SLIDER_FILE_LOADER
          If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
            debugMsg(sProcName, "kill scan because 'Stop ASAP' requested")
            bScanKilled = #True
            Break
          EndIf
        EndIf
        \nSlicePeakAndMinCount + 1
        byPeakL = 0
        byMinL = 0
        ; recalc qSamplePtr each time to keep to avoid getting out of sync due to rounding
        ; qSamplePtr = ((n * \qMaxSamplePtr) / \nGraphMaxX) + qFirstSampleOffSet
        qSamplePtr = (n * qSamplePositions / \nGraphMaxX) + qFirstSampleOffSet
        qHoldSamplePtr = qSamplePtr
        For m = 1 To \nSamplePositionsPerPixel
          If qSamplePtr <= qSamplesArraySize
            If \nMGFileChannels = 1
              bySampleL = \aFileSampleL(qSamplePtr)
              ; Peak L
              If bySampleL > byPeakL
                byPeakL = bySampleL
              EndIf
              ; Min L
              If bySampleL < byMinL
                byMinL = bySampleL
              EndIf
            Else
              nTmpValue = (\aFileSampleL(qSamplePtr) + \aFileSampleR(qSamplePtr)) / 2
              bySampleL = nTmpValue
              ; Peak L
              If bySampleL > byPeakL
                byPeakL = bySampleL
              EndIf
              ; Min L
              If bySampleL < byMinL
                byMinL = bySampleL
              EndIf
            EndIf
            qSamplePtr + 1
          EndIf
        Next m
        \aSlicePeakL(n) = byPeakL
        \aSliceMinL(n) = byMinL
        ; debugMsg(sProcName, "(1b) MG" + \nMGNumber + "\aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", byPeakL=" + byPeakL + ", qHoldSamplePtr=" + qHoldSamplePtr +
        ;                     ", pos=" + Str(qHoldSamplePtr * 1000 / gaFileData(nFileDataPtr)\nSampleRate))
      Next n
      
    Else ; If \nGraphChannels <> 1
      ; Comment added 30Jul2024 11.10.3av
      ; In SCS, audio/video files that have more than 2 channels will have their audio graphs displayed as just two channels.
      ; The 'left' channel will be the sum of channels 1, 3, 5, etc, and the 'right' channel will be the sum of channels 2, 4, 6, etc.
      ; So the number of 'graph channels' for these files should be set to 2.
      ; End comment added 30Jul2024 11.10.3av
      ; debugMsg(sProcName, "ArraySize(\aFileSampleL()=" + ArraySize(\aFileSampleL()) + ", ArraySize(\aFileSampleR()=" + ArraySize(\aFileSampleR()) +
      ;                     ", \nGraphChannels=" + \nGraphChannels + ", \nMGFileChannels=" + \nMGFileChannels + ", \nSamplePositionsPerPixel=" + \nSamplePositionsPerPixel)
      
      For n = 0 To \nGraphMaxX
        If gnThreadNo = #SCS_THREAD_SLIDER_FILE_LOADER
          If gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP
            logMsg(sProcName, "kill scan because 'Stop ASAP' requested")
            bScanKilled = #True
            Break
          EndIf
        EndIf
        \nSlicePeakAndMinCount + 1
        byPeakL = 0
        byMinL = 0
        byPeakR = 0
        byMinR = 0
        ; recalc qSamplePtr each time to keep to avoid getting out of sync due to rounding
        ; qSamplePtr = ((n * \qMaxSamplePtr) / \nGraphMaxX) + qFirstSampleOffSet
        ; added 9Jun2017 11.6.2 following division by zero detected in run of Sebastian Franke
        If \nGraphMaxX = 0
          logMsg(sProcName, "kill scan because \nGraphMaxX=0")
          bScanKilled = #True
          Break
        EndIf
        ; end added 9Jun2017 11.6.2
        qSamplePtr = (n * qSamplePositions / \nGraphMaxX) + qFirstSampleOffSet
        For m = 1 To \nSamplePositionsPerPixel
          If qSamplePtr <= qSamplesArraySize
            bySampleL = \aFileSampleL(qSamplePtr)
            ; Peak L
            If bySampleL > byPeakL
              byPeakL = bySampleL
            EndIf
            ; Min L
            If bySampleL < byMinL
              byMinL = bySampleL
            EndIf
            If \nMGFileChannels = 1
              byPeakR = byPeakL
              byMinR = byMinL
            Else
              bySampleR = \aFileSampleR(qSamplePtr)
              ; Peak R
              If bySampleR > byPeakR
                byPeakR = bySampleR
              EndIf
              ; Min R
              If bySampleR < byMinR
                byMinR = bySampleR
              EndIf
            EndIf
            ; debugMsg(sProcName, "(2) qSamplePtr=" + qSamplePtr + ", bySampleL=" + bySampleL + ", bySampleR=" + bySampleR)
            qSamplePtr + 1
          EndIf
        Next m
        \aSlicePeakL(n) = byPeakL
        \aSliceMinL(n) = byMinL
        \aSlicePeakR(n) = byPeakR
        \aSliceMinR(n) = byMinR
        ; debugMsg(sProcName, "(2b) MG" + \nMGNumber + "\aSlicePeakL(" + n + ")=" + \aSlicePeakL(n) + ", \aSlicePeakR(" + n + ")=" + \aSlicePeakR(n) + ", byPeakL=" + byPeakL + ", byPeakR=" + byPeakR)
        ; debugMsg(sProcName, "(2) \aSliceMinL(" + n + ")=" + \aSliceMinL(n) + ", \aSliceMinR(" + n + ")=" + \aSliceMinR(n) + ", byMinL=" + byMinL + ", byMinR=" + byMinR)
        ;       debugMsg(sProcName, "(2) n=" + n + ", byPeakL=" + byPeakL + ", byMinL="+ byMinL + ", byPeakR=" + byPeakR + ", byMinR=" + byMinR)
        If gnThreadNo <= #SCS_THREAD_MAIN
          If n >= (nPrevValue + nProgressBarIncrement)
            drawProgressBar(*rMG)
            nPrevValue = n
          EndIf
        EndIf
        
      Next n
    EndIf
    
    EnableDebugger
    
    \bInLoadSlicePeakAndMin = #False
    ; debugMsg(sProcName, "bInLoadSlicePeakAndMin=" + strB(\bInLoadSlicePeakAndMin) + ", \nSlicePeakAndMinCount=" + \nSlicePeakAndMinCount)
    
    If bScanKilled = #False
      \nFileDataPtrForSlicePeakAndMinArrays = nFileDataPtr
      ; Commented out the following line 2Dec2023 because this was preventing the zoom control from working in WQF, due to a test in loadSlicePeakAndMinArraysFromSamplesArray()
      ;  \nFileDataPtrForSamplesArray = nFileDataPtr ; Added 25Sep2023 11.10.0
      debugMsg(sProcName, \sMGNumber + "\nFileDataPtrForSlicePeakAndMinArrays=" + \nFileDataPtrForSlicePeakAndMinArrays)
      If bSaveToTempDatabase
        Select \nMGNumber
          Case 2, 5
            ; grMG2 is used by fmEditQF and associated routines
            ; grMG5 is used by fmEditQA and associated routines
            debugMsg(sProcName, "calling saveMG25SlicePeakAndMinArraysToTempDatabase(*rMG, " + nFileDataPtr + ")")
            saveMG25SlicePeakAndMinArraysToTempDatabase(*rMG, nFileDataPtr)
          Case 3
            ; grMG3 is used For creating an image for an 'audio graph' progress slider
            debugMsg(sProcName, "calling saveMG34SlicePeakAndMinArraysToTempDatabase(*rMG)")
            saveMG34SlicePeakAndMinArraysToTempDatabase(*rMG)
          Case 4
            ; grMG4 is used by the slider graph loader thread
            If gnThreadNo = #SCS_THREAD_SLIDER_FILE_LOADER
              ; pass the request back to the main thread because we had mutex/deadlock problems trying to access the database from both the main thread and the slider file loader thread
              \bCallSaveSlicePeakAndMinArraysToTempDatabase = #True
              debugMsg(sProcName, "grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase=" + strB(grMG4\bCallSaveSlicePeakAndMinArraysToTempDatabase))
            Else
              ; nb shouldn't get here if the #SCS_THREAD_SLIDER_FILE_LOADER thread is in use
              debugMsg(sProcName, "calling saveMG34SlicePeakAndMinArraysToTempDatabase(*rMG)")
              saveMG34SlicePeakAndMinArraysToTempDatabase(*rMG)
            EndIf
        EndSelect
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure saveMG25SlicePeakAndMinArraysToTempDatabase(*rMG.tyMG, nFileDataPtr)
  PROCNAMEC()
  ; '*rMG' is used for editor graphs in audio file cues, and is used in fmEditQF and associated routines
  ; 'grMG5' is used for editor graphs in video file cues, and is used in fmEditQA and associated routines
  Protected bTraceDetails = #True
  Protected nSlicePeakAndMinBufPtr
  Protected n
  Static *mSlicePeakAndMinData
  Protected nSlicePeakAndMinDataMemSize
  Protected nSlicePeakAndMinDataPtr
  Protected byPeakL.b, byMinL.b, byPeakR.b, byMinR.b
  Protected sSQLRequest.s
  
  debugMsg(sProcName, #SCS_START + ", nFileDataPtr=" + nFileDataPtr)
  
  If nFileDataPtr < 0
    ProcedureReturn
  EndIf
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  With gaFileData(nFileDataPtr)
    
    debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\sFileName=" + GetFilePart(\sFileName))
    
    ; check if the required row already exists
    sSQLRequest = "SELECT FileBlob, NormalizeFactorInt FROM FileData "
    sSQLRequest + " WHERE FileName = '" + RepQuote(\sFileName) + "'"
    sSQLRequest + " AND FileModified = '" + RepQuote(\sFileModified) + "'"
    sSQLRequest + " AND FileSize = " + Str(\qFileSize)
    sSQLRequest + " AND ViewStart = " + Str(*rMG\nViewStart)
    sSQLRequest + " AND ViewEnd = " + Str(*rMG\nViewEnd)
    sSQLRequest + " AND GraphWidth = " + Str(*rMG\nGraphWidth)
    sSQLRequest + " AND GraphChannels = " + Str(*rMG\nGraphChannels)
    sSQLRequest + " AND MaxPeak = " + Str(#SCS_GRAPH_MAX_PEAK)
    sSQLRequest + " LIMIT 1"
    debugMsg(sProcName, "(T) sSQLRequest=" + sSQLRequest)
    If DatabaseQuery(grTempDB\nTempDatabaseNo, sSQLRequest)
      ; debugMsg(sProcName, "DatabaseQuery(grTempDB\nTempDatabaseNo, sSQLRequest) returned #True")
      If NextDatabaseRow(grTempDB\nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
        ; debugMsg(sProcName, "exiting because row already exists for " + GetFilePart(\sFileName))
        ProcedureReturn
      Else
        debugMsg(sProcName, "NextDatabaseRow(grTempDB\nTempDatabaseNo) returned #False")
      EndIf
    Else
      debugMsg(sProcName, "DatabaseQuery(grTempDB\nTempDatabaseNo, sSQLRequest) returned #False")
    EndIf
    ; debugMsg(sProcName, "row not found, so ok to save new row")
;     debugMsg(sProcName, "calling listDatabaseFileData(grTempDB\nTempDatabaseNo)")
;     listDatabaseFileData(grTempDB\nTempDatabaseNo)
    
    If *rMG\nGraphChannels = 2
      nSlicePeakAndMinDataMemSize = *rMG\nGraphWidth << 2  ; * 4 for PeakL, MinL, PeakR and MinR
    Else
      nSlicePeakAndMinDataMemSize = *rMG\nGraphWidth << 1  ; * 2 for PeakL and MinL
    EndIf
    debugMsg(sProcName, "*rMG\nGraphWidth=" + *rMG\nGraphWidth + ", *rMG\nGraphChannels=" + *rMG\nGraphChannels + ", nSlicePeakAndMinDataMemSize=" + nSlicePeakAndMinDataMemSize)
    If *mSlicePeakAndMinData
      If MemorySize(*mSlicePeakAndMinData) < nSlicePeakAndMinDataMemSize
        FreeMemory(*mSlicePeakAndMinData)
        *mSlicePeakAndMinData = AllocateMemory(nSlicePeakAndMinDataMemSize, #PB_Memory_NoClear)
      EndIf
    Else
      *mSlicePeakAndMinData = AllocateMemory(nSlicePeakAndMinDataMemSize, #PB_Memory_NoClear)
    EndIf
    If *mSlicePeakAndMinData
      ; set nSlicePeakAndMinDataMemSize to the actual memory size as this variable is used in checking if the memory allocation needs to be increased
      nSlicePeakAndMinDataMemSize = MemorySize(*mSlicePeakAndMinData)
    EndIf
;     If *mSlicePeakAndMinData
;       debugMsg(sProcName, "*mSlicePeakAndMinData=" + *mSlicePeakAndMinData + ", MemorySize()=" + MemorySize(*mSlicePeakAndMinData))
;     Else
;       debugMsg(sProcName, "*mSlicePeakAndMinData=" + *mSlicePeakAndMinData)
;     EndIf
    nSlicePeakAndMinDataPtr = 0
    
    DisableDebugger
    
    For n = 0 To (*rMG\nGraphWidth - 1)
      byPeakL = *rMG\aSlicePeakL(n)
      byMinL = *rMG\aSliceMinL(n)
      PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr, byPeakL)
      PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr+1, byMinL)
      nSlicePeakAndMinDataPtr + 2
      If *rMG\nGraphChannels = 2
        byPeakR = *rMG\aSlicePeakR(n)
        byMinR = *rMG\aSliceMinR(n)
        PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr, byPeakR)
        PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr+1, byMinR)
        nSlicePeakAndMinDataPtr + 2
      EndIf
    Next n
    
    EnableDebugger
    
    ; debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\fNormalizeFactor=" + StrF(\fNormalizeFactor,4))
    *rMG\fNormalizeFactor = \fNormalizeFactor
    
    ; store peak and min memory info in the temp database
;     debugMsg(sProcName, "calling saveGraphDataToTempDatabase(" + nFileDataPtr + ", *mSlicePeakAndMinData, " + nSlicePeakAndMinDataPtr +
;                         ", " + StrF(*rMG\fNormalizeFactor,4) + ", " + *rMG\nGraphWidth + ", " + *rMG\nGraphChannels + ", " + *rMG\nViewStart + ", " + *rMG\nViewEnd + ")")
    saveGraphDataToTempDatabase(nFileDataPtr, *mSlicePeakAndMinData, nSlicePeakAndMinDataPtr, *rMG\fNormalizeFactor, *rMG\nGraphWidth, *rMG\nGraphChannels,
                                *rMG\nViewStart, *rMG\nViewEnd)
    
;     debugMsg(sProcName, "calling listDatabaseFileData(grTempDB\nTempDatabaseNo)")
;     listDatabaseFileData(grTempDB\nTempDatabaseNo)
    
    If gnUnsavedEditorGraphs = 0
      gnUnsavedEditorGraphs = 1
      gsUnsavedEditorGraphs = #DQUOTE$ + GetFilePart(\sFileName) + #DQUOTE$
    ElseIf FindString(gsUnsavedEditorGraphs, #DQUOTE$ + GetFilePart(\sFileName) + #DQUOTE$) = 0
      gnUnsavedEditorGraphs + 1
      If gnUnsavedEditorGraphs < 21
        gsUnsavedEditorGraphs + Chr(10) + #DQUOTE$ + GetFilePart(\sFileName) + #DQUOTE$
      ElseIf gnUnsavedEditorGraphs = 21
        gsUnsavedEditorGraphs + Chr(10) + "..."
      EndIf
    EndIf
    ; debugMsg(sProcName, "gnUnsavedEditorGraphs=" + gnUnsavedEditorGraphs)
    setFileSave()
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure saveMG34SlicePeakAndMinArraysToTempDatabase(*rMG.tyMG)
  PROCNAMEC()
  ; 'grMG3' is used for creating an image for an 'audio graph' progress slider
  ; 'grMG4' is used by the slider graph loader thread
  Protected n
  Static *mSlicePeakAndMinData
  Protected nSlicePeakAndMinDataMemSize
  Protected nSlicePeakAndMinDataPtr
  Protected byPeakL.b, byMinL.b, byPeakR.b, byMinR.b
  Protected sSQLRequest.s
  Protected nAudPtr
  Protected sFileName.s
  Protected qFileSize.q, sFileModified.s
  
  debugMsg(sProcName, #SCS_START + ", *rMG\sMGNumber=" + *rMG\sMGNumber)
  
  If gbClosingDown
    ProcedureReturn
  EndIf
  
  nAudPtr = *rMG\nAudPtr
  debugMsg(sProcName, "nAudPtr=" + getAudLabel(nAudPtr))
  If nAudPtr >= 0
    With aAud(nAudPtr)
      sFileName = \sFileName
      If (sFileName) And (\bAudPlaceHolder = #False)
        
        ; debugMsg(sProcName, "ArraySize(*rMG\aSlicePeakL())=" + ArraySize(*rMG\aSlicePeakL()) + ", *rMG\nGraphWidth=" + *rMG\nGraphWidth)
        If ArraySize(*rMG\aSlicePeakL()) < (*rMG\nGraphWidth - 1)
          debugMsg(sProcName, "!!!!!! exiting because ArraySize(*rMG\aSlicePeakL()) < (*rMG\nGraphWidth - 1)")
          ProcedureReturn
        EndIf
        
        ; check if the required row already exists
        qFileSize = FileSize(sFileName)
        sFileModified = FormatDate(#SCS_CUE_FILE_DATE_FORMAT, GetFileDate(sFileName, #PB_Date_Modified))
        sSQLRequest = "SELECT SldrBlob, NormalizeFactorInt FROM ProgSldrs" +
                      " WHERE FileName = '" + RepQuote(sFileName) + "'" +
                      " AND FileModified = '" + RepQuote(sFileModified) + "'" +
                      " AND FileSize = " + qFileSize +
                      " AND GraphWidth = " + *rMG\nGraphWidth +
                      " AND GraphChannels = " + *rMG\nGraphChannels +
                      " AND AbsMin = " + \nAbsMin +
                      " AND AbsMax = " + \nAbsMax +
                      " AND MaxPeak = " + #SCS_GRAPH_MAX_PEAK +
                      " LIMIT 1"
        debugMsg(sProcName, "(T) sSQLRequest=" + sSQLRequest)
        If DatabaseQuery(grTempDB\nTempDatabaseNo, sSQLRequest)
          If NextDatabaseRow(grTempDB\nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
            debugMsg(sProcName, "exiting because row already exists for " + GetFilePart(\sFileName))
            ProcedureReturn
          EndIf
        EndIf
        
        If *rMG\nGraphChannels = 2
          nSlicePeakAndMinDataMemSize = *rMG\nGraphWidth << 2  ; * 4 for PeakL, MinL, PeakR and MinR
        Else
          nSlicePeakAndMinDataMemSize = *rMG\nGraphWidth << 1  ; * 2 for PeakL and MinL
        EndIf
        debugMsg(sProcName, "*rMG\nGraphWidth=" + *rMG\nGraphWidth + ", *rMG\nGraphChannels=" + *rMG\nGraphChannels + ", nSlicePeakAndMinDataMemSize=" + nSlicePeakAndMinDataMemSize)
        If *mSlicePeakAndMinData
          If MemorySize(*mSlicePeakAndMinData) < nSlicePeakAndMinDataMemSize
            FreeMemory(*mSlicePeakAndMinData)
            *mSlicePeakAndMinData = AllocateMemory(nSlicePeakAndMinDataMemSize, #PB_Memory_NoClear)
          EndIf
        Else
          *mSlicePeakAndMinData = AllocateMemory(nSlicePeakAndMinDataMemSize, #PB_Memory_NoClear)
        EndIf
        nSlicePeakAndMinDataPtr = 0
        
        DisableDebugger
        
        For n = 0 To (*rMG\nGraphWidth - 1)
          byPeakL = *rMG\aSlicePeakL(n)
          byMinL = *rMG\aSliceMinL(n)
          PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr, byPeakL)
          PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr+1, byMinL)
          nSlicePeakAndMinDataPtr + 2
          If *rMG\nGraphChannels = 2
            byPeakR = *rMG\aSlicePeakR(n)
            byMinR = *rMG\aSliceMinR(n)
            PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr, byPeakR)
            PokeB(*mSlicePeakAndMinData+nSlicePeakAndMinDataPtr+1, byMinR)
            nSlicePeakAndMinDataPtr + 2
          EndIf
        Next n
        
        EnableDebugger
        
        ; store peak and min memory info in the temp database
        debugMsg(sProcName, "calling saveProgSldrGraphToTempDatabase(*rMG, " + nSlicePeakAndMinDataPtr + ", " + StrF(*rMG\fNormalizeFactor,3) + ", " + *rMG\nGraphWidth + ")")
        saveProgSldrGraphToTempDatabase(*rMG, *mSlicePeakAndMinData, nSlicePeakAndMinDataPtr, *rMG\fNormalizeFactor, *rMG\nGraphWidth)
        
        ; debugMsg(sProcName, "calling listDatabaseProgSldrsData(grTempDB\nTempDatabaseNo)")
        ; listDatabaseProgSldrsData(grTempDB\nTempDatabaseNo)
        
        gnUnsavedSliderGraphs + 1
        debugMsg(sProcName, "gnUnsavedSliderGraphs=" + gnUnsavedSliderGraphs)
        ; setFileSave() ; do NOT set file save if the only changes are for unsaved slider graphs
        
      EndIf
    EndWith
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure cancelLoadRequestsExcept(pCaller, nFileDataPtr)
  PROCNAMEC()
  Protected f
  
  debugMsg(sProcName, #SCS_START + ", pCaller=" + pCaller + ", nFileDataPtr=" + nFileDataPtr)
  
  For f = gnLastFileData To 1 Step -1
    If f <> nFileDataPtr
      With gaFileData(f)
        If (\bLoadRequest2) And (pCaller = 2)
          \bLoadRequest2 = #False
          \bDrawGraphAfterLoad = #False
          If \nSamplesArrayStatus = #SCS_SAP_IN_PROGRESS
            \bKillScanRequested = #True
            debugMsg(sProcName, "gaFileData(" + f + ")\bKillScanRequested=" + strB(\bKillScanRequested) + ", \sFileName=" + GetFilePart(\sFileName))
          EndIf
        EndIf
        If (\bLoadRequest3) And (pCaller = 3)
          \bLoadRequest3 = #False
          \bDrawSliderAfterLoad = #False
          If \nSamplesArrayStatus = #SCS_SAP_IN_PROGRESS
            \bKillScanRequested = #True
            debugMsg(sProcName, "gaFileData(" + f + ")\bKillScanRequested=" + strB(\bKillScanRequested) + ", \sFileName=" + GetFilePart(\sFileName))
          EndIf
        EndIf
      EndWith
    EndIf
  Next f
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure cancelAllLoadRequests()
  PROCNAMEC()
  Protected nSldPtr, nFileDataPtr
  
  debugMsg(sProcName, #SCS_START)
  
  For nSldPtr = 0 To ArraySize(gaSlider())
    With gaSlider(nSldPtr)
      If \bLoadFileRequest
        \bLoadFileRequest = #False
        debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bLoadFileRequest=" + strB(\bLoadFileRequest) + ", \sName=" + \sName)
        nFileDataPtr = \nSldFileDataPtr
      Else
        nFileDataPtr = -1
      EndIf
    EndWith
    If nFileDataPtr >= 0
      With gaFileData(nFileDataPtr)
        debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\nSamplesArrayStatus=" + decodeSamplesArrayStatus(\nSamplesArrayStatus) + ", \sFileName=" + GetFilePart(\sFileName))
        If \nSamplesArrayStatus = #SCS_SAP_IN_PROGRESS Or 1=1
          \bKillScanRequested = #True
          debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\bKillScanRequested=" + strB(\bKillScanRequested) + ", \sFileName=" + GetFilePart(\sFileName))
        EndIf
      EndIf
    EndWith
  Next nSldPtr
  
  For nFileDataPtr = gnLastFileData To 1 Step -1
    With gaFileData(nFileDataPtr)
      If \bLoadRequest2 Or \bLoadRequest3
        If \bLoadRequest2
          \bLoadRequest2 = #False
          debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\bLoadRequest2=" + strB(\bLoadRequest2) + ", \sFileName=" + GetFilePart(\sFileName))
        EndIf
        If \bLoadRequest3
          \bLoadRequest3 = #False
          debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\bLoadRequest3=" + strB(\bLoadRequest3) + ", \sFileName=" + GetFilePart(\sFileName))
        EndIf
        \bDrawGraphAfterLoad = #False
        \bDrawSliderAfterLoad = #False
        If \nSamplesArrayStatus = #SCS_SAP_IN_PROGRESS
          \bKillScanRequested = #True
          debugMsg(sProcName, "gaFileData(" + nFileDataPtr + ")\bKillScanRequested=" + strB(\bKillScanRequested) + ", \sFileName=" + GetFilePart(\sFileName))
        EndIf
      EndIf
    EndWith
  Next nFileDataPtr
  
  gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP = #True
  THR_waitForAThreadToStop(#SCS_THREAD_SLIDER_FILE_LOADER, 10000)
  gaThread(#SCS_THREAD_SLIDER_FILE_LOADER)\bStopASAP = #False ; Added 14Jun2021 11.8.5ai
  
  If THR_getThreadState(#SCS_THREAD_SLIDER_FILE_LOADER) = #SCS_THREAD_STATE_STOPPED
    For nSldPtr = 0 To ArraySize(gaSlider())
      With gaSlider(nSldPtr)
        If \bReloadThisSld
          \bReloadThisSld = #False
          debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bReloadThisSld=" + strB(\bReloadThisSld) + ", \sName=" + \sName)
        EndIf
        If \bRedrawSldAfterLoad
          \bRedrawSldAfterLoad = #False
          debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bRedrawSldAfterLoad=" + strB(\bRedrawSldAfterLoad) + ", \sName=" + \sName)
        EndIf
      EndWith
    Next nSldPtr
    gnReloadSldCount = 0
    gnRedrawSldCount = 0
    For nFileDataPtr = gnLastFileData To 1 Step -1
      With gaFileData(nFileDataPtr)
        \bDrawGraphAfterLoad = #False
        \bDrawSliderAfterLoad = #False
      EndWith
    Next nFileDataPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure calcViewStartAndEnd(*rMG.tyMG, pAudPtr)
  PROCNAMEC()
  Protected nNewZoomValue, nNewPositionValue
  Protected nPositionSliderMin, nPositionSliderMax, nPositionSliderRange
  Protected nFileDuration
  Protected qNewViewStart.q
  Protected fMillisecondsPerPixelMaxInnerWidth.f
  Protected fMillisecondsPerPixelViewRange.f
  Protected fViewProportion.f
  Protected nLastTimeMark
  Protected fLastTimeMarkDisplayPoint.f
  Static nZoomTrackBarMin, nZoomTrackBarMax, nZoomTrackBarRange
  Static bStaticLoaded
  
  With *rMG
    If \nMGNumber = 2
      If bStaticLoaded = #False
        ; load static variables
        nZoomTrackBarMin = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Minimum)
        nZoomTrackBarMax = GetGadgetAttribute(WQF\trbZoom, #PB_TrackBar_Maximum)
        nZoomTrackBarRange = nZoomTrackBarMax - nZoomTrackBarMin + 1
        bStaticLoaded = #True
      EndIf
      nNewZoomValue = GGS(WQF\trbZoom)
      ; do not process maximum zoom (nNewZoomValue = nZoomTrackBarMax) because the remaining code would treat that as infinite zoom
      If nNewZoomValue >= nZoomTrackBarMax
        ; if 'maximum zoom' then drop back 1 zoom value below maximum
        nNewZoomValue = nZoomTrackBarMax - 1
      EndIf
      fViewProportion = ((nNewZoomValue / nZoomTrackBarRange) - 1.0) * -1.0
      ; debugMsg(sProcName, "nNewZoomValue=" + nNewZoomValue + ", nZoomTrackBarRange=" + nZoomTrackBarRange + ", fViewProportion=" + StrF(fViewProportion,2))
      nNewPositionValue = SLD_getValue(WQF\sldPosition)
      nPositionSliderMin = SLD_getMin(WQF\sldPosition)
      nPositionSliderMax = SLD_getMax(WQF\sldPosition)
      nPositionSliderRange = nPositionSliderMax - nPositionSliderMin + 1
      
      nLastTimeMark = \nLastTimeMark
      If (nLastTimeMark >= 0) And (nLastTimeMark <= \nFileDuration)
        If (nLastTimeMark >= \nViewStart) And (nLastTimeMark <= \nViewEnd)
          fLastTimeMarkDisplayPoint = (nLastTimeMark - \nViewStart) / \nViewRange
          ; debugMsg(sProcName, "nLastTimeMark=" + nLastTimeMark + ", \nViewEnd=" + \nViewEnd + ", \nViewStart=" + \nViewStart +
          ;                     ", fLastTimeMarkDisplayPoint=" + StrF(fLastTimeMarkDisplayPoint,2))
        EndIf
      EndIf
      
    EndIf
    
    If pAudPtr >= 0
      nFileDuration = aAud(pAudPtr)\nFileDuration
      If nFileDuration > 0
        If aAud(pAudPtr)\bAudTypeA
          \nViewStart = aAud(pAudPtr)\nAbsStartAt
          \nViewEnd = aAud(pAudPtr)\nAbsEndAt
          \nViewRange = \nViewEnd - \nViewStart + 1
          debugMsg(sProcName, "\nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange)
        ElseIf nNewZoomValue <= nZoomTrackBarMin
          \nViewStart = 0
          \nViewEnd = \nFileDuration - 1
          \nViewRange = \nViewEnd - \nViewStart + 1
          ; debugMsg(sProcName, "nFileDuration=" + nFileDuration + ", nNewZoomValue=" + nNewZoomValue + ", \nViewRange=" + \nViewRange)
        Else
          fMillisecondsPerPixelMaxInnerWidth = \nMaxInnerWidth / \nVisibleWidth
          ; debugMsg(sProcName, "\nMaxInnerWidth=" + \nMaxInnerWidth + ", \nVisibleWidth=" + \nVisibleWidth + ", fMillisecondsPerPixelMaxInnerWidth=" + StrF(fMillisecondsPerPixelMaxInnerWidth,4))
          fMillisecondsPerPixelViewRange = fMillisecondsPerPixelMaxInnerWidth * fViewProportion
          ; debugMsg(sProcName, "fViewProportion=" + StrF(fViewProportion,2) + ", fMillisecondsPerPixelMaxInnerWidth=" + StrF(fMillisecondsPerPixelMaxInnerWidth,4) + ", fMillisecondsPerPixelViewRange=" + StrF(fMillisecondsPerPixelViewRange,4))
          \nViewRange = fMillisecondsPerPixelViewRange * \nVisibleWidth
          ; debugMsg(sProcName, "fMillisecondsPerPixelViewRange=" + StrF(fMillisecondsPerPixelViewRange,4) + ", \nVisibleWidth=" + \nVisibleWidth + ", \nViewRange=" + \nViewRange)
          ; debugMsg(sProcName, "nFileDuration=" + nFileDuration + ", fViewProportion=" + StrF(fViewProportion,2) + ", \nViewRange=" + \nViewRange)
          
          qNewViewStart = (nNewPositionValue - nPositionSliderMin) * (\nFileDuration - grMG2\nViewRange) / nPositionSliderRange
          ; debugMsg(sProcName, "nNewPositionValue=" + nNewPositionValue +
          ;                     ", nPositionSliderMin=" + nPositionSliderMin +
          ;                     ", \nFileDuration=" + \nFileDuration +
          ;                     ", grMG2\nViewRange=" + grMG2\nViewRange +
          ;                     ", nPositionSliderRange=" + nPositionSliderRange +
          ;                     ", qNewViewStart=" + qNewViewStart)
          
          \nViewStart = qNewViewStart
          If fLastTimeMarkDisplayPoint > 0.00
            \nViewStart = nLastTimeMark - (\nViewRange * fLastTimeMarkDisplayPoint)
          EndIf
          If \nViewStart < 0
            \nViewStart = 0
          EndIf
          \nViewEnd = \nViewStart + \nViewRange - 1
          ; debugMsg(sProcName, "nLastTimeMark=" + nLastTimeMark + ", \nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange)
        EndIf
      EndIf
      If \nViewStart < 0
        \nViewStart = 0
        \nViewEnd = \nViewStart + \nViewRange - 1
      EndIf
      If \nViewEnd >= nFileDuration
        \nViewEnd = nFileDuration - 1
      EndIf
      \nViewRange = \nViewEnd - \nViewStart + 1
      ; debugMsg(sProcName, "nNewZoomValue=" + nNewZoomValue + ", nNewPositionValue=" + nNewPositionValue +
      ;                     ", \nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", >>\nViewRange=" + \nViewRange)
      \fMillisecondsPerPixel = \nViewRange / \nVisibleWidth
      ; debugMsg(sProcName, "\nViewRange=" + \nViewRange + ", \nVisibleWidth=" + \nVisibleWidth + ", >>\fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,2))
    EndIf
  EndWith
  
EndProcedure

Procedure setViewStartAndEndFromVisibleGraph()
  PROCNAMEC()
  
  With grMG2
    ;     debugMsg(sProcName, "\nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange)
    ;     debugMsg(sProcName, "\nFirstIndex=" + \nFirstIndex + ", \nLastIndex=" + \nLastIndex +
    ;                         ", \nFileDuration=" + \nFileDuration + ", \fMillisecondsPerPixel=" + StrF(\fMillisecondsPerPixel,4))
    ;     debugMsg(sProcName, "\nGraphLeft=" + \nGraphLeft + ", \nGraphRight=" + \nGraphRight + ", \nGraphWidth=" + \nGraphWidth)
    
    \nViewStart = \nFirstIndex * \fMillisecondsPerPixel
    \nViewEnd = (\nLastIndex + 1) * \fMillisecondsPerPixel
    \nViewRange = \nViewEnd - \nViewStart + 1
    
    ;     debugMsg(sProcName, "\nViewStart=" + \nViewStart + ", \nViewEnd=" + \nViewEnd + ", \nViewRange=" + \nViewRange)
    
  EndWith
EndProcedure

Procedure loadSlicePeakAndMinArraysAndDrawGraph(*rMG.tyMG)
  ; PROCNAMEC()
  Protected nFileDataPtr, bLoadResult, nReqdInnerWidth
  Protected sSubType.s
  
  ;debugMsg(sProcName, #SCS_START)
  
  If nEditAudPtr >= 0
    With aAud(nEditAudPtr)
      nFileDataPtr = \nFileDataPtr
      If nFileDataPtr >= 0
        nReqdInnerWidth = -1
        If \bAudTypeA And IsGadget(WQA\cvsGraphQA)
          nReqdInnerWidth = GadgetWidth(WQA\cvsGraphQA)
        EndIf
        sSubType = aSub(nEditSubPtr)\sSubType
        If \nFileDuration <= getFileScanMaxLengthMS(sSubType) Or getFileScanMaxLength(sSubType) < 0
          ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(*rMG, " + nFileDataPtr + ", " + nReqdInnerWidth + ", " + getAudLabel(nEditAudPtr) + ") for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
          bLoadResult = loadSlicePeakAndMinArraysFromDatabase(*rMG, nFileDataPtr, nReqdInnerWidth, nEditAudPtr)
          If bLoadResult = #False
            If gaFileData(nFileDataPtr)\nSamplesArrayStatus = #SCS_SAP_DONE
              ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(*rMG, " + nFileDataPtr + ", " + nReqdInnerWidth + ", " + getAudLabel(nEditAudPtr) + ", #False) for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
              loadSlicePeakAndMinArraysFromSamplesArray(*rMG, nFileDataPtr, nReqdInnerWidth, nEditAudPtr, #False)
            EndIf
          EndIf
        EndIf
        ; debugMsg(sProcName, "calling drawWholeGraphArea()")
        drawWholeGraphArea()
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure calcNormalizeFactor(*rMG.tyMG)
  PROCNAMEC()
  Protected byHighestPeak.b
  Protected byLowestMin.b
  Protected qSampleIndex.q
  Protected byValue.b
  Protected fNormalizeFactor.f
  Protected qStartTime.q
  
  debugMsg(sProcName, #SCS_START)
  
  qStartTime = ElapsedMilliseconds()
  
  With *rMG
    If \nFileDataPtrForSamplesArray >= 0
      debugMsg(sProcName, "gaFileData(" + \nFileDataPtrForSamplesArray + ")\fNormalizeFactor=" + StrF(gaFileData(\nFileDataPtrForSamplesArray)\fNormalizeFactor,4))
      \fNormalizeFactor = gaFileData(\nFileDataPtrForSamplesArray)\fNormalizeFactor
    EndIf
    debugMsg(sProcName, "*rMG\fNormalizeFactor=" + StrF(\fNormalizeFactor,4) + ", \qMaxSamplePtr=" + \qMaxSamplePtr + ", ArraySize(\aFileSampleL()=" + ArraySize(\aFileSampleL()))
    If \fNormalizeFactor = 0
      While qSampleIndex <= \qMaxSamplePtr
        byValue = \aFileSampleL(qSampleIndex)
        If byValue > byHighestPeak
          byHighestPeak = byValue
        EndIf
        If byValue < byLowestMin
          byLowestMin = byValue
        EndIf
        If \nMGFileChannels > 1
          byValue = \aFileSampleR(qSampleIndex)
          If byValue > byHighestPeak
            byHighestPeak = byValue
          EndIf
          If byValue < byLowestMin
            byLowestMin = byValue
          EndIf
        EndIf
        qSampleIndex + 1
      Wend
      debugMsg(sProcName, "byHighestPeak=" + byHighestPeak + ", byLowestMin=" + byLowestMin + ", qSampleIndex=" + qSampleIndex)
      fNormalizeFactor = 1
      If byHighestPeak >= (byLowestMin * -1)
        If byHighestPeak <> 0
          fNormalizeFactor = #SCS_GRAPH_MAX_PEAK / byHighestPeak
        EndIf
      Else
        If byLowestMin <> 0
          fNormalizeFactor = #SCS_GRAPH_MAX_PEAK / (byLowestMin * -1)
        EndIf
      EndIf
      \fNormalizeFactor = fNormalizeFactor
      debugMsg(sProcName, "*rMG\fNormalizeFactor=" + StrF(\fNormalizeFactor,4))
    EndIf
    If \nFileDataPtrForSamplesArray >= 0
      gaFileData(\nFileDataPtrForSamplesArray)\fNormalizeFactor = \fNormalizeFactor
      debugMsg(sProcName, "gaFileData(" + \nFileDataPtrForSamplesArray + ")\fNormalizeFactor=" + StrF(gaFileData(\nFileDataPtrForSamplesArray)\fNormalizeFactor,4))
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", time in procedure: " + Str(ElapsedMilliseconds() - qStartTime))
  
EndProcedure

; EOF