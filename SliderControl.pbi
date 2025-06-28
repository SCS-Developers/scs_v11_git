; file SliderControl.pbi

EnableExplicit

; INFO: Slider Drawing logic (DO NOT DELETE)
; SLD_drawSlider
;   SLD_drawBoxes
;     BOX(…)
;   SLD_drawButton
;     SLD_drawCaption (if level change) – then exit
;     SLD_drawKnob (if rotary gain) – then exit
;     SLD_drawScrollBar (if scrollbar) – then exit
;     BOX(…)
;     If horizontal:
;       DrawText(left)
;       DrawText(right)
;       SLD_drawAudioGraph (if audio graph slider)
;       If not audio graph, or if SLD_drawAudioGraph failed:
;         Draw gutter
;         SLD_drawTickLines
;       SLD_drawLvlPts
;       If base (white) pointer required:
;         SLD_drawPointer (white)
;       If audio graph
;         Draw vertical line for current position
;       Else
;         SLD_drawPointer
;       End If
;     If vertical:
;       DrawText(top)
;       DrawText(bottom)
;       If not 'vertical fader':
;         Draw gutter
;         SLD_drawTickLines
;       If base (white) pointer required:
;         SLD_drawPointer (white)
;       If audio graph
;         Draw vertical line for current position
;       Else
;         SLD_drawPointer
;       End If
; INFO: End of Slider Drawing logic

Procedure SLD_isSlider(nSldPtr)
  Protected bIsSlider
  
  If nSldPtr > 0
    If IsGadget(gaSlider(nSldPtr)\cvsSlider)
      bIsSlider = #True
    EndIf
  EndIf
  ProcedureReturn bIsSlider
EndProcedure

Procedure.s SLD_decodeEvent(nSliderEvent)
  Protected sDecoded.s
  
  Select nSliderEvent
    Case #SCS_SLD_EVENT_NONE
      sDecoded = "#SCS_SLD_EVENT_NONE"
    Case #SCS_SLD_EVENT_MOUSE_DOWN
      sDecoded = "#SCS_SLD_EVENT_MOUSE_DOWN"
    Case #SCS_SLD_EVENT_MOUSE_MOVE
      sDecoded = "#SCS_SLD_EVENT_MOUSE_MOVE"
    Case #SCS_SLD_EVENT_MOUSE_UP
      sDecoded = "#SCS_SLD_EVENT_MOUSE_UP"
    Case #SCS_SLD_EVENT_SCROLL
      sDecoded = "#SCS_SLD_EVENT_SCROLL"
    Case #SCS_SLD_EVENT_GOT_FOCUS
      sDecoded = "#SCS_SLD_EVENT_GOT_FOCUS"
    Case #SCS_SLD_EVENT_LOST_FOCUS
      sDecoded = "#SCS_SLD_EVENT_LOST_FOCUS"
    Default
      sDecoded = Str(nSliderEvent)
  EndSelect
  ProcedureReturn sDecoded
EndProcedure

Procedure SLD_fcSliderType(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nAMarks, nBMarks, nCMarks, nDMarks, nFaderInfoIndex
  Protected nCuePanelNo, d, nDevNo, nAudPtr
  
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "\nSliderType=" + \nSliderType + ", \nCuePanelNo=" + \nCuePanelNo + ", \nDevNo=" + \nDevNo)
    nCuePanelNo = \nCuePanelNo
    nDevNo = \nDevNo
    
    If IsFont(\fontLabels)
      \nLblFontId = FontID(\fontLabels)
    EndIf
    \bUseInfinityFont = #False
    
    \bHorizontal = #True
    \nButtonStyle = #SCS_BUTTON_POINTER
    \m_BackColor = #SCS_SLD_BACKCOLOR
    \m_GtrAreaBackColor = -1
    \bFader = #False
    \bLevelSlider = #False
    
    nFaderInfoIndex = 0
    Select \nSliderType
      Case #SCS_ST_PROGRESS
        \btnColor1 = #SCS_Progress_Color
        \btnColor2 = #SCS_Progress_Color
        \sldNumDiv = 8     ; number of division segments
        
      Case #SCS_ST_POSITION
        \btnColor1 = #SCS_Position_Color
        \btnColor2 = #SCS_Position_Color
        \sldNumDiv = 8     ; number of division segments
        
      Case #SCS_ST_PAN
        \m_Max = #SCS_MAXPAN_SLD
        \btnColor1 = #SCS_Pan_Color
        \btnColor2 = #SCS_Pan_Color
        \sldNumDiv = 4     ; number of division segments
        \sLeftText = "L"
        \sRightText = "R"
        
      Case #SCS_ST_PANNOLR
        \m_Max = #SCS_MAXPAN_SLD
        \btnColor1 = #SCS_Pan_Color
        \btnColor2 = #SCS_Pan_Color
        \sldNumDiv = 4     ; number of division segments
        
      Case #SCS_ST_HLEVELRUN
        \m_Max = #SCS_MAXVOLUME_SLD
        \btnColor1 = #SCS_Level_Color
        \btnColor2 = #SCS_Level_Color
        \bLevelSlider = #True
        
      Case #SCS_ST_HLEVELNODB
        \m_Max = #SCS_MAXVOLUME_SLD
        \btnColor1 = #SCS_Level_Color
        \btnColor2 = #SCS_Level_Color
        \bLevelSlider = #True
        
      Case #SCS_ST_HLEVELCHANGERUN, #SCS_ST_HLEVELCHANGERUNPL
        \bLevelSlider = #True
        ; no buttons etc - just displays text like "Target = Current -3.0dB"
        
      Case #SCS_ST_HPERCENT
        \btnColor1 = #SCS_Percent_Color
        \btnColor2 = #SCS_Percent_Color
        \sldNumDiv = \m_Max / 20  ; eg 5 division segments if m_Max = 100 (100%), 10 division segments if m_max = 200 (200%)
        
      Case #SCS_ST_HLIGHTING_PERCENT
        \nButtonStyle = #SCS_BUTTON_LIGHTING
        \btnColor1 = #SCS_Yellow
        \sldNumDiv = \m_Max / 20  ; eg 5 division segments if m_Max = 100 (100%), 10 division segments if m_max = 200 (200%)
        
      Case #SCS_ST_HGENERAL
        ; \nButtonStyle = #SCS_BUTTON_ROUNDED_BOX
        \nButtonStyle = #SCS_BUTTON_HBOX
        \btnColor1 = #SCS_General_Color1
        \btnColor2 = #SCS_General_Color2
        \sldNumDiv = 2     ;Number of division segments
        
      Case #SCS_ST_HLIGHTING_GENERAL
        \nButtonStyle = #SCS_BUTTON_LIGHTING
        \btnColor1 = #SCS_Yellow
        \sldNumDiv = 2 ; Number of division segments
        
      Case #SCS_ST_VGENERAL
        \bHorizontal = #False
        ; \nButtonStyle = #SCS_BUTTON_ROUNDED_BOX
        \nButtonStyle = #SCS_BUTTON_VBOX
        \btnColor1 = #SCS_General_Color1
        \btnColor2 = #SCS_General_Color2
        \sldNumDiv = 2 ; Number of division segments
        
      Case #SCS_ST_VFADER_LIVE_INPUT, #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_PLAYING, #SCS_ST_VFADER_MASTER, #SCS_ST_VFADER_DMX_MASTER, #SCS_ST_VFADER_DIMMER_CHAN
        \bHorizontal = #False
        \m_BackColor = #SCS_SLD_FADER_BACKCOLOR
        \m_GtrAreaBackColor = -1
        Select \nSliderType
          Case #SCS_ST_VFADER_LIVE_INPUT
            \nButtonStyle = #SCS_BUTTON_FADER_LIVE_INPUT
            \nImageNo = hSlThumbLiveInput
          Case #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_PLAYING
            \nButtonStyle = #SCS_BUTTON_FADER_OUTPUT
            \nImageNo = hSLThumbOutput
          Case #SCS_ST_VFADER_MASTER
            \nButtonStyle = #SCS_BUTTON_FADER_MASTER
            \nImageNo = hSlThumbMaster
          Case #SCS_ST_VFADER_DMX_MASTER
            \nButtonStyle = #SCS_BUTTON_FADER_DMX_MASTER
            \nImageNo = hSlThumbDMXMaster
          Case #SCS_ST_VFADER_DIMMER_CHAN ; Added 11Jul2022 11.9.4
            \nButtonStyle = #SCS_BUTTON_FADER_DIMMER_CHAN
            \nImageNo = hSlThumbFaderChan
        EndSelect
        \nImageWidth = ImageWidth(\nImageNo)
        \nImageHeight = ImageHeight(\nImageNo)
        \nImageCentreOffset = \nImageHeight >> 1
        Select \nSliderType
          Case #SCS_ST_VFADER_DMX_MASTER, #SCS_ST_VFADER_DIMMER_CHAN
            \m_Max = 100
            \bFader = #True
            \sldNumDiv = 10 ; Number of division segments
          Default
            \m_Max = #SCS_MAXVOLUME_SLD
            \btnColor1 = #SCS_Level_Color
            \btnColor2 = #SCS_Level_Color
            \bFader = #True
            \bLevelSlider = #True
        EndSelect
        
      Case #SCS_ST_HSCROLLBAR
        \nButtonStyle = #SCS_BUTTON_SCROLLBAR_THUMB
        \btnColor1 = #SCS_ScrollThumb_Color1
        \btnColor2 = #SCS_ScrollThumb_Color2
        
      Case #SCS_ST_REMDEV_FADER_LEVEL
        \m_Max = #SCS_MAXVOLUME_SLD
        \btnColor1 = #SCS_Level_Color
        \btnColor2 = #SCS_Level_Color
        \bLevelSlider = #True
        nFaderInfoIndex = 1

      Case #SCS_ST_FREQ, #SCS_ST_TEMPO, #SCS_ST_PITCH
        \btnColor1 = #SCS_Light_Blue
        \btnColor2 = #SCS_White
        
    EndSelect
    
    CompilerIf #c_cuepanel_multi_dev_select
      Select \nSliderType
        Case #SCS_ST_HLEVELRUN
          If grLicInfo\bDevLinkAvailable
            If nCuePanelNo >= 0 And nDevNo >= 0 And nDevNo <= #SCS_MAX_AUDIO_DEV_PER_DISP_PANEL
              nAudPtr = gaDispPanel(nCuePanelNo)\nDPAudPtr
              If nAudPtr >= 0
                If aAud(nAudPtr)\bAudTypeF And aAud(nAudPtr)\bDeviceSelected[nDevNo]
                  \btnColor1 = #Cyan
                EndIf
              EndIf
            EndIf
          EndIf
      EndSelect
    CompilerEndIf
    
    If \nSliderType <> #SCS_ST_REMDEV_FADER_LEVEL
      SLD_calcUnitWidth(nSldPtr)
      If \bLevelSlider
        nAMarks = ((gaFaderInfo(nFaderInfoIndex)\fFdrDBHeadroom - gaFaderInfo(nFaderInfoIndex)\fFdrSecADBBase) / gaFaderInfo(nFaderInfoIndex)\fFdrSecADBInterval) + 1
        nAMarks = nAMarks + (2 * (gaFaderInfo(nFaderInfoIndex)\fFdrSecADBInterval - 1)) ; 1dB sub-marks in the cells above and below 0dB
        nAMarks = nAMarks + ((gaFaderInfo(nFaderInfoIndex)\fFdrDBHeadroom - gaFaderInfo(nFaderInfoIndex)\fFdrSecADBBase - 10) / gaFaderInfo(nFaderInfoIndex)\fFdrSecADBInterval) ; sub-marks outside the above range
        nBMarks = (gaFaderInfo(nFaderInfoIndex)\fFdrSecADBBase - gaFaderInfo(nFaderInfoIndex)\fFdrSecBDBBase) / gaFaderInfo(nFaderInfoIndex)\fFdrSecBDBInterval
        nBMarks = nBMarks + nBMarks ; plus sub-marks
        nCMarks = Round((gaFaderInfo(nFaderInfoIndex)\fFdrSecBDBBase - gaFaderInfo(nFaderInfoIndex)\fFdrSecCDBBase) / gaFaderInfo(nFaderInfoIndex)\fFdrSecCDBInterval, #PB_Round_Up)
        nDMarks = 1
        \sldNumDiv = (nAMarks + nBMarks + nCMarks + nDMarks)
      EndIf
    EndIf
    
  EndWith

EndProcedure

Procedure SLD_New(sName.s, pParentGadget, pParentGadgetItem, pOffsetX, pOffsetY, pWidth, pHeight, pSliderType, pMin=0, pMax=100, nValue=0, pBaseValue=#SCS_SLD_NO_BASE, pEnabled=#True, pUseMainScaling=#False, pUseCuePanelScaling=#False, pText1.s="", pText2.s="", pAudioGraph=#False, pCuePanelNo=-1, pDevNo=-1)
  PROCNAME(#PB_Compiler_Procedure + "(" + sName + ")")
  ; For slider types (pSliderType) see 'slider constants' #SCS_ST_... in Constants.pbi, eg #SCS_ST_PROGRESS, #SCS_ST_HLEVEL, #SCS_ST_PAN, etc.
  Protected nSldPtr
  
  gnSldCurrID + 1
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, "gnSldCurrID=" + gnSldCurrID + ", pParentGadget=" + getGadgetName(pParentGadget) + ", pOffsetX=" + pOffsetX + ", pOffsetY=" + pOffsetY + ", pWidth=" + pWidth + ", pHeight=" + pHeight +
                        ", pMax=" + pMax + ", nValue=" + nValue + ", pBaseValue=" + pBaseValue + ", pAudioGraph=" + strB(pAudioGraph) + ", pCuePanelNo=" + pCuePanelNo + ", pDevNo=" + pDevNo)
  CompilerEndIf
  nSldPtr = gnSldCurrID
  If nSldPtr > ArraySize(gaSlider())
    ReDim gaSlider.tySlider(nSldPtr + 50)
  EndIf
  
  With gaSlider(nSldPtr)
    \bInUse = #True
    \sName = sName
    \nAudioGraphImageNo = 0
    \nAudioGraphImageNoPlay = 0
    \bAudioGraphImageReady = #False
    ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bAudioGraphImageReady=" + strB(\bAudioGraphImageReady))
  EndWith
  
  SLD_initFaderConstants()
  
  With gaSlider(nSldPtr)
    
    \bUseMainScaling = pUseMainScaling
    \bUseCuePanelScaling = pUseCuePanelScaling
    If grOperModeOptions(gnOperMode)\bShowAudioGraph
      \bAudioGraph = pAudioGraph
    Else
      \bAudioGraph = #False
    EndIf
    \nCuePanelNo = pCuePanelNo
    \nDevNo = pDevNo
    
    ; default values
    \m_BackColor = #SCS_SLD_BACKCOLOR
    \m_GtrAreaBackColor = -1
    \m_BVLevel = 0.0
    \m_BaseBVLevel = #SCS_SLD_NO_BASE
    \m_TrimFactor = 1
    \m_KeyFactorS = pMax - pMin
    \m_KeyFactorL = 100.0
    \m_PageLength = -1  ; for scrollbars, page length must be set separately
    \m_AudPtr = -1
    
    ; other values
    \nSliderType = pSliderType
    \m_Min = pMin
    \m_Max = pMax ; will be overridden for level and pan
    \m_Value = nValue
    \m_BaseValue = pBaseValue
    \m_Enabled = pEnabled
    
    \btnBaseColor = #SCS_White
    \bLevelSlider = #False
    \bFader = #False
    \sLeftText = pText1
    \sRightText = pText2
    \sTopText = pText1
    \sBottomText = pText2
    \nTickColor = #SCS_Yellow
    
    \nCanvasX = pOffsetX
    \nCanvasY = pOffsetY
    \nCanvasWidth = pWidth
    \nCanvasHeight = pHeight
    \nCanvasHalfHeight = \nCanvasHeight >> 1
    \nCanvasHalfWidth = \nCanvasWidth >> 1
    
    SLD_fcSliderType(nSldPtr)
    
    SLD_createSliderGadgets(nSldPtr, pParentGadget, pParentGadgetItem)
    SLD_setText(nSldPtr)
    
    If \bFader
      SLD_setFaderVariables(nSldPtr)
    EndIf
    
    \nMaxArrayIndex = -1
    \nMaxSldCustom = -1
    ; \fSldMinDBLevel = grLevels\nMinDBLevel
    ; \fSldMaxDBLevel = grLevels\nMaxDBLevel
    
    \bInitialized = #True
    
    ; debugMsg(sProcName, "calling SLD_setButtonPos")
    SLD_setButtonPos(nSldPtr)
    
  EndWith
  
  gnMaxSld = nSldPtr
  
  gnNextX = pOffsetX + pWidth
  
  ProcedureReturn nSldPtr

EndProcedure

Procedure SLD_Release(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  With gaSlider(nSldPtr)
    If \bInUse
      ; free gadgets
      \cvsSlider = condFreeGadget(\cvsSlider)
      \bInUse = #False
    EndIf
  EndWith
EndProcedure

Procedure SLD_Event(nSldPtr, nWindowEvent, nEventWindowNo, nEventGadgetNo, nEventType, bMustBeEnabled)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  
  ; debugMsg(sProcName,"nWindowEvent=" + nWindowEvent + ", nEventWindowNo=" + nEventWindowNo + ", nEventGadgetNo=G" + nEventGadgetNo + ", nEventType=" + decodeEventType(nEventGadgetNo))
  
  With gaSlider(nSldPtr)
    If (\m_Enabled) Or (bMustBeEnabled = #False)
      \nEventWindowNo = nEventWindowNo
      Select nEventType
          
          ; Case #PB_EventType_RightButtonDown
          ; Debug sProcName + " #PB_EventType_RightButtonDown"
          
        Case #PB_EventType_LeftButtonDown
          ; debugMsg(sProcName, "#PB_EventType_LeftButtonDown")
          nRaiseEvent = SLD_cvsSlider_MouseDown(nSldPtr, 1, 0, CanvasMX(\cvsSlider), CanvasMY(\cvsSlider))
          
        Case #PB_EventType_LeftButtonUp
          ; debugMsg(sProcName, "#PB_EventType_LeftButtonUp")
          nRaiseEvent = SLD_cvsSlider_MouseUp(nSldPtr, 1, 0, CanvasMX(\cvsSlider), CanvasMY(\cvsSlider))
          
        Case #PB_EventType_MouseMove
          ; debugMsg(sProcName, "#PB_EventType_MouseMove")
          If GetActiveGadget() = \cvsSlider
            nRaiseEvent = SLD_cvsSlider_MouseMove(nSldPtr, 1, 0, CanvasMX(\cvsSlider), CanvasMY(\cvsSlider))
            ; debugMsg0(sProcName, "SLD_cvsSlider_MouseMove() returned nRaiseEvent=" + nRaiseEvent)
          EndIf
          
        Case #PB_EventType_MouseWheel
          If GetActiveGadget() = \cvsSlider
            nRaiseEvent = SLD_cvsSlider_MouseWheel(nSldPtr)
          EndIf
          
        Case #PB_EventType_MouseEnter
          Select \sName
            Case "QF_Progress", "QA_FileProg", "QP_FileProg"
              ; see also WQx_Form_Load() procedures where the tooltip is initially built using #SCS_SLD_TTA_BUILD
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, buildSkipBackForwardTooltip())
          EndSelect
          
        Case #PB_EventType_MouseLeave
          SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_HIDE)
          
        Case #PB_EventType_Focus
          ; debugMsg(sProcName, "#PB_EventType_Focus")
          SLD_gotFocus(nSldPtr)
          nRaiseEvent = #SCS_SLD_EVENT_GOT_FOCUS
          
        Case #PB_EventType_LostFocus
          ; debugMsg(sProcName, "#PB_EventType_LostFocus")
          SLD_LostFocus(nSldPtr)
          nRaiseEvent = #SCS_SLD_EVENT_LOST_FOCUS
          
        Case #PB_EventType_KeyDown
          ; debugMsg(sProcName, "#PB_EventType_KeyDown")
          nRaiseEvent = SLD_cvsSlider_KeyDown(nSldPtr, CanvasKey(\cvsSlider))
          ; debugMsg(sProcName, "nRaiseEvent=" + SLD_decodeEvent(nRaiseEvent))
          
        Case #PB_EventType_KeyUp
          ; debugMsg(sProcName, "#PB_EventType_KeyUp")
          
      EndSelect
    EndIf
  EndWith
  
  ProcedureReturn nRaiseEvent

EndProcedure

Procedure SLD_getMin(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_Min
EndProcedure

Procedure SLD_setMin(nSldPtr, nMin)
  With gaSlider(nSldPtr)
    If nMin <> \m_Min 
      \m_Min = nMin
      \m_KeyFactorS = \m_Max - \m_Min
      SLD_calcUnitWidth(nSldPtr)
      If (\m_Max >= \m_Min) And (\m_Value >= \m_Min) And (\m_Value <= \m_Max) 
        SLD_setButtonPos(nSldPtr)
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure SLD_getMax(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_Max
EndProcedure

Procedure SLD_setMax(nSldPtr, nMax)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected bPrevContinuous
  
  ; debugMsg0(sProcName, "nMax=" + nMax)
  With gaSlider(nSldPtr)
    If nMax <> \m_Max 
      \m_Max = nMax
      bPrevContinuous = \bContinuous
      If nMax >= #SCS_CONTINUOUS_END_AT
        \bContinuous = #True
      Else
        \bContinuous = #False
      EndIf
      SLD_calcUnitWidth(nSldPtr)
      If \m_Value > \m_Max 
        ; if current value > max then bring it back to max
        \m_Value = \m_Max
      EndIf
      \m_KeyFactorS = \m_Max - \m_Min
      If \bContinuous <> bPrevContinuous
        SLD_drawSlider(nSldPtr)
      EndIf
      If (\m_Max >= \m_Min) And (\m_Value >= \m_Min) And (\m_Value <= \m_Max)
        SLD_setText(nSldPtr)
        SLD_setButtonPos(nSldPtr) ; do this last as it redraws the slider
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure SLD_getRemDevMsgType(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\nRemDevMsgType 
EndProcedure

Procedure SLD_setRemDevMsgType(nSldPtr, nRemDevMsgType)
  gaSlider(nSldPtr)\nRemDevMsgType = nRemDevMsgType
EndProcedure

Procedure SLD_getLineCount(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_LineCount
EndProcedure

Procedure SLD_setLineCount(nSldPtr, nLineCount)
  With gaSlider(nSldPtr)
    If nLineCount <> \m_LineCount 
      \m_LineCount = nLineCount
      SLD_setButtonPos(nSldPtr)
    EndIf
  EndWith
EndProcedure

Procedure SLD_getLinePos(nSldPtr, nLinePosIndex)
  ProcedureReturn gaSlider(nSldPtr)\m_LinePos(nLinePosIndex)
EndProcedure

Procedure SLD_setLinePos(nSldPtr, nLinePosIndex, nLinePos, nLineType)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; NB ONLY USED FOR LOOP START AND END LINES
  ; NOW ALSO USED FOR CUE MARKERS
  With gaSlider(nSldPtr)
    If nLinePosIndex > ArraySize(\m_LinePos())
      ReDim \m_LinePos(nLinePosIndex + 10)
      ReDim \m_LineType(nLinePosIndex + 10)
    EndIf
    \m_LinePos(nLinePosIndex) = nLinePos
    \m_LineType(nLinePosIndex) = nLineType
    ; debugMsg(sProcName, "\m_LinePos(" + nLinePosIndex + ")=" + \m_LinePos(nLinePosIndex) + ", \m_LineType(" + nLinePosIndex + ")=" + \m_LineType(nLinePosIndex))
  EndWith
EndProcedure

Procedure SLD_getTrimFactor(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_TrimFactor
EndProcedure

Procedure SLD_getBaseTrimFactor(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_BaseTrimFactor
EndProcedure

Procedure.f SLD_getXFactor(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_XFactor
EndProcedure

Procedure SLD_setXFactor(nSldPtr, fXFactor.f)
  gaSlider(nSldPtr)\m_XFactor = fXFactor
EndProcedure

Procedure.f SLD_getYFactor(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_YFactor
EndProcedure

Procedure SLD_setYFactor(nSldPtr, fYFactor.f)
  gaSlider(nSldPtr)\m_YFactor = fYFactor
EndProcedure

Procedure.f SLD_getKeyFactorS(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_KeyFactorS
EndProcedure

Procedure SLD_setKeyFactorS(nSldPtr, fKeyFactorS.f)
  gaSlider(nSldPtr)\m_KeyFactorS = fKeyFactorS
EndProcedure

Procedure.f SLD_getKeyFactorL(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_KeyFactorL
EndProcedure

Procedure SLD_setKeyFactorL(nSldPtr, fKeyFactorL.f)
  gaSlider(nSldPtr)\m_KeyFactorL = fKeyFactorL
EndProcedure

Procedure SLD_getPageLength(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_PageLength
EndProcedure

Procedure SLD_setPageLength(nSldPtr, nPageLength)
  gaSlider(nSldPtr)\m_PageLength = nPageLength
  SLD_calcUnitWidth(nSldPtr)
EndProcedure

Procedure SLD_getAudPtr(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_AudPtr
EndProcedure

Procedure SLD_setAudPtr(nSldPtr, nAudPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure,nSldPtr))
  gaSlider(nSldPtr)\m_AudPtr = nAudPtr
  ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\m_AudPtr=" + getAudLabel(gaSlider(nSldPtr)\m_AudPtr))
  gaSlider(nSldPtr)\nLoadFileRequestCount = 0
EndProcedure

Procedure SLD_cvsSlider_KeyDown(nSldPtr, pCanvasKey)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  Protected nInterval, nValue
  Protected nCanvasKey, bShiftDown
  Protected nDirection
  Protected fCurrDBLevel.f, fDBIncrement.f, fNewDBLevel.f, fNewLevel.f
  Protected nShortcutFunction
  
  nCanvasKey = pCanvasKey
  bShiftDown = ShiftKeyDown()
  
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "\bLevelSlider=" + strB(\bLevelSlider) + ", \m_BVLevel=" + formatLevel(\m_BVLevel))
    If (nCanvasKey = #PB_Shortcut_Left) And (\bHorizontal)
      nDirection = -1
    ElseIf (nCanvasKey = #PB_Shortcut_Right) And (\bHorizontal)
      nDirection = 1
    ElseIf (nCanvasKey = #PB_Shortcut_Up) And (\bHorizontal = #False)
      nDirection = -1 ; changed 28Mar2020 11.8.2.3ah (was +1)
    ElseIf (nCanvasKey = #PB_Shortcut_Down) And (\bHorizontal = #False)
      nDirection = 1 ; changed 28Mar2020 11.8.2.3ah (was -1)
    EndIf
    ; Debug sProcName + ": \bLevelSlider=" + strB(\bLevelSlider) + ", \m_BVLevel=" + formatLevel(\m_BVLevel) + ", nCanvasKey=" + nCanvasKey + ", nDirection=" + nDirection
    If nDirection <> 0
      If \bLevelSlider
        fCurrDBLevel = convertBVLevelToDBLevel(\m_BVLevel)
        fDBIncrement = ValF(grProd\sDBLevelChangeIncrement)
        fNewDBLevel = fCurrDBLevel + (fDBIncrement * nDirection)
        fNewLevel = convertDBLevelToBVLevel(fNewDBLevel)
        If fNewLevel <= grLevels\fMinBVLevel
          fNewLevel = grLevels\fMinBVLevel
        ElseIf fNewLevel > grLevels\fMaxBVLevel
          fNewLevel = grLevels\fMaxBVLevel
        EndIf
        If fNewLevel <> \m_BVLevel
          \m_BVLevel = fNewLevel
          ; debugMsg0(sProcName, "\m_BVLevel=" + traceLevel(\m_BVLevel))
          \m_Value = SLD_BVLevelToSliderValue(fNewLevel, \m_TrimFactor)
          SLD_setText(nSldPtr)
          SLD_setButtonPos(nSldPtr)
          nRaiseEvent = #SCS_SLD_EVENT_SCROLL
        EndIf
        
      ElseIf \nSliderType = #SCS_ST_PROGRESS
        If bShiftDown
          nInterval = 500 * nDirection
        Else
          nInterval = 3000 * nDirection
        EndIf
        nValue = \m_Value + nInterval
        If nValue < \m_Min 
          nValue = \m_Min
        ElseIf nValue > \m_Max 
          nValue = \m_Max
        EndIf
        ; debugMsg(sProcName, "nInterval=" + nInterval + ", \m_Min=" + \m_Min + ", \m_Max=" + \m_Max + ", \m_Value=" + \m_Value + ", nValue=" + nValue)
        If nValue <> \m_Value 
          \m_Value = nValue
          SLD_setText(nSldPtr)
          SLD_setButtonPos(nSldPtr)
          Select \nSliderToolTipType
            Case #SCS_SLD_TTT_GENERAL
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
            Case #SCS_SLD_TTT_SIZE
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
          EndSelect
          nRaiseEvent = #SCS_SLD_EVENT_SCROLL
        EndIf
        
      Else
        If bShiftDown
          nInterval = ((\m_Max - \m_Min) / \m_KeyFactorS) * nDirection
          ; debugMsg(sProcName, "nInterval=" + nInterval + ", \m_Max=" + \m_Max + ", \m_Min=" + \m_Min + ", \m_KeyFactorS=" + StrF(\m_KeyFactorS,2))
        Else
          nInterval = ((\m_Max - \m_Min) / \m_KeyFactorL) * nDirection
          ; debugMsg(sProcName, "nInterval=" + nInterval + ", \m_Max=" + \m_Max + ", \m_Min=" + \m_Min + ", \m_KeyFactorL=" + StrF(\m_KeyFactorL,2))
        EndIf
        If nInterval = 0
          nInterval = 1
        EndIf
        ; debugMsg(sProcName, "nInterval=" + nInterval + ", \m_Max=" + \m_Max + ", \m_Min=" + \m_Min)
        nValue = \m_Value + nInterval
        If nValue < \m_Min 
          nValue = \m_Min
        ElseIf nValue > \m_Max 
          nValue = \m_Max
        EndIf
        If nValue <> \m_Value 
          \m_Value = nValue
          SLD_setText(nSldPtr)
          SLD_setButtonPos(nSldPtr)
          Select \nSliderToolTipType
            Case #SCS_SLD_TTT_GENERAL
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
            Case #SCS_SLD_TTT_SIZE
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
          EndSelect
          nRaiseEvent = #SCS_SLD_EVENT_SCROLL
        EndIf
      EndIf
    Else
      If GetActiveWindow() = #WMN
        nShortcutFunction = getMainShortcutFunctionForPBShortcut(nCanvasKey)
        ; Debug sProcName + ": nShortcutFunction=" + nShortcutFunction
        If nShortcutFunction >= 0
          ; Debug sProcName + ": calling WMN_processShortcut(" + nShortcutFunction + ")"
          WMN_processShortcut(nShortcutFunction)
        EndIf
      EndIf
    EndIf
  EndWith
  ; debugMsg(sProcName, #SCS_END + ", returning " + nRaiseEvent)
  ProcedureReturn nRaiseEvent
EndProcedure

Procedure SLD_cvsSlider_ProcessControlKeyIfReqd(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected bControlKeyProcessed
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "\nControlKeyAction=" + \nControlKeyAction)
    Select \nControlKeyAction
      Case #SCS_SLD_CCK_BASE
        ; debugMsg(sProcName, "#SCS_SLD_CCK_BASE")
        If (GetAsyncKeyState_(#VK_LCONTROL) & (1 << 15)) Or (GetAsyncKeyState_(#VK_RCONTROL) & (1 << 15))
          If (\bHorizontal) And (\nBasePointerX1 >= 0)
            \m_Value = \m_BaseValue
            \m_BVLevel = \m_BaseBVLevel
            bControlKeyProcessed = #True
          ElseIf (\bHorizontal = #False) And (\nBasePointerY1 >= 0)
            \m_Value = \m_BaseValue
            \m_BVLevel = \m_BaseBVLevel
            bControlKeyProcessed = #True
          EndIf
        EndIf
        
      Case #SCS_SLD_CCK_ZERO
        ; debugMsg(sProcName, "#SCS_SLD_CCK_ZERO")
        If (GetAsyncKeyState_(#VK_LCONTROL) & (1 << 15)) Or (GetAsyncKeyState_(#VK_RCONTROL) & (1 << 15))
          \m_Value = 0
          \m_BVLevel = 0
          bControlKeyProcessed = #True
        EndIf
        
      Case #SCS_SLD_CCK_0DB
        ; debugMsg(sProcName, "#SCS_SLD_CCK_0DB")
        If (GetAsyncKeyState_(#VK_LCONTROL) & (1 << 15)) Or (GetAsyncKeyState_(#VK_RCONTROL) & (1 << 15))
          \m_BVLevel = grLevels\fZeroBVLevel
          \m_Value = SLD_BVLevelToSliderValue(\m_BVLevel, \m_TrimFactor)
          bControlKeyProcessed = #True
        EndIf
        
    EndSelect
  EndWith
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bControlKeyProcessed))
  ProcedureReturn bControlKeyProcessed
EndProcedure

Procedure SLD_cvsSlider_MouseDown(nSldPtr, Button, Shift, X, Y)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  Protected nAdjX, nAdjY
  Protected bAdjustSlider
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "X=" + X + ", \nPointerMinX=" + \nPointerMinX + ", \nPointerMaxX=" + \nPointerMaxX)
    If \m_Enabled
      If Button = 1
        If \bHorizontal ; horizontal
          ; debugMsg(sProcName, "X=" + X + ", \nPointerMinX=" + \nPointerMinX + ", \nPointerMaxX=" + \nPointerMaxX)
          If (X < \nPointerMinX) Or (X > \nPointerMaxX)
            ; ignore if outside range of gutter
            ProcedureReturn
          EndIf
          \bMouseDown = #True
          ; change button position if mouse is clicked in a valid area
          SLD_clickSlider(nSldPtr, X, Y)
          nAdjX = X - \nCurrPointerClickOffset
          \nPrevMouseX = nAdjX
          If SLD_cvsSlider_ProcessControlKeyIfReqd(nSldPtr) = #False
            If (\bBasePointerSelected) And (\nBasePointerX1 >= 0)
              ; user clicked on the white (base) marker so snap to that position
              \m_Value = \m_BaseValue
              \m_BVLevel = \m_BaseBVLevel
              debugMsg(sProcName, ">>>> white marker")
            Else
              SLD_adjustButton(nSldPtr, nAdjX, Y)
            EndIf
          EndIf
          
        Else  ; vertical
          ; debugMsg(sProcName, "Y=" + Y + ", \nPointerMinY=" + \nPointerMinY + ", \nPointerMaxY=" + \nPointerMaxY)
          If (Y < \nPointerMinY) Or (Y > \nPointerMaxY)
            ; ignore if outside range of gutter
            ProcedureReturn
          EndIf
          \bMouseDown = #True
          ; change button position if mouse is clicked in a valid area
          SLD_clickSlider(nSldPtr, X, Y)
          nAdjY = Y - \nCurrPointerClickOffset
          \nPrevMouseY = nAdjY
          If SLD_cvsSlider_ProcessControlKeyIfReqd(nSldPtr) = #False
            If (\bBasePointerSelected) And (\nBasePointerY1 >= 0)
              ; user clicked on the white (base) marker so snap to that position
              \m_Value = \m_BaseValue
              \m_BVLevel = \m_BaseBVLevel
            Else
              SLD_adjustButton(nSldPtr, X, nAdjY)
            EndIf
          EndIf
          
        EndIf
        
        Select \nSliderToolTipType
          Case #SCS_SLD_TTT_GENERAL
            SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
          Case #SCS_SLD_TTT_SIZE
            SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
        EndSelect
        bAdjustSlider = SLD_checkForAdjustingSlider(nSldPtr)
        If bAdjustSlider
          SLD_setText(nSldPtr)
          ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
          SLD_drawButton(nSldPtr)
        EndIf
        nRaiseEvent = #SCS_SLD_EVENT_MOUSE_DOWN
      EndIf
    EndIf
  EndWith
  ProcedureReturn nRaiseEvent
EndProcedure

Procedure SLD_cvsSlider_MouseMove(nSldPtr, Button, Shift, X, Y)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  Protected nAdjX, nAdjY
  Protected bAdjustSlider
  
  ; debugMsg(sProcName,"X=" + X + ", Y=" + Y)
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "gaSlider(nSldPtr)\bMouseDown=" + strB(\bMouseDown))
    ; debugMsg(sProcName,"\m_Enabled="+strB(\m_Enabled) +", Button="+Str(Button) + ", \nPrevMouseX="+Str(\nPrevMouseX) + ", \bCurrMove="+strB(\bCurrMove))
    If \m_Enabled
      If (Button = 1) And (\bMouseDown)
        If \bHorizontal ; horizontal
          nAdjX = X - \nCurrPointerClickOffset
          If nAdjX <> \nPrevMouseX 
            \nPrevMouseX = nAdjX
            ; Reset the button based on mouse position
            If \bCurrMove   ; MouseDown over button will make this #True
              \bBasePointerSelected = #False  ; ignore clicking on white (base) pointer if the user then drags the mouse
              bAdjustSlider = SLD_checkForAdjustingSlider(nSldPtr)
              If bAdjustSlider
                SLD_adjustButton(nSldPtr, nAdjX, Y)
                SLD_setText(nSldPtr)
                ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
                SLD_drawButton(nSldPtr)
                Select \nSliderToolTipType
                  Case #SCS_SLD_TTT_GENERAL
                    SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
                  Case #SCS_SLD_TTT_SIZE
                    SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
                EndSelect
              EndIf
              nRaiseEvent = #SCS_SLD_EVENT_SCROLL
            EndIf
          EndIf
          
        Else  ; vertical
          nAdjY = Y - \nCurrPointerClickOffset
          If nAdjY <> \nPrevMouseY
            \nPrevMouseY = nAdjY
            ; Reset the button based on mouse position
            If \bCurrMove   ; MouseDown over button will make this #True
              \bBasePointerSelected = #False  ; ignore clicking on white (base) pointer if the user then drags the mouse
              SLD_adjustButton(nSldPtr, X, nAdjY)
              SLD_setText(nSldPtr)
              ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
              SLD_drawButton(nSldPtr)
              Select \nSliderToolTipType
                Case #SCS_SLD_TTT_GENERAL
                  SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
                Case #SCS_SLD_TTT_SIZE
                  SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
              EndSelect
              nRaiseEvent = #SCS_SLD_EVENT_SCROLL
            EndIf
          EndIf
          
        EndIf
      EndIf ; EndIf (Button = 1) And (\bMouseDown)
    EndIf ; EndIf \m_Enabled
  EndWith
  ProcedureReturn nRaiseEvent
EndProcedure

Procedure SLD_cvsSlider_MouseWheel(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  Protected nWheelDelta
  Protected X, Y
  
  With gaSlider(nSldPtr)
    If \m_Enabled
      nWheelDelta = GetGadgetAttribute(\cvsSlider, #PB_Canvas_WheelDelta)
      ; debugMsg(sProcName, "nWheelDelta=" + nWheelDelta)
      If \bHorizontal ; horizontal
        X = \nPrevMouseX + nWheelDelta
        ; debugMsg(sProcName, "X=" + X + ", \nPrevMouseX=" + \nPrevMouseX)
        If X <> \nPrevMouseX 
          \nPrevMouseX = X
          ; Reset the button based on mouse position
          \bBasePointerSelected = #False  ; ignore clicking on white (base) pointer if the user then drags the mouse
            SLD_adjustButton(nSldPtr, X, Y)
            SLD_setText(nSldPtr)
            ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
            SLD_drawButton(nSldPtr)
            Select \nSliderToolTipType
            Case #SCS_SLD_TTT_GENERAL
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
            Case #SCS_SLD_TTT_SIZE
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
          EndSelect
          nRaiseEvent = #SCS_SLD_EVENT_SCROLL
        EndIf
        
      Else  ; vertical
        ; Y = \nPrevMouseY + nWheelDelta
        Y = \nPrevMouseY - nWheelDelta
        If Y <> \nPrevMouseY
          \nPrevMouseY = Y
          ; Reset the button based on mouse position
          \bBasePointerSelected = #False  ; ignore clicking on white (base) pointer if the user then drags the mouse
          SLD_adjustButton(nSldPtr, X, Y)
          SLD_setText(nSldPtr)
          ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
          SLD_drawButton(nSldPtr)
          Select \nSliderToolTipType
            Case #SCS_SLD_TTT_GENERAL
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
            Case #SCS_SLD_TTT_SIZE
              SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
          EndSelect
          nRaiseEvent = #SCS_SLD_EVENT_SCROLL
        EndIf
        
      EndIf
    EndIf
  EndWith
  ProcedureReturn nRaiseEvent
EndProcedure

Procedure SLD_cvsSlider_MouseUp(nSldPtr, Button, Shift, X, Y)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRaiseEvent = #SCS_SLD_EVENT_NONE
  Protected sToolTip.s
  Protected nAdjX, nAdjY
  Protected bAdjustSlider
  
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "gaSlider(nSldPtr)\bMouseDown=" + strB(\bMouseDown))
    If \m_Enabled
      If (Button = 1) And (\bMouseDown)
        If \bCurrMove
          If SLD_cvsSlider_ProcessControlKeyIfReqd(nSldPtr) = #False
            If \bHorizontal ; horizontal
              If (\bBasePointerSelected) And (\nBasePointerX1 >= 0)
                ; user clicked on the white (base) marker so snap to that position
                \m_Value = \m_BaseValue
                \m_BVLevel = \m_BaseBVLevel
              Else
                nAdjX = X - \nCurrPointerClickOffset
                SLD_adjustButton(nSldPtr, nAdjX, Y)
              EndIf
              
            Else  ; vertical
              If (\bBasePointerSelected) And (\nBasePointerY1 >= 0)
                ; user clicked on the white (base) marker so snap to that position
                \m_Value = \m_BaseValue
                \m_BVLevel = \m_BaseBVLevel
              Else
                nAdjY = Y - \nCurrPointerClickOffset
                SLD_adjustButton(nSldPtr, X, nAdjY)
              EndIf
              
            EndIf
          EndIf
          bAdjustSlider = SLD_checkForAdjustingSlider(nSldPtr)
          If bAdjustSlider
            SLD_setText(nSldPtr)
            ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
            SLD_drawButton(nSldPtr)
            Select \nSliderToolTipType
              Case #SCS_SLD_TTT_GENERAL
                SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(\m_Value))
              Case #SCS_SLD_TTT_SIZE
                SLD_ToolTip(nSldPtr, #SCS_SLD_TTA_SHOW, Str(0 - \m_Value))
            EndSelect
          EndIf ; EndIf bAdjustSlider
        EndIf ; EndIf \bCurrMove
        ; Turn off mouse tracking
        \bCurrMove = #False
        \bMouseDown = #False
        ; debugMsg(sProcName,"\bCurrMove=" + strB(\bCurrMove))
        nRaiseEvent = #SCS_SLD_EVENT_MOUSE_UP
      EndIf
    EndIf
  EndWith
  ProcedureReturn nRaiseEvent
EndProcedure

Procedure SLD_setDBLabel(nSldPtr, sDBLevel.s)
  ; Only called from within SliderControl.pbi
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; debugMsg(sProcName, "sDBLevel=" + sDBLevel)
  With gaSlider(nSldPtr)
    \nLblFontId = FontID(\fontLabels)
    \bUseInfinityFont = #False
    Select \nSliderType
      Case #SCS_ST_HLEVELCHANGERUN, #SCS_ST_HLEVELCHANGERUNPL
        \sCaptionText = "Target = Current " + sDBLevel + "dB"   ; eg "Target = Current -45.2dB"
        
      Default
        If sDBLevel = #SCS_INF_DBLEVEL
          \nLblFontId = FontID(\fontInfinity)
          \bUseInfinityFont = #True
          \sRightText = #SCS_Text_Minus_Infinity
        Else
          \sRightText = sDBLevel
        EndIf
        ; debugMsg(sProcName, "\sRightText=" + \sRightText)
    EndSelect
  EndWith
EndProcedure

Procedure SLD_setText(nSldPtr, nDispPanel=-1)
  ; PROCNAMEC()
  ; only called from within SliderControl.pbi
  Protected bRelativeLevel
  Protected sDBLevel.s
  
  With gaSlider(nSldPtr)
    If \bLevelSlider
      ; level slider
      If \bFader
        \sTopText = convertBVLevelToDBString(\m_BVLevel, #False, #True)
      Else
        If (\nSliderType = #SCS_ST_HLEVELCHANGERUN) Or (\nSliderType = #SCS_ST_HLEVELCHANGERUNPL)
          bRelativeLevel = #True
        EndIf
        sDBLevel = convertBVLevelToDBString(\m_BVLevel, bRelativeLevel, #True)
        SLD_setDBLabel(nSldPtr, sDBLevel)
      EndIf
    Else
      ; not a level slider
      Select \nSliderType
        Case #SCS_ST_PROGRESS
          \sLeftText = timeToString(\m_Value, \nLogicalRange)
          ; debugMsg0(sProcName, "gaSlider(" + nSldPtr + ")\m_Value=" + \m_Value + ", \sLeftText=" + \sLeftText + ", \m_Min=" + \m_Min + ", \m_Max=" + \m_Max)
          If \m_Max >= #SCS_CONTINUOUS_END_AT
            \sRightText = ""
          Else
            \sRightText = timeToString(\nLogicalRange - \m_Value, \nLogicalRange)
          EndIf
          If nDispPanel >= 0
            M2T_displayMoveToTimeValueIfActive(nDispPanel, \m_Value)
          EndIf
          
        Case #SCS_ST_POSITION
          \sRightText = timeToString(\nLogicalRange - \m_Value, \nLogicalRange)
          
        Case #SCS_ST_HPERCENT, #SCS_ST_HLIGHTING_PERCENT
          \sRightText = Str(\m_Value) + "%"
          
        Case #SCS_ST_HSCROLLBAR
          ; no action
          
        Case #SCS_ST_VFADER_DMX_MASTER, #SCS_ST_VFADER_DIMMER_CHAN ; Changed 11Jul2022 11.9.4
          \sTopText = Str(\m_Value) + "%"
          
      EndSelect
    EndIf
  EndWith
EndProcedure

Procedure SLD_getSliderType(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\nSliderType
EndProcedure

Procedure SLD_setSliderType(nSldPtr, nSliderType)
  gaSlider(nSldPtr)\nSliderType = nSliderType
  SLD_fcSliderType(nSldPtr)
EndProcedure

Procedure SLD_setAudioGraph(nSldPtr, bAudioGraph)
;   PROCNAME(buildSliderProcName(#PB_Compiler_Procedure,nSldPtr))
  If (bAudioGraph) And (grOperModeOptions(gnOperMode)\bShowAudioGraph = #False)
    gaSlider(nSldPtr)\bAudioGraph = #False
  Else
    gaSlider(nSldPtr)\bAudioGraph = bAudioGraph
  EndIf
;   debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bAudioGraph=" + strB(gaSlider(nSldPtr)\bAudioGraph) + ", \m_AudPtr=" + getAudLabel(gaSlider(nSldPtr)\m_AudPtr) +
;                       ", grOperModeOptions(" + decodeOperMode(gnOperMode) + ")\bShowAudioGraph=" + strB(grOperModeOptions(gnOperMode)\bShowAudioGraph))
  SLD_setButtonWidthEtc(nSldPtr)
EndProcedure

Procedure SLD_getValue(nSldPtr, bOKForLevelSLider=#False)
  Protected sProcName.s
  Protected nValue, fValue.f
  Static bMessageDisplayed
  
  With gaSlider(nSldPtr)
    If (\bLevelSlider) And (bOKForLevelSLider = #False)
      If bMessageDisplayed = #False
        sProcName = buildSliderProcName(#PB_Compiler_Procedure, nSldPtr)
        debugMsg(sProcName, "called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        MessageRequester(sProcName, sProcName + " called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr) + ", nSldPtr=" + nSldPtr)
        bMessageDisplayed = #True
      EndIf
    EndIf
    nValue = \m_Value
  EndWith
  ; debugMsg0(sProcName, "gaSlider(" + nSldPtr + ")\m_Value=" + nValue)
  ProcedureReturn nValue
EndProcedure

Procedure SLD_setValue(nSldPtr, nValue, bForceRedraw=#False, nDispPanel=-1)
  Protected sProcName.s
  Static bMessageDisplayed
  
  With gaSlider(nSldPtr)
    sProcName = buildSliderProcName(#PB_Compiler_Procedure, nSldPtr)
    If \bLevelSlider
      If bMessageDisplayed = #False
        debugMsg(sProcName, "called for level slider " + \sName + ", \nSliderType=" + \nSliderType + ", nValue=" + nValue + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        MessageRequester(sProcName, sProcName + " called for level slider " + \sName + ", \nSliderType=" + \nSliderType + ", nValue=" + nValue + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        bMessageDisplayed = #True
      EndIf
    EndIf
    \m_Value = nValue
    If (\bCurrMove = #False) Or (bForceRedraw)
      ; only call the following if user is NOT currently moving the slider, or if bForceRedraw=#True (used in WQF_fcSldRelLevel())
      SLD_setText(nSldPtr, nDispPanel)
      SLD_setButtonPos(nSldPtr) ; do this last as it redraws the slider
    EndIf
  EndWith
EndProcedure

Procedure SLD_getBaseValue(nSldPtr)
  Protected sProcName.s
  Static bMessageDisplayed
  
  With gaSlider(nSldPtr)
    If \bLevelSlider
      If bMessageDisplayed = #False
        sProcName = buildSliderProcName(#PB_Compiler_Procedure, nSldPtr)
        debugMsg(sProcName, "called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        MessageRequester(sProcName, sProcName + " called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        bMessageDisplayed = #True
      EndIf
    EndIf
  EndWith
  ProcedureReturn gaSlider(nSldPtr)\m_BaseValue
EndProcedure

Procedure SLD_setBaseValue(nSldPtr, nBaseValue)
  Protected sProcName.s
  Static bMessageDisplayed
  
  With gaSlider(nSldPtr)
    If \bLevelSlider
      If bMessageDisplayed = #False
        sProcName = buildSliderProcName(#PB_Compiler_Procedure, nSldPtr)
        debugMsg(sProcName, "called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        MessageRequester(sProcName, sProcName + " called for level slider " + \sName + ", \m_AudPtr=" + getAudLabel(\m_AudPtr))
        bMessageDisplayed = #True
      EndIf
    EndIf
  EndWith
  With gaSlider(nSldPtr)
    If nBaseValue = #SCS_SLD_BASE_EQUALS_CURRENT
      \m_BaseValue = \m_Value
    Else
      \m_BaseValue = nBaseValue
    EndIf
    SLD_setButtonPos(nSldPtr)
    \nControlKeyAction = #SCS_SLD_CCK_BASE
  EndWith
EndProcedure

Procedure.f SLD_getLevel(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_BVLevel
EndProcedure

Procedure SLD_setLevel(nSldPtr, fBVLevel.f, fTrimFactor.f=1.0)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  With gaSlider(nSldPtr)
    If fBVLevel <= grLevels\fMinBVLevel ; Test added 13Sep2022 following email from Jan van Triest about -75.0dB instead of minus infinity appearing in level sliders
      \m_BVLevel = 0.0
    Else
      \m_BVLevel = fBVLevel
    EndIf
    ; debugMsg0(sProcName, "\m_BVLevel=" + traceLevel(\m_BVLevel) + ", grLevels\fMinBVLevel=" + grLevels\fMinBVLevel + " (" + traceLevel(grLevels\fMinBVLevel) + ")")
    \m_TrimFactor = fTrimFactor
    \m_Value = SLD_BVLevelToSliderValue(fBVLevel, fTrimFactor)
    SLD_setText(nSldPtr)
    If \bCurrMove = #False
      ; only redraw if user is NOT currently moving the slider
      SLD_setButtonPos(nSldPtr) ; do this last as it redraws the slider
    EndIf
  EndWith
EndProcedure

Procedure.f SLD_getBaseLevel(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\m_BaseBVLevel
EndProcedure

Procedure SLD_setBaseLevel(nSldPtr, fBaseLevel.f, fTrimFactor.f=1.0)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nAudPtr
  
; debugMsg(sProcName, #SCS_START + ", fBaseLevel=" + convertBVLevelToDBString(fBaseLevel) + ", gaSlider(" + nSldPtr+ ")\m_AudPtr=" + getAudLabel(gaSlider(nSldPtr)\m_AudPtr))
  
  With gaSlider(nSldPtr)
    ; Added 23Apr2024 11.10.2cc
    nAudPtr = \m_AudPtr
    If nAudPtr >= 0
      If aAud(nAudPtr)\bAudTypeF
; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bDeviceInitialTotalVolWorksSet=" + strB(aAud(nAudPtr)\bDeviceInitialTotalVolWorksSet))
        If aAud(nAudPtr)\bDeviceInitialTotalVolWorksSet
          ; do not set or display base levels if multi-device selection occuring and one or more devices are currently selected
          ProcedureReturn
        EndIf
      EndIf
    EndIf
    ; End added 23Apr2024 11.10.2cc
    
    If fBaseLevel = #SCS_SLD_BASE_EQUALS_CURRENT
      \m_BaseBVLevel = \m_BVLevel
      \m_BaseValue = \m_Value
    Else
      \m_BaseBVLevel = fBaseLevel
      \m_BaseTrimFactor = fTrimFactor
      If \m_BaseBVLevel = #SCS_SLD_NO_BASE
        \m_BaseValue = #SCS_SLD_NO_BASE
      Else
        \m_BaseValue = SLD_BVLevelToSliderValue(fBaseLevel, fTrimFactor)
      EndIf
    EndIf
; debugMsg(sProcName, "\m_BaseValue=" + \m_BaseValue)
    SLD_setButtonPos(nSldPtr)
    \nControlKeyAction = #SCS_SLD_CCK_BASE
  EndWith
EndProcedure

Procedure SLD_adjustButton(nSldPtr, inX, inY, bUseCurrentXY=#False)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected fTmpFloat.f
  Protected nMyInX, nMyInY

  ; called from the MouseMove and MouseUp events to redraw the button position
  
  ; debugMsg(sProcName, #SCS_START + ", inX=" + inX + ", inY=" + inY)
  
  With gaSlider(nSldPtr)
    
    If bUseCurrentXY = #False
      nMyInX = inX
      nMyInY = inY
    Else
      nMyInX = ((\nCurrPointerX2 - \nCurrPointerX1) / 2) + \nCurrPointerX1
      nMyInY = ((\nCurrPointerY2 - \nCurrPointerY1) / 2) + \nCurrPointerY1
    EndIf
    
    If \bHorizontal ; horizontal
      ; if x is left of gutter then place at min OR if x is to right then place at max
      If nMyInX < \nGtrX1
        nMyInX = \nGtrX1
      ElseIf nMyInX > \nGtrX2 
        nMyInX = \nGtrX2
      EndIf
      fTmpFloat = nMyInX - \nGtrX1
      fTmpFloat / \fUnitSize
      \m_Value = \m_Min + fTmpFloat
      ; debugMsg(sProcName, "\m_Value=" + \m_Value + ", inX=" + inX + ", nMyInX=" + nMyInX + ", \nGtrX1=" + \nGtrX1 + ", \nGtrX2=" + \nGtrX2 + ", \fUnitSize=" + StrF(\fUnitSize,4) + ", fTmpFloat=" + StrF(fTmpFloat))
      If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL
        \nSldCustomLinePos = nMyInX - \nPointerMinX + \nCurrPointerClickOffset - \btnHalfWdth - 1
        If \nMaxSldCustom >= 0
          If \nSldCustomLinePos < 0
            ; debugMsg0(sProcName, "\nSldCustomLinePos=" + \nSldCustomLinePos + ", setting to 0")
            \nSldCustomLinePos = 0
          ElseIf \nSldCustomLinePos > \aSldCustom(0)\nCustomLinePos
            ; debugMsg0(sProcName, "\nSldCustomLinePos=" + \nSldCustomLinePos + ", setting to " + \aSldCustom(0)\nCustomLinePos)
            \nSldCustomLinePos = \aSldCustom(0)\nCustomLinePos
          EndIf
        EndIf
      EndIf
      
    Else  ; vertical
      If \bFader
        ; 15Sep2017 11.7.0: added "- 1" in the following to fix a problem with vertical fader sliders not reaching max (eg stopping at -0.2dB instead of 0.0dB) - reported by Eric Snodgrass
        If nMyInY < (\nMaxPos - 1)
          nMyInY = \nMaxPos - 1
        ElseIf nMyInY > \nMinPos
          nMyInY = \nMinPos
        EndIf
        fTmpFloat = \nMinPos - nMyInY
        fTmpFloat / \fUnitSize
        \m_Value = \m_Min + fTmpFloat
        ; debugMsg(sProcName, "\m_Value=" + \m_Value + ", inY=" + inY + ", nMyInY=" + nMyInY + ", \nMinPos=" + \nMinPos + ", \nMaxPos=" + \nMaxPos + ", \fUnitSize=" + StrF(\fUnitSize,4) + ", fTmpFloat=" + StrF(fTmpFloat))
      Else
        If nMyInY < \nGtrY1
          nMyInY = \nGtrY1
        ElseIf nMyInY > \nGtrY2 
          nMyInY = \nGtrY2
        EndIf
        fTmpFloat = nMyInY - \nGtrY1
        fTmpFloat / \fUnitSize
        \m_Value = \m_Min + fTmpFloat
      EndIf
      
    EndIf
    
    ; debugMsg0(sProcName, "gaSlider(" + nSldPtr + ")\m_Value=" + \m_Value)
    If \m_Value < \m_Min
      \m_Value = \m_Min
    ElseIf \m_Value > \m_Max
      \m_Value = \m_Max
    EndIf
    If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL
      SLD_setBVLevelForSldCustomLinePos(nSldPtr)
    ElseIf \bLevelSlider
      \m_BVLevel = SLD_SliderValueToBVLevel(\m_Value, \m_TrimFactor)
      ; debugMsg0(sProcName, "\m_BVLevel=" + traceLevel(\m_BVLevel))
    EndIf
    
  EndWith
EndProcedure

Procedure SLD_clickSlider(nSldPtr, inX, inY)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))

  ; called from the mouse down to see if the mouse is pointing to the Slider area - if so then start tracking the mouse move
  
  With gaSlider(nSldPtr)
    ; X value can be to the edge of the slider area - easier to 'hit' the end on a move.
    ; debugMsg(sProcName, "inX=" + inX + ", inY=" + inY + ", \nCanvasHalfHeight=" + \nCanvasHalfHeight + ", \btnHalfHght=" + \btnHalfHght + ", \nCanvasWidth=" + \nCanvasWidth)
    ; If (inY > (\nCanvasHalfHeight) - (\btnHalfHght)) And (inY < (\nCanvasHalfHeight) + (\btnHalfHght)) And (inX >= \nPointerMinX) And (inX <= \nPointerMaxX) 
    ; debugMsg0(sProcName, "\bHorizontal=" + strB(\bHorizontal) + ", \nPointerMinX=" + \nPointerMinX + ", \nPointerMaxX=" + \nPointerMaxX)
    If \bHorizontal ; horizontal
      If (inX >= \nPointerMinX) And (inX <= \nPointerMaxX)
        \bCurrMove = #True
        \bBasePointerSelected = #False
        If (inX < \nCurrPointerX1) Or (inX > \nCurrPointerX2)
          ; not clicking on the yellow (or current) pointer
          \nCurrPointerClickOffset = 0
          If (inX >= \nBasePointerX1) And (inX <= \nBasePointerX2)
            ; clicked on the white (or base) marker
            \bBasePointerSelected = #True
          EndIf
        Else
          ; clicking on the yellow (or current) pointer
          \nCurrPointerClickOffset = inX - ((\nCurrPointerX2 + \nCurrPointerX1) >> 1) ; nb similar logic to that used in SLD_DrawPointer()
        EndIf
        If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL
          \nSldCustomLinePos = inX - \nPointerMinX + \nCurrPointerClickOffset - \btnHalfWdth - 1
          ; debugMsg0(sProcName, "\bCurrMove=" + strB(\bCurrMove) + ", inX=" + inX + ", \nCurrPointerX1=" + \nCurrPointerX1 + ", \nCurrPointerX2=" + \nCurrPointerX2 + ", \nCurrPointerClickOffset=" + \nCurrPointerClickOffset +
          ;                      ", \nSldCustomLinePos=" + \nSldCustomLinePos)
        EndIf
        ; debugMsg(sProcName, "\bCurrMove=" + strB(\bCurrMove) + ", inX=" + inX + ", \nCurrPointerX1=" + \nCurrPointerX1 + ", \nCurrPointerX2=" + \nCurrPointerX2 + ", \nCurrPointerClickOffset=" + \nCurrPointerClickOffset)
      EndIf
      
    Else  ; vertical
      If (inY >= \nPointerMinY) And (inY <= \nPointerMaxY) 
        \bCurrMove = #True
        \bBasePointerSelected = #False
        If (inY < \nCurrPointerY1) Or (inY > \nCurrPointerY2)
          ; not clicking on the yellow (or current) pointer
          \nCurrPointerClickOffset = 0
          If (inY >= \nBasePointerY1) And (inY <= \nBasePointerY2)
            ; clicked on the white (or base) marker
            \bBasePointerSelected = #True
          EndIf
        Else
          ; clicking on the yellow (or current) pointer
          \nCurrPointerClickOffset = inY - ((\nCurrPointerY2 + \nCurrPointerY1) >> 1) ; nb similar logic to that used in SLD_DrawPointer()
        EndIf
        ; debugMsg(sProcName, "\bCurrMove=" + strB(\bCurrMove) + ", inY=" + inY + ", \nCurrPointerY1=" + \nCurrPointerY1 + ", \nCurrPointerY2=" + \nCurrPointerY2 + ", \nCurrPointerClickOffset=" + \nCurrPointerClickOffset)
      EndIf
      
    EndIf
    ; debugMsg(sProcName,"\bCurrMove=" + strB(\bCurrMove) + ", \bBasePointerSelected=" + strB(\bBasePointerSelected) + ", \nCurrPointerClickOffset=" + \nCurrPointerClickOffset)
  EndWith
EndProcedure

Procedure SLD_condStartDrawing(nSldPtr)
  With gaSlider(nSldPtr)
    If \bDrawingStarted = #False
      StartDrawing(CanvasOutput(\cvsSlider))
      \bDrawingStarted = #True
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndWith
EndProcedure

Procedure SLD_condStopDrawing(nSldPtr, bDrawingStartedByMe)
  With gaSlider(nSldPtr)
    If bDrawingStartedByMe
      StopDrawing()
      \bDrawingStarted = #False
    EndIf
  EndWith
EndProcedure

Procedure SLD_createSliderGadgets(nSldPtr, pParentGadget, pParentGadgetItem)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; This procedure must be called when the slider is created, resized, or if the slider type is to be changed (eg from Level to Pan or vice versa).
  ; Problems were encountered in trying to resize the 'image' as the object created by 'createImage' doesn't seem to be resizable.
  ; The solution adopted is that if a resize is required then the slider gadgets should be re-created. Hence this procedure includes
  ; code to free the gadgets if they currently exist.
  Protected fMyXFactor.f = 1.0
  Protected fMyYFactor.f = 1.0
  Protected fReqdFontSize.f
  
  ; debugMsg(sProcName, #SCS_START + ", pParentGadget=G" + pParentGadget + ", pParentGadgetItem=" + pParentGadgetItem)
  
  gbCreatingSliderGadgets = #True
  gnCurrentSliderNo = nSldPtr
  
  scsOpenGadgetList(pParentGadget, pParentGadgetItem)
    
    CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
    With gaSlider(nSldPtr)
      
      ; free any existing gadgets
      \cvsSlider = condFreeGadget(\cvsSlider)
      
      ; \cvsSlider = scsCanvasGadget(\nCanvasX, \nCanvasY, \nCanvasWidth, \nCanvasHeight, #PB_Canvas_ClipMouse | #PB_Canvas_Keyboard, \sName+"\cvsSlider")
      ; NB removed 'ClipMouse' 31May2016 11.5.0RC2 following error reported by Lluís Vilarrasa whereby validation of a text field my throw and error displayed by MessageRequester
      ; but if the validation is triggered by clicking on a slider with 'ClipMouse' then the mouse gets locked inside the boundaries of the slider, and so the user
      ; may not be able to click the relevant button in the MessageRequester.
      ; See also test program ClipMouseTest.pb
      \cvsSlider = scsCanvasGadget(\nCanvasX, \nCanvasY, \nCanvasWidth, \nCanvasHeight, #PB_Canvas_Keyboard, \sName+"\cvsSlider")
      CompilerIf #cTraceGadgets
        debugMsg(sProcName,"GadgetX(G" + \cvsSlider + ")=" + GadgetX(\cvsSlider) + ", GadgetHeight(G" + \cvsSlider + ")=" + GadgetHeight(\cvsSlider) + ", fMyYFactor=" + StrF(fMyYFactor,4))
      CompilerEndIf
      
      SLD_Resize(nSldPtr, #True, fMyYFactor, fMyXFactor)
      
    EndWith
    
  scsCloseGadgetList()
  
  gnCurrentSliderNo = -1
  gbCreatingSliderGadgets = #False
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_drawBackground(nSldPtr, nBackColor)
  
  With gaSlider(nSldPtr)
    Box(0, 0, \nCanvasWidth, \nCanvasHeight, nBackColor)
    If \m_GtrAreaBackColor <> -1
      If \m_GtrAreaBackColor <> \m_BackColor
        Box(\nGtrDistanceLeft, 0, \nGtrLength, \nCanvasHeight, \m_GtrAreaBackColor)
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_drawCaption(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nLeft, nTop, nRight, nBottom
  Protected nTextWidth, nTextX
  
  ; debugMsg(sProcName, #SCS_START + ", nSldPtr=" + nSldPtr)
  
  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    
    If IsGadget(\cvsSlider) = #False
      RaiseMiscError(gaSlider(nSldPtr)\sName + ", IsGadget(\cvsSlider) returned #False, \cvsSlider=G" + \cvsSlider)
    EndIf
    
    gnLabelSlider = 1001
    If StartDrawing(CanvasOutput(\cvsSlider))
      
      ; fill area with background color
      If (\nCanvasWidth <= 0) Or (\nCanvasWidth > 2000) Or (\nCanvasHeight <= 0) Or (\nCanvasHeight > 2000)
        RaiseMiscError(gaSlider(nSldPtr)\sName + " \nCanvasWidth=" + \nCanvasWidth + ", \nCanvasHeight=" + \nCanvasHeight)
      EndIf
      ; debugMsg(sProcName, gaSlider(nSldPtr)\sName + " \nCanvasWidth=" + \nCanvasWidth + ", \nCanvasHeight=" + \nCanvasHeight + ", \m_BackColor=$" + Hex(\m_BackColor))
      ; Box(0,0,\nCanvasWidth,\nCanvasHeight,\m_BackColor)
      ; debugMsg(sProcName, "calling SLD_drawBackground(" + nSldPtr + ", " + debugColorCode(\m_BackColor) + ")")
      gnLabelSlider = 1002
      SLD_drawBackground(nSldPtr, \m_BackColor)
      
      ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\nLblFontId=" + \nLblFontId)
      DrawingFont(\nLblFontId)
      
      If \sCaptionText
        nTextWidth = TextWidth(\sCaptionText)
        nTextX = 0
        If nTextWidth < \nCanvasWidth
          nTextX + ((\nCanvasWidth - nTextWidth) >> 1)
        EndIf
        DrawingMode(#PB_2DDrawing_Transparent)
        gnLabelSlider = 1003
        DrawText(nTextX, 0, \sCaptionText, #SCS_Yellow)
      EndIf
      
      StopDrawing()
      gnLabelSlider = 1009
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_drawKnob(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  
  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    If StartDrawing(CanvasOutput(\cvsSlider))
      ; fill area with background color
      ; Box(0,0,\nCanvasWidth,\nCanvasHeight,\m_BackColor)
      SLD_drawBackground(nSldPtr, \m_BackColor)
      StopDrawing()
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_drawScrollBar(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nLeft, nTop, nRight, nBottom

  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    gnLabelSlider = 1101
    If StartDrawing(CanvasOutput(\cvsSlider))
      ; fill area with background color
      ; Box(0,0,\nCanvasWidth,\nCanvasHeight,\m_BackColor)
      ; debugMsg(sProcName, "calling SLD_drawBackground(" + nSldPtr + ", " + debugColorCode(\m_BackColor) + ")")
      gnLabelSlider = 1102
      SLD_drawBackground(nSldPtr, \m_BackColor)
      
      ; draw gutter
      LineXY(\nGtrX1, \nGtrY1,   \nGtrX2, \nGtrY2,   #SCS_Black)
      LineXY(\nGtrX1, \nGtrY1+1, \nGtrX2, \nGtrY2+1, #SCS_White)
      ; debugMsg(sProcName, "\nGtrX1=" + \nGtrX1 + ", \nGtrX2=" + \nGtrX2 + ", \nGtrLength=" + \nGtrLength)
      
      ; draw the button on the slider
      If \m_Value >= \m_Min
        nLeft = ((\m_Value - \m_Min) * \fUnitSize) ; - \btnHalfWdth
        nTop = \nCanvasHalfHeight - \btnHalfHght - 1
        nRight = nLeft + \btnWdth
        nBottom = \nCanvasHalfHeight + \btnHalfHght - 1
        ; debugMsg(sProcName, "\nSliderType=" + \nSliderType + ", nLeft=" + nLeft + ", \m_Value=" + \m_Value + ", \m_Min=" + \m_Min + ", \m_Max=" + \m_Max + ", \fUnitSize=" + StrF(\fUnitSize,4) + ", \nGtrDistanceLeft=" + \nGtrDistanceLeft)
        If \m_Enabled
          ; debugMsg(sProcName, "\btnColor1=$" + RSet(Hex(\btnColor1), 6, "0"))
          SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnColor1, \btnColor2, #SCS_POINTER_BORDERCOLOR2)
        Else
          SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, #SCS_Disabled_Pointer_Color, #SCS_Disabled_Pointer_Color, #SCS_POINTER_BORDERCOLOR2)
        EndIf
        \nCurrPointerX1 = nLeft
        \nCurrPointerX2 = nRight
      Else
        \nCurrPointerX1 = -1000
        \nCurrPointerX2 = -1000
      EndIf
      
      StopDrawing()
      gnLabelSlider = 1109
    EndIf
    
  EndWith
EndProcedure

Procedure SLD_loadAudioGraph(nSldPtr, bReload=#False)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nFileDataPtr
  Protected nAudPtr
  Protected nPlayableStart, nPlayableEnd, nMaxLoopInfo
  Protected byPeakL.b, byMinL.b, byPeakR.b, byMinR.b
  Protected nArraySize
  Protected X
  Protected n
  Protected bLoadResult, bNewImage
  Protected nPass, nImageNo, nINFGColorL, nINFGColorR
  
  ; debugMsg(sProcName, #SCS_START + ", bReload=" + strB(bReload))
  
  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    nAudPtr = \m_AudPtr
    If nAudPtr >= 0
      nFileDataPtr = aAud(nAudPtr)\nFileDataPtr
      If nFileDataPtr >= 0
        nPlayableStart = aAud(nAudPtr)\nAbsStartAt
        nPlayableEnd = aAud(nAudPtr)\nAbsEndAt
        nMaxLoopInfo = aAud(nAudPtr)\nMaxLoopInfo
        If nMaxLoopInfo >= 0
          If aAud(nAudPtr)\aLoopInfo(0)\nAbsLoopStart < nPlayableStart
            nPlayableStart = aAud(nAudPtr)\aLoopInfo(0)\nAbsLoopStart
          EndIf
          If aAud(nAudPtr)\aLoopInfo(nMaxLoopInfo)\nAbsLoopEnd > nPlayableEnd
            nPlayableEnd = aAud(nAudPtr)\aLoopInfo(nMaxLoopInfo)\nAbsLoopEnd
          EndIf
        EndIf
        grMG3\nGraphChannels = gaFileData(nFileDataPtr)\nxFileChannels
        ; Added 30Jul2024 11.10.3av
        If grMG3\nGraphChannels > 2
          ; In SCS, audio/video files that have more than 2 channels will have their audio graphs displayed as just two channels.
          ; The 'left' channel will be the sum of channels 1, 3, 5, etc, and the 'right' channel will be the sum of channels 2, 4, 6, etc.
          ; So the number of 'graph channels' for these files should be set to 2.
          grMG3\nGraphChannels = 2
        EndIf
        ; End added 30Jul2024 11.10.3av
        ; debugMsg0(sProcName, "gaFileData(" + nFileDataPtr + ")\nxFileChannels=" + gaFileData(nFileDataPtr)\nxFileChannels + ", grMG3\nGraphChannels=" + grMG3\nGraphChannels)
        
        \nAudioGraphWidth = \nCanvasWidth - \nLblLeftWidth - \nLblRightWidth
        ; debugMsg(sProcName, "\nCanvasWidth=" + \nCanvasWidth + ", \nLblLeftWidth=" + \nLblLeftWidth + ", \nLblRightWidth=" + \nLblRightWidth + ", \nAudioGraphWidth=" + \nAudioGraphWidth)
        ; added 25Mar2019 11.8.0.2ck following report (not yet resolved) whereby 
        grMG3\nInnerWidth = \nAudioGraphWidth
        ; debugMsg(sProcName, "grMG3\nInnerWidth=" + grMG3\nInnerWidth)
        \nAudioGraphHeight = \nCanvasHeight
        
        If (bReload) Or (grMG3\nSldPtr <> nSldPtr)
          ; debugMsg(sProcName, "calling newGraph(@grMG3, " + getAudLabel(nAudPtr) + ", " + \nAudioGraphWidth + ")")
          newGraph(@grMG3, nAudPtr, \nAudioGraphWidth) ; initialize grMG3 for this graph
          grMG3\nSldPtr = nSldPtr
        EndIf
        
        ; debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromDatabase(@grMG3, " + nFileDataPtr + ", " + \nAudioGraphWidth + ", " + getAudLabel(nAudPtr) + ")")
        bLoadResult = loadSlicePeakAndMinArraysFromDatabase(@grMG3, nFileDataPtr, \nAudioGraphWidth, nAudPtr)
        If bLoadResult = #False
          debugMsg(sProcName, "loadSlicePeakAndMinArraysFromDatabase(@grMG3, " + nFileDataPtr + ", " + \nAudioGraphWidth + ", " + getAudLabel(nAudPtr) + ") returned " + strB(bLoadResult))
          If \nLoadFileRequestCount < 1   ; if we don't check this then the program will loop, continually requesting the file be loaded
            \bRedrawSldAfterLoad = #True
            \bLoadFileRequest = #True
            \nLoadFileRequestCount + 1
            \nAudioGraphImageNo = 0
            \nAudioGraphImageNoPlay = 0
            \bAudioGraphImageReady = #False
            debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bLoadFileRequest=" + strB(\bLoadFileRequest) + ", \nLoadFileRequestCount=" + \nLoadFileRequestCount)
            THR_createOrResumeAThread(#SCS_THREAD_SLIDER_FILE_LOADER)
          EndIf
          ; debugMsg(sProcName, "exiting - returning #False")
          ProcedureReturn #False
        EndIf
        
        ; debugMsg(sProcName, "IsImage(" + \nAudioGraphImageNo + ")=" + IsImage(\nAudioGraphImageNo))
        If IsImage(\nAudioGraphImageNo)
          If (ImageWidth(\nAudioGraphImageNo) <> \nAudioGraphWidth) Or (ImageHeight(\nAudioGraphImageNo) <> \nAudioGraphHeight)
            FreeImage(\nAudioGraphImageNo)
            \nAudioGraphImageNo = 0
          EndIf
        EndIf
        If IsImage(\nAudioGraphImageNo) = #False
          ; create a (new) image for this audio graph slider
          gnNextImageNo + 1
          \nAudioGraphImageNo = gnNextImageNo
          If CreateImage(\nAudioGraphImageNo, \nAudioGraphWidth, \nAudioGraphHeight) = #False
            ; shouldn't happen, I hope
            \nAudioGraphImageNo = 0
          EndIf
        EndIf
        ; debugMsg(sProcName, "IsImage(" + \nAudioGraphImageNo + ")=" + IsImage(\nAudioGraphImageNo))
        If IsImage(\nAudioGraphImageNoPlay)
          If (ImageWidth(\nAudioGraphImageNoPlay) <> \nAudioGraphWidth) Or (ImageHeight(\nAudioGraphImageNoPlay) <> \nAudioGraphHeight)
            FreeImage(\nAudioGraphImageNoPlay)
            \nAudioGraphImageNoPlay = 0
          EndIf
        EndIf
        If grColorScheme\rColorAudioGraph\nLeftColor = grColorScheme\rColorAudioGraph\nRightColor Or grColorScheme\rColorAudioGraph\bRightSameAsLeft ; Added \bRightSameAsLeft 24Mar2025 following emails from Detlef Rosenthal
          ; the graph color will only be changed for 'playing' cues if left and right colors are the same as (currently) we only use a single 'playing' color
          If IsImage(\nAudioGraphImageNoPlay) = #False
            ; create a (new) 'playing' image for this audio graph slider
            gnNextImageNo + 1
            \nAudioGraphImageNoPlay = gnNextImageNo
            If CreateImage(\nAudioGraphImageNoPlay, \nAudioGraphWidth, \nAudioGraphHeight) = #False
              ; shouldn't happen, I hope
              \nAudioGraphImageNoPlay = 0
            EndIf
          EndIf
          ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\nAudioGraphImageNo=" + \nAudioGraphImageNo + ", \nAudioGraphImageNoPlay=" + \nAudioGraphImageNoPlay)
          ; If IsImage(\nAudioGraphImageNoPlay)
          ;   debugMsg(sProcName, "ImageWidth(\nAudioGraphImageNoPlay)=" + ImageWidth(\nAudioGraphImageNoPlay) + ", ImageHeight(\nAudioGraphImageNoPlay)=" + ImageHeight(\nAudioGraphImageNoPlay))
          ; EndIf
        EndIf
        
        SLD_loadLvlPts(nSldPtr)   ; 16Jan2017 (must be called AFTER \nAudioGraphImageNo has been set)
        
        If IsGadget(\cvsSlider)
          grMG3\nGraphHeight = GadgetHeight(\cvsSlider)
          ; debugMsg(sProcName, "GadgetHeight(" + getGadgetName( \cvsSlider) + ")=" + GadgetHeight(\cvsSlider))
        EndIf
        
        \nSldFileDataPtr = nFileDataPtr
        
        If grMG3\nFileDataPtrForSlicePeakAndMinArrays = \nSldFileDataPtr
          
          resetGraphView(@grMG3, nPlayableStart, nPlayableEnd)
          
          nArraySize = ArraySize(grMG3\aSlicePeakL())
          grMG3\nFirstIndex = 0
          grMG3\nLastIndex = grMG3\nFirstIndex + grMG3\nVisibleWidth - 1
          If grMG3\nLastIndex > nArraySize
            grMG3\nLastIndex = nArraySize
          EndIf
          
          If grMG3\nGraphChannels = 1
            grMG3\nGraphLeftBaseY = (grMG3\nGraphHeight >> 1)
            grMG3\nGraphLeftBaseY + grMG3\nGraphTop
            grMG3\nGraphPartHeight = grMG3\nGraphHeight >> 1
          Else
            grMG3\nGraphLeftBaseY = (grMG3\nGraphHeight >> 2)
            grMG3\nGraphRightBaseY = (grMG3\nGraphHeight * 3 / 4)
            grMG3\nGraphLeftBaseY + grMG3\nGraphTop
            grMG3\nGraphRightBaseY + grMG3\nGraphTop
            grMG3\nGraphPartHeight = grMG3\nGraphHeight >> 2
          EndIf
          grMG3\fYFactor = grMG3\nGraphPartHeight / 128
          grMG3\fYFactor * grMG3\fNormalizeFactor
          ; debugMsg(sProcName, "grMG3\nGraphPartHeight=" + grMG3\nGraphPartHeight + ", grMG3\fNormalizeFactor=" + StrF(grMG3\fNormalizeFactor,4) + ", grMG3\fYFactor=" + StrF(grMG3\fYFactor,4))
          ; debugMsg(sProcName, "grMG3\nGraphChannels=" + grMG3\nGraphChannels + ", grMG3\nGraphTop=" + grMG3\nGraphTop + ", grMG3\nGraphHeight=" + grMG3\nGraphHeight +
          ;                     ", grMG3\nGraphLeftBaseY=" + grMG3\nGraphLeftBaseY + ", grMG3\nGraphRightBaseY=" + grMG3\nGraphRightBaseY)
          For nPass = 1 To 2
            If nPass = 1
              nImageNo = \nAudioGraphImageNo
              nINFGColorL = grMG3\nINFGColorL
              nINFGColorR = grMG3\nINFGColorR
            Else
              nImageNo = \nAudioGraphImageNoPlay
              nINFGColorL = grMG3\nINFGColorLPlay
              nINFGColorR = grMG3\nINFGColorRPlay
              ; debugMsg(sProcName, "grMG3\nINFGColorLPlay=" + debugColorCode(grMG3\nINFGColorLPlay))
            EndIf
            ; debugMsg(sProcName, "nPass=" + nPass + ", IsImage(" + nImageNo + ")=" + IsImage(nImageNo) + ", nINFGColorL=" + debugColorCode(nINFGColorL) + ", nINFGColorR=" + debugColorCode(nINFGColorR))
            If IsImage(nImageNo)
              gnLabelSlider = 1201
              If StartDrawing(ImageOutput(nImageNo))
                gnLabelSlider = 1202
                Box(0, 0, OutputWidth(), OutputHeight(), grMG4\nINBGColor)
                gnLabelSlider = 1203
                X = 0
                ; debugMsg(sProcName, "grMG3\nFileChannels=" + grMG3\nFileChannels + ", grMG3\nGraphLeftBaseY=" + grMG3\nGraphLeftBaseY + ", grMG3\nFirstIndex=" + grMG3\nFirstIndex + ", grMG3\nLastIndex=" + grMG3\nLastIndex)
                If grMG3\nMGFileChannels = 1
                  For n = grMG3\nFirstIndex To grMG3\nLastIndex
                    ; debugMsg(sProcName, "grMG3\aSlicePeakL(" + n + ")=" + grMG3\aSlicePeakL(n) + ", grMG3\aSliceMinL(" + n + ")=" + grMG3\aSliceMinL(n))
                    byPeakL = grMG3\aSlicePeakL(n) * grMG3\fYFactor
                    byMinL = grMG3\aSliceMinL(n) * grMG3\fYFactor
                    ; if there's any audio at all in the slice then this will show on the audio graph
                    ; (just show either peak or min, not both, so a single pixel is drawn - note that to get here means the level represnts less than half a pixel, but we want to show there is audio here)
                    If byPeakL = 0 And byMinL = 0
                      If grMG3\aSlicePeakL(n) > 0
                        byPeakL = 1
                      ElseIf grMG3\aSliceMinL(n) < 0
                        byMinL = -1
                      EndIf
                    EndIf
                    If (byPeakL <> 0) Or (byMinL <> 0)
                      LineXY(X, grMG3\nGraphLeftBaseY - byMinL, X, grMG3\nGraphLeftBaseY - byPeakL + 1, nINFGColorL)
                      ; debugMsg(sProcName, "LineXY(" + X + ", " + Str(grMG3\nGraphLeftBaseY - byMinL) + ", " + X + ", " + Str(grMG3\nGraphLeftBaseY - byPeakL + 1) + ", " + hex6(nINFGColorL) + ")")
                    EndIf
                    X + 1
                  Next n
                  
                Else
                  ; debugMsg(sProcName, "grMG3\nFirstIndex=" + grMG3\nFirstIndex + ", grMG3\nLastIndex=" + grMG3\nLastIndex)
                  For n = grMG3\nFirstIndex To grMG3\nLastIndex
                    CheckSubInRange(n, ArraySize(grMG3\aSlicePeakL()), "grMG3\aSlicePeakL()")
                    byPeakL = grMG3\aSlicePeakL(n) * grMG3\fYFactor
                    byMinL = grMG3\aSliceMinL(n) * grMG3\fYFactor
                    ; if there's any audio at all in the slice then this will show on the audio graph
                    ; (just show either peak or min, not both, so a single pixel is drawn - note that to get here means the level represnts less than half a pixel, but we want to show there is audio here)
                    If byPeakL = 0 And byMinL = 0
                      If grMG3\aSlicePeakL(n) > 0
                        byPeakL = 1
                      ElseIf grMG3\aSliceMinL(n) < 0
                        byMinL = -1
                      EndIf
                    EndIf
                    If byPeakR = 0 And byMinR = 0
                      If grMG3\aSlicePeakR(n) > 0
                        byPeakR = 1
                      ElseIf grMG3\aSliceMinR(n) < 0
                        byMinR = -1
                      EndIf
                    EndIf
                    If (byPeakL <> 0) Or (byMinL <> 0)
                      LineXY(X, grMG3\nGraphLeftBaseY - byMinL, X, grMG3\nGraphLeftBaseY - byPeakL + 1, nINFGColorL)
                      ; debugMsg(sProcName, "LineXY(" + X + ", " + Str(grMG3\nGraphLeftBaseY - byMinL) + ", " + X + ", " + Str(grMG3\nGraphLeftBaseY - byPeakL + 1) + ", " + hex6(nINFGColorL) + ")")
                    Else
                      ; debugMsg(sProcName, "X=" + X + ", byPeakL=" + byPeakL + ", byMinL=" + byMinL)
                    EndIf
                    byPeakR = grMG3\aSlicePeakR(n) * grMG3\fYFactor
                    byMinR = grMG3\aSliceMinR(n) * grMG3\fYFactor
                    If (byPeakR <> 0) Or (byMinR <> 0)
                      LineXY(X, grMG3\nGraphRightBaseY - byMinR, X, grMG3\nGraphRightBaseY - byPeakR + 1, nINFGColorR)
                      ; debugMsg(sProcName, "LineXY(" + X + ", " + Str(grMG3\nGraphRightBaseY - byMinR) + ", " + X + ", " + Str(grMG3\nGraphRightBaseY - byPeakR + 1) + ", " + hex6(nINFGColorR) + ")")
                    EndIf
                    X + 1
                  Next n
                  
                EndIf
                
                StopDrawing()
                gnLabelSlider = 1209
                
                If nPass = 1
                  ; now save information applicable to the drawing of this audio graph
                  \nAudioGraphAudPtr = nAudPtr
                  \nAudioGraphFileDuration = aAud(nAudPtr)\nFileDuration
                  \nAudioGraphFileChannels = aAud(nAudPtr)\nFileChannels
                  \nAudioGraphAbsMin = aAud(nAudPtr)\nAbsMin
                  \nAudioGraphAbsMax = aAud(nAudPtr)\nAbsMax
                  
                  \bAudioGraphImageReady = #True
                  If \bRedrawThisSld = #False
                    \bRedrawThisSld = #True
                    gnRedrawSldCount + 1
                  EndIf
                  ; debugMsg(sProcName, "\bAudioGraphImageReady=" + strB(\bAudioGraphImageReady) + ", \bRedrawThisSld=" + strB(\bRedrawThisSld) + ", gnRedrawSldCount=" + gnRedrawSldCount)
                EndIf
              EndIf ; EndIf StartDrawing(ImageOutput(\nAudioGraphImageNo))
            EndIf ; EndIf IsImage(\nAudioGraphImageNo)
          Next nPass
        EndIf ; EndIf grMG3\nFileDataPtrForSlicePeakAndMinArrays = \nSldFileDataPtr
      EndIf ; EndIf nFileDataPtr >= 0
    EndIf ; EndIf nAudPtr >= 0
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END, returning #True)
  ProcedureReturn #True ; added 8Feb2020 11.8.2.2ai (previously omitted so always returned #False)
  
EndProcedure

Procedure SLD_drawAudioGraph(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; called from SLD_drawButton(), so do not trace unless necessary
  Protected bResult
  Protected nAudPtr, nAudState, nImageNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaSlider(nSldPtr)
    nImageNo = \nAudioGraphImageNo
    nAudPtr = \m_AudPtr
    If nAudPtr >= 0
      nAudState = aAud(nAudPtr)\nAudState
      If (nAudState >= #SCS_CUE_FADING_IN) And (nAudState <= #SCS_CUE_FADING_OUT) And (nAudState <> #SCS_CUE_HIBERNATING)
        If IsImage(\nAudioGraphImageNoPlay)
          nImageNo = \nAudioGraphImageNoPlay
        EndIf
      EndIf
    EndIf
    ; debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(aAud(nAudPtr)\nAudState) + ", nImageNo=" + nImageNo)
    If IsImage(nImageNo)
      DrawImage(ImageID(nImageNo), \nLblLeftWidth, 0)
      ; debugMsg(sProcName, "DrawImage(ImageID(nImageNo), " + \nLblLeftWidth + ", 0)")
      bResult = #True
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure SLD_drawButton(nSldPtr)
PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nLeft, nTop, nRight, nBottom
  Protected nTextWidth, nTextX
  Protected nTextHeight, nTextY
  Protected sMsg.s
  Protected nBackColor
  Protected bDrawAudioGraphResult
  
  ; do not trace unless necessary
  ; debugMsg0(sProcName, #SCS_START)
  
  ; CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    
    Select \nSliderType
      Case #SCS_ST_HLEVELCHANGERUN, #SCS_ST_HLEVELCHANGERUNPL
        gnLabelSlider = 1301
        SLD_drawCaption(nSldPtr)
        gnLabelSlider = 1302
        ; debugMsg(sProcName, "exiting - \nSliderType=" + \nSliderType + ", \bContinuous=" + strB(\bContinuous) + ", \sCationText=" + \sCaptionText)
        ProcedureReturn
    EndSelect
    
    If \bContinuous
      ; debugMsg(sProcName, "\bContinuous=" + strB(\bContinuous))
      ProcedureReturn
    EndIf
    
    Select \nSliderType
      Case #SCS_ST_ROTARYGAIN ; #SCS_ST_ROTARYGAIN
        SLD_drawKnob(nSldPtr)
        ProcedureReturn
        
      Case #SCS_ST_HSCROLLBAR ; #SCS_ST_HSCROLLBAR
        gnLabelSlider = 1303
        SLD_drawScrollBar(nSldPtr)
        gnLabelSlider = 1304
        ProcedureReturn
    EndSelect
    
    If StartDrawing(CanvasOutput(\cvsSlider))
      ; fill area with background color
      nBackColor = \m_BackColor
      If \nCuePanelNo >= 0
        If nBackColor = #SCS_SLD_BACKCOLOR
          If gaPnlVars(\nCuePanelNo)\bActiveOrComplete
            If grColorScheme\aItem[#SCS_COL_ITEM_DA]\nBackColor <> grColorScheme\aItem[#SCS_COL_ITEM_DP]\nBackColor
              nBackColor = $6D6D80
            EndIf
          EndIf
        EndIf
      EndIf
      ; debugMsg(sProcName, "calling SLD_drawBackground(" + nSldPtr + ", " + debugColorCode(nBackColor) + ")")
      gnLabelSlider = 1304
      SLD_drawBackground(nSldPtr, nBackColor)
      gnLabelSlider = 1305
      DrawingFont(\nLblFontId)
      
      If \bHorizontal ; horizontal
        ;{
        gnLabelSlider = 1306
        ; draw left and right text
        If \nLblLeftWidth > 0
          nTextWidth = TextWidth(\sLeftText)
          nTextX = \nLblLeftX
          If nTextWidth < \nLblLeftWidth
            nTextX + ((\nLblLeftWidth - nTextWidth) >> 1)
          EndIf
          If \sLeftText = #SCS_Text_Minus_Infinity
            DrawingFont(FontID(\fontInfinity))
          Else
            DrawingFont(FontID(\fontLabels))
          EndIf
          DrawText(nTextX, \nLblLeftY, \sLeftText, #SCS_Yellow, nBackColor)
        EndIf
        If \nLblRightWidth > 0
          nTextWidth = TextWidth(\sRightText)
          nTextX = \nLblRightX
          If nTextWidth < \nLblRightWidth
            nTextX + ((\nLblRightWidth - nTextWidth) >> 1)
          EndIf
          If \sRightText = #SCS_Text_Minus_Infinity
            DrawingFont(FontID(\fontInfinity))
          Else
            DrawingFont(FontID(\fontLabels))
          EndIf
          DrawText(nTextX, \nLblRightY, \sRightText, #SCS_Yellow, nBackColor)
        EndIf
        
        If \bAudioGraph
          bDrawAudioGraphResult = SLD_drawAudioGraph(nSldPtr)
        EndIf
        
        If (\bAudioGraph) And (bDrawAudioGraphResult)
          ; draw mark lines on audio graph (if reqd)
          If \m_LineCount > 0
            SLD_drawLoopLines(nSldPtr)
          EndIf
          ; draw cue marker lines on audio graph (if reqd)
          If \m_LineCount > 0
            SLD_drawCueMarkers(nSldPtr)
          EndIf

        Else
          ; draw gutter
          LineXY(\nGtrX1,\nGtrY1,\nGtrX2,\nGtrY2,#SCS_Black)
          LineXY(\nGtrX1,\nGtrY1+1,\nGtrX2,\nGtrY2+1,#SCS_White)
          ; draw tick lines and mark lines
          SLD_drawTickLines(nSldPtr)
        EndIf
        
        ; draw level envelope if reqd
        If \nMaxArrayIndex > 0
          SLD_drawLvlPts(nSldPtr)
        EndIf
        
        ; Draw the button(s) on the slider
        If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL
          \nBasePointerX1 = -1000
          \nBasePointerX2 = -1000
        ElseIf \m_BaseValue <> #SCS_SLD_NO_BASE
          nLeft = SLD_calcMarkerPosForSliderValue(nSldPtr, \m_BaseValue) - \btnHalfWdth
          nTop = (\nCanvasHalfHeight - \btnHalfHght - 1)
          nRight = nLeft + \btnWdth
          nBottom = (\nCanvasHalfHeight + \btnHalfHght - 1)
          SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnBaseColor, \btnBaseColor, #SCS_POINTER_BORDERCOLOR1)
          \nBasePointerX1 = nLeft
          \nBasePointerX2 = nRight
        Else
          \nBasePointerX1 = -1000
          \nBasePointerX2 = -1000
        EndIf
        
        If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL
          nLeft = \nGtrDistanceLeft + \nSldCustomLinePos - \btnHalfWdth
          nTop = (\nCanvasHalfHeight - \btnHalfHght - 1)
          nRight = nLeft + \btnWdth
          nBottom = (\nCanvasHalfHeight + \btnHalfHght - 1)
          SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnColor1, \btnColor2, #SCS_POINTER_BORDERCOLOR2)
          \nCurrPointerX1 = nLeft
          \nCurrPointerX2 = nRight
        ElseIf \m_Value >= \m_Min
          If (\bAudioGraph) ; And (bDrawAudioGraphResult) 
                            ; WARNING! do NOT include bDrawAudioGraphResult in this test or the slider will be drawn incorrectly when bDrawAudioGraphResult = #False
            nLeft = (\nLblLeftWidth + ((\m_Value - \m_Min) * \fUnitSize))
            nRight = nLeft
            nTop = 0
            nBottom = \nCanvasHeight - 1
            If \nCuePanelNo >= 0
              If \m_Value > 0
                ; this code dims the 'past' portion of the audio graph by drawing a 50% transparent black box over the area
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                Box(\nLblLeftWidth, 0, nLeft-\nLblLeftWidth-1, \nCanvasHeight, $80000000) ; RGBA(0,0,0,128))
                DrawingMode(#PB_2DDrawing_Default)
              EndIf
            EndIf
            drawPosCursor(nLeft, nTop, nBottom, grColorScheme\rColorAudioGraph\nCuePanelCursorColor, grColorScheme\rColorAudioGraph\nCuePanelShadowColor, #True)
          Else
            nLeft = SLD_calcMarkerPosForSliderValue(nSldPtr, \m_Value) - \btnHalfWdth
            nTop = (\nCanvasHalfHeight - \btnHalfHght - 1)
            nRight = nLeft + \btnWdth
            nBottom = (\nCanvasHalfHeight + \btnHalfHght - 1)
            If \nCuePanelNo >= 0
              If (\nSliderType = #SCS_ST_PROGRESS) And (\m_Value > 0)
                ; this code dims the 'past' portion of the progress slider by drawing a 50% transparent black box over the area
                DrawingMode(#PB_2DDrawing_AlphaBlend)
                Box(\nGtrDistanceLeft, 0, nLeft-\nGtrDistanceLeft+\btnHalfWdth, \nCanvasHeight, $40000000) ; RGBA(0,0,0,64))
                DrawingMode(#PB_2DDrawing_Default)
              EndIf
            EndIf
            If \m_Enabled
              SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnColor1, \btnColor2, #SCS_POINTER_BORDERCOLOR2)
            Else
              SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, #SCS_Disabled_Pointer_Color, #SCS_Disabled_Pointer_Color, #SCS_POINTER_BORDERCOLOR2)
            EndIf
          EndIf
          \nCurrPointerX1 = nLeft
          \nCurrPointerX2 = nRight
        Else
          \nCurrPointerX1 = -1000
          \nCurrPointerX2 = -1000
        EndIf
        ;}
      Else  ; vertical
        ;{
        gnLabelSlider = 1307
        ; draw top and bottom text
        If \nLblTopHeight > 0
          nTextWidth = TextWidth(\sTopText)
          nTextX = 0
          If nTextWidth < \nLblTopWidth
            nTextX + ((\nLblTopWidth - nTextWidth) >> 1)
          EndIf
          If \sTopText = #SCS_Text_Minus_Infinity
            DrawingFont(FontID(\fontInfinity))
          Else
            DrawingFont(FontID(\fontLabels))
          EndIf
          DrawText(nTextX, 0, \sTopText, #SCS_Yellow, nBackColor)
        EndIf
        If \nLblBottomHeight > 0
          nTextWidth = TextWidth(\sBottomText)
          nTextX = 0
          If nTextWidth < \nLblBottomWidth
            nTextX + ((\nLblBottomWidth - nTextWidth) >> 1)
          EndIf
          If \sBottomText = #SCS_Text_Minus_Infinity
            DrawingFont(FontID(\fontInfinity))
          Else
            DrawingFont(FontID(\fontLabels))
          EndIf
          DrawText(nTextX, \nLblBottomY, \sBottomText, #SCS_Yellow, nBackColor)
          ; debugMsg(sProcName, "\sBottomText=" + \sBottomText)
        EndIf
        
        Select \nSliderType
          Case #SCS_ST_VFADER_LIVE_INPUT To #SCS_ST_VFADER_DIMMER_CHAN ; #SCS_ST_VFADER_DMX_MASTER
            ; do not draw gutter
          Default
            ; draw gutter
            LineXY(\nGtrX1,\nGtrY1,\nGtrX2,\nGtrY2,#SCS_Black)
            LineXY(\nGtrX1+1,\nGtrY1,\nGtrX2+1,\nGtrY2,#SCS_White)
            ; draw tick lines and mark lines
            ; debugMsg(sProcName, "calling SLD_drawTickLines(" + nSldPtr + ")")
            SLD_drawTickLines(nSldPtr)
        EndSelect
        
        ; draw the button(s) on the slider
        If \m_BaseValue <> #SCS_SLD_NO_BASE
          nTop = (\nGtrDistanceTop + ((\m_BaseValue - \m_Min) * \fUnitSize) - \btnHalfHght)
          nLeft = (\nCanvasHalfWidth - \btnHalfWdth - 1)
          nBottom = nTop + \btnHght
          nRight = (\nCanvasHalfWidth + \btnHalfWdth - 1)
          SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnBaseColor, \btnBaseColor, #SCS_POINTER_BORDERCOLOR1)
          \nBasePointerY1 = nLeft
          \nBasePointerY2 = nRight
        Else
          \nBasePointerY1 = -1000
          \nBasePointerY2 = -1000
        EndIf
        
        If \m_Value >= \m_Min
          If \bFader
            nTop = (\nMinPos - ((\m_Value - \m_Min) * \fUnitSize) - \btnHalfHght)
          Else
            nTop = (\nGtrDistanceTop + ((\m_Value - \m_Min) * \fUnitSize) - \btnHalfHght)
          EndIf
          nLeft = (\nCanvasHalfWidth - \btnHalfWdth - 1)
          nBottom = nTop + \btnHght
          nRight = (\nCanvasHalfWidth + \btnHalfWdth - 1)
;           If \nSliderType = #SCS_ST_VFADER_DMX_MASTER Or \nSliderType = #SCS_ST_VFADER_MASTER
;             debugMsg0(sProcName, "\nSliderType=" + \nSliderType + ", \nMinPos=" + \nMinPos + ", \nMaxPos=" + \nMaxPos + ", \m_Value=" + \m_Value)
;             debugMsg0(sProcName, "\nGtrDistanceTop=" + \nGtrDistanceTop + ", \m_Value=" + \m_Value + ", \m_Min=" + \m_Min + ", \fUnitSize=" + StrF(\fUnitSize,4) + ", \btnHalfHght=" + \btnHalfHght + ", nTop=" + nTop)
;             debugMsg0(sProcName, "\nGtrLength=" + \nGtrLength + ", \nImageHeight=" + \nImageHeight + ", \nImageCentreOffset=" + \nImageCentreOffset + ", \nCurrPointerY1=" + \nCurrPointerY1 + ", \nCurrPointerY2=" + \nCurrPointerY2)
;             debugMsg0(sProcName, "\nPhysicalRange=" + \nPhysicalRange + ", \nLogicalRange=" + \nLogicalRange)
;           EndIf
          If \m_Enabled
            SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, \btnColor1, \btnColor2, #SCS_POINTER_BORDERCOLOR2)
          Else
            SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, #SCS_Disabled_Pointer_Color, #SCS_Disabled_Pointer_Color, #SCS_POINTER_BORDERCOLOR2)
          EndIf
          \nCurrPointerY1 = nTop
          \nCurrPointerY2 = nBottom
        Else
          \nCurrPointerY1 = -1000
          \nCurrPointerY2 = -1000
        EndIf
        ;}
      EndIf
      
      gnLabelSlider = 1308
      StopDrawing()
      gnLabelSlider = 1309
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_drawBoxes(nSldPtr, nLeft, nTop, nRight, nBottom, nBackColor)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; called from within this module to make box areas
  Protected bDrawingStartedByMe
  
  gnLabelSlider = 1401
  bDrawingStartedByMe = SLD_condStartDrawing(nSldPtr)
  Box(nLeft,nTop,(nRight-nLeft),(nBottom-nTop),nBackColor)
  SLD_condStopDrawing(nSldPtr, bDrawingStartedByMe)
  gnLabelSlider = 1409

EndProcedure

Procedure SLD_drawSlider(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; see "Slider Drawing logic" at top of this .pbi file
  Protected nLeft, nTop, nRight, nBottom

  ; CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    If \bInitialized
      nRight = GadgetWidth(\cvsSlider)
      nBottom = GadgetHeight(\cvsSlider)
      SLD_drawBoxes(nSldPtr, nLeft, nTop, nRight, nBottom, \m_BackColor)
      ; Draw button and tick lines on the slider
      SLD_drawButton(nSldPtr)
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_reloadSlidersWhereRequested()
  PROCNAMEC()
  Protected nSldPtr
  
  ; debugMsg(sProcName, #SCS_START + ", gnReloadSldCount=" + gnReloadSldCount)
  
  If gnReloadSldCount > 0
    For nSldPtr = 0 To gnMaxSld
      With gaSlider(nSldPtr)
        If \bReloadThisSld
          If grOperModeOptions(gnOperMode)\bShowAudioGraph
            If SLD_loadAudioGraph(nSldPtr, #True)
              \bReloadThisSld = #False
              gnReloadSldCount - 1
            EndIf
          Else
            \bReloadThisSld = #False
            gnReloadSldCount - 1
          EndIf
        EndIf
      EndWith
    Next nSldPtr
  EndIf
  If gnReloadSldCount < 0
    ; shouldn't get here
    debugMsg(sProcName, "setting gnReloadSldCount=0 (was " + gnReloadSldCount + ")")
    gnReloadSldCount = 0
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_redrawSlidersWhereRequested()
  ; PROCNAMEC()
  Protected nSldPtr
  
  ; debugMsg(sProcName, #SCS_START + ", gnRedrawSldCount=" + gnRedrawSldCount)
  
  gnLabelSlider = 1701
  If gnRedrawSldCount > 0
    For nSldPtr = 0 To gnMaxSld
      With gaSlider(nSldPtr)
        If \bRedrawThisSld
          ; debugMsg(sProcName, "calling SLD_drawSlider(" + SLD_getName(nSldPtr) + "), SLD_getWidth()=" + SLD_getWidth(nSldPtr))
          SLD_drawSlider(nSldPtr)
          \bRedrawThisSld = #False
          gnRedrawSldCount - 1
        EndIf
      EndWith
    Next nSldPtr
  EndIf
  If gnRedrawSldCount < 0
    ; shouldn't get here
    ; debugMsg(sProcName, "setting gnRedrawSldCount=0 (was " + gnRedrawSldCount + ")")
    gnRedrawSldCount = 0
  EndIf
  gnLabelSlider = 1709
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_drawCueMarkers(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected n, nLinePos, nWorkLength, fWorkPos.f
  
  With gaSlider(nSldPtr)
    If \bContinuous = #False
      nWorkLength = \nPhysicalRange
      For n = 0 To (\m_LineCount - 1)
        If \m_LineType(n) = #SCS_SLD_LT_CUE_MARKER
          If (\bAudioGraph) And (\nAudioGraphImageNo)
            nLinePos = (\nLblLeftWidth + ((\m_LinePos(n) - \m_Min) * \fUnitSize))
            ; debugMsg(sProcName, "\nLblLeftWidth=" + \nLblLeftWidth + ", \m_LinePos(" + n + ")=" + \m_LinePos(n) + ", \m_Min=" + \m_Min + ", \fUnitSize=" + StrF(\fUnitSize,6) + ", nLinePos=" + nLinePos + ", \m_Max=" + \m_Max)
          Else
            fWorkPos = \m_LinePos(n) / \m_Max * nWorkLength
            If fWorkPos > (nWorkLength - 1)
              fWorkPos = (nWorkLength - 1)
            EndIf
            nLinePos = \nGtrDistanceLeft + fWorkPos
          EndIf
          ; debugMsg(sProcName, "nLinePos=" + nLinePos)
          LineXY(nLinePos, 1, nLinePos, \nCanvasHeight-2, #SCS_Red)
          LineXY(nLinePos+1, 1, nLinePos+1, \nCanvasHeight-2, #SCS_Red)
          Circle(nLinePos, \nCanvasHalfHeight, 3, #SCS_Red)
          Circle(nLinePos+1, \nCanvasHalfHeight, 3, #SCS_Red)
        EndIf
      Next n
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_drawTickLines(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected n
  Protected X1, X2, Y1, Y2, YOffSet
  Protected nThisMarkSize, nThisMarkSizeMinor, nColor, b0dB, nMidPoint
  Static nPrevColor, nDimColor
  Static nPrevCanvasHeight, nMarkSize0dB, nMarkSizeMajor, nMarkSizeMinor
  
  ; Only called from SLD_drawButton, so StartDrawing() and StopDrawing() not required in this procedure
  
  With gaSlider(nSldPtr)
    
    nColor = \nTickColor
    If nColor <> nPrevColor
      ; this test purely to optimise performance by minimising the need to process the following
      nDimColor = RGB(Red(nColor)/2, Green(nColor)/2, Blue(nColor)/2)
      nPrevColor = nColor
    EndIf
    If \nCanvasHeight <> nPrevCanvasHeight
      nMarkSize0dB = (\nCanvasHeight * 2) / 3 ; 3/4 canvas height
      nMarkSizeMajor = (\nCanvasHeight / 3)   ; 1/2 canvas height
      nMarkSizeMinor = (\nCanvasHeight / 6)   ; 1/4 canvas height
      nPrevCanvasHeight = \nCanvasHeight
    EndIf
    
    Select \nSliderType
      Case #SCS_ST_REMDEV_FADER_LEVEL
        If \nMaxSldCustom > 30 ; arbitrary decision - if there more than 30 tick lines to be displayed (eg for AH-SQ faders) then do not display 'minor' marks
          nThisMarkSizeMinor = 0
        Else
          nThisMarkSizeMinor = nMarkSizeMinor
        EndIf
        Y2 = \nCanvasHeight
        For n = 0 To \nMaxSldCustom
          ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\aSldCustom(" + n + ")\nCustomLinePos=" + \aSldCustom(n)\nCustomLinePos + ", \nCustomDBLevel=" + \aSldCustom(n)\nCustomDBLevel + ", \nCustomLineType=" + \aSldCustom(n)\nCustomLineType)
          Select \aSldCustom(n)\nCustomLineType
            Case #SCS_SLD_CLT_0DB
              nThisMarkSize = nMarkSize0dB
              b0dB = #True
            Case #SCS_SLD_CLT_MAJOR
              nThisMarkSize = nMarkSizeMajor
              b0dB = #False
            Default
              nThisMarkSize = nThisMarkSizeMinor
              b0dB = #False
          EndSelect
          If nThisMarkSize > 0
            X1 = \nGtrDistanceLeft + \aSldCustom(n)\nCustomLinePos
            X2 = X1
            Y1 = \nCanvasHeight - nThisMarkSize
            If b0dB
              LineXY(X1-1,Y1+1,X2-1,Y2,nDimColor)
              LineXY(X1+1,Y1+1,X2+1,Y2,nDimColor)
            EndIf
            LineXY(X1,Y1,X2,Y2,nColor)
          EndIf
        Next n
        
      Case #SCS_ST_FREQ
        X1 = SLD_calcMarkerPosForSliderValue(nSldPtr, 100)
        Y1 = \nCanvasHeight - nMarkSizeMajor
        Y2 = \nCanvasHeight
        LineXY(X1,Y1,X1,Y2,nColor)
        
      Case #SCS_ST_TEMPO
        X1 = SLD_calcMarkerPosForSliderValue(nSldPtr, 100)
        Y1 = \nCanvasHeight - nMarkSizeMajor
        Y2 = \nCanvasHeight
        LineXY(X1,Y1,X1,Y2,nColor)
        
      Case #SCS_ST_PITCH
        X1 = SLD_calcMarkerPosForSliderValue(nSldPtr, 0)
        Y1 = \nCanvasHeight - nMarkSizeMajor
        Y2 = \nCanvasHeight
        LineXY(X1,Y1,X1,Y2,nColor)
        
      Default
        ; Draw small lines for indicating position within the slider
        ; Number of lines drawn will be 1 more than number of segments wanted (\sldNumDiv)
        If \bContinuous = #False
          nColor = \nTickColor
          If \bHorizontal ; horizontal
            Y2 = \nCanvasHeight
            If \bLevelSlider 
              For n = 0 To \sldNumDiv
                nThisMarkSize = \nFaderMarkSize[n]
                If nThisMarkSize > 0
                  X1 = \nGtrDistanceLeft + \nFaderMarks[n]
                  X2 = X1
                  Y1 = \nCanvasHeight - nThisMarkSize
                  CompilerIf #c_slider_mark_section_colors
                    nColor = \nMarkColors[n] ; Useful if you want to clearly see which tick marks are for which section (A, B or C). See SLD_defineLevelMarkers() for where \nMarkColors[n] is set.
                  CompilerEndIf
                  LineXY(X1,Y1,X2,Y2,nColor)
                EndIf
              Next n
            Else
              Y1 = \nCanvasHeight - Round(\nCanvasHeight/10, #PB_Round_Down) - 2
              For n = 0 To \sldNumDiv
                X1 = \nGtrDistanceLeft + (n * \fMarkWidth)
                X2 = X1
                LineXY(X1,Y1,X2,Y2,nColor)
              Next n
            EndIf
            
          Else  ; vertical
            X2 = \nCanvasWidth
            If \bLevelSlider
              If \bFader
                nColor = #SCS_Light_Grey
                nMidPoint = \nMarkerX1 + ((\nMarkerX2 - \nMarkerX1) >> 1)
                For n = 0 To \sldNumDiv
                  nThisMarkSize = \nFaderMarkSize[n]
                  If nThisMarkSize > 0
                    Y1 = \nMinPos - \nFaderMarks[n]
                    X1 = nMidPoint - (nThisMarkSize >> 1)
                    X2 = X1 + nThisMarkSize + 1
                    LineXY(X1,Y1,X2,Y1,nColor)
                    ; debugMsg(sProcName,"LineXY(" + X1 + "," + Y1 + "," + X2 + "," + Y2 + ",nColor)")
                  EndIf
                Next n
              Else
                ; probably not used, but existed before adding the \bFader logic, so left it in place
                For n = 0 To \sldNumDiv
                  nThisMarkSize = \nFaderMarkSize[n]
                  If nThisMarkSize > 0 
                    Y1 = \nGtrDistanceTop + \nFaderMarks[n]
                    X1 = \nCanvasWidth - nThisMarkSize
                    LineXY(X1,Y1,X2,Y1,nColor)
                    ; debugMsg(sProcName,"LineXY(" + X1 + "," + Y1 + "," + X2 + "," + Y2 + ",nColor)")
                  EndIf
                Next n
              EndIf
            Else
              If \nSliderType = #SCS_ST_VFADER_DMX_MASTER Or \nSliderType = #SCS_ST_VFADER_DIMMER_CHAN ; Changed 11Jul2022 11.9.4
                nColor = #SCS_Light_Grey
                X1 = (\nCanvasWidth >> 1) - 9
                X2 = \nCanvasWidth - X1
                YOffSet = 2
              Else
                X1 = \nCanvasWidth - Round(\nCanvasWidth/10, #PB_Round_Down) - 2
                YOffSet = 0
              EndIf
              For n = 0 To \sldNumDiv
                Y1 = \nGtrDistanceTop + YOffSet + (n * \fMarkWidth)
                Y2 = Y1
                LineXY(X1,Y1,X2,Y2,nColor)
              Next n
            EndIf
          EndIf
        EndIf ; EndIf \bContinuous = #False
        ; draw mark lines (if reqd)
        If \m_LineCount > 0
          ; debugMsg(sProcName, "calling SLD_drawLoopLines(" + nSldPtr + ")")
          SLD_drawLoopLines(nSldPtr)
        EndIf
        ; draw cue marker lines (if reqd)
        If \m_LineCount > 0
          SLD_drawCueMarkers(nSldPtr)
        EndIf
        
    EndSelect ; EndSelect \nSliderType
  EndWith
  
EndProcedure

Procedure SLD_drawLoopLines(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; only called from SLD_drawButton or SLD_drawTickLines, so StartDrawing and StopDrawing not required in this procedure
  Protected n, nLinePos, nWorkLength, fWorkPos.f
  Protected nPrevLinePos
  
  With gaSlider(nSldPtr)
    If \bContinuous = #False
      nWorkLength = \nPhysicalRange
      For n = 0 To (\m_LineCount - 1)
        Select \m_LineType(n)
          Case #SCS_SLD_LT_LOOP_START, #SCS_SLD_LT_LOOP_END
            If (\m_LinePos(n) <= \m_Max) And (\m_Max > 0 )
              ; debugMsg(sProcName, "\m_LinePos[" + n + "]=" + \m_LinePos(n) + ", \bAudioGraph=" + strB(\bAudioGraph) + ", \nAudioGraphImageNo=" + \nAudioGraphImageNo + ", \m_LineType(n)=" + \m_LineType(n))
              If (\bAudioGraph) And (\nAudioGraphImageNo)
                nLinePos = (\nLblLeftWidth + ((\m_LinePos(n) - \m_Min) * \fUnitSize))
                ; debugMsg(sProcName, "nLinePos=" + nLinePos)
                LineXY(nLinePos, 1, nLinePos, \nCanvasHeight-2, $CDFAFF)  ; nb color $CDFAFF looks better over the audio graph than grMG2\nLSColorD
                If n > 0
                  If \m_LineType(n) = #SCS_SLD_LT_LOOP_END
                    If \m_LineType(n-1) = #SCS_SLD_LT_LOOP_START
                      LineXY(nPrevLinePos, \nCanvasHeight-2, nLinePos, \nCanvasHeight-2, $CDFAFF)
                    EndIf
                  EndIf
                EndIf
                nPrevLinePos = nLinePos
              Else
                fWorkPos = \m_LinePos(n) / \m_Max * nWorkLength
                If fWorkPos > (nWorkLength - 1)
                  fWorkPos = (nWorkLength - 1)
                EndIf
                If \bHorizontal ; horizontal
                  nLinePos = \nGtrDistanceLeft + fWorkPos
                  ; debugMsg(sProcName, "nLinePos=" + nLinePos)
                  LineXY(nLinePos, 2, nLinePos, \nCanvasHeight-2, grMG2\nLSColorD)
                  If n > 0
                    If \m_LineType(n) = #SCS_SLD_LT_LOOP_END
                      If \m_LineType(n-1) = #SCS_SLD_LT_LOOP_START
                        LineXY(nPrevLinePos, \nCanvasHeight-2, nLinePos, \nCanvasHeight-2, grMG2\nLSColorD)
                      EndIf
                    EndIf
                  EndIf
                  nPrevLinePos = nLinePos
                Else  ; vertical
                  If \bFader
                    LineXY(\nMarkerX1, (\nMaxPos + fWorkPos), \nMarkerX2, (\nMaxPos + fWorkPos), #SCS_Light_Grey)
                  Else
                    LineXY(2, (\nGtrDistanceTop + fWorkPos), \nCanvasWidth-4, (\nGtrDistanceTop + fWorkPos), \nTickColor)
                  EndIf
                EndIf
              EndIf
            EndIf
        EndSelect
      Next n
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_setButtonPos(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected fTmpSingle1.f, fTmpSingle2.f, fTmpSingle3.f, fTmpSingle4.f
  Protected fNewCurrPos.f, fNewBasePos.f
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_SET_SLD_BUTTON_POSITION, nSldPtr)
    ProcedureReturn
  EndIf
  
  With gaSlider(nSldPtr)
    
    Select \nSliderType
      Case #SCS_ST_HLEVELCHANGERUN, #SCS_ST_HLEVELCHANGERUNPL
        SLD_drawCaption(nSldPtr)
        ProcedureReturn
        
      Case #SCS_ST_REMDEV_FADER_LEVEL
        ; debugMsg(sProcName, "\m_Value=" + \m_Value + ", \m_BVLevel=" + \m_BVLevel + " (" + convertBVLevelToDBLevel(\m_BVLevel) + ")")
        SLD_setCustomLinePosForDBValue(nSldPtr)
        SLD_drawButton(nSldPtr)
        ProcedureReturn
        
    EndSelect
    
    If (\m_Max = 0) Or (\bContinuous)
      fNewCurrPos = 0
      fNewBasePos = #SCS_SLD_NO_BASE ; was -1
    Else
      ;fNewCurrPos = (\m_Value - \m_Min) / ((\m_Max - \m_Min) / \sldNumDiv)
      ; modifed to use tmp single fields to try to avoid the occasional failure with "Error 16 Expression too complex" (VB6)
      fTmpSingle1 = \m_Value - \m_Min
      fTmpSingle2 = \m_Max - \m_Min
      fTmpSingle3 = \sldNumDiv
      fTmpSingle4 = fTmpSingle2 / fTmpSingle3
      fNewCurrPos = fTmpSingle1 / fTmpSingle4
      ; debugMsg(sProcName,"fNewCurrPos=" + fNewCurrPos + ", \m_Value=" + \m_Value + ", \m_Max=" + \m_Max + ", \m_Min=" + \m_Min)
      
      If \m_BaseValue <> #SCS_SLD_NO_BASE 
        fTmpSingle1 = \m_BaseValue - \m_Min
        ; other tmp fields have same values.Crnt
        fNewBasePos = fTmpSingle1 / fTmpSingle4
      Else
        fNewBasePos = #SCS_SLD_NO_BASE
      EndIf
    EndIf
    
    ; tried only drawing button if either of these had changed, but this then failed to display the left and right text
    ; for QF progress slider in the Editor, and probably would affect others as well. easiest solution was to
    ; call SLD_drawButton() unconditionally.
    \fCurrPos = fNewCurrPos
    \fBasePos = fNewBasePos
    ; debugMsg0(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
    SLD_drawButton(nSldPtr)
    
  EndWith
  
  ; debugMsg0(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_drawPointer(nSldPtr, nLeft, nTop, nRight, nBottom, btnColor1, btnColor2, nBorderColor)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure,nSldPtr))
  Protected nHalfWidth, nHalfHeight

  ;  2-----3
  ;   |   |
  ;   |   |
  ;  1\   /4
  ;    \ /
  ;     0
  
  Protected X0, Y0
  Protected X1, Y1
  Protected X2, Y2
  Protected X3, Y3
  Protected X4, Y4
  Protected nWidth, nHeight
  Protected nCenterX, nCenterY
  Protected n
  Protected ndB, nLevel, nVal
  Protected sdB.s
  Static nRadius
  Static ndBHeight
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
;   If gnThreadNo > #SCS_THREAD_MAIN
;     debugMsg(sProcName, #SCS_START)
;   EndIf
  
  If bStaticLoaded = #False
    nRadius = 6
    ndBHeight = TextHeight("Gg")
    bStaticLoaded = #True
  EndIf
  
  With gaSlider(nSldPtr)
    
;     Select \nButtonStyle
;       Case #SCS_BUTTON_POINTER, #SCS_BUTTON_HBOX, #SCS_BUTTON_VBOX
;         debugMsg(sProcName, "\nButtonStyle=" + \nButtonStyle + ", nLeft=" + nLeft + ", nTop=" + nTop + ", nRight=" + nRight + ", nBottom=" + nBottom)
;     EndSelect
        
    If \bHorizontal ; horizontal
      
      Select \nButtonStyle
        Case #SCS_BUTTON_POINTER
;           debugMsg(sProcName, "#SCS_BUTTON_POINTER")
          nHalfWidth = (nRight - nLeft) >> 1
          ; set pointer points, starting at bottom point, going clockwise
          X0 = nLeft + nHalfWidth                ; point
          Y0 = nBottom
          X1 = nLeft                             ; lower left
          Y1 = nBottom - nHalfWidth
          X2 = X1                                ; top left
          Y2 = nTop
          X3 = nLeft + nHalfWidth + nHalfWidth   ; top right
          Y3 = Y2
          X4 = X3                                ; lower right
          Y4 = Y1
          ; debugMsg(sProcName, "nRight=" + nRight + ", nLeft=" + nLeft + ", nHalfWidth=" + nHalfWidth + ", X0=" + X0 + ", X1=" + X1 + ", X2=" + X2 + ", X3=" + X3)
          
          ; note: add 1 to the Y value of the bottom of the side lines to prevent "FillArea" leaking out of the pointer and flooding the whole slider
          ; mod 12Nov2020 11.8.3.3af - adding 1 to the Y value doesn't seem to be necessary
          LineXY(X0, Y0, X1, Y1, nBorderColor)
          ; LineXY(X1, Y1+1, X2, Y2, nBorderColor)
          LineXY(X1, Y1, X2, Y2, nBorderColor)
          LineXY(X2, Y2, X3, Y3, nBorderColor)
          ; LineXY(X3, Y3, X4, Y4+1, nBorderColor)
          LineXY(X3, Y3, X4, Y4, nBorderColor)
          LineXY(X4, Y4, X0, Y0, nBorderColor)
          FillArea(X2+1, Y2+1, nBorderColor, btnColor1)
          
        Case #SCS_BUTTON_ROUNDED_BOX
          DrawingMode(#PB_2DDrawing_Default)
          nHalfWidth = (nRight - nLeft) >> 1
          nCenterX = nLeft + nHalfWidth
          ; debugMsg(sProcName, "Lighting: nRight=" + nRight + ", nLeft=" + nLeft + ", nCenterX=" + nCenterX)
          ; nCenterY = nTop + nHalfWidth
          nCenterY = \nGtrY1 + 1  ; + 1 because this corresponds to the white line of the gutter
          Circle(nCenterX, nCenterY, nHalfWidth, btnColor2)
          Circle(nCenterX, nCenterY, nHalfWidth-1, btnColor1)
          
        Case #SCS_BUTTON_SCROLLBAR_THUMB
          Box(nLeft,nTop,(nRight - nLeft + 1),(nBottom - nTop + 1), nBorderColor)
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(btnColor1)
          FrontColor(btnColor2)
          LinearGradient(nLeft,nTop,nLeft,nBottom)
          RoundBox(nLeft+1,nTop+1,(nRight - nLeft - 1),(nBottom - nTop - 1),2,2)
          
        Case #SCS_BUTTON_LIGHTING
          DrawingMode(#PB_2DDrawing_Default)
          nHalfWidth = (nRight - nLeft) >> 1
          nCenterX = nLeft + nHalfWidth
          ; debugMsg(sProcName, "Lighting: nRight=" + nRight + ", nLeft=" + nLeft + ", nCenterX=" + nCenterX)
          ; nCenterY = nTop + nHalfWidth
          nCenterY = \nGtrY1 + 1  ; + 1 because this corresponds to the white line of the gutter
          Circle(nCenterX, nCenterY, nHalfWidth, btnColor1)
          
        Case #SCS_BUTTON_HBOX
          DrawingMode(#PB_2DDrawing_Default)
          nWidth = nRight - nLeft + 1
          nHeight = nBottom - nTop + 1
          Box(nLeft-1,nTop,nWidth,nHeight,btnColor1)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(nLeft-1,nTop,nWidth,nHeight,#SCS_Dark_Grey)
          ; debugMsg(sProcName, "(HBOX) Box(" + nLeft + "," + nTop + "," + nWidth + "," + nHeight + ",nBorderColor)")
          
      EndSelect
      
    Else ; vertical
      
      Select \nButtonStyle
        Case #SCS_BUTTON_POINTER
          nHeight = nBottom - nTop
          nHalfHeight = nHeight >> 1
          X0 = nLeft + nHeight + nHalfHeight
          Y0 = nTop + nHalfHeight
          X1 = nLeft + nHeight
          Y1 = nTop
          X2 = nLeft
          Y2 = Y1
          X3 = X2
          Y3 = nTop + nHalfHeight + nHalfHeight
          X4 = X1
          Y4 = Y3
          LineXY(X0, Y0, X1, Y1, nBorderColor)
          LineXY(X1, Y1, X2, Y2, nBorderColor)
          LineXY(X2, Y2, X3, Y3, nBorderColor)
          LineXY(X3, Y3, X4, Y4, nBorderColor)
          LineXY(X4, Y4, X0, Y0, nBorderColor)
          FillArea(X0-2, Y0, nBorderColor, btnColor1)
          
        Case #SCS_BUTTON_ROUNDED_BOX
          DrawingMode(#PB_2DDrawing_Gradient)
          BackColor(btnColor1)
          FrontColor(btnColor2)
          nWidth = nRight - nLeft + 1
          nHeight = nBottom - nTop + 1
          LinearGradient(nLeft,nTop,nRight,nBottom)
          RoundBox(nLeft+1,nTop,nWidth,nHeight,nRadius,nRadius)
          
        Case #SCS_BUTTON_FADER_LIVE_INPUT, #SCS_BUTTON_FADER_OUTPUT, #SCS_BUTTON_FADER_MASTER, #SCS_BUTTON_FADER_DMX_MASTER, #SCS_BUTTON_FADER_DIMMER_CHAN ; Changed 11Jul2022 11.9.4
          DrawingMode(#PB_2DDrawing_Transparent)
          SLD_drawTickLines(nSldPtr)
          If IsImage(\nImageNo)
            LineXY(\nTrackX1,\nTrackY1,\nTrackX1,\nTrackY2,#SCS_Black)
            LineXY(\nTrackX1+1,\nTrackY1,\nTrackX1+1,\nTrackY2,#SCS_White)
            DrawImage(ImageID(\nImageNo), \nImageLeft, (nTop+1))  ; added 1 pixel to Y position 22Dec2017, mainly to correct the max and min positions
          EndIf
          
        Case #SCS_BUTTON_VBOX
          DrawingMode(#PB_2DDrawing_Default)
          nWidth = nRight - nLeft + 1
          nHeight = nBottom - nTop + 1
          Box(nLeft,nTop+1,nWidth,nHeight,btnColor1)
          DrawingMode(#PB_2DDrawing_Outlined)
          Box(nLeft,nTop+1,nWidth,nHeight,#SCS_Dark_Grey)
          ; debugMsg(sProcName, "(VBOX) Box(" + nLeft + "," + nTop + "," + nWidth + "," + nHeight + ",nBorderColor)")
          
      EndSelect
      
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_defineLevelMarkers(nSldPtr)
  Protected sProcName.s
  ; NB Many of the following variables are declared as floats, not integers, to provide more accurate results when calculating multiples of the respective variables
  Protected fSecACellLength.f ; actual distance between marks in section A, based on gutter length
  Protected fSecBCellLength.f ; actual distance between marks in section B, based on gutter length
  Protected fSecCCellLength.f ; actual distance between marks in section C, based on gutter length
  Protected fDBLevel.f, fDBInterval.f, fPos.f, n, nMarkCounter
  Protected nMarkSize
  Protected nMarkSizeM  ; medium
  Protected nMarkSizeS  ; small
  Protected fSecABasePos.f, fSecBBasePos.f
  
  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    sProcName = #PB_Compiler_Procedure + "[" + \sName + "]"
    
    fSecACellLength = (gaFaderInfo(0)\fFdrSecACellSize / 2 / gfFdrOverallSize) * (\nPhysicalRange) ; divide by 2 as gfFdrSecACellSize was calculated for 'major' cell sizes, not 'minor' cell sizes
    fSecBCellLength = (gaFaderInfo(0)\fFdrSecBCellSize / 2 / gfFdrOverallSize) * (\nPhysicalRange) ; divide by 2 as gfFdrSecBCellSize was calculated for 'major' cell sizes, not 'minor' cell sizes
    fSecCCellLength = (gaFaderInfo(0)\fFdrSecCCellSize / gfFdrOverallSize) * (\nPhysicalRange)     ; no 'divide by 2' here as there were never any 'minor' cells in section C
    
    ; clear any current settings (eg after changing max db level and redrawing sliders) so that DrawTickLines() doesn't redraw some obsolete marks
    For n = 0 To \sldNumDiv
      \nFaderMarks[n] = 0
      \nFaderMarkSize[n] = 0
    Next n
    
    n = \sldNumDiv
    
    If \bHorizontal
      nMarkSize = Int((\nCanvasHeight / 10) + (\nCanvasHeight / 7.667))
      nMarkSizeM = nMarkSize
      nMarkSizeS = nMarkSize >> 1
    Else
      If \bFader
        nMarkSizeS = \nImageWidth + 2
        nMarkSizeM = \nImageWidth + 10
      Else
        nMarkSize = Int((\nCanvasWidth / 10) + (\nCanvasWidth / 7.667))
        nMarkSizeM = nMarkSize
        nMarkSizeS = nMarkSize >> 1
      EndIf
    EndIf
    
    ; Section A
    fPos = \nPhysicalRange ; start section A marker positions from the max end of the fader
    fDBInterval = gaFaderInfo(0)\fFdrSecADBInterval / 2 ; divide by 2 as gfFdrSecADBInterval was calculated for 'major' cell sizes, not 'minor' cell sizes
    fDBLevel = gaFaderInfo(0)\fFdrDBHeadroom ; dB level for the max position of section A
    ; debugMsg(sProcName, "A: \nPhysicalRange=" + \nPhysicalRange + ", fPos=" + fPos + ", fDBLevel=" + StrF(fDBLevel) + ", fDBInterval=" + StrF(fDBInterval))
    While (fDBLevel >= gaFaderInfo(0)\fFdrSecADBBase) And (n >= 0)
      \nFaderMarks[n] = fPos
      nMarkCounter + 1
      If nMarkCounter & 1
        \nFaderMarkSize[n] = nMarkSizeM ; 'major mark' size
      Else
        \nFaderMarkSize[n] = nMarkSizeS ; 'minor mark' size
      EndIf
      CompilerIf #c_slider_mark_section_colors
        \nMarkColors[n] = #SCS_Red ; Useful for checking 'tick' positions
      CompilerEndIf
      ; debugMsg(sProcName, "A: " + fDBLevel + " at fPos=" + fPos + ", n=" + n + ", \nFaderMarkSize(" + n + ")=" + \nFaderMarkSize[n])
      fSecABasePos = fPos ; will eventually be the position of the lowest mark in section A
      fPos - fSecACellLength
      If fPos < 0
        fPos = 0
      EndIf
      fDBLevel - fDBInterval
      n - 1
    Wend
    
    ; Section B
    fPos = fSecABasePos - fSecBCellLength ; start section B marker positions from the start of section A
    fDBInterval = gaFaderInfo(0)\fFdrSecBDBInterval / 2 ; divide by 2 as gfFdrSecBDBInterval was calculated for 'major' cell sizes, not 'minor' cell sizes
    fDBLevel = gaFaderInfo(0)\fFdrSecADBBase - fDBInterval ; dB level for the max position of section B
    ; debugMsg(sProcName, "B: fSecABasePos=" + fSecABasePos + ", fSecBCellLength=" + fSecBCellLength + ", fPos=" + fPos + ", fDBLevel=" + StrF(fDBLevel) + ", fDBInterval=" + StrF(fDBInterval))
    While (fDBLevel >= gaFaderInfo(0)\fFdrSecBDBBase) And (n >= 0)
      \nFaderMarks[n] = fPos
      nMarkCounter + 1
      If nMarkCounter & 1
        \nFaderMarkSize[n] = nMarkSizeM ; 'major mark' size
      Else
        \nFaderMarkSize[n] = nMarkSizeS ; 'minor mark' size
      EndIf
      CompilerIf #c_slider_mark_section_colors
        \nMarkColors[n] = #SCS_Yellow ; Useful for checking 'tick' positions
      CompilerEndIf
      ; debugMsg(sProcName, "B: " + fDBLevel + " at fPos=" + fPos + ", n=" + n + ", \nFaderMarkSize(" + n + ")=" + \nFaderMarkSize[n])
      fSecBBasePos = fPos ; will eventually be the position of the lowest mark in section B
      fPos - fSecBCellLength
      If fPos < 0
        fPos = 0
      EndIf
      fDBLevel - fDBInterval
      n - 1
    Wend
    
    ; Section C
    fPos = fSecBBasePos - fSecCCellLength ; start section B marker positions from the start of section B
    fDBInterval = gaFaderInfo(0)\fFdrSecCDBInterval ; no 'divide by 2' here as there were never any 'minor' cells in section C
    fDBLevel = gaFaderInfo(0)\fFdrSecBDBBase - fDBInterval ; dB level for the max position of section C
    ; debugMsg(sProcName, "C: fSecBBasePos=" + fSecBBasePos + ", fSecCCellLength=" + fSecCCellLength + ", fPos=" + fPos + ", fDBLevel=" + StrF(fDBLevel) + ", fDBInterval=" + StrF(fDBInterval))
    While (fDBLevel > gaFaderInfo(0)\fFdrSecCDBBase) And (n >= 0)
      \nFaderMarks[n] = fPos
      \nFaderMarkSize[n] = nMarkSizeS ; All marks in Section C are 'minor'
      CompilerIf #c_slider_mark_section_colors
        \nMarkColors[n] = #SCS_Green ; Useful for checking 'tick' positions
      CompilerEndIf
      ; debugMsg(sProcName, "C: " + fDBLevel + " at fPos=" + fPos + ", n=" + n + ", \nFaderMarkSize(" + n + ")=" + \nFaderMarkSize[n])
      fPos - fSecCCellLength
      If fPos < 0
        fPos = 0
      EndIf
      fDBLevel - fDBInterval
      n - 1
    Wend
    
    ; Lowest level
    If n >= 0 
      \nFaderMarks[n] = 0
      \nFaderMarkSize[n] = nMarkSizeM
      CompilerIf #c_slider_mark_section_colors
        \nMarkColors[n] = #SCS_Green ; Useful for checking 'tick' positions
      CompilerEndIf
      ; debugMsg(sProcName, "C final: " + fDBLevel + " at fPos=0, n=" + n + ", \nFaderMarkSize(" + n + ")=" + \nFaderMarkSize[n])
      n - 1
    EndIf
    
    Select \nSliderType
      Case #SCS_ST_HLEVEL, #SCS_ST_HLEVELNODB, #SCS_ST_HLEVELRUN
        ; no action
      Default
        ; calculate the gutter distance from the edge
        If \bFader = #False
          \nGtrDistanceLeft = (\nCanvasWidth - \nPhysicalRange) >> 1
          \nGtrDistanceRight = \nGtrDistanceLeft
        EndIf
        \fMarkWidth = \nPhysicalRange / \sldNumDiv
        ; debugMsg(sProcName, "\nCanvasWidth=" + \nCanvasWidth + ", \nPhysicalRange=" + \nPhysicalRange + ", \sldNumDiv=" + \sldNumDiv)
    EndSelect
    
    ; debugMsg(sProcName, "\nGtrDistanceLeft=" + \nGtrDistanceLeft + ", \nGtrDistanceRight=" + \nGtrDistanceRight + ", \fMarkWidth=" + \fMarkWidth)
    
  EndWith
  
EndProcedure

Procedure SLD_setFaderVariables(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nBorder1, nBorder2
  Protected nMarkerSize
  
  CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    nMarkerSize = 22
    \nMarkerX1 = (\nCanvasWidth - nMarkerSize) >> 1
    \nMarkerX2 = \nMarkerX1 + nMarkerSize - 1
    nBorder1 = \nImageCentreOffset + (\nImageCentreOffset / 5)
    nBorder2 = nBorder1
    \nTrackExtra = \nImageHeight / 10
    \nTrackY1 = nBorder1 - \nTrackExtra + (\nLblTopY + \nLblTopHeight)
    \nTrackY2 = \nCanvasHeight - nBorder2 + \nTrackExtra
    \nTrackHeight = \nTrackY2 - \nTrackY1 + 1
    \nTrackX1 = \nMarkerX1 + ((\nMarkerX2 - \nMarkerX1) >> 1)
    \nImageLeft = \nTrackX1 - (\nImageWidth >> 1) + 1
    \nMaxPos = \nTrackY1 + \nTrackExtra
    \nMinPos = \nTrackY2 - \nTrackExtra
    \nPhysicalRange = \nMinPos - \nMaxPos + 1
    \nLogicalRange = \m_Max - \m_Min + 1 ; Added "+ 1" 16Oct2022 11.9.6
    debugMsg(sProcName, "\nPhysicalRange=" + \nPhysicalRange + ", \nLogicalRange=" + \nLogicalRange)
    
    \nGtrDistanceTop = \nTrackY1
    \nGtrDistanceBottom = \nCanvasHeight - \nTrackY2
    \btnHalfHght = \nImageHeight >> 1
    \btnHalfWdth = \nImageWidth >> 1
    \nLblTopWidth = \nCanvasWidth
    
    SLD_calcUnitWidth(nSldPtr)
    SLD_defineLevelMarkers(nSldPtr)
    
  EndWith
  
EndProcedure

Procedure SLD_initFaderConstants()
  ; PROCNAMEC()
  Protected nFactorA, nFactorB, nFactorC, nLengthA, nLengthB, nLengthC
  Protected nSliderMax = #SCS_MAXVOLUME_SLD
  
  ; set 'constants' for level sliders
  
  If gbInitFaderConstantsDone
    ProcedureReturn
  EndIf

  ; debugMsg(sProcName, "grProd\nMaxDBLevel=" + grProd\nMaxDBLevel)
  
  gfFdrOverallSize = 125                                 ; used for working out proportions of fader to sections A, B and C
  With gaFaderInfo(0)
    Select grProd\nMaxDBLevel
      Case 12 ; ie +12dB
        \fFdrDBHeadroom = 12                                   ; headroom in dB
        
        ; section A
        \fFdrSecADBBase = -12                                  ; lowest dB level for section A
        \fFdrSecADBInterval = 6                                ; dB interval between major marks in section A
        \fFdrSecACellSize = 10                                 ; relative distance between major marks in section A, based on gfFdrOverallSize
        
        ; section B
        If grProd\nMinDBLevel = -75
          \fFdrSecBDBBase = -28                                ; lowest dB level for section B
          \fFdrSecBDBInterval = 8                              ; dB interval between major marks in section B
        Else                                                   ; -120 or -160
          \fFdrSecBDBBase = -40                                ; lowest dB level for section B
          \fFdrSecBDBInterval = 10                             ; dB interval between major marks in section B
        EndIf
        \fFdrSecBCellSize = 18                                 ; relative distance between major marks in section B, based on gfFdrOverallSize
        
        ; section C
        \fFdrSecCDBBase = grLevels\nMinDBLevel                 ; lowest dB level for section C (-160 as at 30Jun2020 11.8.3.2aj)
        If grProd\nMinDBLevel = -75
          \fFdrSecCDBInterval = 10                             ; dB interval between major marks in section C
        Else                                                   ; -120 or -160
          \fFdrSecCDBInterval = 20                             ; dB interval between major marks in section C
        EndIf
        \fFdrSecCBaseValue = 0                                 ; slider value for lowest level in section C (lowest position in slider)
        
      Default ; only other valid value for \nMaxDBLevel currently is 0, ie +0dB
        \fFdrDBHeadroom = 0                                    ; headroom in dB
        
        ; section A
        \fFdrSecADBBase = -15                                  ; lowest dB level for section A
        \fFdrSecADBInterval = 5                                ; dB interval between major marks in section A
        \fFdrSecACellSize = 17                                 ; relative distance between major marks in section A, based on gfFdrOverallSize
        
        ; section B
        If grProd\nMinDBLevel = -75
          \fFdrSecBDBBase = -35                                ; lowest dB level for section B
        Else                                                   ; -120 or -160
          \fFdrSecBDBBase = -40                                ; lowest dB level for section B
        EndIf
        \fFdrSecBDBInterval = 10                               ; dB interval between major marks in section B
        \fFdrSecBCellSize = 18                                 ; relative distance between major marks in section B, based on gfFdrOverallSize
        
        ; section C
        \fFdrSecCDBBase = grLevels\nMinDBLevel                 ; lowest dB level for section C (-160 as at 30Jun2020 11.8.3.2aj)
        If grProd\nMinDBLevel = -75
          \fFdrSecCDBInterval = 10                             ; dB interval between major marks in section C
        Else                                                   ; -120 or -160
          \fFdrSecCDBInterval = 30                             ; dB interval between major marks in section C
        EndIf
        \fFdrSecCBaseValue = 0                                 ; slider value for lowest level in section C (lowest position in slider)
        
    EndSelect
    
    ; calculate derived factors
    \fFdrSecADBRange = \fFdrDBHeadroom - \fFdrSecADBBase    ; dB range of section A
    nLengthA = (\fFdrSecADBRange / \fFdrSecADBInterval) * \fFdrSecACellSize
    nFactorA = nLengthA / gfFdrOverallSize * nSliderMax
    \fFdrSecABaseValue = nSliderMax - nFactorA
    \fFdrSecA1DBValue = nFactorA / \fFdrSecADBRange          ; value of 1dB in section A, relative to sliders; max value, which is 10000
    ; debugMsg0(sProcName, "\fFdrSecADBRange=" + StrF(\fFdrSecADBRange,4) + ", nLengthA=" + nLengthA + ", nFactorA=" + StrF(nFactorA,4) + ", \fFdrSecABaseValue=" + StrF(\fFdrSecABaseValue,4) + ", \fFdrSecA1DBValue=" + StrF(\fFdrSecA1DBValue,4))
    
    \fFdrSecBDBRange = \fFdrSecADBBase - \fFdrSecBDBBase    ; dB range of section B
    nLengthB = (\fFdrSecBDBRange / \fFdrSecBDBInterval) * \fFdrSecBCellSize
    nFactorB = nLengthB / gfFdrOverallSize * nSliderMax
    \fFdrSecBBaseValue = \fFdrSecABaseValue - nFactorB
    \fFdrSecB1DBValue = nFactorB / \fFdrSecBDBRange          ; value of 1dB in section B, relative to sliders; max value, which is 10000
    ; debugMsg(sProcName, "\fFdrSecBDBRange=" + StrF(\fFdrSecBDBRange,4) + ", nLengthB=" + nLengthB + ", nFactorB=" + StrF(nFactorB,4) + ", \fFdrSecBBaseValue=" + StrF(\fFdrSecBBaseValue,4) + ", \fFdrSecB1DBValue=" + StrF(\fFdrSecB1DBValue,4))
    
    \fFdrSecCDBRange = \fFdrSecBDBBase - \fFdrSecCDBBase    ; dB range of section C
    nLengthC = 125 - nLengthA - nLengthB
    \fFdrSecCCellSize = nLengthC / (\fFdrSecCDBRange / \fFdrSecCDBInterval)
    nFactorC = nLengthC / gfFdrOverallSize * nSliderMax
    \fFdrSecC1DBValue = nFactorC / \fFdrSecCDBRange          ; value of 1dB in section C, relative to sliders; max value, which is 10000
    ; debugMsg(sProcName, "\fFdrSecCDBRange=" + StrF(\fFdrSecCDBRange,4) + ", nLengthC=" + nLengthC + ", nFactorC=" + StrF(nFactorC,4) + ", \fFdrSecCBaseValue=" + StrF(\fFdrSecCBaseValue,4) + ", \fFdrSecC1DBValue=" + StrF(\fFdrSecC1DBValue,4))
    
    ; debugMsg(sProcName, "\fFdrSecCDBBase=" + traceLevel(\fFdrSecCDBBase) + ", \fFdrSecCDBInterval=" + traceLevel(\fFdrSecCDBInterval) + ", \fFdrSecCCellSize=" + StrF(\fFdrSecCCellSize,4))
  EndWith
  gbInitFaderConstantsDone = #True
  
EndProcedure

Procedure SLD_setRemDevFaderConstants(nFaderDataIndex)
  PROCNAMEC()
  Protected nFactorA, nFactorB, nFactorC, nLengthA, nLengthB, nLengthC
  Protected nSliderMax = #SCS_MAXVOLUME_SLD
  Protected rFaderData.tyCSRD_FaderData
  
  ; set 'constants' for currently-selected remote device level slider
  
  rFaderData = grCSRD\aFaderData(nFaderDataIndex)
  
  With gaFaderInfo(1)
    If rFaderData\nCSRD_MaxFaderValue >= 0
      \fFdrDBHeadroom = rFaderData\aFdrValue(0)\fCSRD_FdrLevel_dB
      ; section A
      \fFdrSecADBBase = -10                 ; lowest dB level for section A
      \fFdrSecADBInterval = 5               ; dB interval between major marks in section A
      \fFdrSecACellSize = 10                ; relative distance between major marks in section A, based on gfFdrOverallSize
      ; section B
      \fFdrSecBDBBase = -10                 ; lowest dB level for section B
      \fFdrSecBDBInterval = 10              ; dB interval between major marks in section B
      \fFdrSecBCellSize = 18                ; relative distance between major marks in section B, based on gfFdrOverallSize
      ; section C
      \fFdrSecCDBBase = -80                 ; lowest dB level for section C
      \fFdrSecCDBInterval = 10              ; dB interval between major marks in section C
      \fFdrSecCBaseValue = 0                ; slider value for lowest level in section C (lowest position in slider)
    EndIf    
    ; calculate derived factors
    \fFdrSecADBRange = \fFdrDBHeadroom - \fFdrSecADBBase    ; dB range of section A
    nLengthA = (\fFdrSecADBRange / \fFdrSecADBInterval) * \fFdrSecACellSize
    nFactorA = nLengthA / gfFdrOverallSize * nSliderMax
    \fFdrSecABaseValue = nSliderMax - nFactorA
    \fFdrSecA1DBValue = nFactorA / \fFdrSecADBRange          ; value of 1dB in section A, relative to sliders; max value, which is 10000
    ; debugMsg(sProcName, "\fFdrSecADBRange=" + StrF(\fFdrSecADBRange,4) + ", nLengthA=" + nLengthA + ", nFactorA=" + StrF(nFactorA,4) + ", \fFdrSecABaseValue=" + StrF(\fFdrSecABaseValue,4) + ", \fFdrSecA1DBValue=" + StrF(\fFdrSecA1DBValue,4))
    
    \fFdrSecBDBRange = \fFdrSecADBBase - \fFdrSecBDBBase    ; dB range of section B
    nLengthB = (\fFdrSecBDBRange / \fFdrSecBDBInterval) * \fFdrSecBCellSize
    nFactorB = nLengthB / gfFdrOverallSize * nSliderMax
    \fFdrSecBBaseValue = \fFdrSecABaseValue - nFactorB
    \fFdrSecB1DBValue = nFactorB / \fFdrSecBDBRange          ; value of 1dB in section B, relative to sliders; max value, which is 10000
    ; debugMsg(sProcName, "\fFdrSecBDBRange=" + StrF(\fFdrSecBDBRange,4) + ", nLengthB=" + nLengthB + ", nFactorB=" + StrF(nFactorB,4) + ", \fFdrSecBBaseValue=" + StrF(\fFdrSecBBaseValue,4) + ", \fFdrSecB1DBValue=" + StrF(\fFdrSecB1DBValue,4))
    
    \fFdrSecCDBRange = \fFdrSecBDBBase - \fFdrSecCDBBase    ; dB range of section C
    nLengthC = 125 - nLengthA - nLengthB
    \fFdrSecCCellSize = nLengthC / (\fFdrSecCDBRange / \fFdrSecCDBInterval)
    nFactorC = nLengthC / gfFdrOverallSize * nSliderMax
    \fFdrSecC1DBValue = nFactorC / \fFdrSecCDBRange          ; value of 1dB in section C, relative to sliders; max value, which is 10000
    ; debugMsg(sProcName, "\fFdrSecCDBRange=" + StrF(\fFdrSecCDBRange,4) + ", nLengthC=" + nLengthC + ", nFactorC=" + StrF(nFactorC,4) + ", \fFdrSecCBaseValue=" + StrF(\fFdrSecCBaseValue,4) + ", \fFdrSecC1DBValue=" + StrF(\fFdrSecC1DBValue,4))
    
    ; debugMsg(sProcName, "\fFdrSecCDBBase=" + traceLevel(\fFdrSecCDBBase) + ", \fFdrSecCDBInterval=" + traceLevel(\fFdrSecCDBInterval) + ", \fFdrSecCCellSize=" + StrF(\fFdrSecCCellSize,4))
  EndWith
  gbInitFaderConstantsDone = #True
  
EndProcedure

Procedure SLD_setButtonWidthEtc(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nTextHeight
  
  With gaSlider(nSldPtr)
    If \bHorizontal ; horizontal
      \nLblLeftX = 0
      \nLblRightX = \nCanvasWidth - \nLblRightWidth
      nTextHeight = GetTextHeight("8", #SCS_FONT_WMN_NORMAL)
      If nTextHeight < \nCanvasHeight
        \nLblLeftY = (\nCanvasHeight - nTextHeight) >> 1
      Else
        \nLblLeftY = 0
      EndIf
      \nLblRightY = \nLblLeftY
      
      Select \nSliderType
        Case #SCS_ST_HSCROLLBAR
          \btnHght = \nCanvasHeight - 2
          \btnHalfHght = \btnHght >> 1
        Default
          \btnHght = (\nCanvasHeight * 3) >> 2
          \btnHalfHght = \btnHght >> 1
      EndSelect
      If \bAudioGraph
        \btnWdth = 1
        \btnHalfWdth = 0
      Else
        \btnWdth = 10    ;Button width (10 pixels)
        \btnHalfWdth = \btnWdth >> 1
      EndIf
      ; debugMsg(sProcName, "\btnWdth=" + \btnWdth + ", \btnHalfWdth=" + \btnHalfWdth)
      
      \nGtrDistanceLeft = \btnHalfWdth + \nLblLeftWidth
      \nGtrDistanceRight = \btnHalfWdth + \nLblRightWidth
      \nGtrLength = (\nCanvasWidth - \nGtrDistanceLeft - \nGtrDistanceRight)
      ; Added 17Dec2021 11.8.6cx
      If \nGtrLength & 1 = 0
        ; currently even, so make odd so that a centre point can be calculated
        \nGtrLength - 1
      EndIf
      ; End added 17Dec2021 11.8.6cx
      ; debugMsg(sProcName, "\nCanvasWidth=" + \nCanvasWidth + ", \nGtrDistanceLeft=" + \nGtrDistanceLeft + ", \nGtrDistanceRight=" + \nGtrDistanceRight + ", \nGtrLength=" + \nGtrLength)
      If \bAudioGraph = #False
        \nGtrLength - 2
      EndIf
      \nPhysicalRange = \nGtrLength
      ; debugMsg(sProcName, "\nPhysicalRange=" + \nPhysicalRange)
      \nGtrX1 = \nGtrDistanceLeft
      \nGtrX2 = \nGtrDistanceLeft + \nGtrLength
      \nPointerMinX = \nLblLeftWidth
      \nPointerMaxX = \nCanvasWidth - \nLblRightWidth
      \nGtrY1 = Round(\nCanvasHeight * 0.4, #PB_Round_Down)
      \nGtrY2 = \nGtrY1
      
    Else  ; vertical
      \nLblTopY = 0
      \nLblBottomY = \nCanvasHeight - \nLblBottomHeight
      
      \btnWdth = (\nCanvasWidth * 3) >> 2
      \btnHalfWdth = \btnWdth >> 1
      ; debugMsg(sProcName, "\btnWdth=" + \btnWdth + ", \btnHalfWdth=" + \btnHalfWdth)
      \btnHght = 10    ;Button height (10 pixels)
      \btnHalfHght = \btnHght >> 1
      
      \nGtrDistanceTop = \btnHalfHght + \nLblTopHeight
      \nGtrDistanceBottom = \btnHalfHght + \nLblBottomHeight
      \nGtrLength = (\nCanvasHeight - \nGtrDistanceTop - \nGtrDistanceBottom) - 2 ; starting value - may be adjusted below
      ; Added 17Dec2021 11.8.6cx
      If \nGtrLength & 1 = 0
        ; currently even, so make odd so that a centre point can be calculated
        \nGtrLength - 1
      EndIf
      ; End added 17Dec2021 11.8.6cx
      \nPhysicalRange = \nGtrLength
      \nGtrY1 = \nGtrDistanceTop
      \nGtrY2 = \nGtrDistanceTop + \nGtrLength
      \nPointerMinY = \nLblTopHeight
      \nPointerMaxY = \nCanvasHeight - \nLblBottomHeight
      \nGtrX1 = Round(\nCanvasWidth * 0.4, #PB_Round_Down)
      \nGtrX2 = \nGtrX1
      
    EndIf
    
    ; debugMsg(sProcName, "\nGtrLength=" + \nGtrLength + ", \nCanvasWidth=" + \nCanvasWidth + ", \btnWdth=" + \btnWdth + ", \nGtrDistanceLeft=" + \nGtrDistanceLeft + ", \nGtrDistanceRight=" + \nGtrDistanceRight)
    
    SLD_calcUnitWidth(nSldPtr)
    ; debugMsg(sProcName, "\fUnitSize=" + StrF(\fUnitSize,4))
    
  EndWith
  
EndProcedure

Procedure SLD_Resize(nSldPtr, bResizeCanvas=#True, fReqdYFactor.f=0, fReqdXFactor.f=0, bForceHeightOddPixels=#False, bChangeLeft=#True, bChangeTop=#True, bChangeWidth=#True, bChangeHeight=#True)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected bVisible
  Protected nWindowNo, nToolBarHeight
  Protected nTextHeight
  Protected nSldHeight
  
  ; debugMsg(sProcName, #SCS_START + ", nSldPtr=" + nSldPtr + ", bResizeCanvas=" + strB(bResizeCanvas) + ", fReqdYFactor=" + StrF(fReqdYFactor,4) + ", fReqdXFactor=" + StrF(fReqdXFactor,4))
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  ; CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider()")
  With gaSlider(nSldPtr)
    bVisible = getVisible(\cvsSlider)
    setVisible(\cvsSlider, #False)
    
    ; debugMsg(sProcName, "bResizeCanvas=" + strB(bResizeCanvas) + ", \bUseMainScaling=" + strB(\bUseMainScaling))
    If bResizeCanvas And (\bUseMainScaling Or \bUseCuePanelScaling)
      nWindowNo = gaGadgetProps(\cvsSlider-#SCS_GADGET_BASE_NO)\nGWindowNo
      If gaGadgetProps(\cvsSlider-#SCS_GADGET_BASE_NO)\nContainerLevel > 0
        nToolBarHeight = 0
      Else
        nToolBarHeight = gaWindowProps(nWindowNo)\nToolBarHeight
      EndIf
      resizeControl(\cvsSlider, nToolBarHeight, fReqdYFactor, -1, #False, fReqdXFactor, bChangeLeft, bChangeTop, bChangeWidth, bChangeHeight)
      If bForceHeightOddPixels
        nSldHeight = GadgetHeight(\cvsSlider)
        nSldHeight >> 1
        nSldHeight << 1
        nSldHeight + 1
        ResizeGadget(\cvsSlider, #PB_Ignore, #PB_Ignore, #PB_Ignore, nSldHeight)
        CompilerIf #cTraceGadgets
          debugMsg(sProcName, "ResizeGadget(" + getGadgetName(gaSlider(nSldPtr)\cvsSlider) + ", #PB_Ignore, #PB_Ignore, #PB_Ignore, " + nSldHeight + ")")
        CompilerEndIf
      EndIf
    EndIf
    
    If \bUseCuePanelScaling
      \fontLabels = #SCS_FONT_CUE_NORMAL
      \fontInfinity = #SCS_FONT_CUE_SYMBOL9
    ElseIf \bUseMainScaling
      \fontLabels = #SCS_FONT_WMN_NORMAL9
      \fontInfinity = #SCS_FONT_WMN_SYMBOL9
    Else
      \fontLabels = #SCS_FONT_GEN_NORMAL9
      \fontInfinity = #SCS_FONT_GEN_SYMBOL9
    EndIf
    
    If \bUseInfinityFont
      \nLblFontId = FontID(\fontInfinity)
    Else
      \nLblFontId = FontID(\fontLabels)
    EndIf
    ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\fontLabels=" + \fontLabels + ", \nLblFontId=" + \nLblFontId + ", \bUseMainScaling=" + strB(\bUseMainScaling) + ", \bUseCuePanelScaling=" + strB(\bUseCuePanelScaling))
    
    \nLblLeftWidth = 0
    \nLblRightWidth = 0
    \nLblTopHeight = 0
    \nLblBottomHeight = 0
    
    gnLabelSlider = 1801
    If StartDrawing(WindowOutput(#WMN))
      gnLabelSlider = 1802
      scsDrawingFont(\fontLabels) ; always use \fontLabels for setting label widths - \fontInfinity is only used for actually drawing the infinity symbol
      Select \nSliderType
        Case #SCS_ST_PROGRESS
          \nLblLeftWidth = TextWidth("_8:88.88_")
          \nLblRightWidth = \nLblLeftWidth
          
        Case #SCS_ST_PAN
          \nLblLeftWidth = TextWidth("_R_")
          \nLblRightWidth = \nLblLeftWidth
          
        Case #SCS_ST_HLEVELRUN
          \nLblRightWidth = TextWidth("_-INF_")
          
        Case #SCS_ST_HPERCENT, #SCS_ST_HLIGHTING_PERCENT
          \nLblRightWidth = TextWidth("_100%_")
          
        Case #SCS_ST_POSITION
          \nLblLeftWidth = 0
          \nLblRightWidth = TextWidth("_8:88.88_")
          
      EndSelect
      nTextHeight = TextHeight("Wg")
      If \bFader
        \nLblTopHeight = nTextHeight
      EndIf
      StopDrawing()
    EndIf
    gnLabelSlider = 1804
    
    \nCanvasX = GadgetX(\cvsSlider)
    \nCanvasY = GadgetY(\cvsSlider)
    \nCanvasWidth = GadgetWidth(\cvsSlider)
    ; debugMsg(sProcName, "\nCanvasWidth=" + \nCanvasWidth)
    \nCanvasHeight = GadgetHeight(\cvsSlider)
    \nCanvasHalfHeight = \nCanvasHeight >> 1
    \nCanvasHalfWidth = \nCanvasWidth >> 1
    
    ; added 25Mar2019 11.8.0.2ck following issue reported by Nigel (email from Ian White) 'SCS 11.8.0.1 (x64) Crash on Window "UnMaximise"'
    If (\nLblLeftWidth + \nLblRightWidth) >= \nCanvasWidth
      ; debugMsg(sProcName, "\nLblLeftWidth=" + \nLblLeftWidth + ", \nLblRightWidth=" + \nLblRightWidth + ", \nCanvasWidth=" + \nCanvasWidth + ", so setting \nLblRightWidth=0")
      \nLblRightWidth = 0
      If (\nLblLeftWidth + \nLblRightWidth) >= \nCanvasWidth
        ; debugMsg(sProcName, "\nLblLeftWidth=" + \nLblLeftWidth + ", \nLblRightWidth=" + \nLblRightWidth + ", \nCanvasWidth=" + \nCanvasWidth + ", so setting \nLblLeftWidth=0")
        \nLblLeftWidth = 0
      EndIf
    EndIf
    ; end added 25Mar2019 11.8.0.2ck
    
    ResizeGadget(\cvsSlider, #PB_Ignore, #PB_Ignore, \nCanvasWidth, \nCanvasHeight)
    CompilerIf #cTraceGadgets
      debugMsg(sProcName, "ResizeGadget(" + getGadgetName(gaSlider(nSldPtr)\cvsSlider) + ", #PB_Ignore, #PB_Ignore, " + \nCanvasWidth + ", " + \nCanvasHeight + ")")
    CompilerEndIf
    
    ; debugMsg(sProcName, "calling SLD_setButtonWidthEtc(" + nSldPtr + ")")
    SLD_setButtonWidthEtc(nSldPtr)
    
    If \bLevelSlider
      ; debugMsg(sProcName, "calling SLD_defineLevelMarkers")
      SLD_defineLevelMarkers(nSldPtr)
    Else
      \fMarkWidth = \nPhysicalRange / \sldNumDiv
    EndIf
    
    If \bInitialized
      SLD_setButtonPos(nSldPtr)
    EndIf
    
    ; debugMsg(sProcName, "calling setVisible(" + \cvsSlider + ", " + strB(bVisible) + ")")
    setVisible(\cvsSlider, bVisible)
    gnLabelSlider = 1809
    
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_ResizeGadget(sProcName.s, nSldPtr, nLeft, nTop, nWidth, nHeight)
  gnLabelSlider = 1901
  ResizeGadget(gaSlider(nSldPtr)\cvsSlider, nLeft, nTop, nWidth, nHeight)
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, "ResizeGadget(" + getGadgetName(gaSlider(nSldPtr)\cvsSlider) + ", " + nLeft + ", " + nTop + ", " + nWidth + ", " + nHeight + ")")
  CompilerEndIf
  gnLabelSlider = 1909
  ; Note: procedures that call SLD_ResizeGadget() should follow this by a call to SLD_Resize(), probably with bResizeCanvas=#False (since the above ResizeGadget() has already resized the canvas)
EndProcedure

Procedure SLD_getWidth(nSldPtr)
  If IsGadget(gaSlider(nSldPtr)\cvsSlider)
    ProcedureReturn GadgetWidth(gaSlider(nSldPtr)\cvsSlider)
  Else
    ProcedureReturn -1
  EndIf
EndProcedure

Procedure SLD_setVisible(nSldPtr, bVisible)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; debugMsg(sProcName, "bVisible=" + strB(bVisible))
  setVisible(gaSlider(nSldPtr)\cvsSlider, bVisible)
EndProcedure

Procedure SLD_getVisible(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ProcedureReturn getVisible(gaSlider(nSldPtr)\cvsSlider)
EndProcedure

Procedure SLD_setEnabled(nSldPtr, bEnabled)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; debugMsg(sProcName, #SCS_START + ", bEnabled=" + strB(bEnabled))
  With gaSlider(nSldPtr)
    If \m_Enabled <> bEnabled
      \m_Enabled = bEnabled
      If \bFader And \bLevelSlider
        If \m_Enabled = #False
          If \sTopText = #SCS_INF_DBLEVEL
            \sTopText = "X" ; to indicate a disabled fader, as may be required for unused 'playing' faders in the Faders window for controller (NK2 Preset C)
          EndIf
        EndIf
      EndIf
      ; debugMsg0(sProcName, "gaSlider(" + nSldPtr + ")\m_Enabled=" + strB(\m_Enabled) + ", \sTopText=" + \sTopText)
      ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
      SLD_drawButton(nSldPtr)
    EndIf
  EndWith
EndProcedure

Procedure SLD_getEnabled(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ProcedureReturn gaSlider(nSldPtr)\m_Enabled
EndProcedure

Procedure SLD_setBackColor(nSldPtr, nBackColor)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "nBackColor=" + debugColorCode(nBackColor))
    If \m_BackColor <> nBackColor
      \m_BackColor = nBackColor
      ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
      SLD_drawButton(nSldPtr)
    EndIf
  EndWith
EndProcedure

Procedure SLD_getBackColor(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ProcedureReturn gaSlider(nSldPtr)\m_BackColor
EndProcedure

Procedure SLD_setGtrAreaBackColor(nSldPtr, nBackColor)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  With gaSlider(nSldPtr)
    ; debugMsg(sProcName, "nBackColor=" + debugColorCode(nBackColor))
    If \m_GtrAreaBackColor <> nBackColor
      \m_GtrAreaBackColor = nBackColor
      If nBackColor = #SCS_SLD_BACKCOLOR
        \nTickColor = #SCS_Yellow
      Else
        \nTickColor = getContrastColor(nBackColor)
      EndIf
      ; debugMsg(sProcName, "calling SLD_drawButton(" + nSldPtr + ")")
      SLD_drawButton(nSldPtr)
    EndIf
  EndWith
EndProcedure

Procedure SLD_setControlKeyAction(nSldPtr, nControlKeyAction)
  gaSlider(nSldPtr)\nControlKeyAction = nControlKeyAction
EndProcedure

Procedure SLD_gadgetX(nSldPtr)
  ProcedureReturn GadgetX(gaSlider(nSldPtr)\cvsSlider)
EndProcedure

Procedure SLD_gadgetY(nSldPtr)
  ProcedureReturn GadgetY(gaSlider(nSldPtr)\cvsSlider)
EndProcedure

Procedure SLD_gadgetWidth(nSldPtr)
  ProcedureReturn GadgetWidth(gaSlider(nSldPtr)\cvsSlider)
EndProcedure

Procedure SLD_gadgetHeight(nSldPtr)
  ProcedureReturn GadgetHeight(gaSlider(nSldPtr)\cvsSlider)
EndProcedure

Procedure.s SLD_getName(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\sName
EndProcedure

Procedure SLD_calcUnitWidth(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRange          ; = \nMax - \nMin
  Protected nBtnUnits       ; = number of units of the scrollbar that the button occupies, = the current page length
  Protected nBtnRange       ; = nRange - nBtnUnits, ie the actual number of units that the button can move
  
  With gaSlider(nSldPtr)
    Select \nSliderType
      Case #SCS_ST_HSCROLLBAR
        nRange = \m_Max - \m_Min
        \nLogicalRange = nRange + 1 ; Added "+ 1" 16Oct2022 11.9.6
        ; debugMsg(sProcName, "\m_Min=" + \m_Min + ", \m_Max=" + \m_Max + ", \nLogicalRange=" + \nLogicalRange)
        nBtnUnits = \m_PageLength
        If nBtnUnits < 0
          nBtnUnits = 0
        ElseIf nBtnUnits > nRange
          nBtnUnits = nRange
        EndIf
        nBtnRange = nRange - nBtnUnits
        \btnWdth = \nCanvasWidth * nBtnUnits / nRange
        \btnHalfWdth = \btnWdth >> 1
        
        \nLblLeftWidth = 0
        \nLblRightWidth = 0
        \nGtrDistanceLeft = \btnHalfWdth + \nLblLeftWidth
        \nGtrDistanceRight = \btnHalfWdth + \nLblRightWidth
        \nGtrLength = (\nCanvasWidth - \nGtrDistanceLeft - \nGtrDistanceRight) ; starting value - may be adjusted below
        ; Added 17Dec2021 11.8.6cx
        If \nGtrLength & 1 = 0
          ; currently even, so make odd so that a centre point can be calculated
          \nGtrLength - 1
        EndIf
        ; End added 17Dec2021 11.8.6cx
        ; debugMsg(sProcName, "\nCanvasWidth=" + \nCanvasWidth)
        \nPhysicalRange = \nGtrLength
        ; debugMsg(sProcName, "\nPhysicalRange=" + \nPhysicalRange)
        \nGtrX1 = \nGtrDistanceLeft
        \nGtrX2 = \nGtrDistanceLeft + \nGtrLength
        \nPointerMinX = \nLblLeftWidth
        \nPointerMaxX = \nCanvasWidth - \nLblRightWidth
        If \nLogicalRange > 0
;           \fUnitSize = (\nPhysicalRange - 2) / \nLogicalRange  ; width of 1 value unit of the slider.
          ; nb when pointer is displayed it is displayed with a single-pixel border on the left (when at min position)
          ; -2 in above calculation gives single pixel border at RHS when pointer moved to max
          ; Changed 17Dec2021 11.8.6cx
          \fUnitSize = (\nPhysicalRange - 2) / (\nLogicalRange + 1)  ; width of 1 value unit of the slider
        Else
          \fUnitSize = \nPhysicalRange
        EndIf
        ; debugMsg(sProcName, "\nGtrLength=" + \nGtrLength + ", \fUnitSize=" + StrF(\fUnitSize,4) + ", \btnWdth=" + \btnWdth + ", \btnHalfWdth=" + \btnHalfWdth)
        
      Default ; Other ST values
        If \m_Max >= #SCS_CONTINUOUS_END_AT
          \nLogicalRange = 0
        Else
          \nLogicalRange = \m_Max - \m_Min + 1 ; Added "+ 1" 16Oct2022 11.9.6
        EndIf
        If (\bAudioGraph) And (\nAudioGraphImageNo)
          If \nLogicalRange > 0
            \fUnitSize = (\nCanvasWidth - \nLblLeftWidth - \nLblRightWidth) / \nLogicalRange
          Else
            \fUnitSize = (\nCanvasWidth - \nLblLeftWidth - \nLblRightWidth)
          EndIf
        ElseIf \nLogicalRange > 0
          Select \nSliderType
            Case #SCS_ST_VFADER_LIVE_INPUT To #SCS_ST_VFADER_DIMMER_CHAN
              ; Added this test and the following modified \fUnitSize calculation 10May2023 11.10.0bb
              ; Needs more investigation into what the 'correct' value of \nLogicalRange should be, etc.
              ; Without this test the DMX faders displayed slightly low at 100% instead of displaying at the very top of the slider.
              ; The audio faders displayed ok, but that would have because the 'logical range' is about 100 times greater than that of the DMX sliders.
              ; The logical range of the audio faders is 10001 but the logical range of the DMX faders is 101.
              ; Deducting 1 results in the 'correct' \fUnitSize for both types of fader.
              \fUnitSize = \nPhysicalRange / (\nLogicalRange - 1)  ; width of 1 value unit of the slider
            Default
              ; \fUnitSize = \nPhysicalRange / \nLogicalRange  ; width of 1 value unit of the slider
              ; Changed 17Dec2021 11.8.6cx
              \fUnitSize = \nPhysicalRange / (\nLogicalRange + 1)  ; width of 1 value unit of the slider
          EndSelect
        Else
          \fUnitSize = \nPhysicalRange
        EndIf
;         If \nSliderType = #SCS_ST_VFADER_DMX_MASTER Or \nSliderType = #SCS_ST_VFADER_MASTER
;           debugMsg0(sProcName, ">>>> \nPhysicalRange=" + \nPhysicalRange + ", \nLogicalRange=" + \nLogicalRange + ", \fUnitSize=" + StrF(\fUnitSize))
;         EndIf
    EndSelect
  EndWith
EndProcedure

Procedure SLD_calcMarkerPosForSliderValue(nSldPtr, nSliderValue)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nMarkerPos, nLogicalRange, nPhysicalRange, nLogicalPos
  
  With gaSlider(nSldPtr)
    If \m_Max < #SCS_CONTINUOUS_END_AT
      If nSliderValue <= \m_Max And nSliderValue >= \m_Min
        nLogicalRange = \m_Max - \m_Min
        nPhysicalRange = \nGtrLength
        nLogicalPos = nSliderValue - \m_Min
        nMarkerPos = Round((nPhysicalRange * nLogicalPos) / nLogicalRange, #PB_Round_Nearest) + \nGtrDistanceLeft
;         If \nSliderType = #SCS_ST_FREQ Or \nSliderType = #SCS_ST_TEMPO Or \nSliderType = #SCS_ST_PITCH
;           debugMsg0(sProcName, "nSliderValue=" + nSliderValue + ", nLogicalRange=" + nLogicalRange + ", nPhysicalRange=" + nPhysicalRange + ", nLogicalPos=" + nLogicalPos + ", \nGtrDistanceLeft=" + \nGtrDistanceLeft)
;           debugMsg0(sProcName, "Round((" + nPhysicalRange + " * " + nLogicalPos + ") / " + nLogicalRange + ", #PB_Round_Nearest) + " + \nGtrDistanceLeft + ", returning nMarkerPos=" + nMarkerPos)
;         EndIf
      EndIf
    EndIf
  EndWith
  ; debugMsg0(sProcName, #SCS_END + ", returning nMarkerPos=" + nMarkerPos)
  ProcedureReturn nMarkerPos
EndProcedure

Procedure SLD_BVLevelToSliderValue(fBVLevel.f, fTrimFactor.f=1, nFaderInfoIndex=0)
  ; PROCNAMEC()
  Protected nSliderValue
  Protected fdB.f, fRelativeDB.f
  
  ; debugMsg0(sProcName, #SCS_START + ", fBVLevel=" + traceLevel(fBVLevel))
  
  With gaFaderInfo(nFaderInfoIndex)
    ; NB fBVLevel is in range 0.0 to 1.0
    If fBVLevel >= grLevels\fMaxBVLevel
      nSliderValue = #SCS_MAXVOLUME_SLD
      
    ElseIf fBVLevel <= grLevels\fMinBVLevel
      nSliderValue = #SCS_MINVOLUME_SLD
      
    Else
      fdB = convertBVLevelToDBLevel(fBVLevel)
      If fdB >= \fFdrSecADBBase
        fRelativeDB = fdB - \fFdrSecADBBase
        nSliderValue = \fFdrSecABaseValue + (fRelativeDB * \fFdrSecA1DBValue)
        
      ElseIf fdB >= \fFdrSecBDBBase
        fRelativeDB = fdB - \fFdrSecBDBBase
        nSliderValue = \fFdrSecBBaseValue + (fRelativeDB * \fFdrSecB1DBValue)
        
      Else
        fRelativeDB = fdB - \fFdrSecCDBBase
        nSliderValue = \fFdrSecCBaseValue + (fRelativeDB * \fFdrSecC1DBValue)
      EndIf
      
      If fTrimFactor <> 0
        nSliderValue = nSliderValue * fTrimFactor
      EndIf
    EndIf
    
    If nSliderValue < #SCS_MINVOLUME_SLD
      nSliderValue = #SCS_MINVOLUME_SLD
      
    ElseIf nSliderValue > #SCS_MAXVOLUME_SLD
      nSliderValue = #SCS_MAXVOLUME_SLD
    EndIf
  EndWith
  
  ; debugMsg0(sProcName, #SCS_END + ", returning nSliderValue=" + nSliderValue)
  ProcedureReturn nSliderValue
  
EndProcedure

Procedure SLD_levelToPercentage(fBVLevel.f, fTrimFactor.f=1, nFaderInfoIndex=0)
  Protected nSliderValue, nPercentage
  
  nSliderValue = SLD_BVLevelToSliderValue(fBVLevel, fTrimFactor, nFaderInfoIndex)
  nPercentage = Round((nSliderValue - #SCS_MINVOLUME_SLD) * 100 / (#SCS_MAXVOLUME_SLD - #SCS_MINVOLUME_SLD), #PB_Round_Nearest)
  If nPercentage < 0
    nPercentage = 0
  ElseIf nPercentage > 100
    nPercentage = 100
  EndIf
  ProcedureReturn nPercentage
EndProcedure

Procedure.f SLD_percentageToLevel(nPercentage, fTrimFactor.f=1, nFaderInfoIndex=0)
  Protected nSliderValue, fBVLevel.f
  
  nSliderValue = Round((#SCS_MAXVOLUME_SLD - #SCS_MINVOLUME_SLD) * nPercentage / 100, #PB_Round_Nearest) + #SCS_MINVOLUME_SLD
  If nSliderValue < #SCS_MINVOLUME_SLD
    nSliderValue = #SCS_MINVOLUME_SLD
  ElseIf nSliderValue > #SCS_MAXVOLUME_SLD
    nSliderValue = #SCS_MAXVOLUME_SLD
  EndIf
  fBVLevel = SLD_SliderValueToBVLevel(nSliderValue, fTrimFactor, nFaderInfoIndex)
  ProcedureReturn fBVLevel
EndProcedure

Procedure.f SLD_SliderValueToBVLevel(nSliderValue, fTrimFactor.f=1, nFaderInfoIndex=0)
  ; PROCNAMEC()
  Protected nAdjustedSliderVal
  Protected fBVLevel.f
  Protected fdB.f, fRelativeValue.f
  
  With gaFaderInfo(nFaderInfoIndex)
    ; NB fBVLevel is to be in range 0.0 to 1.0
    If nSliderValue = #SCS_MINVOLUME_SLD
      fBVLevel = #SCS_MINVOLUME_SINGLE
      
    Else
      If fTrimFactor = 0
        nAdjustedSliderVal = nSliderValue
      Else
        nAdjustedSliderVal = nSliderValue / fTrimFactor
      EndIf
      
      If nAdjustedSliderVal >= \fFdrSecABaseValue
        fRelativeValue = nAdjustedSliderVal - \fFdrSecABaseValue
        fdB = \fFdrSecADBBase + (fRelativeValue / \fFdrSecA1DBValue)
        ; debugMsg0(sProcName, "nSliderValue=" + nSliderValue + ", nAdjustedSliderVal=" + nAdjustedSliderVal + ", \fFdrSecABaseValue=" + StrF(\fFdrSecABaseValue) + ", fRelativeValue=" + StrF(fRelativeValue) +
        ;                      ", \fFdrSecADBBase=" + StrF(\fFdrSecADBBase) + ", \fFdrSecA1DBValue=" + StrF(\fFdrSecA1DBValue) + ", fdB=" + StrF(fdB))
        
      ElseIf nAdjustedSliderVal >= \fFdrSecBBaseValue
        fRelativeValue = nAdjustedSliderVal - \fFdrSecBBaseValue
        fdB = \fFdrSecBDBBase + (fRelativeValue / \fFdrSecB1DBValue)
        ; debugMsg0(sProcName, "nSliderValue=" + nSliderValue + ", nAdjustedSliderVal=" + nAdjustedSliderVal + ", \fFdrSecBBaseValue=" + StrF(\fFdrSecBBaseValue) + ", fRelativeValue=" + StrF(fRelativeValue) + ", fdB=" + StrF(fdB))
        
      Else
        fRelativeValue = nAdjustedSliderVal - \fFdrSecCBaseValue
        fdB = \fFdrSecCDBBase + (fRelativeValue / \fFdrSecC1DBValue)
        ; debugMsg0(sProcName, "nSliderValue=" + nSliderValue + ", nAdjustedSliderVal=" + nAdjustedSliderVal + ", \fFdrSecCBaseValue=" + StrF(\fFdrSecCBaseValue) + ", fRelativeValue=" + StrF(fRelativeValue) + ", fdB=" + StrF(fdB))
        
      EndIf
      fBVLevel = convertDBLevelToBVLevel(fdB)
    EndIf
    
    If fBVLevel > grLevels\fMaxBVLevel
      fBVLevel = grLevels\fMaxBVLevel
      
    ElseIf fBVLevel <= grLevels\fMinBVLevel
      fBVLevel = #SCS_MINVOLUME_SINGLE
    EndIf
  EndWith
  
  ; debugMsg0(sProcName, "nSliderValue=" + nSliderValue + ", fBVLevel=" + convertBVLevelToDBString(fBVLevel))
  ProcedureReturn fBVLevel
  
EndProcedure

Procedure SLD_getContainerNo(nSldPtr)
  ProcedureReturn gaSlider(nSldPtr)\cvsSlider
EndProcedure

Procedure SLD_gotFocus(nSldPtr)
  With gaSlider(nSldPtr)
    If \bFader = #False
      If \m_BackColor <> #SCS_SLD_FOCUS_BACKCOLOR
        \m_BackColor = #SCS_SLD_FOCUS_BACKCOLOR
        SLD_drawSlider(nSldPtr)
        gnFocusSliderNo = nSldPtr
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure SLD_LostFocus(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  ; Protected nActiveWindow, nActiveGadgetNo
  
  ; debugMsg(sProcName, #SCS_START)
  ; nActiveWindow = GetActiveWindow()
  ; nActiveGadgetNo = GetActiveGadget()
  ; debugMsg(sProcName, "nActiveWindow=" + decodeWindow(nActiveWindow) + ", nActiveGadgetNo=" + getGadgetName( nActiveGadgetNo))
  
  With gaSlider(nSldPtr)
    ; nb - in tests with WQA\sldXPos etc it was found that LostFocus was sometimes occuring when the canvas still had focus.
    ; on further testing it appears to be have due to unnecessarily re-hiding the video player and/or unnecessarily resetting the preview canvas to visible.
    ; having removed these unnecessary calls, the 'lost focus' event on the slider is no longer being raised, but leave code in place anyway.
    ; (MJD 21/10/2013 - SCS 11.2.5)
    If GetActiveGadget() <> \cvsSlider
      If \bFader = #False
        \m_BackColor = #SCS_SLD_BACKCOLOR
        SLD_drawSlider(nSldPtr)
        gnFocusSliderNo = 0
      EndIf
      \bCurrMove = #False
      ; debugMsg(sProcName,"\bCurrMove=" + strB(\bCurrMove))
    EndIf
  EndWith
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure SLD_clearFocusSlider(bForceClear=#False)
  PROCNAMEC()
  
  If gnFocusSliderNo > 0
    With gaSlider(gnFocusSliderNo)
      If (bForceClear) Or (GetActiveGadget() <> \cvsSlider)
        If IsGadget(\cvsSlider)
          If \bFader = #False
            \m_BackColor = #SCS_SLD_BACKCOLOR
            SLD_drawSlider(gnFocusSliderNo)
            gnFocusSliderNo = 0
          EndIf
          \bCurrMove = #False
          ; debugMsg(sProcName,"\bCurrMove=" + strB(\bCurrMove))
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure SLD_redrawAllLevelSliders()
  PROCNAMEC()
  Protected nSldPtr
  
  debugMsg(sProcName, #SCS_START)
  
  For nSldPtr = 1 To gnSldCurrID
    CheckSubInRange(nSldPtr, ArraySize(gaSlider()), "gaSlider(), gnSldCurrID=" + gnSldCurrID)
    With gaSlider(nSldPtr)
      If \bInUse
        If \bLevelSlider
          If IsGadget(\cvsSlider)
            ; debugMsg(sProcName, "redraw gaSlider(" + nSldPtr + ")\sName=" + \sName)
            SLD_fcSliderType(nSldPtr)
            SLD_calcUnitWidth(nSldPtr)
            SLD_defineLevelMarkers(nSldPtr)
            \m_Value = SLD_BVLevelToSliderValue(\m_BVLevel)
            If \m_BaseBVLevel <> #SCS_SLD_NO_BASE
              \m_BaseValue = SLD_BVLevelToSliderValue(\m_BaseBVLevel)
            EndIf
            SLD_drawSlider(nSldPtr)
          EndIf
        EndIf
      EndIf
    EndWith
  Next nSldPtr
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_setToolTipType(nSldPtr, nSliderToolTipType)
  gaSlider(nSldPtr)\nSliderToolTipType = nSliderToolTipType
EndProcedure

Procedure SLD_ToolTip(nSldPtr, nAction, sToolTip.s="")
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Static cvsTooltip
  Static nTextHeight, nCanvasHeight
  Protected nTextWidth, nCanvasWidth
  Static nPrevCanvasWidth, nPrevCanvasHeight
  Protected nLeft, nTop
  Protected nWindowLeft, nWindowTop
  Static nParentWindow
  Protected nActiveWindow
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaSlider(nSldPtr)
    If \nSliderToolTipType = #SCS_SLD_TTT_NONE
      ProcedureReturn
    EndIf
    
    gnLabelSlider = 2001
    nActiveWindow = GetActiveWindow()
    ; debugMsg(sProcName, "nActiveWindow=" + decodeWindow(nActiveWindow) + ", nParentWindow=" + decodeWindow(nParentWindow) + ", \sName=" + \sName)
    Select nAction
      Case #SCS_SLD_TTA_BUILD, #SCS_SLD_TTA_SHOW
        ; The BUILD action was added to enabled forms to have the tooltip built early, eg on form creation, without being shown.
        ; This is because if we wait Until the tooltip is required then the first time the tooltip is displayed it will be displayed
        ; blank. I don't know why - I tried adding some timing delays but they didn't help. But by 'building' the tooltip early
        ; (eg on creating the form), the tooltip displays correctly every time.
        
        ; debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\nEventWindowNo=" + decodeWindow(gaSlider(nSldPtr)\nEventWindowNo) + ", nParentWindow=" + decodeWindow(nParentWindow))
        If \nEventWindowNo <> nParentWindow
          If IsWindow(#WST)
            ; close tooltip window as it must be recreated with a new parent
            scsCloseWindow(#WST)
          EndIf
          nParentWindow = \nEventWindowNo
        EndIf
        If IsWindow(nParentWindow) = #False
          If IsWindow(nActiveWindow)
            nParentWindow = nActiveWindow
          ElseIf IsWindow(#WED)
            nParentWindow = #WED
          EndIf
        EndIf
        If IsWindow(nParentWindow) = #False
          debugMsg(sProcName, "Exiting because nParentWindow (" + nParentWindow + ") failed 'IsWindow()'")
          ProcedureReturn
        EndIf
        If IsWindow(#WST) = #False
          If OpenWindow(#WST, 0, 0, 8, 8, "", #PB_Window_Invisible|#PB_Window_BorderLess|#PB_Window_NoActivate, WindowID(nParentWindow))
            registerWindow(#WST, "WST(Slider Tooltip)")
            cvsTooltip = scsCanvasGadget(0, 0, WindowWidth(#WST), WindowHeight(#WST), 0, "cvsToolTip")
          EndIf
        EndIf
        
        If IsGadget(cvsTooltip)
          If StartDrawing(CanvasOutput(cvsTooltip))
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            nTextWidth = TextWidth(sToolTip)
            nCanvasWidth = nTextWidth + 8
            If nCanvasWidth < 40
              nCanvasWidth = 40
            EndIf
            If nTextHeight = 0
              ; nTextHeight = TextHeight("Ag")
              nTextHeight = TextHeight("8")
              nCanvasHeight = nTextHeight + 4
            EndIf
            If GadgetWidth(cvsTooltip) <> nCanvasWidth
              ResizeWindow(#WST, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
              ResizeGadget(cvsTooltip, #PB_Ignore, #PB_Ignore, nCanvasWidth, nCanvasHeight)
            EndIf
            Box(0, 0, nCanvasWidth, nCanvasHeight, RGB(255,255,223))
            DrawingMode(#PB_2DDrawing_Transparent)
            nLeft = (nCanvasWidth - nTextWidth) >> 1
            nTop = (nCanvasHeight - nTextHeight) >> 1
            DrawText(nLeft, nTop, sToolTip, #SCS_Black)
            ; debugMsg0(sProcName, "DrawText(" + nLeft + ", " + nTop + ", " + #DQUOTE$ + sToolTip + #DQUOTE$ + ", #SCS_Black)")
            StopDrawing()
            If nTextWidth > 0
              nWindowLeft = DesktopMouseX() + 8
              nWindowTop = DesktopMouseY() + 8
              ResizeWindow(#WST, nWindowLeft, nWindowTop, #PB_Ignore, #PB_Ignore)
              If nAction = #SCS_SLD_TTA_SHOW
                HideWindow(#WST, #False, #PB_Window_NoActivate)
              EndIf
            EndIf
          EndIf
        EndIf
        
      Case #SCS_SLD_TTA_HIDE  ; hide tooltip
        If IsWindow(#WST)
          HideWindow(#WST, #True)
        EndIf
        
    EndSelect
    If IsWindow(nActiveWindow)
      SAW(nActiveWindow)
    EndIf
    gnLabelSlider = 2009
  EndWith
EndProcedure

Procedure SLD_clearLvlPts(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  
  With gaSlider(nSldPtr)
    \nMaxArrayIndex = -1
  EndWith
EndProcedure

Procedure SLD_loadLvlPts(nSldPtr)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nLevelPointIndex, nItemIndex
  Protected nMaxLevelPoint
  Protected nArrayIndex, nArraySize
  Protected d, k
  Protected nAbsStartAt, nAbsEndAt, nCueDuration
  Protected nPointTime
  Protected nPointRelTime
  Protected nPointX, nPointY
  Protected nPass
  Protected bDisplayLevelPoints
  Protected nPointType
  Protected fDevDBLevel.f, fItemDBLevel.f, fItemLevel.f
  Protected fMaxItemLevel.f
  Protected fStartLevel.f, fEndLevel.f
  Protected bShowLvlCurvesPrim, bShowLvlCurvesOther, bShowPanCurvesPrim, bShowPanCurvesOther
  Protected bPrimaryDev
  Protected fDevLevel.f
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaSlider(nSldPtr)
;     Debug sProcName + ", \nSliderType=" + \nSliderType + ", \m_Format=" + \m_Format
    nArrayIndex = -1
    k = \m_AudPtr
    If k >= 0
      nAbsStartAt = aAud(k)\nAbsStartAt
      nAbsEndAt = aAud(k)\nAbsEndAt
      nCueDuration = nAbsEndAt - nAbsStartAt + 1
      nMaxLevelPoint = aAud(k)\nMaxLevelPoint
      
      bShowLvlCurvesPrim = grOperModeOptions(gnOperMode)\bShowLvlCurvesPrim
      If bShowLvlCurvesPrim
        bShowLvlCurvesOther = grOperModeOptions(gnOperMode)\bShowLvlCurvesOther
      EndIf
      bShowPanCurvesPrim = grOperModeOptions(gnOperMode)\bShowPanCurvesPrim
      If bShowPanCurvesPrim
        bShowPanCurvesOther = grOperModeOptions(gnOperMode)\bShowPanCurvesOther
      EndIf
      
      \nFromDev = aAud(k)\nFirstSoundingDev
      If (bShowLvlCurvesPrim = #False) And (bShowPanCurvesPrim = #False)
        \nUpToDev = -1  ; force processing to be skipped
      ElseIf (bShowLvlCurvesOther = #False) And (bShowPanCurvesOther = #False)
        \nUpToDev = \nFromDev ; force loop to process only the primary device
      Else
        \nUpToDev = aAud(k)\nLastSoundingDev  ; process all devices
      EndIf
      If \nUpToDev >= \nFromDev
        nArraySize = (nMaxLevelPoint + 1) * (\nUpToDev + 1)
        If ArraySize(\aSldLvlPt()) < nArraySize
          ReDim \aSldLvlPt(nArraySize) ; nb may be larger than required due to level points before 'start at' or after 'end at'
        EndIf
        ; debugMsg(sProcName, "nMaxLevelPoint=" + nMaxLevelPoint + ", \nFromDev=" + \nFromDev + ", \nUpToDev=" + \nUpToDev + ", nArraySize=" + nArraySize + ", ArraySize(\aSldLvlPt())=" + ArraySize(\aSldLvlPt()))
        For d = \nFromDev To \nUpToDev
          If Len(aAud(k)\sLogicalDev[d]) > 0
            If d = \nFromDev
              bPrimaryDev = #True
            Else
              bPrimaryDev = #False
            EndIf
            ; fDevDBLevel = convertBVLevelToDBLevel(aAud(k)\fBVLevel[d])
            ; Added 6Dec2024 to fix issue of level point relative dB adjustments handling scenarios like "-Inf + 80dB = -Inf". Fix reults in something like "-120dB + 80dB = -40dB"
            fDevLevel = aAud(k)\fBVLevel[d]
            If fDevLevel < grLevels\fMinBVLevel
              fDevLevel = grLevels\fMinBVLevel
            EndIf
            fDevDBLevel = convertBVLevelToDBLevel(fDevLevel)
            ; End added 6Dec2024
            fMaxItemLevel = convertDBLevelToBVLevel(fDevDBLevel) ; use device level as the maximum for pass 2 unless pass 1 finds a higher device level
            For nPass = 1 To 2
              ; pass 1 looks for the maximum relative level; pass 2 calculates the X and Y positions for each required level point
              For nLevelPointIndex = 0 To nMaxLevelPoint
                nPointTime = aAud(k)\aPoint(nLevelPointIndex)\nPointTime
                If (nPointTime >= nAbsStartAt) And (nPointTime <= nAbsEndAt)
                  If nPass = 2
                    nPointType = aAud(k)\aPoint(nLevelPointIndex)\nPointType
                    Select nPointType
                      Case #SCS_PT_FADE_IN, #SCS_PT_STD, #SCS_PT_FADE_OUT
                        bDisplayLevelPoints = #True
                    EndSelect
                  EndIf
                  nItemIndex = getItemIndexForDevNo(k, nLevelPointIndex, d)
                  If nItemIndex >= 0
                    If aAud(k)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\bItemInclude
                      fItemDBLevel = fDevDBLevel + aAud(k)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemRelDBLevel
                      fItemLevel = convertDBLevelToBVLevel(fItemDBLevel)
                      If fItemLevel > grLevels\fMaxBVLevel
                        fItemLevel = grLevels\fMaxBVLevel
                      EndIf
                      If nPass = 1
                        If fItemLevel > fMaxItemLevel
                          fMaxItemLevel = fItemLevel
                        EndIf
                      Else  ; pass 2
                        Select nPointType
                          Case #SCS_PT_START
                            fStartLevel = fItemLevel
                          Case #SCS_PT_END
                            fEndLevel = fItemLevel
                        EndSelect
                        nPointRelTime = nPointTime - nAbsStartAt
                        If (\bAudioGraph) And (\nAudioGraphImageNo)
                          nPointX = ((\nCanvasWidth - \nLblLeftWidth - \nLblRightWidth) * nPointRelTime / nCueDuration) + \nLblLeftWidth
                        Else
                          nPointX = ((\nCanvasWidth - \nGtrDistanceLeft - \nGtrDistanceRight) * nPointRelTime / nCueDuration) + \nGtrDistanceLeft
                        EndIf
                        If ((bShowLvlCurvesPrim) And (bPrimaryDev)) Or (bShowLvlCurvesOther)
                          nPointY = \nCanvasHeight - (\nCanvasHeight * fItemLevel / fMaxItemLevel)
                        Else
                          nPointY = -999  ; see drawSldLvlPts()
                        EndIf
                        nArrayIndex + 1
                        If nArrayIndex > ArraySize(\aSldLvlPt())
                          ; shouldn't happen, but just in case...
                          ReDim \aSldLvlPt(nArrayIndex+10)
                        EndIf
                        ; debugMsg(sProcName, ", d=" + d + ", nLevelPointIndex=" + nLevelPointIndex + ", nItemIndex=" + nItemIndex + ", nArrayIndex=" + nArrayIndex)
                        CheckSubInRange(nArrayIndex, ArraySize(\aSldLvlPt()), "gaSlider(" + nSldPtr + ")\aSldLvlPt")
                        \aSldLvlPt(nArrayIndex)\nLevelPointIndex = nLevelPointIndex
                        \aSldLvlPt(nArrayIndex)\nItemIndex = nItemIndex
                        \aSldLvlPt(nArrayIndex)\nLvlPtX = nPointX
                        \aSldLvlPt(nArrayIndex)\nLvlPtY = nPointY
                        If aAud(k)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\nItemGraphChannels = 2
                          If ((bShowPanCurvesPrim) And (bPrimaryDev)) Or (bShowPanCurvesOther)
                            nPointY = \nCanvasHalfHeight + (\nCanvasHalfHeight * aAud(k)\aPoint(nLevelPointIndex)\aItem(nItemIndex)\fItemPan)
                          Else
                            nPointY = -999  ; see drawSldLvlPts()
                          EndIf
                        Else
                          nPointY = -999  ; see drawSldLvlPts()
                        EndIf
                        \aSldLvlPt(nArrayIndex)\nPanPtX = nPointX ; nb same X as for levels
                        \aSldLvlPt(nArrayIndex)\nPanPtY = nPointY
                        ; debugMsg(sProcName, "\aSldLvlPt(" + nArrayIndex + ")\nLevelPointIndex=" + \aSldLvlPt(nArrayIndex)\nLevelPointIndex + ", \nItemIndex=" + nItemIndex + ", \nLvlPtX=" + nPointX + ", \nLvlPtY=" + nPointY)
                        ; Debug "k=" + getAudLabel(k) + ", nSldPtr=" + nSldPtr + ", nLevelPointIndex=" + nLevelPointIndex + ", \aSldLvlPt(" + nArrayIndex + ")\nLvlPtX=" + \aSldLvlPt(nArrayIndex)\nLvlPtX + ", \aSldLvlPt(" + nArrayIndex + ")\nLvlPtY=" + \aSldLvlPt(nArrayIndex)\nLvlPtY
                      EndIf
                    EndIf
                  EndIf
                EndIf
              Next nLevelPointIndex
            Next nPass
          EndIf ; EndIf Len(aAud(k)\sLogicalDev[d]) > 0
        Next d
      EndIf ; EndIf nUpToDev >= nFromDev
    EndIf ; EndIf k >= 0
    If (bDisplayLevelPoints) Or (fEndLevel <> fStartLevel) Or (fStartLevel <> fDevDBLevel)
      ; nb test (nEndRelLevel <> nStartRelLevel) catches scenario of the only level points being 'start at' and 'end at', but where a level change occurs
      \nMaxArrayIndex = nArrayIndex
    Else
      ; nb do not display level points on a progress slider if there's nothing unusual about them - see test above for 'pass 2'
      \nMaxArrayIndex = -1
    EndIf
  EndWith
EndProcedure

Procedure SLD_drawLvlPts(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nPrevLvlPtX, nPrevLvlPtY, nThisLvlPtX, nThisLvlPtY
  Protected nPrevPanPtX, nPrevPanPtY, nThisPanPtX, nThisPanPtY
  Protected nAudPtr
  Protected nLevelPointIndex, nItemIndex
  Protected nPrevLevelPointIndex, nPrevItemIndex
  Protected bFirstLine
  Protected n
  Protected nThisLPColor, nThisPanColor
  
  ; debugMsg(sProcName, #SCS_START)
  
  gnLabelSlider = 2101
  With gaSlider(nSldPtr)
    nAudPtr = \m_AudPtr
    For nItemIndex = \nUpToDev To \nFromDev Step -1 ; draw primary device last so it's in front of other devices
;       debugMsg(sProcName, "nItemIndex=" + nItemIndex)
      If nItemIndex = \nFromDev
        ; primary device
        nThisLPColor = grMG2\nLPColor
        nThisPanColor = grMG2\nPanColor
      Else
        ; other devices
        nThisLPColor = grMG2\nLPColor2
        nThisPanColor = grMG2\nPanColor2
      EndIf
      bFirstLine = #True
      For nLevelPointIndex = 0 To aAud(nAudPtr)\nMaxLevelPoint
        ; debugMsg(sProcName, "nLevelPointIndex=" + nLevelPointIndex)
        For n = 0 To \nMaxArrayIndex
          ; debugMsg(sProcName, "\aSldLvlPt(" + n + ")\nLevelPointIndex=" + \aSldLvlPt(n)\nLevelPointIndex + ", \nItemIndex=" + \aSldLvlPt(n)\nItemIndex)
          If (\aSldLvlPt(n)\nLevelPointIndex = nLevelPointIndex) And (\aSldLvlPt(n)\nItemIndex = nItemIndex)
            ; debugMsg(sProcName, "match, bFirstLine=" + strB(bFirstLine))
            nThisLvlPtX = \aSldLvlPt(n)\nLvlPtX
            nThisLvlPtY = \aSldLvlPt(n)\nLvlPtY
            nThisPanPtX = \aSldLvlPt(n)\nPanPtX
            nThisPanPtY = \aSldLvlPt(n)\nPanPtY
            If bFirstLine = #False
              If nThisLvlPtY <> -999  ; see sldLoadLvlPts()
                LineXY(nPrevLvlPtX, nPrevLvlPtY, nThisLvlPtX, nThisLvlPtY, nThisLPColor)
                LineXY(nPrevLvlPtX, nPrevLvlPtY+1, nThisLvlPtX, nThisLvlPtY+1, #SCS_LevelPointEmphasis_Color)
              EndIf
              If nThisPanPtY <> -999  ; see sldLoadLvlPts()
                LineXY(nPrevPanPtX, nPrevPanPtY, nThisPanPtX, nThisPanPtY, nThisPanColor)
                LineXY(nPrevPanPtX, nPrevPanPtY+1, nThisPanPtX, nThisPanPtY+1, #SCS_LevelPointEmphasis_Color)
              EndIf
            EndIf
            bFirstLine = #False
            nPrevLvlPtX = nThisLvlPtX
            nPrevLvlPtY = nThisLvlPtY
            nPrevPanPtX = nThisPanPtX
            nPrevPanPtY = nThisPanPtY
          EndIf
        Next n
      Next nLevelPointIndex
    Next nItemIndex
  EndWith
  gnLabelSlider = 2109
  
;   debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure SLD_processOneLoadFileRequest()
  PROCNAMEC()
  Protected nSldPtr
  Protected nAudPtr, nFileDataPtr, bFileLoading, bLoadFromFileResult
  Protected bProcessSliderLoadFileRequests
  Protected sSubType.s
  
  debugMsg(sProcName, #SCS_START)
  
  For nSldPtr = 1 To ArraySize(gaSlider())
    With gaSlider(nSldPtr)
      If \bLoadFileRequest
        debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\sName=" + \sName + ", \bLoadFileRequest=" + strB(\bLoadFileRequest) +
                            ", \m_AudPtr=" + getAudLabel(\m_AudPtr) + ", \bRedrawSldAfterLoad=" + strB(\bRedrawSldAfterLoad))
        \bLoadFileRequest = #False
        nAudPtr = \m_AudPtr
        If nAudPtr >= 0
          nFileDataPtr = aAud(nAudPtr)\nFileDataPtr
          If nFileDataPtr >= 0
            sSubType = getSubTypeForAud(nAudPtr)
            bFileLoading = #True
            If (getFileScanMaxLength(sSubType) < 0) Or (aAud(nAudPtr)\nFileDuration <= getFileScanMaxLengthMS(sSubType))
              debugMsg(sProcName, "calling loadSamplesArrayFromFile(@grMG4, " + nFileDataPtr + ")")
              bLoadFromFileResult = loadSamplesArrayFromFile(@grMG4, nFileDataPtr)
              debugMsg(sProcName, "loadSamplesArrayFromFile(@grMG4, " + nFileDataPtr + ") returned " + strB(bLoadFromFileResult))
            EndIf
            If bLoadFromFileResult
              grMG4\nGraphChannels = gaFileData(nFileDataPtr)\nxFileChannels
              debugMsg(sProcName, "grMG4\nGraphChannels=" + grMG4\nGraphChannels + ", grMG4\nMGFileChannels=" + grMG4\nMGFileChannels + ", grMG4\nFileDuration=" + grMG4\nFileDuration)
              debugMsg(sProcName, "calling loadSlicePeakAndMinArraysFromSamplesArray(@grMG4, " + nFileDataPtr + ", " + \nAudioGraphWidth + ", " + getAudLabel(nAudPtr) + ", #True) for " + GetFilePart(gaFileData(nFileDataPtr)\sFileName))
              loadSlicePeakAndMinArraysFromSamplesArray(@grMG4, nFileDataPtr, \nAudioGraphWidth, nAudPtr, #True)
              ; now save information applicable to the drawing of this audio graph
              \nAudioGraphAudPtr = nAudPtr
              \nAudioGraphFileDuration = aAud(nAudPtr)\nFileDuration
              \nAudioGraphFileChannels = aAud(nAudPtr)\nFileChannels
              \nAudioGraphAbsMin = aAud(nAudPtr)\nAbsMin
              \nAudioGraphAbsMax = aAud(nAudPtr)\nAbsMax
              \bAudioGraphImageReady = #True
              If \bReloadThisSld = #False
                \bReloadThisSld = #True
                gnReloadSldCount + 1
              EndIf
              If \bRedrawSldAfterLoad
                If \bRedrawThisSld = #False
                  \bRedrawThisSld = #True
                  gnRedrawSldCount + 1
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        debugMsg(sProcName, "gaSlider(" + nSldPtr + ")\bLoadFileRequest=" + strB(\bLoadFileRequest) + ", \bRedrawSldAfterLoad=" + strB(\bRedrawSldAfterLoad) +
                            ", \bReloadThisSld=" + strB(\bReloadThisSld) + ", gnReloadSldCount=" + gnReloadSldCount + ", gnRedrawSldCount=" + gnRedrawSldCount)
        Break ; Break because for overall performance reasons we only want to process one load file request per call of this procedure
      EndIf
    EndWith
  Next nSldPtr
  
  ; now reset gbProcessSliderLoadFileRequests
  For nSldPtr = 1 To ArraySize(gaSlider())
    If gaSlider(nSldPtr)\bLoadFileRequest
      bProcessSliderLoadFileRequests = #True
      Break
    EndIf
  Next nSldPtr
  gbProcessSliderLoadFileRequests = bProcessSliderLoadFileRequests
  
  gbProcessSliderLoadFileRequestIssued = #False ; indicates ready to receive a new request
  
  debugMsg(sProcName, #SCS_END + ", gbProcessSliderLoadFileRequests=" + strB(gbProcessSliderLoadFileRequests))
  
EndProcedure

Procedure SLD_checkForAdjustingSlider(nSldPtr)
  Protected bAdjustSlider, nAudState
  
  With gaSlider(nSldPtr)
    bAdjustSlider = #True
    If \nSliderType = #SCS_ST_PROGRESS
      If \m_AudPtr >= 0
        nAudState = aAud(\m_AudPtr)\nAudState
        If nAudState >= #SCS_CUE_FADING_IN And nAudState <= #SCS_CUE_FADING_OUT And nAudState <> #SCS_CUE_PAUSED And nAudState <> #SCS_CUE_HIBERNATING
          ; do not adjust this progress slider for the calling event as it is being set based on the current playing position, from the procedure PNL_updateDisplayPanel()
          bAdjustSlider = #False
        EndIf
      EndIf
    EndIf
  EndWith
  ProcedureReturn bAdjustSlider
EndProcedure

Procedure SLD_populateCustomArrayForRemDevFader(nSldPtr, nRemDevMsgType)
  PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nRemDevMsgPtr
  Protected n1, n2, nCustomLinePos, nCustomLineType, nMajorCount, nSldWidth, fMajorWidth.f, fMajorPos.f, nMinorCount, fMinorWidth.f, fMinorPos.f, fDBLevel.f
  Protected nFaderLevel ; nb only interested in integer values (eg +10, -15)
  Protected bTrace = #False
  
  nRemDevMsgPtr = CSRD_GetMsgDataPtrForRemDevMsgType(nRemDevMsgType)
  ; debugMsg(sProcName, "nRemDevMsgType=" + nRemDevMsgType + ", nRemDevMsgPtr=" + nRemDevMsgPtr)
  
  If nRemDevMsgPtr >= 0
    With grCSRD\aRemDevMsgData(nRemDevMsgPtr)
      debugMsg(sProcName, "nRemDevMsgType=" + CSRD_DecodeRemDevMsgType(nRemDevMsgType) + ", grCSRD\aRemDevMsgData(" + nRemDevMsgPtr + ")\sCSRD_FdrData=" + \sCSRD_FdrData +
                          ", \nCSRD_MaxFaderValue=" + \nCSRD_MaxFaderValue + ", ArraySize(\aFdrValue())=" + ArraySize(\aFdrValue()))
    EndWith
  EndIf
  
  With gaSlider(nSldPtr)
    If nRemDevMsgPtr >= 0
      \nMaxSldCustom = grCSRD\aRemDevMsgData(nRemDevMsgPtr)\nCSRD_MaxFaderValue
      If \nMaxSldCustom >= 0
        If \nMaxSldCustom > ArraySize(\aSldCustom())
          ReDim \aSldCustom(\nMaxSldCustom)
        EndIf
        For n1 = 0 To ArraySize(\aSldCustom())
          \aSldCustom(n1)\nCustomDBLevel = -999
          \aSldCustom(n1)\fCustomBVLevel = #SCS_MINVOLUME_SINGLE
          \aSldCustom(n1)\nCustomLinePos = 0
        Next n1
        For n1 = 0 To grCSRD\aRemDevMsgData(nRemDevMsgPtr)\nCSRD_MaxFaderValue
          nFaderLevel = grCSRD\aRemDevMsgData(nRemDevMsgPtr)\aFdrValue(n1)\fCSRD_FdrLevel_dB
          If nFaderLevel = 0
            nCustomLineType = #SCS_SLD_CLT_0DB
            nMajorCount + 1
          ElseIf nFaderLevel = 5 Or nFaderLevel = -5 Or (nFaderLevel % 10) = 0
            nCustomLineType = #SCS_SLD_CLT_MAJOR
            nMajorCount + 1
          Else
            nCustomLineType = #SCS_SLD_CLT_MINOR
          EndIf
          \aSldCustom(n1)\nCustomDBLevel = nFaderLevel
          fDBLevel = nFaderLevel
          \aSldCustom(n1)\fCustomBVLevel = Pow(10, (fDBLevel / 20))
          \aSldCustom(n1)\nCustomLineType = nCustomLineType
        Next n1
        ; force first and last entries to be 'major' (which they probably will be anyway
        \aSldCustom(0)\nCustomLineType = #SCS_SLD_CLT_MAJOR
        \aSldCustom(\nMaxSldCustom)\nCustomLineType = #SCS_SLD_CLT_MAJOR
        nSldWidth = \nGtrLength
        \aSldCustom(0)\nCustomLinePos = 0
        debugMsgC(sProcName, "\aSldCustom(0)\nCustomLinePos=" + \aSldCustom(0)\nCustomLinePos + " (min)")
        \aSldCustom(\nMaxSldCustom)\nCustomLinePos = nSldWidth - 1
        debugMsgC(sProcName, "\aSldCustom(" + \nMaxSldCustom + ")\nCustomLinePos=" + \aSldCustom(\nMaxSldCustom)\nCustomLinePos + " (max)")
        fMajorWidth = nSldWidth / (nMajorCount - 1)
        debugMsgC(sProcName, "nSldWidth=" + nSldWidth + ", nMajorCount=" + nMajorCount + ", fMajorWidth=" + StrF(fMajorWidth,2))
        For n1 =  1 To (\nMaxSldCustom - 1)
          If \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_MAJOR Or \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_0DB
            fMajorPos + fMajorWidth
            \aSldCustom(n1)\nCustomLinePos = fMajorPos
            debugMsgC(sProcName, "\aSldCustom(" + n1 + ")\nCustomDBLevel=" + \aSldCustom(n1)\nCustomDBLevel + ", \nCustomLinePos=" + \aSldCustom(n1)\nCustomLinePos + " (major)")
          EndIf
        Next n1
        For n1 = 0 To \nMaxSldCustom
          If \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_MAJOR Or \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_0DB
            fMinorPos = \aSldCustom(n1)\nCustomLinePos
            nMinorCount = 0
            For n2 = (n1 + 1) To \nMaxSldCustom
              If \aSldCustom(n2)\nCustomLineType = #SCS_SLD_CLT_MINOR
                nMinorCount + 1
              Else
                Break
              EndIf
            Next n2
            If nMinorCount > 0
              fMinorWidth = fMajorWidth / (nMinorCount + 1)
              debugMsgC(sProcName, "n1=" + n1 + ", fMajorWidth=" + StrF(fMajorWidth,2) + ", nMinorCount=" + nMinorCount + ", fMinorWidth=" + StrF(fMinorWidth,2))
              For n2 = (n1 + 1) To \nMaxSldCustom
                If \aSldCustom(n2)\nCustomLineType = #SCS_SLD_CLT_MINOR
                  fMinorPos + fMinorWidth
                  \aSldCustom(n2)\nCustomLinePos = fMinorPos
                  debugMsgC(sProcName, "\aSldCustom(" + n2 + ")\nCustomDBLevel=" + \aSldCustom(n2)\nCustomDBLevel + ", \nCustomLinePos=" + \aSldCustom(n2)\nCustomLinePos + " (minor)")
                Else
                  Break
                EndIf
              Next n2
            EndIf ; EndIf nMinorCount > 0
          EndIf ; EndIf \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_MAJOR Or \aSldCustom(n1)\nCustomLineType = #SCS_SLD_CLT_0DB
        Next n1
      EndIf ; EndIf \nMaxSldCustom >= 0
    EndIf ; EndIf nRemDevMsgPtr >= 0
  EndWith
  
  ; debugMsg(sProcName, "nSldWidth=" + nSldWidth)
  
  For n1 = 0 To gaSlider(nSldPtr)\nMaxSldCustom
    With gaSlider(nSldPtr)\aSldCustom(n1)
      \nCustomLinePos = nSldWidth - \nCustomLinePos - 1
      ; debugMsg(sProcName, "\aSldCustom(" + n1 + ")\nCustomDBLevel=" + \nCustomDBLevel + ", \nCustomLineType=" + \nCustomLineType + ", \nCustomLinePos=" + \nCustomLinePos)
    EndWith
  Next n1
  
EndProcedure

Procedure SLD_setCustomLinePosForDBValue(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected fdBLevel.f, n
  Protected nThisdBLevel, nNextdBLevel, nThisLinePos, nNextLinePos, fReqdLinePos.f, nReqdLinePos, fFactor.f
  
  With gaSlider(nSldPtr)
    fdBLevel = convertBVLevelToDBLevel(\m_BVLevel)
    nReqdLinePos = -1
    If \nMaxSldCustom >= 0
      ; debugMsg(sProcName, "fdBLevel=" + StrF(fdBLevel,2) + ", \aSldCustom(0)\nCustomDBLevel=" + \aSldCustom(0)\nCustomDBLevel + ", \aSldCustom(" + \nMaxSldCustom + ")\nCustomDBLevel=" + \aSldCustom(\nMaxSldCustom)\nCustomDBLevel)
      If fdBLevel >= \aSldCustom(0)\nCustomDBLevel
        nReqdLinePos = \aSldCustom(0)\nCustomLinePos
      ElseIf fdBLevel <= \aSldCustom(\nMaxSldCustom)\nCustomDBLevel
        nReqdLinePos = \aSldCustom(\nMaxSldCustom)\nCustomLinePos
      EndIf
    EndIf
    ; debugMsg(sProcName, "nReqdLinePos=" + nReqdLinePos)
    If nReqdLinePos < 0
      For n = 0 To \nMaxSldCustom
        nThisdBLevel = \aSldCustom(n)\nCustomDBLevel
        If n < \nMaxSldCustom - 1
          nNextdBLevel = \aSldCustom(n+1)\nCustomDBLevel
        Else
          nNextdBLevel = nThisdBLevel
        EndIf
        ; debugMsg(sProcName, "fdBLevel=" + StrF(fdBLevel,2) + ", n=" + n + ", nThisdBLevel=" + nThisdBLevel + ", nNextdBLevel=" + nNextdBLevel)
        If fdBLevel >= nThisdBLevel
          nReqdLinePos = \aSldCustom(n)\nCustomLinePos
        ElseIf fdBLevel = nNextdBLevel
          nReqdLinePos = \aSldCustom(n+1)\nCustomLinePos
        ElseIf fdBLevel > nNextdBLevel
          nThisLinePos = \aSldCustom(n)\nCustomLinePos
          nNextLinePos = \aSldCustom(n+1)\nCustomLinePos
          fFactor = (fdBLevel - nThisdBLevel) / (nNextdBLevel - nThisdBLevel)
          fReqdLinePos = (fFactor * (nNextLinePos - nThisLinePos)) + nThisLinePos
          nReqdLinePos = fReqdLinePos
        EndIf
        ; debugMsg(sProcName, ".. nReqdLinePos=" + nReqdLinePos)
        If nReqdLinePos >= 0
          Break
        EndIf
      Next n
    EndIf
    ; debugMsg0(sProcName, "fdBLevel=" + StrF(fdBLevel,2) + ", nReqdLinePos=" + nReqdLinePos + ", nThisdBLevel=" + nThisdBLevel + ", nNextdBLevel=" + nNextdBLevel +
    ;                      ", nThisLinePos=" + nThisLinePos + ", nNextLinePos=" + nNextLinePos + ", fFactor=" + StrF(fFactor,2))
    If nReqdLinePos < 0
      nReqdLinePos = 0
    EndIf
    \nSldCustomLinePos = nReqdLinePos
    ; debugMsg0(sProcName, "\nSldCustomLinePos=" + \nSldCustomLinePos)
  EndWith
  
EndProcedure

Procedure SLD_setBVLevelForSldCustomLinePos(nSldPtr)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  Protected nSldCustomLinePos, nThisLinePos, nNextLinePos
  Protected fReqdDBLevel.f, bReqdDBLevelSet, n
  Protected fThisDBLevel.f, fNextDBLevel.f, fReqdLinePos.f, nReqdLinePos, fFactor.f
  
  With gaSlider(nSldPtr)
    nSldCustomLinePos = \nSldCustomLinePos
    If nSldCustomLinePos = 0
      \m_BVLevel = 0
    Else
      For n = 0 To \nMaxSldCustom
        nThisLinePos = \aSldCustom(n)\nCustomLinePos
        If n < \nMaxSldCustom - 1
          nNextLinePos = \aSldCustom(n+1)\nCustomLinePos
        Else
          nNextLinePos = nThisLinePos
        EndIf
        ; debugMsg0(sProcName, "\nCustomLinePos=" + \nCustomLinePos + ", nThisLinePos=" + nThisLinePos + ", nNextLinePos=" + nNextLinePos)
        If nSldCustomLinePos >= nThisLinePos
          fReqdDBLevel = \aSldCustom(n)\nCustomDBLevel
          bReqdDBLevelSet = #True
        ElseIf nSldCustomLinePos = nNextLinePos
          fReqdDBLevel = \aSldCustom(n+1)\nCustomDBLevel
          bReqdDBLevelSet = #True
        ElseIf nSldCustomLinePos > nNextLinePos
          fThisDBLevel = \aSldCustom(n)\nCustomDBLevel
          fNextDBLevel = \aSldCustom(n+1)\nCustomDBLevel
          fFactor = (nSldCustomLinePos - nThisLinePos) / (nThisLinePos - nNextLinePos)
          fReqdDBLevel = (fFactor * (fThisDBLevel - fNextDBLevel)) + fThisDBLevel
          ; debugMsg0(sProcName, "fThisDBLevel=" + StrF(fThisDBLevel,2) + ", fNextDBLevel=" + StrF(fNextDBLevel,2) + ", fFactor=" + StrF(fFactor,2) + ", fReqddBLevel=" + StrF(fReqddBLevel,2))
          bReqdDBLevelSet = #True
        EndIf
        If bReqdDBLevelSet
          Break
        EndIf
      Next n
      If bReqdDBLevelSet
        If \nSliderType = #SCS_ST_REMDEV_FADER_LEVEL And \nRemDevMsgType > 0
          \m_BVLevel = convertDBLevelToBVLevel(fReqdDBLevel, \nRemDevMsgType)
          ; debugMsg0(sProcName, "nSldCustomLinePos=" + nSldCustomLinePos + ", fReqdDBLevel=" + StrF(fReqdDBLevel,2) + ", \nRemDevMsgType=" + CSRD_DecodeRemDevMsgType(\nRemDevMsgType) + ", \m_BVLevel=" + traceLevel(\m_BVLevel))
        Else
          \m_BVLevel = convertDBLevelToBVLevel(fReqdDBLevel)
          ; debugMsg0(sProcName, "nSldCustomLinePos=" + nSldCustomLinePos + ", fReqdDBLevel=" + StrF(fReqdDBLevel,2) + ", \m_BVLevel=" + traceLevel(\m_BVLevel))
        EndIf
      Else
        \m_BVLevel = 0
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure SLD_setBtnColor1(nSldPtr, nBtnColor1)
  ; PROCNAME(buildSliderProcName(#PB_Compiler_Procedure, nSldPtr))
  
  ; debugMsg(sProcName, #SCS_START + ", nBtnColor1=" + nBtnColor1)
  
  With gaSlider(nSldPtr)
    If nBtnColor1 >= 0
      \btnColor1 = nBtnColor1
    Else
      ; If nBtnColor < 0 (eg -1) then use the default color
      Select \nSliderType
        Case #SCS_ST_PROGRESS
          \btnColor1 = #SCS_Progress_Color
        Case #SCS_ST_POSITION
          \btnColor1 = #SCS_Position_Color
        Case #SCS_ST_PAN
          \btnColor1 = #SCS_Pan_Color
        Case #SCS_ST_PANNOLR
          \btnColor1 = #SCS_Pan_Color
        Case #SCS_ST_HLEVELRUN
          \btnColor1 = #SCS_Level_Color
        Case #SCS_ST_HLEVELNODB
          \btnColor1 = #SCS_Level_Color
        Case #SCS_ST_HPERCENT
          \btnColor1 = #SCS_Percent_Color
        Case #SCS_ST_HLIGHTING_PERCENT
          \btnColor1 = #SCS_Yellow
        Case #SCS_ST_HGENERAL
          \btnColor1 = #SCS_General_Color1
        Case #SCS_ST_HLIGHTING_GENERAL
          \btnColor1 = #SCS_Yellow
        Case #SCS_ST_VGENERAL
          \btnColor1 = #SCS_General_Color1
        Case #SCS_ST_VFADER_LIVE_INPUT, #SCS_ST_VFADER_OUTPUT, #SCS_ST_VFADER_PLAYING, #SCS_ST_VFADER_MASTER
          \btnColor1 = #SCS_Level_Color
        Case #SCS_ST_HSCROLLBAR
          \btnColor1 = #SCS_ScrollThumb_Color1
        Case #SCS_ST_REMDEV_FADER_LEVEL
          \btnColor1 = #SCS_Level_Color
        Case #SCS_ST_FREQ, #SCS_ST_TEMPO, #SCS_ST_PITCH
          \btnColor1 = #SCS_Light_Blue
      EndSelect
    EndIf
  EndWith
  
EndProcedure

; EOF