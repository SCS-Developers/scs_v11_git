; File: fmDMXTest.pbi

EnableExplicit

Procedure WDT_btnClear_Click()
  PROCNAMEC()
  
  ClearGadgetItems(WDT\lstTestDMXInfo)
  SAG(-1)
EndProcedure

Procedure WDT_btnOK_Click()
  WDT_Form_Unload()
EndProcedure

Procedure WDT_Form_Load()
  PROCNAMEC()
  Protected m, n, sRowTitle.s
  Protected nLeft, nTop
  
  If IsWindow(#WDT) = #False
    createfmDMXTest()
  EndIf
  setFormPosition(#WDT, @grDMXTestWindow)

  ClearGadgetItems(WDT\lstTestDMXInfo)
  
  With grWDT
    
    If grWEP\nCurrentCueDevNo >= 0
      \nDMXInPref = grProdForDevChgs\aCueCtrlLogicalDevs(grWEP\nCurrentCueDevNo)\nDMXInPref
    Else
      ; shouldn't happen
      \nDMXInPref = #SCS_DMX_NOTATION_0_255
    EndIf
    
    If \nDMXInPref = #SCS_DMX_NOTATION_0_255
      SGT(WDT\lblChannelValues, Lang("DMX", "ValNum"))
    ElseIf \nDMXInPref = #SCS_DMX_NOTATION_PERCENT
      SGT(WDT\lblChannelValues, Lang("DMX", "ValPercent"))
    EndIf
    
    If StartDrawing(CanvasOutput(WDT\cvsDMXReceived))
      \nCanvasWidth = GadgetWidth(WDT\cvsDMXReceived)
      \nCanvasHeight = GadgetHeight(WDT\cvsDMXReceived)
      \nCanvasBackColor = #SCS_Very_Light_Grey
      Box(0,0,\nCanvasWidth,\nCanvasHeight,\nCanvasBackColor)
      DrawingMode(#PB_2DDrawing_Transparent)
      scsDrawingFont(#SCS_FONT_GEN_NORMAL)
      \nTextHeight = TextHeight("8")
      \nRowHeight = (\nCanvasHeight - gl3DBorderHeight - gl3DBorderHeight) >> 4   ; 16 rows
      If \nTextHeight < \nRowHeight - 1
        \nTopMargin = (\nRowHeight - 1 - \nTextHeight) >> 1
      Else
        \nTopMargin = 0
      EndIf
      \nColWidth = 24
      \nTitleWidth = (\nCanvasWidth - gl3DBorderAllowanceX) - (\nColWidth << 5)
      nLeft = 4
      For n = 1 To 16
        m = ((n - 1) * 32) + 1
        sRowTitle = Str(m) + "-" + Str(m+31)
        nTop = ((n-1) * \nRowHeight) + gl3DBorderHeight + \nTopMargin
        DrawText(nLeft, nTop, sRowTitle, #SCS_Black)
        If n < 16
          LineXY(0,nTop+\nRowHeight-2,\nCanvasWidth,nTop+\nRowHeight,#SCS_Light_Grey)
        EndIf
      Next n
      For m = 1 To 32
        nLeft = ((m-1) * \nColWidth) + \nTitleWidth
        LineXY(nLeft,0,nLeft,\nCanvasHeight,#SCS_Light_Grey)
      Next m
      StopDrawing()
    EndIf
  EndWith
  
  setWindowVisible(#WDT, #True)
  SAG(-1)
  
EndProcedure

Procedure WDT_Form_Show(bModal=#False)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsWindow(#WDT) = #False
    WDT_Form_Load()
  EndIf
  setWindowModal(#WDT, bModal)
  setWindowVisible(#WDT, #True)
  SAW(#WDT)
  grDMX\bDMXTestWindowFirstRead = #True
  grDMX\bDMXTestWindowActive = #True
EndProcedure

Procedure WDT_Form_Unload()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  grDMX\bDMXTestWindowActive = #False
  getFormPosition(#WDT, @grDMXTestWindow)
  grDMX\bDMXTestWindowFirstRead = #False
  unsetWindowModal(#WDT)
  scsCloseWindow(#WDT)
EndProcedure

Procedure WDT_EventHandler()
  PROCNAMEC()
  
  With WDT
    Select gnWindowEvent
        
      Case #PB_Event_CloseWindow
        WDT_Form_Unload()
        
      Case #PB_Event_Menu
        gnEventMenu = EventMenu()
        Select gnEventMenu
            
          Case #SCS_mnuKeyboardReturn   ; Return
            WDT_Form_Unload()
            
          Case #SCS_mnuKeyboardEscape   ; Escape
            WDT_Form_Unload()
            
        EndSelect
        
      Case #PB_Event_Gadget
        ;debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo)
        Select gnEventGadgetNoForEvHdlr
          Case \btnClear
            WDT_btnClear_Click()
            
          Case \btnOK
            WDT_btnOK_Click()
            
          Case \cvsDMXReceived
            ; ignore canvas events
            
          Default
            debugMsg(sProcName, "gnEventGadgetNo=G" + gnEventGadgetNo + ", gnEventType=" + decodeEventType())
        EndSelect
        
    EndSelect
  EndWith
  
EndProcedure

; EOF