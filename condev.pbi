; File: condev.pbi (connected devices)
; Modified

EnableExplicit

Macro incMaxConnectedDev()
  gnMaxConnectedDev + 1
  If gnMaxConnectedDev > ArraySize(gaConnectedDev())
    REDIM_ARRAY(gaConnectedDev, (gnMaxConnectedDev + 8), grConnectedDevDef, "gaConnectedDev()")
  EndIf
EndMacro

Procedure getConnectedAudDSandWASAPIDevs()
  PROCNAMEC()
  Protected nPass ; pass 1 for DirectSound, pass 2 for WASAPI
  Protected nDevice.l, nBassInitFlags.l ; longs
  Protected rInfo.BASS_INFO
  Protected rDeviceInfo.BASS_DEVICEINFO
  Protected nBassResult.l, nBassInitErrorCode.l   ; longs
  Protected nDevInitResult.l
  Protected nMySpeakers
  Protected nBassInitWindowHandle, sBassInitWindowHandle.s
  Protected nDeviceCount, nWasapiDevices
  Protected nBassErrorCode.l
  Protected sPhysicalDevDesc.s, sLowerDesc.s
  Protected nFreq.l, nFlags.l
  Protected nOutputs
  Protected sCheckingWASAPI.s, bPrefsOpenAtStart, sPrefGroupAtStart.s, sMsg.s, sOption.s, sDSWASAPI.s
  
  debugMsg(sProcName, #SCS_START)
  
  gnDSDeviceCount = 0
  gnWASAPIDeviceCount = 0
  
  If IsWindow(#WDU) = #False
    createfmDummy()
  EndIf
  If IsWindow(#WDU)
    nBassInitWindowHandle = WindowID(#WDU)
    sBassInitWindowHandle = "WindowID(#WDU)"
  ElseIf IsWindow(#WMN)
    nBassInitWindowHandle = WindowID(#WMN)
    sBassInitWindowHandle = "WindowID(#WMN)"
  ElseIf IsWindow(#WSP)
    nBassInitWindowHandle = WindowID(#WSP)
    sBassInitWindowHandle = "WindowID(#WSP)"
  EndIf
  
  ; Explanation: WASAPI does not appear to be properly supported by all device drivers. Some device drivers do not support WASAPI at all, which is fine - they do not cause a problem.
  ; The device drivers that do cause a problem are those that apparently support WASAPI but which stall during the call to BASS_Init(), ie during a call to BASS_Init() where the flags
  ; parameter does NOT have BASS_DEVICE_DSOUND set. Unfortunately we cannot predict when this will occur, and what users experience is that SCS won't start.
  ; From SCS 11.8.2ar, the preference key CheckingWASAPI has been created. This is set to Y prior to calling BASS_Init() and is removed after returning from BASS_Init(). So if SCS has
  ; to be aborted by the user while WASAPI initialization is stalled (in BASS_Init()) then on restarting SCS this preference key will still be set. SCS then displays a warning message
  ; and automaticlaly disables WASAPI by setting grDriverSettings\bNoWASAPI = #True.
  If grDriverSettings\bNoWASAPI
    debugMsg(sProcName, "grDriverSettings\bNoWASAPI=#True")
  Else
    COND_OPEN_PREFS("AudioDriverBASS")
    sCheckingWASAPI = ReadPreferenceString("CheckingWASAPI", "")
    If sCheckingWASAPI = "Y"
      sDSWASAPI = Lang("AudioDriver","BASS_DS") + "/" + Lang("AudioDriver","BASS_WASAPI")
      sOption = Lang("Init", "FnOptions") + " - " + Lang("WOP", "tabAudio") + " - " + sDSWASAPI
      sMsg = LangPars("Init", "WASAPINotStarting", sOption)
      MessageRequester(#SCS_TITLE, sMsg, #PB_MessageRequester_Warning)
      grDriverSettings\bNoWASAPI = #True
      WritePreferenceInteger("NoWASAPI", grDriverSettings\bNoWASAPI)
    Else
      sCheckingWASAPI = "Y"
      ; debugMsg(sProcName, "calling WritePreferenceString('CheckingWASAPI', '" + sCheckingWASAPI + "')")
      WritePreferenceString("CheckingWASAPI", sCheckingWASAPI)
    EndIf
    COND_CLOSE_PREFS()
  EndIf
  
  If grDriverSettings\bNoWASAPI = #False
    ; check that WASAPI is available
    nDeviceCount = 0
    nDevice = 1
    While BASS_GetDeviceInfo(nDevice, @rDeviceInfo)
      nDeviceCount + 1
      ; debugMsg(sProcName, "calling BASS_Init(" + nDevice + ", 44100, 0, " + sBassInitWindowHandle + ", 0)")
      nDevInitResult = BASS_Init(nDevice, 44100, 0, nBassInitWindowHandle, 0)
      ; debugMsg2(sProcName, "BASS_Init(" + nDevice + ", 44100, 0, " + sBassInitWindowHandle + ", 0)", nDevInitResult)
      If nDevInitResult = #BASSTRUE
        nBassResult = BASS_GetInfo(@rInfo)
        debugMsg(sProcName, "nDevice=" + nDevice + ", rInfo\speakers=" + rInfo\speakers)
        If rInfo\initflags & #BASS_DEVICE_DSOUND = 0
          nWasapiDevices + 1
        EndIf
        BASS_Free()
        ; debugMsg3(sProcName, "BASS_Free()")
      Else
        debugMsg2(sProcName, "BASS_Init(" + nDevice + ", 44100, 0, " + sBassInitWindowHandle + ", 0)", nDevInitResult)
        nBassInitErrorCode = BASS_ErrorGetCode()
        debugMsg(sProcName, "nBassInitErrorCode=" + getBassErrorDesc(nBassInitErrorCode))
      EndIf
      nDevice + 1
    Wend
    If (nDeviceCount > 0) And (nWasapiDevices = nDeviceCount)
      gbWasapiAvailable = #True
    EndIf
    debugMsg(sProcName, "nDeviceCount=" + nDeviceCount + ", nWasapiDevices=" + nWasapiDevices + ", gbWasapiAvailable=" + strB(gbWasapiAvailable))
  EndIf ; EndIf grDriverSettings\bNoWASAPI = #False
  
  ; debugMsg(sProcName, "sCheckingWASAPI=" + #DQUOTE$ + sCheckingWASAPI + #DQUOTE$)
  If sCheckingWASAPI
    COND_OPEN_PREFS("AudioDriverBASS")
    ; debugMsg(sProcName, "calling RemovePreferenceKey('CheckingWASAPI')")
    RemovePreferenceKey("CheckingWASAPI")
    COND_CLOSE_PREFS()
  EndIf
  
  For nPass = 1 To 2
    If nPass = 1
      debugMsg(sProcName, "nPass=1: DirectSound")
      nBassInitFlags = #BASS_DEVICE_DSOUND
    Else
      If gbWasapiAvailable = #False
        debugMsg(sProcName, "Break because gbWasapiAvailable=" + strB(gbWasapiAvailable))
        Break ; Break nPass
      EndIf
      debugMsg(sProcName, "nPass=2: WASAPI")
      nBassInitFlags = 0
    EndIf
    nDeviceCount = 0 ; counts number of devices, used or not
    nDevice = 1      ; first BASS real device number (ignores device 0, the 'no sound' device)
    
    While BASS_GetDeviceInfo(nDevice, @rDeviceInfo)
      If (nDevice = 1) And (rDeviceInfo\flags & #BASS_DEVICE_DEFAULT)
        sPhysicalDevDesc = grMMedia\sDefAudDevDesc
      Else
        sPhysicalDevDesc = Trim(VBStrFromAnsiPtr(rDeviceInfo\name))
      EndIf
      debugMsg(sProcName, "nDevice=" + nDevice + ", sPhysicalDevDesc=" + sPhysicalDevDesc + ", DefaultDev=" + strB(rDeviceInfo\flags & #BASS_DEVICE_DEFAULT))
      If nDevice > 1
        If sPhysicalDevDesc = grMMedia\sDefAudDevDesc
          ; ignore any device that happens to have the name reserved for the default device (this condition shouldn't occur)
          nDevice + 1
          Continue
        EndIf
      EndIf
      If rDeviceInfo\flags & #BASS_DEVICE_ENABLED
        nBassResult = BASS_SetDevice(nDevice)
        ; debugMsg2(sProcName, "BASS_SetDevice(" + nDevice + ")", nBassResult)
        If nBassResult = #BASSTRUE
          nBassResult = BASS_Free()
          ; debugMsg2(sProcName, "BASS_Free() for device = " + nDevice, nBassResult)
        EndIf
        nBassInitErrorCode = #BASS_OK
        nDevInitResult = BASS_Init(nDevice, 44100, nBassInitFlags, nBassInitWindowHandle, 0)
        If nDevInitResult = #BASSFALSE
          debugMsg2(sProcName, "BASS_Init(" + nDevice + ", 44100, " + decodeInitFlags(nBassInitFlags) + ", " + sBassInitWindowHandle + ", 0)", nDevInitResult)
          nBassInitErrorCode = BASS_ErrorGetCode()
          debugMsg(sProcName, "nBassInitErrorCode=" + getBassErrorDesc(nBassInitErrorCode))
          If nBassInitErrorCode = #BASS_ERROR_ALREADY
            ; already initialised, so treat as OK
            nDevInitResult = #BASSTRUE
          EndIf
        EndIf
        ; nb if device cannot be initialised then it may be an emulated device, such as "Modem #0 Line Playback (emulated)". Such devices are to be ignored.
        If nDevInitResult = #BASSTRUE
          nDeviceCount + 1
          grMMedia\nMaxBassDevice = nDevice
          incMaxConnectedDev()
          With gaConnectedDev(gnMaxConnectedDev)
            \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            If nPass = 1
              \nDriver = #SCS_DRV_BASS_DS
            Else
              \nDriver = #SCS_DRV_BASS_WASAPI
            EndIf
            \sPhysicalDevDesc = sPhysicalDevDesc
            sLowerDesc = Trim(LCase(sPhysicalDevDesc))
            \nDevice = nDevice
            \nBassInitErrorCode = nBassInitErrorCode
            nBassResult = BASS_GetInfo(@rInfo)
            ; debugMsg2(sProcName, "BASS_GetInfo(@rInfo)", nBassResult) ; not really necessary to log this
            \nSpeakers = rInfo\speakers
            \nOutputs = \nSpeakers
            debugMsg(sProcName, "rInfo\Speakers=" + rInfo\speakers + ", \latency=" + rInfo\latency)
            If (\nSpeakers = 0) And (nDevice = 0)
              \bNoSoundDevice = #True
              \nSpeakers = 2
              \nOutputs = \nSpeakers
            Else
              \bNoSoundDevice = #False
            EndIf
            If rDeviceInfo\flags & #BASS_DEVICE_DEFAULT
              \bDefaultDev = #True ; Added 1Aug2022 11.10.0
            EndIf
            nBassResult = BASS_Free()
            ; debugMsg2(sProcName, "BASS_Free() for device " + nDevice, nBassResult)
            \bInitialized = #False
          EndWith
          If nPass = 1
            gnDSDeviceCount + 1
          Else
            gnWASAPIDeviceCount + 1
          EndIf
          gnPhysicalAudDevs + 1
        EndIf
      EndIf
      nDevice + 1
    Wend
    
    If nPass = 1
      gaDriverInfo(#SCS_DRV_BASS_DS)\nDeviceCount = nDeviceCount
    Else
      gaDriverInfo(#SCS_DRV_BASS_WASAPI)\nDeviceCount = nDeviceCount
    EndIf
    
  Next nPass
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedAudASIODevs()
  PROCNAMEC()
  Protected nAsioDeviceCount
  Protected nASIODeviceNo.l ; long
  Protected rAsioDeviceInfo.BASS_ASIO_DEVICEINFO
  Protected rAsioInfo.BASS_ASIO_INFO
  Protected nBassResult.l, nErrorCode.l ; longs
  Protected nDevInitResult.l
  Protected nBassErrorCode.l
  Protected dBufferTime.d
  Protected sPhysicalDevDesc.s
  Protected bIgnoreThisDevice
  
  debugMsg(sProcName, #SCS_START)
  
  gnAsioDeviceCount = 0
  
  If grLicInfo\bASIOAvailable
    nAsioDeviceNo = 0     ; first BASS ASIO device number
    While #True
      bIgnoreThisDevice = #False
      debugMsg3(sProcName, "calling BASS_ASIO_GetDeviceInfo(" + nAsioDeviceNo + ", @rAsioDeviceInfo)")
      nBassResult = BASS_ASIO_GetDeviceInfo(nAsioDeviceNo, @rAsioDeviceInfo)
      debugMsg2(sProcName, "BASS_ASIO_GetDeviceInfo(" + nAsioDeviceNo + ", @rAsioDeviceInfo)", nBassResult)
      If nBassResult = #BASSFALSE
        Break
      EndIf
      ; debugMsg(sProcName, "rAsioDeviceInfo\name=" + Trim(VBStrFromAnsiPtr(rAsioDeviceInfo\name)) + ", \driver=" + Trim(VBStrFromAnsiPtr(rAsioDeviceInfo\driver)))
      sPhysicalDevDesc = Trim(VBStrFromAnsiPtr(rAsioDeviceInfo\name))
      If grLicInfo\sLicUser = "SFXacctforHWMS" And sPhysicalDevDesc = "Yamaha Steinberg USB ASIO"
        debugMsg(sProcName, "ignoring " + #DQUOTE$ + "Yamaha Steinberg USB ASIO" + #DQUOTE$)
        bIgnoreThisDevice = #True
      EndIf
      If bIgnoreThisDevice
        nASIODeviceNo + 1
        Continue
      EndIf
      nAsioDeviceCount + 1
      debugMsg3(sProcName, "calling BASS_ASIO_Init(" + nAsioDeviceNo + ", 0) [" + sPhysicalDevDesc + "]")
      nDevInitResult = BASS_ASIO_Init(nAsioDeviceNo, 0)
      debugMsg2(sProcName, "BASS_ASIO_Init(" + nAsioDeviceNo + ", 0) [" + sPhysicalDevDesc + "]", nDevInitResult)
      If nDevInitResult = #BASSFALSE
        nErrorCode = BASS_ASIO_ErrorGetCode()
        debugMsg3(sProcName, "Error " + nErrorCode + ": " + getBassErrorDesc(nErrorCode))
        If nErrorCode = #BASS_ERROR_ALREADY
          ; already initialized, so change nDevInitResult to #BASSTRUE
          debugMsg(sProcName, "changing nDevInitResult to #BASSTRUE")
          nDevInitResult = #BASSTRUE
        EndIf
      EndIf
      incMaxConnectedDev()
      With gaConnectedDev(gnMaxConnectedDev)
        \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
        \nDriver = #SCS_DRV_BASS_ASIO
        \sPhysicalDevDesc = sPhysicalDevDesc
        \nDevice = nAsioDeviceNo
        If nDevInitResult = #BASSTRUE ; could be #BASSFALSE if USB ASIO device not currently connected
          nBassResult = BASS_ASIO_GetInfo(@rAsioInfo)
          debugMsg2(sProcName, "BASS_ASIO_GetInfo(@rAsioInfo)", nBassResult)
          debugMsg(sProcName, "rAsioInfo\name=" + PeekS(@rAsioInfo\name,-1,#PB_Ascii) + ", \outputs=" + rAsioInfo\outputs +
                              ", \bufmin=" + rAsioInfo\bufmin + ", \bufmax=" + rAsioInfo\bufmax + ", \bufpref=" + rAsioInfo\bufpref)
          \nOutputs = rAsioInfo\outputs
          CompilerIf #cEnableASIOBufLen
            If grDriverSettings\nAsioBufLen >= 128
              \nAsioBufLen = grDriverSettings\nAsioBufLen
            ElseIf grDriverSettings\nAsioBufLen = #SCS_ASIOBUFLEN_MAX
              \nAsioBufLen = rAsioInfo\bufmax
            Else
              \nAsioBufLen = rAsioInfo\bufpref
            EndIf
          CompilerElse
            \nAsioBufLen = rAsioInfo\bufpref
          CompilerEndIf
          \dAsioSampleRate = BASS_ASIO_GetRate()
          debugMsg3(sProcName, "BASS_ASIO_GetRate() returned " + StrD(\dAsioSampleRate, 0))
          dBufferTime = \nAsioBufLen * 1000.0 / \dAsioSampleRate
          debugMsg3(sProcName, "dBufferTime=" + StrD(dBufferTime, 0))
          If dBufferTime > 500.0
            \nAsioBufLen = Int(0.5 * \dAsioSampleRate)
            If rAsioInfo\bufgran > 0
              \nAsioBufLen = Round(\nAsioBufLen / rAsioInfo\bufgran, #PB_Round_Down) * rAsioInfo\bufgran
            ElseIf rAsioInfo\bufgran < 0
              \nAsioBufLen = Round(\nAsioBufLen / 1024, #PB_Round_Down) * 1024
            EndIf
          Else
            If rAsioInfo\bufgran > 0
              \nAsioBufLen = Round(\nAsioBufLen / rAsioInfo\bufgran, #PB_Round_Nearest) * rAsioInfo\bufgran
            EndIf
          EndIf
          If \nAsioBufLen > rAsioInfo\bufmax
            \nAsioBufLen = rAsioInfo\bufmax
          EndIf
          debugMsg3(sProcName, "grDriverSettings\nAsioBufLen=" + decodeAsioBufLen(grDriverSettings\nAsioBufLen) +
                               ", gaAudioDev(" + gnPhysicalAudDevs + ")\nAsioBufLen=" + \nAsioBufLen +
                               ", \dAsioSampleRate=" + StrD(\dAsioSampleRate,0) + ", \nBassInitFlags=" + \nBassInitFlags)
          debugMsg(sProcName, "calling BASS_ASIO_Free")
          nBassResult = BASS_ASIO_Free()
          debugMsg2(sProcName, "BASS_ASIO_Free() for ASIO device " + nAsioDeviceNo, nBassResult)
        Else  ; BASS_ASIO_Init failed
          \nOutputs = 0
          \nAsioBufLen = 0
        EndIf
        \bInitialized = #False
      EndWith
      gnAsioDeviceCount + 1
      gnPhysicalAudDevs + 1
      nAsioDeviceNo + 1
    Wend
  EndIf
  
  With gaDriverInfo(#SCS_DRV_BASS_ASIO)
    If nAsioDeviceCount > 0
      ; \bPhysicalDevsPopulated = #True
      \nDeviceCount = nAsioDeviceCount
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedSMSDevs()
  PROCNAMEC()
  Protected bResult
  Protected nDeviceCount
  Protected nIndex, nStartIndex, nMaxIndex
  Protected nFieldNo, sField.s
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  ; added 10Dec2024
  ; The code below has been adjusted so that at startup it automatically test for a SM-M network connection, if SM-S is available then LTC will use SM-S to generate
  ; LTC as it used to. If no SM-S server is found it will default to the SCS LTC generator.
  If grLicInfo\bSMSAvailable
    If grSMS\nSMSClientConnection = 0
      debugMsg(sProcName, "calling primeAndInitSMS(#True)")
      bResult = primeAndInitSMS(#True)                            ; grSMS\nSMSClientConnection get set in here
      debugMsg(sProcName, "primeAndInitSMS() returned " + strB(bResult))
      If bResult = #False
        ; gbInloadArrayAudioDevs = #False
        ProcedureReturn #False
      EndIf
    EndIf
    
    nStartIndex = gnMaxConnectedDev + 1  ; hold for later use
    If grSMS\nSMSClientConnection                                  ; This is the test for SMS being active.
      sendSMSCommand("config get interfaces", #True)
      debugMsg(sProcName, "grSMS\sFirstWordLC=" + grSMS\sFirstWordLC)
      If grSMS\sFirstWordLC = "interfaces"
        grMMedia\nInterfaceCount = Val(StringField(gsSMSResponse(0), 2, " "))
        ; now extract the names of the interfaces from the multi-line response
        For n = 0 To (grMMedia\nInterfaceCount-1)
          incMaxConnectedDev()
          With gaConnectedDev(gnMaxConnectedDev)
            \nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT
            \nDriver = #SCS_DRV_SMS_ASIO
            If LCase(getSMSResponseField(n+2, 1)) = "interface"
              \sPhysicalDevDesc = getSMSResponseField(n+2, 3)
            EndIf
          EndWith
          gnPhysicalAudDevs + 1
        Next n
      Else
        ; shouldn't get here
        debugMsg(sProcName, "shouldn't get here")
        grMMedia\nInterfaceCount = 0 
      EndIf
      nMaxIndex = gnMaxConnectedDev
      
      debugMsg3(sProcName, "grMMedia\nInterfaceCount=" + grMMedia\nInterfaceCount)
      ; get specifics about each interface (if available)
      n = -1
      For nIndex = nStartIndex To nMaxIndex
        n + 1
        With gaConnectedDev(nIndex)
          sendSMSCommand("config get interface " + n, #True)
          If grSMS\sFirstWordLC = "interfaceinfo"
            \nInterfaceNo = n
            nFieldNo = 4
            sField = LCase(getSMSResponseField(1, nFieldNo))
            While sField
              Select sField
                Case "inputs"
                  \nInputs = Val(getSMSResponseField(1, nFieldNo+1))
                  nFieldNo + 2
                Case "outputs"
                  \nOutputs = Val(getSMSResponseField(1, nFieldNo+1))
                  nFieldNo + 2
                Case "defaultsamplerate"
                  \nDefaultSampleRate = Val(getSMSResponseField(1, nFieldNo+1))
                  nFieldNo + 2
                Default
                  nFieldNo + 1
              EndSelect
              sField = LCase(getSMSResponseField(1, nFieldNo))
            Wend
            debugMsg(sProcName, \sPhysicalDevDesc + ", Inputs=" + \nInputs + ", Outputs=" + \nOutputs + ", DefaultSampleRate=" + \nDefaultSampleRate)
          Else
            \nInterfaceNo = -1
            debugMsg(sProcName, \sPhysicalDevDesc + " NOT AVAILABLE")
          EndIf
        EndWith
      Next nIndex
      
      For nIndex = nStartIndex To nMaxIndex
        With gaConnectedDev(nIndex)
          If \nInputs > 0
            incMaxConnectedDev()
            gaConnectedDev(gnMaxConnectedDev) = gaConnectedDev(nIndex)
            gaConnectedDev(gnMaxConnectedDev)\nDevType = #SCS_DEVTYPE_LIVE_INPUT
          EndIf
        EndWith
      Next nIndex
      
      If nDeviceCount > 0
        gaDriverInfo(#SCS_DRV_SMS_ASIO)\nDeviceCount = nDeviceCount
      EndIf
      
      CompilerIf 1=2
        debugMsg(sProcName, "calling closeSMSConnection()")
        closeSMSConnection()
      CompilerEndIf
      
    EndIf ; EndIf bResult
    
  EndIf ; EndIf grLicInfo\bSMSAvailable
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedTVGDevs()
  PROCNAMEC()
  Protected nAudioDevCount.l, nVideoDevCount.l
  Protected *AudioRenderers, sAudioRenderers.s, sAudioRenderer.s
  Protected *VideoDevices, sVideoDevices.s, sVideoDevice.s
  Protected n
  Protected nTVGIndex, nTVGVideoSource.l
  Protected nIndex, nMaxIndex
  Protected nHandle.i, sHandle.s, bControlCreatedHere
  Protected nVidAudCount, nVidCapCount
  Protected *Subtypes, *Sizes, *Formats
  
  debugMsgT(sProcName, #SCS_START)
  
  ; start with an entry for the default audio device
  incMaxConnectedDev()
  With gaConnectedDev(gnMaxConnectedDev)
    \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
    \nDriver = #SCS_DRV_TVG
    \bDefaultDev = #True
    \sPhysicalDevDesc = grMMedia\sDefAudDevDesc
    \nDevice = -1 ; the TVG audio renderer number for 'default renderer' as used by _SetAudioRenderer() - although that will be overriden if gnDSDeviceCount = 0
    ; debugMsg(sProcName, "gaConnectedDev(" + gnMaxConnectedDev + ")\nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDevDesc=" + \sPhysicalDevDesc + ", \nDevice=" + \nDevice)
  EndWith
  nVidAudCount + 1
  
  debugMsg(sProcName, "gnDSDeviceCount=" + gnDSDeviceCount + ", grTVGControl\nTVGWorkControlIndex=" + grTVGControl\nTVGWorkControlIndex)
  
  If gnDSDeviceCount > 0
    If grTVGControl\nTVGWorkControlIndex >= 0
      nTVGIndex = grTVGControl\nTVGWorkControlIndex
    Else
      nTVGIndex = createTVGControl(#SCS_VID_PIC_TARGET_P, #SCS_VID_SRC_FILE, #True)
      debugMsgT2(sProcName, "createTVGControl(#SCS_VID_PIC_TARGET_P, #SCS_VID_SRC_FILE, #True)", nTVGIndex)
      If nTVGIndex >= 0
        If *gmVideoGrabber(nTVGIndex)
          newHandle(#SCS_HANDLE_TVG, *gmVideoGrabber(nTVGIndex))
          bControlCreatedHere = #True
        EndIf
      EndIf
    EndIf
    
    debugMsg(sProcName, "nTVGIndex=" + nTVGIndex)
    If nTVGIndex >= 0
      nHandle = *gmVideoGrabber(nTVGIndex)
      sHandle = decodeHandle(nHandle)
      ; debugMsgT(sProcName, "calling TVG_RefreshDevicesAndCompressorsLists(" + sHandle + ")")
      TVG_RefreshDevicesAndCompressorsLists(nHandle)
      debugMsgT(sProcName, "TVG_RefreshDevicesAndCompressorsLists(" + sHandle + ")")
      
      ; debugMsgT(sProcName, "calling TVG_GetAudioRenderersCount(" + sHandle + ")")
      nAudioDevCount = TVG_GetAudioRenderersCount(nHandle)
      debugMsgT2(sProcName, "TVG_GetAudioRenderersCount(" + sHandle + ")", nAudioDevCount)
      *AudioRenderers = TVG_GetAudioRenderers(nHandle)
      debugMsgT(sProcName, "TVG_GetAudioRenderers(" + sHandle + ") returned *AudioRenderers=" + *AudioRenderers)
      If *AudioRenderers
        sAudioRenderers = PeekS(*AudioRenderers)
      EndIf
      sAudioRenderers = RemoveString(sAudioRenderers, Chr(13))
      ; only store 'audio renderers' that match DirectSound device names loaded in getConnectedAudDSDevs() to avoid duplications caused by names
      ; like '1-2 (OCTA-CAPTURE)' and 'DirectSound: 1-2 (OCTA-CAPTURE)', both of which appear in the list returned by TVG_GetAudioRenderers()
      nMaxIndex = gnMaxConnectedDev ; lock nMaxIndex to the existing maximum, because gnMaxConnectedDev may be increased during the 'nIndex' loop below
      For n = 1 To nAudioDevCount
        sAudioRenderer = StringField(sAudioRenderers, n, Chr(10))
        If sAudioRenderer
          debugMsg(sProcName, "n=" + n + ", sAudioRenderer=" + #DQUOTE$ + sAudioRenderer + #DQUOTE$)
          For nIndex = 0 To nMaxIndex
            If sAudioRenderer <> grMMedia\sDefAudDevDesc
              If (gaConnectedDev(nIndex)\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (gaConnectedDev(nIndex)\nDriver = #SCS_DRV_BASS_DS)
                If sAudioRenderer = gaConnectedDev(nIndex)\sPhysicalDevDesc
                  ; want this audio renderer
                  incMaxConnectedDev()
                  With gaConnectedDev(gnMaxConnectedDev)
                    \nDevType = #SCS_DEVTYPE_VIDEO_AUDIO
                    \nDriver = #SCS_DRV_TVG
                    \sPhysicalDevDesc = sAudioRenderer
                    \nDevice = n - 1  ; \nDevice is the zero-based index of this audio renderer in the list of audio renderers returned by _GetAudioRenderers()
                                      ; \nDevice will subsequently be used by TVG_SetAudioRenderer()
                    ; debugMsg(sProcName, "gaConnectedDev(" + gnMaxConnectedDev + ")\nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDevDesc=" + \sPhysicalDevDesc + ", \nDevice=" + \nDevice)
                  EndWith
                  nVidAudCount + 1
                  Break
                EndIf
              EndIf
            EndIf
          Next nIndex
        EndIf
      Next n
      
      nVideoDevCount = TVG_GetVideoDevicesCount(nHandle)
      debugMsgT2(sProcName, "TVG_GetVideoDevicesCount(" + sHandle + ")", nVideoDevCount)
      *VideoDevices = TVG_GetVideoDevices(nHandle)
      If *VideoDevices
        sVideoDevices = sVideoDevices + PeekS(*VideoDevices)
      EndIf
      sVideoDevices = RemoveString(sVideoDevices, Chr(13))
      nTVGVideoSource = TVG_GetVideoSource(nHandle) ; hold existing video source ; corrected 26Feb2020 11.8.2.2au: was "nTVGVideoSource - ..." not "nTVGVideoSource = ..."
      TVG_SetVideoSource(nHandle, #tvc_vs_VideoCaptureDevice)
      For n = 1 To nVideoDevCount
        sVideoDevice = StringField(sVideoDevices, n, Chr(10))
        If sVideoDevice
          debugMsg(sProcName, "n=" + n + ", sVideoDevice=" + #DQUOTE$ + sVideoDevice + #DQUOTE$)
          ; added 20Mar2020 11.8.2.3ac following emails and logs from Janice Finke, where TVG hangs in TVG_SetVideoDevice() for the "Decklink Video Capture" device
          CompilerIf #c_ignore_Decklink_Video_Capture
            If sVideoDevice = "Decklink Video Capture"
              ; ignore this device
              Continue
            EndIf
          CompilerEndIf
          ; end added 20Mar2020 11.8.2.3ac
          incMaxConnectedDev()
          With gaConnectedDev(gnMaxConnectedDev)
            \nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
            \nDriver = #SCS_DRV_TVG
            \sPhysicalDevDesc = sVideoDevice
            \nDevice = n - 1  ; \nDevice is the zero-based index of this (capture) device in the list of devices returned by TVG_GetVideoDevices()
                              ; \nDevice will subsequently be used by TVG_SetVideoDevice()
            debugMsg(sProcName, "calling TVG_SetVideoDevice(" + sHandle + ", " + \nDevice + ")")
            TVG_SetVideoDevice(nHandle, \nDevice)
            debugMsg(sProcName, "TVG_SetVideoDevice(" + sHandle + ", " + \nDevice + ")")
            ; debugMsg(sProcName, "gaConnectedDev(" + gnMaxConnectedDev + ")\nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDevDesc=" + \sPhysicalDevDesc + ", \nDevice=" + \nDevice)
            \nSubtypesCount = TVG_GetVideoSubtypesCount(nHandle)
            debugMsgT2(sProcName, "TVG_GetVideoSubtypesCount(" + sHandle + ")", \nSubtypesCount)
            *Subtypes = TVG_GetVideoSubtypes(nHandle)
            debugMsgT(sProcName, "TVG_GetVideoSubtypes(" + sHandle + ") returned *Subtypes=" + *Subtypes)
            If *Subtypes
              \sSubtypes = PeekS(*Subtypes)
            Else
              \sSubtypes = ""
            EndIf
            \sSubtypes = RemoveString(\sSubtypes, Chr(13))
            debugMsgT(sProcName, "\sSubtypes=" + ReplaceString(\sSubtypes, Chr(10), ", "))
            
            \nSizesCount = TVG_GetVideoSizesCount(nHandle)
            debugMsgT2(sProcName, "TVG_GetVideoSizesCount(" + sHandle + ")", \nSizesCount)
            *Sizes = TVG_GetVideoSizes(nHandle)
            debugMsgT(sProcName, "TVG_GetVideoSizes(" + sHandle + ") returned *Sizes=" + *Sizes)
            If *Sizes
              \sSizes = PeekS(*Sizes)
            Else
              \sSizes = ""
            EndIf
            \sSizes = RemoveString(\sSizes, Chr(13))
            debugMsgT(sProcName, "\sSizes=" + ReplaceString(\sSizes, Chr(10), ", "))
            
            \nFormatsCount = TVG_GetVideoFormatsCount(nHandle)
            debugMsgT2(sProcName, "TVG_GetVideoFormatsCount(" + sHandle + ")", \nFormatsCount)
            *Formats = TVG_GetVideoFormats(nHandle)
            debugMsgT(sProcName, "TVG_GetVideoFormats(" + sHandle + ") returned *Formats=" + *Formats)
            If *Formats
              \sFormats = PeekS(*Formats)
            Else
              \sFormats = ""
            EndIf
            \sFormats = RemoveString(\sFormats, Chr(13))
            debugMsgT(sProcName, "\sFormats=" + ReplaceString(\sFormats, Chr(10), ", "))
            
            sortVidCapFormats(gnMaxConnectedDev)
            debugMsgT(sProcName, "\sFormatsSorted=" + ReplaceString(\sFormatsSorted, Chr(10), ", "))
            
          EndWith
          nVidCapCount + 1
        EndIf
      Next n
      
      ; Add the Dummy Port for Video Capture
      incMaxConnectedDev()
      With gaConnectedDev(gnMaxConnectedDev)
        \nDevType = #SCS_DEVTYPE_VIDEO_CAPTURE
        \nDriver = #SCS_DRV_TVG
        \sPhysicalDevDesc = Lang("VIDCAP", "DummyVidCapPort")
        \bDummy = #True
        \sFormats = LCase(grText\sTextDefault)
        \nFormatsCount = 1
        sortVidCapFormats(gnMaxConnectedDev)
        debugMsg(sProcName, "gaConnectedDev(" + gnMaxConnectedDev + ")\nDevType=" + decodeDevType(\nDevType) + ", \sPhysicalDevDesc=" + \sPhysicalDevDesc + ", \bDummy=" + strB(\bDummy) + ", \sFormatsSorted=" + \sFormatsSorted)
      EndWith
      nVidCapCount + 1
      
      debugMsg(sProcName, "calling TVG_SetVideoSource(" + sHandle + ", " + nTVGVideoSource + ")")
      TVG_SetVideoSource(nHandle, nTVGVideoSource) ; reinstate held video source
      debugMsg(sProcName, "returned from TVG_SetVideoSource(" + sHandle + ", " + nTVGVideoSource + ")")

      If bControlCreatedHere
        ; now destroy this TVG Control
        If nTVGIndex = grTVGControl\nMaxTVGIndex
          ; should always get here
          If nHandle
            debugMsg(sProcName, "calling TVG_DestroyVideoGrabber(" + sHandle + ")")
            TVG_DestroyVideoGrabber(nHandle)
            debugMsg(sProcName, "TVG_DestroyVideoGrabber(" + sHandle + ")")
            freeHandle(nHandle)
            nHandle = 0
          EndIf
          gaTVG(nTVGIndex) = grTVGDef
          grTVGControl\nMaxTVGIndex - 1
        EndIf
      EndIf
      
    EndIf
  EndIf
  
  gnNumVideoAudioDevs = nVidAudCount
  gnNumVideoCaptureDevs = nVidCapCount
  
  debugMsgT(sProcName, #SCS_END + ", gnNumVideoAudioDevs=" + gnNumVideoAudioDevs + ", gnNumVideoCaptureDevs=" + gnNumVideoCaptureDevs)
  
EndProcedure

Procedure getConnectedMidiInDevs()
  PROCNAMEC()
  Protected d, d2, n
  Protected midiError, nMidiInCount
  Protected sName.s
  Protected rMidiInCaps.MIDIINCAPS
  Protected nMidiDeviceID.l ; long
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; midi in devices (for midi control)
  nMidiInCount = midiInGetNumDevs_()
  debugMsg(sProcName, "nMidiInCount=" + Str(nMidiInCount))
  For d = 0 To (nMidiInCount - 1)
    nMidiDeviceID = d
    midiError = midiInGetDevCaps_(nMidiDeviceID, @rMidiInCaps, SizeOf(MIDIINCAPS))
    If midiError <> #MMSYSERR_NOERROR
      TraceMMErr(sProcName, " midiInGetDevCaps", midiError)
      Break
    EndIf
    sName = Trim(PeekS(@rMidiInCaps\szPname[0], 32))
    incMaxConnectedDev()
    With gaConnectedDev(gnMaxConnectedDev)
      \nDevType = #SCS_DEVTYPE_CC_MIDI_IN
      \sPhysicalDevDesc = sName
      \nMidiDeviceID = nMidiDeviceID
      \bWindowsMidiCompatible = #True
    EndWith
  Next d
  gnNumMidiInDevs = nMidiInCount
  
  ; add a dummy port
  incMaxConnectedDev()
  With gaConnectedDev(gnMaxConnectedDev)
    \nDevType = #SCS_DEVTYPE_CC_MIDI_IN
    \sPhysicalDevDesc = Lang("MIDI", "DummyInPort")
    \bDummy = #True
    \nMidiDeviceID = 0
    \bWindowsMidiCompatible = #False
  EndWith
  gnNumMidiInDevs + 1
  
  ; ensure midi in device names unique
  For d = 0 To gnMaxConnectedDev
    If gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
      sName = gaConnectedDev(d)\sPhysicalDevDesc
      n = 1
      For d2 = (d + 1) To gnMaxConnectedDev
        If gaConnectedDev(d2)\nDevType = #SCS_DEVTYPE_CC_MIDI_IN
          If gaConnectedDev(d2)\sPhysicalDevDesc = sName
            n + 1
            gaConnectedDev(d2)\sPhysicalDevDesc = sName + " #" + n
          EndIf
        EndIf
      Next d2
    EndIf
  Next d
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedMidiOutDevs()
  PROCNAMEC()
  Protected d, d2, n, nLastDev
  Protected midiError, nMidiOutCount
  Protected sName.s
  Protected rMidiOutCaps.MIDIOUTCAPS
  Protected nMidiDeviceID.l
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; midi out devices (for control send)
  nMidiOutCount = midiOutGetNumDevs_()
  debugMsg(sProcName, "nMidiOutCount=" + Str(nMidiOutCount))
  For d = 0 To (nMidiOutCount - 1)
    nMidiDeviceID = d
    midiError = midiOutGetDevCaps_(nMidiDeviceID, @rMidiOutCaps, SizeOf(MIDIOUTCAPS))
    If midiError <> #MMSYSERR_NOERROR
      TraceMMErr(sProcName, "midiOutGetDevCaps", midiError)
      Break
    EndIf
    sName = Trim(PeekS(@rMidiOutCaps\szPname[0], 32))
    incMaxConnectedDev()
    With gaConnectedDev(gnMaxConnectedDev)
      \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
      \sPhysicalDevDesc = sName
      \nMidiDeviceID = nMidiDeviceID
      \bWindowsMidiCompatible = #True
      If sName = "Microsoft GS Wavetable Synth"  ; ignore "Microsoft GS Wavetable Synth" - not wanted for SCS Control Sends
        \bIgnoreDev = #True
      EndIf
    EndWith
  Next d
  gnNumMidiOutDevs = nMidiOutCount
  
  ; now check for any Enttec DMX USB PRO Mk2 devices as they have MIDI capability
  ; nb using the DMX IN devtype
  nLastDev = gnMaxConnectedDev
  For n = 0 To nLastDev
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_CC_DMX_IN
      If gaConnectedDev(n)\nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
        sName = gaConnectedDev(n)\sPhysicalDevDesc
        If gaConnectedDev(n)\nSerial
          sName + " (" + gaConnectedDev(n)\nSerial + ")"
        EndIf
        incMaxConnectedDev()
        With gaConnectedDev(gnMaxConnectedDev)
          \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
          \sPhysicalDevDesc = sName
          \bWindowsMidiCompatible = #False
          \bEnttecMidi = #True
          ;\nDevice = gaConnectedDev(n)\nDevice  ; will be passed to DMX_FTDI_OpenDevice()
          \nSerial = gaConnectedDev(n)\nSerial
          \sSerial = gaConnectedDev(n)\sSerial
        EndWith
        gnNumMidiOutDevs + 1
      EndIf
    EndIf
  Next n
  
  ; add a dummy port
  incMaxConnectedDev()
  With gaConnectedDev(gnMaxConnectedDev)
    \nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
    \sPhysicalDevDesc = Lang("MIDI", "DummyOutPort")
    \bDummy = #True
    \nMidiDeviceID = 0
    \bWindowsMidiCompatible = #False
  EndWith
  gnNumMidiOutDevs + 1
  
  ; ensure midi out device names unique
  For d = 0 To gnMaxConnectedDev
    If gaConnectedDev(d)\nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
      sName = gaConnectedDev(d)\sPhysicalDevDesc
      n = 1
      For d2 = (d + 1) To gnMaxConnectedDev
        If gaConnectedDev(d2)\nDevType = #SCS_DEVTYPE_CS_MIDI_OUT
          If gaConnectedDev(d2)\sPhysicalDevDesc = sName
            n + 1
            gaConnectedDev(d2)\sPhysicalDevDesc = sName + " #" + n
          EndIf
        EndIf
      Next d2
    EndIf
  Next d
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedRS232InDevs()
  PROCNAMEC()
  Protected p
  Protected sRS232PortAddress.s
  Protected sRS232PortAddressForCF.s   ; port address for CreateFile_()
  Protected hPort.l, bPortExists, dwError.l
  Protected nLongResult.l
  Protected nDebugLimit = -1  ; -1 = only debug successes
  
  debugMsg(sProcName, #SCS_START)
  
  gnMaxRS232Control = -1
  ; debugMsg0(sProcName, "gnMaxRS232Control=" + gnMaxRS232Control)
  
  ; Added 30Mar2023 11.10.0ar
  For p = 0 To 255
    If IsSerialPort(p)
      debugMsg(sProcName, "calling CloseSerialPort(" + p + ")")
      CloseSerialPort(p)
    EndIf
  Next p
  ; End added 30Mar2023 11.10.0ar
  
  For p = 0 To 255
    sRS232PortAddress = "COM" + Str(p+1)
    sRS232PortAddressForCF = "\\.\COM" + Str(p+1)
    bPortExists = #False
    
    ; debugMsg(sProcName, "calling CreateFile_(" + sRS232PortAddressForCF + ", #GENERIC_READ | #GENERIC_WRITE, 0, 0, #OPEN_EXISTING, 0, 0)")
    hPort = CreateFile_(sRS232PortAddressForCF, #GENERIC_READ | #GENERIC_WRITE, 0, 0, #OPEN_EXISTING, 0, 0)
    If (p <= nDebugLimit) Or (hPort >= 0)
      debugMsg2(sProcName, "CreateFile_(" + sRS232PortAddressForCF + ", #GENERIC_READ | #GENERIC_WRITE, 0, 0, #OPEN_EXISTING, 0, 0)", hPort)
    EndIf
    
    If hPort = #INVALID_HANDLE_VALUE   ; nb #INVALID_HANDLE_VALUE = -1
      ; debugMsg(sProcName, "calling CreateFile_(" + sRS232PortAddressForCF + ", 0, 0, 0, #OPEN_EXISTING, 0, 0)")
      hPort = CreateFile_(sRS232PortAddressForCF, 0, 0, 0, #OPEN_EXISTING, 0, 0)
      If (p <= nDebugLimit) Or (hPort >= 0)
        debugMsg2(sProcName, "CreateFile_(" + sRS232PortAddressForCF + ", 0, 0, 0, #OPEN_EXISTING, 0, 0)", hPort)
      EndIf
    EndIf
    
    If hPort = #INVALID_HANDLE_VALUE
      dwError = GetLastError_()
      ; debugMsg0(sProcName, sRS232PortAddress + " hPort=#INVALID_HANDLE_VALUE: GetLastError_() returned " + dwError)
      If (dwError = #ERROR_ACCESS_DENIED) Or (dwError = #ERROR_GEN_FAILURE) Or (dwError = #ERROR_SHARING_VIOLATION) Or (dwError = #ERROR_SEM_TIMEOUT)
        bPortExists = #True
        ; debugMsg0(sProcName, sRS232PortAddress + " exists but CreateFile_() failed - dwError=" + dwError)
      EndIf
    Else
      nLongResult = CloseHandle_(hPort)
      ; debugMsg0(sProcName, sRS232PortAddress + " CloseHandle_(" + hPort + ") returned " + nLongResult)
      bPortExists = #True
    EndIf
    ; debugMsg0(sProcName, sRS232PortAddress + " bPortExists=" + strB(bPortExists))
    If bPortExists
      incMaxConnectedDev()
      With gaConnectedDev(gnMaxConnectedDev)
        \nDevType = #SCS_DEVTYPE_CC_RS232_IN
        \sPhysicalDevDesc = sRS232PortAddress
      EndWith
      gnMaxRS232Control + 1
      ; debugMsg(sProcName, sRS232PortAddress + " gnMaxRS232Control=" + gnMaxRS232Control)
    EndIf
  Next p
  
  ; add a dummy port
  incMaxConnectedDev()
  With gaConnectedDev(gnMaxConnectedDev)
    \nDevType = #SCS_DEVTYPE_CC_RS232_IN
    \sPhysicalDevDesc = Lang("RS232", "Dummy")
    \bDummy = #True
  EndWith
  gnMaxRS232Control + 1
  ; debugMsg(sProcName, "gnMaxRS232Control=" + gnMaxRS232Control)
  
  debugMsg(sProcName, #SCS_END + ", gnMaxRS232Control=" + gnMaxRS232Control)

EndProcedure

Procedure getConnectedRS232OutDevs()
  PROCNAMEC()
  Protected nIndex, nMaxIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  nMaxIndex = gnMaxConnectedDev
  For nIndex = 0 To nMaxIndex
    If gaConnectedDev(nIndex)\nDevType = #SCS_DEVTYPE_CC_RS232_IN
      incMaxConnectedDev()
      gaConnectedDev(gnMaxConnectedDev) = gaConnectedDev(nIndex)
      With gaConnectedDev(gnMaxConnectedDev)
        \nDevType = #SCS_DEVTYPE_CS_RS232_OUT
      EndWith
    EndIf
  Next nIndex
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getConnectedDMXInDevs()
  PROCNAMEC()
  ; nb also used for DMX Out as most devices can be used for both input and output
  Protected nNumDMXDevs.l   ; long
  Protected nTmp.l          ; long
  Protected nDevIndex.l
  Protected ftStatus.l
  Protected nFlags.l, nID.l, nType.l, nLocId.l  ; all longs as they are return variables from FT_GetDeviceInfoDetail()
  Protected *pSerialNumber, *pDescription
  Protected sSerialNumber.s, sDescription.s, nDMXDevType.i
  Protected *ftHandleTemp
  Protected nSerial.l, bResult, bRecognizedDevice
  Protected nIpResult.i
  
  debugMsg(sProcName, #SCS_START + ", gbFTD2XXAvailable=" + strB(gbFTD2XXAvailable))
  
  grDMX\nNumDMXDevs = 0
  If gbFTD2XXAvailable
    ; note: the call to FT_ListDevices() may seem superfluous as nNumDMXDevs is also populated by the subsequent call to FT_CreateDeviceInfoList(),
    ; which must be called prior to calls to FT_GetDeviceInfoDetail(). BUT, in a test run by Matt Hughes in a pre-release version of 11.5.0 which did not have
    ; the call to FT_ListDevices(), the program threw a memory error on the call to FT_CreateDeviceInfoList(), but only on one of his machines.
    ; That error had not occured in earlier versions that did include the call to FT_ListDevices(), which is why this call has now been reinstated.
    ; 15-12-2023 Addendum by Dee, During testing I came across a bug where the stack was getting corrupted if debug was turned on in the compiler and a DMX dongle was attached.
    ; Upon close examination of the code and documentation I noticed that Parameter 2 For FT_ListDevices should be NULL To get the number of devices
    ; Also ftHandleTemp needed To be changed To a pointer As this is declared As a PVOID pointer in the FTD api.
    ; This may be the cause of Matt Hughes memory crash in a pre-release version of 11.5.0.
    ftStatus = FT_ListDevices(@nNumDMXDevs, 0, #FT_LIST_NUMBER_ONLY)
    debugMsg2(sProcName, "FT_ListDevices(@nNumDMXDevs, 0, FT_LIST_NUMBER_ONLY)", ftStatus)
    If (ftStatus = #FT_OK) And (nNumDMXDevs > 0)
      ftStatus = FT_CreateDeviceInfoList(@nNumDMXDevs)
      debugMsg2(sProcName, "FT_CreateDeviceInfoList(@nNumDMXDevs)", ftStatus)
      If ftStatus = #FT_OK
        grDMX\nNumDMXDevs = nNumDMXDevs
      EndIf
    EndIf
  EndIf
  debugMsg3(sProcName, "grDMX\nNumDMXDevs=" + grDMX\nNumDMXDevs)

  If nNumDMXDevs > 0
    *pDescription = AllocateMemory(256)
    *pSerialNumber = AllocateMemory(128)
    If (*pDescription) And (*pSerialNumber)
      For nDevIndex = 0 To (nNumDMXDevs-1)
        ftStatus = FT_GetDeviceInfoDetail(nDevIndex, @nFlags, @nType, @nID, @nLocId, *pSerialNumber, *pDescription, *ftHandleTemp)
        debugMsg2(sProcName, "FT_GetDeviceInfoDetail(" + nDevIndex + ", @nFlags, @nType, @nID, @nLocId, *pSerialNumber, *pDescription, *ftHandleTemp)", ftStatus)
        If ftStatus = #FT_OK
          debugMsg(sProcName, "ftStatus=#FT_OK")
          bRecognizedDevice = #True
          sDescription = PeekS(*pDescription, MemorySize(*pDescription), #PB_Ascii)
          sSerialNumber = PeekS(*pSerialNumber, MemorySize(*pSerialNumber), #PB_Ascii)
          debugMsg(sProcName, "sDescription=" + sDescription + ", sSerialNumber=" + sSerialNumber)
          debugMsg(sProcName, "nFlags=$" + Hex(nFlags, #PB_Long) + ", nType=$" + Hex(nType, #PB_Long) + ", nID=$" + Hex(nID, #PB_Long) + ", nLocId=$" + Hex(nLocId, #PB_Long))
          Select UCase(sDescription)
            Case "DMX USB PRO"
              nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
            Case "DMX USB PRO MK2", "FT245R USB FIFO"
              ; added "FT245R USB FIFO" 12Nov2019 11.8.2rc2 as this appears to be the description published by new versions of the Enttec DMX USB PRO MK2
              nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
            Case "USB <-> SERIAL", "FT232R USB UART"
              nDMXDevType = #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB
            Default
              If Left(sDescription,9) = "USB-RS485"
                nDMXDevType = #SCS_DMX_DEV_FTDI_USB_RS485
              Else
                nDMXDevType = #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB
              EndIf
          EndSelect
          Select nDMXDevType
            Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO, #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
              bResult = DMX_getDMXNumericSerial(nDevIndex, @nSerial)
              If bResult = #False
                bRecognizedDevice = #False
              EndIf
          EndSelect
          If bRecognizedDevice
            incMaxConnectedDev()
            With gaConnectedDev(gnMaxConnectedDev)
              \nDevType = #SCS_DEVTYPE_CC_DMX_IN   ; may also be used for identifying #SCS_DEVTYPE_LT_DMX_OUT devices
              \sPhysicalDevDesc = sDescription
              \sSerial = sSerialNumber
              \nSerial = nSerial
              \nDevice = nDevIndex
              \nDMXDevType = nDMXDevType
              Select nDMXDevType
                Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
                  \nDMXPorts = 2
                Default
                  \nDMXPorts = 1
              EndSelect
            EndWith
          EndIf
        Else ; FT_GetDeviceInfoDetail() failed
          debugMsg(sProcName, "FT_GetDeviceInfoDetail(" + nDevIndex + ", ...) returned ftStatus=" + ftStatus)
        EndIf
      Next nDevIndex
    Else
      debugMsg(sProcName, "Memory allocation error!  DMX device(s) not added.")
    EndIf
    
    ; Freemen(s) moved as it was freeing both when it may have only have 1 allocated and so potential crash or memory leak.
    If *pSerialNumber
      FreeMemory(*pSerialNumber)
    EndIf
    
    If *pDescription
      FreeMemory(*pDescription)
    EndIf
  EndIf
  
  ; add a dummy IN port
  incMaxConnectedDev()
  With gaConnectedDev(gnMaxConnectedDev)
    \nDevType = #SCS_DEVTYPE_CC_DMX_IN ; may also be used for the dummy #SCS_DEVTYPE_LT_DMX_OUT device
    \sPhysicalDevDesc = Lang("DMX", "Dummy")
    \nDMXPorts = 1
    \bDummy = #True
    \nDMXDevType = #SCS_DMX_DEV_NONE
  EndWith
  grDMX\nNumDMXDevs + 1
  
  ; Check for an IP address, if so we can add Artnet and sACn devices 
  nIpResult = ExamineIPAddresses(#PB_Network_IPv4)
  
  If nIpResult
    ; add Artnet
    incMaxConnectedDev()
    With gaConnectedDev(gnMaxConnectedDev)
      \nDevType = #SCS_DEVTYPE_CC_DMX_IN
      \sPhysicalDevDesc = "Art-Net" ; "Artnet"
      \nDMXPorts = 2
      \bDummy = #False
      \nDMXDevType = #SCS_DMX_DEV_ARTNET
    EndWith
    grDMX\nNumDMXDevs + 1
    
    ; add sACN
    incMaxConnectedDev()
    With gaConnectedDev(gnMaxConnectedDev)
      \nDevType = #SCS_DEVTYPE_CC_DMX_IN
      \sPhysicalDevDesc = "sACN"
      \nDMXPorts = 2
      \bDummy = #False
      \nDMXDevType = #SCS_DMX_DEV_SACN
    EndWith
    grDMX\nNumDMXDevs + 1
  EndIf
EndProcedure

Procedure getConnectedDevs()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  ; note: license level 'preference' and audio driver options must be loaded before calling this procedure
  ; nb failure of either of the following should not occur in released versions!
  If grLicInfo\bCommonPrefsLoaded = #False
    scsMessageRequester(sProcName, "Common Prefs not yet loaded", #MB_ICONERROR)
  ElseIf grLicInfo\bDriverOptionsLoaded = #False
    scsMessageRequester(sProcName, "Driver Options not yet loaded", #MB_ICONERROR)
  EndIf
  
  If IsWindow(#WMN) = #False
    ; ensure window #WMN is created so that BASS_Init() can use this as "the application's main window". see comments about this at the start of mmInit().
    debugMsg(sProcName, "calling createfmMain()")
    createfmMain()
  EndIf

  ; start with a clean list
  gnMaxConnectedDev = -1
  gnPhysicalAudDevs = 0
  For n = 0 To ArraySize(gaConnectedDev())
    gaConnectedDev(n) = grConnectedDevDef
  Next n
  
  getConnectedAudDSandWASAPIDevs() ; get connected DirectSound and WASAPI devices
  getConnectedAudASIODevs() ; get connected ASIO devices
  getConnectedSMSDevs() ; get connected SoundMan-Server devices
  
  ; prerequisite: getConnectedAudDSandWASAPIDevs() must be called before getConnectedTVGDevs()
  getConnectedTVGDevs() ; get connected TVideoGrabber devices (nb includes video capture devices)
  
  ; close any DMX devices before calling loadArrayDMXDevs() because DMX device numbers may change inside loadArrayDMXDevs() following a call to FT_CreateDeviceInfoList()
  DMX_closeDMXDevs()
  getConnectedDMXInDevs() ; get connected DMX devices
  
  ; must call getConnectedMidiInDevs() and getConnectedMidiOutDevs() AFTER calling getConnectedDMXInDevs() as these MIDI procedures may add Enttec USB PRO Mk2 devices
  getConnectedMidiInDevs(); get connected MIDI In devices
  getConnectedMidiOutDevs() ; get connected MIDI Out devices
  
  getConnectedRS232InDevs() ; get connected RS232 In devices
  getConnectedRS232OutDevs(); get connected RS232 Out devices
  
  CompilerIf #c_scsltc ; Modified 18Feb2025 as scsltc not available
    ; Added 19Dec2024
    If grLicInfo\bLTCAvailable
      CompilerIf #c_scsltc
        gn_ScsLTCAllowed = #False
        THR_suspendAThread(#SCS_THREAD_SCS_LTC)
      CompilerElse
        If gnCurrAudioDriver = #SCS_DRV_SMS_ASIO And grSMS\nSMSClientConnection
          gn_ScsLTCAllowed = #False
          THR_suspendAThread(#SCS_THREAD_SCS_LTC)
        Else
          THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)            ; No SMS server so enable internal LTC, Modified by Dee 29-01-2025 to disable SCSLTC
          gn_ScsLTCAllowed = #True
        EndIf
        debugMsg(sProcName, "gnCurrAudioDriver=" + decodeDriver(gnCurrAudioDriver) + ", gn_ScsLTCAllowed=" + strB(gn_ScsLTCAllowed))
      CompilerEndIf
    EndIf
    ; End added 19Dec2024
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END + ", gnMaxConnectedDev=" + gnMaxConnectedDev + ", gnPhysicalAudDevs=" + gnPhysicalAudDevs)
  
EndProcedure

Procedure sortConnectedDevs()
  PROCNAMEC()
  ; nb sorts devices to match the sorting order of sortPhysDevs() etc
  ; the reason for sorting is to make sure the order of the 'connected devices' matches that displayed under physical device combo boxes
  Protected n1, n2, bSwapped
  Protected rConnectedDev.tyConnectedDev
  Protected sSortKey.s, sDefKey.s
  Protected nRegularExpression
  Protected sPhysDevWithExpandedNumbers.s
  
  For n1 = 0 To gnMaxConnectedDev
    With gaConnectedDev(n1)
      sSortKey = StrN(\nDevType, 2)   ; first part of sort key is the device type (as 2-digit numeric)
      Select \nDevType
        Case #SCS_DEVTYPE_AUDIO_OUTPUT, #SCS_DEVTYPE_VIDEO_AUDIO
          sSortKey + \nDriver  ; for audio output and video audio, the driver
          If \bDefaultDev
            sDefKey = "1" ; default pseudo device is sorted before real devices
          Else
            sDefKey = "2"
          EndIf
          If (\nDevType = #SCS_DEVTYPE_AUDIO_OUTPUT) And (\nDriver = #SCS_DRV_BASS_DS)
            If (\nDevice = 1) And (\bDefaultDev)
              sDefKey = "1"
            Else
              sDefKey = "2"
            EndIf
          EndIf
          sSortKey + sDefKey
          Select \nDriver
            Case #SCS_DRV_BASS_ASIO, #SCS_DRV_SMS_ASIO
              sSortKey + StrN((9999 - \nOutputs), 4) + StrN((9999 - \nInputs), 4)
          EndSelect
          
          ; Expand numbers within \sPhysicalDevDesc for sorting purposes
          ; eg change "1-2 (OCTA-CAPTURE)" to "0001-0002 (OCTA-CAPTURE)"
          ; This is to ensure that something like "11-12..." does NOT get sorted between "1-2..." and "3-4...".
          ; Since this part of the sort key will be followed by the original order sequence (ie n1) this should result in such devices appearing in their correct 'outputs' order.
          ; NB Expanding numbers will also exapnd other numbers, eg "ASUS VK266H" will be sorted as "ASUS VK0266H" but that shouldn't matter in this sort.
          sPhysDevWithExpandedNumbers = expandNumbersInString(\sPhysicalDevDesc, 4)
          sSortKey + UCase(sPhysDevWithExpandedNumbers)
          
      EndSelect
      \sSortKey = sSortKey + StrN(n1, 4)  ; finally, add the current sequence (n1) to retain current order within items with the same sort key up to this point
    EndWith
  Next n1
  
  ; now sort the array
  For n1 = 0 To (gnMaxConnectedDev - 1)
    bSwapped = #False
    For n2 = 0 To (gnMaxConnectedDev - 1)
      If (gaConnectedDev(n2)\sSortKey > gaConnectedDev(n2 + 1)\sSortKey)
        ; exchange the items
        rConnectedDev = gaConnectedDev(n2)
        gaConnectedDev(n2) = gaConnectedDev(n2 + 1)
        gaConnectedDev(n2 + 1) = rConnectedDev
        bSwapped = #True
      EndIf
    Next n2
    If bSwapped = #False
      Break
    EndIf
  Next n1
  
;   For n1 = 0 To gnMaxConnectedDev
;     debugMsg(sProcName, "gaConnectedDev(" + n1 + ")\sSortKey=" + gaConnectedDev(n1)\sSortKey)
;   Next n1
  
EndProcedure

Procedure listConnectedDevs()
  PROCNAMEC()
  Protected n
  Protected sLine.s
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To gnMaxConnectedDev
    With gaConnectedDev(n)
      sLine = Str(n) + " " + decodeDevType(\nDevType)
      If \nDriver
        sLine + "(" + decodeDriver(\nDriver) + ")"
      EndIf
      sLine + " " + #DQUOTE$ + \sPhysicalDevDesc + #DQUOTE$
      If (\nDevice >= 0) Or (\bDefaultDev)
        sLine + ", \nDevice=" + \nDevice
      EndIf
      If \bDefaultDev
        sLine + ", \bDefaultDev=" + strB(\bDefaultDev)
      EndIf
      Select \nDevType
        Case #SCS_DEVTYPE_AUDIO_OUTPUT
          If \nSpeakers > 0
            sLine + ", \nSpeakers=" + \nOutputs
          ElseIf \nOutputs > 0
            sLine + ", \nOutputs=" + \nOutputs
          EndIf
        Case #SCS_DEVTYPE_LIVE_INPUT
          sLine + ", \nInputs=" + \nInputs
        Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
          If \bDummy = #False
            sLine + ", \sSerial=" + \sSerial + ", \nSerial=" + \nSerial + ", \nDMXDevType=" + decodeDMXDevType(\nDMXDevType) + ", \nDMXPorts=" + \nDMXPorts
          EndIf
        Case #SCS_DEVTYPE_CC_MIDI_IN, #SCS_DEVTYPE_CS_MIDI_OUT
          sLine + ", \nMidiDeviceID=" + \nMidiDeviceID
          If \bDummy = #False
            sLine + ", \bWindowsMidiCompatible=" + strB(\bWindowsMidiCompatible)
          EndIf
      EndSelect
      debugMsg(sProcName, sLine)
    EndWith
  Next n
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure getAllPhysicalDevices()
  PROCNAMEC()
  
  debugMsg(sProcName, #SCS_START)
  
  gnPhysicalAudDevs = 0
  
  debugMsg(sProcName, "calling getConnectedDevs()")
  getConnectedDevs()
  debugMsg(sProcName, "calling sortConnectedDevs()")
  sortConnectedDevs()
  debugMsg(sProcName, "calling listConnectedDevs()")
  listConnectedDevs()
  
  ; debugMsg(sProcName, "calling loadArrayAudioDevs()")
  loadArrayAudioDevs()
  ; debugMsg(sProcName, "calling loadArrayVideoAudioDevs()")
  loadArrayVideoAudioDevs()
  ; debugMsg(sProcName, "calling loadArrayVideoCaptureDevs()")
  loadArrayVideoCaptureDevs()
  ; debugMsg(sProcName, "calling loadArrayMidiDevs()")
  loadArrayMidiDevs()
  ; debugMsg(sProcName, "calling initRS232Control()")
  initRS232Control()
  ; debugMsg(sProcName, "calling DMX_loadArrayDMXDevs()")
  DMX_loadArrayDMXDevs()
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure sortVidCapFormats(nConnectedDevPtr)
  PROCNAMEC()
  Protected sFormats.s, nFormatsCount, nFormatIndex, sFormatsSorted.s, sSortKey.s
  Protected sSizes.s, nSizesCount, nSizeIndex, sSize.s, sSizeIndexChar.s
  Structure tyFormatSort
    sSortKey.s
    sFormat.s
  EndStructure
  Static Dim aFormatSort.tyFormatSort(0)
  
  With gaConnectedDev(nConnectedDevPtr)
    sFormats = \sFormats
    nFormatsCount = \nFormatsCount
    If nFormatsCount > ArraySize(aFormatSort())
      ReDim aFormatSort(nFormatsCount)
    EndIf
    For nFormatIndex = 1 To nFormatsCount
      aFormatSort(nFormatIndex)\sFormat = StringField(sFormats, nFormatIndex, Chr(10))
      If nFormatIndex = 1
        ; first entry is always 'default' and must remain as the first entry, sort prefix the sort key with "a."
        aFormatSort(nFormatIndex)\sSortKey = "a." + aFormatSort(nFormatIndex)\sFormat
      Else
        ; prefix all other entries with "b."
        aFormatSort(nFormatIndex)\sSortKey = "b." + aFormatSort(nFormatIndex)\sFormat
      EndIf
    Next nFormatIndex
    
    sSizes = \sSizes
    nSizesCount = CountString(sSizes, Chr(10)) + 1
    For nSizeIndex = 2 To nSizesCount ; start from 2 because size 1 will be 'default'
      sSizeIndexChar = "[" + RSet(Hex(nSizeIndex), 2, "0") + "]" ; brackets ensure 'size' will not be picked up again in another test or pass
      sSize = StringField(sSizes, nSizeIndex, Chr(10))
      ; debugMsg(sProcName, "sSize=" + sSize + ", sSizeIndexChar=" + sSizeIndexChar)
      For nFormatIndex = 1 To nFormatsCount
        ; debugMsg(sProcName, "FindString(" + #DQUOTE$ + aFormatSort(nFormatIndex)\sSortKey + #DQUOTE$ + ", " + #DQUOTE$ + sSize + #DQUOTE$ + ")=" + FindString(aFormatSort(nFormatIndex)\sSortKey, sSize))
        If FindString(aFormatSort(nFormatIndex)\sSortKey, sSize) > 0
          sSortKey = aFormatSort(nFormatIndex)\sSortKey
          aFormatSort(nFormatIndex)\sSortKey = ReplaceString(sSortKey, sSize, sSizeIndexChar)
          ; debugMsg(sProcName, "SIZE REPLACED, aFormatSort(" + nFormatIndex + ")\sSortKey=" + aFormatSort(nFormatIndex)\sSortKey)
        EndIf
      Next nFormatIndex
    Next nSizeIndex
    
    SortStructuredArray(aFormatSort(), #PB_Sort_Ascending, OffsetOf(tyFormatSort\sSortKey), #PB_String, 1, nFormatsCount)
    
    sFormatsSorted = ""
    For nFormatIndex = 1 To nFormatsCount
      If nFormatIndex > 1
        sFormatsSorted + Chr(10)
      EndIf
      sFormatsSorted + aFormatSort(nFormatIndex)\sFormat
    Next nFormatIndex
    
    \sFormatsSorted = sFormatsSorted
    
  EndWith
  
EndProcedure

; EOF