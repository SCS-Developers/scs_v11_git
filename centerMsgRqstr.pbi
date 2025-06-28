; File: centerMsgRqstr.pbi

; Based on code supplied by RASHAD in PB Forum Posting "Control Position And Size of Requesters [Windows]", Sep 10, 2010
; see scsMessageRequester (below) for the condition in which this special code needs to be called

EnableExplicit

Structure tyCenterMsgRqstr
  hwnd.i
  sWindowName.s
  x.i
  y.i
  w.i
  h.i
  flag.i
  Hook.i
EndStructure
Global grCenterMsgRqstr.tyCenterMsgRqstr

Procedure HookTimer(hwnd, uMsg, Event, Time)
  UnhookWindowsHookEx_( grCenterMsgRqstr\Hook )
EndProcedure

Procedure HookCB(uMsg, wParam, lParam)
  
  Select uMsg
    Case #HC_ACTION
      With grCenterMsgRqstr
        \hwnd = FindWindow_(0,\sWindowName)
        Protected r.RECT
        GetWindowRect_(\hwnd,r)
        ExamineDesktops()
        If \w = 0 Or \h = 0
          \w = r\right - r\left
          \h = r\bottom - r\top
        EndIf   
        If \hwnd And \flag = 0
          MoveWindow_(\hwnd,\x,\y,\w,\h,0)
        ElseIf \hwnd And \flag = 1
          \x = (DesktopWidth(0) - \w)/2
          \y = (DesktopHeight(0) - \h)/2     
          MoveWindow_(\hwnd,\x,\y,\w,\h,0)
        EndIf
      EndWith
      
  EndSelect
  
  ProcedureReturn #False
EndProcedure

Procedure scsMessageRequester(sTitle.s, sText.s, nFlags=#PB_MessageRequester_Ok)
  PROCNAMEC()
  Protected Timer, Hook
  Protected nReply, sReply.s
  Protected sMsgTitle.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  If getWindowVisible(#WMI)
    ; the 'information' window may be being displayed if scsMessageRequester() is called during the opening of a cue file, etc (by fmLoadProd)
    debugMsg(sProcName, "calling WMI_Form_Unload()")
    WMI_Form_Unload()
  EndIf
  
  gbInMessageRequester = #True
  
  ; WARNING! If the MessageRequester's title matches that of an existing SCS window title then HookCB (see above) may change the size of the wrong window
  ; This was reported by Eric Snodgrass in June 2016 when changing the Video Playback Library from TVG to DirectShow (in Options), then clicking Apply.
  ; SCS displayed a message (using scsMessageRequester) advising the user that they would have to close and restart SCS for the change to take effect.
  ; But the title of the Message Requester was the same as the title of the Options window. On clicking OK to the Message Requester, the size of the
  ; Options window was immediately reduced to that of the message requester that had just been closed.
  
  ; To avoid problem it is necessary to ensure the message requester title is NOT the same as any SCS window title, and the easiest way to do that is to
  ; add a character to the end of the message requester title. Hence sMsgTitle.s was added. Note - this is only required if TVG secondary screens are in use
  ; as SCS will not call HookCB if there are no such screens created.
  
  THR_suspendMutexLockTimeoutChecks()
  
  debugMsg(sProcName, "sTitle=" + #DQUOTE$ + sTitle + #DQUOTE$ + ", sText=" + #DQUOTE$ + sText + #DQUOTE$)
  
  ; added 13Nov2017 11.7.0ax following email from C.Peters where cursor was locked into the graph area while a message about minimum number of loops was displayed
  If IsGadget(WQF\cvsGraph)
    SetGadgetAttribute(WQF\cvsGraph, #PB_Canvas_Clip, 0)
  EndIf
  ; end added 13Nov2017

  ; "CompilerIf 1=2 / CompilerElse" to revert to normal MessageRequester() processing 24Aug2016 (11.5.2.014) following reports and screenshots from
  ; Martin Stansfield that showed the repositioning using HookCB etc was displaying the dialog to the bottom right of the screen, and partially off-screen.
  ; This occured when Windows rescales and repositions objects for a UHD screen (eg 3000x2000),
  ; Further testing of the the condition with TVG having created a control on the secondary screen no longer(?) positions the standard message requester
  ; dialog on the secondary screen, which therefore makes the work-around unnecessary.
  CompilerIf 1=2
    If grVideoDriver\bTVGControlForSecondaryScreenCreated
      sMsgTitle = sTitle + "."    ; add "." to end of title to (hopefully) ensure the message requester title does not match a window title
      With grCenterMsgRqstr
        \sWindowName = sMsgTitle
        \x = 0      ; default x, y, w and h
        \y = 0
        \w = 0
        \h = 0
        \flag = 1   ; center in desktop(0)
        Timer = SetTimer_(#Null, 0, 1000, @HookTimer())
        Hook = SetWindowsHookEx_ (#WH_FOREGROUNDIDLE, @HookCB(), 0, GetCurrentThreadId_())
        nReply = MessageRequester(sMsgTitle, sText, nFlags)
        KillTimer_(#Null, Timer)
      EndWith
    Else
      nReply = MessageRequester(sTitle, sText, nFlags)
    EndIf
  CompilerElse
    nReply = MessageRequester(sTitle, sText, nFlags)
  CompilerEndIf
  
  gbInMessageRequester = #False
  
  Select nReply
    Case #PB_MessageRequester_Yes
      sReply = "Yes"
    Case #PB_MessageRequester_No
      sReply = "No"
    Case #PB_MessageRequester_Cancel
      sReply = "Cancel"
    Default
      sReply = Str(nReply)
  EndSelect
  
  debugMsg(sProcName, #SCS_END + ", returning " + sReply)
  ProcedureReturn nReply
EndProcedure

; EOF