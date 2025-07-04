;/ ===========================
;/ =    TextEx-Module.pbi    =
;/ ===========================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/ Extented TextGadget (e.g. gradient background / multiline / automatic size adjustment) 
;/
;/ � 2019 Thorsten1867 (03/2019)
;/

; Last Update: 29.12.19
;
; Added:   AdjustSize()
; Changed: #ResizeWidth  -> #Width
; Changed: #ResizeHeight -> #Height


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;}


;{ _____TextEx - Commands _____

; TextEx::AdjustSize()         - adjusting the size to the content
; TextEx::Disable()            - similar to 'DisableGadget()'
; TextEx::Gadget()             - similar to 'TextGadget()'
; TextEx::GetColor()           - similar to 'GetGadgetColor()'
; TextEx::GetData()            - similar to 'GetGadgetData()'
; TextEx::GetID()              - similar to 'GetGadgetData()', but string
; TextEx::GetText()            - similar to 'GetGadgetText()'
; TextEx::Hide()               - similar to 'HideGadget()'
; TextEx::SetAttribute()       - similar to 'SetGadgetAttribute()'
; TextEx::SetAutoResizeFlags() - [#MoveX|#MoveY|#Width|#Height]
; TextEx::SetColor()           - similar to 'SetGadgetColor()'
; TextEx::SetData()            - similar to 'SetGadgetData()'
; TextEx::SetFont()            - similar to 'SetGadgetFont()'
; TextEx::SetID()              - similar to 'SetGadgetData()', but string
; TextEx::SetText()            - similar to 'SetGadgetText()'

;}

; XIncludeFile "ModuleEx.pbi"

DeclareModule TextEx
  
  #Version  = 19122900
  #ModuleEx = 19112102
  
  ;- ===========================================================================
  ;-   DeclareModule - Constants / Structures
  ;- =========================================================================== 
  
  #Left = 0
  
  EnumerationBinary ;{ Gadget Flags
    #Center = #PB_Text_Center
    #Right  = #PB_Text_Right
    #Gradient
    #AutoResize
    #MultiLine
    #UseExistingCanvas
    #Border = #PB_Text_Border
  EndEnumeration ;}
  
  EnumerationBinary ;{ Autoresize
    #MoveX
    #MoveY
    #Width
    #Height
  EndEnumeration ;}
  
  Enumeration 1     ;{ Attribute
    #Corner
  EndEnumeration ;} 
  
  Enumeration 1     ;{ Colors
    #FrontColor
    #BackColor
    #GradientColor
    #BorderColor
  EndEnumeration ;}
  
  CompilerIf Defined(ModuleEx, #PB_Module)

		#Event_Theme = ModuleEx::#Event_Theme

	CompilerEndIf
  
  ;- ===========================================================================
  ;-   DeclareModule
  ;- ===========================================================================
	
	Declare   AdjustSize(GNum.i, Flags.i, Padding.i=5)
	Declare   Disable(GNum.i, State.i=#True)
  Declare   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
  Declare.i GetColor(GNum.i, ColorType.i)
  Declare.q GetData(GNum.i)
	Declare.s GetID(GNum.i)
  Declare.s GetText(GNum.i)
  Declare   Hide(GNum.i, State.i=#True)
  Declare   SetColor(GNum.i, ColorType.i, Value.i)
  Declare   SetData(GNum.i, Value.q)
  Declare   SetFont(GNum.i, FontID.i)
  Declare   SetID(GNum.i, String.s)
  Declare   SetText(GNum.i, Text.s)
  Declare   SetAttribute(GNum.i, Attribute.i, Value.i)
  Declare   SetAutoResizeFlags(GNum.i, Flags.i)
  
EndDeclareModule



Module TextEx
  
  EnableExplicit
  
  ;- ============================================================================
  ;-   Module - Constants / Structures
  ;- ============================================================================  
  
  Structure   TextEx_Required_Structure  ;{ TextEx()\Required\...
    Width.i
    Height.i
  EndStructure
  
  Structure TextEx_Window_Structure  ;{ TextEx()\Window\...
    Num.i
    Width.f
    Height.f
  EndStructure ;}
  
  Structure TextEx_Size_Structure  ;{ TextEx()\Size\...
    X.f
    Y.f
    Width.f
    Height.f
    winWidth.f
    winHeight.f
    Flags.i
  EndStructure ;} 
  
  Structure TextEx_Color_Structure ;{ TextEx()\Color\...
    Front.i
    Back.i
    Gradient.i
    Gadget.i
    Border.i
    DisableFront.i
    DisableBack.i
  EndStructure  ;}
  
  Structure TextEx_Structure       ;{ TextEx()\...
    WindowNum.i
    CanvasNum.i
    
    Quad.q
    ID.s
    
    FontID.i
    
    Text.s
    
    Radius.i
    
    Disable.i
    Hide.i
    
    Flags.i
    
    Color.TextEx_Color_Structure
    Required.TextEx_Required_Structure
    Size.TextEx_Size_Structure
    Window.TextEx_Window_Structure
    
  EndStructure ;}
  Global NewMap TextEx.TextEx_Structure()
  
  ;- ============================================================================
  ;-   Module - Internal
  ;- ============================================================================ 
  
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
    ; Addition of mk-soft
    
    Procedure OSX_NSColorToRGBA(NSColor)
      Protected.cgfloat red, green, blue, alpha
      Protected nscolorspace, rgba
      nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        CocoaMessage(@alpha, nscolorspace, "alphaComponent")
        rgba = RGBA(red * 255.9, green * 255.9, blue * 255.9, alpha * 255.)
        ProcedureReturn rgba
      EndIf
    EndProcedure
    
    Procedure OSX_NSColorToRGB(NSColor)
      Protected.cgfloat red, green, blue
      Protected r, g, b, a
      Protected nscolorspace, rgb
      nscolorspace = CocoaMessage(0, nscolor, "colorUsingColorSpaceName:$", @"NSCalibratedRGBColorSpace")
      If nscolorspace
        CocoaMessage(@red, nscolorspace, "redComponent")
        CocoaMessage(@green, nscolorspace, "greenComponent")
        CocoaMessage(@blue, nscolorspace, "blueComponent")
        rgb = RGB(red * 255.0, green * 255.0, blue * 255.0)
        ProcedureReturn rgb
      EndIf
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure.i GetGadgetWindow()
      ProcedureReturn ModuleEx::GetGadgetWindow()
    EndProcedure
    
  CompilerElse  
    
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      ; Thanks to mk-soft
      Import ""
        PB_Object_EnumerateStart(PB_Objects)
        PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
        PB_Object_EnumerateAbort( PB_Objects )
        PB_Window_Objects.i
      EndImport
    CompilerElse
      ImportC ""
        PB_Object_EnumerateStart( PB_Objects )
        PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
        PB_Object_EnumerateAbort( PB_Objects )
        PB_Window_Objects.i
      EndImport
    CompilerEndIf
    
    Procedure.i GetGadgetWindow()
      ; Thanks to mk-soft
      Define.i WindowID, Window, Result = #PB_Default
      
      WindowID = UseGadgetList(0)
      
      PB_Object_EnumerateStart(PB_Window_Objects)
      
      While PB_Object_EnumerateNext(PB_Window_Objects, @Window)
        If WindowID = WindowID(Window)
          Result = Window
          Break
        EndIf
      Wend
      
      PB_Object_EnumerateAbort(PB_Window_Objects)
      
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf	  
  
  
  Procedure.f dpiX(Num.i)
    ProcedureReturn DesktopScaledX(Num)
  EndProcedure
  
  Procedure.f dpiY(Num.i)
    ProcedureReturn DesktopScaledY(Num)
  EndProcedure
  
  
  ;- __________ Drawing __________
  
  Procedure.i BlendColor_(Color1.i, Color2.i, Scale.i=50)
    Define.i R1, G1, B1, R2, G2, B2
    Define.f Blend = Scale / 100
    
    R1 = Red(Color1): G1 = Green(Color1): B1 = Blue(Color1)
    R2 = Red(Color2): G2 = Green(Color2): B2 = Blue(Color2)
    
    ProcedureReturn RGB((R1*Blend) + (R2 * (1-Blend)), (G1*Blend) + (G2 * (1-Blend)), (B1*Blend) + (B2 * (1-Blend)))
  EndProcedure
  
  Procedure.f GetOffsetX_(Text.s, OffsetX.f) 
    
    If TextEx()\Flags & #Center
      ProcedureReturn (TextEx()\Size\Width - TextWidth(Text)) / 2
    ElseIf TextEx()\Flags & #Right
      ProcedureReturn TextEx()\Size\Width - TextWidth(Text) - OffsetX
    Else
      ProcedureReturn OffsetX
    EndIf
 
  EndProcedure  
  
  Procedure   Box_(X.i, Y.i, Width.i, Height.i, Color.i)
    
    If TextEx()\Radius
      Box(X, Y, Width, Height, TextEx()\Color\Gadget)
      If Color = #PB_Default
        RoundBox(X, Y, Width, Height, TextEx()\Radius, TextEx()\Radius)
      Else
        RoundBox(X, Y, Width, Height, TextEx()\Radius, TextEx()\Radius, Color)
      EndIf
		Else
		  If Color = #PB_Default
		    Box(X, Y, Width, Height)
		  Else  
		    Box(X, Y, Width, Height, Color)
		  EndIf   
		EndIf
		
	EndProcedure 
  
  
  Procedure Draw_()
    Define.f textY, textX, OffsetX
    Define.i TextHeight, Rows, r
    Define.i FrontColor, BackColor, BorderColor, GradientColor
    Define.s Text
    
    If TextEx()\Hide : ProcedureReturn #False : EndIf
    
    If StartDrawing(CanvasOutput(TextEx()\CanvasNum))
      
      FrontColor    = TextEx()\Color\Front
      BackColor     = TextEx()\Color\Back
      BorderColor   = TextEx()\Color\Border
      GradientColor = TextEx()\Color\Gradient
      
      If TextEx()\Disable
        FrontColor    = TextEx()\Color\DisableFront
        BackColor     = BlendColor_(TextEx()\Color\DisableBack, TextEx()\Color\Back, 90)
        GradientColor = BlendColor_(TextEx()\Color\DisableBack, TextEx()\Color\Gradient, 80)
        BorderColor   = TextEx()\Color\DisableBack
      EndIf
      
      ;{ _____ Background _____
      If TextEx()\Flags & #Gradient
        DrawingMode(#PB_2DDrawing_Gradient)
        FrontColor(BackColor)
        BackColor(GradientColor)
        LinearGradient(0, 0, TextEx()\Size\Width, TextEx()\Size\Height)
        Box_(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, #PB_Default)
        OffsetX = dpiX(5)
      Else
        DrawingMode(#PB_2DDrawing_Default)
        Box_(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BackColor)
      EndIf ;}
      
      ;{ _____ Text _____
      If TextEx()\FontID : DrawingFont(TextEx()\FontID) : EndIf
      
      TextHeight = TextHeight(TextEx()\Text)
      
      DrawingMode(#PB_2DDrawing_Transparent)
      
      If TextEx()\Flags & #MultiLine
        
        TextEx()\Required\Width = 0
        
        Rows = CountString(TextEx()\Text, #LF$) + 1
        
        textY = (TextEx()\Size\Height - (TextHeight * Rows)) / 2
        
        For r = 1 To Rows
          Text  = StringField(TextEx()\Text, r, #LF$)
          textX = GetOffsetX_(Text, OffsetX)
          DrawText(textX, textY, Text, FrontColor)
          If TextWidth(Text) > TextEx()\Required\Width : TextEx()\Required\Width = TextWidth(Text) : EndIf 
          textY + TextHeight
        Next
        
        TextEx()\Required\Height = TextHeight * Rows
      Else
        
        textY = (TextEx()\Size\Height - TextHeight) / 2
        textX = GetOffsetX_(TextEx()\Text, OffsetX) 
        
        DrawText(textX, textY, TextEx()\Text, FrontColor)
        
        TextEx()\Required\Width  = TextWidth(TextEx()\Text)
        TextEx()\Required\Height = TextHeight
      EndIf ;}
      
      TextEx()\Required\Width  = DesktopUnscaledX(TextEx()\Required\Width)  + 4
      TextEx()\Required\Height = DesktopUnscaledY(TextEx()\Required\Height) + 4

      ;{ _____ Border ____
      If TextEx()\Flags & #Border
        
        DrawingMode(#PB_2DDrawing_Outlined)
        
        If TextEx()\Color\Border = #PB_Default
          If TextEx()\Flags & #Gradient
            Box_(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BlendColor_(TextEx()\Color\Back, GradientColor, 20))
          Else
            Box_(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BlendColor_(TextEx()\Color\Back, FrontColor))
          EndIf
        Else
          Box_(0, 0, TextEx()\Size\Width, TextEx()\Size\Height, BorderColor)
        EndIf
        
      EndIf ;}

      StopDrawing()
    EndIf  

  EndProcedure 
  
  ;- __________ Events __________
  
  CompilerIf Defined(ModuleEx, #PB_Module)
    
    Procedure _ThemeHandler()

      ForEach TextEx()
        
        If IsFont(ModuleEx::ThemeGUI\Font\Num)
          TextEx()\FontID = FontID(ModuleEx::ThemeGUI\Font\Num)
        EndIf
        
        TextEx()\Color\Front        = ModuleEx::ThemeGUI\FrontColor
        TextEx()\Color\Back         = ModuleEx::ThemeGUI\GadgetColor
        TextEx()\Color\DisableFront = ModuleEx::ThemeGUI\Disable\FrontColor
        TextEx()\Color\DisableBack  = ModuleEx::ThemeGUI\Disable\BackColor
        
        Draw_()
      Next
      
    EndProcedure
    
  CompilerEndIf 
  
  
  Procedure _ResizeHandler()
    Define.i GadgetID = EventGadget()
    
    If FindMapElement(TextEx(), Str(GadgetID))
      
      TextEx()\Size\Width  = dpiX(GadgetWidth(GadgetID))
      TextEx()\Size\Height = dpiY(GadgetHeight(GadgetID))
      
      Draw_()
    EndIf  
 
  EndProcedure
  
  Procedure _ResizeWindowHandler()
    Define.f X, Y, Width, Height
    Define.f OffSetX, OffSetY
    
    ForEach TextEx()
      
      If IsGadget(TextEx()\CanvasNum)
        
        If TextEx()\Flags & #AutoResize
          
          If IsWindow(TextEx()\Window\Num)
            
            OffSetX = WindowWidth(TextEx()\Window\Num)  - TextEx()\Window\Width
            OffsetY = WindowHeight(TextEx()\Window\Num) - TextEx()\Window\Height

            TextEx()\Window\Width  = WindowWidth(TextEx()\Window\Num)
            TextEx()\Window\Height = WindowHeight(TextEx()\Window\Num)
            
            If TextEx()\Size\Flags
              
              X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
              
              If TextEx()\Size\Flags & #MoveX : X = GadgetX(TextEx()\CanvasNum) + OffSetX : EndIf
              If TextEx()\Size\Flags & #MoveY : Y = GadgetY(TextEx()\CanvasNum) + OffSetY : EndIf
              If TextEx()\Size\Flags & #Width  : Width  = GadgetWidth(TextEx()\CanvasNum)  + OffSetX : EndIf
              If TextEx()\Size\Flags & #Height : Height = GadgetHeight(TextEx()\CanvasNum) + OffSetY : EndIf
              
              ResizeGadget(TextEx()\CanvasNum, X, Y, Width, Height)
              
            Else
              ResizeGadget(TextEx()\CanvasNum, #PB_Ignore, #PB_Ignore, GadgetWidth(TextEx()\CanvasNum) + OffSetX, GadgetHeight(TextEx()\CanvasNum) + OffsetY)
            EndIf
          
            Draw_()
          EndIf
          
        EndIf
        
      EndIf
      
    Next
    
  EndProcedure
  
  
  ;- ==========================================================================
  ;-   Module - Declared Procedures
  ;- ==========================================================================  
  
  Procedure   AdjustSize(GNum.i, Flags.i, Padding.i=5)
    Define.i X, Y, Width, Height, Offset
    
    If FindMapElement(TextEx(), Str(GNum))
      
      X = #PB_Ignore : Y = #PB_Ignore : Width = #PB_Ignore : Height = #PB_Ignore
     
      If Flags & #Width  : Width  = TextEx()\Required\Width  + (Padding * 2) : EndIf 
      If Flags & #Height : Height = TextEx()\Required\Height + (Padding * 2) : EndIf 
      
      If Flags & #MoveX 
        If Width <> #PB_Ignore
          Offset = (GadgetWidth(TextEx()\CanvasNum) - Width) / 2
          X = GadgetX(TextEx()\CanvasNum) + Offset
        EndIf 
      EndIf
      
      If Flags & #MoveY
        If Height <> #PB_Ignore
          Offset = (GadgetHeight(TextEx()\CanvasNum) - Height) / 2
          Y = GadgetY(TextEx()\CanvasNum) + Offset
        EndIf
      EndIf
      
      ResizeGadget(TextEx()\CanvasNum, X, Y, Width, Height)
      
      Draw_()
    EndIf 
   
  EndProcedure  
  
	Procedure   Disable(GNum.i, State.i=#True)
    
    If FindMapElement(TextEx(), Str(GNum))  

      TextEx()\Disable = State
      DisableGadget(GNum, State)
      
      Draw_()
    EndIf  
    
  EndProcedure 	  
  
  Procedure.i GetColor(GNum.i, ColorType.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          ProcedureReturn TextEx()\Color\Front
        Case #BackColor
          ProcedureReturn TextEx()\Color\Back
        Case #BorderColor
          ProcedureReturn TextEx()\Color\Border
        Case #GradientColor
          ProcedureReturn TextEx()\Color\Gradient
      EndSelect
      
    EndIf  

  EndProcedure  
  
  Procedure.q GetData(GNum.i)
	  
	  If FindMapElement(TextEx(), Str(GNum))
	    ProcedureReturn TextEx()\Quad
	  EndIf  
	  
	EndProcedure	
	
	Procedure.s GetID(GNum.i)
	  
	  If FindMapElement(TextEx(), Str(GNum))
	    ProcedureReturn TextEx()\ID
	  EndIf
	  
	EndProcedure

  
  Procedure   Hide(GNum.i, State.i=#True)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      If State
        TextEx()\Hide = #True
        HideGadget(GNum, #True)
      Else
        TextEx()\Hide = #False
        HideGadget(GNum, #False)
        Draw_()
      EndIf
    
    EndIf  
    
  EndProcedure  
  
  Procedure   SetAttribute(GNum.i, Attribute.i, Value.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      Select Attribute
        Case #Corner
          TextEx()\Radius  = Value
      EndSelect
      
      Draw_()
    EndIf
    
  EndProcedure
  
  Procedure   SetAutoResizeFlags(GNum.i, Flags.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\Size\Flags = Flags
      
    EndIf  
   
  EndProcedure
  
  Procedure   SetColor(GNum.i, ColorType.i, Color.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      Select ColorType
        Case #FrontColor
          TextEx()\Color\Front    = Color
        Case #BackColor
          TextEx()\Color\Back     = Color
        Case #BorderColor
          TextEx()\Color\Border   = Color
        Case #GradientColor
          TextEx()\Color\Gradient = Color
      EndSelect
      
      Draw_()
    EndIf  

  EndProcedure

  Procedure   SetFont(GNum.i, FontID.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\FontID = FontID
      
      Draw_()
    EndIf  
    
  EndProcedure
  
  Procedure   SetData(GNum.i, Value.q)
	  
	  If FindMapElement(TextEx(), Str(GNum))
	    TextEx()\Quad = Value
	  EndIf  
	  
	EndProcedure
	
	Procedure   SetID(GNum.i, String.s)
	  
	  If FindMapElement(TextEx(), Str(GNum))
	    TextEx()\ID = String
	  EndIf
	  
	EndProcedure
  
  Procedure   SetText(GNum.i, Text.s)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      TextEx()\Text = Text
      
      Draw_()
    EndIf  
    
  EndProcedure
  
  
  Procedure.s GetText(GNum.i)
    
    If FindMapElement(TextEx(), Str(GNum))
      
      ProcedureReturn TextEx()\Text

    EndIf  
    
  EndProcedure
  
  
  Procedure   Gadget(GNum.i, X.i, Y.i, Width.i, Height.i, Text.s, Flags.i=#False, WindowNum.i=#PB_Default)
    Define.i Result, txtNum
    
    CompilerIf Defined(ModuleEx, #PB_Module)
      If ModuleEx::#Version < #ModuleEx : Debug "Please update ModuleEx.pbi" : EndIf 
    CompilerEndIf
    
    If Flags & #UseExistingCanvas ;{ Use an existing CanvasGadget
      If IsGadget(GNum)
        Result = #True
      Else
        ProcedureReturn #False
      EndIf
      ;}
    Else
      Result = CanvasGadget(GNum, X, Y, Width, Height)
    EndIf
    
    If Result
      
      If GNum = #PB_Any : GNum = Result : EndIf
      
      X      = dpiX(X)
      Y      = dpiY(Y)
      Width  = dpiX(Width)
      Height = dpiY(Height)
      
      If AddMapElement(TextEx(), Str(GNum))
        
        TextEx()\CanvasNum = GNum
        
  			If WindowNum = #PB_Default
          TextEx()\Window\Num = GetGadgetWindow()
        Else
          TextEx()\Window\Num = WindowNum
        EndIf   
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          If ModuleEx::AddWindow(TextEx()\Window\Num, ModuleEx::#Tabulator)
            ModuleEx::AddGadget(GNum, TextEx()\Window\Num, ModuleEx::#IgnoreTabulator)
          EndIf
        CompilerEndIf
        
        CompilerSelect #PB_Compiler_OS ;{ Font
          CompilerCase #PB_OS_Windows
            TextEx()\FontID = GetGadgetFont(#PB_Default)
          CompilerCase #PB_OS_MacOS
            txtNum = TextGadget(#PB_Any, 0, 0, 0, 0, " ")
            If txtNum
              TextEx()\FontID = GetGadgetFont(txtNum)
              FreeGadget(txtNum)
            EndIf
          CompilerCase #PB_OS_Linux
            TextEx()\FontID = GetGadgetFont(#PB_Default)
        CompilerEndSelect ;}
        
        TextEx()\Size\X = X
        TextEx()\Size\Y = Y
        TextEx()\Size\Width  = Width
        TextEx()\Size\Height = Height
        
        TextEx()\Text = Text
        
        TextEx()\Color\Front        = $000000
        TextEx()\Color\Back         = $EDEDED
        TextEx()\Color\Gradient     = $C0C0C0
        TextEx()\Color\Border       = #PB_Default
        TextEx()\Color\Gadget       = $EDEDED
        TextEx()\Color\DisableFront = $72727D
        TextEx()\Color\DisableBack  = $CCCCCA
        
        CompilerSelect #PB_Compiler_OS ;{ window background color (if possible)
          CompilerCase #PB_OS_Windows
            TextEx()\Color\Front  = GetSysColor_(#COLOR_WINDOWTEXT)
            TextEx()\Color\Back   = GetSysColor_(#COLOR_MENU)
            TextEx()\Color\Gadget = GetSysColor_(#COLOR_MENU)
          CompilerCase #PB_OS_MacOS
            TextEx()\Color\Front  = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor textColor"))
            TextEx()\Color\Back   = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
            TextEx()\Color\Gadget = OSX_NSColorToRGB(CocoaMessage(0, 0, "NSColor windowBackgroundColor"))
          CompilerCase #PB_OS_Linux
            
        CompilerEndSelect ;}
        
        TextEx()\Flags  = Flags
        
        BindGadgetEvent(TextEx()\CanvasNum,  @_ResizeHandler(), #PB_EventType_Resize)
        
        CompilerIf Defined(ModuleEx, #PB_Module)
          BindEvent(#Event_Theme, @_ThemeHandler())
        CompilerEndIf
        
        If Flags & #AutoResize
          If IsWindow(WindowNum)
            TextEx()\Window\Width  = WindowWidth(WindowNum)
            TextEx()\Window\Height = WindowHeight(WindowNum)
            BindEvent(#PB_Event_SizeWindow, @_ResizeWindowHandler(), WindowNum)
          EndIf  
        EndIf
        
        Draw_()
        
      EndIf
      
    EndIf
    
    ProcedureReturn GNum
  EndProcedure 
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Window = 0
  #Text = 1
  #Font = 1
  
  LoadFont(#Font, "Arial", 11, #PB_Font_Bold)
  
  If OpenWindow(#Window, 0, 0, 180, 60, "Example", #PB_Window_SystemMenu | #PB_Window_ScreenCentered | #PB_Window_SizeGadget)
    
    TextEx::Gadget(#Text, 5, 5, 170, 50, "Gradient Background", TextEx::#Center|TextEx::#Border|TextEx::#Gradient|TextEx::#AutoResize|TextEx::#MultiLine, #Window)
 
    TextEx::SetColor(#Text, TextEx::#FrontColor,    $FFFFFF)
    TextEx::SetColor(#Text, TextEx::#BackColor,     $DEC4B0)
    TextEx::SetColor(#Text, TextEx::#GradientColor, $783C0A)
    
    TextEx::SetFont(#Text, FontID(#Font))
    TextEx::SetText(#Text, "Row 1" + #LF$ + "Row 2")
    
    TextEx::AdjustSize(#Text, TextEx::#Width|TextEx::#Height)
    
    
    TextEx::SetAutoResizeFlags(#Text, TextEx::#MoveY|TextEx::#Width)
      
    ;ModuleEx::SetTheme(ModuleEx::#Theme_Dark)
    
    TextEx::SetAttribute(#Text, TextEx::#Corner, 4)
    
    Repeat
      Event = WaitWindowEvent()
    Until Event = #PB_Event_CloseWindow
    
  EndIf
CompilerEndIf