; File: MultiLineTooltip.pbi

; from RASHAD's forum topic "Gadget ToolTip Normal and By Command [Windows]" 13Apr2014
; slightly modified

EnableExplicit

Global TTip,ti.TOOLINFO

#TTS_BUBBLE = $40
#TTF_TRACK       =  $20
#TTF_ABSOLUTE  =  $80

ti.TOOLINFO
ti\cbSize = SizeOf(ti) 
ti\hInst = GetModuleHandle_(0)

TTip = CreateWindowEx_(#WS_EX_TOPMOST, "tooltips_class32", 0, #TTS_ALWAYSTIP| #TTS_NOPREFIX| #WS_POPUP| #TTS_BUBBLE,0,0,0,0, 0, 0, GetModuleHandle_(0), 0)
  ; SetWindowTheme_(TTip, @null.w, @null.w)
  ;SendMessage_(TTip,#WM_SETFONT,FontID,0)
  SendMessage_(TTip,#TTM_SETTIPTEXTCOLOR,$0202FD,0)
  SendMessage_(TTip,#TTM_SETTIPBKCOLOR,$DCFFFF,0)
  

Procedure GadToolTip(Gadget,Tip$,MaxWidth.l=0)
  ti\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
  ti\hwnd = GadgetID(Gadget) 
  ti\uId = GadgetID(Gadget)
  ti\lpszText = @Tip$;"Gadget # 1 Tooltip"  
  SendMessage_(TTip, #TTM_SETDELAYTIME, #TTDT_AUTOPOP, 30000)
  SendMessage_(TTip, #TTM_SETMAXTIPWIDTH, 0, MaxWidth)
  SendMessage_(TTip, #TTM_UPDATE, 0, 0)
  SendMessage_(TTip, #TTM_ADDTOOL, 0, ti)
EndProcedure

Procedure TTip_Command(Gadget,x,y,dTime,Title$,Tip$,Icon)
  ti\uFlags = #TTF_TRACK | #TTF_ABSOLUTE
  ti\hwnd = GadgetID(Gadget)
  ti\uId = GadgetID(Gadget)
  ti\lpszText = @Tip$
  SendMessage_(TTip,#TTM_SETTOOLINFO,0,ti)
  SendMessage_(TTip, #TTM_SETTITLE, Icon, @Title$)
  SendMessage_(TTip,#TTM_TRACKPOSITION,0,x+y<<16)
  SendMessage_(TTip,#TTM_TRACKACTIVATE,1,ti)                      
  SendMessage_(TTip,#TTM_TRACKPOSITION,0,x + 50 + y<<16)                      
  Delay(dTime)
  SendMessage_(TTip,#TTM_TRACKACTIVATE,0,ti)
  ti\uFlags = #TTF_IDISHWND | #TTF_SUBCLASS
  SendMessage_(TTip,#TTM_SETTOOLINFO,0,ti)
EndProcedure

CompilerIf #PB_Compiler_IsMainFile
  Global Quit, p.POINT, hGad, x, y
  
  If OpenWindow(0, 0, 0, 300, 300, "Tooltips by Command",#PB_Window_ScreenCentered| #PB_Window_SystemMenu)  
    
    ButtonGadget(0,10,10,80,20,"TEST # 0")
    GadToolTip(0,"This is a test for"+#CRLF$ + "Multiline Balloon")
    
    ButtonGadget(1,10,40,80,20,"TEST # 1")
    GadToolTip(1,"Gadget # 1 Tooltip") 
    
    StringGadget(2,10,70,120,20,"This is a test")
    GadToolTip(2,"Gadget # 2 Tooltip") 
    
    ButtonGadget(3,10,260,80,20,"TEST 0")
    ButtonGadget(4,100,260,80,20,"TEST 1")
    CanvasGadget(5,10,100,120,20,#PB_Canvas_Border)
    
    
    Repeat
      Select WaitWindowEvent()      
        Case #PB_Event_CloseWindow
          Quit = 1
          
        Case #WM_MOUSEMOVE      
          If 1=2
            GetCursorPos_ (@p.POINT) 
            ScreenToClient_ (WindowID(0), @p)              
            hGad = ChildWindowFromPoint_ (WindowID(0),  p\y<< 32+p\x)
            Select hGad
              Case GadgetID(0)
                ; SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_WARNING_ICON, @"Hi")
                ; SendMessage_(TTip, #TTM_SETTITLE, 0, 0)
                GadToolTip(0,"This is test 2 for"+#CRLF$ + "Multiline Balloon")
                SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_NO_ICON, @"Graph Help")
              Case GadgetID(1)
                SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_ERROR_ICON, @"Remember")
              Case GadgetID(2)
                SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_INFO_ICON, @"Info")
            EndSelect
          EndIf
          
        Case #PB_Event_Gadget
          ; Debug "#PB_Event_Gadget, EventGadget()=" + EventGadget()
          Select EventGadget()
            Case 5
              Select EventType()
                Case #PB_EventType_MouseMove
                  GadToolTip(5,"This is test 3 for"+#CRLF$ + "Multiline Balloon")
                  SendMessage_(TTip, #TTM_SETTITLE, #TOOLTIP_NO_ICON, @"Graph Help")
              EndSelect
              
            Case 3
              Debug "3"
              x = GadgetX(0,#PB_Gadget_ScreenCoordinate)
              y = GadgetY(0,#PB_Gadget_ScreenCoordinate)
              TTip_Command(0,x,y,1000,"Hi","This is a test for"+#CRLF$+"Multiline Balloon",#TOOLTIP_WARNING_ICON)
              
            Case 4
              Debug "4"
              x = GadgetX(1,#PB_Gadget_ScreenCoordinate)
              y = GadgetY(1,#PB_Gadget_ScreenCoordinate)
              TTip_Command(1,x,y,1000,"Remember", "Gadget # 1 Tooltip",#TOOLTIP_INFO_ICON)
              
          EndSelect          
      EndSelect 
      
    Until Quit = 1
    End
    
  EndIf
CompilerEndIf

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 31
; FirstLine = 18
; Folding = -
; EnableThread
; EnableXP
; EnableOnError