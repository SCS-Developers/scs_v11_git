; File: DMX.pbi

EnableExplicit

Procedure DMX_debugPrevChannels(pCaller)
  PROCNAMEC()
  Protected nDMXChannel, bFound
  For nDMXChannel = 1 To 512
    If grDMX\rPrevDMX\ascData[nDMXChannel] > 0
      debugMsg0(sProcName,  "(" + pCaller + ") grDMX\rPrevDMX\ascData[" + nDMXChannel + "]=" + grDMX\rPrevDMX\ascData[nDMXChannel])
      bFound = #True
    EndIf
  Next nDMXChannel
  If bFound = #False
    debugMsg0(sProcName,  "(" + pCaller + ") no non-zero channels found")
  EndIf
EndProcedure

Procedure DMX_initDMXControl()
  PROCNAMEC()
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  With grDMXControlDef
    \nDMXInPref = #SCS_DMX_NOTATION_0_255
    For n = 0 To #SCS_MAX_DMX_COMMAND
      \aDMXCommand[n]\nChannel = -1
    Next n
  EndWith
  
  For n = 0 To ArraySize(gaDMXControl())
    gaDMXControl(n) = grDMXControlDef
  Next n
  With grDMX
    \nMaxDMXControl = -1
    \nDMXCueControlPtr = -1
    \nDMXCaptureControlPtr = -1
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getBlankDMXControlEntry()
  PROCNAMEC()
  Protected nDMXControlPtr
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  nDMXControlPtr = -1
  For n = 0 To grDMX\nMaxDMXControl
    ; debugMsg(sProcName, "gaDMXControl(" + n + ")\bExists=" + strB(gaDMXControl(n)\bExists))
    If gaDMXControl(n)\bExists = #False
      nDMXControlPtr = n
      Break
    EndIf
  Next n
  
  If nDMXControlPtr < 0
    nDMXControlPtr = grDMX\nMaxDMXControl + 1
    If nDMXControlPtr > ArraySize(gaDMXControl())
      REDIM_ARRAY(gaDMXControl, nDMXControlPtr, grDMXControlDef, "gaDMXControl()")
    EndIf
    grDMX\nMaxDMXControl = nDMXControlPtr
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + nDMXControlPtr)
  ProcedureReturn nDMXControlPtr
  
EndProcedure

Procedure DMX_loadDMXControl(bUseDevChgs=#False)
  PROCNAMEC()
  Protected d, n
  Protected nDevMapId, nDevMapPtr, nDevMapDevPtr
  Protected nDevGrp, nDevType
  Protected sLogicalDev.s
  Protected nDMXControlPtr, nDMXSendDataBaseIndex
  
  debugMsg(sProcName, #SCS_START + ", bUseDevChgs=" + strB(bUseDevChgs))
  
  grDMX\nDMXCueControlPtr = -1
  ; debugMsg(sProcName, "grDMX\nDMXCueControlPtr=" + grDMX\nDMXCueControlPtr)
  
  If bUseDevChgs = #False
    nDevMapPtr = grProd\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevMapId = grMaps\aMap(nDevMapPtr)\nDevMapId
    EndIf
    
    For d = 0 To grProd\nMaxCueCtrlLogicalDev
      nDevType = grProd\aCueCtrlLogicalDevs(d)\nDevType
      If nDevType = #SCS_DEVTYPE_CC_DMX_IN
        sLogicalDev = buildCueCtrlLogicalDev(d)
        debugMsg(sProcName, "sLogicalDev=" + sLogicalDev)
        debugMsg(sProcName, "grProd\nSelectedDevMapPtr=" + grProd\nSelectedDevMapPtr)
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
        debugMsg(sProcName, "nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr >= 0
          nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(nDevType, sLogicalDev)
          If nDMXControlPtr < 0
            debugMsg(sProcName, "calling DMX_getBlankDMXControlEntry()")
            nDMXControlPtr = DMX_getBlankDMXControlEntry()
          EndIf
          ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr)
          If nDMXControlPtr >= 0
            With gaDMXControl(nDMXControlPtr)
              \bExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevMapDevPtr = nDevMapDevPtr
              \nDevChgsDevMapDevPtr = grDMXControlDef\nDevChgsDevMapDevPtr
              \nDevMapId = nDevMapId
              \sDMXName = grMaps\aDev(nDevMapDevPtr)\sPhysicalDev
              \nDMXSerial = grMaps\aDev(nDevMapDevPtr)\nDMXSerial
              \sDMXSerial = grMaps\aDev(nDevMapDevPtr)\sDMXSerial
              \nDMXDevPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
              \bDMXDummyPort = grMaps\aDev(nDevMapDevPtr)\bDummy
              \nDMXPort = grMaps\aDev(nDevMapDevPtr)\nDMXPort
              \sDMXIpAddress = grMaps\aDev(nDevMapDevPtr)\sDMXIpAddress
              If \nDMXDevPtr >= 0
                \nDMXDevType = gaDMXDevice(\nDMXDevPtr)\nDMXDevType
              EndIf
              \nDMXInPref = grProd\aCueCtrlLogicalDevs(d)\nDMXInPref
              \nDMXTrgCtrl = grProd\aCueCtrlLogicalDevs(d)\nDMXTrgCtrl
              \nDMXTrgValue = grProd\aCueCtrlLogicalDevs(d)\nDMXTrgValue
              For n = 0 To #SCS_MAX_DMX_COMMAND
                \aDMXCommand[n]\nChannel = grProd\aCueCtrlLogicalDevs(d)\aDMXCommand[n]\nChannel
                If \aDMXCommand[n]\nChannel >= 0
                  debugMsg(sProcName, "grDMXControl\aDMXCommand[" + n + "]\nChannel=" + \aDMXCommand[n]\nChannel)
                EndIf
              Next n
              If grDMX\nDMXCueControlPtr = -1
                grDMX\nDMXCueControlPtr = nDMXControlPtr
                debugMsg(sProcName, "grDMX\nDMXCueControlPtr=" + grDMX\nDMXCueControlPtr)
              EndIf
            EndWith
          EndIf
        EndIf
      EndIf
    Next d

    For d = 0 To grProd\nMaxLightingLogicalDev
      nDevGrp = #SCS_DEVGRP_LIGHTING
      nDevType = grProd\aLightingLogicalDevs(d)\nDevType
      If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDev = grProd\aLightingLogicalDevs(d)\sLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, nDevGrp, sLogicalDev)
        debugMsg(sProcName, "d=" + d + ", nDevType=" + decodeDevType(nDevType) + ", sLogicalDev=" + #DQUOTE$ + sLogicalDev + #DQUOTE$ + ", nDevMapDevPtr=" + nDevMapDevPtr)
        nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(nDevType, sLogicalDev)
        debugMsg(sProcName, "DMX_getDMXControlPtrForLogicalDev(" + decodeDevType(nDevType) + ", " + #DQUOTE$ + sLogicalDev + #DQUOTE$ + ") returned nDMXControlPtr=" + nDMXControlPtr)
        If nDMXControlPtr < 0
          debugMsg(sProcName, "calling DMX_getBlankDMXControlEntry()")
          nDMXControlPtr = DMX_getBlankDMXControlEntry()
        EndIf
        ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr)
        If nDMXControlPtr >= 0
          With gaDMXControl(nDMXControlPtr)
            \bExists = #True
            \nDevType = nDevType
            \nDevNo = d
            \sLogicalDev = sLogicalDev
            \nDevMapDevPtr = nDevMapDevPtr
            \nDevChgsDevMapDevPtr = grDMXControlDef\nDevChgsDevMapDevPtr
            \nDevMapId = nDevMapId
            If nDevMapDevPtr >= 0
              \sDMXName = grMaps\aDev(nDevMapDevPtr)\sPhysicalDev
              \nDMXSerial = grMaps\aDev(nDevMapDevPtr)\nDMXSerial
              \sDMXSerial = grMaps\aDev(nDevMapDevPtr)\sDMXSerial
              \nDMXDevPtr = grMaps\aDev(nDevMapDevPtr)\nPhysicalDevPtr
              \bDMXDummyPort = grMaps\aDev(nDevMapDevPtr)\bDummy
              \nDMXPort = grMaps\aDev(nDevMapDevPtr)\nDMXPort
              \sDMXIpAddress = grMaps\aDev(nDevMapDevPtr)\sDMXIpAddress
              If \nDMXDevPtr >= 0
                \nDMXDevType = gaDMXDevice(\nDMXDevPtr)\nDMXDevType
                \nDMXSendDataBaseIndex = nDMXSendDataBaseIndex
                nDMXSendDataBaseIndex + 512
              EndIf
              \nDMXRefreshRate = grMaps\aDev(nDevMapDevPtr)\nDMXRefreshRate
            EndIf
            ; Added 8Aug2020 11.8.3.2ap
            If grDMX\nDMXCaptureControlPtr= -1
              grDMX\nDMXCaptureControlPtr = nDMXControlPtr
              debugMsg(sProcName, "grDMX\nDMXCaptureControlPtr=" + grDMX\nDMXCaptureControlPtr)
            EndIf
            ; End added 8Aug2020 11.8.3.2ap
            \bDMXCueControl = #False
            If \bExists
              debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\sDMXName=" + \sDMXName + ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial +
                                  ", \nDMXDevPtr=" + \nDMXDevPtr + ", \nDMXPort=" + \nDMXPort + ", \bDMXDummyPort=" + strB(\bDMXDummyPort) + ", \nDMXSendDataBaseIndex=" + \nDMXSendDataBaseIndex)
            EndIf
          EndWith
          DMX_setDMXProcessRefresh(nDMXControlPtr)
        EndIf
      EndIf
    Next d
    
  Else
    ; bUseDevChgs is #True
    
    nDevMapPtr = grProdForDevChgs\nSelectedDevMapPtr
    If nDevMapPtr >= 0
      nDevMapId = grMapsForDevChgs\aMap(nDevMapPtr)\nDevMapId
    EndIf
    
    For d = 0 To grProdForDevChgs\nMaxCueCtrlLogicalDev
      nDevType = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDevType
      If nDevType = #SCS_DEVTYPE_CC_DMX_IN
        sLogicalDev = buildCueCtrlLogicalDev(d)
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, #SCS_DEVGRP_CUE_CTRL, sLogicalDev)
        debugMsg(sProcName, "sLogicalDev=" + sLogicalDev + ", nDevMapDevPtr=" + nDevMapDevPtr)
        If nDevMapDevPtr >= 0
          nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(nDevType, sLogicalDev)
          If nDMXControlPtr < 0
            debugMsg(sProcName, "calling DMX_getBlankDMXControlEntry()")
            nDMXControlPtr = DMX_getBlankDMXControlEntry()
          EndIf
          ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr)
          If nDMXControlPtr >= 0
            With gaDMXControl(nDMXControlPtr)
              \bExists = #True
              \nDevType = nDevType
              \nDevNo = d
              \sLogicalDev = sLogicalDev
              \nDevChgsDevMapDevPtr = nDevMapDevPtr
              \nDevMapDevPtr = grDMXControlDef\nDevMapDevPtr
              \nDevMapId = nDevMapId
              \sDMXName = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
              \nDMXSerial = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXSerial
              \sDMXSerial = grMapsForDevChgs\aDev(nDevMapDevPtr)\sDMXSerial
              \nDMXDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
              \bDMXDummyPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
              \nDMXPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXPort
              \sDMXIpAddress = grMapsForDevChgs\aDev(nDevMapDevPtr)\sDMXIpAddress
              If \nDMXDevPtr >= 0
                \nDMXDevType = gaDMXDevice(\nDMXDevPtr)\nDMXDevType
              EndIf
              \nDMXInPref = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDMXInPref
              \nDMXTrgCtrl = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDMXTrgCtrl
              \nDMXTrgValue = grProdForDevChgs\aCueCtrlLogicalDevs(d)\nDMXTrgValue
              For n = 0 To #SCS_MAX_DMX_COMMAND
                \aDMXCommand[n]\nChannel = grProdForDevChgs\aCueCtrlLogicalDevs(d)\aDMXCommand[n]\nChannel
                debugMsg(sProcName, "grDMXControl\aDMXCommand[" + n + "]\nChannel=" + \aDMXCommand[n]\nChannel)
              Next n
              If grDMX\nDMXCueControlPtr = -1
                grDMX\nDMXCueControlPtr = nDMXControlPtr
                debugMsg(sProcName, "grDMX\nDMXCueControlPtr=" + grDMX\nDMXCueControlPtr)
              EndIf
            EndWith
          EndIf
        EndIf
      EndIf
    Next d
    
    For d = 0 To grProdForDevChgs\nMaxLightingLogicalDev
      nDevGrp = #SCS_DEVGRP_LIGHTING
      nDevType = grProdForDevChgs\aLightingLogicalDevs(d)\nDevType
      If nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        sLogicalDev = grProdForDevChgs\aLightingLogicalDevs(d)\sLogicalDev
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMapsForDevChgs, nDevGrp, sLogicalDev)
        nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(nDevType, sLogicalDev)
        If nDMXControlPtr < 0
          debugMsg(sProcName, "calling DMX_getBlankDMXControlEntry()")
          nDMXControlPtr = DMX_getBlankDMXControlEntry()
        EndIf
        ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr)
        If nDMXControlPtr >= 0
          With gaDMXControl(nDMXControlPtr)
            \bExists = #True
            \nDevType = nDevType
            \nDevNo = d
            \sLogicalDev = sLogicalDev
            \nDevChgsDevMapDevPtr = nDevMapDevPtr
            \nDevMapDevPtr = grDMXControlDef\nDevMapDevPtr
            \nDevMapId = nDevMapId
            If nDevMapDevPtr >= 0
              \sDMXName = grMapsForDevChgs\aDev(nDevMapDevPtr)\sPhysicalDev
              \nDMXSerial = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXSerial
              \sDMXSerial = grMapsForDevChgs\aDev(nDevMapDevPtr)\sDMXSerial
              \nDMXDevPtr = grMapsForDevChgs\aDev(nDevMapDevPtr)\nPhysicalDevPtr
              \bDMXDummyPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\bDummy
              \nDMXPort = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXPort
              \sDMXIpAddress = grMapsForDevChgs\aDev(nDevMapDevPtr)\sDMXIpAddress
              If \nDMXDevPtr >= 0
                \nDMXDevType = gaDMXDevice(\nDMXDevPtr)\nDMXDevType
              EndIf
              \nDMXRefreshRate = grMapsForDevChgs\aDev(nDevMapDevPtr)\nDMXRefreshRate
            EndIf
            ; Added 8Aug2020 11.8.3.2ap
            If grDMX\nDMXCaptureControlPtr= -1
              grDMX\nDMXCaptureControlPtr = nDMXControlPtr
              debugMsg(sProcName, "grDMX\nDMXCaptureControlPtr=" + grDMX\nDMXCaptureControlPtr)
            EndIf
            ; End added 8Aug2020 11.8.3.2ap
            \bDMXCueControl = #False
            If \bExists
              debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\sDMXName=" + \sDMXName + ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial +
                                  ", \nDMXDevPtr=" + \nDMXDevPtr + ", \nDMXPort=" + \nDMXPort + ", \bDMXDummyPort=" + strB(\bDMXDummyPort))
            EndIf
          EndWith
          DMX_setDMXProcessRefresh(nDMXControlPtr)
        EndIf
      EndIf
    Next d
    
  EndIf
  
  debugMsg(sProcName, "calling DMX_redimDMXArraysIfRequired()")
  DMX_redimDMXArraysIfRequired()
  
  debugMsg(sProcName, "calling DMX_setDMXControlPtrsForAllSubs()")
  DMX_setDMXControlPtrsForAllSubs()
  
  If bUseDevChgs
    debugMsg(sProcName, "calling DMX_loadDMXChannelMonitoredArray(@grProdForDevChgs)")
    DMX_loadDMXChannelMonitoredArray(@grProdForDevChgs)
  Else
    debugMsg(sProcName, "calling DMX_loadDMXChannelMonitoredArray(@grProd)")
    DMX_loadDMXChannelMonitoredArray(@grProd)
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s DMX_getDMXInfo()
  PROCNAMEC()
  Protected sInfo.s
  Protected nDMXControlPtr
  
  If gbDMXAvailable
    For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
      If gaDMXControl(nDMXControlPtr)\bDMXCueControl
        sInfo = "DMX Control Enabled"
        Break
      EndIf
    Next nDMXControlPtr
  EndIf
  ProcedureReturn sInfo
EndProcedure

Procedure DMX_openDMXDev(nDMXControlPtr, nSendOnChangeFlag=-1)
  PROCNAMEC()
  Protected bResult
  Protected sErrorMsg.s
  Protected sDMXPort.s
  Protected nFTDeviceNo.l, nFTHandle.i, sFTHandle.s, bFTDIResult
  Protected n
  Protected sNameForMidi.s
  Protected nMySendOnChangeFlag.a, nLabel.a, wLength.w
  ; Protected Dim aDMXSendData.a(512) ; index 0 = start code, 1-512 = values for channels 1-512 (always zero for this procedure)
  Protected nDMXChannel
  
  debugMsg(sProcName, #SCS_START + ", nDMXControlPtr=" + nDMXControlPtr + ", nSendOnChangeFlag=" + nSendOnChangeFlag)
  
  With gaDMXControl(nDMXControlPtr)
    debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\nDevType=" + decodeDevType(\nDevType))
    Select \nDevType
      Case #SCS_DEVTYPE_CC_DMX_IN, #SCS_DEVTYPE_LT_DMX_OUT
        debugMsg(sProcName, "grDMXControl\sDMXName=" + \sDMXName + ", \nDMXSerial=" + \nDMXSerial + ", \sDMXSerial=" + \sDMXSerial)
        \nDMXDevPtr = -1
        If \nDMXSerial
          For n = 0 To (grDMX\nNumDMXDevs - 1)
            If (gaDMXDevice(n)\sName = \sDMXName) And (gaDMXDevice(n)\nSerial = \nDMXSerial)
              \nDMXDevPtr = n
              \bDMXDummyPort = gaDMXDevice(n)\bDummy
              Break
            EndIf
          Next n
        EndIf
        If \nDMXDevPtr < 0
          ; nb do not check for \sDMXInSerial being present as it will be blank for 'Dummy DMX Port'
          For n = 0 To (grDMX\nNumDMXDevs - 1)
            If (gaDMXDevice(n)\sName = \sDMXName) And (gaDMXDevice(n)\sSerial = \sDMXSerial)
              \nDMXDevPtr = n
              \bDMXDummyPort = gaDMXDevice(n)\bDummy
              Break
            EndIf
          Next n
        EndIf
        debugMsg(sProcName, "grDMXControl\nDMXDevPtr=" + \nDMXDevPtr + ", \bDMXDummyPort=" + strB(\bDMXDummyPort))
        If \nDMXDevPtr >= 0
          If \bDMXDummyPort
            gaDMXDevice(\nDMXDevPtr)\bInitialized = #True
            gaDMXDevice(\nDMXDevPtr)\nFTHandle = 0
            \bDMXFirstReceive = #False
          ElseIf \nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO Or \nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2 Or
                 \nDMXDevType = #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB Or \nDMXDevType = #SCS_DMX_DEV_FTDI_USB_RS485
            nFTDeviceNo = gaDMXDevice(\nDMXDevPtr)\nFTDeviceNo
            \nFTHandle = DMX_FTDI_OpenDevice(nFTDeviceNo)
            
            If \nFTHandle And gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #True
              gaDMXDevice(\nDMXDevPtr)\nFTHandle = \nFTHandle
              \bDMXFirstReceive = #True
            EndIf
            
          ElseIf \nDMXDevType = #SCS_DMX_DEV_ARTNET And grLicInfo\nLicLevel >= #SCS_LIC_PLUS
            If \sDMXIpAddress = "" Or \sDMXIpAddress = "0.0.0.0"
              \sDMXIpAddress = "127.0.0.1"
            EndIf
            
            gsArtnetIpToBindTo = \sDMXIpAddress
            gsArtnetBroadcastIp = StringField(gsArtnetIpToBindTo, 1, ".") + "." + StringField(gsArtnetIpToBindTo, 2, ".") + "." +
                                  StringField(gsArtnetIpToBindTo, 3, ".") + ".255"
            gaDMXDevice(\nDMXDevPtr)\sDMXIpAddress = gsArtnetIpToBindTo
            Artnet_close()                              ; gracefully close, routine checks for activity, needs shutdown to reset
            gnArtnetHandle = Artnet_init()
            
            If gnArtnetHandle > 0
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #True
            Else
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
              sDMXPort = LangPars("DMX", "DMXPortArtnet", Str(\nDMXDevPtr))
              sErrorMsg = LangPars("Errors", "CannotOpen", sDMXPort)
              WMN_setStatusField(sErrorMsg, #SCS_STATUS_ERROR)
            EndIf
          ElseIf \nDMXDevType = #SCS_DMX_DEV_SACN And grLicInfo\nLicLevel >= #SCS_LIC_PLUS
            If \sDMXIpAddress = "" Or \sDMXIpAddress = "0.0.0.0"
              \sDMXIpAddress = "127.0.0.1"
            EndIf
            
            gs_sACNIpToBindTo = \sDMXIpAddress
            gaDMXDevice(\nDMXDevPtr)\sDMXIpAddress = gs_sACNIpToBindTo
            sACNFinish(\nDMXPort)                                 ; sACNFinish will check for an active connection before closing it 
            
            If sACNInitialise(gs_sACNIpToBindTo, \nDMXPort) = 0
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #True
            Else
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
              sDMXPort = LangPars("DMX", "DMXPortsACN", Str(\nDMXDevPtr))
              sErrorMsg = LangPars("Errors", "CannotOpen", sDMXPort)
              WMN_setStatusField(sErrorMsg, #SCS_STATUS_ERROR)
            EndIf
          EndIf
            debugMsg(sProcName, "gaDMXDevice(" + \nDMXDevPtr + ")\bInitialized=" + strB(gaDMXDevice(\nDMXDevPtr)\bInitialized) +
                     ", \nFTHandle=" + decodeHandle(gaDMXDevice(\nDMXDevPtr)\nFTHandle) + " (" + decodeDMXDevType(\nDMXDevType) + ")")
        EndIf
        
        ; propogate \nFTHandle to gaMidiIn() and gaMidiOut() where applicable
        sNameForMidi = \sDMXName
        If \nDMXSerial
          sNameForMidi + " (" + \nDMXSerial + ")"
        EndIf
        For n = 0 To (gnNumMidiInDevs-1)
          If gaMidiInDevice(n)\bEnttecMidi
            If (gaMidiInDevice(n)\sName = sNameForMidi) And (gaMidiInDevice(n)\sDMXSerial = \sDMXSerial)
              gaMidiInDevice(n)\nFTHandle = \nFTHandle
              gaMidiInDevice(n)\bInitialized = #True
              debugMsg(sProcName, "gaMidiInDevice(" + n + ")\nFTHandle=" + decodeHandle(gaMidiInDevice(n)\nFTHandle))
            EndIf
          EndIf
        Next n
        For n = 0 To (gnNumMidiOutDevs-1)
          If gaMidiOutDevice(n)\bEnttecMidi
            If (gaMidiOutDevice(n)\sName = sNameForMidi) And (gaMidiOutDevice(n)\sDMXSerial = \sDMXSerial)
              gaMidiOutDevice(n)\nFTHandle = \nFTHandle
              gaMidiOutDevice(n)\bInitialized = #True
              debugMsg(sProcName, "gaMidiOutDevice(" + n + ")\nFTHandle=" + decodeHandle(gaMidiOutDevice(n)\nFTHandle))
            EndIf
          EndIf
        Next n
        
    EndSelect
    
    Select \nDevType
      Case #SCS_DEVTYPE_CC_DMX_IN
        grDMX\bDMXInLocked = #False
        grDMX\nDMXInCount = 0
        grDMX\bTooManyDMXMessages = #False
        grDMX\bDMXFirstTime = #True
        If \nFTHandle
          sFTHandle = decodeHandle(\nFTHandle)
          CompilerIf 1=1
            ; Blocked out 15Feb2024 11.10.2ao following emails from Stefano about DMX Cue Control not processing the first action
            debugMsg(sProcName, "calling DMX_getDMXCurrValues(" + sFTHandle + ", " + \nDMXPort + ")") ; load initial values
            bResult = DMX_getDMXCurrValues(\nFTHandle, \nDMXPort)
            debugMsg(sProcName, "DMX_getDMXCurrValues(" + sFTHandle + ", " + \nDMXPort + ") returned " + strB(bResult))
            If bResult
              ; DMX_getDMXCurrValues() was successful, so cancel 'first receive' flag
              \bDMXFirstReceive = #False
              CompilerIf 1=2
                ; Added 21Jul2023 11.10.0bq
                For nDMXChannel = 1 To 512
                  grDMX\rPrevDMX\ascData[nDMXChannel] = DMX_IN\ascData[nDMXChannel]
                Next nDMXChannel
                ; DMX_debugPrevChannels(1)
                ; End added 21Jul2023 11.10.0bq
              CompilerEndIf
            EndIf
          CompilerEndIf
          If nSendOnChangeFlag >= 0
            nMySendOnChangeFlag = nSendOnChangeFlag
          Else
            nMySendOnChangeFlag = 1
          EndIf
          debugMsg(sProcName, "calling DMX_setReceiveDMXOnChangeFlag(" + sFTHandle + ", " + nMySendOnChangeFlag + ")")
          DMX_setReceiveDMXOnChangeFlag(\nFTHandle, nMySendOnChangeFlag)
          grDMX\bReceiveDMX = #True
          debugMsg(sProcName, "grDMX\nDMXInCount=" + grDMX\nDMXInCount)
        EndIf
        
      Case #SCS_DEVTYPE_LT_DMX_OUT
        If \nDMXDevPtr >= 0
          grDMX\bBlackOutWhenOpenDone = #True
        EndIf
        
    EndSelect
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_openDMXDevForMidiOut(nMidiOutDevPtr)
  PROCNAMEC()
  Protected nDMXDevPtr
  Protected bResult
  Protected sErrorMsg.s
  Protected sDMXPort.s
  Protected nFTDeviceNo.l, nFTHandle.i
  Protected sName.s, sSerialSuffix.s
  
  debugMsg(sProcName, #SCS_START + ", nMidiOutDevPtr=" + nMidiOutDevPtr)
  
  If nMidiOutDevPtr >= 0
    With gaMidiOutDevice(nMidiOutDevPtr)
      sName = \sDMXName
      nDMXDevPtr = DMX_getDMXDevPtr(sName, \sDMXSerial, \nDMXSerial, \bDummy)
      If nDMXDevPtr = -1
        If \nDMXSerial
          sSerialSuffix = "(" + \nDMXSerial + ")"
          sName = Trim(RemoveString(\sDMXName, sSerialSuffix))
          nDMXDevPtr = DMX_getDMXDevPtr(sName, \sDMXSerial, \nDMXSerial, \bDummy)
        EndIf
      EndIf
      \nDMXDevPtr = nDMXDevPtr
      debugMsg(sProcName, "grDMXControl\nDMXDevPtr=" + \nDMXDevPtr)
      If nDMXDevPtr >= 0
        If gaDMXDevice(nDMXDevPtr)\bInitialized = #False
          If \nFTHandle = 0
            nFTDeviceNo = gaDMXDevice(nDMXDevPtr)\nFTDeviceNo
            \nFTHandle = DMX_FTDI_OpenDevice(nFTDeviceNo)
            If \nFTHandle
              gaDMXDevice(nDMXDevPtr)\bInitialized = #True
              gaDMXDevice(nDMXDevPtr)\nFTHandle = \nFTHandle
              ; \bDMXFirstReceive = #True
            Else
              gaDMXDevice(nDMXDevPtr)\bInitialized = #False
              sDMXPort = LangPars("DMX", "DMXPort", Str(nDMXDevPtr))
              sErrorMsg = LangPars("Errors", "CannotOpen", sDMXPort)
              WMN_setStatusField(sErrorMsg, #SCS_STATUS_ERROR)
            EndIf
            debugMsg(sProcName, "gaDMXDevice(" + nDMXDevPtr + ")\bInitialized=" + strB(gaDMXDevice(nDMXDevPtr)\bInitialized) + ", \nFTHandle=" + gaDMXDevice(nDMXDevPtr)\nFTHandle)
          EndIf
        EndIf
        If gaDMXDevice(nDMXDevPtr)\bInitialized
          If \nFTHandle
            debugMsg(sProcName, "calling DMX_FTDI_EnableMidi(" + \nFTHandle + ")")
            DMX_FTDI_EnableMidi(\nFTHandle)
          EndIf
          \bInitialized = #True
          debugMsg(sProcName, "gaMidiOutDevice(" + nMidiOutDevPtr + ")\bInitialized=" + strB(\bInitialized))
        EndIf
      EndIf
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_openDMXDevs()
  PROCNAMEC()
  Protected nDMXControlPtr
  Protected nPhysicalDevPtr
  Protected nDevPtr
  
  debugMsg(sProcName, #SCS_START)
  
  debugMsg(sProcName, "grDMX\nMaxDMXControl=" + grDMX\nMaxDMXControl)
  For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
    nPhysicalDevPtr = -1
    With gaDMXControl(nDMXControlPtr)
      debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\bExists=" + strB(\bExists) + ", \nDevMapDevPtr=" + \nDevMapDevPtr + ", \nDevChgsDevMapDevPtr=" + \nDevChgsDevMapDevPtr)
      If \bExists
        If \nDevMapDevPtr >= 0
          nPhysicalDevPtr = grMaps\aDev(\nDevMapDevPtr)\nPhysicalDevPtr
        ElseIf \nDevChgsDevMapDevPtr >= 0
          nPhysicalDevPtr = grMapsForDevChgs\aDev(\nDevChgsDevMapDevPtr)\nPhysicalDevPtr
        EndIf
        If nPhysicalDevPtr >= 0
          debugMsg(sProcName, "gaDMXDevice(" + nPhysicalDevPtr + ")\bInitialized=" + strB(gaDMXDevice(nPhysicalDevPtr)\bInitialized))
          If gaDMXDevice(nPhysicalDevPtr)\bInitialized = #False
            debugMsg(sProcName, "calling DMX_openDMXDev(" + nDMXControlPtr + ")")
            DMX_openDMXDev(nDMXControlPtr)
          Else ; gaDMXDevice(nPhysicalDevPtr)\bInitialized = #True
            \bDMXDummyPort = gaDMXDevice(nPhysicalDevPtr)\bDummy
            \nFTHandle = gaDMXDevice(nPhysicalDevPtr)\nFTHandle
          EndIf
        EndIf
      EndIf
    EndWith
  Next nDMXControlPtr
  
  CompilerIf #c_no_blackout_on_start_or_closedown = #False
    If grDMX\bBlackOutWhenOpenDone
      DMX_blackOutAll()
      Delay(100)  ; give thread time to execute this command
      grDMX\bBlackOutWhenOpenDone = #False
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, "calling setDMXEnabled()")
  setDMXEnabled()
  
  CompilerIf #c_dmx_receive_in_main_thread = #False
    If grDMX\bReceiveDMX
      If THR_getThreadState(#SCS_THREAD_DMX_RECEIVE) <> #SCS_THREAD_STATE_ACTIVE
        samAddRequest(#SCS_SAM_START_THREAD, #SCS_THREAD_DMX_RECEIVE)
      EndIf
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_closeDMXDev(nDMXControlPtr)
  PROCNAMEC()
  Protected ftStatus.l
  
  debugMsg(sProcName, #SCS_START + ", nDMXControlPtr=" + nDMXControlPtr)
  
  With gaDMXControl(nDMXControlPtr)
    If \bExists
      If \nDevType = #SCS_DEVTYPE_CC_DMX_IN
        ; stop listening
        grDMX\bReceiveDMX = #False
      EndIf
      If \bDMXDummyPort = #False ; Test added 26Feb2024 11.10.2ax following email from Nithat Namfa (KAI) that threw an error due to \nFTHandle not being set. \sDMXName was "Dummy DMX Port".
        If \nDMXDevPtr >= 0
          Select \sDMXName
            Case "Artnet", "Art-Net"
              Artnet_close()
              gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
              gnArtnetHandle = 0
              
            Case "sACN"
              FindMapElement(gm_sACnActive(), Str(\nDMXPort))
              
              If gm_sACnActive() <> 0
                sACNFinish(\nDMXPort)
                gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
              EndIf
              
            Default
              If gaDMXDevice(\nDMXDevPtr)\bInitialized
                ftStatus = FT_Close(\nFTHandle)
                debugMsg2(sProcName, "FT_Close(" + decodeHandle(\nFTHandle) + ")", ftStatus)
                gaDMXDevice(\nDMXDevPtr)\bInitialized = #False
                debugMsg(sProcName, "gaDMXDevice(" + \nDMXDevPtr + ")\bInitialized=" + strB(gaDMXDevice(\nDMXDevPtr)\bInitialized))
                \nFTHandle = 0
                debugMsg(sProcName, "\nFTHandle=" + \nFTHandle + ", \nDMXDevPtr=" + \nDMXDevPtr)
              EndIf
          EndSelect
        EndIf
      EndIf
      \nDMXDevPtr = -1
 
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_closeDMXDevs()
  PROCNAMEC()
  Protected nDMXControlPtr, nDefArraySize
  
  debugMsg(sProcName, #SCS_START)
  
  For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
    With gaDMXControl(nDMXControlPtr)
      If \bExists And \sLogicalDev = "DMX"
        DMX_closeDMXDev(nDMXControlPtr)
      EndIf
    EndWith
  Next nDMXControlPtr
  
  ; Added 29Jul2020 11.8.3.2ap following tests where on opening a new cue file the data from the first cue file was still present, resulting in DMX values not being sent.
  ; The most significant fix in the following is "grFixturesRunTime\bLoaded = #False", but the other lines of code help clean things up.
  If gbClosingDown = #False ; this test added 31May2021 11.8.5ad
    DMX_clearFadeItems()
    ; Added 31May2021 11.8.5ad
    nDefArraySize = ArraySize(grDMXChannelItemsDef\aDMXChannelItem())
    debugMsg(sProcName, "nDefArraySize=" + nDefArraySize + ", ArraySize(grDMXChannelItems\aDMXChannelItem())=" + ArraySize(grDMXChannelItems\aDMXChannelItem()))
    If ArraySize(grDMXChannelItems\aDMXChannelItem()) <> nDefArraySize
      ReDim grDMXChannelItems\aDMXChannelItem(nDefArraySize)
    EndIf
    ; End added 31May2021 11.8.5ad
    grDMXChannelItems = grDMXChannelItemsDef
    grFixturesRunTime\bLoaded = #False
  EndIf
  ; End added 29Jul2020 11.8.3.2ap
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_loadArrayDMXDevs()
  PROCNAMEC()
  Protected d, n
  
  ; debugMsg(sProcName, #SCS_START + ", gbFTD2XXAvailable=" + strB(gbFTD2XXAvailable) + ", grDMX\nNumDMXDevs=" + grDMX\nNumDMXDevs)
  debugMsg(sProcName, "DMX devices")
  If gbFTD2XXAvailable = #False
    debugMsg(sProcName, "gbFTD2XXAvailable=" + strB(gbFTD2XXAvailable) + ", grDMX\nNumDMXDevs=" + grDMX\nNumDMXDevs)
  EndIf
  
  ReDim gaDMXDevice(grDMX\nNumDMXDevs)
  d = -1
  For n = 0 To gnMaxConnectedDev
    If gaConnectedDev(n)\nDevType = #SCS_DEVTYPE_CC_DMX_IN ; may also be used for identifying #SCS_DEVTYPE_LT_DMX_OUT devices
      d + 1
      With gaDMXDevice(d)
        \sName = gaConnectedDev(n)\sPhysicalDevDesc
        \nSerial = gaConnectedDev(n)\nSerial
        \sSerial = gaConnectedDev(n)\sSerial
        \nFTDeviceNo = gaConnectedDev(n)\nDevice
        \bDummy = gaConnectedDev(n)\bDummy
        \nDMXDevType = gaConnectedDev(n)\nDMXDevType
        \nDMXPorts = gaConnectedDev(n)\nDMXPorts
      EndWith
    EndIf
  Next n
  
  For n = 0 To (grDMX\nNumDMXDevs-1)
    With gaDMXDevice(n)
      debugMsg(sProcName, "gaDMXDevice(" + n + ")\sName=" + \sName + ", \sSerial=" + \sSerial + ", \nSerial=" + \nSerial + ", \nDMXPorts=" + \nDMXPorts +
                          ", \nFTDeviceNo=" + \nFTDeviceNo + ", \nFTHandle=" + \nFTHandle + ", \bDummy=" + strB(\bDummy) + ", \nDMXDevType=" + decodeDMXDevType(\nDMXDevType))
    EndWith
  Next n
  
EndProcedure

Procedure DMX_setDMXBoolean(nDMXCommand, nInputIndex)
  PROCNAMEC()
  Protected bBoolean
  Protected nChannel
  Protected ascThisByte.a, ascPrevByte.a
  
  If grDMX\nDMXCueControlPtr >= 0
    With gaDMXControl(grDMX\nDMXCueControlPtr)
      nChannel = \aDMXCommand[nDMXCommand]\nChannel
      If nChannel >= 0
        ascThisByte = gaDMXIns(nInputIndex)\rDMX_In\ascData[nChannel]
        ascPrevByte = grDMX\rPrevDMX\ascData[nChannel]
        
        Select \nDMXTrgCtrl
          Case #SCS_DMX_TRG_CHG_UP_TO_VALUE
            If (ascThisByte = \nDMXTrgValue) And (ascThisByte > ascPrevByte)
              bBoolean = #True
            EndIf
            
          Case #SCS_DMX_TRG_CHG_FROM_ZERO
            If (ascPrevByte = 0) And (ascThisByte > 0)
              bBoolean = #True
            EndIf
            
          Case #SCS_DMX_TRG_ANY_CHG
            If (ascThisByte <> ascPrevByte) And (ascThisByte > 0)
              bBoolean = #True
            EndIf
            
        EndSelect
      EndIf
    EndWith
  EndIf
  
  ; debugMsg(sProcName, "nDMXCommand=" + decodeDMXCommand(nDMXCommand) + ", nInputIndex=" + nInputIndex +
  ;                     ", ascThisByte=" + ascThisByte + ", ascPrevByte=" + ascPrevByte + ", returning " + strB(bBoolean))
  ProcedureReturn bBoolean
EndProcedure

Procedure DMX_setDMXBooleanFromChannel(nDMXChannel, nInputIndex)
  PROCNAMEC()
  Protected bBoolean
  Protected ascThisByte.a, ascPrevByte.a
  
  If grDMX\nDMXCueControlPtr >= 0
    With gaDMXControl(grDMX\nDMXCueControlPtr)
      If nDMXChannel >= 0
        ascThisByte = gaDMXIns(nInputIndex)\rDMX_In\ascData[nDMXChannel]
        ascPrevByte = grDMX\rPrevDMX\ascData[nDMXChannel]
        
        Select \nDMXTrgCtrl
          Case #SCS_DMX_TRG_CHG_UP_TO_VALUE
            If (ascThisByte = \nDMXTrgValue) And (ascThisByte > ascPrevByte)
              bBoolean = #True
            EndIf
            
          Case #SCS_DMX_TRG_CHG_FROM_ZERO
            If (ascPrevByte = 0) And (ascThisByte > 0)
              bBoolean = #True
            EndIf
            
          Case #SCS_DMX_TRG_ANY_CHG
            If (ascThisByte <> ascPrevByte) And (ascThisByte > 0)
              bBoolean = #True
            EndIf
            
        EndSelect
      EndIf
    EndWith
  EndIf
  
  ProcedureReturn bBoolean
EndProcedure

Procedure DMX_doDMXIn_Proc()
  PROCNAMEC()
  Protected m, n, n2
  Protected nCountNotDone
  Protected sWork.s
  Protected txt.s
  Protected nDMXChannel
  Protected ascThisByte.a, ascPrevByte.a
  Protected bGoButton
  Protected bStopAll
  Protected bPauseResumeAll
  Protected bGoTop
  Protected bGoBack
  Protected bGoNext
  Protected nDMXChannelPlayDMXCue0
  Protected nDMXChannelPlayDMXCueMax
  Protected nDMXChannelPlayDMXCueRange
  Static Dim bPlayDMXCue(0)
  Protected nMasterFader
  Protected nSliderValue, fLevel.f
  Protected nRow, nCol
  Protected nLeft, nTop
  Protected nCellValue
  Protected bTestUpdated
  Protected sMidiCue.s
  
  ; debugMsg(sProcName, #SCS_START + ", grDMX\nDMXInCount=" + grDMX\nDMXInCount + ", grSession\nDMXInEnabled=" + grSession\nDMXInEnabled)
  
  If (grSession\nDMXInEnabled <> #SCS_DEVTYPE_ENABLED) Or (gbInitialising) Or (gbLoadingCueFile) Or (grDMX\nDMXCueControlPtr < 0)
    ; currently ignoring DMX
    CompilerIf #cTraceDMX
      debugMsg(sProcName, "Ignoring DMX: grSession\nDMXInEnabled=" + grSession\nDMXInEnabled + ", gbInitialising=" + strB(gbInitialising) + ", gbLoadingCueFile=" + strB(gbLoadingCueFile) + ", grDMX\nDMXCueControlPtr=" + grDMX\nDMXCueControlPtr)
    CompilerEndIf
    ProcedureReturn
  EndIf
  
  If grDMX\bDMXInLocked
    debugMsg(sProcName, "grDMX\bDMXInLocked=" + strB(grDMX\bDMXInLocked))
    ProcedureReturn
  EndIf
  
  nDMXChannelPlayDMXCue0 = gaDMXControl(grDMX\nDMXCueControlPtr)\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_0]\nChannel
  nDMXChannelPlayDMXCueMax = gaDMXControl(grDMX\nDMXCueControlPtr)\aDMXCommand[#SCS_DMX_PLAY_DMX_CUE_MAX]\nChannel
  
  If nDMXChannelPlayDMXCue0 >= 0 And nDMXChannelPlayDMXCueMax >= 0
    nDMXChannelPlayDMXCueRange = nDMXChannelPlayDMXCueMax - nDMXChannelPlayDMXCue0
  Else
    nDMXChannelPlayDMXCueRange = -1
  EndIf
  If nDMXChannelPlayDMXCueRange > ArraySize(bPlayDMXCue())
    ReDim bPlayDMXCue(nDMXChannelPlayDMXCueRange)
  EndIf
  
  CompilerIf #cTraceDMXUpdatePackets Or #cTraceDMX
    debugMsg(sProcName, "nDMXChannelPlayDMXCue0=" + nDMXChannelPlayDMXCue0 + ", nDMXChannelPlayDMXCueMax=" + nDMXChannelPlayDMXCueMax + ", nDMXChannelPlayDMXCueRange=" + nDMXChannelPlayDMXCueRange)
  CompilerEndIf
  
  For n = 0 To grDMX\nDMXInCount - 1
    CompilerIf #cTraceDMX
      debugMsg(sProcName, "n=" + n + ", grDMX\nDMXInCount=" + grDMX\nDMXInCount)
    CompilerEndIf
    
    bGoButton = #False
    bStopAll = #False
    bPauseResumeAll = #False
    bGoTop = #False
    bGoBack = #False
    bGoNext = #False
    nMasterFader = -1
    
    With gaDMXIns(n)
      If \bDone = #False
        bGoButton = DMX_setDMXBoolean(#SCS_DMX_GO_BUTTON, n)
        bStopAll = DMX_setDMXBoolean(#SCS_DMX_STOP_ALL, n)
        bPauseResumeAll = DMX_setDMXBoolean(#SCS_DMX_PAUSE_RESUME_ALL, n)
        bGoTop = DMX_setDMXBoolean(#SCS_DMX_GO_TO_TOP, n)
        bGoBack = DMX_setDMXBoolean(#SCS_DMX_GO_BACK, n)
        bGoNext = DMX_setDMXBoolean(#SCS_DMX_GO_TO_NEXT, n)
        If nDMXChannelPlayDMXCueRange >= 0
          For n2 = 0 To nDMXChannelPlayDMXCueRange
            bPlayDMXCue(n2) = DMX_setDMXBooleanFromChannel(nDMXChannelPlayDMXCue0 + n2, n)
            CompilerIf #cTraceDMX
              If bPlayDMXCue(n2)
                debugMsg(sProcName, "bPlayDMXCue(" + n2 + ")=" + strB(bPlayDMXCue(n2)))
              EndIf
            CompilerEndIf
          Next n2
        EndIf
        
        nDMXChannel = gaDMXControl(grDMX\nDMXCueControlPtr)\aDMXCommand[#SCS_DMX_MASTER_FADER]\nChannel
        If nDMXChannel >= 0
          ascThisByte = \rDMX_In\ascData[nDMXChannel]
          ascPrevByte = grDMX\rPrevDMX\ascData[nDMXChannel]
          If ascThisByte <> ascPrevByte
            nMasterFader = ascThisByte
          EndIf
        EndIf
        
        txt = ""
        ; Commented out 16Nov2022 11.9.7ag
;         If nMasterFader >= 0
;           If gaDMXControl(grDMX\nDMXCueControlPtr)\nDMXInPref = 1
;             nCellValue = nMasterFader / 2.55
;             txt + ", Set Master Fader to " + nCellValue + "%"
;           Else
;             txt + ", Set Master Fader to " + nMasterFader
;           EndIf
;         EndIf
        
        If bGoButton
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_GO_BUTTON)
        EndIf
        
        If bStopAll
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_STOP_ALL)
        EndIf
        
        If bPauseResumeAll
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_PAUSE_RESUME_ALL)
        EndIf
        
        If bGoTop
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_GO_TO_TOP)
        EndIf
        
        If bGoBack
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_GO_BACK)
        EndIf
        
        If bGoNext
          txt + ", " + DMXCmdDescrForCmdNo(#SCS_DMX_GO_TO_NEXT)
        EndIf
        
        If nDMXChannelPlayDMXCueRange >= 0
          For n2 = 0 To nDMXChannelPlayDMXCueRange
            If bPlayDMXCue(n2)
              txt + ", Play DMX Cue " + n2
            EndIf
          Next n2
        EndIf
        
        If Len(txt) > 2
          txt = Mid(txt, 3)
        EndIf
        
        If grDMX\bDMXTestWindowActive = #False
          If gbInitialising Or gbLoadingCueFile
            ; discard if initialising or currently loading a cue file
            txt = ""
          Else
            gbInExternalControl = #True
            
            If nMasterFader >= 0
              nSliderValue = nMasterFader * (SLD_getMax(WMN\sldMasterFader) / 255)
              fLevel = SLD_SliderValueToBVLevel(nSliderValue)
              ; samAddRequest(#SCS_SAM_SET_MASTER_FADER, 0, fLevel, #True) ; deleted 16Nov2022 11.9.7ag
              ; Added 16Nov2022 11.9.76ag
              setMasterFader(fLevel)
              SLD_setLevel(WMN\sldMasterFader, fLevel)
              ; End added 16Nov2022 11.9.76ag
            EndIf
            
            If bGoButton
              PostEvent(#SCS_Event_GoButton, #WMN, 0)
            EndIf
            
            If bStopAll
              PostEvent(#SCS_Event_StopEverything, #WMN, 0)
            EndIf
            
            If bPauseResumeAll
              samAddRequest(#SCS_SAM_PAUSE_RESUME_ALL)
            EndIf
            
            If bGoTop
              PostEvent(#SCS_Event_GoTo_Top_Cue, #WMN, 0)
            EndIf
            
            If bGoBack
              PostEvent(#SCS_Event_GoTo_Prev_Cue, #WMN, 0)
            EndIf
            
            If bGoNext
              PostEvent(#SCS_Event_GoTo_Next_Cue, #WMN, 0)
            EndIf
            
            If nDMXChannelPlayDMXCueRange >= 0
              For n2 = 0 To nDMXChannelPlayDMXCueRange
                If bPlayDMXCue(n2)
                  sMidiCue = Trim(Str(n2))
                  processMidiOrDMXPlayCueCmd(-1, sMidiCue) ; nMidiInPort -1 = DMX
                EndIf
              Next n2
            EndIf
            
            gbInExternalControl = #False
          EndIf
        EndIf
        
        If txt
          ; debugMsg(sProcName, "txt=" + txt)
          If grDMX\bDMXTestWindowActive
            ; debugMsg0(sProcName, "AddGadgetItem(WDT\lstTestDMXInfo, -1, " + #DQUOTE$ + txt + #DQUOTE$ + ")")
            AddGadgetItem(WDT\lstTestDMXInfo, -1, txt)
            ; scroll to last entry, so entry just added is visible
            SetGadgetState(WDT\lstTestDMXInfo, CountGadgetItems(WDT\lstTestDMXInfo)-1)
            SetGadgetState(WDT\lstTestDMXInfo, -1)
            bTestUpdated = #True
            debugMsg(sProcName, RTrim("DMX Received:  " + txt))
          Else
            WMN_setStatusField(RTrim("DMX Received:  " + txt))
          EndIf
        EndIf
        
        If grDMX\bDMXTestWindowActive
          If StartDrawing(CanvasOutput(WDT\cvsDMXReceived))
            scsDrawingFont(#SCS_FONT_GEN_NORMAL)
            If grDMX\bDMXFirstTime
              For m = 1 To 512
                nRow = (m-1) >> 5   ; equivalent to "Round((m-1) / 32, #PB_Round_Down)"
                nCol = (m-1) - (nRow << 5)
                nCellValue = \rDMX_In\ascData[m]
                If grWDT\nDMXInPref = #SCS_DMX_NOTATION_PERCENT
                  nCellValue / 2.55
                EndIf
                nLeft = (nCol * grWDT\nColWidth) + grWDT\nTitleWidth + 4
                nTop = (nRow * grWDT\nRowHeight) + gl3DBorderHeight + grWDT\nTopMargin
                Box(nLeft, nTop, grWDT\nColWidth - 5, grWDT\nRowHeight - 5, grWDT\nCanvasBackColor)
                If nCellValue = 0
                  DrawText(nLeft, nTop, Str(nCellValue), #SCS_Grey, grWDT\nCanvasBackColor)
                Else
                  DrawText(nLeft, nTop, Str(nCellValue), #SCS_Black, grWDT\nCanvasBackColor)
                EndIf
                bTestUpdated = #True
              Next m
            Else
              For m = 1 To 512
                If \rDMX_In\ascData[m] <> grDMX\rPrevDMX\ascData[m]
                  nRow = (m-1) >> 5   ; equivalent to "Round((m-1) / 32, #PB_Round_Down)"
                  nCol = (m-1) - (nRow << 5)
                  nCellValue = \rDMX_In\ascData[m]
                  If grWDT\nDMXInPref = #SCS_DMX_NOTATION_PERCENT
                    nCellValue = nCellValue / 2.55
                  EndIf
                  nLeft = (nCol * grWDT\nColWidth) + grWDT\nTitleWidth + 4
                  nTop = (nRow * grWDT\nRowHeight) + gl3DBorderHeight + grWDT\nTopMargin
                  Box(nLeft, nTop, grWDT\nColWidth - 5, grWDT\nRowHeight - 5, grWDT\nCanvasBackColor)
                  If nCellValue = 0
                    DrawText(nLeft, nTop, Str(nCellValue), #SCS_Grey, grWDT\nCanvasBackColor)
                  Else
                    DrawText(nLeft, nTop, Str(nCellValue), #SCS_Black, grWDT\nCanvasBackColor)
                  EndIf
                  bTestUpdated = #True
                EndIf
              Next m
            EndIf
            StopDrawing()
          EndIf
        EndIf
        
        grDMX\rPrevDMX = \rDMX_In
        grDMX\bDMXFirstTime = #False
        \bDone = #True
        
      EndIf
      
    EndWith
  Next n
  
  If bTestUpdated
    SAG(-1)
  EndIf
  
  If grDMX\bDMXInLocked
    ProcedureReturn
  EndIf
  
  nCountNotDone = 0
  For n = 0 To grDMX\nDMXInCount - 1
    If gaDMXIns(n)\bDone = #False
      nCountNotDone + 1
    EndIf
  Next n
  If nCountNotDone = 0
    grDMX\nDMXInCount = 0
    ; debugMsg3(sProcName, "grDMX\nDMXInCount=" + grDMX\nDMXInCount)
  EndIf
  
EndProcedure

Procedure.s DMXCmdAbbrForCmdNo(nCmdNo)
  PROCNAMEC()
  Protected sCmdAbbr.s
  
  Select nCmdNo
    Case #SCS_DMX_GO_BUTTON
      sCmdAbbr = "GoButton"
    Case #SCS_DMX_STOP_ALL
      sCmdAbbr = "StopAll"
    Case #SCS_DMX_PAUSE_RESUME_ALL
      sCmdAbbr = "PauseResumeAll"
    Case #SCS_DMX_GO_TO_TOP
      sCmdAbbr = "GoToTop"
    Case #SCS_DMX_GO_BACK
      sCmdAbbr = "GoBack"
    Case #SCS_DMX_GO_TO_NEXT
      sCmdAbbr = "GoToNext"
    Case #SCS_DMX_MASTER_FADER
      sCmdAbbr = "MasterFader"
    Case #SCS_DMX_PLAY_DMX_CUE_0
      sCmdAbbr = "PlayDMXCue0"
    Case #SCS_DMX_PLAY_DMX_CUE_MAX
      sCmdAbbr = "PlayDMXCueMax"
    Default
      sCmdAbbr = Str(nCmdNo)
  EndSelect
  ProcedureReturn Trim(sCmdAbbr)
EndProcedure

Procedure.s DMXCmdDescrForCmdNo(nCmdNo)
  PROCNAMEC()
  Protected sCmdDescr.s, sRange.s
  
  ; debugMsg(sProcName, #SCS_START + ", nCmdNo=" + nCmdNo)
  
  Select nCmdNo
    Case #SCS_DMX_GO_BUTTON
      sCmdDescr = Lang("Remote", "GoButton") ; "'Go' Button"
    Case #SCS_DMX_STOP_ALL
      sCmdDescr = Lang("Remote", "StopAll") ; "Stop Everything"
    Case #SCS_DMX_PAUSE_RESUME_ALL
      sCmdDescr = "Pause/Resume All"
    Case #SCS_DMX_GO_TO_TOP
      sCmdDescr = "Go To Top"
    Case #SCS_DMX_GO_BACK
      sCmdDescr = "Go Back"
    Case #SCS_DMX_GO_TO_NEXT
      sCmdDescr = "Go To Next"
    Case #SCS_DMX_MASTER_FADER
      sCmdDescr = "Master Fader"
    Case #SCS_DMX_PLAY_DMX_CUE_0
      sCmdDescr = "Play DMX Cue 0"
    Case #SCS_DMX_PLAY_DMX_CUE_MAX
      sCmdDescr = "Upper Limit of Play DMX Cue #"
    Default
      sCmdDescr = Str(nCmdNo)
  EndSelect
  ProcedureReturn Trim(sCmdDescr)
EndProcedure

Procedure DMX_getDMXDevPtr(sName.s, sSerial.s, nSerial.l, bDummy)
  ; PROCNAMEC()
  Protected n, nDMXDevPtr=-1
  
  ; debugMsg(sProcName, #SCS_START + ", sName=" + sName + ", sSerial=" + sSerial + ", nSerial=" + nSerial + ", bDummy=" + strB(bDummy))
  
  If sName
    If nSerial
      For n = 0 To grDMX\nNumDMXDevs - 1
        With gaDMXDevice(n)
          ; debugMsg(sProcName, "gaDMXDevice(" + n + ")\sName=" + \sName + ", \nSerial=" + \nSerial)
          If (\sName = sName) And (\nSerial = nSerial)
            nDMXDevPtr = n
            Break
          EndIf
        EndWith
      Next n
    EndIf
    If nDMXDevPtr < 0
      ; nb do not check for sSerial being present as it will be blank for 'Dummy DMX Port'
      For n = 0 To grDMX\nNumDMXDevs - 1
        With gaDMXDevice(n)
          ; debugMsg(sProcName, "gaDMXDevice(" + n + ")\sName=" + \sName + ", \sSerial=" + \sSerial)
          If (bDummy And \bDummy) Or ((\sName = sName) And (\sSerial = sSerial))
            nDMXDevPtr = n
            Break
          EndIf
        EndWith
        Next n
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nDMXDevPtr)
  ProcedureReturn nDMXDevPtr
  
EndProcedure

Procedure DMX_getDMXDevPtrForFTHandle(nFTHandle.i)
  ; PROCNAMEC()
  Protected n, nDMXDevPtr=-1
  
  ; debugMsg(sProcName, #SCS_START + ", nFTHandle=" + nFTHandle)
  
  If nFTHandle
    For n = 0 To grDMX\nNumDMXDevs - 1
      With gaDMXDevice(n)
        If \nFTHandle = nFTHandle
          nDMXDevPtr = n
          Break
        EndIf
      EndWith
    Next n
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nDMXDevPtr)
  ProcedureReturn nDMXDevPtr
  
EndProcedure

Procedure.s DMX_buildDMXValuesStringDetail(*rProd.tyProd, *rSub.tySub, nDefDMXFadeTime)
  ; NOTE: updates *rSub so if editing must be called within a PreChangeSub/PostChangeSub sequence
  ; PROCNAMEC()
  Protected sDMXValuesStringDetail.s
  Protected nStepIndex, nItemIndex, nFixtureIndex, nChanIndex, nMyDefDMXFadeTime
  Protected sDefDMXFadeTime.s
  Protected sDMXItemStr.s
  Protected bSkipSemi
  
  ; don't log unnecessarily as this procedure may be called many times when the user drags the DMX Value slider
  ; debugMsg(sProcName, #SCS_START + ", *rSub\sSubLabel=" + *rSub\sSubLabel)
  
  With *rSub
    If \bDMXSend
      setSubLTDisplayInfo(*rSub) ; 4Jun2019 11.8.1.1ak: moved here from end of procedure as setSubLTDisplayInfo() sets \sLTDisplayInfo which is required later in this current procedure
      Select \nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          ; debugMsg0(sProcName, "\sDMXSendString=" + \sDMXSendString)
          If \nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            nMyDefDMXFadeTime = nDefDMXFadeTime
            If nMyDefDMXFadeTime > 0
              sDefDMXFadeTime = timeToStringD(nMyDefDMXFadeTime, 0, #True)
            EndIf
          Else ; #SCS_LT_ENTRY_TYPE_DMX_CAPTURE
            nMyDefDMXFadeTime = 0
          EndIf
          
          ; debugMsg(sProcName, "\nMaxChaseStepIndex=" + \nMaxChaseStepIndex + ", \bChase=" + strB(\bChase) + ", ArraySize(\aChaseStep())=" + ArraySize(\aChaseStep()))
          For nStepIndex = 0 To \nMaxChaseStepIndex
            If \bChase
              If nStepIndex = 0
                sDMXValuesStringDetail + "(1) "
              Else
                sDMXValuesStringDetail + "; (" + Str(nStepIndex+1) + ") "
              EndIf
              bSkipSemi = #True
            EndIf
            For nItemIndex = 0 To \aChaseStep(nStepIndex)\nDMXSendItemCount-1
              sDMXItemStr = Trim(StringField(\aChaseStep(nStepIndex)\aDMXSendItem(nItemIndex)\sDMXItemStr, 1, "//"))
              If sDMXItemStr
                If bSkipSemi = #False
                  If sDMXValuesStringDetail
                    sDMXValuesStringDetail + "; "
                  EndIf
                EndIf
                bSkipSemi = #False
                sDMXValuesStringDetail + sDMXItemStr
                If (\aChaseStep(nStepIndex)\aDMXSendItem(nItemIndex)\nDMXFadeTime < 0) And (nMyDefDMXFadeTime > 0)
                  sDMXValuesStringDetail + "f" + sDefDMXFadeTime
                EndIf
              EndIf
            Next nItemIndex
          Next nStepIndex
          
        Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS, #SCS_LT_ENTRY_TYPE_BLACKOUT
          sDMXValuesStringDetail = \sLTDisplayInfo
          
      EndSelect
      \sDMXSendString = Trim(sDMXValuesStringDetail)
      ; debugMsg0(sProcName, "\sLTDisplayInfo=" + \sLTDisplayInfo)
      ; debugMsg0(sProcName, "\sDMXSendString=" + \sDMXSendString)
      ; setSubLTDisplayInfo(*rSub) ; 4Jun2019 11.8.1.1ak: moved to start of procedure as setSubLTDisplayInfo() sets \sLTDisplayInfo which is required earlier in this current procedure
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + sDMXValuesStringDetail)
  ProcedureReturn sDMXValuesStringDetail
  
EndProcedure

Procedure.s DMX_buildDMXValuesString(pSubPtr, bPrimaryFile=#True)
  PROCNAME(buildSubProcName(#PB_Compiler_Procedure, pSubPtr, bPrimaryFile))
  ; NOTE: calls a procedure that updates *rSub so if editing must be called within a PreChangeSub/PostChangeSub sequence
  Protected sDMXValuesString.s
  Protected nDefFadeTime, nFadeOutOthersTime
  Protected bFadeOutOthers
  Static sFadeOutOthers.s
  Static bStaticLoaded
  Protected bTrace = #False
  
  ; don't log unnecessarily as this procedure may be called many times when the user drags the DMX Value slider
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sFadeOutOthers = Lang("DMX", "FadeOutOthers")
    bStaticLoaded = #True
  EndIf
  
  If pSubPtr >= 0
    If bPrimaryFile
      With aSub(pSubPtr)
        ; debugMsg(sProcName, "\bSubTypeK=" + strB(\bSubTypeK) + ", \nLTEntryType=" + decodeLTEntryType(\nLTEntryType))
        nDefFadeTime = DMX_getDefFadeTimeForSub(@aSub(pSubPtr), @grProd)
        sDMXValuesString = DMX_buildDMXValuesStringDetail(@grProd, @aSub(pSubPtr), nDefFadeTime)
        Select \nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            If \nLTDIFadeOutOthersAction <> #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              bFadeOutOthers = #True
              nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@aSub(pSubPtr), @grProd)
            EndIf
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            If \nLTFIFadeOutOthersAction <> #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              bFadeOutOthers = #True
              nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@aSub(pSubPtr), @grProd)
            EndIf
        EndSelect
        ; sDMXValuesString = DMX_buildDMXValuesStringDetail(@grProd, @aSub(pSubPtr), nDefFadeTime) ; Del 18Aug2021 11.8.5.1ab (redundant as already called earlier in this procedure!)
      EndWith
    Else
      With a2ndSub(pSubPtr)
        nDefFadeTime = DMX_getDefFadeTimeForSub(@a2ndSub(pSubPtr), @gr2ndProd)
        sDMXValuesString = DMX_buildDMXValuesStringDetail(@gr2ndProd, @a2ndSub(pSubPtr), nDefFadeTime)
        Select \nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            If \nLTDIFadeOutOthersAction <> #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              bFadeOutOthers = #True
              nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@a2ndSub(pSubPtr), @gr2ndProd)
            EndIf
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            If \nLTFIFadeOutOthersAction <> #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              bFadeOutOthers = #True
              nFadeOutOthersTime = DMX_getFadeOutOthersTimeForSub(@a2ndSub(pSubPtr), @gr2ndProd)
            EndIf
        EndSelect
      EndWith
    EndIf
    
    If bFadeOutOthers
      sDMXValuesString + "  (+ " + sFadeOutOthers + " " + timeToStringD(nFadeOutOthersTime, 0, #True) + ")"
    EndIf
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + sDMXValuesString)
  ProcedureReturn sDMXValuesString

EndProcedure

Procedure.s DMX_buildDMXDisplayInfo(*rSub.tySub)
  ; PROCNAMEC()
  Protected sDisplayInfo.s
  
  ; don't log unnecessarily as this procedure may be called many times when the user drags the DMX Value slider
  ; debugMsg(sProcName, #SCS_START)
  
  With *rSub
    ; debugMsg0(sProcName, "\sSubLabel=" + \sSubLabel + ", \bDMXSend=" + strB(\bDMXSend) + ", \sDMXSendString=" + \sDMXSendString) ; + ", \nDMXSendItemCount=" + \nDMXSendItemCount)
    If \bDMXSend
      sDisplayInfo = \sDMXSendString
    EndIf
  EndWith
  ; debugMsg0(sProcName, #SCS_END + ", returning " + sDisplayInfo)
  ProcedureReturn sDisplayInfo
  
EndProcedure

Procedure DMX_FTDI_SendData(ftHandle.i, label.a, *aData, length.w)
  PROCNAMEC()
  ; based on function FTDI_SendData in "ENTTEC\pro_example_v2\EXAMPLE\usb_pro_example.cpp"
  ; * Author	: ENTTEC
  ; * Purpose  : Send Data (DMX or other packets) to the PRO
  ; * Parameters: Label, Pointer to Data Structure, Length of Data
  ; DMX_FTDI_SendData() returns #True if successful, else #False
  Protected end_code.a = #ENTTEC_DMX_END_CODE ; #ENTTEC_DMX_END_CODE = $E7
  Protected res.l = 0
  Protected bytes_written.l = 0
  Protected event.l = #Null
  Protected size.w = 0
  Protected rDMXHeader.Struct_Header
  CompilerIf #cTraceDMX Or #cTraceFTCalls Or #cTraceDMX_FTDI_SendData
    Protected sftHandle.s
  CompilerEndIf
  
  CompilerIf #cTraceDMX Or #cTraceFTCalls Or #cTraceDMX_FTDI_SendData
    sftHandle = decodeHandle(ftHandle)
    debugMsg(sProcName, #SCS_START + ", ftHandle=" + sftHandle + ", label=" + decodeDMXAPILabel(label) + ", length=" + length)
  CompilerEndIf
  
  ; form packet header
  rDMXHeader\Delim = #ENTTEC_DMX_START_CODE ; #ENTTEC_DMX_START_CODE = $7E
  rDMXHeader\byLabel = label
  rDMXHeader\nLength = length
  ; write the header
  res = FT_Write(ftHandle, @rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH, @bytes_written)
  If res <> #FT_OK
    debugMsg(sProcName, "FT_Write(" + decodeHandle(ftHandle) + ", @rDMXHeader, " + #ENTTEC_DMX_HEADER_LENGTH + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(@rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH))
  Else
    CompilerIf #cTraceDMX Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Write(" + sftHandle + ", @rDMXHeader, " + #ENTTEC_DMX_HEADER_LENGTH + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(@rDMXHeader, #ENTTEC_DMX_HEADER_LENGTH))
    CompilerEndIf
  EndIf
  If bytes_written <> #ENTTEC_DMX_HEADER_LENGTH
    ProcedureReturn #False
  EndIf
  
  ; write the data
  res = FT_Write(ftHandle, *aData, length, @bytes_written)
  If res <> #FT_OK
    debugMsg(sProcName, "FT_Write(" + decodeHandle(ftHandle) + ", *aData, " + length + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(*aData, length, #True))
  Else
    CompilerIf #cTraceDMX Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Write(" + sftHandle + ", *aData, " + length + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(*aData, length, #True))
    CompilerEndIf
  EndIf
  If bytes_written <> length
    ProcedureReturn #False
  EndIf
  
  ; write the end code
  res = FT_Write(ftHandle, @end_code, 1, @bytes_written)
  If res <> #FT_OK
    debugMsg(sProcName, "FT_Write(" + decodeHandle(ftHandle) + ", @end_code, " + 1 + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(@end_code, 1))
  Else
    CompilerIf #cTraceDMX Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Write(" + sftHandle + ", @end_code, " + 1 + ", @bytes_written) returned " + decodeFTStatus(res) + ", bytes_written=" + bytes_written + ", $" + memoryToHexString(@end_code, 1))
    CompilerEndIf
  EndIf
  If bytes_written <> 1
    ProcedureReturn #False
  EndIf
  
  If res = #FT_OK
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
  
EndProcedure

Procedure DMX_FTDI_EnableMidi(ftHandle.i)
  PROCNAMEC()
  ; based on function enable_midi in "ENTTEC\pro_example_v2\EXAMPLE\usb_pro_example.cpp"
  ; * Author	: ENTTEC
  ; * Purpose  : Enables MIDI on Port2  
  ; * Parameters: none
  Protected Dim port_assignment.a(1)
  Protected bFTDIResult
  Protected nDMXDevPtr
  
  port_assignment(0) = 1  ; DMX port 1 enabled For DMX And RDM
  port_assignment(1) = 2  ; DMX port 2 enabled For MIDI
  bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_SET_PORT_ASSIGNMENT, @port_assignment(0), 2)
  debugMsg3(sProcName, "DMX_FTDI_SendData(" + decodeHandle(ftHandle) + ", #SET_PORT_ASSIGNMENT, @port_assignment, 2) returned " + strB(bFTDIResult))
  Delay(200)  ; nb init_promk2() in usb_pro_example.cpp includes sleep(200) here
  
  nDMXDevPtr = DMX_getDMXDevPtrForFTHandle(ftHandle)
  If nDMXDevPtr >= 0
    gaDMXDevice(nDMXDevPtr)\bMidiEnabled = #True
  EndIf
  
EndProcedure

Procedure DMX_FTDI_ReceiveData(ftHandle.i, nReqdLabel.a, *aData, nExpectedLength.w, bWaitForReqdLabel=#True)
  PROCNAMEC()
  ; based on function FTDI_ReceiveData in "ENTTEC\pro_example_v2\EXAMPLE\usb_pro_example.cpp"
  ; * Author	: ENTTEC
  ; * Purpose  : Receive Data (DMX or other packets) from the PRO
  ; * Parameters: Label, Pointer to Data Structure, Length of Data
  ; DMX_FTDI_ReceiveData() returns #True if successful, else #False
  Protected res.l = 0
  Protected length.l = 0
  Protected bytes_to_read.l = 1
  Protected bytes_read.l = 0
  Protected onebyte.a = 0
  Protected Dim buffer.a(600)
  Protected n, sBufferHex.s
  Protected sftHandle.s
  Protected nMessageLabel.a
  Protected qStartTime.q, qTimeNow.q, nTimeOutPeriod, nLoopCount
  
  qStartTime = ElapsedMilliseconds()
  nTimeOutPeriod = 500
  
  CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
    sftHandle = decodeHandle(ftHandle)
    debugMsg(sProcName, #SCS_START + ", ftHandle=" + sftHandle + ", nReqdLabel=" + decodeDMXAPILabel(nReqdLabel) + ", nExpectedLength=" + nExpectedLength + ", bWaitForReqdLabel=" + strB(bWaitForReqdLabel))
  CompilerEndIf
  
  ; Check for Start Code and matching Label
  While (nMessageLabel <> nReqdLabel)
    ; scan for the 'Start of message delimiter, hex 7E' (which should be the first onebyte received)
    nLoopCount = 0
    While (onebyte <> #ENTTEC_DMX_START_CODE) ; #ENTTEC_DMX_START_CODE = $7E
      res = FT_Read(ftHandle, @onebyte, 1, @bytes_read)
      CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
        If onebyte <> 0
          ; nb this loop is waiting for a start code ($7E) but 0 (zero) seems to be constantly sent during that wait time
          debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", onebyte=$" + hex2(onebyte))
        EndIf
      CompilerEndIf
      If bytes_read = #ENTTEC_NO_RESPONSE
        ProcedureReturn #False
      EndIf
      qTimeNow = ElapsedMilliseconds()
      If (qTimeNow - qStartTime) > nTimeOutPeriod
        debugMsg(sProcName, "Timed out. qStartTime=" + traceTime(qStartTime))
        ProcedureReturn #False
      EndIf
    Wend
    
    ; now read the 'Label to identify type of message'
    res = FT_Read(ftHandle, @onebyte, 1, @bytes_read)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", onebyte=$" + hex2(onebyte) + ", Label=" + decodeDMXAPILabel(onebyte))
    CompilerEndIf
    If (res <> #FT_OK) Or (bytes_read = #ENTTEC_NO_RESPONSE)
      debugMsg(sProcName, "returning #False because res=" + res + " or bytes_read=#ENTTEC_NO_RESPONSE")
      ProcedureReturn #False
    EndIf
    nMessageLabel = onebyte
    
    ; now read the data length (saved in two bytes)
    res = FT_Read(ftHandle, @onebyte, 1, @bytes_read)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", onebyte=$" + hex2(onebyte))
    CompilerEndIf
    If (res <> #FT_OK) Or (bytes_read = #ENTTEC_NO_RESPONSE)
      debugMsg(sProcName, "returning #False because res=" + res + " or bytes_read=#ENTTEC_NO_RESPONSE")
      ProcedureReturn #False
    EndIf
    length = onebyte
    res = FT_Read(ftHandle, @onebyte, 1, @bytes_read)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", onebyte=$" + hex2(onebyte))
    CompilerEndIf
    If (res <> #FT_OK)
      debugMsg(sProcName, "returning #False because res=" + res)
      ProcedureReturn #False
    EndIf
    length + (onebyte << #ENTTEC_BYTE_LENGTH)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      debugMsg(sProcName, "length=" + length)
    CompilerEndIf
;     ; Check Length is not greater than allowed
;     If (length > #ENTTEC_DMX_PACKET_SIZE)
;       debugMsg(sProcName, "returning #False because res=" + res)
;       ProcedureReturn #False
;     EndIf
    
    ; Read the data bytes
    res = FT_Read(ftHandle, @buffer(0), length, @bytes_read)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      sBufferHex = ""
      For n = 1 To bytes_read
        If n > 100
          sBufferHex + "..."
          Break
        EndIf
        sBufferHex + hex2(buffer(n-1))
      Next n
      debugMsg(sProcName, "FT_Read(" + sftHandle + ", @buffer, length=" + length + ", @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", buffer=$" + sBufferHex)
    CompilerEndIf
    If (res <> #FT_OK) Or (bytes_read <> length)
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    EndIf
    
    ; Check the end code
    res = FT_Read(ftHandle, @onebyte, 1, @bytes_read)
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      If res = #FT_OK
        debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read + ", onebyte=$" + hex2(onebyte))
      Else
        debugMsg(sProcName, "FT_Read(" + sftHandle + ", @onebyte, 1, @bytes_read) returned " + decodeFTStatus(res) + ", bytes_read=" + bytes_read)
      EndIf
    CompilerEndIf
    If (res <> #FT_OK) Or (bytes_read = #ENTTEC_NO_RESPONSE)
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    EndIf
    If (onebyte <> #ENTTEC_DMX_END_CODE) ; #ENTTEC_DMX_END_CODE = $E7
      debugMsg(sProcName, "returning #False")
      ProcedureReturn #False
    EndIf
    
    If bWaitForReqdLabel = #False
      Break
    EndIf
    
    ; Added 2Jan2022 11.9aa
    qTimeNow = ElapsedMilliseconds()
    If (qTimeNow - qStartTime) > nTimeOutPeriod
      debugMsg(sProcName, "Timed out. qStartTime=" + traceTime(qStartTime))
      Break
    EndIf
    ; End added 2Jan2022 11.9aa
    
    Delay(10)
    
  Wend
  
  If nMessageLabel <> nReqdLabel
    CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
      debugMsg(sProcName, "nMessageLabel (" + nMessageLabel + ") <> nReqdLabel (" + nReqdLabel + "), so returning #False")
    CompilerEndIf
    ProcedureReturn #False
  EndIf
  
  ; Copy The Data Read To the buffer passed
  CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
    debugMsg(sProcName, "calling CopyMemory(@buffer(0), *aData, " + nExpectedLength + ")")
  CompilerEndIf
  CopyMemory(@buffer(0), *aData, nExpectedLength)
  
  CompilerIf #cTraceDMX Or #cTraceDMX_FTDI_ReceiveData Or #cTraceFTCalls
    debugMsg(sProcName, #SCS_END + ", returning #True")
  CompilerEndIf
  ProcedureReturn #True
EndProcedure

Procedure.i DMX_FTDI_OpenDevice(device_num.l)
  PROCNAMEC()
  ; based on function FTDI_OpenDevice in "ENTTEC\pro_example_v2\EXAMPLE\usb_pro_example.cpp"
  ; * Author	: ENTTEC
  ; * Purpose  : Opens the PRO; Tests various parameters; outputs info
  ; * Parameters: device num (returned by the List Device function), Fw Version MSB, Fw Version LSB
  ; DMX_FTDI_OpenDevice() returns ftHandle if successful, else 0
  Protected RTimeout.l = 120
  Protected WTimeout.l = 100
  Protected VersionMSB.l = 0
  Protected VersionLSB.l = 0
  ; Protected temp.l ; temp.a[4]  ; temp.a[4] not valid PB syntax but temp only used to store a 4-onebyte response and not actually read
  Protected Dim temp.a(3)
  Protected sSerial.s, nSerial.l
  Protected version.l
  Protected major_ver.a, minor_ver.a, build_ver.a
  Protected recvd.w = 0
  Protected onebyte.a = 0
  Protected size.w = 0
  Protected bFTDIResult
  Protected tries.w = 0
  Protected latencyTimer.a
  Protected BreakTime.w
  Protected MABTime.w
  Protected PRO_Params.DMXUSBPROParamsType
  Protected send_on_change_flag.a
  Protected ftHandle.i, sfthandle.s
  Protected ftStatus.l
  Protected nDMXDevType
  Protected hardware_version.a
  Protected nAPIKey.l ; see ENTTEC document PRO2_API_04.pdf
  
  Protected Dim port_assignment.a(1)
  ; port_assignment(0) = DMX port 1 assignment.
  ;   0: Port disabled.
  ;   1: Port enabled for DMX and RDM.
  ; port_assignment(1) = DMX port 2, MIDI IN port and MIDI OUT port assignment.
  ;   0: Ports disabled.
  ;   1: DMX port enabled for DMX and RDM.
  ;   2: MIDI IN And MIDI OUT ports enabled.
  
  ; Try at least 3 times
  ftStatus = -1
  While ((ftStatus <> #FT_OK) And (tries < 3))
    debugMsg(sProcName, "------ D2XX ------- Opening [Device " + device_num + "] ------ Try " + tries)
    ; Open the PRO 
    ftStatus = FT_Open(device_num, @ftHandle)
    debugMsg2(sProcName, "FT_Open(" + device_num + ", @ftHandle)", ftStatus)
    If ftStatus = #FT_OK
      Break
    EndIf
    ; delay for next try
    Delay(750);
    tries + 1
  Wend
  ; PRO Opened succesfully
  If (ftStatus = #FT_OK)
    newHandle(#SCS_HANDLE_DMX, ftHandle, #False)
    sfthandle = decodeHandle(ftHandle)
    
    nDMXDevType = gaDMXDevice(device_num)\nDMXDevType
    debugMsg(sProcName, "nDMXDevType=" + decodeDMXDevType(nDMXDevType))
    
    ; get D2XX driver version
    ftStatus = FT_GetDriverVersion(ftHandle, @version)
    debugMsg2(sProcName, "FT_GetDriverVersion(" + sftHandle + ", @version)", ftStatus)
    If ftStatus = #FT_OK
      major_ver = version >> 16 & $FF
      minor_ver = (version >> 8) & $FF
      build_ver = version & $FF
      ; debugMsg(sProcName, "D2XX Driver Version: " + major_ver + "." + minor_ver + "." + build_ver + ", version=$" + Hex(version,#PB_Long))
      ; modified 9Nov2018 11.8.0at following investigation for Ryan Rohrer, when I found that the Windows File Properties for ftd2xx.dll show the hex version
      ; of the version number, eg the Product Version displayed was 2.12.24.1 whereas SCS log showed "D2XX Driver Version: 2.18.36, version=$21224".
      ; note that the FTDI documenetation states that the final onebyte is 'currently set to zero'.
      debugMsg(sProcName, "D2XX Driver Version: " + Hex(major_ver) + "." + Hex(minor_ver) + "." + Hex(build_ver) + ", version=$" + Hex(version,#PB_Long))
    Else
      debugMsg(sProcName, "Unable to Get D2XX Driver Version")
    EndIf
    
    ; get latency timer
    ftStatus = FT_GetLatencyTimer(ftHandle, @latencyTimer)
    debugMsg2(sProcName, "FT_GetLatencyTimer(" + sftHandle + ", @latencyTimer)", ftStatus)
    If ftStatus = #FT_OK
      debugMsg(sProcName, "latencyTimer=" + latencyTimer)
    Else
      debugMsg(sProcName, "Unable to Get Latency Timer")
    EndIf
    
    ; SET Default Read & Write Timeouts (in milliseconds)
    ftStatus = FT_SetTimeouts(ftHandle, RTimeout, WTimeout)
    debugMsg2(sProcName, "FT_SetTimeouts(" + sftHandle + ", " + RTimeout + ", " + WTimeout + ")", ftStatus)
    
    ; Purge the buffer
    ftStatus = FT_Purge(ftHandle, #FT_PURGE_RX)
    debugMsg2(sProcName, "FT_Purge(" + sftHandle + ", #FT_PURGE_RX)", ftStatus)
    
    ; Send Get Widget Parameters to get Device Info
    debugMsg(sProcName, "Sending GET_WIDGET_PARAMS packet... ")
    bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_GET_WIDGET_PARAMS_PORT1, @size, 2)
    debugMsg3(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_PARAMS_PORT1) + ", @size, 2) returned " + strB(bFTDIResult))
    If bFTDIResult = #False
      ftStatus = FT_Purge(ftHandle, #FT_PURGE_TX)
      debugMsg2(sProcName, "FT_Purge(" + sftHandle + ", #FT_PURGE_TX)", ftStatus)
      bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_GET_WIDGET_PARAMS_PORT1, @size, 2)
      debugMsg3(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_PARAMS_PORT1) + ", @size, 2) returned " + strB(bFTDIResult))
      If bFTDIResult = #False
        ftStatus = FT_Close(ftHandle)
        debugMsg2(sProcName, "FT_Close(" + sftHandle + ")", ftStatus)
        ; return 0 to indicate failure
        ProcedureReturn 0
      EndIf
    EndIf
    debugMsg(sProcName, decodeDMXDevType(nDMXDevType) + " Connected Successfully")
    
    Select nDMXDevType
      Case #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB, #SCS_DMX_DEV_FTDI_USB_RS485 ; #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB, #SCS_DMX_DEV_FTDI_USB_RS485
        ; reset the device
        ftStatus = FT_ResetDevice(ftHandle)
        debugMsg2(sProcName, "FT_ResetDevice(ftHandle)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed to Reset Device")
          ProcedureReturn 0
        EndIf
        
        ; set the baud rate
        ftStatus = FT_SetDivisor(ftHandle, 12)
        debugMsg2(sProcName, "FT_SetDivisor(ftHandle, 12)", ftStatus)
        If ftStatus
          debugMsg3(sProcName, "Failed To Set Baud Rate")
          ProcedureReturn 0
        EndIf
        
        ; shape the line
        ftStatus = FT_SetDataCharacteristics(ftHandle, #FT_BITS_8, #FT_STOP_BITS_2, #FT_PARITY_NONE)
        debugMsg2(sProcName, "FT_SetDataCharacteristics(ftHandle, FT_BITS_8, FT_STOP_BITS_2, FT_PARITY_NONE)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed To Set Data Characteristics")
          ProcedureReturn 0
        EndIf
        
        ; no flow control
        ftStatus = FT_SetFlowControl(ftHandle, #FT_FLOW_NONE, 0, 0)
        debugMsg2(sProcName, "FT_SetFlowControl(ftHandle, FT_FLOW_NONE, 0, 0)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed to set flow control")
          ProcedureReturn 0
        EndIf
        
        ; set send dmx
        ftStatus = FT_ClrRts(ftHandle)
        debugMsg2(sProcName, "FT_ClrRts(ftHandle)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed to set RS485 to send")
          ProcedureReturn 0
        EndIf
        
        ; Clear TX RX buffers
        ftStatus = FT_Purge(ftHandle, #FT_PURGE_TX)
        debugMsg2(sProcName, "FT_Purge(ftHandle, FT_PURGE_TX)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed to purge TX buffer")
          ProcedureReturn 0
        EndIf
        
        ftStatus = FT_Purge(ftHandle, #FT_PURGE_RX)
        debugMsg2(sProcName, "FT_Purge(ftHandle, FT_PURGE_RX)", ftStatus)
        If ftStatus <> #FT_OK
          debugMsg3(sProcName, "Failed to purge RX buffer")
          ProcedureReturn 0
        EndIf
        
      Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO, #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2 ; #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO, #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
        ; Receive Widget Response
        debugMsg(sProcName, "Waiting for GET_WIDGET_PARAMS_REPLY packet... ")
        bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, #ENTTEC_GET_WIDGET_PARAMS_PORT1, @PRO_Params, SizeOf(DMXUSBPROParamsType))
        debugMsg3(sProcName, "DMX_FTDI_ReceiveData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_PARAMS_PORT1) + " , @PRO_Params, " + SizeOf(DMXUSBPROParamsType) + ") returned " + strB(bFTDIResult))
        If bFTDIResult = #False
          ; Receive Widget Response packet
          bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, #ENTTEC_GET_WIDGET_PARAMS_PORT1, @PRO_Params, SizeOf(DMXUSBPROParamsType))
          debugMsg3(sProcName, "DMX_FTDI_ReceiveData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_PARAMS_PORT1) + ", @PRO_Params, " + SizeOf(DMXUSBPROParamsType) + ") returned " + strB(bFTDIResult))
          If bFTDIResult = #False
            ftStatus = FT_Close(ftHandle)
            debugMsg2(sProcName, "FT_Close(" + sftHandle + ")", ftStatus)
            ; return 0 to indicate failure
            ProcedureReturn 0
          EndIf
        Else
          debugMsg(sProcName, "GET WIDGET REPLY Received ... ")
        EndIf
        ; Firmware Version
        debugMsg(sProcName, "PRO_Params\FirmwareMSB=" + hex2(PRO_Params\FirmwareMSB) + ", PRO_Params\FirmwareLSB=" + hex2(PRO_Params\FirmwareLSB))
        VersionMSB = PRO_Params\FirmwareMSB
        VersionLSB = PRO_Params\FirmwareLSB
        ; Display All PRO Parameters & Info available
        debugMsg(sProcName, "-----------::PRO Connected [Information Follows]::------------")
        debugMsg(sProcName, "  FIRMWARE VERSION: " + VersionMSB + "." + VersionLSB)
        BreakTime = (PRO_Params\BreakTime * 10.67) + 100
        debugMsg(sProcName, "  BREAK TIME: " + BreakTime + " micro sec")
        MABTime = (PRO_Params\MaBTime * 10.67)
        debugMsg(sProcName, "  MAB TIME: " + MABTime + " micro sec")
        debugMsg(sProcName, "  SEND REFRESH RATE: " + PRO_Params\RefreshRate+ " packets/sec")
        ; GET PRO's serial number 
        bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_GET_WIDGET_SN, @size, 2)
        debugMsg(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_SN) + ", @size, 2) returned " + strB(bFTDIResult))
        Delay(25)
        bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, #ENTTEC_GET_WIDGET_SN, @temp(0), 4)
        debugMsg(sProcName, "DMX_FTDI_ReceiveData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_SN) + ", @temp(0), 4) returned " + strB(bFTDIResult))
        If bFTDIResult
          sSerial = hex2(temp(3)) + hex2(temp(2)) + hex2(temp(1)) + hex2(temp(0))
          If IsInteger(sSerial)
            nSerial = Val(sSerial)
          EndIf
          debugMsg(sProcName, "sSerial=" + sSerial + ", nSerial=" + nSerial)
          If nDMXDevType = #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
            bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_HARDWARE_VERSION, @size, 2)
            debugMsg(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_HARDWARE_VERSION) + ", @size, 2) returned " + strB(bFTDIResult))
            If bFTDIResult
              bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, #ENTTEC_HARDWARE_VERSION, @hardware_version, 1, #True)
              debugMsg3(sProcName, "DMX_FTDI_ReceiveData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_HARDWARE_VERSION) + ", @hardware_version, 1) returned " + strB(bFTDIResult))
              If bFTDIResult
                debugMsg(sProcName, "hardware_version=" + hardware_version)
                If hardware_version >= 2
                  ; hardware version 2 = DMX PRO MK2
                  ; hardware version 3 = DMX PRO MK2 RevB
                  ; nAPIKey = $0004A5CA ; see ENTTEC document PRO2_API_04.pdf
                  ; nAPIKey = $E403A4C9 ; see ENTTEC document PRO2_API_05.pdf
                  nAPIKey = $E201A2C7; see ENTTEC document PRO2_API_03.pdf
                  bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_SET_API_KEY, @nAPIKey, 4)
                  debugMsg3(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_SET_API_KEY) + ", @nAPIKey, 4) returned " + strB(bFTDIResult) + ", nAPIKey=$" + Hex(nAPIKey,#PB_Long))
                  If bFTDIResult
                    Delay(200)  ; nb init_promk2() in usb_pro_example.cpp includes sleep(200) here
                    ; enable both ports for DMX
                    port_assignment(0) = 1  ; DMX port 1 enabled for DMX and RDM
                    port_assignment(1) = 1  ; DMX port 2 enabled for DMX and RDM
                    bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_SET_PORT_ASSIGNMENT, @port_assignment(0), 2)
                    debugMsg3(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_SET_PORT_ASSIGNMENT) + ", @port_assignment, 2) returned " + strB(bFTDIResult) + ", port_assignment()=" + port_assignment(0) + "," + port_assignment(1))
                    If bFTDIResult
                      Delay(200)  ; nb init_promk2() in usb_pro_example.cpp includes sleep(200) here
                    EndIf
                  EndIf
                EndIf
              EndIf
            EndIf
          EndIf
        EndIf
        
      Case #SCS_DMX_DEV_ARTNET
        port_assignment(0) = 1  ; DMX port 1 enabled for DMX and RDM
        port_assignment(1) = 1  ; DMX port 2 enabled for DMX and RDM

      Case #SCS_DMX_DEV_SACN
          port_assignment(0) = 1  ; DMX port 1 enabled for DMX and RDM
          port_assignment(1) = 1  ; DMX port 2 enabled for DMX and RDM

    EndSelect
    
    ; return handle to indicate success
    ProcedureReturn ftHandle
    
  Else ; Can't open Device 
    ; return 0 to indicate failure
    ProcedureReturn 0
  EndIf
  
EndProcedure

Procedure DMX_getFadeItemIndex(nDMXDevPtr, nDMXPort, nDMXChannel, nDMXDelayTime, bCheckExistingEntriesOnly)
  PROCNAMEC()
  ; This procedure will return the grDMXFadeItems\aFadeItem() array index for the entry that matches the supplied 'primary key' parameters, ie devptr, port, channel and delay time.
  ; If no such entry is found, the procedure will create a new entry and return the array index of that entry.
  Protected nItemIndex
  Protected n
  
  ; debugMsg(sProcName, #SCS_START + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel + ", nDMXDelayTime=" + nDMXDelayTime + ", bCheckExistingEntriesOnly=" + strB(bCheckExistingEntriesOnly))
  
  With grDMXFadeItems
    nItemIndex = -1
    For n = 0 To grDMXFadeItems\nMaxFadeItem
      If \aFadeItem(n)\nDMXChannel = nDMXChannel And \aFadeItem(n)\nDMXDelayTime = nDMXDelayTime
        If (\aFadeItem(n)\nDMXDevPtr = nDMXDevPtr) And (\aFadeItem(n)\nDMXPort = nDMXPort)
          nItemIndex = n
          Break
        EndIf
      EndIf
    Next n
    
    If (nItemIndex = -1) And (bCheckExistingEntriesOnly = #False)
      For n = 0 To grDMXFadeItems\nMaxFadeItem
        If \aFadeItem(n)\nDMXChannel = 0
          ; if the DMX Channel number is zero, this entry has not yet been used, because valid DMX channel numbers are in the range 1-512
          nItemIndex = n
          Break
        EndIf
      Next n
      If nItemIndex = -1
        nItemIndex = grDMXFadeItems\nMaxFadeItem + 1
        If nItemIndex > ArraySize(\aFadeItem())
          ReDim \aFadeItem(nItemIndex+10)
        EndIf
      EndIf
      ; prime this new entry
      \aFadeItem(nItemIndex)\nDMXDevPtr = nDMXDevPtr
      \aFadeItem(nItemIndex)\nDMXPort = nDMXPort
      \aFadeItem(nItemIndex)\nDMXChannel = nDMXChannel
      \aFadeItem(nItemIndex)\nDMXDelayTime = nDMXDelayTime
      If nItemIndex > \nMaxFadeItem
        \nMaxFadeItem = nItemIndex
        ; debugMsg(sProcName, "grDMXFadeItems\nMaxFadeItem=" + \nMaxFadeItem)
      EndIf
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nItemIndex + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem)
  ProcedureReturn nItemIndex
  
EndProcedure

Procedure DMX_setMaxFadeItem()
  PROCNAMEC()
  Protected n
  Protected nMaxFadeItem = -1
  
  With grDMXFadeItems
    If gbInCalcCueStartValues = #False
      For n = 0 To grDMXFadeItems\nMaxFadeItem
        If \aFadeItem(n)\nDMXChannel > 0
          If \aFadeItem(n)\bFadeCompleted = #False
            nMaxFadeItem = n
          EndIf
        EndIf
      Next n
    EndIf
    \nMaxFadeItem = nMaxFadeItem
    ; debugMsg(sProcName, "grDMXFadeItems\nMaxFadeItem=" + \nMaxFadeItem)
  EndWith
  
EndProcedure

Procedure DMX_clearFadeItems()
  PROCNAMEC()
  Protected n, rFadeItemDef.tyDMXFadeItem
  
  With grDMXFadeItems
    For n = 0 To ArraySize(\aFadeItem())
      \aFadeItem(n) = rFadeItemDef
    Next n
    \nMaxFadeItem = -1
    ; debugMsg(sProcName, "grDMXFadeItems\nMaxFadeItem=" + \nMaxFadeItem)
  EndWith
  
EndProcedure

Procedure DMX_prepareDMXForSend(pSubPtr, bMutexAlreadyLocked=#False, bLiveDMXTest=#False, bIncludeSettingPreSubValues=#False, bIgnoreFadeTimes=#False, bBlackOutItems=#False, nChaseStepIndex=0, bSavePreHotkeyValues=#False, bUsePreHotkeyValues=#False, nDMXValuePercentage=100)
  PROCNAMECS(pSubPtr)
  Protected m, f, n
  Protected nDMXControlPtr
  Protected nDMXDevPtr, nDMXPort, nDMXChannel
  Protected nDMXSendDataBaseIndex, nItemIndex
  Protected bDMXValueChange
  Protected bFadesReqd, bFadeItemFound
  Protected qTimeNow.q
  Protected bItemPresent
  Protected nDMXFadeTime
  Protected nPreSubFadeTime
  Protected bLockedMutex
  Protected bMyBlackOutItems
  Protected bBlackoutOthersInLiveTest
  Protected nLTEntryType, nDelayIndex, nDelayTime, nCalcTargetValue
  Protected nStartValue, nTargetValue
  Protected nDMXPreHotkeyDataIndex = -1
  
  CompilerIf #cTraceDMXPrepareForSend
    debugMsg(sProcName, #SCS_START + ", bMutexAlreadyLocked=" + strB(bMutexAlreadyLocked) +
                        ", bLiveDMXTest=" + strB(bLiveDMXTest) + ", bIncludeSettingPreSubValues=" + strB(bIncludeSettingPreSubValues) +
                        ", bIgnoreFadeTimes=" + strB(bIgnoreFadeTimes) + ", bBlackOutItems=" + strB(bBlackOutItems) + ", nChaseStepIndex=" + nChaseStepIndex +
                        ", bSavePreHotkeyValues=" + strB(bSavePreHotkeyValues) + ", bUsePreHotkeyValues=" + strB(bUsePreHotkeyValues) + ", nDMXValuePercentage=" + nDMXValuePercentage)
    debugMsg(sProcName, "grDMXMasterFader\nDMXMasterFaderValue=" + grDMXMasterFader\nDMXMasterFaderValue)
  CompilerEndIf
  
  If grSession\nDMXOutEnabled <> #SCS_DEVTYPE_ENABLED
    CompilerIf #cTraceDMXPrepareForSend
      debugMsg(sProcName, "exiting because grSession\nDMXOutEnabled=" + grSession\nDMXOutEnabled)
    CompilerEndIf
    ProcedureReturn #False
  EndIf
  
  CompilerIf #cTraceDMXPrepareForSend
    For n = 0 To ArraySize(grDMXChannelItems\aDMXChannelItem())
      With grDMXChannelItems\aDMXChannelItem(n)
        If \bDMXChannelSet
          debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + n + ")\bDMXChannelSet=" + strB(\bDMXChannelSet) + ", \nDMXChannelValue=" + \nDMXChannelValue + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
        EndIf
      EndWith
    Next n
  CompilerEndIf
  
  bMyBlackOutItems = bBlackOutItems
  If pSubPtr >= 0
    If aSub(pSubPtr)\bSubTypeK
      If aSub(pSubPtr)\nDMXControlPtr < 0
        aSub(pSubPtr)\nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(aSub(pSubPtr)\nLTDevType, aSub(pSubPtr)\sLTLogicalDev)
      EndIf
      nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
      If nDMXControlPtr >= 0
        With aSub(pSubPtr)
          nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
          nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
          nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
          CompilerIf #cTraceDMXLoadChannelInfo
            debugMsg(sProcName, "\sLTLogicalDev=" + \sLTLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr + ", nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex)
          CompilerEndIf
          
          nLTEntryType = \nLTEntryType
          If bLiveDMXTest
            If grWQK\bDoNotBlackoutOthers = #False
              bBlackoutOthersInLiveTest = #True
            EndIf
          EndIf
          CompilerIf #cTraceDMXPrepareForSend
            debugMsg(sProcName, "bLiveDMXTest=" + strB(bLiveDMXTest) + ", bBlackoutOthersInLiveTest=" + strB(bBlackoutOthersInLiveTest))
          CompilerEndIf
          
          If \bDMXSend
            Select nLTEntryType
              Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                CompilerIf #cTraceDMXPrepareForSend
                  debugMsg(sProcName, "nLTEntryType=" + decodeLTEntryType(nLTEntryType) + ", \aChaseStep(" + nChaseStepIndex + ")\nDMXSendItemCount=" + \aChaseStep(nChaseStepIndex)\nDMXSendItemCount)
                CompilerEndIf
                For m = 0 To (\aChaseStep(nChaseStepIndex)\nDMXSendItemCount - 1)
                  If Trim(\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)\sDMXItemStr)
                    ; at least one item present
                    bItemPresent = #True
                    CompilerIf #cTraceDMXPrepareForSend
                      ; if tracing then trace all non-blank items
                      debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ")\aDMXSendItem(" + m + ")\sDMXItemStr=" + \aChaseStep(nChaseStepIndex)\aDMXSendItem(m)\sDMXItemStr)
                    CompilerElse
                      ; if not tracing, can 'Break' now
                      Break
                    CompilerEndIf
                  EndIf
                Next m
                
              Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
                CompilerIf #cTraceDMXPrepareForSend
                  debugMsg(sProcName, "nLTEntryType=" + decodeLTEntryType(nLTEntryType) + ", \nMaxFixture=" + \nMaxFixture)
                CompilerEndIf
                If \nMaxFixture >= 0
                  bItemPresent = #True
                  \aChaseStep(nChaseStepIndex)\aDMXSendItem(0)\sDMXItemStr = DMX_buildDMXString(@grProd, @aSub(pSubPtr), nChaseStepIndex)
                  \aChaseStep(nChaseStepIndex)\aDMXSendItem(0)\sDMXChannels = StringField(\aChaseStep(nChaseStepIndex)\aDMXSendItem(0)\sDMXItemStr, 1, "@")
                  \aChaseStep(nChaseStepIndex)\nDMXSendItemCount = 1
                  CompilerIf #cTraceDMXPrepareForSend
                    debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ")\aDMXSendItem(0)\sDMXItemStr=" + \aChaseStep(nChaseStepIndex)\aDMXSendItem(0)\sDMXItemStr)
                  CompilerEndIf
                EndIf
                
              Case #SCS_LT_ENTRY_TYPE_BLACKOUT
                bMyBlackOutItems = #True
                bItemPresent = #True
                
            EndSelect
          EndIf
        EndWith
        
        If bMutexAlreadyLocked = #False
          LockDMXSendMutex(601)
        EndIf
        
        For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
          nItemIndex = nDMXSendDataBaseIndex + nDMXChannel ; nb nDMXSendDataBaseIndex will be 0 for port 1, or 512 for port 2
          With grDMXChannelItems\aDMXChannelItem(nItemIndex)
            If bBlackoutOthersInLiveTest And \bDMXChannelDimmable ; 20Jan2021 11.8.4ab added "And \bDMXChannelDimmable"
              \nDMXChannelValue = 0 ; nb may be overridden later in this Procedure
              \bDMXChannelSet = #True
              \bDMXApplyFadeTime = #True
              CompilerIf #cTraceDMXChannelSet
                debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
              CompilerEndIf
            Else
              If \bDMXChannelSet
                \bDMXChannelSet = #False
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                CompilerEndIf
              EndIf
              \bDMXApplyFadeTime = #False
            EndIf
          EndWith
        Next nDMXChannel
        
        With grDMXChaseItems
          If \bChaseRunning
            If \bStopChase
              CompilerIf #cTraceDMXPrepareForSend
                debugMsg(sProcName,"grDMXChaseItems\bChaseRunning=#True, \bStopChase=#True, calling DMX_prepareChaseStepForSend()")
              CompilerEndIf
              DMX_prepareChaseStepForSend()
            EndIf
          EndIf
        EndWith
        
        Select nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
            CompilerIf #cTraceDMXPrepareForSend Or #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "calling DMX_loadDMXChannelItems(" + getSubLabel(pSubPtr) + ", " + nChaseStepIndex + ", " + strB(bLiveDMXTest) + ", " + strB(bBlackoutOthersInLiveTest) + ")")
            CompilerEndIf
            DMX_loadDMXChannelItems(pSubPtr, nChaseStepIndex, bLiveDMXTest, bBlackoutOthersInLiveTest)
            
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            CompilerIf #cTraceDMXPrepareForSend Or #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "calling DMX_loadDMXChannelItems(" + getSubLabel(pSubPtr) + ", " + nChaseStepIndex + ", " + strB(bLiveDMXTest) + ", " + strB(bBlackoutOthersInLiveTest) + ")")
            CompilerEndIf
            DMX_loadDMXChannelItems(pSubPtr, nChaseStepIndex, bLiveDMXTest, bBlackoutOthersInLiveTest)
            DMX_loadFadeItemsArrayForDMXCapture(pSubPtr, nChaseStepIndex)
            CompilerIf #cTraceDMXPrepareForSend
              debugMsg(sProcName, "calling DMX_clearDMXSendArrayForDMXControl(" + aSub(pSubPtr)\nDMXControlPtr + ")")
            CompilerEndIf
            DMX_clearDMXSendArrayForDMXControl(aSub(pSubPtr)\nDMXControlPtr)
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS, #SCS_LT_ENTRY_TYPE_BLACKOUT
            CompilerIf #cTraceDMXPrepareForSend Or #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "calling DMX_loadDMXChannelItemsFI(" + getSubLabel(pSubPtr) + ", " + nChaseStepIndex + ", " + strB(bLiveDMXTest) + ", " + strB(bBlackoutOthersInLiveTest) +
                                  ", " + nDMXValuePercentage + ", " + strB(bUsePreHotkeyValues) + ")")
            CompilerEndIf
            DMX_loadDMXChannelItemsFI(pSubPtr, nChaseStepIndex, bLiveDMXTest, bBlackoutOthersInLiveTest, nDMXValuePercentage, bUsePreHotkeyValues)
            
        EndSelect
        
        ; DMX_buildSubDMXDelayTimeArray(pSubPtr) populates the array grDMX\nSubDMXDelayTime() with DMX delay times for this sub, and sets grDMX\nMaxSubDMXDelayTimeIndex.
        ; If there are no DMX delay times, or if delay times are not applicable for the entry type, then grDMX\nMaxSubDMXDelayTimeIndex will be set to 0 and a dummy '0 delay' entry will be placed in the array.
        DMX_buildSubDMXDelayTimeArray(pSubPtr)
        
        ; Added 16Dec2020 11.8.3.4ab
        If bSavePreHotkeyValues
          ; prime array for later (in this procedure) saving of pre-hotkey DMX values
          nDMXPreHotkeyDataIndex = aSub(pSubPtr)\nDMXPreHotkeyDataIndex
          If nDMXPreHotkeyDataIndex < 0
            For n = 0 To ArraySize(gaDMXPreHotkeyData())
              If gaDMXPreHotkeyData(n)\nSubPtr = grDMXPreHotkeyDataDef\nSubPtr
                nDMXPreHotkeyDataIndex = n
                Break
              EndIf
            Next n
            If nDMXPreHotkeyDataIndex < 0
              nDMXPreHotkeyDataIndex = ArraySize(gaDMXPreHotkeyData()) + 1
              REDIM_ARRAY(gaDMXPreHotkeyData, nDMXPreHotkeyDataIndex, grDMXPreHotkeyDataDef, "gaDMXPreHotkeyData()")
            EndIf
          EndIf
          With gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)
            \nSubPtr = pSubPtr
            \nMaxPreHotkeyItem = -1
          EndWith
          aSub(pSubPtr)\nDMXPreHotkeyDataIndex = nDMXPreHotkeyDataIndex
          
        ElseIf bUsePreHotkeyValues
          nDMXPreHotkeyDataIndex = aSub(pSubPtr)\nDMXPreHotkeyDataIndex
          If nDMXPreHotkeyDataIndex >= 0
            If gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\nSubPtr <> pSubPtr
              ; shouldn't get here
              nDMXPreHotkeyDataIndex = -1
            EndIf
          EndIf
        EndIf
        ; End added 16Dec2020 11.8.3.4ab
        
        qTimeNow = ElapsedMilliseconds()
        
        If gaDMXControl(nDMXControlPtr)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
          For nDelayIndex = 0 To grDMX\nMaxSubDMXDelayTimeIndex
            nDelayTime = grDMX\nSubDMXDelayTime(nDelayIndex)
            For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
              nItemIndex = nDMXSendDataBaseIndex + nDMXChannel ; nb nDMXSendDataBaseIndex will be 0 for port 1, or 512 for port 2
              With grDMXChannelItems\aDMXChannelItem(nItemIndex)
                CompilerIf (#cTraceDMXPrepareForSend) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                  If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35) Or (#cTraceDMXSendChannelsNonZero And \nDMXChannelValue > 0)
                    debugMsg(sProcName, "nDelayTime=" + nDelayTime + ", grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(\bDMXChannelSet) +
                                        ", nDMXChannel=" + nDMXChannel + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime + ", \nDMXChannelValue=" + \nDMXChannelValue)
                  EndIf
                CompilerEndIf
                If \bDMXChannelSet
                  Select nLTEntryType
                    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP, #SCS_LT_ENTRY_TYPE_DMX_ITEMS ; Added #SCS_LT_ENTRY_TYPE_DMX_ITEMS 25Sep2024 11.10.6aa following bug reported by Sascha Pirkowski
                      nDMXFadeTime = \nDMXChannelFadeTime
                    Default
                      ; debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime + ", \nDMXChannelValue=" + \nDMXChannelValue + ", \bDMXChannelDimmable=" + strB(\bDMXChannelDimmable) + ", \bDMXApplyFadeTime=" + strB(\bDMXApplyFadeTime))
                      If (\bDMXChannelDimmable = #False) And (\bDMXApplyFadeTime = #False)
                        nDMXFadeTime = 0
                        ; debugMsg(sProcName, "nDMXFadeTime=" + nDMXFadeTime + ", \bDMXChannelDimmable=" + strB(\bDMXChannelDimmable) + ", \bDMXApplyFadeTime=" + strB(\bDMXApplyFadeTime))
                      Else
                        If bIgnoreFadeTimes ; Or bUsePreHotkeyValues ; commented out bUsePreHotkeyValues 12Jun2024 11.10.3al
                          nDMXFadeTime = 0
                          ; debugMsg(sProcName, "nDMXFadeTime=" + nDMXFadeTime + ", bIgnoreFadeTimes=" + strB(bIgnoreFadeTimes) + ", bUsePreHotkeyValues=" + strB(bUsePreHotkeyValues))
                        Else
                          nDMXFadeTime = \nDMXChannelFadeTime
                          ; debugMsg(sProcName, "nDMXFadeTime=" + nDMXFadeTime)
                        EndIf
                      EndIf ; EndIf (\bDMXChannelDimmable = #False) And (\bDMXApplyFadeTime = #False) / Else
                  EndSelect
                  ; debugMsg(sProcName, "nDMXFadeTime=" + nDMXFadeTime)
                  If bSavePreHotkeyValues
                    If nDMXPreHotkeyDataIndex >= 0
                      gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\nMaxPreHotkeyItem + 1
                      n = gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\nMaxPreHotkeyItem
                      If n > ArraySize(gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem())
                        ReDim gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n+10)
                      EndIf
                      gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXSendDataItemIndex = nItemIndex
                      gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXValue = gaDMXSendData(nItemIndex)
                      debugMsg(sProcName, "gaDMXPreHotkeyData(" + nDMXPreHotkeyDataIndex + ")\aPreHotkeyItem(" + n + ")\nDMXSendDataItemIndex=" +
                                          gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXSendDataItemIndex +
                                          ", \nDMXValue=" + gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXValue)
                    EndIf
                    ; End changed 16Dec2020 11.8.3.4ab
                  EndIf
                  CompilerIf (#cTraceDMXPrepareForSend) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                    If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35) Or (#cTraceDMXSendChannelsNonZero And \nDMXChannelValue > 0)
                      debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\nDMXChannelFadeTime=" + \nDMXChannelFadeTime + ", nDMXChannel=" + nDMXChannel + ", nDMXFadeTime=" + nDMXFadeTime)
                    EndIf
                  CompilerEndIf
                Else
                  \nDMXChannelValue = gaDMXSendData(nItemIndex) ; Added 27Mar2021 11.8.4.1ah following bug reported by Willi Härtel
                EndIf ; INFO 8Sep2020 11.8.2.3aw
                
                If aSub(pSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ Or aSub(pSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
                  If nDelayTime = 0
                    nCalcTargetValue = DMX_calcChannelTargetValueAtDelayTime(pSubPtr, nDMXControlPtr, nDMXChannel, nDelayTime)
                    ; If DMX_calcChannelTargetValueAtDelayTime() returns -1 then this means there is no DMX string entry for this device, channel and delay time
                    If nCalcTargetValue >= 0
                      gaDMXSendData(nItemIndex) = nCalcTargetValue
                      gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
                    EndIf
                  EndIf
                  
                ElseIf nDMXFadeTime > 0
                  nStartValue = gaDMXSendData(nItemIndex)
                  If grDMXMasterFader\nDMXMasterFaderValue = 100
                    nTargetValue = \nDMXChannelValue
                  Else
                    nTargetValue = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
                  EndIf
                  If nTargetValue <> nStartValue
                    f = DMX_getFadeItemIndex(nDMXDevPtr, nDMXPort, nDMXChannel, nDelayTime, #False)
                    ; Note: if this call to DMX_getFadeItemIndex() cannot find an entry for the supplied parameters, it will return a pointer to a blank entry that can be used
                    CompilerIf #cTraceDMXPrepareForSend
                      debugMsg(sProcName, "nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel + ", f=" + f +
                                          ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem + ", ArraySize(grDMXFadeItems\aFadeItem())=" + ArraySize(grDMXFadeItems\aFadeItem()))
                    CompilerEndIf
                    grDMXFadeItems\aFadeItem(f)\nFadeTime = nDMXFadeTime
                    grDMXFadeItems\aFadeItem(f)\qStartTime = qTimeNow + nDelayTime
                    grDMXFadeItems\aFadeItem(f)\nStartValue = nStartValue
                    grDMXFadeItems\aFadeItem(f)\nTargetValue = nTargetValue
                    grDMXFadeItems\aFadeItem(f)\bFadeCompleted = #False
                    grDMXFadeItems\aFadeItem(f)\nSubPtr = pSubPtr
                    CompilerIf (#cTraceDMXPrepareForSend) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                      If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35) Or
                         (#cTraceDMXSendChannelsNonZero And (nStartValue > 0 Or nTargetValue > 0))
                        debugMsg(sProcName, "grDMXFadeItems\aFadeItem(" + f + ")\nDMXDelayTime=" + grDMXFadeItems\aFadeItem(f)\nDMXDelayTime +
                                            ", \nDMXDevPtr=" + grDMXFadeItems\aFadeItem(f)\nDMXDevPtr +
                                            ", \nDMXPort=" + grDMXFadeItems\aFadeItem(f)\nDMXPort +
                                            ", \nDMXChannel=" + grDMXFadeItems\aFadeItem(f)\nDMXChannel +
                                            ", \nFadeTime=" + grDMXFadeItems\aFadeItem(f)\nFadeTime +
                                            ", \qStartTime=" + traceTime(grDMXFadeItems\aFadeItem(f)\qStartTime) +
                                            ", \nStartValue=" + grDMXFadeItems\aFadeItem(f)\nStartValue +
                                            ", \nTargetValue=" + grDMXFadeItems\aFadeItem(f)\nTargetValue)
                      EndIf
                    CompilerEndIf
                    bFadesReqd = #True
                  EndIf
                Else
                  ; cancel any existing fade for this DMX channel, because we are implementing LTP (Last Takes Precedence)
                  If \bDMXChannelSet ; Added this test 4May2021 11.8.4.2af following bug report from Dieter
                    f = DMX_getFadeItemIndex(nDMXDevPtr, nDMXPort, nDMXChannel, 0, #True)
                    If f >= 0
                      CompilerIf #cTraceDMXPrepareForSend
                        If grDMXFadeItems\aFadeItem(f)\bFadeCompleted = #False
                          debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + f + ")\bFadeCompleted=#True")
                        EndIf
                      CompilerEndIf
                      grDMXFadeItems\aFadeItem(f)\bFadeCompleted = #True
                    EndIf
                  EndIf
                  If bUsePreHotkeyValues
                    If nDMXPreHotkeyDataIndex >= 0
                      For n = 0 To gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\nMaxPreHotkeyItem
                        If gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXSendDataItemIndex = nItemIndex
                          gaDMXSendData(nItemIndex) = gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)\aPreHotkeyItem(n)\nDMXValue
                          gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
                          debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
                          Break
                        EndIf
                      Next n
                    EndIf
                    ; End changed 16Dec2020 11.8.3.4ab
                    ; Added 21Dec2019 11.8.2.1ao following email from Peter Holmes about DMX master fader setting non-zero DMX values for a note hotkey DMX channel where the note hotkey was no longer pressed.
                    ; This was because \nDMXChannelValue had not been reset on releasing the note key, even though the fixture itself was blacked out.
                    \nDMXChannelValue = gaDMXSendData(nItemIndex)
                    ; End added 21Dec2019 11.8.2.1ao
                  Else
                    If (grDMXMasterFader\nDMXMasterFaderValue = 100) Or (\bDMXChannelDimmable = #False)
                      gaDMXSendData(nItemIndex) = \nDMXChannelValue
                    Else
                      gaDMXSendData(nItemIndex) = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
                    EndIf
                    gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
                  EndIf
                EndIf
                bDMXValueChange = #True
                CompilerIf (#cTraceDMXPrepareForSend) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                  If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35) Or (#cTraceDMXSendChannelsNonZero And gaDMXSendData(nItemIndex) > 0)
                    debugMsg(sProcName, "nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
                  EndIf
                CompilerEndIf
              EndWith
            Next nDMXChannel
          Next nDelayIndex
        EndIf ; EndIf gaDMXControl(nDMXControlPtr)\nDMXDevType = #SCS_DEVTYPE_LT_DMX_OUT
        
        CompilerIf #cTraceDMXPrepareForSend
          debugMsg(sProcName, "calling DMX_setMaxFadeItem()")
          DMX_setMaxFadeItem()
          debugMsg(sProcName, "grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem)
        CompilerElse
          DMX_setMaxFadeItem()
        CompilerEndIf
        
        If bDMXValueChange
          grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
          CompilerIf #cTraceDMXPrepareForSend
            debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
          CompilerEndIf
        EndIf
        
        If bMutexAlreadyLocked = #False
          UnlockDMXSendMutex()
          If bDMXValueChange
            If gbInCalcCueStartValues = #False
              If THR_getThreadState(#SCS_THREAD_DMX_SEND) <> #SCS_THREAD_STATE_ACTIVE
                THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)
              EndIf
            EndIf
          EndIf
        EndIf
        
        CompilerIf #cTraceDMXPrepareForSend
          debugMsg(sProcName, "calling DMX_listDMXFadeItemsArray()")
          DMX_listDMXFadeItemsArray()
        CompilerEndIf
        
        CompilerIf #cTraceDMXPrepareForSend
          ; debugMsg0(sProcName, "(z) gaDMXSendData(18)=" + gaDMXSendData(18))
          debugMsg(sProcName, #SCS_END + ", returning bDMXValueChange=" + strB(bDMXValueChange))
        CompilerEndIf
        
      EndIf ; EndIf nDMXControlPtr >= 0 (near top of procedure)
    EndIf ; EndIf aSub(pSubPtr)\bSubTypeK (near top of procedure)
  EndIf ; EndIf pSubPtr >= 0 (near top of procedure)
  
  ProcedureReturn bDMXValueChange
  
EndProcedure

Procedure DMX_prepareChaseStepForSend()
  PROCNAMEC()
  ; This procedure is called from DMX_prepareDMXForSend() and from DMX_processDMXSendThread().
  Protected n
  Protected nStep, nDMXSendDataBaseIndex, nItemIndex, nDMXControlPtr
  Protected rDMXChaseItem.tyDMXChaseItem
  Protected nRandomStep
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grDMXChaseItems
    nDMXControlPtr = \nDMXControlPtr
    If \bStopChase
      nStep = -1
      debugMsg(sProcName, "grDMXChaseItems\bStopChase=" + strB(\bStopChase) + ", nStep=" + nStep)
    Else
      If \nChaseMode = #SCS_DMX_CHASE_MODE_BOUNCE
        If (\bBouncingBack = #False) And (\nLastStepProcessed >= \nChaseSteps)
          \bBouncingBack = #True
        ElseIf (\bBouncingBack) And (\nLastStepProcessed <= 1)
          \bBouncingBack = #False
        EndIf
      EndIf
      If (\nChaseMode = #SCS_DMX_CHASE_MODE_FORWARD) Or ((\nChaseMode = #SCS_DMX_CHASE_MODE_BOUNCE) And (\bBouncingBack = #False))
        If \nLastStepProcessed >= \nChaseSteps
          nStep = 1
        Else
          nStep = \nLastStepProcessed + 1
        EndIf
        
      ElseIf (\nChaseMode = #SCS_DMX_CHASE_MODE_REVERSE) Or ((\nChaseMode = #SCS_DMX_CHASE_MODE_BOUNCE) And (\bBouncingBack))
        If \nLastStepProcessed <= 1
          nStep = \nChaseSteps
        Else
          nStep = \nLastStepProcessed - 1
        EndIf
        
      ElseIf (\nChaseMode = #SCS_DMX_CHASE_MODE_RANDOM)
        ; calculate a new random step that's anything other than \nLastStepProcessed
        nRandomStep = Random(\nChaseSteps-1, 1)
        If nRandomStep < \nLastStepProcessed
          nStep = nRandomStep
        Else
          nStep = nRandomStep + 1
        EndIf
      EndIf
      
    EndIf
  EndWith
  
  CompilerIf #cTraceDMXPrepareForSend
    debugMsg(sProcName, "nStep=" + nStep + ", grDMXChaseItems\nMaxChaseItem=" + grDMXChaseItems\nMaxChaseItem)
  CompilerEndIf
  
  If nStep > 0
    For n = 0 To grDMXChaseItems\nMaxChaseItem
      If grDMXChaseItems\aDMXChaseItem(n)\nStep = nStep
        rDMXChaseItem = grDMXChaseItems\aDMXChaseItem(n)
        nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
        nItemIndex = nDMXSendDataBaseIndex + rDMXChaseItem\nDMXChannel
        If grDMXMasterFader\nDMXMasterFaderValue = 100
          gaDMXSendData(nItemIndex) = rDMXChaseItem\nDMXValue
        Else
          gaDMXSendData(nItemIndex) = rDMXChaseItem\nDMXValue * grDMXMasterFader\nDMXMasterFaderValue / 100
        EndIf
        gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
        CompilerIf #cTraceDMXPrepareForSend
          debugMsg(sProcName, "rDMXChaseItem\nDMXChannel=" + rDMXChaseItem\nDMXChannel + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
        CompilerEndIf
      EndIf
    Next n
  ElseIf 1=2 ; Added "If 1=2" 12Oct2021 11.8.6ba to bypass the following code so that when a chase is stopped the lights are not blacked out but remain on the last setting (until changed by another lighting cue)
    For n = 0 To grDMXChaseItems\nMaxChaseItem
      rDMXChaseItem = grDMXChaseItems\aDMXChaseItem(n)
      nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
      nItemIndex = nDMXSendDataBaseIndex + rDMXChaseItem\nDMXChannel
      CompilerIf #cTraceDMXPrepareForSend
        debugMsg(sProcName, "nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", rDMXChaseItem\nDMXChannel=" + rDMXChaseItem\nDMXChannel + ", nItemIndex=" + nItemIndex +
                            ", gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
      CompilerEndIf
      If gbDMXDimmableChannel(nItemIndex)
        gaDMXSendData(nItemIndex) = 0
        gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
        CompilerIf #cTraceDMXSendChannels1to34
          If nItemIndex < 35
            debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
          EndIf
        CompilerEndIf
        ; debugMsg(sProcName, "rDMXChaseItem\nDMXChannel=" + rDMXChaseItem\nDMXChannel + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
        With grDMXChannelItems\aDMXChannelItem(nItemIndex)
          \nDMXChannelValue = 0
          \bDMXChannelSet = #True
          CompilerIf #cTraceDMXChannelSet
            debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
          CompilerEndIf
        EndWith
      EndIf
    Next n
  EndIf
  grDMXChaseItems\nLastStepProcessed = nStep
  If nStep = -1
    grDMXChaseItems\bChaseRunning = #False
    ; debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(grDMXChaseItems\bChaseRunning))
  Else
    ; Added 12Oct2021 11.8.6ba (see comments earler in the procedure)
    grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
    ; debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
    ; End added 12Oct2021 11.8.6ba
  EndIf
  ; Deleted 12Oct2021 11.8.6ba (see comments earler in the procedure)
  ; grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
  ; debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
  ; End deleted 12Oct2021 11.8.6ba
  
  CompilerIf #cTraceDMXPrepareForSend
    debugMsg(sProcName, #SCS_END + ", returning nStep=" + nStep)
  CompilerEndIf
  ProcedureReturn nStep
  
EndProcedure

Procedure DMX_populateSendDataArrayFromFadeItemsArray()
  PROCNAMEC()
  ; This procedure is called only from DMX_processDMXSendThread().
  ; It populates DMX channel values in the array gaDMXSendData() using information obtained primarily from the array grDMXFadeItems\aFadeItem().
  Protected bFadesCompleted = #True
  Protected bValuesChanged
  Protected nFadeResult = 1
  Protected n, nDMXAdjustedValue, nDMXControlPtr
  Protected qTimeNow.q, nTimeElapsed
  Protected rFadeItem.tyDMXFadeItem
  Protected nSubTotalTimeOnPause
  Protected nDMXSendDataBaseIndex, nItemIndex
  
  CompilerIf #cTraceDMXFadeItemValues And 1=2
    debugMsg(sProcName, #SCS_START + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem)
  CompilerEndIf
  
  qTimeNow = ElapsedMilliseconds()
  
  For n = 0 To grDMXFadeItems\nMaxFadeItem
    rFadeItem = grDMXFadeItems\aFadeItem(n)
    With rFadeItem
      If aSub(\nSubPtr)\nDMXControlPtr < 0
        DMX_setDMXControlPtrForSub(\nSubPtr)
      EndIf
      nDMXControlPtr = aSub(\nSubPtr)\nDMXControlPtr
      If \bFadeCompleted = #False
        If \nDMXChannel > 0
          nSubTotalTimeOnPause = 0
          If \nSubPtr >= 0
            If aSub(\nSubPtr)\nSubState = #SCS_CUE_PAUSED
              bFadesCompleted = #False
              Continue
            EndIf
            nSubTotalTimeOnPause = aSub(\nSubPtr)\nSubTotalTimeOnPause
            ; debugMsg(sProcName, "aSub(" + getSubLabel(\nSubPtr) + ")\nSubTotalTimeOnPause=" + nSubTotalTimeOnPause)
          EndIf
          ; Note: \qStartTime will be set to the time the lighting sub-cue started OR to the scheduled start time if DMX Capture has recorded a delay time.
          ; So if the (scheduled) start time is greater than the time now, then this entry must be the latter scenario and be waiting for the start time to occur.
          ; If so, we 'continue' the loop and process the next entry in the array grDMXFadeItems\aFadeItem().
          If (\qStartTime + nSubTotalTimeOnPause) > qTimeNow
            bFadesCompleted = #False
            Continue
          EndIf
          
          If \nFadeTime = 0
            ; No fade specified, so just set the DMX value at the 'target' value.
            nDMXAdjustedValue = \nTargetValue
          Else
            ; A fade time has been specified, so calculate the DMX value based on how far through the fade we are.
            nTimeElapsed = qTimeNow - (\qStartTime + nSubTotalTimeOnPause)
            If nTimeElapsed < 0
              nTimeElapsed = 0
            ElseIf nTimeElapsed > \nFadeTime
              nTimeElapsed = \nFadeTime
            EndIf
            nDMXAdjustedValue = Round(\nStartValue + ((\nTargetValue - \nStartValue) * nTimeElapsed / \nFadeTime), #PB_Round_Nearest)
            If nDMXAdjustedValue < 0
              nDMXAdjustedValue = 0
            ElseIf nDMXAdjustedValue > 255
              nDMXAdjustedValue = 255
            EndIf
          EndIf
          
          nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
          nItemIndex = nDMXSendDataBaseIndex + \nDMXChannel
          ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", \nDMXChannel=" + \nDMXChannel + ", nItemIndex=" + nItemIndex +
          ;                     ", ArraySize(gaDMXSendData())=" + ArraySize(gaDMXSendData()) + ", n=" + n + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem)
          If nDMXAdjustedValue <> gaDMXSendData(nItemIndex)
            gaDMXSendData(nItemIndex) = nDMXAdjustedValue
            gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
            CompilerIf #cTraceDMXFadeItemValues
              CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
                If (#cTraceDMXSendChannels1to12 And \nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And \nDMXChannel < 35)
                  debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", \nDMXChannel=" + \nDMXChannel)
                EndIf
              CompilerEndIf
            CompilerEndIf
            bValuesChanged = #True
          EndIf
          If nTimeElapsed >= \nFadeTime
            CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
              If (#cTraceDMXSendChannels1to12 And \nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And \nDMXChannel < 35)
                debugMsg(sProcName, "port " + \nDMXPort + ", channel " + \nDMXChannel + " fade completed, \nStartValue=" + \nStartValue + ", \nTargetValue=" + \nTargetValue +
                                    ", \nFadeTime=" + \nFadeTime + ", nTimeElapsed=" + nTimeElapsed + ", nDMXAdjustedValue=" + nDMXAdjustedValue)
              EndIf
            CompilerEndIf
            CompilerIf #cTraceDMXFadeItemValues
              If grDMXFadeItems\aFadeItem(n)\bFadeCompleted = #False
                debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + n + ")\bFadeCompleted=#True")
              EndIf
            CompilerEndIf
            grDMXFadeItems\aFadeItem(n)\bFadeCompleted = #True
          Else
            bFadesCompleted = #False
          EndIf
          CompilerIf #cTraceDMXFadeItemValues
            CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
              If (#cTraceDMXSendChannels1to12 And \nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And \nDMXChannel < 35)
                debugMsg(sProcName, "\nDMXPort=" + \nDMXPort + ", \nDMXChannel=" + \nDMXChannel + ", \nStartValue=" + \nStartValue + ", \nTargetValue=" + \nTargetValue + ", nTimeElapsed=" + nTimeElapsed +
                                    ", \nFadeTime=" + \nFadeTime + ", nDMXAdjustedValue=" + nDMXAdjustedValue +
                                    ", bValuesChanged=" + strB(bValuesChanged) + ", bFadesCompleted=" + strB(bFadesCompleted) + ", \nSubPtr=" + getSubLabel(\nSubPtr))
              EndIf
            CompilerEndIf
          CompilerEndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  ; If bValuesChanged Or 1=1
  ;   nFadeResult | 1
  ; EndIf
  If bFadesCompleted
    nFadeResult | 2
  EndIf
  
  ; debugMsg(sProcName, #SCS_END + ", returning " + nFadeResult)
  ProcedureReturn nFadeResult
EndProcedure

Procedure DMX_processDMXSendThread(bDMXRefreshOnly)
  PROCNAMEC()
  ; This procedure is called each iteration of a loop within from THR_runDMXSendThread().
  ; The procedure (DMX_processDMXSendThread()) cycles through the entries in the array gaDMXControl(), which will contain one entry per assigned DMX Port,
  ; and will send DMX data to each port via either FT_Write() or DMX_FTDI_SendData(), depending on the type of DMX interface.
  ; -------------------------------------------------------------------
  ; The DMX channel values are obtained from the array gaDMXSendData().
  ; -------------------------------------------------------------------
  ; The main procedure that initially populates gaDMXSendData() is DMX_prepareDMXForSend(),
  ; but DMX_processDMXSendThread() itself may directly call DMX_prepareChaseStepForSend() and DMX_populateSendDataArrayFromFadeItemsArray().
  ; Note that this procedure (DMX_processDMXSendThread()) contains many calls to debugMsg(), but these are under CompilerIf #cTrace... conditions.
  ; If these were all removed, the procedure would be MUCH shorter!
  Protected nFTDIResult
  Protected nFadeResult
  Protected bSendData = #True
  Protected bStopSending = #True
  Protected nStartCode.a = 0
  Protected nBytesWritten.l
  Protected ftStatus.l, nFTHandle.i, sFTHandle.s
  Protected nDMXControlPtr
  Protected nDMXSendDataBaseIndex
  Protected nLabel.a, sLabel.s
  Protected bLockedMutex
  Protected n
  Protected nResult
  Protected qTimeNow.q
  Protected bSendChaseStep, nTimeBetweenSteps
  CompilerIf ((#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero Or #cTraceFTCalls)) Or (#cTraceDMX)
    Protected sMsg.s
    Static sPrevMsg.s, qPrevTime.q
    Protected n2
  CompilerEndIf
  
  CompilerIf (#cTraceDMXSendThread) ; And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero Or #cTraceFTCalls)
    debugMsg(sProcName, #SCS_START + ", bDMXRefreshOnly=" + strB(bDMXRefreshOnly))
  CompilerEndIf
  
  LockDMXSendMutex(602)
  ; debugMsg(sProcName, "#SCS_MUTEX_DMX_SEND locked")
  
  With grDMXChaseItems
;   CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero Or #cTraceFTCalls)
;       If \bChaseRunning
;         debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(\bChaseRunning))
;       EndIf
;     CompilerEndIf
    If \bChaseRunning
      If gbClosingDown = #False
        qTimeNow = ElapsedMilliseconds()
        If \nChaseControl = #SCS_DMX_CHASE_CTL_TAP
          nTimeBetweenSteps = \nTapTimeBetweenSteps
          If ((qTimeNow - \qLastItemTime) >= nTimeBetweenSteps)
            ; debugMsg(sProcName, "qTimeNow=" + qTimeNow + ", \qLastItemTime=" + \qLastItemTime + ", (qTimeNow - \qLastItemTime)=" + Str(qTimeNow - \qLastItemTime) + ", nTimeBetweenSteps=" + nTimeBetweenSteps + ", calling DMX_prepareChaseStepForSend()")
            If DMX_prepareChaseStepForSend() >= 0 ; Added If test 12Oct2021 11.8.6ba
              \qLastItemTime + nTimeBetweenSteps
              bSendChaseStep = #True
              bStopSending = #False
              \bDisplayChaseIndicator = #True
              \qTimeDisplayChaseIndicatorSet = qTimeNow
            EndIf
          EndIf
        Else
          If qTimeNow >= \qNextTtemTime
            nTimeBetweenSteps = \nCueTimeBetweenSteps
            If DMX_prepareChaseStepForSend() >= 0 ; Added If test 12Oct2021 11.8.6ba
              \qLastItemTime + nTimeBetweenSteps
              bSendChaseStep = #True
              bStopSending = #False
              \bDisplayChaseIndicator = #True
              \qTimeDisplayChaseIndicatorSet = qTimeNow
              \nItemsProcessed + 1
              \qNextTtemTime = \qChaseStartTime + (nTimeBetweenSteps * \nItemsProcessed)
              ; debugMsg0(sProcName, "\nItemsProcessed=" + \nItemsProcessed + ", \qNextTtemTime=" + traceTime(\qNextTtemTime))
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
  EndWith
  
  If bSendChaseStep = #False
    If bDMXRefreshOnly
      bStopSending = #False
      
    ElseIf grDMXFadeItems\nMaxFadeItem >= 0
      nFadeResult = DMX_populateSendDataArrayFromFadeItemsArray()
      CompilerIf #cTraceDMXSendThread
        debugMsg(sProcName, "DMX_populateSendDataArrayFromFadeItemsArray() returned nFadeResult=" + nFadeResult)
      CompilerEndIf
      If (nFadeResult & 1) = 0
        ; no values changed
        If bDMXRefreshOnly = #False ; nb do NOT clear bSendData if we are processing a DMX refresh
          bSendData = #False
        EndIf
      EndIf
      If (nFadeResult & 2) = 0
        ; not reached the end of the fades
        bStopSending = #False
      EndIf
    EndIf
  EndIf ; EndIf bSendChaseStep = #False

  If bSendData
    grDMX\bBlackOutOnCloseDown = #True
    For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
      CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero Or #cTraceFTCalls)
        sMsg = ""
      CompilerEndIf
      With gaDMXControl(nDMXControlPtr)
        CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero Or #cTraceFTCalls)
          debugMsg(sProcName, "-- gaDMXControl(" + nDMXControlPtr + ")\nFTHandle=" + decodeHandle(\nFTHandle) + ", \bDMXDummyPort=" + strB(\bDMXDummyPort) + ", \nDMXDevType=" + decodeDMXDevType(\nDMXDevType))
        CompilerEndIf
        nFTHandle = \nFTHandle
        sFTHandle = decodeHandle(nFTHandle)
        If \bDMXDummyPort
          CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12)
            For n = 1 To 12
              sMsg + ", " + gaDMXSendData(n)
            Next n
            debugMsg(sProcName, "DMX Dummy Port" + sMsg)
          CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
            For n = 1 To 34
              sMsg + ", " + gaDMXSendData(n)
            Next n
            debugMsg(sProcName, "DMX Dummy Port" + sMsg)
          CompilerEndIf
          If grWDD\bDMXDisplayActive
            If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
              ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
              grDMX\bCallDisplayDMXSendData = #True
            EndIf
          EndIf
          ; Added 13Jul2022 11.9.4
          If WCN\nDimmerChanCtrls > 0
            WCN\bRefreshDimmerChannelFaders = #True
          EndIf
          ; End added 13Jul2022 11.9.4
        ; ElseIf nFTHandle
        Else
          Select \nDMXDevType
            Case #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB, #SCS_DMX_DEV_FTDI_USB_RS485
              ; nDMXSendDataBaseIndex = \nDMXSendDataBaseIndex
              ; If nDMXSendDataBaseIndex >= 0
              nDMXSendDataBaseIndex = 1 ; replaced the above 10Dec2020 11.8.3.3au following bug report from Daniel Wieschnewski - only affects Open_DMX_USB, not DMX_USB_PRO etc
              FT_SetBreakOn(nFTHandle)
              FT_SetBreakOff(nFTHandle)
              ; write the start code
              ftStatus = FT_Write(nFTHandle, @nStartCode, 1, @nBytesWritten)
              If ftStatus <> #FT_OK
                debugMsg(sProcName, "FT_Write(" + sFTHandle + ", @nStartCode, 1, @nBytesWritten) returned " + decodeFTStatus(ftStatus) + ", nBytesWritten=" + nBytesWritten)
              Else
                CompilerIf #cTraceDMX Or #cTraceFTCalls
                  If bDMXRefreshOnly = #False Or #cTraceFTCalls
                    debugMsg(sProcName, "FT_Write(" + sFTHandle + ", @nStartCode, 1, @nBytesWritten) returned " + decodeFTStatus(ftStatus) + ", nBytesWritten=" + nBytesWritten)
                  EndIf
                CompilerEndIf
              EndIf
              ; write the data
              ftStatus = FT_Write(nFTHandle, @gaDMXSendData(nDMXSendDataBaseIndex), grLicInfo\nMaxDMXChannel, @nBytesWritten)
              If ftStatus <> #FT_OK
                debugMsg(sProcName, "FT_Write(" + sFTHandle + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + grLicInfo\nMaxDMXChannel + ", @nBytesWritten) returned " + decodeFTStatus(ftStatus) + ", nBytesWritten=" + nBytesWritten)
              Else
                CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12 Or #cTraceFTCalls)
                  If bDMXRefreshOnly = #False Or #cTraceFTCalls
                    For n = 1 To 12
                      sMsg + ", " + gaDMXSendData(n)
                    Next n
                    debugMsg(sProcName, "FT_Write(" + sFTHandle + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + grLicInfo\nMaxDMXChannel + ", @nBytesWritten)" + sMsg + ", returned " + decodeFTStatus(ftStatus) + ", nBytesWritten=" + nBytesWritten)
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
                  If bDMXRefreshOnly = #False
                    For n = 1 To 34
                      sMsg + ", " + gaDMXSendData(n)
                    Next n
                    debugMsg(sProcName, "FT_Write(" + sFTHandle + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + grLicInfo\nMaxDMXChannel + ", @nBytesWritten)" + sMsg + ", returned " + decodeFTStatus(ftStatus) + ", nBytesWritten=" + nBytesWritten)
                  EndIf
                CompilerEndIf
              EndIf
              If grWDD\bDMXDisplayActive
                If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
                  If bDMXRefreshOnly = #False ; nb no need to update display if we are just refreshing the DMX data
                    ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
                    grDMX\bCallDisplayDMXSendData = #True
                  EndIf
                EndIf
              EndIf
              ; Added 13Jul2022 11.9.4
              If WCN\nDimmerChanCtrls > 0
                WCN\bRefreshDimmerChannelFaders = #True
              EndIf
              ; End added 13Jul2022 11.9.4
              ; EndIf
              
            Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO
              ; nb no need to check bDMXRefreshOnly for USB PRO as refreshing DMX from SCS is not required so bDMXRefreshOnly will always be #False
              CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                sMsg = ""
              CompilerEndIf
              nLabel = #ENTTEC_SEND_DMX_PORT1
              sLabel = decodeDMXAPILabel(nLabel)
              nDMXSendDataBaseIndex = \nDMXSendDataBaseIndex
              If nDMXSendDataBaseIndex >= 0
                gaDMXSendData(nDMXSendDataBaseIndex) = 0  ; start code = 0
                nFTDIResult = DMX_FTDI_SendData(nFTHandle, nLabel, @gaDMXSendData(nDMXSendDataBaseIndex), grLicInfo\nMaxDMXChannel+1)  ; +1 to include the start code
                CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannelsNonZero)
                  For n = 1 To grLicInfo\nMaxDMXChannel
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(pro) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12)
                  For n = 1 To 12
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(pro) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
                  For n = 1 To 34
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(pro) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerEndIf
                If grWDD\bDMXDisplayActive
                  If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
                    ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
                    grDMX\bCallDisplayDMXSendData = #True
                  EndIf
                EndIf
                ; Added 13Jul2022 11.9.4
                If WCN\nDimmerChanCtrls > 0
                  WCN\bRefreshDimmerChannelFaders = #True
                EndIf
                ; End added 13Jul2022 11.9.4
              EndIf
              
            Case #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2
              ; nb no need to check bDMXRefreshOnly for USB PRO MK2 as refreshing DMX from SCS is not required so bDMXRefreshOnly will always be #False
              CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                sMsg = ""
              CompilerEndIf
              Select \nDMXPort
                Case 1
                  nLabel = #ENTTEC_SEND_DMX_PORT1
                Case 2
                  nLabel = #ENTTEC_SEND_DMX_PORT2
              EndSelect
              sLabel = decodeDMXAPILabel(nLabel)
              nDMXSendDataBaseIndex = \nDMXSendDataBaseIndex
              If nDMXSendDataBaseIndex >= 0
                gaDMXSendData(nDMXSendDataBaseIndex) = 0  ; start code = 0
                nFTDIResult = DMX_FTDI_SendData(nFTHandle, nLabel, @gaDMXSendData(nDMXSendDataBaseIndex), grLicInfo\nMaxDMXChannel+1)  ; +1 to include the start code
                CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannelsNonZero)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To grLicInfo\nMaxDMXChannel
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(mk2) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 12
                    n2 = nDMXSendDataBaseIndex + n
                    ; debugMsg(sProcName, "n=" + n + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", n2=" + n2 + ", ArraySize(gaDMXSendData())=" + ArraySize(gaDMXSendData()))
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(mk2) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 34
                    n2 = nDMXSendDataBaseIndex + n
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg2(sProcName, "(mk2) DMX_FTDI_SendData(" + sFTHandle + ", " + sLabel + ", @gaDMXSendData(" + nDMXSendDataBaseIndex + "), " + Str(grLicInfo\nMaxDMXChannel+1) + ") time=" + Str(qTimeNow - qPrevTime) + sMsg, nFTDIResult)
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerEndIf
                If grWDD\bDMXDisplayActive
                  If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
                    ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
                    grDMX\bCallDisplayDMXSendData = #True
                  EndIf
                EndIf
                ; Added 13Jul2022 11.9.4
                If WCN\nDimmerChanCtrls > 0
                  WCN\bRefreshDimmerChannelFaders = #True
                EndIf
                ; End added 13Jul2022 11.9.4
              EndIf
              
            Case #SCS_DMX_DEV_ARTNET
              CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                sMsg = ""
              CompilerEndIf
              
              nDMXSendDataBaseIndex = \nDMXSendDataBaseIndex
              If nDMXSendDataBaseIndex >= 0
                ;gaDMXSendData(nDMXSendDataBaseIndex) = 0           ; start code = 0
                artnet_addDmxDataToQueue(@gaDMXSendData(nDMXSendDataBaseIndex), \nDMXPort - 1, 512)
                
                CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannelsNonZero)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To grLicInfo\nMaxDMXChannel
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "Atrnet send universe: " +  \nDMXPort + "time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 12
                    n2 = nDMXSendDataBaseIndex + n
                    ; debugMsg(sProcName, "n=" + n + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", n2=" + n2 + ", ArraySize(gaDMXSendData())=" + ArraySize(gaDMXSendData()))
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "Atrnet send universe: " +  \nDMXPort + "time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 34
                    n2 = nDMXSendDataBaseIndex + n
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "Atrnet send universe: " +  \nDMXPort + "time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerEndIf
                If grWDD\bDMXDisplayActive
                  If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
                    ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
                    grDMX\bCallDisplayDMXSendData = #True
                  EndIf
                EndIf
                ; Added 13Jul2022 11.9.4
                If WCN\nDimmerChanCtrls > 0
                  WCN\bRefreshDimmerChannelFaders = #True
                EndIf
                ; End added 13Jul2022 11.9.4
              EndIf
              
            Case #SCS_DMX_DEV_SACN
              CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34 Or #cTraceDMXSendChannelsNonZero)
                sMsg = ""
              CompilerEndIf
              
              nDMXSendDataBaseIndex = \nDMXSendDataBaseIndex
              If nDMXSendDataBaseIndex >= 0
                *gp_sACNBuffer = sACNDmxTxBuffer(\nDMXPort)                 
                
                If *gp_sACNBuffer <> 0
                  CopyMemory(@gaDMXSendData(nDMXSendDataBaseIndex) + 1, *gp_sACNBuffer, 512)
                  nResult = sACNSendDmxData(\nDMXPort)
                  debugMsg(sProcName, "sacnSend=" + nResult)
                EndIf
              
                CompilerIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannelsNonZero)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To grLicInfo\nMaxDMXChannel
                    n2 = nDMXSendDataBaseIndex + n
                    If gaDMXSendData(n2) > 0
                      sMsg + ", " + n2 + "=" + gaDMXSendData(n2)
                    EndIf
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "sACN send universe: " +  \nDMXPort + " Result: " + nResult + " Time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMX Or #cTraceDMXSendChannels1to12)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 12
                    n2 = nDMXSendDataBaseIndex + n
                    ; debugMsg(sProcName, "n=" + n + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", n2=" + n2 + ", ArraySize(gaDMXSendData())=" + ArraySize(gaDMXSendData()))
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "sACN send universe: " +  \nDMXPort + "time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerElseIf (#cTraceDMXSendThread) And (#cTraceDMXSendChannels1to34)
                  sMsg + " (nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ")"
                  For n = 1 To 34
                    n2 = nDMXSendDataBaseIndex + n
                    sMsg + ", " + gaDMXSendData(n2)
                  Next n
                  If sMsg <> sPrevMsg
                    qTimeNow = ElapsedMilliseconds()
                    debugMsg(sProcName, "sACN send universe: " +  \nDMXPort + "time=" + Str(qTimeNow - qPrevTime))
                    sPrevMsg = sMsg
                    qPrevTime = qTimeNow
                  EndIf
                CompilerEndIf
                If grWDD\bDMXDisplayActive
                  If grWDD\nDMXDisplayControlPtr = nDMXControlPtr
                    ; DMX_displayDMXSendData() ; Replaced by the following, 24Jun2021 11.8.5an
                    grDMX\bCallDisplayDMXSendData = #True
                  EndIf
                EndIf
                ; Added 13Jul2022 11.9.4
                If WCN\nDimmerChanCtrls > 0
                  WCN\bRefreshDimmerChannelFaders = #True
                EndIf
                ; End added 13Jul2022 11.9.4
              EndIf

          EndSelect
        EndIf
      EndWith
    Next nDMXControlPtr
    
  EndIf
  
  If bStopSending
    If (bSendChaseStep = #False) And (bSendData)
      CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX)
        debugMsg(sProcName, "bStopSending=" + strB(bStopSending) + ", bSendChaseStep=" + strB(bSendChaseStep) + ", bSendData=" + strB(bSendData))
        debugMsg(sProcName, "calling DMX_setMaxFadeItem()")
      CompilerEndIf
      DMX_setMaxFadeItem()
    EndIf
    If grDMXChaseItems\bChaseRunning = #False
      grDMX\bDMXReadyToSend = #False ; must be cleared (or set) while gnDMXSendMutex is locked
      CompilerIf (#cTraceDMXSendThread) And (#cTraceDMX)
        debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
      CompilerEndIf
    EndIf
  EndIf
  
  UnlockDMXSendMutex()
  
  CompilerIf #cTraceDMXSendThread
    debugMsg(sProcName, #SCS_END)
  CompilerEndIf
  
EndProcedure

Procedure DMX_processDMXReceiveThread()
  PROCNAMEC()  
  ; NB The DMX Receive Thread was created 18Jul2023 11.10.0bq, primarily to improve the performance of DMX Capture Sequence requests
  ; when creating/editing a Lighting Cue. This is under the control of grDMX\bCaptureDMX.
  ; However, the DMX Receive Thread is also now used for DMX Cue Control, under the control of grDMX\bReceiveDMX.
  
  ; NOTE: As from SCS 11.10.2au this is NO LONGER PROCESSED IN A SEPARATE THREAD due to some thread conflict that was causing issues.
  ; NOTE: Those issues have not been resolved and the simplest solution was to return this procesing to the main thread, which is where it was prior to SCS 11.10.0.
  
  Protected qTimeNow.q, qTimeDiff.q
  Static nMinTimeDiff = 80
  
  CompilerIf #cTraceDMXReceiveThread And 1=2
    debugMsg(sProcName, #SCS_START)
  CompilerEndIf
  
  If grDMX\bCaptureDMX
    ; Processing DMX Capture for Lighting Cues
    ; debugMsg(sProcName, "calling DMX_requestData(" + grDMX\nDMXCaptureControlPtr + ")")
    DMX_requestData(grDMX\nDMXCaptureControlPtr)
  EndIf
  
  If grDMX\bReceiveDMX
    ; Processing DMX Cue Control
    qTimeNow = ElapsedMilliseconds()
    qTimeDiff = qTimeNow - grDMX\qTimeLastDMXReceiveRequested
    ; debugMsg0(sProcName, "qTimeDiff=" + qTimeDiff + ", nMinTimeDiff=" + nMinTimeDiff)
    If qTimeDiff >= nMinTimeDiff Or grDMX\bRequestNextImmediately
      DMX_requestData(grDMX\nDMXCueControlPtr)
      grDMX\qTimeLastDMXReceiveRequested = qTimeNow
    EndIf
  EndIf
  
  CompilerIf #cTraceDMXReceiveThread And 1=2
    debugMsg(sProcName, #SCS_END)
  CompilerEndIf
  
EndProcedure

Procedure DMX_convertDMXValueStringToDMXValue(sDMXValueString.s)
  Protected sValue.s, nDMXValue
  
  If sDMXValueString
    sValue = LCase(Trim(sDMXValueString))
    If Left(sValue, 1) = "d"
      ; absolute DMX value (0-255)
      If Left(sValue, 3) = "dmx"
        sValue = Mid(sValue, 4)
      Else
        sValue = Mid(sValue, 2)
      EndIf
      nDMXValue = Val(sValue)
    Else
      ; percentage (0-100) so convert to absolute DMX value
      nDMXValue = Val(sValue) * 2.55
    EndIf
  EndIf      
  
  ProcedureReturn nDMXValue
EndProcedure

Procedure DMX_validateAndConvertDMXDisplayValue(sDMXDisplayValue.s)
  PROCNAMEC()
  ; checks that sDMXDisplayValue is valid and places results in grDMXValueInfo
  ; see Structure tyDMXValueInfo for details and explanations
  Protected sValue.s, nValue
  Protected rDMXValueInfoDef.tyDMXValueInfo
  
  grDMXValueInfo = rDMXValueInfoDef ; clear all fields in grDMXValueInfo before starting
  
  With grDMXValueInfo
    \sDMXDisplayValue = Trim(sDMXDisplayValue)
    sValue = LCase(\sDMXDisplayValue)
    If Left(sValue, 1) = "d"
      ; absolute DMX value (0-255)
      If Left(sValue, 3) = "dmx"
        sValue = Mid(sValue, 4)
      Else
        sValue = Mid(sValue, 2)
      EndIf
      If IsNumeric(sValue) = #False
        \nErrorCode = 1 ; invalid format
      Else
        nValue = Val(sValue)
        If (nValue < 0) Or (nValue > 255)
          \nErrorCode = 2 ; value out of range
        Else
          \nDMXDisplayValue = nValue
          \nDMXAbsValue = nValue
          \bDMXAbsValue = #True
        EndIf
      EndIf
    Else
      ; percentage (0-100) so convert to absolute DMX value
      If IsNumeric(sValue) = #False
        \nErrorCode = 1 ; invalid format
      Else
        nValue = Val(sValue)
        If (nValue < 0) Or (nValue > 100)
          \nErrorCode = 2 ; value out of range
        Else
          \nDMXDisplayValue = nValue
          \nDMXAbsValue = nValue * 2.55
          \bDMXAbsValue = #False
        EndIf
      EndIf
    EndIf
  EndWith
  
  If grDMXValueInfo\nErrorCode = 0
    ProcedureReturn #True
  Else
    ProcedureReturn #False
  EndIf
EndProcedure

Procedure DMX_unpackDMXSendItemStr(*rDMXSendItem.tyDMXSendItem, *rProd.tyProd, sLTLogicalDev.s)
  PROCNAMEC()
  Protected sNonComment.s, sFixtureCodes.s
  Protected nFadePtr, fFadeTime.f, fDelayTime.f
  Protected sValue.s, sFadeTime.s, sDelayTime.s
  Protected n, nPartCount, nPart, nProdDevNo, nDashCount, nRightBracketPtr
  Protected sPart.s, sFrom.s, sUpTo.s, sFromSortKey.s, sUpToSortKey.s, sThisSortKey.s, sFixtureCode.s
  
  ; debugMsg(sProcName, #SCS_START + ", *rDMXSendItem\sDMXItemStr=" + *rDMXSendItem\sDMXItemStr + ", sLTLogicalDev=" + sLTLogicalDev)
  
  nProdDevNo = -1
  With *rProd
    For n = 0 To \nMaxLightingLogicalDev
      If \aLightingLogicalDevs(n)\sLogicalDev = sLTLogicalDev
        nProdDevNo = n
        Break
      EndIf
    Next n
  EndWith
  
  With *rDMXSendItem
    ; set initial values, some of which will be changed later in this procedure
    \sDMXChannels = ""
    \nDMXFlags = 0
    \nDMXValue = 0
    \nDMXDisplayValue = 0
    \bDMXAbsValue = #False
    \bDMXFade = #False
    \nDMXFadeTime = -2
    \nDMXDelayTime = 0
    \bDBO = #False
    \nFixtureCount = 0
    \nRelChannelCount = 0
    \sDMXFixturesOnly = ""
    \sDMXRelChannelsOnly = ""
    \nFixtureInd = #SCS_FIXIND_NO_FIXTURE_CODES
    \sComment = Trim(StringField(\sDMXItemStr, 2, "//"))
    sNonComment = RemoveString(StringField(\sDMXItemStr, 1, "//"), " ")
    If sNonComment
      If LCase(Left(sNonComment, 3)) = "dbo"
        \bDBO = #True
        sValue = LCase(StringField(sNonComment, 2, "!"))
      EndIf
      
      If \bDBO = #False
        If Left(sNonComment, 1) = "["
          nRightBracketPtr = FindString(sNonComment, "]")
          If nRightBracketPtr > 1
            sDelayTime = Mid(sNonComment, 2, nRightBracketPtr-2)
            fDelayTime = ValF(sDelayTime)
            \nDMXDelayTime = Int(fDelayTime * 1000)
            ; debugMsg(sProcName, "\nDMXDelayTime=" + \nDMXDelayTime)
            sNonComment = Mid(sNonComment, nRightBracketPtr+1)
          EndIf
        EndIf
        
        \sDMXChannels = UCase(StringField(sNonComment, 1, "@"))
        If FindString(\sDMXChannels, ":") > 0
          \sDMXFixturesOnly = Trim(StringField(\sDMXChannels, 1, ":"))
          If Len(\sDMXFixturesOnly) = 0 ; ie \sDMXChannels STARTS with ":"
            \nFixtureInd = #SCS_FIXIND_SAME_FIXTURE_CODES_AS_PREV_ITEM
          Else
            \nFixtureInd = #SCS_FIXIND_FIXTURE_CODES_PRESENT
          EndIf
          \sDMXRelChannelsOnly = Trim(StringField(\sDMXChannels, 2, ":"))
        EndIf
        sFixtureCodes = \sDMXFixturesOnly
        nPartCount = CountString(sFixtureCodes, ",") + 1
        For nPart = 1 To nPartCount
          sPart = StringField(sFixtureCodes, nPart, ",")
          nDashCount = CountString(sPart, "-")
          Select nDashCount
            Case 0
              sFrom = sPart
              sUpTo = sPart
            Case 1
              sFrom = StringField(sPart, 1, "-")
              sUpTo = StringField(sPart, 2, "-")
          EndSelect
          sFromSortKey = DMX_createFixtureSortKey(nProdDevNo, sFrom)
          sUpToSortKey = DMX_createFixtureSortKey(nProdDevNo, sUpTo)
          ; debugMsg(sProcName, "sPart=" + sPart + ", sFrom=" + sFrom + ", sUpTo=" + sUpTo + ", sFromSortKey=" + sFromSortKey + ", sUpToSortKey=" + sUpToSortKey)
          For n = 0 To *rProd\aLightingLogicalDevs(nProdDevNo)\nMaxFixture
            sFixtureCode = *rProd\aLightingLogicalDevs(nProdDevNo)\aFixture(n)\sFixtureCode
            sThisSortKey = DMX_createFixtureSortKey(nProdDevNo, sFixtureCode)
            If (sThisSortKey >= sFromSortKey) And (sThisSortKey <= sUpToSortKey)
              If \nFixtureCount > ArraySize(\sDMXFixtureCode())
                ReDim \sDMXFixtureCode(\nFixtureCount + 20)
              EndIf
              \sDMXFixtureCode(\nFixtureCount) = sFixtureCode
              ; debugMsg(sProcName, "\sDMXFixtureCode(" + \nFixtureCount + ")=" + \sDMXFixtureCode(\nFixtureCount))
              \nFixtureCount + 1
            EndIf
          Next n
        Next nPart
        
        sValue = LCase(StringField(sNonComment, 2, "@"))
        If Left(sValue, 1) = "d"
          ; absolute DMX value (0-255)
          If Left(sValue, 3) = "dmx"
            \nDMXFlags | #SCS_DMX_CS_DMX
            sValue = Mid(sValue, 4)
          Else
            \nDMXFlags | #SCS_DMX_CS_D
            sValue = Mid(sValue, 2)
          EndIf
          \bDMXAbsValue = #True
          \nDMXDisplayValue = ValD(sValue)
          \nDMXValue = \nDMXDisplayValue
        Else
          \nDMXDisplayValue = ValD(sValue)
          ; percentage (0-100) so convert to absolute DMX value
          \nDMXValue = \nDMXDisplayValue * 2.55
        EndIf
        ; debugMsg0(sProcName, "\sDMXItemStr=" + \sDMXItemStr + ", sValue=" + sValue + ", \bDMXAbsValue=" + strB(\bDMXAbsValue) + ", \nDMXValue=" + \nDMXValue + ", \nDMXDisplayValue=" + \nDMXDisplayValue)
      EndIf
      
      nFadePtr = FindString(sValue, "f")
      If nFadePtr > 0
        sFadeTime = Mid(sValue, nFadePtr)
        If Left(sFadeTime, 4) = "fade"
          \nDMXFlags | #SCS_DMX_CS_FADE
          sFadeTime = Mid(sFadeTime, 5)
        Else
          \nDMXFlags | #SCS_DMX_CS_F
          sFadeTime = Mid(sFadeTime, 2)
        EndIf
        fFadeTime = ValF(sFadeTime)
        \nDMXFadeTime = Int(fFadeTime * 1000)
      EndIf
      
    EndIf
    ; debugMsg(sProcName, "\sDMXItemStr=" + \sDMXItemStr + ", \sDMXRelChannelsOnly=" + \sDMXRelChannelsOnly + ", \bDBO=" + strB(\bDBO))

  EndWith
  
EndProcedure

Procedure DMX_packDMXSendItemStr(*rDMXSendItem.tyDMXSendItem)
  ; PROCNAMEC()
  Protected sDMXItemStr.s, sComment.s, sFadeTime.s, sDelayTime.s
  Protected nDMXFlags
  
  ; debugMsg(sProcName, #SCS_START)
  
  With *rDMXSendItem
    ; debugMsg(sProcName, "\sDMXItemStr=" + \sDMXItemStr + ", \sDMXChannels=" + \sDMXChannels + ", \bDBO=" + strB(\bDBO))
    If \sDMXChannels Or \bDBO
      sComment = StringField(\sDMXItemStr, 2, "//")
      If \bDBO
        sDMXItemStr = "DBO"
        If \nDMXFadeTime >= 0
          sDMXItemStr + "!"
        EndIf
      Else
        sDMXItemStr = DMX_reformatDMXItemStr(\sDMXChannels)
        ; debugMsg(sProcName, "DMX_reformatDMXItemStr(" + \sDMXChannels + ") returned sDMXItemStr=" + sDMXItemStr)
        nDMXFlags = \nDMXFlags
        If nDMXFlags & #SCS_DMX_CS_DMX
          sDMXItemStr + "@dmx" + \nDMXValue
        ElseIf nDMXFlags & #SCS_DMX_CS_D
          sDMXItemStr + "@d" + \nDMXValue
        Else
          sDMXItemStr + "@" + Round(\nDMXValue / 2.55, #PB_Round_Nearest)
        EndIf
      EndIf
      ; debugMsg(sProcName, "sDMXItemStr=" + sDMXItemStr + ", \nDMXFadeTime=" + \nDMXFadeTime)
      If \nDMXFadeTime >= 0
        sFadeTime = StrF(\nDMXFadeTime / 1000, 3)
        If FindString(sFadeTime, gsDecimalMarker)
          ; strip off unnecessary trailing characters, eg 4.50 becomes 4.5, 4.00 becomes 4
          sFadeTime = RTrim(sFadeTime, "0")
          sFadeTime = RTrim(sFadeTime, gsDecimalMarker)
        EndIf
        ; debugMsg(sProcName, "sFadeTime=" + sFadeTime)
        If nDMXFlags & #SCS_DMX_CS_F
          sDMXItemStr + "f" + sFadeTime
        Else
          sDMXItemStr + "fade" + sFadeTime
        EndIf
      EndIf
      ; debugMsg(sProcName, "sDMXItemStr=" + sDMXItemStr)
      \sDMXItemStr = Trim(sDMXItemStr)
      If sComment
        \sDMXItemStr + " //" + sComment
      EndIf
      ; debugMsg(sProcName, "\sDMXItemStr=" + \sDMXItemStr)
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getPreHotkeyDMXValue(pSubPtr, nDMXChannel)
  PROCNAMECS(pSubPtr)
  Protected nDMXValue, nDMXPreHotkeyDataIndex, n
  
  debugMsg(sProcName, #SCS_START + ", nDMXChannel=" + nDMXChannel)
  
  nDMXPreHotkeyDataIndex = aSub(pSubPtr)\nDMXPreHotkeyDataIndex
  If nDMXPreHotkeyDataIndex >= 0
    With gaDMXPreHotkeyData(nDMXPreHotkeyDataIndex)
      For n = 0 To \nMaxPreHotkeyItem
        If \aPreHotkeyItem(n)\nDMXSendDataItemIndex = nDMXChannel
          debugMsg(sProcName, "found at n=" + n)
          nDMXValue = \aPreHotkeyItem(n)\nDMXValue
          Break
        EndIf
      Next n
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning nDMXValue=" + nDMXValue)
  ProcedureReturn nDMXValue
EndProcedure

Procedure DMX_loadDMXChannelItemsFI(pSubPtr, nChaseStepIndex=0, bLiveDMXTest=#False, bBlackoutOthersInLiveTest=#False, nDMXValuePercentage=100, bUsePreHotkeyValues=#False)
  ; Used for entry types 'Fixture Items' and 'Blackout'
  PROCNAMECS(pSubPtr)
  Protected m, n
  Protected nDMXValue, nDMXFadeTime, nLTEntryType, nCurrentDMXValue, nLTMaxCurrChanValue, nMinDMXValue
  Protected nDMXChannel, nDevStartChannelIndex
  Protected bFadeOutOthers, nFadeOutOthersTime, bChannelInChase
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort
  Protected nDMXSendDataBaseIndex, nFixtureOffset, nItemIndex, nProdDevNo
  Protected nFixtureIndex, sFixtureCode.s, nFixtureRunTimeIndex, nTotalChans, nRelChanNo, nChanIndex, nDMXStartChannel
  Protected nFixTypeIndex, nDMXFadeTimeForSub, bChannelDimmable, bApplyFadeTime
  Protected nDMXFadeUpTimeForSub, nDMXFadeDownTimeForSub, nDMXFadeOthersTimeForSub
  
  CompilerIf #cTraceDMXLoadChannelInfo
    debugMsg(sProcName, #SCS_START + ", nChaseStepIndex=" + nChaseStepIndex + ", bLiveDMXTest=" + strB(bLiveDMXTest) + ", bBlackoutOthersInLiveTest=" + strB(bBlackoutOthersInLiveTest) +
                        ", nDMXValuePercentage=" + nDMXValuePercentage + ", bUsePreHotkeyValues=" + strB(bUsePreHotkeyValues) + ")")
  CompilerEndIf
  
  If grFixturesRunTime\bLoaded = #False
    debugMsg(sProcName, "calling DMX_loadFixturesRunTime()")
    DMX_loadFixturesRunTime()
  EndIf
  
  traceDMXChannelItems(#cTraceDMXLoadChannelInfo)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      nLTEntryType = \nLTEntryType
      ; debugMsg0(sProcName, "gbInCalcCueStartValues=" + strB(gbInCalcCueStartValues) + ", nLTEntryType=" + decodeLTEntryType(nLTEntryType))
      If gbInCalcCueStartValues = #False
        nDMXFadeTimeForSub = DMX_getDefFadeTimeForSub(@aSub(pSubPtr), @grProd)
        ; debugMsg0(sProcName, "nDMXFadeTimeForSub=" + nDMXFadeTimeForSub)
        Select nLTEntryType
          Case #SCS_LT_ENTRY_TYPE_BLACKOUT
            nDMXFadeTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_BL_FADE, \nLTBLFadeAction, @aSub(pSubPtr), @grProd)
            CompilerIf #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "\nLTBLFadeAction=" + decodeDMXFadeActionBL(\nLTBLFadeAction) + ", nDMXFadeTimeForSub=" + nDMXFadeTimeForSub)
            CompilerEndIf
            
          Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            nDMXFadeUpTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEUP, \nLTDCFadeUpAction, @aSub(pSubPtr), @grProd)
            nDMXFadeDownTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEDOWN, \nLTDCFadeDownAction, @aSub(pSubPtr), @grProd)
            CompilerIf #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "\nLTDCFadeUpAction=" + decodeDMXFadeActionDC(\nLTDCFadeUpAction) + ", nDMXFadeUpTimeForSub=" + nDMXFadeUpTimeForSub +
                                  ", \nLTDCFadeDownAction=" + decodeDMXFadeActionDC(\nLTDCFadeDownAction) + ", nDMXFadeDownTimeForSub=" + nDMXFadeDownTimeForSub)
            CompilerEndIf
            
          Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
            nDMXFadeUpTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEUP, \nLTFIFadeUpAction, @aSub(pSubPtr), @grProd)
            nDMXFadeDownTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEDOWN, \nLTFIFadeDownAction, @aSub(pSubPtr), @grProd)
            nDMXFadeOthersTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, \nLTFIFadeOutOthersAction, @aSub(pSubPtr), @grProd)
            CompilerIf #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "\nLTFIFadeUpAction=" + decodeDMXFadeActionFI(\nLTFIFadeUpAction) + ", nDMXFadeUpTimeForSub=" + nDMXFadeUpTimeForSub +
                                  ", \nLTFIFadeDownAction=" + decodeDMXFadeActionFI(\nLTFIFadeDownAction) + ", nDMXFadeDownTimeForSub=" + nDMXFadeDownTimeForSub +
                                  ", \nLTFIFadeOutOthersAction=" + decodeDMXFadeActionFI(\nLTFIFadeOutOthersAction) + ", nDMXFadeOthersTimeForSub=" + nDMXFadeOthersTimeForSub)
            CompilerEndIf
        EndSelect
      EndIf ; EndIf gbInCalcCueStartValues = #False
      
      nDMXControlPtr = \nDMXControlPtr
      If nDMXControlPtr >= 0
        nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
        nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
        nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
      EndIf
      CompilerIf #cTraceDMXLoadChannelInfo
        debugMsg(sProcName, "\sLTLogicalDev=" + \sLTLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr + ", nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex)
      CompilerEndIf
      
      If aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
        If nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
          If bLiveDMXTest And bBlackoutOthersInLiveTest
            bFadeOutOthers = #True
            nFadeOutOthersTime = 0 ; 20Jan2021 11.8.4ab modified setting of nFadeOutOthersTime
            ; debugMsg0(sProcName, "bFadeOutOthers=" + strB(bFadeOutOthers))
          Else
            If \nLTFIFadeOutOthersAction <> #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              bFadeOutOthers = #True
              ; debugMsg0(sProcName, "bFadeOutOthers=" + strB(bFadeOutOthers))
              nFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, \nLTFIFadeOutOthersAction, @aSub(pSubPtr), @grProd)
            EndIf
          EndIf
          ; Added 6Jan2020 11.8.2.1ax following tests by Peter Holmes where live test incorrectly blacked out other channels even though the 'do not blackout other channels' checkbox was selected
          If (bLiveDMXTest) And (bBlackoutOthersInLiveTest = #False)
            bFadeOutOthers = #False
            nFadeOutOthersTime = 0
            ; debugMsg0(sProcName, "bFadeOutOthers=" + strB(bFadeOutOthers))
          EndIf
          ; End added 6Jan2020 11.8.2.1ax
        EndIf ; EndIf nLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
      EndIf ; EndIf aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
    EndWith
    
    CompilerIf #cTraceDMXLoadChannelInfo
      debugMsg(sProcName, "bFadeOutOthers=" + strB(bFadeOutOthers) + ", nFadeOutOthersTime=" + nFadeOutOthersTime + ", nLTEntryType=" + decodeLTEntryType(nLTEntryType))
    CompilerEndIf
    If bFadeOutOthers
      For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
        ; debugMsg(sProcName, "gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
        If gbDMXDimmableChannel(nItemIndex)
          If grDMXChaseItems\bChaseRunning
            bChannelInChase = DMX_isChannelInChase(nDMXChannel)
          Else
            bChannelInChase = #False
          EndIf
          ; debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(grDMXChaseItems\bChaseRunning) + ", bChannelInChase=" + strB(bChannelInChase))
          If bChannelInChase = #False
            With grDMXChannelItems\aDMXChannelItem(nItemIndex)
              If gaDMXSendData(nItemIndex) > 0 ; Modified 11May2021 11.8.4.2bc (was testing \nDMXChannelValue - see comment of same date below)
                \bDMXChannelSet = #True
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) + ", grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                CompilerEndIf
                \nDMXChannelValue = 0
                \nDMXChannelFadeTime = nFadeOutOthersTime
                CompilerIf #cTraceDMXChannelSet Or #cTraceDMXFadeItemValues
                  debugMsg(sProcName, "(fade) grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(\bDMXChannelSet) + ", \nDMXChannelValue=" + \nDMXChannelValue + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
                CompilerEndIf
              EndIf
            EndWith
          EndIf ; EndIf bChannelInChase = #False
        EndIf ; EndIf gbDMXDimmableChannel(nItemIndex)
      Next nDMXChannel
    EndIf ; EndIf bFadeOutOthers
    
    If aSub(pSubPtr)\bDMXSend
      If nLTEntryType = #SCS_LT_ENTRY_TYPE_BLACKOUT
        debugMsg(sProcName, "grFixturesRunTime\nMaxFixture=" + grFixturesRunTime\nMaxFixture)
        If grFixturesRunTime\nMaxFixture < 0
          ; if no fixtures have been specified then 'blackout' ALL channels for the device
          For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
            nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
            With grDMXChannelItems\aDMXChannelItem(nItemIndex)
              If gaDMXSendData(nItemIndex) > 0 ; Modified 11May2021 11.8.4.2bc (was testing \nDMXChannelValue - see comment of same date below)
                \bDMXChannelSet = #True
                \nDMXChannelValue = 0
                \nDMXChannelFadeTime = nDMXFadeTimeForSub
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet) + ", \nDMXChannelValue=" + \nDMXChannelValue +
                                      ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
                CompilerEndIf
              EndIf
            EndWith
          Next nDMXChannel
        Else
          For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
            nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
            ; debugMsg(sProcName, "gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
            If gbDMXDimmableChannel(nItemIndex)
              With grDMXChannelItems\aDMXChannelItem(nItemIndex)
                If gaDMXSendData(nItemIndex) > 0 ; Modified 11May2021 11.8.4.2bc (was testing \nDMXChannelValue but that was incorrect as reported in tests by Dieter Edinger)
                  \bDMXChannelSet = #True
                  \nDMXChannelValue = 0
                  \nDMXChannelFadeTime = nDMXFadeTimeForSub
                  CompilerIf #cTraceDMXChannelSet
                    debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet) + ", \nDMXChannelValue=" + \nDMXChannelValue +
                                        ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
                  CompilerEndIf
                EndIf
              EndWith
            EndIf
          Next nDMXChannel
        EndIf
      Else
        nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(pSubPtr)\sLTLogicalDev)
        nLTMaxCurrChanValue = aSub(pSubPtr)\nLTMaxCurrChanValue
        For nFixtureIndex = 0 To aSub(pSubPtr)\nMaxFixture
          sFixtureCode = aSub(pSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
          If sFixtureCode
            With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)
              If \sFixtureCode = sFixtureCode
                ; should be #True
                nFixtureRunTimeIndex = DMX_getFixturesRunTimeIndex(nProdDevNo, sFixtureCode)
                CompilerIf #cTraceDMXChannelSet
                  debugMsg2(sProcName, "DMX_getFixturesRunTimeIndex(" + nProdDevNo + ", " + #DQUOTE$ + sFixtureCode + #DQUOTE$ + ")", nFixtureRunTimeIndex)
                CompilerEndIf
                If nFixtureRunTimeIndex >= 0
                  ; should be #True
                  nFixTypeIndex = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nFixTypeIndex
                  nTotalChans = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nTotalChans
                  ; nDMXStartChannel = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nDMXStartChannel
                  For nDevStartChannelIndex = 0 To grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nMaxDevStartChannelIndex
                    nDMXStartChannel = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\aDevStartChannel(nDevStartChannelIndex)
                    For nChanIndex = 0 To nTotalChans-1
                      If \aFixChan(nChanIndex)\bRelChanIncluded
                        nRelChanNo = \aFixChan(nChanIndex)\nRelChanNo
                        nDMXChannel = nDMXStartChannel + nRelChanNo - 1
                        ; Added bUsePreHotkeyValues test 13Jun2024 11.10.3al
                        If bUsePreHotkeyValues = #False
                          nDMXValue = \aFixChan(nChanIndex)\nDMXAbsValue
                        Else
                          nDMXValue = DMX_getPreHotkeyDMXValue(pSubPtr, nDMXChannel)
                        EndIf
                        bChannelDimmable = DMX_getFixTypeChanDimmable(nFixTypeIndex, nRelChanNo)
                        ; debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", nDMXValue=" + nDMXValue + ", bChannelDimmable=" + strB(bChannelDimmable) + ", nDMXValuePercentage=" + nDMXValuePercentage)
                        If bChannelDimmable And nDMXValuePercentage < 100
                          nDMXValue = (nDMXValue * nDMXValuePercentage) / 100
                        EndIf
                        ; debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", nDMXValue=" + nDMXValue)
                        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
                        If gbInCalcCueStartValues
                          bApplyFadeTime = #False
                        Else
                          bApplyFadeTime = \aFixChan(nChanIndex)\bApplyFadeTime
                        EndIf
                        nDMXFadeTime = 0
                        If bLiveDMXTest = #False ; Or 1=1 ; 20Jan2021 11.8.4ab added "Or 1=1"
                          ; If bChannelDimmable Or bApplyFadeTime
                          ; Modified 11Jan2021 11.8.3.4am do NOT apply fade time UNLESS the 'Fade' checkbox is checked,
                          ; ie do NOT apply fade time if the channel is dimmable but the 'fade' checkbox is clear.
                          ; Modified following Forum bug report 'Fade work incorrect in lighting cue?' by didiv, 7Jan2021.
                          If bApplyFadeTime
                            nCurrentDMXValue = gaDMXSendData(nItemIndex)
                            If nDMXValue > nCurrentDMXValue
                              nDMXFadeTime = nDMXFadeUpTimeForSub
                            ElseIf nDMXValue < nCurrentDMXValue
                              nDMXFadeTime = nDMXFadeDownTimeForSub
                            Else
                              nDMXFadeTime = nDMXFadeTimeForSub
                            EndIf
                          EndIf
                          ; debugMsg0(sProcName, "bApplyFadeTime=" + strB(bApplyFadeTime) + ", nDMXValue=" + nDMXValue + ", nCurrentDMXValue=" + nCurrentDMXValue + ", nDMXFadeTime=" + nDMXFadeTime)
                          If nLTMaxCurrChanValue >= 0
                            For n = 0 To nLTMaxCurrChanValue
                              If aSub(pSubPtr)\aLTCurrChanValue(n)\nDMXChannel = nDMXChannel
                                nMinDMXValue = aSub(pSubPtr)\aLTCurrChanValue(n)\nDMXValue
                                If nDMXValue < nMinDMXValue
                                  CompilerIf #cTraceDMXChannelSet
                                    debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", nDMXValue=" + nDMXValue + ", nMinDMXValue=" + nMinDMXValue)
                                  CompilerEndIf
                                  nDMXValue = nMinDMXValue
                                EndIf
                                Break
                              EndIf
                            Next n
                          EndIf ; EndIf nLTMaxCurrChanValue >= 0
                        EndIf ; EndIf bLiveDMXTest = #False
                        CompilerIf #cTraceDMXChannelSet
                          debugMsg(sProcName, "nRelChanNo=" + nRelChanNo + ", nDMXChannel=" + nDMXChannel + ", nDMXValue=" + nDMXValue + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) +
                                              ", bLiveDMXTest=" + strB(bLiveDMXTest) +
                                              ", \aFixChan(" + nChanIndex + ")\bApplyFadeTime=" + strB(\aFixChan(nChanIndex)\bApplyFadeTime) + ", bApplyFadeTime=" + strB(bApplyFadeTime) +
                                              ", nDMXFadeTimeForSub=" + nDMXFadeTimeForSub + ", nDMXFadeTime=" + nDMXFadeTime)
                        CompilerEndIf
                        grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet = #True
                        grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelValue = nDMXValue
                        grDMXChannelItems\aDMXChannelItem(nItemIndex)\nDMXChannelFadeTime = nDMXFadeTime
                        grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelDimmable = bChannelDimmable
                        grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXApplyFadeTime = bApplyFadeTime
                        traceDMXChannelItems(#cTraceDMXChannelSet)
                        traceDMXChannelIfReqd("(d) ", nDMXDevPtr, nDMXPort, nDMXChannel, nItemIndex)
                      EndIf
                    Next nChanIndex
                  Next nDevStartChannelIndex
                EndIf
              EndIf
            EndWith
          EndIf
          ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", grDMXChannelItems\aDMXChannelItem(62)\nDMXChannelValue=" + grDMXChannelItems\aDMXChannelItem(62)\nDMXChannelValue + ", \nDMXChannelFadeTime=" + grDMXChannelItems\aDMXChannelItem(62)\nDMXChannelFadeTime)
        Next nFixtureIndex
      EndIf
      
    EndIf ; EndIf aSub(pSubPtr)\bDMXSend
    
  EndIf ; EndIf pSubPtr >= 0
  
  traceDMXChannelItems(#cTraceDMXLoadChannelInfo)
  
  CompilerIf #cTraceDMXLoadChannelInfo
    debugMsg(sProcName, #SCS_END)
  CompilerEndIf
  
EndProcedure

Procedure DMX_loadDMXChannelItems(pSubPtr, nChaseStepIndex=0, bLiveDMXTest=#False, bBlackoutOthersInLiveTest=#False)
  ; Used for entry types 'DMX Items' and 'Capture'
  PROCNAMECS(pSubPtr)
  Protected nLTEntryType
  Protected m, n
  Protected nMaxItemIndex
  Protected sCurrFixtureCodes.s, sFixtureCodes.s, sDMXChannels.s, nDMXValue, nDMXFadeTime, bDBO, nDMXDelayTime
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected nDMXChannel, nDMXStartChannel, nDevStartChannelIndex
  Protected nDefDMXFadeTime
  Protected bChannelInChase
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort
  Protected nDMXSendDataBaseIndex, nFixtureOffset, nItemIndex, bSkipFixture, nProdDevNo
  Protected nFirstFixtureIndex.l, nLastFixtureIndex.l, nThisFixtureIndex.l
  Protected bSubUsesFixtures
  Protected bDMXApplyFadeTime ; added 25Mar2019 11.8.0.2ck following test of 17th Doll LX2A where items like "L6:13@36f3 // tilt" didn't apply the 3-second fade
  Protected nDMXFadeUpTime, nDMXFadeDownTime, nDMXFadeOutOthersTime ; Added 8Jul2023 11.10.0bq
  
  CompilerIf #cTraceDMXLoadChannelInfo
    debugMsg(sProcName, #SCS_START + ", nChaseStepIndex=" + nChaseStepIndex + ", bLiveDMXTest=" + strB(bLiveDMXTest) + ", bBlackoutOthersInLiveTest=" + strB(bBlackoutOthersInLiveTest) + ")")
  CompilerEndIf
  
  If grFixturesRunTime\bLoaded = #False
    DMX_loadFixturesRunTime()
  EndIf
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      nLTEntryType = \nLTEntryType
      nDMXFadeUpTime = -2 ; indicates do not fade up
      nDMXFadeDownTime = -2 ; indicates do not fade down
      nDMXFadeOutOthersTime = -2 ; indicates do not fade out others
      Select nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
          nDMXFadeUpTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEUP, \nLTDIFadeUpAction, @aSub(pSubPtr), @grProd)
          nDMXFadeDownTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEDOWN, \nLTDIFadeDownAction, @aSub(pSubPtr), @grProd)
          nDMXFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS, \nLTDIFadeOutOthersAction, @aSub(pSubPtr), @grProd)
        Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
          nDMXFadeUpTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEUP, \nLTFIFadeUpAction, @aSub(pSubPtr), @grProd)
          nDMXFadeDownTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEDOWN, \nLTFIFadeDownAction, @aSub(pSubPtr), @grProd)
          nDMXFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, \nLTFIFadeOutOthersAction, @aSub(pSubPtr), @grProd)
        Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          nDMXFadeUpTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEUP, \nLTDCFadeUpAction, @aSub(pSubPtr), @grProd)
          nDMXFadeDownTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEDOWN, \nLTDCFadeDownAction, @aSub(pSubPtr), @grProd)
          nDMXFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEOUTOTHERS, \nLTDCFadeOutOthersAction, @aSub(pSubPtr), @grProd)
      EndSelect
      CompilerIf #cTraceDMXLoadChannelInfo
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\nLTEntryType=" + decodeLTEntryType(\nLTEntryType) +
                            ", nDMXFadeUpTime=" + nDMXFadeUpTime + ", nDMXFadeDownTime=" + nDMXFadeDownTime + ", nDMXFadeOutOthersTime=" + nDMXFadeOutOthersTime)
      CompilerEndIf
    EndWith
    
    If bLiveDMXTest = #False
      nDefDMXFadeTime = DMX_getDefFadeTimeForSub(@aSub(pSubPtr), @grProd)
    EndIf
    
    nMaxItemIndex = aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\nDMXSendItemCount - 1
    CompilerIf #cTraceDMXLoadChannelInfo
      debugMsg(sProcName, "nMaxItemIndex=" + nMaxItemIndex)
      For m = 0 To nMaxItemIndex
        With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)
          debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\aChaseStep(" + nChaseStepIndex + ")\aDMXSendItem(" + m + ")\sDMXChannels=" + \sDMXChannels + ", \sDMXItemStr=" + \sDMXItemStr +
                              ", \nDMXDelayTime=" + \nDMXDelayTime + ", \nDMXFadeTime=" + \nDMXFadeTime + ", \nDMXValue=" + \nDMXValue)
        EndWith
      Next m
    CompilerEndIf
    
    For m = 0 To nMaxItemIndex
      With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)
        If FindString(\sDMXChannels, ":")
          bSubUsesFixtures = #True  ; at least one DMX Item in this sub uses fixtures
          Break
        EndIf
      EndWith
    Next m
    
    With aSub(pSubPtr)
      If \nDMXControlPtr < 0
        DMX_setDMXControlPtrForSub(pSubPtr)
      EndIf
      nDMXControlPtr = \nDMXControlPtr
      If nDMXControlPtr >= 0
        nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
        nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
        nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
      EndIf
      CompilerIf #cTraceDMXLoadChannelInfo
        debugMsg(sProcName, "aSub(" + getSubLabel(pSubPtr) + ")\sLTLogicalDev=" + \sLTLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr +
                            ", nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex)
      CompilerEndIf
      
      If bLiveDMXTest
        ; When using 'Live DMX Test' we either blackout others, or we leave others alone (by setting nDMXFadeOutOthersTime to -2)
        If bBlackoutOthersInLiveTest
          nDMXFadeOutOthersTime = 0
        Else
          nDMXFadeOutOthersTime = -2
        EndIf
      EndIf
    EndWith
    
    CompilerIf #cTraceDMXLoadChannelInfo
      debugMsg(sProcName, "nDMXFadeOutOthersTime=" + nDMXFadeOutOthersTime)
    CompilerEndIf
    If nDMXFadeOutOthersTime >= 0
      For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
        If (bSubUsesFixtures = #False) Or (gbDMXDimmableChannel(nItemIndex))
          If grDMXChaseItems\bChaseRunning
            bChannelInChase = DMX_isChannelInChase(nDMXChannel)
          Else
            bChannelInChase = #False
          EndIf
          If bChannelInChase = #False
            With grDMXChannelItems\aDMXChannelItem(nItemIndex)
              ; debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
              If gaDMXSendData(nItemIndex) > 0 ; Modified 11May2021 11.8.5 (was testing \nDMXChannelValue - see comments of same date in DMX_loadDMXChannelItemsFI())
                \bDMXChannelSet = #True
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                CompilerEndIf
                ; \nDMXChannelValue = 0 ; Commented out 25Sep2024 11.10.6aa following bug reported by Sascha Pirkowski
                \nDMXChannelFadeTime = nDMXFadeOutOthersTime
                CompilerIf #cTraceDMXFadeItemValues
                  debugMsg(sProcName, "(fade) grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(\bDMXChannelSet) +
                                      ", \nDMXChannelValue=" + \nDMXChannelValue + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
                CompilerEndIf
              EndIf
            EndWith
          EndIf ; EndIf bChannelInChase = #False
        EndIf ; EndIf (bSubUsesFixtures = #False) Or (gbDMXDimmableChannel(nItemIndex))
      Next nDMXChannel
    EndIf ; EndIf bFadeOutOthers
    
    If aSub(pSubPtr)\bDMXSend
      ; debugMsg(sProcName, "\bDMXSend=" + strB(aSub(pSubPtr)\bDMXSend) + ", \aChaseStep(" + nChaseStepIndex + ")\nDMXSendItemCount=" + aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\nDMXSendItemCount)
      nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(pSubPtr)\sLTLogicalDev)
      For m = 0 To nMaxItemIndex
        With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)
          If aSub(pSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ And \nDMXDelayTime > 0
            Continue
          EndIf
          bDMXApplyFadeTime = #False ; added 25Mar2019 11.8.0.2ck (see comment at "Protected bDMXApplyFadeTime")
          bDBO = \bDBO
          If bDBO = #False
            If FindString(\sDMXChannels, ":")
              sFixtureCodes = UCase(StringField(\sDMXChannels, 1, ":"))
              If Len(sFixtureCodes) = 0
                sFixtureCodes = sCurrFixtureCodes
              Else
                sCurrFixtureCodes = sFixtureCodes
              EndIf
              sDMXChannels = StringField(\sDMXChannels, 2, ":")
              DMX_setFixturesRunTimeRequiredFlags(nProdDevNo, sFixtureCodes, @nFirstFixtureIndex, @nLastFixtureIndex)
            Else
              sFixtureCodes = ""
              sDMXChannels = \sDMXChannels
              nFirstFixtureIndex = -1
              nLastFixtureIndex = -1
            EndIf
            nThisFixtureIndex = nFirstFixtureIndex
            nDMXValue = \nDMXValue ; Required DMX value
          EndIf ; EndIf bDBO = #False
          
          If aSub(pSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ ; Or aSub(pSubPtr)\nLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            nDMXDelayTime = \nDMXDelayTime
          Else
            nDMXDelayTime = 0
          EndIf
          
          CompilerIf #cTraceDMXChannelSet
            debugMsg(sProcName, "\sDMXItemStr=" + \sDMXItemStr + ", \nDMXFadeTime=" + \nDMXFadeTime)
          CompilerEndIf
          If bLiveDMXTest
            nDMXFadeTime = 0
          Else
            nDMXFadeTime = \nDMXFadeTime
            ; added 25Mar2019 11.8.0.2ck (see comment at "Protected bDMXApplyFadeTime")
            If nDMXFadeTime >= 0
              bDMXApplyFadeTime = #True
            EndIf
            ; end added 25Mar2019 11.8.0.2ck
          EndIf
          If nDMXFadeTime < 0
            nDMXFadeTime = nDefDMXFadeTime
            If nDMXFadeTime >= 0
              bDMXApplyFadeTime = #True
            EndIf
          EndIf
          CompilerIf #cTraceDMXChannelSet
            debugMsg(sProcName, "nDMXFadeTime=" + nDMXFadeTime)
          CompilerEndIf
        EndWith
        
        If bDBO ; dead blackout
          For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
            nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
            If gbDMXDimmableChannel(nItemIndex)
              With grDMXChannelItems\aDMXChannelItem(nItemIndex)
                If gaDMXSendData(nItemIndex) > 0 ; Modified 11May2021 11.8.5 (was testing \nDMXChannelValue - see comments of same date in DMX_loadDMXChannelItemsFI())
                  \bDMXChannelSet = #True
                  CompilerIf #cTraceDMXChannelSet
                    debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                  CompilerEndIf
                  \nDMXChannelValue = 0
                  \nDMXChannelFadeTime = nDMXFadeTime
                  \bDMXApplyFadeTime = bDMXApplyFadeTime ; added 25Mar2019 11.8.0.2ck (see comment at "Protected bDMXApplyFadeTime")
                  traceDMXChannelIfReqd("(d) ", nDMXDevPtr, nDMXPort, nDMXChannel, nItemIndex)
                EndIf
              EndWith
            EndIf
          Next nDMXChannel
          
        ElseIf nLastFixtureIndex >= 0
          While #True ; fixtures loop
            bSkipFixture = #False
            If nThisFixtureIndex >= 0
              If grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\bFixtureRequired = #False
                bSkipFixture = #True
              EndIf
            EndIf
            If bSkipFixture = #False
              CheckSubInRange(nThisFixtureIndex, ArraySize(grFixturesRunTime\aFixtureRunTime()), "grFixturesRunTime\aFixtureRunTime()")
              For nDevStartChannelIndex = 0 To grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\nMaxDevStartChannelIndex
                CheckSubInRange(nDevStartChannelIndex, ArraySize(grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\aDevStartChannel()), "grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\aDevStartChannel()")
                nDMXStartChannel = grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\aDevStartChannel(nDevStartChannelIndex)
                If nThisFixtureIndex = -1
                  ; no fixture - just absolute DMX channel addresses
                  nFixtureOffset = 0
                Else
                  nFixtureOffset = nDMXStartChannel - 1
                EndIf
                ; process channels
                nPartCount = CountString(sDMXChannels, ",") + 1
                CompilerIf #cTraceDMXLoadChannelInfo
                  debugMsg(sProcName, "sDMXChannels=" + #DQUOTE$ + sDMXChannels + #DQUOTE$ + ", nPartCount=" + nPartCount)
                CompilerEndIf
                For nPart = 1 To nPartCount
                  sPart = StringField(sDMXChannels, nPart, ",")
                  nDashCount = CountString(sPart, "-")
                  Select nDashCount
                    Case 0
                      sFromChannel = sPart
                      sUpToChannel = sPart
                    Case 1
                      sFromChannel = StringField(sPart, 1, "-")
                      sUpToChannel = StringField(sPart, 2, "-")
                  EndSelect
                  nFromChannel = Val(sFromChannel) + nFixtureOffset
                  nUpToChannel = Val(sUpToChannel) + nFixtureOffset
                  ; process channels for this part
                  CompilerIf #cTraceDMXLoadChannelInfo
                    debugMsg(sProcName, "nPart=" + nPart + ", sPart=" + #DQUOTE$ + sPart + #DQUOTE$ + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex +
                                        ", nFromChannel=" + nFromChannel + ", nUpToChannel=" + nUpToChannel + ", nDMXValue=" + nDMXValue)
                  CompilerEndIf
                  For nDMXChannel = nFromChannel To nUpToChannel
                    nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
                    With grDMXChannelItems\aDMXChannelItem(nItemIndex)
                      If \bDMXChannelSet = #False
                        \bDMXChannelSet = #True
                        CompilerIf #cTraceDMXChannelSet
                          debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                        CompilerEndIf
                      EndIf
                      ; Added 6Nov2023 11.10.0cp
                      ; debugMsg(sProcName, "setting grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\nDMXChannelValue=" + nDMXValue + ", was " + \nDMXChannelValue)
                      If nDMXFadeTime < 0
                        If nDMXValue < \nDMXChannelValue
                          nDMXFadeTime = nDMXFadeDownTime
                        ElseIf nDMXValue > \nDMXChannelValue
                          nDMXFadeTime = nDMXFadeUpTime
                        Else
                          nDMXFadeTime = 0
                        EndIf
                      EndIf
                      ; End added 6Nov2023 11.10.0cp
                      \nDMXChannelValue = nDMXValue
                      \nDMXChannelFadeTime = nDMXFadeTime
                      \bDMXChannelDimmable = gbDMXDimmableChannel(nItemIndex)
                      \bDMXApplyFadeTime = bDMXApplyFadeTime
                      ; debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelDimmable=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)))
                      traceDMXChannelIfReqd("(c) ", nDMXDevPtr, nDMXPort, nDMXChannel, nItemIndex)
                    EndWith
                  Next nDMXChannel
                Next nPart
              Next nDevStartChannelIndex
            EndIf ; EndIf bSkipFixture = #False
            nThisFixtureIndex + 1
            If nThisFixtureIndex > nLastFixtureIndex
              Break ; break While #True (fixtures loop)
            EndIf
          Wend
          
        Else
          ; process channels
          nPartCount = CountString(sDMXChannels, ",") + 1
          CompilerIf #cTraceDMXLoadChannelInfo
            debugMsg(sProcName, "sDMXChannels=" + #DQUOTE$ + sDMXChannels + #DQUOTE$ + ", nPartCount=" + nPartCount)
          CompilerEndIf
          For nPart = 1 To nPartCount
            sPart = StringField(sDMXChannels, nPart, ",")
            nDashCount = CountString(sPart, "-")
            Select nDashCount
              Case 0
                sFromChannel = sPart
                sUpToChannel = sPart
              Case 1
                sFromChannel = StringField(sPart, 1, "-")
                sUpToChannel = StringField(sPart, 2, "-")
            EndSelect
            nFromChannel = Val(sFromChannel)
            nUpToChannel = Val(sUpToChannel)
            ; process channels for this part
            CompilerIf #cTraceDMXLoadChannelInfo
              debugMsg(sProcName, "nPart=" + nPart + ", sPart=" + #DQUOTE$ + sPart + #DQUOTE$ + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex +
                                  ", nFromChannel=" + nFromChannel + ", nUpToChannel=" + nUpToChannel + ", nDMXValue=" + nDMXValue)
            CompilerEndIf
            For nDMXChannel = nFromChannel To nUpToChannel
              nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
              With grDMXChannelItems\aDMXChannelItem(nItemIndex)
                \bDMXChannelSet = #True
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                  debugMsg(sProcName, "setting grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\nDMXChannelValue=" + nDMXValue + ", was " + \nDMXChannelValue)
                CompilerEndIf
                If aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)\nDMXFadeTime >= 0
                  \nDMXChannelFadeTime = aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)\nDMXFadeTime
                  CompilerIf #cTraceDMXChannelSet : debugMsg(sProcName, "DMX channel " + nDMXChannel + ": using item's fade time (" + \nDMXChannelFadeTime + ")") : CompilerEndIf
                ElseIf nDMXValue > \nDMXChannelValue
                  \nDMXChannelFadeTime = nDMXFadeUpTime
                  CompilerIf #cTraceDMXChannelSet : debugMsg(sProcName, "DMX channel " + nDMXChannel + ": using sub-cue's fade up time (" + \nDMXChannelFadeTime + ")") : CompilerEndIf
                ElseIf nDMXValue < \nDMXChannelValue
                  \nDMXChannelFadeTime = nDMXFadeDownTime
                  CompilerIf #cTraceDMXChannelSet : debugMsg(sProcName, "DMX channel " + nDMXChannel + ": using sub-cue's fade down time (" + \nDMXChannelFadeTime + ")") : CompilerEndIf
                Else
                  \nDMXChannelFadeTime = 0 ; no change in DMX value
                  CompilerIf #cTraceDMXChannelSet : debugMsg(sProcName, "DMX channel " + nDMXChannel + ": no fade required") : CompilerEndIf
                EndIf
                \nDMXChannelValue = nDMXValue
                \bDMXChannelDimmable = gbDMXDimmableChannel(nItemIndex)
                \bDMXApplyFadeTime = bDMXApplyFadeTime
                ; debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelDimmable=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)))
                traceDMXChannelIfReqd("(c) ", nDMXDevPtr, nDMXPort, nDMXChannel, nItemIndex)
              EndWith
            Next nDMXChannel
          Next nPart
          
        EndIf
        
      Next m ; Next "aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aDMXSendItem(m)"
      
    EndIf ; EndIf aSub(pSubPtr)\bDMXSend
    
    ; Added 6Nov2023 11.10.0cp
    If nDMXFadeOutOthersTime >= 0 And bDBO = #False
      For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
        If (bSubUsesFixtures = #False) Or (gbDMXDimmableChannel(nItemIndex))
          If grDMXChaseItems\bChaseRunning
            bChannelInChase = DMX_isChannelInChase(nDMXChannel)
          Else
            bChannelInChase = #False
          EndIf
          If bChannelInChase = #False
            With grDMXChannelItems\aDMXChannelItem(nItemIndex)
              If \bDMXChannelSet = #False And \nDMXChannelValue > 0
                \bDMXChannelSet = #True
                CompilerIf #cTraceDMXChannelSet
                  debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(grDMXChannelItems\aDMXChannelItem(nItemIndex)\bDMXChannelSet))
                CompilerEndIf
                \nDMXChannelValue = 0
                \nDMXChannelFadeTime = nDMXFadeOutOthersTime
                CompilerIf #cTraceDMXFadeItemValues
                  debugMsg(sProcName, "(fade) grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\bDMXChannelSet=" + strB(\bDMXChannelSet) +
                                      ", \nDMXChannelValue=" + \nDMXChannelValue + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
                CompilerEndIf
              EndIf
            EndWith
          EndIf ; EndIf bChannelInChase = #False
        EndIf   ; EndIf (bSubUsesFixtures = #False) Or (gbDMXDimmableChannel(nItemIndex))
      Next nDMXChannel
    EndIf ; EndIf nDMXFadeOutOthersTime >= 0 And bDBO = #False
    ; End added 6Nov2023 11.10.0cp

  EndIf ; EndIf pSubPtr >= 0
  
  CompilerIf #cTraceDMXLoadChannelInfo
    For n = 0 To ArraySize(grDMXChannelItems\aDMXChannelItem())
      With grDMXChannelItems\aDMXChannelItem(n)
        If \bDMXChannelSet
          debugMsg(sProcName, "grDMXChannelItems\aDMXChannelItem(" + n + ")\nDMXChannelValue=" + \nDMXChannelValue + ", \nDMXChannelFadeTime=" + \nDMXChannelFadeTime)
        EndIf
      EndWith
    Next n
  CompilerEndIf
  
  CompilerIf #cTraceDMXLoadChannelInfo
    debugMsg(sProcName, #SCS_END)
  CompilerEndIf
  
EndProcedure

Procedure.s DMX_getCurrFixtureCodes(pSubPtr, nChaseStepIndex, nItemIndex)
  PROCNAMECS(pSubPtr)
  Protected sCurrFixtureCodes.s, n
  
  With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)
    For n = 0 To nItemIndex
      If n < \nDMXSendItemCount
        If FindString(Trim(\aDMXSendItem(n)\sDMXItemStr), ":") > 1
          sCurrFixtureCodes = StringField(\aDMXSendItem(n)\sDMXItemStr, 1, ":")
        EndIf
      EndIf
    Next n
  EndWith
  ProcedureReturn sCurrFixtureCodes
EndProcedure

Procedure DMX_valDMXDBOItemString(sDMXItemStr.s)
  PROCNAMEC()
  Protected sWorkItemStr.s
  Protected nFadeTime, sFade.s
  Protected nErrorCode
  Static sFadeTimePrompt.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sFadeTimePrompt = Lang("DMX", "FadeTime")
    bStaticLoaded = #True
  EndIf
  
  While #True
    sWorkItemStr = LCase(Trim(RemoveString(sDMXItemStr, " ")))
    nFadeTime = 0
    Select Left(sWorkItemStr,3)
      Case "dbo"
        If sWorkItemStr = "dbo" Or sWorkItemStr = "dbo!"
          ; no fade info
          Break
        ElseIf Left(sWorkItemStr,5) = "dbo!f"
          ; extract fade time
          sFade = Mid(sWorkItemStr, 5)
          If Left(sFade,4) = "fade"
            sFade = Mid(sFade,5)
          ElseIf Left(sFade,1) = "f"
            sFade = Mid(sFade,2)
          EndIf
          If Len(sFade) = 0
            nErrorCode = 201
          Else
            If validateTimeFieldD(sFade, sFadeTimePrompt, #False, #False, 0, #True) = #False
              nErrorCode = 202
              Break
            EndIf
            nFadeTime = stringToTime(sFade)
            If nFadeTime < 0
              nErrorCode = 203
              Break
            EndIf
          EndIf
        EndIf
        
      Default
        nErrorCode = 60000
        Break
    EndSelect
    Break
  Wend
  
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure DMX_valDMXItemStr(sDMXItemStr.s, nProdDevNo, sCurrFixtureCodes.s)
  PROCNAMEC()
  ; returns 0 if no error found in sDMXItemStr
  ; returns non-zero error code if an error is found
  ; nb error code 405 means a channel number is greater than that allowed for in the user's license level
  
  ; sample indiviudal strings:
  ; 4@65fade0         - set channel 4 to a value of 65% with no fade time.
  ; 6@90              - set channel 6 to 90% using the default fade time.
  ; 1-6,9-12@50fade5  - set channels 1 through 6 and 9 through 12 to 50% in 5 seconds.
  ; 1,3,5,7@dmx128    - set channels 1, 3, 5 and 7 to a DMX value of 128 (ie 50%) using the default fade time.
  
  ; mod since fixtures introduced:
  ; if a channel number or range contains a full stop (.) then the text before the full stop is considered to be the fixture code
  ; eg ML1.15 means channel 15 on fixture ML1, and if ML1's start DMX channel is 101 then ML1.15 will map to channel 115
  
  ; added 17Aug2020 11.8.3.2ar for DMX Capture feature
  ; [time] = time delay before starting this item, eg [8.3] for a time delay of 8.3 seconds. [time] (if present) must be at the start of the string.
  
  ; spaces anywhere in sDMXItemStr are ignored
  
  Protected sWorkItemStr.s, sFixtureAndChannels.s, sFixtureCodes.s
  Protected sDMXChannels.s, sLevelAndFade.s, sLevel.s, sFade.s, sDelay.s
  Protected nAtCount, nColonCount, nFadePtr, nDmxPtr
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s, sFrom.s, sUpTo.s, nFrom, nUpTo, sFromSortKey.s, sUpToSortKey.s
  Protected bDMXValue, nDMXValue, nFadeTime, nDelayTime, nRightBracketPtr
  Protected nChannel, nFixtureIndex
  Protected nErrorCode
  Static sFadeTimePrompt.s
  Static bStaticLoaded
  
  ; debugMsg(sProcName, #SCS_START)
  
  If bStaticLoaded = #False
    sFadeTimePrompt = Lang("DMX", "FadeTime")
    bStaticLoaded = #True
  EndIf
  
  While #True ; While loop to enable 'Break' out of the loop if error found
    sWorkItemStr = LCase(Trim(RemoveString(sDMXItemStr, " ")))
    ; debugMsg(sProcName, "sDMXItemStr=" + #DQUOTE$ + sDMXItemStr + #DQUOTE$ + ", sWorkItemStr=" + #DQUOTE$ + sWorkItemStr + #DQUOTE$)
    bDMXValue = #False
    nDMXValue = -1
    nFadeTime = 0
    nDelayTime = 0
    
    If Left(sWorkItemStr, 3) = "dbo" ; dead blackout, or fade to dead blackout
      nErrorCode = DMX_valDMXDBOItemString(sWorkItemStr) ; returns 0 if DBO string is valid
      Break
    EndIf
    
    ; Added 17Aug2020 11.8.3.2ar for DMX Capture feature
    If Left(sWorkItemStr, 1) = "["
      ; [time] = time delay before starting this item, eg [8.3] for a time delay of 8.3 seconds. [time] (if present) must be at the start of the string.
      nRightBracketPtr = FindString(sWorkItemStr, "]")
      sDelay = Mid(sWorkItemStr, 2, nRightBracketPtr-2)
      nDelayTime = stringToTime(sDelay)
      If nDelayTime < 0
        nErrorCode = 801
        Break
      EndIf
      sWorkItemStr = Mid(sWorkItemStr, nRightBracketPtr+1) ; remove [time] from start of sWorkItemStr for the remainder of this validation
    EndIf
    ; End added 17Aug2020 11.8.3.2ar
    
    nAtCount = CountString(sWorkItemStr, "@")
    Select nAtCount
      Case 0
        sFixtureAndChannels = sWorkItemStr
      Case 1
        sFixtureAndChannels = StringField(sWorkItemStr, 1, "@")
      Default
        nErrorCode = 1
        Break
    EndSelect
    
    ; INFO: error codes 50100 to 59999 mean fixture code(s) invalid or unknown
    nColonCount = CountString(sFixtureAndChannels, ":")
    Select nColonCount
      Case 0
        sFixtureCodes = ""
        sDMXChannels = sFixtureAndChannels
      Case 1
        sFixtureCodes = StringField(sFixtureAndChannels, 1, ":")
        sDMXChannels = StringField(sFixtureAndChannels, 2, ":")
        If (Len(sFixtureCodes) = 0) And (Len(sCurrFixtureCodes) = 0)
          nErrorCode = 50100
          Break
        EndIf
      Default
        nErrorCode = 50200
        Break
    EndSelect
    If sFixtureCodes
      nPartCount = CountString(sFixtureCodes, ",") + 1
      For nPart = 1 To nPartCount
        sPart = StringField(sFixtureCodes, nPart, ",")
        nDashCount = CountString(sPart, "-")
        Select nDashCount
          Case 0
            sFrom = sPart
            sUpTo = sPart
          Case 1
            sFrom = StringField(sPart, 1, "-")
            sUpTo = StringField(sPart, 2, "-")
          Default
            nErrorCode = 50300 + nPart
            Break
        EndSelect
        nFixtureIndex = DMX_getProdFixtureIndex(nProdDevNo, sFrom)
        If nFixtureIndex < 0
          nErrorCode = 50400 + nPart
          Break
        EndIf
        If sUpTo <> sFrom
          nFixtureIndex = DMX_getProdFixtureIndex(nProdDevNo, sUpTo)
          If nFixtureIndex < 0
            nErrorCode = 50500 + nPart
            Break
          EndIf
          sFromSortKey = expandNumbersInString(sFrom, 4)
          sUpToSortKey = expandNumbersInString(sUpTo, 4)
          If sUpToSortKey < sFromSortKey
            nErrorCode = 50600 + nPart
            Break
          EndIf
        EndIf
      Next nPart
    EndIf
    
    If Len(sDMXChannels) = 0
      nErrorCode = 2
      Break
    EndIf
    
    If nAtCount = 0
      sLevelAndFade = ""
    Else
      sLevelAndFade = StringField(sWorkItemStr, 2, "@")
    EndIf
    
    ; extract fade time
    nFadePtr = FindString(sLevelAndFade, "f")
    If nFadePtr = 0
      sLevel = sLevelAndFade
      sFade = ""
      nFadeTime = -2
    Else
      sLevel = Left(sLevelAndFade, (nFadePtr-1))
      sFade = Mid(sLevelAndFade, nFadePtr)
      If Left(sFade,4) = "fade"
        sFade = Mid(sFade,5)
      ElseIf Left(sFade,1) = "f"
        sFade = Mid(sFade,2)
      EndIf
      If Len(sFade) = 0
        nErrorCode = 201
      Else
        If validateTimeFieldD(sFade, sFadeTimePrompt, #False, #False, 0, #True) = #False
          nErrorCode = 202
          Break
        EndIf
        nFadeTime = stringToTime(sFade)
        If nFadeTime < 0
          nErrorCode = 203
          Break
        EndIf
      EndIf
    EndIf
    
    ; extract level
    If Left(sLevel,3) = "dmx"
      sLevel = Mid(sLevel,4)
      bDMXValue = #True
    ElseIf Left(sLevel,1) = "d"
      sLevel = Mid(sLevel,2)
      bDMXValue = #True
    EndIf
    If Len(sLevel) = 0
      ; nErrorCode = 301
      nDMXValue = 0
    Else
      If IsInteger(sLevel) = #False
        nErrorCode = 302
        Break
      EndIf
      If bDMXValue
        nDMXValue = Val(sLevel)
      Else ; percentage
        nDMXValue = Val(sLevel) * 2.55
      EndIf
      If nDMXValue < 0 Or nDMXValue > 255
        nErrorCode = 303
        Break
      EndIf
    EndIf
    
    ; extract and process channels (nb must extract fade time and level before processing the channels, which is why they are extracted in the above code)
    nPartCount = CountString(sDMXChannels, ",") + 1
    For nPart = 1 To nPartCount
      sPart = StringField(sDMXChannels, nPart, ",")
      nDashCount = CountString(sPart, "-")
      Select nDashCount
        Case 0
          sFrom = sPart
          sUpTo = sPart
        Case 1
          sFrom = StringField(sPart, 1, "-")
          sUpTo = StringField(sPart, 2, "-")
        Default
          nErrorCode = 40100 + nPart
          Break
      EndSelect
      If IsInteger(sFrom) = #False Or IsInteger(sUpTo) = #False
        nErrorCode = 40200 + nPart
        Break
      EndIf
      nFrom = Val(sFrom)
      nUpTo = Val(sUpTo)
      If nFrom < 1 Or nFrom > 512 Or nUpTo < 1 Or nUpTo > 512
        nErrorCode = 40300 + nPart
        Break
      EndIf
      If nUpTo < nFrom
        nErrorCode = 40400 + nPart
        Break
      EndIf
      If nUpTo > grLicInfo\nMaxDMXChannel
        nErrorCode = 40500 + nPart ; INFO: error codes 40500 to 40599 mean a channel number is greater than that allowed for in the user's license level
        Break
      EndIf
    Next nPart
    Break
  Wend
  
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure.s DMX_reformatDMXItemStr(sDMXItemStr.s)
  PROCNAMEC()
  Protected sFixturesAndChannels.s, sValuesEtc.s, sBeforeComment.s, sComment.s, sCommand.s
  Protected sReformattedStr.s
  
  sBeforeComment = Trim(StringField(sDMXItemStr, 1, "//"))
  sComment = StringField(sDMXItemStr, 2, "//")
  
  If FindString(sBeforeComment, "!")
    sCommand = StringField(sBeforeComment, 1, "!")
    sValuesEtc = StringField(sBeforeComment, 2, "!")
    sReformattedStr = UCase(sCommand) + "!" + sValuesEtc
  Else
    sFixturesAndChannels = StringField(sBeforeComment, 1, "@")
    sReformattedStr = UCase(sFixturesAndChannels) ; to force fixture codes to uppercase
    If FindString(sBeforeComment, "@")
      sValuesEtc = StringField(sBeforeComment, 2, "@")
      sReformattedStr + "@" + sValuesEtc
    EndIf
  EndIf
  
  If FindString(sDMXItemStr, "//")
    sReformattedStr + " //" + sComment
  EndIf
  
  ProcedureReturn sReformattedStr
  
EndProcedure

Procedure DMX_valDMXChannels(sDMXChannels.s)
  PROCNAMEC()
  ; returns 0 if no error found in sDMXChannels
  ; returns non-zero error code if an error is found
  ; nb error code 405 means a channel number is greater than that allowed for in the user's license level
  
  ; sample individual strings:
  ; 1-6,9-12  = channels 1 through 6 and 9 through 12
  ; 1,3,5,7   = channels 1, 3, 5 and 7
  
  ; spaces anywhere in sDMXChannels are ignored
  
  Protected sMyDMXChannels.s
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s, sFrom.s, sUpTo.s, nFrom, nUpTo
  Protected nChannel
  Protected nErrorCode
  
  While #True ; While loop to enable 'Break' out of the loop if error found
    sMyDMXChannels = StringField(LCase(Trim(RemoveString(sDMXChannels, " "))), 1, "(")
    If Len(sMyDMXChannels) = 0
      Break
    EndIf
    
    ; extract and process channels (nb must extract fade time and level before processing the channels, which is why they are extracted in the above code)
    nPartCount = CountString(sMyDMXChannels, ",") + 1
    For nPart = 1 To nPartCount
      sPart = StringField(sMyDMXChannels, nPart, ",")
      nDashCount = CountString(sPart, "-")
      Select nDashCount
        Case 0
          sFrom = sPart
          sUpTo = sPart
        Case 1
          sFrom = StringField(sPart, 1, "-")
          sUpTo = StringField(sPart, 2, "-")
        Default
          nErrorCode = 401
          Break
      EndSelect
      If IsInteger(sFrom) = #False Or IsInteger(sUpTo) = #False
        nErrorCode = 402
        Break
      EndIf
      nFrom = Val(sFrom)
      nUpTo = Val(sUpTo)
      If nFrom < 1 Or nFrom > 512 Or nUpTo < 1 Or nUpTo > 512
        nErrorCode = 403
        Break
      EndIf
      If nUpTo < nFrom
        nErrorCode = 404
        Break
      EndIf
      If nUpTo > grLicInfo\nMaxDMXChannel
        nErrorCode = 405
        ; nb do not change '405' as the error code for a channel number greater than that allowed for in the user's license level
        ; and do not use '405' for any other error in this procedure
        Break
      EndIf
    Next nPart
    Break
  Wend
  
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure DMX_valDMXStartChannels(sDMXStartChannels.s, sFixtureCode.s, nFixtureChannels, *nReturnChannelCount)
  PROCNAMEC()
  ; returns 0 if no error found in sDMXStartChannels
  ; returns non-zero error code if an error is found
  ; nb error code 405 means a channel number is greater than that allowed for in the user's license level
  
  ; sample individual strings:
  ; 1-6,9-12  = channels 1 through 6 and 9 through 12
  ; 1,3,5,7   = channels 1, 3, 5 and 7
  
  ; spaces anywhere in sDMXStartChannels are ignored
  
  Protected sMyDMXStartChannels.s
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s, sFrom.s, sUpTo.s, nFrom, nUpTo
  Protected nChannelCount
  Protected Dim bDMXStartChannelSelected(512), nChannelNo
  Protected nErrorCode
  
  While #True ; While loop to enable 'Break' out of the loop if error found
    sMyDMXStartChannels = StringField(LCase(Trim(RemoveString(sDMXStartChannels, " "))), 1, "(")
    If Len(sMyDMXStartChannels) = 0
      Break
    EndIf
    
    ; extract and process channels (nb must extract fade time and level before processing the channels, which is why they are extracted in the above code)
    nPartCount = CountString(sMyDMXStartChannels, ",") + 1
    For nPart = 1 To nPartCount
      sPart = StringField(sMyDMXStartChannels, nPart, ",")
      nDashCount = CountString(sPart, "-")
      If nDashCount > 0 And nFixtureChannels > 1
        nErrorCode = 406
        grDMX\sChannelErrorMsg = LangPars("Errors", "DMXChannelRangeNotAvailable", sPart, sFixtureCode, Str(nFixtureChannels))
        Break
      EndIf
      Select nDashCount
        Case 0
          sFrom = sPart
          sUpTo = sPart
        Case 1
          sFrom = StringField(sPart, 1, "-")
          sUpTo = StringField(sPart, 2, "-")
        Default
          nErrorCode = 401
          Break
      EndSelect
      If IsInteger(sFrom) = #False Or IsInteger(sUpTo) = #False
        nErrorCode = 402
        Break
      EndIf
      nFrom = Val(sFrom)
      nUpTo = Val(sUpTo)
      If nFrom < 1 Or nFrom > 512 Or nUpTo < 1 Or nUpTo > 512
        nErrorCode = 403
        Break
      EndIf
      If nUpTo < nFrom
        nErrorCode = 404
        Break
      EndIf
      If nUpTo > grLicInfo\nMaxDMXChannel
        nErrorCode = 405
        ; nb do not change '405' as the error code for a channel number greater than that allowed for in the user's license level
        ; and do not use '405' for any other error in this procedure
        Break
      EndIf
      For nChannelNo = nFrom To nUpTo
        If bDMXStartChannelSelected(nChannelNo)
          nErrorCode = 407
          grDMX\sChannelErrorMsg = LangPars("Errors", "DMXChannelDuplicated", Str(nChannelNo))
          Break
        Else
          bDMXStartChannelSelected(nChannelNo) = #True
        EndIf
      Next nChannelNo
      nChannelCount + (nUpTo - nFrom + 1)
    Next nPart
    Break
  Wend
  
  If nErrorCode = 0
    PokeI(*nReturnChannelCount, nChannelCount)
  EndIf
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure DMX_populateFixtureDMXStartChannelsArray(pSubPtr)
  PROCNAMEC()
  ; returns 0 if no error found in sDMXStartChannels
  ; returns non-zero error code if an error is found
  ; nb error code 405 means a channel number is greater than that allowed for in the user's license level
  
  ; sample individual strings:
  ; 1-6,9-12  = channels 1 through 6 and 9 through 12
  ; 1,3,5,7   = channels 1, 3, 5 and 7
  
  ; spaces anywhere in sDMXStartChannels are ignored
  
  Protected nFixtureIndex, nDevMapDevPtr, nDMXStartChannel, sDMXStartChannels.s
  Protected sMyDMXStartChannels.s
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s, sFrom.s, sUpTo.s, nFrom, nUpTo
  Protected nChannelCount, nChannelNo, nIndex
  Protected nErrorCode, n, sTraceMsg.s
  
  nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, aSub(pSubPtr)\sLTLogicalDev)
  If nDevMapDevPtr >= 0
    For nFixtureIndex = 0 To aSub(pSubPtr)\nMaxFixture
      With aSub(pSubPtr)\aLTFixture(nFixtureIndex)
        \nLTMaxDMXStartChannelIndex = -1
        nDMXStartChannel = DMX_getFixtureDMXStartChannel(nDevMapDevPtr, \sLTFixtureCode)
        If nDMXStartChannel > 0
          \nLTMaxDMXStartChannelIndex = 0
          \aLTDMXStartChannel(0) = nDMXStartChannel
        Else
          sDMXStartChannels = DMX_getFixtureDMXStartChannels(nDevMapDevPtr, \sLTFixtureCode)
          While #True ; While loop to enable 'Break' out of the loop if error found
            sMyDMXStartChannels = StringField(LCase(Trim(RemoveString(sDMXStartChannels, " "))), 1, "(")
            If Len(sMyDMXStartChannels) = 0
              Break
            EndIf
            ; extract and process channels (nb must extract fade time and level before processing the channels, which is why they are extracted in the above code)
            nPartCount = CountString(sMyDMXStartChannels, ",") + 1
            For nPart = 1 To nPartCount
              sPart = StringField(sMyDMXStartChannels, nPart, ",")
              nDashCount = CountString(sPart, "-")
              Select nDashCount
                Case 0
                  sFrom = sPart
                  sUpTo = sPart
                Case 1
                  sFrom = StringField(sPart, 1, "-")
                  sUpTo = StringField(sPart, 2, "-")
                Default
                  nErrorCode = 401
                  Break
              EndSelect
              If IsInteger(sFrom) = #False Or IsInteger(sUpTo) = #False
                nErrorCode = 402
                Break
              EndIf
              nFrom = Val(sFrom)
              nUpTo = Val(sUpTo)
              If nFrom < 1 Or nFrom > 512 Or nUpTo < 1 Or nUpTo > 512
                nErrorCode = 403
                Break
              EndIf
              If nUpTo < nFrom
                nErrorCode = 404
                Break
              EndIf
              If nUpTo > grLicInfo\nMaxDMXChannel
                nErrorCode = 405
                ; nb do not change '405' as the error code for a channel number greater than that allowed for in the user's license level
                ; and do not use '405' for any other error in this procedure
                Break
              EndIf
              nChannelCount = (nUpTo - nFrom + 1)
              If nChannelCount > 0
                nIndex = \nLTMaxDMXStartChannelIndex
                \nLTMaxDMXStartChannelIndex + nChannelCount
                If \nLTMaxDMXStartChannelIndex > ArraySize(\aLTDMXStartChannel())
                  ReDim \aLTDMXStartChannel(\nLTMaxDMXStartChannelIndex)
                EndIf
                For nChannelNo = nFrom To nUpTo
                  nIndex + 1
                  \aLTDMXStartChannel(nIndex) = nChannelNo
                Next nChannelNo
              EndIf
            Next nPart
            Break
          Wend
          If nErrorCode > 0
            Break
          EndIf
        EndIf ; EndIf nDMXStartChannel > 0 / Else
        ; start for debugging only
        sTraceMsg = ""
        For n = 0 To \nLTMaxDMXStartChannelIndex
          If n = 0
            sTraceMsg + \aLTDMXStartChannel(n)
          Else
            sTraceMsg + "," + \aLTDMXStartChannel(n)
          EndIf
        Next n
        If sTraceMsg
          debugMsg(sProcName, \sLTFixtureCode + " StartChannels: " + sTraceMsg)
        EndIf
        ; end start for debugging only
      EndWith
    Next nFixtureIndex
  EndIf ; EndIf nDevMapDevPtr >= 0
  ProcedureReturn nErrorCode
  
EndProcedure

Procedure DMX_populateAllFixtureDMXStartChannelsArrays()
  PROCNAMEC()
  Protected i, j, nErrorCode, nThisErrorCode
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeK
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeK
          nThisErrorCode = DMX_populateFixtureDMXStartChannelsArray(j)
          If nThisErrorCode = 405 ; 405 = DMX Channel Limit (for license level)
            nErrorCode = nThisErrorCode
          EndIf
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  ProcedureReturn nErrorCode
EndProcedure

Procedure DMX_getDMXControlPtrForDevNo(nDevType, nDevNo)
  ; PROCNAMEC()
  Protected m
  Protected nDMXControlPtr
  
  nDMXControlPtr = -1
  For m = 0 To ArraySize(gaDMXControl())
    With gaDMXControl(m)
      If (\nDevType = nDevType) And (\nDevNo = nDevNo)
        nDMXControlPtr = m
        Break
      EndIf
    EndWith
  Next m
  ; debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) + ", nDevNo=" + nDevNo + ", nDMXControlPtr=" + nDMXControlPtr)
  ProcedureReturn nDMXControlPtr
EndProcedure

Procedure DMX_getDMXControlPtrForLogicalDev(nDevType, sLogicalDev.s)
  ; PROCNAMEC()
  Protected m
  Protected nDMXControlPtr
  
  nDMXControlPtr = -1
  For m = 0 To ArraySize(gaDMXControl())
    With gaDMXControl(m)
      If (\nDevType = nDevType) And (\sLogicalDev = sLogicalDev)
        nDMXControlPtr = m
        Break
      EndIf
    EndWith
  Next m
  ; debugMsg(sProcName, "nDevType=" + decodeDevType(nDevType) + ", sLogicalDev=" + sLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr)
  ProcedureReturn nDMXControlPtr
EndProcedure

Procedure DMX_getDMXCurrValues(ftHandle.i, nDMXPort, bForceSaveForCapture=#False)
  PROCNAMEC()
  Protected send_on_change_flag.a, nSendLabel.a, nReceiveLabel.a
  Protected bFTDIResult, ftStatus.l
  Protected nReadLength, nDataLength, nStatus.a, nStartCode.a, nDMXChannel
  Protected n, sMsg.s
  Protected bResult
  Protected sftHandle.s
  Protected qTimeOut.q, nTryCount, rxbytes.l    ; rxbytes was incorrect size should be 4 bytes DWORD as 1 byte was leading to stack corruption.
  Protected wLength.w
  Protected aDMXValue.a
  Protected *aBuffer
  
  sftHandle = decodeHandle(ftHandle)
  debugMsg(sProcName, #SCS_START + ", ftHandle=" + sftHandle + ", nDMXPort=" + nDMXPort + ", bForceSaveForCapture=" + strB(bForceSaveForCapture))
  
  If ftHandle
    If nDMXPort = 2
      nSendLabel = #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT2
      nReceiveLabel = #ENTTEC_RECEIVED_DMX_PORT2
    Else
      nSendLabel = #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1
      nReceiveLabel = #ENTTEC_RECEIVED_DMX_PORT1
    EndIf
    send_on_change_flag = 0
    bFTDIResult = DMX_FTDI_SendData(ftHandle, nSendLabel, @send_on_change_flag, 1)
    debugMsg(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(nSendLabel) + ", @send_on_change_flag, 1) returned " + strB(bFTDIResult) + ", send_on_change_flag=" + send_on_change_flag)
    If bFTDIResult
      *aBuffer = AllocateMemory(600)
      Delay(200)
      ftStatus = FT_Purge(ftHandle, #FT_PURGE_RX)
      debugMsg2(sProcName, "FT_Purge(" + sftHandle + ", #FT_PURGE_RX)", ftStatus)
      Delay(200)
      qTimeOut = ElapsedMilliseconds() + 2500
      While ElapsedMilliseconds() < qTimeOut
        ftStatus = FT_GetQueueStatus(ftHandle, @rxbytes)
        nTryCount + 1
        If rxbytes > 0 : Break : EndIf
        Delay(200)
      Wend
      debugMsg(sProcName, "FT_GetQueueStatus(" + decodeHandle(ftHandle) + ", @rxbytes) returned " + decodeFTStatus(ftStatus) + ", rxBytes=" + rxBytes + ", nTryCount=" + nTryCount)
      wLength = 513
      bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, nReceiveLabel, *aBuffer + 4, wLength)
      debugMsg(sProcName, "DMX_FTDI_ReceiveData(" + decodeHandle(ftHandle) + ", " + decodeDMXAPILabel(nReceiveLabel) + ", *aBuffer + 4, " + wLength + ") returned " + StrB(bFTDIResult))
      If bFTDIResult = #False
        debugMsg(sProcName, "DMX_FTDI_ReceiveData(" + decodeHandle(ftHandle) + ", " + decodeDMXAPILabel(nReceiveLabel) + ", *aBuffer + 4, " + wLength + ") returned " + StrB(bFTDIResult))
      Else
        Select nReceiveLabel
          Case #ENTTEC_RECEIVED_DMX_PORT1, #ENTTEC_RECEIVED_DMX_PORT2
            ; The following info based on the ENTTEC documentation for 'Received DMX Packet (Label=5)':
            ; 1st byte: DMX Receive status: 0 = Valid; non-zero = corrupted
            ; 2nd byte: start code
            ; remaining bytes: DMX channel values. The size can be determined from the overall message size.
            PokeA(*aBuffer, $7E)
            PokeA(*aBuffer + 1, nReceiveLabel)
            PokeW(*aBuffer + 2, wLength)
            nReadLength = wLength + 4
            CompilerIf #cTraceDMX Or #cTraceDMXSendChannels1to12
              If PeekA(*aBuffer + 4) = 0 And PeekA(*aBuffer + 5) = 0 ; aBuffer(4) = 0 means 'valid'; aBuffer(5) = 0 means data starts from DMX channel 1
                For nDMXChannel = 1 To 12
                  aDMXValue = PeekA(*aBuffer + nDMXChannel + 1)
                  sMsg + ", " + aDMXValue
                Next nDMXChannel
                debugMsg(sProcName, Mid(sMsg, 3))
              EndIf
            CompilerElseIf #cTraceDMXSendChannels1to34
              If PeekA(*aBuffer + 4) = 0 And PeekA(*aBuffer + 5) = 0
                For nDMXChannel = 1 To 34
                  aDMXValue = PeekA(*aBuffer + nDMXChannel + 1)
                  sMsg + ", " + aDMXValue
                Next nDMXChannel
                debugMsg(sProcName, Mid(sMsg, 3))
              EndIf
            CompilerEndIf
        EndSelect
        debugMsg(sProcName, "calling CopyMemory(*aBuffer + 4, @DMX_IN+4, " + wLength + ")")
        CopyMemory(*aBuffer + 4, @DMX_IN+4, wLength)
        If bForceSaveForCapture
          DMX_SaveDMXPacketForCapture(grDMX\nDMXCaptureControlPtr, *aBuffer, nReadLength)
        EndIf
        bResult = #True
      EndIf
    EndIf
  EndIf
  
  If *aBuffer
    FreeMemory(*aBuffer)
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bResult))
  ProcedureReturn bResult
  
EndProcedure

Procedure DMX_setReceiveDMXOnChangeFlag(ftHandle.i, SendOnChangeFlag.a)
  PROCNAMEC()
  Protected send_on_change_flag.a ; 0 = send always; 1 = send on data change only
  Protected nLabel.a, wLength.w
  Protected bFTDIResult
  
  ; debugMsg(sProcName, #SCS_START + ", ftHandle=" + decodeHandle(ftHandle) + ", SendOnChangeFlag=" + SendOnChangeFlag)
  send_on_change_flag = SendOnChangeFlag
  nLabel = #ENTTEC_RECEIVE_DMX_ON_CHANGE_PORT1
  wLength = 1
  bFTDIResult = DMX_FTDI_SendData(ftHandle, nLabel, @send_on_change_flag, wLength)
  debugMsg(sProcName, "DMX_FTDI_SendData(" + decodeHandle(ftHandle) + ", " + decodeDMXAPILabel(nLabel) + ", @send_on_change_flag, " + wLength + ") returned " + strB(bFTDIResult) + ", send_on_change_flag=" + send_on_change_flag)
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_requestData(nDMXControlPtr, bForceSave=#False)
  ; PROCNAMEC()
  Protected nReadLength
  Protected qTimeStart.q
  Protected *p_sACNRxBuffer
  Protected n_sACNDmxBufferSize.i
  
  ; debugMsg0(sProcName, #SCS_START + ", nDMXControlPtr=" + nDMXControlPtr)
  
  If nDMXControlPtr >= 0
    qTimeStart = ElapsedMilliseconds()
    If *gmDMXReceiveBuffer = 0
      *gmDMXReceiveBuffer = AllocateMemory(1000, #PB_Memory_NoClear)
    EndIf
    
    Select gaDMXControl(nDMXControlPtr)\nDMXDevType ; Changed \nDevType to \nDMXDevType 4Jun2024 11.10.3ai
      Case #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB, #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO,
           #SCS_DMX_DEV_ENTTEC_DMX_USB_PRO_MK2, #SCS_DMX_DEV_FTDI_USB_RS485
        If *gmDMXReceiveBuffer
          While #True
            grDMX\bRequestNextImmediately = #False ; may be set #True in DMX_SaveDMXChangeOfStatePacket()
            ; debugMsg(sProcName, "calling DMX_USBRead(" + gaDMXControl(nDMXControlPtr)\nFTHandle + ", *gmDMXReceiveBuffer, 1000)")
            nReadLength = DMX_USBRead(gaDMXControl(nDMXControlPtr)\nFTHandle, *gmDMXReceiveBuffer, 1000)
            ; debugMsg(sProcName, "nReadLength=" + nReadLength)
            If nReadLength > 0
              ; something received
              ; debugMsg(sProcName, "calling DMX_ProcessInput(*gmDMXReceiveBuffer, " + nReadLength + ", " + strB(bForceSave) + ")")
              DMX_ProcessInput(nDMXControlPtr, *gmDMXReceiveBuffer, nReadLength, bForceSave)
            EndIf
            If grDMX\bRequestNextImmediately = #False Or (ElapsedMilliseconds() - qTimeStart) > 250 ; timeout after 250ms if necessary
              Break
            EndIf
          Wend
        EndIf
      
      ;Case #SCS_DMX_DEV_ARTNET
      ;  If IsThread(ghArtnetThreadId)
      ;    LockMutex(ghArtnetRxMutex)
      ;    
      ;    If ListSize(ghArtnetRxList())
      ;      FirstElement(ghArtnetRxList())
      ;      DMX_ProcessInput(nDMXControlPtr, ghArtnetRxList()\aDmxDataArray + #ARTNET_BUFFER_SIZE, #ARTNET_DMX_BUFFER_SIZE, bForceSave)
      ;      DeleteElement(ghArtnetRxList())
      ;    EndIf
      ;    UnlockMutex(ghArtnetRxMutex)
      ;  EndIf
      ;  
      ;Case #SCS_DMX_DEV_SACN
      ;  *p_sACNRxBuffer = sACNDmxRxBuffer(gaDMXControl(nDMXControlPtr)\nDMXPort)
      ;  n_sACNDmxBufferSize = sACNDmxRxSize(gaDMXControl(nDMXControlPtr)\nDMXPort)
      ;  
      ;  If n_sACNDmxBufferSize
      ;      DMX_ProcessInput(nDMXControlPtr, *p_sACNRxBuffer + #SACN_DMX_DATA_OFFSET, #SACN_DMX_BUFFER_SIZE, bForceSave)
      ;  EndIf
      ;  
      ;Default 
    EndSelect
  EndIf
  ; debugMsg0(sProcName, #SCS_END)
EndProcedure

; decode a dmx input update packet, results go into the DMX_IN structure
Procedure DMX_ProcessUpdatePacket()
  CompilerIf #cTraceDMXUpdatePackets
    PROCNAMEC()
  CompilerEndIf
  
  ; modified 30Jan2018 11.8.0.2ae to include checking gbDMXChannelMonitored(nDMXChannel) to enable unwanted update packets to be discarded asap
  Protected changed_byte_index, bit_array_index, byteindex, nDMXChannel
  Protected bMonitoredOrCapturedChangeFound
  ; added the following 'first time' indicator because the calling procedure included this comment:
  ;    nb do NOT ignore the first #ENTTEC_DMX_INPUT_CHANGES message as this would ignore the first required message if all DMX values in the device are initially 0
  Static bFirstTime = #True
  
  ; debugMsg(sProcName, "DMXIN_Changes\byStart=" + DMXIN_Changes\byStart)
  
  ; IMPORTANT: See "Received DMX Change Of State Packet (Label=9)" in the Enttec document "dmx_usb_pro_api_03.pdf"
  ; ==============================================================================================================
  ; Size In Bytes       Description
  ;      1              Start changed byte number.
  ;      5              Changed bit array, where array bit 0 is bit 0 of first byte and array bit 39 is bit 7 of last byte.
  ;    1 To 40          Changed DMX Data byte Array. One byte is present for each set bit in the Changed bit array.
  
  For byteindex = 0 To 4
    For bit_array_index = 0 To 7
      ; now pointing to a bit that contains the change state of a DMX channel number when also applying the start changed byte number
      If IsBitSet(DMXIN_Changes\Bitfield[byteindex], bit_array_index)
        nDMXChannel = (DMXIN_Changes\byStart * 8) + ((byteindex * 8) + bit_array_index)
        If grDMX\bCaptureDMX
          If DMX_IN\ascData[nDMXChannel] <> DMXIN_Changes\ascData[changed_byte_index]
            ;debugMsg(sProcName, "setting DMX_IN\ascData[" + nDMXChannel + "]=" + DMXIN_Changes\ascData[changed_byte_index] + ", was " + DMX_IN\ascData[nDMXChannel])
            DMX_IN\ascData[nDMXChannel] = DMXIN_Changes\ascData[changed_byte_index]
            CompilerIf #cTraceDMXUpdatePackets
              debugMsg(sProcName, "changed " + Str((DMXIN_Changes\byStart * 8) + ((byteindex * 8) + bit_array_index)) + " = " + DMXIN_Changes\ascData[changed_byte_index])
            CompilerEndIf
            bMonitoredOrCapturedChangeFound = #True
            ; nb don't break because we need to find all 
          Else
            CompilerIf #cTraceDMXUpdatePackets
              debugMsg(sProcName, "no change " + Str((DMXIN_Changes\byStart * 8) + ((byteindex * 8) + bit_array_index)) + " = " + DMXIN_Changes\ascData[changed_byte_index])
            CompilerEndIf
          EndIf
        ElseIf gbDMXChannelMonitored(nDMXChannel) Or bFirstTime Or grDMX\bDMXTestWindowActive
          ; debugMsg(sProcName, "setting DMX_IN\ascData[" + nDMXChannel + "]=" + DMXIN_Changes\ascData[changed_byte_index] + ", was " + DMX_IN\ascData[nDMXChannel])
          DMX_IN\ascData[nDMXChannel] = DMXIN_Changes\ascData[changed_byte_index]
          CompilerIf #cTraceDMXUpdatePackets
            debugMsg(sProcName, "changed " + Str((DMXIN_Changes\byStart * 8) + ((byteindex * 8) + bit_array_index)) + " = " + DMXIN_Changes\ascData[changed_byte_index])
          CompilerEndIf
          bMonitoredOrCapturedChangeFound = #True
          ; nb don't break because we need to find all 
        Else
          CompilerIf #cTraceDMXUpdatePackets
            debugMsg(sProcName, "DMX Channel " + nDMXChannel + " not monitored")
          CompilerEndIf
        EndIf
        changed_byte_index + 1
      EndIf
    Next bit_array_index
  Next byteindex
  bFirstTime = #False
  
  ; Added 6Jan2021 11.8.3.4ai following emails from Stefano Ciriello, to minimize the time between calls to DMX_ProcessUpdatePacket() when only non-monitored channel updates are received
  If bMonitoredOrCapturedChangeFound = #False
    grDMX\bRequestNextImmediately = #True
  EndIf
  ; End added 6Jan2021 11.8.3.4ai
  
  ProcedureReturn bMonitoredOrCapturedChangeFound
  
EndProcedure

Procedure DMX_ProcessInput(nDMXControlPtr, *buffer, nBufferSize, bForceSave=#False)
  PROCNAMEC()
  ; process any data received from the widget...
  ; prerequisite: data has been read by DMX_USBRead, and the header has been filled
  Protected nResult
  Protected n, bIgnoreThisInput, bDataChange, ascStartCode.a, nMin, nMax, nLabel
  Protected nDataOffset = OffsetOf(Struct_RECV_DMX\ascData)
  
  CompilerIf #cTraceDMX
    debugMsg(sProcName, #SCS_START + ", nBufferSize=" + nBufferSize + ", Header\byLabel=" + decodeDMXAPILabel(Header\byLabel))
  CompilerEndIf
;   If (Header\byLabel = 5 And nBufferSize > 500 And nBufferSize < 550) Or (Header\byLabel = 9)
;     debugMsg(sProcName, #SCS_START + ", nBufferSize=" + nBufferSize + ", Header\byLabel=" + Header\byLabel)
;   EndIf
  
  ; check the type of packet we received
  nLabel = Header\byLabel
  Select nLabel
    Case #ENTTEC_RECEIVED_DMX_PORT1, #ENTTEC_RECEIVED_DMX_PORT2
      ; debugMsg(sProcName, "Received DMX, nDMXControlPtr=" + nDMXControlPtr + ", grDMX\nDMXCaptureControlPtr=" + grDMX\nDMXCaptureControlPtr + ", grDMX\nDMXCueControlPtr=" + grDMX\nDMXCueControlPtr)
      If nDMXControlPtr = grDMX\nDMXCaptureControlPtr
        If grDMX\bDMXSaveCapture
          If bForceSave
            DMX_SaveDMXPacketForCapture(nDMXControlPtr, *buffer, nBufferSize)
          Else
            DisableDebugger ; !!!!!!!!!! Debugger disabled to improve peformance whilst checking for a change in the DMX channel values
            ascStartCode = PeekA(*buffer+nDataOffset)
            nMin = ascStartCode + 1
            nMax = nBufferSize - nDataOffset - 2
            ; debugMsg(sProcName, "ascStartCode=" + ascStartCode + ", nMin=" + nMin + ", nMax=" +nMax)
            For n = nMin To nMax ; 1 To 512
              If PeekA(*buffer+nDataOffset+n) <> DMX_IN\ascData[n]
                bDataChange = #True
                ; debugMsg(sProcName, "bDataChange=" + strB(bDataChange) + ", n=" + n + ", PeekA(*buffer+" + Str(nDataOffset+n) + ")=" + PeekA(*buffer+nDataOffset+n) + ", DMX_IN\ascData[" + n + "]=" + DMX_IN\ascData[n])
                Break
              EndIf
            Next n
            EnableDebugger ; !!!!!!!!!! Debugger enabled again
            If bDataChange
              DMX_SaveDMXPacketForCapture(nDMXControlPtr, *buffer, nBufferSize)
            EndIf
          EndIf
        EndIf
      ElseIf nDMXControlPtr = grDMX\nDMXCueControlPtr
        ; Input is for 'Cue Control', not for 'Lighting Cue DMX Capture'
        If gaDMXControl(grDMX\nDMXCueControlPtr)\bDMXFirstReceive
          ; ignore the first #ENTTEC_DMX_INPUT message
          ; (we ignore the first label 5 message because otherwise any current non-zero DMX channel values may activate SCS controls, such as 'go')
          gaDMXControl(grDMX\nDMXCueControlPtr)\bDMXFirstReceive = #False
          debugMsg(sProcName, "gaDMXControl(" + grDMX\nDMXCueControlPtr + ")\bDMXFirstReceive=" + strB(gaDMXControl(grDMX\nDMXCueControlPtr)\bDMXFirstReceive))
          bIgnoreThisInput = #True
        EndIf
      EndIf
      If bIgnoreThisInput = #False
        DisableDebugger ; !!!!!!!!!! Debugger disabled to improve peformance whilst checking for a change in the DMX channel values
        ascStartCode = PeekA(*buffer+nDataOffset)
        nMin = ascStartCode + 1
        nMax = nBufferSize - nDataOffset - 2
        ; debugMsg(sProcName, "ascStartCode=" + ascStartCode + ", nMin=" + nMin + ", nMax=" +nMax)
        For n = nMin To nMax ; 1 To 512
          If PeekA(*buffer+nDataOffset+n) <> DMX_IN\ascData[n]
            bDataChange = #True
            ; debugMsg0(sProcName, "bDataChange=" + strB(bDataChange) + ", n=" + n + ", PeekA(*buffer+" + Str(nDataOffset+n) + ")=" + PeekA(*buffer+nDataOffset+n) + ", DMX_IN\ascData[" + n + "]=" + DMX_IN\ascData[n])
            Break
          EndIf
        Next n
        EnableDebugger ; !!!!!!!!!! Debugger enabled again
        If bDataChange Or grDMX\bDMXTestWindowFirstRead Or bForceSave
          ; copy the packet into the DMX_IN structute
          CopyMemory(*buffer, @DMX_IN, nBufferSize)
;           debugMsg(sProcName, "Status: " + DMX_IN\status)
;           debugMsg(sProcName, "Length: " + DMX_IN\Head\nLength)
;           debugMsg(sProcName, "channel1: " + DMX_IN\ascData[1])
          If nDMXControlPtr = grDMX\nDMXCueControlPtr
            CompilerIf #cTraceDMX
              debugMsg(sProcName, "calling DMX_addToStack()")
            CompilerEndIf
            DMX_addToStack()
            grDMX\bDMXTestWindowFirstRead = #False
          EndIf
        EndIf
        CompilerIf #cTraceDMX
          debugMsg3(sProcName, "finished processing " + decodeDMXAPILabel(nLabel) + " (label=" + nLabel + ")")
        CompilerEndIf
      EndIf
      
    Case #ENTTEC_GET_WIDGET_CFG_REPLY ; NOTE: we receive the widgets current config
      ; copy it into the PRO_INFO structure
      CopyMemory(*buffer, @PRO_INFO, nBufferSize)
      debugMsg(sProcName, "Enttec DMX USB PRO Version " + PRO_INFO\Firmware_VersionH + "." + PRO_INFO\Firmware_VersionL)
      debugMsg(sProcName, " \FPS: " + PRO_INFO\FrameRate + " BREAK: " + PRO_INFO\BreakTime + " MAB: " + PRO_INFO\MarkAfterBreak)
      debugMsg(sProcName, " \User Data Length: " + PRO_INFO\Head\nLength)
      
    Case #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1, #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2
      ; debugMsg(sProcName, "Change Of State, nDMXControlPtr=" + nDMXControlPtr + ", grDMX\nDMXCaptureControlPtr=" + grDMX\nDMXCaptureControlPtr + ", grDMX\bDMXSaveCapture=" + strB(grDMX\bDMXSaveCapture))
      If nDMXControlPtr = grDMX\nDMXCaptureControlPtr
        ; debugMsg(sProcName, "grDMX\bDMXSaveCapture=" + strB(grDMX\bDMXSaveCapture) + ", grDMX\qTimeFirstPacket9Received=" + traceTime(grDMX\qTimeFirstPacket9Received))
        If grDMX\bDMXSaveCapture
          CopyMemory(*buffer, @DMXIN_Changes, nBufferSize)
          If DMX_ProcessUpdatePacket()
            CompilerIf #cTraceDMX
              debugMsg(sProcName, "DMX_ProcessUpdatePacket() returned #True")
            CompilerEndIf
            If grDMX\qTimeFirstPacket9Received = 0
              grDMX\qTimeFirstPacket9Received = ElapsedMilliseconds()
              debugMsg(sProcName, "grDMX\qTimeFirstPacket9Received=" + traceTime(grDMX\qTimeFirstPacket9Received))
            EndIf
            DMX_SaveDMXPacketForCapture(nDMXControlPtr, *buffer, nBufferSize)
            If grDMX\bDMXCaptureSingleShot
              ; Include a delay in the following SAM request as there may be several 'change of state' messages for a snapshot, as each 'change of state' packet is limited to 40 consecutive DMX channels.
              ; Only the latest #SCS_SAM_DMX_CAPTURE_COMPLETE request (for nLabel) is kept.
              samAddRequest(#SCS_SAM_DMX_CAPTURE_COMPLETE, nLabel, 0, 0, "", ElapsedMilliseconds()+100)
            EndIf
          Else
            CompilerIf #cTraceDMX
              debugMsg(sProcName, "DMX_ProcessUpdatePacket() returned #False")
            CompilerEndIf
          EndIf
        EndIf
      ElseIf nDMXControlPtr = grDMX\nDMXCueControlPtr
        ; copy the packet into the structure
        CopyMemory(*buffer, @DMXIN_Changes, nBufferSize)
        ; decode the message
        CompilerIf #cTraceDMX And 1=2
          debugMsg3(sProcName, "calling DMX_ProcessUpdatePacket()")
        CompilerEndIf
        If DMX_ProcessUpdatePacket()  ; modified 30Jan2019 11.8.0.2ae to include 'If' condition so that changes to DMX channels that not being monitored can be discarded asap
          ; nb do NOT ignore the first #ENTTEC_DMX_INPUT_CHANGES message as this would ignore the first required message if all DMX values in the device are initially 0
          CompilerIf #cTraceDMX
            debugMsg(sProcName, "DMX_ProcessUpdatePacket() returned #True")
          CompilerEndIf
          CompilerIf #cTraceDMX
            debugMsg3(sProcName, "(label=9) calling DMX_addToStack()")
          CompilerEndIf
          DMX_addToStack()
          CompilerIf #cTraceDMX
            debugMsg3(sProcName, "finished processing #ENTTEC_DMX_INPUT_CHANGES (label=9)")
          CompilerEndIf
        Else
          CompilerIf #cTraceDMX
            debugMsg(sProcName, "DMX_ProcessUpdatePacket() returned #False")
          CompilerEndIf
        EndIf
      EndIf
    
    Case #FLASH_PAGE_REPLY ; NOTE: received success status of last firmware flash page sent
      CopyMemory(*buffer, @FIRMWARE_PAGE_REPLY, nBufferSize-1)
      
      If FIRMWARE_PAGE_REPLY\ascData[0] = Asc("T")
        If FIRMWARE_PAGE_REPLY\ascData[1] = Asc("R")
          If FIRMWARE_PAGE_REPLY\ascData[2] = Asc("U")
            If FIRMWARE_PAGE_REPLY\ascData[3] = Asc("E")
              ; last firmware page was written successfully
              ; write next page or done
              nResult = 254 ; return if success
            EndIf
          EndIf
        EndIf
      Else
        nResult = 255 ; return if flash failed
        ; stop sending flash pages, flashing failed
      EndIf
      
    Default ; NOTE: unknown packet
      debugMsg(sProcName, "Unknown Packet Type: " + Header\byLabel)
      nResult = 1
      
  EndSelect
  
  CompilerIf #cTraceDMX
    debugMsg(sProcName, #SCS_END + ", returning nResult=" + nResult)
  CompilerEndIf
  ProcedureReturn nResult
EndProcedure

Procedure DMX_USBRead(ftHandle.i, *byBuffer, nBufferSize)
  CompilerIf #cTraceFTCalls
    PROCNAMEC()
  CompilerEndIf
  ; read data
  Protected ftStatus.l, sftHandle.s
  Protected nBufferPtr, nLabel, nLength
  Protected qTimeOut.q, nTryCount
  
  With grUSBPRO
    
    \bytesread = 0
    If ftHandle
      CompilerIf #cTraceFTCalls
        sftHandle = decodeHandle(ftHandle)
      CompilerEndIf
      ; get length of rx queue
      If grDMX\bCaptureDMX ; Test added 14Mar2024 11.10.2bh to avoid excessive delays if only receiving DMX, not capturing
        ; qTimeOut = ElapsedMilliseconds() + 500 ; 2500 ; Changed from 2.5 seconds to 0.5 seconds 15Jul2023 11.10.0bq to reduce delay on stopping DMX Capture Sequence
        qTimeOut = ElapsedMilliseconds() + 200 ; Changed again 14Mar2024 11.10.2bh
        While ElapsedMilliseconds() < qTimeOut
          ftStatus = FT_GetQueueStatus(ftHandle, @\rxbytes)
          nTryCount + 1
          If \rxbytes > 0 : Break : EndIf
          ; Delay(10) ; Delay(200) ; Changed 21Jul2023 11.10.0bq
          Delay(5) ; Changed again 14Mar2024 11.10.2bh
        Wend
      Else
        ; Not capturing DMX
        ftStatus = FT_GetQueueStatus(ftHandle, @\rxbytes)
      EndIf
      CompilerIf #cTraceFTCalls
        If \rxbytes > 0
          debugMsg(sProcName, "FT_GetQueueStatus(" + sftHandle + ", @\rxbytes) returned ftStatus=" + decodeFTStatus(ftStatus) + ", \rxbytes=" + \rxbytes + ", nTryCount=" + nTryCount)
        EndIf
      CompilerEndIf
      If ftStatus <> #FT_OK
        ; failed
        debugMsg(sProcName, "Exiting because ftStatus=" + decodeFTStatus(ftStatus))
        ProcedureReturn -1
      EndIf
      If \rxbytes = 0
        ; debugMsg(sProcName, "Exiting because \rxBytes=" + \rxbytes)
        ProcedureReturn 0
      EndIf
      
      ; read first four bytes into the header structure
      ; ===============================================
      
      \timedout = #False
      \fatalerror = #False
      \totalbytesread = 0
      Repeat
        \bytesread = 0
        ftStatus = FT_Read(ftHandle, *byBuffer+nBufferPtr, (4 - \totalbytesread), @\bytesread) ; FT_Read for header
        CompilerIf #cTraceFTCalls
          If ftStatus = #FT_OK
            nLabel = PeekA(*byBuffer+1)
            nLength = PeekW(*byBuffer+2)
            Select nLabel
              Case #ENTTEC_RECEIVED_DMX_PORT1, #ENTTEC_RECEIVED_DMX_PORT2, #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1, #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2
                debugMsg(sProcName, "FT_Read(" + sftHandle + ", *byBuffer+" + nBufferPtr + ", " + Str(4 - \totalbytesread) + ", @\bytesread) returned " + decodeFTStatus(ftStatus) + ", \bytesread=" + \bytesread +
                                    ", $" + memoryToHexString(*byBuffer+nBufferPtr,\bytesread, #True) + ", label=" + decodeDMXAPILabel(nLabel) + ", length=" + nLength)
              Default
                debugMsg(sProcName, "FT_Read(" + sftHandle + ", *byBuffer+" + nBufferPtr + ", " + Str(4 - \totalbytesread) + ", @\bytesread) returned " + decodeFTStatus(ftStatus) + ", \bytesread=" + \bytesread +
                                    ", $" + memoryToHexString(*byBuffer+nBufferPtr,\bytesread, #True) + ", label=" + decodeDMXAPILabel(nLabel) + ", length=" + nLength)
            EndSelect
          Else
            debugMsg(sProcName, "FT_Read(" + sftHandle + ", *byBuffer+" + nBufferPtr + ", " + Str(4 - \totalbytesread) + ", @\bytesread) returned " + decodeFTStatus(ftStatus) + ", \bytesread=" + \bytesread)
          EndIf
        CompilerEndIf
        If (ftStatus = #FT_OK) Or (ftStatus = #FT_IO_ERROR)
          If \bytesread > 0 And (nBufferPtr + \bytesread) <= nBufferSize
            \totalbytesread + \bytesread
            nBufferPtr + \bytesread
          Else
            \timedout = #True
          EndIf
        Else
          \fatalerror = #True
        EndIf
      Until (\totalbytesread = 4) Or (\timedout = #True) Or (\fatalerror = #True)
      
      If (\timedout = #False) And (\fatalerror = #False)
        
        ; should now have header
        ; ======================
        CopyMemory(*byBuffer, @Header, SizeOf(Header))
        
        If Header\Delim = #ENTTEC_SOM
          ; header ok
          ; debugMsg(sProcName, "HEADER OK")
          
          ; ok read now the rest of the message,
          ; ====================================
          ; length + 1 we are using the length info from the header we just got..
          \timedout = #False
          \fatalerror = #False
          \totalbytesread = 0
          Repeat
            \bytesread = 0
            ftStatus = FT_Read(ftHandle, *byBuffer+nBufferPtr, Header\nLength+1-\totalbytesread, @\bytesread) ; FT_Read for rest of message
            CompilerIf #cTraceFTCalls
              If ftStatus = #FT_OK
                debugMsg(sProcName, "FT_Read(" + sftHandle + ", *byBuffer+" + nBufferPtr + ", " + Str(Header\nLength+1-\totalbytesread) + ", @\bytesread) returned " + decodeFTStatus(ftStatus) + ", \bytesread=" + \bytesread +
                                    ", $" + memoryToHexString(*byBuffer+nBufferPtr, \bytesread, #True))
              Else
                debugMsg(sProcName, "FT_Read(" + sftHandle + ", *byBuffer+" + nBufferPtr + ", " + Str(Header\nLength+1-\totalbytesread) + ", @\bytesread) returned " + decodeFTStatus(ftStatus) + ", \bytesread=" + \bytesread)
              EndIf
            CompilerEndIf
            If (ftStatus = #FT_OK) Or (ftStatus = #FT_IO_ERROR)
              If \bytesread > 0 And (nBufferPtr + \bytesread) <= nBufferSize
                \totalbytesread + \bytesread
                nBufferPtr + \bytesread
              Else
                \timedout = #True
              EndIf
            Else
              \fatalerror = #True
            EndIf
          Until (\totalbytesread = Header\nLength + 1) Or (\timedout = #True) Or (\fatalerror = #True)
          
          If (\timedout = #False) And (\fatalerror = #False)
            ; check if end of packet is valid
            If PeekA(*byBuffer+nBufferPtr-1) = #ENTTEC_EOM
              ; SUCCESS
              ; debugMsg(sProcName, "SUCCESS - returning " + nBufferPtr)
              ProcedureReturn nBufferPtr  ; return the length
            Else
              ; FAIL
            EndIf
          EndIf
        EndIf
      EndIf
    EndIf
    
  EndWith
  
  debugMsg(sProcName, "READ FAILED - returning -1")
  ProcedureReturn -1  ; indicates read failed
  
EndProcedure

; check if a bit is set in a byte
Procedure DMX_addToStack()
  PROCNAMEC()
  Protected bLockedMutex

  If grDMX\nDMXInCount > ArraySize(gaDMXIns())
    If grDMX\bTooManyDMXMessages = #False
      grDMX\bTooManyDMXMessages = #True
      WMN_setStatusField(Lang("DMX", "TooMany"), #SCS_STATUS_ERROR)
    EndIf
  Else
    scsLockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE, 5047)
    grDMX\bDMXInLocked = #True
    With gaDMXIns(grDMX\nDMXInCount)
      \rDMX_In = DMX_IN
      \bDone = #False
    EndWith
    grDMX\nDMXInCount + 1
    CompilerIf #cTraceDMX
      debugMsg3(sProcName, "grDMX\nDMXInCount=" + grDMX\nDMXInCount)
    CompilerEndIf
    grDMX\bDMXInLocked = #False
    scsUnlockMutex(gnDMXReceiveMutex, #SCS_MUTEX_DMX_RECEIVE)
  EndIf

EndProcedure

Procedure DMX_saveCueStartDMXSave(pCuePtr)
  PROCNAMECQ(pCuePtr)
  Protected sSQLRequest.s, nSQLResult, sPlayCue.s
  Protected nTempDatabaseNo, bLockedMutex, nBlobSize
  
  ; debugMsg(sProcName, #SCS_START)
  
  If grProd\bDoNotCalcCueStartValues = #False
    nTempDatabaseNo = grTempDB\nTempDatabaseNo
    If IsDatabase(nTempDatabaseNo)
      LockTempDatabaseMutex(81)
      sPlayCue = aCue(pCuePtr)\sCue
      ; delete any existing row for this cue
      sSQLRequest = "DELETE FROM CueStartDMXSave WHERE PlayCue = " + #DQUOTE$ + sPlayCue + #DQUOTE$
      nSQLResult = doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
      ; now save the current DMX values
      nBlobSize = ArraySize(gaDMXSendData()) ; gaDMXSendData array items are single variables of type .a so ArraySize(gaDMXSendData()) effectively returns the number of bytes in the array
      SetDatabaseBlob(nTempDatabaseNo, 0, @gaDMXSendData(), nBlobSize)
      sSQLRequest = "INSERT INTO CueStartDMXSave" +
                    " (PlayCue, DMXSaveBlob, DMXSaveBlobSize)" +
                    " VALUES ('" + sPlayCue + "', ?, " + nBlobSize + ")"
      nSQLResult = doDatabaseUpdate(nTempDatabaseNo, sSQLRequest) ; , #True)
      UnlockTempDatabaseMutex()
    EndIf ; EndIf IsDatabase(nTempDatabaseNo)
  EndIf ; EndIf grProd\bDoNotCalcCueStartValues = #False
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_clearCueStartDMXSave()
  PROCNAMEC()
  Protected sSQLRequest.s, nSQLResult
  Protected nTempDatabaseNo, bLockedMutex
  
  ; debugMsg(sProcName, #SCS_START)
  
  nTempDatabaseNo = grTempDB\nTempDatabaseNo
  If IsDatabase(nTempDatabaseNo)
    LockTempDatabaseMutex(82)
    sSQLRequest = "DELETE FROM CueStartDMXSave"
    nSQLResult = doDatabaseUpdate(nTempDatabaseNo, sSQLRequest)
    UnlockTempDatabaseMutex()
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_loadCueStartDMXSave(pCuePtr, bTrace=#False)
  PROCNAMECQ(pCuePtr)
  Protected bLoaded
  Protected sSQLRequest.s, nSQLResult, sPlayCue.s
  Protected nTempDatabaseNo, bLockedMutex, nBlobSize, nReadBlobSize
  
  debugMsgC(sProcName, #SCS_START)
  
  If grProd\bDoNotCalcCueStartValues = #False
    nTempDatabaseNo = grTempDB\nTempDatabaseNo
    If IsDatabase(nTempDatabaseNo)
      LockTempDatabaseMutex(83)
      sPlayCue = aCue(pCuePtr)\sCue
      nBlobSize = ArraySize(gaDMXSendData()) ; gaDMXSendData array items are single variables of type .a so ArraySize(gaDMXSendData()) effectively returns the number of bytes in the array
      SetDatabaseBlob(nTempDatabaseNo, 0, @gaDMXSendData(), nBlobSize)
      sSQLRequest = "SELECT DMXSaveBlob FROM CueStartDMXSave" +
                    " WHERE PlayCue = '" + sPlayCue + "'" +
                    " AND DMXSaveBlobSize = " + nBlobSize
      debugMsgC(sProcName, "(T) sSQLRequest=" + sSQLRequest)
      If DatabaseQuery(nTempDatabaseNo, sSQLRequest)
        If NextDatabaseRow(nTempDatabaseNo)  ; nb use 'If' not 'While' as there should only be one row returned (or none)
          nReadBlobSize = DatabaseColumnSize(grTempDB\nTempDatabaseNo, 0)
          If nReadBlobSize = nBlobSize
            ; should be #True
            If GetDatabaseBlob(nTempDatabaseNo, 0, @gaDMXSendData(), nBlobSize)
              bLoaded = #True
              debugMsg(sProcName, "bLoaded=" + strB(bLoaded))
            EndIf
          EndIf
        EndIf
        FinishDatabaseQuery(nTempDatabaseNo)
      EndIf ; EndIf DatabaseQuery(nTempDatabaseNo, sSQLRequest)
      UnlockTempDatabaseMutex()
    EndIf ; EndIf IsDatabase(nTempDatabaseNo)
  EndIf ; EndIf grProd\bDoNotCalcCueStartValues = #False
  
  debugMsgC(sProcName, #SCS_END + ", returning bLoaded=" + strB(bLoaded))
  ProcedureReturn bLoaded
  
EndProcedure

Procedure DMX_blackOutAll()
  PROCNAMEC()
  Protected nDMXControlPtr
  Protected nDMXDevPtr, nDMXPort, nDMXChannel
  Protected nDMXSendDataBaseIndex, nItemIndex
  Protected f
  Protected bLockedMutex
  
  debugMsg(sProcName, #SCS_START)
  
  LockDMXSendMutex(603)
  
  For nDMXControlPtr = 0 To  grDMX\nMaxDMXControl
    If gaDMXControl(nDMXControlPtr)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
      nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
      nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
      nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
      For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
        ; cancel any existing fade(s) for this DMX channel
        For f = 0 To grDMXFadeItems\nMaxFadeItem
          With grDMXFadeItems\aFadeItem(f)
            If \nDMXDevPtr = nDMXDevPtr And \nDMXPort = nDMXPort And \nDMXChannel = nDMXChannel
              If \bFadeCompleted = #False
                debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + f + ")\bFadeCompleted=#True")
              EndIf
              \bFadeCompleted = #True
              ; debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", grDMXFadeItems\aFadeItem(" + f + ")\bFadeCompleted=" + strB(grDMXFadeItems\aFadeItem(f)\bFadeCompleted))
            EndIf
          EndWith
        Next f
        gaDMXSendData(nItemIndex) = 0
        gaDMXSendOrigin(nItemIndex) = #SCS_DMX_ORIGIN_CUE
      Next nDMXChannel
    EndIf
  Next nDMXControlPtr
  
  debugMsg(sProcName, "calling DMX_setMaxFadeItem()")
  DMX_setMaxFadeItem()
  
  grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
  debugMsg(sProcName, "grDMX\bDMXReadyToSend=" + strB(grDMX\bDMXReadyToSend))
  
  UnlockDMXSendMutex()
  
  If gbInCalcCueStartValues = #False
    If THR_getThreadState(#SCS_THREAD_DMX_SEND) <> #SCS_THREAD_STATE_ACTIVE
      debugMsg3(sProcName, "calling THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)")
      THR_createOrResumeAThread(#SCS_THREAD_DMX_SEND)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_setDMXItemCount(pSubPtr)
  ; PROCNAMECS(pSubPtr)
  Protected nChaseStepIndex, nItemIndex
  Protected nMaxItemIndex
  
  ; debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If grProd\bLightingPre118
        For nChaseStepIndex = 0 To \nMaxChaseStepIndex
          nMaxItemIndex = -1
          For nItemIndex = 0 To ArraySize(\aChaseStep(nChaseStepIndex)\aDMXSendItem())
            If Trim(\aChaseStep(nChaseStepIndex)\aDMXSendItem(nItemIndex)\sDMXItemStr)
              nMaxItemIndex = nItemIndex
            EndIf
          Next nItemIndex
          \aChaseStep(nChaseStepIndex)\nDMXSendItemCount = nMaxItemIndex + 1
          ; debugMsg(sProcName, "\aChaseStep(" + nChaseStepIndex + ")\nDMXSendItemCount=" + \aChaseStep(nChaseStepIndex)\nDMXSendItemCount)
        Next nChaseStepIndex
      EndIf
      \nSubDuration = getSubLength(pSubPtr, #True)
      ; debugMsg(sProcName, "\nSubDuration=" + \nSubDuration)
    EndWith
  EndIf
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.l DMX_getDMXNumericSerial(device_num.l, *nSerial)
  ; Used exclusively in getConnectedDMXInDevs() so opens and closes the device (ie doesn't use a currently-open device)
  PROCNAMEC()
  Protected ftStatus.l
  Protected ftHandle.i, sftHandle.s
  Protected tries
  Protected Dim temp.a(3)
  Protected sSerial.s, nMySerial.l
  Protected size.w
  Protected bFTDIResult, bProcResult
  Protected RTimeout.l = 200
  Protected WTimeout.l = 150
  
  debugMsg(sProcName, #SCS_START + ", device_num=" + device_num)
  
  ; Try at least 3 times
  ftStatus = -1
  While ((ftStatus <> #FT_OK) And (tries < 3))
    ; Open the PRO 
    ftStatus = FT_Open(device_num, @ftHandle)
    If ftStatus = #FT_OK
      debugMsg(sProcName, "FT_Open(" + device_num + ", @ftHandle) returned " + decodeFTStatus(ftStatus) + ", ftHandle=" + ftHandle)
      Break
    Else
      debugMsg2(sProcName, "FT_Open(" + device_num + ", @ftHandle)", ftStatus)
    EndIf
    ; delay for next try
    Delay(750);
    tries + 1
  Wend
  If (ftStatus = #FT_OK)
    sftHandle = decodeHandle(ftHandle)
    ; Added 4Jan2022 11.9ac following isues reported by Beverley Grover
    ; Set Default Read & Write Timeouts (in milliseconds)
    ftStatus = FT_SetTimeouts(ftHandle, RTimeout, WTimeout)
    debugMsg2(sProcName, "FT_SetTimeouts(" + sftHandle + ", " + RTimeout + ", " + WTimeout + ")", ftStatus)
    ; Purge the buffer
    ftStatus = FT_Purge(ftHandle, #FT_PURGE_RX)
    debugMsg2(sProcName, "FT_Purge(" + sftHandle + ", #FT_PURGE_RX)", ftStatus)
    ; End added 4Jan2022 11.9ac
    ; GET PRO's serial number
    ; debugMsg(sProcName, "calling DMX_FTDI_SendData(" + sftHandle + ", #ENTTEC_GET_WIDGET_SN, @size, 2)")
    bFTDIResult = DMX_FTDI_SendData(ftHandle, #ENTTEC_GET_WIDGET_SN, @size, 2)
    debugMsg(sProcName, "DMX_FTDI_SendData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_SN) + ", @size, 2) returned " + strB(bFTDIResult))
    If bFTDIResult
      ; debugMsg(sProcName, "calling DMX_FTDI_ReceiveData(" + sftHandle + ", #ENTTEC_GET_WIDGET_SN, @temp(0), 4)")
      bFTDIResult = DMX_FTDI_ReceiveData(ftHandle, #ENTTEC_GET_WIDGET_SN, @temp(0), 4)
      debugMsg(sProcName, "DMX_FTDI_ReceiveData(" + sftHandle + ", " + decodeDMXAPILabel(#ENTTEC_GET_WIDGET_SN) + ", @temp(0), 4) returned " + strB(bFTDIResult))
      If bFTDIResult
        ; debugMsg(sProcName, "after #ENTTEC_GET_WIDGET_SN, temp(0)=$" + Hex(temp(0)) + ", temp(1)=$" + Hex(temp(1)) + ", temp(2)=$" + Hex(temp(2)) + ", temp(3)=$" + Hex(temp(3)))
        sSerial = hex2(temp(3)) + hex2(temp(2)) + hex2(temp(1)) + hex2(temp(0))
        If IsInteger(sSerial)
          nMySerial = Val(sSerial)
          PokeL(*nSerial, nMySerial)
          bProcResult = #True
        Else
          ; Added 19Feb2024 11.10.2aq following email from Chris Everhart where it now appears that the 'numeric' serial number is now not necessarily numeric
          ; so (temporarily?) treat as zero
          nMySerial = 0
          PokeL(*nSerial, nMySerial)
          bProcResult = #True
          ; End added 19Feb2024 11.10.2aq
        EndIf
        debugMsg(sProcName, "sSerial=" + sSerial + ", nMySerial=" + nMySerial)
      EndIf
      ftStatus = FT_Close(ftHandle)
      debugMsg2(sProcName, "FT_Close(" + sftHandle + ")", ftStatus)
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END + ", returning " + strB(bProcResult))
  ProcedureReturn bProcResult
EndProcedure

Procedure.l DMX_getDMXNumSerialForStrSerial(sDMXSerial.s)
  PROCNAMEC()
  Protected nDMXSerial.l
  Protected n
  
  If sDMXSerial
    For n = 0 To ArraySize(gaDMXDevice())
      If gaDMXDevice(n)\sSerial = sDMXSerial
        nDMXSerial = gaDMXDevice(n)\nSerial
        Break
      EndIf
    Next n
  EndIf
  ProcedureReturn nDMXSerial
EndProcedure

Procedure DMX_stopDMXFadesForSub(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  If pSubPtr >= 0
    For n = 0 To grDMXFadeItems\nMaxFadeItem
      If grDMXFadeItems\aFadeItem(n)\nSubPtr = pSubPtr
        CompilerIf #cTraceDMX Or #cTraceDMXSendChannels1to12
          If n < 13
            debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + n + ")\bFadeCompleted=#True for \nDMXChannel=" + grDMXFadeItems\aFadeItem(n)\nDMXChannel)
          EndIf
        CompilerElseIf #cTraceDMXSendChannels1to34
          If n < 35
            debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + n + ")\bFadeCompleted=#True for \nDMXChannel=" + grDMXFadeItems\aFadeItem(n)\nDMXChannel)
          EndIf
        CompilerEndIf
;         If grDMXFadeItems\aFadeItem(n)\bFadeCompleted = #False
;           debugMsg(sProcName, "setting grDMXFadeItems\aFadeItem(" + n + ")\bFadeCompleted=#True")
;         EndIf
        grDMXFadeItems\aFadeItem(n)\bFadeCompleted = #True
      EndIf
    Next n
    debugMsg(sProcName, "calling DMX_setMaxFadeItem()")
    DMX_setMaxFadeItem()
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getDefFadeTimeForProd(*rProd.tyProd)
  Protected nDefFadeTime
  
  With *rProd
    nDefFadeTime = \nDefDMXFadeTime
    If nDefFadeTime < 0
      nDefFadeTime = 0
    EndIf
  EndWith
  ProcedureReturn nDefFadeTime
EndProcedure

Procedure DMX_getFadeTimeForSubFadeFieldAction(nFadeField, nFadeAction, *rSub.tySub, *rProd.tyProd, pCallCueSubPtr=-1)
  PROCNAMEC()
  ; nb procedure is recursive, ie it may call itself
  Protected nFadeTime, bProcessThis
  Static nCallDepth
  
  ; debugMsg(sProcName, *rSub\sSubLabel + ": " + #SCS_START + ", nFadeField=" + nFadeField + ", nFadeAction=" + decodeDMXFadeActionFI(nFadeAction) + ", nCallDepth=" + nCallDepth)
  
  nCallDepth + 1
  With *rSub
    If \nCueIndex < 0 Or grCFH\bReadingSecondaryCueFile
      bProcessThis = #True
    ElseIf aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
      bProcessThis = #True
    EndIf
    If bProcessThis
      Select \nLTEntryType
        Case #SCS_LT_ENTRY_TYPE_BLACKOUT
          Select nFadeAction
            Case #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
              nFadeTime = DMX_getDefFadeTimeForProd(*rProd)
            Case #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
              nFadeTime = getValueForNumericParameter(*rSub, \nLTBLFadeUserTime, \sLTBLFadeUserTime, 3, pCallCueSubPtr)
            Default
              ; debugMsg0(sProcName, "nFadeAction=" + nFadeAction + " (" + decodeDMXFadeActionFI(nFadeAction) + ")")
          EndSelect
          
        Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
          
        Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
          Select nFadeAction
            Case #SCS_DMX_DC_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
              nFadeTime = DMX_getDefFadeTimeForProd(*rProd)
            Case #SCS_DMX_DC_FADE_ACTION_USER_DEFINED_TIME
              Select nFadeField
                Case #SCS_DMX_FADE_FIELD_DC_FADEUP
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTDCFadeUpUserTime, \sLTDCFadeUpUserTime, 3, pCallCueSubPtr)
                Case #SCS_DMX_FADE_FIELD_DC_FADEDOWN
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTDCFadeDownUserTime, \sLTDCFadeDownUserTime, 3, pCallCueSubPtr)
              EndSelect
          EndSelect
          
        Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
          Select nFadeAction
            Case #SCS_DMX_DI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
              nFadeTime = DMX_getDefFadeTimeForProd(*rProd)
            Case #SCS_DMX_DI_FADE_ACTION_USE_FADEUP_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEUP, *rSub\nLTDIFadeUpAction, *rSub, *rProd)
            Case #SCS_DMX_DI_FADE_ACTION_USE_FADEDOWN_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEDOWN, *rSub\nLTDIFadeDownAction, *rSub, *rProd)
            Case #SCS_DMX_DI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS, *rSub\nLTDIFadeOutOthersAction, *rSub, *rProd)
            Case #SCS_DMX_DI_FADE_ACTION_USER_DEFINED_TIME
              Select nFadeField
                Case #SCS_DMX_FADE_FIELD_DI_FADEUP
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTDIFadeUpUserTime, \sLTDIFadeUpUserTime, 3, pCallCueSubPtr)
                Case #SCS_DMX_FADE_FIELD_DI_FADEDOWN
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTDIFadeDownUserTime, \sLTDIFadeDownUserTime, 3, pCallCueSubPtr)
                Case #SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTDIFadeOutOthersUserTime, \sLTDIFadeOutOthersUserTime, 3, pCallCueSubPtr)
              EndSelect
            Case #SCS_DMX_DI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              ; no action
            Default
              ; debugMsg0(sProcName, *rSub\sSubLabel + ": nFadeAction=" + nFadeAction + " (" + decodeDMXFadeActionDI(nFadeAction) + ")")
          EndSelect
          
        Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
          Select nFadeAction
            Case #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
              nFadeTime = DMX_getDefFadeTimeForProd(*rProd)
            Case #SCS_DMX_FI_FADE_ACTION_USE_FADEUP_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEUP, *rSub\nLTFIFadeUpAction, *rSub, *rProd)
            Case #SCS_DMX_FI_FADE_ACTION_USE_FADEDOWN_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEDOWN, *rSub\nLTFIFadeDownAction, *rSub, *rProd)
            Case #SCS_DMX_FI_FADE_ACTION_USE_FADEOUTOTHERS_TIME
              nFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, *rSub\nLTFIFadeOutOthersAction, *rSub, *rProd)
            Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
              Select nFadeField
                Case #SCS_DMX_FADE_FIELD_FI_FADEUP
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTFIFadeUpUserTime, \sLTFIFadeUpUserTime, 3, pCallCueSubPtr)
                Case #SCS_DMX_FADE_FIELD_FI_FADEDOWN
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTFIFadeDownUserTime, \sLTFIFadeDownUserTime, 3, pCallCueSubPtr)
                Case #SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS
                  nFadeTime = getValueForNumericParameter(*rSub, \nLTFIFadeOutOthersUserTime, \sLTFIFadeOutOthersUserTime, 3, pCallCueSubPtr)
              EndSelect
            Case #SCS_DMX_FI_FADE_ACTION_DO_NOT_FADEOUTOTHERS
              ; no action
            Default
              ; debugMsg0(sProcName, *rSub\sSubLabel + ": nFadeAction=" + nFadeAction + " (" + decodeDMXFadeActionFI(nFadeAction) + ")")
          EndSelect
          
      EndSelect
    EndIf ; EndIf aCue(\nCueIndex)\nActivationMethod <> #SCS_ACMETH_EXT_FADER
  EndWith
  
  If nFadeTime < 0
    ; mainly to convert -2 (the SCS convention for 'blank') to 0
    nFadeTime = 0
  EndIf
  
  nCallDepth - 1
  ; debugMsg(sProcName, *rSub\sSubLabel + ": " + #SCS_END + ", returning nFadeTime=" + nFadeTime + ", nCallDepth=" + nCallDepth)
  ProcedureReturn nFadeTime
EndProcedure

Procedure DMX_getSubLength(*rSub.tySub, *rProd.tyProd, pCallCueSubPtr=-1)
  PROCNAMEC()
  Protected nSubLength, nThisFadeTime, nMaxFadeTime
  
  With *rSub
    Select \nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_BLACKOUT
        nMaxFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_BL_FADE, \nLTBLFadeAction, *rSub, *rProd, pCallCueSubPtr)
        
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
        
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        nMaxFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEUP, \nLTDCFadeUpAction, *rSub, *rProd, pCallCueSubPtr)
        nThisFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEDOWN, \nLTDCFadeDownAction, *rSub, *rProd, pCallCueSubPtr)
        If nThisFadeTime > nMaxFadeTime : nMaxFadeTime = nThisFadeTime : EndIf
        
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
        nMaxFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEUP, \nLTDIFadeUpAction, *rSub, *rProd, pCallCueSubPtr)
        nThisFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEDOWN, \nLTDIFadeDownAction, *rSub, *rProd, pCallCueSubPtr)
        If nThisFadeTime > nMaxFadeTime : nMaxFadeTime = nThisFadeTime : EndIf
        nThisFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS, \nLTDIFadeOutOthersAction, *rSub, *rProd)
        If nThisFadeTime > nMaxFadeTime : nMaxFadeTime = nThisFadeTime : EndIf
        
      Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        nMaxFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEUP, \nLTFIFadeUpAction, *rSub, *rProd, pCallCueSubPtr)
        nThisFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEDOWN, \nLTFIFadeDownAction, *rSub, *rProd, pCallCueSubPtr)
        If nThisFadeTime > nMaxFadeTime : nMaxFadeTime = nThisFadeTime : EndIf
        nThisFadeTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, \nLTFIFadeOutOthersAction, *rSub, *rProd, pCallCueSubPtr)
        If nThisFadeTime > nMaxFadeTime : nMaxFadeTime = nThisFadeTime : EndIf
        
    EndSelect
    nSubLength = nMaxFadeTime ; The 'length' of a lighting sub-cue is solely dependent on the maximum of:
                              ;   Fade up time for fixtures that need to be faded up
                              ;   Fade down time for fixtures that need to be faded down
                              ;   Fade out time for other active fixtures
                              ; or equivalents for non-fixture lighting sub-cues
  EndWith
  
  ProcedureReturn nSubLength
EndProcedure

Procedure DMX_getDefFadeTimeForSub(*rSub.tySub, *rProd.tyProd)
  Protected nDefFadeTime = -1
  
  With *rSub
    Select \nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_BLACKOUT
        Select \nLTBLFadeAction
          Case #SCS_DMX_BL_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
            nDefFadeTime = DMX_getDefFadeTimeForProd(*rProd)
          Case #SCS_DMX_BL_FADE_ACTION_USER_DEFINED_TIME
            nDefFadeTime = \nLTBLFadeUserTime
        EndSelect
;       Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE
;       Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
;       Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
;         Select \nLTFIFadeDownAction
;           Case #SCS_DMX_FI_FADE_ACTION_USE_PROD_RUNTIME_DEFAULT
;             nDefFadeTime = DMX_getDefFadeTimeForProd(*rProd)
;           Case #SCS_DMX_FI_FADE_ACTION_USER_DEFINED_TIME
;             nDefFadeTime = \nLTDefFadeUserTime
;           Default
;             nDefFadeTime = 0
;         EndSelect
        If nDefFadeTime < 0
          nDefFadeTime = 0
        EndIf
    EndSelect
  EndWith
  ProcedureReturn nDefFadeTime
EndProcedure

Procedure DMX_getFadeOutOthersTimeForSub(*rSub.tySub, *rProd.tyProd)
  Protected nFadeOutOthersTime = -2
  
  With *rSub
    Select \nLTEntryType
      Case #SCS_LT_ENTRY_TYPE_BLACKOUT
        
      Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        nFadeOutOthersTime = 0
        
      Case #SCS_LT_ENTRY_TYPE_DMX_ITEMS
        nFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DI_FADEOUTOTHERS, \nLTDIFadeOutOthersAction, *rSub, *rProd)
        If nFadeOutOthersTime < 0
          nFadeOutOthersTime = 0
        EndIf
        
      Case #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        nFadeOutOthersTime = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_FI_FADEOUTOTHERS, \nLTFIFadeOutOthersAction, *rSub, *rProd)
        If nFadeOutOthersTime < 0
          nFadeOutOthersTime = 0
        EndIf
    EndSelect
  EndWith
  
  ProcedureReturn nFadeOutOthersTime
EndProcedure

Procedure DMX_redimDMXArraysIfRequired()
  PROCNAMEC()
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort
  Protected nReqdOutArraySize
  Protected nTmp, nMaxDMXSendDataBaseIndex
  
  debugMsg(sProcName, #SCS_START)
  
  For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
    With gaDMXControl(nDMXControlPtr)
      debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\sDMXName=" + \sDMXName + ", \sDMXSerial=" + \sDMXSerial + ", \nDMXDevPtr=" + \nDMXDevPtr + ", \nDMXPort=" + \nDMXPort + ", \bExists=" + strB(\bExists))
      If \bExists
        Select \nDevType
          Case #SCS_DEVTYPE_LT_DMX_OUT
            nDMXDevPtr = \nDMXDevPtr
            nDMXPort = \nDMXPort
            nTmp = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
            ; debugMsg(sProcName, "nTmp=" + nTmp)
            If nTmp > nMaxDMXSendDataBaseIndex
              nMaxDMXSendDataBaseIndex = nTmp
            EndIf
        EndSelect
      EndIf
    EndWith
  Next nDMXControlPtr
  
  nReqdOutArraySize = nMaxDMXSendDataBaseIndex + 512
  debugMsg(sProcName, "nMaxDMXSendDataBaseIndex=" + nMaxDMXSendDataBaseIndex + ", nReqdOutArraySize=" + nReqdOutArraySize)
  
  If nReqdOutArraySize > ArraySize(gaDMXSendData())
    doRedim(gaDMXSendData, nReqdOutArraySize, "gaDMXSendData")
  EndIf
  If nReqdOutArraySize > ArraySize(gaDMXSendOrigin())
    doRedim(gaDMXSendOrigin, nReqdOutArraySize, "gaDMXSendOrigin")
  EndIf
  If nReqdOutArraySize > ArraySize(gbDMXDimmableChannel())
    doRedim(gbDMXDimmableChannel, nReqdOutArraySize, "gbDMXDimmableChannel")
  EndIf
  If nReqdOutArraySize > ArraySize(grDMXChannelItems\aDMXChannelItem())
    debugMsg(sProcName, "ArraySize(grDMXChannelItems\aDMXChannelItem())=" + ArraySize(grDMXChannelItems\aDMXChannelItem()) + ", nReqdOutArraySize=" + nReqdOutArraySize)
    doRedim(grDMXChannelItems\aDMXChannelItem, nReqdOutArraySize, "grDMXChannelItems\aDMXChannelItem")
  EndIf
  If nReqdOutArraySize > ArraySize(grDMXFadeItems\aFadeItem())
    doRedim(grDMXFadeItems\aFadeItem, nReqdOutArraySize, "grDMXFadeItems\aFadeItem")
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_setDMXControlPtrForSub(pSubPtr)
  PROCNAMEC()
  
  If pSubPtr >= 0
    With aSub(pSubPtr)
      If \bSubTypeK
        \nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(#SCS_DEVTYPE_LT_DMX_OUT, \sLTLogicalDev)
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure DMX_setDMXControlPtrsForAllSubs()
  PROCNAMEC()
  Protected i, j
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeK
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubEnabled
          DMX_setDMXControlPtrForSub(j)
        EndIf
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf
  Next i
  
EndProcedure

Procedure DMX_displayDMXAllFixturesData()
PROCNAMEC()
  Protected nDevNo, nProdLTFixtureIndex, nFixTypeIndex, nFixtureChannelIndex, nChannelIndex, nDevMapDevPtr, nDMXStartChannel, nDevMapFixtureIndex, nDevStartChannelIndex
  Protected nRow, nCol, nCellValue, nCellBackColor
  Protected nLeft, nTop
  Protected nArraySize, nSendDataIndex
  Protected sText.s, sRowTitle.s, nRowTitleWidth, nMaxRowTitleWidth, sMaxRowTitle.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  With grWDD
    For nDevNo = 0 To grProd\nMaxLightingLogicalDev
      If grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev = \sLTLogicalDev
        For nProdLTFixtureIndex = 0 To grProd\aLightingLogicalDevs(nDevNo)\nMaxFixture   ; Loop through all the fixtures in this device                  
          nLeft = 4
          If \bDMXDisplayFirstCall
            ; Display row title and draw lines
            sText = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nProdLTFixtureIndex)\sFixtureCode
            If grProd\aLightingLogicalDevs(nDevNo)\aFixture(nProdLTFixtureIndex)\sFixtureDesc
              sText + " (" + grProd\aLightingLogicalDevs(nDevNo)\aFixture(nProdLTFixtureIndex)\sFixtureDesc + ")"
            EndIf
            sRowTitle = compactTextForCanvas(sText, \nTitleWidth)
            nTop = ((nProdLTFixtureIndex) * \nRowHeight) + \nTopMargin + 1
            DrawText(nLeft, nTop, sRowTitle, #SCS_Black)
            If grMemoryPrefs\bDMXShowGridLines
              LineXY(0, nTop+\nRowHeight-2, \nTitleWidth, nTop+\nRowHeight-2, #SCS_Light_Grey)   ; TD Horiontal lines
            EndIf
            ; get the index in the DMX array for this fixture:
          EndIf
          ; Get the DMX Start Channel(s) for this Fixture:
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev)
          nDMXStartChannel = 1
          If nDevMapDevPtr >= 0
            For nDevMapFixtureIndex = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
              If grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevMapFixtureIndex)\sDevFixtureCode = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nProdLTFixtureIndex)\sFixtureCode
                nFixtureChannelIndex = -1
                For nDevStartChannelIndex = 0 To grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevMapFixtureIndex)\nMaxDevStartChannelIndex
                  If nDevStartChannelIndex & 1
                     ; slightly darker cell background to help identify the different DMX Start Channel fixture groups
                    nCellBackColor = \nCanvasBackColor2
                  Else
                    ; normal cell background color
                    nCellBackColor = \nCanvasBackColor1
                  EndIf
                  nDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevMapFixtureIndex)\aDevStartChannel(nDevStartChannelIndex)
                  ; Now get the channels for this Fixture, by first of all locating the fixture type in the grProd\aFixTypes array
                  For nFixTypeIndex = 0 To grProd\nMaxFixType
                    If grProd\aFixTypes(nFixTypeIndex)\sFixTypeName = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nProdLTFixtureIndex)\sFixTypeName
                      For nChannelIndex = 0 To (grProd\aFixTypes(nFixTypeIndex)\nTotalChans - 1)
                        If grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChannelIndex)\nChanNo > 0
                          nFixtureChannelIndex + 1
                          nSendDataIndex = \nDMXSendDataBaseIndex + nDMXStartChannel + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChannelIndex)\nChanNo - 1
                          ; Base index for this Dev + Fixed Start + Fixture Channel - 1
                          If \bDMXDisplayFirstCall Or gaDMXSendData(nSendDataIndex) <> grWDD\aPrevDMXSendData(nSendDataIndex)
                            nCellValue = gaDMXSendData(nSendDataIndex)
                            If grMemoryPrefs\nDMXDisplayPref = #SCS_DMX_NOTATION_PERCENT
                              nCellValue / 2.55
                            EndIf
                            If \bDMXDisplayFirstCall Or nCellValue <> \aPrevDMXSendData(nSendDataIndex)
                              nRow = nProdLTFixtureIndex
                              nCol = nFixtureChannelIndex
                              nLeft = (nCol * \nColWidth) + \nTitleWidth + 4
                              nTop = (nRow * \nRowHeight) + \nTopMargin + 1
                              ; If nDevStartChannelIndex & 1
                                ; an 'even-numbered' cell (nb nDevStartChannelIndex starts from 0)
                                Box(nLeft-3, nTop-2, \nColWidth-1, \nRowHeight, nCellBackColor)
                              ; EndIf
                              If grMemoryPrefs\bDMXShowGridLines
                                ; Draw 3 lines: Top, Bottom and Right.  Left will reuse the right from the cell to the left.  We may or may not have a cell above.                      
                                If nTop > \nTopMargin + 1
                                  LineXY(nLeft-4, nTop-2, nLeft+\nColWidth-4, nTop-2, #SCS_Light_Grey)                        ; Line to the Top of the cell (skip the top row)
                                EndIf
                                LineXY(nLeft-4, nTop+\nRowHeight-2, nLeft+\nColWidth-4, nTop+\nRowHeight-2, #SCS_Light_Grey)  ; Line to the Bottom of the cell
                                LineXY(nLeft+\nColWidth-4, nTop-1, nLeft+\nColWidth-4, nTop+\nRowHeight-3, #SCS_Light_Grey)   ; Line to the Right of the cell
                              EndIf
                              DMX_displayDMXText(nLeft, nTop, nCellValue, grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChannelIndex)\nDMXTextColor, nCellBackColor)
                            EndIf ; EndIf \bDMXDisplayFirstCall Or nCellValue <> \aPrevDMXSendData(nSendDataIndex)
                          EndIf ; EndIf \bDMXDisplayFirstCall Or gaDMXSendData(nSendDataIndex) <> grWDD\aPrevDMXSendData(nSendDataIndex)
                        EndIf ; EndIf grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChannelIndex)\nChanNo > 0
                      Next nChannelIndex
                      Break ; Break nFixTypeIndex
                    EndIf ; EndIf grProd\aFixTypes(nFixTypeIndex)\sFixTypeName = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixTypeName
                  Next nFixTypeIndex
                Next nDevStartChannelIndex
                Break ; Break nDevMapFixtureIndex
              EndIf ; EndIf grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevMapFixtureIndex)\sDevFixtureCode = grProd\aLightingLogicalDevs(nDevNo)\aFixture(nFixtureIndex)\sFixtureCode
            Next nDevMapFixtureIndex
          EndIf ; EndIf nDevMapDevPtr >= 0
        Next nProdLTFixtureIndex
      EndIf ; EndIf grProd\aLightingLogicalDevs(nDevNo)\sLogicalDev = \sLTLogicalDev
    Next nDevNo
  EndWith
  
EndProcedure

Procedure DMX_displayDMXText(nLeft, nTop, nCellValue, nTextColor.l, nCanvasBackColor.l)
  PROCNAMEC()
  ; procedure to show text and handle the color
  Protected sCellValue.s, nDrawLeft
  Static nCharWidth
  
  ; The code below sets nDrawLeft to enable the cell value to be right-justified in the display.
  ; Cell values are in the range 0 - 255 so are no more than 3 digits.
  ; Originally tried just right-justifying sCellValue using RSet(nCellValue,3) but space characters displayed with the selected font
  ; are shorter than digit characters, so the displayed value was not fully right-justifed. Didn't want to change to a fixed-pitch font.
  If nCharWidth = 0
    nCharWidth = TextWidth("0")
  EndIf
  sCellValue = Str(nCellValue)
  If nCellValue < 10
    nDrawLeft = nLeft + nCharWidth + nCharWidth
  ElseIf nCellValue < 100
    nDrawLeft = nLeft + nCharWidth
  Else
    nDrawLeft = nLeft
  EndIf
  
  ; Now draw the cell value
  ; debugMsg(sProcName, "nCellValue=" + nCellValue + ", sCellValue=" + sCellValue + ", nTextColor=$" + Hex(nTextColor,#PB_Long) + ", grFixTypeChanDef\nDMXTextColor=$" + Hex(grFixTypeChanDef\nDMXTextColor,#PB_Long))
  If nTextColor <> grFixTypeChanDef\nDMXTextColor ; nb grFixTypeChanDef\nDMXTextColor = -1
    DrawText(nDrawLeft, nTop, sCellValue, nTextColor, nCanvasBackColor)
  ElseIf nCellValue = 0
    DrawText(nDrawLeft, nTop, sCellValue, #SCS_Dark_Grey, nCanvasBackColor)
  Else
    DrawText(nDrawLeft, nTop, sCellValue, #SCS_Black, nCanvasBackColor)
  EndIf
EndProcedure

Procedure DMX_displayDMXSendData()
  PROCNAMEC()
  Protected nDevNo, nFixtureIndex, nFixTypeIndex, nChannelIndex, nDevMapDevPtr, nDMXStartChannel, nDevMapFixtureIndex
  Protected m, n, nRow, nCol, nCellValue
  Protected nLeft, nTop
  Protected nArraySize, nFixtureCount
  Protected sRowTitle.s
  
  ; debugMsg(sProcName, #SCS_START)
  
  ; Added 31Jul2020 11.8.3.2ap
  ; Added following a test where clicking the 'Reset' button in WQK the program locked up in WQK_doLiveDMXTestIfReqd() on LockDMXSendMutex(789).
  ; I don't know why, and it only occurs when the DMX Display window exists, and this didn't occur in SCS 11.8.3.1.
  ; However, by issuing ProcedureReturn immediately, the program continues OK, and this procedure - DMX_displayDMXSendData() - gets called
  ; regularly anyway by the DMX Send Thread.
  If grWQK\bProcessingReset
    ProcedureReturn
  EndIf
  ; End added 31Jul2020 11.8.3.2ap
  
  ; Added 24Jun2021 11.8.5an
  grDMX\bCallDisplayDMXSendData = #False
  If gbClosingDown
    ProcedureReturn
  EndIf
  ASSERT_THREAD(#SCS_THREAD_MAIN)
  ; End added 24Jun2021 11.8.5an
  
  With grWDD
    ; debugMsg0(sProcName, "grWDD\bDMXDisplayActive=" + strB(\bDMXDisplayActive) + ", \bDMXDisplayFirstCall=" + strB(\bDMXDisplayFirstCall) + ", \nDMXSendDataBaseIndex=" + \nDMXSendDataBaseIndex)
    If \bDMXDisplayActive
      If \bDMXDisplayFirstCall
        WDD_setCanvasSize() ; Must be called BEFORE StartDrawing()
      EndIf
    
      If StartDrawing(CanvasOutput(WDD\cvsDMXDisplay))
        scsDrawingFont(#SCS_FONT_GEN_NORMAL9) ; Changed 20Nov2024 11.10.6bm
        If \bDMXDisplayFirstCall
          ; debugMsg(sProcName, "grWDD\bDMXDisplayFirstCall=" + strB(\bDMXDisplayFirstCall) + ", grMemoryPrefs\nDMXGridType=" + decodeDMXGridType(grMemoryPrefs\nDMXGridType))
          If grMemoryPrefs\nDMXGridType = #SCS_DMX_GRIDTYPE_UNIVERSE
            ; initial drawing of grid
            Box(0, 0, \nCanvasWidth, \nCanvasHeight, \nCanvasBackColor1)
            DrawingMode(#PB_2DDrawing_Transparent)
            \nTitleWidth = TextWidth("888-888xx") ; Also used in WDD_setCanvasSize() in fmDMXDisplay.pbi
            nLeft = 4
            For n = 1 To 16
              m = ((n - 1) * 32) + 1
              sRowTitle = Str(m) + "-" + Str(m+31)
              nTop = ((n-1) * \nRowHeight) + \nTopMargin + 1
              DrawText(nLeft, nTop, sRowTitle, #SCS_Black)
              If grMemoryPrefs\bDMXShowGridLines
                LineXY(0, nTop+\nRowHeight-2, \nCanvasWidth, nTop+\nRowHeight, #SCS_Light_Grey)
              EndIf
            Next n
            If grMemoryPrefs\bDMXShowGridLines
              For m = 1 To 33 ; 33 not 32, to draw vertical line after last (32nd) column
                nLeft = ((m-1) * \nColWidth) + \nTitleWidth
                LineXY(nLeft, 1, nLeft, (\nCanvasHeight-2), #SCS_Light_Grey)
              Next m
            EndIf
            ; end of initial drawing of grid
            nArraySize = ArraySize(gaDMXSendData())
            If ArraySize(\aPrevDMXSendData()) <> nArraySize
              ReDim \aPrevDMXSendData(nArraySize)
            EndIf
            
            For m = 1 To 512
              nRow = (m-1) >> 5   ; equivalent to "Round((m-1) / 32, #PB_Round_Down)"
              nCol = (m-1) - (nRow << 5)
              nCellValue = gaDMXSendData(\nDMXSendDataBaseIndex + m)
              If grMemoryPrefs\nDMXDisplayPref = #SCS_DMX_NOTATION_PERCENT
                nCellValue / 2.55
              EndIf
              nLeft = (nCol * \nColWidth) + \nTitleWidth + 4
              nTop = (nRow * \nRowHeight) + \nTopMargin + 1
              Box(nLeft, nTop, \nColWidth - 5, \nRowHeight - 5, \nCanvasBackColor1)
              If nCellValue = 0
                DMX_displayDMXText(nLeft, nTop, nCellValue, gnDMXTextColorsZero(\nDMXSendDataBaseIndex + m), \nCanvasBackColor1)
              Else
                DMX_displayDMXText(nLeft, nTop, nCellValue, gnDMXTextColorsNonZero(\nDMXSendDataBaseIndex + m), \nCanvasBackColor1)
              EndIf
            Next m
            
          ElseIf grMemoryPrefs\nDMXGridType = #SCS_DMX_GRIDTYPE_ALL_FIXTURES            
            ; Draw Fixtures option
            ; initial drawing of grid
            
            Box(0, 0, \nCanvasWidth, \nCanvasHeight, \nCanvasBackColor1)
            DrawingMode(#PB_2DDrawing_Transparent)
            
            If grMemoryPrefs\bDMXShowGridLines
              ; TD Draw vertical lines
              LineXY(\nTitleWidth, 1, \nTitleWidth, (\nCanvasHeight-2), #SCS_Light_Grey)  ; Just draw the first vertical line now
            EndIf
            
            DMX_displayDMXAllFixturesData()
            
            ; end of initial drawing of grid
            nArraySize = ArraySize(gaDMXSendData())
            If ArraySize(\aPrevDMXSendData()) <> nArraySize
              ReDim \aPrevDMXSendData(nArraySize)
            EndIf          
          EndIf
          \bDMXDisplayFirstCall = #False
        Else
          ; Not the first time
          ; debugMsg(sProcName, "grWDD\bDMXDisplayFirstCall=" + strB(\bDMXDisplayFirstCall) + ", grMemoryPrefs\nDMXGridType=" + decodeDMXGridType(grMemoryPrefs\nDMXGridType))
          If grMemoryPrefs\nDMXGridType = #SCS_DMX_GRIDTYPE_UNIVERSE
            For m = 1 To 512
              If gaDMXSendData(\nDMXSendDataBaseIndex + m) <> \aPrevDMXSendData(\nDMXSendDataBaseIndex + m)
                nRow = (m-1) >> 5   ; Equivalent to "Round((m-1) / 32, #PB_Round_Down)". There are 32 columns per row.
                nCol = (m-1) - (nRow << 5)
                nCellValue = gaDMXSendData(\nDMXSendDataBaseIndex + m)
                If grMemoryPrefs\nDMXDisplayPref = #SCS_DMX_NOTATION_PERCENT
                  nCellValue = nCellValue / 2.55
                EndIf
                nLeft = (nCol * \nColWidth) + \nTitleWidth + 4
                nTop = (nRow * \nRowHeight) + \nTopMargin + 1
                Box(nLeft, nTop, \nColWidth - 5, \nRowHeight - 5, \nCanvasBackColor1)
                If nCellValue = 0
                  DMX_displayDMXText(nLeft, nTop, nCellValue, gnDMXTextColorsZero(\nDMXSendDataBaseIndex + m), \nCanvasBackColor1)
                Else
                  DMX_displayDMXText(nLeft, nTop, nCellValue, gnDMXTextColorsNonZero(\nDMXSendDataBaseIndex + m), \nCanvasBackColor1)
                EndIf
              EndIf
            Next m            
          ElseIf grMemoryPrefs\nDMXGridType = #SCS_DMX_GRIDTYPE_ALL_FIXTURES
            DMX_displayDMXAllFixturesData()
          EndIf
        EndIf
        StopDrawing()
      EndIf
      CopyArray(gaDMXSendData(), \aPrevDMXSendData())
    EndIf
  EndWith
  
EndProcedure

Procedure DMX_setDMXMasterFader(nDMXMasterFaderValue, nDMXSendOrigin=#SCS_DMX_ORIGIN_CUE)
  PROCNAMEC()
  Protected nDMXDevPtr, nDMXPort, nDMXSendDataBaseIndex, nDMXChannel, aNewValue.a
  Protected nItemIndex
  Protected f, nDMXControlPtr
  
  ; debugMsg0(sProcName, #SCS_START + ", nDMXMasterFaderValue=" + nDMXMasterFaderValue)
  
  grDMXMasterFader\nDMXMasterFaderValue = nDMXMasterFaderValue
  
  For nDMXControlPtr = 0 To grDMX\nMaxDMXControl
    If gaDMXControl(nDMXControlPtr)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
      nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
      nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
      nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
      For nDMXChannel = 1 To grLicInfo\nMaxDMXChannel
        nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
        If gbDMXDimmableChannel(nItemIndex)
          With grDMXChannelItems\aDMXChannelItem(nItemIndex)
            If \nDMXChannelValue = 0
              aNewValue = 0
            Else
              ; debugMsg0(sProcName, "grDMXChannelItems\aDMXChannelItem(" + nItemIndex + ")\nDMXChannelValue=" + \nDMXChannelValue)
              f = DMX_getFadeItemIndex(nDMXDevPtr, nDMXPort, nDMXChannel, 0, #True) ; nb #True in final parameter means 'check existing entries only')
              If f >= 0
                If grDMXFadeItems\aFadeItem(f)\bFadeCompleted = #False
                  grDMXFadeItems\aFadeItem(f)\nStartValue = gaDMXSendData(nItemIndex)
                  If grDMXMasterFader\nDMXMasterFaderValue = 100
                    grDMXFadeItems\aFadeItem(f)\nTargetValue = \nDMXChannelValue
                  Else
                    grDMXFadeItems\aFadeItem(f)\nTargetValue = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
                  EndIf
                  ; debugMsg(sProcName, "grDMXFadeItems\aFadeItem(" + f + ")\nTargetValue=" + grDMXFadeItems\aFadeItem(f)\nTargetValue)
                Else
                  If grDMXMasterFader\nDMXMasterFaderValue = 100
                    aNewValue = \nDMXChannelValue
                  Else
                    aNewValue = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
                  EndIf
                  ; debugMsg0(sProcName, "grDMXMasterFader\nDMXMasterFaderValue=" + grDMXMasterFader\nDMXMasterFaderValue + ", gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
                EndIf
              Else
                If grDMXMasterFader\nDMXMasterFaderValue = 100
                  aNewValue = \nDMXChannelValue
                Else
                  aNewValue = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
                EndIf
              EndIf
              ; debugMsg0(sProcName, "gaDMXSendOrigin(" + nItemIndex + ")=" + gaDMXSendOrigin(nItemIndex))
              CompilerIf #cTraceDMXSendChannels1to34
                If nItemIndex < 35
                  debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
                EndIf
              CompilerEndIf
            EndIf
            If gaDMXSendData(nItemIndex) <> aNewValue
              gaDMXSendData(nItemIndex) = aNewValue
              gaDMXSendOrigin(nItemIndex) = nDMXSendOrigin
            EndIf
          EndWith
        EndIf
      Next nDMXChannel
    EndIf ; EndIf gaDMXControl(m)\nDevType = #SCS_DEVTYPE_LT_DMX_OUT
  Next nDMXControlPtr
  
  If gbMainFormLoaded
    ; debugMsg(sProcName, "calling setSaveSettings()")
    setSaveSettings(#True)
  EndIf
  
  grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_resetDMXMasterFader()
  PROCNAMEC()
  
  With grDMXMasterFader
    DMX_setDMXMasterFader(\nDMXMasterFaderResetValue)
    If SLD_isSlider(WCN\sldDMXMasterFader)
      SLD_setValue(WCN\sldDMXMasterFader, \nDMXMasterFaderValue)
    EndIf
  EndWith
  
EndProcedure

Procedure DMX_IsDMXOutDevPresent(bTrace=#False)
  PROCNAMEC()
  Protected bDMXOutDevPresent
  Protected d
  
  debugMsgC(sProcName, #SCS_START + ", grProd\nMaxLightingLogicalDev=" + grProd\nMaxLightingLogicalDev)
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
        bDMXOutDevPresent = #True
        Break
      EndIf
    EndWith
  Next d
  
  debugMsgC(sProcName, #SCS_END + ", returning " + strB(bDMXOutDevPresent))
  ProcedureReturn bDMXOutDevPresent
EndProcedure

Procedure DMX_loadDMXDimmableChannelArray()
  PROCNAMEC()
  Protected nArraySize
  Protected d, f, n, nDevMapDevPtr, nDevFixtureIndex, nDMXStartChannel
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort, nDMXSendDataBaseIndex
  Protected sDimmableChannels.s, nPartCount, sPart.s, nPart, nDashCount, nDMXChannel, nItemIndex
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected sFixtureCode.s
  
  debugMsg(sProcName, #SCS_START)
  
  nArraySize = ArraySize(gaDMXSendData())
  If ArraySize(gbDMXDimmableChannel()) <> nArraySize
    ReDim gbDMXDimmableChannel(nArraySize)
  EndIf
  For nItemIndex = 0 To nArraySize
    gbDMXDimmableChannel(nItemIndex) = #False
  Next nItemIndex
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
        debugMsg(sProcName, "grProd\aLightingLogicalDevs(" + d + ")\nMaxFixture=" + \nMaxFixture)
        For f = 0 To \nMaxFixture
          sFixtureCode = \aFixture(f)\sFixtureCode
          sDimmableChannels = \aFixture(f)\sDimmableChannels
          If (sFixtureCode) And (sDimmableChannels)
            nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(\nDevType, \sLogicalDev)
            If nDMXControlPtr >= 0
              nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
              nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
              nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
            EndIf
            nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, \sLogicalDev)
            nDMXStartChannel = 1
            If nDevMapDevPtr >= 0
              For n = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
                If grMaps\aDev(nDevMapDevPtr)\aDevFixture(n)\sDevFixtureCode = sFixtureCode
                  nDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(n)\nDevDMXStartChannel
                  Break
                EndIf
              Next n
            EndIf
            debugMsg(sProcName, "\sLogicalDev=" + \sLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr + ", nDMXPort=" + nDMXPort + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex +
                                ", \aFixture(" + f + ")\sFixtureCode=" + #DQUOTE$ + sFixtureCode + #DQUOTE$ +
                                ", \sDimmableChannels=" + #DQUOTE$ + sDimmableChannels + #DQUOTE$ + ", nDMXStartChannel=" + nDMXStartChannel)
            ; process channels
            If nDMXStartChannel > 0
              nPartCount = CountString(sDimmableChannels, ",") + 1
              For nPart = 1 To nPartCount
                sPart = StringField(sDimmableChannels, nPart, ",")
                nDashCount = CountString(sPart, "-")
                Select nDashCount
                  Case 0
                    sFromChannel = sPart
                    sUpToChannel = sPart
                  Case 1
                    sFromChannel = StringField(sPart, 1, "-")
                    sUpToChannel = StringField(sPart, 2, "-")
                EndSelect
                nFromChannel = Val(sFromChannel)
                nUpToChannel = Val(sUpToChannel)
                ; process channels for this part
                For nDMXChannel = nFromChannel To nUpToChannel
                  nItemIndex = nDMXSendDataBaseIndex + nDMXChannel + (nDMXStartChannel - 1)
                  gbDMXDimmableChannel(nItemIndex) = #True
                  ; debugMsg(sProcName, "gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
                Next nDMXChannel
              Next nPart
            EndIf ; EndIf nDMXStartChannel > 0
          EndIf ; EndIf \aFixture(f)\sDimmableChannels
        Next f
      EndIf ; EndIf (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
    EndWith
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_loadDMXTextColorsArray()
  PROCNAMEC()
  Protected nArraySize
  Protected d, f, n, nDevMapDevPtr, nDMXStartChannel
  Protected nDMXControlPtr, nDMXSendDataBaseIndex
  Protected nItemIndex, nColorIndex
  Protected sFixtureCode.s, sFixTypeName.s, nFixTypeIndex, nTotalChans, nChanIndex
  
  debugMsg(sProcName, #SCS_START)
  
  nArraySize = ArraySize(gaDMXSendData())  
  If ArraySize(gnDMXTextColorsZero()) <> nArraySize
    ReDim gnDMXTextColorsZero(nArraySize)
    ReDim gnDMXTextColorsNonZero(nArraySize)
  EndIf
  
  For nItemIndex = 0 To nArraySize
    gnDMXTextColorsZero(nItemIndex) = #SCS_Mid_Grey
    gnDMXTextColorsNonZero(nItemIndex) = #SCS_Black
  Next nItemIndex
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
        nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(\nDevType, \sLogicalDev)
        If nDMXControlPtr >= 0
          nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
        Else
          nDMXSendDataBaseIndex = 0
        EndIf
        For f = 0 To \nMaxFixture
          sFixtureCode = \aFixture(f)\sFixtureCode        
          ; debugMsg(sProcName, "Code: " + \aFixture(f)\sFixtureCode + " Name: " + \aFixture(f)\sFixTypeName + " Descr: " + \aFixture(f)\sFixtureDesc + " Dimmable: " + \aFixture(f)\sDimmableChannels)
          
          ; Get the DMX Start Channel for this Device
          nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, \sLogicalDev)        
          If sFixtureCode
            nDMXStartChannel = 1
            If nDevMapDevPtr >= 0
              For n = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
                If grMaps\aDev(nDevMapDevPtr)\aDevFixture(n)\sDevFixtureCode = sFixtureCode
                  nDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(n)\nDevDMXStartChannel
                  Break
                EndIf
              Next n
            EndIf
          EndIf
          
          If nDMXStartChannel > 0 ; nb nDMXStartChannel will be -2 if the fixture has not yet been defined in the device map - a scenario that occurred during testing
            sFixTypeName = \aFixture(f)\sFixTypeName
            ;Debug "Fixture Type Name: " + sFixTypeName 
            If sFixTypeName
              nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
              If nFixTypeIndex >= 0
                nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
                For nChanIndex = 0 To nTotalChans-1
                  nColorIndex = nDMXSendDataBaseIndex + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\nChanNo + (nDMXStartChannel - 1)
                  gnDMXTextColorsZero(nColorIndex) = grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\nDMXTextColor
                  gnDMXTextColorsNonZero(nColorIndex) = grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\nDMXTextColor
                Next nChanIndex
              EndIf
            EndIf
          EndIf
        Next f      
      EndWith
    EndIf 
  Next d
    
EndProcedure

Procedure DMX_loadDMXDimmableChannelArrayFI()
  PROCNAMEC()
  Protected nArraySize
  Protected d, f, nDevMapDevPtr, nDevFixtureIndex, nDMXStartChannel, nStartChannelIndex
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort, nDMXSendDataBaseIndex
  Protected sDimmableChannels.s, nPartCount, sPart.s, nPart, nDashCount, nDMXChannel, nItemIndex
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected sFixtureCode.s, sFixTypeName.s, nFixTypeIndex, nTotalChans, nChanIndex, nRelChanNo
  
  debugMsg(sProcName, #SCS_START)
  
  nArraySize = ArraySize(gaDMXSendData())
  If ArraySize(gbDMXDimmableChannel()) <> nArraySize
    ReDim gbDMXDimmableChannel(nArraySize)
  EndIf
  
  ; Modified this procedure 23Mar2019 11.8.0.2cj following email from Ryan Rohrer 21Mar2019 about fade times not working.
  ; debugMsg(sProcName, "nArraySize=" + nArraySize)
  For nItemIndex = 0 To nArraySize
    gbDMXDimmableChannel(nItemIndex) = #True
  Next nItemIndex
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
        nDMXControlPtr = DMX_getDMXControlPtrForLogicalDev(\nDevType, \sLogicalDev)
        If nDMXControlPtr >= 0
          nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
          nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
          nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
        Else
          nDMXDevPtr = 0
          nDMXPort = 0
          nDMXSendDataBaseIndex = 0
        EndIf
        nDevMapDevPtr = getDevMapDevPtrForLogicalDev(@grMaps, #SCS_DEVGRP_LIGHTING, \sLogicalDev)
        For f = 0 To \nMaxFixture
          sFixtureCode = \aFixture(f)\sFixtureCode
          If sFixtureCode
            sFixTypeName = \aFixture(f)\sFixTypeName
            If sFixTypeName
              nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
              If nFixTypeIndex >= 0
                nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
              EndIf
              nDMXStartChannel = 1
              If nDevMapDevPtr >= 0
                For nDevFixtureIndex = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
                  If grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\sDevFixtureCode = sFixtureCode
                    If grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\nMaxDevStartChannelIndex >= 0
                      For nStartChannelIndex = 0 To grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\nMaxDevStartChannelIndex
                        nDMXStartChannel = grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\aDevStartChannel(nStartChannelIndex)
                        For nChanIndex = 0 To nTotalChans-1
                          If grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\bDimmerChan = #False
                            nItemIndex = nDMXSendDataBaseIndex + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\nChanNo + (nDMXStartChannel - 1)
                            gbDMXDimmableChannel(nItemIndex) = #False
                            ; debugMsg(sProcName, "sFixtureCode=" + sFixtureCode + ", sFixTypeName=" + sFixTypeName + ", nFixTypeIndex=" + nFixTypeIndex + ", nTotalChans=" + nTotalChans + ", nDMXStartChannel=" + nDMXStartChannel + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex +
                            ;                     ", nChanIndex=" + nChanIndex + ", nItemIndex=" + nItemIndex + ", gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
                          EndIf
                        Next nChanIndex
                      Next nStartChannelIndex
                    Else
                      sDimmableChannels = Trim(\aFixture(f)\sDimmableChannels)
                      ; debugMsg(sProcName, "\sLogicalDev=" + \sLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr + ", nDMXPort=" + nDMXPort + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex +
                      ;                     ", \aFixture(" + f + ")\sFixtureCode=" + #DQUOTE$ + sFixtureCode + #DQUOTE$ +
                      ;                     ", \sDimmableChannels=" + #DQUOTE$ + sDimmableChannels + #DQUOTE$ + ", nDMXStartChannel=" + nDMXStartChannel)
                      If Len(sDimmableChannels) = 0
                        ; process channels
                        If nDMXStartChannel > 0
                          nPartCount = CountString(sDimmableChannels, ",") + 1
                          For nPart = 1 To nPartCount
                            sPart = StringField(sDimmableChannels, nPart, ",")
                            nDashCount = CountString(sPart, "-")
                            Select nDashCount
                              Case 0
                                sFromChannel = sPart
                                sUpToChannel = sPart
                              Case 1
                                sFromChannel = StringField(sPart, 1, "-")
                                sUpToChannel = StringField(sPart, 2, "-")
                            EndSelect
                            nFromChannel = Val(sFromChannel)
                            nUpToChannel = Val(sUpToChannel)
                            ; process channels for this part
                            For nDMXChannel = nFromChannel To nUpToChannel
                              nItemIndex = nDMXSendDataBaseIndex + nDMXChannel + (nDMXStartChannel - 1)
                              gbDMXDimmableChannel(nItemIndex) = #False
                              ; debugMsg(sProcName, "gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
                            Next nDMXChannel
                          Next nPart
                        EndIf ; EndIf nDMXStartChannel > 0
                      EndIf   ; EndIf sDimmableChannels
                    EndIf
                  EndIf ; EndIf grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\sDevFixtureCode = sFixtureCode
                Next nDevFixtureIndex
              EndIf ; EndIf nDevMapDevPtr >= 0
            EndIf ; EndIf/Else sFixTypeName
          EndIf ; EndIf sFixtureCode
        Next f
      EndIf ; EndIf (\nDevType = #SCS_DEVTYPE_LT_DMX_OUT) And (\sLogicalDev)
    EndWith
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_setDMXProcessRefresh(nDMXControlPtr)
  PROCNAMEC()
  Protected bProcessRefresh, bRefreshSet, nRefreshInterval
  Protected nThisRefreshInterval
  Protected n
  
  debugMsg(sProcName, #SCS_START + ", nDMXControlPtr=" + nDMXControlPtr)
  
  With gaDMXControl(nDMXControlPtr)
    Select \nDevType
      Case #SCS_DEVTYPE_LT_DMX_OUT
        Select \nDMXDevType
          Case #SCS_DMX_DEV_ENTTEC_OPEN_DMX_USB, #SCS_DMX_DEV_FTDI_USB_RS485, #SCS_DMX_DEV_ARTNET, #SCS_DMX_DEV_SACN
            If \nDMXRefreshRate > 0
              debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\nDMXRefreshRate=" + \nDMXRefreshRate)
              bProcessRefresh = #True
              bRefreshSet = #True
            EndIf
        EndSelect
    EndSelect
    \bDMXProcessRefresh = bProcessRefresh
    debugMsg(sProcName, "gaDMXControl(" + nDMXControlPtr + ")\bDMXProcessRefresh=" + strB(\bDMXProcessRefresh))
  EndWith
  
  For n = 0 To grDMX\nMaxDMXControl
    With gaDMXControl(n)
      debugMsg(sProcName, "gaDMXControl(" + n + ")\nDevType=" + decodeDevType(\nDevType) + ", \bDMXProcessRefresh=" + strB(\bDMXProcessRefresh) + ", \nDMXRefreshRate=" + \nDMXRefreshRate)
      If \nDevType = #SCS_DEVTYPE_LT_DMX_OUT
        If \bDMXProcessRefresh
          bRefreshSet = #True
          nThisRefreshInterval = 1000 / \nDMXRefreshRate  ; convert refresh rate to refresh interval, eg 40fps = 25ms
          If (nRefreshInterval = 0) Or (nThisRefreshInterval < nRefreshInterval)
            nRefreshInterval = nThisRefreshInterval
          EndIf
        EndIf
      EndIf
    EndWith
  Next n
  
  With grDMXRefreshControl
    \bRefreshSet = bRefreshSet              ; #True if at least one DMX OUT device requires refreshing (ie Enttec OPEN DMX USB or equivalent)
    \nRefreshInterval = nRefreshInterval    ; the minimum refresh interval of the devices that require refreshing
    debugMsg(sProcName, "grDMXRefreshControl\bRefreshSet=" + strB(\bRefreshSet) + ", \nRefreshInterval=" + \nRefreshInterval)
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_loadDMXChaseItems(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected n, m
  Protected nPass, nChaseItemIndex
  Protected nStep
  Protected sCurrFixtureCodes.s, sFixtureCodes.s, sDMXChannels.s, nDMXValue, nDMXFadeTime
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected nDMXChannel, nDMXControlPtr, nDMXDevPtr, nDMXPort = 1
  Protected nFixtureOffset, bSkipFixture, nProdDevNo
  Protected nFirstFixtureIndex.l, nLastFixtureIndex.l, nThisFixtureIndex.l
  Protected nDMXStartChannel, nDevStartChannelIndex, nMaxDevStartChannelIndex
  Protected qTimeNow.q
  
  debugMsg(sProcName, #SCS_START)
  
  If grFixturesRunTime\bLoaded = #False
    DMX_loadFixturesRunTime()
  EndIf
  
  If pSubPtr >= 0
    With grDMXChaseItems
      If \bChaseRunning
        If \nChaseSubPtr <> pSubPtr
          debugMsg(sProcName, "calling stopSub(" + getSubLabel(\nChaseSubPtr) + ", 'K', #False, #False)")
          stopSub(\nChaseSubPtr, "K", #False, #False)
        EndIf
      EndIf
    EndWith
    
    If aSub(pSubPtr)\nDMXControlPtr < 0
      DMX_setDMXControlPtrForSub(pSubPtr)
    EndIf
    nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
    If nDMXControlPtr >= 0
      nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
      nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
      ; nb do not calculate the nDMXSendDataBaseIndex in this procedure as it is calculated and used in DMX_prepareChaseStepForSend()
    EndIf
    
    nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(pSubPtr)\sLTLogicalDev)
    ; debugMsg(sProcName, "nProdDevNo=" + nProdDevNo)
    For nPass = 1 To 2  ; pass 1 just calculates required arraysize and then redim's the array if necessary. pass 2 populates the array
      nChaseItemIndex = -1
      sCurrFixtureCodes = ""
      For n = 0 To aSub(pSubPtr)\nMaxChaseStepIndex
        For m = 0 To (aSub(pSubPtr)\aChaseStep(n)\nDMXSendItemCount - 1)
          With aSub(pSubPtr)\aChaseStep(n)\aDMXSendItem(m)
            ; debugMsg(sProcName, "nPass=" + nPass + ", aSub(" + getSubLabel(pSubPtr) + ")\aChaseStep(" + n + ")\aDMXSendItem(" + m + ")\sDMXItemStr=" + \sDMXItemStr + ", \sDMXChannels=" + \sDMXChannels)
            If \sDMXChannels
              If FindString(\sDMXChannels, ":")
                sFixtureCodes = UCase(StringField(\sDMXChannels, 1, ":"))
                If Len(sFixtureCodes) = 0
                  sFixtureCodes = sCurrFixtureCodes
                Else
                  sCurrFixtureCodes = sFixtureCodes
                EndIf
                sDMXChannels = StringField(\sDMXChannels, 2, ":")
                DMX_setFixturesRunTimeRequiredFlags(nProdDevNo, sFixtureCodes, @nFirstFixtureIndex, @nLastFixtureIndex)
              Else
                sFixtureCodes = ""
                sDMXChannels = \sDMXChannels
                nFirstFixtureIndex = -1
                nLastFixtureIndex = -1
              EndIf
              nThisFixtureIndex = nFirstFixtureIndex
              ; debugMsg(sProcName, "sFixtureCodes=" + sFixtureCodes + ", nFirstFixtureIndex=" + nFirstFixtureIndex + ", nLastFixtureIndex=" + nLastFixtureIndex + ", sDMXChannels=" + sDMXChannels + ", \nDMXValue=" + \nDMXValue)
              nDMXValue = \nDMXValue
            EndIf
          EndWith
          
          If aSub(pSubPtr)\aChaseStep(n)\aDMXSendItem(m)\sDMXChannels
            ; debugMsg(sProcName, "\aChaseStep(" + n + ")\aDMXSendItem(" + m + ")\sDMXChannels=" + aSub(pSubPtr)\aChaseStep(n)\aDMXSendItem(m)\sDMXChannels)
            While #True ; fixtures loop
              bSkipFixture = #False
              If nThisFixtureIndex >= 0
                If grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\bFixtureRequired = #False
                  bSkipFixture = #True
                EndIf
              EndIf
              If bSkipFixture = #False
                If nThisFixtureIndex >= 0
                  nMaxDevStartChannelIndex = grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\nMaxDevStartChannelIndex
                Else
                  nMaxDevStartChannelIndex = 0 ; Forces next loop to be processed just once
                EndIf
                For nDevStartChannelIndex = 0 To nMaxDevStartChannelIndex
                  If nThisFixtureIndex = -1
                    ; no fixture - just absolute DMX channel addresses
                    nFixtureOffset = 0
                  Else
                    nDMXStartChannel = grFixturesRunTime\aFixtureRunTime(nThisFixtureIndex)\aDevStartChannel(nDevStartChannelIndex)
                    nFixtureOffset = nDMXStartChannel - 1
                  EndIf
                  ; debugMsg(sProcName, "nThisFixtureIndex=" + nThisFixtureIndex + ", nFixtureOffset=" + nFixtureOffset)
                  ; process channels
                  nPartCount = CountString(sDMXChannels, ",") + 1
                  For nPart = 1 To nPartCount
                    sPart = StringField(sDMXChannels, nPart, ",")
                    nDashCount = CountString(sPart, "-")
                    Select nDashCount
                      Case 0
                        sFromChannel = sPart
                        sUpToChannel = sPart
                      Case 1
                        sFromChannel = StringField(sPart, 1, "-")
                        sUpToChannel = StringField(sPart, 2, "-")
                    EndSelect
                    nFromChannel = Val(sFromChannel) + nFixtureOffset
                    nUpToChannel = Val(sUpToChannel) + nFixtureOffset
                    If nPass = 1
                      nChaseItemIndex + (nUpToChannel - nFromChannel + 1)
                      ; debugMsg(sProcName, "nFromChannel=" + nFromChannel + ", nUpToChannel=" + nUpToChannel + ", nChaseItemIndex=" + nChaseItemIndex)
                    Else ; nPass = 2
                      nStep = n + 1
                      ; process channels for this part
                      For nDMXChannel = nFromChannel To nUpToChannel
                        nChaseItemIndex + 1
                        If nChaseItemIndex > ArraySize(grDMXChaseItems\aDMXChaseItem())
                          ; shouldn't happen as the array should have been correctly redim'd at the end of pass 1
                          ReDim grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)
                        EndIf
                        grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nStep = nStep
                        grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXChannel = nDMXChannel
                        grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXValue = nDMXValue
                        ; debugMsg(sProcName, "grDMXChaseItems\aDMXChaseItem(" + nChaseItemIndex + ")\nStep=" + grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nStep +
                        ;                     ", \nDMXChannel=" + grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXChannel +
                        ;                     ", \nDMXValue=" + grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXValue)
                      Next nDMXChannel
                    EndIf ; nPass
                  Next nPart
                Next nDevStartChannelIndex
              EndIf ; EndIf bSkipFixture = #False
              nThisFixtureIndex + 1
              If nThisFixtureIndex > nLastFixtureIndex
                Break ; break While #True (fixtures loop)
              EndIf
            Wend
          EndIf ; EndIf aSub(pSubPtr)\aChaseStep(n)\aDMXSendItem(m)\sDMXChannels
        Next m
      Next n
      If nPass = 1
        With grDMXChaseItems
          \nMaxChaseItem = nChaseItemIndex
          If \nMaxChaseItem > ArraySize(\aDMXChaseItem())
            ReDim \aDMXChaseItem(\nMaxChaseItem)
          EndIf
        EndWith
      EndIf
    Next nPass
    
    With grDMXChaseItems
      If \nMaxChaseItem >= 0
        \nChaseSubPtr = pSubPtr
        \nDMXDevPtr = nDMXDevPtr
        \nDMXPort = nDMXPort
        If aSub(pSubPtr)\nDMXControlPtr < 0
          DMX_setDMXControlPtrForSub(pSubPtr)
        EndIf
        \nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
        \nChaseSteps = aSub(pSubPtr)\nChaseSteps
        \bNextLTStopsChase = aSub(pSubPtr)\bNextLTStopsChase
        \nChaseMode = aSub(pSubPtr)\nChaseMode
        \bBouncingBack = #False
        \nLastStepProcessed = 0
        If aSub(pSubPtr)\nChaseSpeed > 0
          \nCueTimeBetweenSteps = 60000 / aSub(pSubPtr)\nChaseSpeed
          \sCueChaseBPM = Str(aSub(pSubPtr)\nChaseSpeed)
        Else
          \nCueTimeBetweenSteps = 60000 / grProd\nDefChaseSpeed
          \sCueChaseBPM = Str(grProd\nDefChaseSpeed)
        EndIf
        \bMonitorTapDelay = aSub(pSubPtr)\bMonitorTapDelay
        qTimeNow = ElapsedMilliseconds()
        If (\bMonitorTapDelay) And (\nTapTimeBetweenSteps > 0)
          \nChaseControl = #SCS_DMX_CHASE_CTL_TAP
          \qLastItemTime = qTimeNow - \nTapTimeBetweenSteps - 100 ; ensure chase starts asap
        Else
          \nChaseControl = #SCS_DMX_CHASE_CTL_CUE
          \qLastItemTime = qTimeNow - \nCueTimeBetweenSteps - 100 ; ensure chase starts asap
        EndIf
        \nItemsProcessed = 0
        \qNextTtemTime = qTimeNow
        \qChaseStartTime = qTimeNow
        ; debugMsg0(sProcName, "\qChaseStartTime=" + traceTime(\qChaseStartTime))
        \bStopChase = #False
        \bChaseRunning = #True
        debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(grDMXChaseItems\bChaseRunning))
        debugMsg(sProcName, "grDMXChaseItems\nMaxChaseItem=" + \nMaxChaseItem + ", \nChaseSubPtr=" + getSubLabel(\nChaseSubPtr) +
                            ", \nChaseSteps=" + \nChaseSteps + ", \bNextLTStopsChase=" + strB(\bNextLTStopsChase) +
                            ", \nLastStepProcessed=" + \nLastStepProcessed + ", \nCueTimeBetweenSteps=" + \nCueTimeBetweenSteps +
                            ", \qLastItemTime=" + traceTime(\qLastItemTime) + ", \bChaseRunning=" + strB(\bChaseRunning) +
                            ", \bStopChase=" + strB(\bStopChase))
      EndIf
    EndWith
    
  EndIf ; EndIf pSubPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_loadDMXChaseItemsFI(pSubPtr)
  ; loadDMXChaseItems for entry type 'Fixture Items'
  PROCNAMECS(pSubPtr)
  Protected m
  Protected nPass, nChaseStepIndex, nChaseItemIndex
  Protected nFixtureIndex, sFixtureCode.s, nFixtureRunTimeIndex, nFixTypeIndex
  Protected nTotalChans, nDMXStartChannel, nChanIndex, nDevStartChannelIndex
  Protected nRelChanNo, nItemIndex, nDMXSendDataBaseIndex
  Protected sCurrFixtureCodes.s, sFixtureCodes.s, sDMXChannels.s, nDMXValue, nDMXFadeTime
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel
  Protected nDMXChannel, nDMXControlPtr, nDMXDevPtr, nDMXPort = 1
  Protected nFixtureOffset, bSkipFixture, nProdDevNo
  Protected nFirstFixtureIndex.l, nLastFixtureIndex.l, nThisFixtureIndex.l
  Protected qTimeNow.q
  
  debugMsg(sProcName, #SCS_START)
  
  If grFixturesRunTime\bLoaded = #False
    DMX_loadFixturesRunTime()
  EndIf
  
  If pSubPtr >= 0
    With grDMXChaseItems
      If \bChaseRunning
        If \nChaseSubPtr <> pSubPtr
          debugMsg(sProcName, "calling stopSub(" + getSubLabel(\nChaseSubPtr) + ", 'K', #False, #False)")
          stopSub(\nChaseSubPtr, "K", #False, #False)
        EndIf
      EndIf
    EndWith
    
    nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
    If aSub(pSubPtr)\nDMXControlPtr < 0
      DMX_setDMXControlPtrForSub(pSubPtr)
    EndIf
    If nDMXControlPtr >= 0
      nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
      nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
      nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
    EndIf
    
    nProdDevNo = getDevNoForLogicalDev(@grProd, #SCS_DEVGRP_LIGHTING, aSub(pSubPtr)\sLTLogicalDev)
    ; debugMsg(sProcName, "nProdDevNo=" + nProdDevNo)
    For nPass = 1 To 2  ; pass 1 just calculates required arraysize and then redim's the array if necessary. pass 2 populates the array
      nChaseItemIndex = -1
      sCurrFixtureCodes = ""
      For nChaseStepIndex = 0 To aSub(pSubPtr)\nMaxChaseStepIndex
        For nFixtureIndex = 0 To aSub(pSubPtr)\nMaxFixture
          sFixtureCode = aSub(pSubPtr)\aLTFixture(nFixtureIndex)\sLTFixtureCode
          If sFixtureCode
            With aSub(pSubPtr)\aChaseStep(nChaseStepIndex)\aFixtureItem(nFixtureIndex)
              If \sFixtureCode = sFixtureCode
                ; should be #True
                nFixtureRunTimeIndex = DMX_getFixturesRunTimeIndex(nProdDevNo, sFixtureCode)
                If nFixtureRunTimeIndex >= 0
                  ; should be #True
                  nFixTypeIndex = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nFixTypeIndex
                  nTotalChans = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nTotalChans
                  For nDevStartChannelIndex = 0 To grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\nMaxDevStartChannelIndex
                    nDMXStartChannel = grFixturesRunTime\aFixtureRunTime(nFixtureRunTimeIndex)\aDevStartChannel(nDevStartChannelIndex)
                    For nChanIndex = 0 To nTotalChans-1
                      If \aFixChan(nChanIndex)\bRelChanIncluded
                        nChaseItemIndex + 1
                        If nPass = 2
                          nRelChanNo = \aFixChan(nChanIndex)\nRelChanNo
                          nDMXChannel = nDMXStartChannel + nRelChanNo - 1
                          nDMXValue = \aFixChan(nChanIndex)\nDMXAbsValue
                          If nChaseItemIndex > ArraySize(grDMXChaseItems\aDMXChaseItem())
                            ; shouldn't happen as the array should have been correctly redim'd at the end of pass 1
                            ReDim grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)
                          EndIf
                          grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nStep = nChaseStepIndex + 1
                          grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXChannel = nDMXChannel
                          grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXValue = nDMXValue
                          ; If nDMXValue > 0
                          ;   debugMsg(sProcName, "grDMXChaseItems\aDMXChaseItem(" + nChaseItemIndex + ")\nDMXValue=" + grDMXChaseItems\aDMXChaseItem(nChaseItemIndex)\nDMXValue)
                          ; EndIf
                        EndIf
                      EndIf
                    Next nChanIndex
                  Next nDevStartChannelIndex
                EndIf
              EndIf
            EndWith
          EndIf
        Next nFixtureIndex
      Next nChaseStepIndex
      
      If nPass = 1
        With grDMXChaseItems
          \nMaxChaseItem = nChaseItemIndex
          If \nMaxChaseItem > ArraySize(\aDMXChaseItem())
            ReDim \aDMXChaseItem(\nMaxChaseItem)
          EndIf
        EndWith
      EndIf
    Next nPass
    
    With grDMXChaseItems
      If \nMaxChaseItem >= 0
        \nChaseSubPtr = pSubPtr
        \nDMXDevPtr = nDMXDevPtr
        \nDMXPort = nDMXPort
        If aSub(pSubPtr)\nDMXControlPtr < 0
          DMX_setDMXControlPtrForSub(pSubPtr)
        EndIf
        \nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
        \nChaseSteps = aSub(pSubPtr)\nChaseSteps
        \bNextLTStopsChase = aSub(pSubPtr)\bNextLTStopsChase
        \nChaseMode = aSub(pSubPtr)\nChaseMode
        \bBouncingBack = #False
        \nLastStepProcessed = 0
        If aSub(pSubPtr)\nChaseSpeed > 0
          \nCueTimeBetweenSteps = 60000 / aSub(pSubPtr)\nChaseSpeed
          \sCueChaseBPM = Str(aSub(pSubPtr)\nChaseSpeed)
        Else
          \nCueTimeBetweenSteps = 60000 / grProd\nDefChaseSpeed
          \sCueChaseBPM = Str(grProd\nDefChaseSpeed)
        EndIf
        \bMonitorTapDelay = aSub(pSubPtr)\bMonitorTapDelay
        qTimeNow = ElapsedMilliseconds()
        If (\bMonitorTapDelay) And (\nTapTimeBetweenSteps > 0)
          \nChaseControl = #SCS_DMX_CHASE_CTL_TAP
          \qLastItemTime = qTimeNow - \nTapTimeBetweenSteps - 100 ; ensure chase starts asap
        Else
          \nChaseControl = #SCS_DMX_CHASE_CTL_CUE
          \qLastItemTime = qTimeNow - \nCueTimeBetweenSteps - 100 ; ensure chase starts asap
        EndIf
        \nItemsProcessed = 0
        \qNextTtemTime = qTimeNow
        \qChaseStartTime = qTimeNow
        ; debugMsg0(sProcName, "\qChaseStartTime=" + traceTime(\qChaseStartTime))
        \bStopChase = #False
        \bChaseRunning = #True
        debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(grDMXChaseItems\bChaseRunning) + ", \qLastItemTime=" + \qLastItemTime)
        debugMsg(sProcName, "grDMXChaseItems\nMaxChaseItem=" + \nMaxChaseItem + ", \nChaseSubPtr=" + getSubLabel(\nChaseSubPtr) +
                            ", \nChaseSteps=" + \nChaseSteps + ", \bNextLTStopsChase=" + strB(\bNextLTStopsChase) +
                            ", \nLastStepProcessed=" + \nLastStepProcessed + ", \nCueTimeBetweenSteps=" + \nCueTimeBetweenSteps +
                            ", \qLastItemTime=" + traceTime(\qLastItemTime) + ", \bChaseRunning=" + strB(\bChaseRunning) +
                            ", \bStopChase=" + strB(\bStopChase))
      EndIf
    EndWith
    
  EndIf ; EndIf pSubPtr >= 0
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_stopChaseIfReqd(pSubPtr)
  PROCNAMECS(pSubPtr)
  
  With grDMXChaseItems
    debugMsg(sProcName, "grDMXChaseItems\bChaseRunning=" + strB(\bChaseRunning) + ", \nChaseSubPtr=" + getSubLabel(\nChaseSubPtr) + ", \nLastStepProcessed=" + \nLastStepProcessed)
    If \bChaseRunning
      If \nChaseSubPtr = pSubPtr
        If \nLastStepProcessed >= 0
          \bStopChase = #True
          debugMsg(sProcName, "grDMXChaseItems\bStopChase=" + strB(\bStopChase))
        EndIf
      EndIf
    EndIf
  EndWith
  
EndProcedure

Procedure DMX_isChannelInChase(nDMXChannel)
  PROCNAMEC()
  Protected bChannelInChase
  Protected n
  
  With grDMXChaseItems
    If \bChaseRunning
      For n = 0 To \nMaxChaseItem
        If \aDMXChaseItem(n)\nDMXChannel = nDMXChannel
          bChannelInChase = #True
          Break
        EndIf
      Next n
    EndIf
  EndWith
  ProcedureReturn bChannelInChase
  
EndProcedure

Procedure DMX_calcTapDelayTime()
  PROCNAMEC()
  Protected nDelayTime
  Protected nThisIndex, nPrevIndex, nLoopCount, nThisDiff, nTotalTime, nTapDiffCount
  Protected qTapTimeThisIndex.q, qTapTimePrevIndex.q
  Protected qTimeNow.q
  Static nTapIndex = -1
  Static Dim qTapTime.q(3)
  Static qLastTapTime.q
  
  qTimeNow = ElapsedMilliseconds()
  If (qTimeNow - qLastTapTime) > 1500
    ; clear array
    ; Debug "clear array"
    For nThisIndex = 0 To ArraySize(qTapTime())
      qTapTime(nThisIndex) = 0
    Next nThisIndex
    nTapIndex = -1
  EndIf
  qLastTapTime = qTimeNow
  
  nTapIndex + 1
  If nTapIndex > ArraySize(qTapTime())
    nTapIndex = 0
  EndIf
  qTapTime(nTapIndex) = qTimeNow
  ; Debug "qTapTime(" + nTapIndex + ")=" + qTapTime(nTapIndex) + " ----------------------------"
  
  nThisIndex = nTapIndex
  For nLoopCount = 0 To ArraySize(qTapTime())
    nPrevIndex = nThisIndex - 1
    If nPrevIndex < 0
      nPrevIndex = ArraySize(qTapTime())
    EndIf
    qTapTimePrevIndex = qTapTime(nPrevIndex)
    qTapTimeThisIndex = qTapTime(nThisIndex)
    If (qTapTimeThisIndex <> 0) And (qTapTimePrevIndex <> 0) And (qTapTimeThisIndex > qTapTimePrevIndex)
      ; Debug "nPrevIndex=" + nPrevIndex + ", nThisIndex=" + nThisIndex + ", qTapTimePrevIndex=" + qTapTimePrevIndex + ", qTapTimeThisIndex=" + qTapTimeThisIndex
      nThisDiff = qTapTimeThisIndex - qTapTimePrevIndex
      If nThisDiff > 1500
        ; Debug "nThisDiff=" + nThisDiff + ", break"
        Break ; break as soon as we encounter a difference between taps of more than 1.5 seconds
      EndIf
      ; Debug "nThisDiff=" + nThisDiff
      nTotalTime + nThisDiff
      nTapDiffCount + 1
    EndIf
    nThisIndex + 1
    If nThisIndex > ArraySize(qTapTime())
      nThisIndex = 0
    EndIf
    If nThisIndex = nTapIndex
      Break
    EndIf
  Next nLoopCount
  
  If nTapDiffCount < 2  ; nb = tap count < 3 as we require at least 3 taps to set an average tap time
    ; Debug "nTapDiffCount=" + nTapDiffCount
    nDelayTime = -1 ; -ve indicates delay time not calculated
  Else
    nDelayTime = nTotalTime / nTapDiffCount
    ; Debug "nTapDiffCount=" + nTapDiffCount + ", nTotalTime=" + nTotalTime + ", nDelayTime=" + nDelayTime
  EndIf
  
  ProcedureReturn nDelayTime
EndProcedure

Procedure DMX_processTapDelayShortcutOrCommand()
  PROCNAMEC()
  Protected nDelayTime
  
  With grDMXChaseItems
    nDelayTime = DMX_calcTapDelayTime()
    debugMsg(sProcName, "grDMXChaseItems\bMonitorTapDelay=" + strB(\bMonitorTapDelay) + ", nDelayTime=" + nDelayTime)
    If nDelayTime > 0
      \nTapTimeBetweenSteps = nDelayTime
      \sTapChaseBPM = Str(60000 / \nTapTimeBetweenSteps)
      If \nChaseControl = #SCS_DMX_CHASE_CTL_CUE
        If (\bChaseRunning) And (\bMonitorTapDelay)
          ; this condition can occur if the cue is set to 'monitor tap delay' but the tap delay has not yet been set during this SCS session
          ; if that occurred, then when the cue was started \nChaseControl would have been set to #SCS_DMX_CHASE_CTL_CUE but can now be set to #SCS_DMX_CHASE_CTL_TAP
          \nChaseControl = #SCS_DMX_CHASE_CTL_TAP
        EndIf
      EndIf
    EndIf
  EndWith
EndProcedure

Procedure DMX_processExtFader(pCuePtr, nMidiControlPtr, nControlValue)
  PROCNAMECQ(pCuePtr)
  Protected nCueState, j, nThresholdVV, bProcessControlValue, nPercentage
  Protected nAdjMinValue, nAdjMaxValue, nAdjValue, bStopCue
  
  ; debugMsg0(sProcName, #SCS_START + ", nMidiControlPtr=" + nMidiControlPtr + ", nControlValue=" + nControlValue)
  If aCue(pCuePtr)\bCueEnabled
    nThresholdVV = gaMidiControl(nMidiControlPtr)\nExtFaderThresholdVV
    If aCue(pCuePtr)\nCueState < #SCS_CUE_FADING_IN
      ; not yet playing
      If nControlValue >= nThresholdVV
        debugMsg(sProcName, "calling playCue(" + getCueLabel(pCuePtr) + ")")
        playCue(pCuePtr)
        bProcessControlValue = #True
      EndIf
    ElseIf aCue(pCuePtr)\nCueState <= #SCS_CUE_FADING_OUT
      If nControlValue = 0
        bStopCue = #True
      EndIf
      bProcessControlValue = #True
    EndIf
    If bProcessControlValue
      j = aCue(pCuePtr)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeK And \bSubEnabled
            If \nSubState >= #SCS_CUE_FADING_IN And \nSubState <= #SCS_CUE_FADING_OUT
              nAdjMinValue = 0
              nAdjMaxValue = 127 - nThresholdVV
              nAdjValue = nControlValue - nThresholdVV
              If nAdjValue < 0
                nAdjValue = 0
              EndIf
              nPercentage = (nAdjValue * 100) / nAdjMaxValue
              ; debugMsg0(sProcName, "nAdjMaxValue=" + nAdjMaxValue + ", nAdjValue=" + nAdjValue + ", nPercentage=" + nPercentage)
              playExtFaderSubTypeK(j, nPercentage)
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf ; EndIf bProcessControlValue
    If bStopCue
      debugMsg(sProcName, "calling stopCue(" + getCueLabel(pCuePtr) + ", 'ALL', #False)")
      stopCue(pCuePtr, "ALL", #False)
    EndIf
  EndIf
  
EndProcedure

Procedure DMX_getProdFixtureIndex(nProdDevNo, sFixtureCode.s)
  PROCNAMEC()
  Protected n
  Protected nFixtureIndex = -1
  
  With grProd\aLightingLogicalDevs(nProdDevNo)
    For n = 0 To \nMaxFixture
      If UCase(\aFixture(n)\sFixtureCode) = UCase(sFixtureCode)
        nFixtureIndex = n
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nFixtureIndex
EndProcedure

Procedure DMX_getFixtureDMXStartChannel(nDevMapDevPtr, sFixtureCode.s)
  PROCNAMEC()
  Protected nDMXStartChannel, nFixtureIndex
  
  If nDevMapDevPtr >= 0
    With grMaps\aDev(nDevMapDevPtr)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          nDMXStartChannel = \aDevFixture(nFixtureIndex)\nDevDMXStartChannel
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
  ProcedureReturn nDMXStartChannel
EndProcedure

Procedure.s DMX_getFixtureDMXStartChannels(nDevMapDevPtr, sFixtureCode.s)
  PROCNAMEC()
  Protected sDMXStartChannels.s, nFixtureIndex
  
  If nDevMapDevPtr >= 0
    With grMaps\aDev(nDevMapDevPtr)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          sDMXStartChannels = \aDevFixture(nFixtureIndex)\sDevDMXStartChannels
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
  ProcedureReturn sDMXStartChannels
EndProcedure

Procedure DMX_getFixtureDMXStartChannelForDevChgs(nDevMapDevPtr, sFixtureCode.s)
  PROCNAMEC()
  Protected nDMXStartChannel, nFixtureIndex
  
  ; debugMsg(sProcName, #SCS_START + ", nDevMapDevPtr=" + nDevMapDevPtr + ", sFixtureCode=" + sFixtureCode)
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\nMaxDevFixture=" + \nMaxDevFixture)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          nDMXStartChannel = \aDevFixture(nFixtureIndex)\nDevDMXStartChannel
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
  ; debugMsg(sProcName, #SCS_END + ", returning nDMXStartChannel=" + nDMXStartChannel)
  ProcedureReturn nDMXStartChannel
EndProcedure

Procedure DMX_setFixtureDMXStartChannelForDevChgs(nDevMapDevPtr, sFixtureCode.s, nDMXStartChannel)
  PROCNAMEC()
  Protected nFixtureIndex
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          \aDevFixture(nFixtureIndex)\nDevDMXStartChannel = nDMXStartChannel
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + nFixtureIndex + ")\nDevDMXStartChannel=" + \aDevFixture(nFixtureIndex)\nDevDMXStartChannel)
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
EndProcedure

Procedure.s DMX_getFixtureDMXStartChannelsForDevChgs(nDevMapDevPtr, sFixtureCode.s)
  PROCNAMEC()
  Protected sDMXStartChannels.s, nFixtureIndex
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          sDMXStartChannels = \aDevFixture(nFixtureIndex)\sDevDMXStartChannels
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
  ProcedureReturn sDMXStartChannels
EndProcedure

Procedure DMX_setFixtureDMXStartChannelsForDevChgs(nDevMapDevPtr, sFixtureCode.s, sDMXStartChannels.s)
  PROCNAMEC()
  Protected nFixtureIndex
  
  If nDevMapDevPtr >= 0
    With grMapsForDevChgs\aDev(nDevMapDevPtr)
      For nFixtureIndex = 0 To \nMaxDevFixture
        If UCase(\aDevFixture(nFixtureIndex)\sDevFixtureCode) = UCase(sFixtureCode)
          \aDevFixture(nFixtureIndex)\sDevDMXStartChannels = sDMXStartChannels
          ; debugMsg(sProcName, "grMapsForDevChgs\aDev(" + nDevMapDevPtr + ")\aDevFixture(" + nFixtureIndex + ")\sDevDMXStartChannels=" + \aDevFixture(nFixtureIndex)\sDevDMXStartChannels)
          Break
        EndIf
      Next nFixtureIndex
    EndWith
  EndIf
EndProcedure

Procedure DMX_loadFixturesRunTime()
  PROCNAMEC()
  Protected d, n, n2, nFixtureIndex, nFixTypeIndex, nChanIndex, nTotalChans
  Protected nFixtureCount
  Protected sFixtureCode.s, sFixTypeName.s, sDimmableChannels.s
  Protected nDevMapDevPtr, nDevFixtureIndex, nMaxDevStartChannelIndex
  
  debugMsg(sProcName, #SCS_START)
  
  For d = 0 To grProd\nMaxLightingLogicalDev
    With grProd\aLightingLogicalDevs(d)
      If \sLogicalDev And \nMaxFixture >= 0
        nFixtureCount + \nMaxFixture + 1
      EndIf
    EndWith
  Next d
  
  With grFixturesRunTime
    \nMaxFixture = nFixtureCount - 1
    ; debugMsg(sProcName, "grFixturesRunTime\nMaxFixture=" + \nMaxFixture)
    If \nMaxFixture >= 0
      ReDim \aFixtureRunTime(\nMaxFixture)
    EndIf
  EndWith
  
  nFixtureIndex = -1
  For d = 0 To grProd\nMaxLightingLogicalDev
    If (grProd\aLightingLogicalDevs(d)\sLogicalDev) And (grProd\aLightingLogicalDevs(d)\nMaxFixture >= 0)
      nDevMapDevPtr = getDevMapDevPtrForDevNo(#SCS_DEVGRP_LIGHTING, d)
      For n = 0 To grProd\aLightingLogicalDevs(d)\nMaxFixture
        With grProd\aLightingLogicalDevs(d)\aFixture(n)
          nFixtureIndex + 1
          sFixtureCode = \sFixtureCode
          sFixTypeName = \sFixTypeName
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\nDevNo = d
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\sFixtureCode = sFixtureCode
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\sDimmableChannels = \sDimmableChannels
          ; grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\nDMXStartChannel = DMX_getFixtureDMXStartChannel(nDevMapDevPtr, sFixtureCode)
          nMaxDevStartChannelIndex = -1
          For nDevFixtureIndex = 0 To grMaps\aDev(nDevMapDevPtr)\nMaxDevFixture
            If grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\sDevFixtureCode = sFixtureCode
              nMaxDevStartChannelIndex = grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\nMaxDevStartChannelIndex
              Break
            EndIf
          Next nDevFixtureIndex
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\nMaxDevStartChannelIndex = nMaxDevStartChannelIndex
          If nMaxDevStartChannelIndex > ArraySize(grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\aDevStartChannel())
            ReDim grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\aDevStartChannel(nMaxDevStartChannelIndex)
          EndIf
          If nMaxDevStartChannelIndex >= 0
            CopyArray(grMaps\aDev(nDevMapDevPtr)\aDevFixture(nDevFixtureIndex)\aDevStartChannel(), grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\aDevStartChannel())
          EndIf
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\sFixtureSortKey = DMX_createFixtureSortKey(d, sFixtureCode)
          grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\bFixtureRequired = #False
          For nFixTypeIndex = 0 To grProd\nMaxFixType
            If grProd\aFixTypes(nFixTypeIndex)\sFixTypeName = sFixTypeName
              grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\nFixTypeIndex = nFixTypeIndex
              nTotalChans = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
              grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\nTotalChans = nTotalChans
              sDimmableChannels = ""
              For nChanIndex = 0 To nTotalChans-1
                If grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\bDimmerChan
                  sDimmableChannels + "," + grProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nChanIndex)\nChanNo
                EndIf
              Next nChanIndex
              If sDimmableChannels
                grFixturesRunTime\aFixtureRunTime(nFixtureIndex)\sDimmableChannels = Mid(sDimmableChannels,2)
              EndIf
              Break
            EndIf
          Next nFixTypeIndex
        EndWith
      Next n
    EndIf
  Next d
  
  With grFixturesRunTime
    If \nMaxFixture > 0
      SortStructuredArray(\aFixtureRunTime(), #PB_Sort_Ascending, OffsetOf(tyFixtureRunTime\sFixtureSortKey), #PB_String)
    EndIf
    \bLoaded = #True
  EndWith
  
  CompilerIf 1=2
    For n = 0 To grFixturesRunTime\nMaxFixture
      With grFixturesRunTime\aFixtureRunTime(n)
        debugMsg(sProcName, "\aFixtureRunTime(" + n + ")\sFixtureSortKey=" + \sFixtureSortKey + ", \nDevNo=" + \nDevNo + ", \sFixtureCode=" + \sFixtureCode + ", \nTotalChans=" + \nTotalChans + ", \sDimmableChannels=" + \sDimmableChannels + ", \nMaxDevStartChannelIndex=" + \nMaxDevStartChannelIndex)
        For n2 = 0 To \nMaxDevStartChannelIndex
          debugMsg(sProcName, ".. \aDevStartChannel(" + n2 + ")=" + \aDevStartChannel(n2))
        Next n2
      EndWith
    Next n
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getFixturesRunTimeIndex(nProdDevNo, sFixtureCode.s)
  PROCNAMEC()
  Protected n, nFixtureRunTimeIndex = -1
  
  With grFixturesRunTime
    For n = 0 To \nMaxFixture
      If (\aFixtureRunTime(n)\nDevNo = nProdDevNo) And (\aFixtureRunTime(n)\sFixtureCode = sFixtureCode)
        nFixtureRunTimeIndex = n
        Break
      EndIf
    Next n
  EndWith
  ProcedureReturn nFixtureRunTimeIndex
EndProcedure

Procedure DMX_setFixturesRunTimeRequiredFlags(nProdDevNo, sFixtures.s, *mFirstFixtureIndex.Long, *mLastFixtureIndex.Long)
  PROCNAMEC()
  Protected sFixtureCodes.s
  Protected nPart, nPartCount, sPart.s, nDashCount
  Protected sFrom.s, sUpTo.s, sFromSortKey.s, sUpToSortKey.s
  Protected n
  Protected nFirstFixtureIndex.l=999999, nLastFixtureIndex.l=-1
  
  ; debugMsg(sProcName, #SCS_START + ", nProdDevNo=" + nProdDevNo + ", sFixtures=" + sFixtures)
  
  For n = 0 To grFixturesRunTime\nMaxFixture
    grFixturesRunTime\aFixtureRunTime(n)\bFixtureRequired = #False
  Next n
  
  sFixtureCodes = StringField(sFixtures, 1, ":")
  nPartCount = CountString(sFixtureCodes, ",") + 1
  For nPart = 1 To nPartCount
    sPart = StringField(sFixtureCodes, nPart, ",")
    nDashCount = CountString(sPart, "-")
    Select nDashCount
      Case 0
        sFrom = sPart
        sUpTo = sPart
      Case 1
        sFrom = StringField(sPart, 1, "-")
        sUpTo = StringField(sPart, 2, "-")
    EndSelect
    sFromSortKey = DMX_createFixtureSortKey(nProdDevNo, sFrom)
    sUpToSortKey = DMX_createFixtureSortKey(nProdDevNo, sUpTo)
    ; debugMsg(sProcName, "sPart=" + sPart + ", sFrom=" + sFrom + ", sUpTo=" + sUpTo + ", sFromSortKey=" + sFromSortKey + ", sUpToSortKey=" + sUpToSortKey)
    For n = 0 To grFixturesRunTime\nMaxFixture
      With grFixturesRunTime\aFixtureRunTime(n)
        ; debugMsg(sProcName, "grFixturesRunTime\aFixtureRunTime(" + n + ")\nDevNo=" + \nDevNo + ", \sFixtureSortKey=" + \sFixtureSortKey)
        If \nDevNo = nProdDevNo
          If (\sFixtureSortKey >= sFromSortKey) And (\sFixtureSortKey <= sUpToSortKey)
            \bFixtureRequired = #True
            ; debugMsg(sProcName, "grFixturesRunTime\aFixtureRunTime(" + n + ")\sFixtureCode=" + \sFixtureCode + ", \bFixtureRequired=" + strB(\bFixtureRequired))
            If n < nFirstFixtureIndex
              nFirstFixtureIndex = n
            EndIf
            If n > nLastFixtureIndex
              nLastFixtureIndex = n
            EndIf
          EndIf
        EndIf
      EndWith
    Next n
  Next nPart
  
  If nLastFixtureIndex < nFirstFixtureIndex
    ; shouldn't occur, but if it does then nLastFixtureIndex will still be -1, and setting nFirstFixtureIndex also to -1 will cause
    ; the calling procedure (loadDMXChannelItems()) to treat the item has having no fixture codes
    nFirstFixtureIndex = nLastFixtureIndex
  EndIf
  
  PokeL(*mFirstFixtureIndex, nFirstFixtureIndex)
  PokeL(*mLastFixtureIndex, nLastFixtureIndex)
  
  ; debugMsg(sProcName, #SCS_END + ", nFirstFixtureIndex=" + nFirstFixtureIndex + ", nLastFixtureIndex=" + nLastFixtureIndex)
  
EndProcedure

Procedure.s DMX_createFixtureSortKey(nProdDevNo, sFixtureCode.s)
  Protected sSortKeyWork.s
  sSortKeyWork = RSet(Str(nProdDevNo),2,"0") + sFixtureCode
  ProcedureReturn expandNumbersInString(sSortKeyWork, 4)
EndProcedure

Procedure DMX_setChaseCueCount()
  PROCNAMEC()
  ; count lighting cues that contain chase
  Protected i, j, nChaseCueCount
  
  For i = 1 To gnLastCue
    If (aCue(i)\bSubTypeK) And (aCue(i)\bCueEnabled)
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If (\bSubTypeK) And (\bSubEnabled)
            If \bChase
              nChaseCueCount + 1
              Break ; Break j
            EndIf
          EndIf
          j = \nNextSubIndex
        EndWith
      Wend
    EndIf
  Next i
  
  With grDMXChaseItems
    \nChaseCueCount = nChaseCueCount
    If \bDisplayChaseIndicator = #False
      \bDisplayChaseIndicator = #True
      \nDefTimeBetweenSteps = 60000 / grProd\nDefChaseSpeed
      \sDefChaseBPM = Str(grProd\nDefChaseSpeed)
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", grDMXChaseItems\nChaseCueCount=" + grDMXChaseItems\nChaseCueCount)
  
EndProcedure

Procedure DMX_valDMXValue(sDMXValue.s)
  ; sDMXValue may be either a percentage, expressed as a number (only) in the range "0" to "100",
  ; or a DMX value, expressed as a number preceded by "d" or "dmx", with the number component in the range "0" to "255", eg "d128"
  ; If sDMXValue satisfies the above, then the procedure returns #True
  PROCNAMEC()
  Protected sMyDMXValue.s, sStringValue.s, nNumericValue
  Protected bValid
  
  sMyDMXValue = LCase(Trim(sDMXValue))
  If IsNumeric(sMyDMXValue)
    nNumericValue = Val(sMyDMXValue)
    If (nNumericValue >= 0) And (nNumericValue <= 100)
      bValid = #True
    EndIf
  Else
    If Left(sMyDMXValue,1) = "d"
      If Left(sMyDMXValue,3) = "dmx"
        sStringValue = Mid(sMyDMXValue,4)
      Else
        sStringValue = Mid(sMyDMXValue,2)
      EndIf
      If IsNumeric(sStringValue)
        nNumericValue = Val(sStringValue)
        If (nNumericValue >= 0) And (nNumericValue <= 255)
          bValid = #True
        EndIf
      EndIf
    EndIf
  EndIf
  ProcedureReturn bValid

EndProcedure

Procedure DMX_getFixTypeId(*rProd.tyProd, sFixTypeName.s)
  Protected n, nFixTypeId = -1
  
  For n = 0 To *rProd\nMaxFixType
    If *rProd\aFixTypes(n)\sFixTypeName = sFixTypeName
      nFixTypeId = *rProd\aFixTypes(n)\nFixTypeId
      Break
    EndIf
  Next n
  ProcedureReturn nFixTypeId
EndProcedure

Procedure DMX_getFixTypeIndex(*rProd.tyProd, sFixTypeName.s)
  Protected n, nFixTypeIndex = -1
  
  For n = 0 To *rProd\nMaxFixType
    If *rProd\aFixTypes(n)\sFixTypeName = sFixTypeName
      nFixTypeIndex = n
      Break
    EndIf
  Next n
  ProcedureReturn nFixTypeIndex
EndProcedure

Procedure DMX_changeFixtureCodeInLightingCues(sOldFixtureCode.s, sNewFixtureCode.s)
  PROCNAMEC()
  Protected i, j, u
  Protected nStepIndex, nMaxStepIndex
  Protected nFixtureIndex, nFixtureItemIndex
  Protected bFixtureCodeChanged
  
  debugMsg(sProcName, #SCS_START + ", sOldFixtureCode=" + sOldFixtureCode + ", sNewFixtureCode=" + sNewFixtureCode)
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypek
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        With aSub(j)
          If \bSubTypeK
            bFixtureCodeChanged = #False
            u = preChangeSubL(bFixtureCodeChanged, "Fixture Code Changed", j)
            For nFixtureIndex = 0 To \nMaxFixture
              If \aLTFixture(nFixtureIndex)\sLTFixtureCode = sOldFixtureCode
                \aLTFixture(nFixtureIndex)\sLTFixtureCode = sNewFixtureCode
                bFixtureCodeChanged = #True
              EndIf
            Next nFixtureIndex
            If \nChaseSteps = 0
              nMaxStepIndex = 0
            Else
              nMaxStepIndex = \nChaseSteps - 1
            EndIf
            For nStepIndex = 0 To nMaxStepIndex
              For nFixtureItemIndex = 0 To \nMaxFixture
                If \aChaseStep(nStepIndex)\aFixtureItem(nFixtureItemIndex)\sFixtureCode = sOldFixtureCode
                  \aChaseStep(nStepIndex)\aFixtureItem(nFixtureItemIndex)\sFixtureCode = sNewFixtureCode
                  bFixtureCodeChanged = #True
                EndIf
              Next nFixtureItemIndex
            Next nStepIndex
            postChangeSubL(u, bFixtureCodeChanged, j)
          EndIf
          j = \nNextSubIndex 
        EndWith
      Wend
    EndIf
  Next i
  
EndProcedure

Procedure.s DMX_buildDMXString(*rProd.tyProd, *rSub.tySub, nStepIndex)
  PROCNAMEC()
  Protected sDMXString.s, nFixtureIndex, nChanIndex, sFixtureString.s, sFixtureCode.s, nTotalChans
  
  With *rSub
    For nFixtureIndex = 0 To \nMaxFixture
      sFixtureCode = \aLTFixture(nFixtureIndex)\sLTFixtureCode
      If sFixtureCode
        nTotalChans = getTotalChansForFixture(*rProd, *rSub, sFixtureCode)
        If nTotalChans > 0
          sFixtureString = ""
          For nChanIndex = 0 To nTotalChans-1
            If \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\bRelChanIncluded
              If Len(sFixtureString) = 0
                sFixtureString = sFixtureCode
              Else
                sFixtureString + "; "
              EndIf
              sFixtureString + ":" + \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\nRelChanNo +
                               "@" + \aChaseStep(nStepIndex)\aFixtureItem(nFixtureIndex)\aFixChan(nChanIndex)\sDMXDisplayValue
            EndIf
          Next nChanIndex
          If sFixtureString
            If Len(sDMXString) = 0
              sDMXString = sFixtureString
            Else
              sDMXString + "; " + sFixtureString
            EndIf
          EndIf
        EndIf
      EndIf
    Next nFixtureIndex
  EndWith
  ; debugMsg0(sProcName, #SCS_END + ", returning sDMXString=" + #DQUOTE$ + sDMXString + #DQUOTE$)
  ProcedureReturn sDMXString
EndProcedure

Procedure DMX_getFixTypeChanDimmable(nFixTypeIndex, nChanNo)
  PROCNAMEC()
  Protected bChannelDimmable, nChanIndex
  
  If nFixTypeIndex >= 0
    With grProd\aFixTypes(nFixTypeIndex)
      For nChanIndex = 0 To \nTotalChans - 1
        If \aFixTypeChan(nChanIndex)\nChanNo = nChanNo
          bChannelDimmable = \aFixTypeChan(nChanIndex)\bDimmerChan
          Break
        EndIf
      Next nChanIndex
    EndWith
  EndIf
  ProcedureReturn bChannelDimmable
EndProcedure

Procedure DMX_getDefLTEntryType(*rProd.tyProd)
  PROCNAMEC()
  Protected nDefLTEntryType = -1, n
  
  With *rProd
    For n = 0 To \nMaxFixType
      If \aFixTypes(n)\nTotalChans > 0
        nDefLTEntryType = #SCS_LT_ENTRY_TYPE_FIXTURE_ITEMS
        Break
      EndIf
    Next n
  EndWith
  If nDefLTEntryType = -1
    ; not set in above loop
    If grLicInfo\bDMXCaptureAvailable
      nDefLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
    Else
      nDefLTEntryType = #SCS_LT_ENTRY_TYPE_DMX_ITEMS
    EndIf
  EndIf
  ProcedureReturn nDefLTEntryType
EndProcedure

Procedure DMX_loadDMXChannelMonitoredArray(*rProd.tyProd)
  PROCNAMEC()
  Protected d, nDMXCommandIndex, nDMXChannel, nPlayDMXCue0Channel, nUpperLimit
  Protected i, sMidiCue.s, nMidiCue, nMidiCueChannel
  Protected n
  
  debugMsg(sProcName, #SCS_START)
  
  For n = 0 To ArraySize(gbDMXChannelMonitored())
    gbDMXChannelMonitored(n) = #False
  Next n
  
  For d = 0 To *rProd\nMaxCueCtrlLogicalDev
    With *rProd\aCueCtrlLogicalDevs(d)
      If \nDevType = #SCS_DEVTYPE_CC_DMX_IN
        For nDMXCommandIndex = 0 To #SCS_MAX_DMX_COMMAND
          nDMXChannel = \aDMXCommand[nDMXCommandIndex]\nChannel
          If (nDMXChannel > 0) And (nDMXChannel <= 512)
            Select nDMXCommandIndex
              Case #SCS_DMX_PLAY_DMX_CUE_0
                nPlayDMXCue0Channel = nDMXChannel
                debugMsg(sProcName, "nDMXCommandIndex=" + decodeDMXCommand(nDMXCommandIndex) + ", nDMXChannel=" + nDMXChannel)
              Case #SCS_DMX_PLAY_DMX_CUE_MAX
                nUpperLimit = nDMXChannel
                debugMsg(sProcName, "nDMXCommandIndex=" + decodeDMXCommand(nDMXCommandIndex) + ", nDMXChannel=" + nDMXChannel)
              Default
                gbDMXChannelMonitored(nDMXChannel) = #True
                debugMsg(sProcName, "nDMXCommandIndex=" + decodeDMXCommand(nDMXCommandIndex) + ", nDMXChannel=" + nDMXChannel + ", gbDMXChannelMonitored(" + nDMXChannel + ")=" + strB(gbDMXChannelMonitored(nDMXChannel)))
            EndSelect
          EndIf
        Next nDMXCommandIndex
        If (nPlayDMXCue0Channel > 0) And (nUpperLimit >= nPlayDMXCue0Channel)
          For i = 1 To gnLastCue
            sMidiCue = Trim(aCue(i)\sMidiCue)
            If sMidiCue
              If aCue(i)\bCueEnabled
                If IsInteger(sMidiCue)
                  nMidiCue = Val(sMidiCue)
                  nMidiCueChannel = nMidiCue + nPlayDMXCue0Channel
                  If (nMidiCueChannel > 0) And (nMidiCueChannel <= nUpperLimit)
                    gbDMXChannelMonitored(nMidiCueChannel) = #True
                    ; debugMsg(sProcName, "aCue(" + getCueLabel(i) + ")\sMidiCue=" + sMidiCue + ", nMidiCueChannel=" + nMidiCueChannel + ", gbDMXChannelMonitored(" + nMidiCueChannel + ")=" + strB(gbDMXChannelMonitored(nMidiCueChannel)))
                  EndIf
                EndIf
              EndIf
            EndIf
          Next i
        EndIf
        Break
      EndIf
    EndWith
  Next d
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getFixtureChannelCount(nProdDevNo, sFixtureCode.s)
  ; Returns the number of DMX channels for a given Fixture, eg for a 3-channel RGB fixture this will return 3
  PROCNAMEC()
  Protected nFixtureChannelCount, sFixTypeName.s
  Protected nFixtureIndex, nFixTypeIndex
  
  With grProd\aLightingLogicalDevs(nProdDevNo)
    For nFixtureIndex = 0 To \nMaxFixture
      If \aFixture(nFixtureIndex)\sFixtureCode = sFixtureCode
        sFixTypeName = \aFixture(nFixtureIndex)\sFixTypeName
        Break
      EndIf
    Next nFixtureIndex
  EndWith
  If sFixTypeName
    nFixTypeIndex = DMX_getFixTypeIndex(@grProd, sFixTypeName)
    If nFixTypeIndex >= 0
      nFixtureChannelCount = grProd\aFixTypes(nFixTypeIndex)\nTotalChans
    EndIf
  EndIf
  ProcedureReturn nFixtureChannelCount
EndProcedure

Procedure DMX_setDMXTextColorFromDesc(sChannelDesc.s)
  Protected nDMXTextColor
  Static sLangRed.s, sLangGreen.s, sLangBlue.s, sLangWhite.s, sLangYellow.s, sLangCyan.s, sLangAmber.s, sLangUV.s
  Static bStaticLoaded
  
  If bStaticLoaded = #False
    sLangRed = Trim(UCase(Lang("Menu", "mnuGrdColRed")))
    sLangGreen = Trim(UCase(Lang("Menu", "mnuGrdColGreen")))
    sLangBlue = Trim(UCase(Lang("Menu", "mnuGrdColBlue")))
    sLangWhite = Trim(UCase(Lang("Menu", "mnuGrdColWhite")))
    sLangYellow = Trim(UCase(Lang("Menu", "mnuGrdColYellow")))
    sLangCyan = Trim(UCase(Lang("Menu", "mnuGrdColCyan")))
    sLangAmber = Trim(UCase(Lang("Menu", "mnuGrdColAmber")))
    sLangUV = Trim(UCase(Lang("Menu", "mnuGrdColUV")))
    bStaticLoaded = #True
  EndIf
  
  Select Trim(UCase(sChannelDesc))
    Case "R", "RED", sLangRed
      nDMXTextColor = #SCS_Red
    Case "G", "GREEN", sLangGreen
      nDMXTextColor = #SCS_Dark_Green ; a darker green than RGB(0,255,0) as this shows up better against the 'very light grey' background
    Case "B", "BLUE", sLangBlue
      nDMXTextColor = #SCS_Blue
    Case "W", "WHITE", sLangWhite
      nDMXTextColor = #SCS_White
    Case "Y", "YELLOW", sLangYellow
      nDMXTextColor = #SCS_Yellow
    Case "C", "CYAN", sLangCyan
      nDMXTextColor = RGB(0,255,255) ; Also in WEP_mnuGridColor_Selection()
    Case "A", "AMBER", sLangAmber
      nDMXTextColor = RGB(255,191,0) ; Also in WEP_mnuGridColor_Selection()
    Case "UV", "ULTRAVIOLET", sLangUV
      nDMXTextColor = RGB(158,0,255) ; Also in WEP_mnuGridColor_Selection()
    Default
      nDMXTextColor = grFixTypeChanDef\nDMXTextColor ; nb grFixTypeChanDef\nDMXTextColor = -1
  EndSelect
  ProcedureReturn nDMXTextColor
EndProcedure

Procedure DMX_setDerivedDMXTextColors(*rProd.tyProd)
  PROCNAMEC()
  Protected nFixTypeIndex, nFixTypeChanIndex
  
  For nFixTypeIndex = 0 To ArraySize(*rProd\aFixTypes())
    For nFixTypeChanIndex = 0 To ArraySize(*rProd\aFixTypes(nFixTypeIndex)\aFixTypeChan())
      With *rProd\aFixTypes(nFixTypeIndex)\aFixTypeChan(nFixTypeChanIndex)
        If \nDMXTextColor = grFixTypeChanDef\nDMXTextColor ; nb grFixTypeChanDef\nDMXTextColor = -1
          \nDMXTextColor = DMX_setDMXTextColorFromDesc(\sChannelDesc)
        EndIf
      EndWith
    Next nFixTypeChanIndex
  Next nFixTypeIndex
  
EndProcedure

Procedure DMX_debugReceiveDMXPacket(*buffer, nBufferSize)
  PROCNAMEC()
  Protected rReceiveDMX.Struct_RECV_DMX
  Protected nDMXChannel, nMaxChannel, sMsg.s
  
  CopyMemory(*buffer, @rReceiveDMX, nBufferSize)
  
  If rReceiveDMX\status = 0
    If rReceiveDMX\ascData[0] = 0 ; start code
      CompilerIf #cTraceDMXSendChannels1to12
        nMaxChannel = 12
      CompilerElseIf #cTraceDMXSendChannels1to34
        nMaxChannel = 34
      CompilerEndIf
      If nMaxChannel > 0
        For nDMXChannel = 1 To nMaxChannel
          If nDMXChannel > 1
            sMsg + ", "
          EndIf
          sMsg + rReceiveDMX\ascData[nDMXChannel]
        Next nDMXChannel
      EndIf
    EndIf
  EndIf
  If sMsg
    debugMsg(sProcName, sMsg)
  EndIf
  
EndProcedure

Procedure DMX_debugChangeOfStatePacket(*buffer, nBufferSize)
  PROCNAMEC()
  Protected rCaptureChange.Struct_DMX_ChangeOfState
  Protected changed_byte_index, bit_array_index, byteindex
  Protected sMsg.s
  
  CopyMemory(*buffer, @rCaptureChange, nBufferSize)
  
  ; IMPORTANT: See "Received DMX Change Of State Packet (Label=9)" in the Enttec document "dmx_usb_pro_api_spec.pdf"
  ; ================================================================================================================
  ; Size In Bytes       Description
  ;      1              Start changed byte number.
  ;      5              Changed bit array, where array bit 0 is bit 0 of first byte and array bit 39 is bit 7 of last byte.
  ;    1 To 40          Changed DMX Data byte Array. One byte is present for each set bit in the Changed bit array.
  changed_byte_index = 0
  For byteindex = 0 To 4
    For bit_array_index = 0 To 7
      ; now pointing to a bit that contains the change state of a DMX channel number when also applying the start changed byte number
      If IsBitSet(rCaptureChange\Bitfield[byteindex], bit_array_index)
        If sMsg
          sMsg + ", "
        EndIf
        sMsg + "Ch:" + Str((rCaptureChange\byStart * 8) + ((byteindex * 8) + bit_array_index))
        sMsg + "=" + rCaptureChange\ascData[changed_byte_index]
        changed_byte_index + 1
      EndIf
    Next bit_array_index
  Next byteindex
  If sMsg
    debugMsg(sProcName, sMsg)
  EndIf
  
EndProcedure

Procedure DMX_SaveDMXPacketForCapture(nDMXControlPtr, *buffer, nBufferSize)
  PROCNAMEC()
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", nDMXControlPtr=" + nDMXControlPtr + ", nBufferSize=" + nBufferSize)
  
  debugMsgC(sProcName, "grDMX\nMaxDMXCapture=" + grDMX\nMaxDMXCapture + ", grDMX\nDMXCaptureLimit=" + grDMX\nDMXCaptureLimit)
  If grDMX\nMaxDMXCapture < grDMX\nDMXCaptureLimit
    grDMX\nMaxDMXCapture + 1
    debugMsgC(sProcName, "grDMX\nMaxDMXCapture=" + grDMX\nMaxDMXCapture)
    If grDMX\nMaxDMXCapture > ArraySize(gaDMXCapture())
      ReDim gaDMXCapture(grDMX\nMaxDMXCapture + 100)
    EndIf
    With gaDMXCapture(grDMX\nMaxDMXCapture)
      \nCaptureNo = grDMX\nDMXCaptureNo
      \qCaptureTime = ElapsedMilliseconds()
      \nCaptureLabel = PeekA(*buffer+1)
      \wCaptureBufferLength = PeekW(*buffer+2)
      debugMsgC(sProcName, "gaDMXCapture(" + grDMX\nMaxDMXCapture + ")\nCaptureLabel=" + \nCaptureLabel + ", \wCaptureBufferLength=" + \wCaptureBufferLength)
      If \wCaptureBufferLength > 0 And \wCaptureBufferLength <= 514
        CopyMemory(*buffer+4, @\aCaptureBuffer[0], \wCaptureBufferLength)
      EndIf
      Select \nCaptureLabel
        Case #ENTTEC_RECEIVED_DMX_PORT1, #ENTTEC_RECEIVED_DMX_PORT2
          If bTrace
            DMX_debugReceiveDMXPacket(*buffer, nBufferSize)
          EndIf
        Case #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1, #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2
          If bTrace
            DMX_debugChangeOfStatePacket(*buffer, nBufferSize)
          EndIf
          grDMX\bRequestNextImmediately = #True ; Whenever we receive and save a 'DMX Change Of State Packet', request another read immediately
          CompilerIf #cTraceDMX
            debugMsg(sProcName, "grDMX\bRequestNextImmediately=#True")
          CompilerEndIf
      EndSelect
    EndWith
    grDMX\qTimeLastDMXPacketForCaptureSaved = ElapsedMilliseconds()
  Else
    If grDMX\bDMXCaptureLimitWarningDisplayed = #False
      grDMX\bDMXCaptureLimitWarningDisplayed = #True
      MessageRequester("DMX Capture", "Exceeded maximum of " + grDMX\nDMXCaptureLimit + " DMX 'change of state' messages - remainder discarded", #PB_MessageRequester_Warning)
    EndIf
  EndIf
  
EndProcedure

Procedure DMX_loadDMXCaptureItemArray()
  PROCNAMECS(nEditSubPtr)
  Protected nDMXCaptureIndex, rCaptureReceive.Struct_RECV_DMX, rCaptureChange.Struct_DMX_ChangeOfState
  Protected rDMXCaptureItem.tyDMXCaptureItem
  Protected changed_byte_index, bit_array_index, byteindex, nDMXChannel, nDataByteIndex
  Protected nDataOffset = OffsetOf(Struct_RECV_DMX\ascData), nDMXStartCode.a, nDMXValue.a, nDMXDataLength.w
  Protected nMostRecentDMXValue.a, qMostRecentCaptureTime.q
  Protected qStartTime.q
  Protected Dim aDMXChannelValue.a(512), Dim qDMXChannelLastCaptureTime.q(512)
  Protected n
  Protected ascStartCode.a, wDataLength.w
  Protected bChangeOfStatePresent
  Static nItemSequence
  Protected bTrace = #False
  
  debugMsgC(sProcName, #SCS_START + ", grDMX\nMaxDMXCapture=" + grDMX\nMaxDMXCapture)
  
  If grDMX\nMaxDMXCapture > 0
    debugMsgC(sProcName, "changing gaDMXCapture(0)\qCaptureTime from " + traceTime(gaDMXCapture(0)\qCaptureTime) + " to " + traceTime(gaDMXCapture(1)\qCaptureTime))
    gaDMXCapture(0)\qCaptureTime = gaDMXCapture(1)\qCaptureTime
  EndIf
  qStartTime = gaDMXCapture(0)\qCaptureTime
  
  grDMX\nMaxDMXCaptureItem = -1
  For nDMXCaptureIndex = 0 To grDMX\nMaxDMXCapture
    With gaDMXCapture(nDMXCaptureIndex)
      rDMXCaptureItem\qCaptureTime = \qCaptureTime
      rDMXCaptureItem\nCaptureElapsedTime = rDMXCaptureItem\qCaptureTime - qStartTime
      rDMXCaptureItem\nCaptureElapsedTimeAdj = Round(rDMXCaptureItem\nCaptureElapsedTime / 100, #PB_Round_Nearest) * 100 ; save elapsed time to the nearest 0.1 second
      If rDMXCaptureItem\nCaptureElapsedTimeAdj <= 100
        ; if <= 0.1 second, assume no delay time
        rDMXCaptureItem\nCaptureElapsedTimeAdj = 0
      EndIf
      Select \nCaptureLabel
        Case #ENTTEC_RECEIVED_DMX_PORT1, #ENTTEC_RECEIVED_DMX_PORT2
          rCaptureReceive\status = \aCaptureBuffer[0]
          CopyMemory(@\aCaptureBuffer[0], @rCaptureReceive\ascData[0], \wCaptureBufferLength)
          DisableDebugger ; !!!!!!!!!! Debugger disabled to improve peformance whilst checking for a change in the DMX channel values
          ascStartCode = rCaptureReceive\ascData[0]
          wDataLength = \wCaptureBufferLength
          ; debugMsg(sProcName, "ascStartCode=" + ascStartCode + ", wDataLength=" + wDataLength)
          For n = 1 To (wDataLength - 1)
            nDMXValue = rCaptureReceive\ascData[n]
            nDMXChannel = ascStartCode + (n - 1)
            If nDMXValue <> aDMXChannelValue(nDMXChannel) Or grWQK\bStartingCapture ; bStartingCapture test added 15Jun2023 11.10.0bg
              rDMXCaptureItem\nCaptureChannel = nDMXChannel
              rDMXCaptureItem\nCaptureValue = nDMXValue
              If qDMXChannelLastCaptureTime(nDMXChannel) > 0
                rDMXCaptureItem\nCaptureChannelTimeDelta = rDMXCaptureItem\qCaptureTime - qDMXChannelLastCaptureTime(nDMXChannel)
                rDMXCaptureItem\nCaptureChannelTimeDeltaAdj = Round(rDMXCaptureItem\nCaptureChannelTimeDelta / 100, #PB_Round_Nearest) * 100 ; save change in time (time delta) to the nearest 0.1 second
              Else
                rDMXCaptureItem\nCaptureChannelTimeDelta = 0
                rDMXCaptureItem\nCaptureChannelTimeDeltaAdj = 0
              EndIf
              nItemSequence + 1
              rDMXCaptureItem\nItemSequence = nItemSequence
              grDMX\nMaxDMXCaptureItem + 1
              If grDMX\nMaxDMXCaptureItem > ArraySize(gaDMXCaptureItem())
                debugMsg(sProcName, "calling ReDim gaDMXCaptureItem(" + Str(grDMX\nMaxDMXCaptureItem + 100) + ")")
                ReDim gaDMXCaptureItem(grDMX\nMaxDMXCaptureItem + 100)
              EndIf
              gaDMXCaptureItem(grDMX\nMaxDMXCaptureItem) = rDMXCaptureItem
              debugMsgC(sProcName, "changed: gaDMXCaptureItem(" + grDMX\nMaxDMXCaptureItem + ")\nCaptureChannel=" + rDMXCaptureItem\nCaptureChannel + ", \nCaptureValue=" + rDMXCaptureItem\nCaptureValue +
                                   ", \qCaptureTime=" + traceTime(rDMXCaptureItem\qCaptureTime) + ", \nItemSequence=" + rDMXCaptureItem\nItemSequence + ", qStartTime=" + traceTime(qStartTime) +
                                   ", \nCaptureElapsedTime=" + rDMXCaptureItem\nCaptureElapsedTime + ", \nCaptureElapsedTimeAdj=" + rDMXCaptureItem\nCaptureElapsedTimeAdj +
                                   ", \nCaptureChannelTimeDelta=" + rDMXCaptureItem\nCaptureChannelTimeDelta + ", \nCaptureChannelTimeDeltaAdj=" + rDMXCaptureItem\nCaptureChannelTimeDeltaAdj)
              aDMXChannelValue(rDMXCaptureItem\nCaptureChannel) = rDMXCaptureItem\nCaptureValue
              If grWQK\bStartingCapture
                debugMsg(sProcName, "setting grWQK\bStartingCapture=#False")
                grWQK\bStartingCapture = #False ; Added 15Jun2023 11.10.0bg
              EndIf
            EndIf
            ; Setting qDMXChannelLastCaptureTime(channel) must be OUTSIDE the test on value change, as it will record the last time (so far) that the channel had the value in aDMXChannelValue(channel)
            qDMXChannelLastCaptureTime(rDMXCaptureItem\nCaptureChannel) = rDMXCaptureItem\qCaptureTime
          Next n
          EnableDebugger ; !!!!!!!!!! Debugger enabled again
            
        Case #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT1, #ENTTEC_RECEIVED_DMX_CHANGE_OF_STATE_PORT2
          ; CopyMemory(*buffer, @rCaptureChange, nBufferSize)
          
          rCaptureChange\byStart = \aCaptureBuffer[0]
          For n = 0 To 4
            rCaptureChange\Bitfield[n] = \aCaptureBuffer[n+1]
          Next n
          CopyMemory(@\aCaptureBuffer[6], @rCaptureChange\ascData[0], \wCaptureBufferLength)
          debugMsgC(sProcName, "rCaptureChange\byStart=" + rCaptureChange\byStart + ", rCaptureChange\Bitfield[0]=$" + Hex(rCaptureChange\Bitfield[0]) +
                               ", [1]=$" + Hex(rCaptureChange\Bitfield[1]) + ", [2]=$" + Hex(rCaptureChange\Bitfield[2]) + ", [3]=$" + Hex(rCaptureChange\Bitfield[3]) + ", [4]=$" + Hex(rCaptureChange\Bitfield[4]) +
                               ", rCaptureChange\ascData[0]=" + rCaptureChange\ascData[0])
          ; IMPORTANT: See "Received DMX Change Of State Packet (Label=9)" in the Enttec document "dmx_usb_pro_api_spec.pdf"
          ; ================================================================================================================
          ; Size In Bytes       Description
          ;      1              Start changed byte number.
          ;      5              Changed bit array, where array bit 0 is bit 0 of first byte and array bit 39 is bit 7 of last byte.
          ;    1 To 40          Changed DMX Data byte Array. One byte is present for each set bit in the Changed bit array.
          changed_byte_index = 0
          For byteindex = 0 To 4
            For bit_array_index = 0 To 7
              ; now pointing to a bit that contains the change state of a DMX channel number when also applying the start changed byte number
              If IsBitSet(rCaptureChange\Bitfield[byteindex], bit_array_index)
                nDMXChannel = (rCaptureChange\byStart * 8) + ((byteindex * 8) + bit_array_index)
                nDMXValue = rCaptureChange\ascData[changed_byte_index]
                If nDMXValue <> aDMXChannelValue(nDMXChannel)
                  rDMXCaptureItem\nCaptureChannel = nDMXChannel
                  rDMXCaptureItem\nCaptureValue = nDMXValue
                  If qDMXChannelLastCaptureTime(nDMXChannel) > 0
                    rDMXCaptureItem\nCaptureChannelTimeDelta = \qCaptureTime - qDMXChannelLastCaptureTime(nDMXChannel)
                    ; rDMXCaptureItem\nCaptureChannelTimeDeltaAdj = Round(rDMXCaptureItem\nCaptureChannelTimeDelta / 100, #PB_Round_Nearest) * 100 ; save change in time (time delta) to the nearest 0.1 second
                    rDMXCaptureItem\nCaptureChannelTimeDeltaAdj = rDMXCaptureItem\nCaptureChannelTimeDelta ; Changed 22Jul2023 11.10.0bq
                  Else
                    rDMXCaptureItem\nCaptureChannelTimeDelta = 0
                    rDMXCaptureItem\nCaptureChannelTimeDeltaAdj = 0
                  EndIf
                  nItemSequence + 1
                  rDMXCaptureItem\nItemSequence = nItemSequence
                  grDMX\nMaxDMXCaptureItem + 1
                  If grDMX\nMaxDMXCaptureItem > ArraySize(gaDMXCaptureItem())
                    ReDim gaDMXCaptureItem(grDMX\nMaxDMXCaptureItem + 100)
                  EndIf
                  gaDMXCaptureItem(grDMX\nMaxDMXCaptureItem) = rDMXCaptureItem
                  debugMsgC(sProcName, "changed: gaDMXCaptureItem(" + grDMX\nMaxDMXCaptureItem + ")\nCaptureChannel=" + rDMXCaptureItem\nCaptureChannel + ", \nCaptureValue=" + rDMXCaptureItem\nCaptureValue +
                                       ", \qCaptureTime=" + traceTime(rDMXCaptureItem\qCaptureTime) + ", \nItemSequence=" + rDMXCaptureItem\nItemSequence + ", qStartTime=" + traceTime(qStartTime) +
                                       ", \nCaptureElapsedTime=" + rDMXCaptureItem\nCaptureElapsedTime + ", \nCaptureElapsedTimeAdj=" + rDMXCaptureItem\nCaptureElapsedTimeAdj +
                                       ", \nCaptureChannelTimeDelta=" + rDMXCaptureItem\nCaptureChannelTimeDelta + ", \nCaptureChannelTimeDeltaAdj=" + rDMXCaptureItem\nCaptureChannelTimeDeltaAdj)
                  ; debugMsg(sProcName, "changed: (" + grDMX\nMaxDMXCaptureItem + ")\nCaptureChannel=" + rDMXCaptureItem\nCaptureChannel + ", \nCaptureValue=" + rDMXCaptureItem\nCaptureValue +
                  ;                     ", \qCaptureTime=" + rDMXCaptureItem\qCaptureTime + ", \nCaptureElapsedTime=" + rDMXCaptureItem\nCaptureElapsedTime + ", \nCaptureChannelTimeDelta=" + rDMXCaptureItem\nCaptureChannelTimeDelta)
                  aDMXChannelValue(rDMXCaptureItem\nCaptureChannel) = rDMXCaptureItem\nCaptureValue
                EndIf
                ; Setting qDMXChannelLastCaptureTime(channel) must be OUTSIDE the test on value change, as it will record the last time (so far) that the channel had the value in aDMXChannelValue(channel)
                qDMXChannelLastCaptureTime(rDMXCaptureItem\nCaptureChannel) = \qCaptureTime
                changed_byte_index + 1
              EndIf
            Next bit_array_index
          Next byteindex
      EndSelect
    EndWith
  Next nDMXCaptureIndex
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure DMX_getFirstCaptureItemIndexForChannel(nDMXChannel)
  Protected nFirstItemIndexForChannel, nItemIndex
  
  nFirstItemIndexForChannel = -1
  For nItemIndex = 0 To grDMX\nMaxDMXCaptureItem
    If gaDMXCaptureItem(nItemIndex)\nCaptureChannel = nDMXChannel
      nFirstItemIndexForChannel = nItemIndex
      Break
    EndIf
  Next nItemIndex
  ProcedureReturn nFirstItemIndexForChannel
EndProcedure

Procedure DMX_getPrevCaptureItemIndexForChannel(nThisItemIndex)
  Protected nPrevItemIndex, nItemIndex, nDMXChannel
  
  nPrevItemIndex = -1
  nDMXChannel = gaDMXCaptureItem(nThisItemIndex)\nCaptureChannel
  For nItemIndex = (nThisItemIndex - 1) To 0 Step -1
    If gaDMXCaptureItem(nItemIndex)\nCaptureChannel = nDMXChannel And gaDMXCaptureItem(nItemIndex)\bDeleteThisItem = #False
      nPrevItemIndex = nItemIndex
      Break
    EndIf
  Next nItemIndex
  ProcedureReturn nPrevItemIndex
EndProcedure

Procedure DMX_removeCaptureShakes()
  PROCNAMEC()
  Protected nDMXChannel, nItemIndex1, nItemIndex2, nItemIndex3
  Protected nRemovedItems
  
  For nDMXChannel = 1 To 512
    nRemovedItems = 0
    For nItemIndex1 = grDMX\nMaxDMXCaptureItem To 0 Step -1
      If gaDMXCaptureItem(nItemIndex1)\nCaptureChannel = nDMXChannel And gaDMXCaptureItem(nItemIndex1)\bDeleteThisItem = #False
        nItemIndex2 = DMX_getPrevCaptureItemIndexForChannel(nItemIndex1)
        If nItemIndex2 >= 0
          nItemIndex3 = DMX_getPrevCaptureItemIndexForChannel(nItemIndex2)
          If nItemIndex3 >= 0
            If gaDMXCaptureItem(nItemIndex3)\nCaptureValue = gaDMXCaptureItem(nItemIndex1)\nCaptureValue
              If gaDMXCaptureItem(nItemIndex1)\qCaptureTime - gaDMXCaptureItem(nItemIndex3)\qCaptureTime > 125
                gaDMXCaptureItem(nItemIndex1)\bDeleteThisItem = #True
                gaDMXCaptureItem(nItemIndex2)\bDeleteThisItem = #True
                nRemovedItems + 2
              EndIf
            EndIf
          EndIf
        EndIf
      EndIf
    Next nItemIndex1
    If nRemovedItems > 0
      debugMsg(sProcName,"Marked " + nRemovedItems + " items for removal for channel " + nDMXChannel)
    EndIf
  Next nDMXChannel
EndProcedure

Procedure DMX_removeItemsToBeDeleted()
  PROCNAMEC()
  Protected nItemIndex1, nItemIndex2
  
  nItemIndex2 = -1
  For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
    If gaDMXCaptureItem(nItemIndex1)\bDeleteThisItem = #False
      nItemIndex2 + 1
      gaDMXCaptureItem(nItemIndex2) = gaDMXCaptureItem(nItemIndex1)
    EndIf
  Next nItemIndex1
  If nItemIndex2 <> grDMX\nMaxDMXCaptureItem
    debugMsg(sProcName, "Changing grDMX\nMaxDMXCaptureItem from " + grDMX\nMaxDMXCaptureItem + " to " + nItemIndex2)
    grDMX\nMaxDMXCaptureItem = nItemIndex2
  EndIf
EndProcedure

Procedure DMX_deriveCaptureFades()
  ; derive fade times for capture DMX channel values, but only for channel numbers that correspond to 'dimmer' channels in the Fixture Types
  PROCNAMEC()
  Protected nDMXChannel, nItemIndex1, nItemIndex2
  Protected nPrevItemIndexForChannel, nFirstItemIndexForChannel
  Protected rFirstItem.tyDMXCaptureItem, rLastItem.tyDMXCaptureItem
  Protected nLastItemIndex, nItemCount, nValueIncreaseCount, nValueDecreaseCount, nSmallestTimeDelta.l, nLargestTimeDelta.l, nTotalTime, fAverageTimeDelta.f
  Protected nValueChange, nSmallestValueChange, nLargestValueChange, nTotalValueChange, fAverageValueChange.f
  Protected fReqdFadeTime.f, bChannelProcessed
  Protected nMaxUsedItem, nCurrTimeSlot, nLastCaptureElapsedTimeAdj, nLastCaptureValue
  Protected nCaptureDirection, nLastCaptureDirection ; 0 = not set; -1 = down; +1 = up
  Protected Dim nChannelTimeSlots(512)
  Protected bTrace = #False
  
  For nDMXChannel = 1 To 512
    nCurrTimeSlot = 0
    For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
      If gaDMXCaptureItem(nItemIndex1)\nCaptureChannel = nDMXChannel
        ; The first entry for this channel is to be saved in it's own timeslot to force this to be saved, even if it's at the start of a fade
        nCurrTimeSlot = 1
        gaDMXCaptureItem(nItemIndex1)\nCaptureTimeSlot = nCurrTimeSlot
        nCurrTimeSlot + 1
        nLastCaptureElapsedTimeAdj = 0
        nLastCaptureValue = gaDMXCaptureItem(nItemIndex1)\nCaptureValue
        nLastCaptureDirection = 0
        For nItemIndex2 = nItemIndex1 + 1 To grDMX\nMaxDMXCaptureItem
          With gaDMXCaptureItem(nItemIndex2)
            If \nCaptureChannel = nDMXChannel
              If \nCaptureValue > nLastCaptureValue
                nCaptureDirection = 1
              ElseIf \nCaptureValue < nLastCaptureValue
                nCaptureDirection = -1
              Else
                nCaptureDirection = 0
              EndIf
              If \nCaptureElapsedTimeAdj > nLastCaptureElapsedTimeAdj + 750
                ; more than 0.75 second since last captured item for this channel, so assume this is a new change
                nCurrTimeSlot + 1
              ; NOTE: Removed the 'change of direction' test 25Jul2023 11.10.0bq as this can result in numerous entries due to minor
              ; NOTE: value + or - changes while moving a lighting fader, as tested using another computer sending from Enttec Pro Manager.
              ; NOTE: A change of direction will be handled anyway if the previous captured item was more than 0.75 seconds ago.
;               ElseIf nLastCaptureDirection <> 0 And nCaptureDirection <> 0 And nCaptureDirection <> nLastCaptureDirection
;                 ; change of direction, so assume a new change
;                 nCurrTimeSlot + 1
              EndIf
              \nCaptureTimeSlot = nCurrTimeSlot
              nLastCaptureElapsedTimeAdj = \nCaptureElapsedTimeAdj
              nLastCaptureValue = \nCaptureValue
              nLastCaptureDirection = nCaptureDirection
            EndIf
          EndWith
        Next nItemIndex2
        Break ; go to next channel
      EndIf
    Next nItemIndex1
    nChannelTimeSlots(nDMXChannel) = nCurrTimeSlot
    CompilerIf #cTraceDMX
      If nDMXChannel < 13 And nChannelTimeSlots(nDMXChannel) > 0
        debugMsg(sProcName, "nChannelTimeSlots(" + nDMXChannel + ")=" + nChannelTimeSlots(nDMXChannel))
      EndIf
    CompilerEndIf
  Next nDMXChannel
  
  For nDMXChannel = 1 To 512
    CompilerIf #cTraceDMX
      If nDMXChannel < 13
        debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", nChannelTimeSlots(" + nDMXChannel + ")=" + nChannelTimeSlots(nDMXChannel))
      EndIf
    CompilerEndIf
    For nCurrTimeSlot = 1 To nChannelTimeSlots(nDMXChannel)
      bChannelProcessed = #False
      For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
        If gaDMXCaptureItem(nItemIndex1)\nCaptureChannel = nDMXChannel And gaDMXCaptureItem(nItemIndex1)\nCaptureTimeSlot = nCurrTimeSlot
          rFirstItem = gaDMXCaptureItem(nItemIndex1)
          nItemCount = 1
          nValueIncreaseCount = 0
          nValueDecreaseCount = 0
          nSmallestTimeDelta = $7FFFFFFF ; maximum 'long' value
          nLargestTimeDelta = 0
          nSmallestValueChange = 255
          nLargestValueChange = 0
          nLastItemIndex = nItemIndex1
          For nItemIndex2 = nItemIndex1 + 1 To grDMX\nMaxDMXCaptureItem
            With gaDMXCaptureItem(nItemIndex2)
              If \nCaptureChannel = nDMXChannel And \nCaptureTimeSlot = nCurrTimeSlot
                nItemCount + 1
                If \nCaptureValue >= gaDMXCaptureItem(nLastItemIndex)\nCaptureValue
                  nValueIncreaseCount + 1
                Else
                  nValueDecreaseCount + 1
                EndIf
                If nItemCount > 1
                  nValueChange = \nCaptureValue - gaDMXCaptureItem(nLastItemIndex)\nCaptureValue
                  If nValueChange < nSmallestValueChange
                    nSmallestValueChange = nValueChange
                  EndIf
                  If nValueChange > nLargestValueChange
                    nLargestValueChange = nValueChange
                  EndIf
                  If \nCaptureChannelTimeDelta < nSmallestTimeDelta
                    ; nSmallestTimeDeltaAdj = \nCaptureChannelTimeDeltaAdj
                    nSmallestTimeDelta = \nCaptureChannelTimeDelta
                  EndIf
                  If \nCaptureChannelTimeDelta > nLargestTimeDelta
                    ; nLargestTimeDeltaAdj = \nCaptureChannelTimeDeltaAdj
                    nLargestTimeDelta = \nCaptureChannelTimeDelta
                  EndIf
                EndIf
                nLastItemIndex = nItemIndex2
              EndIf
            EndWith
          Next nItemIndex2
          If nItemCount > 5
            ; arbitrary decision to derive fades only when there are more than 5 DMX values captured for this channel
            rLastItem = gaDMXCaptureItem(nLastItemIndex)
            nTotalTime = rLastItem\qCaptureTime - rFirstItem\qCaptureTime + 1
            fAverageTimeDelta = nTotalTime / nItemCount
            nTotalValueChange = rLastItem\nCaptureValue - rFirstItem\nCaptureValue
            fAverageValueChange = nTotalValueChange / nItemCount
            CompilerIf #cTraceDMX
              If nDMXChannel < 13
                debugMsg(sProcName, "nDMXChannel=" + nDMXChannel + ", nCurrTimeSlot=" + nCurrTimeSlot + ", nItemCount=" + nItemCount +
                                    ", nTotalTime=" + nTotalTime + ", fAverageTimeDelta=" + StrF(fAverageTimeDelta,2) +
                                    ", nSmallestTimeDelta=" + nSmallestTimeDelta + ", nLargestTimeDelta=" + nLargestTimeDelta +
                                    ", nValueIncreaseCount=" + nValueIncreaseCount + ", nValueDecreaseCount=" + nValueDecreaseCount +
                                    ", nTotalValueChange=" + nTotalValueChange + ", nSmallestValueChange=" + nSmallestValueChange + ", nLargestValueChange=" + nLargestValueChange + ", fAverageValueChange=" + StrF(fAverageValueChange,2))
              EndIf
            CompilerEndIf
            If (nLargestTimeDelta - nSmallestTimeDelta) <= 500
              ; difference between largest time delta and smallest time delta is <= 0.5 second
              fReqdFadeTime = (nTotalTime + Int(fAverageTimeDelta)) / 1000 ; effectively round down average time delta - adding this allows for the final stage of the original fade
              With gaDMXCaptureItem(nItemIndex1)
                \sItemValue = "@d" + rLastItem\nCaptureValue
                \sItemFadeTime = "f" + trimZeroDecimals(StrF(fReqdFadeTime,1))
                If \nCaptureElapsedTimeAdj = 0
                  \sItemData = Str(nDMXChannel) + \sItemValue + \sItemFadeTime
                Else
                  \sItemData = "[" + trimZeroDecimals(StrF(\nCaptureElapsedTimeAdj/1000,1)) + "]" + nDMXChannel + \sItemValue + \sItemFadeTime
                EndIf
                \bUseThisItem = #True
                ; check if previous entry is superfluous and should be removed
                nFirstItemIndexForChannel = DMX_getFirstCaptureItemIndexForChannel(\nCaptureChannel)
                If nFirstItemIndexForChannel >= 0 And nFirstItemIndexForChannel < nItemIndex1
                  nPrevItemIndexForChannel = DMX_getPrevCaptureItemIndexForChannel(nItemIndex1)
                  If nPrevItemIndexForChannel = nFirstItemIndexForChannel
                    If gaDMXCaptureItem(nPrevItemIndexForChannel)\nCaptureElapsedTimeAdj = \nCaptureElapsedTimeAdj
                      If gaDMXCaptureItem(nPrevItemIndexForChannel)\nCaptureValue < 8
                        gaDMXCaptureItem(nPrevItemIndexForChannel)\bUseThisItem = #False
                        CompilerIf #cTraceDMX
                          debugMsg(sProcName, "ignoring gaDMXCaptureItem(" + nPrevItemIndexForChannel + ")\nCaptureChannel=" + gaDMXCaptureItem(nPrevItemIndexForChannel)\nCaptureChannel +
                                              ", \sItemData=" + gaDMXCaptureItem(nPrevItemIndexForChannel)\sItemData)
                        CompilerEndIf
                      EndIf
                    EndIf
                  EndIf
                EndIf
              EndWith
              bChannelProcessed = #True
            EndIf
          EndIf ; EndIf nItemCount > 5
          Break ; Break nItemIndex1 to go to next DMX channel
        EndIf ; EndIf gaDMXCaptureItem(nItemIndex1)\nCaptureChannel = nDMXChannel
      Next nItemIndex1
      If bChannelProcessed = #False
        For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
          If gaDMXCaptureItem(nItemIndex1)\nCaptureChannel = nDMXChannel And gaDMXCaptureItem(nItemIndex1)\nCaptureTimeSlot = nCurrTimeSlot
            With gaDMXCaptureItem(nItemIndex1)
              \sItemValue = "@d" + \nCaptureValue
              If \nCaptureElapsedTimeAdj <= 100
                \sItemData = Str(nDMXChannel) + \sItemValue
              Else
                \sItemData = "[" + trimZeroDecimals(StrF(\nCaptureElapsedTimeAdj/1000,1)) + "]" + nDMXChannel + \sItemValue
              EndIf
              \bUseThisItem = #True
            EndWith
          EndIf
        Next nItemIndex1
        bChannelProcessed = #True
      EndIf
    Next nCurrTimeSlot
  Next nDMXChannel
  
  ; Sort the gaDMXCaptureItem() array in the order 'elapsed time adjusted', 'DMX channel'.
  ; All 'unused' items will be sorted to the end, and grDMX\nMaxDMXCaptureItem will be reset to point to the last 'used' item.
  nMaxUsedItem = -1
  For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
    With gaDMXCaptureItem(nItemIndex1)
      If \bUseThisItem
        ; \qSortKey = (((\nCaptureElapsedTimeAdj * 1000) + \nCaptureChannel) * 10000000) + \nItemSequence
        ; \qSortKey = (\nCaptureChannel * 10000000000) + (\nCaptureElapsedTimeAdj * 10000) + \nItemSequence
        ; \qSortKey = (((\nCaptureTimeSlot * 1000) + \nCaptureChannel) * 10000000) + \nItemSequence
        ; \qSortKey = ((((\nCaptureElapsedTimeAdj * 100000) + \nCaptureTimeSlot * 1000) + \nCaptureChannel) * 10000000) + \nItemSequence
        \qSortKey = (((\nCaptureElapsedTimeAdj * 1000) + \nCaptureChannel) * 10000000) + \nCaptureTimeSlot
        nMaxUsedItem + 1
      Else
        \qSortKey = $7FFFFFFFFFFFFFFF ; maximum quad value - will sort all unused items to the end (order within unused items not important)
      EndIf
    EndWith
  Next nItemIndex1
  SortStructuredArray(gaDMXCaptureItem(), #PB_Sort_Ascending, OffsetOf(tyDMXCaptureItem\qSortKey), #PB_Quad, 0, grDMX\nMaxDMXCaptureItem)
  grDMX\nMaxDMXCaptureItem = nMaxUsedItem
  ; End of sort code
  
  CompilerIf #cTraceDMX
    For nItemIndex1 = 0 To grDMX\nMaxDMXCaptureItem
      With gaDMXCaptureItem(nItemIndex1)
        debugMsg(sProcName, "gaDMXCaptureItem(" + nItemIndex1 + ")\qSortKey=" + \qSortKey +
                            ", \nCaptureTimeSlot=" + \nCaptureTimeSlot + ", \nCaptureElapsedTimeAdj=" + \nCaptureElapsedTimeAdj + ", \nCaptureChannel=" + \nCaptureChannel + ", \sItemData=" + \sItemData)
      EndWith
    Next nItemIndex1
  CompilerEndIf
  
EndProcedure

Procedure DMX_calcChannelStartValueAtDelayTime(nDMXControlPtr, nDMXChannel, nDelayTime)
  PROCNAMEC()
  Protected nChannelStartValue, nDMXPort, nDMXSendDataBaseIndex, nItemIndex, f
  
  nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
  nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex ; nb nDMXSendDataBaseIndex will be 0 for port 1, or 512 for port 2
  nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
  CompilerIf #cTraceDMX
    debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex))
  CompilerEndIf
  nChannelStartValue = gaDMXSendData(nItemIndex)
  If nDelayTime > 0
    For f = 0 To grDMXFadeItems\nMaxFadeItem
      With grDMXFadeItems\aFadeItem(f)
        If \nDMXPort = nDMXPort And \nDMXChannel = nDMXChannel
          If nDelayTime = 0 And \nDMXDelayTime = 0
            nChannelStartValue = \nTargetValue
          ElseIf \nDMXDelayTime < nDelayTime
            nChannelStartValue = \nTargetValue
          EndIf
        EndIf
      EndWith
    Next f
  EndIf
  
  CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
    If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35)
      debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr + ", nDMXChannel=" + nDMXChannel + ", nDelayTime=" + nDelayTime + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem +
                          ", returning nChannelStartValue=" + nChannelStartValue)
    EndIf
  CompilerEndIf
  ProcedureReturn nChannelStartValue
EndProcedure

Procedure DMX_calcChannelTargetValueAtDelayTime(pSubPtr, nDMXControlPtr, nDMXChannel, nDelayTime)
  CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
    PROCNAMECS(pSubPtr)
  CompilerEndIf
  Protected nChannelTargetValue, nItemIndex
  Protected sDMXChannels.s, nPartCount, nPart, sPart.s, sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel, nDashCount
  
  ; debugMsg(sProcName, "nDMXControlPtr=" + nDMXControlPtr + ", nDMXChannel=" + nDMXChannel + ", nDelayTime=" + nDelayTime)
  
  nChannelTargetValue = -1 ; if nChannelTargetValue remains at -1 this indicates no target value was calculated for this channel, port and delay time
  If nDMXControlPtr = aSub(pSubPtr)\nDMXControlPtr
    With aSub(pSubPtr)\aChaseStep(0)
      For nItemIndex = 0 To \nDMXSendItemCount-1
        If \aDMXSendItem(nItemIndex)\nDMXDelayTime = nDelayTime
          sDMXChannels = \aDMXSendItem(nItemIndex)\sDMXChannels
          nPartCount = CountString(sDMXChannels, ",") + 1
          For nPart = 1 To nPartCount
            sPart = StringField(sDMXChannels, nPart, ",")
            nDashCount = CountString(sPart, "-")
            Select nDashCount
              Case 0
                sFromChannel = sPart
                sUpToChannel = sPart
              Case 1
                sFromChannel = StringField(sPart, 1, "-")
                sUpToChannel = StringField(sPart, 2, "-")
            EndSelect
            nFromChannel = Val(sFromChannel)
            nUpToChannel = Val(sUpToChannel)
            If nDMXChannel >= nFromChannel And nDMXChannel <= nUpToChannel
              ; found the required entry for this channel
              nChannelTargetValue = \aDMXSendItem(nItemIndex)\nDMXValue
            EndIf
          Next nPart
        EndIf
      Next nItemIndex
    EndWith
  EndIf
  
  CompilerIf #cTraceDMXSendChannels1to12 Or #cTraceDMXSendChannels1to34
    If (#cTraceDMXSendChannels1to12 And nDMXChannel < 13) Or (#cTraceDMXSendChannels1to34 And nDMXChannel < 35)
      debugMsg(sProcName, "\sLTLogicalDev=" + aSub(pSubPtr)\sLTLogicalDev + ", nDMXControlPtr=" + nDMXControlPtr + ", nDMXChannel=" + nDMXChannel + ", nDelayTime=" + nDelayTime + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem +
                          ", returning nChannelTargetValue=" + nChannelTargetValue)
    EndIf
  CompilerEndIf
  ProcedureReturn nChannelTargetValue
EndProcedure

Procedure DMX_buildSubDMXDelayTimeArray(pSubPtr)
  PROCNAMECS(pSubPtr)
  Protected nStepIndex, nDMXSendItemIndex, nMaxDMXSendItemIndex, nArrayItemIndex, nDelayTime, n, bNewDelayTime
  
  ; Added 4Sep2020 11.8.3.2au primarily for non-capture entry types
  grDMX\nMaxSubDMXDelayTimeIndex = 0
  grDMX\nSubDMXDelayTime(0) = 0
  ; End added 4Sep2020 11.8.3.2au
  
  Select aSub(pSubPtr)\nLTEntryType
    Case #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ, #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
      nArrayItemIndex = -1
      nStepIndex = 0
      nMaxDMXSendItemIndex = aSub(pSubPtr)\aChaseStep(nStepIndex)\nDMXSendItemCount - 1
      If ArraySize(grDMX\nSubDMXDelayTime()) < nMaxDMXSendItemIndex
        ReDim grDMX\nSubDMXDelayTime(nMaxDMXSendItemIndex)
      EndIf
      For nDMXSendItemIndex = 0 To nMaxDMXSendItemIndex
        With aSub(pSubPtr)\aChaseStep(nStepIndex)\aDMXSendItem(nDMXSendItemIndex)
          If Trim(\sDMXItemStr)
            nDelayTime = \nDMXDelayTime
            bNewDelayTime = #True
            For n = 0 To nArrayItemIndex
              If nDelayTime = grDMX\nSubDMXDelayTime(n)
                ; an earlier item has the same delay time (nb may be zero)
                bNewDelayTime = #False
                Break
              EndIf
            Next n
            If bNewDelayTime
              nArrayItemIndex + 1
              grDMX\nSubDMXDelayTime(nArrayItemIndex) = \nDMXDelayTime
            EndIf
          EndIf
        EndWith
      Next nDMXSendItemIndex
      If nArrayItemIndex >= 0
        SortArray(grDMX\nSubDMXDelayTime(), #PB_Sort_Ascending, 0, nArrayItemIndex)
        grDMX\nMaxSubDMXDelayTimeIndex = nArrayItemIndex
      EndIf
  EndSelect
  
EndProcedure

Procedure DMX_clearDMXSendArrayForDMXControl(nDMXControlPtr)
  ; Procedure added for playing DMX Capture cues, where all non-specified channels are to be set to 0, so that DMX Capture only needs to save the non-zero channel values in the cue file
  Protected nDMXSendDataBaseIndex, nDMXChannel
  
  If nDMXControlPtr >= 0
    nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
    If nDMXSendDataBaseIndex >= 0
      gaDMXSendData(nDMXSendDataBaseIndex) = 0  ; start code = 0
      For nDMXChannel = 1 To 512
        gaDMXSendData(nDMXSendDataBaseIndex + nDMXChannel) = 0
      Next nDMXChannel
    EndIf
  EndIf
  
EndProcedure

Procedure DMX_loadFadeItemsArrayForDMXCapture(pSubPtr, nChaseStepIndex)
  ; NB this Procedure is only used for DMX Capture
  PROCNAMECS(pSubPtr)
  Protected rDMXSendItem.tyDMXSendItem
  Protected qTimeSubStarted.q
  Protected f
  Protected nMaxItemIndex
  Protected sDMXChannels.s, nDMXFadeTime, nDMXDelayTime, nDMXValue
  Protected nPart, nPartCount, nDashCount
  Protected sPart.s
  Protected sFromChannel.s, sUpToChannel.s, nFromChannel, nUpToChannel, nDMXChannel
  Protected nDelayTime, nCalcTargetValue
  Protected nDMXControlPtr, nDMXDevPtr, nDMXPort
  Protected nDMXSendDataBaseIndex, nDMXChannelIndex, nItemIndex
  Protected nEntryType, nDMXFadeUpTimeForSub, nDMXFadeDownTimeForSub ; Added 12Oct2021 11.8.6ba
  
  With aSub(pSubPtr)
    If \nDMXControlPtr < 0
      DMX_setDMXControlPtrForSub(pSubPtr)
    EndIf
    nDMXControlPtr = \nDMXControlPtr
    nDMXDevPtr = gaDMXControl(nDMXControlPtr)\nDMXDevPtr
    nDMXPort = gaDMXControl(nDMXControlPtr)\nDMXPort
    nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex ; nb nDMXSendDataBaseIndex will be 0 for port 1, or 512 for port 2
                                                                               ; Added 12Oct2021 11.8.6ba
    nEntryType = \nLTEntryType
    If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
      nDMXFadeUpTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEUP, \nLTDCFadeUpAction, @aSub(pSubPtr), @grProd)
      nDMXFadeDownTimeForSub = DMX_getFadeTimeForSubFadeFieldAction(#SCS_DMX_FADE_FIELD_DC_FADEDOWN, \nLTDCFadeDownAction, @aSub(pSubPtr), @grProd)
;       CompilerIf #cTraceDMXLoadChannelInfo
;         debugMsg(sProcName, "\nLTDCFadeUpAction=" + decodeDMXFadeActionDC(\nLTDCFadeUpAction) + ", nDMXFadeUpTimeForSub=" + nDMXFadeUpTimeForSub +
;                             ", \nLTDCFadeDownAction=" + decodeDMXFadeActionDC(\nLTDCFadeDownAction) + ", nDMXFadeDownTimeForSub=" + nDMXFadeDownTimeForSub)
;       CompilerEndIf
    EndIf
    ; End added 12Oct2021 11.8.6ba
    qTimeSubStarted = \qTimeSubStarted
    ; debugMsg(sProcName, "qTimeSubStarted=" + traceTime(qTimeSubStarted))
    
    nMaxItemIndex = \aChaseStep(nChaseStepIndex)\nDMXSendItemCount - 1
    ; debugMsg0(sProcName, "nMaxItemIndex=" + nMaxItemIndex)
    For nItemIndex = 0 To nMaxItemIndex
      rDMXSendItem = \aChaseStep(nChaseStepIndex)\aDMXSendItem(nItemIndex)
      nDMXValue = rDMXSendItem\nDMXValue
      If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
        ; nDMXFadeTime will be set later, on a channel-by-channel basis, depending on whether fade up or fade down is required
        nDelayTime = 0
      Else
        nDMXFadeTime = rDMXSendItem\nDMXFadeTime
        nDelayTime = rDMXSendItem\nDMXDelayTime
      EndIf
      sDMXChannels = rDMXSendItem\sDMXChannels
      ; process channels
      nPartCount = CountString(sDMXChannels, ",") + 1
      CompilerIf #cTraceDMXFadeItemValues
        debugMsg(sProcName, "sDMXChannels=" + #DQUOTE$ + sDMXChannels + #DQUOTE$ + ", nPartCount=" + nPartCount)
      CompilerEndIf
      For nPart = 1 To nPartCount
        sPart = StringField(sDMXChannels, nPart, ",")
        nDashCount = CountString(sPart, "-")
        Select nDashCount
          Case 0
            sFromChannel = sPart
            sUpToChannel = sPart
          Case 1
            sFromChannel = StringField(sPart, 1, "-")
            sUpToChannel = StringField(sPart, 2, "-")
        EndSelect
        nFromChannel = Val(sFromChannel)
        nUpToChannel = Val(sUpToChannel)
        ; process channels for this part
        CompilerIf #cTraceDMXFadeItemValues
          If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SEQ
            debugMsg(sProcName, "nPart=" + nPart + ", sPart=" + #DQUOTE$ + sPart + #DQUOTE$ + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", nFromChannel=" + nFromChannel + ", nUpToChannel=" + nUpToChannel +
                                ", nDelayTime=" + nDelayTime + ", nDMXFadeTime=" + nDMXFadeTime + ", nDMXValue=" + nDMXValue)
          Else
            debugMsg(sProcName, "nPart=" + nPart + ", sPart=" + #DQUOTE$ + sPart + #DQUOTE$ + ", nDMXSendDataBaseIndex=" + nDMXSendDataBaseIndex + ", nFromChannel=" + nFromChannel + ", nUpToChannel=" + nUpToChannel +
                                ", nDMXFadeUpTimeForSub=" + nDMXFadeUpTimeForSub + ", nDMXFadeDownTimeForSub=" + nDMXFadeDownTimeForSub + ", nDMXValue=" + nDMXValue)
          EndIf
        CompilerEndIf
        For nDMXChannel = nFromChannel To nUpToChannel
          nDMXChannelIndex = nDMXSendDataBaseIndex + nDMXChannel
          If nEntryType = #SCS_LT_ENTRY_TYPE_DMX_CAPTURE_SNAP
            If nDMXValue >= gaDMXSendData(nDMXChannelIndex)
              nDMXFadeTime = nDMXFadeUpTimeForSub
            Else
              nDMXFadeTime = nDMXFadeDownTimeForSub
            EndIf
          EndIf
          If nDelayTime <= 0 And nDMXFadeTime <= 0
            gaDMXSendData(nDMXChannelIndex) = nDMXValue
            ; debugMsg(sProcName, "gaDMXSendData(" + nDMXChannelIndex + ")=" + gaDMXSendData(nDMXChannelIndex))
          EndIf
          If nDMXFadeTime > 0 Or nDelayTime > 0 ; Added "Or nDelayTime > 0" 30Sep2021 11.8.6ar
            nCalcTargetValue = DMX_calcChannelTargetValueAtDelayTime(pSubPtr, nDMXControlPtr, nDMXChannel, nDelayTime)
            ; If DMX_calcChannelTargetValueAtDelayTime() returns -1 then this means there is no DMX string entry for this device, channel and delay time
            If nCalcTargetValue >= 0
              f = DMX_getFadeItemIndex(nDMXDevPtr, nDMXPort, nDMXChannel, nDelayTime, #False)
              ; Note: if this call to DMX_getFadeItemIndex() cannot find an entry for the supplied parameters, it will return a pointer to a blank entry that can be used
              ; debugMsg(sProcName, "nDMXDevPtr=" + nDMXDevPtr + ", nDMXPort=" + nDMXPort + ", nDMXChannel=" + nDMXChannel + ", f=" + f +
              ;                     ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem + ", ArraySize(grDMXFadeItems\aFadeItem())=" + ArraySize(grDMXFadeItems\aFadeItem()))
              grDMXFadeItems\aFadeItem(f)\nFadeTime = nDMXFadeTime
              grDMXFadeItems\aFadeItem(f)\qStartTime = qTimeSubStarted + nDelayTime
              grDMXFadeItems\aFadeItem(f)\nStartValue = DMX_calcChannelStartValueAtDelayTime(nDMXControlPtr, nDMXChannel, nDelayTime)
              grDMXFadeItems\aFadeItem(f)\nTargetValue = nCalcTargetValue
              ; NB Do NOT apply DMX Master Fader when using DMX Capture or we would need to know which channels are fader channels, so that we don't 'fade' mode channels, etc
              grDMXFadeItems\aFadeItem(f)\bFadeCompleted = #False
              grDMXFadeItems\aFadeItem(f)\nSubPtr = pSubPtr
              CompilerIf #cTraceDMXFadeItemValues
                debugMsg(sProcName, "grDMXFadeItems\aFadeItem(" + f + ")\nDMXDelayTime=" + grDMXFadeItems\aFadeItem(f)\nDMXDelayTime +
                                    ", \nDMXDevPtr=" + grDMXFadeItems\aFadeItem(f)\nDMXDevPtr +
                                    ", \nDMXPort=" + grDMXFadeItems\aFadeItem(f)\nDMXPort +
                                    ", \nDMXChannel=" + grDMXFadeItems\aFadeItem(f)\nDMXChannel +
                                    ", \nFadeTime=" + grDMXFadeItems\aFadeItem(f)\nFadeTime +
                                    ", \qStartTime=" + traceTime(grDMXFadeItems\aFadeItem(f)\qStartTime) +
                                    ", \nStartValue=" + grDMXFadeItems\aFadeItem(f)\nStartValue +
                                    ", \nTargetValue=" + grDMXFadeItems\aFadeItem(f)\nTargetValue)
              CompilerEndIf
            EndIf
          EndIf
        Next nDMXChannel
      Next nPart
    Next nItemIndex
  EndWith

EndProcedure

Procedure DMX_listDMXFadeItemsArray()
  PROCNAMEC()
  Protected f
  
  ; debugMsg(sProcName, #SCS_START + ", grDMXFadeItems\nMaxFadeItem=" + grDMXFadeItems\nMaxFadeItem + ", ArraySize(grDMXFadeItems\aFadeItem())=" + ArraySize(grDMXFadeItems\aFadeItem()))
  For f = 0 To ArraySize(grDMXFadeItems\aFadeItem())
    With grDMXFadeItems\aFadeItem(f)
      If \nDMXChannel > 0
        debugMsg(sProcName, "grDMXFadeItems\aFadeItem(" + f + ")\nDMXDelayTime=" + \nDMXDelayTime + ", \nDMXDevPtr=" + \nDMXDevPtr + ", \nDMXPort=" + \nDMXPort + ", \nDMXChannel=" + \nDMXChannel +
                            ", \nFadeTime=" + \nFadeTime + ", \qStartTime=" + traceTime(\qStartTime) + ", \nStartValue=" + \nStartValue + ", \nTargetValue=" + \nTargetValue)
      EndIf
    EndWith
  Next f

EndProcedure

Procedure DMX_ChannelLimitWarning()
  PROCNAMEC()
  Protected sButtons.s, sDontTellMeAgainText.s, nOption, bRaiseAskMessage
  Protected sTitle.s, sMsg.s
  
  If getDontAskTellToday(#SCS_DontTellDMXChannelLimitDate) = #False
    sButtons = Lang("Btns", "OK")
    sDontTellMeAgainText = Lang("Common", "DontTellMeAgainToday") ; "Don't tell me this again today"
    sTitle = Lang("Errors", "DMXChannelLimitTitle")
    sMsg = LangPars("Errors", "DMXChannelLimit", Str(grLicInfo\nMaxDMXChannel))
    debugMsg(sProcName, sMsg)
    sMsg = ReplaceString(sMsg, ". ", ".|") ; force newline at end of first sentence as the message is quite long
    nOption = OptionRequester(0, 0, sTitle + "|" + sMsg, sButtons, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
    debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
    If nOption & $10000
      setDontAskTellToday(#SCS_DontTellDMXChannelLimitDate)
    EndIf
  EndIf
  
EndProcedure

Procedure DMX_setDMXChannelValue(nProdDevNo, nDMXChannel, nDMXValue, nDMXSendOrigin)
  PROCNAMEC()
  Protected nDMXControlPtr, nDMXSendDataBaseIndex, nItemIndex, aNewValue.a
  Protected bLockedMutex
  
  LockDMXSendMutex(622) ; Added 13Jul2022 11.9.4
  
  nDMXControlPtr = DMX_getDMXControlPtrForDevNo(#SCS_DEVTYPE_LT_DMX_OUT, nProdDevNo)
  nDMXSendDataBaseIndex = gaDMXControl(nDMXControlPtr)\nDMXSendDataBaseIndex
  nItemIndex = nDMXSendDataBaseIndex + nDMXChannel
  With grDMXChannelItems\aDMXChannelItem(nItemIndex)
    \nDMXChannelValue = nDMXValue
    \nDMXChannelFadeTime = 0
    \bDMXApplyFadeTime = #False
    ; debugMsg0(sProcName, "gbDMXDimmableChannel(" + nItemIndex + ")=" + strB(gbDMXDimmableChannel(nItemIndex)))
    \bDMXChannelDimmable = gbDMXDimmableChannel(nItemIndex) ; Added 16Jul2022 11.9.4
    If \nDMXChannelValue = 0
      aNewValue = 0
    Else
      If grDMXMasterFader\nDMXMasterFaderValue = 100
        aNewValue = \nDMXChannelValue
      Else
        aNewValue = \nDMXChannelValue * grDMXMasterFader\nDMXMasterFaderValue / 100
      EndIf
    EndIf
    If gaDMXSendData(nItemIndex) <> aNewValue
      gaDMXSendData(nItemIndex) = aNewValue
      gaDMXSendOrigin(nItemIndex) = nDMXSendOrigin
      ; debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) + ", gaDMXSendOrigin(" + nItemIndex + ")=" + gaDMXSendOrigin(nItemIndex))
    EndIf
    CompilerIf #cTraceDMXSendChannels1to34
      If nItemIndex < 35
        debugMsg(sProcName, "gaDMXSendData(" + nItemIndex + ")=" + gaDMXSendData(nItemIndex) + ", gaDMXSendOrigin(" + nItemIndex + ")=" + gaDMXSendOrigin(nItemIndex))
      EndIf
    CompilerEndIf
  EndWith
  
  If gbMainFormLoaded
    ; debugMsg(sProcName, "calling setSaveSettings()")
    setSaveSettings(#True)
  EndIf
  
  grDMX\bDMXReadyToSend = #True ; must be set (or cleared) while gnDMXSendMutex is locked
  UnlockDMXSendMutex() ; Added 13Jul2022 11.9.4
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF