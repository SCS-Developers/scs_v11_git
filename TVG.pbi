; File: TVG.pbi

EnableExplicit

Procedure updateMonitorInfoForTVG()
  PROCNAMEC()
  Protected *mVideoGrabber
  Protected v, v2
  Protected nLongResult.l
  Protected nMonitorsCount.l
  Protected nLeftBound.l, nTopBound.l, nRightBound.l, nBottomBound.l
  Protected nMonitorIndex, nMonitorNo, nPass
  
  debugMsgT(sProcName, #SCS_START)
  
  *mVideoGrabber = TVG_CreateVideoGrabber(0)
  debugMsgT(sProcName, "TVG_CreateVideoGrabber(0) returned *mVideoGrabber=" + *mVideoGrabber)
  If *mVideoGrabber
    nMonitorsCount = TVG_MonitorsCount(*mVideoGrabber)
    debugMsgT2(sProcName, "TVG_MonitorsCount(*mVideoGrabber)", nMonitorsCount)
    ; Added 7Nov2018 11.8.0aq to test bug reported by Beverley (Brighton Little Theatre)  that crashed SCS on adding a video cue if the default screen (prod properties) was set to 3 but only 2 screens were available
    If nMonitorsCount > #cMaxScreenNo
      nMonitorsCount = #cMaxScreenNo
      debugMsgT(sProcName, "nMonitorsCount reset to #cMaxScreenNo, ie nMonitorsCount=" + nMonitorsCount)
    EndIf
    ; End added 7Nov2018 11.8.0aq
    
    ; Added 9Oct2019 11.8.2au - see comments further down for 9Oct2019
    For nMonitorNo = 1 To gnMonitors
      gaMonitors(nMonitorNo)\nTVGDisplayMonitor = -1
    Next nMonitorNo
    ; End added 9Oct2019 11.8.2au
    
    For nMonitorIndex = 0 To (nMonitorsCount - 1)
      nLongResult = TVG_MonitorBounds(*mVideoGrabber, nMonitorIndex, @nLeftBound, @nTopBound, @nRightBound, @nBottomBound)
      debugMsgT(sProcName, "TVG_MonitorBounds(*mVideoGrabber, " + nMonitorIndex + ", @nLeftBound, @nTopBound, @nRightBound, @nBottomBound) returned " + strB(nLongResult))
      If nLongResult <> 0
        debugMsgT(sProcName, "nMonitorIndex=" + nMonitorIndex + ", nLeftBound=" + nLeftBound + ", nTopBound=" + nTopBound + ", nRightBound=" + nRightBound + ", nBottomBound=" + nBottomBound)
        If (nLeftBound = gaMonitors(1)\nDesktopLeft) And (nTopBound = gaMonitors(1)\nDesktopTop)
          grTVGControl\nDisplayMonitor = nMonitorIndex
          debugMsgT(sProcName, "grTVGControl\nDisplayMonitor=" + grTVGControl\nDisplayMonitor)
        EndIf
        For nPass = 1 To 2
          For nMonitorNo = 1 To gnMonitors
            With gaMonitors(nMonitorNo)
              ; debugMsg(sProcName, "nLeftBound=" + nLeftBound + ", nTopBound=" + nTopBound + ", gaMonitors(" + nMonitorNo + ")\nDesktopLeft=" + \nDesktopLeft + ", \nDesktopTop=" + \nDesktopTop)
              ; ; The following test changed 23Aug2019 11.8.2af following bug report from Stas Ushomirsky regarding screens 1 and 2 being swapped
              ; ; If \nDesktopIndex = nMonitorIndex ; deleted 23Aug2019 11.8.2af
              ; If (\nDesktopLeft = nLeftBound) And (\nDesktopTop = nTopBound) ; added 23Aug2019 11.8.2af
              ; INFO: The above changed again 4Jan2020 11.8.2.1aw following test from Dave Jenkins. Made into a 2-pass test because Dave's 2nd monitor seemd to have a 125% scaling which for some reason
              ; seemed to affect the TVG LeftBound (and other) settings so that they didn't match the corresponding PB desktop settings. Doesn't happen in my development environment.
              ; Pass 1 tries to match against the PB desktop settings.
              ; For any gaMonitors() entries not set in pass 1, pass 2 tries to match using the index.
              If ((nPass = 1) And (\nDesktopLeft = nLeftBound) And (\nDesktopTop = nTopBound)) Or
                 ((nPass = 2) And (\nTVGDisplayMonitor = -1) And (\nDesktopIndex = nMonitorIndex))
                \nMonitorBoundsLeft = nLeftBound
                \nMonitorBoundsTop = nTopBound
                \nMonitorBoundsRight = nRightBound
                \nMonitorBoundsBottom = nBottomBound
                \nMonitorBoundsWidth = nRightBound - nLeftBound
                \nMonitorBoundsHeight = nBottomBound - nTopBound
                If \nMonitorBoundsWidth > 0
                  \nDisplayScalingPercentage = Round(\nDeskTopWidth * 100 / \nMonitorBoundsWidth, #PB_Round_Nearest)
                Else
                  ; shouldn't get here
                  \nDisplayScalingPercentage = 100
                EndIf
                \nTVGDisplayMonitor = nMonitorIndex
                \nTVGDisplayLeft = 0
                \nTVGDisplayTop = 0
                \nTVGDisplayWidth = \nMonitorBoundsWidth
                \nTVGDisplayHeight = \nMonitorBoundsHeight
                Break 2 ; Break nPass
              EndIf
            EndWith
          Next nMonitorNo
        Next nPass
        
      EndIf
    Next nMonitorIndex
    
    ; deleted 16Dec2019 11.8.2.1ag as it appears to incorrectly delete monitors in logs from Vincent Rijntjes, and so has been replaced by calls to the new procedure getBlanketDesktopIndex() 
;     ; added 9Oct2019 11.8.2au following bug report from Rob Widdicombe who had 'desktop' settings of:
;     ;   DesktopX(0)=0, DesktopY(0)=0, DesktopWidth(0)=1440, DesktopHeight(0)=900      0,0,1440,900
;     ;   DesktopX(1)=1440, DesktopY(1)=0, DesktopWidth(1)=1920, DesktopHeight(1)=1080  1440,0,1920,1080
;     ;   DesktopX(2)=5280, DesktopY(2)=0, DesktopWidth(2)=1920, DesktopHeight(2)=1080  5280,0,1920,1080
;     ;   DesktopX(3)=3360, DesktopY(3)=0, DesktopWidth(3)=1920, DesktopHeight(3)=1080  3360,0,1920,1080
;     ;   DesktopX(4)=0,    DesktopY(4)=0, DesktopWidth(4)=7200, DesktopHeight(4)=1080  0,0,7200,1080
;     ; but TVG MonitorBounds of:
;     ;   nMonitorIndex=0, nLeftBound=0,    nTopBound=0, nRightBound=1440, nBottomBound=900  0,0,1440,900  scaling 100%
;     ;   nMonitorIndex=1, nLeftBound=1440, nTopBound=0, nRightBound=2720, nBottomBound=720  1440,0,1280,720  scaling 150%
;     ;   nMonitorIndex=2, nLeftBound=3360, nTopBound=0, nRightBound=4640, nBottomBound=720  3360,0,1280,720  scaling 150%
;     ;   nMonitorIndex=3, nLeftBound=5280, nTopBound=0, nRightBound=6560, nBottomBound=720  5280,0,1280,720  scaling 150%
;     ; note that Desktop 4 is not included in TVG MonitorBounds which is reasonable because it is a blanket desktop definition that covers all 4 monitors
;     ; Rob advised that this condition occurs when using VNC (see email 8Oct2019)
;     ; Fix: delete from gaMonitors any entries that did not find a TVG MonitorBounds entry, eg the entry originally populated from Desktop 4 in the above example
;     v = 1
;     While v <= gnMonitors
;       If gaMonitors(v)\nTVGDisplayMonitor = -1
;         ; no match found in TVG MonitorBounds
;         debugMsg(sProcName, "deleting entry for gaMonitors(" + v + ")")
;         For v2 = v To gnMonitors
;           gaMonitors(v2) = gaMonitors(v2+1)
;           debugMsg(sProcName, "setting gaMonitors(" + v2 + ")\nDisplayNo=" + v2 + " (was " + gaMonitors(v2)\nDisplayNo + ")")
;           gaMonitors(v2)\nDisplayNo = v2
;         Next v2
;         gnMonitors -1
;       Else
;         v + 1
;       EndIf
;     Wend
;     ; end added 9Oct2019 11.8.2au
    ; end deleted 16Dec2019 11.8.2.1ag
    
    For v = 1 To gnMonitors
      With gaMonitors(v)
        debugMsgT(sProcName, "gaMonitors(" + v + ")\nDesktopLeft=" + \nDesktopLeft + ", \nDesktopTop=" + \nDesktopTop + ", \nDeskTopWidth=" + \nDeskTopWidth + ", \nDeskTopHeight=" + \nDeskTopHeight)
        debugMsgT(sProcName, "gaMonitors(" + v + ")\nMonitorBoundsLeft=" + \nMonitorBoundsLeft + ", \nMonitorBoundsTop=" + \nMonitorBoundsTop + ", \nMonitorBoundsWidth=" + \nMonitorBoundsWidth + ", \nMonitorBoundsHeight=" + \nMonitorBoundsHeight +
                             ", \nDisplayScalingPercentage=" + \nDisplayScalingPercentage)
        debugMsgT(sProcName, "gaMonitors(" + v + ")\nTVGDisplayMonitor=" + \nTVGDisplayMonitor +
                             ", \nTVGDisplayLeft=" + \nTVGDisplayLeft + ", \nTVGDisplayTop=" + \nTVGDisplayTop + ", \nTVGDisplayWidth=" + \nTVGDisplayWidth + ", \nTVGDisplayHeight=" + \nTVGDisplayHeight)
      EndWith
    Next v
    
    TVG_DestroyVideoGrabber(*mVideoGrabber)
    debugMsgT(sProcName, "TVG_DestroyVideoGrabber(*mVideoGrabber)")
  EndIf  
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure initTVG()
  PROCNAMEC()
  Protected nTVGIndex, n
  Protected *mVersion, sVersion.s
  Protected nHandle.i, sHandle.s
  
  debugMsgT(sProcName, #SCS_START)
  
  ; nb cannot set these initial values in setDefaults_All() because that procedure is called after mmInit() is called, because setDefaults_All() needs gnDefaultAudioDriver which is set in mmInit()
  With grTVGDef
    \nTVGAudPtr = -1
    \nTVGSubPtr = -1
    \nTVGVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    \nLastOnPlayerStateChange = #tvc_ps_Closed
  EndWith
  
  For n = 0 To ArraySize(gaTVG())
    gaTVG(n) = grTVGDef
  Next n
  nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_NONE, #SCS_VID_SRC_FILE, #True)
  If nTVGIndex >= 0
    nHandle = *gmVideoGrabber(nTVGIndex)
    sHandle = decodeHandle(nHandle)
    If nHandle
      *mVersion = TVG_GetVersion(nHandle)
      If *mVersion
        sVersion = PeekS(*mVersion)
        debugMsgT(sProcName, "TVG Version: " + sVersion)
      EndIf
      grTVGControl\nTVGWorkControlIndex = nTVGIndex
      updateMonitorInfoForTVG()
    EndIf
    
    debugMsg(sProcName, "calling listTVGDirectShowFilters()")
    listTVGDirectShowFilters()
    
    ; nb cannot call loadArrayVideoAudioDevs() or loadArrayVideoCaptureDevs() yet as they depend on info loaded by loadArrayPhysicalDevs()
    
  EndIf ; EndIf nTVGIndex >= 0
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure createTVGControl(pVidPicTarget, pVideoSource=#SCS_VID_SRC_FILE, bAnyThread=#False, nReuseIndex=-1)
  PROCNAMEC()
  Protected nTVGIndex
  Protected nHandle.i, sHandle.s
  Protected nTVGVideoSource.l
  
  debugMsgT(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", pVideoSource=" + decodeVideoSource(pVideoSource) + ", nReuseIndex=" + nReuseIndex)
  
  ; debugMsg0(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  
  ; all TVG controls must be created in the main thread or the program can lock up
  If (gnThreadNo > #SCS_THREAD_MAIN) And (bAnyThread = #False)
    samAddRequest(#SCS_SAM_CREATE_TVG_CONTROL, pVidPicTarget, 0, pVideoSource)
    ProcedureReturn -2  ; -2 indicates control cannot be created because the current thread is not the main thread
  EndIf
  
  Select pVideoSource
    Case #SCS_VID_SRC_CAPTURE
      nTVGVideoSource = #tvc_vs_VideoCaptureDevice
    Default
      nTVGVideoSource = #tvc_vs_VideoFileOrURL
  EndSelect
  
  If nReuseIndex >= 0
    nTVGIndex = nReuseIndex
  Else
    nTVGIndex = grTVGControl\nMaxTVGIndex + 1
    If nTVGIndex > ArraySize(gaTVG())
      REDIM_ARRAY(gaTVG, (nTVGIndex + 10), grTVGDef, "gaTVG()")
      ReDim *gmVideoGrabber(nTVGIndex + 10)
    EndIf
  EndIf
  
  ; debugMsgT(sProcName, "nTVGIndex=" + nTVGIndex + ", ArraySize(gaTVG())=" + ArraySize(gaTVG()) + ", ArraySize(*gmVideoGrabber())=" + ArraySize(*gmVideoGrabber()))
  CheckSubInRange(nTVGIndex, ArraySize(*gmVideoGrabber()), "*gmVideoGrabber()")
  CheckSubInRange(nTVGIndex, ArraySize(gaTVG()), "gaTVG()")
  
  ; debugMsg0(sProcName, "nTVGIndex=" + nTVGIndex + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  *gmVideoGrabber(nTVGIndex) = TVG_CreateVideoGrabber(0)
  newHandle(#SCS_HANDLE_TVG, *gmVideoGrabber(nTVGIndex), #False)
  debugMsgT2(sProcName, "TVG_CreateVideoGrabber(0)", *gmVideoGrabber(nTVGIndex))
  
  If *gmVideoGrabber(nTVGIndex)
    nHandle = *gmVideoGrabber(nTVGIndex)
    sHandle = decodeHandle(nHandle)
    TVG_SetLicenseString(nHandle, @gsTVGLicenseString)
    debugMsgT(sProcName, "TVG_SetLicenseString(" + sHandle + ", @gsTVGLicenseString)")
    TVG_SetCallbackSender(nHandle, nHandle)
    debugMsgT(sProcName, "TVG_SetCallbackSender(" + sHandle + ", " + sHandle + ")")
    
    ; set properties common to all TVG controls in SCS:
    
    If grVideoDriver\nTVGPlayerHwAccel <> #tvc_hw_None
      TVG_SetPlayerHwAccel(nHandle, grVideoDriver\nTVGPlayerHwAccel)
      debugMsgT(sProcName, "TVG_SetPlayerHwAccel(" + sHandle + ", " + decodeTVGPlayerHwAccel(grVideoDriver\nTVGPlayerHwAccel) + ")")
    EndIf
    
    If pVidPicTarget = #SCS_VID_PIC_TARGET_NONE
      ; used for 'work' control only
      TVG_SetOnLog(nHandle, @eventTVGOnLog())
      debugMsgT(sProcName, "TVG_SetOnLog(" + sHandle + ", @eventTVGOnLog())")
      
    Else
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_FRAME_CAPTURE
          If IsGadget(WQA\cntForCaptureFrame)
            TVG_SetParentWindow(nHandle, GadgetID(WQA\cntForCaptureFrame))
            debugMsgT(sProcName, "TVG_SetParentWindow(" + sHandle + ", GadgetID(WQA\cntForCaptureFrame))")
          EndIf
          
;         Case #SCS_VID_PIC_TARGET_TEST
          ; leave display embedded
          
        Default
          ; eg #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          ; detach control
          TVG_SetDisplayEmbedded(nHandle, 0, #tvc_false)
          debugMsgT(sProcName, "TVG_SetDisplayEmbedded(" + sHandle + ", 0, #tvc_false)")
          TVG_SetDisplayStayOnTop(nHandle, 0, #tvc_false)
          debugMsgT(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", 0, #tvc_false)")
          
          ; enable alpha-blend
          TVG_SetDisplayAlphaBlendEnabled(nHandle, 0, #tvc_true)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendEnabled(" + sHandle + ", 0, #tvc_true)")
          
          If TVG_GetFrameGrabber(nHandle) <> #tvc_fg_Disabled
            ; debugMsg(sProcName, "TVG_GetFrameGrabber(" + sHandle + ")=" + TVG_GetFrameGrabber(nHandle))
            TVG_SetFrameGrabber(nHandle, #tvc_fg_Disabled)
            debugMsgT(sProcName, "TVG_SetFrameGrabber(" + sHandle + ", #tvc_fg_Disabled)")
          EndIf
          
      EndSelect
      
      TVG_SetDisplayMouseMovesWindow(nHandle, 0, #tvc_false)
      debugMsgT(sProcName, "TVG_SetDisplayMouseMovesWindow(" + sHandle + ", 0, #tvc_false)")
      
      ; register event callbacks
      TVG_SetOnInactive(nHandle, @eventTVGOnInactive())
      debugMsgT(sProcName, "TVG_SetOnInactive(" + sHandle + ", @eventTVGOnInactive())")
      
      TVG_SetOnLastCommandCompleted(nHandle, @eventTVGOnLastCommandCompleted())
      debugMsgT(sProcName, "TVG_SetOnLastCommandCompleted(" + sHandle + ", @eventTVGOnLastCommandCompleted())")
      
      TVG_SetOnLog(nHandle, @eventTVGOnLog())
      debugMsgT(sProcName, "TVG_SetOnLog(" + sHandle + ", @eventTVGOnLog())")
      
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
          TVG_SetTranslateMouseCoordinates(nHandle, #tvc_false)
          debugMsgT(sProcName, "TVG_SetTranslateMouseCoordinates(" + sHandle + ", #tvc_false)")
          TVG_SetOnMouseDown(nHandle, @eventTVGOnMouseDown())
          debugMsgT(sProcName, "TVG_SetOnMouseDown(" + sHandle + ", @eventTVGOnMouseDown())")
          TVG_SetOnMouseMove(nHandle, @eventTVGOnMouseMove())
          debugMsgT(sProcName, "TVG_SetOnMouseMove(" + sHandle + ", @eventTVGOnMouseMove())")
          TVG_SetOnMouseUp(nHandle, @eventTVGOnMouseUp())
          debugMsgT(sProcName, "TVG_SetOnMouseUp(" + sHandle + ", @eventTVGOnMouseUp())")
      EndSelect
      
      TVG_SetVideoSource(nHandle, nTVGVideoSource)
      debugMsgT(sProcName, "TVG_SetVideoSource(" + sHandle + ", " + decodeTVGVideoSource(nTVGVideoSource) + ")")
      
      Select pVideoSource
        Case #SCS_VID_SRC_FILE
          TVG_SetOnPlayerEndOfStream(nHandle, @eventTVGOnPlayerEndOfStream())
          debugMsgT(sProcName, "TVG_SetOnPlayerEndOfStream(" + sHandle + ", @eventTVGOnPlayerEndOfStream())")
          
          TVG_SetOnPlayerOpened(nHandle, @eventTVGOnPlayerOpened())
          debugMsgT(sProcName, "TVG_SetOnPlayerOpened(" + sHandle + ", @eventTVGOnPlayerOpened())")
          
          TVG_SetOnPlayerStateChanged(nHandle, @eventTVGOnPlayerStateChanged())
          debugMsgT(sProcName, "TVG_SetOnPlayerStateChanged(" + sHandle + ", @eventTVGOnPlayerStateChanged())")
          
          If grVideoDriver\bTVGDisplayVUMeters
            TVG_SetOnAudioPeak(nHandle, @eventTVGOnAudioPeak())
            debugMsgT(sProcName, "TVG_SetOnAudioPeak(" + sHandle + ", @eventTVGOnAudioPeak())")
          EndIf
          
      EndSelect
      
      TVG_SetOnReinitializing(nHandle, @eventTVGOnReinitializing())
      debugMsgT(sProcName, "TVG_SetOnReinitializing(" + sHandle + ", @eventTVGOnReinitializing())")
      
      TVG_SetOnVideoDeviceSelected(nHandle, @eventTVGOnVideoDeviceSelected())
      debugMsgT(sProcName, "TVG_SetOnVideoDeviceSelected(" + sHandle + ", @eventTVGOnVideoDeviceSelected())")
      
      CompilerIf #c_tvg_onrawaudiosample
        TVG_SetOnRawAudioSample(nHandle, @eventTVGOnRawAudioSample())
        debugMsgT(sProcName, "TVG_SetOnRawAudioSample(" + sHandle + ", @eventTVGOnRawAudioSample())")
        TVG_SetRawAudioSampleCapture(nHandle, #tvc_true)
        debugMsgT(sProcName, "TVG_SetRawAudioSampleCapture(" + sHandle + ", #tvc_true)")
      CompilerEndIf
      
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          grVideoDriver\bTVGControlForSecondaryScreenCreated = #True
      EndSelect
      
    EndIf ; End Else (If pVidPicTarget = #SCS_VID_PIC_TARGET_NONE)
  
  EndIf ; EndIf nHandle
  
  gaTVG(nTVGIndex)\nTVGVidPicTarget = pVidPicTarget
  gaTVG(nTVGIndex)\nTVGVideoSource = pVideoSource
  If nTVGIndex > grTVGControl\nMaxTVGIndex ; Test added 16Apr2020 11.8.2.3av
    grTVGControl\nMaxTVGIndex = nTVGIndex
    debugMsg(sProcName, "grTVGControl\nMaxTVGIndex=" + grTVGControl\nMaxTVGIndex)
  EndIf
  
  debugMsgT(sProcName, #SCS_END + ", returning " + nTVGIndex)
  ProcedureReturn nTVGIndex
  
EndProcedure

Procedure setTVGCommonDisplayProperties(nTVGIndex, nDisplayIndex.l)
  PROCNAMEC()
  Protected nHandle.i, sHandle.s
  Protected nAudPtr
  
  nHandle = *gmVideoGrabber(nTVGIndex)
  If nHandle
    sHandle = decodeHandle(nHandle)
    nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
    
    ; added 13Feb2020 11.8.2.2al
    TVG_SetDisplayActive(nHandle, nDisplayIndex, #tvc_false)
    debugMsgT(sProcName, "TVG_SetDisplayActive(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
    ; end added 13Feb2020 11.8.2.2al
    
    ; detach control
    TVG_SetDisplayEmbedded(nHandle, nDisplayIndex, #tvc_false)
    debugMsgT(sProcName, "TVG_SetDisplayEmbedded(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
    TVG_SetDisplayStayOnTop(nHandle, nDisplayIndex, #tvc_false)
    debugMsgT(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
    ; enable alpha-blend
    TVG_SetDisplayAlphaBlendEnabled(nHandle, nDisplayIndex, #tvc_true)
    debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendEnabled(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
    TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
    debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
    TVG_SetDisplayMouseMovesWindow(nHandle, nDisplayIndex, #tvc_false)
    debugMsgT(sProcName, "TVG_SetDisplayMouseMovesWindow(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
    If nAudPtr >= 0
      With aAud(nAudPtr)
        Select \nAspectRatioType
          Case #SCS_ART_FULL
            TVG_SetDisplayAspectRatio(nHandle, nDisplayIndex, #tvc_ar_Stretch)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", " + nDisplayIndex + ", #tvc_ar_Stretch)")
          Default
            TVG_SetDisplayAspectRatio(nHandle, nDisplayIndex, #tvc_ar_Box)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", " + nDisplayIndex + ", #tvc_ar_Box)")
        EndSelect
      EndWith
    EndIf
    
    ; set display active must be called AFTER setting all of the above, especially AFTER setting alpha blend = 0
    TVG_SetDisplayActive(nHandle, nDisplayIndex, #tvc_true)
    debugMsgT(sProcName, "TVG_SetDisplayActive(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
    
  EndIf
  
EndProcedure

Procedure setTVGDualDisplay(nTVGIndex, bDualDisplay)
  PROCNAMEC()
  Protected nHandle.i, sHandle.s
  
  debugMsg(sProcName, #SCS_START + ", nTVGIndex=" + nTVGIndex + ", bDualDisplay=" + strB(bDualDisplay) + ", gaTVG(" + nTVGIndex + ")\bDualDisplayActive=" + strB(gaTVG(nTVGIndex)\bDualDisplayActive))
  
  nHandle = *gmVideoGrabber(nTVGIndex)
  If nHandle
    sHandle = decodeHandle(nHandle)
    If bDualDisplay
      setTVGCommonDisplayProperties(nTVGIndex, 1)
      gaTVG(nTVGIndex)\bDualDisplayActive = #True
    Else
      TVG_SetDisplayActive(nHandle, 1, #tvc_false)
      debugMsgT(sProcName, "TVG_SetDisplayActive(" + sHandle + ", 1, #tvc_false)")
      gaTVG(nTVGIndex)\bDualDisplayActive = #False
    EndIf
  EndIf
  
EndProcedure

Procedure destroyAllTVGControls()
  PROCNAMEC()
  Protected nTVGIndex
  
  debugMsgT(sProcName, #SCS_START + ", grTVGControl\nMaxTVGIndex=" + grTVGControl\nMaxTVGIndex)
  
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
;      debugMsgT(sProcName, decodeHandle(*gmVideoGrabber(nTVGIndex)) + "=" + *gmVideoGrabber(nTVGIndex))
    If *gmVideoGrabber(nTVGIndex)
      debugMsgT(sProcName, "calling TVG_DestroyVideoGrabber(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
      TVG_DestroyVideoGrabber(*gmVideoGrabber(nTVGIndex))
      debugMsgT(sProcName, "TVG_DestroyVideoGrabber(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
      *gmVideoGrabber(nTVGIndex) = 0
    EndIf
  Next nTVGIndex
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure assignProdTestVidCapTVGControl(pVidPicTarget)
  PROCNAMEC()
  Protected n, nTVGIndex = -1
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To grTVGControl\nMaxTVGIndex
    If gaTVG(n)\nTVGVidPicTarget = pVidPicTarget
      If gaTVG(n)\bProdTestVidCap
        nTVGIndex = n
        Break
      EndIf
    EndIf
  Next n
  
  If nTVGIndex = -1
    nTVGIndex = createTVGControl(pVidPicTarget, #tvc_vs_VideoCaptureDevice)
      ; nb if createTVGControl returns -2 this indicates the current thread is not the main thread
  EndIf
  
  If nTVGIndex >= 0
    If *gmVideoGrabber(nTVGIndex)
      gaTVG(nTVGIndex)\bProdTestVidCap = #True
      gaTVG(nTVGIndex)\nTVGVidPicTarget = pVidPicTarget
    EndIf
  EndIf
  
EndProcedure

Procedure assignTVGControl(pSubPtr, pAudPtr, pVidPicTarget)
  PROCNAMECS(pSubPtr)
  Protected n, nTVGIndex = -1
  Protected bDualDisplay
  Protected nWindowIndex, nMainWindowNo, nMonitorWindowNo
  Protected nWindowNo, nOutputScreenNo, nDisplayIndex.l
  
  debugMsgT(sProcName, #SCS_START + ", pSubPtr=" + getSubLabel(pSubPtr) + ", pAudPtr=" + getAudLabel(pAudPtr) + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If pSubPtr >= 0
    
    ; Added 28Nov2022 11.9.7ap
    If pVidPicTarget = #SCS_VID_PIC_TARGET_P
      For n = 0 To grTVGControl\nMaxTVGIndex
        debugMsg(sProcName, "gaTVG(" + n + ")\nTVGVidPicTarget=" + gaTVG(n)\nTVGVidPicTarget + ", \bAssigned=" + strB(gaTVG(n)\bAssigned))
        If gaTVG(n)\nTVGVidPicTarget = #SCS_VID_PIC_TARGET_P And gaTVG(n)\bAssigned
          debugMsg(sProcName, "calling freeTVGControl(" + n + ", #True)")
          freeTVGControl(n, #True)
          Break
        EndIf
      Next n
    EndIf
    ; End added 28Nov2022 11.9.7ap
    
    For n = 0 To grTVGControl\nMaxTVGIndex
      If gaTVG(n)\nTVGVidPicTarget = pVidPicTarget
        If gaTVG(n)\bProdTestVidCap = #False
          If gaTVG(n)\bAssigned = #False
            nTVGIndex = n
            Break
          EndIf
          If (gaTVG(n)\nTVGSubPtr = pSubPtr) And (gaTVG(n)\nTVGAudPtr = pAudPtr)
            nTVGIndex = n
            ; added 19Jul2018 11.7.1.1ab following problem reported by Eric Snodgrass
            ; found a gaTVG() instance that is already assigned to this Sub and Aud, so cancel any existing SAM request that would free this instance
            samCancelRequest(#SCS_SAM_FREE_TVG_CONTROL, n)
            ; now 'break' to continue with the assignmment
            ; end added 19Jul2018 11.7.1.1ab
            Break
          EndIf
          If (gaTVG(n)\nTVGSubPtr = grTVGDef\nTVGSubPtr) And (gaTVG(n)\nTVGAudPtr = grTVGDef\nTVGAudPtr)
            nTVGIndex = n
            Break
          EndIf
        EndIf
      EndIf
    Next n
    
    If nTVGIndex = -1
      debugMsg(sProcName, "calling createTVGControl(" + decodeVidPicTarget(pVidPicTarget) + ")")
      nTVGIndex = createTVGControl(pVidPicTarget)
      ; nb if createTVGControl returns -2 this indicates the current thread is not the required thread
    ElseIf nTVGIndex >= 0
      If *gmVideoGrabber(nTVGIndex) = 0
        debugMsg(sProcName, "calling createTVGControl(" + decodeVidPicTarget(pVidPicTarget) + ", #SCS_VID_SRC_FILE, #False, " + nTVGIndex + ")")
        nTVGIndex = createTVGControl(pVidPicTarget, #SCS_VID_SRC_FILE, #False, nTVGIndex)
      EndIf
    EndIf
    debugMsg(sProcName, "nTVGIndex=" + nTVGIndex)
    
    If nTVGIndex >= 0
      If *gmVideoGrabber(nTVGIndex)
        With gaTVG(nTVGIndex)
          \bAssigned = #True
          \nTVGSubPtr = pSubPtr
          \nTVGAudPtr = pAudPtr
          If pAudPtr >= 0
            \nTVGVideoSource = aAud(pAudPtr)\nVideoSource
          Else
            \nTVGVideoSource = #SCS_VID_SRC_FILE
          EndIf
          debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\bAssigned=" + strB(\bAssigned) + ", handle=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) +
                              ", \nTVGSubPtr=" + getSubLabel(\nTVGSubPtr) + ", \nTVGAudPtr=" + getAudLabel(\nTVGAudPtr) + ", \nTVGVideoSource=" + decodeVideoSource(\nTVGVideoSource))
          \nTVGVidPicTarget = pVidPicTarget
          \bClosePlayerRequested = #False
          \bCloseWhenTVGNotPlaying = #False
          For nDisplayIndex = 2 To 8
            \bDisplayIndexUsed(nDisplayIndex) = #False
            \nWindowForDisplayIndex(nDisplayIndex) = 0
          Next nDisplayIndex
          Select pVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              nWindowIndex = pVidPicTarget - #SCS_VID_PIC_TARGET_F2
              nMainWindowNo = #WV2 + nWindowIndex
              If IsWindow(nMainWindowNo)
                \nMainWindowNo = nMainWindowNo
              EndIf
              If grOperModeOptions(gnOperMode)\nMonitorSize <> #SCS_MON_NONE
                nMonitorWindowNo = #WM2 + nWindowIndex
                debugMsgT(sProcName, "nMonitorWindowNo=" + decodeWindow(nMonitorWindowNo) + ", IsWindow(" + decodeWindow(nMonitorWindowNo) + ")=" + IsWindow(nMonitorWindowNo))
                If IsWindow(nMonitorWindowNo)
                  \nMonitorWindowNo = nMonitorWindowNo
                  debugMsgT(sProcName, "gaTVG(" + nTVGIndex + ")\nMonitorWindowNo=" + decodeWindow(\nMonitorWindowNo))
                  bDualDisplay = #True
                EndIf
              EndIf
              nDisplayIndex = 2 ; Added 28May2020 11.8.3rc5
              For nWindowNo = #WV3 To grLicInfo\nLastVideoWindowNo
                ; debugMsg(sProcName, "nWindowNo=" + decodeWindow(nWindowNo))
                If nWindowNo <> nMainWindowNo
                  nOutputScreenNo = nWindowNo - #WV3 + 3
                  ; nDisplayIndex = nOutputScreenNo - 1 ; display index is 0-based ; Deleted 28May2020 11.8.3rc5
                  If aSub(pSubPtr)\bOutputScreenReqd(nOutputScreenNo)
                    debugMsg(sProcName, "nOutputScreenNo=" + nOutputScreenNo + ", nDisplayIndex=" + nDisplayIndex + ", aSub(" + getSubLabel(pSubPtr) + ")\bOutputScreenReqd(" + nOutputScreenNo + ")=" + strB(aSub(pSubPtr)\bOutputScreenReqd(nOutputScreenNo)))
                    \bDisplayIndexUsed(nDisplayIndex) = #True
                    \nWindowForDisplayIndex(nDisplayIndex) = nWindowNo
                    debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\bDisplayIndexUsed(" + nDisplayIndex + ")=" + strB(\bDisplayIndexUsed(nDisplayIndex)))
                    nDisplayIndex + 1 ; Added 28May2020 11.8.3rc5
                  EndIf
                EndIf
              Next nWindowNo
              
            Case #SCS_VID_PIC_TARGET_P
              debugMsg(sProcName, "gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo)
              If gnPreviewOnOutputScreenNo > 0
                bDualDisplay = #True
              EndIf
              
          EndSelect
          debugMsg(sProcName, "calling setTVGDualDisplay(" + nTVGIndex + ", " + strB(bDualDisplay) + ")")
          setTVGDualDisplay(nTVGIndex, bDualDisplay)
          debugMsg(sProcName, "calling setTVG3PlusDisplays(" + nTVGIndex + ")")
          setTVG3PlusDisplays(nTVGIndex)
          
        EndWith
      EndIf ; EndIf *gmVideoGrabber(nTVGIndex)
    EndIf ; EndIf nTVGIndex >= 0
    
  EndIf ; EndIf pSubPtr >= 0
  
  debugMsgT(sProcName, #SCS_END + ", returning " + nTVGIndex)
  ProcedureReturn nTVGIndex
  
EndProcedure

Procedure setTVGDisplayLocation(nTVGIndex)
  ; nb nTVGIndex points to *gmVideoGrabber(nTVGIndex) and also gaTVG(nTVGIndex)
  Protected sProcName.s
  ; PROCNAMEC() ; see also code at start of this procudure
  
  ; IMPORTANT INFORMATION
  ; Some of the information about TVideoGrabber (TVG) is unclear and not well documented in the Help.
  ; Also, Datastead support is abysmal. If Michel of Datastead can give you a simple answer he will, but usually I hear nothing back from my enquiries.
  ; The relevance here is that the timing of setting the display location (eg calling TVG_SetDisplayLocation()) is not clear. Sometimes this needs to be
  ; called BEFORE calling TVG_OpenPlayer(), but sometimes it seems it needs to be called AFTER calling TVG_OpenPlayer() but before calling TVG_RunPlayer().
  ; To be 'safe'(!), SCS now calls this Procedure (setTVGDisplayLocation()) both BEFORE AND AFTER calling TVG_Open_Player().
  
  Protected nAudPtr, nSubPtr
  Protected nVidPicTarget, nVidPicTargetForOutputScreen
  Protected bUseTVGCropping
  Protected nHandle.i, sHandle.s
  Protected qPlayerFramePosition.q, dCroppingZoom.d = 1.0, dAspectRatioToUse.d
  Protected nLongResult.l, bPreviewPlaying
  ; for nVidPicTarget = #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
  Protected nMainLeft.l, nMainTop.l, nMainWidth.l, nMainHeight.l
  Protected bSetMainLocation, bSetFullScreen, bShareScreen
  Protected nMonitorLeft.l, nMonitorTop.l, nMonitorWidth.l, nMonitorHeight.l
  Protected bSetMonitorLocation
  Protected bTVGCropping
  Protected nDisplayIndex.l
  Protected nDisplayLeft.l, nDisplayTop.l, nDisplayWidth.l, nDisplayHeight.l
  ; for nVidPicTarget = #SCS_VID_PIC_TARGET_P
  Protected nPreviewCanvasLeft, nPreviewCanvasTop, nPreviewCanvasWidth, nPreviewCanvasHeight
  Protected nPreviewLeft, nPreviewTop, nPreviewWidth, nPreviewHeight
  Protected bSetPreviewLocation
  Protected nOutputLeft, nOutputTop, nOutputWidth, nOutputHeight
  Protected bSetOutputLocation
  ;
  Protected nMainWindowNo, nMainCanvasNo, nMonitorWindowNo, nMonitorCanvasNo
  Protected nWindowIndex, nMonitorIndex
  Protected nPreviewCanvas
  Protected nOutputScreen, nOutputWindowNo, nTVGMonitor
  Protected sScreens.s, nScreenIndex, nScreenCount
  Protected bUsingMemoryImage
  Protected bSwap0and1, nPreviewDisplayIndex.l, nOutputDisplayIndex.l
  ;
  Static b100PerCentWarningDisplayed
  Protected sWarningMessage.s
  
  ; nb #SCS_START debug call further down this procedure after setting nSubPtr and nAudPtr if required
  
  With gaTVG(nTVGIndex)
    nVidPicTarget = \nTVGVidPicTarget
    Select nVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P ; Mod 19Oct2020 11.8.3.2bx - added #SCS_VID_PIC_TARGET_P to this part of the Select
        nSubPtr = \nTVGSubPtr
        nAudPtr = \nTVGAudPtr
      Case #SCS_VID_PIC_TARGET_FRAME_CAPTURE ; Mod 19Oct2020 11.8.3.2bx - removed #SCS_VID_PIC_TARGET_P from this part of the Select
        nSubPtr = nEditSubPtr
        nAudPtr = nEditAudPtr
    EndSelect
    If nAudPtr >= 0
      sProcName = buildAudProcName(#PB_Compiler_Procedure, nAudPtr)
    ElseIf nSubPtr >= 0
      sProcName = buildSubProcName(#PB_Compiler_Procedure, nSubPtr)
    Else
      sProcName = #PB_Compiler_Procedure + "[" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + "]"
    EndIf
    debugMsgT(sProcName, #SCS_START)
    
    debugMsgT(sProcName, "nVidPicTarget=" + decodeVidPicTarget(nVidPicTarget) + ", nSubPtr=" + getSubLabel(nSubPtr) + ", nAudPtr=" + getAudLabel(nAudPtr))
    debugMsg(sProcName, "\nTVGSubPtr=" + getSubLabel(\nTVGSubPtr) + ", \nTVGAudPtr=" + getAudLabel(\nTVGAudPtr))
    
    If nAudPtr >= 0
      bUsingMemoryImage = aAud(nAudPtr)\bUsingMemoryImage
      debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nSourceWidth=" + aAud(nAudPtr)\nSourceWidth + ", \nSourceHeight=" + aAud(nAudPtr)\nSourceHeight +
                          ", \bUsingMemoryImage=" + strB(aAud(nAudPtr)\bUsingMemoryImage))
    EndIf
    
    nHandle = *gmVideoGrabber(nTVGIndex)
    If nHandle
      sHandle = decodeHandle(nHandle)
      
      If nAudPtr >= 0
        If aAud(nAudPtr)\nVideoSource = #SCS_VID_SRC_CAPTURE
          If (aAud(nAudPtr)\nAudState >= #SCS_CUE_FADING_IN) And (aAud(nAudPtr)\nAudState <= #SCS_CUE_FADING_OUT)
            bPreviewPlaying = #True
          EndIf
        EndIf
      EndIf
      
      Select nVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          bShareScreen = grVidPicTarget(nVidPicTarget)\bShareScreen
          ; debugMsg0(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShareScreen=" + strB(grVidPicTarget(nVidPicTarget)\bShareScreen))
          nWindowIndex = nVidPicTarget - #SCS_VID_PIC_TARGET_F2
          nMainWindowNo = #WV2 + nWindowIndex
          nMonitorWindowNo = #WM2 + nWindowIndex
          If IsWindow(nMainWindowNo)
            \nMainWindowNo = nMainWindowNo
            nMainCanvasNo = WVN(nWindowIndex)\cntMainPicture
            debugMsgT(sProcName, "nMainWindowNo=" + decodeWindow(nMainWindowNo) + ", IsWindow(" + decodeWindow(nMainWindowNo) + ")=" + IsWindow(nMainWindowNo) + ", IsGadget(nMainCanvasNo)=" + IsGadget(nMainCanvasNo))
            If IsGadget(nMainCanvasNo)
              ; Added 17May2020 11.8.3rc6
              If gbVideosOnMainWindow
                nMainLeft = GadgetX(nMainCanvasNo, #PB_Gadget_ScreenCoordinate)
                nMainTop = GadgetY(nMainCanvasNo, #PB_Gadget_ScreenCoordinate)
                nMainWidth = GadgetWidth(nMainCanvasNo)
                nMainHeight = GadgetHeight(nMainCanvasNo)
              Else
                ; End added 17May2020 11.8.3rc6
                nMainLeft = grVidPicTarget(nVidPicTarget)\nMainWindowXWithinDisplayMonitor
                nMainTop = grVidPicTarget(nVidPicTarget)\nMainWindowYWithinDisplayMonitor
                ; debugMsg0(sProcName, "nMainLeft=" + nMainLeft + ", nMainTop=" + nMainTop)
                If nMainLeft = 0 And nMainTop = 0 And bShareScreen = #False ; Added bShareScreen test 18Oct2023 11.10.0cl following email from Paul (White Water Media) 13Oct2023
                  nMainWidth = grVidPicTarget(nVidPicTarget)\nDesktopWidth
                  nMainHeight = grVidPicTarget(nVidPicTarget)\nDesktopHeight
                Else
                  nMainWidth = grVidPicTarget(nVidPicTarget)\nMainWindowWidth
                  nMainHeight = grVidPicTarget(nVidPicTarget)\nMainWindowHeight
                EndIf
              EndIf
              debugMsg(sProcName, "nMainWindowNo=" + decodeWindow(nMainWindowNo) + ", nMainLeft=" + nMainLeft + ", nMainTop=" + nMainTop + ", nMainWidth=" + nMainWidth + ", nMainHeight=" + nMainHeight)
              If IsWindow(nMonitorWindowNo)
                \nMonitorWindowNo = nMonitorWindowNo
                nMonitorIndex = getIndexForMonitorWindowNo(nMonitorWindowNo)
                nMonitorCanvasNo = WMO(nMonitorIndex)\cntMonitor
                If IsGadget(nMonitorCanvasNo)
                  ; nMonitorLeft = GadgetX(nMonitorCanvasNo, #PB_Gadget_ScreenCoordinate)
                  ; nMonitorTop = GadgetY(nMonitorCanvasNo, #PB_Gadget_ScreenCoordinate)
                  nMonitorWidth = GadgetWidth(nMonitorCanvasNo)
                  nMonitorHeight = GadgetHeight(nMonitorCanvasNo)
                  nMonitorLeft = adjustLeftIfNecessary(nHandle, GadgetX(nMonitorCanvasNo, #PB_Gadget_ScreenCoordinate))
                  nMonitorTop = adjustTopIfNecessary(nHandle, GadgetY(nMonitorCanvasNo, #PB_Gadget_ScreenCoordinate))
                EndIf
              EndIf
              If (nAudPtr >= 0) And (bUsingMemoryImage = #False)
                debugMsg(sProcName, "(a main) calling calcDisplayPosAndSize3(" + getAudLabel(nAudPtr) + ", " + aAud(nAudPtr)\nSourceWidth + ", " + aAud(nAudPtr)\nSourceHeight + ", " +
                                    nMainWidth + ", " + nMainHeight + ", " + nMonitorWidth + ", " + nMonitorHeight + ")")
                calcDisplayPosAndSize3(nAudPtr, aAud(nAudPtr)\nSourceWidth, aAud(nAudPtr)\nSourceHeight, nMainWidth, nMainHeight, nMonitorWidth, nMonitorHeight)
                nMainLeft + grDPS\nDisplayLeft
                nMainTop + grDPS\nDisplayTop
                nMainWidth = grDPS\nDisplayWidth
                nMainHeight = grDPS\nDisplayHeight
                nMonitorLeft + grDPS\nDisplay2Left
                nMonitorTop + grDPS\nDisplay2Top
                nMonitorWidth = grDPS\nDisplay2Width
                nMonitorHeight = grDPS\nDisplay2Height
                dAspectRatioToUse = grDPS\dAspectRatioToUse
                debugMsg(sProcName, "nMainLeft=" + nMainLeft + ", nMainTop=" + nMainTop + ", nMainWidth=" + nMainWidth + ", nMainHeight=" + nMainHeight +
                                    ", nMonitorLeft=" + nMonitorLeft + ", nMonitorTop=" + nMonitorTop + ", nMonitorWidth=" + nMonitorWidth + ", nMonitorHeight=" + nMonitorHeight +
                                    ", dAspectRatioToUse=" + StrD(dAspectRatioToUse,4))
                \nMainRelLeft = grDPS\nDisplayLeft      ; relative display left (ie left within the container)
                \nMainRelTop = grDPS\nDisplayTop        ; relative display top (ie top within the container)
                \nMainRelWidth = grDPS\nDisplayWidth    ; display width
                \nMainRelHeight = grDPS\nDisplayHeight  ; display height
                debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nMainRelLeft=" + \nMainRelLeft + ", \nMainRelTop=" + \nMainRelTop + ", \nMainRelWidth=" + \nMainRelWidth + ", \nMainRelHeight=" + \nMainRelHeight)
              EndIf
              bSetMainLocation = #True
              If IsWindow(nMonitorWindowNo)
                bSetMonitorLocation = #True
              EndIf
            EndIf
          EndIf
          debugMsg(sProcName, "bSetMonitorLocation=" + strB(bSetMonitorLocation) + ", gaTVG(" + nTVGIndex + ")\bDualDisplayActive=" + strB(\bDualDisplayActive))
          If bSetMonitorLocation
            If \bDualDisplayActive = #False
              debugMsg(sProcName, "calling setTVGDualDisplay(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #True)")
              setTVGDualDisplay(nTVGIndex, #True)
            EndIf
          Else
            If \bDualDisplayActive
              debugMsg(sProcName, "calling setTVGDualDisplay(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #False)")
              setTVGDualDisplay(nTVGIndex, #False)
            EndIf
          EndIf
          
        Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_FRAME_CAPTURE
          nPreviewCanvas = WQA\cvsPreview
          nPreviewDisplayIndex = 0
          nOutputDisplayIndex = 1
          If gnPreviewOnOutputScreenNo
            If nSubPtr >= 0
              nOutputScreen = aSub(nSubPtr)\nOutputScreen
              nOutputWindowNo = #WV2 + (nOutputScreen - 2)
              bSwap0and1 = #True
              nPreviewDisplayIndex = 1
              nOutputDisplayIndex = 0
            EndIf
          EndIf
          If IsGadget(nPreviewCanvas)
            nPreviewCanvasLeft = GadgetX(nPreviewCanvas, #PB_Gadget_ScreenCoordinate)
            nPreviewCanvasTop = GadgetY(nPreviewCanvas, #PB_Gadget_ScreenCoordinate)
            nPreviewCanvasWidth = GadgetWidth(nPreviewCanvas)
            nPreviewCanvasHeight = GadgetHeight(nPreviewCanvas)
            debugMsg(sProcName, "(preview screen coordinates) nPreviewLeft=" + nPreviewLeft + ", nPreviewTop=" + nPreviewTop + ", nPreviewWidth=" + nPreviewWidth + ", nPreviewHeight=" + nPreviewHeight)
            If IsWindow(nOutputWindowNo)
              nVidPicTargetForOutputScreen = getVidPicTargetForOutputScreen(nOutputScreen)
              debugMsg(sProcName, "nVidPicTargetForOutputScreen=" + decodeVidPicTarget(nVidPicTargetForOutputScreen))
              nOutputLeft = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowXWithinDisplayMonitor
              nOutputTop = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowYWithinDisplayMonitor
              If nOutputLeft = 0 And nOutputTop = 0
                nOutputWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopWidth
                nOutputHeight = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopHeight
              Else
                nOutputWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth
                nOutputHeight = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowHeight
              EndIf
            EndIf
            If nAudPtr >= 0
              If bUsingMemoryImage = #False
                nPreviewLeft = nPreviewCanvasLeft
                nPreviewTop = nPreviewCanvasTop
                nPreviewWidth = nPreviewCanvasWidth
                nPreviewHeight = nPreviewCanvasHeight
                debugMsg(sProcName, "(c preview) calling calcDisplayPosAndSize3(" + getAudLabel(nAudPtr) + ", " + aAud(nAudPtr)\nSourceWidth + ", " + aAud(nAudPtr)\nSourceHeight +
                                    ", " + nPreviewWidth + ", " + nPreviewHeight + ", " + nOutputWidth + ", " + nOutputHeight + ")")
                calcDisplayPosAndSize3(nAudPtr, aAud(nAudPtr)\nSourceWidth, aAud(nAudPtr)\nSourceHeight, nPreviewWidth, nPreviewHeight, nOutputWidth, nOutputHeight)
                nPreviewLeft + grDPS\nDisplayLeft
                nPreviewTop + grDPS\nDisplayTop
                nPreviewWidth = grDPS\nDisplayWidth
                nPreviewHeight = grDPS\nDisplayHeight
                nOutputLeft + grDPS\nDisplay2Left
                nOutputTop + grDPS\nDisplay2Top
                nOutputWidth = grDPS\nDisplay2Width
                nOutputHeight = grDPS\nDisplay2Height
                dAspectRatioToUse = grDPS\dAspectRatioToUse
                
              Else ; bUsingMemoryImage (= #True)
                ; Added 20Oct2020 11.8.3.2by
                nPreviewLeft = nPreviewCanvasLeft
                nPreviewTop = nPreviewCanvasTop
                nPreviewWidth = nPreviewCanvasWidth
                nPreviewHeight = nPreviewCanvasHeight
                dAspectRatioToUse = ImageWidth(aAud(nAudPtr)\nMemoryImageNo) / ImageHeight(aAud(nAudPtr)\nMemoryImageNo)
                debugMsg(sProcName, "ImageWidth(aAud(" + getAudLabel(nAudPtr) + ")\nMemoryImageNo)=" + ImageWidth(aAud(nAudPtr)\nMemoryImageNo) + ", ImageHeight(aAud(" + getAudLabel(nAudPtr) + ")\nMemoryImageNo)=" + ImageHeight(aAud(nAudPtr)\nMemoryImageNo))
                ; End added 20Oct2020 11.8.3.2by
                
              EndIf
              debugMsg(sProcName, "nPreviewLeft=" + nPreviewLeft + ", nPreviewTop=" + nPreviewTop + ", nPreviewWidth=" + nPreviewWidth + ", nPreviewHeight=" + nPreviewHeight +
                                  ", nOutputLeft=" + nOutputLeft + ", nOutputTop=" + nOutputTop + ", nOutputWidth=" + nOutputWidth + ", nOutputHeight=" + nOutputHeight +
                                  ", dAspectRatioToUse=" + StrD(dAspectRatioToUse,4))
            EndIf
            
            bSetPreviewLocation = #True
            If IsWindow(nOutputWindowNo)
              bSetOutputLocation = #True
            EndIf
          EndIf
          debugMsg(sProcName, "gnPreviewOnOutputScreenNo=" + gnPreviewOnOutputScreenNo + ", nOutputScreen=" + nOutputScreen +
                              ", nOutputWindowNo=" + decodeWindow(nOutputWindowNo) + ", IsWindow(nOutputWindowNo)=" + IsWindow(nOutputWindowNo) +
                              ", nOutputLeft=" + nOutputLeft + ", bSetOutputLocation=" + strB(bSetOutputLocation))
          If gnPreviewOnOutputScreenNo
            If \bDualDisplayActive = #False
              debugMsg(sProcName, "calling setTVGDualDisplay(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #True)")
              setTVGDualDisplay(nTVGIndex, #True)
            EndIf
          Else
            If \bDualDisplayActive
              debugMsg(sProcName, "calling setTVGDualDisplay(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #False)")
              setTVGDualDisplay(nTVGIndex, #False)
            EndIf
          EndIf
          
      EndSelect
      
      ; added 14/02/2025 by Dee as a feature request, Pete Barnes, 29Aug2024, this only works when pause at end is selected, otherwise the player will be stopped and the
      ; tvg_videograbber instance is destroyed in freeTVGControl()
      If aSub(nSubPtr)\bPauseAtEnd <> #False
        TVG_SetVideoVisibleWhenStopped(nHandle, #True)
        debugMsgT(sProcName, "TVG_SetVideoVisibleWhenStopped(" + sHandle + ", #True)")
      Else
        TVG_SetVideoVisibleWhenStopped(nHandle, #False)
        debugMsgT(sProcName, "TVG_SetVideoVisibleWhenStopped(" + sHandle + ", #False)")
      EndIf
      
      debugMsgT(sProcName, "bSetMainLocation=" + strB(bSetMainLocation) + ", bSetMonitorLocation=" + strB(bSetMonitorLocation) + ", bSetPreviewLocation=" + strB(bSetPreviewLocation) + ", bSetOutputLocation=" + strB(bSetOutputLocation))
      If bSetMainLocation Or bSetMonitorLocation Or bSetPreviewLocation Or bSetOutputLocation
        bTVGCropping = #False
        If bUsingMemoryImage
          If TVG_GetCropping_Enabled(nHandle)
            TVG_SetCropping_Enabled(nHandle, #tvc_false)
            debugMsgT(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_false)")
          EndIf
        Else
          If TVG_GetCropping_Enabled(nHandle)
            bTVGCropping = #True
          EndIf
          If aAud(nAudPtr)\bTVGCropping <> bTVGCropping
            If aAud(nAudPtr)\bTVGCropping
              If bPreviewPlaying
                nLongResult = TVG_StopPreview(nHandle)
                debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ") returned "+ strB(nLongResult))
              EndIf
              If nVidPicTarget = #SCS_VID_PIC_TARGET_P
                setTVGCroppingData(nAudPtr, nTVGIndex, #True)
              Else
                setTVGCroppingData(nAudPtr, nTVGIndex, #False)
              EndIf
              Select \nTVGVideoSource
                Case #SCS_VID_SRC_FILE
                  qPlayerFramePosition = TVG_GetPlayerFramePosition(nHandle)
                  debugMsgT2(sProcName, "TVG_GetPlayerFramePosition(" + sHandle + ")", qPlayerFramePosition)
                  If qPlayerFramePosition > 1
                    nLongResult = TVG_OpenPlayerAtFramePositions(nHandle, qPlayerFramePosition, 0, #tvc_false, #tvc_true)
                    debugMsgT(sProcName, "TVG_OpenPlayerAtFramePositions(" + sHandle + ", " + qPlayerFramePosition + ", 0, #tvc_false, #tvc_true) returned " + strB(nLongResult))
                    debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
                    hideTVGWindowIcons(nTVGIndex)
                  Else
                    CompilerIf 1=2 ; 10Jul2020
                      nLongResult = TVG_OpenPlayer(nHandle)
                      debugMsgT(sProcName, "TVG_OpenPlayer(" + sHandle + ") returned " + strB(nLongResult))
                      debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
                      hideTVGWindowIcons(nTVGIndex)
                    CompilerEndIf
                  EndIf
                Case #SCS_VID_SRC_CAPTURE
                  If bPreviewPlaying
                    nLongResult = TVG_StartPreview(nHandle)
                    debugMsgT(sProcName, "TVG_StartPreview(" + sHandle + ") returned " + strB(nLongResult))
                  EndIf
              EndSelect
            Else
              If bSetPreviewLocation
                ; NB ALWAYS enable cropping for the editor's preview location so the user can dynamically adjust the X, Y and Size without having to have the player re-opened
                If TVG_GetCropping_Enabled(nHandle) = #tvc_false
                  TVG_SetCropping_Enabled(nHandle, #tvc_true)
                  debugMsgT(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_tru )")
                EndIf
              Else
                setTVGCroppingData(nAudPtr, nTVGIndex, #False)
              EndIf
            EndIf ; EndIf \bCrop / Else
          EndIf ; EndIf \bCrop <> bTVGCropping
        EndIf
        
        If dAspectRatioToUse <> 0.0
          If TVG_GetAspectRatioToUse(nHandle) <> dAspectRatioToUse
            TVG_SetAspectRatioToUse(nHandle, dAspectRatioToUse)
            debugMsgT(sProcName, "TVG_SetAspectRatioToUse(" + sHandle + ", " + StrD(dAspectRatioToUse,4) + ")")
          EndIf
        EndIf
        
      EndIf ; EndIf bSetMainLocation Or bSetMonitorLocation Or bSetPreviewLocation Or bSetOutputLocation
      
      debugMsg(sProcName, "calling setTVGCroppingData(" + getAudLabel(nAudPtr) + ", " + nTVGIndex + ", #False)")
      setTVGCroppingData(nAudPtr, nTVGIndex, #False)
      
      If bSetMainLocation
        If nSubPtr >= 0
          sScreens = aSub(nSubPtr)\sScreens
          If gbVideosOnMainWindow
            ; If only one screen is available, meaning videos will be displayed on the main screen, then only display the first screen instance, regardless of how many screens have been selected by the user
            nScreenCount = 1
          Else
            nScreenCount = CountString(sScreens, ",") + 1
          EndIf
          For nScreenIndex = 1 To nScreenCount
            nOutputScreen = Val(StringField(sScreens, nScreenIndex, ","))
            If nScreenIndex = 1
              \nOutputScreen = nOutputScreen
              debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nOutputScreen=" + \nOutputScreen)
              nDisplayIndex = 0
            Else
              nDisplayIndex = nScreenIndex
            EndIf
            ; Explanation of nDisplayIndex: This is passed as the DisplayIndex parameter in relevant TVG function calls, and is set as follows:
            ; 0 = The main display, ie the 1st screen specified in aSub(nSubPtr)\sScreens, which is also stored in \nOutputScreen.
            ; 1 = The monitor display, ie the small display over the SCS main window. This may or may not be present, depending on the 'Monitor Size' SCS Option.
            ; 2 = The 2nd screen specified (if present) in aSub(nSubPtr)\sScreens.
            ; 3 = The 3rd screen specified..., and so on the any further screens specified in aSub(nSubPtr)\sScreens.
            nVidPicTargetForOutputScreen = getVidPicTargetForOutputScreen(nOutputScreen)
            nWindowIndex = nVidPicTargetForOutputScreen - #SCS_VID_PIC_TARGET_F2
            nTVGMonitor = grVidPicTarget(nVidPicTargetForOutputScreen)\nTVGDisplayMonitor
            bShareScreen = grVidPicTarget(nVidPicTargetForOutputScreen)\bShareScreen
            debugMsg(sProcName, "nScreenIndex=" + nScreenIndex + ", nOutputScreen=" + nOutputScreen + ", nWindowIndex=" + nWindowIndex + ", nTVGMonitor=" + nTVGMonitor + ", bShareScreen=" + strB(bShareScreen))
            TVG_SetDisplayMonitor(nHandle, nDisplayIndex, nTVGMonitor)
            debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", " + nDisplayIndex + ", " + nTVGMonitor + ")")
            If gbVideosOnMainWindow
              bSetFullScreen = #False
            ElseIf bUsingMemoryImage
              If grVidPicTarget(nVidPicTargetForOutputScreen)\bShareScreen ; Added this bShareScreen test 11Dec2020 11.8.3.3av
                bSetFullScreen = #False
              Else
                bSetFullScreen = #True
              EndIf
            Else
              bSetFullScreen = #False
              If grVidPicTarget(nVidPicTargetForOutputScreen)\bShareScreen = #False
                Select aAud(nAudPtr)\nAspectRatioType
                  Case #SCS_ART_ORIGINAL, #SCS_ART_FULL
                    If isVideoPosAndSizeDefault(nAudPtr)
                      bSetFullScreen = #True
                    EndIf
                EndSelect
              EndIf
            EndIf
            debugMsg(sProcName, "nOutputScreen=" + nOutputScreen + ", nVidPicTargetForOutputScreen=" + decodeVidPicTarget(nVidPicTargetForOutputScreen) + ", bSetFullScreen=" + strB(bSetFullScreen) + ", bShareScreen=" + strB(bShareScreen))
            If bSetFullScreen
              TVG_SetDisplayFullScreen(nHandle, nDisplayIndex, #tvc_true)
              debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
            Else
              TVG_SetDisplayFullScreen(nHandle, nDisplayIndex, #tvc_false)
              debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
              If nDisplayIndex <> 0
                ; nb already processed the following for nDisplayIndex=0 so no need to execute again
                nMainLeft = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowXWithinDisplayMonitor
                nMainTop = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowYWithinDisplayMonitor
                If nMainLeft = 0 And nMainTop = 0
                  nMainWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopWidth
                  nMainHeight = grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopHeight
                Else
                  nMainWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth
                  nMainHeight = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowHeight
                EndIf
                debugMsg(sProcName, "(a2 main) calling calcDisplayPosAndSize3(" + getAudLabel(nAudPtr) + ", " + aAud(nAudPtr)\nSourceWidth + ", " + aAud(nAudPtr)\nSourceHeight + ", " + nMainWidth + ", " + nMainHeight + ", 0, 0)")
                calcDisplayPosAndSize3(nAudPtr, aAud(nAudPtr)\nSourceWidth, aAud(nAudPtr)\nSourceHeight, nMainWidth, nMainHeight, 0, 0)
                nMainLeft + grDPS\nDisplayLeft
                nMainTop + grDPS\nDisplayTop
                nMainWidth = grDPS\nDisplayWidth
                nMainHeight = grDPS\nDisplayHeight
              EndIf
              nDisplayLeft = nMainLeft
              nDisplayTop = nMainTop
              nDisplayWidth = nMainWidth
              nDisplayHeight = nMainHeight
              If aAud(\nTVGAudPtr)\nAspectRatioType = #SCS_ART_ORIGINAL
                CompilerIf 1=1
                  ; There's a bug in TVG in that if DisplayLeft = 0 or DisplayTop = 0 then the image appears to be being displayed using the Desktop width and height
                  ; instead of the MonitorBounds width and height. If the scaling factor is > 100% then this results in the image being spread over multiple displays.
                  ; A work-around is to move the image 1 pixel from the edge.
                  ; NB does not affect 'full screen' displays.
                  debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTargetForOutputScreen) + ")\nDesktopWidth=" + grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopWidth +
                                      ", \nMainWindowWidth=" + grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth +
                                      ", \nDesktopHeight=" + grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopHeight +
                                      ", \nMainWindowHeight=" + grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowHeight +
                                      ", \nDisplayScalingPercentage=" + grVidPicTarget(nVidPicTargetForOutputScreen)\nDisplayScalingPercentage)
                  If nDisplayIndex <> 1
                    If nDisplayLeft = 0 Or nDisplayTop = 0
                      If grVidPicTarget(nVidPicTargetForOutputScreen)\nDisplayScalingPercentage > 100
                        nDisplayLeft = 1
                        nDisplayTop = 1
                        nDisplayWidth - 1
                        nDisplayHeight - 1
                      EndIf
                    EndIf
                  EndIf
                CompilerEndIf
              EndIf
              nLongResult = TVG_SetDisplayLocation(nHandle, nDisplayIndex, nDisplayLeft, nDisplayTop, nDisplayWidth, nDisplayHeight)
              debugMsgT(sProcName, "TVG_SetDisplayLocation(" + sHandle + ", " + nDisplayIndex + ", " + nDisplayLeft + ", " + nDisplayTop + ", " + nDisplayWidth + ", " + nDisplayHeight + ") (main) returned " + strB(nLongResult))
              ; Added 25Oct2022 11.9.6
              If gaMonitors(1)\nDisplayScalingPercentage <> 100
                If b100PerCentWarningDisplayed = #False And grVideoDriver\bDisableVideoWarningMessage = 0
                   sWarningMessage = LangPars("TVG", "100%Warning1", getSubLabel(nSubPtr))
                  sWarningMessage + #CRLF$ + #CRLF$ + Lang("TVG", "100%Warning2")
                  SAW(#WMN) ; Added 23May2023 11.10.0bd so that the message will be displayed over the main window, not over a video window
                  scsMessageRequester(grProd\sTitle, sWarningMessage, #PB_MessageRequester_Warning)
                  b100PerCentWarningDisplayed = #True
                EndIf
              EndIf
              ; Added 25Oct2022 11.9.6
            EndIf
          Next nScreenIndex
        EndIf ; EndIf nSubPtr >= 0
        
        ; Added 25Feb2025 11.10.7-b04 following email from Lluís Vilarrasa to ensure 'monitor' display position is based on the main window
        If grTVGControl\nDisplayMonitor >= 0 And grOperModeOptions(gnOperMode)\nMonitorSize <> #SCS_MON_NONE
          TVG_SetDisplayMonitor(nHandle, 1, grTVGControl\nDisplayMonitor)
          debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", 1, " + grTVGControl\nDisplayMonitor + ")")
        EndIf
        ; Added 25Feb2025 11.10.7-b04
        
        \bSetMainDisplayLocationDone = #True
      EndIf ; EndIf bSetMainLocation
      
      If bSetMonitorLocation
        nLongResult = TVG_SetDisplayLocation(nHandle, 1, nMonitorLeft, nMonitorTop, nMonitorWidth, nMonitorHeight)
        debugMsgT(sProcName, "TVG_SetDisplayLocation(" + sHandle + ", 1, " + nMonitorLeft + ", " + nMonitorTop + ", " + nMonitorWidth + ", " + nMonitorHeight + ") (monitor) returned " + strB(nLongResult))
        \bSetMonitorDisplayLocationDone = #True
        ; debugMsgT2(sProcName, "TVG_GetDisplayVideoWindowHandle(" + sHandle + ", 1)", TVG_GetDisplayVideoWindowHandle(nHandle, 1))
      EndIf
      
      If bSetPreviewLocation
        setTVGCaptureSize(nAudPtr, nHandle, #SCS_VID_PIC_TARGET_P)
        setTVGCroppingData(nAudPtr, nTVGIndex, #True) ; Added 11Jun2020 11.8.3.2aa
        If grTVGControl\nDisplayMonitor >= 0
          TVG_SetDisplayMonitor(nHandle, nPreviewDisplayIndex, grTVGControl\nDisplayMonitor)
          debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", " + nPreviewDisplayIndex + ", " + grTVGControl\nDisplayMonitor + ")")
        EndIf
        TVG_SetDisplayFullScreen(nHandle, nPreviewDisplayIndex, #tvc_false)
        debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nPreviewDisplayIndex + ", #tvc_false)")
        nLongResult = TVG_SetDisplayLocation(nHandle, nPreviewDisplayIndex, nPreviewLeft, nPreviewTop, nPreviewWidth, nPreviewHeight)
        debugMsgT(sProcName, "TVG_SetDisplayLocation(" + sHandle + ", " + nPreviewDisplayIndex + ", " + nPreviewLeft + ", " + nPreviewTop + ", " + nPreviewWidth + ", " + nPreviewHeight + ") (preview) returned " + strB(nLongResult))
        \bSetPreviewDisplayLocationDone = #True
      EndIf
      
      If bSetOutputLocation ; ie preview on output screen
        If nSubPtr >= 0
          nOutputScreen = aSub(nSubPtr)\nOutputScreen
          \nOutputScreen = nOutputScreen
          debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nOutputScreen=" + \nOutputScreen)
          If nOutputScreen > 0
            nVidPicTargetForOutputScreen = getVidPicTargetForOutputScreen(nOutputScreen)
            nTVGMonitor = grVidPicTarget(nVidPicTargetForOutputScreen)\nTVGDisplayMonitor
            TVG_SetDisplayMonitor(nHandle, nOutputDisplayIndex, nTVGMonitor)
            debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", " + nOutputDisplayIndex + ", " + nTVGMonitor + ")")
            If bUsingMemoryImage
              bSetFullScreen = #True
            Else
              bSetFullScreen = #False
              If grVidPicTarget(nVidPicTargetForOutputScreen)\bShareScreen = #False
                Select aAud(nAudPtr)\nAspectRatioType
                  Case #SCS_ART_ORIGINAL, #SCS_ART_FULL
                    If isVideoPosAndSizeDefault(nAudPtr)
                      bSetFullScreen = #True
                    EndIf
                EndSelect
              EndIf
            EndIf
          EndIf
        EndIf
        If bSetFullScreen
          nLongResult = TVG_SetDisplayFullScreen(nHandle, nOutputDisplayIndex, #tvc_true)
          debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nOutputDisplayIndex + ", #tvc_true) returned " + strB(nLongResult))
        Else
          TVG_SetDisplayFullScreen(nHandle, nOutputDisplayIndex, #tvc_false)
          debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nOutputDisplayIndex + ", #tvc_false)")
          CompilerIf 1=1
            ; This is one of those mysteries (see comments at the top of this procedure) where there is confusion between DesktopWidth and the MonitorBounds width.
            ; In a test of Q2 in "Aspect Ratio Test.scs11" where Q2 is displaying a partial video image to screen 2, and screen 2 has a scaling factor of 175%, I
            ; found that if the image directed to screen 2 extends even 1 pixel beyond the edge of the screen then the whole image is displayed 175%. After lengthy
            ; tests (with the help of "PB Test Files\TVG_DisplayMonitor.pb") I found the following 'fix' resolves the issue.
            If nOutputScreen > 0
              If nOutputWidth <> grVidPicTarget(nVidPicTargetForOutputScreen)\nDesktopWidth
                If nOutputWidth > grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth
                  debugMsg(sProcName, "changing nOutputWidth from " + nOutputWidth + " to " + Str(grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth - 1))
                  nOutputWidth = grVidPicTarget(nVidPicTargetForOutputScreen)\nMainWindowWidth - 1
                EndIf
              EndIf
            EndIf
          CompilerEndIf
          nLongResult = TVG_SetDisplayLocation(nHandle, nOutputDisplayIndex, nOutputLeft, nOutputTop, nOutputWidth, nOutputHeight)
          debugMsgT(sProcName, "TVG_SetDisplayLocation(" + sHandle + ", " + nOutputDisplayIndex + ", " + nOutputLeft + ", " + nOutputTop + ", " + nOutputWidth + ", " + nOutputHeight + ") (output) returned "+ strB(nLongResult))
        EndIf
        \nOutputScreen = nOutputScreen
        debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nOutputScreen=" + \nOutputScreen)
        ; debugMsgT2(sProcName, "TVG_GetDisplayVideoWindowHandle(" + sHandle + ", 1)", TVG_GetDisplayVideoWindowHandle(nHandle, 1))
      EndIf
      
    EndWith
    
  EndIf
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure setTVGDisplayLocationsForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected k, nTVGIndex
  
  debugMsg(sProcName, #SCS_START)
  
  If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
    If pSubPtr >= 0
      k = aSub(pSubPtr)\nFirstAudIndex
      While k >= 0
        For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
          With gaTVG(nTVGIndex)
            If (\nTVGAudPtr = k) And (\nTVGVidPicTarget <> #SCS_VID_PIC_TARGET_NONE)
              debugMsg(sProcName, "nTVGIndex=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", gaTVG(" + nTVGIndex + ")\nTVGAudPtr=" + getAudLabel(\nTVGAudPtr) + ", \bAssigned=" + strB(\bAssigned) + ", \nChannel=" + \nChannel)
              If \nChannel <> 0
                debugMsgT(sProcName, "calling setTVGDisplayLocation(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
                setTVGDisplayLocation(nTVGIndex)
              EndIf
            EndIf
          EndWith
        Next nTVGIndex
        k = aAud(k)\nNextAudIndex
      Wend
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure repositionMonitorDisplays(nMonitorWindowNo)
  PROCNAMEC()
  Protected nMonitorIndex, nTVGIndex
  Protected nMonitorGadgetNo
  Protected nMonitorLeft.l, nMonitorTop.l, nMonitorWidth.l, nMonitorHeight.l
  Protected nCurrLeft.l, nCurrTop.l, nCurrWidth.l, nCurrHeight.l
  Protected nHandle.i, sHandle.s
  
  debugMsg(sProcName, #SCS_START + ", nMonitorWindowNo=" + decodeWindow(nMonitorWindowNo))
  
  If IsWindow(nMonitorWindowNo)
    nMonitorIndex = getIndexForMonitorWindowNo(nMonitorWindowNo)
    If nMonitorIndex >= 0
      nMonitorGadgetNo = WMO(nMonitorIndex)\cntMonitor
      If IsGadget(nMonitorGadgetNo)
;         nMonitorLeft = GadgetX(nMonitorGadgetNo, #PB_Gadget_ScreenCoordinate)
;         nMonitorTop = GadgetY(nMonitorGadgetNo, #PB_Gadget_ScreenCoordinate)
        nMonitorWidth = GadgetWidth(nMonitorGadgetNo)
        nMonitorHeight = GadgetHeight(nMonitorGadgetNo)
        
        For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
          nHandle = *gmVideoGrabber(nTVGIndex)
          If nHandle
            sHandle = decodeHandle(nHandle)
            With gaTVG(nTVGIndex)
              If \nMonitorWindowNo = nMonitorWindowNo And \nTVGVidPicTarget <> #SCS_VID_PIC_TARGET_NONE
                nMonitorLeft = adjustLeftIfNecessary(nHandle, GadgetX(nMonitorGadgetNo, #PB_Gadget_ScreenCoordinate))
                nMonitorTop = adjustTopIfNecessary(nHandle, GadgetY(nMonitorGadgetNo, #PB_Gadget_ScreenCoordinate))
                nCurrLeft = TVG_GetDisplayLeft(nHandle, 1)
                nCurrTop = TVG_GetDisplayTop(nHandle, 1)
                nCurrWidth = TVG_GetDisplayWidth(nHandle, 1)
                nCurrHeight = TVG_GetDisplayHeight(nHandle, 1)
                debugMsgT(sProcName, "TVG_GetDisplayLeft(" + sHandle + ", 1):" + nCurrLeft + ", Top:" + nCurrTop + ", Width:" + nCurrWidth + ", Height:" + nCurrHeight)
                If (nCurrLeft <> nMonitorLeft) Or (nCurrTop <> nMonitorTop) Or (nCurrWidth <> nMonitorWidth) Or (nCurrHeight <> nMonitorHeight)
                  debugMsgT(sProcName, "calling scale_TVG_SetDisplayLocation(" + sHandle + ", 1, " + nMonitorLeft + ", " + nMonitorTop + ", " + nMonitorWidth + ", " + nMonitorHeight + ")")
                  scale_TVG_SetDisplayLocation(nHandle, 1, nMonitorLeft, nMonitorTop, nMonitorWidth, nMonitorHeight)
                EndIf
                Break
              EndIf
            EndWith
          EndIf
        Next nTVGIndex
        
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure repositionMainDisplays(nMainWindowNo)
  PROCNAMEC()
  Protected nMainIndex, nTVGIndex
  Protected nMainGadgetNo
  Protected nMainLeft.l, nMainTop.l, nMainWidth.l, nMainHeight.l
  Protected nCurrLeft.l, nCurrTop.l, nCurrWidth.l, nCurrHeight.l
  
;   debugMsgT(sProcName, #SCS_START + ", nMainWindowNo=" + decodeWindow(nMainWindowNo))
  
  If IsWindow(nMainWindowNo)
    nMainIndex = nMainWindowNo - #WV2
    If nMainIndex >= 0
      nMainGadgetNo = WVN(nMainIndex)\cntMainPicture
      If IsGadget(nMainGadgetNo)
        nMainLeft = GadgetX(nMainGadgetNo, #PB_Gadget_ScreenCoordinate)
        nMainTop = GadgetY(nMainGadgetNo, #PB_Gadget_ScreenCoordinate)
        nMainWidth = GadgetWidth(nMainGadgetNo)
        nMainHeight = GadgetHeight(nMainGadgetNo)
        
        For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
          If *gmVideoGrabber(nTVGIndex)
            With gaTVG(nTVGIndex)
              If (\nMainWindowNo = nMainWindowNo) And (\nTVGVidPicTarget <> #SCS_VID_PIC_TARGET_NONE)
                debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nMainRelLeft=" + \nMainRelLeft + ", \nMainRelTop=" + \nMainRelTop + ", \nMainRelWidth=" + \nMainRelWidth + ", \nMainRelHeight=" + \nMainRelHeight)
                If \nMainRelWidth > 0
                  nMainLeft = GadgetX(nMainGadgetNo, #PB_Gadget_ScreenCoordinate) + \nMainRelLeft
                  nMainTop = GadgetY(nMainGadgetNo, #PB_Gadget_ScreenCoordinate) + \nMainRelTop
                  nMainWidth = \nMainRelWidth
                  nMainHeight = \nMainRelHeight
                EndIf
                nCurrLeft = TVG_GetDisplayLeft(*gmVideoGrabber(nTVGIndex), 0)
                debugMsgT2(sProcName, "TVG_GetDisplayLeft(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", 0)", nCurrLeft)
                nCurrTop = TVG_GetDisplayTop(*gmVideoGrabber(nTVGIndex), 0)
                nCurrWidth = TVG_GetDisplayWidth(*gmVideoGrabber(nTVGIndex), 0)
                nCurrHeight = TVG_GetDisplayHeight(*gmVideoGrabber(nTVGIndex), 0)
                debugMsg(sProcName, "nCurrLeft=" + nCurrLeft + ", nCurrTop=" + nCurrTop + ", nCurrWidth=" + nCurrWidth + ", nCurrHeight=" + nCurrHeight)
                debugMsg(sProcName, "nMainLeft=" + nMainLeft + ", nMainTop=" + nMainTop + ", nMainWidth=" + nMainWidth + ", nMainHeight=" + nMainHeight)
                If (nCurrLeft <> nMainLeft) Or (nCurrTop <> nMainTop) Or (nCurrWidth <> nMainWidth) Or (nCurrHeight <> nMainHeight)
                  debugMsgT(sProcName, "calling scale_TVG_SetDisplayLocation(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", 0, " + nMainLeft + ", " + nMainTop + ", " + nMainWidth + ", " + nMainHeight + ")")
                  scale_TVG_SetDisplayLocation(*gmVideoGrabber(nTVGIndex), 0, nMainLeft, nMainTop, nMainWidth, nMainHeight)
                EndIf
              EndIf
            EndWith
          EndIf
        Next nTVGIndex
        
      EndIf
    EndIf
  EndIf
  
;   debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure repositionTVGDisplay(nDisplayGadgetNo, pVidPicTarget)
  PROCNAMEC()
  Protected nTVGIndex
  Protected nDisplayLeft.l, nDisplayTop.l, nDisplayWidth.l, nDisplayHeight.l
  Protected nCurrLeft.l, nCurrTop.l, nCurrWidth.l, nCurrHeight.l
  Protected nHandle.i, sHandle.s
  
  debugMsg(sProcName, #SCS_START + ", nDisplayGadgetNo=" + getGadgetName(nDisplayGadgetNo) + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If IsGadget(nDisplayGadgetNo)
    ; debugMsg(sProcName, "nDisplayGadgetNo=" + getGadgetName(nDisplayGadgetNo) + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
;     nDisplayLeft = GadgetX(nDisplayGadgetNo, #PB_Gadget_ScreenCoordinate)
;     nDisplayTop = GadgetY(nDisplayGadgetNo, #PB_Gadget_ScreenCoordinate)
    nDisplayWidth = GadgetWidth(nDisplayGadgetNo)
    nDisplayHeight = GadgetHeight(nDisplayGadgetNo)
    For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
      If *gmVideoGrabber(nTVGIndex)
        With gaTVG(nTVGIndex)
          If \nTVGVidPicTarget = pVidPicTarget
            nHandle = *gmVideoGrabber(nTVGIndex)
            sHandle = decodeHandle(nHandle)
            nDisplayLeft = adjustLeftIfNecessary(nHandle, GadgetX(nDisplayGadgetNo, #PB_Gadget_ScreenCoordinate))
            nDisplayTop = adjustTopIfNecessary(nHandle, GadgetY(nDisplayGadgetNo, #PB_Gadget_ScreenCoordinate))
            nCurrLeft = TVG_GetDisplayLeft(nHandle, 0)
            ; debugMsgT2(sProcName, "TVG_GetDisplayLeft(" + sHandle + ", 0)", nCurrLeft)
            nCurrTop = TVG_GetDisplayTop(nHandle, 0)
            nCurrWidth = TVG_GetDisplayWidth(nHandle, 0)
            nCurrHeight = TVG_GetDisplayHeight(nHandle, 0)
            If (nCurrLeft <> nDisplayLeft) Or (nCurrTop <> nDisplayTop) Or (nCurrWidth <> nDisplayWidth) Or (nCurrHeight <> nDisplayHeight)
              TVG_SetDisplayLocation(nHandle, 0, nDisplayLeft, nDisplayTop, nDisplayWidth, nDisplayHeight)
              debugMsgT(sProcName, "TVG_SetDisplayLocation(" + sHandle + ", 0, " + nDisplayLeft + ", " + nDisplayTop + ", " + nDisplayWidth + ", " + nDisplayHeight + ")")
            EndIf
          EndIf
        EndWith
      EndIf
    Next nTVGIndex
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure loadArrayVideoAudioDevs()
  PROCNAMEC()
  Protected d, n
  
  ; debugMsgT(sProcName, #SCS_START)
  debugMsgT(sProcName, "Video Audio devices")
  
  ReDim gaVideoAudioDev(gnNumVideoAudioDevs)
  d = -1
  For n = 0 To gnMaxConnectedDev
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
      d + 1
      With gaVideoAudioDev(d)
        \nVidAudDevId = gaConnectedDev(n)\nDevice
        \sVidAudName = gaConnectedDev(n)\sPhysicalDevDesc
        \bDefaultDev = gaConnectedDev(n)\bDefaultDev
        debugMsgT(sProcName, "gaVideoAudioDev(" + d + ")\sVidAudName=" + #DQUOTE$ + \sVidAudName + #DQUOTE$ + ", \bDefaultDev=" + strB(\bDefaultDev) + ", \nVidAudDevId=" + \nVidAudDevId)
      EndWith
    EndIf
  Next n
  
  gbVideoAudioDevsLoaded = #True
  
  ; debugMsgT(sProcName, #SCS_END + ", gnNumVideoAudioDevs=" + gnNumVideoAudioDevs + ", gbVideoAudioDevsLoaded=" + strB(gbVideoAudioDevsLoaded))
  
EndProcedure

Procedure loadArrayVideoCaptureDevs()
  PROCNAMEC()
  Protected d, n
  
  ; debugMsgT(sProcName, #SCS_START)
  debugMsgT(sProcName, "Video Capture devices")
  
  ReDim gaVideoCaptureDev(gnNumVideoCaptureDevs)
  d = -1
  For n = 0 To gnMaxConnectedDev
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
      d + 1
      With gaVideoCaptureDev(d)
        \nVidCapDevId = gaConnectedDev(n)\nDevice
        \sVidCapName = gaConnectedDev(n)\sPhysicalDevDesc
        \nFormatsCount = gaConnectedDev(n)\nFormatsCount
        \sFormats = gaConnectedDev(n)\sFormats
        debugMsgT(sProcName, "gaVideoCaptureDev(" + d + ")\sVidCapName=" + \sVidCapName + ", \nVidCapDevId=" + \nVidCapDevId +
                             ", \nFormatsCount=" + \nFormatsCount + ", \sFormats=" + ReplaceString(\sFormats, Chr(10), ", "))
      EndWith
    EndIf
  Next n
    
  gbVideoCaptureDevsLoaded = #True
  
  ; debugMsgT(sProcName, #SCS_END + ", gnNumVideoCaptureDevs=" + gnNumVideoCaptureDevs + ", gbVideoCaptureDevsLoaded=" + strB(gbVideoCaptureDevsLoaded))
  
EndProcedure

Procedure listTVGDirectShowFilters()
  PROCNAMEC()
  Protected *mDirectShowFilters
  
  If *gmVideoGrabber(0)
    With grTVGControl
      \nDirectShowFiltersCount = TVG_GetDirectShowFiltersCount(*gmVideoGrabber(0))
      debugMsgT2(sProcName, "TVG_GetDirectShowFiltersCount(" + decodeHandle(*gmVideoGrabber(0)) + ")", \nDirectShowFiltersCount)
      *mDirectShowFilters = TVG_GetDirectShowFilters(*gmVideoGrabber(0))
      ; debugMsgT2(sProcName, "TVG_GetDirectShowFilters(" + decodeHandle(*gmVideoGrabber(0)) + ")", *mDirectShowFilters)
      If *mDirectShowFilters
        \sDirectShowFilters = PeekS(*mDirectShowFilters)
        CompilerIf #cTraceFiltersEtc
          debugMsgT(sProcName, "grTVGControl\sDirectShowFilters=" + \sDirectShowFilters)
        CompilerEndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure setFrameGrabberEnabled(nTVGIndex, bEnable)
  PROCNAMEC()
  Protected nCurrEnabledState.l
  
  If *gmVideoGrabber(nTVGIndex)
    nCurrEnabledState = TVG_GetFrameGrabber(*gmVideoGrabber(nTVGIndex))
    If bEnable
      If nCurrEnabledState <> #tvc_fg_BothStreams
        TVG_SetFrameGrabber(*gmVideoGrabber(nTVGIndex), #tvc_fg_BothStreams)
        debugMsgT(sProcName, "TVG_SetFrameGrabber(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #tvc_fg_BothStreams)")
      EndIf
    Else
      If nCurrEnabledState <> #tvc_fg_Disabled
        TVG_SetFrameGrabber(*gmVideoGrabber(nTVGIndex), #tvc_fg_Disabled)
        debugMsgT(sProcName, "TVG_SetFrameGrabber(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #tvc_fg_Disabled)")
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure setTVGCaptureSize(pAudPtr, nHandle.i, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected sHandle.s
  Protected nReqdVidPicTarget, nReqdTargetWidth.l, nReqdTargetHeight.l
  
  With aAud(pAudPtr)
    sHandle = decodeHandle(nHandle)
    If \nVideoSource = #SCS_VID_SRC_CAPTURE
      nReqdTargetWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
      nReqdTargetHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nTargetWidth=" + nReqdTargetWidth + ", \nTargetHeight=" + nReqdTargetHeight)
      If pVidPicTarget = #SCS_VID_PIC_TARGET_P
        If TVG_GetDisplayActive(nHandle, 1)
          nReqdVidPicTarget = getVidPicTargetForOutputScreen(aSub(\nSubIndex)\nOutputScreen)
          nReqdTargetWidth = grVidPicTarget(nReqdVidPicTarget)\nTargetWidth
          nReqdTargetHeight = grVidPicTarget(nReqdVidPicTarget)\nTargetHeight
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nReqdVidPicTarget) + ")\nTargetWidth=" + nReqdTargetWidth + ", \nTargetHeight=" + nReqdTargetHeight)
        EndIf
      EndIf
      TVG_UseNearestVideoSize(nHandle, nReqdTargetWidth, nReqdTargetHeight, #tvc_false)
      debugMsgT(sProcName, "TVG_UseNearestVideoSize(" + sHandle + ", " + nReqdTargetWidth + ", " + nReqdTargetHeight + ", #tvc_false)")
      debugMsg(sProcName, "TVG_GetVideoWidth(" + sHandle + ")=" + TVG_GetVideoWidth(nHandle) + ", TVG_GetVideoHeight(" + sHandle + ")=" + TVG_GetVideoHeight(nHandle))
      \nSourceWidth = TVG_GetVideoWidth(nHandle)
      \nSourceHeight = TVG_GetVideoHeight(nHandle)
      debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight)
    EndIf
  EndWith
EndProcedure

Procedure setTVGCroppingData(pAudPtr, nTVGIndex, bEditing, bMyTrace=#False)
  PROCNAMECA(pAudPtr)
  Protected nHandle.i, sHandle.s
  Protected nCroppingX.l, nCroppingY.l, nCroppingWidth.l, nCroppingHeight.l, dCroppingZoom.d
  Protected bForce = #False
  Protected bTrace = #cTraceTVGCropping
  
  If bTrace = #False
    bTrace = bMyTrace
  EndIf
  ; debugMsgC(sProcName, #SCS_START)
  
  nHandle = *gmVideoGrabber(nTVGIndex)
  sHandle = decodeHandle(nHandle)
  
  With aAud(pAudPtr)
    If \bUsingMemoryImage = #False
      If \bTVGCropping Or bEditing
        ; NB ALWAYS enable cropping if editing so the user can dynamically adjust the X, Y and Size without having to have the player re-opened
        If \bTVGCropping
          nCroppingX = \nTVGCroppingX
          nCroppingY = \nTVGCroppingY
          nCroppingWidth = \nTVGCroppingWidth
          nCroppingHeight = \nTVGCroppingHeight
          dCroppingZoom = \dTVGCroppingZoom
        Else
          ; editing, but cropping not currently required
          nCroppingWidth = \nSourceWidth
          nCroppingHeight = \nSourceHeight
          dCroppingZoom = 1.0
        EndIf
        
        If TVG_GetCropping_Enabled(nHandle) = #tvc_false Or bForce
          TVG_SetCropping_Enabled(nHandle, #tvc_true)
          debugMsgC(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_true)")
        EndIf
        
        If TVG_GetCropping_Outbounds(nHandle) = #tvc_false Or bForce
          TVG_SetCropping_Outbounds(nHandle, #tvc_true)
          debugMsgC(sProcName, "TVG_SetCropping_OutBounds(" + sHandle + ", #tvc_true)")
        EndIf
        
        If TVG_GetCropping_X(nHandle) <> nCroppingX Or bForce
          TVG_SetCropping_X(nHandle, nCroppingX)
          debugMsgC(sProcName, "TVG_SetCropping_X(" + sHandle + ", " + nCroppingX + ")")
        EndIf
        
        If TVG_GetCropping_Y(nHandle) <> nCroppingY Or bForce
          TVG_SetCropping_Y(nHandle, nCroppingY)
          debugMsgC(sProcName, "TVG_SetCropping_Y(" + sHandle + ", " + nCroppingY + ")")
        EndIf
        
        If TVG_GetCropping_Width(nHandle) <> nCroppingWidth Or bForce
          TVG_SetCropping_Width(nHandle, nCroppingWidth)
          debugMsgC(sProcName, "TVG_SetCropping_Width(" + sHandle + ", " + nCroppingWidth + ")")
        EndIf
        
        If TVG_GetCropping_Height(nHandle) <> nCroppingHeight Or bForce
          TVG_SetCropping_Height(nHandle, nCroppingHeight)
          debugMsgC(sProcName, "TVG_SetCropping_Height(" + sHandle + ", " + nCroppingHeight + ")")
        EndIf
        
        If TVG_GetCropping_Zoom(nHandle) <> dCroppingZoom Or bForce
          TVG_SetCropping_Zoom(nHandle, dCroppingZoom)
          debugMsgC(sProcName, "TVG_SetCropping_Zoom(" + sHandle + ", " + StrD(dCroppingZoom,4) + ")")
        EndIf
        
      Else
        If TVG_GetCropping_Enabled(nHandle)
          TVG_SetCropping_Enabled(nHandle, #tvc_false)
          debugMsgC(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_false)")
        EndIf
        
      EndIf ; EndIf / Else \bTVGCropping Or bEditing
    EndWith
  EndIf ; EndIf \bUsingMemoryImage = #False
  
EndProcedure

Procedure openVideoFileForTVG(pAudPtr, pVidPicTarget, nIndexAssigned=-1)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nSubPtr
  Protected nTVGIndex
  Protected sFileName.s
  Protected bDualDisplayActive
  Protected nLongResult.l
  Protected nOpenPlayerResult.l
  Protected qDuration.q
  Protected qImageDuration.q
;   Protected AVIFile.l
  Protected Duration.q, FrameCount.q, _VideoWidth.l, _VideoHeight.l, VideoFrameRateFPS.d, AvgBitRate.l, AudioChannels.l, AudioSamplesPerSec.l
  Protected AudioBitsPerSample.l
  Protected nAudioFormat.l
  Protected pVideoCodec.l, pAudioCodec.l
  Protected nVideoPhysicalDevPtr, nVideoDevId, nAudioPhysicalDevPtr, nAudioDevId
  Protected nAudioRenderer
  Protected nChannel
  Protected qStartPos.q, qEndPos.q
  Protected nCurrActiveWindow
  Protected *VideoCodec, *AudioCodec
  Protected nDevMapDevPtr
  Protected bDoneAudio
  Protected sForcedCodec.s
  Protected nRequestPtr, bRequestProcessed
  Protected bFadeInReqd
  Protected nHandle.i, sHandle.s, nDisplayIndex.l, nReqdRotation, lRotation.l
  Protected sKeyEvent.s
  Protected sDriveRootFolder.s, nDriveType
  Protected qTimeStarted.q
  Protected nReqdFrameGrabber.l, sReqdFrameGrabber.s
  Protected nOutputScreenNo, nVidPicTarget, nTVGMonitor.l
  Protected sScreens.s, nScreenIndex, sScreenNo.s
  Protected bUsingMemoryImage, sBlankString.s = ""
  Protected bEditing
  Protected nSCSVideoRenderer, nTVGVideoRenderer, nTVGExternalRenderer, nItemIndex
  Protected qCurrPos.q
  CompilerIf #c_tvg_onrawaudiosample
    Protected nMixerStreamPtr, nMixerStreamHandle.l, nMixerChannelFlags.l, sBassCommand.s, nBassResult.l
  CompilerEndIf
  CompilerIf #c_tvg_audio_streams
    Protected sAudioStreams.s, sTemp.s, nTemp, *AviInfo2Result
  CompilerEndIf
  
  debugMsgT(sProcName, #SCS_START + ", nIndexAssigned=" + nIndexAssigned)
  
  qTimeStarted = ElapsedMilliseconds()

  If pAudPtr >= 0
    
    nCurrActiveWindow = GetActiveWindow()
    
    With aAud(pAudPtr)
      
      nSubPtr = \nSubIndex
      ; nIndexAssigned added 2Apr2020 11.8.2.3aj
      If nIndexAssigned >= 0
        nTVGIndex = nIndexAssigned
      Else
        nTVGIndex = assignTVGControl(nSubPtr, pAudPtr, pVidPicTarget)
        debugMsgT(sProcName, "assignTVGControl(" + getSubLabel(nSubPtr) + ", " + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ") returned " + nTVGIndex)
      EndIf
      If nTVGIndex >= 0
        nHandle = *gmVideoGrabber(nTVGIndex)
        sHandle = decodeHandle(nHandle)
        bDualDisplayActive = gaTVG(nTVGIndex)\bDualDisplayActive
        
        ; INFO TVG Set Player Filename
        sFileName = \sFileName
        sDriveRootFolder = getDriveRootFolder(sFileName)
        nDriveType = getDriveType(sDriveRootFolder)
        bUsingMemoryImage = \bUsingMemoryImage
        If bUsingMemoryImage
          TVG_SetVideoSource(nHandle, #tvc_vs_JPEGsOrBitmaps)
          debugMsg(sProcName, "ImageWidth(\nMemoryImageNo)=" + ImageWidth(\nMemoryImageNo) + ", ImageHeight(\nMemoryImageNo)=" + ImageHeight(\nMemoryImageNo))
          debugMsgT(sProcName, "TVG_SetVideoSource(" + sHandle + ", #tvc_vs_JPEGsOrBitmaps)")
          nLongResult = TVG_SendImageToVideoFromBitmaps(nHandle, @sBlankString, ImageID(\nMemoryImageNo), #tvc_false, #tvc_false)
          debugMsgT(sProcName, "TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(\nMemoryImageNo) + "), #tvc_false, #tvc_false) returned " + strB(nLongResult))
        Else
          TVG_SetVideoSource(nHandle, #tvc_vs_VideoFileOrURL)
          debugMsgT(sProcName, "TVG_SetVideoSource(" + sHandle + ", #tvc_vs_VideoFileOrURL)")
          TVG_SetPlayerFileName(nHandle, @sFileName)
          debugMsgT(sProcName, "TVG_SetPlayerFileName(" + sHandle + ", " + GetFilePart(sFileName) + "), nDriveType=" + decodeDriveType(nDriveType))
          
          If \nFileFormat = #SCS_FILEFORMAT_VIDEO
            Select LCase(\sFileExt)
              Case "wmv"
                ; no action
              Default
                If grDontTellMeAgain\bVideoCodecs = #False
                  ; note: tests conducted by Llu?s Vilarrasa have shown that even avi files may not play correctly if FFDSHOW or LAV is not installed
                  ; nb - only FFDSHOW has been thoroughly tested, but Stas Ushomirsky seemed to find that he needed the LAV Filters to get his videos to play
                  ; nb as at 11.5.3 changed preference from FFDSHOW to LAVFilters as this is easier to install and seems to work very well
                  check_FFDSHOW_or_LAV_installed(pAudPtr)
                EndIf
            EndSelect
          EndIf
          
          ; added 11Jan2017 11.5.3
          If (grTVGControl\bFFDSHOWInstalled) And (grTVGControl\bLAVFiltersInstalled)
            sForcedCodec = "NOFFDSHOW"
            TVG_SetPlayerForcedCodec(nHandle, @sForcedCodec)
            debugMsgT(sProcName, "TVG_SetPlayerForcedCodec(" + sHandle + ", @" + #DQUOTE$ + sForcedCodec + #DQUOTE$ + ")")
          EndIf
          ; end added 11Jan2017 11.5.3
          
          ; disable player auto-start
          TVG_SetAutoStartPlayer(nHandle, #tvc_false)
          debugMsgT(sProcName, "TVG_SetAutoStartPlayer(" + sHandle + ", #tvc_false)")
          
        EndIf ; EndIf (\nFileFormat = #SCS_FILEFORMAT_PICTURE) And (IsImage(\nMemoryImageNo)) / Else
        
        ; hide image initially by setting alpha-blend = 0
        TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
        If bDualDisplayActive
          TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
        EndIf
        For nDisplayIndex = 2 To 8
          If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
            TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
          EndIf
        Next nDisplayIndex
        
        ; reset properties that may have been changed by an earlier use of this TVG control
        If TVG_GetCropping_Enabled(nHandle)
          TVG_SetCropping_Enabled(nHandle, #tvc_false)
          debugMsgT(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_false)")
        EndIf
        
        If bUsingMemoryImage = #False
          ; aspect ratio
          If \nAspectRatioType = #SCS_ART_FULL
            TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Stretch)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 0, #tvc_ar_Stretch)")
            If bDualDisplayActive
              TVG_SetDisplayAspectRatio(nHandle, 1, #tvc_ar_Stretch)
              debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 1, #tvc_ar_Stretch)")
            EndIf
            For nDisplayIndex = 2 To 8
              If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                TVG_SetDisplayAspectRatio(nHandle, nDisplayIndex, #tvc_ar_Stretch)
                debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", " + nDisplayIndex + ", #tvc_ar_Stretch)")
              EndIf
            Next nDisplayIndex
          Else
            TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Box)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 0, #tvc_ar_Box)")
            If bDualDisplayActive
              TVG_SetDisplayAspectRatio(nHandle, 1, #tvc_ar_Box)
              debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 1, #tvc_ar_Box)")
            EndIf
            For nDisplayIndex = 2 To 8
              If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                TVG_SetDisplayAspectRatio(nHandle, nDisplayIndex, #tvc_ar_Box)
                debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", " + nDisplayIndex + ", #tvc_ar_Box)")
              EndIf
            Next nDisplayIndex
          EndIf
          
        EndIf ; EndIf bUsingMemoryImage = #False
        
        ; audio renderer
        bDoneAudio = #False
        aSub(nSubPtr)\nVideoAudioDevPtr = -1
        If (aSub(nSubPtr)\bMuteVideoAudio) Or (gnDSDeviceCount = 0 And gnWASAPIDeviceCount = 0)
          TVG_SetMuteAudioRendering(nHandle, #tvc_true)
          debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_true)")
        Else
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, aSub(nSubPtr)\sVidAudLogicalDev)
          ; debugMsgT(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\sVidAudLogicalDev=" + aSub(nSubPtr)\sVidAudLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
          If nDevMapDevPtr >= 0
            If grMaps\aDev(nDevMapDevPtr)\bIgnoreDevThisRun
              TVG_SetMuteAudioRendering(nHandle, #tvc_true)
              debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_true)")
              bDoneAudio = #True
            EndIf
          EndIf
          If bDoneAudio = #False
            aSub(nSubPtr)\nVideoAudioDevPtr = nDevMapDevPtr
            TVG_SetMuteAudioRendering(nHandle, #tvc_false)
            debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_false)")
            nAudioPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, aSub(nSubPtr)\sVidAudLogicalDev)
            ; debugMsgT(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\sVidAudLogicalDev=" + aSub(nSubPtr)\sVidAudLogicalDev + ", nAudioPhysicalDevPtr=" + nAudioPhysicalDevPtr)
            If nAudioPhysicalDevPtr >= 0
              nAudioDevId = gaVideoAudioDev(nAudioPhysicalDevPtr)\nVidAudDevId
              TVG_SetAudioRenderer(nHandle, nAudioDevId) ; NB -1 = default renderer
              debugMsgT(sProcName, "TVG_SetAudioRenderer(" + sHandle + ", " + nAudioDevId + ") [" + gaVideoAudioDev(nAudioPhysicalDevPtr)\sVidAudName + "]")
            EndIf
            CompilerIf #c_tvg_onrawaudiosample
              ;\nVideoASIOStream = BASS_StreamCreate(44100, 2, #BASS_SAMPLE_FLOAT|#BASS_STREAM_DECODE, #STREAMPROC_PUSH, 0)
              \nVideoASIOStream = BASS_StreamCreate(44100, 2, #BASS_STREAM_DECODE, #STREAMPROC_PUSH, 0)                     ; TVG audio decode corrected to use non float
              debugMsgT2(sProcName, "BASS_StreamCreate(44100, 2, #BASS_STREAM_DECODE, #STREAMPROC_PUSH, 0)", \nVideoASIOStream)
              newHandle(#SCS_HANDLE_SOURCE, \nVideoASIOStream, #True)
              nMixerStreamPtr = 0
              nMixerStreamHandle = gaMixerStreams(nMixerStreamPtr)\nMixerStreamHandle
              nMixerChannelFlags = #BASS_MIXER_CHAN_DOWNMIX|#BASS_MIXER_CHAN_BUFFER|#BASS_MIXER_CHAN_NORAMPIN|#BASS_MIXER_CHAN_PAUSE
              sBassCommand = "BASS_Mixer_StreamAddChannel(" + decodeHandle(nMixerStreamHandle) + ", " + decodeHandle(\nVideoASIOStream) + ", " + decodeStreamCreateFlags(nMixerChannelFlags, #False, #True) + ")"
              nBassResult = BASS_Mixer_StreamAddChannel(nMixerStreamHandle, \nVideoASIOStream, nMixerChannelFlags)
              debugMsg2(sProcName, sBassCommand, nBassResult)
            CompilerEndIf
          EndIf
        EndIf
        
        ; video renderer
        ; Modified the following 16Dec2020 11.8.3.4aa because...
        ; The compiler constant #c_blackmagic_card_support was added in 11.8.3.2, but was not ultimately implemented as it did not solve the BlackMagic issue raised by a user.
        ; However, the code in 11.8.3.2 did not include this test, and the original code that used grVideoDriverSession\nTVGVideoRendererTVGValue had been removed.
        ; So in 11.8.3.4aa we have reinstated the code that uses grVideoDriverSession\nTVGVideoRendererTVGValue, following emails from Paul Wilton about trying to use EVR.
        CompilerIf #c_blackmagic_card_support
          nOutputScreenNo = aSub(nSubPtr)\nOutputScreen
          nSCSVideoRenderer = getVideoRendererForScreen(nOutputScreenNo)
          debugMsgT(sProcName, "nOutputScreenNo=" + nOutputScreenNo + ", nSCSVideoRenderer=" + decodeVideoRenderer(nSCSVideoRenderer))
        CompilerElse
          nSCSVideoRenderer = grVideoDriverSession\nTVGVideoRendererTVGValue
        CompilerEndIf
        nTVGVideoRenderer = #tvc_vr_AutoSelect
        nTVGExternalRenderer = #tvc_vre_None
        Select nSCSVideoRenderer
          Case #SCS_VR_AUTOSELECT
            nTVGVideoRenderer = #tvc_vr_AutoSelect
          Case #SCS_VR_EVR
            nTVGVideoRenderer = #tvc_vr_EVR
          Case #SCS_VR_OVERLAY
            nTVGVideoRenderer = #tvc_vr_OverlayRenderer
          Case #SCS_VR_STANDARD
            nTVGVideoRenderer = #tvc_vr_StandardRenderer
          Case #SCS_VR_VMR7
            nTVGVideoRenderer = #tvc_vr_VMR7
          Case #SCS_VR_VMR9
            nTVGVideoRenderer = #tvc_vr_VMR9
          Case #SCS_VR_BLACKMAGIC_DECKLINK
            nTVGExternalRenderer = #tvc_vre_BlackMagic_Decklink
        EndSelect
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFileFormat=" + decodeFileFormat(\nFileFormat))
          TVG_SetVideoRenderer(nHandle, nTVGVideoRenderer)
          debugMsgT(sProcName, "TVG_SetVideoRenderer(" + sHandle + ", " + decodeTVGVideoRenderer(nTVGVideoRenderer) + ")")
          TVG_SetVideoRendererExternal(nHandle, nTVGExternalRenderer)
          debugMsgT(sProcName, "TVG_SetVideoRendererExternal(" + sHandle + ", " + decodeTVGExternalRenderer(nTVGExternalRenderer) + ")")
        EndIf
        
        If nTVGExternalRenderer = #tvc_vre_BlackMagic_Decklink
          ; See TVG documentation under "Blackmagic Decklink Cards" explains why TVG_UseNearestVideoSize() should be used (at least for HD)
          TVG_UseNearestVideoSize(nHandle, 1920, 1080, #tvc_true)
          debugMsgT(sProcName, "TVG_UseNearestVideoSize(" + sHandle + ", 1920, 1080, #tvc_true)")
        EndIf
        
        ; OPEN FILE
        If \nFileFormat = #SCS_FILEFORMAT_VIDEO
          If \nAbsStartAt > 0
            qStartPos = \nAbsStartAt * 10000
          EndIf
          CompilerIf 1=2
            ; do not set qEndPos for TVG_OpenPlayerAtTimePositions() as it appears that this can cause the video to flip back to the start position
            ; on reaching the specified end position, which causes a brief display of that starting frame
            If (\nAbsEndAt > 0) And (\nAbsEndAt > \nAbsStartAt)
              qEndPos = \nAbsEndAt * 10000
            EndIf
          CompilerEndIf
        EndIf
        
        ; 20Jul2015 11.4.0.3c: mod added for the following reasons:
        ; 1. Luigi Strina reported unsatisfactory performance on playing MPEG files (stuttering)
        ; 2. LS tested TVG's maindemo.exe and reported that performance was best if Frame Grabber was disabled
        ; 3. TVG default for Frame Grabber is 'both streams'
        ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nFadeInTime=" + \nFadeInTime + ", \nCurrFadeInTime=" + \nCurrFadeInTime + ", aSub(" + getSubLabel(\nSubIndex) + ")\nPLFadeInTime=" + aSub(\nSubIndex)\nPLFadeInTime)
        If \nCurrFadeInTime > 0
          bFadeInReqd = #True
        ElseIf \nPrevPlayIndex = -1
          If aSub(nSubPtr)\nPLFadeInTime > 0
            bFadeInReqd = #True
          EndIf
        EndIf
        ; 18May2017 11.6.1: added test on \nSize because ZoomCoeff requires FrameGrabber
        If (\nFileFormat = #SCS_FILEFORMAT_PICTURE) Or (bFadeInReqd) Or (\nSize <> grAudDef\nSize)
          ; Changed the following 12Aug2021 11.8.5 after tests of "Video Size Test top left.scs11" (although at the time of testing the image is no longer 'top left'),
          ; because the image on the large screen with a display scaling of 175% was cut severely. After exhaustive testing, it was found that the cause of the problem
          ; was setting FrameGrabber to 'BothStreams', and that setting FrameGrabber to 'Disabled' fixed the problem.
          ; Couldn't reproduce any related issues with fade or size, although fade in seems to slow the video regardless of the FrameGrabber setting, and
          ; zooming right in on the image didn't display the image correctly on the 175% screen, also regardless of the FrameGrabber setting.
          ; So decided to stay with 'Disabled' until further notice.
          ; (old code) nReqdFrameGrabber = #tvc_fg_BothStreams
          ; (old code) sReqdFrameGrabber = "#tvc_fg_BothStreams"
          nReqdFrameGrabber = #tvc_fg_Disabled
          sReqdFrameGrabber = "#tvc_fg_Disabled"
          ; End of change 12Aug2021 11.8.5
        ElseIf grVidPicTarget(pVidPicTarget)\bShareScreen
          nReqdFrameGrabber = #tvc_fg_PreviewStream
          sReqdFrameGrabber = "#tvc_fg_PreviewStream"
        Else
          nReqdFrameGrabber = #tvc_fg_Disabled
          sReqdFrameGrabber = "#tvc_fg_Disabled"
        EndIf
        If TVG_GetFrameGrabber(nHandle) <> nReqdFrameGrabber
          TVG_SetFrameGrabber(nHandle, nReqdFrameGrabber)
          debugMsgT(sProcName, "TVG_SetFrameGrabber(" + sHandle + ", " + sReqdFrameGrabber + ")")
        EndIf
        ; 20Jul2015 11.4.0.3c: End of MOD
        
        ; Commented out 7May2020 11.8.3rc3 (\nVideoRotation now populated from grVideoInfo in getVideoInfoForAud())
        ;   debugMsg(sProcName, "calling getVideoInfo(" + GetFilePart(sFileName) + ", #True)")
        ;   getVideoInfo(sFileName, #True)  ; Added 30Jun2018 11.7.1rc5 so that video rotation could be obtained from mmediainfo.dll, because TVG doesn't supply that setting.
        ;   \nVideoRotation = grVideoInfo\nRotation
        ; End commented out 7May2020 11.8.3rc3
        
        ; Added 23Apr2020 11.8.2.3
        nReqdRotation = \nVideoRotation + \nRotate
        If nReqdRotation >= 360
          nReqdRotation - 360
        EndIf
        If nReqdRotation <> 0
          debugMsgT(sProcName, "\nVideoRotation=" + \nVideoRotation + ", \nRotate=" + \nRotate + ", nReqdRotation=" + nReqdRotation)
        EndIf
        ; End added 23Apr2020 11.8.2.3
        Select nReqdRotation
          Case 90
            lRotation = #tvc_rt_90_deg
          Case 180
            lRotation = #tvc_rt_180_deg
          Case 270
            lRotation = #tvc_rt_270_deg
          Default
            lRotation = #tvc_rt_0_deg
        EndSelect
        If TVG_GetVideoProcessingRotation(nHandle) <> lRotation
          ; above test added 16Aug2018 11.7.1.3ac following a test of a cue file provided by Rick Sarson,
          ; which on investigation found that calling TVG_SetVideoProcessingRotation() incurs a short delay,
          ; even if the rotation is not required.
          TVG_SetVideoProcessingRotation(nHandle, lRotation)
          debugMsgT(sProcName, "TVG_SetVideoProcessingRotation(" + sHandle + ", " + lRotation + ")")
        EndIf
        
        CompilerIf 1=1
          ; Changed 7Oct2022 following bug reported by James Lownie, where 'flip horizontal' was not working.
          ; Use TVG_SetVideoProcessingRotation() instead of TVG_SetVideoProcessingFlip...() because TVG_SetVideoProcessingFlip...() requires FrameGrabber.
          Select \nFlip
            Case #SCS_FLIPH
              TVG_SetVideoProcessingRotation(nHandle, #tvc_rt_0_deg_mirror)
              debugMsgT(sProcName, "TVG_SetVideoProcessingRotation(" + sHandle + ", #tvc_rt_0_deg_mirror)")
            Case #SCS_FLIPV
              TVG_SetVideoProcessingRotation(nHandle, #tvc_rt_180_deg_mirror) ; Not sure why this requires 'mirror', but it seems necessary
              debugMsgT(sProcName, "TVG_SetVideoProcessingRotation(" + sHandle + ", #tvc_rt_180_deg_mirror)")
          EndSelect
        CompilerElse
          Select \nFlip
            Case #SCS_FLIPH
              TVG_SetVideoProcessingFlipHorizontal(nHandle, #tvc_true)
              debugMsgT(sProcName, "TVG_SetVideoProcessingFlipHorizontal(" + sHandle + ", #tvc_true)")
            Case #SCS_FLIPV
              TVG_SetVideoProcessingFlipVertical(nHandle, #tvc_true)
              debugMsgT(sProcName, "TVG_SetVideoProcessingFlipVertical(" + sHandle + ", #tvc_true)")
          EndSelect
        CompilerEndIf
        
        setTVGCaptureSize(pAudPtr, nHandle, pVidPicTarget)
        ; added 11Jun2020 11.8.3.2aa to replace code that is now included in this new procedure setTVGCroppingData()
        If pVidPicTarget = #SCS_VID_PIC_TARGET_P
          setTVGCroppingData(pAudPtr, nTVGIndex, #True)
        Else
          setTVGCroppingData(pAudPtr, nTVGIndex, #False)
        EndIf
        ; end added 11Jun2020 11.8.3.2aa
        
        sScreens = aSub(nSubPtr)\sScreens
        For nDisplayIndex = 0 To 8
          If nDisplayIndex <> 1
            If nDisplayIndex = 0
              nScreenIndex = 1 ; nDisplayIndex 0 means the 1st entry in sScreens
            Else
              nScreenIndex = nDisplayIndex ; eg nDisplayIndex 2 means the 2nd entry in sScreens
            EndIf
            sScreenNo = Trim(StringField(sScreens, nScreenIndex, ","))
            If sScreenNo
              ; selected entry exists in sScreens
              nOutputScreenNo = Val(sScreenNo)
              nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreenNo)
              nTVGMonitor = grVidPicTarget(nVidPicTarget)\nTVGDisplayMonitor
              TVG_SetDisplayMonitor(nHandle, nDisplayIndex, nTVGMonitor)
              debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", " + nDisplayIndex + ", " + nTVGMonitor + ")")
              debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\bShareScreen=" + strB(grVidPicTarget(nVidPicTarget)\bShareScreen))
              If grVidPicTarget(nVidPicTarget)\bShareScreen = #False
                TVG_SetDisplayFullScreen(nHandle, nDisplayIndex, #tvc_true)
                debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
              EndIf
              TVG_SetDisplayStayOnTop(nHandle, nDisplayIndex, #tvc_false)
              debugMsgT(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
            EndIf
          EndIf
        Next nDisplayIndex
        
        ; Added 25Feb2025 11.10.7-b04 following email from Lluís Vilarrasa to ensure 'monitor' display position is based on the main window
        If grTVGControl\nDisplayMonitor >= 0 And grOperModeOptions(gnOperMode)\nMonitorSize <> #SCS_MON_NONE
          TVG_SetDisplayMonitor(nHandle, 1, grTVGControl\nDisplayMonitor)
          debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", 1, " + grTVGControl\nDisplayMonitor + ")")
        EndIf
        ; Added 25Feb2025 11.10.7-b04
        
        nLongResult = TVG_AVIInfo(nHandle, @sFileName, @Duration, @FrameCount, @_VideoWidth, @_VideoHeight, @VideoFrameRateFPS, @AvgBitRate, @AudioChannels, @AudioSamplesPerSec,
                                  @AudioBitsPerSample, @pVideoCodec, @pAudioCodec)
        debugMsgT(sProcName, "TVG_AVIInfo(" + sHandle + ",...) returned " + strB(nLongResult))
        debugMsgT(sProcName, "Duration=" + Duration + ", FrameCount=" + FrameCount + ", _VideoWidth=" + _VideoWidth + ", _VideoHeight=" + _VideoHeight +
                             ", VideoFrameRateFPS=" + StrD(VideoFrameRateFPS,2) + ", AvgBitRate=" + AvgBitRate +
                             ", AudioChannels=" + AudioChannels + ", AudioSamplesPerSec=" + AudioSamplesPerSec + ", AudioBitsPerSample=" + AudioBitsPerSample)
        \qVideoFrameCount = FrameCount ; Added 17Feb2025
        CompilerIf #c_tvg_audio_streams
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_Duration)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_Duration) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_FrameCount)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_FrameCount) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_VideoWidth)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_VideoWidth) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_VideoHeight)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_VideoHeight) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AudioStreams)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AudioStreams) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_VideoFrameRateFps)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_VideoFrameRateFPS) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_VideoCodec)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_VideoCodec) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AudioCodec)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AudioCodec) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AvgBitRate)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AvgBitRate) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AudioChannels)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AudioChannels) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AudioSamplesPerSec)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AudioSamplesPerSec) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_AudioBitsPerSample)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_AudioBitsPerSample) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
          *AviInfo2Result = TVG_AVIInfo2(nHandle, @sFileName, #tvc_av_FileSizeInKB)
          debugMsg0(sProcName, "TVG_AVIInfo2(" + sHandle + ", @sFileName, #tvc_av_FileSizeInKB) returned " + *AviInfo2Result)
          If *AviInfo2Result : debugMsg0(sProcName, "PeekS(*AviInfo2Result)=" + PeekS(*AviInfo2Result)) : EndIf
        CompilerEndIf
        ; Added 28Nov2022 11.9.7ap
        If _VideoWidth = 0 Or _VideoHeight = 0
          ; TVG failed to open the file successfully (mainly seems to occur with 32-bit executables with large image files, eg dimensions 8000x4500 as supplied by Ian Harding)
          debugMsg0(sProcName, "_VideoWidth=" + _VideoWidth + ", _VideoHeight=" + _VideoHeight + " so TVG failed to successfully open the file")
          debugMsg(sProcName, "calling freeTVGControl(nTVGIndex=" + nTVGIndex + ", bForceClose=#True)")
          freeTVGControl(nTVGIndex, #True)
          nChannel = 0
          ProcedureReturn nChannel
        EndIf
        ; End added 28Nov2022 11.9.7ap
        If AudioChannels > 0 ; Test added 30Nov2021 11.8.6cm following email from Josh Wilson
          debugMsgT(sProcName, "TVG_GetAudioFormat(" + sHandle + ")=" + TVG_GetAudioFormat(nHandle))
          nAudioFormat = getTVGAudioFormat(AudioSamplesPerSec, AudioChannels, AudioBitsPerSample)
          debugMsgT(sProcName, "getTVGAudioFormat(" + AudioSamplesPerSec + ", " + AudioChannels + ", " + AudioBitsPerSample + ") returned " + nAudioFormat)
          TVG_SetAudioFormat(nHandle, nAudioFormat)
          debugMsgT(sProcName, "TVG_GetAudioFormat(" + sHandle + ")=" + TVG_GetAudioFormat(nHandle))
        EndIf
        ; debugMsgT(sProcName, "AVIFile=" + AVIFile)
        ; debugMsgT(sProcName, "pVideoCodec=" + pVideoCodec)
        ; debugMsgT(sProcName, "pAudioCodec=" + pAudioCodec)
        sKeyEvent = sHandle + " " + #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$ + ", Duration=" + Str(Duration / 10000) + ", VideoWidth=" + _VideoWidth + ", VideoHeight=" + _VideoHeight
        
        grVideoInfo\sFileName = sFileName
        ; 9May2020 11.8.3rc3: commented out test of #c_tvg_preferred_aspect_ratio because it doesn't seem necessary, and cannot be meaningfully used before TVG_OpenPlayer() is called
;         CompilerIf #c_tvg_preferred_aspect_ratio
;           grVideoInfo\nSourceWidth = TVG_GetVideoWidth_PreferredAspectRatio(nHandle)
;           grVideoInfo\nSourceHeight = TVG_GetVideoHeight_PreferredAspectRatio(nHandle)
;         CompilerElse
          grVideoInfo\nSourceWidth = _VideoWidth
          grVideoInfo\nSourceHeight = _VideoHeight
;         CompilerEndIf
        debugMsg(sProcName, "grVideoInfo\nSourceWidth=" + grVideoInfo\nSourceWidth + ", \nSourceHeight=" + grVideoInfo\nSourceHeight)
        grVideoInfo\sInfo = UCase(GetExtensionPart(sFileName))
        If (grVideoInfo\nSourceWidth > 0) And (grVideoInfo\nSourceHeight > 0)
          grVideoInfo\sInfo + " " + grVideoInfo\nSourceWidth + "x" + grVideoInfo\nSourceHeight
        EndIf
        grVideoInfo\sTitle = ignoreExtension(GetFilePart(sFileName))
        
        \nSourceWidth = grVideoInfo\nSourceWidth ; must set \nSourceWidth and \nSourceHeight before calling setTVGDisplayLocation()
        \nSourceHeight = grVideoInfo\nSourceHeight
        ; Added 12Jan2024 11.10.0
        If AudioChannels > 0
          \nFileChannels = AudioChannels
        EndIf
        ; End added 12Jan2024 11.10.0
        debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nSourceWidth=" + \nSourceWidth + ", \nSourceHeight=" + \nSourceHeight + ", \nFileChannels=" + \nFileChannels)
        
        ; See 'Important Information' in procedure setTVGDisplayLocation() regarding why this is called here
        debugMsgT(sProcName, "calling setTVGDisplayLocation(" + nTVGIndex + ")")
        setTVGDisplayLocation(nTVGIndex)
        
        ; Added 5Apr2025 to improve playback performance, following emails with Michel of Datastead.
        ; My tests of the Alaska video were not running smoothly with TVG 16.1.1... but were smooth with 15.4.1.8.
        ; Apparently the default video renderer priority was vrp_Speed in 15.4.1.8 and earlier versions, but had been changed to vrp_Quality in some later verion.
        ; Forcing this back to vrp_Speed fixed the playback problem.
        debugMsgT(sProcName, "calling TVG_SetVideoRendererPriority(" + sHandle + ", #tvc_vrp_Speed)")
        TVG_SetVideoRendererPriority(nHandle, #tvc_vrp_Speed)
        ; End added 5Apr2025
        
        ; INFO TVG Open Player
        gaTVG(nTVGIndex)\bClosePlayerRequested = #False
        gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #False
        If bUsingMemoryImage = #False
          If (qStartPos > 0) Or (qEndPos > 0)
            ; NB see comment above about not setting qEndPos !!!!!!!!!!!!!!
            debugMsgT(sProcName, "calling TVG_OpenPlayerAtTimePositions(" + sHandle + ", " + qStartPos + ", " + qEndPos + ", #tvc_true, #tvc_false)")
            nOpenPlayerResult = TVG_OpenPlayerAtTimePositions(nHandle, qStartPos, qEndPos, #tvc_true, #tvc_false)
            debugMsgT(sProcName, "TVG_OpenPlayerAtTimePositions(" + sHandle + ", " + qStartPos + ", " + qEndPos + ", #tvc_true, #tvc_false) returned " + strB(nOpenPlayerResult))
          Else
            debugMsgT(sProcName, "calling TVG_OpenPlayer(" + sHandle + ")")
            nOpenPlayerResult = TVG_OpenPlayer(nHandle)
            debugMsgT(sProcName, "TVG_OpenPlayer(" + sHandle + ") returned " + strB(nOpenPlayerResult))
          EndIf
        EndIf
        
        ; Added 8Jun2020 11.8.3.1
        ; See 'Important Information' in procedure setTVGDisplayLocation() regarding why this is called here
        ; debugMsgT(sProcName, "calling setTVGDisplayLocation(" + nTVGIndex + ")")
        setTVGDisplayLocation(nTVGIndex)
        ; End added 8Jun2020 11.8.3.1

        ; added 8May2020 11.8.3rc3
        ; NOTE IMPORTANT: hideTVGWindowIcons() is necessary or TVG DisplayMonitor windows will be independent windows, resulting in an icon appearing in the task bar
        ; for every such display. BUT, it is essentail to call everything to do with setting up the winodw BEFORE calling TVG_OpenPlayer(), and then to call hideTVGWindowIcons().
        ; Failure to follow this procedure may cause TVG to create a new window which will not be handled by a subsequent call to hideTVGWindowIcons(), and that will result
        ; in the window icons in the task bar.
        ; It took a lot of frustrating work to get this right! The test program used in the experimentation was TVG_Test_SetDisplayMonitor.pb.
        debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
        hideTVGWindowIcons(nTVGIndex)
        ; end added 8May2020 11.8.3rc3
        
        If (nOpenPlayerResult = 0) And (bUsingMemoryImage = #False)
          \bTVG_OpenPlayerFailed = #True
          If \nFileFormat = #SCS_FILEFORMAT_VIDEO
            ; debugMsg(sProcName, "calling check_FFDSHOW_or_LAV_installed(" + getAudLabel(pAudPtr) + ")")
            check_FFDSHOW_or_LAV_installed(pAudPtr)
          EndIf
        Else
          \bTVG_OpenPlayerFailed = #False
          nChannel = grTVGControl\nNextTVGNo
          grTVGControl\nNextTVGNo + 1
          *VideoCodec = TVG_GetVideoCodec(nHandle)
          If *VideoCodec
            sKeyEvent + ", VideoCodec=" + PeekS(*VideoCodec)
          EndIf
          *AudioCodec = TVG_GetAudioCodec(nHandle)
          If *AudioCodec
            sKeyEvent + ", AudioCodec=" + PeekS(*AudioCodec)
          EndIf
          logKeyEvent(sKeyEvent)
          
          If \nFileFormat = #SCS_FILEFORMAT_VIDEO
            ; debugMsg(sProcName, "calling checkCodecs(" + getAudLabel(pAudPtr) + ", " + nTVGIndex + ")")
            checkCodecs(pAudPtr, nTVGIndex)
          EndIf
          
          \nAlphaBlend = 255
          
          If bUsingMemoryImage
            qDuration = 0
          Else
            qDuration = TVG_GetPlayerDuration(nHandle)
            debugMsgT(sProcName, "TVG_GetPlayerDuration(" + sHandle + ") returned " + qDuration)
          EndIf
          grVideoInfo\nLength = qDuration / 10000
          
          If FrameCount <= 1
            gaTVG(nTVGIndex)\bStillImage = #True
            If (\bContinuous = #False) And (\nAbsEndAt > 0)
              grVideoInfo\nLength = \nAbsEndAt
            EndIf
          Else
            gaTVG(nTVGIndex)\bStillImage = #False
          EndIf
          
          listTVGControls()
          
        EndIf
        
        If nChannel = 0
          grMMedia\nStreamCreateError = 1
          Select pVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              \nMainTVGIndex = grAudDef\nMainTVGIndex
            Case #SCS_VID_PIC_TARGET_P
              \nPreviewTVGIndex = grAudDef\nPreviewTVGIndex
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPreviewTVGIndex=" + aAud(pAudPtr)\nPreviewTVGIndex)
          EndSelect
        Else
          grMMedia\nStreamCreateError = 0
          \nAudState = #SCS_CUE_READY
          Select pVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              \nMainTVGIndex = nTVGIndex
            Case #SCS_VID_PIC_TARGET_P
              \nPreviewTVGIndex = nTVGIndex
              debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPreviewTVGIndex=" + aAud(pAudPtr)\nPreviewTVGIndex)
          EndSelect
        EndIf
        debugMsg(sProcName, "nChannel=" + nChannel + ", \nAudState=" + decodeCueState(\nAudState) + ", nTVGIndex=" + nTVGIndex + ", \nMainTVGIndex=" + \nMainTVGIndex + ", \nPreviewTVGIndex=" + \nPreviewTVGIndex)
        gaTVG(nTVGIndex)\nChannel = nChannel
        
      EndIf
      
    EndWith
    
    ; Deleted 25Apr2024 11.10.2cf as cue markers in video cues are now handled exclusively by eventTVGOnFrameProgress2() and MarkerTVGSyncProc()
    ;  debugMsg(sProcName, "calling setNextCueMarker(" + getAudLabel(pAudPtr) + ", 0)")
    ;  setNextCueMarker(pAudPtr, 0)
    
    If GetActiveWindow() <> nCurrActiveWindow
      If IsWindow(nCurrActiveWindow)
        ; debugMsgT(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(" + decodeWindow(nCurrActiveWindow) + ")")
        SAW(nCurrActiveWindow)
      EndIf
    EndIf
    
  EndIf
  
  debugMsgT(sProcName, #SCS_END + ", returning nChannel=" + nChannel + ", time in openVideoFileForTVG(): " + Str(ElapsedMilliseconds() - qTimeStarted) + " milliseconds")
  ProcedureReturn nChannel
  
EndProcedure

Procedure openVideoCaptureDevForTVG(pAudPtr, pVidPicTarget)
  PROCNAME(buildAudProcName(#PB_Compiler_Procedure, pAudPtr) + "[" + decodeVidPicTarget(pVidPicTarget) + "]")
  Protected nSubPtr
  Protected nTVGIndex
  Protected sCaptureDev.s
  Protected bDualDisplayActive
  Protected nLongResult.l
  Protected nOpenPlayerResult.l
  Protected nPhysicalDevPtr, nDevId
  Protected nChannel
  Protected nCurrActiveWindow
  Protected nDevMapDevPtr
  Protected nHandle.i, sHandle.s
  
  debugMsgT(sProcName, #SCS_START)
  
  If pAudPtr >= 0
    
    nCurrActiveWindow = GetActiveWindow()
    
    If pVidPicTarget > gnMaxVidPicTargetSetup
      debugMsg(sProcName, "calling setVidPicTargets()")
      setVidPicTargets()
    EndIf
    
    With aAud(pAudPtr)
      
      \nVideoPlaybackLibrary = grVideoDriver\nVideoPlaybackLibrary
      debugMsg(sProcName, "\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(\nVideoPlaybackLibrary))
      
      nSubPtr = \nSubIndex
      nTVGIndex = assignTVGControl(nSubPtr, pAudPtr, pVidPicTarget)
      debugMsgT(sProcName, "assignTVGControl(" + getSubLabel(nSubPtr) + ", " + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ") returned " + nTVGIndex)
      If nTVGIndex >= 0
        nHandle = *gmVideoGrabber(nTVGIndex)
        sHandle = decodeHandle(nHandle)
        
        setTVGCaptureSize(pAudPtr, nHandle, pVidPicTarget)
        
        bDualDisplayActive = gaTVG(nTVGIndex)\bDualDisplayActive
        ; aspect ratio
        Select \nAspectRatioType
          Case #SCS_ART_FULL
            TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Stretch)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 0, #tvc_ar_Stretch)")
            If bDualDisplayActive
              TVG_SetDisplayAspectRatio(nHandle, 1, #tvc_ar_Stretch)
              debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 1, #tvc_ar_Stretch)")
            EndIf
          Default
            TVG_SetDisplayAspectRatio(nHandle, 0, #tvc_ar_Box)
            debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 0, #tvc_ar_Box)")
            If bDualDisplayActive
              TVG_SetDisplayAspectRatio(nHandle, 1, #tvc_ar_Box)
              debugMsgT(sProcName, "TVG_SetDisplayAspectRatio(" + sHandle + ", 1, #tvc_ar_Box)")
            EndIf
        EndSelect
        
        TVG_SetMuteAudioRendering(nHandle, #tvc_true)
        debugMsgT(sProcName, "TVG_SetMuteAudioRendering(" + sHandle + ", #tvc_true)")
        
        TVG_SetFrameGrabber(nHandle, #tvc_fg_Disabled)
        debugMsgT(sProcName, "TVG_SetFrameGrabber(" + sHandle + ", #tvc_fg_Disabled)")
        
        TVG_SetVideoSource(nHandle, #tvc_vs_VideoCaptureDevice)
        debugMsgT(sProcName, "TVG_SetVideoSource(" + sHandle + ", #tvc_vs_VideoCaptureDevice)")
        nPhysicalDevPtr = getPhysDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_CAPTURE, \sVideoCaptureLogicalDevice)
        If nPhysicalDevPtr >= 0
          TVG_SetVideoDevice(nHandle, nPhysicalDevPtr)
          debugMsgT(sProcName, "TVG_SetVideoDevice(" + sHandle + ", " + nPhysicalDevPtr + ")")
        EndIf
        
        TVG_SetDroppedFramesPollingInterval(nHandle, 0) ; disables the polling of dropped frames (recommended to save CPU, but only relevant for video capture devices, eg webcam)
        debugMsgT(sProcName, "TVG_SetDroppedFramesPollingInterval(" + sHandle + ", 0)")
        
        debugMsgT(sProcName, "calling setTVGDisplayLocation(" + sHandle + ")")
        setTVGDisplayLocation(nTVGIndex)
        
        setTVGCaptureSize(pAudPtr, nHandle, pVidPicTarget)
        If pVidPicTarget = #SCS_VID_PIC_TARGET_P
          setTVGCroppingData(pAudPtr, nTVGIndex, #True)
        Else
          setTVGCroppingData(pAudPtr, nTVGIndex, #False)
        EndIf
        
      EndIf
      
      grMMedia\nStreamCreateError = 0
      \nAudState = #SCS_CUE_READY
      \nFileState = #SCS_FILESTATE_OPEN
      setCueState(\nCueIndex)
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          \nMainTVGIndex = nTVGIndex
        Case #SCS_VID_PIC_TARGET_P
          \nPreviewTVGIndex = nTVGIndex
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nPreviewTVGIndex=" + aAud(pAudPtr)\nPreviewTVGIndex)
      EndSelect
      
    EndIf
    
  EndWith
  
  If GetActiveWindow() <> nCurrActiveWindow
    If IsWindow(nCurrActiveWindow)
      debugMsgT(sProcName, "GetActiveWindow()=" + decodeWindow(GetActiveWindow()) + ", calling SetActiveWindow(" + decodeWindow(nCurrActiveWindow) + ")")
      SAW(nCurrActiveWindow)
    EndIf
  EndIf
  
  debugMsgT(sProcName, #SCS_END + ", returning nPhysicalDevPtr=" + nPhysicalDevPtr)
  ProcedureReturn nPhysicalDevPtr
  
EndProcedure

Procedure windowOnTop(nTVGIndex)
  PROCNAMEC()
  Protected nWindowHandle
  Protected nVidPicTarget
  Protected n, bReqdTopMostState
  Static nZOrder
  
  debugMsg(sProcName, #SCS_START + ", nTVGIndex=" + nTVGIndex)
  
  nWindowHandle = TVG_GetDisplayVideoWindowHandle(*gmVideoGrabber(nTVGIndex), 0)
  debugMsgT2(sProcName, "TVG_GetDisplayVideoWindowHandle(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", 0)", nWindowHandle)
  If nWindowHandle
    SetWindowPos_(nWindowHandle, #HWND_TOP,0,0,0,0,#SWP_NOACTIVATE|#SWP_NOMOVE|#SWP_NOSIZE)
    debugMsg(sProcName, "SetWindowPos_(" + nWindowHandle + ", #HWND_TOP,0,0,0,0,#SWP_NOACTIVATE|#SWP_NOMOVE|#SWP_NOSIZE)")
    nWindowHandle = TVG_GetDisplayVideoWindowHandle(*gmVideoGrabber(nTVGIndex), 1)
    debugMsgT2(sProcName, "TVG_GetDisplayVideoWindowHandle(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", 1)", nWindowHandle)
    If nWindowHandle
      SetWindowPos_(nWindowHandle, #HWND_TOP,0,0,0,0,#SWP_NOACTIVATE|#SWP_NOMOVE|#SWP_NOSIZE)
      debugMsg(sProcName, "SetWindowPos_(" + nWindowHandle + ", #HWND_TOP,0,0,0,0,#SWP_NOACTIVATE|#SWP_NOMOVE|#SWP_NOSIZE)")
    EndIf
    nZOrder + 1
    gaTVG(nTVGIndex)\nZOrder = nZOrder
    debugMsgT(sProcName, "gaTVG(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")\nZOrder=" + gaTVG(nTVGIndex)\nZOrder + ", \nVidPicTarget=" + decodeVidPicTarget(gaTVG(nTVGIndex)\nTVGVidPicTarget))
    nVidPicTarget = gaTVG(nTVGIndex)\nTVGVidPicTarget
    For n = 0 To grTVGControl\nMaxTVGIndex
      With gaTVG(n)
        If \nTVGVidPicTarget = nVidPicTarget
          If n = nTVGIndex
            bReqdTopMostState = #True
          Else
            bReqdTopMostState = #False
          EndIf
          If \bTopMostWindowForTarget <> bReqdTopMostState
            \bTopMostWindowForTarget = bReqdTopMostState
            debugMsg(sProcName, "(T) gaTVG(" + decodeHandle(*gmVideoGrabber(n)) + ")\nTVGVidPicTarget=" + decodeVidPicTarget(\nTVGVidPicTarget) + ", \bTopMostWindowForTarget=" + strB(\bTopMostWindowForTarget))
          EndIf
        Else
          debugMsg(sProcName, "(F) gaTVG(" + decodeHandle(*gmVideoGrabber(n)) + ")\nTVGVidPicTarget=" + decodeVidPicTarget(\nTVGVidPicTarget) + ", \bTopMostWindowForTarget=" + strB(\bTopMostWindowForTarget))
        EndIf
      EndWith
    Next n
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure hideOneWindowIcon(WindowHandle, NewParentWindowHandle)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START + ", WindowHandle=" + WindowHandle + ", NewParentWindowHandle=" + NewParentWindowHandle)
  ShowWindow_(WindowHandle, #SW_HIDE)
  debugMsg(sProcName, "ShowWindow_(" + WindowHandle + ", #SW_HIDE)")
  SetWindowLongPtr_(WindowHandle, #GWL_HWNDPARENT, NewParentWindowHandle)
  debugMsg(sProcName, "SetWindowLongPtr_(" + WindowHandle + ", #GWL_HWNDPARENT, " + NewParentWindowHandle + ")")
  ShowWindow_(WindowHandle, #SW_SHOW)
  debugMsg(sProcName, "ShowWindow_(" + WindowHandle + ", #SW_SHOW)")
EndProcedure

Procedure hideTVGWindowIcons(nTVGIndex)
  PROCNAMEC()
  Protected nHandle.i, sHandle.s
  Protected nDisplayIndex.l, nWindowHandle, nParentWindow, nParentWindowHandle
  Protected nSubPtr, sScreens.s, nScreenIndex, sScreenNo.s
  
  nHandle = *gmVideoGrabber(nTVGIndex)
  sHandle = decodeHandle(nHandle)
  
  nSubPtr = gaTVG(nTVGIndex)\nTVGSubPtr
  If nSubPtr >= 0
    sScreens = aSub(nSubPtr)\sScreens
  EndIf
  
  For nDisplayIndex = 0 To 8
    nWindowHandle = TVG_GetDisplayVideoWindowHandle(nHandle, nDisplayIndex)
    If nWindowHandle
      debugMsg2(sProcName, "TVG_GetDisplayVideoWindowHandle(" + sHandle + ", " + nDisplayIndex + ")", nWindowHandle)
      Select nDisplayIndex
        Case 0
          nParentWindow = gaTVG(nTVGIndex)\nMainWindowNo
        Case 1
          nParentWindow = gaTVG(nTVGIndex)\nMonitorWindowNo
        Default
          nScreenIndex = nDisplayIndex
          sScreenNo = Trim(StringField(sScreens, nScreenIndex, ","))
          If sScreenNo
            nParentWindow = #WV2 + Val(sScreenNo) - 2
          EndIf
      EndSelect
      debugMsg(sProcName, "nDisplayIndex=" + nDisplayIndex + ", nParentWindow=" + decodeWindow(nParentWindow))
      If IsWindow(nParentWindow) = 0
        If gbEditing And IsWindow(#WED)
          nParentWindow = #WED
        ElseIf IsWindow(#WMN)
          nParentWindow = #WMN
        EndIf
        debugMsg(sProcName, "nParentWindow=" + decodeWindow(nParentWindow))
      EndIf
      If IsWindow(nParentWindow)
        nParentWindowHandle = WindowID(nParentWindow)
        debugMsg2(sProcName, "WindowID(" + decodeWindow(nParentWindow) + ")", nParentWindowHandle)
        hideOneWindowIcon(nWindowHandle, nParentWindowHandle)
      EndIf
    EndIf
  Next nDisplayIndex
  
EndProcedure

Procedure playTVGVideo(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex
  Protected nMonitorWindowNo, nOutputWindowNo
  Protected nPlayerState
  Protected nLongResult.l
  Protected bStartedInEditor
  Protected qStartPos.q
  Protected nHandle.i, sHandle.s, nDisplayIndex.l
  Protected nAlphaBlendValue.l
  Protected bOpenFile, bUsingMemoryImage, bDeferSetVisible
  Protected qCurrPos.q ; 24Nov2020
  Protected nActiveWindow
  CompilerIf #c_tvg_onrawaudiosample
    Protected nBassResult.l
  CompilerEndIf
  
  debugMsgT(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  ; Added 12Dec2020 11.8.3.3aw following bug report from Stuart Barry
  nActiveWindow = GetActiveWindow()
  ; debugMsg0(sProcName, "(a) nActiveWindow=" + decodeWindow(nActiveWindow))
  ; End added 12Dec2020 11.8.3.3aw
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      bStartedInEditor = aSub(\nSubIndex)\bStartedInEditor
      nTVGIndex = -1
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          debugMsg(sProcName, "\nMainTVGIndex=" + \nMainTVGIndex)
          nTVGIndex = \nMainTVGIndex
          ; Added 13Nov2020 11.8.3.3ag
          If grMMedia\bInPlayCue
            bDeferSetVisible = #True ; See comments near the end of this procedure.
          EndIf
          ; End added 13Nov2020 11.8.3.3ag
        Case #SCS_VID_PIC_TARGET_P
          debugMsg(sProcName, "\nPreviewTVGIndex=" + \nPreviewTVGIndex)
          nTVGIndex = \nPreviewTVGIndex
      EndSelect
      If nTVGIndex >= 0
        If gaTVG(nTVGIndex)\bAssigned = #False
          debugMsg(sProcName, "setting bOpenFile=#True because gaTVG(" + nTVGIndex + ")\bAssigned=#False")
          bOpenFile = #True
        ElseIf gaTVG(nTVGIndex)\nTVGAudPtr <> pAudPtr
          debugMsg(sProcName, "setting bOpenFile=#True because gaTVG(" + nTVGIndex + ")\nAudPtr=" + getAudLabel(gaTVG(nTVGIndex)\nTVGAudPtr))
          bOpenFile = #True
        EndIf
      Else
        debugMsg(sProcName, "setting bOpenFile=#True because nTVGIndex=" + nTVGIndex)
        bOpenFile = #True
      EndIf
      If bOpenFile
        debugMsg(sProcName, "calling openVideoFileForTVG(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ")")
        openVideoFileForTVG(pAudPtr, pVidPicTarget)
        Select pVidPicTarget
          Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
            debugMsg(sProcName,"\nMainVideoNo=" + \nMainVideoNo + ", \nMainTVGIndex=" + \nMainTVGIndex)
            \nPlayVideoNo = \nMainVideoNo
            \nPlayTVGIndex = \nMainTVGIndex
            nTVGIndex = \nMainTVGIndex
          Case #SCS_VID_PIC_TARGET_P
            debugMsg(sProcName, "\nPreviewVideoNo=" + \nPreviewVideoNo + ", \nPreviewTVGIndex=" + \nPreviewTVGIndex)
            \nPlayVideoNo = \nPreviewVideoNo
            \nPlayTVGIndex = \nPreviewTVGIndex
            nTVGIndex = \nPreviewTVGIndex
        EndSelect
      EndIf
      If nTVGIndex >= 0
        debugMsgT(sProcName, "\nFadeInTime=" + \nFadeInTime + ", \nCurrFadeInTime=" + \nCurrFadeInTime + ", gaTVG(" + nTVGIndex + ")\bDualDisplayActive=" + strB(gaTVG(nTVGIndex)\bDualDisplayActive))
        nHandle = *gmVideoGrabber(nTVGIndex)
        debugMsg(sProcName, "nTVGIndex=" + nTVGIndex + ", nHandle=" + nHandle)
        If nHandle = 0
          ; re-create control
          nTVGIndex = createTVGControl(pVidPicTarget, #SCS_VID_SRC_FILE, #False, nTVGIndex)
          nHandle = *gmVideoGrabber(nTVGIndex)
          debugMsg(sProcName, "nTVGIndex=" + nTVGIndex + ", nHandle=" + nHandle)
          ; Added 2Apr2020 11.8.2.3aj
          debugMsg(sProcName, "calling openVideoFileForTVG(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ", " + nTVGIndex + ")")
          openVideoFileForTVG(pAudPtr, pVidPicTarget, nTVGIndex)
          ; End added 2Apr2020 11.8.2.3aj
        EndIf
        sHandle = decodeHandle(nHandle)
        If \nCurrFadeInTime > 0
          ; if fade-in time present then ensure image is hidden BEFORE calling RunPlayer()
          nAlphaBlendValue = TVG_GetDisplayAlphaBlendValue(nHandle, 0)
          debugMsgT2(sProcName, "TVG_GetDisplayAlphaBlendValue(" + sHandle + ", 0)", nAlphaBlendValue)
          If nAlphaBlendValue <> 0
            TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
            If gaTVG(nTVGIndex)\bDualDisplayActive
              TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
              debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
            EndIf
            For nDisplayIndex = 2 To 8
              If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
                debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
              EndIf
            Next nDisplayIndex
          EndIf
        EndIf
        
        If \bUsingMemoryImage = #False
;           qCurrPos = TVG_GetPlayerTimePosition(nHandle)
;           debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ") returned " + qCurrPos)
          nPlayerState = TVG_GetPlayerState(nHandle)
          debugMsgT(sProcName, "TVG_GetPlayerState(" + sHandle + ")=" + decodeTVGPlayerState(nPlayerState))
;           qCurrPos = TVG_GetPlayerTimePosition(nHandle)
;           debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ") returned " + qCurrPos)
          If nPlayerState = #tvc_ps_Closed
            ; nb shouldn't get here but did during early testing before deferring clearing some freeTVGControl() action until the player status changed to 'stopped'
            gaTVG(nTVGIndex)\bClosePlayerRequested = #False
            gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #False
            debugMsgT(sProcName, "calling TVG_OpenPlayer(" + sHandle + ")")
            nLongResult = TVG_OpenPlayer(nHandle)
            debugMsgT(sProcName, "TVG_OpenPlayer(" + sHandle + ") returned " + strB(nLongResult))
            ; added 8May2020 11.8.3rc3
            debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
            hideTVGWindowIcons(nTVGIndex)
            ; end added 8May2020 11.8.3rc3
            nPlayerState = TVG_GetPlayerState(nHandle)
            debugMsgT(sProcName, "TVG_GetPlayerState(" + sHandle + ")=" + decodeTVGPlayerState(nPlayerState))
          EndIf
        EndIf
        
        If gaTVG(nTVGIndex)\nTVGVidPicTarget = #SCS_VID_PIC_TARGET_P
          debugMsgT(sProcName, "calling setTVGDisplayLocation(" + sHandle + ")")
          setTVGDisplayLocation(nTVGIndex)
        EndIf
        
        For nDisplayIndex = 0 To 8
          If TVG_GetDisplayActive(nHandle, nDisplayIndex)
            TVG_SetDisplayStayOnTop(nHandle, nDisplayIndex, #tvc_true)
            debugMsgT(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
          EndIf
        Next nDisplayIndex
        
        CompilerIf #c_tvg_onrawaudiosample
          nBassResult = BASS_Mixer_ChannelFlags(\nVideoASIOStream, 0, #BASS_MIXER_CHAN_PAUSE) ; remove the pause flag
          debugMsg3(sProcName, "BASS_Mixer_ChannelFlags(" + decodeHandle(\nVideoASIOStream) + ", 0, BASS_MIXER_CHAN_PAUSE) returned " + decodeMixerChannelFlags(nBassResult))
        CompilerEndIf
        
        debugMsgT(sProcName, "TVG_GetAudioFormat(" + sHandle + ")=" + TVG_GetAudioFormat(nHandle))
        
        ; NOTE: Call TVG_RunPlayer() (or TVG_StartPreview()) BEFORE setting alpha blend value
        If \bUsingMemoryImage
          nLongResult = TVG_StartPreview(nHandle) ; INFO TVG_StartPreview(nHandle)
          debugMsgT(sProcName, "TVG_StartPreview(" + sHandle + ") returned " + strB(nLongResult))
          ; Added 19Oct2020 11.8.3.2bx
          debugMsg(sProcName, "calling setTVGDisplayLocation(" + nTVGIndex + ")")
          setTVGDisplayLocation(nTVGIndex)
          ; End added 19Oct2020 11.8.3.2bx
          ; When using TVG_StartPreview, hiding the window icons must be called AFTER TVG_StartPreview()
          debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
          hideTVGWindowIcons(nTVGIndex)
        Else
          TVG_RunPlayer(nHandle) ; INFO TVG_RunPlayer(nHandle)
          debugMsgT(sProcName, "TVG_RunPlayer(" + sHandle + ")")
        EndIf
        
        If (\nCurrFadeInTime > 0) And (\bTimeFadeInStartedSet = #False)
          \qTimeFadeInStarted = ElapsedMilliseconds()
          \bTimeFadeInStartedSet = #True
          \nCuePosAtFadeStart = \nCuePos
        EndIf
        
        If \nCurrFadeInTime <= 0
          ; if fade-in time not present then fully display image immediately AFTER calling RunPlayer()
          ; (don't do this PRIOR to calling RunPlayer() as that could cause a very brief freeze of the image before playback)
          ; NOTE: equivalent code is in eventTVGOnPlayerStateChanged(), so if any of the code in this If/EndIf section is changed
          ; NOTE: then the corresponding code in eventTVGOnPlayerStateChanged() may also need to be changed
          TVG_SetDisplayAlphaBlendValue(nHandle, 0, 255)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 255)")
          If gaTVG(nTVGIndex)\bDualDisplayActive
            TVG_SetDisplayAlphaBlendValue(nHandle, 1, 255)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 255)")
          EndIf
          For nDisplayIndex = 2 To 8
            If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
              TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 255)
              debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 255)")
            EndIf
          Next nDisplayIndex
        EndIf
        
        debugMsg(sProcName, "calling adjustVidAudPlayingCount(" + getSubLabel(gaTVG(nTVGIndex)\nTVGSubPtr) + ", 1)")
        adjustVidAudPlayingCount(gaTVG(nTVGIndex)\nTVGSubPtr, 1)
        
        ; setTVGWindowsVisibleAsReqd(pAudPtr, pVidPicTarget) ; Replaced 13Nov2020 11.8.3.3ag with the following:
        ; Added 13Nov2020 11.8.3.3ag
        ; Defering calling setTVGWindowsVisibleAsReqd() until the final processing in playCue() was added following emails and logs from Rainer Sch?n.
        ; Procedure setTVGWindowsVisibleAsReqd() calls windowOnTop() which calls the Windows function SetWindowPos(). In Rainer's tests, the log files
        ; show that SetWindowPos() takes about half-a-second on his machine, which meant that a subsequent Control Send sub-cue in that cue was delayed
        ; by that half-second. Defering the call to setTVGWindowsVisibleAsReqd() minimises the inter-sub-cue delays.
        If bDeferSetVisible
          \bCallSetWindowVisible = #True
          aCue(\nCueIndex)\bCallSetWindowVisible = #True
          ; debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bCallSetWindowVisible=" + strB(\bCallSetWindowVisible) + ", aCue(" + getCueLabel(\nCueIndex) + ")\bCallSetWindowVisible=" + strB(aCue(\nCueIndex)\bCallSetWindowVisible))
        Else
          setTVGWindowsVisibleAsReqd(pAudPtr, pVidPicTarget)
        EndIf
        ; End added 13Nov2020 11.8.3.3ag
        
        qCurrPos = TVG_GetPlayerTimePosition(nHandle)
        debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ") returned " + qCurrPos)
      EndIf
    EndWith
  EndIf
  
  ; Added 12Dec2020 11.8.3.3aw following bug report from Stuart Barry
  ; debugMsg0(sProcName, "(z) GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  If GetActiveWindow() = -1
    If IsWindow(nActiveWindow)
      SAW(nActiveWindow)
    EndIf
  EndIf
  ; End added 12Dec2020 11.8.3.3aw following bug report from Stuart Barry
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure setTVGWindowsVisibleAsReqd(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex
  Protected nMonitorWindowNo, nOutputWindowNo
  Protected bStartedInEditor
  Protected nHandle.i, sHandle.s
  Protected nDisplayIndex.l
  
  debugMsgT(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      bStartedInEditor = aSub(\nSubIndex)\bStartedInEditor
      nTVGIndex = -1
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          nTVGIndex = \nMainTVGIndex
        Case #SCS_VID_PIC_TARGET_P
          nTVGIndex = \nPreviewTVGIndex
      EndSelect
      If nTVGIndex >= 0
        
        windowOnTop(nTVGIndex)
        
        If gaTVG(nTVGIndex)\bDualDisplayActive
          Select gaTVG(nTVGIndex)\nTVGVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
              nMonitorWindowNo = gaTVG(nTVGIndex)\nMonitorWindowNo
              If IsWindow(nMonitorWindowNo)
                If getWindowVisible(nMonitorWindowNo) = #False
                  setWindowVisible(nMonitorWindowNo, #True)
                EndIf
              EndIf
            Case #SCS_VID_PIC_TARGET_P
              nOutputWindowNo = #WV2 + gaTVG(nTVGIndex)\nOutputScreen - 2
              If IsWindow(nOutputWindowNo)
                If getWindowVisible(nOutputWindowNo) = #False
                  setWindowVisible(nOutputWindowNo, #True)
                EndIf
              EndIf
          EndSelect
        Else
          Select gaTVG(nTVGIndex)\nTVGVidPicTarget
            Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST, #SCS_VID_PIC_TARGET_P
              nOutputWindowNo = #WV2 + gaTVG(nTVGIndex)\nOutputScreen - 2
              ; debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nOutputScreen=" + gaTVG(nTVGIndex)\nOutputScreen + ", nOutputWindowNo=" + decodeWindow(nOutputWindowNo))
              If IsWindow(nOutputWindowNo)
                If getWindowVisible(nOutputWindowNo) = #False
                  ; debugMsg(sProcName, "IsWindow(" + decodeWindow(nOutputWindowNo) + ")=#True")
                  setWindowVisible(nOutputWindowNo, #True)
                EndIf
              Else
                debugMsg(sProcName, "IsWindow(" + decodeWindow(nOutputWindowNo) + ")=#False")
              EndIf
              ; debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\nMonitorWindowNo=" + gaTVG(nTVGIndex)\nMonitorWindowNo)
          EndSelect
        EndIf
        
        ; Added 10Jun2020 11.8.2.3aa
        nHandle = *gmVideoGrabber(nTVGIndex)
        If nHandle ; Test added 14Mar2022 11.9.1an following test of Rob Gooch's "Selfish Giant screening.scs11" which crashed on trying to play the last still image cue, which was (incorrectly) set to start 0.00 seconds after the START of the previous video cue
          sHandle = decodeHandle(nHandle)
          For nDisplayIndex = 0 To 8
            If TVG_GetDisplayActive(nHandle, nDisplayIndex)
              If TVG_GetDisplayStayOnTop(nHandle, nDisplayIndex) = #tvc_false
                TVG_SetDisplayStayOnTop(nHandle, nDisplayIndex, #tvc_true)
                debugMsgT(sProcName, "TVG_SetDisplayStayOnTop(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
              EndIf
            EndIf
          Next nDisplayIndex
        EndIf
        ; End added 10Jun2020 11.8.2.3aa
        
        If bStartedInEditor
          If IsWindow(#WED)
            setWindowSticky(#WED, #True)
          EndIf
        EndIf
        
      EndIf
    EndWith
  EndIf
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure getPlayerIndex(*Sender)
  Protected nTVGIndex = -1
  Protected n
  
  If *Sender
    For n = 0 To grTVGControl\nMaxTVGIndex
      If *gmVideoGrabber(n) = *Sender
        nTVGIndex = n
        Break
      EndIf
    Next n
  EndIf
  ProcedureReturn nTVGIndex
EndProcedure

Procedure getTVGIndexForAud(pAudPtr, pVidPicTarget)
  PROCNAMEC()
  Protected nTVGIndex = -1
  
  If pAudPtr >= 0
    With aAud(pAudPtr)
      Select pVidPicTarget
        Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
          nTVGIndex = \nMainTVGIndex
        Case #SCS_VID_PIC_TARGET_P
          nTVGIndex = \nPreviewTVGIndex
      EndSelect
    EndWith
  EndIf
  
  ; Added 8Apr2020 11.8.2.3an following bug reports from Theo Anderson where TVG controls were accessed after being freed, resulting in a memory error
  If nTVGIndex >= 0
    If *gmVideoGrabber(nTVGIndex) = 0
      nTVGIndex = -1
    EndIf
  EndIf
  ; End added 8Apr2020 11.8.2.3an
  
  ProcedureReturn nTVGIndex
  
EndProcedure

Procedure getTVGIndexForHighestZOrder(pVidPicTarget)
  PROCNAMEC()
  Protected nZOrder, nTVGIndex
  Protected nReqdTVGIndex
  
  nReqdTVGIndex = -1
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    With gaTVG(nTVGIndex)
      If (\nTVGVidPicTarget = pVidPicTarget) And (\nTVGAudPtr >= 0) And (\nTVGVideoSource = #SCS_VID_SRC_FILE)
        If *gmVideoGrabber(nTVGIndex) <> 0 ; This test added 8Apr2020 11.8.2.3an - see comments of this date in getTVGIndexForAud()
          If \nZOrder > nZOrder
            nZOrder = \nZOrder
            nReqdTVGIndex = nTVGIndex
          EndIf
        EndIf
      EndIf
    EndWith
  Next nTVGIndex
  ProcedureReturn nReqdTVGIndex
EndProcedure

Procedure getTVGIndexForCapture(pVidPicTarget)
  PROCNAMEC()
  Protected nTVGIndex
  Protected nReqdTVGIndex
  
  nReqdTVGIndex = -1
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    With gaTVG(nTVGIndex)
      If (\nTVGVidPicTarget = pVidPicTarget) And (\nTVGVideoSource = #SCS_VID_SRC_CAPTURE)
        If *gmVideoGrabber(nTVGIndex) <> 0 ; This test added 8Apr2020 11.8.2.3an - see comments of this date in getTVGIndexForAud()
          nReqdTVGIndex = nTVGIndex
          Break
        EndIf
      EndIf
    EndWith
  Next nTVGIndex
  ProcedureReturn nReqdTVGIndex
EndProcedure

Procedure stopTVGVideo(nTVGIndex, bCallStopAud)
  PROCNAMEC()
  Protected nAudPtr, nSubPtr, bUsingMemoryImage, nLongResult.l
  Protected nWindowHandle
  Protected nHandle.i, sHandle.s
  Protected nDisplayIndex
  Protected sBlankString.s = ""
  
  debugMsgT(sProcName, #SCS_START)
  
  If nTVGIndex >= 0
    With gaTVG(nTVGIndex)
      nHandle = *gmVideoGrabber(nTVGIndex)
      nAudPtr = \nTVGAudPtr
      nSubPtr = \nTVGSubPtr
      If nHandle <> 0 ; Added 8Apr2020 11.8.2.3an
        sHandle = decodeHandle(nHandle)
        If nAudPtr >= 0
          bUsingMemoryImage = aAud(nAudPtr)\bUsingMemoryImage
        EndIf
        If bUsingMemoryImage
          debugMsgT(sProcName, "calling TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)")
          nLongResult = TVG_SendImageToVideoFromBitmaps(nHandle, @sBlankString, ImageID(aAud(nAudPtr)\nMemoryImageNo), #tvc_true, #tvc_true)
          debugMsgT(sProcName, "TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true) returned " + strB(nLongResult))
          debugMsgT(sProcName, "calling TVG_StopPreview(" + sHandle + ")")
          TVG_StopPreview(nHandle)
          debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ")")
        Else
          debugMsgT(sProcName, "calling TVG_StopPlayer(" + sHandle + ")")
          TVG_StopPlayer(nHandle)
          debugMsgT(sProcName, "TVG_StopPlayer(" + sHandle + ")")
        EndIf
        TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
        If \bDualDisplayActive
          TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
        EndIf
        For nDisplayIndex = 2 To 8
          If \bDisplayIndexUsed(nDisplayIndex)
            TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
          EndIf
        Next nDisplayIndex
      EndWith
    EndIf
    
    If nAudPtr >= 0
      If bCallStopAud
        aAud(nAudPtr)\bPlayEndSyncOccurred = #True
        debugMsgT(sProcName, "calling stopAud(" + getAudLabel(nAudPtr) + ")")
        stopAud(nAudPtr)
      EndIf
    EndIf
  EndIf
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure isTVGPlaying()
  PROCNAMEC()
  Protected nTVGIndex
  Protected nPlayerState.l
  Protected bTVGsPlaying
  
  ; debugMsgT(sProcName, #SCS_START)
  
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    If *gmVideoGrabber(nTVGIndex)
      If gaTVG(nTVGIndex)\bAssigned
        nPlayerState = TVG_GetPlayerState(*gmVideoGrabber(nTVGIndex))
        ; debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ") returned " + decodeTVGPlayerState(nPlayerState))
        If nPlayerState = #tvc_ps_Playing
          ; nb only interested in 'playing' - not paused etc. (Also, SCS doesn't use states like 'playing backwards'.)
          ; debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")=" + decodeTVGPlayerState(nPlayerState))
          bTVGsPlaying = #True
          Break
        EndIf
      EndIf
    EndIf
  Next nTVGIndex
  
  grTVGControl\bTVGsPlaying = bTVGsPlaying
  
  debugMsgT(sProcName, #SCS_END + ", returning " + strB(bTVGsPlaying))
  ProcedureReturn bTVGsPlaying
  
EndProcedure

Procedure freeTVGControl(nTVGIndex, bForceClose=#False)
  PROCNAMEC()
  Protected nPlayerState.l
  Protected nAudPtr, nAudState, nFadeOutTime = -1, bUsingMemoryImage, nLongResult.l
  Protected bFreeThis = #True
  Protected nDisplayIndex.l
  Protected nHandle.i, sHandle.s
  Protected sBlankString.s = ""
  
  debugMsgT(sProcName, #SCS_START + ", nTVGIndex=" + nTVGIndex + ", bForceClose=" + strB(bForceClose))
  
  If nTVGIndex >= 0
    debugMsgT(sProcName, "gaTVG(" + nTVGIndex + ")\nVidPicTarget=" + decodeVidPicTarget(gaTVG(nTVGIndex)\nTVGVidPicTarget))
    nHandle = *gmVideoGrabber(nTVGIndex)
    If nHandle
      sHandle = decodeHandle(nHandle)
      nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
      If nAudPtr >= 0
        bUsingMemoryImage = aAud(nAudPtr)\bUsingMemoryImage
      EndIf
      If bUsingMemoryImage
        debugMsgT(sProcName, "calling TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)")
        nLongResult = TVG_SendImageToVideoFromBitmaps(nHandle, @sBlankString, ImageID(aAud(nAudPtr)\nMemoryImageNo), #tvc_true, #tvc_true)
        debugMsgT(sProcName, "TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true) returned " + strB(nLongResult))
        TVG_StopPreview(nHandle)
        debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ")")
        debugMsgT(sProcName, "calling TVG_DestroyVideoGrabber(" + sHandle + ")")
        TVG_DestroyVideoGrabber(nHandle)
        debugMsgT(sProcName, "TVG_DestroyVideoGrabber(" + sHandle + ")")
        nHandle = 0
        *gmVideoGrabber(nTVGIndex) = 0
      Else
        nPlayerState = TVG_GetPlayerState(nHandle)
        debugMsgT(sProcName, "TVG_GetPlayerState(" + sHandle + ")=" + decodeTVGPlayerState(nPlayerState))
        If nPlayerState <> #tvc_ps_Closed
          ; The followng code to defer closing was added in 11.5.2 in an attempt to provide smoother playback for Stas Ushomirsky's "Wolf and Kids",
          ; but subsequently found this 'fix' should not be applied if a video is playing on another screen (as discovered when running Q18 in demo2)
          ; so 22Nov2016 (11.5.2.4) have now added this extra test "If grVideoMonitors\nOutputScreenCount = 1"
          If grVideoMonitors\nOutputScreenCount = 1
            If (bForceClose = #False) And (isTVGPlaying())
              gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #True
              ; added 10Feb2017 11.6.0 as the 11.5.3 code can cause black to be displayed - again as tested using Stas Ushomirsky's "Wolf and Kids",
              If nAudPtr >= 0
                nAudState = aAud(nAudPtr)\nAudState
                debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(nAudState))
                If (nAudState >= #SCS_CUE_FADING_IN) And (nAudState <= #SCS_CUE_FADING_OUT)
                  bFreeThis = #False
                  If nAudState = #SCS_CUE_FADING_OUT
                    debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nFadeOutTime=" + aAud(nAudPtr)\nFadeOutTime + ", \nCurrFadeOutTime=" + aAud(nAudPtr)\nCurrFadeOutTime)
                    nFadeOutTime = aAud(nAudPtr)\nCurrFadeOutTime
                  EndIf
                EndIf
              EndIf
              ; end added 10Feb2017 11.6.0
              grTVGControl\bCloseTVGsWaiting = #True
              ; added 11Jan2017 11.5.3 following bug report from Jonathan Cesaroni about a faded-out video image remaining on the screen
              ; don't free control yet, but make image invisible
              ; modified 10Feb2017 11.6.0 as the 11.5.3 code can cause black to be displayed - again as tested using Stas Ushomirsky's "Wolf and Kids",
              If bFreeThis
                TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
                debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
                If gaTVG(nTVGIndex)\bDualDisplayActive
                  TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
                  debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
                EndIf
                For nDisplayIndex = 2 To 8
                  If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                    TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
                    debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
                  EndIf
                Next nDisplayIndex
                gaTVG(nTVGIndex)\bAssigned = #False
                debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\bAssigned=" + strB(gaTVG(nTVGIndex)\bAssigned) + ", handle=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", \nAudPtr=" + getAudLabel(gaTVG(nTVGIndex)\nTVGAudPtr) + "")
              ElseIf nFadeOutTime > 0
                samAddRequest(#SCS_SAM_FREE_TVG_CONTROL, nTVGIndex, 0, #True, "", (ElapsedMilliseconds() + nFadeOutTime))
              Else
                samAddRequest(#SCS_SAM_FREE_TVG_CONTROL, nTVGIndex, 0, #True, "", (ElapsedMilliseconds() + 50))
              EndIf
              ; end added 11Jan2017 11.5.3
              debugMsgT(sProcName, #SCS_END + ", returning #False")
              ProcedureReturn #False
            EndIf
          EndIf
          ; 4Mar2017 11.6.0 added code to hide the image as it may otherwise remain displayed if the 'pause at end' property was set, causing TVG's VisibleWhenStopped property to be set true
          TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
          If gaTVG(nTVGIndex)\bDualDisplayActive
            TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
          EndIf
          For nDisplayIndex = 2 To 8
            If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
              TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
              debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
            EndIf
          Next nDisplayIndex
          
        EndIf ; EndIf nPlayerState <> #tvc_ps_Closed ; INFO MOVED 14Jul2020 11.8.3.2am (moved from further down this procedure)
        
          ; end 4Mar2017 11.6.0 added code
          gaTVG(nTVGIndex)\bClosePlayerRequested = #True
          debugMsgT(sProcName, "calling TVG_ClosePlayer(" + sHandle + ")")
          TVG_ClosePlayer(nHandle)
          debugMsgT(sProcName, "TVG_ClosePlayer(" + sHandle + ")")
          nPlayerState = TVG_GetPlayerState(nHandle)
          debugMsgT(sProcName, "TVG_GetPlayerState(" + sHandle + ")=" + decodeTVGPlayerState(nPlayerState))
          ; 6Mar2017 11.6.0 add destroy control
          CompilerIf 1=1 ; INFO 13Feb2020 11.8.2.2al: 1=1 (was 1=2) ????????????????????????????????
            debugMsgT(sProcName, "calling TVG_DestroyVideoGrabber(" + sHandle + ")")
            TVG_DestroyVideoGrabber(nHandle)
            debugMsgT(sProcName, "TVG_DestroyVideoGrabber(" + sHandle + ")")
            nHandle = 0
            *gmVideoGrabber(nTVGIndex) = 0
            gaTVG(nTVGIndex)\bAssigned = #False ; Added 28Nov2022 11.9.7ap
          CompilerEndIf
          ; end 6Mar2017 11.6.0 added code
          ; gaTVG(nTVGIndex)\bAssigned = #False ; commented out 13Feb2020 11.8.2.2al INFO ??????????????????
          ; debugMsg(sProcName, "gaTVG(" + nTVGIndex + ")\bAssigned=" + strB(gaTVG(nTVGIndex)\bAssigned) + ", handle=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", \nAudPtr=" + getAudLabel(gaTVG(nTVGIndex)\nTVGAudPtr) + "")
;         EndIf ; EndIf nPlayerState <> #tvc_ps_Closed ; INFO MOVED 14Jul2020 11.8.3.2am (moved to further up this procedure)
        ; the following actions deferred until OnPlayerStateChanged() where (PlayerState = #tvc_ps_Closed) And (\bClosePlayerRequested)
        ; gaTVG(nTVGIndex)\nTVGSubPtr = grTVGDef\nSubPtr
        ; gaTVG(nTVGIndex)\nTVGAudPtr = grTVGDef\nAudPtr
      EndIf ; EndIf bUsingMemoryImage / Else
    EndIf ; EndIf nHandle
  EndIf ; EndIf nTVGIndex >= 0
  
  debugMsgT(sProcName, #SCS_END + ", returning #True, grTVGControl\bCloseTVGsWaiting=" + strB(grTVGControl\bCloseTVGsWaiting))
  ProcedureReturn #True
  
EndProcedure

Procedure freeWaitingTVGControls()
  PROCNAMEC()
  Protected nTVGIndex
  Protected bResetTVGsPlaying
  Protected bTVGsPlaying
  Protected nAudPtr, nAudState
  Protected bFreeThis, bDeferClearingFlag
  Protected nPlayerState.l
  
  debugMsg(sProcName, #SCS_START)
  
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    If *gmVideoGrabber(nTVGIndex)
      If gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying
        nPlayerState = TVG_GetPlayerState(*gmVideoGrabber(nTVGIndex))
        debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")=" + decodeTVGPlayerState(nPlayerState))
        If nPlayerState <> #tvc_ps_Playing
          bFreeThis = #True
          ; nb only interested in 'playing' - not paused etc. (Also, SCS doesn't use states like 'playing backwards'.)
          nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
          If nAudPtr >= 0
            nAudState = aAud(nAudPtr)\nAudState
            debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(nAudState))
            If (nAudState >= #SCS_CUE_FADING_IN) And (nAudState <= #SCS_CUE_FADING_OUT)
              bFreeThis = #False
              bDeferClearingFlag = #True
            EndIf
          EndIf
          If bFreeThis
            debugMsg(sProcName, "calling freeTVGControl(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #True)")
            If freeTVGControl(nTVGIndex, #True)
              gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #False
            EndIf
            bResetTVGsPlaying = #True
          EndIf
        EndIf
      EndIf
    EndIf
  Next nTVGIndex
  
  If bResetTVGsPlaying
    isTVGPlaying()
  EndIf
  
  If bDeferClearingFlag = #False
    grTVGControl\bCloseTVGsWaiting = #False
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", grTVGControl\bCloseTVGsWaiting=" + strB(grTVGControl\bCloseTVGsWaiting))
  
EndProcedure

Procedure freeAudTVGControls(pAudPtr)
  PROCNAMEC()
  Protected nTVGIndex
  Protected bResetTVGsPlaying
  Protected bTVGsPlaying
  Protected nAudState
  Protected nPlayerState.l
  
  debugMsg(sProcName, #SCS_START)
  
  nAudState = aAud(pAudPtr)\nAudState
  debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAudState=" + decodeCueState(nAudState))
  If nAudState < #SCS_CUE_FADING_IN Or nAudState > #SCS_CUE_FADING_OUT
    For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
      If *gmVideoGrabber(nTVGIndex)
        If gaTVG(nTVGIndex)\nTVGAudPtr = pAudPtr
          nPlayerState = TVG_GetPlayerState(*gmVideoGrabber(nTVGIndex))
          debugMsgT(sProcName, "TVG_GetPlayerState(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")=" + decodeTVGPlayerState(nPlayerState))
          If nPlayerState <> #tvc_ps_Playing
            ; nb only interested in 'playing' - not paused etc. (Also, SCS doesn't use states like 'playing backwards'.)
            debugMsg(sProcName, "calling freeTVGControl(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #True)")
            If freeTVGControl(nTVGIndex, #True)
              gaTVG(nTVGIndex)\bCloseWhenTVGNotPlaying = #False
            EndIf
            bResetTVGsPlaying = #True
          EndIf
        EndIf
      EndIf
    Next nTVGIndex
  EndIf
  
  If bResetTVGsPlaying
    isTVGPlaying()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure applyTVGPosAndSize(nAudPtr, nTVGIndex, bTrace=#False)
  PROCNAMECA(nAudPtr)
  Protected dCroppingZoom.d, nCroppingX.l, nCroppingY.l
  Protected nHandle.i, sHandle.s
  
  If nAudPtr >= 0 And nTVGIndex >= 0
    With aAud(nAudPtr)
      nHandle = *gmVideoGrabber(nTVGIndex)
      sHandle = decodeHandle(nHandle)
      
      If \nSize <> 0 Or \nXPos <> 0 Or \nYPos <> 0
        debugMsgC(sProcName, "\nSize=" + \nSize + ", \nXPos=" + \nXPos + ", \nYPos=" + \nYPos)
        
        If TVG_GetCropping_Enabled(nHandle) = #tvc_false
          TVG_SetCropping_Enabled(nHandle, #tvc_true)
          debugMsgC(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_true)")
          TVG_SetCropping_Width(nHandle, \nSourceWidth)
          debugMsgC(sProcName, "TVG_SetCropping_Width(" + sHandle + ", " + \nSourceWidth + ")")
          TVG_SetCropping_Height(nHandle, \nSourceHeight)
          debugMsgC(sProcName, "TVG_SetCropping_Height(" + sHandle + ", " + \nSourceHeight + ")")
        EndIf
        
        dCroppingZoom = convertSizeToTVGCroppingZoom(\nSize)
        If TVG_GetCropping_Zoom(nHandle) <> dCroppingZoom Or 1=1
          TVG_SetCropping_Zoom(nHandle, dCroppingZoom)
          debugMsgC(sProcName, "TVG_SetCropping_Zoom(" + sHandle + ", " + StrD(dCroppingZoom,4) + ")")
        EndIf
        
        nCroppingX = convertXPosToTVGCroppingX(\nXPos, \nSourceWidth, dCroppingZoom)
        If TVG_GetCropping_X(nHandle) <> nCroppingX
          TVG_SetCropping_X(nHandle, nCroppingX)
          debugMsgC(sProcName, "TVG_SetCropping_X(" + sHandle + ", " + nCroppingX + ")")
        EndIf
        
        nCroppingY = convertYPosToTVGCroppingY(\nYPos, \nSourceHeight, dCroppingZoom)
        If TVG_GetCropping_Y(nHandle) <> nCroppingY
          TVG_SetCropping_Y(nHandle, nCroppingY)
          debugMsgC(sProcName, "TVG_SetCropping_Y(" + sHandle + ", " + nCroppingY + ")")
        EndIf
        
      Else
        ; \nSize = 0 And \nXPos = 0 And \nYPos = 0
        If TVG_GetCropping_Enabled(nHandle) = #tvc_true
          TVG_SetCropping_Enabled(nHandle, #tvc_false)
          debugMsgC(sProcName, "TVG_SetCropping_Enabled(" + sHandle + ", #tvc_false)")
        EndIf
        
      EndIf ; EndIf / Else \nSize <> 0 Or \nXPos <> 0 Or \nYPos <> 0
      
    EndWith
  EndIf
  
EndProcedure

Procedure.s decodeTVGPlayerState(nPlayerState)
  Protected sPlayerState.s
  
  Select nPlayerState
    Case #tvc_ps_Closed
      sPlayerState = "ps_Closed"
    Case #tvc_ps_Stopped
      sPlayerState = "ps_Stopped"
    Case #tvc_ps_Paused
      sPlayerState = "ps_Paused"
    Case #tvc_ps_Playing
      sPlayerState = "ps_Playing"
    Case #tvc_ps_PlayingBackward
      sPlayerState = "ps_PlayingBackward"
    Case #tvc_ps_FastForwarding
      sPlayerState = "ps_FastForwarding"
    Case #tvc_ps_FastRewinding
      sPlayerState = "ps_FastRewinding"
    Case #tvc_ps_Downloading
      sPlayerState = "ps_Downloading"
    Case #tvc_ps_DownloadCompleted
      sPlayerState = "ps_DownloadCompleted"
    Case #tvc_ps_DownloadCancelled
      sPlayerState = "ps_DownloadCancelled"
    Case #tvc_ps_Opened
      sPlayerState = "ps_Opened"
    Default
      sPlayerState = Str(nPlayerState)
  EndSelect
  ProcedureReturn sPlayerState
  
EndProcedure

Procedure.s decodeTVGVideoSource(nTVGVideoSource)
  Protected sTVGVideoSource.s
  
  Select nTVGVideoSource
    Case #tvc_vs_VideoCaptureDevice
      sTVGVideoSource = "vs_VideoCaptureDevice"
    Case #tvc_vs_ScreenRecording
      sTVGVideoSource = "vs_ScreenRecording"
    Case #tvc_vs_VideoFileOrURL
      sTVGVideoSource = "vs_VideoFileOrURL"
    Case #tvc_vs_JPEGsOrBitmaps
      sTVGVideoSource = "vs_JPEGsOrBitmaps"
    Case#tvc_vs_IPCamera
      sTVGVideoSource = "vs_IPCamera"
    Case #tvc_vs_Mixer
      sTVGVideoSource = "vs_Mixer"
    Case #tvc_vs_VideoFromImages
      sTVGVideoSource = "vs_VideoFromImages"
    Case #tvc_vs_ThirdPartyFilter
      sTVGVideoSource = "vs_ThirdPartyFilter"
    Default
      sTVGVideoSource = Str(nTVGVideoSource)
  EndSelect
  ProcedureReturn sTVGVideoSource
  
EndProcedure

Procedure.s decodeTVGDisplayAspectRatio(nTVGDisplayAspectRatio)
  Protected sTVGDisplayAspectRatio.s
  
  Select nTVGDisplayAspectRatio
    Case #tvc_ar_Box
      sTVGDisplayAspectRatio = "ar_Box"
    Case #tvc_ar_NoResize
      sTVGDisplayAspectRatio = "ar_NoResize"
    Case #tvc_ar_PanScan
      sTVGDisplayAspectRatio = "ar_PanSCan"
    Case #tvc_ar_Stretch
      sTVGDisplayAspectRatio = "ar_Stretch"
    Default
      sTVGDisplayAspectRatio = Str(nTVGDisplayAspectRatio)
  EndSelect
  ProcedureReturn sTVGDisplayAspectRatio
  
EndProcedure

Procedure encodeTVGPlayerHwAccel(sTVGPlayerHwAccel.s)
  Protected nTVGPlayerHwAccel
  
  Select sTVGPlayerHwAccel
    Case "hw_None"
      nTVGPlayerHwAccel = #tvc_hw_None
    Case "hw_Cuda"
      nTVGPlayerHwAccel = #tvc_hw_Cuda
    Case "hw_d3d11"
      nTVGPlayerHwAccel = #tvc_hw_d3d11
    Case "hw_Dxva2"
      nTVGPlayerHwAccel = #tvc_hw_Dxva2
    Case "hw_QuickSync"
      nTVGPlayerHwAccel = #tvc_hw_QuickSync
    Default
      nTVGPlayerHwAccel = #tvc_hw_None
  EndSelect
  ProcedureReturn nTVGPlayerHwAccel
  
EndProcedure

Procedure.s decodeTVGPlayerHwAccel(nTVGPlayerHwAccel)
  Protected sTVGPlayerHwAccel.s
  
  Select nTVGPlayerHwAccel
    Case #tvc_hw_None
      sTVGPlayerHwAccel = "hw_None"
    Case #tvc_hw_Cuda
      sTVGPlayerHwAccel = "hw_Cuda"
    Case #tvc_hw_d3d11
      sTVGPlayerHwAccel = "hw_d3d11"
    Case #tvc_hw_Dxva2
      sTVGPlayerHwAccel = "hw_Dxva2"
    Case #tvc_hw_QuickSync
      sTVGPlayerHwAccel = "hw_QuickSync"
    Default
      sTVGPlayerHwAccel = Str(nTVGPlayerHwAccel)
  EndSelect
  ProcedureReturn sTVGPlayerHwAccel
  
EndProcedure

Procedure.s decodeTVGPlayerHwAccelL(nTVGPlayerHwAccel)
  Protected sTVGPlayerHwAccel.s
  
  Select nTVGPlayerHwAccel
    Case #tvc_hw_None
      sTVGPlayerHwAccel = Lang("TVG", "HwAccelNone") ; "No hardware acceleration"
    Case #tvc_hw_Cuda
      sTVGPlayerHwAccel = "NVIDIA CUDA"
    Case #tvc_hw_d3d11
      sTVGPlayerHwAccel = "DirectX d3d11"
    Case #tvc_hw_Dxva2
      sTVGPlayerHwAccel = "DirectX dxva2"
    Case #tvc_hw_QuickSync
      sTVGPlayerHwAccel = "Intel QuickSync"
    Default
      sTVGPlayerHwAccel = Str(nTVGPlayerHwAccel)
  EndSelect
  ProcedureReturn sTVGPlayerHwAccel
  
EndProcedure

Procedure.s decodeTVGVideoRenderer(nTVGVideoRenderer)
  Protected sTVGVideoRenderer.s
  
  Select nTVGVideoRenderer
    Case #tvc_vr_AutoSelect
      sTVGVideoRenderer = "vr_AutoSelect"
    Case #tvc_vr_EVR
      sTVGVideoRenderer = "vr_EVR"
    Case #tvc_vr_madVR
      sTVGVideoRenderer = "vr_madVR"
    Case #tvc_vr_None
      sTVGVideoRenderer = "vr_None"
    Case #tvc_vr_OverlayRenderer
      sTVGVideoRenderer = "vr_OverlayRenderer"
    Case #tvc_vr_RecordingPriority
      sTVGVideoRenderer = "vr_RecordingPriority"
    Case #tvc_vr_StandardRenderer
      sTVGVideoRenderer = "vr_StandardRenderer"
    Case #tvc_vr_VMR7
      sTVGVideoRenderer = "vr_VMR7"
    Case #tvc_vr_VMR9
      sTVGVideoRenderer = "vr_VMR9"
    Default
      sTVGVideoRenderer = Str(nTVGVideoRenderer)
  EndSelect
  ProcedureReturn sTVGVideoRenderer
EndProcedure

Procedure encodeTVGExternalRenderer(sTVGExternalRenderer.s)
  Protected nTVGExternalRenderer
  
  Select sTVGExternalRenderer
    Case "vre_None"
      nTVGExternalRenderer = #tvc_vre_None
    Case "vre_Matrox_PRO"
      nTVGExternalRenderer = #tvc_vre_Matrox_PRO
    Case "vre_Decklink_SD"
      nTVGExternalRenderer = #tvc_vre_Decklink_SD
    Case "vre_Decklink_Extreme"
      nTVGExternalRenderer = #tvc_vre_Decklink_Extreme
    Case "vre_Pinnacle_MovieBoard"
      nTVGExternalRenderer = #tvc_vre_Pinnacle_MovieBoard
    Case "vre_BlackMagic_Decklink"
      nTVGExternalRenderer = #tvc_vre_BlackMagic_Decklink
    Case "vre_AJA"
      nTVGExternalRenderer = #tvc_vre_AJA
    Default
      nTVGExternalRenderer = #tvc_vre_None
  EndSelect
  ProcedureReturn nTVGExternalRenderer
EndProcedure

Procedure.s decodeTVGExternalRenderer(nTVGExternalRenderer)
  Protected sTVGExternalRenderer.s
  
  ; TVG documentation states: "vre_Decklink_SD, vre_Decklink_Extreme: deprecated"
  
  Select nTVGExternalRenderer
    Case #tvc_vre_None
      sTVGExternalRenderer = "vre_None"
    Case #tvc_vre_Matrox_PRO
      sTVGExternalRenderer = "vre_Matrox_PRO"
    Case #tvc_vre_Pinnacle_MovieBoard
      sTVGExternalRenderer = "vre_Pinnacle_MovieBoard"
    Case #tvc_vre_BlackMagic_Decklink
      sTVGExternalRenderer = "vre_BlackMagic_Decklink"
    Case #tvc_vre_AJA
      sTVGExternalRenderer = "vre_AJA"
    Default
      sTVGExternalRenderer = Str(nTVGExternalRenderer)
  EndSelect
  ProcedureReturn sTVGExternalRenderer
EndProcedure

Procedure.s decodeTVGExternalRendererL(nTVGExternalRenderer)
  Protected sTVGExternalRenderer.s
  Static sNone.s, bStaticLoaded
  
  ; TVG documentation states: "vre_Decklink_SD, vre_Decklink_Extreme: deprecated"
  
  If bStaticLoaded = #False
    sNone = Lang("Common", "None") + " (" + Lang("Common", "Default") + ")"
    bStaticLoaded = #True
  EndIf
  
  Select nTVGExternalRenderer
    Case #tvc_vre_None
      sTVGExternalRenderer = sNone
    Case #tvc_vre_Matrox_PRO
      sTVGExternalRenderer = "MatroxPro"
    Case #tvc_vre_Pinnacle_MovieBoard
      sTVGExternalRenderer = "Pinnacle Movie Board"
    Case #tvc_vre_BlackMagic_Decklink
      sTVGExternalRenderer = "Blackmagic DeckLink" ; capital letters etc checked from web
    Case #tvc_vre_AJA
      sTVGExternalRenderer = "AJA"
    Default
      sTVGExternalRenderer = Str(nTVGExternalRenderer)
  EndSelect
  ProcedureReturn sTVGExternalRenderer
EndProcedure

Procedure MarkerTVGSyncProc(nChannelAudPtr, nCueMarkerId)
  PROCNAMECA(nChannelAudPtr)
  Protected nChannelSubPtr, nLinkCuePtr, nLinkSubPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nCueMarkerId=" + nCueMarkerId)
  
  nChannelSubPtr = aAud(nChannelAudPtr)\nSubIndex
  If (aSub(nChannelSubPtr)\bStartedInEditor = #False) Or (grEditingOptions\bActivateOCMAutoStarts)
    For n = 0 To gnMaxOCMMatrixItem
      If gaOCMMatrix(n)\nCueMarkerId = nCueMarkerId
        nLinkCuePtr = gaOCMMatrix(n)\nOCMCuePtr
        nLinkSubPtr = gaOCMMatrix(n)\nOCMSubPtr
        If nLinkSubPtr >= 0
          If aSub(nLinkSubPtr)\bSubEnabled
            debugMsg(sProcName, "PostEvent(#SCS_Event_PlaySub, #WMN, 0, 0, " + aSub(nLinkSubPtr)\sSubLabel + ")")
            PostEvent(#SCS_Event_PlaySub, #WMN, 0, 0, nLinkSubPtr)
          EndIf
        ElseIf nLinkCuePtr >= 0
          If aCue(nLinkCuePtr)\bCueEnabled
            debugMsg(sProcName, "PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, " + aCue(nLinkCuePtr)\sCue + ")")
            PostEvent(#SCS_Event_PlayCue, #WMN, 0, 0, nLinkCuePtr)
          EndIf
        EndIf
      EndIf
    Next n
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure eventTVGOnFrameProgress2(*Object, *Sender, *FrameInfo.TFrameInfo)
  PROCNAMEC()
  Protected nTVGIndex, nAudPtr
  Protected n
  
  nTVGIndex = getPlayerIndex(*Sender)
  ; debugMsg(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", *FrameInfo=" + *FrameInfo + ", nTVGIndex=" + nTVGIndex + ", *FrameInfo\frameTime=" + *FrameInfo\frameTime)
  If nTVGIndex >= 0
    nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
    For n = 0 To aAud(nAudPtr)\nMaxCueMarker
      With aAud(nAudPtr)\aCueMarker(n)
        If \bCueMarkerProcessed = #False
          If *frameinfo\frametime >= \qMinFrameTimeForCueMarker
            If *frameInfo\frameTime <= \qMaxFrameTimeForCueMarker
              ; debugMsg(sProcName, "*frameinfo\frametime=" + *frameinfo\frametime + ", aAud(" + getAudLabel(nAudPtr) + ")\aCueMarker(" + n + ")\nCueMarkerId=" + \nCueMarkerId + ", calling MarkerTVGSyncProc(" + getAudLabel(nAudPtr) + ")")
              MarkerTVGSyncProc(nAudPtr, \nCueMarkerId)
            EndIf
            \bCueMarkerProcessed = #True
          EndIf
        EndIf
      EndWith
    Next n
  EndIf

EndProcedure

Procedure eventTVGOnInactive(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
  
EndProcedure

Procedure eventTVGOnLastCommandCompleted(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
  
EndProcedure

Procedure eventTVGOnLog (*Object, *Sender, LogType.l, *Severity, *InfoMsg)
  PROCNAMEC()
  Protected nTVGIndex
  Protected *mLogString, sLogString.s
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
  
  *mLogString = TVG_GetLogString(*Sender, LogType)
  If *mLogString
    sLogString = PeekS(*mLogString)
    debugMsgT(sProcName, "LogType=" + LogType + " " + #DQUOTE$ + Trim(sLogString) + #DQUOTE$ +
                         ", *Severity=" + PeekS(*Severity) + ", *InfoMsg=" + PeekS(*InfoMsg) + ", GetActiveWindow()=" + decodeWindow(GetActiveWindow()))
  EndIf
  
  ; Added 6May2020 11.8.3rc2
  If GetActiveWindow() = -1
    samAddRequest(#SCS_SAM_SET_FOCUS_TO_SCS, 0, 0, 0, "", ElapsedMilliseconds()+750)
  EndIf
  ; End added 6May2020 11.8.3rc2

EndProcedure

Procedure eventTVGOnMouseDown(*Object, *Sender, VideoWindow.l, Button.l, Shift.l, X.l, Y.l)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", VideoWindow=" + VideoWindow + ", Button=" + Button + ", Shift=" + Shift + ", X=" + X + ", Y=" + Y)
  Select Button
    Case #tvc_mbRight
      If VideoWindow = 1
        WMN_processRightClick()
      EndIf
    Case #tvc_mbLeft
      If nTVGIndex >= 0
        Select gaTVG(nTVGIndex)\nTVGVidPicTarget
          Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
            WQA_cvsPreviewOrVideoEvent(WQA\cvsPreview, #PB_EventType_LeftButtonDown, X, Y)
        EndSelect
      EndIf
  EndSelect
EndProcedure

Procedure eventTVGOnMouseMove(*Object, *Sender, VideoWindow.l, Shift.l, X.l, Y.l)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  ; debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", VideoWindow=" + VideoWindow + ", Shift=" + Shift + ", X=" + X + ", Y=" + Y + ", nTVGIndex=" + nTVGIndex)
  If nTVGIndex >= 0
    Select gaTVG(nTVGIndex)\nTVGVidPicTarget
      Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
        WQA_cvsPreviewOrVideoEvent(WQA\cvsPreview, #PB_EventType_MouseMove, X, Y)
    EndSelect
  EndIf
  
EndProcedure

Procedure eventTVGOnMouseUp(*Object, *Sender, VideoWindow.l, Button.l, Shift.l, X.l, Y.l)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", VideoWindow=" + VideoWindow + ", Button=" + Button + ", Shift=" + Shift + ", X=" + X + ", Y=" + Y)
  Select Button
    Case #tvc_mbLeft
      If nTVGIndex >= 0
        Select gaTVG(nTVGIndex)\nTVGVidPicTarget
          Case #SCS_VID_PIC_TARGET_P, #SCS_VID_PIC_TARGET_TEST
            WQA_cvsPreviewOrVideoEvent(WQA\cvsPreview, #PB_EventType_LeftButtonUp, X, Y)
        EndSelect
      EndIf
  EndSelect
EndProcedure

Procedure eventTVGOnPlayerEndOfStream(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex
  Protected nSubPtr, nAudPtr
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
  
  If nTVGIndex >= 0
    nSubPtr = gaTVG(nTVGIndex)\nTVGSubPtr
    nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
    debugMsgT(sProcName, "nSubPtr=" + getSubLabel(nSubPtr) + ", nAudPtr=" + getAudLabel(nAudPtr))
    If nSubPtr >= 0 And nAudPtr >= 0
      If gaTVG(nTVGIndex)\bStillImage = #False
        aAud(nAudPtr)\bPlayEndSyncOccurred = #True
        debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\bPlayEndSyncOccurred=" + strB(aAud(nAudPtr)\bPlayEndSyncOccurred))
      EndIf
      ; Added 16May2020 11.8.3rc5 because the TVG 'VideoVisibleWhenStopped' wasn't working - see emails to Datastead 15May2020
      ; See also code in statusCheck() around the test on bChannelPlaying, which is still required because eventTVGOnPlayerEndOfStream() is not activated when an 'end at' is set (ie set prior to the end of the file).
      With aSub(nSubPtr)
        debugMsgT(sProcName, "aSub(" + getSubLabel(nSubPtr) + ")\bPauseAtEnd=" + strB(\bPauseAtEnd) + ", \bPLTerminating=" + strB(\bPLTerminating) + ", \nSubState=" + decodeCueState(\nSubState) +
                             ", aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(aAud(nAudPtr)\nAudState) + ", \nNextPlayIndex=" + getAudLabel(aAud(nAudPtr)\nNextPlayIndex))
        If (\bPauseAtEnd) And (\bPLTerminating = #False) And (aAud(nAudPtr)\nNextPlayIndex < 0)
          If (aAud(nAudPtr)\nAudState <> #SCS_CUE_PAUSED)
            debugMsgT(sProcName, "calling pauseAud(" + getAudLabel(nAudPtr) + ")")
            pauseAud(nAudPtr)
          Else ; video paused at end
            ; Added 17Feb2025 to set player at the last frame, because it appears that otherwise TVG would reset the display to the first frame
            ; Tested using AGM.scs11 and video files supplied by Pete Barnes in Aug2024
            TVG_SetPlayerFramePosition(*Sender, aAud(nAudPtr)\qVideoFrameCount)
            debugMsg0(sProcName, "TVG_SetPlayerFramePosition(" + decodeHandle(*Sender) + ", " + aAud(nAudPtr)\qVideoFrameCount + ")")
            debugMsg0(sProcName, "call samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, " + getCueLabel(gnCueToGo) + ")")
            samAddRequest(#SCS_SAM_OPEN_NEXT_CUES, gnCueToGo)
            ; End added 17Feb2025
          EndIf
        EndIf
      EndWith
      ; End added 16May2020 11.8.3rc5
    EndIf        
  EndIf
  
EndProcedure

Procedure eventTVGOnPlayerOpened(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex, nHandle, sHandle.s
  
  nTVGIndex = getPlayerIndex(*Sender)
  nHandle = *Sender
  sHandle = decodeHandle(nHandle)
  
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + sHandle + ", nTVGIndex=" + nTVGIndex)
  
  CompilerIf 1=2
    debugMsgT2(sProcName, "TVG_GetVideoWidth(" + sHandle + ")", TVG_GetVideoWidth(nHandle))
    debugMsgT2(sProcName, "TVG_GetVideoHeight(" + sHandle + ")", TVG_GetVideoHeight(nHandle))
    debugMsgT2(sProcName, "TVG_GetVideoWidth_PreferredAspectRatio(" + sHandle + ")", TVG_GetVideoWidth_PreferredAspectRatio(nHandle))
    debugMsgT2(sProcName, "TVG_GetVideoHeight_PreferredAspectRatio(" + sHandle + ")", TVG_GetVideoHeight_PreferredAspectRatio(nHandle))
    debugMsgT2(sProcName, "TVG_GetAdjustPixelAspectRatio(" + sHandle + ")", TVG_GetAdjustPixelAspectRatio(nHandle))
    debugMsgT2(sProcName, "TVG_GetDisplayAutoSize(" + sHandle + ", 0)", TVG_GetDisplayAutoSize(nHandle, 0))
    debugMsgT2(sProcName, "TVG_GetDisplayAutoSize(" + sHandle + ", 1)", TVG_GetDisplayAutoSize(nHandle, 1))
    debugMsgT(sProcName, "TVG_GetDisplayAspectRatio(" + sHandle + ", 0) returned " + decodeTVGDisplayAspectRatio(TVG_GetDisplayAspectRatio(nHandle, 0)))
    debugMsgT(sProcName, "TVG_GetDisplayAspectRatio(" + sHandle + ", 1) returned " + decodeTVGDisplayAspectRatio(TVG_GetDisplayAspectRatio(nHandle, 1)))
  CompilerEndIf
  
EndProcedure

; typedef void CALLBACK TOnPlayerStateChangedCb  (void *Object, void *Sender, TPlayerState  OldPlayerState, TPlayerState  NewPlayerState);
Procedure eventTVGOnPlayerStateChanged(*Object, *Sender, OldPlayerState.l, NewPlayerState.l)
  PROCNAMEC()
  Protected nTVGIndex, nAudPtr=-1, nAudState
  Protected nHandle.i, sHandle.s, nDisplayIndex
  Protected sText.s
  Protected bFreeControl
;   Protected qCurrPos.q ; 25Nov2020
  
  nTVGIndex = getPlayerIndex(*Sender)
  sText = "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) +
          ", OldPlayerState=" + decodeTVGPlayerState(OldPlayerState) + ", NewPlayerState=" + decodeTVGPlayerState(NewPlayerState) +
          ", nTVGIndex=" + nTVGIndex
  If nTVGIndex >= 0
    With gaTVG(nTVGIndex)
      \nLastOnPlayerStateChange = NewPlayerState
      If \nTVGAudPtr >= 0
        sText + ", \sFileName=" + GetFilePart(aAud(\nTVGAudPtr)\sFileName)
      EndIf
    EndWith
  EndIf
  debugMsgT(sProcName, sText)
  
  ; TEMP
;   nHandle = *Sender
;   sHandle = decodeHandle(nHandle)
;   qCurrPos = TVG_GetPlayerTimePosition(nHandle)
;   debugMsgT(sProcName, "TVG_GetPlayerTimePosition(" + sHandle + ") returned " + qCurrPos)
  ; END TEMP
  
  Select NewPlayerState
    Case #tvc_ps_Playing
      grTVGControl\nCountTVGsPlaying + 1
      debugMsgT(sProcName, "NewPlayerState=ps_Playing, grTVGControl\nCountTVGsPlaying=" + grTVGControl\nCountTVGsPlaying)
      ; added 6Sep2018 11.7.1.4ai following issue reported by Dee Ireland whereby a video set to start didn't display an image
      ; even though alphablend had been set to 255 immediately after the call to TVG_RunPlayer() in playTVGVideo()
      If nAudPtr >= 0
        With aAud(nAudPtr)
          If \nCurrFadeInTime <= 0
            nHandle = *Sender
            sHandle = decodeHandle(nHandle)
            TVG_SetDisplayAlphaBlendValue(nHandle, 0, 255)
            debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 255)")
            If gaTVG(nTVGIndex)\bDualDisplayActive
              TVG_SetDisplayAlphaBlendValue(nHandle, 1, 255)
              debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 255)")
            EndIf
            For nDisplayIndex = 2 To 8
              If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
                TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 255)
                debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 255)")
              EndIf
            Next nDisplayIndex
          EndIf
        EndWith
      EndIf
      ; end added 6Sep2018 11.7.1.4ai
      
    Case #tvc_ps_Stopped
      If OldPlayerState = #tvc_ps_Playing
        grTVGControl\nCountTVGsPlaying - 1
        debugMsgT(sProcName, "OldPlayerState=" + decodeTVGPlayerState(OldPlayerState) + ", NewPlayerState=" + decodeTVGPlayerState(NewPlayerState) +
                            ", grTVGControl\nCountTVGsPlaying=" + grTVGControl\nCountTVGsPlaying)
      EndIf
      
    Case #tvc_ps_Closed
      If nTVGIndex >= 0
        With gaTVG(nTVGIndex)
          If \bClosePlayerRequested
            ; note: the following code is only to be executed after we have called ClosePlayer(), because TVG itself seems to
            ; occasionally close and re-open a player, possibly when the active window changes(?). the following code must not
            ; be executed if TVG is just closing and re-opening the player.
            nAudPtr = \nTVGAudPtr
            bFreeControl = #True
            If \nTVGVidPicTarget <> #SCS_VID_PIC_TARGET_P
              If nAudPtr >= 0
                nAudState = aAud(nAudPtr)\nAudState
                debugMsgT(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nAudState=" + decodeCueState(aAud(nAudPtr)\nAudState))
                If nAudState < #SCS_CUE_COMPLETED
                  bFreeControl = #False
                EndIf
              EndIf
            EndIf
            If bFreeControl
              If nAudPtr >= 0
                Select \nTVGVidPicTarget
                  Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
                    aAud(nAudPtr)\nMainTVGIndex = grAudDef\nMainTVGIndex
                    debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nMainTVGIndex=" + aAud(nAudPtr)\nMainTVGIndex)
                  Case #SCS_VID_PIC_TARGET_P
                    aAud(nAudPtr)\nPreviewTVGIndex = grAudDef\nPreviewTVGIndex
                    debugMsg(sProcName, "aAud(" + getAudLabel(nAudPtr) + ")\nPreviewTVGIndex=" + aAud(nAudPtr)\nPreviewTVGIndex)
                EndSelect
              EndIf
              gaTVG(nTVGIndex)\nTVGSubPtr = grTVGDef\nTVGSubPtr
              gaTVG(nTVGIndex)\nTVGAudPtr = grTVGDef\nTVGAudPtr
            EndIf
          EndIf
        EndWith
      EndIf
      
  EndSelect
  
EndProcedure

Procedure eventTVGOnReinitializing(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex
  
  nTVGIndex = getPlayerIndex(*Sender)
  debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
  
EndProcedure

Procedure eventTVGOnRawAudioSample(*Object, *Sender, *pSampleBuffer, SampleBufferSize.l, SampleDataLength.l, FormatType.l, *pFormat, *pWaveFormatEx, SampleStartTime.q, SampleStopTime.q)
  PROCNAMEC()
  Protected nTVGIndex, nAudPtr, nVideoASIOStream.l, nBassResult.l
  
  nTVGIndex = getPlayerIndex(*Sender)
  If nTVGIndex >= 0
    nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
    If nAudPtr >= 0
      nVideoASIOStream = aAud(nAudPtr)\nVideoASIOStream
    EndIf
  EndIf
;   debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex + ", nAudPtr=" + getAudLabel(nAudPtr) + ", nVideoASIOStream=" + decodeHandle(nVideoASIOStream) +
;                        ", FormatType=" + FormatType + ", *pFormat=" + *pFormat + ", *pWaveFormatEx=" + *pWaveFormatEx + ", SampleStartTime=" + SampleStartTime + ", SampleStopTime=" + SampleStopTime)
  If nVideoASIOStream <> 0
    nBassResult = BASS_StreamPutData(nVideoASIOStream, *pSampleBuffer, SampleDataLength)
;     debugMsgT2(sProcName, "BASS_StreamPutData(" + decodeHandle(nVideoASIOStream) + ", " + *pSampleBuffer + ", " + SampleDataLength + ")", nBassResult)
  EndIf
EndProcedure

; typedef void CALLBACK TOnAudioPeakCb  (void *Object, void *Sender, double  Left_Percent, double  Left_DB, double  Right_Percent, double  Right_DB);
Procedure eventTVGOnAudioPeak(*Object, *Sender, Left_Percent.d, Left_DB.d, Right_Percent.d, Right_DB.d)
  ; PROCNAMEC()
  Protected nTVGIndex, nSubPtr, nVideoAudioDevPtr, nHandle.i
  
  nHandle = *Sender
  nTVGIndex = getPlayerIndex(nHandle)
  ; debugMsg(sProcName, "nTVGIndex=" + nTVGIndex + ", Left_Percent=" + StrD(Left_Percent,4) + ", Right_Percent=" + StrD(Right_Percent,4))
  nSubPtr = gaTVG(nTVGIndex)\nTVGSubPtr
  If nSubPtr > 0
    nVideoAudioDevPtr = aSub(nSubPtr)\nVideoAudioDevPtr
    If nVideoAudioDevPtr >= 0
      If aSub(nSubPtr)\bMuteVideoAudio = #False
        With grMaps\aDev(nVideoAudioDevPtr)
          If \nVideoPlayingCount > 0
            \dAudioPeakLeftPercent = Left_Percent
            \dAudioPeakRightPercent = Right_Percent
            ; debugMsg(sProcName, "grMaps\aDev(" + nVideoAudioDevPtr + ")\dAudioPeakLeftPercent=" + StrD(\dAudioPeakLeftPercent,4) + ", \dAudioPeakRightPercent=" + StrD(\dAudioPeakRightPercent,4))
            \nVideoLevel = TVG_GetAudioVolume(nHandle)
            \nVideoPan = TVG_GetAudioBalance(nHandle)
          Else
            \dAudioPeakLeftPercent = 0.0
            \dAudioPeakRightPercent = 0.0
          EndIf
        EndWith
      EndIf ; EndIf aSub(nSubPtr)\bMuteVideoAudio = #False
    EndIf ; EndIf nVideoAudioDevPtr >= 0
  EndIf ; EndIf nSubPtr > 0
  
EndProcedure

Procedure eventTVGOnVideoDeviceSelected(*Object, *Sender)
  PROCNAMEC()
  Protected nTVGIndex, nHandle.l, sHandle.s, dCurrFrameRate.d
  
  If *Object ; Test added 24Feb2025 11.10.7 following test of Steve Martin's cue file that referred to a video capture device that does not exist on my computer
    nTVGIndex = getPlayerIndex(*Sender)
    debugMsgT(sProcName, "*Object=" + *Object + ", *Sender=" + decodeHandle(*Sender) + ", nTVGIndex=" + nTVGIndex)
    nHandle = *Sender
    sHandle = decodeHandle(nHandle)
    dCurrFrameRate = TVG_GetCurrentFrameRate(nHandle)
    debugMsgT(sProcName, "TVG_GetCurrentFrameRate(" + sHandle + ") returned " + strDTrimmed(dCurrFrameRate,2))
  EndIf
  
EndProcedure

Procedure listTVGControls(bAssignedOnly=#True)
  PROCNAMEC()
  Protected nTVGIndex
  Protected sText.s
  Protected bListThis
  Protected nPlayerState
  
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    With gaTVG(nTVGIndex)
      bListThis = #True
      If bAssignedOnly
        If (\nTVGAudPtr = grTVGDef\nTVGAudPtr) And (\nTVGSubPtr = grTVGDef\nTVGSubPtr) And (\bProdTestVidCap = #False)
          bListThis = #False
        EndIf
      EndIf
      If bListThis
        sText = "gaTVG(" + nTVGIndex + ")\bAssigned=" + strB(\bAssigned) +
                ", *gmVideoGrabber(" + nTVGIndex + ")=" + decodeHandle(*gmVideoGrabber(nTVGIndex)) +
                ", \nTVGSubPtr=" + getSubLabel(\nTVGSubPtr) +
                ", \nTVGAudPtr=" + getAudLabel(\nTVGAudPtr) + ", \bProdTestVidCap=" + strB(\bProdTestVidCap) +
                ", \nTVGVidPicTarget=" + decodeVidPicTarget(\nTVGVidPicTarget) +
                ", \nChannel=" + \nChannel +
                ", \bTopMostWindowForTarget=" + strB(\bTopMostWindowForTarget)
        If \nTVGAudPtr >= 0
          sText + ", \sFileName=" + GetFilePart(aAud(\nTVGAudPtr)\sFileName)
        EndIf
        If *gmVideoGrabber(nTVGIndex)
          nPlayerState = TVG_GetPlayerState(*gmVideoGrabber(nTVGIndex))
          sText + ", PlayerState=" + decodeTVGPlayerState(nPlayerState)
        EndIf
        debugMsgT(sProcName, sText)
      EndIf
    EndWith
  Next nTVGIndex
  
EndProcedure

Procedure createPreviewTVGControlsIfReqd()
  PROCNAMEC()
  Protected nFreePreviewCount, nProdTestVidCapCount
  Protected nTVGIndex
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  listTVGControls(#False)
  
  debugMsg(sProcName, "grTVGControl\nMaxTVGIndex=" + grTVGControl\nMaxTVGIndex)
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    With gaTVG(nTVGIndex)
      If \nTVGVidPicTarget = #SCS_VID_PIC_TARGET_P
        If \bProdTestVidCap
          nProdTestVidCapCount + 1
        ElseIf (\nTVGSubPtr = grTVGDef\nTVGSubPtr) And (\nTVGAudPtr = grTVGDef\nTVGAudPtr)
          nFreePreviewCount + 1
        EndIf
      EndIf
    EndWith
  Next nTVGIndex
  debugMsg(sProcName, "nFreePreviewCount=" + nFreePreviewCount)
  
  If nProdTestVidCapCount = 0
    debugMsg(sProcName, "calling createTVGControl(#SCS_VID_PIC_TARGET_P, #tvc_vs_VideoCaptureDevice) for ProdTestVidCap")
    nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_P, #tvc_vs_VideoCaptureDevice)
    If nTVGIndex >= 0
      debugMsg(sProcName, "created " + decodeHandle(*gmVideoGrabber(nTVGIndex)))
      gaTVG(nTVGIndex)\bProdTestVidCap = #True
    EndIf
  EndIf
  
  If nFreePreviewCount < 2
    For n = nFreePreviewCount To 1
      debugMsg(sProcName, "calling createTVGControl(#SCS_VID_PIC_TARGET_P)")
      nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_P)
      If nTVGIndex >= 0
        debugMsg(sProcName, "created " + decodeHandle(*gmVideoGrabber(nTVGIndex)))
      EndIf
    Next n
  EndIf
  
  If countVidCapDevs(@grProd) > 0
    debugMsg(sProcName, "calling createTVGControl(#SCS_VID_PIC_TARGET_P, #SCS_VID_SRC_CAPTURE)")
    nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_P, #SCS_VID_SRC_CAPTURE)
    If nTVGIndex >= 0
      debugMsg(sProcName, "created " + decodeHandle(*gmVideoGrabber(nTVGIndex)))
    EndIf
    
    debugMsg(sProcName, "calling createTVGControl(#SCS_VID_PIC_TARGET_TEST, #SCS_VID_SRC_CAPTURE)")
    nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_TEST, #SCS_VID_SRC_CAPTURE)
    If nTVGIndex >= 0
      debugMsg(sProcName, "created " + decodeHandle(*gmVideoGrabber(nTVGIndex)))
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure freePreviewTVGControls()
  PROCNAMEC()
  Protected nTVGIndex
  
  For nTVGIndex = 0 To grTVGControl\nMaxTVGIndex
    With gaTVG(nTVGIndex)
      If \nTVGVidPicTarget = #SCS_VID_PIC_TARGET_P
        If (\nTVGSubPtr <> grTVGDef\nTVGSubPtr) Or (\nTVGAudPtr <> grTVGDef\nTVGAudPtr) Or (\nLastOnPlayerStateChange <> #tvc_ps_Closed)
          If \nLastOnPlayerStateChange <> #tvc_ps_Playing
            debugMsg(sProcName, "calling freeTVGControl(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
            freeTVGControl(nTVGIndex)
            \nTVGSubPtr = grTVGDef\nTVGSubPtr
            \nTVGAudPtr = grTVGDef\nTVGAudPtr
          EndIf
        EndIf
      EndIf
    EndWith
  Next nTVGIndex
  
EndProcedure

Procedure clearTVGFadeAudArray()
  PROCNAMEC()
  
  With grTVGControl
    If \nFadeAudCount > 0
      debugMsg(sProcName, "setting grTVGControl\nFadeAudCount=0, was " + \nFadeAudCount)
      \nFadeAudCount = 0
      debugMsg(sProcName, "\nFadeAudCount=" + \nFadeAudCount)
    EndIf
  EndWith
EndProcedure

Procedure addAudToTVGFadeAudArray(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, nUnusedIndex
  Protected bFound
  
  debugMsg(sProcName, #SCS_START)
  
  With grTVGControl
    If pAudPtr >= 0
      If aAud(pAudPtr)\bAudTypeA
        nUnusedIndex = -1
        For n = 0 To (\nFadeAudCount-1)
          If \nFadeAudPtr(n) = pAudPtr
            ; already in list
            bFound = #True
            Break
          ElseIf \nFadeAudPtr(n) = -1
            If nUnusedIndex = -1
              nUnusedIndex = n
            EndIf
          EndIf
        Next n
        If bFound = #False
          If nUnusedIndex >= 0
            \nFadeAudPtr(nUnusedIndex) = pAudPtr
            debugMsg(sProcName, "\nFadeAudPtr(" + nUnusedIndex + ")=" + getAudLabel(\nFadeAudPtr(nUnusedIndex)))
          Else
            nUnusedIndex = \nFadeAudCount
            If nUnusedIndex > ArraySize(\nFadeAudPtr())
              ReDim \nFadeAudPtr(nUnusedIndex+5)
            EndIf
            \nFadeAudPtr(nUnusedIndex) = pAudPtr
            \nFadeAudCount + 1
            debugMsg(sProcName, "\nFadeAudPtr(" + nUnusedIndex + ")=" + getAudLabel(\nFadeAudPtr(nUnusedIndex)) + ", \nFadeAudCount=" + \nFadeAudCount)
          EndIf
        EndIf
        If (nUnusedIndex >= 0) Or (bFound)
          aAud(pAudPtr)\bBlending = #True
          debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\bBlending=" + strB(aAud(pAudPtr)\bBlending))
          If nUnusedIndex >= 0
            debugMsgT(sProcName, "grTVGControl\nFadeAudPtr(" + nUnusedIndex + ")=" + getAudLabel(\nFadeAudPtr(nUnusedIndex)))
          EndIf
          If gaThread(#SCS_THREAD_BLENDER)\nThreadState <> #SCS_THREAD_STATE_ACTIVE
            THR_createOrResumeAThread(#SCS_THREAD_BLENDER)
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure removeAudFromTVGFadeAudArray(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n
  Protected nActiveCount
  Protected nTVGIndex
  
  With grTVGControl
    If pAudPtr >= 0
      For n = 0 To (\nFadeAudCount-1)
        If \nFadeAudPtr(n) = pAudPtr
          \nFadeAudPtr(n) = -1
          debugMsgT(sProcName, "grTVGControl\nFadeAudPtr(" + n + ")=-1")
        ElseIf \nFadeAudPtr(n) >= 0
          nActiveCount + 1
        EndIf
      Next n
      nTVGIndex = aAud(pAudPtr)\nMainTVGIndex
      If nTVGIndex >= 0
        If gaTVG(nTVGIndex)\nTVGAudPtr = pAudPtr
          debugMsg(sProcName, "calling setFrameGrabberEnabled(" + nTVGIndex + ", #False)")
          setFrameGrabberEnabled(nTVGIndex, #False)
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure isAudInTVGFadeAudArray(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected n, bResult
  
  With grTVGControl
    If pAudPtr >= 0
      For n = 0 To (\nFadeAudCount-1)
        If \nFadeAudPtr(n) = pAudPtr
          bResult = #True
          Break
        EndIf
      Next n
    EndIf
  EndWith
  
  ProcedureReturn bResult
  
EndProcedure

Procedure setTVGLogo(nTVGIndex, nImageNo)
  PROCNAMEC()
  Protected nResult.l
  
  If nTVGIndex >= 0
    If IsImage(nImageNo)
      nResult = TVG_SetLogoFromHBitmap(*gmVideoGrabber(nTVGIndex), ImageID(nImageNo))
      debugMsgT(sProcName, "TVG_SetLogoFromHBitmap(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", ImageID(" + nImageNo + ")) returned " + strB(nResult))
      TVG_SetLogoDisplayed(*gmVideoGrabber(nTVGIndex), #tvc_true)
      debugMsgT(sProcName, "TVG_SetLogoDisplayed(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ", #tvc_true)")
    EndIf
  EndIf
  
EndProcedure

Procedure.s decodeTVGTriState(nState)
  Protected sState.s
  
  Select nState
    Case #tvc_ts_Undefined
      sState = "Undefined"
    Case #tvc_ts_False
      sState = "False"
    Case #tvc_ts_True
      sState = "True"
    Default
      sState = Str(nState)
  EndSelect
  ProcedureReturn sState
EndProcedure

Procedure checkCodecs(pAudPtr, nTVGIndex)
  PROCNAMEC()
  Protected *VideoCodec, sVideoCodec.s
  Protected *AudioCodec, sAudioCodec.s
  Protected *FileName, sFileName.s, sFileExt.s
  Protected nVideoStreamAvailable.l, nAudioStreamAvailable.l
  Protected sMsg.s, sButtons.s, sBits.s, sDontTellMeAgainText.s
  Protected nOption
  Protected sKeyEvent.s
  Static bDontTellMeAgain
  
  If nTVGIndex >= 0
    *FileName = TVG_GetPlayerFileName(*gmVideoGrabber(nTVGIndex))
    If *FileName
      sFileName = PeekS(*FileName)
      sFileExt = GetExtensionPart(sFileName)
    EndIf
    sKeyEvent = "sFileName=" + GetFilePart(sFileName)
    
    nVideoStreamAvailable = TVG_GetIsPlayerVideoStreamAvailable(*gmVideoGrabber(nTVGIndex))
    sKeyEvent + ", VideoStreamAvailable=" + decodeTVGTriState(nVideoStreamAvailable)
    If nVideoStreamAvailable = #tvc_ts_True
      *VideoCodec = TVG_GetVideoCodec(*gmVideoGrabber(nTVGIndex))
      sVideoCodec = PeekS(*VideoCodec)
      sKeyEvent + ", VideoCodec=" + sVideoCodec
    EndIf
    
    nAudioStreamAvailable = TVG_GetIsPlayerAudioStreamAvailable(*gmVideoGrabber(nTVGIndex))
    sKeyEvent + ", AudioStreamAvailable=" + decodeTVGTriState(nAudioStreamAvailable)
    If nAudioStreamAvailable = #tvc_ts_True
      *AudioCodec = TVG_GetAudioCodec(*gmVideoGrabber(nTVGIndex))
      sAudioCodec = PeekS(*AudioCodec)
      sKeyEvent + ", AudioCodec=" + sAudioCodec
    EndIf
    
    ; logKeyEvent(sKeyEvent)
    
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      sBits = "64-bit"
    CompilerElse
      sBits = "32-bit"
    CompilerEndIf
    sButtons = Lang("Btns", "OK") + "|" +
               Lang("Btns", "Help")
    ; sDontTellMeAgainText = "Don't tell me this again for any video files in this SCS session"
    sDontTellMeAgainText = Lang("Common", "DontTellMeAgain")   ; "Don't tell me this again during this SCS session."

    If nVideoStreamAvailable = #tvc_ts_True
      If sVideoCodec = "n/a"
        If (bDontTellMeAgain = #False) And (aAud(pAudPtr)\bCodecWarningDisplayed = #False)
;           sMsg = "File Open Problem|" +
;                  "File " + #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$ + ": video stream available but no suitable codec found, so no video image will be displayed for this file.||" +
;                  "If you do not have the " + sBits + " LAVFilters installed then we recommend installing them. Click the Help button below for more details.||" +
;                  "If you still cannot get the video file to play then please contact SCS support."
          sMsg = Lang("TVG", "Warn2a") + "|" +
                 LangPars("TVG", "Warn2ba", #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$) + "||" +
                 LangPars("TVG", "Warn2c", sBits) + "||" +
                 Lang("TVG", "Contact")
          debugMsg(sProcName, sMsg)
          nOption = OptionRequester(0, 0, sMsg, sButtons, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
          debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
          If nOption & $10000
            bDontTellMeAgain = #True
          EndIf
          Select (nOption & $FFFF)
            Case 2
              displayHelpTopic("scs_options_video.htm")
          EndSelect
          aAud(pAudPtr)\bCodecWarningDisplayed = #True
        EndIf
      EndIf
    EndIf
    
    
    If nAudioStreamAvailable = #tvc_ts_True
      If sAudioCodec = "n/a"
        If (bDontTellMeAgain = #False) And (aAud(pAudPtr)\bCodecWarningDisplayed = #False)
;           sMsg = "File Open Problem|" +
;                  "File " + #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$ + ": audio stream available but no suitable codec found, so no audio will heard for this file.||" +
;                  "If you do not have the " + sBits + " LAVFilters installed then we recommend installing them. Click the Help button below for more details.||" +
;                  "If you still cannot get the video file to play then please contact SCS support."
          sMsg = Lang("TVG", "Warn2a") + "|" +
                 LangPars("TVG", "Warn2bv", #DQUOTE$ + GetFilePart(sFileName) + #DQUOTE$) + "||" +
                 LangPars("TVG", "Warn2c", sBits) + "||" +
                 Lang("TVG", "Contact")
          debugMsg(sProcName, sMsg)
          nOption = OptionRequester(0, 0, sMsg, sButtons, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
          debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
          If nOption & $10000
            bDontTellMeAgain = #True
          EndIf
          Select (nOption & $FFFF)
            Case 2
              displayHelpTopic("scs_options_video.htm")
          EndSelect
          aAud(pAudPtr)\bCodecWarningDisplayed = #True
        EndIf
      EndIf
    EndIf
    
  EndIf
  
EndProcedure

Procedure check_FFDSHOW_or_LAV_installed(pAudPtr)
  PROCNAMEC()
  Protected sFilters.s
  Protected bResult
  Protected sMsg.s, sButtons.s
  Protected sDontTellMeAgainText.s
  Protected nOption
  Protected sKeyEvent.s
  Static bWarningDisplayed
  
  debugMsg(sProcName, #SCS_START)
  
  sButtons = Lang("Btns", "OK") + "|" +
             Lang("Btns", "Help")
  sDontTellMeAgainText = Lang("Common", "DontTellMeAgain2") ; "Don't tell me this again"
  
  With grTVGControl
    \bFFDSHOWInstalled = #False
    \bLAVFiltersInstalled = #False
    ; debugMsg(sProcName, "grTVGControl\sDirectShowFilters=" + #DQUOTE$ + \sDirectShowFilters + #DQUOTE$)
    If \sDirectShowFilters
      sFilters = LCase(\sDirectShowFilters)
      If FindString(sFilters, "ffdshow video decoder", #PB_String_NoCase)
        \bFFDSHOWInstalled = #True
        bResult = #True
      EndIf
      If FindString(sFilters, "lav video decoder", #PB_String_NoCase)
        \bLAVFiltersInstalled = #True
        bResult = #True
      EndIf
    EndIf
    If bResult = #False
      debugMsg(sProcName, "grTVGControl\bFFDSHOWInstalled=" + strB(\bFFDSHOWInstalled) + ", \bLAVFiltersInstalled=" + strB(\bLAVFiltersInstalled))
    EndIf
  EndWith
  
  ; nb as at 11.5.3 changed preference from FFDSHOW to LAVFilters as this is easier to install and seems to work very well
  If bResult = #False
    If (grDontTellMeAgain\bVideoCodecs = #False) And (aAud(pAudPtr)\bCodecWarningDisplayed = #False) And (bWarningDisplayed = #False)
;       sMsg = "Video File Warning|" +
;              "Warning! Some video files may not play correctly or may not play at all if a compatible Video Codec cannot be connected.||" +
;              "We recommend you download and install LAVFilters. Click the Help button below for more details.||" +
;              "If you still cannot get a video file to play then please contact SCS support."
      sMsg = Lang("TVG", "Warn1a") + "|" +
             Lang("TVG", "Warn1b") + "||" +
             Lang("TVG", "Warn1c") + "||" +
             Lang("TVG", "Contact")
      debugMsg(sProcName, sMsg)
      nOption = OptionRequester(0, 0, sMsg, sButtons, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
      debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
      If nOption & $10000
        grDontTellMeAgain\bVideoCodecs = #True
      EndIf
      aAud(pAudPtr)\bCodecWarningDisplayed = #True
      bWarningDisplayed = #True
      Select (nOption & $FFFF)
        Case 2
          displayHelpTopic("scs_options_video.htm")
      EndSelect
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
EndProcedure

Procedure setTVG3PlusDisplays(nTVGIndex)
  PROCNAMEC()
  Protected nHandle.i, sHandle.s
  Protected nWindowNo, nDisplayIndex.l, nTVGMonitor.l
  Protected nLeft, nTop, nWidth, nHeight, nOutputScreenNo, nVidPicTarget
  
  ; debugMsg(sProcName, #SCS_START + ", nTVGIndex=" + nTVGIndex)
  
  nHandle = *gmVideoGrabber(nTVGIndex)
  sHandle = decodeHandle(nHandle)
  
  With gaTVG(nTVGIndex)
    For nDisplayIndex = 2 To 8 ; display index is 0-based
      ; nb if gbVideosOnMainWindow then only the primary display (DisplayIndex = 0) is used, so any other DisplayIndex values should be made inactive
      If (gbVideosOnMainWindow = #False) And (\bDisplayIndexUsed(nDisplayIndex))
        debugMsgT(sProcName, "\bDisplayIndexUsed(" + nDisplayIndex + ")=" + strB(\bDisplayIndexUsed(nDisplayIndex)) + ", \nTVGVidPicTarget=" + decodeVidPicTarget(\nTVGVidPicTarget))
        If TVG_GetDisplayActive(nHandle, nDisplayIndex) = #tvc_false
          TVG_SetDisplayActive(nHandle, nDisplayIndex, #tvc_true)
          debugMsgT(sProcName, "TVG_SetDisplayActive(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
        EndIf
        ; enable alpha-blend
        TVG_SetDisplayAlphaBlendEnabled(nHandle, nDisplayIndex, #tvc_true)
        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendEnabled(" + sHandle + ", " + nDisplayIndex+ ", #tvc_true)")
        ; detach control
        TVG_SetDisplayEmbedded(nHandle, nDisplayIndex, #tvc_false)
        debugMsgT(sProcName, "TVG_SetDisplayEmbedded(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
        TVG_SetDisplayMouseMovesWindow(nHandle, nDisplayIndex, #tvc_false)
        debugMsgT(sProcName, "TVG_SetDisplayMouseMovesWindow(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
        CompilerIf 1=2
          ; INFO BLOCKED OUT 8May2020 11.8.3rc3
          nOutputScreenNo = nDisplayIndex + 1 ; display index is 0-based
          nVidPicTarget = getVidPicTargetForOutputScreen(nOutputScreenNo)
          debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(nVidPicTarget) + ")\nTVGDisplayMonitor=" + grVidPicTarget(nVidPicTarget)\nTVGDisplayMonitor)
          nTVGMonitor = grVidPicTarget(nVidPicTarget)\nTVGDisplayMonitor
          TVG_SetDisplayFullScreen(nHandle, nDisplayIndex, #tvc_true)
          debugMsgT(sProcName, "TVG_SetDisplayFullScreen(" + sHandle + ", " + nDisplayIndex + ", #tvc_true)")
          TVG_SetDisplayMonitor(nHandle, nDisplayIndex, nTVGMonitor)
          debugMsgT(sProcName, "TVG_SetDisplayMonitor(" + sHandle + ", " + nDisplayIndex + ", " + nTVGMonitor + ")")
        CompilerEndIf
      Else
        If TVG_GetDisplayActive(nHandle, nDisplayIndex)
          TVG_SetDisplayActive(nHandle, nDisplayIndex, #tvc_false)
          debugMsgT(sProcName, "TVG_SetDisplayActive(" + sHandle + ", " + nDisplayIndex + ", #tvc_false)")
        EndIf
      EndIf
    Next nDisplayIndex
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.l scale_TVG_SetDisplayLocation(nHandle.i, nDisplayIndex.l, nWindowLeft.l, nWindowTop.l, nWindowWidth.l, nWindowHeight.l)
  PROCNAMEC()
  ; calls _SetDisplayLocation() after adjusting size and position for Windows Display Scaling factors
  Protected nLongResult.l
  Protected nDisplayLeft.l, nDisplayTop.l, nDisplayWidth.l, nDisplayHeight.l
  
  debugMsg(sProcName, #SCS_START + ", nHandle=" + decodeHandle(nHandle) + ", nDisplayIndex=" + nDisplayIndex + ", nWindowLeft=" + nWindowLeft + ", nWindowTop=" + nWindowTop + ", nWindowWidth=" + nWindowWidth + ", nWindowHeight=" + nWindowHeight)
  
  ; load window left, etc into 'Long' variables
  nDisplayLeft = nWindowLeft
  nDisplayTop = nWindowTop
  nDisplayWidth = nWindowWidth
  nDisplayHeight = nWindowHeight
  nLongResult = TVG_SetDisplayLocation(nHandle, nDisplayIndex, nDisplayLeft, nDisplayTop, nDisplayWidth, nDisplayHeight)
  debugMsgT(sProcName, "TVG_SetDisplayLocation(" + decodeHandle(nHandle) + ", " + nDisplayIndex + ", " + nDisplayLeft + ", " + nDisplayTop + ", " + nDisplayWidth + ", " + nDisplayHeight + ") returned "+ strB(nLongResult))
  ProcedureReturn nLongResult
EndProcedure

; Procedure to Play the Current Capture Device connected to TVG 
Procedure playTVGCapture(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex, nSubPtr
  Protected nHandle.i, sHandle.s
  Protected bResult.l
  Protected bIgnoreFadeIn, nDisplayIndex
  Protected nThisVidPicTarget, nOutputScreenCount, sScreens.s
  Protected nVideoPlaybackLibrary
  Protected nActiveWindow
  Protected nOutputVidPicTarget, nDisplayWidth.l, nDisplayHeight.l
  Protected nDevMapDevPtr, sVidCapFormat.s, dVidCapFrameRate.d, nPhysicalDevPtr, nVidCapFormat.l, sFormats.s, nFormatsCount, nFormatIndex, dCurrFrameRate.d
  
  debugMsgT(sProcName, #SCS_START + ", pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget))
  
  If pVidPicTarget = #SCS_VID_PIC_TARGET_NONE
    ProcedureReturn #False
  EndIf

  If aAud(pAudPtr)\nAudState = #SCS_CUE_ERROR
    ProcedureReturn #False
  EndIf
  
  If gnThreadNo > #SCS_THREAD_MAIN
    ; debugMsg3(sProcName, "transfer request to main thread")
    ; in the following call, set pCuePtrForRequestTime to prevent the control thread checking this cue until the SAM process has been actioned
    samAddRequest(#SCS_SAM_DISPLAY_PICTURE, pAudPtr, 0.0, pVidPicTarget, "", 0, bIgnoreFadein, aAud(pAudPtr)\nCueIndex)
    ProcedureReturn #True
  EndIf
  
  nActiveWindow = GetActiveWindow()
  debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(nActiveWindow))
  
  nThisVidPicTarget = pVidPicTarget
  Select pVidPicTarget
    Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
      sScreens = aSub(aAud(pAudPtr)\nSubIndex)\sScreens
      nOutputScreenCount = CountString(sScreens, ",") + 1
  EndSelect
  
  If pAudPtr < 0
    debugMsg(sProcName, "Failed value of pAudPtr < Zero")
    ProcedureReturn #False
  EndIf  
  
  With aAud(pAudPtr)
    nSubPtr = \nSubIndex
    
    \nAudVidPicTarget = pVidPicTarget
    Select pVidPicTarget
      Case #SCS_VID_PIC_TARGET_F2 To #SCS_VID_PIC_TARGET_LAST
        \nPlayVideoNo = \nMainVideoNo
        \nPlayTVGIndex = \nMainTVGIndex
      Case #SCS_VID_PIC_TARGET_P
        \nPlayVideoNo = \nPreviewVideoNo
        \nPlayTVGIndex = \nPreviewTVGIndex
    EndSelect
    debugMsg(sProcName, "pVidPicTarget=" + decodeVidPicTarget(pVidPicTarget) + ", aAud(" + getAudLabel(pAudPtr) + ")\nPlayVideoNo=" + \nPlayVideoNo + ", \nPlayTVGIndex=" + \nPlayTVGIndex)
    \bPlayEndSyncOccurred = #False
    \bInForcedFadeOut = #False
  EndWith
  
  With grVidPicTarget(pVidPicTarget)
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nVideoPlaybackLibrary=" + decodeVideoPlaybackLibrary(aAud(pAudPtr)\nVideoPlaybackLibrary))
    nVideoPlaybackLibrary = aAud(pAudPtr)\nVideoPlaybackLibrary
    Select nVideoPlaybackLibrary
      Case #SCS_VPL_NOT_SET, #SCS_VPL_IMAGE
        ; shouldn't get here
        nVideoPlaybackLibrary = grVideoDriver\nVideoPlaybackLibrary
        aAud(pAudPtr)\nVideoPlaybackLibrary = nVideoPlaybackLibrary
    EndSelect
    \nCurrVideoPlaybackLibrary = nVideoPlaybackLibrary
    
    \nPrevPrimaryAudPtr = \nPrimaryAudPtr
    \nPrevPlayingSubPtr = \nPlayingSubPtr
    \nPrimaryAudPtr = pAudPtr
    \nPlayingSubPtr = -1
    If \bLogoCurrentlyDisplayed
      \bLogoCurrentlyDisplayed = #False
      debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\bLogoCurrentlyDisplayed=" + strB(\bLogoCurrentlyDisplayed))
    EndIf
    \nPrimaryFileFormat = aAud(pAudPtr)\nFileFormat
    \sPrimaryFileName = aAud(pAudPtr)\sFileName
    debugMsg(sProcName, "grVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")\nPrevPlayingSubPtr=" + getSubLabel(\nPrevPlayingSubPtr) + ", \nPlayingSubPtr=" + getSubLabel(\nPlayingSubPtr) +
                        ", \nPrevPrimaryAudPtr=" + getAudLabel(\nPrevPrimaryAudPtr) + ", \nPrimaryAudPtr=" + getAudLabel(\nPrimaryAudPtr) + ", \sPrimaryFileName=" + GetFilePart(\sPrimaryFileName))
    
    nTVGIndex = getTVGIndexForAud(pAudPtr, pVidPicTarget)
    debugMsg(sProcName, "getTVGIndexForAud(" + getAudLabel(pAudPtr) + ", " + decodeVidPicTarget(pVidPicTarget) + ") returned " + nTVGIndex)
    If nTVGIndex < 0
      nTVGIndex = assignTVGControl(nSubPtr, pAudPtr, pVidPicTarget) 
      If nTVGIndex < 0 
        debugMsg(sProcName, "Failed nTVGIndex value of " + nTVGIndex)
        ProcedureReturn #False
      EndIf
    EndIf
    
    nHandle = *gmVideoGrabber(nTVGIndex)
    sHandle = decodeHandle(nHandle)
    
    nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_CAPTURE, aAud(pAudPtr)\sVideoCaptureLogicalDevice)
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\sVideoCaptureLogicalDevice=" + aAud(pAudPtr)\sVideoCaptureLogicalDevice + ", nDevMapDevPtr=" + nDevMapDevPtr)
    If nDevMapDevPtr >= 0
      sVidCapFormat = grMaps\aDev(nDevMapDevPtr)\sVidCapFormat
      dVidCapFrameRate = grMaps\aDev(nDevMapDevPtr)\dVidCapFrameRate
      nPhysicalDevPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
      debugMsg(sProcName, "sVidCapFormat=" + #DQUOTE$ + sVidCapFormat + #DQUOTE$ + ", dVidCapFrameRate=" + dVidCapFrameRate + ", nPhysicalDevPtr=" + nPhysicalDevPtr)
      If nPhysicalDevPtr >= 0
        If gaVideoCaptureDev(nPhysicalDevPtr)\nFormatsCount > 0
          nVidCapFormat = 0
          sFormats = gaVideoCaptureDev(nPhysicalDevPtr)\sFormats
          nFormatsCount = gaVideoCaptureDev(nPhysicalDevPtr)\nFormatsCount
          For nFormatIndex = 1 To nFormatsCount
            If StringField(sFormats, nFormatIndex, Chr(10)) = sVidCapFormat
              nVidCapFormat = nFormatIndex - 1 ; nVidCapFormat is 0-based
              Break
            EndIf
          Next nFormatIndex
          TVG_SetVideoFormat(nHandle, nVidCapFormat)
          debugMsgT(sProcName, "TVG_SetVideoFormat(" + sHandle + ", " + nVidCapFormat + ")")
        EndIf
      EndIf
      TVG_SetFrameRate(nHandle, dVidCapFrameRate)
      debugMsgT(sProcName, "TVG_SetFrameRate(" + sHandle + ", " + strDTrimmed(dVidCapFrameRate,2) + ")")
    EndIf
    
    bResult = TVG_StartPreview(nHandle)
    debugMsgT(sProcName, "TVG_StartPreview(" + sHandle + ") returned "+ strB(bResult))
    
    ; When using TVG_StartPreview, hiding the window icons must be called AFTER TVG_StartPreview()
    debugMsgT(sProcName, "calling hideTVGWindowIcons(" + nTVGIndex + ")")
    hideTVGWindowIcons(nTVGIndex)
    
    If aAud(pAudPtr)\nCurrFadeInTime <= 0
      ; if fade-in time not present then fully display image immediately AFTER calling RunPlayer()
      ; (don't do this PRIOR to calling RunPlayer() as that could cause a very brief freeze of the image before playback)
      TVG_SetDisplayAlphaBlendValue(nHandle, 0, 255)
      debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 255)")
      If gaTVG(nTVGIndex)\bDualDisplayActive
        TVG_SetDisplayAlphaBlendValue(nHandle, 1, 255)
        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 255)")
      EndIf
      For nDisplayIndex = 2 To 8
        If gaTVG(nTVGIndex)\bDisplayIndexUsed(nDisplayIndex)
          TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 255)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 255)")
        EndIf
      Next nDisplayIndex
    EndIf
    
    dCurrFrameRate = TVG_GetCurrentFrameRate(nHandle)
    debugMsgT(sProcName, "TVG_GetCurrentFrameRate(" + sHandle + ") returned " + strDTrimmed(dCurrFrameRate,2))
    
  EndWith
  
  setTVGWindowsVisibleAsReqd(pAudPtr, pVidPicTarget)
  
  debugMsg(sProcName, "calling fadeOutOrStopWhatWasPlayingOnVidPicTarget(" + decodeVidPicTarget(pVidPicTarget) + ")")
  fadeOutOrStopWhatWasPlayingOnVidPicTarget(pVidPicTarget)
  
  If GetActiveWindow() = -1
    ; nb, playing a video capture seems to set the active window to the TVG window, so bring focus back to the relevant SCS window
    If IsWindow(nActiveWindow) ; nActiveWindow was set at the start of this procedure, before TVG had a chance to shift focus elsewhere
      SAW(nActiveWindow)
    EndIf
  EndIf
  debugMsg(sProcName, "GetActiveWindow()=" + decodeWindow(nActiveWindow))
  
  debugMsgT(sProcName, #SCS_END)
  
  ProcedureReturn #True
  
EndProcedure

Procedure stopTVGCapture(nTVGIndex, bCallStopAud)
  PROCNAMEC()
  Protected nAudPtr, nDisplayIndex, nLongResult.l
  Protected nHandle.i, sHandle.s
  Protected sBlankString.s = ""

  debugMsgT(sProcName, #SCS_START)
  
  If nTVGIndex >= 0
    nHandle = *gmVideoGrabber(nTVGIndex)
    sHandle = decodeHandle(nHandle)
    nAudPtr = gaTVG(nTVGIndex)\nTVGAudPtr
    With gaTVG(nTVGIndex)
      ; Deleted 10Jun2020 11.8.3.2aa
      ; debugMsgT(sProcName, "calling TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(\nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)")
      ; nLongResult = TVG_SendImageToVideoFromBitmaps(nHandle, @sBlankString, ImageID(aAud(\nAudPtr)\nMemoryImageNo), #tvc_true, #tvc_true)
      ; debugMsgT2(sProcName, "TVG_SendImageToVideoFromBitmaps(" + sHandle + ", @sBlankString, ImageID(" + decodeHandle(aAud(\nAudPtr)\nMemoryImageNo) + "), #tvc_true, #tvc_true)", nLongResult)
      ; End deleted 10Jun2020 11.8.3.2aa
      debugMsgT(sProcName, "calling TVG_StopPreview(" + sHandle + ")")
      TVG_StopPreview(nHandle)
      debugMsgT(sProcName, "TVG_StopPreview(" + sHandle + ")")
      If nAudPtr >= 0
        aAud(\nTVGAudPtr)\nFileState = #SCS_FILESTATE_CLOSED
      EndIf
      TVG_SetDisplayAlphaBlendValue(nHandle, 0, 0)
      debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 0, 0)")
      If \bDualDisplayActive
        TVG_SetDisplayAlphaBlendValue(nHandle, 1, 0)
        debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", 1, 0)")
      EndIf
      For nDisplayIndex = 2 To 8
        If \bDisplayIndexUsed(nDisplayIndex)
          TVG_SetDisplayAlphaBlendValue(nHandle, nDisplayIndex, 0)
          debugMsgT(sProcName, "TVG_SetDisplayAlphaBlendValue(" + sHandle + ", " + nDisplayIndex + ", 0)")
        EndIf
      Next nDisplayIndex
    EndWith
    
    If bCallStopAud
      If nAudPtr >= 0
        aAud(nAudPtr)\bPlayEndSyncOccurred = #True
        debugMsgT(sProcName, "calling stopAud(" + getAudLabel(nAudPtr) + ")")
        stopAud(nAudPtr)
      EndIf
    EndIf
    
  EndIf ; EndIf nTVGIndex >= 0
  
  debugMsgT(sProcName, #SCS_END)
  
EndProcedure

Procedure resetTVGDisplayLocations()
  PROCNAMEC()
  Protected i, j, k, nTVGIndex
  
  If grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
    For i = 1 To gnLastCue
      If aCue(i)\bSubTypeA
        j = aCue(i)\nFirstSubIndex
        While j >= 0
          If aSub(j)\bSubTypeA
            k = aSub(j)\nFirstAudIndex
            While k >= 0
              With aAud(k)
                If (\nAudState >= #SCS_CUE_READY) And (\nAudState < #SCS_CUE_COMPLETED)
                  nTVGIndex = \nMainTVGIndex
                  If nTVGIndex >= 0
                    debugMsgT(sProcName, "calling setTVGDisplayLocation(" + decodeHandle(*gmVideoGrabber(nTVGIndex)) + ")")
                    setTVGDisplayLocation(nTVGIndex)
                  EndIf
                EndIf
                k = \nNextAudIndex
              EndWith
            Wend
          EndIf
          j = aSub(j)\nNextSubIndex
        Wend
      EndIf
    Next i
  EndIf ; EndIf grVideoDriver\nVideoPlaybackLibrary = #SCS_VPL_TVG
EndProcedure

Procedure.f getOutputGainForDev(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  Protected fDevOutputGain.f = 1.0
  Protected sLogicalDev.s
  Protected nDevMapDevPtr
  
  If pSubPtr >= 0
    If aSub(pSubPtr)\bSubTypeA
      sLogicalDev = aSub(pSubPtr)\sVidAudLogicalDev
      nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_VIDEO_AUDIO, sLogicalDev)
      If nDevMapDevPtr >= 0
        fDevOutputGain = grMaps\aDev(nDevMapDevPtr)\fDevOutputGain
      EndIf
    EndIf
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", returning fDevOutputGain=" + StrF(fDevOutputGain,4) + " (" + convertBVLevelToDBString(fDevOutputGain) + ")")
  ProcedureReturn fDevOutputGain
  
EndProcedure

Procedure.d convertSizeToTVGCroppingZoom(nSize)
  ; PROCNAMEC()
  Protected fPercentage.f, dTVGCroppingZoom.d
  
  ; nSize: 0 = normal (no resize), +500 (smallest) to -500 (largest)
  ; (NB nSize negated in CueFileHandler.pbi to comply with pre-11.2.1 cue files)
  ; dTVGCroppingZoom: 1.0 = normal (no resize)
  
  fPercentage = convertSizeToPercentage(nSize)
  dTVGCroppingZoom = fPercentage / 100
  ; debugMsg(sProcName, "nSize=" + nSize + ", fPercentage=" + StrF(fPercentage,4) + ", dTVGCroppingZoom=" + StrD(dTVGCroppingZoom,4))

  ProcedureReturn dTVGCroppingZoom
EndProcedure

Procedure.l convertXPosToTVGCroppingX(nXPos, nCroppingWidth, dCroppingZoom.d)
  ; PROCNAMEC()
  Protected nHalfWidth, nZoomedWidth, nCroppingX.l
  
  ; nXPos: 0 = centre, -5000 = far left, +5000 = far right
  ; TVG CroppingX: 0 = centre, CroppingWidth = far left, CroppingWidth*-1 = far right
  
  ; debugMsg(sProcName, #SCS_START + ", nXPos=" + nXPos + ", nCroppingWidth=" + nCroppingWidth + ", dCroppingZoom=" + StrD(dCroppingZoom,2))
  
  nHalfWidth = nCroppingWidth / 2
  nZoomedWidth = (nHalfWidth / dCroppingZoom) + nHalfWidth
  nCroppingX = nXPos * nZoomedWidth / 5000 * -1
  ; debugMsg(sProcName, "nHalfWidth=" + nHalfWidth + ", nZoomedWidth=" + nZoomedWidth)
  
  ; debugMsg(sProcName, #SCS_END + ", returning nCroppingX=" + nCroppingX)
  ProcedureReturn nCroppingX
  
EndProcedure

Procedure.l convertYPosToTVGCroppingY(nYPos, nCroppingHeight, dCroppingZoom.d)
  ; PROCNAMEC()
  Protected nHalfHeight, nZoomedHeight, nCroppingY.l
  
  ; nYPos: 0 = centre, -5000 (lowest) to +5000 (highest)
  ; TVG CroppingY: 0 = centre, CroppingHeight = lowest, CroppingWidth*-1 = far right
  
  nHalfHeight = nCroppingHeight / 2
  nZoomedHeight = (nHalfHeight / dCroppingZoom) + nHalfHeight
  nCroppingY = nYPos * nZoomedHeight / 5000 * -1
  ; debugMsg(sProcName, "nHalfHeight=" + nHalfHeight + ", nZoomedHeight=" + nZoomedHeight)
  
  ; debugMsg(sProcName, #SCS_END + ", returning nCroppingY=" + nCroppingY)
  ProcedureReturn nCroppingY
  
EndProcedure

Procedure adjustVidAudPlayingCount(pSubPtr, nPlusOrMinusOne)
  PROCNAMECS(pSubPtr)
  Protected nVideoAudioDevPtr
  
;   debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\bMuteVideoAudio=" + strb(aSub(pSubPtr)\bMuteVideoAudio) +
;                       ", \bSubPlaceHolder=" + strB(aSub(pSubPtr)\bSubPlaceHolder)
  If aSub(pSubPtr)\bMuteVideoAudio = #False And aSub(pSubPtr)\bSubPlaceHolder = #False
    nVideoAudioDevPtr = aSub(pSubPtr)\nVideoAudioDevPtr
    If nVideoAudioDevPtr >= 0
      With grMaps\aDev(nVideoAudioDevPtr)
        \nVideoPlayingCount + nPlusOrMinusOne
        If \nVideoPlayingCount < 0
          \nVideoPlayingCount = 0
        EndIf
      EndWith
    EndIf
  EndIf
  
EndProcedure

Procedure.d calcAspectRatioToUse(pAudPtr, pVidPicTarget)
  PROCNAMECA(pAudPtr)
  Protected dAspectRatioToUse.d
  Protected nTmpWidth, nTmpHeight
  
  With aAud(pAudPtr)
    Select \nAspectRatioType
      Case #SCS_ART_ORIGINAL
        If \nSourceWidth > 0 And \nSourceHeight > 0
          dAspectRatioToUse = \nSourceWidth / \nSourceHeight
        EndIf
      Case #SCS_ART_16_9
        dAspectRatioToUse = 16 / 9
      Case #SCS_ART_4_3
        dAspectRatioToUse = 4 / 3
      Case #SCS_ART_185_1
        dAspectRatioToUse = 1.85
      Case #SCS_ART_235_1
        dAspectRatioToUse = 2.35
      Case #SCS_ART_CUSTOM
        nTmpWidth = \nSourceWidth
        nTmpHeight = \nSourceHeight
        nTmpWidth + (nTmpWidth * \nAspectRatioHVal / 500)
        dAspectRatioToUse = nTmpWidth / nTmpHeight
      Case #SCS_ART_FULL
        nTmpWidth = grVidPicTarget(pVidPicTarget)\nTargetWidth
        nTmpHeight = grVidPicTarget(pVidPicTarget)\nTargetHeight
        dAspectRatioToUse = nTmpWidth / nTmpHeight
    EndSelect
    debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\nAspectRatioType=" + decodeAspectRatioType(\nAspectRatioType) + ", dAspectRatioToUse=" + StrD(dAspectRatioToUse,4))
  EndWith
  
  ProcedureReturn dAspectRatioToUse
EndProcedure

Procedure.l getTVGAudioFormat(nSampleRate.l, nChannels.l, nBitsPerSample.l)
  Protected nAudioFormat.l, nBitResolution.l
  
  nAudioFormat = #tvc_af_default
  nBitResolution = nBitsPerSample / nChannels
  Select nSampleRate
    Case 8000
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_8000_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_8000_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_8000_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_8000_16b_2ch
        EndIf
      EndIf
    Case 11025
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_11025_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_11025_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_11025_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_11025_16b_2ch
        EndIf
      EndIf
    Case 16000
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_16000_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_16000_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_16000_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_16000_16b_2ch
        EndIf
      EndIf
    Case 22050
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_22050_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_22050_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_22050_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_22050_16b_2ch
        EndIf
      EndIf
    Case 32000
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_32000_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_32000_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_32000_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_32000_16b_2ch
        EndIf
      EndIf
    Case 44100
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_44100_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_44100_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_44100_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_44100_16b_2ch
        EndIf
      EndIf
    Case 48000
      If nBitResolution = 8
        If nChannels = 1
          nAudioFormat = #tvc_af_48000_8b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_48000_8b_2ch
        EndIf
      ElseIf nBitResolution = 16
        If nChannels = 1
          nAudioFormat = #tvc_af_48000_16b_1ch
        ElseIf nChannels = 2
          nAudioFormat = #tvc_af_48000_16b_2ch
        EndIf
      EndIf
  EndSelect
  ProcedureReturn nAudioFormat
  
EndProcedure

Procedure setTVGMarkerPositions(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected nTVGIndex, nHandle, sHandle.s
  Protected n, dFrameRate.d, dFrameTime.d, qFrameTime.q
  
  debugMsg(sProcName, #SCS_START)
  
  If aAud(pAudPtr)\nFileFormat <> #SCS_FILEFORMAT_VIDEO
    ProcedureReturn
  EndIf
  
  If aAud(pAudPtr)\nMaxCueMarker >= 0
    nTVGIndex = getTVGIndexForAud(pAudPtr, #SCS_VID_PIC_TARGET_F2)
    ; debugMsg0(sProcName, "nTVGIndex=" + nTVGIndex)
    If nTVGIndex >= 0
      nHandle = *gmVideoGrabber(nTVGIndex)
      sHandle = decodeHandle(nHandle)
      ; debugMsg(sProcName, "nTVGIndex=" + nTVGIndex + ", nHandle=" + nHandle + ", sHandle=" + sHandle)
      dFrameRate = TVG_GetCurrentFrameRate(nHandle)
      If dFrameRate > 0.0
        dFrameTime = 1.00 / dFrameRate
        qFrameTime = dFrameTime * 10000000
        debugMsg(sProcName, "dFrameRate=" + StrD(dFrameRate, 2) + ", dFrameTime=" + StrD(dFrameTime,2) + ", qFrameTime=" + qFrameTime)
        ; update this aud's cue marker info for TVG
        For n = 0 To aAud(pAudPtr)\nMaxCueMarker
          With aAud(pAudPtr)\aCueMarker(n)
            ; \qMinFrameTimeForCueMarker will be set to nCueMarkerPosition minus half the time of a frame (based on the frame rate).
            \qMinFrameTimeForCueMarker = (\nCueMarkerPosition * 10000) - (qFrameTime / 2.0)
            ; \qMaxFrameTimeForCueMarker will be set to nCueMarkerPosition plus the time of a couple of frames to ensure the value returned by TVG in *frameinfo\frametime is definitely within the min and max times here.
            ; nb this is also to allow for the possibility of a dropped frame
            \qMaxFrameTimeForCueMarker = (\nCueMarkerPosition * 10000) + (qFrameTime * 4.0)
            debugMsg(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aCueMarker(" + n + ")\qMinFrameTimeForCueMarker=" + \qMinFrameTimeForCueMarker + ", \qMaxFrameTimeForCueMarker=" + \qMaxFrameTimeForCueMarker)
            \bCueMarkerProcessed = #False
          EndWith
        Next n
        TVG_SetOnFrameProgress2(nHandle, @eventTVGOnFrameProgress2())
        debugMsg(sProcName, "TVG_SetOnFrameProgress2(" + sHandle + ", @eventTVGOnFrameProgress2())")
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure.l adjustLeftIfNecessary(nHandle.i, nMonitorLeft.l)
  ; Added 23Oct2024 11.10.6at following issue reported by Martin Jan van Dale (and at least one other user)
  ; where the video's 'monitor' display was appearing over the top of the main video display.
  ; This only(?) occurs if screen 2 is to the left of screen 1, and then not always!
  PROCNAMEC()
  Protected sHandle.s
  Protected nMonitorLeftWork.l
  Protected nLongResult.l
  Protected nMonitorIndex
  Protected nMonitorsCount.l, nLeftBound.l, nTopBound.l, nRightBound.l, nBottomBound.l, nPrevLeftBound.l
  Protected bTrace = #False
  
  sHandle = decodeHandle(nHandle)
  debugMsgC(sProcName, #SCS_START + ", nHandle=" + sHandle + ", nMonitorLeft=" + nMonitorLeft)
  
  nMonitorLeftWork = nMonitorLeft
  nMonitorsCount = TVG_MonitorsCount(nHandle)
  debugMsgC2(sProcName, "TVG_MonitorsCount(" + sHandle + ")", nMonitorsCount)
  debugMsgC(sProcName, "nMonitorLeftWork=" + nMonitorLeftWork)
  If nMonitorsCount > #cMaxScreenNo
    nMonitorsCount = #cMaxScreenNo
    debugMsgC(sProcName, "nMonitorsCount reset to #cMaxScreenNo, ie nMonitorsCount=" + nMonitorsCount)
  EndIf
  For nMonitorIndex = 0 To (nMonitorsCount - 1)
    nLongResult = TVG_MonitorBounds(nHandle, nMonitorIndex, @nLeftBound, @nTopBound, @nRightBound, @nBottomBound)
    debugMsgC(sProcName, "TVG_MonitorBounds(" + sHandle + ", " + nMonitorIndex + ", @nLeftBound, @nTopBound, @nRightBound, @nBottomBound) returned " + strB(nLongResult))
    If nLongResult <> 0
      debugMsgC(sProcName, "nMonitorIndex=" + nMonitorIndex + ", nLeftBound=" + nLeftBound + ", nTopBound=" + nTopBound + ", nRightBound=" + nRightBound + ", nBottomBound=" + nBottomBound)
      If nMonitorIndex > 0
        nMonitorLeftWork + (nLeftBound - nPrevLeftBound)
      EndIf
      debugMsg(sProcName, "nMonitorIndex=" + nMonitorIndex + ", nMonitorLeftWork=" + nMonitorLeftWork)
      If nLeftBound >= 0
        debugMsgC(sProcName, "Break")
        Break
      EndIf
      nPrevLeftBound = nLeftBound
    EndIf
  Next nMonitorIndex
  
  debugMsgC(sProcName, #SCS_END + ", returning nMonitorLeftWork=" + nMonitorLeftWork)
  ProcedureReturn nMonitorLeftWork
  
EndProcedure

Procedure.l adjustTopIfNecessary(nHandle.i, nMonitorTop.l)
  ; Added 23Oct2024 11.10.6at following issue reported by Martin Jan van Dale (and at least one other user)
  ; where the video's 'monitor' display was appearing over the top of the main video display.
  ; This only(?) occurs if screen 2 is to the left of screen 1, and then not always!
  PROCNAMEC()
  Protected sHandle.s
  Protected nMonitorTopWork.l
  Protected nLongResult.l
  Protected nMonitorIndex
  Protected nMonitorsCount.l, nLeftBound.l, nTopBound.l, nRightBound.l, nBottomBound.l, nPrevLeftBound.l, nPrevTopBound.l
  Protected bTrace = #False
  
  sHandle = decodeHandle(nHandle)
  debugMsgC(sProcName, #SCS_START + ", nHandle=" + sHandle + ", nMonitorTop=" + nMonitorTop)
  
  nMonitorTopWork = nMonitorTop
  nMonitorsCount = TVG_MonitorsCount(nHandle)
  debugMsgC2(sProcName, "TVG_MonitorsCount(" + sHandle + ")", nMonitorsCount)
  debugMsgC(sProcName, "nMonitorTopWork=" + nMonitorTopWork)
  If nMonitorsCount > #cMaxScreenNo
    nMonitorsCount = #cMaxScreenNo
    debugMsgC(sProcName, "nMonitorsCount reset to #cMaxScreenNo, ie nMonitorsCount=" + nMonitorsCount)
  EndIf
  For nMonitorIndex = 0 To (nMonitorsCount - 1)
    nLongResult = TVG_MonitorBounds(nHandle, nMonitorIndex, @nLeftBound, @nTopBound, @nRightBound, @nBottomBound)
    debugMsgC(sProcName, "TVG_MonitorBounds(" + sHandle + ", " + nMonitorIndex + ", @nLeftBound, @nTopBound, @nRightBound, @nBottomBound) returned " + strB(nLongResult))
    If nLongResult <> 0
      debugMsgC(sProcName, "nMonitorIndex=" + nMonitorIndex + ", nLeftBound=" + nLeftBound + ", nTopBound=" + nTopBound + ", nRightBound=" + nRightBound + ", nBottomBound=" + nBottomBound)
      If nMonitorIndex > 0
        nMonitorTopWork + (nTopBound - nPrevTopBound)
      EndIf
      debugMsgC(sProcName, "nMonitorIndex=" + nMonitorIndex + ", nMonitorTopWork=" + nMonitorTopWork)
      If nLeftBound >= 0
        debugMsgC(sProcName, "Break")
        Break
      EndIf
      nPrevTopBound = nTopBound
    EndIf
  Next nMonitorIndex
  
  debugMsgC(sProcName, #SCS_END + ", returning nMonitorTopWork=" + nMonitorTopWork)
  ProcedureReturn nMonitorTopWork
  
EndProcedure

; EOF