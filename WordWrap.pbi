; File: WordWrap.pbi

EnableExplicit

; code supplied by LittleJohn in Forum Topic 'WordWrap' (4Mar2013) in "Tricks 'n' Tips (Archive)"
; nb changed procedure name GetTextWidth to wwGetTextWidth to avoid clash with SCS procedure of same name
; also changed procedure name GetTextLen to wwGetTextLen

; v1.01, tested with PB 5.10 on Windows XP x86 (should be cross-platform, though)

Procedure.i wwGetTextWidth (Window.i, gadget.i, Text$)
  ; in : window: window number
  ;      gadget: gadget number
  ;      text$ : This function does not require that the text is
  ;              actually shown in the gadget.
  ; out: width of text$ in pixels
  Protected Width.i=-1
  
  If StartDrawing(WindowOutput(Window))
      DrawingFont(GetGadgetFont(gadget))
      Width = TextWidth(Text$)
    StopDrawing()
  EndIf
  
  ProcedureReturn Width  ; -1 on error
EndProcedure

Procedure.i wwGetTextLen (Window.i, gadget.i, Text$, Width.i)
  ; in : window: window number
  ;      gadget: gadget number
  ;      width : available width in pixels
  ;      text$ : This function does not require that the text is
  ;              actually shown in the gadget.
  ; out: maximum number of characters of text$ (counted from the left)
  ;      which fit into the available width
  Protected length.i=-1
  
  If StartDrawing(WindowOutput(Window))
      DrawingFont(GetGadgetFont(gadget))
      length = Len(Text$)
      While length > 0 And TextWidth(Left(Text$, length)) > Width
        length - 1
      Wend
    StopDrawing()
  EndIf
  
  ProcedureReturn length  ; -1 on error
EndProcedure


Procedure.s LineWrapW (Window.i, gadget.i, line$, softWrapWidth.i, hardWrapWidth.i=-1, delimList$=" "+Chr(9), nl$=#LF$, indent$="")
  ; -- Word wrap in *one line* in a window (can have a variable-width font)
  ; in: line$  : line which is to be wrapped
  ;     indent$: "" or a string consisting of blanks, used for indenting lines of list items
  ;
  ;     For the meaning of the other parameters see function WordWrapW().
  Protected.i posn, found, i, softWrapPosn, hardWrapPosn, firstChar=Len(indent$)+1
  Protected ret$=""
  
  softWrapPosn = wwGetTextLen(Window, gadget, line$, softWrapWidth)
  If softWrapPosn < firstChar
    ProcedureReturn line$
  EndIf
  
  posn = Len(line$)
  While posn > softWrapPosn
    ; search for rightmost delimiter <= softWrapPosn:
    For i = softWrapPosn To firstChar Step -1
      found = FindString(delimList$, Mid(line$,i,1))
      If found
        posn = i
        Break
      EndIf
    Next
    
    If found = 0    ; if there is no delimiter <= softWrapPosn
      If hardWrapWidth < 0
        ; insert hard wrap at position of soft wrap:
        posn = softWrapPosn
      Else
        ; search for leftmost delimiter > softWrapPosn:
        For i = softWrapPosn+1 To posn
          found = FindString(delimList$, Mid(line$,i,1))
          If found
            posn = i
            Break
          EndIf
        Next
        If hardWrapWidth > 0
          hardWrapPosn = wwGetTextLen(Window, gadget, line$, hardWrapWidth)
          If hardWrapPosn < posn
            ; insert hard wrap at given position:
            posn = hardWrapPosn
          EndIf
        EndIf
      EndIf
    EndIf
    
    ret$ + RTrim(Left(line$, posn)) + nl$
    line$ = LTrim(Mid(line$, posn+1))
    If line$ <> ""
      line$ = indent$ + line$
    EndIf
    
    softWrapPosn = wwGetTextLen(Window, gadget, line$, softWrapWidth)
    posn = Len(line$)
  Wend
  
  ProcedureReturn ret$ + line$
EndProcedure


Procedure.s WordWrapW (Window.i, gadget.i, Text$, softWrapWidth.i, hardWrapWidth.i=-1, delimList$=" "+Chr(9), nl$=#LF$, liStart$="")
  ; ## Main function ##
  ; -- Word wrap in *one or more lines* in a window (can have a variable-width font)
  ; in : window       : window number
  ;      gadget       : gadget number
  ;      text$        : text which is to be wrapped;
  ;                     may contain #CRLF$ (Windows), or #LF$ (Linux and modern Mac systems) as line breaks
  ;      softWrapWidth: the desired maximum width (pixels) of each resulting line
  ;                     if a delimiter was found (not counting the length of the inserted nl$);
  ;                     if no delimiter was found at a position <= softWrapWidth, a line might
  ;                     still be longer if hardWrapWidth = 0 or > softWrapWidth
  ;      hardWrapWidth: guaranteed maximum width (pixels) of each resulting line
  ;                     (not counting the length of the inserted nl$);
  ;                     if hardWrapWidth <> 0, each line will be wrapped at the latest at
  ;                     hardWrapWidth, even if it doesn't contain a delimiter;
  ;                     default setting: hardWrapWidth = softWrapWidth
  ;      delimList$   : list of characters which are used as delimiters;
  ;                     any delimiter in line$ denotes a position where a soft wrap is allowed
  ;      nl$          : string to be used as line break (normally #CRLF$ or #LF$)
  ;      liStart$     : string at the beginning of each list item
  ;                     (providing this information makes proper indentation possible)
  ;
  ; out: return value : text$ with given nl$ inserted at appropriate positions
  ;
  ; <http://www.purebasic.fr/english/viewtopic.php?f=12&t=53800>
  Protected.i numLines, i, indentPixels, indentLen=-1
  Protected line$, indent$, ret$=""
  
  numLines = CountString(Text$, #LF$) + 1
  For i = 1 To numLines
    line$ = RTrim(StringField(Text$, i, #LF$), #CR$)
    
    If FindString(line$, liStart$) = 1
      If indentLen = -1
        indentPixels = wwGetTextWidth(Window, gadget, liStart$)
        indentLen = wwGetTextLen(Window, gadget, Space(Len(Text$)), indentPixels)
      EndIf
      indent$ = Space(indentLen)
    Else
      indent$ = ""
    EndIf
    
    ret$ + LineWrapW(Window, gadget, line$, softWrapWidth, hardWrapWidth, delimList$, nl$, indent$)
    If i < numLines
      ret$ + nl$
    EndIf
  Next
  
  ProcedureReturn ret$
EndProcedure
