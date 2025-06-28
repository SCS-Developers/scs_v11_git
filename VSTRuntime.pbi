; File: VSTRuntime.pbi
; VST runtime processing, and procedures for #WPL (the plugin editor window)

EnableExplicit

Procedure WPL_EventHandler()
  PROCNAMEC()

  Select gnWindowEvent
    Case #PB_Event_CloseWindow
      debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(grWPL\nVSTHandleForPluginShowing) + ", #False)")
      WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, grWPL\nVSTHandleForPluginShowing, #False)
      ; nb #SCS_VST_HOST_NONE in the above call will hide the plugin editor window #WPL
  EndSelect

EndProcedure

Procedure WPL_hideWindowIfDisplayed(nHideIfHostType=#SCS_VST_HOST_ANY)
  PROCNAMEC()
  
  If IsWindow(#WPL)
    With grWPL
      If \bPluginShowing
        If (\nVSTHost = nHideIfHostType) Or (nHideIfHostType = #SCS_VST_HOST_ANY)
          debugMsg(sProcName, "calling WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, " + decodeHandle(\nVSTHandleForPluginShowing) + ", #False)")
          WPL_showVSTEditor(#SCS_VST_HOST_NONE, -1, \nVSTHandleForPluginShowing, #False)
          ; nb #SCS_VST_HOST_NONE in the above call will hide the plugin editor window #WPL
        EndIf
      EndIf
    EndWith
  EndIf
  
EndProcedure

Procedure WPL_showVSTEditor(nVSTHost, nHostPtr, nVSTHandle.l, bShowEditor)
  PROCNAMEC()
  Protected nBassResult.l
  Protected rVSTInfo.BASS_VST_INFO, rVSTParamInfo.BASS_VST_PARAM_INFO
  Protected sVSTHandle.s, nLineIndex
  Protected bPrevPluginShowing, nPrevVSTHost, nPrevVSTHandle.l, sPrevVSTHandle.s, nPrevHostPtr
  Protected bCloseExistingEditor, bSetWVPCheckboxesAtEndOfProcedure
  Protected sWindowTitle.s, sOrigin.s, sPluginName.s
  Protected bLogData = #False
  
  debugMsg(sProcName, #SCS_START + ", nVSTHost=" + nVSTHost + ", nHostPtr=" + nHostPtr + ", nVSTHandle=" + decodeHandle(nVSTHandle) + ", bShowEditor=" + strB(bShowEditor))
  
  With grWPL
    ; set 'previous' items
    bPrevPluginShowing = \bPluginShowing
    nPrevVSTHost = \nVSTHost
    nPrevVSTHandle = \nVSTHandleForPluginShowing
    If nPrevVSTHandle
      sPrevVSTHandle = decodeHandle(nPrevVSTHandle)
    EndIf
    Select nPrevVSTHost
      Case #SCS_VST_HOST_DEV
        nPrevHostPtr = \nHostPluginIndex
      Case #SCS_VST_HOST_AUD
        nPrevHostPtr = \nHostAudPtr
    EndSelect
    
    ; determine if existing VST editor needs to be closed
    If bPrevPluginShowing
      If (nVSTHost = #SCS_VST_HOST_NONE) Or (nVSTHost <> nPrevVSTHost) Or (nHostPtr <> nPrevHostPtr) Or (nVSTHandle <> nPrevVSTHandle)
        debugMsg(sProcName, "nVSTHost=" + nVSTHost + ", nPrevVSTHost=" + nPrevVSTHost + ", nHostPtr=" + nHostPtr + ", nPrevHostPtr=" + nPrevHostPtr + ", nVSTHandle=" + nVSTHandle + ", nPrevVSTHandle=" + nPrevVSTHandle)
        bCloseExistingEditor = #True
      EndIf
    EndIf
    
    ; close existing editor if required
    If bCloseExistingEditor
      If nPrevVSTHandle
        nBassResult = BASS_VST_EmbedEditor(nPrevVSTHandle, #Null)
        debugMsg2(sProcName, "BASS_VST_EmbedEditor(" + sPrevVSTHandle + ", #Null)", nBassResult)
        BASS_VST_SetCallback(nPrevVSTHandle, @WPL_VSTEditorCallBack(), #SCS_VST_HOST_NONE)
        debugMsg(sProcName, "BASS_VST_SetCallback(" + sPrevVSTHandle + ", @WPL_VSTEditorCallBack(), #SCS_VST_HOST_NONE)")
      EndIf
      If IsWindow(#WPL)
        setWindowVisible(#WPL, #False)
      EndIf
      Select nPrevVSTHost
        Case #SCS_VST_HOST_DEV
          If IsWindow(#WVP)
            bSetWVPCheckboxesAtEndOfProcedure = #True
          EndIf
        Case #SCS_VST_HOST_AUD
          If IsGadget(WQF\chkViewVST)
            ; debugMsg0(sProcName, "setOwnState(WQF\chkViewVST, #PB_Checkbox_Unchecked)")
            setOwnState(WQF\chkViewVST, #PB_Checkbox_Unchecked)
          EndIf
      EndSelect
    EndIf
    
    If nVSTHandle <> 0
      sVSTHandle = decodeHandle(nVSTHandle)
      ; Get Window Info for Plugin
      nBassResult = BASS_VST_GetInfo(nVSTHandle, @rVSTInfo)
      debugMsg2(sProcName, "BASS_VST_GetInfo(" + sVSTHandle + ", @rVSTInfo)", nBassResult)
      debugMsg(sProcName, "rVSTInfo\hasEditor=" + strB(rVSTInfo\hasEditor) + ", grWPL\bPluginShowing=" + strB(grWPL\bPluginShowing))
      If (bShowEditor) And (rVSTInfo\hasEditor)
        ; Show the Editor
        If IsWindow(#WPL) = #False
          If OpenWindow(#WPL, 10, 20, rVSTInfo.BASS_VST_INFO\editorWidth, rVSTInfo.BASS_VST_INFO\editorHeight, "", #PB_Window_SystemMenu) ; window title set (or changed) further down this procedure
            setFormPosition(#WPL, @grVSTWindow, -1, #True)
            StickyWindow(#WPL, #True)
          EndIf
        Else
          If WindowWidth(#WPL) <> rVSTInfo.BASS_VST_INFO\editorWidth Or WindowHeight(#WPL) <> rVSTInfo.BASS_VST_INFO\editorHeight
            debugMsg(sProcName, "calling ResizeWindow(#WPL, #PB_Ignore, #PB_Ignore, " + rVSTInfo.BASS_VST_INFO\editorWidth + ", " + rVSTInfo.BASS_VST_INFO\editorHeight + ")")
            ResizeWindow(#WPL, #PB_Ignore, #PB_Ignore, rVSTInfo.BASS_VST_INFO\editorWidth, rVSTInfo.BASS_VST_INFO\editorHeight)
          EndIf
        EndIf
        If IsWindow(#WPL)
          Select nVSTHost
            Case #SCS_VST_HOST_DEV
              sOrigin = grVST\aDevVSTPlugin(nHostPtr)\sDevVSTLogicalDev + "/" + grVST\aDevVSTPlugin(nHostPtr)\nDevVSTOrder
              sPluginName = grVST\aDevVSTPlugin(nHostPtr)\sDevVSTPluginName
            Case #SCS_VST_HOST_AUD
              sOrigin = getAudLabel(nHostPtr)
              sPluginName = aAud(nHostPtr)\sVSTPluginName
          EndSelect
          debugMsg(sProcName, "sOrigin=" + sOrigin + ", sPluginName=" + sPluginName)
          sWindowTitle = LangPars("VST", "vstViewer", sOrigin, sPluginName)
          SetWindowTitle(#WPL, sWindowTitle)
          \bPluginShowing = #True
          \nVSTHandleForPluginShowing = nVSTHandle
          \nVSTHost = nVSTHost
          Select nVSTHost
            Case #SCS_VST_HOST_DEV
              \nHostPluginIndex = nHostPtr
            Case #SCS_VST_HOST_AUD
              \nHostAudPtr = nHostPtr
          EndSelect
          nBassResult = BASS_VST_EmbedEditor(nVSTHandle, WindowID(#WPL))
          debugMsg2(sProcName, "BASS_VST_EmbedEditor(" + sVSTHandle + ", WindowID(#WPL))", nBassResult)
          CompilerIf #c_minimal_vst = #False
            BASS_VST_SetCallback(nVSTHandle, @WPL_VSTEditorCallBack(), nVSTHost)
            debugMsg(sProcName, "BASS_VST_SetCallback(" + sVSTHandle + ", @WPL_VSTEditorCallBack(), " + nVSTHandle + ")")
          CompilerEndIf
          setWindowVisible(#WPL, #True)
          ; Added 15Feb2025 11.10.7
          ; debugMsg0(sProcName, "setOwnState(WQF\chkViewVST, #PB_Checkbox_Checked)")
          setOwnState(WQF\chkViewVST, #PB_Checkbox_Checked)
          ; End added 15Feb2025 11.10.7
        EndIf
        Select \nVSTHost ; nb must be \nVSTHost, not nVSTHost as we need the \nVSTHost of the VST Editor just closed
          Case #SCS_VST_HOST_DEV
            WVP_setViewCheckboxes()
        EndSelect
        If bLogData
          debugMsg(sProcName, "calling VST_logVSTData(" + sVSTHandle + ")")
          VST_logVSTData(nVSTHandle)
        EndIf
      ElseIf bPrevPluginShowing
        \bPluginShowing = #False
        \nVSTHandleForPluginShowing = 0
        \nVSTHost = #SCS_VST_HOST_NONE
      EndIf
    EndIf ; EndIf nVSTHandle <> 0
    
    If bSetWVPCheckboxesAtEndOfProcedure
      WVP_setViewCheckboxes()
    EndIf
    
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure WPL_VSTEditorCallBack(vstHandle.l, action.l, param1.l, param2.l, *user)
  PROCNAMEC()
  
  ; Debug sProcName + ": vstHandle=" + decodeHandle(vstHandle) + ", action=" + action + ", param1=" + param1 + ", param2=" + param2
  
  If action = #BASS_VST_PARAM_CHANGED
    ; debugMsg(sProcName, "vstHandle=" + decodeHandle(vstHandle) + ", action=#BASS_VST_PARAM_CHANGED, param1=" + param1 + ", param2=" + param2 + ", *user=" + *user)
    Select *user
      Case #SCS_VST_HOST_DEV
        ; debugMsg(sProcName, "PostEvent(#SCS_Event_VSTGetData, #WVP, 0, 0, " + decodeHandle(vstHandle) + ")")
        PostEvent(#SCS_Event_VSTGetData, #WVP, 0, 0, vstHandle)
      Case #SCS_VST_HOST_AUD
        ; debugMsg(sProcName, "PostEvent(#SCS_Event_VSTGetData, #WED, 0, 0, " + decodeHandle(vstHandle) + ")")
        PostEvent(#SCS_Event_VSTGetData, #WED, 0, 0, vstHandle)
      Default
        debugMsg(sProcName, "*user not recognised: " + *user)
    EndSelect
  EndIf
  ProcedureReturn 0
  
EndProcedure

Procedure.s VST_getPluginFileLocation(sPluginName.s, nProcessor)
  PROCNAMEC()
  Protected n, sResult.s, sCompareStr.s
  
  debugMsg(sProcName, #SCS_START + ", sPluginName=" + #DQUOTE$ + sPluginName + #DQUOTE$)
  
  debugMsg(sProcName, "grVST\nMaxLibVSTPlugin=" + grVST\nMaxLibVSTPlugin)
  For n = 0 To grVST\nMaxLibVSTPlugin
    debugMsg(sProcName, "n=" + n)
    sCompareStr = grVST\aLibVSTPlugin(n)\sLibVSTPluginName
    If sCompareStr = sPluginName
      If nProcessor = #PB_Processor_x64
        sResult = grVST\aLibVSTPlugin(n)\sLibVSTPluginFile64
      ElseIf nProcessor = #PB_Processor_x86
        sResult = grVST\aLibVSTPlugin(n)\sLibVSTPluginFile32
      EndIf
      Break
    EndIf
  Next n
  
  debugMsg(sProcName, #SCS_END + ", returning " + #DQUOTE$ + sResult + #DQUOTE$)
  ProcedureReturn sResult
  
EndProcedure

Procedure VST_getLibPluginIndex(sPluginName.s)
  PROCNAMEC()
  Protected nIndex, n
  
  nIndex = -1
  If sPluginName
    For n = 0 To grVST\nMaxLibVSTPlugin
      If grVST\aLibVSTPlugin(n)\sLibVSTPluginName= sPluginName
        nIndex = n
        Break
      EndIf
    Next n
  EndIf
  ProcedureReturn nIndex
EndProcedure

Procedure VST_getDevPluginIndexForDevItem(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  Protected nPluginIndex, n
  
  ; debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder)
  
;   For n = 0 To grVST\nMaxDevVSTPlugin
;     With grVST\aDevVSTPlugin(n)
;       debugMsg(sProcName, "grVST\aDevVSTPlugin(" + n + ")\sDevVSTLogicalDev=" + \sDevVSTLogicalDev + ", \nDevVSTOrder=" + \nDevVSTOrder + ", \sDevVSTPluginName=" + \sDevVSTPluginName)
;     EndWith
;   Next n
  
  With grVST
    nPluginIndex = -1
    For n = 0 To \nMaxDevVSTPlugin
      If (\aDevVSTPlugin(n)\sDevVSTLogicalDev = sLogicalDev) And (\aDevVSTPlugin(n)\nDevVSTOrder = nVSTOrder)
        nPluginIndex = n
        Break
      EndIf
    Next n
    ; debugMsg(sProcName, "nPluginIndex=" + nPluginIndex)
    If nPluginIndex < 0
      ; entry not found, so create a new entry in the array
      \nMaxDevVSTPlugin + 1
      debugMsg(sProcName, "grVST\nMaxDevVSTPlugin=" + \nMaxDevVSTPlugin)
      nPluginIndex = \nMaxDevVSTPlugin
      If nPluginIndex > ArraySize(\aDevVSTPlugin())
        ReDim \aDevVSTPlugin(nPluginIndex)
      EndIf
      \aDevVSTPlugin(nPluginIndex) = grDevVSTPluginDef
      \aDevVSTPlugin(nPluginIndex)\sDevVSTLogicalDev = sLogicalDev
      \aDevVSTPlugin(nPluginIndex)\nDevVSTOrder = nVSTOrder
    EndIf
  EndWith
  
  ; debugMsg(sProcName, #SCS_END + ", sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder + ", returning nPluginIndex=" + nPluginIndex)
  ProcedureReturn nPluginIndex
  
EndProcedure

Procedure VST_showWarning(ErrorNo, sPluginName.s, sCue.s="", sVSTFilePath.s="")
  PROCNAMEC()
  Protected sErrorMsg.s
  
  Select #PB_Compiler_Processor
    Case #PB_Processor_x64
      sErrorMsg = "64-bit "
    Case #PB_Processor_x86
      sErrorMsg = "32-bit "
  EndSelect
  
  Select ErrorNo
    Case #SCS_VST_PLUGIN_ERROR_FILE_LOCATION
      ; File Location not found
      sErrorMsg.s + Lang("VST", "Failure01") + " for [" + sPluginName + "]"
      If sCue
        sErrorMsg = sErrorMsg + " in Cue " + sCue
      EndIf
      debugMsg(sProcName, sErrorMsg)
      MessageRequester(Lang("VST", "lblVSTPlugin"), sErrorMsg, #PB_MessageRequester_Warning)
      
    Case #SCS_VST_PLUGIN_ERROR_PLUGIN_NOT_LOADED
      ; Unsuccessful attempt to load plugin
      sErrorMsg.s + Lang("VST", "Failure02") + " for [" + sPluginName + "]"
      If sCue <> ""
        sErrorMsg = sErrorMsg + " in Cue " + sCue
      EndIf
      debugMsg(sProcName, sErrorMsg)
      MessageRequester(Lang("VST", "lblVSTPlugin"), sErrorMsg, #PB_MessageRequester_Warning)
      
    Case #SCS_VST_PLUGIN_ERROR_INCORRECT_PROCESSOR_VERSION
      ; Incorrect Processor Version for Plugin
      sErrorMsg.s + Lang("VST", "Failure03") + " for [" + sPluginName + "]"
      debugMsg(sProcName, sErrorMsg)
      MessageRequester(Lang("VST", "lblVSTPlugin"), sErrorMsg, #PB_MessageRequester_Warning)
      
    Case #SCS_VST_PLUGIN_ERROR_ALREADY_EXISTS
      ; Plugin being loaded already exists
      sErrorMsg.s = Lang("VST", "Failure04") + " for [" + sPluginName + "]" ; nb 32/64 bit info not relevant for this message
      debugMsg(sProcName, sErrorMsg)
      MessageRequester(Lang("VST", "lblVSTPlugin"), sErrorMsg, #PB_MessageRequester_Warning)
      
    Case #SCS_VST_PLUGIN_ERROR_INSTRUMENT
      sErrorMsg = LangPars("VST", "Instrument", #DQUOTE$ + sVSTFilePath + #DQUOTE$)
      debugMsg(sProcName, sErrorMsg)
      MessageRequester(Lang("VST", "lblVSTPlugin"), sErrorMsg, #PB_MessageRequester_Warning)
      
    Default ;#SCS_VST_PLUGIN_ERROR_OK
      ; No need to display anything as Plugin Loaded successfully
      
  EndSelect
  
EndProcedure

Procedure WPL_getVSTData(nVSTHandle.l)
  PROCNAMEC()
  
  With grWPL
    If nVSTHandle <> \nVSTHandleForPluginShowing
      ; shouldn't get here
      debugMsg(sProcName, "exiting - nVSTHandle=" + decodeHandle(nVSTHandle) + " but expecting " + decodeHandle(\nVSTHandleForPluginShowing))
      ProcedureReturn
    EndIf
    
    Select \nVSTHost
      Case #SCS_VST_HOST_DEV
        ; debugMsg(sProcName, "calling WPL_getDevVSTData(" + \nHostPluginIndex + ", " + decodeHandle(nVSTHandle) + ")")
        WPL_getDevVSTData(\nHostPluginIndex, nVSTHandle)
        WVP_checkForChanges()
      Case #SCS_VST_HOST_AUD
        ; debugMsg(sProcName, "calling WPL_getAudVSTData(" + \nHostPluginIndex + ", " + decodeHandle(nVSTHandle) + ")")
        WPL_getAudVSTData(\nHostAudPtr, nVSTHandle)
      Default
        debugMsg(sProcName, "unknown \nVSTHost=" + \nVSTHost)
    EndSelect
    
  EndWith
  
EndProcedure

Procedure WPL_getDevVSTData(nPluginIndex, nVSTHandle.l)
  PROCNAMEC()
  Protected sVSTHandle.s
  Protected nProgramCount.l, nParamCount.l, nParamIndex.l
  Protected nReqdArraySize, nArrayIndex
  Protected fParam.f
  Protected nBassResult.l
  Protected rVSTParamInfo.BASS_VST_PARAM_INFO
  Protected bTrace = #False
  Protected nChunkPtr, nChunkLength.l, nByteOffset.l
  
  debugMsgC(sProcName, #SCS_START + ", nPluginIndex=" + nPluginIndex + ", nVSTHandle=" + decodeHandle(nVSTHandle))
  
  ; nb only get chunk data if there are no programs
  With grVST\aDevVSTPlugin(nPluginIndex)
    sVSTHandle = decodeHandle(nVSTHandle)
    ; program
    \rDevVSTChunk = grDevVSTPluginDef\rDevVSTChunk
    nProgramCount = BASS_VST_GetProgramCount(nVSTHandle)
    If nProgramCount > 0
      \nDevVSTProgram = BASS_VST_GetProgram(nVSTHandle)
      debugMsgC2(sProcName, "BASS_VST_GetProgram(" + sVSTHandle + ")", \nDevVSTProgram)
    Else
      \nDevVSTProgram = grDevVSTPluginDef\nDevVSTProgram
    EndIf
    ; parameters
    nArrayIndex = -1
    nParamCount = BASS_VST_GetParamCount(nVSTHandle)
    debugMsgC2(sProcName, "BASS_VST_GetParamCount(" + sVSTHandle + ")", nParamCount)
    If nParamCount > 0
      nReqdArraySize = nParamCount - 1
      If nReqdArraySize > ArraySize(\aDevVSTParam())
        ReDim \aDevVSTParam(nReqdArraySize)
      EndIf
      For nParamIndex = 0 To nReqdArraySize
        fParam = BASS_VST_GetParam(nVSTHandle, nParamIndex)
        debugMsgC(sProcName, "BASS_VST_GetParam(" + sVSTHandle + ", " + nParamIndex + ") returned " + StrF(fParam))
        nBassResult = BASS_VST_GetParamInfo(nVSTHandle, nParamIndex, @rVSTParamInfo)
        ; debugMsgC2(sProcName, "BASS_VST_GetParamInfo(" + sVSTHandle + ", " + nParamIndex + ", @rVSTParamInfo)", nBassResult)
        If fParam <> rVSTParamInfo\defaultValue
          nArrayIndex + 1
          \aDevVSTParam(nArrayIndex)\nVSTParamIndex = nParamIndex
          \aDevVSTParam(nArrayIndex)\fVSTParamValue = fParam
          \aDevVSTParam(nArrayIndex)\fVSTParamDefaultValue = rVSTParamInfo\defaultValue
          debugMsgC(sProcName, "grVST\aDevVSTPlugin(" + nPluginIndex + ")\aDevVSTParam(" + nArrayIndex + ")\nVSTParamIndex=" + \aDevVSTParam(nArrayIndex)\nVSTParamIndex +
                               ", \fVSTParamDefaultValue=" + StrF(\aDevVSTParam(nArrayIndex)\fVSTParamDefaultValue) +
                               ", \fVSTParamValue=" + StrF(\aDevVSTParam(nArrayIndex)\fVSTParamValue))
        EndIf
      Next nParamIndex
      \nDevVSTMaxParam = nArrayIndex
    EndIf       
    ; chunk (if required)
    If (nProgramCount = 0) Or (\sDevVSTPluginName = "Metaplugin")
      nChunkPtr = BASS_VST_GetChunk(nVSTHandle, 0, @nChunkLength)
      debugMsgC(sProcName, "BASS_VST_GetChunk(" + sVSTHandle + ", 0, @nChunkLength) returned " + nChunkPtr + ", nChunkLength=" + nChunkLength)
      If nChunkPtr > 0
        \rDevVSTChunk\sChunkMagic = PeekS(nChunkPtr, 4, #PB_Ascii)
        Select \rDevVSTChunk\sChunkMagic
          Case "VC2!"
            debugMsgC(sProcName, ".. chunkMagic=" + \rDevVSTChunk\sChunkMagic)
            \rDevVSTChunk\nByteSize = PeekL(nChunkPtr+4)
            debugMsgC(sProcName, ".. byteSize=" + \rDevVSTChunk\nByteSize)
            nByteOffset = 8
            If \rDevVSTChunk\nByteSize > 0
              \rDevVSTChunk\sChunkData = PeekS(nChunkPtr+nByteOffset, \rDevVSTChunk\nByteSize, #PB_Ascii)
              debugMsgC(sProcName, \rDevVSTChunk\sChunkData)
            EndIf
          Case "<?xm"
            debugMsgC(sProcName, ".. chunkMagic=" + \rDevVSTChunk\sChunkMagic)
            \rDevVSTChunk\nByteSize = nChunkLength
            debugMsgC(sProcName, ".. byteSize=" + \rDevVSTChunk\nByteSize)
            \rDevVSTChunk\sChunkData = PeekS(nChunkPtr, nChunkLength, #PB_Ascii)
            debugMsgC(sProcName, \rDevVSTChunk\sChunkData)
        EndSelect
      EndIf
    EndIf
    
    ; end
    If bTrace
      VST_logVSTData(nVSTHandle)
    EndIf
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure WPL_getAudVSTData(pAudPtr, nVSTHandle.l)
  PROCNAMECA(pAudPtr)
  Protected sVSTHandle.s
  Protected nProgramCount.l, nParamCount.l, nParamIndex.l
  Protected nReqdArraySize, nArrayIndex
  Protected fParam.f
  Protected nBassResult.l
  Protected rVSTParamInfo.BASS_VST_PARAM_INFO
  Protected u
  Protected bTrace = #False
  Protected nChunkPtr, nChunkLength.l, nByteOffset.l
  
  debugMsgC(sProcName, #SCS_START)
  
  ; nb only get chunk data if there are no programs
  With aAud(pAudPtr)
    u = preChangeAudL(#True, Lang("VST", "ParameterChanges"), pAudPtr)
    sVSTHandle = decodeHandle(nVSTHandle)
    ; program
    \rVSTChunk = grAudDef\rVSTChunk
    nProgramCount = BASS_VST_GetProgramCount(nVSTHandle)
    If nProgramCount > 0
      \nVSTProgram = BASS_VST_GetProgram(nVSTHandle)
      debugMsgC2(sProcName, "BASS_VST_GetProgram(" + sVSTHandle + ")", \nVSTProgram)
    Else
      \nVSTProgram = grAudDef\nVSTProgram
    EndIf
    ; parameters
    nArrayIndex = -1
    nParamCount = BASS_VST_GetParamCount(nVSTHandle)
    debugMsgC2(sProcName, "BASS_VST_GetParamCount(" + sVSTHandle + ")", nParamCount)
    If nParamCount > 0
      nReqdArraySize = nParamCount - 1
      If nReqdArraySize > ArraySize(\aVSTParam())
        ReDim \aVSTParam(nReqdArraySize)
      EndIf
      For nParamIndex = 0 To nReqdArraySize
        fParam = BASS_VST_GetParam(nVSTHandle, nParamIndex)
        debugMsgC(sProcName, "BASS_VST_GetParam(" + sVSTHandle + ", " + nParamIndex + ") returned " + StrF(fParam))
        nBassResult = BASS_VST_GetParamInfo(nVSTHandle, nParamIndex, @rVSTParamInfo)
        ; debugMsgC2(sProcName, "BASS_VST_GetParamInfo(" + sVSTHandle + ", " + nParamIndex + ", @rVSTParamInfo)", nBassResult)
        If fParam <> rVSTParamInfo\defaultValue
          nArrayIndex + 1
          \aVSTParam(nArrayIndex)\nVSTParamIndex = nParamIndex
          \aVSTParam(nArrayIndex)\fVSTParamValue = fParam
          \aVSTParam(nArrayIndex)\fVSTParamDefaultValue = rVSTParamInfo\defaultValue
          debugMsgC(sProcName, "aAud(" + getAudLabel(pAudPtr) + ")\aVSTParam(" + nArrayIndex + ")\nVSTParamIndex=" + \aVSTParam(nArrayIndex)\nVSTParamIndex +
                               ", \fVSTParamDefaultValue=" + StrF(\aVSTParam(nArrayIndex)\fVSTParamDefaultValue) +
                               ", \fVSTParamValue=" + StrF(\aVSTParam(nArrayIndex)\fVSTParamValue))
        EndIf
      Next nParamIndex
      \nVSTMaxParam = nArrayIndex
    EndIf       
    ; chunk (if required)
    If (nProgramCount = 0) Or (\sVSTPluginName = "Metaplugin")
      nChunkPtr = BASS_VST_GetChunk(nVSTHandle, 0, @nChunkLength)
      debugMsgC(sProcName, "BASS_VST_GetChunk(" + sVSTHandle + ", 0, @nChunkLength) returned " + nChunkPtr + ", nChunkLength=" + nChunkLength)
      If nChunkPtr > 0
        \rVSTChunk\sChunkMagic = PeekS(nChunkPtr, 4, #PB_Ascii)
        Select \rVSTChunk\sChunkMagic
          Case "VC2!"
            debugMsgC(sProcName, ".. chunkMagic=" + \rVSTChunk\sChunkMagic)
            \rVSTChunk\nByteSize = PeekL(nChunkPtr+4)
            debugMsgC(sProcName, ".. byteSize=" + \rVSTChunk\nByteSize)
            nByteOffset = 8
            If \rVSTChunk\nByteSize > 0
              \rVSTChunk\sChunkData = PeekS(nChunkPtr+nByteOffset, \rVSTChunk\nByteSize, #PB_Ascii)
              debugMsgC(sProcName, \rVSTChunk\sChunkData)
            EndIf
          Case "<?xm"
            debugMsgC(sProcName, ".. chunkMagic=" + \rVSTChunk\sChunkMagic)
            \rVSTChunk\nByteSize = nChunkLength
            debugMsgC(sProcName, ".. byteSize=" + \rVSTChunk\nByteSize)
            \rVSTChunk\sChunkData = PeekS(nChunkPtr, nChunkLength, #PB_Ascii)
            debugMsgC(sProcName, \rVSTChunk\sChunkData)
        EndSelect
      EndIf
    EndIf
    
    ; adjust the 'other channel if both source channels in use
    If \nSourceAltChannel <> 0
      ; if \nSourceAltChannel <> 0 then both channels in use, which occurs (only) for a loop with a cross-fade, as that requires the audio fiole to be opened twice
      Select nVSTHandle
        Case \nVSTHandle
          ; if the parameter
          VST_setAudProgramAndParams(\nVSTAltHandle, pAudPtr)
        Case \nVSTAltHandle
          VST_setAudProgramAndParams(\nVSTHandle, pAudPtr)
      EndSelect
    EndIf
    
    VST_applyVSTInfoToSameAsSubCues(pAudPtr) ; Added 21Apr2024 11.10.2cb
    
    ; end
    postChangeAudL(u, #False, pAudPtr)
    If bTrace
      VST_logVSTData(nVSTHandle)
    EndIf
  EndWith
  
  debugMsgC(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_logVSTData(nVSTHandle.l)
  PROCNAMEC()
  Protected nProgramIndex.l, nParamCount.l, nParamIndex.l
  Protected fParamValue.f, sVSTHandle.s
  Protected nBassResult.l
  Protected rVSTParamInfo.BASS_VST_PARAM_INFO
  Protected nProgramCount.l, nProgramNamePtr, sProgramName.s
  Protected nParamCountDigits
  Protected nChunkPtr, nChunkLength.l, sChunkMagic.s, nByteSize.l, nByteOffset.l, sFxMagic.s, sFuture.s
  
  debugMsg(sProcName, #SCS_START + ", nVSTHandle=" + decodeHandle(nVSTHandle))
  
  CompilerIf #c_minimal_vst = #False
    If nVSTHandle <> 0
      sVSTHandle = decodeHandle(nVSTHandle)
      nChunkPtr = BASS_VST_GetChunk(nVSTHandle, 0, @nChunkLength)
      debugMsg(sProcName, "BASS_VST_GetChunk(" + sVSTHandle + ", 0, @nChunkLength) returned " + nChunkPtr + ", nChunkLength=" + nChunkLength)
      If nChunkPtr > 0
        sChunkMagic = PeekS(nChunkPtr, 4, #PB_Ascii)
        Select sChunkMagic
          Case "VC2!"
            debugMsg(sProcName, ".. chunkMagic=" + sChunkMagic)
            nByteSize = PeekL(nChunkPtr+4)
            debugMsg(sProcName, ".. byteSize=" + nByteSize)
            nByteOffset = 8
            If nByteSize > 0
              debugMsg(sProcName, "   " + PeekS(nChunkPtr+nByteOffset, nByteSize, #PB_Ascii))
            EndIf
          Case "CcnK"
            debugMsg(sProcName, ".. chunkMagic=" + sChunkMagic)
            nByteSize = PeekL(nChunkPtr+4)
            debugMsg(sProcName, ".. byteSize=" + nByteSize)
            nByteOffset = 8
            If nByteSize > 0
              sFxMagic = PeekS(nChunkPtr+nByteOffset, 4, #PB_Ascii)
              debugMsg(sProcName, ".. fxMagic=" + sFxMagic)
              nByteOffset + 4
              debugMsg(sProcName, ".. version=" + PeekL(nChunkPtr+nByteOffset))
              nByteOffset + 4
              debugMsg(sProcName, ".. fxID=" + PeekL(nChunkPtr+nByteOffset))
              nByteOffset + 4
              debugMsg(sProcName, ".. fxVersion=" + PeekL(nChunkPtr+nByteOffset))
              nByteOffset + 4
              Select sFxMagic
                Case "FxCk"
                  debugMsg(sProcName, ".. numParams=" + PeekL(nChunkPtr+nByteOffset))
                  nByteOffset + 4
                  debugMsg(sProcName, ".. prgName=" + PeekS(nChunkPtr+nByteOffset, 28, #PB_Ascii))
                  nByteOffset + 28
                Case "FPCh"
                  debugMsg(sProcName, ".. numPrograms=" + PeekL(nChunkPtr+nByteOffset))
                  nByteOffset + 4
                  debugMsg(sProcName, ".. prgName=" + PeekS(nChunkPtr+nByteOffset, 28, #PB_Ascii))
                  nByteOffset + 28
                Case "FxBk"
                  debugMsg(sProcName, ".. numPrograms=" + PeekL(nChunkPtr+nByteOffset))
                  nByteOffset + 4
                  sFuture = PeekS(nChunkPtr+nByteOffset, 128, #PB_Ascii)
                  debugMsg(sProcName, ".. future=" + stringToHexString(sFuture))
                  nByteOffset + 128
                Case "FBCh"
                  debugMsg(sProcName, ".. numPrograms=" + PeekL(nChunkPtr+nByteOffset))
                  nByteOffset + 4
                  sFuture = PeekS(nChunkPtr+nByteOffset, 128, #PB_Ascii)
                  debugMsg(sProcName, ".. future=" + stringToHexString(sFuture))
                  nByteOffset + 128
                  debugMsg(sProcName, ".. chunkSize=" + PeekL(nChunkPtr+nByteOffset))
                  nByteOffset + 4
              EndSelect
            EndIf
          Case "<?xm"
            debugMsg(sProcName, PeekS(nChunkPtr, nChunkLength, #PB_Ascii))
          Default
            debugMsg(sProcName, ".. fxMagic=" + PeekS(nChunkPtr+8, 4, #PB_Ascii))
        EndSelect
      EndIf
      nProgramCount = BASS_VST_GetProgramCount(nVSTHandle)
      debugMsg2(sProcName, "BASS_VST_GetProgramCount(" + sVSTHandle + ")", nProgramCount)
      For nProgramIndex = 0 To nProgramCount-1
        nProgramNamePtr = BASS_VST_GetProgramName(nVSTHandle, nProgramIndex)
        If nProgramNamePtr > 0
          sProgramName = PeekS(nProgramNamePtr, -1, #PB_Ascii)
          If Left(sProgramName, 4) <> "USER" ; NB should also test for plugin name = "TDR Nova"
            debugMsg(sProcName, "BASS_VST_GetProgramName(" + sVSTHandle + ", " + nProgramIndex + ") returned sProgramName=" + sProgramName)
          EndIf
        Else
          debugMsg2(sProcName, "BASS_VST_GetProgramName(" + sVSTHandle + ", " + nProgramIndex + ")", nProgramNamePtr)
        EndIf
      Next nProgramIndex
      nProgramIndex = BASS_VST_GetProgram(nVSTHandle)
      debugMsg2(sProcName, "BASS_VST_GetProgram(" + sVSTHandle + ")", nProgramIndex)
      If nProgramIndex >= 0
        nParamCount = BASS_VST_GetParamCount(nVSTHandle)
        debugMsg2(sProcName, "BASS_VST_GetParamCount(" + sVSTHandle + ")", nParamCount)
        If nParamCount < 10
          nParamCountDigits = 1
        ElseIf nParamCount < 100
          nParamCountDigits = 2
        Else
          nParamCountDigits = 3
        EndIf
        If nParamCount > 0
          For nParamIndex = 0 To nParamCount-1
            fParamValue = BASS_VST_GetParam(nVSTHandle, nParamIndex)
            ; debugMsg(sProcName, "BASS_VST_GetParam(" + sVSTHandle + ", " + nParamIndex + ") returned " + StrF(fParam))
            nBassResult = BASS_VST_GetParamInfo(nVSTHandle, nParamIndex, @rVSTParamInfo)
            ; debugMsg2(sProcName, "BASS_VST_GetParamInfo(" + sVSTHandle + ", " + nParamIndex + ", @rVSTParamInfo)", nBassResult)
            With rVSTParamInfo
              debugMsg(sProcName, "nParamIndex=" + RSet(Str(nParamIndex), nParamCountDigits, "0") +
                                  ", name=" + PeekS(@\name, -1, #PB_Ascii) +
                                  ", unit=" + PeekS(@\unit, -1, #PB_Ascii) +
                                  ", display=" + PeekS(@\display, -1, #PB_Ascii) +
                                  ", defaultValue=" + StrF(\defaultValue) +
                                  ", fParamValue=" + StrF(fParamValue))
            EndWith
          Next nParamIndex
        EndIf
      EndIf
    EndIf
  CompilerEndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_setAudProgramAndParams(nVSTHandle.l, pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sVSTHandle.s
  Protected nArrayIndex, nParamIndex.l, fParamValue.f
  Protected nProgramIndex.l, nProgramCount.l
  Protected nChunkLength.l
  Protected nBassResult.l
  Protected nMemSize, *mChunk, bIsPreset.l
  
  debugMsg(sProcName, #SCS_START)
  
  sVSTHandle = decodeHandle(nVSTHandle)
  
  With aAud(pAudPtr)
    ; if chunk info present, ALWAYS set that first so that any individual program and parameter settings will take effect later in this procedure
    CompilerIf #c_minimal_vst = #False
      If \rVSTChunk\nByteSize > 0
        Select \rVSTChunk\sChunkMagic
          Case "VC2!"
            nMemSize = 8 + \rVSTChunk\nByteSize + 1
            *mChunk = AllocateMemory(nMemSize)
            PokeS(*mChunk, \rVSTChunk\sChunkMagic, 4, #PB_Ascii | #PB_String_NoZero)
            PokeL(*mChunk+4, \rVSTChunk\nByteSize)
            PokeS(*mChunk+8, \rVSTChunk\sChunkData, \rVSTChunk\nByteSize, #PB_Ascii)
            nChunkLength = 8 + \rVSTChunk\nByteSize
          Case "<?xm"
            nChunkLength = \rVSTChunk\nByteSize
            nMemSize = nChunkLength + 1
            *mChunk = AllocateMemory(nMemSize)
            PokeS(*mChunk, \rVSTChunk\sChunkData, \rVSTChunk\nByteSize, #PB_Ascii)
        EndSelect
        If nChunkLength > 0
          nBassResult = BASS_VST_SetChunk(nVSTHandle, bIsPreset, *mChunk, nChunkLength)
          debugMsg2(sProcName, "BASS_VST_SetChunk(" + sVSTHandle + ", " + bIsPreset + ", *mChunk, " + nChunkLength + ")", nBassResult)
          debugMsg(sProcName, PeekS(*mChunk, 4, #PB_Ascii))
          debugMsg(sProcName, Str(PeekL(*mChunk+4)))
          debugMsg(sProcName, PeekS(*mChunk+8, nChunkLength-8, #PB_Ascii))
          ; debugMsg(sProcName, "MemorySize(*mChunk)=" + MemorySize(*mChunk) + ", *mChunk=" + stringToHexString(PeekS(*mChunk,-1,#PB_Ascii)))
        EndIf
      EndIf
    CompilerEndIf
    
    ; program
    CompilerIf #c_minimal_vst = #False
      nProgramCount = BASS_VST_GetProgramCount(nVSTHandle)
      debugMsg2(sProcName, "BASS_VST_GetProgramCount(" + sVSTHandle + ")", nProgramCount)
      If nProgramCount > 0
        nProgramIndex = \nVSTProgram
        If nProgramIndex < 0
          nProgramIndex = 0
        EndIf
        BASS_VST_SetProgram(nVSTHandle, nProgramIndex)
        ; debugMsg(sProcName, "BASS_VST_SetProgram(" + sVSTHandle + ", " + nProgramIndex + ")") 
      EndIf
    CompilerEndIf
    
    ; parameters
    CompilerIf #c_minimal_vst = #False
      For nArrayIndex = 0 To \nVSTMaxParam
        nParamIndex = \aVSTParam(nArrayIndex)\nVSTParamIndex
        fParamValue = \aVSTParam(nArrayIndex)\fVSTParamValue
        BASS_VST_SetParam(nVSTHandle, nParamIndex, fParamValue)
        ; debugMsg(sProcName, "BASS_VST_SetParam(" + sVSTHandle + ", " + nParamIndex + ", " + StrF(fParamValue) + ")")   
      Next nArrayIndex
;     CompilerElse
;       nArrayIndex = 3
;       nParamIndex = \aVSTParam(nArrayIndex)\nVSTParamIndex
;       fParamValue = \aVSTParam(nArrayIndex)\fVSTParamValue
;       BASS_VST_SetParam(nVSTHandle, nParamIndex, fParamValue)
;       debugMsg(sProcName, "BASS_VST_SetParam(" + sVSTHandle + ", " + nParamIndex + ", " + StrF(fParamValue) + ")")   
    CompilerEndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_setDevProgramAndParams(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  Protected nPluginIndex, nVSTHandle.l, sVSTHandle.s
  Protected nArrayIndex, nParamIndex.l, fParamValue.f
  Protected nProgramIndex.l, nProgramCount.l
  Protected nChunkLength.l
  Protected nBassResult.l
  Protected nMemSize, *mChunk, bIsPreset.l
  Protected nTmpChunkPtr, nTmpChunkLength.l, nTmpByteOffset.l, rTmpVSTChunk.tyVSTChunk ; INFO: temp ???
  
  debugMsg(sProcName, #SCS_START)
  
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    With grVST\aDevVSTPlugin(nPluginIndex)
      nVSTHandle = \nDevVSTHandle
      sVSTHandle = decodeHandle(nVSTHandle)
      ; if chunk info present, ALWAYS set that first so that any individual program and parameter settings will take effect later in this procedure
      If \rDevVSTChunk\nByteSize > 0
        Select \rDevVSTChunk\sChunkMagic
          Case "VC2!"
            nMemSize = 8 + \rDevVSTChunk\nByteSize + 1
            *mChunk = AllocateMemory(nMemSize)
            PokeS(*mChunk, \rDevVSTChunk\sChunkMagic, 4, #PB_Ascii | #PB_String_NoZero)
            PokeL(*mChunk+4, \rDevVSTChunk\nByteSize)
            PokeS(*mChunk+8, \rDevVSTChunk\sChunkData, \rDevVSTChunk\nByteSize, #PB_Ascii)
            nChunkLength = 8 + \rDevVSTChunk\nByteSize
          Case "<?xm"
            nChunkLength = \rDevVSTChunk\nByteSize
            nMemSize = nChunkLength + 1
            *mChunk = AllocateMemory(nMemSize)
            PokeS(*mChunk, \rDevVSTChunk\sChunkData, \rDevVSTChunk\nByteSize, #PB_Ascii)
        EndSelect
        If nChunkLength > 0
          nBassResult = BASS_VST_SetChunk(nVSTHandle, bIsPreset, *mChunk, nChunkLength)
          debugMsg2(sProcName, "BASS_VST_SetChunk(" + sVSTHandle + ", " + bIsPreset + ", *mChunk, " + nChunkLength + ")", nBassResult)
          debugMsg(sProcName, PeekS(*mChunk, 4, #PB_Ascii))
          debugMsg(sProcName, Str(PeekL(*mChunk+4)))
          debugMsg(sProcName, PeekS(*mChunk+8, nChunkLength-8, #PB_Ascii))
          ; debugMsg(sProcName, "MemorySize(*mChunk)=" + MemorySize(*mChunk) + ", *mChunk=" + stringToHexString(PeekS(*mChunk,-1,#PB_Ascii)))
          ; INFO: temp ???
          nTmpChunkPtr = BASS_VST_GetChunk(nVSTHandle, 0, @nTmpChunkLength)
          debugMsg(sProcName, "BASS_VST_GetChunk(" + sVSTHandle + ", 0, @nTmpChunkLength) returned " + nTmpChunkPtr + ", nTmpChunkLength=" + nTmpChunkLength)
          If nTmpChunkPtr > 0
            rTmpVSTChunk\sChunkMagic = PeekS(nTmpChunkPtr, 4, #PB_Ascii)
            Select rTmpVSTChunk\sChunkMagic
              Case "VC2!"
                debugMsg(sProcName, ".. chunkMagic=" + rTmpVSTChunk\sChunkMagic)
                rTmpVSTChunk\nByteSize = PeekL(nTmpChunkPtr+4)
                debugMsg(sProcName, ".. byteSize=" + rTmpVSTChunk\nByteSize)
                nTmpByteOffset = 8
                If rTmpVSTChunk\nByteSize > 0
                  rTmpVSTChunk\sChunkData = PeekS(nTmpChunkPtr+nTmpByteOffset, rTmpVSTChunk\nByteSize, #PB_Ascii)
                  debugMsg(sProcName, rTmpVSTChunk\sChunkData)
                EndIf
              Case "<?xm"
                debugMsg(sProcName, ".. chunkMagic=" + rTmpVSTChunk\sChunkMagic)
                rTmpVSTChunk\nByteSize = nTmpChunkLength
                debugMsg(sProcName, ".. byteSize=" + rTmpVSTChunk\nByteSize)
                rTmpVSTChunk\sChunkData = PeekS(nTmpChunkPtr, nTmpChunkLength, #PB_Ascii)
                debugMsg(sProcName, rTmpVSTChunk\sChunkData)
            EndSelect
          EndIf
          ; INFO: end temp ???
        EndIf
      EndIf
      
      ; program
      nProgramCount = BASS_VST_GetProgramCount(nVSTHandle)
      debugMsg2(sProcName, "BASS_VST_GetProgramCount(" + sVSTHandle + ")", nProgramCount)
      If nProgramCount > 0
        nProgramIndex = \nDevVSTProgram
        If nProgramIndex < 0
          nProgramIndex = 0
        EndIf
        BASS_VST_SetProgram(nVSTHandle, nProgramIndex)
        debugMsg(sProcName, "BASS_VST_SetProgram(" + sVSTHandle + ", " + nProgramIndex + ")") 
      EndIf
      
      ; parameters
      For nArrayIndex = 0 To \nDevVSTMaxParam
        nParamIndex = \aDevVSTParam(nArrayIndex)\nVSTParamIndex
        fParamValue = \aDevVSTParam(nArrayIndex)\fVSTParamValue
        BASS_VST_SetParam(nVSTHandle, nParamIndex, fParamValue)
        debugMsg(sProcName, "BASS_VST_SetParam(" + sVSTHandle + ", " + nParamIndex + ", " + StrF(fParamValue) + ")")   
      Next nArrayIndex
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_loadAudVSTPlugin(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected sVSTPluginFile.s, nProcessResult, nIndex
  Protected nBASSHandle.l, nVSTHandle.l, sVSTHandle.s
  Protected nCount
  Protected bLogData = #False
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    If \sVSTReqdPluginName
      sVSTPluginFile = VST_getPluginFileLocation(\sVSTReqdPluginName, #PB_Compiler_Processor)
      debugMsg(sProcName, "\sVSTReqdPluginName=" + \sVSTReqdPluginName + ", sVSTPluginFile=" + #DQUOTE$ + sVSTPluginFile + #DQUOTE$)
      While #True
        If sVSTPluginFile
          
          For nCount = 1 To 2
            
            If nCount = 1
              nBASSHandle = \nSourceChannel
              nVSTHandle = \nVSTHandle
            Else
              nBASSHandle = \nSourceAltChannel
              nVSTHandle = \nVSTAltHandle
            EndIf
            
            ; Remove any existing plugin
            If nVSTHandle <> 0 
              BASS_VST_ChannelRemoveDSP(nBASSHandle, nVSTHandle)
              debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(nBASSHandle) + ", " + decodeHandle(nVSTHandle) + ")")
              nVSTHandle = 0
              If nCount = 1
                \nVSTHandle = 0
              Else
                \nVSTAltHandle = 0
              EndIf
            EndIf
            
            ; Load the selected VST plugin
            debugMsg(sProcName, "Setting current ChannelDSP")
            nVSTHandle = BASS_VST_ChannelSetDSP(nBASSHandle, @sVSTPluginFile, #BASS_UNICODE, 0)     
            If nVSTHandle = 0
              debugMsg(sProcName, "VST Plugin Failed to Load")
              nProcessResult = #SCS_VST_PLUGIN_ERROR_PLUGIN_NOT_LOADED
              Break
            Else
              newHandle(#SCS_HANDLE_VST, nVSTHandle, #False)
              debugMsg2(sProcName, "BASS_VST_ChannelSetDSP(" + decodeHandle(nBASSHandle) + ", @" + #DQUOTE$ + sVSTPluginFile + #DQUOTE$ + ", #BASS_UNICODE, 0)", nVSTHandle)
              sVSTHandle = decodeHandle(nVSTHandle)
            EndIf
            If nVSTHandle <> 0
              If nCount = 1
                \nVSTHandle = nVSTHandle
              Else
                \nVSTAltHandle = nVSTHandle
              EndIf
            EndIf
            
            ; Set the Program and Parameters using the info saved in this aAud()
            VST_setAudProgramAndParams(nVSTHandle, pAudPtr)
            
            VST_setPluginBypass(nVSTHandle, pAudPtr)   
            
          Next nCount
          
          nVSTHandle = aAud(pAudPtr)\nVSTHandle
          If bLogData
            VST_logVSTData(nVSTHandle)
          EndIf
          
        Else
          nProcessResult = #SCS_VST_PLUGIN_ERROR_FILE_LOCATION
        EndIf
        Break
      Wend
      If nProcessResult > 0
        ; Display Warning for VST
        nIndex = VST_getLibPluginIndex(\sVSTPluginName)
        If nIndex >= 0
          If grVST\aLibVSTPlugin(nIndex)\bLibWarningShown = #False
            VST_showWarning(nProcessResult, \sVSTPluginName, \sCue)
          EndIf
          grVST\aLibVSTPlugin(nIndex)\bLibWarningShown = #True
        EndIf
        ProcedureReturn #False
      EndIf
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure VST_loadDevVSTPlugin(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  Protected nMixerStreamPtr, nMixerStreamHandle.l, sVSTHandle.s, nVSTHandle.l, nPriority.l
  Protected sVSTPluginFile.s, nProcessResult, nIndex
  Protected nPluginIndex
  Protected sMsg.s, sButton.s, sDontTellMeAgainText.s, nOption
  Protected bLogData = #False
  Static bDontTellMeAgain
  
  debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder)
  
  nMixerStreamPtr = getMixerStreamPtrForLogicalDev(sLogicalDev)
  If nMixerStreamPtr >= 0
    nMixerStreamHandle = gaMixerStreams(nMixerStreamPtr)\nMixerStreamHandle
  EndIf
  If nMixerStreamHandle = 0
    If gbUseBASSMixer = #False
      If bDontTellMeAgain = #False
        sMsg = Lang("WVP", "DevPlugins") + "|" + createWrapTextForOptionRequester(450, Lang("VST", "MixerWarning"))
        ; "MixerWarning" = "Warning! VST plugins can only be assigned to devices if the BASS Mixer Option is selected or if you use ASIO instead of DirectSound. This Option will be auto-set for this cue file on re-opening the cue file."
        sButton = Lang("Btns", "OK")
        sDontTellMeAgainText = Lang("Common", "DontTellMeAgain") ; "Don't tell me this again during this SCS session."
        debugMsg(sProcName, sMsg)
        nOption = OptionRequester(0, 0, sMsg, sButton, 200, #IDI_WARNING, 0, sDontTellMeAgainText)
        debugMsg(sProcName, "nOption=$" + Hex(nOption,#PB_Long))
        If nOption & $10000
          ; user selected checkbox for "Don't tell me again..."
          bDontTellMeAgain = #True
        EndIf
      EndIf
    EndIf
    debugMsg(sProcName, "exiting because nMixerStreamHandle=0")
    ProcedureReturn #False
  EndIf
  
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  debugMsg(sProcName, "nPluginIndex=" + nPluginIndex)
  If nPluginIndex >= 0
    ; Remove any existing plugin
    With grVST\aDevVSTPlugin(nPluginIndex)
      If \nDevVSTHandle <> 0
        BASS_VST_ChannelRemoveDSP(nMixerStreamHandle, \nDevVSTHandle)
        debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(nMixerStreamHandle) + ", " + decodeHandle(\nDevVSTHandle) + ")")
      EndIf
      \nDevVSTHandle = 0
      
      debugMsg(sProcName, "grVST\aDevVSTPlugin(" + nPluginIndex + ")\sDevVSTPluginName=" + \sDevVSTPluginName)
      If \sDevVSTPluginName
        sVSTPluginFile = VST_getPluginFileLocation(\sDevVSTPluginName, #PB_Compiler_Processor)
        debugMsg(sProcName, "\sDevVSTPluginName=" + \sDevVSTPluginName + ", sVSTPluginFile=" + #DQUOTE$ + sVSTPluginFile + #DQUOTE$)
        If sVSTPluginFile
          nPriority = nVSTOrder * -1
          ; eg 'processing order' 1 = priority = -1; 'processing order' 2 = priority = -2. Priority -1 is higher than -2 so 'processing order' 1 will be processed first
          ; Load the selected VST plugin
          debugMsg(sProcName, "Setting current ChannelDSP")
          nVSTHandle = BASS_VST_ChannelSetDSP(nMixerStreamHandle, @sVSTPluginFile, #BASS_UNICODE, nPriority)
          If nVSTHandle = 0
            debugMsg(sProcName, "VST Plugin Failed to Load")
            nProcessResult = #SCS_VST_PLUGIN_ERROR_PLUGIN_NOT_LOADED
          Else
            newHandle(#SCS_HANDLE_VST, nVSTHandle, #False)
            debugMsg2(sProcName, "BASS_VST_ChannelSetDSP(" + decodeHandle(nMixerStreamHandle) + ", @" + #DQUOTE$ + sVSTPluginFile + #DQUOTE$ + ", #BASS_UNICODE, " + nPriority + ")", nVSTHandle)
            sVSTHandle = decodeHandle(nVSTHandle)
          EndIf
          \nDevVSTHandle = nVSTHandle
          
          VST_setDevProgramAndParams(sLogicalDev, nVSTOrder)
          VST_setDevPluginBypass(sLogicalDev, nVSTOrder)
          If bLogData
            VST_logVSTData(nVSTHandle)
          EndIf
          
        Else
          nProcessResult = #SCS_VST_PLUGIN_ERROR_FILE_LOCATION
        EndIf
        
        If nProcessResult <> 0
          ; Display Warning for VST
          nIndex = VST_getLibPluginIndex(\sDevVSTPluginName)
          If nIndex >= 0
            ; should be #True
            If grVST\aLibVSTPlugin(nIndex)\bLibWarningShown = #False
              VST_showWarning(nProcessResult, \sDevVSTPluginName)
            EndIf
            grVST\aLibVSTPlugin(nIndex)\bLibWarningShown = #True
          EndIf
          ProcedureReturn #False
        EndIf
        
      EndIf ; EndIf \sVSTPluginName
    EndWith
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  ProcedureReturn #True
  
EndProcedure

Procedure VST_clearAudPlugin(pAudPtr)
  PROCNAMECA(pAudPtr)
  
  debugMsg(sProcName, #SCS_START)
  
  With aAud(pAudPtr)
    ; Remove any existing plugin
    If \nVSTHandle <> 0
      BASS_VST_ChannelRemoveDSP(\nSourceChannel, \nVSTHandle)
      debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(\nSourceChannel) + ", " + decodeHandle(\nVSTHandle) + ")")
      \nVSTHandle = 0
    EndIf
    If \nVSTAltHandle <> 0
      BASS_VST_ChannelRemoveDSP(\nSourceAltChannel, \nVSTAltHandle)
      debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(\nSourceAltChannel) + ", " + decodeHandle(\nVSTAltHandle) + ")")
      \nVSTAltHandle = 0
    EndIf
    ; clear info
    \sVSTPluginName = grAudDef\sVSTPluginName
    \nVSTProgram = grAudDef\nVSTProgram
    \nVSTMaxParam = grAudDef\nVSTMaxParam
    \rVSTChunk = grAudDef\rVSTChunk
  EndWith
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_unsetDevPlugin(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  Protected nMixerStreamPtr, nMixerStreamHandle.l, nPluginIndex, nVSTHandle.l
  
  debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder)
  
  nMixerStreamPtr = getMixerStreamPtrForLogicalDev(sLogicalDev)
  If nMixerStreamPtr >= 0
    nMixerStreamHandle = gaMixerStreams(nMixerStreamPtr)\nMixerStreamHandle
    If nMixerStreamHandle <> 0
      nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
      If nPluginIndex >= 0
        nVSTHandle = grVST\aDevVSTPlugin(nPluginIndex)\nDevVSTHandle
        If nVSTHandle <> 0
          BASS_VST_ChannelRemoveDSP(nMixerStreamHandle, nVSTHandle)
          debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(nMixerStreamHandle) + ", " + decodeHandle(nVSTHandle) + ")")
          grVST\aDevVSTPlugin(nPluginIndex)\nDevVSTHandle = 0
        EndIf
      EndIf
    EndIf
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_clearDevPlugin(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  ; nb this procedure clears only one plugin for a device, not ALL plugins for the device, to minimise the likelihood that we lose parameter settings etc for other plugins
  Protected nPluginIndex
  
  debugMsg(sProcName, #SCS_START + ", sLogicalDev=" + sLogicalDev + ", nVSTOrder=" + nVSTOrder)
  
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    VST_unsetDevPlugin(sLogicalDev, nVSTOrder)
    grVST\aDevVSTPlugin(nPluginIndex) = grDevVSTPluginDef
    grVST\aDevVSTPlugin(nPluginIndex)\sDevVSTLogicalDev = sLogicalDev
    grVST\aDevVSTPlugin(nPluginIndex)\nDevVSTOrder = nVSTOrder
  EndIf
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure VST_streamProc(Handle.l, *buffer, length.l, *user)
  ; Dummy streamProc because Procedure VST_getEffectName() needs to have a BASS stream to use with BASS_VST_ChannelSetDSP(), but that stream doesn't need to play anything.
  ; Procedure VST_streamProc() is never actually called because that BASS stream is never played.
EndProcedure

Procedure VST_getInfo(sFileLocation.s, *rVSTInfo.BASS_VST_INFO)
  PROCNAMEC()
  Protected nStreamHandle.l, nVSTHandle.l, nBassResult.l
  Protected sErrorMsg.s
  Protected bValid = #True
  
  nStreamHandle = BASS_StreamCreate(44100, 2, #BASS_SAMPLE_FLOAT, @VST_streamProc(), 0)
  newHandle(#SCS_HANDLE_TMP, nStreamHandle, #False)
  debugMsg2(sProcName, "BASS_StreamCreate(44100, 2, #BASS_SAMPLE_FLOAT, @VST_streamProc(), 0)", nStreamHandle)
  If nStreamHandle
    nVSTHandle = BASS_VST_ChannelSetDSP(nStreamHandle, @sFileLocation, #BASS_UNICODE, 0)
    newHandle(#SCS_HANDLE_VST, nVSTHandle, #False)
    debugMsg2(sProcName, "BASS_VST_ChannelSetDSP(" + decodeHandle(nStreamHandle) + ", @" + #DQUOTE$ + sFileLocation + #DQUOTE$ + ", #BASS_UNICODE, 0)", nVSTHandle)
    If nVSTHandle = 0
      sErrorMsg = getBassErrorDesc(BASS_ErrorGetCode())
      debugMsg(sProcName, "sErrorMsg=" + sErrorMsg)
      bValid = #False
    Else
      nBassResult = BASS_VST_GetInfo(nVSTHandle, *rVSTInfo)
      debugMsg2(sProcName, "BASS_VST_GetInfo(" + decodeHandle(nVSTHandle) + ", *rVSTInfo)", nBassResult)
      If nBassResult = 0
        sErrorMsg = getBassErrorDesc(BASS_ErrorGetCode())
        debugMsg(sProcName, "sErrorMsg=" + sErrorMsg)
        bValid = #False
      EndIf
      BASS_VST_ChannelRemoveDSP(nStreamHandle, nVSTHandle)
      debugMsg(sProcName, "BASS_VST_ChannelRemoveDSP(" + decodeHandle(nStreamHandle) + ", " + decodeHandle(nVSTHandle) + ")")
    EndIf
    BASS_StreamFree(nStreamHandle)
    debugMsg3(sProcName, "BASS_StreamFree(" + decodeHandle(nStreamHandle) + ")")
  EndIf
  gsVSTError = sErrorMsg
  ProcedureReturn bValid
EndProcedure

Procedure VST_setPluginBypass(nVSTHandle.l, pAudPtr)
  PROCNAMECA(pAudPtr)
  
  CompilerIf #c_minimal_vst = #False
    With aAud(pAudPtr)
      BASS_VST_SetBypass(nVSTHandle, \bVSTBypass)
      debugMsg(sProcName, "BASS_VST_SetBypass(" + decodeHandle(nVSTHandle) + ", " + strB(\bVSTBypass) + ")")
    EndWith
  CompilerEndIf
  
EndProcedure

Procedure VST_setDevPluginBypass(sLogicalDev.s, nVSTOrder)
  PROCNAMEC()
  Protected nPluginIndex
  
  nPluginIndex = VST_getDevPluginIndexForDevItem(sLogicalDev, nVSTOrder)
  If nPluginIndex >= 0
    With grVST\aDevVSTPlugin(nPluginIndex)
      BASS_VST_SetBypass(\nDevVSTHandle, \bDevVSTBypass)
      debugMsg(sProcName, "BASS_VST_SetBypass(" + decodeHandle(\nDevVSTHandle) + ", " + strB(\bDevVSTBypass) + ")")
    EndWith
  EndIf
  
EndProcedure

Procedure VST_checkPluginInList(sPluginName.s)
  PROCNAMEC()
  Protected bResult, n
  
  For n = 0 To grVST\nMaxLibVSTPlugin
    If sPluginName = grVST\aLibVSTPlugin(n)\sLibVSTPluginName
      bResult = #True
      Break
    EndIf
  Next n
  ProcedureReturn bResult
EndProcedure

Procedure VST_changePluginName(sOldPluginName.s, sNewPluginName.s)
  PROCNAMEC()
  Protected i, j, k, u, nDevNo, nVSTIndex
  Protected sUndoDescr.s
  
  sUndoDescr = Lang("WVP","lblLibVSTPluginName")
  For i = 1 To gnLastCue
    j = aCue(i)\nFirstSubIndex
    While j >= 0
      If aSub(j)\bSubTypeF
        k = aSub(j)\nFirstAudIndex
        If k >= 0
          If LCase(aAud(k)\sVSTPluginName) = LCase(sOldPluginName)
            u = preChangeAudS(sOldPluginName, sUndoDescr, k)
            aAud(k)\sVSTPluginName = sNewPluginName
            postChangeAudS(u, sNewPluginName, k)
          EndIf
        EndIf
      EndIf
      j = aSub(j)\nNextSubIndex
    Wend
  Next i
  
  For nVSTIndex = 0 To grVST\nMaxLibVSTPlugin
    With grVST\aLibVSTPlugin(nVSTIndex)
      If LCase(\sLibVSTPluginName) = LCase(sOldPluginName)
        \sLibVSTPluginName = sNewPluginName
      EndIf
    EndWith
  Next nVSTIndex
  For nVSTIndex = 0 To grVST\nMaxDevVSTPlugin
    With grVST\aDevVSTPlugin(nVSTIndex)
      If LCase(\sDevVSTPluginName) = LCase(sOldPluginName)
        \sDevVSTPluginName = sNewPluginName
      EndIf
    EndWith
  Next nVSTIndex
  
EndProcedure

Procedure VST_listDevVSTPlugins()
  PROCNAMEC()
  Protected nPluginIndex
  
  For nPluginIndex = 0 To grVST\nMaxDevVSTPlugin
    With grVST\aDevVSTPlugin(nPluginIndex)
      debugMsg(sProcName, "grVST\aDevVSTPlugin(" + nPluginIndex + ")\sDevVSTLogicalDev=" + \sDevVSTLogicalDev + ", \nDevVSTOrder=" + \nDevVSTOrder + ", \bDevVSTBypass=" + strB(\bDevVSTBypass) + ", \sDevVSTComment=" + \sDevVSTComment)
    EndWith
  Next nPluginIndex
  
EndProcedure

Procedure VST_loadAllDevVSTPlugins()
  PROCNAMEC()
  Protected nPluginIndex
  
  debugMsg(sProcName, #SCS_START)
  
  For nPluginIndex = 0 To grVST\nMaxDevVSTPlugin
    With grVST\aDevVSTPlugin(nPluginIndex)
      If \sDevVSTPluginName
        VST_unsetDevPlugin(\sDevVSTLogicalDev, \nDevVSTOrder)
        VST_loadDevVSTPlugin(\sDevVSTLogicalDev, \nDevVSTOrder)
      EndIf
    EndWith
  Next nPluginIndex
  
  debugMsg(sProcName, #SCS_END)
  
EndProcedure

Procedure.s VST_adjustLogicalDevForVST(sLogicalDev.s)
  PROCNAMEC()
  Protected nPluginIndex, sAdjusted.s
  
  sAdjusted = sLogicalDev
  For nPluginIndex = 0 To grVST\nMaxDevVSTPlugin
    With grVST\aDevVSTPlugin(nPluginIndex)
      If \sDevVSTLogicalDev = sLogicalDev
        If (\sDevVSTPluginName) And (\bDevVSTBypass = #False)
          sAdjusted + "&"
        EndIf
      EndIf
    EndWith
  Next nPluginIndex
  ProcedureReturn sAdjusted
EndProcedure

Procedure VST_changeLogicalDev(sLogicalDevOld.s, sLogicalDevNew.s)
  PROCNAMEC()
  Protected nPluginIndex, sTmp.s
  
  For nPluginIndex = 0 To grVST\nMaxDevVSTPlugin
    With grVST\aDevVSTPlugin(nPluginIndex)
      If \sDevVSTLogicalDev = sLogicalDevOld
        \sDevVSTLogicalDev = sLogicalDevNew
      EndIf
    EndWith
  Next nPluginIndex
  sTmp = VST_adjustLogicalDevForVST(sLogicalDevNew)
  
EndProcedure

Procedure VST_setReqdPluginInfo(pAudPtr)
  PROCNAMECA(pAudPtr)
  Protected i, j, k, nSameAsSubPtr
  
  debugMsg(sProcName, #SCS_START)
  
  nSameAsSubPtr = -1
  With aAud(pAudPtr)
    \sVSTReqdPluginName = ""
    If \sVSTPluginName
      \sVSTReqdPluginName = \sVSTPluginName
    ElseIf \sVSTPluginSameAsCue
      j = getSubPtrForSubRef(\nVSTPluginSameAsSubRef)
      If j >= 0
        k = aSub(j)\nFirstAudIndex
        If k >= 0
          ; copy VST info from aAud(k) to aAud(paudPtr)
          \sVSTReqdPluginName = aAud(k)\sVSTPluginName
          ; chunk
          \rVSTChunk\nByteSize = aAud(k)\rVSTChunk\nByteSize
          \rVSTChunk\sChunkData = aAud(k)\rVSTChunk\sChunkData
          \rVSTChunk\sChunkMagic = aAud(k)\rVSTChunk\sChunkMagic
          ; program
          \nVSTProgram = aAud(k)\nVSTProgram
          ;parameters
          \nVSTMaxParam = aAud(k)\nVSTMaxParam
          CopyArray(aAud(k)\aVSTParam(), \aVSTParam())
          ; bypass
          \bVSTBypass = aAud(k)\bVSTBypass
          nSameAsSubPtr = j
        EndIf ; EndIf k >= 0
      EndIf ; EndIf j >= 0
    EndIf
  EndWith
  
  debugMsg(sProcName, #SCS_END + ", returning nSameAsSubPtr=" + getSubLabel(nSameAsSubPtr))
  ProcedureReturn nSameAsSubPtr ; returns subptr if 'same as cue/subno' requested and found, else returns -1
  
EndProcedure

Procedure VST_applyVSTInfoToSameAsSubCues(pCtrlAudPtr)
  PROCNAMECA(pCtrlAudPtr)
  Protected i, j, k
  Protected sCtrlCue.s, nCtrlSubNo
  
  ; debugMsg(sProcName, #SCS_START)
  
  sCtrlCue = aAud(pCtrlAudPtr)\sCue
  nCtrlSubNo = aAud(pCtrlAudPtr)\nSubNo
  
  For i = 1 To gnLastCue
    If aCue(i)\bSubTypeF
      j = aCue(i)\nFirstSubIndex
      While j >= 0
        If aSub(j)\bSubTypeF
          k = aSub(j)\nFirstAudIndex
          If k >= 0
            With aAud(k)
              If \sVSTPluginSameAsCue = sCtrlCue And \nVSTPluginSameAsSubNo = nCtrlSubNo
                ; debugMsg(sProcName, "calling VST_setReqdPluginInfo(" + getAudLabel(k) + ")")
                VST_setReqdPluginInfo(k)
                If \nFileState = #SCS_FILESTATE_OPEN
                  ; debugMsg(sProcName, "calling VST_loadAudVSTPlugin(" + getAudLabel(k) + ")")
                  VST_loadAudVSTPlugin(k)
                EndIf
              EndIf
            EndWith
          EndIf ; EndIf k >= 0
        EndIf ; EndIf aSub(j)\bSubTypeF
        j = aSub(j)\nNextSubIndex
      Wend
    EndIf ; EndIf aCue(i)\bSubTypeF
  Next i
  
  ; debugMsg(sProcName, #SCS_END)
  
EndProcedure

; EOF