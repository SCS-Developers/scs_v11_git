; File: MIDI.pbi

EnableExplicit

Global gnWinmmLibrary
Global *gmMidiOutShortMsg

Procedure openWinmm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsLibrary(gnWinmmLibrary) = #False
    gnWinmmLibrary = OpenLibrary(#PB_Any, "Winmm.dll")
    If gnWinmmLibrary
      *gmMidiOutShortMsg = GetFunction(gnWinmmLibrary, "midiOutShortMsg")
      If *gmMidiOutShortMsg = 0
        debugMsg(sProcName, "GetFunction(gnWinmmLibrary, " + #DQUOTE$ + "midiOutShortMsg" + #DQUOTE$ + ") returned 0")
      Else
        ; debugMsg(sProcName, "*gmMidiOutShortMsg=" + *gmMidiOutShortMsg)
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeWinmm()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  If IsLibrary(gnWinmmLibrary)
    CloseLibrary(gnWinmmLibrary)
  EndIf
  gnWinmmLibrary = 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure checkGoConfirmReqdAndSet()
  PROCNAMEC()
  Protected i, sMsg.s
  Protected n
  Protected bGoConfirmFound

  For n = 0 To (gnNumMidiInDevs-1)
    If gaMidiInDevice(n)\bCueControl
      If gaMidiControl(n)\aMidiCommand[#SCS_MIDI_GO_CONFIRM]\nCmd >= 0
        bGoConfirmFound = #True
        Break
      EndIf
    EndIf
  Next n
  
  If bGoConfirmFound
    ProcedureReturn
  EndIf
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      If aCue(i)\nActivationMethod = #SCS_ACMETH_MAN_PLUS_CONF
        sMsg = LangPars("Errors", "NoGoConfMan", getCueLabel(i))
        Break
      ElseIf aCue(i)\nActivationMethod = #SCS_ACMETH_AUTO_PLUS_CONF
        sMsg = LangPars("Errors", "NoGoConfAuto", getCueLabel(i))
        Break
      EndIf
    EndIf
  Next i
  
  If Len(sMsg) > 0
    displayMidiWarning(sMsg)
  EndIf
  
EndProcedure

Procedure closeMidiPorts()
  PROCNAMEC()
  Protected nMidiOutPhysicalDevPtr, nMidiInPhysicalDevPtr
  Protected nThreadState
  
  debugMsg(sProcName, #SCS_START)
  
  For nMidiOutPhysicalDevPtr = 0 To (gnNumMidiOutDevs-1)
    With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
      If \hMidiOut
        If (\bThruPort) And (\nMidiThruInPhysicalDevPtr >= 0)
          MidiThru_Port("disconnect", \nMidiThruInPhysicalDevPtr, nMidiOutPhysicalDevPtr)
        EndIf
        MidiOut_Port("close", nMidiOutPhysicalDevPtr, "all")
      EndIf
      \bInitialized = #False
    EndWith
  Next nMidiOutPhysicalDevPtr
  
  For nMidiInPhysicalDevPtr = 0 To (gnNumMidiInDevs-1)
    With gaMidiInDevice(nMidiInPhysicalDevPtr)
      If \hMidiIn
        debugMsg(sProcName, "calling MidiIn_Port('close', " + nMidiInPhysicalDevPtr + ", 'all')")
        MidiIn_Port("close", nMidiInPhysicalDevPtr, "all")
      EndIf
      \bInitialized = #False
    EndWith
  Next nMidiInPhysicalDevPtr
  
  If *gMidiInData
    FreeMemory(*gMidiInData)
    *gMidiInData = 0
  EndIf
  
  With grMTCSendControl
    If \hMTCMidiOut
      nThreadState = THR_getThreadState(#SCS_THREAD_MTC_CUES)
      If nThreadState > #SCS_THREAD_STATE_NOT_CREATED
        \nMTCThreadRequest | #SCS_MTC_THR_CLOSE_MIDI
        debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
        If nThreadState <> #SCS_THREAD_STATE_ACTIVE
          ; need to resume thread so the 'close' request can be processed
          debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)")
          THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)
        EndIf
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeAndReopenMidiOutPort(nMidiOutPhysicalDevPtr)
  PROCNAMEC()
  Protected nMidiError.l ; long

  With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
    If \hMidiOut <> 0
      ; close the port
      nMidiError = midiOutClose_(\hMidiOut)
      debugMsg2(sProcName, "midiOutClose_(" + \hMidiOut + ")", nMidiError)
      ; don't check for an error as this procedure may be called after a MIDI send failure, so another 'error' is quite likely
      \hMidiOut = 0
      \bInitialized = #False
      ; reopen the port
      nMidiError = midiOutOpen_(@\hMidiOut, \nMidiDeviceID, 0, 0, #CALLBACK_NULL)
      debugMsg2(sProcName, "midiOutOpen_(@\hMidiOut, " + \nMidiDeviceID + ", 0, 0, CALLBACK_NULL)", nMidiError)
      If nMidiError = #MMSYSERR_NOERROR
        debugMsg3(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\hMidiOut=" + \hMidiOut)
        \bInitialized = #True
      EndIf
    EndIf
    \bInitialized = #False
  EndWith
  
EndProcedure

Procedure getMidiInPhysicalDevPtr(sName.s, bDummy)
  ; PROCNAMEC()
  Protected n, nPhysicalDevPtr

  nPhysicalDevPtr = -1
  If sName Or bDummy
    For n = 0 To gnNumMidiInDevs - 1
      If (bDummy And gaMidiInDevice(n)\bDummy) Or (gaMidiInDevice(n)\sName = sName)
        nPhysicalDevPtr = n
        Break
      EndIf
    Next
  EndIf
  ProcedureReturn nPhysicalDevPtr

EndProcedure

Procedure getMidiOutPhysicalDevPtr(sName.s, bDummy)
  ; PROCNAMEC()
  Protected n, nPhysicalDevPtr

  ; debugMsg(sProcName, #SCS_START + ", sName=" + sName + ", bDummy=" + strB(bDummy))
  
  nPhysicalDevPtr = -1
  If sName Or bDummy
    ; debugMsg(sProcName, "gnNumMidiOutDevs=" + gnNumMidiOutDevs)
    For n = 0 To (gnNumMidiOutDevs - 1)
      ; debugMsg(sProcName, "gaMidiOutDevice(" + n + ")\sName=" + gaMidiOutDevice(n)\sName + ", \bDummy=" + strB(gaMidiOutDevice(n)\bDummy))
      If (bDummy And gaMidiOutDevice(n)\bDummy) Or (gaMidiOutDevice(n)\sName = sName)
        nPhysicalDevPtr = n
        Break
      EndIf
    Next
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nPhysicalDevPtr)
  ProcedureReturn nPhysicalDevPtr

EndProcedure

Procedure.s getMidiCueFromSCSCue(psCue.s, psMethod.s)
  ; derive MSC cue from SCS cue,
  ;   eg 1.2 from FX 1.2 if method is MSC
  ;      1   from FX 1.2 if method is CTRL or NOTE
  Protected sMidiCue.s, sChar.s, sCue.s
  Protected sValidChars.s
  Protected n

  If (psMethod = "MSC")
    sValidChars = "0123456789.," ; added ',' 16Aug2019 11.8.2ad following forum posting from 'allcomp' regarding LightFactory not accepting '.' but accepting ','
  Else
    sValidChars = "0123456789"
  EndIf

  sCue = Trim(psCue)  ; mainly to remove any trailing space
  sMidiCue = ""
  For n = 1 To Len(sCue)
    sChar = Mid(sCue, n, 1)
    If InStr(sValidChars, sChar) > 0
      sMidiCue = sMidiCue + sChar
    ElseIf Len(sMidiCue) > 0
      ; if non-numeric after numerics then no good
      sMidiCue = ""
      Break
    EndIf
  Next n

  If psMethod = "Note"
    If Val(sMidiCue) > 127
      sMidiCue = ""
    EndIf
  EndIf

  ; return MIDI Cue
  ProcedureReturn sMidiCue
EndProcedure

Procedure getMidiCuePtr(sMidiCue.s)
  PROCNAMEC()
  Protected i, nCuePtr
  
  nCuePtr = -1
  For i = 1 To gnLastCue
    If aCue(i)\sMidiCue = sMidiCue And aCue(i)\bCueEnabled
      nCuePtr = i
      Break
    EndIf
  Next i
  ProcedureReturn nCuePtr
EndProcedure

Procedure.s getMidiInfo()
  PROCNAMEC()
  Protected sInfo.s, sHex.s
  Protected n

  For n = 0 To (gnNumMidiInDevs-1)
    If gaMidiInDevice(n)\bCueControl
      With gaMidiControl(n)
        If Len(sInfo) = 0
          sInfo = "MIDI Control Enabled."
        EndIf
        sInfo + " Cue Control Method: "
        Select \nCtrlMethod
          Case #SCS_CTRLMETHOD_NONE
            ; no action
            
          Case #SCS_CTRLMETHOD_MTC
            sInfo = Lang("Ctrl", "MTC") + ", "
            
          Case #SCS_CTRLMETHOD_MSC
;             sInfo + "MIDI Show Control (MSC), "
            sInfo = Lang("Ctrl", "MSC") + ", "
            sHex = Right("0" + Hex(\nMscMmcMidiDevId), 2)
            sInfo + "Device ID: " + sHex + "H, "
            sHex = Right("0" + Hex(\nMscCommandFormat), 2)
            sInfo + "Command Format: " + sHex + "H, "
            If \nGoMacro >= 0
              sHex = Right("0" + Hex(\nGoMacro), 2)
              sInfo + "Go Macro: " + sHex + "H"
            EndIf
            
          Case #SCS_CTRLMETHOD_MMC
;             sInfo + "MIDI Machine Control (MMC), "
            sInfo = Lang("Ctrl", "MMC") + ", "
            sHex = Right("0" + Hex(\nMscMmcMidiDevId), 2)
            sInfo + "Device ID: " + sHex + "H"
            
          Default
            sInfo + decodeCtrlMethodL(\nCtrlMethod) + ", "
            sInfo + "Channel: " + \nMidiChannel
            
        EndSelect
      EndWith
    EndIf
  Next n
  ProcedureReturn sInfo
EndProcedure

Procedure.s midiCCAbbrForCmd(nCmd, nCmdNo)
  PROCNAMEC()
  Protected sCCAbbr.s

  Select nCmd
    Case $8, $9             ; note off, note on
      sCCAbbr = "kk"
    Case $B                 ; control change
      If nCmdNo <= #SCS_MIDI_LAST_SCS_CUE_RELATED
        sCCAbbr = "cc"
      Else
        Select nCmdNo
          Case #SCS_MIDI_MASTER_FADER, #SCS_MIDI_OPEN_FAV_FILE, #SCS_MIDI_SET_HOTKEY_BANK,
               #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER,
               #SCS_MIDI_DMX_MASTER, #SCS_MIDI_CUE_MARKER_PREV, #SCS_MIDI_CUE_MARKER_NEXT
            sCCAbbr = "cc"
          Default
            sCCAbbr = "cc/vv"
        EndSelect
      EndIf
    Case $A                 ; key pressure
      sCCAbbr = "kk/vv"
    Case $C                 ; program change
      sCCAbbr = "pp"
    Case $D                 ; channel pressure
      sCCAbbr = "vv"
    Case $E                 ; pitch bend
      sCCAbbr = "lsb"
  EndSelect
  ProcedureReturn sCCAbbr
EndProcedure

Procedure.s midiCCDescrForCmd(nCmd)
  PROCNAMEC()
  Protected sCCDescr.s
  
  Select nCmd
    Case $8, $9, $A      ; note off, note on, key pressure
      sCCDescr = "Key number"
    Case $B                ; control change
      sCCDescr = "Controller number"
    Case $C                ; program change
      sCCDescr = "Program number"
    Case $D                ; channel pressure
      sCCDescr = "Channel pressure value"
    Case $E                ; pitch bend
      sCCDescr = "Least significant byte"
  EndSelect
  ProcedureReturn sCCDescr
EndProcedure

Procedure.s midiVVAbbrForCmd(nCmd)
  PROCNAMEC()
  Protected sVVAbbr.s
  
  Select nCmd
    Case $8, $9           ; note off, note on
      sVVAbbr = "vv"      ;   velocity
    Case $A               ; key pressure
      sVVAbbr = "vv"      ;   key pressure value
    Case $B               ; control change
      sVVAbbr = "vv"      ;   controller value
    Case $C               ; program change
      sVVAbbr = ""
    Case $D               ; channel pressure
      sVVAbbr = "vv"      ;   channel pressure value
    Case $E               ; pitch bend
      sVVAbbr = "msb"     ;   most significant byte
  EndSelect
  ProcedureReturn sVVAbbr
EndProcedure

Procedure.s midiVVDescrForCmd(nCmd)
  PROCNAMEC()
  Protected sVVDescr.s
  
  Select nCmd
    Case $8, $9           ; note off, note on
      sVVDescr = "Velocity"
    Case $A               ; key pressure
      sVVDescr = "Key pressure value"
    Case $B               ; control change
      sVVDescr = "Controller value (* = any value)"
    Case $C               ; program change
      sVVDescr = ""
    Case $D               ; channel pressure
      sVVDescr = "Channel pressure value"
    Case $E               ; pitch bend
      sVVDescr = "Most significant byte"
  EndSelect
  ProcedureReturn sVVDescr
EndProcedure

Procedure.s midiCmdDescrForCmdNo(nCmdNo, nCueSet=0, sMidiCue.s="", nCtrlMethod=0, nCmd=0, nCC=-1, nVV=-1)
  PROCNAMEC()
  Protected sCmdDescr.s, sRange.s
  Protected nMyCueSet
  Protected nFavFileNo, nAudNo, bUseDevChgs, sLogicalDev.s, sFixtureCode.s, nFixNo

;   debugMsg(sProcName, #SCS_START + ", nCmdNo=" + nCmdNo + ", nCueSet=" + nCueSet + ", sMidiCue=" + sMidiCue + ", nCtrlMethod=" + decodeCtrlMethod(nCtrlMethod) + ", nCmd=" + nCmd + ", nCC=" + nCC + ", nVV=" + nVV)

  nMyCueSet = nCueSet

  Select nCtrlMethod
    Case #SCS_CTRLMETHOD_ETC_AB
      If (nCmdNo = #SCS_MIDI_PLAY_CUE) And (nCmd = $B)
        nMyCueSet = nCC - 69
      Else
        nMyCueSet = 0
      EndIf
    Case #SCS_CTRLMETHOD_ETC_CD
      If nCmdNo = #SCS_MIDI_PLAY_CUE
        nMyCueSet = nCC - 77
      Else
        nMyCueSet = 0
      EndIf
  EndSelect

  Select nMyCueSet
    Case -1
      sRange = " " + sMidiCue
    Case 0
      sRange = " 1-127"
    Case 1
      sRange = " 128-255"
    Case 2
      sRange = " 256-383"
    Case 3
      sRange = " 384-511"
    Case 4
      sRange = " 512-639"
    Case 5
      sRange = " 640-767"
    Case 6
      sRange = " 768-895"
    Case 7
      sRange = " 896-999"
  EndSelect

  Select nCmdNo
    Case #SCS_MIDI_PLAY_CUE
      sCmdDescr = "Play Cue" + sRange
    Case #SCS_MIDI_PAUSE_RESUME_CUE
      sCmdDescr = "Pause/Resume Cue" + sRange
    Case #SCS_MIDI_RELEASE_CUE
      sCmdDescr = "Release Loop Cue" + sRange
    Case #SCS_MIDI_FADE_OUT_CUE
      sCmdDescr = "Fade Out Cue" + sRange
    Case #SCS_MIDI_STOP_CUE
      sCmdDescr = "Stop Cue" + sRange
    Case #SCS_MIDI_GO_TO_CUE
      sCmdDescr = "Go To Cue" + sRange
    Case #SCS_MIDI_LOAD_CUE
      sCmdDescr = "Load Cue" + sRange
    Case #SCS_MIDI_UNLOAD_CUE
      sCmdDescr = "Unload Cue" + sRange
    Case #SCS_MIDI_GO_BUTTON
      sCmdDescr = Lang("Remote", "GoButton") ; "'Go' Button"
    Case #SCS_MIDI_STOP_ALL
      sCmdDescr = "Stop Everything"
    Case #SCS_MIDI_FADE_ALL ; 7May2022 11.9.1
      sCmdDescr = "Fade All"
    Case #SCS_MIDI_PAUSE_RESUME_ALL
      sCmdDescr = "Pause/Resume All"
    Case #SCS_MIDI_GO_TO_TOP
      sCmdDescr = "Go To Top"
    Case #SCS_MIDI_GO_BACK
      sCmdDescr = "Go Back"
    Case #SCS_MIDI_GO_TO_NEXT
      sCmdDescr = "Go To Next"
    Case #SCS_MIDI_PAGE_UP
      sCmdDescr = "Page Up"
    Case #SCS_MIDI_PAGE_DOWN
      sCmdDescr = "Page Down"
    Case #SCS_MIDI_MASTER_FADER
      sCmdDescr = "Master Fader"
    Case #SCS_MIDI_GO_CONFIRM
      sCmdDescr = "Go Confirm"
    Case #SCS_MIDI_OPEN_FAV_FILE
      If (nVV >= 1) And (nVV <= 20)
        sCmdDescr = "Open Fav. File #" + Str(nVV)
      Else
        sCmdDescr = "Open Fav. File #1-#20"
      EndIf
    Case #SCS_MIDI_SET_HOTKEY_BANK
      If (nVV >= 0) And (nVV <= 12)
        sCmdDescr = "Set Hotkey Bank " + Str(nVV)
      Else
        sCmdDescr = "Set Hotkey Bank 0-12"
      EndIf
    Case #SCS_MIDI_TAP_DELAY
      sCmdDescr = "Tap Delay"
    Case #SCS_MIDI_EXT_FADER
      sCmdDescr = "External Fader"
    Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER
      nAudNo = nCmdNo - #SCS_MIDI_DEVICE_1_FADER
      If IsGadget(WEP\btnApplyDevChgs)
        If getEnabled(WEP\btnApplyDevChgs)
          bUseDevChgs = #True
        EndIf
      EndIf
      sLogicalDev = ""
      If bUseDevChgs
        If nAudNo <= grProdForDevChgs\nMaxAudioLogicalDev
          sLogicalDev = grProdForDevChgs\aAudioLogicalDevs(nAudNo)\sLogicalDev
        EndIf
      Else
        If nAudNo <= grProd\nMaxAudioLogicalDev
          sLogicalDev = grProd\aAudioLogicalDevs(nAudNo)\sLogicalDev
        EndIf
      EndIf
      If sLogicalDev
        sCmdDescr = sLogicalDev + " Fader"
      Else
        sCmdDescr = Str(nCmdNo)
      EndIf
    Case #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER
      ; Added 29Apr2025 11.10.8bb
      nFixNo = nCmdNo - #SCS_MIDI_DIMMER_1_FADER
      sFixtureCode = WCN_getDimmerIndexFixtureCode(nFixNo)
      If sFixtureCode
        sCmdDescr = sFixtureCode + " Dimmer"
      Else
        sCmdDescr = Str(nFixNo)
      EndIf
    Case #SCS_MIDI_DMX_MASTER
      sCmdDescr = "DMX Master"
    Case #SCS_MIDI_CUE_MARKER_PREV  ; 3May2022 11.9.1
      sCmdDescr = "Prev Cue Marker"
    Case #SCS_MIDI_CUE_MARKER_NEXT  ; 3May2022 11.9.1
      sCmdDescr = "Next Cue Marker"
    Case -1
      sCmdDescr = ""
    Default
      sCmdDescr = Str(nCmdNo)
  EndSelect
  ProcedureReturn Trim(sCmdDescr)
EndProcedure

Procedure loadArrayMidiDevs()
  PROCNAMEC()
  Protected d, n
  Protected sMsg.s
  
  ; debugMsg(sProcName, #SCS_START + ", gnNumMidiInDevs=" + gnNumMidiInDevs + ", gnNumMidiOutDevs=" + gnNumMidiOutDevs + ", gnMaxConnectedDev=" + gnMaxConnectedDev)
  
  ; midi in devices (for midi control)
  debugMsg(sProcName, "MIDI In Devices")
  ReDim gaMidiInDevice(gnNumMidiInDevs)
  ReDim gaMidiInHdr(gnNumMidiInDevs)
  ReDim gaMidiControl(gnNumMidiInDevs)
  d = -1
  For n = 0 To gnMaxConnectedDev
    CheckSubInRange(n, ArraySize(gaConnectedDev()), "gaConnectedDev()")
    ; debugMsg(sProcName, "gaConnectedDev(" + n + ")\nDevType=" + decodeDevType(gaConnectedDev(n)\nDevType))
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
      ; debugMsg(sProcName, "gaConnectedDev(" + n + ")\nDevType=" + decodeDevType(gaConnectedDev(n)\nDevType))
      d + 1
      CheckSubInRange(d, ArraySize(gaMidiInDevice()), "gaMidiInDevice()")
      gaMidiInDevice(d) = grMidiDeviceDef
      CheckSubInRange(d, ArraySize(gaMidiControl()), "gaMidiControl()")
      gaMidiControl(d) = grMidiControlDef
      With gaMidiInDevice(d)
        \nMidiDeviceID = gaConnectedDev(n)\nMidiDeviceID
        \sName = gaConnectedDev(n)\sPhysicalDevDesc
        \bDummy = gaConnectedDev(n)\bDummy
        \bWindowsMidiCompatible = gaConnectedDev(n)\bWindowsMidiCompatible
        \bEnttecMidi = gaConnectedDev(n)\bEnttecMidi
        ; debugMsg(sProcName, "gaMidiInDevice(" + d + ")\bEnttecMidi=" + strB(\bEnttecMidi))
        ; the following for Enttec devices with Midi support (ie \bEnttecMidi = #True)
        ; \nDevice = gaConnectedDev(n)\nDevice  ; if \bEnttecMidi then \nDevice will be passed to DMX_FTDI_OpenDevice()
        \sDMXName = gaConnectedDev(n)\sPhysicalDevDesc
        \sDMXSerial = gaConnectedDev(n)\sSerial
        \nDMXSerial = gaConnectedDev(n)\nSerial
        \nDMXDevPtr = gaConnectedDev(n)\nDevice
        sMsg = "gaMidiInDevice(" + d + ")\nMidiDeviceID=" + \nMidiDeviceID + ", \sName="  + #DQUOTE$ + \sName + #DQUOTE$
        If \bDummy
          sMsg + ", \bDummy=" + strB(\bDummy)
        EndIf
        If \bEnttecMidi
          sMsg + ", \bEnttecMidi=" + strB(\bEnttecMidi) + ", \sDMXName=" + \sDMXName + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXSerial=" + \nDMXSerial + ", \nDMXDevPtr=" + \nDMXDevPtr
        EndIf
        debugMsg(sProcName, sMsg)
      EndWith
    EndIf
  Next n
  
  ; midi out devices (for control send)
  debugMsg(sProcName, "MIDI Out Devices")
  ReDim gaMidiOutDevice(gnNumMidiOutDevs)
  ReDim gaMidiOutHdr(gnNumMidiOutDevs)
  d = -1
  For n = 0 To gnMaxConnectedDev
    CheckSubInRange(n, ArraySize(gaConnectedDev()), "gaConnectedDev()")
    ; debugMsg(sProcName, "gaConnectedDev(" + n + ")\nDevType=" + decodeDevType(gaConnectedDev(n)\nDevType))
    Select gaConnectedDev(n)\nDevType
      Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
        ; debugMsg(sProcName, "gaConnectedDev(" + n + ")\nDevType=" + decodeDevType(gaConnectedDev(n)\nDevType))
        d + 1
        CheckSubInRange(d, ArraySize(gaMidiOutDevice()), "gaMidiOutDevice()")
        gaMidiOutDevice(d) = grMidiDeviceDef
        With gaMidiOutDevice(d)
          \nMidiDeviceID = gaConnectedDev(n)\nMidiDeviceID
          \sName = gaConnectedDev(n)\sPhysicalDevDesc
          \bDummy = gaConnectedDev(n)\bDummy
          \bIgnoreDev = gaConnectedDev(n)\bIgnoreDev
          \bWindowsMidiCompatible = gaConnectedDev(n)\bWindowsMidiCompatible
          \bEnttecMidi = gaConnectedDev(n)\bEnttecMidi
          ; debugMsg(sProcName, "gaMidiOutDevice(" + d + ")\bEnttecMidi=" + strB(\bEnttecMidi))
          ; the following for Enttec devices with Midi support (ie \bEnttecMidi = #True)
          ; \nDevice = gaConnectedDev(n)\nDevice  ; if \bEnttecMidi then \nDevice will be passed to DMX_FTDI_OpenDevice()
          \sDMXName = gaConnectedDev(n)\sPhysicalDevDesc
          \sDMXSerial = gaConnectedDev(n)\sSerial
          \nDMXSerial = gaConnectedDev(n)\nSerial
          \nDMXDevPtr = gaConnectedDev(n)\nDevice
          sMsg = "gaMidiOutDevice(" + d + ")\nMidiDeviceID=" + \nMidiDeviceID + ", \sName="  + #DQUOTE$ + \sName + #DQUOTE$
          If \bDummy
            sMsg + ", \bDummy=" + strB(\bDummy)
          EndIf
          If \bIgnoreDev
            sMsg + ", \bIgnoreDev=" + strB(\bIgnoreDev)
          EndIf
          If \bEnttecMidi
            sMsg + ", \bEnttecMidi=" + strB(\bEnttecMidi) + ", \sDMXName=" + \sDMXName + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXSerial=" + \nDMXSerial + ", \nDMXDevPtr=" + \nDMXDevPtr
          EndIf
          debugMsg(sProcName, sMsg)
        EndWith
    EndSelect
  Next n
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure initMidiControl()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  With grMidiControlDef
    \nCtrlMethod = 0
    \nMidiChannel = 0
    \nGoMacro = -1
    For n = 0 To (#SCS_MAX_MIDI_COMMAND)
      \aMidiCommand[n]\nCmd = -1
      \aMidiCommand[n]\nCC = -1
      \aMidiCommand[n]\nVV = -1
      \aMidiCommand[n]\bModifiable = #True
    Next n
  EndWith
  
  ; MSC general commands
  gaMSCSoundCommand($0) = "reserved"
  gaMSCSoundCommand($1) = "GO"
  gaMSCSoundCommand($2) = "STOP"
  gaMSCSoundCommand($3) = "RESUME"
  gaMSCSoundCommand($4) = "TIMED_GO"
  gaMSCSoundCommand($5) = "LOAD"
  gaMSCSoundCommand($6) = "SET"
  gaMSCSoundCommand($7) = "FIRE"
  gaMSCSoundCommand($8) = "ALL_OFF"
  gaMSCSoundCommand($9) = "RESTORE"
  gaMSCSoundCommand($A) = "RESET"
  gaMSCSoundCommand($B) = "GO_OFF"
  ; MSC sound commands
  gaMSCSoundCommand($10) = "GO/JAM_CLOCK"
  gaMSCSoundCommand($11) = "STANDBY_+"
  gaMSCSoundCommand($12) = "STANDBY_-"
  gaMSCSoundCommand($13) = "SEQUENCE_+"
  gaMSCSoundCommand($14) = "SEQUENCE_-"
  gaMSCSoundCommand($15) = "START_CLOCK"
  gaMSCSoundCommand($16) = "STOP_CLOCK"
  gaMSCSoundCommand($17) = "ZERO_CLOCK"
  gaMSCSoundCommand($18) = "SET_CLOCK"
  gaMSCSoundCommand($19) = "MTC_CHASE_ON"
  gaMSCSoundCommand($1A) = "MTC_CHASE_OFF"
  gaMSCSoundCommand($1B) = "OPEN_SCS_CUE_LIST"
  gaMSCSoundCommand($1C) = "CLOSE_SCS_CUE_LIST"
  gaMSCSoundCommand($1D) = "OPEN_SCS_CUE_PATH"
  gaMSCSoundCommand($1E) = "CLOSE_SCS_CUE_PATH"
  
  ; MMC Commands
  gaMMCCommand($01) = "Stop"
  gaMMCCommand($02) = "Play"
  gaMMCCommand($03) = "Deferred Play"
  gaMMCCommand($04) = "Fast Forward"
  gaMMCCommand($05) = "Rewind"
  gaMMCCommand($06) = "Record Strobe (Punch In)"
  gaMMCCommand($07) = "Record Exit (Punch Out)"
  gaMMCCommand($08) = "Record Ready (Record Pause)"
  gaMMCCommand($09) = "Pause"
  gaMMCCommand($0A) = "Eject"
  gaMMCCommand($0B) = "Chase"
  gaMMCCommand($0D) = "MMC Reset"
  gaMMCCommand($40) = "Write"
  gaMMCCommand($44) = "Locate/Go To"
  gaMMCCommand($47) = "Shuttle"
  
  debugMsg(sProcName, "calling openWinmm()")
  openWinmm()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure MidiIn_Port(sOpenClose.s, nPhysicalDevPtr, sReason.s, bForceClose=#False)
  PROCNAME("MidiIn_Port(" + sOpenClose + ")")
  Protected nMidiError.l   ; long
  Protected ct, ret.w
  Protected midiDevID
  Protected length = #SCS_MIDI_IN_BUFFER_LEN
  
  ; debugMsg0(sProcName, #SCS_START + ", " + sOpenClose + " nPhysicalDevPtr=" + nPhysicalDevPtr + ", sReason=" + sReason)
  
  If *gMidiInData = 0
    *gMidiInData = AllocateMemory(length)
  EndIf
  
  If *gMidiInData
    For ct = 0 To length - 1
      PokeA(*gMidiInData+ct, 0) ; c++ end of string char
    Next ct
  EndIf
  
  If nPhysicalDevPtr >= 0
    
    With gaMidiInHdr(nPhysicalDevPtr)
      \lpData = *gMidiInData
      \dwBufferLength = length
      \dwBytesRecorded = 0  ; Length - 1 ' Was Length - only used for MIDI in
      \dwUser = 0
      \dwFlags = 0
    EndWith
    
    With gaMidiInDevice(nPhysicalDevPtr)
      
      If sOpenClose = "open"  ; "open"
        
        If \hMidiIn = 0
          ; port not currently open
          nMidiError = midiInOpen_(@\hMidiIn, \nMidiDeviceID, @MidiIn_Proc(), nPhysicalDevPtr, #CALLBACK_FUNCTION|#MIDI_IO_STATUS)  ; place nPhysicalDevPtr in 'instance data' parameter for callback
          debugMsg2(sProcName, "midiInOpen_(@\hMidiIn, " + \nMidiDeviceID + ", @MidiIn_Proc(), " + nPhysicalDevPtr + ", #CALLBACK_FUNCTION|#MIDI_IO_STATUS)", nMidiError)
          If nMidiError = #MMSYSERR_NOERROR
            debugMsg3(sProcName, "gaMidiInDevice(" + nPhysicalDevPtr + ")\hMidiIn=" + \hMidiIn)
            \bInitialized = #True
          Else
            ShowMMErr(sProcName, "midiInOpen_(@\hMidiIn, " + \nMidiDeviceID + ", @MidiIn_Proc(), " + nPhysicalDevPtr + ", #CALLBACK_FUNCTION|#MIDI_IO_STATUS)", nMidiError)
            \bInitialized = #False
            \hMidiIn = 0
            ProcedureReturn #False
          EndIf
          
          ; prepare a buffer for MIDI input
          nMidiError = midiInPrepareHeader_(\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInPrepareHeader_(" + \hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInPrepareHeader_(" + \hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
            ProcedureReturn #False
          EndIf
          
          ; send an input buffer to midi input dev (This function is used for system-exclusive messages.)
          nMidiError = midiInAddBuffer_(\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInAddBuffer_(" + \hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInAddBuffer_(" + \hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
            ProcedureReturn #False
          EndIf
          
          nMidiError = midiInStart_(\hMidiIn)
          debugMsg2(sProcName, "midiInStart_(" + \hMidiIn + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInStart_(" + \hMidiIn + ")", nMidiError)
            ProcedureReturn #False
          EndIf
          
        EndIf
        Select LCase(sReason)
          Case "midicapture"
            \bMidiCapture = #True
          Case "nrpncapture"
            \bNRPNCapture = #True
          Case "cuecontrol"
            \bCueControl = #True
            ; debugMsg0(sProcName, "gaMidiInDevice(" + nPhysicalDevPtr + ")\bCueControl=" + strB(\bCueControl))
          Case "connectport"
            \bConnectPort = #True
          Case "controllerportin"
            \bControllerPort = #True
        EndSelect
        
      Else  ; "close"
        Select LCase(sReason)
          Case "midicapture"
            \bMidiCapture = #False
          Case "nrpncapture"
            \bNRPNCapture = #False
          Case "cuecontrol"
            \bCueControl = #False
          Case "connectport"
            \bConnectPort = #False
          Case "controllerportin"
            \bControllerPort = #False
          Case "all"
            \bMidiCapture = #False
            \bNRPNCapture = #False
            \bCueControl = #False
            \bConnectPort = #False
            \bControllerPort = #False
        EndSelect
        
        If ((\bMidiCapture = #False) And (\bNRPNCapture = #False) And (\bCueControl = #False) And (\bConnectPort = #False) And (\bControllerPort = #False)) Or (gbClosingDown) Or (bForceClose)
          ; port can now be closed
          If \hMidiIn <> 0
            nMidiError = midiInStop_(\hMidiIn)
            debugMsg2(sProcName, "midiInStop_(" + \hMidiIn + ")", nMidiError)
            If nMidiError <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiInStop_(" + \hMidiIn + ")", nMidiError)
            EndIf
            
            gbInMidiInReset = #True
            nMidiError = midiInReset_(\hMidiIn)
            debugMsg2(sProcName, "midiInReset_(" + \hMidiIn + ")", nMidiError)
            If nMidiError <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiInReset_(" + \hMidiIn + ")", nMidiError)
            EndIf
            gbInMidiInReset = #False
            
            nMidiError = midiInUnprepareHeader_(\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
            debugMsg2(sProcName, "midiInUnprepareHeader_(" + \hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
            ;If nMidiError <> #MMSYSERR_NOERROR
            ;  ShowMMErr sProcName, "midiInUnprepareHeader: MidiIn_Port(" + #DQUOTE$ + sOpenClose + #DQUOTE$ + ", " + nPhysicalDevPtr + ")", nMidiError
            ;EndIf
            
            gbInMidiInClose = #True
            nMidiError = midiInClose_(\hMidiIn)
            debugMsg2(sProcName, "midiInClose_(" + \hMidiIn + ")", nMidiError)
            If nMidiError <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiInClose_(" + \hMidiIn + ")", nMidiError)
            EndIf
            gbInMidiInClose = #False
            \hMidiIn = 0
            \bInitialized = #False
          EndIf
        EndIf
      EndIf
      
      debugMsg(sProcName, #SCS_END + ", hMidiIn=" + \hMidiIn)
      
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure MidiConnect_Port(sOpenClose.s, nPhysicalDevPtr)
  PROCNAME("MidiConnect_Port(" + sOpenClose + ")")
  ; a MIDI connect port is a MIDI In port but is not used in SCS for cue control, but just to be connected to a MIDI Out port to establish a MIDI Thru link
  Protected nMidiError.l   ; long
  Protected ct, ret.w
  Protected midiDevID
  Protected length = #SCS_MIDI_IN_BUFFER_LEN
  
  debugMsg(sProcName, #SCS_START)
  
  If *gMidiInData = 0
    *gMidiInData = AllocateMemory(length)
  EndIf
  
  If *gMidiInData
    For ct = 0 To length - 1
      PokeA(*gMidiInData+ct, 0) ;c++ end of string char
    Next ct
  EndIf
  
  If nPhysicalDevPtr >= 0
    
    With gaMidiInHdr(nPhysicalDevPtr)
      \lpData = *gMidiInData
      \dwBufferLength = length
      \dwBytesRecorded = 0  ;Length - 1 ' Was Length - only used for MIDI in
      \dwUser = 0
      \dwFlags = 0
    EndWith
    
    With gaMidiInDevice(nPhysicalDevPtr)
      
      If sOpenClose = "open"
        nMidiError = midiInOpen_(@\hMidiConnect, \nMidiDeviceID, @MidiIn_Proc(), nPhysicalDevPtr, #CALLBACK_FUNCTION)   ; place nPhysicalDevPtr in 'instance data' parameter for callback
        debugMsg2(sProcName, "midiInOpen_(@\hMidiConnect, " + \nMidiDeviceID + ", @MidiIn_Proc(), " + nPhysicalDevPtr + ", #CALLBACK_FUNCTION)", nMidiError)
        debugMsg3(sProcName, "\hMidiConnect=" + \hMidiConnect)
        If nMidiError <> #MMSYSERR_NOERROR
          ShowMMErr(sProcName, "midiInOpen_(@\hMidiConnect, " + \nMidiDeviceID + ", @MidiIn_Proc(), " + nPhysicalDevPtr + ", #CALLBACK_FUNCTION)", nMidiError)
          ProcedureReturn
        EndIf
        
        ; prepare a buffer for MIDI input
        nMidiError = midiInPrepareHeader_(\hMidiConnect, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
        debugMsg2(sProcName, "midiInPrepareHeader_(" + \hMidiConnect + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
        If nMidiError <> #MMSYSERR_NOERROR
          ShowMMErr(sProcName, "midiInPrepareHeader_(" + \hMidiConnect + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
          ProcedureReturn #False
        EndIf
        
        ; send an input buffer to midi input dev
        nMidiError = midiInAddBuffer_(\hMidiConnect, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
        debugMsg2(sProcName, "midiInAddBuffer_(" + \hMidiConnect + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
        If nMidiError <> #MMSYSERR_NOERROR
          ShowMMErr(sProcName, "midiInAddBuffer_(" + \hMidiConnect + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
          ProcedureReturn #False
        EndIf
        
        nMidiError = midiInStart_(\hMidiConnect)
        debugMsg2(sProcName, "midiInStart_(" + \hMidiConnect + ")", nMidiError)
        If nMidiError <> #MMSYSERR_NOERROR
          ShowMMErr(sProcName, "midiInStart_(" + \hMidiConnect + ")", nMidiError)
          ProcedureReturn #False
        EndIf
        
      Else  ; "close"
        If \hMidiConnect <> 0
          nMidiError = midiInStop_(\hMidiConnect)
          debugMsg2(sProcName, "midiInStop_(" + \hMidiConnect + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInStop_(" + \hMidiConnect + ")", nMidiError)
          EndIf
          
          gbInMidiInReset = #True
          nMidiError = midiInReset_(\hMidiConnect)
          debugMsg2(sProcName, "midiInReset_(" + \hMidiConnect + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInReset_(" + \hMidiConnect + ")", nMidiError)
          EndIf
          gbInMidiInReset = #False
          
          nMidiError = midiInUnprepareHeader_(\hMidiConnect, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInUnprepareHeader_(" + \hMidiConnect + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
          ;If nMidiError <> #MMSYSERR_NOERROR
          ;  ShowMMErr sProcName, "midiInUnprepareHeader: MidiIn_Port(" + #DQUOTE$ + sOpenClose + #DQUOTE$ + ", " + nMidiInPort + ")", nMidiError
          ;EndIf
          
          gbInMidiInClose = #True
          nMidiError = midiInClose_(\hMidiConnect)
          debugMsg2(sProcName, "midiInClose_(" + \hMidiConnect + ")", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInClose_(" + \hMidiConnect + ")", nMidiError)
          EndIf
          gbInMidiInClose = #False
          \hMidiConnect = 0
          \bInitialized = #False
        EndIf
      EndIf
      
      debugMsg(sProcName, #SCS_END + ", hMidiConnect=" + \hMidiConnect)
      
    EndWith
  EndIf
  
  ProcedureReturn #True
  
EndProcedure

Procedure MidiCallback_Proc(hmIN.l, wMsg.l, dwInstance.l, dw1.l, dw2.l)
  ; nb dwInstance will contain the nPhysicalDevPtr to arrays like gaMidiInDevice(), gaMidiControl(), etc
  PROCNAMEC()
  
  debugMsg0(sProcName, #SCS_START)
  
EndProcedure

Procedure MidiIn_Proc(hmIN.l, wMsg.l, dwInstance.l, dw1.l, dw2.l)
  ; nb dwInstance will contain the nPhysicalDevPtr to arrays like gaMidiInDevice(), gaMidiControl(), etc
  PROCNAMEC()
  Protected n
  Protected msgType, midiChannel, kk, vv, bReqd
  Protected nTmp
  Protected nMidiPhysicalDevPtr
  Protected nThisIndex
  Protected nThisCount
  Static nTimeCode.l, nQtrFrameFlags
  Protected nQtrFramePiece, nQtrFrameData
  Protected nIndex, nCuePtr, nMTCStartTimeForCueOrSub
  Static bNRPNStarted, NRPNMidiChannel
  Static dw1_NRPN_MSB.l, vv_NRPN_MSB.b
  Static dw1_NRPN_LSB.l, vv_NRPN_LSB.b
  Static dw1_Data_MSB.l, vv_Data_MSB.b
  Static dw1_Data_LSB.l, vv_Data_LSB.b
  Static nNRPNPartsReceived, bYamahaNRPNFormat
  Static nActiveSensingPrevMinute
  Protected bCurrMsgIsNRPN, bFull4PartNRPNReqd, nActiveSensingCurrMinute
  
  ; debugMsg(sProcName, #SCS_START + ", hmIN=" + hmIN + ", wMsg=" + decodeMidiMsg(wMsg) + ", dwInstance=" + dwInstance + ", dw1=$" + Hex(dw1) + ", dw2=" + dw2)
  
  ; added 17Nov2015 11.4.1.2m
  If gbClosingDown
    ProcedureReturn
  EndIf
  ; end added 17Nov2015 11.4.1.2m
  
  If (wMsg = #MM_MIM_DATA) And (dw1 = $FE)
    ; active sensing message - ignore immediately, but log once a minute so we at least know they are happening
    nActiveSensingCurrMinute = Int(ElapsedMilliseconds() / 60000)
    If nActiveSensingCurrMinute <> nActiveSensingPrevMinute
      debugMsg(sProcName, "Active sensing: hmIN=" + hmIN + ", wMsg=" + decodeMidiMsg(wMsg) + ", dwInstance=" + dwInstance + ", dw1=" + dw1 + ", dw2=" + dw2)
      nActiveSensingPrevMinute = nActiveSensingCurrMinute
    EndIf
    ProcedureReturn
  EndIf
  
  If wMsg = #MM_MIM_MOREDATA
    debugMsg(sProcName, "More Data")
    ProcedureReturn
  EndIf
  
  nMidiPhysicalDevPtr = dwInstance
  
  ; debugMsg0(sProcName, "grSession\nMidiInEnabled=" + grSession\nMidiInEnabled + ", gbCapturingFreeFormatMidi=" + strB(gbCapturingFreeFormatMidi) + ", gbCapturingNRPN=" + strB(gbCapturingNRPN))
  
  If grSession\nMidiInEnabled <> #SCS_DEVTYPE_ENABLED
    ; currently ignoring midi
    debugMsg(sProcName, "exiting because grSession\nMidiInEnabled=" + grSession\nMidiInEnabled)
    ProcedureReturn
  EndIf

  If gbTooManyMessages
    ; waiting for stack to be cleared
    debugMsg(sProcName, "exiting because gbTooManyMessages=" + strB(gbTooManyMessages))
    ProcedureReturn
  EndIf
  
  If (gbInMidiInReset) Or (gbInMidiInClose)
    ; discard message(s) generated by midiInReset and midiInClose
    debugMsg(sProcName, "exiting because gbInMidiInReset=" + strB(gbInMidiInReset) + ", gbInMidiInClose=" + strB(gbInMidiInClose))
    ProcedureReturn
  EndIf
  
  ; debugMsg0(sProcName, "gbCapturingFreeFormatMidi=" + strB(gbCapturingFreeFormatMidi) + ", nMidiPhysicalDevPtr=" + nMidiPhysicalDevPtr + ", gnMidiCapturePhysicalDevPtr=" + gnMidiCapturePhysicalDevPtr)
  If gbCapturingFreeFormatMidi
    ; gbCapturingFreeFormatMidi is set #True by WQM\btnMidiCapture, which is the MIDI capture for MIDI Free Format messages, NOT for NRPN messages
    If nMidiPhysicalDevPtr = gnMidiCapturePhysicalDevPtr
      MidiCapture_Proc(hmIN, wMsg, dwInstance, dw1, dw2)
      debugMsg(sProcName, "exiting because gbCapturingFreeFormatMidi and nMidiPhysicalDevPtr=gnMidiCapturePhysicalDevPtr")
      ProcedureReturn
    EndIf
  EndIf
  
  ; debugMsg(sProcName, "gaMidiInDevice(" + nMidiPhysicalDevPtr + ")\nCtrlMidiRemoteDev=" + gaMidiInDevice(nMidiPhysicalDevPtr)\nCtrlMidiRemoteDev + ", bFull4PartNRPNReqd=" + strB(bFull4PartNRPNReqd))
  
  If wMsg = #MM_MIM_DATA
    If (dw1 & $FF) = $F1
      With grMTCControl
        ; MTC Quarter Frame
        CompilerIf #cTraceMTCQuarterFramesReceived And 1=2
          debugMsg(sProcName, "MTC Quarter Frame: dw1=$" + Hex(dw1,#PB_Long) + ", dw2=$" + Hex(dw2,#PB_Long))
        CompilerEndIf
        nQtrFramePiece = dw1 >> 12
        nQtrFrameData = (dw1 >> 8) & $F
        ; rate (rr) 00=24, 01=25,10=29.97, 11=30)
        ; hour (hhhh) 0-23
        ; minute (mmmmm) 0-59
        ; second (sssss) 0-59
        ; frame (ffff) 0-29
        Select nQtrFramePiece
          Case 0  ; 0000 ffff frame number lsbits
            nTimeCode = nQtrFrameData
            nQtrFrameFlags = 1
          Case 1  ; 0001 000f frame number msbit
            nTimeCode + (nQtrFrameData << 4)
            nQtrFrameFlags | 2
          Case 2  ; 0010 ssss second lsbits
            nTimeCode + (nQtrFrameData << 8)
            nQtrFrameFlags | 4
          Case 3  ; 0011 00ss second msbits
            nTimeCode + (nQtrFrameData << 12)
            nQtrFrameFlags | 8
          Case 4  ; 0100 mmmm minute lsbits
            nTimeCode + (nQtrFrameData << 16)
            nQtrFrameFlags | 16
          Case 5  ; 0101 00mm minute msbits
            nTimeCode + (nQtrFrameData << 20)
            nQtrFrameFlags | 32
          Case 6  ; 0110 hhhh hour lsbits
            nTimeCode + (nQtrFrameData << 24)
            nQtrFrameFlags | 64
          Case 7  ; 0111 0rrh rate and hour msbit
            nTimeCode + ((nQtrFrameData & 1) << 28) ; ignore frame rate as we just want a 'time' value we can compare
            nQtrFrameFlags | 128
            ; if all pieces received then store time code in grMTCControl\nTimeCode
            If nQtrFrameFlags = 255
              \nTimeCode = nTimeCode
              CompilerIf #cTraceMTCQuarterFramesReceived
                debugMsg(sProcName, "MTC Quarter Frame: \nTimeCode=$" + Hex(\nTimeCode,#PB_Long))
              CompilerEndIf
              ; added 16Dec2019 11.8.2.1ah
              If \bMTCControlActive = #False
                ; no full frame message yet received so set variables based on this (first) quarter frame message
                debugMsg(sProcName, "MTC quarter frame message received before a full frame message, so setting \bMTCControlActive=#True now." +
                                    " \nTimeCode=" + decodeMTCTime(\nTimeCode) + " ($" + Hex(\nTimeCode,#PB_Long) + ")")
                \nPrevTimeCodeProcessed = adjustMTCBySeconds(nTimeCode, -1)
                \nMidiPhysicalDevPtr = nMidiPhysicalDevPtr
                \sMidiInName = gaMidiControl(nMidiPhysicalDevPtr)\sMidiInName
                \bMTCControlActive = #True
              ElseIf (nTimeCode < \nPrevTimeCodeProcessed) And (nTimeCode <> 0)
                ; earlier quarter frame message received so assume MTC has been restarted, so set variables based on this quarter frame message
                debugMsg(sProcName, "MTC quarter frame time code < previous time code, so setting \bMTCControlActive=#True now." +
                                    " \nTimeCode=" + decodeMTCTime(\nTimeCode) + " ($" + Hex(\nTimeCode,#PB_Long) + ")" +
                                    ", \nPrevTimeCodeProcessed=" + decodeMTCTime(\nPrevTimeCodeProcessed) + " ($" + Hex(\nPrevTimeCodeProcessed,#PB_Long) + ")")
                \nPrevTimeCodeProcessed = adjustMTCBySeconds(nTimeCode, -1)
                \nMidiPhysicalDevPtr = nMidiPhysicalDevPtr
                \sMidiInName = gaMidiControl(nMidiPhysicalDevPtr)\sMidiInName
                \bMTCControlActive = #True
              EndIf
              ; end added 16Dec2019 11.8.2.1ah
              If gbMidiTestWindow
                WMT_DisplayTimeCode(nTimeCode)
                checkArrayCueOrSubForMTC()
              EndIf
            EndIf
            nTimeCode = 0
            nQtrFrameFlags = 0
        EndSelect
        
      EndWith
      ProcedureReturn ; completed processing of MTC Quarter Frame
    EndIf
  EndIf
  
  ; debugMsg3(sProcName, "hmIN=" + hmIN + ", wMsg=" + decodeMidiMsg(wMsg) + ", dwInstance=" + dwInstance + ", dw1=" + dw1 + ", dw2=" + dw2)
  
  msgType = 0
  midiChannel = 0
  kk = 0 ; nb 'kk' also used for 'cc', 'mm' etc, the terminology depending on the type of message
  vv = 0
  
  If wMsg = #MM_MIM_DATA
    
    midiChannel = (dw1 & $F) + 1
    nTmp = dw1 >> 4
    msgType = nTmp & $F
    nTmp >> 4
    kk = nTmp & $FF
    nTmp >> 8
    vv = nTmp & $FF
    CompilerIf #cTraceMidiIn
      debugMsg(sProcName, "wMsg=MM_MIM_DATA" + ", midiChannel=" + midiChannel + ", msgType=$" + Hex(msgType) + ", kk=$" + hex2(kk) + ", vv=$" + hex2(vv))
    CompilerEndIf
    
    ; INFO: upgrade to log NRPN, which is supplied as 4 consecutive Control Change messages, eg this from a test run when moving fader 16 on the Qu-16:
    ; debugMsg0(sProcName, "wMsg=MM_MIM_DATA, dw1=" + Hex(dw1,#PB_Long) + ", midiChannel=" + midiChannel + ", msgType=$" + Hex(msgType) + ", kk=$" + hex2(kk) + ", vv=$" + Hex2(vv))
    ;   17:59:42.130(28619) ~1 #0 MIDI@1034.MidiIn_Proc: wMsg=MM_MIM_DATA, midiChannel=1, msgType=$B, kk=$63, vv=$2F   NRPN MSB ($2F = CH16 on Qu-16)
    ;   17:59:42.130(28620) ~1 #0 MIDI@1034.MidiIn_Proc: wMsg=MM_MIM_DATA, midiChannel=1, msgType=$B, kk=$62, vv=$17   NRPN LSB ($17 = Fader on Qu-16)
    ;   17:59:42.131(28621) ~1 #0 MIDI@1034.MidiIn_Proc: wMsg=MM_MIM_DATA, midiChannel=1, msgType=$B, kk=$06, vv=$24   Data MSB ($24 = Fader Value on Qu-16)
    ;   17:59:42.131(28622) ~1 #0 MIDI@1034.MidiIn_Proc: wMsg=MM_MIM_DATA, midiChannel=1, msgType=$B, kk=$26, vv=$07   Data LSB ($07 = constant for Fader on Qu-16)
    
    If msgType = $B
      ; debugMsg0(sProcName, "bNRPNStarted=" + strB(bNRPNStarted) + ", nNRPNPartsReceived=" + nNRPNPartsReceived + ", NRPNMidiChannel=" + NRPNMidiChannel)
      Select kk ; nb in a Control Change message this is usually referred to as cc but is from the same byte of the message as kk
        Case 99, 98
          If bNRPNStarted And nNRPNPartsReceived >= 3
            ; previous NRPN message completed, so prepare to accept a new NRPN message
            bNRPNStarted = #False
          EndIf
          If bNRPNStarted = #False
            bNRPNStarted = #True
            NRPNMidiChannel = midiChannel
            nNRPNPartsReceived = 1
            dw1_Data_LSB = 0 ; nb Data_LSB is optional in the NRPN spec
            vv_Data_LSB = 0
          ElseIf midiChannel = NRPNMidiChannel And nNRPNPartsReceived = 1
            nNRPNPartsReceived = 2
          Else
            bNRPNStarted = #False
          EndIf
      EndSelect
      
      If bNRPNStarted And midiChannel = NRPNMidiChannel
        Select kk ; nb in a Control Change message this is usually referred to as cc but is from the same byte of the message as kk
          Case 99
            dw1_NRPN_MSB = dw1
            vv_NRPN_MSB = vv
            bCurrMsgIsNRPN = #True
            If nNRPNPartsReceived = 1
              bYamahaNRPNFormat = #False
            EndIf
            
          Case 98
            dw1_NRPN_LSB = dw1
            vv_NRPN_LSB = vv
            bCurrMsgIsNRPN = #True
            If nNRPNPartsReceived = 1
              bYamahaNRPNFormat = #True
            EndIf
            
          Case 6
            If nNRPNPartsReceived = 2
              dw1_Data_MSB = dw1
              vv_Data_MSB = vv
              nNRPNPartsReceived = 3
              bCurrMsgIsNRPN = #True
            Else
              bNRPNStarted = #False ; abort 'nrpn'
            EndIf
            
          Case 38
            If nNRPNPartsReceived = 3
              dw1_Data_LSB = dw1
              vv_Data_LSB = vv
              nNRPNPartsReceived = 4
              bCurrMsgIsNRPN = #True
            Else
              bNRPNStarted = #False ; abort 'nrpn'
            EndIf
        EndSelect
      EndIf
    EndIf
    
    If bNRPNStarted
      If bCurrMsgIsNRPN And nNRPNPartsReceived >= 3 And (bFull4PartNRPNReqd = #False Or nNRPNPartsReceived = 4)
        ; process this NRPN
        If gnMidiInCount > ArraySize(gaMidiIns())
          ReDim gaMidiIns(gnMidiInCount + 2000)
        EndIf
        gbMidiInLocked = #True
        n = gnMidiInCount
        nThisIndex = n
        nThisCount + 1
        grMidiIn = grMidiInDef
        With grMidiIn
          If bYamahaNRPNFormat
            \bNRPN_Yam = #True
            \bNRPN_Gen = #False
          Else
            \bNRPN_Gen = #True
            \bNRPN_Yam = #False
          EndIf
          \nPhysicalDevPtr = nMidiPhysicalDevPtr
          \midiChannel = midiChannel
          \dw1_NRPN_MSB = dw1_NRPN_MSB
          \dw1_NRPN_LSB = dw1_NRPN_LSB
          \dw1_Data_MSB = dw1_Data_MSB
          \dw1_Data_LSB = dw1_Data_LSB
          \vv_NRPN_MSB = vv_NRPN_MSB
          \vv_NRPN_LSB = vv_NRPN_LSB
          \vv_Data_MSB = vv_Data_MSB
          \vv_Data_LSB = vv_Data_LSB
          \nNRPNPartsReceived = nNRPNPartsReceived ; will be either 3 or 4
        EndWith
        gaMidiIns(n) = grMidiIn
        gnMidiInCount = n + 1
        gbMidiInLocked = #False
      EndIf ; EndIf bCurrMsgIsNRPN And nNRPNPartsReceived >= 3
    EndIf ; EndIf bNRPNStarted
    
    ; debugMsg0(sProcName, "bCurrMsgIsNRPN=" + strB(bCurrMsgIsNRPN) + ", msgType=$" + Hex(msgType) + ", midiChannel=" + midiChannel)
    If bCurrMsgIsNRPN = #False
      If (msgType >= $8) And (msgType <= $E)
        ; accept $H8(Note Off), $H9 (Note On), $HA(Key Pressure), $HB(Control Change), $HC(Program Change), $HD(Channel Pressure / After Touch) and $HE(Pitch Bend Change)
        If midiChannel > 0
          bReqd = checkMidiChannelAndMsgTypeReqd(midiChannel, msgType, kk, vv)
          ; debugMsg0(sProcName, "checkMidiChannelAndMsgTypeReqd(" + midiChannel + ", $" + Hex(msgType) + ", " + kk + ", " + vv + ") returned " + strB(bReqd))
          If bReqd = #False
            If (grCtrlSetup\bUseExternalController) And (midiChannel = 1) And (msgType = $B)
              ; debugMsg0(sProcName, "OK - message possibly from a BCF2000/BCR2000")
            ElseIf (grOperModeOptions(gnOperMode)\bDisplayAllMidiIn = #False) And (gbMidiTestWindow = #False) And (gbCapturingFreeFormatMidi = #False)
              ; 10Mar2020 11.8.2.2bi: added "And (gbMidiTestWindow = #False) And (gbCapturingFreeFormatMidi = #False)" to the above as CC messages were not being logged in the MIDI Test window (reported by Michel W)
              ; message not of use to SCS, so discard
              ; debugMsg0(sProcName, "discard")
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        
        If gnMidiInCount > ArraySize(gaMidiIns())
          ReDim gaMidiIns(gnMidiInCount + 2000)
        EndIf
        gbMidiInLocked = #True
        n = gnMidiInCount
        nThisIndex = n
        nThisCount + 1
        grMidiIn = grMidiInDef
        With grMidiIn
          \nPhysicalDevPtr = nMidiPhysicalDevPtr
          \wMsg = wMsg
          \dwInstance = dwInstance
          \dw1 = dw1
          \dw2 = dw2
          \msgType = msgType
          \midiChannel = midiChannel
          \kk = kk
          \vv = vv
          \bDone = #False
          \bPlayCue = #False
          If msgType = $9
            If gaMidiControl(nMidiPhysicalDevPtr)\nCtrlMethod = #SCS_CTRLMETHOD_NOTE
              \bPlayCue = #True
            EndIf
          EndIf
        EndWith
        gaMidiIns(n) = grMidiIn
        gnMidiInCount = n + 1
        gbMidiInLocked = #False
        CompilerIf #cTraceMidiIn
          debugMsg(sProcName, "gnMidiInCount=" + gnMidiInCount + ", gaMidiIns(" + n + ")\bPlayCue=" + strB(gaMidiIns(n)\bPlayCue) + ", \kk=" + gaMidiIns(n)\kk)
        CompilerEndIf
      EndIf ; EndIf (msgType >= $8) And (msgType <= $E)
    EndIf ; EndIf bCurrMsgIsNRPN = #False
    
  ElseIf (wMsg = #MM_MIM_LONGDATA) Or (wMsg = #MM_MIM_ERROR) Or (wMsg = #MM_MIM_LONGERROR)
    ; debugMsg0(sProcName, "hmIN=" + hmIN + ", wMsg=" + decodeMidiMsg(wMsg) + ", dwInstance=" + dwInstance + ", dw1=" + dw1 + ", dw2=" + dw2)
    If gnMidiInCount > ArraySize(gaMidiIns())
      ReDim gaMidiIns(gnMidiInCount + 2000)
    EndIf
    gbMidiInLocked = #True
    n = gnMidiInCount
    nThisIndex = n
    nThisCount + 1
    grMidiIn = grMidiInDef
    With grMidiIn
      \nPhysicalDevPtr = nMidiPhysicalDevPtr
      \wMsg = wMsg
      \dwInstance = dwInstance
      \dw1 = dw1
      \dw2 = dw2
      \bDone = #False
      \bPlayCue = #False
    EndWith
    gaMidiIns(n) = grMidiIn
    gnMidiInCount = n + 1
    gbMidiInLocked = #False
    
  EndIf
  
  PostEvent(#SCS_Event_WakeUp, #WMN, 0) ; wake up main thread's WaitWindowEvent()
  
  ; debugMsg(sProcName, #SCS_END + ", gnMidiInCount=" + gnMidiInCount)

EndProcedure

Procedure.s decodeMidiMsg(wMsg.l)
  PROCNAMEC()
  Protected sMsg.s
  
  Select wMsg
    Case #MM_MIM_CLOSE
      sMsg = "MM_MIM_CLOSE"
    Case #MM_MIM_DATA
      sMsg = "MM_MIM_DATA"
    Case #MM_MIM_ERROR
      sMsg = "MM_MIM_ERROR"
    Case #MM_MIM_LONGDATA
      sMsg = "MM_MIM_LONGDATA"
    Case #MM_MIM_LONGERROR
      sMsg = "MM_MIM_LONGERROR"
    Case #MM_MIM_OPEN 
      sMsg = "MM_MIM_OPEN"
    Default
      sMsg = Str(wMsg)
  EndSelect
  ProcedureReturn sMsg
EndProcedure

Procedure MidiCapture_Proc(hmIN.l, wMsg.l, dwInstance.l, dw1.l, dw2.l)
  ; nb dwInstance will contain the nPhysicalDevPtr to arrays like gaMidiInDevice(), gaMidiControl(), etc
  PROCNAMEC()
  Protected nTmp
  Protected sMsgBytes.s
  Protected a1.a, a2.a, a3.a
  Protected nBytesRecorded, ct
  Protected aOneByte.a, sChar.s
  Protected length = #IN_BUFFER_LEN
  Protected nResult
  
  debugMsg(sProcName, #SCS_START + ", wMsg=" + decodeMidiMsg(wMsg))
  
  If (wMsg = #MM_MIM_DATA) And (dw1 = $FE)
    ; active sensing message - ignore immediately
    ProcedureReturn
  EndIf
  
  debugMsg3(sProcName, "hmIN=" + hmIN + ", wMsg=" + decodeMidiMsg(wMsg) + ", dwInstance=" + dwInstance + ", dw1=" + dw1 + ", dw2=" + dw2)
  
  If (gbInMidiInReset) Or (gbInMidiInClose)
    ; discard message(s) generated by midiInReset and midiInClose
    ProcedureReturn
  EndIf
  
  If gnMidiCapturePhysicalDevPtr < 0
    ; shouldn't get here
    ProcedureReturn
  EndIf
  
  ; Added 6Nov2020 11.8.3.3ad following a test of MIDI Capture that crashed in a WQM procedure after closing the editor, when nEditSubPtr was -1
  If nEditSubPtr < 0
    gbCapturingFreeFormatMidi = #False
    gbCapturingNRPN = #False
    ProcedureReturn
  ElseIf aSub(nEditSubPtr)\bSubTypeM = #False
    gbCapturingFreeFormatMidi = #False
    gbCapturingNRPN = #False
    ProcedureReturn
  EndIf
  ; End added 6Nov2020 11.8.3.3ad
  
  With gaMidiInDevice(gnMidiCapturePhysicalDevPtr)
    
    Select wMsg
      Case #MM_MIM_DATA, #MM_MIM_LONGDATA
        
        If wMsg = #MM_MIM_DATA
          ; debugMsg(sProcName, "wMsg=#MM_MIM_DATA")
          a1 = dw1 % 256
          nTmp = Round(dw1 / 256, #PB_Round_Down)
          a2 = nTmp % 256
          nTmp = Round(nTmp / 256, #PB_Round_Down)
          a3 = nTmp % 256
          sMsgBytes = hex2(a1) + " " + hex2(a2) + " " + hex2(a3)
          
        ElseIf wMsg = #MM_MIM_LONGDATA
          ; debugMsg(sProcName, "wMsg=#MM_MIM_LONGDATA, \nMidiCapturePort=" + \nMidiCapturePort + ", \nMidiInPort=" + \nMidiInPort)
          sMsgBytes = ""
          nBytesRecorded = gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\dwBytesRecorded
          debugMsg(sProcName, "nBytesRecorded=" + nBytesRecorded)
          For ct = 0 To nBytesRecorded - 1
            aOneByte = PeekA(*gMidiInData+ct)
            sChar = hex2(aOneByte)
            debugMsg(sProcName, "aOneByte=$" + Hex(aOneByte) + ", sChar=" + sChar)
            sMsgBytes + sChar + " "
          Next ct
          debugMsg(sProcName, "sMsgBytes=" + sMsgBytes)
          
        EndIf
        
        SGT(WQM\txtMFEnteredString, RTrim(sMsgBytes))
        SGT(WQM\lblMidiCaptureDone, LangSpace("WQM","Done")) ; add space to end because of italic font losing a bit
        gqEditMidiInfoDisplayed = ElapsedMilliseconds()
        gbEditMidiInfoDisplayedSet = #True
        SGT(WQM\btnMidiCapture, Lang("WQM","btnMidiCapture"))
        gbCapturingFreeFormatMidi = #False
        If wMsg = #MM_MIM_LONGDATA
          nResult = midiInUnprepareHeader_(\hMidiIn, @gaMidiInHdr(gnMidiCapturePhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInUnprepareHeader_(" + \hMidiIn + ", @gaMidiInHdr(gnMidiCapturePhysicalDevPtr), " + SizeOf(MIDIHDR) + ")", nResult)
          ;If nResult <> #MMSYSERR_NOERROR
          ;  ShowMMErr sProcName, "midiInUnprepareHeader", nResult
          ;EndIf
          
          gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\lpData = *gMidiInData
          gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\dwBufferLength = length
          gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\dwBytesRecorded = 0  ;Length - 1 ' Was Length - only used for MIDI in
          gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\dwUser = 0
          gaMidiInHdr(gnMidiCapturePhysicalDevPtr)\dwFlags = 0
          ;prepare a buffer for MIDI input
          nResult = midiInPrepareHeader_(\hMidiIn, @gaMidiInHdr(gnMidiCapturePhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInPrepareHeader_(" + \hMidiIn + ", @gaMidiInHdr(" + gnMidiCapturePhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nResult)
          If nResult <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInPrepareHeader", nResult)
          EndIf
          
          ;send an input buffer to midi input dev
          nResult = midiInAddBuffer_(\hMidiIn, @gaMidiInHdr(gnMidiCapturePhysicalDevPtr), SizeOf(MIDIHDR))
          debugMsg2(sProcName, "midiInAddBuffer_(" + \hMidiIn + ", @gaMidiInHdr(" + gnMidiCapturePhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nResult)
          If nResult <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiInAddBuffer", nResult)
          EndIf
        EndIf
        setEnabled(WQM\cboMidiCapturePort, #True)
        
    EndSelect
  EndWith
EndProcedure

Procedure.s decodeCommandFormatL(nCommandFormat.b) ; nb if you change .b then change #PB_Byte in the Hex() command
  Protected sLangKey.s
  
  sLangKey = "MSC_Cmd$" + RSet(Hex(nCommandFormat, #PB_Byte), 2, "0")
  ProcedureReturn Lang("MIDI", sLangKey, "")
EndProcedure

Procedure displayMidiWarning(sMsg.s)
  PROCNAMEC()
  Protected bHoldModalDisplayed

  If gbMidiWarningDisplayed = #False
    bHoldModalDisplayed = gbModalDisplayed
    ensureSplashNotOnTop()
    gbModalDisplayed = #True
    debugMsg(sProcName, ReplaceString(sMsg, #CRLF$, " "))
    scsMessageRequester(#SCS_TITLE, sMsg, #MB_ICONEXCLAMATION)
    gbMidiWarningDisplayed = #True
    gbModalDisplayed = bHoldModalDisplayed
  EndIf

EndProcedure

Procedure.s formatMidiText(sPort.s, txt.s, txt2.s)
  If Trim(txt2) And Trim(txt)
    ProcedureReturn "MIDI IN: " + Trim(txt2 + " (" + sPort + ", " + txt + ")")
  Else
    ProcedureReturn " MIDI IN: " + Trim(sPort + ", " + txt + " " + txt2)
  EndIf
EndProcedure

Procedure doMidiIn_Proc()
  PROCNAMEC()
  Protected bTrace = #cTraceMidiIn
  Protected txt.s, txt2.s, txt3.s, nCtrlMethod
  Protected midiChannel.l
  Protected d, n, nCount
  Protected sMidiCue.s, nAction, nMidiCuePtr, bTurnButtonOff
  Protected kk, vv, msgType
  Protected ct, nBytesRecorded
  Protected length = #IN_BUFFER_LEN
  Protected nMidiError, sChar.s
  Protected bMTCMsg, bMSCMsg, bMMCMsg
  Protected bMTCFullFrame
  Protected bGettingQNumber, bGettingQList, bGettingQPath
  Protected sQNumber.s, sQList.s, sQPath.s
  Protected nMscMmcMidiDevId, aOneByte.a
  Protected nMscCommandFormat.b, nMSCCommand.b, sMSCData.s
  Protected nMMCCommand.b, bIgnoreInputMsg
  Protected nGoMacro
  Protected fNewLevel.f
  Protected bNoteOff
  Protected nPhysicalDevPtr, nOutputPhysicalDevPtr
  Protected sMidiInName.s
  Protected nTimeCode.l
  Protected bLogEnd, nLogEntry, bCheckForControllerMsg
  Protected nCuePtr, nAudNo, nDevMapDevPtr, nCtrlNo
  Protected nDimmerController, nDimmerFaderValue
  Protected nEarliestPlayingSubPtr, nAudPtr
  Static sNRPN.s, sNRPNY.s, bStaticLoaded
  Static qTimeOfLastMMCCommand.q
  
  If gnMidiInCount > 0
    debugMsgC(sProcName, #SCS_START + ", gnMidiInCount=" + gnMidiInCount + ", ArraySize(gaMidiIns())=" + ArraySize(gaMidiIns()))
    bLogEnd = #True
  EndIf
  
  If gbMidiInLocked
    debugMsg(sProcName, "exit gbMidiInLocked")
    ProcedureReturn
  EndIf
  
  If bStaticLoaded = #False
    sNRPN = decodeMsgTypeShortL(#SCS_MSGTYPE_NRPN_GEN)
    sNRPNY = decodeMsgTypeShortL(#SCS_MSGTYPE_NRPN_YAM)
    bStaticLoaded = #True
  EndIf
  
  nAction = -1
  For n = 0 To (gnMidiInCount-1)
    grMidiIn = gaMidiIns(n)
    bIgnoreInputMsg = #False
    With grMidiIn
      ; debugMsg0(sProcName, "gaMidiIns(" + n + ")\bDone=" + strB(\bDone) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bNRPN_Gen=" + strB(\bNRPN_Gen) + ", gbCapturingNRPN=" + strB(gbCapturingNRPN))
      If (\bDone = #False) And (\nPhysicalDevPtr >= 0)
        debugMsgC(sProcName, "gaMidiIns(" + n + ")\bDone=" + strB(\bDone) + ", \nPhysicalDevPtr=" + \nPhysicalDevPtr + ", \bNRPN_Gen=" + strB(\bNRPN_Gen) + ", \bNRPN_Yam=" + strB(\bNRPN_Yam) + ", gbCapturingNRPN=" + strB(gbCapturingNRPN))
        txt = ""
        txt2 = ""
        txt3 = ""
        bTurnButtonOff = #False
        nPhysicalDevPtr = \nPhysicalDevPtr
        sMidiInName = gaMidiControl(nPhysicalDevPtr)\sMidiInName
        gaMidiControl(nPhysicalDevPtr)\sStatusField = ""
        gaMidiControl(nPhysicalDevPtr)\nStatusType = -1
        If \bNRPN_Gen Or \bNRPN_Yam
          If \bNRPN_Gen
            txt = sNRPN
          Else
            txt = sNRPNY
          EndIf
          txt + " Channel:" + Str(midiChannel + 1)
          If \bNRPN_Gen
            txt + "  NRPN MSB=$" + hex2(\vv_NRPN_MSB) + ", LSB=$" + hex2(\vv_NRPN_LSB)
          ElseIf \bNRPN_Yam
            txt + "  NRPN LSB=$" + hex2(\vv_NRPN_LSB) + ", MSB=$" + hex2(\vv_NRPN_MSB)
          EndIf
          txt + ", Data MSB=$" + hex2(\vv_Data_MSB)
          If \nNRPNPartsReceived = 4
            txt + ", LSB=$" + hex2(\vv_Data_LSB)
          EndIf
          If gbCapturingNRPN
            If IsGadget(WQM\txtNRPNCapture)
              If \bNRPN_Gen
                txt2 = "CH" + Str(midiChannel+1) +
                       ", NRPN MSB:" + \vv_NRPN_MSB +
                       ", LSB:" + \vv_NRPN_LSB
              ElseIf \bNRPN_Yam
                txt2 = "CH" + Str(midiChannel+1) +
                       ", NRPN LSB:" + \vv_NRPN_LSB +
                       ", MSB:" + \vv_NRPN_MSB
              EndIf
              If txt2
                txt2 + ", Data MSB:" + \vv_Data_MSB
                If \nNRPNPartsReceived = 4
                  txt2 + ", LSB:" + \vv_Data_LSB
                EndIf
                ; should be #True
                ; debugMsg0(sProcName, "txt2=" + txt2)
                SGT(WQM\txtNRPNCapture, txt2)
                ; debugMsg0(sProcName, "calling setEnabled(WQM\btnNRPNSave, #True)")
                setEnabled(WQM\btnNRPNSave, #True)
                grWQM\rNRPNCapture = gaMidiIns(n) ; hold info for 'Save' button
                \bDone = #True
                gaMidiIns(n) = grMidiIn ; Added 4Oct2021 11.8.6au because gaMidiIns(n)\bDone MUST be refreshed from grMidiIn\bDone or the program loops!
                Continue
              EndIf
            EndIf
          EndIf
        Else
          nCtrlMethod = gaMidiControl(nPhysicalDevPtr)\nCtrlMethod
          ; debugMsg(sProcName, "nCtrlMethod=" + decodeCtrlMethod(nCtrlMethod))
          nMscMmcMidiDevId = gaMidiControl(nPhysicalDevPtr)\nMscMmcMidiDevId
          If (nMscMmcMidiDevId < 0) Or (nMscMmcMidiDevId > $FF)
            nMscMmcMidiDevId = 0
          EndIf
          nMscCommandFormat = gaMidiControl(nPhysicalDevPtr)\nMscCommandFormat
          If (nMscCommandFormat < $1) Or (nMscCommandFormat > $FF)
            nMscCommandFormat = #MSC_DEFAULT_COMMAND_FORMAT
          EndIf
          nGoMacro = gaMidiControl(nPhysicalDevPtr)\nGoMacro
          
          sMidiCue = ""
          bMTCFullFrame = #False
          
          Select \wMsg
            Case #MM_MIM_OPEN
              debugMsg(sProcName, "gaMidiIns(" + n + ")\wMsg=MM_MIM_OPEN")
              txt = "OPEN"
              
            Case #MM_MIM_CLOSE
              debugMsg(sProcName, "gaMidiIns(" + n + ")\wMsg=MM_MIM_CLOSE")
              txt = "CLOSE"
              
            Case #MM_MIM_DATA
              ; debugMsg(sProcName, "gaMidiIns(" + n + ")\wMsg=MM_MIM_DATA, \midiChannel=" + \midiChannel + ", \msgType=" + Hex(\msgType) + ", \kk=" + \kk + ", \vv=" + \vv)
              midiChannel = \midiChannel
              msgType = \msgType
              kk = \kk
              vv = \vv
              Select msgType
                Case $8
                  bNoteOff = #True
                  txt = "NOTE OFF " + kk
                  txt + "  Velocity:" + vv
                  txt + "  Channel:" + midiChannel
                  
                Case $9
                  txt = "NOTE ON " + kk
                  txt + "  Velocity:" + vv
                  txt + "  Channel:" + midiChannel
                  ; after setting txt, check if this 'note On' message has velocity 0, and if so then change this to a 'note off' message
                  If vv = 0
                    \msgType = $8
                    msgType = \msgType
                    bNoteOff = #True
                    txt + " (converted to "
                    txt + "NOTE OFF " + kk
                    txt + "  Velocity:" + vv
                    txt + "  Channel:" + midiChannel
                    txt + ")"
                  EndIf
                  
                Case $A
                  txt = "KEY PRESSURE " + kk
                  txt + "  Pressure:" + vv
                  txt + "  Channel:" + midiChannel
                  
                Case $B
                  txt = "CONTROLLER CHANGE "
                  txt + "  Controller:" + kk
                  txt + "  Value:" + vv
                  txt + "  Channel:" + midiChannel
                  
                Case $C
                  txt = "PROGRAM CHANGE "
                  txt + "  Program:" + kk
                  txt + "  Channel:" + midiChannel
                  
                Case $D
                  txt = "CHANNEL PRESSURE " + kk
                  txt + "  Pressure:" + vv
                  txt + "  Channel:" + midiChannel
                  
                Case $E
                  txt = "PITCH BEND " + kk
                  txt + "  Delta (LSB):" + vv
                  txt + "  Channel:" + midiChannel
                  
                Default
                  debugMsg(sProcName, "gaMidiIns(" + n + ")\wMsg=" + \wMsg + " (ignored)")
                  
              EndSelect
              
              nAction = -1
              sMidiCue = ""
              If gbCapturingNRPN = #False
                Select nCtrlMethod
                  Case #SCS_CTRLMETHOD_MTC, #SCS_CTRLMETHOD_MSC, #SCS_CTRLMETHOD_MMC
                    ; no action
                  Default
                    ; debugMsg(sProcName, "gaMidiControl(" + nPhysicalDevPtr + ")\nMidiChannel=" + gaMidiControl(nPhysicalDevPtr)\nMidiChannel + ", midiChannel=" + midiChannel)
                    If gaMidiControl(nPhysicalDevPtr)\nMidiChannel = midiChannel
                      nMidiCuePtr = -1 ; default in case not set by setActionAndCue()
                      setActionAndCue(nPhysicalDevPtr, msgType, kk, vv, @nMidiCuePtr)
                      nAction = gnMidiAction
                      sMidiCue = gsMidiCue
                      nAction = changeActionIfReqd(nAction, sMidiCue) ; may change 'play' to 'stop' for external toggle
                      If gbMidiTestWindow = #False
                        If nAction = -1
                          If bNoteOff
                            txt = ""
                          EndIf
                        EndIf
                      EndIf
                    EndIf
                EndSelect
                
                If (nAction = #SCS_MIDI_OPEN_FAV_FILE) And (vv >= 1) And (vv <= 20)
                  txt2 = midiCmdDescrForCmdNo(nAction, -1, sMidiCue, 0, 0, 0, vv)
                ElseIf (nAction = #SCS_MIDI_SET_HOTKEY_BANK) And (vv >= 0) And (vv <= 12)
                  txt2 = midiCmdDescrForCmdNo(nAction, -1, sMidiCue, 0, 0, 0, vv)
                Else
                  txt2 = midiCmdDescrForCmdNo(nAction, -1, sMidiCue)
                EndIf
                
              EndIf ; EndIf gbCapturingNRPN = #False
              debugMsgC(sProcName, "nAction=" + nAction + " (" + decodeMidiCommand(nAction) + "), sMidiCue=" + sMidiCue + ", txt=" + txt + ", txt2=" + txt2)
              
              If gbMidiTestWindow = #False
                If txt
                  If gaMidiControl(nPhysicalDevPtr)\nStatusType < 0
                    ; gaMidiControl(nPhysicalDevPtr)\sStatusField = " MIDI IN  " + sMidiInName + ": " + txt
                    gaMidiControl(nPhysicalDevPtr)\sStatusField = formatMidiText(sMidiInName, txt, txt2)
                    gaMidiControl(nPhysicalDevPtr)\nStatusType = #SCS_STATUS_INCOMING_COMMAND
                  EndIf
                EndIf
                gbInExternalControl = #True
                Select nAction
                  Case #SCS_MIDI_PLAY_CUE
                    debugMsgC(sProcName, "calling processMidiOrDMXPlayCueCmd(" + nPhysicalDevPtr + ", " + sMidiCue + ")")
                    bIgnoreInputMsg = processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, sMidiCue)
                    If msgType = $B
                      bTurnButtonOff = #True
                    EndIf
                    
                  Case #SCS_MIDI_PAUSE_RESUME_CUE
                    processMidiPauseResumeCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_RELEASE_CUE
                    processMidiReleaseCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_FADE_OUT_CUE
                    processMidiFadeOutCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_STOP_CUE
                    debugMsg(sProcName, "calling processMidiStopCueCmd(" + sMidiCue + ")")
                    processMidiStopCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_GO_TO_CUE
                    processMidiGoToCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_LOAD_CUE
                    processMidiLoadCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_UNLOAD_CUE
                    processMidiUnloadCueCmd(sMidiCue)
                    
                  Case #SCS_MIDI_GO_BUTTON
                    bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nAction)
                    If bIgnoreInputMsg = #False
                      processMidiGoButtonCmd(nPhysicalDevPtr)
                    EndIf
                    
                  Case #SCS_MIDI_STOP_ALL
                    ; stopEverythingPart1()
                    processStopAll() ; Changed 19May2025 11.10.8ba2
                    
                  Case #SCS_MIDI_FADE_ALL ; 7May2022 11.9.1
                    processFadeAll()
                    
                  Case #SCS_MIDI_PAUSE_RESUME_ALL
                    bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nAction)
                    If bIgnoreInputMsg = #False
                      processPauseResumeAll()
                    EndIf
                    
                  Case #SCS_MIDI_GO_TO_TOP
                    nCuePtr = getFirstEnabledCue()
                    GoToCue(nCuePtr)
                    debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
                    calcCueStartValues(nCuePtr)
                    
                  Case #SCS_MIDI_GO_BACK
                    WMN_prevCue()
                    
                  Case #SCS_MIDI_GO_TO_NEXT
                    WMN_nextCue()
                    
                  Case #SCS_MIDI_PAGE_UP
                    WMN_reposCueList(#SCS_WMNF_CueListUpOnePage)
                    
                  Case #SCS_MIDI_PAGE_DOWN
                    WMN_reposCueList(#SCS_WMNF_CueListDownOnePage)
                    
                  Case #SCS_MIDI_MASTER_FADER
                    debugMsgC(sProcName, "MASTER_FADER, vv=" + vv)
                    fNewLevel = SLD_SliderValueToBVLevel(#SCS_MAXVOLUME_SLD * vv / 127)
                    debugMsgC(sProcName, "calling SLD_setLevel(WMN\sldMasterFader, " + StrF(fNewLevel) + ")")
                    SLD_setLevel(WMN\sldMasterFader, fNewLevel)
                    debugMsgC(sProcName, "calling setMasterFader(" + StrF(fNewLevel) + ")")
                    setMasterFader(fNewLevel)
                    debugMsgC(sProcName, "MASTER_FADER complete")
                    
                  Case #SCS_MIDI_GO_CONFIRM
                    confirmGo(#SCS_GOCONFIRM_MIDI)
                    
                  Case #SCS_MIDI_OPEN_FAV_FILE
                    processOpenFavFile(vv)
                    
                  Case #SCS_MIDI_SET_HOTKEY_BANK
                    debugMsg(sProcName, "calling setHotkeyBank(" + vv + ")")
                    setHotkeyBank(vv)
                    
                  Case #SCS_MIDI_TAP_DELAY
                    DMX_processTapDelayShortcutOrCommand()
                    
                  Case #SCS_MIDI_EXT_FADER
                    DMX_processExtFader(nMidiCuePtr, nPhysicalDevPtr, vv)
                    
                  Case #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER
                    ; debugMsg0(sProcName, decodeMidiCommand(nAction) + ", vv=" + vv)
                    fNewLevel = SLD_SliderValueToBVLevel(#SCS_MAXVOLUME_SLD * vv / 127)
                    nAudNo = nAction - #SCS_MIDI_DEVICE_1_FADER
                    ; debugMsg0(sProcName, "WCN_getControllerIndex(#SCS_CTRLTYPE_PLAYING, " + Str(nAction - #SCS_MIDI_DEVICE_1_FADER) + ") returned " + WCN_getControllerIndex(#SCS_CTRLTYPE_PLAYING, (nAction - #SCS_MIDI_DEVICE_1_FADER)))
                    nDevMapDevPtr = getDevMapDevPtrForDevNo(#SCS_DEVGRP_AUDIO_OUTPUT, nAudNo)
                    If IsWindow(#WCN) And (grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_C Or grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_C Or grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_C)
                      nEarliestPlayingSubPtr = getEarliestPlayingSubTypeF()
                      If nEarliestPlayingSubPtr >= 0
                        If aSub(nEarliestPlayingSubPtr)\bSubTypeA
                          ; continue with just type F until we have sorted out better how to handle a video audio fader
                        Else
                          nAudPtr = aSub(nEarliestPlayingSubPtr)\nFirstAudIndex
                          For d = aAud(nAudPtr)\nFirstDev To aAud(nAudPtr)\nLastDev
                            If aAud(nAudPtr)\sLogicalDev[d] = grMaps\aDev(nDevMapDevPtr)\sLogicalDev
                              nCtrlNo = WCN_getCtrlNoForLogicalDev(#SCS_CTRLTYPE_PLAYING, aAud(nAudPtr)\sLogicalDev[d])
                              If WCN_getSliderValueMatched(#SCS_CTRLTYPE_PLAYING, nCtrlNo)
                                ; debugMsg(sProcName, "calling setLevelsAny(" + getAudLabel(nAudPtr) + ", " + d + ", " + traceLevel(fNewLevel) + ", #SCS_NOPANCHANGE_SINGLE)")
                                setLevelsAny(nAudPtr, d, fNewLevel, #SCS_NOPANCHANGE_SINGLE)
                              EndIf
                              Break
                            EndIf
                          Next d
                        EndIf
                      Else
                        ; no currently playing sub type F
                      EndIf
                    ElseIf WCN\nNrOfControllers > 0
                      ; debugMsg0(sProcName, "WCN\nNrOfControllers=" + WCN\nNrOfControllers)
                      grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain = fNewLevel
                      grMaps\aDev(nDevMapDevPtr)\sDevFaderOutputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fDevFaderOutputGain, #False, #True)
                      ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\sDevFaderOutputGainDB=" + grMaps\aDev(nDevMapDevPtr)\sDevFaderOutputGainDB)
                      ; debugMsg0(sProcName, "calling setAudioDevOutputGain(" + nAudNo + ")")
                      setAudioDevOutputGain(nAudNo)
                      ; WCN_setAudioOutputFader(grMaps\aDev(nDevMapDevPtr)\sLogicalDev, fNewLevel, #False) ; Commented out 15Oct2023 11.10.0ck following test using the NK2 where the output (not 'master') faders did not wait for the NK2 slider position to match the SCS fader level
                      ; Reinstated 11May2024 11.10.2cp but not if an external controller is specified - this following email from Tim Crump who was just using MIDI received by an SCS MIDI Cue Control device.
                      ; debugMsg0(sProcName, "grCtrlSetup\nController=" + decodeController(grCtrlSetup\nController))
                      Select grCtrlSetup\nController
                        Case #SCS_CTRL_NONE, #SCS_CTRL_MIDI_CUE_CONTROL
                          WCN_setAudioOutputFader(grMaps\aDev(nDevMapDevPtr)\sLogicalDev, fNewLevel, #False)
                      EndSelect
                    Else
                      grMaps\aDev(nDevMapDevPtr)\fDevOutputGain = fNewLevel
                      grMaps\aDev(nDevMapDevPtr)\sDevOutputGainDB = convertBVLevelToDBString(grMaps\aDev(nDevMapDevPtr)\fDevOutputGain, #False, #True)
                      ; debugMsg(sProcName, "grMaps\aDev(" + nDevMapDevPtr + ")\sDevOutputGainDB=" + grMaps\aDev(nDevMapDevPtr)\sDevFaderOutputGainDB)
                      ; debugMsg0(sProcName, "calling setAudioDevOutputGain(" + nAudNo + ")")
                      setAudioDevOutputGain(nAudNo)
                      If gnVisMode = #SCS_VU_LEVELS
                        ; need to call displayLabels() as this procedure also sets gaMeterBar(nOutputNr)\fVUOutputGain which is used in correctly displaying the VU levels and output gain markers
                        displayLabels()
                      EndIf
                    EndIf
                    
                  Case #SCS_MIDI_DIMMER_1_FADER To #SCS_MIDI_DIMMER_LAST_FADER ; Added 18Jul2022 11.9.4
                    nDimmerFaderValue = (vv * 100) / 127
                    nDimmerController = nAction - #SCS_MIDI_DIMMER_1_FADER
                    If WCN\nDimmerChanCtrls > 0
                      ; debugMsg0(sProcName, "calling WCN_setFader(#SCS_CTRLTYPE_DIMMER_CHANNEL, " + nDimmerController + ", " + nDimmerFaderValue + ", #False)")
                      WCN_setFader(#SCS_CTRLTYPE_DIMMER_CHANNEL, nDimmerController, nDimmerFaderValue, #False)
                    EndIf
                    
                  Case #SCS_MIDI_DMX_MASTER
                    grDMXMasterFader\nDMXMasterFaderValue = (vv * 100) / 127
                    DMX_setDMXMasterFader(grDMXMasterFader\nDMXMasterFaderValue)
                    If WCN\nNrOfControllers > 0
                      WCN_setFader(#SCS_CTRLTYPE_DMX_MASTER, 0, grDMXMasterFader\nDMXMasterFaderValue, #False)
                    EndIf
                    
                  Case #SCS_MIDI_CUE_MARKER_PREV ; 3May2022 11.9.1
                    skipCueMarker(#SCS_WMNF_CueMarkerPrev)
                    
                  Case #SCS_MIDI_CUE_MARKER_NEXT ; 3May2022 11.9.1
                    skipCueMarker(#SCS_WMNF_CueMarkerNext)
                    
                EndSelect
                gbInExternalControl = #False
              EndIf
              
              ;midiOutShortMsg hMidiOUT, gaMidiIns(n).dw1 ' send data = Thru-function
            Case #MM_MIM_LONGDATA
              ;{
              txt = "SysEx "
              debugMsgC(sProcName, "txt=" + txt)
              ; SysEx format: F0 7F <Device-ID> <Sub-ID#1> [<Sub-ID#2> [<parameters>]] F7
              ; Device-ID 7F = all devices
              ; Sub-ID#1:
              ; 01 = Long Form MTC (F0 7F 7F 01 01 hh mm ss ff F7)
              ; 02 = MIDI Show Control
              ; 03 = Notation Information
              ; 04 = Device Control
              ; 05 = Real Time MTC Cueing
              ; 06 = MIDI Machine Control Command
              ; 07 = MIDI Machine Control Response
              ; 08 = Single Note Retune
              bMTCMsg = #True   ; two or all of these will be set #False later
              bMSCMsg = #True
              bMMCMsg = #True
              nTimeCode = 0
              bGettingQNumber = #False
              bGettingQList = #False
              bGettingQPath = #False
              sQNumber = ""
              sQList = ""
              sQPath = ""
              nMSCCommand = $FF
              nMMCCommand = $00
              
              nBytesRecorded = gaMidiInHdr(\nPhysicalDevPtr)\dwBytesRecorded
              For ct = 0 To nBytesRecorded - 1
                aOneByte = PeekA(*gMidiInData+ct)
                sChar = Hex(aOneByte)
                ; debugMsg(sProcName, "ct=" + Str(ct) + ", aOneByte=$" + Hex(aOneByte) + ", sChar=" + sChar + ", bMTCMsg=" + strB(bMTCMsg))
                If Len(sChar) = 1
                  sChar = "0" + sChar
                EndIf
                If sChar <> "F7" ;not F7 EOX
                  txt + sChar + " "
                  PokeA(*gMidiInData+ct, 0)
                Else
                  txt + sChar
                  PokeA(*gMidiInData+ct, 0)
                EndIf
                Select ct
                  Case 0
                    ; SysEx byte(0) F0 = start of System Exclusive Message
                    If aOneByte <> $F0
                      bMTCMsg = #False
                      bMSCMsg = #False
                      bMMCMsg = #False
                    EndIf
                  Case 1
                    ; SysEx byte(1) F7 = start of message
                    If aOneByte <> $7F
                      bMTCMsg = #False
                      bMSCMsg = #False
                      bMMCMsg = #False
                    EndIf
                  Case 2
                    ; SysEx byte(2) device ID (for MSC / MMC), or &H7F = all devices if MSC
                    If aOneByte <> $7F
                      bMTCMsg = #False
                    EndIf
                    If aOneByte <> nMscMmcMidiDevId And aOneByte <> $7F
                      bMSCMsg = #False
                      bMMCMsg = #False
                    EndIf
                  Case 3
                    ; SysEx byte(3) 02 = indicates SysEx MIDI Show Control (MSC); 06 = indicates SysEx MIDI Machine Control (MMC)
                    If aOneByte <> $01
                      bMTCMsg = #False
                    EndIf
                    If aOneByte <> $02
                      bMSCMsg = #False
                    EndIf
                    If aOneByte <> $06
                      bMMCMsg = #False
                    EndIf
                  Case 4
                    ; SysEx byte(4) MSC: command format (7F = all types); MMC: command
                    If bMTCMsg
                      If aOneByte <> $01
                        bMTCMsg = #False
                      EndIf
                    ElseIf bMSCMsg
                      If aOneByte <> nMscCommandFormat And aOneByte <> $7F
                        bMSCMsg = #False
                      EndIf
                    ElseIf bMMCMsg
                      nMMCCommand = aOneByte
                    EndIf
                  Case 5
                    ; SysEx byte(5) MSC: command; MMC: end of msg
                    If bMTCMsg
                      nTimeCode = (aOneByte & $1F) << 24  ; hours (ignore frame rate)
                      ; debugMsg(sProcName, "ct=" + ct + ", nTimeCode=$" + Hex(nTimeCode,#PB_Long))
                    ElseIf bMSCMsg
                      nMSCCommand = aOneByte
                      bGettingQNumber = #True
                    ElseIf bMMCMsg
                      If aOneByte = $F7
                        Break    ; end of SysEx
                      Else
                        bMMCMsg = #False
                        Break
                      EndIf
                    EndIf
                  Default
                    If aOneByte = $F7
                      If bMTCMsg
                        bMTCFullFrame = #True
                        grMTCControl\nTimeCode = nTimeCode
                        debugMsg(sProcName, "grMTCControl\nTimeCode=" + decodeMTCTime(grMTCControl\nTimeCode) + " ($" + Hex(grMTCControl\nTimeCode,#PB_Long) + ")")
                        grMTCControl\nPrevTimeCodeProcessed = adjustMTCBySeconds(nTimeCode, -1)
                        grMTCControl\nMidiPhysicalDevPtr = nPhysicalDevPtr
                        grMTCControl\sMidiInName = sMidiInName
                        grMTCControl\bMTCControlActive = #True
                        ; debugMsg(sProcName, "bMTCMsg=" + strB(bMTCMsg) +
                        ;                     ", nTimeCode=" + decodeMTCTime(nTimeCode) + " ($" + Hex(nTimeCode,#PB_Long) + ")" +
                        ;                     ", grMTCControl\nPrevTimeCodeProcessed=" + decodeMTCTime(grMTCControl\nPrevTimeCodeProcessed) + " ($" + Hex(grMTCControl\nPrevTimeCodeProcessed,#PB_Long) + ")" +
                        ;                     ", grMTCControl\bMTCControlActive=" + strB(grMTCControl\bMTCControlActive))
                        txt + " MTC Full Frame " + decodeMTCTime(nTimeCode)
                      EndIf
                      Break    ; end of SysEx
                    EndIf
                    
                    If bMTCMsg
                      Select ct
                        Case 6
                          nTimeCode | (aOneByte << 16)  ; minutes
                        Case 7
                          nTimeCode | (aOneByte << 8)   ; seconds
                        Case 8
                          nTimeCode | aOneByte          ; frames
                      EndSelect
                      ; debugMsg(sProcName, "ct=" + ct + ", nTimeCode=$" + Hex(nTimeCode,#PB_Long))
                      
                    Else
                      
                      If nMSCCommand = $7 And ct = 6
                        ; MSC FIRE macro number
                        sQNumber = Trim(Str(aOneByte))
                        bGettingQNumber = #False
                      EndIf
                      
                      If bGettingQNumber
                        If aOneByte = 0
                          bGettingQNumber = #False
                          bGettingQList = #True
                        Else
                          If sChar >= "30" And sChar <= "39"
                            sQNumber + Right(sChar, 1)
                          ElseIf sChar = "2E"
                            sQNumber + "."
                          Else
                            bMSCMsg = #False
                          EndIf
                        EndIf
                        
                      ElseIf bGettingQList
                        If aOneByte = 0
                          bGettingQList = #False
                          bGettingQPath = #True
                        Else
                          If sChar >= "30" And sChar <= "39"
                            sQList + Right(sChar, 1)
                          ElseIf sChar = "2E"
                            sQList + "."
                          Else
                            bMSCMsg = #False
                          EndIf
                        EndIf
                        
                      ElseIf bGettingQPath
                        If sChar >= "30" And sChar <= "39"
                          sQPath + Right(sChar, 1)
                        ElseIf sChar = "2E"
                          sQPath + "."
                        Else
                          bMSCMsg = #False
                        EndIf
                      EndIf
                      
                    EndIf
                    
                EndSelect
                
              Next ct
              
              If bMSCMsg
                debugMsgC(sProcName, "bMSCMsg=" + strB(bMSCMsg) + ", nMSCCommand=$" + Hex(nMSCCommand,#PB_Byte))
              ElseIf bMMCMsg
                debugMsgC(sProcName, "bMMCMsg=" + strB(bMMCMsg) + ", nMMCCommand=$" + Hex(nMMCCommand,#PB_Byte))
              EndIf
              
              If bMSCMsg  ; MSC
                sMidiCue = sQNumber
                txt2 = "MSC "
                If nMSCCommand <= $1E And nMSCCommand >= 0
                  txt2 + "Command = " + gaMSCSoundCommand(nMSCCommand)
                EndIf
                If nMSCCommand = $07 ; command 07H = FIRE
                  If sQNumber
                    txt2 + ", Macro = " + sQNumber
                  EndIf
                  If sMidiCue = Str(nGoMacro)
                    sMidiCue = ""
                    txt2 + " GO"
                  EndIf
                Else
                  If sQNumber
                    txt2 + ", Q_number = " + sQNumber
                  EndIf
                  If sQList
                    txt2 + ", Q_list = " + sQList
                  EndIf
                  If sQPath
                    txt2 + ", Q_path = " + sQPath
                  EndIf
                EndIf
                
                If gbMidiTestWindow = #False And gbCapturingNRPN = #False
                  gbInExternalControl = #True
                  Select nMSCCommand
                    Case $01 ; command 01H = GO
                      debugMsgC(sProcName, "calling processMidiOrDMXPlayCueCmd(" + nPhysicalDevPtr + ", " + sMidiCue + ")")
                      processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, sMidiCue)
                    Case $02 ; command 02H = STOP
                      debugMsgC(sProcName, "calling processMidiStopCueCmd(" + sMidiCue + ")")
                      processMidiStopCueCmd(sMidiCue)
                    Case $07 ; command 07H = FIRE
                      debugMsgC(sProcName, "calling processMidiOrDMXPlayCueCmd(" + nPhysicalDevPtr + ", " + sMidiCue + ")")
                      processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, sMidiCue)
                  EndSelect
                  gbInExternalControl = #False
                EndIf
                
              ElseIf bMMCMsg  ; MMC
                txt2 = "MMC "
                If nMMCCommand <= $47
                  If gaMMCCommand(nMMCCommand)
                    txt2 + "Command = " + gaMMCCommand(nMMCCommand)
                  EndIf
                EndIf
                If gbMidiTestWindow = #False And gbCapturingNRPN = #False
                  gbInExternalControl = #True
                  Select nMMCCommand
                    Case $01                                            ; MMC command 01H = Stop
                      bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nMMCCommand)
                      If bIgnoreInputMsg = #False
                        If gaMidiControl(nPhysicalDevPtr)\bMMCApplyFadeForStop
                          processMidiFadeOutCueCmd("")                  ; SCS fade all
                        Else
                          processMidiStopCueCmd("")                     ; SCS stop all
                        EndIf
                      EndIf
                      
                    Case $02                                            ; MMC command 02H = Play
                      bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nMMCCommand)
                      If bIgnoreInputMsg = #False
                        debugMsgC(sProcName, "calling processMidiOrDMXPlayCueCmd(" + nPhysicalDevPtr + ", '')")
                        processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, "") ; SCS go if ok
                      EndIf
                      
                    Case $03                                            ; MMC command 03H = Deferred Play
                      bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nMMCCommand)
                      If bIgnoreInputMsg = #False
                        debugMsgC(sProcName, "calling processMidiOrDMXPlayCueCmd(" + nPhysicalDevPtr + ", '')")
                        processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, "") ; SCS go if ok
                      EndIf
                      
                    Case $04                                            ; MMC command 04H = Fast Forward
                      processMidiNextCueCmd()                           ; SCS next cue
                      
                    Case $05                                            ; MMC command 05H = Rewind
                      processMidiPrevCueCmd()                           ; SCS prev cue
                      
                    Case $09                                            ; MMC command 09H = Pause
                      bIgnoreInputMsg = ignoreRequestIfWithinDoubleClickTime(nMMCCommand)
                      If bIgnoreInputMsg = #False
                        processMidiPauseResumeCueCmd("")                ; SCS pause/resume all
                      EndIf
                  EndSelect
                  gbInExternalControl = #False
                  
                ElseIf gbMidiTestWindow ; Added 14Feb2024 11.10.2an
                  Select nMMCCommand
                    Case $01                                            ; MMC command 01H = Stop
                      If gaMidiControl(nPhysicalDevPtr)\bMMCApplyFadeForStop
                        txt3 = "SCS = Fade All"
                      Else
                        txt3 = "SCS = Stop All"
                      EndIf
                      
                    Case $02, $03                                       ; MMC command 02H = Play, 03H = Deferred Play
                      txt3 = "SCS = Go"
                      
                    Case $04                                            ; MMC command 04H = Fast Forward
                      txt3 = "SCS = Next Cue"
                      
                    Case $05                                            ; MMC command 05H = Rewind
                      txt3 = "SCS = Previous Cue"
                      
                    Case $09                                            ; MMC command 09H = Pause
                      txt3 = "SCS = Pause/Resume All"
                  EndSelect
                EndIf
                
              EndIf
              
              nMidiError = midiInUnprepareHeader_(gaMidiInDevice(nPhysicalDevPtr)\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
              debugMsg2(sProcName, "midiInUnprepareHeader_(" + gaMidiInDevice(nPhysicalDevPtr)\hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
              ;If nMidiError <> #MMSYSERR_NOERROR Then
              ;  ShowMMErr sProcName, "midiInUnprepareHeader", nMidiError
              ;End If
              
              gaMidiInHdr(nPhysicalDevPtr)\lpData = *gMidiInData
              gaMidiInHdr(nPhysicalDevPtr)\dwBufferLength = length
              gaMidiInHdr(nPhysicalDevPtr)\dwBytesRecorded = 0
              gaMidiInHdr(nPhysicalDevPtr)\dwUser = 0
              gaMidiInHdr(nPhysicalDevPtr)\dwFlags = 0
              ;prepare a buffer for MIDI input
              nMidiError = midiInPrepareHeader_(gaMidiInDevice(nPhysicalDevPtr)\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
              debugMsg2(sProcName, "midiInPrepareHeader_(" + gaMidiInDevice(nPhysicalDevPtr)\hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
              If nMidiError <> #MMSYSERR_NOERROR
                ShowMMErr(sProcName, "midiInPrepareHeader", nMidiError)
              EndIf
              
              ;send an input buffer to midi input dev
              nMidiError = midiInAddBuffer_(gaMidiInDevice(nPhysicalDevPtr)\hMidiIn, @gaMidiInHdr(nPhysicalDevPtr), SizeOf(MIDIHDR))
              debugMsg2(sProcName, "midiInAddBuffer_(" + gaMidiInDevice(nPhysicalDevPtr)\hMidiIn + ", @gaMidiInHdr(" + nPhysicalDevPtr + "), " + SizeOf(MIDIHDR) + ")", nMidiError)
              If nMidiError <> #MMSYSERR_NOERROR
                ShowMMErr(sProcName, "midiInAddBuffer", nMidiError)
              EndIf
              ;}
              
            Case #MM_MIM_ERROR
              txt = "error " + Hex(gaMidiIns(n)\dw1) + " " + Hex(gaMidiIns(n)\dw2)
              
            Case #MM_MIM_LONGERROR
              txt = "longerror"
              
            Default
              txt = "???"
              
          EndSelect
          debugMsgC(sProcName, "txt = " + txt + ", txt2 = " + txt2+ ", txt3 = " + txt3 + ", bMTCFullFrame=" + strB(bMTCFullFrame))
          
        EndIf   ; EndIf \bNRPN / False
        
        ; debugMsg(sProcName, "grCtrlSetup\bUseExternalController=" + strB(grCtrlSetup\bUseExternalController) + ", grCtrlSetup\nCtrlMidiInPhysicalDevPtr=" + grCtrlSetup\nCtrlMidiInPhysicalDevPtr + ", \nPhysicalDevPtr=" + nPhysicalDevPtr)
        If grCtrlSetup\bUseExternalController
          If grCtrlSetup\nCtrlMidiInPhysicalDevPtr = \nPhysicalDevPtr
            bCheckForControllerMsg = #True
            ; debugMsg(sProcName, "bCheckForControllerMsg=" + strB(bCheckForControllerMsg) + ", sMidiCue=" + sMidiCue)
            If sMidiCue
              If getMidiCuePtr(sMidiCue) >= 0
                bCheckForControllerMsg = #False
                If msgType = $B
                  SendCtrlChange(grCtrlSetup\nCtrlMidiOutPhysicalDevPtr, kk, 0, 1, #False) ; turn button off
                  bTurnButtonOff = #False
                EndIf
              EndIf
            EndIf
            If bCheckForControllerMsg
              ; debugMsg(sProcName, "calling processMidiControllerMsg()")
              nLogEntry = processMidiControllerMsg()
              If nLogEntry >= 0
                txt2 = decodeControllerLogEntry(nLogEntry)
              EndIf
            EndIf
          EndIf
        EndIf
        
        If txt And bIgnoreInputMsg = #False
          debugMsgC(sProcName, "txt = " + txt)
          If gbMidiTestWindow
            If txt3
              WMT_addListItem(sMidiInName, txt, txt2 + " (" + txt3 + ")")
            Else
              WMT_addListItem(sMidiInName, txt, txt2)
            EndIf
            If bMTCFullFrame
              ; debugMsg(sProcName, "calling checkArrayCueOrSubForMTC()")
              checkArrayCueOrSubForMTC()
            EndIf
          ElseIf bMTCFullFrame
            ; debugMsg(sProcName, "calling checkArrayCueOrSubForMTC()")
            checkArrayCueOrSubForMTC()
            If gaMidiControl(nPhysicalDevPtr)\nStatusType < 0
              gaMidiControl(nPhysicalDevPtr)\sStatusField = formatMidiText(sMidiInName, txt, txt2)
              gaMidiControl(nPhysicalDevPtr)\nStatusType = #SCS_STATUS_INCOMING_COMMAND
            EndIf
          ElseIf bMSCMsg
            If gaMidiControl(nPhysicalDevPtr)\nStatusType < 0
              gaMidiControl(nPhysicalDevPtr)\sStatusField = formatMidiText(sMidiInName, txt, txt2)
              gaMidiControl(nPhysicalDevPtr)\nStatusType = #SCS_STATUS_INCOMING_COMMAND
            EndIf
          EndIf
        EndIf ; EndIf txt And bIgnoreInputMsg = #False
      EndIf ; EndIf (\bDone = #False) And (\nPhysicalDevPtr >= 0)
      
      \bDone = #True
      gaMidiIns(n) = grMidiIn
      
    EndWith
  Next n
  
  If bIgnoreInputMsg = #False
    Select nAction 
      Case #SCS_MIDI_EXT_FADER, #SCS_MIDI_DEVICE_1_FADER To #SCS_MIDI_DEVICE_LAST_FADER, #SCS_MIDI_DMX_MASTER, #SCS_MIDI_MASTER_FADER
        ; do not display in status line
      Case -1
        ; nAction not set - do not display in status line
      Default
        With gaMidiControl(nPhysicalDevPtr)
          If \nStatusType > 0
            debugMsg(sProcName, "calling WMN_setStatusField(" + \sStatusField + ", " + \nStatusType + ")")
            WMN_setStatusField(\sStatusField, \nStatusType)
          EndIf
        EndWith
    EndSelect
  EndIf
  
  If gbMidiInLocked
    ; debugMsg(sProcName, "exit b")
    ProcedureReturn
  EndIf
  
  nCount = 0
  For n = 0 To gnMidiInCount - 1
    If gaMidiIns(n)\bDone = #False
      nCount + 1
    EndIf
  Next n
  If nCount = 0
    gnMidiInCount = 0
    gbTooManyMessages = #False
  EndIf
  
  If bLogEnd Or gnMidiInCount > 0
    debugMsgC(sProcName, #SCS_END + ", gnMidiInCount=" + gnMidiInCount)
  EndIf
  
EndProcedure

Procedure setActionAndCue(nPhysicalDevPtr, pMsgType, pKK, pVV, *nMidiCuePtr)
  PROCNAMEC()
  Protected nAction, sMidiCue.s, n
  Protected nNoteAction, sNoteMidiCue.s
  Protected nCuePtr, j, k, bFadeOut
  
  ; debugMsg(sProcName, "pMsgType=$" + Hex(pMsgType) + ", pKK=" + pKK + ", pVV=" + pVV)
  
  With gaMidiControl(nPhysicalDevPtr)
    nAction = -1
    
    If grLicInfo\bExtFaderCueControlAvailable And pMsgType = $B
      If \aMidiCommand[#SCS_MIDI_EXT_FADER]\nCmd >= 0
        nCuePtr = getCuePtrForExtFaderCC(pKK)
        If nCuePtr >= 0
          nAction = #SCS_MIDI_EXT_FADER
          sMidiCue = Str(nCuePtr)
          PokeI(*nMidiCuePtr, nCuePtr)
        EndIf
      EndIf
    EndIf
    
    If nAction = -1 And (pMsgType = $A Or pMsgType = $B) ; key pressure or controller change
      ; check global settings first
      For n = #SCS_MIDI_LAST_SCS_CUE_RELATED + 1 To gnMaxMidiCommand
        If \aMidiCommand[n]\nCmd = pMsgType
          If (\aMidiCommand[n]\nCC = pKK) And ((\aMidiCommand[n]\nVV = pVV) Or (\aMidiCommand[n]\nVV = #SCS_MIDI_ANY_VALUE))
            nAction = n
            Break
          EndIf
        EndIf
      Next n
      
      If nAction = -1
        If \nCtrlMethod = #SCS_CTRLMETHOD_ETC_AB
          If (pKK >= 70 And pKK <= 76)
            If (pKK = 70 And pVV = 0)
              nAction = #SCS_MIDI_GO_BUTTON
            Else
              nAction = #SCS_MIDI_PLAY_CUE
              sMidiCue = Str(128 + ((pKK - 70) * 128) + pVV)
            EndIf
          EndIf
          
        ElseIf \nCtrlMethod = #SCS_CTRLMETHOD_ETC_CD
          If (pKK >= 77 And pKK <= 84)
            If (pKK = 77 And pVV = 0)
              nAction = #SCS_MIDI_GO_BUTTON
            Else
              nAction = #SCS_MIDI_PLAY_CUE
              sMidiCue = Str(((pKK - 77) * 128) + pVV)
            EndIf
          EndIf
        EndIf
        
      EndIf
      
      If nAction = -1
        For n = 0 To #SCS_MAX_MIDI_COMMAND
          If \aMidiCommand[n]\nCmd = pMsgType
            If n <= #SCS_MIDI_LAST_SCS_CUE_RELATED
              If \aMidiCommand[n]\nCC = pKK
                nAction = n
                sMidiCue = Str(pVV)
                Break
              EndIf
            ElseIf (n = #SCS_MIDI_MASTER_FADER) Or (n = #SCS_MIDI_OPEN_FAV_FILE) Or (n = #SCS_MIDI_SET_HOTKEY_BANK) Or (n >= #SCS_MIDI_DEVICE_1_FADER And n <= #SCS_MIDI_DEVICE_LAST_FADER) Or
                   (n = #SCS_MIDI_DMX_MASTER) Or (n >= #SCS_MIDI_DIMMER_1_FADER And n <= #SCS_MIDI_DIMMER_LAST_FADER) Or
                   (n = #SCS_MIDI_CUE_MARKER_PREV) Or (n = #SCS_MIDI_CUE_MARKER_NEXT)
              ; debugMsg(sProcName, "n=" + n +", pKK=" + pKK + ", pVV=" + pVV)
              If \aMidiCommand[n]\nCC = pKK
                nAction = n
                Break
              EndIf
            Else
              If (\aMidiCommand[n]\nCC = pKK) And ((\aMidiCommand[n]\nVV = pVV) Or (\aMidiCommand[n]\nVV = #SCS_MIDI_ANY_VALUE))
                nAction = n
                Break
              EndIf
            EndIf
          EndIf
        Next n
      EndIf
      
    ElseIf pMsgType = $C ; program change
      ; work backwards thru array to check globals first
      For n = #SCS_MAX_MIDI_COMMAND To 0 Step -1
        If \aMidiCommand[n]\nCmd = pMsgType
          If n <= #SCS_MIDI_LAST_SCS_CUE_RELATED
            If \nBase = 1 And pKK > 0
              nAction = n
              sMidiCue = Str(pKK)
              ; debugMsg(sProcName, "\nBase=" + \nBase + ", pKK=" + pKK + ", sMidiCue=" + sMidiCue)
              Break
            ElseIf \nBase = 0 And pKK < 128
              nAction = n
              sMidiCue = Str(pKK + 1)
              ; debugMsg(sProcName, "\nBase=" + \nBase + ", pKK=" + pKK + ", sMidiCue=" + sMidiCue)
              Break
            EndIf
          ElseIf (n = #SCS_MIDI_MASTER_FADER) Or (n = #SCS_MIDI_OPEN_FAV_FILE) Or (n = #SCS_MIDI_SET_HOTKEY_BANK) Or (n >= #SCS_MIDI_DEVICE_1_FADER And n <= #SCS_MIDI_DEVICE_LAST_FADER) Or (n = #SCS_MIDI_DMX_MASTER) Or
                 (n = #SCS_MIDI_CUE_MARKER_PREV) Or (n = #SCS_MIDI_CUE_MARKER_NEXT) ; 3May2022 11.9.1
            nAction = n
            Break
          ElseIf \aMidiCommand[n]\nCC = pKK
            nAction = n
            Break
          EndIf
        EndIf
      Next n
      
    Else ; other types
      For n = (#SCS_MIDI_LAST_SCS_CUE_RELATED + 1) To #SCS_MAX_MIDI_COMMAND
        ; debugMsg(sProcName, "pMsgType=$" + Hex(pMsgType,#PB_Long) + ", \aMidiCommand[" + n + "]\nCmd=$" + Hex(\aMidiCommand[n]\nCmd,#PB_Long) +
        ;                     ", pKK=" + pKK + ", \aMidiCommand[" + n + "]\nCC=" + \aMidiCommand[n]\nCC)
        If (\aMidiCommand[n]\nCmd = pMsgType) And ((n = #SCS_MIDI_MASTER_FADER) Or (n >= #SCS_MIDI_DEVICE_1_FADER And n <= #SCS_MIDI_DEVICE_LAST_FADER) Or (n = #SCS_MIDI_DMX_MASTER)) And pMsgType = $E ; pitch bend
          ; Added 3Jan2025 11.0.6ce
          nAction = n
          Break
        ElseIf (\aMidiCommand[n]\nCmd = pMsgType) And (\aMidiCommand[n]\nCC = pKK)
          nAction = n
          Break
        EndIf
      Next n
      
      If nAction = -1
        For n = 0 To #SCS_MIDI_LAST_SCS_CUE_RELATED
          If \aMidiCommand[n]\nCmd = pMsgType
            nAction = n
            sMidiCue = Str(pKK)
            Break
          EndIf
        Next n
      EndIf
      
    EndIf
    
    If nAction = -1
      ; debugMsg(sProcName, "pMsgType=$" + Hex(pMsgType) + ", pVV=" + pVV + ", pKK=" + pKK)
      ; no match found yet
      ; the following code is for 'Note' hotkeys, and looks for a 'Note Off' to turn off the hotkey cue
      If pMsgType = $8 Or (pMsgType = $9 And pVV = 0)
        ; Note Off (or Note On with velocity 0)
        ; look for the corresponding Note On
        nNoteAction = -1
        sNoteMidiCue = ""
        For n = 0 To #SCS_MIDI_LAST_SCS_CUE_RELATED
          ; debugMsg(sProcName, "\aMidiCommand[" + n + "]\nCmd=$" + Hex(\aMidiCommand[n]\nCmd) + ", \aMidiCommand[" + n + "]\nCC=" + \aMidiCommand[n]\nCC)
          If \aMidiCommand[n]\nCmd = $9
            ; found a 'Note On' entry in the command array
            nNoteAction = n
            sNoteMidiCue = Str(pKK)
            Break
          EndIf
        Next n
        ; debugMsg(sProcName, "nNoteAction=" + nNoteAction + ", sNoteMidiCue=" + sNoteMidiCue)
        If nNoteAction >= 0
          nCuePtr = getCuePtrForMidiCue(sNoteMidiCue)
          If nCuePtr >= 0
            ; debugMsg(sProcName, "nCuePtr=" + getCueLabel(nCuePtr))
            Select aCue(nCuePtr)\nActivationMethod
              Case #SCS_ACMETH_HK_NOTE, #SCS_ACMETH_EXT_NOTE
                ; cue is a 'note' hotkey or external activated cue so return a 'fade' or 'stop' action for the 'note off' command
                nAction = #SCS_MIDI_FADE_OUT_CUE
                sMidiCue = sNoteMidiCue
            EndSelect
          EndIf
        EndIf
      EndIf
    EndIf
    
    If nAction = -1
      n = #SCS_MIDI_PLAY_CUE
      If pMsgType  = $B And \aMidiCommand[n]\nCmd = $200B And pVV > 0
        nAction = n
        sMidiCue = Str(pKK)
      EndIf
    EndIf
    
    If nAction = #SCS_MIDI_OPEN_FAV_FILE
      If pVV < 1 Or pVV > 20
        ; 'velocity' out of range for a favorite file number
        nAction = -1
      EndIf
    EndIf
    
    If nAction = #SCS_MIDI_SET_HOTKEY_BANK
      If pVV < 0 Or pVV > 12
        ; 'velocity' out of range for a hotkey bank number
        nAction = -1
      EndIf
    EndIf
    
  EndWith
  
  ; debugMsg(sProcName, "nAction=" + nAction + ", sMidiCue=" + sMidiCue + ", gbMidiTestWindow=" + strB(gbMidiTestWindow))
  
  gnMidiAction = nAction
  gsMidiCue = Trim(sMidiCue)
  
EndProcedure

Procedure.s setMidiCueForCueRelated(pMidiInPort, pMsgType, pKK, pVV)
  PROCNAMEC()
  Protected nAction, sMidiCue.s, n
  
  debugMsg(sProcName, "pMidiInPort=" + pMidiInPort + ", pMsgType=" + pMsgType + ", pKK=" + pKK + ", pVV=" + pVV)
  
  With gaMidiControl(pMidiInPort)
    
    nAction = -1
    
    If pMsgType = $B ; controller change
      If \nCtrlMethod = #SCS_CTRLMETHOD_ETC_AB
        If (pKK >= 70 And pKK <= 76)
          If (pKK = 70 And pVV = 0)
            nAction = #SCS_MIDI_GO_BUTTON
          ElseIf pVV >= 0
            nAction = #SCS_MIDI_PLAY_CUE
            sMidiCue = Str(128 + ((pKK - 70) * 128) + pVV)
          EndIf
        EndIf
        
      ElseIf \nCtrlMethod = #SCS_CTRLMETHOD_ETC_CD
        If (pKK >= 77 And pKK <= 84)
          If (pKK = 77 And pVV = 0)
            nAction = #SCS_MIDI_GO_BUTTON
          ElseIf pVV >= 0
            nAction = #SCS_MIDI_PLAY_CUE
            sMidiCue = Str(((pKK - 77) * 128) + pVV)
          EndIf
        EndIf
        
      EndIf
      
      For n = 0 To #SCS_MIDI_LAST_SCS_CUE_RELATED
        If \aMidiCommand[n]\nCmd = pMsgType
          If (\aMidiCommand[n]\nCC = pKK) And (pVV >= 0)
            nAction = n
            sMidiCue = Str(pVV)
            Break
          EndIf
        EndIf
      Next n
      
    ElseIf pMsgType = $C ; program change
      For n = 0 To #SCS_MIDI_LAST_SCS_CUE_RELATED
        If \aMidiCommand[n]\nCmd = pMsgType
          If (\nBase = 1) And (pKK > 0)
            nAction = n
            sMidiCue = Str(pKK)
            Break
          ElseIf (\nBase = 0) And (pKK < 128) And (pKK >= 0)
            nAction = n
            sMidiCue = Str(pKK + 1)
            Break
          EndIf
        EndIf
      Next n
      
    Else ; other types
      For n = 0 To #SCS_MIDI_LAST_SCS_CUE_RELATED
        If (\aMidiCommand[n]\nCmd = pMsgType) And (pKK >= 0)
          nAction = n
          sMidiCue = Str(pKK)
          Break
        EndIf
      Next n
      
    EndIf
    
  EndWith
  
  debugMsg(sProcName, "sMidiCue=" + sMidiCue)

  ProcedureReturn Trim(sMidiCue)

EndProcedure

Procedure MidiOut_Port(sOpenClose.s, nMidiOutPhysicalDevPtr, sReason.s)
  PROCNAME(#PB_Compiler_Procedure + "(" + sOpenClose + ")")
  Protected nMidiError.l   ; long
  Protected nMidiInDeviceId.l
  
  debugMsg(sProcName, #SCS_START + ", nMidiOutPhysicalDevPtr=" + nMidiOutPhysicalDevPtr + ", sReason=" + sReason)

  If nMidiOutPhysicalDevPtr >= 0
    With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
      
      debugMsg(sProcName, "sOpenClose=" + sOpenClose + ", gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\sName=" + \sName)
      
      If sOpenClose = "open"  ; "open"
        debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\bDummy=" + strB(\bDummy) + ", \bMidiFilePlayback=" + strB(\bMidiFilePlayback) +
                            ", \bWindowsMidiCompatible=" + strB(\bWindowsMidiCompatible))
        If \bDummy
          \bInitialized = #True
          \hMidiOut = 0
        ElseIf \bMidiFilePlayback And 1=2 ; added this test 10Nov2015 11.4.1.2h
          ; note: the midiOutPort must NOT be 'open' if a midi file is to be played through this port, mciSendString(play...) will return 337 (port in use)
          \bInitialized = #True
          \hMidiOut = 0
        ElseIf \bWindowsMidiCompatible = #False
          If \bEnttecMidi
          EndIf
        Else
          If \hMidiOut = 0
            ; port not currently open
            nMidiError = midiOutOpen_(@\hMidiOut, \nMidiDeviceID, 0, 0, #CALLBACK_NULL)
            debugMsg2(sProcName, "midiOutOpen_(@\hMidiOut, " + \nMidiDeviceID + ", 0, 0, CALLBACK_NULL)", nMidiError)
            debugMsg3(sProcName, "gaMidiOutDevice(" + \nMidiDeviceID + ")\hMidiOut=" + \hMidiOut)
            If nMidiError = #MMSYSERR_NOERROR
              \bInitialized = #True
            Else
              ShowMMErr(sProcName, "midiOutOpen_(@\hMidiOut, " + \nMidiDeviceID + ", 0, 0, CALLBACK_NULL)", nMidiError)
              \bInitialized = #False
              \hMidiOut = 0
              ProcedureReturn #False
            EndIf
          EndIf
        EndIf
        Select LCase(sReason)
          Case "ctrlsend"
            \bCtrlSend = #True
          Case "thruport"
            \bThruPort = #True
          Case "mtccues"
            \bMTCCuesPort = #True
          Case "controllerportout"
            \bControllerPort = #True
        EndSelect
        debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\sName=" + \sName + ", \bCtrlSend=" + strB(\bCtrlSend) + ", \bMTCCuesPort=" + strB(\bMTCCuesPort))
        
      Else  ; "close"
        Select LCase(sReason)
          Case "ctrlsend"
            \bCtrlSend = #False
          Case "thruport"
            \bThruPort = #False
          Case "mtccues"
            \bMTCCuesPort = #False
          Case "controllerportout"
            \bControllerPort = #False
          Case "all"
            \bCtrlSend = #False
            \bThruPort = #False
            \bMTCCuesPort = #False
            \bControllerPort = #False
        EndSelect
        debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\sName=" + \sName + ", \bCtrlSend=" + strB(\bCtrlSend) + ", \bMTCCuesPort=" + strB(\bMTCCuesPort))
        If ((\bCtrlSend = #False) And (\bThruPort = #False) And (\bMTCCuesPort = #False) And (\bControllerPort = #False)) Or (gbClosingDown)
          ; port can now be closed
          If \hMidiOut <> 0
            nMidiError = midiOutClose_(\hMidiOut)
            debugMsg2(sProcName, "midiOutClose_(" + \hMidiOut + ")", nMidiError)
            If nMidiError <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutClose_(" + \hMidiOut + ")", nMidiError)
              ProcedureReturn #False
            EndIf
            \hMidiOut = 0
          EndIf
          \bInitialized = #False
        EndIf
      EndIf
      
      debugMsg(sProcName, #SCS_END + ", hMidiOut=" + \hMidiOut)
      
    EndWith
  EndIf
  ProcedureReturn #True
EndProcedure

Procedure MidiThru_Port(sConnectDisconnect.s, nMidiInPhysicalDevPtr, nMidiOutPhysicalDevPtr)
  PROCNAME("MidiThru_Port(" + sConnectDisconnect + ")")
  Protected nMidiError.l ; long
  Protected hMidiIn.l, hMidiOut.l
  
  debugMsg(sProcName, #SCS_START + ", nMidiInPhysicalDevPtr=" + nMidiInPhysicalDevPtr + ", nMidiOutPhysicalDevPtr=" + nMidiOutPhysicalDevPtr)
  
  If (nMidiInPhysicalDevPtr >= 0) And (nMidiOutPhysicalDevPtr >= 0)
    
    hMidiIn = gaMidiInDevice(nMidiInPhysicalDevPtr)\hMidiIn
    hMidiOut = gaMidiOutDevice(nMidiOutPhysicalDevPtr)\hMidiOut
    
    If (hMidiOut <> 0) And (hMidiIn <> 0)
      
      If sConnectDisconnect = "connect"
        nMidiError = midiConnect_(hMidiIn, hMidiOut, 0)
        debugMsg2(sProcName, "midiConnect_(" + hMidiIn + ", " + hMidiOut + ", 0)", nMidiError)
        If nMidiError <> #MMSYSERR_NOERROR
          ShowMMErr(sProcName, "midiConnect_(" + hMidiIn + ", " + hMidiOut + ", 0)", nMidiError)
          ProcedureReturn #False
        EndIf
        
      Else  ; "disconnect"
        If hMidiIn <> 0
          nMidiError = midiDisconnect_(hMidiIn, hMidiOut, 0)
          debugMsg2(sProcName, "midiDisconnect_(" + hMidiIn + ", " + hMidiOut + ", 0)", nMidiError)
          If nMidiError <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiDisconnect_(" + hMidiIn + ", " + hMidiOut + ", 0)", nMidiError)
          EndIf
        EndIf
        
      EndIf
    EndIf
    
  EndIf
  ProcedureReturn #True
  
EndProcedure

Procedure openMidiPorts()
  PROCNAMEC()
  Protected nMidiInPhysicalDevPtr, nMidiOutPhysicalDevPtr
  Protected bWantThisPort, bOpenMTCCuesPort

  debugMsg(sProcName, #SCS_START + ", gnNumMidiInDevs=" + gnNumMidiInDevs + ", gnNumMidiOutDevs=" + gnNumMidiOutDevs)

  gbMidiInLocked = #False
  gnMidiInCount = 0
  gbTooManyMessages = #False
  
  For nMidiInPhysicalDevPtr = 0 To (gnNumMidiInDevs-1)
    With gaMidiInDevice(nMidiInPhysicalDevPtr)
      debugMsg(sProcName, "gaMidiInDevice(" + nMidiInPhysicalDevPtr + ")\sName=" + \sName + ", \bCueControl=" + strB(\bCueControl) + ", \bMidiCapture=" + strB(\bMidiCapture) + ", \bNRPNCapture=" + strB(\bNRPNCapture) +
                          ", \bConnectPort=" + strB(\bConnectPort) + ", \bDummy=" + strB(\bDummy))
      If \bDummy = #False
        bWantThisPort = #False
        ; note: MidiIn_Port("open", nMidiDeviceID, ...) must be called for each required 'reason', but the port is physically opened only once
        If \bCueControl
          bWantThisPort = #True
          debugMsgQ(sProcName, "calling MidiIn_Port('open', " + nMidiInPhysicalDevPtr + ", 'cuecontrol')")
          MidiIn_Port("open", nMidiInPhysicalDevPtr, "cuecontrol")
        EndIf
        If \bMidiCapture
          bWantThisPort = #True
          debugMsgQ(sProcName, "calling MidiIn_Port('open', " + nMidiInPhysicalDevPtr + ", 'midicapture')")
          MidiIn_Port("open", nMidiInPhysicalDevPtr, "midicapture")
        EndIf
        If \bNRPNCapture
          bWantThisPort = #True
          debugMsgQ(sProcName, "calling MidiIn_Port('open', " + nMidiInPhysicalDevPtr + ", 'nrpncapture')")
          MidiIn_Port("open", nMidiInPhysicalDevPtr, "nrpncapture")
        EndIf
        If \bConnectPort
          bWantThisPort = #True
          debugMsgQ(sProcName, "calling MidiIn_Port('open', " + nMidiInPhysicalDevPtr + ", 'connectport')")
          MidiIn_Port("open", nMidiInPhysicalDevPtr, "connectport")
        EndIf
        If grCtrlSetup\bUseExternalController
          If grCtrlSetup\sCtrlMidiInPort = \sName
            bWantThisPort = #True
            debugMsgQ(sProcName, "calling MidiIn_Port('open', " + nMidiInPhysicalDevPtr + ", 'controllerportin')")
            MidiIn_Port("open", nMidiInPhysicalDevPtr, "controllerportin")
            grCtrlSetup\nCtrlMidiInPhysicalDevPtr = nMidiInPhysicalDevPtr
            debugMsg(sProcName, "grCtrlSetup\nCtrlMidiInPhysicalDevPtr=" + grCtrlSetup\nCtrlMidiInPhysicalDevPtr)
          EndIf
        EndIf
        If bWantThisPort = #False
          If \hMidiIn
            debugMsgQ(sProcName, "calling MidiIn_Port('close', " + nMidiInPhysicalDevPtr + ", 'all')")
            MidiIn_Port("close", nMidiInPhysicalDevPtr, "all")
          EndIf
        EndIf
      EndIf ; EndIf \bDummy = #False
    EndWith
  Next nMidiInPhysicalDevPtr
  
  For nMidiOutPhysicalDevPtr = 0 To (gnNumMidiOutDevs-1)
    With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
      bWantThisPort = #False
      ; note: MidiOut_Port("open", nMidiOutPhysicalDevPtr, ...) must be called for each required 'reason', but the port is physically opened only once
      debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\sName=" + \sName + ", \bEnttecMidi=" + strB(\bEnttecMidi) + ", \bCtrlSend=" + strB(\bCtrlSend) +
                          ", \bMidiDevForMTC=" + strB(\bMidiDevForMTC) + ", \bThruPort=" + strB(\bThruPort) + ", \bDummy=" + strB(\bDummy))
      If \bDummy = #False
        If \bEnttecMidi
          If \bCtrlSend Or \bMidiDevForMTC
            debugMsg(sProcName, "calling DMX_openDMXDevForMidiOut(" + nMidiOutPhysicalDevPtr + ")")
            DMX_openDMXDevForMidiOut(nMidiOutPhysicalDevPtr)
            debugMsg(sProcName, "returned from DMX_openDMXDevForMidiOut(" + nMidiOutPhysicalDevPtr + "), \nFTHandle=" + \nFTHandle)
          EndIf
        Else
          If (\bCtrlSend) And (\bMidiDevForMTC = #False)  ; nb don't open MTC port because MTC Port must be opened separately by the MTC Cues thread
            bWantThisPort = #True
            debugMsgQ(sProcName, "calling MidiOut_Port('open', " + nMidiOutPhysicalDevPtr + ", 'ctrlsend')")
            MidiOut_Port("open", nMidiOutPhysicalDevPtr, "ctrlsend")
          EndIf
          If \bThruPort
            bWantThisPort = #True
            debugMsgQ(sProcName, "calling MidiOut_Port('open', " + nMidiOutPhysicalDevPtr + ", 'thruport')")
            MidiOut_Port("open", nMidiOutPhysicalDevPtr, "thruport")
            If \nMidiThruInPhysicalDevPtr >= 0
              debugMsgQ(sProcName, "calling MidiThru_Port('connect', " + \nMidiThruInPhysicalDevPtr + ", " + nMidiOutPhysicalDevPtr + ")")
              MidiThru_Port("connect", \nMidiThruInPhysicalDevPtr, nMidiOutPhysicalDevPtr)
            EndIf
          EndIf
          If grCtrlSetup\bUseExternalController
            Select grCtrlSetup\nController ; Select added 25Jun2022 11.9.4
              Case #SCS_CTRL_NK2
                ; no MIDI out port
              Default
                If grCtrlSetup\sCtrlMidiOutPort = \sName
                  bWantThisPort = #True
                  debugMsgQ(sProcName, "calling MidiOut_Port('open', " + nMidiOutPhysicalDevPtr + ", 'controllerportout')")
                  MidiOut_Port("open", nMidiOutPhysicalDevPtr, "controllerportout")
                  grCtrlSetup\nCtrlMidiOutPhysicalDevPtr = nMidiOutPhysicalDevPtr
                EndIf
            EndSelect
          EndIf
          ; nb don't open MTC port because MTC Port must be opened separately by the MTC Cues thread
          If bWantThisPort = #False
            If \bMTCCuesPort = #False
              If \hMidiOut
                debugMsgQ(sProcName, "calling MidiOut_Port('close', " + nMidiOutPhysicalDevPtr + ", 'all')")
                MidiOut_Port("close", nMidiOutPhysicalDevPtr, "all")
              EndIf
            EndIf
          EndIf
          If (\bMidiDevForMTC) And (\bMTCCuesPort = #False)
            bOpenMTCCuesPort = #True
          EndIf
        EndIf
      EndIf ; EndIf \bDummy = #False
    EndWith
  Next nMidiOutPhysicalDevPtr
  
  If bOpenMTCCuesPort
    samCancelRequest(#SCS_SAM_OPEN_MTC_CUES_PORT_AND_WAIT_IF_REQD) ; Added 4Jan2023 11.10.0ab
    debugMsg(sProcName, "calling openMTCCuesPortAndWaitIfReqd(#True)")
    openMTCCuesPortAndWaitIfReqd(#True)
  EndIf
  
  If grCtrlSetup\bUseExternalController
    debugMsg(sProcName, "calling resetController()")
    resetController()
  EndIf
  
  debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure openMidiOutPortIfReqd(nMidiOutPhysicalDevPtr)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", nMidiOutPort=" + nMidiOutPort)
  
  If nMidiOutPhysicalDevPtr >= 0
    If gaMidiOutDevice(nMidiOutPhysicalDevPtr)\bEnttecMidi = #False
      If gaMidiOutDevice(nMidiOutPhysicalDevPtr)\hMidiOut = 0
        debugMsg(sProcName, "calling MidiOut_Port('open', " + nMidiOutPhysicalDevPtr + ", 'ctrlsend')")
        MidiOut_Port("open", nMidiOutPhysicalDevPtr, "ctrlsend")
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure openMTCCuesPortIfReqd(nMTCCuesPhysicalDevPtr)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nMTCCuesPhysicalDevPtr=" + nMTCCuesPhysicalDevPtr)
  
  ASSERT_THREAD(#SCS_THREAD_MTC_CUES)
  
  If gnMTCSendMutex = 0
    gnMTCSendMutex = CreateMutex()
    debugMsg(sProcName, "gnMTCSendMutex=" + gnMTCSendMutex)
  EndIf
  
  If nMTCCuesPhysicalDevPtr >= 0
    With gaMidiOutDevice(nMTCCuesPhysicalDevPtr)
      debugMsg(sProcName, "gaMidiOutDevice(" + nMTCCuesPhysicalDevPtr + ")\bEnttecMidi=" + strB(\bEnttecMidi) + ", \nFTHandle=" + \nFTHandle + ", \hMidiOut=" + \hMidiOut)
      If \bEnttecMidi
        If \nFTHandle = 0
          debugMsg(sProcName, "calling DMX_openDMXDevForMidiOut(" + nMTCCuesPhysicalDevPtr + ")")
          DMX_openDMXDevForMidiOut(nMTCCuesPhysicalDevPtr)
          debugMsg(sProcName, "returned from DMX_openDMXDevForMidiOut(" + nMTCCuesPhysicalDevPtr + "), \nFTHandle=" + \nFTHandle)
        EndIf
      ElseIf \hMidiOut = 0
        debugMsg(sProcName, "calling MidiOut_Port('open', " + nMTCCuesPhysicalDevPtr + ", 'mtccues')")
        MidiOut_Port("open", nMTCCuesPhysicalDevPtr, "mtccues")
      EndIf
    EndWith
    With grMTCSendControl
      \bMTCCuesPortOpen = #True
      \nMTCCuesPhysicalDevPtr = nMTCCuesPhysicalDevPtr
      \hMTCMidiOut = gaMidiOutDevice(nMTCCuesPhysicalDevPtr)\hMidiOut
      \nMTCChannelNo = 127  ; using channel 127 for MTC
      \bMTCEnttecMidi = gaMidiOutDevice(nMTCCuesPhysicalDevPtr)\bEnttecMidi
      \nMTCFTHandle = gaMidiOutDevice(nMTCCuesPhysicalDevPtr)\nFTHandle
      debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(\bMTCCuesPortOpen))
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure openMTCCuesPortAndWaitIfReqd(bCloseExistingPort=#False)
  PROCNAMEC()
  Protected d
  Protected qInitialTime.q
  
  debugMsg(sProcName, #SCS_START + ", bCloseExistingPort=" + strB(bCloseExistingPort))
  
  With grMTCSendControl
    If \bMTCCuesPortOpen And bCloseExistingPort
      debugMsg(sProcName, "grMTCSendControl\nMTCCuesPhysicalDevPtr=" + \nMTCCuesPhysicalDevPtr + ", \bMTCCuesPortOpen=" + strB(\bMTCCuesPortOpen))
      If \nMTCCuesPhysicalDevPtr <> grMTCSendControlDef\nMTCCuesPhysicalDevPtr
        debugMsg(sProcName, "closing port " + \nMTCCuesPhysicalDevPtr)
        \nMTCThreadRequest | #SCS_MTC_THR_CLOSE_MIDI
        debugMsg(sProcName, "grMTCSendControl\nMTCThreadRequest=" + grMTCSendControl\nMTCThreadRequest)
        debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)")
        THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)
        qInitialTime = ElapsedMilliseconds()
        While (\bMTCCuesPortOpen = #False) And ((ElapsedMilliseconds() - qInitialTime) < 2000) And (\nMTCThreadRequest & #SCS_MTC_THR_CLOSE_MIDI) ; Added "And (\nMTCThreadRequest & #SCS_MTC_THR_CLOSE_MIDI)" 4Jan2022 11.10.0ab
          If gnThreadNo = #SCS_THREAD_MAIN
            WaitWindowEvent(20)   ; throw away window events
          Else
            Delay(20)   ; WaitWindowEvent() can only be called from the main thread
          EndIf
        Wend
      EndIf
    EndIf
    
    If \bMTCCuesPortOpen = #False
      debugMsg(sProcName, "grMTCSendControl\nMTCCuesPhysicalDevPtr=" + \nMTCCuesPhysicalDevPtr + ", \bMTCCuesPortOpen=" + strB(\bMTCCuesPortOpen))
      If \nMTCCuesPhysicalDevPtr = grMTCSendControlDef\nMTCCuesPhysicalDevPtr
        For d = 0 To grProd\nMaxCtrlSendLogicalDev
          Select grProd\aCtrlSendLogicalDevs(d)\nDevType
            Case #SCS_DEVTYPE_CS_MIDI_OUT, #SCS_DEVTYPE_CS_MIDI_THRU
              If grProd\aCtrlSendLogicalDevs(d)\bCtrlMidiForMTC
                \nMTCCuesPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CTRL_SEND, grProd\aCtrlSendLogicalDevs(d)\sLogicalDev)
                Break
              EndIf
          EndSelect
        Next d
      EndIf
      debugMsg(sProcName, "grMTCSendControl\nMTCCuesPhysicalDevPtr=" + \nMTCCuesPhysicalDevPtr)
      If \nMTCCuesPhysicalDevPtr <> grMTCSendControlDef\nMTCCuesPhysicalDevPtr
        \nMTCThreadRequest = #SCS_MTC_THR_OPEN_MIDI ; nb OPEN_MIDI means 'open MIDI if required'
        debugMsg(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)")
        THR_createOrResumeAThread(#SCS_THREAD_MTC_CUES)
        qInitialTime = ElapsedMilliseconds()
        While (\bMTCCuesPortOpen = #False) And (ElapsedMilliseconds() - qInitialTime) < 2000
          If gnThreadNo = #SCS_THREAD_MAIN
            WaitWindowEvent(20)   ; throw away window events
          Else
            Delay(20)   ; WaitWindowEvent() can only be called from the main thread
          EndIf
        Wend
        ; Deleted 17Mar2025 11.10.8am (see call to THR_suspendAThreadAndWait later in this procedure)
        ; debugMsg(sProcName, "calling THR_suspendAThread(#SCS_THREAD_MTC_CUES)")
        ; THR_suspendAThread(#SCS_THREAD_MTC_CUES)  ; added 17/10/2014 11.3.5
        ; End deleted 17Mar2025 11.10.8am (see call to THR_suspendAThreadAndWait later in this procedure)
      EndIf
      debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(\bMTCCuesPortOpen))
      
      If \bMTCCuesPortOpen
        If grOperModeOptions(gnOperMode)\nMTCDispLocn = #SCS_MTC_DISP_SEPARATE_WINDOW
          If (IsWindow(#WTC) = #False) And (IsWindow(#WMN))
            debugMsg(sProcName, "calling WTC_Form_Load(#False)")
            WTC_Form_Load(#False)
          EndIf
        EndIf
      EndIf
      
    EndIf
    
    ; Added 17Mar2025 11.10.8am
    debugMsg(sProcName, "calling THR_suspendAThreadAndWait(#SCS_THREAD_MTC_CUES)")
    THR_suspendAThreadAndWait(#SCS_THREAD_MTC_CUES)
    ; End added 17Mar2025 11.10.8am
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure closeMTCCuesPort(nMTCCuesPhysicalDevPtr)
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START + ", nMTCCuesPhysicalDevPtr=" + nMTCCuesPhysicalDevPtr)
  
  ASSERT_THREAD(#SCS_THREAD_MTC_CUES)
  
  If nMTCCuesPhysicalDevPtr >= 0
    debugMsg(sProcName, "gaMidiOutDevice(" + nMTCCuesPhysicalDevPtr + ")\hMidiOut=" + gaMidiOutDevice(nMTCCuesPhysicalDevPtr)\hMidiOut)
    If gaMidiOutDevice(nMTCCuesPhysicalDevPtr)\hMidiOut
      debugMsg(sProcName, "calling MidiOut_Port('close', " + nMTCCuesPhysicalDevPtr + ", 'mtccues')")
      MidiOut_Port("close", nMTCCuesPhysicalDevPtr, "mtccues")
    EndIf
  EndIf
  debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(grMTCSendControl\bMTCCuesPortOpen))
  grMTCSendControl = grMTCSendControlDef
  debugMsg(sProcName, "grMTCSendControl\bMTCCuesPortOpen=" + strB(grMTCSendControl\bMTCCuesPortOpen))
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getCuePtrForMidiCue(sMidiCue.s, bCueEnabledOnly=#True)
  PROCNAMEC()
  Protected i, nCuePtr
  
  nCuePtr = -1
  If bCueEnabledOnly
    For i = 1 To gnLastCue
      If (aCue(i)\sMidiCue = sMidiCue) And (aCue(i)\bCueCurrentlyEnabled)
        nCuePtr = i
        Break
      EndIf
    Next i
  Else
    For i = 1 To gnLastCue
      If aCue(i)\sMidiCue = sMidiCue
        nCuePtr = i
        Break
      EndIf
    Next i
  EndIf
  ProcedureReturn nCuePtr
  
EndProcedure

Procedure getCuePtrForExtFaderCC(nExtFaderCC)
  PROCNAMEC()
  Protected i, nCuePtr
  
  nCuePtr = -1
  For i = 1 To gnLastCue
    If aCue(i)\nActivationMethod = #SCS_ACMETH_EXT_FADER And aCue(i)\bCueCurrentlyEnabled
      If aCue(i)\nExtFaderCC = nExtFaderCC
        nCuePtr = i
        Break
      EndIf
    EndIf
  Next i
  ProcedureReturn nCuePtr
  
EndProcedure

Procedure processMidiOrDMXPlayCueCmd(nPhysicalDevPtr, sMidiCue.s)
  PROCNAMEC()
  ; also called from DMX_doDMXIn_Proc(), but nPhysicalDevPtr = -1 if called from DMX_doDMXIn_Proc()
  Protected i, j, nCuePtr
  Protected nExclusiveCuePtr
  Protected bEnableInSoloMode
  Protected bGoIfOKResult
  Protected nCurrHotkeyPtr, nHotkeyNr
  Protected bIgnoreInputMsg
  
  debugMsg(sProcName, #SCS_START + ", nPhysicalDevPtr=" + nPhysicalDevPtr + ", sMidiCue=" + sMidiCue)
  
  If gnThreadNo > #SCS_THREAD_MAIN
    samAddRequest(#SCS_SAM_PLAY_MIDI_OR_DMX_CUE, nPhysicalDevPtr, 0, 0, sMidiCue)
    ProcedureReturn
  EndIf
  
  nExclusiveCuePtr = checkExclusiveCuePlaying()
  If nExclusiveCuePtr >= 0
    debugMsg(sProcName, "nExclusiveCuePtr=" + getCueLabel(nExclusiveCuePtr))
  EndIf
  
  debugMsg(sProcName, "sMidiCue=" + sMidiCue + ", gnCueToGo=" + getCueLabel(gnCueToGo))
  If Len(sMidiCue) = 0
    If (gnCueToGo > 0) And (gnCueToGo < gnCueEnd)
      ; debugMsg(sProcName, "calling goIfOK()")
      bGoIfOKResult = goIfOK()
      debugMsg(sProcName, "goIfOK() returned " + strB(bGoIfOKResult))
      If bGoIfOKResult = #False
        ; cue didn't play
        If nExclusiveCuePtr > 0
          If nPhysicalDevPtr >= 0
            gaMidiControl(nPhysicalDevPtr)\sStatusField = LangPars("Errors", "MIDICannotPlay", getCueLabel(nExclusiveCuePtr))
            gaMidiControl(nPhysicalDevPtr)\nStatusType = #SCS_STATUS_ERROR
          Else
            WMN_setStatusField(LangPars("Errors", "DMXCannotPlay", getCueLabel(nExclusiveCuePtr)), #SCS_STATUS_ERROR)
          EndIf
          ProcedureReturn
        EndIf
      EndIf
    EndIf
    
  Else
    If gbMidiExtras
      Select sMidiCue
        Case "1"    ; STOP
          ; stopEverythingPart1()
          processStopAll() ; Changed 19May2025 11.10.8ba2
          ProcedureReturn
        Case "2"    ; TOP
          nCuePtr = getFirstEnabledCue()
          GoToCue(nCuePtr)
          debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
          calcCueStartValues(nCuePtr)
          ProcedureReturn
        Case "3"    ; END
          nCuePtr = gnLastCue + 1
          GoToCue(nCuePtr)
          debugMsg(sProcName, "calling calcCueStartValues(" + getCueLabel(nCuePtr) + ")")
          calcCueStartValues(nCuePtr)
          ProcedureReturn
        Case "4"    ; NEXT
          WMN_nextCue()
          ProcedureReturn
        Case "5"    ; PREV
          WMN_prevCue()
          ProcedureReturn
      EndSelect
    EndIf
    
    i = getCuePtrForMidiCue(sMidiCue)
    If i >= 0
      ; debugMsg(sProcName, "cue found i=" + getCueLabel(i))
      
      If aCue(i)\bCueCurrentlyEnabled
        If nExclusiveCuePtr > 0
          If aCue(i)\bGoOkIfExclPlaying = #False
            If nPhysicalDevPtr >= 0
              gaMidiControl(nPhysicalDevPtr)\sStatusField = LangPars("Errors", "MIDICannotPlay", getCueLabel(nExclusiveCuePtr))
              gaMidiControl(nPhysicalDevPtr)\nStatusType = #SCS_STATUS_ERROR
            Else
              WMN_setStatusField(LangPars("Errors", "DMXCannotPlay", getCueLabel(nExclusiveCuePtr)), #SCS_STATUS_ERROR)
            EndIf
            ProcedureReturn
          EndIf
        EndIf
        
        If aCue(i)\bHotkey
          nCurrHotkeyPtr = getCurrHotkeyPtrForCuePtr(i)
          If nCurrHotkeyPtr >= 0
            nHotkeyNr = gaCurrHotkeys(nCurrHotkeyPtr)\nHotkeyNr
            debugMsg(sProcName, "calling WMN_processHotkey(" + nHotkeyNr + ", #True)")
            WMN_processHotkey(nHotkeyNr, #True)
            ProcedureReturn
          EndIf
        EndIf
        
        bEnableInSoloMode = #True
        If (nExclusiveCuePtr > 0)
          j = aCue(i)\nFirstSubIndex
          While (j >= 0) And (bEnableInSoloMode)
            If (aSub(j)\bSubTypeForP) Or (aSub(j)\bSubTypeA)
              bEnableInSoloMode = #False
            EndIf
            j = aSub(j)\nNextSubIndex
          Wend
        EndIf
        
        If bEnableInSoloMode = #False
          WMN_setStatusField(LangPars("Errors", "MIDICannotPlay", getCueLabel(nExclusiveCuePtr)), #SCS_STATUS_ERROR)
          ProcedureReturn
        EndIf
        
        If aCue(i)\bKeepOpen
          debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\bKeepOpen=" + strB(aCue(i)\bKeepOpen))
          ; hotkey or external activation cue, or non-linear cue
          Select aCue(i)\nActivationMethodReqd
            Case  #SCS_ACMETH_HK_TOGGLE, #SCS_ACMETH_EXT_TOGGLE
              ; toggle activation method, so fade out / stop cue IF cue is currrently playing
              If (aCue(i)\nCueState >= #SCS_CUE_FADING_IN) And (aCue(i)\nCueState <= #SCS_CUE_FADING_OUT)
                debugMsg(sProcName, "calling fadeOutCue(" + aCue(i)\sCue + ", False)")
                fadeOutCue(i, #False)
              Else
                debugMsg(sProcName, "calling playCueFromStart(" + getCueLabel(i) + ")")
                playCueFromStart(i)
              EndIf
            Case #SCS_ACMETH_EXT_COMPLETE
              If aCue(i)\nCueState >= #SCS_CUE_FADING_IN And aCue(i)\nCueState <= #SCS_CUE_FADING_OUT
                ; cue is currently playing so ignore this request
                debugMsg(sProcName, "ignore request to play cue " + getCueLabel(i) + " as it is currently playing and the activation method is #SCS_ACMETH_EXT_COMPLETE")
                WMN_setStatusField(LangPars("Errors", "ExtCannotPlayComp", getCueLabel(i)), #SCS_STATUS_ERROR)
                bIgnoreInputMsg = #True
              Else
                debugMsg(sProcName, "calling playCueFromStart(" + getCueLabel(i) + ")")
                playCueFromStart(i)
              EndIf
            Default
              debugMsg(sProcName, "calling playCueFromStart(" + getCueLabel(i) + ")")
              playCueFromStart(i)
          EndSelect
          If bIgnoreInputMsg = #False
            If aCue(i)\nHideCueOpt = #SCS_HIDE_NO
              debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
              gbCallLoadDispPanels = #True
            EndIf
          EndIf
          DoEvents()
        Else
          ; non-hotkey or external activation cue
          ; debugMsg(sProcName, "calling setGridRow(" + getCueLabel(i) + ")")
          setGridRow(i)
          If i <> gnCueToGo
            debugMsg(sProcName, "calling GoToCue(" + getCueLabel(i) + ")")
            GoToCue(i)
          EndIf
          debugMsg(sProcName, "calling playCueFromStart(" + getCueLabel(i) + ")")
          playCueFromStart(i)
          ; debugMsg(sProcName, "calling highlightLine(" + getCueLabel(i) + ")")
          highlightLine(i)
          ; debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
          gbCallLoadDispPanels = #True
          ; debugMsg(sProcName, "calling setCueToGo()")
          setCueToGo()
          gbCallSetNavigateButtons = #True
        EndIf
        
      EndIf ; EndIf aCue(i)\bCueEnabled
      
    EndIf ; EndIf i >= 0
    
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning bIgnoreInputMsg=" + strB(bIgnoreInputMsg))
  ProcedureReturn bIgnoreInputMsg
  
EndProcedure

Procedure processMidiFadeOutCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected nCuePtr
  
  debugMsg(sProcName, #SCS_START)
  
  If Len(sMidiCue) = 0
    ; 'Fade All' added 16Nov2020 11.8.3.3ah
    processFadeAll()
  Else
    nCuePtr = getCuePtrForMidiCue(sMidiCue)
    If nCuePtr >= 0
      debugMsg(sProcName, "calling fadeOutCue(" + getCueLabel(nCuePtr) + ")")
      fadeOutCue(nCuePtr)
      debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
      gbCallLoadDispPanels = #True
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processMidiGoButtonCmd(nMidiInPort)
  PROCNAMEC()
  Protected bGoIfOKResult, nExclusiveCuePtr
  
  debugMsg(sProcName, "calling goIfOK()")
  bGoIfOKResult = goIfOK()
  debugMsg(sProcName, "goIfOK() returned " + strB(bGoIfOKResult))
  If bGoIfOKResult = #False
    ; cue didn't play
    nExclusiveCuePtr = checkExclusiveCuePlaying()
    debugMsg(sProcName, "nExclusiveCuePtr=" + getCueLabel(nExclusiveCuePtr))
    If nExclusiveCuePtr > 0
      gaMidiControl(nMidiInPort)\sStatusField = LangPars("Errors", "MIDICannotPlay", getCueLabel(nExclusiveCuePtr))
      gaMidiControl(nMidiInPort)\nStatusType = #SCS_STATUS_ERROR
      ProcedureReturn
    EndIf
  EndIf
EndProcedure

Procedure processMidiGoToCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i

  i = getCuePtrForMidiCue(sMidiCue)
  If i >= 0
    GoToCue(i)
  EndIf

EndProcedure

Procedure processMidiNextCueCmd()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling WMN_nextCue()")
  WMN_nextCue()
  
EndProcedure

Procedure processMidiPrevCueCmd()
  PROCNAMEC()
  
  debugMsg(sProcName, "calling WMN_prevCue()")
  WMN_prevCue()
  
EndProcedure

Procedure processMidiPauseResumeCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i, j, k

  If Len(sMidiCue) = 0
    processPauseResumeAll()
    ProcedureReturn
  EndIf
  
  setGlobalTimeNow()
  i = getCuePtrForMidiCue(sMidiCue)
  If i >= 0
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubEnabled
        If aSub(j)\bSubTypeF Or aSub(j)\bSubTypeP
          k = aSub(j)\nFirstAudIndex
          While k >= 0
            If aAud(k)\nAudState >= #SCS_CUE_FADING_IN And aAud(k)\nAudState <= #SCS_CUE_FADING_OUT
              If aAud(k)\nAudState <> #SCS_CUE_PAUSED
                pauseAud(k)
              Else
                resumeAud(k)
              EndIf
            EndIf
            k = aAud(k)\nNextAudIndex
          Wend
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    setCueState(i)
  EndIf

EndProcedure

Procedure processMidiLoadCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i
  
  i = getCuePtrForMidiCue(sMidiCue)
  If i >= 0
    loadOneCue(i)
  EndIf

EndProcedure

Procedure processMidiUnloadCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i
  
  i = getCuePtrForMidiCue(sMidiCue)
  If i >= 0
    unloadOneCue(i)
  EndIf

EndProcedure

Procedure processMidiReleaseCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i, j, k, l2
  
  i = getCuePtrForMidiCue(sMidiCue)
  If i >= 0
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeF And aSub(j)\bSubEnabled
        k = aSub(j)\nFirstAudIndex
        While k >= 0
          If (aAud(k)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(k)\nAudState <= #SCS_CUE_FADING_OUT)
            With aAud(k)
              l2 = \nCurrLoopInfoIndex
              If l2 >= 0
                If \rCurrLoopInfo\bLoopReleased = #False
                  \rCurrLoopInfo\bLoopReleased = #True
                  \aLoopInfo(l2)\bLoopReleased = #True
                  \nRelPassEnd = \nRelEndAt
                  debugMsg(sProcName, "aAud(" + getAudLabel(k) + ")\nRelPassEnd=" + \nRelPassEnd)
                  CompilerIf 1=2
                    removeAudChannelLoopSyncs(k)
                    debugMsg(sProcName, "setting gbCallLoadDispPanels=#True")
                  CompilerEndIf
                  gbCallLoadDispPanels = #True
                EndIf
              EndIf
            EndWith
          EndIf
          k = aAud(k)\nNextAudIndex
        Wend
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
    setCueState(i)
  EndIf

EndProcedure

Procedure processMidiStopCueCmd(sMidiCue.s)
  PROCNAMEC()
  Protected i

  If Len(sMidiCue) = 0
    ; stopEverythingPart1()
    processStopAll() ; Changed 19May2025 11.10.8ba2
  Else
    i = getCuePtrForMidiCue(sMidiCue, #False)
    If i >= 0
      debugMsg(sProcName, "calling stopCue(" + getCueLabel(i) + ", 'ALL', #True)")
      stopCue(i, "ALL", #True)
    EndIf
  EndIf

EndProcedure

Procedure processOpenFavFile(nFavFileNr)
  PROCNAMEC()
  Protected nFavFilePtr
  
  debugMsg(sProcName, #SCS_START + ", nFavFileNr=" + Str(nFavFileNr))
  
  nFavFilePtr = nFavFileNr - 1
  If (nFavFilePtr >= 0) And (nFavFilePtr <= #SCS_MAX_FAV_FILE)
    If Len(gaFavoriteFiles(nFavFilePtr)\sFileName) > 0
      If FileExists(gaFavoriteFiles(nFavFilePtr)\sFileName)
        gsCueFile = gaFavoriteFiles(nFavFilePtr)\sFileName
        gsCueFolder = GetPathPart(gsCueFile)
        debugMsg(sProcName, "gsCueFile=" + gsCueFile)
        samAddRequest(#SCS_SAM_LOAD_SCS_CUE_FILE, 1, 0, 0)  ; p1: 1 = primary file.  p3: 0 = do NOT call editor after loading
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s SendMSC(nMidiOutPort, pDevice, pCommandFormat, pCommand, pQNumber.s, pQList.s, pQPath.s, pMacro)
  PROCNAMEC()
  Protected sPortName.s, nDataLength
  Protected *MidiData
  Protected n
  Protected j
  Protected nTmp, nLSB, nMSB
  Protected nMidiResult.l   ; long
  Protected qTimeoutTime.q
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bByte.b, sMidiString.s
  Protected bEnttecMidi
  Protected nTryCount
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        bEnttecMidi = \bEnttecMidi
        sPortName = \sName
        If bEnttecMidi = #False
          debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut)
          If \hMidiOut <> 0
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(nMidiOutPort), " + nSizeOfHdr + ")", nMidiResult)
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMSC to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
    
    *MidiData = AllocateMemory(256)  ; allocate more than enough memory for the data
    If *MidiData
      ; construct SysEx message
      nDataLength = 0
      PokeB(*MidiData+nDataLength, $F0)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $7F)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, pDevice)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $2)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, pCommandFormat)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, pCommand)
      nDataLength + 1
      Select pCommand
        Case $1, $2, $3, $5, $B, $10
          ; commands with q_number, q_list and q_path
          If Len(pQNumber) > 0
            For j = 1 To Len(pQNumber)
              PokeB(*MidiData+nDataLength, Asc(Mid(pQNumber, j, 1)))
              nDataLength + 1
            Next j
          EndIf
          If Len(pQList) > 0 Or Len(pQPath) > 0
            PokeB(*MidiData+nDataLength, $0)  ; null separator byte
            nDataLength + 1                   ; for above
            If Len(pQList) > 0
              For j = 1 To Len(pQList)
                PokeB(*MidiData+nDataLength, Asc(Mid(pQList, j, 1)))
                nDataLength + 1
              Next j
            EndIf
          EndIf
          If Len(pQPath) > 0
            PokeB(*MidiData+nDataLength, $0)  ; null separator byte
            nDataLength + 1                   ; for above
            If Len(pQPath) > 0
              For j = 1 To Len(pQPath)
                PokeB(*MidiData+nDataLength, Asc(Mid(pQPath, j, 1)))
                nDataLength + 1
              Next j
            EndIf
          EndIf
          
        Case $6
          ; set command uses q_number and q_list for control number and control value
          nTmp = Val(pQNumber)
          ; the LSB and MSB specified as 7-bit numbers
          If nTmp < $80
            nLSB = nTmp
            nMSB = 0
          Else
            nMSB = Round(nTmp / $80, #PB_Round_Down)
            nLSB = nTmp - (nMSB * $80)
          EndIf
          PokeB(*MidiData+nDataLength, nLSB)
          nDataLength + 1
          PokeB(*MidiData+nDataLength, nMSB)
          nDataLength + 1
          
          nTmp = Val(pQList)
          If nTmp < $80
            nLSB = nTmp
            nMSB = 0
          Else
            nMSB = Round(nTmp / $80, #PB_Round_Down)
            nLSB = nTmp - (nMSB * $80)
          EndIf
          PokeB(*MidiData+nDataLength, nLSB)
          nDataLength + 1
          PokeB(*MidiData+nDataLength, nMSB)
          nDataLength + 1
          
        Case $7
          ; command with macro number
          If pMacro >= 0
            PokeB(*MidiData+nDataLength, pMacro)
            nDataLength + 1
          EndIf
          
        Case $1B, $1C
          If Len(pQList) > 0
            If Len(pQList) > 0
              For j = 1 To Len(pQList)
                PokeB(*MidiData+nDataLength, Asc(Mid(pQList, j, 1)))
                nDataLength + 1
              Next j
            EndIf
          EndIf
          
        Case $1D, $1E
          If Len(pQPath) > 0
            If Len(pQPath) > 0
              For j = 1 To Len(pQPath)
                PokeB(*MidiData+nDataLength, Asc(Mid(pQPath, j, 1)))
                nDataLength + 1
              Next j
            EndIf
          EndIf
          
        Default
          ; no extra info or unsupported
      EndSelect
      PokeB(*MidiData+nDataLength, $F7)
      nDataLength + 1
      
      If (bEnttecMidi) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
        With gaMidiOutDevice(nMidiOutPort)
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, *MidiData, nDataLength)
        EndWith
      EndIf
      
      If bEnttecMidi = #False
        
        With gaMidiOutHdr(nMidiOutPort)
          \lpData = *MidiData
          \dwBufferLength = nDataLength
          \dwBytesRecorded = 0
          \dwUser = 0
          \dwFlags = 0
          sMidiString = ""
          For n = 0 To (nDataLength - 1)
            bByte = PeekB(*MidiData + n)
            sMidiString + hex2(bByte)
          Next n
          debugMsg(sProcName, "\dwBufferLength=" + \dwBufferLength + ", \lpData=$" + sMidiString)
        EndWith
        
        With gaMidiOutDevice(nMidiOutPort)
          If \hMidiOut <> 0
            debugMsg(sProcName, "calling midiOutPrepareHeader_(" + \hMidiOut + ", @gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")")
            nMidiResult = midiOutPrepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutPrepareHeader: SendMSC to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            debugMsg(sProcName, "calling midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")")
            nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
                debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
              Wend
            EndIf
            ; debugMsg2(sProcName, "(\hMidiOut) midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(nMidiOutPort), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutLongMsg: SendMSC to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndWith
        
      EndIf ; EndIf bEnttecMidi = #False
      
      FreeMemory(*MidiData)
      
    EndIf ; EndIf *MidiData
    
  EndIf ; EndIf nMidiOutPort >= 0
  
  ProcedureReturn sPortName
EndProcedure

Procedure.s SendProgChange(nMidiOutPort, pProg, pMidiChannel)
  PROCNAMEC()
  Protected sPortName.s
  Protected qTimeoutTime.q
  Protected nMidiMessage.l   ; long
  Protected nMidiResult.l   ; long
  Protected nTryCount
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        nMidiMessage = $C0 + (pProg * $100) + (pMidiChannel - 1)
        debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut + ", pProg=" + Str(pProg) + ", pMidiChannel=" + Str(pMidiChannel))
        If \bEnttecMidi
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, @nMidiMessage, 4)
        Else
          If \hMidiOut <> 0
            nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage) ; params: long, long
            debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage)
                debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
              Wend
            EndIf
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "SendNoteOff: midiOutShortMsg", nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        sPortName = \sName
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
  EndIf
  ProcedureReturn sPortName
EndProcedure

Procedure.s SendCtrlChange(nMidiOutPort, pCtrl, pValue, pMidiChannel, bLogCommand=#True)
  PROCNAMEC()
  Protected sPortName.s
  Protected qTimeoutTime.q
  Protected nMidiMessage.l   ; long
  Protected nMidiResult.l   ; long
  Protected nTryCount

  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        nMidiMessage = $B0 + (pCtrl * $100) + (pValue * $10000) + (pMidiChannel - 1)
        If bLogCommand
          debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut + ", pCtrl=" + pCtrl + ", pValue=" + pValue + ", pMidiChannel=" + pMidiChannel)
        EndIf
        If \bEnttecMidi
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, @nMidiMessage, 4)
        Else
          If \hMidiOut <> 0
            nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage) ; params: long, long
            If bLogCommand
              debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
            EndIf
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage)
                debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
              Wend
            EndIf
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "SendNoteOff: midiOutShortMsg", nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        sPortName = \sName
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
  EndIf
  ProcedureReturn sPortName
EndProcedure

Procedure.s SendNoteOn(nMidiOutPort, pNote, pVelocity, pMidiChannel)
  PROCNAMEC()
  Protected sPortName.s
  Protected qTimeoutTime.q
  Protected nMidiMessage.l   ; long
  Protected nMidiResult.l   ; long
  Protected nTryCount
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        nMidiMessage = $90 + (pNote * $100) + (pVelocity * $10000) + (pMidiChannel - 1)
        debugMsg(sProcName, "hMidiOut: pNote=" + pNote + ", pVelocity=" + pVelocity + ", pMidiChannel=" + pMidiChannel)
        If \bEnttecMidi
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, @nMidiMessage, 4)
        Else
          If \hMidiOut <> 0
            nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage) ; params: long, long
            debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage)
                debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
              Wend
            EndIf
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "SendNoteOn: midiOutShortMsg", nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        sPortName = \sName
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
  EndIf ; EndIf nMidiOutPort >= 0
  ProcedureReturn sPortName
EndProcedure

Procedure.s SendNoteOff(nMidiOutPort, pNote, pVelocity, pMidiChannel)
  PROCNAMEC()
  Protected sPortName.s
  Protected qTimeoutTime.q
  Protected nMidiMessage.l   ; long
  Protected nMidiResult.l   ; long
  Protected nTryCount
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        nMidiMessage = $80 + (pNote * $100) + (pVelocity * $10000) + (pMidiChannel - 1)
        debugMsg(sProcName, "hMidiOut: pNote=" + pNote + ", pVelocity=" + pVelocity + ", pMidiChannel=" + pMidiChannel)
        If \bEnttecMidi
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, @nMidiMessage, 4)
        Else
          If \hMidiOut <> 0
            nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage) ; params: long, long
            debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutShortMsg_(\hMidiOut, nMidiMessage)
                debugMsg2(sProcName, "midiOutShortMsg_(" + \hMidiOut + ", " + Hex(nMidiMessage) + ")", nMidiResult)
              Wend
            EndIf
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "SendNoteOff: midiOutShortMsg", nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        sPortName = \sName
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
  EndIf ; EndIf nMidiOutPort >= 0
  ProcedureReturn sPortName
EndProcedure

Procedure.s SendMidiFreeFormat(nMidiOutPort, pHexMsg.s)
  PROCNAMEC()
  Protected sPortName.s, nHexLength, nDataLength
  Protected sWork.s, sHexMsg.s, sMsg.s
  Protected *MidiData
  Protected n
  Protected aByte.a
  Protected qTimeoutTime.q
  Protected nMidiResult.l   ; long
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bEnttecMidi
  Protected nTryCount
  
  debugMsg(sProcName, #SCS_START + ", pHexMsg=" + pHexMsg)
  
  sHexMsg = RemoveString(pHexMsg, " ")
  nHexLength = Len(sHexMsg)
  
  If nHexLength = 0
    ProcedureReturn
  EndIf
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        bEnttecMidi = \bEnttecMidi
        sPortName = \sName
        If bEnttecMidi = #False
          debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut)
          If \hMidiOut <> 0
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver styalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
    
    *MidiData = AllocateMemory(nHexLength<<1)  ; allocate more than enough memory for the data
    If *MidiData
      nDataLength = 0
      For n = 1 To nHexLength Step 2
        aByte = hexToDec(Mid(sHexMsg, n, 1)) * 16
        aByte + hexToDec(Mid(sHexMsg, n + 1, 1))
        PokeA(*MidiData+nDataLength, aByte)
        nDataLength + 1
      Next n
      
      If (bEnttecMidi) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
        With gaMidiOutDevice(nMidiOutPort)
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, *MidiData, nDataLength)
        EndWith
      EndIf
      
      If bEnttecMidi = #False
        
        With gaMidiOutHdr(nMidiOutPort)
          \lpData = *MidiData
          \dwBufferLength = nDataLength
          \dwBytesRecorded = 0
          \dwUser = 0
          \dwFlags = 0
          For n = 0 To (nDataLength - 1)
            sMsg + decToHex2(PeekA(*MidiData+n)) + " "
          Next n
          debugMsg3(sProcName, "\dwBufferLength=" + \dwBufferLength + ", data=" + RTrim(sMsg))
        EndWith
        
        With gaMidiOutDevice(nMidiOutPort)
          If \hMidiOut <> 0
            nMidiResult = midiOutPrepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutPrepareHeader_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutPrepareHeader: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
                debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
              Wend
            EndIf
            ; debugMsg2(sProcName, "(\hMidiOut) midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutLongMsg: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndWith
        
      EndIf ; EndIf bEnttecMidi = #False
      
      FreeMemory(*MidiData)
      
    EndIf ; EndIf *MidiData
    
  EndIf ; EndIf nMidiOutPort >= 0
  
  ProcedureReturn sPortName
  
EndProcedure

Procedure.s SendMidiNRPN(nMidiOutPort, *rCtrlSend.tyCtrlSend)
  PROCNAMEC()
  Protected sPortName.s
  Protected aStatusByte.a, aParamByte.a, nDataLength
  Protected sWork.s, sHexMsg.s, sMsg.s
  Static *MidiData
  Protected n
  Protected qTimeoutTime.q
  Protected nMidiResult.l   ; long
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bEnttecMidi
  Protected nTryCount
  
  debugMsg(sProcName, #SCS_START)
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        bEnttecMidi = \bEnttecMidi
        sPortName = \sName
        If bEnttecMidi = #False
          debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut)
          If \hMidiOut <> 0
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver stalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
    
    If *MidiData = 0
      *MidiData = AllocateMemory(16)  ; allocate more than enough memory for the data
    EndIf
    If *MidiData
      With *rCtrlSend
        aStatusByte = $B0 + (\nMSChannel - 1)
        Select \nMSMsgType
          Case #SCS_MSGTYPE_NRPN_GEN
            ; #SCS_MSGTYPE_NRPN_GEN: 'Standard' NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
            ; NRPN MSB
            aParamByte = \nMSParam1
            PokeA(*MidiData, aStatusByte)
            PokeA(*MidiData+1, $63)
            PokeA(*MidiData+2, aParamByte)
            ; NRPN LSB
            aParamByte = \nMSParam2
            PokeA(*MidiData+3, aStatusByte)
            PokeA(*MidiData+4, $62)
            PokeA(*MidiData+5, aParamByte)
            ; Data MSB
            aParamByte = \nMSParam3
            PokeA(*MidiData+6, aStatusByte)
            PokeA(*MidiData+7, $06)
            PokeA(*MidiData+8, aParamByte)
            If \nMSParam4 >= 0
              ; Data LSB
              aParamByte = \nMSParam4
              PokeA(*MidiData+9, aStatusByte)
              PokeA(*MidiData+10, $26)
              PokeA(*MidiData+11, aParamByte)
              nDataLength = 12
            Else
              nDataLength = 9
            EndIf
            
          Case #SCS_MSGTYPE_NRPN_YAM
            ; #SCS_MSGTYPE_NRPN_YAM: Yamaha NRPN (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
            ; Also, second and subsequent status bytes not required
            ; NRPN LSB
            aParamByte = \nMSParam2
            PokeA(*MidiData, aStatusByte)
            PokeA(*MidiData+1, $62)
            PokeA(*MidiData+2, aParamByte)
            ; NRPN MSB
            aParamByte = \nMSParam1
            PokeA(*MidiData+3, $63)
            PokeA(*MidiData+4, aParamByte)
            ; Data MSB
            aParamByte = \nMSParam3
            PokeA(*MidiData+5, $06)
            PokeA(*MidiData+6, aParamByte)
            If \nMSParam4 >= 0
              ; Data LSB
              aParamByte = \nMSParam4
              PokeA(*MidiData+7, $26)
              PokeA(*MidiData+8, aParamByte)
              nDataLength = 9
            Else
              nDataLength = 7
            EndIf
            
        EndSelect
      EndWith
      
      If (bEnttecMidi) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
        With gaMidiOutDevice(nMidiOutPort)
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, *MidiData, nDataLength)
        EndWith
      EndIf
      
      If bEnttecMidi = #False
        
        With gaMidiOutHdr(nMidiOutPort)
          \lpData = *MidiData
          \dwBufferLength = nDataLength
          \dwBytesRecorded = 0
          \dwUser = 0
          \dwFlags = 0
          For n = 0 To (nDataLength - 1)
            sMsg + decToHex2(PeekA(*MidiData+n)) + " "
          Next n
          debugMsg3(sProcName, "\dwBufferLength=" + \dwBufferLength + ", data=" + RTrim(sMsg))
        EndWith
        
        With gaMidiOutDevice(nMidiOutPort)
          If \hMidiOut <> 0
            nMidiResult = midiOutPrepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutPrepareHeader_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutPrepareHeader: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
                debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
              Wend
            EndIf
            ; debugMsg2(sProcName, "(\hMidiOut) midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutLongMsg: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndWith
        
      EndIf ; EndIf bEnttecMidi = #False
      
    EndIf ; EndIf *MidiData
    
  EndIf ; EndIf nMidiOutPort >= 0
  
  ProcedureReturn sPortName
  
EndProcedure

Procedure.s SendMidiRemDevMsg(nMidiOutPort, *rCtrlSend.tyCtrlSend)
  PROCNAMEC()
  Protected sPortName.s
  Protected n, n1, n2, nMsgIndex
  Protected qTimeoutTime.q
  Protected nMidiMessage.l   ; long
  Protected nMidiResult.l   ; long
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bEnttecMidi
  Protected nTryCount
  Protected nCtrlMidiChannel
  Protected nDataLength, sMsg.s
  Protected nMsgDataPtr, nValidValueIndex, sValType1.s, sValType2.s, nMaxDataValue1, nMaxDataValue2, nValBase1, nValBase2
  Protected sSkipParamValues.s, nSkipParamValuesStart, nSkipParamValuesEnd
  Protected sMsgData.s, sReqdMsgData.s
  Protected nItemPass, nPos, sMathOperator.s
  Protected nByteValue, nAdjustmentValue, bParamPresent
  Protected nMemoryPtr, nMemoryByte.a, bIgnoreThisByte, fRemDevLevel.f
  Protected nP1Value, nP2Value, sP1Code.s, sP2Code.s, nItemCount, nItemNr, sItem.s, sItemPart.s, nItemPartLength, nItemPartValue, sChar.s, nCharPtr
  Protected nHTUValue
  Static *MidiData
  Protected nCustomisedAlgorithm, nAlgorithmParamValue ; Added 31Aug2022 11.9.5.1
  Protected sBaseMsgData.s, sTmpMsgData.s, nPart1Count, nPart2Count
  Structure tyRemDevParamValuesAndCodes
    nParamP1Value.i
    sParamS1Code.s
    nParamP2Value.i
    sParamS2Code.s
  EndStructure
  Static Dim aRemDevParamValuesAndCodes.tyRemDevParamValuesAndCodes(0)
  Protected nMaxRemDevValuesAndCodes, nRemDevId, sDataCode1.s, sDataCode2.s
  Protected sParameter.s
  Protected sHexTenZeros.s = "30 30 30 30 30 30 30 30 30 30 "
  Protected nDollarPtr, nParamLength, sParamValue.s
  
  debugMsg(sProcName, #SCS_START)
  
  openMidiOutPortIfReqd(nMidiOutPort)
  gsMidiSendError = ""
  
  If nMidiOutPort >= 0
    With gaMidiOutDevice(nMidiOutPort)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        ;{
        bEnttecMidi = \bEnttecMidi
        sPortName = \sName
        If bEnttecMidi = #False
          ; debugMsg(sProcName, "nMidiOutPort=" + nMidiOutPort + ", \hMidiOut=" + \hMidiOut)
          If \hMidiOut <> 0
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            EndIf
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver stalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
              closeAndReopenMidiOutPort(nMidiOutPort)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMIDIFreeFormat to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        Break ; added 4Apr2019 11.8.0.2cm
        ;}
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
    
    With *rCtrlSend
      nCtrlMidiChannel = getCtrlMidiChannelForLogicalDev(\sCSLogicalDev)
      ; debugMsg(sProcName, "nCtrlMidiChannel=" + nCtrlMidiChannel)
      nMsgDataPtr = CSRD_GetMsgDataPtrForRemDevMsgType(\nRemDevMsgType)
      If nMsgDataPtr >= 0
        sValType1 = grCSRD\aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType
        nValidValueIndex = CSRD_GetValidValueIndexForValType(\nRemDevId, sValType1)
        If nValidValueIndex >= 0
          nMaxDataValue1 = grCSRD\aValidValue(nValidValueIndex)\nCSRD_MaxValDataValue
        EndIf
        sValType2 = grCSRD\aRemDevMsgData(nMsgDataPtr)\sCSRD_ValType2
        If sValType2
          nValidValueIndex = CSRD_GetValidValueIndexForValType(\nRemDevId, sValType2)
          If nValidValueIndex >= 0
            nMaxDataValue2 = grCSRD\aValidValue(nValidValueIndex)\nCSRD_MaxValDataValue
          EndIf
        Else
          nMaxDataValue2 = 0
        EndIf
        sSkipParamValues = grCSRD\aRemDevMsgData(nMsgDataPtr)\sCSRD_SkipParamValues
        If sSkipParamValues
          nSkipParamValuesStart = Val(StringField(sSkipParamValues, 1, "-"))
          nSkipParamValuesEnd = Val(StringField(sSkipParamValues, 2, "-"))
        Else
          nSkipParamValuesStart = -1
          nSkipParamValuesEnd = -1
        EndIf
      EndIf
      ; debugMsg(sProcName, "nMaxDataValue1=" + nMaxDataValue1 + ", nMaxDataValue2=" + nMaxDataValue2)
      If \sRemDevValue And (nMaxDataValue1 >= 0 Or nMaxDataValue2 >= 0)
        grCSRD\nMaxDataValueIndex = nMaxDataValue1
        grCSRD\nMaxDataValueIndex2 = nMaxDataValue2
        nPart1Count = CSRD_populateArrayDataValueSelected(\sRemDevValue, 1)
        nPart2Count = CSRD_populateArrayDataValueSelected(\sRemDevValue2, 2)
        If nPart2Count = 0
          nMaxRemDevValuesAndCodes = nPart1Count - 1
        Else
          nMaxRemDevValuesAndCodes = (nPart1Count * nPart2Count) - 1
        EndIf
        debugMsg(sProcName, "nPart1Count=" + nPart1Count + ", nPart2Count=" + nPart2Count + ", nMaxRemDevValuesAndCodes=" + nMaxRemDevValuesAndCodes)
        If nMaxRemDevValuesAndCodes > ArraySize(aRemDevParamValuesAndCodes())
          ReDim aRemDevParamValuesAndCodes(nMaxRemDevValuesAndCodes)
        EndIf
        nRemDevId = \nRemDevId
        sValType1 = CSRD_GetValTypeForRemDevMsgType(\nRemDevMsgType, 1)
        sValType2 = CSRD_GetValTypeForRemDevMsgType(\nRemDevMsgType, 2)
        nValBase1 = CSRD_GetValBaseForRemDevMsgType(\nRemDevMsgType, 1)
        nValBase2 = CSRD_GetValBaseForRemDevMsgType(\nRemDevMsgType, 2)
        n = 0
        For n1 = nValBase1 To nMaxDataValue1
          ; debugMsg(sProcName, "grCSRD\bDataValueSelected(" + n1 + ")=" + strB(grCSRD\bDataValueSelected(n1)))
          If grCSRD\bDataValueSelected(n1)
            sDataCode1 = CSRD_getValDataCodeForValTypeItemNr(nRemDevId, sValType1, Str(n1))
            debugMsg(sProcName, "CSRD_getValDataCodeForValTypeItemNr(" + nRemDevId + ", " + sValType1 + ", " + Str(n1) + ") returned sDataCode1=" + sDataCode1)
            If nPart2Count = 0
              aRemDevParamValuesAndCodes(n)\nParamP1Value = n1 - nValBase1
              aRemDevParamValuesAndCodes(n)\nParamP2Value = 0
              aRemDevParamValuesAndCodes(n)\sParamS1Code = CSRD_convertStringsToHexStrings(#DQUOTE$ + sDataCode1 + #DQUOTE$)
              aRemDevParamValuesAndCodes(n)\sParamS2Code = ""
              n + 1
            Else
              For n2 = nValBase2 To nMaxDataValue2
                ; debugMsg(sProcName, "grCSRD\bDataValueSelected2(" + n2 + ")=" + strB(grCSRD\bDataValueSelected2(n2)))
                If grCSRD\bDataValueSelected2(n2)
                  sDataCode2 = CSRD_getValDataCodeForValTypeItemNr(nRemDevId, sValType2, Str(n2))
                  debugMsg(sProcName, "CSRD_getValDataCodeForValTypeItemNr(" + nRemDevId + ", " + sValType2 + ", " + Str(n2) + ") returned sDataCode2=" + sDataCode2)
                  aRemDevParamValuesAndCodes(n)\nParamP1Value = n1 - nValBase1
                  aRemDevParamValuesAndCodes(n)\nParamP2Value = n2 - nValBase2
                  aRemDevParamValuesAndCodes(n)\sParamS1Code = CSRD_convertStringsToHexStrings(#DQUOTE$ + sDataCode1 + #DQUOTE$)
                  aRemDevParamValuesAndCodes(n)\sParamS2Code = CSRD_convertStringsToHexStrings(#DQUOTE$ + sDataCode2 + #DQUOTE$)
                  n + 1
                EndIf
              Next n2
            EndIf
          EndIf
        Next n1
        For n = 0 To nMaxRemDevValuesAndCodes
          debugMsg(sProcName, "aRemDevParamValuesAndCodes(" + n + ")\nParamP1Value=" + aRemDevParamValuesAndCodes(n)\nParamP1Value + ", \sParamS1Code=" + #DQUOTE$ + aRemDevParamValuesAndCodes(n)\sParamS1Code + #DQUOTE$ +
                              ", \nParamP2Value=" + aRemDevParamValuesAndCodes(n)\nParamP2Value + ", \sParamS2Code=" + #DQUOTE$ + aRemDevParamValuesAndCodes(n)\sParamS2Code + #DQUOTE$)
        Next n
        ; EG if $S1 = "GN" (color green) then aRemDevParamValuesAndCodes(0)\sParamS1Code will be "47 4E" (hex values for "GN")
        ;    if $S2 = 6 (eg channel 6) then aRemDevParamValuesAndCodes(0)\sParamS2Code will be "36" (the hex value for character "6")
        ; If there is a grid for $S2 (eg multiple channels may be selected) then nMaxRemDevValuesAndCodes will be the relevant maximum array index, eg if 4 channels have been selected then
        ; the array items will range from aRemDevParamValuesAndCodes(0)\sParamS1Code (and 2) to aRemDevParamValuesAndCodes(3)\sParamS1Code (and 2), and nMaxRemDevValuesAndCodes will be 3.
      EndIf
      sTmpMsgData = CSRD_GetMsgDataForRemDevMsgType(\nRemDevMsgType) ; MsgData is the MIDI data as obtained from the file scs_csrd.scsrd, eg "9N $P1+20 7F; 9N $P1+20 3F"
      ; debugMsg(sProcName, "sTmpMsgData=" + sTmpMsgData)
      sBaseMsgData = CSRD_convertStringsToHexStrings(sTmpMsgData)
      debugMsg(sProcName, "sBaseMsgData=" + sBaseMsgData)
      For nMsgIndex = 0 To nMaxRemDevValuesAndCodes
        ; debugMsg(sProcName, "nMsgIndex=" + nMsgIndex)
        sMsgData = sBaseMsgData
        nDollarPtr = FindString(sMsgData, "$S")
        While nDollarPtr > 0
          ; debugMsg(sProcName, "sMsgData=" + sMsgData + ", nDollarPtr=" + nDollarPtr)
          ; next string parameter ($S1 or $S2) found
          If Mid(sMsgData, nDollarPtr+3, 1) = "."
            ; parameter has a specified length for the string value
            sParameter = Mid(sMsgData, nDollarPtr, 5) ; sParameter will be something like "$S2.2"
            nParamLength = Val(Right(sParameter, 1))  ; nParamLength will be in the range 2-9 (probably no more than 3)
          Else
            sParameter = Mid(sMsgData, nDollarPtr, 3) ; sParameter will be something like "$S2"
            nParamLength = 0                          ; 0 means no specific length
          EndIf
          ; debugMsg(sProcName, "nDollarPtr=" + nDollarPtr + ", sParameter=" + sParameter + ", nParamLength=" + nParamLength)
          Select Mid(sParameter, 3, 1)
              ; All of the following ReplaceString() calls require the final parameter NbOccurrences to be 1, which is why the preceding trailing parameters are also included.
            Case "1"
              If nParamLength > 0
                sTmpMsgData = ReplaceString(sMsgData, sParameter, Right(sHexTenZeros + aRemDevParamValuesAndCodes(nMsgIndex)\sParamS1Code, (nParamLength * 3)), #PB_String_CaseSensitive, 1, 1)
                ; In the above ReplaceString(), nParamLength is multiplied by 3 because datacodes are in hex separated by a space, eg parameter "12" is stored in datacodes as "31 32"
              Else
                sTmpMsgData = ReplaceString(sMsgData, sParameter, aRemDevParamValuesAndCodes(nMsgIndex)\sParamS1Code, #PB_String_CaseSensitive, 1, 1)
              EndIf
            Case "2"
              If nParamLength > 0
                sTmpMsgData = ReplaceString(sMsgData, sParameter, Right(sHexTenZeros + aRemDevParamValuesAndCodes(nMsgIndex)\sParamS2Code, (nParamLength * 3)), #PB_String_CaseSensitive, 1, 1)
                ; In the above ReplaceString(), nParamLength is multiplied by 3 because datacodes are in hex separated by a space, eg parameter "12" is stored in datacodes as "31 32"
              Else
                sTmpMsgData = ReplaceString(sMsgData, sParameter, aRemDevParamValuesAndCodes(nMsgIndex)\sParamS2Code, #PB_String_CaseSensitive, 1, 1)
              EndIf
          EndSelect
          ; debugMsg(sProcName, "sTmpMsgData=" + sTmpMsgData)
          sMsgData = sTmpMsgData
          nDollarPtr = FindString(sMsgData, "$S")
        Wend
        sTmpMsgData = ReplaceString(sMsgData, "  ", " ") ; convert any double-spaces to single-spaces
        sMsgData = sTmpMsgData
        If LCase(Left(\sRemDevMsgType,4)) = "mute"
          If \nRemDevMuteAction = #SCS_MUTE_ON
            sReqdMsgData = Trim(StringField(sMsgData, 1, ";"))
          Else
            sReqdMsgData = Trim(StringField(sMsgData, 2, ";"))
          EndIf
        Else
          sReqdMsgData = Trim(sMsgData)
        EndIf
        nItemCount = CountString(sReqdMsgData, " ") + 1
        
        For nItemPass = 1 To 2
          ;{
          ; Since the MIDI message will be built in a memory location (*MidiData), we need to calculate the required memory size BEFORE we start Poking data into that memory location.
          ; So we use two passes of the following code - pass 1 to calculate the required memory size, and pass 2 to allocate that memory and then poke data into the memory location.
          If nItemPass = 2
            ; debugMsg(sProcName, "nMemoryPtr(reqd memory size)=" + nMemoryPtr)
            If nMemoryPtr = 0
              Break
            Else
              If *MidiData = 0
                *MidiData = AllocateMemory(nMemoryPtr, #PB_Memory_NoClear)
              ElseIf nMemoryPtr > MemorySize(*MidiData)
                *MidiData = ReAllocateMemory(*MidiData, nMemoryPtr, #PB_Memory_NoClear)
              EndIf
            EndIf
          EndIf
          nMemoryPtr = 0
          nP1Value = aRemDevParamValuesAndCodes(nMsgIndex)\nParamP1Value
          ; debugMsg0(sProcName, "nP1Value=" + nP1Value)
          nHTUValue = nP1Value + 1
          nP2Value = aRemDevParamValuesAndCodes(nMsgIndex)\nParamP2Value
          sP1Code = aRemDevParamValuesAndCodes(nMsgIndex)\sParamS1Code
          sP2Code = aRemDevParamValuesAndCodes(nMsgIndex)\sParamS2Code
          For nItemNr = 1 To nItemCount
            sItem = StringField(sReqdMsgData, nItemNr, " ")
            nByteValue = 0
            bIgnoreThisByte = #False ; see code below for $h and $t
            sMathOperator = "+"
            nPos = 1
            bParamPresent = #False
            While nPos <= Len(sItem)
              sItemPart = CSRD_GetNextPart(sItem, nPos)
              nItemPartLength = Len(sItemPart)
              If nItemPartLength = 0
                Break
              EndIf
              nItemPartValue = 0
              Select sItemPart
                Case "$P1"
                  nItemPartValue = nP1Value
                  bParamPresent = #True
                Case "$P2"
                  nItemPartValue = nP2Value
                  bParamPresent = #True
                Case "$V1", "$V2"
                  ; debugMsg(sProcName, "*rCtrlSend\sRemDevLevel=" + *rCtrlSend\sRemDevLevel)
                  If *rCtrlSend\sRemDevLevel = #SCS_INF_DBLEVEL
                    nItemPartValue = 0
                  Else
                    fRemDevLevel = ValF(*rCtrlSend\sRemDevLevel)
                    ; debugMsg(sProcName, "fRemDevLevel=" + StrF(fRemDevLevel,2))
                    If sItemPart = "$V1"
                      nItemPartValue = CSRD_GetFaderValueByteForRemDevMsgType(*rCtrlSend\nRemDevMsgType, fRemDevLevel, 1)
                    Else
                      nItemPartValue = CSRD_GetFaderValueByteForRemDevMsgType(*rCtrlSend\nRemDevMsgType, fRemDevLevel, 2)
                    EndIf
                  EndIf
                Case "$H", "$h" ; 'Hundreds', eg if nHTUValue = 234 then nByteValue is to be set to 2 (initially added for Aurus)
                                ; Uppercase H means always include this byte. Lowercase h means ignore this byte if nHTUValue < 100.
                  If sItemPart = "$h" And nHTUValue < 100
                    bIgnoreThisByte = #True
                  Else
                    nByteValue + (nHTUValue / 100)
                  EndIf
                Case "$T", "$t" ; 'Tens', eg if nHTUValue = 234 then nByteValue is to be set to 3 (initially added for Aurus)
                                ; Uppercase T means always include this byte. Lowercase t means ignore this byte if nHTUValue < 10.
                  If sItemPart = "$t" And nHTUValue < 10
                    bIgnoreThisByte = #True
                  Else
                    nByteValue + ((nHTUValue % 100) / 10)
                  EndIf
                Case "$U", "$u" ; 'Units', eg if nHTUValue = 234 then nByteValue is to be set to 4 (initially added for Aurus)
                  nByteValue + (nHTUValue % 10)
                Default
                  For nCharPtr = 1 To Len(sItemPart)
                    sChar = Mid(sItemPart, nCharPtr, 1)
                    Select sChar
                      Case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"
                        ; hexadecimal character
                        If nCharPtr = 1
                          nItemPartValue = hexToDec(sChar)
                        ElseIf nCharPtr = 2 Or nCharPtr = 3 ; Added "Or nCharPtr = 3" 22Aug2022 11.9.5
                          nItemPartValue = (nItemPartValue * 16) + hexToDec(sChar)
                        EndIf
                      Case "N"
                        ; MIDI channel (MIDI channel that the mixer or device expects MIDI messages to use, ie this is not a mixer fader channel)
                        If nCharPtr = 1
                          nItemPartValue = nCtrlMidiChannel - 1
                        ElseIf nCharPtr = 2 Or nCharPtr = 3 ; Added "Or nCharPtr = 3" 22Aug2022 11.9.5
                          nItemPartValue = (nItemPartValue * 16) + (nCtrlMidiChannel - 1)
                        EndIf
                    EndSelect
                  Next nCharPtr
              EndSelect
              Select sMathOperator
                Case "+"
                  nByteValue + nItemPartValue
                Case "-"
                  nByteValue - nItemPartValue
                Case "*"
                  nByteValue * nItemPartValue
                Case "/"
                  nByteValue / nItemPartValue
                Case "%" ; Added "%" 8Apr2022 11.9.1az following forum bug report from 'SchauSbg'
                  nByteValue % nItemPartValue
                Case "~" ; Added "~" 22Aug2022 11.9.5
                  nByteValue * (nItemPartValue * -1)
                Case "#" ; Added 31Aug2022 11.9.5.1
                  nCustomisedAlgorithm = nItemPartValue
                  nAlgorithmParamValue = nByteValue
                  ; debugMsg(sProcName, ".. nCustomisedAlgorithm=" + nCustomisedAlgorithm + ", nAlgorithmParamValue=" + nAlgorithmParamValue)
                Default
                  nByteValue + nItemPartValue
              EndSelect
              ; debugMsg(sProcName, ".. nByteValue=" + nByteValue)
              nPos + nItemPartLength
              If nPos < Len(sItem)
                sChar = Mid(sItem, nPos, 1)
                ; debugMsg(sProcName, "sChar=" + sChar + ", nPos=" + nPos + ", sItem=" + sItem)
                Select sChar
                  Case "+", "-", "*", "/", "%", "~", "#" ; Added "%" 8Apr2022 11.9.1az following forum bug report from 'SchauSbg' ; Added "~" 22Aug2022 11.9.5 ; Added "#" 31Aug2022 11.9.5.1
                    sMathOperator = sChar
                    ; debugMsg(sProcName, "sMathOperator=" + sMathOperator)
                    nPos + 1
                EndSelect
              EndIf
            Wend
            If bIgnoreThisByte = #False
              If nCustomisedAlgorithm = 0 ; Test added 31Aug2022 11.9.5.1
                If bParamPresent
                  ; debugMsg(sProcName, "nSkipParamValuesStart=" + nSkipParamValuesStart + ", nSkipParamValuesEnd=" + nSkipParamValuesEnd)
                  If nSkipParamValuesStart >= 0
                    If nByteValue >= nSkipParamValuesStart
                      nByteValue + (nSkipParamValuesEnd - nSkipParamValuesStart + 1)
                    EndIf
                    ; debugMsg(sProcName, "nByteValue=" + nByteValue)
                  EndIf
                EndIf
                If nItemPass = 2
                  ; Poking data into the memory location only permitted in the second pass, as the required memory is allocated at the start of this pass
                  nMemoryByte = nByteValue
                  ; debugMsg(sProcName, "nByteValue=$" + Hex(nByteValue) + ", nMemoryByte=$" + Hex(nByteValue, #PB_Byte) + ", calling PokeA(*MidiData+" + nMemoryPtr + ", nMemoryByte)")
                  PokeA(*MidiData+nMemoryPtr, nMemoryByte)
                EndIf
                nMemoryPtr + 1
                ; debugMsg(sProcName, "nItemPass=" + nItemPass + ", nMemoryPtr=" + nMemoryPtr)
              EndIf
            EndIf
          Next nItemNr
          If nCustomisedAlgorithm = 2
            If nItemPass = 2
              PokeA(*MidiData+nMemoryPtr, $F7)
            EndIf
            nMemoryPtr + 1
          EndIf
          ;}
        Next nItemPass
        
        ; debugMsg(sProcName, "nMemoryPtr=" + nMemoryPtr)
        If nCustomisedAlgorithm > 0
          ;{
          Select nCustomisedAlgorithm
            Case 1 ; X32 GoCue
              If *MidiData = 0
                *MidiData = AllocateMemory(2, #PB_Memory_NoClear)
              ElseIf 2 > MemorySize(*MidiData)
                *MidiData = ReAllocateMemory(*MidiData, 2, #PB_Memory_NoClear)
              EndIf
              Select nAlgorithmParamValue
                Case 1 To 128
                  PokeA(*MidiData, $C2)
                  PokeA(*MidiData+1, nAlgorithmParamValue - 1)
                Case 129 To 256
                  PokeA(*MidiData, $C3)
                  PokeA(*MidiData+1, nAlgorithmParamValue - 129)
                Case 257 To 384
                  PokeA(*MidiData, $C4)
                  PokeA(*MidiData+1, nAlgorithmParamValue - 257)
                Case 385 To 512 ; actual maximum X32 cue number is 500
                  PokeA(*MidiData, $C5)
                  PokeA(*MidiData+1, nAlgorithmParamValue - 385)
              EndSelect
              nMemoryPtr = 2 ; Changed 2Sep2022 11.9.5.1ab
          EndSelect
          ;}
        EndIf
        nDataLength = nMemoryPtr
        If nDataLength >  0
          ;{
          gaMidiOutHdr(nMidiOutPort)\lpData = *MidiData
          gaMidiOutHdr(nMidiOutPort)\dwBufferLength = nDataLength
          gaMidiOutHdr(nMidiOutPort)\dwBytesRecorded = 0
          gaMidiOutHdr(nMidiOutPort)\dwUser = 0
          gaMidiOutHdr(nMidiOutPort)\dwFlags = 0
          For n = 0 To (nDataLength - 1)
            sMsg + decToHex2(PeekA(*MidiData+n)) + " "
          Next n
          debugMsg3(sProcName, "gaMidiOutHdr(" + nMidiOutPort + ")\dwBufferLength=" + gaMidiOutHdr(nMidiOutPort)\dwBufferLength + ", Data=" + RTrim(sMsg))
          
          If gaMidiOutDevice(nMidiOutPort)\hMidiOut <> 0
            ;{
            nMidiResult = midiOutPrepareHeader_(gaMidiOutDevice(nMidiOutPort)\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              debugMsg2(sProcName, "(\hMidiOut) midiOutPrepareHeader_(" + gaMidiOutDevice(nMidiOutPort)\hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
              ShowMMErr(sProcName, "midiOutPrepareHeader: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutLongMsg_(gaMidiOutDevice(nMidiOutPort)\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              debugMsg2(sProcName, "midiOutLongMsg_(" + gaMidiOutDevice(nMidiOutPort)\hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
            EndIf
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutLongMsg_(gaMidiOutDevice(nMidiOutPort)\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
                debugMsg2(sProcName, "midiOutLongMsg_(" + gaMidiOutDevice(nMidiOutPort)\hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + ", " + nSizeOfHdr + ")", nMidiResult)
              Wend
            EndIf
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutLongMsg: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutUnprepareHeader_(gaMidiOutDevice(nMidiOutPort)\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader_(" + gaMidiOutDevice(nMidiOutPort)\hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendNRPN to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            ;}
          EndIf
          ;}
        EndIf ; EndIf nDataLength >  0
      Next nMsgIndex
    EndWith
  EndIf ; EndIf nMidiOutPort >= 0
  
  ProcedureReturn sPortName
  
EndProcedure

Procedure ShowMMErr(pProcName.s, InFunct.s, MMErr.l)
  PROCNAMEC()
  Protected sMsg.s, sMsg2.s
  
  sMsg = LSet(" ", 520) ; needs to be up to 255, but double plus extra for safety re unicode and possible null terminators
  If FindString(InFunct, "out", 1) = 0
    midiInGetErrorText_(MMErr, sMsg, 255)
  Else
    midiOutGetErrorText_(MMErr, sMsg, 255)
  EndIf
  sMsg2 = pProcName + " " + InFunct + #CRLF$ + sMsg + #CRLF$
  debugMsg(sProcName, sMsg2)
  WMN_setStatusField(" " + sMsg2, #SCS_STATUS_ERROR)
EndProcedure

Procedure TraceMMErr(pProcName.s, InFunct.s, MMErr.l)
  PROCNAMEC()
  Protected sMsg.s, sMsg2.s
  
  sMsg = LSet(" ", 520) ; needs to be up to 255, but double plus extra for safety re unicode and possible null terminators
  If FindString(InFunct, "out", 1) = 0
    midiInGetErrorText_(MMErr, sMsg, 255)
  Else
    midiOutGetErrorText_(MMErr, sMsg, 255)
  EndIf
  sMsg2 = pProcName + " " + InFunct + #CRLF$ + sMsg + #CRLF$
  debugMsg(sProcName, sMsg2)
EndProcedure

Procedure loadMidiControl(bEditor)
  PROCNAMEC()
  Protected d, n, m
  Protected sLogicalDev.s, nDevMapDevPtr, nMidiInPhysicalDevPtr
  Protected sMsg.s
  
  ; debugMsg0(sProcName, #SCS_START + ", bEditor=" + strB(bEditor))
  
  For n = 0 To ArraySize(gaMidiControl())
    gaMidiControl(n) = grMidiControlDef
  Next n
  
  If bEditor  ; load grMidiControl from grMapsForDevChgs\aDevMap
    For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      If grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
        sLogicalDev = grProdForDevChgs\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
        If nDevMapDevPtr >= 0
          nMidiInPhysicalDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nMidiInPhysicalDevPtr
          If nMidiInPhysicalDevPtr >= 0
            With gaMidiControl(nMidiInPhysicalDevPtr)
              \sMidiInName = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
              \nMidiChannel = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nMidiChannel
              \nCtrlMethod = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nCtrlMethod
              \nMscMmcMidiDevId = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nMscMmcMidiDevId
              \nMscCommandFormat = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nMscCommandFormat
              \bMMCApplyFadeForStop = grProdForDevChgs\aCueCtrlLogicalDevs(d)\bMMCApplyFadeForStop ; Added 16Nov2020 11.8.3.3ah
              \nGoMacro = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nGoMacro
              For m = 0 To #SCS_MAX_MIDI_COMMAND
                \aMidiCommand[m] = grProdForDevChgs\aCueCtrlLogicalDevs(d)\aMidiCommand[m]
              Next m
              If grLicInfo\bExtFaderCueControlAvailable
                \nExtFaderThresholdVV = grProdForDevChgs\aCueCtrlLogicalDevs(d)\aMidiCommand[#SCS_MIDI_EXT_FADER]\nVV
              EndIf
              Select \nCtrlMethod
                Case #SCS_CTRLMETHOD_NOTE, #SCS_CTRLMETHOD_PC127, #SCS_CTRLMETHOD_ETC_AB, #SCS_CTRLMETHOD_ETC_CD, #SCS_CTRLMETHOD_PALLADIUM, #SCS_CTRLMETHOD_CUSTOM
                  \nBase = 1
                Case #SCS_CTRLMETHOD_PC128
                  \nBase = 0
                Default
                  ; shouldn't get here
                  \nBase = 0
              EndSelect
              debugMsg(sProcName, "gaMidiControl(" + nMidiInPhysicalDevPtr + ")\sMidiInName=" + \sMidiInName + ", \nMidiChannel=" + \nMidiChannel + ", \nCtrlMethod=" + decodeCtrlMethod(\nCtrlMethod) + ", \nExtFaderThresholdVV=" + \nExtFaderThresholdVV)
              gaMidiInDevice(nMidiInPhysicalDevPtr)\bCueControl = #True
              ; debugMsg0(sProcName, "gaMidiInDevice(" + nMidiInPhysicalDevPtr + ")\bCueControl=" + strB(gaMidiInDevice(nMidiInPhysicalDevPtr)\bCueControl))
            EndWith
          EndIf
        EndIf
      EndIf
    Next d
    
  Else  ; bEditor = #False
    For d = 0 To grProd\nMaxCueCtrlLogicalDev
      If grProd\aCueCtrlLogicalDevs(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
        sLogicalDev = grProd\aCueCtrlLogicalDevs(d)\sCueCtrlLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
        If nDevMapDevPtr >= 0
          nMidiInPhysicalDevPtr = grMaps\aDev(nDevMapDevPtr)\nMidiInPhysicalDevPtr
          If nMidiInPhysicalDevPtr >= 0
            With gaMidiControl(nMidiInPhysicalDevPtr)
              \sMidiInName = grMaps\aDev(nDevMapDevPtr)\sPhysicalDev
              \nMidiChannel = grProd\aCueCtrlLogicalDevs(d)\nMidiChannel
              \nCtrlMethod = grProd\aCueCtrlLogicalDevs(d)\nCtrlMethod
              \nMscMmcMidiDevId = grProd\aCueCtrlLogicalDevs(d)\nMscMmcMidiDevId
              \nMscCommandFormat = grProd\aCueCtrlLogicalDevs(d)\nMscCommandFormat
              \bMMCApplyFadeForStop = grProd\aCueCtrlLogicalDevs(d)\bMMCApplyFadeForStop ; Added 16Nov2020 11.8.3.3ah
              \nGoMacro = grProd\aCueCtrlLogicalDevs(d)\nGoMacro
              For m = 0 To #SCS_MAX_MIDI_COMMAND
                \aMidiCommand[m] = grProd\aCueCtrlLogicalDevs(d)\aMidiCommand[m]
              Next m
              If grLicInfo\bExtFaderCueControlAvailable
                \nExtFaderThresholdVV = grProd\aCueCtrlLogicalDevs(d)\aMidiCommand[#SCS_MIDI_EXT_FADER]\nVV
              EndIf
              Select \nCtrlMethod
                Case #SCS_CTRLMETHOD_NOTE, #SCS_CTRLMETHOD_PC127, #SCS_CTRLMETHOD_ETC_AB, #SCS_CTRLMETHOD_ETC_CD, #SCS_CTRLMETHOD_PALLADIUM, #SCS_CTRLMETHOD_CUSTOM
                  \nBase = 1
                Case #SCS_CTRLMETHOD_PC128
                  \nBase = 0
                Default
                  ; shouldn't get here
                  \nBase = 0
              EndSelect
              sMsg = "gaMidiControl(" + nMidiInPhysicalDevPtr + ")\sMidiInName=" + \sMidiInName + ", \nMidiChannel=" + \nMidiChannel + ", \nCtrlMethod=" + decodeCtrlMethod(\nCtrlMethod)
              If \nExtFaderThresholdVV >= 0
                sMsg + ", \nExtFaderThresholdVV=" + \nExtFaderThresholdVV
              EndIf
              debugMsg(sProcName, sMsg)
              For m = 0 To #SCS_MAX_MIDI_COMMAND
                If \aMidiCommand[m]\nCmd >= 0
                  debugMsg(sProcName, "\aMidiCommand[" + m + "]\nCmd=$" + Hex(\aMidiCommand[m]\nCmd) + ", \nCC=" + \aMidiCommand[m]\nCC + ", \nVV=" + \aMidiCommand[m]\nVV)
                EndIf
              Next m
              gaMidiInDevice(nMidiInPhysicalDevPtr)\bCueControl = #True
              ; debugMsg0(sProcName, "gaMidiInDevice(" + nMidiInPhysicalDevPtr + ")\bCueControl=" + strB(gaMidiInDevice(nMidiInPhysicalDevPtr)\bCueControl))
            EndWith
          EndIf
        EndIf
      EndIf
    Next d
    
  EndIf
  
EndProcedure

Procedure getFirstMidiDevice(bInputDevice)
  PROCNAMEC()
  Protected nDevPtr = -1  ; = -1 added 30Oct2015 11.4.1.2f
  Protected d
  
  If bInputDevice
    For d = 0 To (gnNumMidiInDevs-1)
      If gaMidiInDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  Else
    For d = 0 To (gnNumMidiOutDevs-1)
      If gaMidiOutDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  EndIf
  ProcedureReturn nDevPtr
EndProcedure

Procedure getNextMidiDevice(bInputDevice, nCurrDevPtr)
  PROCNAMEC()
  Protected nDevPtr = -1  ; = -1 added 30Oct2015 11.4.1.2f
  Protected d
  
  nDevPtr = nCurrDevPtr
  If bInputDevice
    For d = (nCurrDevPtr+1) To (gnNumMidiInDevs-1)
      If gaMidiInDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  Else
    For d = (nCurrDevPtr+1) To (gnNumMidiOutDevs-1)
      If gaMidiOutDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  EndIf
  ProcedureReturn nDevPtr
EndProcedure

Procedure getLastMidiDevice(bInputDevice)
  PROCNAMEC()
  Protected nDevPtr = -1  ; = -1 added 30Oct2015 11.4.1.2f
  Protected d
  
  If bInputDevice
    For d = (gnNumMidiInDevs-1) To 0 Step -1
      If gaMidiInDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  Else
    For d = (gnNumMidiOutDevs-1) To 0 Step -1
      If gaMidiOutDevice(d)\bIgnoreDev = #False
        nDevPtr = d
        Break
      EndIf
    Next d
  EndIf
  ProcedureReturn nDevPtr
EndProcedure

Procedure.s decodeMTCSendState(nMTCSendState)
  PROCNAMEC()
  ; only used for debugging
  Protected sMTCSendState.s
  
  Select nMTCSendState
    Case #SCS_MTC_STATE_IDLE
      sMTCSendState = "SCS_MTC_STATE_IDLE"
    Case #SCS_MTC_STATE_PRE_ROLL ; full-frame sent but sending quarter-frames not yet started
      sMTCSendState = "SCS_MTC_STATE_PRE_ROLL"
    Case #SCS_MTC_STATE_RUNNING  ; sending quarter-frames
      sMTCSendState = "SCS_MTC_STATE_RUNNING"
    Case #SCS_MTC_STATE_PAUSED   ; quarter-frames paused by SCS cue or operator
      sMTCSendState = "SCS_MTC_STATE_PAUSED"
    Case #SCS_MTC_STATE_STOPPED  ; quarter-frames stopped by SCS cue or operator
      sMTCSendState = "SCS_MTC_STATE_STOPPED"
    Default
      sMTCSendState = Str(nMTCSendState)
  EndSelect
  ProcedureReturn sMTCSendState
  
EndProcedure

Procedure initQPCIfReqd()
  PROCNAMEC()
  ; obtain information about the QueryPerformanceTimer if required
  ; based on PB Forum topic "Hi-res timing delayer" (http://forums.purebasic.com/english/viewtopic.php?p=76173) posted by Psychophanta - see posting dated Thu Jul 15, 2010
  Protected freq.q, periodns.d, t1.q, t2.q, calldelay.q
  Protected periodms.d
  
  With grQPCInfo
    If \bQPCInitDone = #False
      ; determine timer max resolution:
      If QueryPerformanceFrequency_(@freq.q)
        \bQPCAvailable = #True
        If freq < 0
          freq ! $8000000000000000
          periodns.d = freq
          periodns + $7FFFFFFFFFFFFFFF + 1
          periodms = 1E3/periodns  ; do this before "periodns = 1E9/periodns"
          periodns = 1E9/periodns
        Else
          periodms = 1E3/freq
          periodns = 1E9/freq
        EndIf
        ; MessageRequester("Timing resolution info","freq=" + Str(freq) + ", Resolution (used time per piece) in this machine is: "+StrD(periodns)+" nanosecs")
        \sQPCInfo = "Timing resolution info: freq=" + Str(freq) + Chr(10) + "Resolution (used time per piece) in this machine is: "+StrD(periodns)+" nanosecs, " + StrD(periodms) + " milliseconds"
      Else
        \bQPCAvailable = #False
        ; shouldn't get here if running under Windows XP or later
        ; MessageRequester("Sorry!","No High-res timer allowed by this machine"):End
        \sQPCInfo = "No High-res timer allowed by this machine"
      EndIf
      
      If \bQPCAvailable
        ; determine API call delay:
        QueryPerformanceCounter_(@t1.q)
        QueryPerformanceCounter_(@t2.q)
        calldelay.q = t2-t1
        debugMsg(sProcName, "calldelay=" + Str(calldelay))
        ; MessageRequester("","Time used by API call QueryPerformanceCounter_() was ~ "+StrD(calldelay*periodns)+" nanosecs")
        \sQPCInfo + Chr(10) + "Time used by API call QueryPerformanceCounter_() was ~ "+StrD(calldelay*periodns)+" nanosecs"
      EndIf
      
      \qQPCFrequency = freq
      \dQPCPeriodNanoSecs = periodns
      \dQPCPeriodMilliseconds = periodms
      \qQPCCallDelay = calldelay
      \bQPCInitDone = #True
      debugMsg(sProcName, \sQPCInfo)
      
    EndIf
  EndWith
  ProcedureReturn grQPCInfo\bQPCAvailable
EndProcedure

Procedure checkIfMTCCuesIncluded()
  PROCNAMEC()
  ; NOTE: For MTC only, not LTC
  Protected i, j
  Protected bMTCCuesIncluded
  
  For i = 1 To gnLastCue
    If aCue(i)\bCueCurrentlyEnabled
      If aCue(i)\bSubTypeU
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If (aSub(j)\bSubEnabled) And (aSub(j)\bSubTypeU)
            If aSub(j)\nMTCType = #SCS_MTC_TYPE_MTC
              bMTCCuesIncluded = #True
              Break 2 ; break i loop
            EndIf
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    EndIf
  Next i
  
  debugMsg(sProcName, "bMTCCuesIncluded=" + strB(bMTCCuesIncluded))
  If bMTCCuesIncluded
    debugMsg(sProcName, "calling initQPCIfReqd()")
    initQPCIfReqd()
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bMTCCuesIncluded))
  ProcedureReturn bMTCCuesIncluded
EndProcedure

Procedure initMTCSendControlForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  ; NOTE: For MTC AND LTC
  Protected nLinkedToSubPtr
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With grMTCSendControl
      \nMTCSubPtr = pSubPtr
      \nMTCType = aSub(pSubPtr)\nMTCType
      M2T_setLinkedAudInfo(grMTCSendControlDef\nMTCLinkedToAudPtr)
      \bMTCSyncNextQtrFrameWithAud = grMTCSendControlDef\bMTCSyncNextQtrFrameWithAud
      nLinkedToSubPtr = aSub(pSubPtr)\nMTCLinkedToAFSubPtr
      If nLinkedToSubPtr >= 0
        If aSub(nLinkedToSubPtr)\bSubTypeF
          M2T_setLinkedAudInfo(aSub(nLinkedToSubPtr)\nFirstAudIndex)
          \bMTCSyncNextQtrFrameWithAud = #True
        EndIf
      EndIf
      debugMsg(sProcName, "grMTCSendControl\nMTCSubPtr=" + getSubLabel(\nMTCSubPtr) + ", \nMTCLinkedToAudPtr=" + getAudLabel(\nMTCLinkedToAudPtr))
      \nMTCStartTime = aSub(pSubPtr)\nMTCStartTime
      \nMTCFrameRate = aSub(pSubPtr)\nMTCFrameRate
      \nMTCPreRoll = aSub(pSubPtr)\nMTCPreRoll
      
      Select \nMTCFrameRate
        Case #SCS_MTC_FR_24
          \dMTCMillisecondsPerFrame = 1000.0 / 24.0
          \nMTCMillisecondsPerFrame = -1
          \nMTCFrameRateX100 = 2400
          \nSMPTEType = 0
          \nMTCPieceDelayTime = Round(2000 / 24 / 8, #PB_Round_Down)
          
        Case #SCS_MTC_FR_25
          \dMTCMillisecondsPerFrame = 1000.0 / 25.0
          \nMTCMillisecondsPerFrame = 40
          \nMTCFrameRateX100 = 2500
          \nSMPTEType = 1 << 9 ; shift left 9 bits ready to 'OR' (|) into the 8th quarter-frame message (will be shifted back 4 bits for full-frame message)
          \nMTCPieceDelayTime = Round(2000 / 25 / 8, #PB_Round_Down)
          
        Case #SCS_MTC_FR_29_97
          \dMTCMillisecondsPerFrame = 1000.0 / 29.97
          \nMTCMillisecondsPerFrame = -1
          \nMTCFrameRateX100 = 2997
          \nSMPTEType = 2 << 9
          \nMTCPieceDelayTime = Round(2000 / 29.97 / 8, #PB_Round_Down)
          
        Case #SCS_MTC_FR_30
          \dMTCMillisecondsPerFrame = 1000.0 / 30.0
          \nMTCMillisecondsPerFrame = -1
          \nMTCFrameRateX100 = 3000
          \nSMPTEType = 3 << 9
          \nMTCPieceDelayTime = Round(2000 / 30 / 8, #PB_Round_Down)
          
        Default
          ; shouldn't get here
          \dMTCMillisecondsPerFrame = 1000.0 / 30.0
          \nMTCMillisecondsPerFrame = -1
          \nMTCFrameRateX100 = 3000
          \nSMPTEType = 3 << 9
          \nMTCPieceDelayTime = Round(2000 / 30 / 8, #PB_Round_Down)
          
      EndSelect
      ; \nMTCPieceDelayTime - grQPCInfo\qQPCCallDelay - 1  ; reduce by 1ms (per piece) to ensure all 8 pieces sent WITHIN time of two frames, allowing for other processing overheads
      ; modified 27Mar2020 11.8.2.3ag - was previously just "\nMTCPieceDelayTime - grQPCInfo\qQPCCallDelay"
      If grQPCInfo\qQPCCallDelay > 0
        \nMTCPieceDelayTime - grQPCInfo\qQPCCallDelay
      Else
        \nMTCPieceDelayTime - 1
      EndIf
      ; end modified 27Mar2020 11.8.2.3ag
      
      debugMsg(sProcName, "grMTCSendControl\nMTCFrameRate=" + decodeMTCFrameRate(\nMTCFrameRate) + ", \dMTCMillisecondsPerFrame=" + StrD(\dMTCMillisecondsPerFrame,4) +
                          ", \nMTCFrameRateX100=" + \nMTCFrameRateX100 +
                          ", \nMTCMillisecondsPerFrame=" + \nMTCMillisecondsPerFrame +
                          ", grQPCInfo\qQPCCallDelay=" + grQPCInfo\qQPCCallDelay +
                          ", \nMTCPieceDelayTime=" + \nMTCPieceDelayTime)
      
      If \nMTCPieceDelayTime < 0
        \nMTCPieceDelayTime = 0
      EndIf
      
      \nHours = (\nMTCStartTime >> 24) & $1F
      \nMinutes = (\nMTCStartTime >> 16) & $3F
      \nSeconds = (\nMTCStartTime >> 8) & $3F
      \nFrames = \nMTCStartTime & $1F
      \qMTCStartTimeAsMicroseconds = convertMTCTimeToMicroseconds(\nMTCStartTime)
      
      debugMsg(sProcName, "\nMTCStartTime=" + decodeMTCTime(\nMTCStartTime) + ", \qMTCStartTimeAsMicroseconds=" + \qMTCStartTimeAsMicroseconds)
      debugMsg(sProcName, "\nHours=" + \nHours + ", nMinutes=" + \nMinutes + ", nSeconds=" + \nSeconds + ", nFrames=" + \nFrames)
      
      If aSub(pSubPtr)\nMTCType = #SCS_MTC_TYPE_MTC
        \bMTCSendControlActive = #True
      EndIf
      
      If grMTCControl\nMaxCueOrSubForMTC >= 0
        grMTCControl\nTimeCode = \nMTCStartTime
        debugMsg(sProcName, "grMTCControl\nTimeCode=$" + Hex(grMTCControl\nTimeCode,#PB_Long))
        grMTCControl\nPrevTimeCodeProcessed = \nMTCStartTime - 1
        grMTCControl\bClearPrevTimeCodeProcessed = #True  ; added 29Oct2015 11.4.1.2e
        debugMsg(sProcName, "\nTimeCode=" + decodeMTCTime(grMTCControl\nTimeCode) + " ($" + Hex(grMTCControl\nTimeCode,#PB_Long) + ")" +
                            ", \nPrevTimeCodeProcessed=" + decodeMTCTime(grMTCControl\nPrevTimeCodeProcessed) + " ($" + Hex(grMTCControl\nPrevTimeCodeProcessed,#PB_Long) + ")" +
                            ", \bClearPrevTimeCodeProcessed=" + strB(grMTCControl\bClearPrevTimeCodeProcessed))
      EndIf
      
    EndWith
  EndIf
  
EndProcedure

Procedure.s SendMTCFullFrame()
  PROCNAMEC()
  Protected sPortName.s, nDataLength
  Static *MidiData
  Protected nMidiResult.l   ; long
  Protected qTimeoutTime.q
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bLockedMutex
  Protected bEnttecMidi
  Protected nTryCount, nMidiOutPort
  
  ; MTC 'Full Frame' Documentation
  ;
  ; For cueing the slave to a particular start point, Quarter Frame messages are not used. Instead, an MTC Full Frame message should be sent.
  ; The Full Frame is a SysEx message that encodes the entire SMPTE time in one message as so (in hex):
  ;
  ; F0 7F cc 01 01 hr mn sc fr F7
  ;
  ; cc is the SysEx channel (0 to 127). It is suggested that a device default to using its Manufacturer's SysEx ID number for this channel, giving
  ; the musician the option of changing it. Channel number 0x7F is used to indicate that all devices on the daisy-chain should recognize this Full Frame message.
  ;
  ; The hr, mn, sc, and fr are the hours, minutes, seconds, and frames of the current SMPTE time. The hours byte also contains the SMPTE Type as per
  ; the Quarter Frame's Hours High Nibble message.
  ;
  ; The Full Frame simply cues a slave to a particular SMPTE time. The slave doesn't actually start running until it starts receiving Quarter Frame messages.
  ; (Which implies that a slave is stopped whenever it is not receiving Quarter Frame messages). The master should pause after sending a Full Frame,
  ; and before sending a Quarter Frame, in order to give the slave time to cue to the desired SMPTE time.
  ;
  ; During fast forward or rewind (ie, shuttle) modes, the master should not continuously send Quarter Frame messages, but rather, send Full Frame messages
  ; at regular intervals.
  
  debugMsg(sProcName, #SCS_START)
  
  gsMidiSendError = ""
  
  nMidiOutPort = grMTCSendControl\nMTCCuesPhysicalDevPtr
  With gaMidiOutDevice(nMidiOutPort)
    For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
      bEnttecMidi = \bEnttecMidi
      If grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED
        If (bEnttecMidi = #False) And (\hMidiOut <> 0)
          sPortName = \sName
          nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
          debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(nMidiOutPort), " + nSizeOfHdr + ")", nMidiResult)
          ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver stalled and was restarted
          If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
            debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPort + ")")
            closeAndReopenMidiOutPort(nMidiOutPort)
            Continue ; try again
          EndIf
          ; end added 4Apr2019 11.8.0.2cm
          If nMidiResult <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMTCFullFrame to " + sPortName, nMidiResult)
            ProcedureReturn
          EndIf
        EndIf
      EndIf
      Break ; added 4Apr2019 11.8.0.2cm
    Next nTryCount ; added 4Apr2019 11.8.0.2cm
  EndWith
  
  LockMTCSendMutex(501, #True)
  
  If *MidiData = 0
    *MidiData = AllocateMemory(256)  ; allocate more than enough memory for the data
  EndIf
  
  If *MidiData
    ; construct SysEx message
    With grMTCSendControl
      debugMsg(sProcName, "(frame rate)=" + Str(\nSMPTEType >> 4) + ", \nHours=" + \nHours + ", \nMinutes=" + \nMinutes + ", \nSeconds=" + \nSeconds + ", \nFrames=" + \nFrames)
      nDataLength = 0
      PokeB(*MidiData+nDataLength, $F0)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $7F)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, grMTCSendControl\nMTCChannelNo)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $1)  ; 01 = MIDI Time Code
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $1)  ; 01 = Full Message (02 = User Bits)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nHours | (\nSMPTEType >> 4))
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nMinutes)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nSeconds)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nFrames)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $F7)
      nDataLength + 1
    EndWith
    
    debugMsg(sProcName, "bEnttecMidi=" + strB(bEnttecMidi) + ", gaMidiOutDevice(" + nMidiOutPort + ")\nFTHandle=" + gaMidiOutDevice(nMidiOutPort)\nFTHandle)
    If (bEnttecMidi) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
      With gaMidiOutDevice(nMidiOutPort)
        DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, *MidiData, nDataLength)
      EndWith
    EndIf
    
    If bEnttecMidi = #False
      With gaMidiOutHdr(nMidiOutPort)
        \lpData = *MidiData
        \dwBufferLength = nDataLength
        \dwBytesRecorded = 0
        \dwUser = 0
        \dwFlags = 0
      EndWith
      With gaMidiOutDevice(nMidiOutPort)
        If (\hMidiOut <> 0) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
          sPortName = \sName
          nMidiResult = midiOutPrepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
          If nMidiResult <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiOutPrepareHeader: SendMTCFullFrame to " + sPortName, nMidiResult)
            ProcedureReturn
          EndIf
          nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
          debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
          If nMidiResult = #MIDIERR_NOTREADY
            qTimeoutTime = ElapsedMilliseconds() + 1000
            While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
              Delay(10)
              nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPort), nSizeOfHdr)
              debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPort + "), " + nSizeOfHdr + ")", nMidiResult)
            Wend
          EndIf
          ; debugMsg2(sProcName, "(\hMidiOut) midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(nMidiOutPort), " + nSizeOfHdr + ")", nMidiResult)
          If nMidiResult <> #MMSYSERR_NOERROR
            ShowMMErr(sProcName, "midiOutLongMsg: SendMTCFullFrame to " + sPortName, nMidiResult)
            ProcedureReturn
          EndIf
        EndIf
      EndWith
    EndIf ; EndIf bEnttecMidi = #False
    
    With grMTCSendControl
      ; Added 3Jan2023 11.10.0ab following email from Ian Harding 12Dec2022 that showed some quarter-frame messages sent before the relevant full-frame message on starting a second MTC cue
      \bMTCSuspendThreadUntilFullFrameSent = #False
      debugMsg(sProcName, "grMTCSendControl\bMTCSuspendThreadUntilFullFrameSent=" + strB(\bMTCSuspendThreadUntilFullFrameSent))
      ; End added 3Jan2023 11.10.0ab
      QueryPerformanceCounter_(@\qQPCTimeReady)
      \nMTCSendState = #SCS_MTC_STATE_PRE_ROLL
      debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
      If grMTCControl\nMaxCueOrSubForMTC >= 0
        grMTCControl\nTimeCode = buildMTCTime(\nHours, \nMinutes, \nSeconds, \nFrames)
        debugMsg(sProcName, "grMTCControl\nTimeCode=$" + Hex(grMTCControl\nTimeCode,#PB_Long))
        grMTCControl\nPrevTimeCodeProcessed = adjustMTCBySeconds(grMTCControl\nTimeCode, -1)
        debugMsg(sProcName, "\nTimeCode=" + decodeMTCTime(grMTCControl\nTimeCode) + " ($" + Hex(grMTCControl\nTimeCode,#PB_Long) + ")" +
                            ", \nPrevTimeCodeProcessed=" + decodeMTCTime(grMTCControl\nPrevTimeCodeProcessed) + " ($" + Hex(grMTCControl\nPrevTimeCodeProcessed,#PB_Long) + ")")
      EndIf
      
    EndWith
    
    ; FreeMemory(*MidiData)
    
  EndIf
  
  UnlockMTCSendMutex(#True)
  
  debugMsg(sProcName, #SCS_END + ", returning sPortName=" + sPortName)
  ProcedureReturn sPortName
  
EndProcedure

Procedure.s SendMTCFullFrameForRepos(bMutexAlreadyLocked, bRestarting, bCurrentlyPaused=#False)
  PROCNAMEC()
  Protected sPortName.s, nDataLength
  Static *MidiData
  Protected nMidiResult.l   ; long
  Protected qTimeoutTime.q
  Protected nSizeOfHdr.l = SizeOf(MIDIHDR)  ; long
  Protected bLockedMutex
  Protected bEnttecMidi
  Protected nTryCount, nMidiOutPhysicalDevPtr
  
  debugMsg(sProcName, #SCS_START + ", bMutexAlreadyLocked=" + strB(bMutexAlreadyLocked) + ", bRestarting=" + strB(bRestarting) + ", bCurrentlyPaused=" + strB(bCurrentlyPaused))
  
  ; openMTCCuesPortIfReqd(nMTCCuesPhysicalDevPtr)
  
  gsMidiSendError = ""
  
  nMidiOutPhysicalDevPtr = grMTCSendControl\nMTCCuesPhysicalDevPtr
  If nMidiOutPhysicalDevPtr >= 0 ; Added 26Feb2024 as this could be -1 if 'ignore device this run' was selected
    With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
      For nTryCount = 1 To 2 ; added 4Apr2019 11.8.0.2cm - see comments further down
        bEnttecMidi = \bEnttecMidi
        If bEnttecMidi = #False
          debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutPhysicalDevPtr + ")\hMidiOut=" + \hMidiOut)
          If (\hMidiOut <> 0) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
            sPortName = \sName
            nMidiResult = midiOutUnprepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPhysicalDevPtr), nSizeOfHdr)
            debugMsg2(sProcName, "(\hMidiOut) midiOutUnprepareHeader(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPhysicalDevPtr + "), " + nSizeOfHdr + ")", nMidiResult)
            ; added 4Apr2019 11.8.0.2cm following issue reported by Alberto Rosselli where MOTU MIDI failed after the MOTU ASIO driver stalled and was restarted
            If nMidiResult = #MMSYSERR_NODRIVER And nTryCount = 1
              debugMsg(sProcName, "nMidiResult=#MMSYSERR_NODRIVER; calling closeAndReopenMidiOutPort(" + nMidiOutPhysicalDevPtr + ")")
              closeAndReopenMidiOutPort(nMidiOutPhysicalDevPtr)
              Continue ; try again
            EndIf
            ; end added 4Apr2019 11.8.0.2cm
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutUnprepareHeader: SendMTCFullFrame to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndIf
        Break ; added 4Apr2019 11.8.0.2cm
      Next nTryCount ; added 4Apr2019 11.8.0.2cm
    EndWith
  EndIf
  
  If bMutexAlreadyLocked = #False
    LockMTCSendMutex(502, #True)
  EndIf
  
  With grMTCSendControl
    \qMTCStartTimeAsMicroseconds = (\nHours * 3600000000) + (\nMinutes * 60000000) + (\nSeconds * 1000000)
    \qMTCStartTimeAsMicroseconds + (1000000 * \nFrames * 100 / \nMTCFrameRateX100)
    ; debugMsg(sProcName, "grMTCSendControl\nHours=" + \nHours + ", nMinutes=" + \nMinutes + ", nSeconds=" + \nSeconds + ", nFrames=" + \nFrames)
    ; debugMsg(sProcName, "grMTCSendControl\qMTCStartTimeAsMicroseconds=" + \qMTCStartTimeAsMicroseconds)
    debugMsg(sProcName, "MTC Time: " + RSet(Str(\nHours),2,"0") + ":" + RSet(Str(\nMinutes),2,"0") + ":" + RSet(Str(\nSeconds),2,"0") + ":" + RSet(Str(\nFrames),2,"0"))
  EndWith
  
  If *MidiData = 0
    *MidiData = AllocateMemory(256)  ; allocate more than enough memory for the data
  EndIf
  
  If *MidiData
    ; construct SysEx message
    With grMTCSendControl
      nDataLength = 0
      PokeB(*MidiData+nDataLength, $F0)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $7F)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, grMTCSendControl\nMTCChannelNo)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $1)  ; 01 = MIDI Time Code
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $1)  ; 01 = Full Message (02 = User Bits)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nHours | (\nSMPTEType >> 4))
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nMinutes)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nSeconds)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, \nFrames)
      nDataLength + 1
      PokeB(*MidiData+nDataLength, $F7)
      nDataLength + 1
    EndWith
    
    If nMidiOutPhysicalDevPtr >= 0 ; Added 26Feb2024 as this could be -1 if 'ignore device this run' was selected
      If (bEnttecMidi) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
        With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
          DMX_FTDI_SendData(\nFTHandle, #ENTTEC_SEND_MIDI, *MidiData, nDataLength)
        EndWith
      EndIf
      
      If bEnttecMidi = #False
        
        With gaMidiOutHdr(nMidiOutPhysicalDevPtr)
          \lpData = *MidiData
          \dwBufferLength = nDataLength
          \dwBytesRecorded = 0
          \dwUser = 0
          \dwFlags = 0
        EndWith
        
        With gaMidiOutDevice(nMidiOutPhysicalDevPtr)
          If (\hMidiOut <> 0) And (grSession\nMidiOutEnabled = #SCS_DEVTYPE_ENABLED)
            sPortName = \sName
            nMidiResult = midiOutPrepareHeader_(\hMidiOut, @gaMidiOutHdr(nMidiOutPhysicalDevPtr), nSizeOfHdr)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutPrepareHeader: SendMTCFullFrame to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
            nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPhysicalDevPtr), nSizeOfHdr)
            debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPhysicalDevPtr + ", " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult = #MIDIERR_NOTREADY
              qTimeoutTime = ElapsedMilliseconds() + 1000
              While (nMidiResult = #MIDIERR_NOTREADY) And (ElapsedMilliseconds() < qTimeoutTime)
                Delay(10)
                nMidiResult = midiOutLongMsg_(\hMidiOut, gaMidiOutHdr(nMidiOutPhysicalDevPtr), nSizeOfHdr)
                debugMsg2(sProcName, "midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(" + nMidiOutPhysicalDevPtr + ", " + nSizeOfHdr + ")", nMidiResult)
              Wend
            EndIf
            ; debugMsg2(sProcName, "(\hMidiOut) midiOutLongMsg_(" + \hMidiOut + ", gaMidiOutHdr(nMidiOutPhysicalDevPtr), " + nSizeOfHdr + ")", nMidiResult)
            If nMidiResult <> #MMSYSERR_NOERROR
              ShowMMErr(sProcName, "midiOutLongMsg: SendMTCFullFrame to " + sPortName, nMidiResult)
              ProcedureReturn
            EndIf
          EndIf
        EndWith
        
      EndIf ; EndIf bEnttecMidi = #False
      
    EndIf ; EndIf nMidiOutPhysicalDevPtr >= 0
  
    With grMTCSendControl
      ; debugMsg(sProcName, "bCurrentlyPaused=" + strB(bCurrentlyPaused))
      If bCurrentlyPaused = #False
        ; debugMsg(sProcName, "bRestarting=" + strB(bRestarting))
        If bRestarting
          QueryPerformanceCounter_(@\qQPCTimeReady)
          If \nMTCSendState <> #SCS_MTC_STATE_PRE_ROLL
            \nMTCSendState = #SCS_MTC_STATE_PRE_ROLL
            debugMsg(sProcName, "grMTCSendControl\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
          EndIf
        Else
          QueryPerformanceCounter_(@\qQPCTimeStarted.q)
          debugMsg(sProcName, "grMTCSendControl\qQPCTimeStarted=" + \qQPCTimeStarted)
          \qMinNextElapsedFrame = -1  ; forces first set of quarter frames to be sent
          ; debugMsg(sProcName, "(b)grMTCSendControl\qMinNextElapsedFrame=" + grMTCSendControl\qMinNextElapsedFrame)
          If \nMTCSendState <> #SCS_MTC_STATE_RUNNING
            \nMTCSendState = #SCS_MTC_STATE_RUNNING
            debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
          EndIf
        EndIf
      EndIf
      \bMTCSendRefreshDisplay = #True
      ; debugMsg(sProcName, "grMTCSendControl\bMTCSendRefreshDisplay=" + strB(grMTCSendControl\bMTCSendRefreshDisplay))
      ; debugMsg(sProcName, "\nMTCSendState=" + decodeMTCSendState(\nMTCSendState))
      
      ; Added 3Jan2023 11.10.0ab following email from Ian Harding 12Dec2022 that showed some quarter-frame messages sent before the relevant full-frame message on starting a second MTC cue
      \bMTCSuspendThreadUntilFullFrameSent = #False
      debugMsg(sProcName, "grMTCSendControl\bMTCSuspendThreadUntilFullFrameSent=" + strB(\bMTCSuspendThreadUntilFullFrameSent))
      ; End added 3Jan2023 11.10.0ab
      
      If grMTCControl\nMaxCueOrSubForMTC >= 0
        grMTCControl\nTimeCode = buildMTCTime(\nHours, \nMinutes, \nSeconds, \nFrames)
        ; debugMsg(sProcName, "grMTCControl\nTimeCode=$" + Hex(grMTCControl\nTimeCode,#PB_Long))
        grMTCControl\nPrevTimeCodeProcessed = adjustMTCBySeconds(grMTCControl\nTimeCode, -1)
        debugMsg(sProcName, "\nTimeCode=" + decodeMTCTime(grMTCControl\nTimeCode) + " ($" + Hex(grMTCControl\nTimeCode,#PB_Long) + ")" +
                            ", \nPrevTimeCodeProcessed=" + decodeMTCTime(grMTCControl\nPrevTimeCodeProcessed) + " ($" + Hex(grMTCControl\nPrevTimeCodeProcessed,#PB_Long) + ")")
      EndIf
      
    EndWith
    
    ; FreeMemory(*MidiData)
    
  EndIf
  
  If bMutexAlreadyLocked = #False
    UnlockMTCSendMutex(#True)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning sPortName=" + sPortName)
  ProcedureReturn sPortName
  
EndProcedure

Procedure setMTCAtAudStartIfReqd(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nCuePtr, nSubPtr
  Protected nAFLinkedToMTCSubPtr
  Protected i, j
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    nSubPtr = aAud(pAudPtr)\nSubIndex
    nAFLinkedToMTCSubPtr = aSub(nSubPtr)\nAFLinkedToMTCSubPtr
    If nAFLinkedToMTCSubPtr >= 0
      nCuePtr = aSub(nSubPtr)\nCueIndex
      j = aCue(nCuePtr)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeU And aSub(j)\bSubEnabled
            If (\nSubState >= #SCS_CUE_FADING_IN) And (\nSubState <= #SCS_CUE_FADING_OUT)
              \nMTCMSAtLinkedAudStart = getCurrMTCTimeInMilliseconds()
              debugMsg(sProcName, "aSub(" + getSubLabel(j) + ")\nSubState=" + decodeCueState(\nSubState) + ", \nMTCMSAtLinkedAudStart=" + Str(\nMTCMSAtLinkedAudStart))
            EndIf
            Break
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure sliderValueToMidiValue(nCtrlType, nSliderValue)
  ; PROCNAMEC()
  Protected fTmp.f
  Protected nMidiValue
  
  Select nCtrlType
    Case #SCS_CTRLTYPE_DMX_MASTER
      If (nSliderValue >= 0) And (nSliderValue <= 100)
        fTmp = nSliderValue / 100 * 127
        nMidiValue = fTmp
      EndIf
    Default
      If (nSliderValue >= #SCS_MINVOLUME_SLD) And (nSliderValue <= #SCS_MAXVOLUME_SLD)
        fTmp = nSliderValue / (#SCS_MAXVOLUME_SLD - #SCS_MINVOLUME_SLD) * 127
        nMidiValue = fTmp
      EndIf
  EndSelect
  ; debugMsg(sProcName, "nSliderValue=" + nSliderValue + ", fTmp=" + StrF(fTmp,4) + ", nMidiValue=" + nMidiValue)
  ProcedureReturn nMidiValue
EndProcedure

Procedure midiValueToSliderValue(nCtrlType, nMidiValue)
  ; PROCNAMEC()
  Protected fTmp.f
  Protected nSliderValue
  
  If (nMidiValue >= 0) And (nMidiValue <= 127)
    Select nCtrlType
      Case #SCS_CTRLTYPE_DMX_MASTER, #SCS_CTRLTYPE_DIMMER_CHANNEL ; Changed 18Jul2022 11.9.4
        fTmp = nMidiValue / 127 * 100
      Default
        fTmp = nMidiValue / 127 * (#SCS_MAXVOLUME_SLD - #SCS_MINVOLUME_SLD)
    EndSelect
    nSliderValue = fTmp
  EndIf
  ProcedureReturn nSliderValue
EndProcedure

Procedure sendControllerMsg(nCtrlType, nCtrlSubType, nCtrlNo, nValue)
  PROCNAMEC()
  Protected nCC, nChannel
  
  ; debugMsg(sProcName, #SCS_START + ", nCtrlType=" + decodeCtrlType(nCtrlType) + ", nCtrlSubType=" + nCtrlSubType + ", nCtrlNo=" + nCtrlNo + ", nValue=" + nValue)
  
  nCC = -1
  nChannel = -1
  
  With grCtrlSetup
    Select \nController
      Case #SCS_CTRL_BCF2000, #SCS_CTRL_BCR2000 ; BCF2000, BCR2000 (assumes BCF/BCR set to 'Preset 1')
        ; debugMsg(sProcName, "\nCtrlConfig=" + decodeCtrlConfig(\nCtrlConfig))
        nChannel = 1
        Select \nCtrlConfig
          Case #SCS_CTRLCONF_BCF2000_PRESET_A To #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_A To #SCS_CTRLCONF_BCR2000_PRESET_C
            Select nCtrlType
              Case #SCS_CTRLTYPE_LIVE_INPUT ; control type live input
                Select nCtrlSubType
                  Case #SCS_CTRLSUBTYPE_FADER
                    If (\nController = #SCS_CTRL_BCF2000) And (grGeneralOptions\nFaderAssignments = #SCS_FADER_INPUTS_1_8)  ; BCF2000 inputs
                      Select nCtrlNo
                        Case 1 To 8
                          nCC = 80 + nCtrlNo
                      EndSelect
                    ElseIf (\nController = #SCS_CTRL_BCR2000) ; BCR2000 live inputs
                      Select nCtrlNo
                        Case 1 To 8
                          nCC = 96 + nCtrlNo
                        Case 9 To 16
                          nCC = 88 + nCtrlNo
                      EndSelect
                    EndIf
                EndSelect
                
              Case #SCS_CTRLTYPE_OUTPUT ; control type output
                Select nCtrlSubType
                  Case #SCS_CTRLSUBTYPE_FADER
                    If (\nController = #SCS_CTRL_BCF2000) And (grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M) ; BCF2000 outputs
                      Select nCtrlNo
                        Case 1 To 7
                          nCC = 80 + nCtrlNo
                      EndSelect
                    ElseIf (\nController = #SCS_CTRL_BCR2000) ; BCR2000 outputs
                      Select nCtrlNo
                        Case 1 To 7
                          nCC = 80 + nCtrlNo
                      EndSelect
                    EndIf
                EndSelect
                
              Case #SCS_CTRLTYPE_PLAYING ; control type playing
                Select nCtrlSubType
                  Case #SCS_CTRLSUBTYPE_FADER
                    If (\nController = #SCS_CTRL_BCF2000) And (grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M) ; BCF2000 outputs
                      Select nCtrlNo
                        Case 1 To 7
                          nCC = 80 + nCtrlNo
                      EndSelect
                    ElseIf (\nController = #SCS_CTRL_BCR2000) ; BCR2000 outputs
                      Select nCtrlNo
                        Case 1 To 8
                          nCC = 96 + nCtrlNo
                      EndSelect
                    EndIf
                EndSelect
                
              Case #SCS_CTRLTYPE_MASTER ; control type master
                If (\nController = #SCS_CTRL_BCF2000) And (grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M) ; BCF2000 master
                  nCC = 88
                ElseIf (\nController = #SCS_CTRL_BCR2000) ; BCR2000 master
                  If \nCtrlConfig = #SCS_CTRLCONF_BCR2000_PRESET_C
                    nCC = 104
                  Else
                    nCC = 88
                  EndIf
                EndIf
                
              Case #SCS_CTRLTYPE_EQ_KNOB  ; control type EQ knob
                Select nCtrlNo
                  Case 1 To 7
                    nCC = nCtrlNo ; CC1-7
                EndSelect
                
              Case #SCS_CTRLTYPE_DMX_MASTER ; DMX master rotary control
                nCC = 8
                
              Case #SCS_CTRLTYPE_EQ_SELECT ; control type EQ select
                Select \nCtrlConfig
                  Case #SCS_CTRLCONF_BCF2000_PRESET_A, #SCS_CTRLCONF_BCR2000_PRESET_A
                    Select nCtrlNo
                      Case 1 To 8
                        nCC = 64 + nCtrlNo
                    EndSelect
                  Case #SCS_CTRLCONF_BCR2000_PRESET_B
                    Select nCtrlNo
                      Case 1 To 8
                        nCC = 72 + nCtrlNo
                      Case 9 To 16
                        nCC = 64 + nCtrlNo
                    EndSelect
                EndSelect
                
              Case #SCS_CTRLTYPE_MUTE ; control type mute button
                Select nCtrlNo
                  Case 1 To 8
                    nCC = 72 + nCtrlNo
                EndSelect
                
            EndSelect
            
        EndSelect
        
      Case #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
        ; no action as the controller doesn't have motorised faders
        
    EndSelect
    
    ; debugMsg(sProcName, "nCC=" + nCC + ", nValue=" + nValue)
    If (nCC >= 0) And (nValue >= 0) And (nValue <= 127)
      ; debugMsg(sProcName, "calling SendCtrlChange(" + \nCtrlMidiOutPhysicalDevPtr + ", nCC=" + nCC + ", nValue=" + nValue + ", nChannel=" + nChannel + ")")
      SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, nValue, nChannel, #False)
      ProcedureReturn #True   ; indicates a MIDI message was sent
    Else
      ProcedureReturn #False  ; indicates a MIDI message was NOT sent
    EndIf
    
  EndWith
  
EndProcedure

Procedure resetController()
  PROCNAMEC()
  Protected nCC, nChannel
  Protected nMaxCC
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grCtrlSetup
    If \nCtrlMidiOutPhysicalDevPtr = -1
      \nCtrlMidiOutPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sCtrlMidiOutPort, #False)
    EndIf
    ; debugMsg(sProcName, "grCtrlSetup\nController=" + decodeController(\nController) + ", \nCtrlMidiOutPhysicalDevPtr=" + \nCtrlMidiOutPhysicalDevPtr)
    If \nCtrlMidiOutPhysicalDevPtr >= 0
      Select \nController
        Case #SCS_CTRL_BCF2000, #SCS_CTRL_BCR2000 ; BCF2000, BCR2000 (assumes BCF/BCR set to 'Preset 1')
          nChannel = 1
          Select \nController
            Case #SCS_CTRL_BCF2000
              nMaxCC = 94
            Case #SCS_CTRL_BCR2000
              nMaxCC = 110
          EndSelect
          For nCC = 1 To nMaxCC
            If nCC <= 7
              SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 64, nChannel, #False) ; top row of encoders used for EQ (except last encoder) so set to mid-point (64)
            Else
              SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)  ; all other controls (including last encoder on top row) set to 0
            EndIf
          Next nCC
      EndSelect
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure resetControllerSelectButtons(nExcludeCtrlNo)
  PROCNAMEC()
  Protected nCC, nChannel
  Protected nCtrlNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grCtrlSetup
    If \nCtrlMidiOutPhysicalDevPtr = -1
      \nCtrlMidiOutPhysicalDevPtr = getMidiOutPhysicalDevPtr(\sCtrlMidiOutPort, #False)
    EndIf
    ; debugMsg(sProcName, "grCtrlSetup\nController=" + decodeController(\nController) + ", \nCtrlMidiOutPhysicalDevPtr=" + \nCtrlMidiOutPhysicalDevPtr)
    If \nCtrlMidiOutPhysicalDevPtr >= 0
      Select \nController
        Case #SCS_CTRL_BCF2000 ; BCF2000 (assumes BCF2000 set to 'Preset 1')
          nChannel = 1
          Select \nCtrlConfig
            Case #SCS_CTRLCONF_BCF2000_PRESET_A ; BCF2000 Preset A
              For nCC = 65 To 72 ; select live inputs 1-8
                nCtrlNo = nCC - 64
                If nCtrlNo <> nExcludeCtrlNo
                  SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)
                EndIf
              Next nCC
          EndSelect
          
        Case #SCS_CTRL_BCR2000 ; BCR2000 (assumes BCR2000 set to 'Preset 1')
          nChannel = 1
          Select \nCtrlConfig
            Case #SCS_CTRLCONF_BCR2000_PRESET_A ; BCR2000 Preset A
              For nCC = 65 To 72 ; select live inputs 1-8
                nCtrlNo = nCC - 64
                If nCtrlNo <> nExcludeCtrlNo
                  SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)
                EndIf
              Next nCC
            Case #SCS_CTRLCONF_BCR2000_PRESET_B ; BCR2000 Preset B
              For nCC = 73 To 80 ; select live inputs 1-8
                nCtrlNo = nCC - 72
                If nCtrlNo <> nExcludeCtrlNo
                  SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)
                EndIf
              Next nCC
              For nCC = 65 To 72 ; select live inputs 9-16
                nCtrlNo = (nCC - 64) + 8
                If nCtrlNo <> nExcludeCtrlNo
                  SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)
                EndIf
              Next nCC
            Case #SCS_CTRLCONF_BCR2000_PRESET_C ; BCR2000 Preset C
              For nCC = 65 To 80 ; select all
                nCtrlNo = nCC - 64
                If nCtrlNo <> nExcludeCtrlNo
                  SendCtrlChange(\nCtrlMidiOutPhysicalDevPtr, nCC, 0, nChannel, #False)
                EndIf
              Next nCC
          EndSelect
      EndSelect
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure processMidiControllerMsg()
  PROCNAMEC()
  Protected nCC, nMidiValue, nSliderValue, bTurnButtonOff
  Protected nCtrlType, nCtrlNo, nEQGroup, nLogEntry
  Protected nCurrSliderValue, bSliderValueMatched, nControllerIndex ; Added 23Jun2022 11.9.4
  Static nSliderMidiIncrementForAudioMatch, nSliderMidiIncrementForDMXMatch
  
  ; debugMsg(sProcName, #SCS_START)
 
  ; Important note about the use of gbMidiTestWindow: We must allow much of this procedure to execute even if the MIDI Test Window is active because
  ; some actions need to send a message back to the controller to turn OFF a button that has just been turned ON - eg for the GO button on BCR2000/BCF2000 controllers
  
  If nSliderMidiIncrementForAudioMatch = 0
    nSliderMidiIncrementForAudioMatch = Round(#SCS_MAXVOLUME_SLD / 127, #PB_Round_Up) * 3
    ; seem to need to multiply by approx 3 for the audio sliders (with large maximum values) or the slider movements may not detect a match
    nSliderMidiIncrementForDMXMatch = Round(255 / 127, #PB_Round_Nearest)
    ; multiplier not needed for the DMX sliders, probably due to the much lower maximum slider value
    ; debugMsg(sProcName, "nSliderMidiIncrementForAudioMatch=" + nSliderMidiIncrementForAudioMatch + ", nSliderMidiIncrementForDMXMatch=" + nSliderMidiIncrementForDMXMatch)
  EndIf
  
  ; debugMsg(sProcName, "grCtrlSetup\nController=" + grCtrlSetup\nController)
  With grMidiIn
    Select grCtrlSetup\nController
      Case #SCS_CTRL_BCF2000, #SCS_CTRL_BCR2000
        ;{
        Select grCtrlSetup\nCtrlConfig
          Case #SCS_CTRLCONF_BCF2000_PRESET_A To #SCS_CTRLCONF_BCF2000_PRESET_C, #SCS_CTRLCONF_BCR2000_PRESET_A To #SCS_CTRLCONF_BCR2000_PRESET_C
            debugMsg(sProcName, "\msgType=$" + Hex(\msgType) + ", \midiChannel=" + \midiChannel + ", \kk=" + \kk + ", \vv=" + \vv)
            ; debugMsg(sProcName, "grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_GO)=" + grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_GO))
            If (\msgType = $B) And (\midiChannel = 1)
              nCC = \kk
              nMidiValue = \vv
              Select nCC
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_PREV) ; PREV CUE
                  If gbMidiTestWindow = #False
                    PostEvent(#SCS_Event_GoTo_Prev_Cue, #WMN, 0)
                  EndIf
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_PREV
                  
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_NEXT) ; NEXT CUE
                  If gbMidiTestWindow = #False
                    PostEvent(#SCS_Event_GoTo_Next_Cue, #WMN, 0)
                  EndIf
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_NEXT
                  
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_STOP) ; STOP ALL button
                  If gbMidiTestWindow = #False
                    PostEvent(#SCS_Event_StopEverything, #WMN, 0)
                  EndIf
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_STOP
                  
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_GO) ; GO button
                  If gbMidiTestWindow = #False
                    ; debugMsg(sProcName, "calling PostEvent(#SCS_Event_GoButton, #WMN, 0, 0, " + grCtrlSetup\nCtrlMidiInPhysicalDevPtr + ")")
                    PostEvent(#SCS_Event_GoButton, #WMN, 0, 0, grCtrlSetup\nCtrlMidiInPhysicalDevPtr)
                  EndIf
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_GO
                  
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_INPUTS) ; INPUTS button
                  If gbMidiTestWindow = #False
                    grGeneralOptions\nFaderAssignments = #SCS_FADER_INPUTS_1_8
                    PostEvent(#SCS_Event_SetFaderAssignments, #WMN, 0)
                  EndIf
                  nLogEntry = #SCS_CTRLLOG_FADER
                  
                Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_OUTPUTS) ; OUTPUTS button
                  If gbMidiTestWindow = #False
                    grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M
                    PostEvent(#SCS_Event_SetFaderAssignments, #WMN, 0)
                  EndIf
                  nLogEntry = #SCS_CTRLLOG_FADER
                  
                Case 1 To 7 ; EQ rotary
                  nCtrlType = #SCS_CTRLTYPE_EQ_KNOB
                  nCtrlNo = nCC
                  nLogEntry = #SCS_CTRLLOG_EQ
                  
                Case 8  ; DMX Master (8th rotary control in top row)
                  nCtrlType = #SCS_CTRLTYPE_DMX_MASTER
                  nLogEntry = #SCS_CTRLLOG_DMX
                  
                Case 33 To 40 ; EQ push
                  nCtrlType = #SCS_CTRLTYPE_EQ_BTN
                  Select nCC
                    Case 33
                      nEQGroup = #SCS_EQGRP_LOW_CUT
                    Case 34 To 36
                      nEQGroup = #SCS_EQGRP_BAND_1
                    Case 37 To 39
                      nEQGroup = #SCS_EQGRP_BAND_2
                  EndSelect
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_EQ
                  
                Case 65 To 72 ; select live inputs 1-8
                  nCtrlType = #SCS_CTRLTYPE_EQ_SELECT
                  nCtrlNo = (nCC - 64)
                  bTurnButtonOff = #True
                  nLogEntry = #SCS_CTRLLOG_EQ
                  
                Case 73 To 80
                  Select grCtrlSetup\nCtrlConfig
                    Case #SCS_CTRLCONF_BCR2000_PRESET_B ; select live inputs 9-16
                      nCtrlType = #SCS_CTRLTYPE_EQ_SELECT
                      nCtrlNo = (nCC - 72) + 8
                      bTurnButtonOff = #True
                      nLogEntry = #SCS_CTRLLOG_EQ
                    Case #SCS_CTRLCONF_BCF2000_PRESET_A, #SCS_CTRLCONF_BCR2000_PRESET_A ; mute live inputs 1-8
                      nCtrlType = #SCS_CTRLTYPE_MUTE
                      nCtrlNo = nCC - 72
                      bTurnButtonOff = #True
                      nLogEntry = #SCS_CTRLLOG_MUTE
                  EndSelect
                  
                Case 81 To 88
                  Select grCtrlSetup\nCtrlConfig
                    Case #SCS_CTRLCONF_BCF2000_PRESET_A ; BCF2000
                      Select grGeneralOptions\nFaderAssignments
                        Case #SCS_FADER_OUTPUTS_1_7_M ; BCF2000 FADER_OUTPUTS_1_7_M
                          If nCC < 88
                            ; outputs 1-7
                            nCtrlType = #SCS_CTRLTYPE_OUTPUT
                            nCtrlNo = nCC - 80
                            nLogEntry = #SCS_CTRLLOG_OUTPUT
                          Else ; 88
                            ; master
                            nCtrlType = #SCS_CTRLTYPE_MASTER
                            nCtrlNo = 1
                            nLogEntry = #SCS_CTRLLOG_MASTER
                          EndIf
                          
                        Case #SCS_FADER_INPUTS_1_8 ; BCF2000 FADER_INPUTS_1_8
                          ; live inputs 1-8
                          nCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
                          nCtrlNo = nCC - 80
                          nLogEntry = #SCS_CTRLLOG_FADER
                          
                      EndSelect
                          
                    Case #SCS_CTRLCONF_BCF2000_PRESET_C ; BCF2000
                      If nCC < 88
                        ; playing 1-7
                        nCtrlType = #SCS_CTRLTYPE_PLAYING
                        nCtrlNo = nCC - 80
                        nLogEntry = #SCS_CTRLLOG_FADER
                      Else ; 88
                           ; master
                        nCtrlType = #SCS_CTRLTYPE_MASTER
                        nCtrlNo = 1
                        nLogEntry = #SCS_CTRLLOG_MASTER
                      EndIf
                      
                    Case #SCS_CTRLCONF_BCR2000_PRESET_A To #SCS_CTRLCONF_BCR2000_PRESET_B ; BCR2000
                      If nCC < 88
                        ; outputs 1-7
                        nCtrlType = #SCS_CTRLTYPE_OUTPUT
                        nCtrlNo = nCC - 80
                        nLogEntry = #SCS_CTRLLOG_OUTPUT
                      Else ; 88
                        ; master
                        nCtrlType = #SCS_CTRLTYPE_MASTER
                        nCtrlNo = 1
                        nLogEntry = #SCS_CTRLLOG_MASTER
                      EndIf
                  EndSelect
                  
                Case 89 To 96
                  Select grCtrlSetup\nCtrlConfig
                    Case #SCS_CTRLCONF_BCF2000_PRESET_A ; BCF2000
                      ; first two buttons on BCF2000 allow switching fader assignments between inputs and outputs
                      Select nCC
                        Case grCtrlSetup\nCtrlBtnCC(#SCS_CTRLBTN_INPUTS)
                          If gbMidiTestWindow = #False
                            grGeneralOptions\nFaderAssignments = #SCS_FADER_INPUTS_1_8
                            PostEvent(#SCS_Event_SetFaderAssignments, #WMN, 0)
                          EndIf
                          nLogEntry = #SCS_CTRLLOG_FADER
                        Case 90
                          If gbMidiTestWindow = #False
                            grGeneralOptions\nFaderAssignments = #SCS_FADER_OUTPUTS_1_7_M
                            PostEvent(#SCS_Event_SetFaderAssignments, #WMN, 0)
                          EndIf
                          nLogEntry = #SCS_CTRLLOG_FADER
                        Case 91  ; STOP ALL button
                          If grCtrlSetup\bIncludeGoEtc
                            If gbMidiTestWindow = #False
                              PostEvent(#SCS_Event_StopEverything, #WMN, 0)
                            EndIf
                            bTurnButtonOff = #True
                            nLogEntry = #SCS_CTRLLOG_STOP
                          EndIf
                        Case 92  ; GO button
                          If grCtrlSetup\bIncludeGoEtc
                            If gbMidiTestWindow = #False
                              PostEvent(#SCS_Event_GoButton, #WMN, 0, 0, grCtrlSetup\nCtrlMidiInPhysicalDevPtr)
                            EndIf
                            bTurnButtonOff = #True
                            nLogEntry = #SCS_CTRLLOG_GO
                          EndIf
                      EndSelect
                      
                    Case #SCS_CTRLCONF_BCR2000_PRESET_A, #SCS_CTRLCONF_BCR2000_PRESET_B ; BCR2000
                      ; live inputs 9-16
                      nCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
                      nCtrlNo = (nCC - 88) + 8
                      nLogEntry = #SCS_CTRLLOG_LIVE_INPUT
                  EndSelect
                  
                Case 97 To 104
                  ; nb BCR2000 only as BCF2000 max CC = 94
                  Select grCtrlSetup\nCtrlConfig
                    Case #SCS_CTRLCONF_BCR2000_PRESET_A, #SCS_CTRLCONF_BCR2000_PRESET_B
                      ; live inputs 1-8
                      nCtrlType = #SCS_CTRLTYPE_LIVE_INPUT
                      nCtrlNo = nCC - 96
                      nLogEntry = #SCS_CTRLLOG_LIVE_INPUT
                    Case #SCS_CTRLCONF_BCR2000_PRESET_C
                      If nCC < 104
                        ; playing outputs 1-7
                        nCtrlType = #SCS_CTRLTYPE_PLAYING
                        nCtrlNo = nCC - 96
                        nLogEntry = #SCS_CTRLLOG_PLAYING
                      Else 
                        ; master
                        nCtrlType = #SCS_CTRLTYPE_MASTER
                        nCtrlNo = 1
                        nLogEntry = #SCS_CTRLLOG_MASTER
                      EndIf
                  EndSelect
                  
              EndSelect
            EndIf
        EndSelect
        ;}
      Case #SCS_CTRL_NK2 ; 14Jun2022 11.9.4
        ;{
        Select grCtrlSetup\nCtrlConfig
          Case #SCS_CTRLCONF_NK2_PRESET_A, #SCS_CTRLCONF_NK2_PRESET_B, #SCS_CTRLCONF_NK2_PRESET_C
            If (\msgType = $B) And (\midiChannel = 1)
              nLogEntry = -1
              nCC = \kk
              nMidiValue = \vv
              If grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_A
                Select nCC
                  Case 0 To 6 ; outputs 1-7
                    nCtrlType = #SCS_CTRLTYPE_OUTPUT
                    nCtrlNo = nCC + 1
                    nLogEntry = #SCS_CTRLLOG_OUTPUT
                  Case 7 ; master
                    nCtrlType = #SCS_CTRLTYPE_MASTER
                    nCtrlNo = 1
                    nLogEntry = #SCS_CTRLLOG_MASTER
                EndSelect
              ElseIf grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_B
                Select nCC
                  Case 0 To 5 ; outputs 1-6
                    nCtrlType = #SCS_CTRLTYPE_OUTPUT
                    nCtrlNo = nCC + 1
                    nLogEntry = #SCS_CTRLLOG_OUTPUT
                  Case 6 ; master
                    nCtrlType = #SCS_CTRLTYPE_MASTER
                    nCtrlNo = 1
                    nLogEntry = #SCS_CTRLLOG_MASTER
                  Case 7 ; DMX master
                    nCtrlType = #SCS_CTRLTYPE_DMX_MASTER
                    nLogEntry = #SCS_CTRLLOG_DMX
                  Case $10 To $17 ; DMX dimmer channel faders 1-8
                    nCtrlType = #SCS_CTRLTYPE_DIMMER_CHANNEL
                    nCtrlNo = (nCC - $10) + 1
                    nLogEntry = #SCS_CTRLLOG_DIMMER
                EndSelect
              ElseIf grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_NK2_PRESET_C ; Added 28Aug2023 11.10.0by
                ; debugMsg0(sProcName, "grCtrlSetup\nCtrlConfig=" + decodeCtrlConfig(grCtrlSetup\nCtrlConfig) + ", nCC=" + nCC)
                Select nCC
                  Case 0 To 6 ; playing cue's outputs 1-7
                    nCtrlType = #SCS_CTRLTYPE_PLAYING
                    nCtrlNo = nCC + 1
                    nLogEntry = #SCS_CTRLLOG_PLAYING
                  Case 7 ; master
                    nCtrlType = #SCS_CTRLTYPE_MASTER
                    nCtrlNo = 1
                    nLogEntry = #SCS_CTRLLOG_MASTER
                EndSelect
              EndIf
              If nLogEntry = -1 And grCtrlSetup\nCtrlConfig <> #SCS_CTRLCONF_NK2_PRESET_C ; no 'mute' or 'solo' for 'playing' outputs
                Select nCC
                  Case $30 To $35
                    If nMidiValue > 0
                      nCtrlType = #SCS_CTRLTYPE_MUTE
                      nCtrlNo = (nCC - $30) + 1
                      nLogEntry = #SCS_CTRLLOG_MUTE
                      ; debugMsg0(sProcName, "nCC=$" + hex2(nCC) + ", nCtrlNo=" + nCtrlNo)
                    EndIf
                  Case $20 To $25
                    If nMidiValue > 0
                      nCtrlType = #SCS_CTRLTYPE_SOLO
                      nCtrlNo = (nCC - $20) + 1
                      nLogEntry = #SCS_CTRLLOG_SOLO
                      ; debugMsg0(sProcName, "nCC=$" + hex2(nCC) + ", nCtrlNo=" + nCtrlNo)
                    EndIf
                EndSelect
              EndIf
              If nLogEntry = -1 And grCtrlSetup\bIncludeGoEtc
                If nMidiValue = 127 ; check button push only - not button release
                  Select nCC
                    Case $3A ; PREV CUE
                      ; In this and the following three commands, use PostEvent() so the commands are processed in the main thread, not in the callback
                      If gbMidiTestWindow = #False
                        PostEvent(#SCS_Event_GoTo_Prev_Cue, #WMN, 0)
                      EndIf
                      nLogEntry = #SCS_CTRLLOG_PREV
                    Case $3B ; NEXT CUE
                      If gbMidiTestWindow = #False
                        PostEvent(#SCS_Event_GoTo_Next_Cue, #WMN, 0)
                      EndIf
                      nLogEntry = #SCS_CTRLLOG_NEXT
                    Case $2A ; STOP ALL button
                      If gbMidiTestWindow = #False
                        PostEvent(#SCS_Event_StopEverything, #WMN, 0)
                      EndIf
                      nLogEntry = #SCS_CTRLLOG_STOP
                    Case $29 ; GO button
                      If gbMidiTestWindow = #False
                        PostEvent(#SCS_Event_GoButton, #WMN, 0)
                      EndIf
                      bTurnButtonOff = #True
                      nLogEntry = #SCS_CTRLLOG_GO
                  EndSelect
                EndIf ; EndIf nMidiValue = 127
              EndIf
            EndIf
        EndSelect
        ;}
    EndSelect
  EndWith
  
  ; debugMsg(sProcName, "nCtrlType=" + decodeCtrlType(nCtrlType) + ", nCtrlNo=" + nCtrlNo + ", nEQGroup=" + nEQGroup)
  If gbMidiTestWindow = #False
    If (nCtrlType > 0) And ((nCtrlNo > 0) Or (nEQGroup > 0) Or (nCtrlType = #SCS_CTRLTYPE_DMX_MASTER))
      Select nCtrlType
        Case #SCS_CTRLTYPE_EQ_SELECT
          ; debugMsg(sProcName, "(EQ) calling WCN_selectController(" + nCtrlNo + ", " + nMidiValue + ")")
          WCN_selectController(nCtrlNo, nMidiValue)
        Case #SCS_CTRLTYPE_EQ_KNOB
          WCN_setKnob(nCtrlNo, nMidiValue, #False)
        Case #SCS_CTRLTYPE_EQ_BTN
          WCN_selectEQGroup(nEQGroup, -1)
        Case #SCS_CTRLTYPE_MUTE
          WCN_processMuteButton(nCtrlNo)
        Case #SCS_CTRLTYPE_SOLO ; Added 24Jun2022 11.9.4
          WCN_processSoloButton(nCtrlNo)
        Default
          ; Changed 23Jun2022 11.9.4
          nSliderValue = midiValueToSliderValue(nCtrlType, nMidiValue)
          ; debugMsg(sProcName, "midiValueToSliderValue(" + decodeCtrlType(nCtrlType) + ", " + nMidiValue + ") returned nSliderValue=" + nSliderValue + ", nCtrlNo=" + nCtrlNo)
          Select grCtrlSetup\nController
            Case #SCS_CTRL_BCF2000, #SCS_CTRL_BCR2000
              ; debugMsg(sProcName, "calling WCN_setFader(" + decodeCtrlType(nCtrlType) + ", " + nCtrlNo + ", " + nSliderValue + ", #False)")
              WCN_setFader(nCtrlType, nCtrlNo, nSliderValue, #False)
            Case #SCS_CTRL_NK2
              nControllerIndex = WCN_getControllerIndex(nCtrlType, nCtrlNo)
              ; debugMsg0(sProcName, "WCN_getControllerIndex(" + decodeCtrlType(nCtrlType) + ", " + nCtrlNo + ") returned " + nControllerIndex)
              If nControllerIndex >= 0 ; Would be -1 if user moves 'DMX Master Fader' on the NK2 but there's no DMX Master Fader in #WCN
                nCurrSliderValue = SLD_getValue(WCN\aController(nControllerIndex)\sldLevelOrValue, #True)
                ; debugMsg0(sProcName, "nCurrSliderValue=" + nCurrSliderValue + ", nSliderValue=" + nSliderValue + ", Abs(nCurrSliderValue - nSliderValue)=" + Abs(nCurrSliderValue - nSliderValue))
                bSliderValueMatched = WCN\aController(nControllerIndex)\bSliderValueMatched
                If bSliderValueMatched = #False
                  Select nCtrlType
                    Case #SCS_CTRLTYPE_DIMMER_CHANNEL, #SCS_CTRLTYPE_DMX_MASTER
                      If Abs(nCurrSliderValue - nSliderValue) <= nSliderMidiIncrementForDMXMatch
                        bSliderValueMatched = #True
                      EndIf
                    Default
                      If Abs(nCurrSliderValue - nSliderValue) <= nSliderMidiIncrementForAudioMatch
                        bSliderValueMatched = #True
                      EndIf
                  EndSelect
                  WCN\aController(nControllerIndex)\bSliderValueMatched = bSliderValueMatched
                  ; debugMsg0(sProcName, ">>>>> WCN\aController(" + nControllerIndex + ")\bSliderValueMatched=" + strB(WCN\aController(nControllerIndex)\bSliderValueMatched))
                EndIf
                If bSliderValueMatched
                  ; debugMsg(sProcName, "calling WCN_setFader(" + decodeCtrlType(nCtrlType) + ", " + nCtrlNo + ", " + nSliderValue + ", #False)")
                  WCN_setFader(nCtrlType, nCtrlNo, nSliderValue, #False)
                EndIf
              EndIf
          EndSelect
      EndSelect
    EndIf
  EndIf
  
  ; debugMsg0(sProcName, "nCC=" + nCC + ", bTurnButtonOff=" + strB(bTurnButtonOff))
  If bTurnButtonOff
    SendCtrlChange(grCtrlSetup\nCtrlMidiOutPhysicalDevPtr, nCC, 0, 1, #False) ; turn button off
  EndIf
  
  ProcedureReturn nLogEntry ; will be zero if not a required controller message
  ; debugMsg(sProcName, #SCS_END)

EndProcedure

Procedure.s decodeControllerLogEntry(nLogEntry)
  PROCNAMEC()
  Protected sLogEntry.s
  Static sController.s, sDMX.s, sEQ.s, sFADER.s, sGO.s, sLIVE_INPUT.s, sMASTER.s, sMUTE.s, sNEXT.s, sOUTPUT.s, sPREV.s, sSTOP.s, sSOLO.s, sDimmerChannel.s, sPlaying.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sController = "Controller: "
    sDimmerChannel = Lang("Common", "DimmerChannel") ; Added 18Jul2022 11.9.4
    sDMX = Lang("Common", "DMXMaster")
    sEQ = "EQ"
    sFADER = "External Fader"
    sGO = Lang("Common", "Go")
    sLIVE_INPUT = "Live Input"
    sMASTER = Lang("Common", "Master")
    sMUTE = Lang("Common", "Mute")
    sNEXT = "Next"
    sOUTPUT = "Output"
    sPREV = "Previous"
    sSTOP = "Stop"
    sSOLO = Lang("Common", "Solo") ; Added 24Jun2022 11.9.4
    sPlaying = "Playing"
    bStaticLoaded = #True
  EndIf
  
  sLogEntry = sController
  Select nLogEntry
    Case #SCS_CTRLLOG_DIMMER ; Added 18Jul2022 11.9.4
      sLogEntry + sDimmerChannel
    Case #SCS_CTRLLOG_DMX
      sLogEntry + sDMX
    Case #SCS_CTRLLOG_EQ
      sLogEntry + sEQ
    Case #SCS_CTRLLOG_FADER
      sLogEntry + sFADER
    Case #SCS_CTRLLOG_GO
      sLogEntry + sGO
    Case #SCS_CTRLLOG_LIVE_INPUT
      sLogEntry + sLIVE_INPUT
    Case #SCS_CTRLLOG_MASTER
      sLogEntry + sMASTER
    Case #SCS_CTRLLOG_MUTE
      sLogEntry + sMUTE
    Case #SCS_CTRLLOG_NEXT
      sLogEntry + sNEXT
    Case #SCS_CTRLLOG_OUTPUT
      sLogEntry + sOUTPUT
    Case #SCS_CTRLLOG_PREV
      sLogEntry + sPREV
    Case #SCS_CTRLLOG_STOP
      sLogEntry + sSTOP
    Case #SCS_CTRLLOG_SOLO ; Added 24Jun2022 11.9.4
      sLogEntry + sSOLO
    Case #SCS_CTRLLOG_PLAYING ; Added 28Aug2023 11.10.0by
      sLogEntry + sPlaying
    Default
      sLogEntry + nLogEntry
  EndSelect
  ProcedureReturn sLogEntry
EndProcedure

Procedure setFaderAssignments()
  PROCNAMEC()
  Protected n
  Protected nCC, nCCFrom, nValue, nChannel
  Protected nIndex
  
  ; debugMsg(sProcName, #SCS_START + ", grGeneralOptions\nFaderAssignments=" + decodeFaderAssignments(grGeneralOptions\nFaderAssignments))
  
  ; debugMsg(sProcName, "grCtrlSetup\bUseExternalController=" + strB(grCtrlSetup\bUseExternalController) + ", grCtrlSetup\nCtrlMidiOutPhysicalDevPtr=" + grCtrlSetup\nCtrlMidiOutPhysicalDevPtr)
  If (grCtrlSetup\bUseExternalController) And (grCtrlSetup\nCtrlMidiOutPhysicalDevPtr >= 0)
    If grCtrlSetup\nController = #SCS_CTRL_BCR2000 Or #c_Test_BCF2000_using_BCR2000
      nCCFrom = 105
    Else
      nCCFrom = 89
    EndIf
    nChannel = 1
    
    nIndex = -1
    If grCtrlSetup\nCtrlConfig = #SCS_CTRLCONF_BCF2000_PRESET_A
      Select grGeneralOptions\nFaderAssignments
        Case #SCS_FADER_INPUTS_1_8
          nIndex = 0 ; loop below turns 'input' button on and 'output' button off
        Case #SCS_FADER_OUTPUTS_1_7_M
          nIndex = 1 ; loop below turns 'input' button off and 'output' button on
      EndSelect
    EndIf
    ; debugMsg(sProcName, "nIndex=" + nIndex)
    
    For n = 0 To 1
      ; see comments above regarding this loop
      nCC = nCCFrom + n
      If nIndex = -1
        nValue = 0    ; turns off button LED
      ElseIf n = nIndex
        nValue = 127  ; turns on button LED
      Else
        nValue = 0    ; turns off button LED
      EndIf
      ; debugMsg(sProcName, "calling SendCtrlChange(" + grCtrlSetup\nCtrlMidiOutPhysicalDevPtr + ", " + nCC + ", " + nValue + ", "+ nChannel + ", #True)")
      SendCtrlChange(grCtrlSetup\nCtrlMidiOutPhysicalDevPtr, nCC, nValue, nChannel, #True) ; #False)
    Next n
    
    ; turn off 'stop all' and 'go' buttons
    nValue = 0
    For n = 0 To 1
      nCC = nCCFrom + n + 2
      SendCtrlChange(grCtrlSetup\nCtrlMidiOutPhysicalDevPtr, nCC, nValue, nChannel, #True) ; #False)
    Next n
    
  EndIf
  
  ; debugMsg(sProcName, "calling WCN_setExternalControllerFaders()")
  WCN_setExternalControllerFaders()
  
  ; debugMsg(sProcName, "calling WCN_drawFaderAssignmentsIfReqd()")
  WCN_drawFaderAssignmentsIfReqd()
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure changeActionIfReqd(nAction, sMidiCue.s)
  PROCNAMEC()
  Protected nReqdAction
  Protected i
  
  nReqdAction = nAction
  
  If nAction = #SCS_MIDI_PLAY_CUE
    i = getCuePtrForMidiCue(sMidiCue)
    If i >= 0
      ; debugMsg(sProcName, "cue found i=" + getCueLabel(i))
      With aCue(i)
        If \bCueCurrentlyEnabled
          Select \nActivationMethod
            Case #SCS_ACMETH_EXT_TOGGLE
              If \nExtActToggleState = 1
                nReqdAction = #SCS_MIDI_STOP_CUE
              EndIf
          EndSelect
        EndIf
      EndWith
    EndIf
  EndIf
  
  ProcedureReturn nReqdAction
EndProcedure

Procedure loadArrayCueOrSubForMTC()
  PROCNAMEC()
  Protected i, j
  Protected nIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nIndex = -1
  With grMTCControl
    If grLicInfo\nLicLevel >= #SCS_LIC_PLUS
      For i = 1 To gnLastCue
        If aCue(i)\nActivationMethod = #SCS_ACMETH_MTC
          If aCue(i)\bCueCurrentlyEnabled
            nIndex + 1
            If nIndex > ArraySize(\aCueOrSubForMTC())
              ReDim \aCueOrSubForMTC(nIndex + 20)
            EndIf
            \aCueOrSubForMTC(nIndex)\nMTCCuePtr = i
            \aCueOrSubForMTC(nIndex)\nMTCSubPtr = -1
            \aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub = aCue(i)\nMTCStartTimeForCue
            \aCueOrSubForMTC(nIndex)\nMTCMaxStartTimeForCueOrSub = adjustMTCBySeconds(\aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub, 1)
            \aCueOrSubForMTC(nIndex)\qTimeCueOrSubLastStarted = -2000
            debugMsg(sProcName, "grMTCControl\aCueOrSubForMTC(" + nIndex + ")\nCuePtr=" + getCueLabel(\aCueOrSubForMTC(nIndex)\nMTCCuePtr) +
                                ", \nMTCSubPtr=-1" +
                                ", \nMTCStartTimeForCueOrSub=" + decodeMTCTime(\aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub) +
                                ", \nMTCMaxStartTimeForCueOrSub=" + decodeMTCTime(\aCueOrSubForMTC(nIndex)\nMTCMaxStartTimeForCueOrSub))
            j = aCue(i)\nFirstSubIndex
            While j >= 0
              If aSub(j)\nSubStart = #SCS_SUBSTART_REL_MTC And aSub(j)\bSubEnabled
                nIndex + 1
                If nIndex > ArraySize(\aCueOrSubForMTC())
                  ReDim \aCueOrSubForMTC(nIndex + 20)
                EndIf
                \aCueOrSubForMTC(nIndex)\nMTCCuePtr = i
                \aCueOrSubForMTC(nIndex)\nMTCSubPtr = j
                \aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub = aSub(j)\nCalcMTCStartTimeForSub
                \aCueOrSubForMTC(nIndex)\nMTCMaxStartTimeForCueOrSub = adjustMTCBySeconds(\aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub, 1)
                \aCueOrSubForMTC(nIndex)\qTimeCueOrSubLastStarted = -2000
                debugMsg(sProcName, "grMTCControl\aCueOrSubForMTC(" + nIndex + ")\nCuePtr=" + getCueLabel(\aCueOrSubForMTC(nIndex)\nMTCCuePtr) +
                                    ", \nMTCSubPtr=" + getSubLabel(\aCueOrSubForMTC(nIndex)\nMTCSubPtr) +
                                    ", \nMTCStartTimeForCueOrSub=" + decodeMTCTime(\aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub) +
                                    ", \nMTCMaxStartTimeForCueOrSub=" + decodeMTCTime(\aCueOrSubForMTC(nIndex)\nMTCMaxStartTimeForCueOrSub))
              EndIf
              j = aSub(j)\nNextSubIndex
            Wend
          EndIf
        EndIf
      Next i
    EndIf
    \nMaxCueOrSubForMTC = nIndex
    debugMsg(sProcName, "\nMaxCueOrSubForMTC=" + \nMaxCueOrSubForMTC)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure clearArrayCueOrSubForMTC()
  PROCNAMEC()
  
  With grMTCControl
    \nMaxCueOrSubForMTC = -1
  EndWith
  
EndProcedure

Procedure checkArrayCueOrSubForMTC()
  PROCNAMEC()
  Protected nIndex
  Protected nCurrTimeCode
  Protected nMTCStartTimeForCueOrSub.l, nMTCMaxStartTimeForCueOrSub.l
  Protected nCuePtr, nSubPtr
  Protected bCallLoadDispPanels
  Protected sMidiInName.s
  Protected qTimeNow.q
  Static bCheckingTimeCodeStopped
  Static qTimeStopped.q
  Protected bResult

  ; note: MIDI time code variables only contain the hh:mm:ss:ff components, not the rr as that would mess up some comparisons
  
  With grMTCControl
; debugMsg(sProcName, "grMTCControl\bMTCControlActive=" + strB(\bMTCControlActive) + ", grMTCSendControl\bMTCSendControlActive=" + strB(grMTCSendControl\bMTCSendControlActive))
    If \bMTCControlActive Or grMTCSendControl\bMTCSendControlActive
      qTimeNow = ElapsedMilliseconds()
      ; debugMsg(sProcName, "grMTCControl\nTimeCode=$" + Hex(\nTimeCode,#PB_Long))
      nCurrTimeCode = \nTimeCode  ; extract \nTimeCode once only in this procedure in case another thread changes the value during the processing of this procedure
      CompilerIf #cTraceMTCReceive
        debugMsg(sProcName, "\nPrevTimeCodeProcessed=$" + Hex(\nPrevTimeCodeProcessed,#PB_Long) + " (" + decodeMTCTime(\nPrevTimeCodeProcessed) + "), nCurrTimeCode=$" + Hex(nCurrTimeCode,#PB_Long) + " (" + decodeMTCTime(nCurrTimeCode) + ")")
      CompilerEndIf
      If (nCurrTimeCode <> \nPrevTimeCodeProcessed) Or (\bClearPrevTimeCodeProcessed)
        \bClearPrevTimeCodeProcessed = #False
        \bTimeCodeStopped = #False
        \bStoppedDuringTest = #False
        bCheckingTimeCodeStopped = #False
        CompilerIf #cTraceMTCReceive
          debugMsg(sProcName, "\nMaxCueOrSubForMTC=" + \nMaxCueOrSubForMTC + ", \nPrevTimeCodeProcessed=" + decodeMTCTime(\nPrevTimeCodeProcessed) + ", nCurrTimeCode=" + decodeMTCTime(nCurrTimeCode))
        CompilerEndIf
        For nIndex = 0 To \nMaxCueOrSubForMTC
          nMTCStartTimeForCueOrSub = \aCueOrSubForMTC(nIndex)\nMTCStartTimeForCueOrSub
          nMTCMaxStartTimeForCueOrSub = \aCueOrSubForMTC(nIndex)\nMTCMaxStartTimeForCueOrSub
          If (nCurrTimeCode >= nMTCStartTimeForCueOrSub) And (nCurrTimeCode < nMTCMaxStartTimeForCueOrSub)
            ; current timecode (nCurrTimeCode) is within the window for the MTC start time for this cue
            If \aCueOrSubForMTC(nIndex)\qTimeCueOrSubLastStarted < (qTimeNow - 1100)
              ; this cue has not already been started within this instance of the window
              debugMsg(sProcName, "nIndex=" + nIndex + ", nMTCStartTimeForCueOrSub=" + decodeMTCTime(nMTCStartTimeForCueOrSub) +
                                  ", nMTCMaxStartTimeForCueOrSub=" + decodeMTCTime(nMTCMaxStartTimeForCueOrSub) +
                                  ", \nPrevTimeCodeProcessed=" + decodeMTCTime(\nPrevTimeCodeProcessed) + 
                                  ", nCurrTimeCode=" + decodeMTCTime(nCurrTimeCode))
              nCuePtr = \aCueOrSubForMTC(nIndex)\nMTCCuePtr
              nSubPtr = \aCueOrSubForMTC(nIndex)\nMTCSubPtr
              If gbMidiTestWindow
                WMT_addListItem(\sMidiInName, decodeMTCTime(nCurrTimeCode) + " Play Cue " + getCueLabel(nCuePtr))
              Else
                If nSubPtr >= 0
                  debugMsg(sProcName, "nCurrTimeCode=" + decodeMTCTime(nCurrTimeCode) + ", calling playSub(" + getSubLabel(nSubPtr) + ")")
                  playSub(nSubPtr)
                  \sTxt = decodeMTCTime(nCurrTimeCode) + " Play Sub " + getSubLabel(nSubPtr)
                Else
                  debugMsg(sProcName, "nCurrTimeCode=" + decodeMTCTime(nCurrTimeCode) + ", calling playCue(" + getCueLabel(nCuePtr) + ")")
                  playCue(nCuePtr)
                  \sTxt = decodeMTCTime(nCurrTimeCode) + " Play Cue " + getCueLabel(nCuePtr)
                EndIf
                \aCueOrSubForMTC(nIndex)\qTimeCueOrSubLastStarted = qTimeNow
                bCallLoadDispPanels = #True
                bResult = #True
                debugMsg(sProcName, "grMTCControl\sTxt=" + \sTxt + ", bResult=" + strB(bResult))
              EndIf
            EndIf
          EndIf
        Next nIndex
        If bCallLoadDispPanels
          gbCallLoadDispPanels = #True
        EndIf
        \nPrevTimeCodeProcessed = nCurrTimeCode
        CompilerIf #cTraceMTCReceive
          debugMsg(sProcName, "\nTimeCode=" + decodeMTCTime(\nTimeCode) + " ($" + Hex(\nTimeCode,#PB_Long) + ")" + ", \nPrevTimeCodeProcessed=" + decodeMTCTime(\nPrevTimeCodeProcessed) + " ($" + Hex(\nPrevTimeCodeProcessed,#PB_Long) + ")")
        CompilerEndIf
        
      ElseIf nCurrTimeCode = \nPrevTimeCodeProcessed
        If \bMTCControlActive
          If bCheckingTimeCodeStopped = #False
            qTimeStopped = qTimeNow
            bCheckingTimeCodeStopped = #True
            If gbMidiTestWindow
              \bStoppedDuringTest = #True
            Else
              \bStoppedDuringTest = #False
            EndIf
          Else
            If ((qTimeNow - qTimeStopped) > 3000) Or (\bStoppedDuringTest)
              \bTimeCodeStopped = #True
              WTC_hideWindowIfInactive()
            EndIf
          EndIf
        EndIf
        
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn bResult
  
EndProcedure

Procedure checkMidiChannelAndMsgTypeReqd(nMidiChannel, nMsgType, kk, vv)
  PROCNAMEC()
  Protected bReqd
  Protected n, m, i, sMidiCue.s
  
  ; debugMsg0(sProcName, "nMidiChannel=" + nMidiChannel + ", nMsgType=$" + Hex(nMsgType) + ", kk=" + kk + ", vv=" + vv)
  
  If nMsgType = $8
    ; MIDI Note Off: accept if either Note Off OR Note On is specified
    For n = 0 To ArraySize(gaMidiControl())
      With gaMidiControl(n)
        If \nMidiChannel = nMidiChannel
          For m = 0 To #SCS_MAX_MIDI_COMMAND
            Select \aMidiCommand[m]\nCmd
              Case $8, $9
                bReqd = #True
                Break 2 ; Break m, n
            EndSelect
          Next m
        EndIf
      EndWith
    Next n
  Else
    ; other MIDI message types: only check for nMsgType
    ; debugMsg(sProcName, "nMsgType=" + nMsgType)
    For n = 0 To ArraySize(gaMidiControl())
      With gaMidiControl(n)
        ; debugMsg(sProcName, "gaMidiControl(n)\nMidiChannel=" + \nMidiChannel)
        If \nMidiChannel = nMidiChannel
          For m = 0 To #SCS_MAX_MIDI_COMMAND
            ; debugMsg(sProcName, "gaMidiControl(" + n + ")\aMidiCommand[" + m + ")\nCmd=" + \aMidiCommand[m]\nCmd)
            If \aMidiCommand[m]\nCmd = nMsgType
              bReqd = #True
              Break 2 ; Break m, n
            EndIf
          Next m
        EndIf
      EndWith
    Next n
  EndIf
  
  If bReqd = #False
    If nMsgType = $B
      sMidiCue = Str(kk)
      For n = 0 To ArraySize(gaMidiControl())
        With gaMidiControl(n)
          If \nMidiChannel = nMidiChannel
            For m = 0 To #SCS_MAX_MIDI_COMMAND
              Select \aMidiCommand[m]\nCmd
                Case $200B
                  For i = 1 To gnLastCue
                    If aCue(i)\bCueEnabled And aCue(i)\sMidiCue = sMidiCue
                      bReqd = #True
                      Break 3 ; Break i, m, n
                    EndIf
                  Next i
              EndSelect
            Next m
          EndIf ; EndIf \nMidiChannel = nMidiChannel
        EndWith
      Next n
    EndIf ; EndIf nMsgType = $B
  EndIf ; EndIf bReqd = #False
  
  ; debugMsg0(sProcName, #SCS_END + ", nMidiChannel=" + nMidiChannel + ", nMsgType=" + nMsgType + ", returning " + strB(bReqd))
  ProcedureReturn bReqd
  
EndProcedure

Procedure getMidiFileLength(sFileName.s)
  PROCNAMEC()
  ; returns length of a media file in milliseconds - designed for MIDI files but counld be used by other file formats recognized by mciSendString
  Protected sLength.s, nLength
  Protected sCommandString.s
  Protected nErrCode.l
  Protected *lpReturnString
  
  *lpReturnString = AllocateMemory(64)
  
  sCommandString = "Open " + #DQUOTE$ + sFileName + #DQUOTE$ + " alias MediaFile"
  nErrCode = mciSendString_(sCommandString, #Null, 0, #Null)
  sCommandString = "Set MediaFile time format milliseconds"
  nErrCode = mciSendString_(sCommandString, #Null, 0, #Null)
  sCommandString = "Status MediaFile length"
  nErrCode = mciSendString_(sCommandString, *lpReturnString, 32, 0)
  sLength = PeekS(*lpReturnString)
  nLength = Val(sLength)
  sCommandString = "Close MediaFile"
  nErrCode = mciSendString_(sCommandString, #Null, 0, #Null)
  
  FreeMemory(*lpReturnString)
  
  ProcedureReturn nLength
  
EndProcedure

Procedure unpackNRPN(*rCtrlSend.tyCtrlSend, bCheckOnly=#True)
  PROCNAMEC()
  Protected bValidNRPN, sWorkString.s, nWorkStringLength, nPos, nPartNo, sPart.s, sChar1.s, sChar2.s
  Protected Dim nValue(4)
  Protected nChannel
  
  ; NRPN (Non-Registered Parameter Number) entry in Wikipedia:
  ; ----------------------------------------------------------
  ; Unlike other MIDI controllers (such as velocity, modulation, volume, etc.), NRPNs require more than one item of controller data to be sent.
  ; First, controller 99 - NRPN Most Significant Byte (MSB)
  ; followed by 98 - NRPN Least Significant Byte (LSB) sent as a pair specify the parameter to be changed.
  ; Controller 6 then sets the value of the relevant parameter.
  ; Controller 38 may optionally then be sent as a fine adjustment to the value set by controller 6.
  ;
  ; This fine adjustment is part of the conventional MIDI controller specification, where any of the first 32 controls can be optionally paired with a control offset 32 higher.
  ; This is the rare 14-bit Continuous Controller feature of the MIDI specification, and NRPNs simply take advantage of that existing option in the same way to offer 16,384 possible values instead of only 128.
  
  With grCtrlSendDef
    nValue(1) = \nMSParam1
    nValue(2) = \nMSParam2
    nValue(3) = \nMSParam3
    nValue(4) = \nMSParam4
  EndWith
    
  With *rCtrlSend
    sWorkString = UCase(RemoveString(\sEnteredString, " "))
    ; debugMsg(sProcName, "sWorkString=" + #DQUOTE$ + sWorkString + #DQUOTE$)
    If IsHexString(sWorkString)
      nWorkStringLength = Len(sWorkString)
      Select \nMSMsgType
        Case #SCS_MSGTYPE_NRPN_GEN
          ; #SCS_MSGTYPE_NRPN_GEN: 'Standard' NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
          If nWorkStringLength = 18 Or nWorkStringLength = 24
            ; a valid NRPN message must contain either 3 or 4 parts (each of 6 hexadecimal characters)
            bValidNRPN = #True
            For nPos = 1 To nWorkStringLength Step 6
              nPartNo + 1
              sPart = Mid(sWorkString, nPos, 6)
              If sPart
                If Len(sPart) <> 6
                  bValidNRPN = #False
                ElseIf Left(sPart,1) <> "B" ; Hex("B") = MIDI Control Change message
                  bValidNRPN = #False
                ElseIf nPartNo > 1 And Left(sPart,2) <> Left(sWorkString,2)
                  ; 2nd character of sPart (after "B") is the MIDI Channel, where 0 = MIDI Channel 1
                  bValidNRPN = #False
                ElseIf nPartNo = 1 And Mid(sPart,3,2) <> "63" ; Hex("63") = controller 99
                  bValidNRPN = #False
                ElseIf nPartNo = 2 And Mid(sPart,3,2) <> "62" ; Hex("62") = controller 98
                  bValidNRPN = #False
                ElseIf nPartNo = 3 And Mid(sPart,3,2) <> "06" ; Hex("06") = controller 6
                  bValidNRPN = #False
                ElseIf nPartNo = 4 And Mid(sPart,3,2) <> "26" ; Hex("26") = controller 38 ; Note: this last part of an NRPN message is optional
                  bValidNRPN = #False
                EndIf
                If bValidNRPN = #False
                  Break
                EndIf
                sChar1 = Mid(sPart,5,1)
                sChar2 = Mid(sPart,6,1)
                ; debugMsg(sProcName, "sChar1=" + sChar1 + ", sChar2=" + sChar2 + ", hexToDec(sChar1)=" + hexToDec(sChar1) + ", hexToDec(sChar2)=" + hexToDec(sChar2))
                nValue(nPartNo) = (hexToDec(sChar1) * 16) + hexToDec(sChar2)
              EndIf
            Next nPos
          EndIf ; EndIf nWorkStringLength = 18 Or nWorkStringLength = 24
          
        Case #SCS_MSGTYPE_NRPN_YAM
          ; #SCS_MSGTYPE_NRPN_YAM: Yamaha NRPN (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
          ; Also, second and subsequent status bytes not required
          bValidNRPN = #True
          If Left(sWorkString,1) <> "B"
            bValidNRPN = #False
          Else
            nChannel = hexToDec(Mid(sWorkString,2,1)) + 1
            nPos = 3
            For nPartNo = 1 To 4
              If nPartNo = 4 And nPos >= Len(sWorkString)
                ; Note: part 4 is optional
                Break
                EndIf
              If nPartNo > 1 And Mid(sWorkString,nPos,1) = "B"
                If Mid(sWorkString,nPos,2) <> Left(sWorkString,2)
                  bValidNRPN = #False
                  Break
                Else
                  nPos + 2
                EndIf
              EndIf
              If nPartNo = 1 And Mid(sWorkString,nPos,2) <> "62"
                bValidNRPN = #False
              ElseIf nPartNo = 2 And Mid(sWorkString,nPos,2) <> "63"
                bValidNRPN = #False
              ElseIf nPartNo = 3 And Mid(sWorkString,nPos,2) <> "06"
                bValidNRPN = #False
              ElseIf nPartNo = 4 And Mid(sWorkString,nPos,2) <> "26"
                bValidNRPN = #False
              EndIf
              If bValidNRPN = #False
                Break
              EndIf
              sChar1 = Mid(sWorkString,nPos+2,1)
              sChar2 = Mid(sWorkString,nPos+3,1)
              ; debugMsg(sProcName, "sChar1=" + sChar1 + ", sChar2=" + sChar2 + ", hexToDec(sChar1)=" + hexToDec(sChar1) + ", hexToDec(sChar2)=" + hexToDec(sChar2))
              nValue(nPartNo) = (hexToDec(sChar1) * 16) + hexToDec(sChar2)
              nPos + 4
            Next nPartNo
            Swap nValue(1), nValue(2)
          EndIf
            
      EndSelect
    EndIf ; EndIf IsHexString(sWorkString)
    If bValidNRPN
      If bCheckOnly = #False
        \nMSChannel = hexToDec(Mid(sWorkString,2,1)) + 1
        \nMSParam1 = nValue(1)
        \nMSParam2 = nValue(2)
        \nMSParam3 = nValue(3)
        \nMSParam4 = nValue(4)
        If nValue(4) >= 0
          debugMsg(sProcName, "bValidNRPN=" + strB(bValidNRPN) + ", \sEnteredString=" + #DQUOTE$ + \sEnteredString + #DQUOTE$ +
                              ", \nMSChannel=" + \nMSChannel +
                              ", nValue(1)=" + hex2(nValue(1)) + ", nValue(2)=" + hex2(nValue(2)) + ", nValue(3)=" + hex2(nValue(3)) + ", nValue(4)=" + hex2(nValue(4)))
        Else
          debugMsg(sProcName, "bValidNRPN=" + strB(bValidNRPN) + ", \sEnteredString=" + #DQUOTE$ + \sEnteredString + #DQUOTE$ +
                              ", \nMSChannel=" + \nMSChannel +
                              ", nValue(1)=" + hex2(nValue(1)) + ", nValue(2)=" + hex2(nValue(2)) + ", nValue(3)=" + hex2(nValue(3)))
        EndIf
      EndIf
    EndIf
  EndWith
  ProcedureReturn bValidNRPN
EndProcedure

Procedure convertMidiFreesToNRPNIfRequired()
  PROCNAMEC()
  Protected i, j, n, sMsg.s, nResponse
  Static bMessageDisplayed, bConvertToNRPN, nConverted
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeM
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeM
          For n = 0 To #SCS_MAX_CTRL_SEND
            If aSub(j)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FREE
              If unpackNRPN(@aSub(j)\aCtrlSend[n], #True)
                If bMessageDisplayed = #False
                  sMsg = "A MIDI Free-Format Message in Cue " + aCue(i)\sCue + " looks like a MIDI NRPN Message. Do you want this and other such messsages converted to MIDI NRPN Control Send messages?"
                  nResponse = MessageRequester(grProd\sTitle, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                  If nResponse = #PB_MessageRequester_Yes
                    bConvertToNRPN = #True
                  EndIf
                  bMessageDisplayed = #True
                EndIf
                If bConvertToNRPN
                  If unpackNRPN(@aSub(j)\aCtrlSend[n], #False)
                    ; should be #True if we get here
                    debugMsg(sProcName, "converting aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n + "]\nMSMsgType from #SCS_MSGTYPE_FREE To #SCS_MSGTYPE_NRPN_GEN")
                    aSub(j)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_NRPN_GEN
                    buildDisplayInfoForCtrlSend(@aSub(j), n)
                    nConverted + 1
                  EndIf
                EndIf
              EndIf ; EndIf unpackNRPN(@aSub(j)\aCtrlSend[n], #True)
            EndIf ; EndIf aSub(j)\aCtrlSend[n]\nMSMsgType = #SCS_MSGTYPE_FREE
          Next n
        EndIf ; EndIf aSub(j)\bSubTypeM
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bSubTypeM
  Next i
  
  ProcedureReturn nConverted
  
EndProcedure

Procedure convertMidiCCToNRPNIfRequired()
  PROCNAMEC()
  Protected i, j, n1, n2, n3, sMsg.s, nResponse, bNRPNGen, bNRPNYam, nMidiChannel, bLooksLikeNRPN, nPartCount
  Protected nNRPNMSB.a, nNRPNLSB.a, nDataMSB.a, nDataLSB.a
  Static bMessageDisplayed, bConvertToNRPN, nConverted
  
  ; debugCuePtrs()
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeM
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeM
          ; debugMsg(sProcName, "CHECKING aSub(" + getSubLabel(j) + ") ------------------")
          With aSub(j)
            For n1 = 0 To #SCS_MAX_CTRL_SEND
              bNRPNGen = #False
              bNRPNYam = #False
              bLooksLikeNRPN = #False
              nDataLSB = 0 ; 'Data LSB' is optional so there may not be a CC message for this part
              If \aCtrlSend[n1]\nMSMsgType = #SCS_MSGTYPE_CC
                If \aCtrlSend[n1]\nMSParam1 = 99
                  bNRPNGen = #True
                  bLooksLikeNRPN = #True
                  nNRPNMSB = \aCtrlSend[n1]\nMSParam2
                ElseIf \aCtrlSend[n1]\nMSParam1 = 98
                  bNRPNYam = #True
                  bLooksLikeNRPN = #True
                  nNRPNLSB = \aCtrlSend[n1]\nMSParam2
                EndIf
                If bLooksLikeNRPN
                  nMidiChannel = \aCtrlSend[n1]\nMSChannel
                  n2 = n1 + 1
                  If n2 <= #SCS_MAX_CTRL_SEND
                    If bNRPNGen And \aCtrlSend[n2]\nMSParam1 = 98 And \aCtrlSend[n2]\nMSChannel = nMidiChannel
                      nNRPNLSB = \aCtrlSend[n2]\nMSParam2
                    ElseIf bNRPNYam And \aCtrlSend[n2]\nMSParam1 = 99 And \aCtrlSend[n2]\nMSChannel = nMidiChannel
                      nNRPNMSB = \aCtrlSend[n2]\nMSParam2
                    Else
                      bLooksLikeNRPN = #False
                    EndIf
                  Else
                    bLooksLikeNRPN = #False
                  EndIf
                  If bLooksLikeNRPN
                    n2 + 1
                    If n2 <= #SCS_MAX_CTRL_SEND
                      If \aCtrlSend[n2]\nMSParam1 = 6 And \aCtrlSend[n2]\nMSChannel = nMidiChannel
                        nDataMSB = \aCtrlSend[n2]\nMSParam2
                        nPartCount = 3
                      Else
                        bLooksLikeNRPN = #False
                      EndIf
                    Else
                      bLooksLikeNRPN = #False
                    EndIf
                  EndIf
                  If bLooksLikeNRPN
                    n2 + 1
                    If n2 <= #SCS_MAX_CTRL_SEND
                      If \aCtrlSend[n2]\nMSParam1 = 38 And \aCtrlSend[n2]\nMSChannel = nMidiChannel
                        nDataLSB = \aCtrlSend[n2]\nMSParam2
                        nPartCount = 4
                      EndIf
                    EndIf
                  EndIf
                  If bLooksLikeNRPN
                    If bMessageDisplayed = #False
                      sMsg = "MIDI Control Change messages in Cue " + aCue(i)\sCue + " look like a MIDI NRPN Message. Do you want these and other such messsages converted to MIDI NRPN Control Send messages?"
                      nResponse = MessageRequester(grProd\sTitle, sMsg, #PB_MessageRequester_YesNo | #MB_ICONQUESTION)
                      If nResponse = #PB_MessageRequester_Yes
                        bConvertToNRPN = #True
                      EndIf
                      bMessageDisplayed = #True
                    EndIf
                    If bConvertToNRPN
                      If bNRPNGen
                        debugMsg(sProcName, "converting aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n1 + "] To NRPN_GEN")
                        \aCtrlSend[n1]\nMSMsgType = #SCS_MSGTYPE_NRPN_GEN
                      ElseIf bNRPNYam
                        debugMsg(sProcName, "converting aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n1 + "] To NRPN_YAM")
                        \aCtrlSend[n1]\nMSMsgType = #SCS_MSGTYPE_NRPN_YAM
                      EndIf
                      \aCtrlSend[n1]\nMSChannel = nMidiChannel
                      \aCtrlSend[n1]\nMSParam1 = nNRPNMSB
                      \aCtrlSend[n1]\nMSParam2 = nNRPNLSB
                      \aCtrlSend[n1]\nMSParam3 = nDataMSB
                      \aCtrlSend[n1]\nMSParam4 = nDataLSB
                      n2 = n1 + 1
                      n3 = n1 + nPartCount
                      While n2 <= #SCS_MAX_CTRL_SEND
                        If n3 <= #SCS_MAX_CTRL_SEND
                          ; debugMsg(sProcName, "moving aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n3 + "] To \aCtrlSend[" + n2 + "]")
                          \aCtrlSend[n2] = \aCtrlSend[n3]
                        Else
                          ; debugMsg(sProcName, "clearing aSub(" + getSubLabel(j) + ")\aCtrlSend[" + n2 + "]")
                          \aCtrlSend[n2] = grCtrlSendDef
                        EndIf
                        n3 + 1
                        n2 + 1
                      Wend
                      buildDisplayInfoForCtrlSend(@aSub(j), n1)
                      nConverted + 1
                    EndIf ; EndIf bConvertToNRPN
                  EndIf ; EndIf bLooksLikeNRPN
                EndIf ; EndIf bLooksLikeNRPN
              EndIf ; EndIf \aCtrlSend[n1]\nMSMsgType = #SCS_MSGTYPE_CC
            Next n1
          EndWith
        EndIf ; EndIf aSub(j)\bSubTypeM
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bSubTypeM
  Next i
  ; debugCuePtrs()
  
  ProcedureReturn nConverted
  
EndProcedure

Procedure.s buildNRPNSendString(*rCtrlSend.tyCtrlSend)
  PROCNAMEC()
  Protected sWorkString.s, sStatusByte.s
  
  With *rCtrlSend
    If \nMSChannel >= 1 And \nMSChannel <= 16
      sStatusByte = "B" + Hex(\nMSChannel-1) + " "
      Select \nMSMsgType
        Case #SCS_MSGTYPE_NRPN_GEN
          ; #SCS_MSGTYPE_NRPN_GEN: 'Standard' NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
          sWorkString = sStatusByte + "63 "
          If \nMSParam1 >= 0
            sWorkString + hex2(\nMSParam1) + " "
          Else
            sWorkString + "<NRPN MSB> " + RTrim(" " + \sMSParam1)
          EndIf
          If \nMSParam2 >= 0
            sWorkString + sStatusByte + "62 " + hex2(\nMSParam2) + " "
          Else
            sWorkString + sStatusByte + "62 <NRPN LSB> " + RTrim(" " + \sMSParam2)
          EndIf
          If \nMSParam3 >= 0
            sWorkString + sStatusByte + "06 " + hex2(\nMSParam3) + " "
          Else
            sWorkString + sStatusByte + "06 <Data MSB> " + RTrim(" " + \sMSParam3)
          EndIf
          If \nMSParam4 >= 0
            sWorkString + sStatusByte + "26 " + hex2(\nMSParam4)
          ElseIf \sMSParam4
            sWorkString + "26 <Data LSB> " + RTrim(" " + \sMSParam4)
          EndIf
          
        Case #SCS_MSGTYPE_NRPN_YAM
          ; #SCS_MSGTYPE_NRPN_YAM: Yamaha NRPN (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
          ; Also, second and subsequent status bytes not required
          sWorkString = sStatusByte + "62 "
          If \nMSParam2 >= 0
            sWorkString + hex2(\nMSParam2) + " "
          Else
            sWorkString + "<NRPN LSB> " + RTrim(" " + \sMSParam2)
          EndIf
          If \nMSParam1 >= 0
            sWorkString + "63 " + hex2(\nMSParam1) + " "
          Else
            sWorkString + "63 <NRPN MSB> " + RTrim(" " + \sMSParam1)
          EndIf
          If \nMSParam3 >= 0
            sWorkString + "06 " + hex2(\nMSParam3) + " "
          Else
            sWorkString + "06 <Data MSB> " + RTrim(" " + \sMSParam3)
          EndIf
          If \nMSParam4 >= 0
            sWorkString + "26 " + hex2(\nMSParam4)
          ElseIf \sMSParam4
            sWorkString + "26 <Data LSB> " + RTrim(" " + \sMSParam4)
          EndIf
          
      EndSelect
    EndIf
  EndWith
  
  ProcedureReturn sWorkString
  
EndProcedure

Procedure.s buildNRPNDisplayInfo(*rCtrlSend.tyCtrlSend)
  PROCNAMEC()
  Protected sDisplayInfo.s
  
  With *rCtrlSend
    If \nMSChannel >= 1 And \nMSChannel <= 16
      sDisplayInfo = "ch" + \nMSChannel + " "
      Select \nMSMsgType
        Case #SCS_MSGTYPE_NRPN_GEN
          ; #SCS_MSGTYPE_NRPN_GEN: Standard NRPN (NRPN MSB, NRPN LSB, Data MSB, Data LSB)
          sDisplayInfo + "msb:"
          If \nMSParam1 >= 0
            sDisplayInfo + hex2(\nMSParam1) + " "
          ElseIf \sMSParam1
            sDisplayInfo + \sMSParam1 + " "
          Else
            sDisplayInfo + "? "
          EndIf
          sDisplayInfo + "lsb:"
          If \nMSParam2 >= 0
            sDisplayInfo + hex2(\nMSParam2) + " "
          ElseIf \sMSParam2
            sDisplayInfo + \sMSParam2 + " "
          Else
            sDisplayInfo + "? "
          EndIf
          
        Case #SCS_MSGTYPE_NRPN_YAM
          ; #SCS_MSGTYPE_NRPN_YAM: Yamaha NRPN (NRPN LSB, NRPN MSB, Data MSB, Data LSB)
          sDisplayInfo + "lsb:"
          If \nMSParam2 >= 0
            sDisplayInfo + hex2(\nMSParam2) + " "
          ElseIf \sMSParam2
            sDisplayInfo + \sMSParam2 + " "
          Else
            sDisplayInfo + "? "
          EndIf
          sDisplayInfo + "msb:"
          If \nMSParam1 >= 0
            sDisplayInfo + hex2(\nMSParam1) + " "
          ElseIf \sMSParam1
            sDisplayInfo + \sMSParam1 + " "
          Else
            sDisplayInfo + "? "
          EndIf
      EndSelect
      
      sDisplayInfo + "data msb:"
      If \nMSParam3 >= 0
        sDisplayInfo + hex2(\nMSParam3) + " "
      ElseIf \sMSParam3
        sDisplayInfo + \sMSParam3 + " "
      Else
        sDisplayInfo + "? "
      EndIf
      If \nMSParam4 >= 0
        ; nb this field is optional
        sDisplayInfo + "lsb:" + hex2(\nMSParam4) + " "
      ElseIf \sMSParam4
        sDisplayInfo + "lsb:" + \sMSParam4 + " "
      EndIf
    EndIf
  EndWith
  
  ProcedureReturn sDisplayInfo
  
EndProcedure

Procedure stopMTC()
  PROCNAMEC()
  Protected i, j
  
  debugMsg(sProcName, #SCS_START)
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeU
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeU
          If aSub(j)\nSubState >= #SCS_CUE_FADING_IN And aSub(j)\nSubState <= #SCS_CUE_FADING_OUT
            debugMsg(sProcName, "calling closeSub(" + getSubLabel(j) + ", #False, #True, #True)")
            closeSub(j, #False, #True, #True)
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure encodeCtrlMidiRemoteDev(sCtrlMidiRemoteDev.s)
  Protected nCtrlMidiRemoteDev
  
  Select sCtrlMidiRemoteDev
    Case "Any"
      nCtrlMidiRemoteDev = #SCS_CS_MIDI_REM_ANY
    Case "Qu", "AH_Qu"
      nCtrlMidiRemoteDev = #SCS_CS_MIDI_REM_AH_QU
    Case "AH_SQ"
      nCtrlMidiRemoteDev = #SCS_CS_MIDI_REM_AH_SQ
    Default
      nCtrlMidiRemoteDev = #SCS_CS_MIDI_REM_ANY
  EndSelect
  ProcedureReturn nCtrlMidiRemoteDev
EndProcedure

Procedure.s decodeCtrlMidiRemoteDev(nCtrlMidiRemoteDev)
  Protected sCtrlMidiRemoteDev.s
  
  Select nCtrlMidiRemoteDev
    Case #SCS_CS_MIDI_REM_ANY
      sCtrlMidiRemoteDev = "Any"
    Case #SCS_CS_MIDI_REM_AH_QU
      sCtrlMidiRemoteDev = "AH_Qu"
    Case #SCS_CS_MIDI_REM_AH_SQ
      sCtrlMidiRemoteDev = "AH_SQ"
    Default
      sCtrlMidiRemoteDev = "Any"
  EndSelect
  ProcedureReturn sCtrlMidiRemoteDev
EndProcedure

Procedure.s decodeCtrlMidiRemoteDevL(nCtrlMidiRemoteDev)
  Protected sCtrlMidiRemoteDev.s
  
  sCtrlMidiRemoteDev = decodeCtrlMidiRemoteDev(nCtrlMidiRemoteDev)
  If sCtrlMidiRemoteDev
    ProcedureReturn Lang("Midi", sCtrlMidiRemoteDev)
  Else
    ProcedureReturn ""
  EndIf
  
EndProcedure

Procedure.l getMidiInDeviceIdForMidiOutDeviceId(nMidiOutDeviceId.l)
  PROCNAMEC()
  Protected n, sPhysicalDevDesc.s, nMidiInDeviceId.l
  
  nMidiInDeviceId = -1
  For n = 0 To gnMaxConnectedDev
    With gaConnectedDev(n)
      If \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
        If \nMidiDeviceID = nMidiOutDeviceId
          sPhysicalDevDesc = \sPhysicalDevDesc
          Break
        EndIf
      EndIf
    EndWith
  Next n
  If sPhysicalDevDesc
    For n = 0 To gnMaxConnectedDev
      With gaConnectedDev(n)
        If \nDevType = #SCS_DEVTYPE_CC_MIDI_IN
          If \sPhysicalDevDesc = sPhysicalDevDesc
            nMidiInDeviceId = \nMidiDeviceID
            Break
          EndIf
        EndIf
      EndWith
    Next n
  EndIf
  ProcedureReturn nMidiInDeviceId
EndProcedure

Procedure calcMSParamValueForCallableCueParam(*rCue.tyCue, sStringParam.s, nNumParam)
  PROCNAMEC()
  Protected nMSParamValue
  
  If sStringParam
    nMSParamValue = getCallableCueParamIndex(*rCue, sStringParam) + #SCS_MISC_WQM_COMBO_PARAM_BASE
  Else
    nMSParamValue = nNumParam
  EndIf
  ProcedureReturn nMSParamValue
EndProcedure

Procedure setBooleanUseExternalController(*rCtrlSetup.tyCtrlSetup)
  ; Added 25Jun2022 11.9.4
  PROCNAMEC()
  With *rCtrlSetup
    \bUseExternalController = #True
    Select \nController
      Case #SCS_CTRL_BCF2000, #SCS_CTRL_BCR2000
        If Len(\sCtrlMidiInPort) = 0  Or Len(\sCtrlMidiOutPort) = 0
          \bUseExternalController = #False
        EndIf
      Case #SCS_CTRL_NK2
        If Len(\sCtrlMidiInPort) = 0 ; no MIDI Out for NK2 so don't check \sCtrlMidiOutPort
          \bUseExternalController = #False
        EndIf
      Default
        \bUseExternalController = #False
    EndSelect
    ; debugMsg(sProcName, "*rCtrlSetup\nController=" + decodeController(\nController) + ", \sCtrlMidiInPort=" + \sCtrlMidiInPort + ", \sCtrlMidiOutPort=" + \sCtrlMidiOutPort + ", \bUseExternalController=" + \bUseExternalController)
  EndWith
EndProcedure

; EOF