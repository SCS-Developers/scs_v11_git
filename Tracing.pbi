; File: Tracing.pbi

EnableExplicit

Macro IsIDE()
  ; macro to check if the program is being run from the IDE - see forum posting by skywalk under the topic "How to detect if running code is being run from IDE or n"
  FindString(GetFilePart(ProgramFilename()),"PureBasic_Compilation")
EndMacro

#MAX_ADAPTER_NAME = 128
#MAX_ADAPTER_NAME_LENGTH = 256
#MAX_ADAPTER_description_LENGTH = 128
#MAX_ADAPTER_ADDRESS_LENGTH = 8
#MAX_hostName_LEN = 128
#MAX_DOMAIN_NAME_LEN = 128
#MAX_SCOPE_ID_LEN = 256 
#MIB_IF_TYPE_OTHER = 1
#MIB_IF_TYPE_ETHERNET = 6
#MIB_IF_TYPE_TOKENRING = 9
#MIB_IF_TYPE_PPP = 23
#MIB_IF_TYPE_LOOPBACK = 24
#MIB_IF_TYPE_SLIP = 28 
#IF_TYPE_IEEE80211 = 71
#DNS_INFO_buffer_SIZE = 1024
#DNS_RESULT = 111

Structure TM
  tm_sec.l
  tm_min.l
  tm_hour.l
  tm_mday.l
  tm_mon.l
  tm_year.l
  tm_wday.l
  tm_yday.l
  tm_isdst.l
EndStructure

Structure _IP_ADDR_STRING Align #PB_Structure_AlignC 
  *pnext._IP_ADDR_STRING 
  ipAddress.IP_ADDRESS_STRING
  ipMask.IP_MASK_STRING
  context.l 
EndStructure 

Structure IP_ADAPTER_INFO Align #PB_Structure_AlignC 
  *pNext
  comboindex.l
  adaptorName.a[#MAX_ADAPTER_NAME_LENGTH + 4]
  description.a[#MAX_ADAPTER_description_LENGTH + 4]
  addressLength.l
  address.b[#MAX_ADAPTER_ADDRESS_LENGTH]
  index.l
  Type.l
  dhcpEnabled.l
  *currentipAddressPTR._IP_ADDR_STRING
  ipAddressList._IP_ADDR_STRING
  gatewayList._IP_ADDR_STRING
  dhcpServer._IP_ADDR_STRING
  haveWins.l
  primaryWinsServer._IP_ADDR_STRING
  secondaryWinsServer._IP_ADDR_STRING
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
    leaseObtained.l
    leaseExpires.l
    CompilerElse
    leaseObtained.q
    leaseExpires.q
  CompilerEndIf
EndStructure

Structure IP_ADAPTER_index_MAP
  index.l
  name.w[#MAX_ADAPTER_NAME]
EndStructure

Structure IP_INTERFACE_INFO
  numAdapters.l
  adapter.IP_ADAPTER_index_MAP[1]
EndStructure

Structure MyIP_ADAPTER_INFO
  index.l
  dhcp.l
  adaptorName.s
  description.s
  macAddress.s
  ipAddress.s
  gateWayAdress.s
  ipMask.s
  leaseObtained.s
  leaseExpires.s
  type.l
EndStructure

Structure MyIP_INTERFACE_INFO
  index.l
  name.s
EndStructure

Structure FIXED_INFO
  hostName.a[#MAX_hostName_LEN + 4]
  domainName.a[#MAX_DOMAIN_NAME_LEN + 4]
  *currentDnsServer
  dnsServerList.IP_ADDR_STRING
  nodeType.l
  scopeId.a[#MAX_SCOPE_ID_LEN + 4]
  enableRouting.l
  enableProxy.l
  enableDns.l 
EndStructure 

Global NewList dnsInfo_l.MyIP_INTERFACE_INFO() 
Global NewList myIpAdaptor_l.MyIP_ADAPTER_INFO() 

CompilerIf #PB_Compiler_Processor = #PB_Processor_x86
ImportC "msvcrt.lib"
  asctime.l(a.l)
  localtime.l(a.l)
  strftime.l(a.l, b.l, c.p-ascii, d.l)
EndImport
CompilerElse
ImportC "msvcrt.lib"
  asctime.i(a.l)
  localtime.i(a.l)
  strftime.i(a.l, b.l, c.p-ascii, d.l)
EndImport
CompilerEndIf

Procedure GetDNSInfo() 
  Protected *mem
  Protected *info.FIXED_INFO
  Protected len.i = #DNS_INFO_buffer_SIZE
  Protected index.i = 1
  Protected *pIPAddr._IP_ADDR_STRING
  Protected res.i
  
  ClearList(dnsInfo_l()) 
  *mem = AllocateMemory(len)
  res = GetNetworkParams_(*mem, @len)
  
  If res = #DNS_RESULT 
    *mem = ReAllocateMemory(*mem, len) 
    res = GetNetworkParams_(*mem, @len) 
  EndIf 
  
  If res = 0 
    *info = *mem 
    AddElement(dnsInfo_l()) 
    dnsInfo_l()\Name = PeekS(@*info\dnsServerList\ipAddress\string, -1, #PB_Ascii) 
    *pIpAddr = *info\dnsServerList\pNext
    
    While *pIPAddr
      index + 1 
      AddElement(dnsInfo_l()) 
      dnsInfo_l()\name = PeekS(@*pIpAddr\ipAddress\string, -1, #PB_Ascii) 
      dnsInfo_l()\index = index 
      *pIPAddr = *pIpAddr\pnext
    Wend 
  EndIf 
  FreeMemory(*mem)
EndProcedure 

Procedure GetAdaptersInfo()
  Protected length.l = 0 
  Protected result.l 
  Protected *buffer 
  Protected *buffer2 
  Protected *ipInfo.IP_ADAPTER_INFO 
  Protected *ipList._IP_ADDR_STRING
  Protected s_mac.s 
  Protected i.l 
  Protected byte.b
  
  ClearList(myIpAdaptor_l())
  result = GetAdaptersInfo_(0, @length)                                                ; Get the length for buffer
  
  If result = #ERROR_BUFFER_OVERFLOW And length
    *buffer = AllocateMemory(length)
   
    If *buffer And GetAdaptersInfo_(*buffer, @length) = #ERROR_SUCCESS
      *ipInfo.IP_ADAPTER_INFO = *buffer
      ;Global NewList myIpAdaptor_l.MyIP_ADAPTER_INFO() ; declare list here
      
      While *ipInfo
        AddElement(myIpAdaptor_l()) ; add one element
       
        myIpAdaptor_l()\index = *ipInfo\index
        myIpAdaptor_l()\adaptorName = PeekS(@*ipInfo\adaptorName, -1, #PB_Ascii)
        myIpAdaptor_l()\description = PeekS(@*ipInfo\description, -1, #PB_Ascii)
        myIpAdaptor_l()\type = *ipInfo\Type
        myIpAdaptor_l()\dhcp = *ipInfo\dhcpEnabled 
       
        ;IP-Adress
        *ipList._IP_ADDR_STRING = *ipInfo\ipAddressList
        While *ipList
          myIpAdaptor_l()\ipAddress + PeekS(@*ipList\ipAddress, -1, #PB_Ascii) 
          myIpAdaptor_l()\ipMask + PeekS(@*ipList\ipMask, -1, #PB_Ascii) 
          *ipList._IP_ADDR_STRING = *ipList\pNext
        Wend
       
        ;Gateway
        *ipList._IP_ADDR_STRING = *ipInfo\GatewayList
       
        While *ipList
          myIpAdaptor_l()\gateWayAdress + PeekS(@*ipList\ipAddress, -1, #PB_Ascii) 
          *ipList._IP_ADDR_STRING = *ipList\pNext
        Wend
       
        ;Wins
        If *ipInfo\HaveWins
          ;PrimaryWinsServer
          *ipList._IP_ADDR_STRING = *ipInfo\primaryWinsServer
         
          While *ipList
            *ipList._IP_ADDR_STRING = *ipList\pNext
          Wend
         
          ;SecondaryWinsServer
          *ipList._IP_ADDR_STRING = *ipInfo\secondaryWinsServer
         
          While *ipList
            *ipList._IP_ADDR_STRING = *ipList\pNext
          Wend
        EndIf
       
        ;dhcp
        If *ipInfo\dhcpEnabled
          ;dhcpServer
          *ipList._IP_ADDR_STRING = *ipInfo\dhcpServer
          
          While *ipList
            *ipList._IP_ADDR_STRING = *ipList\pNext
          Wend
          
          ;leaseObtained
          *buffer2 = AllocateMemory(#MAXCHAR)
          
          If *buffer2
            strftime(*buffer2, #MAXCHAR, "%d.%m.%Y %H:%M:%S", localtime(@*ipInfo\leaseObtained))
            myIpAdaptor_l()\leaseObtained = PeekS(*buffer2, -1, #PB_Ascii) 
            FreeMemory(*buffer2)
            *buffer2 = 0
          EndIf
          
          ;leaseExpires
          *buffer2 = AllocateMemory(#MAXCHAR)
          
          If *buffer2
            strftime(*buffer2, #MAXCHAR, "%d.%m.%Y %H:%M:%S", localtime(@*ipInfo\leaseExpires))
            myIpAdaptor_l()\leaseExpires = PeekS(*buffer2, -1, #PB_Ascii) 
            FreeMemory(*buffer2)
            *buffer2 = 0
          EndIf
        EndIf
       
        If *ipInfo\addressLength
          s_mac = ""
          
          For i = 0 To *ipInfo\addressLength-1
            If i
              s_mac + ":"
            EndIf
            byte.b = PeekB(@*ipInfo\address + i)
            
            If byte> = 0
              s_mac + RSet(Hex(byte), 2, "0")
            Else
              s_mac + RSet(Hex(byte + 256), 2, "0")
            EndIf
          Next
       
          myIpAdaptor_l()\macAddress = s_mac
        EndIf
        *ipInfo.IP_ADAPTER_INFO = *ipInfo\pNext
      Wend
    EndIf
   
    If *buffer
      FreeMemory(*buffer)
      *buffer = 0
    EndIf
  EndIf
EndProcedure

Procedure debugProcAll(sProcName.s, sMessage.s, sThreadNo.s, sLogGroup.s, sFilename.s, nLineNo, bMutexAlreadyLocked=#False)
  Protected bLockedMutex
  Protected sDebugTime.s
  Protected rDateTime.SYSTEMTIME
  
  If gnDebugFile And gbDoDebug
    If gbTracingStopped = #False Or gbForceTracing
      GetLocalTime_(@rDateTime)
      sDebugTime = RSet(Str(rDateTime\wHour),2,"0") + ":" + RSet(Str(rDateTime\wMinute),2,"0") + ":" + RSet(Str(rDateTime\wSecond),2,"0") + "." + RSet(Str(rDateTime\wMilliseconds),3,"0")
      If sMessage = #SCS_BLANK
        Debug " "
      Else
        Debug sDebugTime + sLogGroup + sThreadNo + GetFilePart(sFilename, #PB_FileSystem_NoExtension)+ "@" + nLineNo + "." + sProcName  + ": " + sMessage
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure debugMsgProcAll(sProcName.s, sMessage.s, sThreadNo.s, sLogGroup.s, sFilename.s, nLineNo, bMutexAlreadyLocked=#False, bIncludeDebugLine=#False)
  Protected bLockedMutex
  Protected sDebugTime.s
  Protected rDateTime.SYSTEMTIME
  
  If gnDebugFile And gbDoDebug
    If gbTracingStopped = #False Or gbForceTracing
      If bMutexAlreadyLocked = #False
        scsLockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG, 701)
      EndIf
      
      If IsFile(gnDebugFile) = 0
        If OpenFile(gnDebugFile, gsDebugFile)
          FileSeek(gnDebugFile, Lof(gnDebugFile))
          WriteStringN(gnDebugFile, "==== after closedown (1)")
          Debug "==== after closedown (1)"
          gnTraceLine + 1
        EndIf
      EndIf
      GetLocalTime_(@rDateTime)
      sDebugTime = RSet(Str(rDateTime\wHour),2,"0") + ":" + RSet(Str(rDateTime\wMinute),2,"0") + ":" + RSet(Str(rDateTime\wSecond),2,"0") + "." + RSet(Str(rDateTime\wMilliseconds),3,"0")
      sDebugTime + "(" + gnTraceLine + ")"
      
      If sMessage = #SCS_BLANK
        WriteStringN(gnDebugFile, " ")
      Else
        WriteStringN(gnDebugFile, sDebugTime + sLogGroup + sThreadNo + GetFilePart(sFilename, #PB_FileSystem_NoExtension)+ "@" + nLineNo + "." + sProcName  + ": " + sMessage)
        If bIncludeDebugLine
          Debug sDebugTime + sLogGroup + sThreadNo + GetFilePart(sFilename, #PB_FileSystem_NoExtension)+ "@" + nLineNo + "." + sProcName  + ": " + sMessage
        EndIf
      EndIf
      gnTraceLine + (CountString(sMessage, Chr(13)) + 1)
      FlushFileBuffers(gnDebugFile)
      
      If bMutexAlreadyLocked = #False
        scsUnlockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure debugMsgProcAll2(sProcName.s, sMessage.s, nResult.l, sThreadNo.s, sLogGroup.s, sFilename.s, nLineNo, bMutexAlreadyLocked=#False)
  Protected bLockedMutex
  Protected sDebugTime.s
  Protected sHandle.s, bHasHandle
  Protected sProcAndLine.s
  Protected rDateTime.SYSTEMTIME
  
  If gnDebugFile And gbDoDebug
    If gbTracingStopped = #False Or gbForceTracing
      If bMutexAlreadyLocked = #False
        scsLockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG, 702)
      EndIf
      
      If IsFile(gnDebugFile) = 0
        If OpenFile(gnDebugFile, gsDebugFile)
          FileSeek(gnDebugFile, Lof(gnDebugFile))
          WriteStringN(gnDebugFile, "==== after closedown (2)")
          Debug "==== after closedown (2)"
          gnTraceLine + 1
        EndIf
      EndIf
      GetLocalTime_(@rDateTime)
      sDebugTime = RSet(Str(rDateTime\wHour),2,"0") + ":" + RSet(Str(rDateTime\wMinute),2,"0") + ":" + RSet(Str(rDateTime\wSecond),2,"0") + "." + RSet(Str(rDateTime\wMilliseconds),3,"0")
      sDebugTime + "(" + gnTraceLine + ")"
      
      If FindString(sMessage, "StreamCreate") Or FindString(sMessage, "ChannelSetSync") Or FindString(sMessage, "ChannelSetDSP") Or FindString(sMessage, "TVG_CreateVideoGrabber")
        If nResult <> 0
          sHandle = decodeHandle(nResult)
          If FindString(sHandle,"#")
            bHasHandle = #True
          EndIf
        EndIf
      EndIf
      
      sProcAndLine = GetFilePart(sFilename, #PB_FileSystem_NoExtension) + "@" + nLineNo + "." + sProcName + ": "
      
      If sMessage = #SCS_BLANK
        WriteStringN(gnDebugFile, " ")
        
      ElseIf bHasHandle
        WriteStringN(gnDebugFile, sDebugTime + sLogGroup + sThreadNo + sProcAndLine + sMessage + " returned " + nResult + " (" + sHandle + ")")
        
      ElseIf Left(sMessage, 20) = "BASS_ChannelIsActive"
        WriteStringN(gnDebugFile, sDebugTime + sLogGroup + sThreadNo + sProcAndLine + sMessage + " returned " + decodeActiveState(nResult))
        
      ElseIf Left(sMessage, 3) = "FT_"
        WriteStringN(gnDebugFile, sDebugTime + sLogGroup + sThreadNo + sProcAndLine + sMessage + " returned " + decodeFTStatus(nResult))
        
      Else
        WriteStringN(gnDebugFile, sDebugTime + sLogGroup + sThreadNo + sProcAndLine + sMessage + " returned " + nResult)
        
      EndIf
      gnTraceLine + (CountString(sMessage, Chr(13)) + 1)
      ; the following code is also in debugMsgProcAll() and writeSMSLogProc()
      CompilerIf 1=2 ; Blocked out 19Oct2020 11.8.3.2bx to try to sort out bug from Teemu where SCS failed after about two days
        If (gnTraceLine > gnMaxTraceLines) And (gbTracingStopped = #False)
          WriteStringN(gnDebugFile, "==== logging suspended")
          gbTracingStopped = #True
        EndIf
      CompilerEndIf
      FlushFileBuffers(gnDebugFile)
      
      If bMutexAlreadyLocked = #False
        scsUnlockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG)
      EndIf
    EndIf
  EndIf
  
EndProcedure

Procedure writeSMSLogProc(pProcName.s, sCommandString.s, *prSMS.tySMS)
  PROCNAMEC()
  Protected bLockedMutex
  Protected sSendTime.s, sReceiveTime.s, n
  
  If gnDebugFile
    If gbTracingStopped = #False Or gbForceTracing
      scsLockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG, 703)
      With *prSMS
        sSendTime = RSet(Str(\rSendTime\wHour),2,"0") + ":" + RSet(Str(\rSendTime\wMinute),2,"0") + ":" + RSet(Str(\rSendTime\wSecond),2,"0") + "." + RSet(Str(\rSendTime\wMilliseconds),3,"0")
        If \qReceiveTime >= 0
          sReceiveTime = RSet(Str(\rReceiveTime\wHour),2,"0") + ":" + RSet(Str(\rReceiveTime\wMinute),2,"0") + ":" + RSet(Str(\rReceiveTime\wSecond),2,"0") + "." + RSet(Str(\rReceiveTime\wMilliseconds),3,"0")
        EndIf
        WriteStringN(gnDebugFile, sSendTime + " ~S" + gsThreadNo + " C: " + sCommandString)
        gnTraceLine + 1
        For n = 0 To (\nResponseLineCount - 1)
          WriteStringN(gnDebugFile, sReceiveTime + " ~S" + gsThreadNo + " R: " + gsSMSResponse(n))
          gnTraceLine + 1
        Next n
        ; the following code is also in debugMsgProcAll() and debugMsgProcAll2()
        CompilerIf 1=2 ; Blocked out 19Oct2020 11.8.3.2bx to try to sort out bug from Teemu where SCS failed after about two days
          If (gnTraceLine > gnMaxTraceLines) And (gbTracingStopped = #False)
            WriteStringN(gnDebugFile, "==== logging suspended")
            gbTracingStopped = #True
          EndIf
        CompilerEndIf
        FlushFileBuffers(gnDebugFile)
      EndWith
      gbSMSLogUsed = #True
      scsUnlockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG)
    EndIf
  EndIf
  
EndProcedure

Procedure logKeyEventProc(pProcName.s, pMessage.s, sLogGroup.s, sFilename.s, nLineNo)
  PROCNAMEC()
  Protected bLockedMutex
  Protected sTime.s
  
  ; limit key event logging to 5000 events - any more than that is not likely to be useful
  ; (problem occurred with Chris Hubbard's stress testing, where over 1,000,000 key events were being logged - 3/5/2014)
  If gnMaxKeyEvent > 4999
    ProcedureReturn
  EndIf
  
  scsLockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG, 704)
  
  gnMaxKeyEvent + 1
  If gnMaxKeyEvent > ArraySize(gaKeyEvent())
    ReDim gaKeyEvent(gnMaxKeyEvent+500)
  EndIf
  
  With gaKeyEvent(gnMaxKeyEvent)
    GetLocalTime_(@\rDateTime)
    \sKeyEvent = gsThreadNo + GetFilePart(sFilename, #PB_FileSystem_NoExtension) + "." + pProcName + "@" + nLineNo + ": " + pMessage
    debugMsgProcAll(pProcName, "KEY EVENT: " + pMessage, gsThreadNo, sLogGroup, sFilename, nLineNo, #True)
  EndWith
  
  scsUnlockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG)
  
EndProcedure

Procedure debugAnyFile(sAnyFile.s, bIgnoreBlankLines=#False)
  PROCNAMEC() ; nb sProcName.s required by scsLockMutex()
  Protected bLockedMutex
  Protected nDebugAnyFile, nStringFormat
  Protected sLine.s
  
  If gnDebugFile And gbDoDebug
    scsLockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG, 707)
    nDebugAnyFile = ReadFile(#PB_Any, sAnyFile, #PB_File_SharedRead)
    If nDebugAnyFile <> 0
      WriteStringN(gnDebugFile, "--------------------")
      nStringFormat = ReadStringFormat(nDebugAnyFile)
      While Eof(nDebugAnyFile) = 0
        sLine = ReadString(nDebugAnyFile, nStringFormat)
        If Len(Trim(sLine)) > 0 Or bIgnoreBlankLines = #False
          WriteStringN(gnDebugFile, sLine)
        EndIf
        gnTraceLine + 1
        gnMaxTraceLines + 1 ; this is so that the size of the cue file does not limit the number of other trace lines in the log file
      Wend
      CloseFile(nDebugAnyFile)
      WriteStringN(gnDebugFile, "--------------------")
    EndIf
    scsUnlockMutex(gnDebugMutex, #SCS_MUTEX_DEBUG)
  EndIf
EndProcedure

Procedure debugCueFile(sCueFile.s)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START + ", sCueFile=" + #DQUOTE$ + sCueFile + #DQUOTE$)
  debugAnyFile(sCueFile)
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure debugDevMapFile(sDevMapFile.s)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START + ", sDevMapFile=" + #DQUOTE$ + sDevMapFile + #DQUOTE$)
  debugAnyFile(sDevMapFile)
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure debugPrefsFile(sPrefsFile.s)
  PROCNAMEC()
  debugMsg(sProcName, #SCS_START + ", sPrefsFile=" + #DQUOTE$ + sPrefsFile + #DQUOTE$)
  debugAnyFile(sPrefsFile)
  debugMsg(sProcName, #SCS_END)
EndProcedure

Procedure.s GetVendor()
  ; procedure supplied by 'idle' in PB Forum topic 'cpuinfo module'
  Protected a.l,b.l,c.l
  !mov eax,0
  !cpuid 
  !mov [p.v_a],ebx
  !mov [p.v_b],edx 
  !mov [p.v_c],ecx 
  ProcedureReturn PeekS(@a,4,#PB_Ascii) + PeekS(@b,4,#PB_Ascii) + PeekS(@c,4,#PB_Ascii)
EndProcedure   

Procedure openListLogFile()
  Protected sLine.s
  Protected nResult
  
  gsDebugFolder = gsMyDocsPath + "SCS Logs\"
  gsDebugFolderShortName = gsMyDocsLeafName + "SCS Logs\"
  gsListLogFile = gsDebugFolder + "scs11_list.log"
  
  If FolderExists(gsDebugFolder) = #False
    nResult = CreateDirectory(gsDebugFolder)
  EndIf
  gnNextFileNo + 1
  If OpenFile(gnNextFileNo, gsListLogFile, #PB_File_SharedRead)
    gnListLogFile = gnNextFileNo
    FileSeek(gnListLogFile, Lof(gnListLogFile))
    sLine = "SCS started at " + gsStartDateTime + ", SCS Version: " + #SCS_VERSION + "  Build " + grProgVersion\sBuildDateTime
    WriteStringN(gnListLogFile, sLine)
  EndIf
  
EndProcedure

Procedure logListEventProc(sProcName.s, sMessage.s, sThreadNo.s, bHoldLineIfNotOpen)
  Protected sDateTime.s, sLogLine.s, n
  Static Dim sHoldLogLine.s(0), nMaxHoldLogLine=-1
  
  ; the purpose of bHoldLineIfNotOpen is so that the RandomSeed message will be written only if the list log is actually opened, which currently occurs only on starting a random playlist
  If gbDoListLogging
    sDateTime = FormatDate("%yy/%mm/%dd %hh:%ii:%ss", Date())
    sLogLine = sDateTime + sThreadNo + sProcName + ": " + sMessage
    If gnListLogFile = 0
      If bHoldLineIfNotOpen
        nMaxHoldLogLine + 1
        If nMaxHoldLogLine > ArraySize(sHoldLogLine())
          ReDim sHoldLogLine(nMaxHoldLogLine)
        EndIf
        sHoldLogLine(nMaxHoldLogLine) = sLogLine
      Else
        openListLogFile()
        If (gnListLogFile) And (nMaxHoldLogLine >= 0)
          For n = 0 To nMaxHoldLogLine
            WriteStringN(gnListLogFile, sHoldLogLine(n))
          Next n
          nMaxHoldLogLine = -1
        EndIf
      EndIf
    EndIf
    If gnListLogFile
      WriteStringN(gnListLogFile, sLogLine)
    EndIf
  EndIf
  
EndProcedure

Procedure purgeOldLogFiles()
  PROCNAMEC()
  Protected nDirNo, nPurgeDate, nDateModified, sFileName.s
  
  nPurgeDate = AddDate(Date(), #PB_Date_Day, -7)  ; set to purge files created more than 7 days ago
  nDirNo = ExamineDirectory(#PB_Any, gsDebugFolder, "scs11_*.*")
  If nDirNo
    While NextDirectoryEntry(nDirNo)
      If DirectoryEntryType(nDirNo) = #PB_DirectoryEntry_File
        sFileName = DirectoryEntryName(nDirNo)
        Select LCase(GetExtensionPart(sFileName))
          Case "log", "zip", "bak"
            nDateModified = DirectoryEntryDate(nDirNo, #PB_Date_Modified)
            If nDateModified < nPurgeDate
              If DeleteFile(gsDebugFolder + sFileName)
                debugMsg(sProcName, "deleted " + #DQUOTE$ + sFileName + #DQUOTE$ + ", date modified: " + FormatDate("%yyyy-%mm-%dd", nDateModified))
              EndIf
            EndIf
        EndSelect
      EndIf
    Wend
    FinishDirectory(nDirNo)
  EndIf

EndProcedure

Procedure.s decodeDirectoryEntryAttributes(nAttributes)
  Protected sAttributes.s
  sAttributes = Str(nAttributes) + ":"
  If nAttributes & #PB_FileSystem_Hidden: sAttributes + " Hidden" : EndIf
  If nAttributes & #PB_FileSystem_Archive: sAttributes + " Archive" : EndIf
  If nAttributes & #PB_FileSystem_Compressed: sAttributes + " Compressed" : EndIf
  If nAttributes & #PB_FileSystem_Normal: sAttributes + " Normal" : EndIf
  If nAttributes & #PB_FileSystem_ReadOnly: sAttributes + " ReadOnly" : EndIf
  If nAttributes & #PB_FileSystem_System: sAttributes + " Systems" : EndIf
  ProcedureReturn Trim(sAttributes)
EndProcedure

Procedure openLogFile()
  Protected sLine.s, nResult, nLineCount, nCreateFileResult
  Protected rDateTime.SYSTEMTIME, nWinBuildVersion.i
  Protected DisplayDeviceIndex, display_device.DISPLAY_DEVICE\cb = SizeOf(DISPLAY_DEVICE)     ; declared by win32
  Protected sMessage.s, nDirectory
  
  Debug "openLogFile: start"
  
  ; gnDebugMutex = CreateMutex()  ; commented out - now created unconditionally as used in logKeyEventProc()
  
  gbTracingStopped = #False
  ; gnTraceLine = 0 ; Commented out 20Oct2020 11.8.3.2bx so that trace line numbers are not reset on starting a new log file at midnight
  
  gsDebugFolder = gsMyDocsPath + "SCS Logs\"
  gsDebugFolderShortName = gsMyDocsLeafName + "SCS Logs\"
  If IsIDE()
    gsDebugFile = gsDebugFolder + "scs11_log.log"
  Else
    gsDebugFile = gsDebugFolder + "scs11_log_" + gsDebugFileDateTime + ".log"
  EndIf
  If Len(gsOriginalDebugFile) = 0
    gsOriginalDebugFile = gsDebugFile
    gnCurrLogDay = Day(Date())
  EndIf
  
  sMessage = "gsDebugFile=" + #DQUOTE$ + gsDebugFile + #DQUOTE$
  sMessage + #CRLF$ + "gbDoDebug=" + gbDoDebug + ", gbDoSMSLogging=" + gbDoSMSLogging
  
  Debug "gbDoDebug=" + gbDoDebug
  If (gbDoDebug) Or (gbDoSMSLogging)
    If FolderExists(gsDebugFolder) = #False
      sMessage + #CRLF$ + "FolderExists(" + gsDebugFile + ") returned #False"
      nResult = CreateDirectory(gsDebugFolder)
      sMessage + #CRLF$ + "CreateDirectory(" + gsDebugFolder + ") returned " + nResult
    Else
      sMessage + #CRLF$ + "FolderExists(" + gsDebugFile + ") returned #True"
    EndIf
    gnNextFileNo + 1
    nCreateFileResult = CreateFile(gnNextFileNo, gsDebugFile, #PB_File_SharedRead)
    sMessage + #CRLF$ + "CreateFile(" + gnNextFileNo + ", " + gsDebugFile + ", #PB_File_SharedRead) returned " + nCreateFileResult
    If nCreateFileResult = 0
      Debug "CreateFile(" + gnNextFileNo + ", " + gsDebugFile + ", #PB_File_SharedRead) returned 0"
      Debug "IsFile(" + gnNextFileNo + ")=" + IsFile(gnNextFileNo)
      sMessage + #CRLF$ + "IsFile(" + gnNextFileNo + ") returned " + IsFile(gnNextFileNo)
      nCreateFileResult = CreateFile(gnNextFileNo, gsDebugFile)
      sMessage + #CRLF$ + "CreateFile(" + gnNextFileNo + ", " + gsDebugFile + ") returned " + nCreateFileResult
      If nCreateFileResult = 0
        Debug "CreateFile(" + gnNextFileNo + ", " + gsDebugFile + ") returned 0"
      EndIf
    EndIf
    If nCreateFileResult
      gnDebugFile = gnNextFileNo
      Debug "gnDebugFile=" + gnDebugFile
    EndIf
  EndIf
  sMessage + #CRLF$ + "gnDebugFile=" + gnDebugFile
  
  nDirectory = ExamineDirectory(#PB_Any, gsDebugFolder, "*.*")
  sMessage + #CRLF$ + "ExamineDirectory(#PB_Any, " + gsDebugFolder + ", " + #DQUOTE$ + "." + #DQUOTE$ + ") returned " + nDirectory
  If nDirectory
    While NextDirectoryEntry(nDirectory)
      nResult = DirectoryEntryType(nDirectory)
      sMessage + #CRLF$ + "DirectoryEntryType(" + nDirectory + ")=" + nResult + ": " + DirectoryEntryName(nDirectory)
      If nResult = #PB_DirectoryEntry_Directory
        nResult = DirectoryEntryAttributes(nDirectory)
        sMessage + #CRLF$ + "DirectoryEntryAttributes(" + nDirectory + ") returned " + decodeDirectoryEntryAttributes(nResult)
      EndIf
    Wend
    FinishDirectory(nDirectory)
  EndIf
  
  sLine = "SCS log started at " + gsStartDateTime
  nResult = WriteStringN(gnDebugFile, sLine)
  sMessage + #CRLF$ + "WriteStringN(" + gnDebugFile + ", " + #DQUOTE$ + sLine + #DQUOTE$ + ") returned " + nResult
  nLineCount + 1
  
  ; MessageRequester("openLogFile", sMessage) ; Added temporarily 14Nov2024 11.10.6bj for David Lambert as log files are apparently not being created
  
  If gsDebugFile <> gsOriginalDebugFile
    sLine = "Original log file for this run: " + GetFilePart(gsOriginalDebugFile)
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    GetLocalTime_(@rDateTime)
    sLine = "Time now: " + RSet(Str(rDateTime\wHour),2,"0") + ":" + RSet(Str(rDateTime\wMinute),2,"0") + ":" + RSet(Str(rDateTime\wSecond),2,"0") + "." + RSet(Str(rDateTime\wMilliseconds),3,"0")
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
  Else
    
    sLine = "SCS Version: " + #SCS_VERSION + " (" + #SCS_PROCESSOR + ")" + "  Build " + grProgVersion\sBuildDateTime
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "OS Version: " + gsOSVersion
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    nWinBuildVersion = RunProgram("cmd", "/c ver", "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Hide)
    sLine = "OS Build Version: "
    
    If nWinBuildVersion
      While ProgramRunning(nWinBuildVersion)
        If AvailableProgramOutput(nWinBuildVersion)
          sLine + ReadProgramString(nWinBuildVersion) + Chr(13)
        EndIf
      Wend
      
      CloseProgram(nWinBuildVersion) ; Close the connection to the program
    EndIf

    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Compiler Version: " + #PB_Compiler_Version
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Computer name: " + ComputerName()
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "CPU name: " + CPUName()
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Vendor: " + GetVendor()
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Available cores: " + CountCPUs(#PB_System_ProcessCPUs)
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Total System Memory: " + StrF(MemoryStatus(#PB_System_TotalPhysical)/1073741824, 2) + " GB"
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "Available System Memory: " + StrF(MemoryStatus(#PB_System_FreePhysical)/1073741824, 2) + " GB"
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "User name: " + UserName()
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    GetAdaptersInfo()                                                            ; get the network adaptor name(s)
 
    ForEach myIpAdaptor_l.MyIP_ADAPTER_INFO() 
      If myIpAdaptor_l()\ipAddress <> "0.0.0.0"                                  ; list only adaptors that have actual ip's, we can exclude loopback adaptors here as well no gateway
        ;Debug "Name " + myIpAdaptor_l()\adaptorName
        sline = #CRLF$ + "Network adaptors:"
        sLine +  "Description " + myIpAdaptor_l()\description + #CRLF$
        sLine +  "Dhcp " + Str(myIpAdaptor_l()\dhcp) + #CRLF$ 
        sLine +  "Address " + myIpAdaptor_l()\ipAddress + #CRLF$ 
        sLine +  "Mask " + myIpAdaptor_l()\ipMask + #CRLF$ 
        sLine +  "Gateway " + myIpAdaptor_l()\gateWayAdress
        ;Debug "Index " + myIpAdaptor_l()\index 
        ;Debug "Mac address " + myIpAdaptor_l()\macAddress
        ;Debug "Node type " + myIpAdaptor_l()\type
        WriteStringN(gnDebugFile, sLine)
        nLineCount + 7
        
        If myIpAdaptor_l()\dhcp 
          sLine = "dhcp: leaseObtained " + myIpAdaptor_l()\leaseObtained + #CRLF$
          sLine + "dhcp: leaseExpires " + myIpAdaptor_l()\leaseExpires + #CRLF$
          WriteStringN(gnDebugFile, sLine)
          nLineCount + 2
        EndIf 
      EndIf 
    Next 
 
    GetDNSInfo() 
    sLine = "DNS servers list:"
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1

    ForEach dnsInfo_l() 
      sLine = dnsInfo_l()\name 
      WriteStringN(gnDebugFile, sLine)
      nLineCount + 1
    Next 

    sLine = ""
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    While EnumDisplayDevices_(0, DisplayDeviceIndex, @display_device, 0)
      If display_device\StateFlags & #DISPLAY_DEVICE_ATTACHED_TO_DESKTOP      ; We only need to see displays attached to the desktop
        If display_device\StateFlags & #DISPLAY_DEVICE_PRIMARY_DEVICE = #DISPLAY_DEVICE_PRIMARY_DEVICE
          sLine = "Primary graphics: " + PeekS(@display_device\DeviceString)
          WriteStringN(gnDebugFile, sLine)
          nLineCount + 1
        Else
          sLine = "Secondary graphics: " + PeekS(@display_device\DeviceString)
          WriteStringN(gnDebugFile, sLine)
          nLineCount + 1
        EndIf
      EndIf
      DisplayDeviceIndex + 1
    Wend
   
    sLine = ""
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
    sLine = "BASS Version: $" + Hex(BASS_GetVersion())
    sLine + ", BASS Mixer Version: $" + Hex(BASS_Mixer_GetVersion())
    sLine + ", BASS ASIO Version: $" + Hex(BASS_ASIO_GetVersion())
    sLine + ", BASS Encoder Version: $" + Hex(BASS_Encode_GetVersion())
    sLine + ", BASS_FX Version: $" + Hex(BASS_FX_GetVersion())
    WriteStringN(gnDebugFile, sLine)
    nLineCount + 1
    
  EndIf
  
  gnTraceLine + nLineCount
  gnCurrLogDay = Day(Date())
  
EndProcedure

Procedure closeLogFile(bCompressLogFile=#True)
  PROCNAMEC()
  Protected sPackFileName.s, nPackFile
  
  Debug "closeLogFile() start"
  
  If IsFile(gnDebugFile)
    CloseFile(gnDebugFile)
    gnDebugFile = 0
  EndIf
  
  If bCompressLogFile
    If IsIDE() = #False
      If FileSize(gsDebugFile) > 0
        UseZipPacker()
        sPackFileName = ignoreExtension(gsDebugFile) + ".zip"
        If FileSize(sPackFileName) > 0
          DeleteFile(sPackFileName)
        EndIf
        nPackFile = CreatePack(#PB_Any, sPackFileName, #PB_PackerPlugin_Zip)
        If nPackFile
          AddPackFile(nPackFile, gsDebugFile, GetFilePart(gsDebugFile))
          ClosePack(nPackFile)
          DeleteFile(gsDebugFile)
        EndIf
      EndIf
    EndIf
  EndIf
  
  Debug "closeLogFile() end"
  
EndProcedure

Procedure newHandleProc(nHandleType, nHandle, pProcName.s, bTrace=#False, sExtraInfo.s="")
  ; Creates a descriptive handle from a BASS, TVG or other handle.
  ; For example, BASS_StreamCreateFile() may return a number like 3028747 but newHandleProc() can generate a descriptive handle like source#5, which is much more helpful when analyzing log files.
  ; See also procedure decodeHandle().
  Protected nIndex, n, nTypeCount
  
  If nHandle = 0
    ; create failed
    ProcedureReturn
  EndIf
  
  nIndex = -1
  For n = 0 To gnMaxHandleIndex
    If gaHandle(n)\nHandleType = nHandleType
      nTypeCount + 1
    ElseIf (gaHandle(n)\nHandleType = #SCS_HANDLE_NONE) And (nIndex = -1)
      nIndex = n
    EndIf
  Next n
  
  If nIndex = -1
    nIndex = gnMaxHandleIndex + 1
    If nIndex > ArraySize(gaHandle())
      ReDim gaHandle(nIndex+100)
    EndIf
  EndIf

  With gaHandle(nIndex)
    \nHandle = nHandle
    \nHandleType = nHandleType
    Select nHandleType
      Case #SCS_HANDLE_SOURCE
        \sMnemonic = "source"
      Case #SCS_HANDLE_SPLITTER
        \sMnemonic = "splitter"
      Case #SCS_HANDLE_MIXER
        \sMnemonic = "mixer"
      Case #SCS_HANDLE_GAPLESS
        \sMnemonic = "gapless"
      Case #SCS_HANDLE_TIMELINE
        \sMnemonic = "timeline"
      Case #SCS_HANDLE_BUFFER
        \sMnemonic = "pushstream"
      Case #SCS_HANDLE_ENCODER
        \sMnemonic = "encoder"
      Case #SCS_HANDLE_VIDEO
        \sMnemonic = "video"
      Case #SCS_HANDLE_IMAGE
        \sMnemonic = "image"
      Case #SCS_HANDLE_SYNC
        \sMnemonic = "sync"
      Case #SCS_HANDLE_TEMPO
        \sMnemonic = "tempo"
      Case #SCS_HANDLE_TVG
        \sMnemonic = "tvg"
      Case #SCS_HANDLE_NETWORK_CLIENT
        \sMnemonic = "client"
      Case #SCS_HANDLE_NETWORK_SERVER
        \sMnemonic = "server"
      Case #SCS_HANDLE_VST
        \sMnemonic = "vst"
      Case #SCS_HANDLE_DMX
        \sMnemonic = "dmx"
      Case #SCS_HANDLE_TMP
        \sMnemonic = "tmp"
      Case #SCS_HANDLE_LTC
        \sMnemonic = "ltc"
    EndSelect
    \sMnemonic + "#" + Str(nTypeCount+1)
    If Trim(sExtraInfo)
      \sMnemonic + "(" + Trim(sExtraInfo) + ")"
    EndIf
    If bTrace
      debugMsg3(pProcName, "~~ handle " + nHandle + " is " + \sMnemonic)
    EndIf
  EndWith
  gnMaxHandleIndex = nIndex
EndProcedure

Procedure freeHandleProc(nHandle, pProcName.s)
  ; use this when a BASS, TVG or other handle (eg stream) is freed, so that the descriptive name, such as source#5 is also freed and removed from the gaHandle() array
  Protected n
  
  If nHandle <> 0
    For n = 0 To gnMaxHandleIndex
      If gaHandle(n)\nHandle = nHandle
        gaHandle(n)\nHandle = 0
        ; debugMsg3(pProcName, "handle " + gaHandle(n)\sMnemonic + " cleared (nHandle=" + nHandle + ")")
        Break
      EndIf
    Next n
  EndIf
  
EndProcedure

Procedure setDefaultTracing()
  PROCNAMEC()
  Protected bPrevDoDebug
  
  bPrevDoDebug = gbDoDebug
  
  gbDoDebug = #True
  gbDoSMSLogging = #True
  If bPrevDoDebug = #False
    debugMsg(sProcName, "Tracing enabled")
  EndIf
  
  If IsWindow(#WMN)
    If IsMenu(#WMN_mnuWindowMenu)
      SetMenuItemState(#WMN_mnuWindowMenu, #WMN_mnuTracing, gbDoDebug)
    EndIf
    If IsMenu(#WMN_mnuHelp)
      SetMenuItemState(#WMN_mnuHelp, #WMN_mnuTracing, gbDoDebug)
    EndIf
  EndIf
  
EndProcedure

; Convert FILETIME to 64-bit nanoseconds (100-ns units)
Procedure.q FileTimeToQuad(*ft.FILETIME)
  ProcedureReturn (*ft\dwHighDateTime << 32) | (*ft\dwLowDateTime & $FFFFFFFF)
EndProcedure

; Calculate CPU usage between two samples
Procedure.f CalculateCPUUsage(prevIdle.q, prevKernel.q, prevUser.q, currIdle.q, currKernel.q, currUser.q)
  Protected qDeltaIdle.q
  Protected qDeltaKernel.q
  Protected qDeltaUser.q
  Protected qDeltaTotal.q
  Protected qBusyTime.q
  
  qDeltaIdle = currIdle - prevIdle
  qDeltaKernel = currKernel - prevKernel
  qDeltaUser = currUser - prevUser
  qDeltaTotal = qDeltaKernel + qDeltaUser
  
  ; Handle edge cases
  If qDeltaTotal <= 0 Or qDeltaIdle < 0 Or qDeltaKernel < 0 Or qDeltaUser < 0
    ProcedureReturn 0.0 ; Invalid sample, return 0%
  EndIf

  ; CPU Usage = (Total - Idle) / Total * 100
  
  qBusyTime = qDeltaTotal - qDeltaIdle
  
  If qBusyTime < 0
    qBusyTime = 0 ; Prevent negative usage
  EndIf

  ProcedureReturn (qBusyTime / qDeltaTotal) * 100.0
EndProcedure

; EOF