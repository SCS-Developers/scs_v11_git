;=================================================================
; Library Command:      ShortcutGadgetEx()
; Author:               Lloyd Gallant (netmaestro)
; Date:                 January 3, 2010
; Target Compiler:      PureBasic 4.40
; Target OS             Windows only
; License:              Free, unrestricted, no warranty
;
; What it does:         Adds Backspace key and maps numpad
;                       keys to corresponding extended keys
;                       affecting arrow keys, Page keys,
;                       Insert, Home, End.
;                       
;                       Key names will be more descriptive
;                       in the gadget.
;
;                       Fixes bugs in the native gadget where
;                       some extended keys were not generating
;                       a gadget event.
;=================================================================

EnableExplicit  ; added by MJD

Import "gadget.lib"
  PB_Gadget_SendGadgetCommand(hwnd, EventType)
EndImport

Procedure GetMods()
  Protected mod.b = 0
  If GetAsyncKeyState_(#VK_CONTROL) & 32768
    mod.b | #HOTKEYF_CONTROL
  EndIf
  If GetAsyncKeyState_(#VK_SHIFT) & 32768
    mod.b | #HOTKEYF_SHIFT
  EndIf
  If GetAsyncKeyState_(#VK_MENU) & 32768
    mod.b | #HOTKEYF_ALT
  EndIf
  ProcedureReturn mod
EndProcedure

Procedure HotProc(hwnd, msg, wparam, lparam)
  Protected oldproc, mod.b
  
  oldproc = GetProp_(hwnd, "oldproc")
  Select msg
    Case #WM_NCDESTROY
      RemoveProp_(hwnd, "oldproc")
      
    Case #WM_KEYDOWN 
      mod.b = GetMods()
      ; Debug "HotProc wparam=" + wparam
      Select wparam
        Case 13
          SendMessage_(hwnd, #HKM_SETHOTKEY, (mod<<8) | #VK_RETURN, 0 )
          PB_Gadget_SendGadgetcommand(hwnd, 0)    ; this line added by MJD
          ProcedureReturn 0
        ; Case 32 ; 'space' added by MJD
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, (mod<<8) | #VK_SPACE, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 27 ; 'escape' added by MJD
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, (mod<<8) | #VK_ESCAPE, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 46,110
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Delete, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        Case 8
          SendMessage_(hwnd, #HKM_SETHOTKEY, (mod<<8) | #VK_BACK, 0 )
          PB_Gadget_SendGadgetcommand(hwnd, 0)
          ProcedureReturn 0
        ; Case 37,38,39,40
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|wparam, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 96 To 105   ; added MJD to retain num pad keys
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|wparam, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 100
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Left, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 104
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Up, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 102
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Right, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 98
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Down, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 105
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|33, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 99
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|34, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 103
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|36, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 97
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|35, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
        ; Case 96
          ; SendMessage_(hwnd, #HKM_SETHOTKEY, ((mod | #HOTKEYF_EXT)<<8)|#VK_Insert, 0 )
          ; PB_Gadget_SendGadgetcommand(hwnd, 0)
          ; ProcedureReturn 0
      EndSelect
  EndSelect   
  ProcedureReturn CallWindowProc_(oldproc, hwnd, msg, wparam, lparam)
EndProcedure

ProcedureDLL ShortcutGadgetEx(gadgetnum, X, Y, w, h, initialvalue=0)
  Protected result
  
  If gadgetnum = #PB_Any
    gadgetnum = ShortcutGadget(#PB_Any, X, Y, w, h, initialvalue)
    result = gadgetnum
  Else
    result = ShortcutGadget(gadgetnum, X, Y, w, h, initialvalue)
  EndIf  
  SetProp_(GadgetID(gadgetnum),"oldproc",SetWindowLongPtr_(GadgetID(gadgetnum),#GWL_WNDPROC,@HotProc()))
  ProcedureReturn result
EndProcedure



; Test Prog

; To test: Set a hotkey in the gadget, press "Set" and then press the key combination.
;          This verifies that the shortcut works correctly and that the library didn't 
;          harm the result of GetGadgetState().

;          Any bugs or requested extensions, let me know.

; Global sg, Event, EventGadget
; 
; OpenWindow(0, 0, 0, 240, 200, "ShortcutGadget", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
; sg = ShortcutGadgetEx(#PB_Any, 20, 20, 200, 25)
; ButtonGadget(1, 70,140,100,20,"Set")
; SetActiveGadget(sg)
; 
; Repeat
  ; Event = WaitWindowEvent()
  ; Select Event
      ; 
    ; Case #PB_Event_Gadget
      ; EventGadget = EventGadget()
      ; If EventGadget=1
        ; AddKeyboardShortcut(0, GetGadgetState(sg), 1)
      ; ElseIf EventGadget = sg
        ; Debug "GetGadgetState(sg)=" + Str(GetGadgetState(sg))
      ; EndIf
      ; 
    ; Case #PB_Event_Menu
      ; Select EventMenu()
        ; Case 1
          ; Debug "Shortcut Received"
      ; EndSelect
      ; 
  ; EndSelect
  ; 
; Until Event=#PB_Event_CloseWindow
