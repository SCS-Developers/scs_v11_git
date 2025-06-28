; File: fmLoadProd.pbi

EnableExplicit

Procedure WLP_Form_Unload(bCalledFromProcessAction=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", bCalledFromProcessAction=" + strB(bCalledFromProcessAction))
  
  If IsWindow(#WLP)
    scsCloseWindow(#WLP)
    unsetWindowModal(#WLP)
    If IsWindow(#WMN) = #False
      debugMsg(sProcName, "calling WMN_Form_Load")
      WMN_Form_Load()
    EndIf
    grWLP\bWindowActive = #False
    If gbEditing
      debugMsg(sProcName, "calling closeEditor()")
      closeEditor()
    EndIf
    If bCalledFromProcessAction = #False
      If grAction\nAction <> #SCS_ACTION_NONE
        gqMainThreadRequest | #SCS_MTH_PROCESS_ACTION
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_drawNew()
  PROCNAMEC()
  Protected sDevMapName.s
  
  With WLP
    setVisible(\cntNew, #True)
    setVisible(\btnCreateNew, #True)
    SAG(\txtTitle)
    setComboBoxByData(\cboAudioDriver, grLoadProdPrefs\nAudioDriver, 0)
    sDevMapName = Trim(GGT(\txtDevMapName))
    If Len(sDevMapName) = 0
      sDevMapName = grLoadProdPrefs\sDevMapName
      If Len(sDevMapName) = 0
        sDevMapName = GetEnvironmentVariable("computername")
      EndIf
      SGT(\txtDevMapName, Trim(sDevMapName))
    EndIf
  EndWith
  
EndProcedure

Procedure WLP_drawExisting(Index=-1, bMouseOverDelItem=#False)
  PROCNAMEC()
  Protected nBackColor, nTextColor1, nTextColor2, nFont1
  Protected n
  Protected sFileName.s, sTitle.s
  Protected nFileCount
  Protected nReqdInnerHeight
  Protected bEnableOpenButton
  Protected nFromIndex, nUpToIndex
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WLP
    If Index = -1
      nFromIndex = 0
      ; nUpToIndex = ArraySize(\cvsExisting())
      nUpToIndex = gnRecentFileCount - 1
    Else
      nFromIndex = Index
      nUpToIndex = Index
    EndIf
    If nFromIndex > #SCS_MAXRFL_DISPLAYED
      nFromIndex = #SCS_MAXRFL_DISPLAYED
    EndIf
    If nUpToIndex > #SCS_MAXRFL_DISPLAYED
      nUpToIndex = #SCS_MAXRFL_DISPLAYED
    EndIf
    
    If Index = -1
      If nUpToIndex > ArraySize(grWLP\aMouseOverItem())
        ReDim grWLP\aMouseOverItem(nUpToIndex)
        ReDim grWLP\aItemFileName(nUpToIndex)
        ReDim grWLP\aItemName(nUpToIndex)
        ReDim grWLP\aItemTitleOrDesc(nUpToIndex)
      EndIf
      setVisible(\scaFiles, #True)
      setVisible(\btnOpenE, #True)
      setVisible(\btnBrowseE, #True)
      grAction\sSelectedFileName = ""
    EndIf
    For n = nFromIndex To nUpToIndex
      If n = grWLP\nSelectedExisting
        nBackColor = grWLP\nHighBackColor
        nTextColor1 = grWLP\nHighTextColor1
        nTextColor2 = grWLP\nHighTextColor2
        nFont1 = #SCS_FONT_GEN_BOLD10
      Else
        If grWLP\aMouseOverItem(n)
          nBackColor = #SCS_Btn_Hover_Color
        Else
          nBackColor = grWLP\nDfltItemBackColor
        EndIf
        nTextColor1 = grWLP\nDfltTextColor1
        nTextColor2 = grWLP\nDfltTextColor2
        nFont1 = #SCS_FONT_GEN_NORMAL10
      EndIf
      StartDrawing(CanvasOutput(\cvsExisting(n)))
      Box(0, 0, OutputWidth(), OutputHeight(), nBackColor)
      Line(0, OutputHeight()-1, OutputWidth(), 1, #SCS_Light_Grey)
      If Index = -1
        If (n <= ArraySize(gsRecentFile())) And (n < gnRecentFileCount)
          sFileName = gsRecentFile(n)
          grWLP\aItemFileName(n) = sFileName
          ; debugMsg(sProcName, "grWLP\aItemFileName(" + n + ")=" + grWLP\aItemFileName(n))
          If sFileName
            If FileExists(sFileName, #False)
              bEnableOpenButton = #True
              nFileCount + 1
              sTitle = getTitleFromCueFile(sFileName)
              grWLP\aItemTitleOrDesc(n) = sTitle
              DrawingMode(#PB_2DDrawing_Transparent)
              scsDrawingFont(nFont1)
              DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sTitle, nTextColor1)
              scsDrawingFont(#SCS_FONT_GEN_NORMAL)
              DrawText(grWLP\nTextLeft2, grWLP\nTextTop2, sFileName, nTextColor2)
              WLP_drawDelItemX(nTextColor1, nBackColor, bMouseOverDelItem)
              If n = grWLP\nSelectedExisting
                grAction\sSelectedFileName = sFileName
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        sFileName = grWLP\aItemFileName(n)
        sTitle = grWLP\aItemTitleOrDesc(n)
        If sFileName
          bEnableOpenButton = #True
          DrawingMode(#PB_2DDrawing_Transparent)
          scsDrawingFont(nFont1)
          DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sTitle, nTextColor1)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          DrawText(grWLP\nTextLeft2, grWLP\nTextTop2, sFileName, nTextColor2)
          WLP_drawDelItemX(nTextColor1, nBackColor, bMouseOverDelItem)
        EndIf
      EndIf
      StopDrawing()
    Next n
    If Index = -1
      grWLP\nFileCountExisting = nFileCount
      setEnabled(WLP\btnOpenE, bEnableOpenButton)
      ; nb no need to allow for nFileCount = 0 for 'existing' files,
      ; as loadPrefsPart2() will have populated gsRecentFile(0) with the demo cue file if there are no recent files registered,
      ; so nFileCount in this procedure will always be at least 1
      nReqdInnerHeight = nFileCount * GadgetHeight(\cvsExisting(0))
      SetGadgetAttribute(\scaFiles, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
      SetGadgetAttribute(\scaFiles, #PB_ScrollArea_Y, grWLP\nExistingY)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_drawFavorites(Index=-1)
  PROCNAMEC()
  Protected nBackColor, nTextColor1, nTextColor2, nFont1
  Protected n
  Protected sFileName.s, sTitle.s
  Protected nFileCount
  Protected nReqdInnerHeight
  Protected bEnableOpenButton
  Protected nFromIndex, nUpToIndex
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WLP
    If Index = -1
      nFromIndex = 0
      ; nUpToIndex = ArraySize(\cvsFavorite())
      nUpToIndex = gnFavFileCount - 1
    Else
      nFromIndex = Index
      nUpToIndex = Index
    EndIf
    
    If Index = -1
      If nUpToIndex > ArraySize(grWLP\aMouseOverItem())
        ReDim grWLP\aMouseOverItem(nUpToIndex)
        ReDim grWLP\aItemFileName(nUpToIndex)
        ReDim grWLP\aItemName(nUpToIndex)
        ReDim grWLP\aItemTitleOrDesc(nUpToIndex)
      EndIf
      setVisible(\scaFavorites, #True)
      setVisible(\btnOpenF, #True)
      setVisible(\btnManageF, #True)
      grAction\sSelectedFileName = ""
    EndIf
    
    For n = nFromIndex To nUpToIndex
      If n = grWLP\nSelectedFavorite
        nBackColor = grWLP\nHighBackColor
        nTextColor1 = grWLP\nHighTextColor1
        nTextColor2 = grWLP\nHighTextColor2
        nFont1 = #SCS_FONT_GEN_BOLD10
      Else
        If grWLP\aMouseOverItem(n)
          nBackColor = #SCS_Btn_Hover_Color
        Else
          ; nBackColor = grWLP\nDfltBackColor
          nBackColor = grWLP\nDfltItemBackColor
        EndIf
        nTextColor1 = grWLP\nDfltTextColor1
        nTextColor2 = grWLP\nDfltTextColor2
        nFont1 = #SCS_FONT_GEN_NORMAL10
      EndIf
      StartDrawing(CanvasOutput(\cvsFavorite(n)))
      Box(0,0,OutputWidth(),OutputHeight(),nBackColor)
      Line(0,OutputHeight()-1,OutputWidth(),1,#SCS_Light_Grey)
      If Index = -1
        If (n <= ArraySize(gaFavoriteFiles())) And (n < gnFavFileCount)
          sFileName = gaFavoriteFiles(n)\sFileName
          grWLP\aItemFileName(n) = sFileName
          debugMsg(sProcName, "grWLP\aItemFileName(" + n + ")=" + grWLP\aItemFileName(n))
          If sFileName
            If FileExists(sFileName, #False)
              bEnableOpenButton = #True
              nFileCount + 1
              sTitle = getTitleFromCueFile(sFileName)
              grWLP\aItemTitleOrDesc(n) = sTitle
              DrawingMode(#PB_2DDrawing_Transparent)
              scsDrawingFont(nFont1)
              DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sTitle, nTextColor1)
              scsDrawingFont(#SCS_FONT_GEN_NORMAL)
              DrawText(grWLP\nTextLeft2, grWLP\nTextTop2, sFileName, nTextColor2)
              If n = grWLP\nSelectedFavorite
                grAction\sSelectedFileName = sFileName
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        debugMsg(sProcName, "grWLP\aItemFileName(" + n + ")=" + grWLP\aItemFileName(n))
        sFileName = grWLP\aItemFileName(n)
        sTitle = grWLP\aItemTitleOrDesc(n)
        If sFileName
          bEnableOpenButton = #True
          DrawingMode(#PB_2DDrawing_Transparent)
          scsDrawingFont(nFont1)
          DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sTitle, nTextColor1)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL)
          DrawText(grWLP\nTextLeft2, grWLP\nTextTop2, sFileName, nTextColor2)
        EndIf
      EndIf
      StopDrawing()
    Next n
    If Index = -1
      grWLP\nFileCountFavorite = nFileCount
      If nFileCount = 0
        StartDrawing(CanvasOutput(\cvsFavorite(0)))
        Box(0,0,OutputWidth(),OutputHeight(),grWLP\nDfltBackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
        DrawText(grWLP\nTextLeft1, grWLP\nTextTop2, Lang("WLP", "NoFav"), grWLP\nDfltTextColor1)
        StopDrawing()
        grWLP\nSelectedFavorite = -1
        nFileCount = 1  ; set file count = 1 for calculating scrollarea required inner height
      EndIf
      setEnabled(WLP\btnOpenF, bEnableOpenButton)
      nReqdInnerHeight = nFileCount * GadgetHeight(\cvsFavorite(0))
      SetGadgetAttribute(\scaFavorites, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
      SetGadgetAttribute(\scaFavorites, #PB_ScrollArea_Y, grWLP\nFavoriteY)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_drawTemplates(Index=-1)
  PROCNAMEC()
  Protected nBackColor, nTextColor1, nTextColor2, nFont1
  Protected n
  Protected sTemplateFileName.s
  Protected sName.s, sDesc.s
  Protected nFileCount
  Protected nReqdInnerHeight
  Static nMaxDescWidth, nMaxDescHeight
  Protected bEnableCreateButton
  Protected nFromIndex, nUpToIndex
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index)
  
  With WLP
    If Index = -1
      nFromIndex = 0
      ; nUpToIndex = ArraySize(\cvsTemplate())
      nUpToIndex = gnTemplateCount - 1
    Else
      nFromIndex = Index
      nUpToIndex = Index
    EndIf
    
    If Index = -1
      If nUpToIndex > ArraySize(grWLP\aMouseOverItem())
        ReDim grWLP\aMouseOverItem(nUpToIndex)
        ReDim grWLP\aItemFileName(nUpToIndex)
        ReDim grWLP\aItemName(nUpToIndex)
        ReDim grWLP\aItemTitleOrDesc(nUpToIndex)
      EndIf
      setVisible(\scaTemplates, #True)
      setVisible(\btnCreateT, #True)
      setVisible(\btnManageT, #True)
      nMaxDescWidth = GadgetWidth(\cvsTemplate(0)) - grWLP\nTextLeft2 - grWLP\nTextLeft1  ; include \nTextLeft1 to provide padding on right
      nMaxDescHeight = GadgetHeight(\cvsTemplate(0)) - grWLP\nTextTop2
      grAction\sSelectedFileName = ""
      debugMsg(sProcName, "grAction\sSelectedFileName=" + #DQUOTE$ + grAction\sSelectedFileName + #DQUOTE$)
    EndIf
    For n = nFromIndex To nUpToIndex
      If n = grWLP\nSelectedTemplate
        nBackColor = grWLP\nHighBackColor
        nTextColor1 = grWLP\nHighTextColor1
        nTextColor2 = grWLP\nHighTextColor2
        nFont1 = #SCS_FONT_GEN_BOLD10
      Else
        If grWLP\aMouseOverItem(n)
          nBackColor = #SCS_Btn_Hover_Color
        Else
          ; nBackColor = grWLP\nDfltBackColor
          nBackColor = grWLP\nDfltItemBackColor
        EndIf
        nTextColor1 = grWLP\nDfltTextColor1
        nTextColor2 = grWLP\nDfltTextColor2
        nFont1 = #SCS_FONT_GEN_NORMAL10
      EndIf
      StartDrawing(CanvasOutput(\cvsTemplate(n)))
      Box(0,0,OutputWidth(),OutputHeight(),nBackColor)
      Line(0,OutputHeight()-1,OutputWidth(),1,#SCS_Light_Grey)
      If Index = -1
        If n < gnTemplateCount
          sTemplateFileName = gaTemplate(n)\sCurrTemplateFileName
          grWLP\aItemFileName(n) = sTemplateFileName
          debugMsg(sProcName, "grWLP\aItemFileName(" + n + ")=" + grWLP\aItemFileName(n))
          If sTemplateFileName
            If FileExists(sTemplateFileName, #False)
              bEnableCreateButton = #True
              sName = gaTemplate(n)\sName
              sDesc = gaTemplate(n)\sDesc
              grWLP\aItemName(n) = sName
              grWLP\aItemTitleOrDesc(n) = sDesc
              nFileCount + 1
              DrawingMode(#PB_2DDrawing_Transparent)
              scsDrawingFont(nFont1)
              DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sName, nTextColor1)
              scsDrawingFont(#SCS_FONT_GEN_NORMAL9)
              drawMultiLineText(grWLP\nTextLeft2, grWLP\nTextTop2, nMaxDescWidth, nMaxDescHeight, sDesc, nTextColor2)
              If n = grWLP\nSelectedTemplate
                grAction\sSelectedFileName = sTemplateFileName
              EndIf
            EndIf
          EndIf
        EndIf
      Else
        sTemplateFileName = grWLP\aItemFileName(n)
        sName = grWLP\aItemName(n)
        sDesc = grWLP\aItemTitleOrDesc(n)
        If sTemplateFileName
          bEnableCreateButton = #True
          DrawingMode(#PB_2DDrawing_Transparent)
          scsDrawingFont(nFont1)
          DrawText(grWLP\nTextLeft1, grWLP\nTextTop1, sName, nTextColor1)
          scsDrawingFont(#SCS_FONT_GEN_NORMAL9)
          drawMultiLineText(grWLP\nTextLeft2, grWLP\nTextTop2, nMaxDescWidth, nMaxDescHeight, sDesc, nTextColor2)
        EndIf
      EndIf
      StopDrawing()
    Next n
    If Index = -1
      grWLP\nFileCountTemplate = nFileCount
      If nFileCount = 0
        StartDrawing(CanvasOutput(\cvsTemplate(0)))
        Box(0,0,OutputWidth(),OutputHeight(),grWLP\nDfltBackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
        DrawText(grWLP\nTextLeft1, grWLP\nTextTop2, Lang("WLP", "NoTmp"), grWLP\nDfltTextColor1)
        StopDrawing()
        grWLP\nSelectedTemplate = -1
        nFileCount = 1  ; set file count = 1 for calculating scrollarea required inner height
      EndIf
      setEnabled(WLP\btnCreateT, bEnableCreateButton)
      nReqdInnerHeight = nFileCount * GadgetHeight(\cvsTemplate(0))
      SetGadgetAttribute(\scaTemplates, #PB_ScrollArea_InnerHeight, nReqdInnerHeight)
      SetGadgetAttribute(\scaTemplates, #PB_ScrollArea_Y, grWLP\nTemplateY)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_drawSelectedChoice()
  
  Select grWLP\nSelectedChoice
    Case #SCS_CHOICE_NEW
      WLP_drawNew()
    Case #SCS_CHOICE_TEMPLATE
      WLP_drawTemplates()
    Case #SCS_CHOICE_FAVORITE
      WLP_drawFavorites()
    Default
      WLP_drawExisting()
  EndSelect
  
  WLP_setButtons()
  
EndProcedure

Procedure WLP_drawChoices(bRedrawButtonsOnly=#False)
  PROCNAMEC()
  Protected nBackColor, nTextColor
  Protected nCanvasLeft, nTextLeft
  Protected nGap
  Protected n
  Protected bEnabled
  Static Dim sText.s(3)
  Static Dim nImageNo(3)
  Static Dim nTextWidth(3)
  Static nMaxTextWidth, nCanvasWidth
  Static nImageLeft, nImageTop, nTextTop
  Static bPrevPlayOnly
  Static bStaticLoaded
  
  With WLP
    If (bStaticLoaded = #False) Or (grWLP\bPlayOnly <> bPrevPlayOnly)
      If bStaticLoaded = #False
        sText(#SCS_CHOICE_NEW) = Lang("WLP", "New")
        sText(#SCS_CHOICE_EXISTING) = Lang("WLP", "Existing")
        sText(#SCS_CHOICE_FAVORITE) = Lang("WLP", "Favorite")
        sText(#SCS_CHOICE_TEMPLATE) = Lang("WLP", "Template")
        nImageNo(#SCS_CHOICE_FAVORITE) = hToolFavoritesEn
        nImageNo(#SCS_CHOICE_EXISTING) = hToolExistingEn
        If StartDrawing(CanvasOutput(\cvsChoice(0)))
          scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
          For n = 0 To 3
            nTextWidth(n) = TextWidth(sText(n))
            If nTextWidth(n) > nMaxTextWidth
              nMaxTextWidth = nTextWidth(n)
            EndIf
          Next n
          StopDrawing()
        EndIf
        nGap = 4
        nCanvasWidth = nMaxTextWidth + 12
        ; resize and reposition canvases
        nCanvasLeft = GadgetWidth(\cntChoice) - (nCanvasWidth * 4) - (nGap * 3) - glScrollBarWidth - 8
        For n = 0 To 3
          ResizeGadget(\cvsChoice(n), nCanvasLeft, #PB_Ignore, nCanvasWidth, #PB_Ignore)
          nCanvasLeft + nCanvasWidth + nGap
        Next n
        nImageLeft = (nCanvasWidth - ImageWidth(hToolNewEn)) >> 1
        nImageTop = 4
        nTextTop = nImageTop + ImageHeight(hToolNewEn) + 6
        bStaticLoaded = #True
      EndIf
      If grWLP\bPlayOnly
        nImageNo(#SCS_CHOICE_NEW) = hToolNewDi
        nImageNo(#SCS_CHOICE_TEMPLATE) = hToolTemplatesDi
      Else
        nImageNo(#SCS_CHOICE_NEW) = hToolNewEn
        nImageNo(#SCS_CHOICE_TEMPLATE) = hToolTemplatesEn
      EndIf
      bPrevPlayOnly = grWLP\bPlayOnly
    EndIf
    
    For n = 0 To 3
      If StartDrawing(CanvasOutput(\cvsChoice(n)))
        If grWLP\bPlayOnly And (n = #SCS_CHOICE_NEW Or n = #SCS_CHOICE_TEMPLATE)
          bEnabled = #False
          Box(0,0,OutputWidth(),OutputHeight(),grWLP\nPlayOnlyBackColor)
        Else
          bEnabled = #True
          If grWLP\aMouseOverChoice(n)
            Box(0,0,OutputWidth(),OutputHeight(),#SCS_Btn_Hover_Color)
          Else
            Box(0,0,OutputWidth(),OutputHeight(),#SCS_Btn_Enabled_Color)
          EndIf
        EndIf
        If n = grWLP\nSelectedChoice
          nBackColor = grWLP\nHighBackColor
          nTextColor = grWLP\nHighTextColor1
        Else
          nBackColor = #SCS_Line_Color
          If grWLP\bPlayOnly And (n = #SCS_CHOICE_NEW Or n = #SCS_CHOICE_TEMPLATE)
            nTextColor = #SCS_Mid_Grey ; grWLP\nPlayOnlyTextColor1
          Else
            nTextColor = grWLP\nDfltTextColor1
          EndIf
        EndIf
        If n <> grWLP\nSelectedChoice
          ; rounded box for non-selected choices to be in outline only, if not using new colors
          DrawingMode(#PB_2DDrawing_Outlined)
        EndIf
        RoundBox(0,0,OutputWidth(),OutputHeight(),8,8,nBackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawAlphaImage(ImageID(nImageNo(n)),nImageLeft,nImageTop)
        scsDrawingFont(#SCS_FONT_GEN_NORMAL10)
        nTextLeft = (nCanvasWidth - nTextWidth(n)) >> 1
        DrawText(nTextLeft,nTextTop,sText(n),nTextColor)
        StopDrawing()
      EndIf
    Next n
    
    If bRedrawButtonsOnly = #False
      SetGadgetColor(\cntNew, #PB_Gadget_BackColor, grWLP\nDfltBackColor)
      SetGadgetColor(\scaFiles, #PB_Gadget_BackColor, grWLP\nDfltBackColor)
      
      setVisible(\cntNew, #False)
      setVisible(\scaTemplates, #False)
      setVisible(\scaFavorites, #False)
      setVisible(\scaFiles, #False)
      
      ; initially hide all buttons except for 'cancel' (which is displayed for all choices)
      setVisible(\btnCreateNew, #False)
      setVisible(\btnCreateT, #False)
      setVisible(\btnManageT, #False)
      setVisible(\btnOpenF, #False)
      setVisible(\btnManageF, #False)
      setVisible(\btnOpenE, #False)
      setVisible(\btnBrowseE, #False)
      
      WLP_drawSelectedChoice()
    EndIf ; EndIf bRedrawButtonsOnly = #False
    
  EndWith
  
EndProcedure

Procedure WLP_populateCboAudPrimaryDev()
  PROCNAMEC()
  Protected n
  Protected nDataForDefault = -1
  Protected nListIndex
  
  ; debugMsg(sProcName, "grLoadProdPrefs\nAudioDriver=" + decodeDriver(grLoadProdPrefs\nAudioDriver))
  
  ClearGadgetItems(WLP\cboAudPrimaryDev)
  For n = 0 To gnMaxConnectedDev
    With gaConnectedDev(n)
      If \nDriver = grLoadProdPrefs\nAudioDriver
        addGadgetItemWithData(WLP\cboAudPrimaryDev, \sPhysicalDevDesc, n)
        If \bDefaultDev
          If nDataForDefault < 0 Or \nDevice = 1 ; Added \nDevice test 9Jan2025 11.10.6-b02 as WASAPI seems to have "Default Audio Device" listed second, but with \nDevice = 1
            nDataForDefault = n
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  With WLP
    setComboBoxWidth(\cboAudPrimaryDev, 60)
    If CountGadgetItems(\cboAudPrimaryDev) > 0
      nListIndex = indexForComboBoxRow(\cboAudPrimaryDev, grLoadProdPrefs\sAudPrimaryDev, -1)
      If nListIndex = -1
        nListIndex = indexForComboBoxData(\cboAudPrimaryDev, nDataForDefault, 0)
      EndIf
      SGS(\cboAudPrimaryDev, nListIndex)
    EndIf
  EndWith

EndProcedure

Procedure WLP_Form_Load(nParentWindow)
  PROCNAMEC()
  Protected sUpdateAvailable.s
  Protected nActionTop, nWindowHeight

  debugMsg(sProcName, #SCS_START)
  
  With grWLP
    \bWindowActive = #True
    grAction\nAction = #SCS_ACTION_NONE
    If \bStructurePrimed = #False
      \nSelectedChoice = #SCS_CHOICE_EXISTING
      \nDfltBackColor = glSysColBtnFace
      \nDfltTextColor1 = glSysColWindowText
      \nDfltTextColor2 = \nDfltTextColor1
      \nDfltItemBackColor = RGB(233,233,233)
      \nHighBackColor = RGB(60,156,255)
      \nHighTextColor1 = #SCS_White
      \nHighTextColor2 = \nHighTextColor1
      \nPlayOnlyBackColor = glSysColInactiveCaption
      \nPlayOnlyTextColor1 = glSysColInactiveCaptionText
      \nTextLeft1 = 10
      \nTextLeft2 = \nTextLeft1 + 12
      \nTextTop1 = 3
      \nTextTop2 = \nTextTop1 + GetTextHeight("yY", #SCS_FONT_GEN_NORMAL10) + 2
      \bStructurePrimed = #True
    EndIf
    
    If (IsWindow(#WLP) = #False) Or (gaWindowProps(#WLP)\nParentWindow <> nParentWindow)
      createfmLoadProd(nParentWindow)
    EndIf
    
    CompilerIf #cDemo = #False And #cWorkshop = #False
      If IsGadget(WLP\cntUpdateAvailable)
        If gnOperMode = #SCS_OPERMODE_DESIGN
          sUpdateAvailable = checkForUpdateIfReqd() ; returns "" if no update available
        Else
          ; do not check for updates in rehearsal or performance modes
          sUpdateAvailable = ""
        EndIf
        If sUpdateAvailable
          debugMsg(sProcName, "sUpdateAvailable" + sUpdateAvailable)
          nActionTop = GadgetY(WLP\cntUpdateAvailable) + GadgetHeight(WLP\cntUpdateAvailable) + 1
        Else
          nActionTop = \nScaTop + \nScaHeight + 1
        EndIf
        nWindowHeight = nActionTop + GadgetHeight(WLP\cntAction)
        If WindowHeight(#WLP) <> nWindowHeight
          ResizeWindow(#WLP, #PB_Ignore, #PB_Ignore, #PB_Ignore, nWindowHeight)
          ResizeGadget(WLP\cntAction, #PB_Ignore, nActionTop, #PB_Ignore, #PB_Ignore)
          ResizeGadget(WLP\lnSeparator[1], #PB_Ignore, nActionTop-1, #PB_Ignore, #PB_Ignore)
          If sUpdateAvailable
            SGT(WLP\lblUpdateAvailable1, LangPars("Common", "SCSUpdateMsg1", sUpdateAvailable))
            SGT(WLP\lblUpdateAvailable2, Lang("Common", "SCSUpdateMsg2"))
            setVisible(WLP\cntUpdateAvailable, #True)
            setVisible(WLP\lnSeparator[2], #True)
          Else
            setVisible(WLP\cntUpdateAvailable, #False)
            setVisible(WLP\lnSeparator[2], #False)
          EndIf
        EndIf
      EndIf
    CompilerEndIf
    
    If gbInitialising
      setVisible(WLP\btnCloseSCS, #True)
      setVisible(WLP\btnCancel, #False)
    Else
      setVisible(WLP\btnCloseSCS, #False)
      setVisible(WLP\btnCancel, #True)
    EndIf
    If grLoadProdPrefs\bShowAtStart
      SGS(WLP\chkShowAtStart, #PB_Checkbox_Checked)
    Else
      SGS(WLP\chkShowAtStart, #PB_Checkbox_Unchecked)
    EndIf
    
    ClearGadgetItems(WLP\cboAudioDriver)
    If gnDSDeviceCount > 0
      addGadgetItemWithData(WLP\cboAudioDriver, decodeDriverL(#SCS_DRV_BASS_DS), #SCS_DRV_BASS_DS)
    EndIf
    If gnWASAPIDeviceCount > 0 And gbWasapiAvailable
      addGadgetItemWithData(WLP\cboAudioDriver, decodeDriverL(#SCS_DRV_BASS_WASAPI), #SCS_DRV_BASS_WASAPI)
    EndIf
    If grLicInfo\bASIOAvailable
      If gnAsioDeviceCount > 0
        addGadgetItemWithData(WLP\cboAudioDriver, decodeDriverL(#SCS_DRV_BASS_ASIO), #SCS_DRV_BASS_ASIO)
      EndIf
    EndIf
    If grLicInfo\bSMSAvailable
      If gnAsioDeviceCount > 0
        addGadgetItemWithData(WLP\cboAudioDriver, decodeDriverL(#SCS_DRV_SMS_ASIO), #SCS_DRV_SMS_ASIO)
      EndIf
    EndIf
    setComboBoxWidth(WLP\cboAudioDriver, 60)
    WLP_populateCboAudPrimaryDev()
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_Form_Show(nParentWindow, bModal=#False, nReturnFunction=0, bClearSelected=#True)
  PROCNAMEC()
  
  If (IsWindow(#WLP) = #False) Or (gaWindowProps(#WLP)\nParentWindow <> nParentWindow)
    WLP_Form_Load(nParentWindow)
  EndIf
  
  With grWLP
    If grLicInfo\bPlayOnly Or gbEditorAndOptionsLocked
      \bPlayOnly = #True
    Else
      \bPlayOnly = #False
    EndIf
    If bClearSelected
      \nSelectedChoice = #SCS_CHOICE_EXISTING
      \nSelectedExisting = 0
      \nSelectedFavorite = 0
      \nSelectedTemplate = 0
      \nExistingY = 0
      \nFavoriteY = 0
      \nTemplateY = 0
    ElseIf \bPlayOnly
      Select \nSelectedChoice
        Case #SCS_CHOICE_NEW, #SCS_CHOICE_TEMPLATE
          \nSelectedChoice = #SCS_CHOICE_EXISTING
          \nSelectedExisting = 0
          \nExistingY = 0
      EndSelect
    EndIf
  EndWith
  
  createWLPExistingIfReqd()
  createWLPFavoritesIfReqd()
  createWLPTemplatesIfReqd()
  
  WLP_drawChoices()
  
  setWindowModal(#WLP, bModal, nReturnFunction)

  setWindowVisible(#WLP, #True)
  If nParentWindow = #WSP
    If IsWindow(#WSP)
      If getWindowVisible(#WSP)
        setWindowVisible(#WSP, #False)
      EndIf
    EndIf
  EndIf
  SAW(#WLP)
  
EndProcedure

Procedure WLP_cboAudioDriver_Click()
  
  If getCurrentItemData(WLP\cboAudioDriver) <> grLoadProdPrefs\nAudioDriver
    grLoadProdPrefs\nAudioDriver = getCurrentItemData(WLP\cboAudioDriver)
    WLP_populateCboAudPrimaryDev()
  EndIf
  
EndProcedure

Procedure WLP_cboAudPrimaryDev_Click()
  
  grLoadProdPrefs\sAudPrimaryDev = GGT(WLP\cboAudPrimaryDev)
  
EndProcedure

Procedure WLP_txtTitle_Validate()
  ; PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START)
  
  WLP_setButtons()
  ProcedureReturn #True
EndProcedure

Procedure WLP_txtDevMapName_Validate()
  Protected sDevMapName.s
  
  sDevMapName = Trim(GGT(WLP\txtDevMapName))
  If sDevMapName
    grLoadProdPrefs\sDevMapName = sDevMapName
  EndIf
  
  ProcedureReturn #True
EndProcedure

Procedure WLP_chkShowAtStart_Click()
  
  If GGS(WLP\chkShowAtStart) = #PB_Checkbox_Checked
    grLoadProdPrefs\bShowAtStart = #True
  Else
    grLoadProdPrefs\bShowAtStart = #False
  EndIf
  
EndProcedure

Procedure WLP_cvsChoice_Event(Index)
  Protected bIgnoreClick
  
  With grWLP
    Select gnEventType
      Case #PB_EventType_LeftClick
        If \bPlayOnly
          Select Index
            Case #SCS_CHOICE_NEW, #SCS_CHOICE_TEMPLATE
              bIgnoreClick = #True
          EndSelect
        EndIf
        If bIgnoreClick = #False
          \nSelectedChoice = Index
          WLP_drawChoices(#False)
        EndIf
        
      Case #PB_EventType_MouseEnter
        \aMouseOverChoice(Index) = #True
        WLP_drawChoices(#True)
        
      Case #PB_EventType_MouseLeave
        \aMouseOverChoice(Index) = #False
        WLP_drawChoices(#True)
        
    EndSelect
  EndWith

EndProcedure

Procedure WLP_cvsFile_Event(Index)
  PROCNAMEC()
  Protected sTitle.s, sMsg.s, nResponse, bMouseCurrOverDelItem
  
  With grWLP
    Select gnEventType
      Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick
        If (gnRecentFileCount > 0) And (\aItemTitleOrDesc(Index))
          If WLP_isMouseOverDelItemX(WLP\cvsExisting(Index))
            \nSelectedExisting = Index
            \nExistingY = GetGadgetAttribute(WLP\scaFiles, #PB_ScrollArea_Y)
            WLP_drawExisting(-1, grWLP\bMouseOverDelItemHot)
            sTitle = Lang("WLP", "Existing")
            sMsg = LangPars("WLP", "RemoveFile", "'" + \aItemTitleOrDesc(Index) + "'")
            sMsg + Chr(10) + Chr(10) + "(" + \aItemFileName(Index) + ")"
            nResponse = scsMessageRequester(sTitle, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
            If nResponse = #PB_MessageRequester_Yes
              WLP_removeItem(#SCS_CHOICE_EXISTING, Index)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
    EndSelect
    
    Select gnEventType
      Case #PB_EventType_LeftClick
        If gnRecentFileCount > 0
          \nSelectedExisting = Index
          \nExistingY = GetGadgetAttribute(WLP\scaFiles, #PB_ScrollArea_Y)
          WLP_drawExisting()
        EndIf
        
      Case #PB_EventType_LeftDoubleClick
        If gnRecentFileCount > 0
          \nSelectedExisting = Index
          \nExistingY = GetGadgetAttribute(WLP\scaFiles, #PB_ScrollArea_Y)
          If getEnabled(WLP\btnOpenE)
            grAction\sSelectedFileName = gsRecentFile(Index)
            WLP_btnOpen_Click()
            ProcedureReturn
          Else
            WLP_drawExisting()
          EndIf
        EndIf
        
      Case #PB_EventType_MouseEnter
        If gnRecentFileCount > 0
          \aMouseOverItem(Index) = #True
          bMouseCurrOverDelItem = WLP_isMouseOverDelItemX(WLP\cvsExisting(Index))
          WLP_drawExisting(Index, bMouseCurrOverDelItem)
          grWLP\bMouseOverDelItemHot = bMouseCurrOverDelItem
        EndIf
        
      Case #PB_EventType_MouseLeave
        If gnRecentFileCount > 0
          \aMouseOverItem(Index) = #False
          WLP_drawExisting(Index, #False)
        EndIf
        
      Case #PB_EventType_MouseMove
        If gnRecentFileCount > 0
          bMouseCurrOverDelItem = WLP_isMouseOverDelItemX(WLP\cvsExisting(Index))
          If bMouseCurrOverDelItem <> grWLP\bMouseOverDelItemHot
            WLP_drawExisting(Index, bMouseCurrOverDelItem)
            grWLP\bMouseOverDelItemHot = bMouseCurrOverDelItem
          EndIf
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_cvsFavorite_Event(Index)
  PROCNAMEC()
  
  With grWLP
    Select gnEventType
      Case #PB_EventType_LeftClick
        If gnFavFileCount > 0
          grWLP\nSelectedFavorite = Index
          grWLP\nFavoriteY = GetGadgetAttribute(WLP\scaFavorites, #PB_ScrollArea_Y)
          WLP_drawFavorites()
        EndIf
        
      Case #PB_EventType_LeftDoubleClick
        If gnFavFileCount > 0
          grWLP\nSelectedFavorite = Index
          grWLP\nFavoriteY = GetGadgetAttribute(WLP\scaFavorites, #PB_ScrollArea_Y)
          If getEnabled(WLP\btnOpenF)
            grAction\sSelectedFileName = gaFavoriteFiles(Index)\sFileName
            WLP_btnOpen_Click()
            ProcedureReturn
          Else
            WLP_drawFavorites()
          EndIf
        EndIf
        
      Case #PB_EventType_MouseEnter
        If gnFavFileCount > 0
          \aMouseOverItem(Index) = #True
          WLP_drawFavorites(Index)
        EndIf
        
      Case #PB_EventType_MouseLeave
        If gnFavFileCount > 0
          \aMouseOverItem(Index) = #False
          WLP_drawFavorites(Index)
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_cvsTemplate_Event(Index)
  PROCNAMEC()
  
  With grWLP
    Select gnEventType
      Case #PB_EventType_LeftClick
        If gnTemplateCount > 0
          grWLP\nSelectedTemplate = Index
          grWLP\nTemplateY = GetGadgetAttribute(WLP\scaTemplates, #PB_ScrollArea_Y)
          WLP_drawTemplates()
        EndIf
        
      Case #PB_EventType_LeftDoubleClick
        If gnTemplateCount > 0
          grWLP\nSelectedTemplate = Index
          grWLP\nTemplateY = GetGadgetAttribute(WLP\scaTemplates, #PB_ScrollArea_Y)
          If getEnabled(WLP\btnCreateT)
            debugMsg(sProcName, "gaTemplate(" + Index + ")\sName=" + gaTemplate(Index)\sName)
            grAction\sSelectedFileName = gaTemplate(Index)\sCurrTemplateFileName
            debugMsg(sProcName, "Index=" + Index + ", grAction\sSelectedFileName=" + #DQUOTE$ + grAction\sSelectedFileName + #DQUOTE$)
            WLP_btnCreateT_Click()
            ProcedureReturn
          Else
            WLP_drawTemplates()
          EndIf
        EndIf
        
      Case #PB_EventType_MouseEnter
        If gnTemplateCount > 0
          \aMouseOverItem(Index) = #True
          WLP_drawTemplates(Index)
        EndIf
        
      Case #PB_EventType_MouseLeave
        If gnTemplateCount > 0
          \aMouseOverItem(Index) = #False
          WLP_drawTemplates(Index)
        EndIf
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_btnOpen_Click()
  PROCNAMEC()
  Protected sInfo.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWLP
    grAction\nAction = #SCS_ACTION_NONE
    Select \nSelectedChoice
      Case #SCS_CHOICE_EXISTING
        If \nSelectedExisting >= 0
          grAction\sSelectedFileName = gsRecentFile(\nSelectedExisting)
          grAction\nAction = #SCS_ACTION_OPEN_FILE
          grAction\nParentWindow = #WLP
        EndIf
      Case #SCS_CHOICE_FAVORITE
        If \nSelectedFavorite >= 0
          grAction\sSelectedFileName = gaFavoriteFiles(\nSelectedFavorite)\sFileName
          grAction\nAction = #SCS_ACTION_OPEN_FILE
          grAction\nParentWindow = #WLP
        EndIf
    EndSelect
  EndWith
  WLP_Form_Unload()
  With grAction
    If \nAction = #SCS_ACTION_OPEN_FILE
      sInfo = Trim(getTitleFromCueFile(\sSelectedFileName))
      If Len(sInfo) = 0
        sInfo = GetFilePart(\sSelectedFileName)
      EndIf
      WMI_displayInfoMsg1(LangPars("WLP", "Opening", #DQUOTE$ + sInfo + #DQUOTE$), 0, #SCS_TITLE)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_FMOpenCueFile(sCueFile.s)
  PROCNAMEC()
  Protected sInfo.s
  
  debugMsg(sProcName, #SCS_START + ", sCueFile=" + #DQUOTE$ + sCueFile + #DQUOTE$)
  
  With grAction
    \sSelectedFileName = sCueFile
    \nAction = #SCS_ACTION_OPEN_FILE
    \nParentWindow = #WLP
  EndWith
  WLP_Form_Unload()
  With grAction
    sInfo = Trim(getTitleFromCueFile(\sSelectedFileName))
    If Len(sInfo) = 0
      sInfo = GetFilePart(\sSelectedFileName)
    EndIf
    WMI_displayInfoMsg1(LangPars("WLP", "Opening", #DQUOTE$ + sInfo + #DQUOTE$), 0, #SCS_TITLE)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_btnBrowse_Click()
  PROCNAMEC()
  Protected sTitle.s, sDefaultFile.s
  Protected sFileName.s
  Protected sInfo.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    sTitle = Lang("Common", "OpenSCSCueFile")
    If Trim(gsCueFolder)
      sDefaultFile = Trim(gsCueFolder)
    ElseIf Trim(grGeneralOptions\sInitDir)
      sDefaultFile = Trim(grGeneralOptions\sInitDir)
    EndIf
    sFileName = OpenFileRequester(sTitle, sDefaultFile, gsPatternAllCueFiles, 0)
    If sFileName
      \sSelectedFileName = sFileName
      \nAction = #SCS_ACTION_OPEN_FILE
      \nParentWindow = #WLP
      WLP_Form_Unload()
      sInfo = Trim(getTitleFromCueFile(\sSelectedFileName))
      If Len(sInfo) = 0
        sInfo = GetFilePart(\sSelectedFileName)
      EndIf
      WMI_displayInfoMsg1(LangPars("WLP", "Opening", #DQUOTE$ + sInfo + #DQUOTE$), 0, #SCS_TITLE)
    EndIf
  EndWith  
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_btnCreateNew_Click()
  PROCNAMEC()
  ; create a new cue file
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    \sTitle = Trim(GGT(WLP\txtTitle))
    \sDevMapName = Trim(GGT(WLP\txtDevMapName))
    \nAudioDriver = getCurrentItemData(WLP\cboAudioDriver)
    \sAudPrimaryDev = GGT(WLP\cboAudPrimaryDev)
    \nAction = #SCS_ACTION_CREATE
    \nParentWindow = #WLP
  EndWith
  WLP_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_btnCreateT_Click()
  PROCNAMEC()
  ; create a cue file from a template
  Protected sFileName.s, sName.s
  Protected sReqTitle.s, sReqHeading.s, sReqItem.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grAction
    \nAction = #SCS_ACTION_NONE
    If grWLP\nSelectedTemplate >= 0
      sFileName = gaTemplate(grWLP\nSelectedTemplate)\sCurrTemplateFileName
      sName = gaTemplate(grWLP\nSelectedTemplate)\sName
      \sSelectedFileName = sFileName
      debugMsg(sProcName, "grAction\sSelectedFileName=" + #DQUOTE$ + \sSelectedFileName + #DQUOTE$)
      sReqTitle = Lang("Actions", "PrTitle")
      sReqHeading = LangPars("Actions", "PrHeading", #DQUOTE$ + sName + #DQUOTE$)
      sReqItem = Lang("WEP", "lblTitle")  ; "Name of Production"
      WIR_Form_Show(#True, #WLP, #SCS_IR_PROD_TITLE, #SCS_ACTION_CREATE_FROM_TEMPLATE, sReqTitle, sReqHeading, sReqItem)
      ProcedureReturn
    EndIf
  EndWith
  WLP_Form_Unload()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_btnManage_Click()
  PROCNAMEC()
  Protected sSelectedTemplateName.s
  
  debugMsg(sProcName, #SCS_START)
  
  With grWLP
    Select \nSelectedChoice
      Case #SCS_CHOICE_TEMPLATE
        If (gnTemplateCount > 0) And (\nSelectedTemplate >= 0)
          sSelectedTemplateName = gaTemplate(\nSelectedTemplate)\sName
        EndIf
        WTM_Form_Show(#WLP, #True, #SCS_MODRETURN_LOADPROD, sSelectedTemplateName)
        
      Case #SCS_CHOICE_FAVORITE
        WFF_Form_Show(#WLP, #True, #SCS_MODRETURN_LOADPROD)
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_btnOptions_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  WOP_Form_Show(#True, #WLP)

  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_btnCloseSCS_Click()
  PROCNAMEC()
  
  grAction\nAction = #SCS_ACTION_CLOSE_SCS
  grAction\nParentWindow = #WLP
  WLP_Form_Unload()
  
EndProcedure

Procedure WLP_btnCancel_Click()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  ; 25Feb2020 11.8.2.2at: modified to call WLP_btnCloseSCS_Click() if no cue file is yet open, following email from Steven Slator about Esc from LoadProd window preventing SCS being started again
  If gsCueFile
    grAction\nAction = #SCS_ACTION_NONE
    debugMsg(sProcName, "gsCueFile=" + #DQUOTE$ + gsCueFile + #DQUOTE$ + ", so calling WLP_Form_Unload()")
    WLP_Form_Unload()
  Else
    debugMsg(sProcName, "gsCueFile=" + #DQUOTE$ + gsCueFile + #DQUOTE$ + ", so calling WLP_btnCloseSCS_Click()")
    WLP_btnCloseSCS_Click()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_EventHandler()
  PROCNAMEC()
  Protected nGadgetNo ; must be called 'nGadgetNo' for macro ETVAL2()
  Protected nGadgetPropsIndex ; required by macro ETVAL2()
  
  With WLP
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        If getVisible(\btnCancel)
          WLP_btnCancel_Click()
        Else
          WLP_btnCloseSCS_Click()
        EndIf
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
          Case #SCS_mnuKeyboardReturn
            ; Added 22Jul2022 11.10.0 following test in which creating a new production and entering a 'name of production', and then pressing the Enter key without tabbing out of the field
            ; would cause SCS to loop as \txtTitle was still marked as requiring validation.
            nGadgetNo = GetActiveGadget()
            ; debugMsg0(sProcName, "nGadgetNo=" + getGadgetName(nGadgetNo))
            Select nGadgetNo
              Case \txtTitle, \txtDevMapName
                Select nGadgetNo
                  Case \txtTitle
                    ETVAL2(WLP_txtTitle_Validate())
                  Case \txtDevMapName
                    ETVAL2(WLP_txtDevMapName_Validate())
                EndSelect
                If gbLastVALResult = #False
                  If IsGadget(gnFocusGadgetNo)
                    SAG(gnFocusGadgetNo)
                  EndIf
                  debugMsg(sProcName, "exiting because ETVAL2(" + getGadgetName(nGadgetNo, #False) + " reported a validation failure")
                  ProcedureReturn
                EndIf
            EndSelect
            ; Any required validation comleted OK, so continue
            ; End added 22Jul2022 11.10.0
            If (getVisible(\btnOpenE)) And (getEnabled(\btnOpenE))
              WLP_btnOpen_Click()
            ElseIf (getVisible(\btnOpenF)) And (getEnabled(\btnOpenF))
              WLP_btnOpen_Click()
            ElseIf (getVisible(\btnCreateNew)) And (getEnabled(\btnCreateNew))
              ; debugMsg0(sProcName, "calling WLP_btnCreateNew_Click()")
              WLP_btnCreateNew_Click()
            ElseIf (getVisible(\btnCreateT)) And (getEnabled(\btnCreateT))
              WLP_btnCreateT_Click()
            EndIf
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WLP_btnCancel_Click()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ; debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
            
          Case \btnBrowseE
            WLP_btnBrowse_Click()
            
          Case \btnCancel
            WLP_btnCancel_Click()
            
          Case \btnCloseSCS
            WLP_btnCloseSCS_Click()
            
          Case \btnCreateNew
            WLP_btnCreateNew_Click()
            
          Case \btnCreateT
            WLP_btnCreateT_Click()
            
          Case \btnManageF, \btnManageT
            WLP_btnManage_Click()
            
          Case \btnOpenE, \btnOpenF
            WLP_btnOpen_Click()
            
          Case \btnOptions
            WLP_btnOptions_Click()
            
          Case \btnRegister
            WRG_Form_Show(#True, #WLP)
            
          Case \cboAudioDriver
            CBOCHG(WLP_cboAudioDriver_Click())
            
          Case \cboAudPrimaryDev
            CBOCHG(WLP_cboAudPrimaryDev_Click())
            
          Case \chkShowAtStart
            CHKCHG(WLP_chkShowAtStart_Click())
            
          Case \cvsChoice(0)
            WLP_cvsChoice_Event(gnEventGadgetArrayIndex)
            
          Case \cvsFavorite(0)
            WLP_cvsFavorite_Event(gnEventGadgetArrayIndex)
            
          Case \cvsExisting(0)
            WLP_cvsFile_Event(gnEventGadgetArrayIndex)
            
          Case \cvsTemplate(0)
            WLP_cvsTemplate_Event(gnEventGadgetArrayIndex)
            
          Case \scaFavorites, \scaFiles, \scaTemplates
            ; no action
            
          Case \txtDevMapName
            If gnEventType = #PB_EventType_LostFocus
              ETVAL(WLP_txtDevMapName_Validate())
            EndIf
            
          Case \txtTitle
            Select gnEventType
              Case #PB_EventType_Change
                WLP_setButtons()
              Case #PB_EventType_LostFocus
                ETVAL(WLP_txtTitle_Validate())
            EndSelect
            
          Default
            debugMsg0(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
            
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_setButtons()
  PROCNAMEC()
  Protected bEnable
  
  With WLP
    Select grWLP\nSelectedChoice
      Case #SCS_CHOICE_NEW
        If Trim(GGT(\txtTitle))
          bEnable = #True
        EndIf
        If getEnabled(\btnCreateNew) <> bEnable
          setEnabled(\btnCreateNew, bEnable)
        EndIf
        
      EndSelect
    EndWith

EndProcedure

Procedure WLP_refresh()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createWLPExistingIfReqd()
  createWLPFavoritesIfReqd()
  createWLPTemplatesIfReqd()
  WLP_drawChoices() ; nb includes call to WLP_drawSelectedChoice()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WLP_setIndexWithinChoice(nChoice, sSelectedFileName.s)
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", sSelectedFileName=" + sSelectedFileName)
  
  With grWLP
    Select nChoice
      Case #SCS_CHOICE_TEMPLATE
        For n = 0 To (gnTemplateCount-1)
          ; debugMsg(sProcName, "gaTemplate(n)\sCurrTemplateFileName=" + gaTemplate(n)\sCurrTemplateFileName)
          If gaTemplate(n)\sCurrTemplateFileName = sSelectedFileName
            \nSelectedTemplate = n
            Break
          EndIf
        Next n
        debugMsg(sProcName, "grWLP\nSelectedTemplate=" + \nSelectedTemplate)
    EndSelect
  EndWith
  
EndProcedure

Procedure WLP_drawDelItemX(nColor, nMainBackColor, bMouseOverDelItem)
  PROCNAMEC()
  
  With grWLP
    If \nDelItemWidth = 0
      \nDelItemWidth = 7
      \nDelItemHeight = 7
      \nDelItemLeft = OutputWidth() - \nDelItemWidth - 13
      \nDelItemRight = \nDelItemLeft + \nDelItemWidth - 1
      \nDelItemTop = 6
      \nDelItemBottom = \nDelItemTop + \nDelItemHeight - 1
      \nDelItemHotTop = 1
      \nDelItemHotBottom = 18
      \nDelItemHotLeft = \nDelItemLeft - 12
      \nDelItemHotRight = OutputWidth() - 2
      \nDelItemHotWidth = \nDelItemHotRight - \nDelItemHotLeft + 1
      \nDelItemHotHeight = \nDelItemHotBottom - \nDelItemHotTop + 1
      debugMsg(sProcName, "OutputWidth()=" + OutputWidth() + ", \nDelItemHotLeft=" + \nDelItemHotLeft + ", \nDelItemHotRight=" + \nDelItemHotRight +
                       ", \nDelItemHotWidth=" + \nDelItemHotWidth + ", \nDelItemHotHeight=" + \nDelItemHotHeight)
    EndIf
    If bMouseOverDelItem
      Box(\nDelItemHotLeft, \nDelItemHotTop, \nDelItemHotWidth, \nDelItemHotHeight, #SCS_Light_Grey)
    Else
      Box(\nDelItemHotLeft, \nDelItemHotTop, \nDelItemHotWidth, \nDelItemHotHeight, nMainBackColor)
    EndIf
    Line(\nDelItemLeft, \nDelItemTop, \nDelItemWidth, \nDelItemHeight, nColor)
    Line(\nDelItemLeft, \nDelItemBottom, \nDelItemWidth, (\nDelItemHeight * -1), nColor)
  EndWith
  
EndProcedure

Procedure WLP_isMouseOverDelItemX(nCanvasGadget)
  PROCNAMEC()
  Protected nMouseX, nMouseY, bMouseOverDelItemX
  
  With grWLP
    nMouseX = GetGadgetAttribute(nCanvasGadget, #PB_Canvas_MouseX)
    nMouseY = GetGadgetAttribute(nCanvasGadget, #PB_Canvas_MouseY)
    If (nMouseX >= \nDelItemHotLeft) And (nMouseX <= \nDelItemHotRight)
      If (nMouseY >= \nDelItemHotTop) And (nMouseY <= \nDelItemHotBottom)
        bMouseOverDelItemX = #True
      EndIf
    EndIf
  EndWith
  ProcedureReturn bMouseOverDelItemX
  
EndProcedure

Procedure WLP_removeItem(nItemType, Index)
  PROCNAMEC()
  
  Select nItemType
    Case #SCS_CHOICE_EXISTING
      deleteFromRFL(grWLP\aItemFileName(Index))
      WLP_drawExisting()
  EndSelect
  
EndProcedure

; EOF
