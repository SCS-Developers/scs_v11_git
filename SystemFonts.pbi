; Code for receiving the Windows system font (posting by 'rashad') taken from:
;   http://www.purebasic.fr/english/viewtopic.php?f=13&t=64682
;
; More informations about the different Windows system fonts can be found in this MSDN article:
;   https://msdn.microsoft.com/en-us/library/dn742483.aspx

EnableExplicit

Enumeration 1
  #Font_CaptionFont         ; The font used by window captions
  #Font_SmallCaptionFont    ; The font used by window small captions
  #Font_MenuFont            ; The font used by menus
  #Font_StatusFont          ; The font used in status messages
  #Font_MsgBoxFont          ; The font used to display messages in a message box
  #Font_IconTitleFont       ; The font used for icons
EndEnumeration

Structure fontdetails
  Name$
  Size.i
EndStructure
Global Dim SystemFont.fontdetails(#Font_IconTitleFont)

#TMT_CAPTIONFONT = 801
#TMT_SMALLCAPTIONFONT = 802
#TMT_MENUFONT = 803
#TMT_STATUSFONT = 804
#TMT_MSGBOXFONT = 805
#TMT_ICONTITLEFONT = 806

Import "Uxtheme.lib"
  OpenThemeData(Window.i, Body.p-unicode)
  GetThemeSysFont(hTheme,iConst,pStructure)
  CloseThemeData(hTheme)
EndImport

Procedure getSystemFonts()
  Protected hTheme, a, hDC
  Protected fntName$, fntHeight
  Protected lf.LOGFONT
  
  hTheme = OpenThemeData(0, "Window")
  
  For a = 1 To #Font_IconTitleFont
    GetThemeSysFont(hTheme, 800+a , lf.LOGFONT)     ; instead of the fixed font constants #TMT_MSGBOXFONT etc. we use an incrementing variable
    fntName$ =  PeekS(@lf\lfFaceName, 32, #PB_Unicode)
    hDC = GetDC_(0)
    fntHeight = Round(Abs(lf\lfheight) * 72 / GetDeviceCaps_(hDC, #LOGPIXELSY), #PB_Round_Nearest)
    ReleaseDC_(0, hDC)
    
    CompilerIf #PB_Compiler_IsMainFile
      ; Debug output of the currently selected font:
      Debug fntName$ + " / " + fntHeight
    CompilerEndIf
    
    ; Storing the font information in the array for later use:
    SystemFont(a)\Name$ = fntName$
    SystemFont(a)\Size  = fntHeight
  Next a
  
  CloseThemeData(htheme)
EndProcedure

CompilerIf #PB_Compiler_IsMainFile
  ; And here the font we want to use:
  LoadFont(0, SystemFont(#Font_MsgBoxFont)\Name$, SystemFont(#Font_MsgBoxFont)\Size)
  SetGadgetFont(#PB_Default, FontID(0))
CompilerEndIf

; IDE Options = PureBasic 5.42 LTS (Windows - x64)
; CursorPosition = 55
; FirstLine = 8
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError