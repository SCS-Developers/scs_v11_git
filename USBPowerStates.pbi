; File: USBPowerStates.pbi

; based on code supplied by 'breeze4me' 20Nov2018 in PB Windows Forum in reply to my posting in topic 'USB Power Management query'

;Getting current USB power state
;https://stackoverflow.com/questions/51725639/getting-current-usb-power-state

EnableExplicit

#DIGCF_PRESENT = $00000002
#DIGCF_ALLCLASSES = $00000004
#DIGCF_PROFILE = $00000008
#DIGCF_DEVICEINTERFACE = $00000010

#SPDRP_DEVICE_POWER_DATA = $0000001E
#SPDRP_FRIENDLYNAME = $0000000C
#SPDRP_DEVICEDESC = 0
;#SPDRP_DRIVER = $00000009

#POWER_SYSTEM_MAXIMUM = 7

Enumeration
  #PowerDeviceUnspecified
  #PowerDeviceD0
  #PowerDeviceD1
  #PowerDeviceD2
  #PowerDeviceD3
EndEnumeration

Structure SP_DEVINFO_DATA Align #PB_Structure_AlignC
  cbSize.w
  ClassGuid.GUID
  DevInst.w
  Reserved.i
EndStructure

Structure CM_POWER_DATA
  PD_Size.l
  PD_MostRecentPowerState.l                     ;DEVICE_POWER_STATE
  PD_Capabilities.l
  PD_D1Latency.l
  PD_D2Latency.l
  PD_D3Latency.l
  PD_PowerStateMapping.l[#POWER_SYSTEM_MAXIMUM] ;DEVICE_POWER_STATE
  PD_DeepestSystemWake.l                        ;SYSTEM_POWER_STATE
EndStructure

Procedure.s GUIDtoString(*guid)
  Protected res.s{48}
  
  If StringFromGUID2_(*guid, @res, 40)
    ProcedureReturn res
  EndIf
  
EndProcedure

Structure tyUSBPowerInfo
  sUSBDevDesc.s
  sUSBGUID.s
  sUSBPowerState.s
EndStructure
Global Dim gaUSBPowerInfo.tyUSBPowerInfo(0)
Global gnMaxUSBPowerInfo = -1

Procedure loadUSBPowerInfo()
  Protected hDevinfo
  Protected Text.s{1024}
  Protected PowerData.CM_POWER_DATA\PD_Size = SizeOf(CM_POWER_DATA)
  Protected PropertyRegDataType
  Protected idx
  
  gnMaxUSBPowerInfo = -1
  
  ;hDevinfo = SetupDiGetClassDevs_(?GUID_DEVINTERFACE_USB_DEVICE, 0, 0, #DIGCF_PRESENT | #DIGCF_DEVICEINTERFACE)
  hDevinfo = SetupDiGetClassDevs_(?GUID_DEVINTERFACE_USB_HUB, 0, 0, #DIGCF_PRESENT | #DIGCF_DEVICEINTERFACE)
  
  If hDevinfo <> #INVALID_HANDLE_VALUE
    
    Define di.SP_DEVINFO_DATA\cbSize = SizeOf(SP_DEVINFO_DATA)
    
    Repeat
      
      If SetupDiEnumDeviceInfo_(hDevinfo, idx, di) = 0 And GetLastError_() = #ERROR_NO_MORE_ITEMS
        Break
      Else
        gnMaxUSBPowerInfo + 1
        If gnMaxUSBPowerInfo > ArraySize(gaUSBPowerInfo())
          ReDim gaUSBPowerInfo(gnMaxUSBPowerInfo+5)
        EndIf
        With gaUSBPowerInfo(gnMaxUSBPowerInfo)
          ;If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_FRIENDLYNAME, @PropertyRegDataType, @Text, 1020, 0)
          If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_DEVICEDESC, @PropertyRegDataType, @Text, 1020, 0)
            \sUSBDevDesc = Text
          EndIf
          
          If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_DEVICE_POWER_DATA, @PropertyRegDataType, @PowerData, SizeOf(CM_POWER_DATA), 0)
            \sUSBGUID = GUIDtoString(di\ClassGuid)
            
            ;USB Device Power States
            ;https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/comparing-usb-device-states-to-wdm-device-states
            ;https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/device-power-states
            
            Select PowerData\PD_MostRecentPowerState
              Case #PowerDeviceD0
                \sUSBPowerState = "D0" ; "The working state. The device is fully powered."
                
              Case #PowerDeviceD1
                \sUSBPowerState = "D1" ; "Intermediate sleep state. This state allows the device to be armed for remote wakeup."
                
              Case #PowerDeviceD2
                \sUSBPowerState = "D2" ; "Intermediate sleep state. This state allows the device to be armed for remote wakeup."
                
              Case #PowerDeviceD3
                \sUSBPowerState = "D3" ; "The deepest sleep state. Devices in state D3 cannot be armed for remote wakeup."
                
              Default
                \sUSBPowerState = "?" ; "#PowerDeviceUnspecified"
                
            EndSelect
            
          EndIf
          
        EndWith
        
      EndIf
      
      idx + 1
      
    ForEver
    
    SetupDiDestroyDeviceInfoList_(hDevinfo)
  EndIf
EndProcedure

CompilerIf #PB_Compiler_IsMainFile = #False
  Procedure checkUSBPowerStates()
    PROCNAMEC()
    Protected n
    
    loadUSBPowerInfo()
    For n = 0 To gnMaxUSBPowerInfo
      With gaUSBPowerInfo(n)
        debugMsg(sProcName, "gaUSBPowerInfo(" + n + ")\sUSBDevDesc=" + #DQUOTE$ + \sUSBDevDesc + #DQUOTE$ + ", \sUSBGUID=" + \sUSBGUID + ", \sUSBPowerState=" + \sUSBPowerState)
      EndWith
    Next n
    
  EndProcedure
CompilerEndIf

CompilerIf #PB_Compiler_IsMainFile
  Define Text.s{1024}
  
  Define PowerData.CM_POWER_DATA\PD_Size = SizeOf(CM_POWER_DATA)
  
  ;hDevinfo = SetupDiGetClassDevs_(?GUID_DEVINTERFACE_USB_DEVICE, 0, 0, #DIGCF_PRESENT | #DIGCF_DEVICEINTERFACE)
  hDevinfo = SetupDiGetClassDevs_(?GUID_DEVINTERFACE_USB_HUB, 0, 0, #DIGCF_PRESENT | #DIGCF_DEVICEINTERFACE)
  
  If hDevinfo <> #INVALID_HANDLE_VALUE
    
    Define di.SP_DEVINFO_DATA\cbSize = SizeOf(SP_DEVINFO_DATA)
    
    Repeat
      
      If SetupDiEnumDeviceInfo_(hDevinfo, idx, di) = 0 And GetLastError_() = #ERROR_NO_MORE_ITEMS
        Break
      Else
        
        ;If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_FRIENDLYNAME, @PropertyRegDataType, @Text, 1020, 0)
        If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_DEVICEDESC, @PropertyRegDataType, @Text, 1020, 0)
          Debug Text
        EndIf
        
        If SetupDiGetDeviceRegistryProperty_(hDevinfo, di, #SPDRP_DEVICE_POWER_DATA, @PropertyRegDataType, @PowerData, SizeOf(CM_POWER_DATA), 0)
          Debug GUIDtoString(di\ClassGuid)
          
          ;USB Device Power States
          ;https://docs.microsoft.com/en-us/windows-hardware/drivers/usbcon/comparing-usb-device-states-to-wdm-device-states
          ;https://docs.microsoft.com/en-us/windows-hardware/drivers/kernel/device-power-states
          
          Select PowerData\PD_MostRecentPowerState
            Case #PowerDeviceD0
              Debug "D0 - The working state. The device is fully powered."
              
            Case #PowerDeviceD1
              Debug "D1 - The intermediate sleep states. These states allow the device to be armed for remote wakeup."
              
            Case #PowerDeviceD2
              Debug "D2 - The intermediate sleep states. These states allow the device to be armed for remote wakeup."
              
            Case #PowerDeviceD3
              Debug "D3 - The deepest sleep state. Devices in state D3 cannot be armed for remote wakeup."
              
            Default
              Debug "#PowerDeviceUnspecified"
              
          EndSelect
          
          Debug "-------------------------------------"
          
        EndIf
        
      EndIf
      
      idx + 1
      
    ForEver
    
    SetupDiDestroyDeviceInfoList_(hDevinfo)
  EndIf
CompilerElse
  
CompilerEndIf


DataSection
  
  GUID_DEVINTERFACE_USB_DEVICE: ; {A5DCBF10-6530-11D2-901F-00C04FB951ED}
  Data.l $A5DCBF10
  Data.w $6530, $11D2
  Data.b $90, $1F, $00, $C0, $4F, $B9, $51, $ED
  
  
  GUID_DEVINTERFACE_USB_HUB: ; {F18A0E88-C30C-11D0-8815-00A0C906BED8}
  Data.l $F18A0E88
  Data.w $C30C, $11D0
  Data.b $88, $15, $00, $A0, $C9, $06, $BE, $D8
  
EndDataSection
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 89
; FirstLine = 73
; Folding = -
; EnableThread
; EnableXP
; EnableOnError