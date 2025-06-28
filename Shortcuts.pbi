; File: Shortcuts.pbi

EnableExplicit

Procedure.s decodeShortcut(nShortcut)
  Protected nMyShortcut, sShiftStr.s, sKeyStr.s
  
  If nShortcut = 0
    ProcedureReturn ""
  EndIf
  
  nMyShortcut = nShortcut
  
  If nMyShortcut & #PB_Shortcut_Control
    sShiftStr + "Ctrl+"
    nMyShortcut ! #PB_Shortcut_Control
  EndIf
  If nShortcut & #PB_Shortcut_Alt
    sShiftStr + "Alt+"
    nMyShortcut ! #PB_Shortcut_Alt
  EndIf
  If nShortcut & #PB_Shortcut_Shift
    sShiftStr + "Shift+"
    nMyShortcut ! #PB_Shortcut_Shift
  EndIf
  If nMyShortcut & #PB_Shortcut_Command
    sShiftStr + "Cmd+"
    nMyShortcut ! #PB_Shortcut_Command
  EndIf
  
  Select nMyShortcut
    Case #PB_Shortcut_Back
      sKeyStr = "Back"
    Case #PB_Shortcut_Tab
      sKeyStr = "Tab"
    ; Case #PB_Shortcut_Clear
      ; sKeyStr = "Clear"
    Case #PB_Shortcut_Return
      sKeyStr = "Return"
    Case #PB_Shortcut_Menu
      sKeyStr = "Menu"
    ; Case #PB_Shortcut_Pause
      ; sKeyStr = "Pause"
    ; Case #PB_Shortcut_Print
      ; sKeyStr = "Print"
    Case #PB_Shortcut_Capital
      sKeyStr = "Caps Lock"
    Case #PB_Shortcut_Escape
      sKeyStr = "Esc"
    Case #PB_Shortcut_Space
      sKeyStr = "Space"
    Case #PB_Shortcut_PageUp
      sKeyStr = "Page Up"
    Case #PB_Shortcut_PageDown
      sKeyStr = "Page Down"
    Case #PB_Shortcut_End
      sKeyStr = "End"
    Case #PB_Shortcut_Home
      sKeyStr = "Home"
    Case #PB_Shortcut_Left
      sKeyStr = "Left"
    Case #PB_Shortcut_Up
      sKeyStr = "Up"
    Case #PB_Shortcut_Right
      sKeyStr = "Right"
    Case #PB_Shortcut_Down
      sKeyStr = "Down"
    Case #PB_Shortcut_Select
      sKeyStr = "Select"
    Case #PB_Shortcut_Execute
      sKeyStr = "Execute"
    Case #PB_Shortcut_Snapshot
      sKeyStr = "Snapshot"
    Case #PB_Shortcut_Insert
      sKeyStr = "Ins"
    Case #PB_Shortcut_Delete
      sKeyStr = "Del"
    Case #PB_Shortcut_Help
      sKeyStr = "Help"
    Case #PB_Shortcut_0
      sKeyStr = "0"
    Case #PB_Shortcut_1
      sKeyStr = "1"
    Case #PB_Shortcut_2
      sKeyStr = "2"
    Case #PB_Shortcut_3
      sKeyStr = "3"
    Case #PB_Shortcut_4
      sKeyStr = "4"
    Case #PB_Shortcut_5
      sKeyStr = "5"
    Case #PB_Shortcut_6
      sKeyStr = "6"
    Case #PB_Shortcut_7
      sKeyStr = "7"
    Case #PB_Shortcut_8
      sKeyStr = "8"
    Case #PB_Shortcut_9
      sKeyStr = "9"
    Case #PB_Shortcut_A
      sKeyStr = "A"
    Case #PB_Shortcut_B
      sKeyStr = "B"
    Case #PB_Shortcut_C
      sKeyStr = "C"
    Case #PB_Shortcut_D
      sKeyStr = "D"
    Case #PB_Shortcut_E
      sKeyStr = "E"
    Case #PB_Shortcut_F
      sKeyStr = "F"
    Case #PB_Shortcut_G
      sKeyStr = "G"
    Case #PB_Shortcut_H
      sKeyStr = "H"
    Case #PB_Shortcut_I
      sKeyStr = "I"
    Case #PB_Shortcut_J
      sKeyStr = "J"
    Case #PB_Shortcut_K
      sKeyStr = "K"
    Case #PB_Shortcut_L
      sKeyStr = "L"
    Case #PB_Shortcut_M
      sKeyStr = "M"
    Case #PB_Shortcut_N
      sKeyStr = "N"
    Case #PB_Shortcut_O
      sKeyStr = "O"
    Case #PB_Shortcut_P
      sKeyStr = "P"
    Case #PB_Shortcut_Q
      sKeyStr = "Q"
    Case #PB_Shortcut_R
      sKeyStr = "R"
    Case #PB_Shortcut_S
      sKeyStr = "S"
    Case #PB_Shortcut_T
      sKeyStr = "T"
    Case #PB_Shortcut_U
      sKeyStr = "U"
    Case #PB_Shortcut_V
      sKeyStr = "V"
    Case #PB_Shortcut_W
      sKeyStr = "W"
    Case #PB_Shortcut_X
      sKeyStr = "X"
    Case #PB_Shortcut_Y
      sKeyStr = "Y"
    Case #PB_Shortcut_Z
      sKeyStr = "Z"
    ; Case #PB_Shortcut_LeftWindows
      ; sKeyStr = "LeftWindows"
    ; Case #PB_Shortcut_RightWindows
      ; sKeyStr = "RightWindows"
    ; Case #PB_Shortcut_Apps
      ; sKeyStr = "Apps"
    Case #PB_Shortcut_Pad0
      sKeyStr = "Pad0"
    Case #PB_Shortcut_Pad1
      sKeyStr = "Pad1"
    Case #PB_Shortcut_Pad2
      sKeyStr = "Pad2"
    Case #PB_Shortcut_Pad3
      sKeyStr = "Pad3"
    Case #PB_Shortcut_Pad4
      sKeyStr = "Pad4"
    Case #PB_Shortcut_Pad5
      sKeyStr = "Pad5"
    Case #PB_Shortcut_Pad6
      sKeyStr = "Pad6"
    Case #PB_Shortcut_Pad7
      sKeyStr = "Pad7"
    Case #PB_Shortcut_Pad8
      sKeyStr = "Pad8"
    Case #PB_Shortcut_Pad9
      sKeyStr = "Pad9"
    Case #PB_Shortcut_Multiply
      sKeyStr = "Multiply"
    Case #PB_Shortcut_Add
      sKeyStr = "Add"
    ; Case #PB_Shortcut_Separator
      ; sKeyStr = "Separator"
    Case #PB_Shortcut_Subtract
      sKeyStr = "Subtract"
    Case #PB_Shortcut_Decimal
      sKeyStr = "Decimal"
    Case #PB_Shortcut_Divide
      sKeyStr = "Divide"
    Case #PB_Shortcut_F1
      sKeyStr = "F1"
    Case #PB_Shortcut_F2
      sKeyStr = "F2"
    Case #PB_Shortcut_F3
      sKeyStr = "F3"
    Case #PB_Shortcut_F4
      sKeyStr = "F4"
    Case #PB_Shortcut_F5
      sKeyStr = "F5"
    Case #PB_Shortcut_F6
      sKeyStr = "F6"
    Case #PB_Shortcut_F7
      sKeyStr = "F7"
    Case #PB_Shortcut_F8
      sKeyStr = "F8"
    Case #PB_Shortcut_F9
      sKeyStr = "F9"
    Case #PB_Shortcut_F10
      sKeyStr = "F10"
    Case #PB_Shortcut_F11
      sKeyStr = "F11"
    Case #PB_Shortcut_F12
      sKeyStr = "F12"
    Case #PB_Shortcut_F13
      sKeyStr = "F13"
    Case #PB_Shortcut_F14
      sKeyStr = "F14"
    Case #PB_Shortcut_F15
      sKeyStr = "F15"
    Case #PB_Shortcut_F16
      sKeyStr = "F16"
    Case #PB_Shortcut_F17
      sKeyStr = "F17"
    Case #PB_Shortcut_F18
      sKeyStr = "F18"
    Case #PB_Shortcut_F19
      sKeyStr = "F19"
    Case #PB_Shortcut_F20
      sKeyStr = "F20"
    Case #PB_Shortcut_F21
      sKeyStr = "F21"
    Case #PB_Shortcut_F22
      sKeyStr = "F22"
    Case #PB_Shortcut_F23
      sKeyStr = "F23"
    Case #PB_Shortcut_F24
      sKeyStr = "F24"
    Case #PB_Shortcut_Numlock
      sKeyStr = "Numlock"
    Case #PB_Shortcut_Scroll
      sKeyStr = "Scroll"
      
      ; 'undocumented' PB shortcut values, so assigned to SCS constants
    Case #SCS_Shortcut_Equals
      sKeyStr = "Equals"
    Case #SCS_Shortcut_LeftBracket
      sKeyStr = "LeftBracket"
    Case #SCS_Shortcut_RightBracket
      sKeyStr = "RightBracket"
    Case #SCS_Shortcut_SemiColon
      sKeyStr = "SemiColon"
    Case #SCS_Shortcut_Apostrophe
      sKeyStr = "Apostrophe"
    Case #SCS_Shortcut_Grave
      sKeyStr = "Grave"
    Case #SCS_Shortcut_Backslash
      sKeyStr = "BackSlash"
    Case #SCS_Shortcut_Comma
      sKeyStr = "Comma"
    Case #SCS_Shortcut_Period
      sKeyStr = "Period"
    Case #SCS_Shortcut_Slash
      sKeyStr = "Slash"
    Case #SCS_Shortcut_Minus
      sKeyStr = "Minus"
      
  EndSelect
  
  If Len(sKeyStr) = 0
    ; if key not recognised or not accepted, then clear any shift, etc that was found in this 'shortcut'
    sShiftStr = ""
  EndIf
  
  ProcedureReturn Trim(sShiftStr + sKeyStr)
EndProcedure

Procedure encodeShortcut(sShortcutStr.s)
  Protected sMyShortcutStr.s
  Protected nMyShift, nMyKey
  
  If Len(sShortcutStr) = 0
    ProcedureReturn 0
  EndIf
  
  sMyShortcutStr = sShortcutStr
  
  If FindString(sMyShortcutStr, "Ctrl+", 1)
    nMyShift | #PB_Shortcut_Control
    sMyShortcutStr = ReplaceString(sMyShortcutStr, "Ctrl+", "")
  EndIf
  
  If FindString(sMyShortcutStr, "Alt+", 1)
    nMyShift | #PB_Shortcut_Alt
    sMyShortcutStr = ReplaceString(sMyShortcutStr, "Alt+", "")
  EndIf
  
  If FindString(sMyShortcutStr, "Shift+", 1)
    nMyShift | #PB_Shortcut_Shift
    sMyShortcutStr = ReplaceString(sMyShortcutStr, "Shift+", "")
  EndIf
  
  If FindString(sMyShortcutStr, "Cmd+", 1)
    nMyShift | #PB_Shortcut_Command
    sMyShortcutStr = ReplaceString(sMyShortcutStr, "Cmd+", "")
  EndIf
  
  sMyShortcutStr = Trim(sMyShortcutStr)
  
  Select sMyShortcutStr
    Case "Back"
      nMyKey = #PB_Shortcut_Back
    Case "Tab"
      nMyKey = #PB_Shortcut_Tab
    ; Case "Clear"
      ; nMyKey = #PB_Shortcut_Clear
    Case "Return"
      nMyKey = #PB_Shortcut_Return
    Case "Menu"
      nMyKey = #PB_Shortcut_Menu
    ; Case "Pause"
      ; nMyKey = #PB_Shortcut_Pause
    ; Case "Print"
      ; nMyKey = #PB_Shortcut_Print
    Case "Caps Lock"
      nMyKey = #PB_Shortcut_Capital
    Case "Esc"
      nMyKey = #PB_Shortcut_Escape
    Case "Space"
      nMyKey = #PB_Shortcut_Space
    Case "Page Up"
      nMyKey = #PB_Shortcut_PageUp
    Case "Page Down"
      nMyKey = #PB_Shortcut_PageDown
    Case "End"
      nMyKey = #PB_Shortcut_End
    Case "Home"
      nMyKey = #PB_Shortcut_Home
    Case "Left"
      nMyKey = #PB_Shortcut_Left
    Case "Up"
      nMyKey = #PB_Shortcut_Up
    Case "Right"
      nMyKey = #PB_Shortcut_Right
    Case "Down"
      nMyKey = #PB_Shortcut_Down
    Case "Select"
      nMyKey = #PB_Shortcut_Select
    Case "Execute"
      nMyKey = #PB_Shortcut_Execute
    Case "Snapshot"
      nMyKey = #PB_Shortcut_Snapshot
    Case "Ins"
      nMyKey = #PB_Shortcut_Insert
    Case "Del"
      nMyKey = #PB_Shortcut_Delete
    Case "Help"
      nMyKey = #PB_Shortcut_Help
    Case "0"
      nMyKey = #PB_Shortcut_0
    Case "1"
      nMyKey = #PB_Shortcut_1
    Case "2"
      nMyKey = #PB_Shortcut_2
    Case "3"
      nMyKey = #PB_Shortcut_3
    Case "4"
      nMyKey = #PB_Shortcut_4
    Case "5"
      nMyKey = #PB_Shortcut_5
    Case "6"
      nMyKey = #PB_Shortcut_6
    Case "7"
      nMyKey = #PB_Shortcut_7
    Case "8"
      nMyKey = #PB_Shortcut_8
    Case "9"
      nMyKey = #PB_Shortcut_9
    Case "A"
      nMyKey = #PB_Shortcut_A
    Case "B"
      nMyKey = #PB_Shortcut_B
    Case "C"
      nMyKey = #PB_Shortcut_C
    Case "D"
      nMyKey = #PB_Shortcut_D
    Case "E"
      nMyKey = #PB_Shortcut_E
    Case "F"
      nMyKey = #PB_Shortcut_F
    Case "G"
      nMyKey = #PB_Shortcut_G
    Case "H"
      nMyKey = #PB_Shortcut_H
    Case "I"
      nMyKey = #PB_Shortcut_I
    Case "J"
      nMyKey = #PB_Shortcut_J
    Case "K"
      nMyKey = #PB_Shortcut_K
    Case "L"
      nMyKey = #PB_Shortcut_L
    Case "M"
      nMyKey = #PB_Shortcut_M
    Case "N"
      nMyKey = #PB_Shortcut_N
    Case "O"
      nMyKey = #PB_Shortcut_O
    Case "P"
      nMyKey = #PB_Shortcut_P
    Case "Q"
      nMyKey = #PB_Shortcut_Q
    Case "R"
      nMyKey = #PB_Shortcut_R
    Case "S"
      nMyKey = #PB_Shortcut_S
    Case "T"
      nMyKey = #PB_Shortcut_T
    Case "U"
      nMyKey = #PB_Shortcut_U
    Case "V"
      nMyKey = #PB_Shortcut_V
    Case "W"
      nMyKey = #PB_Shortcut_W
    Case "X"
      nMyKey = #PB_Shortcut_X
    Case "Y"
      nMyKey = #PB_Shortcut_Y
    Case "Z"
      nMyKey = #PB_Shortcut_Z
    ; Case "LeftWindows"
      ; nMyKey = #PB_Shortcut_LeftWindows
    ; Case "RightWindows"
      ; nMyKey = #PB_Shortcut_RightWindows
    ; Case "Apps"
      ; nMyKey = #PB_Shortcut_Apps
    Case "Pad0"
      nMyKey = #PB_Shortcut_Pad0
    Case "Pad1"
      nMyKey = #PB_Shortcut_Pad1
    Case "Pad2"
      nMyKey = #PB_Shortcut_Pad2
    Case "Pad3"
      nMyKey = #PB_Shortcut_Pad3
    Case "Pad4"
      nMyKey = #PB_Shortcut_Pad4
    Case "Pad5"
      nMyKey = #PB_Shortcut_Pad5
    Case "Pad6"
      nMyKey = #PB_Shortcut_Pad6
    Case "Pad7"
      nMyKey = #PB_Shortcut_Pad7
    Case "Pad8"
      nMyKey = #PB_Shortcut_Pad8
    Case "Pad9"
      nMyKey = #PB_Shortcut_Pad9
    Case "Multiply"
      nMyKey = #PB_Shortcut_Multiply
    Case "Add"
      nMyKey = #PB_Shortcut_Add
    ; Case "Separator"
      ; nMyKey = #PB_Shortcut_Separator
    Case "Subtract"
      nMyKey = #PB_Shortcut_Subtract
    Case "Decimal"
      nMyKey = #PB_Shortcut_Decimal
    Case "Divide"
      nMyKey = #PB_Shortcut_Divide
    Case "F1"
      nMyKey = #PB_Shortcut_F1
    Case "F2"
      nMyKey = #PB_Shortcut_F2
    Case "F3"
      nMyKey = #PB_Shortcut_F3
    Case "F4"
      nMyKey = #PB_Shortcut_F4
    Case "F5"
      nMyKey = #PB_Shortcut_F5
    Case "F6"
      nMyKey = #PB_Shortcut_F6
    Case "F7"
      nMyKey = #PB_Shortcut_F7
    Case "F8"
      nMyKey = #PB_Shortcut_F8
    Case "F9"
      nMyKey = #PB_Shortcut_F9
    Case "F10"
      nMyKey = #PB_Shortcut_F10
    Case "F11"
      nMyKey = #PB_Shortcut_F11
    Case "F12"
      nMyKey = #PB_Shortcut_F12
    Case "F13"
      nMyKey = #PB_Shortcut_F13
    Case "F14"
      nMyKey = #PB_Shortcut_F14
    Case "F15"
      nMyKey = #PB_Shortcut_F15
    Case "F16"
      nMyKey = #PB_Shortcut_F16
    Case "F17"
      nMyKey = #PB_Shortcut_F17
    Case "F18"
      nMyKey = #PB_Shortcut_F18
    Case "F19"
      nMyKey = #PB_Shortcut_F19
    Case "F20"
      nMyKey = #PB_Shortcut_F20
    Case "F21"
      nMyKey = #PB_Shortcut_F21
    Case "F22"
      nMyKey = #PB_Shortcut_F22
    Case "F23"
      nMyKey = #PB_Shortcut_F23
    Case "F24"
      nMyKey = #PB_Shortcut_F24
    Case "NumLock"
      nMyKey = #PB_Shortcut_Numlock
    Case "Scroll"
      nMyKey = #PB_Shortcut_Scroll
      
      ; 'undocumented' PB shortcut values, so assigned to SCS constants - see also getShortcutVK() below
    Case "Equals", "="
      nMyKey = #SCS_Shortcut_Equals
    Case "LeftBracket", "["
      nMyKey = #SCS_Shortcut_LeftBracket
    Case "RightBracket", "]"
      nMyKey = #SCS_Shortcut_RightBracket
    Case "SemiColon", ";"
      nMyKey = #SCS_Shortcut_SemiColon
    Case "Apostrophe", "'"
      nMyKey = #SCS_Shortcut_Apostrophe
    Case "Grave", "`"
      nMyKey = #SCS_Shortcut_Grave
    Case "BackSlash", "\"
      nMyKey = #SCS_Shortcut_Backslash
    Case "Comma", ","
      nMyKey = #SCS_Shortcut_Comma
    Case "Period", "."
      nMyKey = #SCS_Shortcut_Period
    Case "Slash", "/"
      nMyKey = #SCS_Shortcut_Slash
    Case "Minus", "-"
      nMyKey = #SCS_Shortcut_Minus
      
  EndSelect
  
  ProcedureReturn nMyShift | nMyKey
EndProcedure

Procedure.l getShortcutVK(nShortcut, *nShortcutNumPadVK)
  PROCNAMEC()
  ; get shortcut key 'virtual key', eg #VK_F1
  Protected nMyShortCut
  Protected nMyKeyVK.l = 0
  Protected nNumPadVK.l = 0
  
  nMyShortCut = nShortcut
  
  If nMyShortCut & #PB_Shortcut_Control
    nMyShortCut ! #PB_Shortcut_Control
  EndIf
  If nMyShortCut & #PB_Shortcut_Alt
    nMyShortCut ! #PB_Shortcut_Alt
  EndIf
  If nMyShortCut & #PB_Shortcut_Shift
    nMyShortCut ! #PB_Shortcut_Shift
  EndIf
  If nMyShortCut & #PB_Shortcut_Command
    nMyShortCut ! #PB_Shortcut_Command
  EndIf
  
  Select nMyShortCut
    Case #PB_Shortcut_Back
      nMyKeyVK = #VK_BACK
    Case #PB_Shortcut_Tab
      nMyKeyVK = #VK_TAB
    Case #PB_Shortcut_Return
      nMyKeyVK = #VK_RETURN
    Case #PB_Shortcut_Menu
      nMyKeyVK = #VK_MENU
    Case #PB_Shortcut_Capital
      nMyKeyVK = #VK_CAPITAL
    Case #PB_Shortcut_Escape
      nMyKeyVK = #VK_ESCAPE
    Case #PB_Shortcut_Space
      nMyKeyVK = #VK_SPACE
    Case #PB_Shortcut_PageUp
      nMyKeyVK = #VK_PRIOR
    Case #PB_Shortcut_PageDown
      nMyKeyVK = #VK_NEXT
    Case #PB_Shortcut_End
      nMyKeyVK = #VK_END
    Case #PB_Shortcut_Home
      nMyKeyVK = #VK_HOME
    Case #PB_Shortcut_Left
      nMyKeyVK = #VK_LEFT
    Case #PB_Shortcut_Up
      nMyKeyVK = #VK_UP
    Case #PB_Shortcut_Right
      nMyKeyVK = #VK_RIGHT
    Case #PB_Shortcut_Down
      nMyKeyVK = #VK_DOWN
    Case #PB_Shortcut_Select
      nMyKeyVK = #VK_SELECT
    Case #PB_Shortcut_Execute
      nMyKeyVK = #VK_EXECUTE
    Case #PB_Shortcut_Snapshot
      nMyKeyVK = #VK_SNAPSHOT
    Case #PB_Shortcut_Insert
      nMyKeyVK = #VK_INSERT
    Case #PB_Shortcut_Delete
      nMyKeyVK = #VK_DELETE
    Case #PB_Shortcut_Help
      nMyKeyVK = #VK_HELP
    Case #PB_Shortcut_0
      nMyKeyVK = #VK_0
      nNumPadVK = #VK_NUMPAD0
    Case #PB_Shortcut_1
      nMyKeyVK = #VK_1
      nNumPadVK = #VK_NUMPAD1
    Case #PB_Shortcut_2
      nMyKeyVK = #VK_2
      nNumPadVK = #VK_NUMPAD2
    Case #PB_Shortcut_3
      nMyKeyVK = #VK_3
      nNumPadVK = #VK_NUMPAD3
    Case #PB_Shortcut_4
      nMyKeyVK = #VK_4
      nNumPadVK = #VK_NUMPAD4
    Case #PB_Shortcut_5
      nMyKeyVK = #VK_5
      nNumPadVK = #VK_NUMPAD5
    Case #PB_Shortcut_6
      nMyKeyVK = #VK_6
      nNumPadVK = #VK_NUMPAD6
    Case #PB_Shortcut_7
      nMyKeyVK = #VK_7
      nNumPadVK = #VK_NUMPAD7
    Case #PB_Shortcut_8
      nMyKeyVK = #VK_8
      nNumPadVK = #VK_NUMPAD8
    Case #PB_Shortcut_9
      nMyKeyVK = #VK_9
      nNumPadVK = #VK_NUMPAD9
    Case #PB_Shortcut_A
      nMyKeyVK = #VK_A
    Case #PB_Shortcut_B
      nMyKeyVK = #VK_B
    Case #PB_Shortcut_C
      nMyKeyVK = #VK_C
    Case #PB_Shortcut_D
      nMyKeyVK = #VK_D
    Case #PB_Shortcut_E
      nMyKeyVK = #VK_E
    Case #PB_Shortcut_F
      nMyKeyVK = #VK_F
    Case #PB_Shortcut_G
      nMyKeyVK = #VK_G
    Case #PB_Shortcut_H
      nMyKeyVK = #VK_H
    Case #PB_Shortcut_I
      nMyKeyVK = #VK_I
    Case #PB_Shortcut_J
      nMyKeyVK = #VK_J
    Case #PB_Shortcut_K
      nMyKeyVK = #VK_K
    Case #PB_Shortcut_L
      nMyKeyVK = #VK_L
    Case #PB_Shortcut_M
      nMyKeyVK = #VK_M
    Case #PB_Shortcut_N
      nMyKeyVK = #VK_N
    Case #PB_Shortcut_O
      nMyKeyVK = #VK_O
    Case #PB_Shortcut_P
      nMyKeyVK = #VK_P
    Case #PB_Shortcut_Q
      nMyKeyVK = #VK_Q
    Case #PB_Shortcut_R
      nMyKeyVK = #VK_R
    Case #PB_Shortcut_S
      nMyKeyVK = #VK_S
    Case #PB_Shortcut_T
      nMyKeyVK = #VK_T
    Case #PB_Shortcut_U
      nMyKeyVK = #VK_U
    Case #PB_Shortcut_V
      nMyKeyVK = #VK_V
    Case #PB_Shortcut_W
      nMyKeyVK = #VK_W
    Case #PB_Shortcut_X
      nMyKeyVK = #VK_X
    Case #PB_Shortcut_Y
      nMyKeyVK = #VK_Y
    Case #PB_Shortcut_Z
      nMyKeyVK = #VK_Z
    Case #PB_Shortcut_Pad0
      nMyKeyVK = #VK_NUMPAD0
    Case #PB_Shortcut_Pad1
      nMyKeyVK = #VK_NUMPAD1
    Case #PB_Shortcut_Pad2
      nMyKeyVK = #VK_NUMPAD2
    Case #PB_Shortcut_Pad3
      nMyKeyVK = #VK_NUMPAD3
    Case #PB_Shortcut_Pad4
      nMyKeyVK = #VK_NUMPAD4
    Case #PB_Shortcut_Pad5
      nMyKeyVK = #VK_NUMPAD5
    Case #PB_Shortcut_Pad6
      nMyKeyVK = #VK_NUMPAD6
    Case #PB_Shortcut_Pad7
      nMyKeyVK = #VK_NUMPAD7
    Case #PB_Shortcut_Pad8
      nMyKeyVK = #VK_NUMPAD8
    Case #PB_Shortcut_Pad9
      nMyKeyVK = #VK_NUMPAD9
    Case #PB_Shortcut_Multiply
      nMyKeyVK = #VK_MULTIPLY
    Case #PB_Shortcut_Add
      nMyKeyVK = #VK_ADD
    Case #PB_Shortcut_Subtract
      nMyKeyVK = #VK_SUBTRACT
    Case #PB_Shortcut_Decimal
      nMyKeyVK = #VK_DECIMAL
    Case #PB_Shortcut_Divide
      nMyKeyVK = #VK_DIVIDE
    Case #PB_Shortcut_F1
      nMyKeyVK = #VK_F1
    Case #PB_Shortcut_F2
      nMyKeyVK = #VK_F2
    Case #PB_Shortcut_F3
      nMyKeyVK = #VK_F3
    Case #PB_Shortcut_F4
      nMyKeyVK = #VK_F4
    Case #PB_Shortcut_F5
      nMyKeyVK = #VK_F5
    Case #PB_Shortcut_F6
      nMyKeyVK = #VK_F6
    Case #PB_Shortcut_F7
      nMyKeyVK = #VK_F7
    Case #PB_Shortcut_F8
      nMyKeyVK = #VK_F8
    Case #PB_Shortcut_F9
      nMyKeyVK = #VK_F9
    Case #PB_Shortcut_F10
      nMyKeyVK = #VK_F10
    Case #PB_Shortcut_F11
      nMyKeyVK = #VK_F11
    Case #PB_Shortcut_F12
      nMyKeyVK = #VK_F12
    Case #PB_Shortcut_Numlock
      nMyKeyVK = #VK_NUMLOCK
    Case #PB_Shortcut_Scroll
      nMyKeyVK = #VK_SCROLL
    Case #PB_Shortcut_PageUp ; Added 17Apr2022 11.9.1bb
      nMyKeyVK = #VK_PRIOR
    Case #PB_Shortcut_PageDown ; Added 17Apr2022 11.9.1bb
      nMyKeyVK = #VK_NEXT
      
      ; the following VK codes obtained from http://www.kbdedit.com/manual/low_level_vk_list.html
      ; (added 14Jul2018 11.7.2aa following bug report "Shortcut for Master Fader Reset Doesn't Work" by Bellevillain)
    Case #SCS_Shortcut_SemiColon
      nMyKeyVK = #VK_OEM_1      ; OEM_1 (: ;)
    Case #SCS_Shortcut_Slash
      nMyKeyVK = #VK_OEM_2      ; OEM_2 (? /)
    Case #SCS_Shortcut_Grave
      nMyKeyVK = #VK_OEM_3      ; OEM_3 (~ `)
    Case #SCS_Shortcut_LeftBracket
      nMyKeyVK = #VK_OEM_4      ; OEM_4 ({ [)
    Case #SCS_Shortcut_Backslash
      nMyKeyVK = #VK_OEM_5      ; OEM_5 (| \)
    Case #SCS_Shortcut_RightBracket
      nMyKeyVK = #VK_OEM_6      ; OEM_6 (} ])
    Case #SCS_Shortcut_Apostrophe
      nMyKeyVK = #VK_OEM_7      ; OEM_7 (" ')
    Case #SCS_Shortcut_Comma
      nMyKeyVK = #VK_OEM_COMMA  ; OEM_COMMA (< ,)
    Case #SCS_Shortcut_Period
      nMyKeyVK = #VK_OEM_PERIOD ; OEM_PERIOD (> .)
    Case #SCS_Shortcut_Equals
      nMyKeyVK = #VK_OEM_PLUS   ; OEM_PLUS (+ =)
    Case #SCS_Shortcut_Minus
      nMyKeyVK = #VK_OEM_MINUS  ; OEM_MINUS (_ -)
      
    Case 0
      nMyKeyVK = 0
      
    Default
      Debug sProcName + ": shortcut not recognised: nShortcut=" + nShortcut + ", nMyShortCut=" + nMyShortCut
      debugMsg(sProcName, "shortcut not recognised: nShortcut=" + nShortcut + ", nMyShortCut=" + nMyShortCut)
      
  EndSelect
  
  PokeL(*nShortcutNumPadVK, nNumPadVK)
  ProcedureReturn nMyKeyVK
EndProcedure

Procedure populateOrderedShortcutArray()
  ; This array is required so that successive #PB_Key values can be assigned to 'favorite files'.
  ; Note that the numerical keys are 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 in that order (as per the keyboard)
  gaOrderedShortcut(0) = #PB_Shortcut_A
  gaOrderedShortcut(1) = #PB_Shortcut_B
  gaOrderedShortcut(2) = #PB_Shortcut_C
  gaOrderedShortcut(3) = #PB_Shortcut_D
  gaOrderedShortcut(4) = #PB_Shortcut_E
  gaOrderedShortcut(5) = #PB_Shortcut_F
  gaOrderedShortcut(6) = #PB_Shortcut_G
  gaOrderedShortcut(7) = #PB_Shortcut_H
  gaOrderedShortcut(8) = #PB_Shortcut_I
  gaOrderedShortcut(9) = #PB_Shortcut_J
  gaOrderedShortcut(10) = #PB_Shortcut_K
  gaOrderedShortcut(11) = #PB_Shortcut_L
  gaOrderedShortcut(12) = #PB_Shortcut_M
  gaOrderedShortcut(13) = #PB_Shortcut_N
  gaOrderedShortcut(14) = #PB_Shortcut_O
  gaOrderedShortcut(15) = #PB_Shortcut_P
  gaOrderedShortcut(16) = #PB_Shortcut_Q
  gaOrderedShortcut(17) = #PB_Shortcut_R
  gaOrderedShortcut(18) = #PB_Shortcut_S
  gaOrderedShortcut(19) = #PB_Shortcut_T
  gaOrderedShortcut(20) = #PB_Shortcut_U
  gaOrderedShortcut(21) = #PB_Shortcut_V
  gaOrderedShortcut(22) = #PB_Shortcut_W
  gaOrderedShortcut(23) = #PB_Shortcut_X
  gaOrderedShortcut(24) = #PB_Shortcut_Y
  gaOrderedShortcut(25) = #PB_Shortcut_Z
  gaOrderedShortcut(26) = #PB_Shortcut_1
  gaOrderedShortcut(27) = #PB_Shortcut_2
  gaOrderedShortcut(28) = #PB_Shortcut_3
  gaOrderedShortcut(29) = #PB_Shortcut_4
  gaOrderedShortcut(30) = #PB_Shortcut_5
  gaOrderedShortcut(31) = #PB_Shortcut_6
  gaOrderedShortcut(32) = #PB_Shortcut_7
  gaOrderedShortcut(33) = #PB_Shortcut_8
  gaOrderedShortcut(34) = #PB_Shortcut_9
  gaOrderedShortcut(35) = #PB_Shortcut_0
EndProcedure

Procedure getIndexForMainShortcutFunction(nShortcutFunction)
  PROCNAMEC()
  Protected n, nIndex = -1
  
  For n = 0 To ArraySize(gaShortcutsMain())
    If gaShortcutsMain(n)\nShortcutFunction = nShortcutFunction
      nIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nIndex
EndProcedure

Procedure getIndexForEditorShortcutFunction(nShortcutFunction)
  PROCNAMEC()
  Protected n, nIndex = -1
  
  For n = 0 To ArraySize(gaShortcutsEditor())
    If gaShortcutsEditor(n)\nShortcutFunction = nShortcutFunction
      nIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nIndex
EndProcedure

Procedure populateExclCueOverrideShortcut()
  PROCNAMEC()
  Protected nExclCueOverrideShortcut
  Protected sGoButtonShortcutStr.s, sExclCueOverrideShortcutStr.s
  
  debugMsg(sProcName, "grGeneralOptions\bCtrlOverridesExclCue=" + strB(grGeneralOptions\bCtrlOverridesExclCue))
  If grGeneralOptions\bCtrlOverridesExclCue
    sGoButtonShortcutStr = gaShortcutsMain(#SCS_ShortMain_GoButton)\sShortcutStr
    debugMsg(sProcName, "sGoButtonShortcutStr=" + sGoButtonShortcutStr)
    If sGoButtonShortcutStr
      If FindString(sGoButtonShortcutStr, "Ctrl+") = #False
        sExclCueOverrideShortcutStr = "Ctrl+" + sGoButtonShortcutStr
      EndIf
    EndIf
  EndIf
  
  With gaShortcutsMain(#SCS_ShortMain_ExclCueOverride)
    \sShortcutStr = sExclCueOverrideShortcutStr
    \nShortcut = encodeShortcut(\sShortcutStr)
    \nShortcutVK = getShortcutVK(\nShortcut, @\nShortcutNumPadVK)
    debugMsg(sProcName, "gaShortcutsMain(" + #SCS_ShortMain_ExclCueOverride + ")\sShortcutStr=" + \sShortcutStr)
  EndWith
  
EndProcedure

Procedure.s getMainShortcutStr(nShortcutFunction)
  Protected n
  Protected sShortcutStr.s
  
  For n = 0 To ArraySize(gaShortcutsMain())
    With gaShortcutsMain(n)
      If \nShortcutFunction = nShortcutFunction
        sShortcutStr = \sShortcutStr
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn sShortcutStr
  
EndProcedure

Procedure.s getEditorShortcutStr(nShortcutFunction)
  Protected n
  Protected sShortcutStr.s
  
  For n = 0 To ArraySize(gaShortcutsEditor())
    With gaShortcutsEditor(n)
      If \nShortcutFunction = nShortcutFunction
        sShortcutStr = \sShortcutStr
        Break
      EndIf
    EndWith
  Next n
  ProcedureReturn sShortcutStr
  
EndProcedure

Procedure getMainShortcutFunctionForPBShortcut(nPBShortcut)
  PROCNAMEC()
  Protected n, nShortcutFunction
  
  nShortcutFunction = -1
  Select nPBShortcut
    Case #PB_Shortcut_1 To #PB_Shortcut_9
      nShortcutFunction = #SCS_WMNF_HK_1 + nPBShortcut - #PB_Shortcut_1
    Case #PB_Shortcut_Pad1 To #PB_Shortcut_Pad9
      nShortcutFunction = #SCS_WMNF_HK_1 + nPBShortcut - #PB_Shortcut_Pad1
    Case #PB_Shortcut_0, #PB_Shortcut_Pad0
      nShortcutFunction = #SCS_WMNF_HK_0
    Case #PB_Shortcut_A To #PB_Shortcut_Z
      nShortcutFunction = #SCS_WMNF_HK_A + nPBShortcut - #PB_Shortcut_A
    Case #PB_Shortcut_F1 To #PB_Shortcut_F12
      nShortcutFunction = #SCS_WMNF_HK_F1 + nPBShortcut - #PB_Shortcut_F1
    Case #PB_Shortcut_PageUp ; Added 17Apr2022 11.9.1bc
      nShortcutFunction = #SCS_WMNF_HK_PGUP
    Case #PB_Shortcut_PageDown ; Added 17Apr2022 11.9.1bc
      nShortcutFunction = #SCS_WMNF_HK_PGDN
; Added 25Jul2020 but commented out when I realised that some of these 'shortcut keys' are already used as Master Fader shortcut keys
;     Case #PB_Shortcut_Add
;       nShortcutFunction = #SCS_WMNF_HK_ADD
;     Case #PB_Shortcut_Subtract
;       nShortcutFunction = #SCS_WMNF_HK_SUBTRACT
;     Case #PB_Shortcut_Divide
;       nShortcutFunction = #SCS_WMNF_HK_DIVIDE
;     Case #PB_Shortcut_Multiply
;       nShortcutFunction = #SCS_WMNF_HK_MULTIPLY
;     Case #PB_Shortcut_Decimal
;       nShortcutFunction = #SCS_WMNF_HK_DECIMAL
  EndSelect
  ProcedureReturn nShortcutFunction
  
EndProcedure

Procedure getPBShortcutForMainShortcutFunction(nShortcutFunction)
  PROCNAMEC()
  Protected n, nPBShortcut
  
  nPBShortcut = -1
  Select nShortcutFunction
    Case #SCS_WMNF_HK_1 To #SCS_WMNF_HK_9
      nPBShortcut = #PB_Shortcut_1 + (nShortcutFunction - #SCS_WMNF_HK_1)
    Case #SCS_WMNF_HK_0
      nPBShortcut = #PB_Shortcut_0
    Case #SCS_WMNF_HK_A To #SCS_WMNF_HK_Z
      nPBShortcut = #PB_Shortcut_A + (nShortcutFunction - #SCS_WMNF_HK_A)
    Case #SCS_WMNF_HK_F1 To #SCS_WMNF_HK_F12
      nPBShortcut = #PB_Shortcut_F1 + (nShortcutFunction - #SCS_WMNF_HK_F1)
    Case #SCS_WMNF_HK_PGUP ; Added 17Apr2022 11.9.1bc
      nPBShortcut = #PB_Shortcut_PageUp
    Case #SCS_WMNF_HK_PGDN ; Added 17Apr2022 11.9.1bc
      nPBShortcut = #PB_Shortcut_PageDown
; Added 25Jul2020 but commented out when I realised that some of these 'shortcut keys' are already used as Master Fader shortcut keys
;     Case #SCS_WMNF_HK_ADD
;       nPBShortcut = #PB_Shortcut_Add
;     Case #SCS_WMNF_HK_SUBTRACT
;       nPBShortcut = #PB_Shortcut_Subtract
;     Case #SCS_WMNF_HK_DIVIDE
;       nPBShortcut = #PB_Shortcut_Divide
;     Case #SCS_WMNF_HK_MULTIPLY
;       nPBShortcut = #PB_Shortcut_Multiply
;     Case #SCS_WMNF_HK_DECIMAL
;       nPBShortcut = #PB_Shortcut_Decimal
  EndSelect
  ProcedureReturn nPBShortcut
  
EndProcedure

Procedure.s decodeMainShortcutFunction(nShortcutFunction)
  PROCNAMEC()
  Protected nIndex, sParam.s
  
  nIndex = getIndexForMainShortcutFunction(nShortcutFunction)
  If nIndex >= 0
    sParam = decodeShortcut(gaShortcutsMain(nIndex)\nShortcut)
  EndIf
  ProcedureReturn sParam
EndProcedure

Procedure.s decodeEditorShortcutFunction(nShortcutFunction)
  PROCNAMEC()
  Protected nIndex, sParam.s
  
  nIndex = getIndexForEditorShortcutFunction(nShortcutFunction)
  If nIndex >= 0
    sParam = decodeShortcut(gaShortcutsEditor(nIndex)\nShortcut)
  EndIf
  ProcedureReturn sParam
EndProcedure

; EOF