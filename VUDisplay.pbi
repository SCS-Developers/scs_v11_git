; File: VUDisplay.pbi

EnableExplicit

Procedure initVU()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)
  
  gnVUBank = 0
  gnVUMaxMeters = 32
  
  With grMVUD
    \nSpecWidth = (GadgetWidth(WMN\cvsVUDisplay) >> 2) << 2
    \nSpecHeight = GadgetHeight(WMN\cvsVUDisplay)
    ; debugMsg(sProcName, "\nSpecWidth=" + \nSpecWidth + ", \nSpecHeight=" + \nSpecHeight)
    
    If StartDrawing(CanvasOutput(WMN\cvsVUDisplay))
      Box(0, 0, OutputWidth(), OutputHeight(), #SCS_Black)  ; make sure entire canvas is black, avoiding possible white vertical line on the right
      \nMaxBarWidth = TextWidth("WWWW")
      \sMeterGapWithinBar = "  "
      \nMeterGapWithinBar = TextWidth(\sMeterGapWithinBar)
      \nMTCWidth = TextWidth("MTC 88:88:88:88 ")
      StopDrawing()
    EndIf
    
    ReDim specbuf.b(\nSpecWidth * (\nSpecHeight + 1)) ; establish buffer
    
  EndWith
  
  WMN_setPeakMenuItemStates()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetMaxBarWidth(bTrace=#False)
  PROCNAMEC()
  Protected nDevMapPtr, nDevPtr
  Protected sLabel.s, nLabelWidth
  
  If StartDrawing(CanvasOutput(WMN\cvsVULabels))
    grMVUD\nMaxBarWidth = TextWidth("WWWW")
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevPtr = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
      While nDevPtr >= 0
        With grMaps\aDev(nDevPtr)
          If (\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (\sLogicalDev) And (\nReassignDevMapDevPtr = -1)
            sLabel = Trim(\sLogicalDev)
            If sLabel
              nLabelWidth = TextWidth(sLabel)
              debugMsgC(sProcName, "sLabel=" + #DQUOTE$ + sLabel + #DQUOTE$ + ", nLabelWidth=" + nLabelWidth)
              If nLabelWidth > grMVUD\nMaxBarWidth
                grMVUD\nMaxBarWidth = nLabelWidth
                debugMsgC(sProcName, "grMVUD\nMaxBarWidth=" + grMVUD\nMaxBarWidth)
              EndIf
            EndIf
          EndIf
        EndWith
        nDevPtr = grMaps\aDev(nDevPtr)\nNextDevIndex
      Wend
    EndIf
    StopDrawing()
  EndIf
  
EndProcedure

Procedure.s compactVULabel(sVULabel.s, nMaxWidth, bTrace=#False)
  PROCNAMEC()
  Protected sTmp.s, nLen, nChars
  
  sTmp = sVULabel
  nLen = TextWidth(sTmp)
  debugMsgC(sProcName, "TextWidth(" + #DQUOTE$ + sTmp + #DQUOTE$ + ") returned " + nLen)
  If nLen > nMaxWidth
    nChars = Len(sVULabel)
    While (nLen > nMaxWidth) And (nChars > 4)
      nChars - 1
      sTmp = Left(sVULabel, nChars) + "..."
      nLen = TextWidth(sTmp)
    Wend
  EndIf
  debugMsgC(sProcName, "sVULabel=" + #DQUOTE$ + sVULabel + #DQUOTE$ + ", nMaxWidth=" + nMaxWidth + ", returning " + #DQUOTE$ + sTmp + #DQUOTE$)
  ProcedureReturn sTmp
EndProcedure

Procedure resetPeaks(bResetAll)
  ; PROCNAMEC()
  Protected nMeterIndex
  
  If (gnVisMode = #SCS_VU_LEVELS) Or (bResetAll)
    For nMeterIndex = 0 To ArraySize(grMVUD\aMeter())
      grMVUD\aMeter(nMeterIndex)\nPeakValue = 0
    Next nMeterIndex
  EndIf
  
EndProcedure

Procedure buildDevChannelList(bEditingDevChgs=#False)
  PROCNAMEC()
  Protected j, k, n, d, m
  Protected sMyLogicalDev.s, nMyChannel.l, nMyAltChannel.l, nDevNo
  Protected bFound, nChannelIndex
  Protected nDevMapPtr, nDevMapDevPtr
  Protected rDevMap.tyDevMap
  Protected Dim aDevMapDev.tyDevMapDev(0)
  Protected nArraySize
  Protected nMyDSPInd

  debugMsg(sProcName, #SCS_START + ", grMVUD\bInBuildDevChannelList=" + strB(grMVUD\bInBuildDevChannelList) + ", bEditingDevChgs=" + strB(bEditingDevChgs))
  
  If grMVUD\bInBuildDevChannelList
    ProcedureReturn
  EndIf
  
  If bEditingDevChgs
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
  Else
    nDevMapPtr = grProd\nSelectedDevMapPtr
  EndIf
  debugMsg(sProcName, "nDevMapPtr=" + nDevMapPtr)
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  If bEditingDevChgs
    rDevMap = grMapsForDevChgs\aMap(nDevMapPtr)
    nArraySize = ArraySize(grMapsForDevChgs\aDev())
    ReDim aDevMapDev(nArraySize)
    For n = 0 To nArraySize
      aDevMapDev(n) = grMapsForDevChgs\aDev(n)
    Next n
    
  Else
    rDevMap = grMaps\aMap(nDevMapPtr)
    nArraySize = ArraySize(grMaps\aDev())
    ReDim aDevMapDev(nArraySize)
    For n = 0 To nArraySize
      aDevMapDev(n) = grMaps\aDev(n)
    Next n
    
  EndIf
  
  grMVUD\bInBuildDevChannelList = #True

  If gbUseBASS  ; BASS
    
    For n = 0 To nArraySize
      aDevMapDev(n)\nDevChannelCount = 0
    Next n
    
    For j = 1 To gnLastSub
      If (aSub(j)\bExists) And (aSub(j)\bSubTypeHasAuds)
        ; debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(aSub(j)\nSubState))
        If aSub(j)\nSubState >= #SCS_CUE_FADING_IN And aSub(j)\nSubState <= #SCS_CUE_FADING_OUT
          If aSub(j)\nSubState <> #SCS_CUE_HIBERNATING
            
            If aSub(j)\bSubTypeF  ; bSubTypeF
              k = aSub(j)\nFirstAudIndex
              If k >= 0
                If aAud(k)\nAudState >= #SCS_CUE_FADING_IN And aAud(k)\nAudState <= #SCS_CUE_FADING_OUT
                  For d = aAud(k)\nFirstSoundingDev To aAud(k)\nLastSoundingDev
                    sMyLogicalDev = aAud(k)\sLogicalDev[d]
                    nMyChannel = aAud(k)\nBassChannel[d]
                    nMyAltChannel = aAud(k)\nBassAltChannel[d]
                    nMyDSPInd = aAud(k)\nDSPInd[d]
                    bFound = #False
                    If sMyLogicalDev
                      If bEditingDevChgs
                        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev)
                      Else
                        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev)
                      EndIf
                    Else
                      nDevMapDevPtr = -1
                    EndIf
                    If nDevMapDevPtr >= 0
                      bFound = #True
                    EndIf
                    If bFound
                      nChannelIndex = aDevMapDev(nDevMapDevPtr)\nDevChannelCount
                      If nChannelIndex <= #SCS_MAX_DEV_CHANNEL
                        If nMyChannel <> 0
                          aDevMapDev(nDevMapDevPtr)\nDevChannel[nChannelIndex] = nMyChannel
                          debugMsg(sProcName,"(a) k=" + getAudLabel(k) + ", d=" + d + ", aDevMapDev(" + nDevMapDevPtr + ")\nDevChannel[" + nChannelIndex + "]=" + decodeHandle(aDevMapDev(nDevMapDevPtr)\nDevChannel[nChannelIndex]))
                          aDevMapDev(nDevMapDevPtr)\nDSPInd[nChannelIndex] = nMyDSPInd
                          nChannelIndex + 1
                        EndIf
                        If nMyAltChannel <> 0
                          aDevMapDev(nDevMapDevPtr)\nDevChannel[nChannelIndex] = nMyAltChannel
                          debugMsg(sProcName,"(b) k=" + getAudLabel(k) + ", d=" + d + ", aDevMapDev(" + nDevMapDevPtr + ")\nDevChannel[" + nChannelIndex + "]=" + decodeHandle(aDevMapDev(nDevMapDevPtr)\nDevChannel[nChannelIndex]))
                          aDevMapDev(nDevMapDevPtr)\nDSPInd[nChannelIndex] = nMyDSPInd
                          nChannelIndex + 1
                        EndIf
                      EndIf
                      aDevMapDev(nDevMapDevPtr)\nDevChannelCount = nChannelIndex
                    EndIf
                  Next d
                EndIf
              EndIf
              
            ElseIf aSub(j)\bSubTypeP  ; bSubTypeP
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nCurrPlayIndex=" + getAudLabel(aSub(j)\nCurrPlayIndex))
              k = aSub(j)\nCurrPlayIndex
              While k >= 0
                If aAud(k)\nAudState >= #SCS_CUE_FADING_IN And aAud(k)\nAudState <= #SCS_CUE_FADING_OUT
                  For d = 0 To grLicInfo\nMaxAudDevPerSub
                    sMyLogicalDev = aSub(j)\sPLLogicalDev[d]
                    nMyChannel = aAud(k)\nBassChannel[d]
                    nMyDSPInd = aAud(k)\nDSPInd[d]
                    bFound = #False
                    If sMyLogicalDev
                      If bEditingDevChgs
                        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev)
                      Else
                        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sMyLogicalDev)
                      EndIf
                    Else
                      nDevMapDevPtr = -1
                    EndIf
                    If nDevMapDevPtr >= 0
                      bFound = #True
                    EndIf
                    If bFound
                      nChannelIndex = aDevMapDev(nDevMapDevPtr)\nDevChannelCount
                      If nMyChannel <> 0
                        If nChannelIndex <= #SCS_MAX_DEV_CHANNEL
                          aDevMapDev(nDevMapDevPtr)\nDevChannel[nChannelIndex] = nMyChannel
                          aDevMapDev(nDevMapDevPtr)\nDSPInd[nChannelIndex] = nMyDSPInd
                          nChannelIndex + 1
                        EndIf
                      EndIf
                      aDevMapDev(nDevMapDevPtr)\nDevChannelCount = nChannelIndex
                    EndIf
                  Next d
                EndIf
                k = aAud(k)\nNextAudIndex
              Wend
            EndIf
          EndIf
        EndIf
      EndIf
    Next j
    
    debugMsg(sProcName, "grTestTone\nTestToneChan=" + decodeHandle(grTestTone\nTestToneChan) + ", grTestTone\nDevMapDevPtr=" + Str(grTestTone\nDevMapDevPtr))
    If (grTestTone\nTestToneChan <> 0) And (grTestTone\nDevMapDevPtr >= 0)
      If (ElapsedMilliseconds() - grTestTone\qTimeTestToneStarted) <= 1100
        CheckSubInRange(grTestTone\nDevMapDevPtr, ArraySize(aDevMapDev()), "aDevMapDev()")
        nChannelIndex = aDevMapDev(grTestTone\nDevMapDevPtr)\nDevChannelCount
        If nChannelIndex <= #SCS_MAX_DEV_CHANNEL
          aDevMapDev(grTestTone\nDevMapDevPtr)\nDevChannel[nChannelIndex] = grTestTone\nTestToneChan
          nChannelIndex + 1
        EndIf
        aDevMapDev(grTestTone\nDevMapDevPtr)\nDevChannelCount = nChannelIndex
      EndIf
    EndIf
    
  Else  ; SM-S
    
  EndIf
  
  If bEditingDevChgs
    grMapsForDevChgs\aMap(nDevMapPtr) = rDevMap
    For n = 0 To nArraySize
      grMapsForDevChgs\aDev(n) = aDevMapDev(n)
    Next n
  Else
    grMaps\aMap(nDevMapPtr) = rDevMap
    For n = 0 To nArraySize
      grMaps\aDev(n) = aDevMapDev(n)
    Next n
  EndIf
  
  grMVUD\bInBuildDevChannelList = #False
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure drawTriangle(nDirection, nBaseX, nBaseY, nColor)
  PROCNAMEC()
  
  ; nDirection = -1 for left, +1 for right
  
  debugMsg(sProcName, "nDirection=" + Str(nDirection) + ", nHeight=" + Str(grMVUD\nTriangleHeight) + ", nWidth=" + Str(grMVUD\nTriangleWidth) + ", nBaseX=" + Str(nBaseX) + ", nBaseY=" + Str(nBaseY))
  Protected hBrush, hRgn, hPen1, hPen2
  Protected rPrevPoint.POINTAPI, nHalfHeight, i
  Protected POINTCOUNT = 3
  
  ; one extra occurrence than points so polyline can close the border
  Protected Dim aPt.POINTAPI(3)
  
  ;Called from within this module to make box areas and/or beveling
  
  ;     /|2
  ;   1/ |
  ;    \ |
  ;     \|0
  
  nHalfHeight = grMVUD\nTriangleHeight >> 1
  ; set pointer points, starting at bottom point, going clockwise
  aPt(0)\X = nBaseX
  aPt(0)\Y = nBaseY
  aPt(1)\X = nBaseX + (grMVUD\nTriangleWidth * nDirection)
  aPt(1)\Y = nBaseY - nHalfHeight
  aPt(2)\X = nBaseX
  aPt(2)\Y = nBaseY - grMVUD\nTriangleHeight
  aPt(3)\X = nBaseX     ; point (to complete polyline)
  aPt(3)\Y = nBaseY
  
  LineXY(aPt(0)\X, aPt(0)\Y, aPt(1)\X, aPt(1)\Y, nColor)
  ; debugMsg(sProcName, "LineXY(" + Str(aPt(0)\X) + ", " + Str(aPt(0)\Y) + ", " + Str(aPt(1)\X) + ", " + Str(aPt(1)\Y) + ", nColor)")
  LineXY(aPt(1)\X, aPt(1)\Y, aPt(2)\X, aPt(2)\Y, nColor)
  ; debugMsg(sProcName, "LineXY(" + Str(aPt(1)\X) + ", " + Str(aPt(1)\Y) + ", " + Str(aPt(2)\X) + ", " + Str(aPt(2)\Y) + ", nColor)")
  LineXY(aPt(2)\X, aPt(2)\Y, aPt(0)\X, aPt(0)\Y, nColor)
  ; debugMsg(sProcName, "LineXY(" + Str(aPt(2)\X) + ", " + Str(aPt(2)\Y) + ", " + Str(aPt(0)\X) + ", " + Str(aPt(0)\Y) + ", nColor)")
  FillArea(aPt(1)\X - nDirection, aPt(1)\Y, nColor, nColor)
  ; debugMsg(sProcName, "FillArea(" + Str(aPt(1)\X - nDirection) + ", " + Str(aPt(1)\Y) + ", nColor, nColor)")
  
EndProcedure

Procedure displayLabelsBASSandTVG(bTrace=#False)
  PROCNAMEC()
  Protected X
  Protected n2, nOutputIndex, nVidAudFirstMeterIndex
  Protected nLabelPosX, nLabelPosY
  Protected bDrawLabels, bDrawOneLabel
  Protected sOneLabel.s, sTmpLabel.s
  Protected nMaxLabelWidth
  Protected bPeakVisible
  Protected nCurrSpecWidth
  Protected Dim nDevOutputs(0)
  Protected nDevIndex
  Protected nInterDevGap
  Protected nWidth, nHeight
  Protected sToolTip.s
  Protected nDevMapPtr, nDevPtr, sAdjustedLogicalDev.s
  Protected nProdLogicalDevPtr, nNrOfOutputChans, nOutputChanNr, nVUBarsReqd, nBarIndex, nMeterIndex, nMixerChanNr, nTotalBarDisplayWidth, nMeterNrWithinBar, nMixerStreamPtr
  Protected rVUBarDef.tyVUBar, rVUMeterDef.tyVUMeter, rAudioDevDef.tyTVGAudioDev
  Protected nMyMaxVidAudDevPerProd
  
  debugMsgC(sProcName, #SCS_START + ", gnVisMode=" + decodeVisMode(gnVisMode))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If (gnVisMode = #SCS_VU_NONE) Or (gnCtrlPanelPos = #SCS_CTRLPANEL_NONE)
    debugMsgC(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  debugMsgC(sProcName, "grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
  If nDevMapPtr < 0
    debugMsgC(sProcName, "exiting")
    ProcedureReturn
  EndIf
  
  If gnVisMode = #SCS_VU_LEVELS
    bPeakVisible = #True
  EndIf
  
  With WMN
    nCurrSpecWidth = grMVUD\nSpecWidth
    ; Added 12Apr2023
    If WindowWidth(#WMN) > 0
      grWMN\nCurrWindowWidth = WindowWidth(#WMN)
    EndIf
    ; End added 12Apr2023
    nWidth = grWMN\nCurrWindowWidth - GadgetX(WMN\cvsVUDisplay)  ; nb use grWMN\nCurrWindowWidth instead of WindowWidth(#WMN) as WindowWith() returns 0 for a minimized window
    If nWidth < 0
      debugMsgC(sProcName, "exiting - grWMN\nCurrWindowWidth=" + grWMN\nCurrWindowWidth + ", GadgetX(WMN\cvsVUDisplay)=" + GadgetX(WMN\cvsVUDisplay) + ", nWidth=" + nWidth)
      ProcedureReturn
    EndIf
    ResizeGadget(WMN\cvsVUDisplay, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(WMN\cvsVULabels, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    grMVUD\nSpecWidth = (GadgetWidth(WMN\cvsVUDisplay) >> 2) << 2
    If grMVUD\nSpecWidth <> nCurrSpecWidth
      debugMsgC(sProcName, "grMVUD\nSpecWidth=" + grMVUD\nSpecWidth + ", nCurrSpecWidth=" + nCurrSpecWidth + ", calling initVU()")
      initVU()
    EndIf
  EndWith
  
  If (gnVisMode = #SCS_VU_LEVELS) ; -------------------------------------------- LEVELS
    If grTVGControl\bDisplayVUMeters
      nMyMaxVidAudDevPerProd = grLicInfo\nMaxVidAudDevPerProd
    EndIf
    ReDim specbuf(grMVUD\nSpecWidth * (grMVUD\nSpecHeight + 1)) ; clear display
    ReDim grMVUD\aBar((grLicInfo\nMaxAudDevPerProd + nMyMaxVidAudDevPerProd) * 2)
    ReDim nDevOutputs(grLicInfo\nMaxAudDevPerProd + nMyMaxVidAudDevPerProd)
    nOutputIndex = -1
    nDevIndex = -1
    nBarIndex = -1
    nMeterIndex = -1
    grTVGControl\nMaxAudioDev = -1
    nDevPtr = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While nDevPtr >= 0
      If (grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) Or (grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO And grTVGControl\bDisplayVUMeters)
        If (grMaps\aDev(nDevPtr)\sLogicalDev) And (grMaps\aDev(nDevPtr)\nReassignDevMapDevPtr = -1)
          nProdLogicalDevPtr = getProdLogicalDevPtrForLogicalDev(grMaps\aDev(nDevPtr)\sLogicalDev)
          If nProdLogicalDevPtr >= 0
            nNrOfOutputChans = grProd\aAudioLogicalDevs(nProdLogicalDevPtr)\nNrOfOutputChans
          Else
            ; shouldn't get here
            nNrOfOutputChans = 1
          EndIf
          sAdjustedLogicalDev = VST_adjustLogicalDevForVST(grMaps\aDev(nDevPtr)\sLogicalDev)
          nVUBarsReqd = Round(nNrOfOutputChans / 2, #PB_Round_Up) ; eg 1 or 2 outputs = 1 VUBar, 3 or 4 outputs = 2 VUBars, etc
          debugMsgC(sProcName, "grMaps\aDev(" + nDevPtr + ")\sLogicalDev=" + grMaps\aDev(nDevPtr)\sLogicalDev + ", nProdLogicalDevPtr=" + nProdLogicalDevPtr + ", nNrOfOutputChans=" + nNrOfOutputChans + ", nVUBarsReqd=" + nVUBarsReqd)
          If grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            If gbUseBASSMixer
              nMixerStreamPtr = grMaps\aDev(nDevPtr)\nMixerStreamPtr
              ; debugMsg0(sProcName, "grProd\bNewCueFile=" + strB(grProd\bNewCueFile))
              CompilerIf 1=1 ; Changed 27Jan2025 (was 1=1) Would originally have been 1=2 and don't know why it was changed to 1=1. Needs to be 1=2 (ie code bypassed) to correct bug reported by Dave Cornish 27Jan2025 'No output'.
                ; Blocked out 18Mar2023 11.10.0am following investigation of a bug encountered when testing 'Dream' with the Octa-Capture.
                ; It is NOT necessary to call createMixerStreams() here as it will be called later, and calling it now could result one or more extra mixer streams being created and 'left over'.
                ; See emails to Ian Luck 17-18Mar2023.
                ; INFO: Changed back to 1=1 7Feb2025 11.10.7aa but added grProd\bNewCueFile test (below) because creating a new cue file would not create the mixer streams.
                If (nMixerStreamPtr = -1) And (gbGoToProdPropDevices = #False) And (grProd\bNewCueFile) ; Added grProd\bNewCueFile test 7Feb2025 11.10.7aa
                  debugMsgC(sProcName, "grMaps\aDev(" + nDevPtr + ")\sLogicalDev=" + grMaps\aDev(nDevPtr)\sLogicalDev + ", \nMixerStreamPtr=" + grMaps\aDev(nDevPtr)\nMixerStreamPtr + ", calling createMixerStreams()")
                  createMixerStreams()
                  nMixerStreamPtr = grMaps\aDev(nDevPtr)\nMixerStreamPtr
                EndIf
              CompilerEndIf
              If nMixerStreamPtr >= 0
                nDevIndex + 1
                nDevOutputs(nDevIndex) = 0
                With gaMixerStreams(nMixerStreamPtr)
                  ; debugMsgC(sProcName, "gaMixerStreams(" + nMixerStreamPtr + ")\nMixerChans=" + gaMixerStreams(nMixerStreamPtr)\nMixerChans)
                  For nMixerChanNr = 1 To \nMixerChans
                    nDevOutputs(nDevIndex) + 1
                    nOutputIndex + 1
                    If nMixerChanNr & 1
                      ; nMixerChanNr is odd (1, 3, 5, etc)
                      nMeterNrWithinBar = 1
                      nBarIndex + 1
                      If nBarIndex > ArraySize(grMVUD\aBar())
                        ReDim grMVUD\aBar(nBarIndex + 10)
                      EndIf
                      grMVUD\aBar(nBarIndex) = rVUBarDef ; clear any existing content
                      grMVUD\aBar(nBarIndex)\sVUBarLogicalDev = sAdjustedLogicalDev
                      grMVUD\aBar(nBarIndex)\nVUBarDevType = grMaps\aDev(nDevPtr)\nDevType
                    Else
                      ; nMixerChanNr is even (2, 4, 6, etc)
                      nMeterNrWithinBar = 2
                    EndIf
                    If nMeterNrWithinBar = 1
                      If nMixerChanNr = 1
                        grMVUD\aBar(nBarIndex)\sVUBarLabel = sAdjustedLogicalDev
                      Else
                        grMVUD\aBar(nBarIndex)\sVUBarLabel = Str(nMixerChanNr)
                      EndIf
                    ElseIf nMixerChanNr > 2
                      grMVUD\aBar(nBarIndex)\sVUBarLabel + grMVUD\sMeterGapWithinBar + Str(nMixerChanNr)
                    EndIf
                    If nMeterNrWithinBar = 1
                      grMVUD\aBar(nBarIndex)\bNoDevice = \bNoDevice
                      grMVUD\aBar(nBarIndex)\bIgnoreDevThisRun = grMaps\aDev(nDevPtr)\bIgnoreDevThisRun
                      ; debugMsg(sProcName, "calling calcReqdGain(@grMaps\aDev(" + nDevPtr + "), #False, " + strB(#cTraceSetLevels) + ")")
                      grMVUD\aBar(nBarIndex)\fVUOutputGain = calcReqdGain(@grMaps\aDev(nDevPtr), #False, #cTraceSetLevels)
                      grMVUD\aBar(nBarIndex)\nMeterCount = \nMixerChans
                    EndIf
                    nMeterIndex + 1
                    If nMeterIndex > ArraySize(grMVUD\aMeter())
                      ReDim grMVUD\aMeter(nMeterIndex + 10)
                    EndIf
                    grMVUD\aMeter(nMeterIndex) = rVUMeterDef ; clear any existing content
                    grMVUD\aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
                    grMVUD\aMeter(nMeterIndex)\nDevMapDevPtr = nDevPtr
                    grMVUD\aMeter(nMeterIndex)\nMixerStreamPtr = nMixerStreamPtr
                    grMVUD\aMeter(nMeterIndex)\nMixerChanNr = nMixerChanNr
                    If \bASIO
                      grMVUD\aMeter(nMeterIndex)\nDevChannel = \nFirstOutputChannel + nMixerChanNr - 1
                      grMVUD\aMeter(nMeterIndex)\nBassASIODevice = \nBassASIODevice
                    Else
                      grMVUD\aMeter(nMeterIndex)\nDevChannel = \nMixerStreamHandle
                    EndIf
                    ; debugMsgC(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\nMixerStreamPtr=" + grMVUD\aMeter(nMeterIndex)\nMixerStreamPtr +
                    ;                     ", \nMixerChanNr=" + grMVUD\aMeter(nMeterIndex)\nMixerChanNr +
                    ;                     ", \nDevChannel=" + decodeHandle(grMVUD\aMeter(nMeterIndex)\nDevChannel))
                  Next nMixerChanNr
                  bDrawLabels = #True
                EndWith
              EndIf
              
            Else ; gbUseBASSMixer = #False
              If grMaps\aDev(nDevPtr)\nBassDevice > 0   ; ignores 0 (no sound) and -1 (unassigned)
                nDevIndex + 1
                CheckSubInRange(nDevIndex, ArraySize(nDevOutputs()), "nDevOutputs()")
                nDevOutputs(nDevIndex) = 0
                With grMaps\aDev(nDevPtr)
                  nOutputIndex + 1
                  nDevOutputs(nDevIndex) + 1
                  For nOutputChanNr = 1 To \nNrOfDevOutputChans
                    nDevOutputs(nDevIndex) + 1
                    nOutputIndex + 1
                    If nOutputChanNr & 1
                      ; nOutputChanNr is odd (1, 3, 5, etc)
                      nMeterNrWithinBar = 1
                      nBarIndex + 1
                      If nBarIndex > ArraySize(grMVUD\aBar())
                        ReDim grMVUD\aBar(nBarIndex + 10)
                      EndIf
                      grMVUD\aBar(nBarIndex) = rVUBarDef ; clear any existing content
                      grMVUD\aBar(nBarIndex)\sVUBarLogicalDev = sAdjustedLogicalDev
                      grMVUD\aBar(nBarIndex)\nVUBarDevType = grMaps\aDev(nDevPtr)\nDevType
                    Else
                      ; nOutputChanNr is even (2, 4, 6, etc)
                      nMeterNrWithinBar = 2
                    EndIf
                    If nMeterNrWithinBar = 1
                      If nOutputChanNr = 1
                        grMVUD\aBar(nBarIndex)\sVUBarLabel = sAdjustedLogicalDev
                      Else
                        grMVUD\aBar(nBarIndex)\sVUBarLabel = Str(nOutputChanNr)
                      EndIf
                    ElseIf nOutputChanNr > 2
                      grMVUD\aBar(nBarIndex)\sVUBarLabel + grMVUD\sMeterGapWithinBar + Str(nOutputChanNr)
                    EndIf
                    If nMeterNrWithinBar = 1
                      grMVUD\aBar(nBarIndex)\bNoDevice = \bNoDevice
                      grMVUD\aBar(nBarIndex)\bIgnoreDevThisRun = grMaps\aDev(nDevPtr)\bIgnoreDevThisRun
                      ; debugMsg(sProcName, "calling calcReqdGain(@grMaps\aDev(" + nDevPtr + "), #False, " + strB(#cTraceSetLevels) + ")")
                      grMVUD\aBar(nBarIndex)\fVUOutputGain = calcReqdGain(@grMaps\aDev(nDevPtr), #False, #cTraceSetLevels)
                      grMVUD\aBar(nBarIndex)\nMeterCount = \nNrOfDevOutputChans
                    EndIf
                    nMeterIndex + 1
                    If nMeterIndex > ArraySize(grMVUD\aMeter())
                      ReDim grMVUD\aMeter(nMeterIndex + 10)
                    EndIf
                    grMVUD\aMeter(nMeterIndex) = rVUMeterDef ; clear any existing content
                    grMVUD\aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
                    grMVUD\aMeter(nMeterIndex)\nDevMapDevPtr = nDevPtr
                    grMVUD\aMeter(nMeterIndex)\nDevChannel = \nDevChannel[nOutputChanNr-1]
                    debugMsgC(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\nDevChannel=" + decodeHandle(grMVUD\aMeter(nMeterIndex)\nDevChannel))
                  Next nOutputChanNr
                  bDrawLabels = #True
                EndWith
              EndIf
              
            EndIf ; EndIf gbUseBASSMixer / Else
            
          ElseIf grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
            nDevIndex + 1
            CheckSubInRange(nDevIndex, ArraySize(nDevOutputs()), "nDevOutputs()")
            nDevOutputs(nDevIndex) = 0
            With grMaps\aDev(nDevPtr)
              nOutputIndex + 1
              nDevOutputs(nDevIndex) + 1
              nVidAudFirstMeterIndex = -1
              For nOutputChanNr = 1 To \nNrOfDevOutputChans
                nDevOutputs(nDevIndex) + 1
                nOutputIndex + 1
                If nOutputChanNr & 1
                  ; nOutputChanNr is odd (1, 3, 5, etc)
                  nMeterNrWithinBar = 1
                  nBarIndex + 1
                  If nBarIndex > ArraySize(grMVUD\aBar())
                    ReDim grMVUD\aBar(nBarIndex + 10)
                  EndIf
                  grMVUD\aBar(nBarIndex) = rVUBarDef ; clear any existing content
                  grMVUD\aBar(nBarIndex)\sVUBarLogicalDev = sAdjustedLogicalDev
                  grMVUD\aBar(nBarIndex)\nVUBarDevType = grMaps\aDev(nDevPtr)\nDevType
                Else
                  ; nOutputChanNr is even (2, 4, 6, etc)
                  nMeterNrWithinBar = 2
                EndIf
                If nMeterNrWithinBar = 1
                  If nOutputChanNr = 1
                    grMVUD\aBar(nBarIndex)\sVUBarLabel = sAdjustedLogicalDev
                  Else
                    grMVUD\aBar(nBarIndex)\sVUBarLabel = Str(nOutputChanNr)
                  EndIf
                ElseIf nOutputChanNr > 2
                  grMVUD\aBar(nBarIndex)\sVUBarLabel + grMVUD\sMeterGapWithinBar + Str(nOutputChanNr)
                EndIf
                If nMeterNrWithinBar = 1
                  grMVUD\aBar(nBarIndex)\bNoDevice = \bNoDevice
                  grMVUD\aBar(nBarIndex)\bIgnoreDevThisRun = grMaps\aDev(nDevPtr)\bIgnoreDevThisRun
                  ; debugMsg(sProcName, "calling calcReqdGain(@grMaps\aDev(" + nDevPtr + "), #False, " + strB(#cTraceSetLevels) + ")")
                  grMVUD\aBar(nBarIndex)\fVUOutputGain = calcReqdGain(@grMaps\aDev(nDevPtr), #False, #cTraceSetLevels)
                  grMVUD\aBar(nBarIndex)\nMeterCount = \nNrOfDevOutputChans
                EndIf
                nMeterIndex + 1
                If nMeterIndex > ArraySize(grMVUD\aMeter())
                  ReDim grMVUD\aMeter(nMeterIndex + 10)
                EndIf
                grMVUD\aMeter(nMeterIndex) = rVUMeterDef ; clear any existing content
                grMVUD\aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
                grMVUD\aMeter(nMeterIndex)\nDevMapDevPtr = nDevPtr
                grMVUD\aMeter(nMeterIndex)\nDevChannel = \nDevChannel[nOutputChanNr-1]
                grMVUD\aMeter(nMeterIndex)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
                debugMsgC(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\nDevChannel=" + decodeHandle(grMVUD\aMeter(nMeterIndex)\nDevChannel))
                If nVidAudFirstMeterIndex < 0
                  nVidAudFirstMeterIndex = nMeterIndex
                EndIf
              Next nOutputChanNr
              bDrawLabels = #True
            EndWith
            With grTVGControl
              \nMaxAudioDev + 1
              If \nMaxAudioDev > ArraySize(\aAudioDev())
                ReDim \aAudioDev(\nMaxAudioDev)
              EndIf
              \aAudioDev(\nMaxAudioDev) = rAudioDevDef
              \aAudioDev(\nMaxAudioDev)\sVidAudLogicalDev = grMaps\aDev(nDevPtr)\sLogicalDev
              \aAudioDev(\nMaxAudioDev)\nVideoAudioDevPtr = nDevPtr
              \aAudioDev(\nMaxAudioDev)\nFirstMeterIndex = nVidAudFirstMeterIndex
              debugMsgC(sProcName, "grTVGControl\aAudioDev(" + \nMaxAudioDev + ")\nFirstMeterIndex=" + \aAudioDev(\nMaxAudioDev)\nFirstMeterIndex)
            EndWith
          EndIf ; EndIf grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT / ElseIf grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
        EndIf ; EndIf (grMaps\aDev(nDevPtr)\sLogicalDev) And (grMaps\aDev(nDevPtr)\nReassignDevMapDevPtr = -1)
      EndIf ; EndIf (grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) Or (grMaps\aDev(nDevPtr)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO And grTVGControl\bDisplayVUMeters)
      
      nDevPtr = grMaps\aDev(nDevPtr)\nNextDevIndex
    Wend
    
    With grMVUD
      \nMaxBar = nBarIndex
      \nBarCount = \nMaxBar + 1
      \nMaxMeter = nMeterIndex
      \nMeterCount = \nMaxMeter + 1
      debugMsgC(sProcName, "nOutputIndex=" + nOutputIndex + ", nDevIndex=" + nDevIndex + ", grMVUD\nBarCount=" + \nBarCount + ", \nMeterCount=" + \nMeterCount + ", \nMaxBar=" + \nMaxBar + ", \nMaxMeter=" + \nMaxMeter)
      
      nInterDevGap = 4
      If nDevIndex > 0
        ; more than one device
        If nDevIndex > 7
          nInterDevGap = 2
        EndIf
        \nBarWidth = Round((\nSpecWidth - (nInterDevGap * nDevIndex)) / \nBarCount, #PB_Round_Down)
      Else
        \nBarWidth = Round(\nSpecWidth / \nBarCount, #PB_Round_Down)
      EndIf
      If \nBarWidth > \nMaxBarWidth
        \nBarWidth = \nMaxBarWidth
      EndIf
      If \nBarWidth < \nMinBarWidth
        \nBarWidth = \nMinBarWidth
      EndIf
      \nMeterWidth = gnReqdMeterWidth
      If \nMeterWidth > \nBarWidth
        \nMeterWidth = \nBarWidth
      EndIf
      nTotalBarDisplayWidth = (\nBarCount * \nBarWidth) + ((\nBarCount - 1) * nInterDevGap)
      If nTotalBarDisplayWidth < \nSpecWidth
        \nXOffSet = (\nSpecWidth - nTotalBarDisplayWidth) >> 1
      Else
        \nXOffSet = 0
      EndIf
      X = \nXOffSet
      For nBarIndex = 0 To \nMaxBar
        \aBar(nBarIndex)\nBarX = X
        For nMeterIndex = 0 To \nMaxMeter
          If \aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
            If \aBar(nBarIndex)\nMeterCount = 1
              \aMeter(nMeterIndex)\nMeterX = X + ((\nBarWidth - \nMeterWidth) >> 1) + 1
            Else
              \aMeter(nMeterIndex)\nMeterX = X + ((\nBarWidth - \nMeterWidth - \nMeterGapWithinBar - \nMeterWidth) >> 1) + 1
              \aMeter(nMeterIndex + 1)\nMeterX = \aMeter(nMeterIndex)\nMeterX + \nMeterGapWithinBar + \nMeterWidth
              nMeterIndex + 1
              X + \nMeterWidth + \nMeterGapWithinBar
            EndIf
          EndIf
        Next nMeterIndex
        X = \aBar(nBarIndex)\nBarX + \nBarWidth + nInterDevGap
      Next nBarIndex
      
    EndWith
    
  EndIf
  
  grMVUD\bDisplayTriangles = #False
  If StartDrawing(CanvasOutput(WMN\cvsVULabels))
    DrawingMode(#PB_2DDrawing_Transparent)
    
    If bDrawLabels Or bDrawOneLabel
      nWidth = GadgetWidth(WMN\cvsVULabels)
      nHeight = GadgetHeight(WMN\cvsVULabels)
      Box(0, 0, nWidth, nHeight, #SCS_Black)
      
      nLabelPosY = nHeight - (TextHeight("W") + 1)
      If bDrawOneLabel
        nLabelPosX = (grMVUD\nSpecWidth >> 1) - (TextWidth(sOneLabel) / 2)
        DrawText(nLabelPosX, nLabelPosY, sOneLabel, #SCS_White)
        If gnMixerStreamCount > 1
          grMVUD\bDisplayTriangles = #True
          grMVUD\nTriangleHeight = (TextHeight("W") * 3) / 4    ; = * 0.75
          grMVUD\nTriangleWidth = (TextWidth("W") * 3) / 4      ; = * 0.75
          grMVUD\nTriangleXPosL = grMVUD\nTriangleWidth << 1
          grMVUD\nTriangleYPosL = ((nHeight - grMVUD\nTriangleHeight) >> 1) + grMVUD\nTriangleHeight
          grMVUD\nTriangleXPosR = grMVUD\nSpecWidth - grMVUD\nTriangleXPosL + 1
          grMVUD\nTriangleYPosR = grMVUD\nTriangleYPosL
          drawTriangle(-1, grMVUD\nTriangleXPosL, grMVUD\nTriangleYPosL, grMVUD\nTriangleColorL)
          drawTriangle(1, grMVUD\nTriangleXPosR, grMVUD\nTriangleYPosR, grMVUD\nTriangleColorR)
        EndIf
        If grMVUD\aBar(nBarIndex)\nVUBarDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
          LineXY(nLabelPosX, nHeight-2, nLabelPosX+TextWidth(sOneLabel), nHeight-2, #SCS_Mid_Grey)
        EndIf
      Else
        For nBarIndex = 0 To (grMVUD\nBarCount - 1)
          If grMVUD\aBar(nBarIndex)\sVUBarLabel
            nMaxLabelWidth = grMVUD\nBarWidth
            nLabelPosX = grMVUD\aBar(nBarIndex)\nBarX + (grMVUD\nBarWidth >> 1)
            sTmpLabel = compactVULabel(grMVUD\aBar(nBarIndex)\sVUBarLabel, nMaxLabelWidth)
            nLabelPosX - (TextWidth(sTmpLabel) / 2)
            Box(grMVUD\aBar(nBarIndex)\nBarX, 0, grMVUD\nBarWidth, nHeight, #SCS_Dark_Grey)
            If grMVUD\aBar(nBarIndex)\bIgnoreDevThisRun
              DrawText(nLabelPosX, nLabelPosY, sTmpLabel, #SCS_Red)
              debugMsgC(sProcName, "DrawText(" + nLabelPosX + ", " + nLabelPosY + ", " + #DQUOTE$ + sTmpLabel + #DQUOTE$ + ", #SCS_Red)")
            Else
              DrawText(nLabelPosX, nLabelPosY, sTmpLabel, #SCS_White)
              debugMsgC(sProcName, "DrawText(" + nLabelPosX + ", " + nLabelPosY + ", " + #DQUOTE$ + sTmpLabel + #DQUOTE$ + ", #SCS_White)")
            EndIf
            If grMVUD\aBar(nBarIndex)\nVUBarDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
              LineXY(nLabelPosX, nHeight-2, nLabelPosX+TextWidth(sTmpLabel), nHeight-2, #SCS_Mid_Grey)
            EndIf
          EndIf
        Next nBarIndex
      EndIf
    EndIf
    
    If grMVUD\bDisplayTriangles
      sToolTip = Lang("Main", "VUDisplayTT2")
    EndIf
    scsToolTip(WMN\cvsVULabels, sToolTip)
    scsToolTip(WMN\cvsVUDisplay, sToolTip)
    
    StopDrawing()
  EndIf
  
  ; debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure displayLabelsSMS(bTrace=#False)
  PROCNAMEC()
  Protected X
  Protected m, n2, nOutputNr, nOutputIndex
  Protected nLabelPosX, nLabelPosY
  Protected bDrawLabels, bDrawOneLabel
  Protected sOneLabel.s, sTmpLabel.s
  Protected nMaxLabelWidth
  Protected bPeakVisible
  Protected nCurrSpecWidth
  Protected Dim nDevOutputs(0)
  Protected nDevIndex
  Protected nInterDevGap
  Protected nWidth, nHeight
  Protected sToolTip.s
  Protected nDevPtr
  Protected nOutputCount
  Protected sDevLabel.s, sLogicalDev.s
  Protected d
  Protected nBarIndex, nMeterIndex, nTotalBarDisplayWidth
  Protected rVUBarDef.tyVUBar, rVUMeterDef.tyVUMeter
  
  debugMsgC(sProcName, #SCS_START + ", gnVisMode=" + decodeVisMode(gnVisMode))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  If gnVisMode = #SCS_VU_NONE
    debugMsgC(sProcName, "exiting because gnVisMode=None")
    ProcedureReturn
  EndIf
  
  If gnCtrlPanelPos = #SCS_CTRLPANEL_NONE
    debugMsgC(sProcName, "exiting because \nCtrlPanelPos=None")
    ProcedureReturn
  EndIf
  
  If grASIOGroup\nGroupOutputs <= 0
    debugMsgC(sProcName, "exiting because grASIOGroup\nGroupOutputs=" + Str(grASIOGroup\nGroupOutputs))
    ProcedureReturn
  EndIf
  
  If gnVUMeters <= 0
    debugMsgC(sProcName, "exiting because gnVUMeters=" + Str(gnVUMeters))
    ProcedureReturn
  EndIf
  
  If gnVisMode = #SCS_VU_LEVELS
    bPeakVisible = #True
  EndIf
  
  With WMN
    nCurrSpecWidth = grMVUD\nSpecWidth
    nWidth = grWMN\nCurrWindowWidth - GadgetX(WMN\cvsVUDisplay)  ; nb use grWMN\nCurrWindowWidth instead of WindowWidth(#WMN) as WindowWith() returns 0 for a minimized window
    ; Changed 12Apr2021 11.8.4.2ae following email from Dmitriy Velikanov
    ; Changed to match corresponding code near start of displayLabelsBASSandTVG()
    ; If nWidth < 0
    ;   RaiseMiscError("nWidth=" + nWidth + ", grWMN\nCurrWindowWidth=" + grWMN\nCurrWindowWidth + ", GadgetX(WMN\cvsVUDisplay)=" + GadgetX(WMN\cvsVUDisplay))
    ; EndIf
    If nWidth < 0
      debugMsgC(sProcName, "exiting - grWMN\nCurrWindowWidth=" + grWMN\nCurrWindowWidth + ", GadgetX(WMN\cvsVUDisplay)=" + GadgetX(WMN\cvsVUDisplay) + ", nWidth=" + nWidth)
      ProcedureReturn
    EndIf
    ; End of changed 12Apr2021 11.8.4.2ae
    ResizeGadget(WMN\cvsVUDisplay, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    ResizeGadget(WMN\cvsVULabels, #PB_Ignore, #PB_Ignore, nWidth, #PB_Ignore)
    grMVUD\nSpecWidth = (GadgetWidth(WMN\cvsVUDisplay) >> 2) << 2
    If grMVUD\nSpecWidth <> nCurrSpecWidth
      debugMsgC(sProcName, "grMVUD\nSpecWidth=" + grMVUD\nSpecWidth + ", nCurrSpecWidth=" + nCurrSpecWidth + ", calling initVU()")
      initVU()
    EndIf
  EndWith
  
  With grMVUD
    If (gnVisMode = #SCS_VU_LEVELS) ; -------------------------------------------- LEVELS
      ReDim specbuf(\nSpecWidth * (\nSpecHeight + 1)) ; clear display
      nOutputNr = gnVUMeters
      \nBarCount = gnVUMeters
      \nMaxBar = \nBarCount - 1
      \nMeterCount = gnVUMeters
      ReDim \aBar(\nMaxBar)
      ReDim nDevOutputs(nOutputNr)
      nOutputIndex = -1
      nDevIndex = -1
      nBarIndex = -1
      nMeterIndex = -1
      
      For nBarIndex = 0 To \nMaxBar
        nOutputIndex = nBarIndex
        \aBar(nBarIndex) = rVUBarDef
        nDevPtr = gaSMSOutput(nOutputIndex)\nFirstDevPtr
        If nDevPtr >= 0
          \aBar(nBarIndex)\sVUBarLabel = grMaps\aDev(nDevPtr)\sLogicalDev
          If gaSMSOutput(nOutputIndex)\nLastDevPtr <> gaSMSOutput(nOutputIndex)\nFirstDevPtr
            \aBar(nBarIndex)\sVUBarLabel + "+"
          EndIf
          \aBar(nBarIndex)\sVUBarLogicalDev = grMaps\aDev(nDevPtr)\sLogicalDev
          \aBar(nBarIndex)\nVUBarDevType = grMaps\aDev(nDevPtr)\nDevType
          \aBar(nBarIndex)\bNoDevice = #False
          \aBar(nBarIndex)\fVUOutputGain = grMaps\aDev(nDevPtr)\fDevOutputGain
          \aBar(nBarIndex)\nMeterCount = 1  ; currently fixed at 1
          nMeterIndex + 1
          If nMeterIndex > ArraySize(\aMeter())
            ReDim \aMeter(nMeterIndex + 10)
          EndIf
          \aMeter(nMeterIndex) = rVUMeterDef ; clear any existing content
          \aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
          \aMeter(nMeterIndex)\nDevMapDevPtr = nDevPtr
          \aMeter(nMeterIndex)\nMixerChanNr = 1
        EndIf
        bDrawLabels = #True
      Next nBarIndex
      \nMaxMeter = nMeterIndex
      
      For nBarIndex = 1 To \nMaxBar
        If grMVUD\aBar(nBarIndex)\sVUBarLabel = grMVUD\aBar(nBarIndex-1)\sVUBarLabel
          grMVUD\aBar(nBarIndex)\sVUBarLabel = ""
        EndIf
      Next nBarIndex
      
      nInterDevGap = 4
      nDevIndex = nOutputNr - 1
      If nDevIndex > 0
        ; more than one device
        If nDevIndex > 7
          nInterDevGap = 2
        EndIf
        \nBarWidth = Round((\nSpecWidth - (nInterDevGap * nDevIndex)) / \nMeterCount, #PB_Round_Down)
      Else
        \nBarWidth = Round(\nSpecWidth / \nMeterCount, #PB_Round_Down)
      EndIf
      If \nBarWidth > \nMaxBarWidth
        \nBarWidth = \nMaxBarWidth
      EndIf
      \nMeterWidth = gnReqdMeterWidth
      debugMsgC(sProcName, "gnReqdMeterWidth=" + gnReqdMeterWidth + ", \nMeterWidth=" + \nMeterWidth)
      nTotalBarDisplayWidth = (\nBarCount * \nBarWidth) + ((\nBarCount - 1) * nInterDevGap)
      If nTotalBarDisplayWidth < \nSpecWidth
        \nXOffSet = (\nSpecWidth - nTotalBarDisplayWidth) >> 1
      Else
        \nXOffSet = 0
      EndIf
      debugMsgC(sProcName, "\nXOffSet=" + \nXOffSet)
      X = \nXOffSet
      ; debugMsgC(sProcName, "\nMaxBar=" + \nMaxBar + ", \nMaxMeter=" + \nMaxMeter)
      For nBarIndex = 0 To \nMaxBar
        \aBar(nBarIndex)\nBarX = X
        ; debugMsgC(sProcName, "\aBar(" + nBarIndex + ")\nBarX=" + \aBar(nBarIndex)\nBarX)
        For nMeterIndex = 0 To \nMaxMeter
          ; debugMsgC(sProcName, "\aMeter(" + nMeterIndex + ")\nParentBarIndex=" + \aMeter(nMeterIndex)\nParentBarIndex + ", nBarIndex=" + nBarIndex)
          If \aMeter(nMeterIndex)\nParentBarIndex = nBarIndex
            ; debugMsgC(sProcName, "\aBar(" + nBarIndex + ")\nMeterCount=" + \aBar(nBarIndex)\nMeterCount)
            If \aBar(nBarIndex)\nMeterCount = 1
              \aMeter(nMeterIndex)\nMeterX = X + ((\nBarWidth - \nMeterWidth) >> 1) + 1
              debugMsgC(sProcName, "grMVUD\aBar(" + nBarIndex + ")\nBarX=" + \aBar(nBarIndex)\nBarX + ", grMVUD\aMeter(" + nMeterIndex + ")\nMeterX=" + \aMeter(nMeterIndex)\nMeterX)
            Else
              \aMeter(nMeterIndex)\nMeterX = X + ((\nBarWidth - \nMeterWidth - \nMeterGapWithinBar - \nMeterWidth) >> 1) + 1
              \aMeter(nMeterIndex + 1)\nMeterX = \aMeter(nMeterIndex)\nMeterX + \nMeterGapWithinBar + \nMeterWidth
              debugMsgC(sProcName, "grMVUD\aBar(" + nBarIndex + ")\nBarX=" + \aBar(nBarIndex)\nBarX + ", grMVUD\aMeter(" + nMeterIndex + ")\nMeterX=" + \aMeter(nMeterIndex)\nMeterX + ", \aMeter(" + Str(nMeterIndex+1) + ")\nMeterX=" + \aMeter(nMeterIndex+1)\nMeterX)
              nMeterIndex + 1
              X + \nMeterWidth + \nMeterGapWithinBar
            EndIf
          EndIf
        Next nMeterIndex
        X = \aBar(nBarIndex)\nBarX + \nBarWidth + nInterDevGap
      Next nBarIndex
      
    EndIf
    
    \bDisplayTriangles = #False
    \bTrianglesForVUBank = #False
    
    If StartDrawing(CanvasOutput(WMN\cvsVULabels))
      DrawingMode(#PB_2DDrawing_Transparent)
      
      If bDrawLabels Or bDrawOneLabel
        nWidth = GadgetWidth(WMN\cvsVULabels)
        nHeight = GadgetHeight(WMN\cvsVULabels)
        Box(0, 0, nWidth, nHeight, #SCS_Black)
        
        nLabelPosY = nHeight - (TextHeight("W") + 1)
        debugMsgC(sProcName, "bDrawOneLabel=" + strB(bDrawOneLabel))
        If bDrawOneLabel
          nLabelPosX = (grMVUD\nSpecWidth >> 1) - (TextWidth(sOneLabel) / 2)
            Box(grMVUD\aBar(nBarIndex)\nBarX, 0, grMVUD\nBarWidth, nHeight, #SCS_Dark_Grey)
          DrawText(nLabelPosX, nLabelPosY, sOneLabel, #SCS_White)
          ; debugMsgC(sProcName, "DrawText(" + Str(nLabelPosX) + ", " + Str(nLabelPosY) + ", " + sOneLabel + ", #SCS_White)")
          If gnMixerStreamCount > 1
            \bDisplayTriangles = #True
            \nTriangleHeight = (TextHeight("W") * 3) / 4    ; = * 0.75
            \nTriangleWidth = (TextWidth("W") * 3) / 4      ; = * 0.75
            \nTriangleXPosL = \nTriangleWidth << 1
            \nTriangleYPosL = ((nHeight - \nTriangleHeight) >> 1) + \nTriangleHeight
            \nTriangleXPosR = \nSpecWidth - \nTriangleXPosL + 1
            \nTriangleYPosR = \nTriangleYPosL
            drawTriangle(-1, \nTriangleXPosL, \nTriangleYPosL, \nTriangleColorL)
            drawTriangle(1, \nTriangleXPosR, \nTriangleYPosR, \nTriangleColorR)
          EndIf
        Else
          ; debugMsgC(sProcName,"grMVUD\nBands=" + Str(grMVUD\nBands))
          For nBarIndex = 0 To \nMaxBar
            If \aBar(nBarIndex)\sVUBarLabel
              nMaxLabelWidth = \nBarWidth
              If nBarIndex < \nMaxBar
                If Len(\aBar(nBarIndex+1)\sVUBarLabel) = 0
                  ; label to span 2 bars
                  nLabelPosX = \aBar(nBarIndex)\nBarX + \nBarWidth
                  nMaxLabelWidth = \nBarWidth * 2
                Else
                  nLabelPosX = \aBar(nBarIndex)\nBarX + (\nBarWidth >> 1)
                EndIf
              Else
                nLabelPosX = \aBar(nBarIndex)\nBarX + (\nBarWidth >> 1)
              EndIf
              Box(\aBar(nBarIndex)\nBarX, 0, nMaxLabelWidth, nHeight, #SCS_Dark_Grey)
              sTmpLabel = compactVULabel(\aBar(nBarIndex)\sVUBarLabel, nMaxLabelWidth)
              nLabelPosX - (TextWidth(sTmpLabel) / 2)
              DrawText(nLabelPosX, nLabelPosY, sTmpLabel, #SCS_White)
              If \aBar(nBarIndex)\nVUBarDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
                LineXY(nLabelPosX, nHeight-2, nLabelPosX+TextWidth(sTmpLabel), nHeight-2, #SCS_Mid_Grey)
              EndIf
            EndIf
          Next nBarIndex
          If grASIOGroup\nGroupOutputs > gnVUMaxMeters
            \bDisplayTriangles = #True
            \bTrianglesForVUBank = #True
            \nTriangleHeight = (TextHeight("W") * 3) / 4    ; = * 0.75
            \nTriangleWidth = (TextWidth("W") * 3) / 4      ; = * 0.75
            ; debugMsgC(sProcName, "TextWidth('W')=" + Str(TextWidth("W")) + ", \nTriangleWidth=" + Str(grMVUD\nTriangleWidth))
            \nTriangleXPosL = \nTriangleWidth << 1
            \nTriangleYPosL = ((nHeight - \nTriangleHeight) >> 1) + \nTriangleHeight
            \nTriangleXPosR = \nSpecWidth - \nTriangleXPosL + 1
            \nTriangleYPosR = \nTriangleYPosL
            drawTriangle(-1, \nTriangleXPosL, \nTriangleYPosL, \nTriangleColorL)
            drawTriangle(1, \nTriangleXPosR, \nTriangleYPosR, \nTriangleColorR)
          EndIf
        EndIf
      EndIf
      
      If \bTrianglesForVUBank
        sToolTip = Lang("Main", "VUDisplayTT1")
      ElseIf \bDisplayTriangles
        sToolTip = Lang("Main", "VUDisplayTT2")
      EndIf
      scsToolTip(WMN\cvsVULabels, sToolTip)
      scsToolTip(WMN\cvsVUDisplay, sToolTip)
      
      StopDrawing()
      
    EndIf ; EndIf StartDrawing(CanvasOutput(WMN\cvsVULabels))
    
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure setOutputGainYValues(bTrace=#False)
  ; PROCNAMEC()
  Protected nBarIndex, nMeterIndex, fDevOutputGain.f
  Protected Y, sc
  
  ; debugMsg(sProcName, "grMVUD\bDrawOutputGainMarkers=" + strB(grMVUD\bDrawOutputGainMarkers))
  grMVUD\bDrawOutputGainMarkers = #False
  sc = 10
  For nMeterIndex = 0 To grMVUD\nMaxMeter
    nBarIndex = grMVUD\aMeter(nMeterIndex)\nParentBarIndex
    fDevOutputGain = grMVUD\aBar(nBarIndex)\fVUOutputGain
    ; debugMsg(sProcName, "grMVUD\aBar(" + nBarIndex + ")\fVUOutputGain=" + grMVUD\aBar(nBarIndex)\fVUOutputGain)
    With grMVUD\aMeter(nMeterIndex)
      If fDevOutputGain = grLevels\fMaxBVLevel
        \nOutputGainY = -1  ; indicates output gain line not to be drawn
      Else
        Y = (Sqr(fDevOutputGain / Log10(sc)) * grMVUD\nSpecHeight) - 1 ; scale it
        If (Y > grMVUD\nSpecHeight)
          Y = grMVUD\nSpecHeight ; cap it
        EndIf
        \nOutputGainY = Y
        grMVUD\bDrawOutputGainMarkers = #True
      EndIf
    EndWith
  Next nMeterIndex
  ; debugMsg(sProcName, "grMVUD\bDrawOutputGainMarkers=" + strB(grMVUD\bDrawOutputGainMarkers))
  
  CompilerIf 1=2
    ; test code only, to trace Y values for dB levels
    Protected nDBLevel, sDBLevel.s, fBVLevel.f
    debugMsg(sProcName, "grMVUD\nSpecHeight=" + Str(grMVUD\nSpecHeight))
    For nDBLevel = 0 To -72 Step -3
      sDBLevel = Str(nDBLevel)
      fBVLevel = convertDBStringToBVLevel(sDBLevel)
      Y = (Sqr(fBVLevel / Log10(sc)) * grMVUD\nSpecHeight) - 1 ; scale it
      debugMsg(sProcName, "fBVLevel=" + traceLevel(fBVLevel) + ", Y=" + Y)
    Next nDBLevel
  CompilerEndIf
  
EndProcedure

Procedure displayLabels(bResetMaxBarWidth=#True, bTrace=#False)
  PROCNAMEC()
  
  debugMsgC(sProcName, #SCS_START + ", gbInRedoPhysicalDevs=" + strB(gbInRedoPhysicalDevs) + ", gbUseBASS=" + strB(gbUseBASS))
  
  If gbInRedoPhysicalDevs = #False
    If bResetMaxBarWidth
      debugMsgC(sProcName, "calling resetMaxBarWidth()")
      resetMaxBarWidth(bTrace)
    EndIf
    If gbUseBASS  ; BASS
      debugMsgC(sProcName, "calling displayLabelsBASSandTVG()")
      displayLabelsBASSandTVG(bTrace)
    Else  ; SM-S
      displayLabelsSMS(bTrace)
    EndIf
    If gnVisMode = #SCS_VU_LEVELS
      setOutputGainYValues(bTrace)
    EndIf
  EndIf
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure drawVUDisplay()
  PROCNAMEC()
  Protected nThisX, nThisY, nThisPeak, nThisX2, nThisWidth, nThisHeight, nOperModeWidth, nOperModeHeight, nOperModeX, nOperModeY, nOperModeBackColor, nOperModeFrontColor
  Protected bLevelFound, sVULevels.s
  Protected qTimeNow.q
  Protected sDevMapName.s, sOperMode.s
  Protected nBPMWidth, nChaseColor, sChaseBPM.s, nTimeBetweenSteps
  Static nBPMHeight, sDevMap.s, sRehearsalMode.s, sPerformanceMode.s, bStaticLoaded
  Protected i, j, nChaseSubPtr
  Protected nBarIndex, nMeterIndex
  Static sLastVULevels.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If StartDrawing(CanvasOutput(WMN\cvsVUDisplay))
    If bStaticLoaded = #False
      nBPMHeight = TextHeight("8")
      sDevMap = Lang("Info", "DevMap") + ": "
      sRehearsalMode = Lang("OperMode", "Rehearsal")
      sPerformanceMode = Lang("OperMode", "Performance")
      bStaticLoaded = #True
    EndIf
    Select gnVisMode
      Case #SCS_VU_LEVELS  ; -------------------------------------------- LEVELS
        Box(0, 0, grMVUD\nSpecWidth, grMVUD\nSpecHeight, #SCS_Black)
        DrawingMode(#PB_2DDrawing_Gradient)
        BackColor(#SCS_Yellow)
        FrontColor(#SCS_Green)
        LinearGradient(0, 0, 0, grMVUD\nSpecHeight)
        For nMeterIndex = 0 To grMVUD\nMaxMeter
          With grMVUD\aMeter(nMeterIndex)
            nThisX = \nMeterX
            nThisY = \nMeterY
            nThisWidth = grMVUD\nMeterWidth-2
            ; draw level
            ; Debug("meterindex" + nMeterIndex + ", x: " + nThisX + ", y: " + nThisY + ", " + ElapsedMilliseconds())
            If nThisY > 0
              ; some level is present, so draw box
              Box(nThisX, (grMVUD\nSpecHeight - nThisY), nThisWidth, nThisY)
              CompilerIf #cTraceVULevels
                sVULevels + Str(nThisY) + " "
                bLevelFound = #True
              CompilerEndIf
            Else
              CompilerIf #cTraceVULevels
                sVULevels + "0 "
              CompilerEndIf
            EndIf
            ; draw peak
            If gnPeakMode <> #SCS_PEAK_NONE
              nThisPeak = \nPeakValue
              If nThisPeak > 0
                nThisY = grMVUD\nSpecHeight - nThisPeak - 1
                ; debugMsg(sProcName, "n=" + n + ", peak Y=" + Str(nThisY))
                LineXY(nThisX, nThisY, (nThisX + nThisWidth - 1), nThisY)
              EndIf
            EndIf
          EndWith
        Next nMeterIndex
        CompilerIf #cTraceVULevels
          If bLevelFound
            If sVULevels <> sLastVULevels
              debugMsg(sProcName, RTrim(sVULevels))
              sLastVULevels = sVULevels
            EndIf
          EndIf
        CompilerEndIf
        
        If grMVUD\bDrawOutputGainMarkers
          ; draw output gain markers
          DrawingMode(#PB_2DDrawing_Default)
          ; FrontColor(#SCS_Light_Grey)
          For nMeterIndex = 0 To grMVUD\nMaxMeter
            With grMVUD\aMeter(nMeterIndex)
              nThisX = \nMeterX
              If \nOutputGainY > 0
                nThisY = grMVUD\nSpecHeight - \nOutputGainY
                ; debugMsg0(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\nOutputGainY=" + \nOutputGainY + ", nThisY=" + nThisY)
                nThisX2 = \nMeterX + nThisWidth
                While nThisX < nThisX2
                  If nThisX < OutputWidth() And nThisY < OutputHeight()
                    Plot(nThisX, nThisY, #SCS_Light_Grey)
                  EndIf
                  nThisX + 2
                Wend
              EndIf
            EndWith
          Next nMeterIndex
        EndIf
        
        If grMTCSendControl\bMTCSendControlActive
          ; debugMsg(sProcName, "grMTCSendControl\bMTCSendControlActive=" + strB(grMTCSendControl\bMTCSendControlActive))
          If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
            ; debugMsg(sProcName, "calling drawMTCSend(#True)")
            drawMTCSend(#True)
          EndIf
        ElseIf grSMS\bLTCRunning
          ; debugMsg(sProcName, "grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\nMTCDispLocn=" + decodeMTCDispLocn(grOperModeOptions(gnOperMode)\nMTCDispLocn))
          If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_VU_METERS
            ; debugMsg(sProcName, "calling drawLTCSend(#True)")
            drawLTCSend(#True)
          EndIf
        ElseIf grMTCControl\bMTCControlActive
          drawMTCReceive(#True)
        EndIf
        
    EndSelect
    
    With grMVUD
      If \bDevMapDisplayed = #False
        ; 12Sep2021 11.8.6ah - changed from displaying Audio Driver to displaying Device Map
        If gnOperMode > #SCS_OPERMODE_DESIGN
          If gnOperMode = #SCS_OPERMODE_REHEARSAL
            sOperMode = " " + sRehearsalMode + " "
            nOperModeBackColor = #SCS_Orange
            nOperModeFrontColor = #SCS_Dark_Grey
          Else
            sOperMode = " " + sPerformanceMode + " "
            nOperModeBackColor = #SCS_Blue
            nOperModeFrontColor = #SCS_White
          EndIf
          nOperModeWidth = TextWidth(sOperMode)
          nOperModeHeight = TextHeight(sOperMode) + 2 ; + 2 for gap between opermode and devmap
        EndIf
        If grMaps\sSelectedDevMapName
          sDevMapName = sDevMap + grMaps\sSelectedDevMapName ; gsSelectedDevMapName
        Else
          sDevMapName = " "
        EndIf
        nThisWidth = TextWidth(sDevMapName)
        nThisHeight = TextHeight(sDevMapName)
        If nOperModeWidth > OutputWidth() Or nThisWidth > OutputWidth()
          \bDevMapDisplayed = #True
        ElseIf (nOperModeHeight + nThisHeight) > OutputHeight()
          \bDevMapDisplayed = #True
        Else
          DrawingMode(#PB_2DDrawing_Transparent)
          If gnOperMode > #SCS_OPERMODE_DESIGN
            nOperModeX = (OutputWidth() - nOperModeWidth) >> 1
            nOperModeY = (OutputHeight() - nOperModeHeight - nThisHeight) >> 1
            ; debugMsg0(sProcName, "OutputHeight()=" + OutputHeight() + ", nOperModeHeight=" + nOperModeHeight + ", nThisHeight=" + nThisHeight + ", nOperModeY=" + nOperModeY)
            Box(nOperModeX, nOperModeY, nOperModeWidth, nOperModeHeight - 2, nOperModeBackColor)
            DrawText(nOperModeX, nOperModeY, sOperMode, nOperModeFrontColor)
            nThisY = nOperModeY + nOperModeHeight
          Else
            nThisY = (OutputHeight() - nThisHeight) >> 1
          EndIf
          nThisX = (OutputWidth() - nThisWidth) >> 1
          DrawText(nThisX, nThisY, sDevMapName, #SCS_White)
          If \bDevMapCurrentlyDisplayed
            If (ElapsedMilliseconds() - \qTimeDevMapDisplayed) > 7500 ; 5000
              \bDevMapDisplayed = #True
            EndIf
          Else
            \qTimeDevMapDisplayed = ElapsedMilliseconds()
            \bDevMapCurrentlyDisplayed = #True
          EndIf
        EndIf
      EndIf
    EndWith
    
    ; the following code flashes a 'chase' indicator in the bottom right of the VU display for when a lightng (or DMX) chase is running
    ; the indicator is flashed briefly at the start of each step in the chase - see the setting of \bDisplayChaseIndicator in DMX_processDMXSendThread()
    With grDMXChaseItems
      If (\bChaseRunning) Or (\nTapTimeBetweenSteps > 0) Or (\nChaseCueCount > 0)
        If (\bChaseRunning) And (\nChaseControl = #SCS_DMX_CHASE_CTL_CUE)
          nChaseColor = #SCS_Yellow
          sChaseBPM = \sCueChaseBPM
          nTimeBetweenSteps = \nCueTimeBetweenSteps
        ElseIf \sTapChaseBPM
          nChaseColor = #SCS_Orange
          sChaseBPM = \sTapChaseBPM
          nTimeBetweenSteps = \nTapTimeBetweenSteps
        Else
          nChaseSubPtr = -1
          If gbEditing
            If (nEditCuePtr >= 0) And (nEditSubPtr >= 0)
              If aSub(nEditSubPtr)\bSubTypeK
                If aSub(nEditSubPtr)\bChase
                  nChaseSubPtr = nEditSubPtr
                EndIf
              EndIf
            EndIf
          EndIf
          If nChaseSubPtr = -1
            If grDMXChaseItems\nChaseCueCount > 0
              For i = gnCueToGo To gnLastCue
                If aCue(i)\bSubTypeK
                  j = aCue(i)\nFirstSubIndex
                  While j >= 0
                    If aSub(j)\bSubTypeK
                      If aSub(j)\bChase
                        nChaseSubPtr = j
                        Break 2
                      EndIf
                    EndIf
                    j = aSub(j)\nNextSubIndex
                  Wend
                EndIf
              Next i
            EndIf
          EndIf
          If nChaseSubPtr >= 0
            If aSub(nChaseSubPtr)\bMonitorTapDelay
              nChaseColor = #SCS_Orange
            Else
              nChaseColor = #SCS_Light_Grey
            EndIf
            sChaseBPM = Str(aSub(nChaseSubPtr)\nChaseSpeed)
            nTimeBetweenSteps = 60000 / aSub(nChaseSubPtr)\nChaseSpeed
          Else
            nChaseColor = #SCS_Light_Grey
            sChaseBPM = \sDefChaseBPM
            nTimeBetweenSteps = \nDefTimeBetweenSteps
          EndIf
        EndIf
        qTimeNow = ElapsedMilliseconds()
        If \bChaseRunning = #False
          If \bDisplayChaseIndicator = #False
            If ((qTimeNow - \qTimeDisplayChaseIndicatorSet) >= nTimeBetweenSteps)
              \bDisplayChaseIndicator = #True
              \qTimeDisplayChaseIndicatorSet = qTimeNow
            EndIf
          EndIf
        EndIf
        If \bDisplayChaseIndicator
          If (qTimeNow - \qTimeDisplayChaseIndicatorSet) > 150
            ; turn off the indicator display for this chase step after 150ms
            \bDisplayChaseIndicator = #False
          Else
            ; draw the chase step indicator
            DrawingMode(#PB_2DDrawing_Default)
            RoundBox(OutputWidth()-20, OutputHeight()-14, 12, 12, 2, 2, nChaseColor)
          EndIf
        EndIf
        nBPMWidth = TextWidth(sChaseBPM)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(OutputWidth()-6-nBPMWidth, OutputHeight()-14-nBPMHeight, sChaseBPM, nChaseColor)
        If \nChaseIndHotLeft = 0
          \nChaseIndHotLeft = OutputWidth() - TextWidth("888") - 8
          \nChaseIndHotTop = OutputHeight() - nBPMHeight - 16
          \nChaseIndHotRight = OutputWidth()
          \nChaseIndHotBottom = OutputHeight()
        EndIf
      EndIf ; EndIf \bChaseRunning
    EndWith
    
    StopDrawing()
  EndIf
  
EndProcedure

Procedure drawTestLiveInputVUDisplay()
  PROCNAMEC()
  Protected n, nThisX, nThisY, nThisPeak, nThisX2, nThisWidth, nThisHeight
  
  If IsGadget(WEP\cvsTestLiveInputVU)
    If StartDrawing(CanvasOutput(WEP\cvsTestLiveInputVU))
      Box(0, 0, 120, 7, #SCS_Black)
      DrawingMode(#PB_2DDrawing_Gradient)
      BackColor(#SCS_Green)
      FrontColor(#SCS_Yellow)
      LinearGradient(0, 0, 120, 0)
      With grTestLiveInputVUMeter
        nThisX = 1
        nThisY = 1
        nThisWidth = \nMeterX - 1
        nThisHeight = 5
        ; draw level
        If nThisWidth > 0
          ; some level is present, so draw box
          Box(nThisX, nThisY, nThisWidth, nThisHeight)
        EndIf
        ; draw peak
        If gnPeakMode <> #SCS_PEAK_NONE
          nThisPeak = grLiveInputTestLvlPeak\nPeakValue
          If nThisPeak > 0
            ; debugMsg(sProcName, "n=" + n + ", peak Y=" + Str(nThisY))
            LineXY(nThisPeak, 1, nThisPeak, nThisHeight)
          EndIf
        EndIf
      EndWith
      StopDrawing()
    EndIf
  EndIf
  
EndProcedure

Procedure clearTestLiveInputVUDisplay()
  PROCNAMEC()
  
  If IsGadget(WEP\cvsTestLiveInputVU)
    If StartDrawing(CanvasOutput(WEP\cvsTestLiveInputVU))
      Box(0, 0, 120, 7, #SCS_Black)
      StopDrawing()
    EndIf
  EndIf
  
EndProcedure

Procedure clearVUDisplay()
  PROCNAMEC()
  Protected nVUBarWidth
  
  debugMsg(sProcName, #SCS_START)
  
  If gbMainFormLoaded = #False
    ProcedureReturn
  EndIf
  
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  
  If gbInOptionsWindow
    gnVisMode = mrOperModeOptions(grWOP\nCurrOperMode)\nVisMode
    gnPeakMode = mrOperModeOptions(grWOP\nCurrOperMode)\nPeakMode
    gnCtrlPanelPos = mrOperModeOptions(grWOP\nCurrOperMode)\nCtrlPanelPos
    nVUBarWidth = mrOperModeOptions(grWOP\nCurrOperMode)\nVUBarWidth
  Else
    gnVisMode = grOperModeOptions(gnOperMode)\nVisMode
    gnPeakMode = grOperModeOptions(gnOperMode)\nPeakMode
    gnCtrlPanelPos = grOperModeOptions(gnOperMode)\nCtrlPanelPos
    nVUBarWidth = grOperModeOptions(gnOperMode)\nVUBarWidth
  EndIf
  
  Select nVUBarWidth
    Case #SCS_VUBARWIDTH_NARROW
      gnReqdMeterWidth = 18
    Case #SCS_VUBARWIDTH_MEDIUM
      gnReqdMeterWidth = 36
    Case #SCS_VUBARWIDTH_WIDE
      gnReqdMeterWidth = 54
  EndSelect
  grMVUD\nMinBarWidth = (gnReqdMeterWidth * 2) + (grMVUD\nMeterGapWithinBar * 2)
  debugMsg(sProcName, "grMVUD\nMeterGapWithinBar=" + grMVUD\nMeterGapWithinBar + ", grMVUD\nMinBarWidth=" + grMVUD\nMinBarWidth +
                      ", gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver) + ", gbUseBASS=" + strB(gbUseBASS) + ", gbUseSMS=" + strB(gbUseSMS))
  If gbUseSMS
    buildVUCommandString()
  EndIf
  
  debugMsg(sProcName, "grMVUD\nSpecWidth=" + grMVUD\nSpecWidth + ", grMVUD\nSpecHeight=" + grMVUD\nSpecHeight + ", gnVisMode=" + decodeVisMode(gnVisMode))
  ReDim specbuf.b(grMVUD\nSpecWidth * (grMVUD\nSpecHeight + 1)) ; clear display
  
  grMVUD\nTriangleColorL = #SCS_White
  grMVUD\nTriangleColorR = #SCS_White
  displayLabels()
  
  debugMsg(sProcName, "gnPeakMode=" + decodePeakMode(gnPeakMode))
  If gnPeakMode <> #SCS_PEAK_HOLD
    resetPeaks(#True)
  EndIf
  
  gbClearVUB4Update = #False
  
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure drawPeaks(bClearBeforeDisplay)
  ; PROCNAMEC()
  Protected nMeterIndex, nThisPeak
  
  If (gnVisMode = #SCS_VU_LEVELS) ; -------------------------------------------- LEVELS
    If bClearBeforeDisplay
      ReDim specbuf(grMVUD\nSpecWidth * (grMVUD\nSpecHeight + 1)) ; clear display
    EndIf
    For nMeterIndex = 0 To grMVUD\nMaxMeter
      With grMVUD\aMeter(nMeterIndex)
        ; display peak
        nThisPeak = \nPeakValue
        If nThisPeak > 0
          FillMemory(@specbuf((nThisPeak * grMVUD\nSpecWidth) + \nMeterX), grMVUD\nBarWidth - 2, nThisPeak + 1)
        EndIf
      EndWith
    Next nMeterIndex
  EndIf
  
EndProcedure

Procedure updateSpectrumBASS()
  CompilerIf #cTraceVULevels
    PROCNAMEC()
  CompilerEndIf
  Protected Y
  Protected m, nOutputChannel.l
  Protected lBassResult.l
  Protected sc
  Protected fSum.f, nChannelLevel
  Protected nMyOutputNr
  Protected qTimeNow.q
  Protected nThisPeak
  Protected fChannelVol.f, fChannelPan.f
  Protected fTmpLevel.f
  Protected nSideLevel
  Protected nDevMapPtr, nDevPtr
  Protected nMyDSPInd
  Protected fOutputGain.f
  Protected nBarIndex, nMeterIndex, nMixerStreamPtr
  Protected nLoWord, nHiWord
  Static nBassAsioErrorLogged

  ; debugMsg(sProcName, #SCS_START + ", gnVisMode=" + decodeVisMode(gnVisMode) + ", gnCtrlPanelPos=" + decodeCtrlPanelPos(gnCtrlPanelPos) +
  ; ", grMVUD\bInBuildDevChannelList=" + strB(grMVUD\bInBuildDevChannelList) + ", grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
  
  If (gnVisMode = #SCS_VU_NONE) Or (gnCtrlPanelPos = #SCS_CTRLPANEL_NONE)
    ProcedureReturn
  EndIf
  
  If grMVUD\bInBuildDevChannelList
    ProcedureReturn
  EndIf
  
  nDevMapPtr = grProd\nSelectedDevMapPtr
  If nDevMapPtr < 0
    ProcedureReturn
  EndIf
  
  If gbClearVUB4Update
    clearVUDisplay()
  EndIf
  
  If (gnVisMode = #SCS_VU_LEVELS) ; -------------------------------------------- LEVELS
    nMyOutputNr = -1
    nDevPtr = grMaps\aMap(nDevMapPtr)\nFirstDevIndex
    While nDevPtr >= 0
      If (grMaps\aDev(nDevPtr)\sLogicalDev) And (grMaps\aDev(nDevPtr)\nReassignDevMapDevPtr = -1) ; And (grMaps\aDev(nDevPtr)\bDevFound)
        nMixerStreamPtr = grMaps\aDev(nDevPtr)\nMixerStreamPtr
        If gbUseBASSMixer
          If nMixerStreamPtr >= 0
            With gaMixerStreams(nMixerStreamPtr)
              If \bASIO
                lBassResult = BASS_ASIO_SetDevice(\nBassASIODevice)
                If lBassResult = #BASSFALSE
                  If nBassAsioErrorLogged = #False
                    debugMsg(sProcName, "Error: " + getBassErrorDesc(BASS_ASIO_ErrorGetCode()))
                    nBassAsioErrorLogged = #True
                  EndIf
                Else
                  For m = 1 To \nMixerChans
                    nMyOutputNr + 1
                    nOutputChannel = \nFirstOutputChannel + m - 1
                    If grMVUD\aMeter(nMyOutputNr)\nDevChannel = nOutputChannel
                      grMVUD\aMeter(nMyOutputNr)\fVULevel = BASS_ASIO_ChannelGetLevel(#BASSFALSE, nOutputChannel)
                      CompilerIf #c_huw_morgan
                        debugMsg(sProcName, "BASS_ASIO_ChannelGetLevel(#BASSFALSE, " + nOutputChannel + ") returned grMVUD\aMeter(" + nMyOutputNr + ")\fVULevel=" + traceLevel(grMVUD\aMeter(nMyOutputNr)\fVULevel))
                      CompilerEndIf
                    EndIf
                  Next m
                EndIf
              Else
                ; debugMsg(sProcName, "gaMixerStreams(" + nMixerStreamPtr + ")\bNoDevice=" + strB(\bNoDevice) + ", \nMixerStreamHandle=" + decodeHandle(\nMixerStreamHandle))
                nOutputChannel = \nMixerStreamHandle
                If \bNoDevice
                  nChannelLevel = 0
                Else
                  nChannelLevel = BASS_ChannelGetLevel(\nMixerStreamHandle)
                EndIf
                nMyOutputNr + 1
                nSideLevel = LOWORD(nChannelLevel)
                If grMVUD\aMeter(nMyOutputNr)\nDevChannel = nOutputChannel
                  nBarIndex = grMVUD\aMeter(nMyOutputNr)\nParentBarIndex
                  grMVUD\aMeter(nMyOutputNr)\fVULevel = nSideLevel * grMVUD\fVolumeFactor * grMVUD\aBar(nBarIndex)\fVUOutputGain
                EndIf
                If \nMixerChans > 1
                  nMyOutputNr + 1
                  nSideLevel = HIWORD(nChannelLevel)
                  ; debugMsg(sProcName, "gaMixerStreams(" + nMixerStreamPtr + ")\nMixerChans=" + \nMixerChans + ", nMyOutputNr=" + nMyOutputNr + ", ArraySize(grMVUD\aMeter())=" + ArraySize(grMVUD\aMeter()))
                  If grMVUD\aMeter(nMyOutputNr)\nDevChannel = nOutputChannel
                    nBarIndex = grMVUD\aMeter(nMyOutputNr)\nParentBarIndex
                    grMVUD\aMeter(nMyOutputNr)\fVULevel = nSideLevel * grMVUD\fVolumeFactor * grMVUD\aBar(nBarIndex)\fVUOutputGain
                  EndIf
                ElseIf grMVUD\aMeter(nMyOutputNr)\fVULevel
                  nSideLevel = HIWORD(nChannelLevel)
                  If grMVUD\aMeter(nMyOutputNr)\nDevChannel = nOutputChannel
                    nBarIndex = grMVUD\aMeter(nMyOutputNr)\nParentBarIndex
                    grMVUD\aMeter(nMyOutputNr)\fVULevel = nSideLevel * grMVUD\fVolumeFactor * grMVUD\aBar(nBarIndex)\fVUOutputGain
                  EndIf
                EndIf
              EndIf
            EndWith
          EndIf
          
        Else  ; gbUseBASSMixer = #False
          With grMaps\aDev(nDevPtr)
            If \nBassDevice > 0 ; ignores 0 (no sound) and -1 (unassigned)
              nMyOutputNr + 1
              grMVUD\aMeter(nMyOutputNr)\fVULevel = 0
              If \nNrOfDevOutputChans > 1
                grMVUD\aMeter(nMyOutputNr+1)\fVULevel = 0
              EndIf
              For m = 0 To \nDevChannelCount - 1 ; nb there may be several \nDevChannel's per meter if several cues are playing
                nMyDSPInd = \nDSPInd[m]
                nOutputChannel = \nDevChannel[m]
                nChannelLevel = BASS_ChannelGetLevel(nOutputChannel) ; BASS_ChannelGetLevel() returns channel's level in the range 0 (silent) to 32768 (max)
                If nChannelLevel > 0
                  lBassResult = BASS_ChannelGetAttribute(nOutputChannel, #BASS_ATTRIB_VOL, @fChannelVol)
                  lBassResult = BASS_ChannelGetAttribute(nOutputChannel, #BASS_ATTRIB_PAN, @fChannelPan)
                  If nMyDSPInd = #SCS_DSP_RIGHT
                    nSideLevel = HIWORD(nChannelLevel)
                  Else
                    nSideLevel = LOWORD(nChannelLevel)
                  EndIf
                  fTmpLevel = (nSideLevel * grMVUD\fVolumeFactor * fChannelVol)
                  If fChannelPan > 0
                    ; panned to the right, so reduce left level
                    fTmpLevel * (1 - fChannelPan)
                  EndIf
                  grMVUD\aMeter(nMyOutputNr)\fVULevel + fTmpLevel
                  CompilerIf #cTraceVULevels
                    debugMsg(sProcName, "grMVUD\aMeter(" + nMyOutputNr + ")\fVULevel=" + traceLevel(grMVUD\aMeter(nMyOutputNr)\fVULevel) + ", nOutputChannel=" + decodeHandle(nOutputChannel))
                  CompilerEndIf
                  If grMVUD\aMeter(nMyOutputNr)\fVULevel > 32768 ; 32768 is the max value returned by BASS_ChannelGetLevel()
                    grMVUD\aMeter(nMyOutputNr)\fVULevel = 32768
                  EndIf
                  If \nNrOfDevOutputChans > 1
                    nSideLevel = HIWORD(nChannelLevel)
                    fTmpLevel = (nSideLevel * grMVUD\fVolumeFactor * fChannelVol)
                    If fChannelPan < 0
                      ; panned to the left, so reduce right level
                      fTmpLevel * (1 - (fChannelPan * -1))
                    EndIf
                    grMVUD\aMeter(nMyOutputNr+1)\fVULevel + fTmpLevel
                    If grMVUD\aMeter(nMyOutputNr+1)\fVULevel > 32768
                      grMVUD\aMeter(nMyOutputNr+1)\fVULevel = 32768
                    EndIf
                  EndIf
                EndIf
              Next m
              If \nNrOfDevOutputChans > 1
                nMyOutputNr + 1
              EndIf
            EndIf
          EndWith
        EndIf
      EndIf
      nDevPtr = grMaps\aDev(nDevPtr)\nNextDevIndex
    Wend
    
    sc = 10
    qTimeNow = ElapsedMilliseconds()
    For nMeterIndex = 0 To grMVUD\nMaxMeter
      ; debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\nDevType=" + decodeDevType(grMVUD\aMeter(nMeterIndex)\nDevType))
      If grMVUD\aMeter(nMeterIndex)\nDevType <> #SCS_DEVTYPE_VIDEO_AUDIO
        ; debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + StrF(grMVUD\aMeter(nMeterIndex)\fVULevel,4))
        fSum = grMVUD\aMeter(nMeterIndex)\fVULevel
        Y = (Sqr(fSum / Log10(sc)) * grMVUD\nSpecHeight) ; scale it
        CompilerIf #c_huw_morgan
          If gnPlayingAudTypeForPPtr >= 0
            debugMsg(sProcName, "nMeterIndex=" + nMeterIndex + ", fSum=" + StrF(fSum,4) + ", sc=" + sc + ", Log10(sc)=" + StrF(Log10(sc),4) + ", grMVUD\nSpecHeight=" + grMVUD\nSpecHeight + ", Y=" + Y)
          EndIf
        CompilerEndIf
        If Y > grMVUD\nSpecHeight
          Y = grMVUD\nSpecHeight ; cap it
        EndIf
      If Y > grMVUD\nSpecHeight
        Y = grMVUD\nSpecHeight ; cap it
      EndIf
      If Y > 1
        Y - 1 ; Subtract 1 as valid range is 0 to (nSpecHeight - 1),
              ; but do NOT subtract 1 if Y is currently only 1, so that we show something in the VU meter bar for this VU level
      ElseIf Y < 0
        Y = 0
      EndIf
      grMVUD\aMeter(nMeterIndex)\nMeterY = Y
;         If fSum > 0
;           ; debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + StrF(fSum,4) + " (" + traceLevel(fSum) + "), \nMeterY=" + Y)
;           debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + traceLevel(fSum) + ", \nMeterY=" + Y)
;         EndIf
        grMVUD\aMeter(nMeterIndex)\nMeterY = Y
        CompilerIf #cTraceVULevels
          If fSum > 0
            ; debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + StrF(fSum,4) + " (" + traceLevel(fSum) + "), \nMeterY=" + Y)
            debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + traceLevel(fSum) + ", \nMeterY=" + Y)
          EndIf
        CompilerEndIf
        
        ; added 17Nov2018 11.8.0ay to enable tracing of peak VU meter values - designed to enable log to show if no audio
        If gnPlayingAudTypeForPPtr >= 0
          If Y > gnPeakVU
            gnPeakVU = Y
            ; debugMsg(sProcName, "gnPeakVU=" + gnPeakVU)
          EndIf
        EndIf
        ; end added 17Nov2018 11.8.0ay
        
        If gnPeakMode <> #SCS_PEAK_NONE
          nThisPeak = grMVUD\aMeter(nMeterIndex)\nPeakValue
          If Y > nThisPeak
            ; new peak
            nThisPeak = Y
            grMVUD\aMeter(nMeterIndex)\nPeakValue = Y
            ; debugMsg(sProcName, "gaLvlPeak(" + Y + ")\nPeakValue=" + Str(grMVUD\aMeter(nMeterIndex)\nPeakValue))
            grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
          ElseIf (gnPeakMode = #SCS_PEAK_AUTO) And ((qTimeNow - grMVUD\aMeter(nMeterIndex)\qPeakTime) >= 1000)
            ; previous peak more than 1 second ago so set new peak (if in auto mode)
            nThisPeak = Y
            grMVUD\aMeter(nMeterIndex)\nPeakValue = Y
            grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
          Else
            ; previous peak less than 1 second ago, or peak hold requested, so continue to display that peak
          EndIf
        EndIf
      EndIf
    Next nMeterIndex
    
    ;drawVUDisplay()
    
  EndIf
  
EndProcedure

Procedure updateSpectrumSMS()
  PROCNAMEC()
  Protected sVUResponse.s, sVUItem.s, sVUAveAndPeak.s
  Protected nVUAve, nVUPeak
  Protected X, Y, X1, Y1
  Protected nMaxX
  Protected m, nOutputChannel.l
  Protected fLeftPeak.f, fRightPeak.f
  Protected sc
  Protected fSum.f, nChannelLevel
  Protected nMyOutputNr
  Protected qTimeNow.q
  Protected nThisPeak
  Protected fChannelVol.f, fChannelPan.f
  Protected fTmpLevel.f
  Protected nSideLevel
  Protected nTmpPeak
  Protected bWantVUMeters = #True
  Protected nBarIndex, nMeterIndex, nStringFieldNr
  
  If (gnVisMode = #SCS_VU_NONE) Or (gnCtrlPanelPos = #SCS_CTRLPANEL_NONE)
    If grTestLiveInput\bRunningTestLiveInput = #False
      ProcedureReturn
    EndIf
    bWantVUMeters = #False
  EndIf
  
  If grMVUD\bInBuildDevChannelList
    ProcedureReturn
  EndIf
  
  If gbClearVUB4Update
    clearVUDisplay()
  EndIf
  
  qTimeNow = ElapsedMilliseconds()
  
  If (gnVisMode = #SCS_VU_LEVELS) ; -------------------------------------------- LEVELS
    If bWantVUMeters
      If Len(grSMS\sOVUResponse) > 3
        sVUResponse = Mid(grSMS\sOVUResponse, 4)
        For nMeterIndex = 0 To grMVUD\nMaxMeter
          nStringFieldNr = nMeterIndex + 1
          sVUItem = StringField(sVUResponse, nStringFieldNr, " ")
          sVUAveAndPeak = StringField(sVUItem, 2, "=")
          nTmpPeak = Val(StringField(sVUAveAndPeak, 2, ":"))
          If nTmpPeak <= 2
            nTmpPeak = 0
          EndIf
          grMVUD\aMeter(nMeterIndex)\nSMSVUPeak = nTmpPeak
        Next nMeterIndex
      EndIf
      
      For nMeterIndex = 0 To grMVUD\nMaxMeter
        nVUPeak = grMVUD\aMeter(nMeterIndex)\nSMSVUPeak
        Y = Round(grMVUD\nSpecHeight * nVUPeak / 255, #PB_Round_Nearest) - 1
        If (Y > grMVUD\nSpecHeight)
          Y = grMVUD\nSpecHeight ; cap it
        EndIf
        grMVUD\aMeter(nMeterIndex)\nMeterY = Y
        CompilerIf #cTraceVULevels And 1=2
          debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + traceLevel(grMVUD\aMeter(nMeterIndex)\fVULevel) + ", \nMeterY=" + grMVUD\aMeter(nMeterIndex)\nMeterY)
        CompilerEndIf
        
        If gnPeakMode <> #SCS_PEAK_NONE
          Y1 = Y
          nThisPeak = grMVUD\aMeter(nMeterIndex)\nPeakValue
          If Y1 > nThisPeak
            ; new peak
            nThisPeak = Y1
            grMVUD\aMeter(nMeterIndex)\nPeakValue = Y1
            grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
          ElseIf gnPeakMode = #SCS_PEAK_AUTO
            If (qTimeNow - grMVUD\aMeter(nMeterIndex)\qPeakTime) > 2000
              ; previous peak more than 2 seconds ago so set new peak (if in auto mode)
              nThisPeak = Y1
              grMVUD\aMeter(nMeterIndex)\nPeakValue = Y1
              grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
            EndIf
          EndIf
        EndIf
        
      Next nMeterIndex
      
      ;drawVUDisplay()
      
    EndIf
  EndIf
  
  ; nb the following 'test live input' code uses X and \nMeterX, not Y and \nMeterY because the 'meter' that displays the level of the live input test is horizontal.
  ; this 'meter' is in Production Properties / Devices / Live Inputs and on the 'Test' tab.
  If grTestLiveInput\bRunningTestLiveInput
    ; debugMsg(sProcName, "grTestLiveInput\bRunningTestLiveInput=" + strB(grTestLiveInput\bRunningTestLiveInput) + ", gnVUMeters=" + gnVUMeters + ", sVUResponse=" + #DQUOTE$ + sVUResponse + #DQUOTE$)
    If gnVUInputMeters > 0
      nStringFieldNr = gnVUMeters + 1   ; input VU reading immediately follows last output VU reading
      sVUItem = StringField(sVUResponse, nStringFieldNr, " ")
      sVUAveAndPeak = StringField(sVUItem, 2, "=")
      nVUPeak = Val(StringField(sVUAveAndPeak, 2, ":"))
      If nVUPeak <= 2
        nVUPeak = 0
      EndIf
      If nVUPeak <> grTestLiveInputVUMeter\nSMSVUPeak
        grTestLiveInputVUMeter\nSMSVUPeak = nVUPeak
        
        X = Round(120 * nVUPeak / 255, #PB_Round_Nearest) - 1
        If (X > 120)
          X = 120 ; cap it
        EndIf
        grTestLiveInputVUMeter\nMeterX = X
        
        nThisPeak = grLiveInputTestLvlPeak\nPeakValue
        If (qTimeNow - grLiveInputTestLvlPeak\qPeakTime) > 2000
          ; previous peak more than 1 second ago so set new peak (if in auto mode)
          grLiveInputTestLvlPeak\nPeakValue = X
          grLiveInputTestLvlPeak\qPeakTime= qTimeNow
        EndIf
        
        ; debugMsg(sProcName, "sVUItem=" + sVUItem + ", grTestLiveInputVUMeter\nSMSVUPeak=" + Str(grTestLiveInputVUMeter\nSMSVUPeak) + ", grTestLiveInputVUMeter\nBarX=" + Str(grTestLiveInputVUMeter\nBarX) + ".")
        drawTestLiveInputVUDisplay()
        
      EndIf
      
    EndIf
  EndIf
  
EndProcedure

Procedure updateSpectrumTVG()
  PROCNAMEC()
  Protected bWantVUMeters = #True, n, nDevPtr
  Protected qTimeNow.q, nMeterIndex, Y, nThisPeak, nSide, nVideoLevel, nVideoPan
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START)
  
  If (gnVisMode = #SCS_VU_NONE) Or (gnCtrlPanelPos = #SCS_CTRLPANEL_NONE)
    bWantVUMeters = #False
  EndIf
  
  If grMVUD\bInBuildDevChannelList
    ProcedureReturn
  EndIf
  
  If gbClearVUB4Update
    clearVUDisplay()
  EndIf
  
  qTimeNow = ElapsedMilliseconds()
    
  If gnVisMode = #SCS_VU_LEVELS ; -------------------------------------------- LEVELS
    debugMsgC(sProcName, "bWantVUMeters=" + strB(bWantVUMeters) + ", grTVGControl\nMaxAudioDev=" + grTVGControl\nMaxAudioDev)
    If bWantVUMeters
      For n = 0 To grTVGControl\nMaxAudioDev
        debugMsgC(sProcName, "grTVGControl\aAudioDev(" + n + ")\nVideoAudioDevPtr=" + grTVGControl\aAudioDev(n)\nVideoAudioDevPtr)
        nDevPtr = grTVGControl\aAudioDev(n)\nVideoAudioDevPtr
        If nDevPtr >= 0
          ; debugMsgC(sProcName, "grMaps\aDev(" + nDevPtr + ")\nVideoLevel=" + grMaps\aDev(nDevPtr)\nVideoLevel + ", \nVideoPan=" + grMaps\aDev(nDevPtr)\nVideoPan)
          nVideoLevel = grMaps\aDev(nDevPtr)\nVideoLevel ; \nVideoLevel set in eventTVGOnAudioPeak() from TVG_GetAudioVolume(), where AudioVolume is in the range 0 (minimum) to 65535 (maximum)
          nVideoPan = grMaps\aDev(nDevPtr)\nVideoPan     ; \nVideoPan set in eventTVGOnAudioPeak() from TVG_GetAudioBalance(), where AudioBalance is in the ranmge -32767 to 32767, 0 is centre
          debugMsgC(sProcName, "grTVGControl\aAudioDev(" + n + ")\nFirstMeterIndex=" + grTVGControl\aAudioDev(n)\nFirstMeterIndex)
          nMeterIndex = grTVGControl\aAudioDev(n)\nFirstMeterIndex
          If nMeterIndex >= 0 ; nb may be -1 if not yet assigned (as found in a test of Lluís Vilarrasa's cue file before any video/image files had been assigned)
            debugMsgC(sProcName, "grMVUD\nSpecHeight=" + grMVUD\nSpecHeight + ", nVideoLevel=" + nVideoLevel + ", nVideoPan=" + nVideoPan +
                                 ", grMaps\aDev(" + nDevPtr + ")\dAudioPeakLeftPercent=" + StrD(grMaps\aDev(nDevPtr)\dAudioPeakLeftPercent,4) +
                                 ", \dAudioPeakRightPercent=" + StrD(grMaps\aDev(nDevPtr)\dAudioPeakRightPercent,4))
            For nSide = 0 To 1 ; 0 = left channel, 1 = right channel
              If nSide = 0
                ; VU meter for left channel
                If nVideoPan > 0
                  ; pan right so decrease VU value of left channel
                  Y = grMVUD\nSpecHeight * grMaps\aDev(nDevPtr)\dAudioPeakLeftPercent / 100 * nVideoLevel / 65535 * (32767 - nVideoPan) / 32767
                Else
                  ; pan centre or left
                  Y = grMVUD\nSpecHeight * grMaps\aDev(nDevPtr)\dAudioPeakLeftPercent / 100 * nVideoLevel / 65535
                EndIf
              Else
                ; VU meter for right channel
                If nVideoPan < 0
                  ; pan left so decrease VU value of right channel
                  Y = grMVUD\nSpecHeight * grMaps\aDev(nDevPtr)\dAudioPeakRightPercent / 100 * nVideoLevel / 65535 * (32767 + nVideoPan) / 32767
                Else
                  ; pan centre or right
                  Y = grMVUD\nSpecHeight * grMaps\aDev(nDevPtr)\dAudioPeakRightPercent / 100 * nVideoLevel / 65535
                EndIf
              EndIf
              grMVUD\aMeter(nMeterIndex)\nMeterY = Y
              CompilerIf #cTraceVULevels
                debugMsg(sProcName, "grMVUD\aMeter(" + nMeterIndex + ")\fVULevel=" + traceLevel(grMVUD\aMeter(nMeterIndex)\fVULevel) + ", \nMeterY=" + grMVUD\aMeter(nMeterIndex)\nMeterY)
              CompilerEndIf
              If gnPeakMode <> #SCS_PEAK_NONE
                nThisPeak = grMVUD\aMeter(nMeterIndex)\nPeakValue
                If Y > nThisPeak
                  ; new peak
                  nThisPeak = Y
                  grMVUD\aMeter(nMeterIndex)\nPeakValue = Y
                  ; debugMsg(sProcName, "gaLvlPeak(" + Y + ")\nPeakValue=" + Str(grMVUD\aMeter(nMeterIndex)\nPeakValue))
                  grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
                ElseIf (gnPeakMode = #SCS_PEAK_AUTO) And ((qTimeNow - grMVUD\aMeter(nMeterIndex)\qPeakTime) >= 1000)
                  ; previous peak more than 1 second ago so set new peak (if in auto mode)
                  nThisPeak = Y
                  grMVUD\aMeter(nMeterIndex)\nPeakValue = Y
                  grMVUD\aMeter(nMeterIndex)\qPeakTime = qTimeNow
                Else
                  ; previous peak less than 1 second ago, or peak hold requested, so continue to display that peak
                EndIf
              EndIf
              nMeterIndex + 1
            Next nSide
          EndIf ; EndIf nMeterIndex >= 0
        EndIf ; EndIf nDevPtr >= 0
      Next n
    EndIf ; EndIf bWantVUMeters
  EndIf ; EndIf gnVisMode = #SCS_VU_LEVELS
  
EndProcedure

Procedure startVUDisplayIfReqd(bDisplayLabels = #False)
  PROCNAMEC()

  ; debugMsg(sProcName, #SCS_START + ", bDisplayLabels=" + strB(bDisplayLabels))
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_START_VU_DISPLAY, bDisplayLabels)
    ProcedureReturn
  EndIf

  If bDisplayLabels
    ; debugMsg(sProcName, "gnVisMode=" + decodeVisMode(gnVisMode))
    If gnVisMode <> #SCS_VU_NONE
      ; debugMsg(sProcName, "calling displayLabels()")
      displayLabels()
    EndIf
  EndIf

  If (gnVisMode <> #SCS_VU_NONE) And (gnCtrlPanelPos <> #SCS_CTRLPANEL_NONE)
    gbVUDisplayRunning = #True
  Else
    gbVUDisplayRunning = #False
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure stopVUDisplayIfReqd()
  PROCNAMEC()

  debugMsg(sProcName, #SCS_START)

  If gbVUDisplayRunning
    If (gnVisMode <> #SCS_VU_NONE) And (gnCtrlPanelPos <> #SCS_CTRLPANEL_NONE)
      gbVUDisplayRunning = #False
      debugMsg(sProcName, "calling clearVUDisplay")
      clearVUDisplay()
    EndIf
  EndIf

EndProcedure

Procedure triangleHot(X, Y)
  Protected nHot, nColorL, nColorR, bChanged

  If grMVUD\bDisplayTriangles = #False
    ProcedureReturn 0
  EndIf

  nColorL = #SCS_White
  nColorR = #SCS_White
  If (Y < (grMVUD\nTriangleYPosL)) And (Y >= (grMVUD\nTriangleYPosL - grMVUD\nTriangleHeight))
    If (X >= 0) And (X <= grMVUD\nTriangleXPosL)
      nHot = 1
      nColorL = #SCS_Yellow
    ElseIf (X <= grMVUD\nSpecWidth) And (X >= grMVUD\nTriangleXPosR)
      nHot = 2
      nColorR = #SCS_Yellow
    EndIf
  EndIf
  If nColorL <> grMVUD\nTriangleColorL
    bChanged = #True
    grMVUD\nTriangleColorL = nColorL
  EndIf
  If nColorR <> grMVUD\nTriangleColorR
    bChanged = #True
    grMVUD\nTriangleColorR = nColorR
  EndIf
  If bChanged
    displayLabels()
  EndIf
  ProcedureReturn nHot
EndProcedure

Procedure chaseSpeedHot(X, Y)
  PROCNAMEC()
  Protected bDisplayTooltip
  Protected sShortCutStr.s
  Static sTapTooltip.s, bStaticLoaded
  Static sCurrTapTooltip.s
  
  If bStaticLoaded = #False
    sShortCutStr = gaShortcutsMain(#SCS_ShortMain_TapDelay)\sShortcutStr
    sTapTooltip = LangPars("DMX", "TapTT", sShortCutStr)
    bStaticLoaded = #True
  EndIf
  
  With grDMXChaseItems
    If \bMonitorTapDelay
      If (X < \nChaseIndHotLeft) Or (X > \nChaseIndHotRight) Or (Y < \nChaseIndHotTop) Or (Y > \nChaseIndHotBottom)
        bDisplayTooltip = #False
      Else
        bDisplayTooltip = #True
      EndIf
    EndIf
    If bDisplayTooltip
      If Len(sCurrTapTooltip) = 0
        sCurrTapTooltip = sTapTooltip
        GadgetToolTip(WMN\cvsVUDisplay, sCurrTapTooltip)
      EndIf
    Else
      If sCurrTapTooltip
        sCurrTapTooltip = ""
        GadgetToolTip(WMN\cvsVUDisplay, sCurrTapTooltip)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure setVolumeFactor()
  PROCNAMEC()
  Protected nBassMasterVolume

  If gbUseBASS
    nBassMasterVolume = BASS_GetConfig(#BASS_CONFIG_GVOL_STREAM)
    If nBassMasterVolume = -1
      nBassMasterVolume = 10000
    EndIf
    grMVUD\fVolumeFactor = (nBassMasterVolume / 10000) / 32768
  Else ; SM-S
    ; no action
  EndIf
  
EndProcedure

Procedure monitorVU(qTimeNow.q)
  PROCNAMEC()
  Protected nDurationOfCheck = 4000 ; check info during first 4 seconds only
  Protected nDelayBetweenChecks = 250 ; 250ms between checks - approx because of low thread priority, and delay time in thread loop
  Static nPlayingAudTypeFPtr, qTimeAudStarted.q, sAudLabel.s
  Static qTimeOfLastCheck.q
  
  ; check VU meters and progress slider active when expected to be
  If gnPlayingAudTypeForPPtr >= 0
    If nPlayingAudTypeFPtr <> gnPlayingAudTypeForPPtr ; static variable nPlayingAudTypeFPtr used to optimise obtaining fields that only need to obtained once on a new setting of gnPlayingAudTypeForPPtr
      With aAud(gnPlayingAudTypeForPPtr)
        If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
          qTimeAudStarted = \qTimeAudStarted
          qTimeOfLastCheck = qTimeAudStarted - 100
          gnPeakVU = 0
          ; debugMsg(sProcName, "gnPeakVU=" + gnPeakVU)
          sAudLabel = getAudLabel(gnPlayingAudTypeForPPtr)
        Else
          gnPlayingAudTypeForPPtr = -1
          debugMsg(sProcName, "gnPlayingAudTypeForPPtr=" + getAudLabel(gnPlayingAudTypeForPPtr))
        EndIf
      EndWith
      nPlayingAudTypeFPtr = gnPlayingAudTypeForPPtr
      ; debugMsg(sProcName, "nPlayingAudTypeFPtr=" + getAudLabel(nPlayingAudTypeFPtr))
    EndIf
    If gnPlayingAudTypeForPPtr >= 0
      If (qTimeNow - qTimeAudStarted) >= nDurationOfCheck
        gnPlayingAudTypeForPPtr = -1 ; end of duration of check, so set this to -1 to ignore further checking
        ; debugMsg(sProcName, "gnPlayingAudTypeForPPtr=" + getAudLabel(gnPlayingAudTypeForPPtr))
        nPlayingAudTypeFPtr = gnPlayingAudTypeForPPtr ; set the static variable as well
        ; debugMsg(sProcName, "nPlayingAudTypeFPtr=" + getAudLabel(nPlayingAudTypeFPtr))
      Else
        If (qTimeNow - qTimeOfLastCheck) >= nDelayBetweenChecks
          ; perform check
          ; debugMsg(sProcName, sAudLabel + ", VU Peak: " + gnPeakVU + ", \nRelFilePos=" + aAud(gnPlayingAudTypeForPPtr)\nRelFilePos)
          gnPeakVU = 0 ; reset peak VU (see comment against "Global gnPeakVU"
          ; debugMsg(sProcName, "gnPeakVU=" + gnPeakVU)
          qTimeOfLastCheck = qTimeNow
        EndIf
      EndIf
    EndIf
  EndIf
  
EndProcedure

; EOF