; File: fmEditQE.pbi

EnableExplicit

Enumeration 7000 ; toolbar images
  #WQE_btn_Page_Color
  #WQE_btn_Text_Back_Color
  #WQE_btn_Text_Color
  #WQE_ico_Font
  #WQE_ico_Search
  #WQE_ico_Cut
  #WQE_ico_Copy
  #WQE_ico_Paste
  #WQE_ico_Undo
  #WQE_ico_Redo
  #WQE_ico_Bold
  #WQE_ico_Italic
  #WQE_ico_Underline
  #WQE_ico_Left
  #WQE_ico_Center
  #WQE_ico_Right
  #WQE_ico_SelectAll
  #WQE_ico_Indent
  #WQE_ico_Outdent
  #WQE_ico_List
  ; #WQE_btn_Misc
EndEnumeration

Procedure WQE_displaySub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nListIndex
  ; Protected rtf$
  
  debugMsg(sProcName, #SCS_START)
  
  If grCED\bQECreated = #False
    WQE_Form_Load()
  EndIf
  
  ; rtf$ + "{\rtf1\ansi\ansicpg1252{\fonttbl{\f1\fswiss Arial;}{\f2\fmodern Courier New;}{\f3\froman Times New Roman;}{\f4\fcharset2\fdecor Symbol;}}{\colortbl ;\red255\green0\blue0;\red0\green255\blue255;}{" + #CRLF$
  ; rtf$ + "{\f1\b A large range of character formatting options is supported:}\par\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Fonts:} {\f1 Arial}, {\f2 Courier New}, {\f3 Times New Roman}, {\f4 SYMBOL} (any installed font)\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Effects:} {\b bold}, {\i italic}, {\ul underline}, {\strike strikeout}, {\caps capitals}, {\sub subscript}, {\super superscript}\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Size:} {\fs12 from \fs18 very \fs24 small \fs30 to \fs36 very \fs42 large}\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Positions:} {from \dn6 very \dn12 low \dn0 to \up6 very \up12 high}\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Colors:} {\cf1 text}, {\highlight2 background}\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Underline types:} {\ul normal}, {\uld dotted}, {\uldash dashed}, {\uldashd dash-dotted}, {\uldashdd dash-dot-dotted}, {\ulth thick}, {\ulwave wave}\par" + #CRLF$
  ; rtf$ + "{\f2\fs18 Spacing:} {\expnd8\expndtw40 expanded}, {\expnd-4\expndtw-20 condensed}" + #CRLF$
  ; rtf$ + "}}" + #CRLF$
  
  ; set sub-cue properties header line
  setSubHeader(WQE\lblSubCueType, pSubPtr)
  
  With aSub(pSubPtr)
    macHeaderDisplaySub(aSub(pSubPtr), "E", WQE)
    
    WQE\rchMemoObject\SetCtrlBackColor(\nMemoPageColor)
    If \nMemoTextBackColor <> -1
      WQE\rchMemoObject\SetTextBackColor(\nMemoTextBackColor)
    EndIf
    WQE\rchMemoObject\SetTextColor(\nMemoTextColor)
    WQE\rchMemoObject\SetTextEx(\sMemoRTFText)
    
    SGT(WQE\txtDisplayTime, timeToStringBWZ(\nMemoDisplayTime))
    setOwnState(WQE\chkContinuous, \bMemoContinuous)
    
    nListIndex = indexForComboBoxData(WQE\cboAspectRatio, \nMemoAspectRatio, 0)
    SGS(WQE\cboAspectRatio, nListIndex)
    WQE_fcAspectRatio()
    
    nListIndex = indexForComboBoxData(WQE\cboMemoScreen, \nMemoScreen, 0)
    SGS(WQE\cboMemoScreen, nListIndex)
    WQE_fcMemoScreen()
    setOwnState(WQE\chkResizeFont, \bMemoResizeFont)
    
    WQE_updateToolbar()
    WQE_setStatusbarText()
    
    gbCallEditUpdateDisplay = #True
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQE_createToolbar()
  PROCNAMEC()
  Protected nToolBarGadgetNo
  
  gnNextMiscGadgetNo + 1
  nToolBarGadgetNo = gnNextMiscGadgetNo
  If CreateToolBar(nToolBarGadgetNo, GadgetID(WQE\cntRichEdit))
    ToolBarImageButton(#WQE_mnu_PageColor, ImageID(#WQE_btn_Page_Color))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_PageColor, Lang("WQE", "tbPageColor"))
    ToolBarImageButton(#WQE_mnu_TextBackColor, ImageID(#WQE_btn_Text_Back_Color))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_TextBackColor, Lang("WQE", "tbTextBackColor"))
    ToolBarImageButton(#WQE_mnu_TextColor, ImageID(#WQE_btn_Text_Color))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_TextColor, Lang("WQE", "tbTextColor"))
    ToolBarImageButton(#WQE_mnu_Font, ImageID(#WQE_ico_Font))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Font, Lang("WQE", "tbFont"))
    ToolBarImageButton(#WQE_mnu_Bold, ImageID(#WQE_ico_Bold), #PB_ToolBar_Toggle)
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Bold, Lang("WQE", "tbBold"))
    ToolBarImageButton(#WQE_mnu_Italic, ImageID(#WQE_ico_Italic), #PB_ToolBar_Toggle)
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Italic, Lang("WQE", "tbItalic")) 
    ToolBarImageButton(#WQE_mnu_Underline, ImageID(#WQE_ico_Underline), #PB_ToolBar_Toggle)
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Underline, Lang("WQE", "tbUnderline"))
    ; commented out 'Find' - can't see the point of it for this usage, and it doesn't work particularly well
    ; ToolBarSeparator()
    ; ToolBarImageButton(#WQE_mnu_Search, ImageID(#WQE_ico_Search))
    ; ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Search, Lang("WQE", "tbFind"))
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_Cut, ImageID(#WQE_ico_Cut))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Cut, Lang("WQE", "tbCut"))
    ToolBarImageButton(#WQE_mnu_Copy, ImageID(#WQE_ico_Copy))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Copy, Lang("WQE", "tbCopy"))
    ToolBarImageButton(#WQE_mnu_Paste, ImageID(#WQE_ico_Paste))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Paste, Lang("WQE", "tbPaste"))
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_SelectAll, ImageID(#WQE_ico_SelectAll))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_SelectAll, Lang("WQE", "tbSelectAll"))
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_Undo, ImageID(#WQE_ico_Undo))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Undo, Lang("WQE", "tbUndo"))
    DisableToolBarButton(nToolBarGadgetNo, #WQE_mnu_Undo, #True)
    ToolBarImageButton(#WQE_mnu_Redo, ImageID(#WQE_ico_Redo))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Redo, Lang("WQE", "tbRedo"))
    DisableToolBarButton(nToolBarGadgetNo, #WQE_mnu_Redo, #True)  
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_Left, ImageID(#WQE_ico_Left))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Left, Lang("WQE", "tbLeft"))
    ToolBarImageButton(#WQE_mnu_Center, ImageID(#WQE_ico_Center))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Center, Lang("WQE", "tbCenter"))
    ToolBarImageButton(#WQE_mnu_Right, ImageID(#WQE_ico_Right))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Right, Lang("WQE", "tbRight"))
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_Indent, ImageID(#WQE_ico_Indent))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Indent, Lang("WQE", "tbIndent"))
    ToolBarImageButton(#WQE_mnu_Outdent, ImageID(#WQE_ico_Outdent))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Outdent, Lang("WQE", "tbOutdent"))
    ToolBarSeparator()
    ToolBarImageButton(#WQE_mnu_List, ImageID(#WQE_ico_List))
    ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_List, Lang("WQE", "tbList"))
    ; line spacing not yet working properly - updates control but doesn't seem to save the info correctly for redisplay
    ; ToolBarSeparator()
    ; ToolBarImageButton(#WQE_mnu_Misc, ImageID(#WQE_btn_Misc))
    ; ToolBarToolTip(nToolBarGadgetNo, #WQE_mnu_Misc, LangEllipsis("WQE", "tbMisc"))
  EndIf
  ProcedureReturn nToolBarGadgetNo
EndProcedure

Procedure WQE_createStatusBar()
  PROCNAMEC()
  Protected nStatusBarGadgetNo
  
  gnNextMiscGadgetNo + 1
  nStatusBarGadgetNo = gnNextMiscGadgetNo
  If CreateStatusBar(nStatusBarGadgetNo, GadgetID(WQE\cntRichEdit))
    AddStatusBarField(80)         ; Line
    AddStatusBarField(80)         ; Row
    AddStatusBarField(80)         ; Count
    AddStatusBarField(140)        ; Font
    AddStatusBarField(#PB_Ignore) ; Zoom
    With grWQE
      \nStatusItemLine  = 0
      \nStatusItemCol   = 1
      \nStatusItemCount = 2
      \nStatusItemFont  = 3
      \nStatusItemZoom  = 4
    EndWith
  EndIf
  ProcedureReturn nStatusBarGadgetNo
EndProcedure

Procedure WQE_setStatusbarText()
  PROCNAMEC()
  
  With WQE
    If \rchMemoObject
      StatusBarText(\sbStatusBar, grWQE\nStatusItemLine,  grWQE\sTextLine + Str(\rchMemoObject\GetCursorY()))
      StatusBarText(\sbStatusBar, grWQE\nStatusItemCol,   grWQE\sTextCol + Str(\rchMemoObject\GetCursorX()))
      StatusBarText(\sbStatusBar, grWQE\nStatusItemCount, grWQE\sTextCount + Str(\rchMemoObject\CountWords()))
      StatusBarText(\sbStatusBar, grWQE\nStatusItemFont,  \rchMemoObject\GetFont() + "(" + Str(\rchMemoObject\GetFontSize()) + ")")
      ; debugMsg(sProcName, "\rchMemoObject\GetFont()=" + \rchMemoObject\GetFont())
    Else
      StatusBarText(\sbStatusBar, grWQE\nStatusItemLine,  grWQE\sTextLine + "1")
      StatusBarText(\sbStatusBar, grWQE\nStatusItemCol,   grWQE\sTextCol + "1")
      StatusBarText(\sbStatusBar, grWQE\nStatusItemCount, grWQE\sTextCount + "0")
      StatusBarText(\sbStatusBar, grWQE\nStatusItemFont,  " ")
      StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom,  grWQE\sTextZoom + "100%")
    EndIf
  EndWith
EndProcedure

Procedure WQE_updateToolbar()
  PROCNAMEC()
  
  With WQE
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Bold, \rchMemoObject\GetFontStyle() & #PB_Font_Bold)
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Italic, \rchMemoObject\GetFontStyle() & #PB_Font_Italic)
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Underline, \rchMemoObject\GetFontStyle() & #PB_Font_Underline)  
    
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Left, \rchMemoObject\IsAlignLeft() )
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Center, \rchMemoObject\IsAlignCenter() )
    SetToolBarButtonState(\tbToolBar, #WQE_mnu_Right, \rchMemoObject\IsAlignRight() )
  EndWith
EndProcedure

Procedure WQE_adjustForSplitterSize()
  PROCNAMEC()
  
  ProcedureReturn ; !!!!!!!!!!!!!!!
  
EndProcedure

Procedure WQE_catchImages()
  PROCNAMEC()
  Protected hNewImage
  
  IMG_doCatchImage(hCueTypeMemo, cueType_Memo)
  IMG_doCatchImage(hClMemo, cl_Memo)
  hToolAddQEDi = IMG_buildAddImage(hClMemo, "Q", #False)
  hToolAddQEEn = IMG_buildAddImage(hClMemo, "Q", #True)
  hToolAddSEDi = IMG_buildAddImage(hClMemo, "S", #False)
  hToolAddSEEn = IMG_buildAddImage(hClMemo, "S", #True)
  
  CreateImage(#WQE_btn_Page_Color, 16, 16)
  If StartDrawing(ImageOutput(#WQE_btn_Page_Color))
      Box(0, 0, 16, 16, #SCS_Black)
      Box(1, 1, 14, 14, RGB(254,255,153)) ; preferably make this color match grSubDef\nMemoPageColor (which hasn't been set when WQE_catchImages() is called)
    StopDrawing()
  EndIf

  CatchImage(#WQE_btn_Text_Back_Color, ?WQE_btn_text_back_color)
  CatchImage(#WQE_btn_Text_Color, ?WQE_btn_text_color)
  CatchImage(#WQE_ico_Font, ?WQE_ico_font)
  CatchImage(#WQE_ico_Search, ?WQE_ico_search)
  CatchImage(#WQE_ico_Cut, ?WQE_ico_cut)
  CatchImage(#WQE_ico_Copy, ?WQE_ico_copy)
  CatchImage(#WQE_ico_Paste, ?WQE_ico_paste)
  CatchImage(#WQE_ico_Undo, ?WQE_ico_undo)
  CatchImage(#WQE_ico_Redo, ?WQE_ico_redo)
  CatchImage(#WQE_ico_Bold, ?WQE_ico_bold)
  CatchImage(#WQE_ico_Italic, ?WQE_ico_italic)
  CatchImage(#WQE_ico_Underline, ?WQE_ico_underline)
  CatchImage(#WQE_ico_Left, ?WQE_ico_left)
  CatchImage(#WQE_ico_Center, ?WQE_ico_center)
  CatchImage(#WQE_ico_Right, ?WQE_ico_right)
  CatchImage(#WQE_ico_SelectAll, ?WQE_ico_selectall)
  CatchImage(#WQE_ico_Indent, ?WQE_ico_indent)
  CatchImage(#WQE_ico_Outdent, ?WQE_ico_outdent)
  CatchImage(#WQE_ico_List, ?WQE_ico_list)
  ; CatchImage(#WQE_btn_Misc, ?WQE_btn_misc)
  
EndProcedure

Procedure WQE_drawForm()
  PROCNAMEC()
  
  colorEditorComponent(#WQE)
  
EndProcedure

Procedure WQE_populateCboAspectRatio()
  PROCNAMEC()
  
  With WQE
    ClearGadgetItems(\cboAspectRatio)
    addGadgetItemWithData(\cboAspectRatio, "16:9", #SCS_AR_16_9)
    addGadgetItemWithData(\cboAspectRatio, "4:3", #SCS_AR_4_3)
    addGadgetItemWithData(\cboAspectRatio, "1.85:1", #SCS_AR_185_1)
    addGadgetItemWithData(\cboAspectRatio, "2.35:1", #SCS_AR_235_1)
  EndWith
EndProcedure

Procedure WQE_populateCboMemoScreen()
  PROCNAMEC()
  Protected nMemoScreen
  
  With WQE
    ClearGadgetItems(\cboMemoScreen)
    addGadgetItemWithData(\cboMemoScreen, Lang("WQE", "ScreenPrim2"), 1)
    For nMemoScreen = #SCS_VID_PIC_TARGET_F2 To grLicInfo\nLastVidPicTarget
      addGadgetItemWithData(\cboMemoScreen, LangPars("WQE", "ScreenNr", Str(nMemoScreen)), nMemoScreen)
    Next nMemoScreen
    setComboBoxWidth(\cboMemoScreen)
  EndWith
EndProcedure

Procedure WQE_Form_Load()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  createfmEditQE()
  SUB_loadOrResizeHeaderFields("E", #True)
  WQE_setPreviewBtn(0)
  WQE_setStatusbarText()
  WQE_populateCboAspectRatio()
  
  WQE_drawForm()
  
EndProcedure

Procedure WQE_formValidation()
  PROCNAMEC()
  Protected bValidationOK = #True
  
  If gnValidateGadgetNo <> 0
    bValidationOK = WQE_valGadget(gnValidateGadgetNo)
  EndIf
  
  debugMsg(sProcName, "returning " + strB(bValidationOK))
  ProcedureReturn bValidationOK
EndProcedure

Procedure WQE_valGadget(nGadgetNo)
  PROCNAMECG(nGadgetNo)
  Protected nGadgetPropsIndex, nEventGadgetNoForEvHdlr, nArrayIndex
  Protected bFound = #True
  
  nGadgetPropsIndex = getGadgetPropsIndex(nGadgetNo)
  nEventGadgetNoForEvHdlr = gaGadgetProps(nGadgetPropsIndex)\nGadgetNoForEvHdlr
  nArrayIndex = getGadgetArrayIndex(nGadgetNo)
  
  With WQE
    Select nEventGadgetNoForEvHdlr
        ; header gadgets
        macHeaderValGadget(WQE)
        
        ; detail gadgets
      Case \txtDisplayTime    ; txtDisplayTime
        ETVAL2(WQE_txtDisplayTime_Validate())
        
      Default
        bFound = #False
        
    EndSelect
  EndWith
  
  If bFound
    If gaGadgetProps(nGadgetPropsIndex)\bValidationReqd
      ; validation must have failed
      ProcedureReturn #False
    Else
      ; validation must have succeeded
      ProcedureReturn #True
    EndIf
  Else
    ; gadget doesn't have a validation procedure, so validation is successful
    ProcedureReturn #True
  EndIf
  
EndProcedure

Procedure WQE_EventHandler()
  PROCNAMEC()
  Protected nResult
  Static sSearchText.s
  
  With WQE
    
    Select gnWindowEvent
        
      Case #PB_Event_Gadget
        
        Select gnEventGadgetNoForEvHdlr
            ; header gadgets
            macHeaderEvents(WQE)
            
            ; detail gadgets in alphabetical order
            
          Case \btnPreview ; btnPreview
            WQE_btnPreview_Click()
            
          Case \cboAspectRatio   ; cboAspectRatio
            CBOCHG(WQE_cboAspectRatio_Click())
            
          Case \cboMemoScreen   ; cboMemoScreen
            CBOCHG(WQE_cboMemoScreen_Click())
            
          Case \chkContinuous   ; chkContinuous
            CHKOWNCHG(WQE_chkContinuous_Click())
            
          Case \chkResizeFont   ; chkResizeFont
            CHKOWNCHG(WQE_chkResizeFont_Click())
            
          Case \cntMemoControls, \cntRichEdit, \cntSubDetailE
            ; no action
            
          Case \rchMemo ; rchMemo
            Select gnEventType
              Case #PB_EventType_Change
                WQE_rchMemo_Change()
              Case #PB_EventType_Focus
                ; Debug "Focus"
              Case #PB_EventType_LostFocus
                ; Debug "LostFocus"
            EndSelect
            
          Case \scaMemo   ; scaMemo
            ; no action
            
          Case \txtDisplayTime    ; txtDisplayTime
            Select gnEventType
              Case #PB_EventType_LostFocus
                ETVAL(WQE_txtDisplayTime_Validate())
            EndSelect
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=" + getGadgetName(gnEventGadgetNo) + ", gnEventType=" + decodeEventType() + ", gnEventButtonId=" + gnEventButtonId)
            
        EndSelect
        
      Case #WM_LBUTTONUP, #WM_KEYUP
        If GetActiveGadget() = \rchMemo
          If isCursorOnGadget(\rchMemo)
            WQE_setStatusbarText()
            WQE_updateToolbar()
          EndIf
        EndIf
        
      Case #PB_Event_Menu   ; #PB_Event_Menu
        ; see also WED_EventHandler() in fmEditor.pbi, which is where the menu events #WQE_mnu_DummyFirst To #WQE_mnu_DummyLast are originally caught
        Select gnEventMenu
          Case #WQE_mnu_PageColor
            WQE_mnuPageColor()
            
          Case #WQE_mnu_TextBackColor
            WQE_mnuTextBackColor()
            
          Case #WQE_mnu_TextColor
            WQE_mnuTextColor()
            
          Case #WQE_mnu_Font
            WQE_mnuFont()
            
          Case #WQE_mnu_Search
            sSearchText = InputRequester(Lang("WQE","FindText"), Lang("WQE","Find"), sSearchText)
            If sSearchText
              If \rchMemoObject\FindText(sSearchText) = #False
                scsMessageRequester(Lang("WQE","FindText"), Lang("WQE","NotFound"), #MB_ICONEXCLAMATION)
              EndIf
            EndIf
            
          Case #WQE_mnu_Misc
            WQE_displayMiscMenu()
            
          Case #WQE_mnu_Cut
            \rchMemoObject\Cut()
          Case #WQE_mnu_Copy
            \rchMemoObject\Copy()
          Case #WQE_mnu_Paste
            \rchMemoObject\Paste()
          Case #WQE_mnu_Undo
            \rchMemoObject\Undo()
            DisableToolBarButton(\tbToolBar, #WQE_mnu_Redo, #False)  
          Case #WQE_mnu_Redo
            \rchMemoObject\Redo()
          Case #WQE_mnu_SelectAll
            \rchMemoObject\SelectAll()
          Case #WQE_mnu_List
            \rchMemoObject\SetBulleted()
          Case #WQE_mnu_Bold, #WQE_mnu_Italic, #WQE_mnu_Underline
            nResult = 0
            If GetToolBarButtonState(\tbToolBar, #WQE_mnu_Bold)
              nResult | #PB_Font_Bold
            EndIf
            If GetToolBarButtonState(\tbToolBar, #WQE_mnu_Italic)
              nResult | #PB_Font_Italic
            EndIf
            If GetToolBarButtonState(\tbToolBar, #WQE_mnu_Underline)
              nResult | #PB_Font_Underline
            EndIf
            \rchMemoObject\SetFontStyle(nResult)
          Case #WQE_mnu_Left
            \rchMemoObject\SetAlignment()
          Case #WQE_mnu_Center
            \rchMemoObject\SetAlignment(#PB_Text_Center)
          Case #WQE_mnu_Right
            \rchMemoObject\SetAlignment(#PB_Text_Right)
          Case #WQE_mnu_Indent
            \rchMemoObject\Indent()
          Case #WQE_mnu_Outdent
            \rchMemoObject\Outdent()
          Case #WQE_mnu_pct_10
            \rchMemoObject\SetZoom(10)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_25
            \rchMemoObject\SetZoom(25)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_50
            \rchMemoObject\SetZoom(50)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_75
            \rchMemoObject\SetZoom(75)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_100
            \rchMemoObject\SetZoom(100)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_125
            \rchMemoObject\SetZoom(125)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_150
            \rchMemoObject\SetZoom(150)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_200
            \rchMemoObject\SetZoom(200)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_pct_400
            \rchMemoObject\SetZoom(400)
            StatusBarText(\sbStatusBar, grWQE\nStatusItemZoom, grWQE\sTextZoom + Str(\rchMemoObject\GetZoom()) +"%")
          Case #WQE_mnu_linespacing_1
            \rchMemoObject\SetLineSpacing(1.0)
          Case #WQE_mnu_linespacing_1_5
            \rchMemoObject\SetLineSpacing(1.5)
          Case #WQE_mnu_linespacing_2_0
            \rchMemoObject\SetLineSpacing(2.0)
            
        EndSelect
        
      Default
        ; debugMsg(sProcName, "gnWindowEvent=" + decodeEvent(gnWindowEvent))
        
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WQE_chkContinuous_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nCheckboxState, sUndoDescr.s
  
  nCheckboxState = getOwnState(WQE\chkContinuous)
  sUndoDescr = getOwnText(WQE\chkContinuous)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\bMemoContinuous, sUndoDescr)
      \bMemoContinuous = nCheckboxState
      If \bMemoContinuous
        \nMemoDisplayTime = grSubDef\nMemoDisplayTime
        SGT(WQE\txtDisplayTime, timeToStringBWZ(\nMemoDisplayTime))
      EndIf
      postChangeSubL(u, \bMemoContinuous)
    EndWith
  EndIf
  
EndProcedure

Procedure WQE_cboMemoScreen_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nMemoScreen, GGT(WQE\lblMemoScreen))
      \nMemoScreen = getCurrentItemData(WQE\cboMemoScreen)
      debugMsg(sProcName, "calling loadArrayOutputScreenReqd(" + getSubLabel(nEditSubPtr) + ")")
      loadArrayOutputScreenReqd(nEditSubPtr)
      postChangeSubL(u, \nMemoScreen)
      
      debugMsg(sProcName, "\nMemoScreen=" + Str(\nMemoScreen))
      If \nMemoScreen >= 2
        debugMsg(sProcName, "calling setVidPicTargets()")
        setVidPicTargets()
        SetActiveWindow(#WED) ; added because throws back to main window after setVidPicTargets()
      EndIf
      
    EndWith
  EndIf
  
  WQE_fcMemoScreen()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQE_cboAspectRatio_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  
  debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\nMemoAspectRatio, GGT(WQE\lblAspectRatio))
      \nMemoAspectRatio = getCurrentItemData(WQE\cboAspectRatio)
      postChangeSubL(u, \nMemoAspectRatio)
    EndWith
  EndIf
  
  WQE_fcAspectRatio()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQE_fcAspectRatio()
  PROCNAMEC()
  Protected nTop, nWidth, nHeight
  Protected nToolBarHeight, nStatusBarHeight
  Protected nCntHeight
  Protected nInnerHeight
  
  With WQE
    nToolBarHeight = ToolBarHeight(\tbToolBar)
    nStatusBarHeight = StatusBarHeight(\sbStatusBar)
    
    nWidth = \rchMemoObject\GetWidth()
    Select aSub(nEditSubPtr)\nMemoAspectRatio
      Case #SCS_AR_16_9
        nHeight = nWidth * 9 / 16
      Case #SCS_AR_4_3
        nHeight = nWidth * 3 / 4
      Case #SCS_AR_185_1
        nHeight = nWidth * 100 / 185
      Case #SCS_AR_235_1
        nHeight = nWidth * 100 / 235
    EndSelect
    If nHeight > 0
      \rchMemoObject\Resize(#PB_Ignore,#PB_Ignore,#PB_Ignore,nHeight)
    EndIf
    nCntHeight = nHeight + nToolBarHeight + nStatusBarHeight
    ResizeGadget(\cntRichEdit,#PB_Ignore,#PB_Ignore,#PB_Ignore,nCntHeight)
    
    ; adjust the top position of the controls below \cntRichEdit
    nTop = GadgetY(\cntRichEdit) + GadgetHeight(\cntRichEdit) + 8
    ResizeGadget(\cntMemoControls, #PB_Ignore, nTop, #PB_Ignore, #PB_Ignore)
    
    nHeight = GadgetY(\cntMemoControls) + GadgetHeight(\cntMemoControls)
    ResizeGadget(\cntSubDetailE, #PB_Ignore, #PB_Ignore, #PB_Ignore, nHeight)
    
    nInnerHeight = GadgetY(\cntSubDetailE) + GadgetHeight(\cntSubDetailE) + 8
    SetGadgetAttribute(\scaMemo, #PB_ScrollArea_InnerHeight, nInnerHeight)
    
  EndWith
EndProcedure

Procedure WQE_fcMemoScreen()
  PROCNAMECS(nEditSubPtr)
  Protected bEnableResizeFont
  
  ProcedureReturn ; !!!!!!!!!!
  
  If nEditSubPtr >= 0
    If aSub(nEditSubPtr)\nMemoScreen >= 2
      bEnableResizeFont = #True
    EndIf
  EndIf
  setOwnEnabled(WQE\chkResizeFont, bEnableResizeFont)
  
EndProcedure

Procedure WQE_chkResizeFont_Click()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected nCheckboxState, sUndoDescr.s
  
  nCheckboxState = getOwnState(WQE\chkResizeFont)
  sUndoDescr = getOwnText(WQE\chkResizeFont)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      u = preChangeSubL(\bMemoResizeFont, sUndoDescr)
      \bMemoResizeFont = nCheckboxState
      postChangeSubL(u, \bMemoResizeFont)
    EndWith
  EndIf
  
EndProcedure

Procedure WQE_txtDisplayTime_Validate()
  PROCNAMECS(nEditSubPtr)
  Protected nTime
  Protected u
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      
      If validateTimeField(GGT(WQE\txtDisplayTime), GGT(WQE\lblDisplayTime), #False, #False) = #False
        ProcedureReturn #False
      ElseIf GGT(WQE\txtDisplayTime) <> gsTmpString
        SGT(WQE\txtDisplayTime, gsTmpString)
      EndIf
      
      nTime = stringToTime(GGT(WQE\txtDisplayTime))
      If nTime <> \nMemoDisplayTime
        u = preChangeSubL(\nMemoDisplayTime, GGT(WQE\lblDisplayTime))
        \nMemoDisplayTime = nTime
        If \nMemoDisplayTime > 0
          \bMemoContinuous = #False
          If getOwnState(WQE\chkContinuous) <> #PB_Checkbox_Unchecked
            setOwnState(WQE\chkContinuous, #PB_Checkbox_Unchecked)
          EndIf
        EndIf
        postChangeSubL(u, \nMemoDisplayTime)
      EndIf
      
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
  ProcedureReturn #True
EndProcedure

Procedure WQE_mnuPageColor()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedColor
  Protected nCurrColor
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; nSelectedColor = ColorRequester(\nMemoPageColor)
      nCurrColor = GetGadgetColor(WQE\rchMemo, #PB_Gadget_BackColor)
      nSelectedColor = ColorRequester(nCurrColor)
      If nSelectedColor > -1
        If nSelectedColor <> \nMemoPageColor
          \nMemoPageColor = nSelectedColor
          WQE\rchMemoObject\SetCtrlBackColor(nSelectedColor)
          ; nb the above forces #PB_EventType_Change on \rchMemo, which calls WQE_rchMemo_Change() which handles undo/redo processing, so no need for pre/post change in this current procedure
          grWEN\nLastMemoPageColor = nSelectedColor
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQE_mnuTextColor()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedColor
  Protected nCurrColor
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; nSelectedColor = ColorRequester(\nMemoTextColor)
      nCurrColor = WQE\rchMemoObject\GetTextColor()
      nSelectedColor = ColorRequester(nCurrColor)
      debugMsg(sProcName, "nCurrColor=$" + Hex(nCurrColor) + ", nSelectedColor=$" + Hex(nSelectedColor) + ", \nMemoTextColor=$" + Hex(\nMemoTextColor))
      If nSelectedColor > -1
        If nSelectedColor <> \nMemoTextColor
          \nMemoTextColor = nSelectedColor
          debugMsg(sProcName, "calling WQE\rchMemoObject\SetTextColor($" + Hex(nSelectedColor) + ")")
          WQE\rchMemoObject\SetTextColor(nSelectedColor)
          ; nb the above forces #PB_EventType_Change on \rchMemo, which calls WQE_rchMemo_Change() which handles undo/redo processing, so no need for pre/post change in this current procedure
          grWEN\nLastMemoTextColor = nSelectedColor
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQE_mnuTextBackColor()
  PROCNAMECS(nEditSubPtr)
  Protected nSelectedColor
  Protected nCurrColor
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; nSelectedColor = ColorRequester(\nMemoTextBackColor)
      nCurrColor = WQE\rchMemoObject\GetTextBackColor()
      nSelectedColor = ColorRequester(nCurrColor)
      debugMsg(sProcName, "nCurrColor=$" + Hex(nCurrColor) + ", nSelectedColor=$" + Hex(nSelectedColor) + ", \nMemoTextBackColor=$" + Hex(\nMemoTextBackColor))
      If nSelectedColor > -1
        If nSelectedColor <> \nMemoTextBackColor
          \nMemoTextBackColor = nSelectedColor
          debugMsg(sProcName, "calling WQE\rchMemoObject\SetTextBackColor($" + Hex(nSelectedColor) + ")")
          WQE\rchMemoObject\SetTextBackColor(nSelectedColor)
          ; nb the above forces #PB_EventType_Change on \rchMemo, which calls WQE_rchMemo_Change() which handles undo/redo processing, so no need for pre/post change in this current procedure
          grWEN\nLastMemoTextBackColor = nSelectedColor
        EndIf
      EndIf
    EndWith
  EndIf
EndProcedure

Procedure WQE_mnuFont()
  PROCNAMECS(nEditSubPtr)
  Protected nColor, nStyle
  Protected nResult
  
  With WQE
    nColor = \rchMemoObject\GetTextColor()
    nStyle = \rchMemoObject\GetFontStyle()
    nResult = FontRequester(\rchMemoObject\GetFont(), \rchMemoObject\GetFontSize(), #PB_FontRequester_Effects, nColor, nStyle)
    If nResult
      \rchMemoObject\SetFont(SelectedFontName())
      \rchMemoObject\SetFontSize(SelectedFontSize())
      \rchMemoObject\SetFontStyle(SelectedFontStyle())
      \rchMemoObject\SetTextColor(SelectedFontColor())
      ; nb the above forces #PB_EventType_Change on \rchMemo, which calls WQE_rchMemo_Change() which handles undo/redo processing, so no need for pre/post change in this current procedure
      SetToolBarButtonState(\tbToolBar, #WQE_mnu_Bold, SelectedFontStyle() & #PB_Font_Bold)
      SetToolBarButtonState(\tbToolBar, #WQE_mnu_Italic, SelectedFontStyle() & #PB_Font_Italic)
      SetToolBarButtonState(\tbToolBar, #WQE_mnu_Underline, SelectedFontStyle() & #PB_Font_Underline)
    EndIf
  EndWith
  
EndProcedure

Procedure WQE_rchMemo_Change()
  PROCNAMECS(nEditSubPtr)
  Protected u
  Protected sNewRTFText.s
  Protected nCanPaste
  Static sUndoDescr.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sUndoDescr = Lang("WQE", "lblMemo")
    bStaticLoaded = #True
  EndIf
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nCanPaste = WQE\rchMemoObject\CanPaste()
      debugMsg(sProcName, "nCanPaset=" + nCanPaste)
      sNewRTFText = WQE\rchMemoObject\GetRTFText()
      If sNewRTFText <> \sMemoRTFText
        u = preChangeSubS(\sMemoRTFText, sUndoDescr)
        debugMsg(sProcName, "BEFORE: Len(\sMemoRTFText)=" + Len(\sMemoRTFText) + ": " + \sMemoRTFText)
        \sMemoRTFText = sNewRTFText
        debugMsg(sProcName, "AFTER:  Len(\sMemoRTFText)=" + Len(\sMemoRTFText) + ": " + \sMemoRTFText)
        WQE_resetSubDescrIfReqd()
        postChangeSubS(u, \sMemoRTFText)
      EndIf
      WQE_setStatusbarText()
      DisableToolBarButton(WQE\tbToolBar, #WQE_mnu_Undo, WQE\rchMemoObject\CanUndo() ! 1)
      WQE_updateToolbar()
    EndWith
  EndIf
  
EndProcedure

Procedure WQE_resetSubDescrIfReqd()
  PROCNAMECS(nEditSubPtr)
  Protected sOldSubDescr.s
  Protected sMemoText.s
  Protected bCueChanged, bSubChanged
  Protected u2
  Protected sSendType.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      ; debugMsg(sProcName, "\bDefaultSubDescrMayBeSet=" + strB(\bDefaultSubDescrMayBeSet))
      If \bDefaultSubDescrMayBeSet
        sOldSubDescr = \sSubDescr
        sMemoText = Trim(WQE\rchMemoObject\GetText())                   ; trim spaces from start and end
        ; Debug "sMemoText=" + Left(sMemoText,50)
        sMemoText = ReplaceString(sMemoText, Chr(13)+Chr(10), Chr(10))  ; replace all CRLF by LF
        sMemoText = LTrim(sMemoText, Chr(10))                           ; remove leading LF characters
        sMemoText = StringField(sMemoText, 1, Chr(10))                  ; use first line of memo text
        If Len(sMemoText) > 40
          sMemoText = Trim(Left(sMemoText,40)) + "..."                  ; limit to 40 characters of the text
        EndIf
        debugMsg(sProcName, "sMemoText=[" + sMemoText + "]")
        debugMsg(sProcName, "\sSubDescr=[" + \sSubDescr + "]")
        debugMsg(sProcName, "GGT(WQE\txtSubDescr)=[" + GGT(WQE\txtSubDescr) + "]")
        If Len(sMemoText) > 0
          \sSubDescr = sMemoText
          If GGT(WQE\txtSubDescr) <> \sSubDescr
            debugMsg(sProcName, "CHANGED")
            SGT(WQE\txtSubDescr, \sSubDescr)
            setSubDescrToolTip(WQE\txtSubDescr)
            WED_setSubNodeText(nEditSubPtr)
            bSubChanged = #True
            If \nPrevSubIndex = -1
              If aCue(\nCueIndex)\sCueDescr = sOldSubDescr
                u2 = preChangeCueS(aCue(nEditCuePtr)\sCueDescr, grText\sTextDescription)
                aCue(nEditCuePtr)\sCueDescr = \sSubDescr
                bCueChanged = #True
                If GGT(WEC\txtDescr) <> aCue(nEditCuePtr)\sCueDescr
                  SGT(WEC\txtDescr, aCue(nEditCuePtr)\sCueDescr)
                  WED_setCueNodeText(nEditCuePtr)
                  aCue(nEditCuePtr)\sValidatedDescr = aCue(nEditCuePtr)\sCueDescr
                EndIf
                postChangeCueS(u2, aCue(nEditCuePtr)\sCueDescr)
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
      
      If bCueChanged
        loadGridRow(nEditCuePtr)
      EndIf
      
      If bSubChanged
        If \nPrevSubIndex >= 0 Or \nNextSubIndex >= 0
          ; multiple sub-cues
          WED_setCueNodeText(nEditCuePtr)
        EndIf
      EndIf
      
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WQE_setPreviewBtn(nPreviewBtnState)
  PROCNAMEC()
  
  With WQE
    If IsGadget(\btnPreview)   ; IsGadget() test included as procedure may be called from other than #WQE
      Select nPreviewBtnState
        Case -1
          SGT(\btnPreview, Lang("WQE", "btnPreview"))
          setEnabled(\btnPreview, #False)
          
        Case 0
          SGT(\btnPreview, Lang("WQE", "btnPreview"))
          setEnabled(\btnPreview, #True)
          
        Case 1
          SGT(\btnPreview, Lang("WQE", "CancelPreview"))
          setEnabled(\btnPreview, #True)
          
      EndSelect
      grWQE\nPreviewBtnState = nPreviewBtnState
    EndIf
  EndWith
EndProcedure

Procedure WQE_closeMemoPreviewIfReqd()
  PROCNAMEC()
  
  If grWQE\nPreviewMemoScreen > 0
    Select grWQE\nPreviewMemoScreen
      Case 1
        If IsWindow(#WE2)
          WEN_Form_Unload(#WE2)
        EndIf
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        debugMsg(sProcName, "calling hideMemoOnSecondaryScreen(" + decodeVidPicTarget(grWQE\nPreviewMemoScreen) + ")")
        WEN_hideMemoOnSecondaryScreen(grWQE\nPreviewMemoScreen)
    EndSelect
    WQE_setPreviewBtn(0)  ; change btn to 'preview' (if it exists)
    grWQE\nPreviewMemoScreen = 0
  EndIf
EndProcedure

Procedure WQE_btnPreview_Click()
  PROCNAMECS(nEditSubPtr)
  Protected nUseScreenNo, nWindowNo
  
  If nEditSubPtr >= 0
    With aSub(nEditSubPtr)
      nUseScreenNo = \nMemoScreen
      If nUseScreenNo > gnScreens
        nUseScreenNo = gnScreens
      EndIf
      If grWQE\nPreviewBtnState = 0
        ; preview
        Select nUseScreenNo
          Case 1
            WEN_Form_Show(#WE2, nEditSubPtr)
            WQE_setPreviewBtn(-1)  ; disable preview btn
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            nWindowNo = #WV2 + nUseScreenNo - #SCS_VID_PIC_TARGET_F2
            debugMsg(sProcName, "IsWindow(" + decodeWindow(nWindowNo) + ")=" + IsWindow(nWindowNo))
            If IsWindow(nWindowNo) = #False
              debugMsg(sProcName, "calling setVidPicTargets()")
              setVidPicTargets()
            EndIf
            debugMsg(sProcName, "calling displayMemoOnSecondaryScreen(" + getSubLabel(nEditSubPtr) + ", " + nUseScreenNo + ")")
            WEN_displayMemoOnSecondaryScreen(nEditSubPtr, nUseScreenNo)
            WQE_setPreviewBtn(1)  ; change btn to 'cancel preview'
        EndSelect
        grWQE\nPreviewMemoScreen = nUseScreenNo
        
      Else
        ; cancel preview
        Select nUseScreenNo
          Case 1
            If IsWindow(#WE2)
              WEN_Form_Unload(#WE2)
            EndIf
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            debugMsg(sProcName, "calling hideMemoOnSecondaryScreen(" + decodeVidPicTarget(nUseScreenNo) + ")")
            WEN_hideMemoOnSecondaryScreen(nUseScreenNo)
        EndSelect
        WQE_setPreviewBtn(0)  ; change btn to 'preview'
        grWQE\nPreviewMemoScreen = 0
        
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WQE_displayMiscMenu()
  Protected sLineSpacing.s
  
  sLineSpacing = Lang("WQE","mnuLineSpacing")
  scsCreatePopupMenu(#WQE_mnu_misc_popup_menu)
  scsMenuItem(#WQE_mnu_linespacing_1  , sLineSpacing + " 1.0")
  scsMenuItem(#WQE_mnu_linespacing_1_5, sLineSpacing + " 1.5")
  scsMenuItem(#WQE_mnu_linespacing_2_0, sLineSpacing + " 2.0")
  MenuBar()
  scsMenuItem(#WQE_mnu_pct_10, "10%")
  scsMenuItem(#WQE_mnu_pct_25, "25%")
  scsMenuItem(#WQE_mnu_pct_50, "50%")
  scsMenuItem(#WQE_mnu_pct_75, "75%")
  scsMenuItem(#WQE_mnu_pct_100, "100%")
  scsMenuItem(#WQE_mnu_pct_125, "125%")
  scsMenuItem(#WQE_mnu_pct_150, "150%")
  scsMenuItem(#WQE_mnu_pct_200, "200%")
  scsMenuItem(#WQE_mnu_pct_400, "400%")
  DisplayPopupMenu(#WQE_mnu_misc_popup_menu, WindowID(#WED))
EndProcedure

Procedure WQE_addMenuZoom()
  PROCNAMEC()
  
  MenuItem(#WQE_mnu_pct_10, "10%")
  MenuItem(#WQE_mnu_pct_25, "25%")
  MenuItem(#WQE_mnu_pct_50, "50%")
  MenuItem(#WQE_mnu_pct_75, "75%")
  MenuItem(#WQE_mnu_pct_100, "100%")
  MenuItem(#WQE_mnu_pct_125, "125%")
  MenuItem(#WQE_mnu_pct_150, "150%")
  MenuItem(#WQE_mnu_pct_200, "200%")
  MenuItem(#WQE_mnu_pct_400, "400%")
EndProcedure

Procedure WQE_reposMemo(pSubPtr, pReposAt)
  PROCNAMECS(pSubPtr)
  Protected bChangedToReady
  
  debugMsg(sProcName, #SCS_START + ", pReposAt=" + Str(pReposAt))
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If (\bMemoContinuous = #False) And (\nMemoDisplayTime > 0)
        \nSubPosition = pReposAt
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + Str(\nSubPosition))
        If \nSubPosition < 0
          \nSubPosition = 0
        ElseIf (\nMemoDisplayTime > 0) And (\nSubPosition > \nMemoDisplayTime)
          \nSubPosition = \nMemoDisplayTime
        EndIf
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + Str(\nSubPosition))
        If (\nSubState < #SCS_CUE_FADING_IN) Or (\nSubState > #SCS_CUE_FADING_OUT)
          \bSubCheckProgSlider = #True
        Else
          \bSubCheckProgSlider = #False
        EndIf
        
        \qAdjTimeSubStarted = gqTimeNow - pReposAt
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\qAdjTimeSubStarted=" + traceTime(\qAdjTimeSubStarted) +
                            ", \nSubState=" + decodeCueState(\nSubState) + ", \nSubPosition=" + Str(\nSubPosition))
        \nSubTotalTimeOnPause = 0
        If \nSubState = #SCS_CUE_PAUSED
          \nSubPriorTimeOnPause = 0
          \qSubTimePauseStarted = gqTimeNow
          debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nSubPosition=" + Str(\nSubPosition))
          If \nSubPosition = 0
            \nSubState = #SCS_CUE_READY
            setCueState(\nCueIndex)
            bChangedToReady = #True
          EndIf
        EndIf
        
        If bChangedToReady
          gqMainThreadRequest | #SCS_MTH_SET_CUE_TO_GO
        EndIf
        
        If \nSubState = #SCS_CUE_PAUSED
          \nSubPriorTimeOnPause = 0
          \qSubTimePauseStarted = gqTimeNow
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF

; IDE Options = PureBasic 5.70 LTS (Windows - x64)
; CursorPosition = 854
; FirstLine = 838
; Folding = ------
; EnableThread
; EnableXP
; EnableOnError
; CPU = 1
; EnableUnicode