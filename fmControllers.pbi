; File: fmControllers.pbi

EnableExplicit

Procedure WCN_initControllers()
  PROCNAMEC()
  Protected nIndex
  Protected d2
  Protected sLogicalDev.s
  Protected nCtrlNo
  Protected d3, d4, n, n2, nReqdFixtureCount, sFixtureCode.s, sFixTypeName.s, nDimmerChannelCount, nDevDMXStartChannel, nFirstDimmerChannel, nDevMapDevPtr ; Added 11Jul2022 11.9.4
  Protected nDMXControlPtr, nDMXSendDataBaseIndex
  Protected bAudioFadersRequired, bVideoFadersRequired
  Protected i, j
  
  debugMsg(sProcName, #SCS_START)
  
  With grCtrlSetup
    For n = 0 To #SCS_CTRLBTN_LAST
      \nCtrlBtnCC(n) = -1 ; indicates (by default) no CC assigned
    Next n
debugMsg(sProcName, "grCtrlSetup\nCtrlConfig=" + decodeCtrlConfig(\nCtrlConfig))
    Select \nCtrlConfig
      Case #SCS_CTRLCONF_BCR2000_PRESET_A To #SCS_CTRLCONF_BCR2000_PRESET_C
        \nCtrlBtnCC(#SCS_CTRLBTN_PREV) = 105
        \nCtrlBtnCC(#SCS_CTRLBTN_NEXT) = 106
        \nCtrlBtnCC(#SCS_CTRLBTN_STOP) = 107
        \nCtrlBtnCC(#SCS_CTRLBTN_GO) = 108
        
      Case #SCS_CTRLCONF_BCF2000_PRESET_A
        CompilerIf #c_Test_BCF2000_using_BCR2000
          \nCtrlBtnCC(#SCS_CTRLBTN_INPUTS) = 105
          \nCtrlBtnCC(#SCS_CTRLBTN_OUTPUTS) = 106
          \nCtrlBtnCC(#SCS_CTRLBTN_STOP) = 107
          \nCtrlBtnCC(#SCS_CTRLBTN_GO) = 108
        CompilerElse
          \nCtrlBtnCC(#SCS_CTRLBTN_INPUTS) = 89
          \nCtrlBtnCC(#SCS_CTRLBTN_OUTPUTS) = 90
          \nCtrlBtnCC(#SCS_CTRLBTN_STOP) = 91
          \nCtrlBtnCC(#SCS_CTRLBTN_GO) = 92
        CompilerEndIf
        
      Case #SCS_CTRLCONF_BCF2000_PRESET_C
        CompilerIf #c_Test_BCF2000_using_BCR2000
          \nCtrlBtnCC(#SCS_CTRLBTN_PREV) = 105
          \nCtrlBtnCC(#SCS_CTRLBTN_NEXT) = 106
          \nCtrlBtnCC(#SCS_CTRLBTN_STOP) = 107
          \nCtrlBtnCC(#SCS_CTRLBTN_GO) = 108
        CompilerElse
          \nCtrlBtnCC(#SCS_CTRLBTN_PREV) = 89
          \nCtrlBtnCC(#SCS_CTRLBTN_NEXT) = 90
          \nCtrlBtnCC(#SCS_CTRLBTN_STOP) = 91
          \nCtrlBtnCC(#SCS_CTRLBTN_GO) = 92
        CompilerEndIf
        
    EndSelect
  EndWith
  
  With WCN
    \nLiveInputCtrls = 0
    \nOutputCtrls = 0
    \nPlayingCtrls = 0
    \nMasterCtrls = 0
    \nDimmerChanCtrls = 0
    \nDMXMasterCtrls = 0
    \nNrOfControllers = 0
    \nFirstVidAudIndex = -1
    nIndex = 0
    
    ; live inputs
    nCtrlNo = 0
    For d2 = 0 To grProd\nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
      sLogicalDev = grProd\aLiveInputLogicalDevs(d2)\sLogicalDev
      If sLogicalDev
        nIndex + 1
        If nIndex > ArraySize(\aController())
          ReDim \aController(nIndex+8)
        EndIf
        \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
        \aController(nIndex)\sWCNLogicalDev = sLogicalDev
        \aController(nIndex)\sWCNLabel = sLogicalDev
        \aController(nIndex)\nWCNDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIVE_INPUT, sLogicalDev)
        \aController(nIndex)\nWCNDevNo = d2
        nCtrlNo + 1
        \aController(nIndex)\nWCNCtrlNo = nCtrlNo
        \nLiveInputCtrls + 1
        \nNrOfControllers + 1
        If \nLiveInputCtrls = 8 : Break : EndIf ; Added 18Jul2022 11.9.4
      EndIf
    Next d2
    
    Select grCtrlSetup\nCtrlConfig
      Case #SCS_CTRLCONF_NK2_PRESET_C, #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_C
        ; playing (outputs for a currently-playing cue)
        nCtrlNo = 0
        ; continue with just type F until we have sorted out better how to handle a video audio fader
        ;       For i = 1 To gnLastCue
        ;         If aCue(i)\bCueEnabled
        ;           If aCue(i)\bSubTypeAorF
        ;             j = aCue(i)\nFirstSubIndex
        ;             While j >= 0
        ;               If aSub(j)\bSubEnabled
        ;                 If aSub(j)\bSubTypeA
        ;                   bVideoFadersRequired = #True
        ;                 ElseIf aSub(j)\bSubTypeF
        ;                   bAudioFadersRequired = #True
        ;                 EndIf
        ;               EndIf
        ;               j = aSub(j)\nNextSubIndex
        ;             Wend
        ;             If bVideoFadersRequired And bAudioFadersRequired
        ;               Break ; Break i
        ;             EndIf
        ;           EndIf ; EndIf aCue(i)\bSubTypeAorF
        ;         EndIf ; EndIf aCue(i)\bCueEnabled
        ;       Next i
        ;       
        ;       If bAudioFadersRequired
        For d2 = 0 To grProd\nMaxAudioLogicalDev
          sLogicalDev = grProd\aAudioLogicalDevs(d2)\sLogicalDev
          If sLogicalDev
            nIndex + 1
            If nIndex > ArraySize(\aController())
              ReDim \aController(nIndex+8)
            EndIf
            \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_PLAYING
            \aController(nIndex)\sWCNLogicalDev = sLogicalDev
            \aController(nIndex)\sWCNLabel = sLogicalDev ; + "(Aud)" ; continue with just type F until we have sorted out better how to handle a video audio fader
            \aController(nIndex)\nWCNDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
            \aController(nIndex)\nWCNDevNo = d2
            nCtrlNo + 1
            \aController(nIndex)\nWCNCtrlNo = nCtrlNo
            \nPlayingCtrls + 1
            \nNrOfControllers + 1
            If \nPlayingCtrls = 8 : Break : EndIf
          EndIf
        Next d2
        ;       EndIf
        ;       If bVideoFadersRequired
        ;         For d2 = 0 To grProd\nMaxVidAudLogicalDev
        ;           sLogicalDev = grProd\aVidAudLogicalDevs(d2)\sVidAudLogicalDev
        ;           If sLogicalDev
        ;             nIndex + 1
        ;             If nIndex > ArraySize(\aController())
        ;               ReDim \aController(nIndex+8)
        ;             EndIf
        ;             If \nFirstVidAudIndex = -1
        ;               \nFirstVidAudIndex = nIndex
        ;             EndIf
        ;             \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_PLAYING
        ;             \aController(nIndex)\sWCNLogicalDev = sLogicalDev
        ;             \aController(nIndex)\sWCNLabel = sLogicalDev + "(Vid)"
        ;             \aController(nIndex)\nWCNDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, sLogicalDev)
        ;             \aController(nIndex)\nWCNDevNo = d2
        ;             nCtrlNo + 1
        ;             \aController(nIndex)\nWCNCtrlNo = nCtrlNo
        ;             \nPlayingCtrls + 1
        ;             \nNrOfControllers + 1
        ;             If \nPlayingCtrls = 8 : Break : EndIf
        ;           EndIf
        ;         Next d2
        ;       EndIf
      Default
        ; grCtrlSetup\nCtrlConfig <> #SCS_CTRLCONF_NK2_PRESET_C
        ; outputs
        nCtrlNo = 0
        For d2 = 0 To grProd\nMaxAudioLogicalDev
          sLogicalDev = grProd\aAudioLogicalDevs(d2)\sLogicalDev
          If sLogicalDev
            nIndex + 1
            If nIndex > ArraySize(\aController())
              ReDim \aController(nIndex+8)
            EndIf
            \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_OUTPUT
            \aController(nIndex)\sWCNLogicalDev = sLogicalDev
            \aController(nIndex)\sWCNLabel = sLogicalDev
            \aController(nIndex)\nWCNDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_AUDIO_OUTPUT, sLogicalDev)
            \aController(nIndex)\nWCNDevNo = d2
            nCtrlNo + 1
            \aController(nIndex)\nWCNCtrlNo = nCtrlNo
            \nOutputCtrls + 1
            \nNrOfControllers + 1
            If \nOutputCtrls = 8 : Break : EndIf ; Added 18Jul2022 11.9.4
          EndIf
        Next d2
    EndSelect
    
    ; master
    nCtrlNo = 0
    nIndex + 1
    If nIndex > ArraySize(\aController())
      ReDim \aController(nIndex)
    EndIf
    \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_MASTER
    \aController(nIndex)\sWCNLogicalDev = ""
    \aController(nIndex)\sWCNLabel = Lang("Common", "Master")
    \aController(nIndex)\nWCNDevMapDevPtr = -1
    \aController(nIndex)\nWCNDevNo = -1
    nCtrlNo + 1
    \aController(nIndex)\nWCNCtrlNo = nCtrlNo
    \nMasterIndex = nIndex
    \nMasterCtrls + 1
    \nNrOfControllers + 1
    
    ; DMX master
    ; If gbDMXAvailable And grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
    If gbDMXAvailable ; Removed nCtrlConfig test 11Feb2025 11.10.7ab following email from Willi Härtel where the DMX Master fader was not being displayed
      If DMX_IsDMXOutDevPresent()
        nCtrlNo = 0
        nIndex + 1
        If nIndex > ArraySize(\aController())
          ReDim \aController(nIndex)
        EndIf
        \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
        \aController(nIndex)\sWCNLogicalDev = ""
        \aController(nIndex)\sWCNLabel = Lang("Common", "DMXMaster")
        \aController(nIndex)\nWCNDevMapDevPtr = -1
        \aController(nIndex)\nWCNDevNo = -1
        nCtrlNo + 1
        \aController(nIndex)\nWCNCtrlNo = nCtrlNo
        \nDMXMasterIndex = nIndex
        \nDMXMasterCtrls + 1
        \nNrOfControllers + 1
      EndIf
    EndIf
    
    ; fixture dimmer channels (for single-dimmer-channel fixtures only)
    If gbDMXAvailable And grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
      If DMX_IsDMXOutDevPresent()
        nCtrlNo = 0
        For d2 = 0 To grProd\nMaxLightingLogicalDev
          sLogicalDev = grProd\aLightingLogicalDevs(d2)\sLogicalDev
          If sLogicalDev
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, sLogicalDev)
            If nDevMapDevPtr >= 0
              debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d2 + ")\nMaxFixture=" + grProd\aLightingLogicalDevs(d2)\nMaxFixture)
              For n = 0 To grProd\aLightingLogicalDevs(d2)\nMaxFixture
                sFixtureCode = grProd\aLightingLogicalDevs(d2)\aFixture(n)\sFixtureCode
                sFixTypeName = grProd\aLightingLogicalDevs(d2)\aFixture(n)\sFixTypeName
                debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", sFixTypeName=" + sFixTypeName)
                nDimmerChannelCount = 0
                For d3 = 0 To grLicInfo\nMaxFixTypePerProd
                  If d3 <= grProd\nMaxFixType
                    If grProd\aFixTypes(d3)\sFixTypeName = sFixTypeName
                      For n2 = 0 To grProd\aFixTypes(d3)\nTotalChans - 1
                        If grProd\aFixTypes(d3)\aFixTypeChan(n2)\bDimmerChan
                          ; debugMsg(sProcName, "grProd\aFixTypes(" + d3 + ")\aFixTypeChan(" + n2 + ")\sChannelDesc=" + grProd\aFixTypes(d3)\aFixTypeChan(n2)\sChannelDesc + ", \bDimmerChan=" + grProd\aFixTypes(d3)\aFixTypeChan(n2)\bDimmerChan)
                          nDimmerChannelCount + 1
                          If nDimmerChannelCount = 1
                            nFirstDimmerChannel = grProd\aFixTypes(d3)\aFixTypeChan(n2)\nChanNo
                          EndIf
                        EndIf
                      Next n2
                      Break ; Break d3 after matching sFixTypeName
                    EndIf
                  EndIf
                Next d3
                If nDimmerChannelCount = 1
                  For d4 = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
                    If grMaps\aDev(nDevMapDevPtr)\aDevFixture(d4)\sDevFixtureCode = sFixtureCode
                      nDevDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(d4)\nDevDMXStartChannel
                      If nDevDMXStartChannel > 0
                        nIndex + 1
                        If nIndex > ArraySize(\aController())
                          ReDim \aController(nIndex+8)
                        EndIf
                        \aController(nIndex)\nWCNCtrlType = #SCS_CTRLTYPE_DIMMER_CHANNEL
                        \aController(nIndex)\sWCNLogicalDev = sLogicalDev
                        \aController(nIndex)\sWCNLabel = sFixtureCode ; nb sFixtureCode, NOT sLogicalDev
                        \aController(nIndex)\nWCNDevMapDevPtr = nDevMapDevPtr
                        \aController(nIndex)\nWCNDevNo = d2
                        \aController(nIndex)\nWCNDimmerChan = nDevDMXStartChannel + nFirstDimmerChannel - 1
                        ; Added 13Jul2022 11.9.4
                        nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, sLogicalDev)
                        nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex ; nb nDMXSendDataBaseIndex will be 0 for port 1, or 512 for port 2
                        \aController(nIndex)\nWCNDMXSendItemIndex = nDMXSendDataBaseIndex + \aController(nIndex)\nWCNDimmerChan
                        \aController(nIndex)\dWCNPrevValue = -1.0
                        ; End added 13Jul2022 11.9.4
                        nCtrlNo + 1
                        \aController(nIndex)\nWCNCtrlNo = nCtrlNo
                        \nDimmerChanCtrls + 1
                        \nNrOfControllers + 1
                        debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d2 + ")\aFixture(" + n + ")\sFixtureCode=" + grProd\aLightingLogicalDevs(d2)\aFixture(n)\sFixtureCode +
                                            ", nFirstDimmerChannel=" + nFirstDimmerChannel + ", nDevDMXStartChannel=" + nDevDMXStartChannel +
                                            ", \aController(" + nIndex + ")\nWCNDimmerChan=" + \aController(nIndex)\nWCNDimmerChan)
                        ; Added 18Jul2022 11.9.4
                        If \nDimmerChanCtrls = 8
                          Break 3 ; Break d4, n, d2
                        EndIf
                        ; End added 18Jul2022 11.9.4
                      EndIf
                    EndIf
                  Next d4
                EndIf ; EndIf nDimmerChannelCount = 1
              Next n
            EndIf ; EndIf nDevMapDevPtr >= 0
          EndIf ; EndIf sLogicalDev
        Next d2
      EndIf ; EndIf DMX_IsDMXOutDevPresent()
    EndIf ; EndIf gbDMXAvailable
    
  EndWith
  
  For nIndex = 1 To WCN\nNrOfControllers
    With WCN\aController(nIndex)
      debugMsg(sProcName, "WCN\aController(" + nIndex + ")\nWCNCtrlType=" + decodeCtrlType(\nWCNCtrlType) +
                          ", \sWCNLogicalDev=" + \sWCNLogicalDev + ", \sWCNLabel=" + \sWCNLabel + ", \nWCNDevMapDevPtr=" + \nWCNDevMapDevPtr +
                          ", \nWCNDevNo=" + \nWCNDevNo + ", \nWCNCtrlNo=" + \nWCNCtrlNo)
      \bLiveOn = #False
      \bMuteOn = #False
      \bSoloOn = #False
      \bSaveEnabled = #False
    EndWith
  Next nIndex
  
  With WCN
    \nLiveInputSolos = 0
    \nOutputSolos = 0
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", WCN\nNrOfControllers=" + WCN\nNrOfControllers)
  
EndProcedure

Procedure WCN_setLabel(nIndex)
  PROCNAMEC()
  Protected nGadgetNo
  Protected nLeft, nTop, nWidth, nHeight
  Protected nTextWidth, nTextHeight
  Protected sLabel.s
  
  With WCN\aController(nIndex)
    nGadgetNo = \cvsLabel
    sLabel = \sWCNLabel
    CompilerIf 1=2
      ; blocked out 27Jan2022 11.9.0rc6 - decided not to include the number before the label
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT
          If WCN\nLiveInputCtrls > 1
            sLabel = Str(\nWCNCtrlNo) + "." + \sWCNLabel
          EndIf
        Case #SCS_CTRLTYPE_OUTPUT
          If WCN\nOutputCtrls > 1
            sLabel = Str(\nWCNCtrlNo) + "." + \sWCNLabel
          EndIf
      EndSelect
    CompilerEndIf
  EndWith
  If IsGadget(nGadgetNo)
    If StartDrawing(CanvasOutput(nGadgetNo))
      nWidth = GadgetWidth(nGadgetNo)
      nHeight = GadgetHeight(nGadgetNo)
      Box(0,0,nWidth,nHeight,#SCS_Dark_Grey)
      If sLabel
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawingMode(#PB_2DDrawing_Transparent)
        nTextWidth = TextWidth(sLabel)
        If nTextWidth >= nWidth
          nLeft = 0
        Else
          nLeft = (nWidth - nTextWidth) >> 1
        EndIf
        nTextHeight = TextHeight("gG")  ; force all labels to same height, ie same Y position
        nTop = (nHeight - nTextHeight) >> 1
        DrawText(nLeft, nTop, sLabel, #SCS_White)
      EndIf
      StopDrawing()
    EndIf
  EndIf
  
EndProcedure

Procedure WCN_setWindowButtons()
  PROCNAMEC()
  Protected bEnableClearSolos, bEnableSave, bEnableSetup
  Protected n, d
  
  ; debugMsg(sProcName, #SCS_START)
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_DMX_MASTER
          ; debugMsg(sProcName, "n=" + n + ", \nValue=" + \nValue + ", \nInitialValue=" + \nInitialValue)
          If \nValue <> \nInitialValue
            bEnableSave = #True
          EndIf
        Default
          If \bSoloOn
            bEnableClearSolos = #True
          EndIf
          ; debugMsg(sProcName, "n=" + n + ", \sDBLevel=" + \sDBLevel + ", \sInitialDBLevel=" + \sInitialDBLevel)
          If \sDBLevel <> \sInitialDBLevel
            bEnableSave = #True
          EndIf
      EndSelect
    EndWith
  Next n
  
  bEnableSetup = #True
  With WCN
    If IsGadget(\btnClearSolos)
      If getEnabled(\btnClearSolos) <> bEnableClearSolos
        setEnabled(\btnClearSolos, bEnableClearSolos)
      EndIf
    EndIf
    If IsGadget(\btnSave)
      If getEnabled(\btnSave) <> bEnableSave
        setEnabled(\btnSave, bEnableSave)
      EndIf
    EndIf
    If IsGadget(\btnSetup)
      If getEnabled(\btnSetup) <> bEnableSetup
        setEnabled(\btnSetup, bEnableSetup)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WCN_setButtons(Index)
  PROCNAMEC()
  Protected nBtnWidth, nBtnHeight
  Protected nLeft, nTop
  Protected nCenterX, nCenterY, nRadius
  Protected nBackColor, nTextColor
  
  If WCN\bUseFaders = #False
    ProcedureReturn
  EndIf
  
  ; debugMsg0(sProcName, #SCS_START + ", Index=" + Index)
  ; debugMsg0(sProcName, "WCN\aController(" + Index + ")\nWCNCtrlType=" + decodeCtrlType(WCN\aController(Index)\nWCNCtrlType))
  Select WCN\aController(Index)\nWCNCtrlType
    Case #SCS_CTRLTYPE_MASTER, #SCS_CTRLTYPE_DMX_MASTER, #SCS_CTRLTYPE_DIMMER_CHANNEL ; Changed 11Jul2022 11.9.4
      ; masters do not have live, mute or solo buttons, nor do dimmer channels
      ProcedureReturn
  EndSelect
  
  With WCN\aController(Index)
    If IsGadget(\cvsMute)
      nBtnWidth = GadgetWidth(\cvsMute)
      nBtnHeight = GadgetHeight(\cvsMute)
    Else
      ; see button width and height settings in createfmControllers()
      nBtnWidth = 16
      nBtnHeight = 16
    EndIf
    
    ; live
    If IsGadget(\cvsLive)
      If StartDrawing(CanvasOutput(\cvsLive))
        nCenterX = (nBtnWidth >> 1) - 1
        nCenterY = (nBtnHeight >> 1) ; - 1
        nRadius = ((nBtnWidth + nBtnHeight) >> 2) - 1
        Box(0,0,nBtnWidth,nBtnHeight,GetGadgetColor(\cntCtrl,#PB_Gadget_BackColor))
        If WCN\aController(Index)\bLiveOn
          ; nBackColor = RGB(10,216,255)
          nBackColor = #SCS_Yellow
          nTextColor = #SCS_Black
        Else
          nBackColor = #SCS_BS_ENABLED_BACKCOLOR
          nTextColor = #SCS_BS_ENABLED_TEXTCOLOR
        EndIf
        Circle(nCenterX,nCenterY,nRadius,nBackColor)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawingMode(#PB_2DDrawing_Transparent)
        nLeft = (nBtnWidth - TextWidth("L")) / 2
        nTop = (nBtnHeight - TextHeight("L")) / 2
        DrawText(nLeft, nTop, "L", nTextColor)
        StopDrawing()
      EndIf
    EndIf
    
    ; mute
    If IsGadget(\cvsMute)
      If StartDrawing(CanvasOutput(\cvsMute))
        If WCN\aController(Index)\bMuteOn
          nBackColor = RGB($FF,$80,$40)
          nTextColor = #SCS_Black
        Else
          nBackColor = #SCS_BS_ENABLED_BACKCOLOR
          nTextColor = #SCS_BS_ENABLED_TEXTCOLOR
        EndIf
        Box(0,0,nBtnWidth,nBtnHeight,nBackColor)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawingMode(#PB_2DDrawing_Transparent)
        nLeft = (nBtnWidth - TextWidth("M")) / 2
        nTop = (nBtnHeight - TextHeight("M")) / 2
        DrawText(nLeft, nTop, "M", nTextColor)
        StopDrawing()
      EndIf
    EndIf
    
    ; solo
    If IsGadget(\cvsSolo)
      If StartDrawing(CanvasOutput(\cvsSolo))
        If WCN\aController(Index)\bSoloOn
          nBackColor = RGB($0,$D9,$0)
          nTextColor = #SCS_Black
        Else
          nBackColor = #SCS_BS_ENABLED_BACKCOLOR
          nTextColor = #SCS_BS_ENABLED_TEXTCOLOR
        EndIf
        Box(0,0,nBtnWidth,nBtnHeight,nBackColor)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawingMode(#PB_2DDrawing_Transparent)
        nLeft = (nBtnWidth - TextWidth("S")) / 2
        nTop = (nBtnHeight - TextHeight("S")) / 2
        DrawText(nLeft, nTop, "S", nTextColor)
        StopDrawing()
      EndIf
    EndIf
    
  EndWith
  
EndProcedure

Procedure WCN_primeControllers()
  PROCNAMEC()
  Protected n
  Protected nDevMapDevPtr
  Protected nSliderValue, nMidiValue
  Protected bLevelFader, bDMXFader
  Protected fInitialLevel.f, nInitialValue
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "calling resetController()")
  resetController() ; set all faders, knobs, etc
  
  debugMsg(sProcName, "WCN\nNrOfControllers=" + WCN\nNrOfControllers)
  For n = 1 To WCN\nNrOfControllers
    bLevelFader = #False
    bDMXFader = #False
    With WCN\aController(n)
      nDevMapDevPtr = \nWCNDevMapDevPtr
      ; debugMsg(sProcName, "WCN\aController(" + n + ")\nWCNCtrlType=" + decodeCtrlType(\nWCNCtrlType))
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT ; #SCS_CTRLTYPE_LIVE_INPUT
          If nDevMapDevPtr >= 0
            fInitialLevel = grMaps\aDev(nDevMapDevPtr)\fInputGain
            If grMaps\aDev(nDevMapDevPtr)\bUseFaderInputGain = #False
              \rOrigDev = grMaps\aDev(nDevMapDevPtr)
              grMaps\aDev(nDevMapDevPtr)\fFaderInputGain = grMaps\aDev(nDevMapDevPtr)\fInputGain
              grMaps\aDev(nDevMapDevPtr)\sFaderInputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fFaderInputGain, #False, #True)
              grMaps\aDev(nDevMapDevPtr)\bUseFaderInputGain = #True
            EndIf
            \fBVLevel  = grMaps\aDev(nDevMapDevPtr)\fFaderInputGain
            bLevelFader = #True
          EndIf
          
        Case #SCS_CTRLTYPE_OUTPUT ; #SCS_CTRLTYPE_OUTPUT
          If nDevMapDevPtr >= 0
            fInitialLevel = grMaps\aDev(nDevMapDevPtr)\fDevOutputGain
            If grMaps\aDev(nDevMapDevPtr)\bUseFaderOutputGain = #False
              \rOrigDev = grMaps\aDev(nDevMapDevPtr)
              grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain = grMaps\aDev(nDevMapDevPtr)\fDevOutputGain
              grMaps\aDev(nDevMapDevPtr)\sDevFaderOutputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain, #False, #True)
              grMaps\aDev(nDevMapDevPtr)\bUseFaderOutputGain = #True
            EndIf
            \fBVLevel = grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain
            bLevelFader = #True
          EndIf
          
        Case #SCS_CTRLTYPE_MASTER ; #SCS_CTRLTYPE_MASTER
          fInitialLevel = grMasterLevel\fProdMasterBVLevel
          If grMasterLevel\bUseControllerFaderMasterBVLevel = #False
            grMasterLevel\fControllerFaderMasterBVLevel = grMasterLevel\fProdMasterBVLevel
            ; debugMsg0(sProcName, "grMasterLevel\fControllerFaderMasterBVLevel=" + traceLevel(grMasterLevel\fControllerFaderMasterBVLevel))
            grMasterLevel\bUseControllerFaderMasterBVLevel = #True
          EndIf
          \fBVLevel = grMasterLevel\fControllerFaderMasterBVLevel
          ; debugMsg0(sProcName, "grMasterLevel\fControllerFaderMasterBVLevel=" + traceLevel(grMasterLevel\fControllerFaderMasterBVLevel))
          bLevelFader = #True
          
        Case #SCS_CTRLTYPE_DIMMER_CHANNEL ; Added 11Jul2022 11.9.4
          nInitialValue = 0 ; ????????????????
          \nValue = 0       ; ?????????
          bDMXFader = #True
          
        Case #SCS_CTRLTYPE_DMX_MASTER ; #SCS_CTRLTYPE_DMX_MASTER
          nInitialValue = grDMXMasterFader\nDMXMasterFaderValue
          \nValue = grDMXMasterFader\nDMXMasterFaderValue
          bDMXFader = #True
          
      EndSelect
      
      If bLevelFader
        \sDBLevel = convertBVLevelToDBString(\fBVLevel)
        \sInitialDBLevel = convertBVLevelToDBString(fInitialLevel)
;         If \nWCNCtrlType = #SCS_CTRLTYPE_MASTER
;           debugMsg(sProcName, "\sDBLevel=" + \sDBLevel + ", \fBVLevel=" + traceLevel(\fBVLevel) + ", \sInitialDBLevel=" + \sInitialDBLevel + traceLevel(fInitialLevel))
;         EndIf
        SLD_setLevel(\sldLevelOrValue, \fBVLevel)
        ; debugMsg(sProcName, "grCtrlSetup\bUseExternalController=" + strB(grCtrlSetup\bUseExternalController) + ", grCtrlSetup\nCtrlMidiOutPhysicalDevPtr=" + grCtrlSetup\nCtrlMidiOutPhysicalDevPtr)
        If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
          nSliderValue = SLD_BVLevelToSliderValue(SLD_getLevel(\sldLevelOrValue))
          nMidiValue = sliderValueToMidiValue(\nWCNCtrlType, nSliderValue)
          sendControllerMsg(\nWCNCtrlType, #SCS_CTRLSUBTYPE_FADER, \nWCNCtrlNo, nMidiValue)
        EndIf
      EndIf
      
      If bDMXFader
        \nInitialValue = nInitialValue
        SLD_setValue(\sldLevelOrValue, \nValue)
        If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
          nMidiValue = sliderValueToMidiValue(\nWCNCtrlType, \nValue)
          sendControllerMsg(\nWCNCtrlType, #SCS_CTRLSUBTYPE_FADER, \nWCNCtrlNo, nMidiValue)
        EndIf
      EndIf
      
    EndWith
  Next n
  WCN_setWindowButtons()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_setFader(nCtrlType, nCtrlNo, nSliderValue, bSendControllerMsg, bIgnoreFieldControl=#False)
  ; PROCNAMEC()
  Protected n, fBVLevel.f
  Protected nMidiValue
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlType=" + decodeCtrlType(nCtrlType) + ", nCtrlNo=" + nCtrlNo + ", nSliderValue=" + nSliderValue +
  ;                     ", bSendControllerMsg=" + strB(bSendControllerMsg) + ", bIgnoreFieldControl=" + strB(bIgnoreFieldControl))
  
  ; debugMsg0(sProcName, "WCN\nNrOfControllers=" + WCN\nNrOfControllers)
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      ; debugMsg0(sProcName, "WCN\aController(" + n + ")\nWCNCtrlType=" + decodeCtrlType(\nWCNCtrlType) + ", \nWCNCtrlNo=" + \nWCNCtrlNo)
      If \nWCNCtrlType = nCtrlType
        If SLD_getEnabled(\sldLevelOrValue)
          If \nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER Or (\nWCNCtrlType = #SCS_CTRLTYPE_DIMMER_CHANNEL And \nWCNCtrlNo = nCtrlNo)
            ; debugMsg(sProcName, "(DMX Master) calling SLD_setValue(" + \sldLevelOrValue + ", " + nSliderValue + ")")
            SLD_setValue(\sldLevelOrValue, nSliderValue)
            If bIgnoreFieldControl = #False
              ; debugMsg0(sProcName, "calling WCN_fcSldLevelOrValue(" + n + ", " + strB(bSendControllerMsg) + ")")
              WCN_fcSldLevelOrValue(n, bSendControllerMsg)
            EndIf
            Break
          ElseIf \nWCNCtrlNo = nCtrlNo
            fBVLevel = SLD_SliderValueToBVLevel(nSliderValue)
            ; debugMsg0(sProcName, "SLD_SliderValueToBVLevel(\sldLevelOrValue, " + nSliderValue + ") returned fBVLevel=" + traceLevel(fBVLevel))
            SLD_setLevel(\sldLevelOrValue, fBVLevel)
            If bIgnoreFieldControl = #False
              ; debugMsg0(sProcName, "calling WCN_fcSldLevelOrValue(" + n + ", " + strB(bSendControllerMsg) + ")")
              WCN_fcSldLevelOrValue(n, bSendControllerMsg)
            Else
              nMidiValue = sliderValueToMidiValue(\nWCNCtrlType, nSliderValue)
              sendControllerMsg(\nWCNCtrlType, #SCS_CTRLSUBTYPE_FADER, \nWCNCtrlNo, nMidiValue)
            EndIf
            Break
          EndIf
        EndIf ; EndIf SLD_getEnabled(\sldLevelOrValue)
      EndIf ; EndIf \nWCNCtrlType = nCtrlType
    EndWith
  Next n
  
  ; debugMsg0(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_setSliderValueMatched(nCtrlType, nCtrlNo, bSliderValueMatched)
  Protected n
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = nCtrlType
        If \nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
          \bSliderValueMatched = bSliderValueMatched
          Break
        ElseIf \nWCNCtrlNo = nCtrlNo
          \bSliderValueMatched = bSliderValueMatched
          Break
        EndIf
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure WCN_getSliderValueMatched(nCtrlType, nCtrlNo)
  Protected n, bSliderValueMatched
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = nCtrlType
        If \nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
          bSliderValueMatched = \bSliderValueMatched
          Break
        ElseIf \nWCNCtrlNo = nCtrlNo
          bSliderValueMatched = \bSliderValueMatched
          Break
        EndIf
      EndIf
    EndWith
  Next n
  ProcedureReturn bSliderValueMatched
  
EndProcedure

Procedure WCN_getCtrlNoForLogicalDev(nCtrlType, sLogicalDev.s)
  PROCNAMEC()
  Protected n, nCtrlNo
  
  nCtrlNo = -1
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = nCtrlType
        If \sWCNLogicalDev = sLogicalDev
          nCtrlNo = \nWCNCtrlNo
          Break
        EndIf
      EndIf
    EndWith
  Next n
  ProcedureReturn nCtrlNo
EndProcedure

Procedure WCN_getAudDevNoForCtrlNo(pAudPtr, nCtrlNo)
  PROCNAMEC()
  Protected nAudDevNo, d, sWCNLogicalDev.s
  
  nAudDevNo = -1
  sWCNLogicalDev = WCN\aController(nCtrlNo)\sWCNLogicalDev
  With aAud(pAudPtr)
    For d = 0 To #SCS_MAX_AUDIO_DEV_PER_AUD_OR_SUB
      If \sLogicalDev[d] = sWCNLogicalDev
        nAudDevNo = d
        Break
      EndIf
    Next d
  EndWith
  ProcedureReturn nAudDevNo
EndProcedure

Procedure WCN_setAudioOutputFader(sLogicalDev.s, fBVLevel.f, bSendControllerMsg)
  PROCNAMEC()
  Protected n
  
  ; debugMsg0(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev + ", fBVLevel=" + traceLevel(fBVLevel) + ", bSendControllerMsg=" + strB(bSendControllerMsg))
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = #SCS_CTRLTYPE_OUTPUT
        If \sWCNLogicalDev = sLogicalDev
          SLD_setLevel(\sldLevelOrValue, fBVLevel)
          ; debugMsg0(sProcName, "calling WCN_fcSldLevelOrValue(" + n + ", " + strB(bSendControllerMsg) + ")")
          WCN_fcSldLevelOrValue(n, bSendControllerMsg)
          Break
        EndIf
      EndIf
    EndWith
  Next n
EndProcedure

Procedure WCN_setKnob(nCtrlNo, nMidiValue, bSendControllerMsg)
  ; PROCNAMEC()
  ; only called from processMidiControllerMsg() on receiving a MIDI message from a control surface
  Protected nIndex
  Protected nMinValue, nMaxValue, nValue
  
  Select nCtrlNo
    Case 1 To 7
      nIndex = nCtrlNo
      If _Knob(nIndex)\bKnobCreated
        nMinValue = knobGetMinValue(nIndex)
        nMaxValue = knobGetMaxValue(nIndex)
        nValue = ((nMaxValue - nMinValue) * nMidiValue) / 127
        knobSetValue(nIndex, nValue)
        knobCalcAngleFromValue(nIndex)
        SpinKNOB(nIndex)
        SetGadgetText(_Knob(nIndex)\nInfo, knobValueToString(nIndex, #True))
        WCN_processKnobValue(nIndex, bSendControllerMsg)
        WCN_checkEQChanged()
      EndIf
  EndSelect
EndProcedure

Procedure WCN_primeKnobs()
  PROCNAMEC()
  Protected nIndex
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If WCN\bDisplayEQPanel = #False
    ProcedureReturn
  EndIf
  
  With WCN
    If \nSelectedController >= 0
      nDevMapDevPtr = \aController(\nSelectedController)\nWCNDevMapDevPtr
    EndIf
  EndWith
  
  For nIndex = 1 To 7
    If nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        Select nIndex
          Case 1
            setKnobValueFromString(nIndex, Str(\nInputLowCutFreq))
          Case 2
            setKnobValueFromString(nIndex, \aInputEQBand[0]\sEQGainDB)
          Case 3
            setKnobValueFromString(nIndex, Str(\aInputEQBand[0]\nEQFreq))
          Case 4
            setKnobValueFromString(nIndex, StrF(\aInputEQBand[0]\fEQQ,1))
          Case 5
            setKnobValueFromString(nIndex, \aInputEQBand[1]\sEQGainDB)
          Case 6
            setKnobValueFromString(nIndex, Str(\aInputEQBand[1]\nEQFreq))
          Case 7
            setKnobValueFromString(nIndex, StrF(\aInputEQBand[1]\fEQQ,1))
        EndSelect
      Else
      EndIf
      knobCalcAngleFromValue(nIndex)
      SpinKNOB(nIndex)
      SetGadgetText(_Knob(nIndex)\nInfo, knobValueToString(nIndex, #True))
      If nIndex < 7
        WCN_processKnobValue(nIndex, #True, #False)
      Else
        WCN_processKnobValue(nIndex, #True, #True)
      EndIf
    EndWith
  Next nIndex
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_Form_Unload()
  PROCNAMEC()
  Protected sMsg.s
  Protected nResponse
  Protected n
  Protected bDisplayCloseWarn1
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \bMuteOn Or \bSoloOn
        bDisplayCloseWarn1 = #True
        Break
      EndIf
    EndWith
  Next n
  If bDisplayCloseWarn1
    nResponse = scsMessageRequester(Lang("WCN", "Window"), Lang("WCN", "CloseWarn1"), #PB_MessageRequester_YesNo)
    If nResponse = #PB_MessageRequester_No
      ProcedureReturn
    EndIf
    For n = 1 To WCN\nNrOfControllers
      With WCN\aController(n)
        \bSoloOn = #False
        \bMuteOn = #False
        If \nWCNDevMapDevPtr >= 0
          grMaps\aDev(\nWCNDevMapDevPtr)\bInputMuteOn = #False
          grMaps\aDev(\nWCNDevMapDevPtr)\bInputMuteTmpOn = #False
          grMaps\aDev(\nWCNDevMapDevPtr)\bOutputMuteOn = #False
          grMaps\aDev(\nWCNDevMapDevPtr)\bOutputMuteTmpOn = #False
        EndIf
      EndWith
    Next n
    WCN_applySolos(#SCS_CTRLTYPE_LIVE_INPUT)
    WCN_applySolos(#SCS_CTRLTYPE_OUTPUT)
  EndIf
  
  WCN\bUseFaders = #False
  getFormPosition(#WCN, @grControllersWindow)
  setWindowVisible(#WCN, #False)  ; hide window rather than closing it so if the user subsequently operates controls then SCS can still 'move' the sliders on #WCN
  SLD_setEnabled(WMN\sldMasterFader, #True)
  If IsGadget(WMN\btnShowFaders)
    SGT(WMN\btnShowFaders, Lang("WMN", "ShowFaders"))
  EndIf
  
  SAW(#WMN)
  SAG(-1)
  
EndProcedure

Procedure WCN_setLiveOnInds()
  PROCNAMEC()
  Protected d, k, n
  Protected sInputLogicalDev.s
  Protected bAudLiveOn
  
  ; debugMsg(sProcName, #SCS_START + ", WCN\bUseFaders=" + strB(WCN\bUseFaders))
  
  If WCN\bUseFaders = #False
    ProcedureReturn
  EndIf
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
        \bLiveOn = #False
      EndIf
    EndWith
  Next n
  
  For k = 1 To gnLastAud
    With aAud(k)
      If \bExists
        If \bAudTypeI
          If (\nAudState >= #SCS_CUE_FADING_IN) And (\nAudState <= #SCS_CUE_FADING_OUT)
            bAudLiveOn = #True
          Else
            bAudLiveOn = #False
          EndIf
          For d = 0 To grLicInfo\nMaxLiveDevPerAud
            sInputLogicalDev = \sInputLogicalDev[d]
            If (Len(sInputLogicalDev) > 0) And (\bInputCurrentlyOff[d] = #False)
              ; debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nAudState=" + decodeCueState(\nAudState) + ", \sInputLogicalDev[" + Str(d) + "]=" + \sInputLogicalDev[d] + ", \bInputCurrentlyOff[" + Str(d) + "]=" + strB(\bInputCurrentlyOff[d]))
              For n = 1 To WCN\nNrOfControllers
                If (WCN\aController(n)\nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT) And (WCN\aController(n)\sWCNLogicalDev = sInputLogicalDev)
                  If bAudLiveOn
                    WCN\aController(n)\bLiveOn = #True
                  EndIf
                  Break
                EndIf
              Next n
            EndIf
          Next d
        EndIf
      EndIf
    EndWith
  Next k
  
  For n = 1 To WCN\nLiveInputCtrls
    WCN_setButtons(n)
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_countSolos()
  PROCNAMEC()
  Protected n
  
  WCN\nLiveInputSolos = 0
  WCN\nOutputSolos = 0
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT
          If \bSoloOn
            WCN\nLiveInputSolos + 1
          EndIf
        Case #SCS_CTRLTYPE_OUTPUT
          If \bSoloOn
            WCN\nOutputSolos + 1
          EndIf
      EndSelect
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END + ", WCN\nLiveInputSolos=" + Str(WCN\nLiveInputSolos) + ", WCN\nOutputSolos=" + Str(WCN\nOutputSolos))
  
EndProcedure

Procedure WCN_applySolos(nCtrlType)
  PROCNAMEC()
  Protected n
  Protected nDevMapDevPtr, nDevNo
  
  WCN_countSolos()  ; must call WCN_countSolos() before subsequent processing, as this sets WCN\nLiveInputSolos and WCN\nOutputSolos
  Select nCtrlType
    Case #SCS_CTRLTYPE_LIVE_INPUT
      For n = 1 To WCN\nNrOfControllers
        If WCN\aController(n)\nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
          nDevMapDevPtr = WCN\aController(n)\nWCNDevMapDevPtr
          If WCN\nLiveInputSolos > 0
            If WCN\aController(n)\bSoloOn
              grMaps\aDev(nDevMapDevPtr)\bInputMuteTmpOn = #False
            Else
              grMaps\aDev(nDevMapDevPtr)\bInputMuteTmpOn = #True
            EndIf
          Else
            grMaps\aDev(nDevMapDevPtr)\bInputMuteTmpOn = #False
          EndIf
          nDevNo = WCN\aController(n)\nWCNDevNo
          setInputGain(nDevNo)
          WCN_setButtons(n)
        EndIf
      Next n
      
    Case #SCS_CTRLTYPE_OUTPUT
      For n = 1 To WCN\nNrOfControllers
        If WCN\aController(n)\nWCNCtrlType = #SCS_CTRLTYPE_OUTPUT
          nDevMapDevPtr = WCN\aController(n)\nWCNDevMapDevPtr
          If WCN\nOutputSolos > 0
            If WCN\aController(n)\bSoloOn
              grMaps\aDev(nDevMapDevPtr)\bOutputMuteTmpOn = #False
            Else
              grMaps\aDev(nDevMapDevPtr)\bOutputMuteTmpOn = #True
            EndIf
          Else
            grMaps\aDev(nDevMapDevPtr)\bOutputMuteTmpOn = #False
          EndIf
          debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\sLogicalDev=" + grMaps\aDev(nDevMapDevPtr)\sLogicalDev + ", \bOutputMuteTmpOn=" + strB(grMaps\aDev(nDevMapDevPtr)\bOutputMuteTmpOn))
          nDevNo = WCN\aController(n)\nWCNDevNo
          setAudioDevOutputGain(nDevNo)
          WCN_setButtons(n)
        EndIf
      Next n
      
  EndSelect
EndProcedure

Procedure WCN_processSoloButton(Index)
  ; Added 24Jun2022 11.9.4
  PROCNAMEC()
  Protected nDevMapDevPtr
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  If Index <= WCN\nNrOfControllers
    With WCN\aController(Index)
      nDevMapDevPtr = \nWCNDevMapDevPtr
      If \bSoloOn
        \bSoloOn = #False
      Else
        \bSoloOn = #True
        \bMuteOn = #False
        If nDevMapDevPtr >= 0
          Select \nWCNCtrlType
            Case #SCS_CTRLTYPE_LIVE_INPUT
              grMaps\aDev(nDevMapDevPtr)\bInputMuteOn = #False
            Case #SCS_CTRLTYPE_OUTPUT
              grMaps\aDev(nDevMapDevPtr)\bOutputMuteOn = #False
          EndSelect
        EndIf
      EndIf
      WCN_applySolos(\nWCNCtrlType)
      WCN_setButtons(Index)
      WCN_setWindowButtons()
    EndWith
  EndIf
  
EndProcedure

Procedure WCN_cvsSolo_Event(Index)
  ; Changed 24Jun2022 11.9.4
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  If gnEventType = #PB_EventType_LeftClick
    WCN_processSoloButton(Index)
    makeMainWindowActive()
  EndIf

EndProcedure

Procedure WCN_btnClearSolos_Click()
  PROCNAMEC()
  Protected n
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \bSoloOn
        \bSoloOn = #False
        WCN_applySolos(\nWCNCtrlType)
        WCN_setButtons(n)
      EndIf
    EndWith
  Next n
  WCN_setWindowButtons()
  makeMainWindowActive()
  
EndProcedure

Procedure WCN_processMuteButton(Index)
  PROCNAMEC()
  Protected nMidiValue
  
  ; debugMsg(sProcName, #SCS_START)
  
  If Index <= WCN\nNrOfControllers
    With WCN\aController(Index)
      If \bMuteOn
        \bMuteOn = #False
        nMidiValue = 0
      Else
        \bMuteOn = #True
        \bSoloOn = #False
        nMidiValue = 127
      EndIf
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT
          grMaps\aDev(\nWCNDevMapDevPtr)\bInputMuteOn = \bMuteOn
          setInputGain(\nWCNDevNo)
          
        Case #SCS_CTRLTYPE_OUTPUT
          grMaps\aDev(\nWCNDevMapDevPtr)\bOutputMuteOn = \bMuteOn
          ; debugMsg(sProcName, "calling setAudioDevOutputGain(" + \nWCNDevNo + ")")
          setAudioDevOutputGain(\nWCNDevNo)
          
      EndSelect
      ; debugMsg(sProcName, "\sWCNLabel=" + \sWCNLabel + ", \bMuteOn=" + strB(\bMuteOn) + ", \bSoloOn=" + strB(\bSoloOn))
      ; debugMsg(sProcName, "calling WCN_applySolos(" + \nWCNCtrlType + ")")
      WCN_applySolos(\nWCNCtrlType)
      WCN_setButtons(Index)
      If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
        sendControllerMsg(#SCS_CTRLTYPE_MUTE, 0, Index, nMidiValue)
      EndIf
      WCN_setWindowButtons()
    EndWith
  EndIf
  
EndProcedure

Procedure WCN_cvsMute_Event(nIndex)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnEventType = #PB_EventType_LeftClick  ; #PB_EventType_LeftClick
    WCN_processMuteButton(nIndex)
    makeMainWindowActive()
  EndIf
  
EndProcedure

Procedure WCN_cvsLoCut_Event()
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnEventType = #PB_EventType_LeftClick  ; #PB_EventType_LeftClick
    WCN_selectEQGroup(#SCS_EQGRP_LOW_CUT, -1) ; nMidiValue -1 means 'switch state'
    makeMainWindowActive()
  EndIf
EndProcedure

Procedure WCN_cvsEQBand_Event(nIndex)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnEventType = #PB_EventType_LeftClick  ; #PB_EventType_LeftClick
    WCN_selectEQGroup(#SCS_EQGRP_BAND_1 + nIndex, -1) ; nMidiValue -1 means 'switch state'
    makeMainWindowActive()
  EndIf
EndProcedure

Procedure WCN_cvsFaderAssignments_Event(nIndex)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  If gnEventType = #PB_EventType_LeftClick  ; #PB_EventType_LeftClick
    Select nIndex
      Case 0
        If grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_C
          grGeneralOptions\nFaderAssignments = #SCS_FADER_PLAYING_1_7_M
        Else
          grGeneralOptions\nFaderAssignments = #SCS_FADER_INPUTS_1_8
        EndIf
      Case 1
        grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M
    EndSelect
    setFaderAssignments()
    makeMainWindowActive()
  EndIf
EndProcedure

Procedure WCN_selectController(nCtrlNo, nMidiValue)
  PROCNAMEC()
  Protected n
  Protected bFound
  Protected sSelectedChannel.s
  Static bStaticLoaded
  Static sNoSelect.s
  
  ; debugMsg0(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sNoSelect = Lang("WCN","NoSelect")
    bStaticLoaded = #True
  EndIf
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
        If n = nCtrlNo
          bFound = #True
          If nMidiValue = 0
            WCN\nSelectedController = -1
          Else
            WCN\nSelectedController = n
          EndIf
          Break
        EndIf
      EndIf
    EndWith
  Next n
  
  If bFound
    With WCN
      WCN_setSelectButtons()
      If IsGadget(\lblSelection)
        If \nSelectedController = -1
          sSelectedChannel = sNoSelect
          SetGadgetColor(\lblSelection, #PB_Gadget_BackColor, _BkRGB)
          SetGadgetColor(\lblSelection, #PB_Gadget_FrontColor, #SCS_White)
        Else
          sSelectedChannel = \aController(\nSelectedController)\sWCNLabel
          SetGadgetColor(\lblSelection, #PB_Gadget_BackColor, #SCS_Orange)
          SetGadgetColor(\lblSelection, #PB_Gadget_FrontColor, #SCS_Black)
        EndIf
        SGT(\lblSelection, sSelectedChannel)
      EndIf
      WCN_setEQLabels(\nSelectedController)
      If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
        resetControllerSelectButtons(\nSelectedController)
        debugMsg(sProcName, "calling sendControllerMsg(#SCS_CTRLTYPE_EQ_SELECT, 0, " + nCtrlNo + ", " + nMidiValue + ")")
        sendControllerMsg(#SCS_CTRLTYPE_EQ_SELECT, 0, nCtrlNo, nMidiValue)
      EndIf
debugMsg(sProcName, "\nSelectedController=" + \nSelectedController)
      If \nSelectedController >= 0
        WCN_primeKnobs()
      EndIf
    EndWith
  EndIf ; EndIf bFound
  
EndProcedure

Procedure WCN_selectEQGroup(nEQGroup, nMidiValue)
  PROCNAMEC()
  Protected nDevMapDevPtr
  Protected bSelected, bSwitchState
  
  debugMsg(sProcName, #SCS_START)
  
  With WCN
    If \nSelectedController >= 0
      nDevMapDevPtr = \aController(\nSelectedController)\nWCNDevMapDevPtr
    EndIf
  EndWith
  
  If nDevMapDevPtr >= 0
    
    If nMidiValue > 0
      bSelected = #True
    ElseIf nMidiValue = -1
      bSwitchState = #True
    EndIf
    
    With grMaps\aDev(nDevMapDevPtr)
      Select nEQGroup
        Case #SCS_EQGRP_LOW_CUT
          debugMsg(sProcName, "nEQGroup=#SCS_EQGRP_LOW_CUT")
          If bSwitchState
            If \bInputLowCutSelected = #False
              bSelected = #True
            EndIf
          EndIf
          \bInputLowCutSelected = bSelected
          
        Case #SCS_EQGRP_BAND_1
          debugMsg(sProcName, "nEQGroup=#SCS_EQGRP_BAND_1")
          If bSwitchState
            If \aInputEQBand[0]\bEQBandSelected = #False
              bSelected = #True
            EndIf
          EndIf
          \aInputEQBand[0]\bEQBandSelected = bSelected
          
        Case #SCS_EQGRP_BAND_2
          debugMsg(sProcName, "nEQGroup=#SCS_EQGRP_BAND_2")
          If bSwitchState
            If \aInputEQBand[1]\bEQBandSelected = #False
              bSelected = #True
            EndIf
          EndIf
          \aInputEQBand[1]\bEQBandSelected = bSelected
          
        Default
          debugMsg(sProcName, "nEQGroup=" + Str(nEQGroup))
          
      EndSelect
      
      If (\bInputLowCutSelected) Or (\aInputEQBand[0]\bEQBandSelected) Or (\aInputEQBand[1]\bEQBandSelected)
        \bInputEQOn = #True
      Else
        \bInputEQOn = #False
      EndIf
      ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\bInputLowCutSelected=" + strB(\bInputLowCutSelected) + ", \aInputEQBand[0]\bEQBandSelected=" + strB(\aInputEQBand[0]\bEQBandSelected) + ", \aInputEQBand[1]\bEQBandSelected=" + strB(\aInputEQBand[1]\bEQBandSelected) + ", \bInputEQOn=" + strB(\bInputEQOn))
      adjustLiveEQ(@grMaps\aDev(nDevMapDevPtr), #True)
      
    EndWith
    
    WCN_setEQLabels(WCN\nSelectedController)
    
    WCN_checkEQChanged()
    
  EndIf
  
EndProcedure

Procedure WCN_cvsSelect_Event(Index)
  PROCNAMEC()
  Protected nMidiValue
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WCN\aController(Index)
    If gnEventType = #PB_EventType_LeftClick  ; #PB_EventType_LeftClick
      ; debugMsg(sProcName, "Left Click")
      If WCN\nSelectedController = Index
        nMidiValue = 0    ; to turn off selection
      Else
        nMidiValue = 127  ; to turn on selection
      EndIf
      WCN_selectController(Index, nMidiValue)
      makeMainWindowActive()
    EndIf
  EndWith
EndProcedure

Procedure WCN_btnSave_Click()
  ; NB save fader levels
  PROCNAMEC()
  Protected n
  Protected nDevMapDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If gbEditing
    scsMessageRequester(GGT(WCN\btnSave),Lang("WCN","CloseEditor"))
    ProcedureReturn
  EndIf
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      nDevMapDevPtr = \nWCNDevMapDevPtr
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT
          If nDevMapDevPtr >= 0
            grMaps\aDev(nDevMapDevPtr)\fInputGain = grMaps\aDev(nDevMapDevPtr)\fFaderInputGain
            grMaps\aDev(nDevMapDevPtr)\sInputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fInputGain, #False, #True)
            \sInitialDBLevel = \sDBLevel
          EndIf
          
        Case #SCS_CTRLTYPE_OUTPUT
          If nDevMapDevPtr >= 0
            grMaps\aDev(nDevMapDevPtr)\fDevOutputGain = grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain
            grMaps\aDev(nDevMapDevPtr)\sDevOutputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain, #False, #True)
            \sInitialDBLevel = \sDBLevel
          EndIf
          
        Case #SCS_CTRLTYPE_MASTER
          grMasterLevel\fProdMasterBVLevel = grMasterLevel\fControllerFaderMasterBVLevel
          ; debugMsg0(sProcName, "grMasterLevel\fProdMasterBVLevel=" + traceLevel(grMasterLevel\fProdMasterBVLevel))
          grProd\fMasterBVLevel = grMasterLevel\fProdMasterBVLevel
          grProd\sMasterDBVol = convertBVLevelToDBString(grProd\fMasterBVLevel, #False, #True)
          If SLD_getLevel(WMN\sldMasterFader) = SLD_getBaseLevel(WMN\sldMasterFader)
            SLD_setLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
            SLD_setBaseLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
          Else
            SLD_setBaseLevel(WMN\sldMasterFader, grProd\fMasterBVLevel)
          EndIf
          \sInitialDBLevel = \sDBLevel
          
        Case #SCS_CTRLTYPE_DMX_MASTER
          grProd\nDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderValue
          \nInitialValue = \nValue
          
      EndSelect
    EndWith
  Next n
  If gnVisMode = #SCS_VU_LEVELS
    displayLabels()
  EndIf
  WCN_setWindowButtons()
  debugMsg(sProcName, "calling writeXMLCueFile(#False, #False, #False, #False, " + strB(grProd\bTemplate) + ")")
  writeXMLCueFile(#False, #False, #False, #False, grProd\bTemplate)
  debugMsg(sProcName, "calling writeXMLDevMapFile(" + #DQUOTE$ + grMaps\sSelectedDevMapName + #DQUOTE$ + ", " + #DQUOTE$ + grProd\sProdId + #DQUOTE$ + ")")
  writeXMLDevMapFile(grMaps\sSelectedDevMapName, grProd\sProdId)
  makeMainWindowActive()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_btnClose_Click()
  PROCNAMEC()

  WCN_Form_Unload()
  gbFadersDisplayed = #False
  
EndProcedure

Procedure WCN_btnSetup_Click()
  ; PROCNAMEC()
  
  WCM_Form_Show()
  
EndProcedure

Procedure WCN_refreshControllers()
  PROCNAMEC()
  Protected rCurrWCN.strWCN
  Protected bSetVisible
  Protected n, nCurrIndex, nPrevIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WCN) ; nb no need to 'refresh' if the window has not yet been created
    rCurrWCN = WCN  ; hold current settings (eg fader levels)
    If getWindowVisible(#WCN)
      bSetVisible = #True
    EndIf
    getFormPosition(#WCN, @grControllersWindow)
    scsCloseWindow(#WCN)
    WCN_Form_Show(#False) ; initially keep window hidden
    
    ; now reset controllers that previously existed to their previously-displayed settings
    debugMsg(sProcName, "WCN\nNrOfControllers=" + WCN\nNrOfControllers)
    For nCurrIndex = 1 To WCN\nNrOfControllers
      With WCN\aController(nCurrIndex)
        ; find this controller's previous entry
        nPrevIndex = 0
        For n = 1 To rCurrWCN\nNrOfControllers
          If (rCurrWCN\aController(n)\nWCNCtrlType = \nWCNCtrlType) And (rCurrWCN\aController(n)\sWCNLogicalDev = \sWCNLogicalDev) And (rCurrWCN\aController(n)\sWCNLabel = \sWCNLabel)
            nPrevIndex = n
            Break
          EndIf
        Next n
        debugMsg(sProcName, "nPrevIndex=" + nPrevIndex)
        If nPrevIndex > 0
          \nValue = rCurrWCN\aController(nPrevIndex)\nValue
          \fBVLevel = rCurrWCN\aController(nPrevIndex)\fBVLevel
          \sDBLevel = rCurrWCN\aController(nPrevIndex)\sDBLevel
          \bLiveOn = rCurrWCN\aController(nPrevIndex)\bLiveOn
          \bMuteOn = rCurrWCN\aController(nPrevIndex)\bMuteOn
          \bSoloOn = rCurrWCN\aController(nPrevIndex)\bSoloOn
          \bSaveEnabled = rCurrWCN\aController(nPrevIndex)\bSaveEnabled
          If \nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
            ; debugMsg(sProcName, "calling SLD_setValue(" + \sldLevelOrValue + ", " + \nValue + ")")
            SLD_setValue(\sldLevelOrValue, \nValue)
          Else
            ; debugMsg(sProcName, "calling SLD_setLevel(" + \sldLevelOrValue + ", " + StrF(\fBVLevel,2) + ")")
            SLD_setLevel(\sldLevelOrValue, \fBVLevel)
          EndIf
        EndIf
        ; debugMsg(sProcName, "calling WCN_setButtons(" + nCurrIndex + ")")
        WCN_setButtons(nCurrIndex)
      EndWith
    Next nCurrIndex
    
    ; debugMsg(sProcName, "calling WCN_countSolos()")
    WCN_countSolos()
    
    ; now re-display the window if it was visible at the start of this procedure call
    If bSetVisible
      setWindowVisible(#WCN, #True)
    EndIf
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_Form_Show(bSetVisible=#True)
  PROCNAMEC()
  Protected d, n
  Protected nLiveInputCount, nOutputCount, nDMXMasterIndex, nDMXValue
  Protected bReloadReqd
  
  debugMsg(sProcName, #SCS_START)
  
  ; Added 27Jan2022 11.9.0rc6
  If IsWindow(#WCN)
    ; close window to force controls to be re-created, thus avoiding some nasty possible error messages when trying to use slider settings no longer valid
    CloseWindow(#WCN)
  EndIf
  ; End added 27Jan2022 11.9.0rc6

  grCtrlSetup\bRecreateWCN = #False
  
  WCN\bUseFaders = #True
  WCN\nSelectedController = -1
  
  With grProd
    For d = 0 To \nMaxLiveInputLogicalDev ; grLicInfo\nMaxLiveDevPerProd
      If \aLiveInputLogicalDevs(d)\sLogicalDev
        nLiveInputCount + 1
      EndIf
    Next d
    For d = 0 To \nMaxAudioLogicalDev ; grLicInfo\nMaxAudDevPerProd
      If \aAudioLogicalDevs(d)\sLogicalDev
        nOutputCount + 1
      EndIf
    Next d
  EndWith
  Select grCtrlSetup\nCtrlConfig
    Case #SCS_CTRLCONF_NK2_PRESET_C, #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_C
      WCN\bDisplayEQPanel = #False
      WCN\bDisplaySoloAndMute = #False
      WCN\bDisplayClearSolos = #False
      WCN\bDisplaySaveFaderLevels = #False
    Default
      If nLiveInputCount > 0
        WCN\bDisplayEQPanel = #True
      Else
        WCN\bDisplayEQPanel = #False
      EndIf
      If (nLiveInputCount + nOutputCount) > 0
        WCN\bDisplaySoloAndMute = #True
        WCN\bDisplaySaveFaderLevels = #True
      EndIf
      If (nLiveInputCount + nOutputCount) >= 2
        WCN\bDisplayClearSolos = #True
      Else
        WCN\bDisplayClearSolos = #False
      EndIf
  EndSelect
  
  ; debugMsg0(sProcName, "calling WCN_initControllers()")
  WCN_initControllers()
  
  If IsWindow(#WCN) = #False
    createfmControllers()
  EndIf
  setFormPosition(#WCN, @grControllersWindow)
  
  nDMXMasterIndex = -1
  For n = 1 To WCN\nNrOfControllers
    WCN_setButtons(n)
    WCN_setLabel(n)
    If WCN\aController(n)\nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
      nDMXMasterIndex = n
    EndIf
  Next n
  WCN_primeControllers()
  setFaderAssignments()
  WCN_setLiveOnInds()
  WCN_setSelectButtons()
debugMsg(sProcName, "(EQ) calling WCN_selectController(-1, 0)")
  WCN_selectController(-1, 0)
  WCN_setEQLabels(-1)
  WCN_primeKnobs()
  
  With WCN
    ; debugMsg(sProcName, "WCN\sldDMXMasterFader=" + WCN\sldDMXMasterFader)
    If SLD_isSlider(\sldDMXMasterFader)
      nDMXValue = grProd\nDMXMasterFaderValue
      If nDMXMasterIndex >= 0
        If \aController(nDMXMasterIndex)\bDMXSliderUsed
          nDMXValue = \aController(nDMXMasterIndex)\nValue
        EndIf
      EndIf
      SLD_setValue(\sldDMXMasterFader, nDMXValue)
      WCN_enableDMXMasterFaderIfReqd()
      SLD_drawSlider(WCN\sldDMXMasterFader)
    EndIf
  EndWith
  
  WCN_setWindowButtons()
  
  If bSetVisible
    setWindowVisible(#WCN, #True)
    SLD_setEnabled(WMN\sldMasterFader, #False)
    If IsGadget(WMN\btnShowFaders)
      SGT(WMN\btnShowFaders, Lang("WMN","HideFaders"))
    EndIf
    gbFadersDisplayed = #True
  EndIf
  
  WCN\nPlayingSubTypeF = -1
  WCN_setPlayingControlsIfReqd(#True)
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_setSelectButtons()
  PROCNAMEC()
  Protected n
  Protected nBackColor, nTextColor
  Static bStaticLoaded
  Static nBtnWidth, nBtnHeight
  Static sSelectText.s, nTextWidth, nTextHeight
  Static nSelectLeft, nSelectTop
  
  If IsGadget(WCN\cntEQPanel) = #False
    ProcedureReturn
  EndIf
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If IsGadget(\cvsSelect)
        If StartDrawing(CanvasOutput(\cvsSelect))
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          DrawingMode(#PB_2DDrawing_Transparent)
          If bStaticLoaded = #False
            nBtnWidth = GadgetWidth(\cvsSelect)
            nBtnHeight = GadgetHeight(\cvsSelect)
            sSelectText = grText\sTextSelect
            nTextHeight = TextHeight(sSelectText)
            nTextWidth = TextWidth(sSelectText)
            nSelectLeft = ((nBtnWidth - nTextWidth) / 2)
            If nSelectLeft <= 0
              nSelectLeft = 1
            EndIf
            nSelectTop = (nBtnHeight - nTextHeight) / 2
            bStaticLoaded = #True
          EndIf
          If n = WCN\nSelectedController
            nBackColor = #SCS_Orange
            nTextColor = #SCS_Black
          Else
            nBackColor = #SCS_BS_ENABLED_BACKCOLOR
            nTextColor = #SCS_BS_ENABLED_TEXTCOLOR
          EndIf
          Box(0,0,nBtnWidth,nBtnHeight,RGB(173,173,173))
          Box(1,1,nBtnWidth-2,nBtnHeight-2,nBackColor)
          DrawText(nSelectLeft, nSelectTop, sSelectText, nTextColor)
          StopDrawing()
        EndIf
      EndIf
      If IsGadget(\cvsEQInd)
        If StartDrawing(CanvasOutput(\cvsEQInd))
          scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
          DrawingMode(#PB_2DDrawing_Transparent)
          nBackColor = $606060
          nTextColor = #SCS_Orange
          Box(0,0,OutputWidth(),OutputHeight(),nBackColor)
          If WCN_isControllerUsingEQ(n)
            DrawText(0,nSelectTop,"*",nTextColor)
          EndIf
          StopDrawing()
        EndIf
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure WCN_fcSldLevelOrValue(nIndex, bSendControllerMsg=#True)
  PROCNAMEC()
  Protected nSliderValue, nMidiValue, nDMXValue, nNextCuePtr, nSubPtr, nAudPtr, nAudDevNo
  
  ; debugMsg(sProcName, #SCS_START + ", nIndex=" + nIndex + ", bSendControllerMsg=" + strB(bSendControllerMsg))
  
  With WCN\aController(nIndex)
    Select \nWCNCtrlType
      Case #SCS_CTRLTYPE_DMX_MASTER, #SCS_CTRLTYPE_DIMMER_CHANNEL ; Changed 12Jul2022 11.9.4
        \nValue = SLD_getValue(\sldLevelOrValue)
        \bDMXSliderUsed = #True
      Default
        ; debugMsg(sProcName, "(AUDIO) SLD_getMax(\sldLevelOrValue)=" + SLD_getMax(\sldLevelOrValue))
        \fBVLevel = SLD_getLevel(\sldLevelOrValue)
        \sDBLevel = convertBVLevelToDBString(\fBVLevel)
    EndSelect
    
    Select \nWCNCtrlType
      Case #SCS_CTRLTYPE_LIVE_INPUT
        grMaps\aDev(\nWCNDevMapDevPtr)\fFaderInputGain = \fBVLevel
        grMaps\aDev(\nWCNDevMapDevPtr)\sFaderInputGainDB = convertBVLevelToDBString(grMaps\aDev(\nWCNDevMapDevPtr)\fFaderInputGain, #False, #True)
        If \bMuteOn = #False
          setInputGain(\nWCNDevNo)
        EndIf
        
      Case #SCS_CTRLTYPE_OUTPUT
        grMaps\aDev(\nWCNDevMapDevPtr)\fDevFaderOutputGain = \fBVLevel
        grMaps\aDev(\nWCNDevMapDevPtr)\sDevFaderOutputGainDB = convertBVLevelToDBString(grMaps\aDev(\nWCNDevMapDevPtr)\fDevFaderOutputGain, #False, #True)
        If \bMuteOn = #False
          setAudioDevOutputGain(\nWCNDevNo)
        EndIf
        If gnVisMode = #SCS_VU_LEVELS
          ; need to call displayLabels() as this procedure also sets gaMeterBar(nOutputNr)\fVUOutputGain which is used in correctly displaying the VU levels and output gain markers
          displayLabels()
        EndIf
        
      Case #SCS_CTRLTYPE_MASTER
        grMasterLevel\fControllerFaderMasterBVLevel = \fBVLevel
        CompilerIf #cTraceSetLevels
          debugMsg(sProcName, "grMasterLevel\fControllerFaderMasterBVLevel=" + traceLevel(grMasterLevel\fControllerFaderMasterBVLevel))
        CompilerEndIf
        If \bMuteOn = #False
          SLD_setLevel(WMN\sldMasterFader, \fBVLevel)
          WMN_sldMasterFader_Common()
        EndIf
        If gnVisMode = #SCS_VU_LEVELS
          ; need to call displayLabels() as this procedure also sets gaMeterBar(nOutputNr)\fVUOutputGain which is used in correctly displaying the VU levels and output gain markers
          displayLabels()
        EndIf
        
      Case #SCS_CTRLTYPE_DIMMER_CHANNEL
        nDMXValue = \nValue * 2.55
        If nDMXValue > 255
          nDMXValue = 255
        EndIf
        DMX_setDMXChannelValue(\nWCNDevNo, \nWCNDimmerChan, nDMXValue, #SCS_DMX_ORIGIN_CHANNEL_FADER)
        nNextCuePtr = WCN_getNextCuePtr()
        If nNextCuePtr >= 0
          DMX_saveCueStartDMXSave(nNextCuePtr)
        EndIf
        
      Case #SCS_CTRLTYPE_DMX_MASTER
        grDMXMasterFader\nDMXMasterFaderValue = \nValue
        DMX_setDMXMasterFader(grDMXMasterFader\nDMXMasterFaderValue, #SCS_DMX_ORIGIN_MASTER_FADER)
        nNextCuePtr = WCN_getNextCuePtr()
        If nNextCuePtr >= 0
          DMX_saveCueStartDMXSave(nNextCuePtr)
        EndIf
        
      Case #SCS_CTRLTYPE_PLAYING
        nSubPtr = getEarliestPlayingSubTypeF()
        If nSubPtr >= 0
          ; continue with just type F until we have sorted out better how to handle a video audio fader
;           If \nWCNCtrlNo >= WCN\nFirstVidAudIndex
;             aSub(nSubPtr)\fSubBVLevelNow = \fBVLevel
;             nAudPtr = aSub(nSubPtr)\nFirstAudIndex
;             If nAudPtr >= 0
;               debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nAudPtr) + ", 0, " + traceLevel(\fBVLevel) + ", #SCS_NOPANCHANGE_SINGLE)")
;               setLevelsAny(nAudPtr, 0, \fBVLevel, #SCS_NOPANCHANGE_SINGLE)
;             EndIf
;             ; setLevelsVideo(nAudPtr, 0, 
;             ;;;;;;;;;;;; setsub
;           Else
            nAudPtr = aSub(nSubPtr)\nFirstAudIndex
            If nAudPtr >= 0
              nAudDevNo = WCN_getAudDevNoForCtrlNo(nAudPtr, \nWCNCtrlNo)
              ; debugMsg(sProcName, "WCN_getAudDevNoForCtrlNo(" + getAudLabel(nAudPtr) + ", " + \nWCNCtrlNo + ") returned " + nAudDevNo)
              ; debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nAudPtr) + ", " + nAudDevNo + ", " + traceLevel(\fBVLevel) + ", #SCS_NOPANCHANGE_SINGLE)")
              setLevelsAny(nAudPtr, nAudDevNo, \fBVLevel, #SCS_NOPANCHANGE_SINGLE)
              If aAud(nAudPtr)\bAudTypeF
                If aAud(nAudPtr)\nLevelChangeSubPtr >= 0
                  If aSub(aAud(nAudPtr)\nLevelChangeSubPtr)\nLCAction = #SCS_LC_ACTION_ABSOLUTE  ; absolute level change, not relative level change
                    ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(aAud(nAudPtr)\nLevelChangeSubPtr) + ")")
                    addToSaveSettings(aAud(nAudPtr)\nLevelChangeSubPtr)
                    setSaveSettings()
                  EndIf
                Else
                  ; debugMsg(sProcName, "calling addToSaveSettings(" + getSubLabel(aAud(nAudPtr)\nSubIndex) + ")")
                  addToSaveSettings(aAud(nAudPtr)\nSubIndex)
                  setSaveSettings()
                EndIf
              EndIf
              aAud(nAudPtr)\bIncDecLevelSet = #False
              If nAudDevNo >= 0
                aAud(nAudPtr)\bCueVolManual[nAudDevNo] = #True
              EndIf
            EndIf
;           EndIf
        Else
          ; debugMsg(sProcName, "no aud type A or F currently playing")
        EndIf
        
    EndSelect
    If bSendControllerMsg
      If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
        Select \nWCNCtrlType
          Case #SCS_CTRLTYPE_DMX_MASTER, #SCS_CTRLTYPE_DIMMER_CHANNEL ; Changed 12Jul2022 11.9.4
            nSliderValue = SLD_getValue(\sldLevelOrValue)
          Default
            nSliderValue = SLD_BVLevelToSliderValue(SLD_getLevel(\sldLevelOrValue))
        EndSelect
        nMidiValue = sliderValueToMidiValue(\nWCNCtrlType, nSliderValue)
        ; debugMsg(sProcName, "nSliderValue=" + nSliderValue + ", nMidiValue=" + nMidiValue)
        sendControllerMsg(\nWCNCtrlType, #SCS_CTRLSUBTYPE_FADER, \nWCNCtrlNo, nMidiValue)
      EndIf
    EndIf
    WCN_setWindowButtons()
  EndWith
  
  ; debugMsg0(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_setExternalControllerFaders()
  ; This procedure sets fader levels on an external controller, such as the BCF2000 or BCR2000, and is therefore only available for controller wth motorized faders or equivalent
  PROCNAMEC()
  Protected nIndex
  Protected nSliderValue, nMidiValue
  Protected Dim bFaderSet(8)  ; currently used only with BCF2000, to identify which of the 8 faders has been set so we can zeroise the remainder
  Protected bMessageSent
  Protected nFaderNo
  Protected nCC, nChannel, nValue
  
  debugMsg(sProcName, #SCS_START)
  
  If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
    For nIndex = 1 To WCN\nNrOfControllers
      With WCN\aController(nIndex)
        ; debugMsg(sProcName, "WCN\aController(" + nIndex + ")\nWCNCtrlType=" + decodeCtrlType(\nWCNCtrlType) + ", \nWCNCtrlNo=" + \nWCNCtrlNo + ", \sWCNLabel=" + \sWCNLabel + ", \sWCNLogicalDev=" + \sWCNLogicalDev)
        If \nWCNCtrlType <> #SCS_CTRLTYPE_DMX_MASTER And \nWCNCtrlType <> #SCS_CTRLTYPE_DIMMER_CHANNEL ; Changed 11Jul2022 11.9.4
          nSliderValue = SLD_BVLevelToSliderValue(SLD_getLevel(\sldLevelOrValue))
          nMidiValue = sliderValueToMidiValue(\nWCNCtrlType, nSliderValue)
          bMessageSent = sendControllerMsg(\nWCNCtrlType, #SCS_CTRLSUBTYPE_FADER, \nWCNCtrlNo, nMidiValue)
          If (bMessageSent) And (grCtrlSetup\nController = #SCS_CTRL_BCF2000)
            If \nWCNCtrlType = #SCS_CTRLTYPE_MASTER
              nFaderNo = 8
            Else
              nFaderNo = \nWCNCtrlNo
            EndIf
            If nFaderNo <= 8
              bFaderSet(nFaderNo) = #True
            EndIf
          EndIf
        EndIf
      EndWith
    Next nIndex
    
    If grCtrlSetup\nController = #SCS_CTRL_BCF2000
      ; now zeroise any faders not set by the above
      nChannel = 1
      nValue = 0
      For nFaderNo = 1 To 8
        If bFaderSet(nFaderNo) = #False
          nCC = 80 + nFaderNo
          SendCtrlChange(grCtrlSetup\nCtrlMidiOutPhysicalDevPtr, nCC, nValue, nChannel, #False)
        EndIf
      Next nFaderNo
    EndIf
    
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_processKnobValue(nIndex, bSendControllerMsg=#True, bSendSMSMsgIfReqd=#True)
  PROCNAME(#PB_Compiler_Procedure + "(" + nIndex + ")")
  Protected nDevMapDevPtr
  Protected nEQBandIndex
  Protected nMinValue, nMaxValue, nValue, nMidiValue
  Protected fTmp.f
  Protected bSendSMSMsg
  
  ; debugMsg(sProcName, #SCS_START)
  
  With WCN
    If \nSelectedController >= 0
      nDevMapDevPtr = \aController(\nSelectedController)\nWCNDevMapDevPtr
    Else
      ; shouldn't happen
      ProcedureReturn
    EndIf
  EndWith
  
  With _Knob(nIndex)
    Select \nEQBand
      Case 1
        nEQBandIndex = 0
      Case 2
        nEQBandIndex = 1
      Default
        nEQBandIndex = -1
    EndSelect
    
    Select \nKnobType
      Case #SCS_EQTYPE_LOWCUT_FREQ
        grMaps\aDev(nDevMapDevPtr)\nInputLowCutFreq = Val(knobValueToString(nIndex, #False))
        If grMaps\aDev(nDevMapDevPtr)\bInputLowCutSelected
          bSendSMSMsg = bSendSMSMsgIfReqd
        EndIf
        
      Case #SCS_EQTYPE_GAIN
        If nEQBandIndex >= 0
          grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\sEQGainDB = knobValueToString(nIndex, #False)
          ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\aInputEQBand[" + Str(nEQBandIndex) + "]\sEQGainDB=" + grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\sEQGainDB)
          If grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\bEQBandSelected
            bSendSMSMsg = bSendSMSMsgIfReqd
          EndIf
        EndIf
        
      Case #SCS_EQTYPE_FREQ
        If nEQBandIndex >= 0
          grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\nEQFreq = Val(knobValueToString(nIndex, #False))
          If grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\bEQBandSelected
            bSendSMSMsg = bSendSMSMsgIfReqd
          EndIf
        EndIf
        
      Case #SCS_EQTYPE_Q
        If nEQBandIndex >= 0
          grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\fEQQ = ValF(knobValueToString(nIndex, #False))
          If grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nEQBandIndex]\bEQBandSelected
            bSendSMSMsg = bSendSMSMsgIfReqd
          EndIf
        EndIf
          
    EndSelect
    If bSendControllerMsg
      If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
        nMinValue = knobGetMinValue(nIndex)
        nMaxValue = knobGetMaxValue(nIndex)
        If \nValue <= nMinValue
          nMidiValue = 0
        ElseIf \nValue >= nMaxValue
          nMidiValue = 127
        Else
          fTmp = 127 / ((nMaxValue - nMinValue) / \nValue)
          nMidiValue = fTmp
        EndIf
        sendControllerMsg(#SCS_CTRLTYPE_EQ_KNOB, 0, nIndex, nMidiValue)
      EndIf
    EndIf
    ; WCN_setSaveButton(nIndex)
    WCN_setWindowButtons()
  EndWith
  
  If bSendSMSMsg
    ; debugMsg(sProcName, "calling adjustLiveEQ(" + nDevMapDevPtr + ")")
    adjustLiveEQ(@grMaps\aDev(nDevMapDevPtr))
  EndIf
  
EndProcedure

Procedure WCN_isControllerUsingEQ(nIndex)
  PROCNAME(#PB_Compiler_Procedure + "(" + nIndex + ")")
  Protected nDevMapDevPtr
  Protected bLowCutSelected, bEQBand1Selected, bEQBand2Selected
  
  If nIndex >= 0
    nDevMapDevPtr = WCN\aController(nIndex)\nWCNDevMapDevPtr
    If nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        bLowCutSelected = \bInputLowCutSelected
        bEQBand1Selected = \aInputEQBand[0]\bEQBandSelected
        bEQBand2Selected = \aInputEQBand[1]\bEQBandSelected
      EndWith
    EndIf
  EndIf
  If (bLowCutSelected) Or (bEQBand1Selected) Or (bEQBand2Selected)
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure WCN_setEQLabels(nIndex)
  PROCNAME(#PB_Compiler_Procedure + "(" + nIndex + ")")
  Protected nTextWidth
  Protected nLabelWidth
  Protected bLowCutSelected, bEQBand1Selected, bEQBand2Selected
  Protected nDevMapDevPtr
  Static nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, nActiveButtonGap
  Static bStaticLoaded
  Static sLowCut.s, sEQBand1.s, sEQBand2.s
  Static nLowCutLeft, nEQBand1Left, nEQBand2Left
  Static nLowCutBtnLeft, nEQBand1BtnLeft, nEQBand2BtnLeft
  Static nLblTop
  Static sOn.s, nOnPad
  
  If IsGadget(WCN\cntEQPanel) = #False
    ProcedureReturn
  EndIf
  
  If nIndex >= 0
    nDevMapDevPtr = WCN\aController(nIndex)\nWCNDevMapDevPtr
    If nDevMapDevPtr >= 0
      With grMaps\aDev(nDevMapDevPtr)
        bLowCutSelected = \bInputLowCutSelected
        bEQBand1Selected = \aInputEQBand[0]\bEQBandSelected
        bEQBand2Selected = \aInputEQBand[1]\bEQBandSelected
      EndWith
    EndIf
  EndIf
  debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr + ", bLowCutSelected=" + strB(bLowCutSelected) + ", bEQBand1Selected=" + strB(bEQBand1Selected) + ", bEQBand2Selected=" + strB(bEQBand2Selected))
  
  With WCN
    If bStaticLoaded = #False
      If StartDrawing(CanvasOutput(\cvsLoCut))
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          sOn = UCase(Lang("Common", "On"))
          nOnPad = 1
          nTextWidth = TextWidth(sOn) + nOnPad + nOnPad
          nActiveButtonWidth = nTextWidth
          nActiveButtonHeight = GadgetHeight(\cvsLoCut) - 2
          nActiveButtonTop = (GadgetHeight(\cvsLoCut) - nActiveButtonHeight) >> 1
          nActiveButtonGap = 4
          sLowCut = Lang("WCN", "lblLoCut")
          sEQBand1 = LangPars("WCN", "lblEQBand", "1")
          sEQBand2 = LangPars("WCN", "lblEQBand", "2")
          nLblTop = (GadgetHeight(\cvsLoCut) - TextHeight("Gg")) / 2
          
          nTextWidth = TextWidth(sLowCut)
          nLabelWidth = nTextWidth + nActiveButtonGap + nActiveButtonWidth
          If nLabelWidth < GadgetWidth(\cvsLoCut)
            nLowCutLeft = (GadgetWidth(\cvsLoCut) - nLabelWidth) >> 1
          Else
            nLowCutLeft = 0
          EndIf
          nLowCutBtnLeft = nLowCutLeft + nTextWidth + nActiveButtonGap
          debugMsg(sProcName, "nLowCutLeft=" + nLowCutLeft + ", nTextWidth=" + nTextWidth + ", nActiveButtonGap=" + nActiveButtonGap + ", nLowCutBtnLeft=" + nLowCutBtnLeft)
          
          nTextWidth = TextWidth(sEQBand1)
          nLabelWidth = nTextWidth + nActiveButtonGap + nActiveButtonWidth
          If nLabelWidth < GadgetWidth(\cvsEQBand[0])
            nEQBand1Left = (GadgetWidth(\cvsEQBand[0]) - nLabelWidth) >> 1
          Else
            nEQBand1Left = 0
          EndIf
          nEQBand1BtnLeft = nEQBand1Left + nTextWidth + nActiveButtonGap
          
          nTextWidth = TextWidth(sEQBand1)
          nLabelWidth = nTextWidth + nActiveButtonGap + nActiveButtonWidth
          If nLabelWidth < GadgetWidth(\cvsEQBand[1])
            nEQBand2Left = (GadgetWidth(\cvsEQBand[1]) - nLabelWidth) >> 1
          Else
            nEQBand2Left = 0
          EndIf
          nEQBand2BtnLeft = nEQBand2Left + nTextWidth + nActiveButtonGap
          
          bStaticLoaded = #True
        EndIf
      StopDrawing()
    EndIf
    
    If StartDrawing(CanvasOutput(\cvsLoCut))
        Box(0,0,OutputWidth(),OutputHeight(),_BkRGB)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawText(nLowCutLeft,nLblTop,sLowCut,#SCS_White)
        If bLowCutSelected
          Box(nLowCutBtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Orange)
          DrawText(nLowCutBtnLeft+nOnPad,nLblTop,sOn,#SCS_Black)
        Else
          Box(nLowCutBtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Light_Grey)
        EndIf
      StopDrawing()
    EndIf
    
    If StartDrawing(CanvasOutput(\cvsEQBand[0]))
        Box(0,0,OutputWidth(),OutputHeight(),_BkRGB)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawText(nEQBand1Left,nLblTop,sEQBand1,#SCS_White)
        If bEQBand1Selected
          Box(nEQBand1BtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Orange)
          DrawText(nEQBand1BtnLeft+nOnPad,nLblTop,sOn,#SCS_Black)
        Else
          Box(nEQBand1BtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Light_Grey)
        EndIf
      StopDrawing()
    EndIf
    
    If StartDrawing(CanvasOutput(\cvsEQBand[1]))
        Box(0,0,OutputWidth(),OutputHeight(),_BkRGB)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL)
        DrawText(nEQBand2Left,nLblTop,sEQBand2,#SCS_White)
        If bEQBand2Selected
          Box(nEQBand2BtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Orange)
          DrawText(nEQBand2BtnLeft+nOnPad,nLblTop,sOn,#SCS_Black)
        Else
          Box(nEQBand2BtnLeft, nActiveButtonTop, nActiveButtonWidth, nActiveButtonHeight, #SCS_Light_Grey)
        EndIf
      StopDrawing()
    EndIf
    
  EndWith
  
EndProcedure

Procedure WCN_KnobCanvas_Event(nIndex)
  PROCNAME(#PB_Compiler_Procedure + "(" + nIndex + ")")
  Protected nCanvasMouseX, nCanvasMouseY
  Protected bDoSpinKnob
  Protected bSetMainWindowActive
  
  If WCN\nSelectedController = -1
    ; nothing selected, so ignore
    makeMainWindowActive()
    ProcedureReturn
  EndIf
  
  With _Knob(nIndex)
    Select gnEventType
      Case #PB_EventType_LeftButtonDown
        \bMouseDown = #True
        bDoSpinKnob = #True
        
      Case #PB_EventType_MouseMove
        If \bMouseDown
          bDoSpinKnob = #True
        EndIf
        
      Case #PB_EventType_LeftButtonUp
        \bMouseDown = #False
        bSetMainWindowActive = #True
        
    EndSelect
    
    If bDoSpinKnob
      nCanvasMouseX = GetGadgetAttribute(\nCanv, #PB_Canvas_MouseX)
      nCanvasMouseY = GetGadgetAttribute(\nCanv, #PB_Canvas_MouseY)
      \fAngle = RotaF(GetAngle(nCanvasMouseX,nCanvasMouseY,\nXCenter,\nYCenter)-90,0,360)
      If (\fAngle > \fMinDeadAngle) And (\fAngle < \fMaxDeadAngle)
        If \fAngle < 180
          \fAngle = \fMinDeadAngle
        Else
          \fAngle = \fMaxDeadAngle
        EndIf
      EndIf
      SpinKNOB(nIndex)
      If \fAngle < 180
        \nValue = Proportion(\fAngle,0,\fMinDeadAngle,\nMidValue,\nMaxValue)
      Else
        \nValue = Proportion(\fAngle,\fMaxDeadAngle,360,\nMinValue,\nMidValue)
      EndIf
      SetGadgetText(\nInfo, knobValueToString(nIndex, #True))
      WCN_processKnobValue(nIndex)
    EndIf
    
  EndWith
  
  If bSetMainWindowActive ; set on LeftButtonUp, ie end of mouse movement
    WCN_checkEQChanged()
    makeMainWindowActive()
  EndIf
  
EndProcedure

Procedure WCN_EventHandler()
  PROCNAMEC()
  Protected n, nIndex
  Protected bFound
  
  With WCN
    
    Select gnWindowEvent
        
      Case #WM_RBUTTONDOWN, #WM_NCRBUTTONDOWN
        ; see note at start of WMN_windowCallback()
        debugMsg(sProcName, decodeEvent(gnWindowEvent))
        If WMN_processRightClick()
          ProcedureReturn
        EndIf
        
      Case #PB_Event_CloseWindow
        WCN_Form_Unload()
        gbFadersDisplayed = #False
        
      Case #PB_Event_Gadget
        If gnEventSliderNo > 0
          For n = 1 To WCN\nNrOfControllers
            If gnEventSliderNo = WCN\aController(n)\sldLevelOrValue
              bFound = #True
              Select gnSliderEvent
                Case #SCS_SLD_EVENT_MOUSE_DOWN, #SCS_SLD_EVENT_SCROLL
                  WCN_fcSldLevelOrValue(n)
                Case #SCS_SLD_EVENT_MOUSE_UP
                  WCN_fcSldLevelOrValue(n)
                  makeMainWindowActive()
              EndSelect
              Break
            EndIf
          Next n
          If bFound
            ProcedureReturn
          EndIf
        EndIf
        
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnClearSolos
            WCN_btnClearSolos_Click()
            
          Case \btnClose
            WCN_btnClose_Click()
            
          Case \btnSave ; 'save fader levels'
            WCN_btnSave_Click()
            
          Case \btnSetup
            WCN_btnSetup_Click()
            
          Case \cvsDimmerChanTitle
            ; no action
            
          Case \cvsDMXMasterTitle
            ; no action
            
          Case \cvsEQBand[0]
            WCN_cvsEQBand_Event(gnEventGadgetArrayIndex)
            
          Case \cvsFaderAssignments[0]
            WCN_cvsFaderAssignments_Event(gnEventGadgetArrayIndex)
            
          Case \cvsInputTitle
            ; no action
            
          Case \cvsLoCut
            WCN_cvsLoCut_Event()
            
          Case \cvsMasterTitle
            ; no action
            
          Case \cvsOutputTitle
            ; no action
            
          Case \cvsPlayingTitle
            ; no action
            
          Case \aController(1)\cvsLive
            ; no action
            
          Case \aController(1)\cvsLabel
            ; no action
            
          Case \aController(1)\cvsMute
            WCN_cvsMute_Event(gnEventGadgetArrayIndex)
            
          Case \aController(1)\cvsSelect
            WCN_cvsSelect_Event(gnEventGadgetArrayIndex)
            
          Case \aController(1)\cvsSolo
            WCN_cvsSolo_Event(gnEventGadgetArrayIndex)
            
          Default
            bFound = #False
            For n = 0 To \nMaxEQControl
              If gnEventGadgetNo = _Knob(n+1)\nCanv
                bFound = #True
                WCN_KnobCanvas_Event(n+1)
                Break
              EndIf
            Next n
            If bFound = #False
              debugMsg(sProcName, "gnEventGadgetNoForEvHdlr=" + getGadgetName(gnEventGadgetNoForEvHdlr) + ", gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType())
            EndIf
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WCN_checkEQChanged()
  PROCNAMEC()
  Protected bEQChanged
  Protected n, nBandNo
  Protected nDevMapDevPtr
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
        nDevMapDevPtr = \nWCNDevMapDevPtr
        If nDevMapDevPtr >= 0
          ; check low-cut
          If grMaps\aDev(nDevMapDevPtr)\bInputLowCutSelected <> \rOrigDev\bInputLowCutSelected
            bEQChanged = #True
          ElseIf grMaps\aDev(nDevMapDevPtr)\nInputLowCutFreq <> \rOrigDev\nInputLowCutFreq
            bEQChanged = #True
          EndIf
          If bEQChanged
            Break
          EndIf
          ; check EQ Bands
          For nBandNo = 0 To #SCS_MAX_EQ_BAND
            If grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nBandNo]\bEQBandSelected <> \rOrigDev\aInputEQBand[nBandNo]\bEQBandSelected
              bEQChanged = #True
            ElseIf grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nBandNo]\sEQGainDB <> \rOrigDev\aInputEQBand[nBandNo]\sEQGainDB
              bEQChanged = #True
            ElseIf grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nBandNo]\nEQFreq <> \rOrigDev\aInputEQBand[nBandNo]\nEQFreq
              bEQChanged = #True
            ElseIf grMaps\aDev(nDevMapDevPtr)\aInputEQBand[nBandNo]\fEQQ <> \rOrigDev\aInputEQBand[nBandNo]\fEQQ
              bEQChanged = #True
            EndIf
            If bEQChanged
              Break
            EndIf
          Next nBandNo
        EndIf
      EndIf
    EndWith
    If bEQChanged
      Break
    EndIf
  Next n
  
  If bEQChanged <> WCN\bEQChanged
    WCN\bEQChanged = bEQChanged
    setFileSave(#False)
  EndIf
  
EndProcedure

Procedure WCN_resetOrigDevs()
  PROCNAMEC()
  ; called after saving device map file
  Protected n
  Protected nDevMapDevPtr
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      Select \nWCNCtrlType
        Case #SCS_CTRLTYPE_LIVE_INPUT, #SCS_CTRLTYPE_OUTPUT
          nDevMapDevPtr = \nWCNDevMapDevPtr
          If nDevMapDevPtr >= 0
            \rOrigDev = grMaps\aDev(nDevMapDevPtr)
          EndIf
      EndSelect
    EndWith
  Next n
  
EndProcedure

Procedure WCN_windowCallback(hwnd, uMsg, wparam, lparam)
  PROCNAMEC()
  ; IDENTICAL CODE TO WMN_callback_window() in fmMain.pbi
  ; see note at start of WMN_callback_window()
  
  Select uMsg
    Case #WM_RBUTTONDOWN
      ; Debug "window right button down"
      debugMsg(sProcName, "window right button down")
      ProcedureReturn 0
      
    Case #WM_NCRBUTTONDOWN
      ; Debug "window nonclient right button down"
      debugMsg(sProcName, "window nonclient right button down")
      ProcedureReturn 0
      
      ; 8May2017 11.6.1bd: commented out processing #WM_KEYDOWN, #WM_KEYUP and #WM_SYSKEYDOWN as these are now handled by keyboard shortcuts
      ; (changed because if they're not handled by keyboard shortcuts and activae gadget is -1 then Windows sounds 'default beep', as reported by Malcolm Gordon)
;     Case #WM_KEYDOWN
;       Debug sProcName + ": #WM_KEYDOWN uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam
;       WMN_processKeyCallback(uMsg, wParam, lParam)
;       
;     Case #WM_KEYUP
;       Debug sProcName + ": #WM_KEYUP uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam
;       WMN_processKeyCallback(uMsg, wParam, lParam)
;       
;     Case #WM_SYSKEYDOWN
;       Debug sProcName + ": #WM_SYSKEYDOWN uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam
;       WMN_processKeyCallback(uMsg, wParam, lParam)
;       ; system key (eg F10) so return 0 to cancel Windows default processing
;       ProcedureReturn 0
      
      ; 8May2017 11.6.1bd comment: still need to retain processing of #WM_SYSKEYUP to handle 'key up' event for note hotkeys
    Case #WM_SYSKEYUP
      ; Debug sProcName + ": #WM_SYSKEYUP uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam
      debugMsg(sProcName, "#WM_SYSKEYUP uMsg=" + uMsg + ", wParam=" + wParam + ", lParam=" + lParam)
      WMN_processKeyCallback(uMsg, wParam, lParam)
      ; system key (eg F10) so return 0 to cancel Windows defaut processing
      ProcedureReturn 0
      
    Default
      ; debugMsg(sProcName, "uMsg=" + Str(uMsg) + ", $" + Hex(uMsg,#PB_Long))
      ProcedureReturn #PB_ProcessPureBasicEvents
      
  EndSelect
  ProcedureReturn #PB_ProcessPureBasicEvents
EndProcedure

Procedure WCN_displayFadersWindowIfReqd()
  PROCNAMEC()
  Protected nDevMapPtr
  
  If gbFadersDisplayed
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      ; 28Dec2015 added test on #cAlwaysUseMixerForBass
      CompilerIf #cAlwaysUseMixerForBass
        WCN_Form_Show()
      CompilerElse
        If (grMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_DS Or grMaps\aMap(nDevMapPtr)\nAudioDriver = #SCS_DRV_BASS_WASAPI) And (grDriverSettings\bUseBASSMixer = #False)
          ; ignore
        Else
          WCN_Form_Show()
        EndIf
      CompilerEndIf
    EndIf
  EndIf
  
EndProcedure

Procedure WCN_setInputEQOnState(nDevMapDevPtr)
  PROCNAMEC()
  
  If nDevMapDevPtr >= 0
    With grMaps\aDev(nDevMapDevPtr)
      If (\bInputLowCutSelected) Or (\aInputEQBand[0]\bEQBandSelected) Or (\aInputEQBand[1]\bEQBandSelected)
        \bInputEQOn = #True
      Else
        \bInputEQOn = #False
      EndIf
      debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\bInputLowCutSelected=" + strB(\bInputLowCutSelected) + ", \aInputEQBand[0]\bEQBandSelected=" + strB(\aInputEQBand[0]\bEQBandSelected) + ", \aInputEQBand[1]\bEQBandSelected=" + strB(\aInputEQBand[1]\bEQBandSelected) + ", \bInputEQOn=" + strB(\bInputEQOn))
    EndWith
  EndIf
EndProcedure

Procedure WCN_drawFaderAssignmentsIfReqd()
  PROCNAMEC()
  Protected bDrawFaderAssignments
  Protected n, nMax
  Protected nLeft, nWidth, nHeight, nMinWindowWidth
  Protected sText.s, nTextLeft, nTextTop, nTextWidth, nTextHeight
  Protected bDisplayThis, bAssigned
  Protected nFrontColor, nBackColor
  Protected nCtrlCount, nController
  Protected sAssignedText1.s, sAssignedText2.s, sAssignToText1.s, sCtrlConfigText.s
  Protected nBtnCloseX, nBtnSetupX, nWindowWidthChange
  Static sNotAssigned.s, sAssignToBCR.s, sAssignedToBCR.s, sAssignToBCF.s, sAssignedToBCF.s, sAssignToNK2.s, sAssignedToNK2Sliders.s, sAssignedToNK2Knobs.s, sCtrlConfig.s
  Static bStaticLoaded
  
  debugMsg(sProcName, #SCS_START + ", grCtrlSetup\nController=" + decodeController(grCtrlSetup\nController))
  
  If bStaticLoaded = #False
    sNotAssigned = Lang("WCM", "NONE") ; NB Language group WCM as this is also used in fmCtrlSetup and is the same
    sAssignToBCR = LangPars("WCN", "Assign", "BCR")
    sAssignedToBCR = LangPars("WCN", "Assigned", "BCR")
    sAssignToBCF = LangPars("WCN", "Assign", "BCF")
    sAssignedToBCF = LangPars("WCN", "Assigned", "BCF")
    sAssignToNK2 = LangPars("WCN", "Assign", "NK2")
    sAssignedToNK2Sliders = LangPars("WCN", "AssignedSliders", "NK2")
    sAssignedToNK2Knobs = LangPars("WCN", "AssignedKnobs", "NK2")
    sCtrlConfig = Lang("WCM", "lblCtrlConfig") + ": " ; nb using the WCM label lblCtrlConfig
    bStaticLoaded = #True
  EndIf
  
  With WCN
    CompilerIf #c_Test_BCF2000_using_BCR2000
      nController = #SCS_CTRL_BCF2000
    CompilerElse
      nController = grCtrlSetup\nController
    CompilerEndIf
    
    Select nController
      Case #SCS_CTRL_NK2
        nMax = 2
        sAssignedText1 = sAssignedToNK2Sliders
        sAssignedText2 = sAssignedToNK2Knobs
        sAssignToText1 = sAssignToNK2
        sCtrlConfigText = decodeCtrlConfigL(grCtrlSetup\nCtrlConfig)
      Case #SCS_CTRL_BCF2000
        nMax = 1
        sAssignedText1 = sAssignedToBCF
        sAssignToText1 = sAssignToBCF
        sCtrlConfigText = decodeCtrlConfigL(grCtrlSetup\nCtrlConfig)
      Case #SCS_CTRL_BCR2000
        nMax = 1
        sAssignedText1 = sAssignedToBCR
        sAssignToText1 = sAssignToBCR
        sCtrlConfigText = decodeCtrlConfigL(grCtrlSetup\nCtrlConfig)
      Case #SCS_CTRL_NONE
        nMax = 1
        sAssignedText1 = sNotAssigned
      Default
        nMax = 1
    EndSelect
    debugMsg(sProcName, "nController=" + decodeController(nController) + ", sAssignedText1=" + sAssignedText1 + ", sAssignToText1=" + sAssignToText1)
    
    For n = 0 To nMax
      bDisplayThis = #False
      bAssigned = #False ; used to determine the colours (background and text) to be used for the displayed "Assigned ..." text
      Select n
        Case 0
          ; live inputs 1-8
          If \nLiveInputCtrls > 0
            nCtrlCount = \nLiveInputCtrls
            If nCtrlCount > 8
              nCtrlCount = 8  ; 8 is number of faders on BCF2000
            EndIf
            bDisplayThis = #True
            nLeft = GadgetX(\cvsInputTitle) + 1
            nWidth = (nCtrlCount * \nCtrlWidth) + ((nCtrlCount - 1) * \nCtrlGap) - 2
            sText = sAssignedText1
            If grGeneralOptions\nFaderAssignments = #SCS_FADER_INPUTS_1_8
              bAssigned = #True
            EndIf
          EndIf
          
        Case 1
          ; outputs 1-7 or playing outputs 1-7, and master
          ; nb 'outputs' and 'playing' are mutually exclusive, with 'playing' used only by NK2 Preset C
          nCtrlCount = \nOutputCtrls + \nPlayingCtrls + \nMasterCtrls
          If nCtrlCount > 8
            nCtrlCount = 8  ; 8 is number of faders on BCF2000 and NK2
          EndIf
          If grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
            nCtrlCount + \nDMXMasterCtrls
          EndIf
          bDisplayThis = #True
          If IsGadget(\cvsOutputTitle)
            nLeft = GadgetX(\cvsOutputTitle) + 1
          ElseIf IsGadget(\cvsPlayingTitle)
            nLeft = GadgetX(\cvsPlayingTitle) + 1
          EndIf
          nWidth = (nCtrlCount * \nCtrlWidth) + ((nCtrlCount - 1) * \nCtrlGap) - 2
          Select grGeneralOptions\nFaderAssignments
            Case #SCS_FADER_OUTPUTS_1_7_M, #SCS_FADER_PLAYING_1_7_M
              sText = sAssignedText1
              bAssigned = #True
            Default
              sText = sAssignToText1
              bAssigned = #False
          EndSelect
          debugMsg(sProcName, "n=" + n + ", nCtrlCount=" + nCtrlCount + ", sText=" + sText + ", bAssigned=" + strB(bAssigned))
          
        Case 2
          ; dimmer channels on NK2
          If \nDimmerChanCtrls > 0
            If grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
              nCtrlCount = \nDimmerChanCtrls
              If nCtrlCount > 8
                nCtrlCount = 8  ; 8 is number of faders on the NK2
              EndIf
              bDisplayThis = #True
              nLeft = GadgetX(\cvsDimmerChanTitle) + 1
              nWidth = (nCtrlCount * \nCtrlWidth) + ((nCtrlCount - 1) * \nCtrlGap) - 2
              Select nController
                Case #SCS_CTRL_NK2
                  sText = sAssignedText2
                  bAssigned = #True
              EndSelect
            EndIf
          EndIf
          
      EndSelect
      
      ; debugMsg(sProcName, "n=" + n + ", bDisplayThis=" + strB(bDisplayThis) + ", nLeft=" + nLeft + ", nWidth=" + nWidth)
      If bDisplayThis
        ResizeGadget(\cvsFaderAssignments[n],nLeft,#PB_Ignore,nWidth,#PB_Ignore)
        If StartDrawing(CanvasOutput(\cvsFaderAssignments[n]))
          If bAssigned And nController <> #SCS_CTRL_NONE
            nFrontColor = #SCS_Black
            nBackColor = #SCS_Green
          Else
            nFrontColor = #SCS_Black
            nBackColor = #SCS_Light_Grey
          EndIf
          nWidth = OutputWidth()
          nHeight = OutputHeight()
          Box(0,0,nWidth,nHeight,#SCS_Dark_Grey)
          Box(1,1,nWidth-2,nHeight-2,nBackColor)
          If sText
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            DrawingMode(#PB_2DDrawing_Transparent)
            nTextWidth = TextWidth(sText)
            If nTextWidth >= nWidth
              nTextLeft = 0
            Else
              nTextLeft = (nWidth - nTextWidth) >> 1
            EndIf
            nTextHeight = TextHeight("gG")  ; force all text to same height, ie same Y position
            nTextTop = (nHeight - nTextHeight) >> 1
            DrawText(nTextLeft, nTextTop, sText, nFrontColor)
          EndIf
          StopDrawing()
        EndIf
        setVisible(\cvsFaderAssignments[n], #True)
      Else
        setVisible(\cvsFaderAssignments[n], #False)
      EndIf
    Next n
    
    If sCtrlConfigText
      SGT(\lblCtrlConfig, sCtrlConfig + sCtrlConfigText)
      setGadgetWidth(\lblCtrlConfig)
      setVisible(\lblCtrlConfig, #True)
      nMinWindowWidth = (GadgetX(\lblCtrlConfig) * 2) + GadgetWidth(\lblCtrlConfig)
      If nMinWindowWidth > WindowWidth(#WCN)
        nWindowWidthChange = nMinWindowWidth - WindowWidth(#WCN)
        nBtnCloseX = GadgetX(\btnClose)
        nBtnSetupX = GadgetX(\btnSetup)
        ResizeWindow(#WCN, #PB_Ignore, #PB_Ignore, nMinWindowWidth, #PB_Ignore)
        ResizeGadget(\btnClose, nBtnCloseX + nWindowWidthChange, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        ResizeGadget(\btnSetup, nBtnSetupX + nWindowWidthChange, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
    Else
      setVisible(\lblCtrlConfig, #False)
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_turnOnLiveInputForSolo(nCtrlNo)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nCtrlNo=" + Str(nCtrlNo))
  
  With WCN\aController(nCtrlNo)
    If \nWCNCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
      If \bLiveOn = #False
        ; not currently turned on
        setInputGain(\nWCNDevNo)
      EndIf
    EndIf
  EndWith
  WCN_setLiveOnInds()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WCN_enableDMXMasterFaderIfReqd()
  PROCNAMEC()
  Protected bDMXOutDevPresent, bEnableFader
  
  With WCN
    If SLD_isSlider(\sldDMXMasterFader)
      bDMXOutDevPresent = DMX_IsDMXOutDevPresent()
      If bDMXOutDevPresent
        bEnableFader = #True
      EndIf
      If SLD_getEnabled(\sldDMXMasterFader) <> bEnableFader
        SLD_setEnabled(\sldDMXMasterFader, bEnableFader)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure WCN_getControllerIndex(nCtrlType, nCtrlNo)
  ; PROCNAMEC()
  Protected n, nControllerIndex
  
  nControllerIndex = -1
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = nCtrlType
        If \nWCNCtrlType = #SCS_CTRLTYPE_DMX_MASTER
          nControllerIndex = n
          Break
        ElseIf \nWCNCtrlNo = nCtrlNo
          nControllerIndex = n
          Break
        EndIf
      EndIf
    EndWith
  Next n
  ; debugMsg0(sProcName, "nControllerIndex=" + nControllerIndex)
  ProcedureReturn nControllerIndex
EndProcedure

Procedure WCN_refreshDimmerChannelFaders()
  PROCNAMEC()
  Protected n, nItemIndex, dSliderValue.d, dDMXMasterFaderValue.d, nSliderValue
  Static nPrevDMXMasterFaderValue = -1
  
  If grWQK\bProcessingReset ; See comments near the top of DMX_displayDMXSendData() regarding why this test is included
    ProcedureReturn
  EndIf
  
  WCN\bRefreshDimmerChannelFaders = #False
  If gbClosingDown
    ProcedureReturn
  EndIf
  
; debugMsg0(sProcName, "grDMXMasterFader\nDMXMasterFaderValue=" + grDMXMasterFader\nDMXMasterFaderValue + ", nPrevDMXMasterFaderValue=" + nPrevDMXMasterFaderValue)
  If grDMXMasterFader\nDMXMasterFaderValue <> nPrevDMXMasterFaderValue And nPrevDMXMasterFaderValue >= 0
    nPrevDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderValue
    ProcedureReturn
  Else
    nPrevDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderValue
  EndIf
  dDMXMasterFaderValue = grDMXMasterFader\nDMXMasterFaderValue
  
  For n = 1 To WCN\nNrOfControllers
    With WCN\aController(n)
      If \nWCNCtrlType = #SCS_CTRLTYPE_DIMMER_CHANNEL
        nItemIndex = \nWCNDMXSendItemIndex
        If gaDMXSendOrigin(nItemIndex) <> #SCS_DMX_ORIGIN_MASTER_FADER
          dSliderValue = (gaDMXSendData(nItemIndex) * 100.0) / 255.0
          If dDMXMasterFaderValue < 100.0
            dSliderValue = (dSliderValue * 100.0) / dDMXMasterFaderValue
          EndIf
          If dSliderValue <> \dWCNPrevValue
            ; debugMsg0(sProcName, "dDMXMasterFaderValue=" + StrD(dDMXMasterFaderValue,2) + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) + ", n=" + n + ", dSliderValue=" + StrD(dSliderValue,2) + ", WCN\aController(" + n + ")\dWCNPrevValue=" + StrD(\dWCNPrevValue,2))
            \dWCNPrevValue = dSliderValue
            nSliderValue = dSliderValue
            ; debugMsg(sProcName, "calling WCN_setFader(" + decodeCtrlType(\nWCNCtrlType) + ", CtrlNo=" + \nWCNCtrlNo + ", nSliderValue=" + nSliderValue + ", #False, #True)")
            WCN_setFader(\nWCNCtrlType, \nWCNCtrlNo, nSliderValue, #False, #True)
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
EndProcedure

Procedure WCN_refreshAudioChannelFaders()
  ; PROCNAMEC()
  Protected nCtrlNo, nDevMapDevPtr, nSubPtr, nAudPtr, d
  Protected bSendControllerMsg, bIgnoreFieldControl
  
  ; debugMsg0(sProcName, #SCS_START)
  
  WCN\bRefreshAudioChannelFaders = #False

  If gbClosingDown
    ProcedureReturn
  EndIf
  
  Select grCtrlSetup\nCtrlConfig
    Case #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_C
      bSendControllerMsg = #True
      bIgnoreFieldControl = #True
    Default
      bSendControllerMsg = #False
      bIgnoreFieldControl = #True
  EndSelect
  
  For nCtrlNo = 1 To WCN\nNrOfControllers
    With WCN\aController(nCtrlNo)
      ; debugMsg0(sProcName, "WCN\aController(" + nCtrlNo + ")\nWCNDevMapDevPtr=" + WCN\aController(nCtrlNo)\nWCNDevMapDevPtr)
      nDevMapDevPtr = \nWCNDevMapDevPtr
      If nDevMapDevPtr >= 0
        ; debugMsg0(sProcName, "WCN\aController(" + nCtrlNo + ")\nWCNCtrlType=" + decodeCtrlType(\nWCNCtrlType))
        Select \nWCNCtrlType
          Case #SCS_CTRLTYPE_OUTPUT ; #SCS_CTRLTYPE_OUTPUT
            ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\fDevOutputGain=" + traceLevel(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain) +
            ;                     "< grMaps\aDev(" + nDevMapDevPtr + ")\fDevFaderOutputGain=" + traceLevel(grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain))
            WCN_setFader(\nWCNCtrlType, nCtrlNo, SLD_BVLevelToSliderValue(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain), bSendControllerMsg, bIgnoreFieldControl)
            
          Case #SCS_CTRLTYPE_PLAYING
            nSubPtr = WCN\nPlayingSubTypeF
            If nSubPtr >= 0
              nAudPtr = aSub(nSubPtr)\nFirstAudIndex
              For d = aAud(nAudPtr)\nFirstDev To aAud(nAudPtr)\nLastDev
                If aAud(nAudPtr)\sLogicalDev[d]
                  If WCN_getCtrlNoForLogicalDev(#SCS_CTRLTYPE_PLAYING, aAud(nAudPtr)\sLogicalDev[d]) = nCtrlNo
                    ; debugMsg(sProcName, "calling WCN_setFader(#SCS_CTRLTYPE_PLAYING, " + nCtrlNo + ", " + SLD_BVLevelToSliderValue(aAud(nAudPtr)\fCueTotalVolNow[d]) + ", " + strB(bSendControllerMsg) + ", " + strB(bIgnoreFieldControl) + ")")
                    WCN_setFader(#SCS_CTRLTYPE_PLAYING, nCtrlNo, SLD_BVLevelToSliderValue(aAud(nAudPtr)\fCueTotalVolNow[d]), bSendControllerMsg, bIgnoreFieldControl)
                  EndIf
                  Break ; Break d
                EndIf
              Next d
            EndIf
        EndSelect
      EndIf
    EndWith
  Next nCtrlNo
  
EndProcedure

Procedure WCN_getNextCuePtr()
  ; Added 16Jul2022 11.9.4
  PROCNAMEC()
  Protected i, nNextCuePtr
  
  ; Logic based on code in setCueToGo(), but for this procedure we need to know the next cue to fire, whether or not it is a manual start cue
  
  nNextCuePtr = -1
  For i = 1 To gnLastCue
    With aCue(i)
      If (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False) And ((\nCueState >= #SCS_CUE_COUNTDOWN_TO_START) And (\nCueState <= #SCS_CUE_FADING_OUT))
        ; no action
      ElseIf (\bCueCurrentlyEnabled) And (\bCueSubsAllDisabled = #False) And (\nCueState <> #SCS_CUE_IGNORED) And (\bHoldAutoStart = #False)
        If \nCueState <= #SCS_CUE_READY
          ; debugMsg(sProcName, ".. \bHotkey=" + strB(\bHotkey) + ", \bExtAct=" + strB(\bExtAct) + ", \bCallableCue=" + strB(\bCallableCue))
          If (\bHotkey = #False) And (\bExtAct = #False) And (\bCallableCue = #False)
            nNextCuePtr = i
            Break
          EndIf
        EndIf
      EndIf
    EndWith
  Next i
  ProcedureReturn nNextCuePtr ; will return -1 if no 'next cue' found
  
EndProcedure

Procedure.s WCN_getDimmerIndexFixtureCode(nDimmerIndex)
  PROCNAMEC()
  ; NB this procedure may be called even if the controller window is not displayed
  Protected sReqdFixtureCode.s
  Protected nCtrlNo, d2, d3, d4, n, n2, sLogicalDev.s, nDevMapDevPtr, sFixtureCode.s, sFixTypeName.s, nDimmerChannelCount, nDevDMXStartChannel, nIndex
  
  If gbDMXAvailable
    If DMX_IsDMXOutDevPresent()
      nCtrlNo = 0
      For d2 = 0 To grProd\nMaxLightingLogicalDev
        sLogicalDev = grProd\aLightingLogicalDevs(d2)\sLogicalDev
        If sLogicalDev
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, sLogicalDev)
          If nDevMapDevPtr >= 0
            ; debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d2 + ")\nMaxFixture=" + grProd\aLightingLogicalDevs(d2)\nMaxFixture)
            For n = 0 To grProd\aLightingLogicalDevs(d2)\nMaxFixture
              sFixtureCode = Trim(grProd\aLightingLogicalDevs(d2)\aFixture(n)\sFixtureCode)
              sFixTypeName = Trim(grProd\aLightingLogicalDevs(d2)\aFixture(n)\sFixTypeName)
              ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", sFixTypeName=" + sFixTypeName)
              nDimmerChannelCount = 0
              For d3 = 0 To grLicInfo\nMaxFixTypePerProd
                If d3 <= grProd\nMaxFixType
                  If grProd\aFixTypes(d3)\sFixTypeName = sFixTypeName
                    For n2 = 0 To grProd\aFixTypes(d3)\nTotalChans - 1
                      If grProd\aFixTypes(d3)\aFixTypeChan(n2)\bDimmerChan
                        ; debugMsg(sProcName, "grProd\aFixTypes(" + d3 + ")\aFixTypeChan(" + n2 + ")\sChannelDesc=" + grProd\aFixTypes(d3)\aFixTypeChan(n2)\sChannelDesc + ", \bDimmerChan=" + grProd\aFixTypes(d3)\aFixTypeChan(n2)\bDimmerChan)
                        nDimmerChannelCount + 1
                      EndIf
                    Next n2
                    Break ; Break d3 after matching sFixTypeName
                  EndIf
                EndIf
              Next d3
              If nDimmerChannelCount = 1
                ; only single-dimmer-channel fixtures included in dimmer channel controls
                For d4 = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
                  If grMaps\aDev(nDevMapDevPtr)\aDevFixture(d4)\sDevFixtureCode = sFixtureCode
                    nDevDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(d4)\nDevDMXStartChannel
                    If nDevDMXStartChannel > 0
                      nIndex + 1
                      If nIndex = nDimmerIndex
                        sReqdFixtureCode = sFixtureCode
                        Break 3 ; Break d4, n, d2
                      EndIf
                    EndIf
                  EndIf
                Next d4
              EndIf ; EndIf nDimmerChannelCount = 1
            Next n
          EndIf ; EndIf nDevMapDevPtr >= 0
        EndIf ; EndIf sLogicalDev
      Next d2
    EndIf ; EndIf DMX_IsDMXOutDevPresent()
  EndIf ; EndIf gbDMXAvailable
  
;   If sReqdFixtureCode
;     debugMsg(sProcName, "nDimmerIndex=" + nDimmerIndex + ", returning " + #DQUOTE$ + sReqdFixtureCode + #DQUOTE$)
;   EndIf
  ProcedureReturn sReqdFixtureCode
  
EndProcedure

Procedure WCN_setPlayingControlsIfReqd(bInitialSetting=#False)
  PROCNAMEC()
  Protected nEarliestPlayingSubTypeF, nAudPtr, nCtrlNo, d
  Protected sText.s, nTextLeft, nTextTop, nTextWidth
  Protected bSendControllerMsg, bIgnoreFieldControl
  
  ; debugMsg(sProcName, #SCS_START + ", bInitialSetting=" + strB(bInitialSetting))
  
  Select grCtrlSetup\nCtrlConfig
    Case #SCS_CTRLCONF_NK2_PRESET_C
      bSendControllerMsg = #False
      bIgnoreFieldControl = #True
    Case #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_C
      bSendControllerMsg = #True
      bIgnoreFieldControl = #True
    Default
      ProcedureReturn
  EndSelect
  
  nEarliestPlayingSubTypeF = getEarliestPlayingSubTypeF()
  ; debugMsg0(sProcName, "nEarliestPlayingSubTypeF=" + getSubLabel(nEarliestPlayingSubTypeF))
  If bInitialSetting = #False And nEarliestPlayingSubTypeF = WCN\nPlayingSubTypeF
    ; debugMsg0(sProcName, "no changes")
    ; no changes required, either because the earliest playing sub hasn't changed, or that there is no playing sub type F and that was also the last state recorded in WCN\nPlayingSubPtr
    ; but continue if bInitialSetting = #True, eg when called from WCN_Form_Show()
    ProcedureReturn
  EndIf
  
  ; some changes required
  ; initially set all 'playing' faders to -INF (displayed as 'X' as they will be disabled)
  For nCtrlNo = 1 To WCN\nNrOfControllers
    If WCN\aController(nCtrlNo)\nWCNCtrlType = #SCS_CTRLTYPE_PLAYING
      ; 'set enabled #True' must be called BEFORE calling WCN_setFader() as WCN_setFader() checks the enabled state
      SLD_setEnabled(WCN\aController(nCtrlNo)\sldLevelOrValue, #True) ; set true before calling WCN_setFader() so that the fader level will be set to 0 (-INF)
      ; debugMsg(sProcName, "calling WCN_setFader(#SCS_CTRLTYPE_PLAYING, " + nCtrlNo + ", 0, " + strB(bSendControllerMsg) + ", " + strB(bIgnoreFieldControl) + ")")
      WCN_setFader(#SCS_CTRLTYPE_PLAYING, nCtrlNo, 0, bSendControllerMsg, bIgnoreFieldControl)
      ; Now disable the fader (which will also change '-INF' to 'X')
      SLD_setEnabled(WCN\aController(nCtrlNo)\sldLevelOrValue, #False)
      wCN\aController(nCtrlNo)\bSliderValueMatched = #False
      ; The fader will be re-enabled in the code below if this device is used by the earliest playing sub type F
    EndIf
  Next nCtrlNo
  
  If nEarliestPlayingSubTypeF >= 0
    If aSub(nEarliestPlayingSubTypeF)\bSubTypeA
      ; continue with just type F until we have sorted out better how to handle a video audio fader
;       With aSub(nEarliestPlayingSubTypeF)
;         If \sVidAudLogicalDev
;           nCtrlNo = WCN_getCtrlNoForLogicalDev(#SCS_CTRLTYPE_PLAYING, \sVidAudLogicalDev)
;           debugMsg0(sProcName, "aSub(" + getSubLabel(nEarliestPlayingSubTypeF) + ")\sVidAudLogicalDev=" + \sVidAudLogicalDev + ", nCtrlNo=" + nCtrlNo)
;           If nCtrlNo >= 0
;             SLD_setEnabled(WCN\aController(nCtrlNo)\sldLevelOrValue, #True) ; 'set enabled #True' must be called BEFORE calling WCN_setFader() as WCN_setFader() checks the enabled state
;             ; debugMsg0(sProcName, "calling WCN_setFader(#SCS_CTRLTYPE_PLAYING, " + nCtrlNo + ", " + SLD_BVLevelToSliderValue(\fSubMastBVLevel[0]) + ", #False, #True)")
;             WCN_setFader(#SCS_CTRLTYPE_PLAYING, nCtrlNo, SLD_BVLevelToSliderValue(\fSubMastBVLevel[0]), #False, #True)
;           EndIf
;         EndIf
;       EndWith
    Else
      nAudPtr = aSub(nEarliestPlayingSubTypeF)\nFirstAudIndex
      ; debugMsg0(sProcName, "nEarliestPlayingSubTypeF=" + getSubLabel(nEarliestPlayingSubTypeF) + ", nAudPtr=" + getAudLabel(nAudPtr) + ", bInitialSetting=" + bInitialSetting)
      With aAud(nAudPtr)
        For d = \nFirstDev To \nLastDev
          If \sLogicalDev[d]
            nCtrlNo = WCN_getCtrlNoForLogicalDev(#SCS_CTRLTYPE_PLAYING, \sLogicalDev[d])
            If nCtrlNo >= 0
              SLD_setEnabled(WCN\aController(nCtrlNo)\sldLevelOrValue, #True) ; 'set enabled #True' must be called BEFORE calling WCN_setFader() as WCN_setFader() checks the enabled state
              ; debugMsg(sProcName, "calling WCN_setFader(#SCS_CTRLTYPE_PLAYING, " + nCtrlNo + ", " + SLD_BVLevelToSliderValue(\fCueTotalVolNow[d]) + ", " + strB(bSendControllerMsg) + ", " + strB(bIgnoreFieldControl) + ")")
              WCN_setFader(#SCS_CTRLTYPE_PLAYING, nCtrlNo, SLD_BVLevelToSliderValue(\fCueTotalVolNow[d]), bSendControllerMsg, bIgnoreFieldControl)
            EndIf
          EndIf
        Next d
      EndWith
    EndIf
  Else
    ; no currently playing Sub Type F
  EndIf
  
  WCN\nPlayingSubTypeF = nEarliestPlayingSubTypeF ; nb will be -1 if no currently playing sub type F
  
  ; Redraw title
  If IsGadget(WCN\cvsPlayingTitle)
    If StartDrawing(CanvasOutput(WCN\cvsPlayingTitle))
      Box(1, 1, OutputWidth()-2, OutputHeight()-2, #SCS_White) ; Clear existing title. PB Help states that background colour of a canvas gadget is white, and we haven't changed that
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      If WCN\nPlayingSubTypeF < 0
        sText = "" ; (was: grText\sTextLevel ; "Level")
      Else
        sText = getSubLabel(WCN\nPlayingSubTypeF)
      EndIf
      nTextWidth = TextWidth(sText)
      If nTextWidth < (OutputWidth()-1)
        nTextLeft = (OutputWidth()-1 - nTextWidth) >> 1
      Else
        nTextLeft = 1
      EndIf
      nTextTop = 1 ; 'top' setting used in createfmControllers()
      DrawText(nTextLeft,nTextTop,sText,#SCS_Dark_Grey)
      StopDrawing()
    EndIf
  EndIf

  ; debugMsg0(sProcName, #SCS_END + ", WCN\nPlayingSubTypeF=" + getSubLabel(WCN\nPlayingSubTypeF))
  
EndProcedure

; EOF