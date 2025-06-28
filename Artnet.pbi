; ARTNET 
EnableExplicit

CompilerIf Not #PB_Compiler_Thread
  CompilerError "Use Compiler-Option ThreadSafe!"
CompilerEndIf

; Adds DMX data to the queue and handled the Mutext lock in case we try to send whilst bulding the packet.
; Dynamically add an element to a list, this saves us doing lots of mallocs and free's as it is all handled by the list commands
; takes a dmx universes worth of data and adds it to the end of the network buffer which is a List, when we transmit we take the first elemnt in the list and remove it
; Returns 1 good or 3 out of memory allocating a new element, upon exit the buffer corrisponding to *dmxDATA can be refilled ready for the next frame
Procedure.i artnet_addDmxDataToQueue(*dmxData, cUniverseSlot.c, wBufferLength.w)
  Protected nResult.i
  Protected sNames.s
  
  LockMutex(ghArtnetMutex)
    If ListSize(artnetDmxSend_l()) < #ARTNET_MAX_TX_QUE_DEPTH
      ; debug "index: " + universeSlot
      LastElement(artnetDmxSend_l())                                                              ; move to end element and add one
      
      If AddElement(artnetDmxSend_l()) = 0
        ; debug "Add element fail, memory?"
        nResult = 2
      EndIf
    EndIf
      
    LastElement(artnetDmxSend_l())                                                                ; move to end element, if we can
    sNames = #ARTNET_PROTOCOL_NAME
    PokeS(@artnetDmxSend_l(), #ARTNET_PROTOCOL_NAME, Len(sNames), #PB_Ascii)
    PokeC(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET, #ARTNET_DATA_PACKET) 
    PokeA(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET + 3, #ARTNET_VERSION_INFO) 
    PokeA(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET + 4, gnArtnetsequenceOut(cUniverseSlot))      ; Sequence number, 0 disables
    PokeA(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET + 5, 0)                                      ; universeSlot high byte
    PokeA(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET + 6, gnArtnetUniversesLookup(cUniverseSlot))  ; universeSlot number
    PokeC(@artnetDmxSend_l() + #ARTNET_OPCODE_OFFSET + 7, #ARTNET_DMX_BUFFER_SIZE)
    artnetDmxSend_l()\cUniverseIndex = cUniverseSlot
    nResult | 1
    gnArtnetsequenceOut(cUniverseSlot) + 1                         ; increment the sequence number
    
    If gnArtnetsequenceOut(cUniverseSlot) = 0                      ; in the artnet spec sequence = 0 is used to disable using sequence.
      gnArtnetsequenceOut(cUniverseSlot) = 1
    EndIf

    If wBufferLength <= #ARTNET_DMX_BUFFER_SIZE
      CopyMemory(*dmxdata + 1, @artnetDmxSend_l() + 18, wBufferLength)                          ; copy the dmx data into the queue
    Else
      CopyMemory(*dmxdata + 1, @artnetDmxSend_l() + 18, #ARTNET_DMX_BUFFER_SIZE)                ; copy the dmx data into the queue
    EndIf
    
    artnetDmxSend_l()\nReady = nResult
  UnlockMutex(ghArtnetMutex)
  ProcedureReturn nResult
EndProcedure

; sends dmx data as called by the timer DMXOUT, builds in the passed in DMX buffer and gets transfered to a list in dmxsend()
Procedure.i artnet_send_DmxData()
  Protected nResult.i
  Protected hConnectionId.i
  Protected nIndex.i
  
  nResult = 0
  FindMapElement(artnetTimers_m(), "POLL_TIMEOUT")                      ; check that we have received polls and are not timmed out

  If artnetTimers_m()\nActive = 1 And ListSize(artnetDmxSend_l()) <> 0   ; the timer is active and there is data ready to send
    hConnectionId = OpenNetworkConnection(gsArtnetBroadcastIp, #ARTNET_PORT, #PB_Network_UDP)
    
    If hConnectionId
      LockMutex(ghArtnetMutex)
      
        Repeat
          If ListSize(artnetDmxSend_l()) > 0
            FirstElement(artnetDmxSend_l())
            nIndex = artnetDmxSend_l()\cUniverseIndex
            ; Debug "index: " + nIndex
            
            If artnetDmxSend_l()\nReady <> 0                            ; a useful flag to prevent sending if the packet is still being built
              nResult = SendNetworkData(hConnectionId, @artnetDmxSend_l(), #ARTNET_DMX_OUT_SIZE)
              
              ;If nResult = #ARTNET_DMX_OUT_SIZE
                DeleteElement(artnetDmxSend_l(), 1)  ; the flag parameter here for DeleteElement importantly moves us back to the top of the list to always point at the first
              ;EndIf
            EndIf
          EndIf
        Until ListSize(artnetDmxSend_l()) = 0
      
      UnlockMutex(ghArtnetMutex)
      CloseNetworkConnection(hConnectionId)
    EndIf
  EndIf
  
  ProcedureReturn nResult
EndProcedure

Procedure.i artnet_send_poll_response(nTargetId.i, sIpStrFixed.s)
  Protected sIpString.s
  Protected hConnectionId.i
  Protected nResult.i
  
  If Len(sIpStrFixed) > 0
    sIpString = sIpStrFixed
  Else
    sIpString = IPString(GetClientIP(nTargetId))
  EndIf
  
  hConnectionId = OpenNetworkConnection(sIpString, gnArtnetPort, #PB_Network_UDP)
  
  If hConnectionId
    artnet_build_poll_reply(*gpArtnetTxBuffer)
    nResult = SendNetworkData(hConnectionId, *gpArtnetTxBuffer, #ARTNET_POLLREPLY_SIZE)
    CloseNetworkConnection(hConnectionId)
    ProcedureReturn nResult
  EndIf
EndProcedure

Procedure.i artnet_send_poll_request()
  Protected nResult.i
  Protected hConnectionId.i
  
  nResult = 0
  hConnectionId = OpenNetworkConnection(gsArtnetBroadcastIp, gnArtnetPort, #PB_Network_UDP)
  
  If hConnectionId
    artnet_build_poll_request(*gpArtnetTxBuffer)
    nResult = SendNetworkData(hConnectionId, *gpArtnetTxBuffer, #ARTNET_POLLREQUEST_SIZE)
    CloseNetworkConnection(hConnectionId)
    ProcedureReturn nResult
  EndIf
EndProcedure

; Create a universal timer by using a map to a structure. 
; The timer will act as a normal timer by setting the qInterval. Set count > 0 for a limited set of repeats i.e.  1 for a 1 shot.
; set the count -1 for a random time between 10mS and your qInterval time. Artnet spec wants poll reply times to be random under 1 second
; A timer can be made active or deactive by setting active to 1 or deactivate with 0
; Calling the timer with different parameters will retart the timer with those new settings.
; The timers go by name i.e. "POLL"
; Each timer has a pointer to a function and a client ID (from which you can extract the IP) the timer can call that function with that ID
Procedure artnet_addTimer(sName.s, *pFunction, qInterval.q, nCount.i, nActive.i)
  AddMapElement(artnetTimers_m(), sName, #PB_Map_ElementCheck)   ; create timer if it does not exist
  artnetTimers_m()\qThisTime = ElapsedMilliseconds()
  artnetTimers_m()\qLastTime = artnetTimers_m()\qThisTime
  artnetTimers_m()\pFunction = *pFunction
  artnetTimers_m()\nCount = nCount
  artnetTimers_m()\nActive = nActive
  artnetTimers_m()\sTimerName = sName
  artnetTimers_m()\hClient = ghArtnetClientId
  artnetTimers_m()\qStoredInterval = qInterval
  
  If artnetTimers_m()\nCount = -1                            ; if -1 generate a random number between 10mS and qInterval
    artnetTimers_m()\qInterval = Random(artnetTimers_m()\qStoredInterval, 10)        ; 2000  = 2 seconds
  Else
    artnetTimers_m()\qInterval = qInterval
  EndIf
EndProcedure

Procedure.i artnet_process_timer(sTimerIdProc.s)
  Protected nResult.i, nTxResult.i
  
  FindMapElement(artnetTimers_m(), sTimerIdProc)              ; retrives the wanted map
  nResult = 0
  
  If artnetTimers_m()\nActive <> 0
    artnetTimers_m()\qThisTime = ElapsedMilliseconds()
    
    If artnetTimers_m()\qThisTime > (artnetTimers_m()\qLastTime + artnetTimers_m()\qInterval)    ; timed out
      ;Debug timerId_Proc + " " + artnetTimers_m()\qThisTime + " " + artnetTimers_m()\qLastTime + " " + artnetTimers_m()\qInterval + " " + artnetTimers_m()\count
      artnetTimers_m()\qLastTime = artnetTimers_m()\qThisTime
      
      If artnetTimers_m()\nCount = -1                          ; if -1 generate a random number between 10mS and storedqInterval
        artnetTimers_m()\qInterval = Random(artnetTimers_m()\qStoredInterval, 10) 
      EndIf
      
      If artnetTimers_m()\nCount > 0
        artnetTimers_m()\nCount - 1
        
        If artnetTimers_m()\nCount = 0
          artnetTimers_m()\nActive = 0                           ; we have done the required number of loops, deactivate timer
        EndIf
      EndIf
      
      nResult = 1
    EndIf
    ; 09/03/2025 Mod by Dee to always send regardless of the Poll timer (Gregor Mucha emails)
    If nResult = 1
      Select artnetTimers_m()\sTimerName
        Case "DMXOUT"
          PushMapPosition(artnetTimers_m())
          FindMapElement(artnetTimers_m(), "POLL_TIMEOUT")                 ; switch to the POLL TIMEOUT timer
          artnet_addTimer("POLL_TIMEOUT", 0, #ARTNET_POLL_TIMEOUT, 1, 1)              ; refresh the timer for received artnet poll requests
         
          If artnetTimers_m()\nActive = 1                                  ; Is the POLL TIMEOUT timer active? i.e. we have receivd an artnet poll in the last few seconds
            FindMapElement(artnetTimers_m(), "DMXOUT")                     ; switch back To the DMXOUT timer
            ; debugMsg(sProcName, "DMXOut")
            
            If artnetTimers_m()\pFunction <> 0 
              ; call the function only if it is specified
              nTxResult = CallFunctionFast(artnetTimers_m()\pFunction, artnetTimers_m()\hClient)   ; calls send_DmxData()
              
              If nTxResult <> #ARTNET_DMX_OUT_SIZE
                ; debug("TX Data fail: ")
              Else
                ; debug("TX Data OK")
              EndIf
            EndIf
          EndIf
          PopMapPosition(artnetTimers_m())
          
        Case "POLL_TIMEOUT"                                         ; timout timer for incoming poll requests 
          ; This is here for debugging or if we need to take action on this in the future
          ;; debug " " + artnetTimers_m()\qThisTime + " " + artnetTimers_m()\qLastTime + " " + artnetTimers_m()\qInterval + " " + artnetTimers_m()\count
          debugMsg(sProcName, "POLL_TIMEOUT " + artnetTimers_m()\nActive)
         
        Case "POLL_REQUEST"                                         ; timer for sending our own artnet poll requests
          If artnetTimers_m()\pFunction <> 0
          nTxResult = CallFunctionFast(artnetTimers_m()\pFunction, artnetTimers_m()\hClient)
          
          If nTxResult <> #ARTNET_POLLREQUEST_SIZE
            ; debug("TX Pollreq fail: ")
          Else
            artnet_addTimer("POLL_REQUEST", @artnet_send_poll_request(), #ARTNET_POLL_REPLY_TIME, 1000000, 1)      ; timer for transmitted artnet poll requests

            ; debug("TX Pollreq OK")
            ; nTxResult = artnet_send_poll_response(artnetTimers_m()\hClient, gsArtnetBroadcastIp) 
            
            ;If txResult <> #ARTNET_POLLREQUEST_SIZE
              ; debug("TX Poll response internal: fail")
            ;Else
              ; debug("TX Poll response internal: OK")
            ;EndIf
          EndIf
        EndIf
      EndSelect
      nResult = 1
    EndIf
  EndIf
  ProcedureReturn nResult
EndProcedure  

Procedure artnet_build_poll_reply(*gpArtnetTxBufferProc)
  Protected sNames.s
  Protected nIndex.i

  FillMemory(*gpArtnetTxBufferProc, #ARTNET_BUFFER_SIZE, 0)
  sNames = #ARTNET_PROTOCOL_NAME
  PokeS(*gpArtnetTxBufferProc, #ARTNET_PROTOCOL_NAME, Len(sNames), #PB_Ascii)
  PokeC(*gpArtnetTxBufferProc + #ARTNET_OPCODE_OFFSET, #ARTNET_POLL_REPLY) 
  PokeL(*gpArtnetTxBufferProc + 10, makeIPAddressFromString(gsArtnetIpToBindTo))
  PokeC(*gpArtnetTxBufferProc + 14, #ARTNET_PORT)
  PokeC(*gpArtnetTxBufferProc + 17, #ARTNET_VERSION_INFO)
  PokeA(*gpArtnetTxBufferProc + 18, 0)
  PokeA(*gpArtnetTxBufferProc + 19, 0)
  PokeC(*gpArtnetTxBufferProc + 20, $A5A5)                 ; OEM info field, we need to request this from artnet!!!
  PokeA(*gpArtnetTxBufferProc + 22, 0)
  PokeA(*gpArtnetTxBufferProc + 23, 0)
  PokeC(*gpArtnetTxBufferProc + 24, 0)                     ; ESTA manufatures code, basically Artistic licence code for ART-OSC
  sNames = #ARTNET_SHORT_NAME
  PokeS(*gpArtnetTxBufferProc + 26, #ARTNET_SHORT_NAME, Len(sNames), #PB_Ascii)
  sNames = #ARTNET_LONG_NAME
  PokeS(*gpArtnetTxBufferProc + 44, #ARTNET_LONG_NAME, Len(sNames), #PB_Ascii)
EndProcedure

Procedure artnet_build_poll_request(*gpArtnetTxBufferProc)
  Protected sNames.s
  
  FillMemory(*gpArtnetTxBufferProc, #ARTNET_BUFFER_SIZE, 0)
  sNames = #ARTNET_PROTOCOL_NAME
  PokeS(*gpArtnetTxBufferProc, #ARTNET_PROTOCOL_NAME, Len(sNames), #PB_Ascii)
  PokeC(*gpArtnetTxBufferProc + #ARTNET_OPCODE_OFFSET, #ARTNET_POLL_REQUEST) 
  PokeA(*gpArtnetTxBufferProc + 11, #ARTNET_VERSION_INFO)
  PokeA(*gpArtnetTxBufferProc + 12, 2)
  PokeA(*gpArtnetTxBufferProc + 13, 0)
  PokeA(*gpArtnetTxBufferProc + 14, 0)
EndProcedure

Procedure.i artnet_thread(threadparam.i)
  PROCNAMEC()
  Protected nResult.i
  Protected hNetworkServer.i
  Protected nFound.i
  Protected nIsElement.i
  Protected qElapsed.q
  Protected *pTimerOK
  
  debugMsg(sProcName, "Artnet thread started")
  nResult = 0
  hNetworkServer = CreateNetworkServer(#PB_Any, gnArtnetPort, #PB_Network_IPv4 | #PB_Network_UDP, gsArtnetIpToBindTo)
  
  If hNetworkServer
    ; to start sending data enable the dmxout timer, to stop send an addtimer with active set to 0
    artnet_addTimer("POLL_TIMEOUT", 0, #ARTNET_POLL_TIMEOUT, 1, 1)                               ; timer for received artnet poll requests
    artnet_addTimer("POLL_REQUEST", @artnet_send_poll_request(), #ARTNET_POLL_REPLY_TIME, 1000000, 1)  ; timer for transmitted artnet poll requests
    artnet_addTimer("DMXOUT", @artnet_send_DmxData(), #DMX_RATE, 0, 1) 
    gn_ArtnetActive = 1
    ; start TX'ing data, depends upon poll rx being received
    ; debug("PureBasic - Server" + "Server created (Port "+ artnetPort + ") ")
    qElapsed = ElapsedMilliseconds()

    Repeat
      ; Modified 04/03/2025 by Dee to slow the rate at which timers are processed
      If #DMX_RATE + qElapsed <= ElapsedMilliseconds()                                                ; this controls the DMX refresh rate for a universe 25mS
        ForEach artnetTimers_m()                                                                      ; action each timer
          artnet_process_timer(artnetTimers_m()\sTimerName)
        Next
      EndIf
      
      gnArtnetServerEvent = NetworkServerEvent(hNetworkServer)
      
      If gnArtnetServerEvent
        ghArtnetClientId = EventClient()
        
        Select gnArtnetServerEvent
          Case #PB_NetworkEvent_Connect
            ; debug("PureBasic - Server" + "A new client has connected " + GetClientIP(ghArtnetClientId))
    
          Case #PB_NetworkEvent_Data
            ReceiveNetworkData(ghArtnetClientId, *gpArtnetRxBuffer, #ARTNET_BUFFER_SIZE)      ; load the rx data into a buffer
            gsArtnetId = PeekS(*gpArtnetRxBuffer, -1, #PB_Ascii)
            
            If gsArtnetId = #ARTNET_PROTOCOL_NAME
              gnArtnetOpcode = PeekC(*gpArtnetRxBuffer + #ARTNET_OPCODE_OFFSET)                ; Opcode, Poll $2000, poll reply $2100, or data (DMX) $5000
              gnArtnetProtVer = PeekC(*gpArtnetRxBuffer + #ARTNET_PROTOCOL_VERSION_OFFSET)     ; Protocol version
              gnArtnetsequence = PeekA(*gpArtnetRxBuffer + #ARTNET_SEQUENCE_NUMBER_OFFSET)     ; Packet sequence number
              gnArtnetphysical = PeekA(*gpArtnetRxBuffer + #ARTNET_PHYSICAL_OFFSET)            ; Physical DMX port
              gnArtnetUniverse = PeekC(*gpArtnetRxBuffer + #ARTNET_UNIVERSE_OFFSET)            ; This is universe
              gnArtnetlength = PeekC(*gpArtnetRxBuffer + #ARTNET_LENGTH_OFFSET)                ; Length of DMX Data
             
              Select gnArtnetOpcode                                                          ; determine the artnet packet type and act accordingly
                Case #ARTNET_POLL_REQUEST
                  ;; debug("Poll from "+ IPString(GetClientIP(ghArtnetClientId)) + " ID: " + artnetId + " Opcode: " + gnArtnetOpcode + " ProtVer" + artnetProtVer)
                  ; We can use the polls to creat a network map as they should happen every few seconds
                  ; #ARTPOLL_TALK_TO_ME_OFFSET, should be 0 but if 1 Artpollreply on change becomes active
                  ; #ARTPOLL_DPALL_OFFSET, always 0
                  
                  ; send a poll reply Note UDP maximum 'Length' is 2048, this needs a random delay up to 1 second as described in the Art-net docs
                  artnet_send_poll_response(ghArtnetClientId, "")
                  ;Debug "K: " + Str(ElapsedMilliseconds())

  ; ARTPOLL_TALK_TO_ME aka Flags in the documentation. Known as Talk to me in wireshark.  1 byte with the bits described as below
  ; Bit 0 is unused
  ; Bit 1 Send me ArtPollReply on change: Disabled
  ; Bit 2 Send diagnostics messages: Disabled
  ; Bit 3 Send diagnostics unicast: Broadcast (0x0)
  ; Bit 4 VLC transmission: Enabled
  ; Bit5 Targeted mode: Disabled
  ; Bits 6-7 unused
  ; DpALL, Diagnostics byte. I doubt we will every use this, allways 0
  
                Case #ARTNET_POLL_REPLY
                  ; We can use the poll responses to creat a network map as they should happen every few seconds even the controller should respond to it's own poll request
                  ; debug("Poll reply from "+ IPString(GetClientIP(artnet_ClientId)) + " ID: " + artnetId + " Opcode: " + artnetOpcode + " ProtVer" + artnetProtVer)
                  
                  ; store the poll reponses in a list, update each time they are received and store the time in milliseconds
                  ; if the elapsed time is greater than 3 seconds remove it from the list. This could be change to be an active flag if we want to show
                  ; red green status's on any devices we have connected to. There could be another timeout say 5 mins before removal.
                  nFound = 0
                  ;Debug "i: " + IPString(GetClientIP(ghArtnetClientId))
                  ResetList(artnetPollReplies_l())                                              ; resets to before the list so n element is valid
                    
                  ; Do we have this client listed?
                  Repeat
                    nIsElement = NextElement(artnetPollReplies_l())
                   
                    If nIsElement <> 0
                      If artnetPollReplies_l()\sArtnetClientId = IPString(GetClientIP(ghArtnetClientId))
                        nfound = 1
                      EndIf
                    EndIf  
                    
                  Until nIsElement = 0 Or nfound = 1
                  
                  ; Add new client if not found
                  ; Modified 04/03/2025 by Dee to fix a timming bug, reduce self poll requests and maintain the client map correctly
                  If nfound = 0
                    AddElement(artnetPollReplies_l())
                    nFound = 1
                  EndIf
                  
                  If artnetPollReplies_l()\sArtnetClientId <> gsArtnetIpToBindTo
                    artnet_addTimer("POLL_TIMEOUT", 0, #ARTNET_POLL_TIMEOUT, 1, 1)              ; refresh the timer for received artnet poll requests
                  EndIf
                  
                  artnetPollReplies_l()\sArtnetClientId = IPString(GetClientIP(ghArtnetClientId))
                  artnetPollReplies_l()\sArtnetId = gsArtnetId
                  artnetPollReplies_l()\cArtnetOpcode = gnArtnetOpcode
                  artnetPollReplies_l()\cArtnetProtVer = gnArtnetProtVer
                  artnetPollReplies_l()\qArrived = ElapsedMilliseconds()
                  ResetList(artnetPollReplies_l())                                              ; resets to before the list so n element is valid
                    
                  Repeat
                    nIsElement = NextElement(artnetPollReplies_l())
                   
                    If nIsElement <> 0
                      If artnetPollReplies_l()\sArtnetClientId <> gsArtnetIpToBindTo And artnetPollReplies_l()\qArrived + #ARTNET_POLL_TIMEOUT <= ElapsedMilliseconds()
                        ;Debug "d: " + "Deleting " + artnetPollReplies_l()\sArtnetClientId + " t1: " + Str(artnetPollReplies_l()\qArrived  + #ARTNET_POLL_TIMEOUT) + " t2: " + Str(ElapsedMilliseconds())
                        DeleteElement(artnetPollReplies_l())
                      EndIf
                    EndIf  
                    
                  Until nIsElement = 0
                  
                  ; Here is the info for the Artnet poll reply, we will need to send these so useful info, I have added the sizes and byte counts in the first column
                  ; Consumers of ArtPollReplyshall accept As valid a packet of length 198
  ;  00.s   Art-Net, Opcode: ArtPollReply (0x2100)
  ;             Descriptor Header
  ;                 ID: Art-Net
  ;  08.c           OpCode: ArtPollReply (0x2100)
  ;             ArtPollReply packet
  ;  10.l           IP Address: 192.168.8.252
  ;  14.c           Port number: 6454
  ;  16.c           Version Info: 0x000e
  ;  18.a           NetSwitch: 0x00
  ;  19.a           SubSwitch: 0x00
  ;  20.c           Oem: ChamSys: MagicQ  (0x08c0)
  ;  22.a           UBEA Version: 0
  ;  23.a           Status: 0x00, Port Address Programming Authority: unknown, Indicator State: unknown
  ;  24.c           ESTA Code: ChamSys Ltd. (0x050a)
  ;  26.s+18        Short Name: ChamSys MagicQ
  ;  44.s+64        Long Name: ChamSys MagicQ console
  ; 108.a+64        Node Report: 
  ; 172.a           Port Info
  ;                     Number of Ports: 4
  ;                     Port Types
  ;                         Type of Port 1: Art-Net <-> DMX512 (0xc0)
  ;                         Type of Port 2: Art-Net <-> DMX512 (0xc0)
  ;                         Type of Port 3: Art-Net <-> DMX512 (0xc0)
  ;                         Type of Port 4: Art-Net <-> DMX512 (0xc0)
  ;                     Input Status
  ;                         Input status of Port 1: 0x80
  ;                         Input status of Port 2: 0x80
  ;                         Input status of Port 3: 0x80
  ;                         Input status of Port 4: 0x80
  ;                     Output Status
  ;                         Output status of Port 1: 0x80
  ;                         Output status of Port 2: 0x80
  ;                         Output status of Port 3: 0x80
  ;                         Output status of Port 4: 0x80
  ;                     Input Subswitch
  ;                         Input Subswitch of Port 1: 0x00
  ;                         [Universe of input port 1: 0]
  ;                         Input Subswitch of Port 2: 0x01
  ;                         [Universe of input port 2: 1]
  ;                         Input Subswitch of Port 3: 0x02
  ;                         [Universe of input port 3: 2]
  ;                         Input Subswitch of Port 4: 0x03
  ;                         [Universe of input port 4: 3]
  ;                     Output Subswitch
  ;                         Output Subswitch of Port 1: 0x00
  ;                         [Universe of output port 1: 0]
  ;                         Output Subswitch of Port 2: 0x01
  ;                         [Universe of output port 2: 1]
  ;                         Output Subswitch of Port 3: 0x02
  ;                         [Universe of output port 3: 2]
  ;                         Output Subswitch of Port 4: 0x03
  ;                         [Universe of output port 4: 3]
  ;                 SwVideo: Displaying local data (0x00)
  ;                 SwMacro: 0x00
  ;                 SwRemote: 0x00
  ;                 spare: 000000
  ;                 Style: StController (Lighting console) (0x01)
  ;                 MAC: 00:00:00_00:00:00 (00:00:00:00:00:00)
  ;                 Bind IP Address: 0.0.0.0
  ;                 Bind Index: 0x00
  ;                 Status2: 0x00, Port-Address size: 8bit Port-Address
  ;                 filler: 000000000000000000000000000000000000000000000000000000000000000000000000…
  ;         
                Case #ARTNET_DATA_PACKET        ; process the rx dmx data maybe move the data into a list
                  CompilerIf (#ARTNET_RX_ENABLE)
                  
                    LockMutex(ghArtnetRxMutex)
                    LastElement(ghArtnetRxList())
                    AddElement(ghArtnetRxList())                 
                    ghArtnetRxList()\qTimestamp = ElapsedMilliseconds()
                    CopyMemory(*gpArtnetRxBuffer, @ghArtnetRxList()\aDmxDataArray[0], #ARTNET_DMX_BUFFER_SIZE)    ; dmx data starts at #ARTNET_DATA_OFFSET
                    
                    ; if the list gets to large remove the first element which will be the oldest.
                    If ListSize(ghArtnetRxList()) > 4
                      FirstElement(ghArtnetRxList())
                      DeleteElement(ghArtnetRxList())
                    EndIf
                    
                    
                    SignalSemaphore(smArtnetRxSemaphore)
                    UnlockMutex(ghArtnetRxMutex)  
                    
                    ; ; *************************** in the dmx RX processing use something like, DMX RX needs some work to enable
                    ; If CreateThread(@artnet_thread(), 30)
  
                    ; wait for one element to be available
                    ;If TrySemaphore(Semaphore) <> 0
                    ;
                    ;  ; display the queue state
                    ;  LockMutex(Mutex)
                    ;    Queue$ = "Queue:"
                    ;    ForEach Queue()
                    ;      Queue$ + " " + Str(Queue())
                    ;    Next Queue()
                    ;    Debug Queue$
                    ;  
                    ;    ; remove head element from the queue
                    ;    FirstElement(Queue())
                    ;    DeleteElement(Queue())
                    ;  UnlockMutex(Mutex)
                    ;EndIf
                CompilerEndIf                  
              EndSelect  
              
              ;; debug "Artnet packet " + Hex(type)
            EndIf
            
          Case #PB_NetworkEvent_Disconnect
            ; debug("PureBasic - Server " + "Client "+artnet_ClientId+" has closed the connection...")
            gnArtnetQuitThread = 1
        EndSelect
      Else
        Delay(1)                                            ; if nothing to process go easy on system resources.
      EndIf
    Until gnArtnetQuitThread = 2
    
    ForEach artnetTimers_m()                                ; action each timer
     DeleteMapElement(artnetTimers_m(), artnetTimers_m()\sTimerName)
    Next
    ; remove all the dmx buffers in the list, prevents memory leaks.
    ClearList(artnetDmxSend_l())
    ClearList(artnetPollReplies_l())
    debugMsg(sProcName, "Closing Artnet thread")
  Else
    debugMsg(sProcName, "Error: Can't create the server (port in use ?).")
    nResult = 3
  EndIf
  
  If hNetworkServer
    CloseNetworkServer(hNetworkServer)
  EndIf
  
  gn_ArtnetActive = 0
  
  ProcedureReturn nResult
EndProcedure

; Run the artnet thread
Procedure.i Artnet_init()
  PROCNAMEC()
  Protected nIndex.i
  
  If gnArtnetQuitThread = 1 Or gn_ArtnetActive = 1
    Artnet_close()
  EndIf
  
  debugMsg(sProcName, "Artnet initialising")
  *gpArtnetRxBuffer = AllocateMemory(#ARTNET_BUFFER_SIZE)                                ; headers + 512 bytes of data
  *gpArtnetTxBuffer = AllocateMemory(#ARTNET_BUFFER_SIZE)                                ; headers + 512 bytes of data
  *gpArtnetMyDmx = AllocateMemory(#ARTNET_DMX_BUFFER_SIZE)                               ; the DMX_TX buffer for testing can be replaces with any 512 byte DMX buffer if not testing
  ;gsArtnetIpToBindTo = #ARTNET_IP_TO_BIND                                               ; now set in DMX.pbi - DMX_openDMXDev
  
  For nIndex = 0 To #ARTNET_MAX_UNIVERSES - 1
    gnArtnetUniversesLookup(nIndex) = nIndex                                             ; initialise the artnet universes 0 - 3
  Next
  
  ghArtnetThreadId = CreateThread(@artnet_thread(), 0)
  ProcedureReturn ghArtnetThreadId
EndProcedure

; Close all the buffers nicely to prevent memory leaks
Procedure Artnet_close()
  Protected nResult.i
  
  debugMsg(sProcName, "Artnet closing")
  
  If ghArtnetThreadId 
    gnArtnetQuitThread = 2                                                                 ; tells the main loop to stop processing ans shutdown in a tidy manner
    nResult = WaitThread(ghArtnetThreadId)                                                 ; wait for the artnet thread to clean up and stop
  EndIf
  
  If *gpArtnetTxBuffer
    FreeMemory(*gpArtnetTxBuffer)
    *gpArtnetTxBuffer = 0
  EndIf
   
  If *gpArtnetRxBuffer
    FreeMemory(*gpArtnetRxBuffer)
    *gpArtnetRxBuffer = 0
  EndIf
  
  If *gpArtnetMyDmx
    FreeMemory(*gpArtnetMyDmx)
    *gpArtnetMyDmx = 0
  EndIf
  
  gnArtnetQuitThread = 0                                                                 
  gn_ArtnetActive = 0
EndProcedure

; End of artnet program
  
