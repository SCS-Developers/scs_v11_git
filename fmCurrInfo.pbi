; File: fmCurrInfo.pbi

EnableExplicit

Procedure WCI_calcAggregateTimes()
  PROCNAMEC()
  Protected rAggregateTimes.tyAggregateTimes
  Protected i
  Protected nCueLength
  
  grAggregateTimes = rAggregateTimes  ; clear existing values
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      If (aCue(i)\bHotkey = #False) And (aCue(i)\bExtAct = #False)
        nCueLength = getCueLength(i)
        If nCueLength > 0
          With grAggregateTimes\rProdAggregate
            If aCue(i)\bSubTypeF
              \nCuesWithAudioFileSubCues + nCueLength
            EndIf
            If aCue(i)\bSubTypeAorF
              \nCuesWithAudioFileAndOrVideoImageSubCues + nCueLength
            EndIf
            If aCue(i)\bSubTypeAorF Or aCue(i)\bSubTypeP
              \nCuesWithAudioFileAndOrVideoImageAndOrPlaylistSubCues + nCueLength
            EndIf
          EndWith
          If aCue(i)\nCueState <= #SCS_CUE_FADING_OUT
            With grAggregateTimes\rNonCompleteAggregate
              If aCue(i)\bSubTypeF
                \nCuesWithAudioFileSubCues + nCueLength
              EndIf
              If aCue(i)\bSubTypeAorF
                \nCuesWithAudioFileAndOrVideoImageSubCues + nCueLength
              EndIf
              If aCue(i)\bSubTypeAorF Or aCue(i)\bSubTypeP
                \nCuesWithAudioFileAndOrVideoImageAndOrPlaylistSubCues + nCueLength
              EndIf
            EndWith
          EndIf
        EndIf
      EndIf
    EndIf
  Next i
  
EndProcedure

Procedure WCI_drawTextArray(X, Y, Array asLeft.s(1), Array asRight.s(1), nMaxIndex, nLineHeight)
  PROCNAMEC()
  Protected nTextWidth, nMaxWidthLeft, nMaxWidthRight, nMaxLineLength
  Protected n
  Protected nRightX, nLineY
  
  For n = 0 To nMaxIndex
    nTextWidth = TextWidth(asLeft(n))
    If nTextWidth > nMaxWidthLeft
      nMaxWidthLeft = nTextWidth
    EndIf
    nTextWidth = TextWidth(asRight(n))
    If nTextWidth > nMaxWidthRight
      nMaxWidthRight = nTextWidth
    EndIf
  Next n
  nRightX = X + nMaxWidthLeft + TextWidth("WW")
  nLineY = Y
  For n = 0 To nMaxIndex
    DrawText(X, nLineY, asLeft(n), #scs_black, #SCS_Yellow)
    DrawText(nRightX, nLineY, asRight(n))
    nLineY + nLineHeight
  Next n
  nMaxLineLength = nRightX + nMaxWidthRight
  ProcedureReturn nMaxLineLength
EndProcedure

Procedure WCI_displayCurrInfo()
  PROCNAMEC()
  Protected nLineY, nLineHeight, nArrayMaxLineWidth, nMaxLineWidth
  Protected nIPAddr
  Protected n, nIndex, nPass
  Protected nBtnLeft, nBtnTop, nWindowHeight, nWindowWidth
  Protected Dim asLeft.s(20), Dim asRight.s(20)
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WCI) = #False
    createfmCurrInfo()
  EndIf
  
  ; NOTE: modified 10Jun2019 11.8.1.2ac to use 2 passes.
  ; It appears that 'ResizeGadget(\cvsCurrInfo,...) destroys the already-processed drawing, which resulted in a blank 'current information' screen.
  ; The easiest solution was to use 2 passes, so the first pass calculates the required size and resizes the canvas and window, and the second pass
  ; repeats all the processing but skips the resizing code.
  nMaxLineWidth = 450
  For nPass = 1 To 2
    nLineY = 0
    If StartDrawing(CanvasOutput(WCI\cvsCurrInfo))
      Box(0,0,OutputWidth(),OutputHeight(),glSysCol3DFace)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
      DrawingMode(#PB_2DDrawing_Transparent)
      FrontColor(#SCS_Black)
      nLineHeight = TextHeight("Wg") + 2
      
      asLeft(0) = Lang("Info", "CueFile") : asRight(0) = gsCueFile
      asLeft(1) = Lang("Info", "ProdTitle") : asRight(1) = grProd\sTitle
      asLeft(2) = Lang("Info", "DevMap") : asRight(2) = grProd\sSelectedDevMapName
      asLeft(3) = Lang("Info", "AudioDriver") : asRight(3) = decodeDriverL(gnCurrAudioDriver)
      asLeft(4) = Lang("Info", "VideoLibrary") : asRight(4) = decodeVideoPlaybackLibraryL(grVideoDriver\nVideoPlaybackLibrary)
      asLeft(5) = Lang("Info", "OperMode") : asRight(5) = Lang("OperMode", decodeOperMode(gnOperMode))
      nIndex = 5
      
      ExamineIPAddresses() 
      Repeat
        nIPAddr = NextIPAddress()
        If nIPAddr = 0
          Break
        EndIf
        nIndex + 1
        asLeft(nIndex) = Lang("Network", "IPAddr") : asRight(nIndex) = IPString(nIPAddr)
      ForEver
      
      nArrayMaxLineWidth = WCI_drawTextArray(0, nLineY, asLeft(), asRight(), nIndex, nLineHeight)
      If nArrayMaxLineWidth > nMaxLineWidth
        nMaxLineWidth = nArrayMaxLineWidth
      EndIf
      nLineY + (nLineHeight * (nIndex + 1))
      
      WCI_calcAggregateTimes()
      
      With grAggregateTimes\rProdAggregate
        nLineY + nLineHeight
        scsDrawingFont(#SCS_FONT_GEN_UL10)
        DrawText(0, nLineY, Lang("Info", "AgTimes"))
        scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
        nLineY + nLineHeight
        asLeft(0) = Lang("Info", "CuesF") : asRight(0) = timeToStringHHMMSS(\nCuesWithAudioFileSubCues)
        asLeft(1) = Lang("Info", "CuesAF") : asRight(1) = timeToStringHHMMSS(\nCuesWithAudioFileAndOrVideoImageSubCues)
        asLeft(2) = Lang("Info", "CuesAFP") : asRight(2) = timeToStringHHMMSS(\nCuesWithAudioFileAndOrVideoImageAndOrPlaylistSubCues)
        nArrayMaxLineWidth = WCI_drawTextArray(0, nLineY, asLeft(), asRight(), 2, nLineHeight)
        If nArrayMaxLineWidth > nMaxLineWidth
          nMaxLineWidth = nArrayMaxLineWidth
        EndIf
        nLineY + (nLineHeight * 3)
      EndWith
      
      With grAggregateTimes\rNonCompleteAggregate
        nLineY + nLineHeight
        scsDrawingFont(#SCS_FONT_GEN_UL10)
        DrawText(0, nLineY, Lang("Info", "AgNonComp"))
        scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
        nLineY + nLineHeight
        asLeft(0) = Lang("Info", "CuesF") : asRight(0) = timeToStringHHMMSS(\nCuesWithAudioFileSubCues)
        asLeft(1) = Lang("Info", "CuesAF") : asRight(1) = timeToStringHHMMSS(\nCuesWithAudioFileAndOrVideoImageSubCues)
        asLeft(2) = Lang("Info", "CuesAFP") : asRight(2) = timeToStringHHMMSS(\nCuesWithAudioFileAndOrVideoImageAndOrPlaylistSubCues)
        nArrayMaxLineWidth = WCI_drawTextArray(0, nLineY, asLeft(), asRight(), 2, nLineHeight)
        If nArrayMaxLineWidth > nMaxLineWidth
          nMaxLineWidth = nArrayMaxLineWidth
        EndIf
        nLineY + (nLineHeight * 3)
      EndWith
      StopDrawing()
    EndIf
    
    If nPass = 1
      With WCI
        ResizeGadget(\cvsCurrInfo, #PB_Ignore, #PB_Ignore, nMaxLineWidth, nLineY)
        nWindowWidth = GadgetWidth(\cvsCurrInfo) + (GadgetX(\cvsCurrInfo) * 2)
        nBtnLeft = nWindowWidth - 120
        nBtnTop = GadgetY(\cvsCurrInfo) + GadgetHeight(\cvsCurrInfo) + 8
        ResizeGadget(\btnOK, nBtnLeft, nBtnTop, #PB_Ignore, #PB_Ignore)
        nWindowHeight = nBtnTop + GadgetHeight(\btnOK) + 12
        ResizeWindow(#WCI, #PB_Ignore, #PB_Ignore, nWindowWidth, nWindowHeight)
      EndWith
    EndIf
    
  Next nPass
  setWindowVisible(#WCI, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCI_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling scsCloseWindow(#WCI)")
  scsCloseWindow(#WCI)
  
EndProcedure

Procedure WCI_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WCI) = #False
    createfmCurrInfo()
  EndIf
  setWindowVisible(#WCI, #True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCI_EventHandler()
  PROCNAMEC()
  
  With WCI
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WCI_Form_Unload()
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + Str(gnEventGadgetNo))
        Select gnEventGadgetNoForEvHdlr
          Case \btnOK
            WCI_Form_Unload()
            
          Case \cvsCurrInfo
            ; no action
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF
