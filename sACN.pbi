; sACN send

EnableExplicit
  
; Define the dll callback function, use for extreme debugging only
; Procedure MyLogCallback(message, number.i)
;     Debug PeekS(message, -1, #PB_UTF8) + ": " + Str(number) ; Convert UTF-8 to PureBasic string
; EndProcedure
  
; Enables an instance of sACN for each universe 
; returns 0 if successful, a negative number upon failure
Procedure.i sACNInitialise(s_sACNIp.s, cUniverse.c)
  PROCNAMEC()
  Protected nResult.i
  Protected nMy_sACNIpx.l
  Protected Dim an_sACNIpf.l(4)
  Protected nIndex.i
  Protected sTempString.s

  debugMsg(sProcName, "sACN initialising")
  
  If FindMapElement(gm_sACnActive(), Str(cUniverse)) = 0    ; If the Map element does Not exist add a new one for this universe 
    AddMapElement(gm_sACnActive(), Str(cUniverse))
    gm_sACnActive() = 0                                     ; this stores the activation flag for each universe instance
  EndIf
  
  For nIndex = 1 To 4                              ; Turn the n_sACNIp string into a standard winsock n_sACNIp in a long var, PB is problamatic passing pointers and strings to the dll
    an_sACNIpf(nIndex) = Val(StringField(s_sACNIp, nIndex, "."))
  Next
  
  nMy_sACNIpx = MakeIPAddress(an_sACNIpf(1), an_sACNIpf(2), an_sACNIpf(3), an_sACNIpf(4))   ; nMy_sACNIpx is a long containing the n_sACNIpv4 address as used by winsock, equivelent to inet_addr()
  
  ; Open the dll and set up the function calls
  If gh_sACNLib = 0
    CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
      gh_sACNLib = OpenLibrary(#PB_Any, "sACN.dll")
    CompilerElse
      gh_sACNLib = OpenLibrary(#PB_Any, "sACN_x86.dll")
    CompilerEndIf
  
    If gh_sACNLib                                                   ; Check if the dll opened
      sACNStart.sACNInit = GetFunction(gh_sACNLib, "sACNInit")      ; starts a sACN instance for that universe, returns 0 for OK anything else for fail
      sACNSendDmxData.sACNTxDmx = GetFunction(gh_sACNLib, "sACNTxDmx")
      sACNEnd.sACNClose = GetFunction(gh_sACNLib, "sACNClose")
      sACNDmxTxBuffer.sACNGetDmxTxBuffer = GetFunction(gh_sACNLib, "sACNGetDmxTxBuffer")
      sACNDmxRxBuffer.sACNGetDmxRxBuffer = GetFunction(gh_sACNLib, "sACNGetDmxRxBuffer")
      sACNDmxRxSize.sACNgetDmxRxSize = GetFunction(gh_sACNLib, "sACNgetDmxRxSize")
      ;SetLogCallback.SetLogCallbackPrototype = GetFunction(gh_sACNLib, "SetLogCallback")
      ;SetLogCallback(@MyLogCallback())
      debugMsg(sProcName, "sACN dll initialised")
    Else
      debugMsg(sProcName, "sACN library failed to load")
      ProcedureReturn -3
    EndIf
  EndIf

  If gm_sACNActive() = 0 
      ;WSACleanup_()
                                                                  ; we need to initailise this instance 
    nResult = sACNStart(nMy_sACNIpx, cUniverse)                   ; call the sACN initialisetion function, pass in the n_sACNIp to send from and a starting univerese
                                                                  ; returns the handle to that instance
    If nResult = 0
      gm_sACnActive() = cUniverse                                 ; Global flag for active sACN on that universe
      ProcedureReturn 0  
    Else
      sACNEnd(cUniverse.c)
      Restore sACNErrorMessages
      
      For nIndex = 0 To nResult
        Read.s sTempString                                        ; read the string eqiuivelent error message from the dll
      Next
      
      debugMsg(sProcName, "sACN failed to start with error: " + sTempString + "(" + nResult + ")")
      ProcedureReturn -1
    EndIf
  Else
    debugMsg(sProcName, "sACn instance aready in use for universe: " + cUniverse)
    ProcedureReturn -2
  EndIf
  ProcedureReturn -4                                               ; never happens
EndProcedure

Procedure sACNFinish(cUniverse.c)
  If FindMapElement(gm_sACnActive(), Str(cUniverse))              ; Do we have a map element for this universe?
    sACNEnd(cUniverse.c)
    gm_sACnActive() = 0
    DeleteMapElement(gm_sACnActive())
  EndIf
EndProcedure

; End of sACN program
