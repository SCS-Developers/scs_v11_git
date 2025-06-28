; /**********************************************************************************
; | TouchScreenKeyboard.pbi
; | 
; | Unfinished module for using Touch Screen Keyboard
; | 15/Jul/2021 - holzhacker - romerio@gmail.com
; | 
; | To do: 
; |       Add new layout for function keys
; |       Add hooks for calling functions when pressing a function key
; |       Add Viewer to Calculator Layout
; |       And other crazy ideas that can come up
; |
; \**********************************************************************************


Macro IncludeModule(ModName, PureBasisModuleFile, UseMod = #False)
  CompilerIf Not Defined(ModName, #PB_Module)
    XIncludeFile PureBasisModuleFile
    If UseMod
      UseModule ModName
    EndIf 
  CompilerEndIf
EndMacro


; IncludeModule(WindowTransparent, "../SetWindowTransparent_WinLin/SetWindowTransparent_WinLin.pbi")
; IncludeModule(CWMove,            "../MyCanvasWindowMover/MyCanvasWindowMover.pbi")
; IncludeModule(Simulate,          "../SendKeys_WinLin/SendKeys_WinLin.pbi")
; IncludeModule(TaskBarInfo,       "../TaskBarInfo/TaskBarInfo.pbi")

DeclareModule TouchScreenKeyboard 
  
;   Global Keyboard\WindowFather
  
  Global Canvas_keyboard
  
  Structure screen
    width.i
    height.i
  EndStructure
  Global screen.screen
  
  Structure keys
    x.i
    y.i
    Width.i
    Height.i
    Text.s
    active.i
    Hover.i
    FontSize.i
    FontSizeHover.i
    BackColor.i
    FrontColor.i
    Type.i
  EndStructure
  
  Global NewMap key.keys()
  Global NewMap keys.s()
  
  Structure Keyboard
    GadgetID.i
    WindowFather.i
    WindowKeyboard.i
    x.i
    y.i
    w.i
    h.i
    CapslockActive.i
    ShiftActive.i
    KeyboartVisible.i
    KeyboartStarted.i
    KeyboardMove.i
    KeyboardDirection.i
    KeyboardFixed.i
    ComplementTaskBar.i
  EndStructure
  
  Global Keyboard.Keyboard
  
  Global NewMap Keyboard.Keyboard()
  
  
  Global ShiftActive = #False 
  Global SwitchKeyboard
  
  Enumeration
    #EscapeKeyboard
  EndEnumeration
  
  Enumeration #PB_Compiler_EnumerationValue
    #Keyborad
    #LeftClickDown
  EndEnumeration
  
  Enumeration #PB_Compiler_EnumerationValue
    #BackSpace
    #Return
    #Shift
    #Escape
    #Space
    #_123
  EndEnumeration
  
  Enumeration 0
    #Keyboard
    #KeyboardNum
    #KeyboardConfig
  EndEnumeration
  
  Enumeration 0
    #Up
    #Down
  EndEnumeration
    
  Enumeration 0
    #Create
    #Hide
  EndEnumeration
  
  Global CreateOrHide = #Hide
  
  Global Action = #Keyboard
  
  NewMap KeyboardLimitStart.i()
  NewMap KeyboardLimitStop.i()
  
  KeyboardLimitStart(Str(#Keyboard)) = 1
  KeyboardLimitStop(Str(#Keyboard))  = 33
  
  KeyboardLimitStart(Str(#KeyboardNum)) = 34
  KeyboardLimitStop(Str(#KeyboardNum))  = 49

  CompilerIf #PB_Compiler_OS = #PB_OS_Linux
    CompilerIf Not Defined(gtk_entry_set_alignment, #PB_Procedure)
      ImportC ""
      	gtk_entry_set_alignment(*entry.GtkEntry, xalign.f)
      EndImport
    CompilerEndIf
  CompilerEndIf
    
  Restore _keys_
  For i=1 To 52
    Read.s keys(Str(i))
    ;Debug Str(i)+"...: " + keys(Str(i))
  Next   
  
  DataSection
    _keys_:
    Data.s "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", 
           "a", "s", "d", "f", "g", "h", "j", "k", "l",
           "z", "x", "c", "v", "b", "n", "m",
           "shift", "backspace", "?123", "escape", "space", "...", "return",
           "7", "8", "9", "/", "*", "4", "5", "6", "-", "+", "1", "2", "3", ".", "abc", "escape2", "0", "backspace2", "="
  EndDataSection    
  
  
  Declare  StartKeyboard(GadgetID.i = #PB_Ignore, WindowID.i = #PB_Ignore, Move.i = #False, Direction.i = #Down, Fixed.i =  #False)
  Declare  OpenWindow_KB(x = 0, y = 0, width = 480, height = 195)
  ;Declare  Window_KB_Events(event)
  Declare  OnEventsKeyboard(Event)
  Declare  _CreateKeyboard()
  Declare  _Draw()
  
  Declare  SetKeyboarFocus(Gadget)
  Declare  SetActiveKeyboard(Active.i = #True)
  
  Declare  RegisterGadget(Gadget.i)
  
  
EndDeclareModule

Module TouchScreenKeyboard

;   XIncludeFile "TouchScreenKeyboard.pbf"
  
  ;{- Temporary code   
  Global Window_KB
  
  Global Canvas_keyboard
  
  
  Procedure OpenWindow_KB(x = 0, y = 0, width = 480, height = 195)
    ; Window_KB = OpenWindow(#PB_Any, x, y, width, height, "", #PB_Window_BorderLess, WindowID(Window_Father))
    Window_KB = OpenWindow(#PB_Any, x, y, width, height, "", #PB_Window_BorderLess, WindowID(keyboard\WindowFather))
    HideWindow(Window_KB, 1)
    Canvas_keyboard = CanvasGadget(#PB_Any, 0, 0, 480, 195, #PB_Canvas_ClipMouse | #PB_Canvas_Keyboard)
  EndProcedure
  ;}
 
  Procedure _SetActiveKey(key.s, origim.i=#Keyborad)
    key(key)\BackColor =$FFFF0000
    key(key)\FrontColor = $FF00DDFF  
    If origim.i=#LeftClickDown
      key(key)\FontSize = 23
    Else
      key(key)\FontSize = 25
    EndIf 
    key()\Hover = #True 
  EndProcedure
    


  Procedure SetPositionToEnd(Gadget.i)  
    Protected.i tam
    Protected.s txt, char
    tam = Len(GetGadgetText(Gadget))
    txt = GetGadgetText(Gadget)
       
    ;SetGadgetText(Gadget, txt)
    SetActiveGadget(Gadget)
    CompilerIf #PB_Compiler_OS = #PB_OS_Linux
      gtk_editable_set_position_(GadgetID(Gadget), tam)
    CompilerElse
      SendMessage_(GadgetID(Gadget), #EM_SETSEL, tam, tam) 
    CompilerEndIf
    
  EndProcedure    

  Procedure _SetDesctiveKey(key.s)
    key(key)\BackColor = $FF393a41
    key(key)\FrontColor = $FFFFFFFF    
    key(key)\FontSize = 25
    key()\Hover = #False
  EndProcedure
  
  Procedure _ConfigKey(Nr,x,y,w,h,fntsize,bc,fc,tp=-1)
    _key_.s = keys(Str(Nr))
    key(_key_)\x = x
    key(_key_)\y = y
    key(_key_)\Width = w
    key(_key_)\Height = h
    key(_key_)\Text = _key_
    key(_key_)\FontSize = fntsize
    key(_key_)\BackColor = bc
    key(_key_)\FrontColor = fc
    key(_key_)\Type = tp
  EndProcedure  
  
  Procedure _DrawEscape(x,y)
    x = x + 11
    y = y + 11
    
    half = 20 / 2.0
    hw = 20 / 12.0    
    
   VectorSourceColor($FFFFFFFF)

   AddPathCircle(x + half, y + half, half-hw, -50.0, 230.0)
   StrokePath(1.0*hw)

   MovePathCursor(x + half, y)
   AddPathLine(x + half, y + half)
   StrokePath(1*hw)
  EndProcedure
  
  Procedure _DrawReturn(x,y)
    Protected p.d = 48 / 32  
    x = x + 5
;      StrokePath(p, #PB_Path_RoundCorner)
     ; Arrow shaft
     VectorSourceColor($FFFFFFFF)
     MovePathCursor(x + 24*p, y + 10*p)
     AddPathLine(x + 24*p, y + 20*p)
     AddPathLine(x + 16*p, y + 20*p)
     StrokePath(2)
     ; Arrow head
     MovePathCursor(x + 16*p, y + 16*p)
     AddPathLine(x + 16*p, y + 24*p)
     AddPathLine(x + 12*p, y + 20*p)
     ClosePath()
     FillPath()
  EndProcedure
  
  Procedure _DrawShift(x,y)
    Protected p.d = 24 / 32    
    Protected w.d = 24 / 8
    If key("shift")\active
      VectorSourceColor($FF000FFF)
    Else
      VectorSourceColor($FFFFFFFF)
    EndIf 
     x = x + 20
     y = y + 10
     
     MovePathCursor(x + 4*w, y +    2*p)
     
     AddPathLine   (x +   w, y + 4*w + 2*p)
     AddPathLine   (x + 2*w, y + 4*w + 2*p)
     AddPathLine   (x + 2*w, y + 7*w + 2*p)
     AddPathLine   (x + 6*w, y + 7*w + 2*p)
     AddPathLine   (x + 6*w, y + 4*w + 2*p)
     AddPathLine   (x + 7*w, y + 4*w + 2*p)
     
     ClosePath()
    
     StrokePath(2)

  EndProcedure
  
  
  Procedure _DrawBackSpace(x,y)
    Protected p.d = 48 / 32
    x = x + 10
    y = y - 5
   
   VectorSourceColor($FFFFFFFF)
   MovePathCursor(x +  7 * p,  y + 19 * p)
   AddPathLine   (x + 13 * p,  y + 13 * p)
   AddPathLine   (x + 25 * p,  y + 13 * p)
   AddPathLine   (x + 25 * p,  y + 25 * p)
   AddPathLine   (x + 13 * p,  y + 25 * p)
   ClosePath     ()
   FillPath      ()
   VectorSourceColor($FF603A41)
   MovePathCursor(x + 15 * p,  y + 15 * p)
   AddPathLine   (x + 23 * p,  y + 23 * p)
   MovePathCursor(x + 23 * p,  y + 15 * p)
   AddPathLine   (x + 15 * p,  y + 23 * p)
   StrokePath    ( p * 3)    
    
    
  EndProcedure
      
 
  Procedure OnEventsKeyboard(Event)

    
;     Repeat
      
;       Event = WaitWindowEvent(100)
      
      Select Event
        Case #PB_Event_Menu
          Select EventMenu()
            Case #EscapeKeyboard
              HideWindow(Keyboard\WindowKeyboard, #True ): Keyboard\KeyboartVisible = #False
          EndSelect
        Case #PB_Event_Timer
          Select EventTimer()
            Case #EscapeKeyboard
              HideWindow(Keyboard\WindowKeyboard, #True): Keyboard\KeyboartVisible = #False
          EndSelect

       Case #PB_Event_Gadget
          Select EventGadget()
            Case Keyboard\GadgetID
              Select EventType()
                Case #PB_EventType_LostFocus
              EndSelect
 
            Case Canvas_keyboard
              Select EventType()
                Case #PB_EventType_Focus
                  SetGadgetAttribute(Canvas_keyboard, #PB_Canvas_Cursor, #PB_Cursor_Hand)
                
;                 Case #PB_EventType_LeftButtonDown
;                   If Action = #Keyboard
;                     For item=1 To 33
;                       i.s=keys(Str(item))
; ;                       mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
; ;                       my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
; ;                       
; ;                       If (mx > key()\x And mx < key()\x+key()\Width) And (my > key()\y And my < key()\y+key()\Height)
; ;                          _SetActiveKey(Key()\Text, #LeftClickDown)
; ;                       EndIf
;                     Next                 
;                     
;                   ElseIf Action = #KeyboardNum
;                     For item=34 To 52
;                       i.s=keys(Str(item))
; ;                       mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
; ;                       my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
; ;                       
; ;                       If (mx > key()\x And mx < key()\x+key()\Width) And (my > key()\y And my < key()\y+key()\Height)
; ;                          _SetActiveKey(Key()\Text, #LeftClickDown)
; ;                       EndIf                      
;                     Next
;                     
;                   EndIf

                Case #PB_EventType_LeftButtonUp
                  If Action = #Keyboard
                    For item=1 To 33
                      i.s=keys(Str(item))
                      mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
                      my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
                      
                      If (mx > key(i)\x And mx < key(i)\x+key(i)\Width) And (my > key(i)\y And my < key(i)\y+key(i)\Height)
      
                        _SetDesctiveKey(Key(i)\Text)
                        If Key(i)\Text = "escape"
                          HideWindow(Keyboard\WindowKeyboard, #True): Keyboard\KeyboartVisible = #False
                          Event = #PB_Event_CloseWindow
                          If IsGadget(Keyboard\GadgetID)
                            SetGadgetText(Keyboard\GadgetID, "")
                          EndIf 
                        ElseIf Key(i)\Text = "return"
                          HideWindow(Keyboard\WindowKeyboard, #True): Keyboard\KeyboartVisible = #False
                          Event = #PB_Event_CloseWindow
                        ElseIf Key(i)\Text = "backspace"
                          If IsGadget(Keyboard\GadgetID)
                            SetGadgetText(Keyboard\GadgetID, Mid(GetGadgetText(Keyboard\GadgetID), 0, Len(GetGadgetText(Keyboard\GadgetID))-1))
                          EndIf                           
                        ElseIf Key(i)\Text = "space"
                          If IsGadget(Keyboard\GadgetID)
                            SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID)  + " ")
                          EndIf                            
                        ElseIf Key(i)\Text = "shift"
                          ShiftActive ! #True 
                          key("shift")\active = ShiftActive
                        ElseIf Key(i)\Text = "?123"
                          SwitchKeyboard ! #True 
                          ;Debug "SwitchKeyboard..: " + Str(SwitchKeyboard)
                          Action = SwitchKeyboard
                        Else
                          If IsGadget(Keyboard\GadgetID)
                            If ShiftActive  = #True 
                              SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + UCase(Key(i)\Text))
                            Else
                              SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + Key(i)\Text)
                            EndIf
                          EndIf 
                          ;Simulate::Ghost(Key()\Text, 10)
                          
                        EndIf
                      EndIf 
                    Next   
                    
                  ElseIf Action = #KeyboardNum
                    
                    For item=34 To 52
                      i.s=keys(Str(item))
                      mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
                      my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
                      
                      If (mx > key(i)\x And mx < key(i)\x+key(i)\Width) And (my > key(i)\y And my < key(i)\y+key(i)\Height)
                        _SetDesctiveKey(Key(i)\Text)
                        If Key(i)\Text = "escape2"
                          HideWindow(Keyboard\WindowKeyboard, #True): Keyboard\KeyboartVisible = #False
                         Event = #PB_Event_CloseWindow
                         If IsGadget(Keyboard\GadgetID)
                          SetGadgetText(Keyboard\GadgetID, "")
                         EndIf 
                       ElseIf Key(i)\Text = "="
                          Event = #PB_Event_CloseWindow
                       ElseIf Key(i)\Text = "backspace2"
                        If IsGadget(Keyboard\GadgetID)
                          SetGadgetText(Keyboard\GadgetID, Mid(GetGadgetText(Keyboard\GadgetID), 0, Len(GetGadgetText(Keyboard\GadgetID))-1))
                        EndIf                           
                       ElseIf Key(i)\Text = "abc"
                          SwitchKeyboard ! #True 
                          Action = SwitchKeyboard
                       Else
                          If IsGadget(Keyboard\GadgetID)
                            If ShiftActive  = #True 
                              SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + UCase(Key(i)\Text))
                            Else
                              SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + Key(i)\Text)
                            EndIf
                          EndIf 
                          ;Simulate::Ghost(Key()\Text, 10)
                        EndIf
                      EndIf                       
                    Next
                  EndIf
                  
                  SetPositionToEnd(Keyboard\GadgetID)

                Case #PB_EventType_MouseMove
                  If Action = #Keyboard
                    For item=1 To 33
                      i.s=keys(Str(item))
                      mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
                      my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
                      
                      If (mx > key(i)\x And mx < key(i)\x+key()\Width) And (my > key(i)\y And my < key(i)\y+key(i)\Height)
                        _SetActiveKey(Key(i)\Text, #LeftClickDown)
                      Else
                         _SetDesctiveKey(Key(i)\Text)
                      EndIf                  
                    Next                 
                    
                  ElseIf Action = #KeyboardNum
                    
                    For item=34 To 52
                      i.s=keys(Str(item))
                      mx = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseX) 
                      my = GetGadgetAttribute(Canvas_keyboard, #PB_Canvas_MouseY)
                      
                      If (mx > key(i)\x And mx < key(i)\x+key()\Width) And (my > key(i)\y And my < key(i)\y+key(i)\Height)
                        _SetActiveKey(Key(i)\Text, #LeftClickDown)
                      Else
                         _SetDesctiveKey(Key(i)\Text)
                      EndIf                  
                    Next                        
                  EndIf 
                  
                Case #PB_EventType_KeyDown
                  key = GetGadgetAttribute(Canvas_keyboard,#PB_Canvas_Key)
                  ;Debug key
                  ;Debug LCase(Chr(key))
                  If Action = #Keyboard
                    If key = #PB_Shortcut_Back
                      _SetActiveKey("backspace")
                      If IsGadget(Keyboard\GadgetID)
                        SetGadgetText(Keyboard\GadgetID, Mid(GetGadgetText(Keyboard\GadgetID), 0, Len(GetGadgetText(Keyboard\GadgetID))-1))
                      EndIf                        
                    ElseIf key = #PB_Shortcut_Return
                      _SetActiveKey("return")
                    ElseIf key = #PB_Shortcut_Space
                      _SetActiveKey("space")
                      If IsGadget(Keyboard\GadgetID)
                        SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID)  + " ")
                      EndIf 
                    ElseIf key = #PB_Shortcut_Shift Or Key = 16  Or Key = 20
                      _SetActiveKey("shift")
                      ShiftActive ! #True 
                      key("shift")\active = ShiftActive
                    ElseIf key = #PB_Shortcut_Escape Or Key = 27
                      _SetActiveKey("escape")
                       HideWindow(Keyboard\WindowKeyboard, #True): Keyboard\KeyboartVisible = #False
                       Event = #PB_Event_CloseWindow
                       If IsGadget(Keyboard\GadgetID)
                        SetGadgetText(Keyboard\GadgetID, "")
                       EndIf
                    Else
                      _SetActiveKey(LCase(Chr(key)))
                      If IsGadget(Keyboard\GadgetID)
                        If ShiftActive  = #True 
                          SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + UCase(Chr(key)))
                        Else
                          SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + Chr(key))
                        EndIf
                      EndIf
                    EndIf 
                    
                  ElseIf Action = #KeyboardNum
                    
                    If key = #PB_Shortcut_Back
                      _SetActiveKey("backspace2")
                      If IsGadget(Keyboard\GadgetID)
                        SetGadgetText(Keyboard\GadgetID, Mid(GetGadgetText(Keyboard\GadgetID), 0, Len(GetGadgetText(Keyboard\GadgetID))-1))
                      EndIf                        
                    ElseIf key = #PB_Shortcut_Return
                      _SetActiveKey("=")
                    ElseIf key = #PB_Shortcut_Space
                    Else
                      _SetActiveKey(LCase(Chr(key)))
                      If IsGadget(Keyboard\GadgetID)
                        If ShiftActive  = #True 
                          SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + UCase(Chr(key)))
                        Else
                          SetGadgetText(Keyboard\GadgetID, GetGadgetText(Keyboard\GadgetID) + Chr(key))
                        EndIf
                      EndIf
                    EndIf
                    
                    
                  EndIf
                  
                      
                Case #PB_EventType_KeyUp
                  key = GetGadgetAttribute(Canvas_keyboard,#PB_Canvas_Key)
  ;                       Debug key
  ;                       Debug LCase(Chr(key))
                  
                  If Action = #Keyboard
                    If key = 27
                      Event = #PB_Event_CloseWindow
                      If IsGadget(Keyboard\GadgetID)
                        SetGadgetText(Keyboard\GadgetID, "")
                      EndIf 
                    ElseIf key = #PB_Shortcut_Back
                      _SetDesctiveKey("backspace")
                    ElseIf key = #PB_Shortcut_Return
                      _SetDesctiveKey("return")
                      Event = #PB_Event_CloseWindow
                    ElseIf key = #PB_Shortcut_Space
                      _SetDesctiveKey("space")
                    ElseIf key = #PB_Shortcut_Shift Or Key = 16  Or Key = 20
                      _SetDesctiveKey("shift")
                    ElseIf key = #PB_Shortcut_Escape Or Key = 27
                      _SetDesctiveKey("escape")
                    Else
                      _SetDesctiveKey(LCase(Chr(key)))
                    EndIf                     
                    
                  ElseIf Action = #KeyboardNum
                    If key = 27
                      ;Debug "ESC"
                    ElseIf key = #PB_Shortcut_Back
                      _SetDesctiveKey("backspace2")
                    ElseIf key = #PB_Shortcut_Return
                      _SetDesctiveKey("return2")   
                    EndIf
                  EndIf
                    
                Case #PB_EventType_LostFocus
                   StickyWindow(Keyboard\WindowKeyboard, #True)
                      
              EndSelect             
          EndSelect
     EndSelect
     _Draw()
;     Until Event = #PB_Event_CloseWindow
;     If IsGadget(Keyboard\GadgetID)
; ;       SetPositionToEnd(Keyboard\GadgetID)
;       ;SetActiveGadget(Keyboard\GadgetID)
;     EndIf
    

    
    
  EndProcedure  
  
  Procedure _MoveKeyboard()
    If Keyboard\KeyboardFixed = #False
      ResizeWindow(Keyboard\WindowKeyboard, WindowX(0) + GadgetX(Keyboard\GadgetID), WindowY(0) + GadgetY(Keyboard\GadgetID)-195, #PB_Ignore, #PB_Ignore)
    EndIf 
     OnEventsKeyboard(Event)
  EndProcedure
  
  Procedure SetActiveKeyboard(Active.i = #True)
    If Active
      HideWindow(Keyboard\WindowKeyboard, #False): Keyboard\KeyboartVisible = Active 
      SetPositionToEnd(Keyboard\GadgetID)
    Else
      HideWindow(Keyboard\WindowKeyboard, Active): Keyboard\KeyboartVisible = #True 
    EndIf
  EndProcedure
  
  
  Procedure SetKeyboarFocus(Gadget)
    If IsGadget(Gadget)
      Keyboard\GadgetID = Gadget  
      _MoveKeyboard()
    Else
;       Debug "Não sou um gadget"
    EndIf
  EndProcedure
  
 
 
  
  Procedure StartKeyboard(GadgetID.i = #PB_Ignore, WindowID.i = #PB_Ignore, Move.i = #False, Direction.i = #Down, Fixed.i =  #False)
    If Keyboard\KeyboartStarted = #True
      _MoveKeyboard()
      ProcedureReturn
    EndIf  
    ExamineDesktops()
    
    Keyboard\GadgetID          = GadgetID
    Keyboard\KeyboardFixed     = Fixed
    Keyboard\KeyboardMove      = Move
    Keyboard\KeyboardDirection = Direction 
    
    CompilerIf Defined(TaskBarInfo, #PB_Module)
      If TaskBarInfo::GetTaskBarAutoHide()
        complement = 0
      Else
        complement = TaskBarInfo::GetTaskBarHeight()
      EndIf 
    CompilerElse
      complement = 64
    CompilerEndIf    
    Keyboard\ComplementTaskBar = complement
    
;     If IsWindow(WindowID)
      Keyboard\WindowFather = WindowID 
;     Else
;       Keyboard\WindowFather = OpenWindow(0, 0, 0, 0, 0, "", #PB_Window3D_Invisible)
;     EndIf

    If Not Keyboard\KeyboardFixed
      If IsGadget(Keyboard\GadgetID)
        If Direction = #Up
          ;OpenWindowKeyboard(GadgetX(Keyboard\GadgetID), GadgetY(Keyboard\GadgetID)-195) ;, GadgetWidth(Keyboard\GadgetID))
          OpenWindow_KB(WindowX(Keyboard\WindowFather) + GadgetX(Keyboard\GadgetID)-(GadgetWidth(Keyboard\GadgetID)/2), WindowY(Keyboard\WindowFather) + GadgetY(Keyboard\GadgetID)+GadgetHeight(Keyboard\GadgetID)-195)
        ElseIf Direction = #Down
          ;OpenWindowKeyboard(GadgetX(Keyboard\GadgetID), GadgetY(Keyboard\GadgetID)+195) ;, GadgetWidth(Keyboard\GadgetID))
          OpenWindow_KB(WindowX(Keyboard\WindowFather) + GadgetX(Keyboard\GadgetID)-(GadgetWidth(Keyboard\GadgetID)/2), WindowY(Keyboard\WindowFather) + GadgetY(Keyboard\GadgetID)+GadgetHeight(Keyboard\GadgetID)+40)
        EndIf
      Else
        OpenWindow_KB((DesktopWidth(0)/2)-240 , DesktopHeight(0)-195)
      EndIf 
    Else
      OpenWindow_KB((DesktopWidth(0)/2)-240 , DesktopHeight(0)-(195+complement))
    EndIf 
    
    Keyboard\KeyboartStarted = #True 
    Keyboard\WindowKeyboard = Window_KB
    StickyWindow(Keyboard\WindowKeyboard, #True)
      
    CompilerIf Defined(CWMove, #PB_Module)
      If Keyboard\KeyboardMove
        CWMove::RegisterWMove(Canvas_keyboard)
      EndIf 
    CompilerEndIf
    
    CompilerIf Defined(WindowTransparent, #PB_Module)
      WindowTransparent::DefineWindow(WindowID(Keyboard\WindowKeyboard), 200)
    CompilerEndIf
 
    SetActiveWindow(Keyboard\WindowKeyboard)
    SetActiveGadget(Canvas_keyboard)
    
    _CreateKeyboard()
    _Draw()   

  EndProcedure
  
  Procedure _CreateKeyboard()
    w_ = GadgetWidth(Canvas_keyboard)
    x_ = GadgetWidth(Canvas_keyboard) / 11
    
    ;#Keyboard
    For x=2 To w_ Step 48
      Nrkey + 1:_ConfigKey(Nrkey, x,  3, x_, x_, 25, $FF393a41, $FFFFFFFF) ;q-p
    Next
    For x=25 To w_-45 Step 48
      Nrkey + 1:_ConfigKey(Nrkey, x, 51, x_, x_, 25, $FF393a41, $FFFFFFFF) ;a-l
    Next
    For x=73 To w_-110 Step 48
      Nrkey + 1:_ConfigKey(Nrkey, x, 99, x_, x_, 25, $FF393a41, $FFFFFFFF) ;z-m
    Next
    Nrkey + 1:_ConfigKey(Nrkey,   2,  99, x_+(x_/2)+3, x_, 11, $FF393a41, $FFFFFFFF,#Shift)
    Nrkey + 1:_ConfigKey(Nrkey,   x,  99, x_+(x_/2)+3, x_, 11, $FF393a41, $FFFFFFFF,#BackSpace)
    Nrkey + 1:_ConfigKey(Nrkey,   2, 147, x_+(x_/2)+3, x_, 11, $FF393a41, $FFFFFFFF,#_123)
    Nrkey + 1:_ConfigKey(Nrkey,  72, 147,          x_, x_, 11, $FF393a41, $FFFFFFFF,#Escape)      
    Nrkey + 1:_ConfigKey(Nrkey, 121, 147,   x_*5.5,    x_, 11, $FF393a41, $FFFFFFFF,#Space)      
    Nrkey + 1:_ConfigKey(Nrkey, 361, 147,       x_,    x_, 11, $FF393a41, $FFFFFFFF)
    Nrkey + 1:_ConfigKey(Nrkey,   x, 147, x_+(x_/2)+3, x_, 11, $FF393a41, $FFFFFFFF,#Return)      
    
    ;#KeyboardNum    
    Nrkey + 1:_ConfigKey(Nrkey,                 2, 3, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;7     
    Nrkey + 1:_ConfigKey(Nrkey,      (x_*5.4)/2+2, 3, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;8  
    Nrkey + 1:_ConfigKey(Nrkey,  ((x_*5.4)/2)*2+2, 3, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;9     
    Nrkey + 1:_ConfigKey(Nrkey,  ((x_*5.4)/2)*3+2, 3,  x_+(x_/2)-2, x_, 11, $FF393a41, $FFFFFFFF) ;/     
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*4-49, 3,  x_+(x_/2)-2, x_, 11, $FF393a41, $FFFFFFFF) ;*     
        
    Nrkey + 1:_ConfigKey(Nrkey,                2,  51, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;4     
    Nrkey + 1:_ConfigKey(Nrkey,     (x_*5.4)/2+2,  51, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;5  
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*2+2,  51, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;6     
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*3+2,  51,    x_+(x_/2)-2, x_, 11, $FF393a41, $FFFFFFFF) ; -     
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*4-49, 51,  x_+(x_/2)-2, x_, 11, $FF393a41, $FFFFFFFF)   ;+      
    
    Nrkey + 1:_ConfigKey(Nrkey,                2,  99, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF)  ;1     
    Nrkey + 1:_ConfigKey(Nrkey,     (x_*5.4)/2+2,  99, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF)  ;2  
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*2+2,  99, (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF)  ;3     
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*3+2,  99, (x_*5.4)/2+11, x_, 11, $FF393a41, $FFFFFFFF) ;.
    
    Nrkey + 1:_ConfigKey(Nrkey,                2, 147,   x_+(x_/2)+3, x_, 11, $FF393a41, $FFFFFFFF,#_123)  
    Nrkey + 1:_ConfigKey(Nrkey,               72, 147,            x_, x_, 11, $FF393a41, $FFFFFFFF,#Escape)      
    Nrkey + 1:_ConfigKey(Nrkey,     (x_*5.4)/2+2, 147,  (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF) ;0     
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*2+2, 147,  (x_*5.4)/2-3, x_, 11, $FF393a41, $FFFFFFFF, #BackSpace)      
    Nrkey + 1:_ConfigKey(Nrkey, ((x_*5.4)/2)*3+2, 147, (x_*5.4)/2+11, x_, 11, $FF393a41, $FFFFFFFF, #Return)

  EndProcedure
  
  Procedure _Draw()
    Define.s Txt
    If StartVectorDrawing(CanvasVectorOutput(Canvas_keyboard))
      VectorSourceColor($FF1c1f27)
      AddPathBox(0, 0, GadgetWidth(Canvas_keyboard), GadgetHeight(Canvas_keyboard))
      FillPath()

      LoadFont(0, "Arial", 20, #PB_Font_Bold)

      If Action = #Keyboard
        For item=1 To 33
          i.s=keys(Str(item))
          Txt = key(i)\Text
          If ShiftActive
            Txt = UCase(key(i)\Text)
          EndIf          
          If key(i)\Hover
            VectorFont(FontID(0), key(i)\FontSize)
            VectorSourceColor(key(i)\BackColor)
            AddPathBox(key(i)\x, key(i)\y, key(i)\Width, key(i)\Height)  
            FillPath()
            
            If key(i)\Type = #BackSpace 
              _DrawBackSpace(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Shift
              _DrawShift(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Return
              _DrawReturn(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Escape
              _DrawEscape(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Space
            Else 
              VectorSourceColor(key(i)\FrontColor)
              MovePathCursor(key(i)\x + 10, key(i)\y+10)
              DrawVectorText(Txt)
              FillPath()     
            EndIf 
            
          Else
            VectorFont(FontID(0), 25)
            VectorSourceColor(key(i)\BackColor)
            AddPathBox(key(i)\x, key(i)\y, key(i)\Width, key(i)\Height)  
            FillPath()
            
            If key(i)\Type = #BackSpace 
              _DrawBackSpace(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Shift
              _DrawShift(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Return
              _DrawReturn(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Escape
              _DrawEscape(key(i)\x, key(i)\y)
            ElseIf key(i)\Type = #Space
            Else            
              VectorSourceColor(key(i)\FrontColor)
              MovePathCursor(key(i)\x + 10, key(i)\y+10)
              DrawVectorText(Txt)
              FillPath()
            EndIf           
          EndIf 
        Next 
        
        ElseIf Action = #KeyboardNum
          
          For item=34 To 52
            i.s=keys(Str(item))
            Txt = key(i)\Text
            If ShiftActive
              Txt = UCase(key(i)\Text)
            EndIf          
            
            If key(i)\Hover
              VectorFont(FontID(0), key(i)\FontSize)
              VectorSourceColor(key(i)\BackColor)
              AddPathBox(key(i)\x, key(i)\y, key(i)\Width, key(i)\Height)  
              FillPath()
              
              If key(i)\Type = #BackSpace 
                _DrawBackSpace(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Shift
                _DrawShift(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Return
                _DrawReturn(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Escape
                _DrawEscape(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Space
              Else 
                VectorSourceColor(key(i)\FrontColor)
                MovePathCursor(key(i)\x + 10, key(i)\y+10)
                DrawVectorText(Txt)
                FillPath()     
              EndIf 
              
            Else
              VectorFont(FontID(0), key(i)\FontSize)
              VectorSourceColor(key(i)\BackColor)
              AddPathBox(key(i)\x, key(i)\y, key(i)\Width, key(i)\Height)  
              FillPath()
              
              If key(i)\Type = #BackSpace 
                _DrawBackSpace(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Shift
                _DrawShift(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Return
                _DrawReturn(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Escape
                _DrawEscape(key(i)\x, key(i)\y)
              ElseIf key(i)\Type = #Space
              Else            
                VectorSourceColor(key(i)\FrontColor)
                MovePathCursor(key(i)\x + 10, key(i)\y+10)
                DrawVectorText(Txt)
                FillPath()
              EndIf 
            EndIf             
           Next
        EndIf
  
      FillPath()
      StopVectorDrawing()
    EndIf
    
  EndProcedure

  Procedure _Events()
    GadgetID.i = GetActiveGadget()
    Select EventType()
      Case #PB_EventType_LeftClick, #PB_EventType_LeftDoubleClick;, #PB_EventType_Focus
        TouchScreenKeyboard::StartKeyboard(GadgetID, 0, 1, 1)
        SetGadgetState(1, #False)
      Case #PB_EventType_LostFocus
        
    EndSelect    
  EndProcedure
  
  Procedure RegisterGadget(Gadget.i)
    BindGadgetEvent(Gadget, _Events())
  EndProcedure  
  

  
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
  
  UsePNGImageDecoder()
  
  IMG_keyboard = CatchImage(#PB_Any, ?keyboard, 593)
  
  Window_Test = OpenWindow(0, x, y, 400, 240, "TouchScreenKeyboard Test", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_WindowCentered)
  Button_0 = ButtonImageGadget(#PB_Any, 290, 20, 90, 30, ImageID(IMG_keyboard))
  Text_0 = TextGadget(#PB_Any, 30, 20, 80, 25, "Field 1")
  String_1 = StringGadget(#PB_Any, 120, 20, 150, 25, "")
  Text_2 = TextGadget(#PB_Any, 30, 60, 80, 25, "Field 2")
  String_2 = StringGadget(#PB_Any, 120, 60, 150, 25, "")
  Text_3 = TextGadget(#PB_Any, 30, 100, 80, 25, "Field 3")
  String_3 = StringGadget(#PB_Any, 120, 100, 150, 25, "")
  Text_4 = TextGadget(#PB_Any, 30, 140, 80, 25, "Field 4")
  String_4 = StringGadget(#PB_Any, 120, 140, 150, 25, "")
  Text_5 = TextGadget(#PB_Any, 30, 180, 80, 25, "Field 5")
  String_5 = StringGadget(#PB_Any, 120, 180, 150, 25, "")
  
  TouchScreenKeyboard::StartKeyboard(String_1, 0, #False, TouchScreenKeyboard::#Down, #True)
  
  Ativei = #False
  ThisGadget.i = 0
  Repeat
    
    event = WaitWindowEvent(1)
    TouchScreenKeyboard::OnEventsKeyboard(Event)
    
    Select Event
      Case #PB_Event_Gadget
        Select EventGadget()
          Case Button_0
            Select EventType()
              Case #PB_EventType_LeftClick
                Debug GetGadgetState(Button_0)
                TouchScreenKeyboard::SetKeyboarFocus(ThisGadget): TouchScreenKeyboard::SetActiveKeyboard(ThisGadget)
            EndSelect
            
          Case String_1
            Select EventType()
              Case #PB_EventType_Focus
                 ThisGadget = String_1
                 TouchScreenKeyboard::SetKeyboarFocus(ThisGadget)
            EndSelect
            
          Case String_2
            Select EventType()
              Case #PB_EventType_Focus
                 ThisGadget = String_2
                 TouchScreenKeyboard::SetKeyboarFocus(ThisGadget)
            EndSelect
            
          Case String_3
            Select EventType()
              Case #PB_EventType_Focus
                 ThisGadget = String_3
                 TouchScreenKeyboard::SetKeyboarFocus(ThisGadget)
            EndSelect
            
          Case String_4
            Select EventType()
              Case #PB_EventType_Focus
                 ThisGadget = String_4
                 TouchScreenKeyboard::SetKeyboarFocus(ThisGadget)
            EndSelect
            
          Case String_5
            Select EventType()
              Case #PB_EventType_Focus
                 ThisGadget = String_5
                 TouchScreenKeyboard::SetKeyboarFocus(ThisGadget)
            EndSelect
          
            
        EndSelect
    EndSelect
    
  Until event = #PB_Event_CloseWindow
  End
    
  DataSection
    keyboard:
    Data.q $0A1A0A0D474E5089,$524448490D000000,$2000000020000000,$7A7A730000000608,$49427304000000F4,$64087C0808080854,
           $5948700900000088,$000000E800000073,$0000AFF6D58601E8,$6F53745845741900,$7700657261777466,$63736B6E692E7777,
           $9B67726F2E657061,$49CE0100001A3CEE,$3197ED8558544144,$15B79F861460DD4B,$07077B41417B1107,$A5441071480FF075,
           $C44407FA1C550B4B,$704FE2E4E2E0E0DF,$285CE4E093A4E872,$B9A5D0DEAE88A6ED,$E702721D3C14A288,$0BEE1DC983BD2206,
           $DF24E724EF9E5F21,$A9BD4EA33322139B,$0060285E80BF7B35,$5BB9C57DE03BD240,$AB01EE06D806D666,$8980B405B607BB78,
           $6A6AF22532DBBE57,$079819606D84D153,$4FD81EB673DF028E,$2F6CEEB5CE3EF367,$7143A39ECB6723B0,$815B8EEF0CCD2E5D,
           $730EC0C3B39E062F,$32FC0ADD8862D81E,$04D490D314281CE6,$A2FD2467C0E9801E,$8738F91A92932BD3,$D3B1099804816692,
           $3CE7A70234043B1E,$381BF5104B8AB950,$814804F621AF98F5,$303BE00BB3ACC00F,$9E037C04F6767C0A,$A359547D1E142F81,
           $B604967739C60DD8,$071D9D4F0357621A,$738825A5E7965076,$43B627FFE6CBEC2A,$E8F646700FF0992F,$980E6E7CCE45C2D7,
           $DEC8C600FC0D7672,$7C12D931C0BF8075,$FED512A02DBB8602,$E649A01229A74016,$6DB3759D37C0FDD8,$69473D359DF7F384,
           $4DD24016ECCD4C27,$92577376966657E0,$4A4A9F9F8DE1C3AE,$A484C058A27CF181,$4947F810BC56B225,$82F184AC0014DD8F,
           $309EFE9F0A21F2B7,$0EE05BC9FCC6AB61,$EC00FE4E2B060258,$2AD0E6423490CCC8,$FD66BFFAB6B332D5,$DD45101FE02EEA02,
           $000000DAA2293DC2,$6042AE444E454900
    Data.b $82
  EndDataSection
  
CompilerEndIf