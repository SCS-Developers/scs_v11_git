EnableExplicit

; SCS proto LTC reader. LTC is an bi phase Manchester encoded timecode  audio signal consisting of 80 bits of data
; This uses a windows port of the libltc library
; Visula studio project file LTC\libltc-win-master\msvc\libltc.vcxproj

; The dll and associated test files are bult in LTC\libltc-win-master\msvc\x64\Debug\
; To test a build in windows open a command prompt in the above path for test files and run ltcdecode.exe followed by the wav file you with to decode
; i.e. ltcdecode.exe LTC_00595000_1mins_30fps_44100x8.wav    Note you can use LTC_00595000_1mins_30fps_44100x8R.wav To test For reverse timecode.
; Note audio files are unsigned 8 bit mono in the raw form 

; libltc linux port https://github.com/x42/libltc
; libltc Windows port https://github.com/nbhr/libltc-win
; Free online timecode .wav generator https://elteesee.pehrhovey.net/

; The audio is read from the file in 1024 byte chunks, in practice we would need to open a Bass audio input and read live audio to feed into the decoder.
; the audio is 8 bit only, this should not be a problem as in an ideal world we would read the 16/24/32 bit audio, check for maximum level and shift down to 8 bits.
; I have rewritten the decoder a bit to make life easier and reduce the number of calls between SCS and the DLL
; Once you have the timecode data it is fairly easy to convert it to MIDI MTC, I have a working arduino example c code we can convert if need be.
; I have dumped the results into strings in order to output the debug easily but that can be changed.

; /** the standard defines the assignment of the binary-group-flag bits
;  * basically only 25fps is different, but other standards defined in
;  * the SMPTE spec have been included For completeness.
;  */
;enum LTC_TV_STANDARD {
;	LTC_TV_525_60, ///< 30fps
;	LTC_TV_625_50, ///< 25fps
;	LTC_TV_1125_60,///< 30fps
;	LTC_TV_FILM_24 ///< 24fps
;};
; The above could be selected from a drop down gadget.
; This test program now reads its own generated test file LTC_encode_1.wav
; Output is displayed in the debug window.
; It then regenerates the file with possibly new parameters  and then fills in the header information.

; This file has been tested against LTC_00595000_1mins_30fps_44100x8.wav for accuracy in the header and file size.
; With the correct .wav file header it will open and play in Goldwave audio editor, I then fed this back into Reaper as a LTC timecode input which works well
; You can test for stop start and repositioning which all worked well in testing. I found the shntool.exe useful in testing as it validates .wav file headers.

; Exampe midi sysex send 
;        sysex_fullframe[M_HOURS] = hours;
;        sysex_fullframe[M_MINS] = mins;
;        sysex_fullframe[M_SECS] = secs;
;        sysex_fullframe[M_FRAMES] = frames;
;        usbMIDI.sendSysEx(SizeOf(sysex_fullframe), sysex_fullframe, true);    // sizeof = 10, array, true = start/end bytes not added 0xF0/0xF7

Macro debugBassError(pResult)
  If pResult = 0
    debugMsg(sProcName, "Error: " + getBassErrorDesc(BASS_ErrorGetCode()))
  EndIf
EndMacro

Macro debugBassAsioError(pResult)
  If pResult = 0
    debugMsg(sProcName, "Error: " + getBassErrorDesc(BASS_ASIO_ErrorGetCode()))
  EndIf
EndMacro

Procedure debugChannelInfo(hStream.l)
  PROCNAMEC()
  Protected sStream.s, nBassResult.l
  Protected rChannelInfo.BASS_CHANNELINFO
  
  sStream = decodeHandle(hStream)
  nBassResult = BASS_ChannelGetInfo(hStream, @rChannelInfo)
  debugMsg2(sProcName, "BASS_ChannelGetInfo(" + sStream + ", rChannelInfo)", nBassResult)
  If nBassResult
    With rChannelInfo
      debugMsg(sProcName, "rChannelInfo\flags=$" + Hex(\flags) + ", #BASS_STREAM_DECODE=$" + Hex(#BASS_STREAM_DECODE))
    EndWith
  EndIf
  
EndProcedure

; Callback proceedure for BASS_StreamCreate, *userdata is a pointer to the required map key$
; for 30fps length is set to 7960, IF the BASS buffer is not filled then it will end the stream
; As we have no control over the BASS buffer size requested except we know it will be less that 24k and does not match the 1600 or so from LTCencoder 
Procedure.l StreamCallback(handle.l, *buffer, length.l, *userData)
  PROCNAMEC()
  Protected sTempString.s, nResult.i, iLoop.i
  Protected bytesRead.i, byteOffset.i
  Static qElapsedTime.q
  Protected *tempBuffer, qDiffTime.q
  
  bytesRead = 0
  sTempString = PeekS(*userData)    ; get the name "P1000" etc
 
  ; debugMsg(sProcName, "handle=" + decodeHandle(handle) + ", *buffer=" + *buffer + ", length=" + length + ", *userData=" + sTempString + ", map_ScsLTCGenerators()\nLTCbufferIndex=" + map_ScsLTCGenerators()\nLTCbufferIndex)
  LockMutex(mtx_ScsLTCMutex)
  PushMapPosition(map_ScsLTCGenerators())
  nResult = FindMapElement(map_ScsLTCGenerators(), stempString)

  If nResult
    nResult = (length * 2) + 2048
    
    If map_ScsLTCGenerators()\nAudioBufferSize < nResult
      ReAllocateMemory(map_ScsLTCGenerators()\pAudioBuffer, nResult, #PB_Memory_NoClear)                  ; 2000 is to make the buffer larger so we can fill the BAss buffer, LTC packet < 2000
      map_ScsLTCGenerators()\nAudioBufferSize = nResult
    EndIf
    
    While map_ScsLTCGenerators()\nLTCbufferIndex < length                                                 ; produce an excess of LTC, on stop it will be thrown away
      ltc_encoder_encode_frame(map_ScsLTCGenerators()\pLTCXxcoder)                                        ; encode it
      byteOffset = map_ScsLTCGenerators()\pAudioBuffer + map_ScsLTCGenerators()\nLTCbufferIndex           ; Note: the encoder is looking for a buffer pointer but scs is typeless
      bytesRead = ltc_encoder16_copy_buffer(map_ScsLTCGenerators()\pLTCXxcoder, byteOffset)               ; For the 16 bit version this returns the count of audio data written, for bytes * 2
      map_ScsLTCGenerators()\nLTCbufferIndex + (bytesRead * 2)                                            ; * 2 for 16 bit
      ltc_encoder_inc_timecode(map_ScsLTCGenerators()\pLTCXxcoder)                                        ; generate the next timecode sequence
    Wend
    
    If map_ScsLTCGenerators()\nLTCbufferIndex >= length
      CopyMemory(map_ScsLTCGenerators()\pAudioBuffer, *buffer, length)                                    ; copy to BASS buffer
      map_ScsLTCGenerators()\nLTCbufferIndex - length
      MoveMemory(map_ScsLTCGenerators()\pAudioBuffer + length, map_ScsLTCGenerators()\pAudioBuffer, map_ScsLTCGenerators()\nLTCbufferIndex) ; Move the remainder to the start
      nResult = length 
    Else                                                                                                  ; just copy the partial buffer
      CopyMemory(map_ScsLTCGenerators()\pAudioBuffer, *buffer, map_ScsLTCGenerators()\nLTCbufferIndex)    ; copy all remaining to BASS buffer
      nResult = map_ScsLTCGenerators()\nLTCbufferIndex
      map_ScsLTCGenerators()\nLTCbufferIndex = 0
    EndIf
  EndIf
  
  PopMapPosition(map_ScsLTCGenerators())
  UnlockMutex(mtx_ScsLTCMutex)
  
  ProcedureReturn nResult
EndProcedure

Enumeration
  #BASSERRORTYPE
  #BASSASIOERRORTYPE
EndEnumeration

Procedure bassErrorDebug(nType)
  PROCNAMEC()
  Select ntype
    Case #BASSERRORTYPE
      debugMsg(sProcName, "Bass function error: " + Str(BASS_ErrorGetCode()))
      
    Case #BASSASIOERRORTYPE
      debugMsg(sProcName, "Bass ASIO function error: " + Str(BASS_ASIO_ErrorGetCode()))
  EndSelect
EndProcedure

Procedure.s asioFormatToReadableString(format)
  Protected sTempString.s = "ASIO format set to: "
  
  Select format
    Case 16
      sTempString + "16-bit Integer"
    Case 17
      sTempString + "24-bit Integer"
    Case 18
      sTempString + "32-bit Integer"
    Case 19
      sTempString + "32-bit Floating-point"
    Case 24
      sTempString + "32-bit Integer (16-bit alignment)"
    Case 25
      sTempString + "32-bit Integer (18-bit alignment)"
    Case 26
      sTempString + "32-bit Integer (20-bit alignment)"
    Case 27
      sTempString + "32-bit Integer (24-bit alignment)"
    Case 32
      sTempString + "DSD (LSB 1st)"
    Case 33
      sTempString + "DSD (MSB 1st)"
    Case $100
      sTempString + "Dither Applied"
    Default
      sTempString + "Unknown Format"
  EndSelect
  
  ProcedureReturn sTempString
EndProcedure

; Run the LTC thread
; Called from THR_createOrResumeAThread(#SCS_THREAD_SCS_LTC)

Procedure.i THR_scsLTC(threadparam.i)
  PROCNAMEC()
  Protected nResult.l, sTempString.s, *tempPointer, sTempParseString.s
  Protected nLoop.i, nLen.i, hStream.l
  Protected hNetworkServer.i
  Protected nScsLTCServerEvent.i
  Protected hScsLTCClientId.i
  Protected ltcSmpteEncoder.SMPTETimecode
  Protected Dim sParseLTCCommands.s(0)
  Protected Dim sSmpteNames.s(3)
  Protected Dim dSmpteValues.d(3)
  Protected deviceInfo.BASS_DEVICEINFO
  Protected deviceIndex
  Protected qElapsedTime.q
  Protected sTempKeyStore.s
  Protected nForLTCFound.i
  Protected rAsioDeviceInfo.BASS_ASIO_DEVICEINFO
  Protected rAsioInfo.BASS_ASIO_INFO
  Protected nBASSError.l, nBassDevice.l
  Protected volumeInDB.f
  Protected nBassBufferLength.l
  Protected nBassBufferSize.i
  Protected postEventString.s
  Protected nAsioDevice.l
  Protected nErrorCode.l
  Protected nBassFlags.l
  Protected nDevMapDevPtr, nFirst0BasedOutputChan.l
  Protected t_Bass_ASIO_DeviceInfo.BASS_ASIO_DEVICEINFO
  Protected sTemp1.s, sTemp2.s, fTemp.d
  Protected nAsioBufLen.l

  setThreadNo(#SCS_THREAD_SCS_LTC)  ; preferably set this before calling debugMsg()
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadState = #SCS_THREAD_STATE_ACTIVE
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_INACTIVE
  gaThread(#SCS_THREAD_SCS_LTC)\bThreadCreated = #True

  debugMsg(sProcName, "SCS LTC thread started")
  nResult = 0
  
  Restore SmpteDataS
  
  ; parse the smpte name
  For nLoop = 0 To 3
    Read.s sSmpteNames(nLoop)
  Next

  Restore SmpteDataN
  
  ; parse the smpte name
  For nLoop = 0 To 3
    Read.d dSmpteValues(nLoop)
  Next
  
  debugMsg(sProcName, "Starting LTC Thread")
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_STARTING
  ;debugMsg(sProcName, "gsAppPath=" + #DQUOTE$ + gsAppPath + #DQUOTE$)
  
  CompilerIf #PB_Compiler_Processor = #PB_Processor_x64
    LTCDecode = OpenLibrary(#PB_Any, gsAppPath + "libltc.dll")
  CompilerElse
    LTCDecode = OpenLibrary(#PB_Any, gsAppPath + "libltc_X86.dll")
  CompilerEndIf
  debugMsg(sProcName, "LTCDecode=" + LTCDecode)

  If (LTCDecode)
    ltc_decoder_create = GetFunction(LTCDecode, "ltc_decoder_create")
    ltc_decoder_write = GetFunction(LTCDecode, "ltc_decoder_write")
    ltc_frame_to_time = GetFunction(LTCDecode, "ltc_frame_to_time")
    ltc_decoder_free = GetFunction(LTCDecode, "ltc_decoder_free")
    ltc_encoder_create = GetFunction(LTCDecode, "ltc_encoder_create")
    ltc_encoder_set_buffersize = GetFunction(LTCDecode, "ltc_encoder_set_buffersize")
    ltc_encoder_reinit = GetFunction(LTCDecode, "ltc_encoder_reinit")
    ltc_encoder_set_filter = GetFunction(LTCDecode, "ltc_encoder_set_filter")
    ltc_encoder_set_volume = GetFunction(LTCDecode, "ltc_encoder_set_volume")
    ltc_encoder_set_timecode = GetFunction(LTCDecode, "ltc_encoder_set_timecode")
    ltc_encoder_get_bufferptr = GetFunction(LTCDecode, "ltc_encoder_get_bufferptr")
    ltc_encoder_get_timecode = GetFunction(LTCDecode, "ltc_encoder_get_timecode")
    ltc_encoder_copy_buffer = GetFunction(LTCDecode, "ltc_encoder_copy_buffer")
    ltc_encoder_encode_frame = GetFunction(LTCDecode, "ltc_encoder_encode_frame")
    ltc_encoder_inc_timecode = GetFunction(LTCDecode, "ltc_encoder_inc_timecode")
    ltc_encoder_free = GetFunction(LTCDecode, "ltc_encoder_free")
    ltc_encoder16_copy_buffer = GetFunction(LTCDecode, "ltc_encoder16_copy_buffer")
    ltc_encoder32_copy_buffer = GetFunction(LTCDecode, "ltc_encoder32_copy_buffer")
  
    If (ltc_encoder_create = 0) Or (ltc_decoder_write = 0) Or (ltc_frame_to_time = 0) Or (ltc_decoder_free = 0)
      debugMsg(sProcName, "Failed to get function pointers from DLL")
      gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_STOPPING
    Else
      gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_ACTIVE        ; We are in a position to start to main loop
      debugMsg(sProcName, "LTC thread starting main loop with sub_state = " + gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState)
    EndIf  
  Else
    debugMsg(sProcName, "libltc.dll fault, exiting SCS LTC thread")
    gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_STOPPING
  EndIf  

  While gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_ACTIVE      ; anything else is a failure and we need to shutdown
    If gaThread(#SCS_THREAD_SCS_LTC)\bStopRequested ; Or gbClosingDown
      gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_STOPPING
      Break
    EndIf

    ; wait for one element to be available, waits for a play, pause, stop message to arrive
    
    LockMutex(mtx_ScsLTCMutexCmdList)
    
    If ListSize(list_ScsLTCQueue())                         ; grab the incoming list and extract the command string
      FirstElement(list_ScsLTCQueue())                      ; get the first element in  the list
      sTempParseString = list_ScsLTCQueue()\sScsLTCCommands      ; save the command.
      DeleteElement(list_ScsLTCQueue())                     ; finished with this element
      ; Debug "Tempstring: " + sTempParseString
    Else
      sTempParseString = "       "                          ; 8 spaces to clear the sParseLTCCommands() array
    EndIf  
    
    UnlockMutex(mtx_ScsLTCMutexCmdList)
    nResult = CountString(sTempParseString, " ")
    ReDim sParseLTCCommands(nResult + 2)                      ; ensure the command array has enough slots
    
    For nLoop = 1 To nResult + 1                              ; Loop through the command string and break it up
      sParseLTCCommands(nLoop) = StringField(sTempParseString, nLoop, " ")
;       If sParseLTCCommands(nLoop)
;         debugMsg(sProcName, Str(nLoop) + ": " + sParseLTCCommands(nLoop))
;       EndIf
    Next
    
    sParseLTCCommands(nLoop) = RTrim(StringField(sTempParseString, 2, "ForSub"), ";")
    
    Select sParseLTCCommands(1)                               ; Parse each command and store in a map, we use a map because it is quick and easy to search for the map key
      Case "set"
        ;               1    2     3    4     5       6    7     8                                                           9
        ; SMS command: set tcgen p1000 code smpte24 start tc 01:59:55:0, Procname: TimeCode@1091.setTimeCodeGeneratorForSub[Q12<1>]
        ;                                                    0  1  2  3
                                                              
        If sParseLTCCommands(2) = "tcgen" And sParseLTCCommands(4) = "code" And sParseLTCCommands(7) = "tc"
          If FindMapElement(map_ScsLTCGenerators(), sParseLTCCommands(3)) = 0         ; list element does not exist
            AddMapElement(map_ScsLTCGenerators(), sParseLTCCommands(3))               ; Add a new map set the key to the generator name "p1000" etc
            map_ScsLTCGenerators()\sLTCName = sParseLTCCommands(3)
            map_ScsLTCGenerators()\sTimecodeStart = RTrim(sParseLTCCommands(8), ",")  
            map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_READY
            map_ScsLTCGenerators()\nType = -1
            
            ; parse the smpte name, eg "smpte24"
            For nLoop = 0 To 3
              If sSmpteNames(nLoop) = sParseLTCCommands(5)
                map_ScsLTCGenerators()\nType = nloop                                  ; index of name
                map_ScsLTCGenerators()\dFramerate = dSmpteValues(nloop)               ; framerate
                map_ScsLTCGenerators()\sType = sParseLTCCommands(5)                   ; the name
              EndIf
            Next
              
            If map_ScsLTCGenerators()\nType = -1                                      ; Somehow a smpte value was not found
              map_ScsLTCGenerators()\nType = 0                                        ; defaults to 30fps
              map_ScsLTCGenerators()\dFramerate = 30                                  ; index of name
              debugMsg(sProcName, "Smpte framerate not found")
            EndIf
                              
            map_ScsLTCGenerators()\sType = sParseLTCCommands(5)
            map_ScsLTCGenerators()\sCue = sParseLTCCommands(9)
            PokeS(@ltcSmpteEncoder\timezone, "+0000", -1, #PB_Ascii)
            PokeA(@ltcSmpteEncoder\hours, Val(StringField(sParseLTCCommands(8), 1, ":")))
            PokeA(@ltcSmpteEncoder\mins, Val(StringField(sParseLTCCommands(8), 2, ":")))
            PokeA(@ltcSmpteEncoder\secs, Val(StringField(sParseLTCCommands(8), 3, ":")))
            PokeA(@ltcSmpteEncoder\frame, Val(StringField(sParseLTCCommands(8), 4, ":")))
            PokeA(@ltcSmpteEncoder\years, Val(FormatDate("%yy", Date())))
            PokeA(@ltcSmpteEncoder\months, Val(FormatDate("%mm", Date())))
            PokeA(@ltcSmpteEncoder\days, Val(FormatDate("%dd", Date())))
          EndIf
        EndIf
        
        map_ScsLTCGenerators()\pLTCXxcoder = ltc_encoder_create(1, 1, 0, #LTC_USE_DATE)   ; encoder handle
        
        If map_ScsLTCGenerators()\pLTCXxcoder = 0              ; Not allocated, abort.
          DeleteMapElement(map_ScsLTCGenerators())
          debugMsg(sProcName, "Failed to allocate ScsLTCDecoder " + sParseLTCCommands(2))
        Else
        	ltc_encoder_set_buffersize(map_ScsLTCGenerators()\pLTCXxcoder, #LTC_SAMPLE_RATE, map_ScsLTCGenerators()\dFramerate);
        	ltc_encoder_reinit(map_ScsLTCGenerators()\pLTCXxcoder, #LTC_SAMPLE_RATE, map_ScsLTCGenerators()\dFramerate, map_ScsLTCGenerators()\nType, #LTC_USE_DATE);
          ltc_encoder_set_filter(map_ScsLTCGenerators()\pLTCXxcoder, 0)
          ltc_encoder_set_filter(map_ScsLTCGenerators()\pLTCXxcoder, 25.0)
          ltc_encoder_set_volume(map_ScsLTCGenerators()\pLTCXxcoder, -3)      ; use -100 to mute, units are dB
        	ltc_encoder_set_timecode(map_ScsLTCGenerators()\pLTCXxcoder, @ltcSmpteEncoder);

        	If map_ScsLTCGenerators()\hBassStream                           ; We already have used this 
        	  nResult = BASS_SetDevice(map_ScsLTCGenerators()\nBassAudioDevice)       ; set this to only stop and free our Bass instance
        	  debugMsg2(sProcName, "BASS_SetDevice(" + map_ScsLTCGenerators()\nBassAudioDevice + ")", nResult)
        	  debugBassError(nResult)
        	  nResult = BASS_Stop()                                                   ; Just in case it is playing.
        	  debugMsg2(sProcName, "BASS_Stop()", nResult)
        	  debugBassError(nResult)
        	  map_ScsLTCGenerators()\hBassStream = 0
        	EndIf
        	
       	  If map_ScsLTCGenerators()\pAudioBuffer
      	    FreeMemory(map_ScsLTCGenerators()\pAudioBuffer)
      	  EndIf
      	  
          For nLoop = 0 To grProd\nMaxAudioLogicalDev
            If grProd\aAudioLogicalDevs(nLoop)\bForLTC
              map_ScsLTCGenerators()\nBassAudioDevice = grProd\aAudioLogicalDevs(nLoop)\nPhysicalDevPtr
              map_ScsLTCGenerators()\nBassAudioDevType = grProd\aAudioLogicalDevs(nLoop)\nDevId
              map_ScsLTCGenerators()\nBassChannelPan = 1                  ; Always Left until we have 3 or more channel devices !
              debugMsg(sProcName, "map_ScsLTCGenerators()\nBassAudioDevice=" + map_ScsLTCGenerators()\nBassAudioDevice)
              nDevMapDevPtr = getDevMapDevPtrDevId(#SCS_DEVGRP_AUDIO_OUTPUT, grProd\aAudioLogicalDevs(nLoop)\nDevId)
              debugMsg(sProcName, "getDevMapDevPtrDevId(#SCS_DEVGRP_AUDIO_OUTPUT, " + grProd\aAudioLogicalDevs(nLoop)\nDevId + ") returned nDevMapDevPtr=" + nDevMapDevPtr)
              
              If nDevMapDevPtr >= 0 And nDevMapDevPtr <= ArraySize(grMaps\aDev())
                nFirst0BasedOutputChan = grMaps\aDev(nDevMapDevPtr)\nFirst0BasedOutputChan
                debugMsg(sProcName, "nFirst0BasedOutputChan=" + nFirst0BasedOutputChan)
              EndIf
              
              nForLTCFound = 1
              map_ScsLTCGenerators()\nloop = nLoop
              Break
            EndIf
          Next
          
          If map_ScsLTCGenerators()\pAudioBuffer = 0                      ; see if the buffer has already been allocate 
            nBassBufferLength = BASS_GetConfig(#BASS_CONFIG_BUFFER)       ; Get buffer length in milliseconds
            debugMsg2(sProcName, "BASS_GetConfig(#BASS_CONFIG_BUFFER)", nBassBufferLength)
            nBassBufferSize = (#LTC_SAMPLE_RATE * nBassBufferLength * 4) / 1000      ; work out the buffer size to match, * 2 for 16 bit mono, 4 for 32bit float
            map_ScsLTCGenerators()\pAudioBuffer = AllocateMemory(nBassBufferSize)
            map_ScsLTCGenerators()\nAudioBufferSize = nBassBufferSize
          EndIf
          
          If nForLTCFound
            Select gaConnectedDev(grProd\aAudioLogicalDevs(nLoop)\nPhysicalDevPtr)\nDriver
              Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI
                debugMsg(sProcName, "LTC Audio device " +  gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\sPhysicalDevDesc + " " + gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\nDevice)
                nResult = BASS_SetDevice(gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\nDevice)
                debugMsg2(sProcName, "BASS_SetDevice(" + gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\nDevice + ")", nResult)
                debugBassError(nResult)
                
                If nResult
                  volumeInDB = -6.0                               ; -6dB
                  nResult = BASS_SetVolume(dBToLinear(volumeInDB))
                  debugMsg2(sProcName, "BASS_SetVolume(" + StrF(dBToLinear(volumeInDB),2) + ")", nResult)
                  debugBassError(nResult)
                  
                  ; Note: For decoding channels (created with BASS_STREAM_DECODE), this function will fail because decoding channels are not meant for playback. i.e do not use BASS_STREAM_DECODE here.
                  ; If you do Bass_chanelplay will fail with error 38
                  map_ScsLTCGenerators()\hBassStream = BASS_StreamCreate(#LTC_SAMPLE_RATE, 1, 0, @StreamCallback(), @map_ScsLTCGenerators()\sLTCName) ; with no #BASS_SAMPLE_XBITS BASS assumes 16 bit working
              	  newHandle(#SCS_HANDLE_LTC, map_ScsLTCGenerators()\hBassStream, #True)
              	  debugMsg2(sProcName, "BASS_StreamCreate(" + #LTC_SAMPLE_RATE + ", 1, 0, @StreamCallback(), @map_ScsLTCGenerators()\sLTCName)", map_ScsLTCGenerators()\hBassStream)
                  
;                   If nResult
;                     debugMsg(sProcName, "Bass volume set")
;                   Else
;                     debugMsg(sProcName, "Failed to set Bass volume")
;                   EndIf
                EndIf
                
              Case #SCS_DRV_BASS_ASIO
                map_ScsLTCGenerators()\nBassASIODevice = gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\nDevice
                debugMsg(sProcName, "LTC Audio device " +  gaConnectedDev(map_ScsLTCGenerators()\nBassAudioDevice)\sPhysicalDevDesc + " = " + map_ScsLTCGenerators()\nBassASIODevice)
                nResult = BASS_ASIO_SetDevice(map_ScsLTCGenerators()\nBassASIODevice)
                debugMsg2(sProcName, "BASS_ASIO_SetDevice(" + map_ScsLTCGenerators()\nBassASIODevice + ")", nResult)
                debugBassAsioError(nResult)
                ;BASS_SetConfig(#BASS_CONFIG_UPDATEPERIOD, 5)

                If nResult
                  nResult = BASS_ASIO_Lock(#True)
                  debugMsg2(sProcName, "BASS_ASIO_Lock(#True)", nResult)
                  debugBassAsioError(nResult)
                  nResult = BASS_ASIO_ChannelSetFormat(#False, 0, #BASS_ASIO_FORMAT_16BIT)
                  debugMsg2(sProcName, asioFormatToReadableString(BASS_ASIO_ChannelGetFormat(#False, 0)), nResult)
                  debugBassAsioError(nResult)
                
                  ; Important note: In order to get AISO to work correctly you need to use the sample rate for Mono NOT stereo.
                  nResult = BASS_ASIO_SetRate(#LTC_SAMPLE_RATE / 2)
                  debugMsg2(sProcName, "BASS_ASIO_SetRate(" + Str(#LTC_SAMPLE_RATE / 2) + ")", nResult)
                  debugBassAsioError(nResult)
                  
                  nResult = BASS_ASIO_channelSetRate(#False, map_ScsLTCGenerators()\nBassASIODevice, #LTC_SAMPLE_RATE / 2)
                  debugMsg2(sProcName, "BASS_ASIO_channelSetRate(#False, " + map_ScsLTCGenerators()\nBassASIODevice + ", " + Str(#LTC_SAMPLE_RATE / 2) + ")", nResult)
                  debugBassAsioError(nResult)
                  
                  debugMsg(sProcName, "Get bassAsioRate: " + StrF(BASS_ASIO_GetRate()))
                  debugMsg(sProcName, "Get bassAsiochannelRate: " + StrF(BASS_ASIO_ChannelGetRate(#False, map_ScsLTCGenerators()\nBassASIODevice)))
                  
                  volumeInDB = -6.0                               ; -6dB
                  nResult = BASS_ASIO_ChannelSetVolume(#False, -1, dBToLinear(volumeInDB))              ; Dee note: -1 is Master i.e. all channels for this device
                  debugMsg2(sProcName, "BASS_ASIO_ChannelSetVolume(#False, -1, " + StrF(dBToLinear(volumeInDB), 2) + ")", nResult)
                  debugBassAsioError(nResult)
                  nResult = BASS_ASIO_Lock(#False)
                  debugMsg2(sProcName, "BASS_ASIO_Lock(#False)", nResult)
                  debugBassAsioError(nResult)
                  
                EndIf
                
              	If map_ScsLTCGenerators()\pAudioBuffer <> 0
              	  ; In the bass_asio_start() documentation.
              	  ; Remarks
                  ; Before starting the device, channels must be enabled using BASS_ASIO_ChannelEnable Or BASS_ASIO_ChannelEnableBASS.
              	  ; Once started, no more channels can be enabled Until the device is stopped using BASS_ASIO_Stop. 
              	  nResult = BASS_ASIO_IsStarted()
              	  debugMsg2(sProcName, "BASS_ASIO_IsStarted()", nResult)
              	  If nResult
              	    nResult = BASS_ASIO_Stop()
              	    debugMsg2(sProcName, "BASS_ASIO_Stop()", nResult)
              	    debugBassAsioError(nResult)
              	  EndIf
              	  
              	  map_ScsLTCGenerators()\hBassStream = BASS_StreamCreate(#LTC_SAMPLE_RATE / 2, 1, #BASS_STREAM_DECODE, @StreamCallback(), @map_ScsLTCGenerators()\sLTCName) ; with no #BASS_SAMPLE_XBITS BASS assumes 16 bit working
              	  newHandle(#SCS_HANDLE_LTC, map_ScsLTCGenerators()\hBassStream, #True)
              	  debugMsg2(sProcName, "BASS_StreamCreate(" + Str(#LTC_SAMPLE_RATE / 2) + ", 1, " + "#BASS_STREAM_DECODE" + ", @StreamCallback(), @map_ScsLTCGenerators()\sLTCName)", map_ScsLTCGenerators()\hBassStream)
              	  debugChannelInfo(map_ScsLTCGenerators()\hBassStream)
              	  
              	  nResult = BASS_ASIO_ChannelEnableBASS(#False, nFirst0BasedOutputChan, map_ScsLTCGenerators()\hBassStream, #False)
              	  debugMsg2(sProcName, "BASS_ASIO_ChannelEnableBASS(#False, " + nFirst0BasedOutputChan + ", " + decodeHandle(map_ScsLTCGenerators()\hBassStream) + ", #False)", nResult)
                  debugBassAsioError(nResult)
              	  map_ScsLTCGenerators()\nLTCbufferIndex = 0                    ; set the audio buffer index to 0
              	  
              	  nResult = BASS_ASIO_IsStarted()
              	  debugMsg2(sProcName, "BASS_ASIO_IsStarted()", nResult)
              	  If nResult = #False
              	    nAsioBufLen = 512
              	    nResult = BASS_ASIO_GetInfo(@rAsioInfo)
              	    debugMsg2(sProcName, "BASS_ASIO_GetInfo(@rAsioInfo)", nResult)
              	    debugBassAsioError(nResult)
              	    If nResult
              	      If nAsioBufLen < rAsioInfo\bufmin Or nAsioBufLen > rAsioInfo\bufmax
              	        debugMsg(sProcName, "rAsioInfo\bufmin=" + rAsioInfo\bufmin + ", \bufmax=" + rAsioInfo\bufmax + ", \bufpref=" + rAsioInfo\bufpref)
              	        nAsioBufLen = rAsioInfo\bufpref
              	      EndIf
              	    EndIf
              	    nResult = BASS_ASIO_Start(nAsioBufLen, 0)
              	    debugMsg2(sProcName, "BASS_ASIO_Start(" + nAsioBufLen + ", 0)", nResult)
              	    debugBassAsioError(nResult)
              	  EndIf
              	Else
              	  debugMsg(sProcName, "BASS_ASIO: \pAudioBuffer memory not allocated")
                EndIf
              
                If map_ScsLTCGenerators()\hBassStream = 0
                  nResult = BASS_ErrorGetCode()
                  sTempString = getBassErrorDesc(nResult, "")
                  debugMsg(sProcName, "Error: Failed to create stream" + sTempString)
                Else
                  debugMsg(sProcName, "Bass stream " + map_ScsLTCGenerators()\sLTCName + " created")
                EndIf
                
            EndSelect
          EndIf
        EndIf

      Case "stop"
        ; stop p1000, Procname: TimeCode@1278.stopTimeCode[Q12<1>]
        LockMutex(mtx_ScsLTCMutex)
        If MapSize(map_ScsLTCGenerators())                                            ; Unable to stop if there is no map
          sTempKeyStore = MapKey(map_ScsLTCGenerators())                              ; We can't use pushmap here because deleting a key and using popmap will result in a nasty crash.
          
          If FindMapElement(map_ScsLTCGenerators(), sParseLTCCommands(2)) <> 0        ; list element does exist
            If map_ScsLTCGenerators()\nStatus <> #SCS_LTC_COMMAND_STOP                ; only stop the first time
              debugMsg(sProcName, "Stopping:" + map_ScsLTCGenerators()\sLTCName)
              map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_STOP
    
              If map_ScsLTCGenerators()\hBassStream
                Select gaConnectedDev(grProd\aAudioLogicalDevs(map_ScsLTCGenerators()\nloop)\nPhysicalDevPtr)\nDriver
                    
                  Case #SCS_DRV_BASS_DS, #SCS_DRV_BASS_WASAPI
                    ; Stop and free the stream after playback
                    nResult = BASS_ChannelStop(map_ScsLTCGenerators()\hBassStream)
                    debugMsg2(sProcName, "BASS_ChannelStop(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) +")", nResult)
                    debugBassError(nResult)
                    
                    Repeat
                      nResult = BASS_ChannelIsActive(map_ScsLTCGenerators()\hBassStream)
                      Delay(10)  ; Check the status every 10 milliseconds
                    Until nResult = #BASS_ACTIVE_STOPPED
     
                    If map_ScsLTCGenerators()\pAudioBuffer
                      FreeMemory(map_ScsLTCGenerators()\pAudioBuffer)
                    EndIf
                    
                    If map_ScsLTCGenerators()\hBassStream
                      nResult = BASS_StreamFree(map_ScsLTCGenerators()\hBassStream)
                      debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) +")", nResult)
                      debugBassError(nResult)
                    EndIf
                    
                    If map_ScsLTCGenerators()\pLTCXxcoder
                      ltc_encoder_free(map_ScsLTCGenerators()\pLTCXxcoder)
                    EndIf
                    
                    DeleteMapElement(map_ScsLTCGenerators())
                    FindMapElement(map_ScsLTCGenerators(), sTempKeyStore)                       ; attempt to restore the last key but i may no longer exist
            
                  Case #SCS_DRV_BASS_ASIO
                    ; Stop and free the stream after playback
                    nResult = BASS_ChannelStop(map_ScsLTCGenerators()\hBassStream)
                    debugMsg2(sProcName, "BASS_ChannelStop(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) +")", nResult)
                    debugBassError(nResult)
                    
                    Repeat
                      nResult = BASS_ChannelIsActive(map_ScsLTCGenerators()\hBassStream)
                      Delay(10)  ; Check the status every 10 milliseconds
                    Until nResult = #BASS_ACTIVE_STOPPED
   
                    If map_ScsLTCGenerators()\hBassStream
                      nResult = BASS_StreamFree(map_ScsLTCGenerators()\hBassStream)
                      debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) +")", nResult)
                      debugBassError(nResult)
                    EndIf
                    
                    If map_ScsLTCGenerators()\pAudioBuffer
                      FreeMemory(map_ScsLTCGenerators()\pAudioBuffer)
                    EndIf
                    
                    If map_ScsLTCGenerators()\pLTCXxcoder
                      ltc_encoder_free(map_ScsLTCGenerators()\pLTCXxcoder)
                    EndIf
                    
                    DeleteMapElement(map_ScsLTCGenerators())
                    FindMapElement(map_ScsLTCGenerators(), sTempKeyStore)                       ; attempt to restore the last key but i may no longer exist
                EndSelect
              EndIf
            EndIf
          EndIf
          UnlockMutex(mtx_ScsLTCMutex)
        EndIf
        
      Case "play", "resume"
        ; play p1001, Procname: mmedia@9609.playSubTypeU[Q12<2>]
        LockMutex(mtx_ScsLTCMutex)
        
        If FindMapElement(map_ScsLTCGenerators(), sParseLTCCommands(2)) <> 0        ; list element does exist
          If map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_READY Or map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_PAUSE
            map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_PLAY
          	ltc_encoder_set_buffersize(map_ScsLTCGenerators()\pLTCXxcoder, #LTC_SAMPLE_RATE, map_ScsLTCGenerators()\dFramerate);
          	ltc_encoder_reinit(map_ScsLTCGenerators()\pLTCXxcoder, #LTC_SAMPLE_RATE, map_ScsLTCGenerators()\dFramerate, map_ScsLTCGenerators()\nType, #LTC_USE_DATE);
            ltc_encoder_set_filter(map_ScsLTCGenerators()\pLTCXxcoder, 0)
            ltc_encoder_set_filter(map_ScsLTCGenerators()\pLTCXxcoder, 25.0)
            ltc_encoder_set_volume(map_ScsLTCGenerators()\pLTCXxcoder, -3)      ; use -100 to mute, units are dB
          	ltc_encoder_set_timecode(map_ScsLTCGenerators()\pLTCXxcoder, @ltcSmpteEncoder);
          	
          	; Play the stream
          	debugChannelInfo(map_ScsLTCGenerators()\hBassStream)
          	nResult = BASS_ChannelPlay(map_ScsLTCGenerators()\hBassStream, #False)           ; if successful this then calls streamcallback() to handle the buffers
          	; bassErrorDebug(#BASSERRORTYPE)
          	debugMsg2(sProcName, "BASS_ChannelPlay(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) + ", #False)", nResult)
          	If nResult = 0
          	  debugMsg(sProcName, "Error: Failed To play stream: " + getBassErrorDesc(BASS_ErrorGetCode()))
          	  debugChannelInfo(map_ScsLTCGenerators()\hBassStream)
          	EndIf
          EndIf
        EndIf
        
        UnlockMutex(mtx_ScsLTCMutex)

      Case "pause"
        ; pause p1000, Procname: TimeCode@1197.pauseTimeCode[Q11]
        LockMutex(mtx_ScsLTCMutex)
       
        If FindMapElement(map_ScsLTCGenerators(), sParseLTCCommands(2)) <> 0        ; list element does exist
          If map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_PLAY                 ; ignore pause if already paused
            map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_PAUSE
            nResult = BASS_ChannelPause(map_ScsLTCGenerators()\hBassStream)
            debugMsg2(sProcName, "BASS_ChannelPause(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) + ")", nResult)
            debugBassError(nResult)
            ltc_encoder_get_timecode(map_ScsLTCGenerators()\pLTCXxcoder, @ltcSmpteEncoder)    ; Save the current timecode
          EndIf
        EndIf
        
        UnlockMutex(mtx_ScsLTCMutex)
        
      Default
        ; nope, we do not recognise the command.
        
    EndSelect
                    
    ; check for playing cues and send the TC to the display
    qElapsedTime = ElapsedMilliseconds()
    LockMutex(mtx_ScsLTCMutex)
    
    If MapSize(map_ScsLTCGenerators())                                                    ; check there is a map
      PushMapPosition(map_ScsLTCGenerators())
      ForEach map_ScsLTCGenerators()
        If map_ScsLTCGenerators()\nStatus = #SCS_LTC_COMMAND_PLAY And qElapsedTime > map_ScsLTCGenerators()\qTimeSaved + #SCS_LTC_DISPLAYUPDATE_TIMER
          postEventString = map_ScsLTCGenerators()\sCue
          map_ScsLTCGenerators()\qTimeSaved = qElapsedTime
        EndIf
        
        If postEventString <> ""
          PostEvent(#SCS_Event_DrawLTC, #WMN, 0, 0, Val(postEventString))           ; send the cue number to trigger drawLTCSend() which request the current SMPTE values
          postEventString = ""
        EndIf

      Next
      PopMapPosition(map_ScsLTCGenerators())
    EndIf
    
    UnlockMutex(mtx_ScsLTCMutex)
    
    Delay(10)                                                                              ; if nothing to process go easy on system resources.
  Wend
  
  debugMsg(sProcName, "LTC thread closing due to sub_state = " + gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState)
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_STOPPING
  LockMutex(mtx_ScsLTCMutex)

  ForEach map_ScsLTCGenerators()
    ; Stop and free the stream after playback
    nResult = BASS_ChannelStop(map_ScsLTCGenerators()\hBassStream)
    debugMsg2(sProcName, "BASS_ChannelStop(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) + ")", nResult)
    debugBassError(nResult)
    
    Repeat
      nResult = BASS_ChannelIsActive(map_ScsLTCGenerators()\hBassStream)
      Delay(10)  ; Check the status every 10 milliseconds
    Until nResult = #BASS_ACTIVE_STOPPED

    If map_ScsLTCGenerators()\pAudioBuffer
      FreeMemory(map_ScsLTCGenerators()\pAudioBuffer)
    EndIf
    
    If map_ScsLTCGenerators()\hBassStream
      nResult = BASS_StreamFree(map_ScsLTCGenerators()\hBassStream)
      debugMsg2(sProcName, "BASS_StreamFree(" + decodeHandle(map_ScsLTCGenerators()\hBassStream) + ")", nResult)
    EndIf
    
    If map_ScsLTCGenerators()\pLTCXxcoder
      ltc_encoder_free(map_ScsLTCGenerators()\pLTCXxcoder)
    EndIf
    
    DeleteMapElement(map_ScsLTCGenerators())
  Next
  
  UnlockMutex(mtx_ScsLTCMutex)
  FreeMap(map_ScsLTCGenerators())
  nResult = 3
  
  If LTCDecode
    CloseLibrary(LTCDecode)
  EndIf
  
  debugMsg(sProcName, "SCS LTC closed")
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_INACTIVE
  gaThread(#SCS_THREAD_SCS_LTC)\nThreadState = #SCS_THREAD_STATE_STOPPED
  gaThread(#SCS_THREAD_SCS_LTC)\bThreadCreated = #False
  
  ProcedureReturn nResult
EndProcedure

Procedure sendLTCCommand(sCommandToSend.s)
  PROCNAMEC()
  
  If gaThread(#SCS_THREAD_SCS_LTC)\nThreadState = #SCS_THREAD_STATE_ACTIVE And gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_ACTIVE
    LockMutex(mtx_ScsLTCMutexCmdList)
    PushListPosition(list_ScsLTCQueue())                              ; Save the current list position
    LastElement(list_ScsLTCQueue())                                   ; move to last element
    AddElement(list_ScsLTCQueue())                                    ; add an element after
    list_ScsLTCQueue()\sScsLTCCommands = sCommandToSend               ; Save the new commend in here
    PopListPosition(list_ScsLTCQueue())                               ; Restore the previous list position
    UnlockMutex(mtx_ScsLTCMutexCmdList)    
    debugMsg(sProcName, "LTC command received: " + sCommandToSend)
    ; Debug "LTC command received: " + sCommandToSend
  EndIf
EndProcedure  

; Returns a copy of the requested map as it will chenge the map pointer which would not be good.
; If sucess then return the name of the LTC time or "" if it failed.
Procedure.s getLTCCurrentProgress(sLTCName.s)
  PROCNAMEC()
  Protected NewMap map_ScsLTCGenCopy.scsLTCTDevice_t()
  
  If gaThread(#SCS_THREAD_SCS_LTC)\nThreadState = #SCS_THREAD_STATE_ACTIVE And gaThread(#SCS_THREAD_SCS_LTC)\nThreadSubState = #SCS_THREAD_SUB_STATE_ACTIVE
    LockMutex(mtx_ScsLTCMutex)
    
    If MapSize(map_ScsLTCGenerators())
      CopyMap(map_ScsLTCGenerators(), map_ScsLTCGenCopy())
      UnlockMutex(mtx_ScsLTCMutex)                                    ; unlock mutex as we are working on a copy now
      FindMapElement(map_ScsLTCGenCopy(), sLTCName)
      ltc_encoder_get_timecode(map_ScsLTCGenCopy()\pLTCXxcoder, @gLTCSmpteEncoder)        ; Save the current timecode in gLTCSmpteEncoder, return as a pointer
      ProcedureReturn sLTCName
    EndIf
    
    UnlockMutex(mtx_ScsLTCMutex)
  EndIf
  
  ProcedureReturn ""
EndProcedure

Procedure.f dBToLinear(dB.f)
  ProcedureReturn Pow(10, dB / 20)
EndProcedure

