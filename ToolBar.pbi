; File: ToolBar.pbi

EnableExplicit

Procedure setToolbarColors()
  With grToolBarColors
    \nCntColor = RGB(56,51,55)
    \nBtnColor = \nCntColor ; make button and container the same color to remove borders around buttons
    \nBtnColorMouseOver = RGB(86,81,85)
    \nBtnTextColor = RGB(230,230,230)
    \nBtnMoreEnRGBA = RGBA(144,144,144,255)
    \nBtnMoreEnRGB = RGB(144,144,144)
    \nBtnMoreDiRGBA = RGBA(180,180,180,255)
    \nBtnMoreDiRGB = RGB(180,180,180)
    \nCatColor = RGB(70,70,70)
    \nCatColorMouseOver = RGB(95,95,95)
    \nCatTextColor = \nBtnTextColor
    \nCatMoreEnRGBA = \nBtnMoreEnRGBA
    \nCatMoreEnRGB = \nBtnMoreEnRGB
    \bColorsLoaded = #True
  EndWith
EndProcedure

Procedure WrapTextInit()
  ; PROCNAMEC()
  
  gsUnwrappedText = ""
  gnWrapTextLineCount = 0
  gnWrapTextTotalHeight = 0
EndProcedure

Procedure WrapTextAddLine(sLine.s)
  ; PROCNAMEC()
  
  If gnWrapTextLineCount > 0
    gsUnwrappedText + " "
  EndIf
  gsUnwrappedText + sLine
  gnWrapTextLineCount + 1
  gnWrapTextTotalHeight + TextHeight(sLine)
  ; debugMsg(sProcName, "sLine=" + #DQUOTE$ + sLine + #DQUOTE$ + ", gnWrapTextLineCount=" + gnWrapTextLineCount + ", gnWrapTextTotalHeight=" + gnWrapTextTotalHeight)
EndProcedure

Procedure WrapTextCenter(X, Y, Text.s, Width, nFrontColor, nBackColor, bNonBreakingHyphens=#False)
  ; PROCNAMEC()
  Protected nLimit, nCut, nLeft, nTextWidth
  Protected nLFPos, sTextLeft.s, sTextRight.s
  
  nLFPos = FindString(Text, Chr(10))
  If nLFPos > 0
    sTextLeft = Trim(Left(Text, nLFPos-1))
    WrapTextCenter(X,Y,sTextLeft,Width,nFrontColor,nBackColor, bNonBreakingHyphens)
    sTextRight = Trim(Mid(Text, nLFPos+1))
    WrapTextCenter(X,Y+TextHeight("|"),sTextRight,Width,nFrontColor,nBackColor, bNonBreakingHyphens)
  Else
    nTextWidth = TextWidth(Text)
    If nTextWidth <= Width
      nLeft = X + ((Width - nTextWidth) >> 1)
      DrawText(nLeft,Y,Text, nFrontColor, nBackColor)
      WrapTextAddLine(Text)
    Else
      nLimit = 0
      Repeat 
        nLimit + 1 
      Until TextWidth(Left(Text,nLimit)) > Width 
      nCut = nLimit
      If bNonBreakingHyphens
        Repeat 
          nCut - 1 
        Until Mid(Text,nCut,1) = " " Or nCut = 0
      Else
        Repeat 
          nCut - 1 
        Until Mid(Text,nCut,1) = " " Or Mid(Text,nCut,1) = "-" Or nCut = 0
      EndIf
      If nCut = 0 
        nCut = nLimit - 1 
      EndIf
      sTextLeft = Trim(Left(Text,nCut))
      nTextWidth = TextWidth(sTextLeft)
      nLeft = X + ((Width - nTextWidth) >> 1)
      DrawText(nLeft,Y,sTextLeft,nFrontColor,nBackColor)
      WrapTextAddLine(sTextLeft)
      WrapTextCenter(X,Y+TextHeight("|"),Trim(Mid(Text,nCut+1)),Width,nFrontColor,nBackColor,bNonBreakingHyphens)
    EndIf
  EndIf
EndProcedure

Procedure WrapTextLeft(X, Y, Text.s, Width, nFrontColor, nBackColor)  ;Word Wrap example by kenmo updated to pb4, added fontspace to accomodate fonts of any size.
  ; PROCNAMEC()
  Protected nLimit, nCut, nTextWidth
  Protected nLFPos, sTextLeft.s, sTextRight.s
  Protected sMyText.s
  
  ; please use WordWrapW() instead of this procedure - see WordWrap.pbi for details
  
  ; debugMsg(sProcName, #SCS_START + ", Text=" + Text)
  
  ;- needs work
  ; eg
  ; SCS Professional (Time-Limited)
  ; License expires 01 Jul 2012
  ; appears on the splash screen without "Limited)" because this is wrapped to the second line, but that line is then overwritten with "License expires..."
  
  sMyText = RemoveString(Text, Chr(13))
  nLFPos = FindString(sMyText, Chr(10))
  If nLFPos > 0
    sTextLeft = Trim(Left(sMyText, nLFPos-1))
    WrapTextLeft(X,Y,sTextLeft,Width,nFrontColor,nBackColor)
    sTextRight = Trim(Mid(sMyText, nLFPos+1))
    WrapTextLeft(X,Y+TextHeight("|"),sTextRight,Width,nFrontColor,nBackColor)
  Else
    nTextWidth = TextWidth(sMyText)
    If nTextWidth <= Width
      ; debugMsg(sProcName, "calling DrawText(" + Y + ", " + Y + ", " + sMyText)
      DrawText(X,Y,sMyText, nFrontColor, nBackColor)
      WrapTextAddLine(sMyText)
    Else
      nLimit = 0
      Repeat
        nLimit + 1
      Until TextWidth(Left(sMyText,nLimit)) > Width 
      nCut = nLimit
      Repeat 
        nCut - 1 
      Until Mid(sMyText,nCut,1) = " " Or Mid(sMyText,nCut,1) = "-" Or nCut = 0
      If nCut = 0 
        nCut = nLimit - 1 
      EndIf
      sTextLeft = Trim(Left(sMyText,nCut))
      ; nTextWidth = TextWidth(sTextLeft)
      ; nLeft = (Width - nTextWidth) >> 1
      ; debugMsg(sProcName, "calling DrawText(" + Y + ", " + Y + ", " + sTextLeft)
      DrawText(X,Y,sTextLeft,nFrontColor,nBackColor)
      WrapTextAddLine(sTextLeft)
      WrapTextLeft(X,Y+TextHeight("|"),Trim(Mid(sMyText,nCut+1)),Width,nFrontColor,nBackColor)
    EndIf
  EndIf
  ; debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure getToolBarBtnMenuEquivalent(nBtnId)
  Protected nMenuItem = -1
  
  If grOperModeOptions(gnOperMode)\nMainToolBarInfo = #SCS_TOOL_DISPLAY_NONE
    Select nBtnId
      Case #SCS_TBMB_GO
        nMenuItem = #WMN_mnuGo
      Case #SCS_TBMB_STANDBY_GO
        nMenuItem = #WMN_mnuStandbyGo
      Case #SCS_TBMB_STOP_ALL
        nMenuItem = #WMN_mnuStopAll
      Case #SCS_TBMB_FADE_ALL ; added 21Mar2020 11.8.2.3ad
        nMenuItem = #WMN_mnuFadeAll
    EndSelect
  EndIf
  ProcedureReturn nMenuItem
EndProcedure

Procedure createToolBarBtnIcon(nBtnId, hImage, sCaption.s, bEnabled)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  Protected nBarId, nCatId
  Protected nBtnWidth, nBtnHeight
  Protected hThisArrowImage
  Protected nTextLeft, nTextWidth
  Protected nMyImage
  
  If IsImage(hImage) = #False
    ProcedureReturn 0
  EndIf
  
  With gaToolBarBtn(nBtnId)
    nCatId = \nCatId
    nBarId = gaToolBarCat(nCatId)\nBarId
    nBtnWidth = \nBtnWidth - 1
    nBtnHeight = gaToolBarCat(nCatId)\nBtnHeight
    
    If bEnabled
      hThisArrowImage = hToolMoreEn
    Else
      hThisArrowImage = hToolMoreDi
    EndIf
    
    nMyImage = CreateImage(#PB_Any, nBtnWidth, nBtnHeight, 32 | #PB_Image_Transparent)
    logCreateImage(20, nMyImage)
    If StartDrawing(CanvasOutput(\cvsToolBtn))
      ; draw button image
      If IsImage(hImage)
        DrawAlphaImage(ImageID(hImage), (nBtnWidth-\nImgWidth)>>1, 0) ;, \nImgWidth, \nImgHeight)
      EndIf
      ; ignore 'bold' request
      DrawingFont(FontID(gaToolBar(nBarId)\nFontNormal))
      ; button caption
      nTextWidth = TextWidth(sCaption)
      If nTextWidth < nBtnWidth
        nTextLeft = (nBtnWidth - nTextWidth) >> 1
      Else
        nTextLeft = 0
      EndIf
      WrapTextInit()
      WrapTextCenter(0,\nImgHeight, sCaption, nBtnWidth, grToolBarColors\nBtnTextColor, grToolBarColors\nBtnColor)
      ; 'more' indicator
      If \bBtnMore
        If IsImage(hThisArrowImage)
          DrawAlphaImage(ImageID(hThisArrowImage), (nBtnWidth-9)/2.0, nBtnHeight-7) ;, 9, 6)
          debugMsg(sProcName, "DrawAlphaImage(ImageID(hThisArrowImage), " + Str((nBtnWidth-9)/2.0) + ", " + Str(nBtnHeight-7) + ")")
        EndIf
      EndIf
      StopDrawing()
    EndIf
    
  EndWith
  
  ProcedureReturn nMyImage
EndProcedure

Procedure drawToolBarBtn(nBtnId, nBtnLeft=-1)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  Protected nBarId, nCatId
  Protected nBtnTop, nBtnWidth, nBtnHeight  ; nb nBtnLeft passed in as a parameter
  Protected hThisImage, hThisArrowImage, sThisCaption.s, sThisTooltip.s
  Protected nReqdBtnColor
  
  ; debugMsg(sProcName, #SCS_START + ", nBtnId=" + Str(nBtnId) + ", nBtnLeft=" + Str(nBtnLeft))
  
  With gaToolBarBtn(nBtnId)
    ; debugMsg(sProcName, "\sBtnCaption1=" + \sBtnCaption1 + ", \sBtnCaption2=" + \sBtnCaption2 + ", \bVisible=" + strB(\bVisible) + ", \nBtnWidth=" + \nBtnWidth + ", \bEnabled=" + strB(\bEnabled))
    If \bBtnVisible = #False Or \nBtnId = 0
      ProcedureReturn
    EndIf
    nCatId = \nCatId
    nBarId = gaToolBarCat(nCatId)\nBarId
    nBtnTop = gaToolBarCat(nCatId)\nBtnTop
    nBtnWidth = \nBtnWidth - 1
    nBtnHeight = gaToolBarCat(nCatId)\nBtnHeight
    If \bBtnMouseOver And \bBtnEnabled
      nReqdBtnColor = grToolBarColors\nBtnColorMouseOver
    Else
      nReqdBtnColor = grToolBarColors\nBtnColor
    EndIf
    
    If nBtnLeft >= 0  ; if -ve then assume button gadget already exists and we just need to redraw the content
      If IsGadget(\cvsToolBtn) = #False
        \cvsToolBtn = scsCanvasGadget(nBtnLeft, nBtnTop, nBtnWidth, nBtnHeight, 0, "cvsToolBtn[" + nBtnId + "]", 0, #SCS_GTYPE_TOOLBAR_BTN)
        gaGadgetProps(getGadgetPropsIndex(\cvsToolBtn))\nResizeFlags = #SCS_RESIZE_IGNORE
        gaGadgetProps(getGadgetPropsIndex(\cvsToolBtn))\nToolBarBtnId = nBtnId
      Else
        ResizeGadget(\cvsToolBtn, nBtnLeft, nBtnTop, nBtnWidth, nBtnHeight)
      EndIf
      \nBtnLeft = nBtnLeft
    EndIf
    
    If IsGadget(\cvsToolBtn) = #False
      ; button gadget does not exist and was not created, so exit (shouldn't happen)
      ProcedureReturn
    EndIf
    
    If \bPicture2Displayed = #False
      If \bBtnEnabled
        hThisImage = \hBtnPicture1En
        hThisArrowImage = hToolMoreEn
      Else
        hThisImage = \hBtnPicture1Di
        hThisArrowImage = hToolMoreDi
      EndIf
      sThisCaption = \sBtnCaption1
      sThisTooltip = \sBtnTooltip1
    Else
      If \bBtnEnabled
        hThisImage = \hBtnPicture2En
      Else
        hThisImage = \hBtnPicture2Di
      EndIf
      sThisCaption = \sBtnCaption2
      sThisTooltip = \sBtnTooltip2
    EndIf
    
    ; debugMsg(sProcName, "sThisCaption=" + sThisCaption + ", nBtnWidth=" + Str(nBtnWidth) + ", nBtnHeight=" + Str(nBtnHeight))
    If StartDrawing(CanvasOutput(\cvsToolBtn))
      ; fill button background
      DrawingMode(#PB_2DDrawing_Default)
      Box(0, 0, nBtnWidth, nBtnHeight, nReqdBtnColor)
      ; draw button image
      If IsImage(hThisImage)
        DrawAlphaImage(ImageID(hThisImage), (nBtnWidth-\nImgWidth)>>1, nBtnTop)
        ; debugMsg(sProcName, "\nImgWidth=" + \nImgWidth + ", \nImgHeight=" + \nImgHeight + ", DrawAlphaImage(ImageID(hThisImage), " + Str((nBtnWidth-\nImgWidth)>>1) + ", " + nBtnTop + ")")
      EndIf
      ; ignore 'bold' request
      DrawingFont(FontID(gaToolBar(nBarId)\nFontNormal))
      ; button caption
      WrapTextInit()
      WrapTextCenter(0, nBtnTop+\nImgHeight, sThisCaption, nBtnWidth, grToolBarColors\nBtnTextColor, nReqdBtnColor, #True)
      ; #True for bNonBreakingHyphens in above call prevents "Sub-Cue" being split onto two lines
      If gnWrapTextLineCount > 2
        If Len(sThisTooltip) = 0
          sThisTooltip = gsUnwrappedText
        EndIf
      EndIf
      ; 'more' indicator
      If \bBtnMore
        If IsImage(hThisArrowImage)
          DrawAlphaImage(ImageID(hThisArrowImage), (nBtnWidth-9)/2, nBtnHeight-7)
        EndIf
      EndIf
      StopDrawing()
    EndIf
    
    If sThisTooltip
      scsToolTip(\cvsToolBtn, sThisTooltip)
    EndIf
    
    setVisible(\cvsToolBtn, #True)
    setEnabled(\cvsToolBtn, \bBtnEnabled)
    
  EndWith
  
EndProcedure

Procedure drawToolBarCat(nCatId, nCatLeft)
  PROCNAME(#PB_Compiler_Procedure + "[" + nCatId + "]")
  Protected nBarId
  Protected nCatTop, nCatHeight
  Protected nCatReqdWidth
  Protected nBtnDisplayOrder
  Protected n, nThisBtnLeft, nBtnWidth
  Protected nTextLeft, nTextTop, nTextWidth, nTextHeight
  Protected nOldGadgetList
  Protected nGadgetPropsIndex
  Protected nNextX, nImageTop
  Protected nReqdCatColor
  
  ; debugMsg(sProcName, #SCS_START + ", nCatId=" + Str(nCatId))
  
  With gaToolBarCat(nCatId)
    ; debugMsg(sProcName, "category \sCaption=" + \sCaption)
    nBarId = \nBarId
    nCatTop = gaToolBar(nBarId)\nCatTop
    nCatHeight = gaToolBar(nBarId)\nCatHeight
    If \bCatMouseOver And \bCatEnabled
      nReqdCatColor = grToolBarColors\nCatColorMouseOver
    Else
      nReqdCatColor = grToolBarColors\nCatColor
    EndIf
    
    If IsGadget(\cntToolCat) = #False
      \cntToolCat = scsContainerGadget(nCatLeft, nCatTop, \nCatMinWidth, nCatHeight, #PB_Container_Flat, "cntToolCat[" + nCatId + "]", 0)
        nGadgetPropsIndex = getGadgetPropsIndex(\cntToolCat)
        gaGadgetProps(nGadgetPropsIndex)\nToolBarCatId = nCatId
        gaGadgetProps(nGadgetPropsIndex)\nResizeFlags = #SCS_RESIZE_IGNORE
      scsCloseGadgetList()
    Else
      ResizeGadget(\cntToolCat, nCatLeft, nCatTop, \nCatMinWidth, nCatHeight)
      CompilerIf #cTraceGadgets
        debugMsg(sProcName, "ResizeGadget(" + getGadgetName(\cntToolCat, #False) + ", " + nCatLeft + ", " + nCatTop + ", " + \nCatMinWidth + ", " + nCatHeight + ")")
      CompilerEndIf
    EndIf
    SetGadgetColor(\cntToolCat, #PB_Gadget_BackColor, nReqdCatColor)
    \nCatLeft = nCatLeft
  EndWith
  
  nOldGadgetList = scsUseGadgetList(GadgetID(gaToolBarCat(nCatId)\cntToolCat), gaToolBarCat(nCatId)\cntToolCat)

  ; hide any existing buttons
  For n = 0 To #SCS_TBZB_DUMMY_LAST
    With gaToolBarBtn(n)
      If \nCatId = nCatId
        If IsGadget(\cvsToolBtn)
          setVisible(\cvsToolBtn, #False)
        EndIf
      EndIf
    EndWith
  Next n

  ; now display required buttons
  nThisBtnLeft = gaToolBarCat(nCatId)\nBtnLeft   ; left position of first displayed button in category
  ; debugMsg(sProcName, "gaToolBarCat(" + Str(nCatId) + ")\nBtnCount=" + Str(gaToolBarCat(nCatId)\nBtnCount) + ", \sCaption=" + gaToolBarCat(nCatId)\sCaption)
  For nBtnDisplayOrder = 1 To gaToolBarCat(nCatId)\nBtnCount
    For n = 0 To #SCS_TBZB_DUMMY_LAST
      With gaToolBarBtn(n)
        If (\nCatId = nCatId) And (\nBtnDisplayOrder = nBtnDisplayOrder) And (\bBtnVisible)
          drawToolBarBtn(\nBtnId, nThisBtnLeft)
          nThisBtnLeft + \nBtnWidth
          Break
        EndIf
      EndWith
    Next n
  Next nBtnDisplayOrder
  
  With gaToolBarCat(nCatId)
    nCatReqdWidth = nThisBtnLeft + 3
    If nCatReqdWidth < \nCatMinWidth
      nCatReqdWidth = \nCatMinWidth
    EndIf
    ResizeGadget(\cntToolCat, #PB_Ignore, #PB_Ignore, nCatReqdWidth, #PB_Ignore)
    CompilerIf #cTraceGadgets
      debugMsg(sProcName, "ResizeGadget(" + getGadgetName(\cntToolCat, #False) + ", #PB_Ignore, #PB_Ignore, " + nCatReqdWidth + ", #PB_Ignore)")
    CompilerEndIf
    
    ; category caption
    If IsGadget(\cvsCatCaption) = #False
      \cvsCatCaption = scsCanvasGadget(0, nCatHeight-(#SCS_TBN_CAT_CAPTION_HEIGHT+2), nCatReqdWidth, #SCS_TBN_CAT_CAPTION_HEIGHT, 0, "cvsCatCaption[" + Str(nCatId) + "]", 0, #SCS_GTYPE_TOOLBAR_CAT)
      nGadgetPropsIndex = getGadgetPropsIndex(\cvsCatCaption)
      gaGadgetProps(nGadgetPropsIndex)\nToolBarCatId = nCatId
      gaGadgetProps(nGadgetPropsIndex)\nResizeFlags = #SCS_RESIZE_IGNORE
    Else
      ResizeGadget(\cvsCatCaption, #PB_Ignore, #PB_Ignore, nCatReqdWidth, #PB_Ignore)
    EndIf
    If StartDrawing(CanvasOutput(\cvsCatCaption))
      Box(0, 0, nCatReqdWidth, #SCS_TBN_CAT_CAPTION_HEIGHT, nReqdCatColor)
      DrawingFont(FontID(gaToolBar(nBarId)\nFontNormal))
      nTextWidth = TextWidth(\sCaption)
      If \bCatMore
        nTextWidth + (ImageWidth(hToolCatMoreEn) + 4)  ; 4 is separator width
      EndIf
      If nTextWidth < nCatReqdWidth
        nTextLeft = (nCatReqdWidth - nTextWidth) >> 1
      Else
        nTextLeft = 0
      EndIf
      nTextHeight = TextHeight("Qy")
      If nTextHeight < #SCS_TBN_CAT_CAPTION_HEIGHT
        nTextTop = (#SCS_TBN_CAT_CAPTION_HEIGHT - nTextHeight) / 2
      Else
        nTextTop = 0
      EndIf
      nNextX = DrawText(nTextLeft, nTextTop, \sCaption, grToolBarColors\nCatTextColor, nReqdCatColor)
      If \bCatMore
        nImageTop = #SCS_TBN_CAT_CAPTION_HEIGHT - ImageHeight(hToolCatMoreEn) - 2
        DrawAlphaImage(ImageID(hToolCatMoreEn), nNextX+4, nImageTop)
      EndIf
      StopDrawing()
    EndIf
    
    \nCatWidth = nCatReqdWidth
    
  EndWith
  
  scsUseGadgetList(nOldGadgetList)   ; return to previous GadgetList
  
EndProcedure

Procedure drawToolBar(nBarId)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBarId + "]")
  Protected nCatDisplayOrder
  Protected nBarReqdWidth
  Protected n, nThisCatLeft
  Protected nOldGadgetList
  
  ; debugMsg(sProcName, #SCS_START)
  
  With gaToolBar(nBarId)
    If IsGadget(\cntToolBar) = #False
      \cntToolBar = scsContainerGadget(\nBarLeft, \nBarTop, \nBarWidth, \nBarHeight, 0, "cntToolBar[" + Str(nBarId) + "]")
        gaGadgetProps(getGadgetPropsIndex(\cntToolBar))\nResizeFlags = #SCS_RESIZE_IGNORE
      scsCloseGadgetList()
    Else
      ResizeGadget(\cntToolBar,\nBarLeft,\nBarTop,\nBarWidth,\nBarHeight)
    EndIf
    SetGadgetColor(\cntToolBar, #PB_Gadget_BackColor, grToolBarColors\nCntColor)
  EndWith
  
  nOldGadgetList = scsUseGadgetList(GadgetID(gaToolBar(nBarId)\cntToolBar), gaToolBar(nBarId)\cntToolBar)
  
  nThisCatLeft = gaToolBar(nBarId)\nCatLeft   ; left position of first displayed category in toolbar
  For nCatDisplayOrder = 1 To gaToolBar(nBarId)\nCatCount
    For n = 0 To #SCS_TBZC_DUMMY_LAST
      With gaToolBarCat(n)
        If (\nBarId = nBarId) And (\nCatDisplayOrder = nCatDisplayOrder) And (\bCatVisible)
          ; debugMsg(sProcName, "calling drawToolBarCat(" + \nCatId + ", " + nThisCatLeft + "), nBarId=" + nBarId + ", nCatDisplayOrder=" + nCatDisplayOrder)
          drawToolBarCat(\nCatId, nThisCatLeft)
          nThisCatLeft + \nCatWidth
          Break
        EndIf
      EndWith
    Next n
  Next nCatDisplayOrder
  
  scsUseGadgetList(nOldGadgetList)   ; return to previous GadgetList
  
  With gaToolBar(nBarId)
    nBarReqdWidth = nThisCatLeft + 1
    If nBarReqdWidth < \nBarMinWidth
      nBarReqdWidth = \nBarMinWidth
    EndIf
    ResizeGadget(\cntToolBar, #PB_Ignore, #PB_Ignore, nBarReqdWidth, #PB_Ignore)
    \nBarWidth = nBarReqdWidth
  EndWith
  
EndProcedure

Procedure addToolBar(nBarId, nLeft, nTop, nWidth, nHeight, nHostId, nFontNormal=#SCS_FONT_GEN_NORMAL, nFontBold=#SCS_FONT_GEN_BOLD)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBarId + "]")
  
  ; debugMsg(sProcName, #SCS_START)

  With gaToolBar(nBarId)
    \nBarId = nBarId
    \nHostId = nHostId  ; see comment about nHostId under 'Structure tyToolBar'
    \nBarLeft = nLeft
    \nBarTop = nTop
    \nBarWidth = nWidth
    \nBarHeight = nHeight
    \nFontNormal = nFontNormal
    \nFontBold = nFontBold
    
    \nCatCount = 0
    \nCatTop = 1
    \nCatLeft = 1
    \nCatHeight = gaToolBar(nBarId)\nBarHeight - (\nCatTop*2)
    ; debugMsg(sProcName, "gaToolBar(" + Str(nBarId) + ")\nBarHeight=" + Str(\nBarHeight) + ", \nCatHeight=" + Str(\nCatHeight))
    
    ; create container gadget now, rather than waiting for drawToolBar(), as we need to return the toolbar's gadget no.
    If IsGadget(\cntToolBar) = #False
      \cntToolBar = scsContainerGadget(\nBarLeft, \nBarTop, \nBarWidth, \nBarHeight, 0, "cntToolBar[" + Str(nBarId) + "]", 0)
        gaGadgetProps(getGadgetPropsIndex(\cntToolBar))\nResizeFlags = #SCS_RESIZE_IGNORE
        SetGadgetColor(\cntToolBar, #PB_Gadget_BackColor, grToolBarColors\nCntColor)
      scsCloseGadgetList()
    EndIf
    
  EndWith
  
  ProcedureReturn gaToolBar(nBarId)\cntToolBar
  
EndProcedure

Procedure deleteToolBar(nBarId)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBarId + "]")
  Protected n, n2, nCatId
  
  With gaToolBar(nBarId)
    If IsGadget(\cntToolBar)
      scsFreeGadget(\cntToolBar)
      debugMsg(sProcName, "scsFreeGadget(G" + \cntToolBar + ")")
      For n = 0 To #SCS_TBZC_DUMMY_LAST
        If gaToolBarCat(n)\nBarId = nBarId
          nCatId = gaToolBarCat(n)\nCatId
          For n2 = 0 To #SCS_TBZB_DUMMY_LAST
            If gaToolBarBtn(n2)\nCatId = nCatId
              gaToolBarBtn(n2)\bBtnVisible = #False
            EndIf
          Next n2
          gaToolBarCat(n)\bCatVisible = #False
        EndIf
      Next n
      \cntToolBar = 0
    EndIf
  EndWith
  
EndProcedure

Procedure addToolBarCat(nCatId, nBarId, sCaption.s, pMinWidth=-1, bVisible=#True, bMore=#False)
  PROCNAMEC()
  Protected nMinWidth
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, #SCS_START + ", nCatId=" + nCatId + ", nBarId=" + nBarId + ", sCaption=" + sCaption + ", pMinWidth=" + pMinWidth)
  CompilerEndIf
  
  nMinWidth = pMinWidth
  If nMinWidth = -1
    nMinWidth = 40
  EndIf
  
  With gaToolBarCat(nCatId)
    \nCatId = nCatId
    \nBarId = nBarId
    \sCaption = RemoveString(sCaption, "...")
    \nCatMinWidth = nMinWidth
    \bCatVisible = bVisible
    \bCatMore = bMore
    If bMore
      \bCatEnabled = #True
    Else
      \bCatEnabled = #False
    EndIf
    gaToolBar(nBarId)\nCatCount + 1
    \nCatDisplayOrder = gaToolBar(nBarId)\nCatCount
    \nBtnCount = 0
    \nBtnLeft = 2     ; left position of first displayed button in category
    \nBtnTop = 1
    \nBtnHeight = (gaToolBar(nBarId)\nCatHeight - (\nBtnTop << 1) - #SCS_TBN_CAT_CAPTION_HEIGHT - 2) ; #SCS_TBN_CAT_CAPTION_HEIGHT for height of caption; -2 to allow for border
    ; debugMsg(sProcName, "gaToolBarCat(" + Str(nCatId) + ")\nBtnHeight=" + Str(\nBtnHeight))
  EndWith

EndProcedure

Procedure addToolBarBtn(nBtnId, nCatId, hImage1En, hImage1Di, sCaption1.s, sToolTip1.s="", pBtnWidth=-1, pImgWidth=-1, pImgHeight=-1, bMore=#False, bFontBold=#False, bEnabled=#True, bVisible=#True)
  PROCNAMEC()
  Protected nBtnWidth, nMinBtnWidth
  Protected nImgWidth, nImgHeight
  Protected nBarId, nFontNo, nTextWidth
  Protected sText.s, nWordCount, nWordNo
  Protected sLine.s, nLineCount, nLineNo, nLineLength
  Protected Dim sWord.s(0)
  Protected Dim nWordLength(0)
  Protected nSpaceLength
  
  ; changes made 14Feb2017 11.6.0 to allow for setting the minimum button width according to the language translation of the button text, following email from Lluís Vilarrasa
  
  CompilerIf #cTraceGadgets
    debugMsg(sProcName, #SCS_START + ", nBtnId=" + nBtnId + ", nCatId=" + nCatId + ", hImage1En=" + hImage1En + ", hImage1Di=" + hImage1Di + ", pBtnWidth=" + pBtnWidth + ", sCaption1=" + ReplaceString(sCaption1, Chr(10), "\n"))
  CompilerEndIf
  
  nBtnWidth = pBtnWidth
  nImgWidth = pImgWidth
  nImgHeight = pImgHeight
  
  nBarId = gaToolBarCat(nCatId)\nBarId
  If bFontBold
    nFontNo = gaToolBar(nBarId)\nFontBold
  Else
    nFontNo = gaToolBar(nBarId)\nFontNormal
  EndIf
  
  sText = sCaption1
  
  Select pBtnWidth
    Case -1
      ; -1 = use 44
      nBtnWidth = 44
      
    Case -2, -3, -265, -365, -275, -375
      ; -2 = calculate width for a one-line caption, minimum 44
      ; -3 = calculate width for a two-line caption, minimum 44
      ; -265 = calculate width for a one-line caption, minimum 65
      ; -365 = calculate width for a two-line caption, minimum 65
      ; -275 = calculate width for a one-line caption, minimum 75
      ; -375 = calculate width for a two-line caption, minimum 75
      sText = Trim(ReplaceString(sText, "/", "/ ")) ; Added to enable button captions like "Add Video/Image Cue" to be possibly split over two lines, with "Video/" and "Image" being treated as two separate words.
      sText = Trim(ReplaceString(sText, Chr(10), " "))
      nWordCount = CountString(sText, " ") + 1
      ; debugMsg(sProcName, "pBtnWidth=" + pBtnWidth + ", sCaption1=" + #DQUOTE$ + sCaption1 + #DQUOTE$ + ", sText=" + #DQUOTE$ + sText + #DQUOTE$ + ", nWordCount=" + nWordCount)
      If pBtnWidth = -2 Or nWordCount = 1
        nTextWidth = GetTextWidth(sText, nFontNo)
      Else
        ReDim sWord(nWordCount)
        ReDim nWordLength(nWordCount)
        For nWordNo = 1 To nWordCount
          sWord(nWordNo) = StringField(sText, nWordNo, " ")
          nWordLength(nWordNo) = GetTextWidth(sWord(nWordNo), nFontNo)
        Next nWordNo
        nSpaceLength = GetTextWidth(" ", nFontNo)
        Select nWordCount
          Case 2
            If nWordLength(1) > nWordLength(2)
              nTextWidth = nWordLength(1)
            Else
              nTextWidth = nWordLength(2)
            EndIf
          Case 3
            If (nWordLength(1) + nWordLength(2)) > (nWordLength(2) + nWordLength(3))
              nTextWidth = nWordLength(1) + nWordLength(2) + nSpaceLength
            Else
              nTextWidth = nWordLength(2) + nWordLength(3) + nSpaceLength
            EndIf
          Case 4
            If (nWordLength(1) + nWordLength(2)) > (nWordLength(3) + nWordLength(4))
              nTextWidth = nWordLength(1) + nWordLength(2) + nSpaceLength
            Else
              nTextWidth = nWordLength(3) + nWordLength(4) + nSpaceLength
            EndIf
          Default
            nTextWidth = (GetTextWidth(sText, nFontNo) / 2) + 8  ; + 8 just for 'safety'
        EndSelect
      EndIf
      nMinBtnWidth = nTextWidth + 6
      Select pBtnWidth
        Case -265, -365
          nBtnWidth = 65
        Case -275, -375
          nBtnWidth = 75
        Default
          nBtnWidth = 44
      EndSelect
      If nMinBtnWidth > nBtnWidth
        nBtnWidth = nMinBtnWidth
      EndIf
      ; debugMsg(sProcName, "sText=" + ReplaceString(sText, Chr(10), "\n") + ", pBtnWidth=" + pBtnWidth + ", nTextWidth=" + nTextWidth + ", nWordCount=" + nWordCount + ", nMinBtnWidth=" + nMinBtnWidth + ", nBtnWidth=" + nBtnWidth)
      
    Case -4
      ; -4 = calculate button width based on the length of the longest line, minimum 44
      nBtnWidth = 44
      nLineCount = CountString(sText, Chr(10)) + 1
      For nLineNo = 1 To nLineCount
        sLine = StringField(sText, nLineNo, Chr(10))
        nLineLength = GetTextWidth(sLine, nFontNo) + 8
        If nLineLength > nBtnWidth
          nBtnWidth = nLineLength
        EndIf
      Next nLineNo
      ; debugMsg(sProcName, "sText=" + ReplaceString(sText, Chr(10), "\n") + ", pBtnWidth=" + pBtnWidth + ", nLineCount=" + nLineCount + ", nBtnWidth=" + nBtnWidth)
      
  EndSelect
  
  If nImgWidth = -1
    nImgWidth = 24
  EndIf
  
  If nImgHeight = -1
    nImgHeight = 24
  EndIf
  
  ; debugMsg(sProcName, "nBtnId=" + Str(nBtnId) + ", nCatId=" + nCatId + ", sText=" + sText)
  With gaToolBarBtn(nBtnId)
    \nBtnId = nBtnId
    \nCatId = nCatId
    \nBtnWidth = nBtnWidth
    \nImgWidth = nImgWidth
    \nImgHeight = nImgHeight
    gaToolBarCat(nCatId)\nBtnCount + 1
    \nBtnDisplayOrder = gaToolBarCat(nCatId)\nBtnCount
    \hBtnPicture1En = hImage1En
    \hBtnPicture1Di = hImage1Di
    \sBtnCaption1 = RemoveString(sText, "...")
    \sBtnTooltip1 = sToolTip1
    \bBtnMore = bMore
    \bFontBold = bFontBold
    \bBtnEnabled = bEnabled
    \bBtnVisible = bVisible
  EndWith
  
EndProcedure

Procedure addToolBarBtnH(nBtnId, nCatId, hImage1En, hImage1Di, sCaption1.s, sToolTip1.s="", pBtnWidth=-1, pImgWidth=-1, pImgHeight=-1, bMore=#False, bFontBold=#False, bEnabled=#True)
  ; shortcut for addToolBarBtn() with bVisible=#False.
  addToolBarBtn(nBtnId, nCatId, hImage1En, hImage1Di, sCaption1, sToolTip1, pBtnWidth, pImgWidth, pImgHeight, bMore, bFontBold, bEnabled, #False)
EndProcedure

Procedure addToolBarBtn2(nBtnId, hImage2En, hImage2Di, sCaption2.s, sToolTip2.s)
  With gaToolBarBtn(nBtnId)
    \hBtnPicture2En = hImage2En
    \hBtnPicture2Di = hImage2Di
    \sBtnCaption2 = RemoveString(sCaption2, "...")
    \sBtnTooltip2 = sToolTip2
  EndWith
EndProcedure

Procedure setToolBarBtnCaption(nBtnId, sCaption.s)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  Protected sBtnCaption.s
  
  With gaToolBarBtn(nBtnId)
    sBtnCaption = RemoveString(sCaption, "...")
    If \sBtnCaption1 <> sBtnCaption
      ; debugMsg(sProcName, "sCaption=" + ReplaceString(sCaption, Chr(10), "<LF>"))
      \sBtnCaption1 = sBtnCaption
      drawToolBarBtn(nBtnId)
    EndIf
  EndWith
EndProcedure

Procedure.s getToolBarBtnCaption(nBtnId)
  ProcedureReturn gaToolBarBtn(nBtnId)\sBtnCaption1
EndProcedure

Procedure setToolBarCatMouseOver(nCatId, nEventType)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  ; debugMsg(sProcName, "sCaption=" + sCaption)
  With gaToolBarCat(nCatId)
    If nEventType = #PB_EventType_MouseEnter
      \bCatMouseOver = #True
      drawToolBarCat(nCatId, \nCatLeft)
    ElseIf nEventType = #PB_EventType_MouseLeave
      \bCatMouseOver = #False
      drawToolBarCat(nCatId, \nCatLeft)
    EndIf
  EndWith
EndProcedure

Procedure setToolBarBtnMouseOver(nBtnId, nEventType)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  ; debugMsg(sProcName, "sCaption=" + sCaption)
  With gaToolBarBtn(nBtnId)
    If nEventType = #PB_EventType_MouseEnter
      \bBtnMouseOver = #True
      drawToolBarBtn(nBtnId)
    ElseIf nEventType = #PB_EventType_MouseLeave
      \bBtnMouseOver = #False
      drawToolBarBtn(nBtnId)
    EndIf
  EndWith
EndProcedure

Procedure setToolBarBtnEnabled(nBtnId, bEnable, bForceSetting=#False)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  Protected nMenuEquivalent
  
  With gaToolBarBtn(nBtnId)
    If (\bBtnEnabled <> bEnable) Or (bForceSetting)
      If \bBtnEnabled <> bEnable
        \bBtnEnabled = bEnable
        drawToolBarBtn(nBtnId)
      EndIf
    EndIf
    ; added 11Nov2019 11.8.2rc1
    nMenuEquivalent = getToolBarBtnMenuEquivalent(nBtnId)
    If nMenuEquivalent >= 0
      scsEnableMenuItem(#WMN_mnuWindowMenu, nMenuEquivalent, bEnable)
    EndIf
    ; end added 11Nov2019 11.8.2rc1
  EndWith
EndProcedure

Procedure setToolBarCurrentImageIndex(nBtnId, nPicIndex)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  
  ; debugMsg(sProcName, "nPicIndex=" + Str(nPicIndex))
  With gaToolBarBtn(nBtnId)
    If nPicIndex = 0
      \bPicture2Displayed = #False
    Else
      \bPicture2Displayed = #True
    EndIf
    drawToolBarBtn(nBtnId)
  EndWith
EndProcedure

Procedure setToolBarBtnToolTip(nBtnId, sToolTip.s)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  ; debugMsg(sProcName, "sToolTip=" + sToolTip)
  With gaToolBarBtn(nBtnId)
    \sBtnTooltip1 = sToolTip
    drawToolBarBtn(nBtnId)
  EndWith
EndProcedure

Procedure setToolBarBtnVisible(nBtnId, bVisible, bSuppressDraw=#False)
  ; PROCNAME(#PB_Compiler_Procedure + "[" + nBtnId + "]")
  Protected nBarId
  
  ; debugMsg(sProcName, "bVisible=" + strB(bVisible))
  With gaToolBarBtn(nBtnId)
    If \bBtnVisible <> bVisible
      \bBtnVisible = bVisible
      ; since we have change the 'visible' status of a button, we need to redraw the entire toolbar
      nBarId = gaToolBarCat(\nCatId)\nBarId
      If bSuppressDraw = #False
        ; debugMsg(sProcName, "calling drawToolBar(" + Str(nBarId) + ")")
        drawToolBar(nBarId) 
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure getToolBarBtnEnabled(nBtnId)
  ; PROCNAME("getToolBarBtnEnabled[" + nBtnId + "]")
  ; debugMsg(sProcName, "gaToolBarBtn(" + nBtnId + ")\bEnabled=" + strB(gaToolBarBtn(nBtnId)\bEnabled))
  
  ProcedureReturn gaToolBarBtn(nBtnId)\bBtnEnabled
EndProcedure

Procedure getToolBarBtnLeft(nBtnId)
  Protected nCatId, nLeft
  
  nCatId = gaToolBarBtn(nBtnId)\nCatId
  nLeft = gaToolBarCat(nCatId)\nCatLeft + gaToolBarBtn(nBtnId)\nBtnLeft
  ProcedureReturn nLeft
EndProcedure

Procedure getToolBarBtnTop(nBtnId)
  Protected nCatId
  
  nCatId = gaToolBarBtn(nBtnId)\nCatId
  ProcedureReturn gaToolBarCat(nCatId)\nBtnTop
EndProcedure

Procedure getToolBarBtnWidth(nBtnId)
  ProcedureReturn gaToolBarBtn(nBtnId)\nBtnWidth
EndProcedure

Procedure getToolBarBtnHeight(nBtnId)
  Protected nCatId
  
  nCatId = gaToolBarBtn(nBtnId)\nCatId
  ProcedureReturn gaToolBarCat(nCatId)\nBtnHeight
EndProcedure

Procedure setToolBarWidth(nBarId, nWidth)
  PROCNAME(#PB_Compiler_Procedure + "[" + nBarId + "]")
  
  ASSERT_THREAD(#SCS_THREAD_MAIN) ; procedure resizes gadgets
  
  With gaToolBar(nBarId)
    \nBarWidth = nWidth
    debugMsg(sProcName, "calling drawToolBar(" + Str(nBarId) + ")")
    drawToolBar(nBarId)
  EndWith
EndProcedure

Procedure getToolBarCatTop(nBarId)
  ProcedureReturn gaToolBar(nBarId)\nCatTop
EndProcedure

Procedure getToolBarCatHeight(nBarId)
  ProcedureReturn gaToolBar(nBarId)\nCatHeight
EndProcedure

Procedure.s getToolBarCatCaption(nCatId)
  ProcedureReturn gaToolBarCat(nCatId)\sCaption
EndProcedure

Procedure showEditorFavorites(bSuppressDraw=#False)
  ; PROCNAMEC()
  Protected nBtnId, n, nBtnDisplayOrder
  Protected bFound, bChanged, nFavCount
  
  ; debugMsg(sProcName, #SCS_START + ", bSuppressDraw=" + strB(bSuppressDraw))
  
  For nBtnId = (#SCS_TBEB_FAV_START+1) To (#SCS_TBEB_FAV_END-1)
    With gaToolBarBtn(nBtnId)
      bFound = #False
      For n = 0 To #SCS_MAX_ED_FAV
        If grWED\nFavBtnId[n] = nBtnId
          bFound = #True
          nFavCount + 1
          nBtnDisplayOrder = n + 1
          If (\bBtnVisible = #False) Or (\nBtnDisplayOrder <> nBtnDisplayOrder)
            \bBtnVisible = #True
            \nBtnDisplayOrder = nBtnDisplayOrder
            bChanged = #True
          EndIf
          ; debugMsg(sProcName, "grWED\nFavBtnId[" + n + "] found. nBtnId=" + nBtnId + ", nFavCount=" + nFavCount + ", \nBtnDisplayOrder=" + \nBtnDisplayOrder + ", \bVisible=" + strB(\bVisible))
          Break
        EndIf
      Next n
      If bFound = #False
        If \bBtnVisible
          ; debugMsg(sProcName, "hiding " + n)
          \bBtnVisible = #False
          \nBtnDisplayOrder = 0
          bChanged = #True
        EndIf
      EndIf
    EndWith
  Next nBtnId
  
  ; debugMsg(sProcName, "nFavCount=" + Str(nFavCount))
  With gaToolBarBtn(#SCS_TBEB_FAV_NONE)
    If nFavCount = 0
      \bBtnVisible = #True
      \nBtnDisplayOrder = 1
      \bBtnEnabled = #False
    Else
      \bBtnVisible = #False
      \nBtnDisplayOrder = 0
    EndIf
  EndWith
  
  If (bChanged) Or (nFavCount = 0)
    If bSuppressDraw = #False
      ; debugMsg(sProcName, "calling drawToolBar(#SCS_TBE_EDITOR)")
      drawToolBar(#SCS_TBE_EDITOR)
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF