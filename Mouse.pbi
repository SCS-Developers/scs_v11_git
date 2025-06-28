; File: Mouse.pbi

EnableExplicit


Procedure isLeftMouseButtonDown()   ; return current state of left mousebutton 
  ; based on code obtained from this PB Forum topic: http://www.purebasic.fr/english/viewtopic.php?t=15053
  ; 
  ; retval: #True  - mouse button down 
  ;         #False - mouse button up 
  ; 
  ; note: does not use events! 
  ; 
  If GetSystemMetrics_(#SM_SWAPBUTTON) = 0 
    ProcedureReturn (GetAsyncKeyState_(#VK_LBUTTON) & $8000)
  Else 
    ProcedureReturn (GetAsyncKeyState_(#VK_RBUTTON) & $8000)
  EndIf 
EndProcedure 

Procedure isRightMouseButtonDown()  ; return current state of right mousebutton 
  ; 
  ; note: does not use events! 
  ; 
  If GetSystemMetrics_(#SM_SWAPBUTTON) = 0 
    ProcedureReturn (GetAsyncKeyState_(#VK_RBUTTON) & $8000)
  Else 
    ProcedureReturn (GetAsyncKeyState_(#VK_LBUTTON) & $8000)
  EndIf 
EndProcedure 

Procedure x_mousewheel(mode)  ; returns number of lines up / down upon using the scrollwheel after a #WM_MOUSEWHEEL event 
  ; 
  ; *** returns number of lines up / down upon using the scrollwheel after a #WM_MOUSEWHEEL event 
  ; 
  ; in:     mode = 0   - one line per message, return -1 for up, +1 for down 
  ;                = 1   - use windows setting for calculating number of lines, from -n to +n 
  ; retval: <0          - up 
  ;         >0          - down 
  ; 
  Protected nLines
  
  If mode = 0 
    ; !!!!!!! need explanation/definition of x_sgn !!!!!!!!
    ; nLines = x_sgn( EventwParam() >> 16 ) 
  Else 
    ; 
    ; #SPI_GETWHEELSCROLLLINES = 104 
    ; 
    nLines = 0 
    SystemParametersInfo_(104,0,@nLines,0) 
    nLines = (EventwParam() >> 16)*nLines/120 
    ; 
  EndIf 
  ProcedureReturn nLines
EndProcedure 

; EOF

; IDE Options = PureBasic 5.62 (Windows - x64)
; Folding = -
; EnableThread
; EnableXP
; EnableOnError
; EnableUnicode